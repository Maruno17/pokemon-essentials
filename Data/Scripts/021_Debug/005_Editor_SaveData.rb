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
# Save TM compatibility data to PBS file
#===============================================================================
def pbSaveMachines
  machines = pbLoadSpeciesTMData
  return if !machines
  File.open("PBS/tm.txt", "wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    keys = machines.keys.sort { |a, b| GameData::Move.get(a).id_number <=> GameData::Move.get(b).id_number }
    for i in 0...keys.length
      Graphics.update if i%50==0
      pbSetWindowText(_INTL("Writing move {1}/{2}", i, keys.length)) if i % 20 == 0
      next if !machines[keys[i]]
      movename = GameData::Move.get(keys[i]).id.to_s
      next if !movename || movename == ""
      f.write("\#-------------------------------\r\n")
      f.write(sprintf("[%s]\r\n", movename))
      x = []
      machines[keys[i]].each do |species|
        speciesname = getConstantName(PBSpecies, species) rescue pbGetSpeciesConst(species) rescue nil
        next if !speciesname || speciesname == ""
        x.push(speciesname)
      end
      f.write(x.join(",") + "\r\n")
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
          encentry = (enc[k]) ? enc[k] : [1,5,5]
          species = getConstantName(PBSpecies,encentry[0]) rescue pbGetSpeciesConst(encentry[0])
          if encentry[1]==encentry[2]
            f.write(sprintf("    %s,%d\r\n",species,encentry[1]))
          else
            f.write(sprintf("    %s,%d,%d\r\n",species,encentry[1],encentry[2]))
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
        species = getConstantName(PBSpecies,poke[TrainerData::SPECIES]) rescue pbGetSpeciesConst(poke[TrainerData::SPECIES]) rescue ""
        f.write(sprintf("Pokemon = %s,%d\r\n",species,poke[TrainerData::LEVEL]))
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
  speciesData  = pbLoadSpeciesData
  messages     = Messages.new("Data/messages.dat") rescue nil
  return if !speciesData || !messages
  metrics      = pbLoadSpeciesMetrics
  movesets     = pbLoadMovesetsData
  eggMoves     = pbLoadEggMovesData
  regionaldata = pbLoadRegionalDexes
  numRegions   = regionaldata.length
  pokedata = File.open("PBS/pokemon.txt","wb") rescue nil
  pokedata.write(0xEF.chr)
  pokedata.write(0xBB.chr)
  pokedata.write(0xBF.chr)
  pokedata.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
  for i in 1..(PBSpecies.maxValue rescue PBSpecies.getCount-1 rescue messages.getCount(MessageTypes::Species)-1)
    cname       = getConstantName(PBSpecies,i) rescue next
    speciesname = messages.get(MessageTypes::Species,i)
    kind        = messages.get(MessageTypes::Kinds,i)
    entry       = messages.get(MessageTypes::Entries,i)
    formname    = messages.get(MessageTypes::FormNames,i)
    abilities = speciesData[i][SpeciesData::ABILITIES]
    if abilities.is_a?(Array)
      ability1       = abilities[0]
      ability2       = abilities[1]
    else
      ability1       = abilities
      ability2       = nil
    end
    color            = speciesData[i][SpeciesData::COLOR] || 0
    habitat          = speciesData[i][SpeciesData::HABITAT] || 0
    type1            = speciesData[i][SpeciesData::TYPE1]
    type2            = speciesData[i][SpeciesData::TYPE2] || type1
    if speciesData[i][SpeciesData::BASE_STATS]
      basestats      = speciesData[i][SpeciesData::BASE_STATS].clone
    else
      basestats      = [1,1,1,1,1,1]
    end
    rareness         = speciesData[i][SpeciesData::RARENESS] || 0
    shape            = speciesData[i][SpeciesData::SHAPE] || 0
    gender           = speciesData[i][SpeciesData::GENDER_RATE] || 0
    happiness        = speciesData[i][SpeciesData::HAPPINESS] || 0
    growthrate       = speciesData[i][SpeciesData::GROWTH_RATE] || 0
    stepstohatch     = speciesData[i][SpeciesData::STEPS_TO_HATCH] || 1
    if speciesData[i][SpeciesData::EFFORT_POINTS]
      effort         = speciesData[i][SpeciesData::EFFORT_POINTS].clone
    else
      effort         = [0,0,0,0,0,0]
    end
    compats = speciesData[i][SpeciesData::COMPATIBILITY]
    if compats.is_a?(Array)
      compat1        = compats[0] || 0
      compat2        = compats[1] || compat1
    else
      compat1        = compats || 0
      compat2        = compat1
    end
    height           = speciesData[i][SpeciesData::HEIGHT] || 1
    weight           = speciesData[i][SpeciesData::WEIGHT] || 1
    baseexp          = speciesData[i][SpeciesData::BASE_EXP] || 0
    hiddenAbils = speciesData[i][SpeciesData::HIDDEN_ABILITY]
    if hiddenAbils.is_a?(Array)
      hiddenability1 = hiddenAbils[0]
      hiddenability2 = hiddenAbils[1]
      hiddenability3 = hiddenAbils[2]
      hiddenability4 = hiddenAbils[3]
    else
      hiddenability1 = hiddenAbils
      hiddenability2 = nil
      hiddenability3 = nil
      hiddenability4 = nil
    end
    item1            = speciesData[i][SpeciesData::WILD_ITEM_COMMON]
    item2            = speciesData[i][SpeciesData::WILD_ITEM_UNCOMMON]
    item3            = speciesData[i][SpeciesData::WILD_ITEM_RARE]
    incense          = speciesData[i][SpeciesData::INCENSE]
    pokedata.write("\#-------------------------------\r\n")
    pokedata.write("[#{i}]\r\nName = #{speciesname}\r\n")
    pokedata.write("InternalName = #{cname}\r\n")
    if type1
      pokedata.write("Type1 = #{type1.to_s}\r\n")
    end
    if type2 && type2 != type1
      pokedata.write("Type2 = #{type2.to_s}\r\n")
    end
    pokedata.write("BaseStats = #{basestats[0]},#{basestats[1]},#{basestats[2]},#{basestats[3]},#{basestats[4]},#{basestats[5]}\r\n")
    gendername = getConstantName(PBGenderRates,gender) rescue pbGetGenderConst(gender)
    pokedata.write("GenderRate = #{gendername}\r\n")
    pokedata.write("GrowthRate = " + ["Medium","Erratic","Fluctuating","Parabolic","Fast","Slow"][growthrate]+"\r\n")
    pokedata.write("BaseEXP = #{baseexp}\r\n")
    pokedata.write("EffortPoints = #{effort[0]},#{effort[1]},#{effort[2]},#{effort[3]},#{effort[4]},#{effort[5]}\r\n")
    pokedata.write("Rareness = #{rareness}\r\n")
    pokedata.write("Happiness = #{happiness}\r\n")
    pokedata.write("Abilities = ")
    if ability1
      pokedata.write("#{ability1.to_s}")
      pokedata.write(",") if ability2
    end
    if ability2
      pokedata.write("#{ability2.to_s}")
    end
    pokedata.write("\r\n")
    if hiddenability1 || hiddenability2 || hiddenability3 || hiddenability4
      pokedata.write("HiddenAbility = ")
      needcomma = false
      if hiddenability1
        pokedata.write("#{hiddenability1.to_s}"); needcomma = true
      end
      if hiddenability2
        pokedata.write(",") if needcomma
        pokedata.write("#{hiddenability2.to_s}"); needcomma = true
      end
      if hiddenability3
        pokedata.write(",") if needcomma
        pokedata.write("#{hiddenability3.to_s}"); needcomma = true
      end
      if hiddenability4
        pokedata.write(",") if needcomma
        pokedata.write("#{hiddenability4.to_s}")
      end
      pokedata.write("\r\n")
    end
    if movesets[i] && movesets[i].length>0
      movelist = []
      movesets[i].each_with_index { |m,j| movelist.push([m[0],m[1],j]) }
      movelist.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
      pokedata.write("Moves = ")
      first = true
      movelist.each do |m|
        next if !m
        level = m[0]
        move  = m[1]
        pokedata.write(",") if !first
        pokedata.write(sprintf("%d,%s",level,move.to_s))
        first = false
      end
      pokedata.write("\r\n")
    end
    if eggMoves[i] && eggMoves[i].length>0
      pokedata.write("EggMoves = ")
      first = true
      eggMoves[i].each do |m|
        next if !m
        pokedata.write(",") if !first
        pokedata.write("#{m.to_s}")
        first = false
      end
      pokedata.write("\r\n")
    end
    comp1 = getConstantName(PBEggGroups,compat1) rescue pbGetEggGroupConst(compat1)
    comp2 = getConstantName(PBEggGroups,compat2) rescue pbGetEggGroupConst(compat2)
    if compat1==compat2
      pokedata.write("Compatibility = #{comp1}\r\n")
    else
      pokedata.write("Compatibility = #{comp1},#{comp2}\r\n")
    end
    pokedata.write("StepsToHatch = #{stepstohatch}\r\n")
    pokedata.write("Height = ")
    pokedata.write(sprintf("%.1f",height/10.0)) if height
    pokedata.write("\r\n")
    pokedata.write("Weight = ")
    pokedata.write(sprintf("%.1f",weight/10.0)) if weight
    pokedata.write("\r\n")
    colorname = getConstantName(PBColors,color) rescue pbGetColorConst(color)
    pokedata.write("Color = #{colorname}\r\n")
    pokedata.write("Shape = #{shape}\r\n")
    pokedata.write("Habitat = "+["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain","RoughTerrain","Urban","Rare"][habitat]+"\r\n") if habitat>0
    regionallist = []
    for region in 0...numRegions
      regionallist.push(regionaldata[region][i])
    end
    numb = regionallist.length-1
    while (numb>=0)   # remove every 0 at end of array
      (!regionallist[numb] || regionallist[numb]==0) ? regionallist.pop : break
      numb -= 1
    end
    if !regionallist.empty?
      pokedata.write("RegionalNumbers = "+(regionallist[0] || 0).to_s)
      for numb in 1...regionallist.size
        pokedata.write(","+(regionallist[numb] || 0).to_s)
      end
      pokedata.write("\r\n")
    end
    pokedata.write("Kind = #{kind}\r\n")
    pokedata.write("Pokedex = #{entry}\r\n")
    if formname && formname!=""
      pokedata.write("FormName = #{formname}\r\n")
    end
    if item1
      pokedata.write("WildItemCommon = #{item1.to_s}\r\n")
    end
    if item2
      pokedata.write("WildItemUncommon = #{item2.to_s}\r\n")
    end
    if item3
      pokedata.write("WildItemRare = #{item3.to_s}\r\n")
    end
    if metrics && metrics.length>0
      pokedata.write("BattlerPlayerX = #{metrics[SpeciesData::METRIC_PLAYER_X][i] || 0}\r\n")
      pokedata.write("BattlerPlayerY = #{metrics[SpeciesData::METRIC_PLAYER_Y][i] || 0}\r\n")
      pokedata.write("BattlerEnemyX = #{metrics[SpeciesData::METRIC_ENEMY_X][i] || 0}\r\n")
      pokedata.write("BattlerEnemyY = #{metrics[SpeciesData::METRIC_ENEMY_Y][i] || 0}\r\n")
      pokedata.write("BattlerAltitude = #{metrics[SpeciesData::METRIC_ALTITUDE][i] || 0}\r\n") if metrics[SpeciesData::METRIC_ALTITUDE][i]!=0
      pokedata.write("BattlerShadowX = #{metrics[SpeciesData::METRIC_SHADOW_X][i] || 0}\r\n")
      pokedata.write("BattlerShadowSize = #{metrics[SpeciesData::METRIC_SHADOW_SIZE][i] || 2}\r\n")
    end
    pokedata.write("Evolutions = ")
    count = 0
    for form in pbGetEvolvedFormData(i)
      method      = form[0]
      parameter   = form[1]
      new_species = form[2]
      next if new_species==0
      cnew_species = getConstantName(PBSpecies,new_species) rescue pbGetSpeciesConst(new_species)
      evoname = getConstantName(PBEvolution,method) rescue pbGetEvolutionConst(method)
      next if !cnew_species || cnew_species==""
      pokedata.write(",") if count>0
      pokedata.write(sprintf("%s,%s,",cnew_species,evoname))
      param_type = PBEvolution.getFunction(method, "parameterType")
      has_param = !PBEvolution.hasFunction?(method, "parameterType") || param_type != nil
      if has_param
        if param_type
          if GameData.const_defined?(param_type.to_sym)
            pokedata.write("#{parameter.to_s}")
          else
            cparameter = (getConstantName(param_type, parameter) rescue parameter)
            pokedata.write("#{cparameter}")
          end
        else
          pokedata.write("#{parameter}")
        end
      end
      count += 1
    end
    pokedata.write("\r\n")
    if incense
      pokedata.write("Incense = #{incense.to_s}\r\n")
    end
    if i%20==0
      Graphics.update
      pbSetWindowText(_INTL("Processing species {1}...",i))
    end
  end
  pokedata.close
  Graphics.update
end



#===============================================================================
# Save Pokémon forms data to PBS file
#===============================================================================
def pbSavePokemonFormsData
  speciesData  = pbLoadSpeciesData
  messages     = Messages.new("Data/messages.dat") rescue nil
  return if !speciesData || !messages
  metrics      = pbLoadSpeciesMetrics
  movesets     = pbLoadMovesetsData
  eggMoves     = pbLoadEggMovesData
  pokedata = File.open("PBS/pokemonforms.txt","wb") rescue nil
  pokedata.write(0xEF.chr)
  pokedata.write(0xBB.chr)
  pokedata.write(0xBF.chr)
  pokedata.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
  m1 = (PBSpecies.maxValue+1 rescue PBSpecies.getCount rescue messages.getCount(MessageTypes::Species))
  m2 = (PBSpecies.maxValueF rescue m1)
  for i in m1..m2
    species,form = pbGetSpeciesFromFSpecies(i)
    next if !species || species==0 || !form || form==0
    cname = getConstantName(PBSpecies,species) rescue next
    origkind    = messages.get(MessageTypes::Kinds,species)
    kind        = messages.get(MessageTypes::Kinds,i)
    kind = nil if kind==origkind || kind==""
    origentry   = messages.get(MessageTypes::Entries,species)
    entry       = messages.get(MessageTypes::Entries,i)
    entry = nil if entry==origentry || entry==""
    formname    = messages.get(MessageTypes::FormNames,i)
    origdata = {}
    abilities = speciesData[species][SpeciesData::ABILITIES]
    if abilities.is_a?(Array)
      origdata["ability1"]       = abilities[0]
      origdata["ability2"]       = abilities[1]
    else
      origdata["ability1"]       = abilities
      origdata["ability2"]       = nil
    end
    origdata["color"]            = speciesData[species][SpeciesData::COLOR] || 0
    origdata["habitat"]          = speciesData[species][SpeciesData::HABITAT] || 0
    origdata["type1"]            = speciesData[species][SpeciesData::TYPE1]
    origdata["type2"]            = speciesData[species][SpeciesData::TYPE2] || type1
    if speciesData[species][SpeciesData::BASE_STATS]
      origdata["basestats"]      = speciesData[species][SpeciesData::BASE_STATS].clone
    else
      origdata["basestats"]      = [1,1,1,1,1,1]
    end
    origdata["rareness"]         = speciesData[species][SpeciesData::RARENESS] || 0
    origdata["shape"]            = speciesData[species][SpeciesData::SHAPE] || 0
    origdata["gender"]           = speciesData[species][SpeciesData::GENDER_RATE] || 0
    origdata["happiness"]        = speciesData[species][SpeciesData::HAPPINESS] || 0
    origdata["growthrate"]       = speciesData[species][SpeciesData::GROWTH_RATE] || 0
    origdata["stepstohatch"]     = speciesData[species][SpeciesData::STEPS_TO_HATCH] || 1
    if speciesData[species][SpeciesData::EFFORT_POINTS]
      origdata["effort"]         = speciesData[species][SpeciesData::EFFORT_POINTS].clone
    else
      origdata["effort"]         = [0,0,0,0,0,0]
    end
    compats = speciesData[species][SpeciesData::COMPATIBILITY]
    if compats.is_a?(Array)
      origdata["compat1"]        = compats[0] || 0
      origdata["compat2"]        = compats[1] || origdata["compat1"]
    else
      origdata["compat1"]        = compats || 0
      origdata["compat2"]        = origdata["compat1"]
    end
    origdata["height"]           = speciesData[species][SpeciesData::HEIGHT] || 1
    origdata["weight"]           = speciesData[species][SpeciesData::WEIGHT] || 1
    origdata["baseexp"]          = speciesData[species][SpeciesData::BASE_EXP] || 0
    hiddenAbils = speciesData[species][SpeciesData::HIDDEN_ABILITY]
    if hiddenAbils.is_a?(Array)
      origdata["hiddenability1"] = hiddenAbils[0]
      origdata["hiddenability2"] = hiddenAbils[1]
      origdata["hiddenability3"] = hiddenAbils[2]
      origdata["hiddenability4"] = hiddenAbils[3]
    else
      origdata["hiddenability1"] = hiddenAbils
      origdata["hiddenability2"] = nil
      origdata["hiddenability3"] = nil
      origdata["hiddenability4"] = nil
    end
    origdata["item1"]            = speciesData[species][SpeciesData::WILD_ITEM_COMMON]
    origdata["item2"]            = speciesData[species][SpeciesData::WILD_ITEM_UNCOMMON]
    origdata["item3"]            = speciesData[species][SpeciesData::WILD_ITEM_RARE]
    origdata["incense"]          = speciesData[species][SpeciesData::INCENSE]
    abilities = speciesData[i][SpeciesData::ABILITIES]
    if abilities.is_a?(Array)
      ability1       = abilities[0]
      ability2       = abilities[1]
    else
      ability1       = abilities
      ability2       = nil
    end
    if ability1==origdata["ability1"] && ability2==origdata["ability2"]
      ability1 = ability2 = nil
    end
    color            = speciesData[i][SpeciesData::COLOR] || 0
    color            = nil if color==origdata["color"]
    habitat          = speciesData[i][SpeciesData::HABITAT] || 0
    habitat          = nil if habitat==origdata["habitat"]
    type1            = speciesData[i][SpeciesData::TYPE1]
    type2            = speciesData[i][SpeciesData::TYPE2] || type1
    if type1==origdata["type1"] && type2==origdata["type2"]
      type1 = type2  = nil
    end
    if speciesData[i][SpeciesData::BASE_STATS]
      basestats      = speciesData[i][SpeciesData::BASE_STATS].clone
    else
      basestats      = [1,1,1,1,1,1]
    end
    diff = false
    for k in 0...6
      next if basestats[k]==origdata["basestats"][k]
      diff = true; break
    end
    basestats        = nil if !diff
    rareness         = speciesData[i][SpeciesData::RARENESS] || 0
    rareness         = nil if rareness==origdata["rareness"]
    shape            = speciesData[i][SpeciesData::SHAPE] || 0
    shape            = nil if shape==origdata["shape"]
    gender           = speciesData[i][SpeciesData::GENDER_RATE] || 0
    gender           = nil if gender==origdata["gender"]
    happiness        = speciesData[i][SpeciesData::HAPPINESS] || 0
    happiness        = nil if happiness==origdata["happiness"]
    growthrate       = speciesData[i][SpeciesData::GROWTH_RATE] || 0
    growthrate       = nil if growthrate==origdata["growthrate"]
    stepstohatch     = speciesData[i][SpeciesData::STEPS_TO_HATCH] || 1
    stepstohatch     = nil if stepstohatch==origdata["stepstohatch"]
    if speciesData[i][SpeciesData::EFFORT_POINTS]
      effort         = speciesData[i][SpeciesData::EFFORT_POINTS].clone
    else
      effort         = [0,0,0,0,0,0]
    end
    diff = false
    for k in 0...6
      next if effort[k]==origdata["effort"][k]
      diff = true; break
    end
    effort           = nil if !diff
    compats = speciesData[i][SpeciesData::COMPATIBILITY]
    if compats.is_a?(Array)
      compat1        = compats[0] || 0
      compat2        = compats[1] || compat1
    else
      compat1        = compats || 0
      compat2        = compat1
    end
    if compat1==origdata["compat1"] && compat2==origdata["compat2"]
      compat1 = compat2 = nil
    end
    height           = speciesData[i][SpeciesData::HEIGHT] || 1
    height           = nil if height==origdata["height"]
    weight           = speciesData[i][SpeciesData::WEIGHT] || 1
    weight           = nil if weight==origdata["weight"]
    baseexp          = speciesData[i][SpeciesData::BASE_EXP] || 0
    baseexp          = nil if baseexp==origdata["baseexp"]
    hiddenAbils = speciesData[i][SpeciesData::HIDDEN_ABILITY]
    if hiddenAbils.is_a?(Array)
      hiddenability1 = hiddenAbils[0]
      hiddenability2 = hiddenAbils[1]
      hiddenability3 = hiddenAbils[2]
      hiddenability4 = hiddenAbils[3]
    else
      hiddenability1 = hiddenAbils
      hiddenability2 = nil
      hiddenability3 = nil
      hiddenability4 = nil
    end
    if hiddenability1==origdata["hiddenability1"] &&
       hiddenability2==origdata["hiddenability2"] &&
       hiddenability3==origdata["hiddenability3"] &&
       hiddenability4==origdata["hiddenability4"]
      hiddenability1 = hiddenability2 = hiddenability3 = hiddenability4 = nil
    end
    item1            = speciesData[i][SpeciesData::WILD_ITEM_COMMON]
    item2            = speciesData[i][SpeciesData::WILD_ITEM_UNCOMMON]
    item3            = speciesData[i][SpeciesData::WILD_ITEM_RARE]
    if item1==origdata["item1"] && item2==origdata["item2"] && item3==origdata["item3"]
      item1 = item2 = item3 = nil
    end
    incense          = speciesData[i][SpeciesData::INCENSE]
    incense          = nil if incense==origdata["incense"]
    pokedexform      = speciesData[i][SpeciesData::POKEDEX_FORM] || 0   # No nil check
    megastone        = speciesData[i][SpeciesData::MEGA_STONE]          # No nil check
    megamove         = speciesData[i][SpeciesData::MEGA_MOVE]           # No nil check
    unmega           = speciesData[i][SpeciesData::UNMEGA_FORM] || 0    # No nil check
    megamessage      = speciesData[i][SpeciesData::MEGA_MESSAGE] || 0   # No nil check
    pokedata.write("\#-------------------------------\r\n")
    pokedata.write("[#{cname},#{form}]\r\n")
    pokedata.write("FormName = #{formname}\r\n") if formname && formname!=""
    pokedata.write("PokedexForm = #{pokedexform}\r\n") if pokedexform>0
    if megastone
      pokedata.write("MegaStone = #{megastone.to_s}\r\n")
    end
    if megamove
      pokedata.write("MegaMove = #{megamove.to_s}\r\n")
    end
    pokedata.write("UnmegaForm = #{unmega}\r\n") if unmega>0
    pokedata.write("MegaMessage = #{megamessage}\r\n") if megamessage>0
    if type1
      pokedata.write("Type1 = #{type1.to_s}\r\n")
    end
    if type2 && type2 != type1
      pokedata.write("Type2 = #{type2.to_s}\r\n")
    end
    if basestats!=nil
      pokedata.write("BaseStats = #{basestats[0]},#{basestats[1]},#{basestats[2]},#{basestats[3]},#{basestats[4]},#{basestats[5]}\r\n")
    end
    if gender!=nil
      gendername = getConstantName(PBGenderRates,gender) rescue pbGetGenderConst(gender)
      pokedata.write("GenderRate = #{gendername}\r\n")
    end
    if growthrate!=nil
      pokedata.write("GrowthRate = " + ["Medium","Erratic","Fluctuating","Parabolic","Fast","Slow"][growthrate]+"\r\n")
    end
    if baseexp!=nil
      pokedata.write("BaseEXP = #{baseexp}\r\n")
    end
    if effort!=nil
      pokedata.write("EffortPoints = #{effort[0]},#{effort[1]},#{effort[2]},#{effort[3]},#{effort[4]},#{effort[5]}\r\n")
    end
    if rareness!=nil
      pokedata.write("Rareness = #{rareness}\r\n")
    end
    if happiness!=nil
      pokedata.write("Happiness = #{happiness}\r\n")
    end
    if ability1 || ability2
      pokedata.write("Abilities = ")
      if ability1
        pokedata.write("#{ability1.to_s}")
        pokedata.write(",") if ability2
      end
      if ability2
        pokedata.write("#{ability2.to_s}")
      end
      pokedata.write("\r\n")
    end
    if hiddenability1!=nil
      if hiddenability1 || hiddenability2 || hiddenability3 || hiddenability4
        pokedata.write("HiddenAbility = ")
        needcomma = false
        if hiddenability1
          pokedata.write("#{hiddenability1.to_s}"); needcomma=true
        end
        if hiddenability2
          pokedata.write(",") if needcomma
          pokedata.write("#{hiddenability2.to_s}"); needcomma=true
        end
        if hiddenability3
          pokedata.write(",") if needcomma
          pokedata.write("#{hiddenability3.to_s}"); needcomma=true
        end
        if hiddenability4
          pokedata.write(",") if needcomma
          pokedata.write("#{hiddenability4.to_s}")
        end
        pokedata.write("\r\n")
      end
    end
    origMoveset = []
    movesets[species].each_with_index { |m,j| origMoveset.push([m[0],m[1],j]) }
    origMoveset.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
    moveList = []
    movesets[i].each_with_index { |m,j| moveList.push([m[0],m[1],j]) }
    moveList.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
    movesetDifferent = false
    if origMoveset.length!=moveList.length
      movesetDifferent = true
    else
      for k in 0...moveList.length
        next if origMoveset[k][0]==moveList[k][0] && origMoveset[k][1]==moveList[k][1]
        movesetDifferent = true
        break
      end
    end
    if movesetDifferent
      pokedata.write("Moves = ")
      first = true
      moveList.each do |m|
        next if !m
        level = m[0]
        move  = m[1]
        pokedata.write(",") if !first
        pokedata.write(sprintf("%d,%s",level,move.to_s))
        first = false
      end
      pokedata.write("\r\n")
    end
    origEggMoves = []
    origEggMoves = eggMoves[species].clone if eggMoves[species] && eggMoves[species].length>0
    eggList = []
    eggList = eggMoves[i].clone if eggMoves[i] && eggMoves[i].length>0
    eggMovesDifferent = false
    if origEggMoves.length!=eggList.length
      eggMovesDifferent = true
    else
      for k in 0...eggList.length
        next if origEggMoves[k]==eggList[k]
        eggMovesDifferent = true
        break
      end
    end
    if eggMovesDifferent
      pokedata.write("EggMoves = ")
      first = true
      eggList.each do |m|
        next if !m || m==0
        pokedata.write(",") if !first
        pokedata.write("#{m.to_s}")
        first = false
      end
      pokedata.write("\r\n")
    end
    if compat1!=nil && compat2!=nil
      comp1 = getConstantName(PBEggGroups,compat1) rescue pbGetEggGroupConst(compat1)
      comp2 = getConstantName(PBEggGroups,compat2) rescue pbGetEggGroupConst(compat2)
      if compat1==compat2
        pokedata.write("Compatibility = #{comp1}\r\n")
      else
        pokedata.write("Compatibility = #{comp1},#{comp2}\r\n")
      end
    end
    if stepstohatch!=nil
      pokedata.write("StepsToHatch = #{stepstohatch}\r\n")
    end
    if height!=nil
      pokedata.write("Height = ")
      pokedata.write(sprintf("%.1f",height/10.0))
      pokedata.write("\r\n")
    end
    if weight!=nil
      pokedata.write("Weight = ")
      pokedata.write(sprintf("%.1f",weight/10.0))
      pokedata.write("\r\n")
    end
    if color!=nil
      colorname = getConstantName(PBColors,color) rescue pbGetColorConst(color)
      pokedata.write("Color = #{colorname}\r\n")
    end
    if shape!=nil
      pokedata.write("Shape = #{shape}\r\n")
    end
    if habitat!=nil && habitat>0
      habitat_name = getConstantName(PBHabitats,habitat) rescue pbGetHabitatConst(habitat)
      pokedata.write("Habitat = #{habitat_name}\r\n")
    end
    if kind!=nil
      pokedata.write("Kind = #{kind}\r\n")
    end
    if entry!=nil
      pokedata.write("Pokedex = #{entry}\r\n")
    end
    if item1
      pokedata.write("WildItemCommon = #{item1.to_s}\r\n")
    end
    if item2
      pokedata.write("WildItemUncommon = #{item2.to_s}\r\n")
    end
    if item3
      pokedata.write("WildItemRare = #{item3.to_s}\r\n")
    end
    if metrics && metrics.length>0
      for j in 0...6
        met = ["BattlerPlayerX","BattlerPlayerY","BattlerEnemyX","BattlerEnemyY",
               "BattlerAltitude","BattlerShadowX"][j]
        if metrics[j][i]!=metrics[j][species]
          pokedata.write(met+" = #{metrics[j][i] || 0}\r\n")
        end
      end
      if metrics[SpeciesData::METRIC_SHADOW_SIZE][i]!=metrics[SpeciesData::METRIC_SHADOW_SIZE][species]
        pokedata.write("BattlerShadowSize = #{metrics[SpeciesData::METRIC_SHADOW_SIZE][i] || 2}\r\n")
      end
    end
    origevos = []
    for form in pbGetEvolvedFormData(species)
      method      = form[0]
      parameter   = form[1]
      new_species = form[2]
      next if new_species==0
      cnew_species = getConstantName(PBSpecies,new_species) rescue pbGetSpeciesConst(new_species)
      evoname = getConstantName(PBEvolution,method) rescue pbGetEvolutionConst(method)
      next if !cnew_species || cnew_species==""
      origevos.push([method,parameter,new_species])
    end
    evos = []
    for form in pbGetEvolvedFormData(i)
      method      = form[0]
      parameter   = form[1]
      new_species = form[2]
      next if new_species==0
      cnew_species = getConstantName(PBSpecies,new_species) rescue pbGetSpeciesConst(new_species)
      evoname = getConstantName(PBEvolution,method) rescue pbGetEvolutionConst(method)
      next if !cnew_species || cnew_species==""
      evos.push([method,parameter,new_species])
    end
    diff = false
    if evos.length!=origevos.length
      diff = true
    else
      for k in 0...evos.length
        if evos[k][0]!=origevos[k][0] ||
           evos[k][1]!=origevos[k][1] ||
           evos[k][2]!=origevos[k][2]
          diff = true; break
        end
      end
    end
    if diff
      pokedata.write("Evolutions = ")
      for k in 0...evos.length
        method      = form[0]
        parameter   = form[1]
        new_species = form[2]
        cnew_species = getConstantName(PBSpecies,new_species) rescue pbGetSpeciesConst(new_species)
        evoname = getConstantName(PBEvolution,method) rescue pbGetEvolutionConst(method)
        next if !cnew_species || cnew_species==""
        pokedata.write(sprintf("%s,%s,",cnew_species,evoname))
        param_type = PBEvolution.getFunction(method, "parameterType")
        has_param = !PBEvolution.hasFunction?(method, "parameterType") || param_type != nil
        if has_param
          if param_type
            if GameData.const_defined?(param_type.to_sym)
              pokedata.write("#{parameter.to_s}")
            else
              cparameter = (getConstantName(param_type, parameter) rescue parameter)
              pokedata.write("#{cparameter}")
            end
          else
            pokedata.write("#{parameter}")
          end
        end
        pokedata.write(",") if k<evos.length-1
      end
      pokedata.write("\r\n")
    end
    if incense
      pokedata.write("Incense = #{incense.to_s}\r\n")
    end
    if i%20==0
      Graphics.update
      pbSetWindowText(_INTL("Processing species {1}...",i))
    end
  end
  pokedata.close
  Graphics.update
end



#===============================================================================
# Save Shadow move data to PBS file
#===============================================================================
def pbSaveShadowMoves
  shadow_movesets = pbLoadShadowMovesets
  File.open("PBS/shadowmoves.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 0...shadow_movesets.length
      moveset = shadow_movesets[i]
      next if !moveset || moveset.length==0
      constname = (getConstantName(PBSpecies,i) rescue pbGetSpeciesConst(i) rescue nil)
      next if !constname
      f.write(sprintf("%s = ",constname))
      movenames = []
      for m in moveset
        movenames.push(GameData::Move.get(m).id.to_s)
      end
      f.write(sprintf("%s\r\n",movenames.compact.join(",")))
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
  c1 = (species[pkmn.species]) ? species[pkmn.species] :
     (species[pkmn.species] = (getConstantName(PBSpecies,pkmn.species) rescue pbGetSpeciesConst(pkmn.species)))
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
  c4 = (moves[pkmn.move1]) ? moves[pkmn.move1] : (moves[pkmn.move1] = GameData::Move.get(pkmn.move1).id_to_s)
  c5 = (moves[pkmn.move2]) ? moves[pkmn.move2] : (moves[pkmn.move2] = GameData::Move.get(pkmn.move2).id_to_s)
  c6 = (moves[pkmn.move3]) ? moves[pkmn.move3] : (moves[pkmn.move3] = GameData::Move.get(pkmn.move3).id_to_s)
  c7 = (moves[pkmn.move4]) ? moves[pkmn.move4] : (moves[pkmn.move4] = GameData::Move.get(pkmn.move4).id_to_s)
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
  pbSaveMachines;         Graphics.update
  pbSaveEncounterData;    Graphics.update
  pbSaveTrainerTypes;     Graphics.update
  pbSaveTrainerBattles;   Graphics.update
  pbSaveTownMap;          Graphics.update
  pbSavePhoneData;        Graphics.update
  pbSavePokemonData;      Graphics.update
  pbSavePokemonFormsData; Graphics.update
  pbSaveShadowMoves;      Graphics.update
end
