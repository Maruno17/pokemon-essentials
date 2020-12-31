# The SaveData module is used to analyze and modify the save file.

# TODO: Currently, values loaded using load_value are loaded again when
#   load_values is called. A more robust system should be built instead.
#   Maybe a "load_on_bootup" class method for flagging values to be
#   loaded on bootup automatically. Examples of values that need this
#   are :trainer, :pokemon_system etc.

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

  # Registers a value to be saved into save data.
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

  # Loads the values from the given save data into memory by
  # calling each {Value} object's +load_value+ proc.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def load_values(save_data)
    validate save_data => Hash
    save_data.each do |id, value|
      @values[id].load(value)
    end
  end

  # Loads a single value from the given save data into memory.
  # @param id [Symbol] save value id
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def load_value(id, save_data)
    validate id => Symbol, save_data => Hash
    @values[id].load(save_data[id])
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
