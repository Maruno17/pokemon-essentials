class Battle::AI
  #=============================================================================
  # Main method for calculating the score for moves that raise a battler's
  # stat(s).
  # By default, assumes that a stat raise is a good thing. However, this score
  # is inverted (by desire_mult) if the target opposes the user. If the move
  # could target a foe but is targeting an ally, the score is also inverted, but
  # only because it is inverted again in def pbGetMoveScoreAgainstTarget.
  #=============================================================================
  def get_score_for_target_stat_raise(score, target, stat_changes, whole_effect = true)
    whole_effect = false if @move.damagingMove?
    # Decide whether the target raising its stat(s) is a good thing
    desire_mult = 1
    if target.opposes?(@user) ||
       (@move.pbTarget(@user.battler).targets_foe && target.index != @user.index)
      desire_mult = -1
    end
    # Discard status move/don't prefer damaging move if target has Contrary
    # TODO: Maybe this should return get_score_for_target_stat_drop if Contrary
    #       applies and desire_mult < 1.
    if !@battle.moldBreaker && target.has_active_ability?(:CONTRARY) && desire_mult > 1
      return (whole_effect) ? MOVE_USELESS_SCORE : score - 20
    end
    # Don't make score changes if target will faint from EOR damage
    if target.rough_end_of_round_damage > target.hp
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Don't make score changes if foes have Unaware and target can't make use of
    # extra stat stages
    if !target.check_for_move { |m| m.function == "PowerHigherWithUserPositiveStatStages" }
      foe_is_aware = false
      each_foe_battler(target.side) do |b, i|
        foe_is_aware = true if !b.has_active_ability?(:UNAWARE)
      end
      if !foe_is_aware
        return (whole_effect) ? MOVE_USELESS_SCORE : score
      end
    end

    # Figure out which stat raises can happen
    real_stat_changes = []
    stat_changes.each_with_index do |stat, idx|
      next if idx.odd?
      next if !stat_raise_worthwhile?(target, stat)
      # Calculate amount that stat will be raised by
      increment = stat_changes[idx + 1]
      if @move.function == "RaiseUserAtkSpAtk1Or2InSun"
        increment = 1
        increment = 2 if [:Sun, :HarshSun].include?(target.battler.effectiveWeather)
      end
      increment *= 2 if !@battle.moldBreaker && target.has_active_ability?(:SIMPLE)
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
      score = get_target_stat_raise_score_one(score, target, change[0], change[1], desire_mult)
    end

    return score
  end

  #=============================================================================
  # Returns whether the target raising the given stat will have any impact.
  # TODO: Make sure the move's actual damage category is taken into account,
  #       i.e. CategoryDependsOnHigherDamagePoisonTarget and
  #       CategoryDependsOnHigherDamageIgnoreTargetAbility.
  #=============================================================================
  def stat_raise_worthwhile?(target, stat)
    return false if !target.battler.pbCanRaiseStatStage?(stat, @user.battler, @move.move)
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
      if !target.check_for_move { |m| moves_that_prefer_high_speed.include?(m.function) }
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


