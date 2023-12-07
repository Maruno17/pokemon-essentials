class Battle::Move
  #=============================================================================
  # Move's type calculation
  #=============================================================================
  def pbBaseType(user)
    ret = @type
    if ret && user.abilityActive?
      ret = Battle::AbilityEffects.triggerModifyMoveBaseType(user.ability, user, self, ret)
    end
    return ret
  end

  def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    if ret && GameData::Type.exists?(:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
        ret = :ELECTRIC
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = :ELECTRIC
        @powerBoost = false
      end
    end
    return ret
  end

  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !moveType
    return ret if moveType == :GROUND && target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Get effectivenesses
    if moveType == :SHADOW
      if target.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      target.pbTypes(true).each do |type|
        ret *= pbCalcTypeModSingle(moveType, type, user, target)
      end
      ret *= 2 if target.effects[PBEffects::TarShot] && moveType == :FIRE
    end
    return ret
  end

  #=============================================================================
  # Accuracy check
  #=============================================================================
  def pbBaseAccuracy(user, target); return @accuracy; end

  # Accuracy calculations for one-hit KO moves are handled elsewhere.
  def pbAccuracyCheck(user, target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis] > 0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
    baseAcc = pbBaseAccuracy(user, target)
    return true if baseAcc == 0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
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
    threshold = modifiers[:base_accuracy] * accuracy / evasion
    # Calculation
    r = @battle.pbRandom(100)
    if Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       target.pbOwnedByPlayer? && target.affection_level == 5 && !target.mega?
      return true if r < threshold - 10
      target.damageState.affection_missed = true if r < threshold
      return false
    end
    return r < threshold
  end

  def pbCalcAccuracyModifiers(user, target, modifiers)
    # Ability effects that alter accuracy calculation
    if user.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromUser(
        user.ability, modifiers, user, target, self, @calcType
      )
    end
    user.allAllies.each do |b|
      next if !b.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
        b.ability, modifiers, user, target, self, @calcType
      )
    end
    if target.abilityActive? && !@battle.moldBreaker
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target.ability, modifiers, user, target, self, @calcType
      )
    end
    # Item effects that alter accuracy calculation
    if user.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        user.item, modifiers, user, target, self, @calcType
      )
    end
    if target.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target.item, modifiers, user, target, self, @calcType
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
    # specific values
    if @battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if user.effects[PBEffects::MicleBerry]
      user.effects[PBEffects::MicleBerry] = false
      modifiers[:accuracy_multiplier] *= 1.2
    end
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
  end

  #=============================================================================
  # Critical hit check
  #=============================================================================
  # Return values:
  #   -1: Never a critical hit.
  #    0: Calculate normally.
  #    1: Always a critical hit.
  def pbCritialOverride(user, target); return 0; end

  # Returns whether the move will be a critical hit.
  def pbIsCritical?(user, target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    c = 0
    # Ability effects that alter critical hit rate
    if c >= 0 && user.abilityActive?
      c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
    end
    # Item effects that alter critical hit rate
    if c >= 0 && user.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
    end
    return false if c < 0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user, target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c > 50   # Merciless
    return true if user.effects[PBEffects::LaserFocus] > 0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    # Set up the critical hit ratios
    ratios = CRITICAL_HIT_RATIOS
    c = ratios.length - 1 if c >= ratios.length
    # Calculation
    return true if ratios[c] == 1
    r = @battle.pbRandom(ratios[c])
    return true if r == 0
    if r == 1 && Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       user.pbOwnedByPlayer? && user.affection_level == 5 && !target.mega?
      target.damageState.affection_critical = true
      return true
    end
    return false
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbBaseDamage(baseDmg, user, target);              return baseDmg;    end
  def pbBaseDamageMultiplier(damageMult, user, target); return damageMult; end
  def pbModifyDamage(damageMult, user, target);         return damageMult; end

  def pbGetAttackStats(user, target)
    return user.spatk, user.stages[:SPECIAL_ATTACK] + Battle::Battler::STAT_STAGE_MAXIMUM if specialMove?
    return user.attack, user.stages[:ATTACK] + Battle::Battler::STAT_STAGE_MAXIMUM
  end

  def pbGetDefenseStats(user, target)
    return target.spdef, target.stages[:SPECIAL_DEFENSE] + Battle::Battler::STAT_STAGE_MAXIMUM if specialMove?
    return target.defense, target.stages[:DEFENSE] + Battle::Battler::STAT_STAGE_MAXIMUM
  end

  def pbCalcDamage(user, target, numTargets = 1)
    return if statusMove?
    if target.damageState.disguise || target.damageState.iceFace
      target.damageState.calcDamage = 1
      return
    end
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stageMul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stageDiv = Battle::Battler::STAT_STAGE_DIVISORS
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user, target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@power, user, target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user, target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = max_stage if target.damageState.critical && atkStage < max_stage
      atk = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user, target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = max_stage if target.damageState.critical && defStage > max_stage
      defense = (defense.to_f * stageMul[defStage] / stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :power_multiplier        => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:power_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:power_multiplier] *= 3 / 4.0
      else
        multipliers[:power_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromUser(
        user.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
      if target.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    if target.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromUser(
        user.item, user, target, self, multipliers, baseDmg, type
      )
    end
    if target.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, self, multipliers, baseDmg, type
      )
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond] == 1
      multipliers[:power_multiplier] /= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:power_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(Battle::Move::Confusion)
      multipliers[:power_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:power_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
        multipliers[:power_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::MudSportField] > 0
        multipliers[:power_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
        multipliers[:power_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::WaterSportField] > 0
        multipliers[:power_multiplier] /= 3
      end
    end
    # Terrain moves
    terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
    case @battle.field.terrain
    when :Electric
      multipliers[:power_multiplier] *= terrain_multiplier if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:power_multiplier] *= terrain_multiplier if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:power_multiplier] *= terrain_multiplier if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:power_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    multipliers[:final_damage_multiplier] *= 0.75 if numTargets > 1
    # Weather
    case user.effectiveWeather
    when :Sun, :HarshSun
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      when :WATER
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] /= 2
      when :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function_code != "UseTargetDefenseInsteadOfTargetSpDef"
        multipliers[:defense_multiplier] *= 1.5
      end
    when :ShadowSky
      multipliers[:final_damage_multiplier] *= 1.5 if type == :SHADOW
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(Battle::Move::Confusion)
      random = 85 + @battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:power_multiplier] = pbBaseDamageMultiplier(multipliers[:power_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end

  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user, target, effectChance = 0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance > 0) ? effectChance : @addlEffect
    return ret if ret > 100
    if (Settings::MECHANICS_GENERATION >= 6 || @function_code != "EffectDependsOnEnvironment") &&
       (user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
      ret *= 2
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user, target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH, true) ||
       user.hasActiveItem?([:KINGSROCK, :RAZORFANG], true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow] > 0
    return ret
  end
end
