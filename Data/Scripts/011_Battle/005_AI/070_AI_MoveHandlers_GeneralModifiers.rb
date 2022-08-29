#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: High priority checks:
# => Prefer move if it will KO the target (moreso if user is slower than target)
# => Don't prefer damaging move if it won't KO, user has Stance Change and
#    is in shield form, and user is slower than the target
# => Check memory for past damage dealt by a target's non-high priority move,
#    and prefer move if user is slower than the target and another hit from
#    the same amount will KO the user
# => Check memory for past damage dealt by a target's priority move, and don't
#    prefer the move if user is slower than the target and can't move faster
#    than it because of priority
# => Discard move if user is slower than the target and target is semi-
#    invulnerable (and move won't hit it)
# => Check memory for whether target has previously used Quick Guard, and
#    don't prefer move if so

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Low priority checks:
# => Don't prefer move if user is faster than the target
# => Prefer move if user is faster than the target and target is semi-
#    invulnerable

#===============================================================================
# Don't prefer a dancing move if the target has the Dancer ability.
# TODO: Review score modifier.
# TODO: Check all battlers, not just the target.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:dance_move_against_dancer,
  proc { |score, move, user, target, ai, battle|
    next score /= 2 if move.move.danceMove? && target&.has_active_ability?(:DANCER)
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Check memory for whether target has previously used Ion Deluge, and
#       don't prefer move if it's Normal-type and target is immune because
#       of its ability (Lightning Rod, etc.).

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer sound move if user hasn't been Throat Chopped but
#       target has previously used Throat Chop.

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Prefer move if it has a high critical hit rate, critical hits are
#       possible but not certain, and target has raised defences/user has
#       lowered offences (Atk/Def or SpAtk/SpDef, whichever is relevant).

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer damaging moves if target is Destiny Bonding.
# => Also don't prefer damaging moves if user is slower than the target, move
#    is likely to be lethal, and target has previously used Destiny Bond

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer a move that is stopped by Wide Guard if target has
#       previously used Wide Guard.

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer Fire-type moves if target has previously used Powder.

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
# TODO: Review score modifier.
#===============================================================================
# TODO: Don't prefer a status move if user has a damaging move that will KO
#       the target.
# => If target has previously used a move that will hurt the user by 30% of
#    its current HP or more, moreso don't prefer a status move.

#===============================================================================
# Prefer damaging moves if AI has no more Pokémon or AI is less clever.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:damaging_moves_if_last_pokemon,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 &&
       !(ai.trainer.high_skill? && target && battle.pbAbleNonActiveCount(target.idxOwnSide) > 0)
      next score * 0.9 if move.statusMove?
      next score * 1.1 if target_battler.hp <= target_battler.totalhp / 2
    end
  }
)

#===============================================================================
# Don't prefer attacking the target if they'd be semi-invulnerable.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:target_semi_invulnerable,
  proc { |score, move, user, target, ai, battle|
    if move.accuracy > 0 && target && user.faster_than?(target) &&
      (target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
      miss = true
      miss = false if user.has_active_ability?(:NOGUARD)
      miss = false if ai.trainer.best_skill? && target.has_active_ability?(:NOGUARD)
      if ai.trainer.best_skill? && miss
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
      next score - 50 if miss
    end
  }
)

#===============================================================================
# Pick a good move for the Choice items.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:good_move_for_choice_item,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      if user.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         user.has_active_ability?(:GORILLATACTICS)
        # Really don't prefer status moves (except Trick)
        score *= 0.1 if move.statusMove? && move.function != "UserTargetSwapItems"
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
        score *= 0.95 if unpreferred_types.include?(move_type)
        # Don't prefer moves with lower accuracy
        score *= move.accuracy / 100.0 if move.accuracy > 0
        # Don't prefer moves with low PP
        score *= 0.9 if move.move.pp < 6
        next score
      end
    end
  }
)

#===============================================================================
# If user is frozen, prefer a move that can thaw the user.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:thawing_move_when_frozen,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && user.status == :FROZEN
      if move.move.thawsUser?
        score += 30
      else
        user.battler.eachMove do |m|
          next unless m.thawsUser?
          score -= 30   # Don't prefer this move if user knows another move that thaws
          break
        end
      end
      next score
    end
  }
)

#===============================================================================
# If target is frozen, don't prefer moves that could thaw them.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:thawing_move_against_frozen_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target&.status == :FROZEN
      if move.rough_type == :FIRE || (Settings::MECHANICS_GENERATION >= 6 && move.move.thawsUser?)
        next score - 30
      end
    end
  }
)

#===============================================================================
# Don't prefer hitting a wild shiny Pokémon.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:shiny_target,
  proc { |score, move, user, target, ai, battle|
    next score - 40 if target&.wild? && target&.battler.shiny?
  }
)

#===============================================================================
# TODO: Review score modifier.
#===============================================================================
# TODO: Discard a move that can be Magic Coated if either opponent has Magic
#       Bounce.

#===============================================================================
# Account for accuracy of move.
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:move_accuracy,
  proc { |score, move, user, target, ai, battle|
    next score * move.rough_accuracy / 100.0
  }
)

#===============================================================================
# Prefer flinching external effects (note that move effects which cause
# flinching are dealt with in the function code part of score calculation).
# TODO: Review score modifier.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:flinching_effects,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target
      if (battle.moldBreaker || !target.has_active_ability?([:INNERFOCUS, :SHIELDDUST])) &&
         target.effects[PBEffects::Substitute] == 0
        if move.move.flinchingMove? ||
           (move.damagingMove? &&
           (user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
           user.has_active_ability?(:STENCH)))
          next score + 20
        end
      end
    end
  }
)

#===============================================================================
# Adjust score based on how much damage it can deal.
# TODO: Review score modifier.
#===============================================================================
# Battle::AI::Handlers::GeneralMoveScore.add(:add_predicted_damage,
#   proc { |score, move, user, target, ai, battle|
#     if move.damagingMove?
#       dmg = move.rough_damage
#       next score + [30.0 * dmg / target.hp, 40].min
#     else   # Status moves
#       # Don't prefer attacks which don't deal damage
#       next score - 10
#     end
#   }
# )
