# The Game module contains methods for saving and loading the game.
module Game
  # Initializes various global variables and loads the game data.
  def self.initialize
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    pbLoadBattleAnimations
    GameData.load_all
    map_file = sprintf("Data/Map%03d.rxdata", $data_system.start_map_id)
    if $data_system.start_map_id == 0 || !pbRgssExists?(map_file)
      raise _INTL("No starting position was set in the map editor.")
    end
  end

  # Loads bootup data from save file (if it exists) or creates bootup data (if
  # it doesn't).
  def self.set_up_system
    save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH) : {}
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if !Settings::LANGUAGES.empty?
      $PokemonSystem.language = pbChooseLanguage if save_data.empty? && Settings::LANGUAGES.length >= 2
      MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
    end
  end

  # Called when starting a new game. Initializes global variables
  # and transfers the player into the map scene.
  def self.start_new
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $game_temp.last_uptime_refreshed_play_time = System.uptime
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end

  # Loads the game from the given save data and starts the map scene.
  # @param save_data [Hash] hash containing the save data
  # @raise [SaveData::InvalidValueError] if an invalid value is being loaded
  def self.load(save_data)
    validate save_data => Hash
    SaveData.load_all_values(save_data)
    $game_temp.last_uptime_refreshed_play_time = System.uptime
    $stats.play_sessions += 1
    self.load_map
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
  end

  # Loads and validates the map. Called when loading a saved game.
  def self.load_map
    $game_map = $map_factory.map
    magic_number_matches = ($game_system.magic_number == $data_system.magic_number)
    if !magic_number_matches || $PokemonGlobal.safesave
      pbMapInterpreter.setup(nil, 0) if pbMapInterpreterRunning?
      begin
        $map_factory.setup($game_map.map_id)
      rescue Errno::ENOENT
        if $DEBUG
          pbMessage(_INTL("Map {1} was not found.", $game_map.map_id))
          map = pbWarpToMap
          exit unless map
          $map_factory.setup(map[0])
          $game_player.moveto(map[1], map[2])
        else
          raise _INTL("The map was not found. The game cannot continue.")
        end
      end
      $game_player.center($game_player.x, $game_player.y)
    else
      $map_factory.setMapChanged($game_map.map_id)
    end
    if $game_map.events.nil?
      raise _INTL("The map is corrupt. The game cannot continue.")
    end
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbUpdateVehicle
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(save_file = SaveData::FILE_PATH, safe: false)
    validate save_file => String, safe => [TrueClass, FalseClass]
    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    $stats.set_time_last_saved
    begin
      SaveData.save_to_file(save_file)
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end
end
