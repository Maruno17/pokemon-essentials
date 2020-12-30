#===============================================================================
# Save type data to PBS file
#===============================================================================
def pbSaveTypes
  File.open("PBS/types.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    # Write each type in turn
    GameData::Type.each do |type|
      f.write("\#-------------------------------\r\n")
      f.write("[#{type.id_number}]\r\n")
      f.write("Name = #{type.real_name}\r\n")
      f.write("InternalName = #{type.id.to_s}\r\n")
      f.write("IsPseudoType = true\r\n") if type.pseudo_type
      f.write("IsSpecialType = true\r\n") if type.special?
      f.write("Weaknesses = #{type.weaknesses.join(",")}\r\n") if type.weaknesses.length > 0
      f.write("Resistances = #{type.resistances.join(",")}\r\n") if type.resistances.length > 0
      f.write("Immunities = #{type.immunities.join(",")}\r\n") if type.immunities.length > 0
    end
  }
end

#===============================================================================
# Save ability data to PBS file
#===============================================================================
def pbSaveAbilities
  File.open("PBS/abilities.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save move data to PBS file
#===============================================================================
def pbSaveMoveData
  File.open("PBS/moves.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
        (getConstantName(PBTargets, m.target) rescue sprintf("%d", m.target)),
        m.priority,
        csvQuote(m.flags),
        csvQuoteAlways(m.real_description)
      ))
    end
  }
end

#===============================================================================
# Save map connection data to PBS file
#===============================================================================
def normalizeConnectionPoint(conn)
  ret = conn.clone
  if conn[1]<0 && conn[4]<0
  elsif conn[1]<0 || conn[4]<0
    ret[4] = -conn[1]
    ret[1] = -conn[4]
  end
  if conn[2]<0 && conn[5]<0
  elsif conn[2]<0 || conn[5]<0
    ret[5] = -conn[2]
    ret[2] = -conn[5]
  end
  return ret
end

def writeConnectionPoint(map1,x1,y1,map2,x2,y2)
  dims1 = MapFactoryHelper.getMapDims(map1)
  dims2 = MapFactoryHelper.getMapDims(map2)
  if x1==0 && x2==dims2[0]
    return sprintf("%d,West,%d,%d,East,%d",map1,y1,map2,y2)
  elsif y1==0 && y2==dims2[1]
    return sprintf("%d,North,%d,%d,South,%d",map1,x1,map2,x2)
  elsif x1==dims1[0] && x2==0
    return sprintf("%d,East,%d,%d,West,%d",map1,y1,map2,y2)
  elsif y1==dims1[1] && y2==0
    return sprintf("%d,South,%d,%d,North,%d",map1,x1,map2,x2)
  end
  return sprintf("%d,%d,%d,%d,%d,%d",map1,x1,y1,map2,x2,y2)
end

def pbSerializeConnectionData(conndata,mapinfos)
  File.open("PBS/connections.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    f.write("\#-------------------------------\r\n")
    for conn in conndata
      if mapinfos
        # Skip if map no longer exists
        next if !mapinfos[conn[0]] || !mapinfos[conn[3]]
        f.write(sprintf("# %s (%d) - %s (%d)\r\n",
           mapinfos[conn[0]] ? mapinfos[conn[0]].name : "???",conn[0],
           mapinfos[conn[3]] ? mapinfos[conn[3]].name : "???",conn[3]))
      end
      if conn[1].is_a?(String) || conn[4].is_a?(String)
        f.write(sprintf("%d,%s,%d,%d,%s,%d",conn[0],conn[1],
           conn[2],conn[3],conn[4],conn[5]))
      else
        ret = normalizeConnectionPoint(conn)
        f.write(writeConnectionPoint(ret[0],ret[1],ret[2],ret[3],ret[4],ret[5]))
      end
      f.write("\r\n")
    end
  }
  save_data(conndata,"Data/map_connections.dat")
end

def pbSaveConnectionData
  data = load_data("Data/map_connections.dat") rescue nil
  return if !data
  pbSerializeConnectionData(data,pbLoadRxData("Data/MapInfos"))
