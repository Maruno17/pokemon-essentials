# Contains conversions defined in Essentials by default.

SaveData.register_conversion(:v19_define_versions) do
  essentials_version 19
  display_title 'Adding game version and Essentials version to save data'
  to_all do |save_data|
    unless save_data.has_key?(:essentials_version)
      save_data[:essentials_version] = Essentials::VERSION
    end
    unless save_data.has_key?(:game_version)
      save_data[:game_version] = Settings::GAME_VERSION
    end
  end
end

SaveData.register_conversion(:v19_convert_player) do
  essentials_version 19
  display_title 'Converting player trainer class'
  to_all do |save_data|
    next if save_data[:player].is_a?(PlayerTrainer)
    # Conversion of the party is handled in PokeBattle_Trainer.copy
    save_data[:player] = PokeBattle_Trainer.copy(save_data[:player])
  end
end

SaveData.register_conversion(:v19_convert_storage) do
  essentials_version 19
  display_title 'Converting classes of Pokémon in storage'
  to_value :storage_system do |storage|
    storage.instance_eval do
      for box in 0...self.maxBoxes
        for i in 0...self.maxPokemon(box)
          next unless self[box, i]
          next if self[box, i].is_a?(Pokemon)
          self[box, i] = PokeBattle_Pokemon.copy(self[box, i])
        end
      end
    end # storage.instance_eval
  end # to_value
end

SaveData.register_conversion(:v19_convert_bag) do
  essentials_version 19
  display_title 'Converting item IDs in Bag'
  to_value :bag do |bag|
    bag.instance_eval do
      for pocket in self.pockets
        for item in pocket
          next if !item || !item[0] || item[0] == 0
          item_data = GameData::Item.try_get(item[0])
          item[0] = item_data.id if item_data
        end
      end
    end # bag.instance_eval
  end # to_value
end

SaveData.register_conversion(:v19_convert_global_metadata) do
  essentials_version 19
  display_title 'Adding encounter version variable to global metadata'
  to_value :global_metadata do |global|
    global.encounter_version ||= 0
  end
end
