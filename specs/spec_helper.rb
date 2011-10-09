require 'bundler'
Bundler.setup(:default, :test)


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'bottle'

require 'evented-spec'

class AmqpTest
  include Bottle::AMQP
  attr_accessor :broker
  
  def initialize(settings={})
    @amqp_settings = Bottle::AMQP_DEFAULTS.merge(settings)
  end
end

def default_done
  done(0.25)
end