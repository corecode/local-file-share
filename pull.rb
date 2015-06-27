require 'dnssd'

def recv(res)
  filename = res.text_record['file']
  File.open(filename, File::WRONLY | File::CREAT | File::EXCL) do |outf|
    conn = res.connect()
    puts "connected to #{res.target}"
    recvd = 0
    while !conn.eof
      buf = conn.read(1024*1024)
      outf.write(buf)
      recvd += buf.bytesize
    end
    conn.close
    puts "done receiving #{recvd}"
  end
end

DNSSD.browse!('_localfileshare._tcp') do |reply|
  DNSSD.resolve!(reply) do |res|
    recv(res)
    exit 0
  end
end
