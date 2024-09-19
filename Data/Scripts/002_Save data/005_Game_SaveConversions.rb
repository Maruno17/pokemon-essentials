#===============================================================================
# Conversions required to support backwards compatibility with old save files
# (within reason).
#===============================================================================

SaveData.register_conversion(:v21_replace_phone_data) do
  essentials_version 21
  display_title "Updating Phone data format"
  to_value :global_metadata do |global|
    if !global.phone
      global.instance_eval do
        @phone = Phone.new
        @phoneTime = nil   # Don't bother using this
        if @phoneNumbers
          @phoneNumbers.each do |contact|
            if contact.length > 4
              # Trainer
              @phone.add(contact[6], contact[7], contact[1], contact[2], contact[5], 0)
              new_contact = @phone.get(contact[1], contact[2], 0)
              new_contact.visible = contact[0]
              new_contact.rematch_flag = [contact[4] - 1, 0].max
            else
              # Non-trainer
              @phone.add(contact[3], contact[2], contact[1])
            end
          end
          @phoneNumbers = nil
        end
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v21_replace_flute_booleans) do
  essentials_version 21
  display_title "Updating Black/White Flute variables"
  to_value :map_metadata do |metadata|
    metadata.instance_eval do
      if !@blackFluteUsed.nil?
        if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
          @higher_level_wild_pokemon = @blackFluteUsed
        else
          @lower_encounter_rate = @blackFluteUsed
        end
        @blackFluteUsed = nil
      end
      if !@whiteFluteUsed.nil?
        if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
          @lower_level_wild_pokemon = @whiteFluteUsed
        else
          @higher_encounter_rate = @whiteFluteUsed
        end
        @whiteFluteUsed = nil
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v21_add_bump_stat) do
  essentials_version 21
  display_title "Adding a bump stat"
  to_value :stats do |stats|
    stats.instance_eval do
      @bump_count = 0 if !@bump_count
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v22_add_new_stats) do
  essentials_version 22
  display_title "Adding some more stats"
  to_value :stats do |stats|
    stats.instance_eval do
      @wild_battles_fled = 0 if !@wild_battles_fled
      @pokemon_release_count = 0 if !@pokemon_release_count
      @primal_reversion_count = 0 if !@primal_reversion_count
    end
  end
end
