#===============================================================================
# Checking for files and directories
#===============================================================================
# Works around a problem with FileTest.directory if directory contains accent marks
def safeIsDirectory?(f)
  ret = false
  Dir.chdir(f) { ret = true } rescue nil
  return ret
end

# Works around a problem with FileTest.exist if path contains accent marks
def safeExists?(f)
  return FileTest.exist?(f) if f[/\A[\x20-\x7E]*\z/]
  ret = false
  begin
    File.open(f,"rb") { ret = true }
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
    ret = false
  end
  return ret
end

# Similar to "Dir.glob", but designed to work around a problem with accessing
# files if a path contains accent marks.
# "dir" is the directory path, "wildcard" is the filename pattern to match.
def safeGlob(dir,wildcard)
  ret = []
  afterChdir = false
  begin
    Dir.chdir(dir) {
      afterChdir = true
      Dir.glob(wildcard) { |f| ret.push(dir+"/"+f) }
    }
  rescue Errno::ENOENT
    raise if afterChdir
  end
  if block_given?
    ret.each { |f| yield(f) }
  end
  return (block_given?) ? nil : ret
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns nil if the path can't be found.
def pbResolveBitmap(x)
  return nil if !x
  noext = x.gsub(/\.(bmp|png|gif|jpg|jpeg)$/,"")
  filename = nil
#  RTP.eachPathFor(x) { |path|
#    filename = pbTryString(path) if !filename
#    filename = pbTryString(path+".gif") if !filename
#  }
  RTP.eachPathFor(noext) { |path|
    filename = pbTryString(path+".png") if !filename
    filename = pbTryString(path+".gif") if !filename
#    filename = pbTryString(path+".jpg") if !filename
#    filename = pbTryString(path+".jpeg") if !filename
#    filename = pbTryString(path+".bmp") if !filename
  }
  return filename
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns _x_ if the path can't be found.
def pbBitmapName(x)
  ret = pbResolveBitmap(x)
  return (ret) ? ret : x
end

def getUnicodeString(addr)
  return "" if addr==0
  rtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  ret = ""
  data = "xx"
  index = (addr.is_a?(String)) ? 0 : addr
  loop do
    if addr.is_a?(String)
      data = addr[index,2]
    else
      rtlMoveMemory_pi.call(data, index, 2)
    end
    codepoint = data.unpack("v")[0]
    break if codepoint==0
    index += 2
    if codepoint<=0x7F
      ret += codepoint.chr
    elsif codepoint<=0x7FF
      ret += (0xC0|((codepoint>>6)&0x1F)).chr
      ret += (0x80|(codepoint   &0x3F)).chr
    elsif codepoint<=0xFFFF
      ret += (0xE0|((codepoint>>12)&0x0F)).chr
      ret += (0x80|((codepoint>>6)&0x3F)).chr
      ret += (0x80|(codepoint   &0x3F)).chr
    elsif codepoint<=0x10FFFF
      ret += (0xF0|((codepoint>>18)&0x07)).chr
      ret += (0x80|((codepoint>>12)&0x3F)).chr
      ret += (0x80|((codepoint>>6)&0x3F)).chr
      ret += (0x80|(codepoint   &0x3F)).chr
    end
  end
  return ret
end

def getUnicodeStringFromAnsi(addr)
  return "" if addr==0
  rtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  ret = ""
  data = "x"
  index = (addr.is_a?(String)) ? 0 : addr
  loop do
    if addr.is_a?(String)
      data = addr[index,1]
    else
      rtlMoveMemory_pi.call(data, index, 1)
    end
    index += 1
    codepoint = data.unpack("C")[0]
    break if codepoint==0 || !codepoint
    break if codepoint==0
    if codepoint<=0x7F
      ret += codepoint.chr
    else
      ret += (0xC0|((codepoint>>6)&0x1F)).chr
      ret += (0x80|(codepoint   &0x3F)).chr
    end
  end
  return ret
end

def getKnownFolder(guid)
  packedGuid = guid.pack("VvvC*")
  shGetKnownFolderPath = Win32API.new("shell32.dll","SHGetKnownFolderPath","pllp","i") rescue nil
  coTaskMemFree        = Win32API.new("ole32.dll","CoTaskMemFree","i","") rescue nil
  return "" if !shGetKnownFolderPath || !coTaskMemFree
  path = "\0"*4
  ret = shGetKnownFolderPath.call(packedGuid,0,0,path)
  path = path.unpack("V")[0]
  ret = getUnicodeString(path)
  coTaskMemFree.call(path)
  return ret
