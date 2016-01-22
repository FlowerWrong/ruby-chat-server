require 'mqtt'
require 'socket'

require '../models/settings'

server = TCPServer.new Settings.mqtt.mqtt_sub_port

# block unless accept only one client
client = server.accept

# sub
MQTT::Client.connect(Settings.mqtt.host, Settings.mqtt.port) do |c|
  c.get('chat') do |topic, message|
    puts "#{topic}: #{message}"
    client.puts message
  end
end

client.close
