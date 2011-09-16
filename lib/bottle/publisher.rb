## synchronous publisher...

module Bottle
  class Publisher
    attr_accessor :close_connections, :queue_count

    def initialize(channel, exchange, reply_queue_name)
      @channel  = channel
      @exchange = exchange
      @reply_queue_name = reply_queue_name
      @queue_count = 0

      @queue = @channel.queue(Bottle::DEFAULT_QUEUE_NAME)
      @queue.bind(@exchange, :key => Bottle::DEFAULT_QUEUE_NAME)
    end

    def publish(message, options = {}, &block)
      default_opts = { :message_id => Kernel.rand(10101010).to_s }
      
      reply_queue = @reply_queue_name #+ "." + default_opts[:message_id]
      
      default_opts[:reply_to] = reply_queue 
      oops = options.merge(default_opts)
      @exchange.publish(message, oops)
      monitor_reply_queue(reply_queue,&block) if block_given?
    end


    ### IMPLEMENTATION

    def monitor_reply_queue(reply_queue_name)
      rx = @channel.exchange("bottle.sync.reply")
      @reply_queue = @channel.queue(reply_queue_name, :exclusive => true, :auto_delete => true)
      @reply_queue.bind(rx, :key => reply_queue_name)
      log.debug "Reply expected.. monitoring..."
      
      @reply_queue.subscribe(:max_message => 1, :timeout => 3) do |msg|
        data = YAML.load(msg[:payload])
        yield(data)  
      end
    end
    
    def handle_channel_exception(channel, channel_close)
      log.warn "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end 
  end
end