end



module RTP
  @rtpPaths = nil

  def self.exists?(filename,extensions=[])
    return false if !filename || filename==""
    eachPathFor(filename) { |path|
      return true if safeExists?(path)
      for ext in extensions
        return true if safeExists?(path+ext)
      end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename,["",".png",".gif"])   # ".jpg",".bmp",".jpeg"
  end

  def self.getAudioPath(filename)
    return self.getPath(filename,["",".mp3",".wav",".wma",".mid",".ogg",".midi"])
  end

  def self.getPath(filename,extensions=[])
    return filename if !filename || filename==""
    eachPathFor(filename) { |path|
      return path if safeExists?(path)
      for ext in extensions
        file = path+ext
        return file if safeExists?(file)
      end
    }
    return filename
  end

 # Gets the absolute RGSS paths for the given file name
  def self.eachPathFor(filename)
    return if !filename
    if filename[/^[A-Za-z]\:[\/\\]/] || filename[/^[\/\\]/]
      # filename is already absolute
      yield filename
    else
      # relative path
      RTP.eachPath { |path|
        if path=="./"
          yield filename
        else
          yield path+filename
        end
      }
    end
  end

  # Gets all RGSS search paths
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/,"/").gsub(/[\/\\]$/,"")+"/"
    if !@rtpPaths
      tmp = Sprite.new
      isRgss2 = tmp.respond_to?("wave_amp")
      tmp.dispose
      @rtpPaths = []
      if isRgss2
        rtp = getGameIniValue("Game","RTP")
        if rtp!=""
          rtp = MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
             "SOFTWARE\\Enterbrain\\RGSS2\\RTP",rtp,nil)
          if rtp && safeIsDirectory?(rtp)
            @rtpPaths.push(rtp.sub(/[\/\\]$/,"")+"/")
          end
        end
      else
        %w( RTP1 RTP2 RTP3 ).each { |v|
          rtp = getGameIniValue("Game",v)
          if rtp!=""
            rtp = MiniRegistry.get(MiniRegistry::HKEY_LOCAL_MACHINE,
               "SOFTWARE\\Enterbrain\\RGSS\\RTP",rtp,nil)
            if rtp && safeIsDirectory?(rtp)
              @rtpPaths.push(rtp.sub(/[\/\\]$/,"")+"/")
            end
          end
        }
      end
    end
    @rtpPaths.each { |x| yield x }
  end

  private

  @@folder = nil

  def self.getGameIniValue(section,key)
    val = "\0"*256
    gps = Win32API.new('kernel32', 'GetPrivateProfileString',%w(p p p p l p), 'l')
    gps.call(section, key, "", val, 256, ".\\Game.ini")
    val.delete!("\0")
    return val
  end

  def self.isDirWritable(dir)
    return false if !dir || dir==""
    loop do
      name = dir.gsub(/[\/\\]$/,"")+"/writetest"
      12.times do
        name += sprintf("%02X",rand(256))
      end
      name += ".tmp"
      if !safeExists?(name)
        retval = false
        begin
          File.open(name,"wb") { retval = true }
        rescue Errno::EINVAL, Errno::EACCES, Errno::ENOENT
        ensure
          File.delete(name) rescue nil
        end
        return retval
      end
    end
  end

  def self.ensureGameDir(dir)
    title = RTP.getGameIniValue("Game","Title")
    title = "RGSS Game" if title==""
    title = title.gsub(/[^\w ]/,"_")
    newdir = dir.gsub(/[\/\\]$/,"")+"/"
    # Convert to UTF-8 because of ANSI function
    newdir += getUnicodeStringFromAnsi(title)
    Dir.mkdir(newdir) rescue nil
    ret = safeIsDirectory?(newdir) ? newdir : dir
    return ret
  end

  def self.getSaveFileName(fileName)
    return getSaveFolder().gsub(/[\/\\]$/,"")+"/"+fileName
  end

  def self.getSaveFolder
    if !@@folder
      # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
      # the current directory contains an accent mark
      pwd = "."
      # Get the known folder path for saved games
      savedGames = getKnownFolder([
         0x4c5c32ff,0xbb9d,0x43b0,0xb5,0xb4,0x2d,0x72,0xe5,0x4e,0xaa,0xa4])
      if savedGames && savedGames!="" && isDirWritable(savedGames)
        pwd = ensureGameDir(savedGames)
      end
      if isDirWritable(pwd)
        @@folder = pwd
      else
        appdata = ENV["LOCALAPPDATA"]
        if isDirWritable(appdata)
          appdata = ensureGameDir(appdata)
        else
          appdata = ENV["APPDATA"]
          if isDirWritable(appdata)
            appdata = ensureGameDir(appdata)
          elsif isDirWritable(pwd)
            appdata = pwd
          else
            appdata = "."
          end
        end
        @@folder = appdata
      end
    end
    return @@folder
  end
