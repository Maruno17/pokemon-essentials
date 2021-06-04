class PokeBattle_Move
  attr_reader   :battle
  attr_reader   :realMove
  attr_accessor :id
  attr_reader   :name
  attr_reader   :function
  attr_reader   :baseDamage
  attr_reader   :type
  attr_reader   :category
  attr_reader   :accuracy
  attr_accessor :pp
  attr_writer   :total_pp
  attr_reader   :addlEffect
  attr_reader   :target
  attr_reader   :priority
  attr_reader   :flags
  attr_accessor :calcType
  attr_accessor :powerBoost
  attr_accessor :snatched

  def to_int; return @id; end

  #=============================================================================
  # Creating a move
  #=============================================================================
  def initialize(battle, move)
    @battle     = battle
    @realMove   = move
    @id         = move.id
    @name       = move.name   # Get the move's name
    # Get data on the move
    @function   = move.function_code
    @baseDamage = move.base_damage
    @type       = move.type
    @category   = move.category
    @accuracy   = move.accuracy
    @pp         = move.pp   # Can be changed with Mimic/Transform
    @addlEffect = move.effect_chance
    @target     = move.target
    @priority   = move.priority
    @flags      = move.flags
    @calcType   = nil
    @powerBoost = false   # For Aerilate, Pixilate, Refrigerate, Galvanize
    @snatched   = false
  end

  # This is the code actually used to generate a PokeBattle_Move object. The
  # object generated is a subclass of this one which depends on the move's
  # function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.from_pokemon_move(battle, move)
    validate move => Pokemon::Move
    moveFunction = move.function_code || "000"
    className = sprintf("PokeBattle_Move_%s", moveFunction)
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle, move)
    end
    return PokeBattle_UnimplementedMove.new(battle, move)
  end

  #=============================================================================
  # About the move
  #=============================================================================
  def pbTarget(_user); return GameData::Target.get(@target); end

  def total_pp
    return @total_pp if @total_pp && @total_pp>0   # Usually undefined
    return @realMove.total_pp if @realMove
    return 0
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def physicalMove?(thisType=nil)
    return (@category==0) if Settings::MOVE_CATEGORY_PER_MOVE
    thisType ||= @calcType
    thisType ||= @type
    return true if !thisType
    return GameData::Type.get(thisType).physical?
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def specialMove?(thisType=nil)
    return (@category==1) if Settings::MOVE_CATEGORY_PER_MOVE
    thisType ||= @calcType
    thisType ||= @type
    return false if !thisType
    return GameData::Type.get(thisType).special?
  end

  def damagingMove?; return @category!=2; end
  def statusMove?;   return @category==2; end

  def usableWhenAsleep?;       return false; end
  def unusableInGravity?;      return false; end
  def healingMove?;            return false; end
  def recoilMove?;             return false; end
  def flinchingMove?;          return false; end
  def callsAnotherMove?;       return false; end
  # Whether the move can/will hit more than once in the same turn (including
  # Beat Up which may instead hit just once). Not the same as pbNumHits>1.
  def multiHitMove?;           return false; end
  def chargingTurnMove?;       return false; end
  def successCheckPerHit?;     return false; end
  def hitsFlyingTargets?;      return false; end
  def hitsDiggingTargets?;     return false; end
  def hitsDivingTargets?;      return false; end
  def ignoresReflect?;         return false; end   # For Brick Break
  def cannotRedirect?;         return false; end   # For Future Sight/Doom Desire
  def worksWithNoTargets?;     return false; end   # For Explosion
  def damageReducedByBurn?;    return true;  end   # For Facade
  def triggersHyperMode?;      return false; end

  def contactMove?;       return @flags[/a/]; end
  def canProtectAgainst?; return @flags[/b/]; end
  def canMagicCoat?;      return @flags[/c/]; end
  def canSnatch?;         return @flags[/d/]; end
  def canMirrorMove?;     return @flags[/e/]; end
  def canKingsRock?;      return @flags[/f/]; end
  def thawsUser?;         return @flags[/g/]; end
  def highCriticalRate?;  return @flags[/h/]; end
  def bitingMove?;        return @flags[/i/]; end
  def punchingMove?;      return @flags[/j/]; end
  def soundMove?;         return @flags[/k/]; end
  def powderMove?;        return @flags[/l/]; end
  def pulseMove?;         return @flags[/m/]; end
  def bombMove?;          return @flags[/n/]; end
  def danceMove?;         return @flags[/o/]; end

  # Causes perfect accuracy (param=1) and double damage (param=2).
  def tramplesMinimize?(_param=1); return false; end
  def nonLethal?(_user,_target); return false; end   # For False Swipe

  def ignoresSubstitute?(user)   # user is the Pokémon using this move
    if Settings::MECHANICS_GENERATION >= 6
      return true if soundMove?
      return true if user && user.hasActiveAbility?(:INFILTRATOR)
    end
    return false
  end
end
