#===============================================================================
# Don't prefer hitting a wild shiny Pokémon.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:shiny_target,
  proc { |score, move, user, target, ai, battle|
    if target.wild? && target.battler.shiny?
      old_score = score
      score -= 20
      PBDebug.log_score_change(score - old_score, "avoid attacking a shiny wild Pokémon")
    end
    next score
  }
)

#===============================================================================
# Prefer Shadow moves (for flavour).
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:shadow_moves,
  proc { |score, move, user, target, ai, battle|
    if move.rough_type == :SHADOW
      old_score = score
      score += 10
      PBDebug.log_score_change(score - old_score, "prefer using a Shadow move")
    end
    next score
  }
)

#===============================================================================
# If user is frozen, prefer a move that can thaw the user.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:thawing_move_when_frozen,
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill? && user.status == :FROZEN
      old_score = score
      if move.move.thawsUser?
        score += 20
        PBDebug.log_score_change(score - old_score, "move will thaw the user")
      elsif user.check_for_move { |m| m.thawsUser? }
        score -= 20   # Don't prefer this move if user knows another move that thaws
        PBDebug.log_score_change(score - old_score, "user knows another move will thaw it")
      end
    end
    next score
  }
)

#===============================================================================
# Prefer using a priority move if the user is slower than the target and...
# - the user is at low HP, or
# - the target is predicted to be knocked out by the move.
# TODO: Less prefer a priority move if any foe knows Quick Guard?
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:priority_move_against_faster_target,
  proc { |score, move, user, ai, battle|
    if ai.trainer.high_skill? && target.faster_than?(user) && move.rough_priority(user) > 0
      # User is at risk of being knocked out
      if ai.trainer.has_skill_flag?("HPAware") && user.hp < user.totalhp / 3
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "user at low HP and move has priority over faster target")
      end
      # Target is predicted to be knocked out by the move
      if move.damaging_move? && move.rough_damage >= target.hp
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "target at low HP and move has priority over faster target")
      end
    end
    next score
  }
)

#===============================================================================
# Don't prefer a move that can be Magic Coated if the target (or any foe if the
# move doesn't have a target) knows Magic Coat/has Magic Bounce.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_can_Magic_Coat_or_Bounce_move,
  proc { |score, move, user, target, ai, battle|
    if move.statusMove? && move.move.canMagicCoat? && target.opposes?(user) &&
       (target.faster_than?(user) || !target.battler.semiInvulnerable?)
      old_score = score
      if !battle.moldBreaker && target.has_active_ability?(:MAGICBOUNCE)
        score = Battle::AI::MOVE_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because target will Magic Bounce it")
      elsif target.has_move_with_function?("BounceBackProblemCausingStatusMoves") &&
            target.can_attack? && !target.battler.semiInvulnerable?
        score -= 7
        PBDebug.log_score_change(score - old_score, "target knows Magic Coat and could bounce it")
      end
    end
    next score
  }
)

Battle::AI::Handlers::GeneralMoveScore.add(:any_foe_can_Magic_Coat_or_Bounce_move,
  proc { |score, move, user, ai, battle|
    if move.statusMove? && move.move.canMagicCoat? && move.pbTarget(user.battler).num_targets == 0
      old_score = score
      ai.each_foe_battler(user.side) do |b, i|
        next if user.faster_than?(b) && b.battler.semiInvulnerable?
        if b.has_active_ability?(:MAGICBOUNCE) && !battle.moldBreaker
          score = Battle::AI::MOVE_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because a foe will Magic Bounce it")
          break
        elsif b.has_move_with_function?("BounceBackProblemCausingStatusMoves") &&
              b.can_attack? && !b.battler.semiInvulnerable?
          score -= 7
          PBDebug.log_score_change(score - old_score, "a foe knows Magic Coat and could bounce it")
          break
        end
      end
    end
    next score
  }
)

