module Bottle
  class Client
    include Bottle::AMQP
    
    def initialize(client_reference, queue_name="blocks.bottle", amqp_broker = Bottle::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      @reply_queue_name = "blocks.bottle.#{client_reference}.reply.#{self.object_id}"
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
    
    ##### XXXXXXXXXXXX ###########
    
    def with_connection
      with_amqp do
        @publisher = Bottle::Publisher.new(@channel, @channel.default_exchange, @reply_queue_name)   
        @close_connections = false
        yield self
        @close_connections = true
        close_connection
      end
    end
    
    def dispatch(msg_type, payload = {}, opts={})
        args = [payload.to_yaml, :routing_key => @queue_name, :type => msg_type]

        if block_given?
          @publisher.publish(*args) do |data|
            log.debug "Passing on the response..."
            yield(data)
            close_connection if @close_connections
          end 
        else
          @publisher.publish(*args)
          # How to know when it is safe to close?  Need a callback to know the msg has gone?
          # close_connection if @close_connections
        end
      end
    end
    
  end
end
