class Battle::AI
  #=============================================================================
  # Main method for calculating the score for moves that raise the user's stat(s).
  #=============================================================================
  def get_score_for_user_stat_raise(score)
    # Discard status move/don't prefer damaging move if user has Contrary
    if !@battle.moldBreaker && @user.has_active_ability?(:CONTRARY)
      return (@move.statusMove?) ? score - 40 : score - 20
    end
    # Don't make score changes if foes have Unaware and user can't make use of
    # extra stat stages
    if !@user.check_for_move { |move| move.function == "PowerHigherWithUserPositiveStatStages" }
      foe_is_aware = false
      each_foe_battler(@user.side) do |b, i|
        foe_is_aware = true if !b.has_active_ability?(:UNAWARE)
      end
      return score if !foe_is_aware
    end

    # Figure out which stat raises can happen
    stat_changes = []
    @move.move.statUp.each_with_index do |stat, idx|
      next if idx.odd?
      next if !stat_raise_worthwhile?(stat)
      # Calculate amount that stat will be raised by
      increment = @move.move.statUp[idx + 1]
      if @move.function == "RaiseUserAtkSpAtk1Or2InSun"
        increment = 1
        increment = 2 if [:Sun, :HarshSun].include?(@user.battler.effectiveWeather)
      end
      increment *= 2 if !@battle.moldBreaker && @user.has_active_ability?(:SIMPLE)
      increment = [increment, 6 - @user.stages[stat]].min   # The actual stages gained
      # Count this as a valid stat raise
      stat_changes.push([stat, increment]) if increment > 0
    end
    # Discard move if it can't raise any stats
    if stat_changes.length == 0
      # TODO: Have a parameter that decides whether to reduce the score here
      #       (for moves where this is just part of the effect).
      return (@move.statusMove?) ? score - 40 : score
    end

    # Make score changes based on the general concept of raising stats at all
    score = get_user_stat_raise_score_generic(score, stat_changes)

    # Make score changes based on the specific changes to each stat that will be
    # raised
    stat_changes.each do |change|
      score = get_user_stat_raise_score_one(score, change[0], change[1])
    end

    return score
  end

  #=============================================================================
  # Returns whether the user raising the given stat will have any impact.
  # TODO: Make sure the move's actual damage category is taken into account,
  #       i.e. CategoryDependsOnHigherDamagePoisonTarget and
  #       CategoryDependsOnHigherDamageIgnoreTargetAbility.
  #=============================================================================
  def stat_raise_worthwhile?(stat)
    return false if !@user.battler.pbCanRaiseStatStage?(stat, @user.battler, @move)
    # Check if user won't benefit from the stat being raised
    # TODO: Exception if user knows Baton Pass/Stored Power?
    case stat
    when :ATTACK
      return false if !@user.check_for_move { |m| m.physicalMove?(move.type) &&
                                                  m.function != "UseUserBaseDefenseInsteadOfUserBaseAttack" &&
                                                  m.function != "UseTargetAttackInsteadOfUserAttack" }
    when :DEFENSE
      each_foe_battler(@user.side) do |b, i|
        next if !b.check_for_move { |m| m.physicalMove?(m.type) ||
                                        m.function == "UseTargetDefenseInsteadOfTargetSpDef" }
        return true
      end
      return false
    when :SPECIAL_ATTACK
      return false if !@user.check_for_move { |m| m.specialMove?(m.type) }
    when :SPECIAL_DEFENSE
      each_foe_battler(@user.side) do |b, i|
        next if !b.check_for_move { |m| m.specialMove?(m.type) &&
                                        m.function != "UseTargetDefenseInsteadOfTargetSpDef" }
        return true
      end
      return false
    when :SPEED
      moves_that_prefer_high_speed = [
        "PowerHigherWithUserFasterThanTarget",
        "PowerHigherWithUserPositiveStatStages"
      ]
      if !@user.check_for_move { |m| moves_that_prefer_high_speed.include?(m.function) }
        each_foe_battler(@user.side) do |b, i|
          return true if b.faster_than?(@user)
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
  # TODO: These function codes need to have an attr_reader :statUp and for them
  #       to be set when the move is initialised.
  #       LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2 Shell Smash
  #       RaiseTargetRandomStat2 Acupressure
  #       RaisePlusMinusUserAndAlliesDefSpDef1 Magnetic Flux
  #       RaisePlusMinusUserAndAlliesAtkSpAtk1 Gear Up
  def get_user_stat_raise_score_generic(score, stat_changes)
    total_increment = stat_changes.sum { |change| change[1] }
    # TODO: Just return if foe is predicted to use a phazing move (one that
    #       switches the user out).
    # TODO: Don't prefer if foe is faster than user and is predicted to deal
    #       lethal damage.
    # TODO: Don't prefer if foe is slower than user but is predicted to be able
    #       to 2HKO user.
    # TODO: Prefer if foe is semi-invulnerable and user is faster (can't hit
    #       the foe anyway).

    # Prefer if move is a status move and it's the user's first/second turn
    if @user.turnCount < 2 && @move.statusMove?
      score += total_increment * 4
    end

    # Prefer if user is at high HP, don't prefer if user is at low HP
    if @user.hp >= @user.totalhp * 0.7
      score += 4 * total_increment
    else
      score += total_increment * ((100 * @user.hp / @user.totalhp) - 50) / 4   # +5 to -12 per stage
    end

    # Don't prefer if user is about to faint due to EOR damage
    score -= 30 if @user.rough_end_of_round_damage > @user.hp

    # TODO: Look at abilities that trigger upon stat raise. There are none.

    return score



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

    # Prefer if user has most of its HP
    if @user.hp >= @user.totalhp * 3 / 4
      mini_score *= (sweeping_stat) ? 1.2 : 1.1
    end
    # TODO: Prefer if user's moves won't do much damage.
    # Prefer if user has something that will limit damage taken
    mini_score *= 1.3 if @user.effects[PBEffects::Substitute] > 0 ||
                         (@user.form == 0 && @user.ability_id == :DISGUISE)

    # Don't prefer if user doesn't have much HP left
    mini_score *= 0.3 if @user.hp < @user.totalhp / 3
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
  end

  #=============================================================================
  # Make score changes based on the raising of a specific stat.
  #=============================================================================
  def get_user_stat_raise_score_one(score, stat, increment)
    # Figure out how much the stat will actually change by
    stage_mul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stage_div = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    if [:ACCURACY, :EVASION].include?(stat)
      stage_mul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
      stage_div = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    end
    old_stage = @user.stages[stat]
    new_stage = old_stage + increment
    inc_mult = (stage_mul[new_stage].to_f * stage_div[old_stage]) / (stage_div[new_stage] * stage_mul[old_stage])
    inc_mult -= 1
    # Stat-based score changes
    case stat
    when :ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the user has no special moves
      if old_stage >= 3
        score -= 20
      else
        has_special_moves = @user.check_for_move { |m| m.specialMove?(m.type) }
        inc = (has_special_moves) ? 5 : 10
        score += inc * (3 - old_stage) * inc_mult
        score += 5 * inc_mult if @user.hp == @user.totalhp
      end

    when :DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 3
        score -= 20
      else
        score += 5 * (3 - old_stage) * inc_mult
        score += 5 * inc_mult if @user.hp == @user.totalhp
      end

    when :SPECIAL_ATTACK
      # Modify score depending on current stat stage
      # More strongly prefer if the user has no physical moves
      if old_stage >= 3
        score -= 20
      else
        has_physical_moves = @user.check_for_move { |m| m.physicalMove?(m.type) &&
                                                        m.function != "UseUserBaseDefenseInsteadOfUserBaseAttack" &&
                                                        m.function != "UseTargetAttackInsteadOfUserAttack" }
        inc = (has_physical_moves) ? 5 : 10
        score += inc * (3 - old_stage) * inc_mult
        score += 5 * inc_mult if @user.hp == @user.totalhp
      end

    when :SPECIAL_DEFENSE
      # Modify score depending on current stat stage
      if old_stage >= 3
        score -= 20
      else
        score += 5 * (3 - old_stage) * inc_mult
        score += 5 * inc_mult if @user.hp == @user.totalhp
      end

    when :SPEED
      # Prefer if user is slower than a foe
      each_foe_battler(@user.side) do |b, i|
        next if @user.faster_than?(b)
        score += 15 * inc_mult
        break
      end
      # Don't prefer if any foe has Gyro Ball
      each_foe_battler(@user.side) do |b, i|
        next if !b.check_for_move { |m| m.function == "PowerHigherWithTargetFasterThanUser" }
        score -= 8 * inc_mult
      end
      # Don't prefer if user has Speed Boost (will be gaining Speed anyway)
      score -= 20 if @user.has_active_ability?(:SPEEDBOOST)

    when :ACCURACY
      # Modify score depending on current stat stage
      if old_stage >= 3
        score -= 20
      else
        min_accuracy = 100
        @user.battler.moves.each do |m|
          next if m.accuracy == 0 || m.is_a?(Battle::Move::OHKO)
          min_accuracy = m.accuracy if m.accuracy < min_accuracy
        end
        min_accuracy *= stage_mul[old_stage] / stage_div[old_stage]
        if min_accuracy < 90
          score += 5 * (3 - old_stage) * inc_mult
          score += 5 * inc_mult if @user.hp == @user.totalhp
        end
      end

    when :EVASION
      # Prefer if a foe will (probably) take damage at the end of the round
      # TODO: Should this take into account EOR healing, one-off damage and
      #       damage-causing effects that wear off naturally (like Sea of Fire)?
      # TODO: Emerald AI also prefers if user is rooted via Ingrain.
      each_foe_battler(@user.side) do |b, i|
        eor_damage = b.rough_end_of_round_damage
        score += 60 * eor_damage / b.totalhp if eor_damage > 0
      end
      # Modify score depending on current stat stage
      if old_stage >= 3
        score -= 20
      else
        score += 5 * (3 - old_stage) * inc_mult
        score += 5 * inc_mult if @user.hp == @user.totalhp
      end

    end

    # Check impact on moves of gaining stat stages
    pos_change = [old_stage + increment, increment].min
    if pos_change > 0
      # Prefer if user has Stored Power
      if @user.check_for_move { |m| m.function == "PowerHigherWithUserPositiveStatStages" }
        score += 5 * pos_change
      end
      # Don't prefer if any foe has Punishment
      each_foe_battler(@user.side) do |b, i|
        next if !b.check_for_move { |m| m.function == "PowerHigherWithTargetPositiveStatStages" }
        score -= 5 * pos_change
      end
    end

    return score



    mini_score = 1.0
    case stat
    when :ATTACK
      # TODO: Don't prefer if target has previously used a move that benefits
      #       from user's Attack being boosted.
#      mini_score *= 0.3 if @target.check_for_move { |m| m.function == "UseTargetAttackInsteadOfUserAttack" }   # Foul Play
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
end
