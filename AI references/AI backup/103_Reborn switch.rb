class PokeBattle_Battle
  ################################################################################
  # Decide whether the opponent should switch Pokémon, and what to switch to. NEW
  ################################################################################
    #if this function isn't here things break and i hate it.
    def pbDefaultChooseNewEnemy(index,party)
      return pbSwitchTo(@battlers[index],party,pbGetOwner(index).skill)
    end

    def pbShouldSwitch?(index)
      return false if !@opponent
      switchscore = 0
      noswitchscore = 0
      monarray = []
      currentmon = @battlers[index]
      opponent1 = currentmon.pbOppositeOpposing
      opponent2 = opponent1.pbPartner
      party = pbParty(index)
      partyroles=[]
      skill=pbGetOwner(index).skill || 0
      count = 0
      for i in party
        next if i.nil?
        next if i.hp == 0
        count+=1
      end
      return false if count==1
      if $game_switches[1000] && count==2
        return false
      end
      count = 0
      for i in 0..(party.length-1)
        next if !pbCanSwitchLax?(index,i,false)
        count+=1
      end
      return false if count==0
      count = -1
      for i in party
        count+=1
        next if i.nil?
        next if count == currentmon.pokemonIndex
        dummyarr1 = pbGetMonRole(i,opponent1,skill,count,party)
        (partyroles << dummyarr1).flatten!
        dummyarr2 = pbGetMonRole(i,opponent2,skill,count,party)
        (partyroles << dummyarr2).flatten!
      end
      partyroles.uniq!
      currentroles = pbGetMonRole(currentmon,opponent1,skill)
      aimem = getAIMemory(skill,opponent1.pokemonIndex)
      aimem2 = getAIMemory(skill,opponent2.pokemonIndex)
      # Statuses
      PBDebug.log(sprintf("Initial switchscore building: Statuses (%d)",switchscore)) if $INTERNAL
      if currentmon.effects[PBEffects::Curse]
        switchscore+=80
      end
      if currentmon.effects[PBEffects::LeechSeed]>=0
        switchscore+=60
      end
      if currentmon.effects[PBEffects::Attract]>=0
        switchscore+=60
      end
      if currentmon.effects[PBEffects::Confusion]>0
        switchscore+=80
      end
      if currentmon.effects[PBEffects::PerishSong]==2
        switchscore+=40
      elsif currentmon.effects[PBEffects::PerishSong]==1
        switchscore+=200
      end
      if currentmon.effects[PBEffects::Toxic]>0
        switchscore+= (currentmon.effects[PBEffects::Toxic]*15)
      end
      if (!currentmon.abilitynulled && currentmon.ability == PBAbilities::NATURALCURE) && currentmon.status!=0
        switchscore+=50
      end
      if partyroles.include?(PBMonRoles::CLERIC) && currentmon.status!=0
        switchscore+=60
      end
      if currentmon.status==PBStatuses::SLEEP
        switchscore+=170 if checkAImoves([PBMoves::DREAMEATER,PBMoves::NIGHTMARE],aimem)
      end
      if currentmon.effects[PBEffects::Yawn]>0 && currentmon.status!=PBStatuses::SLEEP
        switchscore+=95
      end
      # Stat Stages
      PBDebug.log(sprintf("Initial switchscore building: Stat Stages (%d)",switchscore)) if $INTERNAL
      specialmove = false
      physmove = false
      for i in currentmon.moves
        specialmove = true if i.pbIsSpecial?(i.type)
        physmove = true if i.pbIsPhysical?(i.type)
      end
      if currentroles.include?(PBMonRoles::SWEEPER)
        switchscore+= (-30)*currentmon.stages[PBStats::ATTACK] if currentmon.stages[PBStats::ATTACK]<0 && physmove
        switchscore+= (-30)*currentmon.stages[PBStats::SPATK] if currentmon.stages[PBStats::SPATK]<0 && specialmove
        switchscore+= (-30)*currentmon.stages[PBStats::SPEED] if currentmon.stages[PBStats::SPEED]<0
        switchscore+= (-30)*currentmon.stages[PBStats::ACCURACY] if currentmon.stages[PBStats::ACCURACY]<0
      else
        switchscore+= (-15)*currentmon.stages[PBStats::ATTACK] if currentmon.stages[PBStats::ATTACK]<0 && physmove
        switchscore+= (-15)*currentmon.stages[PBStats::SPATK] if currentmon.stages[PBStats::SPATK]<0 && specialmove
        switchscore+= (-15)*currentmon.stages[PBStats::SPEED] if currentmon.stages[PBStats::SPEED]<0
        switchscore+= (-15)*currentmon.stages[PBStats::ACCURACY] if currentmon.stages[PBStats::ACCURACY]<0
      end
      if currentroles.include?(PBMonRoles::PHYSICALWALL)
        switchscore+= (-30)*currentmon.stages[PBStats::DEFENSE] if currentmon.stages[PBStats::DEFENSE]<0
      else
        switchscore+= (-15)*currentmon.stages[PBStats::DEFENSE] if currentmon.stages[PBStats::DEFENSE]<0
      end
      if currentroles.include?(PBMonRoles::SPECIALWALL)
        switchscore+= (-30)*currentmon.stages[PBStats::SPDEF] if currentmon.stages[PBStats::SPDEF]<0
      else
        switchscore+= (-15)*currentmon.stages[PBStats::SPDEF] if currentmon.stages[PBStats::SPDEF]<0
      end
      # Healing
      PBDebug.log(sprintf("Initial switchscore building: Healing")) if $INTERNAL
      if (currentmon.hp.to_f)/currentmon.totalhp<(2/3) && (!currentmon.abilitynulled && currentmon.ability == PBAbilities::REGENERATOR)
        switchscore+=30
      end
      if currentmon.effects[PBEffects::Wish]>0
        lowhp = false
        for i in party
          next if i.nil?
          if 0.3<((i.hp.to_f)/i.totalhp) && ((i.hp.to_f)/i.totalhp)<0.6
            lowhp = true
          end
        end
        switchscore+=40 if lowhp
      end
      # fsteak
      PBDebug.log(sprintf("Initial switchscore building: fsteak (%d)",switchscore)) if $INTERNAL
      finalmod = 0
      tricktreat = false
      forestcurse = false
      notnorm = false
      for i in currentmon.moves
        if i.id==(PBMoves::TRICKORTREAT)
          tricktreat = true
        elsif i.id==(PBMoves::FORESTSCURSE)
          forestcurse = true
        elsif i.type != (PBTypes::NORMAL)
          notnorm = true
        end
        mod1 = pbTypeModNoMessages(i.type,currentmon,opponent1,i,skill)
        mod2 = pbTypeModNoMessages(i.type,currentmon,opponent2,i,skill)
        mod1 = 4 if opponent1.hp==0
        mod2 = 4 if opponent2.hp==0
        if (!opponent1.abilitynulled && opponent1.ability == PBAbilities::WONDERGUARD) && mod1<=4
          mod1=0
        end
        if (!opponent2.abilitynulled && opponent2.ability == PBAbilities::WONDERGUARD) && mod2<=4
          mod2=0
        end
        finalmod += mod1*mod2
      end
      if finalmod==0
        if (tricktreat && notnorm) || forestcurse
          finalmod=1
        end
      end
      switchscore+=140 if finalmod==0
      totalpp=0
      for i in currentmon.moves
        totalpp+= i.pp
      end
      switchscore+=200 if totalpp==0
      if currentmon.effects[PBEffects::Torment]== true
        switchscore+=30
      end
      if currentmon.effects[PBEffects::Encore]>0
        encoreIndex=currentmon.effects[PBEffects::EncoreIndex]
        if opponent1.hp>0
          dmgValue = pbRoughDamage(currentmon.moves[encoreIndex],currentmon,opponent1,skill,currentmon.moves[encoreIndex].basedamage)
          if currentmon.moves[encoreIndex].basedamage!=0
            dmgPercent = (dmgValue*100)/(opponent1.hp)
            dmgPercent = 110 if dmgPercent > 110
          else
            dmgPercent = pbStatusDamage(currentmon.moves[encoreIndex])
          end
          encoreScore=pbGetMoveScore(currentmon.moves[encoreIndex],currentmon,opponent1,skill,dmgPercent)
        else
          dmgValue = pbRoughDamage(currentmon.moves[encoreIndex],currentmon,opponent2,skill,currentmon.moves[encoreIndex].basedamage)
          if currentmon.moves[encoreIndex].basedamage!=0
            dmgPercent = (dmgValue*100)/(opponent2.hp)
            dmgPercent = 110 if dmgPercent > 110
          else
            dmgPercent = pbStatusDamage(currentmon.moves[encoreIndex])
          end
          encoreScore=pbGetMoveScore(currentmon.moves[encoreIndex],currentmon,opponent2,skill,dmgPercent)
        end
        if encoreScore <= 30
          switchscore+=200
        end
        if currentmon.effects[PBEffects::Torment]== true
          switchscore+=110
        end
      end
      if currentmon.effects[PBEffects::ChoiceBand]>=0 && currentmon.itemWorks? && (currentmon.item == PBItems::CHOICEBAND ||
          currentmon.item == PBItems::CHOICESPECS || currentmon.item == PBItems::CHOICESCARF)
        choiced = false
        for i in 0...4
          if currentmon.moves[i].id==currentmon.effects[PBEffects::ChoiceBand]
            choiced=true
            choiceID = i
            break
          end
        end
        if choiced
          if opponent1.hp>0
            dmgValue = pbRoughDamage(currentmon.moves[choiceID],currentmon,opponent1,skill,currentmon.moves[choiceID].basedamage)
            if currentmon.moves[choiceID].basedamage!=0
              dmgPercent = (dmgValue*100)/(opponent1.hp)
              dmgPercent = 110 if dmgPercent > 110
            else
              dmgPercent = pbStatusDamage(currentmon.moves[choiceID])
            end
            choiceScore=pbGetMoveScore(currentmon.moves[choiceID],currentmon,opponent1,skill,dmgPercent)
          else
            dmgValue = pbRoughDamage(currentmon.moves[choiceID],currentmon,opponent2,skill,currentmon.moves[choiceID].basedamage)
            if currentmon.moves[choiceID].basedamage!=0
              dmgPercent = (dmgValue*100)/(opponent2.hp)
              dmgPercent = 110 if dmgPercent > 110
            else
              dmgPercent = pbStatusDamage(currentmon.moves[choiceID])
            end
            choiceScore=pbGetMoveScore(currentmon.moves[choiceID],currentmon,opponent2,skill,dmgPercent)
          end
          if choiceScore <= 50
            switchscore+=50
            if choiceScore <= 30
              switchscore+=130
              if choiceScore <= 5
                switchscore+=150
              end
            end
          end
          if currentmon.effects[PBEffects::Torment]== true
            switchscore+=150
          end
        end
      end
      if skill<PBTrainerAI.highSkill
        switchscore/=2.0
      end
      # Typing? How have we not had a typing section this entire time?
      PBDebug.log(sprintf("Initial switchscore building: Typing (%d)",switchscore)) if $INTERNAL
      tempswitchscore = 0
      effcheck = PBTypes.getCombinedEffectiveness(opponent1.type1,currentmon.type1,currentmon.type2)
      if effcheck > 4
        tempswitchscore+=20
      elsif effcheck < 4
        tempswitchscore-=20
      end
      effcheck2 = PBTypes.getCombinedEffectiveness(opponent1.type2,currentmon.type1,currentmon.type2)
      if effcheck2 > 4
        tempswitchscore+=20
        elsif effcheck2 < 4
          tempswitchscore-=20
        end
      if opponent2.totalhp !=0
        tempswitchscore *= 0.5
        effcheck = PBTypes.getCombinedEffectiveness(opponent2.type1,currentmon.type1,currentmon.type2)
        if effcheck > 4
          tempswitchscore+=10
        elsif effcheck < 4
          tempswitchscore-=10
        end
        effcheck2 = PBTypes.getCombinedEffectiveness(opponent2.type2,currentmon.type1,currentmon.type2)
        if effcheck2 > 4
          tempswitchscore+=10
        elsif effcheck2 < 4
          tempswitchscore-=10
        end
      end
      switchscore += tempswitchscore
      # Specific Switches
      PBDebug.log(sprintf("Initial switchscore building: Specific Switches (%d)",switchscore)) if $INTERNAL
      if opponent1.effects[PBEffects::TwoTurnAttack]>0
        twoturntype = $pkmn_move[opponent1.effects[PBEffects::TwoTurnAttack]][2]
        breakvar = false
        savedmod = -1
        indexsave = -1
        count = -1
        for i in party
          count+=1
          next if i.nil?
          next if count == currentmon.pokemonIndex
          totalmod=currentmon.moves[0].pbTypeModifierNonBattler(twoturntype,opponent1,i)
          if totalmod<4
            switchscore+=80 unless breakvar
            breakvar = true
            if savedmod<0
              indexsave = count
              savedmod = totalmod
            else
              if savedmod>totalmod
                indexsave = count
                savedmod = totalmod
              end
            end
          end
        end
        monarray.push(indexsave) if indexsave > -1
      end
      if pbRoughStat(currentmon,PBStats::SPEED,skill) < pbRoughStat(opponent1,PBStats::SPEED,skill)
        if aimem.length!=0
          movedamages = []
          for i in aimem
            movedamages.push(pbRoughDamage(i,opponent1,currentmon,skill,i.basedamage))
          end
          if movedamages.length > 0
            bestmoveindex = movedamages.index(movedamages.max)
            bestmove = aimem[bestmoveindex]
            if (currentmon.hp) < movedamages[bestmoveindex]
              count = -1
              breakvar = false
              immunevar = false
              savedmod = -1
              indexsave = -1
              for i in party
                count+=1
                next if i.nil?
                next if count == currentmon.pokemonIndex
                totalmod = bestmove.pbTypeModifierNonBattler(bestmove.type,opponent1,i)
                if totalmod<4
                  switchscore+=80 unless breakvar
                  breakvar = true
                  if totalmod == 0
                    switchscore+=20 unless immunevar
                    immunevar = true
                  end
                  if savedmod<0
                    indexsave = count
                    savedmod = totalmod
                  else
                    if savedmod>totalmod
                      indexsave = count
                      savedmod = totalmod
                    end
                  end
                end
              end
              if immunevar
                monarray.push(indexsave) if indexsave > -1
              else
                if indexsave > -1
                  if party[indexsave].speed > pbRoughStat(opponent1,PBStats::SPEED,skill)
                    monarray.push(indexsave)
                  end
                end
              end
            end
          end
        end
      end
      if pbRoughStat(currentmon,PBStats::SPEED,skill) < pbRoughStat(opponent2,PBStats::SPEED,skill)
        if aimem2.length!=0
          movedamages = []
          for i in aimem2
            movedamages.push(pbRoughDamage(i,opponent2,currentmon,skill,i.basedamage))
          end
          if movedamages.length > 0
            bestmoveindex = movedamages.index(movedamages.max)
            bestmove = aimem2[bestmoveindex]
            if (currentmon.hp) < movedamages[bestmoveindex]
              count = -1
              breakvar = false
              immunevar = false
              savedmod = -1
              indexsave = -1
              for i in party
                count+=1
                next if i.nil?
                next if count == currentmon.pokemonIndex
                totalmod = bestmove.pbTypeModifierNonBattler(bestmove.type,opponent2,i)
                if totalmod<4
                  switchscore+=80 unless breakvar
                  breakvar = true
                  if totalmod == 0
                    switchscore+=20 unless immunevar
                    immunevar = true
                  end
                  if savedmod<0
                    indexsave = count
                    savedmod = totalmod
                  else
                    if savedmod>totalmod
                      indexsave = count
                      savedmod = totalmod
                    end
                  end
                end
              end
              if immunevar
                monarray.push(indexsave) if indexsave > -1
              else
                if indexsave > -1
                  if party[indexsave].speed > pbRoughStat(opponent2,PBStats::SPEED,skill)
                    monarray.push(indexsave)
                  end
                end
              end
            end
          end
        end
      end
      if skill>=PBTrainerAI.highSkill
        if aimem.length!=0
          #Fakeout Check
          if checkAImoves([PBMoves::FAKEOUT],aimem) && opponent1.turncount == 1
            count = -1
            for i in party
              count+=1
              next if i.nil?
              next if count == currentmon.pokemonIndex
              if (i.ability == PBAbilities::STEADFAST)
                monarray.push(count)
                switchscore+=90
                break
              end
            end
          end
          #Meech check
          if (opponent1.ability == PBAbilities::SKILLLINK) && skill>=PBTrainerAI.bestSkill #elite trainers only
            probablycinccino = false
            for i in aimem
              if i.function==0xC0 && i.isContactMove?
                probablycinccino = true
              end
            end
            if probablycinccino
              count = -1
              maxpain = 0
              storedmon = -1
              for i in party
                count+=1
                next if i.nil?
                paincount = 0
                next if count == currentmon.pokemonIndex
                if (i.ability == PBAbilities::ROUGHSKIN) || (i.ability == PBAbilities::IRONBARBS)
                  paincount+=1
                end
                if (i.item == PBItems::ROCKYHELMET)
                  paincount+=1
                end
                if paincount>0 && paincount>maxpain
                  maxpain=paincount
                  storedmon = count
                  switchscore+=70
                end
              end
              if storedmon>-1
                monarray.push(storedmon)
              end
            end
          end
        end
        if aimem.length!=0
          #Fakeout Check
          if checkAImoves([PBMoves::FAKEOUT],aimem2) && opponent2.turncount == 1
            count = -1
            for i in party
              count+=1
              next if i.nil?
              next if count == currentmon.pokemonIndex
              if (i.ability == PBAbilities::STEADFAST)
                monarray.push(count)
                switchscore+=90
                break
              end
            end
          end
          #Meech check
          if (opponent2.ability == PBAbilities::SKILLLINK) && skill>=PBTrainerAI.bestSkill
            probablycinccino = false
            for i in aimem2
              if i.function==0xC0 && i.isContactMove?
                probablycinccino = true
              end
            end
            if probablycinccino
              count = -1
              maxpain = 0
              storedmon = -1
              for i in party
                count+=1
                next if i.nil?
                paincount = 0
                next if count == currentmon.pokemonIndex
                if (i.ability == PBAbilities::ROUGHSKIN) || (i.ability == PBAbilities::IRONBARBS)
                  paincount+=1
                end
                if (i.item == PBItems::ROCKYHELMET)
                  paincount+=1
                end
                if paincount>0 && paincount>maxpain
                  maxpain=paincount
                  storedmon = count
                  switchscore+=70
                end
              end
              if storedmon>-1
                monarray.push(storedmon)
              end
            end
          end
        end
      end
      count = -1
      storedmon = -1
      storedhp = -1
      for i in party
        count+=1
        next if i.nil?
        next if i.totalhp==0
        next if count == currentmon.pokemonIndex
        next if !pbCanSwitchLax?(currentmon.index,count,false)
        if storedhp < 0
          storedhp = i.hp/(i.totalhp.to_f)
          storedmon = i #count
          storedcount = count
        else
          if storedhp > i.hp/(i.totalhp.to_f)
            storedhp = i.hp/(i.totalhp.to_f)
            storedmon = i #count
            storedcount = count
          end
        end
      end
      if storedhp < 0.20 && storedhp > 0
        if ((storedmon.speed < pbRoughStat(opponent1,PBStats::SPEED,skill)) && (
          storedmon.speed < pbRoughStat(opponent2,PBStats::SPEED,skill))) ||
          currentmon.pbOwnSide.effects[PBEffects::Spikes]>0 ||
          currentmon.pbOwnSide.effects[PBEffects::StealthRock]
          speedcheck = false
          for i in party
            next if i.nil?
            next if i==storedmon
            if i.speed > pbRoughStat(opponent1,PBStats::SPEED,skill)
              speedcheck = true
            end
          end
          if speedcheck
            monarray.push(storedcount)
            switchscore+=20
          end
        end
      end
      maxlevel = -1
      for i in party
        next if i.nil?
        if maxlevel < 0
          maxlevel = i.level
        else
          if maxlevel < i.level
            maxlevel = i.level
          end
        end
      end
      if maxlevel>(opponent1.level+10)
        switchscore-=100
        if maxlevel>(opponent1.level+20)
          switchscore-=1000
        end
      end
      PBDebug.log(sprintf("%s: initial switchscore: %d",PBSpecies.getName(@battlers[index].species),switchscore)) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      # Stat Stages
      PBDebug.log(sprintf("Initial noswitchscore building: Stat Stages (%d)",noswitchscore)) if $INTERNAL
      specialmove = false
      physmove = false
      for i in currentmon.moves
        specialmove = true if i.pbIsSpecial?(i.type)
        physmove = true if i.pbIsPhysical?(i.type)
      end
      if currentroles.include?(PBMonRoles::SWEEPER)
        noswitchscore+= (30)*currentmon.stages[PBStats::ATTACK] if currentmon.stages[PBStats::ATTACK]>0 && physmove
        noswitchscore+= (30)*currentmon.stages[PBStats::SPATK] if currentmon.stages[PBStats::SPATK]>0 && specialmove
        noswitchscore+= (30)*currentmon.stages[PBStats::SPEED] if currentmon.stages[PBStats::SPEED]>0 unless (currentroles.include?(PBMonRoles::PHYSICALWALL) ||
                                                                                                              currentroles.include?(PBMonRoles::SPECIALWALL) ||
                                                                                                              currentroles.include?(PBMonRoles::TANK))
      else
        noswitchscore+= (15)*currentmon.stages[PBStats::ATTACK] if currentmon.stages[PBStats::ATTACK]>0 && physmove
        noswitchscore+= (15)*currentmon.stages[PBStats::SPATK] if currentmon.stages[PBStats::SPATK]>0 && specialmove
        noswitchscore+= (15)*currentmon.stages[PBStats::SPEED] if currentmon.stages[PBStats::SPEED]>0 unless (currentroles.include?(PBMonRoles::PHYSICALWALL) ||
                                                                                                              currentroles.include?(PBMonRoles::SPECIALWALL) ||
                                                                                                              currentroles.include?(PBMonRoles::TANK))
      end
      if currentroles.include?(PBMonRoles::PHYSICALWALL)
        noswitchscore+= (30)*currentmon.stages[PBStats::DEFENSE] if currentmon.stages[PBStats::DEFENSE]<0
      else
        noswitchscore+= (15)*currentmon.stages[PBStats::DEFENSE] if currentmon.stages[PBStats::DEFENSE]<0
      end
      if currentroles.include?(PBMonRoles::SPECIALWALL)
        noswitchscore+= (30)*currentmon.stages[PBStats::SPDEF] if currentmon.stages[PBStats::SPDEF]<0
      else
        noswitchscore+= (15)*currentmon.stages[PBStats::SPDEF] if currentmon.stages[PBStats::SPDEF]<0
      end
      # Entry Hazards
      PBDebug.log(sprintf("Initial noswitchscore building: Entry Hazards (%d)",noswitchscore)) if $INTERNAL
      noswitchscore+= (15)*currentmon.pbOwnSide.effects[PBEffects::Spikes]
      noswitchscore+= (15)*currentmon.pbOwnSide.effects[PBEffects::ToxicSpikes]
      noswitchscore+= (15) if currentmon.pbOwnSide.effects[PBEffects::StealthRock]
      noswitchscore+= (15) if currentmon.pbOwnSide.effects[PBEffects::StickyWeb]
      noswitchscore+= (15) if (currentmon.pbOwnSide.effects[PBEffects::StickyWeb] && currentroles.include?(PBMonRoles::SWEEPER))
      airmon = currentmon.isAirborne?
      hazarddam = totalHazardDamage(currentmon.pbOwnSide,currentmon.type1,currentmon.type2,airmon,skill)
      if ((currentmon.hp.to_f)/currentmon.totalhp)*100 < hazarddam
        noswitchscore+= 100
      end
      temppartyko = true
      for i in party
        count+=1
        next if i.nil?
        next if count == currentmon.pokemonIndex
        temproles = pbGetMonRole(i,opponent1,skill,count,party)
        next if temproles.include?(PBMonRoles::ACE)
        tempdam = totalHazardDamage(currentmon.pbOwnSide,i.type1,i.type2,i.isAirborne?,skill)
        if ((i.hp.to_f)/i.totalhp)*100 > tempdam
          temppartyko = false
        end
      end
      if temppartyko
        noswitchscore+= 200
      end
      # Better Switching Options
      PBDebug.log(sprintf("Initial noswitchscore building: Better Switching Options (%d)",noswitchscore)) if $INTERNAL
      if pbRoughStat(currentmon,PBStats::SPEED,skill) > pbRoughStat(opponent1,PBStats::SPEED,skill)
        if currentmon.pbHasMove?((PBMoves::VOLTSWITCH)) || currentmon.pbHasMove?((PBMoves::UTURN))
          noswitchscore+=90
        end
      end
      if currentmon.effects[PBEffects::PerishSong]==0 && currentmon.pbHasMove?((PBMoves::BATONPASS))
        noswitchscore+=90
      end
      if (!currentmon.abilitynulled && currentmon.ability == PBAbilities::WIMPOUT) ||
         (!currentmon.abilitynulled && currentmon.ability == PBAbilities::EMERGENCYEXIT)
        noswitchscore+=60
      end
      # Second Wind Situations
      PBDebug.log(sprintf("Initial noswitchscore building: Second Wind Situations (%d)",noswitchscore)) if $INTERNAL
      if !checkAIpriority(aimem)
        if pbRoughStat(currentmon,PBStats::SPEED,skill) > pbRoughStat(opponent1,PBStats::SPEED,skill)
          maxdam = 0
          for i in currentmon.moves
            if opponent1.hp>0
              tempdam = (pbRoughDamage(i,opponent1,currentmon,skill,i.basedamage)*100/opponent1.hp)
            else
              tempdam=0
            end
            if tempdam > maxdam
              maxdam = tempdam
            end
          end
          if maxdam > 100
            noswitchscore+=130
          end
        end
        if pbRoughStat(currentmon,PBStats::SPEED,skill) > pbRoughStat(opponent2,PBStats::SPEED,skill)
          maxdam = 0
          for i in currentmon.moves
            if opponent2.hp>0
              tempdam = (pbRoughDamage(i,opponent2,currentmon,skill,i.basedamage)*100/opponent2.hp)
            else
              tempdam=0
            end
            if tempdam > maxdam
              maxdam = tempdam
            end
          end
          if maxdam > 100
            noswitchscore+=130
          end
        end
        maxdam = 0
        for i in currentmon.moves
          next if i.priority < 1
          if opponent1.hp>0
            tempdam = (pbRoughDamage(i,opponent1,currentmon,skill,i.basedamage)*100/opponent1.hp)
          else
            tempdam=0
          end
          if tempdam > maxdam
            maxdam = tempdam
          end
        end
        if maxdam > 100
          noswitchscore+=130
        end
        maxdam = 0
        for i in currentmon.moves
          next if i.priority < 1
          if opponent2.hp>0
            tempdam = (pbRoughDamage(i,opponent2,currentmon,skill,i.basedamage)*100/opponent2.hp)
          else
            tempdam=0
          end
          if tempdam > maxdam
            maxdam = tempdam
          end
        end
        if maxdam > 100
          noswitchscore+=130
        end
      end
      finalcrit = 0
      for i in currentmon.moves
        critrate1 = pbAICritRate(currentmon,opponent1,i)
        critrate2 = pbAICritRate(currentmon,opponent2,i)
        maxcrit = [critrate1,critrate2].max
        if finalcrit < maxcrit
          finalcrit = maxcrit
        end
      end
      if finalcrit == 1
        noswitchscore+=12.5
      elsif finalcrit == 2
        noswitchscore += 50
      elsif finalcrit == 3
        noswitchscore += 100
      end
      if currentmon.status==PBStatuses::SLEEP && currentmon.statusCount<3
        noswitchscore+=100
      end
      monturn = (100 - (currentmon.turncount*25))
      if currentroles.include?(PBMonRoles::LEAD)
        monturn /= 1.5
      end
      if monturn > 0
        noswitchscore+=monturn
      end
      PBDebug.log(sprintf("%s: initial noswitchscore: %d",PBSpecies.getName(@battlers[index].species),noswitchscore)) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      PBDebug.log(sprintf("{")) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      finalscore = switchscore - noswitchscore
      if skill<PBTrainerAI.highSkill
        finalscore/=2.0
      end
      if skill<PBTrainerAI.mediumSkill
        finalscore-=100
      end
      highscore = @scores.max
      PBDebug.log(sprintf("}")) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      PBDebug.log(sprintf("%s: highest move score: %d",PBSpecies.getName(@battlers[index].species),highscore)) if $INTERNAL
      PBDebug.log(sprintf("%s: final switching score: %d",PBSpecies.getName(@battlers[index].species),finalscore)) if $INTERNAL
      if finalscore > highscore
        PBDebug.log(sprintf("%s < %d, will switch",highscore,finalscore)) if $INTERNAL
        PBDebug.log(sprintf(" ")) if $INTERNAL
        willswitch = true
      else
        PBDebug.log(sprintf("%s > %d, will not switch",highscore,finalscore)) if $INTERNAL
        PBDebug.log(sprintf(" ")) if $INTERNAL
        willswitch = false
      end
      if willswitch
        memmons = monarray.length
        if memmons>0
          counts = Hash.new(0)
          monarray.each do |mon|
            counts[mon] += 1
          end
          storedswitch = -1
          storednumber = -1
          tievar = false
          for i in counts.keys
            if counts[i] > storednumber
              storedswitch = i
              storednumber = counts[i]
              tievar = true
            elsif counts[i] == storednumber
              tievar=true
            end
          end
          if !tievar
            PBDebug.log(sprintf("Switching to %s",PBSpecies.getName(pbParty(currentmon)[storedswitch].species))) if $INTERNAL
            return pbRegisterSwitch(currentmon.index,storedswitch)
          else
            wallvar = false
            monindex = -1
            for i in counts.keys
              temparr = pbGetMonRole(party[i],opponent1,skill,count,party)
              if temparr.include?(PBMonRoles::PHYSICALWALL) || temparr.include?(PBMonRoles::SPECIALWALL)
                wallvar = true
                monindex = i
              end
            end
            if wallvar
              return pbRegisterSwitch(currentmon.index,monindex)
            else
              maxhpvar = -1
              chosenmon = -1
              for i in counts.keys
                temphp = party[i].hp
                if temphp > maxhpvar
                  maxhpvar = temphp
                  chosenmon = i
                end
              end
              return pbRegisterSwitch(currentmon.index,chosenmon)
            end
          end
        else
          switchindex = pbSwitchTo(currentmon,party,skill)
          if switchindex==-1
            return false
          end
          return pbRegisterSwitch(currentmon.index,switchindex)
        end
      else
        return false
      end
    end

    def pbSpeedChangingSwitch(mon,currentmon)
      speed = mon.speed
      #if @unburdened
      #  speed=speed*2
      #end
      if currentmon.pbOwnSide.effects[PBEffects::Tailwind]>0
        speed=speed*2
      end
      if (mon.ability == PBAbilities::SWIFTSWIM) && pbWeather==PBWeather::RAINDANCE &&
         !(mon.item == PBItems::UTILITYUMBRELLA)
        speed=speed*2
      elsif ($fefieldeffect == 21 || $fefieldeffect == 22 || $fefieldeffect == 26) &&
         (mon.ability == PBAbilities::SWIFTSWIM)
        speed=speed*2
      elsif $fefieldeffect == 21 || $fefieldeffect == 26
        if (!mon.hasType?(:WATER) && !(mon.ability == PBAbilities::SURGESURFER)) &&
           !mon.isAirborne?
          speed=(speed*0.5).floor
        end
      elsif $fefieldeffect == 22
        if (!mon.hasType?(:WATER) && !(mon.ability == PBAbilities::SWIFTSWIM) &&
           !(mon.ability == PBAbilities::STEELWORKER))
          speed=(speed*0.25).floor
        end
      end
      if (mon.ability == PBAbilities::SLUSHRUSH) && (pbWeather==PBWeather::HAIL ||
        $fefieldeffect==13 || $fefieldeffect==28)
        speed=speed*2
      end
      if (mon.ability == PBAbilities::SURGESURFER) && (($fefieldeffect == 1) ||
        ($fefieldeffect==18) || ($fefieldeffect==21) || ($fefieldeffect==22) ||
        ($fefieldeffect==26))
        speed=speed*2
      end
      if (mon.ability == PBAbilities::TELEPATHY) && $fefieldeffect==37
        speed=speed*2
      end
      if $fefieldeffect == 35 && !mon.isAirborne?
        speed=(speed*0.5).floor
      end
      if (mon.ability == PBAbilities::CHLOROPHYLL) &&
        (pbWeather==PBWeather::SUNNYDAY ||
        ($fefieldeffect == 33 && $fecounter > 2)) && !(mon.item == PBItems::UTILITYUMBRELLA)
        speed=speed*2
      end
      if (mon.ability == PBAbilities::SANDRUSH) &&
         (pbWeather==PBWeather::SANDSTORM ||
         $fefieldeffect == 12 || $fefieldeffect == 20)
        speed=speed*2
      end
      if (mon.ability == PBAbilities::QUICKFEET) && mon.status>0
        speed=(speed*1.5).floor
      end
      if (mon.item == PBItems::MACHOBRACE) ||
         (mon.item == PBItems::POWERWEIGHT) ||
         (mon.item == PBItems::POWERBRACER) ||
         (mon.item == PBItems::POWERBELT) ||
         (mon.item == PBItems::POWERANKLET) ||
         (mon.item == PBItems::POWERLENS) ||
         (mon.item == PBItems::POWERBAND)
        speed=(speed/2).floor
      end
      if (mon.item == PBItems::CHOICESCARF)
        speed=(speed*1.5).floor
      end
      if mon.item == PBItems::IRONBALL && mon.ability != PBAbilities::KLUTZ
        speed=(speed/2).floor
      end
      if mon.species == PBSpecies::DITTO && mon.item == PBItems::QUICKPOWDER
        speed=speed*2
      end
      if (mon.ability == PBAbilities::SLOWSTART)
        speed=(speed/2).floor
      end
      if mon.status==PBStatuses::PARALYSIS && !(mon.ability == PBAbilities::QUICKFEET)
        speed=(speed/2).floor
      end
      if currentmon.pbOwnSide.effects[PBEffects::StickyWeb] && !mon.isAirborne? &&
         ($fefieldeffect != 15) &&
         !(mon.ability == PBAbilities::WHITESMOKE) &&
         !(mon.ability == PBAbilities::CLEARBODY) &&
         !(mon.ability == PBAbilities::CONTRARY)
        speed=(speed*2/3).floor
      elsif currentmon.pbOwnSide.effects[PBEffects::StickyWeb] && !mon.isAirborne? &&
         ($fefieldeffect == 15) &&
         !(mon.ability == PBAbilities::WHITESMOKE) &&
         !(mon.ability == PBAbilities::CLEARBODY) &&
         !(mon.ability == PBAbilities::CONTRARY)
        speed=(speed*0.5).floor
      elsif currentmon.pbOwnSide.effects[PBEffects::StickyWeb] && !mon.isAirborne? &&
         ($fefieldeffect != 15) &&
         (mon.ability == PBAbilities::CONTRARY)
        speed=(speed*1.5).floor
      elsif currentmon.pbOwnSide.effects[PBEffects::StickyWeb] && !mon.isAirborne? &
         ($fefieldeffect == 15) &&
         (mon.ability == PBAbilities::CONTRARY)
        speed=speed*2
      end
      speed = 1 if speed <= 0
      return speed
    end

    def pbSwitchTo(currentmon,party,skill)
      opponent1 = currentmon.pbOppositeOpposing
      opponent2 = opponent1.pbPartner
      opp1roles = pbGetMonRole(opponent1,currentmon,skill)
      opp2roles = pbGetMonRole(opponent2,currentmon,skill)
      aimem = getAIMemory(skill,opponent1.pokemonIndex)
      aimem2 = getAIMemory(skill,opponent2.pokemonIndex)
      if skill<PBTrainerAI.mediumSkill
        loop do
          @ranvar = rand(party.length)
          break if ((@ranvar != currentmon.pokemonIndex) && pbCanSwitchLax?(currentmon.index,@ranvar,false))
        end
        return @ranvar
      end
      scorearray = []
      supercount=-1
      #for i in party
      for loopdawoop in 0...party.length
        i = party[loopdawoop].clone rescue nil
        nonmegaform = i.clone rescue nil
        supercount+=1
        if i.nil?
          scorearray.push(-10000000)
          next
        end
        PBDebug.log(sprintf("Scoring for %s switching to: %s",PBSpecies.getName(currentmon.species),PBSpecies.getName(i.species))) if $INTERNAL
        if !pbCanSwitchLax?(currentmon.index,supercount,false)
          scorearray.push(-10000000)
          PBDebug.log(sprintf("Score: -10000000")) if $INTERNAL
          PBDebug.log(sprintf(" ")) if $INTERNAL
          next
        end
        theseRoles = pbGetMonRole(i,opponent1,skill,supercount,party)
        if theseRoles.include?(PBMonRoles::PHYSICALWALL) || theseRoles.include?(PBMonRoles::SPECIALWALL)
          wallvar = true
        else
          wallvar = false
        end
        monscore = 0
        if (i.ability == PBAbilities::IMPOSTER)
          if @doublebattle
            i = opponent2.pokemon
            monscore += 20*opponent2.stages[PBStats::ATTACK]
            monscore += 20*opponent2.stages[PBStats::SPATK]
            monscore += 20*opponent2.stages[PBStats::SPEED]
          else
            i = opponent1.pokemon
            monscore += 20*opponent1.stages[PBStats::ATTACK]
            monscore += 20*opponent1.stages[PBStats::SPATK]
            monscore += 20*opponent1.stages[PBStats::SPEED]
          end
        end
        #Don't switch to already inplay mon
        if currentmon.pokemonIndex == scorearray.length
          scorearray.push(-10000000)
          PBDebug.log(sprintf("Score: -10000000")) if $INTERNAL
          PBDebug.log(sprintf(" ")) if $INTERNAL
          next
        end
        if supercount==pbParty(currentmon.index).length-1 && $game_switches[1000]
          scorearray.push(-10000)
          PBDebug.log(sprintf("Score: -10000")) if $INTERNAL
          PBDebug.log(sprintf(" ")) if $INTERNAL
          next
        end
        if i.hp <= 0
          scorearray.push(-10000000)
          PBDebug.log(sprintf("Score: -10000000")) if $INTERNAL
          PBDebug.log(sprintf(" ")) if $INTERNAL
          next
        end
        sedamagevar = 0
        if pbCanMegaEvolveAI?(i,currentmon.index)
          i.makeMega
        end
        #speed changing
        i.speed = pbSpeedChangingSwitch(i,currentmon)
        nonmegaform.speed = pbSpeedChangingSwitch(nonmegaform,currentmon)
        sedamagevar = 0
        #Defensive
        if aimem.length > 0
          for j in aimem
            totalmod = j.pbTypeModifierNonBattler(j.type,opponent1,i)
            if totalmod > 4
              sedamagevar = j.basedamage if j.basedamage>sedamagevar
              if totalmod >= 16
                sedamagevar*=2
              end
              if j.type == opponent1.type1 || j.type == opponent1.type2
                sedamagevar*=1.5
              end
            end
          end
          monscore-=sedamagevar
        end
        immunevar = 0
        resistvar = 0
        bestresist = false
        bestimmune = false
        count = 0
        movedamages = []
        bestmoveindex = -1
        if aimem.length > 0 && skill>=PBTrainerAI.highSkill
          for j in aimem
            movedamages.push(j.basedamage)
          end
          if movedamages.length > 0
            bestmoveindex = movedamages.index(movedamages.max)
          end
          for j in aimem
            totalmod = j.pbTypeModifierNonBattler(j.type,opponent1,i)
            if bestmoveindex > -1
              if count == bestmoveindex
                if totalmod == 0
                  bestimmune = true
                elsif totalmod == 1 || totalmod == 2
                  bestresist = true
                end
              end
            end
            if totalmod == 0
              immunevar+=1
            elsif totalmod == 1 || totalmod == 2
              resistvar+=1
            end
            count+=1
          end
          if immunevar == 4
            if wallvar
              monscore+=300
            else
              monscore+=200
            end
          elsif bestimmune
            if wallvar
              monscore+=90
            else
              monscore+=60
            end
          end
          if immunevar+resistvar == 4 && immunevar!=4
            if wallvar
              monscore+=150
            else
              monscore+=100
            end
          elsif bestresist
            if wallvar
              monscore+=45
            else
              monscore+=30
            end
          end
        elsif aimem.length > 0
          for j in aimem
            totalmod = j.pbTypeModifierNonBattler(j.type,opponent1,i)
            if totalmod == 0
              bestimmune=true
            elsif totalmod == 1 || totalmod == 2
              bestresist=true
            end
          end
          if bestimmune
            if wallvar
              monscore+=90
            else
              monscore+=60
            end
          end
          if bestresist
            if wallvar
              monscore+=45
            else
              monscore+=30
            end
          end
        end
        otype1 = opponent1.type1
        otype2 = opponent1.type2
        otype3 = opponent2.type1
        otype4 = opponent2.type2
        atype1 = i.type1
        atype2 = i.type2
        stabresist1a = PBTypes.getEffectiveness(otype1,atype1)
        if atype1!=atype2
          stabresist1b = PBTypes.getEffectiveness(otype1,atype2)
        else
          stabresist1b = 2
        end
        stabresist2a = PBTypes.getEffectiveness(otype2,atype1)
        if atype1!=atype2
          stabresist2b = PBTypes.getEffectiveness(otype2,atype2)
        else
          stabresist2b = 2
        end
        stabresist3a = PBTypes.getEffectiveness(otype3,atype1)
        if atype1!=atype2
          stabresist3b = PBTypes.getEffectiveness(otype3,atype2)
        else
          stabresist3b = 2
        end
        stabresist4a = PBTypes.getEffectiveness(otype4,atype1)
        if atype1!=atype2
          stabresist4b = PBTypes.getEffectiveness(otype4,atype2)
        else
          stabresist4b = 2
        end
        if stabresist1a*stabresist1b<4 || stabresist2a*stabresist2b<4
          monscore+=40
          if otype1==otype2
            monscore+=30
          else
            if stabresist1a*stabresist1b<4 && stabresist2a*stabresist2b<4
              monscore+=60
            end
          end
        elsif stabresist1a*stabresist1b>4 || stabresist2a*stabresist2b>4
          monscore-=40
          if otype1==otype2
            monscore-=30
          else
            if stabresist1a*stabresist1b>4 && stabresist2a*stabresist2b>4
              monscore-=60
            end
          end
        end
        if stabresist3a*stabresist3b<4 || stabresist4a*stabresist4b<4
          monscore+=40
          if otype3==otype4
            monscore+=30
          else
            if stabresist3a*stabresist3b<4 && stabresist4a*stabresist4b<4
              monscore+=60
            end
          end
        elsif stabresist3a*stabresist3b>4 || stabresist4a*stabresist4b>4
          monscore-=40
          if otype3==otype4
            monscore-=30
          else
            if stabresist3a*stabresist3b>4 && stabresist4a*stabresist4b>4
              monscore-=60
            end
          end
        end
        PBDebug.log(sprintf("Defensive: %d",monscore)) if $INTERNAL
        # Offensive
        maxbasedam = -1
        bestmove = -1
        for k in i.moves
          j = PokeBattle_Move.new(self,k,i)
          basedam = j.basedamage
          if (j.pbTypeModifierNonBattler(j.type,i,opponent1)>4) ||
             ((j.pbTypeModifierNonBattler(j.type,i,opponent2)>4) && opponent2.totalhp !=0)
            basedam*=2
            if (j.pbTypeModifierNonBattler(j.type,i,opponent1)==16) ||
               ((j.pbTypeModifierNonBattler(j.type,i,opponent2)==16) && opponent2.totalhp !=0)
              basedam*=2
            end
          end
          if (j.pbTypeModifierNonBattler(j.type,i,opponent1)<4) ||
             ((j.pbTypeModifierNonBattler(j.type,i,opponent2)<4) && opponent2.totalhp !=0)
            basedam/=2.0
            if (j.pbTypeModifierNonBattler(j.type,i,opponent1)==1) ||
               ((j.pbTypeModifierNonBattler(j.type,i,opponent2)==1) && opponent2.totalhp !=0)
              basedam/=2.0
            end
          end
          if (j.pbTypeModifierNonBattler(j.type,i,opponent1)==0) ||
             ((j.pbTypeModifierNonBattler(j.type,i,opponent2)==0) && opponent2.totalhp !=0)
            basedam=0
          end
          if (j.pbTypeModifierNonBattler(j.type,i,opponent1)<=4 &&
             (!opponent1.abilitynulled && opponent1.ability == PBAbilities::WONDERGUARD)) ||
             ((j.pbTypeModifierNonBattler(j.type,i,opponent2)<=4 && (!opponent2.abilitynulled && opponent2.ability == PBAbilities::WONDERGUARD)) &&
             opponent2.totalhp !=0)
            basedam=0
          end
          if (((!opponent1.abilitynulled && opponent1.ability == PBAbilities::STORMDRAIN) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::STORMDRAIN) ||
             (!opponent1.abilitynulled && opponent1.ability == PBAbilities::WATERABSORB) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::WATERABSORB) ||
             (!opponent1.abilitynulled && opponent1.ability == PBAbilities::DRYSKIN) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::DRYSKIN)) &&
             (j.type == PBTypes::WATER)) ||
             (((!opponent1.abilitynulled && opponent1.ability == PBAbilities::VOLTABSORB) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::VOLTABSORB) ||
             (!opponent1.abilitynulled && opponent1.ability == PBAbilities::MOTORDRIVE) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::MOTORDRIVE)) &&
             (j.type == PBTypes::ELECTRIC)) ||
             (((!opponent1.abilitynulled && opponent1.ability == PBAbilities::FLASHFIRE) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::FLASHFIRE)) &&
             (j.type == PBTypes::FIRE)) ||
             (((!opponent1.abilitynulled && opponent1.ability == PBAbilities::SAPSIPPER) || (!opponent2.abilitynulled && opponent2.ability == PBAbilities::SAPSIPPER)) &&
             (j.type == PBTypes::GRASS))
            basedam=0
          end
          if j.pbIsPhysical?(j.type) && i.status==PBStatuses::BURN
            basedam/=2.0
          end
          if skill>=PBTrainerAI.highSkill
            if i.hasType?(j.type)
              basedam*=1.5
            end
          end
          if j.accuracy!=0
            basedam*=(j.accuracy/100.0)
          end
          if basedam>maxbasedam
            maxbasedam = basedam
            bestmove = j
          end
        end
        if bestmove!=-1
          if bestmove.priority>0
            maxbasedam*=1.5
          end
        end
        if i.speed<pbRoughStat(opponent1,PBStats::SPEED,skill) ||
           i.speed<pbRoughStat(opponent2,PBStats::SPEED,skill)
          maxbasedam*=0.75
        else
          maxbasedam*=1.25
        end
        if maxbasedam==0
          monscore-=80
        else
          monscore+=maxbasedam
          ministat=0
          if i.attack > i.spatk
            ministat = [opponent1.stages[PBStats::SPDEF] - opponent1.stages[PBStats::DEFENSE],
                        opponent2.stages[PBStats::SPDEF] - opponent2.stages[PBStats::DEFENSE]].max
          else
            ministat = [opponent1.stages[PBStats::DEFENSE] - opponent1.stages[PBStats::SPDEF],
                        opponent1.stages[PBStats::DEFENSE] - opponent1.stages[PBStats::SPDEF]].max
          end
          ministat*=20
          monscore+=ministat
        end
        PBDebug.log(sprintf("Offensive: %d",monscore)) if $INTERNAL
        #Roles
        if skill>=PBTrainerAI.highSkill
          if theseRoles.include?(PBMonRoles::SWEEPER)
            if currentmon.pbNonActivePokemonCount<2
              monscore+=60
            else
              monscore-=50
            end
            if i.attack >= i.spatk
              if (opponent1.defense<opponent1.spdef) || (opponent2.defense<opponent2.spdef)
                monscore+=30
              end
            end
            if i.spatk >= i.attack
              if (opponent1.spdef<opponent1.defense) || (opponent2.spdef<opponent2.defense)
                monscore+=30
              end
            end
            monscore+= (-10)* statchangecounter(opponent1,1,7,-1)
            monscore+= (-10)* statchangecounter(opponent2,1,7,-1)
            if ((i.speed > opponent1.pbSpeed) ^ (@trickroom!=0))
              monscore *= 1.3
            else
              monscore *= 0.7
            end
            if opponent1.status==PBStatuses::SLEEP || opponent1.status==PBStatuses::FROZEN
              monscore+=50
            end
          end
          if wallvar
            if theseRoles.include?(PBMonRoles::PHYSICALWALL) &&
               (opponent1.spatk>opponent1.attack || opponent2.spatk>opponent2.attack)
              monscore+=30
            end
            if theseRoles.include?(PBMonRoles::SPECIALWALL) &&
               (opponent1.spatk<opponent1.attack || opponent2.spatk<opponent2.attack)
              monscore+=30
            end
            if opponent1.status==PBStatuses::BURN ||
               opponent1.status==PBStatuses::POISON ||
               opponent1.effects[PBEffects::LeechSeed]>0
              monscore+=30
            end
            if opponent2.status==PBStatuses::BURN ||
               opponent2.status==PBStatuses::POISON ||
               opponent2.effects[PBEffects::LeechSeed]>0
              monscore+=30
            end
          end
          if theseRoles.include?(PBMonRoles::TANK)
            if opponent1.status==PBStatuses::PARALYSIS || opponent1.effects[PBEffects::LeechSeed]>0
              monscore+=40
            end
            if opponent2.status==PBStatuses::PARALYSIS || opponent2.effects[PBEffects::LeechSeed]>0
              monscore+=40
            end
            if currentmon.pbOwnSide.effects[PBEffects::Tailwind]>0
              monscore+=30
            end
          end
          if theseRoles.include?(PBMonRoles::LEAD)
            monscore+=40
          end
          if theseRoles.include?(PBMonRoles::CLERIC)
            partystatus = false
            partymidhp = false
            for k in party
              next if k.nil?
              next if k==i
              next if k.totalhp==0
              if k.status!=0
                partystatus=true
              end
              if 0.3<((k.hp.to_f)/k.totalhp) && ((k.hp.to_f)/k.totalhp)<0.6
                partymidhp = true
              end
            end
            if partystatus
              monscore+=50
            end
            if partymidhp
              monscore+=50
            end
          end
          if theseRoles.include?(PBMonRoles::PHAZER)
            monscore+= (10)*opponent1.stages[PBStats::ATTACK] if opponent1.stages[PBStats::ATTACK]<0
            monscore+= (10)*opponent2.stages[PBStats::ATTACK] if opponent2.stages[PBStats::ATTACK]<0
            monscore+= (20)*opponent1.stages[PBStats::DEFENSE] if opponent1.stages[PBStats::DEFENSE]<0
            monscore+= (20)*opponent2.stages[PBStats::DEFENSE] if opponent2.stages[PBStats::DEFENSE]<0
            monscore+= (10)*opponent1.stages[PBStats::SPATK] if opponent1.stages[PBStats::SPATK]<0
            monscore+= (10)*opponent2.stages[PBStats::SPATK] if opponent2.stages[PBStats::SPATK]<0
            monscore+= (20)*opponent1.stages[PBStats::SPDEF] if opponent1.stages[PBStats::SPDEF]<0
            monscore+= (20)*opponent2.stages[PBStats::SPDEF] if opponent2.stages[PBStats::SPDEF]<0
            monscore+= (10)*opponent1.stages[PBStats::SPEED] if opponent1.stages[PBStats::SPEED]<0
            monscore+= (10)*opponent2.stages[PBStats::SPEED] if opponent2.stages[PBStats::SPEED]<0
            monscore+= (20)*opponent1.stages[PBStats::EVASION] if opponent1.stages[PBStats::ACCURACY]<0
            monscore+= (20)*opponent2.stages[PBStats::EVASION] if opponent2.stages[PBStats::ACCURACY]<0
          end
          if theseRoles.include?(PBMonRoles::SCREENER)
            monscore+=60
          end
          if theseRoles.include?(PBMonRoles::REVENGEKILLER)
            if opponent2.totalhp!=0 && opponent1.totalhp!=0
              if ((opponent1.hp.to_f)/opponent1.totalhp)<0.3 || ((opponent2.hp.to_f)/opponent2.totalhp)<0.3
                monscore+=110
              end
            elsif opponent1.totalhp!=0
              if ((opponent1.hp.to_f)/opponent1.totalhp)<0.3
                monscore+=110
              end
            elsif opponent2.totalhp!=0
              if ((opponent2.hp.to_f)/opponent2.totalhp)<0.3
                monscore+=110
              end
            end
          end
          if theseRoles.include?(PBMonRoles::SPINNER)
            if !opponent1.pbHasType?(:GHOST) && (opponent2.hp==0 || !opponent2.pbHasType?(:GHOST))
              monscore+=20*currentmon.pbOwnSide.effects[PBEffects::Spikes]
              monscore+=20*currentmon.pbOwnSide.effects[PBEffects::ToxicSpikes]
              monscore+=30 if currentmon.pbOwnSide.effects[PBEffects::StickyWeb]
              monscore+=30 if currentmon.pbOwnSide.effects[PBEffects::StealthRock]
            end
          end
          if theseRoles.include?(PBMonRoles::PIVOT)
            monscore+=40
          end
          if theseRoles.include?(PBMonRoles::BATONPASSER)
            monscore+=50
          end
          if theseRoles.include?(PBMonRoles::STALLBREAKER)
            monscore+=80 if checkAIhealing(aimem) || checkAIhealing(aimem2)
          end
          if theseRoles.include?(PBMonRoles::STATUSABSORBER)
            statusmove = false
            if aimem.length > 0
              for j in aimem
                statusmove=true if (j.id==(PBMoves::THUNDERWAVE) ||
                j.id==(PBMoves::TOXIC) || j.id==(PBMoves::SPORE) ||
                j.id==(PBMoves::SING) || j.id==(PBMoves::POISONPOWDER) ||
                j.id==(PBMoves::STUNSPORE) || j.id==(PBMoves::SLEEPPOWDER) ||
                j.id==(PBMoves::NUZZLE) || j.id==(PBMoves::WILLOWISP) ||
                j.id==(PBMoves::HYPNOSIS) || j.id==(PBMoves::GLARE) ||
                j.id==(PBMoves::DARKVOID) || j.id==(PBMoves::GRASSWHISTLE) ||
                j.id==(PBMoves::LOVELYKISS) || j.id==(PBMoves::POISONGAS) ||
                j.id==(PBMoves::TOXICTHREAD))
              end
            end
            if skill>=PBTrainerAI.bestSkill && aimem2.length!=0
              for j in aimem2
                statusmove=true if (j.id==(PBMoves::THUNDERWAVE) ||
                j.id==(PBMoves::TOXIC) || j.id==(PBMoves::SPORE) ||
                j.id==(PBMoves::SING) || j.id==(PBMoves::POISONPOWDER) ||
                j.id==(PBMoves::STUNSPORE) || j.id==(PBMoves::SLEEPPOWDER) ||
                j.id==(PBMoves::NUZZLE) || j.id==(PBMoves::WILLOWISP) ||
                j.id==(PBMoves::HYPNOSIS) || j.id==(PBMoves::GLARE) ||
                j.id==(PBMoves::DARKVOID) || j.id==(PBMoves::GRASSWHISTLE) ||
                j.id==(PBMoves::LOVELYKISS) || j.id==(PBMoves::POISONGAS) ||
                j.id==(PBMoves::TOXICTHREAD))
              end
            end
            monscore+=70 if statusmove
          end
          if theseRoles.include?(PBMonRoles::TRAPPER)
            if ((i.speed>opponent1.pbSpeed) ^ (@trickroom!=0))
              if opponent1.totalhp!=0
                if (opponent1.hp.to_f)/opponent1.totalhp<0.6
                  monscore+=100
                end
              end
            end
          end
          if theseRoles.include?(PBMonRoles::WEATHERSETTER)
            monscore+=30
            if (i.ability == PBAbilities::DROUGHT) ||
               (nonmegaform.ability == PBAbilities::DROUGHT) ||
               i.knowsMove?(:SUNNYDAY)
              if @weather!=PBWeather::SUNNYDAY
                monscore+=60
              end
            elsif (i.ability == PBAbilities::DRIZZLE) ||
               (nonmegaform.ability == PBAbilities::DRIZZLE) ||
               i.knowsMove?(:RAINDANCE)
              if @weather!=PBWeather::RAINDANCE
                monscore+=60
              end
            elsif (i.ability == PBAbilities::SANDSTREAM) ||
               (nonmegaform.ability == PBAbilities::SANDSTREAM) ||
               i.knowsMove?(:SANDSTORM)
              if @weather!=PBWeather::SANDSTORM
                monscore+=60
              end
            elsif (i.ability == PBAbilities::SNOWWARNING) ||
               (nonmegaform.ability == PBAbilities::SNOWWARNING) ||
               i.knowsMove?(:HAIL)
              if @weather!=PBWeather::HAIL
                monscore+=60
              end
            elsif (i.ability == PBAbilities::PRIMORDIALSEA) ||
               (i.ability == PBAbilities::DESOLATELAND) ||
               (i.ability == PBAbilities::DELTASTREAM) ||
               (nonmegaform.ability == PBAbilities::PRIMORDIALSEA) ||
               (nonmegaform.ability == PBAbilities::DESOLATELAND) ||
               (nonmegaform.ability == PBAbilities::DELTASTREAM) ||
              monscore+=60
            end
          end
        #  if theseRoles.include?(PBMonRoles::SECOND)
       #     monscore-=40
          #end
        end
        PBDebug.log(sprintf("Roles: %d",monscore)) if $INTERNAL
        # Weather
        case @weather
          when PBWeather::HAIL
            monscore+=25 if (i.ability == PBAbilities::MAGICGUARD) ||
                            (i.ability == PBAbilities::OVERCOAT) ||
                            i.hasType?(:ICE)
            monscore+=50 if (i.ability == PBAbilities::SNOWCLOAK) ||
                            (i.ability == PBAbilities::ICEBODY)
            monscore+=80 if (i.ability == PBAbilities::SLUSHRUSH)
          when PBWeather::RAINDANCE
              monscore+=50 if (i.ability == PBAbilities::DRYSKIN) ||
                              (i.ability == PBAbilities::HYDRATION) ||
                              (i.ability == PBAbilities::RAINDISH)
              monscore+=80 if (i.ability == PBAbilities::SWIFTSWIM)
          when PBWeather::SUNNYDAY
            monscore-=40 if (i.ability == PBAbilities::DRYSKIN)
            monscore+=50 if (i.ability == PBAbilities::SOLARPOWER)
            monscore+=80 if (i.ability == PBAbilities::CHLOROPHYLL)
          when PBWeather::SANDSTORM
            monscore+=25 if (i.ability == PBAbilities::MAGICGUARD) ||
                            (i.ability == PBAbilities::OVERCOAT) ||
                            i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)
            monscore+=50 if (i.ability == PBAbilities::SANDVEIL) ||
                            (i.ability == PBAbilities::SANDFORCE)
            monscore+=80 if (i.ability == PBAbilities::SANDRUSH)
        end
        if @trickroom>0
          if i.speed<opponent1.pbSpeed
            monscore+=30
          else
            monscore-=30
          end
          if opponent2.totalhp > 0
            if i.speed<opponent2.pbSpeed
              monscore+=30
            else
              monscore-=30
            end
          end
        end
        PBDebug.log(sprintf("Weather: %d",monscore)) if $INTERNAL
        #Moves
        if skill>=PBTrainerAI.highSkill
          if currentmon.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
            if nonmegaform.hasType?(:POISON) && !nonmegaform.hasType?(:FLYING) &&
               !(nonmegaform.ability == PBAbilities::LEVITATE)
              monscore+=80
            end
            if nonmegaform.hasType?(:FLYING) || nonmegaform.hasType?(:STEEL) ||
               (nonmegaform.ability == PBAbilities::LEVITATE)
              monscore+=30
            end
          end
          if i.knowsMove?(:CLEARSMOG) || i.knowsMove?(:HAZE)
            monscore+= (10)* statchangecounter(opponent1,1,7,1)
            monscore+= (10)* statchangecounter(opponent2,1,7,1)
          end
          if i.knowsMove?(:FAKEOUT) || i.knowsMove?(:FIRSTIMPRESSION)
            monscore+=25
          end
          if currentmon.pbPartner.totalhp != 0
            if i.knowsMove?(:FUSIONBOLT) && currentmon.pbPartner.pbHasMove?((PBMoves::FUSIONFLARE))
              monscore+=70
            end
            if i.knowsMove?(:FUSIONFLARE) && currentmon.pbPartner.pbHasMove?((PBMoves::FUSIONBOLT))
              monscore+=70
            end
          end
          if i.knowsMove?(:RETALIATE) && currentmon.pbOwnSide.effects[PBEffects::Retaliate]
            monscore+=30
          end
          if opponent1.totalhp>0
            if i.knowsMove?(:FELLSTINGER) && (((i.speed>opponent1.pbSpeed) ^ (@trickroom!=0)) &&
               (opponent1.hp.to_f)/opponent1.totalhp<0.2)
              monscore+=50
            end
          end
          if opponent2.totalhp>0
            if i.knowsMove?(:FELLSTINGER) && (((i.speed>opponent2.pbSpeed) ^ (@trickroom!=0)) &&
               (opponent2.hp.to_f)/opponent2.totalhp<0.2)
              monscore+=50
            end
          end
          if i.knowsMove?(:TAILWIND)
            if currentmon.pbOwnSide.effects[PBEffects::Tailwind]>0
              monscore-=60
            else
              monscore+=30
            end
          end
          if i.knowsMove?(:PURSUIT) || i.knowsMove?(:SANDSTORM) || i.knowsMove?(:HAIL) ||
           i.knowsMove?(:TOXIC) || i.knowsMove?(:LEECHSEED)
            monscore+=70 if (opponent1.ability == PBAbilities::WONDERGUARD)
            monscore+=70 if (opponent2.ability == PBAbilities::WONDERGUARD)
          end
        end
        PBDebug.log(sprintf("Moves: %d",monscore)) if $INTERNAL
        #Abilities
        if skill>=PBTrainerAI.highSkill
          if (i.ability == PBAbilities::UNAWARE)
            monscore+= (10)* statchangecounter(opponent1,1,7,1)
            monscore+= (10)* statchangecounter(opponent2,1,7,1)
          end
          if (i.ability == PBAbilities::DROUGHT) ||
             (i.ability == PBAbilities::DESOLATELAND) ||
             (nonmegaform.ability == PBAbilities::DROUGHT) ||
             (nonmegaform.ability == PBAbilities::DESOLATELAND)
            monscore+=40 if opponent1.pbHasType?(:WATER)
            monscore+=40 if opponent2.pbHasType?(:WATER)
            typecheck=false
            if aimem.length!=0
              for j in aimem
                if (j.type == PBTypes::WATER)
                  typecheck=true
                end
              end
              monscore+=15 if typecheck
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              for j in aimem2
                if (j.type == PBTypes::WATER)
                  typecheck=true
                end
              end
              monscore+=15 if typecheck
            end
          end
          if (i.ability == PBAbilities::DRIZZLE) ||
             (i.ability == PBAbilities::PRIMORDIALSEA) ||
             (nonmegaform.ability == PBAbilities::DRIZZLE) ||
             (nonmegaform.ability == PBAbilities::PRIMORDIALSEA)
            monscore+=40 if opponent1.pbHasType?(:FIRE)
            monscore+=40 if opponent2.pbHasType?(:FIRE)
            typecheck=false
            if aimem.length!=0
              for j in aimem
                if (j.type == PBTypes::FIRE)
                  typecheck=true
                end
              end
              monscore+=15 if typecheck
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              for j in aimem2
                if (j.type == PBTypes::FIRE)
                  typecheck=true
                end
              end
              monscore+=15 if typecheck
            end
          end
          if (i.ability == PBAbilities::LIMBER)
            if aimem.length!=0
              monscore+=15 if checkAImoves(PBStuff::PARAMOVE,aimem)
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              monscore+=15 if checkAImoves(PBStuff::PARAMOVE,aimem2)
            end
          end
          if (i.ability == PBAbilities::OBLIVIOUS)
            monscore+=20 if (opponent1.ability == PBAbilities::CUTECHARM) ||
                            (opponent2.ability == PBAbilities::CUTECHARM)
            if aimem.length!=0
              monscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem)
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              monscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem2)
            end
          end
          if (i.ability == PBAbilities::COMPOUNDEYES)
            if (opponent1.item == PBItems::LAXINCENSE) ||
               (opponent1.item == PBItems::BRIGHTPOWDER) ||
               opponent1.stages[PBStats::EVASION]>0 ||
               ((opponent1.ability == PBAbilities::SANDVEIL) && @weather==PBWeather::SANDSTORM) ||
               ((opponent1.ability == PBAbilities::SNOWCLOAK) && @weather==PBWeather::HAIL)
              monscore+=25
            end
            if (opponent2.item == PBItems::LAXINCENSE) ||
               (opponent2.item == PBItems::BRIGHTPOWDER) ||
               opponent2.stages[PBStats::EVASION]>0 ||
               ((opponent2.ability == PBAbilities::SANDVEIL) && @weather==PBWeather::SANDSTORM) ||
               ((opponent2.ability == PBAbilities::SNOWCLOAK) && @weather==PBWeather::HAIL)
              monscore+=25
            end
          end
          if (i.ability == PBAbilities::COMATOSE)
            monscore+=20 if checkAImoves(PBStuff::BURNMOVE,aimem)
            monscore+=20 if checkAImoves(PBStuff::PARAMOVE,aimem)
            monscore+=20 if checkAImoves(PBStuff::SLEEPMOVE,aimem)
            monscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
          end
          if (i.ability == PBAbilities::INSOMNIA) || (i.ability == PBAbilities::VITALSPIRIT)
            monscore+=20 if checkAImoves(PBStuff::SLEEPMOVE,aimem)
          end
          if (i.ability == PBAbilities::POISONHEAL) ||
             (i.ability == PBAbilities::TOXICBOOST) ||
             (i.ability == PBAbilities::IMMUNITY)
            monscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
          end
          if (i.ability == PBAbilities::MAGICGUARD)
            monscore+=20 if checkAImoves([PBMoves::LEECHSEED],aimem)
            monscore+=20 if checkAImoves([PBMoves::WILLOWISP],aimem)
            monscore+=20 if checkAImoves(PBStuff::POISONMOVE,aimem)
          end
          if (i.ability == PBAbilities::WATERBUBBLE) ||
             (i.ability == PBAbilities::WATERVEIL) ||
             (i.ability == PBAbilities::FLAREBOOST)
            if checkAImoves([PBMoves::WILLOWISP],aimem)
              monscore+=10
              if (i.ability == PBAbilities::FLAREBOOST)
                monscore+=10
              end
            end
          end
          if (i.ability == PBAbilities::OWNTEMPO)
            monscore+=20 if checkAImoves(PBStuff::CONFUMOVE,aimem)
          end
          if (i.ability == PBAbilities::INTIMIDATE) ||
             (nonmegaform.ability == PBAbilities::INTIMIDATE) ||
             (i.ability == PBAbilities::FURCOAT) ||
             (i.ability == PBAbilities::STAMINA)
            if opponent1.attack>opponent1.spatk
              monscore+=40
            end
            if opponent2.attack>opponent2.spatk
              monscore+=40
            end
          end
          if (i.ability == PBAbilities::WONDERGUARD)
            dievar = false
            instantdievar=false
            if aimem.length!=0
              for j in aimem
                if (j.type == PBTypes::FIRE) || (j.type == PBTypes::GHOST) ||
                   (j.type == PBTypes::DARK) || (j.type == PBTypes::ROCK) ||
                   (j.type == PBTypes::FLYING)
                  dievar=true
                end
              end
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              for j in aimem2
                if (j.type == PBTypes::FIRE) || (j.type == PBTypes::GHOST) ||
                   (j.type == PBTypes::DARK) || (j.type == PBTypes::ROCK) ||
                   (j.type == PBTypes::FLYING)
                  dievar=true
                end
              end
            end
            if @weather==PBWeather::HAIL || PBWeather::SANDSTORM
              dievar=true
              instantdievar=true
            end
            if i.status==PBStatuses::BURN || i.status==PBStatuses::POISON
              dievar=true
              instantdievar=true
            end
            if currentmon.pbOwnSide.effects[PBEffects::StealthRock] ||
               currentmon.pbOwnSide.effects[PBEffects::Spikes]>0 ||
               currentmon.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
              dievar=true
              instantdievar=true
            end
            if (opponent1.ability == PBAbilities::MOLDBREAKER) ||
               (opponent1.ability == PBAbilities::TURBOBLAZE) ||
               (opponent1.ability == PBAbilities::TERAVOLT)
              dievar=true
            end
            if (opponent2.ability == PBAbilities::MOLDBREAKER) ||
               (opponent2.ability == PBAbilities::TURBOBLAZE) ||
               (opponent2.ability == PBAbilities::TERAVOLT)
              dievar=true
            end
            monscore+=90 if !dievar
            monscore-=90 if instantdievar
          end
          if (i.ability == PBAbilities::EFFECTSPORE) || (i.ability == PBAbilities::STATIC) ||
             (i.ability == PBAbilities::POISONPOINT) || (i.ability == PBAbilities::ROUGHSKIN) ||
             (i.ability == PBAbilities::IRONBARBS) || (i.ability == PBAbilities::FLAMEBODY) ||
             (i.ability == PBAbilities::CUTECHARM) || (i.ability == PBAbilities::MUMMY) ||
             (i.ability == PBAbilities::AFTERMATH) || (i.ability == PBAbilities::GOOEY) ||
             ((i.ability == PBAbilities::FLUFFY) && (!opponent1.pbHasType?(PBTypes::FIRE) && !opponent2.pbHasType?(PBTypes::FIRE)))
            monscore+=30 if checkAIbest(aimem,4) || checkAIbest(aimem2,4)
          end
          if (i.ability == PBAbilities::TRACE)
            if (opponent1.ability == PBAbilities::WATERABSORB) ||
              (opponent1.ability == PBAbilities::VOLTABSORB) ||
              (opponent1.ability == PBAbilities::STORMDRAIN) ||
              (opponent1.ability == PBAbilities::MOTORDRIVE) ||
              (opponent1.ability == PBAbilities::FLASHFIRE) ||
              (opponent1.ability == PBAbilities::LEVITATE) ||
              (opponent1.ability == PBAbilities::LIGHTNINGROD) ||
              (opponent1.ability == PBAbilities::SAPSIPPER) ||
              (opponent1.ability == PBAbilities::DRYSKIN) ||
              (opponent1.ability == PBAbilities::SLUSHRUSH) ||
              (opponent1.ability == PBAbilities::SANDRUSH) ||
              (opponent1.ability == PBAbilities::SWIFTSWIM) ||
              (opponent1.ability == PBAbilities::CHLOROPHYLL) ||
              (opponent1.ability == PBAbilities::SPEEDBOOST) ||
              (opponent1.ability == PBAbilities::WONDERGUARD) ||
              (opponent1.ability == PBAbilities::PRANKSTER) ||
              (i.speed>opponent1.pbSpeed && ((opponent1.ability == PBAbilities::ADAPTABILITY) || (opponent1.ability == PBAbilities::DOWNLOAD) || (opponent1.ability == PBAbilities::PROTEAN))) ||
              (opponent1.attack>opponent1.spatk && (opponent1.ability == PBAbilities::INTIMIDATE)) ||
              (opponent1.ability == PBAbilities::UNAWARE) ||
              (i.hp==i.totalhp && ((opponent1.ability == PBAbilities::MULTISCALE) || (opponent1.ability == PBAbilities::SHADOWSHIELD)))
              monscore+=60
            end
          end
          if (i.ability == PBAbilities::MAGMAARMOR)
            typecheck=false
            if aimem.length!=0
              for j in aimem
                if (j.type == PBTypes::ICE)
                  typecheck=true
                end
              end
              monscore+=20 if typecheck
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              for j in aimem2
                if (j.type == PBTypes::ICE)
                  typecheck=true
                end
              end
              monscore+=20 if typecheck
            end
          end
          if (i.ability == PBAbilities::SOUNDPROOF)
            monscore+=60 if checkAIbest(aimem,5) || checkAIbest(aimem2,5)
          end
          if (i.ability == PBAbilities::THICKFAT)
            monscore+=30 if checkAIbest(aimem,1,[PBTypes::ICE,PBTypes::FIRE]) || checkAIbest(aimem2,1,[PBTypes::ICE,PBTypes::FIRE])
          end
          if (i.ability == PBAbilities::WATERBUBBLE)
            monscore+=30 if checkAIbest(aimem,1,[PBTypes::FIRE]) || checkAIbest(aimem2,1,[PBTypes::FIRE])
          end
          if (i.ability == PBAbilities::LIQUIDOOZE)
            if aimem.length!=0
              for j in aimem
                monscore+=40 if  j.id==(PBMoves::LEECHSEED) || j.function==0xDD || j.function==0x139 || j.function==0x158
              end
            end
          end
          if (i.ability == PBAbilities::RIVALRY)
            if i.gender==opponent1.gender
              monscore+=30
            end
            if i.gender==opponent2.gender
              monscore+=30
            end
          end
          if (i.ability == PBAbilities::SCRAPPY)
            if opponent1.pbHasType?(PBTypes::GHOST)
              monscore+=30
            end
            if opponent2.pbHasType?(PBTypes::GHOST)
              monscore+=30
            end
          end
          if (i.ability == PBAbilities::LIGHTMETAL)
            monscore+=10 if checkAImoves([PBMoves::GRASSKNOT,PBMoves::LOWKICK],aimem)
          end
          if (i.ability == PBAbilities::ANALYTIC)
            if ((i.speed<opponent1.pbSpeed) ^ (@trickroom!=0))
              monscore+=30
            end
            if ((i.speed<opponent2.pbSpeed) ^ (@trickroom!=0))
              monscore+=30
            end
          end
          if (i.ability == PBAbilities::ILLUSION)
            monscore+=40
          end
          if (i.ability == PBAbilities::IMPOSTER)
            monscore+= (20)*opponent1.stages[PBStats::ATTACK]
            monscore+= (20)*opponent1.stages[PBStats::SPATK]
            monscore+=50 if (opponent1.ability == PBAbilities::PUREPOWER) ||
                            (opponent1.ability == PBAbilities::HUGEPOWER) ||
                            (opponent1.ability == PBAbilities::MOXIE) ||
                            (opponent1.ability == PBAbilities::SPEEDBOOST) ||
                            (opponent1.ability == PBAbilities::BEASTBOOST) ||
                            (opponent1.ability == PBAbilities::SOULHEART) ||
                            (opponent1.ability == PBAbilities::WONDERGUARD) ||
                            (opponent1.ability == PBAbilities::PROTEAN)
            monscore+=30 if (opponent1.level>i.level) || opp1roles.include?(PBMonRoles::SWEEPER)
            if opponent.effects[PBEffects::Substitute] > 0
              monscore = -200
            end
            if opponent1.species != PBSpecies::DITTO
              monscore = -500
            end
          end
          if (i.ability == PBAbilities::MOXIE) || (i.ability == PBAbilities::BEASTBOOST) || (i.ability == PBAbilities::SOULHEART)
            if opponent1.totalhp!=0
              monscore+=40 if ((i.speed>opponent1.pbSpeed) ^ (@trickroom!=0)) && ((opponent1.hp.to_f)/opponent1.totalhp<0.5)
            end
            if @doublebattle && opponent2.totalhp!=0
              monscore+=40 if ((i.speed>opponent2.pbSpeed) ^ (@trickroom!=0)) && ((opponent2.hp.to_f)/opponent2.totalhp<0.5)
            end
          end
          if (i.ability == PBAbilities::SPEEDBOOST)
            if opponent1.totalhp!=0
              monscore+=25 if (i.speed>opponent1.pbSpeed) && ((opponent1.hp.to_f)/opponent1.totalhp<0.3)
            end
            if @doublebattle && opponent2.totalhp!=0
              monscore+=25 if (i.speed>opponent2.pbSpeed) && ((opponent2.hp.to_f)/opponent2.totalhp<0.3)
            end
          end
          if (i.ability == PBAbilities::JUSTIFIED)
            monscore+=30 if checkAIbest(aimem,1,[PBTypes::DARK]) || checkAIbest(aimem2,1,[PBTypes::DARK])
          end
          if (i.ability == PBAbilities::RATTLED)
            monscore+=15 if checkAIbest(aimem,1,[PBTypes::DARK,PBTypes::GHOST,PBTypes::BUG]) || checkAIbest(aimem2,1,[PBTypes::DARK,PBTypes::GHOST,PBTypes::BUG])
          end
          if (i.ability == PBAbilities::IRONBARBS) || (i.ability == PBAbilities::ROUGHSKIN)
            monscore+=30 if (opponent1.ability == PBAbilities::SKILLLINK)
            monscore+=30 if (opponent2.ability == PBAbilities::SKILLLINK)
          end
          if (i.ability == PBAbilities::PRANKSTER)
            monscore+=50 if ((opponent1.pbSpeed>i.speed) ^ (@trickroom!=0)) && !opponent1.pbHasType?(PBTypes::DARK)
            monscore+=50 if ((opponent2.pbSpeed>i.speed) ^ (@trickroom!=0)) && !opponent2.pbHasType?(PBTypes::DARK)
          end
          if (i.ability == PBAbilities::GALEWINGS)
            monscore+=50 if ((opponent1.pbSpeed>i.speed) ^ (@trickroom!=0)) && i.hp==i.totalhp && !currentmon.pbOwnSide.effects[PBEffects::StealthRock]
            monscore+=50 if ((opponent2.pbSpeed>i.speed) ^ (@trickroom!=0)) && i.hp==i.totalhp && !currentmon.pbOwnSide.effects[PBEffects::StealthRock]
          end
          if (i.ability == PBAbilities::BULLETPROOF)
            monscore+=60 if checkAIbest(aimem,6) || checkAIbest(aimem2,6)
          end
          if (i.ability == PBAbilities::AURABREAK)
            monscore+=50 if (opponent1.ability == PBAbilities::FAIRYAURA) || (opponent1.ability == PBAbilities::DARKAURA)
            monscore+=50 if (opponent2.ability == PBAbilities::FAIRYAURA) || (opponent2.ability == PBAbilities::DARKAURA)
          end
          if (i.ability == PBAbilities::PROTEAN)
            monscore+=40 if ((i.speed>opponent1.pbSpeed) ^ (@trickroom!=0)) || ((i.speed>opponent2.pbSpeed) ^ (@trickroom!=0))
          end
          if (i.ability == PBAbilities::DANCER)
            monscore+=30 if checkAImoves(PBStuff::DANCEMOVE,aimem)
            monscore+=30 if checkAImoves(PBStuff::DANCEMOVE,aimem2) && skill>=PBTrainerAI.bestSkill
          end
          if (i.ability == PBAbilities::MERCILESS)
            if opponent1.status==PBStatuses::POISON || opponent2.status==PBStatuses::POISON
              monscore+=50
            end
          end
          if (i.ability == PBAbilities::DAZZLING) || (i.ability == PBAbilities::QUEENLYMAJESTY)
            monscore+=20 if checkAIpriority(aimem)
            monscore+=20 if checkAIpriority(aimem2) && skill>=PBTrainerAI.bestSkill
          end
          if (i.ability == PBAbilities::SANDSTREAM) || (i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SNOWWARNING)
            monscore+=70 if (opponent1.ability == PBAbilities::WONDERGUARD)
            monscore+=70 if (opponent2.ability == PBAbilities::WONDERGUARD)
          end
          if (i.ability == PBAbilities::DEFEATIST)
            if currentmon.hp != 0 # hard switch
              monscore -= 80
            end
          end
          if (i.ability == PBAbilities::STURDY) && i.hp == i.totalhp
            if currentmon.hp != 0 # hard switch
              monscore -= 80
            end
          end
        end
        PBDebug.log(sprintf("Abilities: %d",monscore)) if $INTERNAL
        #Items
        if skill>=PBTrainerAI.highSkill
          if (i.item == PBItems::ROCKYHELMET)
            monscore+=30 if (opponent1.ability == PBAbilities::SKILLLINK)
            monscore+=30 if (opponent2.ability == PBAbilities::SKILLLINK)
            monscore+=30 if checkAIbest(aimem,4) || checkAIbest(aimem2,4)
          end
          if (i.item == PBItems::AIRBALLOON)
            allground=true
            biggestpower=0
            groundcheck=false
            if aimem.length!=0
              for j in aimem
                if !(j.type == PBTypes::GROUND)
                  allground=false
                end
              end
            end
            if aimem2.length!=0 && skill>=PBTrainerAI.bestSkill
              for j in aimem2
                if !(j.type == PBTypes::GROUND)
                  allground=false
                end
              end
            end
            monscore+=60 if checkAIbest(aimem,1,[PBTypes::GROUND]) || checkAIbest(aimem2,1,[PBTypes::GROUND])
            monscore+=100 if allground
          end
          if (i.item == PBItems::FLOATSTONE)
            monscore+=10 if checkAImoves([PBMoves::LOWKICK,PBMoves::GRASSKNOT],aimem)
          end
          if (i.item == PBItems::DESTINYKNOT)
            monscore+=20 if (opponent1.ability == PBAbilities::CUTECHARM)
            monscore+=20 if checkAImoves([PBMoves::ATTRACT],aimem)
          end
          if (i.item == PBItems::ABSORBBULB)
            monscore+=25 if checkAIbest(aimem,1,[PBTypes::WATER]) || checkAIbest(aimem2,1,[PBTypes::WATER])
          end
          if (i.item == PBItems::CELLBATTERY)
            monscore+=25 if checkAIbest(aimem,1,[PBTypes::ELECTRIC]) || checkAIbest(aimem2,1,[PBTypes::ELECTRIC])
          end
          if (((i.item == PBItems::FOCUSSASH) || ((i.ability == PBAbilities::STURDY)))) && i.hp == i.totalhp
            if @weather==PBWeather::SANDSTORM || @weather==PBWeather::HAIL ||
              currentmon.pbOwnSide.effects[PBEffects::StealthRock] ||
              currentmon.pbOwnSide.effects[PBEffects::Spikes]>0 ||
              currentmon.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
              monscore-=30
            end
            if currentmon.hp != 0 # hard switch
              monscore -= 80
            end
            monscore+= (30)*opponent1.stages[PBStats::ATTACK]
            monscore+= (30)*opponent1.stages[PBStats::SPATK]
            monscore+= (30)*opponent1.stages[PBStats::SPEED]
          end
          if (i.item == PBItems::SNOWBALL)
            monscore+=25 if checkAIbest(aimem,1,[PBTypes::ICE]) || checkAIbest(aimem2,1,[PBTypes::ICE])
          end
          if (i.item == PBItems::PROTECTIVEPADS)
            if (i.ability == PBAbilities::EFFECTSPORE) || (i.ability == PBAbilities::STATIC) ||
               (i.ability == PBAbilities::POISONPOINT) || (i.ability == PBAbilities::ROUGHSKIN) ||
               (i.ability == PBAbilities::IRONBARBS) || (i.ability == PBAbilities::FLAMEBODY) ||
               (i.ability == PBAbilities::CUTECHARM) || (i.ability == PBAbilities::MUMMY) ||
               (i.ability == PBAbilities::AFTERMATH) || (i.ability == PBAbilities::GOOEY) ||
               ((i.ability == PBAbilities::FLUFFY) && (!opponent1.pbHasType?(PBTypes::FIRE) && !opponent2.pbHasType?(PBTypes::FIRE))) ||
               (opponent1.item == PBItems::ROCKYHELMET)
              monscore+=25
            end
          end
        end
        PBDebug.log(sprintf("Items: %d",monscore)) if $INTERNAL
        #Fields
        if skill>=PBTrainerAI.bestSkill
          case $fefieldeffect
            when 1
              monscore+=50 if (i.ability == PBAbilities::SURGESURFER)
              monscore+=25 if (i.ability == PBAbilities::GALVANIZE)
              monscore+=25 if i.hasType?(:ELECTRIC)
            when 2
              monscore+=30 if (i.ability == PBAbilities::GRASSPELT)
              monscore+=25 if i.hasType?(:GRASS) || i.hasType?(:FIRE)
            when 3
              monscore+=20 if i.hasType?(:FAIRY)
              monscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
              monscore+=20 if (i.ability == PBAbilities::DRYSKIN)
              monscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=25 if (i.ability == PBAbilities::PIXILATE)
              monscore+=25 if (i.ability == PBAbilities::SOULHEART)
            when 4
              monscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
              monscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
            when 5
              monscore+=10 if (i.ability == PBAbilities::ADAPTABILITY)
              monscore+=10 if (i.ability == PBAbilities::SYNCHRONIZE)
              monscore+=10 if (i.ability == PBAbilities::ANTICIPATION)
              monscore+=10 if (i.ability == PBAbilities::TELEPATHY)
            when 6
              monscore+=30 if (i.ability == PBAbilities::SHEERFORCE)
              monscore+=30 if (i.ability == PBAbilities::PUREPOWER)
              monscore+=30 if (i.ability == PBAbilities::HUGEPOWER)
              monscore+=30 if (i.ability == PBAbilities::GUTS)
              monscore+=10 if (i.ability == PBAbilities::DANCER)
              monscore+=20 if i.hasType?(:FIGHTING)
            when 7
              monscore+=25 if i.hasType?(:FIRE)
              monscore+=15 if (i.ability == PBAbilities::WATERVEIL)
              monscore+=15 if (i.ability == PBAbilities::WATERBUBBLE)
              monscore+=30 if (i.ability == PBAbilities::FLASHFIRE)
              monscore+=30 if (i.ability == PBAbilities::FLAREBOOST)
              monscore+=30 if (i.ability == PBAbilities::BLAZE)
              monscore-=30 if (i.ability == PBAbilities::ICEBODY)
              monscore-=30 if (i.ability == PBAbilities::LEAFGUARD)
              monscore-=30 if (i.ability == PBAbilities::GRASSPELT)
              monscore-=30 if (i.ability == PBAbilities::FLUFFY)
            when 8
              monscore+=15 if (i.ability == PBAbilities::GOOEY)
              monscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
            when 9
              monscore+=10 if (i.ability == PBAbilities::WONDERSKIN)
              monscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
              monscore+=25 if (i.ability == PBAbilities::SOULHEART)
              monscore+=30 if (i.ability == PBAbilities::CLOUDNINE)
              monscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
            when 10
              monscore+=20 if (i.ability == PBAbilities::POISONHEAL)
              monscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
              monscore+=30 if (i.ability == PBAbilities::MERCILESS)
              monscore+=30 if (i.ability == PBAbilities::CORROSION)
              monscore+=15 if i.hasType?(:POISON)
            when 11
              monscore+=10 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=20 if (i.ability == PBAbilities::POISONHEAL)
              monscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
              monscore+=30 if (i.ability == PBAbilities::MERCILESS)
              monscore+=30 if (i.ability == PBAbilities::CORROSION)
              monscore+=15 if i.hasType?(:POISON)
            when 12
              monscore+=20 if ((i.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SANDSTREAM))
              monscore+=25 if (i.ability == PBAbilities::SANDVEIL)
              monscore+=30 if (i.ability == PBAbilities::SANDFORCE)
              monscore+=50 if (i.ability == PBAbilities::SANDRUSH)
              monscore+=20 if i.hasType?(:GROUND)
              monscore-=25 if i.hasType?(:ELECTRIC)
            when 13
              monscore+=25 if i.hasType?(:ICE)
              monscore+=25 if (i.ability == PBAbilities::ICEBODY)
              monscore+=25 if (i.ability == PBAbilities::SNOWCLOAK)
              monscore+=25 if (i.ability == PBAbilities::REFRIGERATE)
              monscore+=50 if (i.ability == PBAbilities::SLUSHRUSH)
            when 14
            when 15
              monscore+=20 if (i.ability == PBAbilities::SAPSIPPER)
              monscore+=25 if i.hasType?(:GRASS) || i.hasType?(:BUG)
              monscore+=30 if (i.ability == PBAbilities::GRASSPELT)
              monscore+=30 if (i.ability == PBAbilities::OVERGROW)
              monscore+=30 if (i.ability == PBAbilities::SWARM)
            when 16
              monscore+=15 if i.hasType?(:FIRE)
            when 17
              monscore+=25 if i.hasType?(:ELECTRIC)
              monscore+=20 if (i.ability == PBAbilities::MOTORDRIVE)
              monscore+=20 if (i.ability == PBAbilities::STEELWORKER)
              monscore+=25 if (i.ability == PBAbilities::DOWNLOAD)
              monscore+=25 if (i.ability == PBAbilities::TECHNICIAN)
              monscore+=25 if (i.ability == PBAbilities::GALVANIZE)
            when 18
              monscore+=20 if (i.ability == PBAbilities::VOLTABSORB)
              monscore+=20 if (i.ability == PBAbilities::STATIC)
              monscore+=25 if (i.ability == PBAbilities::GALVANIZE)
              monscore+=50 if (i.ability == PBAbilities::SURGESURFER)
              monscore+=25 if i.hasType?(:ELECTRIC)
            when 19
              monscore+=10 if i.hasType?(:POISON)
              monscore+=10 if (i.ability == PBAbilities::CORROSION)
              monscore+=20 if (i.ability == PBAbilities::POISONHEAL)
              monscore+=20 if (i.ability == PBAbilities::EFFECTSPORE)
              monscore+=20 if (i.ability == PBAbilities::POISONPOINT)
              monscore+=20 if (i.ability == PBAbilities::STENCH)
              monscore+=20 if (i.ability == PBAbilities::GOOEY)
              monscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
              monscore+=30 if (i.ability == PBAbilities::MERCILESS)
            when 20
              monscore+=10 if i.hasType?(:FIGHTING)
              monscore+=15 if (i.ability == PBAbilities::OWNTEMPO)
              monscore+=15 if (i.ability == PBAbilities::PUREPOWER)
              monscore+=15 if (i.ability == PBAbilities::STEADFAST)
              monscore+=20 if ((i.ability == PBAbilities::SANDSTREAM) || (nonmegaform.ability == PBAbilities::SANDSTREAM))
              monscore+=20 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=30 if (i.ability == PBAbilities::SANDFORCE)
              monscore+=35 if (i.ability == PBAbilities::SANDVEIL)
              monscore+=50 if (i.ability == PBAbilities::SANDRUSH)
            when 21
              monscore+=25 if i.hasType?(:WATER)
              monscore+=25 if i.hasType?(:ELECTRIC)
              monscore+=25 if (i.ability == PBAbilities::WATERVEIL)
              monscore+=25 if (i.ability == PBAbilities::HYDRATION)
              monscore+=25 if (i.ability == PBAbilities::TORRENT)
              monscore+=25 if (i.ability == PBAbilities::SCHOOLING)
              monscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
              monscore+=50 if (i.ability == PBAbilities::SURGESURFER)
              mod1=PBTypes.getEffectiveness(PBTypes::WATER,i.type1)
              mod2=(i.type1==i.type2) ? 2 : PBTypes.getEffectiveness(PBTypes::WATER,i.type2)
              monscore-=50 if mod1*mod2>4
            when 22
              monscore+=25 if i.hasType?(:WATER)
              monscore+=25 if i.hasType?(:ELECTRIC)
              monscore+=25 if (i.ability == PBAbilities::WATERVEIL)
              monscore+=25 if (i.ability == PBAbilities::HYDRATION)
              monscore+=25 if (i.ability == PBAbilities::TORRENT)
              monscore+=25 if (i.ability == PBAbilities::SCHOOLING)
              monscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
              monscore+=50 if (i.ability == PBAbilities::SURGESURFER)
              mod1=PBTypes.getEffectiveness(PBTypes::WATER,i.type1)
              mod2=(i.type1==i.type2) ? 2 : PBTypes.getEffectiveness(PBTypes::WATER,i.type2)
              monscore-=50 if mod1*mod2>4
            when 23
              monscore+=15 if i.hasType?(:GROUND)
            when 24
            when 25
              monscore+=25 if i.hasType?(:DRAGON)
              monscore+=30 if (i.ability == PBAbilities::PRISMARMOR)
            when 26
              monscore+=25 if i.hasType?(:WATER)
              monscore+=25 if i.hasType?(:POISON)
              monscore+=25 if i.hasType?(:ELECTRIC)
              monscore+=25 if (i.ability == PBAbilities::SCHOOLING)
              monscore+=25 if (i.ability == PBAbilities::WATERCOMPACTION)
              monscore+=25 if (i.ability == PBAbilities::TOXICBOOST)
              monscore+=25 if (i.ability == PBAbilities::POISONHEAL)
              monscore+=25 if (i.ability == PBAbilities::MERCILESS)
              monscore+=50 if (i.ability == PBAbilities::SWIFTSWIM)
              monscore+=50 if (i.ability == PBAbilities::SURGESURFER)
              monscore+=20 if (i.ability == PBAbilities::GOOEY)
              monscore+=20 if (i.ability == PBAbilities::STENCH)
            when 27
              monscore+=25 if i.hasType?(:ROCK)
              monscore+=25 if i.hasType?(:FLYING)
              monscore+=20 if ((i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::SNOWWARNING))
              monscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
              monscore+=25 if (i.ability == PBAbilities::LONGREACH)
              monscore+=30 if (i.ability == PBAbilities::GALEWINGS) && @weather==PBWeather::STRONGWINDS
            when 28
              monscore+=25 if i.hasType?(:ROCK)
              monscore+=25 if i.hasType?(:FLYING)
              monscore+=25 if i.hasType?(:ICE)
              monscore+=20 if ((i.ability == PBAbilities::SNOWWARNING) || (nonmegaform.ability == PBAbilities::DROUGHT))
              monscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
              monscore+=20 if (i.ability == PBAbilities::ICEBODY)
              monscore+=20 if (i.ability == PBAbilities::SNOWCLOAK)
              monscore+=25 if (i.ability == PBAbilities::LONGREACH)
              monscore+=25 if (i.ability == PBAbilities::REFRIGERATE)
              monscore+=30 if (i.ability == PBAbilities::GALEWINGS) && @weather==PBWeather::STRONGWINDS
              monscore+=50 if (i.ability == PBAbilities::SLUSHRUSH)
            when 29
              monscore+=20 if i.hasType?(:NORMAL)
              monscore+=20 if (i.ability == PBAbilities::JUSTIFIED)
            when 30
              monscore+=25 if (i.ability == PBAbilities::SANDVEIL)
              monscore+=25 if (i.ability == PBAbilities::SNOWCLOAK)
              monscore+=25 if (i.ability == PBAbilities::ILLUSION)
              monscore+=25 if (i.ability == PBAbilities::TANGLEDFEET)
              monscore+=25 if (i.ability == PBAbilities::MAGICBOUNCE)
              monscore+=25 if (i.ability == PBAbilities::COLORCHANGE)
            when 31
              monscore+=25 if i.hasType?(:FAIRY)
              monscore+=25 if i.hasType?(:STEEL)
              monscore+=40 if i.hasType?(:DRAGON)
              monscore+=25 if (i.ability == PBAbilities::POWEROFALCHEMY)
              monscore+=25 if ((i.ability == PBAbilities::MAGICGUARD) || (nonmegaform.ability == PBAbilities::MAGICGUARD))
              monscore+=25 if (i.ability == PBAbilities::MAGICBOUNCE)
              monscore+=25 if (i.ability == PBAbilities::BATTLEARMOR)
              monscore+=25 if (i.ability == PBAbilities::SHELLARMOR)
              monscore+=25 if (i.ability == PBAbilities::MAGICIAN)
              monscore+=25 if (i.ability == PBAbilities::MARVELSCALE)
              monscore+=30 if (i.ability == PBAbilities::STANCECHANGE)
            when 32
              monscore+=25 if i.hasType?(:FIRE)
              monscore+=50 if i.hasType?(:DRAGON)
              monscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
              monscore+=20 if (i.ability == PBAbilities::MULTISCALE)
              monscore+=20 if ((i.ability == PBAbilities::MAGMAARMOR) || (nonmegaform.ability == PBAbilities::MAGMAARMOR))
            when 33
              monscore+=25 if i.hasType?(:GRASS)
              monscore+=25 if i.hasType?(:BUG)
              monscore+=20 if (i.ability == PBAbilities::FLOWERGIFT)
              monscore+=20 if (i.ability == PBAbilities::FLOWERVEIL)
              monscore+=20 if ((i.ability == PBAbilities::DROUGHT) || (nonmegaform.ability == PBAbilities::DROUGHT))
              monscore+=20 if ((i.ability == PBAbilities::DRIZZLE) || (nonmegaform.ability == PBAbilities::DRIZZLE))
            when 34
              monscore+=25 if i.hasType?(:PSYCHIC)
              monscore+=25 if i.hasType?(:FAIRY)
              monscore+=25 if i.hasType?(:DARK)
              monscore+=20 if (i.ability == PBAbilities::MARVELSCALE)
              monscore+=20 if (i.ability == PBAbilities::VICTORYSTAR)
              monscore+=25 if ((i.ability == PBAbilities::ILLUMINATE) || (nonmegaform.ability == PBAbilities::ILLUMINATE))
              monscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
            when 35
              monscore+=25 if i.hasType?(:FLYING)
              monscore+=25 if i.hasType?(:DARK)
              monscore+=20 if (i.ability == PBAbilities::VICTORYSTAR)
              monscore+=25 if (i.ability == PBAbilities::LEVITATE)
              monscore+=30 if (i.ability == PBAbilities::SHADOWSHIELD)
            when 36
            when 37
              monscore+=25 if i.hasType?(:PSYCHIC)
              monscore+=20 if (i.ability == PBAbilities::PUREPOWER)
              monscore+=20 if ((i.ability == PBAbilities::ANTICIPATION) || (nonmegaform.ability == PBAbilities::ANTICIPATION))
              monscore+=50 if (i.ability == PBAbilities::TELEPATHY)
          end
        end
        PBDebug.log(sprintf("Fields: %d",monscore)) if $INTERNAL
        if currentmon.pbOwnSide.effects[PBEffects::StealthRock] ||
          currentmon.pbOwnSide.effects[PBEffects::Spikes]>0
          monscore= (monscore*(i.hp.to_f/i.totalhp.to_f)).floor
        end
        hazpercent = totalHazardDamage(currentmon.pbOwnSide,nonmegaform.type1,nonmegaform.type2,nonmegaform.isAirborne?,skill)
        if hazpercent>(i.hp.to_f/i.totalhp)*100
          monscore=1
        end
        if theseRoles.include?(PBMonRoles::ACE) && skill>=PBTrainerAI.bestSkill
          monscore*= 0.3
        end
        monscore.floor
        PBDebug.log(sprintf("Score: %d",monscore)) if $INTERNAL
        PBDebug.log(sprintf(" ")) if $INTERNAL
        scorearray.push(monscore)
      end
      count=-1
      bestcount=-1
      highscore=-1000000000000
      for score in scorearray
        count+=1
        next if party[count].nil?
        if score>highscore
          highscore=score
          bestcount=count
        elsif score==highscore
          if party[count].hp>party[bestcount].hp
            bestcount=count
          end
        end
      end
      if !pbCanSwitchLax?(currentmon.index,bestcount,false)
        return -1
      else
        return bestcount
      end
    end

    def totalHazardDamage(side,type1,type2,airborne,skill)
      percentdamage = 0
      if side.effects[PBEffects::Spikes]>0 && (!airborne || @field.effects[PBEffects::Gravity]>0)
        spikesdiv=[8,8,6,4][side.effects[PBEffects::Spikes]]
        percentdamage += (100.0/spikesdiv).floor
      end
      if side.effects[PBEffects::StealthRock]
        supereff = -1
        atype=PBTypes::ROCK
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect == 25
            atype1=PBTypes::WATER
            atype2=PBTypes::GRASS
            atype3=PBTypes::FIRE
            atype4=PBTypes::PSYCHIC
            eff1=PBTypes.getCombinedEffectiveness(atype1,type1,type2)
            eff2=PBTypes.getCombinedEffectiveness(atype2,type1,type2)
            eff3=PBTypes.getCombinedEffectiveness(atype3,type1,type2)
            eff4=PBTypes.getCombinedEffectiveness(atype4,type1,type2)
            supereff = [eff1,eff2,eff3,eff4].max
          end
        end
        eff=PBTypes.getCombinedEffectiveness(atype,type1,type2)
        eff = supereff if supereff > -1
        if eff>0
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect == 14 || $fefieldeffect == 23
              eff = eff*2
            end
          end
          percentdamage += 100*(eff/32.0)
        end
      end
      return percentdamage
    end
end
