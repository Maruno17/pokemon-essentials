# The SaveData module is used to analyze and modify the save file.
module SaveData
  # Contains the file path of the save file.
  # TODO: This should be changed at some point, as RTP.getSaveFileName uses Win32API.
  #   mkxp-z introduces System.data_directory, maybe use that later?
  FILE_PATH = RTP.getSaveFileName('Game.rxdata')

  # Contains {SavedValue} objects for each save element.
  # Populated during runtime by {#register} calls.
  @schema = {}

  module_function

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
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
      if save_data.is_a?(Array)
        save_data.push(data)
      else
        save_data = data
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
  # proc for fetching the value from the pre-v19 format (+get_from_legacy+)
  # @param id [Symbol] value id
  def register(id, &block)
    unless block_given?
      raise ArgumentError, "No block given to save value #{id.inspect}"
    end
    validate id => Symbol
    @schema[id] = Value.new(id, &block)
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  def compile
    save_data = {}
    @schema.each do |id, data|
      save_data[id] = data.save
    end
    return save_data
  end

  # Loads the values from the given save data into memory by
  # calling each {SavedValue} object's +load_value+ proc.
  # @param save_data [Hash] save data to load
  def load_values(save_data)
    validate save_data => Hash
    save_data.each do |id, value|
      @schema[id].load(value)
    end
  end

  # Loads the values from the given pre-v19 format save data.
  # @param old_format [Array] pre-v19 format save data
  def load_values_from_legacy(old_format)
    validate old_format => Array
    @schema.each do |value|
      value.load_from_legacy(old_format)
    end
  end
end
