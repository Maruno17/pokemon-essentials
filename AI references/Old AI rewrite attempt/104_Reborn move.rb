class PokeBattle_Battle
  attr_accessor :scores   # Array of move scores (even zeroes), corresponding to battler.moves array
  attr_accessor :targets   # Array containing best idxBattler to target for each move, corresponding to battler.moves array
  attr_accessor :myChoices   # Array containing idxMoves that can be used

  ################################################################################
  # Choose a move to use.
  # Called before any decisions are made.
  ################################################################################
  def pbBuildMoveScores(index) #Generates an array of movescores for decisions
    # Ally targetting stuff marked with ###
    attacker=@battlers[index]
    @scores=[0,0,0,0]
    @targets=nil
    @myChoices=[]
    totalscore=0
    target=-1
    skill=0
    wildbattle=!@opponent && pbIsOpposing?(index)


=begin
    if wildbattle # If wild battle
      preference = attacker.personalID % 16   # Doesn't correlate to any property of the attacker, but is consistent
      preference = preference % 4
      for i in 0...4
        if pbCanChooseMove?(index,i,false)
          @scores[i]=100
          if preference == i # for personality
            @scores[i]+=100
          end
          @myChoices.push(i)
        end
      end
      return
    else   # Trainer battle
=end


      skill=pbGetOwner(attacker.index).skill || 0

      opponent=attacker.pbOppositeOpposing

      fastermon = (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
      if fastermon && opponent
        PBDebug.log(sprintf("AI Pokemon #{attacker.name} is faster than #{opponent.name}.")) if $INTERNAL
      elsif opponent
        PBDebug.log(sprintf("Player Pokemon #{opponent.name} is faster than #{attacker.name}.")) if $INTERNAL
      end

      #if @doublebattle && !opponent.isFainted? && !opponent.pbPartner.isFainted?
      if @doublebattle && ((!opponent.isFainted? && !opponent.pbPartner.isFainted?) || !attacker.pbPartner.isFainted?)

        # Choose a target and move.  Also care about partner.
        otheropp=opponent.pbPartner
        fastermon = (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
        if fastermon && otheropp
          PBDebug.log(sprintf("AI Pokemon #{attacker.name} is faster than #{otheropp.name}.")) if $INTERNAL
        elsif otheropp
          PBDebug.log(sprintf("Player Pokemon #{otheropp.name} is faster than #{attacker.name}.")) if $INTERNAL
        end
        notopp=attacker.pbPartner ###

        scoresAndTargets=[]   # [tiebreaker value, idxMove, score, target]
        @targets=[-1,-1,-1,-1]
        maxscore1=0
        maxscore2=0
        totalscore1=0
        totalscore2=0
        baseDamageArray=[]
        baseDamageArray2=[]
        baseDamageArray3=[] ###

        # For each move in turn, get probable percentage damage dealt against
        # each opponent and against partner
        for j in 0...4
          next if attacker.moves[j].id < 1
          # check attacker.moves[j].basedamage and if this is 0 instead check the status method
          dmgValue = pbRoughDamage(attacker.moves[j],attacker,opponent,skill,attacker.moves[j].basedamage)
          if attacker.moves[j].basedamage!=0
            if opponent.hp==0
              dmgPercent = 0
            else
              dmgPercent = (dmgValue*100)/(opponent.hp)
              dmgPercent = 110 if dmgPercent > 110
            end
          else
            dmgPercent = pbStatusDamage(attacker.moves[j])
          end
          baseDamageArray.push(dmgPercent)

          #Second opponent
          dmgValue2 = pbRoughDamage(attacker.moves[j],attacker,otheropp,skill,attacker.moves[j].basedamage)
          if attacker.moves[j].basedamage!=0
            if otheropp.hp==0
              dmgPercent2=0
            else
              dmgPercent2 = (dmgValue2*100)/(otheropp.hp)
              dmgPercent2 = 110 if dmgPercent2 > 110
            end
          else
            dmgPercent2 = pbStatusDamage(attacker.moves[j])
          end
          baseDamageArray2.push(dmgPercent2)

          #Partner ###
          dmgValue3 = pbRoughDamage(attacker.moves[j],attacker,notopp,skill,attacker.moves[j].basedamage)
          if attacker.moves[j].basedamage!=0
            if notopp.hp==0
              dmgPercent3=0
            else
              dmgPercent3 = (dmgValue3*100)/(notopp.hp)
              dmgPercent3 = 110 if dmgPercent3 > 110
            end
          else
            dmgPercent3 = pbStatusDamage(attacker.moves[j])
          end
          baseDamageArray3.push(dmgPercent3)
        end

        # For each move in turn, calculate final score for each target, and modify
        # scores if the move hits multiple targets
        # Then push results to scoresAndTargets
        for i in 0...4
          if pbCanChooseMove?(index,i,false)
            score1=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill,baseDamageArray[i],baseDamageArray,i)
            score2=pbGetMoveScore(attacker.moves[i],attacker,otheropp,skill,baseDamageArray2[i],baseDamageArray2,i)
            totalscore = score1+score2
            if (attacker.moves[i].target&0x08)!=0 # Targets all users
              score1=totalscore # Consider both scores as it will hit BOTH targets
              score2=totalscore
              if attacker.pbPartner.isFainted? || (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::TELEPATHY) # No partner
                score1*=1.66
                score2*=1.66
              else
                # If this move can also target the partner, get the partner's
                # score too
                v=pbRoughDamage(attacker.moves[i],attacker,attacker.pbPartner,skill,attacker.moves[i].basedamage)
                p=(v*100)/(attacker.pbPartner.hp)
                s=pbGetMoveScore(attacker.moves[i],attacker,attacker.pbPartner,skill,p)
                s=110 if s>110
                if !attacker.pbPartner.abilitynulled &&
                   (attacker.moves[i].type == PBTypes::FIRE && attacker.pbPartner.ability == PBAbilities::FLASHFIRE) ||
                   (attacker.moves[i].type == PBTypes::WATER && [PBAbilities::WATERABSORB, PBAbilities::STORMDRAIN, PBAbilities::DRYSKIN].include?(attacker.pbPartner.ability)) ||
                   (attacker.moves[i].type == PBTypes::GRASS && attacker.pbPartner.ability == PBAbilities::SAPSIPPER) ||
                   (attacker.moves[i].type == PBTypes::ELECTRIC && [PBAbilities::VOLTABSORB, PBAbilities::LIGHTNINGROD, PBAbilities::MOTORDRIVE].include?(attacker.pbPartner.ability))
                  score1*=2.00
                  score2*=2.00
                else
                  if (attacker.pbPartner.hp.to_f)/attacker.pbPartner.totalhp>0.10 || ((attacker.pbPartner.pbSpeed<attacker.pbSpeed) ^ (@trickroom!=0))
                    s = 100-s
                    s=0 if s<0
                    s/=100.0
                    s * 0.5 # multiplier to control how much to arbitrarily care about hitting partner; lower cares more
                    if (attacker.pbPartner.pbSpeed<attacker.pbSpeed) ^ (@trickroom!=0)
                      s * 0.5 # care more if we're faster and would knock it out before it attacks
                    end
                    score1*=s
                    score2*=s
                  end
                end
              end
              score1=score1.to_i
              score2=score2.to_i
              PBDebug.log(sprintf("%s: Final Score after Multi-Target Adjustment: %d",PBMoves.getName(attacker.moves[i].id),score1))
              PBDebug.log(sprintf(""))
            end
            if attacker.moves[i].target==PBTargets::AllOpposing # Consider both scores as it will hit BOTH targets
              totalscore = score1+score2
              score1=totalscore
              score2=totalscore
              PBDebug.log(sprintf("%s: Final Score after Multi-Target Adjustment: %d",PBMoves.getName(attacker.moves[i].id),score1))
              PBDebug.log(sprintf(""))
            end
            @myChoices.push(i)
            scoresAndTargets.push([i*2,i,score1,opponent.index])
            scoresAndTargets.push([i*2+1,i,score2,otheropp.index])
          else
            scoresAndTargets.push([i*2,i,-1,opponent.index])
            scoresAndTargets.push([i*2+1,i,-1,otheropp.index])
          end
        end

        # Check certain moves for use on partner instead of opponent
        for i in 0...4 ### This whole bit -
          if pbCanChooseMove?(index,i,false)
            movecode = attacker.moves[i].function
            if movecode == 0xDF || movecode == 0x63 || movecode == 0x67 || #Heal Pulse, Simple Beam, Skill Swap,
               movecode == 0xA0 || movecode == 0xC1 || movecode == 0x142 || #Frost Breath, Beat Up, Topsy-Turvy,
               movecode == 0x162 || movecode == 0x164 || movecode == 0x167 || #Floral Healing, Instruct, Pollen Puff,
               movecode == 0x169 || movecode == 0x170 || movecode == 0x55 || #Purify, Spotlight, Psych Up,
               movecode == 0x40 || movecode == 0x41 || movecode == 0x66  #Swagger, Flatter, Entrainment
              partnerscore=pbGetMoveScore(attacker.moves[i],attacker,notopp,skill,baseDamageArray3[i],baseDamageArray3,i)
              PBDebug.log(sprintf("%s: Score for using on partner: %d",PBMoves.getName(attacker.moves[i].id),partnerscore))
              PBDebug.log(sprintf(""))
              scoresAndTargets.push([i*10,i,partnerscore,notopp.index])
            end
          end
        end

        # Sort scores for all possible targets of this move
        scoresAndTargets.sort!{|a,b|
          if a[2]==b[2] # if scores are equal
            a[0]<=>b[0] # sort by index (for stable comparison)
          else
            b[2]<=>a[2]
          end
        }

        # Push this move's score to @scores (one per move) and usable move idxMove to @myChoices
        # Also push move's target to @targets
        # Ends up with the highest scoring move/target combo, or a 50/50 choice
        # if two combos have the same score (or 25/25/50 if three combos have equal scores, etc.)
        for i in 0...scoresAndTargets.length
          idx=scoresAndTargets[i][1]
          thisScore=scoresAndTargets[i][2]
          if thisScore>0 || thisScore==-1
            if scores[idx]==0 || (scores[idx]==thisScore && pbAIRandom(10)<5) || (scores[idx] < thisScore)
           #    (scores[idx]!=thisScore && pbAIRandom(10)<3))
              @scores[idx]=thisScore
              @targets[idx]=scoresAndTargets[i][3]
            end
          end
        end
      else

        # Choose a move. There is only 1 opposing Pokémon and no partner.
        if @doublebattle && opponent.isFainted?
          opponent=opponent.pbPartner
        end
        baseDamageArray=[]
        baseDamageArrayAdj=[]

        # For each move in turn, get probable percentage damage dealt against opponent
        for j in 0...4
          next if attacker.moves[j].id < 1
          # check attacker.moves[j].basedamage and if this is 0 instead check the status method
          dmgValue = pbRoughDamage(attacker.moves[j],attacker,opponent,skill,attacker.moves[j].basedamage)
          if attacker.moves[j].basedamage!=0   # Damaging moves
            # Turn probable damage dealt into a percentage of the target's current HP
            dmgPercent = (dmgValue*100)/(opponent.hp)
            dmgPercent = 110 if dmgPercent > 110   # Cap at 110% of target's HP
            # Halve the effective damage for two-turn moves (but not Hyper Beam)
            if attacker.moves[j].function == 0x115 || attacker.moves[j].function == 0xC3 ||
               attacker.moves[j].function == 0xC4 || attacker.moves[j].function == 0xC5 ||
               attacker.moves[j].function == 0xC6 || attacker.moves[j].function == 0xC7 ||
               attacker.moves[j].function == 0xC8
              dmgPercentAdj = (dmgPercent * 0.5)
            else
              dmgPercentAdj = dmgPercent
            end
          else   # Status moves
            dmgPercent = pbStatusDamage(attacker.moves[j])
            dmgPercentAdj = dmgPercent
          end
          baseDamageArray.push(dmgPercent)
          baseDamageArrayAdj.push(dmgPercentAdj)   # Adjusted percentage due to two-turn attacks
        end

        # Push all scores to @scores (one per move) and usable move idxMoves to @myChoices
        for i in 0...4
          if pbCanChooseMove?(index,i,false)
            @scores[i]=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill,baseDamageArray[i],baseDamageArrayAdj,i)
            @myChoices.push(i)
          else
            @scores[i] = -1
          end
        end

      end
