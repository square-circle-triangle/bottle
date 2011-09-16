module Bottle
  class Client
    include Bottle::AMQP

    attr_accessor :queue_name, :client_reference, :reply_queue_name

    def initialize(client_reference, queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_settings = {})
      @amqp_settings = Bottle::AMQP_DEFAULTS.merge(amqp_settings)
      @queue_name = queue_name
      @reply_queue_name = DEFAULT_REPLY_QUEUE_FORMAT % [client_reference, object_id]
    end

    def send_message(msg_type, payload, &block)
      if EM.reactor_running? && !@publisher.nil?
        block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
      else
        @sync_channel = Bunny.new#(:logging => true)
        @sync_channel.start
        @publisher = Bottle::Publisher.new(@sync_channel, @sync_channel.exchange("bottle"), @reply_queue_name)       
        block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
      end
      true
    end
    
    def each_with_amqp(iter)
      @publisher = nil
      threaded_connect(iter) do |i|
        @publisher ||= Bottle::AsyncPublisher.new(@channel, @channel.direct("bottle"), @reply_queue_name)  
        yield(i)
      end
    end


    private #####################################


    def dispatch(msg_type, payload = {}, opts={})
      opts = opts.merge(:type => msg_type)
      opts.merge! (async? ? { :routing_key => @queue_name } : { :key => @queue_name } )
      args = [payload.to_yaml, opts]
      if block_given?
        @publisher.publish(*args) do |data|
          yield(data)
        end 
      else
        @publisher.publish(*args)
      end
    end
    
    def async?
      @publisher.is_a?(Bottle::AsyncPublisher)
    end
    
  end
end
