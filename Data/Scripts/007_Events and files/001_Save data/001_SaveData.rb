# The SaveData module is used to analyze and modify the save file.
module SaveData
  # Contains the file path of the save file.
  FILE_PATH = System.data_directory + '/Game.rxdata'

  # Contains {Value} objects for each save element.
  # Populated during runtime by {#register} calls.
  @values = {}

  module_function

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  # @raise [InvalidValueError] if an invalid value is being saved
  def save_to_file(file_path)
    validate file_path => String
    File.open(file_path, 'wb') { |file| Marshal.dump(self.compile, file) }
  end

  # Loads the save data from the given file and returns it.
  # Returns an Array in the case of a pre-v19 save file.
  # @param file_path [String] path of the file to load from
  # @return [Hash, Array] loaded save data
  def load_from_file(file_path)
    validate file_path => String
    save_data = nil

    File.open(file_path) do |file|
      data = Marshal.load(file)
      unless file.eof?
        save_data = [] if save_data.nil?
        save_data << data
      end
      if save_data.is_a?(Hash)
        save_data = data
      elsif file.eof?
        save_data << data
      end
    end

    return save_data
  end

  # @return [Boolean] whether the save file exists
  def exists?
    return File.file?(FILE_PATH)
  end

  # Registers a {Value} to be saved into save data.
  # Takes a block which defines the value's saving (+save_value+)
  # and loading (+load_value+) procedures, as well as a possible
  # proc for fetching the value from the pre-v19 format (+from_old_format+)
  # @param id [Symbol] value id
  # @yieldself [Value]
  def register(id, &block)
    unless block_given?
      raise ArgumentError, "No block given to save value #{id.inspect}"
    end
    validate id => Symbol
    @values[id] = Value.new(id, &block)
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  # @raise [InvalidValueError] if an invalid value is being saved
  def compile
    save_data = {}
    @values.each { |id, data| save_data[id] = data.save }
    return save_data
  end

  # Loads the values from the given save data by
  # calling each {Value} object's +load_value+ proc.
  # Values that are already loaded are skipped.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def load_values(save_data)
    validate save_data => Hash
    save_data.each do |id, value|
      @values[id].load(value) unless @values[id].loaded?
    end
  end

  # Loads a single value from the given save data.
  # @param id [Symbol] save value id
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  # @raise [ArgumentError] if given save data does not contain the value
  def load_value(id, save_data)
    validate id => Symbol, save_data => Hash

    unless save_data.has_key?(id)
      raise ArgumentError, "Save data does not contain value #{id.inspect}"
    end

    @values[id].load(save_data[id])
  end

  # Loads each {Value}'s new game value, if one is defined.
  def load_new_game_values
    @values.each_value do |value|
      value.load_new_game_value if value.has_new_game_proc?
    end
  end

  # Converts the pre-v19 format data to the new format.
  # @param old_format [Array] pre-v19 format save data
  # @return [Hash] save data in new format
  def to_hash_format(old_format)
    validate old_format => Array
    hash = {}

    @values.each do |id, value|
      data = value.get_from_old_format(old_format)
      hash[id] = data unless data.nil?
    end

    return hash
  end
end
