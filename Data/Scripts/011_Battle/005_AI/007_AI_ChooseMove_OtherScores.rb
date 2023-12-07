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
Battle::AI::Handlers::GeneralMoveScore.add(:shadow_moves,
  proc { |score, move, user, ai, battle|
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
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:priority_move_against_faster_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill? && target.faster_than?(user) && move.rough_priority(user) > 0
      # User is at risk of being knocked out
      if ai.trainer.has_skill_flag?("HPAware") && user.hp < user.totalhp / 3
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "user at low HP and move has priority over faster target")
      end
      # Target is predicted to be knocked out by the move
      if move.damagingMove? && move.rough_damage >= target.hp
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "target at low HP and move has priority over faster target")
      end
      # Any foe knows Quick Guard and can protect against priority moves
      old_score = score
      ai.each_foe_battler(user.side) do |b, i|
        next if !b.has_move_with_function?("ProtectUserSideFromPriorityMoves")
        next if Settings::MECHANICS_GENERATION <= 5 && b.effects[PBEffects::ProtectRate] > 1
        score -= 5
      end
      if score != old_score
        PBDebug.log_score_change(score - old_score, "a foe knows Quick Guard and may protect against priority moves")
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
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:good_move_for_choice_item,
  proc { |score, move, user, ai, battle|
    next score if !ai.trainer.medium_skill?
    next score if !user.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) &&
                  !user.has_active_ability?(:GORILLATACTICS)
    old_score = score
    # Really don't prefer status moves (except Trick)
    if move.statusMove? && move.function_code != "UserTargetSwapItems"
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
# Don't prefer Fire-type moves if target knows Powder and is faster than the
# user.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_can_powder_fire_moves,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill? && move.rough_type == :FIRE &&
       target.has_move_with_function?("TargetNextFireMoveDamagesTarget") &&
       target.faster_than?(user)
      old_score = score
      score -= 5   # Only 5 because we're not sure target will use Powder
      PBDebug.log_score_change(score - old_score, "target knows Powder and could negate Fire moves")
    end
    next score
  }
)

#===============================================================================
# Don't prefer moves if target knows a move that can make them Electric-type,
# and if target is unaffected by Electric moves.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_can_make_moves_Electric_and_be_immune,
  proc { |score, move, user, target, ai, battle|
    next score if !ai.trainer.high_skill?
    next score if !target.has_move_with_function?("TargetMovesBecomeElectric") &&
                  !(move.rough_type == :NORMAL && target.has_move_with_function?("NormalMovesBecomeElectric"))
    next score if !ai.pokemon_can_absorb_move?(target, move, :ELECTRIC) &&
                  !Effectiveness.ineffective?(target.effectiveness_of_type_against_battler(:ELECTRIC, user))
    priority = move.rough_priority(user)
    if priority > 0 || (priority == 0 && target.faster_than?(user))   # Target goes first
      old_score = score
      score -= 5   # Only 5 because we're not sure target will use Electrify/Ion Deluge
      PBDebug.log_score_change(score - old_score, "target knows Electrify/Ion Deluge and is immune to Electric moves")
    end
    next score
  }
)

#===============================================================================
# Don't prefer attacking the target if they'd be semi-invulnerable.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_semi_invulnerable,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.rough_accuracy > 0 &&
       (target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
      next score if user.has_active_ability?(:NOGUARD) || target.has_active_ability?(:NOGUARD)
      priority = move.rough_priority(user)
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
          if move.move.multiHitMove? && target.hp == target.totalhp &&
             (target.has_active_ability?(:STURDY) || target.has_active_item?(:FOCUSSASH))
            old_score = score
            score += 8
            PBDebug.log_score_change(score - old_score, "predicted to overcome the target's Sturdy/Focus Sash")
          end
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
          score += 5 if move.move.multiHitMove?
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
# Don't prefer a damaging move if it will trigger the target's ability or held
# item when used, e.g. Effect Spore/Rough Skin, Pickpocket, Rocky Helmet, Red
# Card.
# NOTE: These abilities/items may not be triggerable after all (e.g. they
#       require the move to make contact but it doesn't), or may have a negative
#       effect for the target (e.g. Air Balloon popping), but it's too much
#       effort to go into detail deciding all this.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:trigger_target_ability_or_item_upon_hit,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill? && move.damagingMove? && target.effects[PBEffects::Substitute] == 0
      if target.ability_active?
        if Battle::AbilityEffects::OnBeingHit[target.ability] ||
           (Battle::AbilityEffects::AfterMoveUseFromTarget[target.ability] &&
           (!user.has_active_ability?(:SHEERFORCE) || move.move.addlEffect == 0))
          old_score = score
          score += 8
          PBDebug.log_score_change(score - old_score, "can trigger the target's ability")
        end
      end
      if target.battler.isSpecies?(:CRAMORANT) && target.ability == :GULPMISSILE &&
         target.battler.form > 0 && !target.effects[PBEffects::Transform]
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "can trigger the target's ability")
      end
      if target.item_active?
        if Battle::ItemEffects::OnBeingHit[target.item] ||
           (Battle::ItemEffects::AfterMoveUseFromTarget[target.item] &&
           (!user.has_active_ability?(:SHEERFORCE) || move.move.addlEffect == 0))
          old_score = score
          score += 8
          PBDebug.log_score_change(score - old_score, "can trigger the target's item")
        end
      end
    end
    next score
  }
)

#===============================================================================
# Prefer a damaging move if it will trigger the user's ability when used, e.g.
# Poison Touch, Magician.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:trigger_user_ability_upon_hit,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill? && user.ability_active? && move.damagingMove? &&
       target.effects[PBEffects::Substitute] == 0
      # NOTE: The only ability with an OnDealingHit effect also requires the
      #       move to make contact. The only abilities with an OnEndOfUsingMove
      #       effect revolve around damaging moves.
      if (Battle::AbilityEffects::OnDealingHit[user.ability] && move.move.contactMove?) ||
         Battle::AbilityEffects::OnEndOfUsingMove[user.ability]
        old_score = score
        score += 8
        PBDebug.log_score_change(score - old_score, "can trigger the user's ability")
      end
    end
    next score
  }
)

#===============================================================================
# Don't prefer damaging moves that will knock out the target if they are using
# Destiny Bond or Grudge.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:knocking_out_a_destiny_bonder_or_grudger,
  proc { |score, move, user, target, ai, battle|
    if (ai.trainer.has_skill_flag?("HPAware") || ai.trainer.high_skill?) && move.damagingMove? &&
       (target.effects[PBEffects::DestinyBond] || target.effects[PBEffects::Grudge])
      priority = move.rough_priority(user)
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
# Don't prefer damaging moves if the target is using Rage, unless the move will
# deal enough damage to KO the target within two rounds.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:damaging_a_raging_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target.effects[PBEffects::Rage] && move.damagingMove?
      # Worth damaging the target if it can be knocked out within two rounds
      if ai.trainer.has_skill_flag?("HPAware")
        next score if (move.rough_damage + target.rough_end_of_round_damage) * 2 > target.hp * 1.1
      end
      old_score = score
      score -= 10
      PBDebug.log_score_change(score - old_score, "don't want to damage a Raging target")
    end
    next score
  }
)

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
          next score if (dmg * hits_possible) + eor_dmg > target.hp * 1.1
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
