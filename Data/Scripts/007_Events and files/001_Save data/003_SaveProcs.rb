# Contains the save values defined by default in Essentials.

SaveData.register(:player) do
  ensure_class :PokeBattle_Trainer
  save_value { $Trainer }
  load_value { |value| $Trainer = value }
  get_from_legacy { |old_format| old_format[0] }
end

SaveData.register(:frame_count) do
  ensure_class :Integer
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
  get_from_legacy { |old_format| old_format[1] }
end

SaveData.register(:game_system) do
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
  get_from_legacy { |old_format| old_format[2] }
end
