#===============================================================================
# Query information about Pokémon in the Day Care.
#===============================================================================
# Returns the number of Pokémon in the Day Care.
def pbDayCareDeposited
  ret = 0
  for i in 0...2
    ret += 1 if $PokemonGlobal.daycare[i][0]
  end
  return ret
end

# Get name/cost info of a particular Pokémon in the Day Care.
def pbDayCareGetDeposited(index,nameVariable,costVariable)
  pkmn = $PokemonGlobal.daycare[index][0]
  return false if !pkmn
  cost = pbDayCareGetCost(index)
  $game_variables[nameVariable] = pkmn.name if nameVariable>=0
  $game_variables[costVariable] = cost if costVariable>=0
end

# Get name/levels gained info of a particular Pokémon in the Day Care.
def pbDayCareGetLevelGain(index,nameVariable,levelVariable)
  pkmn = $PokemonGlobal.daycare[index][0]
  return false if !pkmn
  $game_variables[nameVariable]  = pkmn.name
  $game_variables[levelVariable] = pkmn.level-$PokemonGlobal.daycare[index][1]
  return true
end

def pbDayCareGetCost(index)
  pkmn = $PokemonGlobal.daycare[index][0]
  return 0 if !pkmn
  cost = pkmn.level-$PokemonGlobal.daycare[index][1]+1
  cost *= 100
  return cost
end

# Returns whether an egg is waiting to be collected.
def pbEggGenerated?
  return false if pbDayCareDeposited!=2
  return $PokemonGlobal.daycareEgg==1
end



#===============================================================================
# Manipulate Pokémon in the Day Care.
#===============================================================================
def pbDayCareDeposit(index)
  for i in 0...2
    next if $PokemonGlobal.daycare[i][0]
    $PokemonGlobal.daycare[i][0] = $Trainer.party[index]
    $PokemonGlobal.daycare[i][1] = $Trainer.party[index].level
    $PokemonGlobal.daycare[i][0].heal
    $Trainer.party[index] = nil
    $Trainer.party.compact!
    $PokemonGlobal.daycareEgg      = 0
    $PokemonGlobal.daycareEggSteps = 0
    return
  end
  raise _INTL("No room to deposit a Pokémon")
end

def pbDayCareWithdraw(index)
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the Pokémon...")
  else
    $Trainer.party[$Trainer.party.length] = $PokemonGlobal.daycare[index][0]
    $PokemonGlobal.daycare[index][0] = nil
    $PokemonGlobal.daycare[index][1] = 0
    $PokemonGlobal.daycareEgg = 0
  end
end

def pbDayCareChoose(text,variable)
  count = pbDayCareDeposited
  if count==0
    raise _INTL("There's no Pokémon here...")
  elsif count==1
    $game_variables[variable] = ($PokemonGlobal.daycare[0][0]) ? 0 : 1
  else
    choices = []
    for i in 0...2
      pokemon = $PokemonGlobal.daycare[i][0]
      if pokemon.male?
        choices.push(_ISPRINTF("{1:s} (♂, Lv.{2:d})",pokemon.name,pokemon.level))
      elsif pokemon.female?
        choices.push(_ISPRINTF("{1:s} (♀, Lv.{2:d})",pokemon.name,pokemon.level))
      else
        choices.push(_ISPRINTF("{1:s} (Lv.{2:d})",pokemon.name,pokemon.level))
      end
    end
    choices.push(_INTL("CANCEL"))
    command = pbMessage(text,choices,choices.length)
    $game_variables[variable] = (command==2) ? -1 : command
  end
end



#===============================================================================
# Check compatibility of Pokémon in the Day Care.
#===============================================================================
def pbIsDitto?(pkmn)
  compat = pbGetSpeciesData(pkmn.species,pkmn.form,SpeciesCompatibility)
  if compat.is_a?(Array)
    return compat.include?(getConst(PBEggGroups,:Ditto))
  end
  return compat && isConst?(compat,PBEggGroups,:Ditto)
end

def pbDayCareCompatibleGender(pkmn1,pkmn2)
  return true if pkmn1.female? && pkmn2.male?
  return true if pkmn1.male? && pkmn2.female?
  ditto1 = pbIsDitto?(pkmn1)
  ditto2 = pbIsDitto?(pkmn2)
  return true if ditto1 && !ditto2
  return true if ditto2 && !ditto1
  return false
