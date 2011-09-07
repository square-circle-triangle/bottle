require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Foreman do

  it "should keep a hash of registered workers" do
    Bottle::Foreman.registered_workers.should == {}
  end

  it "should add inherited subclasses into the registered_workers hash" do
    total_workers = Bottle::Foreman.registered_workers.size
    class NewWorker < Bottle::Foreman; end
    
    Bottle::Foreman.registered_workers['newworker'].should be_an_instance_of(NewWorker)
    Bottle::Foreman.registered_workers.size.should == total_workers+1
  end
  
  it "should strip leading module references from the workers label" do
    class Bottle::AnotherWorker < Bottle::Foreman; end
    Bottle::Foreman.registered_workers['anotherworker'].should be_an_instance_of(Bottle::AnotherWorker)
  end
  
end