## Server:
require './lib/bottle'
s = Bottle::Server.new
s.poll


## Client:
require 'bottle'

c = Bottle::Client.new("sct-home")

c.send_message("info", {}) do |data|
  puts "MY DATA LIKE TO SAY: #{data.inspect}"
end

c.send_message("campaign", {:message => "this goes to you"})



### With a sustained connection....

require './lib/bottle'
c = Bottle::Client.new("sct-home")
start = Time.now
c.with_connection do
  10.times do
    c.send_message("info")#{ |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
  end
end
endt = Time.now
res1 = endt.to_i - start.to_i

require './lib/bottle'
c = Bottle::Client.new("sct-home")

1000.times do
  c.send_message("info", {}) { |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
end