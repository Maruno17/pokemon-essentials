class Battle::AI
  #=============================================================================
  # Get scores for the user's moves (done before any action is assessed)
  # NOTE: A move is only added to the choices array if it has a non-zero score.
  #=============================================================================
  def pbGetMoveScores
    battler = @user.battler
    # Get scores and targets for each move
    choices = []
    # TODO: Split this into two, the first part being the calculation of all
    #       predicted damages and the second part being the score calculations
    #       (which are based on the predicted damages). Note that this requires
    #       saving each of the scoresAndTargets entries in here rather than in
    #       def pbRegisterMoveTrainer, and only at the very end are they
    #       whittled down to one per move which are chosen from. Multi-target
    #       moves could be fiddly since damages should be calculated for each
    #       target but they're all related.
    battler.eachMoveWithIndex do |_m, i|
      next if !@battle.pbCanChooseMove?(battler.index, i, false)
      if @user.wild?
        pbRegisterMoveWild(i, choices)
      else
        pbRegisterMoveTrainer(i, choices)
      end
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
    return choices
  end

  #=============================================================================
  # Get scores for the given move against each possible target
  #=============================================================================
  # Wild Pokémon choose their moves randomly.
  def pbRegisterMoveWild(idxMove, choices)
    battler = @user.battler
    score = 100
    choices.push([idxMove, score, -1])   # Move index, score, target
    # Doubly prefer one of the user's moves (the choice is random but consistent
    # and does not correlate to any other property of the user)
    choices.push([idxMove, score, -1]) if battler.pokemon.personalID % battler.moves.length == idxMove
  end

  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbRegisterMoveTrainer(idxMove, choices)
    battler = @user.battler
    move = battler.moves[idxMove]
    target_data = move.pbTarget(battler)
    # TODO: Alter target_data if user has Protean and move is Curse.
    if [:UserAndAllies, :AllAllies, :AllBattlers].include?(target_data.id) ||
       target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field, or
      # specially affects multiple Pokémon and the AI calculates an overall
      # score at once instead of per target
      score = pbGetMoveScore(move)
      choices.push([idxMove, score, -1]) if score > 0
    elsif target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.allBattlers.each do |b|
        next if !@battle.pbMoveCanTarget?(battler.index, b.index, target_data)
        score = pbGetMoveScore(move, b)
        totalScore += ((battler.opposes?(b)) ? score : -score)
      end
      choices.push([idxMove, totalScore, -1]) if totalScore > 0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.allBattlers.each do |b|
        next if !@battle.pbMoveCanTarget?(battler.index, b.index, target_data)
        next if target_data.targets_foe && !battler.opposes?(b)
        score = pbGetMoveScore(move, b)
        scoresAndTargets.push([score, b.index]) if score > 0
      end
      if scoresAndTargets.length > 0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a, b| b[0] <=> a[0] }
        choices.push([idxMove, scoresAndTargets[0][0], scoresAndTargets[0][1]])
      end
    end
  end

  #=============================================================================
  # Set some extra class variables for the move/target combo being assessed
  #=============================================================================
  def set_up_move_check(move, target)
    @move.set_up(move, @user)
    @target = (target) ? @battlers[target.index] : @user
    @target&.refresh_battler
    # Determine whether user or target is faster, and store that result so it
    # doesn't need recalculating
    @user_faster = @user.faster_than?(@target)
  end

  #=============================================================================
  # Returns whether the move will definitely fail (assuming no battle conditions
  # change between now and using the move)
  #=============================================================================
  def pbPredictMoveFailure
    return false if !@trainer.has_skill_flag?("PredictMoveFailure")
    # TODO: Something involving pbCanChooseMove? (see Assault Vest).
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
    if @move.move.powderMove?
      return true if @target.has_type?(:GRASS) && Settings::MORE_TYPE_EFFECTS
      if Settings::MECHANICS_GENERATION >= 6
        return true if @target.has_active_ability?(:OVERCOAT) ||
                       @target.has_active_item?(:SAFETYGOGGLES)
      end
    end
    # Substitute
    return true if @target.effects[PBEffects::Substitute] > 0 && @move.statusMove? &&
                   !@move.move.ignoresSubstitute?(@user.battler) && @user.index != @target.index
    return false
  end

  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  def pbGetMoveScore(move, target = nil)
    set_up_move_check(move, target)
    user_battler = @user.battler
    target_battler = @target.battler

    # Predict whether the move will fail
    return 10 if pbPredictMoveFailure

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

    # A score of 0 here means it absolutely should not be used
    return 0 if score <= 0

    # TODO: High priority checks:
    # => Prefer move if it will KO the target (moreso if user is slower than target)
    # => Don't prefer damaging move if it won't KO, user has Stance Change and
    #    is in shield form, and user is slower than the target
    # => Check memory for past damage dealt by a target's non-high priority move,
    #    and prefer move if user is slower than the target and another hit from
    #    the same amount will KO the user
    # => Check memory for past damage dealt by a target's priority move, and don't
    #    prefer the move if user is slower than the target and can't move faster
    #    than it because of priority
    # => Discard move if user is slower than the target and target is semi-
    #    invulnerable (and move won't hit it)
    # => Check memory for whether target has previously used Quick Guard, and
    #    don't prefer move if so

    # TODO: Low priority checks:
    # => Don't prefer move if user is faster than the target
    # => Prefer move if user is faster than the target and target is semi-
    #    invulnerable

    # Don't prefer a dancing move if the target has the Dancer ability
    # TODO: Check all battlers, not just the target.
    if @move.move.danceMove? && @target.has_active_ability?(:DANCER)
      score /= 2
    end

    # TODO: Check memory for whether target has previously used Ion Deluge, and
    #       don't prefer move if it's Normal-type and target is immune because
    #       of its ability (Lightning Rod, etc.).

    # TODO: Don't prefer sound move if user hasn't been Throat Chopped but
    #       target has previously used Throat Chop.

    # TODO: Prefer move if it has a high critical hit rate, critical hits are
    #       possible but not certain, and target has raised defences/user has
    #       lowered offences (Atk/Def or SpAtk/SpDef, whichever is relevant).

    # TODO: Don't prefer damaging moves if target is Destiny Bonding.
    # => Also don't prefer damaging moves if user is slower than the target, move
    #    is likely to be lethal, and target has previously used Destiny Bond

    # TODO: Don't prefer a move that is stopped by Wide Guard if target has
    #       previously used Wide Guard.

    # TODO: Don't prefer Fire-type moves if target has previously used Powder.

    # TODO: Don't prefer contact move if making contact with the target could
    #       trigger an effect that's bad for the user (Static, etc.).
    # => Also check if target has previously used Spiky Shield.King's Shield/
    #    Baneful Bunker, and don't prefer move if so

    # TODO: Prefer a contact move if making contact with the target could trigger
    #       an effect that's good for the user (Poison Touch/Pickpocket).

    # TODO: Don't prefer a status move if user has a damaging move that will KO
    #       the target.
    # => If target has previously used a move that will hurt the user by 30% of
    #    its current HP or more, moreso don't prefer a status move.

    # Prefer damaging moves if AI has no more Pokémon or AI is less clever
    if @trainer.medium_skill? && @battle.pbAbleNonActiveCount(user_battler.idxOwnSide) == 0 &&
       !(@trainer.high_skill? && @battle.pbAbleNonActiveCount(target_battler.idxOwnSide) > 0)
      if @move.move.statusMove?
        score *= 0.9
      elsif target_battler.hp <= target_battler.totalhp / 2
        score *= 1.1
      end
    end

    # Don't prefer attacking the target if they'd be semi-invulnerable
    if @move.accuracy > 0 && @user_faster &&
       (target_battler.semiInvulnerable? || target_battler.effects[PBEffects::SkyDrop] >= 0)
      miss = true
      miss = false if @user.has_active_ability?(:NOGUARD)
      miss = false if @trainer.best_skill? && @target.has_active_ability?(:NOGUARD)
      if @trainer.best_skill? && miss
        # Knows what can get past semi-invulnerability
        if target_battler.effects[PBEffects::SkyDrop] >= 0 ||
           target_battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                   "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                   "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
          miss = false if move.hitsFlyingTargets?
        elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
          miss = false if move.hitsDiggingTargets?
        elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
          miss = false if move.hitsDivingTargets?
        end
      end
      score = 10 if miss
    end

    # Pick a good move for the Choice items
    if @trainer.medium_skill?
      if @user.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         @user.has_active_ability?(:GORILLATACTICS)
        # Really don't prefer status moves (except Trick)
        score *= 0.1 if @move.move.statusMove? && @move.move.function != "UserTargetSwapItems"
        # Don't prefer moves of certain types
        move_type = @move.rough_type
        # Most unpreferred types are 0x effective against another type, except
        # Fire/Water/Grass
        # TODO: Actually check through the types for 0x instead of hardcoding
        #       them.
        # TODO: Reborn separately doesn't prefer Fire/Water/Grass/Electric, also
        #       with a 0.95x score, meaning Electric can be 0.95x twice. Why are
        #       these four types not preferred? Maybe because they're all not
        #       very effective against Dragon.
        unpreferred_types = [:NORMAL, :FIGHTING, :POISON, :GROUND, :GHOST,
                             :FIRE, :WATER, :GRASS, :ELECTRIC, :PSYCHIC, :DRAGON]
        score *= 0.95 if unpreferred_types.include?(move_type)
        # Don't prefer moves with lower accuracy
        score *= @move.accuracy / 100.0 if @move.accuracy > 0
        # Don't prefer moves with low PP
        score *= 0.9 if @move.move.pp < 6
      end
    end

    # If user is frozen, prefer a move that can thaw the user
    if @trainer.medium_skill? && user_battler.status == :FROZEN
      if @move.move.thawsUser?
        score += 30
      else
        user_battler.eachMove do |m|
          next unless m.thawsUser?
          score -= 30   # Don't prefer this move if user knows another move that thaws
          break
        end
      end
    end

    # If target is frozen, don't prefer moves that could thaw them
    if @trainer.medium_skill? && target_battler.status == :FROZEN
      if @move.rough_type == :FIRE || (Settings::MECHANICS_GENERATION >= 6 && @move.move.thawsUser?)
        score *= 0.1
      end
    end

    # Don't prefer hitting a wild shiny Pokémon
    if @target.wild? && target_battler.shiny?
      score *= 0.15
    end

    # TODO: Discard a move that can be Magic Coated if either opponent has Magic
    #       Bounce.

    # Account for accuracy of move
    accuracy = @move.rough_accuracy
    score *= accuracy / 100.0

    # Prefer flinching external effects (note that move effects which cause
    # flinching are dealt with in the function code part of score calculation)
    if @trainer.medium_skill?
      if !@target.has_active_ability?([:INNERFOCUS, :SHIELDDUST]) &&
         target_battler.effects[PBEffects::Substitute] == 0
        if @move.move.flinchingMove? ||
           (@move.move.damagingMove? &&
           (@user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
           @user.has_active_ability?(:STENCH)))
          score *= 1.3
        end
      end
    end

    # # Adjust score based on how much damage it can deal
    # if move.damagingMove?
    #   score = pbGetMoveScoreDamage(score, move, @user, @target, @trainer.skill)
    # else   # Status moves
    #   # Don't prefer attacks which don't deal damage
    #   score -= 10
    #   # Account for accuracy of move
    #   accuracy = pbRoughAccuracy(move, target)
    #   score *= accuracy / 100.0
    #   score = 0 if score <= 10 && @trainer.high_skill?
    # end
    score = score.to_i
    score = 0 if score < 0
    return score
  end

  #=============================================================================
  # Calculate how much damage a move is likely to do to a given target (as a
  # percentage of the target's current HP)
  #=============================================================================
  def pbGetDamagingMoveBaseScore
    # Don't prefer moves that are ineffective because of abilities or effects
    return 0 if @target.immune_to_move?
    user_battler = @user.battler
    target_battler = @target.battler

    # Calculate how much damage the move will do (roughly)
    calc_damage = @move.rough_damage

    # TODO: Maybe move this check elsewhere? Note that Reborn's base score does
    #       not include this halving, but the predicted damage does.
    # Two-turn attacks waste 2 turns to deal one lot of damage
    calc_damage /= 2 if @move.move.chargingTurnMove?

    # TODO: Maybe move this check elsewhere?
    # Increased critical hit rate
    if @trainer.medium_skill?
      crit_stage = @move.rough_critical_hit_stage
      if crit_stage >= 0
        crit_fraction = (crit_stage > 50) ? 1 : Battle::Move::CRITICAL_HIT_RATIOS[crit_stage]
        crit_mult = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? 0.5 : 1
        calc_damage *= (1 + crit_mult / crit_fraction)
      end
    end

    # Convert damage to percentage of target's remaining HP
    damage_percentage = calc_damage * 100.0 / target_battler.hp

    # Don't prefer weak attacks
