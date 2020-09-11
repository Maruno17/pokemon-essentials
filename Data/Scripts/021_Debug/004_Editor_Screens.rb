#===============================================================================
# Wild encounters editor
#===============================================================================
def pbEncounterEditorTypes(enc,enccmd)
  commands = []
  indexes = []
  haveblank = false
  if enc
    commands.push(_INTL("Density: {1},{2},{3}",
       enc[0][EncounterTypes::Land],
       enc[0][EncounterTypes::Cave],
       enc[0][EncounterTypes::Water]))
    indexes.push(-2)
    for i in 0...EncounterTypes::EnctypeChances.length
      if enc[1][i]
        commands.push(EncounterTypes::Names[i])
        indexes.push(i)
      else
        haveblank = true
      end
    end
  else
    commands.push(_INTL("Density: Not Defined Yet"))
    indexes.push(-2)
    haveblank = true
  end
  if haveblank
    commands.push(_INTL("[New Encounter Type]"))
    indexes.push(-3)
  end
  enccmd.x        = 0
  enccmd.y        = 0
  enccmd.height   = Graphics.height if enccmd.height>Graphics.height
  enccmd.z        = 99999
  enccmd.commands = commands
  enccmd.active   = true
  enccmd.index    = 0
  enccmd.visible  = true
  command = 0
  loop do
    Graphics.update
    Input.update
    enccmd.update
    if Input.trigger?(Input::A) && indexes[enccmd.index]>=0
      if pbConfirmMessage(_INTL("Delete the encounter type {1}?",commands[enccmd.index]))
        enc[1][indexes[enccmd.index]] = nil
        commands.delete_at(enccmd.index)
        indexes.delete_at(enccmd.index)
        enccmd.commands = commands
        if enccmd.index>=enccmd.commands.length
          enccmd.index = enccmd.commands.length
        end
      end
    elsif Input.trigger?(Input::B)
      command = -1
      break
    elsif Input.trigger?(Input::C) || (enccmd.doubleclick? rescue false)
      command = enccmd.index
      break
    end
  end
  ret = command
  enccmd.active = false
  return (ret<0) ? -1 : indexes[ret]
end

def pbNewEncounterType(enc)
  cmdwin = pbListWindow([])
  commands  =[]
  indexes = []
  for i in 0...EncounterTypes::EnctypeChances.length
    dogen = false
    if !enc[1][i]
      if i==0
        dogen = true unless enc[1][EncounterTypes::Cave]
      elsif i==1
        dogen = true unless enc[1][EncounterTypes::Land] ||
                            enc[1][EncounterTypes::LandMorning] ||
                            enc[1][EncounterTypes::LandDay] ||
                            enc[1][EncounterTypes::LandNight] ||
                            enc[1][EncounterTypes::BugContest]
      else
        dogen = true
      end
    end
    if dogen
      commands.push(EncounterTypes::Names[i])
      indexes.push(i)
    end
  end
  ret = pbCommands2(cmdwin,commands,-1)
  ret = (ret<0) ? -1 : indexes[ret]
  if ret>=0
    chances = EncounterTypes::EnctypeChances[ret]
    enc[1][ret] = []
    chances.length.times do
      enc[1][ret].push([1,5,5])
    end
  end
  cmdwin.dispose
  return ret
end

def pbEditEncounterType(enc,etype)
  commands = []
  cmdwin = pbListWindow([])
  chances = EncounterTypes::EnctypeChances[etype]
  chancetotal = 0
  chances.each { |a| chancetotal += a }
  enctype = enc[1][etype]
  for i in 0...chances.length
    enctype[i] = [1,5,5] if !enctype[i]
  end
  ret = 0
  loop do
    commands.clear
    for i in 0...enctype.length
      ch = chances[i]
      ch = sprintf("%.1f",100.0*chances[i]/chancetotal) if chancetotal!=100
      if enctype[i][1]==enctype[i][2]
        commands.push(_INTL("{1}% {2} (Lv.{3})",ch,PBSpecies.getName(enctype[i][0]),enctype[i][1]))
      else
        commands.push(_INTL("{1}% {2} (Lv.{3}-Lv.{4})",ch,PBSpecies.getName(enctype[i][0]),enctype[i][1],enctype[i][2]))
      end
    end
    ret = pbCommands2(cmdwin,commands,-1,ret)
    break if ret<0
    species = pbChooseSpeciesList(enctype[ret][0])
    next if species<=0
    enctype[ret][0] = species if species>0
    mLevel = PBExperience.maxLevel
    params = ChooseNumberParams.new
    params.setRange(1,mLevel)
    params.setDefaultValue(enctype[ret][1])
    minlevel = pbMessageChooseNumber(_INTL("Set the minimum level."),params)
    params = ChooseNumberParams.new
    params.setRange(minlevel,mLevel)
    params.setDefaultValue(minlevel)
    maxlevel = pbMessageChooseNumber(_INTL("Set the maximum level."),params)
    enctype[ret][1] = minlevel
    enctype[ret][2] = maxlevel
  end
  cmdwin.dispose
end

def pbEncounterEditorDensity(enc)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Land])
  enc[0][EncounterTypes::Land] = pbMessageChooseNumber(
     _INTL("Set the density of Pokémon on land (default {1}).",
     EncounterTypes::EnctypeDensities[EncounterTypes::Land]),params)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Cave])
  enc[0][EncounterTypes::Cave] = pbMessageChooseNumber(
     _INTL("Set the density of Pokémon in caves (default {1}).",
     EncounterTypes::EnctypeDensities[EncounterTypes::Cave]),params)
  params = ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Water])
  enc[0][EncounterTypes::Water] = pbMessageChooseNumber(
      _INTL("Set the density of Pokémon on water (default {1}).",
      EncounterTypes::EnctypeDensities[EncounterTypes::Water]),params)
  for i in 0...EncounterTypes::EnctypeCompileDens.length
    t = EncounterTypes::EnctypeCompileDens[i]
    next if !t || t==0
    enc[0][i] = enc[0][EncounterTypes::Land] if t==1
    enc[0][i] = enc[0][EncounterTypes::Cave] if t==2
    enc[0][i] = enc[0][EncounterTypes::Water] if t==3
  end
end

def pbEncounterEditorMap(encdata,map)
  enccmd = pbListWindow([])
  # This window displays the help text
  enchelp = Window_UnformattedTextPokemon.new("")
  enchelp.x      = 256
  enchelp.y      = 0
  enchelp.width  = 224
  enchelp.height = 96
  enchelp.z      = 99999
  mapinfos = load_data("Data/MapInfos.rxdata")
  mapname = mapinfos[map].name
  loop do
    enc = encdata[map]
    enchelp.text = mapname
    choice = pbEncounterEditorTypes(enc,enccmd)
    if !enc
      enc = [EncounterTypes::EnctypeDensities.clone,[]]
      encdata[map] = enc
    end
    if choice==-2
      pbEncounterEditorDensity(enc)
    elsif choice==-1
      break
    elsif choice==-3
      ret = pbNewEncounterType(enc)
      if ret>=0
        enchelp.text = _INTL("{1}\r\n{2}",mapname,EncounterTypes::Names[ret])
        pbEditEncounterType(enc,ret)
      end
    else
      enchelp.text = _INTL("{1}\r\n{2}",mapname,EncounterTypes::Names[choice])
      pbEditEncounterType(enc,choice)
    end
  end
  if encdata[map][1].length==0
    encdata[map] = nil
  end
  enccmd.dispose
  enchelp.dispose
  Input.update
