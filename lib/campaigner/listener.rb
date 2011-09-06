module Campaigner

  class Listener

    def initialize(channel, queue_name = AMQ::Protocol::EMPTY_STRING, consumer = nil)#Dispatcher.new)
      @queue_name = queue_name
      @channel    = channel
      #@channel.on_error(&method(:handle_channel_exception))
      #@consumer   = consumer
    end

    def start
      @queue = @channel.queue(@queue_name)
      ex = @channel.default_exchange
      @queue.bind(ex, :routing_key => @queue_name).subscribe(:ack => true, &method(:handle_message))
    end 

    def handle_message(metadata,payload)
      log.debug "Passing on a msg.. type = #{metadata.type}"
      worker_class = Campaigner::Foreman.registered_workers[metadata.type]
      respond worker_class.process(YAML.load(payload)), metadata
    rescue => e
      log.debug "Error processing message!"
      respond({:state => 'error', :message => "Failed to find suitable worker!", :error => e.message}, metadata)
      false
    ensure
      metadata.ack
    end
    
    def respond(payload, metadata)
      return if metadata.reply_to.nil?
      puts "responding with #{payload.inspect} to #{metadata.reply_to}"
      @channel.default_exchange.publish(payload.to_yaml,
                                       :routing_key    => metadata.reply_to,
                                       :correlation_id => metadata.message_id,
                                       :immediate      => true,
                                       :mandatory      => true)
    end


    # def handle_channel_exception(channel, channel_close)
    #       puts "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    #     end

  end
  
end
