# The Game module contains methods for saving and loading the game.
module Game
  # Saves the game. Returns whether the operation was successful.
  # @return [Boolean] whether the operation was successful
  def self.save
    $game_system.save_count += 1 # FIXME: Right now, the save count is incremented even if saving fails
    begin
      SaveData.save_to_file(SaveData::FILE_PATH)
    rescue IOError, SystemCallError
      return false
    end
    return true
  end

  # Loads the game. Returns whether the operation was successful.
  # @return [Boolean] whether the operation was successful
  def self.load
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