=begin
    mini_score = 1.0
    # Determine whether the move boosts Attack, Special Attack or Speed (Bulk Up
    # is sometimes not considered a sweeping move)
    sweeping_stat = false
    offensive_stat = false
    stat_changes.each do |change|
      next if ![:ATTACK, :SPECIAL_ATTACK, :SPEED].include?(change[0])
      sweeping_stat = true
      next if @move.function == "RaiseUserAtkDef1"   # Bulk Up (+Atk +Def)
      offensive_stat = true
      break
    end

    # TODO: Prefer if user's moves won't do much damage.
    # Prefer if user has something that will limit damage taken
    mini_score *= 1.3 if @user.effects[PBEffects::Substitute] > 0 ||
                         (@user.form == 0 && @user.ability_id == :DISGUISE)

    # Don't prefer if user is badly poisoned
    mini_score *= 0.2 if @user.effects[PBEffects::Toxic] > 0 && !offensive_stat
    # Don't prefer if user is confused
    if @user.effects[PBEffects::Confusion] > 0
      # TODO: Especially don't prefer if the move raises Atk. Even more so if
      #       the move raises the stat by 2+. Not quite so much if the move also
      #       raises Def.
      mini_score *= 0.5
    end
    # Don't prefer if user is infatuated or Leech Seeded
    if @user.effects[PBEffects::Attract] >= 0 || @user.effects[PBEffects::LeechSeed] >= 0
      mini_score *= (offensive_stat) ? 0.6 : 0.3
    end
    # Don't prefer if user has an ability or item that will force it to switch
    # out
    if @user.hp < @user.totalhp * 3 / 4
      mini_score *= 0.3 if @user.hasActiveAbility?([:EMERGENCYEXIT, :WIMPOUT])
      mini_score *= 0.3 if @user.hasActiveItem?(:EJECTBUTTON)
    end

    # Prefer if target has a status problem
    if @target.status != :NONE
      mini_score *= (sweeping_stat) ? 1.2 : 1.1
      case @target.status
      when :SLEEP, :FROZEN
        mini_score *= 1.3
      when :BURN
        # TODO: Prefer if the move boosts Sp Def.
        mini_score *= 1.1 if !offensive_stat
      end
    end
    # Prefer if target is yawning
    if @target.effects[PBEffects::Yawn] > 0
      mini_score *= (sweeping_stat) ? 1.7 : 1.3
    end
    # Prefer if target is recovering after Hyper Beam
    if @target.effects[PBEffects::HyperBeam] > 0
      mini_score *= (sweeping_stat) ? 1.3 : 1.2
    end
    # Prefer if target is Encored into a status move
    if @target.effects[PBEffects::Encore] > 0 &&
       GameData::Move.get(@target.effects[PBEffects::EncoreMove]).category == 2   # Status move
      # TODO: Why should this check greatly prefer raising both the user's defences?
      if sweeping_stat || @move.function == "RaiseUserDefSpDef1"   # +Def +SpDef
        mini_score *= 1.5
      else
        mini_score *= 1.3
      end
    end
    # TODO: Don't prefer if target has previously used a move that would force
    #       the user to switch (or Yawn/Perish Song which encourage it). Prefer
    #       instead if the move raises evasion. Note this comes after the
    #       dissociation of Bulk Up from sweeping_stat.

    if @trainer.medium_skill?
      # TODO: Prefer if the maximum damage the target has dealt wouldn't hurt
      #       the user much.
    end

    # Don't prefer if it's not a single battle
    if !@battle.singleBattle?
      mini_score *= (offensive_stat) ? 0.25 : 0.5
    end

    return mini_score
=end
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
    inc_mult = (stage_mul[new_stage].to_f * stage_div[old_stage]) / (stage_div[new_stage] * stage_mul[old_stage])
    inc_mult -= 1
    inc_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        inc = (has_special_moves) ? 10 : 20
        score += inc * inc_mult
      end

    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end

    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function != "UseTargetAttackInsteadOfUserAttack" }
        inc = (has_physical_moves) ? 10 : 20
        score += inc * inc_mult
      end

    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
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
      if target.check_for_move { |m| moves_that_prefer_high_speed.include?(m.function) }
        score += 8 * inc_mult
      end
      # Don't prefer if any foe has Gyro Ball
      each_foe_battler(target.side) do |b, i|
        next if !b.check_for_move { |m| m.function == "PowerHigherWithTargetFasterThanUser" }
        score -= 8 * inc_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end

    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
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
      # Prefer if a foe will (probably) take damage at the end of the round
      # TODO: Should this take into account EOR healing, one-off damage and
      #       damage-causing effects that wear off naturally (like Sea of Fire)?
      # TODO: Emerald AI also prefers if target is rooted via Ingrain.
      each_foe_battler(target.side) do |b, i|
        eor_damage = b.rough_end_of_round_damage
        next if eor_damage <= 0
      end
      # Modify score depending on current stat stage
      if old_stage >= 2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 10 * inc_mult
      end

    end

    # Prefer if target has Stored Power
    if target.check_for_move { |m| m.function == "PowerHigherWithUserPositiveStatStages" }
      score += 5 * increment * desire_mult
    end
    # Don't prefer if any foe has Punishment
    each_foe_battler(target.side) do |b, i|
      next if !b.check_for_move { |m| m.function == "PowerHigherWithTargetPositiveStatStages" }
      score -= 5 * increment * desire_mult
    end

    return score


=begin
    mini_score = 1.0
    case stat
    when :ATTACK
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
#      if @user.hp == @user.totalhp &&
#         (@user.hasActiveItem?(:FOCUSSASH) || (!@battle.moldBreaker && @user.hasActiveAbility?(:STURDY)))
#        if !(@battle.pbWeather == :Sandstorm && @user.takesSandstormDamage?) &&
#           !(@battle.pbWeather == :Hail && @user.takesHailDamage?) &&
#           !(@battle.pbWeather == :ShadowSky && @user.takesShadowSkyDamage?)
#          mini_score *= 1.4
#        end
#      end
      # Prefer if user has the Sweeper role
      # TODO: Is 1.1x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
#      mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)

