require 'mqtt'
require 'socket'
require './db/redis'

chat_server = TCPServer.open(8080)

mqtt_client = MQTT::Client.connect('localhost', 1883)

mqtt_sub_server = TCPSocket.open('localhost', 8081)

socks = []
socks << chat_server
socks << mqtt_sub_server

while true
  ready_sock = select(socks)
  next if ready_sock == nil
  for s in ready_sock[0]
    if s == chat_server
      socks.push(s.accept)
      puts "#{s} is accepted"
    elsif s == mqtt_sub_server
      puts 'msg from mqtt_sub_server'
      msg = s.gets.chomp
      puts msg
      mqtt_sub_server_msg_reg = /(.*)\ssend\sto\s(.*):\s(.*)/
      if mqtt_sub_server_msg_reg =~ msg
        from_name = $1
        to_name = $2
        msg_str = $3
        # client_info = get_client_info(to_name)
        # if client_info['host'] == '127.0.0.1' && client_info['port'] == 3001
        to_socketfd = get_sockfd(to_name).to_i
        to_socket = TCPSocket.for_fd(to_socketfd) unless to_socketfd.nil?
        to_socket.puts("#{from_name} say #{msg} to you from server s:3001") unless to_socket.nil?
        # end
      end
    else
      if s.eof?
        puts "#{s} is gone"
        pop_name = get_name(s.to_i, '127.0.0.1', 3000)
        $redis.del(pop_name) if pop_name
        s.close
        socks.delete(s)
      else
        str = s.gets.chomp
        login_reg = /login:\s(.*)/
        send_msg_reg = /send\sto\s(.*):\s(.*)/
        if login_reg =~ str
          user_name = $1
          value = {sockfd: s.to_i, host: '127.0.0.1', port: 3000}.to_json
          $redis.set user_name, value
        elsif send_msg_reg =~ str
          from_name = get_name(s.to_i, '127.0.0.1', 3000)
          to_name = $1
          msg = $2
          p from_name, to_name, msg
          mqtt_client.publish('chat', "#{from_name} #{str}")
          # client_info = get_client_info(to_name)
          # if client_info['host'] == '127.0.0.1' && client_info['port'] == 3000
          #   to_socketfd = get_sockfd(to_name).to_i
          #   to_socket = TCPSocket.for_fd(to_socketfd) unless to_socketfd.nil?
          #   to_socket.puts("#{from_name} say #{msg} to you from server s:3000") unless to_socket.nil?
          # else
          #   puts 'send to mqtt_sub_server'
          #   mqtt_sub_server.puts "#{from_name} #{str}"
          #   s.flush
          # end
        end
      end
    end
  end
end
