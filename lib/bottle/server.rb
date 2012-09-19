module Bottle
  class Server
    include Bottle::AMQP
    
    attr_accessor :queue_name, :reply_queue_name, :broker
      
    def initialize(queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_settings = {}, options = {})
      @options = options
      @amqp_settings = Bottle::AMQP_DEFAULTS.merge(amqp_settings)
      @queue_name = queue_name
    end
  
    def poll
      with_amqp do
        Bottle::Listener.new(@channel, @queue_name, @options).start
      end
    end
  end
end
