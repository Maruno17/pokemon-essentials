module Compiler
  module_function

  #=============================================================================
  # Compile metadata
  #=============================================================================
  def compile_metadata
    GameData::Metadata::DATA.clear
    GameData::MapMetadata::DATA.clear
    # Read from PBS file
    File.open("PBS/metadata.txt", "rb") { |f|
      FileLineData.file = "PBS/metadata.txt"   # For error reporting
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
              raise _INTL("The entry {1} is required in PBS/metadata.txt section 0.", key)
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
          GameData::Metadata::DATA[map_id] = GameData::Metadata.new(metadata_hash)
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
          GameData::MapMetadata::DATA[map_id] = GameData::MapMetadata.new(metadata_hash)
        end
      }
    }
    # Save all data
    GameData::Metadata.save
    GameData::MapMetadata.save
    Graphics.update
  end

  #=============================================================================
  # Compile town map points
  #=============================================================================
  def compile_town_map
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
    pbCompilerEachCommentedLine("PBS/townmap.txt") { |line,lineno|
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
  def compile_connections
    records   = []
    pbCompilerEachPreppedLine("PBS/connections.txt") { |line,lineno|
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
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0])) &&
         !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[0]))
        print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}",record[0],FileLineData.linereport)
      end
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3])) &&
         !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[3]))
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
  # Compile berry plants
  #=============================================================================
  def compile_berry_plants
    GameData::BerryPlant::DATA.clear
    pbCompilerEachCommentedLine("PBS/berryplants.txt") { |line, line_no|
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
        GameData::BerryPlant::DATA[item_number] = GameData::BerryPlant::DATA[item_symbol] = GameData::BerryPlant.new(berry_plant_hash)
      end
    }
    # Save all data
    GameData::BerryPlant.save
    Graphics.update
  end

  #=============================================================================
  # Compile phone messages
  #=============================================================================
  def compile_phone
    return if !safeExists?("PBS/phone.txt")
    database = PhoneDatabase.new
    sections = []
    File.open("PBS/phone.txt","rb") { |f|
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
  # Compile types
  #=============================================================================
  def compile_types
    GameData::Type::DATA.clear
    type_names = []
    # Read from PBS file
    File.open("PBS/types.txt", "rb") { |f|
      FileLineData.file = "PBS/types.txt"   # For error reporting
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
              raise _INTL("The entry {1} is required in PBS/types.txt section {2}.", key, type_id)
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
        GameData::Type::DATA[type_number] = GameData::Type::DATA[type_symbol] = GameData::Type.new(type_hash)
        type_names[type_number] = type_hash[:name]
      }
    }
    # Ensure all weaknesses/resistances/immunities are valid types
    GameData::Type.each do |type|
      type.weaknesses.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, section {2}, Weaknesses).", other_type.to_s, type.id_number)
      end
      type.resistances.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, section {2}, Resistances).", other_type.to_s, type.id_number)
      end
      type.immunities.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type (PBS/types.txt, section {2}, Immunities).", other_type.to_s, type.id_number)
      end
    end
    # Save all data
    GameData::Type.save
    MessageTypes.setMessages(MessageTypes::Types, type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile abilities
  #=============================================================================
  def compile_abilities
    GameData::Ability::DATA.clear
    ability_names        = []
    ability_descriptions = []
    pbCompilerEachPreppedLine("PBS/abilities.txt") { |line, line_no|
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
      GameData::Ability::DATA[ability_number] = GameData::Ability::DATA[ability_symbol] = GameData::Ability.new(ability_hash)
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
  # Compile items
  #=============================================================================
=begin
  class ItemList
    include Enumerable

    def initialize; @list = []; end
    def length; @list.length; end
    def []=(x,v); @list[x] = v; end

    def [](x)
      if !@list[x]
        defrecord = SerialRecords::SerialRecord.new
        defrecord.push(0)
        defrecord.push("????????")
        defrecord.push(0)
        defrecord.push(0)
        defrecord.push("????????")
        @list[x] = defrecord
        return defrecord
      end
      return @list[x]
    end

    def each
      for i in 0...self.length
        yield self[i]
      end
    end
  end

  def readItemList(filename)
    ret = ItemList.new
    return ret if !pbRgssExists?(filename)
    pbRgssOpen(filename,"rb") { |file|
      numrec = file.fgetdw>>3
      curpos = 0
      numrec.times do
        file.pos = curpos
        offset = file.fgetdw
        length = file.fgetdw
        record = SerialRecords::SerialRecord.decode(file,offset,length)
        ret[record[0]] = record
        curpos += 8
      end
    }
    return ret
  end
=end

  def compile_items
    GameData::Item::DATA.clear
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    # Read each line of items.txt at a time and compile it into an item
    pbCompilerEachCommentedLine("PBS/items.txt") { |line, line_no|
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
      GameData::Item::DATA[item_number] = GameData::Item::DATA[item_symbol] = GameData::Item.new(item_hash)
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
  # Compile move data
  #=============================================================================
  def compile_moves
    GameData::Move::DATA.clear
    move_names        = []
    move_descriptions = []
    # Read each line of moves.txt at a time and compile it into an move
    pbCompilerEachPreppedLine("PBS/moves.txt") { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "vnssueeuuuyiss",
         nil, nil, nil, nil, nil, :Type, ["Physical", "Special", "Status"],
         nil, nil, nil, PBTargets, nil, nil, nil
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
        :target        => line[10],
        :priority      => line[11],
        :flags         => line[12],
        :description   => line[13]
      }
      # Add move's data to records
      GameData::Move::DATA[move_number] = GameData::Move::DATA[move_symbol] = GameData::Move.new(move_hash)
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
  # Compile battle animations
  #=============================================================================
  def compile_animations
    begin
      pbanims = load_data("Data/PkmnAnimations.rxdata")
    rescue
      pbanims = PBAnimations.new
    end
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
          move2anim[1][moveid] = i
        end
      elsif pbanims[i].name[/^Move\:\s*(.*)$/]
        if GameData::Move.exists?($~[1])
          moveid = GameData::Move.get($~[1]).id_number
          move2anim[0][moveid] = i
        end
      end
    end
    save_data(move2anim,"Data/move2anim.dat")
    save_data(pbanims,"Data/PkmnAnimations.rxdata")
  end

  #=============================================================================
  # Compile Pokémon
  #=============================================================================
  def compile_pokemon
    GameData::Species::DATA.clear
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    # Read from PBS file
    File.open("PBS/pokemon.txt", "rb") { |f|
      FileLineData.file = "PBS/pokemon.txt"   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema
      pbEachFileSection(f) { |contents, species_number|
        FileLineData.setSection(species_number, "header", nil)   # For error reporting
        # Raise an error if a species number is invalid or used twice
        if species_number == 0
          raise _INTL("A Pokémon species can't be numbered 0 (PBS/pokemon.txt).")
        elsif GameData::Species::DATA[species_number]
          raise _INTL("Species ID number '{1}' is used twice.\r\n{2}", species_number, FileLineData.linereport)
        end
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil? || contents[key] == ""
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in PBS/pokemon.txt section {2}.", key, species_number)
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
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)", key, species_number)
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
          :gender_rate           => contents["GenderRate"],
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
          :shape                 => contents["Shape"],
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
        GameData::Species::DATA[species_number] = GameData::Species::DATA[species_symbol] = GameData::Species.new(species_hash)
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
        param_type = PBEvolution.getFunction(evo[1], "parameterType")
        if param_type
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", species.id_number)
        elsif evo[2] && !evo[2].empty?
          evo[2] = csvInt!(evo[2])
        else
          evo[2] = nil
        end
      end
    end
    # Add prevolution "evolution" entry for all evolved species
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      next if all_evos[species.species]
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
  # Compile Pokémon forms
  #=============================================================================
  def compile_pokemon_forms
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
    File.open("PBS/pokemonforms.txt", "rb") { |f|
      FileLineData.file = "PBS/pokemonforms.txt"   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema(true)
      pbEachFileSection2(f) { |contents, section_name|
        FileLineData.setSection(section_name, "header", nil)   # For error reporting
        # Split section_name into a species number and form number
        split_section_name = section_name.split(/[-,\s]/)
        if split_section_name.length != 2
          raise _INTL("Section name {1} is invalid (PBS/pokemonforms.txt). Expected syntax like [XXX,Y] (XXX=internal name, Y=form number).", sectionName)
        end
        species_symbol = csvEnumField!(split_section_name[0], :Species, nil, nil)
        form           = csvPosInt!(split_section_name[1])
        # Raise an error if a species is undefined, the form number is invalid or
        # a species/form combo is used twice
        if !GameData::Species.exists?(species_symbol)
          raise _INTL("Species ID '{1}' is not defined in pokemon.txt.\r\n{2}", species_symbol, FileLineData.linereport)
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
          if contents[key].nil? || contents[key] == ""
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
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemonforms.txt)", key, section_name)
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
              param_type = PBEvolution.getFunction(value[i * 3 + 1], "parameterType")
              param = value[i * 3 + 2]
              if param_type
                param = csvEnumField!(param, param_type, "Evolutions", section_name)
              elsif param && !param.empty?
                param = csvInt!(param)
              else
                param = nil
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
          :evolutions            => evolutions,
          :height                => contents["Height"] || base_data.height,
          :weight                => contents["Weight"] || base_data.weight,
          :color                 => contents["Color"] || base_data.color,
          :shape                 => contents["Shape"] || base_data.shape,
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
        GameData::Species::DATA[form_number] = GameData::Species::DATA[form_symbol] = GameData::Species.new(species_hash)
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
      next if all_evos[species.species]
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
  def compile_move_compatibilities
    return if !safeExists?("PBS/tm.txt")
    species_hash = {}
    move = nil
    pbCompilerEachCommentedLine("PBS/tm.txt") { |line, line_no|
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
    pbSavePokemonData
    pbSavePokemonFormsData
    begin
      File.delete("PBS/tm.txt")
    rescue SystemCallError
    end
  end

  #=============================================================================
  # Compile Shadow movesets
  #=============================================================================
  def compile_shadow_movesets
    sections = {}
    if File.exists?("PBS/shadowmoves.txt")
      pbCompilerEachCommentedLine("PBS/shadowmoves.txt") { |line, _line_no|
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
  def compile_regional_dexes
    dex_lists = []
    section = nil
    pbCompilerEachPreppedLine("PBS/regionaldexes.txt") { |line, line_no|
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
  # Compile wild encounters
  #=============================================================================
  def compile_encounters
    lines   = []
    linenos = []
    FileLineData.file = "PBS/encounters.txt"
    File.open("PBS/encounters.txt","rb") { |f|
      lineno = 1
      f.each_line { |line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line = line[3,line.length-3]
        end
        line = prepline(line)
        if line.length!=0
          lines[lines.length] = line
          linenos[linenos.length] = lineno
        end
        lineno += 1
      }
    }
    encounters  = {}
    thisenc     = nil
    needdensity = false
    lastmapid   = -1
    i = 0
    while i<lines.length
      line = lines[i]
      FileLineData.setLine(line,linenos[i])
      mapid = line[/^\d+$/]
      if mapid
        lastmapid = mapid
        if encounters[mapid.to_i]
          raise _INTL("Encounters for map ID '{1}' are defined twice.\r\n{2}",mapid,FileLineData.linereport)
        end
        if thisenc && (thisenc[1][EncounterTypes::Land] ||
                       thisenc[1][EncounterTypes::LandMorning] ||
                       thisenc[1][EncounterTypes::LandDay] ||
                       thisenc[1][EncounterTypes::LandNight] ||
                       thisenc[1][EncounterTypes::BugContest]) &&
                       thisenc[1][EncounterTypes::Cave]
          raise _INTL("Can't define both Land and Cave encounters in the same area (map ID '{1}').",mapid)
        end
        thisenc = [EncounterTypes::EnctypeDensities.clone,[]]
        encounters[mapid.to_i] = thisenc
        needdensity = true
        i += 1
        next
      end
      enc = findIndex(EncounterTypes::Names) { |val| val==line }
      if enc>=0
        needdensity = false
        enclines = EncounterTypes::EnctypeChances[enc].length
        encarray = []
        j = i+1; k = 0
        while j<lines.length && k<enclines
          line = lines[j]
          FileLineData.setLine(lines[j],linenos[j])
          splitarr = strsplit(line,/\s*,\s*/)
          if !splitarr || splitarr.length<2
            raise _INTL("Expected a species entry line, got \"{1}\" instead. Check the number of species lines in the previous section (number {2}).\r\n{3}",
               line,lastmapid,FileLineData.linereport)
          end
          splitarr[2] = splitarr[1] if splitarr.length==2
          splitarr[1] = splitarr[1].to_i
          splitarr[2] = splitarr[2].to_i
          maxlevel = PBExperience.maxLevel
          if splitarr[1]<=0 || splitarr[1]>maxlevel
            raise _INTL("Level number is not valid: {1}\r\n{2}",splitarr[1],FileLineData.linereport)
          end
          if splitarr[2]<=0 || splitarr[2]>maxlevel
            raise _INTL("Level number is not valid: {1}\r\n{2}",splitarr[2],FileLineData.linereport)
          end
          if splitarr[1]>splitarr[2]
            raise _INTL("Minimum level is greater than maximum level: {1}\r\n{2}",line,FileLineData.linereport)
          end
          splitarr[0] = parseSpecies(splitarr[0])
          encarray.push(splitarr)
          thisenc[1][enc] = encarray
          j += 1; k += 1
        end
        if j==lines.length && k<enclines
          raise _INTL("Reached end of file unexpectedly. There were too few species entry lines in the last section (number {1}), expected {2} entries.\r\n{3}",
             lastmapid,enclines,FileLineData.linereport)
        end
        i = j
      elsif needdensity
        needdensity = false
        nums = strsplit(line,/,/)
        if nums && nums.length>=3
          for j in 0...EncounterTypes::EnctypeChances.length
            next if !EncounterTypes::EnctypeChances[j] ||
                    EncounterTypes::EnctypeChances[j].length==0
            next if EncounterTypes::EnctypeCompileDens[j]==0
            thisenc[0][j] = nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
          end
        else
          raise _INTL("Wrong syntax for densities in encounters.txt; got \"{1}\"\r\n{2}",line,FileLineData.linereport)
        end
        i += 1
      else
        raise _INTL("Undefined encounter type {1}, expected one of the following:\r\n{2}\r\n{3}",line,EncounterTypes::Names.inspect,FileLineData.linereport)
      end
    end
    save_data(encounters,"Data/encounters.dat")
  end

  #=============================================================================
  # Compile trainer types
  #=============================================================================
  def compile_trainer_types
    GameData::TrainerType::DATA.clear
    tr_type_names = []
    # Read each line of trainertypes.txt at a time and compile it into a trainer type
    pbCompilerEachCommentedLine("PBS/trainertypes.txt") { |line, line_no|
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
      GameData::TrainerType::DATA[type_number] = GameData::TrainerType::DATA[type_symbol] = GameData::TrainerType.new(type_hash)
      tr_type_names[type_number] = type_hash[:name]
    }
    # Save all data
    GameData::TrainerType.save
    MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile individual trainers
  #=============================================================================
  def compile_trainers
    trainer_info_types = TrainerData::SCHEMA
    mLevel = PBExperience.maxLevel
    trainerindex    = -1
    trainers        = []
    trainernames    = []
    trainerlosetext = []
    pokemonindex    = -2
    oldcompilerline   = 0
    oldcompilerlength = 0
    pbCompilerEachCommentedLine("PBS/trainers.txt") { |line,lineno|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # Section [trainertype,trainername] or [trainertype,trainername,partyid]
        if oldcompilerline>0
          raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
        end
        if pokemonindex==-1
          raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}",FileLineData.linereport)
        end
        section = pbGetCsvRecord($~[1],lineno,[0,"esU",:TrainerType])
        trainerindex += 1
        trainertype = section[0]
        trainername = section[1]
        partyid     = section[2] || 0
        trainers[trainerindex] = [trainertype,trainername,[],[],partyid,nil]
        trainernames[trainerindex] = trainername
        pokemonindex = -1
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if trainerindex<0
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}",FileLineData.linereport)
        end
        if oldcompilerline>0
          raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
        end
        settingname = $~[1]
        schema = trainer_info_types[settingname]
        next if !schema
        record = pbGetCsvRecord($~[2],lineno,schema)
        # Error checking in XXX=YYY lines
        case settingname
        when "Pokemon"
          if record[1]>mLevel
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}",record[1],mLevel,FileLineData.linereport)
          end
        when "Moves"
          record = [record] if record.is_a?(Symbol)
          record.compact!
        when "Ability"
          if record>5
            raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5).\r\n{2}",record,FileLineData.linereport)
          end
        when "IV"
          record = [record] if record.is_a?(Integer)
          record.compact!
          for i in record
            next if i<=Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", i, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          record = [record] if record.is_a?(Integer)
          record.compact!
          for i in record
            next if i<=Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", i, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          evtotal = 0
          for i in 0...6
            evtotal += (i<record.length) ? record[i] : record[0]
          end
          if evtotal>Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if record>255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}",record,FileLineData.linereport)
          end
        when "Name"
          if record.length>Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", record, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case settingname
        when "Items"   # Items in the trainer's Bag, not the held item
          record = [record] if record.is_a?(Integer)
          record.compact!
          trainers[trainerindex][2] = record
        when "LoseText"
          trainerlosetext[trainerindex] = record
          trainers[trainerindex][5] = record
        when "Pokemon"
          pokemonindex += 1
          trainers[trainerindex][3][pokemonindex] = []
          trainers[trainerindex][3][pokemonindex][TrainerData::SPECIES] = record[0]
          trainers[trainerindex][3][pokemonindex][TrainerData::LEVEL]   = record[1]
        else
          if pokemonindex<0
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}",FileLineData.linereport)
          end
          trainers[trainerindex][3][pokemonindex][schema[0]] = record
        end
      else
        # Old compiler - backwards compatibility is SUCH fun!
        if pokemonindex==-1 && oldcompilerline==0
          raise _INTL("Unexpected line format, started new trainer while previous trainer has no Pokémon.\r\n{1}",FileLineData.linereport)
        end
        if oldcompilerline==0   # Started an old trainer section
          oldcompilerlength = 3
          oldcompilerline   = 0
          trainerindex += 1
          trainers[trainerindex] = [0,"",[],[],0]
          pokemonindex = -1
        end
        oldcompilerline += 1
        case oldcompilerline
        when 1   # Trainer type
          record = pbGetCsvRecord(line,lineno,[0,"e",:TrainerType])
          trainers[trainerindex][0] = record
        when 2   # Trainer name, version number
          record = pbGetCsvRecord(line,lineno,[0,"sU"])
          record = [record] if record.is_a?(Integer)
          trainers[trainerindex][1] = record[0]
          trainernames[trainerindex] = record[0]
          trainers[trainerindex][4] = record[1] if record[1]
        when 3   # Number of Pokémon, items
          record = pbGetCsvRecord(line,lineno,[0,"vEEEEEEEE",nil,
                                  Item,Item,Item,Item,Item,Item,Item,Item])
          record = [record] if record.is_a?(Integer)
          record.compact!
          oldcompilerlength += record[0]
          record.shift
          trainers[trainerindex][2] = record if record
        else   # Pokémon lines
          pokemonindex += 1
          trainers[trainerindex][3][pokemonindex] = []
          record = pbGetCsvRecord(line,lineno,
             [0,"evEEEEEUEUBEUUSBU",Species,nil,:Item,:Move,:Move,:Move,:Move,
                                    nil,{"M"=>0,"m"=>0,"Male"=>0,"male"=>0,
                                    "0"=>0,"F"=>1,"f"=>1,"Female"=>1,"female"=>1,
                                    "1"=>1},nil,nil,PBNatures,nil,nil,nil,nil,nil])
          # Error checking (the +3 is for properties after the four moves)
          for i in 0...record.length
            next if record[i]==nil
            case i
            when TrainerData::LEVEL
              if record[i]>mLevel
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}",record[i],mLevel,FileLineData.linereport)
              end
            when TrainerData::ABILITY+3
              if record[i]>5
                raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5).\r\n{2}",record[i],FileLineData.linereport)
              end
            when TrainerData::IV+3
              if record[i]>31
                raise _INTL("Bad IV: {1} (must be 0-31).\r\n{2}",record[i],FileLineData.linereport)
              end
              record[i] = [record[i]]
            when TrainerData::EV+3
              if record[i]>Pokemon::EV_STAT_LIMIT
                raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", record[i], Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
              end
              record[i] = [record[i]]
            when TrainerData::HAPPINESS+3
              if record[i]>255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}",record[i],FileLineData.linereport)
              end
            when TrainerData::NAME+3
              if record[i].length>Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", record[i], Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            end
          end
          # Write data to trainer array
          for i in 0...record.length
            next if record[i]==nil
            if i>=TrainerData::MOVES && i<TrainerData::MOVES+4
              if !trainers[trainerindex][3][pokemonindex][TrainerData::MOVES]
                trainers[trainerindex][3][pokemonindex][TrainerData::MOVES] = []
              end
              trainers[trainerindex][3][pokemonindex][TrainerData::MOVES].push(record[i])
            else
              d = (i>=TrainerData::MOVES+4) ? i-3 : i
              trainers[trainerindex][3][pokemonindex][d] = record[i]
            end
          end
        end
        oldcompilerline = 0 if oldcompilerline>=oldcompilerlength
      end
    }
    save_data(trainers,"Data/trainers.dat")
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText,trainerlosetext)
  end

  #=============================================================================
  # Compile Battle Tower and other Cups trainers/Pokémon
  #=============================================================================
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

  def compile_trainer_lists
    btTrainersRequiredTypes = {
       "Trainers"   => [0, "s"],
       "Pokemon"    => [1, "s"],
       "Challenges" => [2, "*s"]
    }
    if !safeExists?("PBS/trainerlists.txt")
      File.open("PBS/trainerlists.txt","wb") { |f|
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
    File.open("PBS/trainerlists.txt","rb") { |f|
      FileLineData.file = "PBS/trainerlists.txt"
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
end
