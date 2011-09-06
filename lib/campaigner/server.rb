module Campaigner
  class Server
    include Campaigner::AMQP
    
    attr_accessor :queue_name
  
    def initialize(queue_name="blocks.campaigner", amqp_broker = Campaigner::AMQP_HOST_ADDR)
      @broker = amqp_broker
      @queue_name = queue_name
      #setup_logging
    end
  
    def poll
      with_amqp do
        Campaigner::Listener.new(@channel, @queue_name).start
      end
    end
    
    # def setup_logging(target=$stdout, verbose=false)
    #   Object.send :__create_logger__,  target
    #   log.level = verbose ? Logger::DEBUG : Logger::INFO
    # end
    
  end
end