module Bottle
  class Publisher

    def initialize(channel, exchange, reply_queue_name)
      @channel  = channel
      @exchange = exchange
      @reply_queue_name = reply_queue_name
    end

    def publish(message, options = {}, &block)
      monitor_reply_queue(&block) if block_given?
      default_opts = { :message_id => Kernel.rand(10101010).to_s, :immediate => true }
      default_opts[:reply_to] = @reply_queue_name #if block_given? ### This is always required!? ---> IT must be because ack => true!
      oops = options.merge(default_opts)
      log.debug "OPTION:> " + oops.inspect
      @exchange.publish(message, oops)
    end


    ### IMPLEMENTATION

    def monitor_reply_queue
      log.debug "Reply expected.. monitoring..."
      @channel.queue(@reply_queue_name, :exclusive => true, :auto_delete => true).subscribe do |metadata, payload|
        data = YAML.load(payload)
        yield(data)
      end
    end

    def handle_channel_exception(channel, channel_close)
      log.warn "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end 
  end
end