#===============================================================================
# Don't prefer a move that can be Snatched if any other battler knows Snatch.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:any_battler_can_Snatch_move,
  proc { |score, move, user, ai, battle|
    if move.statusMove? && move.move.canSnatch?
      ai.each_battler do |b, i|
        next if b.index == user.index
        next if b.effects[PBEffects::SkyDrop] >= 0
        next if !b.has_move_with_function?("StealAndUseBeneficialStatusMove")
        old_score = score
        score -= 7
        PBDebug.log_score_change(score - old_score, "another battler could Snatch it")
        break
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
        old_score = score
        # Really don't prefer status moves (except Trick)
        if move.statusMove? && move.function != "UserTargetSwapItems"
          score -= 25
          PBDebug.log_score_change(score - old_score, "don't want to be Choiced into a status move")
          next score
        end
        # Don't prefer moves which are 0x against at least one type
        move_type = move.rough_type
        GameData::Type.each do |type_data|
          score -= 8 if type_data.immunities.include?(move_type)
        end
        # Don't prefer moves with lower accuracy
        if move.accuracy > 0
          score -= (0.4 * (100 - move.accuracy)).to_i   # -0 (100%) to -39 (1%)
        end
        # Don't prefer moves with low PP
        score -= 10 if move.move.pp <= 5
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
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:damaging_move_and_either_side_no_reserves,
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
#
#===============================================================================
# TODO: Don't prefer Fire-type moves if target has previously used Powder and is
#       faster than the user.

#===============================================================================
#
#===============================================================================
# TODO: Don't prefer Normal-type moves if target has previously used Ion Deluge
#       and is immune to Electric moves.

#===============================================================================
#
#===============================================================================
# TODO: Don't prefer a move that is stopped by Wide Guard if any foe has
#       previously used Wide Guard.

#===============================================================================
# Don't prefer attacking the target if they'd be semi-invulnerable.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_semi_invulnerable,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.rough_accuracy > 0 &&
       (target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
      next score if user.has_active_ability?(:NOGUARD) || target.has_active_ability?(:NOGUARD)
      priority = move.rough_priority
      if priority > 0 || (priority == 0 && user.faster_than?(target))   # User goes first
        miss = true
        if ai.trainer.high_skill?
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
    end
    next score
  }
)

#===============================================================================
# Account for accuracy of move.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:predicted_accuracy,
  proc { |score, move, user, target, ai, battle|
    acc = move.rough_accuracy.to_i
    if acc < 90
      old_score = score
      score -= (0.25 * (100 - acc)).to_i   # -2 (89%) to -24 (1%)
      PBDebug.log_score_change(score - old_score, "accuracy (predicted #{acc}%)")
    end
    next score
  }
)

#===============================================================================
# Adjust score based on how much damage it can deal.
# Prefer the move even more if it's predicted to do enough damage to KO the
# target.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:predicted_damage,
  proc { |score, move, user, target, ai, battle|
    if move.damagingMove?
      dmg = move.rough_damage
      old_score = score
      if target.effects[PBEffects::Substitute] > 0
        target_hp = target.effects[PBEffects::Substitute]
        score += ([15.0 * dmg / target.effects[PBEffects::Substitute], 20].min).to_i
        PBDebug.log_score_change(score - old_score, "damaging move (predicted damage #{dmg} = #{100 * dmg / target.hp}% of target's Substitute)")
      else
        score += ([25.0 * dmg / target.hp, 30].min).to_i
        PBDebug.log_score_change(score - old_score, "damaging move (predicted damage #{dmg} = #{100 * dmg / target.hp}% of target's HP)")
        if ai.trainer.has_skill_flag?("HPAware") && dmg > target.hp * 1.1   # Predicted to KO the target
          old_score = score
          score += 10
          PBDebug.log_score_change(score - old_score, "predicted to KO the target")
        end
      end
    end
    next score
  }
)