end



module FileTest
  Image_ext = ['.bmp', '.png', '.jpg', '.jpeg', '.gif']
  Audio_ext = ['.mp3', '.mid', '.midi', '.ogg', '.wav', '.wma']

  def self.audio_exist?(filename)
    return RTP.exists?(filename,Audio_ext)
  end

  def self.image_exist?(filename)
    return RTP.exists?(filename,Image_ext)
  end
end



# Used to determine whether a data file exists (rather than a graphics or
# audio file). Doesn't check RTP, but does check encrypted archives.
def pbRgssExists?(filename)
  filename = canonicalize(filename)
  if safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a")
    return pbGetFileChar(filename)!=nil
  else
    return safeExists?(filename)
  end
end

# Opens an IO, even if the file is in an encrypted archive.
# Doesn't check RTP for the file.
def pbRgssOpen(file,mode=nil)
  #File.open("debug.txt","ab") { |fw| fw.write([file,mode,Time.now.to_f].inspect+"\r\n") }
  if !safeExists?("./Game.rgssad") && !safeExists?("./Game.rgss2a")
    if block_given?
      File.open(file,mode) { |f| yield f }
      return nil
    else
      return File.open(file,mode)
    end
  end
  file = canonicalize(file)
  Marshal.neverload = true
  begin
    str = load_data(file)
  ensure
    Marshal.neverload = false
  end
  if block_given?
    StringInput.open(str) { |f| yield f }
    return nil
  else
    return StringInput.open(str)
  end
end

# Gets at least the first byte of a file. Doesn't check RTP, but does check
# encrypted archives.
def pbGetFileChar(file)
  file = canonicalize(file)
  if !safeExists?("./Game.rgssad") && !safeExists?("./Game.rgss2a")
    return nil if !safeExists?(file)
    begin
      File.open(file,"rb") { |f| return f.read(1) }   # read one byte
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
      return nil
    end
  end
  Marshal.neverload = true
  str = nil
  begin
    str = load_data(file)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, RGSSError
    str = nil
  ensure
    Marshal.neverload = false
  end
  return str
end

def pbTryString(x)
  ret = pbGetFileChar(x)
  return (ret!=nil && ret!="") ? x : nil
end

