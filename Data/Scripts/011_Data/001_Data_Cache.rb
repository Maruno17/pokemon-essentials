#===============================================================================
# Data caches.
#===============================================================================
class PokemonTemp
  attr_accessor :metadata
  attr_accessor :townMapData
  attr_accessor :encountersData
  attr_accessor :phoneData
  attr_accessor :regionalDexes
  attr_accessor :speciesData
  attr_accessor :speciesEggMoves
  attr_accessor :speciesMetrics
  attr_accessor :speciesMovesets
  attr_accessor :speciesTMData
  attr_accessor :speciesShadowMovesets
  attr_accessor :pokemonFormToSpecies
  attr_accessor :trainerTypesData
  attr_accessor :trainersData
  attr_accessor :moveToAnim
  attr_accessor :battleAnims
end

def pbClearData
  if $PokemonTemp
    $PokemonTemp.metadata              = nil
    $PokemonTemp.townMapData           = nil
    $PokemonTemp.encountersData        = nil
    $PokemonTemp.phoneData             = nil
    $PokemonTemp.regionalDexes         = nil
    $PokemonTemp.speciesData           = nil
    $PokemonTemp.speciesEggMoves       = nil
    $PokemonTemp.speciesMetrics        = nil
    $PokemonTemp.speciesMovesets       = nil
    $PokemonTemp.speciesTMData         = nil
    $PokemonTemp.speciesShadowMovesets = nil
    $PokemonTemp.pokemonFormToSpecies  = nil
    $PokemonTemp.trainerTypesData      = nil
    $PokemonTemp.trainersData          = nil
    $PokemonTemp.moveToAnim            = nil
    $PokemonTemp.battleAnims           = nil
  end
  MapFactoryHelper.clear
  $PokemonEncounters.setup($game_map.map_id) if $game_map && $PokemonEncounters
  if pbRgssExists?("Data/Tilesets.rxdata")
    $data_tilesets = load_data("Data/Tilesets.rxdata")
  end
  if pbRgssExists?("Data/Tilesets.rvdata")
    $data_tilesets = load_data("Data/Tilesets.rvdata")
  end
end

#===============================================================================
# Methods to get metadata.
#===============================================================================
def pbLoadMetadata
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.metadata
    $PokemonTemp.metadata = load_data("Data/metadata.dat") || []
  end
  return $PokemonTemp.metadata
end

def pbGetMetadata(map_id, metadata_type)
  meta = pbLoadMetadata
  return meta[map_id][metadata_type] if meta[map_id]
  return nil
end

#===============================================================================
# Method to get Town Map data.
#===============================================================================
def pbLoadTownMapData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.townMapData
    $PokemonTemp.townMapData = load_data("Data/town_map.dat")
  end
  return $PokemonTemp.townMapData
end

#===============================================================================
# Method to get wild encounter data.
#===============================================================================
def pbLoadEncountersData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.encountersData
    if pbRgssExists?("Data/encounters.dat")
      $PokemonTemp.encountersData = load_data("Data/encounters.dat")
    end
  end
  return $PokemonTemp.encountersData
end

#===============================================================================
# Method to get phone call data.
#===============================================================================
def pbLoadPhoneData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.phoneData
    if pbRgssExists?("Data/phone.dat")
      $PokemonTemp.phoneData = load_data("Data/phone.dat")
    end
  end
  return $PokemonTemp.phoneData
end

#===============================================================================
# Method to get Regional Dexes data.
#===============================================================================
def pbLoadRegionalDexes
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.regionalDexes
    $PokemonTemp.regionalDexes = load_data("Data/regional_dexes.dat")
  end
  return $PokemonTemp.regionalDexes
end

#===============================================================================
# Methods to get Pokémon species data.
#===============================================================================
def pbLoadSpeciesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesData
    $PokemonTemp.speciesData = load_data("Data/species.dat") || []
  end
  return $PokemonTemp.speciesData
end

