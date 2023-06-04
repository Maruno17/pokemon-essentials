module Compiler
  module_function

  def compile_PBS_file_generic(game_data, *paths)
    if game_data.const_defined?(:OPTIONAL) && game_data::OPTIONAL
      return if paths.none? { |p| FileTest.exist?(p) }
    end
    game_data::DATA.clear
    schema = game_data.schema
    # Read from PBS file(s)
    paths.each do |path|
      compile_pbs_file_message_start(path)
      base_filename = game_data::PBS_BASE_FILENAME
      base_filename = base_filename[0] if base_filename.is_a?(Array)   # For Species
      file_suffix = File.basename(path, ".txt")[base_filename.length + 1, path.length] || ""
      File.open(path, "rb") do |f|
        FileLineData.file = path   # For error reporting
        # Read a whole section's lines at once, then run through this code.
        # contents is a hash containing all the XXX=YYY lines in that section, where
        # the keys are the XXX and the values are the YYY (as unprocessed strings).
        idx = 0
        pbEachFileSection(f, schema) do |contents, section_name|
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          data_hash = {
            :id              => section_name.to_sym,
            :pbs_file_suffix => file_suffix
          }
          # Go through schema hash of compilable data and compile this section
          schema.each_key do |key|
            FileLineData.setSection(section_name, key, contents[key])   # For error reporting
            if key == "SectionName"
              data_hash[schema[key][0]] = get_csv_record(section_name, schema[key])
              next
            end
            # Skip empty properties
            next if contents[key].nil?
            # Compile value for key
            if schema[key][1][0] == "^"
              contents[key].each do |val|
                value = get_csv_record(val, schema[key])
                value = nil if value.is_a?(Array) && value.empty?
                data_hash[schema[key][0]] ||= []
                data_hash[schema[key][0]].push(value)
              end
              data_hash[schema[key][0]].compact!
            else
              value = get_csv_record(contents[key], schema[key])
              value = nil if value.is_a?(Array) && value.empty?
              data_hash[schema[key][0]] = value
            end
          end
          # Validate and modify the compiled data
          yield false, data_hash if block_given?
          if game_data.exists?(data_hash[:id])
            raise _INTL("Section name '{1}' is used twice.\n{2}", data_hash[:id], FileLineData.linereport)
          end
          # Add section's data to records
          game_data.register(data_hash)
        end
      end
      process_pbs_file_message_end
    end
    yield true, nil if block_given?
    # Save all data
    game_data.save
  end

  #=============================================================================
  # Compile Town Map data
  #=============================================================================
  def compile_town_map(*paths)
    compile_PBS_file_generic(GameData::TownMap, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_town_maps : validate_compiled_town_map(hash)
    end
  end

  def validate_compiled_town_map(hash)
  end

  def validate_all_compiled_town_maps
    # Get town map names and descriptions for translating
    region_names = []
    point_names = []
    interest_names = []
    GameData::TownMap.each do |town_map|
      region_names[town_map.id] = town_map.real_name
      town_map.point.each do |point|
        point_names.push(point[2])
        interest_names.push(point[3])
      end
    end
    point_names.uniq!
    interest_names.uniq!
    MessageTypes.setMessagesAsHash(MessageTypes::REGION_NAMES, region_names)
    MessageTypes.setMessagesAsHash(MessageTypes::REGION_LOCATION_NAMES, point_names)
    MessageTypes.setMessagesAsHash(MessageTypes::REGION_LOCATION_DESCRIPTIONS, interest_names)
  end

  #=============================================================================
  # Compile map connections
  #=============================================================================
  def compile_connections(*paths)
    hashenum = {
      "N" => "N", "North" => "N",
      "E" => "E", "East"  => "E",
      "S" => "S", "South" => "S",
      "W" => "W", "West"  => "W"
    }
    schema = [nil, "iyiiyi", nil, hashenum, nil, nil, hashenum]
    records = []
    paths.each do |path|
      compile_pbs_file_message_start(path)
      pbCompilerEachPreppedLine(path) do |line, lineno|
        FileLineData.setLine(line, lineno)
        record = get_csv_record(line, schema)
        if !pbRgssExists?(sprintf("Data/Map%03d.rxdata", record[0]))
          print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\n{2}", record[0], FileLineData.linereport)
        elsif !pbRgssExists?(sprintf("Data/Map%03d.rxdata", record[3]))
          print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\n{2}", record[3], FileLineData.linereport)
        end
        case record[1]
        when "N"
          raise _INTL("North side of first map must connect with south side of second map\n{1}", FileLineData.linereport) if record[4] != "S"
        when "S"
          raise _INTL("South side of first map must connect with north side of second map\n{1}", FileLineData.linereport) if record[4] != "N"
        when "E"
          raise _INTL("East side of first map must connect with west side of second map\n{1}", FileLineData.linereport) if record[4] != "W"
        when "W"
          raise _INTL("West side of first map must connect with east side of second map\n{1}", FileLineData.linereport) if record[4] != "E"
        end
        records.push(record)
      end
      process_pbs_file_message_end
    end
    save_data(records, "Data/map_connections.dat")
  end

  #=============================================================================
  # Compile type data
  #=============================================================================
  def compile_types(*paths)
    compile_PBS_file_generic(GameData::Type, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_types : validate_compiled_type(hash)
    end
  end

  def validate_compiled_type(hash)
    # Remove duplicate weaknesses/resistances/immunities
    hash[:weaknesses].uniq! if hash[:weaknesses].is_a?(Array)
    hash[:resistances].uniq! if hash[:resistances].is_a?(Array)
    hash[:immunities].uniq! if hash[:immunities].is_a?(Array)
  end

  def validate_all_compiled_types
    type_names = []
    GameData::Type.each do |type|
      # Ensure all weaknesses/resistances/immunities are valid types
      type.weaknesses.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Weaknesses).", other_type.to_s, path, type.id)
      end
      type.resistances.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Resistances).", other_type.to_s, path, type.id)
      end
      type.immunities.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Immunities).", other_type.to_s, path, type.id)
      end
      # Get type names for translating
      type_names.push(type.real_name)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::TYPE_NAMES, type_names)
  end

  #=============================================================================
  # Compile ability data
  #=============================================================================
  def compile_abilities(*paths)
    compile_PBS_file_generic(GameData::Ability, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_abilities : validate_compiled_ability(hash)
    end
  end

  def validate_compiled_ability(hash)
  end

  def validate_all_compiled_abilities
    # Get abilty names/descriptions for translating
    ability_names = []
    ability_descriptions = []
    GameData::Ability.each do |ability|
      ability_names.push(ability.real_name)
      ability_descriptions.push(ability.real_description)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::ABILITY_NAMES, ability_names)
    MessageTypes.setMessagesAsHash(MessageTypes::ABILITY_DESCRIPTIONS, ability_descriptions)
  end

  #=============================================================================
  # Compile move data
  #=============================================================================
  def compile_moves(*paths)
    compile_PBS_file_generic(GameData::Move, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_moves : validate_compiled_move(hash)
    end
  end

  def validate_compiled_move(hash)
    if (hash[:category] || 2) == 2 && (hash[:power] || 0) != 0
      raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\n{2}",
                  hash[:real_name], FileLineData.linereport)
    elsif (hash[:category] || 2) != 2 && (hash[:power] || 0) == 0
      print _INTL("Warning: Move {1} is defined as Physical or Special but has a base damage of 0. Changing it to a Status move.\n{2}",
                  hash[:real_name], FileLineData.linereport)
      hash[:category] = 2
    end
  end

  def validate_all_compiled_moves
    # Get move names/descriptions for translating
    move_names = []
    move_descriptions = []
    GameData::Move.each do |move|
      move_names.push(move.real_name)
      move_descriptions.push(move.real_description)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::MOVE_NAMES, move_names)
    MessageTypes.setMessagesAsHash(MessageTypes::MOVE_DESCRIPTIONS, move_descriptions)
  end

  #=============================================================================
  # Compile item data
  #=============================================================================
  def compile_items(*paths)
    compile_PBS_file_generic(GameData::Item, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_items : validate_compiled_item(hash)
    end
  end

  def validate_compiled_item(hash)
  end

  def validate_all_compiled_items
    # Get item names/descriptions for translating
    item_names = []
    item_names_plural = []
    item_portion_names = []
    item_portion_names_plural = []
    item_descriptions = []
    GameData::Item.each do |item|
      item_names.push(item.real_name)
      item_names_plural.push(item.real_name_plural)
      item_portion_names.push(item.real_portion_name)
      item_portion_names_plural.push(item.real_portion_name_plural)
      item_descriptions.push(item.real_description)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::ITEM_NAMES, item_names)
    MessageTypes.setMessagesAsHash(MessageTypes::ITEM_NAME_PLURALS, item_names_plural)
    MessageTypes.setMessagesAsHash(MessageTypes::ITEM_PORTION_NAMES, item_portion_names)
    MessageTypes.setMessagesAsHash(MessageTypes::ITEM_PORTION_NAME_PLURALS, item_portion_names_plural)
    MessageTypes.setMessagesAsHash(MessageTypes::ITEM_DESCRIPTIONS, item_descriptions)
  end

  #=============================================================================
  # Compile berry plant data
  #=============================================================================
  def compile_berry_plants(*paths)
    compile_PBS_file_generic(GameData::BerryPlant, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_berry_plants : validate_compiled_berry_plant(hash)
    end
  end

  def validate_compiled_berry_plant(hash)
  end

  def validate_all_compiled_berry_plants
  end

  #=============================================================================
  # Compile Pokémon data
  #=============================================================================
  def compile_pokemon(*paths)
    compile_PBS_file_generic(GameData::Species, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_pokemon : validate_compiled_pokemon(hash)
    end
  end

  # NOTE: This method is also called by def validate_compiled_pokemon_form
  #       below, and since a form's hash can contain very little data, don't
  #       assume any data exists.
  def validate_compiled_pokemon(hash)
    # Convert base stats array to a hash
    if hash[:base_stats].is_a?(Array)
      new_stats = {}
      GameData::Stat.each_main do |s|
        new_stats[s.id] = (hash[:base_stats][s.pbs_order] || 1) if s.pbs_order >= 0
      end
      hash[:base_stats] = new_stats
    end
    # Convert EVs array to a hash
    if hash[:evs].is_a?(Array)
      new_evs = {}
      hash[:evs].each { |val| new_evs[val[0]] = val[1] }
      GameData::Stat.each_main { |s| new_evs[s.id] ||= 0 }
      hash[:evs] = new_evs
    end
    # Convert height and weight to integer values of tenths of a unit
    hash[:height] = [(hash[:height] * 10).round, 1].max if hash[:height]
    hash[:weight] = [(hash[:weight] * 10).round, 1].max if hash[:weight]
    # Record all evolutions as not being prevolutions
    if hash[:evolutions].is_a?(Array)
      hash[:evolutions].each { |evo| evo[3] = false }
    end
    # Remove duplicate types
    if hash[:types].is_a?(Array)
      hash[:types].uniq!
      hash[:types].compact!
    end
  end

  def validate_all_compiled_pokemon
    # Enumerate all offspring species (this couldn't be done earlier)
    GameData::Species.each do |species|
      FileLineData.setSection(species.id.to_s, "Offspring", nil)   # For error reporting
      offspring = species.offspring
      offspring.each_with_index do |sp, i|
        offspring[i] = cast_csv_value(sp, "e", :Species)
      end
    end
    # Enumerate all evolution species and parameters (this couldn't be done earlier)
    GameData::Species.each do |species|
      FileLineData.setSection(species.id.to_s, "Evolutions", nil)   # For error reporting
      species.evolutions.each do |evo|
        evo[0] = cast_csv_value(evo[0], "e", :Species)
        param_type = GameData::Evolution.get(evo[1]).parameter
        if param_type.nil?
          evo[2] = nil
        elsif param_type == Integer
          evo[2] = cast_csv_value(evo[2], "u")
        elsif param_type != String
          evo[2] = cast_csv_value(evo[2], "e", param_type)
        end
      end
    end
    # Add prevolution "evolution" entry for all evolved species
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      species.evolutions.each do |evo|
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] if !all_evos[evo[0]]
      end
    end
    GameData::Species.each do |species|   # Distribute prevolutions
      species.evolutions.push(all_evos[species.species].clone) if all_evos[species.species]
    end
    # Get species names/descriptions for translating
    species_names = []
    species_form_names = []
    species_categories = []
    species_pokedex_entries = []
    GameData::Species.each do |species|
      species_names.push(species.real_name)
      species_form_names.push(species.real_form_name)
      species_categories.push(species.real_category)
      species_pokedex_entries.push(species.real_pokedex_entry)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::SPECIES_NAMES, species_names)
    MessageTypes.setMessagesAsHash(MessageTypes::SPECIES_FORM_NAMES, species_form_names)
    MessageTypes.setMessagesAsHash(MessageTypes::SPECIES_CATEGORIES, species_categories)
    MessageTypes.setMessagesAsHash(MessageTypes::POKEDEX_ENTRIES, species_pokedex_entries)
  end

  #=============================================================================
  # Compile Pokémon forms data
  # NOTE: Doesn't use compile_PBS_file_generic because it needs its own schema
  #       and shouldn't clear GameData::Species at the start.
  #=============================================================================
  def compile_pokemon_forms(*paths)
    schema = GameData::Species.schema(true)
    # Read from PBS file(s)
    paths.each do |path|
      compile_pbs_file_message_start(path)
      file_suffix = File.basename(path, ".txt")[GameData::Species::PBS_BASE_FILENAME[1].length + 1, path.length] || ""
      File.open(path, "rb") do |f|
        FileLineData.file = path   # For error reporting
        # Read a whole section's lines at once, then run through this code.
        # contents is a hash containing all the XXX=YYY lines in that section, where
        # the keys are the XXX and the values are the YYY (as unprocessed strings).
        idx = 0
        pbEachFileSection(f, schema) do |contents, section_name|
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          data_hash = {
            :id              => section_name.to_sym,
            :pbs_file_suffix => file_suffix
          }
          # Go through schema hash of compilable data and compile this section
          schema.each_key do |key|
            FileLineData.setSection(section_name, key, contents[key])   # For error reporting
            if key == "SectionName"
              data_hash[schema[key][0]] = get_csv_record(section_name, schema[key])
              next
            end
            # Skip empty properties
            next if contents[key].nil?
            # Compile value for key
            if schema[key][1][0] == "^"
              contents[key].each do |val|
                value = get_csv_record(val, schema[key])
                value = nil if value.is_a?(Array) && value.empty?
                data_hash[schema[key][0]] ||= []
                data_hash[schema[key][0]].push(value)
              end
              data_hash[schema[key][0]].compact!
            else
              value = get_csv_record(contents[key], schema[key])
              value = nil if value.is_a?(Array) && value.empty?
              data_hash[schema[key][0]] = value
            end
          end
          # Validate and modify the compiled data
          validate_compiled_pokemon_form(data_hash)
          if GameData::Species.exists?(data_hash[:id])
            raise _INTL("Section name '{1}' is used twice.\n{2}", data_hash[:id], FileLineData.linereport)
          end
          # Add section's data to records
          GameData::Species.register(data_hash)
        end
      end
      process_pbs_file_message_end
    end
    validate_all_compiled_pokemon_forms
    # Save all data
    GameData::Species.save
  end

  def validate_compiled_pokemon_form(hash)
    # Split species and form into their own values, generate compound ID from them
    hash[:species] = hash[:id][0]
    hash[:form] = hash[:id][1]
    hash[:id] = sprintf("%s_%d", hash[:species].to_s, hash[:form]).to_sym
    if !GameData::Species.exists?(hash[:species])
      raise _INTL("Undefined species ID '{1}'.\n{3}", hash[:species], FileLineData.linereport)
    elsif GameData::Species.exists?(hash[:id])
      raise _INTL("Form {1} for species ID {2} is defined twice.\n{3}", hash[:form], hash[:species], FileLineData.linereport)
    end
    # Perform the same validations on this form as for a regular species
    validate_compiled_pokemon(hash)
    # Inherit undefined properties from base species
    base_data = GameData::Species.get(hash[:species])
    [:real_name, :real_category, :real_pokedex_entry, :base_exp, :growth_rate,
     :gender_ratio, :catch_rate, :happiness, :hatch_steps, :incense, :height,
     :weight, :color, :shape, :habitat, :generation].each do |property|
      hash[property] = base_data.send(property) if hash[property].nil?
    end
    [:types, :base_stats, :evs, :tutor_moves, :egg_moves, :abilities,
     :hidden_abilities, :egg_groups, :offspring, :flags].each do |property|
      hash[property] = base_data.send(property).clone if hash[property].nil?
    end
    if !hash[:moves].is_a?(Array) || hash[:moves].length == 0
      hash[:moves] ||= []
      base_data.moves.each { |m| hash[:moves].push(m.clone) }
    end
    if !hash[:evolutions].is_a?(Array) || hash[:evolutions].length == 0
      hash[:evolutions] ||= []
      base_data.evolutions.each { |e| hash[:evolutions].push(e.clone) }
    end
    if hash[:wild_item_common].nil? && hash[:wild_item_uncommon].nil? &&
       hash[:wild_item_rare].nil?
      hash[:wild_item_common] = base_data.wild_item_common.clone
      hash[:wild_item_uncommon] = base_data.wild_item_uncommon.clone
      hash[:wild_item_rare] = base_data.wild_item_rare.clone
    end
  end

  def validate_all_compiled_pokemon_forms
    # Enumerate all evolution parameters (this couldn't be done earlier)
    GameData::Species.each do |species|
      FileLineData.setSection(species.id.to_s, "Evolutions", nil)   # For error reporting
      species.evolutions.each do |evo|
        param_type = GameData::Evolution.get(evo[1]).parameter
        if param_type.nil?
          evo[2] = nil
        elsif param_type == Integer
          evo[2] = cast_csv_value(evo[2], "u") if evo[2].is_a?(String)
        elsif param_type != String
          evo[2] = cast_csv_value(evo[2], "e", param_type) if evo[2].is_a?(String)
        end
      end
    end
    # Add prevolution "evolution" entry for all evolved species
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      species.evolutions.each do |evo|
        next if evo[3]
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] if !all_evos[evo[0]]
        if species.form > 0
          all_evos[[evo[0], species.form]] = [species.species, evo[1], evo[2], true] if !all_evos[[evo[0], species.form]]
        end
      end
    end
    GameData::Species.each do |species|   # Distribute prevolutions
      prevo_data = all_evos[[species.species, species.base_form]] || all_evos[species.species]
      next if !prevo_data
      # Record what species evolves from
      species.evolutions.delete_if { |evo| evo[3] }
      species.evolutions.push(prevo_data.clone)
      # Record that the prevolution can evolve into species
      prevo = GameData::Species.get(prevo_data[0])
      if prevo.evolutions.none? { |evo| !evo[3] && evo[0] == species.species }
        prevo.evolutions.push([species.species, :None, nil])
      end
    end
    # Get species names/descriptions for translating
    species_form_names = []
    species_categories = []
    species_pokedex_entries = []
    GameData::Species.each do |species|
      next if species.form == 0
      species_form_names.push(species.real_form_name)
      species_categories.push(species.real_category)
      species_pokedex_entries.push(species.real_pokedex_entry)
    end
    MessageTypes.addMessagesAsHash(MessageTypes::SPECIES_FORM_NAMES, species_form_names)
    MessageTypes.addMessagesAsHash(MessageTypes::SPECIES_CATEGORIES, species_categories)
    MessageTypes.addMessagesAsHash(MessageTypes::POKEDEX_ENTRIES, species_pokedex_entries)
  end

  #=============================================================================
  # Compile Pokémon metrics data
  #=============================================================================
  def compile_pokemon_metrics(*paths)
    compile_PBS_file_generic(GameData::SpeciesMetrics, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_pokemon_metrics : validate_compiled_pokemon_metrics(hash)
    end
  end

  def validate_compiled_pokemon_metrics(hash)
    # Split species and form into their own values, generate compound ID from them
    if hash[:id].is_a?(Array)
      hash[:species] = hash[:id][0]
      hash[:form] = hash[:id][1] || 0
      if hash[:form] == 0
        hash[:id] = hash[:species]
      else
        hash[:id] = sprintf("%s_%d", hash[:species].to_s, hash[:form]).to_sym
      end
    end
  end

  def validate_all_compiled_pokemon_metrics
  end

  #=============================================================================
  # Compile Shadow Pokémon data
  #=============================================================================
  def compile_shadow_pokemon(*paths)
    compile_PBS_file_generic(GameData::ShadowPokemon, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_shadow_pokemon : validate_compiled_shadow_pokemon(hash)
    end
  end

  def validate_compiled_shadow_pokemon(hash)
    # Split species and form into their own values, generate compound ID from them
    if hash[:id].is_a?(Array)
      hash[:species] = hash[:id][0]
      hash[:form] = hash[:id][1] || 0
      if hash[:form] == 0
        hash[:id] = hash[:species]
      else
        hash[:id] = sprintf("%s_%d", hash[:species].to_s, hash[:form]).to_sym
      end
    end
  end

  def validate_all_compiled_shadow_pokemon
  end

  #=============================================================================
  # Compile Regional Dexes
  #=============================================================================
  def compile_regional_dexes(*paths)
    dex_lists = []
    paths.each do |path|
      compile_pbs_file_message_start(path)
      section = nil
      pbCompilerEachPreppedLine(path) do |line, line_no|
        Graphics.update if line_no % 200 == 0
        if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
          section = $~[1].to_i
          if dex_lists[section]
            raise _INTL("Dex list number {1} is defined at least twice.\n{2}", section, FileLineData.linereport)
          end
          dex_lists[section] = []
        else
          raise _INTL("Expected a section at the beginning of the file.\n{1}", FileLineData.linereport) if !section
          species_list = line.split(",")
          species_list.each do |species|
            next if !species || species.empty?
            s = parseSpecies(species)
            dex_lists[section].push(s)
          end
        end
      end
      process_pbs_file_message_end
    end
    # Check for duplicate species in a Regional Dex
    dex_lists.each_with_index do |list, index|
      unique_list = list.uniq
      next if list == unique_list
      list.each_with_index do |s, i|
        next if unique_list[i] == s
        raise _INTL("Dex list number {1} has species {2} listed twice.\n{3}", index, s, FileLineData.linereport)
      end
    end
    # Save all data
    save_data(dex_lists, "Data/regional_dexes.dat")
  end

  #=============================================================================
  # Compile ribbon data
  #=============================================================================
  def compile_ribbons(*paths)
    compile_PBS_file_generic(GameData::Ribbon, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_ribbons : validate_compiled_ribbon(hash)
    end
  end

  def validate_compiled_ribbon(hash)
  end

  def validate_all_compiled_ribbons
    # Get ribbon names/descriptions for translating
    ribbon_names = []
    ribbon_descriptions = []
    GameData::Ribbon.each do |ribbon|
      ribbon_names.push(ribbon.real_name)
      ribbon_descriptions.push(ribbon.real_description)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::RIBBON_NAMES, ribbon_names)
    MessageTypes.setMessagesAsHash(MessageTypes::RIBBON_DESCRIPTIONS, ribbon_descriptions)
  end

  #=============================================================================
  # Compile wild encounter data
  #=============================================================================
  def compile_encounters(*paths)
    GameData::Encounter::DATA.clear
    max_level = GameData::GrowthRate.max_level
    paths.each do |path|
      compile_pbs_file_message_start(path)
      file_suffix = File.basename(path, ".txt")[GameData::Encounter::PBS_BASE_FILENAME.length + 1, path.length] || ""
      encounter_hash = nil
      step_chances   = nil
      current_type   = nil
      idx = 0
      pbCompilerEachPreppedLine(path) do |line, line_no|
        echo "." if idx % 100 == 0
        idx += 1
        Graphics.update if idx % 500 == 0
        next if line.length == 0
        if current_type && line[/^\d+,/]   # Species line
          values = line.split(",").collect! { |v| v.strip }
          if !values || values.length < 3
            raise _INTL("Expected a species entry line for encounter type {1} for map '{2}', got \"{3}\" instead.\n{4}",
                        GameData::EncounterType.get(current_type).real_name, encounter_hash[:map], line, FileLineData.linereport)
          end
          values = get_csv_record(line, [nil, "vevV", nil, :Species])
          values[3] = values[2] if !values[3]
          if values[2] > max_level
            raise _INTL("Level number {1} is not valid (max. {2}).\n{3}", values[2], max_level, FileLineData.linereport)
          elsif values[3] > max_level
            raise _INTL("Level number {1} is not valid (max. {2}).\n{3}", values[3], max_level, FileLineData.linereport)
          elsif values[2] > values[3]
            raise _INTL("Minimum level is greater than maximum level: {1}\n{2}", line, FileLineData.linereport)
          end
          encounter_hash[:types][current_type].push(values)
        elsif line[/^\[\s*(.+)\s*\]$/]   # Map ID line
          values = $~[1].split(",").collect! { |v| v.strip.to_i }
          values[1] = 0 if !values[1]
          map_number = values[0]
          map_version = values[1]
          # Add map encounter's data to records
          if encounter_hash
            encounter_hash[:types].each_value do |slots|
              next if !slots || slots.length == 0
              slots.each_with_index do |slot, i|
                next if !slot
                slots.each_with_index do |other_slot, j|
                  next if i == j || !other_slot
                  next if slot[1] != other_slot[1] || slot[2] != other_slot[2] || slot[3] != other_slot[3]
                  slot[0] += other_slot[0]
                  slots[j] = nil
                end
              end
              slots.compact!
              slots.sort! { |a, b| (a[0] == b[0]) ? a[1].to_s <=> b[1].to_s : b[0] <=> a[0] }
            end
            GameData::Encounter.register(encounter_hash)
          end
          # Raise an error if a map/version combo is used twice
          key = sprintf("%s_%d", map_number, map_version).to_sym
          if GameData::Encounter::DATA[key]
            raise _INTL("Encounters for map '{1}' are defined twice.\n{2}", map_number, FileLineData.linereport)
          end
          step_chances = {}
          # Construct encounter hash
          encounter_hash = {
            :id              => key,
            :map             => map_number,
            :version         => map_version,
            :step_chances    => step_chances,
            :types           => {},
            :pbs_file_suffix => file_suffix
          }
          current_type = nil
        elsif !encounter_hash   # File began with something other than a map ID line
          raise _INTL("Expected a map number, got \"{1}\" instead.\n{2}", line, FileLineData.linereport)
        else
          # Check if line is an encounter method name or not
          values = line.split(",").collect! { |v| v.strip }
          current_type = (values[0] && !values[0].empty?) ? values[0].to_sym : nil
          if current_type && GameData::EncounterType.exists?(current_type)   # Start of a new encounter method
            step_chances[current_type] = values[1].to_i if values[1] && !values[1].empty?
            step_chances[current_type] ||= GameData::EncounterType.get(current_type).trigger_chance
            encounter_hash[:types][current_type] = []
          else
            raise _INTL("Undefined encounter type \"{1}\" for map '{2}'.\n{3}",
                        line, encounter_hash[:map], FileLineData.linereport)
          end
        end
      end
      # Add last map's encounter data to records
      if encounter_hash
        encounter_hash[:types].each_value do |slots|
          next if !slots || slots.length == 0
          slots.each_with_index do |slot, i|
            next if !slot
            slots.each_with_index do |other_slot, j|
              next if i == j || !other_slot
              next if slot[1] != other_slot[1] || slot[2] != other_slot[2] || slot[3] != other_slot[3]
              slot[0] += other_slot[0]
              slots[j] = nil
            end
          end
          slots.compact!
          slots.sort! { |a, b| (a[0] == b[0]) ? a[1].to_s <=> b[1].to_s : b[0] <=> a[0] }
        end
        GameData::Encounter.register(encounter_hash)
      end
      process_pbs_file_message_end
    end
    # Save all data
    GameData::Encounter.save
  end

  #=============================================================================
  # Compile trainer type data
  #=============================================================================
  def compile_trainer_types(*paths)
    compile_PBS_file_generic(GameData::TrainerType, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_trainer_types : validate_compiled_trainer_type(hash)
    end
  end

  def validate_compiled_trainer_type(hash)
  end

  def validate_all_compiled_trainer_types
    # Get trainer type names for translating
    trainer_type_names = []
    GameData::TrainerType.each do |tr_type|
      trainer_type_names.push(tr_type.real_name)
    end
    MessageTypes.setMessagesAsHash(MessageTypes::TRAINER_TYPE_NAMES, trainer_type_names)
  end

  #=============================================================================
  # Compile individual trainer data
  #=============================================================================
  def compile_trainers(*paths)
    GameData::Trainer::DATA.clear
    schema = GameData::Trainer.schema
    sub_schema = GameData::Trainer.sub_schema
    idx = 0
    # Read from PBS file(s)
    paths.each do |path|
      compile_pbs_file_message_start(path)
      file_suffix = File.basename(path, ".txt")[GameData::Trainer::PBS_BASE_FILENAME.length + 1, path.length] || ""
      data_hash = nil
      current_pkmn = nil
      section_name = nil
      section_line = nil
      # Read each line of trainers.txt at a time and compile it as a trainer property
      pbCompilerEachPreppedLine(path) do |line, line_no|
        echo "." if idx % 100 == 0
        idx += 1
        Graphics.update if idx % 500 == 0
        FileLineData.setSection(section_name, nil, section_line)
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          # New section [trainer_type, name] or [trainer_type, name, version]
          section_name = $~[1]
          section_line = line
          if data_hash
            validate_compiled_trainer(data_hash)
            GameData::Trainer.register(data_hash)
          end
          FileLineData.setSection(section_name, nil, section_line)
          # Construct data hash
          data_hash = {
            :pbs_file_suffix => file_suffix
          }
          data_hash[schema["SectionName"][0]] = get_csv_record(section_name.clone, schema["SectionName"])
          data_hash[schema["Pokemon"][0]] = []
          current_pkmn = nil
        elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
          # XXX=YYY lines
          if !data_hash
            raise _INTL("Expected a section at the beginning of the file.\n{1}", FileLineData.linereport)
          end
          key = $~[1]
          if schema[key]   # Property of the trainer
            property_value = get_csv_record($~[2], schema[key])
            if key == "Pokemon"
              current_pkmn = {
                :species => property_value[0],
                :level   => property_value[1]
              }
              data_hash[schema[key][0]].push(current_pkmn)
            else
              data_hash[schema[key][0]] = property_value
            end
          elsif sub_schema[key]   # Property of a Pokémon
            if !current_pkmn
              raise _INTL("Pokémon hasn't been defined yet!\n{1}", FileLineData.linereport)
            end
            current_pkmn[sub_schema[key][0]] = get_csv_record($~[2], sub_schema[key])
          end
        end
      end
      # Add last trainer's data to records
      if data_hash
        FileLineData.setSection(section_name, nil, section_line)
        validate_compiled_trainer(data_hash)
        GameData::Trainer.register(data_hash)
      end
      process_pbs_file_message_end
    end
    validate_all_compiled_trainers
    # Save all data
    GameData::Trainer.save
  end

  def validate_compiled_trainer(hash)
    # Split trainer type, name and version into their own values, generate compound ID from them
    hash[:id][2] ||= 0
    hash[:trainer_type] = hash[:id][0]
    hash[:real_name] = hash[:id][1]
    hash[:version] = hash[:id][2]
    # Ensure the trainer has at least one Pokémon
    if hash[:pokemon].empty?
      raise _INTL("Trainer with ID {1} has no Pokémon.\n{2}", hash[:id], FileLineData.linereport)
    end
    max_level = GameData::GrowthRate.max_level
    hash[:pokemon].each do |pkmn|
      # Ensure valid level
      if pkmn[:level] > max_level
        raise _INTL("Invalid Pokémon level {1} (must be 1-{2}).\n{3}",
                    pkmn[:level], max_level, FileLineData.linereport)
      end
      # Ensure valid name length
      if pkmn[:real_name] && pkmn[:real_name].length > Pokemon::MAX_NAME_SIZE
        raise _INTL("Invalid Pokémon nickname: {1} (must be 1-{2} characters).\n{3}",
                    pkmn[:real_name], Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
      end
      # Ensure no duplicate moves
      pkmn[:moves].uniq! if pkmn[:moves]
      # Ensure valid IVs, convert IVs to hash format
      if pkmn[:iv]
        iv_hash = {}
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          iv_hash[s.id] = pkmn[:iv][s.pbs_order] || pkmn[:iv][0]
          if iv_hash[s.id] > Pokemon::IV_STAT_LIMIT
            raise _INTL("Invalid IV: {1} (must be 0-{2}).\n{3}",
                        iv_hash[s.id], Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        end
        pkmn[:iv] = iv_hash
      end
      # Ensure valid EVs, convert EVs to hash format
      if pkmn[:ev]
        ev_hash = {}
        ev_total = 0
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          ev_hash[s.id] = pkmn[:ev][s.pbs_order] || pkmn[:ev][0]
          ev_total += ev_hash[s.id]
          if ev_hash[s.id] > Pokemon::EV_STAT_LIMIT
            raise _INTL("Invalid EV: {1} (must be 0-{2}).\n{3}",
                        ev_hash[s.id], Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
        end
        pkmn[:ev] = ev_hash
        if ev_total > Pokemon::EV_LIMIT
          raise _INTL("Invalid EV set (must sum to {1} or less).\n{2}",
                      Pokemon::EV_LIMIT, FileLineData.linereport)
        end
      end
      # Ensure valid happiness
      if pkmn[:happiness]
        if pkmn[:happiness] > 255
          raise _INTL("Bad happiness: {1} (must be 0-255).\n{2}", pkmn[:happiness], FileLineData.linereport)
        end
      end
      # Ensure valid Poké Ball
      if pkmn[:poke_ball]
        if !GameData::Item.get(pkmn[:poke_ball]).is_poke_ball?
          raise _INTL("Value {1} isn't a defined Poké Ball.\n{2}", pkmn[:poke_ball], FileLineData.linereport)
        end
      end
    end
  end

  def validate_all_compiled_trainers
    # Get trainer names and lose texts for translating
    trainer_names = []
    lose_texts = []
    pokemon_nicknames = []
    GameData::Trainer.each do |trainer|
      trainer_names.push(trainer.real_name)
      lose_texts.push(trainer.real_lose_text)
      trainer.pokemon.each do |pkmn|
        pokemon_nicknames.push(pkmn[:real_name]) if !nil_or_empty?(pkmn[:real_name])
      end
    end
    MessageTypes.setMessagesAsHash(MessageTypes::TRAINER_NAMES, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TRAINER_SPEECHES_LOSE, lose_texts)
    MessageTypes.setMessagesAsHash(MessageTypes::POKEMON_NICKNAMES, pokemon_nicknames)
  end

  #=============================================================================
  # Compile Battle Tower and other Cups trainers/Pokémon
  #=============================================================================
  def compile_trainer_lists(path = "PBS/battle_facility_lists.txt")
    compile_pbs_file_message_start(path)
    btTrainersRequiredTypes = {
      "Trainers"   => [0, "s"],
      "Pokemon"    => [1, "s"],
      "Challenges" => [2, "*s"]
    }
    if !FileTest.exist?(path)
      File.open(path, "wb") do |f|
        f.write(0xEF.chr)
        f.write(0xBB.chr)
        f.write(0xBF.chr)
        f.write("[DefaultTrainerList]\r\n")
        f.write("Trainers = battle_tower_trainers.txt\r\n")
        f.write("Pokemon = battle_tower_pokemon.txt\r\n")
      end
    end
    sections = []
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_INTRO_SPEECHES, [])
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, [])
    MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, [])
    File.open(path, "rb") do |f|
      FileLineData.file = path
      idx = 0
      pbEachFileSection(f) do |section, name|
        echo "."
        idx += 1
        Graphics.update
        next if name != "DefaultTrainerList" && name != "TrainerList"
        rsection = []
        section.each_key do |key|
          FileLineData.setSection(name, key, section[key])
          schema = btTrainersRequiredTypes[key]
          next if key == "Challenges" && name == "DefaultTrainerList"
          next if !schema
          record = get_csv_record(section[key], schema)
          rsection[schema[0]] = record
        end
        if !rsection[0]
          raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
        end
        if !rsection[1]
          raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
        end
        rsection[3] = rsection[0]
        rsection[4] = rsection[1]
        rsection[5] = (name == "DefaultTrainerList")
        if FileTest.exist?("PBS/" + rsection[0])
          rsection[0] = compile_battle_tower_trainers("PBS/" + rsection[0])
        else
          rsection[0] = []
        end
        if FileTest.exist?("PBS/" + rsection[1])
          filename = "PBS/" + rsection[1]
          rsection[1] = []
          pbCompilerEachCommentedLine(filename) do |line, _lineno|
            rsection[1].push(PBPokemon.fromInspected(line))
          end
        else
          rsection[1] = []
        end
        rsection[2] = [] if !rsection[2]
        while rsection[2].include?("")
          rsection[2].delete("")
        end
        rsection[2].compact!
        sections.push(rsection)
      end
    end
    save_data(sections, "Data/trainer_lists.dat")
    process_pbs_file_message_end
  end

  def compile_battle_tower_trainers(filename)
    sections = []
    requiredtypes = {
      "Type"          => [0, "e", :TrainerType],
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"]
    }
    trainernames  = []
    beginspeech   = []
    endspeechwin  = []
    endspeechlose = []
    if FileTest.exist?(filename)
      File.open(filename, "rb") do |f|
        FileLineData.file = filename
        pbEachFileSection(f) do |section, name|
          rsection = []
          section.each_key do |key|
            FileLineData.setSection(name, key, section[key])
            schema = requiredtypes[key]
            next if !schema
            record = get_csv_record(section[key], schema)
            rsection[schema[0]] = record
          end
          trainernames.push(rsection[1])
          beginspeech.push(rsection[2])
          endspeechwin.push(rsection[3])
          endspeechlose.push(rsection[4])
          sections.push(rsection)
        end
      end
    end
    MessageTypes.addMessagesAsHash(MessageTypes::TRAINER_NAMES, trainernames)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_INTRO_SPEECHES, beginspeech)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, endspeechwin)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, endspeechlose)
    return sections
  end

  #=============================================================================
  # Compile metadata
  # NOTE: Doesn't use compile_PBS_file_generic because it contains data for two
  #       different GameData classes.
  #=============================================================================
  def compile_metadata(*paths)
    GameData::Metadata::DATA.clear
    GameData::PlayerMetadata::DATA.clear
    global_schema = GameData::Metadata.schema
    player_schema = GameData::PlayerMetadata.schema
    paths.each do |path|
      compile_pbs_file_message_start(path)
      file_suffix = File.basename(path, ".txt")[GameData::Metadata::PBS_BASE_FILENAME.length + 1, path.length] || ""
      # Read from PBS file
      File.open(path, "rb") do |f|
        FileLineData.file = path   # For error reporting
        # Read a whole section's lines at once, then run through this code.
        # contents is a hash containing all the XXX=YYY lines in that section, where
        # the keys are the XXX and the values are the YYY (as unprocessed strings).
        idx = 0
        pbEachFileSection(f) do |contents, section_name|
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          schema = (section_name.to_i == 0) ? global_schema : player_schema
          data_hash = {
            :id              => section_name.to_sym,
            :pbs_file_suffix => file_suffix
          }
          # Go through schema hash of compilable data and compile this section
          schema.each_key do |key|
            FileLineData.setSection(section_name, key, contents[key])   # For error reporting
            if key == "SectionName"
              data_hash[schema[key][0]] = get_csv_record(section_name, schema[key])
              next
            end
            # Skip empty properties
            next if contents[key].nil?
            # Compile value for key
            if schema[key][1][0] == "^"
              contents[key].each do |val|
                value = get_csv_record(val, schema[key])
                value = nil if value.is_a?(Array) && value.empty?
                data_hash[schema[key][0]] ||= []
                data_hash[schema[key][0]].push(value)
              end
              data_hash[schema[key][0]].compact!
            else
              value = get_csv_record(contents[key], schema[key])
              value = nil if value.is_a?(Array) && value.empty?
              data_hash[schema[key][0]] = value
            end
          end
          # Validate and modify the compiled data
          if data_hash[:id] == 0
            validate_compiled_global_metadata(data_hash)
            if GameData::Metadata.exists?(data_hash[:id])
              raise _INTL("Global metadata ID '{1}' is used twice.\n{2}", data_hash[:id], FileLineData.linereport)
            end
          else
            validate_compiled_player_metadata(data_hash)
            if GameData::PlayerMetadata.exists?(data_hash[:id])
              raise _INTL("Player metadata ID '{1}' is used twice.\n{2}", data_hash[:id], FileLineData.linereport)
            end
          end
          # Add section's data to records
          if data_hash[:id] == 0
            GameData::Metadata.register(data_hash)
          else
            GameData::PlayerMetadata.register(data_hash)
          end
        end
      end
      process_pbs_file_message_end
    end
    validate_all_compiled_metadata
    # Save all data
    GameData::Metadata.save
    GameData::PlayerMetadata.save
  end

  def validate_compiled_global_metadata(hash)
    if hash[:home].nil?
      raise _INTL("The entry 'Home' is required in metadata.txt section 0.\n{1}", FileLineData.linereport)
    end
  end

  def validate_compiled_player_metadata(hash)
  end

  # Should be used to check both global metadata and player character metadata.
  def validate_all_compiled_metadata
    # Ensure global metadata is defined
    if !GameData::Metadata.exists?(0)
      raise _INTL("Global metadata is not defined in metadata.txt but should be.\n{1}", FileLineData.linereport)
    end
    # Ensure player character 1's metadata is defined
    if !GameData::PlayerMetadata.exists?(1)
      raise _INTL("Metadata for player character 1 is not defined in metadata.txt but should be.\n{1}", FileLineData.linereport)
    end
    # Get storage creator's name for translating
    storage_creator = [GameData::Metadata.get.real_storage_creator]
    MessageTypes.setMessagesAsHash(MessageTypes::STORAGE_CREATOR_NAME, storage_creator)
  end

  #=============================================================================
  # Compile map metadata
  #=============================================================================
  def compile_map_metadata(*paths)
    compile_PBS_file_generic(GameData::MapMetadata, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_map_metadata : validate_compiled_map_metadata(hash)
    end
  end

  def validate_compiled_map_metadata(hash)
    # Give the map its RMXP map name if it doesn't define its own
    if nil_or_empty?(hash[:real_name])
      hash[:real_name] = pbLoadMapInfos[hash[:id]].name
    end
  end

  def validate_all_compiled_map_metadata
    # Get map names for translating
    map_names = []
    GameData::MapMetadata.each { |map| map_names[map.id] = map.real_name }
    MessageTypes.setMessagesAsHash(MessageTypes::MAP_NAMES, map_names)
  end

  #=============================================================================
  # Compile dungeon tileset data
  #=============================================================================
  def compile_dungeon_tilesets(*paths)
    compile_PBS_file_generic(GameData::DungeonTileset, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_dungeon_tilesets : validate_compiled_dungeon_tileset(hash)
    end
  end

  def validate_compiled_dungeon_tileset(hash)
  end

  def validate_all_compiled_dungeon_tilesets
  end

  #=============================================================================
  # Compile dungeon parameters data
  #=============================================================================
  def compile_dungeon_parameters(*paths)
    compile_PBS_file_generic(GameData::DungeonParameters, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_dungeon_parameters : validate_compiled_dungeon_parameters(hash)
    end
  end

  def validate_compiled_dungeon_parameters(hash)
    # Split area and version into their own values, generate compound ID from them
    hash[:area] = hash[:id][0]
    hash[:version] = hash[:id][1] || 0
    if hash[:version] == 0
      hash[:id] = hash[:area]
    else
      hash[:id] = sprintf("%s_%d", hash[:area].to_s, hash[:version]).to_sym
    end
    if GameData::DungeonParameters.exists?(hash[:id])
      raise _INTL("Version {1} of dungeon area {2} is defined twice.\n{3}", hash[:version], hash[:area], FileLineData.linereport)
    end
  end

  def validate_all_compiled_dungeon_parameters
  end

  #=============================================================================
  # Compile phone messages
  #=============================================================================
  def compile_phone(*paths)
    compile_PBS_file_generic(GameData::PhoneMessage, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_phone_contacts : validate_compiled_phone_contact(hash)
    end
  end

  def validate_compiled_phone_contact(hash)
    # Split trainer type/name/version into their own values, generate compound ID from them
    if hash[:id].strip.downcase == "default"
      hash[:id] = "default"
      hash[:trainer_type] = hash[:id]
    else
      line_data = get_csv_record(hash[:id], [nil, "esU", :TrainerType])
      hash[:trainer_type] = line_data[0]
      hash[:real_name] = line_data[1]
      hash[:version] = line_data[2] || 0
      hash[:id] = [hash[:trainer_type], hash[:real_name], hash[:version]]
    end
  end

  def validate_all_compiled_phone_contacts
    # Get all phone messages for translating
    messages = []
    GameData::PhoneMessage.each do |contact|
      [:intro, :intro_morning, :intro_afternoon, :intro_evening, :body, :body1,
       :body2, :battle_request, :battle_remind, :end].each do |msg_type|
        msgs = contact.send(msg_type)
        next if !msgs || msgs.length == 0
        msgs.each { |msg| messages.push(msg) }
      end
    end
    MessageTypes.setMessagesAsHash(MessageTypes::PHONE_MESSAGES, messages)
  end

  #=============================================================================
  # Compile battle animations
  #=============================================================================
  def compile_animations
    Console.echo_li(_INTL("Compiling animations..."))
    begin
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    rescue
      pbanims = PBAnimations.new
    end
    changed = false
    move2anim = [{}, {}]
#    anims = load_data("Data/Animations.rxdata")
#    for anim in anims
#      next if !anim || anim.frames.length == 1
#      found = false
#      for i in 0...pbanims.length
#        if pbanims[i] && pbanims[i].id == anim.id
#          found = true if pbanims[i].array.length > 1
#          break
#        end
#      end
#      pbanims[anim.id] = pbConvertRPGAnimation(anim) if !found
#    end
    idx = 0
    pbanims.length.times do |i|
      echo "." if idx % 100 == 0
      Graphics.update if idx % 500 == 0
      idx += 1
      next if !pbanims[i]
      if pbanims[i].name[/^OppMove\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[1][moveid] != i
          move2anim[1][moveid] = i
        end
      elsif pbanims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id
          changed = true if !move2anim[0][moveid] || move2anim[0][moveid] != i
          move2anim[0][moveid] = i
        end
      end
    end
    if changed
      save_data(move2anim, "Data/move2anim.dat")
      save_data(pbanims, "Data/PkmnAnimations.rxdata")
    end
    process_pbs_file_message_end
  end
end
