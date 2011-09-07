require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Client do
  
  before do
    @reference = "a_reference"
    @client = described_class.new(@reference)
  end

  describe "new" do
    
    it "should return a new client obj" do
      @client.should be_an_instance_of(described_class)
    end
    
    it "should default the queue_name to QUEUE_NAME" do
      @client.queue_name.should == Bottle::DEFAULT_QUEUE_NAME
    end
    
    it "should set the reply_queue_name to DEFAULT_REPLY_FORMAT, injected with client_ref and object_id" do
      @client.reply_queue_name.should == (Bottle::DEFAULT_REPLY_QUEUE_FORMAT % [@reference, @client.object_id])
    end
  end
  

  describe 'dispatch' do
    include EventedSpec::SpecHelper
    
    em_before { AMQP.cleanup_state }
    em_after  { AMQP.cleanup_state }
    
    before :each do
      @done_timeout = 0.25
    end
    
    it "should convert the given payload into YAML" do
      pending
      #@client.dispatch
    end
    
    it "should create a new publisher" #?
    
    it "should call publish on the new publisher" #?
    
    context "when a block is given" do
      it "should pass a wrapped block on to the publisher"
    end
    
    
    ## should the above be: should publish a new amqp msg with given payload/type/routing_key.?
  end
  
end