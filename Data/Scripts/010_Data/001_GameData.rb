module GameData
  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is known by a symbol or an ID number.
  #=============================================================================
  module ClassMethods
    def register(hash)
      self::DATA[hash[:id]] = self::DATA[hash[:id_number]] = self.new(hash)
    end

    # @param other [Symbol, self, String, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String, Integer]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
#      if other.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
#      if other.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in order of their id_number.
    def each
      keys = self::DATA.keys.sort { |a, b| self::DATA[a].id_number <=> self::DATA[b].id_number }
      keys.each { |key| yield self::DATA[key] if !key.is_a?(Integer) }
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by a symbol.
  #=============================================================================
  module ClassMethodsSymbols
    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [Symbol, self, String]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    # @param other [Symbol, self, String]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in alphabetical order.
    def each
      keys = self::DATA.keys.sort { |a, b| self::DATA[a].real_name <=> self::DATA[b].real_name }
      keys.each { |key| yield self::DATA[key] }
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by an ID number.
  #=============================================================================
  module ClassMethodsIDNumbers
    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [self, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [self, Integer]
      other = other.id if other.is_a?(self)
      return !self::DATA[other].nil?
    end

    # @param other [self, Integer]
    # @return [self]
    def get(other)
      validate other => [self, Integer]
      return other if other.is_a?(self)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    def try_get(other)
      return nil if other.nil?
      validate other => [self, Integer]
      return other if other.is_a?(self)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in numberical order.
    def each
      keys = self::DATA.keys.sort
      keys.each { |key| yield self::DATA[key] }
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common instance methods
  # (called by thing.method) that analyse the data of a particular thing which
  # the instance represents.
  #=============================================================================
  module InstanceMethods
    # @param other [Symbol, self.class, String, Integer]
    # @return [Boolean] whether other represents the same thing as this thing
    def ==(other)
      return false if other.nil?
      if other.is_a?(Symbol)
        return @id == other
      elsif other.is_a?(self.class)
        return @id == other.id
      elsif other.is_a?(String)
        return @id_number == other.to_sym
      elsif other.is_a?(Integer)
        return @id_number == other
      end
      return false
    end
  end

  #=============================================================================
  # A bulk loader method for all data stored in .dat files in the Data folder.
  #=============================================================================
  def self.load_all
    Type.load
    Ability.load
    Move.load
    Item.load
    BerryPlant.load
    Species.load
    Ribbon.load
    Encounter.load
    TrainerType.load
    Trainer.load
    Metadata.load
    MapMetadata.load
  end
end
