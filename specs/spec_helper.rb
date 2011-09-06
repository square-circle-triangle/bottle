require 'bundler'
Bundler.setup(:default, :test)


$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'campaigner'

require 'evented-spec'