def pbGetSpeciesData(species, form = 0, species_data_type = -1)
  species = getID(PBSpecies, species)
  s = pbGetFSpeciesFromForm(species, form)
  species_data = pbLoadSpeciesData
  if species_data_type < 0
    return species_data[s] || []
  end
  return species_data[s][species_data_type] if species_data[s] && species_data[s][species_data_type]
  case species_data_type
  when SpeciesType2;                                      return nil
  when SpeciesBaseStats;                                  return [1, 1, 1, 1, 1, 1]
  when SpeciesEffortPoints;                               return [0, 0, 0, 0, 0, 0]
  when SpeciesStepsToHatch, SpeciesHeight, SpeciesWeight; return 1
  end
  return 0
end

#===============================================================================
# Methods to get egg moves data.
#===============================================================================
def pbLoadEggMovesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesEggMoves
    $PokemonTemp.speciesEggMoves = load_data("Data/species_eggmoves.dat") || []
  end
  return $PokemonTemp.speciesEggMoves
end

def pbGetSpeciesEggMoves(species, form = 0)
  species = getID(PBSpecies, species)
  s = pbGetFSpeciesFromForm(species, form)
  egg_moves_data = pbLoadEggMovesData
  return egg_moves_data[s] || []
end

#===============================================================================
# Method to get Pokémon species metrics (sprite positioning) data.
#===============================================================================
def pbLoadSpeciesMetrics
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesMetrics
    $PokemonTemp.speciesMetrics = load_data("Data/species_metrics.dat") || []
  end
  return $PokemonTemp.speciesMetrics
end

#===============================================================================
# Methods to get Pokémon moveset data.
#===============================================================================
def pbLoadMovesetsData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesMovesets
    $PokemonTemp.speciesMovesets = load_data("Data/species_movesets.dat") || []
  end
  return $PokemonTemp.speciesMovesets
end

def pbGetSpeciesMoveset(species, form = 0)
  species = getID(PBSpecies, species)
  s = pbGetFSpeciesFromForm(species, form)
  movesets_data = pbLoadMovesetsData
  return movesets_data[s] || []
end

#===============================================================================
# Method to get TM/Move Tutor compatibility data.
#===============================================================================
def pbLoadSpeciesTMData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesTMData
    $PokemonTemp.speciesTMData = load_data("Data/tm.dat") || []
  end
  return $PokemonTemp.speciesTMData
end

#===============================================================================
# Method to get Shadow Pokémon moveset data.
#===============================================================================
def pbLoadShadowMovesets
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesShadowMovesets
    $PokemonTemp.speciesShadowMovesets = load_data("Data/shadow_movesets.dat") || []
  end
  return $PokemonTemp.speciesShadowMovesets
end

#===============================================================================
# Method to get array that converts species + form to and from fSpecies values.
#===============================================================================
def pbLoadFormToSpecies
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.pokemonFormToSpecies
    $PokemonTemp.pokemonFormToSpecies = load_data("Data/form2species.dat")
  end
  return $PokemonTemp.pokemonFormToSpecies
end

#===============================================================================
# Methods to get trainer type data.
#===============================================================================
def pbLoadTrainerTypesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.trainerTypesData
    $PokemonTemp.trainerTypesData = load_data("Data/trainer_types.dat") || []
  end
  return $PokemonTemp.trainerTypesData
end

def pbGetTrainerTypeData(trainer_type)
  trainer_type_data = pbLoadTrainerTypesData
  return trainer_type_data[trainer_type] if trainer_type_data
  return nil
end

#===============================================================================
# Methods to get data about individual trainers.
#===============================================================================
def pbLoadTrainersData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.trainersData
    $PokemonTemp.trainersData = load_data("Data/trainers.dat") || []
  end
  return $PokemonTemp.trainersData
end

def pbGetTrainerData(trainer_id, trainer_name, party_id = 0)
  trainers_data = pbLoadTrainersData
  for t in trainers_data
    next if t[0] != trainer_id || t[1] != trainer_name || t[4] != party_id
    return t
  end
  return nil
end

#===============================================================================
# Methods relating to battle animations data.
#===============================================================================
def pbLoadMoveToAnim
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.moveToAnim
    $PokemonTemp.moveToAnim = load_data("Data/move2anim.dat") || []
  end
  return $PokemonTemp.moveToAnim
end

def pbLoadBattleAnimations
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.battleAnims
    if pbRgssExists?("Data/PkmnAnimations.rxdata")
      $PokemonTemp.battleAnims = load_data("Data/PkmnAnimations.rxdata")
    end
  end
  return $PokemonTemp.battleAnims
end
