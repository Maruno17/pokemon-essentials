#===============================================================================
# Deprecated classes, methods and constants for Pokémon.
# These will be removed in a future Essentials version.
#===============================================================================

# @deprecated Use {Pokemon} instead. PokeBattle_Pokemon is slated to be removed in v20.
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
  attr_reader :shadow, :heartgauge, :savedexp, :savedev, :hypermode, :shadowmoves

  def initialize(*args)
    raise "PokeBattle_Pokemon.new is deprecated. Use Pokemon.new instead."
  end

  def self.convert(pkmn)
    return pkmn if pkmn.is_a?(Pokemon)
    owner = Pokemon::Owner.new(pkmn.trainerID, pkmn.ot, pkmn.otgender, pkmn.language)
    # Set level to 1 initially, as it will be recalculated later
    ret = Pokemon.new(pkmn.species, 1, owner, false, false)
    ret.forced_form      = pkmn.forcedForm if pkmn.forcedForm
    ret.time_form_set    = pkmn.formTime
    ret.exp              = pkmn.exp
    ret.steps_to_hatch   = pkmn.eggsteps
    ret.status           = pkmn.status
    ret.statusCount      = pkmn.statusCount
    ret.gender           = pkmn.genderflag
    ret.shiny            = pkmn.shinyflag
    ret.ability_index    = pkmn.abilityflag
    ret.nature           = pkmn.natureflag
    ret.nature_for_stats = pkmn.natureOverride
    ret.item             = pkmn.item
    ret.mail             = PokemonMail.convert(pkmn.mail) if pkmn.mail
    pkmn.moves.each { |m| ret.moves.push(PBMove.convert(m)) if m && m.id > 0 }
    if pkmn.firstmoves
      pkmn.firstmoves.each { |m| ret.add_first_move(m) }
    end
    if pkmn.ribbons
      pkmn.ribbons.each { |r| ret.giveRibbon(r) }
    end
    ret.cool             = pkmn.cool if pkmn.cool
    ret.beauty           = pkmn.beauty if pkmn.beauty
    ret.cute             = pkmn.cute if pkmn.cute
    ret.smart            = pkmn.smart if pkmn.smart
    ret.tough            = pkmn.tough if pkmn.tough
    ret.sheen            = pkmn.sheen if pkmn.sheen
    ret.pokerus          = pkmn.pokerus if pkmn.pokerus
    ret.name             = pkmn.name if pkmn.name != ret.speciesName
    ret.happiness        = pkmn.happiness
    ret.poke_ball        = pbBallTypeToItem(pkmn.ballused).id
    ret.markings         = pkmn.markings if pkmn.markings
    GameData::Stat.each_main do |s|
      ret.iv[s.id]       = pkmn.iv[s.id_number]
      ret.ivMaxed[s.id]  = pkmn.ivMaxed[s.id_number] if pkmn.ivMaxed
      ret.ev[s.id]       = pkmn.ev[s.id_number]
    end
    ret.obtain_method    = pkmn.obtainMode
    ret.obtain_map       = pkmn.obtainMap
    ret.obtain_text      = pkmn.obtainText
    ret.obtain_level     = pkmn.obtainLevel if pkmn.obtainLevel
    ret.hatched_map      = pkmn.hatchedMap
    ret.timeReceived     = pkmn.timeReceived
    ret.timeEggHatched   = pkmn.timeEggHatched
    if pkmn.fused
      ret.fused = PokeBattle_Pokemon.convert(pkmn.fused) if pkmn.fused.is_a?(PokeBattle_Pokemon)
      ret.fused = pkmn.fused if pkmn.fused.is_a?(Pokemon)
    end
    ret.personalID       = pkmn.personalID
    ret.hp               = pkmn.hp
    if pkmn.shadow
      ret.shadow         = pkmn.shadow
      ret.heart_gauge    = pkmn.heartgauge
      ret.hyper_mode     = pkmn.hypermode
      ret.saved_exp      = pkmn.savedexp
      if pkmn.savedev
        GameData::Stat.each_main { |s| ret.saved_ev[s.id] = pkmn.savedev[s.pbs_order] if s.pbs_order >= 0 }
      end
      ret.shadow_moves   = []
      pkmn.shadowmoves.each_with_index do |move, i|
        ret.shadow_moves[i] = GameData::Move.get(move).id if move
      end
    end
    # NOTE: Intentionally set last, as it recalculates stats.
    ret.form_simple      = pkmn.form || 0
    return ret
  end
end

class Pokemon
  # @deprecated Use {MAX_NAME_SIZE} instead. This alias is slated to be removed in v20.
  MAX_POKEMON_NAME_SIZE = MAX_NAME_SIZE
  deprecate_constant :MAX_POKEMON_NAME_SIZE

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

  # @deprecated Use {Pokemon#shiny=} instead. This alias is slated to be removed in v20.
  def makeShiny
    Deprecation.warn_method('Pokemon#makeShiny', 'v20', 'Pokemon#shiny=true')
    self.shiny = true
  end

  # @deprecated Use {Pokemon#shiny=} instead. This alias is slated to be removed in v20.
  def makeNotShiny
    Deprecation.warn_method('Pokemon#makeNotShiny', 'v20', 'Pokemon#shiny=false')
    self.shiny = false
  end

  deprecated_method_alias :isEgg?, :egg?, removal_in: 'v20'
  deprecated_method_alias :isAble?, :able?, removal_in: 'v20'
  deprecated_method_alias :isFainted?, :fainted?, removal_in: 'v20'
  deprecated_method_alias :isShiny?, :shiny?, removal_in: 'v20'
  deprecated_method_alias :setGender, :gender=, removal_in: 'v20'
  deprecated_method_alias :isMale?, :male?, removal_in: 'v20'
  deprecated_method_alias :isFemale?, :female?, removal_in: 'v20'
  deprecated_method_alias :isGenderless?, :genderless?, removal_in: 'v20'
  deprecated_method_alias :isSingleGendered?, :singleGendered?, removal_in: 'v20'
  deprecated_method_alias :setAbility, :ability_index=, removal_in: 'v20'
  deprecated_method_alias :setNature, :nature=, removal_in: 'v20'
  deprecated_method_alias :setItem, :item=, removal_in: 'v20'
  deprecated_method_alias :healStatus, :heal_status, removal_in: 'v20'
  deprecated_method_alias :knowsMove?, :hasMove?, removal_in: 'v20'
  deprecated_method_alias :resetMoves, :reset_moves, removal_in: 'v20'
  deprecated_method_alias :pbLearnMove, :learn_move, removal_in: 'v20'
  deprecated_method_alias :pbDeleteMove, :forget_move, removal_in: 'v20'
  deprecated_method_alias :pbDeleteMoveAtIndex, :forget_move_at_index, removal_in: 'v20'
  deprecated_method_alias :pbRecordFirstMoves, :record_first_moves, removal_in: 'v20'
  deprecated_method_alias :pbAddFirstMove, :add_first_move, removal_in: 'v20'
  deprecated_method_alias :pbRemoveFirstMove, :remove_first_move, removal_in: 'v20'
  deprecated_method_alias :pbClearFirstMoves, :clear_first_moves, removal_in: 'v20'
  deprecated_method_alias :pbUpdateShadowMoves, :update_shadow_moves, removal_in: 'v20'
  deprecated_method_alias :isForeign?, :foreign?, removal_in: 'v20'
  deprecated_method_alias :calcStats, :calc_stats, removal_in: 'v20'
  deprecated_method_alias :isMega?, :mega?, removal_in: 'v20'
  deprecated_method_alias :isPrimal?, :primal?, removal_in: 'v20'
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
