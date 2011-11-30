module Bottle
  class Client
    include Bottle::AMQP

    attr_accessor :queue_name, :client_reference, :reply_queue_name, :reply_queue_count, :publisher

    def initialize(client_reference, queue_name=Bottle::DEFAULT_QUEUE_NAME, amqp_settings = {})
      @amqp_settings = Bottle::AMQP_DEFAULTS.merge(amqp_settings)
      @queue_name = queue_name
      @reply_queue_count = 0
      @reply_queue_name = DEFAULT_REPLY_QUEUE_FORMAT % [client_reference, object_id]
    end

    def send_message(msg_type, payload, &block)
      if EM.reactor_running?
        if !@publisher.nil?
          block_given? ? dispatch(msg_type, payload, {}, &block) : dispatch(msg_type, payload, {})
        else
          return false
        end
      else
        sync_channel = Bunny.new(@amqp_settings)
        sync_channel.start
        @publisher = Bottle::SyncPublisher.new(sync_channel, sync_channel.exchange("bottle"), @reply_queue_name)
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
      args = [payload.to_yaml, opts]
      if async?
        opts[:routing_key] = @queue_name
        args.push self
      else
        opts[:key] = @queue_name
      end

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

    def waiting_for_replies?
      @publisher.waiting_for_replies?
    rescue
      false
    end

  end
end
