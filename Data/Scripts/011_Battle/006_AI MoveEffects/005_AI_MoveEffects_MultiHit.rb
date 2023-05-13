#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoTimes",
  proc { |power, move, user, target, ai, battle|
    next power * move.move.pbNumHits(user.battler, [target.battler])
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitTwoTimes",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = move.move.pbNumHits(user.battler, [target.battler])
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesPoisonTarget")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitTwoTimesPoisonTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("HitTwoTimes",
       score, move, user, target, ai, battle)
    # Score for poisoning
    poison_score = Battle::AI::Handlers.apply_move_effect_against_target_score("PoisonTarget",
       0, move, user, target, ai, battle)
    score += poison_score if poison_score != Battle::AI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesFlinchTarget")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitTwoTimesFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("HitTwoTimes",
       score, move, user, target, ai, battle)
    # Score for flinching
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("FlinchTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitThreeTimesPowersUpWithEachHit",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      score += 10 if target.effects[PBEffects::Substitute] < dmg / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitThreeTimesAlwaysCriticalHit")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("HitTwoTimes",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitTwoToFiveTimes",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last/third hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = (user.has_active_ability?(:SKILLLINK)) ? 5 : 3   # 3 is about average
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("HitTwoToFiveTimes",
                                                        "HitTwoToFiveTimesOrThreeForAshGreninja")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoToFiveTimes",
                                         "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
  proc { |score, move, user, target, ai, battle|
    # Score for being a multi-hit attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("HitTwoToFiveTimes",
       score, move, user, target, ai, battle)
    # Score for user's stat changes
    score = ai.get_score_for_target_stat_raise(score, user, [:SPEED, 1], false)
    score = ai.get_score_for_target_stat_drop(score, user, [:DEFENSE, 1], false)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HitOncePerUserTeamMember",
  proc { |move, user, ai, battle|
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitOncePerUserTeamMember",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = 0
      battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
        num_hits += 1 if pkmn.able? && pkmn.status == :NONE
      end
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("AttackAndSkipNextTurn",
  proc { |score, move, user, ai, battle|
    # Don't prefer if user is at a high HP (treat this move as a last resort)
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp >= user.totalhp / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttack",
  proc { |score, move, user, target, ai, battle|
    # Power Herb makes this a 1 turn move, the same as a move with no effect
    next score if user.has_active_item?(:POWERHERB)
    # Treat as a failure if user has Truant (the charging turn has no effect)
    next Battle::AI::MOVE_USELESS_SCORE if user.has_active_ability?(:TRUANT)
    # Useless if user will faint from EoR damage before finishing this attack
    next Battle::AI::MOVE_USELESS_SCORE if user.rough_end_of_round_damage >= user.hp
    # Don't prefer because it uses up two turns
    score -= 10
    # Don't prefer if user is at a low HP (time is better spent on quicker moves)
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    # Don't prefer if target has a protecting move
    if ai.trainer.high_skill? && !(user.has_active_ability?(:UNSEENFIST) && move.move.contactMove?)
      has_protect_move = false
      if move.pbTarget(user).num_targets > 1 &&
         (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?)
        if target.has_move_with_function?("ProtectUserSideFromMultiTargetDamagingMoves")
          has_protect_move = true
        end
      end
      if move.move.canProtectAgainst?
        if target.has_move_with_function?("ProtectUser",
                                          "ProtectUserFromTargetingMovesSpikyShield",
                                          "ProtectUserBanefulBunker")
          has_protect_move = true
        end
        if move.damagingMove?
          # NOTE: Doesn't check for Mat Block because it only works on its
          #       user's first turn in battle, so it can't be used in response
          #       to this move charging up.
          if target.has_move_with_function?("ProtectUserFromDamagingMovesKingsShield",
                                            "ProtectUserFromDamagingMovesObstruct")
            has_protect_move = true
          end
        end
        if move.rough_priority(user) > 0
          if target.has_move_with_function?("ProtectUserSideFromPriorityMoves")
            has_protect_move = true
          end
        end
      end
      score -= 20 if has_protect_move
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackOneTurnInSun",
  proc { |score, move, user, target, ai, battle|
    # In sunny weather this a 1 turn move, the same as a move with no effect
    next score if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
    # Score for being a two turn attack
    next Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for paralysing
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("ParalyzeTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackBurnTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for burning
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("BurnTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for flinching
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("FlinchTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "TwoTurnAttackRaiseUserSpAtkSpDefSpd2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for raising user's stats
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackChargeRaiseUserDefense1",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for raising the user's stat
    score = Battle::AI::Handlers.apply_move_effect_score("RaiseUserDefense1",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackChargeRaiseUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for raising the user's stat
    score = Battle::AI::Handlers.apply_move_effect_score("RaiseUserSpAtk1",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackInvulnerableUnderground",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable underground
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsDiggingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackInvulnerableUnderwater",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable underwater
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsDivingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackInvulnerableInSky",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable in the sky
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsFlyingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackInvulnerableInSkyParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack and semi-invulnerable in the sky
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttackInvulnerableInSky",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for paralyzing the target
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("ParalyzeTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TwoTurnAttackInvulnerableInSkyTargetCannotAct",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user)
    next true if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
    next true if target.has_type?(:FLYING)
    next true if Settings::MECHANICS_GENERATION >= 6 && target.battler.pbWeight >= 2000   # 200.0kg
    next true if target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("TwoTurnAttackInvulnerableInSky",
                                                        "TwoTurnAttackInvulnerableInSkyTargetCannotAct")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TwoTurnAttackInvulnerableRemoveProtections",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("TwoTurnAttack",
       score, move, user, target, ai, battle)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for being invulnerable
    score += 8
    # Score for removing protections
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("RemoveProtections",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
# MultiTurnAttackPreventSleeping

#===============================================================================
#
#===============================================================================
# MultiTurnAttackConfuseUserAtEnd

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackPowersUpEachTurn",
  proc { |power, move, user, target, ai, battle|
    # NOTE: The * 2 (roughly) incorporates the higher damage done in subsequent
    #       rounds. It is nearly the average damage this move will do per round,
    #       assuming it hits for 3 rounds (hoping for hits in all 5 rounds is
    #       optimistic).
    next move.move.pbBaseDamage(power, user.battler, target.battler) * 2
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |power, move, user, target, ai, battle|
    next 40   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |score, move, user, ai, battle|
    # Useless if no foe has any damaging moves
    has_damaging_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if b.status == :SLEEP && b.statusCount > 2
      next if b.status == :FROZEN
      has_damaging_move = true if b.check_for_move { |m| m.damagingMove? }
      break if has_damaging_move
    end
    next Battle::AI::MOVE_USELESS_SCORE if !has_damaging_move
    # Don't prefer if the user isn't at high HP
    if ai.trainer.has_skill_flag?("HPAware")
      next Battle::AI::MOVE_USELESS_SCORE if user.hp <= user.totalhp / 4
      score -= 15 if user.hp <= user.totalhp / 2
      score -= 8 if user.hp <= user.totalhp * 3 / 4
    end
    next score
  }
)
