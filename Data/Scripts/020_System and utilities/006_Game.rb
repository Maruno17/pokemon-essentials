# The Game module contains methods for saving and loading the game.
module Game
  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path ({SaveData::FILE_PATH} by default)
  # @return [Boolean] whether the operation was successful
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save(save_file = SaveData::FILE_PATH)
    return false unless File.writable?(save_file)

    $game_system.save_count += 1
    begin
      SaveData.save_to_file(save_file)
    rescue IOError, SystemCallError
      $game_system.save_count -= 1 # TODO: I feel like this is a bit of a hack. Remove?
      return false
    end

    return true
  end

  # Loads the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path ({SaveData::FILE_PATH} by default)
  # @return [Boolean] whether the operation was successful
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load(save_file = SaveData::FILE_PATH)
    return false unless File.readable?(save_file)

    begin
      data = SaveData.load_from_file(save_file)
    rescue IOError, SystemCallError
      return false
    end

    data = SaveData.to_hash_format(data) if data.is_a?(Array)
    # TODO: Handle save data conversion here
    SaveData.load_values(data)
    return true
  end
end
