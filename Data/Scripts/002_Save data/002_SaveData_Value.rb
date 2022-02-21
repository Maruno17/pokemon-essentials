module SaveData
  # Contains Value objects for each save element.
  # Populated during runtime by SaveData.register calls.
  # @type [Array<Value>]
  @values = []

  # An error raised if an invalid save value is being saved or loaded.
  class InvalidValueError < RuntimeError; end

  #=============================================================================
  # Represents a single value in save data.
  # New values are added using {SaveData.register}.
  class Value
    # @return [Symbol] the value id
    attr_reader :id

    # @param id [Symbol] value id
    def initialize(id, &block)
      validate id => Symbol, block => Proc
      @id = id
      @loaded = false
      @load_in_bootup = false
      instance_eval(&block)
      raise "No save_value defined for save value #{id.inspect}" if @save_proc.nil?
      raise "No load_value defined for save value #{id.inspect}" if @load_proc.nil?
    end

    # @param value [Object] value to check
    # @return [Boolean] whether the given value is valid
    def valid?(value)
      return true if @ensured_class.nil?
      return value.is_a?(Object.const_get(@ensured_class))
    end

    # Calls the value's load proc with the given argument passed into it.
    # @param value [Object] load proc argument
    # @raise [InvalidValueError] if an invalid value is being loaded
    def load(value)
      validate_value(value)
      @load_proc.call(value)
      @loaded = true
    end

    # Calls the value's save proc and returns its value.
    # @return [Object] save proc value
    # @raise [InvalidValueError] if an invalid value is being saved
    def save
      value = @save_proc.call
      validate_value(value)
      return value
    end

    # @return [Boolean] whether the value has a new game value proc defined
    def has_new_game_proc?
      return @new_game_value_proc.is_a?(Proc)
    end

    # Calls the save value's load proc with the value fetched
    # from the defined new game value proc.
    # @raise (see #load)
    def load_new_game_value
      unless self.has_new_game_proc?
        raise "Save value #{@id.inspect} has no new_game_value defined"
      end
      self.load(@new_game_value_proc.call)
    end

    # @return [Boolean] whether the value should be loaded during bootup
    def load_in_bootup?
      return @load_in_bootup
    end

    # @return [Boolean] whether the value has been loaded
    def loaded?
      return @loaded
    end

    # Marks value as unloaded.
    def mark_as_unloaded
      @loaded = false
    end

    # Uses the {#from_old_format} proc to select the correct data from
    # +old_format+ and return it.
    # Returns nil if the proc is undefined.
    # @param old_format [Array] old format to load value from
    # @return [Object] data from the old format
    def get_from_old_format(old_format)
      return nil if @old_format_get_proc.nil?
      return @old_format_get_proc.call(old_format)
    end

    private

    # Raises an {InvalidValueError} if the given value is invalid.
    # @param value [Object] value to check
    # @raise [InvalidValueError] if the value is invalid
    def validate_value(value)
      return if self.valid?(value)
      raise InvalidValueError, "Save value #{@id.inspect} is not a #{@ensured_class} (#{value.class.name} given)"
    end

    # @!group Configuration

    # If present, ensures that the value is of the given class.
    # @param class_name [Symbol] class to enforce
    # @see SaveData.register
    def ensure_class(class_name)
      validate class_name => Symbol
      @ensured_class = class_name
    end

    # Defines how the loaded value is placed into a global variable.
    # Requires a block with the loaded value as its parameter.
    # @see SaveData.register
    def load_value(&block)
      raise ArgumentError, "No block given to load_value" unless block_given?
      @load_proc = block
    end

    # Defines what is saved into save data. Requires a block.
    # @see SaveData.register
    def save_value(&block)
      raise ArgumentError, "No block given to save_value" unless block_given?
      @save_proc = block
    end

    # If present, defines what the value is set to at the start of a new game.
    # @see SaveData.register
    def new_game_value(&block)
      raise ArgumentError, "No block given to new_game_value" unless block_given?
      @new_game_value_proc = block
    end

    # If present, sets the value to be loaded during bootup.
    # @see SaveData.register
    def load_in_bootup
      @load_in_bootup = true
    end

    # If present, defines how the value should be fetched from the pre-v19
    # save format. Requires a block with the old format array as its parameter.
    # @see SaveData.register
    def from_old_format(&block)
      raise ArgumentError, "No block given to from_old_format" unless block_given?
      @old_format_get_proc = block
    end

    # @!endgroup
  end

  #=============================================================================
  # Registers a {Value} to be saved into save data.
  # Takes a block which defines the value's saving ({Value#save_value})
  # and loading ({Value#load_value}) procedures.
  #
  # It is also possible to provide a proc for fetching the value
  # from the pre-v19 format ({Value#from_old_format}), define
  # a value to be set upon starting a new game with {Value#new_game_value}
  # and ensure that the saved and loaded value is of the correct
  # class with {Value#ensure_class}.
  #
  # Values can be registered to be loaded on bootup with
  # {Value#load_in_bootup}. If a new_game_value proc is defined, it
  # will be called when the game is launched for the first time,
  # or if the save data does not contain the value in question.
  #
  # @example Registering a new value
  #   SaveData.register(:foo) do
  #     ensure_class :Foo
  #     save_value { $foo }
  #     load_value { |value| $foo = value }
  #     new_game_value { Foo.new }
  #     from_old_format { |old_format| old_format[16] if old_format[16].is_a?(Foo) }
  #   end
  # @example Registering a value to be loaded on bootup
  #   SaveData.register(:bar) do
  #     load_in_bootup
  #     save_value { $bar }
  #     load_value { |value| $bar = value }
  #     new_game_value { Bar.new }
  #   end
  # @param id [Symbol] value id
  # @yield the block of code to be saved as a Value
  def self.register(id, &block)
    validate id => Symbol
    unless block_given?
      raise ArgumentError, "No block given to SaveData.register"
    end
    @values << Value.new(id, &block)
  end

  # @param save_data [Hash] save data to validate
  # @return [Boolean] whether the given save data is valid
  def self.valid?(save_data)
    validate save_data => Hash
    return @values.all? { |value| value.valid?(save_data[value.id]) }
  end

  # Loads values from the given save data.
  # An optional condition can be passed.
  # @param save_data [Hash] save data to load from
  # @param condition_block [Proc] optional condition
  # @api private
  def self.load_values(save_data, &condition_block)
    @values.each do |value|
      next if block_given? && !condition_block.call(value)
      if save_data.has_key?(value.id)
        value.load(save_data[value.id])
      elsif value.has_new_game_proc?
        value.load_new_game_value
      end
    end
  end

  # Loads the values from the given save data by
  # calling each {Value} object's {Value#load_value} proc.
  # Values that are already loaded are skipped.
  # If a value does not exist in the save data and has
  # a {Value#new_game_value} proc defined, that value
  # is loaded instead.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load_all_values(save_data)
    validate save_data => Hash
    load_values(save_data) { |value| !value.loaded? }
  end

  # Marks all values that aren't loaded on bootup as unloaded.
  def self.mark_values_as_unloaded
    @values.each do |value|
      value.mark_as_unloaded unless value.load_in_bootup?
    end
  end

  # Loads each value from the given save data that has
  # been set to be loaded during bootup. Done when a save file exists.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load_bootup_values(save_data)
    validate save_data => Hash
    load_values(save_data) { |value| !value.loaded? && value.load_in_bootup? }
  end

  # Goes through each value with {Value#load_in_bootup} enabled and loads their
  # new game value, if one is defined. Done when no save file exists.
  def self.initialize_bootup_values
    @values.each do |value|
      next unless value.load_in_bootup?
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end

  # Loads each {Value}'s new game value, if one is defined. Done when starting a
  # new game.
  def self.load_new_game_values
    @values.each do |value|
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.compile_save_hash
    save_data = {}
    @values.each { |value| save_data[value.id] = value.save }
    return save_data
  end
end
