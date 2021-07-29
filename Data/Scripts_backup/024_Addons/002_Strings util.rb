# String class extensions
class String
  # Returns true if the string starts with the passed substring.
  def starts_with?(str)
    return false if !str.is_a?(String)
    return false if str.size > self.size
    return self[0...str.length] == str
  end
  
  # Returns true if the string ends with the passed substring.
  def ends_with?(str)
    return self.reverse.starts_with?(str.reverse)
  end
  
  # Converts to bits
  def to_b
    return self.unpack('b*')[0]
  end
  
  # Converts to bits and replaces itself
  def to_b!
    self.replace(to_b)
  end
  
  # Converts from bits
  def from_b
    return [self].pack('b*')
  end
  
  # Convert from bits and replaces itself
  def from_b!
    self.replace(from_b)
  end
  
  # Returns the first n characters
  def first(n = 1)
    return self.clone if n >= self.size
    return self[0] if n == 1
    return self[0...n]
  end
  
  # Returns the last n characters
  def last(n = 1)
    return self.clone if n >= self.size
    return self[-1] if n == 1
    return self.reverse[0...n].reverse
  end
  
  # Returns a random character from the string
  def random
    return self[rand(self.size)]
  end
  
  
  # Breaks the string up every _n_ characters
  def breakup(n)
    new = []
    for i in 0...self.size
      new[(i / n).floor] ||= ""
      new[(i / n).floor] += self[i]
    end
    return new
  end
  
  def empty?
    return (self.size == 0)
  end
  
  def numeric?
    i = 0
    for e in self.split("")
      next if i == 0 && e == "-"
      return false unless [0,1,2,3,4,5,6,7,8,9].map { |n| n.to_s }.include?(e)
    end
    return true
  end
  
  # Deflates itself and returns the result
  def deflate
    return Zlib::Deflate.deflate(self)
  end
  
  # Deflates and replaces itself
  def deflate!
    self.replace(deflate)
  end
  
  # Inflates itself and returns the result
  def inflate
    return Zlib::Inflate.inflate(self)
  end
  
  # Inflates and replaces itself
  def inflate!
    self.replace(inflate)
  end
  
  # Adds some aliases for <include?>: <has?>, <includes?>, <contains?>
  alias has? include?
  alias includes? include?
  alias contains? include?
end