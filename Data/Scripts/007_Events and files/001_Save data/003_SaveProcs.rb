SaveData.register(:player) do
  ensure_class :PokeBattle_Trainer
  save_value { $Trainer }
  load_value { |value| $Trainer = value }
end

SaveData.register(:frame_count) do
  ensure_class :Integer
  save_value { Graphics.frame_count }
  load_value { |value| Graphics.frame_count = value }
end

SaveData.register(:game_system) do
  ensure_class :Game_System
  save_value { $game_system }
  load_value { |value| $game_system = value }
end
