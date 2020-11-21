# Contains the save values defined by default in Essentials.

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

SaveData.register(:map_id) do
  ensure_class :Integer
  save_value { $game_map.map_id }
  load_value { |value| nil } # TODO: Figure out how to deal with the map id
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

# TODO: Add the rest of the procs
