require 'mqtt'
require 'socket'

server = TCPServer.new 8081

# block unless accept only one client
client = server.accept

# sub
MQTT::Client.connect('localhost', 1883) do |c|
  c.get('chat') do |topic, message|
    puts "#{topic}: #{message}"
    client.puts message
  end
end

client.close
