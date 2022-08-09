class PokeBattle_Battle
  attr_accessor :scores
  attr_accessor :targets
  attr_accessor :myChoices

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
    if wildbattle # If wild battle
      preference = attacker.personalID % 16
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
    else
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
        scoresAndTargets=[]
        @targets=[-1,-1,-1,-1]
        maxscore1=0
        maxscore2=0
        totalscore1=0
        totalscore2=0
        baseDamageArray=[]
        baseDamageArray2=[]
        baseDamageArray3=[] ###
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
        for i in 0...4 ### This whole bit
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
        scoresAndTargets.sort!{|a,b|
           if a[2]==b[2] # if scores are equal
             a[0]<=>b[0] # sort by index (for stable comparison)
           else
             b[2]<=>a[2]
           end
        }
        for i in 0...scoresAndTargets.length
          idx=scoresAndTargets[i][1]
          thisScore=scoresAndTargets[i][2]
          if thisScore>0 || thisScore==-1
            if scores[idx]==0 || ((scores[idx]==thisScore && pbAIRandom(10)<5) ||
               (scores[idx] < thisScore))
           #    (scores[idx]!=thisScore && pbAIRandom(10)<3))
              @scores[idx]=thisScore
              @targets[idx]=scoresAndTargets[i][3]
            end
          end
        end
      else
        # Choose a move. There is only 1 opposing Pokémon.
        if @doublebattle && opponent.isFainted?
          opponent=opponent.pbPartner
        end
        baseDamageArray=[]
        baseDamageArrayAdj=[]
        for j in 0...4
          next if attacker.moves[j].id < 1
          # check attacker.moves[j].basedamage and if this is 0 instead check the status method
          dmgValue = pbRoughDamage(attacker.moves[j],attacker,opponent,skill,attacker.moves[j].basedamage)
          if attacker.moves[j].basedamage!=0
            dmgPercent = (dmgValue*100)/(opponent.hp)
            dmgPercent = 110 if dmgPercent > 110
            if attacker.moves[j].function == 0x115 || attacker.moves[j].function == 0xC3 ||
             attacker.moves[j].function == 0xC4 || attacker.moves[j].function == 0xC5 ||
             attacker.moves[j].function == 0xC6 || attacker.moves[j].function == 0xC7 ||
             attacker.moves[j].function == 0xC8
               dmgPercentAdj = (dmgPercent * 0.5)
            else
               dmgPercentAdj = dmgPercent
            end
          else
            dmgPercent = pbStatusDamage(attacker.moves[j])
            dmgPercentAdj = dmgPercent
          end
          baseDamageArray.push(dmgPercent)
          baseDamageArrayAdj.push(dmgPercentAdj)
        end
        for i in 0...4
          if pbCanChooseMove?(index,i,false)
            @scores[i]=pbGetMoveScore(attacker.moves[i],attacker,opponent,skill,baseDamageArray[i],baseDamageArrayAdj,i)
            @myChoices.push(i)
          else
            @scores[i] = -1
          end
        end
      end
    end
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
    for i in 0...4
      #next if scores[i] == -1
      @scores[i]=0 if @scores[i]<0
      maxscore=@scores[i] if @scores[i]>maxscore
      totalscore+=@scores[i]
    end
    # Minmax choices depending on AI
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
    PBDebug.log("If this battle is not wild, something has gone wrong in scoring moves (no preference chosen).") if $INTERNAL
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
    if move.priority>0 || (move.basedamage==0 && !attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER)
      if move.basedamage>0
        PBDebug.log(sprintf("Priority Check Begin")) if $INTERNAL
        fastermon = (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
        if fastermon
          PBDebug.log(sprintf("AI Pokemon is faster.")) if $INTERNAL
        else
          PBDebug.log(sprintf("Player Pokemon is faster.")) if $INTERNAL
        end
        if score>100
          if @doublebattle
            score*=1.3
          else
            if fastermon
              score*=1.3
            else
              score*=2
            end
          end
        else
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::STANCECHANGE)
            if !fastermon
              score*=0.7
            end
          end
        end
        movedamage = -1
        opppri = false
        pridam = -1
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
        if !fastermon
          if movedamage>attacker.hp
            if @doublebattle
              score+=75
            else
              score+=150
            end
          end
        end
        if opppri
          score*=1.1
          if pridam>attacker.hp
            if fastermon
              score*=3
            else
              score*=0.5
            end
          end
        end
        if !fastermon && opponent.effects[PBEffects::TwoTurnAttack]>0
          score*=0
        end
        if $fefieldeffect==37
          score*=0
        end
        if !opponent.abilitynulled && (opponent.ability == PBAbilities::DAZZLING || opponent.ability == PBAbilities::QUEENLYMAJESTY)
          score*=0
        end
      end
      score*=0.2 if checkAImoves([PBMoves::QUICKGUARD],aimem)
      PBDebug.log(sprintf("Priority Check End")) if $INTERNAL
    elsif move.priority<0
      if fastermon
        score*=0.9
        if move.basedamage>0
          if opponent.effects[PBEffects::TwoTurnAttack]>0
            score*=2
          end
        end
      end
    end

    ##### Alter score depending on the move's function code ########################
    score = pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                    score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    ###### END FUNCTION CODES

    if (!opponent.abilitynulled && opponent.ability == PBAbilities::DANCER)
      if (PBStuff::DANCEMOVE).include?(move.id)
        score*=0.5
        score*=0.1 if $fefieldeffect==6
      end
    end
    ioncheck = false
    destinycheck = false
    widecheck = false
    powdercheck = false
    shieldcheck = false
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
    if (move.target==PBTargets::SingleNonUser || move.target==PBTargets::RandomOpposing ||
       move.target==PBTargets::AllOpposing || move.target==PBTargets::SingleOpposing ||
       move.target==PBTargets::OppositeOpposing)
      if move.type==13 || (ioncheck == true && move.type == 0)
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0
        elsif (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0.3
        end
      elsif move.type==11
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0
        elsif (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::LIGHTNINGROD)
          score*=0.3
        end
      end
    end
    if move.isSoundBased?
      if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SOUNDPROOF) && !opponent.moldbroken) || attacker.effects[PBEffects::ThroatChop]!=0
        score*=0
      else
        score *= 0.6 if checkAImoves([PBMoves::THROATCHOP],aimem)
      end
    end
    if move.flags&0x80!=0 # Boosted crit moves
      if !((!opponent.abilitynulled && opponent.ability == PBAbilities::SHELLARMOR) ||
         (!opponent.abilitynulled && opponent.ability == PBAbilities::BATTLEARMOR) ||
         attacker.effects[PBEffects::LaserFocus]>0)
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
    if move.basedamage>0
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
    if widecheck && ((move.target == PBTargets::AllOpposing) || (move.target == PBTargets::AllNonUsers))
      score*=0.2
    end
    if powdercheck && move.type==10
      score*=0.2
    end
    if move.isContactMove? && !(attacker.item == PBItems::PROTECTIVEPADS) && !(!attacker.abilitynulled && attacker.ability == PBAbilities::LONGREACH)
      if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) || shieldcheck
        score*=0.85
      end
      if !opponent.abilitynulled
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
            if initialscores[scoreindex] < 102
              score*=0.8
            end
          end
        elsif opponent.ability == PBAbilities::GOOEY || opponent.ability == PBAbilities::TANGLINGHAIR
          if attacker.pbCanReduceStatStage?(PBStats::SPEED)
            score*=0.9
            if ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0))
              score*=0.8
            end
          end
        elsif opponent.ability == PBAbilities::MUMMY
          if !attacker.abilitynulled && !attacker.unstoppableAbility? &&
             attacker.ability != opponent.ability && attacker.ability != PBAbilities::SHIELDDUST
            mummyscore = getAbilityDisruptScore(move,opponent,attacker,skill)
            if mummyscore < 2
              mummyscore = 2 - mummyscore
            else
              mummyscore = 0
            end
            score*=mummyscore
          end
        end
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::POISONTOUCH) && opponent.pbCanPoison?(false)
        score*=1.1
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::PICKPOCKET) && opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item)
        score*=1.1
      end
      if opponent.effects[PBEffects::KingsShield]== true ||
      opponent.effects[PBEffects::BanefulBunker]== true ||
      opponent.effects[PBEffects::SpikyShield]== true
        score *=0.1
      end
    end
    if move.basedamage>0 && (opponent.effects[PBEffects::SpikyShield] ||
      opponent.effects[PBEffects::BanefulBunker] || opponent.effects[PBEffects::KingsShield])
      score*=0.1
    end
    if move.basedamage==0
      if hasgreatmoves(initialscores,scoreindex,skill)
        maxdam=checkAIdamage(aimem,attacker,opponent,skill)
        if maxdam>0 && maxdam<(attacker.hp*0.3)
          score*=0.6
        else
          score*=0.2 ### highly controversial, revert to 0.1 if shit sucks
        end
      end
    end
    ispowder = (move.id==214 || move.id==218 || move.id==220 || move.id==445 || move.id==600 || move.id==18 || move.id==219)
    if ispowder && (opponent.type==(PBTypes::GRASS) ||
       (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) ||
       (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES))
      score*=0
    end
    # A score of 0 here means it should absolutely not be used
    if score<=0
      PBDebug.log(sprintf("%s: final score: 0",PBMoves.getName(move.id))) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #perry
      return score
    end
    ##### Other score modifications ################################################
    # Prefer damaging moves if AI has no more Pokémon
    if attacker.pbNonActivePokemonCount==0
      if skill>=PBTrainerAI.mediumSkill &&
        !(skill>=PBTrainerAI.highSkill && opponent.pbNonActivePokemonCount>0)
        if move.basedamage==0
          PBDebug.log("[Not preferring status move]") if $INTERNAL
          score*=0.9
        elsif opponent.hp<=opponent.totalhp/2.0
          PBDebug.log("[Preferring damaging move]") if $INTERNAL
          score*=1.1
        end
      end
    end
    # Don't prefer attacking the opponent if they'd be semi-invulnerable
    if opponent.effects[PBEffects::TwoTurnAttack]>0 &&
      skill>=PBTrainerAI.highSkill
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
        score*=0.1
      end
      if ((move.type == PBTypes::NORMAL) && $fefieldeffect!=29) ||
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
      if move.accuracy > 0
        miniacc = (move.accuracy/100.0)
        score *= miniacc
      end
      if move.pp < 6
        score *= 0.9
      end
    end
    #If user is frozen, prefer a move that can thaw the user
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
          score*=0 if hasFreezeMove
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
    if move.basedamage>0
      typemod=pbTypeModNoMessages(bettertype,attacker,opponent,move,skill)
      if typemod==0 || score<=0
        score=0
      elsif skill>=PBTrainerAI.mediumSkill && !(!attacker.abilitynulled &&
         (attacker.ability == PBAbilities::MOLDBREAKER ||
          attacker.ability == PBAbilities::TURBOBLAZE ||
          attacker.ability == PBAbilities::TERAVOLT))
        if !opponent.abilitynulled
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
        if move.type == PBTypes::GROUND && (opponent.ability == PBAbilities::LEVITATE || (oppitemworks && opponent.item == PBItems::AIRBALLOON) || opponent.effects[PBEffects::MagnetRise]>0)
          score=0
        end
      end
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
        if (move.type == PBTypes::GROUND && (opponent.ability == PBAbilities::LEVITATE || (oppitemworks && opponent.item == PBItems::AIRBALLOON) || opponent.effects[PBEffects::MagnetRise]>0)) ||
          (move.type == PBTypes::FIRE && opponent.ability == PBAbilities::FLASHFIRE) ||
          (move.type == PBTypes::WATER && (opponent.ability == PBAbilities::WATERABSORB || opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN)) ||
          (move.type == PBTypes::GRASS && opponent.ability == PBAbilities::SAPSIPPER) ||
          (move.type == PBTypes::ELECTRIC)&& (opponent.ability == PBAbilities::VOLTABSORB || opponent.ability == PBAbilities::LIGHTNINGROD || opponent.ability == PBAbilities::MOTORDRIVE)
          score=0
        end
      end
    end
    accuracy=pbRoughAccuracy(move,attacker,opponent,skill)
    score*=accuracy/100.0
    #score=0 if score<=10 && skill>=PBTrainerAI.highSkill
    if (move.basedamage==0 && !(move.id == PBMoves::NATUREPOWER)) &&
       (move.target==PBTargets::SingleNonUser || move.target==PBTargets::RandomOpposing ||
       move.target==PBTargets::AllOpposing || move.target==PBTargets::OpposingSide ||
       move.target==PBTargets::SingleOpposing || move.target==PBTargets::OppositeOpposing) &&
       ((!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICBOUNCE) ||
       (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::MAGICBOUNCE))
      score=0
    end
    if skill>=PBTrainerAI.mediumSkill
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER)
        if opponent.pbHasType?(:DARK)
          if move.basedamage==0 && move.priority>-1
            score=0
          end
        end
      end
    end
    # Avoid shiny wild pokemon if you're an AI partner
    if pbIsWild?
      if attacker.index == 2
        if opponent.pokemon.isShiny?
          score *= 0.15
        end
      end
    end
    score=score.to_i
    score=0 if score<0
    PBDebug.log(sprintf("%s: final score: %d",PBMoves.getName(move.id),score)) if $INTERNAL
    PBDebug.log(sprintf(" ")) if $INTERNAL
    attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #perry
    return score
  end

  ##############################################################################
  # Decide whether the opponent should use a Z-Move.
  ##############################################################################
  def pbEnemyShouldZMove?(index)
    return pbCanZMove?(index) #Conditions based on effectiveness and type handled later
  end
end
