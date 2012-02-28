module Bottle
  class Publisher
    attr_accessor :exchange

    def initialize(channel, exchange, reply_queue_name)
      @channel  = channel
      @exchange = exchange
      @reply_queue_name = reply_queue_name
    end

    def publish(message, options = {}, &block)
      raise("Abstract method called. Please use a concrete subclass")
    end

    def default_options
      { :message_id => generate_message_id, :reply_to => @reply_queue_name } 
    end

    protected ##############################

    def generate_message_id
       Kernel.rand(36**16).to_s(36)
    end

    def extract_payload(pl)
       YAML.load(pl)
    end
    
    def handle_channel_exception(channel, channel_close)
      puts "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end 
  end
end
