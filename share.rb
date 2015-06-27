require 'dnssd'
require 'sendfile'

filename = ARGV[0]
announcename = File.basename(filename)
file = File.new(filename, 'r')

begin
  port = rand(5535) + 60000
  servsock = TCPServer.new(port)
rescue Errno::EADDRINUSE
  retry
end

puts "waiting for connection"

# info = DNSSD::TextRecord.new 'file' => announcename
# p info
# p info.encode
info = "file=#{announcename}"
info = [info.bytesize, info].pack('Ca*')
def info.encode
  self
end
DNSSD.announce(servsock, "local file share", "localfileshare", info)

connsock = servsock.accept
clientname = connsock.remote_address.getnameinfo.first
puts "connection from #{clientname}"
sent = connsock.sendfile(file, 0)
connsock.shutdown
puts "transfer done."

servsock.close
