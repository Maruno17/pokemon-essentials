#===============================================================================
# class Object
#===============================================================================
class Object
  alias full_inspect inspect

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
