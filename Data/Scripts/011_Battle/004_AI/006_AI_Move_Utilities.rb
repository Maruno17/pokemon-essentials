class PokeBattle_AI
  #=============================================================================
  #
  #=============================================================================
  def pbTargetsMultiple?(move,user)
    target_data = move.pbTarget(user)
    return false if target_data.num_targets <= 1
    num_targets = 0
    case target_data.id
    when :UserAndAllies
      @battle.eachSameSideBattler(user) { |_b| num_targets += 1 }
    when :AllNearFoes
      @battle.eachOtherSideBattler(user) { |b| num_targets += 1 if b.near?(user) }
    when :AllFoes
      @battle.eachOtherSideBattler(user) { |_b| num_targets += 1 }
    when :AllNearOthers
      @battle.eachBattler { |b| num_targets += 1 if b.near?(user) }
    when :AllBattlers
      @battle.eachBattler { |_b| num_targets += 1 }
    end
    return num_targets > 1
  end

  #=============================================================================
  # Move's type effectiveness
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType,defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
    return ret
  end

  def pbCalcTypeMod(moveType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
       target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
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
      tTypes.each_with_index do |type,i|
        typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  # For switching. Determines the effectiveness of a potential switch-in against
  # an opposing battler.
  def pbCalcTypeModPokemon(battlerThis,_battlerOther)
    mod1 = Effectiveness.calculate(battlerThis.type1,target.type1,target.type2)
    mod2 = Effectiveness::NORMAL_EFFECTIVE
    if battlerThis.type1!=battlerThis.type2
      mod2 = Effectiveness.calculate(battlerThis.type2,target.type1,target.type2)
      mod2 = mod2.to_f / Effectivenesss::NORMAL_EFFECTIVE
    end
    return mod1*mod2
  end

  #=============================================================================
  # Immunity to a move because of the target's ability, item or other effects
  #=============================================================================
  def pbCheckMoveImmunity(score,move,user,target,skill)
    type = pbRoughType(move,user,skill)
    typeMod = pbCalcTypeMod(type,user,target)
    # Type effectiveness
    return true if Effectiveness.ineffective?(typeMod) || score<=0
    # Immunity due to ability/item/other effects
    if skill>=PBTrainerAI.mediumSkill
      case type
      when :GROUND
        return true if target.airborne? && !move.hitsFlyingTargets?
      when :FIRE
        return true if target.hasActiveAbility?(:FLASHFIRE)
      when :WATER
        return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
      when :GRASS
        return true if target.hasActiveAbility?(:SAPSIPPER)
      when :ELECTRIC
        return true if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
      end
      return true if Effectiveness.not_very_effective?(typeMod) &&
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
      return true if Settings::MECHANICS_GENERATION >= 7 && user.hasActiveAbility?(:PRANKSTER) &&
                     target.pbHasType?(:DARK) && target.opposes?(user)
      return true if move.priority>0 && @battle.field.terrain == :Psychic &&
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
    return battler.pbSpeed if skill>=PBTrainerAI.highSkill && stat==:SPEED
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = battler.stages[stat]+6
    value = 0
    case stat
    when :ATTACK          then value = battler.attack
    when :DEFENSE         then value = battler.defense
    when :SPECIAL_ATTACK  then value = battler.spatk
    when :SPECIAL_DEFENSE then value = battler.spdef
    when :SPEED           then value = battler.speed
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
      targetSpeed = pbRoughStat(target,:SPEED,skill)
      userSpeed = pbRoughStat(user,:SPEED,skill)
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
      baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && skill>=PBTrainerAI.mediumSkill &&
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
        mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE
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
      if GameData::Type.exists?(:FLYING)
        if skill>=PBTrainerAI.highSkill
          targetTypes = target.pbTypes(true)
          mult = Effectiveness.calculate(:FLYING,
             targetTypes[0],targetTypes[1],targetTypes[2])
          baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
        else
          mult = Effectiveness.calculate(:FLYING,
             target.type1,target.type2,target.effects[PBEffects::Type3])
          baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
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
    atk = pbRoughStat(user,:ATTACK,skill)
    if move.function=="121"   # Foul Play
      atk = pbRoughStat(target,:ATTACK,skill)
    elsif move.specialMove?(type)
      if move.function=="121"   # Foul Play
        atk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
      else
        atk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
      end
    end
    ##### Calculate target's defense stat #####
    defense = pbRoughStat(target,:DEFENSE,skill)
    if move.specialMove?(type) && move.function!="122"   # Psyshock
      defense = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
    end
    ##### Calculate all multiplier effects #####
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
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
        next if move.id != m
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
        next if move.id != m
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
      if target.item && !target.item.is_berry?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,
           user,target,move,multipliers,baseDmg,type)
      end
    end
    # Global abilities
    if skill>=PBTrainerAI.mediumSkill
      if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
         (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
        if @battle.pbCheckGlobalAbility(:AURABREAK)
          multipliers[:base_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        end
      end
    end
    # Parental Bond
    if skill>=PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end
    # Me First
    # TODO
    # Helping Hand - n/a
    # Charge
    if skill>=PBTrainerAI.mediumSkill
      if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
        multipliers[:base_damage_multiplier] *= 2
      end
    end
    # Mud Sport and Water Sport
    if skill>=PBTrainerAI.mediumSkill
      if type == :ELECTRIC
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::MudSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::MudSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::WaterSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::WaterSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end
    # Terrain moves
    if skill>=PBTrainerAI.mediumSkill
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
    end
    # Badge multipliers
    if skill>=PBTrainerAI.highSkill
      if @battle.internalBattle
        # Don't need to check the Atk/Sp Atk-boosting badges because the AI
        # won't control the player's Pokémon.
        if target.pbOwnedByPlayer?
          if move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
            multipliers[:defense_multiplier] *= 1.1
          elsif move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
            multipliers[:defense_multiplier] *= 1.1
          end
        end
      end
    end
    # Multi-targeting attacks
    if skill>=PBTrainerAI.highSkill
      if pbTargetsMultiple?(move,user)
        multipliers[:final_damage_multiplier] *= 0.75
      end
    end
    # Weather
    if skill>=PBTrainerAI.mediumSkill
      case @battle.pbWeather
      when :Sun, :HarshSun
        if type == :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        elsif type == :WATER
          multipliers[:final_damage_multiplier] /= 2
        end
      when :Rain, :HeavyRain
        if type == :FIRE
          multipliers[:final_damage_multiplier] /= 2
        elsif type == :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.pbHasType?(:ROCK) && move.specialMove?(type) && move.function != "122"   # Psyshock
          multipliers[:defense_multiplier] *= 1.5
        end
      end
    end
    # Critical hits - n/a
    # Random variance - n/a
    # STAB
    if skill>=PBTrainerAI.mediumSkill
      if type && user.pbHasType?(type)
        if user.hasActiveAbility?(:ADAPTABILITY)
          multipliers[:final_damage_multiplier] *= 2
        else
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
    end
    # Type effectiveness
    if skill>=PBTrainerAI.mediumSkill
      typemod = pbCalcTypeMod(type,user,target)
      multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
    # Burn
    if skill>=PBTrainerAI.highSkill
      if user.status == :BURN && move.physicalMove?(type) &&
         !user.hasActiveAbility?(:GUTS) &&
         !(Settings::MECHANICS_GENERATION >= 6 && move.function == "07E")   # Facade
        multipliers[:final_damage_multiplier] /= 2
      end
    end
    # Aurora Veil, Reflect, Light Screen
    if skill>=PBTrainerAI.highSkill
      if !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
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
    end
    # Minimize
    if skill>=PBTrainerAI.highSkill
      if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(2)
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Move-specific base damage modifiers
    # TODO
    # Move-specific final damage modifiers
    # TODO
    ##### Main damage calculation #####
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
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
        c += 1 if user.inHyperMode? && move.type == :SHADOW
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
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
    # Check if move can't miss
    return 125 if modifiers[:base_accuracy]==0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion<1
    return modifiers[:base_accuracy] * accuracy / evasion
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
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
    if skill>=PBTrainerAI.mediumSkill
      if @battle.field.effects[PBEffects::Gravity] > 0
        modifiers[:accuracy_multiplier] *= 5/3.0
      end
      if user.effects[PBEffects::MicleBerry]
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    end
    # "AI-specific calculations below"
    if skill>=PBTrainerAI.mediumSkill
      modifiers[:evasion_stage] = 0 if move.function == "0A9"   # Chip Away
      modifiers[:base_accuracy] = 0 if ["0A5", "139", "13A", "13B", "13C",   # "Always hit"
                                        "147"].include?(move.function)
      modifiers[:base_accuracy] = 0 if user.effects[PBEffects::LockOn]>0 &&
                                       user.effects[PBEffects::LockOnPos]==target.index
    end
    if skill>=PBTrainerAI.highSkill
      if move.function=="006"   # Toxic
        modifiers[:base_accuracy] = 0 if Settings::MORE_TYPE_EFFECTS && move.statusMove? &&
                                         user.pbHasType?(:POISON)
      end
      if move.function=="070"   # OHKO moves
        modifiers[:base_accuracy] = move.accuracy + user.level - target.level
        modifiers[:accuracy_multiplier] = 0 if target.level > user.level
        if skill>=PBTrainerAI.bestSkill
          modifiers[:accuracy_multiplier] = 0 if target.hasActiveAbility?(:STURDY)
        end
      end
    end
  end
end
