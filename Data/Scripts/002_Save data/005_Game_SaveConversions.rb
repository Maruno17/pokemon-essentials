#===============================================================================
# Conversions required to support backwards compatibility with old save files
# (within reason).
#===============================================================================

# Planted berries accidentally weren't converted in v19 to change their
# numerical IDs to symbolic IDs (for the berry planted and for mulch laid down).
# Since item numerical IDs no longer exist, this conversion needs to have a list
# of them in order to convert planted berry data properly.
SaveData.register_conversion(:v20_fix_planted_berry_numerical_ids) do
  essentials_version 20
  display_title "Fixing berry plant IDs data"
  to_value :global_metadata do |global|
    berry_conversion = {
      389 => :CHERIBERRY,
      390 => :CHESTOBERRY,
      391 => :PECHABERRY,
      392 => :RAWSTBERRY,
      393 => :ASPEARBERRY,
      394 => :LEPPABERRY,
      395 => :ORANBERRY,
      396 => :PERSIMBERRY,
      397 => :LUMBERRY,
      398 => :SITRUSBERRY,
      399 => :FIGYBERRY,
      400 => :WIKIBERRY,
      401 => :MAGOBERRY,
      402 => :AGUAVBERRY,
      403 => :IAPAPABERRY,
      404 => :RAZZBERRY,
      405 => :BLUKBERRY,
      406 => :NANABBERRY,
      407 => :WEPEARBERRY,
      408 => :PINAPBERRY,
      409 => :POMEGBERRY,
      410 => :KELPSYBERRY,
      411 => :QUALOTBERRY,
      412 => :HONDEWBERRY,
      413 => :GREPABERRY,
      414 => :TAMATOBERRY,
      415 => :CORNNBERRY,
      416 => :MAGOSTBERRY,
      417 => :RABUTABERRY,
      418 => :NOMELBERRY,
      419 => :SPELONBERRY,
      420 => :PAMTREBERRY,
      421 => :WATMELBERRY,
      422 => :DURINBERRY,
      423 => :BELUEBERRY,
      424 => :OCCABERRY,
      425 => :PASSHOBERRY,
      426 => :WACANBERRY,
      427 => :RINDOBERRY,
      428 => :YACHEBERRY,
      429 => :CHOPLEBERRY,
      430 => :KEBIABERRY,
      431 => :SHUCABERRY,
      432 => :COBABERRY,
      433 => :PAYAPABERRY,
      434 => :TANGABERRY,
      435 => :CHARTIBERRY,
      436 => :KASIBBERRY,
      437 => :HABANBERRY,
      438 => :COLBURBERRY,
      439 => :BABIRIBERRY,
      440 => :CHILANBERRY,
      441 => :LIECHIBERRY,
      442 => :GANLONBERRY,
      443 => :SALACBERRY,
      444 => :PETAYABERRY,
      445 => :APICOTBERRY,
      446 => :LANSATBERRY,
      447 => :STARFBERRY,
      448 => :ENIGMABERRY,
      449 => :MICLEBERRY,
      450 => :CUSTAPBERRY,
      451 => :JABOCABERRY,
      452 => :ROWAPBERRY
    }
    mulch_conversion = {
      59 => :GROWTHMULCH,
      60 => :DAMPMULCH,
      61 => :STABLEMULCH,
      62 => :GOOEYMULCH
    }
    global.eventvars.each_value do |var|
      next if !var || !var.is_a?(Array)
      next if var.length < 6 || var.length > 8   # Neither old nor new berry plant
      if !var[1].is_a?(Symbol)   # Planted berry item
        var[1] = berry_conversion[var[1]] || :ORANBERRY
      end
      if var[7] && !var[7].is_a?(Symbol)   # Mulch
        var[7] = mulch_conversion[var[7]]
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_refactor_planted_berries_data) do
  essentials_version 20
  display_title "Updating berry plant data format"
  to_value :global_metadata do |global|
    if global.eventvars
      global.eventvars.each_pair do |key, value|
        next if !value || !value.is_a?(Array)
        case value.length
        when 6   # Old berry plant data
          data = BerryPlantData.new
          if value[1].is_a?(Symbol)
            plant_data = GameData::BerryPlant.get(value[1])
            data.new_mechanics      = false
            data.berry_id           = value[1]
            data.time_alive         = value[0] * plant_data.hours_per_stage * 3600
            data.time_last_updated  = value[3]
            data.growth_stage       = value[0]
            data.replant_count      = value[5]
            data.watered_this_stage = value[2]
            data.watering_count     = value[4]
          end
          global.eventvars[key] = data
        when 7, 8   # New berry plant data
          data = BerryPlantData.new
          if value[1].is_a?(Symbol)
            data.new_mechanics     = true
            data.berry_id          = value[1]
            data.mulch_id          = value[7] if value[7].is_a?(Symbol)
            data.time_alive        = value[2]
            data.time_last_updated = value[3]
            data.growth_stage      = value[0]
            data.replant_count     = value[5]
            data.moisture_level    = value[4]
            data.yield_penalty     = value[6]
          end
          global.eventvars[key] = data
        end
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_refactor_follower_data) do
  essentials_version 20
  display_title "Updating follower data format"
  to_value :global_metadata do |global|
    # NOTE: dependentEvents is still defined in class PokemonGlobalMetadata just
    #       for the sake of this conversion. It will be removed in future.
    if global.dependentEvents && global.dependentEvents.length > 0
      global.followers = []
      global.dependentEvents.each do |follower|
        data = FollowerData.new(follower[0], follower[1], "reflection",
                                follower[2], follower[3], follower[4],
                                follower[5], follower[6], follower[7])
        data.name            = follower[8]
        data.common_event_id = follower[9]
        global.followers.push(data)
      end
    end
    global.dependentEvents = nil
  end
