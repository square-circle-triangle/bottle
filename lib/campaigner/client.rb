module Campaigner
  class Client
    include Campaigner::AMQP
    
    def initialize(client_reference, queue_name="blocks.campaigner", amqp_broker = Campaigner::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      @reply_queue_name = "blocks.campaigner.#{client_reference}.reply.#{self.object_id}"
    end

    def dispatch(msg_type, payload = {})
      with_amqp do
        publisher = Campaigner::Publisher.new(@channel, @channel.default_exchange, @reply_queue_name) #direct('blocks.campaigns')        
        
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