end



#===============================================================================
# Trainer type editor
#===============================================================================
def pbTrainerTypeEditorNew(trconst)
  data = pbLoadTrainerTypesData
  # Get the first unused ID after all existing t-types for the new t-type to use.
  maxid = -1
  for rec in data
    next if !rec
    maxid = rec[0] if rec[0]>maxid
  end
  trainertype = maxid+1
  trname = pbMessageFreeText(_INTL("Please enter the trainer type's name."),
     (trconst) ? trconst.gsub(/_+/," ") : "",false,256)
  return -1 if trname=="" && !trconst
  # Create an internal name based on the trainer type's name if there is none.
  trconst = trname if !trconst
  trconst = trconst.gsub(/é/,"e")
  trconst = trconst.gsub(/[^A-Za-z0-9_]/,"")
  trconst = trconst.upcase
  if trconst.length==0
    trconst = sprintf("T_%03d",trainertype)
  elsif !trconst[0,1][/[A-Z]/]
    trconst = "T_"+trconst
  end
  # Create a default name if there is none.
  trname = trconst if trname==""
  cname = trconst
  if hasConst?(PBTrainers,cname)
    suffix = 1
    100.times do
      tname = sprintf("%s_%d",cname,suffix)
      if !hasConst?(PBTrainers,tname)
        cname = tname
        break
      end
      suffix += 1
    end
  end
  if hasConst?(PBTrainers,cname)
    pbMessage(_INTL("Failed to create the trainer type. Choose a different name."))
    return -1
  end
  record = []
  record[0] = trainertype
  record[1] = cname
  record[2] = trname
  record[7] = pbMessage(_INTL("Is the Trainer male, female, or mixed gender?"),[
     _INTL("Male"),_INTL("Female"),_INTL("Mixed")],0)
  params = ChooseNumberParams.new
  params.setRange(0,255)
  params.setDefaultValue(30)
  record[3] = pbMessageChooseNumber(_INTL("Set the money per level won for defeating the Trainer."),params)
  record[8] = record[3]
  record[9] = ""
  PBTrainers.const_set(cname,record[0])
  data[record[0]] = record
  save_data(data,"Data/trainer_types.dat")
  $PokemonTemp.trainerTypesData = nil
  pbConvertTrainerData
  pbMessage(_INTL("The Trainer type was created (ID: {1}).",record[0]))
  pbMessage(_ISPRINTF("Put the Trainer's graphic (trainer{1:03d}.png or trainer{2:s}.png) in Graphics/Characters, or it will be blank.",
     record[0],getConstantName(PBTrainers,record[0])))
  return record[0]
end

def pbTrainerTypeEditorSave(trainertype,ttdata)
  record = []
  record[0] = trainertype
  for i in 0..ttdata.length
    record.push(ttdata[i])
  end
  setConstantName(PBTrainers,trainertype,ttdata[0])
  data = pbLoadTrainerTypesData
  data[record[0]] = record
  save_data(data,"Data/trainer_types.dat")
  $PokemonTemp.trainerTypesData = nil
  pbConvertTrainerData
end

def pbTrainerTypeEditor
  selection = 0
  trainerTypes = [
    [_INTL("Internal Name"),ReadOnlyProperty,_INTL("Internal name that appears in constructs like PBTrainers::XXX.")],
    [_INTL("Trainer Name"),StringProperty,_INTL("Name of the trainer type as displayed by the game.")],
    [_INTL("Money Per Level"),LimitProperty.new(9999),_INTL("Player earns this amount times the highest level among the trainer's Pokémon.")],
    [_INTL("Battle BGM"),BGMProperty,_INTL("BGM played in battles against trainers of this type.")],
    [_INTL("Battle End ME"),MEProperty,_INTL("ME played when player wins battles against trainers of this type.")],
    [_INTL("Battle Intro ME"),MEProperty,_INTL("ME played before battles against trainers of this type.")],
    [_INTL("Gender"),EnumProperty.new([_INTL("Male"),_INTL("Female"),_INTL("Mixed gender")]),_INTL("Gender of this Trainer type.")],
    [_INTL("Skill"),LimitProperty.new(9999),_INTL("Skill level of this Trainer type.")],
    [_INTL("Skill Codes"),StringProperty,_INTL("Letters/phrases representing AI modifications of trainers of this type.")],
  ]
  pbListScreenBlock(_INTL("Trainer Types"),TrainerTypeLister.new(selection,true)) { |button,trtype|
    if trtype
      if button==Input::A
        if trtype[0]>=0
          if pbConfirmMessageSerious("Delete this trainer type?")
            data = pbLoadTrainerTypesData
            removeConstantValue(PBTrainers,trtype[0])
            data[trtype[0]] = nil
            save_data(data,"Data/trainer_types.dat")
            $PokemonTemp.trainerTypesData = nil
            pbConvertTrainerData
            pbMessage(_INTL("The Trainer type was deleted."))
          end
        end
      elsif button==Input::C
        selection = trtype[0]
        if selection<0
          newid = pbTrainerTypeEditorNew(nil)
          if newid>=0
            selection = newid
          end
        else
          data = []
          for i in 1..trtype.length
            data.push(trtype[i])
          end
          # trtype[2] contains trainer's name to display as title
          save = pbPropertyList(trtype[2],data,trainerTypes,true)
          if save
            pbTrainerTypeEditorSave(selection,data)
          end
        end
      end
    end
  }
end



