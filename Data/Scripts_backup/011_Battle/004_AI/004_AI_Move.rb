class PokeBattle_AI
  #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================
  def pbChooseMoves(idxBattler)
    user        = @battle.battlers[idxBattler]
    wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
    skill       = 0
    if !wildBattler
      skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
    end
    # Get scores and targets for each move
    # NOTE: A move is only added to the choices array if it has a non-zero
    #       score.
    choices     = []
    user.eachMoveWithIndex do |_m,i|
      next if !@battle.pbCanChooseMove?(idxBattler,i,false)
      if wildBattler
        pbRegisterMoveWild(user,i,choices)
      else
        pbRegisterMoveTrainer(user,i,choices,skill)
      end
    end
    # Figure out useful information about the choices
    totalScore = 0
    maxScore   = 0
    choices.each do |c|
      totalScore += c[1]
      maxScore = c[1] if maxScore<c[1]
    end
    # Log the available choices
    if $INTERNAL
      logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
      choices.each_with_index do |c,i|
        logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2]>=0
        logMsg += ", " if i<choices.length-1
      end
      PBDebug.log(logMsg)
    end
    # Find any preferred moves and just choose from them
    if !wildBattler && skill>=PBTrainerAI.highSkill && maxScore>100
      stDev = pbStdDev(choices)
      if stDev>=40 && pbAIRandom(100)<90
        preferredMoves = []
        choices.each do |c|
          next if c[1]<200 && c[1]<maxScore*0.8
          preferredMoves.push(c)
          preferredMoves.push(c) if c[1]==maxScore   # Doubly prefer the best move
        end
        if preferredMoves.length>0
          m = preferredMoves[pbAIRandom(preferredMoves.length)]
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
          @battle.pbRegisterMove(idxBattler,m[0],false)
          @battle.pbRegisterTarget(idxBattler,m[2]) if m[2]>=0
          return
        end
      end
    end
    # Decide whether all choices are bad, and if so, try switching instead
    if !wildBattler && skill>=PBTrainerAI.highSkill
      badMoves = false
      if (maxScore<=20 && user.turnCount>2) ||
         (maxScore<=40 && user.turnCount>5)
        badMoves = true if pbAIRandom(100)<80
      end
      if !badMoves && totalScore<100 && user.turnCount>1
        badMoves = true
        choices.each do |c|
          next if !user.moves[c[0]].damagingMove?
          badMoves = false
          break
        end
        badMoves = false if badMoves && pbAIRandom(100)<10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(idxBattler,true)
        if $INTERNAL
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
        end
        return
      end
    end
    # If there are no calculated choices, pick one at random
    if choices.length==0
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
      user.eachMoveWithIndex do |_m,i|
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        choices.push([i,100,-1])   # Move index, score, target
      end
      if choices.length==0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user.index)
      end
    end
    # Randomly choose a move from the choices and register it
    randNum = pbAIRandom(totalScore)
    choices.each do |c|
      randNum -= c[1]
      next if randNum>=0
      @battle.pbRegisterMove(idxBattler,c[0],false)
      @battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
      break
    end
    # Log the result
    if @battle.choices[idxBattler][2]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
    end
  end

  #=============================================================================
  # Get scores for the given move against each possible target
  #=============================================================================
  # Wild Pokémon choose their moves randomly.
  def pbRegisterMoveWild(_user,idxMove,choices)
    choices.push([idxMove,100,-1])   # Move index, score, target
  end

  # Trainer Pokémon calculate how much they want to use each of their moves.
  def pbRegisterMoveTrainer(user,idxMove,choices,skill)
    move = user.moves[idxMove]
    target_data = move.pbTarget(user)
    if target_data.num_targets > 1
      # If move affects multiple battlers and you don't choose a particular one
      totalScore = 0
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        score = pbGetMoveScore(move,user,b,skill)
        totalScore += ((user.opposes?(b)) ? score : -score)
      end
      choices.push([idxMove,totalScore,-1]) if totalScore>0
    elsif target_data.num_targets == 0
      # If move has no targets, affects the user, a side or the whole field
      score = pbGetMoveScore(move,user,user,skill)
      choices.push([idxMove,score,-1]) if score>0
    else
      # If move affects one battler and you have to choose which one
      scoresAndTargets = []
      @battle.eachBattler do |b|
        next if !@battle.pbMoveCanTarget?(user.index,b.index,target_data)
        next if target_data.targets_foe && !user.opposes?(b)
        score = pbGetMoveScore(move,user,b,skill)
        scoresAndTargets.push([score,b.index]) if score>0
      end
      if scoresAndTargets.length>0
        # Get the one best target for the move
        scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
        choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
      end
    end
  end

  #=============================================================================
  # Get a score for the given move being used against the given target
  #=============================================================================
  def pbGetMoveScore(move,user,target,skill=100)
    skill = PBTrainerAI.minimumSkill if skill<PBTrainerAI.minimumSkill
    score = 100
    score = pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    # A score of 0 here means it absolutely should not be used
    return 0 if score<=0
    if skill>=PBTrainerAI.mediumSkill
      # Prefer damaging moves if AI has no more Pokémon or AI is less clever
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        if !(skill>=PBTrainerAI.highSkill && @battle.pbAbleNonActiveCount(target.idxOwnSide)>0)
          if move.statusMove?
            score /= 1.5
          elsif target.hp<=target.totalhp/2
            score *= 1.5
          end
        end
      end
      # Don't prefer attacking the target if they'd be semi-invulnerable
      if skill>=PBTrainerAI.highSkill && move.accuracy>0 &&
         (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
        miss = true
        miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
        if miss && pbRoughStat(user,:SPEED,skill)>pbRoughStat(target,:SPEED,skill)
          # Knows what can get past semi-invulnerability
          if target.effects[PBEffects::SkyDrop]>=0
            miss = false if move.hitsFlyingTargets?
          else
            if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
              miss = false if move.hitsFlyingTargets?
            elsif target.inTwoTurnAttack?("0CA")          # Dig
              miss = false if move.hitsDiggingTargets?
            elsif target.inTwoTurnAttack?("0CB")          # Dive
              miss = false if move.hitsDivingTargets?
            end
          end
        end
        score -= 80 if miss
      end
      # Pick a good move for the Choice items
      if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
        if move.baseDamage>=60;     score += 60
        elsif move.damagingMove?;   score += 30
        elsif move.function=="0F2"; score += 70   # Trick
        else;                       score -= 60
        end
      end
      # If user is asleep, prefer moves that are usable while asleep
      if user.status == :SLEEP && !move.usableWhenAsleep?
        user.eachMove do |m|
          next unless m.usableWhenAsleep?
          score -= 60
          break
        end
      end
      # If user is frozen, prefer a move that can thaw the user
      if user.status == :FROZEN
        if move.thawsUser?
          score += 40
        else
          user.eachMove do |m|
            next unless m.thawsUser?
            score -= 60
            break
          end
        end
      end
      # If target is frozen, don't prefer moves that could thaw them
      if target.status == :FROZEN
        user.eachMove do |m|
          next if m.thawsUser?
          score -= 60
          break
        end
      end
    end
    # Adjust score based on how much damage it can deal
    if move.damagingMove?
      score = pbGetMoveScoreDamage(score,move,user,target,skill)
    else   # Status moves
      # Don't prefer attacks which don't deal damage
      score -= 10
      # Account for accuracy of move
      accuracy = pbRoughAccuracy(move,user,target,skill)
      score *= accuracy/100.0
      score = 0 if score<=10 && skill>=PBTrainerAI.highSkill
    end
    score = score.to_i
    score = 0 if score<0
    return score
  end

  #=============================================================================
  # Add to a move's score based on how much damage it will deal (as a percentage
  # of the target's current HP)
  #=============================================================================
  def pbGetMoveScoreDamage(score,move,user,target,skill)
    # Don't prefer moves that are ineffective because of abilities or effects
    return 0 if score<=0 || pbCheckMoveImmunity(score,move,user,target,skill)
    # Calculate how much damage the move will do (roughly)
    baseDmg = pbMoveBaseDamage(move,user,target,skill)
    realDamage = pbRoughDamage(move,user,target,skill,baseDmg)
    # Account for accuracy of move
    accuracy = pbRoughAccuracy(move,user,target,skill)
    realDamage *= accuracy/100.0
    # Two-turn attacks waste 2 turns to deal one lot of damage
    if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
      realDamage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
    end
    # Prefer flinching external effects (note that move effects which cause
    # flinching are dealt with in the function code part of score calculation)
    if skill>=PBTrainerAI.mediumSkill
      if !target.hasActiveAbility?(:INNERFOCUS) &&
          !target.hasActiveAbility?(:SHIELDDUST) &&
          target.effects[PBEffects::Substitute]==0
        canFlinch = false
        if move.canKingsRock? && user.hasActiveItem?([:KINGSROCK,:RAZORFANG])
          canFlinch = true
        end
        if user.hasActiveAbility?(:STENCH) && !move.flinchingMove?
          canFlinch = true
        end
        realDamage *= 1.3 if canFlinch
      end
    end
    # Convert damage to percentage of target's remaining HP
    damagePercentage = realDamage*100.0/target.hp
    # Don't prefer weak attacks
#    damagePercentage /= 2 if damagePercentage<20
    # Prefer damaging attack if level difference is significantly high
    damagePercentage *= 1.2 if user.level-10>target.level
    # Adjust score
    damagePercentage = 120 if damagePercentage>120   # Treat all lethal moves the same
    damagePercentage += 40 if damagePercentage>100   # Prefer moves likely to be lethal
    score += damagePercentage.to_i
    return score
  end
end