#      # Don't prefer if user is burned or paralysed
#      mini_score *= 0.5 if @user.status == :BURN || @user.status == :PARALYSIS
#      # Don't prefer if user's Speed stat is lowered
#      sum_stages = @user.stages[:SPEED]
#      mini_score *= 1 + sum_stages * 0.05 if sum_stages < 0
#      # TODO: Prefer if target has previously used a HP-restoring move.
#      # TODO: Don't prefer if some of foes' stats are raised.
#      sum_stages = 0
#      [:ATTACK, :SPECIAL_ATTACK, :SPEED].each do |s|
#        sum_stages += @target.stages[s]
#      end
#      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
#      # TODO: Don't prefer if target has Speed Boost (+Spd at end of each round).
#      mini_score *= 0.6 if @target.hasActiveAbility?(:SPEEDBOOST)
#      # TODO: Don't prefer if the target has previously used a priority move.

    when :DEFENSE
      # Prefer if user has a healing item
      # TODO: Is 1.1x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
#      mini_score *= 1.2 if @user.hasActiveItem?(:LEFTOVERS) ||
#                           (@user.hasActiveItem?(:BLACKSLUDGE) && @user.pbHasType?(:POISON))
      # Prefer if user knows any healing moves
#      # TODO: Is 1.2x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
#      mini_score *= 1.3 if check_for_move(@user) { |m| m.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
#      # TODO: Leech Seed is 1.2x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
#      mini_score *= 1.2 if @user.pbHasMoveFunction?("UserTargetAverageHP")   # Pain Split
#      mini_score *= 1.3 if @user.pbHasMoveFunction?("StartLeechSeedTarget")   # Leech Seed
      # Prefer if user has certain roles
#      # TODO: Is 1.1x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
#      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
      # Don't prefer if user is badly poisoned
      mini_score *= 0.2 if @user.effects[PBEffects::Toxic] > 0
#      # TODO: Prefer if foes have higher Attack than Special Attack, and user
#      #       doesn't have a wall role, user is faster and user has at least 75%
#      #       HP. Don't prefer instead if user is slower (ignore HP).
      # TODO: Don't prefer if previous damage done by foes wouldn't hurt the
      #       user much.

    when :SPEED
      # Don't prefer if user has Speed Boost
#      mini_score *= 0.6 if @user.hasActiveAbility?(:SPEEDBOOST)
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
#      if @user.hp == @user.totalhp &&
#         (@user.hasActiveItem?(:FOCUSSASH) || (!@battle.moldBreaker && @user.hasActiveAbility?(:STURDY)))
#        if !(@battle.pbWeather == :Sandstorm && @user.takesSandstormDamage?) &&
#           !(@battle.pbWeather == :Hail && @user.takesHailDamage?) &&
#           !(@battle.pbWeather == :ShadowSky && @user.takesShadowSkyDamage?)
#          mini_score *= 1.4
#        end
#      end
       # Prefer if user has the Sweeper role
#       mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)
       # TODO: Don't prefer if Trick Room applies or any foe has previously used
       #       Trick Room.
#      mini_score *= 0.2 if @battle.field.effects[PBEffects::TrickRoom] > 0

#      # Prefer if user's Attack/SpAtk stat (whichever is higher) is lowered
#      # TODO: Why?
#      if @user.attack > @user.spatk
#        sum_stages = @user.stages[:ATTACK]
#        mini_score *= 1 - sum_stages * 0.05 if sum_stages < 0
#      else
#        sum_stages = @user.stages[:SPATK]
#        mini_score *= 1 - sum_stages * 0.05 if sum_stages < 0
#      end
#      # Prefer if user has Moxie
#      mini_score *= 1.3 if @user.hasActiveAbility?(:MOXIE)
#      # Don't prefer if user is burned or paralysed
#      mini_score *= 0.2 if @user.status == :PARALYSIS
#      # TODO: Don't prefer if target has raised defenses.
#      sum_stages = 0
#      [:DEFENSE, :SPECIAL_DEFENSE].each { |s| sum_stages += @target.stages[s] }
#      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
#      # TODO: Don't prefer if the target has previously used a priority move.
#      # TODO: Don't prefer if user is already faster than the target and there's
#      #       only 1 unfainted foe (this check is done by Agility/Autotomize
#      #       (both +2 Spd) only in Reborn.)

    when :SPECIAL_ATTACK
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
#      if @user.hp == @user.totalhp &&
#         (@user.hasActiveItem?(:FOCUSSASH) || (!@battle.moldBreaker && @user.hasActiveAbility?(:STURDY)))
#        if !(@battle.pbWeather == :Sandstorm && @user.takesSandstormDamage?) &&
#           !(@battle.pbWeather == :Hail && @user.takesHailDamage?) &&
#           !(@battle.pbWeather == :ShadowSky && @user.takesShadowSkyDamage?)
#          mini_score *= 1.4
#        end
#      end
      # Prefer if user has the Sweeper role