#===============================================================================
# Individual trainer editor
#===============================================================================
module TrainerBattleProperty
  def self.set(settingname,oldsetting)
    return nil if !oldsetting
    properties = [
       [_INTL("Trainer Type"),TrainerTypeProperty,_INTL("Name of the trainer type for this Trainer.")],
       [_INTL("Trainer Name"),StringProperty,_INTL("Name of the Trainer.")],
       [_INTL("Battle ID"),LimitProperty.new(9999),_INTL("ID used to distinguish Trainers with the same name and trainer type.")],
       [_INTL("Lose Text"),StringProperty,_INTL("Message shown in battle when the Trainer is defeated.")],
       [_INTL("Pokémon 1"),TrainerPokemonProperty,_INTL("First Pokémon.")],
       [_INTL("Pokémon 2"),TrainerPokemonProperty,_INTL("Second Pokémon.")],
       [_INTL("Pokémon 3"),TrainerPokemonProperty,_INTL("Third Pokémon.")],
       [_INTL("Pokémon 4"),TrainerPokemonProperty,_INTL("Fourth Pokémon.")],
       [_INTL("Pokémon 5"),TrainerPokemonProperty,_INTL("Fifth Pokémon.")],
       [_INTL("Pokémon 6"),TrainerPokemonProperty,_INTL("Sixth Pokémon.")],
       [_INTL("Item 1"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 2"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 3"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 4"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 5"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 6"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 7"),ItemProperty,_INTL("Item used by the Trainer during battle.")],
       [_INTL("Item 8"),ItemProperty,_INTL("Item used by the Trainer during battle.")]
    ]
    if !pbPropertyList(settingname,oldsetting,properties,true)
      return nil
    end
    oldsetting = nil if !oldsetting[0] || oldsetting[0]==0
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def pbTrainerBattleEditor
  selection = 0
  trainertypes = pbLoadTrainerTypesData
  trainers     = pbLoadTrainersData
  modified = false
  for trainer in trainers
    trtype = trainer[0]
    next if trainertypes && trainertypes[trtype]
    trainer[0] = 0
    modified = true
  end
  pbListScreenBlock(_INTL("Trainer Battles"),TrainerBattleLister.new(selection,true)) { |button,trtype|
    next if !trtype
    index       = trtype[0]
    trainerdata = trtype[1]
    if button==Input::A
      # Delete trainer
      if index>=0
        if pbConfirmMessageSerious("Delete this trainer battle?")
          trainers.delete_at(index)
          modified = true
          pbMessage(_INTL("The Trainer battle was deleted."))
        end
      end
    elsif button==Input::C
      # New trainer/edit existing trainer
      selection = index
      if selection<0
        # New trainer
        trainertype = -1
        ret = pbMessage(_INTL("First, define the type of trainer."),[
           _INTL("Use existing type"),
           _INTL("Use new type"),
           _INTL("Cancel")],3)
        if ret==0
          trainertype = pbListScreen(_INTL("TRAINER TYPE"),TrainerTypeLister.new(0,false))
          next if !trainertype
          trainertype = trainertype[0]
          next if trainertype<0
        elsif ret==1
          trainertype = pbTrainerTypeEditorNew(nil)
          next if trainertype<0
        else
          next
        end
        trainername = pbMessageFreeText(_INTL("Now enter the trainer's name."),"",false,32)
        next if trainername==""
        trainerparty = pbGetFreeTrainerParty(trainertype,trainername)
        if trainerparty<0
          pbMessage(_INTL("There is no room to create a trainer of that type and name."))
          next
        end
        t = pbNewTrainer(trainertype,trainername,trainerparty,false)
        trainers.push(t) if t
        pbMessage(_INTL("The Trainer battle was added."))
      else
        # Edit existing trainer
        data = [trainerdata[0],trainerdata[1],trainerdata[4],trainerdata[5]]   # Type, name, ID, lose text
        for i in 0...6
          data.push(trainerdata[3][i])   # Pokémon
        end
        for i in 0...8
          data.push(trainerdata[2][i])   # Items
        end
        loop do
          data = TrainerBattleProperty.set(trainerdata[1],data)
          break if !data
          trainerdata = [
             data[0],
             data[1],
             [data[10],data[11],data[12],data[13],data[14],data[15],data[16],data[17]].find_all { |i| i && i!=0 },   # Item list
             [data[4],data[5],data[6],data[7],data[8],data[9]].find_all { |i| i && i[TPSPECIES]!=0 },   # Pokémon list
             data[2],
             data[3]
          ]
          if !trainerdata[1] || trainerdata[1].length==0
            pbMessage(_INTL("Can't save. No name was entered."))
          elsif trainerdata[3].length==0
            pbMessage(_INTL("Can't save. The Pokémon list is empty."))
          else
            trainers[index] = trainerdata
            modified = true
            break
          end
        end
      end
    end
  }
  if modified && pbConfirmMessage(_INTL("Save changes?"))
    save_data(trainers,"Data/trainers.dat")
    $PokemonTemp.trainersData = nil
    pbConvertTrainerData
  end
end



#===============================================================================
# Trainer Pokémon editor
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname,initsetting)
    initsetting = [0,10] if !initsetting
    oldsetting = []
    for i in 0...TPEV
      if i==TPMOVES
        for j in 0...4
          oldsetting.push((initsetting[TPMOVES]) ? initsetting[TPMOVES][j] : nil)
        end
      else
        oldsetting.push(initsetting[i])
      end
    end
    mLevel = PBExperience.maxLevel
    properties = [
       [_INTL("Species"),SpeciesProperty,_INTL("Species of the Pokémon.")],
       [_INTL("Level"),NonzeroLimitProperty.new(mLevel),_INTL("Level of the Pokémon (1-{1}).",mLevel)],
       [_INTL("Held item"),ItemProperty,_INTL("Item held by the Pokémon.")],
       [_INTL("Move 1"),MoveProperty2.new(oldsetting),_INTL("First move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 2"),MoveProperty2.new(oldsetting),_INTL("Second move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 3"),MoveProperty2.new(oldsetting),_INTL("Third move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 4"),MoveProperty2.new(oldsetting),_INTL("Fourth move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Ability"),LimitProperty2.new(5),_INTL("Ability flag. 0=first ability, 1=second ability, 2-5=hidden ability.")],
       [_INTL("Gender"),GenderProperty.new,_INTL("Gender of the Pokémon.")],
       [_INTL("Form"),LimitProperty2.new(999),_INTL("Form of the Pokémon.")],
       [_INTL("Shiny"),BooleanProperty2,_INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Nature"),NatureProperty,_INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),IVsProperty.new(PokeBattle_Pokemon::IV_STAT_LIMIT),_INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),LimitProperty2.new(255),_INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Nickname"),StringProperty,_INTL("Name of the Pokémon.")],
       [_INTL("Shadow"),BooleanProperty2,_INTL("If set to true, the Pokémon is a Shadow Pokémon.")],
       [_INTL("Ball"),BallProperty.new(oldsetting),_INTL("The kind of Poké Ball the Pokémon is kept in.")],
       [_INTL("EVs"),EVsProperty.new(PokeBattle_Pokemon::EV_STAT_LIMIT),_INTL("Effort values for each of the Pokémon's stats.")]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return nil if !oldsetting[TPSPECIES] || oldsetting[TPSPECIES]==0
    ret = []
    moves = []
    for i in 0...oldsetting.length
      if i>=TPMOVES && i<TPMOVES+4
        ret.push(nil) if i==TPMOVES
        moves.push(oldsetting[i])
      else
        ret.push(oldsetting[i])
      end
    end
    moves.compact!
    ret[TPMOVES] = moves if moves.length>0
    # Remove unnecessarily nils from the end of ret
    ret.pop while ret.last.nil? && ret.size>0
    return ret
  end

  def self.format(value)
    return "-" if !value || !value[TPSPECIES] || value[TPSPECIES]<=0
    return sprintf("%s,%d",PBSpecies.getName(value[TPSPECIES]),value[TPLEVEL])
  end
end



