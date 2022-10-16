#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoTimes",
  proc { |power, move, user, target, ai, battle|
    next power * move.move.pbNumHits(user.battler, [target.battler])
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimes",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and the first hit can break it
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = move.move.pbNumHits(user.battler, [target.battler])
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    # TODO: Consider effects that trigger per hit.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesPoisonTarget")
Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesPoisonTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = Battle::AI::Handlers.apply_move_effect_score("HitTwoTimes",
       score, move, user, target, ai, battle)
    # Score for poisoning
    score = Battle::AI::Handlers.apply_move_effect_score("PoisonTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesFlinchTarget")
Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = Battle::AI::Handlers.apply_move_effect_score("HitTwoTimes",
       score, move, user, target, ai, battle)
    # Score for flinching
    score = Battle::AI::Handlers.apply_move_effect_score("FlinchTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoTimesTargetThenTargetAlly",
  proc { |power, move, user, target, ai, battle|
    next power * 2
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitThreeTimesPowersUpWithEachHit",
  proc { |power, move, user, target, ai, battle|
    next power * 6   # Hits do x1, x2, x3 ret in turn, for x6 in total
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitThreeTimesPowersUpWithEachHit",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and the first or second hit can break it
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      score += 10 if target.effects[PBEffects::Substitute] < dmg / 2
    end
    # TODO: Consider effects that trigger per hit.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitThreeTimesAlwaysCriticalHit")
Battle::AI::Handlers::MoveEffectScore.copy("HitTwoTimes",
                                           "HitThreeTimesAlwaysCriticalHit")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoToFiveTimes",
  proc { |power, move, user, target, ai, battle|
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitTwoToFiveTimes",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and the first hit(s) can break it
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = (user.has_active_ability?(:SKILLLINK)) ? 5 : 3   # 3 is about average
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    # TODO: Consider effects that trigger per hit.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoToFiveTimesOrThreeForAshGreninja",
  proc { |power, move, user, target, ai, battle|
    if user.battler.isSpecies?(:GRENINJA) && user.battler.form == 2
      next move.move.pbBaseDamage(power, user.battler, target.battler) * move.move.pbNumHits(user.battler, [target.battler])
    end
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("HitTwoToFiveTimes",
                                           "HitTwoToFiveTimesOrThreeForAshGreninja")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoToFiveTimes",
                                         "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1")
Battle::AI::Handlers::MoveEffectScore.add("HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
  proc { |score, move, user, target, ai, battle|
    # Score for being a multi-hit attack
    score = Battle::AI::Handlers.apply_move_effect_score("HitTwoToFiveTimes",
       score, move, user, target, ai, battle)
    # User's stat changes
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if aspeed < ospeed && aspeed * 1.5 > ospeed
      score += 15   # Will become faster than the target
    end
    score += user.stages[:DEFENSE] * 10
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HitOncePerUserTeamMember",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, i|
      next if !pkmn.able? || pkmn.status != :NONE
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveBasePower.add("HitOncePerUserTeamMember",
  proc { |power, move, user, target, ai, battle|
    ret = 0
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
      ret += 5 + (pkmn.baseStats[:ATTACK] / 10) if pkmn.able? && pkmn.status == :NONE
    end
    next ret
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitOncePerUserTeamMember",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and the first hit(s) can break it
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = 0
      battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
        num_hits += 1 if pkmn.able? && pkmn.status == :NONE
      end
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    # TODO: Consider effects that trigger per hit.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("AttackAndSkipNextTurn",
  proc { |score, move, user, target, ai, battle|
    # Don't prefer because it uses up two turns
    score -= 10 if !user.has_active_ability?(:TRUANT)
    # Don't prefer if user is at a high HP (treat this move as a last resort)
    score -= 10 if user.hp >= user.totalhp / 2
    # TODO: Don't prefer if another of the user's moves could KO the target.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttack",
  proc { |score, move, user, target, ai, battle|
    # Power Herb makes this a 1 turn move, the same as a move with no effect
    next score if user.has_active_item?(:POWERHERB)
    # Treat as a failure if user has Truant (the charging turn has no effect)
    next 25 if user.has_active_ability?(:TRUANT)
    # Don't prefer because it uses up two turns
    score -= 15
    # Don't prefer if user is at a low HP (time is better spent on quicker moves)
    score -= 10 if user.hp < user.totalhp / 2
    # Don't prefer if target has a protecting move
    if ai.trainer.high_skill? && !(user.has_active_ability?(:UNSEENFIST) && move.move.contactMove?)
      has_protect_move = false
      if move.move.pbTarget(user).num_targets > 1 &&
         (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?)
        if target.check_for_move { |m| m.function == "ProtectUserSideFromMultiTargetDamagingMoves" }
          has_protect_move = true
        end
      end
      if move.move.canProtectAgainst?
        if target.check_for_move { |m| ["ProtectUser",
                                        "ProtectUserFromTargetingMovesSpikyShield",
                                        "ProtectUserBanefulBunker"].include?(m.function) }
          has_protect_move = true
        end
        if move.damagingMove?
          # NOTE: Doesn't check for Mat Block because it only works on its
          #       user's first turn in battle, so it can't be used in response
          #       to this move charging up.
          if target.check_for_move { |m| ["ProtectUserFromDamagingMovesKingsShield",
                                          "ProtectUserFromDamagingMovesObstruct"].include?(m.function) }
            has_protect_move = true
          end
        end
        if move.rough_priority(user) > 0
          if target.check_for_move { |m| m.function == "ProtectUserSideFromPriorityMoves" }
            has_protect_move = true
          end
        end
      end
      score -= 15 if has_protect_move
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("TwoTurnAttackOneTurnInSun",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamageMultiplier(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackOneTurnInSun",
  proc { |score, move, user, target, ai, battle|
    # Sunny weather this a 1 turn move, the same as a move with no effect
    next score if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
    # Score for being a two turn attack
    next Battle::AI::Handlers.apply_move_effect_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    # Score for paralysing
    score = Battle::AI::Handlers.apply_move_effect_score("ParalyzeTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackBurnTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    # Score for burning
    score = Battle::AI::Handlers.apply_move_effect_score("BurnTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    # Score for flinching
    score = Battle::AI::Handlers.apply_move_effect_score("FlinchTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "TwoTurnAttackRaiseUserSpAtkSpDefSpd2")
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
  proc { |score, move, user, target, ai, battle|
    # Score for raising user's stats
    score = ai.get_score_for_user_stat_raise(score)
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackChargeRaiseUserDefense1",
  proc { |score, move, user, target, ai, battle|
    score += 20 if user.stages[:DEFENSE] < 0
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackChargeRaiseUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if (aspeed > ospeed && user.hp > user.totalhp / 3) || user.hp > user.totalhp / 2
      score += 60
    else
      score -= 90
    end
    score += user.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableUnderground

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableUnderwater

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableInSky

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableInSkyParalyzeTarget

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TwoTurnAttackInvulnerableInSkyTargetCannotAct",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user)
    next true if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
    next true if Settings::MECHANICS_GENERATION >= 6 && target.battler.pbWeight >= 2000   # 200.0kg
    next true if target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableRemoveProtections

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# MultiTurnAttackPreventSleeping

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# MultiTurnAttackConfuseUserAtEnd

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackPowersUpEachTurn",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |power, move, user, target, ai, battle|
    next 40   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |score, move, user, target, ai, battle|
    if user.hp <= user.totalhp / 4
      score -= 90
    elsif user.hp <= user.totalhp / 2
      score -= 50
    end
    next score
  }
)
