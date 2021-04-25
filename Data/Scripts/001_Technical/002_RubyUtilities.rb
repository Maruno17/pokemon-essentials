#===============================================================================
# class Object
#===============================================================================
class Object
  alias full_inspect inspect
end

#===============================================================================
# class Class
#===============================================================================
class Class
  def to_sym
    return self.to_s.to_sym
  end
end

#===============================================================================
# class String
#===============================================================================
class String
  def starts_with_vowel?
    return ['a', 'e', 'i', 'o', 'u'].include?(self[0, 1].downcase)
  end

  def first(n = 1)
    return self[0...n]
  end

  def last(n = 1)
    return self[-n..-1] || self
  end

  def blank?
    blank = true
    s = self.scan(/./)
    for l in s
      blank = false if l != ""
    end
    return blank
  end

  def cut(bitmap, width)
    string = self
    width -= bitmap.text_size("...").width
    string_width = 0
    text = []
    for char in string.scan(/./)
      wdh = bitmap.text_size(char).width
      next if (wdh + string_width) > width
      string_width += wdh
      text.push(char)
    end
    text.push("...") if text.length < string.length
    new_string = ""
    for char in text
      new_string += char
    end
    return new_string
  end
end

#===============================================================================
# class Numeric
#===============================================================================
class Numeric
  # Turns a number into a string formatted like 12,345,678.
  def to_s_formatted
    return self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end
end

#===============================================================================
# class Array
#===============================================================================
class Array
  def ^(other)   # xor of two arrays
    return (self|other) - (self&other)
  end

  def swap(val1, val2)
    index1 = self.index(val1)
    index2 = self.index(val2)
    self[index1] = val2
    self[index2] = val1
  end
end

#===============================================================================
# module Enumerable
#===============================================================================
module Enumerable
  def transform
    ret = []
    self.each { |item| ret.push(yield(item)) }
    return ret
  end
end

#===============================================================================
# class ByteWriter (used by def save_to_png below)
#===============================================================================
class ByteWriter
  def initialize(filename)
    @file = File.new(filename, "wb")
  end

  def <<(*data)
    write(*data)
  end

  def write(*data)
    data.each do |e|
      if e.is_a?(Array)
        e.each { |item| write(item) }
      elsif e.is_a?(Numeric)
        @file.putc e
      else
        raise "Invalid data for writing."
      end
    end
  end

  def write_int(int)
    self << ByteWriter.to_bytes(int)
  end

  def close
    @file.close
    @file = nil
  end

  def self.to_bytes(int)
    return [
      (int >> 24) & 0xFF,
      (int >> 16) & 0xFF,
      (int >> 8) & 0xFF,
       int & 0xFF
    ]
  end
end

#===============================================================================
# class Bitmap
#===============================================================================
class Bitmap
  def save_to_png(filename)
    f = ByteWriter.new(filename)
    #============================= Writing header =============================#
    # PNG signature
    f << [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    # Header length
    f << [0x00, 0x00, 0x00, 0x0D]
    # IHDR
    headertype = [0x49, 0x48, 0x44, 0x52]
    f << headertype
    # Width, height, compression, filter, interlacing
    headerdata = ByteWriter.to_bytes(self.width).
      concat(ByteWriter.to_bytes(self.height)).
      concat([0x08, 0x06, 0x00, 0x00, 0x00])
    f << headerdata
    # CRC32 checksum
    sum = headertype.concat(headerdata)
    f.write_int Zlib::crc32(sum.pack("C*"))
    #============================== Writing data ==============================#
    data = []
    for y in 0...self.height
      # Start scanline
      data << 0x00   # Filter: None
      for x in 0...self.width
        px = self.get_pixel(x, y)
        # Write raw RGBA pixels
        data << px.red
        data << px.green
        data << px.blue
        data << px.alpha
      end
    end
    # Zlib deflation
    smoldata = Zlib::Deflate.deflate(data.pack("C*")).bytes
    # data chunk length
    f.write_int smoldata.size
    # IDAT
    f << [0x49, 0x44, 0x41, 0x54]
    f << smoldata
    # CRC32 checksum
    f.write_int Zlib::crc32([0x49, 0x44, 0x41, 0x54].concat(smoldata).pack("C*"))
    #============================== End Of File ===============================#
    # Empty chunk
    f << [0x00, 0x00, 0x00, 0x00]
    # IEND
    f << [0x49, 0x45, 0x4E, 0x44]
    # CRC32 checksum
    f.write_int Zlib::crc32([0x49, 0x45, 0x4E, 0x44].pack("C*"))
    f.close
    return nil
  end
end

#===============================================================================
# Kernel methods
#===============================================================================
def rand(*args)
  Kernel.rand(*args)
end

class << Kernel
  alias oldRand rand unless method_defined?(:oldRand)
  def rand(a = nil, b = nil)
    if a.is_a?(Range)
      lo = a.min
      hi = a.max
      return lo + oldRand(hi - lo + 1)
    elsif a.is_a?(Numeric)
      if b.is_a?(Numeric)
        return a + oldRand(b - a + 1)
      else
        return oldRand(a)
      end
    elsif a.nil?
      return (b) ? oldRand(b) : oldRand(2)
    end
  end
end

def nil_or_empty?(string)
  return string.nil? || !string.is_a?(String) || string.size == 0
end
