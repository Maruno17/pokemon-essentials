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
    return ["a", "e", "i", "o", "u"].include?(self[0].downcase)
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
    return !self[/\A[+-]?\d+(?:\.\d+)?\Z/].nil?
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
  # xor of two arrays
  def ^(other)
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
# Collision testing
#===============================================================================
class Rect < Object
  def contains?(cx, cy)
    return cx >= self.x && cx < self.x + self.width &&
           cy >= self.y && cy < self.y + self.height
  end
end

#===============================================================================
# class File
#===============================================================================
class File
  # Copies the source file to the destination path.
  def self.copy(source, destination)
    data = ""
    t = System.uptime
    File.open(source, "rb") do |f|
      loop do
        r = f.read(4096)
        break if !r
        if System.uptime - t >= 5
          t += 5
          Graphics.update
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
    case args.length
    when 1
      case args.first
      when Integer
        hex = args.first.to_s(16)
      when String
        try_rgb_format = args.first.split(",")
        init_original(*try_rgb_format.map(&:to_i)) if try_rgb_format.length.between?(3, 4)
        hex = args.first.delete("#")
      end
      pbPrintException("Wrong type of argument given!") if !hex
      r = hex[0...2].to_i(16)
      g = hex[2...4].to_i(16)
      b = hex[4...6].to_i(16)
    when 3
      r, g, b = *args
    end
    init_original(r, g, b) if r && g && b
    init_original(*args)
  end

  def self.new_from_rgb(param)
    return Font.default_color if !param
    base_int = param.to_i(16)
    case param.length
    when 8   # 32-bit hex
      return Color.new(
        (base_int >> 24) & 0xFF,
        (base_int >> 16) & 0xFF,
        (base_int >> 8) & 0xFF,
        (base_int) & 0xFF
      )
    when 6   # 24-bit hex
      return Color.new(
        (base_int >> 16) & 0xFF,
        (base_int >> 8) & 0xFF,
        (base_int) & 0xFF
      )
    when 4   # 15-bit hex
      return Color.new(
        ((base_int) & 0x1F) << 3,
        ((base_int >> 5) & 0x1F) << 3,
        ((base_int >> 10) & 0x1F) << 3
      )
    when 1, 2   # Color number
      case base_int
      when 0 then return Color.white
      when 1 then return Color.blue
      when 2 then return Color.red
      when 3 then return Color.green
      when 4 then return Color.cyan
      when 5 then return Color.pink
      when 6 then return Color.yellow
      when 7 then return Color.gray
      else        return Font.default_color
      end
    end
    return Font.default_color
  end

  # @return [String] the 15-bit representation of this color in a string, ignoring its alpha
  def to_rgb15
    ret = (self.red.to_i >> 3)
    ret |= ((self.green.to_i >> 3) << 5)
    ret |= ((self.blue.to_i >> 3) << 10)
    return sprintf("%04X", ret)
  end

  # @return [String] this color in the format "RRGGBB", ignoring its alpha
  def to_rgb24
    return sprintf("%02X%02X%02X", self.red.to_i, self.green.to_i, self.blue.to_i)
  end

  # @return [String] this color in the format "RRGGBBAA" (or "RRGGBB" if this color's alpha is 255)
  def to_rgb32(always_include_alpha = false)
    if self.alpha.to_i == 255 && !always_include_alpha
      return sprintf("%02X%02X%02X", self.red.to_i, self.green.to_i, self.blue.to_i)
    end
    return sprintf("%02X%02X%02X%02X", self.red.to_i, self.green.to_i, self.blue.to_i, self.alpha.to_i)
  end

  # @return [String] this color in the format "#RRGGBB", ignoring its alpha
  def to_hex
    return "#" + to_rgb24
  end

  # @return [Integer] this color in RGB format converted to an integer
  def to_i
    return self.to_rgb24.to_i(16)
  end

  # @return [Color] the contrasting color to this one
  def get_contrast_color
    r = self.red
    g = self.green
    b = self.blue
    yuv = [
      (r * 0.299) + (g * 0.587) + (b * 0.114),
      (r * -0.1687) + (g * -0.3313) + (b *  0.500) + 0.5,
      (r * 0.500) + (g * -0.4187) + (b * -0.0813) + 0.5
    ]
    if yuv[0] < 127.5
      yuv[0] += (255 - yuv[0]) / 2
    else
      yuv[0] = yuv[0] / 2
    end
    return Color.new(
      yuv[0] + (1.4075 * (yuv[2] - 0.5)),
      yuv[0] - (0.3455 * (yuv[1] - 0.5)) - (0.7169 * (yuv[2] - 0.5)),
      yuv[0] + (1.7790 * (yuv[1] - 0.5)),
      self.alpha
    )
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

  # Returns color object for some commonly used colors.
  def self.red;     return Color.new(255, 128, 128); end
  def self.green;   return Color.new(128, 255, 128); end
  def self.blue;    return Color.new(128, 128, 255); end
  def self.yellow;  return Color.new(255, 255, 128); end
  def self.magenta; return Color.new(255,   0, 255); end
  def self.cyan;    return Color.new(128, 255, 255); end
  def self.white;   return Color.new(255, 255, 255); end
  def self.gray;    return Color.new(192, 192, 192); end
  def self.black;   return Color.new(  0,   0,   0); end
  def self.pink;    return Color.new(255, 128, 255); end
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
      args.instance_variable_set("@#{key}", value)
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

#===============================================================================
# Linear interpolation between two values, given the duration of the change and
# either:
#   - the time passed since the start of the change (delta), or
#   - the start time of the change (delta) and the current time (now)
#===============================================================================
def lerp(start_val, end_val, duration, delta, now = nil)
  return end_val if duration <= 0
  delta = now - delta if now
  return start_val if delta <= 0
  return end_val if delta >= duration
  return start_val + ((end_val - start_val) * delta / duration.to_f)
end
