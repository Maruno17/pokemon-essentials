# Contains the save values defined by default in Essentials.

# TODO: Do additional work (like setting up the map interpreter or initializing $PokemonEncounters)
#   inside the load_value procs

# TODO: Figure out how to handle the magic number and safesave stuff (what does the magic number even do?)

SaveData.register(:player) do
  ensure_class :PokeBattle_Trainer
  save_value { $Trainer }
  load_value { |value| $Trainer = value }
  from_old_format { |old_format| old_format[0] }
end

SaveData.register(:frame_count) do
  ensure_class :Integer
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
  from_old_format { |old_format| old_format[1] }
end

SaveData.register(:game_system) do
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
  from_old_format { |old_format| old_format[2] }
end

SaveData.register(:pokemon_system) do
  ensure_class :PokemonSystem
  save_value { $PokemonSystem }
  load_value { |value| $PokemonSystem = value }
  from_old_format { |old_format| old_format[3] }
end

# saving the map_id may be unnecessary, since all data is loaded at once, including $MapFactory
SaveData.register(:map_id) do
  ensure_class :Integer
  save_value { $game_map.map_id }
  load_value { |value| nil } # TODO: Figure out how to deal with the map id (or whether to deal with it at all)
  from_old_format { |old_format| old_format[4] }
end

SaveData.register(:switches) do
  ensure_class :Game_Switches
  save_value { $game_switches }
  load_value { |value| $game_switches = value }
  from_old_format { |old_format| old_format[5] }
end

SaveData.register(:variables) do
  ensure_class :Game_Variables
  save_value { $game_variables }
  load_value { |value| $game_variables = value }
  from_old_format { |old_format| old_format[6] }
end

SaveData.register(:self_switches) do
  ensure_class :Game_SelfSwitches
  save_value { $game_self_switches }
  load_value { |value| $game_self_switches = value }
  from_old_format { |old_format| old_format[7] }
end

SaveData.register(:game_screen) do
  ensure_class :Game_Screen
  save_value { $game_screen }
  load_value { |value| $game_screen = value }
  from_old_format { |old_format| old_format[8] }
end

SaveData.register(:map_factory) do
  ensure_class :PokemonMapFactory
  save_value { $MapFactory }
  load_value do |value|
    $MapFactory = value
    $game_map = $MapFactory.map
  end
  from_old_format { |old_format| old_format[9] }
end

SaveData.register(:game_player) do
  ensure_class :Game_Player
  save_value { $game_player }
  load_value { |value| $game_player = value }
  from_old_format { |old_format| old_format[10] }
end

SaveData.register(:global_metadata) do
  ensure_class :PokemonGlobalMetadata
  save_value { $PokemonGlobal }
  load_value { |value| $PokemonGlobal = value }
  from_old_format { |old_format| old_format[11] }
end

SaveData.register(:map_metadata) do
  ensure_class :PokemonMapMetadata
  save_value { $PokemonMap }
  load_value { |value| $PokemonMap = value }
  from_old_format { |old_format| old_format[12] }
end

SaveData.register(:bag) do
  ensure_class :PokemonBag
  save_value { $PokemonBag }
  load_value { |value| $PokemonBag = value }
  from_old_format { |old_format| old_format[13] }
end

SaveData.register(:storage_system) do
  ensure_class :PokemonStorage
  save_value { $PokemonStorage }
  load_value { |value| $PokemonStorage = value }
  from_old_format { |old_format| old_format[14] }
end

SaveData.register(:essentials_version) do
  ensure_class :String
  save_value { $SaveVersion }
  load_value { |value| $SaveVersion = value }
  from_old_format { |old_format| old_format[15] }
end
