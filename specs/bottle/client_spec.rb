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


  describe 'send_message' do

    before do
      @pub = mock('publisher')
      @pub.stub!(:publish)
      #    @client.publisher = @pub
    end

    context "when no reactor is running" do

      before do
        Bottle::SyncPublisher.should_receive(:new).and_return(@pub)
      end

      it "should send the message using sync_publisher if a msg_mode of :sync is passed" do
        @client.send_message('info', {}, :sync)
      end

      it "should send the message using sync_publisher EVEN if a msg_mode of :async is passed" do
        @client.send_message('info', {}, :async)
      end
      it "should send the message using async_publisher if no msg_mode is passed" do
        @client.send_message('info', {})
      end
    end

    context "when an event machine is running" do
      include EventedSpec::SpecHelper

      em_before { AMQP.cleanup_state }
      em_after  { AMQP.cleanup_state }

      before do
        @amqptest = AmqpTest.new
      end

      it "should return false if there is no publisher" do
        em do
          @client.send_message('info', {}).should be_false
          default_done
        end
      end

      it "should dispatch the message" do
        em do
          pub = mock('publisher')
          @client.publisher = pub
          pub.should_receive(:publish)#.with(
          @client.send_message('info', {})
          default_done
        end
      end

      it "should send the message using async_publisher if a msg_mode of :async is passed" do
        em do
          Bottle::SyncPublisher.should_not_receive(:new).and_return(@pub)
          @client.send_message('info', {}, :async)
          default_done
        end
      end

      it "should send the message using sync_publisher if a msg_mode of :sync is passed" do
        em do
          Bottle::SyncPublisher.should_receive(:new).and_return(@pub)
          @client.send_message('info', {}, :sync)
          default_done
        end

      end

      it "should send the message using async_publisher if no msg_mode is passed" do
        em do
          Bottle::SyncPublisher.should_not_receive(:new).and_return(@pub)
          @client.send_message('info', {})
          default_done
        end
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
end
