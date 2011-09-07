module Bottle
  class Client
    include Bottle::AMQP
    
    attr_accessor :queue_name, :client_reference, :reply_queue_name
    
    def initialize(client_reference, queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_broker = Bottle::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      @reply_queue_name = DEFAULT_REPLY_QUEUE_FORMAT % [client_reference, object_id]
    end

    def dispatch(msg_type, payload = {})
      with_amqp do
        publisher = Bottle::Publisher.new(@channel, @channel.default_exchange, @reply_queue_name) #direct('blocks.campaigns')        
        
        args = [payload.to_yaml, :routing_key => @queue_name, :type => msg_type]

        if block_given?
          publisher.publish(*args) do |data|
            log.debug "Passing on the response..."
            yield(data)
            close_connection
          end 
        else
          publisher.publish(*args)
          # How to know when it is safe to close?  Need a callback to know the msg has gone?
          # close_connection
        end
      end
    end
  end
end
