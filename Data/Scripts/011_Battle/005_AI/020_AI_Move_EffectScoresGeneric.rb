class Battle::AI
  #=============================================================================
  # Main method for calculating the score for moves that raise a battler's
  # stat(s).
  # By default, assumes that a stat raise is a good thing. However, this score
  # is inverted (by desire_mult) if the target opposes the user. If the move
  # could target a foe but is targeting an ally, the score is also inverted, but
  # only because it is inverted again in def pbGetMoveScoreAgainstTarget.
  #=============================================================================
  def get_score_for_target_stat_raise(score, target, stat_changes, whole_effect = true,
                                      fixed_change = false, ignore_contrary = false)
    whole_effect = false if @move.damagingMove?
    # Decide whether the target raising its stat(s) is a good thing
    desire_mult = 1
    if target.opposes?(@user) ||
       (@move.pbTarget(@user.battler).targets_foe && target.index != @user.index)
      desire_mult = -1
    end
    # If target has Contrary, use different calculations to score the stat change
    if !ignore_contrary && !fixed_change && !@battle.moldBreaker && target.has_active_ability?(:CONTRARY)
      if desire_mult > 0 && whole_effect
        PBDebug.log_score_change(MOVE_USELESS_SCORE - score, "don't prefer raising target's stats (it has Contrary)")
        return MOVE_USELESS_SCORE
      end
      return get_score_for_target_stat_drop(score, target, stat_changes, whole_effect, fixed_change, true)
    end
    # Don't make score changes if target will faint from EOR damage
    if target.rough_end_of_round_damage >= target.hp
      ret = (whole_effect) ? MOVE_USELESS_SCORE : score
      PBDebug.log("     ignore stat change (target predicted to faint this round)")
      return ret
    end
    # Don't make score changes if foes have Unaware and target can't make use of
    # extra stat stages
    if !target.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      foe_is_aware = false
      each_foe_battler(target.side) do |b, i|
        foe_is_aware = true if !b.has_active_ability?(:UNAWARE)
      end
      if !foe_is_aware
        ret = (whole_effect) ? MOVE_USELESS_SCORE : score
        PBDebug.log("     ignore stat change (target's foes have Unaware)")
        return ret
      end
    end
    # Figure out which stat raises can happen
    real_stat_changes = []
    stat_changes.each_with_index do |stat, idx|
      next if idx.odd?
      if !stat_raise_worthwhile?(target, stat, fixed_change)
        if target.index == @user.index
          PBDebug.log("     raising the user's #{GameData::Stat.get(stat).name} isn't worthwhile")
        else
          PBDebug.log("     raising the target's #{GameData::Stat.get(stat).name} isn't worthwhile")
        end
        next
      end
      # Calculate amount that stat will be raised by
      increment = stat_changes[idx + 1]
      increment *= 2 if !fixed_change && !@battle.moldBreaker && target.has_active_ability?(:SIMPLE)
      increment = [increment, 6 - target.stages[stat]].min   # The actual stages gained
      # Count this as a valid stat raise
      real_stat_changes.push([stat, increment]) if increment > 0
    end
    # Discard move if it can't raise any stats
    if real_stat_changes.length == 0
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Make score changes based on the general concept of raising stats at all
    score = get_target_stat_raise_score_generic(score, target, real_stat_changes, desire_mult)
    # Make score changes based on the specific changes to each stat that will be
    # raised
    real_stat_changes.each do |change|
      old_score = score
      score = get_target_stat_raise_score_one(score, target, change[0], change[1], desire_mult)
      if target.index == @user.index
        PBDebug.log_score_change(score - old_score, "raising the user's #{GameData::Stat.get(change[0]).name} by #{change[1]}")
      else
        PBDebug.log_score_change(score - old_score, "raising the target's #{GameData::Stat.get(change[0]).name} by #{change[1]}")
      end
    end
    return score
  end

  #=============================================================================
  # Returns whether the target raising the given stat will have any impact.
  # TODO: Make sure the move's actual damage category is taken into account,
  #       i.e. CategoryDependsOnHigherDamagePoisonTarget and
  #       CategoryDependsOnHigherDamageIgnoreTargetAbility.
  #=============================================================================
  def stat_raise_worthwhile?(target, stat, fixed_change = false)
    if !fixed_change
      return false if !target.battler.pbCanRaiseStatStage?(stat, @user.battler, @move.move)
    end
    # Check if target won't benefit from the stat being raised
    # TODO: Exception if target knows Baton Pass/Stored Power?
    case stat
    when :ATTACK
      return false if !target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                   m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                   m.function != "UseTargetAttackInsteadOfUserAttack" }
    when :DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.physicalMove?(m.type) ||
                                              m.function == "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPECIAL_ATTACK
      return false if !target.check_for_move { |m| m.specialMove?(m.type) }
    when :SPECIAL_DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.specialMove?(m.type) &&
                                              m.function != "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPEED
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if !target.has_move_with_function?(*moves_that_prefer_high_speed)
        each_foe_battler(target.side) do |b, i|
          return true if b.faster_than?(target)
        end
        return false
      end
    when :ACCURACY
    when :EVASION
    end
    return true
  end

  #=============================================================================
  # Make score changes based on the general concept of raising stats at all.
  #=============================================================================
  def get_target_stat_raise_score_generic(score, target, stat_changes, desire_mult = 1)
    total_increment = stat_changes.sum { |change| change[1] }
    # TODO: Just return if the target's foe is predicted to use a phazing move
    #       (one that switches the target out).
    # TODO: Don't prefer if foe is faster than target and is predicted to deal
    #       lethal damage.
    # TODO: Don't prefer if foe is slower than target but is predicted to be
    #       able to 2HKO the target.
    # TODO: Prefer if foe is semi-invulnerable and target is faster (can't hit
    #       the foe anyway).
    # Prefer if move is a status move and it's the user's first/second turn
    if @user.turnCount < 2 && @move.statusMove?
      score += total_increment * desire_mult * 4
    end
    # Prefer if user is at high HP, don't prefer if user is at low HP
    if target.index != @user.index
      if @user.hp >= @user.totalhp * 0.7
        score += total_increment * desire_mult * 3
      else
        score += total_increment * desire_mult * ((100 * @user.hp / @user.totalhp) - 50) / 6   # +3 to -8 per stage
      end
    end
    # Prefer if target is at high HP, don't prefer if target is at low HP
    if target.hp >= target.totalhp * 0.7
      score += total_increment * desire_mult * 4
    else
      score += total_increment * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 4   # +5 to -12 per stage
    end
    # TODO: Look at abilities that trigger upon stat raise. There are none.
    return score
  end

  #=============================================================================
  # Make score changes based on the raising of a specific stat.
  #=============================================================================
  def get_target_stat_raise_score_one(score, target, stat, increment, desire_mult = 1)
    # Figure out how much the stat will actually change by
    stage_mul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stage_div = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
      stage_div = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    end
    old_stage = target.stages[stat]
    new_stage = old_stage + increment
    inc_mult = (stage_mul[new_stage + 6].to_f * stage_div[old_stage + 6]) / (stage_div[new_stage + 6] * stage_mul[old_stage + 6])
    inc_mult -= 1
    inc_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        inc = (has_special_moves) ? 10 : 20
        score += inc * inc_mult
      end
    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end
    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function != "UseTargetAttackInsteadOfUserAttack" }
        inc = (has_physical_moves) ? 10 : 20
        score += inc * inc_mult
      end
    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end
    when :SPEED
      # Prefer if target is slower than a foe
      # TODO: Don't prefer if the target is too much slower than any foe that it
      #       can't catch up.
      each_foe_battler(target.side) do |b, i|
        next if target.faster_than?(b)
        score += 15 * inc_mult
        break
      end
      # TODO: Prefer if the target is able to cause flinching (moves that
      #       flinch, or has King's Rock/Stench).
      # Prefer if the target has Electro Ball or Power Trip/Stored Power
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if target.has_move_with_function?(*moves_that_prefer_high_speed)
        score += 8 * inc_mult
      end
      # Don't prefer if any foe has Gyro Ball
      each_foe_battler(target.side) do |b, i|
        next if !b.has_move_with_function?("PowerHigherWithTargetFasterThanUser")
        score -= 8 * inc_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end
    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        min_accuracy = 100
        target.battler.moves.each do |m|
          next if m.accuracy == 0 || m.is_a?(Battle::Move::OHKO)
          min_accuracy = m.accuracy if m.accuracy < min_accuracy
        end
        min_accuracy = min_accuracy * stage_mul[old_stage] / stage_div[old_stage]
        if min_accuracy < 90
          score += 10 * inc_mult
        end
      end
    when :EVASION
      # Prefer if a foe of the target will take damage at the end of the round
      each_foe_battler(target.side) do |b, i|
        eor_damage = b.rough_end_of_round_damage
        score += 4 * inc_mult if eor_damage > 0
      end
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end
    end
    # Prefer if target has Stored Power
    if target.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      score += 5 * increment * desire_mult
    end
    # Don't prefer if any foe has Punishment
    each_foe_battler(target.side) do |b, i|
      next if !b.has_move_with_function?("PowerHigherWithTargetPositiveStatStages")
      score -= 5 * increment * desire_mult
    end
    return score
  end

  #=============================================================================
  # Main method for calculating the score for moves that lower a battler's
  # stat(s).
  # By default, assumes that a stat drop is a good thing. However, this score
  # is inverted (by desire_mult) if the target is the user or an ally. This
  # inversion does not happen if the move could target a foe but is targeting an
  # ally, but only because it is inverted in def pbGetMoveScoreAgainstTarget
  # instead.
  # TODO: Revisit this method as parts may need rewriting.
  #=============================================================================
  def get_score_for_target_stat_drop(score, target, stat_changes, whole_effect = true,
                                     fixed_change = false, ignore_contrary = false)
    whole_effect = false if @move.damagingMove?
    # Decide whether the target lowering its stat(s) is a good thing
    desire_mult = -1
    if target.opposes?(@user) ||
       (@move.pbTarget(@user.battler).targets_foe && target.index != @user.index)
      desire_mult = 1
    end
    # If target has Contrary, use different calculations to score the stat change
    if !ignore_contrary && !fixed_change && !@battle.moldBreaker && target.has_active_ability?(:CONTRARY)
      if desire_mult > 0 && whole_effect
        PBDebug.log_score_change(MOVE_USELESS_SCORE - score, "don't prefer lowering target's stats (it has Contrary)")
        return MOVE_USELESS_SCORE
      end
      return get_score_for_target_stat_raise(score, target, stat_changes, whole_effect, fixed_change, true)
    end
    # Don't make score changes if target will faint from EOR damage
    if target.rough_end_of_round_damage >= target.hp
      ret = (whole_effect) ? MOVE_USELESS_SCORE : score
      PBDebug.log("     ignore stat change (target predicted to faint this round)")
      return ret
    end
    # Don't make score changes if foes have Unaware and target can't make use of
    # its lowered stat stages
    foe_is_aware = false
    each_foe_battler(target.side) do |b, i|
      foe_is_aware = true if !b.has_active_ability?(:UNAWARE)
    end
    if !foe_is_aware
      ret = (whole_effect) ? MOVE_USELESS_SCORE : score
      PBDebug.log("     ignore stat change (target's foes have Unaware)")
      return ret
    end
    # Figure out which stat drops can happen
    real_stat_changes = []
    stat_changes.each_with_index do |stat, idx|
      next if idx.odd?
      if !stat_drop_worthwhile?(target, stat, fixed_change)
        if target.index == @user.index
          PBDebug.log("     lowering the user's #{GameData::Stat.get(stat).name} isn't worthwhile")
        else
          PBDebug.log("     lowering the target's #{GameData::Stat.get(stat).name} isn't worthwhile")
        end
        next
      end
      # Calculate amount that stat will be lowered by
      decrement = stat_changes[idx + 1]
      decrement *= 2 if !fixed_change && !@battle.moldBreaker && @user.has_active_ability?(:SIMPLE)
      decrement = [decrement, 6 + target.stages[stat]].min   # The actual stages lost
      # Count this as a valid stat drop
      real_stat_changes.push([stat, decrement]) if decrement > 0
    end
    # Discard move if it can't lower any stats
    if real_stat_changes.length == 0
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Make score changes based on the general concept of lowering stats at all
    score = get_target_stat_drop_score_generic(score, target, real_stat_changes, desire_mult)
    # Make score changes based on the specific changes to each stat that will be
    # lowered
    real_stat_changes.each do |change|
      old_score = score
      score = get_target_stat_drop_score_one(score, target, change[0], change[1], desire_mult)
      if target.index == @user.index
        PBDebug.log_score_change(score - old_score, "lowering the user's #{GameData::Stat.get(change[0]).name} by #{change[1]}")
      else
        PBDebug.log_score_change(score - old_score, "lowering the target's #{GameData::Stat.get(change[0]).name} by #{change[1]}")
      end
    end
    return score
  end

  #=============================================================================
  # Returns whether the target lowering the given stat will have any impact.
  # TODO: Make sure the move's actual damage category is taken into account,
  #       i.e. CategoryDependsOnHigherDamagePoisonTarget and
  #       CategoryDependsOnHigherDamageIgnoreTargetAbility.
  # TODO: Revisit this method as parts may need rewriting.
  #=============================================================================
  def stat_drop_worthwhile?(target, stat, fixed_change = false)
    if !fixed_change
      return false if !target.battler.pbCanLowerStatStage?(stat, @user.battler, @move.move)
    end
    # Check if target won't benefit from the stat being lowered
    case stat
    when :ATTACK
      return false if !target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                   m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                   m.function != "UseTargetAttackInsteadOfUserAttack" }
    when :DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.physicalMove?(m.type) ||
                                              m.function == "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPECIAL_ATTACK
      return false if !target.check_for_move { |m| m.specialMove?(m.type) }
    when :SPECIAL_DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.specialMove?(m.type) &&
                                              m.function != "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPEED
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if !target.has_move_with_function?(*moves_that_prefer_high_speed)
        each_foe_battler(target.side) do |b, i|
          return true if !b.faster_than?(target)
        end
        return false
      end
    when :ACCURACY
    when :EVASION
    end
    return true
  end

  #=============================================================================
  # Make score changes based on the general concept of lowering stats at all.
  # TODO: Revisit this method as parts may need rewriting.
  # TODO: All comments in this method may be inaccurate.
  #=============================================================================
  def get_target_stat_drop_score_generic(score, target, stat_changes, desire_mult = 1)
    total_decrement = stat_changes.sum { |change| change[1] }
    # TODO: Just return if target is predicted to switch out (except via Baton Pass).
    # TODO: Don't prefer if target is faster than user and is predicted to deal
    #       lethal damage.
    # TODO: Don't prefer if target is slower than user but is predicted to be able
    #       to 2HKO user.
    # TODO: Don't prefer if target is semi-invulnerable and user is faster.
    # Prefer if move is a status move and it's the user's first/second turn
    if @user.turnCount < 2 && @move.statusMove?
      score += total_decrement * desire_mult * 4
    end
    # Prefer if user is at high HP, don't prefer if user is at low HP
    if target.index != @user.index
      if @user.hp >= @user.totalhp * 0.7
        score += total_decrement * desire_mult * 3
      else
        score += total_decrement * desire_mult * ((100 * @user.hp / @user.totalhp) - 50) / 6   # +3 to -8 per stage
      end
    end
    # Prefer if target is at high HP, don't prefer if target is at low HP
    if target.hp >= target.totalhp * 0.7
      score += total_decrement * desire_mult * 3
    else
      score += total_decrement * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 6   # +3 to -8 per stage
    end
    # TODO: Look at abilities that trigger upon stat lowering.
    return score
  end

  #=============================================================================
  # Make score changes based on the lowering of a specific stat.
  # TODO: Revisit this method as parts may need rewriting.
  #=============================================================================
  def get_target_stat_drop_score_one(score, target, stat, decrement, desire_mult = 1)
    # Figure out how much the stat will actually change by
    stage_mul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stage_div = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
      stage_div = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    end
    old_stage = target.stages[stat]
    new_stage = old_stage - decrement
    dec_mult = (stage_mul[old_stage + 6].to_f * stage_div[new_stage + 6]) / (stage_div[old_stage + 6] * stage_mul[new_stage + 6])
    dec_mult -= 1
    dec_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        dec = (has_special_moves) ? 5 : 10
        score += dec * dec_mult
      end
    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end
    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function != "UseTargetAttackInsteadOfUserAttack" }
        dec = (has_physical_moves) ? 5 : 10
        score += dec * dec_mult
      end
    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end
    when :SPEED
      # Prefer if target is faster than an ally
      # TODO: Don't prefer if the target is too much faster than any ally and
      #       can't be brought slow enough.
      each_foe_battler(target.side) do |b, i|
        next if b.faster_than?(target)
        score += 15 * dec_mult
        break
      end
      # Prefer if any ally has Electro Ball
      each_foe_battler(target.side) do |b, i|
        next if !b.has_move_with_function?("PowerHigherWithUserFasterThanTarget")
        score += 8 * dec_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end
    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end
      # TODO: Prefer if target is poisoned/toxiced/Leech Seeded/cursed.
    when :EVASION
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end
    end
    # Prefer if target has Stored Power
    if target.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      score += 5 * decrement * desire_mult
    end
    # Don't prefer if any foe has Punishment
    each_foe_battler(target.side) do |b, i|
      next if !b.has_move_with_function?("PowerHigherWithTargetPositiveStatStages")
      score -= 5 * decrement * desire_mult
    end
    return score
  end

  #=============================================================================
  #
  #=============================================================================
  def get_score_for_terrain(terrain, move_user)
    ret = 0
    # Inherent effects of terrain
    each_battler do |b, i|
      next if !b.battler.affectedByTerrain?
      case terrain
      when :Electric
        # Immunity to sleep
        # TODO: Check all battlers for sleep-inducing moves and other effects?
        if b.status == :NONE
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if b.effects[PBEffects::Yawn] > 0
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        # Check for Electric moves
        if b.has_damaging_move_of_type?(:ELECTRIC)
          ret += (b.opposes?(move_user)) ? -15 : 15
        end
      when :Grassy
        # End of round healing
        ret += (b.opposes?(move_user)) ? -10 : 10
        # Check for Grass moves
        if b.has_damaging_move_of_type?(:GRASS)
          ret += (b.opposes?(move_user)) ? -15 : 15
        end
      when :Misty
        # Immunity to status problems/confusion
        # TODO: Check all battlers for status/confusion-inducing moves and other
        #       effects?
        if b.status == :NONE || b.effects[PBEffects::Confusion] == 0
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        # Check for Dragon moves
        if b.has_damaging_move_of_type?(:DRAGON)
          ret += (b.opposes?(move_user)) ? 15 : -15
        end
      when :Psychic
        # Check for priority moves
        if b.check_for_move { |m| m.priority > 0 && m.pbTarget(b.battler)&.can_target_one_foe? }
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for Psychic moves
        if b.has_damaging_move_of_type?(:PSYCHIC)
          ret += (b.opposes?(move_user)) ? -15 : 15
        end
      end
    end
    # Held items relating to terrain
    seed = {
      :Electric => :ELECTRICSEED,
      :Grassy   => :GRASSYSEED,
      :Misty    => :MISTYSEED,
      :Psychic  => :PSYCHICSEED
    }[terrain]
    each_battler do |b, i|
      if b.has_active_item?(:TERRAINEXTENDER)
        ret += (b.opposes?(move_user)) ? -15 : 15
      elsif seed && b.has_active_item?(seed)
        ret += (b.opposes?(move_user)) ? -15 : 15
      end
    end
    # Check for abilities/moves affected by the terrain
    if @trainer.medium_skill?
      abils = {
        :Electric => :SURGESURFER,
        :Grassy   => :GRASSPELT,
        :Misty    => nil,
        :Psychic  => nil
      }[terrain]
      good_moves = {
        :Electric => ["DoublePowerInElectricTerrain"],
        :Grassy   => ["HealTargetDependingOnGrassyTerrain",
                      "HigherPriorityInGrassyTerrain"],
        :Misty    => ["UserFaintsPowersUpInMistyTerrainExplosive"],
        :Psychic  => ["HitsAllFoesAndPowersUpInPsychicTerrain"]
      }[terrain]
      bad_moves = {
        :Electric => nil,
        :Grassy   => ["DoublePowerIfTargetUnderground",
                      "LowerTargetSpeed1WeakerInGrassyTerrain",
                      "RandomPowerDoublePowerIfTargetUnderground"],
        :Misty    => nil,
        :Psychic  => nil
      }[terrain]
      each_battler do |b, i|
        next if !b.battler.affectedByTerrain?
        # Abilities
        if b.has_active_ability?(:MIMICRY)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if abils && b.has_active_ability?(abils)
          ret += (b.opposes?(move_user)) ? -15 : 15
        end
        # Moves
        if b.has_move_with_function?("EffectDependsOnEnvironment",
                                     "SetUserTypesBasedOnEnvironment",
                                     "TypeAndPowerDependOnTerrain",
                                     "UseMoveDependingOnEnvironment")
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if good_moves && b.has_move_with_function?(*good_moves)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if bad_moves && b.has_move_with_function?(*bad_moves)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      end
    end
    return ret
  end
end
