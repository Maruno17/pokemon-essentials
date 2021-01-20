#===============================================================================
# Deprecated classes, methods and constants for Pokémon.
# These will be removed in a future Essentials version.
#===============================================================================

# @deprecated Use {Pokemon} instead. PokeBattle_Pokemon is slated to be removed
#   in v20.
class PokeBattle_Pokemon
  attr_reader :name, :species, :form, :formTime, :forcedForm, :fused
  attr_reader :personalID, :exp, :hp, :status, :statusCount
  attr_reader :abilityflag, :genderflag, :natureflag, :natureOverride, :shinyflag
  attr_reader :moves, :firstmoves
  attr_reader :item, :mail
  attr_reader :iv, :ivMaxed, :ev
  attr_reader :happiness, :eggsteps, :pokerus
  attr_reader :ballused, :markings, :ribbons
  attr_reader :obtainMode, :obtainMap, :obtainText, :obtainLevel, :hatchedMap
  attr_reader :timeReceived, :timeEggHatched
  attr_reader :cool, :beauty, :cute, :smart, :tough, :sheen
  attr_reader :trainerID, :ot, :otgender, :language
  attr_reader :shadow, :heartgauge, :savedexp, :savedev, :hypermode
  attr_reader :shadowmoves, :shadowmovenum

  def initialise
    raise "PokeBattle_Pokemon.new is deprecated. Use Pokemon.new instead."
  end

  def self.copy(pkmn)
    owner = Pokemon::Owner.new(pkmn.trainerID, pkmn.ot, pkmn.otgender, pkmn.language)
    ret = Pokemon.new(pkmn.species, pkmn.level, owner, false)
    ret.name           = pkmn.name
    ret.exp            = pkmn.exp
    ret.formTime       = pkmn.formTime
    ret.forcedForm     = pkmn.forcedForm
    ret.hp             = pkmn.hp
    ret.abilityflag    = pkmn.abilityflag
    ret.genderflag     = pkmn.genderflag
    ret.natureflag     = pkmn.natureflag
    ret.natureOverride = pkmn.natureOverride
    ret.shinyflag      = pkmn.shinyflag
    ret.item_id        = pkmn.item
    ret.mail           = pkmn.mail
    ret.moves          = pkmn.moves
    ret.firstmoves     = pkmn.firstmoves.clone
    ret.status         = pkmn.status
    ret.statusCount    = pkmn.statusCount
    ret.iv             = pkmn.iv.clone
    ret.ev             = pkmn.ev.clone
    ret.ivMaxed        = pkmn.ivMaxed if pkmn.ivMaxed
    ret.happiness      = pkmn.happiness
    ret.ballused       = pkmn.ballused
    ret.eggsteps       = pkmn.eggsteps
    ret.markings       = pkmn.markings if pkmn.markings
    ret.ribbons        = pkmn.ribbons.clone
    ret.pokerus        = pkmn.pokerus
    ret.personalID     = pkmn.personalID
    ret.obtainMode     = pkmn.obtainMode
    ret.obtainMap      = pkmn.obtainMap
    ret.obtainText     = pkmn.obtainText
    ret.obtainLevel    = pkmn.obtainLevel if pkmn.obtainLevel
    ret.hatchedMap     = pkmn.hatchedMap
    ret.timeReceived   = pkmn.timeReceived
    ret.timeEggHatched = pkmn.timeEggHatched
    ret.cool           = pkmn.cool if pkmn.cool
    ret.beauty         = pkmn.beauty if pkmn.beauty
    ret.cute           = pkmn.cute if pkmn.cute
    ret.smart          = pkmn.smart if pkmn.smart
    ret.tough          = pkmn.tough if pkmn.tough
    ret.sheen          = pkmn.sheen if pkmn.sheen
    if pkmn.fused
      ret.fused = PokeBattle_Pokemon.copy(pkmn.fused) if pkmn.fused.is_a?(PokeBattle_Pokemon)
      ret.fused = pkmn.fused if pkmn.fused.is_a?(Pokemon)
    end
    ret.shadow         = pkmn.shadow
    ret.heartgauge     = pkmn.heartgauge
    ret.savedexp       = pkmn.savedexp
    ret.savedev        = pkmn.savedev.clone
    ret.hypermode      = pkmn.hypermode
    ret.shadowmoves    = pkmn.shadowmoves.clone
    ret.shadowmovenum  = pkmn.shadowmovenum
    # NOTE: Intentionally set last, as it recalculates stats.
    ret.formSimple = pkmn.form
  end
end

class Pokemon
  # @deprecated Use {MAX_NAME_SIZE} instead. This alias is slated to be removed in v20.
  MAX_POKEMON_NAME_SIZE = MAX_NAME_SIZE

  # @deprecated Use {Owner#public_id} instead. This alias is slated to be removed in v20.
  def publicID
    Deprecation.warn_method('Pokemon#publicID', 'v20', 'Pokemon::Owner#public_id')
    return @owner.public_id
  end

  # @deprecated Use {Owner#id} instead. This alias is slated to be removed in v20.
  def trainerID
    Deprecation.warn_method('Pokemon#trainerID', 'v20', 'Pokemon::Owner#id')
    return @owner.id
  end

  # @deprecated Use {Owner#id=} instead. This alias is slated to be removed in v20.
  def trainerID=(value)
    Deprecation.warn_method('Pokemon#trainerID=', 'v20', 'Pokemon::Owner#id=')
    @owner.id = value
  end

  # @deprecated Use {Owner#name} instead. This alias is slated to be removed in v20.
  def ot
    Deprecation.warn_method('Pokemon#ot', 'v20', 'Pokemon::Owner#name')
    return @owner.name
  end

  # @deprecated Use {Owner#name=} instead. This alias is slated to be removed in v20.
  def ot=(value)
    Deprecation.warn_method('Pokemon#ot=', 'v20', 'Pokemon::Owner#name=')
    @owner.name = value
  end

  # @deprecated Use {Owner#gender} instead. This alias is slated to be removed in v20.
  def otgender
    Deprecation.warn_method('Pokemon#otgender', 'v20', 'Pokemon::Owner#gender')
    return @owner.gender
  end

  # @deprecated Use {Owner#gender=} instead. This alias is slated to be removed in v20.
  def otgender=(value)
    Deprecation.warn_method('Pokemon#otgender=', 'v20', 'Pokemon::Owner#gender=')
    @owner.gender = value
  end

  # @deprecated Use {Owner#language} instead. This alias is slated to be removed in v20.
  def language
    Deprecation.warn_method('Pokemon#language', 'v20', 'Pokemon::Owner#language')
    return @owner.language
  end

  # @deprecated Use {Owner#language=} instead. This alias is slated to be removed in v20.
  def language=(value)
    Deprecation.warn_method('Pokemon#language=', 'v20', 'Pokemon::Owner#language=')
    @owner.language = value
  end
end

# (see Pokemon#initialize)
# @deprecated Use +Pokemon.new+ instead. This method and its aliases are
#   slated to be removed in v20.
def pbNewPkmn(species, level, owner = $Trainer, withMoves = true)
  Deprecation.warn_method('pbNewPkmn', 'v20', 'Pokemon.new')
  return Pokemon.new(species, level, owner, withMoves)
end
alias pbGenPkmn pbNewPkmn
alias pbGenPoke pbNewPkmn
