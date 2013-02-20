module Bottle
  class SyncPublisher < Publisher

    def initialize(channel, exchange, reply_queue_name)
      super
      @queue = @channel.queue(Bottle::DEFAULT_QUEUE_NAME)
      @queue.bind(@exchange, :key => Bottle::DEFAULT_QUEUE_NAME)
      @reply_received = false
    end

    def publish(message, options = {}, &block)
      @exchange.publish(message, default_options.merge(options))
      monitor_reply_queue(options, &block) if block_given?
    end

    ### IMPLEMENTATION

    def monitor_reply_queue(options ={})
      options = { max_message: 1, timeout: 300 }.merge(options)
      options = options.keep_if{|key, value| [:max_message, :timeout].include?(key)}

      puts "Reply expected.. monitoring...#{options.inspect}"
      reply_queue.subscribe(options) do |msg|
        @reply_received = true
        yield(extract_payload(msg[:payload]))
      end

      raise Bottle::NoReplyReceievedError unless reply_received?

      puts "Received response from reply queue"
    end

    private ###########################

    def reply_queue
      rx = @channel.exchange("bottle.sync.reply")
      @reply_queue = @channel.queue(@reply_queue_name, :exclusive => true, :auto_delete => true)
      @reply_queue.bind(rx, :key => @reply_queue_name)
      @reply_queue
    end

    def reply_received?
      !!@reply_received
    end

  end
end
