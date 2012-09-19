require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Listener do
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  before :each do
    @amqptest = AmqpTest.new
    @queue_name = "99.bottles"
  end

  describe "new" do

    it "should initialize the channel and the queue_name" do
      em do
        @amqptest.with_amqp do
          args = {}
          listener = described_class.new(@amqptest.channel, @queue_name)
          listener.queue_name.should == @queue_name
          listener.channel.should == @amqptest.channel
          default_done
        end
      end
    end

  end

  describe "start" do

    it "should bind to the default_exchange" do
      em do
        @amqptest.with_amqp do
          listener = described_class.new(@amqptest.channel, @queue_name)
          listener.queue.should_receive(:bind).with(listener.exchange, :routing_key => @queue_name).and_return(listener.queue)
          listener.start
        end
        default_done
      end
    end

    it "should subscribe to a new queue called #{@queue_name}" do
      em do
        @amqptest.with_amqp do
          listener = described_class.new(@amqptest.channel, @queue_name)
          listener.queue.should_receive(:subscribe).with(:ack => true, &Proc.new { })
          listener.start
        end
        default_done
      end
    end

    it "should set ack on the new queue corectly" do
      em do
        @amqptest.with_amqp do
          listener = described_class.new(@amqptest.channel, @queue_name, { ack: false })
          listener.queue.should_receive(:subscribe).with(:ack => false, &Proc.new { })
          listener.start
        end
        default_done
      end
    end

  end

  describe 'handle_message' do

    class DummyWorker < Bottle::Foreman
      def process(payload)
        {:test => "payload response"}
      end
    end

    before do
      @payload =  { :some => 'content' }.to_yaml
      @de = mock("Exchange")
    end	  

    context 'success' do
      it "should call .process on the desired worker" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'dummyworker', :reply_to => nil })
            meta.stub!(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            Bottle::Foreman.registered_workers['dummyworker'].should_receive(:process)
            listener.handle_message(meta,@payload)	  
            default_done
          end
        end
      end

      it "should respond with the return value of the worker" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'dummyworker', :reply_to => "test.reply", :message_id => "1234" })
            meta.stub!(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            @amqptest.channel.stub!(:default_exchange).and_return(@de)
            @de.should_receive(:publish).with(DummyWorker.new.process({}).to_yaml,
                             :routing_key    => meta.reply_to,
                             :correlation_id => meta.message_id,
                             :mandatory      => true)
            listener.handle_message(meta,@payload)
            default_done
          end
        end
      end

      it "should return true" do
        em do
          @amqptest.with_amqp do
            meta = AMQP::Header.new(@amqptest.channel, Proc.new { }, { :type => 'dummyworker', :reply_to => nil })
            meta.stub!(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            listener.handle_message(meta, @payload).should === true
            default_done
          end
        end
      end

      it "should send ack when ack turned on" do
        em do
          @amqptest.with_amqp do
            meta = AMQP::Header.new(@amqptest.channel, Proc.new { }, { :type => 'dummyworker', :reply_to => nil })
            meta.stub!(:ack)
            meta.should_receive(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            listener.handle_message(meta, @payload).should === true
            default_done
          end
        end
      end

      it "should not send ack when ack turned off" do
        em do
          @amqptest.with_amqp do
            meta = AMQP::Header.new(@amqptest.channel, Proc.new { }, { :type => 'dummyworker', :reply_to => nil })
            meta.stub!(:ack)
            meta.should_not_receive(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name, { ack: false })
            listener.handle_message(meta, @payload).should === true
            default_done
          end
        end
      end
    end

    context 'failure' do
      it "should respond with an error message if a response is required and no matching worker could be found" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'nonexistentworker', :reply_to => 'test.reply', :message_id => "2468" })
            meta.stub!(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            response = {:state => 'error', :message => "Failed to find suitable worker for #{meta.type}" }
            @amqptest.channel.stub!(:default_exchange).and_return(@de)
            @de.should_receive(:publish).with(response.to_yaml,
                             :routing_key    => meta.reply_to,
                             :correlation_id => meta.message_id,
                             :mandatory      => true)
            listener.handle_message(meta,@payload).should === false
            default_done
          end
        end
      end

      it "should respond with an error message if the worker caused an error" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'dummyworker', :reply_to => 'test.reply', :message_id => "3912" })
            meta.stub!(:ack)
            Bottle::Foreman.registered_workers['dummyworker'].stub!(:process).and_raise "DummyWorker raised an error!"
            listener = described_class.new(@amqptest.channel, @queue_name)
            response = {:state => 'error', :message => "DummyWorker raised an error!" }
            @amqptest.channel.stub!(:default_exchange).and_return(@de)
            @de.should_receive(:publish).with(response.to_yaml,
                             :routing_key    => meta.reply_to,
                             :correlation_id => meta.message_id,
                             :mandatory      => true)
            listener.handle_message(meta,@payload)
            default_done
          end
        end
      end

      it "should return false if no matching worker could be found" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'nonexistentworker', :reply_to => nil })
            meta.stub!(:ack)
            listener = described_class.new(@amqptest.channel, @queue_name)
            listener.handle_message(meta,@payload).should === false
            default_done
          end
        end
      end

      it "should return false if an error is encountered while processing" do
        em do
          @amqptest.with_amqp do
            meta =   AMQP::Header.new(@amqptest.channel, Proc.new {}, { :type => 'dummyworker', :reply_to => nil })
            meta.stub!(:ack)
            Bottle::Foreman.registered_workers['dummyworker'].stub!(:process).and_raise "this is an error!"
            listener = described_class.new(@amqptest.channel, @queue_name)
            listener.handle_message(meta,@payload).should === false
            default_done
          end
        end
      end

    end
  end
end