end

def pbDayCareGetCompat
  return 0 if pbDayCareDeposited!=2
  pkmn1 = $PokemonGlobal.daycare[0][0]
  pkmn2 = $PokemonGlobal.daycare[1][0]
  return 0 if pkmn1.shadowPokemon?
  return 0 if pkmn2.shadowPokemon?
  # Insert code here if certain forms of certain species cannot breed
  compat1 = pbGetSpeciesData(pkmn1.species,pkmn1.form,SpeciesCompatibility)
  if compat1.is_a?(Array)
    compat10 = compat1[0] || 0
    compat11 = compat1[1] || compat10
  else
    compat10 = compat11 = compat || 0
  end
  compat2 = pbGetSpeciesData(pkmn2.species,pkmn2.form,SpeciesCompatibility)
  if compat2.is_a?(Array)
    compat20 = compat2[0] || 0
    compat21 = compat2[1] || compat20
  else
    compat20 = compat21 = compat || 0
  end
  return 0 if isConst?(compat10,PBEggGroups,:Undiscovered) ||
              isConst?(compat11,PBEggGroups,:Undiscovered) ||
              isConst?(compat20,PBEggGroups,:Undiscovered) ||
              isConst?(compat21,PBEggGroups,:Undiscovered)
  if compat10==compat20 || compat11==compat20 ||
     compat10==compat21 || compat11==compat21 ||
     isConst?(compat10,PBEggGroups,:Ditto) ||
     isConst?(compat11,PBEggGroups,:Ditto) ||
     isConst?(compat20,PBEggGroups,:Ditto) ||
     isConst?(compat21,PBEggGroups,:Ditto)
    if pbDayCareCompatibleGender(pkmn1,pkmn2)
      ret = 1
      ret += 1 if pkmn1.species==pkmn2.species
      ret += 1 if pkmn1.trainerID!=pkmn2.trainerID
      return ret
    end
  end
  return 0
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable] = pbDayCareGetCompat
end



