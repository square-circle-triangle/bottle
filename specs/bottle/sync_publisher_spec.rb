require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::SyncPublisher do
  
  before :each do
    @amqptest = AmqpTest.new
    @reply_queue_name = "99.bottles"
    @sync_channel = Bunny.new
    @sync_channel.start
  end


  describe "publish" do

    before do
      @msg = "This is an important message"
      @pub = described_class.new(@sync_channel, @sync_channel.exchange('test'), @reply_queue_name)
    end

    it "should publish the message over the amqp exchange" do
      @pub.stub!(:generate_message_id).and_return("abc123")
      @pub.exchange.should_receive(:publish).with(@msg,@pub.default_options) 
      @pub.publish(@msg, {})
    end


    context "when a block given" do
      it "should start monitoring the reply queue" do
        @pub.should_receive(:monitor_reply_queue)
        @pub.publish(@msg){}
      end
    end
  end

  describe "monitor_reply_queue" do
    before do
      @pub = described_class.new(@sync_channel, @sync_channel.exchange('test'), @reply_queue_name)
      @rq = stub
      @pub.stub!(:reply_queue).and_return(@rq)
    end

    it "should subscribe to a new queue called @reply_queue_name" do
      @rq.should_receive(:subscribe)
      @pub.monitor_reply_queue
    end

    it "should yield received message data to the given block" do
      msg = { :msg => "hi there" }
      payload = {:payload => msg.to_yaml } 
      @rq.should_receive(:subscribe).and_yield(payload)
      @pub.monitor_reply_queue { |response|
        response.should == msg 
      }
    end
  end

end
