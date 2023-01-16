# TODO: Check all lingering effects to see if the AI needs to adjust itself
#       because of them.

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO:
# => Don't prefer damaging move if it won't KO, user has Stance Change and
#    is in shield form, and user is slower than the target
# => Check memory for past damage dealt by a target's non-high priority move,
#    and prefer move if user is slower than the target and another hit from
#    the same amount will KO the user
# => Check memory for past damage dealt by a target's priority move, and don't
#    prefer the move if user is slower than the target and can't move faster
#    than it because of priority
# => Check memory for whether target has previously used Quick Guard, and
#    don't prefer move if so

#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================

#===============================================================================
# Don't prefer hitting a wild shiny Pokémon.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:shiny_target,
  proc { |score, move, user, target, ai, battle|
    if target.wild? && target.battler.shiny?
      PBDebug.log_score_change(-40, "avoid attacking a shiny wild Pokémon")
      score -= 40
    end
    next score
  }
)

#===============================================================================
# Adjust score based on how much damage it can deal.
# Prefer the move even more if it's predicted to do enough damage to KO the
# target.
# TODO: Review score modifier.
# => If target has previously used a move that will hurt the user by 30% of
#    its current HP or more, moreso don't prefer a status move.
# => Include EOR damage in this?
# => Prefer move if it will KO the target (moreso if user is slower than target)
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:add_predicted_damage,
  proc { |score, move, user, target, ai, battle|
    if move.damagingMove?
      dmg = move.rough_damage
      old_score = score
      score += ([30.0 * dmg / target.hp, 35].min).to_i
      PBDebug.log_score_change(score - old_score, "damaging move (predicted damage #{dmg} = #{100 * dmg / target.hp}% of target's HP)")
      if dmg > target.hp * 1.1   # Predicted to KO the target
        old_score = score
        score += 10
        PBDebug.log_score_change(score - old_score, "predicted to KO the target")
      end
    end
    next score
  }
)

#===============================================================================
# Account for accuracy of move.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:move_accuracy,
  proc { |score, move, user, target, ai, battle|
    acc = move.rough_accuracy.to_i
    if acc < 90
      old_score = score
      score -= (0.2 * (100 - acc)).to_i   # -2 (89%) to -19 (1%)
      PBDebug.log_score_change(score - old_score, "accuracy (predicted #{acc}%)")
    end
    next score
  }
)

