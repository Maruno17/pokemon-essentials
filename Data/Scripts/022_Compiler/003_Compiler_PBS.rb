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
        item_symbol = parseItem(key).to_sym
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
      pbEachFileSection(f) { |contents, type_number|
        schema = GameData::Type::SCHEMA
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
    # Get schemas.
    requiredValues = SpeciesData.requiredValues
    optionalValues = SpeciesData.optionalValues
    # Prepare arrays for compiled data.
    speciesData    = []
    movesets       = []
    eggMoves       = []
    regionalDexes  = []
    spriteMetrics  = []
    evolutions     = []
    speciesNames   = []
    formNames      = []
    pokedexKinds   = []
    pokedexEntries = []
    # Prepare variables used to record scripted constants.
    constants = ""
    maxValue = 0   # Highest species ID
    # Read from PBS file.
    File.open("PBS/pokemon.txt","rb") { |f|
      FileLineData.file = "PBS/pokemon.txt"   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSection(f) { |contents,speciesID|
        # Raise an error if the species ID is 0.
        if speciesID==0
          raise _INTL("A Pokémon species can't be numbered 0 (PBS/pokemon.txt).")
        end
        # Raise an error if the species ID has already been defined.
        if speciesData[speciesID]
          raise _INTL("Species ID number '{1}' is used twice.\r\n{2}",speciesID,FileLineData.linereport)
        end
        # Create array to store compiled data in.
        speciesData[speciesID] = []
        # Copy Type1 into Type2 if Type2 is undefined. (All species must have two
        # defined types; if both are the same, it is treated as single typed.)
        if !contents["Type2"] || contents["Type2"]==""
          if !contents["Type1"] || contents["Type1"]==""
            raise _INTL("No Pokémon type is defined in section {1} (PBS/pokemon.txt)",speciesID.to_s)
          end
          contents["Type2"] = contents["Type1"].clone
        end
        # Go through hashes of compilable data and compile this section.
        [requiredValues,optionalValues].each do |hash|
          for key in hash.keys
            FileLineData.setSection(speciesID,key,contents[key])   # For error reporting
            maxValue = [maxValue,speciesID].max   # Set highest species ID
            next if hash[key][0]<0   # Property is not to be compiled; skip it
            # Skip empty optional properties, or raise an error if a required
            # property is empty.
            if !contents[key] || contents[key]==""
              raise _INTL("Required entry {1} is missing or empty in section {2} (PBS/pokemon.txt)",
                 key,speciesID.to_s) if hash==requiredValues
              next
            end
            # Compile value for key.
            schema = hash[key]
            value = pbGetCsvRecord(contents[key],key,schema)
            # Modify value as required.
            case key
            when "Height", "Weight"
              # Convert height/weight to 1 decimal place and multiply by 10.
              value = (value*10).round
              if value<=0
                raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)",key,speciesID)
              end
            end
            # Add value to appropriate array for saving.
            case key
            when "Moves"
              speciesMoves = []
              for i in 0...value.length/2
                speciesMoves.push([value[i*2],value[i*2+1],i])
              end
              speciesMoves.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
              for i in speciesMoves; i.pop; end
              movesets[speciesID] = speciesMoves
            when "EggMoves"
              if value.is_a?(Array); eggMoves[speciesID] = value
              else;                  eggMoves[speciesID] = [value]
              end
            when "RegionalNumbers"
              if value.is_a?(Array)
                value.each_with_index do |num,dexID|
                  regionalDexes[dexID] = [] if !regionalDexes[dexID]
                  regionalDexes[dexID][speciesID] = num
                end
              else
                regionalDexes[0] = [] if !regionalDexes[0]
                regionalDexes[0][speciesID] = value
              end
            when "BattlerPlayerX", "BattlerPlayerY",
                 "BattlerEnemyX", "BattlerEnemyY",
                 "BattlerAltitude", "BattlerShadowX", "BattlerShadowSize"
              spriteMetrics[schema[0]] = [] if !spriteMetrics[schema[0]]
              spriteMetrics[schema[0]][speciesID] = value
            when "Evolutions"
              speciesEvolutions  = []
              for i in 0...value.length/3
                speciesEvolutions.push([value[i*3],value[i*3+1],value[i*3+2],false])
              end
              evolutions[speciesID] = speciesEvolutions
            when "Name"
              speciesNames[speciesID] = value
            when "FormName"
              formNames[speciesID] = value
            when "Kind"
              pokedexKinds[speciesID] = value
            when "Pokedex"
              pokedexEntries[speciesID] = value
            when "InternalName"
              constants += "#{value}=#{speciesID}\r\n"
            else   # All other data
              speciesData[speciesID][schema[0]] = value
            end
          end
        end
      }
    }
    # All data is compiled now, just need to save it.
    raise _INTL("No Pokémon species are defined (PBS/pokemon.txt)") if speciesData.length==0
    # Write all constants and some helpful code for PBSpecies.
    count = speciesData.compact.length
    code = "module PBSpecies\r\n#{constants}"
    code += "def PBSpecies.getName(id)\r\n"
    code += "id=getID(PBSpecies,id)\r\n"
    code += "return pbGetMessage(MessageTypes::Species,id); end\r\n"
    code += "def PBSpecies.getCount; return #{count}; end\r\n"
    code += "def PBSpecies.maxValue; return #{maxValue}; end\r\n"
    code += "end\r\n"
    eval(code, TOPLEVEL_BINDING)
    pbAddScript(code,"PBSpecies")
    # Save main species data.
    save_data(speciesData,"Data/species.dat")
    # Save movesets data.
    save_data(movesets,"Data/species_movesets.dat")
    # Save egg moves data.
    save_data(eggMoves,"Data/species_eggmoves.dat")
    # Save regional dexes data.
    save_data(regionalDexes,"Data/regional_dexes.dat")
    # Save metrics data.
    for i in 0...7
      defaultValue = (i==SpeciesData::METRIC_SHADOW_SIZE) ? 2 : 0   # Shadow size 2, other metrics 0
      for j in 0..maxValue
        spriteMetrics[i] = [] if !spriteMetrics[i]
        spriteMetrics[i][j] ||= defaultValue
      end
    end
    save_data(spriteMetrics,"Data/species_metrics.dat")
    # Evaluate evolution data (has to be done after all species are read).
    for e in 0...evolutions.length
      next if !evolutions[e]
      evolutions[e].each_with_index do |evo,i|
        FileLineData.setSection(i,"Evolutions","")
        evo[0] = csvEnumField!(evo[0],PBSpecies,"Evolutions",i)   # Species
        param_type = PBEvolution.getFunction(evo[1], "parameterType")
        if param_type
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", i)
        else
          evo[2] = csvInt!(evo[2]) if evo[2] && evo[2] != ""
        end
      end
    end
    # Add prevolution data to all species as the first "evolution method".
    for sp in 1..maxValue
      preSpecies = -1
      evoData = nil
      # Check for another species that evolves into sp.
      for f in 0...evolutions.length
        next if !evolutions[f] || f==sp
        evolutions[f].each do |evo|
          next if evo[0]!=sp || evo[3]   # Evolved species isn't sp or is a prevolution
          preSpecies = f   # f evolves into sp
          evoData = evo
          break
        end
        break if evoData
      end
      next if !evoData   # evoData[1]=method, evoData[2]=level - both are unused
      # Found a species that evolves into e, record it as a prevolution.
      evolutions[sp] = [] if !evolutions[sp]
      evolutions[sp] = [[preSpecies,evoData[1],evoData[2],true]].concat(evolutions[sp])
    end
    # Save evolutions data.
    save_data(evolutions,"Data/species_evolutions.dat")
    # Save all messages.
    speciesNames.map! { |name| name || "????????" }
    MessageTypes.setMessages(MessageTypes::Species,speciesNames)
    MessageTypes.setMessages(MessageTypes::FormNames,formNames)
    MessageTypes.setMessages(MessageTypes::Kinds,pokedexKinds)
    MessageTypes.setMessages(MessageTypes::Entries,pokedexEntries)
  end

  #=============================================================================
  # Compile Pokémon forms
  #=============================================================================
  def compile_pokemon_forms
    # Get schemas.
    requiredValues = SpeciesData.requiredValues(true)
    optionalValues = SpeciesData.optionalValues(true)
    # Prepare arrays for compiled data.
    speciesData    = pbLoadSpeciesData
    movesets       = []
    eggMoves       = []
    spriteMetrics  = []
    evolutions     = []
    formNames      = []
    pokedexKinds   = []
    pokedexEntries = []
    formToSpecies  = []   # Saved
    speciesToForm  = []   # Only used in this method
    for i in 1..PBSpecies.maxValue
      formToSpecies[i] = [i]
      speciesToForm[i] = i
    end
    # Prepare variables used to record scripted constants.
    constants = ""
    maxValue = PBSpecies.maxValue   # Highest species ID
    # Read from PBS file.
    File.open("PBS/pokemonforms.txt","rb") { |f|
      FileLineData.file = "PBS/pokemonforms.txt"   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSection2(f) { |contents,sectionName|
        # Split sectionName into a species number and form number.
        splitSectionName = sectionName.split(/[-,\s]/)
        if splitSectionName.length!=2
          raise _INTL("Section name {1} is invalid (PBS/pokemonforms.txt). Expected syntax like [XXX,Y] (XXX=internal name, Y=form number).",sectionName)
        end
        baseSpeciesID = parseSpecies(splitSectionName[0])
        form          = csvInt!(splitSectionName[1])
        # Ensure this is a valid form and not a duplicate.
        if form==0
          raise _INTL("Form {1} is invalid (PBS/pokemonforms.txt). Form 0 data should be defined in \"PBS/pokemon.txt\".",sectionName)
        end
        if formToSpecies[baseSpeciesID] && formToSpecies[baseSpeciesID][form]
          raise _INTL("Form {1} is defined at least twice (PBS/pokemonforms.txt). It should only be defined once.",sectionName)
        end
        # Record new species number in formToSpecies.
        speciesID = baseSpeciesID
        if form>0
          maxValue += 1
          speciesID = maxValue
          formToSpecies[baseSpeciesID] = [] if !formToSpecies[baseSpeciesID]
          formToSpecies[baseSpeciesID][form] = speciesID
          speciesToForm[speciesID] = baseSpeciesID
        end
        # Generate internal name for this form.
        cName = getConstantName(PBSpecies,baseSpeciesID).to_s+"_"+form.to_s
        constants += "#{cName}=#{speciesID}\r\n"
        # Create array to store compiled data in.
        speciesData[speciesID] = []
        # Clone data from base form as a starting point.
        speciesData[baseSpeciesID].each_with_index do |val,i|
          speciesData[speciesID][i] = (val.is_a?(Array)) ? val.clone : val
        end
        # Copy Type1 into Type2 if if Type1 is defined but Type2 isn't. (Shouldn't
        # inherit either of the base form's types if Type1 is defined for a form.)
        if contents["Type1"] && contents["Type1"]!=""
          if !contents["Type2"] || contents["Type2"]==""
            contents["Type2"] = contents["Type1"].clone
          end
        end
        # If any held item is defined for this form, clear default data for all
        # three held items.
        if (contents["WildItemCommon"] && contents["WildItemCommon"]!="") ||
           (contents["WildItemUncommon"] && contents["WildItemUncommon"]!="") ||
           (contents["WildItemRare"] && contents["WildItemRare"]!="")
          speciesData[speciesID][SpeciesData::WILD_ITEM_COMMON]   = nil
          speciesData[speciesID][SpeciesData::WILD_ITEM_UNCOMMON] = nil
          speciesData[speciesID][SpeciesData::WILD_ITEM_RARE]     = nil
        end
        # Go through hashes of compilable data and compile this section.
        [requiredValues,optionalValues].each do |hash|
          for key in hash.keys
            FileLineData.setSection(speciesID,key,contents[key])   # For error reporting
            next if hash[key][0]<0   # Property is not to be compiled; skip it
            # Skip empty properties (none are required).
            next if !contents[key] || contents[key]==""
            # Compile value for key.
            schema = hash[key]
            value = pbGetCsvRecord(contents[key],key,schema)
            # Modify value as required.
            case key
            when "Height", "Weight"
              # Convert height/weight to 1 decimal place and multiply by 10.
              value = (value*10).round
              if value<=0
                raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemonforms.txt)",key,speciesID)
              end
            end
            # Add value to appropriate array for saving.
            case key
            when "Moves"
              speciesMoves = []
              for i in 0...value.length/2
                speciesMoves.push([value[i*2],value[i*2+1],i])
              end
              speciesMoves.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
              for i in speciesMoves; i.pop; end
              movesets[speciesID] = speciesMoves
            when "EggMoves"
              if value.is_a?(Array); eggMoves[speciesID] = value
              else;                  eggMoves[speciesID] = [value]
              end
            when "BattlerPlayerX", "BattlerPlayerY",
                 "BattlerEnemyX", "BattlerEnemyY",
                 "BattlerAltitude", "BattlerShadowX", "BattlerShadowSize"
              spriteMetrics[schema[0]] = [] if !spriteMetrics[schema[0]]
              spriteMetrics[schema[0]][speciesID] = value
            when "Evolutions"
              speciesEvolutions  = []
              for i in 0...value.length/3
                speciesEvolutions.push([value[i*3],value[i*3+1],value[i*3+2],false])
              end
              evolutions[speciesID] = speciesEvolutions
            when "FormName"
              formNames[speciesID] = value
            when "Kind"
              pokedexKinds[speciesID] = value
            when "Pokedex"
              pokedexEntries[speciesID] = value
            else   # All other data
              speciesData[speciesID][schema[0]] = value
            end
          end
        end
      }
    }
    # All data is compiled now, just need to save it.
    # Write all constants and some helpful code for PBSpecies.
    code = "module PBSpecies\r\n#{constants}"
    code += "def PBSpecies.maxValueF; return #{maxValue}; end\r\n"
    code += "end\r\n"
    eval(code, TOPLEVEL_BINDING)
    pbAddScript(code,"PBSpecies")
    # Save main species data.
    save_data(speciesData,"Data/species.dat")
    # Save conversions of form to species data.
    save_data(formToSpecies,"Data/form2species.dat")
    # Inherit base form moveset.
    newMovesets = pbLoadMovesetsData
    append_to_base_form_data(PBSpecies.maxValue+1,maxValue,newMovesets,movesets,speciesToForm,true)
    save_data(newMovesets,"Data/species_movesets.dat")
    $PokemonTemp.speciesMovesets = nil if $PokemonTemp
    # Inherit base form egg moves.
    newEggMoves = pbLoadEggMovesData
    append_to_base_form_data(PBSpecies.maxValue+1,maxValue,newEggMoves,eggMoves,speciesToForm,false)
    save_data(newEggMoves,"Data/species_eggmoves.dat")
    $PokemonTemp.speciesEggMoves = nil if $PokemonTemp
    # Inherit base form metrics data.
    newSpriteMetrics = pbLoadSpeciesMetrics
    for i in 0...7
      defaultValue = (i==SpeciesData::METRIC_SHADOW_SIZE) ? 2 : 0   # Shadow size 2, other metrics 0
      append_to_base_form_data(PBSpecies.maxValue+1,maxValue,newSpriteMetrics[i],
         spriteMetrics[i] || [],speciesToForm,false,defaultValue)
    end
    save_data(newSpriteMetrics,"Data/species_metrics.dat")
    # Evaluate evolution data (has to be done after all species are read).
    for e in 0...evolutions.length
      next if !evolutions[e]
      evolutions[e].each_with_index do |evo,i|
        FileLineData.setSection(i,"Evolutions","")
        evo[0] = csvEnumField!(evo[0],PBSpecies,"Evolutions",i)   # Species
        param_type = PBEvolution.getFunction(evo[1], "parameterType")
        if param_type
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", i)
        else
          evo[2] = csvPosInt!(evo[2]) if evo[2] && evo[2] != ""
        end
      end
    end
    # Inherit base form evolution methods.
    newEvolutions = pbLoadEvolutionsData
    append_to_base_form_data(PBSpecies.maxValue+1,maxValue,newEvolutions,evolutions,speciesToForm,true)
    # Add prevolution data to all species as the first "evolution method".
    for i in (PBSpecies.maxValue+1)..maxValue
      baseSpecies = speciesToForm[i]
      preSpecies = -1
      evoData = nil
      # Check for another species that evolves into baseSpecies.
      for f in 0...newEvolutions.length
        next if !newEvolutions[f] || speciesToForm[f]==baseSpecies
        newEvolutions[f].each do |evo|
          next if evo[0]!=baseSpecies || evo[3]   # Evolved species isn't baseSpecies or is a prevolution
          preSpecies = speciesToForm[f]   # f evolves into baseSpecies
          evoData = evo
          break
        end
        break if evoData
      end
      next if !evoData   # evoData[1]=method, evoData[2]=level - both are unused
      # Found a species that evolves into e, record it as a prevolution.
      if newEvolutions[i]
        newEvolutions[i] = [[preSpecies,evoData[1],evoData[2],true]].concat(newEvolutions[i])
      else
        newEvolutions[i] = [[preSpecies,evoData[1],evoData[2],true]]
      end
    end
    # Save evolutions data.
    save_data(newEvolutions,"Data/species_evolutions.dat")
    $PokemonTemp.evolutionsData = nil if $PokemonTemp
    # Save all messages.
    MessageTypes.addMessages(MessageTypes::FormNames,formNames)
    MessageTypes.addMessages(MessageTypes::Kinds,pokedexKinds)
    MessageTypes.addMessages(MessageTypes::Entries,pokedexEntries)
  end

  def append_to_base_form_data(idxStart,idxEnd,baseData,extraData,speciesToForm,clone=false,defaultValue=nil)
    for i in idxStart..idxEnd
      if extraData[i]
        baseData[i] = extraData[i]
      else
        species = speciesToForm[i]
        if baseData[species]
          if clone
            baseData[i] = []
            baseData[species].each { |datum| baseData[i].push(datum.clone) }
          elsif baseData[species].is_a?(Array)
            baseData[i] = baseData[species].clone
          else
            baseData[i] = baseData[species]
          end
        else
          baseData[i] = defaultValue
        end
      end
    end
  end

  #=============================================================================
  # Compile TM/TM/Move Tutor compatibilities
  #=============================================================================
  def compile_move_compatibilities
    lineno = 1
    havesection = false
    sectionname = nil
    sections    = {}
    if safeExists?("PBS/tm.txt")
      f = File.open("PBS/tm.txt","rb")
      FileLineData.file = "PBS/tm.txt"
      f.each_line { |line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line = line[3,line.length-3]
        end
        FileLineData.setLine(line,lineno)
        if !line[/^\#/] && !line[/^\s*$/]
          if line[/^\s*\[\s*(.*)\s*\]\s*$/]
            sectionname = parseMove($~[1])
            if sections[sectionname]
              raise _INTL("TM section [{1}] is defined twice.\r\n{2}",sectionname,FileLineData.linereport)
            end
            sections[sectionname] = []
            havesection = true
          else
            if sectionname==nil
              raise _INTL("Expected a section at the beginning of the file. This error may also occur if the file was not saved in UTF-8.\r\n{1}",
                 FileLineData.linereport)
            end
            specieslist = line.sub(/\s+$/,"").split(",")
            for species in specieslist
              next if !species || species==""
              sec = sections[sectionname]
              sec[sec.length] = parseSpecies(species)
            end
          end
        end
        lineno += 1
        Graphics.update if lineno%50==0
        pbSetWindowText(_INTL("Processing {1} line {2}",FileLineData.file,lineno)) if lineno%50==0
      }
      f.close
    end
    save_data(sections,"Data/tm.dat")
  end

  #=============================================================================
  # Compile Shadow movesets
  #=============================================================================
  def compile_shadow_movesets
    sections = []
    if File.exists?("PBS/shadowmoves.txt")
      pbCompilerEachCommentedLine("PBS/shadowmoves.txt") { |line,_lineno|
        if line[ /^\s*(\w+)\s*=\s*(.*)$/ ]
          key   = $1
          value = $2
          value = value.split(",")
          species = parseSpecies(key)
          moves = []
          for i in 0...[Pokemon::MAX_MOVES,value.length].min
            move = parseMove(value[i], true)
            moves.push(move) if move
          end
          moves.compact!
          sections[species] = moves if moves.length>0
        end
      }
    end
    save_data(sections,"Data/shadow_movesets.dat")
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
             [0,"evEEEEEUEUBEUUSBU",PBSpecies,nil,:Item,:Move,:Move,:Move,:Move,
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
