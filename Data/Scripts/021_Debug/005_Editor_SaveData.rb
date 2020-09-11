#===============================================================================
# Save type data to PBS file
#===============================================================================
def pbSaveTypes
  return if (PBTypes.maxValue rescue 0)==0
  File.open("PBS/types.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for i in 0..(PBTypes.maxValue rescue 25)
      name = PBTypes.getName(i) rescue nil
      next if !name || name==""
      f.write("\#-------------------------------\r\n")
      constname = getConstantName(PBTypes,i) rescue pbGetTypeConst(i)
      f.write(sprintf("[%d]\r\n",i))
      f.write(sprintf("Name = %s\r\n",name))
      f.write(sprintf("InternalName = %s\r\n",constname))
      if (PBTypes.isPseudoType?(i) rescue isConst?(i,PBTypes,QMARKS))
        f.write("IsPseudoType = true\r\n")
      end
      if (PBTypes.isSpecialType?(i) rescue pbIsOldSpecialType?(i))
        f.write("IsSpecialType = true\r\n")
      end
      weak   = []
      resist = []
      immune = []
      for j in 0..(PBTypes.maxValue rescue 25)
        cname = getConstantName(PBTypes,j) rescue pbGetTypeConst(j)
        next if !cname || cname==""
        case PBTypes.getEffectiveness(j,i)
        when PBTypeEffectiveness::SUPER_EFFECTIVE_ONE; weak.push(cname)
        when PBTypeEffectiveness::NOT_EFFECTIVE_ONE;   resist.push(cname)
        when PBTypeEffectiveness::INEFFECTIVE;         immune.push(cname)
        end
      end
      f.write("Weaknesses = "+weak.join(",")+"\r\n") if weak.length>0
      f.write("Resistances = "+resist.join(",")+"\r\n") if resist.length>0
      f.write("Immunities = "+immune.join(",")+"\r\n") if immune.length>0
    end
  }
end



#===============================================================================
# Save ability data to PBS file
#===============================================================================
def pbSaveAbilities
  File.open("PBS/abilities.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 1..(PBAbilities.maxValue rescue PBAbilities.getCount-1 rescue pbGetMessageCount(MessageTypes::Abilities)-1)
      abilname = getConstantName(PBAbilities,i) rescue pbGetAbilityConst(i)
      next if !abilname || abilname==""
      name = pbGetMessage(MessageTypes::Abilities,i)
      next if !name || name==""
      f.write(sprintf("%d,%s,%s,%s\r\n",i,csvQuote(abilname),csvQuote(name),
        csvQuoteAlways(pbGetMessage(MessageTypes::AbilityDescs,i))))
    end
  }
end



#===============================================================================
# Save move data to PBS file
#===============================================================================
def pbSaveMoveData
  movesData = pbLoadMovesData
  return if !movesData
  File.open("PBS/moves.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    currentType = -1
    for i in 1..(PBMoves.maxValue rescue PBMoves.getCount-1 rescue pbGetMessageCount(MessageTypes::Moves)-1)
      moveData = movesData[i]
      next if !moveData   # No move with that ID defined
      if currentType!=moveData[MOVE_TYPE]
        currentType = moveData[MOVE_TYPE]
        f.write("\#-------------------------------\r\n")
      end
      f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s",
         moveData[MOVE_ID],
         moveData[MOVE_INTERNAL_NAME],
         csvQuote(moveData[MOVE_NAME]),
         csvQuote(moveData[MOVE_FUNCTION_CODE]),
         moveData[MOVE_BASE_DAMAGE],
         (getConstantName(PBTypes,moveData[MOVE_TYPE]) rescue pbGetTypeConst(moveData[MOVE_TYPE]) rescue ""),
         ["Physical","Special","Status"][moveData[MOVE_CATEGORY]],
         moveData[MOVE_ACCURACY],
         moveData[MOVE_TOTAL_PP],
         moveData[MOVE_EFFECT_CHANCE],
         (getConstantName(PBTargets,moveData[MOVE_TARGET]) rescue sprintf("%02X",moveData[MOVE_TARGET])),
         moveData[MOVE_PRIORITY],
         csvQuote(moveData[MOVE_FLAGS]),
         csvQuoteAlways(moveData[MOVE_DESCRIPTION])
      ))
      f.write("\r\n")
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
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
def pbSerializeMetadata(metadata,mapinfos)
  save_data(metadata,"Data/metadata.dat")
  File.open("PBS/metadata.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for i in 0...metadata.length
      next if !metadata[i]
      f.write("\#-------------------------------\r\n")
      f.write(sprintf("[%03d]\r\n",i))
      if i==0
        types = PokemonMetadata::GlobalTypes
      else
        if mapinfos && mapinfos[i]
          f.write(sprintf("# %s\r\n",mapinfos[i].name))
        end
        types = PokemonMetadata::NonGlobalTypes
      end
      for key in types.keys
        schema = types[key]
        record = metadata[i][schema[0]]
        next if record==nil
        f.write(sprintf("%s = ",key))
        pbWriteCsvRecord(record,f,schema)
        f.write("\r\n")
      end
    end
  }
