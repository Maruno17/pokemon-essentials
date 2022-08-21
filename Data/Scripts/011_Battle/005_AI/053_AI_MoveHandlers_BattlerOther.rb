#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("SleepTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanSleep?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= 30 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
      end
      if ai.skill_check(Battle::AI::AILevel.best)
        if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                     "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
          score -= 50
        end
      end
    else
      next 0 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("SleepTarget",
                                           "SleepTargetIfUserDarkrai",
                                           "SleepTargetChangeUserMeloettaForm")

Battle::AI::Handlers::MoveEffectScore.add("SleepTargetNextTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Yawn] > 0 || !target.pbCanSleep?(user, false)
    score += 30
    if ai.skill_check(Battle::AI::AILevel.high)
      score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
    end
    if ai.skill_check(Battle::AI::AILevel.best)
      if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                   "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
        score -= 50
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("PoisonTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanPoison?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score += 10 if pbRoughStat(target, :DEFENSE) > 100
        score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE) > 100
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
      end
    else
      next 0 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("PoisonTargetLowerTargetSpeed1",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !target.pbCanPoison?(user, false) && !target.pbCanLowerStatStage?(:SPEED, user)
    if target.pbCanPoison?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score += 10 if pbRoughStat(target, :DEFENSE) > 100
        score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE) > 100
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
      end
    end
    if target.pbCanLowerStatStage?(:SPEED, user)
      score += target.stages[:SPEED] * 10
      if ai.skill_check(Battle::AI::AILevel.high)
        aspeed = pbRoughStat(user, :SPEED)
        ospeed = pbRoughStat(target, :SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("BadPoisonTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanPoison?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score += 10 if pbRoughStat(target, :DEFENSE) > 100
        score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE) > 100
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
      end
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ParalyzeTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanParalyze?(user, false) &&
       !(ai.skill_check(Battle::AI::AILevel.medium) &&
       move.id == :THUNDERWAVE &&
       Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        aspeed = pbRoughStat(user, :SPEED)
        ospeed = pbRoughStat(target, :SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
      end
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("ParalyzeTarget",
                                           "ParalyzeTargetIfNotTypeImmune",
                                           "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
                                           "ParalyzeFlinchTarget")

Battle::AI::Handlers::MoveEffectScore.add("BurnTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanBurn?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
      end
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("BurnTarget",
                                           "BurnTargetIfTargetStatsRaisedThisTurn",
                                           "BurnFlinchTarget")

Battle::AI::Handlers::MoveEffectScore.add("FreezeTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanFreeze?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
      end
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FreezeTargetSuperEffectiveAgainstWater",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanFreeze?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FreezeTargetAlwaysHitsInHail",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanFreeze?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
      end
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("FreezeTargetAlwaysHitsInHail",
                                           "FreezeFlinchTarget")

Battle::AI::Handlers::MoveEffectScore.add("ParalyzeBurnOrFreezeTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 30 if target.status == :NONE
  }
)

Battle::AI::Handlers::MoveEffectScore.add("GiveUserStatusToTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.status == :NONE
    next score + 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CureUserBurnPoisonParalysis",
  proc { |score, move, user, target, skill, ai, battle|
    case user.status
    when :POISON
      score += 40
      if ai.skill_check(Battle::AI::AILevel.medium)
        if user.hp < user.totalhp / 8
          score += 60
        elsif ai.skill_check(Battle::AI::AILevel.high) &&
              user.hp < (user.effects[PBEffects::Toxic] + 1) * user.totalhp / 16
          score += 60
        end
      end
    when :BURN, :PARALYSIS
      score += 40
    else
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CureUserPartyStatus",
  proc { |score, move, user, target, skill, ai, battle|
    statuses = 0
    battle.pbParty(user.index).each do |pkmn|
      statuses += 1 if pkmn && pkmn.status != :NONE
    end
    if statuses == 0
      score -= 80
    else
      score += 20 * statuses
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CureTargetBurn",
  proc { |score, move, user, target, skill, ai, battle|
    if target.opposes?(user)
      score -= 40 if target.status == :BURN
    elsif target.status == :BURN
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartUserSideImmunityToInflictedStatus",
  proc { |score, move, user, target, skill, ai, battle|
    if user.pbOwnSide.effects[PBEffects::Safeguard] > 0
      score -= 80
    elsif user.status != :NONE
      score -= 40
    else
      score += 30
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTarget",
  proc { |score, move, user, target, skill, ai, battle|
    score += 30
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute] == 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetFailsIfUserNotAsleep",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.asleep?
    score += 100   # Because it can only be used while asleep
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute] == 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetFailsIfNotUserFirstTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.turnCount != 0
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute] == 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetDoublePowerIfTargetInSky",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute] == 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ConfuseTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !target.pbCanConfuse?(user, false)
    next score + 30
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("ConfuseTarget",
                                           "ConfuseTargetAlwaysHitsInRainHitsTargetInSky")

Battle::AI::Handlers::MoveEffectScore.add("AttractTarget",
  proc { |score, move, user, target, skill, ai, battle|
    canattract = true
    agender = user.gender
    ogender = target.gender
    if agender == 2 || ogender == 2 || agender == ogender
      score -= 90
      canattract = false
    elsif target.effects[PBEffects::Attract] >= 0
      score -= 80
      canattract = false
    elsif ai.skill_check(Battle::AI::AILevel.best) && target.hasActiveAbility?(:OBLIVIOUS)
      score -= 80
      canattract = false
    end
    if ai.skill_check(Battle::AI::AILevel.high)
      if canattract && target.hasActiveItem?(:DESTINYKNOT) &&
         user.pbCanAttract?(target, false)
        score -= 30
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesBasedOnEnvironment",
  proc { |score, move, user, target, skill, ai, battle|
    if !user.canChangeType?
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.medium)
      new_type = nil
      case battle.field.terrain
      when :Electric
        new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
      when :Grassy
        new_type = :GRASS if GameData::Type.exists?(:GRASS)
      when :Misty
        new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
      when :Psychic
        new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
      end
      if !new_type
        envtypes = {
          :None        => :NORMAL,
          :Grass       => :GRASS,
          :TallGrass   => :GRASS,
          :MovingWater => :WATER,
          :StillWater  => :WATER,
          :Puddle      => :WATER,
          :Underwater  => :WATER,
          :Cave        => :ROCK,
          :Rock        => :GROUND,
          :Sand        => :GROUND,
          :Forest      => :BUG,
          :ForestGrass => :BUG,
          :Snow        => :ICE,
          :Ice         => :ICE,
          :Volcano     => :FIRE,
          :Graveyard   => :GHOST,
          :Sky         => :FLYING,
          :Space       => :DRAGON,
          :UltraSpace  => :PSYCHIC
        }
        new_type = envtypes[battle.environment]
        new_type = nil if !GameData::Type.exists?(new_type)
        new_type ||= :NORMAL
      end
      score -= 90 if !user.pbHasOtherType?(new_type)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToResistLastAttack",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.canChangeType?
    next 0 if !target.lastMoveUsed || !target.lastMoveUsedType ||
              GameData::Type.get(target.lastMoveUsedType).pseudo_type
    aType = nil
    target.eachMove do |m|
      next if m.id != target.lastMoveUsed
      aType = m.pbCalcType(user)
      break
    end
    next 0 if !aType
    has_possible_type = false
    GameData::Type.each do |t|
      next if t.pseudo_type || user.pbHasType?(t.id) ||
              !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
      has_possible_type = true
      break
    end
    next 0 if !has_possible_type
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToTargetTypes",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.canChangeType? || target.pbTypes(true).length == 0
    next 0 if user.pbTypes == target.pbTypes &&
              user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToUserMoveType",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.canChangeType?
    has_possible_type = false
    user.eachMoveWithIndex do |m, i|
      break if Settings::MECHANICS_GENERATION >= 6 && i > 0
      next if GameData::Type.get(m.type).pseudo_type
      next if user.pbHasType?(m.type)
      has_possible_type = true
      break
    end
    next 0 if !has_possible_type
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetTypesToPsychic",
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbHasOtherType?(:PSYCHIC)
      score -= 90
    elsif !target.canChangeType?
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetTypesToWater",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Substitute] > 0 || !target.canChangeType?
      score -= 90
    elsif !target.pbHasOtherType?(:WATER)
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddGhostTypeToTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.pbHasType?(:GHOST)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddGrassTypeToTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.pbHasType?(:GRASS)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserLosesFireType",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.pbHasType?(:FIRE)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetAbilityToSimple",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    if ai.skill_check(Battle::AI::AILevel.medium)
      next 0 if target.unstoppableAbility? ||
                [:TRUANT, :SIMPLE].include?(target.ability)
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetAbilityToInsomnia",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    if ai.skill_check(Battle::AI::AILevel.medium)
      next 0 if target.unstoppableAbility? ||
                [:TRUANT, :INSOMNIA].include?(target.ability)
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserAbilityToTargetAbility",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 40   # don't prefer this move
    if ai.skill_check(Battle::AI::AILevel.medium)
      if !target.ability || user.ability == target.ability ||
         [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
         [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
          :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
        score -= 90
      end
    end
    if ai.skill_check(Battle::AI::AILevel.high)
      if target.ability == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability == :SLOWSTART && user.opposes?(target)
        score -= 90
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetAbilityToUserAbility",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 40   # don't prefer this move
    if target.effects[PBEffects::Substitute] > 0
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.medium)
      if !user.ability || user.ability == target.ability ||
         [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
         [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
          :TRACE, :ZENMODE].include?(user.ability_id)
        score -= 90
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        if user.ability == :TRUANT && user.opposes?(target)
          score += 90
        elsif user.ability == :SLOWSTART && user.opposes?(target)
          score += 90
        end
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapAbilities",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 40   # don't prefer this move
    if ai.skill_check(Battle::AI::AILevel.medium)
      if (!user.ability && !target.ability) ||
         user.ability == target.ability ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
        score -= 90
      end
    end
    if ai.skill_check(Battle::AI::AILevel.high)
      if target.ability == :TRUANT && user.opposes?(target)
        score -= 90
      elsif target.ability == :SLOWSTART && user.opposes?(target)
        score -= 90
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("NegateTargetAbility",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Substitute] > 0 ||
       target.effects[PBEffects::GastroAcid]
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.high)
      score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("NegateTargetAbilityIfTargetActed",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      userSpeed   = pbRoughStat(user, :SPEED)
      targetSpeed = pbRoughStat(target, :SPEED)
      if userSpeed < targetSpeed
        score += 30
      end
    else
      score += 30
    end
    next score
  }
)

# IgnoreTargetAbility

Battle::AI::Handlers::MoveEffectScore.add("StartUserAirborne",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::MagnetRise] > 0 ||
       user.effects[PBEffects::Ingrain] ||
       user.effects[PBEffects::SmackDown]
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartTargetAirborneAndAlwaysHitByMoves",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Telekinesis] > 0 ||
       target.effects[PBEffects::Ingrain] ||
       target.effects[PBEffects::SmackDown]
      score -= 90
    end
    next score
  }
)

# HitsTargetInSky

Battle::AI::Handlers::MoveEffectScore.add("HitsTargetInSkyGroundsTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      score += 20 if target.effects[PBEffects::MagnetRise] > 0
      score += 20 if target.effects[PBEffects::Telekinesis] > 0
      score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                             "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
      score += 20 if target.pbHasType?(:FLYING)
      score += 20 if target.hasActiveAbility?(:LEVITATE)
      score += 20 if target.hasActiveItem?(:AIRBALLOON)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartGravity",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.field.effects[PBEffects::Gravity] > 0
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.medium)
      score -= 30
      score -= 20 if user.effects[PBEffects::SkyDrop] >= 0
      score -= 20 if user.effects[PBEffects::MagnetRise] > 0
      score -= 20 if user.effects[PBEffects::Telekinesis] > 0
      score -= 20 if user.pbHasType?(:FLYING)
      score -= 20 if user.hasActiveAbility?(:LEVITATE)
      score -= 20 if user.hasActiveItem?(:AIRBALLOON)
      score += 20 if target.effects[PBEffects::SkyDrop] >= 0
      score += 20 if target.effects[PBEffects::MagnetRise] > 0
      score += 20 if target.effects[PBEffects::Telekinesis] > 0
      score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                             "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                             "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
      score += 20 if target.pbHasType?(:FLYING)
      score += 20 if target.hasActiveAbility?(:LEVITATE)
      score += 20 if target.hasActiveItem?(:AIRBALLOON)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TransformUserIntoTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 70
  }
)
