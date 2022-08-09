<<<class PokeBattle_AI
  #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================
  def pbChooseMove(choices)
    # Figure out useful information about the choices
    totalScore = 0
    maxScore   = 0
    choices.each do |c|
      totalScore += c[1]
      maxScore = c[1] if maxScore < c[1]
    end

    # Find any preferred moves and just choose from them
    if skill_check(AILevel.high) && maxScore > 100
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
          PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) prefers #{@user.moves[m[0]].name}")
          @battle.pbRegisterMove(@user.index, m[0], false)
          @battle.pbRegisterTarget(@user.index, m[2]) if m[2] >= 0
          return
        end
      end
    end

    # Decide whether all choices are bad, and if so, try switching instead
    if !@wildBattler && skill_check(AILevel.high)
      badMoves = false
      if (maxScore <= 20 && @user.turnCount > 2) ||
         (maxScore <= 40 && @user.turnCount > 5)
        badMoves = true if pbAIRandom(100) < 80
      end
      if !badMoves && totalScore < 100 && @user.turnCount > 1
        badMoves = true
        choices.each do |c|
          next if !@user.moves[c[0]].damagingMove?
          badMoves = false
          break
        end
        badMoves = false if badMoves && pbAIRandom(100) < 10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(true)
        if $INTERNAL
          PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) will switch due to terrible moves")
        end
        return
      end
    end

    # If there are no calculated choices, pick one at random
    if choices.length == 0
      PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) doesn't want to use any moves; picking one at random")
      @user.eachMoveWithIndex do |_m, i|
        next if !@battle.pbCanChooseMove?(@user.index, i, false)
        choices.push([i, 100, -1])   # Move index, score, target
      end
      if choices.length == 0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(@user.index)
      end
    end

    # Randomly choose a move from the choices and register it
    randNum = pbAIRandom(totalScore)
    choices.each do |c|
      randNum -= c[1]
      next if randNum >= 0
      @battle.pbRegisterMove(@user.index, c[0], false)
      @battle.pbRegisterTarget(@user.index, c[2]) if c[2] >= 0
      break
    end

    # Log the result
    if @battle.choices[@user.index][2]
      PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) will use #{@battle.choices[@user.index][2].name}")
    end
  end

  #=============================================================================
  # Get scores for the user's moves (done before any action is assessed)
  # NOTE: A move is only added to the choices array if it has a non-zero score.
  #=============================================================================
  def pbGetMoveScores
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
    @user.eachMoveWithIndex do |_m, i|
      next if !@battle.pbCanChooseMove?(@user.index, i, false)
      if @wildBattler
        pbRegisterMoveWild(i, choices)
      else
        pbRegisterMoveTrainer(i, choices)
      end
    end
    # Log the available choices
    if $INTERNAL
      logMsg = "[AI] Move choices for #{@user.pbThis(true)} (#{@user.index}): "
      choices.each_with_index do |c, i|
        logMsg += "#{@user.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2] >= 0
        logMsg += ", " if i < choices.length-1
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
    score = 100
    # Doubly prefer one of the user's moves (the choice is random but consistent
    # and does not correlate to any other property of the user)
    score *= 2 if @user.pokemon.personalID % @user.moves.length == idxMove
    choices.push([idxMove, score, -1])   # Move index, score, target
  end

  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbRegisterMoveTrainer(idxMove, choices)
    move = @user.moves[idxMove]
    targetType = move.pbTarget(@user)
    # TODO: Alter targetType if user has Protean and move is Curse.
    if PBTargets.multipleTargets?(targetType)
      # Move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(@user.index, b.index, targetType)
        score = pbGetMoveScore(move, b)
        totalScore += ((@user.opposes?(b)) ? score : -score)
      end
      choices.push([idxMove, totalScore, -1]) if totalScore > 0
    elsif PBTargets.noTargets?(targetType)
      # Move has no targets, affects the user, a side or the whole field
      score = pbGetMoveScore(move)
      choices.push([idxMove, score, -1]) if score > 0
    else
      # Move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(@user.index, b.index, targetType)
        next if PBTargets.canChooseFoeTarget?(targetType) && !@user.opposes?(b)
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
  # Set some class variables for the move being assessed
  #=============================================================================
  def set_up_move_check(move, target)
    @move   = move
    @target = target
    # TODO: Calculate pbRoughType once here.
    # Determine whether user or target is faster, and store that result so it
    # doesn't need recalculating
    if @target
      user_speed   = pbRoughStat(@user, PBStats::SPEED)
      target_speed = pbRoughStat(@target, PBStats::SPEED)
      @user_faster = (user_speed > target_speed) ^ (@battle.field.effects[PBEffects::TrickRoom] > 0)
    else
      @user_faster = false   # Won't be used if there is no target
    end
  end

  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  def pbGetMoveScore(move, target = nil)
    set_up_move_check(move, target)

    # Get the base score for the move
    if @move.damagingMove?
      # Is also the predicted damage amount as a percentage of target's current HP
      score = pbGetDamagingMoveBaseScore
    else   # Status moves
      # Depends on the move's effect
      score = pbGetStatusMoveBaseScore
    end
    # Modify the score according to the move's effect
    score = pbGetMoveScoreFunctions(score)

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
    if skill_check(AILevel.high) && @move.danceMove? && @target.hasActiveAbility?(:DANCER)
      score /= 2
    end

    # TODO: Check memory for whether target has previously used Ion Deluge, and
    #       don't prefer move if it's Normal-type and target is immune because
    #       of its ability (Lightning Rod, etc.).

    # TODO: Discard move if it can be redirected by a non-target's ability
    #       (Lightning Rod/Storm Drain). Include checking for a previous use of
    #       Ion Deluge and this move being Normal-type.
    # => If non-target is a user's ally, don't prefer move (rather than discarding
    #    it)

    # TODO: Discard move if it's sound-based and user has been Throat Chopped.
    #       Don't prefer move if user hasn't been Throat Chopped but target has
    #       previously used Throat Chop. The first part of this would probably
    #       go elsewhere (damage calc?).

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


    if skill_check(AILevel.medium)

      # Prefer damaging moves if AI has no more Pokémon or AI is less clever
      if @battle.pbAbleNonActiveCount(@user.idxOwnSide) == 0
        if !(skill_check(AILevel.high) && @battle.pbAbleNonActiveCount(@target.idxOwnSide) > 0)
          if @move.statusMove?
            score *= 0.9
          elsif @target.hp <= @target.totalhp / 2
            score *= 1.1
          end
        end
      end

      # Don't prefer attacking the target if they'd be semi-invulnerable
      if skill_check(AILevel.high) && @move.accuracy > 0 && @user_faster &&
         (@target.semiInvulnerable? || @target.effects[PBEffects::SkyDrop] >= 0)
        miss = true
        miss = false if @user.hasActiveAbility?(:NOGUARD)
        miss = false if skill_check(AILevel.best) && @target.hasActiveAbility?(:NOGUARD)
        if skill_check(AILevel.best) && miss
          # Knows what can get past semi-invulnerability
          if @target.effects[PBEffects::SkyDrop] >= 0
             @target.effects[PBEffects::SkyDrop] != @user.index
            miss = false if @move.hitsFlyingTargets?
          else
            if @target.inTwoTurnAttack?("0C9", "0CC", "0CE")   # Fly, Bounce, Sky Drop
              miss = false if @move.hitsFlyingTargets?
            elsif @target.inTwoTurnAttack?("0CA")          # Dig
              miss = false if @move.hitsDiggingTargets?
            elsif @target.inTwoTurnAttack?("0CB")          # Dive
              miss = false if @move.hitsDivingTargets?
            end
          end
        end
        score = 0 if miss
      end

      # Pick a good move for the Choice items
      if @user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF])
        # Really don't prefer status moves (except Trick)
        score *= 0.1 if @move.statusMove? && @move.function != "0F2"   # Trick
        # Don't prefer moves of certain types
        move_type = pbRoughType(@move)
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
        score *= 0.9 if @move.pp < 6
      end

      # If user is asleep, don't prefer moves that can't be used while asleep
      if skill_check(AILevel.medium) && @user.asleep? &&
         @user.statusCount > 1 && !@move.usableWhenAsleep?
        score *= 0.2
      end

      # If user is frozen, prefer a move that can thaw the user
      if skill_check(AILevel.medium) && @user.status == PBStatuses::FROZEN
        if @move.thawsUser?
          score += 30
        else
          @user.eachMove do |m|
            next unless m.thawsUser?
            score *= 0   # Discard this move if user knows another move that thaws
            break
          end
        end
      end

      # If target is frozen, don't prefer moves that could thaw them
      if @target.status == PBStatuses::FROZEN
        if pbRoughType(@move) == :FIRE || (NEWEST_BATTLE_MECHANICS && @move.thawsUser?)
          score *= 0.1
        end
      end
    end

    # Don't prefer hitting a wild shiny Pokémon
    if @battle.wildBattle? && @target.opposes? && @target.shiny?
      score *= 0.15
    end

    # TODO: Discard a move that can be Magic Coated if either opponent has Magic
    #       Bounce.

    # Account for accuracy of move
    accuracy = pbRoughAccuracy(@move, @target)
    score *= accuracy / 100.0

    # Prefer flinching external effects (note that move effects which cause
    # flinching are dealt with in the function code part of score calculation)
    if skill_check(AILevel.medium)
      if !@target.hasActiveAbility?([:INNERFOCUS, :SHIELDDUST]) &&
         @target.effects[PBEffects::Substitute] == 0
        can_flinch = false
        if @move.canKingsRock? && @user.hasActiveItem?([:KINGSROCK, :RAZORFANG])
          can_flinch = true
        elsif @user.hasActiveAbility?(:STENCH) && !@move.flinchingMove?
          can_flinch = true
        end
        calc_damage *= 1.3 if can_flinch
      end
    end

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
    return 0 if pbCheckMoveImmunity(@move, @target)

    # Calculate how much damage the move will do (roughly)
    base_damage = pbMoveBaseDamage(@move, @target)
    calc_damage = pbRoughDamage(@move, @target, base_damage)

    # TODO: Maybe move this check elsewhere? Note that Reborn's base score does
    #       not include this halving, but the predicted damage does.
    # Two-turn attacks waste 2 turns to deal one lot of damage
    calc_damage /= 2 if @move.chargingTurnMove?

    # TODO: Maybe move this check elsewhere?
    # Increased critical hit rate
    if skill_check(AILevel.medium)
      crit_stage = pbRoughCriticalHitStage(@move, @target)
      if crit_stage >= 0
        crit_fraction = (crit_stage > 50) ? 1 : PokeBattle_Move::CRITICAL_HIT_RATIOS[crit_stage]
        crit_mult = (NEWEST_BATTLE_MECHANICS) ? 0.5 : 1
        calc_damage *= (1 + crit_mult / crit_fraction)
      end
    end

    # Convert damage to percentage of target's remaining HP
    damage_percentage = calc_damage * 100.0 / @target.hp

    # Don't prefer weak attacks
