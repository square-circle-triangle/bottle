module Bottle
  module AMQP
    include RetryOnException

    attr_accessor :connection, :channel, :reactor_thread

    def connect
      @amqp_settings.merge!({ :on_tcp_connection_failure => method(:handle_tcp_connection_failure) })
      @connection = ::AMQP.connect(@amqp_settings)
      puts "Connected to AMQP broker at #{@amqp_settings[:host]}"

      @connection.on_tcp_connection_loss(&method(:handle_connection_loss))
      @connection.on_connection_interruption(&method(:handle_connection_loss))

      @connection.on_recovery do |conn|
        puts "Re-established connection.  Resuming normal operations..."
      end

      @channel = ::AMQP::Channel.new(@connection)
      @channel.prefetch(1)
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
      args = @amqp_settings.merge({ :on_tcp_connection_failure => method(:handle_tcp_connection_failure) })
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
        @channel.prefetch(1)
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

    def handle_tcp_connection_failure(conn)
      retry_on_exception(3, 35, RuntimeError.new("THIS IS A RUNTIME ERROR~")) do
        puts "[network error] TCP connection failed." 
        @connection.reconnect(false, 10)
      end
    end

    def handle_connection_loss(conn, settings={})
      retry_on_exception(20, 50, RuntimeError.new("TCP Network Connection Loss Occurred")) do
        puts "[network failure] Trying to reconnect..."
        conn.reconnect(false, 2)
      end
    end

  end
end
