module Campaigner

  class Handler
    attr_accessor :payload, :metadata

    def initialize(payload, metadata)
    end
    
    def handle_message(metadata,payload)
      puts "Passing on a msg.. type = #{metadata.type}"
      #worker_class = Campaigner.const_get(:"#{metadata.type}Worker")
      worker_class = Campaigner::Foreman.registered_workers[metadata.type]
      cw = worker_class.new(YAML.load(payload))
      puts "Found a worker"
      respond cw.process, metadata
    rescue => e
      puts "it errored..."
      respond({:state => 'error', :message => "Failed to find suitable worker!", :error => e.message}, metadata)
    ensure
      metadata.ack
    end
    
    def respond
      puts "responding with #{payload.inspect} to #{metadata.reply_to}"
      @channel.default_exchange.publish(payload.to_yaml,
                                       :routing_key    => metadata.reply_to,
                                       :correlation_id => metadata.message_id,
                                       :immediate      => true,
                                       :mandatory      => true)
    end
    
    # def response_required?
    #       !@metadata.reply_to.nil?
    #     end