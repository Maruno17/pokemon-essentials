def pbAddPokemonID(pokemon, level = nil, seeform = true, dontRandomize = false)
  return if !pokemon || !$Trainer
  dontRandomize = true if $game_switches[3] #when choosing starters

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end

  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon, level, $Trainer)
  end
  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !dontRandomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  speciesname = PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end


def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end


  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !skip_randomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.register(pokemon) if see_form
  return true
end


def pbGenerateEgg(pokemon, text = "")
  return false if !pokemon || !$Trainer # || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon = getID(PBSpecies, pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon = PokeBattle_Pokemon.new(pokemon, EGGINITIALLEVEL, $Trainer)
  end
  # Get egg steps
  eggsteps = $pkmn_dex[pokemon.species][10]
  # Set egg's details
  pokemon.name = _INTL("Egg")
  pokemon.eggsteps = eggsteps
  pokemon.obtainText = text
  pokemon.calcStats
  # Add egg to party
  Kernel.pbMessage(_INTL("Received a Pokémon egg!"))
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
    Kernel.pbMessage(_INTL("The egg was transfered to the PC."))

  end
  #$Trainer.party[$Trainer.party.length]=pokemon
  return true
end




def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species = getID(PBSpecies, species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species == species
  end
  return false
end


#Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  ret = false
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end

def getBodyID(species)
  return (species / NB_POKEMON).round
end

def getHeadID(species, bodyId)
  return (species - (bodyId * NB_POKEMON)).round
end