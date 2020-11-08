#===============================================================================
# Trainer data
#===============================================================================
module TrainerData
  SPECIES   = 0
  LEVEL     = 1
  ITEM      = 2
  MOVES     = 3
  ABILITY   = 4
  GENDER    = 5
  FORM      = 6
  SHINY     = 7
  NATURE    = 8
  IV        = 9
  HAPPINESS = 10
  NAME      = 11
  SHADOW    = 12
  BALL      = 13
  EV        = 14
  LOSETEXT  = 15

  SCHEMA = {
    "Items"     => [0,         "eEEEEEEE", :Item, :Item, :Item, :Item,
                                           :Item, :Item, :Item, :Item],
    "Pokemon"   => [SPECIES,   "ev", :PBSpecies, nil],   # Species, level
    "Item"      => [ITEM,      "e", :Item],
    "Moves"     => [MOVES,     "eEEE", :PBMoves, :PBMoves, :PBMoves, :PBMoves],
    "Ability"   => [ABILITY,   "u"],
    "Gender"    => [GENDER,    "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
    "Form"      => [FORM,      "u"],
    "Shiny"     => [SHINY,     "b"],
    "Nature"    => [NATURE,    "e", :PBNatures],
    "IV"        => [IV,        "uUUUUU"],
    "Happiness" => [HAPPINESS, "u"],
    "Name"      => [NAME,      "s"],
    "Shadow"    => [SHADOW,    "b"],
    "Ball"      => [BALL,      "u"],
    "EV"        => [EV,        "uUUUUU"],
    "LoseText"  => [LOSETEXT,  "s"]
  }
end

#===============================================================================
#
#===============================================================================
def pbLoadTrainer(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  success = false
  items = []
  party = []
  opponent = nil
  trainers = pbLoadTrainersData
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    thispartyid   = trainer[4]
    next if thistrainerid!=trainerid || name!=trainername || thispartyid!=partyid
    # Found the trainer we want, load it up
    items = trainer[2].clone
    name = pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVAL_NAMES
      next if !isConst?(trainerid,PBTrainers,i[0]) || !$game_variables[i[1]].is_a?(String)
      name = $game_variables[i[1]]
      break
    end
    loseText = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    opponent = PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer)
    # Load up each Pokémon in the trainer's party
    for poke in trainer[3]
      species = pbGetSpeciesFromFSpecies(poke[TrainerData::SPECIES])[0]
      level = poke[TrainerData::LEVEL]
      pokemon = Pokemon.new(species,level,opponent,false)
      if poke[TrainerData::FORM]
        pokemon.forcedForm = poke[TrainerData::FORM] if MultipleForms.hasFunction?(pokemon.species,"getForm")
        pokemon.formSimple = poke[TrainerData::FORM]
      end
      pokemon.setItem(poke[TrainerData::ITEM])
      if poke[TrainerData::MOVES] && poke[TrainerData::MOVES].length>0
        for move in poke[TrainerData::MOVES]
          pokemon.pbLearnMove(move)
        end
      else
        pokemon.resetMoves
      end
      pokemon.setAbility(poke[TrainerData::ABILITY] || 0)
      g = (poke[TrainerData::GENDER]) ? poke[TrainerData::GENDER] : (opponent.female?) ? 1 : 0
      pokemon.setGender(g)
      (poke[TrainerData::SHINY]) ? pokemon.makeShiny : pokemon.makeNotShiny
      n = (poke[TrainerData::NATURE]) ? poke[TrainerData::NATURE] : (pokemon.species+opponent.trainertype)%(PBNatures.maxValue+1)
      pokemon.setNature(n)
      for i in 0...6
        if poke[TrainerData::IV] && poke[TrainerData::IV].length>0
          pokemon.iv[i] = (i<poke[TrainerData::IV].length) ? poke[TrainerData::IV][i] : poke[TrainerData::IV][0]
        else
          pokemon.iv[i] = [level/2, Pokemon::IV_STAT_LIMIT].min
        end
        if poke[TrainerData::EV] && poke[TrainerData::EV].length>0
          pokemon.ev[i] = (i<poke[TrainerData::EV].length) ? poke[TrainerData::EV][i] : poke[TrainerData::EV][0]
        else
          pokemon.ev[i] = [level*3/2, Pokemon::EV_LIMIT/6].min
        end
      end
      pokemon.happiness = poke[TrainerData::HAPPINESS] if poke[TrainerData::HAPPINESS]
      pokemon.name = poke[TrainerData::NAME] if poke[TrainerData::NAME] && poke[TrainerData::NAME]!=""
      if poke[TrainerData::SHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused = poke[TrainerData::BALL] if poke[TrainerData::BALL]
      pokemon.calcStats
      party.push(pokemon)
    end
    success = true
    break
  end
  return success ? [opponent,items,party,loseText] : nil
end

def pbConvertTrainerData
  data = pbLoadTrainerTypesData
  trainertypes = []
  for i in 0...data.length
    record = data[i]
    trainertypes[record[0]] = record[2] if record
  end
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainertypes)
  pbSaveTrainerTypes
  pbSaveTrainerBattles
end

def pbNewTrainer(trainerid,trainername,trainerparty,savechanges=true)
  pokemon = []
  for i in 0...6
    if i==0
      pbMessage(_INTL("Please enter the first Pokémon.",i))
    else
      break if !pbConfirmMessage(_INTL("Add another Pokémon?"))
    end
    loop do
      species = pbChooseSpeciesList
      if species<=0
        break if i>0
        pbMessage(_INTL("This trainer must have at least 1 Pokémon!"))
      else
        params = ChooseNumberParams.new
        params.setRange(1,PBExperience.maxLevel)
        params.setDefaultValue(10)
        level = pbMessageChooseNumber(_INTL("Set the level for {1} (max. #{PBExperience.maxLevel}).",
           PBSpecies.getName(species)),params)
        pokemon.push([species,level])
        break
      end
    end
  end
  trainer = [trainerid,trainername,[],pokemon,trainerparty]
  if savechanges
    data = pbLoadTrainersData
    data.push(trainer)
    save_data(data,"Data/trainers.dat")
    $PokemonTemp.trainersData = nil
    pbConvertTrainerData
    pbMessage(_INTL("The Trainer's data was added to the list of battles and in PBS/trainers.txt."))
  end
  return trainer
end

def pbTrainerTypeCheck(symbol)
  return true if !$DEBUG
  ret = false
  if hasConst?(PBTrainers,symbol)
    trtype = PBTrainers.const_get(symbol)
    data = pbGetTrainerTypeData(trtype)
    ret = true if data
  end
  if !ret
    if pbConfirmMessage(_INTL("Add new trainer type {1}?",symbol))
      pbTrainerTypeEditorNew(symbol.to_s)
    end
    pbMapInterpreter.command_end if pbMapInterpreter
  end
  return ret
end

def pbGetFreeTrainerParty(trainerid,trainername)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  trainers = pbLoadTrainersData
  usedparties = []
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    next if thistrainerid!=trainerid || name!=trainername
    usedparties.push(trainer[4])
  end
  ret = -1
  for i in 0...256
    next if usedparties.include?(i)
    ret = i
    break
  end
  return ret
end

def pbTrainerCheck(trainerid,trainername,maxbattles,startBattleId=0)
  return true if !$DEBUG
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    pbTrainerTypeCheck(trainerid)
    return false if !hasConst?(PBTrainers,trainerid)
    trainerid = PBTrainers.const_get(trainerid)
  end
  for i in 0...maxbattles
    trainer = pbLoadTrainer(trainerid,trainername,i+startBattleId)
    next if trainer
    traineridstring = "#{trainerid}"
    traineridstring = getConstantName(PBTrainers,trainerid) rescue "-"
    if pbConfirmMessage(_INTL("Add new battle {1} (of {2}) for ({3}, {4})?",
       i+1,maxbattles,traineridstring,trainername))
      pbNewTrainer(trainerid,trainername,i)
    end
  end
  return true
end

def pbMissingTrainer(trainerid, trainername, trainerparty)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  traineridstring = getConstantName(PBTrainers,trainerid) rescue "#{trainerid}"
  if !$DEBUG
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})",traineridstring,trainername,trainerparty)
  end
	message = ""
  if trainerparty!=0
    message = (_INTL("Add new trainer ({1}, {2}, ID {3})?",traineridstring,trainername,trainerparty))
  else
    message = (_INTL("Add new trainer ({1}, {2})?",traineridstring,trainername))
  end
  cmd = pbMessage(message,[_INTL("Yes"),_INTL("No")],2)
  if cmd==0
    pbNewTrainer(trainerid,trainername,trainerparty)
  end
  return cmd
