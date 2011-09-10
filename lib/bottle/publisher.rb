module Bottle
  class Publisher
    attr_accessor :close_connections, :queue_count

    def initialize(channel, exchange, reply_queue_name, close_connections)
      @channel  = channel
      @exchange = exchange
      @reply_queue_name = reply_queue_name
      @queue_count = 0
      @close_connections = close_connections

      @ack_count = 0
      @nack_count = 0

      @channel.confirm_select
      handle_confirms
      
    end

    def publish(message, options = {}, client, &block)
      @client = client
      default_opts = { :message_id => Kernel.rand(10101010).to_s, :immediate => true }
      
      reply_queue = @reply_queue_name + default_opts[:message_id]
      monitor_reply_queue(reply_queue,&block) if block_given?
      
      ::AMQP::Channel.queue(reply_queue).status { |number_of_messages, number_of_active_consumers|
        puts "messages: #{number_of_messages}. consumers: #{number_of_active_consumers}"
      }
      
      default_opts[:reply_to] = reply_queue #if block_given? ### This is always required!? ---> IT must be because ack => true!
      oops = options.merge(default_opts)
      log.debug "OPTION:> " + oops.inspect
      @exchange.publish(message, oops)
    end


    ### IMPLEMENTATION

    def monitor_reply_queue(reply_queue)
      @queue_count += 1
      puts @queue_count.inspect
      log.debug "Reply expected.. monitoring..."
      
      ::AMQP::Channel.queue(reply_queue).status { |number_of_messages, number_of_active_consumers|
        puts "messages: #{number_of_messages}. consumers: #{number_of_active_consumers}"
        #if number_of_messages == 0 && number_of_active_consumers == 0
      }
      
      @channel.queue(reply_queue, :exclusive => true, :auto_delete => true).subscribe do |metadata, payload|
        data = YAML.load(payload)
        @queue_count -= 1
        puts @queue_count.inspect + " : " + @close_connections.inspect
        yield(data)  
        #@client.close_connection      
      end
    end
    
    def handle_confirms
      @channel.on_ack do |basic_ack|
        puts "ACKING! -> #{@ack_count}"
        @ack_count += 1 
      end
      
      @channel.on_nack do |basic_ack|
        puts "N______ACKING! -> #{@nack_count}"
        @nack_count += 1
      end
    end

    def handle_channel_exception(channel, channel_close)
      log.warn "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end 
  end
end