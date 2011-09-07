require "bottle/version"
require "bottle/amqp"
require "bottle/client"
require "bottle/foreman"
require "bottle/listener"
require "bottle/publisher"
require "bottle/server"

require 'yaml'
require 'logger'
require 'amqp' # ?

module Bottle
  AMQP_HOST_ADDR = '127.0.0.1'
  DEFAULT_QUEUE_NAME = "blocks.bottle"
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
