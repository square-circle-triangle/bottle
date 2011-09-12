require './lib/bottle'
c = Bottle::Client.new("sct-home")
c.with_threaded_connection do
  puts "OK...."
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
