require 'bundler'
Bundler.setup(:default, :test)


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'bottle'

require 'evented-spec'

class AmqpTest
  include Bottle::AMQP
  attr_accessor :broker
  
  def initialize(amqp_broker = Bottle::AMQP_HOST_ADDR)
    @broker = amqp_broker
  end
end

def default_done
  done(0.25)
end