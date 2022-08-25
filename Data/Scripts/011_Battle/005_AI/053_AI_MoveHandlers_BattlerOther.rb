#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("SleepTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanSleep?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        score -= 30 if target.effects[PBEffects::Yawn] > 0
      end
      score -= 30 if target.has_active_ability?(:MARVELSCALE)
      if ai.trainer.best_skill?
        if target.battler.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
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
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Yawn] > 0 ||
              !target.battler.pbCanSleep?(user.battler, false)
    score += 30
    score -= 30 if target.has_active_ability?(:MARVELSCALE)
    if ai.trainer.best_skill?
      if target.battler.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                           "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
        score -= 50
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("PoisonTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanPoison?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.trainer.high_skill?
        score += 10 if target.rough_stat(:DEFENSE) > 100
        score += 10 if target.rough_stat(:SPECIAL_DEFENSE) > 100
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :TOXICBOOST])
    else
      next 0 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("PoisonTargetLowerTargetSpeed1",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanPoison?(user.battler, false) &&
              !target.battler.pbCanLowerStatStage?(:SPEED, user.battler)
    if target.battler.pbCanPoison?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.trainer.high_skill?
        score += 10 if target.rough_stat(:DEFENSE) > 100
        score += 10 if target.rough_stat(:SPECIAL_DEFENSE) > 100
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :TOXICBOOST])
    end
    if target.battler.pbCanLowerStatStage?(:SPEED, user.battler)
      score += target.stages[:SPEED] * 10
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("BadPoisonTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanPoison?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        score += 30 if target.hp <= target.totalhp / 4
        score += 50 if target.hp <= target.totalhp / 8
        score -= 40 if target.effects[PBEffects::Yawn] > 0
      end
      if ai.trainer.high_skill?
        score += 10 if target.rough_stat(:DEFENSE) > 100
        score += 10 if target.rough_stat(:SPECIAL_DEFENSE) > 100
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :TOXICBOOST])
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanParalyze?(user.battler, false) &&
       !(ai.trainer.medium_skill? &&
       move.id == :THUNDERWAVE &&
       Effectiveness.ineffective?(target.effectiveness_of_type_against_battler(move.type, user)))
      score += 30
      if ai.trainer.medium_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET])
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
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanBurn?(user.battler, false)
      score += 30
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
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
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanFreeze?(user.battler, false)
      score += 30
      score -= 20 if target.has_active_ability?(:MARVELSCALE)
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FreezeTargetSuperEffectiveAgainstWater",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanFreeze?(user.battler, false)
      score += 30
      score -= 20 if target.has_active_ability?(:MARVELSCALE)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FreezeTargetAlwaysHitsInHail",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanFreeze?(user.battler, false)
      score += 30
      score -= 20 if target.has_active_ability?(:MARVELSCALE)
    else
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("FreezeTargetAlwaysHitsInHail",
                                           "FreezeFlinchTarget")

Battle::AI::Handlers::MoveEffectScore.add("ParalyzeBurnOrFreezeTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.status == :NONE
  }
)