end

#===============================================================================
# Save metadata data to PBS file
#===============================================================================
def pbSaveMetadata
  File.open("PBS/metadata.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
    map_infos = pbLoadRxData("Data/MapInfos")
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
end

#===============================================================================
# Save item data to PBS file
#===============================================================================
def pbSaveItems
  File.open("PBS/items.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save berry plant data to PBS file
#===============================================================================
def pbSaveBerryPlants
  File.open("PBS/berryplants.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save trainer list data to PBS file
#===============================================================================
def pbSaveTrainerLists
  trainerlists = load_data("Data/trainer_lists.dat") rescue nil
  return if !trainerlists
  File.open("PBS/trainerlists.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    for tr in trainerlists
      f.write("\#-------------------------------\r\n")
      f.write(((tr[5]) ? "[DefaultTrainerList]" : "[TrainerList]")+"\r\n")
      f.write("Trainers = "+tr[3]+"\r\n")
      f.write("Pokemon = "+tr[4]+"\r\n")
      f.write("Challenges = "+tr[2].join(",")+"\r\n") if !tr[5]
      pbSaveBTTrainers(tr[0],"PBS/"+tr[3])
      pbSaveBattlePokemon(tr[1],"PBS/"+tr[4])
    end
  }
end

#===============================================================================
# Save wild encounter data to PBS file
#===============================================================================
def pbSaveEncounterData
  encdata = pbLoadEncountersData
  return if !encdata
  mapinfos = pbLoadRxData("Data/MapInfos")
  File.open("PBS/encounters.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    sortedkeys = encdata.keys.sort
    for i in sortedkeys
      next if !encdata[i]
      e = encdata[i]
      mapname = ""
      if mapinfos[i]
        map = mapinfos[i].name
        mapname = " # #{map}"
      end
      f.write("\#-------------------------------\r\n")
      f.write(sprintf("%03d%s\r\n",i,mapname))
      f.write(sprintf("%d,%d,%d\r\n",e[0][EncounterTypes::Land],
          e[0][EncounterTypes::Cave],e[0][EncounterTypes::Water]))
      for j in 0...e[1].length
        enc = e[1][j]
        next if !enc
        f.write(sprintf("%s\r\n",EncounterTypes::Names[j]))
        for k in 0...EncounterTypes::EnctypeChances[j].length
          next if !enc[k]
          encentry = enc[k]
          if encentry[1]==encentry[2]
            f.write(sprintf("    %s,%d\r\n",encentry[0],encentry[1]))
          else
            f.write(sprintf("    %s,%d,%d\r\n",encentry[0],encentry[1],encentry[2]))
          end
        end
      end
    end
  }
end

#===============================================================================
# Save trainer type data to PBS file
#===============================================================================
def pbSaveTrainerTypes
  File.open("PBS/trainertypes.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save individual trainer data to PBS file
#===============================================================================
def pbSaveTrainerBattles
  data = pbLoadTrainersData
  return if !data
  File.open("PBS/trainers.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    for trainer in data
      trtypename = trainer[0].to_s
      next if !trtypename
      f.write("\#-------------------------------\r\n")
      # Section
      trainername = trainer[1] ? trainer[1].gsub(/,/,";") : "???"
      if trainer[4]==0
        f.write(sprintf("[%s,%s]\r\n",trtypename,trainername))
      else
        f.write(sprintf("[%s,%s,%d]\r\n",trtypename,trainername,trainer[4]))
      end
      # Trainer's items
      if trainer[2] && trainer[2].length>0
        itemstring = ""
        for i in 0...trainer[2].length
          itemstring.concat(",") if i > 0
          itemstring.concat(trainer[2][i].to_s)
        end
        f.write(sprintf("Items = %s\r\n",itemstring)) if itemstring!=""
      end
      # Lose texts
      if trainer[5] && trainer[5]!=""
        f.write(sprintf("LoseText = %s\r\n",csvQuoteAlways(trainer[5])))
      end
      # Pokémon
      for poke in trainer[3]
        f.write(sprintf("Pokemon = %s,%d\r\n",poke[TrainerData::SPECIES],poke[TrainerData::LEVEL]))
        if poke[TrainerData::NAME] && poke[TrainerData::NAME]!=""
          f.write(sprintf("    Name = %s\r\n",poke[TrainerData::NAME]))
        end
        if poke[TrainerData::FORM]
          f.write(sprintf("    Form = %d\r\n",poke[TrainerData::FORM]))
        end
        if poke[TrainerData::GENDER]
          f.write(sprintf("    Gender = %s\r\n",(poke[TrainerData::GENDER]==1) ? "female" : "male"))
        end
        if poke[TrainerData::SHINY]
          f.write("    Shiny = yes\r\n")
        end
        if poke[TrainerData::SHADOW]
          f.write("    Shadow = yes\r\n")
        end
        if poke[TrainerData::MOVES] && poke[TrainerData::MOVES].length>0
          movestring = ""
          for i in 0...poke[TrainerData::MOVES].length
            movename = GameData::Move.get(poke[TrainerData::MOVES][i]).id.to_s
            next if !movename
            movestring.concat(",") if i>0
            movestring.concat(movename)
          end
          f.write(sprintf("    Moves = %s\r\n",movestring)) if movestring!=""
        end
        if poke[TrainerData::ABILITY]
          f.write(sprintf("    Ability = %s\r\n",poke[TrainerData::ABILITY].to_s))
        end
        if poke[TrainerData::ITEM]
          f.write(sprintf("    Item = %s\r\n",poke[TrainerData::ITEM].to_s))
        end
        if poke[TrainerData::NATURE]
          nature = getConstantName(PBNatures,poke[TrainerData::NATURE]) rescue nil
          f.write(sprintf("    Nature = %s\r\n",nature)) if nature
        end
        if poke[TrainerData::IV] && poke[TrainerData::IV].length>0
          f.write(sprintf("    IV = %d",poke[TrainerData::IV][0]))
          if poke[TrainerData::IV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TrainerData::IV].length) ? poke[TrainerData::IV][i] : poke[TrainerData::IV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TrainerData::EV] && poke[TrainerData::EV].length>0
          f.write(sprintf("    EV = %d",poke[TrainerData::EV][0]))
          if poke[TrainerData::EV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TrainerData::EV].length) ? poke[TrainerData::EV][i] : poke[TrainerData::EV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TrainerData::HAPPINESS]
          f.write(sprintf("    Happiness = %d\r\n",poke[TrainerData::HAPPINESS]))
        end
        if poke[TrainerData::BALL]
          f.write(sprintf("    Ball = %d\r\n",poke[TrainerData::BALL]))
        end
      end
    end
  }
end

#===============================================================================
# Save Town Map data to PBS file
#===============================================================================
def pbSaveTownMap
  mapdata = pbLoadTownMapData
  return if !mapdata
  File.open("PBS/townmap.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save phone message data to PBS file
#===============================================================================
def pbSavePhoneData
  data = load_data("Data/phone.dat") rescue nil
  return if !data
  File.open("PBS/phone.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<Generics>]\r\n")
    f.write(data.generics.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<BattleRequests>]\r\n")
    f.write(data.battleRequests.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<GreetingsMorning>]\r\n")
    f.write(data.greetingsMorning.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<GreetingsEvening>]\r\n")
    f.write(data.greetingsEvening.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<Greetings>]\r\n")
    f.write(data.greetings.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<Bodies1>]\r\n")
    f.write(data.bodies1.join("\r\n")+"\r\n")
    f.write("\#-------------------------------\r\n")
    f.write("[<Bodies2>]\r\n")
    f.write(data.bodies2.join("\r\n")+"\r\n")
  }
end

#===============================================================================
# Save Pokémon data to PBS file
#===============================================================================
def pbSavePokemonData
  File.open("PBS/pokemon.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
      f.write(sprintf("BaseStats = %s\r\n", species.base_stats.join(",")))
      f.write(sprintf("GenderRate = %s\r\n", getConstantName(PBGenderRates, species.gender_rate)))
      f.write(sprintf("GrowthRate = %s\r\n", getConstantName(PBGrowthRates, species.growth_rate)))
      f.write(sprintf("BaseEXP = %d\r\n", species.base_exp))
      f.write(sprintf("EffortPoints = %s\r\n", species.evs.join(",")))
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
        f.write("Compatibility = ")
        species.egg_groups.each_with_index do |group, i|
          f.write(",") if i > 0
          f.write(getConstantName(PBEggGroups, group))
        end
        f.write("\r\n")
      end
      f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps))
      f.write(sprintf("Height = %.1f\r\n", species.height / 10.0))
      f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0))
      f.write(sprintf("Color = %s\r\n", getConstantName(PBColors, species.color)))
      f.write(sprintf("Shape = %d\r\n", species.shape))
      f.write(sprintf("Habitat = %s\r\n", getConstantName(PBHabitats, species.habitat))) if species.habitat != PBHabitats::None
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
          f.write(sprintf("%s,%s,", evo[0], getConstantName(PBEvolution, evo[1])))
          param_type = PBEvolution.getFunction(evo[1], "parameterType")
          has_param = !PBEvolution.hasFunction?(evo[1], "parameterType") || param_type != nil
          next if !has_param
          if param_type
            if GameData.const_defined?(param_type.to_sym)
              f.write(evo[2].to_s)
            else
              f.write(getConstantName(param_type, evo[2]))
            end
          else
            f.write(evo[2].to_s)
          end
        end
        f.write("\r\n")
      end
      f.write(sprintf("Incense = %s\r\n", species.incense)) if species.incense
    end
  }
  Graphics.update