#    end
  end

  ################################################################################
  # Primary method for deciding which move to use.
  ################################################################################
  def pbChooseMoves(index)
    maxscore=0
    totalscore=0
    attacker=@battlers[index]
    skill=pbGetOwner(attacker.index).skill rescue 0
    wildbattle=!@opponent && pbIsOpposing?(index)

    # Calculate highest score and sum of scores
    for i in 0...4
      #next if scores[i] == -1
      @scores[i]=0 if @scores[i]<0
      maxscore=@scores[i] if @scores[i]>maxscore
      totalscore+=@scores[i]
    end

    # Minmax choices depending on AI (reduce the scores for moves that are already significantly lower than the highest score)
    if !wildbattle && skill>=PBTrainerAI.mediumSkill
      threshold=(skill>=PBTrainerAI.bestSkill) ? 1.5 : (skill>=PBTrainerAI.highSkill) ? 2 : 3
      newscore=(skill>=PBTrainerAI.bestSkill) ? 5 : (skill>=PBTrainerAI.highSkill) ? 10 : 15
      for i in 0...@scores.length
        if @scores[i]>newscore && @scores[i]*threshold<maxscore
          totalscore-=(@scores[i]-newscore)
          @scores[i]=newscore
        end
      end
    end

    # Debug logging
    if $INTERNAL
      x="[#{attacker.pbThis}: "
      j=0
      for i in 0...4
        if attacker.moves[i].id!=0
          x+=", " if j>0
          x+=PBMoves.getName(attacker.moves[i].id)+"="+@scores[i].to_s
          j+=1
        end
      end
      x+="]"
      PBDebug.log(x)
    end

    # Decide on a move whose score is at least 0.95 times the highest score
    # If there are multiple moves with such high scores, randomly choose one (each
    # is equally weighted apart from ones that equal the max score, which are each
    # twice as likely to be chosen)
    if !wildbattle #&& maxscore>100
      stdev=pbStdDev(@scores)
      preferredMoves=[]
      for i in 0...4
        if attacker.moves[i].id!=0 && (@scores[i] >= (maxscore*0.95)) && pbCanChooseMove?(index,i,false)
          preferredMoves.push(i)
          preferredMoves.push(i) if @scores[i]==maxscore # Doubly prefer the best move
        end
      end
      if preferredMoves.length>0
        i=preferredMoves[pbAIRandom(preferredMoves.length)]
        PBDebug.log("[Prefer "+PBMoves.getName(attacker.moves[i].id)+"]") if $INTERNAL
        pbRegisterMove(index,i,false)
        target=@targets[i] if @targets
        if @doublebattle && target && target>=0
          pbRegisterTarget(index,target)
        end
        return
      end
    end



    # Trainer battles should have chosen a move by now. The below code is for wild Pokémon only.
    PBDebug.log("If this battle is not wild, something has gone wrong in scoring moves (no preference chosen).") if $INTERNAL

    # n/a
    if !wildbattle && attacker.turncount
      badmoves=false
      if ((maxscore<=20 && attacker.turncount>2) ||
         (maxscore<=30 && attacker.turncount>5)) && pbAIRandom(10)<8
        badmoves=true
      end
      if totalscore<100 && attacker.turncount>1
        badmoves=true
        movecount=0
        for i in 0...4
          if attacker.moves[i].id!=0
            if @scores[i]>0 && attacker.moves[i].basedamage>0
              badmoves=false
            end
            movecount+=1
          end
        end
        badmoves=badmoves && pbAIRandom(10)!=0
      end
    end

    # Choose a move (wild Pokémon only), either at random or with scores as weights
    if maxscore<=0
      # If all scores are 0 or less, choose a move at random
      if @myChoices.length>0
        pbRegisterMove(index,@myChoices[pbAIRandom(@myChoices.length)],false)
      else
        pbAutoChooseMove(index)
      end
    else
      randnum=pbAIRandom(totalscore)
      cumtotal=0
      for i in 0...4
        if @scores[i]>0
          cumtotal+=@scores[i]
          if randnum<cumtotal
            pbRegisterMove(index,i,false)
            target=@targets[i] if @targets
            break
          end
        end
      end
    end
    if @doublebattle && target && target>=0
      pbRegisterTarget(index,target)
    end
  end

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScore(move,attacker,opponent,skill=100,roughdamage=10,initialscores=[],scoreindex=-1)
    if roughdamage<1
      roughdamage=1
    end
    PBDebug.log(sprintf("%s: initial score: %d",PBMoves.getName(move.id),roughdamage)) if $INTERNAL

    skill=PBTrainerAI.minimumSkill if skill<PBTrainerAI.minimumSkill
    #score=(pbRoughDamage(move,attacker,opponent,skill,move.basedamage)*100/opponent.hp) #roughdamage
    score=roughdamage

    #Temporarly mega-ing pokemon if it can    #perry
    if pbCanMegaEvolve?(attacker.index)
      attacker.pokemon.makeMega
      attacker.pbUpdate(true)
      attacker.form=attacker.startform
      megaEvolved=true
    end

    #Little bit of prep before getting into the case statement
    oppitemworks = opponent.itemWorks?
    attitemworks = attacker.itemWorks?
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    bettertype = move.pbType(move.type,attacker,opponent)
    opponent=attacker.pbOppositeOpposing if !opponent
    opponent=opponent.pbPartner if opponent && opponent.isFainted?
    roles = pbGetMonRole(attacker,opponent,skill)

    # Check priority of move (it's non-zero, or is a status move and attacker has Prankster)
    if move.priority>0 || (move.basedamage==0 && !attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER)

      if move.basedamage>0   # Damaging move
        PBDebug.log(sprintf("Priority Check Begin")) if $INTERNAL
        fastermon = (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
        if fastermon
          PBDebug.log(sprintf("AI Pokemon is faster.")) if $INTERNAL   # attacker is faster
        else
          PBDebug.log(sprintf("Player Pokemon is faster.")) if $INTERNAL   # attacker is slower
        end

        if score>100
          # Prefer moves that will KO the opponent
          if @doublebattle
            score*=1.3
          else
            if fastermon
              score*=1.3
            else
              score*=2   # Really prefer a KO move if attacker is slower than
                         # opponent (this is a priority move which will overcome
                         # attacker's speed disadvantage)
            end
          end
        else
          # Don't prefer a non-KO priority move if attacker has Stance Change and
          # is slower than the opponent (probably assumes attacker is in Shield Form
          # with higher defences, and doesn't want to shift to Attack Form before
          # the opponent this round and give them a change to hit the attacker's
          # lowered defences)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::STANCECHANGE)
            if !fastermon
              score*=0.7
            end
          end
        end

        movedamage = -1
        opppri = false
        pridam = -1

        # If attacker is slower, check memory for most damaging move used previously
        # and for most damaging priority move used previously
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if aimem.length > 0
            for i in aimem
              tempdam = pbRoughDamage(i,opponent,attacker,skill,i.basedamage)
              if i.priority>0
                opppri=true
                if tempdam>pridam
                  pridam = tempdam
                end
              end
              if tempdam>movedamage
                movedamage = tempdam
              end
            end
          end
        end
        PBDebug.log(sprintf("Expected damage taken: %d",movedamage)) if $INTERNAL

        # If attacker is slower and will faint from another hit from the most
        # damaging move in memory, strongly prefer a priority move
        if !fastermon
          if movedamage>attacker.hp
            if @doublebattle
              score+=75
            else
              score+=150
            end
          end
        end

        # If attacker is slower and a priority move was used in the past and the
        # attacker will faint from another hit from that priority move...
        if opppri
          score*=1.1
          if pridam>attacker.hp
            if fastermon
              score*=3   # NOTE: Can't get here because opppri is only true if attacker is slower
            else
              score*=0.5   # Don't prefer this priority move
            end
          end
        end

        # If attacker is slower and opponent is in the middle of a two-turn attack
        # (and is likely semi-invulnerable), discard a priority move because it's
        # better to attack after the opponent has finished and is vulnerable again
        if !fastermon && opponent.effects[PBEffects::TwoTurnAttack]>0
          score*=0
        end

        # Discard higher priority moves if Psychic Terrain is in effect (assumes
        # the target is affected by Psychic Terrain's effect)
        if $fefieldeffect==37   # Psychic Terrain
          score*=0
        end

        # Discard higher priority moves if opponent has an ability that makes it
        # immune to high priority moves
        if !opponent.abilitynulled && (opponent.ability == PBAbilities::DAZZLING || opponent.ability == PBAbilities::QUEENLYMAJESTY)
          score*=0
        end
      end

      # Strongly don't prefer priority moves if Quick Guard was previously used
      score*=0.2 if checkAImoves([PBMoves::QUICKGUARD],aimem)
      PBDebug.log(sprintf("Priority Check End")) if $INTERNAL

    elsif move.priority<0

      if fastermon
        # Slightly slower score if attacker is faster than the opponent but the
        # move is a lower priority (i.e. can't make use of the speed advantage)
        score*=0.9
        if move.basedamage>0   # Damaging move
          # Prefer a lower priority damaging move if opponent is in the middle of
          # a two-turn attack (i.e. is likely semi-invulnerable until their turn)
          if opponent.effects[PBEffects::TwoTurnAttack]>0
            score*=2
          end
        end
      end
    end

    ##### Alter score depending on the move's function code ########################
    score = pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                    score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    ###### END FUNCTION CODES ######################################################

=begin
    # Don't prefer a dance move if the opponent has Dancer (because they'll get
    # a free move)
    if (!opponent.abilitynulled && opponent.ability == PBAbilities::DANCER)
      if (PBStuff::DANCEMOVE).include?(move.id)
        score*=0.5
      end
    end
=end

    ioncheck = false
    destinycheck = false
    widecheck = false
    powdercheck = false
    shieldcheck = false

    # Check the memory for various moves which are referenced below
    if skill>=PBTrainerAI.highSkill
      for j in aimem
        ioncheck = true if j.id==(PBMoves::IONDELUGE)
        destinycheck = true if j.id==(PBMoves::DESTINYBOND)
        widecheck = true if j.id==(PBMoves::WIDEGUARD)
        powdercheck = true if j.id==(PBMoves::POWDER)
        shieldcheck = true if j.id==(PBMoves::SPIKYSHIELD) ||
        j.id==(PBMoves::KINGSSHIELD) ||  j.id==(PBMoves::BANEFULBUNKER)
      end
      if @doublebattle && @aiMoveMemory[2][opponent.pbPartner.pokemonIndex].length>0
        for j in @aiMoveMemory[2][opponent.pbPartner.pokemonIndex]
          widecheck = true if j.id==(PBMoves::WIDEGUARD)
          powdercheck = true if j.id==(PBMoves::POWDER)
        end
      end
    end

    # If Ion Deluge was used previously (turns Normal moves into Electric moves
    # for the round), don't prefer Normal moves if the opponent has an ability
    # that benefits from being hit by an Electric move
    if ioncheck == true
      if move.type == 0
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::LIGHTNINGROD) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::VOLTABSORB) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::MOTORDRIVE)
          score *= 0.3
        end
      end
    end

    # If move targets one or more Pokémon (except the user)...
    if (move.target==PBTargets::SingleNonUser || move.target==PBTargets::RandomOpposing ||
       move.target==PBTargets::AllOpposing || move.target==PBTargets::SingleOpposing ||
       move.target==PBTargets::OppositeOpposing)
      # If move is Electric (or Ion Deluge was used in the past and move is Normal),
      # and opponent/partner has Lightning Rod, don't prefer it
      if move.type==13 || (ioncheck == true && move.type == 0)
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0
        elsif (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0.3   # Would rather hit the opponent, although the partner would benefit
        end
      # If move is Water and opponent/partner has Storm Drain, don't prefer it
      elsif move.type==11
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::STORMDRAIN)
          score*=0
        elsif (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::STORMDRAIN)
          score*=0.3   # Would rather hit the opponent, although the partner would benefit
        end
      end
    end

    # If move is sound-based and opponent is immune/attacker can't use sound moves,
    # discard the move
    if move.isSoundBased?
      if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SOUNDPROOF) && !opponent.moldbroken) || attacker.effects[PBEffects::ThroatChop]!=0
        score*=0
      else
        # If attacker can use sound moves but Throat Chop was used previously,
        # don't prefer this sound move (because attacker may get throat chopped)
        score *= 0.6 if checkAImoves([PBMoves::THROATCHOP],aimem)
      end
    end

    # If opponent isn't immune to critical hits and attacker isn't certain to
    # deal a critical hit, prefer a high critical hit move
    # Prefer the move more if opponent has raised defences and/or attacker has
    # lowered offences
    if move.flags&0x80!=0 # Boosted crit moves
      if !(!opponent.abilitynulled && opponent.ability == PBAbilities::SHELLARMOR) &&
         !(!opponent.abilitynulled && opponent.ability == PBAbilities::BATTLEARMOR) &&
         attacker.effects[PBEffects::LaserFocus]==0
        boostercount = 0
        if move.pbIsPhysical?(move.type)
          boostercount += opponent.stages[PBStats::DEFENSE] if opponent.stages[PBStats::DEFENSE]>0
          boostercount -= attacker.stages[PBStats::ATTACK] if attacker.stages[PBStats::ATTACK]<0
        elsif move.pbIsSpecial?(move.type)
          boostercount += opponent.stages[PBStats::SPDEF] if opponent.stages[PBStats::SPDEF]>0
          boostercount -= attacker.stages[PBStats::SPATK] if attacker.stages[PBStats::SPATK]<0
        end
        score*=(1.05**boostercount)
      end
    end

    # Don't prefer a damaging move if the opponent has a Destiny Bond in place
    # Don't prefer a damaging move if the opponent is faster than the attacker
    # and Destiny Bond has been used in the past
    # (Note: Doesn't check if the move is likely to be lethal for some reason)
    if move.basedamage>0   # Damaging move
      if skill>=PBTrainerAI.highSkill
        if opponent.effects[PBEffects::DestinyBond]
          score*=0.2
        else
          if ((opponent.pbSpeed>attacker.pbSpeed) ^ (@trickroom!=0)) && destinycheck
            score*=0.7
          end
        end
      end
    end

    # Don't prefer a move that will be blocked by Wide Guard if Wide Guard has
    # been used in the past
    if widecheck && ((move.target == PBTargets::AllOpposing) || (move.target == PBTargets::AllNonUsers))
      score*=0.2
    end

    # Don't prefer Fire moves if Powder has been used in the past
    if powdercheck && move.type==10
      score*=0.2
    end

    # Check for items/abilities that will trigger upon the move making contact
    if move.isContactMove? && !(attacker.item == PBItems::PROTECTIVEPADS) &&
       !(!attacker.abilitynulled && attacker.ability == PBAbilities::LONGREACH)
      # Rocky Helmet or Spiky Shield will damage the attacker; don't prefer the move
      # The Spiky Shield part assumes opponent is faster than attacker and could
      # get its shield up before attacker hits it (the check for whether it
      # currently has a Spiky Shield up is below)
      if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) || shieldcheck
        score*=0.85
      end
      if !opponent.abilitynulled
        # Various abilities
        if opponent.ability == PBAbilities::ROUGHSKIN || opponent.ability == PBAbilities::IRONBARBS
          score*=0.85
        elsif opponent.ability == PBAbilities::EFFECTSPORE
          score*=0.75
        elsif opponent.ability == PBAbilities::FLAMEBODY && attacker.pbCanBurn?(false)
          score*=0.75
        elsif opponent.ability == PBAbilities::STATIC && attacker.pbCanParalyze?(false)
          score*=0.75
        elsif opponent.ability == PBAbilities::POISONPOINT && attacker.pbCanPoison?(false)
          score*=0.75
        elsif opponent.ability == PBAbilities::CUTECHARM && attacker.effects[PBEffects::Attract]<0
          if initialscores.length>0
            if initialscores[scoreindex] < 102   # Move won't be lethal
              score*=0.8
            end
          end
        elsif opponent.ability == PBAbilities::GOOEY || opponent.ability == PBAbilities::TANGLINGHAIR
          if attacker.pbCanReduceStatStage?(PBStats::SPEED)
            score*=0.9
            if ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0))
              score*=0.8   # Don't prefer it even more if attacker is faster than the opponent (this may make it slower)
            end
          end
        elsif opponent.ability == PBAbilities::MUMMY
          if !attacker.abilitynulled && !attacker.unstoppableAbility? &&
             attacker.ability != opponent.ability && attacker.ability != PBAbilities::SHIELDDUST
            mummyscore = getAbilityDisruptScore(move,opponent,attacker,skill)   # 1 makes no difference, >1 is a bad impact if ability is lost
            if mummyscore < 2
              mummyscore = 2 - mummyscore
            else
              mummyscore = 0   # Losing current ability is really disruptive; discard the move entirely
            end
            score*=mummyscore   # Don't prefer if attacker would rather keep its current ability
          end
        end
      end
      # Prefer a contact move if the attacker has Poison Touch and it'll do something
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::POISONTOUCH) && opponent.pbCanPoison?(false)
        score*=1.1
      end
      # Prefer a contact move if the attacker has Pickpocket and it'll do something (assumes attacker has no item)
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::PICKPOCKET) && opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item)
        score*=1.1
      end
      # Greatly don't prefer a contact move if opponent has a protecting move that
      # triggers a negative effect if the attacker makes contact with it (see also
      # above for a check of whether Spiky Shield has been used in the past)
      # This check makes no sense because these effects only last until the end
      # of the round, and AI is run at the start of a round
      if opponent.effects[PBEffects::KingsShield]== true ||
         opponent.effects[PBEffects::BanefulBunker]== true ||
         opponent.effects[PBEffects::SpikyShield]== true
        score *=0.1
      end
    end

    # This check makes no sense because these effects only last until the end
    # of the round, and AI is run at the start of a round
    if move.basedamage>0 && (opponent.effects[PBEffects::SpikyShield] ||
       opponent.effects[PBEffects::BanefulBunker] || opponent.effects[PBEffects::KingsShield])
      score*=0.1
    end

    # Don't prefer a status move if attacker has another move that'll KO the opponent
    # If opponent has used a move in the past (in memory) that'll hurt the
    # attacker by 30% or more of its current HP, reduce the status move's score by
    # even more (because it's less safe to use a status move and leave the opponent alive)
    if move.basedamage==0   # Status move
      if hasgreatmoves(initialscores,scoreindex,skill)
        maxdam=checkAIdamage(aimem,attacker,opponent,skill)
        if maxdam>0 && maxdam<(attacker.hp*0.3)   # Should status moves (maxdam==0) count here too?
          score*=0.6
        else
          score*=0.2 ### highly controversial, revert to 0.1 if shit sucks
        end
      end
    end

