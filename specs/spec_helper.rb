require 'bundler'
Bundler.setup(:default, :test)


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'bottle'

require 'evented-spec'