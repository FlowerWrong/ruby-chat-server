require 'socket'

server = TCPSocket.open('localhost', 8080)

def close(reason = nil)
  puts reason
  server.shutdown
  Process.exit!(true)
end

trap 'INT' do
  close('ctrl-c')
end

req = Thread.new do
  loop {
    msg = $stdin.gets.chomp
    close('quiting now...') if msg == 'quit'
    server.puts( msg )
  }
end

res = Thread.new do
  loop {
    close('server is going done') if server.eof?
    msg = server.gets.chomp
    puts "#{msg}"
  }
end

req.join
res.join