=begin
    # Discard powder moves if opponent is immune to powder
    ispowder = (move.id==214 || move.id==218 || move.id==220 || move.id==445 || move.id==600 || move.id==18 || move.id==219)
    if ispowder && (opponent.type==(PBTypes::GRASS) ||
       (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) ||
       (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES))
      score*=0
    end
=end

    # A score of 0 here means it should absolutely not be used; return it
    if score<=0
      PBDebug.log(sprintf("%s: final score: 0",PBMoves.getName(move.id))) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #perry
      return score
    end

    ##### Other score modifications ################################################

=begin
    # Prefer damaging moves if AI has no more Pokémon
    if attacker.pbNonActivePokemonCount==0
      if skill>=PBTrainerAI.mediumSkill &&
         !(skill>=PBTrainerAI.highSkill && opponent.pbNonActivePokemonCount>0)
        if move.basedamage==0
          PBDebug.log("[Not preferring status move]") if $INTERNAL
          score*=0.9
        elsif opponent.hp<=opponent.totalhp/2.0   # Opponent is already weakened, hit 'im!
          PBDebug.log("[Preferring damaging move]") if $INTERNAL
          score*=1.1
        end
      end
    end

    # Don't prefer attacking the opponent if they'd be semi-invulnerable; discard the move
    if opponent.effects[PBEffects::TwoTurnAttack]>0 && skill>=PBTrainerAI.highSkill
      invulmove=$pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move
      if move.accuracy>0 &&   # Checks accuracy, i.e. targets opponent
         ([0xC9,0xCA,0xCB,0xCC,0xCD,0xCE].include?(invulmove) ||
         opponent.effects[PBEffects::SkyDrop]) &&
         ((attacker.pbSpeed>opponent.pbSpeed) ^ (@trickroom!=0))
        if skill>=PBTrainerAI.bestSkill   # Can get past semi-invulnerability
          miss=false
          case invulmove
          when 0xC9, 0xCC # Fly, Bounce
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C || # Smack Down
                             (move.id == PBMoves::WHIRLWIND)
          when 0xCA # Dig
            miss=true unless move.function==0x76 || # Earthquake
                             move.function==0x95    # Magnitude
          when 0xCB # Dive
            miss=true unless move.function==0x75 || # Surf
                             move.function==0xD0 || # Whirlpool
                             move.function==0x12D   # Shadow Storm
          when 0xCD # Shadow Force
            miss=true
          when 0xCE # Sky Drop
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C    # Smack Down
          end
          if opponent.effects[PBEffects::SkyDrop]
            miss=true unless move.function==0x08 ||  # Thunder
                             move.function==0x15 ||  # Hurricane
                             move.function==0x77 ||  # Gust
                             move.function==0x78 ||  # Twister
                             move.function==0x11B || # Sky Uppercut
                             move.function==0x11C    # Smack Down
          end
          score*=0 if miss
        else
          score*=0
        end
      end
    end

    # Pick a good move for the Choice items
    if attitemworks && (attacker.item == PBItems::CHOICEBAND ||
       attacker.item == PBItems::CHOICESPECS || attacker.item == PBItems::CHOICESCARF)
      if move.basedamage==0 && move.function!=0xF2 # Trick
        score*=0.1   # Really don't prefer status moves (except Trick)
      end
      # Slightly less prefer certain move types (presumably ones that are considered
      # less good offensively/are ineffective against some things)
      # Types that are still good: Flying, Rock, Bug, Steel, Ice, Dark, Fairy
      if (move.type == PBTypes::NORMAL) ||
         (move.type == PBTypes::GHOST) || (move.type == PBTypes::FIGHTING) ||
         (move.type == PBTypes::DRAGON) || (move.type == PBTypes::PSYCHIC) ||
         (move.type == PBTypes::GROUND) || (move.type == PBTypes::ELECTRIC) ||
         (move.type == PBTypes::POISON)
        score*=0.95
      end
      if (move.type == PBTypes::FIRE) || (move.type == PBTypes::WATER) ||
         (move.type == PBTypes::GRASS) || (move.type == PBTypes::ELECTRIC)
        score*=0.95
      end
      # Don't prefer moves with lower accuracy
      if move.accuracy > 0
        miniacc = (move.accuracy/100.0)
        score *= miniacc
      end
      # Don't prefer moves that don't have much current PP
      if move.pp < 6
        score *= 0.9
      end
    end

    # If user is frozen, prefer a move that can thaw the user
    if attacker.status==PBStatuses::FROZEN
      if skill>=PBTrainerAI.mediumSkill
        if move.canThawUser?
          score+=30
        else
          hasFreezeMove=false
          for m in attacker.moves
            if m.canThawUser?
              hasFreezeMove=true; break
            end
          end
          score*=0 if hasFreezeMove   # Discard this move if it can't thaw the attacker, but it knows another that can
        end
      end
    end

    # If target is frozen, don't prefer moves that could thaw them
    if opponent.status==PBStatuses::FROZEN
      if (move.type == PBTypes::FIRE)
        score *= 0.1
      end
    end

    # Adjust score based on how much damage it can deal
    if move.basedamage>0   # Damaging moves
      # Discard damaging moves if they are ineffective because of their type
      typemod=pbTypeModNoMessages(bettertype,attacker,opponent,move,skill)
      if typemod==0 || score<=0
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && !(!attacker.abilitynulled &&
         (attacker.ability == PBAbilities::MOLDBREAKER ||
         attacker.ability == PBAbilities::TURBOBLAZE ||
         attacker.ability == PBAbilities::TERAVOLT))
        if !opponent.abilitynulled
          # Discard damaging moves if opponent is immune to them because of their ability
          if (typemod<=4 && opponent.ability == PBAbilities::WONDERGUARD) ||
             (move.type == PBTypes::GROUND && (opponent.ability == PBAbilities::LEVITATE || (oppitemworks && opponent.item == PBItems::AIRBALLOON) || opponent.effects[PBEffects::MagnetRise]>0)) ||
             (move.type == PBTypes::FIRE && opponent.ability == PBAbilities::FLASHFIRE) ||
             (move.type == PBTypes::WATER && (opponent.ability == PBAbilities::WATERABSORB || opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN)) ||
             (move.type == PBTypes::GRASS && opponent.ability == PBAbilities::SAPSIPPER) ||
             (move.type == PBTypes::ELECTRIC)&& (opponent.ability == PBAbilities::VOLTABSORB || opponent.ability == PBAbilities::LIGHTNINGROD || opponent.ability == PBAbilities::MOTORDRIVE)
            score=0
          end
        end
      else
        # Discard damaging ground moves if the opponent is airborne (even moron trainers can do this much)
        if move.type == PBTypes::GROUND && (opponent.ability == PBAbilities::LEVITATE || (oppitemworks && opponent.item == PBItems::AIRBALLOON) || opponent.effects[PBEffects::MagnetRise]>0)
          score=0
        end
      end
      # This calculation has no effect, and should be unused anyway as the base
      # score already is the likely damage percentage
      if score != 0
        # Calculate how much damage the move will do (roughly)
        realBaseDamage=move.basedamage
        realBaseDamage=60 if move.basedamage==1
        if skill>=PBTrainerAI.mediumSkill
          realBaseDamage=pbBetterBaseDamage(move,attacker,opponent,skill,realBaseDamage)
        end
      end
    else # non-damaging moves
      if !opponent.abilitynulled
        # Discard status moves if opponent is immune to them because of their ability
        if (move.type == PBTypes::GROUND && (opponent.ability == PBAbilities::LEVITATE || (oppitemworks && opponent.item == PBItems::AIRBALLOON) || opponent.effects[PBEffects::MagnetRise]>0)) ||
           (move.type == PBTypes::FIRE && opponent.ability == PBAbilities::FLASHFIRE) ||
           (move.type == PBTypes::WATER && (opponent.ability == PBAbilities::WATERABSORB || opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN)) ||
           (move.type == PBTypes::GRASS && opponent.ability == PBAbilities::SAPSIPPER) ||
           (move.type == PBTypes::ELECTRIC)&& (opponent.ability == PBAbilities::VOLTABSORB || opponent.ability == PBAbilities::LIGHTNINGROD || opponent.ability == PBAbilities::MOTORDRIVE)
          score=0
        end
      end
    end

    # Multiply score by the move's accuracy
    accuracy=pbRoughAccuracy(move,attacker,opponent,skill)
    score*=accuracy/100.0
    #score=0 if score<=10 && skill>=PBTrainerAI.highSkill
