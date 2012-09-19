require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::Server do

  before do
    @server = described_class.new
  end

  describe "new" do
    it "should default the queue name to DEFAULT_QUEUE_NAME" do
      @server.queue_name.should == Bottle::DEFAULT_QUEUE_NAME
    end
  
    # Not a useful test.
    #it "should default the amqp_broker address to AMQP_DEFAULTS[:host]" do
    #  @server.amqp_settings[:host].should == Bottle::AMQP_DEFAULTS[:host]
    #end

  end

  describe "poll" do
    include EventedSpec::SpecHelper
    
    em_before { AMQP.cleanup_state }
    em_after  { AMQP.cleanup_state }

    it "should setup a new amqp connection" do
      @server.should_receive(:with_amqp)
      em do 
        @server.poll
        default_done
      end
    end

    it "should start a new listener" do
      listener = mock('listener')      
      em do
        Bottle::Listener.should_receive(:new).and_return(listener)
        listener.should_receive(:start)
        @server.poll
        default_done
      end
    end

    it "should start a listener with the passed options" do
      @server = described_class.new(Bottle::DEFAULT_QUEUE_NAME, {}, {ack: false})
      @channel = mock('channel')
      ::AMQP::Channel.stub(:new).and_return(@channel)

      listener = mock('listener')
      em do
        Bottle::Listener.should_receive(:new).with(@channel, Bottle::DEFAULT_QUEUE_NAME, {ack: false}).and_return(listener)
        listener.should_receive(:start)
        @server.poll
        default_done
      end
    end
  end

end
