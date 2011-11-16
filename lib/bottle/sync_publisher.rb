module Bottle
  class SyncPublisher < Publisher

    def initialize(channel, exchange, reply_queue_name)
      super
      @queue = @channel.queue(Bottle::DEFAULT_QUEUE_NAME)
      @queue.bind(@exchange, :key => Bottle::DEFAULT_QUEUE_NAME)
    end

    def publish(message, options = {}, &block)
      @exchange.publish(message, options.merge(default_options))
      monitor_reply_queue(@reply_queue_name,&block) if block_given?
    end


    ### IMPLEMENTATION

    def monitor_reply_queue(reply_queue_name)
      log.debug "Reply expected.. monitoring..."

      reply_queue.subscribe(:max_message => 1, :timeout => 3) do |msg|
        yield(extract_payload(msg[:payload]))
      end
    end

    private ###########################

    def reply_queue
      rx = @channel.exchange("bottle.sync.reply")
      @reply_queue = @channel.queue(reply_queue_name, :exclusive => true, :auto_delete => true)
      @reply_queue.bind(rx, :key => reply_queue_name)
    end

  end
end
