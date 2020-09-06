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

def pbGetMoveData(moveID,moveDataType=-1)
  meta = pbLoadMovesData
  if moveDataType<0
    return meta[moveID] || []
  end
  return meta[moveID][moveDataType] if meta[moveID]
  return nil
end

alias __moveData__pbClearData pbClearData
def pbClearData
  $PokemonTemp.movesData = nil if $PokemonTemp
  __moveData__pbClearData
end



class PBMoveData
  attr_reader :function,:basedamage,:type,:accuracy,:category
  attr_reader :totalpp,:addlEffect,:target,:priority,:flags

  def initialize(moveid)
    moveData = pbGetMoveData(moveID)
    @function   = moveData[MOVE_FUNCTION_CODE]
    @basedamage = moveData[MOVE_BASE_DAMAGE]
    @type       = moveData[MOVE_TYPE]
    @category   = moveData[MOVE_CATEGORY]
    @accuracy   = moveData[MOVE_ACCURACY]
    @totalpp    = moveData[MOVE_TOTAL_PP]
    @addlEffect = moveData[MOVE_EFFECT_CHANCE]
    @target     = moveData[MOVE_TARGET]
    @priority   = moveData[MOVE_PRIORITY]
    @flags      = moveData[MOVE_FLAGS]
  end
end



class PBMove
  attr_reader(:id)       # This move's ID
  attr_accessor(:pp)     # The amount of PP remaining for this move
  attr_accessor(:ppup)   # The number of PP Ups used for this move

  # Initializes this object to the specified move ID.
  def initialize(moveID)
    @id   = moveID
    @pp   = pbGetMoveData(moveID,MOVE_TOTAL_PP) || 0
    @ppup = 0
  end

  # Changes this move's ID, and caps the PP amount if it is now greater than the
  # new move's total PP.
  def id=(value)
    oldID = @id
    @id = value
    @pp = [@pp,self.totalpp].min if oldID>0
  end

  # Gets this move's type.
  def type
    return pbGetMoveData(@id,MOVE_TYPE) || 0
  end

  # Gets the maximum PP for this move.
  def totalpp
    maxPP = pbGetMoveData(@id,MOVE_TOTAL_PP) || 0
    return maxPP+maxPP*@ppup/5
  end
end
