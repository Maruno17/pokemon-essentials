#===============================================================================
#
#===============================================================================
class Battle::AI
  MOVE_FAIL_SCORE    = 20
  MOVE_USELESS_SCORE = 60   # Move predicted to do nothing or just be detrimental
  MOVE_BASE_SCORE    = 100

  # Returns a value between 0.0 and 1.0. All move scores are lowered by this
  # value multiplied by the highest-scoring move's score.
  def move_score_threshold
    return 0.6 + (0.35 * (([@trainer.skill, 100].min / 100.0)**0.5))   # 0.635 to 0.95
  end

  #-----------------------------------------------------------------------------

  # Get scores for the user's moves.
  # NOTE: For any move with a target type that can target a foe (or which
  #       includes a foe(s) if it has multiple targets), the score calculated
  #       for a target ally will be inverted. The MoveHandlers for those moves
  #       should therefore treat an ally as a foe when calculating a score
  #       against it.
  def pbGetMoveScores
    choices = []
    @user.battler.eachMoveWithIndex do |orig_move, idxMove|
      # Unchoosable moves aren't considered
      if !@battle.pbCanChooseMove?(@user.index, idxMove, false)
        if orig_move.pp == 0 && orig_move.total_pp > 0
          PBDebug.log_ai("#{@user.name} cannot use #{orig_move.name} (no PP left)")
        else
          PBDebug.log_ai("#{@user.name} cannot choose to use #{orig_move.name}")
        end
        next
      end
      # Set up move in class variables
      set_up_move_check(orig_move)
      # Predict whether the move will fail (generally)
      if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailure
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name}...")
        PBDebug.log_score_change(MOVE_FAIL_SCORE - MOVE_BASE_SCORE, "move will fail")
        add_move_to_choices(choices, idxMove, MOVE_FAIL_SCORE)
        next
      end
      # Get the move's target type
      target_data = @move.pbTarget(@user.battler)
      if @move.function_code == "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" &&
         @move.rough_type == :GHOST && @user.has_active_ability?([:LIBERO, :PROTEAN])
        target_data = GameData::Target.get((Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe)
      end
      case target_data.num_targets
      when 0   # No targets, affects the user or a side or the whole field
        # Includes: BothSides, FoeSide, None, User, UserSide
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name}...")
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore }
        add_move_to_choices(choices, idxMove, score)
      when 1   # One target to be chosen by the trainer
        # Includes: Foe, NearAlly, NearFoe, NearOther, Other, RandomNearFoe, UserOrNearAlly
        redirected_target = get_redirected_target(target_data)
        num_targets = 0
        @battle.allBattlers.each do |b|
          next if redirected_target && b.index != redirected_target
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          next if target_data.targets_foe && !@user.battler.opposes?(b)
          PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name} against #{b.name} (#{b.index})...")
          score = MOVE_BASE_SCORE
          PBDebug.logonerr { score = pbGetMoveScore([b]) }
          add_move_to_choices(choices, idxMove, score, b.index)
          num_targets += 1
        end
        PBDebug.log("     no valid targets") if num_targets == 0
      else   # Multiple targets at once
        # Includes: AllAllies, AllBattlers, AllFoes, AllNearFoes, AllNearOthers, UserAndAllies
        targets = []
        @battle.allBattlers.each do |b|
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          targets.push(b)
        end
        PBDebug.log_ai("#{@user.name} is considering using #{orig_move.name}...")
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore(targets) }
        add_move_to_choices(choices, idxMove, score)
      end
    end
    @battle.moldBreaker = false
    return choices
  end

  # If the target of a move can be changed by an external effect, this method
  # returns the battler index of the new target.
  def get_redirected_target(target_data)
    return nil if @move.move.cannotRedirect?
    return nil if !target_data.can_target_one_foe? || target_data.num_targets != 1
    return nil if @user.has_active_ability?([:PROPELLERTAIL, :STALWART])
    priority = @battle.pbPriority(true)
    near_only = !target_data.can_choose_distant_target?
    # Spotlight, Follow Me/Rage Powder
    new_target = -1
    strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop] >= 0
      next if !b.opposes?(@user.battler)
      next if near_only && !b.near?(@user.battler)
      if b.effects[PBEffects::Spotlight] > 0 && b.effects[PBEffects::Spotlight] - 50 < strength
        new_target = b.index
        strength = b.effects[PBEffects::Spotlight] - 50   # Spotlight takes priority
      elsif (b.effects[PBEffects::RagePowder] && @user.battler.affectedByPowder?) ||
            (b.effects[PBEffects::FollowMe] > 0 && b.effects[PBEffects::FollowMe] < strength)
        new_target = b.index
        strength = b.effects[PBEffects::FollowMe]
      end
    end
    return new_target if new_target >= 0
    calc_type = @move.rough_type
    priority.each do |b|
      next if b.index == @user.index
      next if near_only && !b.near?(@user.battler)
      case calc_type
      when :ELECTRIC
        new_target = b.index if b.hasActiveAbility?(:LIGHTNINGROD)
      when :WATER
        new_target = b.index if b.hasActiveAbility?(:STORMDRAIN)
      end
      break if new_target >= 0
    end
    return (new_target >= 0) ? new_target : nil
  end

  def add_move_to_choices(choices, idxMove, score, idxTarget = -1)
    choices.push([idxMove, score, idxTarget])
    # If the user is a wild Pokémon, doubly prefer one of its moves (the choice
    # is random but consistent and does not correlate to any other property of
    # the user)
    if @user.wild? && @user.pokemon.personalID % @user.battler.moves.length == idxMove
      choices.push([idxMove, score, idxTarget])
    end
  end

  #-----------------------------------------------------------------------------

  # Set some extra class variables for the move being assessed.
  def set_up_move_check(move)
    case move.function_code
    when "UseLastMoveUsed"
      if @battle.lastMoveUsed &&
         GameData::Move.exists?(@battle.lastMoveUsed) &&
         !move.moveBlacklist.include?(GameData::Move.get(@battle.lastMoveUsed).function_code)
        move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@battle.lastMoveUsed))
      end
    when "UseMoveDependingOnEnvironment"
      move.pbOnStartUse(@user.battler, [])   # Determine which move is used instead
      move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(move.npMove))
    end
    @battle.moldBreaker = @user.has_mold_breaker?
    @move.set_up(move)
  end

  # Set some extra class variables for the target being assessed.
  def set_up_move_check_target(target)
    @target = (target) ? @battlers[target.index] : nil
    @target&.refresh_battler
    if @target && @move.function_code == "UseLastMoveUsedByTarget"
      if @target.battler.lastRegularMoveUsed &&
         GameData::Move.exists?(@target.battler.lastRegularMoveUsed) &&
         GameData::Move.get(@target.battler.lastRegularMoveUsed).has_flag?("CanMirrorMove")
        @battle.moldBreaker = @user.has_mold_breaker?
        mov = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@target.battler.lastRegularMoveUsed))
        @move.set_up(mov)
      end
    end
  end

  #-----------------------------------------------------------------------------

  # Returns whether the move will definitely fail (assuming no battle conditions
  # change between now and using the move).
  def pbPredictMoveFailure
    # User is asleep and will not wake up
    return true if @user.battler.asleep? && @user.statusCount > 1 && !@move.move.usableWhenAsleep?
    # User is awake and can't use moves that are only usable when asleep
    return true if !@user.battler.asleep? && @move.move.usableWhenAsleep?
    # NOTE: Truanting is not considered, because if it is, a Pokémon with Truant
    #       will want to switch due to terrible moves every other round (because
    #       all of its moves will fail), and this is disruptive and shouldn't be
    #       how such Pokémon behave.
    # Primal weather
    return true if @battle.pbWeather == :HeavyRain && @move.rough_type == :FIRE
    return true if @battle.pbWeather == :HarshSun && @move.rough_type == :WATER
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail?(@move.function_code, @move, @user, self, @battle)
    return false
  end

  # Returns whether the move will definitely fail against the target (assuming
  # no battle conditions change between now and using the move).
  def pbPredictMoveFailureAgainstTarget
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail_against_target?(@move.function_code, @move, @user, @target, self, @battle)
    # Immunity to priority moves because of Psychic Terrain
    return true if @battle.field.terrain == :Psychic && @target.battler.affectedByTerrain? &&
                   @target.opposes?(@user) && @move.rough_priority(@user) > 0
    # Immunity because of ability
    return true if @move.move.pbImmunityByAbility(@user.battler, @target.battler, false)
    # Immunity because of Dazzling/Queenly Majesty
    if @move.rough_priority(@user) > 0 && @target.opposes?(@user)
      each_same_side_battler(@target.side) do |b, i|
        return true if b.has_active_ability?([:DAZZLING, :QUEENLYMAJESTY])
      end
    end
    # Type immunity
    calc_type = @move.rough_type
    typeMod = @move.move.pbCalcTypeMod(calc_type, @user.battler, @target.battler)
    return true if @move.move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
    # Dark-type immunity to moves made faster by Prankster
    return true if Settings::MECHANICS_GENERATION >= 7 && @move.statusMove? &&
                   @user.has_active_ability?(:PRANKSTER) && @target.has_type?(:DARK) && @target.opposes?(@user)
    # Airborne-based immunity to Ground moves
    return true if @move.damagingMove? && calc_type == :GROUND &&
                   @target.battler.airborne? && !@move.move.hitsFlyingTargets?
    # Immunity to powder-based moves
    return true if @move.move.powderMove? && !@target.battler.affectedByPowder?
    # Substitute
    return true if @target.effects[PBEffects::Substitute] > 0 && @move.statusMove? &&
                   !@move.move.ignoresSubstitute?(@user.battler) && @user.index != @target.index
    return false
  end

  #-----------------------------------------------------------------------------

  # Get a score for the given move being used against the given target.
  # Assumes def set_up_move_check has previously been called.
  def pbGetMoveScore(targets = nil)
    # Get the base score for the move
    score = MOVE_BASE_SCORE
    # Scores for each target in turn
    if targets
      # Reset the base score for the move (each target will add its own score)
      score = 0
      affected_targets = 0
      # Get a score for the move against each target in turn
      orig_move = @move.move   # In case move is Mirror Move and changes depending on the target
      targets.each do |target|
        set_up_move_check(orig_move)
        set_up_move_check_target(target)
        t_score = pbGetMoveScoreAgainstTarget
        next if t_score < 0
        score += t_score
        affected_targets += 1
      end
      # Set the default score if no targets were affected
      if affected_targets == 0
        score = (@trainer.has_skill_flag?("PredictMoveFailure")) ? MOVE_USELESS_SCORE : MOVE_BASE_SCORE
      end
      # Score based on how many targets were affected
      if affected_targets == 0 && @trainer.has_skill_flag?("PredictMoveFailure")
        if !@move.move.worksWithNoTargets?
          PBDebug.log_score_change(MOVE_FAIL_SCORE - MOVE_BASE_SCORE, "move will fail")
          return MOVE_FAIL_SCORE
        end
      else
        score /= affected_targets if affected_targets > 1   # Average the score against multiple targets
        # Bonus for affecting multiple targets
        if @trainer.has_skill_flag?("PreferMultiTargetMoves") && affected_targets > 1
          old_score = score
          score += (affected_targets - 1) * 10
          PBDebug.log_score_change(score - old_score, "affects multiple battlers")
        end
      end
    end
    # If we're here, the move either has no targets or at least one target will
    # be affected (or the move is usable even if no targets are affected, e.g.
    # Self-Destruct)
    if @trainer.has_skill_flag?("ScoreMoves")
      # Modify the score according to the move's effect
      old_score = score
      score = Battle::AI::Handlers.apply_move_effect_score(@move.function_code,
         score, @move, @user, self, @battle)
      PBDebug.log_score_change(score - old_score, "function code modifier (generic)")
      # Modify the score according to various other effects
      score = Battle::AI::Handlers.apply_general_move_score_modifiers(
        score, @move, @user, self, @battle)
    end
    score = score.to_i
    score = 0 if score < 0
    return score
  end

  #-----------------------------------------------------------------------------

  # Returns the score of @move being used against @target. A return value of -1
  # means the move will fail or do nothing against the target.
  # Assumes def set_up_move_check and def set_up_move_check_target have
  # previously been called.
  def pbGetMoveScoreAgainstTarget
    # Predict whether the move will fail against the target
    if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailureAgainstTarget
      PBDebug.log("     move will not affect #{@target.name}")
      return -1
    end
    # Score the move
    score = MOVE_BASE_SCORE
    if @trainer.has_skill_flag?("ScoreMoves")
      # Modify the score according to the move's effect against the target
      old_score = score
      score = Battle::AI::Handlers.apply_move_effect_against_target_score(@move.function_code,
         MOVE_BASE_SCORE, @move, @user, @target, self, @battle)
      PBDebug.log_score_change(score - old_score, "function code modifier (against target)")
      # Modify the score according to various other effects against the target
      score = Battle::AI::Handlers.apply_general_move_against_target_score_modifiers(
        score, @move, @user, @target, self, @battle)
    end
    # Add the score against the target to the overall score
    target_data = @move.pbTarget(@user.battler)
    if target_data.targets_foe && !@target.opposes?(@user) && @target.index != @user.index
      if score == MOVE_USELESS_SCORE
        PBDebug.log("     move is useless against #{@target.name}")
        return -1
      end
      old_score = score
      score = ((1.85 * MOVE_BASE_SCORE) - score).to_i
      PBDebug.log_score_change(score - old_score, "score inverted (move targets ally but can target foe)")
    end
    return score
  end

  #-----------------------------------------------------------------------------

  # Make the final choice of which move to use depending on the calculated
  # scores for each move. Moves with higher scores are more likely to be chosen.
  def pbChooseMove(choices)
    user_battler = @user.battler
    # If no moves can be chosen, auto-choose a move or Struggle
    if choices.length == 0
      @battle.pbAutoChooseMove(user_battler.index)
      PBDebug.log_ai("#{@user.name} will auto-use a move or Struggle")
      return
    end
    # Figure out useful information about the choices
    max_score = 0
    choices.each { |c| max_score = c[1] if max_score < c[1] }
    # Decide whether all choices are bad, and if so, try switching instead
    if @trainer.high_skill? && @user.can_switch_lax?
      badMoves = false
      if max_score <= MOVE_USELESS_SCORE
        badMoves = true
      elsif max_score < MOVE_BASE_SCORE * move_score_threshold && user_battler.turnCount > 2
        badMoves = true if pbAIRandom(100) < 80
      end
      if badMoves
        PBDebug.log_ai("#{@user.name} wants to switch due to terrible moves")
        if pbChooseToSwitchOut(true)
          @battle.pbUnregisterMegaEvolution(@user.index)
          return
        end
        PBDebug.log_ai("#{@user.name} won't switch after all")
      end
    end
    # Calculate a minimum score threshold and reduce all move scores by it
    threshold = (max_score * move_score_threshold.to_f).floor
    choices.each { |c| c[3] = [c[1] - threshold, 0].max }
    total_score = choices.sum { |c| c[3] }
    # Log the available choices
    if $INTERNAL
      PBDebug.log_ai("Move choices for #{@user.name}:")
      choices.each_with_index do |c, i|
        chance = sprintf("%5.1f", (c[3] > 0) ? 100.0 * c[3] / total_score : 0)
        log_msg = "   * #{chance}% to use #{user_battler.moves[c[0]].name}"
        log_msg += " (target #{c[2]})" if c[2] >= 0
        log_msg += ": score #{c[1]}"
        PBDebug.log(log_msg)
      end
    end
    # Pick a move randomly from choices weighted by their scores
    randNum = pbAIRandom(total_score)
    choices.each do |c|
      randNum -= c[3]
      next if randNum >= 0
      @battle.pbRegisterMove(user_battler.index, c[0], false)
      @battle.pbRegisterTarget(user_battler.index, c[2]) if c[2] >= 0
      break
    end
    # Log the result
    if @battle.choices[user_battler.index][2]
      move_name = @battle.choices[user_battler.index][2].name
      if @battle.choices[user_battler.index][3] >= 0
        PBDebug.log("   => will use #{move_name} (target #{@battle.choices[user_battler.index][3]})")
      else
        PBDebug.log("   => will use #{move_name}")
      end
    end
  end
end
