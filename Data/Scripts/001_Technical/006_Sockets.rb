module Win32
  def copymem(len)
    buf = "\0" * len
    Win32API.new("kernel32", "RtlMoveMemory", "ppl", "").call(buf, self, len)
    buf
  end
end



# Extends the numeric class.
class Numeric
  include Win32
end



# Extends the string class.
class String
  include Win32
end



module Winsock
  DLL = "ws2_32"
  #-----------------------------------------------------------------------------
  # * Accept Connection
  #-----------------------------------------------------------------------------
  def self.accept(*args)
    Win32API.new(DLL, "accept", "ppl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Bind
  #-----------------------------------------------------------------------------
  def self.bind(*args)
    Win32API.new(DLL, "bind", "ppl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Close Socket
  #-----------------------------------------------------------------------------
  def self.closesocket(*args)
    Win32API.new(DLL, "closesocket", "p", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Connect
  #-----------------------------------------------------------------------------
  def self.connect(*args)
    Win32API.new(DLL, "connect", "ppl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Get host (Using Adress)
  #-----------------------------------------------------------------------------
  def self.gethostbyaddr(*args)
    Win32API.new(DLL, "gethostbyaddr", "pll", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Get host (Using Name)
  #-----------------------------------------------------------------------------
  def self.gethostbyname(*args)
    Win32API.new(DLL, "gethostbyname", "p", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Get host's Name
  #-----------------------------------------------------------------------------
  def self.gethostname(*args)
    Win32API.new(DLL, "gethostname", "pl", "").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Get Server (Using Name)
  #-----------------------------------------------------------------------------
  def self.getservbyname(*args)
    Win32API.new(DLL, "getservbyname", "pp", "p").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Convert Host Long To Network Long
  #-----------------------------------------------------------------------------
  def self.htonl(*args)
    Win32API.new(DLL, "htonl", "l", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Convert Host Short To Network Short
  #-----------------------------------------------------------------------------
  def self.htons(*args)
    Win32API.new(DLL, "htons", "l", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Inet Adress
  #-----------------------------------------------------------------------------
  def self.inet_addr(*args)
    Win32API.new(DLL, "inet_addr", "p", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Inet N To A
  #-----------------------------------------------------------------------------
  def self.inet_ntoa(*args)
    Win32API.new(DLL, "inet_ntoa", "l", "p").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Listen
  #-----------------------------------------------------------------------------
  def self.listen(*args)
    Win32API.new(DLL, "listen", "pl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Recieve
  #-----------------------------------------------------------------------------
  def self.recv(*args)
    Win32API.new(DLL, "recv", "ppll", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Select
  #-----------------------------------------------------------------------------
  def self.select(*args)
    Win32API.new(DLL, "select", "lpppp", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Send
  #-----------------------------------------------------------------------------
  def self.send(*args)
    Win32API.new(DLL, "send", "ppll", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Set Socket Options
  #-----------------------------------------------------------------------------
  def self.setsockopt(*args)
    Win32API.new(DLL, "setsockopt", "pllpl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Shutdown
  #-----------------------------------------------------------------------------
  def self.shutdown(*args)
    Win32API.new(DLL, "shutdown", "pl", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Socket
  #-----------------------------------------------------------------------------
  def self.socket(*args)
    Win32API.new(DLL, "socket", "lll", "l").call(*args)
  end
  #-----------------------------------------------------------------------------
  # * Get Last Error
  #-----------------------------------------------------------------------------
  def self.WSAGetLastError(*args)
    Win32API.new(DLL, "WSAGetLastError", "", "l").call(*args)
  end
end



if !Object.const_defined?(:Socket) # for compatibility



#===============================================================================
# ** Socket - Creates and manages sockets.
#-------------------------------------------------------------------------------
# Author    Ruby
# Version   1.8.1
#===============================================================================
class Socket
  #-----------------------------------------------------------------------------
  # * Constants
  #-----------------------------------------------------------------------------
  AF_UNSPEC                 = 0
  AF_UNIX                   = 1
  AF_INET                   = 2
  AF_IPX                    = 6
  AF_APPLETALK              = 16
  PF_UNSPEC                 = 0
  PF_UNIX                   = 1
  PF_INET                   = 2
  PF_IPX                    = 6
  PF_APPLETALK              = 16
  SOCK_STREAM               = 1
  SOCK_DGRAM                = 2
  SOCK_RAW                  = 3
  SOCK_RDM                  = 4
  SOCK_SEQPACKET            = 5
  IPPROTO_IP                = 0
  IPPROTO_ICMP              = 1
  IPPROTO_IGMP              = 2
  IPPROTO_GGP               = 3
  IPPROTO_TCP               = 6
  IPPROTO_PUP               = 12
  IPPROTO_UDP               = 17
  IPPROTO_IDP               = 22
  IPPROTO_ND                = 77
  IPPROTO_RAW               = 255
  IPPROTO_MAX               = 256
  SOL_SOCKET                = 65535
  SO_DEBUG                  = 1
  SO_REUSEADDR              = 4
  SO_KEEPALIVE              = 8
  SO_DONTROUTE              = 16
  SO_BROADCAST              = 32
  SO_LINGER                 = 128
  SO_OOBINLINE              = 256
  SO_RCVLOWAT               = 4100
  SO_SNDTIMEO               = 4101
  SO_RCVTIMEO               = 4102
  SO_ERROR                  = 4103
  SO_TYPE                   = 4104
  SO_SNDBUF                 = 4097
  SO_RCVBUF                 = 4098
  SO_SNDLOWAT               = 4099
  TCP_NODELAY               =	1
  MSG_OOB                   = 1
  MSG_PEEK                  = 2
  MSG_DONTROUTE             = 4
  IP_OPTIONS                =	1
  IP_DEFAULT_MULTICAST_LOOP =	1
  IP_DEFAULT_MULTICAST_TTL  =	1
  IP_MULTICAST_IF           =	2
  IP_MULTICAST_TTL          =	3
  IP_MULTICAST_LOOP         =	4
  IP_ADD_MEMBERSHIP         =	5
  IP_DROP_MEMBERSHIP        =	6
  IP_TTL                    =	7
  IP_TOS                    =	8
  IP_MAX_MEMBERSHIPS        =	20
  EAI_ADDRFAMILY            = 1
  EAI_AGAIN                 = 2
  EAI_BADFLAGS              = 3
  EAI_FAIL                  = 4
  EAI_FAMILY                = 5
  EAI_MEMORY                = 6
  EAI_NODATA                = 7
  EAI_NONAME                = 8
  EAI_SERVICE               = 9
  EAI_SOCKTYPE              = 10
  EAI_SYSTEM                = 11
  EAI_BADHINTS              = 12
  EAI_PROTOCOL              = 13
  EAI_MAX                   = 14
  AI_PASSIVE                = 1
  AI_CANONNAME              = 2
  AI_NUMERICHOST            = 4
  AI_MASK                   = 7
  AI_ALL                    = 256
  AI_V4MAPPED_CFG           = 512
  AI_ADDRCONFIG             = 1024
  AI_DEFAULT                = 1536
  AI_V4MAPPED               = 2048
  #--------------------------------------------------------------------------
  # * Returns the associated IP address for the given hostname.
  #--------------------------------------------------------------------------
  def self.getaddress(host)
    gethostbyname(host)[3].unpack("C4").join(".")
  end
  #--------------------------------------------------------------------------
  # * Returns the associated IP address for the given hostname.
  #--------------------------------------------------------------------------
  def self.getservice(serv)
    case serv
    when Numeric
      return serv
    when String
      return getservbyname(serv)
    else
      raise "Please use an integer or string for services."
    end
  end
  #--------------------------------------------------------------------------
  # * Returns information about the given hostname.
  #--------------------------------------------------------------------------
  def self.gethostbyname(name)
    raise SocketError::ENOASSOCHOST if (ptr = Winsock.gethostbyname(name)) == 0
    host = ptr.copymem(16).unpack("iissi")
    [host[0].copymem(64).split("\0")[0], [], host[2], host[4].copymem(4).unpack("l")[0].copymem(4)]
  end
  #--------------------------------------------------------------------------
  # * Returns the user's hostname.
  #--------------------------------------------------------------------------
  def self.gethostname
    buf = "\0" * 256
    Winsock.gethostname(buf, 256)
    buf.strip
  end
  #--------------------------------------------------------------------------
  # * Returns information about the given service.
  #--------------------------------------------------------------------------
  def self.getservbyname(name)
    case name
    when /echo/i
      return 7
    when /daytime/i
      return 13
    when /ftp/i
      return 21
    when /telnet/i
      return 23
    when /smtp/i
      return 25
    when /time/i
      return 37
    when /http/i
      return 80
    when /pop/i
      return 110
    else
      #Network.testing? != 0 ? (Network.testresult(true)) : (raise "Service not recognized.")
      #return if Network.testing? == 2
    end
  end
  #--------------------------------------------------------------------------
  # * Creates an INET-sockaddr struct.
  #--------------------------------------------------------------------------
  def self.sockaddr_in(port, host)
    begin
      [AF_INET, getservice(port)].pack("sn") + gethostbyname(host)[3] + [].pack("x8")
    rescue
      #Network.testing? != 0 ? (Network.testresult(true)): (nil)
      #return if Network.testing? == 2
    rescue Hangup
      #Network.testing? != 0 ? (Network.testresult(true)): (nil)
      #return if Network.testing? == 2
    end
  end
  #--------------------------------------------------------------------------
  # * Creates a new socket and connects it to the given host and port.
  #--------------------------------------------------------------------------
  def self.open(*args)
    socket = new(*args)
    if block_given?
      begin
        yield socket
      ensure
        socket.close
      end
    end
    nil
  end
  #--------------------------------------------------------------------------
  # * Creates a new socket.
  #--------------------------------------------------------------------------
  def initialize(domain, type, protocol)
    SocketError.check if (@fd = Winsock.socket(domain, type, protocol)) == -1
    @fd
  end
  #--------------------------------------------------------------------------
  # * Accepts incoming connections.
  #--------------------------------------------------------------------------
  def accept(flags = 0)
    buf = "\0" * 16
    SocketError.check if Winsock.accept(@fd, buf, flags) == -1
    buf
  end
  #--------------------------------------------------------------------------
  # * Binds a socket to the given sockaddr.
  #--------------------------------------------------------------------------
  def bind(sockaddr)
    SocketError.check if (ret = Winsock.bind(@fd, sockaddr, sockaddr.size)) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Closes a socket.
  #--------------------------------------------------------------------------
  def close
    SocketError.check if (ret = Winsock.closesocket(@fd)) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Connects a socket to the given sockaddr.
  #--------------------------------------------------------------------------
  def connect(sockaddr)
    #return if Network.testing? == 2
    SocketError.check if (ret = Winsock.connect(@fd, sockaddr, sockaddr.size)) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Listens for incoming connections.
  #--------------------------------------------------------------------------
  def listen(backlog)
    SocketError.check if (ret = Winsock.listen(@fd, backlog)) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Checks waiting data's status.
  #--------------------------------------------------------------------------
  def select(timeout) # timeout in seconds
    SocketError.check if (ret = Winsock.select(1, [1, @fd].pack("ll"), 0, 0, [timeout.to_i,
         (timeout * 1000000).to_i].pack("ll"))) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Checks if data is waiting.
  #--------------------------------------------------------------------------
  def ready?
    not select(0) == 0
  end
  #--------------------------------------------------------------------------
  # * Reads data from socket.
  #--------------------------------------------------------------------------
  def read(len)
    buf = "\0" * len
    Win32API.new("msvcrt", "_read", "lpl", "l").call(@fd, buf, len)
    buf
  end
  #--------------------------------------------------------------------------
  # * Returns received data.
  #--------------------------------------------------------------------------
  def recv(len, flags = 0)
    retString=""
    remainLen=len
    while remainLen > 0
      buf = "\0" * remainLen
      retval=Winsock.recv(@fd, buf, buf.size, flags)
      SocketError.check if retval == -1
      # Note: Return value may not equal requested length
      remainLen-=retval
      retString+=buf[0,retval]
    end
    return retString
  end
  #--------------------------------------------------------------------------
  # * Sends data to a host.
  #--------------------------------------------------------------------------
  def send(data, flags = 0)
    SocketError.check if (ret = Winsock.send(@fd, data, data.size, flags)) == -1
    ret
  end
  #--------------------------------------------------------------------------
  # * Recieves file from a socket
  #     size  : file size
  #     scene : update scene boolean
  #--------------------------------------------------------------------------
  def recv_file(size,scene=false,file="")
    data = []
    size.times do |i|
      if scene == true
        $scene.recv_update(size,i,file)  if i%((size/1000)+1)== 0
      else
        Graphics.update if i%1024 == 0
      end
      data << recv(1)
    end
    return data
  end

  def recvTimeout
    if select(10)==0
      raise Hangup.new("Timeout")
    end
    return recv(1)
  end
  #--------------------------------------------------------------------------
  # * Gets
  #--------------------------------------------------------------------------
  def gets
    # Create buffer
    message = ""
    # Loop Until "end of line"
    count=0
    while true
      x=select(0.05)
      if x==0
        count+=1
        Graphics.update if count%10==0
        raise Errno::ETIMEOUT if count>200
        next
      end
      ch = recv(1)
      break if ch == "\n"
      message += ch
    end
    # Return recieved data
    return message
  end
  #--------------------------------------------------------------------------
  # * Writes data to socket.
  #--------------------------------------------------------------------------
  def write(data)
    Win32API.new("msvcrt", "_write", "lpl", "l").call(@fd, data, 1)
  end
end



#===============================================================================
# ** TCPSocket - Creates and manages TCP sockets.
#-------------------------------------------------------------------------------
# Author    Ruby
# Version   1.8.1
#===============================================================================

#-------------------------------------------------------------------------------
# Begin SDK Enabled Check
#-------------------------------------------------------------------------------
class TCPSocket < Socket
  #--------------------------------------------------------------------------
  # * Creates a new socket and connects it to the given host and port.
  #--------------------------------------------------------------------------
  def self.open(*args)
    socket = new(*args)
    if block_given?
      begin
        yield socket
      ensure
        socket.close
      end
    end
    nil
  end
  #--------------------------------------------------------------------------
  # * Creates a new socket and connects it to the given host and port.
  #--------------------------------------------------------------------------
  def initialize(host, port)
    super(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    connect(Socket.sockaddr_in(port, host))
  end
end



#==============================================================================
# ** SocketError
#------------------------------------------------------------------------------
# Default exception class for sockets.
#==============================================================================
class SocketError < StandardError
  ENOASSOCHOST = "getaddrinfo: no address associated with hostname."

  def self.check
    errno = Winsock.WSAGetLastError
    #if not Network.testing? == 1
      raise Errno.const_get(Errno.constants.detect { |c| Errno.const_get(c).new.errno == errno })
    #else
    #  errno != 0 ? (Network.testresult(true)) : (Network.testresult(false))
    #end
  end
end



end # !Object.const_defined?(:Socket)


#############################
#
# HTTP utility functions
#
#############################
def pbPostData(url, postdata, filename=nil, depth=0)
  if url[/^http:\/\/([^\/]+)(.*)$/]
    host = $1
    path = $2
    path = "/" if path.length==0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
    body = postdata.map { |key, value|
      keyString   = key.to_s
      valueString = value.to_s
      keyString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      valueString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      next "#{keyString}=#{valueString}"
    }.join('&')
    request = "POST #{path} HTTP/1.1\r\n"
    request += "Host: #{host}\r\n"
    request += "Proxy-Connection: Close\r\n"
    request += "Content-Length: #{body.length}\r\n"
    request += "Pragma: no-cache\r\n"
    request += "User-Agent: #{userAgent}\r\n"
    request += "Content-Type: application/x-www-form-urlencoded\r\n"
    request += "\r\n"
    request += body
    return pbHttpRequest(host, request, filename, depth)
  end
  return ""
end

def pbDownloadData(url, filename=nil, depth=0)
  raise "Redirection level too deep" if depth>10
  if url[/^http:\/\/([^\/]+)(.*)$/]
    host = $1
    path = $2
    path = "/" if path.length==0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14"
    request = "GET #{path} HTTP/1.1\r\n"
    request += "User-Agent: #{userAgent}\r\n"
    request += "Pragma: no-cache\r\n"
    request += "Host: #{host}\r\n"
    request += "Proxy-Connection: Close\r\n"
    request += "\r\n"
    return pbHttpRequest(host, request, filename, depth)
  end
  return ""
end

def pbHttpRequest(host, request, filename=nil, depth=0)
  raise "Redirection level too deep" if depth>10
  socket = ::TCPSocket.new(host, 80)
  time = Time.now.to_i
  begin
    socket.send(request)
    result = socket.gets
    data = ""
    # Get the HTTP result
    if result[/^HTTP\/1\.[01] (\d+).*/]
      errorcode = $1.to_i
      raise "HTTP Error #{errorcode}" if errorcode>=400 && errorcode<500
      headers = {}
      # Get the response headers
      while true
        result = socket.gets.sub(/\r$/,"")
        break if result==""
        if result[/^([^:]+):\s*(.*)/]
          headers[$1] = $2
        end
      end
      length = -1
      chunked = false
      if headers["Content-Length"]
        length = headers["Content-Length"].to_i
      end
      if headers["Transfer-Encoding"]=="chunked"
        chunked = true
      end
      if headers["Location"] && errorcode>=300 && errorcode<400
        socket.close rescue socket = nil
        return pbDownloadData(headers["Location"],filename,depth+1)
      end
      if chunked
        # Chunked content
        while true
          lengthline = socket.gets.sub(/\r$/,"")
          length = lengthline.to_i(16)
          break if length==0
          while Time.now.to_i-time>=5 || socket.select(10)==0
            time = Time.now.to_i
            Graphics.update
          end
          data += socket.recv(length)
          socket.gets
        end
      elsif length==-1
        # No content length specified
        while true
          break if socket.select(500)==0
          while Time.now.to_i-time>=5 || socket.select(10)==0
            time = Time.now.to_i
            Graphics.update
          end
          data += socket.recv(1)
        end
      else
        # Content length specified
        while length>0
          chunk = [length,4096].min
          while Time.now.to_i-time>=5 || socket.select(10)==0
            time = Time.now.to_i
            Graphics.update
          end
          data += socket.recv(chunk)
          length -= chunk
        end
      end
    end
    return data if !filename
    File.open(filename,"wb") { |f| f.write(data) }
  ensure
    socket.close rescue socket = nil
  end
  return ""
end

def pbDownloadToString(url)
  begin
    data = pbDownloadData(url)
    return data
  rescue
    return ""
  end
end

def pbDownloadToFile(url, file)
  begin
    pbDownloadData(url,file)
  rescue
  end
end

def pbPostToString(url, postdata)
  begin
    data = pbPostData(url, postdata)
    return data
  rescue
    return ""
  end
end

def pbPostToFile(url, postdata, file)
  begin
    pbPostData(url, postdata,file)
  rescue
  end
end
