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
  elsif $Trainer.party_full?
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
  return pkmn.species_data.egg_groups.include?(:Ditto)
end

def pbDayCareCompatibleGender(pkmn1, pkmn2)
  return true if pkmn1.female? && pkmn2.male?
  return true if pkmn1.male? && pkmn2.female?
  ditto1 = pbIsDitto?(pkmn1)
  ditto2 = pbIsDitto?(pkmn2)
  return true if ditto1 && !ditto2
  return true if ditto2 && !ditto1
  return false
end

def pbDayCareGetCompat
  return 0 if pbDayCareDeposited != 2
  pkmn1 = $PokemonGlobal.daycare[0][0]
  pkmn2 = $PokemonGlobal.daycare[1][0]
  # Shadow Pokémon cannot breed
  return 0 if pkmn1.shadowPokemon? || pkmn2.shadowPokemon?
  # Pokémon in the Undiscovered egg group cannot breed
  egg_groups1 = pkmn1.species_data.egg_groups
  egg_groups2 = pkmn2.species_data.egg_groups
  return 0 if egg_groups1.include?(:Undiscovered) ||
              egg_groups2.include?(:Undiscovered)
  # Pokémon that don't share an egg group (and neither is in the Ditto group)
  # cannot breed
  return 0 if !egg_groups1.include?(:Ditto) &&
              !egg_groups2.include?(:Ditto) &&
              (egg_groups1 & egg_groups2).length == 0
  # Pokémon with incompatible genders cannot breed
  return 0 if !pbDayCareCompatibleGender(pkmn1, pkmn2)
  # Pokémon can breed; calculate a compatibility factor
  ret = 1
  ret += 1 if pkmn1.species == pkmn2.species
  ret += 1 if pkmn1.owner.id != pkmn2.owner.id
  return ret
end

def pbDayCareGetCompatibility(variable)
  $game_variables[variable] = pbDayCareGetCompat
end



