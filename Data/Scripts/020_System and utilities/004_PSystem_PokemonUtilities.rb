#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  return ($Trainer.party.length==6 && $PokemonStorage.full?)
end

def pbNickname(pokemon)
  speciesname = PBSpecies.getName(pokemon.species)
  if pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?",speciesname))
    helptext = _INTL("{1}'s nickname?",speciesname)
    newname = pbEnterPokemonName(helptext,0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,"",pokemon)
    pokemon.name = newname if newname!=""
  end
end

def pbStorePokemon(pokemon)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pokemon)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      if creator
        pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
      else
        pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
    else
      if creator
        pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
      else
        pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
      end
      pbMessage(_INTL("It was stored in box \"{1}.\"",boxname))
    end
  end
end

def pbNicknameAndStore(pokemon)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbNickname(pokemon)
  pbStorePokemon(pokemon)
end



#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemon(pokemon,level=nil,seeform=true)
  return if !pokemon
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  speciesname = PBSpecies.getName(pokemon.species)
  pbMessage(_INTL("\\me[Pkmn get]{1} obtained {2}!\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || pbBoxesFull?
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end



#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pokemon,level=nil,seeform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  speciesname = PBSpecies.getName(pokemon.species)
  pbMessage(_INTL("\\me[Pkmn get]{1} obtained {2}!\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddToPartySilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
end

def pbAddForeignPokemon(pokemon,level=nil,ownerName=nil,nickname=nil,ownerGender=0,seeform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID==$Trainer.id
    pokemon.trainerID = $Trainer.getForeignID
    pokemon.ot        = ownerName if ownerName && ownerName!=""
    pokemon.otgender  = ownerGender
  end
  # Set nickname
  pokemon.name = nickname[0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE] if nickname && nickname!=""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1",$Trainer.name,ownerName))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1",$Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  return true
end

def pbGenerateEgg(pokemon,text="")
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,EGG_LEVEL)
  end
  # Get egg steps
  eggSteps = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesStepsToHatch)
  # Set egg's details
  pokemon.name       = _INTL("Egg")
  pokemon.eggsteps   = eggSteps
  pokemon.obtainText = text
  pokemon.calcStats
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg



#===============================================================================
# Removing Pokémon from the party (fails if trying to remove last able Pokémon)
#===============================================================================
def pbRemovePokemonAt(index)
  return false if index<0 || index>=$Trainer.party.length
  haveAble = false
  for i in 0...$Trainer.party.length
    next if i==index
    haveAble = true if $Trainer.party[i].hp>0 && !$Trainer.party[i].egg?
  end
  return false if !haveAble
  $Trainer.party.delete_at(index)
  return true
end



#===============================================================================
# Recording Pokémon forms as seen
#===============================================================================
def pbSeenForm(pkmn,gender=0,form=0)
  $Trainer.formseen     = [] if !$Trainer.formseen
  $Trainer.formlastseen = [] if !$Trainer.formlastseen
  if pkmn.is_a?(PokeBattle_Pokemon)
    gender  = pkmn.gender
    form    = (pkmn.form rescue 0)
    species = pkmn.species
  else
    species = getID(PBSpecies,pkmn)
  end
  return if !species || species<=0
  fSpecies = pbGetFSpeciesFromForm(species,form)
  species, form = pbGetSpeciesFromFSpecies(fSpecies)
  gender = 0 if gender>1
  dexForm = pbGetSpeciesData(species,form,SpeciesPokedexForm)
  form = dexForm if dexForm>0
  fSpecies = pbGetFSpeciesFromForm(species,form)
  formName = pbGetMessage(MessageTypes::FormNames,fSpecies)
  form = 0 if !formName || formName==""
  $Trainer.formseen[species] = [[],[]] if !$Trainer.formseen[species]
  $Trainer.formseen[species][gender][form] = true
  $Trainer.formlastseen[species] = [] if !$Trainer.formlastseen[species]
  $Trainer.formlastseen[species] = [gender,form] if $Trainer.formlastseen[species]==[]
end

def pbUpdateLastSeenForm(pkmn)
  $Trainer.formlastseen = [] if !$Trainer.formlastseen
  form = (pkmn.form rescue 0)
  dexForm = pbGetSpeciesData(pkmn.species,pkmn.form,SpeciesPokedexForm)
  form = dexForm if dexForm>0
  formName = pbGetMessage(MessageTypes::FormNames,pkmn.fSpecies)
  form = 0 if !formName || formName==""
  $Trainer.formlastseen[pkmn.species] = [] if !$Trainer.formlastseen[pkmn.species]
  $Trainer.formlastseen[pkmn.species] = [pkmn.gender,form]
end



#===============================================================================
# Choose a Pokémon in the party
#===============================================================================
# Choose a Pokémon/egg from the party.
# Stores result in variable _variableNumber_ and the chosen Pokémon's name in
# variable _nameVarNumber_; result is -1 if no Pokémon was chosen
def pbChoosePokemon(variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    if ableProc
      chosen=screen.pbChooseAblePokemon(ableProc,allowIneligible)
    else
      screen.pbStartScene(_INTL("Choose a Pokémon."),false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbChooseNonEggPokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc { |pkmn| !pkmn.egg? })
end

def pbChooseAblePokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc { |pkmn| !pkmn.egg? && pkmn.hp>0 })
end

# Same as pbChoosePokemon, but prevents choosing an egg or a Shadow Pokémon.
def pbChooseTradablePokemon(variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    if ableProc
      chosen=screen.pbChooseTradablePokemon(ableProc,allowIneligible)
    else
      screen.pbStartScene(_INTL("Choose a Pokémon."),false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end


def pbChoosePokemonForTrade(variableNumber,nameVarNumber,wanted)
  wanted = getID(PBSpecies,wanted)
  pbChooseTradablePokemon(variableNumber,nameVarNumber,proc { |pkmn|
    next pkmn.species==wanted
  })
end



#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variableNumber)
  for i in 0...$Trainer.party.length
    p = $Trainer.party[i]
    if p && !p.egg? && p.hp>0
      pbSet(variableNumber,i)
      return $Trainer.party[i]
    end
  end
  pbSet(variableNumber,-1)
  return nil
end

# Checks whether the player would still have an unfainted Pokémon if the
# Pokémon given by _pokemonIndex_ were removed from the party.
def pbCheckAble(pokemonIndex)
  for i in 0...$Trainer.party.length
    next if i==pokemonIndex
    p = $Trainer.party[i]
    return true if p && !p.egg? && p.hp>0
  end
  return false
end

# Returns true if there are no usable Pokémon in the player's party.
def pbAllFainted
  return $Trainer.ablePokemonCount==0
end

# Returns true if there is a Pokémon of the given species in the player's party.
# You may also specify a particular form it should be.
def pbHasSpecies?(species,form=-1)
  species = getID(PBSpecies,species)
  for pokemon in $Trainer.pokemonParty
    return true if pokemon.species==species && (form<0 || form==pokemon.form)
  end
  return false
end

# Returns true if there is a fatefully met Pokémon of the given species in the
# player's party.
def pbHasFatefulSpecies?(species)
  species = getID(PBSpecies,species)
  for pokemon in $Trainer.pokemonParty
    return true if pokemon.species==species && pokemon.obtainMode==4
  end
  return false
end

# Returns true if there is a Pokémon with the given type in the player's party.
def pbHasType?(type)
  type = getID(PBTypes,type)
  for pokemon in $Trainer.pokemonParty
    return true if pokemon.hasType?(type)
  end
  return false
end

# Checks whether any Pokémon in the party knows the given move, and returns
# the first Pokémon it finds with that move, or nil if no Pokémon has that move.
def pbCheckMove(move)
  move = getID(PBMoves,move)
  return nil if !move || move<=0
  for i in $Trainer.pokemonParty
    for j in i.moves
      return i if j.id==move
    end
  end
  return nil
end



#===============================================================================
# Fully heal all Pokémon in the party
#===============================================================================
def pbHealAll
  $Trainer.party.each { |pkmn| pkmn.heal }
end



#===============================================================================
# Return a level value based on Pokémon in a party
#===============================================================================
def pbBalancedLevel(party)
  return 1 if party.length==0
  # Calculate the mean of all levels
  sum = 0
  party.each { |p| sum += p.level }
  return 1 if sum==0
  mLevel = PBExperience.maxLevel
  average = sum.to_f/party.length.to_f
  # Calculate the standard deviation
  varianceTimesN = 0
  for i in 0...party.length
    deviation = party[i].level-average
    varianceTimesN += deviation*deviation
  end
  # NOTE: This is the "population" standard deviation calculation, since no
  # sample is being taken.
  stdev = Math.sqrt(varianceTimesN/party.length)
  mean = 0
  weights = []
  # Skew weights according to standard deviation
  for i in 0...party.length
    weight = party[i].level.to_f/sum.to_f
    if weight<0.5
      weight -= (stdev/mLevel.to_f)
      weight = 0.001 if weight<=0.001
    else
      weight += (stdev/mLevel.to_f)
      weight = 0.999 if weight>=0.999
    end
    weights.push(weight)
  end
  weightSum = 0
  weights.each { |w| weightSum += w }
  # Calculate the weighted mean, assigning each weight to each level's
  # contribution to the sum
  for i in 0...party.length
    mean += party[i].level*weights[i]
  end
  mean /= weightSum
  # Round to nearest number
  mean = mean.round
  # Adjust level to minimum
  mean = 1 if mean<1
  # Add 2 to the mean to challenge the player
  mean += 2
  # Adjust level to maximum
  mean = mLevel if mean>mLevel
  return mean
end



#===============================================================================
# Calculates a Pokémon's size (in millimeters)
#===============================================================================
def pbSize(pkmn)
  baseheight = pbGetSpeciesData(pkmn.species,pkmn.form,SpeciesHeight)
  hpiv = pkmn.iv[0]&15
  ativ = pkmn.iv[1]&15
  dfiv = pkmn.iv[2]&15
  spiv = pkmn.iv[3]&15
  saiv = pkmn.iv[4]&15
  sdiv = pkmn.iv[5]&15
  m = pkmn.personalID&0xFF
  n = (pkmn.personalID>>8)&0xFF
  s = (((ativ^dfiv)*hpiv)^m)*256+(((saiv^sdiv)*spiv)^n)
  xyz = []
  if s<10;       xyz = [ 290,   1,     0]
  elsif s<110;   xyz = [ 300,   1,    10]
  elsif s<310;   xyz = [ 400,   2,   110]
  elsif s<710;   xyz = [ 500,   4,   310]
  elsif s<2710;  xyz = [ 600,  20,   710]
  elsif s<7710;  xyz = [ 700,  50,  2710]
  elsif s<17710; xyz = [ 800, 100,  7710]
  elsif s<32710; xyz = [ 900, 150, 17710]
  elsif s<47710; xyz = [1000, 150, 32710]
  elsif s<57710; xyz = [1100, 100, 47710]
  elsif s<62710; xyz = [1200,  50, 57710]
  elsif s<64710; xyz = [1300,  20, 62710]
  elsif s<65210; xyz = [1400,   5, 64710]
  elsif s<65410; xyz = [1500,   2, 65210]
  else;          xyz = [1700,   1, 65510]
  end
  return (((s-xyz[2])/xyz[1]+xyz[0]).floor*baseheight/10).floor
end



#===============================================================================
# Returns true if the given species can be legitimately obtained as an egg
#===============================================================================
def pbHasEgg?(species)
  species = getID(PBSpecies,species)
  return false if !species
  # species may be unbreedable, so check its evolution's compatibilities
  evoSpecies = pbGetEvolvedFormData(species,true)
  compatSpecies = (evoSpecies && evoSpecies[0]) ? evoSpecies[0][2] : species
  compat = pbGetSpeciesData(compatSpecies,0,SpeciesCompatibility)
  compat = [compat] if !compat.is_a?(Array)
  return false if compat.include?(getConst(PBEggGroups,:Undiscovered))
  return false if compat.include?(getConst(PBEggGroups,:Ditto))
  baby = pbGetBabySpecies(species)
  return true if species==baby   # Is a basic species
  baby = pbGetBabySpecies(species,0,0)
  return true if species==baby   # Is an egg species without incense
  return false
end
