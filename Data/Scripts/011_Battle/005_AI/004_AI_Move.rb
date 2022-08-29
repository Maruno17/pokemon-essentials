class Battle::AI
  #=============================================================================
  # Get scores for the user's moves (done before any action is assessed).
  #=============================================================================
  def pbGetMoveScores
    battler = @user.battler
    # Get scores and targets for each move
    choices = []
    # TODO: Split this into two, the first part being the calculation of all
    #       predicted damages and the second part being the score calculations
    #       (which are based on the predicted damages). Multi-target moves could
    #       be fiddly since damages should be calculated for each target but
    #       they're all related.
    battler.eachMoveWithIndex do |_m, i|
      next if !@battle.pbCanChooseMove?(battler.index, i, false)   # Unchoosable moves aren't considered
      pbAddMoveWithScoreToChoices(i, choices)
    end
    # Log the available choices
    if $INTERNAL
      logMsg = "[AI] Move choices for #{battler.pbThis(true)} (#{battler.index}): "
      choices.each_with_index do |c, i|
        logMsg += "#{battler.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2] >= 0
        logMsg += ", " if i < choices.length - 1
      end
      PBDebug.log(logMsg)
    end
    @battle.moldBreaker = false
    return choices
  end

  #=============================================================================
  # Get scores for the given move against each possible target.
  #=============================================================================
  # Wild Pokémon choose their moves randomly.
  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbAddMoveWithScoreToChoices(idxMove, choices)
    battler = @user.battler
    # TODO: Better incorporate this with the below code in future. This is here
    #       for now because of the num_targets > 1 code below, which would
    #       produce a score of 100 * the number of targets for a multi-target
    #       move, making it ridiculously over-preferred.
    if @user.wild?
      score = 100
      choices.push([idxMove, score, -1])   # Move index, score, target
      # Doubly prefer one of the user's moves (the choice is random but consistent
      # and does not correlate to any other property of the user)
      choices.push([idxMove, score, -1]) if battler.pokemon.personalID % battler.moves.length == idxMove
      return
    end
    move = battler.moves[idxMove]
    target_data = move.pbTarget(battler)
    # TODO: Alter target_data if user has Protean and move is Curse.
    if [:UserAndAllies, :AllAllies, :AllBattlers].include?(target_data.id) ||
       target_data.num_targets == 0
      # Also includes: BothSides, FoeSide, None, User, UserSide
      # If move has no targets, affects the user, a side or the whole field, or
      # specially affects multiple Pokémon and the AI calculates an overall
      # score at once instead of per target
      score = pbGetMoveScore(move)
      choices.push([idxMove, score, -1])
    elsif target_data.num_targets > 1
      # Includes: AllFoes, AllNearFoes, AllNearOthers
      # Would also include UserAndAllies, AllAllies, AllBattlers, but they're above
      # If move affects multiple battlers and you don't choose a particular one
      # TODO: Should the scores from each target be averaged instead of summed?
      total_score = 0
      num_targets = 0
      @battle.allBattlers.each do |b|
        next if !@battle.pbMoveCanTarget?(battler.index, b.index, target_data)
        score = pbGetMoveScore(move, b)
        total_score += ((battler.opposes?(b)) ? score : -score)
        num_targets += 1
      end
      final_score = (num_targets == 1) ? total_score : 1.5 * total_score / num_targets
      choices.push([idxMove, final_score, -1])
    else
      # Includes: Foe, NearAlly, NearFoe, NearOther, Other, RandomNearFoe, UserOrNearAlly
      # If move affects one battler and you have to choose which one
      @battle.allBattlers.each do |b|
        next if !@battle.pbMoveCanTarget?(battler.index, b.index, target_data)
        # TODO: This should consider targeting an ally if possible. Scores will
        #       need to distinguish between harmful and beneficial to target -
        #       maybe make the score "150 - score" if target is an ally (but
        #       only if the score is > 10 which is the "will fail" value)?
        #       Noticeably affects a few moves like Heal Pulse, as well as moves
        #       that the target can be immune to by an ability (you may want to
        #       attack the ally anyway so it gains the effect of that ability).
        next if target_data.targets_foe && !battler.opposes?(b)
        score = pbGetMoveScore(move, b)
        choices.push([idxMove, score, b.index])
      end
    end
  end

  #=============================================================================
  # Set some extra class variables for the move/target combo being assessed.
  #=============================================================================
  def set_up_move_check(move, target)
    @move.set_up(move, @user)
    # TODO: Set @target to nil if there isn't one?
    @target = (target) ? @battlers[target.index] : @user
    @target&.refresh_battler
    @battle.moldBreaker = @user.has_mold_breaker?
    # Determine whether user or target is faster, and store that result so it
    # doesn't need recalculating
    @user_faster = @user.faster_than?(@target)
  end

  #=============================================================================
  # Returns whether the move will definitely fail (assuming no battle conditions
  # change between now and using the move).
  # TODO: Add skill checks in here for particular calculations?
  #=============================================================================
  def pbPredictMoveFailure
    return false if !@trainer.has_skill_flag?("PredictMoveFailure")
    # TODO: Something involving user.usingMultiTurnAttack? (perhaps earlier than
    #       this?).
    # User is asleep and will not wake up
    return true if @trainer.medium_skill? && @user.battler.asleep? &&
                   @user.statusCount > 1 && !@move.move.usableWhenAsleep?
    # User will be truanting
    return true if @user.has_active_ability?(:TRUANT) && @user.effects[PBEffects::Truant]
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail?(@move.function, @move, @user, @target, self, @battle)
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
    calc_type = @move.pbCalcType(@user.battler)
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
  def pbGetMoveScore(move, target = nil)
    set_up_move_check(move, target)
    user_battler = @user.battler
    target_battler = @target.battler

    # Predict whether the move will fail
    return 50 if pbPredictMoveFailure

    # Get the base score for the move
    if @move.damagingMove?
      # Is also the predicted damage amount as a percentage of target's current HP
      score = pbGetDamagingMoveBaseScore
    else   # Status moves
      # Depends on the move's effect
      score = pbGetStatusMoveBaseScore
    end
    # Modify the score according to the move's effect
    score = Battle::AI::Handlers.apply_move_effect_score(@move.function,
       score, @move, @user, @target, self, @battle)
    # Modify the score according to various other effects
    score = Battle::AI::Handlers.apply_general_move_score_modifiers(
       score, @move, @user, @target, self, @battle)

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

    # If there are no calculated choices, pick one at random
    if choices.length == 0
      # NOTE: Can only get here if no moves can be chosen, i.e. will auto-use a
      #       move or struggle.
      user_battler.eachMoveWithIndex do |_m, i|
        next if !@battle.pbCanChooseMove?(user_battler.index, i, false)
        choices.push([i, 100, -1])   # Move index, score, target
      end
      if choices.length == 0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user_battler.index)
        PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will auto-use a move or Struggle")
        return
      end
      PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) doesn't want to use any moves; picking one at random")
    end

    # Figure out useful information about the choices
    max_score = 0
    choices.each { |c| max_score = c[1] if max_score < c[1] }

    # Decide whether all choices are bad, and if so, try switching instead
    if @trainer.high_skill? && @user.can_switch_lax?
      badMoves = false
      if (max_score <= 20 && user_battler.turnCount > 2) ||
         (max_score <= 40 && user_battler.turnCount > 5)
        badMoves = true if pbAIRandom(100) < 80
      end
      if !badMoves && max_score < 60 && user_battler.turnCount > 1
        badMoves = choices.none? { |c| user_battler.moves[c[0]].damagingMove? }
        badMoves = false if badMoves && pbAIRandom(100) < 10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(true)
        if $INTERNAL
          PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will switch due to terrible moves")
        end
        return
      end
    end

    # Calculate a minimum score threshold and reduce all move scores by it
    threshold = (max_score * 0.85).floor
    choices.each { |c| c[1] = [c[1] - threshold, 0].max }
    total_score = choices.sum { |c| c[1] }

    # Pick a move randomly from choices weighted by their scores
    randNum = pbAIRandom(total_score)
    choices.each do |c|
      randNum -= c[1]
      next if randNum >= 0
      @battle.pbRegisterMove(user_battler.index, c[0], false)
      @battle.pbRegisterTarget(user_battler.index, c[2]) if c[2] >= 0
      break
    end

    # Log the result
    if @battle.choices[user_battler.index][2]
      PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will use #{@battle.choices[user_battler.index][2].name}")
    end
  end
end
