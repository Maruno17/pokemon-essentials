class PokeBattle_Battle
  alias __d__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    score = __d__pbGetMoveScoreFunctionCode(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                            score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      when 0xC0 # Bullet Seed
        if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::IRONBARBS) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::ROUGHSKIN)
          score*=0.7
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SKILLLINK)
            score*=0.5
          end
        end
        if opponent.hp==opponent.totalhp &&
           ((oppitemworks && opponent.item == PBItems::FOCUSSASH) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY))
          score*=1.3
        end
        if opponent.effects[PBEffects::Substitute]>0
          score*=1.3
        end
        if (attitemworks && attacker.item == PBItems::RAZORFANG) ||
           (attitemworks && attacker.item == PBItems::KINGSROCK)
          score*=1.3
        end
      when 0xC1 # Beat Up
        count = -1
        for mon in pbParty(attacker.index)
          next if mon.nil?
          count+=1 if mon.hp>0
        end
        if count>0
          if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::IRONBARBS) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::ROUGHSKIN)
            score*=0.7
          end
          if opponent.hp==opponent.totalhp &&
             ((oppitemworks && opponent.item == PBItems::FOCUSSASH) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY))
            score*=1.3
          end
          if opponent.effects[PBEffects::Substitute]>0
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::RAZORFANG) ||
             (attitemworks && attacker.item == PBItems::KINGSROCK)
            score*=1.3
          end
          if opponent == attacker.pbPartner &&
             (!opponent.abilitynulled && opponent.ability == PBAbilities::JUSTIFIED)
            if opponent.stages[PBStats::ATTACK]<1 && opponent.attack>opponent.spatk
              score= 100-thisinitial
              enemy1 = attacker.pbOppositeOpposing
              enemy2 = enemy1.pbPartner
              if opponent.pbSpeed > enemy1.pbSpeed && opponent.pbSpeed > enemy2.pbSpeed
                score*=1.3
              else
                score*=0.7
              end
            end
          end
          if opponent == attacker.pbPartner &&
             !(!opponent.abilitynulled && opponent.ability == PBAbilities::JUSTIFIED)
            score=0
          end
        end
      when 0xC2 # Hyper Beam
        if $fefieldeffect == 24
          if score >=110
            score*=1.3
          end
        else
          thisinitial = score
          if thisinitial<100
            score*=0.5
            score*=0.5 if checkAIhealing(aimem)
          end
          if initialscores.length>0
            score*=0.3 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount>1
            miniscore*=(livecount-1)
            miniscore/=100.0
            miniscore*=0.1
            miniscore=(1-miniscore)
            score*=miniscore
          else
            score*=1.1
          end
          if @doublebattle
            score*=0.5
          end
          livecount2=0
          for i in pbParty(attacker.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if livecount>1 && livecount2==1
            score*=0.7
          end
          if !@doublebattle
            if @opponent.trainertype==PBTrainers::ZEL
              score=thisinitial
              score *= 2
            end
          end
        end
      when 0xC3 # Razor Wind
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        fairyvar = false
        firevar = false
        poisonvar = false
        for p in pbParty(attacker.index)
          next if p.nil?
          fairyvar = true if p.hasType?(:FAIRY)
          firevar = true if p.hasType?(:FIRE)
          poisonvar = true if p.hasType?(:POISON)
        end
        if $fefieldeffect==3
          score*=1.3
          if !fairyvar
            score*=1.3
          else
            score*=0.6
          end
        elsif $fefieldeffect==7
          if !firevar
            score*=1.8
          else
            score*=0.5
          end
        elsif $fefieldeffect==11
          if !poisonvar
            score*=3
          else
            score*=0.8
          end
        end
      when 0xC4 # Solar Beam
        if !(attitemworks && attacker.item == PBItems::POWERHERB) && pbWeather!=PBWeather::SUNNYDAY
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN) &&
             pbWeather!=PBWeather::SUNNYDAY
            score*=1.5
          end
        end
        if $fefieldeffect==4
          score*=0
        end
      when 0xC5 # Freeze Shock
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        if opponent.pbCanParalyze?(false)
          miniscore=100
          miniscore*=1.1
          miniscore*=1.3 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          ministat+=opponent.stages[PBStats::SPATK]
          ministat+=opponent.stages[PBStats::SPEED]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) ||
             roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.5
          end
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2.0)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.5
          end
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.3
          end
          count = -1
          sweepvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          miniscore*=1.3 if sweepvar
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            miniscore*=0.7
          end
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
      when 0xC6 # Ice Burn
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        if opponent.pbCanBurn?(false)
          miniscore=100
          miniscore*=1.2
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          ministat+=opponent.stages[PBStats::SPATK]
          ministat+=opponent.stages[PBStats::SPEED]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            miniscore*=0.7
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::FLAREBOOST) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICGUARD)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.1
          end
          miniscore*=0.3 if checkAImoves([PBMoves::FACADE],aimem)
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.7
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            miniscore*=0.7
          end
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
      when 0xC7 # Sky Attack
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        if opponent.effects[PBEffects::Substitute]==0 &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed)   ^ (@trickroom!=0)
            miniscore=100
            miniscore*=1.3
            if skill>=PBTrainerAI.bestSkill
              if $fefieldeffect==14 # Rocky
                miniscore*=1.2
              end
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STEADFAST)
              miniscore*=0.3
            end
            miniscore-=100
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
        end
      when 0xC8 # Skull Bash
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.4
          else
            if attacker.hp*(1.0/attacker.totalhp)<0.5
              score*=0.6
            end
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0.5
            end
          end
          greatmove = false
          thisko = false
          if initialscores.length>0
            if initialscores[scoreindex] >= 100
              thisko = true
            end
            for i in initialscores
              if i>=100
                greatmove=true
              end
            end
          end
          if greatmove
            score*=0.1
          end
          if @doublebattle
            score*=0.5
          end
          score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if !thisko
            score*=0.7
          end
        else
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        miniscore=100
        if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
          miniscore*=1.3
        end
        if (attacker.hp.to_f)/attacker.totalhp>0.75
          miniscore*=1.1
        end
        if opponent.effects[PBEffects::HyperBeam]>0
          miniscore*=1.2
        end
        if opponent.effects[PBEffects::Yawn]>0
          miniscore*=1.3
        end
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam<(attacker.hp/3.0) && (aimem.length > 0)
            miniscore*=1.1
          end
        end
        if attacker.turncount<2
          miniscore*=1.1
        end
        if opponent.status!=0
          miniscore*=1.1
        end
        if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
          miniscore*=1.3
        end
        if opponent.effects[PBEffects::Encore]>0
          if opponent.moves[(opponent.effects[PBEffects::EncoreIndex])].basedamage==0
            miniscore*=1.3
          end
        end
        if attacker.effects[PBEffects::Confusion]>0
          miniscore*=0.3
        end
        if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
          miniscore*=0.3
        end
        if attacker.effects[PBEffects::Toxic]>0
          miniscore*=0.2
        end
        miniscore*=0.2 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
          miniscore*=2
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=0.5
        end
        if @doublebattle
          miniscore*=0.3
        end
        if attacker.stages[PBStats::DEFENSE]>0
          ministat=attacker.stages[PBStats::DEFENSE]
          minimini=-15*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
          miniscore*=1.3
        end
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if (maxdam.to_f/attacker.hp)<0.12 && (aimem.length > 0)
            miniscore*=0.3
          end
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
          ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          miniscore*=1.2
        end
        healmove=false
        for j in attacker.moves
          if j.isHealingMove?
            healmove=true
          end
        end
        if healmove
          miniscore*=1.3
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        miniscore-=100
        if move.addlEffect.to_f != 100
          miniscore*=(move.addlEffect.to_f/100)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
            miniscore*=2
          end
        end
        miniscore+=100
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::DEFENSE)
          miniscore=1
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0.5
        end
        score*=miniscore
      when 0xC9 # Fly
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if skill<PBTrainerAI.bestSkill || $fefieldeffect!=23 # Not in a cave
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
             opponent.effects[PBEffects::LeechSeed]>=0 ||
             opponent.effects[PBEffects::MultiTurn]>0 ||
             opponent.effects[PBEffects::Curse]
            score*=1.2
          else
            if livecount1>1
              score*=0.8
            end
          end
          if attacker.status!=0 || attacker.effects[PBEffects::Curse] ||
             attacker.effects[PBEffects::Attract]>-1 ||
             attacker.effects[PBEffects::Confusion]>0
            score*=0.5
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
            score*=1.1
          end
          if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
             attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
             attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
          end
          if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::POWERHERB)
            score*=1.5
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
            score*=0.1
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if opponent.vanished
              score*=3
            end
            score*=1.1
          else
            score*=0.8
            score*=0.5 if checkAIhealing(aimem)
            score*=0.7 if checkAIaccuracy(aimem)
          end
          score*=0.3 if checkAImoves([PBMoves::THUNDER,PBMoves::HURRICANE],aimem)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==22
              if !attacker.pbHasType?(PBTypes::WATER)
                score*=2
              end
            end
          end
        end
        if @field.effects[PBEffects::Gravity]>0
          score*=0
        end
      when 0xCA # Dig
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 ||
           opponent.effects[PBEffects::MultiTurn]>0 ||
           opponent.effects[PBEffects::Curse]
          score*=1.2
        else
          if livecount1>1
            score*=0.8
          end
        end
        if attacker.status!=0 || attacker.effects[PBEffects::Curse] ||
           attacker.effects[PBEffects::Attract]>-1 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=0.5
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          score*=1.1
        end
        if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
           attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
           attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
          score*=0.7
        end
        if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
          score*=1.3
        end
        if (attitemworks && attacker.item == PBItems::POWERHERB)
          score*=1.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
          score*=0.1
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if opponent.vanished
            score*=3
          end
          score*=1.1
        else
          score*=0.8
          score*=0.5 if checkAIhealing(aimem)
          score*=0.7 if checkAIaccuracy(aimem)
        end
        score*=0.3 if checkAImoves([PBMoves::EARTHQUAKE],aimem)
      when 0xCB # Dive
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if skill>=PBTrainerAI.bestSkill && ($fefieldeffect==21 || $fefieldeffect==22)  # Water Surface/Underwater
          if $fefieldeffect==21 # Water Surface
            if !opponent.pbHasType?(PBTypes::WATER)
              score*=2
            else
              for mon in pbParty(attacker.index)
                watervar=false
                next if mon.nil?
                if mon.hasType?(:WATER)
                  watervar=true
                end
                if watervar
                  score*=1.3
                end
              end
            end
          else
            if !attacker.pbHasType?(PBTypes::WATER)
              score*=2
            else
              for mon in pbParty(attacker.index)
                watervar=false
                next if mon.nil?
                if mon.hasType?(:WATER)
                  watervar=true
                end
                if watervar
                  score*=0.6
                end
              end
            end
          end
        else
          if $fefieldeffect==26 # Murkwater Surface
            if !attacker.pbHasType?(PBTypes::POISON) && !attacker.pbHasType?(PBTypes::STEEL)
              score*=0.3
            end
          end
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
             opponent.effects[PBEffects::LeechSeed]>=0 ||
             opponent.effects[PBEffects::MultiTurn]>0 ||
             opponent.effects[PBEffects::Curse]
            score*=1.2
          else
            if livecount1>1
              score*=0.8
            end
          end
          if attacker.status!=0 ||
             attacker.effects[PBEffects::Curse] ||
             attacker.effects[PBEffects::Attract]>-1 ||
             attacker.effects[PBEffects::Confusion]>0
            score*=0.5
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
            score*=1.1
          end
          if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
             attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
             attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
          end
          if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::POWERHERB)
            score*=1.5
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
            score*=0.1
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if opponent.vanished
              score*=3
            end
            score*=1.1
          else
            score*=0.8
            score*=0.5 if checkAIhealing(aimem)
            score*=0.7 if checkAIaccuracy(aimem)
          end
          score*=0.3 if checkAImoves([PBMoves::SURF],aimem)
        end
      when 0xCC # Bounce
        if opponent.pbCanParalyze?(false)
          miniscore=100
          miniscore*=1.1 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          ministat+=opponent.stages[PBStats::SPATK]
          ministat+=opponent.stages[PBStats::SPEED]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) ||
             roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.3
          end
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.5
          end
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.1
          end
          count = -1
          sweepvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          miniscore*=1.1 if sweepvar
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            miniscore*=0.7
          end
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if skill<PBTrainerAI.bestSkill || $fefieldeffect!=23 # Not in a cave
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
             opponent.effects[PBEffects::LeechSeed]>=0 ||
             opponent.effects[PBEffects::MultiTurn]>0 ||
             opponent.effects[PBEffects::Curse]
            score*=1.2
          else
            if livecount1>1
              score*=0.7
            end
          end
          if attacker.status!=0 || attacker.effects[PBEffects::Curse] ||
             attacker.effects[PBEffects::Attract]>-1 ||
             attacker.effects[PBEffects::Confusion]>0
            score*=0.5
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
            score*=1.1
          end
          if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
             attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
             attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
            score*=0.7
          end
          if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::POWERHERB)
            score*=1.5
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
            score*=0.1
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if opponent.vanished
              score*=3
            end
            score*=1.1
          else
            score*=0.8
            score*=0.5 if checkAIhealing(aimem)
            score*=0.7 if checkAIaccuracy(aimem)
          end
          score*=0.3 if checkAImoves([PBMoves::THUNDER,PBMoves::HURRICANE],aimem)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==22
              if !attacker.pbHasType?(PBTypes::WATER)
                score*=2
              end
            end
          end
        end
        if @field.effects[PBEffects::Gravity]>0
          score*=0
        end
      when 0xCD # Phantom Force
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 ||
           opponent.effects[PBEffects::MultiTurn]>0 ||
           opponent.effects[PBEffects::Curse]
          score*=1.2
        else
          if livecount1>1
            score*=0.8
          end
        end
        if attacker.status!=0 || attacker.effects[PBEffects::Curse] ||
           attacker.effects[PBEffects::Attract]>-1 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=0.5
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          score*=1.1
        end
        if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
           attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
           attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
          score*=0.7
        end
        if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
          score*=1.3
        end
        if (attitemworks && attacker.item == PBItems::POWERHERB)
          score*=1.5
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.1
        else
          score*=0.8
          score*=0.5 if checkAIhealing(aimem)
          score*=0.7 if checkAIaccuracy(aimem)
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
          score*=0.1
        else
          miniscore=100
          if attacker.stages[PBStats::ACCURACY]<0
            miniscore = (-5)*attacker.stages[PBStats::ACCURACY]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if opponent.stages[PBStats::EVASION]>0
            miniscore = (5)*opponent.stages[PBStats::EVASION]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
             (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER)
            score*=1.2
          end
          if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
             ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
            score*=1.3
          end
          if opponent.vanished && ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))
            score*=3
          end
        end
      when 0xCE # Sky Drop
        if opponent.pbHasType?(:FLYING)
          score = 5
        end
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 ||
           opponent.effects[PBEffects::MultiTurn]>0 ||
           opponent.effects[PBEffects::Curse]
          score*=1.5
        else
          if livecount1>1
            score*=0.8
          end
        end
        if attacker.status!=0 || attacker.effects[PBEffects::Curse] ||
           attacker.effects[PBEffects::Attract]>-1 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=0.5
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          score*=1.1
        end
        if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0 ||
           attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
           attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
          score*=0.7
        end
        if opponent.effects[PBEffects::PerishSong]!=0 && attacker.effects[PBEffects::PerishSong]==0
          score*=1.3
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill))  ^ (@trickroom!=0)
          score*=1.1
        else
          score*=0.8
        end
        if $fefieldeffect==22
          if !attacker.pbHasType?(:WATER)
            score*=2
          end
        end
        if @field.effects[PBEffects::Gravity]>0 || $fefieldeffect==23 || opponent.effects[PBEffects::Substitute]>0
          score*=0
        end
      when 0xCF # Fire Spin
        if opponent.effects[PBEffects::MultiTurn]==0 && opponent.effects[PBEffects::Substitute]<=0
          score*=1.2
          if initialscores.length>0
            score*=1.2 if hasbadmoves(initialscores,scoreindex,30)
          end
          ministat=(-5)*statchangecounter(opponent,1,7,1)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.totalhp == opponent.hp
            score*=1.2
          elsif opponent.hp*2 < opponent.totalhp
            score*=0.8
          end
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.7
          elsif attacker.hp*3<attacker.totalhp
            score*=0.7
          end
          if opponent.effects[PBEffects::LeechSeed]>=0
            score*=1.5
          end
          if opponent.effects[PBEffects::Attract]>-1
            score*=1.3
          end
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.3
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=1.2
          end
          movecheck = false
          for j in attacker.moves
            movecheck = true if j.id==(PBMoves::PROTECT) || j.id==(PBMoves::DETECT) ||
                                j.id==(PBMoves::BANEFULBUNKER) || j.id==(PBMoves::SPIKYSHIELD)
          end
          if movecheck
            score*=1.1
          end
          if (attitemworks && attacker.item == PBItems::BINDINGBAND)
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::GRIPCLAW)
            score*=1.1
          end
        end
        if move.id==(PBMoves::FIRESPIN)
          if $fefieldeffect==20
            score*=0.7
          end
        end
        if move.id==(PBMoves::MAGMASTORM)
          if $fefieldeffect==32
            score*=1.3
          end
        end
        if move.id==(PBMoves::SANDTOMB)
          if $fefieldeffect==12
            score*=1.3
          elsif $fefieldeffect==20
            score*=1.5 unless opponent.stages[PBStats::ACCURACY]<(-2)
          end
        end
        if move.id==(PBMoves::INFESTATION)
          if $fefieldeffect==15
            score*=1.3
          elsif $fefieldeffect==33
            score*=1.3
            if $fecounter == 3
              score*=1.3
            end
            if $fecounter == 4
              score*=1.5
            end
          end
        end
      when 0xD0 # Whirlpool
        if opponent.effects[PBEffects::MultiTurn]==0 && opponent.effects[PBEffects::Substitute]<=0
          score*=1.2
          if initialscores.length>0
            score*=1.2 if hasbadmoves(initialscores,scoreindex,30)
          end
          ministat=(-5)*statchangecounter(opponent,1,7,1)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.totalhp == opponent.hp
            score*=1.2
          elsif opponent.hp*2 < opponent.totalhp
            score*=0.8
          end
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=0.7
          elsif attacker.hp*3<attacker.totalhp
            score*=0.7
          end
          if opponent.effects[PBEffects::LeechSeed]>=0
            score*=1.5
          end
          if opponent.effects[PBEffects::Attract]>-1
            score*=1.3
          end
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.3
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=1.2
          end
          movecheck = false
          for j in attacker.moves
            movecheck = true if j.id==(PBMoves::PROTECT) || j.id==(PBMoves::DETECT) ||
                                j.id==(PBMoves::BANEFULBUNKER) || j.id==(PBMoves::SPIKYSHIELD)
          end
          if movecheck
            score*=1.1
          end
          if (attitemworks && attacker.item == PBItems::BINDINGBAND)
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::GRIPCLAW)
            score*=1.1
          end
          if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCB
            score*=1.3
          end
        end
        watervar = false
        poisonvar = false
        for p in pbParty(attacker.index)
          next if p.nil?
          watervar = true if p.hasType?(:WATER)
          poisonvar = true if p.hasType?(:POISON)
        end
        if $fefieldeffect==20
          score*=0.7
        end
        if $fefieldeffect==21 || $fefieldeffect==22
          score*=1.3
          if opponent.effects[PBEffects::Confusion]<=0
            score*=1.5
          end
        end
        if $fefieldeffect==26
          if score==0
            score+=10
          end
          if !(attacker.pbHasType?(:POISON) || attacker.pbHasType?(:STEEL))
            score*=1.5
          end
          if !poisonvar
            score*=2
          end
          if watervar
            score*=2
          end
        end
      when 0xD1 # Uproar
        if opponent.status==PBStatuses::SLEEP
          score*=0.7
        end
        if opponent.pbHasMove?(:REST)
          score*=1.8
        end
        if opponent.pbNonActivePokemonCount==0 ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
           opponent.effects[PBEffects::MeanLook]>0
          score*=1.1
        end
        typemod=move.pbTypeModifier(move.type,attacker,opponent)
        if typemod<4
          score*=0.7
        end
        if attacker.hp*(1.0/attacker.totalhp)<0.75
          score*=0.75
        end
        if attacker.stages[PBStats::SPATK]<0
          minimini = attacker.stages[PBStats::SPATK]
          minimini*=5
          minimini+=100
          minimini/=100.0
          score*=minimini
        end
        if opponent.pbNonActivePokemonCount>1
          miniscore = opponent.pbNonActivePokemonCount*0.05
          miniscore = 1-miniscore
          score*=miniscore
        end
      when 0xD2 # Outrage
        livecount1=0
        thisinitial = score
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        #this isn't used?
        #livecount2=0
        #for i in pbParty(attacker.index)
        #  next if i.nil?
        #  livecount2+=1 if i.hp!=0
        #end
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::OWNTEMPO)
          if thisinitial<100
            score*=0.85
          end
          if (attitemworks && attacker.item == PBItems::LUMBERRY) ||
             (attitemworks && attacker.item == PBItems::PERSIMBERRY)
            score*=1.3
          end
          if attacker.stages[PBStats::ATTACK]>0
            miniscore = (-5)*attacker.stages[PBStats::ATTACK]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if livecount1>2
            miniscore=100
            miniscore*=(livecount1-1)
            miniscore*=0.01
            miniscore*=0.025
            miniscore=1-miniscore
            score*=miniscore
          end
          score*=0.7 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          score*=0.7 if checkAIhealing(aimem)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==16 # Superheated Field
              score*=0.5
            end
          end
        else
            score *= 1.2
        end
        if move.id==(PBMoves::PETALDANCE)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==33 && $fecounter>1
              score*=1.5
            end
          end
        elsif move.id==(PBMoves::OUTRAGE)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect!=36
              fairyvar = false
              for mon in pbParty(opponent.index)
                next if mon.nil?
                ghostvar=true if mon.hasType?(:FAIRY)
              end
              if fairyvar
                score*=0.8
              end
            end
          end
        elsif move.id==(PBMoves::THRASH)
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect!=36
              ghostvar = false
              for mon in pbParty(opponent.index)
                next if mon.nil?
                ghostvar=true if mon.hasType?(:GHOST)
              end
              if ghostvar
                score*=0.8
              end
            end
          end
        end
      when 0xD3 # Rollout
        if opponent.pbNonActivePokemonCount==0 ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
           opponent.effects[PBEffects::MeanLook]>0
          score*=1.1
        end
        if attacker.hp*(1.0/attacker.totalhp)<0.75
          score*=0.75
        end
        if attacker.stages[PBStats::ACCURACY]<0
            miniscore = (5)*attacker.stages[PBStats::ATTACK]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if attacker.stages[PBStats::ATTACK]<0
            miniscore = (5)*attacker.stages[PBStats::ATTACK]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if opponent.stages[PBStats::EVASION]>0
            miniscore = (-5)*attacker.stages[PBStats::ATTACK]
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          if (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
             (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER)
            score*=0.8
          end
          if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
             ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
            score*=0.8
          end
          if attacker.status==PBStatuses::PARALYSIS
            score*=0.5
          end
          if attacker.effects[PBEffects::Confusion]>0
            score*=0.5
          end
          if attacker.effects[PBEffects::Attract]>=0
            score*=0.5
          end
          if opponent.pbNonActivePokemonCount>1
            miniscore = 1 - (opponent.pbNonActivePokemonCount*0.05)
            score*=miniscore
          end
          if attacker.effects[PBEffects::DefenseCurl]
            score*=1.2
          end
          if checkAIdamage(aimem,attacker,opponent,skill)*3<attacker.hp && (aimem.length > 0)
            score*=1.5
          end
          score*=0.8 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
          if $fefieldeffect==13
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.3
            end
          end
      when 0xD4 # Bide
        statmove = false
        movelength = -1
        if aimem.length > 0
          for j in aimem
            movelength = aimem.length
            if j.basedamage==0
              statmove=true
            end
          end
        end
        if ((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY))
          score*=1.2
        end
        miniscore = attacker.hp*(1.0/attacker.totalhp)
        score*=miniscore
        if checkAIdamage(aimem,attacker,opponent,skill)*2 > attacker.hp
          score*=0.2
        end
        if attacker.hp*3<attacker.totalhp
          score*=0.7
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          score*=1.1
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          score*=1.3
        end
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.3
        end
        score*=0.5 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        if statmove
          score*=0.8
        else
          if movelength==4
            score*=1.3
          end
        end
      when 0xD5 # Recover
        if aimem.length > 0 && skill>=PBTrainerAI.bestSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>attacker.hp
            if maxdam>(attacker.hp*1.5)
              score=0
            else
              score*=5
            #experimental -- cancels out drop if killing moves
              if initialscores.length>0
                score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              #end experimental
            end
          else
            if maxdam*1.5>attacker.hp
              score*=2
            end
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              if maxdam*2>attacker.hp
                score*=5
                #experimental -- cancels out drop if killing moves
                if initialscores.length>0
                  score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
                end
                #end experimental
              end
            end
          end
        elsif skill>=PBTrainerAI.bestSkill #no highest expected damage yet
          if ((attacker.hp.to_f)/attacker.totalhp)<0.5
            score*=3
            if ((attacker.hp.to_f)/attacker.totalhp)<0.25
              score*=3
            end
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        elsif skill>=PBTrainerAI.mediumSkill
          score*=3 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        score*=0.7 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (attacker.hp.to_f)/attacker.totalhp<0.5
          score*=1.5
          if attacker.effects[PBEffects::Curse]
            score*=2
          end
          if attacker.hp*4<attacker.totalhp
            if attacker.status==PBStatuses::POISON
              score*=1.5
            end
            if attacker.effects[PBEffects::LeechSeed]>=0
              score*=2
            end
            if attacker.hp<attacker.totalhp*0.13
              if attacker.status==PBStatuses::BURN
                score*=2
              end
              if (pbWeather==PBWeather::HAIL && !attacker.pbHasType?(:ICE)) ||
                 (pbWeather==PBWeather::SANDSTORM && !attacker.pbHasType?(:ROCK) && !attacker.pbHasType?(:GROUND) && !attacker.pbHasType?(:STEEL))
                score*=2
              end
            end
          end
        else
          score*=0.9
        end
        if attacker.effects[PBEffects::Toxic]>0
          score*=0.5
          if attacker.effects[PBEffects::Toxic]>4
            score*=0.5
          end
        end
        if attacker.status==PBStatuses::PARALYSIS ||
           attacker.effects[PBEffects::Attract]>=0 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=1.1
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        score*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
          score*=1.2
        end
        if skill>=PBTrainerAI.bestSkill
          if move.id==(PBMoves::HEALORDER)
            if $fefieldeffect==15 # Forest
              score*=1.3
            end
          end
        end
        if ((attacker.hp.to_f)/attacker.totalhp)>0.8
          score=0
        elsif ((attacker.hp.to_f)/attacker.totalhp)>0.6
          score*=0.6
        elsif ((attacker.hp.to_f)/attacker.totalhp)<0.25
          score*=2
        end
        if attacker.effects[PBEffects::Wish]>0
            score=0
        end
      when 0xD6 # Roost
        besttype=-1
        if aimem.length > 0 && skill>=PBTrainerAI.bestSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>attacker.hp
            if maxdam>(attacker.hp*1.5)
              score=0
            else
              score*=5
            #experimental -- cancels out drop if killing moves
              if initialscores.length>0
                score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              #end experimental
            end
          else
            if maxdam*1.5>attacker.hp
              score*=2
            end
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              if maxdam*2>attacker.hp
                score*=5
                #experimental -- cancels out drop if killing moves
                if initialscores.length>0
                  score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
                end
                #end experimental
              end
            end
          end
        elsif skill>=PBTrainerAI.bestSkill #no highest expected damage yet
          if ((attacker.hp.to_f)/attacker.totalhp)<0.5
            score*=3
            if ((attacker.hp.to_f)/attacker.totalhp)<0.25
              score*=3
            end
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        elsif skill>=PBTrainerAI.mediumSkill
          score*=3 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        score*=0.7 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (attacker.hp.to_f)/attacker.totalhp<0.5
          score*=1.5
          if attacker.effects[PBEffects::Curse]
            score*=2
          end
          if attacker.hp*4<attacker.totalhp
            if attacker.status==PBStatuses::POISON
              score*=1.5
            end
            if attacker.effects[PBEffects::LeechSeed]>=0
              score*=2
            end
            if attacker.hp<attacker.totalhp*0.13
              if attacker.status==PBStatuses::BURN
                score*=2
              end
              if (pbWeather==PBWeather::HAIL && !attacker.pbHasType?(:ICE)) ||
                 (pbWeather==PBWeather::SANDSTORM && !attacker.pbHasType?(:ROCK) && !attacker.pbHasType?(:GROUND) && !attacker.pbHasType?(:STEEL))
                score*=2
              end
            end
          end
        else
          score*=0.9
        end
        if attacker.effects[PBEffects::Toxic]>0
          score*=0.5
          if attacker.effects[PBEffects::Toxic]>4
            score*=0.5
          end
        end
        if attacker.status==PBStatuses::PARALYSIS ||
           attacker.effects[PBEffects::Attract]>=0 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=1.1
        end
        #if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
        #  score*=0.8
        #end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        score*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
          score*=1.2
        end
        if besttype!=-1
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if (m.type == PBTypes::ROCK) || (m.type == PBTypes::ICE) || (m.type == PBTypes::ELECTRIC)
              score*=1.5
            else
              if (m.type == PBTypes::BUG) || (m.type == PBTypes::FIGHTING) ||
                 (m.type == PBTypes::GRASS) || (m.type == PBTypes::GROUND)
                score*=0.5
              end
            end
          end
        end
        if ((attacker.hp.to_f)/attacker.totalhp)>0.8
          score=0
        elsif ((attacker.hp.to_f)/attacker.totalhp)>0.6
          score*=0.6
        elsif ((attacker.hp.to_f)/attacker.totalhp)<0.25
          score*=2
        end
        if attacker.effects[PBEffects::Wish]>0
            score=0
        end
      when 0xD7 # Wish
        protectmove=false
        for j in attacker.moves
          protectmove = true if j.id==(PBMoves::PROTECT) || j.id==(PBMoves::DETECT) ||
                                j.id==(PBMoves::BANEFULBUNKER) || j.id==(PBMoves::SPIKYSHIELD)
        end
        if aimem.length > 0 && skill>=PBTrainerAI.bestSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>attacker.hp
            if maxdam>(attacker.hp*1.5)
              score=0
            else
              score*=5
            #experimental -- cancels out drop if killing moves
              if initialscores.length>0
                score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              #end experimental
            end
          else
            if maxdam*1.5>attacker.hp
              score*=2
            end
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              if maxdam*2>attacker.hp
                score*=5
                #experimental -- cancels out drop if killing moves
                if initialscores.length>0
                  score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
                end
                #end experimental
              end
            end
          end
        elsif skill>=PBTrainerAI.bestSkill #no highest expected damage yet
          if ((attacker.hp.to_f)/attacker.totalhp)<0.5
            score*=3
            if ((attacker.hp.to_f)/attacker.totalhp)<0.25
              score*=3
            end
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        elsif skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>attacker.hp
            score*=3
          end
        end
        score*=0.7 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (attacker.hp.to_f)/attacker.totalhp<0.5
          if attacker.effects[PBEffects::Curse]
            score*=2
          end
          if attacker.hp*4<attacker.totalhp
            if attacker.status==PBStatuses::POISON
              score*=1.5
            end
            if attacker.effects[PBEffects::LeechSeed]>=0
              score*=2
            end
            if attacker.hp<attacker.totalhp*0.13
              if attacker.status==PBStatuses::BURN
                score*=2
              end
              if (pbWeather==PBWeather::HAIL && !attacker.pbHasType?(:ICE)) ||
                 (pbWeather==PBWeather::SANDSTORM && !attacker.pbHasType?(:ROCK) && !attacker.pbHasType?(:GROUND) && !attacker.pbHasType?(:STEEL))
                score*=2
              end
            end
          end
        else
          score*=0.7
        end
        if attacker.effects[PBEffects::Toxic]>0
          score*=0.5
          if attacker.effects[PBEffects::Toxic]>4
            score*=0.5
          end
        end
        if attacker.status==PBStatuses::PARALYSIS ||
           attacker.effects[PBEffects::Attract]>=0 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=1.1
        end
        if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
          score*=0.8
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        score*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
          score*=1.2
        end
        if roles.include?(PBMonRoles::CLERIC)
          wishpass=false
          for i in pbParty(attacker.index)
            next if i.nil?
            if (i.hp.to_f)/(i.totalhp.to_f)<0.6 && (i.hp.to_f)/(i.totalhp.to_f)>0.3
              wishpass=true
            end
          end
          score*=1.3 if wishpass
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==3 || $fefieldeffect==9 || $fefieldeffect==29 ||
             $fefieldeffect==31 || $fefieldeffect==34 # Misty/Rainbow/Holy/Fairytale/Starlight
            score*=1.5
          end
        end
        if attacker.effects[PBEffects::Wish]>0
          score=0
        end
      when 0xD8 # Synthesis
        if aimem.length > 0 && skill>=PBTrainerAI.bestSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>attacker.hp
            if maxdam>(attacker.hp*1.5)
              score=0
            else
              score*=5
            #experimental -- cancels out drop if killing moves
              if initialscores.length>0
                score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              #end experimental
            end
          else
            if maxdam*1.5>attacker.hp
              score*=2
            end
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              if maxdam*2>attacker.hp
                score*=5
                #experimental -- cancels out drop if killing moves
                if initialscores.length>0
                  score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
                end
                #end experimental
              end
            end
          end
        elsif skill>=PBTrainerAI.bestSkill #no highest expected damage yet
          if ((attacker.hp.to_f)/attacker.totalhp)<0.5
            score*=3
            if ((attacker.hp.to_f)/attacker.totalhp)<0.25
              score*=3
            end
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        elsif skill>=PBTrainerAI.mediumSkill
          score*=3 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        score*=0.7 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (attacker.hp.to_f)/attacker.totalhp<0.5
          score*=1.5
          if attacker.effects[PBEffects::Curse]
            score*=2
          end
          if attacker.hp*4<attacker.totalhp
            if attacker.status==PBStatuses::POISON
              score*=1.5
            end
            if attacker.effects[PBEffects::LeechSeed]>=0
              score*=2
            end
            if attacker.hp<attacker.totalhp*0.13
              if attacker.status==PBStatuses::BURN
                score*=2
              end
              if (pbWeather==PBWeather::HAIL && !attacker.pbHasType?(:ICE)) ||
                 (pbWeather==PBWeather::SANDSTORM && !attacker.pbHasType?(:ROCK) && !attacker.pbHasType?(:GROUND) && !attacker.pbHasType?(:STEEL))
                score*=2
              end
            end
          end
        else
          score*=0.9
        end
        if attacker.effects[PBEffects::Toxic]>0
          score*=0.5
          if attacker.effects[PBEffects::Toxic]>4
            score*=0.5
          end
        end
        if attacker.status==PBStatuses::PARALYSIS ||
           attacker.effects[PBEffects::Attract]>=0 ||
           attacker.effects[PBEffects::Confusion]>0
          score*=1.1
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        score*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
          score*=1.2
        end
        if pbWeather==PBWeather::SUNNYDAY
          score*=1.3
        elsif pbWeather==PBWeather::SANDSTORM || pbWeather==PBWeather::RAINDANCE || pbWeather==PBWeather::HAIL
          score*=0.5
        end
        if skill>=PBTrainerAI.bestSkill
          if move.id==(PBMoves::MOONLIGHT)
            if $fefieldeffect==4 || $fefieldeffect==34 || $fefieldeffect==35  # Dark Crystal/Starlight/New World
              score*=1.3
            end
          else
            if $fefieldeffect==4
              score*=0.5
            end
          end
        end
        if ((attacker.hp.to_f)/attacker.totalhp)>0.8
          score=0
        elsif ((attacker.hp.to_f)/attacker.totalhp)>0.6
          score*=0.6
        elsif ((attacker.hp.to_f)/attacker.totalhp)<0.25
          score*=2
        end
        if attacker.effects[PBEffects::Wish]>0
            score=0
        end
      when 0xD9 # Rest
        if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
          score*=3
        else
          if skill>=PBTrainerAI.bestSkill
            if checkAIdamage(aimem,attacker,opponent,skill)*1.5>attacker.hp
              score*=1.5
            end
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              if checkAIdamage(aimem,attacker,opponent,skill)*2>attacker.hp
                score*=2
              end
            end
          end
        end
        if (attacker.hp.to_f)/attacker.totalhp<0.5
          score*=1.5
        else
          score*=0.5
        end
        if (roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
          score*=1.2
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
           opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        if attacker.status==PBStatuses::POISON
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        if attacker.status==PBStatuses::BURN
          score*=1.3
          if attacker.spatk<attacker.attack
            score*=1.5
          end
        end
        if attacker.status==PBStatuses::PARALYSIS
          score*=1.3
        end
        score*=1.3 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if attacker.hp*(1.0/attacker.totalhp)>=0.8
          score*=0
        end
        if !((attitemworks && attacker.item == PBItems::LUMBERRY) ||
           (attitemworks && attacker.item == PBItems::CHESTOBERRY) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::HYDRATION) && (pbWeather==PBWeather::RAINDANCE ||
           $fefieldeffect==21 || $fefieldeffect==22)))
          score*=0.8
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam*2 > attacker.totalhp
            score*=0.4
          else
            if maxdam*3 < attacker.totalhp
              score*=1.3
              #experimental -- cancels out drop if killing moves
              if initialscores.length>0
                score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              #end experimental
            end
          end
          if checkAImoves([PBMoves::WAKEUPSLAP,PBMoves::NIGHTMARE,PBMoves::DREAMEATER],aimem) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::BADDREAMS)
            score*=0.7
          end
          if attacker.pbHasMove?(:SLEEPTALK)
            score*=1.3
          end
          if attacker.pbHasMove?(:SNORE)
            score*=1.2
          end
          if !attacker.abilitynulled && (attacker.ability == PBAbilities::SHEDSKIN ||
             attacker.ability == PBAbilities::EARLYBIRD)
            score*=1.1
          end
          if @doublebattle
            score*=0.8
          end
        else
          if attitemworks && (attacker.item == PBItems::LUMBERRY ||
             attacker.item == PBItems::CHESTOBERRY)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::HARVEST)
              score*=1.2
            else
              score*=0.8
            end
          end
        end
        if attacker.status!=0
          score*=1.4
          if attacker.effects[PBEffects::Toxic]>0
            score*=1.2
          end
        end
        if !attacker.pbCanSleep?(false,true,true)
          score*=0
        end
      when 0xDA # Aqua Ring
        if !attacker.effects[PBEffects::AquaRing]
          if attacker.hp*(1.0/attacker.totalhp)>0.75
            score*=1.2
          end
          if attacker.hp*(1.0/attacker.totalhp)<0.50
            score*=0.7
            if attacker.hp*(1.0/attacker.totalhp)<0.33
              score*=0.5
            end
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::RAINDISH) && pbWeather==PBWeather::RAINDANCE) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::ICEBODY) && pbWeather==PBWeather::HAIL) ||
             attacker.effects[PBEffects::Ingrain] ||
             ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
             $fefieldeffect==2
            score*=1.2
          end
          if attacker.moves.any? {|moveloop| (PBStuff::PROTECTMOVE).include?(moveloop)}
            score*=1.2
          end
          if attacker.moves.any? {|moveloop| (PBStuff::PIVOTMOVE).include?(moveloop)}
            score*=0.8
          end
          if checkAIdamage(aimem,attacker,opponent,skill)*5 < attacker.totalhp && (aimem.length > 0)
            score*=1.2
          elsif checkAIdamage(aimem,attacker,opponent,skill) > attacker.totalhp*0.4
            score*=0.3
          end
          if (roles.include?(PBMonRoles::PHYSICALWALL) ||
             roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::TANK))
            score*=1.2
          end
          score*=0.3 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
          if @doublebattle
            score*=0.5
          end
          if $fefieldeffect==3 || $fefieldeffect==8 || $fefieldeffect==21 || $fefieldeffect==22
            score*=1.3
          end
          if $fefieldeffect==7
            score*=1.3
          end
          if $fefieldeffect==11
            score*=0.3
          end
        else
          score*=0
        end
      when 0xDB # Ingrain
        if !attacker.effects[PBEffects::Ingrain]
          if attacker.hp*(1.0/attacker.totalhp)>0.75
            score*=1.2
          end
          if attacker.hp*(1.0/attacker.totalhp)<0.50
            score*=0.7
            if attacker.hp*(1.0/attacker.totalhp)<0.33
              score*=0.5
            end
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::RAINDISH) && pbWeather==PBWeather::RAINDANCE) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::ICEBODY) && pbWeather==PBWeather::HAIL) ||
             attacker.effects[PBEffects::AquaRing] ||
             ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
             $fefieldeffect==2
            score*=1.2
          end
          if attacker.moves.any? {|moveloop| (PBStuff::PROTECTMOVE).include?(moveloop)}
            score*=1.2
          end
          if attacker.moves.any? {|moveloop| (PBStuff::PIVOTMOVE).include?(moveloop)}
            score*=0.8
          end
          if checkAIdamage(aimem,attacker,opponent,skill)*5 < attacker.totalhp && (aimem.length > 0)
            score*=1.2
          elsif checkAIdamage(aimem,attacker,opponent,skill) > attacker.totalhp*0.4
            score*=0.3
          end
          if (roles.include?(PBMonRoles::PHYSICALWALL) ||
             roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::TANK))
            score*=1.2
          end

          score*=0.3 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
          if @doublebattle
            score*=0.5
          end
          if $fefieldeffect==15 || $fefieldeffect==33
            score*=1.3
            if $fefieldeffect==33 && $fecounter>3
              score*=1.3
            end
          end
          if $fefieldeffect==8
            score*=0.1 unless (attacker.pbHasType?(:POISON) || attacker.pbHasType?(:STEEL))
          end
          if $fefieldeffect==10
            score*=0.1
          end
        else
          score*=0
        end
      when 0xDC # Leech Seed
        if opponent.effects[PBEffects::LeechSeed]<0 && ! opponent.pbHasType?(:GRASS) &&
           opponent.effects[PBEffects::Substitute]<=0
          if (roles.include?(PBMonRoles::PHYSICALWALL) ||
             roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::TANK))
            score*=1.2
          end
          if attacker.effects[PBEffects::Substitute]>0
            score*=1.3
          end
          if opponent.hp==opponent.totalhp
            score*=1.1
          else
            score*=(opponent.hp*(1.0/opponent.totalhp))
          end
          if (oppitemworks && opponent.item == PBItems::LEFTOVERS) ||
             (oppitemworks && opponent.item == PBItems::BIGROOT) ||
             ((oppitemworks && opponent.item == PBItems::BLACKSLUDGE) && opponent.pbHasType?(:POISON))
            score*=1.2
          end
          if opponent.status==PBStatuses::PARALYSIS || opponent.status==PBStatuses::SLEEP
            score*=1.2
          end
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.2
          end
          if opponent.effects[PBEffects::Attract]>=0
            score*=1.2
          end
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN
            score*=1.1
          end
          score*=0.2 if checkAImoves([PBMoves::RAPIDSPIN,PBMoves::UTURN,PBMoves::VOLTSWITCH],aimem)
          if opponent.hp*2<opponent.totalhp
            score*=0.8
            if opponent.hp*4<opponent.totalhp
              score*=0.2
            end
          end
          protectmove=false
          for j in attacker.moves
            protectmove = true if j.id==(PBMoves::PROTECT) || j.id==(PBMoves::DETECT) ||
                                  j.id==(PBMoves::BANEFULBUNKER) || j.id==(PBMoves::SPIKYSHIELD)
          end
          if protectmove
            score*=1.2
          end
          ministat= (5)* statchangecounter(opponent,1,7,1)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::LIQUIDOOZE) ||
             opponent.effects[PBEffects::Substitute]>0
            score*=0
          end
        else
          score*=0
        end
      when 0xDD # Drain Punch
        minimini = score*0.01
        miniscore = (opponent.hp*minimini)/2.0
        if miniscore > (attacker.totalhp-attacker.hp)
          miniscore = (attacker.totalhp-attacker.hp)
        end
        if attacker.totalhp>0
          miniscore/=(attacker.totalhp).to_f
        end
        if (attitemworks && attacker.item == PBItems::BIGROOT)
          miniscore*=1.3
        end
        miniscore *= 0.5 #arbitrary multiplier to make it value the HP less
        miniscore+=1
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::LIQUIDOOZE)
          miniscore = (2-miniscore)
        end
        if (attacker.hp!=attacker.totalhp ||
           ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))) &&
           opponent.effects[PBEffects::Substitute]==0
          score*=miniscore
        end
        ghostvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:GHOST)
            ghostvar=true
          end
        end
        if move.id==(PBMoves::PARABOLICCHARGE)
          if $fefieldeffect==18
            score*=1.1
            if ghostvar
              score*=0.8
            end
          end
        end
      when 0xDE # Dream Eater
        if opponent.status==PBStatuses::SLEEP
          minimini = score*0.01
          miniscore = (opponent.hp*minimini)/2.0
          if miniscore > (attacker.totalhp-attacker.hp)
            miniscore = (attacker.totalhp-attacker.hp)
          end
          if attacker.totalhp>0
            miniscore/=(attacker.totalhp).to_f
          end
          if (attitemworks && attacker.item == PBItems::BIGROOT)
            miniscore*=1.3
          end
          miniscore+=1
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::LIQUIDOOZE)
            miniscore = (2-miniscore)
          end
          if (attacker.hp!=attacker.totalhp ||
             ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))) &&
             opponent.effects[PBEffects::Substitute]==0
            score*=miniscore
          end
        else
          score*=0
        end
      when 0xDF # Heal Pulse
        if !@doublebattle || attacker.pbIsOpposing?(opponent.index)
          score*=0
        else
          if !attacker.pbIsOpposing?(opponent.index)
            if opponent.hp*(1.0/opponent.totalhp)<0.7 && opponent.hp*(1.0/opponent.totalhp)>0.3
              score*=3
            elsif opponent.hp*(1.0/opponent.totalhp)<0.3
              score*=1.7
            end
            if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
               opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
              score*=0.8
              if opponent.effects[PBEffects::Toxic]>0
                score*=0.7
              end
            end
            if opponent.hp*(1.0/opponent.totalhp)>0.8
              if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
                 ((attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
                score*=0.5
              else
                score*=0
              end
            end
          else
            score*=0
          end
        end
      when 0xE0 # Explosion
        score*=0.7
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
            if (attitemworks && attacker.item == PBItems::CUSTAPBERRY)
              score*=1.4
            end
          end
        end
        if roles.include?(PBMonRoles::LEAD)
          score*=1.2
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::DISGUISE) ||
           opponent.effects[PBEffects::Substitute]>0
          score*=0.3
        end
        score*=0.3 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
        firevar=false
        poisonvar=false
        ghostvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:POISON)
            poisonvar=true
          end
          if mon.hasType?(:GHOST)
            ghostvar=true
          end
        end
        if $fefieldeffect==16
          if pbWeather!=PBWeather::RAINDANCE && @field.effects[PBEffects::WaterSport]==0
            if firevar
              score*=2
            else
              score*=0.5
            end
          end
        elsif $fefieldeffect==11
          if !poisonvar
            score*=1.5
          else
            score*=0.5
          end
        elsif $fefieldeffect==24
          score*=1.5
        elsif $fefieldeffect==17
          score*=1.1
          if ghostvar
            score*=1.3
          end
        end
        if $fefieldeffect==3 || $fefieldeffect==8 || pbCheckGlobalAbility(:DAMP)
          score*=0
        end
      when 0xE1 # Final Gambit
        score*=0.7
        if attacker.hp > opponent.hp
          score*=1.1
        else
          score*=0.5
        end
        if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.1
        else
          score*=0.5
        end
        if (oppitemworks && opponent.item == PBItems::FOCUSSASH) || (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY)
          score*=0.2
        end
      when 0xE2 # Memento
        if initialscores.length>0
          score = 15 if hasbadmoves(initialscores,scoreindex,10)
        end
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
          end
        end
        if opponent.attack > opponent.spatk
          if opponent.stages[PBStats::ATTACK]<-1
            score*=0.1
          end
        else
          if opponent.stages[PBStats::SPATK]<-1
            score*=0.1
          end
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::CLEARBODY) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::WHITESMOKE)
          score*=0
        end
      when 0xE3 # Healing Wish
        count=0
        for mon in pbParty(opponent.index)
          next if mon.nil?
          count+=1 if mon.hp!=mon.totalhp
        end
        count-=1 if attacker.hp!=attacker.totalhp
        if count==0
          score*=0
        else
          maxscore = 0
          for mon in pbParty(opponent.index)
            next if mon.nil?
            if mon.hp!=mon.totalhp
              miniscore = 1 - mon.hp*(1.0/mon.totalhp)
              miniscore*=2 if mon.status!=0
              maxscore=miniscore if miniscore>maxscore
            end
          end
          score*=maxscore
        end
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
            if (attitemworks && attacker.item == PBItems::CUSTAPBERRY)
              score*=1.4
            end
          end
        end
        if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.1
        else
          score*=0.5
        end
        if $fefieldeffect==31 || $fefieldeffect==34
          score*=1.4
        end
      when 0xE4 # Lunar Dance
        count=0
        for mon in pbParty(opponent.index)
          next if mon.nil?
          count+=1 if mon.hp!=mon.totalhp
        end
        count-=1 if attacker.hp!=attacker.totalhp
        if count==0
          score*=0
        else
          maxscore = 0
          score*=1.2
          for mon in pbParty(opponent.index)
            next if mon.nil?
            if mon.hp!=mon.totalhp
              miniscore = 1 - mon.hp*(1.0/mon.totalhp)
              miniscore*=2 if mon.status!=0
              maxscore=miniscore if miniscore>maxscore
            end
          end
          score*=maxscore
        end
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
            if (attitemworks && attacker.item == PBItems::CUSTAPBERRY)
              score*=1.4
            end
          end
        end
        if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.1
        else
          score*=0.5
        end
        if $fefieldeffect==31 || $fefieldeffect==34
          score*=1.4
        elsif $fefieldeffect==35
          score*=2
        end
      when 0xE5 # Perish Song
        livecount1=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if livecount1==1 || (livecount1==2 && @doublebattle)
          score*=4
        else
          if attacker.pbHasMove?(:UTURN) || attacker.pbHasMove?(:VOLTSWITCH)
            score*=1.5
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) || opponent.effects[PBEffects::MeanLook]>0
            score*=3
          end
          if attacker.pbHasMove?(:PROTECT)
            score*=1.2
          end
          count = -1
          sweepvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          score*=1.2 if sweepvar
          for j in attacker.moves
            if j.isHealingMove?
              score*=1.2
              break
            end
          end
          miniscore=(-5)*statchangecounter(attacker,1,7)
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          miniscore= 5*statchangecounter(opponent,1,7)
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          score*=0.5 if checkAImoves(PBStuff::PIVOTMOVE,aimem)
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHADOWTAG) || attacker.effects[PBEffects::MeanLook]>0
            score*=0.1
          end
          count = -1
          pivotvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::PIVOT)
              pivotvar = true
            end
          end
          score*=1.5 if pivotvar
          if livecount2==1 || (livecount2==2 && @doublebattle)
            score*=0
          end
        end
        score*=0 if opponent.effects[PBEffects::PerishSong]>0
      when 0xE6 # Grudge
        movenum = 0
        damcount =0
        if aimem.length > 0
          for j in aimem
            movenum+=1
            if j.basedamage>0
              damcount+=1
            end
          end
        end
        if movenum==4 && damcount==1
          score*=3
        end
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
            if (attitemworks && attacker.item == PBItems::CUSTAPBERRY)
              score*=1.3
            end
          end
        end
        if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.3
        else
          score*=0.5
        end
      when 0xE7 # Destiny Bond
        movenum = 0
        damcount =0
        if aimem.length > 0
          for j in aimem
            movenum+=1
            if j.basedamage>0
              damcount+=1
            end
          end
        end
        if movenum==4 && damcount==4
          score*=3
        end
        if initialscores.length>0
          score*=0.1 if hasgreatmoves(initialscores,scoreindex,skill)
        end
        if attacker.hp==attacker.totalhp
          score*=0.2
        else
          miniscore = attacker.hp*(1.0/attacker.totalhp)
          miniscore = 1-miniscore
          score*=miniscore
          if attacker.hp*4<attacker.totalhp
            score*=1.3
            if (attitemworks && attacker.item == PBItems::CUSTAPBERRY)
              score*=1.5
            end
          end
        end
        if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.5
        else
          score*=0.5
        end
        if attacker.effects[PBEffects::DestinyRate]>1
          score*=0
        end
      when 0xE8 # Endure
        if attacker.hp>1
          if attacker.hp==attacker.totalhp && ((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY))
            score*=0
          end
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=2
          end
          if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.3
          else
            score*=0.5
          end
          if (pbWeather==PBWeather::HAIL && !attacker.pbHasType?(:ICE)) ||
             (pbWeather==PBWeather::SANDSTORM && !(attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=0
          end
          if $fefieldeffect==7 || $fefieldeffect==26
            score*=0
          end
          if attacker.status==PBStatuses::POISON || attacker.status==PBStatuses::BURN ||
            attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Curse]
            score*=0
          end
          if attacker.pbHasMove?(:PAINSPLIT) ||
             attacker.pbHasMove?(:FLAIL) ||
             attacker.pbHasMove?(:REVERSAL)
            score*=2
          end
          if attacker.pbHasMove?(:ENDEAVOR)
            score*=3
          end
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
             opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
            score*=1.5
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=15
            end
          end
        else
          score*=0
        end
      when 0xE9 # False Swipe
        if score>=100
          score*=0.1
        end
      when 0xEA # Teleport
        score*=0
      when 0xEB # Roar
        if opponent.pbOwnSide.effects[PBEffects::StealthRock]
          score*=1.3
        else
          score*=0.8
        end
        if opponent.pbOwnSide.effects[PBEffects::Spikes]>0
          score*=(1.2**opponent.pbOwnSide.effects[PBEffects::Spikes])
        else
          score*=0.8
        end
        if opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
          score*=1.1
        end
        ministat = 10*statchangecounter(opponent,1,7)
        ministat+=100
        ministat/=100.0
        score*=ministat
        if opponent.effects[PBEffects::PerishSong]>0 || opponent.effects[PBEffects::Yawn]>0
          score*=0
        end
        if opponent.status==PBStatuses::SLEEP
          score*=1.3
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SLOWSTART)
          score*=1.3
        end
        if opponent.item ==0 && (!opponent.abilitynulled && opponent.ability == PBAbilities::UNBURDEN)
          score*=1.5
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::INTIMIDATE)
          score*=0.7
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::REGENERATOR) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
          score*=0.5
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.8
        end
        if attacker.effects[PBEffects::Substitute]>0
          score*=1.4
        end
        firevar=false
        poisonvar=false
        fairytvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:POISON)
            poisonvar=true
          end
          if mon.hasType?(:FAIRY)
            fairyvar=true
          end
        end
        if $fefieldeffect==3
          score*=1.3
          if !fairyvar
            score*=1.3
          else
            score*=0.8
          end
        elsif $fefielfeffect==7
          if !firevar
            score*=1.8
          else
            score*=0.5
          end
        elsif $fefieldeffect==11
          if !poisonvar
            score*=3
          else
            score*=0.8
          end
        end
        if opponent.effects[PBEffects::Ingrain] || (!opponent.abilitynulled &&
           opponent.ability == PBAbilities::SUCTIONCUPS) || opponent.pbNonActivePokemonCount==0
          score*=0
        end
      when 0xEC # Dragon Tail
        if opponent.effects[PBEffects::Substitute]<=0
          miniscore=1
          if opponent.pbOwnSide.effects[PBEffects::StealthRock]
            miniscore*=1.3
          else
            miniscore*=0.8
          end
          if opponent.pbOwnSide.effects[PBEffects::Spikes]>0
            miniscore*=(1.2**opponent.pbOwnSide.effects[PBEffects::Spikes])
          else
            miniscore*=0.8
          end
          if opponent.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
            miniscore*=1.1
          end
          ministat = 10*statchangecounter(opponent,1,7)
          ministat+=100
          ministat/=100.0
          miniscore*=ministat
          if opponent.status==PBStatuses::SLEEP
            miniscore*=1.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SLOWSTART)
            miniscore*=1.3
          end
          if opponent.item ==0 && (!opponent.abilitynulled && opponent.ability == PBAbilities::UNBURDEN)
            miniscore*=1.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::INTIMIDATE)
            miniscore*=0.7
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::REGENERATOR) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.5
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            miniscore*=0.8
          end
          if opponent.effects[PBEffects::PerishSong]>0 || opponent.effects[PBEffects::Yawn]>0
            miniscore=1
          end
          if attacker.effects[PBEffects::Substitute]>0
            miniscore=1
          end
          if opponent.effects[PBEffects::Ingrain] || (!opponent.abilitynulled &&
             opponent.ability == PBAbilities::SUCTIONCUPS) || opponent.pbNonActivePokemonCount==0
            miniscore=1
          end
          score*=miniscore
        end
      when 0xED # Baton Pass
        if pbCanChooseNonActive?(attacker.index)
          ministat = 10*statchangecounter(attacker,1,7)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if attacker.effects[PBEffects::Substitute]>0
            score*=1.3
          end
          if attacker.effects[PBEffects::Confusion]>0
            score*=0.5
          end
          if attacker.effects[PBEffects::LeechSeed]>=0
            score*=0.5
          end
          if attacker.effects[PBEffects::Curse]
            score*=0.5
          end
          if attacker.effects[PBEffects::Yawn]>0
            score*=0.5
          end
          if attacker.turncount<1
            score*=0.5
          end
          damvar = false
          for i in attacker.moves
            if i.basedamage>0
              damvar=true
            end
          end
          if !damvar
            score*=1.3
          end
          if attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing]
            score*=1.2
          end
          if attacker.effects[PBEffects::PerishSong]>0
            score*=0
          else
            if initialscores.length>0
              if damvar
                if initialscores.max>30
                  score*=0.7
                  if initialscores.max>50
                    score*=0.3
                  end
                end
              end
            end
          end
        else
          score*=0
        end
      when 0xEE # U-Turn
        livecount=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount+=1 if i.hp!=0
        end
        if livecount>1
          if livecount==2
            if $game_switches[1000]
              score*=0
            end
          end
          if initialscores.length>0
            greatmoves=false
            badmoves=true
            iffymoves=true
            for i in 0...initialscores.length
              next if i==scoreindex
              if initialscores[i]>=110
                greatmoves=true
              end
              if initialscores[i]>=25
                badmoves=false
              end
              if initialscores[i]>=50
                iffymoves=false
              end
            end
            score*=0.5 if greatmoves
            if badmoves == true
              score+=40
            elsif iffymoves == true
              score+=20
            end
          end
          if attacker.pbOwnSide.effects[PBEffects::StealthRock]
            score*=0.7
          end
          if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
            score*=0.6
          end
          if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
            score*=0.9**attacker.pbOwnSide.effects[PBEffects::Spikes]
          end
          if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
            score*=0.9**attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]
          end
          count = -1
          sweepvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.2
          else
            if sweepvar
              score*=1.2
            end
          end
          if roles.include?(PBMonRoles::LEAD)
            score*=1.2
          end
          if roles.include?(PBMonRoles::PIVOT)
            score*=1.1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::REGENERATOR) &&
             ((attacker.hp.to_f)/attacker.totalhp)<0.75
            score*=1.2
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::REGENERATOR) &&
               ((attacker.hp.to_f)/attacker.totalhp)<0.5
              score*=1.2
            end
          end
          loweredstats=0
          loweredstats+=attacker.stages[PBStats::ATTACK] if attacker.stages[PBStats::ATTACK]<0
          loweredstats+=attacker.stages[PBStats::DEFENSE] if attacker.stages[PBStats::DEFENSE]<0
          loweredstats+=attacker.stages[PBStats::SPEED] if attacker.stages[PBStats::SPEED]<0
          loweredstats+=attacker.stages[PBStats::SPATK] if attacker.stages[PBStats::SPATK]<0
          loweredstats+=attacker.stages[PBStats::SPDEF] if attacker.stages[PBStats::SPDEF]<0
          loweredstats+=attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION]<0
          miniscore= (-15)*loweredstats
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          raisedstats=0
          raisedstats+=attacker.stages[PBStats::ATTACK] if attacker.stages[PBStats::ATTACK]>0
          raisedstats+=attacker.stages[PBStats::DEFENSE] if attacker.stages[PBStats::DEFENSE]>0
          raisedstats+=attacker.stages[PBStats::SPEED] if attacker.stages[PBStats::SPEED]>0
          raisedstats+=attacker.stages[PBStats::SPATK] if attacker.stages[PBStats::SPATK]>0
          raisedstats+=attacker.stages[PBStats::SPDEF] if attacker.stages[PBStats::SPDEF]>0
          raisedstats+=attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION]>0
          miniscore= (-25)*raisedstats
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          if attacker.effects[PBEffects::Toxic]>0 || attacker.effects[PBEffects::Attract]>-1 ||
             attacker.effects[PBEffects::Confusion]>0
            score*=1.3
          end
          if attacker.effects[PBEffects::LeechSeed]>-1
            score*=1.5
          end
        end
      when 0xEF # Mean Look
        if !(opponent.effects[PBEffects::MeanLook]>=0 || opponent.effects[PBEffects::Ingrain] ||
           opponent.pbHasType?(:GHOST)) && opponent.effects[PBEffects::Substitute]<=0
          score*=0.1 if checkAImoves(PBStuff::PIVOTMOVE,aimem)
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::RUNAWAY)
            score*=0.1
          end
          if attacker.pbHasMove?(:PERISHSONG)
            score*=1.5
          end
          if opponent.effects[PBEffects::PerishSong]>0
            score*=4
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG)
            score*=0
          end
          if opponent.effects[PBEffects::Attract]>=0
            score*=1.3
          end
          if opponent.effects[PBEffects::LeechSeed]>=0
            score*=1.3
          end
          if opponent.effects[PBEffects::Curse]
            score*=1.5
          end
          miniscore*=0.7 if attacker.moves.any? {|moveloop| (PBStuff::SWITCHOUTMOVE).include?(moveloop)}
          ministat = (-5)*statchangecounter(opponent,1,7)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.1
          end
        else
          score*=0
        end
      when 0x0EF # Thousand Waves
        if !(opponent.effects[PBEffects::MeanLook]>=0 || opponent.effects[PBEffects::Ingrain] || opponent.pbHasType?(:GHOST)) && opponent.effects[PBEffects::Substitute]<=0
          score*=0.1 if checkAImoves(PBStuff::PIVOTMOVE,aimem)
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::RUNAWAY)
            score*=0.1
          end
          if attacker.pbHasMove?(:PERISHSONG)
            score*=1.5
          end
          if opponent.effects[PBEffects::PerishSong]>0
            score*=4
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) || (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG)
            score*=0
          end
          if opponent.effects[PBEffects::Attract]>=0
            score*=1.3
          end
          if opponent.effects[PBEffects::LeechSeed]>=0
            score*=1.3
          end
          if opponent.effects[PBEffects::Curse]
            score*=1.5
          end
          miniscore*=0.7 if attacker.moves.any? {|moveloop| (PBStuff::SWITCHOUTMOVE).include?(moveloop)}
          ministat=(-5)*statchangecounter(opponent,1,7)
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.1
          end
        end
      when 0xF0 # Knock Off
        if !hasgreatmoves(initialscores,scoreindex,skill) && opponent.effects[PBEffects::Substitute]<=0
          if (!(!opponent.abilitynulled && opponent.ability == PBAbilities::STICKYHOLD) ||
             opponent.moldbroken) && opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item)
            score*=1.1
            if oppitemworks
              if opponent.item == PBItems::LEFTOVERS || (opponent.item == PBItems::BLACKSLUDGE) &&
                 opponent.pbHasType?(:POISON)
                score*=1.2
              elsif opponent.item == PBItems::LIFEORB || opponent.item == PBItems::CHOICESCARF ||
                    opponent.item == PBItems::CHOICEBAND || opponent.item == PBItems::CHOICESPECS ||
                    opponent.item == PBItems::ASSAULTVEST
                score*=1.1
              end
            end
          end
        end
      when 0xF1 # Covet
        if (!(!opponent.abilitynulled && opponent.ability == PBAbilities::STICKYHOLD) ||
           opponent.moldbroken) && opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item) &&
           attacker.item ==0 && opponent.effects[PBEffects::Substitute]<=0
          miniscore = 1.2
          case opponent.item
            when (PBItems::LEFTOVERS), (PBItems::LIFEORB), (PBItems::LUMBERRY), (PBItems::SITRUSBERRY)
              miniscore*=1.5
            when (PBItems::ASSAULTVEST), (PBItems::ROCKYHELMET), (PBItems::MAGICALSEED),
                 (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED), (PBItems::ELEMENTALSEED)
              miniscore*=1.3
            when (PBItems::FOCUSSASH), (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES),
                 (PBItems::EXPERTBELT), (PBItems::WIDELENS)
              miniscore*=1.2
            when (PBItems::CHOICESCARF)
              if attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
                miniscore*=1.1
              end
            when (PBItems::CHOICEBAND)
              if attacker.attack>attacker.spatk
                miniscore*=1.1
              end
            when (PBItems::CHOICESPECS)
              if attacker.spatk>attacker.attack
                miniscore*=1.1
              end
            when (PBItems::BLACKSLUDGE)
              if attacker.pbHasType?(:POISON)
                miniscore*=1.5
              else
                miniscore*=0.5
              end
            when (PBItems::TOXICORB), (PBItems::FLAMEORB), (PBItems::LAGGINGTAIL),
                 (PBItems::IRONBALL), (PBItems::STICKYBARB)
              miniscore*=0.5
          end
          score*=miniscore
        end
      when 0xF2 # Trick
        statvar = false
        for m in opponent.moves
          if m.basedamage==0
            statvar=true
          end
        end
        if (!(!opponent.abilitynulled && opponent.ability == PBAbilities::STICKYHOLD) ||
            opponent.moldbroken) && opponent.effects[PBEffects::Substitute]<=0
          miniscore = 1
          minimini = 1
          if opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item)
            miniscore*=1.2
            case opponent.item
              when (PBItems::LEFTOVERS), (PBItems::LIFEORB), (PBItems::LUMBERRY), (PBItems::SITRUSBERRY)
                miniscore*=1.5
              when (PBItems::ASSAULTVEST), (PBItems::ROCKYHELMET), (PBItems::MAGICALSEED),
                   (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED), (PBItems::ELEMENTALSEED)
                miniscore*=1.3
              when (PBItems::FOCUSSASH), (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES),
                   (PBItems::EXPERTBELT), (PBItems::WIDELENS)
                miniscore*=1.2
              when (PBItems::CHOICESCARF)
                if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))
                  miniscore*=1.1
                end
              when (PBItems::CHOICEBAND)
                if attacker.attack>attacker.spatk
                  miniscore*=1.1
                end
              when (PBItems::CHOICESPECS)
                if attacker.spatk>attacker.attack
                  miniscore*=1.1
                end
              when (PBItems::BLACKSLUDGE)
                if attacker.pbHasType?(:POISON)
                  miniscore*=1.5
                else
                  miniscore*=0.5
                end
              when (PBItems::TOXICORB), (PBItems::FLAMEORB), (PBItems::LAGGINGTAIL),
                   (PBItems::IRONBALL), (PBItems::STICKYBARB)
                miniscore*=0.5
            end
          end
          if attacker.item!=0 && !pbIsUnlosableItem(attacker,attacker.item)
            minimini*=0.8
            case attacker.item
              when (PBItems::LEFTOVERS), (PBItems::LIFEORB), (PBItems::LUMBERRY), (PBItems::SITRUSBERRY)
                minimini*=0.5
              when (PBItems::ASSAULTVEST), (PBItems::ROCKYHELMET), (PBItems::MAGICALSEED),
                   (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED), (PBItems::ELEMENTALSEED)
                minimini*=0.7
              when (PBItems::FOCUSSASH), (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES),
                   (PBItems::EXPERTBELT), (PBItems::WIDELENS)
                minimini*=0.8
              when (PBItems::CHOICESCARF)
                if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))
                  minimini*=1.5
                else
                  minimini*=0.9
                end
                if statvar
                  minimini*=1.3
                end
              when (PBItems::CHOICEBAND)
                if opponent.attack<opponent.spatk
                  minimini*=1.7
                end
                if attacker.attack>attacker.spatk
                  minimini*=0.8
                end
                if statvar
                  minimini*=1.3
                end
              when (PBItems::CHOICESPECS)
                if opponent.attack>opponent.spatk
                  minimini*=1.7
                end
                if attacker.attack<attacker.spatk
                  minimini*=0.8
                end
                if statvar
                  minimini*=1.3
                end
              when (PBItems::BLACKSLUDGE)
                if !attacker.pbHasType?(:POISON)
                  minimini*=1.5
                else
                  minimini*=0.5
                end
                if !opponent.pbHasType?(:POISON)
                  minimini*=1.3
                end
              when (PBItems::TOXICORB), (PBItems::FLAMEORB), (PBItems::LAGGINGTAIL),
                   (PBItems::IRONBALL), (PBItems::STICKYBARB)
                minimini*=1.5
            end
          end
          score*=(miniscore*minimini)
        else
          score*=0
        end
        if attacker.item ==opponent.item
          score*=0
        end
      when 0xF3 # Bestow
        if (!(!opponent.abilitynulled && opponent.ability == PBAbilities::STICKYHOLD) ||
           opponent.moldbroken) && attacker.item!=0 && opponent.item ==0 &&
           !pbIsUnlosableItem(attacker,attacker.item) && opponent.effects[PBEffects::Substitute]<=0
          case attacker.item
            when (PBItems::CHOICESPECS)
              if opponent.attack>opponent.spatk
                score+=35
              end
            when (PBItems::CHOICESCARF)
              if (opponent.pbSpeed>attacker.pbSpeed) ^ (@trickroom!=0)
                score+=25
              end
            when (PBItems::CHOICEBAND)
              if opponent.attack<opponent.spatk
                score+=35
              end
            when (PBItems::BLACKSLUDGE)
              if !attacker.pbHasType?(:POISON)
                score+=15
              end
              if !opponent.pbHasType?(:POISON)
                score+=15
              end
            when (PBItems::TOXICORB), (PBItems::FLAMEORB)
              score+=35
            when (PBItems::LAGGINGTAIL), (PBItems::IRONBALL)
              score+=20
            when (PBItems::STICKYBARB)
              score+=25
          end
        else
          score*=0
        end
      when 0xF4 # Bug Bite
        if opponent.effects[PBEffects::Substitute]==0 && pbIsBerry?(opponent.item)
          case opponent.item
            when (PBItems::LUMBERRY)
              score*=2 if attacker.stats!=0
            when (PBItems::SITRUSBERRY)
              score*=1.6 if attacker.hp*(1.0/attacker.totalhp)<0.66
            when (PBItems::LIECHIBERRY)
              score*=1.5 if attacker.attack>attacker.spatk
            when (PBItems::PETAYABERRY)
              score*=1.5 if attacker.spatk>attacker.attack
            when (PBItems::CUSTAPBERRY), (PBItems::SALACBERRY)
              score*=1.1
              score*=1.4 if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))
          end
        end
      when 0xF5 # Incinerate
        if (pbIsBerry?(opponent.item) || pbIsTypeGem?(opponent.item)) &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::STICKYHOLD) &&
           opponent.effects[PBEffects::Substitute]<=0
          if pbIsBerry?(opponent.item) && opponent.item!=(PBItems::OCCABERRY)
            score*=1.2
          end
          if opponent.item ==(PBItems::LUMBERRY) || opponent.item ==(PBItems::SITRUSBERRY) ||
             opponent.item ==(PBItems::PETAYABERRY) || opponent.item ==(PBItems::LIECHIBERRY) ||
             opponent.item ==(PBItems::SALACBERRY) || opponent.item ==(PBItems::CUSTAPBERRY)
            score*=1.3
          end
          if pbIsTypeGem?(opponent.item)
            score*=1.4
          end
          firevar=false
          poisonvar=false
          bugvar=false
          grassvar=false
          icevar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:FIRE)
              firevar=true
            end
            if mon.hasType?(:POISON)
              poisonvar=true
            end
            if mon.hasType?(:BUG)
              bugvar=true
            end
            if mon.hasType?(:GRASS)
              grassvar=true
            end
            if mon.hasType?(:ICE)
              icevar=true
            end
          end
          if $fefieldeffect==2 || $fefieldeffect==15 || ($fefieldeffect==33 && $fecounter>1)
            if firevar && !(bugvar || grassvar)
              score*=2
            end
          elsif $fefieldeffect==16
            if firevar
              score*=2
            end
          elsif $fefieldeffect==13 || $fefieldeffect==28
            if !icevar
              score*=1.5
            end
          end
        end
      when 0xF6 # Recycle
        if attacker.pokemon.itemRecycle!=0
          score*=2
          case attacker.pokemon.itemRecycle
            when (PBItems::LUMBERRY)
              score*=2 if attacker.stats!=0
            when (PBItems::SITRUSBERRY)
              score*=1.6 if attacker.hp*(1.0/attacker.totalhp)<0.66
              if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
                score*=1.5
              end
          end
          if pbIsBerry?(attacker.pokemon.itemRecycle)
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNNERVE)
              score*=0
            end
            score*=0 if checkAImoves([PBMoves::INCINERATE,PBMoves::PLUCK,PBMoves::BUGBITE],aimem)
          end
          score*=0 if (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICIAN) ||
                      checkAImoves([PBMoves::KNOCKOFF,PBMoves::THIEF,PBMoves::COVET],aimem)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::HARVEST) ||
             attacker.pbHasMove?(:ACROBATICS)
            score*=0
          end
        else
          score*=0
        end
      when 0xF7 # Fling
        if attacker.item ==0 || pbIsUnlosableItem(attacker,attacker.item) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::KLUTZ) ||
           (pbIsBerry?(attacker.item) && (!opponent.abilitynulled && opponent.ability == PBAbilities::UNNERVE)) ||
           attacker.effects[PBEffects::Embargo]>0 || @field.effects[PBEffects::MagicRoom]>0
          score*=0
        else
          case attacker.item
            when (PBItems::POISONBARB)
              if opponent.pbCanPoison?(false) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL)
                score*=1.2
              end
            when (PBItems::TOXICORB)
              if opponent.pbCanPoison?(false) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL)
                score*=1.2
                if attacker.pbCanPoison?(false) && !(!attacker.abilitynulled && attacker.ability == PBAbilities::POISONHEAL)
                  score*=2
                end
              end
            when (PBItems::FLAMEORB)
              if opponent.pbCanBurn?(false) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
                score*=1.3
                if attacker.pbCanBurn?(false) && !(!attacker.abilitynulled && attacker.ability == PBAbilities::GUTS)
                  score*=2
                end
              end
            when (PBItems::LIGHTBALL)
              if opponent.pbCanParalyze?(false) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET)
                score*=1.3
              end
            when (PBItems::KINGSROCK), (PBItems::RAZORCLAW)
              if !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS) && ((attacker.pbSpeed>opponent.pbSpeed) ^ (@trickroom!=0))
                score*=1.3
              end
            when (PBItems::POWERHERB)
              score*=0
            when (PBItems::MENTALHERB)
              score*=0
            when (PBItems::LAXINCENSE), (PBItems::CHOICESCARF), (PBItems::CHOICEBAND),
                 (PBItems::CHOICESPECS), (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED),
                 (PBItems::ELEMENTALSEED), (PBItems::MAGICALSEED), (PBItems::EXPERTBELT),
                 (PBItems::FOCUSSASH), (PBItems::LEFTOVERS), (PBItems::MUSCLEBAND),
                 (PBItems::WISEGLASSES), (PBItems::LIFEORB), (PBItems::EVIOLITE),
                 (PBItems::ASSAULTVEST), (PBItems::BLACKSLUDGE)
              score*=0
            when (PBItems::STICKYBARB)
              score*=1.2
            when (PBItems::LAGGINGTAIL)
              score*=3
            when (PBItems::IRONBALL)
              score*=1.5
          end
          if pbIsBerry?(attacker.item)
            if attacker.item ==(PBItems::FIGYBERRY) || attacker.item ==(PBItems::WIKIBERRY) ||
               attacker.item ==(PBItems::MAGOBERRY) || attacker.item ==(PBItems::AGUAVBERRY) ||
               attacker.item ==(PBItems::IAPAPABERRY)
              if opponent.pbCanConfuse?(false)
                score*=1.3
              end
            else
              score*=0
            end
          end
        end
      when 0xF8 # Embargo
        startscore = score
        if opponent.effects[PBEffects::Embargo]>0  && opponent.effects[PBEffects::Substitute]>0
          score*=0
        else
          if opponent.item!=0
            score*=1.1
            if pbIsBerry?(opponent.item)
              score*=1.1
            end
            case opponent.item
              when (PBItems::LAXINCENSE), (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED),
                   (PBItems::ELEMENTALSEED), (PBItems::MAGICALSEED), (PBItems::EXPERTBELT),
                   (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES), (PBItems::LIFEORB),
                   (PBItems::EVIOLITE), (PBItems::ASSAULTVEST)
                score*=1.2
              when (PBItems::LEFTOVERS), (PBItems::BLACKSLUDGE)
                score*=1.3
            end
            if opponent.hp*2<opponent.totalhp
              score*=1.4
            end
          end
          if score==startscore
            score*=0
          end
        end
      when 0xF9 # Magic Room
        if @field.effects[PBEffects::MagicRoom]>0
          score*=0
        else
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK) || $fefieldeffect==35 || $fefieldeffect==37
            score*=1.3
          end
          if opponent.item!=0
            score*=1.1
            if pbIsBerry?(opponent.item)
              score*=1.1
            end
            case opponent.item
              when (PBItems::LAXINCENSE), (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED),
                   (PBItems::ELEMENTALSEED), (PBItems::MAGICALSEED), (PBItems::EXPERTBELT),
                   (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES), (PBItems::LIFEORB),
                   (PBItems::EVIOLITE), (PBItems::ASSAULTVEST)
                score*=1.2
              when (PBItems::LEFTOVERS), (PBItems::BLACKSLUDGE)
                score*=1.3
            end
          end
          if attacker.item!=0
            score*=0.8
            if pbIsBerry?(opponent.item)
              score*=0.8
            end
            case opponent.item
              when (PBItems::LAXINCENSE), (PBItems::SYNTHETICSEED), (PBItems::TELLURICSEED),
                   (PBItems::ELEMENTALSEED), (PBItems::MAGICALSEED), (PBItems::EXPERTBELT),
                   (PBItems::MUSCLEBAND), (PBItems::WISEGLASSES), (PBItems::LIFEORB),
                   (PBItems::EVIOLITE), (PBItems::ASSAULTVEST)
                score*=0.6
              when (PBItems::LEFTOVERS), (PBItems::BLACKSLUDGE)
                score*=0.4
            end
          end
        end
      when 0xFA # Take Down
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD)
          score*=0.9
          if attacker.hp==attacker.totalhp && ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH))
            score*=0.7
          end
          if attacker.hp*(1.0/attacker.totalhp)>0.1 && attacker.hp*(1.0/attacker.totalhp)<0.4
            score*=0.8
          end
        end
        ghostvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:GHOST)
            ghostvar=true
          end
        end
        if move.id==(PBMoves::WILDCHARGE)
          if $fefieldeffect==18
            score*=1.1
            if ghostvar
              score*=0.8
            end
          end
        end
      when 0xFB # Wood Hammer
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD)
          score*=0.9
          if attacker.hp==attacker.totalhp && ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH))
            score*=0.7
          end
          if attacker.hp*(1.0/attacker.totalhp)>0.15 && attacker.hp*(1.0/attacker.totalhp)<0.4
            score*=0.8
          end
        end
      when 0xFC # Head Smash
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD)
          score*=0.9
          if attacker.hp==attacker.totalhp && ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH))
            score*=0.7
          end
          if attacker.hp*(1.0/attacker.totalhp)>0.2 && attacker.hp*(1.0/attacker.totalhp)<0.4
            score*=0.8
          end
        end
      when 0xFD # Volt Tackle
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD)
          score*=0.9
          if attacker.hp==attacker.totalhp && ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH))
            score*=0.7
          end
          if attacker.hp*(1.0/attacker.totalhp)>0.15 && attacker.hp*(1.0/attacker.totalhp)<0.4
            score*=0.8
          end
        end
        if opponent.pbCanParalyze?(false)
          miniscore=100
          miniscore*=1.1
          miniscore*=1.3 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          ministat+=opponent.stages[PBStats::SPATK]
          ministat+=opponent.stages[PBStats::SPEED]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) || roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.5
          end
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.5
          end
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.3
          end
          count = -1
          sweepvar = false
          for i in pbParty(attacker.index)
            count+=1
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          miniscore*=1.3 if sweepvar
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            miniscore*=0.7
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SYNCHRONIZE) &&
             attacker.status==0 && !attacker.pbHasType?(:ELECTRIC) && !attacker.pbHasType?(:GROUND)
            miniscore*=0.5
          end
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
      when 0xFE # Flare Blitz
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD)
          score*=0.9
          if attacker.hp==attacker.totalhp &&
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH))
            score*=0.7
          end
          if attacker.hp*(1.0/attacker.totalhp)>0.2 && attacker.hp*(1.0/attacker.totalhp)<0.4
            score*=0.8
          end
        end
        if opponent.pbCanBurn?(false)
          miniscore=100
          miniscore*=1.2
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          ministat+=opponent.stages[PBStats::SPATK]
          ministat+=opponent.stages[PBStats::SPEED]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::NATURALCURE)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            miniscore*=0.7
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::FLAREBOOST) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICGUARD)
            miniscore*=0.3
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.1
          end
          miniscore*=0.3 if checkAImoves([PBMoves::FACADE],aimem)
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.7
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SYNCHRONIZE) && attacker.status==0
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            miniscore*=0.7
          end
          if move.basedamage>0
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY)
              miniscore*=1.1
            end
          end
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
      when 0xFF # Sunny Day
        if pbCheckGlobalAbility(:AIRLOCK) ||
          pbCheckGlobalAbility(:CLOUDNINE) ||
          pbCheckGlobalAbility(:DELTASTREAM) ||
          pbCheckGlobalAbility(:DESOLATELAND) ||
          pbCheckGlobalAbility(:PRIMORDIALSEA) ||
          pbWeather==PBWeather::SUNNYDAY
          score*=0
        end
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          score*=1.3
        end
        if roles.include?(PBMonRoles::LEAD)
          score*=1.2
        end
        if (attitemworks && attacker.item == PBItems::HEATROCK)
          score*=1.3
        end
        if attacker.pbHasMove?(:WEATHERBALL) || (!attacker.abilitynulled && attacker.ability == PBAbilities::FORECAST)
          score*=2
        end
        if pbWeather!=0 && pbWeather!=PBWeather::SUNNYDAY
          score*=1.5
        end
        if attacker.pbHasMove?(:MOONLIGHT) || attacker.pbHasMove?(:SYNTHESIS) ||
           attacker.pbHasMove?(:MORNINGSUN) || attacker.pbHasMove?(:GROWTH) ||
           attacker.pbHasMove?(:SOLARBEAM) || attacker.pbHasMove?(:SOLARBLADE)
          score*=1.5
        end
        if attacker.pbHasType?(:FIRE)
          score*=1.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CHLOROPHYLL) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::FLOWERGIFT)
          score*=2
          if (attitemworks && attacker.item == PBItems::FOCUSSASH)
            score*=2
          end
          if attacker.effects[PBEffects::KingsShield]== true ||
          attacker.effects[PBEffects::BanefulBunker]== true ||
          attacker.effects[PBEffects::SpikyShield]== true
            score *=3
          end
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SOLARPOWER) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::LEAFGUARD)
          score*=1.3
        end
        watervar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:WATER)
            watervar=true
          end
        end
        if watervar
          score*=0.5
        end
        if attacker.pbHasMove?(:THUNDER) || attacker.pbHasMove?(:HURRICANE)
          score*=0.7
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::DRYSKIN)
          score*=0.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::HARVEST)
          score*=1.5
        end
        if pbWeather==PBWeather::RAINDANCE
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if attacker.pbHasType?(:NORMAL)
            miniscore*=1.2
          end
          score*=miniscore
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==12 || $fefieldeffect==27 || $fefieldeffect==28 # Desert/Mountian/Snowy Mountain
            score*=1.3
          end
          if $fefieldeffect==33 # Flower Garden
            score*=2
          end
          if $fefieldeffect==4 # Dark Crystal
            darkvar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:DARK)
                darkvar=true
              end
            end
            if !darkvar
              score*=3
            end
          end
          if $fefieldeffect==22 || $fefieldeffect==35 # Underwater or New World
            score*=0
          end
        end
    end
    return score
  end
end
