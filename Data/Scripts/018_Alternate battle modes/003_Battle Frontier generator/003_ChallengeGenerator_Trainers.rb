#===============================================================================
#
#===============================================================================
def getTypes(species)
  species_data = GameData::Species.get(species)
  return species_data.types.clone
end

#===============================================================================
# If no trainers are defined for the current challenge, generate a set of random
# ones for it. If pokemonlist is given, assign Pokémon from it to all trainers.
# Save the results in the appropriate PBS files.
#===============================================================================
def pbTrainerInfo(pokemonlist, trfile, rules)
  bttrainers = pbGetBTTrainers(trfile)
  btpokemon = pbGetBTPokemon(trfile)
  # No battle trainers found; fill bttrainers with 200 randomly chosen ones from
  # all that exist (with a base money < 100)
  if bttrainers.length == 0
    200.times do |i|
      yield(nil) if block_given? && i % 50 == 0
      trainerid = nil
      if GameData::TrainerType.exists?(:YOUNGSTER) && rand(30) == 0
        trainerid = :YOUNGSTER
      else
        tr_typekeys = GameData::TrainerType.keys
        loop do
          tr_type = tr_typekeys.sample
          tr_type_data = GameData::TrainerType.get(tr_type)
          next if tr_type_data.base_money >= 100
          trainerid = tr_type_data.id
        end
      end
      # Create a random name for the trainer
      gender = GameData::TrainerType.get(trainerid).gender
      randomName = getRandomNameEx(gender, nil, 0, 12)
      # Add the trainer to bttrainers
      tr = [trainerid, randomName, _INTL("Here I come!"), _INTL("Yes, I won!"),
            _INTL("Man, I lost!"), []]
      bttrainers.push(tr)
    end
    # Sort all the randomly chosen trainers by their base money (smallest first)
    bttrainers.sort! do |a, b|
      money1 = GameData::TrainerType.get(a[0]).base_money
      money2 = GameData::TrainerType.get(b[0]).base_money
      next (money1 == money2) ? a[0].to_s <=> b[0].to_s : money1 <=> money2
    end
  end
  yield(nil) if block_given?
  # Set all Pokémon in pokemonlist to the appropriate level, and determine their
  # type(s) and whether they are valid for the given rules
  suggestedLevel = rules.ruleset.suggestedLevel
  rulesetTeam = rules.ruleset.copy.clearPokemonRules
  pkmntypes = []
  validities = []
  pokemonlist.each do |pkmn|
    pkmn.level = suggestedLevel if pkmn.level != suggestedLevel
    pkmntypes.push(getTypes(pkmn.species))
    validities.push(rules.ruleset.isPokemonValid?(pkmn))
  end
  # For each trainer in bttrainers, come up with a set of Pokémon taken from
  # pokemonlist for that trainer, and copy the trainer and their set of Pokémon
  # to newbttrainers
  newbttrainers = []
  bttrainers.length.times do |btt|
    yield(nil) if block_given? && btt % 50 == 0
    trainerdata = bttrainers[btt]
    pokemonnumbers = trainerdata[5] || []
    # Find all the Pokémon available to the trainer, and count up how often
    # those Pokémon have each type
    species = []
    types = {}
    GameData::Type.each { |t| types[t.id] = 0 }
    pokemonnumbers.each do |pn|
      pkmn = btpokemon[pn]
      species.push(pkmn.species)
      t = getTypes(pkmn.species)
      t.each { |typ| types[typ] += 1 }
    end
    species |= []   # remove duplicates
    # Scale down the counts of each type to the range 0 -> 10
    count = 0
    GameData::Type.each do |t|
      if types[t.id] >= 5
        types[t.id] /= 4
        types[t.id] = 10 if types[t.id] > 10
      else
        types[t.id] = 0
      end
      count += types[t.id]
    end
    types[:NORMAL] = 1 if count == 0   # All type counts are 0; add 1 to Normal
    # Trainer had no Pokémon available to it; make all the type counts 1
    if pokemonnumbers.length == 0
      GameData::Type.each { |t| types[t.id] = 1 }
    end
    # Get Pokémon from pokemonlist, if there are any, and make sure enough are
    # gotten that a valid team can be made from them
    numbers = []
    if pokemonlist
      # For each valid Pokémon in pokemonlist, add its index within pokemonlist
      # to numbers, but only if that species is available to the trainer.
      # Pokémon are less likely to be added if it is positioned later in
      # pokemonlist, or if the trainer is positioned earlier in bttrainers (i.e.
      # later trainers get better Pokémon).
      numbersPokemon = []
      pokemonlist.length.times do |index|
        next if !validities[index]
        pkmn = pokemonlist[index]
        absDiff = ((index * 8 / pokemonlist.length) - (btt * 8 / bttrainers.length)).abs
        if species.include?(pkmn.species)
          weight = [32, 12, 5, 2, 1, 0, 0, 0][[absDiff, 7].min]
          if rand(40) < weight
            numbers.push(index)
            numbersPokemon.push(pokemonlist[index])
          end
        else
          # Pokémon's species isn't available to the trainer; try adding it
          # anyway (more likely to add it if the trainer has access to more
          # Pokémon of the same type(s) as this Pokémon)
          t = pkmntypes[index]
          t.each do |typ|
            weight = [32, 12, 5, 2, 1, 0, 0, 0][[absDiff, 7].min]
            weight *= types[typ]
            if rand(40) < weight
              numbers.push(index)
              numbersPokemon.push(pokemonlist[index])
            end
          end
        end
      end
      numbers |= []   # Remove duplicates
      # If there aren't enough Pokémon to form a full team, or a valid team
      # can't be made from them, fill up numbers with Pokémon in pokemonlist
      # that EITHER have the same species as one available to the trainer OR has
      # a type that is available to the trainer, until a valid team can be
      # formed from what's in numbers
      if numbers.length < Settings::MAX_PARTY_SIZE ||
         !rulesetTeam.hasValidTeam?(numbersPokemon)
        pokemonlist.length.times do |index|
          pkmn = pokemonlist[index]
          next if !validities[index]
          if species.include?(pkmn.species)
            numbers.push(index)
            numbersPokemon.push(pokemonlist[index])
          else
            t = pkmntypes[index]
            t.each do |typ|
              next if types[typ] <= 0 || numbers.include?(index)
              numbers.push(index)
              numbersPokemon.push(pokemonlist[index])
              break
            end
          end
          break if numbers.length >= Settings::MAX_PARTY_SIZE && rules.ruleset.hasValidTeam?(numbersPokemon)
        end
        # If there STILL aren't enough Pokémon to form a full team, or a valid
        # team can't be made from them, add random Pokémon from pokemonlist
        # until a valid team can be formed from what's in numbers
        if numbers.length < Settings::MAX_PARTY_SIZE || !rules.ruleset.hasValidTeam?(numbersPokemon)
          while numbers.length < pokemonlist.length &&
                (numbers.length < Settings::MAX_PARTY_SIZE || !rules.ruleset.hasValidTeam?(numbersPokemon))
            index = rand(pokemonlist.length)
            if !numbers.include?(index)
              numbers.push(index)
              numbersPokemon.push(pokemonlist[index])
            end
          end
        end
      end
      numbers.sort!
    end
    # Add the trainer's data, including all Pokémon that should be available to
    # it (from pokemonlist), to newbttrainers
    newbttrainers.push([trainerdata[0], trainerdata[1], trainerdata[2],
                        trainerdata[3], trainerdata[4], numbers])
  end
  yield(nil) if block_given?
  # Add the trainer and Pokémon data from above to trainer_lists.dat, and then
  # create all PBS files from it
  pbpokemonlist = []
  pokemonlist.each do |pkmn|
    pbpokemonlist.push(PBPokemon.fromPokemon(pkmn))
  end
  trlists = (load_data("Data/trainer_lists.dat") rescue [])
  hasDefault = false
  trIndex = -1
  trlists.length.times do |i|
    next if !trlists[i][5]
    hasDefault = true
    break
  end
  trlists.length.times do |i|
    next if !trlists[i][2].include?(trfile)
    trIndex = i
    trlists[i][0] = newbttrainers
    trlists[i][1] = pbpokemonlist
    trlists[i][5] = !hasDefault
  end
  yield(nil) if block_given?
  if trIndex < 0
    info = [newbttrainers, pbpokemonlist, [trfile],
            trfile + "_trainers.txt", trfile + "_pkmn.txt", !hasDefault]
    trlists.push(info)
  end
  yield(nil) if block_given?
  save_data(trlists, "Data/trainer_lists.dat")
  yield(nil) if block_given?
  Compiler.write_trainer_lists
  yield(nil) if block_given?
end