end

def pbSaveMetadata
  data = load_data("Data/metadata.dat") rescue nil
  return if !data
  pbSerializeMetadata(data,pbLoadRxData("Data/MapInfos"))
end



#===============================================================================
# Save item data to PBS file
#===============================================================================
def pbSaveItems
  itemData = pbLoadItemsData rescue nil
  return if !itemData || itemData.length==0
  File.open("PBS/items.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    curpocket = 0
    for i in 0...itemData.length
      next if !itemData[i]
      data = itemData[i]
      cname = getConstantName(PBItems,i) rescue sprintf("ITEM%03d",i)
      next if !cname || cname=="" || data[0]==0
      if curpocket!=data[ITEM_POCKET]
        curpocket = data[ITEM_POCKET]
        f.write("\#-------------------------------\r\n")
      end
      machine = ""
      if data[ITEM_MACHINE]>0
        machine = getConstantName(PBMoves,data[ITEM_MACHINE]) rescue pbGetMoveConst(data[ITEM_MACHINE]) rescue ""
      end
      f.write(sprintf("%d,%s,%s,%s,%d,%d,%s,%d,%d,%d,%s",
         data[ITEM_ID],csvQuote(cname),csvQuote(data[ITEM_NAME]),
         csvQuote(data[ITEM_PLURAL]),data[ITEM_POCKET],data[ITEM_PRICE],
         csvQuoteAlways(data[ITEM_DESCRIPTION]),data[ITEM_FIELD_USE],
         data[ITEM_BATTLE_USE],data[ITEM_TYPE],csvQuote(machine)))
      f.write("\r\n")
    end
  }
end



