require "campaigner/version"
require "campaigner/amqp"
require "campaigner/client"
require "campaigner/foreman"
require "campaigner/listener"
require "campaigner/publisher"
require "campaigner/server"

require 'yaml'
require 'logger'
require 'amqp' # ?

module Campaigner
  AMQP_HOST_ADDR = '127.0.0.1'
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
