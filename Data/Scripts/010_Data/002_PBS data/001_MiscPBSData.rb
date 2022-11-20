#===============================================================================
# Data caches.
#===============================================================================
class Game_Temp
  attr_accessor :regional_dexes_data
  attr_accessor :battle_animations_data
  attr_accessor :move_to_battle_animation_data
  attr_accessor :map_infos
end

def pbClearData
  if $game_temp
    $game_temp.regional_dexes_data           = nil
    $game_temp.battle_animations_data        = nil
    $game_temp.move_to_battle_animation_data = nil
    $game_temp.map_infos                     = nil
  end
  MapFactoryHelper.clear
  $PokemonEncounters.setup($game_map.map_id) if $game_map && $PokemonEncounters
  if pbRgssExists?("Data/Tilesets.rxdata")
    $data_tilesets = load_data("Data/Tilesets.rxdata")
  end
end

#===============================================================================
# Method to get Regional Dexes data.
#===============================================================================
def pbLoadRegionalDexes
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.regional_dexes_data
    $game_temp.regional_dexes_data = load_data("Data/regional_dexes.dat")
  end
  return $game_temp.regional_dexes_data
end

#===============================================================================
# Methods relating to battle animations data.
#===============================================================================
def pbLoadBattleAnimations
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.battle_animations_data && pbRgssExists?("Data/PkmnAnimations.rxdata")
    $game_temp.battle_animations_data = load_data("Data/PkmnAnimations.rxdata")
  end
  return $game_temp.battle_animations_data
end

def pbLoadMoveToAnim
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.move_to_battle_animation_data
    $game_temp.move_to_battle_animation_data = load_data("Data/move2anim.dat") || []
  end
  return $game_temp.move_to_battle_animation_data
end

#===============================================================================
# Method relating to map infos data.
#===============================================================================
def pbLoadMapInfos
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.map_infos
    $game_temp.map_infos = load_data("Data/MapInfos.rxdata")
  end
  return $game_temp.map_infos
end
