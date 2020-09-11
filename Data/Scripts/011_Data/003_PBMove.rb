MOVE_ID            = 0
MOVE_INTERNAL_NAME = 1
MOVE_NAME          = 2
MOVE_FUNCTION_CODE = 3
MOVE_BASE_DAMAGE   = 4
MOVE_TYPE          = 5
MOVE_CATEGORY      = 6
MOVE_ACCURACY      = 7
MOVE_TOTAL_PP      = 8
MOVE_EFFECT_CHANCE = 9
MOVE_TARGET        = 10
MOVE_PRIORITY      = 11
MOVE_FLAGS         = 12
MOVE_DESCRIPTION   = 13

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
# Move objects known by PokeBattle_Pokemon.
#===============================================================================
class PBMove
  attr_reader(:id)       # This move's ID
  attr_accessor(:pp)     # The amount of PP remaining for this move
  attr_accessor(:ppup)   # The number of PP Ups used for this move

  # Initializes this object to the specified move ID.
  def initialize(move_id)
    @id   = move_id
    @pp   = pbGetMoveData(move_id, MOVE_TOTAL_PP) || 0
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
    return pbGetMoveData(@id, MOVE_TYPE) || 0
  end

  # Gets the maximum PP for this move.
  def totalpp
    max_pp = pbGetMoveData(@id, MOVE_TOTAL_PP) || 0
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
    @function   = move_data[MOVE_FUNCTION_CODE]
    @basedamage = move_data[MOVE_BASE_DAMAGE]
    @type       = move_data[MOVE_TYPE]
    @category   = move_data[MOVE_CATEGORY]
    @accuracy   = move_data[MOVE_ACCURACY]
    @totalpp    = move_data[MOVE_TOTAL_PP]
    @addlEffect = move_data[MOVE_EFFECT_CHANCE]
    @target     = move_data[MOVE_TARGET]
    @priority   = move_data[MOVE_PRIORITY]
    @flags      = move_data[MOVE_FLAGS]
  end
end
