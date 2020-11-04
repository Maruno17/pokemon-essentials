module PokemonData
  # A mixin module for data classes which provides common class methods (called
  # by PokemonData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  module ClassMethods
    # @param other [Symbol, self, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self.class, Integer]
      other = other.id if other.is_a?(self.class)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, Integer]
    # @return [self]
    def get(other)
      validate other => [Symbol, self.class, Integer]
      return other if other.is_a?(self.class)
#      if other.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self.class, Integer]
      return other if other.is_a?(self.class)
#      if other.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    def each
      keys = self::DATA.keys
      keys.sort! { |a, b| a.id_number <=> b.id_number }
      keys.each do |key|
        yield self::DATA[key] if key.is_a?(Symbol)
      end
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  # A mixin module for data classes which provides common instance methods
  # (called by thing.method) that analyse the data of a particular thing which
  # the instance represents.
  module InstanceMethods
    # @param other [Symbol, self.class, Integer]
    # @return [Boolean] whether other represents the same thing as this thing
    def ==(other)
      return false if other.nil?
      validate other => [Symbol, self.class, Integer]
      if other.is_a?(Symbol)
        return @id == other
      elsif other.is_a?(self.class)
        return @id == other.id
      elsif other.is_a?(Integer)
        return @id_number == other
      end
      return false
    end
  end
end
