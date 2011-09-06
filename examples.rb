## Server:
require 'bottle'
s = Bottle::Server.new
s.poll


## Client:
require 'bottle'

c = Bottle::Client.new("sct-home")

c.dispatch("info", {}) do |data|
  puts "MY DATA LIKE TO SAY: #{data.inspect}"
end

c.dispatch("campaign", {:message => "this goes to you"})