#===============================================================================
# Save berry plant data to PBS file
#===============================================================================
def pbSaveBerryPlants
  berryPlantData = load_data("Data/berry_plants.dat")
  return if !berryPlantData || berryPlantData.length==0
  File.open("PBS/berryplants.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 0...berryPlantData.length
      next if !berryPlantData[i]
      data = berryPlantData[i]
      cname = getConstantName(PBItems,i) rescue sprintf("ITEM%03d",i)
      next if !cname || cname=="" || i==0
      f.write(sprintf("%s = %d,%d,%d,%d",
         csvQuote(cname),data[0],data[1],data[2],data[3]))
      f.write("\r\n")
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
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
  File.open("PBS/tm.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for i in 1...machines.length
      Graphics.update if i%50==0
      Win32API.SetWindowText(_INTL("Writing move {1}/{2}",i,machines.length)) if i%20==0
      next if !machines[i]
      movename = getConstantName(PBMoves,i) rescue pbGetMoveConst(i) rescue nil
      next if !movename || movename==""
      f.write("\#-------------------------------\r\n")
      f.write(sprintf("[%s]\r\n",movename))
      x = []
      for j in 0...machines[i].length
        speciesname = getConstantName(PBSpecies,machines[i][j]) rescue pbGetSpeciesConst(machines[i][j]) rescue nil
        next if !speciesname || speciesname==""
        x.push(speciesname)
      end
      f.write(x.join(",")+"\r\n")
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    sortedkeys = encdata.keys.sort { |a,b| a<=>b }
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
  data = pbLoadTrainerTypesData
  return if !data
  File.open("PBS/trainertypes.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 0...data.length
      record = data[i]
      next if !record
      dataline = sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s,%s",
         i,record[1],record[2],
         record[3],
         record[4] ? record[4] : "",
         record[5] ? record[5] : "",
         record[6] ? record[6] : "",
         record[7] ? ["Male","Female","Mixed"][record[7]] : "Mixed",
         (record[8]!=record[3]) ? record[8] : "",
         record[9] ? record[9] : "")
      f.write(dataline)
      f.write("\r\n")
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for trainer in data
      trtypename = getConstantName(PBTrainers,trainer[0]) rescue pbGetTrainerConst(trainer[0]) rescue nil
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
          itemname = getConstantName(PBItems,trainer[2][i]) rescue pbGetItemConst(trainer[2][i]) rescue nil
          next if !itemname
          itemstring.concat(",") if i>0
          itemstring.concat(itemname)
        end
        f.write(sprintf("Items = %s\r\n",itemstring)) if itemstring!=""
      end
      # Lose texts
      if trainer[5] && trainer[5]!=""
        f.write(sprintf("LoseText = %s\r\n",csvQuoteAlways(trainer[5])))
      end
      # Pokémon
      for poke in trainer[3]
        species = getConstantName(PBSpecies,poke[TPSPECIES]) rescue pbGetSpeciesConst(poke[TPSPECIES]) rescue ""
        f.write(sprintf("Pokemon = %s,%d\r\n",species,poke[TPLEVEL]))
        if poke[TPNAME] && poke[TPNAME]!=""
          f.write(sprintf("    Name = %s\r\n",poke[TPNAME]))
        end
        if poke[TPFORM]
          f.write(sprintf("    Form = %d\r\n",poke[TPFORM]))
        end
        if poke[TPGENDER]
          f.write(sprintf("    Gender = %s\r\n",(poke[TPGENDER]==1) ? "female" : "male"))
        end
        if poke[TPSHINY]
          f.write("    Shiny = yes\r\n")
        end
        if poke[TPSHADOW]
          f.write("    Shadow = yes\r\n")
        end
        if poke[TPMOVES] && poke[TPMOVES].length>0
          movestring = ""
          for i in 0...poke[TPMOVES].length
            movename = getConstantName(PBMoves,poke[TPMOVES][i]) rescue pbGetMoveConst(poke[TPMOVES][i]) rescue nil
            next if !movename
            movestring.concat(",") if i>0
            movestring.concat(movename)
          end
          f.write(sprintf("    Moves = %s\r\n",movestring)) if movestring!=""
        end
        if poke[TPABILITY]
          f.write(sprintf("    Ability = %d\r\n",poke[TPABILITY]))
        end
        if poke[TPITEM] && poke[TPITEM]>0
          item = getConstantName(PBItems,poke[TPITEM]) rescue pbGetItemConst(poke[TPITEM]) rescue nil
          f.write(sprintf("    Item = %s\r\n",item)) if item
        end
        if poke[TPNATURE]
          nature = getConstantName(PBNatures,poke[TPNATURE]) rescue nil
          f.write(sprintf("    Nature = %s\r\n",nature)) if nature
        end
        if poke[TPIV] && poke[TPIV].length>0
          f.write(sprintf("    IV = %d",poke[TPIV][0]))
          if poke[TPIV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPEV] && poke[TPEV].length>0
          f.write(sprintf("    EV = %d",poke[TPEV][0]))
          if poke[TPEV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPHAPPINESS]
          f.write(sprintf("    Happiness = %d\r\n",poke[TPHAPPINESS]))
        end
        if poke[TPBALL]
          f.write(sprintf("    Ball = %d\r\n",poke[TPBALL]))
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for i in 0...mapdata.length
      map = mapdata[i]
      return if !map
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
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
  pokedata.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
  pokedata.write("\r\n")
  for i in 1..(PBSpecies.maxValue rescue PBSpecies.getCount-1 rescue messages.getCount(MessageTypes::Species)-1)
    cname       = getConstantName(PBSpecies,i) rescue next
    speciesname = messages.get(MessageTypes::Species,i)
    kind        = messages.get(MessageTypes::Kinds,i)
    entry       = messages.get(MessageTypes::Entries,i)
    formname    = messages.get(MessageTypes::FormNames,i)
    abilities = speciesData[i][SpeciesAbilities]
    if abilities.is_a?(Array)
      ability1       = abilities[0] || 0
      ability2       = abilities[1] || 0
    else
      ability1       = abilities || 0
      ability2       = 0
    end
    color            = speciesData[i][SpeciesColor] || 0
    habitat          = speciesData[i][SpeciesHabitat] || 0
    type1            = speciesData[i][SpeciesType1] || 0
    type2            = speciesData[i][SpeciesType2] || type1
    if speciesData[i][SpeciesBaseStats]
      basestats      = speciesData[i][SpeciesBaseStats].clone
    else
      basestats      = [1,1,1,1,1,1]
    end
    rareness         = speciesData[i][SpeciesRareness] || 0
    shape            = speciesData[i][SpeciesShape] || 0
    gender           = speciesData[i][SpeciesGenderRate] || 0
    happiness        = speciesData[i][SpeciesHappiness] || 0
    growthrate       = speciesData[i][SpeciesGrowthRate] || 0
    stepstohatch     = speciesData[i][SpeciesStepsToHatch] || 1
    if speciesData[i][SpeciesEffortPoints]
      effort         = speciesData[i][SpeciesEffortPoints].clone
    else
      effort         = [0,0,0,0,0,0]
    end
    compats = speciesData[i][SpeciesCompatibility]
    if compats.is_a?(Array)
      compat1        = compats[0] || 0
      compat2        = compats[1] || compat1
    else
      compat1        = compats || 0
      compat2        = compat1
    end
    height           = speciesData[i][SpeciesHeight] || 1
    weight           = speciesData[i][SpeciesWeight] || 1
    baseexp          = speciesData[i][SpeciesBaseExp] || 0
    hiddenAbils = speciesData[i][SpeciesHiddenAbility]
    if hiddenAbils.is_a?(Array)
      hiddenability1 = hiddenAbils[0] || 0
      hiddenability2 = hiddenAbils[1] || 0
      hiddenability3 = hiddenAbils[2] || 0
      hiddenability4 = hiddenAbils[3] || 0
    else
      hiddenability1 = hiddenAbils || 0
      hiddenability2 = 0
      hiddenability3 = 0
      hiddenability4 = 0
    end
    item1            = speciesData[i][SpeciesWildItemCommon] || 0
    item2            = speciesData[i][SpeciesWildItemUncommon] || 0
    item3            = speciesData[i][SpeciesWildItemRare] || 0
    incense          = speciesData[i][SpeciesIncense] || 0
    pokedata.write("\#-------------------------------\r\n")
    pokedata.write("[#{i}]\r\nName = #{speciesname}\r\n")
    pokedata.write("InternalName = #{cname}\r\n")
    ctype1 = getConstantName(PBTypes,type1) rescue pbGetTypeConst(type1) || pbGetTypeConst(0) || "NORMAL"
    pokedata.write("Type1 = #{ctype1}\r\n")
    if type1!=type2
      ctype2 = getConstantName(PBTypes,type2) rescue pbGetTypeConst(type2) || pbGetTypeConst(0) || "NORMAL"
      pokedata.write("Type2 = #{ctype2}\r\n")
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
    if ability1!=0
      cability1 = getConstantName(PBAbilities,ability1) rescue pbGetAbilityConst(ability1)
      pokedata.write("#{cability1}")
      pokedata.write(",") if ability2!=0
    end
    if ability2!=0
      cability2 = getConstantName(PBAbilities,ability2) rescue pbGetAbilityConst(ability2)
      pokedata.write("#{cability2}")
    end
    pokedata.write("\r\n")
    if hiddenability1>0 || hiddenability2>0 || hiddenability3>0 || hiddenability4>0
      pokedata.write("HiddenAbility = ")
      needcomma = false
      if hiddenability1>0
        cabilityh = getConstantName(PBAbilities,hiddenability1) rescue pbGetAbilityConst(hiddenability1)
        pokedata.write("#{cabilityh}"); needcomma = true
      end
      if hiddenability2>0
        pokedata.write(",") if needcomma
        cabilityh = getConstantName(PBAbilities,hiddenability2) rescue pbGetAbilityConst(hiddenability2)
        pokedata.write("#{cabilityh}"); needcomma = true
      end
      if hiddenability3>0
        pokedata.write(",") if needcomma
        cabilityh = getConstantName(PBAbilities,hiddenability3) rescue pbGetAbilityConst(hiddenability3)
        pokedata.write("#{cabilityh}"); needcomma = true
      end
      if hiddenability4>0
        pokedata.write(",") if needcomma
        cabilityh = getConstantName(PBAbilities,hiddenability4) rescue pbGetAbilityConst(hiddenability4)
        pokedata.write("#{cabilityh}")
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
        cmove = getConstantName(PBMoves,move) rescue pbGetMoveConst(move)
        pokedata.write(sprintf("%d,%s",level,cmove))
        first = false
      end
      pokedata.write("\r\n")
    end
    if eggMoves[i] && eggMoves[i].length>0
      pokedata.write("EggMoves = ")
      first = true
      eggMoves[i].each do |m|
        next if !m || m==0
        pokedata.write(",") if !first
        cmove = getConstantName(PBMoves,m) rescue pbGetMoveConst(m)
        pokedata.write("#{cmove}")
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
    if item1>0
      citem1 = getConstantName(PBItems,item1) rescue pbGetItemConst(item1)
      pokedata.write("WildItemCommon = #{citem1}\r\n")
    end
    if item2>0
      citem2 = getConstantName(PBItems,item2) rescue pbGetItemConst(item2)
      pokedata.write("WildItemUncommon = #{citem2}\r\n")
    end
    if item3>0
      citem3 = getConstantName(PBItems,item3) rescue pbGetItemConst(item3)
      pokedata.write("WildItemRare = #{citem3}\r\n")
    end
    if metrics && metrics.length>0
      pokedata.write("BattlerPlayerX = #{metrics[MetricBattlerPlayerX][i] || 0}\r\n")
      pokedata.write("BattlerPlayerY = #{metrics[MetricBattlerPlayerY][i] || 0}\r\n")
      pokedata.write("BattlerEnemyX = #{metrics[MetricBattlerEnemyX][i] || 0}\r\n")
      pokedata.write("BattlerEnemyY = #{metrics[MetricBattlerEnemyY][i] || 0}\r\n")
      pokedata.write("BattlerAltitude = #{metrics[MetricBattlerAltitude][i] || 0}\r\n") if metrics[MetricBattlerAltitude][i]!=0
      pokedata.write("BattlerShadowX = #{metrics[MetricBattlerShadowX][i] || 0}\r\n")
      pokedata.write("BattlerShadowSize = #{metrics[MetricBattlerShadowSize][i] || 2}\r\n")
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
      if param_type
        cparameter = getConstantName(param_type,parameter) rescue ""
        pokedata.write("#{cparameter}")
      else
        pokedata.write("#{parameter}")
      end
      count += 1
    end
    pokedata.write("\r\n")
    if incense>0
      initem = getConstantName(PBItems,incense) rescue pbGetItemConst(incense)
      pokedata.write("Incense = #{initem}\r\n")
    end
    if i%20==0
      Graphics.update
      Win32API.SetWindowText(_INTL("Processing species {1}...",i))
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
  pokedata.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
  pokedata.write("\r\n")
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
    abilities = speciesData[species][SpeciesAbilities]
    if abilities.is_a?(Array)
      origdata["ability1"]       = abilities[0] || 0
      origdata["ability2"]       = abilities[1] || 0
    else
      origdata["ability1"]       = abilities || 0
      origdata["ability2"]       = 0
    end
    origdata["color"]            = speciesData[species][SpeciesColor] || 0
    origdata["habitat"]          = speciesData[species][SpeciesHabitat] || 0
    origdata["type1"]            = speciesData[species][SpeciesType1] || 0
    origdata["type2"]            = speciesData[species][SpeciesType2] || type1
    if speciesData[species][SpeciesBaseStats]
      origdata["basestats"]      = speciesData[species][SpeciesBaseStats].clone
    else
      origdata["basestats"]      = [1,1,1,1,1,1]
    end
    origdata["rareness"]         = speciesData[species][SpeciesRareness] || 0
    origdata["shape"]            = speciesData[species][SpeciesShape] || 0
    origdata["gender"]           = speciesData[species][SpeciesGenderRate] || 0
    origdata["happiness"]        = speciesData[species][SpeciesHappiness] || 0
    origdata["growthrate"]       = speciesData[species][SpeciesGrowthRate] || 0
    origdata["stepstohatch"]     = speciesData[species][SpeciesStepsToHatch] || 1
    if speciesData[species][SpeciesEffortPoints]
      origdata["effort"]         = speciesData[species][SpeciesEffortPoints].clone
    else
      origdata["effort"]         = [0,0,0,0,0,0]
    end
    compats = speciesData[species][SpeciesCompatibility]
    if compats.is_a?(Array)
      origdata["compat1"]        = compats[0] || 0
      origdata["compat2"]        = compats[1] || origdata["compat1"]
    else
      origdata["compat1"]        = compats || 0
      origdata["compat2"]        = origdata["compat1"]
    end
    origdata["height"]           = speciesData[species][SpeciesHeight] || 1
    origdata["weight"]           = speciesData[species][SpeciesWeight] || 1
    origdata["baseexp"]          = speciesData[species][SpeciesBaseExp] || 0
    hiddenAbils = speciesData[species][SpeciesHiddenAbility]
    if hiddenAbils.is_a?(Array)
      origdata["hiddenability1"] = hiddenAbils[0] || 0
      origdata["hiddenability2"] = hiddenAbils[1] || 0
      origdata["hiddenability3"] = hiddenAbils[2] || 0
      origdata["hiddenability4"] = hiddenAbils[3] || 0
    else
      origdata["hiddenability1"] = hiddenAbils || 0
      origdata["hiddenability2"] = 0
      origdata["hiddenability3"] = 0
      origdata["hiddenability4"] = 0
    end
    origdata["item1"]            = speciesData[species][SpeciesWildItemCommon] || 0
    origdata["item2"]            = speciesData[species][SpeciesWildItemUncommon] || 0
    origdata["item3"]            = speciesData[species][SpeciesWildItemRare] || 0
    origdata["incense"]          = speciesData[species][SpeciesIncense] || 0
    abilities = speciesData[i][SpeciesAbilities]
    if abilities.is_a?(Array)
      ability1       = abilities[0] || 0
      ability2       = abilities[1] || 0
    else
      ability1       = abilities || 0
      ability2       = 0
    end
    if ability1==origdata["ability1"] && ability2==origdata["ability2"]
      ability1 = ability2 = nil
    end
    color            = speciesData[i][SpeciesColor] || 0
    color            = nil if color==origdata["color"]
    habitat          = speciesData[i][SpeciesHabitat] || 0
    habitat          = nil if habitat==origdata["habitat"]
    type1            = speciesData[i][SpeciesType1] || 0
    type2            = speciesData[i][SpeciesType2] || type1
    if type1==origdata["type1"] && type2==origdata["type2"]
      type1 = type2  = nil
    end
    if speciesData[i][SpeciesBaseStats]
      basestats      = speciesData[i][SpeciesBaseStats].clone
    else
      basestats      = [1,1,1,1,1,1]
    end
    diff = false
    for k in 0...6
      next if basestats[k]==origdata["basestats"][k]
      diff = true; break
    end
    basestats        = nil if !diff
    rareness         = speciesData[i][SpeciesRareness] || 0
    rareness         = nil if rareness==origdata["rareness"]
    shape            = speciesData[i][SpeciesShape] || 0
    shape            = nil if shape==origdata["shape"]
    gender           = speciesData[i][SpeciesGenderRate] || 0
    gender           = nil if gender==origdata["gender"]
    happiness        = speciesData[i][SpeciesHappiness] || 0
    happiness        = nil if happiness==origdata["happiness"]
    growthrate       = speciesData[i][SpeciesGrowthRate] || 0
    growthrate       = nil if growthrate==origdata["growthrate"]
    stepstohatch     = speciesData[i][SpeciesStepsToHatch] || 1
    stepstohatch     = nil if stepstohatch==origdata["stepstohatch"]
    if speciesData[i][SpeciesEffortPoints]
      effort         = speciesData[i][SpeciesEffortPoints].clone
    else
      effort         = [0,0,0,0,0,0]
    end
    diff = false
    for k in 0...6
      next if effort[k]==origdata["effort"][k]
      diff = true; break
    end
    effort           = nil if !diff
    compats = speciesData[i][SpeciesCompatibility]
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
    height           = speciesData[i][SpeciesHeight] || 1
    height           = nil if height==origdata["height"]
    weight           = speciesData[i][SpeciesWeight] || 1
    weight           = nil if weight==origdata["weight"]
    baseexp          = speciesData[i][SpeciesBaseExp] || 0
    baseexp          = nil if baseexp==origdata["baseexp"]
    hiddenAbils = speciesData[i][SpeciesHiddenAbility]
    if hiddenAbils.is_a?(Array)
      hiddenability1 = hiddenAbils[0] || 0
      hiddenability2 = hiddenAbils[1] || 0
      hiddenability3 = hiddenAbils[2] || 0
      hiddenability4 = hiddenAbils[3] || 0
    else
      hiddenability1 = hiddenAbils || 0
      hiddenability2 = 0
      hiddenability3 = 0
      hiddenability4 = 0
    end
    if hiddenability1==origdata["hiddenability1"] &&
       hiddenability2==origdata["hiddenability2"] &&
       hiddenability3==origdata["hiddenability3"] &&
       hiddenability4==origdata["hiddenability4"]
      hiddenability1 = hiddenability2 = hiddenability3 = hiddenability4 = nil
    end
    item1            = speciesData[i][SpeciesWildItemCommon] || 0
    item2            = speciesData[i][SpeciesWildItemUncommon] || 0
    item3            = speciesData[i][SpeciesWildItemRare] || 0
    if item1==origdata["item1"] && item2==origdata["item2"] && item3==origdata["item3"]
      item1 = item2 = item3 = nil
    end
    incense          = speciesData[i][SpeciesIncense] || 0
    incense          = nil if incense==origdata["incense"]
    pokedexform      = speciesData[i][SpeciesPokedexForm] || 0   # No nil check
    megastone        = speciesData[i][SpeciesMegaStone] || 0     # No nil check
    megamove         = speciesData[i][SpeciesMegaMove] || 0      # No nil check
    unmega           = speciesData[i][SpeciesUnmegaForm] || 0    # No nil check
    megamessage      = speciesData[i][SpeciesMegaMessage] || 0   # No nil check
    pokedata.write("\#-------------------------------\r\n")
    pokedata.write("[#{cname},#{form}]\r\n")
    pokedata.write("FormName = #{formname}\r\n") if formname && formname!=""
    pokedata.write("PokedexForm = #{pokedexform}\r\n") if pokedexform>0
    if megastone>0
      citem = getConstantName(PBItems,megastone) rescue pbGetItemConst(megastone)
      pokedata.write("MegaStone = #{citem}\r\n")
    end
    if megamove>0
      cmove = getConstantName(PBMoves,megamove) rescue pbGetMoveConst(megamove)
      pokedata.write("MegaMove = #{cmove}\r\n")
    end
    pokedata.write("UnmegaForm = #{unmega}\r\n") if unmega>0
    pokedata.write("MegaMessage = #{megamessage}\r\n") if megamessage>0
    if type1!=nil && type2!=nil
      ctype1 = getConstantName(PBTypes,type1) rescue pbGetTypeConst(type1) || pbGetTypeConst(0) || "NORMAL"
      pokedata.write("Type1 = #{ctype1}\r\n")
      if type1!=type2
        ctype2 = getConstantName(PBTypes,type2) rescue pbGetTypeConst(type2) || pbGetTypeConst(0) || "NORMAL"
        pokedata.write("Type2 = #{ctype2}\r\n")
      end
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
    if ability1!=nil && ability2!=nil
      pokedata.write("Abilities = ")
      if ability1!=0
        cability1 = getConstantName(PBAbilities,ability1) rescue pbGetAbilityConst(ability1)
        pokedata.write("#{cability1}")
        pokedata.write(",") if ability2!=0
      end
      if ability2!=0
        cability2 = getConstantName(PBAbilities,ability2) rescue pbGetAbilityConst(ability2)
        pokedata.write("#{cability2}")
      end
      pokedata.write("\r\n")
    end
    if hiddenability1!=nil
      if hiddenability1>0 || hiddenability2>0 || hiddenability3>0 || hiddenability4>0
        pokedata.write("HiddenAbility = ")
        needcomma = false
        if hiddenability1>0
          cabilityh = getConstantName(PBAbilities,hiddenability1) rescue pbGetAbilityConst(hiddenability1)
          pokedata.write("#{cabilityh}"); needcomma=true
        end
        if hiddenability2>0
          pokedata.write(",") if needcomma
          cabilityh = getConstantName(PBAbilities,hiddenability2) rescue pbGetAbilityConst(hiddenability2)
          pokedata.write("#{cabilityh}"); needcomma=true
        end
        if hiddenability3>0
          pokedata.write(",") if needcomma
          cabilityh = getConstantName(PBAbilities,hiddenability3) rescue pbGetAbilityConst(hiddenability3)
          pokedata.write("#{cabilityh}"); needcomma=true
        end
        if hiddenability4>0
          pokedata.write(",") if needcomma
          cabilityh = getConstantName(PBAbilities,hiddenability4) rescue pbGetAbilityConst(hiddenability4)
          pokedata.write("#{cabilityh}")
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
        cmove = getConstantName(PBMoves,move) rescue pbGetMoveConst(move)
        pokedata.write(sprintf("%d,%s",level,cmove))
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
        cmove = getConstantName(PBMoves,m) rescue pbGetMoveConst(m)
        pokedata.write("#{cmove}")
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
    if item1!=nil && item2!=nil && item3!=nil
      if item1>0
        citem1 = getConstantName(PBItems,item1) rescue pbGetItemConst(item1)
        pokedata.write("WildItemCommon = #{citem1}\r\n")
      end
      if item2>0
        citem2 = getConstantName(PBItems,item2) rescue pbGetItemConst(item2)
        pokedata.write("WildItemUncommon = #{citem2}\r\n")
      end
      if item3>0
        citem3 = getConstantName(PBItems,item3) rescue pbGetItemConst(item3)
        pokedata.write("WildItemRare = #{citem3}\r\n")
      end
    end
    if metrics && metrics.length>0
      for j in 0...6
        met = ["BattlerPlayerX","BattlerPlayerY","BattlerEnemyX","BattlerEnemyY",
               "BattlerAltitude","BattlerShadowX"][j]
        if metrics[j][i]!=metrics[j][species]
          pokedata.write(met+" = #{metrics[j][i] || 0}\r\n")
        end
      end
      if metrics[MetricBattlerShadowSize][i]!=metrics[MetricBattlerShadowSize][species]
        pokedata.write("BattlerShadowSize = #{metrics[MetricBattlerShadowSize][i] || 2}\r\n")
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
        if param_type
          cparameter = getConstantName(param_type,parameter) rescue ""
          pokedata.write("#{cparameter}")
        else
          pokedata.write("#{parameter}")
        end
        pokedata.write(",") if k<evos.length-1
      end
      pokedata.write("\r\n")
    end
    if incense!=nil
      if incense>0
        initem = getConstantName(PBItems,incense) rescue pbGetItemConst(incense)
        pokedata.write("Incense = #{initem}\r\n")
      end
    end
    if i%20==0
      Graphics.update
      Win32API.SetWindowText(_INTL("Processing species {1}...",i))
    end
  end
  pokedata.close
  Graphics.update
end



#===============================================================================
# Save Shadow move data to PBS file
#===============================================================================
def pbSaveShadowMoves
  moves = pbLoadShadowMovesets
  File.open("PBS/shadowmoves.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    f.write("\#-------------------------------\r\n")
    for i in 0...moves.length
      move = moves[i]
      next if !move || moves.length==0
      constname = (getConstantName(PBSpecies,i) rescue pbGetSpeciesConst(i) rescue nil)
      next if !constname
      f.write(sprintf("%s = ",constname))
      movenames = []
      for m in move
        movenames.push((getConstantName(PBMoves,m) rescue pbGetMoveConst(m) rescue nil))
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
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
          f.write((getConstantName(PBTrainers,record) rescue pbGetTrainerConst(record)))
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
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
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
  c2 = (items[pkmn.item]) ? items[pkmn.item] :
     (items[pkmn.item] = (getConstantName(PBItems,pkmn.item) rescue pbGetItemConst(pkmn.item)))
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
  c4 = (moves[pkmn.move1]) ? moves[pkmn.move1] :
     (moves[pkmn.move1] = (getConstantName(PBMoves,pkmn.move1) rescue pbGetMoveConst(pkmn.move1)))
  c5 = (moves[pkmn.move2]) ? moves[pkmn.move2] :
     (moves[pkmn.move2] = (getConstantName(PBMoves,pkmn.move2) rescue pbGetMoveConst(pkmn.move2)))
  c6 = (moves[pkmn.move3]) ? moves[pkmn.move3] :
     (moves[pkmn.move3] = (getConstantName(PBMoves,pkmn.move3) rescue pbGetMoveConst(pkmn.move3)))
  c7 = (moves[pkmn.move4]) ? moves[pkmn.move4] :
     (moves[pkmn.move4] = (getConstantName(PBMoves,pkmn.move4) rescue pbGetMoveConst(pkmn.move4)))
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
