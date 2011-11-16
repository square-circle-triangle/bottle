module Bottle
  class AsyncPublisher < Publisher

    def initialize(channel, exchange, reply_queue_name)
      super
      @reply_blocks = {}
    end

    def publish(message, options, &block)
      log.debug "Publishing over an Asynchronous publisher..."
      default_opts = default_options.merge({ :mandatory => true })
      monitor_reply_queue(@reply_queue_name,default_opts[:message_id], &block) if block_given?
      @exchange.publish(message, options.merge(default_opts))
    end


    ### IMPLEMENTATION

    def monitor_reply_queue(reply_queue_name, msg_id, &block)
      @reply_blocks[msg_id] = block

      log.debug "QUEUE COUNT: #{@reply_blocks.size}"
      return if !!@reply_queue

      log.debug "Reply expected... setting up the reply queue: #{reply_queue_name}"
      @reply_queue = @channel.queue(reply_queue_name, :exclusive => true, :auto_delete => true)
      @reply_queue.subscribe do |metadata, payload|
        if reply_block = get_reply_block(metadata.correlation_id)
          reply_block.call(extract_payload(payload))
        else
          raise MissingReplyClosureError
        end
      end
    end

    def get_reply_block(id)
      @reply_blocks.delete(id)
    end

    def waiting_for_replies?
      @reply_blocks.size > 0
    end

  end
end