#===============================================================================
# Metadata editor
#===============================================================================
def pbMetadataScreen(defaultMapId=nil)
  metadata = nil
  mapinfos = pbLoadRxData("Data/MapInfos")
  metadata = pbLoadMetadata
  map = defaultMapId ? defaultMapId : 0
  loop do
    map = pbListScreen(_INTL("SET METADATA"),MapLister.new(map,true))
    break if map<0
    mapname = (map==0) ? _INTL("Global Metadata") : mapinfos[map].name
    data = []
    properties = (map==0) ? MapScreenScene::GLOBALMETADATA : MapScreenScene::LOCALMAPS
    for i in 0...properties.length
      data.push((metadata[map]) ? metadata[map][i+1] : nil)
    end
    pbPropertyList(mapname,data,properties)
    for i in 0...properties.length
      metadata[map] = [] if !metadata[map]
      metadata[map][i+1] = data[i]
    end
  end
  pbSerializeMetadata(metadata,mapinfos) if metadata
end



#===============================================================================
# Item editor
#===============================================================================
def pbItemEditor
  selection = 0
  items = [
     [_INTL("Internal Name"),ReadOnlyProperty,_INTL("Internal name that appears in constructs like PBItems::XXX.")],
     [_INTL("Item Name"),ItemNameProperty,_INTL("Name of the item as displayed by the game.")],
     [_INTL("Item Name Plural"),ItemNameProperty,_INTL("Plural name of the item as displayed by the game.")],
     [_INTL("Pocket"),PocketProperty,_INTL("Pocket in the bag where the item is stored.")],
     [_INTL("Purchase price"),LimitProperty.new(999999),_INTL("Purchase price of the item.")],
     [_INTL("Description"),StringProperty,_INTL("Description of the item")],
     [_INTL("Use Out of Battle"),EnumProperty.new([
        _INTL("Can't Use"),_INTL("On a Pokémon"),_INTL("Use directly"),
        _INTL("TM"),_INTL("HM"),_INTL("On a Pokémon reusable")]),
        _INTL("Specifies how this item can be used outside of battle.")],
     [_INTL("Use In Battle"),EnumProperty.new([
        _INTL("Can't Use"),_INTL("On a Pokémon"),_INTL("On Pokémon's move"),
        _INTL("On battler"),_INTL("On foe battler"),_INTL("Use directly"),
        _INTL("On a Pokémon reusable"),_INTL("On Pokémon's move reusable"),
        _INTL("On battler reusable"),_INTL("On foe battler reusable"),
        _INTL("Use directly reusable")]),
        _INTL("Specifies how this item can be used within a battle.")],
     [_INTL("Special Items"),EnumProperty.new([
        _INTL("None of below"),_INTL("Mail"),_INTL("Mail with Pictures"),
        _INTL("Snag Ball"),_INTL("Poké Ball"),_INTL("Plantable Berry"),
        _INTL("Key Item"),_INTL("Evolution Stone"),_INTL("Fossil"),
        _INTL("Apricorn"),_INTL("Type-boosting Gem"),_INTL("Mulch"),
        _INTL("Mega Stone")]),
        _INTL("For special kinds of items.")],
     [_INTL("Machine"),MoveProperty,_INTL("Move taught by this TM or HM.")]
  ]
  pbListScreenBlock(_INTL("Items"),ItemLister.new(selection,true)) { |button,trtype|
    if trtype
      if button==Input::A
        if trtype>=0
          if pbConfirmMessageSerious("Delete this item?")
            data = pbLoadItemsData
            removeConstantValue(PBItems,trtype)
            data.delete_if { |item| item[0]==trtype }
            for x in data
              p x if data[0]==0
            end
            save_data(data,"Data/items.dat")
            $PokemonTemp.itemsData = nil
            pbSaveItems
            pbMessage(_INTL("The item was deleted."))
          end
        end
      elsif button==Input::C
        selection = trtype
        if selection<0
          newid = pbItemEditorNew(nil)
          if newid>=0
            selection = newid
          end
        else
          data = [getConstantName(PBItems,selection)]
          itemdata = pbLoadItemsData
          data.push(itemdata[selection][ITEM_NAME])
          data.push(itemdata[selection][ITEM_PLURAL])
          data.push(itemdata[selection][ITEM_POCKET])
          data.push(itemdata[selection][ITEM_PRICE])
          data.push(itemdata[selection][ITEM_DESCRIPTION])
          data.push(itemdata[selection][ITEM_FIELD_USE])
          data.push(itemdata[selection][ITEM_BATTLE_USE])
          data.push(itemdata[selection][ITEM_TYPE])
          data.push(itemdata[selection][ITEM_MACHINE])
          save = pbPropertyList(data[ITEM_NAME],data,items,true)
          if save
            itemdata[selection][ITEM_NAME]        = data[ITEM_NAME]
            itemdata[selection][ITEM_PLURAL]      = data[ITEM_PLURAL]
            itemdata[selection][ITEM_POCKET]      = data[ITEM_POCKET]
            itemdata[selection][ITEM_PRICE]       = data[ITEM_PRICE]
            itemdata[selection][ITEM_DESCRIPTION] = data[ITEM_DESCRIPTION]
            itemdata[selection][ITEM_FIELD_USE]   = data[ITEM_FIELD_USE]
            itemdata[selection][ITEM_BATTLE_USE]  = data[ITEM_BATTLE_USE]
            itemdata[selection][ITEM_TYPE]        = data[ITEM_TYPE]
            itemdata[selection][ITEM_MACHINE]     = data[ITEM_MACHINE]
            save_data(itemdata,"Data/items.dat")
            $PokemonTemp.itemsData = nil
            pbSaveItems
          end
        end
      end
    end
  }
end

def pbItemEditorNew(defaultname)
  itemdata = pbLoadItemsData
  # Get the first blank ID for the new item to use.
  maxid = PBItems.maxValue+1
  for i in 1..PBItems.maxValue
    name = itemdata[i][1]
    if !name || name=="" || itemdata[i][ITEM_POCKET]==0
      maxid = i
      break
    end
  end
  index = maxid
  itemname = pbMessageFreeText(_INTL("Please enter the item's name."),
     (defaultname) ? defaultname.gsub(/_+/," ") : "",false,30)
  if itemname=="" && !defaultname
    return -1
  else
    # Create a default name if there is none.
    if !defaultname
      defaultname = itemname.gsub(/[^A-Za-z0-9_]/,"")
      defaultname = defaultname.sub(/^([a-z])/) { $1.upcase }
      if defaultname.length==0
        defaultname = sprintf("Item%03d",index)
      elsif !defaultname[0,1][/[A-Z]/]
        defaultname = "Item"+defaultname
      end
    end
    itemname = defaultname if itemname==""
    # Create an internal name based on the item name.
    cname = itemname.gsub(/é/,"e")
    cname = cname.gsub(/[^A-Za-z0-9_]/,"")
    cname = cname.upcase
    if hasConst?(PBItems,cname)
      suffix = 1
      100.times do
        tname = sprintf("%s_%d",cname,suffix)
        if !hasConst?(PBItems,tname)
          cname = tname
          break
        end
        suffix += 1
      end
    end
    if hasConst?(PBItems,cname)
      pbMessage(_INTL("Failed to create the item. Choose a different name."))
      return -1
    end
    pocket = PocketProperty.set("",0)
    return -1 if pocket==0
    price = LimitProperty.new(999999).set(_INTL("Purchase price"),-1)
    return -1 if price==-1
    desc = StringProperty.set(_INTL("Description"),"")
    # Item list will create record automatically
    itemdata[index][ITEM_ID]          = index
    itemdata[index][ITEM_NAME]        = itemname
    itemdata[index][ITEM_POCKET]      = pocket
    itemdata[index][ITEM_PRICE]       = price
    itemdata[index][ITEM_DESCRIPTION] = desc
    itemdata[index][ITEM_FIELD_USE]   = 0
    itemdata[index][ITEM_BATTLE_USE]  = 0
    itemdata[index][ITEM_TYPE]        = 0
    itemdata[index][ITEM_MACHINE]     = 0
    PBItems.const_set(cname,index)
    save_data(itemdata,"Data/items.dat")
    $PokemonTemp.itemsData = nil
    pbSaveItems
    pbMessage(_INTL("The item was created (ID: {1}).",index))
    pbMessage(_ISPRINTF("Put the item's graphic (item{1:03d}.png or item{2:s}.png) in Graphics/Icons, or it will be blank.",
       index,getConstantName(PBItems,index)))
    return index
  end
