require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Campaign::Listener do

  describe "new" do
    
    it "should create a new listener" do
			args = {}
			Campaigner::Listener.should_receive(:new).with(args)	
			Campaigner::Listener.start(args)
		end
		
	end

	describe "start" do
		
    it "should bind and subscribe to a new queue called @queue_name"

		it "should pass received messages onto the message handler" do
		  pending
		end
	end
	
	describe 'handle_message' do
	  context 'success' do
	    it "should call process on the desired worker"
	    
	    it "should respond with the return value of the worker"
	    
	    it "should return true"
    end
	  
	  context 'failure' do
	    it "should respond with an error message if a response is required and no matching worker could be found"
	    
	    it "should respond with an error message if the worker did respond with the expected response format"
	  
	    it "should return false if no matching worker could be found"
	  
	    it "should return false if an error is encountered"
	    
    end
  end
end
  