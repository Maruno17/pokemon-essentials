#===============================================================================
#
#===============================================================================
class Battle::AI::AIBattler
  attr_reader :index, :side, :party_index
  attr_reader :battler

  def initialize(ai, index)
    @ai = ai
    @index = index
    @side = (@ai.battle.opposes?(@index)) ? 1 : 0
    refresh_battler
  end

  def refresh_battler
    old_party_index = @party_index
    @battler = @ai.battle.battlers[@index]
    @party_index = @battler.pokemonIndex
    if @party_index != old_party_index
      # TODO: Start of battle or Pokémon switched/shifted; recalculate roles,
      #       etc.
    end
  end

  def level;       return @battler.level;       end
  def hp;          return @battler.hp;          end
  def status;      return @Battler.status;      end
  def statusCount; return @battler.statusCount; end
  def totalhp;     return @battler.totalhp;     end
  def gender;      return @battler.gender;      end
  def turnCount;   return @battler.turnCount;   end
  def effects;     return @battler.effects;     end
  def stages;      return @battler.stages;      end
  def statStageAtMax?(stat); return @battler.statStageAtMax?(stat); end
  def statStageAtMin?(stat); return @battler.statStageAtMin?(stat); end

  def wild?
    return @ai.battle.wildBattle? && opposes?
  end

  def opposes?(other = nil)
    return @side == 1 if other.nil?
    return other.side != @side
  end

  def idxOwnSide;      return @battler.idxOwnSide;      end
  def pbOwnSide;       return @battler.pbOwnSide;       end
  def idxOpposingSide; return @battler.idxOpposingSide; end
  def pbOpposingSide;  return @battler.pbOpposingSide;  end

  def faster_than?(other)
    return false if other.nil?
    this_speed  = rough_stat(:SPEED)
    other_speed = other.rough_stat(:SPEED)
    return (this_speed > other_speed) ^ (@ai.battle.field.effects[PBEffects::TrickRoom] > 0)
  end

  #=============================================================================

  def speed; return @battler.speed; end

  # TODO: Cache calculated rough stats? Forget them in def refresh_battler.
  def rough_stat(stat)
    return @battler.pbSpeed if stat == :SPEED && @ai.trainer.high_skill?
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    stage = @battler.stages[stat] + 6
    value = 0
    case stat
    when :ATTACK          then value = @battler.attack
    when :DEFENSE         then value = @battler.defense
    when :SPECIAL_ATTACK  then value = @battler.spatk
    when :SPECIAL_DEFENSE then value = @battler.spdef
    when :SPEED           then value = @battler.speed
    end
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================

  def types; return @battler.types; end

  def has_type?(type)
    return @battler.pbHasType?(type)
  end

  def effectiveness_of_type_against_battler(type, user = nil)
    return Effectiveness::NORMAL_EFFECTIVE if !type
    return Effectiveness::NORMAL_EFFECTIVE if type == :GROUND &&
                                              has_type?(:FLYING) &&
                                              has_active_item?(:IRONBALL)
    # Get effectivenesses
    type_mults = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if type == :SHADOW
      if @battler.shadowPokemon?
        type_mults[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        type_mults[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      @battler.pbTypes(true).each_with_index do |defend_type, i|
        type_mults[i] = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    type_mults.each { |m| ret *= m }
    return ret
  end

  #=============================================================================

  def ability_id; return @battler.ability_id; end
  def ability;    return @battler.ability;    end

  def ability_active?
    # Only a high skill AI knows what an opponent's ability is
#    return false if @ai.trainer.side != @side && !@ai.trainer.high_skill?
    return @battler.abilityActive?
  end

  def has_active_ability?(ability, check_mold_breaker = false)
    # Only a high skill AI knows what an opponent's ability is
#    return false if @ai.trainer.side != @side && !@ai.trainer.high_skill?
    return @battler.hasActiveAbility?(ability)
  end

  def has_mold_breaker?
    return @ai.move.function == "IgnoreTargetAbility" || @battler.hasMoldBreaker?
  end

  #=============================================================================

  def item_id; return @battler.item_id; end
  def item;    return @battler.item;    end

  def item_active?
    # Only a high skill AI knows what an opponent's held item is
#    return false if @ai.trainer.side != @side && !@ai.trainer.high_skill?
    return @battler.itemActive?
  end

  def has_active_item?(item)
    # Only a high skill AI knows what an opponent's held item is
#    return false if @ai.trainer.side != @side && !@ai.trainer.high_skill?
    return @battler.hasActiveItem?(item)
  end

  #=============================================================================

  def can_switch_lax?
    return false if wild?
    @ai.battle.eachInTeamFromBattlerIndex(@index) do |pkmn, i|
      return true if @ai.battle.pbCanSwitchLax?(@index, i)
    end
    return false
  end

  #=============================================================================

  def immune_to_move?
    user = @ai.user
    user_battler = user.battler
    move = @ai.move
    # TODO: Add consideration of user's Mold Breaker.
    move_type = move.rough_type
    typeMod = effectiveness_of_type_against_battler(move_type, user)
    # Type effectiveness
    return true if move.damagingMove? && Effectiveness.ineffective?(typeMod)
    # Immunity due to ability/item/other effects
    if @ai.trainer.medium_skill?
      case move_type
      when :GROUND
        # TODO: Split target.airborne? into separate parts to allow different
        #       skill levels to apply to each part.
        return true if @battler.airborne? && !move.move.hitsFlyingTargets?
      when :FIRE
        return true if has_active_ability?(:FLASHFIRE)
      when :WATER
        return true if has_active_ability?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])
      when :GRASS
        return true if has_active_ability?(:SAPSIPPER)
      when :ELECTRIC
        return true if has_active_ability?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
      end
      return true if move.damagingMove? && Effectiveness.not_very_effective?(typeMod) &&
                     has_active_ability?(:WONDERGUARD)
      return true if move.damagingMove? && user.index != @index && !opposes?(user) &&
                     has_active_ability?(:TELEPATHY)
      return true if move.statusMove? && move.move.canMagicCoat? &&
                     !@ai.battle.moldBreaker && has_active_ability?(:MAGICBOUNCE) &&
                     opposes?(user)
      return true if move.move.soundMove? && !@ai.battle.moldBreaker && has_active_ability?(:SOUNDPROOF)
      return true if move.move.bombMove? && has_active_ability?(:BULLETPROOF)
      if move.move.powderMove?
        return true if has_type?(:GRASS)
        return true if !@ai.battle.moldBreaker && has_active_ability?(:OVERCOAT)
        return true if has_active_ability?(:SAFETYGOGGLES)
      end
      return true if move.move.statusMove? && @battler.effects[PBEffects::Substitute] > 0 &&
                     !move.move.ignoresSubstitute?(user) && user.index != @index
      return true if move.move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
                     user.has_active_ability?(:PRANKSTER) && has_type?(:DARK) &&
                     opposes?(user)
      return true if move.move.priority > 0 && @ai.battle.field.terrain == :Psychic &&
                     @battler.affectedByTerrain? && opposes?(user)
      # TODO: Dazzling/Queenly Majesty go here.
    end
    return false
  end

  #=============================================================================

  private

  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate_one(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user&.has_active_ability?(:SCRAPPY) || @battler.effects[PBEffects::Foresight]) &&
         defend_type == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Miracle Eye
      if @battler.effects[PBEffects::MiracleEye] && defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if @battler.effectiveWeather == :StrongWinds && defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !@battler.airborne? && type == :GROUND && defend_type == :FLYING
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end
end