# Gets the contents of a file. Doesn't check RTP, but does check
# encrypted archives.
def pbGetFileString(file)
  file = canonicalize(file)
  if !(safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a"))
    return nil if !safeExists?(file)
    begin
      File.open(file,"rb") { |f| return f.read }   # read all data
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
      return nil
    end
  end
  Marshal.neverload = true
  str = nil
  begin
    str = load_data(file)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, RGSSError
    str = nil
  ensure
    Marshal.neverload = false
  end
  return str
end



#===============================================================================
#
#===============================================================================
module MiniRegistry
  HKEY_CLASSES_ROOT  = 0x80000000
  HKEY_CURRENT_USER  = 0x80000001
  HKEY_LOCAL_MACHINE = 0x80000002
  HKEY_USERS         = 0x80000003
  FormatMessageA   = Win32API.new("kernel32","FormatMessageA","LPLLPLP","L")
  RegOpenKeyExA    = Win32API.new("advapi32","RegOpenKeyExA","LPLLP","L")
  RegCloseKey      = Win32API.new("advapi32","RegCloseKey","L","L")
  RegQueryValueExA = Win32API.new("advapi32","RegQueryValueExA","LPLPPP","L")

  def self.open(hkey,subkey,bit64=false)
    key = 0.chr*4
    flag = bit64 ? 0x20119 : 0x20019
    rg = RegOpenKeyExA.call(hkey, subkey, 0, flag, key)
    return nil if rg!=0
    key = key.unpack("V")[0]
    if block_given?
      begin
        yield(key)
      ensure
        check(RegCloseKey.call(key))
      end
    else
      return key
    end
  end

  def self.close(hkey); check(RegCloseKey.call(hkey)) if hkey; end

  def self.get(hkey,subkey,name,defaultValue=nil,bit64=false)
    self.open(hkey,subkey,bit64) { |key|
      return self.read(key,name) rescue defaultValue
    }
    return defaultValue
  end

  def self.read(hkey,name)
    hkey = 0 if !hkey
    type = 0.chr*4
    size = 0.chr*4
    check(RegQueryValueExA.call(hkey,name,0,type,0,size))
    data = " "*size.unpack("V")[0]
    check(RegQueryValueExA.call(hkey,name,0,type,data,size))
    type = type.unpack("V")[0]
    data = data[0,size.unpack("V")[0]]
    case type
    when 1; return data.chop                                   # REG_SZ
    when 2; return data.gsub(/%([^%]+)%/) { ENV[$1] || $& }    # REG_EXPAND_SZ
    when 3; return data                                        # REG_BINARY
    when 4; return data.unpack("V")[0]                         # REG_DWORD
    when 5; return data.unpack("V")[0]                         # REG_DWORD_BIG_ENDIAN
    when 11; data.unpack("VV"); return (data[1]<<32|data[0])   # REG_QWORD
    else; raise "Type #{type} not supported."
    end
  end

  private

  def self.check(code)
    if code!=0
      msg = "\0"*1024
      len = FormatMessageA.call(0x1200, 0, code, 0, msg, 1024, 0)
      raise msg[0, len].tr("\r", '').chomp
    end
  end
end



class StringInput
  include Enumerable

  class << self
    def new( str )
      if block_given?
        begin
          f = super
          yield f
        ensure
          f.close if f
        end
      else
        super
      end
    end
    alias open new
  end

  def initialize( str )
    @string = str
    @pos = 0
    @closed = false
    @lineno = 0
  end

  attr_reader :lineno,:string

  def inspect
    return "#<#{self.class}:#{@closed ? 'closed' : 'open'},src=#{@string[0,30].inspect}>"
  end

  def close
    raise IOError, 'closed stream' if @closed
    @pos = nil
    @closed = true
  end

  def closed?; @closed; end

  def pos
    raise IOError, 'closed stream' if @closed
    [@pos, @string.size].min
  end

  alias tell pos

  def rewind; seek(0); end

  def pos=(value); seek(value); end

  def seek(offset, whence=IO::SEEK_SET)
    raise IOError, 'closed stream' if @closed
    case whence
    when IO::SEEK_SET; @pos = offset
    when IO::SEEK_CUR; @pos += offset
    when IO::SEEK_END; @pos = @string.size - offset
    else
      raise ArgumentError, "unknown seek flag: #{whence}"
    end
    @pos = 0 if @pos < 0
    @pos = [@pos, @string.size + 1].min
    offset
  end

  def eof?
    raise IOError, 'closed stream' if @closed
    @pos > @string.size
  end

  def each( &block )
    raise IOError, 'closed stream' if @closed
    begin
      @string.each(&block)
    ensure
      @pos = 0
    end
  end

  def gets
    raise IOError, 'closed stream' if @closed
    if idx = @string.index(?\n, @pos)
      idx += 1  # "\n".size
      line = @string[ @pos ... idx ]
      @pos = idx
      @pos += 1 if @pos == @string.size
    else
      line = @string[ @pos .. -1 ]
      @pos = @string.size + 1
    end
    @lineno += 1
    line
  end

  def getc
    raise IOError, 'closed stream' if @closed
    ch = @string[@pos]
    @pos += 1
    @pos += 1 if @pos == @string.size
    ch
  end

  def read( len = nil )
    raise IOError, 'closed stream' if @closed
    if !len
      return nil if eof?
      rest = @string[@pos ... @string.size]
      @pos = @string.size + 1
      return rest
    end
    str = @string[@pos, len]
    @pos += len
    @pos += 1 if @pos == @string.size
    str
  end

  def read_all; read(); end

  alias sysread read
end



module ::Marshal
  class << self
    if !@oldloadAliased
      alias oldload load
      @oldloadAliased = true
    end

    @@neverload = false

    def neverload
      return @@neverload
    end

    def neverload=(value)
      @@neverload = value
    end

    def load(port,*arg)
      if @@neverload
        if port.is_a?(IO)
          return port.read
        end
        return port
      end
      oldpos = port.pos if port.is_a?(IO)
      begin
        oldload(port,*arg)
      rescue
        p [$!.class,$!.message,$!.backtrace]
        if port.is_a?(IO)
          port.pos = oldpos
          return port.read
        end
        return port
      end
    end
  end
end
