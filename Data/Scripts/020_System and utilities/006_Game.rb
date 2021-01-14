# The Game module contains methods for saving and loading the game.
module Game
  def self.initialize
    $PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_system   = Game_System.new
    $data_system   = pbLoadRxData('Data/System')
    $PokemonSystem = PokemonSystem.new if $PokemonSystem.nil?

    map_file = format('Data/Map%03d.rxdata', $data_system.start_map_id)

    if $data_system.start_map_id == 0 || !pbRgssExists?(map_file)
      raise _INTL('No starting position was set in the map editor.')
    end
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path ({SaveData::FILE_PATH} by default)
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(save_file = SaveData::FILE_PATH)
    return false unless File.writable?(save_file)

    $game_system.save_count += 1
    begin
      SaveData.save_to_file(save_file)
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end

    return true
  end

  # Loads the game from the given save data and starts the map scene.
  # @param save_data [Hash] hash containing the save data
  # @raise [SaveData::InvalidValueError] if an invalid value is being loaded
  def self.load(save_data)
    SaveData.load_values(save_data)
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
  end

  def self.start_new
    if $game_map && $game_map.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $PokemonTemp.begunNewGame = true
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $game_map.autoplay
    $game_map.update
  end
end
