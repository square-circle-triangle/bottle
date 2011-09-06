module Campaigner
  module AMQP
    attr_accessor :connection, :channel
    
    def connect
      @connection = ::AMQP.connect(:host => @broker)
      log.info "Connected to AMQP broker at #{@broker}"
      @channel = ::AMQP::Channel.new(@connection)
    end

    def with_amqp(args={:persist => true })
      EventMachine.run do
        connect
        yield

        if args[:persist]
          Signal.trap("INT") do
            log.info "Signal trap caught.  Stopping now..."
            close_connection
          end
        else
          close_connection
        end
      end
    end

    private ########################

    def close_connection
      @connection.close { EventMachine.stop } 
    end

  end
end