end

#===============================================================================
# Save Pokémon forms data to PBS file
#===============================================================================
def pbSavePokemonFormsData
  File.open("PBS/pokemonforms.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
      f.write(sprintf("BaseStats = %s\r\n", species.base_stats.join(","))) if species.base_stats != base_species.base_stats
      f.write(sprintf("BaseEXP = %d\r\n", species.base_exp)) if species.base_exp != base_species.base_exp
      f.write(sprintf("EffortPoints = %s\r\n", species.evs.join(","))) if species.evs != base_species.evs
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
        f.write("Compatibility = ")
        species.egg_groups.each_with_index do |group, i|
          f.write(",") if i > 0
          f.write(getConstantName(PBEggGroups, group))
        end
        f.write("\r\n")
      end
      f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps)) if species.hatch_steps != base_species.hatch_steps
      f.write(sprintf("Height = %.1f\r\n", species.height / 10.0)) if species.height != base_species.height
      f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0)) if species.weight != base_species.weight
      f.write(sprintf("Color = %s\r\n", getConstantName(PBColors, species.color))) if species.color != base_species.color
      f.write(sprintf("Shape = %d\r\n", species.shape)) if species.shape != base_species.shape
      if species.habitat != PBHabitats::None && species.habitat != base_species.habitat
        f.write(sprintf("Habitat = %s\r\n", getConstantName(PBHabitats, species.habitat)))
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
          f.write(sprintf("%s,%s,", evo[0], getConstantName(PBEvolution, evo[1])))
          param_type = PBEvolution.getFunction(evo[1], "parameterType")
          has_param = !PBEvolution.hasFunction?(evo[1], "parameterType") || param_type != nil
          next if !has_param
          if param_type
            if GameData.const_defined?(param_type.to_sym)
              f.write(evo[2].to_s)
            else
              f.write(getConstantName(param_type, evo[2]))
            end
          else
            f.write(evo[2].to_s)
          end
        end
        f.write("\r\n")
      end
    end
  }
  Graphics.update