=end

    # Discard a status move (except Nature Power) that targets a non-user if
    # either opponent has Magic Bounce
    if (move.basedamage==0 && !(move.id == PBMoves::NATUREPOWER)) &&
       (move.target==PBTargets::SingleNonUser || move.target==PBTargets::RandomOpposing ||
       move.target==PBTargets::AllOpposing || move.target==PBTargets::OpposingSide ||
       move.target==PBTargets::SingleOpposing || move.target==PBTargets::OppositeOpposing) &&
       ((!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICBOUNCE) ||
       (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::MAGICBOUNCE))
      score=0
    end

=begin
    # Discard a move if it'll be made faster by attacker's Prankster but opponent
    # will be immune because it's Dark-type
    if skill>=PBTrainerAI.mediumSkill
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER)
        if opponent.pbHasType?(:DARK)
          if move.basedamage==0 && move.priority>-1
            score=0
          end
        end
      end
    end

    # Avoid hitting shiny wild pokemon if you're an AI partner
    if pbIsWild?
      if attacker.index == 2
        if opponent.pokemon.isShiny?
          score *= 0.15
        end
      end
    end
=end

    score=score.to_i
    score=0 if score<0
    PBDebug.log(sprintf("%s: final score: %d",PBMoves.getName(move.id),score)) if $INTERNAL
    PBDebug.log(sprintf(" ")) if $INTERNAL
    attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #perry
    return score
  end
end
