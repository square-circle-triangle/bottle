%w(version amqp client foreman listener publisher server).each { |f| require File.join(File.dirname(__FILE__), 'bottle', f) }

require File.join(File.dirname(__FILE__), 'bottle', 'workers', 'info') 

require 'yaml'
require 'logger'
require 'amqp'


module Bottle
  AMQP_DEFAULTS = {
    :host => '127.0.0.1'
  }
  DEFAULT_QUEUE_NAME = "bottle.default"
  DEFAULT_REPLY_QUEUE_FORMAT = "bottle.%s.reply.%s"
end


class Object
  def log
    @@__log__ ||= __create_logger__($stdout)
  end

  private

    def __create_logger__(target)
      @@__log__ = Logger.new(target, Logger::INFO)
    end

end
