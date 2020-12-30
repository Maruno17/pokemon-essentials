# NOTE: Everything in here is unused.
#===============================================================================
# Serial record
#===============================================================================
# Unused
module SerialRecords
  class SerialRecord < Array
    def bytesize
      return SerialRecord.bytesize(self)
    end

    def encode(strm)
      return SerialRecord.encode(self,strm)
    end

    def self.bytesize(arr)
      ret = 0
      return 0 if !arr
      for field in arr
        if field==nil || field==true || field==false
          ret += 1
        elsif field.is_a?(String)
          ret += strSize(field)+1
        elsif field.is_a?(Numeric)
          ret += intSize(field)+1
        end
      end
      return ret
    end

    def self.encode(arr,strm)
      return if !arr
      for field in arr
        if field==nil
          strm.write("0")
        elsif field==true
          strm.write("T")
        elsif field==false
          strm.write("F")
        elsif field.is_a?(String)
          strm.write("\"")
          encodeString(strm,field)
        elsif field.is_a?(Numeric)
          strm.write("i")
          encodeInt(strm,field)
        end
      end
    end

    def self.decode(strm,offset,length)
      ret = SerialRecord.new
      strm.pos = offset
      while strm.pos<offset+length
        datatype = strm.read(1)
        case datatype
        when "0"  then ret.push(nil)
        when "T"  then ret.push(true)
        when "F"  then ret.push(false)
        when "\"" then ret.push(decodeString(strm))
        when "i"  then ret.push(decodeInt(strm))
        end
      end
      return ret
    end
  end

  def self.readSerialRecords(filename)
    ret = []
    return ret if !pbRgssExists?(filename)
    pbRgssOpen(filename,"rb") { |file|
      numrec = file.fgetdw>>3
      curpos = 0
      numrec.times do
        file.pos = curpos
        offset = file.fgetdw
        length = file.fgetdw
        record = SerialRecord.decode(file,offset,length)
        ret.push(record)
        curpos += 8
      end
    }
    return ret
  end

  def self.writeSerialRecords(filename,records)
    File.open(filename,"wb") { |file|
      totalsize = records.length*8
      for record in records
        file.fputdw(totalsize)
        bytesize = record.bytesize
        file.fputdw(bytesize)
        totalsize += bytesize
      end
      for record in records
        record.encode(file)
      end
    }
  end
end

#===============================================================================
# Data structures
#===============================================================================
# Unused
class ByteArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("C*") : []
  end

  def [](i); return @a[i]; end
  def []=(i,value); @a[i] = value; end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("C*")
  end
end

# Unused
class WordArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("v*") : []
  end

  def [](i); return @a[i]; end
  def []=(i,value); @a[i] = value; end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("v*")
  end
end

# Unused
class SignedWordArray
  include Enumerable

  def initialize(data=nil)
    @a = (data) ? data.unpack("v*") : []
  end

  def []=(i,value)
    @a[i] = value
  end

  def [](i)
    v = @a[i]
    return 0 if !v
    return (v<0x8000) ? v : -((~v)&0xFFFF)-1
  end

  def length; @a.length; end
  def size; @a.size; end

  def fillNils(length,value)
    for i in 0...length
      @a[i] = value if !@a[i]
    end
  end

  def each
    @a.each { |i| yield i}
  end

  def self._load(str)
    return self.new(str)
  end

  def _dump(_depth=100)
    return @a.pack("v*")
  end
end

#===============================================================================
# Encoding and decoding
#===============================================================================
# Unused
def intSize(value)
  return 1 if value<0x80
  return 2 if value<0x4000
  return 3 if value<0x200000
  return 4 if value<0x10000000
  return 5
end

# Unused
def encodeInt(strm,value)
  num = 0
  loop do
    if value<0x80
      strm.fputb(value)
      return num+1
    end
    strm.fputb(0x80|(value&0x7F))
    value >>= 7
    num += 1
  end
end

# Unused
def decodeInt(strm)
  bits    = 0
  curbyte = 0
  ret = 0
  begin
    curbyte = strm.fgetb
    ret += (curbyte&0x7F)<<bits
    bits += 7
  end while ((curbyte&0x80)>0)&&bits<0x1d
  return ret
end

# Unused
def strSize(str)
  return str.length+intSize(str.length)
end

# Unused
def encodeString(strm,str)
  encodeInt(strm,str.length)
  strm.write(str)
end

# Unused
def decodeString(strm)
  len = decodeInt(strm)
  return strm.read(len)
end

# Unused
def frozenArrayValue(arr)
  typestring = ""
  for i in 0...arr.length
    if i>0
      typestring += ((i%20)==0) ? ",\r\n" : ","
    end
    typestring += arr[i].to_s
  end
  return "["+typestring+"].freeze"
end

#===============================================================================
# Scripted constants
#===============================================================================
# Unused
def pbFindScript(a,name)
  a.each { |i|
    next if !i
    return i if i[1]==name
  }
  return nil
end

# Unused
def pbAddScript(script,sectionname)
  begin
    scripts = load_data("Data/Constants.rxdata")
    scripts = [] if !scripts
  rescue
    scripts = []
  end
  if false   # s
    s = pbFindScript(scripts,sectionname)
    s[2]+=Zlib::Deflate.deflate("#{script}\r\n")
  else
    scripts.push([rand(100000000),sectionname,Zlib::Deflate.deflate("#{script}\r\n")])
  end
  save_data(scripts,"Data/Constants.rxdata")
end
