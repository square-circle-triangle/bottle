require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Bottle::AMQP do
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }
  
  before :each do
    @amqptest = AmqpTest.new
    @done_timeout = 0.25
  end

  describe "connect" do
    it "should establish a connection with the specified AMQP broker" do
      em do
        @amqptest.connect
        @amqptest.connection.should be_an_instance_of(::AMQP::Session)
        done(@done_timeout)
      end
    end

    it "should create a new channel" do
      em do
        @amqptest.connect
        @amqptest.channel.should be_an_instance_of(::AMQP::Channel)
        done(@done_timeout)
      end
    end

  end
  
  describe "connected?" do
    it "should return false if no connection has been created" do
      em do
        @amqptest.connected?.should be_false
        done(@done_timeout)
      end
    end
    
    it "should return true if a connection exists" do
      em do
        @amqptest.connected?.should be_false
        @amqptest.connect
        @amqptest.connected?.should be_true
        done(@done_timeout)
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
        done(@done_timeout)
      end
    end


    context "a persistent (server) connection" do
      it "should handle signal traps" do
        em do
          Signal.should_receive(:trap).with('INT')
          @amqptest.with_amqp {}
          done(@done_timeout)
        end
      end
    end

    context "a non-persistent (client) connection" do
      it "should close the connection immediately after yielding" do
        em do
          Signal.should_not_receive(:trap)
          @amqptest.should_receive(:close_connection)
          @amqptest.with_amqp(:persistent => false) {}
          done(@done_timeout)
        end
      end
    end
  end

end