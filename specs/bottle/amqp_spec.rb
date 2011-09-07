require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::AMQP do
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }
  
  before :each do
    @amqptest = AmqpTest.new
  end

  describe "connect" do
    it "should establish a connection with the specified AMQP broker" do
      em do
        @amqptest.connect
        @amqptest.connection.should be_an_instance_of(::AMQP::Session)
        default_done
      end
    end

    it "should create a new channel" do
      em do
        @amqptest.connect
        @amqptest.channel.should be_an_instance_of(::AMQP::Channel)
        default_done
      end
    end

  end
  
  describe "connected?" do
    it "should return false if no connection has been created" do
      em do
        @amqptest.connected?.should be_false
        default_done
      end
    end
    
    it "should return true if a connection exists" do
      em do
        @amqptest.connected?.should be_false
        @amqptest.connect
        @amqptest.connected?.should be_true
        default_done
      end
    end
  end

  describe "with_amqp" do
    it "should yield after establishing a connection" do
      em do
        @amqptest.connection.should be_nil
        @amqptest.with_amqp do
          @amqptest.connection.should be_an_instance_of(AMQP::Session)
        end
        default_done
      end
    end


    context "a persistent (server) connection" do
      it "should handle signal traps" do
        em do
          Signal.should_receive(:trap).with('INT')
          @amqptest.with_amqp {}
          default_done
        end
      end
    end

    context "a non-persistent (client) connection" do
      it "should close the connection immediately after yielding" do
        em do
          Signal.should_not_receive(:trap)
          @amqptest.should_receive(:close_connection)
          @amqptest.with_amqp(:persistent => false) {}
          default_done
        end
      end
    end
  end

end