#    damage_percentage /= 2 if damage_percentage < 20

    # Prefer damaging attack if level difference is significantly high
#    damage_percentage *= 1.2 if @user.level - 10 > @target.level

    # Adjust score
    damage_percentage = 110 if damage_percentage > 110   # Treat all lethal moves the same
    damage_percentage += 40 if damage_percentage > 100   # Prefer moves likely to be lethal

    score = damage_percentage.to_i
    return score
  end

  def pbGetStatusMoveBaseScore
    # TODO: Call pbCheckMoveImmunity here too, not just for damaging moves
    #       (only if this status move will be affected).

    # TODO: Make sure all status moves are accounted for.
    # TODO: Duplicates:
    # 003 cause sleep - Dark Void (15), Grass Whistle (15), Hypnosis (15), Sing (15),
    #                   Lovely Kiss (20), Sleep Powder (20), Spore (60)
    # 005 poisons - Poison Powder (15), Poison Gas (20)
    # 007 paralyses - Stun Spore (25), Glare (30), Thunder Wave (30)
    # 013 confuses - Teeter Dance (5), Supersonic (10), Sweet Kiss (20), Confuse Ray (25)
    # 01C user's Atk +1 - Howl (10), Sharpen (10), Medicate (15)
    # 030 user's Spd +2 - Agility (15), Rock Polish (25)
    # 042 target Atk -1 - Growl (10), Baby-Doll Eyes (15)
    # 047 target acc -1 - Sand Attack (5), Flash (10), Kinesis (10), Smokescreen (10)
    # 04B target Atk -2 - Charm (10), Feather Dance (15)
    # 04D target Spd -2 - String Shot (10), Cotton Spore (15), Scary Face (15)
    # 04F target SpDef -2 - Metal Sound (10), Fake Tears (15)
    case @move.function
    when "013", "047", "049", "052", "053", "057", "058", "059", "05E", "061",
         "062", "066", "067", "09C", "09D", "09E", "0A6", "0A7", "0A8", "0AB",
         "0AC", "0B1", "0B2", "0B8", "0BB", "0E6", "0E8", "0F6", "0F9", "10F",
         "114", "118", "119", "120", "124", "138", "13E", "13F", "143", "152",
         "15E", "161", "16A", "16B"
      return 5
    when "013", "01C", "01D", "01E", "023", "027", "028", "029", "037", "042",
         "043", "047", "04B", "04D", "04F", "051", "055", "060", "0B7", "0F8",
         "139", "13A", "13C", "148"
      return 10
    when "003", "005", "018", "01C", "021", "022", "030", "042", "04A", "04B",
         "04C", "04D", "04E", "04F", "05C", "05D", "065", "0B0", "0B5", "0DB",
         "0DF", "0E3", "0E4", "0FF", "100", "101", "102", "137", "13D", "140",
         "142", "151", "15C", "16E"
      return 15
    when "003", "004", "005", "013", "040", "041", "054", "056", "05F", "063",
         "064", "068", "069", "0AE", "0AF", "0B6", "0D9", "0DA", "0E5", "0EB",
         "0EF", "145", "146", "159"
      return 20
    when "006", "007", "00A", "013", "016", "01B", "02A", "02F", "030", "031",
         "033", "034", "038", "03A", "05A", "0AA", "0B9", "0BA", "0D5", "0D6",
         "0D7", "0D8", "0DC", "0E7", "0F2", "10C", "112", "117", "141", "160",
         "16D"
      return 25
    when "007", "024", "025", "02C", "0B3", "0B4", "0BC", "0ED", "103", "104",
         "105", "10D", "11F", "14C", "154", "155", "156", "15B", "173"
      return 30
    when "019", "02E", "032", "039", "05B", "0A2", "0A3", "149", "14B", "168"
      return 35
    when "026", "02B", "035", "036", "14E"
      return 40
    when "003", "153", "167"
      return 60
    end
    # "001", "01A", "048", "0A1", "0E2", "0EA", "0F3", "10E", "11A", "11D",
    # "11E", "14A"
    return 0
  end
end