Battle::AI::Handlers::MoveEffectScore.add("GiveUserStatusToTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.status == :NONE
    next score + 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CureUserBurnPoisonParalysis",
  proc { |score, move, user, target, ai, battle|
    case user.status
    when :POISON
      score += 40
      if ai.trainer.medium_skill?
        if user.hp < user.totalhp / 8
          score += 60
        elsif ai.trainer.high_skill? &&
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
  proc { |score, move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    if target.opposes?(user)
      score -= 40 if target.status == :BURN
    elsif target.status == :BURN
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartUserSideImmunityToInflictedStatus",
  proc { |score, move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    score += 30
    score += 30 if !target.has_active_ability?(:INNERFOCUS) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetFailsIfUserNotAsleep",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.battler.asleep?
    score += 100   # Because it can only be used while asleep
    score += 30 if !target.has_active_ability?(:INNERFOCUS) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetFailsIfNotUserFirstTurn",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.turnCount != 0
    score += 30 if !target.has_active_ability?(:INNERFOCUS) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.add("FlinchTargetDoublePowerIfTargetInSky",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
}
Battle::AI::Handlers::MoveEffectScore.add("FlinchTargetDoublePowerIfTargetInSky",
  proc { |score, move, user, target, ai, battle|
    score += 30 if !target.has_active_ability?(:INNERFOCUS) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanConfuse?(user.battler, false)
    next score + 30
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("ConfuseTarget",
                                           "ConfuseTargetAlwaysHitsInRainHitsTargetInSky")

Battle::AI::Handlers::MoveEffectScore.add("AttractTarget",
  proc { |score, move, user, target, ai, battle|
    canattract = true
    agender = user.gender
    ogender = target.gender
    if agender == 2 || ogender == 2 || agender == ogender
      score -= 90
      canattract = false
    elsif target.effects[PBEffects::Attract] >= 0
      score -= 80
      canattract = false
    elsif target.has_active_ability?(:OBLIVIOUS)
      score -= 80
      canattract = false
    end
    if canattract && target.has_active_item?(:DESTINYKNOT) &&
       user.battler.pbCanAttract?(target.battler, false)
      score -= 30
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesBasedOnEnvironment",
  proc { |score, move, user, target, ai, battle|
    if !user.battler.canChangeType?
      score -= 90
    elsif ai.trainer.medium_skill?
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
      score -= 90 if !user.battler.pbHasOtherType?(new_type)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToResistLastAttack",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.battler.canChangeType?
    next 0 if !target.battler.lastMoveUsed || !target.battler.lastMoveUsedType ||
              GameData::Type.get(target.battler.lastMoveUsedType).pseudo_type
    aType = nil
    target.battler.eachMove do |m|
      next if m.id != target.battler.lastMoveUsed
      aType = m.pbCalcType(user.battler)
      break
    end
    next 0 if !aType
    has_possible_type = false
    GameData::Type.each do |t|
      next if t.pseudo_type || user.has_type?(t.id) ||
              !Effectiveness.resistant_type?(target.battler.lastMoveUsedType, t.id)
      has_possible_type = true
      break
    end
    next 0 if !has_possible_type
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToTargetTypes",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.battler.canChangeType? || target.battler.pbTypes(true).length == 0
    next 0 if user.battler.pbTypes == target.battler.pbTypes &&
              user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserTypesToUserMoveType",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.battler.canChangeType?
    has_possible_type = false
    user.battler.eachMoveWithIndex do |m, i|
      break if Settings::MECHANICS_GENERATION >= 6 && i > 0
      next if GameData::Type.get(m.type).pseudo_type
      next if user.has_type?(m.type)
      has_possible_type = true
      break
    end
    next 0 if !has_possible_type
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetTypesToPsychic",
  proc { |score, move, user, target, ai, battle|
    if !target.battler.canChangeType?
      score -= 90
    elsif !target.battler.pbHasOtherType?(:PSYCHIC)
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetTypesToWater",
  proc { |score, move, user, target, ai, battle|
    if !target.battler.canChangeType? || target.effects[PBEffects::Substitute] > 0
      score -= 90
    elsif !target.battler.pbHasOtherType?(:WATER)
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddGhostTypeToTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.has_type?(:GHOST)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddGrassTypeToTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.has_type?(:GRASS)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserLosesFireType",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.has_type?(:FIRE)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetAbilityToSimple",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    if ai.trainer.medium_skill?
      next 0 if target.battler.unstoppableAbility? ||
                [:TRUANT, :SIMPLE].include?(target.ability)
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetTargetAbilityToInsomnia",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    if ai.trainer.medium_skill?
      next 0 if target.battler.unstoppableAbility? ||
                [:TRUANT, :INSOMNIA].include?(target.ability)
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetUserAbilityToTargetAbility",
  proc { |score, move, user, target, ai, battle|
    score -= 40   # don't prefer this move
    if ai.trainer.medium_skill?
      if !target.ability || user.ability == target.ability ||
         [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
         [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
          :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
        score -= 90
      end
    end
    if ai.trainer.high_skill?
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
  proc { |score, move, user, target, ai, battle|
    score -= 40   # don't prefer this move
    if target.effects[PBEffects::Substitute] > 0
      score -= 90
    elsif ai.trainer.medium_skill?
      if !user.ability || user.ability == target.ability ||
         [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
         [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
          :TRACE, :ZENMODE].include?(user.ability_id)
        score -= 90
      end
      if ai.trainer.high_skill?
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
  proc { |score, move, user, target, ai, battle|
    score -= 40   # don't prefer this move
    if ai.trainer.medium_skill?
      if (!user.ability && !target.ability) ||
         user.ability == target.ability ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
         [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
        score -= 90
      end
    end
    if ai.trainer.high_skill?
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
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Substitute] > 0 ||
       target.effects[PBEffects::GastroAcid]
      score -= 90
    elsif ai.trainer.high_skill?
      score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("NegateTargetAbilityIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      score += 30 if target.faster_than?(user)
    else
      score += 30
    end
    next score
  }
)

# IgnoreTargetAbility

Battle::AI::Handlers::MoveEffectScore.add("StartUserAirborne",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::MagnetRise] > 0 ||
       user.effects[PBEffects::Ingrain] ||
       user.effects[PBEffects::SmackDown]
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartTargetAirborneAndAlwaysHitByMoves",
  proc { |score, move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      score += 20 if target.effects[PBEffects::MagnetRise] > 0
      score += 20 if target.effects[PBEffects::Telekinesis] > 0
      score += 20 if target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                                     "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
      score += 20 if target.has_type?(:FLYING)
      score += 20 if target.has_active_ability?(:LEVITATE)
      score += 20 if target.has_active_item?(:AIRBALLOON)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartGravity",
  proc { |score, move, user, target, ai, battle|
    if battle.field.effects[PBEffects::Gravity] > 0
      score -= 90
    elsif ai.trainer.medium_skill?
      score -= 30
      score -= 20 if user.effects[PBEffects::SkyDrop] >= 0
      score -= 20 if user.effects[PBEffects::MagnetRise] > 0
      score -= 20 if user.effects[PBEffects::Telekinesis] > 0
      score -= 20 if user.has_type?(:FLYING)
      score -= 20 if user.has_active_ability?(:LEVITATE)
      score -= 20 if user.has_active_item?(:AIRBALLOON)
      score += 20 if target.effects[PBEffects::SkyDrop] >= 0
      score += 20 if target.effects[PBEffects::MagnetRise] > 0
      score += 20 if target.effects[PBEffects::Telekinesis] > 0
      score += 20 if target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                                     "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                                     "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
      score += 20 if target.has_type?(:FLYING)
      score += 20 if target.has_active_ability?(:LEVITATE)
      score += 20 if target.has_active_item?(:AIRBALLOON)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TransformUserIntoTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 70
  }
)