#      mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)

#      # Don't prefer if user's Speed stat is lowered
#      sum_stages = @user.stages[:SPEED]
#      mini_score *= 1 + sum_stages * 0.05 if sum_stages < 0
#      # TODO: Prefer if target has previously used a HP-restoring move.
#      # TODO: Don't prefer if some of foes' stats are raised
#      sum_stages = 0
#      [:ATTACK, :SPECIAL_ATTACK, :SPEED].each do |s|
#        sum_stages += @target.stages[s]
#      end
#      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
#      # TODO: Don't prefer if target has Speed Boost (+Spd at end of each round)
#      mini_score *= 0.6 if @target.hasActiveAbility?(:SPEEDBOOST)
#      # TODO: Don't prefer if the target has previously used a priority move.

    when :SPECIAL_DEFENSE
      # Prefer if user has a healing item
#      mini_score *= 1.2 if @user.hasActiveItem?(:LEFTOVERS) ||
#                           (@user.hasActiveItem?(:BLACKSLUDGE) && @user.pbHasType?(:POISON))
      # Prefer if user knows any healing moves
#      mini_score *= 1.3 if check_for_move(@user) { |m| m.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
#      mini_score *= 1.2 if @user.pbHasMoveFunction?("UserTargetAverageHP")   # Pain Split
#      mini_score *= 1.3 if @user.pbHasMoveFunction?("StartLeechSeedTarget")   # Leech Seed
      # Prefer if user has certain roles
