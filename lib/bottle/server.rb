module Bottle
  class Server
    include Bottle::AMQP
    
    attr_accessor :queue_name, :reply_queue_name, :broker
      
    def initialize(queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_settings = {})#, log_target=$stdout)
      @amqp_settings = Bottle::AMQP_DEFAULTS.merge(amqp_settings)
      @queue_name = queue_name
      #setup_logging(log_target)
    end
  
    def poll
      with_amqp do
        Bottle::Listener.new(@channel, @queue_name).start
      end
    end
    
    # def setup_logging(target=$stdout, verbose=false)
    #       Object.send :__create_logger__,  target
    #       log.level = verbose ? Logger::DEBUG : Logger::INFO
    #     end
    
  end
end