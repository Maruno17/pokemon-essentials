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
  def write_town_map
    mapdata = pbLoadTownMapData
    return if !mapdata
    File.open("PBS/townmap.txt","wb") { |f|
      add_PBS_header_to_file(f)
      for i in 0...mapdata.length
        map = mapdata[i]
        next if !map
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n",i))
        rname = pbGetMessage(MessageTypes::RegionNames,i)
        f.write(sprintf("Name = %s\r\nFilename = %s\r\n",
          (rname && rname!="") ? rname : _INTL("Unnamed"),
          csvQuote((map[1].is_a?(Array)) ? map[1][0] : map[1])))
        for loc in map[2]
          f.write("Point = ")
          pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
          f.write("\r\n")
        end
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save map connections to PBS file
  #=============================================================================
  def normalize_connection(conn)
    ret = conn.clone
    if conn[1] < 0 && conn[4] < 0
    elsif conn[1] < 0 || conn[4] < 0
      ret[4] = -conn[1]
      ret[1] = -conn[4]
    end
    if conn[2] < 0 && conn[5] < 0
    elsif conn[2] < 0 || conn[5] < 0
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

  def write_connections
    conndata = load_data("Data/map_connections.dat")
    return if !conndata
    mapinfos = pbLoadMapInfos
    File.open("PBS/connections.txt","wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      for conn in conndata
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
    Graphics.update
  end

  #=============================================================================
  # Save phone messages to PBS file
  #=============================================================================
  def write_phone
    data = load_data("Data/phone.dat") rescue nil
    return if !data
    File.open("PBS/phone.txt", "wb") { |f|
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
    Graphics.update
  end

  #=============================================================================
  # Save type data to PBS file
  #=============================================================================
  def write_types
    File.open("PBS/types.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each type in turn
      GameData::Type.each do |type|
        f.write("\#-------------------------------\r\n")
        f.write("[#{type.id_number}]\r\n")
        f.write("Name = #{type.real_name}\r\n")
        f.write("InternalName = #{type.id}\r\n")
        f.write("IsPseudoType = true\r\n") if type.pseudo_type
        f.write("IsSpecialType = true\r\n") if type.special?
        f.write("Weaknesses = #{type.weaknesses.join(",")}\r\n") if type.weaknesses.length > 0
        f.write("Resistances = #{type.resistances.join(",")}\r\n") if type.resistances.length > 0
        f.write("Immunities = #{type.immunities.join(",")}\r\n") if type.immunities.length > 0
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_abilities
    File.open("PBS/abilities.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::Ability.each do |a|
        f.write(sprintf("%d,%s,%s,%s\r\n",
          a.id_number,
          csvQuote(a.id.to_s),
          csvQuote(a.real_name),
          csvQuoteAlways(a.real_description)
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save move data to PBS file
  #=============================================================================
  def write_moves
    File.open("PBS/moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      current_type = -1
      GameData::Move.each do |m|
        if current_type != m.type
          current_type = m.type
          f.write("\#-------------------------------\r\n")
        end
        f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s\r\n",
          m.id_number,
          csvQuote(m.id.to_s),
          csvQuote(m.real_name),
          csvQuote(m.function_code),
          m.base_damage,
          m.type.to_s,
          ["Physical", "Special", "Status"][m.category],
          m.accuracy,
          m.total_pp,
          m.effect_chance,
          m.target,
          m.priority,
          csvQuote(m.flags),
          csvQuoteAlways(m.real_description)
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    File.open("PBS/items.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      current_pocket = 0
      GameData::Item.each do |i|
        if current_pocket != i.pocket
          current_pocket = i.pocket
          f.write("\#-------------------------------\r\n")
        end
        move_name = (i.move) ? GameData::Move.get(i.move).id.to_s : ""
        sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d\r\n"
        sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d,%s\r\n" if move_name != ""
        f.write(sprintf(sprintf_text,
          i.id_number,
          csvQuote(i.id.to_s),
          csvQuote(i.real_name),
          csvQuote(i.real_name_plural),
          i.pocket,
          i.price,
          csvQuoteAlways(i.real_description),
          i.field_use,
          i.battle_use,
          i.type,
          csvQuote(move_name)
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save berry plant data to PBS file
  #=============================================================================
  def write_berry_plants
    File.open("PBS/berryplants.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::BerryPlant.each do |bp|
        f.write(sprintf("%s = %d,%d,%d,%d\r\n",
          csvQuote(bp.id.to_s),
          bp.hours_per_stage,
          bp.drying_per_hour,
          bp.minimum_yield,
          bp.maximum_yield
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save Pokémon data to PBS file
  #=============================================================================
  def write_pokemon
    File.open("PBS/pokemon.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form != 0
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", species.id_number))
        f.write(sprintf("Name = %s\r\n", species.real_name))
        f.write(sprintf("InternalName = %s\r\n", species.species))
        f.write(sprintf("Type1 = %s\r\n", species.type1))
        f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(",")))
        f.write(sprintf("GenderRate = %s\r\n", species.gender_ratio))
        f.write(sprintf("GrowthRate = %s\r\n", species.growth_rate))
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp))
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(",")))
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate))
        f.write(sprintf("Happiness = %d\r\n", species.happiness))
        if species.abilities.length > 0
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
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
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps))
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0))
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0))
        f.write(sprintf("Color = %s\r\n", species.color))
        f.write(sprintf("Shape = %s\r\n", species.shape))
        f.write(sprintf("Habitat = %s\r\n", species.habitat)) if species.habitat != :None
        f.write(sprintf("Kind = %s\r\n", species.real_category))
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != 0
        f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
        f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
        f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x))
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y))
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x))
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y))
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != 0
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x))
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size))
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
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
        f.write(sprintf("Incense = %s\r\n", species.incense)) if species.incense
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save Pokémon forms data to PBS file
  #=============================================================================
  def write_pokemon_forms
    File.open("PBS/pokemonforms.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form == 0
        base_species = GameData::Species.get(species.species)
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s,%d]\r\n", species.species, species.form))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("PokedexForm = %d\r\n", species.pokedex_form)) if species.pokedex_form != species.form
        f.write(sprintf("MegaStone = %s\r\n", species.mega_stone)) if species.mega_stone
        f.write(sprintf("MegaMove = %s\r\n", species.mega_move)) if species.mega_move
        f.write(sprintf("UnmegaForm = %d\r\n", species.unmega_form)) if species.unmega_form != 0
        f.write(sprintf("MegaMessage = %d\r\n", species.mega_message)) if species.mega_message != 0
        if species.type1 != base_species.type1 || species.type2 != base_species.type2
          f.write(sprintf("Type1 = %s\r\n", species.type1))
          f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        end
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(","))) if species.base_stats != base_species.base_stats
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp)) if species.base_exp != base_species.base_exp
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(","))) if species.evs != base_species.evs
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate)) if species.catch_rate != base_species.catch_rate
        f.write(sprintf("Happiness = %d\r\n", species.happiness)) if species.happiness != base_species.happiness
        if species.abilities.length > 0 && species.abilities != base_species.abilities
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0 && species.hidden_abilities != base_species.hidden_abilities
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
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
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps)) if species.hatch_steps != base_species.hatch_steps
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0)) if species.height != base_species.height
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0)) if species.weight != base_species.weight
        f.write(sprintf("Color = %s\r\n", species.color)) if species.color != base_species.color
        f.write(sprintf("Shape = %s\r\n", species.shape)) if species.shape != base_species.shape
        if species.habitat != :None && species.habitat != base_species.habitat
          f.write(sprintf("Habitat = %s\r\n", species.habitat))
        end
        f.write(sprintf("Kind = %s\r\n", species.real_category)) if species.real_category != base_species.real_category
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry)) if species.real_pokedex_entry != base_species.real_pokedex_entry
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != base_species.generation
        if species.wild_item_common != base_species.wild_item_common ||
           species.wild_item_uncommon != base_species.wild_item_uncommon ||
           species.wild_item_rare != base_species.wild_item_rare
          f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
          f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
          f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        end
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x)) if species.back_sprite_x != base_species.back_sprite_x
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y)) if species.back_sprite_y != base_species.back_sprite_y
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x)) if species.front_sprite_x != base_species.front_sprite_x
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y)) if species.front_sprite_y != base_species.front_sprite_y
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != base_species.front_sprite_altitude
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x)) if species.shadow_x != base_species.shadow_x
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size)) if species.shadow_size != base_species.shadow_size
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
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
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
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save Shadow movesets to PBS file
  #=============================================================================
  def write_shadow_movesets
    shadow_movesets = pbLoadShadowMovesets
    File.open("PBS/shadowmoves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::Species.each do |species_data|
        moveset = shadow_movesets[species_data.id]
        next if !moveset || moveset.length == 0
        f.write(sprintf("%s = %s\r\n", species_data.id, moveset.join(",")))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save Regional Dexes to PBS file
  #=============================================================================
  def write_regional_dexes
    dex_lists = pbLoadRegionalDexes
    File.open("PBS/regionaldexes.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each Dex list in turn
      dex_lists.each_with_index do |list, index|
        f.write("\#-------------------------------\r\n")
        f.write("[#{index}]")
        comma = false
        current_family = nil
        list.each do |species|
          next if !species
          if current_family && current_family.include?(species)
            f.write(",") if comma
          else
            current_family = GameData::Species.get(species).get_related_species
            comma = false
            f.write("\r\n")
          end
          f.write(species)
          comma = true
        end
        f.write("\r\n")
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_ribbons
    File.open("PBS/ribbons.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::Ribbon.each do |r|
        f.write(sprintf("%d,%s,%s,%s\r\n",
          r.id_number,
          csvQuote(r.id.to_s),
          csvQuote(r.real_name),
          csvQuoteAlways(r.real_description)
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save wild encounter data to PBS file
  #=============================================================================
  def write_encounters
    map_infos = pbLoadMapInfos
    File.open("PBS/encounters.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Encounter.each do |encounter_data|
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
    Graphics.update
  end

  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types
    File.open("PBS/trainertypes.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::TrainerType.each do |t|
        f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s,%s\r\n",
          t.id_number,
          csvQuote(t.id.to_s),
          csvQuote(t.real_name),
          t.base_money,
          csvQuote(t.battle_BGM),
          csvQuote(t.victory_ME),
          csvQuote(t.intro_ME),
          ["Male", "Female", "Mixed"][t.gender],
          (t.skill_level == t.base_money) ? "" : t.skill_level.to_s,
          csvQuote(t.skill_code)
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_trainers
    File.open("PBS/trainers.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        pbSetWindowText(_INTL("Writing trainer {1}...", trainer.id_number))
        Graphics.update if trainer.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        if trainer.real_lose_text && !trainer.real_lose_text.empty?
          f.write(sprintf("LoseText = %s\r\n", csvQuoteAlways(trainer.real_lose_text)))
        end
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
          f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
          f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
          f.write("    Shiny = yes\r\n") if pkmn[:shininess]
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
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save trainer list data to PBS file
  #=============================================================================
  def write_trainer_lists
    trainerlists = load_data("Data/trainer_lists.dat") rescue nil
    return if !trainerlists
    File.open("PBS/trainerlists.txt","wb") { |f|
      add_PBS_header_to_file(f)
      for tr in trainerlists
        f.write("\#-------------------------------\r\n")
        f.write(((tr[5]) ? "[DefaultTrainerList]" : "[TrainerList]")+"\r\n")
        f.write("Trainers = "+tr[3]+"\r\n")
        f.write("Pokemon = "+tr[4]+"\r\n")
        f.write("Challenges = "+tr[2].join(",")+"\r\n") if !tr[5]
        write_battle_tower_trainers(tr[0],"PBS/"+tr[3])
        write_battle_tower_pokemon(tr[1],"PBS/"+tr[4])
      end
    }
    Graphics.update
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
    File.open(filename,"wb") { |f|
      add_PBS_header_to_file(f)
      for i in 0...bttrainers.length
        next if !bttrainers[i]
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%03d]\r\n",i))
        for key in btTrainersRequiredTypes.keys
          schema = btTrainersRequiredTypes[key]
          record = bttrainers[i][schema[0]]
          next if record==nil
          f.write(sprintf("%s = ",key))
          if key=="Type"
            f.write(record.to_s)
          elsif key=="PokemonNos"
            f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
          else
            pbWriteCsvRecord(record,f,schema)
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
  def write_battle_tower_pokemon(btpokemon,filename)
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
    File.open(filename,"wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      for i in 0...btpokemon.length
        Graphics.update if i % 500 == 0
        pkmn = btpokemon[i]
        c1 = (species[pkmn.species]) ? species[pkmn.species] : (species[pkmn.species] = GameData::Species.get(pkmn.species).species.to_s)
        c2 = (items[pkmn.item]) ? items[pkmn.item] : (items[pkmn.item] = GameData::Item.get(pkmn.item).id.to_s)
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
  def write_metadata
    File.open("PBS/metadata.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      # Write global metadata
      f.write("\#-------------------------------\r\n")
      f.write("[000]\r\n")
      metadata = GameData::Metadata.get
      schema = GameData::Metadata::SCHEMA
      keys = schema.keys.sort {|a, b| schema[a][0] <=> schema[b][0] }
      for key in keys
        record = metadata.property_from_string(key)
        next if record.nil?
        f.write(sprintf("%s = ", key))
        pbWriteCsvRecord(record, f, schema[key])
        f.write("\r\n")
      end
      # Write map metadata
      map_infos = pbLoadMapInfos
      schema = GameData::MapMetadata::SCHEMA
      keys = schema.keys.sort {|a, b| schema[a][0] <=> schema[b][0] }
      GameData::MapMetadata.each do |map_data|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%03d]\r\n", map_data.id))
        if map_infos && map_infos[map_data.id]
          f.write(sprintf("# %s\r\n", map_infos[map_data.id].name))
        end
        for key in keys
          record = map_data.property_from_string(key)
          next if record.nil?
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(record, f, schema[key])
          f.write("\r\n")
        end
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
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
    write_shadow_movesets
    write_regional_dexes
    write_ribbons
    write_encounters
    write_trainer_types
    write_trainers
    write_trainer_lists
    write_metadata
  end
end
