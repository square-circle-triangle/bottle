require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::AsyncPublisher do
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  before :each do
    @amqptest = AmqpTest.new
    @reply_queue_name = "99.bottles"
  end

  describe "publish" do

    it "should publish the message over the amqp exchange" do
      em do
        @amqptest.with_amqp do
          pub = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
          pub.stub!(:generate_message_id).and_return("999")
          pub.exchange.should_receive(:publish).with("a message", :message_id => '999', :mandatory => true, :reply_to => @reply_queue_name)
          pub.publish("a message", {}) 
          default_done
        end 
      end
    end

    context "when a block given" do
      it "should start monitoring the reply queue" do
        em do
          @amqptest.with_amqp do
            pub = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
            pub.stub!(:generate_message_id).and_return("999")
            pub.should_receive(:monitor_reply_queue).with(@reply_queue_name, '999')
            pub.publish("a message", {}){puts 'a block'}
            default_done
          end
        end
      end
    end

  end

  describe "monitor_reply_queue" do

    it "should subscribe to a new queue called @reply_queue_name" do
      em do
        @amqptest.with_amqp do
          pub = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
          rq = stub
          @amqptest.channel.should_receive(:queue).and_return(rq)
          rq.should_receive(:subscribe)
          pub.monitor_reply_queue(@reply_queue_name, '999')
          default_done
        end 
      end 
    end

    it "should yield received message data to the given block and call the block" do
      em do
        @amqptest.with_amqp do
          pub = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
          rq = stub
          @amqptest.channel.should_receive(:queue).and_return(rq)
          payload = { :msg => "hi there" }
          metadata = stub(:correlation_id => 1)
          rq.should_receive(:subscribe).and_yield(metadata, payload.to_yaml)
          procstub = stub
          procstub.should_receive(:call).with(payload)
          pub.stub!(:get_reply_block).and_return(procstub)
          pub.monitor_reply_queue('q.reply', '999'){ |metadata, response| }
          default_done
        end
      end
    end

    it "should raise a MissingReplyClosureError if the matching reply_block could not be found" do
      em do
        @amqptest.with_amqp do
          pub = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
          rq = stub
          @amqptest.channel.should_receive(:queue).and_return(rq)
          payload = { :msg => "hi there" }
          metadata = stub(:correlation_id => 1)
          pub.stub!(:get_reply_block).and_return(nil)
          rq.should_receive(:subscribe).and_yield(metadata, payload.to_yaml)
          lambda{ pub.monitor_reply_queue('q.reply', '999'){ |metadata, response|
          }}.should raise_error(Bottle::MissingReplyClosureError)
          default_done
        end
      end
    end

  end

end