end



#===============================================================================
# Walking charset, for use in text entry screens and load game screen
#===============================================================================
class TrainerWalkingCharSprite < SpriteWrapper
  def initialize(charset,viewport=nil)
    super(viewport)
    @animbitmap = nil
    self.charset = charset
    @animframe      = 0   # Current pattern
    @frame          = 0   # Frame counter
    self.animspeed  = 5   # Animation speed (frames per pattern)
  end

  def charset=(value)
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    bitmapFileName = sprintf("Graphics/Characters/%s",value)
    @charset = pbResolveBitmap(bitmapFileName)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0,0,self.bitmap.width/4,self.bitmap.height/4)
    else
      self.bitmap = nil
    end
  end

  def altcharset=(value)   # Used for box icon in the naming screen
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    @charset = pbResolveBitmap(value)
    if @charset
      @animbitmap = AnimatedBitmap.new(@charset)
      self.bitmap = @animbitmap.bitmap
      self.src_rect.set(0,0,self.bitmap.width/4,self.bitmap.height)
    else
      self.bitmap = nil
    end
  end

  def animspeed=(value)
    @frameskip = value*Graphics.frame_rate/40
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
    end
    @frame += 1
    if @frame>=@frameskip
      @animframe = (@animframe+1)%4
      self.src_rect.x = @animframe*@animbitmap.bitmap.width/4
      @frame -= @frameskip
    end
    @updating = false
  end
end
