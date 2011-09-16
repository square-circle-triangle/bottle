module Bottle
  class AsyncPublisher

    def initialize(channel, exchange, reply_queue_name)
      @channel  = channel
      @exchange = exchange
      @reply_queue_name = reply_queue_name
      # @ack_count = 0
      # @nack_count = 0
      # @channel.confirm_select
      # handle_confirms
    end

    def publish(message, options, client, &block)
      @client = client
      log.debug "Publishing over an Asynchronous publisher..."
      
      default_opts = { :message_id => Kernel.rand(10101010).to_s, :immediate => true }
      
      reply_queue = @reply_queue_name + default_opts[:message_id]
      
      monitor_reply_queue(reply_queue,&block) if block_given?
      default_opts[:reply_to] = reply_queue
      oops = options.merge(default_opts)
      @exchange.publish(message, oops)
    end


    ### IMPLEMENTATION

    def monitor_reply_queue(reply_queue_name)
      @client.reply_queue_count += 1
      #return if !!@reply_queue
      
      log.debug "Reply expected..setting up the reply queue: #{reply_queue_name}"
      reply_queue = @channel.queue(reply_queue_name, :exclusive => true, :auto_delete => true)
      reply_queue.subscribe do |metadata, payload|
        data = YAML.load(payload)
        yield(data)
        @client.reply_queue_count -= 1
      end
    end
    
    # def handle_confirms
    #       @channel.on_ack do |basic_ack|
    #         @ack_count += 1 
    #       end
    #       
    #       @channel.on_nack do |basic_ack|
    #         @nack_count += 1
    #       end
    #     end
    
    def handle_channel_exception(channel, channel_close)
      log.warn "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end 
  end
end