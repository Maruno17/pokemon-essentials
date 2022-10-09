#===============================================================================
#
#===============================================================================
class Battle::AI::AIMove
  attr_reader :move

  def initialize(ai)
    @ai = ai
  end

  def set_up(move, ai_battler)
    @move = move
    @ai_battler = ai_battler
  end

  #=============================================================================

  # pp
  # totalpp
  # priority
  # usableWhenAsleep?
  # thawsUser?
  # flinchingMove?
  # tramplesMinimize?
  # hitsFlyingTargets?
  # canMagicCoat?
  # soundMove?
  # bombMove?
  # powderMove?
  # ignoresSubstitute?
  # highCriticalRate?
  # ignoresReflect?

  def id;            return @move.id;            end
  def physicalMove?(thisType = nil); return @move.physicalMove?(thisType); end
  def specialMove?(thisType = nil);  return @move.specialMove?(thisType);  end
  def damagingMove?; return @move.damagingMove?; end
  def statusMove?;   return @move.statusMove?;   end
  def function;      return @move.function;      end

  #=============================================================================

  # Returns whether this move targets multiple battlers.
  def targets_multiple_battlers?
    user_battler = @ai_battler.battler
    target_data = @move.pbTarget(user_battler)
    return false if target_data.num_targets <= 1
    num_targets = 0
    case target_data.id
    when :AllAllies
      @ai.battle.allSameSideBattlers(user_battler).each { |b| num_targets += 1 if b.index != user_battler.index }
    when :UserAndAllies
      @ai.battle.allSameSideBattlers(user_battler).each { |_b| num_targets += 1 }
    when :AllNearFoes
      @ai.battle.allOtherSideBattlers(user_battler).each { |b| num_targets += 1 if b.near?(user_battler) }
    when :AllFoes
      @ai.battle.allOtherSideBattlers(user_battler).each { |_b| num_targets += 1 }
    when :AllNearOthers
      @ai.battle.allBattlers.each { |b| num_targets += 1 if b.near?(user_battler) }
    when :AllBattlers
      @ai.battle.allBattlers.each { |_b| num_targets += 1 }
    end
    return num_targets > 1
  end

  #=============================================================================

  def rough_priority(user)
    # TODO: More calculations here.
    return @move.priority
  end

  #=============================================================================

  def type; return @move.type; end

  def rough_type
    return @move.pbCalcType(@ai.user.battler) if @ai.trainer.medium_skill?
    return @move.type
  end

  #=============================================================================

  # Returns this move's base power, taking into account various effects that
  # modify it.
  def base_power
    ret = @move.baseDamage
    ret = 60 if ret == 1
    return ret if !@ai.trainer.medium_skill?
    return Battle::AI::Handlers.get_base_power(function,
       ret, self, @ai.user, @ai.target, @ai, @ai.battle)
  end

  def rough_damage
    power = base_power
    return power if @move.is_a?(Battle::Move::FixedDamageMove)
    stage_mul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stage_div = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    # Get the user and target of this move
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler

    # Get the move's type
    calc_type = rough_type

    # Decide whether the move will definitely be a critical hit
    is_critical = rough_critical_hit_stage >= Battle::Move::CRITICAL_HIT_RATIOS.length

    ##### Calculate user's attack stat #####
    atk, atk_stage = @move.pbGetAttackStats(user.battler, target.battler)
    if !target.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker
      atk_stage = 6 if is_critical && atk_stage < 6
      atk = (atk.to_f * stage_mul[atk_stage] / stage_div[atk_stage]).floor
    end

    ##### Calculate target's defense stat #####
    defense, def_stage = pbGetDefenseStats(user, target)
    if !user.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker
      def_stage = 6 if is_critical && def_stage > 6
      defense = (defense.to_f * stage_mul[def_stage] / stage_div[def_stage]).floor
    end

    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Global abilities
    if @ai.trainer.medium_skill? &&
       ((@ai.battle.pbCheckGlobalAbility(:DARKAURA) && calc_type == :DARK) ||
        (@ai.battle.pbCheckGlobalAbility(:FAIRYAURA) && calc_type == :FAIRY))
      if @ai.battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end

    # Ability effects that alter damage
    if user.ability_active?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
      if !abilityBlacklist.include?(user.ability_id)
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user_battler, target_battler, @move, multipliers, power, calc_type
        )
      end
    end

    if !@ai.battle.moldBreaker
      user_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user_battler, target_battler, @move, multipliers, power, calc_type
        )
      end
      if target.ability_active?
        # NOTE: These abilities aren't suitable for checking at the start of the
        #       round.
        abilityBlacklist = [:FILTER, :SOLIDROCK]
        if !abilityBlacklist.include?(target.ability_id)
          Battle::AbilityEffects.triggerDamageCalcFromTarget(
            target.ability, user_battler, target_battler, @move, multipliers, power, calc_type
          )
        end
      end
    end
    if target.ability_active?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user_battler, target_battler, @move, multipliers, power, calc_type
      )
    end
    if !@ai.battle.moldBreaker
      target_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user_battler, target_battler, @move, multipliers, power, calc_type
        )
      end
    end

    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if user.item_active?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT, :LIFEORB]
      if !itemBlacklist.include?(user.item_id)
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user.item, user_battler, target_battler, @move, multipliers, power, calc_type
        )
        user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
      # TODO: Prefer (1.5x?) if item will be consumed and user has Unburden.
    end
    if target.item_active? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user_battler, target_battler, @move, multipliers, power, calc_type
      )
    end

    # Parental Bond
    if user.has_active_ability?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= (Settings::MECHANICS_GENERATION >= 7) ? 1.25 : 1.5
    end

    # Me First
    # TODO

    # Helping Hand - n/a

    # Charge
    if @ai.trainer.medium_skill? &&
       user.effects[PBEffects::Charge] > 0 && calc_type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end

    # Mud Sport and Water Sport
    if @ai.trainer.medium_skill?
      if calc_type == :ELECTRIC
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      elsif calc_type == :FIRE
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end

    # Terrain moves
    if @ai.trainer.medium_skill?
      terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
      case @ai.battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= terrain_multiplier if calc_type == :ELECTRIC && user_battler.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= terrain_multiplier if calc_type == :GRASS && user_battler.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= terrain_multiplier if calc_type == :PSYCHIC && user_battler.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if calc_type == :DRAGON && target_battler.affectedByTerrain?
      end
    end

    # Badge multipliers
    if @ai.trainer.high_skill? && @ai.battle.internalBattle && target_battler.pbOwnedByPlayer?
      # Don't need to check the Atk/Sp Atk-boosting badges because the AI
      # won't control the player's Pokémon.
      if physicalMove?(calc_type) && @ai.battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif specialMove?(calc_type) && @ai.battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end

    # Multi-targeting attacks
    if @ai.trainer.high_skill? && targets_multiple_battlers?
      multipliers[:final_damage_multiplier] *= 0.75
    end

    # Weather
    if @ai.trainer.medium_skill?
      case user_battler.effectiveWeather
      when :Sun, :HarshSun
        case calc_type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :Rain, :HeavyRain
        case calc_type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.has_type?(:ROCK) && specialMove?(calc_type) &&
           function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      end
    end

    # Critical hits
    if is_critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end

    # Random variance - n/a

    # STAB
    if calc_type && user.has_type?(calc_type)
      if user.has_active_ability?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end

    # Type effectiveness
    typemod = target.effectiveness_of_type_against_battler(calc_type, user)
    multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE

    # Burn
    if @ai.trainer.high_skill? && user.status == :BURN && physicalMove?(calc_type) &&
       @move.damageReducedByBurn? && !user.has_active_ability?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end

    # Aurora Veil, Reflect, Light Screen
    if @ai.trainer.medium_skill? && !@move.ignoresReflect? && !is_critical &&
       !user.has_active_ability?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?(calc_type)
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?(calc_type)
        if @ai.battle.pbSideBattlerCount(target_battler) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end

    # Minimize
    if @ai.trainer.medium_skill? && target.effects[PBEffects::Minimize] && @move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end

    # Move-specific base damage modifiers
    # TODO

    # Move-specific final damage modifiers
    # TODO

    ##### Main damage calculation #####
    power   = [(power   * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user.level / 5) + 2).floor * power * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    return damage.floor
  end

  #=============================================================================

  def accuracy
    return @move.pbBaseAccuracy(@ai.user.battler, @ai.target.battler) if @ai.trainer.medium_skill?
    return @move.accuracy
  end

  def rough_accuracy
    # Determine user and target
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    # "Always hit" effects and "always hit" accuracy
    if @ai.trainer.medium_skill?
      return 100 if target.effects[PBEffects::Telekinesis] > 0
      return 100 if target.effects[PBEffects::Minimize] && @move.tramplesMinimize? &&
                    Settings::MECHANICS_GENERATION >= 6
    end
    # Get base accuracy
    baseAcc = self.accuracy
    return 100 if baseAcc == 0
    # Get the move's type
    type = rough_type
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    apply_rough_accuracy_modifiers(user, target, type, modifiers)
    # Check if move certainly misses/can't miss
    return 0 if modifiers[:base_accuracy] < 0
    return 100 if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    return modifiers[:base_accuracy] * accuracy / evasion
  end

  def apply_rough_accuracy_modifiers(user, target, calc_type, modifiers)
    user_battler = user.battler
    target_battler = target.battler
    # OHKO special calculation
    if @ai.trainer.medium_skill?
      case function
      when "OHKO", "OHKOHitsUndergroundTarget"
        modifiers[:base_accuracy] = self.accuracy + user.level - target.level
        modifiers[:base_accuracy] = -1 if target.level > user.level
        modifiers[:base_accuracy] = -1 if !@ai.battle.moldBreaker && target.has_active_ability?(:STURDY)
        modifiers[:accuracy_stage] = 6
        modifiers[:evasion_stage] = 6
        return
      when "OHKOIce"
        modifiers[:base_accuracy] = self.accuracy + user.level - target.level
        modifiers[:base_accuracy] -= 10 if !user.has_type?(:ICE)
        modifiers[:base_accuracy] = -1 if modifiers[:base_accuracy] == 0
        modifiers[:base_accuracy] = -1 if target.level > user.level
        modifiers[:base_accuracy] = -1 if !@ai.battle.moldBreaker && target.has_active_ability?(:STURDY)
        modifiers[:accuracy_stage] = 6
        modifiers[:evasion_stage] = 6
        return
      end
    end
    # Ability effects that alter accuracy calculation
    if user.ability_active?
      Battle::AbilityEffects.triggerAccuracyCalcFromUser(
        user.ability, modifiers, user_battler, target_battler, @move, calc_type
      )
    end
    user_battler.allAllies.each do |b|
      next if !b.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
        b.ability, modifiers, user_battler, target_battler, @move, calc_type
      )
    end
    if !@ai.battle.moldBreaker && target.ability_active?
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target.ability, modifiers, user_battler, target_battler, @move, calc_type
      )
    end
    # Item effects that alter accuracy calculation
    if user.item_active?
      # TODO: Zoom Lens needs to be checked differently (compare speeds of
      #       user and target).
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        user.item, modifiers, user_battler, target_battler, @move, calc_type
      )
    end
    if target.item_active?
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target.item, modifiers, user_battler, target_battler, @move, calc_type
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
    if @ai.battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if @ai.trainer.medium_skill?
      if user.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
    # "AI-specific calculations below"
    modifiers[:evasion_stage] = 0 if function == "IgnoreTargetDefSpDefEvaStatStages"   # Chip Away
    if @ai.trainer.medium_skill?
      modifiers[:base_accuracy] = 0 if user.effects[PBEffects::LockOn] > 0 &&
                                       user.effects[PBEffects::LockOnPos] == target.index
    end
    if @ai.trainer.medium_skill?
      case function
      when "BadPoisonTarget"
        modifiers[:base_accuracy] = 0 if Settings::MORE_TYPE_EFFECTS &&
                                         @move.statusMove? && user.has_type?(:POISON)
      end
    end
  end

  #=============================================================================

  def rough_critical_hit_stage
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    return -1 if target_battler.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    crit_stage = 0
    # Ability effects that alter critical hit rate
    if user.ability_active?
      crit_stage = Battle::AbilityEffects.triggerCriticalCalcFromUser(user_battler.ability,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    if !@ai.battle.moldBreaker && target.ability_active?
      crit_stage = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target_battler.ability,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    # Item effects that alter critical hit rate
    if user.item_active?
      crit_stage = Battle::ItemEffects.triggerCriticalCalcFromUser(user_battler.item,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    if target.item_active?
      crit_stage = Battle::ItemEffects.triggerCriticalCalcFromTarget(user_battler.item,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    # Other effects
    case @move.pbCritialOverride(user_battler, target_battler)
    when 1  then return 99
    when -1 then return -1
    end
    return 99 if crit_stage > 50   # Merciless
    return 99 if user_battler.effects[PBEffects::LaserFocus] > 0
    crit_stage += 1 if @move.highCriticalRate?
    crit_stage += user_battler.effects[PBEffects::FocusEnergy]
    crit_stage += 1 if user_battler.inHyperMode? && @move.type == :SHADOW
    crit_stage = [crit_stage, Battle::Move::CRITICAL_HIT_RATIOS.length - 1].min
    return crit_stage
  end

  #=============================================================================

  # Returns:
  #   0 = move doesn't have an additional effect
  #   1 = additional effect will be negated
  #   2 = additional effect will work
  #   3 = additional effect has an increased chance to work
  def additional_effect_usability(user, target)
    return 0 if @move.addlEffect == 0   # Doesn't have an additional effect
    return 1 if target.has_active_ability?(:SHIELDDUST) && !battle.moldBreaker
    return 3 if (Settings::MECHANICS_GENERATION >= 6 || self.function != "EffectDependsOnEnvironment") &&
                (user.has_active_ability?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
    return 2
  end

  #=============================================================================

  # TODO:
  # pbBaseAccuracy(@ai.user.battler, @ai.target.battler) if @ai.trainer.medium_skill?
  # pbCriticalOverride(@ai.user.battler, @ai.target.battler)
end
