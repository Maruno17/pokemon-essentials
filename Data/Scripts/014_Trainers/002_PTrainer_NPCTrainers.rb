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
    "Moves"     => [MOVES,     "eEEE", :Move, :Move, :Move, :Move],
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
def pbLoadTrainer(tr_type, tr_name, tr_id = 0)
  if !GameData::TrainerType.exists?(tr_type)
    raise _INTL("Trainer type {1} does not exist.", tr_type)
  end
  tr_type = GameData::TrainerType.get(tr_type).id
  success = false
  items = []
  party = []
  opponent = nil
  trainers = pbLoadTrainersData
  for trainer in trainers
    next if trainer[0] != tr_type || trainer[1] != tr_name || trainer[4] != tr_id
    # Found the trainer we want, load it up
    items = trainer[2].clone
    tr_name = pbGetMessageFromHash(MessageTypes::TrainerNames, tr_name)
    for i in RIVAL_NAMES
      next if i[0] != tr_type || !$game_variables[i[1]].is_a?(String)
      tr_name = $game_variables[i[1]]
      break
    end
    loseText = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    opponent = PokeBattle_Trainer.new(tr_name, tr_type)
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
      if poke[TrainerData::NATURE]
        n = poke[TrainerData::NATURE]
      else
        n = (pokemon.species + GameData::TrainerType.get(opponent.trainertype).id_number) % (PBNatures.maxValue + 1)
      end
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
  tr_type_names = []
  GameData::TrainerType.each do |t|
    tr_type_names[t.id_number] = t.real_name
  end
  MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
  pbSaveTrainerTypes
  pbSaveTrainerBattles
end

def pbNewTrainer(tr_type, tr_name, tr_id, savechanges = true)
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
  trainer = [tr_type,tr_name,[],pokemon,tr_id]
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

def pbTrainerTypeCheck(trainer_type)
  return true if !$DEBUG
  return true if GameData::TrainerType.exists?(trainer_type)
  if pbConfirmMessage(_INTL("Add new trainer type {1}?", trainer_type.to_s))
    pbTrainerTypeEditorNew(trainer_type.to_s)
  end
  pbMapInterpreter.command_end if pbMapInterpreter
  return false
end

def pbGetFreeTrainerParty(tr_type, tr_name)
  if !GameData::TrainerType.exists?(tr_type)
    raise _INTL("Trainer type {1} does not exist.", tr_type)
  end
  tr_type = GameData::TrainerType.get(tr_type).id
  trainers = pbLoadTrainersData
  used_ids = []
  for trainer in trainers
    next if trainer[0] != tr_type || trainer[1] != tr_name
    used_ids.push(trainer[4])
  end
  for i in 0...256
    return i if !used_ids.include?(i)
  end
  return -1
end

# Called from trainer events to ensure the trainer exists
def pbTrainerCheck(tr_type, tr_name, max_battles, tr_id = 0)
  return true if !$DEBUG
  # Check for existence of trainer type
  pbTrainerTypeCheck(tr_type)
  return false if !GameData::TrainerType.exists?(tr_type)
  tr_type = GameData::TrainerType.get(tr_type).id
  # Check for existence of trainer with given ID number
  return true if pbLoadTrainer(tr_type, tr_name, tr_id)
  # Add new trainer
  if pbConfirmMessage(_INTL("Add new trainer variant {1} (of {2}) for {3} {4}?",
     tr_id, max_battles, tr_type.to_s, tr_name))
    pbNewTrainer(tr_type, tr_name, tr_id)
  end
  return true
end

def pbMissingTrainer(tr_type, tr_name, tr_id)
  if !GameData::TrainerType.exists?(tr_type)
    raise _INTL("Trainer type {1} does not exist.", tr_type)
  end
  tr_type = GameData::TrainerType.get(tr_type).id
  if !$DEBUG
    raise _INTL("Can't find trainer ({1}, {2}, ID {3})", tr_type.to_s, tr_name, tr_id)
  end
	message = ""
  if tr_id != 0
    message = _INTL("Add new trainer ({1}, {2}, ID {3})?", tr_type.to_s, tr_name, tr_id)
  else
    message = _INTL("Add new trainer ({1}, {2})?", tr_type.to_s, tr_name)
  end
  cmd = pbMessage(message, [_INTL("Yes"), _INTL("No")], 2)
  if cmd == 0
    pbNewTrainer(tr_type, tr_name, tr_id)
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
