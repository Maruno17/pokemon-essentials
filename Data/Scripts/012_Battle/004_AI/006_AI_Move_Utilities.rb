class PokeBattle_AI
  #=============================================================================
  #
  #=============================================================================
  def pbTargetsMultiple?(move,user)
    numTargets = 0
    case move.pbTarget(user)
    when PBTargets::AllNearFoes
      @battle.eachOtherSideBattler(user) { |b| numTargets += 1 if b.near?(user) }
      return numTargets>1
    when PBTargets::AllNearOthers
      @battle.eachBattler { |b| numTargets += 1 if b.near?(user) }
      return numTargets>1
    when PBTargets::UserAndAllies
      @battle.eachSameSideBattler(user) { |_b| numTargets += 1 }
      return numTargets>1
    when PBTargets::AllFoes
      @battle.eachOtherSideBattler(user) { |_b| numTargets += 1 }
      return numTargets>1
    when PBTargets::AllBattlers
      @battle.eachBattler { |_b| numTargets += 1 }
      return numTargets>1
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

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(battlerThis,_battlerOther)
    mod1 = PBTypes.getCombinedEffectiveness(battlerThis.type1,target.type1,target.type2)
    mod2 = PBTypeEffectiveness::NORMAL_EFFECTIVE
    if battlerThis.type1!=battlerThis.type2
      mod2 = PBTypes.getCombinedEffectiveness(battlerThis.type2,target.type1,target.type2)
    end
    return mod1*mod2   # Normal effectiveness is 64 here
  end

  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(score,move,user,target,skill)
    type = pbRoughType(move,user,skill)
    typeMod = pbCalcTypeMod(type,user,target)
    # Type effectiveness
    return true if PBTypes.ineffective?(typeMod) || score<=0
    # Immunity due to ability/item/other effects
    if skill>=PBTrainerAI.mediumSkill
      if isConst?(move.type,PBTypes,:GROUND)
        return true if target.airborne? && !move.hitsFlyingTargets?
      elsif isConst?(move.type,PBTypes,:FIRE)
        return true if target.hasActiveAbility?(:FLASHFIRE)
      elsif isConst?(move.type,PBTypes,:WATER)
        return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
      elsif isConst?(move.type,PBTypes,:GRASS)
        return true if target.hasActiveAbility?(:SAPSIPPER)
      elsif isConst?(move.type,PBTypes,:ELECTRIC)
        return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
      end
      return true if PBTypes.notVeryEffective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && user.index!=target.index && !target.opposes?(user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if target.hasActiveAbility?(:OVERCOAT)
        return true if target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
                     !move.ignoresSubstitute?(user) && user.index!=target.index
      return true if NEWEST_BATTLE_MECHANICS && user.hasActiveAbility?(:PRANKSTER) &&
                     target.pbHasType?(:DARK) && target.opposes?(user)
      return true if move.priority>0 && @battle.field.terrain==PBBattleTerrains::Psychic &&
                     target.affectedByTerrain? && target.opposes?(user)
    end
    return false
  end

  #=============================================================================
  # Get approximate properties for a battler
  #=============================================================================
  def pbRoughType(move,user,skill)
    ret = move.type
    if skill>=PBTrainerAI.highSkill
      ret = move.pbCalcType(user)
    end
    return ret
  end

  def pbRoughStat(battler,stat,skill)
    return battler.pbSpeed if skill>=PBTrainerAI.highSkill && stat==PBStats::SPEED
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = battler.stages[stat]+6
    value = 0
    case stat
    when PBStats::ATTACK;  value = battler.attack
    when PBStats::DEFENSE; value = battler.defense
    when PBStats::SPATK;   value = battler.spatk
    when PBStats::SPDEF;   value = battler.spdef
    when PBStats::SPEED;   value = battler.speed
    end
    return (value.to_f*stageMul[stage]/stageDiv[stage]).floor
  end

  #=============================================================================
  # Get a better move's base damage value
  #=============================================================================
  def pbMoveBaseDamage(move,user,target,skill)
    baseDmg = move.baseDamage
    baseDmg = 60 if baseDmg==1
    return baseDmg if skill<PBTrainerAI.mediumSkill
    # Covers all function codes which have their own def pbBaseDamage
    case move.function
    when "010"   # Stomp
      baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
    # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
    when "06A", "06B", "06C", "06D", "06E"
      baseDmg = move.pbFixedDamage(user,target)
    when "06F"   # Psywave
      baseDmg = user.level
    when "070"   # OHKO
      baseDmg = 200
    when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
      baseDmg = 60
    when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
      baseDmg = move.pbModifyDamage(baseDmg,user,target)
    # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
    # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
    # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
    # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
    when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
         "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
         "098", "099", "09A", "0F7", "113"
      baseDmg = move.pbBaseDamage(baseDmg,user,target)
    when "086"   # Acrobatics
      baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
    when "08D"   # Gyro Ball
      targetSpeed = pbRoughStat(target,PBStats::SPEED,skill)
      userSpeed = pbRoughStat(user,PBStats::SPEED,skill)
      baseDmg = [[(25*targetSpeed/userSpeed).floor,150].min,1].max
    when "094"   # Present
      baseDmg = 50
    when "095"   # Magnitude
      baseDmg = 71
      baseDmg *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
    when "096"   # Natural Gift
      baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
    when "09B"   # Heavy Slam
      baseDmg = move.pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if NEWEST_BATTLE_MECHANICS && skill>=PBTrainerAI.mediumSkill &&
                      target.effects[PBEffects::Minimize]
    when "0A0", "0BD", "0BE"   # Frost Breath, Double Kick, Twineedle
      baseDmg *= 2
    when "0BF"   # Triple Kick
      baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
    when "0C0"   # Fury Attack
      if user.hasActiveAbility?(:SKILLLINK)
        baseDmg *= 5
      else
        baseDmg = (baseDmg*19/6).floor   # Average damage dealt
      end
    when "0C1"   # Beat Up
      mult = 0
      @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,_i|
        mult += 1 if pkmn && pkmn.able? && pkmn.status==PBStatuses::NONE
      end
      baseDmg *= mult
    when "0C4"   # Solar Beam
      baseDmg = move.pbBaseDamageMultiplier(baseDmg,user,target)
    when "0D3"   # Rollout
      baseDmg *= 2 if user.effects[PBEffects::DefenseCurl]
    when "0D4"   # Bide
      baseDmg = 40
    when "0E1"   # Final Gambit
      baseDmg = user.hp
    when "144"   # Flying Press
      type = getConst(PBTypes,:FLYING) || -1
      if type>=0
        if skill>=PBTrainerAI.highSkill
          targetTypes = target.pbTypes(true)
          mult = PBTypes.getCombinedEffectiveness(type,
             targetTypes[0],targetTypes[1],targetTypes[2])
          baseDmg = (baseDmg.to_f*mult/PBTypeEffectiveness::NORMAL_EFFECTIVE).round
        else
          mult = PBTypes.getCombinedEffectiveness(type,
             target.type1,target.type2,target.effects[PBEffects::Type3])
          baseDmg = (baseDmg.to_f*mult/PBTypeEffectiveness::NORMAL_EFFECTIVE).round
        end
      end
      baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
    when "166"   # Stomping Tantrum
      baseDmg *= 2 if user.lastRoundMoveFailed
    when "175"   # Double Iron Bash
      baseDmg *= 2
      baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
    end
    return baseDmg
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbRoughDamage(move,user,target,skill,baseDmg)
    # Fixed damage moves
    return baseDmg if move.is_a?(PokeBattle_FixedDamageMove)
    # Get the move's type
    type = pbRoughType(move,user,skill)
    ##### Calculate user's attack stat #####
    atk = pbRoughStat(user,PBStats::ATTACK,skill)
    if move.function=="121"   # Foul Play
      atk = pbRoughStat(target,PBStats::ATTACK,skill)
    elsif move.specialMove?(type)
      if move.function=="121"   # Foul Play
        atk = pbRoughStat(target,PBStats::SPATK,skill)
      else
        atk = pbRoughStat(user,PBStats::SPATK,skill)
      end
    end
    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target,PBStats::DEFENSE,skill)
    if move.specialMove?(type) && move.function!="122"   # Psyshock
      defense = pbRoughStat(target,PBStats::SPDEF,skill)
    end
    ##### Calculate all multiplier effects #####
    multipliers = [1.0, 1.0, 1.0, 1.0]
    # Ability effects that alter damage
    moldBreaker = false
    if skill>=PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    if skill>=PBTrainerAI.mediumSkill && user.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:ANALYTIC,:SNIPER,:TINTEDLENS,:AERILATE,:PIXILATE,:REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if !isConst?(move.id,PBMoves,m)
        canCheck = false
        break
      end
      if canCheck
        BattleHandlers.triggerDamageCalcUserAbility(user.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.mediumSkill && !moldBreaker
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
      # NOTE: These abilities aren't suitable for checking at the start of the
      #       round.
      abilityBlacklist = [:FILTER,:SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if !isConst?(move.id,PBMoves,m)
        canCheck = false
        break
      end
      if canCheck
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && !moldBreaker
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    # NOTE: Type-boosting gems aren't suitable for checking at the start of the
    #       round.
    if skill>=PBTrainerAI.mediumSkill && user.itemActive?
      # NOTE: These items aren't suitable for checking at the start of the
      #       round.
      itemBlacklist = [:EXPERTBELT,:LIFEORB]
      if !itemBlacklist.include?(user.item_id)
        BattleHandlers.triggerDamageCalcUserItem(user.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill && target.itemActive?
      # NOTE: Type-weakening berries aren't suitable for checking at the start
      #       of the round.
      if !target.item.is_berry?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Global abilities
    if skill>=PBTrainerAI.mediumSkill
      if (@battle.pbCheckGlobalAbility(:DARKAURA) && isConst?(type,PBTypes,:DARK)) ||
         (@battle.pbCheckGlobalAbility(:FAIRYAURA) && isConst?(type,PBTypes,:FAIRY))
        if @battle.pbCheckGlobalAbility(:AURABREAK)
          multipliers[BASE_DMG_MULT] *= 2/3
        else
          multipliers[BASE_DMG_MULT] *= 4/3
        end
      end
    end
    # Parental Bond
    if skill>=PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
      multipliers[BASE_DMG_MULT] *= 1.25
    end
    # Me First
    # TODO
    # Helping Hand - n/a
    # Charge
    if skill>=PBTrainerAI.mediumSkill
      if user.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
        multipliers[BASE_DMG_MULT] *= 2
      end
    end
    # Mud Sport and Water Sport
    if skill>=PBTrainerAI.mediumSkill
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
    end
    # Terrain moves
    if user.affectedByTerrain? && skill>=PBTrainerAI.mediumSkill
      case @battle.field.terrain
      when PBBattleTerrains::Electric
        if isConst?(type,PBTypes,:ELECTRIC)
          multipliers[BASE_DMG_MULT] *= 1.5
        end
      when PBBattleTerrains::Grassy
        if isConst?(type,PBTypes,:GRASS)
          multipliers[BASE_DMG_MULT] *= 1.5
        end
      when PBBattleTerrains::Psychic
        if isConst?(type,PBTypes,:PSYCHIC)
          multipliers[BASE_DMG_MULT] *= 1.5
        end
      end
    end
    if target.affectedByTerrain? && skill>=PBTrainerAI.mediumSkill
      if @battle.field.terrain==PBBattleTerrains::Misty && isConst?(type,PBTypes,:DRAGON)
        multipliers[BASE_DMG_MULT] /= 2
      end
    end
    # Badge multipliers
    if skill>=PBTrainerAI.highSkill
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
    if skill>=PBTrainerAI.highSkill
      if pbTargetsMultiple?(move,user)
        multipliers[FINAL_DMG_MULT] *= 0.75
      end
    end
    # Weather
    if skill>=PBTrainerAI.mediumSkill
      case @battle.pbWeather
      when PBWeather::Sun, PBWeather::HarshSun
        if isConst?(type,PBTypes,:FIRE)
          multipliers[FINAL_DMG_MULT] *= 1.5
        elsif isConst?(type,PBTypes,:WATER)
          multipliers[FINAL_DMG_MULT] /= 2
        end
      when PBWeather::Rain, PBWeather::HeavyRain
        if isConst?(type,PBTypes,:FIRE)
          multipliers[FINAL_DMG_MULT] /= 2
        elsif isConst?(type,PBTypes,:WATER)
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
    if skill>=PBTrainerAI.mediumSkill
      if type>=0 && user.pbHasType?(type)
        if user.hasActiveAbility?(:ADAPTABILITY)
          multipliers[FINAL_DMG_MULT] *= 2
        else
          multipliers[FINAL_DMG_MULT] *= 1.5
        end
      end
    end
    # Type effectiveness
    if skill>=PBTrainerAI.mediumSkill
      typemod = pbCalcTypeMod(type,user,target)
      multipliers[FINAL_DMG_MULT] *= typemod.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
    end
    # Burn
    if skill>=PBTrainerAI.highSkill
      if user.status==PBStatuses::BURN && move.physicalMove?(type) &&
         !user.hasActiveAbility?(:GUTS) &&
         !(NEWEST_BATTLE_MECHANICS && move.function=="07E")   # Facade
        multipliers[FINAL_DMG_MULT] /= 2
      end
    end
    # Aurora Veil, Reflect, Light Screen
    if skill>=PBTrainerAI.highSkill
      if !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
        if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2/3.0
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect]>0 && move.physicalMove?(type)
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2/3.0
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen]>0 && move.specialMove?(type)
          if @battle.pbSideBattlerCount(target)>1
            multipliers[FINAL_DMG_MULT] *= 2/3.0
          else
            multipliers[FINAL_DMG_MULT] /= 2
          end
        end
      end
    end
    # Minimize
    if skill>=PBTrainerAI.highSkill
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
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[FINAL_DMG_MULT]).round, 1].max
    # "AI-specific calculations below"
    # Increased critical hit rates
    if skill>=PBTrainerAI.mediumSkill
      c = 0
      # Ability effects that alter critical hit rate
      if c>=0 && user.abilityActive?
        c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
      end
      if skill>=PBTrainerAI.bestSkill
        if c>=0 && !moldBreaker && target.abilityActive?
          c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
        end
      end
      # Item effects that alter critical hit rate
      if c>=0 && user.itemActive?
        c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
      end
      if skill>=PBTrainerAI.bestSkill
        if c>=0 && target.itemActive?
          c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
        end
      end
      # Other efffects
      c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
      if c>=0
        c += 1 if move.highCriticalRate?
        c += user.effects[PBEffects::FocusEnergy]
        c += 1 if user.inHyperMode? && isConst?(move.type,PBTypes,:SHADOW)
      end
      if c>=0
        c = 4 if c>4
        damage += damage*0.1*c
      end
    end
    return damage.floor
  end

  #=============================================================================
  # Accuracy calculation
  #=============================================================================
  def pbRoughAccuracy(move,user,target,skill)
    # "Always hit" effects and "always hit" accuracy
    if skill>=PBTrainerAI.mediumSkill
      return 125 if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(1)
      return 125 if target.effects[PBEffects::Telekinesis]>0
    end
    baseAcc = move.accuracy
    if skill>=PBTrainerAI.highSkill
      baseAcc = move.pbBaseAccuracy(user,target)
    end
    return 125 if baseAcc==0 && skill>=PBTrainerAI.mediumSkill
    # Get the move's type
    type = pbRoughType(move,user,skill)
    # Calculate all modifier effects
    modifiers = []
    modifiers[BASE_ACC]  = baseAcc
    modifiers[ACC_STAGE] = user.stages[PBStats::ACCURACY]
    modifiers[EVA_STAGE] = target.stages[PBStats::EVASION]
    modifiers[ACC_MULT]  = 1.0
    modifiers[EVA_MULT]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
    # Check if move can't miss
    return 125 if modifiers[BASE_ACC]==0
    # Calculation
    accStage = [[modifiers[ACC_STAGE],-6].max,6].min + 6
    evaStage = [[modifiers[EVA_STAGE],-6].max,6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[ACC_MULT]).round
    evasion  = (evasion  * modifiers[EVA_MULT]).round
    evasion = 1 if evasion<1
    return modifiers[BASE_ACC] * accuracy / evasion
  end

  def pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
    moldBreaker = false
    if skill>=PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    # Ability effects that alter accuracy calculation
    if skill>=PBTrainerAI.mediumSkill
      if user.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
           modifiers,user,target,move,type)
      end
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
           modifiers,user,target,move,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill
      if target.abilityActive? && !moldBreaker
        BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
           modifiers,user,target,move,type)
      end
    end
    # Item effects that alter accuracy calculation
    if skill>=PBTrainerAI.mediumSkill
      if user.itemActive?
        BattleHandlers.triggerAccuracyCalcUserItem(user.item,
           modifiers,user,target,move,type)
      end
    end
    if skill>=PBTrainerAI.bestSkill
      if target.itemActive?
        BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
           modifiers,user,target,move,type)
      end
    end
    # Other effects, inc. ones that set ACC_MULT or EVA_STAGE to specific values
    if skill>=PBTrainerAI.mediumSkill
      if @battle.field.effects[PBEffects::Gravity]>0
        modifiers[ACC_MULT] *= 5/3.0
      end
      if user.effects[PBEffects::MicleBerry]
        modifiers[ACC_MULT] *= 1.2
      end
      modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::Foresight] && modifiers[EVA_STAGE]>0
      modifiers[EVA_STAGE] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[EVA_STAGE]>0
    end
    # "AI-specific calculations below"
    if skill>=PBTrainerAI.mediumSkill
      modifiers[EVA_STAGE] = 0 if move.function=="0A9"   # Chip Away
      modifiers[BASE_ACC] = 0 if ["0A5","139","13A","13B","13C",   # "Always hit"
                                  "147"].include?(move.function)
      modifiers[BASE_ACC] = 0 if user.effects[PBEffects::LockOn]>0 &&
                                 user.effects[PBEffects::LockOnPos]==target.index
    end
    if skill>=PBTrainerAI.highSkill
      if move.function=="006"   # Toxic
        modifiers[BASE_ACC] = 0 if NEWEST_BATTLE_MECHANICS && move.statusMove? &&
                                   user.pbHasType?(:POISON)
      end
      if move.function=="070"   # OHKO moves
        modifiers[BASE_ACC] = move.accuracy+user.level-target.level
        modifiers[ACC_MULT] = 0 if target.level>user.level
        if skill>=PBTrainerAI.bestSkill
          modifiers[ACC_MULT] = 0 if target.hasActiveAbility?(:STURDY)
        end
      end
    end
  end
end