#===============================================================================
# Prefer flinching external effects (note that move effects which cause
# flinching are dealt with in the function code part of score calculation).
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:external_flinching_effects,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.damagingMove? && !move.move.flinchingMove? &&
       user.faster_than?(target) && target.effects[PBEffects::Substitute] == 0
      if user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
         user.has_active_ability?(:STENCH)
        if battle.moldBreaker || !target.has_active_ability?([:INNERFOCUS, :SHIELDDUST])
          old_score = score
          score += 8
          PBDebug.log_score_change(score - old_score, "added chance to cause flinching")
        end
      end
    end
    next score
  }
)

#===============================================================================
# If target is frozen, don't prefer moves that could thaw them.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:thawing_move_against_frozen_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target.status == :FROZEN
      if move.rough_type == :FIRE || (Settings::MECHANICS_GENERATION >= 6 && move.move.thawsUser?)
        old_score = score
        score -= 20
        PBDebug.log_score_change(score - old_score, "thaws the target")
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
# TODO: Prefer a contact move if making contact with the target could trigger
#       an effect that's good for the user (Poison Touch/Pickpocket).

#===============================================================================
#
#===============================================================================
# TODO: Don't prefer contact move if making contact with the target could
#       trigger an effect that's bad for the user (Static, etc.).
# => Also check if target has previously used Spiky Shield/King's Shield/
#    Baneful Bunker, and don't prefer move if so

#===============================================================================
# Don't prefer damaging moves that will knock out the target if they are using
# Destiny Bond or Grudge.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:knocking_out_a_destiny_bonder_or_grudger,
  proc { |score, move, user, target, ai, battle|
    if (ai.trainer.has_skill_flag?("HPAware") || ai.trainer.high_skill?) && move.damagingMove? &&
       (target.effects[PBEffects::DestinyBond] || target.effects[PBEffects::Grudge])
      priority = move.rough_priority
      if priority > 0 || (priority == 0 && user.faster_than?(target))   # User goes first
        if move.rough_damage > target.hp * 1.1   # Predicted to KO the target
          old_score = score
          if target.effects[PBEffects::DestinyBond]
            score -= 20
            score -= 10 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
            PBDebug.log_score_change(score - old_score, "don't want to KO the Destiny Bonding target")
          elsif target.effects[PBEffects::Grudge]
            score -= 15
            score -= 7 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
            PBDebug.log_score_change(score - old_score, "don't want to KO the Grudge-using target")
          end
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
# TODO: Don't prefer damaging moves if the target is using Rage and they benefit
#       from the raised Attack.

#===============================================================================
# Don't prefer damaging moves if the target is Biding, unless the move will deal
# enough damage to KO the target before it retaliates (assuming the move is used
# repeatedly until the target retaliates). Doesn't do a score change if the user
# will be immune to Bide's damage.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:damaging_a_biding_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target.effects[PBEffects::Bide] > 0 && move.damagingMove?
      eff = user.effectiveness_of_type_against_battler(:NORMAL, target)   # Bide is Normal type
      if !Effectiveness.ineffective?(eff)
        # Worth damaging the target if it can be knocked out before Bide ends
        if ai.trainer.has_skill_flag?("HPAware")
          dmg = move.rough_damage
          eor_dmg = target.rough_end_of_round_damage
          hits_possible = target.effects[PBEffects::Bide] - 1
          eor_dmg *= hits_possible
          hits_possible += 1 if user.faster_than?(target)
          next score if dmg * hits_possible + eor_dmg > target.hp * 1.1
        end
        old_score = score
        score -= 20
        PBDebug.log_score_change(score - old_score, "don't want to damage the Biding target")
      end
    end
    next score
  }
)

#===============================================================================
# Don't prefer a dancing move if the target has the Dancer ability.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:dance_move_against_dancer,
  proc { |score, move, user, ai, battle|
    if move.move.danceMove?
      old_score = score
      ai.each_foe_battler(user.side) do |b, i|
        score -= 10 if b.has_active_ability?(:DANCER)
      end
      PBDebug.log_score_change(score - old_score, "don't want to use a dance move because a foe has Dancer")
    end
    next score
  }
)
