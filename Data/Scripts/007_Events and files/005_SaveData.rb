# The SaveData module is used to analyze and modify the save file.
module SaveData
  # Contains the file path of the save file.
  # TODO: This should be changed at some point, as RTP.getSaveFileName uses Win32API.
  #   mkxp-z introduces System.data_directory, maybe use that later?
  FILE_PATH = RTP.getSaveFileName("Game.rxdata")

  module_function

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  def save_to_file(file_path)
    File.open(file, "wb") { |file| Marshal.dump(self.compile, file) }
  end

  # Loads the save data from the given file and returns it.
  # @param file_path [String] path of the file to load from
  # @return [Hash] loaded save data
  def load_from_file(file_path)
    save_data = nil
    File.open(file_path) { |file| save_data = Marshal.load(file) }
    return save_data
  end

  # @return [Boolean] whether the save file exists
  def exists?
    return File.file?(FILE_PATH)
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  def compile
    return {
      :player             => $Trainer,
      :frame_count        => Graphics.frame_count,
      :game_system        => $game_system,
      :pokemon_system     => $PokemonSystem,
      :map_id             => $game_map.map_id,
      :switches           => $game_switches,
      :variables          => $game_variables,
      :self_switches      => $game_self_switches,
      :game_screen        => $game_screen,
      :map_factory        => $MapFactory,
      :game_player        => $game_player,
      :pokemon_global     => $PokemonGlobal,
      :pokemon_map        => $PokemonMap,
      :bag                => $PokemonBag,
      :storage            => $PokemonStorage,
      :essentials_version => ESSENTIALS_VERSION
    }
  end
end
