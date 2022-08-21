class Battle::AI
  #=============================================================================
  #
  #=============================================================================
  def pbTargetsMultiple?(move)
    target_data = move.pbTarget(@user)
    return false if target_data.num_targets <= 1
    num_targets = 0
    case target_data.id
    when :AllAllies
      @battle.allSameSideBattlers(@user).each { |b| num_targets += 1 if b.index != @user.index }
    when :UserAndAllies
      @battle.allSameSideBattlers(@user).each { |_b| num_targets += 1 }
    when :AllNearFoes
      @battle.allOtherSideBattlers(@user).each { |b| num_targets += 1 if b.near?(@user) }
    when :AllFoes
      @battle.allOtherSideBattlers(@user).each { |_b| num_targets += 1 }
    when :AllNearOthers
      @battle.allBattlers.each { |b| num_targets += 1 if b.near?(@user) }
    when :AllBattlers
      @battle.allBattlers.each { |_b| num_targets += 1 }
    end
    return num_targets > 1
  end

  #=============================================================================
  # Move's type effectiveness
  #=============================================================================
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
                                              target.pbHasType?(:FLYING) &&
                                              target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type, i|
        typeMods[i] = pbCalcTypeModSingle(moveType, type, user, target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(pkmn, target)
    mod1 = Effectiveness.calculate(pkmn.types[0], target.types[0], target.types[1])
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if pkmn.types.length > 1
      mod2 = Effectiveness.calculate(pkmn.types[1], target.types[0], target.types[1])
      mod2 = mod2.to_f / Effectivenesss::NORMAL_EFFECTIVE
    end
    return mod1 * mod2
  end

  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(move, target)
    # TODO: Add consideration of user's Mold Breaker.
    move_type = pbRoughType(move)
    typeMod = pbCalcTypeMod(move_type, @user, target)
    # Type effectiveness
    return true if move.damagingMove? && Effectiveness.ineffective?(typeMod)
    # Immunity due to ability/item/other effects
    if skill_check(AILevel.medium)
      case move_type
      when :GROUND
        # TODO: Split target.airborne? into separate parts to allow different
        #       skill levels to apply to each part.
        return true if target.airborne? && !move.hitsFlyingTargets?
      when :FIRE
        return true if target.hasActiveAbility?(:FLASHFIRE)
      when :WATER
        return true if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])
      when :GRASS
        return true if target.hasActiveAbility?(:SAPSIPPER)
      when :ELECTRIC
        return true if target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
      end
      return true if move.damagingMove? && Effectiveness.not_very_effective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && @user.index != target.index && !target.opposes?(@user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.statusMove? && move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(@user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if skill_check(AILevel.best) && target.hasActiveAbility?(:OVERCOAT)
        return true if skill_check(AILevel.high) && target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if move.statusMove? && target.effects[PBEffects::Substitute] > 0 &&
                     !move.ignoresSubstitute?(@user) && @user.index != target.index
      return true if move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
                     @user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK) &&
                     target.opposes?(@user)
      return true if move.priority > 0 && @battle.field.terrain == :Psychic &&
                     target.affectedByTerrain? && target.opposes?(@user)
      # TODO: Dazzling/Queenly Majesty go here.
    end
    return false
  end

  #=============================================================================
  # Get approximate properties for a battler
  #=============================================================================
  def pbRoughType(move)
    ret = move.type
    ret = move.pbCalcType(@user) if skill_check(AILevel.high)
    return ret
  end

  def pbRoughStat(battler, stat)
    return battler.pbSpeed if skill_check(AILevel.high) && stat == :SPEED
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    stage = battler.stages[stat] + 6
    value = 0
    case stat
    when :ATTACK          then value = battler.attack
    when :DEFENSE         then value = battler.defense
    when :SPECIAL_ATTACK  then value = battler.spatk
    when :SPECIAL_DEFENSE then value = battler.spdef
    when :SPEED           then value = battler.speed
    end
    return (value.to_f * stageMul[stage] / stageDiv[stage]).floor
  end

  #=============================================================================
  # Get a better move's base damage value
  #=============================================================================
  def pbMoveBaseDamage(move, target)
    baseDmg = move.baseDamage
    baseDmg = 60 if baseDmg == 1
    return baseDmg if !skill_check(AILevel.medium)
    # Covers all function codes which have their own def pbBaseDamage
    case move.function
    # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
    when "FixedDamage20", "FixedDamage40", "FixedDamageHalfTargetHP",
         "FixedDamageUserLevel", "LowerTargetHPToUserHP"
      baseDmg = move.pbFixedDamage(@user, target)
    when "FixedDamageUserLevelRandom"   # Psywave
      baseDmg = @user.level
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      baseDmg = 200
    when "CounterPhysicalDamage", "CounterSpecialDamage", "CounterDamagePlusHalf"
      baseDmg = 60
    when "DoublePowerIfTargetUnderwater", "DoublePowerIfTargetUnderground",
         "BindTargetDoublePowerIfTargetUnderwater"
      baseDmg = move.pbModifyDamage(baseDmg, @user, target)
    # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
    # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
    # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
    # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
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
      baseDmg = move.pbBaseDamage(baseDmg, @user, target)
    when "DoublePowerIfUserHasNoItem"   # Acrobatics
      baseDmg *= 2 if !@user.item || @user.hasActiveItem?(:FLYINGGEM)
    when "PowerHigherWithTargetFasterThanUser"   # Gyro Ball
      targetSpeed = pbRoughStat(target, :SPEED)
      userSpeed = pbRoughStat(@user, :SPEED)
      baseDmg = [[(25 * targetSpeed / userSpeed).floor, 150].min, 1].max
    when "RandomlyDamageOrHealTarget"   # Present
      baseDmg = 50
    when "RandomPowerDoublePowerIfTargetUnderground"   # Magnitude
      baseDmg = 71
      baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")   # Dig
    when "TypeAndPowerDependOnUserBerry"   # Natural Gift
      baseDmg = move.pbNaturalGiftBaseDamage(@user.item_id)
    when "PowerHigherWithUserHeavierThanTarget"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg, @user, target)
      baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && skill_check(AILevel.medium) &&
                      target.effects[PBEffects::Minimize]
    when "AlwaysCriticalHit", "HitTwoTimes", "HitTwoTimesPoisonTarget"   # Frost Breath, Double Kick, Twineedle
      baseDmg *= 2
    when "HitThreeTimesPowersUpWithEachHit"   # Triple Kick
      baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
    when "HitTwoToFiveTimes"   # Fury Attack
      if @user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 31 / 10).floor   # Average damage dealt
      end
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
      if @user.isSpecies?(:GRENINJA) && @user.form == 2
        baseDmg *= 4   # 3 hits at 20 power = 4 hits at 15 power
      elsif @user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 31 / 10).floor   # Average damage dealt
      end
    when "HitOncePerUserTeamMember"   # Beat Up
      mult = 0
      @battle.eachInTeamFromBattlerIndex(@user.index) do |pkmn, _i|
        mult += 1 if pkmn&.able? && pkmn.status == :NONE
      end
      baseDmg *= mult
    when "TwoTurnAttackOneTurnInSun"   # Solar Beam
      baseDmg = move.pbBaseDamageMultiplier(baseDmg, @user, target)
    when "MultiTurnAttackPowersUpEachTurn"   # Rollout
      baseDmg *= 2 if @user.effects[PBEffects::DefenseCurl]
    when "MultiTurnAttackBideThenReturnDoubleDamage"   # Bide
      baseDmg = 40
    when "UserFaintsFixedDamageUserHP"   # Final Gambit
      baseDmg = @user.hp
    when "EffectivenessIncludesFlyingType"   # Flying Press
      if GameData::Type.exists?(:FLYING)
        if skill_check(AILevel.high)
          targetTypes = target.pbTypes(true)
          mult = Effectiveness.calculate(
            :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
          )
        else
          mult = Effectiveness.calculate(
            :FLYING, target.types[0], target.types[1], target.effects[PBEffects::Type3]
          )
        end
        baseDmg = (baseDmg.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
      end
      baseDmg *= 2 if skill_check(AILevel.medium) && target.effects[PBEffects::Minimize]
    when "DoublePowerIfUserLastMoveFailed"   # Stomping Tantrum
      baseDmg *= 2 if @user.lastRoundMoveFailed
    when "HitTwoTimesFlinchTarget"   # Double Iron Bash
      baseDmg *= 2
      baseDmg *= 2 if skill_check(AILevel.medium) && target.effects[PBEffects::Minimize]
    end
    return baseDmg
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbRoughDamage(move, target, baseDmg)
    # Fixed damage moves
    return baseDmg if move.is_a?(Battle::Move::FixedDamageMove)

    # Get the move's type
    type = pbRoughType(move)

    ##### Calculate user's attack stat #####
    atk = pbRoughStat(@user, :ATTACK)
    if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
      atk = pbRoughStat(target, :ATTACK)
    elsif move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack"   # Body Press
      atk = pbRoughStat(@user, :DEFENSE)
    elsif move.specialMove?(type)
      if move.function == "UseTargetAttackInsteadOfUserAttack"   # Foul Play
        atk = pbRoughStat(target, :SPECIAL_ATTACK)
      else
        atk = pbRoughStat(@user, :SPECIAL_ATTACK)
      end
    end

    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target, :DEFENSE)
    if move.specialMove?(type) && move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
      defense = pbRoughStat(target, :SPECIAL_DEFENSE)
    end

    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    # Ability effects that alter damage
    moldBreaker = skill_check(AILevel.high) && target.hasMoldBreaker?

    if skill_check(AILevel.medium) && @user.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          @user.ability, @user, target, move, multipliers, baseDmg, type
        )
      end
    end

    if skill_check(AILevel.medium) && !moldBreaker
      @user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, @user, target, move, multipliers, baseDmg, type
        )
      end
    end

    if skill_check(AILevel.best) && !moldBreaker && target.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:FILTER, :SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, @user, target, move, multipliers, baseDmg, type
        )
      end
    end

    if skill_check(AILevel.best) && !moldBreaker
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, @user, target, move, multipliers, baseDmg, type
        )
      end
    end

    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if skill_check(AILevel.medium) && @user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT, :LIFEORB]
      if !itemBlacklist.include?(@user.item_id)
        Battle::ItemEffects.triggerDamageCalcFromUser(
          @user.item, @user, target, move, multipliers, baseDmg, type
        )
        @user.effects[PBEffects::GemConsumed] = nil   # Untrigger consuming of Gems
      end
      # TODO: Prefer (1.5x?) if item will be consumed and user has Unburden.
    end

    if skill_check(AILevel.best) &&
       target.itemActive? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, @user, target, move, multipliers, baseDmg, type
      )
    end

    # Global abilities
    if skill_check(AILevel.medium) &&
       ((@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
        (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY))
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end

    # Parental Bond
    if skill_check(AILevel.medium) && @user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end

    # Me First
    # TODO

    # Helping Hand - n/a

    # Charge
    if skill_check(AILevel.medium) &&
       @user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end

    # Mud Sport and Water Sport
    if skill_check(AILevel.medium)
      if type == :ELECTRIC
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end

    # Terrain moves
    if skill_check(AILevel.medium)
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && @user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && @user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && @user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
    end

    # Badge multipliers
    if skill_check(AILevel.high) && @battle.internalBattle && target.pbOwnedByPlayer?
      # Don't need to check the Atk/Sp Atk-boosting badges because the AI
      # won't control the player's Pokémon.
      if move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end

    # Multi-targeting attacks
    if skill_check(AILevel.high) && pbTargetsMultiple?(move)
      multipliers[:final_damage_multiplier] *= 0.75
    end

    # Weather
    if skill_check(AILevel.medium)
      case @user.effectiveWeather
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
        if target.pbHasType?(:ROCK) && move.specialMove?(type) &&
           move.function != "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      end
    end

    # Critical hits - n/a

    # Random variance - n/a

    # STAB
    if skill_check(AILevel.medium) && type && @user.pbHasType?(type)
      if @user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end

    # Type effectiveness
    if skill_check(AILevel.medium)
      typemod = pbCalcTypeMod(type, @user, target)
      multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    end

    # Burn
    if skill_check(AILevel.high) && move.physicalMove?(type) &&
       @user.status == :BURN && !@user.hasActiveAbility?(:GUTS) &&
       !(Settings::MECHANICS_GENERATION >= 6 &&
         move.function == "DoublePowerIfUserPoisonedBurnedParalyzed")   # Facade
      multipliers[:final_damage_multiplier] /= 2
    end

    # Aurora Veil, Reflect, Light Screen
    if skill_check(AILevel.high) && !move.ignoresReflect? && !@user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end

    # Minimize
    if skill_check(AILevel.high) && target.effects[PBEffects::Minimize] && move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end

    # Move-specific base damage modifiers
    # TODO

    # Move-specific final damage modifiers
    # TODO

    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * @user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    return damage.floor
  end

  #=============================================================================
  # Critical hit rate calculation
  #=============================================================================
  def pbRoughCriticalHitStage(move, target)
    return -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    mold_breaker = (skill_check(AILevel.medium) && @user.hasMoldBreaker?)
    crit_stage = 0
    # Ability effects that alter critical hit rate
    if skill_check(AILevel.medium) && @user.abilityActive?
      crit_stage = BattleHandlers.triggerCriticalCalcUserAbility(@user.ability, @user, target, crit_stage)
      return -1 if crit_stage < 0
    end
    if skill_check(AILevel.best) && !mold_breaker && target.abilityActive?
      crit_stage = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability, @user, target, crit_stage)
      return -1 if crit_stage < 0
    end
    # Item effects that alter critical hit rate
    if skill_check(AILevel.medium) && @user.itemActive?
      crit_stage = BattleHandlers.triggerCriticalCalcUserItem(@user.item, @user, target, crit_stage)
      return -1 if crit_stage < 0
    end
    if skill_check(AILevel.high) && target.itemActive?
      crit_stage = BattleHandlers.triggerCriticalCalcTargetItem(target.item, @user, target, crit_stage)
      return -1 if crit_stage < 0
    end
    # Other effects
    case move.pbCritialOverride(@user, target)
    when 1  then return 99
    when -1 then return -1
    end
    return 99 if crit_stage > 50   # Merciless
    return 99 if @user.effects[PBEffects::LaserFocus] > 0
    crit_stage += 1 if move.highCriticalRate?
    crit_stage += @user.effects[PBEffects::FocusEnergy]
    crit_stage += 1 if @user.inHyperMode? && move.type == :SHADOW
    crit_stage = [crit_stage, Battle::Move::CRITICAL_HIT_RATIOS.length - 1].min
    return crit_stage
  end

  #=============================================================================
  # Accuracy calculation
  #=============================================================================
  def pbRoughAccuracy(move, target)
    # "Always hit" effects and "always hit" accuracy
    if skill_check(AILevel.medium)
      return 100 if target.effects[PBEffects::Minimize] && move.tramplesMinimize? &&
                    Settings::MECHANICS_GENERATION >= 6
      return 100 if target.effects[PBEffects::Telekinesis] > 0
    end
    # Get base accuracy
    baseAcc = move.accuracy
    baseAcc = move.pbBaseAccuracy(@user, target) if skill_check(AILevel.medium)
    return 100 if baseAcc == 0 && skill_check(AILevel.medium)
    # Get the move's type
    type = pbRoughType(move)
    # Calculate all modifier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = @user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(target, modifiers, move, type)
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

  def pbCalcAccuracyModifiers(target, modifiers, move, type)
    moldBreaker = (skill_check(AILevel.medium) && target.hasMoldBreaker?)
    # Ability effects that alter accuracy calculation
    if skill_check(AILevel.medium) && @user.abilityActive?
      Battle::AbilityEffects.triggerAccuracyCalcFromUser(
        @user.ability, modifiers, @user, target, move, type
      )
    end
    if skill_check(AILevel.high)
      @user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerAccuracyCalcFromAlly(
          b.ability, modifiers, @user, target, move, type
        )
      end
    end
    if skill_check(AILevel.best) && target.abilityActive? && !moldBreaker
      Battle::AbilityEffects.triggerAccuracyCalcFromTarget(
        target.ability, modifiers, @user, target, move, type
      )
    end
    # Item effects that alter accuracy calculation
    if skill_check(AILevel.medium) && @user.itemActive?
      # TODO: Zoom Lens needs to be checked differently (compare speeds of
      #       user and target).
      Battle::ItemEffects.triggerAccuracyCalcFromUser(
        @user.item, modifiers, @user, target, move, type
      )
    end
    if skill_check(AILevel.high) && target.itemActive?
      Battle::ItemEffects.triggerAccuracyCalcFromTarget(
        target.item, modifiers, @user, target, move, type
      )
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
    if @battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if skill_check(AILevel.medium)
      if @user.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
    # "AI-specific calculations below"
    modifiers[:evasion_stage] = 0 if move.function == "IgnoreTargetDefSpDefEvaStatStages"   # Chip Away
    if skill_check(AILevel.medium)
      modifiers[:base_accuracy] = 0 if @user.effects[PBEffects::LockOn] > 0 &&
                                       @user.effects[PBEffects::LockOnPos] == target.index
    end
    if skill_check(AILevel.medium)
      if move.function == "BadPoisonTarget" &&   # Toxic
         Settings::MORE_TYPE_EFFECTS && move.statusMove? && @user.pbHasType?(:POISON)
        modifiers[:base_accuracy] = 0
      end
      if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(move.function)
        modifiers[:base_accuracy] = move.accuracy + @user.level - target.level
        modifiers[:accuracy_multiplier] = 0 if target.level > @user.level
        if skill_check(AILevel.best) && target.hasActiveAbility?(:STURDY)
          modifiers[:accuracy_multiplier] = 0
        end
      end
    end
  end

  #=============================================================================
  # Check if battler has a move that meets the criteria in the block provided
  #=============================================================================
  def check_for_move(battler)
    ret = false
    battler.eachMove do |move|
      next unless yield move
      ret = true
      break
    end
    return ret
  end
end
