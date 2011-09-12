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
EM.defer do
10.times do |i|
  c.send_message("info"){ |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
end
end


require './lib/bottle'
c = Bottle::Client.new("sct-home")
c.with_threaded_connection do
  items = (0..1000).to_a 
  handle_item = Proc.new do
    puts "off we go.."
    if i = items.shift 
      c.send_message("info"){ |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
      EM.next_tick(handle_item) 
    end 
  end
  handle_item.call()
end


# EventMachine.next_tick do
#    puts "next tick..."
#    @channel = AMQP.channel ||= AMQP::Channel.new(AMQP.connection)
#    puts "YIELDING>>>>>"




endt = Time.now
res1 = endt.to_i - start.to_i

require './lib/bottle'
c = Bottle::Client.new("sct-home")

1000.times do
  c.send_message("info")#, {}) { |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
end