end



#===============================================================================
# Pokémon species editor
#===============================================================================
def pbPokemonEditor
  regionalDexes = pbLoadRegionalDexes
  metrics       = pbLoadSpeciesMetrics
  selection = 0
  species = [
     [_INTL("Name"),LimitStringProperty.new(PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE),_INTL("Name of the Pokémon.")],
     [_INTL("InternalName"),ReadOnlyProperty,_INTL("Internal name of the Pokémon.")],
     [_INTL("Type1"),TypeProperty,_INTL("Pokémon's type. If same as Type2, this Pokémon has a single type.")],
     [_INTL("Type2"),TypeProperty,_INTL("Pokémon's type. If same as Type1, this Pokémon has a single type.")],
     [_INTL("BaseStats"),BaseStatsProperty,_INTL("Base stats of the Pokémon.")],
     [_INTL("GenderRate"),EnumProperty.new([
        _INTL("Genderless"),_INTL("AlwaysMale"),_INTL("FemaleOneEighth"),
        _INTL("Female25Percent"),_INTL("Female50Percent"),_INTL("Female75Percent"),
        _INTL("FemaleSevenEighths"),_INTL("AlwaysFemale")]),
        _INTL("Proportion of males to females for this species.")],
     [_INTL("GrowthRate"),EnumProperty.new([
        _INTL("Medium"),_INTL("Erratic"),_INTL("Fluctuating"),_INTL("Parabolic"),
        _INTL("Fast"),_INTL("Slow")]),
        _INTL("Pokémon's growth rate.")],
     [_INTL("BaseEXP"),LimitProperty.new(9999),_INTL("Base experience earned when this species is defeated.")],
     [_INTL("EffortPoints"),EffortValuesProperty,_INTL("Effort Value points earned when this species is defeated.")],
     [_INTL("Rareness"),LimitProperty.new(255),_INTL("Catch rate of this species (0-255).")],
     [_INTL("Happiness"),LimitProperty.new(255),_INTL("Base happiness of this species (0-255).")],
     [_INTL("Ability1"),AbilityProperty,_INTL("One ability which the Pokémon can have.")],
     [_INTL("Ability2"),AbilityProperty,_INTL("Another ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 1"),AbilityProperty,_INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 2"),AbilityProperty,_INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 3"),AbilityProperty,_INTL("A secret ability which the Pokémon can have.")],
     [_INTL("HiddenAbility 4"),AbilityProperty,_INTL("A secret ability which the Pokémon can have.")],
     [_INTL("Moves"),MovePoolProperty,_INTL("Moves which the Pokémon learns while levelling up.")],
     [_INTL("EggMoves"),EggMovesProperty,_INTL("Moves which the Pokémon can learn via breeding.")],
     [_INTL("Compat1"),EnumProperty.new([
        "Undiscovered","Monster","Water 1","Bug","Flying",
        "Field","Fairy","Grass","Human-like","Water 3",
        "Mineral","Amorphous","Water 2","Ditto","Dragon"]),
        _INTL("Compatibility group (egg group) for breeding purposes.")],
     [_INTL("Compat2"),EnumProperty.new([
        "Undiscovered","Monster","Water 1","Bug","Flying",
        "Field","Fairy","Grass","Human-like","Water 3",
        "Mineral","Amorphous","Water 2","Ditto","Dragon"]),
        _INTL("Compatibility group (egg group) for breeding purposes.")],
     [_INTL("StepsToHatch"),LimitProperty.new(99999),_INTL("Number of steps until an egg of this species hatches.")],
     [_INTL("Height"),NonzeroLimitProperty.new(999),_INTL("Height of the Pokémon in 0.1 metres (e.g. 42 = 4.2m).")],
     [_INTL("Weight"),NonzeroLimitProperty.new(9999),_INTL("Weight of the Pokémon in 0.1 kilograms (e.g. 42 = 4.2kg).")],
     [_INTL("Color"),EnumProperty.new([
        _INTL("Red"),_INTL("Blue"),_INTL("Yellow"),_INTL("Green"),_INTL("Black"),
        _INTL("Brown"),_INTL("Purple"),_INTL("Gray"),_INTL("White"),_INTL("Pink")]),
        _INTL("Pokémon's body color.")],
     [_INTL("Shape"),LimitProperty.new(14),_INTL("Body shape of this species (0-14).")],
     [_INTL("Habitat"),EnumProperty.new([
        _INTL("None"),_INTL("Grassland"),_INTL("Forest"),_INTL("WatersEdge"),
        _INTL("Sea"),_INTL("Cave"),_INTL("Mountain"),_INTL("RoughTerrain"),
        _INTL("Urban"),_INTL("Rare")]),
        _INTL("The habitat of this species.")],
     [_INTL("RegionalNumbers"),ReadOnlyProperty,_INTL("Regional Dex numbers for the Pokémon. These are edited elsewhere.")],
     [_INTL("Kind"),StringProperty,_INTL("Kind of Pokémon species.")],
     [_INTL("Pokédex"),StringProperty,_INTL("Description of the Pokémon as displayed in the Pokédex.")],
     [_INTL("FormName"),StringProperty,_INTL("Name of this form of the Pokémon.")],
     [_INTL("WildItemCommon"),ItemProperty,_INTL("Item commonly held by wild Pokémon of this species.")],
     [_INTL("WildItemUncommon"),ItemProperty,_INTL("Item uncommonly held by wild Pokémon of this species.")],
     [_INTL("WildItemRare"),ItemProperty,_INTL("Item rarely held by wild Pokémon of this species.")],
     [_INTL("BattlerPlayerX"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerPlayerY"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerEnemyX"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerEnemyY"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerAltitude"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerShadowX"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("BattlerShadowSize"),ReadOnlyProperty,_INTL("Affects positioning of the Pokémon in battle. This is edited elsewhere.")],
     [_INTL("Evolutions"),EvolutionsProperty.new(PBEvolution::EVONAMES),_INTL("Evolution paths of this species.")],
     [_INTL("Incense"),ItemProperty,_INTL("Item needed to be held by a parent to produce an egg of this species.")],
  ]
  pbListScreenBlock(_INTL("Pokémon species"),SpeciesLister.new(selection,false)) { |button,index|
    if index
      if button==Input::A
        if index>=0
          if pbConfirmMessageSerious("Delete this species?")
            # A species existing depends on its constant existing, so just need
            # to delete that - recompiling pokemon.txt will do the rest.
            removeConstantValue(PBSpecies,index)
            pbSavePokemonData
            pbMessage(_INTL("The species was deleted. You should fully recompile before doing anything else."))
          end
        end
      elsif button==Input::C
        selection = index
        if selection<0
          pbMessage(_INTL("Can't add a new species."))
#          newid=pbSpeciesEditorNew(nil)
#          selection=newid if newid>=0
        else
          speciesData = pbGetSpeciesData(selection)
          messages = Messages.new("Data/messages.dat") rescue nil
          if !speciesData || !messages
            raise _INTL("Couldn't find species.dat or messages.dat to get Pokémon data from.")
          end
          speciesname = messages.get(MessageTypes::Species,selection)
          kind        = messages.get(MessageTypes::Kinds,selection)
          entry       = messages.get(MessageTypes::Entries,selection)
          cname       = getConstantName(PBSpecies,selection) rescue sprintf("POKE%03d",selection)
          formname    = messages.get(MessageTypes::FormNames,selection)
          abilities = speciesData[SpeciesAbilities]
          if abilities.is_a?(Array)
            ability1       = abilities[0]
            ability2       = abilities[1]
          else
            ability1       = abilities
            ability2       = nil
          end
          color            = speciesData[SpeciesColor]
          habitat          = speciesData[SpeciesHabitat]
          type1            = speciesData[SpeciesType1]
          type2            = speciesData[SpeciesType2]
          type2            = nil if type2==type1
          baseStats        = speciesData[SpeciesBaseStats].clone if speciesData[SpeciesBaseStats]
          rareness         = speciesData[SpeciesRareness]
          shape            = speciesData[SpeciesShape]
          genderrate       = speciesData[SpeciesGenderRate]
          happiness        = speciesData[SpeciesHappiness]
          growthrate       = speciesData[SpeciesGrowthRate]
          stepstohatch     = speciesData[SpeciesStepsToHatch]
          effort           = speciesData[SpeciesEffortPoints].clone if speciesData[SpeciesEffortPoints]
          compats = speciesData[SpeciesCompatibility]
          if compats.is_a?(Array)
            compat1        = compats[0]
            compat2        = compats[1]
          else
            compat1        = compats
            compat2        = nil
          end
          height           = speciesData[SpeciesHeight]
          weight           = speciesData[SpeciesWeight]
          baseexp          = speciesData[SpeciesBaseExp]
          hiddenAbils = speciesData[SpeciesHiddenAbility]
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
          item1            = speciesData[SpeciesWildItemCommon]
          item2            = speciesData[SpeciesWildItemUncommon]
          item3            = speciesData[SpeciesWildItemRare]
          incense          = speciesData[SpeciesIncense]
          originalMoveset = pbGetSpeciesMoveset(selection)
          movelist = []
          originalMoveset.each_with_index { |m,i| movelist.push([m[0],m[1],i]) }
          movelist.sort! { |a,b| (a[0]==b[0]) ? a[2]<=>b[2] : a[0]<=>b[0] }
          originalEggMoves = pbGetSpeciesEggMoves(selection)
          eggmovelist = []
          originalEggMoves.each { |m| eggmovelist.push(m) if m!=0 }
          regionallist = []
          for i in 0...regionalDexes.length
            regionallist.push(regionalDexes[i][selection])
          end
          numb = regionallist.size-1
          while numb>=0   # Remove every 0 at end of array
            (regionallist[numb]==0) ? regionallist.pop : break
            numb -= 1
          end
          evolutions = pbGetEvolvedFormData(selection)
          data = []
          data.push(speciesname)                    # 0
          data.push(cname)                          # 1
          data.push(type1)                          # 2
          data.push(type2)                          # 3
          data.push(baseStats)                      # 4
          data.push(genderrate)                     # 5
          data.push(growthrate)                     # 6
          data.push(baseexp)                        # 7
          data.push(effort)                         # 8
          data.push(rareness)                       # 9
          data.push(happiness)                      # 10
          data.push(ability1)                       # 11
          data.push(ability2)                       # 12
          data.push(hiddenability1)                 # 13
          data.push(hiddenability2)                 # 14
          data.push(hiddenability3)                 # 15
          data.push(hiddenability4)                 # 16
          data.push(movelist)                       # 17
          data.push(eggmovelist)                    # 18
          data.push(compat1)                        # 19
          data.push(compat2)                        # 20
          data.push(stepstohatch)                   # 21
          data.push(height)                         # 22
          data.push(weight)                         # 23
          data.push(color)                          # 24
          data.push(shape)                          # 25
          data.push(habitat)                        # 26
          data.push(regionallist)                   # 27
          data.push(kind)                           # 28
          data.push(entry)                          # 29
          data.push(formname)                       # 30
          data.push(item1)                          # 31
          data.push(item2)                          # 32
          data.push(item3)                          # 33
          for i in 0...6
            data.push(metrics[i][selection] || 0)   # 34, 35, 36, 37, 38, 39
          end
          data.push(metrics[MetricBattlerShadowSize][selection] || 2)   # 40
          data.push(evolutions)                     # 41
          data.push(incense)                        # 42
          # Edit the properties
          save = pbPropertyList(data[0],data,species,true)
          if save
            # Make sure both Type1 and Type2 are recorded correctly
            data[2] = (data[3] || 0) if !data[2]
            data[3] = data[2] if !data[3]
            # Make sure both Compatibilities are recorded correctly
            data[19] = (data[20] && data[20]!=0) ? data[20] : PBEggGroups::Undiscovered if !data[19] || data[19]==0
            data[20] = data[19] if !data[20] || data[20]==0
            compats = (data[20] && data[20]>0) ? [data[19],data[20]] : data[19]
            # Make sure both Abilities are recorded correctly
            data[11] = data[12] if !data[11] || data[11]==0
            data[11] = 0 if !data[11]
            data[12] = 0 if data[11]==data[12]
            abils = (data[12] && data[12]>0) ? [data[11],data[12]] : data[11]
            # Make sure all Hidden Abilities are recorded correctly
            hiddenAbils = []; shouldArray = false
            for i in 13..17
              data[i] = nil if data[i] && data[i]==0
              hiddenAbils.push(data[i])
              shouldArray = true if i>13 && data[i]
            end
            hiddenAbils = hiddenAbils[0] if !shouldArray
            # Save data
            speciesData[SpeciesAbilities]        = abils
            speciesData[SpeciesColor]            = data[24]
            speciesData[SpeciesHabitat]          = data[26]
            speciesData[SpeciesType1]            = data[2]
            speciesData[SpeciesType2]            = data[3]
            speciesData[SpeciesBaseStats]        = data[4]
            speciesData[SpeciesRareness]         = data[9]
            speciesData[SpeciesShape]            = data[25]
            speciesData[SpeciesGenderRate]       = data[5]
            speciesData[SpeciesHappiness]        = data[10]
            speciesData[SpeciesGrowthRate]       = data[6]
            speciesData[SpeciesStepsToHatch]     = data[21]
            speciesData[SpeciesEffortPoints]     = data[8]
            speciesData[SpeciesCompatibility]    = compats
            speciesData[SpeciesHeight]           = data[22]
            speciesData[SpeciesWeight]           = data[23]
            speciesData[SpeciesBaseExp]          = data[7]
            speciesData[SpeciesHiddenAbility]    = hiddenAbils
            speciesData[SpeciesWildItemCommon]   = data[31]
            speciesData[SpeciesWildItemUncommon] = data[32]
            speciesData[SpeciesWildItemRare]     = data[33]
            speciesData[SpeciesIncense]          = data[42]
            save_data(pbLoadSpeciesData,"Data/species.dat")
            namearray  = []
            kindarray  = []
            entryarray = []
            formarray  = []
            for i in 1..(PBSpecies.maxValue rescue PBSpecies.getCount-1 rescue messages.getCount(MessageTypes::Species)-1)
              namearray[i]  = messages.get(MessageTypes::Species,i)
              kindarray[i]  = messages.get(MessageTypes::Kinds,i)
              entryarray[i] = messages.get(MessageTypes::Entries,i)
              formarray[i]  = messages.get(MessageTypes::FormNames,i)
            end
            namearray[selection]  = data[0]
            kindarray[selection]  = data[28]
            entryarray[selection] = data[29]
            formarray[selection]  = data[30]
            MessageTypes.addMessages(MessageTypes::Species,namearray)
            MessageTypes.addMessages(MessageTypes::Kinds,kindarray)
            MessageTypes.addMessages(MessageTypes::Entries,entryarray)
            MessageTypes.addMessages(MessageTypes::FormNames,formarray)
            MessageTypes.saveMessages
            # Save moves data
            movesetsData = pbLoadMovesetsData
            movesetsData[selection] = data[17]
            save_data(movesetsData,"Data/species_movesets.dat")
            # Save egg moves data
            data[18].delete_if { |x| !x || x==0 }
            eggMovesData = pbLoadEggMovesData
            eggMovesData[selection] = data[18]
            save_data(eggMovesData,"Data/species_eggmoves.dat")
            # Save evolutions data
            evos = []
            for sp in 1..PBSpecies.maxValueF
              evos[sp] = []
              if sp==selection
                for i in 0...data[41].length
                  evos[sp].push([data[41][i][2],data[41][i][0],data[41][i][1],false])
                end
              else
                t = pbGetEvolvedFormData(sp)
                for i in 0...t.length
                  evos[sp].push([t[i][2],t[i][0],t[i][1],false])
                end
              end
            end
            for e in 0...evos.length
              evolist = evos[e]
              next if !evos
              parent = nil
              child = -1
              for f in 0...evos.length
                evolist = evos[f]
                next if !evolist || e==f
                for g in evolist
                  if g[0]==e && !g[3]   # f evolves into e
                    parent = g
                    child = f
                    break
                  end
                end
                break if parent
              end
              if parent   # parent[1]=method, parent[2]=level - both are unused
                # Found a species that evolves into e, record it as a prevolution
                evos[e] = [[child,parent[1],parent[2],true]].concat(evos[e])
              end
            end
            save_data(evos,"Data/species_evolutions.dat")
            # Don't need to save metrics or regional numbers
            # because they can't be edited here
            pbClearData
            pbSavePokemonData
            pbMessage(_INTL("Data saved."))
          end
        end
      end
    end
  }
end

def pbSpeciesEditorNew(defaultname)
end



#===============================================================================
# Regional Dexes editor
#===============================================================================
def pbRegionalDexEditor(dex)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  info = Window_AdvancedTextPokemon.new(_INTL("Z+Up/Down: Rearrange entries\nZ+Right: Insert new entry\nZ+Left: Delete entry\nF: Clear entry"))
  info.x        = 256
  info.y        = 64
  info.width    = Graphics.width-256
  info.height   = Graphics.height-64
  info.viewport = viewport
  info.z        = 2
  ret = dex
  tdex = dex.clone
  tdex.compact!
  cmdwin = pbListWindow([])
  refreshlist = true
  commands = []
  cmd = [0,0]
  loop do
    if refreshlist
      if tdex.length>0
        i = tdex.length-1
        loop do break unless tdex[i]==0
          tdex[i] = nil
          i -= 1
          break if i<0
        end
        tdex.compact!
      end
      tdex.push(0) if tdex.length==0 || tdex[tdex.length-1]!=0
      commands = []
      for i in 0...tdex.length
        text = "----------"
        if tdex[i]>0 && (getConstantName(PBSpecies,tdex[i]) rescue false)
          text = PBSpecies.getName(tdex[i])
        end
        commands.push(sprintf("%03d: %s",i+1,text))
      end
    end
    refreshlist = false
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    case cmd[0]
    when 1   # Swap move up
      if cmd[1]<tdex.length-1
        tdex[cmd[1]+1],tdex[cmd[1]] = tdex[cmd[1]],tdex[cmd[1]+1]
        refreshlist = true
      end
     when 2   # Swap move down
      if cmd[1]>0
        tdex[cmd[1]-1],tdex[cmd[1]] = tdex[cmd[1]],tdex[cmd[1]-1]
        refreshlist = true
      end
    when 3   # Delete spot
      tdex[cmd[1]] = nil
      tdex.compact!
      cmd[1] = [cmd[1],tdex.length-1].min
      refreshlist = true
    when 4   # Insert spot
      i = tdex.length
      loop do break unless i>=cmd[1]
        tdex[i+1] = tdex[i]
        i -= 1
      end
      tdex[cmd[1]] = 0
      refreshlist = true
    when 5   # Clear spot
      tdex[cmd[1]] = 0
      refreshlist = true
    when 0
      if cmd[1]>=0   # Edit entry
        cmd2 = pbMessage(_INTL("\\ts[]Do what with this entry?"),
           [_INTL("Change species"),_INTL("Clear"),_INTL("Insert entry"),_INTL("Delete entry"),_INTL("Cancel")],5)
        case cmd2
        when 0
          newspecies = pbChooseSpeciesList(tdex[cmd[1]])
          if newspecies>0
            tdex[cmd[1]] = newspecies
            for i in 0...tdex.length
              next if i==cmd[1]
              tdex[i] = 0 if tdex[i]==newspecies
            end
            refreshlist = true
          end
        when 1
          tdex[cmd[1]] = 0
          refreshlist = true
        when 2
          i = tdex.length
          loop do break unless i>=cmd[1]
            tdex[i+1] = tdex[i]
            i -= 1
          end
          tdex[cmd[1]] = 0
          refreshlist = true
        when 3
          if cmd[1]<tdex.length-1
            tdex[cmd[1]] = nil
            tdex.compact!
            cmd[1] = [cmd[1],tdex.length-1].min
            refreshlist = true
          end
        end
      else   # Cancel
        cmd2 = pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
        if cmd2==0   # Yes
          if tdex.length>0
            i = tdex.length-1
            loop do break unless tdex[i]==0
              tdex[i] = nil
              i -= 1
              break if i<0
            end
            tdex.compact!
          end
          tdex = [nil].concat(tdex)
          ret = tdex
          break
        elsif cmd2==1   # No
          break
        end
      end
    end
  end
  info.dispose
  cmdwin.dispose
  viewport.dispose
  return ret
end

def pbRegionalDexEditorMain
  dexList = pbLoadRegionalDexes
  regionallist = []
  for i in 0...dexList.length
    regionallist[i] = []
    for j in 0...dexList[i].length
      regionallist[i][dexList[i][j]] = j if dexList[i][j] && dexList[i][j]>0
    end
    for j in 1...regionallist[i].length   # Replace nils with 0s
      regionallist[i][j] = 0 if !regionallist[i][j]
    end
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.new(_INTL("Regional Dexes Editor"))
  title.x        = 256
  title.y        = 0
  title.width    = Graphics.width-256
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  info = Window_AdvancedTextPokemon.new(_INTL("Z+Up/Down: Rearrange Dexes"))
  info.x        = 256
  info.y        = 64
  info.width    = Graphics.width-256
  info.height   = Graphics.height-64
  info.viewport = viewport
  info.z        = 2
  commands = []
  refreshlist = true; oldsel = -1
  cmd = [0,0]
  loop do
    if refreshlist
      commands = [_INTL("[ADD DEX]")]
      for i in 0...regionallist.length
        commands.push(_INTL("Dex {1} (size {2})",i+1,regionallist[i].length-1))
      end
    end
    refreshlist = false; oldsel = -1
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    case cmd[0]
    when 1   # Swap dex up
      if cmd[1]>0 && cmd[1]<commands.length-1
        regionallist[cmd[1]-1],regionallist[cmd[1]] = regionallist[cmd[1]],regionallist[cmd[1]-1]
        refreshlist = true
      end
    when 2   # Swap dex down
      if cmd[1]>1
        regionallist[cmd[1]-2],regionallist[cmd[1]-1] = regionallist[cmd[1]-1],regionallist[cmd[1]-2]
        refreshlist = true
      end
    when 0
      if cmd[1]==0   # Add new dex
        cmd2 = pbMessage(_INTL("Fill in this new Dex?"),
           [_INTL("Leave blank"),_INTL("Fill with National Dex"),_INTL("Cancel")],3)
        if cmd2<2
          newdex = [nil]
          if cmd2==1   # Fill with National Dex
            for i in 1...PBSpecies.maxValue
              newdex[i] = i
            end
          end
          regionallist[regionallist.length] = newdex
          refreshlist = true
        end
      elsif cmd[1]>0   # Edit a dex
        cmd2 = pbMessage(_INTL("\\ts[]Do what with this Dex?"),
            [_INTL("Edit"),_INTL("Copy"),_INTL("Delete"),_INTL("Cancel")],4)
        case cmd2
        when 0   # Edit
          regionallist[cmd[1]-1] = pbRegionalDexEditor(regionallist[cmd[1]-1])
          refreshlist = true
        when 1   # Copy
          regionallist[regionallist.length] = regionallist[cmd[1]-1].clone
          cmd[1] = regionallist.length
          refreshlist = true
        when 2   # Delete
          regionallist[cmd[1]-1] = nil
          regionallist.compact!
          cmd[1] = [cmd[1],regionallist.length].min
          refreshlist = true
        end
      else   # Cancel
        cmd2 = pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
        if cmd2==0
          # Save new dexes here
          tosave = []
          for i in 0...regionallist.length
            tosave[i] = []
            for j in 0...regionallist[i].length
              tosave[i][regionallist[i][j]] = j if regionallist[i][j]
            end
          end
          save_data(tosave,"Data/regional_dexes.dat")
          $PokemonTemp.regionalDexes = nil
          pbSavePokemonData
          pbMessage(_INTL("Data saved."))
          break
        elsif cmd2==1
          break
        end
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end

def pbAppendEvoToFamilyArray(species,array,seenarray)
  return if seenarray[species]
  array.push(species); seenarray[species] = true
  evos = pbGetEvolvedFormData(species)
  if evos.length>0
    evos.sort! { |a,b| a[2]<=>b[2] }
    subarray = []
    for i in evos
      pbAppendEvoToFamilyArray(i[2],subarray,seenarray)
    end
    array.push(subarray) if subarray.length>0
  end
end

def pbGetEvoFamilies
  seen = []
  ret = []
  for sp in 1..PBSpecies.maxValue
    species = pbGetBabySpecies(sp)
    next if seen[species]
    subret = []
    pbAppendEvoToFamilyArray(species,subret,seen)
    ret.push(subret.flatten) if subret.length>0
  end
  return ret
end

def pbEvoFamiliesToStrings
  ret = []
  families = pbGetEvoFamilies
  for fam in 0...families.length
    string = ""
    for p in 0...families[fam].length
      if p>=3
        string += " + #{families[fam].length-3} more"
        break
      end
      string += "/" if p>0
      string += PBSpecies.getName(families[fam][p])
    end
    ret[fam] = string
  end
  return ret
end



#===============================================================================
# Battle animations rearranger
#===============================================================================
def pbAnimationsOrganiser
  list = pbLoadBattleAnimations
  if !list || !list[0]
    pbMessage(_INTL("No animations exist."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.new(_INTL("Animations Organiser"))
  title.x        = 256
  title.y        = 0
  title.width    = Graphics.width-256
  title.height   = 64
  title.viewport = viewport
  title.z        = 2
  info = Window_AdvancedTextPokemon.new(_INTL("Z+Up/Down: Swap\nZ+Left: Delete\nZ+Right: Insert"))
  info.x        = 256
  info.y        = 64
  info.width    = Graphics.width-256
  info.height   = Graphics.height-64
  info.viewport = viewport
  info.z        = 2
  commands = []
  refreshlist = true; oldsel = -1
  cmd = [0,0]
  loop do
    if refreshlist
      commands = []
      for i in 0...list.length
        commands.push(sprintf("%d: %s",i,(list[i]) ? list[i].name : "???"))
      end
    end
    refreshlist = false; oldsel = -1
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    if cmd[0]==1   # Swap animation up
      if cmd[1]>=0 && cmd[1]<commands.length-1
        list[cmd[1]+1],list[cmd[1]] = list[cmd[1]],list[cmd[1]+1]
        refreshlist = true
      end
    elsif cmd[0]==2   # Swap animation down
      if cmd[1]>0
        list[cmd[1]-1],list[cmd[1]] = list[cmd[1]],list[cmd[1]-1]
        refreshlist = true
      end
    elsif cmd[0]==3   # Delete spot
      list.delete_at(cmd[1])
      cmd[1] = [cmd[1],list.length-1].min
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==4   # Insert spot
      list.insert(cmd[1],PBAnimation.new)
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==0
      cmd2 = pbMessage(_INTL("Save changes?"),
          [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd2==0 || cmd2==1
        if cmd2==0
          # Save animations here
          save_data(list,"Data/PkmnAnimations.rxdata")
          $PokemonTemp.battleAnims = nil
          pbMessage(_INTL("Data saved."))
        end
        break
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end
