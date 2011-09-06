require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Publisher do
  describe 'new' do
    it "should setup ivars"
  end
  
  describe "publish" do
    
    it "should add message_id and immediate to the given options"
    
    it "should publish the message over the amqp exchange"
    
    context "when a block given" do
      it "should start monitoring the reply queue"
    end

  end
  
  describe "monitor_reploy_queue" do
    it "should subscribe to a new queue called @reply_queue_name"
    
    it "should yield received message data to the given block"
  end
  
end