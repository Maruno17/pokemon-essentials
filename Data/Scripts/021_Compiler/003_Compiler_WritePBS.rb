module Compiler
  module_function

  def add_PBS_header_to_file(file)
    file.write(0xEF.chr)
    file.write(0xBB.chr)
    file.write(0xBF.chr)
    file.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
  end

  #=============================================================================
  # Save Town Map data to PBS file
  #=============================================================================
  def write_town_map(path = "PBS/town_map.txt")
    mapdata = pbLoadTownMapData
    return if !mapdata
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      mapdata.length.times do |i|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        map = mapdata[i]
        next if !map
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", i))
        rname = pbGetMessage(MessageTypes::RegionNames, i)
        f.write(sprintf("Name = %s\r\n", (rname && rname != "") ? rname : _INTL("Unnamed")))
        f.write(sprintf("Filename = %s\r\n", csvQuote((map[1].is_a?(Array)) ? map[1][0] : map[1])))
        map[2].each do |loc|
          f.write("Point = ")
          pbWriteCsvRecord(loc, f, [nil, "uussUUUU"])
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
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
    File.open(path, "wb") { |f|
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
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save phone messages to PBS file
  #=============================================================================
  def write_phone(path = "PBS/phone.txt")
    data = load_data("Data/phone.dat") rescue nil
    return if !data
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      f.write("[<Generics>]\r\n")
      f.write(data.generics.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<BattleRequests>]\r\n")
      f.write(data.battleRequests.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<GreetingsMorning>]\r\n")
      f.write(data.greetingsMorning.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<GreetingsEvening>]\r\n")
      f.write(data.greetingsEvening.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<Greetings>]\r\n")
      f.write(data.greetings.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<Bodies1>]\r\n")
      f.write(data.bodies1.join("\r\n") + "\r\n")
      f.write("\#-------------------------------\r\n")
      f.write("[<Bodies2>]\r\n")
      f.write(data.bodies2.join("\r\n") + "\r\n")
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save type data to PBS file
  #=============================================================================
  def write_types(path = "PBS/types.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each type in turn
      GameData::Type.each do |type|
        f.write("\#-------------------------------\r\n")
        f.write("[#{type.id}]\r\n")
        f.write("Name = #{type.real_name}\r\n")
        f.write("IconPosition = #{type.icon_position}\r\n")
        f.write("IsSpecialType = true\r\n") if type.special?
        f.write("IsPseudoType = true\r\n") if type.pseudo_type
        f.write(sprintf("Flags = %s\r\n", type.flags.join(","))) if type.flags.length > 0
        f.write("Weaknesses = #{type.weaknesses.join(',')}\r\n") if type.weaknesses.length > 0
        f.write("Resistances = #{type.resistances.join(',')}\r\n") if type.resistances.length > 0
        f.write("Immunities = #{type.immunities.join(',')}\r\n") if type.immunities.length > 0
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_abilities(path = "PBS/abilities.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each ability in turn
      GameData::Ability.each do |ability|
        f.write("\#-------------------------------\r\n")
        f.write("[#{ability.id}]\r\n")
        f.write("Name = #{ability.real_name}\r\n")
        f.write("Description = #{ability.real_description}\r\n")
        f.write(sprintf("Flags = %s\r\n", ability.flags.join(","))) if ability.flags.length > 0
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save move data to PBS file
  #=============================================================================
  def write_moves(path = "PBS/moves.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      # Write each move in turn
      GameData::Move.each do |move|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        f.write("[#{move.id}]\r\n")
        f.write("Name = #{move.real_name}\r\n")
        f.write("Type = #{move.type}\r\n")
        category = GameData::Move::SCHEMA["Category"][2][move.category]
        f.write("Category = #{category}\r\n")
        f.write("Power = #{move.base_damage}\r\n") if move.base_damage > 0
        f.write("Accuracy = #{move.accuracy}\r\n")
        f.write("TotalPP = #{move.total_pp}\r\n")
        f.write("Target = #{move.target}\r\n")
        f.write("Priority = #{move.priority}\r\n") if move.priority != 0
        f.write("FunctionCode = #{move.function_code}\r\n")
        f.write("Flags = #{move.flags.join(',')}\r\n") if move.flags.length > 0
        f.write("EffectChance = #{move.effect_chance}\r\n") if move.effect_chance > 0
        f.write("Description = #{move.real_description}\r\n")
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items(path = "PBS/items.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Item.each do |item|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", item.id))
        f.write(sprintf("Name = %s\r\n", item.real_name))
        f.write(sprintf("NamePlural = %s\r\n", item.real_name_plural))
        f.write(sprintf("Pocket = %d\r\n", item.pocket))
        f.write(sprintf("Price = %d\r\n", item.price))
        f.write(sprintf("SellPrice = %d\r\n", item.sell_price)) if item.sell_price != item.price / 2
        field_use = GameData::Item::SCHEMA["FieldUse"][2].key(item.field_use)
        f.write(sprintf("FieldUse = %s\r\n", field_use)) if field_use
        battle_use = GameData::Item::SCHEMA["BattleUse"][2].key(item.battle_use)
        f.write(sprintf("BattleUse = %s\r\n", battle_use)) if battle_use
        f.write(sprintf("Consumable = false\r\n")) if !item.is_important? && !item.consumable
        f.write(sprintf("Flags = %s\r\n", item.flags.join(","))) if item.flags.length > 0
        f.write(sprintf("Move = %s\r\n", item.move)) if item.move
        f.write(sprintf("Description = %s\r\n", item.real_description))
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save berry plant data to PBS file
  #=============================================================================
  def write_berry_plants(path = "PBS/berry_plants.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::BerryPlant.each do |bp|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", bp.id))
        f.write(sprintf("HoursPerStage = %d\r\n", bp.hours_per_stage))
        f.write(sprintf("DryingPerHour = %d\r\n", bp.drying_per_hour))
        f.write(sprintf("Yield = %s\r\n", bp.yield.join(",")))
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save Pokémon data to PBS file
  #=============================================================================
  def write_pokemon(path = "PBS/pokemon.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Species.each_species do |species|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", species.id))
        f.write(sprintf("Name = %s\r\n", species.real_name))
        f.write(sprintf("Types = %s\r\n", species.types.uniq.compact.join(",")))
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array.concat([s.id.to_s, species.evs[s.id]]) if species.evs[s.id] > 0
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(",")))
        f.write(sprintf("GenderRatio = %s\r\n", species.gender_ratio))
        f.write(sprintf("GrowthRate = %s\r\n", species.growth_rate))
        f.write(sprintf("BaseExp = %d\r\n", species.base_exp))
        f.write(sprintf("EVs = %s\r\n", evs_array.join(",")))
        f.write(sprintf("CatchRate = %d\r\n", species.catch_rate))
        f.write(sprintf("Happiness = %d\r\n", species.happiness))
        if species.abilities.length > 0
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0
          f.write(sprintf("HiddenAbilities = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0
          f.write(sprintf("EggGroups = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("HatchSteps = %d\r\n", species.hatch_steps))
        f.write(sprintf("Incense = %s\r\n", species.incense)) if species.incense
        if species.offspring.length > 0
          f.write(sprintf("Offspring = %s\r\n", species.offspring.join(",")))
        end
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0))
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0))
        f.write(sprintf("Color = %s\r\n", species.color))
        f.write(sprintf("Shape = %s\r\n", species.shape))
        f.write(sprintf("Habitat = %s\r\n", species.habitat)) if species.habitat != :None
        f.write(sprintf("Category = %s\r\n", species.real_category))
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != 0
        f.write(sprintf("Flags = %s\r\n", species.flags.join(","))) if species.flags.length > 0
        f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common.join(","))) if species.wild_item_common.length > 0
        f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon.join(","))) if species.wild_item_uncommon.length > 0
        f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare.join(","))) if species.wild_item_rare.length > 0
        if species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if param_type.is_a?(Symbol) && !GameData.const_defined?(param_type)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save Pokémon forms data to PBS file
  #=============================================================================
  def write_pokemon_forms(path = "PBS/pokemon_forms.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        next if species.form == 0
        base_species = GameData::Species.get(species.species)
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s,%d]\r\n", species.species, species.form))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("PokedexForm = %d\r\n", species.pokedex_form)) if species.pokedex_form != species.form
        f.write(sprintf("MegaStone = %s\r\n", species.mega_stone)) if species.mega_stone
        f.write(sprintf("MegaMove = %s\r\n", species.mega_move)) if species.mega_move
        f.write(sprintf("UnmegaForm = %d\r\n", species.unmega_form)) if species.unmega_form != 0
        f.write(sprintf("MegaMessage = %d\r\n", species.mega_message)) if species.mega_message != 0
        if species.types.uniq.compact != base_species.types.uniq.compact
          f.write(sprintf("Types = %s\r\n", species.types.uniq.compact.join(",")))
        end
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array.concat([s.id.to_s, species.evs[s.id]]) if species.evs[s.id] > 0
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(","))) if species.base_stats != base_species.base_stats
        f.write(sprintf("BaseExp = %d\r\n", species.base_exp)) if species.base_exp != base_species.base_exp
        f.write(sprintf("EVs = %s\r\n", evs_array.join(","))) if species.evs != base_species.evs
        f.write(sprintf("CatchRate = %d\r\n", species.catch_rate)) if species.catch_rate != base_species.catch_rate
        f.write(sprintf("Happiness = %d\r\n", species.happiness)) if species.happiness != base_species.happiness
        if species.abilities.length > 0 && species.abilities != base_species.abilities
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0 && species.hidden_abilities != base_species.hidden_abilities
          f.write(sprintf("HiddenAbilities = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0 && species.moves != base_species.moves
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0 && species.tutor_moves != base_species.tutor_moves
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0 && species.egg_moves != base_species.egg_moves
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0 && species.egg_groups != base_species.egg_groups
          f.write(sprintf("EggGroups = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("HatchSteps = %d\r\n", species.hatch_steps)) if species.hatch_steps != base_species.hatch_steps
        if species.offspring.length > 0 && species.offspring != base_species.offspring
          f.write(sprintf("Offspring = %s\r\n", species.offspring.join(",")))
        end
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0)) if species.height != base_species.height
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0)) if species.weight != base_species.weight
        f.write(sprintf("Color = %s\r\n", species.color)) if species.color != base_species.color
        f.write(sprintf("Shape = %s\r\n", species.shape)) if species.shape != base_species.shape
        if species.habitat != :None && species.habitat != base_species.habitat
          f.write(sprintf("Habitat = %s\r\n", species.habitat))
        end
        f.write(sprintf("Category = %s\r\n", species.real_category)) if species.real_category != base_species.real_category
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry)) if species.real_pokedex_entry != base_species.real_pokedex_entry
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != base_species.generation
        f.write(sprintf("Flags = %s\r\n", species.flags.join(","))) if species.flags.length > 0 && species.flags != base_species.flags
        if species.wild_item_common != base_species.wild_item_common ||
           species.wild_item_uncommon != base_species.wild_item_uncommon ||
           species.wild_item_rare != base_species.wild_item_rare
          f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common.join(","))) if species.wild_item_common.length > 0
          f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon.join(","))) if species.wild_item_uncommon.length > 0
          f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare.join(","))) if species.wild_item_rare.length > 0
        end
        if species.evolutions != base_species.evolutions && species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if param_type.is_a?(Symbol) && !GameData.const_defined?(param_type)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Write species metrics
  #=============================================================================
  def write_pokemon_metrics(path = "PBS/pokemon_metrics.txt")
    write_pbs_file_message_start(path)
    # Get in species order then in form order
    sort_array = []
    dex_numbers = {}
    i = 0
    GameData::SpeciesMetrics.each do |metrics|
      dex_numbers[metrics.species] = i if !dex_numbers[metrics.species]
      sort_array.push([dex_numbers[metrics.species], metrics.id, metrics.species, metrics.form])
      i += 1
    end
    sort_array.sort! { |a, b| (a[0] == b[0]) ? a[3] <=> b[3] : a[0] <=> b[0] }
    # Write file
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      sort_array.each do |val|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        species = GameData::SpeciesMetrics.get(val[1])
        if species.form > 0
          base_species = GameData::SpeciesMetrics.get(val[2])
          next if species.back_sprite == base_species.back_sprite &&
                  species.front_sprite == base_species.front_sprite &&
                  species.front_sprite_altitude == base_species.front_sprite_altitude &&
                  species.shadow_x == base_species.shadow_x &&
                  species.shadow_size == base_species.shadow_size
        else
          next if species.back_sprite == [0, 0] && species.front_sprite == [0, 0] &&
                  species.front_sprite_altitude == 0 &&
                  species.shadow_x == 0 && species.shadow_size == 2
        end
        f.write("\#-------------------------------\r\n")
        if species.form > 0
          f.write(sprintf("[%s,%d]\r\n", species.species, species.form))
        else
          f.write(sprintf("[%s]\r\n", species.species))
        end
        f.write(sprintf("BackSprite = %s\r\n", species.back_sprite.join(",")))
        f.write(sprintf("FrontSprite = %s\r\n", species.front_sprite.join(",")))
        f.write(sprintf("FrontSpriteAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != 0
        f.write(sprintf("ShadowX = %d\r\n", species.shadow_x))
        f.write(sprintf("ShadowSize = %d\r\n", species.shadow_size))
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save Shadow Pokémon data to PBS file
  #=============================================================================
  def write_shadow_pokemon(path = "PBS/shadow_pokemon.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::ShadowPokemon.each do |shadow|
        echo "." if idx % 150 == 0
        idx += 1
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", shadow.id))
        f.write(sprintf("GaugeSize = %d\r\n", shadow.gauge_size))
        f.write(sprintf("Moves = %s\r\n", shadow.moves.join(","))) if shadow.moves.length > 0
        f.write(sprintf("Flags = %s\r\n", shadow.flags.join(","))) if shadow.flags.length > 0
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save Regional Dexes to PBS file
  #=============================================================================
  def write_regional_dexes(path = "PBS/regional_dexes.txt")
    write_pbs_file_message_start(path)
    dex_lists = pbLoadRegionalDexes
    File.open(path, "wb") { |f|
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
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_ribbons(path = "PBS/ribbons.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each ability in turn
      GameData::Ribbon.each do |ribbon|
        f.write("\#-------------------------------\r\n")
        f.write("[#{ribbon.id}]\r\n")
        f.write("Name = #{ribbon.real_name}\r\n")
        f.write("IconPosition = #{ribbon.icon_position}\r\n")
        f.write("Description = #{ribbon.real_description}\r\n")
        f.write(sprintf("Flags = %s\r\n", ribbon.flags.join(","))) if ribbon.flags.length > 0
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save wild encounter data to PBS file
  #=============================================================================
  def write_encounters(path = "PBS/encounters.txt")
    write_pbs_file_message_start(path)
    map_infos = pbLoadMapInfos
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Encounter.each do |encounter_data|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        map_name = (map_infos[encounter_data.map]) ? " # #{map_infos[encounter_data.map].name}" : ""
        if encounter_data.version > 0
          f.write(sprintf("[%03d,%d]%s\r\n", encounter_data.map, encounter_data.version, map_name))
        else
          f.write(sprintf("[%03d]%s\r\n", encounter_data.map, map_name))
        end
        encounter_data.types.each do |type, slots|
          next if !slots || slots.length == 0
          if encounter_data.step_chances[type] && encounter_data.step_chances[type] > 0
            f.write(sprintf("%s,%d\r\n", type.to_s, encounter_data.step_chances[type]))
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
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types(path = "PBS/trainer_types.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::TrainerType.each do |t|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", t.id))
        f.write(sprintf("Name = %s\r\n", t.real_name))
        gender = GameData::TrainerType::SCHEMA["Gender"][2].key(t.gender)
        f.write(sprintf("Gender = %s\r\n", gender))
        f.write(sprintf("BaseMoney = %d\r\n", t.base_money))
        f.write(sprintf("SkillLevel = %d\r\n", t.skill_level)) if t.skill_level != t.base_money
        f.write(sprintf("Flags = %s\r\n", t.flags.join(","))) if t.flags.length > 0
        f.write(sprintf("IntroBGM = %s\r\n", t.intro_BGM)) if !nil_or_empty?(t.intro_BGM)
        f.write(sprintf("BattleBGM = %s\r\n", t.battle_BGM)) if !nil_or_empty?(t.battle_BGM)
        f.write(sprintf("VictoryBGM = %s\r\n", t.victory_BGM)) if !nil_or_empty?(t.victory_BGM)
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_trainers(path = "PBS/trainers.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        if trainer.real_lose_text && !trainer.real_lose_text.empty?
          f.write(sprintf("LoseText = %s\r\n", trainer.real_lose_text))
        end
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
          f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
          f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
          f.write("    Shiny = yes\r\n") if pkmn[:shininess] && !pkmn[:super_shininess]
          f.write("    SuperShiny = yes\r\n") if pkmn[:super_shininess]
          f.write("    Shadow = yes\r\n") if pkmn[:shadowness]
          f.write(sprintf("    Moves = %s\r\n", pkmn[:moves].join(","))) if pkmn[:moves] && pkmn[:moves].length > 0
          f.write(sprintf("    Ability = %s\r\n", pkmn[:ability])) if pkmn[:ability]
          f.write(sprintf("    AbilityIndex = %d\r\n", pkmn[:ability_index])) if pkmn[:ability_index]
          f.write(sprintf("    Item = %s\r\n", pkmn[:item])) if pkmn[:item]
          f.write(sprintf("    Nature = %s\r\n", pkmn[:nature])) if pkmn[:nature]
          ivs_array = []
          evs_array = []
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ivs_array[s.pbs_order] = pkmn[:iv][s.id] if pkmn[:iv]
            evs_array[s.pbs_order] = pkmn[:ev][s.id] if pkmn[:ev]
          end
          f.write(sprintf("    IV = %s\r\n", ivs_array.join(","))) if pkmn[:iv]
          f.write(sprintf("    EV = %s\r\n", evs_array.join(","))) if pkmn[:ev]
          f.write(sprintf("    Happiness = %d\r\n", pkmn[:happiness])) if pkmn[:happiness]
          f.write(sprintf("    Ball = %s\r\n", pkmn[:poke_ball])) if pkmn[:poke_ball]
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save trainer list data to PBS file
  #=============================================================================
  def write_trainer_lists(path = "PBS/battle_facility_lists.txt")
    trainerlists = load_data("Data/trainer_lists.dat") rescue nil
    return if !trainerlists
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
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
    }
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
    File.open(filename, "wb") { |f|
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
          f.write(sprintf("\r\n"))
        end
      end
    }
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
    File.open(filename, "wb") { |f|
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
        pkmn.ev.each_with_index do |stat, i|
          evlist += "," if i > 0
          evlist += evs[stat]
        end
        c4 = c5 = c6 = c7 = ""
        [pkmn.move1, pkmn.move2, pkmn.move3, pkmn.move4].each_with_index do |move, i|
          next if !move
          text = (moves[move]) ? moves[move] : (moves[move] = GameData::Move.get(move).id.to_s)
          case i
          when 0 then c4 = text
          when 1 then c5 = text
          when 2 then c6 = text
          when 3 then c7 = text
          end
        end
        f.write("#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}\r\n")
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save metadata data to PBS file
  #=============================================================================
  def write_metadata(path = "PBS/metadata.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write metadata
      f.write("\#-------------------------------\r\n")
      f.write("[0]\r\n")
      metadata = GameData::Metadata.get
      schema = GameData::Metadata::SCHEMA
      keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
      keys.each do |key|
        record = metadata.property_from_string(key)
        next if record.nil? || (record.is_a?(Array) && record.empty?)
        f.write(sprintf("%s = ", key))
        pbWriteCsvRecord(record, f, schema[key])
        f.write("\r\n")
      end
      # Write player metadata
      schema = GameData::PlayerMetadata::SCHEMA
      keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
      GameData::PlayerMetadata.each do |player_data|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", player_data.id))
        keys.each do |key|
          record = player_data.property_from_string(key)
          next if record.nil? || (record.is_a?(Array) && record.empty?)
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(record, f, schema[key])
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save map metadata data to PBS file
  #=============================================================================
  def write_map_metadata(path = "PBS/map_metadata.txt")
    write_pbs_file_message_start(path)
    map_infos = pbLoadMapInfos
    schema = GameData::MapMetadata::SCHEMA
    keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::MapMetadata.each do |map_data|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        map_name = (map_infos && map_infos[map_data.id]) ? map_infos[map_data.id].name : nil
        if map_name
          f.write(sprintf("[%03d]   # %s\r\n", map_data.id, map_name))
          f.write("Name = #{map_name}\r\n") if nil_or_empty?(map_data.real_name)
        else
          f.write(sprintf("[%03d]\r\n", map_data.id))
        end
        keys.each do |key|
          record = map_data.property_from_string(key)
          next if record.nil? || (record.is_a?(Array) && record.empty?)
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(record, f, schema[key])
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
    Console.echo_h1 _INTL("Writing all PBS files")
    write_town_map
    write_connections
    write_phone
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
    echoln ""
    Console.echo_h2("Successfully rewrote all PBS files", text: :green)
  end
end
