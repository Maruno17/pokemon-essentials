module Compiler
  module_function

  #=============================================================================
  # Compile Town Map data
  #=============================================================================
  def compile_town_map(path = "PBS/townmap.txt")
    nonglobaltypes = {
      "Name"     => [0, "s"],
      "Filename" => [1, "s"],
      "Point"    => [2, "uussUUUU"]
    }
    currentmap = -1
    rgnnames   = []
    placenames = []
    placedescs = []
    sections   = []
    pbCompilerEachCommentedLine(path) { |line,lineno|
      if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
        currentmap = $~[1].to_i
        sections[currentmap] = []
      else
        if currentmap<0
          raise _INTL("Expected a section at the beginning of the file\r\n{1}",FileLineData.linereport)
        end
        if !line[/^\s*(\w+)\s*=\s*(.*)$/]
          raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\r\n{1}",FileLineData.linereport)
        end
        settingname = $~[1]
        schema = nonglobaltypes[settingname]
        if schema
          record = pbGetCsvRecord($~[2],lineno,schema)
          if settingname=="Name"
            rgnnames[currentmap] = record
          elsif settingname=="Point"
            placenames.push(record[2])
            placedescs.push(record[3])
            sections[currentmap][schema[0]] = [] if !sections[currentmap][schema[0]]
            sections[currentmap][schema[0]].push(record)
          else   # Filename
            sections[currentmap][schema[0]] = record
          end
        end
      end
    }
    save_data(sections,"Data/town_map.dat")
    MessageTypes.setMessages(MessageTypes::RegionNames,rgnnames)
    MessageTypes.setMessagesAsHash(MessageTypes::PlaceNames,placenames)
    MessageTypes.setMessagesAsHash(MessageTypes::PlaceDescriptions,placedescs)
  end

  #=============================================================================
  # Compile map connections
  #=============================================================================
  def compile_connections(path = "PBS/connections.txt")
    records   = []
    pbCompilerEachPreppedLine(path) { |line,lineno|
      hashenum = {
        "N" => "N","North" => "N",
        "E" => "E","East"  => "E",
        "S" => "S","South" => "S",
        "W" => "W","West"  => "W"
      }
      record = []
      thisline = line.dup
      record.push(csvInt!(thisline,lineno))
      record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
      record.push(csvInt!(thisline,lineno))
      record.push(csvInt!(thisline,lineno))
      record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
      record.push(csvInt!(thisline,lineno))
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0]))
        print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[0],FileLineData.linereport)
      end
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3]))
        print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[3],FileLineData.linereport)
      end
      case record[1]
      when "N"
        raise _INTL("North side of first map must connect with south side of second map\r\n{1}", FileLineData.linereport) if record[4] != "S"
      when "S"
        raise _INTL("South side of first map must connect with north side of second map\r\n{1}", FileLineData.linereport) if record[4] != "N"
      when "E"
        raise _INTL("East side of first map must connect with west side of second map\r\n{1}", FileLineData.linereport) if record[4] != "W"
      when "W"
        raise _INTL("West side of first map must connect with east side of second map\r\n{1}", FileLineData.linereport) if record[4] != "E"
      end
      records.push(record)
    }
    save_data(records,"Data/map_connections.dat")
    Graphics.update
  end

  #=============================================================================
  # Compile phone messages
  #=============================================================================
  def compile_phone(path = "PBS/phone.txt")
    return if !safeExists?(path)
    database = PhoneDatabase.new
    sections = []
    File.open(path, "rb") { |f|
      pbEachSection(f) { |section,name|
        case name
        when "<Generics>"
          database.generics=section
          sections.concat(section)
        when "<BattleRequests>"
          database.battleRequests=section
          sections.concat(section)
        when "<GreetingsMorning>"
          database.greetingsMorning=section
          sections.concat(section)
        when "<GreetingsEvening>"
          database.greetingsEvening=section
          sections.concat(section)
        when "<Greetings>"
          database.greetings=section
          sections.concat(section)
        when "<Bodies1>"
          database.bodies1=section
          sections.concat(section)
        when "<Bodies2>"
          database.bodies2=section
          sections.concat(section)
        end
      }
    }
    MessageTypes.setMessagesAsHash(MessageTypes::PhoneMessages,sections)
    save_data(database,"Data/phone.dat")
  end

  #=============================================================================
  # Compile type data
  #=============================================================================
  def compile_types(path = "PBS/types.txt")
    GameData::Type::DATA.clear
    type_names = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Type::SCHEMA
      pbEachFileSection(f) { |contents, type_number|
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          FileLineData.setSection(type_number, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, type_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Ensure weaknesses/resistances/immunities are in arrays and are symbols
          if value && ["Weaknesses", "Resistances", "Immunities"].include?(key)
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].map! { |x| x.to_sym }
            contents[key].uniq!
          end
        end
        # Construct type hash
        type_symbol = contents["InternalName"].to_sym
        type_hash = {
          :id           => type_symbol,
          :id_number    => type_number,
          :name         => contents["Name"],
          :pseudo_type  => contents["IsPseudoType"],
          :special_type => contents["IsSpecialType"],
          :weaknesses   => contents["Weaknesses"],
          :resistances  => contents["Resistances"],
          :immunities   => contents["Immunities"]
        }
        # Add type's data to records
        GameData::Type.register(type_hash)
        type_names[type_number] = type_hash[:name]
      }
    }
    # Ensure all weaknesses/resistances/immunities are valid types
    GameData::Type.each do |type|
      type.weaknesses.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Weaknesses).", other_type.to_s, path, type.id_number)
      end
      type.resistances.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Resistances).", other_type.to_s, path, type.id_number)
      end
      type.immunities.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Immunities).", other_type.to_s, path, type.id_number)
      end
    end
    # Save all data
    GameData::Type.save
    MessageTypes.setMessages(MessageTypes::Types, type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile ability data
  #=============================================================================
  def compile_abilities(path = "PBS/abilities.txt")
    GameData::Ability::DATA.clear
    ability_names        = []
    ability_descriptions = []
    pbCompilerEachPreppedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnss"])
      ability_number = line[0]
      ability_symbol = line[1].to_sym
      if GameData::Ability::DATA[ability_number]
        raise _INTL("Ability ID number '{1}' is used twice.\r\n{2}", ability_number, FileLineData.linereport)
      elsif GameData::Ability::DATA[ability_symbol]
        raise _INTL("Ability ID '{1}' is used twice.\r\n{2}", ability_symbol, FileLineData.linereport)
      end
      # Construct ability hash
      ability_hash = {
        :id          => ability_symbol,
        :id_number   => ability_number,
        :name        => line[2],
        :description => line[3]
      }
      # Add ability's data to records
      GameData::Ability.register(ability_hash)
      ability_names[ability_number]        = ability_hash[:name]
      ability_descriptions[ability_number] = ability_hash[:description]
    }
    # Save all data
    GameData::Ability.save
    MessageTypes.setMessages(MessageTypes::Abilities, ability_names)
    MessageTypes.setMessages(MessageTypes::AbilityDescs, ability_descriptions)
    Graphics.update
  end

  #=============================================================================
  # Compile move data
  #=============================================================================
  def compile_moves(path = "PBS/moves.txt")
    GameData::Move::DATA.clear
    move_names        = []
    move_descriptions = []
    # Read each line of moves.txt at a time and compile it into an move
    pbCompilerEachPreppedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnssueeuuueiss",
         nil, nil, nil, nil, nil, :Type, ["Physical", "Special", "Status"],
         nil, nil, nil, :Target, nil, nil, nil
      ])
      move_number = line[0]
      move_symbol = line[1].to_sym
      if GameData::Move::DATA[move_number]
        raise _INTL("Move ID number '{1}' is used twice.\r\n{2}", move_number, FileLineData.linereport)
      elsif GameData::Move::DATA[move_symbol]
        raise _INTL("Move ID '{1}' is used twice.\r\n{2}", move_symbol, FileLineData.linereport)
      end
      # Sanitise data
      if line[6] == 2 && line[4] != 0
        raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\r\n{2}", line[2], FileLineData.linereport)
      elsif line[6] != 2 && line[4] == 0
        print _INTL("Warning: Move {1} was defined as Physical or Special but had a base damage of 0. Changing it to a Status move.\r\n{2}", line[2], FileLineData.linereport)
        line[6] = 2
      end
      # Construct move hash
      move_hash = {
        :id_number     => move_number,
        :id            => move_symbol,
        :name          => line[2],
        :function_code => line[3],
        :base_damage   => line[4],
        :type          => line[5],
        :category      => line[6],
        :accuracy      => line[7],
        :total_pp      => line[8],
        :effect_chance => line[9],
        :target        => GameData::Target.get(line[10]).id,
        :priority      => line[11],
        :flags         => line[12],
        :description   => line[13]
      }
      # Add move's data to records
      GameData::Move.register(move_hash)
      move_names[move_number]        = move_hash[:name]
      move_descriptions[move_number] = move_hash[:description]
    }
    # Save all data
    GameData::Move.save
    MessageTypes.setMessages(MessageTypes::Moves, move_names)
    MessageTypes.setMessages(MessageTypes::MoveDescriptions, move_descriptions)
    Graphics.update
  end

  #=============================================================================
  # Compile item data
  #=============================================================================
  def compile_items(path = "PBS/items.txt")
    GameData::Item::DATA.clear
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    # Read each line of items.txt at a time and compile it into an item
    pbCompilerEachCommentedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnssuusuuUN"])
      item_number = line[0]
      item_symbol = line[1].to_sym
      if GameData::Item::DATA[item_number]
        raise _INTL("Item ID number '{1}' is used twice.\r\n{2}", item_number, FileLineData.linereport)
      elsif GameData::Item::DATA[item_symbol]
        raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_symbol, FileLineData.linereport)
      end
      # Construct item hash
      item_hash = {
        :id_number   => item_number,
        :id          => item_symbol,
        :name        => line[2],
        :name_plural => line[3],
        :pocket      => line[4],
        :price       => line[5],
        :description => line[6],
        :field_use   => line[7],
        :battle_use  => line[8],
        :type        => line[9]
      }
      item_hash[:move] = parseMove(line[10]) if !nil_or_empty?(line[10])
      # Add item's data to records
      GameData::Item.register(item_hash)
      item_names[item_number]        = item_hash[:name]
      item_names_plural[item_number] = item_hash[:name_plural]
      item_descriptions[item_number] = item_hash[:description]
    }
    # Save all data
    GameData::Item.save
    MessageTypes.setMessages(MessageTypes::Items, item_names)
    MessageTypes.setMessages(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessages(MessageTypes::ItemDescriptions, item_descriptions)
    Graphics.update
  end

  #=============================================================================
  # Compile berry plant data
  #=============================================================================
  def compile_berry_plants(path = "PBS/berryplants.txt")
    GameData::BerryPlant::DATA.clear
    pbCompilerEachCommentedLine(path) { |line, line_no|
      if line[/^\s*(\w+)\s*=\s*(.*)$/]   # Of the format XXX = YYY
        key   = $1
        value = $2
        item_symbol = parseItem(key)
        item_number = GameData::Item.get(item_symbol).id_number
        line = pbGetCsvRecord(value, line_no, [0, "vuuv"])
        # Construct berry plant hash
        berry_plant_hash = {
          :id              => item_symbol,
          :id_number       => item_number,
          :hours_per_stage => line[0],
          :drying_per_hour => line[1],
          :minimum_yield   => line[2],
          :maximum_yield   => line[3]
        }
        # Add berry plant's data to records
        GameData::BerryPlant.register(berry_plant_hash)
      end
    }
    # Save all data
    GameData::BerryPlant.save
    Graphics.update
  end

  #=============================================================================
  # Compile Pokémon data
  #=============================================================================
  def compile_pokemon(path = "PBS/pokemon.txt")
    GameData::Species::DATA.clear
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema
      pbEachFileSection(f) { |contents, species_number|
        FileLineData.setSection(species_number, "header", nil)   # For error reporting
        # Raise an error if a species number is invalid or used twice
        if species_number == 0
          raise _INTL("A Pokémon species can't be numbered 0 ({1}).", path)
        elsif GameData::Species::DATA[species_number]
          raise _INTL("Species ID number '{1}' is used twice.\r\n{2}", species_number, FileLineData.linereport)
        end
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties, or raise an error if a required property is
          # empty
          if nil_or_empty?(contents[key])
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, species_number)
            end
            contents[key] = nil
            next
          end
          # Raise an error if a species internal name is used twice
          FileLineData.setSection(species_number, key, contents[key])   # For error reporting
          if GameData::Species::DATA[contents["InternalName"].to_sym]
            raise _INTL("Species ID '{1}' is used twice.\r\n{2}", contents["InternalName"], FileLineData.linereport)
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Sanitise data
          case key
          when "BaseStats", "EffortPoints"
            value_hash = {}
            GameData::Stat.each_main do |s|
              value_hash[s.id] = value[s.pbs_order] if s.pbs_order >= 0
            end
            contents[key] = value_hash
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, {3})", key, species_number, path)
            end
            contents[key] = value
          when "Moves"
            move_array = []
            for i in 0...value.length / 2
              move_array.push([value[i * 2], value[i * 2 + 1], i])
            end
            move_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=>b [0] }
            move_array.each { |arr| arr.pop }
            contents[key] = move_array
          when "TutorMoves", "EggMoves", "Abilities", "HiddenAbility", "Compatibility"
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].compact!
          when "Evolutions"
            evo_array = []
            for i in 0...value.length / 3
              evo_array.push([value[i * 3], value[i * 3 + 1], value[i * 3 + 2], false])
            end
            contents[key] = evo_array
          end
        end
        # Construct species hash
        species_symbol = contents["InternalName"].to_sym
        species_hash = {
          :id                    => species_symbol,
          :id_number             => species_number,
          :name                  => contents["Name"],
          :form_name             => contents["FormName"],
          :category              => contents["Kind"],
          :pokedex_entry         => contents["Pokedex"],
          :type1                 => contents["Type1"],
          :type2                 => contents["Type2"],
          :base_stats            => contents["BaseStats"],
          :evs                   => contents["EffortPoints"],
          :base_exp              => contents["BaseEXP"],
          :growth_rate           => contents["GrowthRate"],
          :gender_ratio          => contents["GenderRate"],
          :catch_rate            => contents["Rareness"],
          :happiness             => contents["Happiness"],
          :moves                 => contents["Moves"],
          :tutor_moves           => contents["TutorMoves"],
          :egg_moves             => contents["EggMoves"],
          :abilities             => contents["Abilities"],
          :hidden_abilities      => contents["HiddenAbility"],
          :wild_item_common      => contents["WildItemCommon"],
          :wild_item_uncommon    => contents["WildItemUncommon"],
          :wild_item_rare        => contents["WildItemRare"],
          :egg_groups            => contents["Compatibility"],
          :hatch_steps           => contents["StepsToHatch"],
          :incense               => contents["Incense"],
          :evolutions            => contents["Evolutions"],
          :height                => contents["Height"],
          :weight                => contents["Weight"],
          :color                 => contents["Color"],
          :shape                 => GameData::BodyShape.get(contents["Shape"]).id,
          :habitat               => contents["Habitat"],
          :generation            => contents["Generation"],
          :back_sprite_x         => contents["BattlerPlayerX"],
          :back_sprite_y         => contents["BattlerPlayerY"],
          :front_sprite_x        => contents["BattlerEnemyX"],
          :front_sprite_y        => contents["BattlerEnemyY"],
          :front_sprite_altitude => contents["BattlerAltitude"],
          :shadow_x              => contents["BattlerShadowX"],
          :shadow_size           => contents["BattlerShadowSize"]
        }
        # Add species' data to records
        GameData::Species.register(species_hash)
        species_names[species_number]           = species_hash[:name]
        species_form_names[species_number]      = species_hash[:form_name]
        species_categories[species_number]      = species_hash[:category]
        species_pokedex_entries[species_number] = species_hash[:pokedex_entry]
      }
    }
    # Enumerate all evolution species and parameters (this couldn't be done earlier)
    GameData::Species.each do |species|
      FileLineData.setSection(species.id_number, "Evolutions", nil)   # For error reporting
      Graphics.update if species.id_number % 200 == 0
      pbSetWindowText(_INTL("Processing {1} evolution line {2}", FileLineData.file, species.id_number)) if species.id_number % 50 == 0
      species.evolutions.each do |evo|
        evo[0] = csvEnumField!(evo[0], :Species, "Evolutions", species.id_number)
        param_type = GameData::Evolution.get(evo[1]).parameter
        if param_type.nil?
          evo[2] = nil
        elsif param_type == Integer
          evo[2] = csvPosInt!(evo[2])
        else
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", species.id_number)
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
    # Save all data
    GameData::Species.save
    MessageTypes.setMessages(MessageTypes::Species, species_names)
    MessageTypes.setMessages(MessageTypes::FormNames, species_form_names)
    MessageTypes.setMessages(MessageTypes::Kinds, species_categories)
    MessageTypes.setMessages(MessageTypes::Entries, species_pokedex_entries)
    Graphics.update
  end

  #=============================================================================
  # Compile Pokémon forms data
  #=============================================================================
  def compile_pokemon_forms(path = "PBS/pokemonforms.txt")
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    used_forms = {}
    # Get maximum species ID number
    form_number = 0
    GameData::Species.each do |species|
      form_number = species.id_number if form_number < species.id_number
    end
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema(true)
      pbEachFileSection2(f) { |contents, section_name|
        FileLineData.setSection(section_name, "header", nil)   # For error reporting
        # Split section_name into a species number and form number
        split_section_name = section_name.split(/[-,\s]/)
        if split_section_name.length != 2
          raise _INTL("Section name {1} is invalid ({2}). Expected syntax like [XXX,Y] (XXX=internal name, Y=form number).", sectionName, path)
        end
        species_symbol = csvEnumField!(split_section_name[0], :Species, nil, nil)
        form           = csvPosInt!(split_section_name[1])
        # Raise an error if a species is undefined, the form number is invalid or
        # a species/form combo is used twice
        if !GameData::Species.exists?(species_symbol)
          raise _INTL("Species ID '{1}' is not defined in {2}.\r\n{3}", species_symbol, path, FileLineData.linereport)
        elsif form == 0
          raise _INTL("A form cannot be defined with a form number of 0.\r\n{1}", FileLineData.linereport)
        elsif used_forms[species_symbol] && used_forms[species_symbol].include?(form)
          raise _INTL("Form {1} for species ID {2} is defined twice.\r\n{3}", form, species_symbol, FileLineData.linereport)
        end
        used_forms[species_symbol] = [] if !used_forms[species_symbol]
        used_forms[species_symbol].push(form)
        form_number += 1
        base_data = GameData::Species.get(species_symbol)
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties (none are required)
          if nil_or_empty?(contents[key])
            contents[key] = nil
            next
          end
          FileLineData.setSection(section_name, key, contents[key])   # For error reporting
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Sanitise data
          case key
          when "BaseStats", "EffortPoints"
            value_hash = {}
            GameData::Stat.each_main do |s|
              value_hash[s.id] = value[s.pbs_order] if s.pbs_order >= 0
            end
            contents[key] = value_hash
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, {3})", key, section_name, path)
            end
            contents[key] = value
          when "Moves"
            move_array = []
            for i in 0...value.length / 2
              move_array.push([value[i * 2], value[i * 2 + 1], i])
            end
            move_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=>b [0] }
            move_array.each { |arr| arr.pop }
            contents[key] = move_array
          when "TutorMoves", "EggMoves", "Abilities", "HiddenAbility", "Compatibility"
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].compact!
          when "Evolutions"
            evo_array = []
            for i in 0...value.length / 3
              param_type = GameData::Evolution.get(value[i * 3 + 1]).parameter
              param = value[i * 3 + 2]
              if param_type.nil?
                param = nil
              elsif param_type == Integer
                param = csvPosInt!(param)
              else
                param = csvEnumField!(param, param_type, "Evolutions", section_name)
              end
              evo_array.push([value[i * 3], value[i * 3 + 1], param, false])
            end
            contents[key] = evo_array
          end
        end
        # Construct species hash
        form_symbol = sprintf("%s_%d", species_symbol.to_s, form).to_sym
        moves = contents["Moves"]
        if !moves
          moves = []
          base_data.moves.each { |m| moves.push(m.clone) }
        end
        evolutions = contents["Evolutions"]
        if !evolutions
          evolutions = []
          base_data.evolutions.each { |e| evolutions.push(e.clone) }
        end
        species_hash = {
          :id                    => form_symbol,
          :id_number             => form_number,
          :species               => species_symbol,
          :form                  => form,
          :name                  => base_data.real_name,
          :form_name             => contents["FormName"],
          :category              => contents["Kind"] || base_data.real_category,
          :pokedex_entry         => contents["Pokedex"] || base_data.real_pokedex_entry,
          :pokedex_form          => contents["PokedexForm"],
          :type1                 => contents["Type1"] || base_data.type1,
          :type2                 => contents["Type2"] || base_data.type2,
          :base_stats            => contents["BaseStats"] || base_data.base_stats,
          :evs                   => contents["EffortPoints"] || base_data.evs,
          :base_exp              => contents["BaseEXP"] || base_data.base_exp,
          :growth_rate           => base_data.growth_rate,
          :gender_ratio          => base_data.gender_ratio,
          :catch_rate            => contents["Rareness"] || base_data.catch_rate,
          :happiness             => contents["Happiness"] || base_data.happiness,
          :moves                 => moves,
          :tutor_moves           => contents["TutorMoves"] || base_data.tutor_moves.clone,
          :egg_moves             => contents["EggMoves"] || base_data.egg_moves.clone,
          :abilities             => contents["Abilities"] || base_data.abilities.clone,
          :hidden_abilities      => contents["HiddenAbility"] || base_data.hidden_abilities.clone,
          :wild_item_common      => contents["WildItemCommon"] || base_data.wild_item_common,
          :wild_item_uncommon    => contents["WildItemUncommon"] || base_data.wild_item_uncommon,
          :wild_item_rare        => contents["WildItemRare"] || base_data.wild_item_rare,
          :egg_groups            => contents["Compatibility"] || base_data.egg_groups.clone,
          :hatch_steps           => contents["StepsToHatch"] || base_data.hatch_steps,
          :incense               => base_data.incense,
          :evolutions            => evolutions,
          :height                => contents["Height"] || base_data.height,
          :weight                => contents["Weight"] || base_data.weight,
          :color                 => contents["Color"] || base_data.color,
          :shape                 => (contents["Shape"]) ? GameData::BodyShape.get(contents["Shape"]).id : base_data.shape,
          :habitat               => contents["Habitat"] || base_data.habitat,
          :generation            => contents["Generation"] || base_data.generation,
          :mega_stone            => contents["MegaStone"],
          :mega_move             => contents["MegaMove"],
          :unmega_form           => contents["UnmegaForm"],
          :mega_message          => contents["MegaMessage"],
          :back_sprite_x         => contents["BattlerPlayerX"] || base_data.back_sprite_x,
          :back_sprite_y         => contents["BattlerPlayerY"] || base_data.back_sprite_y,
          :front_sprite_x        => contents["BattlerEnemyX"] || base_data.front_sprite_x,
          :front_sprite_y        => contents["BattlerEnemyY"] || base_data.front_sprite_y,
          :front_sprite_altitude => contents["BattlerAltitude"] || base_data.front_sprite_altitude,
          :shadow_x              => contents["BattlerShadowX"] || base_data.shadow_x,
          :shadow_size           => contents["BattlerShadowSize"] || base_data.shadow_size
        }
        # If form is single-typed, ensure it remains so if base species is dual-typed
        species_hash[:type2] = contents["Type1"] if contents["Type1"] && !contents["Type2"]
        # If form has any wild items, ensure none are inherited from base species
        if contents["WildItemCommon"] || contents["WildItemUncommon"] || contents["WildItemRare"]
          species_hash[:wild_item_common]   = contents["WildItemCommon"]
          species_hash[:wild_item_uncommon] = contents["WildItemUncommon"]
          species_hash[:wild_item_rare]     = contents["WildItemRare"]
        end
        # Add form's data to records
        GameData::Species.register(species_hash)
        species_names[form_number]           = species_hash[:name]
        species_form_names[form_number]      = species_hash[:form_name]
        species_categories[form_number]      = species_hash[:category]
        species_pokedex_entries[form_number] = species_hash[:pokedex_entry]
      }
    }
    # Add prevolution "evolution" entry for all evolved forms that define their
    # own evolution methods (and thus won't have a prevolution listed already)
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      species.evolutions.each do |evo|
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] if !evo[3] && !all_evos[evo[0]]
      end
    end
    GameData::Species.each do |species|   # Distribute prevolutions
      next if species.form == 0   # Looking at alternate forms only
      next if species.evolutions.any? { |evo| evo[3] }   # Already has prevo listed
      species.evolutions.push(all_evos[species.species].clone) if all_evos[species.species]
    end
    # Save all data
    GameData::Species.save
    MessageTypes.addMessages(MessageTypes::Species, species_names)
    MessageTypes.addMessages(MessageTypes::FormNames, species_form_names)
    MessageTypes.addMessages(MessageTypes::Kinds, species_categories)
    MessageTypes.addMessages(MessageTypes::Entries, species_pokedex_entries)
    Graphics.update
  end

  #=============================================================================
  # Compile TM/TM/Move Tutor compatibilities
  #=============================================================================
  def compile_move_compatibilities(path = "PBS/tm.txt")
    return if !safeExists?(path)
    species_hash = {}
    move = nil
    pbCompilerEachCommentedLine(path) { |line, line_no|
      Graphics.update if line_no % 50 == 0
      if line[/^\s*\[\s*(\S+)\s*\]\s*$/]
        move = parseMove($~[1])
        pbSetWindowText(_INTL("Processing {1} section [{2}]", FileLineData.file, move))
      else
        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport) if !move
        species_list = line.split(",")
        for species in species_list
          next if !species || species.empty?
          s = parseSpecies(species)
          species_hash[s] = [] if !species_hash[s]
          species_hash[s].push(move)
        end
      end
    }
    GameData::Species.each do |species_data|
      next if !species_hash[species_data.id]
      species_hash[species_data.id].sort! { |a, b| a.to_s <=> b.to_s }
      species_hash[species_data.id].each { |move| species_data.tutor_moves.push(move) }
    end
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
    begin
      File.delete(path) if path == "PBS/tm.txt"
    rescue SystemCallError
    end
  end

  #=============================================================================
  # Compile Shadow movesets
  #=============================================================================
  def compile_shadow_movesets(path = "PBS/shadowmoves.txt")
    sections = {}
    if safeExists?(path)
      pbCompilerEachCommentedLine(path) { |line, _line_no|
        if line[/^\s*(\w+)\s*=\s*(.*)$/]
          key   = $1
          value = $2
          value = value.split(",")
          species = parseSpecies(key)
          moves = []
          for i in 0...[Pokemon::MAX_MOVES, value.length].min
            move = parseMove(value[i], true)
            moves.push(move) if move
          end
          moves.compact!
          sections[species] = moves if moves.length > 0
        end
      }
    end
    save_data(sections, "Data/shadow_movesets.dat")
  end

  #=============================================================================
  # Compile Regional Dexes
  #=============================================================================
  def compile_regional_dexes(path = "PBS/regionaldexes.txt")
    dex_lists = []
    section = nil
    pbCompilerEachPreppedLine(path) { |line, line_no|
      Graphics.update if line_no % 200 == 0
      if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
        section = $~[1].to_i
        if dex_lists[section]
          raise _INTL("Dex list number {1} is defined at least twice.\r\n{2}", section, FileLineData.linereport)
        end
        dex_lists[section] = []
        pbSetWindowText(_INTL("Processing {1} section [{2}]", FileLineData.file, section))
      else
        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport) if !section
        species_list = line.split(",")
        for species in species_list
          next if !species || species.empty?
          s = parseSpecies(species)
          dex_lists[section].push(s)
        end
      end
    }
    # Check for duplicate species in a Regional Dex
    dex_lists.each_with_index do |list, index|
      unique_list = list.uniq
      next if list == unique_list
      list.each_with_index do |s, i|
        next if unique_list[i] == s
        raise _INTL("Dex list number {1} has species {2} listed twice.\r\n{3}", index, s, FileLineData.linereport)
      end
    end
    # Save all data
    save_data(dex_lists, "Data/regional_dexes.dat")
    Graphics.update
  end

  #=============================================================================
  # Compile ribbon data
  #=============================================================================
  def compile_ribbons(path = "PBS/ribbons.txt")
    GameData::Ribbon::DATA.clear
    ribbon_names        = []
    ribbon_descriptions = []
    pbCompilerEachPreppedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnss"])
      ribbon_number = line[0]
      ribbon_symbol = line[1].to_sym
      if GameData::Ribbon::DATA[ribbon_number]
        raise _INTL("Ribbon ID number '{1}' is used twice.\r\n{2}", ribbon_number, FileLineData.linereport)
      elsif GameData::Ribbon::DATA[ribbon_symbol]
        raise _INTL("Ribbon ID '{1}' is used twice.\r\n{2}", ribbon_symbol, FileLineData.linereport)
      end
      # Construct ribbon hash
      ribbon_hash = {
        :id          => ribbon_symbol,
        :id_number   => ribbon_number,
        :name        => line[2],
        :description => line[3]
      }
      # Add ribbon's data to records
      GameData::Ribbon.register(ribbon_hash)
      ribbon_names[ribbon_number]        = ribbon_hash[:name]
      ribbon_descriptions[ribbon_number] = ribbon_hash[:description]
    }
    # Save all data
    GameData::Ribbon.save
    MessageTypes.setMessages(MessageTypes::RibbonNames, ribbon_names)
    MessageTypes.setMessages(MessageTypes::RibbonDescriptions, ribbon_descriptions)
    Graphics.update
  end

  #=============================================================================
  # Compile wild encounter data
  #=============================================================================
  def compile_encounters(path = "PBS/encounters.txt")
    new_format        = nil
    encounter_hash    = nil
    step_chances      = nil
    need_step_chances = false   # Not needed for new format only
    probabilities     = nil     # Not needed for new format only
    current_type      = nil
    expected_lines    = 0
    max_level = GameData::GrowthRate.max_level
    pbCompilerEachPreppedLine(path) { |line, line_no|
      next if line.length == 0
      if expected_lines > 0 && line[/^\d+,/] && new_format   # Species line (new format)
        values = line.split(',').collect! { |v| v.strip }
        if !values || values.length < 3
          raise _INTL("Expected a species entry line for encounter type {1} for map '{2}', got \"{3}\" instead.\r\n{4}",
             GameData::EncounterType.get(current_type).real_name, encounter_hash[:map], line, FileLineData.linereport)
        end
        values = pbGetCsvRecord(line, line_no, [0, "vevV", nil, :Species])
        values[3] = values[2] if !values[3]
        if values[2] > max_level
          raise _INTL("Level number {1} is not valid (max. {2}).\r\n{3}", values[2], max_level, FileLineData.linereport)
        elsif values[3] > max_level
          raise _INTL("Level number {1} is not valid (max. {2}).\r\n{3}", values[3], max_level, FileLineData.linereport)
        elsif values[2] > values[3]
          raise _INTL("Minimum level is greater than maximum level: {1}\r\n{2}", line, FileLineData.linereport)
        end
        encounter_hash[:types][current_type].push(values)
      elsif expected_lines > 0 && !new_format   # Expect a species line and nothing else (old format)
        values = line.split(',').collect! { |v| v.strip }
        if !values || values.length < 2
          raise _INTL("Expected a species entry line for encounter type {1} for map '{2}', got \"{3}\" instead.\r\n{4}",
             GameData::EncounterType.get(current_type).real_name, encounter_hash[:map], line, FileLineData.linereport)
        end
        values = pbGetCsvRecord(line, line_no, [0, "evV", :Species])
        values[2] = values[1] if !values[2]
        if values[1] > max_level
          raise _INTL("Level number {1} is not valid (max. {2}).\r\n{3}", values[1], max_level, FileLineData.linereport)
        elsif values[2] > max_level
          raise _INTL("Level number {1} is not valid (max. {2}).\r\n{3}", values[2], max_level, FileLineData.linereport)
        elsif values[1] > values[2]
          raise _INTL("Minimum level is greater than maximum level: {1}\r\n{2}", line, FileLineData.linereport)
        end
        probability = probabilities[probabilities.length - expected_lines]
        encounter_hash[:types][current_type].push([probability] + values)
        expected_lines -= 1
      elsif line[/^\[\s*(.+)\s*\]$/]   # Map ID line (new format)
        if new_format == false
          raise _INTL("Can't mix old and new formats.\r\n{1}", FileLineData.linereport)
        end
        new_format = true
        values = $~[1].split(',').collect! { |v| v.strip.to_i }
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
          raise _INTL("Encounters for map '{1}' are defined twice.\r\n{2}", map_number, FileLineData.linereport)
        end
        step_chances = {}
        # Construct encounter hash
        encounter_hash = {
          :id           => key,
          :map          => map_number,
          :version      => map_version,
          :step_chances => step_chances,
          :types        => {}
        }
        current_type = nil
        need_step_chances = true
        expected_lines = 0
      elsif line[/^(\d+)$/]   # Map ID line (old format)
        if new_format == true
          raise _INTL("Can't mix old and new formats.\r\n{1}", FileLineData.linereport)
        end
        new_format = false
        map_number = $~[1].to_i
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
        key = sprintf("%s_0", map_number).to_sym
        if GameData::Encounter::DATA[key]
          raise _INTL("Encounters for map '{1}' are defined twice.\r\n{2}", map_number, FileLineData.linereport)
        end
        step_chances = {}
        # Construct encounter hash
        encounter_hash = {
          :id           => key,
          :map          => map_number,
          :version      => 0,
          :step_chances => step_chances,
          :types        => {}
        }
        current_type = nil
        need_step_chances = true
      elsif !encounter_hash   # File began with something other than a map ID line
        raise _INTL("Expected a map number, got \"{1}\" instead.\r\n{2}", line, FileLineData.linereport)
      elsif line[/^(\d+)\s*,/] && !new_format   # Step chances line
        if !need_step_chances
          raise _INTL("Encounter densities are defined twice or\r\nnot immediately for map '{1}'.\r\n{2}",
             encounter_hash[:map], FileLineData.linereport)
        end
        need_step_chances = false
        values = pbGetCsvRecord(line, line_no, [0, "vvv"])
        GameData::EncounterType.each do |enc_type|
          case enc_type.id
          when :land, :contest then step_chances[enc_type.id] = values[0]
          when :cave           then step_chances[enc_type.id] = values[1]
          when :water          then step_chances[enc_type.id] = values[2]
          end
        end
      else
        # Check if line is an encounter method name or not
        values = line.split(',').collect! { |v| v.strip }
        current_type = (values[0] && !values[0].empty?) ? values[0].to_sym : nil
        if current_type && GameData::EncounterType.exists?(current_type)   # Start of a new encounter method
          need_step_chances = false
          step_chances[current_type] = values[1].to_i if values[1] && !values[1].empty?
          step_chances[current_type] ||= GameData::EncounterType.get(current_type).trigger_chance
          probabilities = GameData::EncounterType.get(current_type).old_slots
          expected_lines = probabilities.length
          encounter_hash[:types][current_type] = []
        else
          raise _INTL("Undefined encounter type \"{1}\" for map '{2}'.\r\n{3}",
             line, encounter_hash[:map], FileLineData.linereport)
        end
      end
    }
    if expected_lines > 0 && !new_format
      raise _INTL("Not enough encounter lines given for encounter type {1} for map '{2}' (expected {3}).\r\n{4}",
         GameData::EncounterType.get(current_type).real_name, encounter_hash[:map], probabilities.length, FileLineData.linereport)
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
    # Save all data
    GameData::Encounter.save
    Graphics.update
  end

  #=============================================================================
  # Compile trainer type data
  #=============================================================================
  def compile_trainer_types(path = "PBS/trainertypes.txt")
    GameData::TrainerType::DATA.clear
    tr_type_names = []
    # Read each line of trainertypes.txt at a time and compile it into a trainer type
    pbCompilerEachCommentedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "unsUSSSeUS",
        nil, nil, nil, nil, nil, nil, nil, {
        "Male"   => 0, "M" => 0, "0" => 0,
        "Female" => 1, "F" => 1, "1" => 1,
        "Mixed"  => 2, "X" => 2, "2" => 2, "" => 2
        }, nil, nil]
      )
      type_number = line[0]
      type_symbol = line[1].to_sym
      if GameData::TrainerType::DATA[type_number]
        raise _INTL("Trainer type ID number '{1}' is used twice.\r\n{2}", type_number, FileLineData.linereport)
      elsif GameData::TrainerType::DATA[type_symbol]
        raise _INTL("Trainer type ID '{1}' is used twice.\r\n{2}", type_symbol, FileLineData.linereport)
      end
      # Construct trainer type hash
      type_hash = {
        :id_number   => type_number,
        :id          => type_symbol,
        :name        => line[2],
        :base_money  => line[3],
        :battle_BGM  => line[4],
        :victory_ME  => line[5],
        :intro_ME    => line[6],
        :gender      => line[7],
        :skill_level => line[8],
        :skill_code  => line[9]
      }
      # Add trainer type's data to records
      GameData::TrainerType.register(type_hash)
      tr_type_names[type_number] = type_hash[:name]
    }
    # Save all data
    GameData::TrainerType.save
    MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile individual trainer data
  #=============================================================================
  def compile_trainers(path = "PBS/trainers.txt")
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names             = []
    trainer_lose_texts        = []
    trainer_hash              = nil
    trainer_id                = -1
    current_pkmn              = nil
    old_format_current_line   = 0
    old_format_expected_lines = 0
    # Read each line of trainers.txt at a time and compile it as a trainer property
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if old_format_current_line > 0
            raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
          end
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        trainer_id += 1
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :id_number    => trainer_id,
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names[trainer_id] = trainer_hash[:name]
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Items"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.uniq!
          property_value.compact!
        when "IV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "Ability"
            if property_value[/^\d+$/]
              current_pkmn[:ability_index] = property_value.to_i
            elsif !GameData::Ability.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Ability.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          when "Ball"
            if property_value[/^\d+$/]
              current_pkmn[line_schema[0]] = pbBallTypeToItem(property_value.to_i).id
            elsif !GameData::Item.exists?(property_value.to_sym) ||
               !GameData::Item.get(property_value.to_sym).is_poke_ball?
              raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      else
        # Old format - backwards compatibility is SUCH fun!
        if old_format_current_line == 0   # Started an old trainer section
          if trainer_hash
            if !current_pkmn
              raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
            end
            # Add trainer's data to records
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
          end
          trainer_id += 1
          old_format_expected_lines = 3
          # Construct trainer hash
          trainer_hash = {
            :id_number    => trainer_id,
            :trainer_type => nil,
            :name         => nil,
            :version      => 0,
            :pokemon      => []
          }
          current_pkmn = nil
        end
        # Evaluate line and add to hash
        old_format_current_line += 1
        case old_format_current_line
        when 1   # Trainer type
          line_data = pbGetCsvRecord(line, line_no, [0, "e", :TrainerType])
          trainer_hash[:trainer_type] = line_data
        when 2   # Trainer name, version number
          line_data = pbGetCsvRecord(line, line_no, [0, "sU"])
          line_data = [line_data] if !line_data.is_a?(Array)
          trainer_hash[:name]    = line_data[0]
          trainer_hash[:version] = line_data[1] if line_data[1]
          trainer_names[trainer_hash[:id_number]] = line_data[0]
        when 3   # Number of Pokémon, items
          line_data = pbGetCsvRecord(line, line_no,
             [0, "vEEEEEEEE", nil, :Item, :Item, :Item, :Item, :Item, :Item, :Item, :Item])
          line_data = [line_data] if !line_data.is_a?(Array)
          line_data.compact!
          old_format_expected_lines += line_data[0]
          line_data.shift
          trainer_hash[:items] = line_data if line_data.length > 0
        else   # Pokémon lines
          line_data = pbGetCsvRecord(line, line_no,
             [0, "evEEEEEUEUBEUUSBU", :Species, nil, :Item, :Move, :Move, :Move, :Move, nil,
                                      {"M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1},
                                      nil, nil, :Nature, nil, nil, nil, nil, nil])
          current_pkmn = {
            :species => line_data[0]
          }
          trainer_hash[:pokemon].push(current_pkmn)
          # Error checking in properties
          line_data.each_with_index do |value, i|
            next if value.nil?
            case i
            when 1   # Level
              if value > max_level
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", value, max_level, FileLineData.linereport)
              end
            when 12   # IV
              if value > Pokemon::IV_STAT_LIMIT
                raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", value, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
              end
            when 13   # Happiness
              if value > 255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", value, FileLineData.linereport)
              end
            when 14   # Nickname
              if value.length > Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            end
          end
          # Write all line data to hash
          moves = [line_data[3], line_data[4], line_data[5], line_data[6]]
          moves.uniq!.compact!
          ivs = {}
          if line_data[12]
            GameData::Stat.each_main do |s|
              ivs[s.id] = line_data[12] if s.pbs_order >= 0
            end
          end
          current_pkmn[:level]         = line_data[1]
          current_pkmn[:item]          = line_data[2] if line_data[2]
          current_pkmn[:moves]         = moves if moves.length > 0
          current_pkmn[:ability_index] = line_data[7] if line_data[7]
          current_pkmn[:gender]        = line_data[8] if line_data[8]
          current_pkmn[:form]          = line_data[9] if line_data[9]
          current_pkmn[:shininess]     = line_data[10] if line_data[10]
          current_pkmn[:nature]        = line_data[11] if line_data[11]
          current_pkmn[:iv]            = ivs if ivs.length > 0
          current_pkmn[:happiness]     = line_data[13] if line_data[13]
          current_pkmn[:name]          = line_data[14] if line_data[14] && !line_data[14].empty?
          current_pkmn[:shadowness]    = line_data[15] if line_data[15]
          current_pkmn[:poke_ball]     = line_data[16] if line_data[16]
          # Check if this is the last expected Pokémon
          old_format_current_line = 0 if old_format_current_line >= old_format_expected_lines
        end
      end
    }
    if old_format_current_line > 0
      raise _INTL("Unexpected end of file, last trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
    end
    # Add last trainer's data to records
    if trainer_hash
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    Graphics.update
  end

  #=============================================================================
  # Compile Battle Tower and other Cups trainers/Pokémon
  #=============================================================================
  def compile_trainer_lists(path = "PBS/trainerlists.txt")
    btTrainersRequiredTypes = {
      "Trainers"   => [0, "s"],
      "Pokemon"    => [1, "s"],
      "Challenges" => [2, "*s"]
    }
    if !safeExists?(path)
      File.open(path, "wb") { |f|
        f.write(0xEF.chr)
        f.write(0xBB.chr)
        f.write(0xBF.chr)
        f.write("[DefaultTrainerList]\r\n")
        f.write("Trainers = bttrainers.txt\r\n")
        f.write("Pokemon = btpokemon.txt\r\n")
      }
    end
    sections = []
    MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,[])
    MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,[])
    MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,[])
    File.open(path, "rb") { |f|
      FileLineData.file = path
      pbEachFileSectionEx(f) { |section,name|
        next if name!="DefaultTrainerList" && name!="TrainerList"
        rsection = []
        for key in section.keys
          FileLineData.setSection(name,key,section[key])
          schema = btTrainersRequiredTypes[key]
          next if key=="Challenges" && name=="DefaultTrainerList"
          next if !schema
          record = pbGetCsvRecord(section[key],0,schema)
          rsection[schema[0]] = record
        end
        if !rsection[0]
          raise _INTL("No trainer data file given in section {1}.\r\n{2}",name,FileLineData.linereport)
        end
        if !rsection[1]
          raise _INTL("No trainer data file given in section {1}.\r\n{2}",name,FileLineData.linereport)
        end
        rsection[3] = rsection[0]
        rsection[4] = rsection[1]
        rsection[5] = (name=="DefaultTrainerList")
        if safeExists?("PBS/"+rsection[0])
          rsection[0] = compile_battle_tower_trainers("PBS/"+rsection[0])
        else
          rsection[0] = []
        end
        if safeExists?("PBS/"+rsection[1])
          filename = "PBS/"+rsection[1]
          rsection[1] = []
          pbCompilerEachCommentedLine(filename) { |line,_lineno|
            rsection[1].push(PBPokemon.fromInspected(line))
          }
        else
          rsection[1] = []
        end
        rsection[2] = [] if !rsection[2]
        while rsection[2].include?("")
          rsection[2].delete("")
        end
        rsection[2].compact!
        sections.push(rsection)
      }
    }
    save_data(sections,"Data/trainer_lists.dat")
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
    if safeExists?(filename)
      File.open(filename,"rb") { |f|
        FileLineData.file = filename
        pbEachFileSectionEx(f) { |section,name|
          rsection = []
          for key in section.keys
            FileLineData.setSection(name,key,section[key])
            schema = requiredtypes[key]
            next if !schema
            record = pbGetCsvRecord(section[key],0,schema)
            rsection[schema[0]] = record
          end
          trainernames.push(rsection[1])
          beginspeech.push(rsection[2])
          endspeechwin.push(rsection[3])
          endspeechlose.push(rsection[4])
          sections.push(rsection)
        }
      }
    end
    MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,trainernames)
    MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,beginspeech)
    MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,endspeechwin)
    MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,endspeechlose)
    return sections
  end

  #=============================================================================
  # Compile metadata
  #=============================================================================
  def compile_metadata(path = "PBS/metadata.txt")
    GameData::Metadata::DATA.clear
    GameData::MapMetadata::DATA.clear
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSection(f) { |contents, map_id|
        schema = (map_id == 0) ? GameData::Metadata::SCHEMA : GameData::MapMetadata::SCHEMA
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          FileLineData.setSection(map_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if map_id == 0 && ["Home", "PlayerA"].include?(key)
              raise _INTL("The entry {1} is required in {2} section 0.", key, path)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
        end
        if map_id == 0   # Global metadata
          # Construct metadata hash
          metadata_hash = {
            :id                 => map_id,
            :home               => contents["Home"],
            :wild_battle_BGM    => contents["WildBattleBGM"],
            :trainer_battle_BGM => contents["TrainerBattleBGM"],
            :wild_victory_ME    => contents["WildVictoryME"],
            :trainer_victory_ME => contents["TrainerVictoryME"],
            :wild_capture_ME    => contents["WildCaptureME"],
            :surf_BGM           => contents["SurfBGM"],
            :bicycle_BGM        => contents["BicycleBGM"],
            :player_A           => contents["PlayerA"],
            :player_B           => contents["PlayerB"],
            :player_C           => contents["PlayerC"],
            :player_D           => contents["PlayerD"],
            :player_E           => contents["PlayerE"],
            :player_F           => contents["PlayerF"],
            :player_G           => contents["PlayerG"],
            :player_H           => contents["PlayerH"]
          }
          # Add metadata's data to records
          GameData::Metadata.register(metadata_hash)
        else   # Map metadata
          # Construct metadata hash
          metadata_hash = {
            :id                   => map_id,
            :outdoor_map          => contents["Outdoor"],
            :announce_location    => contents["ShowArea"],
            :can_bicycle          => contents["Bicycle"],
            :always_bicycle       => contents["BicycleAlways"],
            :teleport_destination => contents["HealingSpot"],
            :weather              => contents["Weather"],
            :town_map_position    => contents["MapPosition"],
            :dive_map_id          => contents["DiveMap"],
            :dark_map             => contents["DarkMap"],
            :safari_map           => contents["SafariMap"],
            :snap_edges           => contents["SnapEdges"],
            :random_dungeon       => contents["Dungeon"],
            :battle_background    => contents["BattleBack"],
            :wild_battle_BGM      => contents["WildBattleBGM"],
            :trainer_battle_BGM   => contents["TrainerBattleBGM"],
            :wild_victory_ME      => contents["WildVictoryME"],
            :trainer_victory_ME   => contents["TrainerVictoryME"],
            :wild_capture_ME      => contents["WildCaptureME"],
            :town_map_size        => contents["MapSize"],
            :battle_environment   => contents["Environment"]
          }
          # Add metadata's data to records
          GameData::MapMetadata.register(metadata_hash)
        end
      }
    }
    # Save all data
    GameData::Metadata.save
    GameData::MapMetadata.save
    Graphics.update
  end

  #=============================================================================
  # Compile battle animations
  #=============================================================================
  def compile_animations
    begin
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    rescue
      pbanims = PBAnimations.new
    end
    changed = false
    move2anim = [[],[]]
=begin
    anims = load_data("Data/Animations.rxdata")
    for anim in anims
      next if !anim || anim.frames.length==1
      found = false
      for i in 0...pbanims.length
        if pbanims[i] && pbanims[i].id==anim.id
          found = true if pbanims[i].array.length>1
          break
        end
      end
      pbanims[anim.id] = pbConvertRPGAnimation(anim) if !found
    end
=end
    for i in 0...pbanims.length
      next if !pbanims[i]
      if pbanims[i].name[/^OppMove\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id_number
          changed = true if !move2anim[0][moveid] || move2anim[1][moveid] != i
          move2anim[1][moveid] = i
        end
      elsif pbanims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id_number
          changed = true if !move2anim[0][moveid] || move2anim[0][moveid] != i
          move2anim[0][moveid] = i
        end
      end
    end
    if changed
      save_data(move2anim,"Data/move2anim.dat")
      save_data(pbanims,"Data/PkmnAnimations.rxdata")
    end
  end
end
