# Contains conversions defined by default in Essentials.

SaveData.register_conversion(:define_versions) do
  essentials_version 19
  title _INTL('Defining versions in save data')
  to_all do |save_data|
    unless save_data.has_key?(:essentials_version)
      save_data[:essentials_version] = Essentials::VERSION
    end
    unless save_data.has_key?(:game_version)
      save_data[:game_version] = Settings::GAME_VERSION
    end
  end
end

SaveData.register_conversion(:convert_player) do
  essentials_version 19
  title _INTL('Converting player trainer')
  to_all do |save_data|
    next if save_data[:player].is_a?(PlayerTrainer)
    # Conversion of the party is handled in the copy method
    save_data[:player] = PokeBattle_Trainer.copy(save_data[:player])
  end
end

SaveData.register_conversion(:convert_pokemon) do
  essentials_version 19
  title _INTL('Converting Pokémon in storage')
  to_value :storage_system do |storage|
    storage.instance_eval do
      for box in 0...self.maxBoxes
        for i in 0...self.maxPokemon(box)
          next unless self[box, i]
          next if self[box, i].is_a?(Pokemon)
          self[box, i] = PokeBattle_Pokemon.copy(self[box, i])
        end
      end
    end
  end
end
