require './lib/bottle'
c = Bottle::Client.new("sct-home")

recipients = (1..100000).to_a

c.each_with_amqp(recipients) do |recipient|
    c.send_message("info", {:recipient => recipient}){ |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
end
