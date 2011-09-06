## Server:
require 'campaigner'
s = Campaigner::Server.new
s.poll


## Client:
require 'campaigner'

c = Campaigner::Client.new("sct-home")

c.dispatch("info", {}) do |data|
  puts "MY DATA LIKE TO SAY: #{data.inspect}"
end

c.dispatch("campaign", {:message => "this goes to you"})