#===============================================================================
# Generate an Egg based on Pokémon in the Day Care.
#===============================================================================
def pbDayCareGenerateEgg
  return if pbDayCareDeposited != 2
  raise _INTL("Can't store the egg.") if $Trainer.party_full?
  pkmn0 = $PokemonGlobal.daycare[0][0]
  pkmn1 = $PokemonGlobal.daycare[1][0]
  mother = nil
  father = nil
  babyspecies = nil
  ditto0 = pbIsDitto?(pkmn0)
  ditto1 = pbIsDitto?(pkmn1)
  if pkmn0.female? || ditto0
    mother = pkmn0
    father = pkmn1
    babyspecies = (ditto0) ? father.species : mother.species
  else
    mother = pkmn1
    father = pkmn0
    babyspecies = (ditto1) ? father.species : mother.species
  end
  # Determine the egg's species
  babyspecies = GameData::Species.get(babyspecies).get_baby_species(true, mother.item_id, father.item_id)
  case babyspecies
  when :MANAPHY
    babyspecies = :PHIONE if GameData::Species.exists?(:PHIONE)
  when :NIDORANfE, :NIDORANmA
    if GameData::Species.exists?(:NIDORANfE) && GameData::Species.exists?(:NIDORANmA)
      babyspecies = [:NIDORANfE, :NIDORANmA][rand(2)]
    end
  when :VOLBEAT, :ILLUMISE
    if GameData::Species.exists?(:VOLBEAT) && GameData::Species.exists?(:ILLUMISE)
      babyspecies = [:VOLBEAT, :ILLUMISE][rand(2)]
    end
  end
  # Generate egg
  egg = Pokemon.new(babyspecies, Settings::EGG_LEVEL)
  # Randomise personal ID
  pid = rand(65536)
  pid |= (rand(65536)<<16)
  egg.personalID = pid
  # Inheriting form
  if [:BURMY, :SHELLOS, :BASCULIN, :FLABEBE, :PUMPKABOO, :ORICORIO, :ROCKRUFF, :MINIOR].include?(babyspecies)
    newForm = mother.form
    newForm = 0 if mother.isSpecies?(:MOTHIM)
    egg.form = newForm
  end
  # Inheriting Alolan form
  if [:RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER].include?(babyspecies)
    if mother.form==1
      egg.form = 1 if mother.hasItem?(:EVERSTONE)
    elsif father.species_data.get_baby_species(true, mother.item_id, father.item_id) == babyspecies
      egg.form = 1 if father.form==1 && father.hasItem?(:EVERSTONE)
    end
  end
  # Inheriting Moves
  moves = []
  othermoves = []
  movefather = father
  movemother = mother
  if pbIsDitto?(movefather) && !mother.female?
    movefather = mother
    movemother = father
  end
  # Initial Moves
  initialmoves = egg.getMoveList
  for k in initialmoves
    if k[0] <= Settings::EGG_LEVEL
      moves.push(k[1])
    elsif mother.hasMove?(k[1]) && father.hasMove?(k[1])
      othermoves.push(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  if Settings::BREEDING_CAN_INHERIT_MACHINE_MOVES
    GameData::Item.each do |i|
      atk = i.move
      next if !atk
      next if !egg.compatible_with_move?(atk)
      next if !movefather.hasMove?(atk)
      moves.push(atk)
    end
  end
  # Inheriting Egg Moves
  babyEggMoves = egg.species_data.egg_moves
  if movefather.male?
    babyEggMoves.each { |m| moves.push(m) if movefather.hasMove?(m) }
  end
  if Settings::BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER
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
  if lightball && babyspecies == :PICHU && GameData::Move.exists?(:VOLTTACKLE)
    moves.push(:VOLTTACKLE)
  end
  moves = moves.reverse
  moves |= []   # remove duplicates
  moves = moves.reverse
  # Assembling move list
  first_move_index = moves.length - Pokemon::MAX_MOVES
  first_move_index = 0 if first_move_index < 0
  finalmoves = []
  for i in first_move_index...moves.length
    finalmoves.push(Pokemon::Move.new(moves[i]))
  end
  # Inheriting Individual Values
  ivs = {}
  GameData::Stat.each_main { |s| ivs[s.id] = rand(Pokemon::IV_STAT_LIMIT + 1) }
  ivinherit = []
  for i in 0...2
    parent = [mother,father][i]
    ivinherit[i] = :HP if parent.hasItem?(:POWERWEIGHT)
    ivinherit[i] = :ATTACK if parent.hasItem?(:POWERBRACER)
    ivinherit[i] = :DEFENSE if parent.hasItem?(:POWERBELT)
    ivinherit[i] = :SPECIAL_ATTACK if parent.hasItem?(:POWERLENS)
    ivinherit[i] = :SPECIAL_DEFENSE if parent.hasItem?(:POWERBAND)
    ivinherit[i] = :SPEED if parent.hasItem?(:POWERANKLET)
  end
  num = 0
  r = rand(2)
  2.times do
    if ivinherit[r]!=nil
      parent = [mother,father][r]
      ivs[ivinherit[r]] = parent.iv[ivinherit[r]]
      num += 1
      break
    end
    r = (r+1)%2
  end
  limit = (mother.hasItem?(:DESTINYKNOT) || father.hasItem?(:DESTINYKNOT)) ? 5 : 3
  loop do
    freestats = []
    GameData::Stat.each_main { |s| freestats.push(s.id) if !ivinherit.include?(s.id) }
    break if freestats.length==0
    r = freestats[rand(freestats.length)]
    parent = [mother,father][rand(2)]
    ivs[r] = parent.iv[r]
    ivinherit.push(r)
    num += 1
    break if num>=limit
  end
  # Inheriting nature
  new_natures = []
  new_natures.push(mother.nature) if mother.hasItem?(:EVERSTONE)
  new_natures.push(father.nature) if father.hasItem?(:EVERSTONE)
  if new_natures.length > 0
    new_nature = (new_natures.length == 1) ? new_natures[0] : new_natures[rand(new_natures.length)]
    egg.nature = new_nature
  end
  # Masuda method and Shiny Charm
  shinyretries = 0
  shinyretries += 5 if father.owner.language != mother.owner.language
  shinyretries += 2 if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
  if shinyretries>0
    shinyretries.times do
      break if egg.shiny?
      egg.personalID = rand(2**16) | rand(2**16) << 16
    end
  end
  # Inheriting ability from the mother
  if !ditto0 || !ditto1
    parent = (ditto0) ? father : mother   # The non-Ditto
    if parent.hasHiddenAbility?
      egg.ability_index = parent.ability_index if rand(100) < 60
    elsif !ditto0 && !ditto1
      if rand(100) < 80
        egg.ability_index = mother.ability_index
      else
        egg.ability_index = (mother.ability_index + 1) % 2
      end
    end
  end
  # Inheriting Poké Ball from the mother (or father if it's same species as mother)
  if !ditto0 || !ditto1
    possible_balls = []
    if mother.species == father.species
      possible_balls.push(mother.poke_ball)
      possible_balls.push(father.poke_ball)
    else
      possible_balls.push(pkmn0.poke_ball) if pkmn0.female? || ditto1
      possible_balls.push(pkmn1.poke_ball) if pkmn1.female? || ditto0
    end
    possible_balls.delete(:MASTERBALL)    # Can't inherit this Ball
    possible_balls.delete(:CHERISHBALL)   # Can't inherit this Ball
    if possible_balls.length > 0
      egg.poke_ball = possible_balls[0]
      egg.poke_ball = possible_balls[rand(possible_balls.length)] if possible_balls.length > 1
    end
  end
  # Set all stats
  egg.happiness = 120
  egg.iv = ivs
  egg.moves = finalmoves
  egg.calc_stats
  egg.obtain_text = _INTL("Day-Care Couple")
  egg.name = _INTL("Egg")
  egg.steps_to_hatch = egg.species_data.hatch_steps
  egg.givePokerus if rand(65536) < Settings::POKERUS_CHANCE
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
      if GameData::Item.exists?(:OVALCHARM) && $PokemonBag.pbHasItem?(:OVALCHARM)
        compatval = [0,40,80,88][pbDayCareGetCompat]
      end
      $PokemonGlobal.daycareEgg = 1 if rand(100)<compatval   # Egg is generated
    end
  end
  # Day Care Pokémon gain Exp/moves
  for i in 0...2
    pkmn = $PokemonGlobal.daycare[i][0]
    next if !pkmn
    maxexp = pkmn.growth_rate.maximum_exp
    next if pkmn.exp>=maxexp
    oldlevel = pkmn.level
    pkmn.exp += 1   # Gain Exp
    next if pkmn.level==oldlevel
    pkmn.calc_stats
    movelist = pkmn.getMoveList
    for i in movelist
      pkmn.learn_move(i[1]) if i[0]==pkmn.level   # Learned a new move
    end
  end
}
