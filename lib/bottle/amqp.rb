module Bottle
  module AMQP
    attr_accessor :connection, :channel, :reactor_thread

    def connect
      @connection = ::AMQP.connect(@amqp_settings)
      puts "Connected to AMQP broker at #{@amqp_settings[:host]}"
      @channel = ::AMQP::Channel.new(@connection)
    end

    def connected?
      puts "connected? " + @connection.inspect
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

    def threaded_connect(_iterator, &block)
      Thread.abort_on_exception = true
      args = @amqp_settings.merge({ :on_tcp_connection_failure => method(:on_tcp_connection_failure) })
      @reactor_thread = Thread.new { 
        puts "Connecting to AMQP broker at #{@amqp_settings[:host]}"
        ::EM.run { ::AMQP.start(args) } 
      }
      sleep(0.5) 

      await_completion = Proc.new do
        if waiting_for_replies?
          EM.next_tick(await_completion) 
        else
          puts "DONE.. we can kill the reactor thread now..."
          close_connection
          @reactor_thread.kill
        end
      end

      handle_item = Proc.new do
        if _iter = _iterator.shift 
          block.call(_iter)
          EM.next_tick(handle_item) 
        else
          puts "Finished processing the list.  Start checking that reply queues are finished"
          EM.next_tick(await_completion)
        end
      end

      EventMachine.next_tick do
        ::AMQP.channel ||= ::AMQP::Channel.new(::AMQP.connection)
        @channel = ::AMQP.channel
        handle_item.call()
      end
      
      @reactor_thread.join
    end

    def close_connection
      return unless connected?
      puts "CLOSING connection..."
      @connection.close { EventMachine.stop if EM.reactor_running? } 
    end

    private ########################

    def trap_signal
      puts "Signal trap caught.  Stopping now..."
      close_connection
    end

    def on_tcp_connection_failure()
      puts "TCP CONNECTION FAILED!!!!!!!"
    end

  end
end
