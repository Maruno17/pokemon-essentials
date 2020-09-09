class PokeBattle_Move
  #=============================================================================
  # Move's type calculation
  #=============================================================================
  def pbBaseType(user)
    ret = @type
    return ret if !ret || ret<0
    if user.abilityActive?
      ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(user.ability,user,self,ret)
    end
    return ret
  end

  def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    return ret if !ret || ret<0
    if hasConst?(PBTypes,:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && isConst?(ret,PBTypes,:NORMAL)
        ret = getConst(PBTypes,:ELECTRIC)
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = getConst(PBTypes,:ELECTRIC)
        @powerBoost = false
      end
    end
    return ret
  end

  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = PBTypes.getEffectiveness(moveType,defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if PBTypes.ineffective?(moveType,defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if isConst?(defType,PBTypes,:GHOST) &&
                                                         PBTypes.ineffective?(moveType,defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if isConst?(defType,PBTypes,:DARK) &&
                                                         PBTypes.ineffective?(moveType,defType)
    end
    # Delta Stream's weather
    if @battle.pbWeather==PBWeather::StrongWinds
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if isConst?(defType,PBTypes,:FLYING) &&
                                                         PBTypes.superEffective?(moveType,defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if isConst?(defType,PBTypes,:FLYING) &&
                                                         isConst?(moveType,PBTypes,:GROUND)
    end
    return ret
  end

  def pbCalcTypeMod(moveType,user,target)
    return PBTypeEffectiveness::NORMAL_EFFECTIVE if moveType<0
    return PBTypeEffectiveness::NORMAL_EFFECTIVE if isConst?(moveType,PBTypes,:GROUND) &&
       target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    tTypes.each_with_index do |type,i|
      typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  #=============================================================================
  # Accuracy check
  #=============================================================================
  def pbBaseAccuracy(user,target); return @accuracy; end

  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = []
    modifiers[BASE_ACC]  = baseAcc
    modifiers[ACC_STAGE] = user.stages[PBStats::ACCURACY]
    modifiers[EVA_STAGE] = target.stages[PBStats::EVASION]
    modifiers[ACC_MULT]  = 0x1000
    modifiers[EVA_MULT]  = 0x1000
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[BASE_ACC]==0
    # Calculation
    accStage = [[modifiers[ACC_STAGE],-6].max,6].min + 6
    evaStage = [[modifiers[EVA_STAGE],-6].max,6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[ACC_MULT] / 0x1000).round
    evasion  = (evasion  * modifiers[EVA_MULT] / 0x1000).round
    evasion = 1 if evasion<1
    # Calculation
    return @battle.pbRandom(100) < modifiers[BASE_ACC] * accuracy / evasion
  end

  def pbCalcAccuracyModifiers(user,target,modifiers)
    # Ability effects that alter accuracy calculation
    if user.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
         modifiers,user,target,self,@calcType)
    end
    user.eachAlly do |b|
      next if !b.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
         modifiers,user,target,self,@calcType)
    end
    if target.abilityActive? && !@battle.moldBreaker
      BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
         modifiers,user,target,self,@calcType)
    end
    # Item effects that alter accuracy calculation
    if user.itemActive?
      BattleHandlers.triggerAccuracyCalcUserItem(user.item,
         modifiers,user,target,self,@calcType)
    end
    if target.itemActive?
      BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
         modifiers,user,target,self,@calcType)
    end
    # Other effects, inc. ones that set ACC_MULT or EVA_STAGE to specific values
    if @battle.field.effects[PBEffects::Gravity]>0
      modifiers[ACC_MULT] = (modifiers[ACC_MULT]*5/3).round
    end
    if user.effects[PBEffects::MicleBerry]
      user.effects[PBEffects::MicleBerry] = false
      modifiers[ACC_MULT] = (modifiers[ACC_MULT]*1.2).round
    end
    modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::Foresight] && modifiers[EVA_STAGE]>0
    modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[EVA_STAGE]>0
  end

  #=============================================================================
  # Critical hit check
  #=============================================================================
  # Return values:
  #   -1: Never a critical hit.
  #    0: Calculate normally.
  #    1: Always a critical hit.
  def pbCritialOverride(user,target); return 0; end

  # Returns whether the move will be a critical hit.
  def pbIsCritical?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
    # Set up the critical hit ratios
    ratios = (NEWEST_BATTLE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
    end
    return false if c<0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user,target)
    when 1;  return true
    when -1; return false
    end
    # Other effects
    return true if c>50   # Merciless
    return true if user.effects[PBEffects::LaserFocus]>0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && isConst?(@type,PBTypes,:SHADOW)
    c = ratios.length-1 if c>=ratios.length
    # Calculation
    return @battle.pbRandom(ratios[c])==0
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end
  def pbBaseDamageMultiplier(damageMult,user,target); return damageMult; end
  def pbModifyDamage(damageMult,user,target);         return damageMult; end

  def pbGetAttackStats(user,target)
    if specialMove?
      return user.spatk, user.stages[PBStats::SPATK]+6
    end
    return user.attack, user.stages[PBStats::ATTACK]+6
  end

  def pbGetDefenseStats(user,target)
    if specialMove?
      return target.spdef, target.stages[PBStats::SPDEF]+6
    end
    return target.defense, target.stages[PBStats::DEFENSE]+6
  end

  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise || target.damageState.iceface
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # -1 is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
      atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
      defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = [0x1000,0x1000,0x1000,0x1000]
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[BASE_DMG_MULT]  / 0x1000).round,1].max
    atk     = [(atk     * multipliers[ATK_MULT]       / 0x1000).round,1].max
    defense = [(defense * multipliers[DEF_MULT]       / 0x1000).round,1].max
    damage  = (((2.0*user.level/5+2).floor*baseDmg*atk/defense).floor/50).floor+2
    damage  = [(damage  * multipliers[FINAL_DMG_MULT] / 0x1000).round,1].max
    target.damageState.calcDamage = damage
  end

  def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK)) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && isConst?(type,PBTypes,:FAIRY))
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[BASE_DMG_MULT] *= 2/3.0
      else
        multipliers[BASE_DMG_MULT] *= 4/3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      BattleHandlers.triggerDamageCalcUserAbility(user.ability,
         user,target,self,multipliers,baseDmg,type)
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      if target.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
        BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      BattleHandlers.triggerDamageCalcUserItem(user.item,
         user,target,self,multipliers,baseDmg,type)
    end
    if target.itemActive?
      BattleHandlers.triggerDamageCalcTargetItem(target.item,
         user,target,self,multipliers,baseDmg,type)
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond]==1
      multipliers[BASE_DMG_MULT] /= 4
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[BASE_DMG_MULT] = (multipliers[BASE_DMG_MULT]*1.5).round
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
      multipliers[BASE_DMG_MULT] = (multipliers[BASE_DMG_MULT]*1.5).round
    end
    if user.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
      multipliers[BASE_DMG_MULT] *= 2
    end
    # Mud Sport
    if isConst?(type,PBTypes,:ELECTRIC)
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::MudSport]
        multipliers[BASE_DMG_MULT] /= 3
        break
      end
      if @battle.field.effects[PBEffects::MudSportField]>0
        multipliers[BASE_DMG_MULT] /= 3
      end
    end
    # Tar Shot
    if target.effects[PBEffects::TarShot] && isConst?(type,PBTypes,:FIRE)
      multipliers[BASE_DMG_MULT] *= 2
    end
    # Water Sport
    if isConst?(type,PBTypes,:FIRE)
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::WaterSport]
        multipliers[BASE_DMG_MULT] /= 3
        break
      end
      if @battle.field.effects[PBEffects::WaterSportField]>0
        multipliers[BASE_DMG_MULT] /= 3
      end
    end
    # Terrain moves
    if user.affectedByTerrain?
      case @battle.field.terrain
      when PBBattleTerrains::Electric
        if isConst?(type,PBTypes,:ELECTRIC)
          multipliers[BASE_DMG_MULT] = (multipliers[BASE_DMG_MULT]*1.5).round
        end
      when PBBattleTerrains::Grassy
        if isConst?(type,PBTypes,:GRASS)
          multipliers[BASE_DMG_MULT] = (multipliers[BASE_DMG_MULT]*1.5).round
        end
      when PBBattleTerrains::Psychic
        if isConst?(type,PBTypes,:PSYCHIC)
          multipliers[BASE_DMG_MULT] = (multipliers[BASE_DMG_MULT]*1.5).round
        end
      end
    end
    if @battle.field.terrain==PBBattleTerrains::Misty && target.affectedByTerrain? &&
       isConst?(type,PBTypes,:DRAGON)
      multipliers[BASE_DMG_MULT] /= 2
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_ATTACK
          multipliers[ATK_MULT] = (multipliers[ATK_MULT]*1.1).round
        elsif specialMove? && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_SPATK
          multipliers[ATK_MULT] = (multipliers[ATK_MULT]*1.1).round
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_DEFENSE
          multipliers[DEF_MULT] = (multipliers[DEF_MULT]*1.1).round
        elsif specialMove? && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_SPDEF
          multipliers[DEF_MULT] = (multipliers[DEF_MULT]*1.1).round
        end
      end
    end
    # Multi-targeting attacks
    if numTargets>1
      multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*0.75).round
    end
    # Weather
    case @battle.pbWeather
    when PBWeather::Sun, PBWeather::HarshSun
      if isConst?(type,PBTypes,:FIRE)
        multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*1.5).round
      elsif isConst?(type,PBTypes,:WATER)
        multipliers[FINAL_DMG_MULT] /= 2
      end
    when PBWeather::Rain, PBWeather::HeavyRain
      if isConst?(type,PBTypes,:FIRE)
        multipliers[FINAL_DMG_MULT] /= 2
      elsif isConst?(type,PBTypes,:WATER)
        multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*1.5).round
      end
    when PBWeather::Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function!="122"   # Psyshock
        multipliers[DEF_MULT] = (multipliers[DEF_MULT]*1.5).round
      end
    end
    # Critical hits
    if target.damageState.critical
      if NEWEST_BATTLE_MECHANICS
        multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*1.5).round
      else
        multipliers[FINAL_DMG_MULT] *= 2
      end
    end
    # Random variance
    if !self.is_a?(PokeBattle_Confusion)
      random = 85+@battle.pbRandom(16)
      multipliers[FINAL_DMG_MULT] *= random/100.0
    end
    # STAB
    if type>=0 && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[FINAL_DMG_MULT] *= 2
      else
        multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*1.5).round
      end
    end
    # Type effectiveness
    multipliers[FINAL_DMG_MULT] *= target.damageState.typeMod.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
    multipliers[FINAL_DMG_MULT] = multipliers[FINAL_DMG_MULT].round
    # Burn
    if user.status==PBStatuses::BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[FINAL_DMG_MULT] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*2/3).round
        else
          multipliers[FINAL_DMG_MULT] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect]>0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*2/3).round
        else
          multipliers[FINAL_DMG_MULT] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen]>0 && specialMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*2/3).round
        else
          multipliers[FINAL_DMG_MULT] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
      multipliers[FINAL_DMG_MULT] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[BASE_DMG_MULT] = pbBaseDamageMultiplier(multipliers[BASE_DMG_MULT],user,target)
    # Move-specific final damage modifiers
    multipliers[FINAL_DMG_MULT] = pbModifyDamage(multipliers[FINAL_DMG_MULT],user,target)
  end

  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance>0) ? effectChance : @addlEffect
    if NEWEST_BATTLE_MECHANICS || @function!="0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
end
