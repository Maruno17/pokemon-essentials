#===============================================================================
# Data caches.
#===============================================================================
class PokemonTemp
  attr_accessor :townMapData
  attr_accessor :phoneData
  attr_accessor :speciesShadowMovesets
  attr_accessor :regionalDexes
  attr_accessor :battleAnims
  attr_accessor :moveToAnim
  attr_accessor :mapInfos
end

def pbClearData
  if $PokemonTemp
    $PokemonTemp.townMapData           = nil
    $PokemonTemp.phoneData             = nil
    $PokemonTemp.speciesShadowMovesets = nil
    $PokemonTemp.regionalDexes         = nil
    $PokemonTemp.battleAnims           = nil
    $PokemonTemp.moveToAnim            = nil
    $PokemonTemp.mapInfos              = nil
  end
  MapFactoryHelper.clear
  $PokemonEncounters.setup($game_map.map_id) if $game_map && $PokemonEncounters
  if pbRgssExists?("Data/Tilesets.rxdata")
    $data_tilesets = load_data("Data/Tilesets.rxdata")
  end
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
# Methods relating to battle animations data.
#===============================================================================
def pbLoadBattleAnimations
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.battleAnims
    if pbRgssExists?("Data/PkmnAnimations.rxdata")
      $PokemonTemp.battleAnims = load_data("Data/PkmnAnimations.rxdata")
    end
  end
  return $PokemonTemp.battleAnims
end

def pbLoadMoveToAnim
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.moveToAnim
    $PokemonTemp.moveToAnim = load_data("Data/move2anim.dat") || []
  end
  return $PokemonTemp.moveToAnim
end

#===============================================================================
# Method relating to map infos data.
#===============================================================================
def pbLoadMapInfos
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.mapInfos
    $PokemonTemp.mapInfos = load_data("Data/MapInfos.rxdata")
  end
  return $PokemonTemp.mapInfos
end
