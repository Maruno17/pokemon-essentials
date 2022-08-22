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

  def type; return @move.type; end

  def rough_type
    return @move.pbCalcType(@ai.user.battler) if @ai.trainer.high_skill?
    return @move.type
  end

  def pbCalcType(user); return @move.pbCalcType(user); end

  #=============================================================================

  # Returns this move's base power, taking into account various effects that
  # modify it.
  def base_power
    ret = @move.baseDamage
    ret = 60 if ret == 1
    return ret if !@ai.trainer.medium_skill?
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    # Covers all function codes which have their own def pbBaseDamage
    case @move.function
    when "FixedDamage20", "FixedDamage40", "FixedDamageHalfTargetHP",
         "FixedDamageUserLevel", "LowerTargetHPToUserHP"
      ret = @move.pbFixedDamage(user_battler, target_battler)
    when "FixedDamageUserLevelRandom"
      ret = user_battler.level
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      ret = 200
    when "CounterPhysicalDamage", "CounterSpecialDamage", "CounterDamagePlusHalf"
      ret = 60
    when "DoublePowerIfTargetUnderwater", "DoublePowerIfTargetUnderground",
         "BindTargetDoublePowerIfTargetUnderwater"
      ret = @move.pbModifyDamage(ret, user_battler, target_battler)
    when "DoublePowerIfTargetInSky",
         "FlinchTargetDoublePowerIfTargetInSky",
         "DoublePowerIfTargetPoisoned",
         "DoublePowerIfTargetParalyzedCureTarget",
         "DoublePowerIfTargetAsleepCureTarget",
         "DoublePowerIfUserPoisonedBurnedParalyzed",
         "DoublePowerIfTargetStatusProblem",
         "DoublePowerIfTargetHPLessThanHalf",
         "DoublePowerIfAllyFaintedLastTurn",
         "TypeAndPowerDependOnWeather",
         "PowerHigherWithUserHappiness",
         "PowerLowerWithUserHappiness",
         "PowerHigherWithUserHP",
         "PowerHigherWithTargetHP",
         "PowerHigherWithUserPositiveStatStages",
         "PowerHigherWithTargetPositiveStatStages",
         "TypeDependsOnUserIVs",
         "PowerHigherWithConsecutiveUse",
         "PowerHigherWithConsecutiveUseOnUserSide",
         "PowerHigherWithLessPP",
         "PowerLowerWithUserHP",
         "PowerHigherWithUserFasterThanTarget",
         "PowerHigherWithTargetWeight",
         "ThrowUserItemAtTarget",
         "PowerDependsOnUserStockpile"
      ret = @move.pbBaseDamage(ret, user_battler, target_battler)
    when "DoublePowerIfUserHasNoItem"
      ret *= 2 if !user_battler.item || user.has_active_item?(:FLYINGGEM)
    when "PowerHigherWithTargetFasterThanUser"
      targetSpeed = target.rough_stat(:SPEED)
      userSpeed = user.rough_stat(:SPEED)
      ret = [[(25 * targetSpeed / userSpeed).floor, 150].min, 1].max
    when "RandomlyDamageOrHealTarget"
      ret = 50
    when "RandomPowerDoublePowerIfTargetUnderground"
      ret = 71
      ret *= 2 if target_battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")   # Dig
    when "TypeAndPowerDependOnUserBerry"
      ret = @move.pbNaturalGiftBaseDamage(user_battler.item_id)
    when "PowerHigherWithUserHeavierThanTarget"
      ret = @move.pbBaseDamage(ret, user_battler, target_battler)
      ret *= 2 if Settings::MECHANICS_GENERATION >= 7 && @trainer.medium_skill? &&
                      target_battler.effects[PBEffects::Minimize]
    when "AlwaysCriticalHit", "HitTwoTimes", "HitTwoTimesPoisonTarget"
      ret *= 2
    when "HitThreeTimesPowersUpWithEachHit"
      ret *= 6   # Hits do x1, x2, x3 ret in turn, for x6 in total
    when "HitTwoToFiveTimes"
      if user.has_active_ability?(:SKILLLINK)
        ret *= 5
      else
        ret = (ret * 31 / 10).floor   # Average damage dealt
      end
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
      if user_battler.isSpecies?(:GRENINJA) && user_battler.form == 2
        ret *= 4   # 3 hits at 20 power = 4 hits at 15 power
      elsif user.has_active_ability?(:SKILLLINK)
        ret *= 5
      else
        ret = (ret * 31 / 10).floor   # Average damage dealt
      end
    when "HitOncePerUserTeamMember"
      mult = 0
      @ai.battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
        mult += 1 if pkmn&.able? && pkmn.status == :NONE
      end
      ret *= mult
    when "TwoTurnAttackOneTurnInSun"
      ret = @move.pbBaseDamageMultiplier(ret, user_battler, target_battler)
    when "MultiTurnAttackPowersUpEachTurn"
      ret *= 2 if user_battler.effects[PBEffects::DefenseCurl]
    when "MultiTurnAttackBideThenReturnDoubleDamage"
      ret = 40
    when "UserFaintsFixedDamageUserHP"
      ret = user_battler.hp
    when "EffectivenessIncludesFlyingType"
      if GameData::Type.exists?(:FLYING)
        if @trainer.high_skill?
          targetTypes = target_battler.pbTypes(true)
          mult = Effectiveness.calculate(
            :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
          )
        else
          mult = Effectiveness.calculate(
            :FLYING, target.types[0], target.types[1], target.effects[PBEffects::Type3]
          )
        end
        ret = (ret.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
      end
      ret *= 2 if @trainer.medium_skill? && target_battler.effects[PBEffects::Minimize]
    when "DoublePowerIfUserLastMoveFailed"
      ret *= 2 if user_battler.lastRoundMoveFailed
    when "HitTwoTimesFlinchTarget"
      ret *= 2
      ret *= 2 if @trainer.medium_skill? && target_battler.effects[PBEffects::Minimize]
    end
    return ret
  end

  #=============================================================================

  def accuracy
    return @move.accuracy
  end

  def rough_accuracy
    baseAcc = self.accuracy
    return 100 if baseAcc == 0
    # Determine user and target
    user = @ai.user
    user_battler = user.battler
    target = @ai.target
    target_battler = target.battler
    # Get better base accuracy
    if @ai.trainer.medium_skill?
      baseAcc = @move.pbBaseAccuracy(user_battler, target_battler)
      return 100 if baseAcc == 0
    end
    # "Always hit" effects and "always hit" accuracy
    if @ai.trainer.medium_skill?
      return 100 if target_battler.effects[PBEffects::Minimize] && @move.tramplesMinimize? &&
                    Settings::MECHANICS_GENERATION >= 6
      return 100 if target_battler.effects[PBEffects::Telekinesis] > 0
    end
    # Get the move's type
    type = rough_type
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user_battler.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target_battler.stages[:EVASION]
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

  def apply_rough_accuracy_modifiers(user, target, type, modifiers)
    user_battler = user.battler
    target_battler = target.battler
    mold_breaker = (@ai.trainer.medium_skill? && target_battler.hasMoldBreaker?)
    # Ability effects that alter accuracy calculation
    if user.ability_active?
      Battle::AbilityEffects.triggerAccuracyCalcFromUser(
        user_battler.ability, modifiers, user_battler, target_battler, @move, type
      )
    end
    user_battler.allAllies.each do |b|
      next if !b.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
        b.ability, modifiers, user_battler, target_battler, @move, type
      )
    end
    if !mold_breaker && target.ability_active?
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target_battler.ability, modifiers, user_battler, target_battler, @move, type
      )
    end
    # Item effects that alter accuracy calculation
    if user.item_active?
      # TODO: Zoom Lens needs to be checked differently (compare speeds of
      #       user and target).
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        user_battler.item, modifiers, user_battler, target_battler, @move, type
      )
    end
    if target.item_active?
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target_battler.item, modifiers, user_battler, target_battler, @move, type
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
    if @ai.battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if @ai.trainer.medium_skill?
      if user_battler.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target_battler.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target_battler.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
    # "AI-specific calculations below"
    modifiers[:evasion_stage] = 0 if @move.function == "IgnoreTargetDefSpDefEvaStatStages"   # Chip Away
    if @ai.trainer.medium_skill?
      modifiers[:base_accuracy] = 0 if user_battler.effects[PBEffects::LockOn] > 0 &&
                                       user_battler.effects[PBEffects::LockOnPos] == target_battler.index
    end
    if @ai.trainer.medium_skill?
      case @move.function
      when "BadPoisonTarget"
        modifiers[:base_accuracy] = 0 if Settings::MORE_TYPE_EFFECTS &&
                                         @move.statusMove? && @user.has_type?(:POISON)
      when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
        modifiers[:base_accuracy] = self.accuracy + user_battler.level - target_battler.level
        modifiers[:accuracy_multiplier] = 0 if target_battler.level > user_battler.level
        modifiers[:accuracy_multiplier] = 0 if target.has_active_ability?(:STURDY)
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
    mold_breaker = (@ai.trainer.medium_skill? && user_battler.hasMoldBreaker?)
    crit_stage = 0
    # Ability effects that alter critical hit rate
    if user.ability_active?
      crit_stage = BattleHandlers.triggerCriticalCalcUserAbility(user_battler.ability,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    if !mold_breaker && target.ability_active?
      crit_stage = BattleHandlers.triggerCriticalCalcTargetAbility(target_battler.ability,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    # Item effects that alter critical hit rate
    if user.item_active?
      crit_stage = BattleHandlers.triggerCriticalCalcUserItem(user_battler.item,
         user_battler, target_battler, crit_stage)
      return -1 if crit_stage < 0
    end
    if target.item_active?
      crit_stage = BattleHandlers.triggerCriticalCalcTargetItem(user_battler.item,
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

  # pbBaseAccuracy(@ai.user.battler, @ai.target.battler) if @ai.trainer.medium_skill?
  # pbCriticalOverride(@ai.user.battler, @ai.target.battler)
end