#      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
#      # TODO: Prefer if foes have higher Special Attack than Attack.
      # TODO: Don't prefer if previous damage done by foes wouldn't hurt the
      #       user much.

    when :ACCURACY
      # Prefer if user knows any weaker moves
      mini_score *= 1.1 if check_for_move(@user) { |m| m.damagingMove? && m.basedamage < 95 }
      # Prefer if target has a raised evasion
      sum_stages = @target.stages[:EVASION]
      mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
      # Prefer if target has an item that lowers foes' accuracy
      mini_score *= 1.1 if @target.hasActiveItem?([:BRIGHTPOWDER, :LAXINCENSE])
      # Prefer if target has an ability that lowers foes' accuracy
      # TODO: Tangled Feet while user is confused?
      if (@battle.pbWeather == :Sandstorm && @target.hasActiveAbility?(:SANDVEIL)) ||
         (@battle.pbWeather == :Hail && @target.hasActiveAbility?(:SNOWCLOAK))
        mini_score *= 1.1
      end

    when :EVASION
      # Prefer if user has a healing item
      mini_score *= 1.2 if @user.hasActiveItem?(:LEFTOVERS) ||
                           (@user.hasActiveItem?(:BLACKSLUDGE) && @user.pbHasType?(:POISON))
      # Prefer if user has an item that lowers foes' accuracy
      mini_score *= 1.3 if @user.hasActiveItem?([:BRIGHTPOWDER, :LAXINCENSE])
      # Prefer if user has an ability that lowers foes' accuracy
      # TODO: Tangled Feet while user is confused?
      if (@battle.pbWeather == :Sandstorm && @user.hasActiveAbility?(:SANDVEIL)) ||
         (@battle.pbWeather == :Hail && @user.hasActiveAbility?(:SNOWCLOAK))
        mini_score *= 1.3
      end
      # Prefer if user knows any healing moves
      mini_score *= 1.3 if check_for_move(@user) { |m| move.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
      mini_score *= 1.2 if @user.pbHasMoveFunction?("UserTargetAverageHP")   # Pain Split
      mini_score *= 1.3 if @user.pbHasMoveFunction?("StartLeechSeedTarget")   # Leech Seed
      # Prefer if user has certain roles
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
      # TODO: Don't prefer if user's evasion stat is raised
      # TODO: Don't prefer if target has No Guard.
      mini_score *= 0.2 if @target.hasActiveAbility?(:NOGUARD)
      # TODO: Don't prefer if target has previously used any moves that never miss.

    end


    # TODO: Don't prefer if any foe has previously used a stat stage-clearing
    #       move (Clear Smog/Haze).
    mini_score *= 0.3 if check_for_move(@target) { |m|
      ["ResetTargetStatStages", "ResetAllBattlersStatStages"].include?(m.function)
    }   # Clear Smog, Haze

    # TODO: Prefer if user is faster than the target.
    # TODO: Is 1.3x for RaiseUserAtkDefAcc1 Coil (+Atk, +Def, +acc).
    mini_score *= 1.5 if  @user.faster_than?(@target)
    # TODO: Don't prefer if target is a higher level than the user
    if @target.level > @user.level + 5
      mini_score *= 0.6
      if @target.level > @user.level + 10
        mini_score *= 0.2
      end
    end

    return mini_score
=end
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
  def get_score_for_target_stat_drop(score, target, stat_changes, whole_effect = true)
    whole_effect = false if @move.damagingMove?
    # Decide whether the target raising its stat(s) is a good thing
    desire_mult = -1
    if target.opposes?(@user) ||
       (@move.pbTarget(@user.battler).targets_foe && target.index != @user.index)
      desire_mult = 1
    end
    # Discard status move/don't prefer damaging move if target has Contrary
    # TODO: Maybe this should return get_score_for_target_stat_raise if Contrary
    #       applies and desire_mult < 1.
    if !@battle.moldBreaker && target.has_active_ability?(:CONTRARY) && desire_mult > 1
      return (whole_effect) ? MOVE_USELESS_SCORE : score - 20
    end
    # Don't make score changes if target will faint from EOR damage
    if target.rough_end_of_round_damage > target.hp
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end
    # Don't make score changes if foes have Unaware and target can't make use of
    # its lowered stat stages
    foe_is_aware = false
    each_foe_battler(target.side) do |b, i|
      foe_is_aware = true if !b.has_active_ability?(:UNAWARE)
    end
    if !foe_is_aware
      return (whole_effect) ? MOVE_USELESS_SCORE : score
    end

    # Figure out which stat raises can happen
    real_stat_changes = []
    stat_changes.each_with_index do |stat, idx|
      next if idx.odd?
      next if !stat_drop_worthwhile?(target, stat)
      # Calculate amount that stat will be raised by
      decrement = stat_changes[idx + 1]
      decrement *= 2 if !@battle.moldBreaker && @user.has_active_ability?(:SIMPLE)
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
      score = get_target_stat_drop_score_one(score, target, change[0], change[1], desire_mult)
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
  def stat_drop_worthwhile?(target, stat)
    return false if !target.battler.pbCanLowerStatStage?(stat, @user.battler, @move.move)
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
      if !target.check_for_move { |m| moves_that_prefer_high_speed.include?(m.function) }
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
    dec_mult = (stage_mul[old_stage].to_f * stage_div[new_stage]) / (stage_div[old_stage] * stage_mul[new_stage])
    dec_mult -= 1
    dec_mult *= desire_mult
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no special moves
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_special_moves = target.check_for_move { |m| m.specialMove?(m.type) }
        dec = (has_special_moves) ? 5 : 10
        score += dec * dec_mult
      end

    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end

    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the target has no physical moves
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        has_physical_moves = target.check_for_move { |m| m.physicalMove?(m.type) &&
                                                         m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                                         m.function != "UseTargetAttackInsteadOfUserAttack" }
        dec = (has_physical_moves) ? 5 : 10
        score += dec * dec_mult
      end

    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
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
        next if !b.check_for_move { |m| m.function == "PowerHigherWithUserFasterThanTarget" }
        score += 8 * dec_mult
      end
      # Don't prefer if target has Speed Boost (will be gaining Speed anyway)
      if target.has_active_ability?(:SPEEDBOOST)
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      end

    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end
      # TODO: Prefer if target is poisoned/toxiced/Leech Seeded/cursed.

    when :EVASION
      # Modify score depending on current stat stage
      if old_stage <= -2
        score -= 20 * ((target.opposes?(@user)) ? 1 : desire_mult)
      else
        score += 5 * dec_mult
      end

    end

    # Prefer if target has Stored Power
    if target.check_for_move { |m| m.function == "PowerHigherWithUserPositiveStatStages" }
      score += 5 * decrement * desire_mult
    end
    # Don't prefer if any foe has Punishment
    each_foe_battler(target.side) do |b, i|
      next if !b.check_for_move { |m| m.function == "PowerHigherWithTargetPositiveStatStages" }
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
        if b.check_for_move { |m| m.type == :ELECTRIC && m.damagingMove? }
          ret += (b.opposes?(move_user)) ? -15 : 15
        end
      when :Grassy
        # End of round healing
        ret += (b.opposes?(move_user)) ? -10 : 10
        # Check for Grass moves
        if b.check_for_move { |m| m.type == :GRASS && m.damagingMove? }
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
        if b.check_for_move { |m| m.type == :DRAGON && m.damagingMove? }
          ret += (b.opposes?(move_user)) ? 15 : -15
        end
      when :Psychic
        # Check for priority moves
        if b.check_for_move { |m| m.priority > 0 && m.pbTarget&.can_target_one_foe? }
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for Psychic moves
        if b.check_for_move { |m| m.type == :PSYCHIC && m.damagingMove? }
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
        if b.check_for_move { |m| ["EffectDependsOnEnvironment",
                                   "SetUserTypesBasedOnEnvironment",
                                   "TypeAndPowerDependOnTerrain",
                                   "UseMoveDependingOnEnvironment"].include?(m.function) }
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if good_moves && b.check_for_move { |m| good_moves.include?(m.function) }
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if bad_moves && b.check_for_move { |m| bad_moves.include?(m.function) }
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      end
    end
    return ret
  end

  #=============================================================================
  # Returns a value indicating how beneficial the given item will be to the
  # given battler if it is holding it.
  # Return values are typically -2, -1, 0, 1 or 2. 0 is indifferent, positive
  # values mean the battler benefits, negative values mean the battler suffers.
  #=============================================================================
  def battler_wants_item?(battler, item = :NONE)
    item == :NONE if item.nil?
    # TODO: Add more items.
    preferred_items = [
      :CHOICESCARF,
      :LEFTOVERS
    ]
    preferred_items.push(:BLACKSLUDGE) if battler.has_type?(:POISON)
    preferred_items.push(:IRONBALL) if battler.check_for_move { |m| m.function = "ThrowUserItemAtTarget" }
    preferred_items.push(:CHOICEBAND) if battler.check_for_move { |m| m.physicalMove?(m.type) }
    preferred_items.push(:CHOICESPECS) if battler.check_for_move { |m| m.specialMove?(m.type) }
    unpreferred_items = [
      :BLACKSLUDGE,
      :FLAMEORB,
      :IRONBALL,
      :LAGGINGTAIL,
      :STICKYBARB,
      :TOXICORB
    ]
    ret = 0
    ret = 2 if preferred_items.include?(item)
    ret = -2 if unpreferred_items.include?(item)
    # Don't prefer if the battler knows Acrobatics
    if battler.check_for_move { |m| m.function == "DoublePowerIfUserHasNoItem" }
      ret += (item == :NONE) ? 1 : -1
    end
    return ret
  end

  #=============================================================================
  # Returns a value indicating how beneficial the given ability will be to the
  # given battler if it has it.
  # Return values are typically between -10 and +10. 0 is indifferent, positive
  # values mean the battler benefits, negative values mean the battler suffers.
  #=============================================================================
  # These values are taken from the Complete-Fire-Red-Upgrade decomp here:
  # https://github.com/Skeli789/Complete-Fire-Red-Upgrade/blob/f7f35becbd111c7e936b126f6328fc52d9af68c8/src/ability_battle_effects.c#L41
  BASE_ABILITY_RATINGS = {
    :ADAPTABILITY       => 8,
    :AERILATE           => 8,
    :AFTERMATH          => 5,
    :AIRLOCK            => 5,
    :ANALYTIC           => 5,
    :ANGERPOINT         => 4,
    :ANTICIPATION       => 2,
    :ARENATRAP          => 9,
    :AROMAVEIL          => 3,
#    :ASONECHILLINGNEIGH => 0,
#    :ASONEGRIMNEIGH     => 0,
    :AURABREAK          => 3,
    :BADDREAMS          => 4,
#    :BALLFETCH          => 0,
#    :BATTERY            => 0,
    :BATTLEARMOR        => 2,
    :BATTLEBOND         => 6,
    :BEASTBOOST         => 7,
    :BERSERK            => 5,
    :BIGPECKS           => 1,
    :BLAZE              => 5,
    :BULLETPROOF        => 7,
    :CHEEKPOUCH         => 4,
#    :CHILLINGNEIGH      => 0,
    :CHLOROPHYLL        => 6,
    :CLEARBODY          => 4,
    :CLOUDNINE          => 5,
    :COLORCHANGE        => 2,
    :COMATOSE           => 6,
    :COMPETITIVE        => 5,
    :COMPOUNDEYES       => 7,
    :CONTRARY           => 8,
    :CORROSION          => 5,
    :COTTONDOWN         => 3,
#    :CURIOUSMEDICINE    => 0,
    :CURSEDBODY         => 4,
    :CUTECHARM          => 2,
    :DAMP               => 2,
    :DANCER             => 5,
    :DARKAURA           => 6,
    :DAUNTLESSSHIELD    => 3,
    :DAZZLING           => 5,
    :DEFEATIST          => -1,
    :DEFIANT            => 5,
    :DELTASTREAM        => 10,
    :DESOLATELAND       => 10,
    :DISGUISE           => 8,
    :DOWNLOAD           => 7,
    :DRAGONSMAW         => 8,
    :DRIZZLE            => 9,
    :DROUGHT            => 9,
    :DRYSKIN            => 6,
    :EARLYBIRD          => 4,
    :EFFECTSPORE        => 4,
    :ELECTRICSURGE      => 8,
    :EMERGENCYEXIT      => 3,
    :FAIRYAURA          => 6,
    :FILTER             => 6,
    :FLAMEBODY          => 4,
    :FLAREBOOST         => 5,
    :FLASHFIRE          => 6,
    :FLOWERGIFT         => 4,
#    :FLOWERVEIL         => 0,
    :FLUFFY             => 5,
    :FORECAST           => 6,
    :FOREWARN           => 2,
#    :FRIENDGUARD        => 0,
    :FRISK              => 3,
    :FULLMETALBODY      => 4,
    :FURCOAT            => 7,
    :GALEWINGS          => 6,
    :GALVANIZE          => 8,
    :GLUTTONY           => 3,
    :GOOEY              => 5,
    :GORILLATACTICS     => 4,
    :GRASSPELT          => 2,
    :GRASSYSURGE        => 8,
#    :GRIMNEIGH          => 0,
    :GULPMISSLE         => 3,
    :GUTS               => 6,
    :HARVEST            => 5,
#    :HEALER             => 0,
    :HEATPROOF          => 5,
    :HEAVYMETAL         => -1,
#    :HONEYGATHER        => 0,
    :HUGEPOWER          => 10,
    :HUNGERSWITCH       => 2,
    :HUSTLE             => 7,
    :HYDRATION          => 4,
    :HYPERCUTTER        => 3,
    :ICEBODY            => 3,
    :ICEFACE            => 4,
    :ICESCALES          => 7,
#    :ILLUMINATE         => 0,
    :ILLUSION           => 8,
    :IMMUNITY           => 4,
    :IMPOSTER           => 9,
    :INFILTRATOR        => 6,
    :INNARDSOUT         => 5,
    :INNERFOCUS         => 2,
    :INSOMNIA           => 4,
    :INTIMIDATE         => 7,
    :INTREPIDSWORD      => 3,
    :IRONBARBS          => 6,
    :IRONFIST           => 6,
    :JUSTIFIED          => 4,
    :KEENEYE            => 1,
    :KLUTZ              => -1,
    :LEAFGUARD          => 2,
    :LEVITATE           => 7,
    :LIBERO             => 8,
    :LIGHTMETAL         => 2,
    :LIGHTNINGROD       => 7,
    :LIMBER             => 3,
    :LIQUIDOOZE         => 3,
    :LIQUIDVOICE        => 5,
    :LONGREACH          => 3,
    :MAGICBOUNCE        => 9,
    :MAGICGUARD         => 9,
    :MAGICIAN           => 3,
    :MAGMAARMOR         => 1,
    :MAGNETPULL         => 9,
    :MARVELSCALE        => 5,
    :MEGALAUNCHER       => 7,
    :MERCILESS          => 4,
    :MIMICRY            => 2,
#    :MINUS              => 0,
    :MIRRORARMOR        => 6,
    :MISTYSURGE         => 8,
    :MOLDBREAKER        => 7,
    :MOODY              => 10,
    :MOTORDRIVE         => 6,
    :MOXIE              => 7,
    :MULTISCALE         => 8,
    :MULTITYPE          => 8,
    :MUMMY              => 5,
    :NATURALCURE        => 7,
    :NEUROFORCE         => 6,
    :NEUTRALIZINGGAS    => 5,
    :NOGUARD            => 8,
    :NORMALIZE          => -1,
    :OBLIVIOUS          => 2,
    :OVERCOAT           => 5,
    :OVERGROW           => 5,
    :OWNTEMPO           => 3,
    :PARENTALBOND       => 10,
    :PASTELVEIL         => 4,
    :PERISHBODY         => -1,
    :PICKPOCKET         => 3,
    :PICKUP             => 1,
    :PIXILATE           => 8,
#    :PLUS               => 0,
    :POISONHEAL         => 8,
    :POISONPOINT        => 4,
    :POISONTOUCH        => 4,
    :POWERCONSTRUCT     => 10,
#    :POWEROFALCHEMY     => 0,
    :POWERSPOT          => 2,
    :PRANKSTER          => 8,
    :PRESSURE           => 5,
    :PRIMORDIALSEA      => 10,
    :PRISMARMOR         => 6,
    :PROPELLORTAIL      => 2,
    :PROTEAN            => 8,
    :PSYCHICSURGE       => 8,
    :PUNKROCK           => 2,
    :PUREPOWER          => 10,
    :QUEENLYMAJESTY     => 6,
#    :QUICKDRAW          => 0,
    :QUICKFEET          => 5,
    :RAINDISH           => 3,
    :RATTLED            => 3,
#    :RECEIVER           => 0,
    :RECKLESS           => 6,
    :REFRIGERATE        => 8,
    :REGENERATOR        => 8,
    :RIPEN              => 4,
    :RIVALRY            => 1,
    :RKSSYSTEM          => 8,
    :ROCKHEAD           => 5,
    :ROUGHSKIN          => 6,
#    :RUNAWAY            => 0,
    :SANDFORCE          => 4,
    :SANDRUSH           => 6,
    :SANDSPIT           => 5,
    :SANDSTREAM         => 9,
    :SANDVEIL           => 3,
    :SAPSIPPER          => 7,
    :SCHOOLING          => 6,
    :SCRAPPY            => 6,
    :SCREENCLEANER      => 3,
    :SERENEGRACE        => 8,
    :SHADOWSHIELD       => 8,
    :SHADOWTAG          => 10,
    :SHEDSKIN           => 7,
    :SHEERFORCE         => 8,
    :SHELLARMOR         => 2,
    :SHIELDDUST         => 5,
    :SHIELDSDOWN        => 6,
    :SIMPLE             => 8,
    :SKILLLINK          => 7,
    :SLOWSTART          => -2,
    :SLUSHRUSH          => 5,
    :SNIPER             => 3,
    :SNOWCLOAK          => 3,
    :SNOWWARNING        => 8,
    :SOLARPOWER         => 3,
    :SOLIDROCK          => 6,
    :SOULHEART          => 7,
    :SOUNDPROOF         => 4,
    :SPEEDBOOST         => 9,
    :STAKEOUT           => 6,
    :STALL              => -1,
    :STALWART           => 2,
    :STAMINA            => 6,
    :STANCECHANGE       => 10,
    :STATIC             => 4,
    :STEADFAST          => 2,
    :STEAMENGINE        => 3,
    :STEELWORKER        => 6,
    :STEELYSPIRIT       => 2,
    :STENCH             => 1,
    :STICKYHOLD         => 3,
    :STORMDRAIN         => 7,
    :STRONGJAW          => 6,
    :STURDY             => 6,
    :SUCTIONCUPS        => 2,
    :SUPERLUCK          => 3,
    :SURGESURFER        => 4,
    :SWARM              => 5,
    :SWEETVEIL          => 4,
    :SWIFTSWIM          => 6,
#    :SYMBIOSIS          => 0,
    :SYNCHRONIZE        => 4,
    :TANGLEDFEET        => 2,
    :TANGLINGHAIR       => 5,
    :TECHNICIAN         => 8,
#    :TELEPATHY          => 0,
    :TERAVOLT           => 7,
    :THICKFAT           => 7,
    :TINTEDLENS         => 7,
    :TORRENT            => 5,
    :TOUGHCLAWS         => 7,
    :TOXICBOOST         => 6,
    :TRACE              => 6,
    :TRANSISTOR         => 8,
    :TRIAGE             => 7,
    :TRUANT             => -2,
    :TURBOBLAZE         => 7,
    :UNAWARE            => 6,
    :UNBURDEN           => 7,
    :UNNERVE            => 3,
#    :UNSEENFIST         => 0,
    :VICTORYSTAR        => 6,
    :VITALSPIRIT        => 4,
    :VOLTABSORB         => 7,
    :WANDERINGSPIRIT    => 2,
    :WATERABSORB        => 7,
    :WATERBUBBLE        => 8,
    :WATERCOMPACTION    => 4,
    :WATERVEIL          => 4,
    :WEAKARMOR          => 2,
    :WHITESMOKE         => 4,
    :WIMPOUT            => 3,
    :WONDERGUARD        => 10,
    :WONDERSKIN         => 4,
    :ZENMODE            => -1
  }

  # TODO: This method assumes the ability isn't being negated. Should it return
  #       0 if it is? The calculations that call this method separately check
  #       for it being negated, because they need to do something special in
  #       that case, so I think it's okay for this method to ignore negation.
  def battler_wants_ability?(battler, ability = :NONE)
    ability = ability.id if !ability.is_a?(Symbol) && ability.respond_to?("id")
    # TODO: Ideally replace the above list of ratings with context-sensitive
    #       calculations. Should they all go in this method, or should there be
    #       more handlers for each ability?
    ret = BASE_ABILITY_RATINGS[ability] || 0
    return ret
  end
end
