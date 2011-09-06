require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Campaigner::AMQP do
  
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }
  

  class AmqpTest
    include Campaigner::AMQP
    attr_accessor :broker
    
    def initialize(amqp_broker = Campaigner::AMQP_HOST_ADDR)
      @broker = amqp_broker
    end
  end


  before do
    @amqptest = AmqpTest.new
  end

  describe "connect" do
    it "should establish a connection with the specified AMQP broker" do
      em do
        @amqptest.connect
        @amqptest.connection.should be_an_instance_of(::AMQP::Session)
      end
    end

    it "should create a new channel" do
      em do
        @amqptest.connect
        @amqptest.channel.should be_an_instance_of(::AMQP::Channel)
      end
    end

  end

  describe "with_amqp" do
    it "should yield after establishing a connection"


    context "a persistent (server) connection" do
      it "should handle signal traps"
    end

    context "a non-persistent (client) connection" do
      it "should close the connection immediately after yielding"
    end
  end

end