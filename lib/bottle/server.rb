module Bottle
  class Server
    include Bottle::AMQP
    
    attr_accessor :queue_name
  
    def initialize(queue_name="blocks.bottle", amqp_broker = Bottle::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      #setup_logging
    end
  
    def poll
      with_amqp do
        Bottle::Listener.new(@channel, @queue_name).start
      end
    end
    
    # def setup_logging(target=$stdout, verbose=false)
    #   Object.send :__create_logger__,  target
    #   log.level = verbose ? Logger::DEBUG : Logger::INFO
    # end
    
  end
end