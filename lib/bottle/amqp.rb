module Bottle
  module AMQP
    attr_accessor :connection, :channel, :reactor_thread
    
    def connect(threaded=false)
      #if threaded
      #  threaded_connect(:host => @broker)
      #else
      puts "CONNECTING>>>."
        @connection = ::AMQP.connect(:host => @broker)
        log.info "Connected to AMQP broker at #{@broker}"
        @channel = ::AMQP::Channel.new(@connection)
      #end
    end
    
    def connected?
      @connection && @connection.is_a?(::AMQP::Session)
    end

    def with_amqp(args={:persist => true })
      EventMachine.run do
        connect
        yield

        if args[:persist]
          Signal.trap("INT") { trap_signal }
        else
          close_connection
        end
      end
    end
    
    def threaded_connect
      Thread.abort_on_exception = true
      args = {:host => @broker, :on_tcp_connection_failure => method(:on_tcp_connection_failure) }
      @reactor_thread = Thread.new { 
        puts "Connecting to AMQP broker at #{@broker}"
        # EventMachine.run do
        #   puts "in the reactor..."
        #   connect
        #   puts "Connected to AMQP broker at #{@broker}"
        #   puts "REACTOR IS RUNNING? "  + EventMachine.reactor_running?.inspect
        # end     
        ::EM.run { ::AMQP.start } 
      }
      sleep(0.5)
      
      #t2 = Thread.new { 
      puts EventMachine.reactor_running?.inspect
      EventMachine.next_tick do
         puts "next tick..."
         ::AMQP.channel ||= ::AMQP::Channel.new(::AMQP.connection)
         @channel = ::AMQP.channel
         puts "YIELDING>>>>>"
         yield
      end
      @reactor_thread.join
     #}
       #AMQP.channel.queue("amqpgem.examples.rails23.warmup", :durable => true)
    end
    
    def close_connection
      return unless @connection.connected?
      log.info "Closing connection..."
      @connection.close { EventMachine.stop if EM.reactor_running? } 
    end

    private ########################

    def trap_signal
      log.info "Signal trap caught.  Stopping now..."
      close_connection
    end
    
    def on_tcp_connection_failure()
      puts "TCP CONNECTION FAILED!!!!!!!"
    end

  end
end