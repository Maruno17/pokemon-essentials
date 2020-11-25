# The Game module contains methods for saving and loading the game.
module Game
  # Saves the game. Returns whether the operation was successful.
  # @return [Boolean] whether the operation was successful
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save
    return false unless File.writable?(SaveData::FILE_PATH)

    $game_system.save_count += 1
    begin
      SaveData.save_to_file(SaveData::FILE_PATH)
    rescue IOError, SystemCallError
      $game_system.save_count -= 1 # TODO: I feel like this is a bit of a hack. Remove?
      return false
    end

    return true
  end

  # Loads the game. Returns whether the operation was successful.
  # @return [Boolean] whether the operation was successful
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load
    return false unless File.readable?(SaveData::FILE_PATH)

    begin
      data = SaveData.load_from_file(SaveData::FILE_PATH)
    rescue IOError, SystemCallError
      return false
    end

    data = SaveData.to_hash_format(data) if data.is_a?(Array)
    # TODO: Handle save data conversion here
    SaveData.load_values(data)
    return true
  end
end