end

#===============================================================================

SaveData.register_conversion(:v20_refactor_day_care_variables) do
  essentials_version 20
  display_title "Refactoring Day Care variables"
  to_value :global_metadata do |global|
    global.instance_eval do
      @day_care = DayCare.new if @day_care.nil?
      if !@daycare.nil?
        @daycare.each do |old_slot|
          if !old_slot[0]
            old_slot[0] = Pokemon.new(:MANAPHY, 50)
            old_slot[1] = 4
          end
          next if !old_slot[0]
          @day_care.slots.each do |slot|
            next if slot.filled?
            slot.instance_eval do
              @pokemon = old_slot[0]
              @initial_level = old_slot[1]
              if @pokemon && @pokemon.markings.is_a?(Integer)
                markings = []
                6.times { |i| markings[i] = ((@pokemon.markings & (1 << i)) == 0) ? 0 : 1 }
                @pokemon.markings = markings
              end
            end
          end
        end
        @day_care.egg_generated = ((@daycareEgg.is_a?(Numeric) && @daycareEgg > 0) || @daycareEgg == true)
        @day_care.step_counter = @daycareEggSteps
        @daycare = nil
        @daycareEgg = nil
        @daycareEggSteps = nil
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_rename_bag_variables) do
  essentials_version 20
  display_title "Renaming Bag variables"
  to_value :bag do |bag|
    bag.instance_eval do
      if !@lastpocket.nil?
        @last_viewed_pocket = @lastpocket
        @lastPocket = nil
      end
      if !@choices.nil?
        @last_pocket_selections = @choices.clone
        @choices = nil
      end
      if !@registeredItems.nil?
        @registered_items = @registeredItems || []
        @registeredItems = nil
      end
      if !@registeredIndex.nil?
        @ready_menu_selection = @registeredIndex || [0, 0, 1]
        @registeredIndex = nil
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_increment_player_character_id) do
  essentials_version 20
  display_title "Incrementing player character ID"
  to_value :player do |player|
    player.character_ID += 1
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_pokedex_records) do
  essentials_version 20
  display_title "Adding more Pokédex records"
  to_value :player do |player|
    player.pokedex.instance_eval do
      @caught_counts = {} if @caught_counts.nil?
      @defeated_counts = {} if @defeated_counts.nil?
      @seen_eggs = {} if @seen_eggs.nil?
      @seen_forms.each_value do |sp|
        next if !sp || sp[0][0].is_a?(Array)   # Already converted to include shininess
        sp[0] = [sp[0], []]
        sp[1] = [sp[1], []]
      end
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_new_default_options) do
  essentials_version 20
  display_title "Updating Options to include new settings"
  to_value :pokemon_system do |option|
    option.givenicknames = 0 if option.givenicknames.nil?
    option.sendtoboxes = 0 if option.sendtoboxes.nil?
  end
end

#===============================================================================

SaveData.register_conversion(:v20_fix_default_weather_type) do
  essentials_version 20
  display_title "Fixing weather type 0 in effect"
  to_value :game_screen do |game_screen|
    game_screen.instance_eval do
      @weather_type = :None if @weather_type == 0
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_add_stats) do
  essentials_version 20
  display_title "Adding stats to save data"
  to_all do |save_data|
    unless save_data.has_key?(:stats)
      save_data[:stats] = GameStats.new
      save_data[:stats].play_time = save_data[:frame_count].to_f / Graphics.frame_rate
      save_data[:stats].play_sessions = 1
      save_data[:stats].time_last_saved = save_data[:stats].play_time
    end
  end
end

#===============================================================================

SaveData.register_conversion(:v20_convert_pokemon_markings) do
  essentials_version 20
  display_title "Updating format of Pokémon markings"
  to_all do |save_data|
    # Create a lambda function that updates a Pokémon's markings
    update_markings = lambda do |pkmn|
      return if !pkmn || !pkmn.markings.is_a?(Integer)
      markings = []
      6.times { |i| markings[i] = ((pkmn.markings & (1 << i)) == 0) ? 0 : 1 }
      pkmn.markings = markings
    end
    # Party Pokémon
    save_data[:player].party.each { |pkmn| update_markings.call(pkmn) }
    # Pokémon storage
    save_data[:storage_system].boxes.each do |box|
      box.pokemon.each { |pkmn| update_markings.call(pkmn) if pkmn }
    end
    # NOTE: Pokémon in the Day Care have their markings converted above.
    # Partner trainer
    if save_data[:global_metadata].partner
      save_data[:global_metadata].partner[3].each { |pkmn| update_markings.call(pkmn) }
    end
    # Roaming Pokémon
    if save_data[:global_metadata].roamPokemon
      save_data[:global_metadata].roamPokemon.each { |pkmn| update_markings.call(pkmn) }
    end
    # Purify Chamber
    save_data[:global_metadata].purifyChamber.sets.each do |set|
      set.list.each { |pkmn| update_markings.call(pkmn) }
      update_markings.call(set.shadow) if set.shadow
    end
    # Hall of Fame records
    if save_data[:global_metadata].hallOfFame
      save_data[:global_metadata].hallOfFame.each do |team|
        next if !team
        team.each { |pkmn| update_markings.call(pkmn) }
      end
    end
    # Pokémon stored in Game Variables for some reason
    variables = save_data[:variables]
    (0..5000).each do |i|
      value = variables[i]
      case value
      when Array
        value.each { |value2| update_markings.call(value2) if value2.is_a?(Pokemon) }
      when Pokemon
        update_markings.call(value)
      end
    end
  end
end
