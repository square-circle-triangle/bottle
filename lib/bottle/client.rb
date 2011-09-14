module Bottle
  class Client
    include Bottle::AMQP

    attr_accessor :queue_name, :client_reference, :reply_queue_name

    def initialize(client_reference, queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_settings = {})
      @amqp_settings = Bottle::AMQP_DEFAULTS.merge(amqp_settings)
      @queue_name = queue_name
      @reply_queue_name = DEFAULT_REPLY_QUEUE_FORMAT % [client_reference, object_id]
      #@close_connections = true
      @count = 0
    end

    def send_message(msg_type, payload, &block)
      if EM.reactor_running? && !@publisher.nil?
        #puts "HERE::" + payload.inspect
        block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
      else
        with_amqp do
          @publisher = Bottle::Publisher.new(@channel, @channel.direct("bottle"), @reply_queue_name, true) #direct('blocks.campaigns')        
          block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
        end
      end
      true
    end

    # def with_connection
    #   with_amqp do
    #     @publisher = Bottle::Publisher.new(@channel, @channel.direct("bottle"), @reply_queue_name, false)   
    #     yield self
    #     @publisher.close_connections = true
    #   end
    # end
    
    def each_with_amqp(iter)
      threaded_connect(iter) do |i|
        @publisher ||= Bottle::Publisher.new(@channel, @channel.direct("bottle"), @reply_queue_name, false)   
        yield(i)
        @publisher.close_connections = true
      end
    end


    private #####################################


    def dispatch(msg_type, payload = {}, opts={})
      args = [payload.to_yaml, {:routing_key => @queue_name, :type => msg_type}, self]
      if block_given?
        @count+=1
        @publisher.publish(*args) do |data|
          yield(data)
        end 
      else
        @publisher.publish(*args)
        # How to know when it is safe to close?  Need a callback to know the msg has gone?
        # close_connection if @close_connections
      end
    end
  end
end
