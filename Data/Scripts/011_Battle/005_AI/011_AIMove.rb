#===============================================================================
#
#===============================================================================
class Battle::AI::AIMove
  attr_reader :move

  def initialize(ai)
    @ai = ai
  end

  def set_up(move)
    @move = move
    @move.calcType = rough_type
    @ai.battle.moldBreaker ||= ["IgnoreTargetAbility",
                                "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(function_code)
  end

  #-----------------------------------------------------------------------------

  def id;                            return @move.id;                      end
  def name;                          return @move.name;                    end
  def physicalMove?(thisType = nil); return @move.physicalMove?(thisType); end
  def specialMove?(thisType = nil);  return @move.specialMove?(thisType);  end
  def damagingMove?;                 return @move.damagingMove?;           end
  def statusMove?;                   return @move.statusMove?;             end
  def function_code;                 return @move.function_code;           end

  #-----------------------------------------------------------------------------

  def type; return @move.type; end

  def rough_type
    return @move.pbCalcType(@ai.user.battler) if @ai.trainer.medium_skill?
    return @move.type
  end

  #-----------------------------------------------------------------------------

  def pbTarget(user)
    return @move.pbTarget((user.is_a?(Battle::AI::AIBattler)) ? user.battler : user)
  end

  # Returns whether this move targets multiple battlers.
  def targets_multiple_battlers?
    user_battler = @ai.user.battler
    target_data = pbTarget(user_battler)
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

  #-----------------------------------------------------------------------------

  def rough_priority(user)
    ret = @move.pbPriority(user.battler)
    if user.ability_active?
      ret = Battle::AbilityEffects.triggerPriorityChange(user.ability, user.battler, @move, ret)
      user.battler.effects[PBEffects::Prankster] = false   # Untrigger this
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # Returns this move's base power, taking into account various effects that
  # modify it.
  def base_power
    ret = @move.power
    ret = 60 if ret == 1
    return ret if !@ai.trainer.medium_skill?
    return Battle::AI::Handlers.get_base_power(function_code,
       ret, self, @ai.user, @ai.target, @ai, @ai.battle)
  end

  # Full damage calculation.
  def rough_damage
    base_dmg = base_power
    return base_dmg if @move.is_a?(Battle::Move::FixedDamageMove)
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    # Get the user and target of this move
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    # Get the move's type
    calc_type = rough_type
    # Decide whether the move has 50% chance of higher of being a critical hit
    crit_stage = rough_critical_hit_stage
    is_critical = crit_stage >= Battle::Move::CRITICAL_HIT_RATIOS.length ||
                  Battle::Move::CRITICAL_HIT_RATIOS[crit_stage] <= 2
    ##### Calculate user's attack stat #####
    if ["CategoryDependsOnHigherDamagePoisonTarget",
        "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(function_code)
      @move.pbOnStartUse(user.battler, [target.battler])   # Calculate category
    end
    atk, atk_stage = @move.pbGetAttackStats(user.battler, target.battler)
    if !target.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker
      atk_stage = max_stage if is_critical && atk_stage < max_stage
      atk = (atk.to_f * stage_mul[atk_stage] / stage_div[atk_stage]).floor
    end
    ##### Calculate target's defense stat #####
    defense, def_stage = @move.pbGetDefenseStats(user.battler, target.battler)
    if !user.has_active_ability?(:UNAWARE) || @ai.battle.moldBreaker
      def_stage = max_stage if is_critical && def_stage > max_stage
      defense = (defense.to_f * stage_mul[def_stage] / stage_div[def_stage]).floor
    end
    ##### Calculate all multiplier effects #####
    multipliers = {
      :power_multiplier        => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Global abilities
    if @ai.trainer.medium_skill? &&
       ((@ai.battle.pbCheckGlobalAbility(:DARKAURA) && calc_type == :DARK) ||
        (@ai.battle.pbCheckGlobalAbility(:FAIRYAURA) && calc_type == :FAIRY))
      if @ai.battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:power_multiplier] *= 3 / 4.0
      else
        multipliers[:power_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.ability_active?
      case user.ability_id
      when :AERILATE, :GALVANIZE, :PIXILATE, :REFRIGERATE
        multipliers[:power_multiplier] *= 1.2 if type == :NORMAL   # NOTE: Not calc_type.
      when :ANALYTIC
        if rough_priority(user) <= 0
          user_faster = false
          @ai.each_battler do |b, i|
            user_faster = (i != user.index && user.faster_than?(b))
            break if user_faster
          end
          multipliers[:power_multiplier] *= 1.3 if !user_faster
        end
      when :NEUROFORCE
        if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 1.25
        end
      when :NORMALIZE
        multipliers[:power_multiplier] *= 1.2 if Settings::MECHANICS_GENERATION >= 7
      when :SNIPER
        multipliers[:final_damage_multiplier] *= 1.5 if is_critical
      when :STAKEOUT
        # NOTE: Can't predict whether the target will switch out this round.
      when :TINTEDLENS
        if Effectiveness.resistant_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 2
        end
      else
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
    if !@ai.battle.moldBreaker
      user_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
      if target.ability_active?
        case target.ability_id
        when :FILTER, :SOLIDROCK
          if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
            multipliers[:final_damage_multiplier] *= 0.75
          end
        else
          Battle::AbilityEffects.triggerDamageCalcFromTarget(
            target.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
          )
        end
      end
    end
    if target.ability_active?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
      )
    end
    if !@ai.battle.moldBreaker
      target_battler.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
      end
    end
    # Item effects that alter damage
    if user.item_active?
      case user.item_id
      when :EXPERTBELT
        if Effectiveness.super_effective_type?(calc_type, *target.pbTypes(true))
          multipliers[:final_damage_multiplier] *= 1.2
        end
      when :LIFEORB
        multipliers[:final_damage_multiplier] *= 1.3
      else
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user.item, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
        )
        user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
    end
    if target.item_active? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user_battler, target_battler, @move, multipliers, base_dmg, calc_type
      )
    end
    # Parental Bond
    if user.has_active_ability?(:PARENTALBOND)
      multipliers[:power_multiplier] *= (Settings::MECHANICS_GENERATION >= 7) ? 1.25 : 1.5
    end
    # Me First - n/a because can't predict the move Me First will use
    # Helping Hand - n/a
    # Charge
    if @ai.trainer.medium_skill? &&
       user.effects[PBEffects::Charge] > 0 && calc_type == :ELECTRIC
      multipliers[:power_multiplier] *= 2
    end
    # Mud Sport and Water Sport
    if @ai.trainer.medium_skill?
      case calc_type
      when :ELECTRIC
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:power_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:power_multiplier] /= 3
        end
      when :FIRE
        if @ai.battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:power_multiplier] /= 3
        end
        if @ai.battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:power_multiplier] /= 3
        end
      end
    end
    # Terrain moves
    if @ai.trainer.medium_skill?
      terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
      case @ai.battle.field.terrain
      when :Electric
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :ELECTRIC && user_battler.affectedByTerrain?
      when :Grassy
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :GRASS && user_battler.affectedByTerrain?
      when :Psychic
        multipliers[:power_multiplier] *= terrain_multiplier if calc_type == :PSYCHIC && user_battler.affectedByTerrain?
      when :Misty
        multipliers[:power_multiplier] /= 2 if calc_type == :DRAGON && target_battler.affectedByTerrain?
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
           function_code != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
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
    typemod = target.effectiveness_of_type_against_battler(calc_type, user, @move)
    multipliers[:final_damage_multiplier] *= typemod
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
    # NOTE: No need to check pbBaseDamageMultiplier, as it's already accounted
    #       for in an AI's MoveBasePower handler or can't be checked now anyway.
    # NOTE: No need to check pbModifyDamage, as it's already accounted for in an
    #       AI's MoveBasePower handler.
    ##### Main damage calculation #####
    base_dmg = [(base_dmg * multipliers[:power_multiplier]).round, 1].max
    atk      = [(atk      * multipliers[:attack_multiplier]).round, 1].max
    defense  = [(defense  * multipliers[:defense_multiplier]).round, 1].max
    damage   = ((((2.0 * user.level / 5) + 2).floor * base_dmg * atk / defense).floor / 50).floor + 2
    damage   = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    ret = damage.floor
    ret = target.hp - 1 if @move.nonLethal?(user_battler, target_battler) && ret >= target.hp
    return ret
  end

  #-----------------------------------------------------------------------------

  def accuracy
    return @move.pbBaseAccuracy(@ai.user.battler, @ai.target.battler) if @ai.trainer.medium_skill?
    return @move.accuracy
  end

  # Full accuracy calculation.
  def rough_accuracy
    # Determine user and target
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    # OHKO move accuracy
    if @move.is_a?(Battle::Move::OHKO)
      ret = self.accuracy + user.level - target.level
      ret -= 10 if function_code == "OHKOIce" && !user.has_type?(:ICE)
      return [ret, 0].max
    end
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
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    accStage = [[modifiers[:accuracy_stage], -max_stage].max, max_stage].min + max_stage
    evaStage = [[modifiers[:evasion_stage], -max_stage].max, max_stage].min + max_stage
    stageMul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
    stageDiv = Battle::Battler::ACC_EVA_STAGE_DIVISORS
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
      if user.item == :ZOOMLENS
        if rough_priority(user) <= 0
          modifiers[:accuracy_multiplier] *= 1.2 if target.faster_than?(user)
        end
      else
        Battle::ItemEffects.triggerAccuracyCalcFromUser(
          user.item, modifiers, user_battler, target_battler, @move, calc_type
        )
      end
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
    modifiers[:evasion_stage] = 0 if function_code == "IgnoreTargetDefSpDefEvaStatStages"   # Chip Away
    if @ai.trainer.medium_skill?
      modifiers[:base_accuracy] = 0 if user.effects[PBEffects::LockOn] > 0 &&
                                       user.effects[PBEffects::LockOnPos] == target.index
    end
    if @ai.trainer.medium_skill?
      case function_code
      when "BadPoisonTarget"
        modifiers[:base_accuracy] = 0 if Settings::MORE_TYPE_EFFECTS &&
                                         @move.statusMove? && user.has_type?(:POISON)
      end
    end
  end

  #-----------------------------------------------------------------------------

  # Full critical hit chance calculation (returns the determined critical hit
  # stage).
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

  #-----------------------------------------------------------------------------

  # Return values:
  #   0: Regular additional effect chance or isn't an additional effect
  #   -999: Additional effect will be negated
  #   Other: Amount to add to a move's score
  def get_score_change_for_additional_effect(user, target = nil)
    # Doesn't have an additional effect
    return 0 if @move.addlEffect == 0
    # Additional effect will be negated
    return -999 if user.has_active_ability?(:SHEERFORCE)
    return -999 if target && user.index != target.index &&
                   target.has_active_ability?(:SHIELDDUST) && !@ai.battle.moldBreaker
    # Prefer if the additional effect will have an increased chance of working
    return 5 if @move.addlEffect < 100 &&
                (Settings::MECHANICS_GENERATION >= 6 || function_code != "EffectDependsOnEnvironment") &&
                (user.has_active_ability?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
    # No change to score
    return 0
  end
end
