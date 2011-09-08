require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Foreman do
  class NewWorker < Bottle::Foreman; end

  it "should keep a hash of registered workers" do
    Bottle::Foreman.registered_workers.should be_an_instance_of(Hash)
  end

  it "should add inherited subclasses into the registered_workers hash" do
    total_workers = Bottle::Foreman.registered_workers.size
    class AnotherWorker < Bottle::Foreman; end
    
    Bottle::Foreman.registered_workers['anotherworker'].should be_an_instance_of(AnotherWorker)
    Bottle::Foreman.registered_workers.size.should == total_workers+1
  end
  
  it "should strip leading module references from the workers label" do
    class Bottle::YetAnotherWorker < Bottle::Foreman; end
    Bottle::Foreman.registered_workers['yetanotherworker'].should be_an_instance_of(Bottle::YetAnotherWorker)
  end
  
  describe "helper response methods" do
    
    before do
      @worker = NewWorker.new
    end
    
    describe "success" do
      it "should return a hash" do
        @worker.send(:success,{}).should be_an_instance_of(Hash)
      end
      
      it "should have state = success in the hash" do
        @worker.send(:success,{})[:state].should == 'success'
      end
      
    end
    
    describe "failure" do
      it "should return a hash" do
        @worker.send(:failure).should be_an_instance_of(Hash)
      end
      
      it "should have state = error in the hash" do
        @worker.send(:failure, '')[:state].should == 'error'
      end
    end
  end
end