#    damage_percentage /= 2 if damage_percentage < 20

    # Prefer damaging attack if level difference is significantly high
#    damage_percentage *= 1.2 if user_battler.level - 10 > target_battler.level

    # Adjust score
    damage_percentage = 110 if damage_percentage > 110   # Treat all lethal moves the same
    damage_percentage += 40 if damage_percentage > 100   # Prefer moves likely to be lethal

    return damage_percentage.to_i
  end

  #=============================================================================
  #
  #=============================================================================
  def pbGetStatusMoveBaseScore
    # TODO: Call @target.immune_to_move? here too, not just for damaging moves
    #       (only if this status move will be affected).

    # TODO: Make sure all status moves are accounted for.
    # TODO: Duplicates in Reborn's AI:
    # "SleepTarget"  Grass Whistle (15), Hypnosis (15), Sing (15),
    #                Lovely Kiss (20), Sleep Powder (20), Spore (60)
    # "PoisonTarget" - Poison Powder (15), Poison Gas (20)
    # "ParalyzeTarget" - Stun Spore (25), Glare (30)
    # "ConfuseTarget" - Teeter Dance (5), Supersonic (10),
    #                   Sweet Kiss (20), Confuse Ray (25)
    # "RaiseUserAttack1" - Howl (10), Sharpen (10), Medicate (15)
    # "RaiseUserSpeed2" - Agility (15), Rock Polish (25)
    # "LowerTargetAttack1" - Growl (10), Baby-Doll Eyes (15)
    # "LowerTargetAccuracy1" - Sand Attack (5), Flash (10), Kinesis (10), Smokescreen (10)
    # "LowerTargetAttack2" - Charm (10), Feather Dance (15)
    # "LowerTargetSpeed2" - String Shot (10), Cotton Spore (15), Scary Face (15)
    # "LowerTargetSpDef2" - Metal Sound (10), Fake Tears (15)
    case @move.move.function
    when "ConfuseTarget",
         "LowerTargetAccuracy1",
         "LowerTargetEvasion1RemoveSideEffects",
         "UserTargetSwapAtkSpAtkStages",
         "UserTargetSwapDefSpDefStages",
         "UserSwapBaseAtkDef",
         "UserTargetAverageBaseAtkSpAtk",
         "UserTargetAverageBaseDefSpDef",
         "SetUserTypesToUserMoveType",
         "SetTargetTypesToWater",
         "SetUserTypesToTargetTypes",
         "SetTargetAbilityToUserAbility",
         "UserTargetSwapAbilities",
         "PowerUpAllyMove",
         "StartWeakenElectricMoves",
         "StartWeakenFireMoves",
         "EnsureNextMoveAlwaysHits",
         "StartNegateTargetEvasionStatStageAndGhostImmunity",
         "StartNegateTargetEvasionStatStageAndDarkImmunity",
         "ProtectUserSideFromPriorityMoves",
         "ProtectUserSideFromMultiTargetDamagingMoves",
         "BounceBackProblemCausingStatusMoves",
         "StealAndUseBeneficialStatusMove",
         "DisableTargetMovesKnownByUser",
         "DisableTargetHealingMoves",
         "SetAttackerMovePPTo0IfUserFaints",
         "UserEnduresFaintingThisTurn",
         "RestoreUserConsumedItem",
         "StartNegateHeldItems",
         "StartDamageTargetEachTurnIfTargetAsleep",
         "HealUserDependingOnUserStockpile",
         "StartGravity",
         "StartUserAirborne",
         "UserSwapsPositionsWithAlly",
         "StartSwapAllBattlersBaseDefensiveStats",
         "RaiseTargetSpDef1",
         "RaiseGroundedGrassBattlersAtkSpAtk1",
         "RaiseGrassBattlersDef1",
         "AddGrassTypeToTarget",
         "TrapAllBattlersInBattleForOneTurn",
         "EnsureNextCriticalHit",
         "UserTargetSwapBaseSpeed",
         "RedirectAllMovesToTarget",
         "TargetUsesItsLastUsedMoveAgain"
      return 5
    when "RaiseUserAttack1",
         "RaiseUserDefense1",
         "RaiseUserDefense1CurlUpUser",
         "RaiseUserCriticalHitRate2",
         "RaiseUserAtkSpAtk1",
         "RaiseUserAtkSpAtk1Or2InSun",
         "RaiseUserAtkAcc1",
         "RaiseTargetRandomStat2",
         "LowerTargetAttack1",
         "LowerTargetDefense1",
         "LowerTargetAccuracy1",
         "LowerTargetAttack2",
         "LowerTargetSpeed2",
         "LowerTargetSpDef2",
         "ResetAllBattlersStatStages",
         "UserCopyTargetStatStages",
         "SetUserTypesBasedOnEnvironment",
         "DisableTargetUsingSameMoveConsecutively",
         "StartTargetCannotUseItem",
         "LowerTargetAttack1BypassSubstitute",
         "LowerTargetAtkSpAtk1",
         "LowerTargetSpAtk1",
         "TargetNextFireMoveDamagesTarget"
      return 10
    when "SleepTarget",
         "SleepTargetIfUserDarkrai",
         "SleepTargetChangeUserMeloettaForm",
         "PoisonTarget",
         "CureUserBurnPoisonParalysis",
         "RaiseUserAttack1",
         "RaiseUserSpDef1PowerUpElectricMove",
         "RaiseUserEvasion1",
         "RaiseUserSpeed2",
         "LowerTargetAttack1",
         "LowerTargetAtkDef1",
         "LowerTargetAttack2",
         "LowerTargetDefense2",
         "LowerTargetSpeed2",
         "LowerTargetSpAtk2IfCanAttract",
         "LowerTargetSpDef2",
         "ReplaceMoveThisBattleWithTargetLastMoveUsed",
         "ReplaceMoveWithTargetLastMoveUsed",
         "SetUserAbilityToTargetAbility",
         "UseMoveTargetIsAboutToUse",
         "UseRandomMoveFromUserParty",
         "StartHealUserEachTurnTrapUserInBattle",
         "HealTargetHalfOfTotalHP",
         "UserFaintsHealAndCureReplacement",
         "UserFaintsHealAndCureReplacementRestorePP",
         "StartSunWeather",
         "StartRainWeather",
         "StartSandstormWeather",
         "StartHailWeather",
         "RaisePlusMinusUserAndAlliesDefSpDef1",
         "LowerTargetSpAtk2",
         "LowerPoisonedTargetAtkSpAtkSpd1",
         "AddGhostTypeToTarget",
         "LowerTargetAtkSpAtk1SwitchOutUser",
         "RaisePlusMinusUserAndAlliesAtkSpAtk1",
         "HealTargetDependingOnGrassyTerrain"
      return 15
    when "SleepTarget",
         "SleepTargetChangeUserMeloettaForm",
         "SleepTargetNextTurn",
         "PoisonTarget",
         "ConfuseTarget",
         "RaiseTargetSpAtk1ConfuseTarget",
         "RaiseTargetAttack2ConfuseTarget",
         "UserTargetSwapStatStages",
         "StartUserSideImmunityToStatStageLowering",
         "SetUserTypesToResistLastAttack",
         "SetTargetAbilityToSimple",
         "SetTargetAbilityToInsomnia",
         "NegateTargetAbility",
         "TransformUserIntoTarget",
         "UseLastMoveUsedByTarget",
         "UseLastMoveUsed",
         "UseRandomMove",
         "HealUserFullyAndFallAsleep",
         "StartHealUserEachTurn",
         "StartPerishCountsForAllBattlers",
         "SwitchOutTargetStatusMove",
         "TrapTargetInBattle",
         "TargetMovesBecomeElectric",
         "NormalMovesBecomeElectric",
         "PoisonTargetLowerTargetSpeed1"
      return 20
    when "BadPoisonTarget",
         "ParalyzeTarget",
         "BurnTarget",
         "ConfuseTarget",
         "AttractTarget",
         "GiveUserStatusToTarget",
         "RaiseUserDefSpDef1",
         "RaiseUserDefense2",
         "RaiseUserSpeed2",
         "RaiseUserSpeed2LowerUserWeight",
         "RaiseUserSpDef2",
         "RaiseUserEvasion2MinimizeUser",
         "RaiseUserDefense3",
         "MaxUserAttackLoseHalfOfTotalHP",
         "UserTargetAverageHP",
         "ProtectUser",
         "DisableTargetLastMoveUsed",
         "DisableTargetStatusMoves",
         "HealUserHalfOfTotalHP",
         "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",
         "HealUserPositionNextTurn",
         "HealUserDependingOnWeather",
         "StartLeechSeedTarget",
         "AttackerFaintsIfUserFaints",
         "UserTargetSwapItems",
         "UserMakeSubstitute",
         "UserAddStockpileRaiseDefSpDef1",
         "RedirectAllMovesToUser",
         "InvertTargetStatStages",
         "HealUserByTargetAttackLowerTargetAttack1",
         "HealUserDependingOnSandstorm"
      return 25
    when "ParalyzeTarget",
         "ParalyzeTargetIfNotTypeImmune",
         "RaiseUserAtkDef1",
         "RaiseUserAtkDefAcc1",
         "RaiseUserSpAtkSpDef1",
         "UseMoveDependingOnEnvironment",
         "UseRandomUserMoveIfAsleep",
         "DisableTargetUsingDifferentMove",
         "SwitchOutUserPassOnEffects",
         "AddSpikesToFoeSide",
         "AddToxicSpikesToFoeSide",
         "AddStealthRocksToFoeSide",
         "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
         "StartSlowerBattlersActFirst",
         "ProtectUserFromTargetingMovesSpikyShield",
         "StartElectricTerrain",
         "StartGrassyTerrain",
         "StartMistyTerrain",
         "StartPsychicTerrain",
         "CureTargetStatusHealUserHalfOfTotalHP"
      return 30
    when "CureUserPartyStatus",
         "RaiseUserAttack2",
         "RaiseUserSpAtk2",
         "RaiseUserSpAtk3",
         "StartUserSideDoubleSpeed",
         "StartWeakenPhysicalDamageAgainstUserSide",
         "StartWeakenSpecialDamageAgainstUserSide",
         "ProtectUserSideFromDamagingMovesIfUserFirstTurn",
         "ProtectUserFromDamagingMovesKingsShield",
         "ProtectUserBanefulBunker"
      return 35
    when "RaiseUserAtkSpd1",
         "RaiseUserSpAtkSpDefSpd1",
         "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",
         "RaiseUserAtk1Spd2",
         "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
      return 40
    when "SleepTarget",
         "SleepTargetChangeUserMeloettaForm",
         "AddStickyWebToFoeSide",
         "StartWeakenDamageAgainstUserSideIfHail"
      return 60
    end
    # "DoesNothingUnusableInGravity",
    # "StartUserSideImmunityToInflictedStatus",
    # "LowerTargetEvasion1",
    # "LowerTargetEvasion2",
    # "StartPreventCriticalHitsAgainstUserSide",
    # "UserFaintsLowerTargetAtkSpAtk2",
    # "FleeFromBattle",
    # "SwitchOutUserStatusMove"
    # "TargetTakesUserItem",
    # "LowerPPOfTargetLastMoveBy4",
    # "StartTargetAirborneAndAlwaysHitByMoves",
    # "TargetActsNext",
    # "TargetActsLast",
    # "ProtectUserSideFromStatusMoves"
    return 0
  end

  #=============================================================================
  # Make the final choice of which move to use depending on the calculated
  # scores for each move. Moves with higher scores are more likely to be chosen.
  #=============================================================================
  def pbChooseMove(choices)
    user_battler = @user.battler

    # Figure out useful information about the choices
    totalScore = 0
    maxScore   = 0
    choices.each do |c|
      totalScore += c[1]
      maxScore = c[1] if maxScore < c[1]
    end

    # Find any preferred moves and just choose from them
    if @trainer.high_skill? && maxScore > 100
      stDev = pbStdDev(choices)
      if stDev >= 40 && pbAIRandom(100) < 90
        preferredMoves = []
        choices.each do |c|
          next if c[1] < 200 && c[1] < maxScore * 0.8
          preferredMoves.push(c)
          preferredMoves.push(c) if c[1] == maxScore   # Doubly prefer the best move
        end
        if preferredMoves.length > 0
          m = preferredMoves[pbAIRandom(preferredMoves.length)]
          PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) prefers #{user_battler.moves[m[0]].name}")
          @battle.pbRegisterMove(user_battler.index, m[0], false)
          @battle.pbRegisterTarget(user_battler.index, m[2]) if m[2] >= 0
          return
        end
      end
    end

    # Decide whether all choices are bad, and if so, try switching instead
    if @trainer.high_skill? && @user.can_switch_lax?
      badMoves = false
      if (maxScore <= 20 && user_battler.turnCount > 2) ||
         (maxScore <= 40 && user_battler.turnCount > 5)
        badMoves = true if pbAIRandom(100) < 80
      end
      if !badMoves && totalScore < 100 && user_battler.turnCount > 1
        badMoves = true
        choices.each do |c|
          next if !user_battler.moves[c[0]].damagingMove?
          badMoves = false
          break
        end
        badMoves = false if badMoves && pbAIRandom(100) < 10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(true)
        if $INTERNAL
          PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) will switch due to terrible moves")
        end
        return
      end
    end

    # If there are no calculated choices, pick one at random
    if choices.length == 0
      PBDebug.log("[AI] #{user_battler.pbThis} (#{user_battler.index}) doesn't want to use any moves; picking one at random")
      user_battler.eachMoveWithIndex do |_m, i|
        next if !@battle.pbCanChooseMove?(user_battler.index, i, false)
        choices.push([i, 100, -1])   # Move index, score, target
      end
      if choices.length == 0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user_battler.index)
      end
    end

    # Randomly choose a move from the choices and register it
    randNum = pbAIRandom(totalScore)
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
