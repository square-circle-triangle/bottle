require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Client do
  
  describe "new" do
    it "should return a new client obj"
    
    it "should default the queue_name to QUEUE_NAME"
  end
  
  describe 'dispatch' do
    it "should convert the given payload into YAML"
    
    it "should create a new publisher" #?
    
    it "should call publish on the new publisher" #?
    
    context "when a block is given" do
      it "should pass a wrapped block on to the publisher"
    end
    
    
    ## should the above be: should publish a new amqp msg with given payload/type/routing_key.?
  end
  
end