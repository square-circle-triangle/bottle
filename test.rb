require './lib/bottle'
c = Bottle::Client.new("sct-home")

recipients = (1..100000).to_a

c.with_threaded_connection(recipients) do |recipient|
    c.send_message("info", {:recipient => recipient}){ |data| puts "MY DATA LIKE TO SAY: #{data.inspect}" }
end
