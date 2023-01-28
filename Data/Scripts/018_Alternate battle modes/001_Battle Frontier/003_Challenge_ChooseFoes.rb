#===============================================================================
# Given an array of trainers and the number of wins the player already has,
# returns a random trainer index. The more wins, the later in the list the
# trainer comes from.
#===============================================================================
def pbBattleChallengeTrainer(win_count, bttrainers)
  # This table's start points and lengths are based on a bttrainers size of 300.
  # They are scaled based on the actual size of bttrainers later.
  table = [   # Each value is [minimum win count, range start point, range length]
    [ 0,   0, 100],   # 0-100
    [ 6,  80,  40],   # 80-120
    [ 7,  80,  40],   # 80-120
    [13, 120,  20],   # 120-140
    [14, 100,  40],   # 100-140
    [20, 140,  20],   # 140-160
    [21, 120,  40],   # 120-160
    [27, 160,  20],   # 160-180
    [28, 140,  40],   # 140-180
    [34, 180,  20],   # 180-200
    [35, 160,  40],   # 160-200
    [41, 200,  20],   # 200-220
    [42, 180,  40],   # 180-220
    [48, 220,  40],   # 220-260
    [49, 200, 100]    # 200-300 - This line is used for all higher win_counts
  ]
  slot = nil
  table.each { |val| slot = val if val[0] <= win_count && (!slot || slot[0] < val[0]) }
  return 0 if !slot
  # Scale the start point and length based on how many trainers are in bttrainers
  offset = slot[1] * bttrainers.length / 300
  length = slot[2] * bttrainers.length / 300
  # Return a random trainer index from the chosen range
  return offset + rand(length)
end

#===============================================================================
#
#===============================================================================
def pbGenerateBattleTrainer(idxTrainer, rules)
  bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  btpokemon = pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  level = rules.ruleset.suggestedLevel
  # Create the trainer
  trainerdata = bttrainers[idxTrainer]
  opponent = NPCTrainer.new(
    pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
    trainerdata[0]
  )
  # Determine how many IVs the trainer's Pokémon will have
  indvalues = 31
  indvalues = 21 if idxTrainer < 220
  indvalues = 18 if idxTrainer < 200
  indvalues = 15 if idxTrainer < 180
  indvalues = 12 if idxTrainer < 160
  indvalues = 9 if idxTrainer < 140
  indvalues = 6 if idxTrainer < 120
  indvalues = 3 if idxTrainer < 100
  # Get the indices within bypokemon of the Pokémon the trainer may have
  pokemonnumbers = trainerdata[5]
  # The number of possible Pokémon is <= the required number; make them
  # all Pokémon and use them
  if pokemonnumbers.length <= rules.ruleset.suggestedNumber
    pokemonnumbers.each do |n|
      rndpoke = btpokemon[n]
      pkmn = rndpoke.createPokemon(level, indvalues, opponent)
      opponent.party.push(pkmn)
    end
    return opponent
  end
  # There are more possible Pokémon than there are spaces available in the
  # trainer's party; randomly choose Pokémon
  loop do
    opponent.party.clear
    while opponent.party.length < rules.ruleset.suggestedNumber
      rnd = pokemonnumbers[rand(pokemonnumbers.length)]
      rndpoke = btpokemon[rnd]
      pkmn = rndpoke.createPokemon(level, indvalues, opponent)
      opponent.party.push(pkmn)
    end
    break if rules.ruleset.isValid?(opponent.party)
  end
  return opponent
end

#===============================================================================
# Generate a full team's worth of Pokémon which obey the given rules.
#===============================================================================
def pbBattleFactoryPokemon(rules, win_count, swap_count, rentals)
  btpokemon = pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  level = rules.ruleset.suggestedLevel
  pokemonNumbers = [0, 0]   # Start and end indices in btpokemon
  ivs = [0, 0]   # Lower and higher IV values for Pokémon to use
  iv_threshold = 6   # Number of Pokémon that use the lower IV
  set = [win_count / 7, 7].min   # The set of 7 battles win_count is part of (minus 1)
  # Choose a range of Pokémon in btpokemon to randomly select from. The higher
  # the set number, the later the range lies within btpokemon (typically).
  # This table's start point and end point values are based on a btpokemon size
  # of 881. They are scaled based on the actual size of btpokemon.
  # Group 1 is 0 - 173. Group 2 is 174 - 371. Group 3 is 372 - 881.
  if level == GameData::GrowthRate.max_level   # Open Level (Level 100)
    table = [
      [372, 491],   # Group 3 (first quarter)
      [492, 610],   # Group 3 (second quarter)
      [611, 729],   # Group 3 (third quarter)
      [730, 849],   # Group 3 (fourth quarter)
      [372, 881],   # All of Group 3
      [372, 881],   # All of Group 3
      [372, 881],   # All of Group 3
      [372, 881]    # This line is used for all higher sets (all of Group 3)
    ]
  else
    table = [
      [  0, 173],   # Group 1
      [174, 272],   # Group 2 (first half)
      [273, 371],   # Group 2 (second half)
      [372, 491],   # Group 3 (first quarter)
      [492, 610],   # Group 3 (second quarter)
      [611, 729],   # Group 3 (third quarter)
      [730, 849],   # Group 3 (fourth quarter)
      [372, 881]    # This line is used for all higher sets (all of Group 3)
    ]
  end
  pokemonNumbers[0] = table[set][0] * btpokemon.length / 881
  pokemonNumbers[1] = table[set][1] * btpokemon.length / 881
  # Choose two IV values for Pokémon to use (the one for the current set, and
  # the one for the next set). The iv_threshold below determines which of these
  # two values a given Pokémon uses. The higher the set number, the higher these
  # values are.
  ivtable = [3, 6, 9, 12, 15, 21, 31, 31]   # Last value is used for all higher sets
  ivs = [ivtable[set], ivtable[[set + 1, 7].min]]
  # Choose a threshold, which is the number of Pokémon with the lower IV out of
  # the two chosen above. The higher the swap_count, the lower this threshold
  # (i.e. the more Pokémon will have the higher IV).
  thresholds = [   # Each value is [minimum swap count, threshold value]
    [ 0, 6],
    [15, 5],
    [22, 4],
    [29, 3],
    [36, 2],
    [43, 1]
  ]
  thresholds.each { |val| iv_threshold = val[1] if swap_count >= val[0] }
  # Randomly choose Pokémon from the range to fill the party with
  old_min = rules.ruleset.minLength
  old_max = rules.ruleset.maxLength
  if rentals.length == 0
    rules.ruleset.setNumber(6)   # Rentals
  else
    rules.ruleset.setNumber(old_max + rentals.length)   # Opponent
  end
  party = []
  loop do
    party.clear
    while party.length < ((rentals.length == 0) ? 6 : old_max)
      rnd = pokemonNumbers[0] + rand(pokemonNumbers[1] - pokemonNumbers[0] + 1)
      rndpoke = btpokemon[rnd]
      indvalue = (party.length < iv_threshold) ? ivs[0] : ivs[1]
      party.push(rndpoke.createPokemon(level, indvalue, nil))
    end
    break if rules.ruleset.isValid?([].concat(party).concat(rentals))
  end
  rules.ruleset.setNumberRange(old_min, old_max)
  return party
end