end

#===============================================================================
# Save Shadow move data to PBS file
#===============================================================================
def pbSaveShadowMoves
  shadow_movesets = pbLoadShadowMovesets
  File.open("PBS/shadowmoves.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    f.write("\#-------------------------------\r\n")
    GameData::Species.each do |species_data|
      moveset = shadow_movesets[species_data.id]
      next if !moveset || moveset.length == 0
      f.write(sprintf("%s = %s\r\n", species_data.id, moveset.join(",")))
    end
  }
end

#===============================================================================
# Save Regional Dexes data to PBS file
#===============================================================================
def pbSaveRegionalDexes
  dex_lists = pbLoadRegionalDexes
  File.open("PBS/regionaldexes.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
          current_family = EvolutionHelper.all_related_species(species)
          comma = false
          f.write("\r\n")
        end
        f.write(species)
        comma = true
      end
      f.write("\r\n")
    end
  }
end

#===============================================================================
# Save Battle Tower trainer data to PBS file
#===============================================================================
def pbSaveBTTrainers(bttrainers,filename)
  return if !bttrainers || !filename
  btTrainersRequiredTypes = {
     "Type"          => [0,"e",nil],  # Specifies a trainer
     "Name"          => [1,"s"],
     "BeginSpeech"   => [2,"s"],
     "EndSpeechWin"  => [3,"s"],
     "EndSpeechLose" => [4,"s"],
     "PokemonNos"    => [5,"*u"]
  }
  File.open(filename,"wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
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
end

#===============================================================================
# Save Battle Tower Pokémon data to PBS file
#===============================================================================
def pbSaveBattlePokemon(btpokemon,filename)
  return if !btpokemon || !filename
  species = {0=>""}
  moves   = {0=>""}
  items   = {0=>""}
  natures = {}
  File.open(filename,"wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 0...btpokemon.length
      Graphics.update if i%500==0
      pkmn = btpokemon[i]
      f.write(pbFastInspect(pkmn,moves,species,items,natures))
      f.write("\r\n")
    end
  }
end

def pbFastInspect(pkmn,moves,species,items,natures)
  c1 = (species[pkmn.species]) ? species[pkmn.species] : (species[pkmn.species] = GameData::Species.get(pkmn.species).species.to_s)
  c2 = (items[pkmn.item]) ? items[pkmn.item] : (items[pkmn.item] = GameData::Item.get(pkmn.item).id.to_s)
  c3 = (natures[pkmn.nature]) ? natures[pkmn.nature] :
     (natures[pkmn.nature] = getConstantName(PBNatures,pkmn.nature))
  evlist = ""
  ev = pkmn.ev
  evs = ["HP","ATK","DEF","SPD","SA","SD"]
  for i in 0...ev
    if ((ev&(1<<i))!=0)
      evlist += "," if evlist.length>0
      evlist += evs[i]
    end
  end
  c4 = (moves[pkmn.move1]) ? moves[pkmn.move1] : (moves[pkmn.move1] = GameData::Move.get(pkmn.move1).id.to_s)
  c5 = (moves[pkmn.move2]) ? moves[pkmn.move2] : (moves[pkmn.move2] = GameData::Move.get(pkmn.move2).id.to_s)
  c6 = (moves[pkmn.move3]) ? moves[pkmn.move3] : (moves[pkmn.move3] = GameData::Move.get(pkmn.move3).id.to_s)
  c7 = (moves[pkmn.move4]) ? moves[pkmn.move4] : (moves[pkmn.move4] = GameData::Move.get(pkmn.move4).id.to_s)
  return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}"
end

#===============================================================================
# Save all data to PBS files
#===============================================================================
def pbSaveAllData
  pbSaveTypes;            Graphics.update
  pbSaveAbilities;        Graphics.update
  pbSaveMoveData;         Graphics.update
  pbSaveConnectionData;   Graphics.update
  pbSaveMetadata;         Graphics.update
  pbSaveItems;            Graphics.update
  pbSaveBerryPlants;      Graphics.update
  pbSaveTrainerLists;     Graphics.update
  pbSaveEncounterData;    Graphics.update
  pbSaveTrainerTypes;     Graphics.update
  pbSaveTrainerBattles;   Graphics.update
  pbSaveTownMap;          Graphics.update
  pbSavePhoneData;        Graphics.update
  pbSavePokemonData;      Graphics.update
  pbSavePokemonFormsData; Graphics.update
  pbSaveShadowMoves;      Graphics.update
  pbSaveRegionalDexes;    Graphics.update
end
