module SaveData

  # Contains Value objects for each save element.
  # Populated during runtime by SaveData.register calls.
  # @type [Hash{Symbol => Value}]
  @values = {}

  # An error raised if an invalid save value is saved or loaded.
  class InvalidValueError < RuntimeError; end

  # TODO Add ensure_value for enhanced compatibility with other plugins etc.?
  #   example:
  #   SaveData.register(:foo) do
  #     ensure_value :bar if PluginManager.installed?('Bar')
  #     save_value { $foo }
  #     load_value do |value|
  #       $foo = value
  #       # We must be certain the Bar plugin's values have been loaded
  #       $bar.plugin_method if PluginManager.installed?('Bar')
  #     end
  #   end

  # Contains the data of a single value in save data.
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

    # Calls the value's save proc and returns its value.
    # @return [Object] save proc value
    # @raise [InvalidValueError] if an invalid value is being saved
    def save
      value = @save_proc.call

      unless self.valid?(value)
        raise InvalidValueError,
              "Save value #{@id.inspect} is not a #{@ensured_class_names.first} (#{value.class.name} given)"
      end

      return value
    end

    # Calls the value's load proc with the given argument passed into it.
    # @param value [Object] load proc argument
    # @raise [InvalidValueError] if an invalid value is being loaded
    def load(value)
      unless self.valid?(value)
        raise InvalidValueError,
              "Save value #{@id.inspect} is not a #{@ensured_class_names.first} (#{value.class.name} given)"
      end

      @load_proc.call(value)
      @loaded = true
    end

    # @param value [Object] value to check
    # @return [Boolean] whether the given value is valid
    def valid?(value)
      return true if @ensured_class_names.nil?
      return @ensured_class_names.include?(value.class.name)
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

    # @return [Boolean] whether the value has a new game value proc defined
    def has_new_game_proc?
      return @new_game_value_proc.is_a?(Proc)
    end

    # @return [Boolean] whether the value should be loaded during bootup
    def load_in_bootup?
      return @load_in_bootup
    end

    # @return [Boolean] whether the value has been loaded
    def loaded?
      return @loaded
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

    # @!group Configuration

    # Defines what is saved into save data. Requires a block.
    # @see SaveData.register
    def save_value(&block)
      raise ArgumentError, 'No block given to save_value' unless block_given?
      @save_proc = block
    end

    # Defines how the loaded value is placed into a global variable.
    # Requires a block with the loaded value as its parameter.
    # @see SaveData.register
    def load_value(&block)
      raise ArgumentError, 'No block given to load_value' unless block_given?
      @load_proc = block
    end

    # If present, sets the value to be loaded during bootup.
    # @see SaveData.register
    def load_in_bootup
      @load_in_bootup = true
    end

    # If present, defines what the value is set to at the start of a new game.
    # @see SaveData.register
    def new_game_value(&block)
      raise ArgumentError, 'No block given to new_game_value' unless block_given?
      @new_game_value_proc = block
    end

    # If present, ensures that the value's class's name is equal to that of
    # the passed parameter(s).
    # @param class_names [Symbol] class names for the accepted value
    # @note This method accepts multiple class names to ensure compatibility with renamed classes.
    # @see SaveData.register
    def ensure_class(*class_names)
      raise ArgumentError, 'No class names given to ensure_class' if class_names.empty?
      @ensured_class_names = class_names.map { |name| name.to_s }
    end

    # If present, defines how the value should be fetched from the pre-v19
    # save format. Requires a block with the old format array as its parameter.
    # @see SaveData.register
    def from_old_format(&block)
      raise ArgumentError, 'No block given to from_old_format' unless block_given?
      @old_format_get_proc = block
    end

    #@!endgroup
  end

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
  # @yieldself [Value]
  def self.register(id, &block)
    validate id => Symbol

    unless block_given?
      raise ArgumentError, 'No block given to SaveData.register'
    end

    @values[id] = Value.new(id, &block)
  end

  # @param save_data [Hash] save data to validate
  # @return [Boolean] whether the given save data is valid
  def self.valid?(save_data)
    validate save_data => Hash
    return @values.all? { |id, value| value.valid?(save_data[id]) }
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.compile
    save_data = {}
    @values.each { |id, data| save_data[id] = data.save }
    return save_data
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

  # Loads each value from the given save data that has
  # been set to be loaded during bootup.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load_bootup_values(save_data)
    validate save_data => Hash

    load_values(save_data) { |value| !value.loaded? && value.load_in_bootup? }
  end

  # Loads values from the given save data.
  # @param save_data [Hash] save data to load from
  # @param condition_block [Proc] optional condition
  # @api private
  def self.load_values(save_data, &condition_block)
    @values.each do |id, value|
      next if block_given? && !condition_block.call(value)
      if save_data.has_key?(id)
        value.load(save_data[id])
      elsif value.has_new_game_proc?
        value.load_new_game_value
      end
    end
  end

  # Loads a single value from the given save data.
  # @param id [Symbol] save value id
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  # @raise [ArgumentError] if given save data does not contain the value
  def self.load_value(id, save_data)
    validate id => Symbol, save_data => Hash

    unless save_data.has_key?(id)
      raise ArgumentError, "Save data does not contain value #{id.inspect}"
    end

    @values[id].load(save_data[id])
  end

  # Loads each {Value}'s new game value, if one is defined.
  def self.load_new_game_values
    @values.each_value do |value|
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end

  # Goes through each value with {Value#load_in_bootup} enabled and
  # loads their new game value, if one is defined.
  def self.initialize_bootup_values
    @values.each_value do |value|
      next unless value.load_in_bootup?
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end
end