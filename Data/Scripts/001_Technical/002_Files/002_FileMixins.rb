module FileInputMixin
  def fgetb
    ret = 0
    each_byte do |i|
      ret = i || 0
      break
    end
    return ret
  end

  def fgetw
    x = 0
    ret = 0
    each_byte do |i|
      break if !i
      ret |= (i << x)
      x += 8
      break if x == 16
    end
    return ret
  end

  def fgetdw
    x = 0
    ret = 0
    each_byte do |i|
      break if !i
      ret |= (i << x)
      x += 8
      break if x == 32
    end
    return ret
  end

  def fgetsb
    ret = fgetb
    ret -= 256 if (ret & 0x80) != 0
    return ret
  end

  def xfgetb(offset)
    self.pos = offset
    return fgetb
  end

  def xfgetw(offset)
    self.pos = offset
    return fgetw
  end

  def xfgetdw(offset)
    self.pos = offset
    return fgetdw
  end

  def getOffset(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return 0 if index >= offset
    self.pos = index * 8
    return fgetdw
  end

  def getLength(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return 0 if index >= offset
    self.pos = (index * 8) + 4
    return fgetdw
  end

  def readName(index)
    self.binmode
    self.pos = 0
    offset = fgetdw >> 3
    return "" if index >= offset
    self.pos = index << 3
    offset = fgetdw
    length = fgetdw
    return "" if length == 0
    self.pos = offset
    return read(length)
  end
end

module FileOutputMixin
  def fputb(b)
    b &= 0xFF
    write(b.chr)
  end

  def fputw(w)
    2.times do
      b = w & 0xFF
      write(b.chr)
      w >>= 8
    end
  end

  def fputdw(w)
    4.times do
      b = w & 0xFF
      write(b.chr)
      w >>= 8
    end
  end
end

class File < IO
#   unless defined?(debugopen)
#     class << self
#       alias debugopen open
#     end
#   end

#   def open(f, m = "r")
#     debugopen("debug.txt", "ab") { |file| file.write([f, m, Time.now.to_f].inspect + "\r\n") }
#     if block_given?
#       debugopen(f, m) { |file| yield file }
#     else
#       return debugopen(f, m)
#     end
#   end

  include FileInputMixin
  include FileOutputMixin
end

class StringInput
  include FileInputMixin

  def pos=(value)
    seek(value)
  end

  def each_byte
    until eof?
      yield getc
    end
  end

  def binmode; end
end

class StringOutput
  include FileOutputMixin
end
