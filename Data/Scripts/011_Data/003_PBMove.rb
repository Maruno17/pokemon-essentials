module MoveData
  ID            = 0
  INTERNAL_NAME = 1
  NAME          = 2
  FUNCTION_CODE = 3
  BASE_DAMAGE   = 4
  TYPE          = 5
  CATEGORY      = 6
  ACCURACY      = 7
  TOTAL_PP      = 8
  EFFECT_CHANCE = 9
  TARGET        = 10
  PRIORITY      = 11
  FLAGS         = 12
  DESCRIPTION   = 13
end

class PokemonTemp
  attr_accessor :movesData
end

def pbLoadMovesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.movesData
    if pbRgssExists?("Data/moves.dat")
      $PokemonTemp.movesData = load_data("Data/moves.dat")
    else
      $PokemonTemp.movesData = []
    end
  end
  return $PokemonTemp.movesData
end

def pbGetMoveData(move_id, move_data_type = -1)
  meta = pbLoadMovesData
  if move_data_type < 0
    return meta[move_id] || []
  end
  return meta[move_id][move_data_type] if meta[move_id]
  return nil
end

alias __moveData__pbClearData pbClearData
def pbClearData
  $PokemonTemp.movesData = nil if $PokemonTemp
  __moveData__pbClearData
end

#===============================================================================
# Move objects known by Pokémon.
#===============================================================================
class PBMove
  attr_reader(:id)       # This move's ID
  attr_accessor(:pp)     # The amount of PP remaining for this move
  attr_accessor(:ppup)   # The number of PP Ups used for this move

  # Initializes this object to the specified move ID.
  def initialize(move_id)
    @id   = move_id
    @pp   = pbGetMoveData(move_id, MoveData::TOTAL_PP) || 0
    @ppup = 0
  end

  # Changes this move's ID, and caps the PP amount if it is now greater than the
  # new move's total PP.
  def id=(value)
    old_id = @id
    @id = value
    @pp = [@pp, totalpp].min if old_id > 0
  end

  # Gets this move's type.
  def type
    return pbGetMoveData(@id, MoveData::TYPE) || 0
  end

  # Gets the maximum PP for this move.
  def totalpp
    max_pp = pbGetMoveData(@id, MoveData::TOTAL_PP) || 0
    return max_pp + max_pp * @ppup / 5
  end
end

#===============================================================================
# Object containing move data. Not used for much.
#===============================================================================
class PBMoveData
  attr_reader :function, :basedamage, :type, :accuracy, :category
  attr_reader :totalpp, :addlEffect, :target, :priority, :flags

  def initialize(move_id)
    move_data = pbGetMoveData(move_id)
    @function   = move_data[MoveData::FUNCTION_CODE]
    @basedamage = move_data[MoveData::BASE_DAMAGE]
    @type       = move_data[MoveData::TYPE]
    @category   = move_data[MoveData::CATEGORY]
    @accuracy   = move_data[MoveData::ACCURACY]
    @totalpp    = move_data[MoveData::TOTAL_PP]
    @addlEffect = move_data[MoveData::EFFECT_CHANCE]
    @target     = move_data[MoveData::TARGET]
    @priority   = move_data[MoveData::PRIORITY]
    @flags      = move_data[MoveData::FLAGS]
  end
end

def pbIsHiddenMove?(move)
  GameData::Item.each do |i|
    return true if i.is_HM? && move == i.move
  end
  return false
end
