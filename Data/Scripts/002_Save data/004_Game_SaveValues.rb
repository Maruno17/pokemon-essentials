# Contains the save values defined in Essentials by default.

SaveData.register(:player) do
  ensure_class :Player
  save_value { $player }
  load_value { |value| $player = $Trainer = value }
  new_game_value {
    # Get the first defined trainer type as a placeholder
    trainer_type = GameData::TrainerType.keys.first
    Player.new("Unnamed", trainer_type)
  }
  from_old_format { |old_format| old_format[0] }
end

SaveData.register(:frame_count) do
  ensure_class :Integer
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
  new_game_value { 0 }
  from_old_format { |old_format| old_format[1] }
end

SaveData.register(:game_system) do
  load_in_bootup
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
  new_game_value { Game_System.new }
  from_old_format { |old_format| old_format[2] }
end

SaveData.register(:pokemon_system) do
  load_in_bootup
  ensure_class :PokemonSystem
  save_value { $PokemonSystem }
  load_value { |value| $PokemonSystem = value }
  new_game_value { PokemonSystem.new }
  from_old_format { |old_format| old_format[3] }
end

SaveData.register(:switches) do
  ensure_class :Game_Switches
  save_value { $game_switches }
  load_value { |value| $game_switches = value }
  new_game_value { Game_Switches.new }
  from_old_format { |old_format| old_format[5] }
end

SaveData.register(:variables) do
  ensure_class :Game_Variables
  save_value { $game_variables }
  load_value { |value| $game_variables = value }
  new_game_value { Game_Variables.new }
  from_old_format { |old_format| old_format[6] }
end

SaveData.register(:self_switches) do
  ensure_class :Game_SelfSwitches
  save_value { $game_self_switches }
  load_value { |value| $game_self_switches = value }
  new_game_value { Game_SelfSwitches.new }
  from_old_format { |old_format| old_format[7] }
end

SaveData.register(:game_screen) do
  ensure_class :Game_Screen
  save_value { $game_screen }
  load_value { |value| $game_screen = value }
  new_game_value { Game_Screen.new }
  from_old_format { |old_format| old_format[8] }
end

SaveData.register(:map_factory) do
  ensure_class :PokemonMapFactory
  save_value { $map_factory }
  load_value { |value| $map_factory = $MapFactory = value }
  from_old_format { |old_format| old_format[9] }
end

SaveData.register(:game_player) do
  ensure_class :Game_Player
  save_value { $game_player }
  load_value { |value| $game_player = value }
  new_game_value { Game_Player.new }
  from_old_format { |old_format| old_format[10] }
end

SaveData.register(:global_metadata) do
  ensure_class :PokemonGlobalMetadata
  save_value { $PokemonGlobal }
  load_value { |value| $PokemonGlobal = value }
  new_game_value { PokemonGlobalMetadata.new }
  from_old_format { |old_format| old_format[11] }
end

SaveData.register(:map_metadata) do
  ensure_class :PokemonMapMetadata
  save_value { $PokemonMap }
  load_value { |value| $PokemonMap = value }
  new_game_value { PokemonMapMetadata.new }
  from_old_format { |old_format| old_format[12] }
end

SaveData.register(:bag) do
  ensure_class :PokemonBag
  save_value { $bag }
  load_value { |value| $bag = $PokemonBag = value }
  new_game_value { PokemonBag.new }
  from_old_format { |old_format| old_format[13] }
end

SaveData.register(:storage_system) do
  ensure_class :PokemonStorage
  save_value { $PokemonStorage }
  load_value { |value| $PokemonStorage = value }
  new_game_value { PokemonStorage.new }
  from_old_format { |old_format| old_format[14] }
end

SaveData.register(:essentials_version) do
  load_in_bootup
  ensure_class :String
  save_value { Essentials::VERSION }
  load_value { |value| $save_engine_version = value }
  new_game_value { Essentials::VERSION }
  from_old_format { |old_format| old_format[15] }
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
end
