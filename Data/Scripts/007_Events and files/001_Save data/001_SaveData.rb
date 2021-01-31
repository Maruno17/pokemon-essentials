# The SaveData module is used to access save data.
module SaveData
  # Contains the file path of the save file.
  FILE_PATH = if File.directory?(System.data_directory)
                System.data_directory + '/Game.rxdata'
              else
                './Game.rxdata'
              end

  # Contains Value objects for each save element.
  # Populated during runtime by SaveData.register calls.
  # @type [Hash{Symbol => Value}]
  @values = {}

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save_to_file(file_path)
    validate file_path => String

    save_data = self.compile

    File.open(file_path, 'wb') { |file| Marshal.dump(save_data, file) }
  end

  # Fetches save data from the given file.
  # @param file_path [String] path of the file to read from
  # @return [Hash] save data in Hash format
  # @raise (see .get_data_from_file)
  def self.read_from_file(file_path)
    validate file_path => String

    save_data = get_data_from_file(file_path)

    save_data = to_hash_format(save_data) if save_data.is_a?(Array)

    return save_data
  end

  # @return [Boolean] whether the save file exists
  def self.exists?
    return File.file?(FILE_PATH)
  end

  # @param save_data [Hash] save data to validate
  # @return [Boolean] whether the given save data is valid
  def self.valid?(save_data)
    validate save_data => Hash
    return @values.all? { |id, value| value.valid?(save_data[id]) }
  end

  # Deletes the save file (and a possible .bak backup file if one exists)
  # @raise [Error::ENOENT]
  def self.delete_file
    File.delete(FILE_PATH)
    File.delete(FILE_PATH + '.bak') if File.file?(FILE_PATH + '.bak')
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

  # Fetches the save data from the given file.
  # Returns an Array in the case of a pre-v19 save file.
  # @param file_path [String] path of the file to load from
  # @return [Hash, Array] loaded save data
  # @raise [IOError, SystemCallError] if file opening fails
  def self.get_data_from_file(file_path)
    validate file_path => String
    save_data = nil

    File.open(file_path) do |file|
      data = Marshal.load(file)

      if data.is_a?(Hash)
        save_data = data
        next
      end

      save_data = [data]

      save_data << Marshal.load(file) until file.eof?
    end

    return save_data
  end

  # Converts the pre-v19 format data to the new format.
  # @param old_format [Array] pre-v19 format save data
  # @return [Hash] save data in new format
  def self.to_hash_format(old_format)
    validate old_format => Array
    hash = {}

    @values.each do |id, value|
      data = value.get_from_old_format(old_format)
      hash[id] = data unless data.nil?
    end

    return hash
  end
end
