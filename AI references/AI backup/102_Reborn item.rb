class PokeBattle_Battle
  ################################################################################
  # Decide whether the opponent should use an item on the Pokémon.
  ################################################################################
    def pbEnemyShouldUseItem?(index)
      item=pbEnemyItemToUse(index)
      if item>0 && @battlers[index].effects[PBEffects::Embargo]==0
        pbRegisterItem(index,item,nil)
        return true
      end
      return false
    end

    def pbEnemyItemAlreadyUsed?(index,item,items)
      if @choices[1][0]==3 && @choices[1][1]==item
        qty=0
        for i in items
          qty+=1 if i==item
        end
        return true if qty<=1
      end
      return false
    end

    def pbEnemyItemToUse(index)
      return 0 if !@opponent
      return 0 if !@internalbattle
      items=pbGetOwnerItems(index)
      return 0 if !items
      skill=pbGetOwner(index).skill || 0
      battler=@battlers[index]
      party = pbParty(index)
      opponent1 = battler.pbOppositeOpposing
      opponent2 = opponent1.pbPartner
      currentroles = pbGetMonRole(battler,opponent1,skill)
      return 0 if battler.isFainted?
      highscore = 0
      movecount = -1
      maxplaypri = -1
      partynumber = 0
      aimem = getAIMemory(skill,opponent1.pokemonIndex)
      for i in party
        next if i.nil?
        next if i.hp == 0
        partynumber+=1
      end
      itemnumber = 0
      for i in items
        next if pbEnemyItemAlreadyUsed?(index,i,items)
        itemnumber+=1
      end
      #highest score
      for i in battler.moves
        scorearray = 0
        scorearray = @scores[i] if @scores[i]
        if scorearray>100 && i.priority>maxplaypri
          maxplaypri = i.priority
        end
      end
      highscore = @scores.max
      highdamage = -1
      maxopppri = -1
      pridam = -1
      bestid = -1
      #expected damage
      #if battler.pbSpeed<pbRoughStat(opponent1,PBStats::SPEED,skill)
      if aimem.length > 0
        for i in aimem
          tempdam = pbRoughDamage(i,opponent1,battler,skill,i.basedamage)
          if tempdam>highdamage
            highdamage = tempdam
            bestid = i.id
          end
          if i.priority > maxopppri
            maxopppri = i.priority
            pridam = tempdam
          end
        end
      end
      highratio = -1
      #expected damage percentage
      if battler.hp!=0
        highratio = highdamage*(1.0/battler.hp)
      end
      scorearray = []
      arraycount = -1
      PBDebug.log(sprintf("Beginning AI Item use check.")) if $INTERNAL
      PBDebug.log(sprintf(" ")) if $INTERNAL
      for i in items
        arraycount+=1
        scorearray.push(0)
        itemscore=100
        ishpitem = false
        isstatusitem = false
        next if pbEnemyItemAlreadyUsed?(index,i,items)
        if (i== PBItems::POTION) ||
           (i== PBItems::ULTRAPOTION) ||
           (i== PBItems::SUPERPOTION) ||
           (i== PBItems::HYPERPOTION) ||
           (i== PBItems::MAXPOTION) ||
           (i== PBItems::FULLRESTORE) ||
           (i== PBItems::FRESHWATER) ||
           (i== PBItems::SODAPOP) ||
           (i== PBItems::LEMONADE) ||
           (i== PBItems::MOOMOOMILK) ||
           (i== PBItems::MEMEONADE) ||
           (i== PBItems::STRAWBIC) ||
           (i== PBItems::CHOCOLATEIC) ||
           (i== PBItems::BLUEMIC)
          ishpitem=true
        end
        if (i== PBItems::FULLRESTORE) ||
           (i== PBItems::FULLHEAL) ||
           (i== PBItems::RAGECANDYBAR) ||
           (i== PBItems::LAVACOOKIE) ||
           (i== PBItems::OLDGATEAU) ||
           (i== PBItems::CASTELIACONE) ||
           (i== PBItems::LUMIOSEGALETTE) ||
           (i== PBItems::BIGMALASADA)
          isstatusitem=true
        end
        if ishpitem
          PBDebug.log(sprintf("This is a HP-healing item.")) if $INTERNAL
          restoreamount=0
          if (i== PBItems::POTION)
            restoreamount=20
          elsif (i== PBItems::ULTRAPOTION)
            restoreamount=200
          elsif (i== PBItems::SUPERPOTION)
            restoreamount=60
          elsif (i== PBItems::HYPERPOTION)
            restoreamount=120
          elsif (i== PBItems::MAXPOTION) || (i== PBItems::FULLRESTORE)
            restoreamount=battler.totalhp
          elsif (i== PBItems::FRESHWATER)
            restoreamount=30
          elsif (i== PBItems::SODAPOP)
            restoreamount=50
          elsif (i== PBItems::LEMONADE)
            restoreamount=70
          elsif (i== PBItems::MOOMOOMILK)
            restoreamount=110
          elsif (i== PBItems::MEMEONADE)
            restoreamount=103
          elsif (i== PBItems::STRAWBIC)
            restoreamount=90
          elsif (i== PBItems::CHOCOLATEIC)
            restoreamount=70
          elsif (i== PBItems::BLUEMIC)
            restoreamount=200
          end
          resratio=restoreamount*(1.0/battler.totalhp)
          itemscore*= (2 - (2*(battler.hp*(1.0/battler.totalhp))))
          if highdamage>=battler.hp
            if highdamage > [battler.hp+restoreamount,battler.totalhp].min
              itemscore*=0
            else
              itemscore*=1.2
            end
            healmove = false
            for j in battler.moves
              if j.isHealingMove?
                healmove=true
              end
            end
            if healmove
              if battler.pbSpeed < opponent1.pbSpeed
                if highdamage>=battler.hp
                  itemscore*=1.1
                else
                  itemscore*=0.6
                  if resratio<0.55
                    itemscore*=0.2
                  end
                end
              end
            end
          else
            itemscore*=0.4
          end
          if highdamage > restoreamount
            itemscore*=0
          else
            if restoreamount-highdamage < 15
              itemscore*=0.5
            end
          end
          if battler.pbSpeed > opponent1.pbSpeed
            itemscore*=0.8
            if highscore >=110
              if maxopppri > maxplaypri
                itemscore*=1.3
                if pridam>battler.hp
                  if pridam>(battler.hp/2.0)
                    itemscore*=0
                  else
                    itemscore*=2
                  end
                end
              elsif !(!opponent1.abilitynulled && opponent1.ability == PBAbilities::STURDY)
                itemscore*=0
              end
            end
            if currentroles.include?(PBMonRoles::SWEEPER)
              itemscore*=1.1
            end
          else
            if highdamage*2 > [battler.hp+restoreamount,battler.totalhp].min
              itemscore*=0
            else
              itemscore*=1.5
              if highscore >=110
                itemscore*=1.5
              end
            end
          end
          if battler.hp == battler.totalhp
            itemscore*=0
          elsif battler.hp >= (battler.totalhp*0.8)
            itemscore*=0.2
          elsif battler.hp >= (battler.totalhp*0.6)
            itemscore*=0.3
          elsif battler.hp >= (battler.totalhp*0.5)
            itemscore*=0.5
          end
          minipot = (partynumber-1)
          minimini = -1
          for j in items
            next if pbEnemyItemAlreadyUsed?(index,j,items)
            next if !((j== PBItems::POTION) || (j== PBItems::ULTRAPOTION) ||
            (j== PBItems::SUPERPOTION) || (j== PBItems::HYPERPOTION) ||
            (j== PBItems::MAXPOTION) || (j== PBItems::FULLRESTORE) ||
            (j== PBItems::FRESHWATER) || (j== PBItems::SODAPOP) ||
            (j== PBItems::LEMONADE) || (j== PBItems::MOOMOOMILK) ||
            (j== PBItems::MEMEONADE) || (j== PBItems::STRAWBIC) ||
            (j== PBItems::CHOCOLATEIC) || (j== PBItems::BLUEMIC))
            minimini+=1
          end
          if minipot>minimini
            itemscore*=(0.9**(minipot-minimini))
            minipot=minimini
          elsif minimini>minipot
            itemscore*=(1.1**(minimini-minipot))
            minimini=minipot
          end
          if currentroles.include?(PBMonRoles::LEAD) || currentroles.include?(PBMonRoles::SCREENER)
            itemscore*=0.6
          end
          if currentroles.include?(PBMonRoles::TANK)
            itemscore*=1.1
          end
          if currentroles.include?(PBMonRoles::SECOND)
            itemscore*=1.1
          end
          if battler.hasWorkingItem(:LEFTOVERS) || (battler.hasWorkingItem(:BLACKSLUDGE) && battler.pbHasType?(:POISON))
            itemscore*=0.9
          end
          if battler.status!=0 && !(i== PBItems::FULLRESTORE)
            itemscore*=0.7
            if battler.effects[PBEffects::Toxic]>0 && partynumber>1
              itemscore*=0.2
            end
          end
          if PBTypes.getCombinedEffectiveness(opponent1.type1,battler.type1,battler.type2)>4
            itemscore*=0.7
          elsif PBTypes.getCombinedEffectiveness(opponent1.type1,battler.type1,battler.type2)<4
            itemscore*=1.1
            if PBTypes.getCombinedEffectiveness(opponent1.type1,battler.type1,battler.type2)==0
              itemscore*=1.2
            end
          end
          if PBTypes.getCombinedEffectiveness(opponent1.type2,battler.type1,battler.type2)>4
            itemscore*=0.6
          elsif PBTypes.getCombinedEffectiveness(opponent1.type1,battler.type1,battler.type2)<4
            itemscore*=1.1
            if PBTypes.getCombinedEffectiveness(opponent1.type1,battler.type1,battler.type2)==0
              itemscore*=1.2
            end
          end
          if (!battler.abilitynulled && battler.ability == PBAbilities::REGENERATOR) && partynumber>1
            itemscore*=0.7
          end
        end
        if isstatusitem
          PBDebug.log(sprintf("This is a status-curing item.")) if $INTERNAL
          if !(i== PBItems::FULLRESTORE)
            if battler.status==0
              itemscore*=0
            else
              if highdamage>battler.hp
                if (bestid==106 && battler.status==PBStatuses::SLEEP) || (bestid==298 && battler.status==PBStatuses::PARALYSIS) || bestid==179
                  if highdamage*0.5>battler.hp
                    itemscore*=0
                  else
                    itemscore*=1.4
                  end
                else
                  itemscore*=0
                end
              end
            end
            if battler.status==PBStatuses::SLEEP
              if battler.pbHasMove?((PBMoves::SLEEPTALK)) ||
                battler.pbHasMove?((PBMoves::SNORE)) ||
                battler.pbHasMove?((PBMoves::REST)) ||
                (!battler.abilitynulled && battler.ability == PBAbilities::COMATOSE)
                itemscore*=0.6
              end
              if checkAImoves([PBMoves::DREAMEATER,PBMoves::NIGHTMARE],aimem) || (!opponent1.abilitynulled && opponent1.ability == PBAbilities::BADDREAMS)
                itemscore*=1.3
              end
              if highdamage*(1.0/battler.hp)>0.2
                itemscore*=1.3
              else
                itemscore*=0.7
              end
            end
            if battler.status==PBStatuses::PARALYSIS
              if (!battler.abilitynulled && battler.ability == PBAbilities::QUICKFEET) || (!battler.abilitynulled && battler.ability == PBAbilities::GUTS)
                itemscore*=0.5
              end
              if battler.pbSpeed>opponent1.pbSpeed && (battler.pbSpeed*0.5)<opponent1.pbSpeed
                itemscore*=1.3
              end
              itemscore*=1.1
            end
            if battler.status==PBStatuses::BURN
              itemscore*=1.1
              if battler.attack>battler.spatk
                itemscore*=1.2
              else
                itemscore*=0.8
              end
              if !battler.abilitynulled
                itemscore*=0.6 if battler.ability == PBAbilities::GUTS
                itemscore*=0.7 if battler.ability == PBAbilities::MAGICGUARD
                itemscore*=0.8 if battler.ability == PBAbilities::FLAREBOOST
              end
            end
            if battler.status==PBStatuses::POISON
              itemscore*=1.1
              if !battler.abilitynulled
                itemscore*=0.5 if battler.ability == PBAbilities::GUTS
                itemscore*=0.5 if battler.ability == PBAbilities::MAGICGUARD
                itemscore*=0.5 if battler.ability == PBAbilities::TOXICBOOST
                itemscore*=0.4 if battler.ability == PBAbilities::POISONHEAL
              end
              if battler.effects[PBEffects::Toxic]>0
                itemscore*=1.1
                if battler.effects[PBEffects::Toxic]>3
                  itemscore*=1.3
                end
              end
            end
            if battler.status==PBStatuses::FROZEN
              itemscore*=1.3
              thawmove=false
              for j in battler.moves
                if j.canThawUser?
                  thawmove=true
                end
              end
              if thawmove
                itemscore*=0.5
              end
              if highdamage*(1.0/battler.hp)>0.15
                itemscore*=1.1
              else
                itemscore*=0.9
              end
            end
          end
          if battler.pbHasMove?((PBMoves::REFRESH)) ||
            battler.pbHasMove?((PBMoves::REST)) ||
            battler.pbHasMove?((PBMoves::PURIFY))
            itemscore*=0.5
          end
          if (!battler.abilitynulled && battler.ability == PBAbilities::NATURALCURE) && partynumber>1
            itemscore*=0.2
          end
          if (!battler.abilitynulled && battler.ability == PBAbilities::SHEDSKIN)
            itemscore*=0.3
          end
        end
        if partynumber==1 || currentroles.include?(PBMonRoles::ACE)
          itemscore*=1.2
        else
          itemscore*=0.8
          if battler.itemUsed2
            itemscore*=0.6
          end
        end
        if battler.effects[PBEffects::Confusion]>0
          itemscore*=0.9
        end
        if battler.effects[PBEffects::Attract]>=0
          itemscore*=0.6
        end
        if battler.effects[PBEffects::Substitute]>0
          itemscore*=1.1
        end
        if battler.effects[PBEffects::LeechSeed]>=0
          itemscore*=0.5
        end
        if battler.effects[PBEffects::Curse]
          itemscore*=0.5
        end
        if battler.effects[PBEffects::PerishSong]>0
          itemscore*=0.2
        end
        minipot=0
        for s in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          minipot+=battler.stages[s]
        end
        if currentroles.include?(PBMonRoles::PHYSICALWALL) || currentroles.include?(PBMonRoles::SPECIALWALL)
          for s in [PBStats::DEFENSE,PBStats::SPDEF]
            minipot+=battler.stages[s]
          end
        end
        if currentroles.include?(PBMonRoles::SWEEPER)
          for s in [PBStats::SPEED]
            minipot+=battler.stages[s]
          end
          if battler.attack>battler.spatk
            for s in [PBStats::ATTACK]
              minipot+=battler.stages[s]
            end
          else
            for s in [PBStats::SPATK]
              minipot+=battler.stages[s]
            end
          end
        end
        minipot*=5
        minipot+=100
        minipot*=0.01
        itemscore*=minipot
        if opponent1.effects[PBEffects::TwoTurnAttack]>0 || opponent1.effects[PBEffects::HyperBeam]>0
          itemscore*=1.2
        end
        if highscore>70
          itemscore*=1.1
        else
          itemscore*=0.9
        end
        fielddisrupt = getFieldDisruptScore(battler,opponent1,skill)
        if fielddisrupt <= 0
          fielddisrupt=0.6
        end
        itemscore*= (1.0/fielddisrupt)
        if @trickroom > 0
          itemscore*=0.9
        end
        if battler.pbOwnSide.effects[PBEffects::Tailwind]>0
          itemscore*=0.6
        end
        if battler.pbOwnSide.effects[PBEffects::Reflect]>0
          itemscore*=0.9
        end
        if battler.pbOwnSide.effects[PBEffects::LightScreen]>0
          itemscore*=0.9
        end
        if battler.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          itemscore*=0.8
        end
        if @doublebattle
          itemscore*=0.8
        end
        itemscore-=100
        PBDebug.log(sprintf("Score for %s: %d",PBItems.getName(i),itemscore)) if $INTERNAL
        scorearray[arraycount] = itemscore
      end
      bestitem=-1
      bestscore=-10000
      counter=-1
      for k in scorearray
        counter+=1
        if k>bestscore
          bestscore = k
          bestitem = items[counter]
        end
      end
      PBDebug.log(sprintf("Highest item score: %d",bestscore)) if $INTERNAL
      PBDebug.log(sprintf("Highest move score: %d",highscore)) if $INTERNAL
      if highscore<bestscore
        PBDebug.log(sprintf("Using %s",PBItems.getName(bestitem))) if $INTERNAL
        return bestitem
      else
        PBDebug.log(sprintf("Not using an item.")) if $INTERNAL
        PBDebug.log(sprintf(" ")) if $INTERNAL
        return 0
      end
    end
end
