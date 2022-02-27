#===============================================================================
# class Object
#===============================================================================
class Object
  alias full_inspect inspect unless method_defined?(:full_inspect)

  def inspect
    return "#<#{self.class}>"
  end
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
    return ["a", "e", "i", "o", "u"].include?(self[0, 1].downcase)
  end

  def first(n = 1); return self[0...n]; end

  def last(n = 1); return self[-n..-1] || self; end

  def blank?; return self.strip.empty?; end

  def cut(bitmap, width)
    string = self
    width -= bitmap.text_size("...").width
    string_width = 0
    text = []
    string.scan(/./).each do |char|
      wdh = bitmap.text_size(char).width
      next if (wdh + string_width) > width
      string_width += wdh
      text.push(char)
    end
    text.push("...") if text.length < string.length
    new_string = ""
    text.each do |char|
      new_string += char
    end
    return new_string
  end

  def numeric?
    return !self[/^[+-]?([0-9]+)(?:\.[0-9]+)?$/].nil?
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

  def to_word
    ret = [_INTL("zero"), _INTL("one"), _INTL("two"), _INTL("three"),
           _INTL("four"), _INTL("five"), _INTL("six"), _INTL("seven"),
           _INTL("eight"), _INTL("nine"), _INTL("ten"), _INTL("eleven"),
           _INTL("twelve"), _INTL("thirteen"), _INTL("fourteen"), _INTL("fifteen"),
           _INTL("sixteen"), _INTL("seventeen"), _INTL("eighteen"), _INTL("nineteen"),
           _INTL("twenty")]
    return ret[self] if self.is_a?(Integer) && self >= 0 && self <= ret.length
    return self.to_s
  end
end

#===============================================================================
# class Array
#===============================================================================
class Array
  def ^(other)   # xor of two arrays
    return (self | other) - (self & other)
  end

  def swap(val1, val2)
    index1 = self.index(val1)
    index2 = self.index(val2)
    self[index1] = val2
    self[index2] = val1
  end
end

#===============================================================================
# class Hash
#===============================================================================
class Hash
  def deep_merge(hash)
    merged_hash = self.clone
    merged_hash.deep_merge!(hash) if hash.is_a?(Hash)
    return merged_hash
  end

  def deep_merge!(hash)
    # failsafe
    return unless hash.is_a?(Hash)
    hash.each do |key, val|
      if self[key].is_a?(Hash)
        self[key].deep_merge!(val)
      else
        self[key] = val
      end
    end
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
# class File
#===============================================================================
class File
  # Copies the source file to the destination path.
  def self.copy(source, destination)
    data = ""
    t = Time.now
    File.open(source, "rb") do |f|
      loop do
        r = f.read(4096)
        break if !r
        if Time.now - t > 1
          Graphics.update
          t = Time.now
        end
        data += r
      end
    end
    File.delete(destination) if File.file?(destination)
    f = File.new(destination, "wb")
    f.write data
    f.close
  end

  # Copies the source to the destination and deletes the source.
  def self.move(source, destination)
    File.copy(source, destination)
    File.delete(source)
  end
end

#===============================================================================
# class Color
#===============================================================================
class Color
  # alias for old constructor
  alias init_original initialize unless self.private_method_defined?(:init_original)

  # New constructor, accepts RGB values as well as a hex number or string value.
  def initialize(*args)
  	pbPrintException("Wrong number of arguments! At least 1 is needed!") if args.length < 1
  	if args.length == 1
      if args.first.is_a?(Fixnum)
        hex = args.first.to_s(16)
      elsif args.first.is_a?(String)
        try_rgb_format = args.first.split(",")
        return init_original(*try_rgb_format.map(&:to_i)) if try_rgb_format.length.between?(3, 4)
        hex = args.first.delete("#")
      end
      pbPrintException("Wrong type of argument given!") if !hex
      r = hex[0...2].to_i(16)
      g = hex[2...4].to_i(16)
      b = hex[4...6].to_i(16)
  	elsif args.length == 3
      r, g, b = *args
  	end
  	return init_original(r, g, b) if r && g && b
  	return init_original(*args)
  end

  # Returns this color as a hex string like "#RRGGBB".
  def to_hex
  	r = sprintf("%02X", self.red)
  	g = sprintf("%02X", self.green)
  	b = sprintf("%02X", self.blue)
  	return ("#" + r + g + b).upcase
  end

  # Returns this color as a 24-bit color integer.
  def to_i
  	return self.to_hex.delete("#").to_i(16)
  end

  # Converts the provided hex string/24-bit integer to RGB values.
  def self.hex_to_rgb(hex)
    hex = hex.delete("#") if hex.is_a?(String)
  	hex = hex.to_s(16) if hex.is_a?(Numeric)
  	r = hex[0...2].to_i(16)
  	g = hex[2...4].to_i(16)
  	b = hex[4...6].to_i(16)
  	return r, g, b
  end

  # Parses the input as a Color and returns a Color object made from it.
  def self.parse(color)
    case color
    when Color
      return color
    when String, Numeric
      return Color.new(color)
    end
    # returns nothing if wrong input
    return nil
  end

  # Returns color object for some commonly used colors
  def self.red;     return Color.new(255,   0,   0); end
  def self.green;   return Color.new(  0, 255,   0); end
  def self.blue;    return Color.new(  0,   0, 255); end
  def self.black;   return Color.new(  0,   0,   0); end
  def self.white;   return Color.new(255, 255, 255); end
  def self.yellow;  return Color.new(255, 255,   0); end
  def self.magenta; return Color.new(255,   0, 255); end
  def self.teal;    return Color.new(  0, 255, 255); end
  def self.orange;  return Color.new(255, 155,   0); end
  def self.purple;  return Color.new(155,   0, 255); end
  def self.brown;   return Color.new(112,  72,  32); end
end

#===============================================================================
# Wrap code blocks in a class which passes data accessible as instance variables
# within the code block.
#
# wrapper = CallbackWrapper.new { puts @test }
# wrapper.set(test: "Hi")
# wrapper.execute  #=>  "Hi"
#===============================================================================
class CallbackWrapper
  @params = {}

  def initialize(&block)
    @code_block = block
  end

  def execute(given_block = nil, *args)
    execute_block = given_block || @code_block
    @params.each do |key, value|
      args.instance_variable_set("@#{key.to_s}", value)
    end
    args.instance_eval(&execute_block)
  end

  def set(params = {})
    @params = params
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
      return oldRand(b)
    end
    return oldRand
  end
end

def nil_or_empty?(string)
  return string.nil? || !string.is_a?(String) || string.size == 0
end