#===============================================================================
# Generate an Egg based on Pokémon in the Day Care.
#===============================================================================
def pbDayCareGenerateEgg
  return if pbDayCareDeposited!=2
  raise _INTL("Can't store the egg") if $Trainer.party.length>=6
  pokemon0 = $PokemonGlobal.daycare[0][0]
  pokemon1 = $PokemonGlobal.daycare[1][0]
  mother = nil
  father = nil
  babyspecies = 0
  ditto0 = pbIsDitto?(pokemon0)
  ditto1 = pbIsDitto?(pokemon1)
  if pokemon0.female? || ditto0
    babyspecies = (ditto0) ? pokemon1.species : pokemon0.species
    mother = pokemon0
    father = pokemon1
  else
    babyspecies = (ditto1) ? pokemon0.species : pokemon1.species
    mother = pokemon1
    father = pokemon0
  end
  # Determine the egg's species
  babyspecies = pbGetBabySpecies(babyspecies,mother.item,father.item)
  if isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies = getConst(PBSpecies,:PHIONE)
  elsif (isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)) ||
        (isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE))
    babyspecies = [getConst(PBSpecies,:NIDORANmA),
                   getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)) ||
        (isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT))
    babyspecies = [getConst(PBSpecies,:VOLBEAT),
                   getConst(PBSpecies,:ILLUMISE)][rand(2)]
  end
  # Generate egg
  egg = pbNewPkmn(babyspecies,EGG_LEVEL)
  # Randomise personal ID
  pid = rand(65536)
  pid |= (rand(65536)<<16)
  egg.personalID = pid
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) ||
     isConst?(babyspecies,PBSpecies,:SHELLOS) ||
     isConst?(babyspecies,PBSpecies,:BASCULIN) ||
     isConst?(babyspecies,PBSpecies,:FLABEBE) ||
     isConst?(babyspecies,PBSpecies,:PUMPKABOO) ||
     isConst?(babyspecies,PBSpecies,:ORICORIO) ||
     isConst?(babyspecies,PBSpecies,:ROCKRUFF) ||
     isConst?(babyspecies,PBSpecies,:MINIOR)
    newForm = mother.form
    newForm = 0 if mother.isSpecies?(:MOTHIM)
    egg.form = newForm
  end
  # Inheriting Alolan form
  if isConst?(babyspecies,PBSpecies,:RATTATA) ||
     isConst?(babyspecies,PBSpecies,:SANDSHREW) ||
     isConst?(babyspecies,PBSpecies,:VULPIX) ||
     isConst?(babyspecies,PBSpecies,:DIGLETT) ||
     isConst?(babyspecies,PBSpecies,:MEOWTH) ||
     isConst?(babyspecies,PBSpecies,:GEODUDE) ||
     isConst?(babyspecies,PBSpecies,:GRIMER)
    if mother.form==1
      egg.form = 1 if mother.hasItem?(:EVERSTONE)
    elsif pbGetBabySpecies(father.species,mother.item,father.item)==babyspecies
      egg.form = 1 if father.form==1 && father.hasItem?(:EVERSTONE)
    end
  end
  # Inheriting Moves
  moves = []
  othermoves = []
  movefather = father; movemother = mother
  if pbIsDitto?(movefather) && !mother.female?
    movefather = mother; movemother = father
  end
  # Initial Moves
  initialmoves = egg.getMoveList
  for k in initialmoves
    if k[0]<=EGG_LEVEL
      moves.push(k[1])
    else
      next if !mother.hasMove?(k[1]) || !father.hasMove?(k[1])
      othermoves.push(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  if !NEWEST_BATTLE_MECHANICS
    itemsData = pbLoadItemsData
    for i in 0...itemsData.length
      next if !itemsData[i]
      atk = itemsData[i][ITEM_MACHINE]
      next if !atk || atk==0
      next if !egg.compatibleWithMove?(atk)
      next if !movefather.hasMove?(atk)
      moves.push(atk)
    end
  end
  # Inheriting Egg Moves
  babyEggMoves = pbGetSpeciesEggMoves(egg.species,egg.form)
  if movefather.male?
    babyEggMoves.each { |m| moves.push(m) if movefather.hasMove?(m) }
  end
  if NEWEST_BATTLE_MECHANICS
    babyEggMoves.each { |m| moves.push(m) if movemother.hasMove?(m) }
  end
  # Volt Tackle
  lightball = false
  if (father.isSpecies?(:PIKACHU) || father.isSpecies?(:RAICHU)) &&
      father.hasItem?(:LIGHTBALL)
    lightball = true
  end
  if (mother.isSpecies?(:PIKACHU) || mother.isSpecies?(:RAICHU)) &&
      mother.hasItem?(:LIGHTBALL)
    lightball = true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  moves = moves.reverse
  moves |= []   # remove duplicates
  moves = moves.reverse
  # Assembling move list
  finalmoves = []
  listend = moves.length-4
  listend = 0 if listend<0
  for i in listend...listend+4
    moveid = (i>=moves.length) ? 0 : moves[i]
    finalmoves[finalmoves.length] = PBMove.new(moveid)
  end
  # Inheriting Individual Values
  ivs = []
  for i in 0...6
    ivs[i] = rand(32)
  end
  ivinherit = []
  for i in 0...2
    parent = [mother,father][i]
    ivinherit[i] = PBStats::HP if parent.hasItem?(:POWERWEIGHT)
    ivinherit[i] = PBStats::ATTACK if parent.hasItem?(:POWERBRACER)
    ivinherit[i] = PBStats::DEFENSE if parent.hasItem?(:POWERBELT)
    ivinherit[i] = PBStats::SPATK if parent.hasItem?(:POWERLENS)
    ivinherit[i] = PBStats::SPDEF if parent.hasItem?(:POWERBAND)
    ivinherit[i] = PBStats::SPEED if parent.hasItem?(:POWERANKLET)
  end
  num = 0; r = rand(2)
  2.times do
    if ivinherit[r]!=nil
      parent = [mother,father][r]
      ivs[ivinherit[r]] = parent.iv[ivinherit[r]]
      num += 1
      break
    end
    r = (r+1)%2
  end
  limit = (NEWEST_BATTLE_MECHANICS && (mother.hasItem?(:DESTINYKNOT) ||
           father.hasItem?(:DESTINYKNOT))) ? 5 : 3
  loop do
    freestats = []
    PBStats.eachStat { |s| freestats.push(s) if !ivinherit.include?(s) }
    break if freestats.length==0
    r = freestats[rand(freestats.length)]
    parent = [mother,father][rand(2)]
    ivs[r] = parent.iv[r]
    ivinherit.push(r)
    num += 1
    break if num>=limit
  end
  # Inheriting nature
  newnatures = []
  newnatures.push(mother.nature) if mother.hasItem?(:EVERSTONE)
  newnatures.push(father.nature) if father.hasItem?(:EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries = 0
  shinyretries += 5 if father.language!=mother.language
  shinyretries += 2 if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
  if shinyretries>0
    shinyretries.times do
      break if egg.shiny?
      egg.personalID = rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
  if !ditto0 && !ditto1
    if mother.hasHiddenAbility?
      egg.setAbility(mother.abilityIndex) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex)
      else
        egg.setAbility((mother.abilityIndex+1)%2)
      end
    end
  elsif !(ditto0 && ditto1) && NEWEST_BATTLE_MECHANICS
    parent = (!ditto0) ? mother : father
    if parent.hasHiddenAbility?
      egg.setAbility(parent.abilityIndex) if rand(10)<6
    end
  end
  # Inheriting Poké Ball from the mother
  if mother.female? &&
     !isConst?(pbBallTypeToItem(mother.ballused),PBItems,:MASTERBALL) &&
     !isConst?(pbBallTypeToItem(mother.ballused),PBItems,:CHERISHBALL)
    egg.ballused = mother.ballused
  end
  # Set all stats
  egg.happiness = 120
  egg.iv[0] = ivs[0]
  egg.iv[1] = ivs[1]
  egg.iv[2] = ivs[2]
  egg.iv[3] = ivs[3]
  egg.iv[4] = ivs[4]
  egg.iv[5] = ivs[5]
  egg.moves[0] = finalmoves[0]
  egg.moves[1] = finalmoves[1]
  egg.moves[2] = finalmoves[2]
  egg.moves[3] = finalmoves[3]
  egg.calcStats
  egg.obtainText = _INTL("Day-Care Couple")
  egg.name = _INTL("Egg")
  eggSteps = pbGetSpeciesData(babyspecies,egg.form,SpeciesStepsToHatch)
  egg.eggsteps = eggSteps
  egg.givePokerus if rand(65536)<POKERUS_CHANCE
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = egg
end



#===============================================================================
# Code that happens every step the player takes.
#===============================================================================
Events.onStepTaken += proc { |_sender,_e|
  # Make an egg available at the Day Care
  deposited = pbDayCareDeposited
  if deposited==2 && $PokemonGlobal.daycareEgg==0
    $PokemonGlobal.daycareEggSteps = 0 if !$PokemonGlobal.daycareEggSteps
    $PokemonGlobal.daycareEggSteps += 1
    if $PokemonGlobal.daycareEggSteps==256
      $PokemonGlobal.daycareEggSteps = 0
      compatval = [0,20,50,70][pbDayCareGetCompat]
      if hasConst?(PBItems,:OVALCHARM) && $PokemonBag.pbHasItem?(:OVALCHARM)
        compatval = [0,40,80,88][pbDayCareGetCompat]
      end
      $PokemonGlobal.daycareEgg = 1 if rand(100)<compatval   # Egg is generated
    end
  end
  # Day Care Pokémon gain Exp/moves
  for i in 0...2
    pkmn = $PokemonGlobal.daycare[i][0]
    next if !pkmn
    maxexp = PBExperience.pbGetMaxExperience(pkmn.growthrate)
    next if pkmn.exp>=maxexp
    oldlevel = pkmn.level
    pkmn.exp += 1   # Gain Exp
    next if pkmn.level==oldlevel
    pkmn.calcStats
    movelist = pkmn.getMoveList
    for i in movelist
      pkmn.pbLearnMove(i[1]) if i[0]==pkmn.level   # Learned a new move
    end
  end
}
