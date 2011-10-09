require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Publisher do
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  before :each do
    @amqptest = AmqpTest.new
    @reply_queue_name = "99.bottles"
  end

  describe "new" do

    it "should setup ivars" do
      em do
        @amqptest.with_amqp do
          args = {}
          publisher = described_class.new(@amqptest.channel, @amqptest.channel.default_exchange, @reply_queue_name)
          #publisher.reply_queue_name.should == @queue_name
          #publisher.channel.should == @amqptest.channel
          #publisher.exchange.should  == @exchange
          default_done
        end
      end
    end
  end
  
  describe "publish" do
    
    it "should add message_id to the given options"
    
    it "should publish the message over the amqp exchange" do

    end
   end
    
  context "when a block given" do
      it "should start monitoring the reply queue"
  end

  it "should subscribe to a new queue called @reply_queue_name"
    
  it "should yield received message data to the given block" do
    pending
  end
  
end
