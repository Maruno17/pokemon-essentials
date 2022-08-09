class PokeBattle_AI
  #=============================================================================
  #
  #=============================================================================
  def pbTargetsMultiple?(move)
    numTargets = 0
    case move.pbTarget(@user)
    when PBTargets::AllNearFoes
      @battle.eachOtherSideBattler(@user) { |b| numTargets += 1 if b.near?(@user) }
      return numTargets > 1
    when PBTargets::AllNearOthers
      @battle.eachBattler { |b| numTargets += 1 if b.near?(@user) }
      return numTargets > 1
    when PBTargets::UserAndAllies
      @battle.eachSameSideBattler(@user) { |_b| numTargets += 1 }
      return numTargets > 1
    when PBTargets::AllFoes
      @battle.eachOtherSideBattler(@user) { |_b| numTargets += 1 }
      return numTargets > 1
    when PBTargets::AllBattlers
      @battle.eachBattler { |_b| numTargets += 1 }
      return numTargets > 1
    end
    return false
  end

  #=============================================================================
  # Move's type effectiveness
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = PBTypes.getEffectiveness(moveType,defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if PBTypes.ineffective?(moveType,defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                         PBTypes.ineffective?(moveType,defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                         PBTypes.ineffective?(moveType,defType)
    end
    # Delta Stream's weather
    if @battle.pbWeather==PBWeather::StrongWinds
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                         PBTypes.superEffective?(moveType,defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
    return ret
  end

  def pbCalcTypeMod(moveType,user,target)
    return PBTypeEffectiveness::NORMAL_EFFECTIVE if !moveType
    return PBTypeEffectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
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

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(battlerThis, _battlerOther)
    mod1 = PBTypes.getCombinedEffectiveness(battlerThis.type1, target.type1, target.type2)
    return mod1 if battlerThis.type1 == battlerThis.type2
    mod2 = PBTypes.getCombinedEffectiveness(battlerThis.type2, target.type1, target.type2)
    return mod1 * mod2.to_f / PBTypeEffectivenesss::NORMAL_EFFECTIVE
  end

  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(move, target)
    # TODO: Add consideration of user's Mold Breaker.
    move_type = pbRoughType(move)
    typeMod = pbCalcTypeMod(move_type, @user, target)
    # Type effectiveness
    return true if PBTypeEffectiveness.ineffective?(typeMod)
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
      return true if PBTypeEffectiveness.notVeryEffective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && @user.index != target.index && !target.opposes?(@user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(@user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if skill_check(AILevel.best) && target.hasActiveAbility?(:OVERCOAT)
        return true if skill_check(AILevel.high) && target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if target.effects[PBEffects::Substitute] > 0 && move.statusMove? &&
                     !move.ignoresSubstitute?(@user) && @user.index != target.index
      return true if NEWEST_BATTLE_MECHANICS && @user.hasActiveAbility?(:PRANKSTER) &&
                     target.pbHasType?(:DARK) && target.opposes?(@user)
      return true if move.priority>0 && @battle.field.terrain == PBBattleTerrains::Psychic &&
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
    if skill_check(AILevel.high)
      ret = move.pbCalcType(@user)
    end
    return ret
  end

  def pbRoughStat(battler,stat)
    return battler.pbSpeed if skill_check(AILevel.high) && stat==PBStats::SPEED
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = battler.stages[stat]+6
    value = 0
    case stat
    when PBStats::ATTACK then value = battler.attack
    when PBStats::DEFENSE then value = battler.defense
    when PBStats::SPATK then value = battler.spatk
    when PBStats::SPDEF then value = battler.spdef
    when PBStats::SPEED then value = battler.speed
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
    when "010"   # Stomp
      baseDmg *= 2 if target.effects[PBEffects::Minimize]
    # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
    when "06A", "06B", "06C", "06D", "06E"
      baseDmg = move.pbFixedDamage(@user, target)
    when "06F"   # Psywave
      baseDmg = @user.level
    when "070"   # OHKO
      baseDmg = target.totalhp
    when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
      # TODO: Check memory to find the move that did the most damage, and use
      #       that value (if this move counters it, applying this move's
      #       doubling effect if appropriate).
      baseDmg = 60
    when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
      baseDmg = move.pbModifyDamage(baseDmg, @user, target)
    # Bulldoze, Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade,
    # Hex, Brine, Retaliate, Weather Ball, Return, Frustration, Eruption,
    # Crush Grip, Stored Power, Punishment, Flail, Electro Ball, Low Kick,
    # Knock Off, Spit Up, Stomping Tantrum
    when "044", "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085",
         "087", "089", "08A", "08B", "08C", "08E", "08F", "098", "099", "09A",
         "0F0", "113", "166"
      baseDmg = move.pbBaseDamage(baseDmg, @user, target)
    when "086"   # Acrobatics
      baseDmg *= 2 if !@user.item || @user.hasActiveItem?(:FLYINGGEM)
    when "08D"   # Gyro Ball
      target_speed = pbRoughStat(target, PBStats::SPEED)
      user_speed = pbRoughStat(@user, PBStats::SPEED)
      baseDmg = [[(25 * target_speed / user_speed).floor, 150].min, 1].max
    when "091"   # Fury Cutter
      baseDmg = move.pbBaseDamage(baseDmg, @user, target)
      baseDmg *= 2 if baseDmg < 160 && @user.effects[PBEffects::FuryCutter] > 0
    when "092"   # Echoed Voice
      factor = @user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
      baseDmg *= [(factor + 1), 5].min
    when "094"   # Present
      baseDmg = 50
    when "095"   # Magnitude
      baseDmg = 71
      baseDmg *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      baseDmg /= 2 if @battle.field.terrain == PBBattleTerrains::Grassy
    when "096"   # Natural Gift
      baseDmg = 0 if !@user.item || !@user.item.is_berry? || !@user.itemActive?
      baseDmg = move.pbNaturalGiftBaseDamage(@user.item_id) if baseDmg > 0
    when "097"   # Trump Card
      dmgs = [200, 80, 60, 50, 40]
      pp_left = [[move.pp - 1, dmgs.length - 1].min, 0].max
      return dmgs[pp_left]
    when "09B"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg, @user, target)
      baseDmg *= 2 if NEWEST_BATTLE_MECHANICS && target.effects[PBEffects::Minimize]
    when "0BD", "0BE"   # Double Kick, Twineedle
      baseDmg *= 2
    when "0BF"   # Triple Kick
      baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
    when "0C0"   # Fury Attack
      if @user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg * 19 / 6).floor   # Average damage dealt
      end
    when "0C1"   # Beat Up
      mult = 0
      @battle.eachInTeamFromBattlerIndex(@user.index) do |pkmn, _i|
        mult += 1 if pkmn && pkmn.able? && pkmn.status == PBStatuses::NONE
      end
      baseDmg *= mult
    when "0C4"   # Solar Beam
      baseDmg = move.pbBaseDamageMultiplier(baseDmg, @user, target)
    when "0D3"   # Rollout
      baseDmg *= 2 if @user.effects[PBEffects::DefenseCurl]
    when "0D4"   # Bide
      # TODO: Maybe make this equal to the highest damage a foe has dealt?
      baseDmg = 40
    when "0E1"   # Final Gambit
      baseDmg = @user.hp
    when "0F7"   # Fling
      if !@user.item || !@user.itemActive? || @user.unlosableItem?(@user.item) ||
         (@user.item.is_berry? && @battle.pbCheckOpposingAbility(:UNNERVE, @user.index))
        baseDmg = 0
      else
        # TODO: Currently assumes a power of 10 if item is unflingable.
        baseDmg = move.pbBaseDamage(baseDmg, @user, target)
      end
    when "144"   # Flying Press
      if GameData::Type.exists?(:FLYING)
        if skill_check(AILevel.high)
          targetTypes = target.pbTypes(true)
          mult = PBTypes.getCombinedEffectiveness(:FLYING,
             targetTypes[0], targetTypes[1], targetTypes[2])
          baseDmg = (baseDmg.to_f * mult / PBTypeEffectiveness::NORMAL_EFFECTIVE).round
        else
          mult = PBTypes.getCombinedEffectiveness(:FLYING,
             target.type1, target.type2, target.effects[PBEffects::Type3])
          baseDmg = (baseDmg.to_f * mult / PBTypeEffectiveness::NORMAL_EFFECTIVE).round
        end
      end
      baseDmg *= 2 if target.effects[PBEffects::Minimize]
    when "175"   # Double Iron Bash
      baseDmg *= 2
      baseDmg *= 2 if target.effects[PBEffects::Minimize]
    end
    return baseDmg
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbRoughDamage(move,target,baseDmg)
    # Fixed damage moves
    return baseDmg if move.is_a?(PokeBattle_FixedDamageMove)

    # Get the move's type
    type = pbRoughType(move)

    ##### Calculate user's attack stat #####
    atk = pbRoughStat(@user,PBStats::ATTACK)
    if move.function=="121"   # Foul Play
      atk = pbRoughStat(target,PBStats::ATTACK)
    elsif move.specialMove?(type)
      if move.function=="121"   # Foul Play
        atk = pbRoughStat(target,PBStats::SPATK)
      else
        atk = pbRoughStat(@user,PBStats::SPATK)
      end
    end

    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target,PBStats::DEFENSE)
    if move.specialMove?(type) && move.function!="122"   # Psyshock
      defense = pbRoughStat(target,PBStats::SPDEF)
    end

    ##### Calculate all multiplier effects #####
    multipliers = [1.0, 1.0, 1.0, 1.0]
    # Ability effects that alter damage
    mold_breaker = false
    if skill_check(AILevel.high) && @user.hasMoldBreaker?
      mold_breaker = true
    end

    if skill_check(AILevel.medium) && @user.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      if ![:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE,
           :REFRIGERATE].include?(@user.ability_id)
        BattleHandlers.triggerDamageCalcUserAbility(@user.ability,
           @user,target,move,multipliers,baseDmg,type)
      end
    end

    if skill_check(AILevel.medium) && !mold_breaker
      @user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           @user,target,move,multipliers,baseDmg,type)
      end
    end

    if skill_check(AILevel.best) && !mold_breaker && target.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      if ![:FILTER, :SOLIDROCK].include?(target.ability_id)
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           @user,target,move,multipliers,baseDmg,type)
      end
    end

    if skill_check(AILevel.best) && !mold_breaker
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           @user,target,move,multipliers,baseDmg,type)
      end
    end

    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if skill_check(AILevel.medium) && @user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      if ![:EXPERTBELT, :LIFEORB].include?(@user.item_id)
        BattleHandlers.triggerDamageCalcUserItem(@user.item,
           @user,target,move,multipliers,baseDmg,type)
      end
      # TODO: Prefer (1.5x?) if item will be consumed and user has Unburden.
    end

    if skill_check(AILevel.best) && target.itemActive?
      # NOTE: Type-weakening berries aren't suitable for checking at the start
      #       of the round.
      if !target.item.is_berry?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,
           @user,target,move,multipliers,baseDmg,type)
      end
    end

    # Global abilities
    if skill_check(AILevel.medium)
      if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
         (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK)
          multipliers[BASE_DMG_MULT] *= 2.0 / 3
        else
          multipliers[BASE_DMG_MULT] *= 4.0 / 3
        end
      end
    end

    # Parental Bond
    if skill_check(AILevel.medium) && @user.hasActiveAbility?(:PARENTALBOND)
      multipliers[BASE_DMG_MULT] *= 1.25
    end

    # Me First
    # TODO

    # Helping Hand - n/a

    # Charge
    if skill_check(AILevel.medium)
      if @user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
        multipliers[BASE_DMG_MULT] *= 2
      end
    end

    # Mud Sport and Water Sport
    if skill_check(AILevel.medium)
      if type == :ELECTRIC
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::MudSport]
          multipliers[BASE_DMG_MULT] /= 3
          break
        end
        if @battle.field.effects[PBEffects::MudSportField]>0
          multipliers[BASE_DMG_MULT] /= 3
        end
      end
      if type == :FIRE
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::WaterSport]
          multipliers[BASE_DMG_MULT] /= 3
          break
        end
        if @battle.field.effects[PBEffects::WaterSportField]>0
          multipliers[BASE_DMG_MULT] /= 3
        end
      end
    end

    # Terrain moves
    if @user.affectedByTerrain? && skill_check(AILevel.medium)
      case @battle.field.terrain
      when PBBattleTerrains::Electric
        multipliers[BASE_DMG_MULT] *= 1.5 if type == :ELECTRIC
      when PBBattleTerrains::Grassy
        multipliers[BASE_DMG_MULT] *= 1.5 if type == :GRASS
      when PBBattleTerrains::Psychic
        multipliers[BASE_DMG_MULT] *= 1.5 if type == :PSYCHIC
      end
    end
    if target.affectedByTerrain? && skill_check(AILevel.medium)
      if @battle.field.terrain==PBBattleTerrains::Misty && type == :DRAGON
        multipliers[BASE_DMG_MULT] /= 2
      end
    end

    # Badge multipliers
    if skill_check(AILevel.high)
      if @battle.internalBattle
        # Don't need to check the Atk/Sp Atk-boosting badges because the AI
        # won't control the player's Pokémon.
        if target.pbOwnedByPlayer?
          if move.physicalMove?(type) && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_DEFENSE
            multipliers[DEF_MULT] *= 1.1
          elsif move.specialMove?(type) && @battle.pbPlayer.numbadges>=NUM_BADGES_BOOST_SPDEF
            multipliers[DEF_MULT] *= 1.1
          end
        end
      end
    end

    # Multi-targeting attacks
    if skill_check(AILevel.high)
      if pbTargetsMultiple?(move)
        multipliers[FINAL_DMG_MULT] *= 0.75
      end
    end

    # Weather
    if skill_check(AILevel.medium)
      case @battle.pbWeather
      when PBWeather::Sun, PBWeather::HarshSun
        if type == :FIRE
          multipliers[FINAL_DMG_MULT] *= 1.5
        elsif type == :WATER
          multipliers[FINAL_DMG_MULT] /= 2
        end
      when PBWeather::Rain, PBWeather::HeavyRain
        if type == :FIRE
          multipliers[FINAL_DMG_MULT] /= 2
        elsif type == :WATER
          multipliers[FINAL_DMG_MULT] *= 1.5
        end
      when PBWeather::Sandstorm
        if target.pbHasType?(:ROCK) && move.specialMove?(type) && move.function!="122"   # Psyshock
          multipliers[DEF_MULT] *= 1.5
        end
      end
    end

    # Critical hits - n/a

    # Random variance - n/a

    # STAB
    if skill_check(AILevel.medium)
      if type && @user.pbHasType?(type)
        if @user.hasActiveAbility?(:ADAPTABILITY)
          multipliers[FINAL_DMG_MULT] *= 2
        else
          multipliers[FINAL_DMG_MULT] = (multipliers[FINAL_DMG_MULT]*1.5).round
        end
      end
    end

    # Type effectiveness
    if skill_check(AILevel.medium)
      typemod = pbCalcTypeMod(type,@user,target)
      multipliers[FINAL_DMG_MULT] *= typemod.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
    end

    # Burn
    if skill_check(AILevel.high)
      if @user.status==PBStatuses::BURN && move.physicalMove?(type) &&
         !@user.hasActiveAbility?(:GUTS) &&
         !(NEWEST_BATTLE_MECHANICS && move.function=="07E")   # Facade
        multipliers[FINAL_DMG_MULT] /= 2
      end
    end

    # Aurora Veil, Reflect, Light Screen
    if skill_check(AILevel.high)
      if !move.ignoresReflect? && !@user.hasActiveAbility?(:INFILTRATOR)
        if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2.0 / 3
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect]>0 && move.physicalMove?(type)
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2.0 / 3
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen]>0 && move.specialMove?(type)
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2.0 / 3
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        end
      end
    end

    # Minimize
    if skill_check(AILevel.high)
      if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(2)
        multipliers[FINAL_DMG_MULT] *= 2
      end
    end

    # Move-specific base damage modifiers
    # TODO

    # Move-specific final damage modifiers
    # TODO

    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[BASE_DMG_MULT]).round, 1].max
    atk     = [(atk     * multipliers[ATK_MULT]).round, 1].max
    defense = [(defense * multipliers[DEF_MULT]).round, 1].max
    damage  = (((2.0 * @user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[FINAL_DMG_MULT]).round, 1].max
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
    crit_stage = [crit_stage, PokeBattle_Move::CRITICAL_HIT_RATIOS.length - 1].min
    return crit_stage
  end

  #=============================================================================
  # Accuracy calculation
  #=============================================================================
  def pbRoughAccuracy(move, target)
    # "Always hit" effects and "always hit" accuracy
    if skill_check(AILevel.medium)
      return 100 if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(1)
      return 100 if target.effects[PBEffects::Telekinesis] > 0
    end
    # Get base accuracy
    baseAcc = move.accuracy
    if skill_check(AILevel.medium)
      baseAcc = move.pbBaseAccuracy(@user, target)
    end
    return 100 if baseAcc == 0 && skill_check(AILevel.medium)
    # Get the move's type
    type = pbRoughType(move)
    # Calculate all modifier effects
    modifiers = []
    modifiers[BASE_ACC]  = baseAcc
    modifiers[ACC_STAGE] = @user.stages[PBStats::ACCURACY]
    modifiers[EVA_STAGE] = target.stages[PBStats::EVASION]
    modifiers[ACC_MULT]  = 1.0
    modifiers[EVA_MULT]  = 1.0
    pbCalcAccuracyModifiers(target, modifiers, move, type)
    # Check if move certainly misses/can't miss
    return 0 if modifiers[BASE_ACC] < 0
    return 100 if modifiers[BASE_ACC] == 0
    # Calculation
    accStage = [[modifiers[ACC_STAGE], -6].max, 6].min + 6
    evaStage = [[modifiers[EVA_STAGE], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[ACC_MULT]).round
    evasion  = (evasion  * modifiers[EVA_MULT]).round
    evasion = 1 if evasion < 1
    return modifiers[BASE_ACC] * accuracy / evasion
  end

  def pbCalcAccuracyModifiers(target,modifiers,move,type)
    mold_breaker = false
    if skill_check(AILevel.medium) && @user.hasMoldBreaker?
      mold_breaker = true
    end
    # Ability effects that alter accuracy calculation
    if skill_check(AILevel.medium)
      if @user.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAbility(@user.ability,
           modifiers, @user, target, move, type)
      end
    end
    if skill_check(AILevel.high)
      @user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
           modifiers, @user, target, move, type)
      end
    end
    if skill_check(AILevel.best)
      if target.abilityActive? && !mold_breaker
        BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
           modifiers, @user, target, move, type)
      end
    end
    # Item effects that alter accuracy calculation
    if skill_check(AILevel.medium)
      if @user.itemActive?
        # TODO: Zoom Lens needs to be checked differently (compare speeds of
        #       user and target).
        BattleHandlers.triggerAccuracyCalcUserItem(@user.item,
           modifiers, @user, target, move, type)
      end
    end
    if skill_check(AILevel.high)
      if target.itemActive?
        BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
           modifiers, @user, target, move, type)
      end
    end
    # Other effects, inc. ones that set ACC_MULT or EVA_STAGE to specific values
    if @battle.field.effects[PBEffects::Gravity] > 0
      modifiers[ACC_MULT] *= 5 / 3.0
    end
    if skill_check(AILevel.medium)
      if @user.effects[PBEffects::MicleBerry]
        modifiers[ACC_MULT] *= 1.2
      end
      modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::Foresight] && modifiers[EVA_STAGE] > 0
      modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[EVA_STAGE] > 0
    end
    # "AI-specific calculations below"
    modifiers[EVA_STAGE] = 0 if move.function == "0A9"   # Chip Away
    modifiers[BASE_ACC] = 0 if ["0A5", "139", "13A", "13B", "13C",   # "Always hit"
                                "147"].include?(move.function)
    if skill_check(AILevel.medium)
      modifiers[BASE_ACC] = 0 if @user.effects[PBEffects::LockOn] > 0 &&
                                 @user.effects[PBEffects::LockOnPos] == target.index
    end
    if skill_check(AILevel.medium)
      if move.function == "006"   # Toxic
        modifiers[BASE_ACC] = 0 if NEWEST_BATTLE_MECHANICS && move.statusMove? &&
                                   @user.pbHasType?(:POISON)
      elsif move.function == "070"   # OHKO moves
        modifiers[BASE_ACC] = move.accuracy + @user.level - target.level
        modifiers[BASE_ACC] = -1 if modifiers[BASE_ACC] <= 0   # Certain miss
        modifiers[ACC_MULT] = 0 if target.level > @user.level
        if skill_check(AILevel.best)
          modifiers[ACC_MULT] = 0 if target.hasActiveAbility?(:STURDY) && !mold_breaker
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
