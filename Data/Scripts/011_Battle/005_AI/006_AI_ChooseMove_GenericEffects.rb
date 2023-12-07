#===============================================================================
#
#===============================================================================
class Battle::AI
  # Main method for calculating the score for moves that raise a battler's
  # stat(s).
  # By default, assumes that a stat raise is a good thing. However, this score
  # is inverted (by desire_mult) if the target opposes the user. If the move
  # could target a foe but is targeting an ally, the score is also inverted, but
  # only because it is inverted again in def pbGetMoveScoreAgainstTarget.
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
    # Don't make score changes if the move is a damaging move and its additional
    # effect (the stat raise(s)) will be negated
    add_effect = @move.get_score_change_for_additional_effect(@user, target)
    return score if add_effect == -999   # Additional effect will be negated
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
      increment = [increment, Battle::Battler::STAT_STAGE_MAXIMUM - target.stages[stat]].min   # The actual stages gained
      # Count this as a valid stat raise
      real_stat_changes.push([stat, increment]) if increment > 0
    end
    # Discard move if it can't raise any stats
    if real_stat_changes.length == 0
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Make score change based on the additional effect chance
    score += add_effect
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

  #-----------------------------------------------------------------------------

  # Returns whether the target raising the given stat will have any impact.
  def stat_raise_worthwhile?(target, stat, fixed_change = false)
    if !fixed_change
      return false if !target.battler.pbCanRaiseStatStage?(stat, @user.battler, @move.move)
    end
    # Check if target won't benefit from the stat being raised
    return true if target.has_move_with_function?("SwitchOutUserPassOnEffects",
                                                  "PowerHigherWithUserPositiveStatStages")
    case stat
    when :ATTACK
      return false if !target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                   m.function_code != "UseUserDefenseInsteadOfUserAttack" &&
                                                   m.function_code != "UseTargetAttackInsteadOfUserAttack" }
    when :DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.physicalMove?(m.type) ||
                                              m.function_code == "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPECIAL_ATTACK
      return false if !target.check_for_move { |m| m.specialMove?(m.type) }
    when :SPECIAL_DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.specialMove?(m.type) &&
                                              m.function_code != "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPEED
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if !target.has_move_with_function?(*moves_that_prefer_high_speed)
        meaningful = false
        target_speed = target.rough_stat(:SPEED)
        each_foe_battler(target.side) do |b, i|
          b_speed = b.rough_stat(:SPEED)
          meaningful = true if target_speed < b_speed && target_speed * 2.5 > b_speed
          break if meaningful
        end
        return false if !meaningful
      end
    when :ACCURACY
      min_accuracy = 100
      target.battler.moves.each do |m|
        next if m.accuracy == 0 || m.is_a?(Battle::Move::OHKO)
        min_accuracy = m.accuracy if m.accuracy < min_accuracy
      end
      if min_accuracy >= 90 && target.stages[:ACCURACY] >= 0
        meaningful = false
        each_foe_battler(target.side) do |b, i|
          meaningful = true if b.stages[:EVASION] > 0
          break if meaningful
        end
        return false if !meaningful
      end
    when :EVASION
    end
    return true
  end

  #-----------------------------------------------------------------------------

  # Make score changes based on the general concept of raising stats at all.
  def get_target_stat_raise_score_generic(score, target, stat_changes, desire_mult = 1)
    total_increment = stat_changes.sum { |change| change[1] }
    # Prefer if move is a status move and it's the user's first/second turn
    if @user.turnCount < 2 && @move.statusMove?
      score += total_increment * desire_mult * 5
    end
    if @trainer.has_skill_flag?("HPAware")
      # Prefer if user is at high HP, don't prefer if user is at low HP
      if target.index != @user.index
        score += total_increment * desire_mult * ((100 * @user.hp / @user.totalhp) - 50) / 8   # +6 to -6 per stage
      end
      # Prefer if target is at high HP, don't prefer if target is at low HP
      score += total_increment * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 8   # +6 to -6 per stage
    end
    # NOTE: There are no abilities that trigger upon stat raise, but this is
    #       where they would be accounted for if they existed.
    return score
  end

  # Make score changes based on the raising of a specific stat.
  def get_target_stat_raise_score_one(score, target, stat, increment, desire_mult = 1)
    # Figure out how much the stat will actually change by
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
      stage_div = Battle::Battler::ACC_EVA_STAGE_DIVISORS
    end
    old_stage = target.stages[stat]
    new_stage = old_stage + increment
    inc_mult = (stage_mul[new_stage + max_stage].to_f * stage_div[old_stage + max_stage]) / (stage_div[new_stage + max_stage] * stage_mul[old_stage + max_stage])
    inc_mult -= 1
    inc_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        inc = (has_special_moves) ? 8 : 12
        score += inc * inc_mult
      end
    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end
    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function_code != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function_code != "UseTargetAttackInsteadOfUserAttack" }
        inc = (has_physical_moves) ? 8 : 12
        score += inc * inc_mult
      end
    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end
    when :SPEED
      # Prefer if target is slower than a foe
      target_speed = target.rough_stat(:SPEED)
      each_foe_battler(target.side) do |b, i|
        b_speed = b.rough_stat(:SPEED)
        next if b_speed <= target_speed   # Target already outspeeds the foe b
        next if b_speed > target_speed * 2.5   # Much too slow to reasonably catch up
        if b_speed < target_speed * (increment + 2) / 2
          score += 15 * inc_mult   # Target will become faster than the foe b
        else
          score += 8 * inc_mult
        end
        break
      end
      # Prefer if the target has Electro Ball or Power Trip/Stored Power
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if target.has_move_with_function?(*moves_that_prefer_high_speed)
        score += 5 * inc_mult
      end
      # Don't prefer if any foe has Gyro Ball
      each_foe_battler(target.side) do |b, i|
        next if !b.has_move_with_function?("PowerHigherWithTargetFasterThanUser")
        score -= 5 * inc_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end
    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
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
        score += 5 * inc_mult if eor_damage > 0
      end
      # Modify score depending on current stat stage
      if old_stage >= 2 && increment == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
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

  #-----------------------------------------------------------------------------

  # Main method for calculating the score for moves that lower a battler's
  # stat(s).
  # By default, assumes that a stat drop is a good thing. However, this score
  # is inverted (by desire_mult) if the target is the user or an ally. This
  # inversion does not happen if the move could target a foe but is targeting an
  # ally, but only because it is inverted in def pbGetMoveScoreAgainstTarget
  # instead.
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
    # Don't make score changes if the move is a damaging move and its additional
    # effect (the stat drop(s)) will be negated
    add_effect = @move.get_score_change_for_additional_effect(@user, target)
    return score if add_effect == -999   # Additional effect will be negated
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
      decrement *= 2 if !fixed_change && !@battle.moldBreaker && target.has_active_ability?(:SIMPLE)
      decrement = [decrement, Battle::Battler::STAT_STAGE_MAXIMUM + target.stages[stat]].min   # The actual stages lost
      # Count this as a valid stat drop
      real_stat_changes.push([stat, decrement]) if decrement > 0
    end
    # Discard move if it can't lower any stats
    if real_stat_changes.length == 0
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Make score change based on the additional effect chance
    score += add_effect
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

  #-----------------------------------------------------------------------------

  # Returns whether the target lowering the given stat will have any impact.
  def stat_drop_worthwhile?(target, stat, fixed_change = false)
    if !fixed_change
      return false if !target.battler.pbCanLowerStatStage?(stat, @user.battler, @move.move)
    end
    # Check if target won't benefit from the stat being lowered
    case stat
    when :ATTACK
      return false if !target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                   m.function_code != "UseUserDefenseInsteadOfUserAttack" &&
                                                   m.function_code != "UseTargetAttackInsteadOfUserAttack" }
    when :DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.physicalMove?(m.type) ||
                                              m.function_code == "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPECIAL_ATTACK
      return false if !target.check_for_move { |m| m.specialMove?(m.type) }
    when :SPECIAL_DEFENSE
      each_foe_battler(target.side) do |b, i|
        return true if b.check_for_move { |m| m.specialMove?(m.type) &&
                                              m.function_code != "UseTargetDefenseInsteadOfTargetSpDef" }
      end
      return false
    when :SPEED
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if !target.has_move_with_function?(*moves_that_prefer_high_speed)
        meaningful = false
        target_speed = target.rough_stat(:SPEED)
        each_foe_battler(target.side) do |b, i|
          b_speed = b.rough_stat(:SPEED)
          meaningful = true if target_speed > b_speed && target_speed < b_speed * 2.5
          break if meaningful
        end
        return false if !meaningful
      end
    when :ACCURACY
      meaningful = false
      target.battler.moves.each do |m|
        meaningful = true if m.accuracy > 0 && !m.is_a?(Battle::Move::OHKO)
        break if meaningful
      end
      return false if !meaningful
    when :EVASION
    end
    return true
  end

  #-----------------------------------------------------------------------------

  # Make score changes based on the general concept of lowering stats at all.
  def get_target_stat_drop_score_generic(score, target, stat_changes, desire_mult = 1)
    total_decrement = stat_changes.sum { |change| change[1] }
    # Prefer if move is a status move and it's the user's first/second turn
    if @user.turnCount < 2 && @move.statusMove?
      score += total_decrement * desire_mult * 5
    end
    if @trainer.has_skill_flag?("HPAware")
      # Prefer if user is at high HP, don't prefer if user is at low HP
      if target.index != @user.index
        score += total_decrement * desire_mult * ((100 * @user.hp / @user.totalhp) - 50) / 8   # +6 to -6 per stage
      end
      # Prefer if target is at high HP, don't prefer if target is at low HP
      score += total_decrement * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 8   # +6 to -6 per stage
    end
    # Don't prefer if target has an ability that triggers upon stat loss
    # (Competitive, Defiant)
    if target.opposes?(@user) && Battle::AbilityEffects::OnStatLoss[target.ability]
      score -= 10
    end
    return score
  end

  # Make score changes based on the lowering of a specific stat.
  def get_target_stat_drop_score_one(score, target, stat, decrement, desire_mult = 1)
    # Figure out how much the stat will actually change by
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stage_mul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stage_div = Battle::Battler::STAT_STAGE_DIVISORS
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = Battle::Battler::ACC_EVA_STAGE_MULTIPLIERS
      stage_div = Battle::Battler::ACC_EVA_STAGE_DIVISORS
    end
    old_stage = target.stages[stat]
    new_stage = old_stage - decrement
    dec_mult = (stage_mul[old_stage + max_stage].to_f * stage_div[new_stage + max_stage]) / (stage_div[old_stage + max_stage] * stage_mul[new_stage + max_stage])
    dec_mult -= 1
    dec_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        dec = (has_special_moves) ? 8 : 12
        score += dec * dec_mult
      end
    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * dec_mult
      end
    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function_code != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function_code != "UseTargetAttackInsteadOfUserAttack" }
        dec = (has_physical_moves) ? 8 : 12
        score += dec * dec_mult
      end
    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * dec_mult
      end
    when :SPEED
      # Prefer if target is faster than an ally
      target_speed = target.rough_stat(:SPEED)
      each_foe_battler(target.side) do |b, i|
        b_speed = b.rough_stat(:SPEED)
        next if target_speed < b_speed   # Target is already slower than foe b
        next if target_speed > b_speed * 2.5   # Much too fast to reasonably be overtaken
        if target_speed < b_speed * 2 / (decrement + 2)
          score += 15 * dec_mult   # Target will become slower than foe b
        else
          score += 8 * dec_mult
        end
        break
      end
      # Prefer if any ally has Electro Ball
      each_foe_battler(target.side) do |b, i|
        next if !b.has_move_with_function?("PowerHigherWithUserFasterThanTarget")
        score += 5 * dec_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 15 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end
    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * dec_mult
      end
    when :EVASION
      # Modify score depending on current stat stage
      if old_stage <= -2 && decrement == 1
        score -= 10 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * dec_mult
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

  #-----------------------------------------------------------------------------

  def get_score_for_weather(weather, move_user, starting = false)
    return 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
                @battle.pbCheckGlobalAbility(:CLOUDNINE)
    ret = 0
    if starting
      weather_extender = {
        :Sun       => :HEATROCK,
        :Rain      => :DAMPROCK,
        :Sandstorm => :SMOOTHROCK,
        :Hail      => :ICYROCK
      }[weather]
      ret += 4 if weather_extender && move_user.has_active_item?(weather_extender)
    end
    each_battler do |b, i|
      # Check each battler for weather-specific effects
      case weather
      when :Sun
        # Check for Fire/Water moves
        if b.has_damaging_move_of_type?(:FIRE)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if b.has_damaging_move_of_type?(:WATER)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for moves that freeze
        if b.has_move_with_function?("FreezeTarget", "FreezeFlinchTarget") ||
           (b.has_move_with_function?("EffectDependsOnEnvironment") &&
           [:Snow, :Ice].include?(@battle.environment))
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      when :Rain
        # Check for Fire/Water moves
        if b.has_damaging_move_of_type?(:WATER)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if b.has_damaging_move_of_type?(:FIRE)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :Sandstorm
        # Check for battlers affected by sandstorm's effects
        if b.battler.takesSandstormDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        if b.has_type?(:ROCK)   # +SpDef for Rock types
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Hail
        # Check for battlers affected by hail's effects
        if b.battler.takesHailDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :ShadowSky
        # Check for battlers affected by Shadow Sky's effects
        if b.has_damaging_move_of_type?(:SHADOW)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        if b.battler.takesShadowSkyDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      end
      # Check each battler's abilities/other moves affected by the new weather
      if @trainer.medium_skill? && !b.has_active_item?(:UTILITYUMBRELLA)
        beneficial_abilities = {
          :Sun       => [:CHLOROPHYLL, :FLOWERGIFT, :FORECAST, :HARVEST, :LEAFGUARD, :SOLARPOWER],
          :Rain      => [:DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH, :SWIFTSWIM],
          :Sandstorm => [:SANDFORCE, :SANDRUSH, :SANDVEIL],
          :Hail      => [:FORECAST, :ICEBODY, :SLUSHRUSH, :SNOWCLOAK]
        }[weather]
        if beneficial_abilities && beneficial_abilities.length > 0 &&
           b.has_active_ability?(beneficial_abilities)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if weather == :Hail && b.ability == :ICEFACE
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        negative_abilities = {
          :Sun => [:DRYSKIN]
        }[weather]
        if negative_abilities && negative_abilities.length > 0 &&
           b.has_active_ability?(negative_abilities)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
        beneficial_moves = {
          :Sun       => ["HealUserDependingOnWeather",
                         "RaiseUserAtkSpAtk1Or2InSun",
                         "TwoTurnAttackOneTurnInSun",
                         "TypeAndPowerDependOnWeather"],
          :Rain      => ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
                         "TypeAndPowerDependOnWeather"],
          :Sandstorm => ["HealUserDependingOnSandstorm",
                         "TypeAndPowerDependOnWeather"],
          :Hail      => ["FreezeTargetAlwaysHitsInHail",
                         "StartWeakenDamageAgainstUserSideIfHail",
                         "TypeAndPowerDependOnWeather"],
          :ShadowSky => ["TypeAndPowerDependOnWeather"]
        }[weather]
        if beneficial_moves && beneficial_moves.length > 0 &&
           b.has_move_with_function?(*beneficial_moves)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        negative_moves = {
          :Sun       => ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"],
          :Rain      => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"],
          :Sandstorm => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"],
          :Hail      => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"]
        }[weather]
        if negative_moves && negative_moves.length > 0 &&
           b.has_move_with_function?(*negative_moves)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def get_score_for_terrain(terrain, move_user, starting = false)
    ret = 0
    ret += 4 if starting && terrain != :None && move_user.has_active_item?(:TERRAINEXTENDER)
    # Inherent effects of terrain
    each_battler do |b, i|
      next if !b.battler.affectedByTerrain?
      case terrain
      when :Electric
        # Immunity to sleep
        if b.status == :NONE
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        if b.effects[PBEffects::Yawn] > 0
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        # Check for Electric moves
        if b.has_damaging_move_of_type?(:ELECTRIC)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Grassy
        # End of round healing
        ret += (b.opposes?(move_user)) ? -8 : 8
        # Check for Grass moves
        if b.has_damaging_move_of_type?(:GRASS)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Misty
        # Immunity to status problems/confusion
        if b.status == :NONE || b.effects[PBEffects::Confusion] == 0
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        # Check for Dragon moves
        if b.has_damaging_move_of_type?(:DRAGON)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :Psychic
        # Check for priority moves
        if b.check_for_move { |m| m.priority > 0 && m.pbTarget(b.battler)&.can_target_one_foe? }
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for Psychic moves
        if b.has_damaging_move_of_type?(:PSYCHIC)
          ret += (b.opposes?(move_user)) ? -10 : 10
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
      if seed && b.has_active_item?(seed)
        ret += (b.opposes?(move_user)) ? -8 : 8
      end
    end
    # Check for abilities/moves affected by the terrain
    if @trainer.medium_skill?
      abils = {
        :Electric => :SURGESURFER,
        :Grassy   => :GRASSPELT
      }[terrain]
      good_moves = {
        :Electric => ["DoublePowerInElectricTerrain"],
        :Grassy   => ["HealTargetDependingOnGrassyTerrain",
                      "HigherPriorityInGrassyTerrain"],
        :Misty    => ["UserFaintsPowersUpInMistyTerrainExplosive"],
        :Psychic  => ["HitsAllFoesAndPowersUpInPsychicTerrain"]
      }[terrain]
      bad_moves = {
        :Grassy => ["DoublePowerIfTargetUnderground",
                    "LowerTargetSpeed1WeakerInGrassyTerrain",
                    "RandomPowerDoublePowerIfTargetUnderground"]
      }[terrain]
      each_battler do |b, i|
        next if !b.battler.affectedByTerrain?
        # Abilities
        if b.has_active_ability?(:MIMICRY)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if abils && b.has_active_ability?(abils)
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        # Moves
        if b.has_move_with_function?("EffectDependsOnEnvironment",
                                     "SetUserTypesBasedOnEnvironment",
                                     "TypeAndPowerDependOnTerrain",
                                     "UseMoveDependingOnEnvironment")
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if good_moves && b.has_move_with_function?(*good_moves)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if bad_moves && b.has_move_with_function?(*bad_moves)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      end
    end
    return ret
  end
end