#===============================================================================
# Don't prefer attacking the target if they'd be semi-invulnerable.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_semi_invulnerable,
  proc { |score, move, user, target, ai, battle|
    # TODO: Also consider the move's priority compared to that of the move the
    #       target is using.
    if move.rough_accuracy > 0 && user.faster_than?(target) &&
       (target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
      miss = true
      miss = false if user.has_active_ability?(:NOGUARD) || target.has_active_ability?(:NOGUARD)
      if ai.trainer.high_skill? && miss
        # Knows what can get past semi-invulnerability
        if target.effects[PBEffects::SkyDrop] >= 0 ||
           target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                           "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                           "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
          miss = false if move.move.hitsFlyingTargets?
        elsif target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
          miss = false if move.move.hitsDiggingTargets?
        elsif target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
          miss = false if move.move.hitsDivingTargets?
        end
      end
      if miss
        old_score = score
        score = Battle::AI::MOVE_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "target is semi-invulnerable")
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Less prefer two-turn moves, as the foe can see it coming and prepare for
#       it.

#===============================================================================
# If target is frozen, don't prefer moves that could thaw them.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:thawing_move_against_frozen_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target.status == :FROZEN
      if move.rough_type == :FIRE || (Settings::MECHANICS_GENERATION >= 6 && move.move.thawsUser?)
        old_score = score
        score -= 15
        PBDebug.log_score_change(score - old_score, "thaws the target")
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Prefer move if it has a high critical hit rate, critical hits are
#       possible but not certain, and target has raised defences/user has
#       lowered offences (Atk/Def or SpAtk/SpDef, whichever is relevant).

#===============================================================================
# Prefer flinching external effects (note that move effects which cause
# flinching are dealt with in the function code part of score calculation).
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:flinching_effects,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      if (battle.moldBreaker || !target.has_active_ability?([:INNERFOCUS, :SHIELDDUST])) &&
         target.effects[PBEffects::Substitute] == 0
        if move.move.flinchingMove? ||
           (move.damagingMove? &&
           (user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
           user.has_active_ability?(:STENCH)))
          old_score = score
          score += 8
          PBDebug.log_score_change(score - old_score, "flinching")
        end
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer contact move if making contact with the target could
#       trigger an effect that's bad for the user (Static, etc.).
# => Also check if target has previously used Spiky Shield.King's Shield/
#    Baneful Bunker, and don't prefer move if so

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Prefer a contact move if making contact with the target could trigger
#       an effect that's good for the user (Poison Touch/Pickpocket).

#===============================================================================
# Don't prefer a dancing move if the target has the Dancer ability.
# TODO: Review score modifier.
# TODO: Check all battlers, not just the target.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:dance_move_against_dancer,
  proc { |score, move, user, target, ai, battle|
    if move.move.danceMove? && target.has_active_ability?(:DANCER)
      old_score = score
      score -= 12
      PBDebug.log_score_change(score - old_score, "don't want to use a dance move on a target with Dancer")
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Prefer a higher priority move if the user is slower than the foe(s) and
#       the user is at risk of being knocked out. Consider whether the foe(s)
#       have priority moves of their own? Limit this to prefer priority damaging
#       moves?

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer damaging moves if the target is Biding, unless the move
#       will deal enough damage to KO the target before it retaliates (assuming
#       the move is used repeatedly until the target retaliates). Don't worry
#       about the target's Bide if the user will be immune to it.

#===============================================================================
# Don't prefer damaging moves that will knock out the target if they are using
# Destiny Bond.
# TODO: Review score modifier.
# => Also don't prefer damaging moves if user is slower than the target, move
#    is likely to be lethal, and target has previously used Destiny Bond
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:avoid_knocking_out_destiny_bonder,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.damagingMove? && target.effects[PBEffects::DestinyBond]
      dmg = move.rough_damage
      if dmg > target.hp * 1.05   # Predicted to KO the target
        old_score = score
        score -= 15
        score -= 10 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
        PBDebug.log_score_change(score - old_score, "don't want to KO the Destiny Bonding target")
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer Fire-type moves if target has previously used Powder.

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Check memory for whether target has previously used Ion Deluge, and
#       don't prefer move if it's Normal-type and target is immune because
#       of its ability (Lightning Rod, etc.).

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer a move that can be Magic Coated if the target (or any foe
#       if the move doesn't have a target) has Magic Bounce.

#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Prefer Shadow moves.

#===============================================================================
# If user is frozen, prefer a move that can thaw the user.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:thawing_move_when_frozen,
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill? && user.status == :FROZEN
      old_score = score
      if move.move.thawsUser?
        score += 30
        PBDebug.log_score_change(score - old_score, "move will thaw the user")
      elsif user.check_for_move { |m| m.thawsUser? }
        score -= 30   # Don't prefer this move if user knows another move that thaws
        PBDebug.log_score_change(score - old_score, "user knows another move will thaw it")
      end
    end
    next score
  }
)

#===============================================================================
# Pick a good move for the Choice items.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:good_move_for_choice_item,
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill?
      if user.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         user.has_active_ability?(:GORILLATACTICS)
        # Really don't prefer status moves (except Trick)
        if move.statusMove? && move.function != "UserTargetSwapItems"
          old_score = score
          score -= 25
          PBDebug.log_score_change(score - old_score, "move is not suitable to be Choiced into")
        end
        # Don't prefer moves of certain types
        move_type = move.rough_type
        # Most unpreferred types are 0x effective against another type, except
        # Fire/Water/Grass
        # TODO: Actually check through the types for 0x instead of hardcoding
        #       them.
        # TODO: Reborn separately doesn't prefer Fire/Water/Grass/Electric, also
        #       with a 0.95x score, meaning Electric can be 0.95x twice. Why are
        #       these four types not preferred? Maybe because they're all not
        #       very effective against Dragon.
        unpreferred_types = [:NORMAL, :FIGHTING, :POISON, :GROUND, :GHOST,
                             :FIRE, :WATER, :GRASS, :ELECTRIC, :PSYCHIC, :DRAGON]
        old_score = score
        score -= 5 if unpreferred_types.include?(move_type)
        # Don't prefer moves with lower accuracy
        score = score * move.accuracy / 100 if move.accuracy > 0
        # Don't prefer moves with low PP
        score -= 10 if move.move.pp < 6
        PBDebug.log_score_change(score - old_score, "move is less suitable to be Choiced into")
      end
    end
    next score
  }
)

#===============================================================================
# Prefer damaging moves if the foe is down to their last Pokémon (opportunistic).
# Prefer damaging moves if the AI is down to its last Pokémon but the foe has
# more (desperate).
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:prefer_damaging_moves_if_last_pokemon,
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill? && move.damagingMove?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      # Don't mess with scores just because a move is damaging; need to play well
      next score if ai.trainer.high_skill? && foes > reserves   # AI is outnumbered
      # Prefer damaging moves depending on remaining Pokémon
      old_score = score
      if foes == 0          # Foe is down to their last Pokémon
        score += 10         # => Go for the kill
        PBDebug.log_score_change(score - old_score, "prefer damaging moves (no foe party Pokémon left)")
      elsif reserves == 0   # AI is down to its last Pokémon, foe has reserves
        score += 5          # => Go out with a bang
        PBDebug.log_score_change(score - old_score, "prefer damaging moves (no ally party Pokémon left)")
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer a move that is stopped by Wide Guard if any foe has
#       previously used Wide Guard.

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer sound move if user hasn't been Throat Chopped but a foe has
#       previously used Throat Chop.
