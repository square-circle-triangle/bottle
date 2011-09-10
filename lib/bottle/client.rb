module Bottle
  class Client
    include Bottle::AMQP

    attr_accessor :queue_name, :client_reference, :reply_queue_name

    def initialize(client_reference, queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_broker = Bottle::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      @reply_queue_name = DEFAULT_REPLY_QUEUE_FORMAT % [client_reference, object_id]
      #@close_connections = true
    end

    def send_message(msg_type, payload = {}, &block)
      if EM.reactor_running? && !@publisher.nil?
        block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
      else
        with_amqp do
          @publisher = Bottle::Publisher.new(@channel, @channel.default_exchange, @reply_queue_name, true) #direct('blocks.campaigns')        
          block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
        end
      end
    end

    def with_connection
      with_amqp do
        @publisher = Bottle::Publisher.new(@channel, @channel.default_exchange, @reply_queue_name, false)   
        yield self
        @publisher.close_connections = true
        #close_connection - can't close here, need to keep tabs on the reply_queues and close when they are all closed/finished.
      end
    end


    private #####################################


    def dispatch(msg_type, payload = {}, opts={})
      args = [payload.to_yaml, {:routing_key => @queue_name, :type => msg_type}, self]

      if block_given?
        @publisher.publish(*args) do |data|
          log.debug "Passing on the response..."
          yield(data)
          #close_connection if @publisher.close_connections && @publisher.queue_count == 0
        end 
      else
        @publisher.publish(*args)
        # How to know when it is safe to close?  Need a callback to know the msg has gone?
        # close_connection if @close_connections
      end
    end
  end
end
