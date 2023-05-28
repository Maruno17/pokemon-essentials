# Contains the save values defined in Essentials by default.

SaveData.register(:player) do
  ensure_class :Player
  save_value { $player }
  load_value { |value| $player = value }
  new_game_value { Player.new("Unnamed", GameData::TrainerType.keys.first) }
end

# @deprecated This save data is slated to be removed in v22, as its use is
# replaced by $stats.play_time.
SaveData.register(:frame_count) do
  ensure_class :Integer
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
  new_game_value { 0 }
end

SaveData.register(:game_system) do
  load_in_bootup
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
  new_game_value { Game_System.new }
end

SaveData.register(:pokemon_system) do
  load_in_bootup
  ensure_class :PokemonSystem
  save_value { $PokemonSystem }
  load_value { |value| $PokemonSystem = value }
  new_game_value { PokemonSystem.new }
end

SaveData.register(:switches) do
  ensure_class :Game_Switches
  save_value { $game_switches }
  load_value { |value| $game_switches = value }
  new_game_value { Game_Switches.new }
end

SaveData.register(:variables) do
  ensure_class :Game_Variables
  save_value { $game_variables }
  load_value { |value| $game_variables = value }
  new_game_value { Game_Variables.new }
end

SaveData.register(:self_switches) do
  ensure_class :Game_SelfSwitches
  save_value { $game_self_switches }
  load_value { |value| $game_self_switches = value }
  new_game_value { Game_SelfSwitches.new }
end

SaveData.register(:game_screen) do
  ensure_class :Game_Screen
  save_value { $game_screen }
  load_value { |value| $game_screen = value }
  new_game_value { Game_Screen.new }
end

SaveData.register(:map_factory) do
  ensure_class :PokemonMapFactory
  save_value { $map_factory }
  load_value { |value| $map_factory = value }
end

SaveData.register(:game_player) do
  ensure_class :Game_Player
  save_value { $game_player }
  load_value { |value| $game_player = value }
  new_game_value { Game_Player.new }
end

SaveData.register(:global_metadata) do
  ensure_class :PokemonGlobalMetadata
  save_value { $PokemonGlobal }
  load_value { |value| $PokemonGlobal = value }
  new_game_value { PokemonGlobalMetadata.new }
end

SaveData.register(:map_metadata) do
  ensure_class :PokemonMapMetadata
  save_value { $PokemonMap }
  load_value { |value| $PokemonMap = value }
  new_game_value { PokemonMapMetadata.new }
end

SaveData.register(:bag) do
  ensure_class :PokemonBag
  save_value { $bag }
  load_value { |value| $bag = value }
  new_game_value { PokemonBag.new }
end

SaveData.register(:storage_system) do
  ensure_class :PokemonStorage
  save_value { $PokemonStorage }
  load_value { |value| $PokemonStorage = value }
  new_game_value { PokemonStorage.new }
end

SaveData.register(:essentials_version) do
  load_in_bootup
  ensure_class :String
  save_value { Essentials::VERSION }
  load_value { |value| $save_engine_version = value }
  new_game_value { Essentials::VERSION }
end

SaveData.register(:game_version) do
  load_in_bootup
  ensure_class :String
  save_value { Settings::GAME_VERSION }
  load_value { |value| $save_game_version = value }
  new_game_value { Settings::GAME_VERSION }
end

SaveData.register(:stats) do
  load_in_bootup
  ensure_class :GameStats
  save_value { $stats }
  load_value { |value| $stats = value }
  new_game_value { GameStats.new }
  reset_on_new_game
end
