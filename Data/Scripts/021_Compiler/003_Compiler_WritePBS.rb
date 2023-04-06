module Compiler
  module_function

  def get_all_PBS_file_paths(game_data)
    ret = []
    game_data.each { |element| ret.push(element.pbs_file_suffix) if !ret.include?(element.pbs_file_suffix) }
    ret.each_with_index do |element, i|
      ret[i] = [sprintf("PBS/%s.txt", game_data::PBS_BASE_FILENAME), element]
      if !nil_or_empty?(element)
        ret[i][0] = sprintf("PBS/%s_%s.txt", game_data::PBS_BASE_FILENAME, element)
      end
    end
    return ret
  end

  def add_PBS_header_to_file(file)
    file.write(0xEF.chr)
    file.write(0xBB.chr)
    file.write(0xBF.chr)
    file.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
  end

  def write_PBS_file_generic(game_data)
    paths = get_all_PBS_file_paths(game_data)
    schema = game_data.schema
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        game_data.each do |element|
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
            f.write("]\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save Town Map data to PBS file
  #=============================================================================
  def write_town_map
    write_PBS_file_generic(GameData::TownMap)
  end

  #=============================================================================
  # Save map connections to PBS file
  #=============================================================================
  def normalize_connection(conn)
    ret = conn.clone
    if conn[1].negative? != conn[4].negative?   # Exactly one is negative
      ret[4] = -conn[1]
      ret[1] = -conn[4]
    end
    if conn[2].negative? != conn[5].negative?   # Exactly one is negative
      ret[5] = -conn[2]
      ret[2] = -conn[5]
    end
    return ret
  end

  def get_connection_text(map1, x1, y1, map2, x2, y2)
    dims1 = MapFactoryHelper.getMapDims(map1)
    dims2 = MapFactoryHelper.getMapDims(map2)
    if x1 == 0 && x2 == dims2[0]
      return sprintf("%d,West,%d,%d,East,%d", map1, y1, map2, y2)
    elsif y1 == 0 && y2 == dims2[1]
      return sprintf("%d,North,%d,%d,South,%d", map1, x1, map2, x2)
    elsif x1 == dims1[0] && x2 == 0
      return sprintf("%d,East,%d,%d,West,%d", map1, y1, map2, y2)
    elsif y1 == dims1[1] && y2 == 0
      return sprintf("%d,South,%d,%d,North,%d", map1, x1, map2, x2)
    end
    return sprintf("%d,%d,%d,%d,%d,%d", map1, x1, y1, map2, x2, y2)
  end

  def write_connections(path = "PBS/map_connections.txt")
    conndata = load_data("Data/map_connections.dat")
    return if !conndata
    write_pbs_file_message_start(path)
    mapinfos = pbLoadMapInfos
    File.open(path, "wb") do |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      conndata.each do |conn|
        if mapinfos
          # Skip if map no longer exists
          next if !mapinfos[conn[0]] || !mapinfos[conn[3]]
          f.write(sprintf("# %s (%d) - %s (%d)\r\n",
                          (mapinfos[conn[0]]) ? mapinfos[conn[0]].name : "???", conn[0],
                          (mapinfos[conn[3]]) ? mapinfos[conn[3]].name : "???", conn[3]))
        end
        if conn[1].is_a?(String) || conn[4].is_a?(String)
          f.write(sprintf("%d,%s,%d,%d,%s,%d", conn[0], conn[1], conn[2],
                          conn[3], conn[4], conn[5]))
        else
          ret = normalize_connection(conn)
          f.write(get_connection_text(ret[0], ret[1], ret[2], ret[3], ret[4], ret[5]))
        end
        f.write("\r\n")
      end
    end
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save type data to PBS file
  #=============================================================================
  def write_types
    write_PBS_file_generic(GameData::Type)
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_abilities
    write_PBS_file_generic(GameData::Ability)
  end

  #=============================================================================
  # Save move data to PBS file
  #=============================================================================
  def write_moves
    write_PBS_file_generic(GameData::Move)
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    write_PBS_file_generic(GameData::Item)
  end

  #=============================================================================
  # Save berry plant data to PBS file
  #=============================================================================
  def write_berry_plants
    write_PBS_file_generic(GameData::BerryPlant)
  end

  #=============================================================================
  # Save Pokémon data to PBS file
  # NOTE: Doesn't use write_PBS_file_generic because it needs to ignore defined
  #       species with a form that isn't 0.
  #=============================================================================
  def write_pokemon
    paths = []
    GameData::Species.each_species { |element| paths.push(element.pbs_file_suffix) if !paths.include?(element.pbs_file_suffix) }
    paths.each_with_index do |element, i|
      paths[i] = [sprintf("PBS/%s.txt", GameData::Species::PBS_BASE_FILENAME[0]), element]
      if !nil_or_empty?(element)
        paths[i][0] = sprintf("PBS/%s_%s.txt", GameData::Species::PBS_BASE_FILENAME[0], element)
      end
    end
    schema = GameData::Species.schema
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        GameData::Species.each_species do |element|
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
            f.write("]\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save Pokémon forms data to PBS file
  # NOTE: Doesn't use write_PBS_file_generic because it needs to ignore defined
  #       species with a form of 0, and needs its own schema.
  #=============================================================================
  def write_pokemon_forms
    paths = []
    GameData::Species.each do |element|
      next if element.form == 0
      paths.push(element.pbs_file_suffix) if !paths.include?(element.pbs_file_suffix)
    end
    paths.each_with_index do |element, i|
      paths[i] = [sprintf("PBS/%s.txt", GameData::Species::PBS_BASE_FILENAME[1]), element]
      if !nil_or_empty?(element)
        paths[i][0] = sprintf("PBS/%s_%s.txt", GameData::Species::PBS_BASE_FILENAME[1], element)
      end
    end
    schema = GameData::Species.schema(true)
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        GameData::Species.each do |element|
          next if element.form == 0
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName", true), f, schema["SectionName"])
            f.write("]\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key, true)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Write species metrics
  # NOTE: Doesn't use write_PBS_file_generic because it needs to ignore defined
  #       metrics for forms of species where the metrics are the same as for the
  #       base species.
  #=============================================================================
  def write_pokemon_metrics
    paths = []
    GameData::SpeciesMetrics.each do |element|
      next if element.form == 0
      paths.push(element.pbs_file_suffix) if !paths.include?(element.pbs_file_suffix)
    end
    paths.each_with_index do |element, i|
      paths[i] = [sprintf("PBS/%s.txt", GameData::SpeciesMetrics::PBS_BASE_FILENAME), element]
      if !nil_or_empty?(element)
        paths[i][0] = sprintf("PBS/%s_%s.txt", GameData::SpeciesMetrics::PBS_BASE_FILENAME, element)
      end
    end
    schema = GameData::SpeciesMetrics.schema
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        GameData::SpeciesMetrics.each do |element|
          next if element.pbs_file_suffix != path[1]
          if element.form > 0
            base_element = GameData::SpeciesMetrics.get(element.species)
            next if element.back_sprite == base_element.back_sprite &&
                    element.front_sprite == base_element.front_sprite &&
                    element.front_sprite_altitude == base_element.front_sprite_altitude &&
                    element.shadow_x == base_element.shadow_x &&
                    element.shadow_size == base_element.shadow_size
          end
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
            f.write("]\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save Shadow Pokémon data to PBS file
  #=============================================================================
  def write_shadow_pokemon
    return if GameData::ShadowPokemon::DATA.empty?
    write_PBS_file_generic(GameData::ShadowPokemon)
  end

  #=============================================================================
  # Save Regional Dexes to PBS file
  #=============================================================================
  def write_regional_dexes(path = "PBS/regional_dexes.txt")
    write_pbs_file_message_start(path)
    dex_lists = pbLoadRegionalDexes
    File.open(path, "wb") do |f|
      add_PBS_header_to_file(f)
      # Write each Dex list in turn
      dex_lists.each_with_index do |list, index|
        f.write("\#-------------------------------\r\n")
        f.write("[#{index}]")
        comma = false
        current_family = nil
        list.each do |species|
          next if !species
          if current_family&.include?(species)
            f.write(",") if comma
          else
            current_family = GameData::Species.get(species).get_family_species
            comma = false
            f.write("\r\n")
          end
          f.write(species)
          comma = true
        end
        f.write("\r\n")
      end
    end
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_ribbons
    write_PBS_file_generic(GameData::Ribbon)
  end

  #=============================================================================
  # Save wild encounter data to PBS file
  #=============================================================================
  def write_encounters
    paths = get_all_PBS_file_paths(GameData::Encounter)
    map_infos = pbLoadMapInfos
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        GameData::Encounter.each do |element|
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          map_name = (map_infos[element.map]) ? " # #{map_infos[element.map].name}" : ""
          if element.version > 0
            f.write(sprintf("[%03d,%d]%s\r\n", element.map, element.version, map_name))
          else
            f.write(sprintf("[%03d]%s\r\n", element.map, map_name))
          end
          element.types.each do |type, slots|
            next if !slots || slots.length == 0
            if element.step_chances[type] && element.step_chances[type] > 0
              f.write(sprintf("%s,%d\r\n", type.to_s, element.step_chances[type]))
            else
              f.write(sprintf("%s\r\n", type.to_s))
            end
            slots.each do |slot|
              if slot[2] == slot[3]
                f.write(sprintf("    %d,%s,%d\r\n", slot[0], slot[1], slot[2]))
              else
                f.write(sprintf("    %d,%s,%d,%d\r\n", slot[0], slot[1], slot[2], slot[3]))
              end
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types
    write_PBS_file_generic(GameData::TrainerType)
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_trainers
    paths = get_all_PBS_file_paths(GameData::Trainer)
    schema = GameData::Trainer.schema
    sub_schema = GameData::Trainer.sub_schema
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        GameData::Trainer.each do |element|
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
            f.write("]\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          # Write each trainer property
          schema.each_key do |key|
            next if ["SectionName", "Pokemon"].include?(key)
            val = element.get_property_for_PBS(key)
            next if val.nil?
            f.write(sprintf("%s = ", key))
            pbWriteCsvRecord(val, f, schema[key])
            f.write("\r\n")
          end
          # Write each Pokémon in turn
          element.pokemon.each_with_index do |pkmn, i|
            # Write species/level
            val = element.get_pokemon_property_for_PBS("Pokemon", i)
            f.write("Pokemon = ")
            pbWriteCsvRecord(val, f, schema["Pokemon"])
            f.write("\r\n")
            # Write other Pokémon properties
            sub_schema.each_key do |key|
              val = element.get_pokemon_property_for_PBS(key, i)
              next if val.nil?
              f.write(sprintf("    %s = ", key))
              pbWriteCsvRecord(val, f, sub_schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save trainer list data to PBS file
  #=============================================================================
  def write_trainer_lists(path = "PBS/battle_facility_lists.txt")
    trainerlists = load_data("Data/trainer_lists.dat") rescue nil
    return if !trainerlists
    write_pbs_file_message_start(path)
    File.open(path, "wb") do |f|
      add_PBS_header_to_file(f)
      trainerlists.each do |tr|
        echo "."
        f.write("\#-------------------------------\r\n")
        f.write(((tr[5]) ? "[DefaultTrainerList]" : "[TrainerList]") + "\r\n")
        f.write("Trainers = " + tr[3] + "\r\n")
        f.write("Pokemon = " + tr[4] + "\r\n")
        f.write("Challenges = " + tr[2].join(",") + "\r\n") if !tr[5]
        write_battle_tower_trainers(tr[0], "PBS/" + tr[3])
        write_battle_tower_pokemon(tr[1], "PBS/" + tr[4])
      end
    end
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save Battle Tower trainer data to PBS file
  #=============================================================================
  def write_battle_tower_trainers(bttrainers, filename)
    return if !bttrainers || !filename
    btTrainersRequiredTypes = {
      "Type"          => [0, "e", nil],   # Specifies a trainer
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"]
    }
    File.open(filename, "wb") do |f|
      add_PBS_header_to_file(f)
      bttrainers.length.times do |i|
        next if !bttrainers[i]
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%03d]\r\n", i))
        btTrainersRequiredTypes.each_key do |key|
          schema = btTrainersRequiredTypes[key]
          record = bttrainers[i][schema[0]]
          next if record.nil?
          f.write(sprintf("%s = ", key))
          case key
          when "Type"
            f.write(record.to_s)
          when "PokemonNos"
            f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
          else
            pbWriteCsvRecord(record, f, schema)
          end
          f.write("\r\n")
        end
      end
    end
    Graphics.update
  end

  #=============================================================================
  # Save Battle Tower Pokémon data to PBS file
  #=============================================================================
  def write_battle_tower_pokemon(btpokemon, filename)
    return if !btpokemon || !filename
    species = {}
    moves   = {}
    items   = {}
    natures = {}
    evs = {
      :HP              => "HP",
      :ATTACK          => "ATK",
      :DEFENSE         => "DEF",
      :SPECIAL_ATTACK  => "SA",
      :SPECIAL_DEFENSE => "SD",
      :SPEED           => "SPD"
    }
    File.open(filename, "wb") do |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      btpokemon.length.times do |i|
        Graphics.update if i % 500 == 0
        pkmn = btpokemon[i]
        c1 = (species[pkmn.species]) ? species[pkmn.species] : (species[pkmn.species] = GameData::Species.get(pkmn.species).species.to_s)
        c2 = nil
        if pkmn.item && GameData::Item.exists?(pkmn.item)
          c2 = (items[pkmn.item]) ? items[pkmn.item] : (items[pkmn.item] = GameData::Item.get(pkmn.item).id.to_s)
        end
        c3 = (natures[pkmn.nature]) ? natures[pkmn.nature] : (natures[pkmn.nature] = GameData::Nature.get(pkmn.nature).id.to_s)
        evlist = ""
        pkmn.ev.each_with_index do |stat, j|
          evlist += "," if j > 0
          evlist += evs[stat]
        end
        c4 = c5 = c6 = c7 = ""
        [pkmn.move1, pkmn.move2, pkmn.move3, pkmn.move4].each_with_index do |move, j|
          next if !move
          text = (moves[move]) ? moves[move] : (moves[move] = GameData::Move.get(move).id.to_s)
          case j
          when 0 then c4 = text
          when 1 then c5 = text
          when 2 then c6 = text
          when 3 then c7 = text
          end
        end
        f.write("#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}\r\n")
      end
    end
    Graphics.update
  end

  #=============================================================================
  # Save metadata data to PBS file
  # NOTE: Doesn't use write_PBS_file_generic because it contains data for two
  #       different GameData classes.
  #=============================================================================
  def write_metadata
    paths = []
    GameData::Metadata.each do |element|
      paths.push(element.pbs_file_suffix) if !paths.include?(element.pbs_file_suffix)
    end
    GameData::PlayerMetadata.each do |element|
      paths.push(element.pbs_file_suffix) if !paths.include?(element.pbs_file_suffix)
    end
    paths.each_with_index do |element, i|
      paths[i] = [sprintf("PBS/%s.txt", GameData::Metadata::PBS_BASE_FILENAME), element]
      if !nil_or_empty?(element)
        paths[i][0] = sprintf("PBS/%s_%s.txt", GameData::Metadata::PBS_BASE_FILENAME, element)
      end
    end
    global_schema = GameData::Metadata.schema
    player_schema = GameData::PlayerMetadata.schema
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        [GameData::Metadata, GameData::PlayerMetadata].each do |game_data|
          schema = global_schema if game_data == GameData::Metadata
          schema = player_schema if game_data == GameData::PlayerMetadata
          game_data.each do |element|
            next if element.pbs_file_suffix != path[1]
            f.write("\#-------------------------------\r\n")
            if schema["SectionName"]
              f.write("[")
              pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
              f.write("]\r\n")
            else
              f.write("[#{element.id}]\r\n")
            end
            schema.each_key do |key|
              next if key == "SectionName"
              val = element.get_property_for_PBS(key)
              next if val.nil?
              if schema[key][1][0] == "^" && val.is_a?(Array)
                val.each do |sub_val|
                  f.write(sprintf("%s = ", key))
                  pbWriteCsvRecord(sub_val, f, schema[key])
                  f.write("\r\n")
                end
              else
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(val, f, schema[key])
                f.write("\r\n")
              end
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save map metadata data to PBS file
  # NOTE: Doesn't use write_PBS_file_generic because it writes the RMXP map name
  #       next to the section header for each map.
  #=============================================================================
  def write_map_metadata
    paths = get_all_PBS_file_paths(GameData::MapMetadata)
    map_infos = pbLoadMapInfos
    schema = GameData::MapMetadata.schema
    idx = 0
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        GameData::MapMetadata.each do |element|
          next if element.pbs_file_suffix != path[1]
          echo "." if idx % 100 == 0
          Graphics.update if idx % 500 == 0
          idx += 1
          f.write("\#-------------------------------\r\n")
          map_name = (map_infos && map_infos[element.id]) ? map_infos[element.id].name : nil
          f.write(sprintf("[%03d]", element.id))
          f.write(sprintf("   # %s", map_name)) if map_name
          f.write("\r\n")
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save dungeon tileset contents data to PBS file
  # NOTE: Doesn't use write_PBS_file_generic because it writes the tileset name
  #       next to the section header for each tileset.
  #=============================================================================
  def write_dungeon_tilesets
    paths = get_all_PBS_file_paths(GameData::DungeonTileset)
    schema = GameData::DungeonTileset.schema
    tilesets = load_data("Data/Tilesets.rxdata")
    paths.each do |path|
      write_pbs_file_message_start(path[0])
      File.open(path[0], "wb") do |f|
        add_PBS_header_to_file(f)
        # Write each element in turn
        GameData::DungeonTileset.each do |element|
          next if element.pbs_file_suffix != path[1]
          f.write("\#-------------------------------\r\n")
          if schema["SectionName"]
            f.write("[")
            pbWriteCsvRecord(element.get_property_for_PBS("SectionName"), f, schema["SectionName"])
            f.write("]")
            f.write("   # #{tilesets[element.id].name}") if tilesets && tilesets[element.id]
            f.write("\r\n")
          else
            f.write("[#{element.id}]\r\n")
          end
          schema.each_key do |key|
            next if key == "SectionName"
            val = element.get_property_for_PBS(key)
            next if val.nil?
            if schema[key][1][0] == "^" && val.is_a?(Array)
              val.each do |sub_val|
                f.write(sprintf("%s = ", key))
                pbWriteCsvRecord(sub_val, f, schema[key])
                f.write("\r\n")
              end
            else
              f.write(sprintf("%s = ", key))
              pbWriteCsvRecord(val, f, schema[key])
              f.write("\r\n")
            end
          end
        end
      end
      process_pbs_file_message_end
    end
  end

  #=============================================================================
  # Save dungeon parameters to PBS file
  #=============================================================================
  def write_dungeon_parameters
    write_PBS_file_generic(GameData::DungeonParameters)
  end

  #=============================================================================
  # Save phone messages to PBS file
  #=============================================================================
  def write_phone
    write_PBS_file_generic(GameData::PhoneMessage)
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
    Console.echo_h1(_INTL("Writing all PBS files"))
    write_town_map
    write_connections
    write_types
    write_abilities
    write_moves
    write_items
    write_berry_plants
    write_pokemon
    write_pokemon_forms
    write_pokemon_metrics
    write_shadow_pokemon
    write_regional_dexes
    write_ribbons
    write_encounters
    write_trainer_types
    write_trainers
    write_trainer_lists
    write_metadata
    write_map_metadata
    write_dungeon_tilesets
    write_dungeon_parameters
    write_phone
    echoln ""
    Console.echo_h2(_INTL("Successfully rewrote all PBS files"), text: :green)
  end
end
