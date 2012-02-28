module Bottle

  class Listener
    attr_accessor :channel, :queue, :exchange, :queue_name
    
    def initialize(channel, queue_name = AMQ::Protocol::EMPTY_STRING, consumer = nil)#Dispatcher.new)
      @queue_name = queue_name
      @channel    = channel
      @channel.on_error(&method(:handle_channel_exception))
      #@consumer   = consumer
      @queue = @channel.queue(@queue_name)
      @exchange = @channel.direct("bottle")
    end

    def start
      puts "binding to #{@queue_name}, on exchange #{@exchange.name}"
      @queue.bind(@exchange, :routing_key => @queue_name).subscribe(:ack => true, &method(:handle_message))
    end 

    def handle_message(metadata,payload)
      worker_class = Bottle::Foreman.registered_workers[metadata.type]
      if worker_class.nil?
        respond({:state => 'error', :message => "Failed to find suitable worker for #{metadata.type}" }, metadata)
        false
      else
        payload = YAML.load(payload)
        #puts "GOT PAYLOAD: #{payload.inspect}"
        respond worker_class.process(payload), metadata
        true
      end
    rescue => e
      puts "Error processing message! #{e.message}"
      respond({:state => 'error', :message => e.message }, metadata)
      false
    ensure
      metadata.ack
    end
    
    def respond(payload, metadata)
      return if metadata.reply_to.nil?
      puts "Responding with #{payload.inspect} to: #{metadata.reply_to} : #{metadata.message_id}"
      @channel.default_exchange.publish(payload.to_yaml,
                       :routing_key    => metadata.reply_to,
                       :correlation_id => metadata.message_id,
                       # :immediate      => true,
                       :mandatory      => true)
    end


    def handle_channel_exception(channel, channel_close)
      puts "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end

  end
  
end
