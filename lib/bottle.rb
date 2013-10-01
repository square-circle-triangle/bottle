%w(retry_on_exception amqp client foreman listener publisher sync_publisher async_publisher server).each { |f| require File.join(File.dirname(__FILE__), 'bottle', f) }

require File.join(File.dirname(__FILE__), 'bottle', 'workers', 'info') 

require 'yaml'
require 'amqp'
require 'bunny'
YAML::ENGINE.yamler= 'syck'

module Bottle
  AMQP_DEFAULTS = {
    :host => '127.0.0.1'
  }
  DEFAULT_QUEUE_NAME = "bottle.default"
  DEFAULT_REPLY_QUEUE_FORMAT = "bottle.%s.reply.%s"

  class MissingReplyClosureError < StandardError
  end

  class NoReplyReceievedError < StandardError; end
end


