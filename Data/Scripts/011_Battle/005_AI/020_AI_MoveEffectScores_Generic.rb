class Battle::AI
  #=============================================================================
  # Apply additional effect chance to a move's score
  # TODO: Apply all the additional effect chance modifiers.
  #=============================================================================
  def apply_effect_chance_to_score(score)
    if @move.damagingMove?
      # TODO: Doesn't return the correct value for "014" (Chatter).
      effect_chance = @move.addlEffect
      if effect_chance > 0
        effect_chance *= 2 if @user.hasActiveAbility?(:SERENEGRACE) ||
                              @user.pbOwnSide.effects[PBEffects::Rainbow] > 0
        effect_multiplier = [effect_chance.to_f, 100].min / 100
        score = ((score - 1) * effect_multiplier) + 1
      end
    end
    return score
  end

  #=============================================================================
  #
  #=============================================================================
  # TODO: These function codes need to have an attr_reader :statUp and for them
  #       to be set when the move is initialised.
  #       035 Shell Smash
  #       037 Acupressure
  #       137 Magnetic Flux
  #       15C Gear Up
  def calc_user_stat_raise_mini_score
    mini_score = 1.0
    # Determine whether the move boosts Attack, Special Attack or Speed (Bulk Up
    # is sometimes not considered a sweeping move)
    sweeping_stat = false
    offensive_stat = false
    @move.stat_up.each_with_index do |stat, idx|
      next if idx.odd?
      next if ![:ATTACK, :SPATK, :SPEED].include?(stat)
      sweeping_stat = true
      next if @move.function == "024"   # Bulk Up (+Atk +Def)
      offensive_stat = true
      break
    end

    # Prefer if user has most of its HP
    if @user.hp >= @user.totalhp * 3 / 4
      mini_score *= (sweeping_stat) ? 1.2 : 1.1
    end
    # Prefer if user hasn't been in battle for long
    if @user.turnCount < 2
      mini_score *= (sweeping_stat) ? 1.2 : 1.1
    end
    # Prefer if user has the ability Simple
    mini_score *= 2 if @user.hasActiveAbility?(:SIMPLE)
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
    if @target.status != PBStatuses::NONE
      mini_score *= (sweeping_stat) ? 1.2 : 1.1
      case @target.status
      when PBStatuses::SLEEP, PBStatuses::FROZEN
        mini_score *= 1.3
      when PBStatuses::BURN
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
      if sweeping_stat || @move.function == "02A"   # +Def +SpDef
        mini_score *= 1.5
      else
        mini_score *= 1.3
      end
    end
    # TODO: Don't prefer if target has previously used a move that would force
    #       the user to switch (or Yawn/Perish Song which encourage it). Prefer
    #       instead if the move raises evasion. Note this comes after the
    #       dissociation of Bulk Up from sweeping_stat.

    if skill_check(AILevel.medium)
      # TODO: Prefer if the maximum damage the target has dealt wouldn't hurt
      #       the user much.
    end
    # Don't prefer if foe's side is able to use a boosted Retaliate
    # TODO: I think this is what Reborn means. Reborn doesn't check for the
    #       existence of the move Retaliate, just whether it can be boosted.
    if @user.pbOpposingSide.effects[PBEffects::LastRoundFainted] == @battle.turnCount - 1
      mini_score *= 0.3
    end

    # Don't prefer if it's not a single battle
    if !@battle.singleBattle?
      mini_score *= (offensive_stat) ? 0.25 : 0.5
    end

    return mini_score
  end

  #=============================================================================
  #
  #=============================================================================
  # TODO: This method doesn't take the increment into account but should.
  def calc_user_stat_raise_one(stat, increment)
    mini_score = 1.0

    # Ignore if user won't benefit from the stat being raised
    # TODO: Exception if user knows Baton Pass? Exception if user knows Power Trip?
    case stat
    when :ATTACK
      has_physical_move = false
      @user.eachMove do |m|
        next if !m.physicalMove?(m.type) || m.function == "121"   # Foul Play
        has_physical_move = true
        break
      end
      return mini_score if !has_physical_move
    when :SPECIAL_ATTACK
      has_special_move = false
      @user.eachMove do |m|
        next if !m.specialMove?(m.type)
        has_special_move = true
        break
      end
      return mini_score if !has_special_move
    end

    case stat
    when :ATTACK
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
      if @user.hp == @user.totalhp &&
         (@user.hasActiveItem?(:FOCUSSASH) || @user.hasActiveAbility?(:STURDY))
        if !(@battle.pbWeather == PBWeather::Sandstorm && @user.takesSandstormDamage?) &&
           !(@battle.pbWeather == PBWeather::Hail && @user.takesHailDamage?) &&
           !(@battle.pbWeather == PBWeather::ShadowSky && @user.takesShadowSkyDamage?)
          mini_score *= 1.4
        end
      end
      # Prefer if user has the Sweeper role
      # TODO: Is 1.1x for 025 Coil (+Atk, +Def, +acc).
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)
      # Don't prefer if user is burned or paralysed
      mini_score *= 0.5 if @user.status == PBStatuses::BURN || @user.status == PBStatuses::PARALYSIS
      # Don't prefer if user's Speed stat is lowered
      sum_stages = @user.stages[:SPEED]
      mini_score *= 1 + sum_stages * 0.05 if sum_stages < 0

      # TODO: Prefer if target has previously used a HP-restoring move.
      # TODO: Don't prefer if some of foes' stats are raised
      sum_stages = 0
      [:ATTACK, :SPECIAL_ATTACK, :SPEED].each do |s|
        sum_stages += @target.stages[s]
      end
      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
      # TODO: Don't prefer if target has Speed Boost (+Spd at end of each round).
      mini_score *= 0.6 if @target.hasActiveAbility?(:SPEEDBOOST)
      # TODO: Don't prefer if target has previously used a move that benefits
      #       from user's Attack being boosted.
      mini_score *= 0.3 if check_for_move(@target) { |move| move.function == "121" }   # Foul Play
      # TODO: Don't prefer if the target has previously used a priority move.

    when :DEFENSE
      # Prefer if user has a healing item
      # TODO: Is 1.1x for 025 Coil (+Atk, +Def, +acc).
      mini_score *= 1.2 if @user.hasActiveItem?(:LEFTOVERS) ||
                           (@user.hasActiveItem?(:BLACKSLUDGE) && @user.pbHasType?(:POISON))
      # Prefer if user knows any healing moves
      # TODO: Is 1.2x for 025 Coil (+Atk, +Def, +acc).
      mini_score *= 1.3 if check_for_move(@user) { |move| move.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
      # TODO: Leech Seed is 1.2x for 025 Coil (+Atk, +Def, +acc).
      mini_score *= 1.2 if @user.pbHasMoveFunction?("05A")   # Pain Split
      mini_score *= 1.3 if @user.pbHasMoveFunction?("0DC")   # Leech Seed
      # Prefer if user has certain roles
      # TODO: Is 1.1x for 025 Coil (+Atk, +Def, +acc).
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
      # Don't prefer if user is badly poisoned
      mini_score *= 0.2 if @user.effects[PBEffects::Toxic] > 0
      # Don't prefer if user's Defense stat is raised
      sum_stages = @user.stages[:DEFENSE]
      mini_score *= 1 - sum_stages * 0.15 if sum_stages > 0

      # TODO: Prefer if foes have higher Attack than Special Attack, and user
      #       doesn't have a wall role, user is faster and user has at least 75%
      #       HP. Don't prefer instead if user is slower (ignore HP).

      # TODO: Don't prefer if previous damage done by foes wouldn't hurt the
      #       user much.

    when :SPEED
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
      if @user.hp == @user.totalhp &&
         (@user.hasActiveItem?(:FOCUSSASH) || @user.hasActiveAbility?(:STURDY))
        if !(@battle.pbWeather == PBWeather::Sandstorm && @user.takesSandstormDamage?) &&
           !(@battle.pbWeather == PBWeather::Hail && @user.takesHailDamage?) &&
           !(@battle.pbWeather == PBWeather::ShadowSky && @user.takesShadowSkyDamage?)
          mini_score *= 1.4
        end
      end
      # Prefer if user's Attack/SpAtk stat (whichever is higher) is lowered
      # TODO: Why?
      if @user.attack > @user.spatk
        sum_stages = @user.stages[:ATTACK]
        mini_score *= 1 - sum_stages * 0.05 if sum_stages < 0
      else
        sum_stages = @user.stages[:SPATK]
        mini_score *= 1 - sum_stages * 0.05 if sum_stages < 0
      end
      # Prefer if user has lowered Speed
      # TODO: Is a flat 1.3x for 026 Dragon Dance (+Atk, +Spd).
      sum_stages = @user.stages[:SPEED]
      mini_score *= 1 - sum_stages * 0.05 if sum_stages < 0
      # Prefer if user has Moxie
      mini_score *= 1.3 if @user.hasActiveAbility?(:MOXIE)
      # Prefer if user has the Sweeper role
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)
      # Don't prefer if user is burned or paralysed
      mini_score *= 0.2 if @user.status == PBStatuses::PARALYSIS
      # Don't prefer if user has Speed Boost
      mini_score *= 0.6 if @user.hasActiveAbility?(:SPEEDBOOST)

      # TODO: Don't prefer if target has raised defenses.
      sum_stages = 0
      [:DEFENSE, :SPECIAL_DEFENSE].each { |s| sum_stages += @target.stages[s] }
      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
      # TODO: Don't prefer if the target has previously used a priority move.
      # TODO: Don't prefer if Trick Room applies or any foe has previously used
      #       Trick Room.
      mini_score *= 0.2 if @battle.field.effects[PBEffects::TrickRoom] > 0

      # TODO: Don't prefer if user is already faster than the target. Exception
      #       for moves that benefit from a raised user's Speed?
      # TODO: Don't prefer if user is already faster than the target and there's
      #       only 1 unfainted foe (this check is done by Agility/Autotomize
      #       (both +2 Spd) only in Reborn.)

    when :SPECIAL_ATTACK
      # Prefer if user can definitely survive a hit no matter how powerful, and
      # it won't be hurt by weather
      if @user.hp == @user.totalhp &&
         (@user.hasActiveItem?(:FOCUSSASH) || @user.hasActiveAbility?(:STURDY))
        if !(@battle.pbWeather == PBWeather::Sandstorm && @user.takesSandstormDamage?) &&
           !(@battle.pbWeather == PBWeather::Hail && @user.takesHailDamage?) &&
           !(@battle.pbWeather == PBWeather::ShadowSky && @user.takesShadowSkyDamage?)
          mini_score *= 1.4
        end
      end
      # Prefer if user has the Sweeper role
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::SWEEPER)
      # Don't prefer if user's Speed stat is lowered
      sum_stages = @user.stages[:SPEED]
      mini_score *= 1 + sum_stages * 0.05 if sum_stages < 0

      # TODO: Prefer if target has previously used a HP-restoring move.
      # TODO: Don't prefer if some of foes' stats are raised
      sum_stages = 0
      [:ATTACK, :SPECIAL_ATTACK, :SPEED].each do |s|
        sum_stages += @target.stages[s]
      end
      mini_score *= 1 - sum_stages * 0.05 if sum_stages > 0
      # TODO: Don't prefer if target has Speed Boost (+Spd at end of each round)
      mini_score *= 0.6 if @target.hasActiveAbility?(:SPEEDBOOST)
      # TODO: Don't prefer if the target has previously used a priority move.

    when :SPECIAL_DEFENSE
      # Prefer if user has a healing item
      mini_score *= 1.2 if @user.hasActiveItem?(:LEFTOVERS) ||
                           (@user.hasActiveItem?(:BLACKSLUDGE) && @user.pbHasType?(:POISON))
      # Prefer if user knows any healing moves
      mini_score *= 1.3 if check_for_move(@user) { |move| move.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
      mini_score *= 1.2 if @user.pbHasMoveFunction?("05A")   # Pain Split
      mini_score *= 1.3 if @user.pbHasMoveFunction?("0DC")   # Leech Seed
      # Prefer if user has certain roles
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
      # Don't prefer if user's Defense stat is raised
      sum_stages = @user.stages[:SPECIAL_DEFENSE]
      mini_score *= 1 - sum_stages * 0.15 if sum_stages > 0

      # TODO: Prefer if foes have higher Special Attack than Attack.

      # TODO: Don't prefer if previous damage done by foes wouldn't hurt the
      #       user much.

    when :ACCURACY

      # Prefer if user knows any weaker moves
      mini_score *= 1.1 if check_for_move(@user) { |move| move.damagingMove? && move.basedamage < 95 }

      # Prefer if target has a raised evasion
      sum_stages = @target.stages[:EVASION]
      mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
      # Prefer if target has an item that lowers foes' accuracy
      mini_score *= 1.1 if @target.hasActiveItem?([:BRIGHTPOWDER, :LAXINCENSE])
      # Prefer if target has an ability that lowers foes' accuracy
      # TODO: Tangled Feet while user is confused?
      if (@battle.pbWeather == PBWeather::Sandstorm && @target.hasActiveAbility?(:SANDVEIL)) ||
         (@battle.pbWeather == PBWeather::Hail && @target.hasActiveAbility?(:SNOWCLOAK))
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
      if (@battle.pbWeather == PBWeather::Sandstorm && @user.hasActiveAbility?(:SANDVEIL)) ||
         (@battle.pbWeather == PBWeather::Hail && @user.hasActiveAbility?(:SNOWCLOAK))
        mini_score *= 1.3
      end
      # Prefer if user knows any healing moves
      mini_score *= 1.3 if check_for_move(@user) { |move| move.healingMove? }
      # Prefer if user knows Pain Split or Leech Seed
      mini_score *= 1.2 if @user.pbHasMoveFunction?("05A")   # Pain Split
      mini_score *= 1.3 if @user.pbHasMoveFunction?("0DC")   # Leech Seed
      # Prefer if user has certain roles
      mini_score *= 1.3 if check_battler_role(@user, BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
      # TODO: Don't prefer if user's evasion stat is raised

      # TODO: Don't prefer if target has No Guard.
      mini_score *= 0.2 if @target.hasActiveAbility?(:NOGUARD)
      # TODO: Don't prefer if target has previously used any moves that never miss.

    end

    # Don't prefer if user has Contrary
    mini_score *= 0.5 if @user.hasActiveAbility?(:CONTRARY)
    # TODO: Don't prefer if target has Unaware? Reborn resets mini_score to 1.
    #       This check needs more consideration. Note that @target is user for
    #       status moves, so that part is wrong.
    # TODO: Is 0x for 025, 026, 026 (all moves that raise multiple stats)
    mini_score *= 0.5 if @move.statusMove? && @target.hasActiveAbility?(:UNAWARE)

    # TODO: Don't prefer if any foe has previously used a stat stage-clearing
    #       move (050, 051 Clear Smog/Haze).
    mini_score *= 0.3 if check_for_move(@target) { |move| ["050", "051"].include?(move.function) }   # Clear Smog, Haze

    # TODO: Prefer if user is faster than the target.
    # TODO: Is 1.3x for 025 Coil (+Atk, +Def, +acc).
    mini_score *= 1.5 if @user_faster
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
  def get_score_for_user_stat_raise(score)
    # Discard status move if user has Contrary
    return 0 if @move.statusMove? && @user.hasActiveAbility?(:CONTRARY)

    # Discard move if it can't raise any stats
    can_change_any_stat = false
    @move.stat_up.each_with_index do |stat, idx|
      next if idx.odd?
      next if @user.statStageAtMax?(stat)
      can_change_any_stat = true
      break
    end
    if !can_change_any_stat
      return (@move.statusMove?) ? 0 : score
    end

    # Get the main mini-score
    main_mini_score = calc_user_stat_raise_mini_score

    # For each stat to be raised in turn, calculate a mini-score describing how
    # beneficial that stat being raised will be
    mini_score = 0
    num_stats = 0
    @move.stat_up.each_with_index do |stat, idx|
      next if idx.odd?
      next if @user.statStageAtMax?(stat)
      # TODO: Use the effective increment (e.g. 1 if the stat is raised by 2 but
      #       the stat is already at +5).
      mini_score += calc_user_stat_raise_one(stat, @move.stat_up[idx + 1])
      num_stats += 1
    end

    # Apply the average mini-score to the actual score
    score = apply_effect_chance_to_score(main_mini_score * mini_score / num_stats)

    return score
  end
end
