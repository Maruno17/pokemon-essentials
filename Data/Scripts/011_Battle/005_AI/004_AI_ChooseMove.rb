class Battle::AI
  MOVE_FAIL_SCORE    = 25
  MOVE_USELESS_SCORE = 60   # Move predicted to do nothing or just be detrimental
  MOVE_BASE_SCORE    = 100

  #=============================================================================
  # Get scores for the user's moves (done before any action is assessed).
  #=============================================================================
  def pbGetMoveScores
    choices = []
    @user.battler.eachMoveWithIndex do |move, idxMove|
      # Unchoosable moves aren't considered
      if !@battle.pbCanChooseMove?(@user.index, idxMove, false)
        if move.pp == 0 && move.total_pp > 0
          PBDebug.log("[AI] #{@user.battler.pbThis} (#{@user.index}) cannot use move #{move.name} as it has no PP left")
        else
          PBDebug.log("[AI] #{@user.battler.pbThis} (#{@user.index}) cannot choose to use #{move.name}")
        end
        next
      end
      # Set up move in class variables
      set_up_move_check(move)
      # Predict whether the move will fail (generally)
      if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailure
        add_move_to_choices(choices, idxMove, MOVE_FAIL_SCORE)
        next
      end
      target_data = move.pbTarget(@user.battler)
      # TODO: Alter target_data if user has Protean and move is Curse.
      case target_data.num_targets
      when 0   # No targets, affects the user or a side or the whole field
        # Includes: BothSides, FoeSide, None, User, UserSide
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore(move) }
        add_move_to_choices(choices, idxMove, score)
      when 1   # One target to be chosen by the trainer
        # Includes: Foe, NearAlly, NearFoe, NearOther, Other, RandomNearFoe, UserOrNearAlly
        # TODO: Figure out first which targets are valid. Includes the call to
        #       pbMoveCanTarget?, but also includes move-redirecting effects like
        #       Lightning Rod. Skip any battlers that can't be targeted.
        @battle.allBattlers.each do |b|
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          # TODO: This should consider targeting an ally if possible. Scores will
          #       need to distinguish between harmful and beneficial to target.
          #       def pbGetMoveScore uses "175 - score" if the target is an ally;
          #       is this okay?
          #       Noticeably affects a few moves like Heal Pulse, as well as moves
          #       that the target can be immune to by an ability (you may want to
          #       attack the ally anyway so it gains the effect of that ability).
          next if target_data.targets_foe && !@user.battler.opposes?(b)
          score = MOVE_BASE_SCORE
          PBDebug.logonerr { score = pbGetMoveScore(move, [b]) }
          add_move_to_choices(choices, idxMove, score, b.index)
        end
      else   # Multiple targets at once
        # Includes: AllAllies, AllBattlers, AllFoes, AllNearFoes, AllNearOthers, UserAndAllies
        targets = []
        @battle.allBattlers.each do |b|
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          targets.push(b)
        end
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore(move, targets) }
        add_move_to_choices(choices, idxMove, score)
      end
    end
    @battle.moldBreaker = false
    return choices
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

  #=============================================================================
  # Set some extra class variables for the move/target combo being assessed.
  #=============================================================================
  def set_up_move_check(move)
    @move.set_up(move, @user)
    @battle.moldBreaker = @user.has_mold_breaker?
  end

  def set_up_move_check_target(target)
    # TODO: Set @target to nil if there isn't one?
    @target = (target) ? @battlers[target.index] : nil   # @user
    @target&.refresh_battler
  end

  #=============================================================================
  # Returns whether the move will definitely fail (assuming no battle conditions
  # change between now and using the move).
  # TODO: Add skill checks in here for particular calculations?
  #=============================================================================
  def pbPredictMoveFailure
    # TODO: Something involving user.usingMultiTurnAttack? (perhaps earlier than
    #       this?).
    # User is asleep and will not wake up
    return true if @trainer.medium_skill? && @user.battler.asleep? &&
                   @user.statusCount > 1 && !@move.move.usableWhenAsleep?
    # User will be truanting
    return true if @user.has_active_ability?(:TRUANT) && @user.effects[PBEffects::Truant]
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail?(@move.function, @move, @user, self, @battle)
    return false
  end

  def pbPredictMoveFailureAgainstTarget
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail_against_target?(@move.function, @move, @user, @target, self, @battle)
    # Immunity to priority moves because of Psychic Terrain
    return true if @battle.field.terrain == :Psychic && @target.battler.affectedByTerrain? &&
                   @target.opposes?(@user) && @move.rough_priority(@user) > 0
    # Immunity because of ability (intentionally before type immunity check)
    # TODO: Check for target-redirecting abilities that also provide immunity.
    #       If an ally has such an ability, may want to just not prefer the move
    #       instead of predicting its failure, as might want to hit the ally
    #       after all.
    return true if @move.move.pbImmunityByAbility(@user.battler, @target.battler, false)
    # Type immunity
    calc_type = @move.rough_type
    typeMod = @move.move.pbCalcTypeMod(calc_type, @user.battler, @target.battler)
    return true if @move.move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
    # Dark-type immunity to moves made faster by Prankster
    return true if Settings::MECHANICS_GENERATION >= 7 && @user.has_active_ability?(:PRANKSTER) &&
                   @target.has_type?(:DARK) && @target.opposes?(@user)
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

  #=============================================================================
  # Get a score for the given move being used against the given target.
  #=============================================================================
  def pbGetMoveScore(move, targets = nil)
    # Get the base score for the move
    score = MOVE_BASE_SCORE
    # Scores for each target in turn
    if targets
      # Reset the base score for the move (each target will add its own score)
      score = 0
      # TODO: Distinguish between affected foes and affected allies?
      affected_targets = 0
      # Get a score for the move against each target in turn
      targets.each do |target|
        set_up_move_check_target(target)
        # Predict whether the move will fail against the target
        if @trainer.has_skill_flag?("PredictMoveFailure")
          next if pbPredictMoveFailureAgainstTarget
        end
        affected_targets += 1
        # Score the move
        t_score = MOVE_BASE_SCORE
        if @trainer.has_skill_flag?("ScoreMoves")
          # Modify the score according to the move's effect against the target
          t_score = Battle::AI::Handlers.apply_move_effect_against_target_score(@move.function,
             MOVE_BASE_SCORE, @move, @user, @target, self, @battle)
          # Modify the score according to various other effects against the target
          score = Battle::AI::Handlers.apply_general_move_against_target_score_modifiers(
             score, @move, @user, @target, self, @battle)
        end
        score += (@target.opposes?(@user)) ? t_score : 175 - t_score
      end
      # Check if any targets were affected
      if affected_targets == 0
        if @trainer.has_skill_flag?("PredictMoveFailure")
          return MOVE_FAIL_SCORE if !@move.move.worksWithNoTargets?
          score = MOVE_USELESS_SCORE
        else
          score = MOVE_BASE_SCORE
        end
      else
        # TODO: Can this accounting for multiple targets be improved somehow?
        score /= affected_targets   # Average the score against multiple targets
        # Bonus for affecting multiple targets
        if @trainer.has_skill_flag?("PreferMultiTargetMoves")
          score += (affected_targets - 1) * 10
        end
      end
    end
    # If we're here, the move either has no targets or at least one target will
    # be affected (or the move is usable even if no targets are affected, e.g.
    # Self-Destruct)
    if @trainer.has_skill_flag?("ScoreMoves")
      # Modify the score according to the move's effect
      score = Battle::AI::Handlers.apply_move_effect_score(@move.function,
         score, @move, @user, self, @battle)
      # Modify the score according to various other effects
      score = Battle::AI::Handlers.apply_general_move_score_modifiers(
         score, @move, @user, self, @battle)
    end
    score = score.to_i
    score = 0 if score < 0
    return score
  end

  #=============================================================================
  # Make the final choice of which move to use depending on the calculated
  # scores for each move. Moves with higher scores are more likely to be chosen.
  #=============================================================================
  def pbChooseMove(choices)
    user_battler = @user.battler
    # If no moves can be chosen, auto-choose a move or Struggle
    if choices.length == 0
      @battle.pbAutoChooseMove(user_battler.index)
      PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will auto-use a move or Struggle")
      return
    end
    # Figure out useful information about the choices
    max_score = 0
    choices.each { |c| max_score = c[1] if max_score < c[1] }
    # Decide whether all choices are bad, and if so, try switching instead
    if @trainer.high_skill? && @user.can_switch_lax?
      badMoves = false
      if (max_score <= MOVE_FAIL_SCORE && user_battler.turnCount > 2) ||
         (max_score <= MOVE_USELESS_SCORE && user_battler.turnCount > 4)
        badMoves = true if pbAIRandom(100) < 80
      end
      if !badMoves && max_score <= MOVE_USELESS_SCORE && user_battler.turnCount >= 1
        badMoves = choices.none? { |c| user_battler.moves[c[0]].damagingMove? }
        badMoves = false if badMoves && pbAIRandom(100) < 10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(true)
        PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will switch due to terrible moves")
        return
      end
    end
    # Calculate a minimum score threshold and reduce all move scores by it
    threshold = (max_score * 0.85).floor
    choices.each { |c| c[3] = [c[1] - threshold, 0].max }
    total_score = choices.sum { |c| c[3] }
    # Log the available choices
    if $INTERNAL
      PBDebug.log("[AI] Move choices for #{user_battler.pbThis(true)} (#{user_battler.index}):")
      choices.each_with_index do |c, i|
        chance = sprintf("%5.1f", (c[3] > 0) ? 100.0 * c[3] / total_score : 0)
        log_msg = "    * #{chance}% chance: #{user_battler.moves[c[0]].name}"
        log_msg += " (against target #{c[2]})" if c[2] >= 0
        log_msg += " = score #{c[1]}"
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
      PBDebug.log("    => will use #{@battle.choices[user_battler.index][2].name}")
    end
  end
end
