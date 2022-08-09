class PokeBattle_Battle
  alias __b__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    score = __b__pbGetMoveScoreFunctionCode(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                            score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      when 0x40 # Flatter
        if opponent != attacker.pbPartner
          if opponent.pbCanConfuse?(false)
            miniscore=100
            ministat=0
            ministat+=opponent.stages[PBStats::ATTACK]
            if ministat>0
              minimini=10*ministat
              minimini+=100
              minimini/=100.0
              miniscore*=minimini
            end
            if opponent.attack>opponent.spatk
              miniscore*=1.5
            else
              miniscore*=0.3
            end
            if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
              miniscore*=1.3
            end
            if opponent.effects[PBEffects::Attract]>=0
              miniscore*=1.1
            end
            if opponent.status==PBStatuses::PARALYSIS
              miniscore*=1.1
            end
            if opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
              miniscore*=0.4
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::TANGLEDFEET)
              miniscore*=0.7
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
              miniscore*=1.5
            end
            if attacker.pbHasMove?(:SUBSTITUTE)
              miniscore*=1.2
              if attacker.effects[PBEffects::Substitute]>0
                miniscore*=1.3
              end
            end
            miniscore/=100.0
            score*=miniscore
          else
            score=0
          end
        else
          if opponent.pbCanConfuse?(false)
            score*=0.5
          else
            score*=1.5
          end
          if opponent.attack<opponent.spatk
            score*=1.5
          end
          if (1.0/opponent.totalhp)*opponent.hp < 0.6
            score*=0.3
          end
          if opponent.effects[PBEffects::Attract]>=0 || opponent.status==PBStatuses::PARALYSIS ||
             opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
            score*=0.3
          end
          if oppitemworks && (opponent.item == PBItems::PERSIMBERRY || opponent.item == PBItems::LUMBERRY)
            score*=1.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
            score*=0
          end
          if opponent.effects[PBEffects::Substitute]>0
            score*=0
          end
          opp1 = attacker.pbOppositeOpposing
          opp2 = opp1.pbPartner
          if opponent.pbSpeed > opp1.pbSpeed && opponent.pbSpeed > opp2.pbSpeed
            score*=1.3
          else
            score*=0.7
          end
        end
      when 0x41 # Swagger
        if opponent != attacker.pbPartner
          if opponent.pbCanConfuse?(false)
            miniscore=100
            if opponent.attack<opponent.spatk
              miniscore*=1.5
            else
              miniscore*=0.7
            end
            if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
              miniscore*=1.3
            end
            if opponent.effects[PBEffects::Attract]>=0
              miniscore*=1.3
            end
            if opponent.status==PBStatuses::PARALYSIS
              miniscore*=1.3
            end
            if opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
              miniscore*=0.4
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::TANGLEDFEET)
              miniscore*=0.7
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
              miniscore*=1.5
            end
            if attacker.pbHasMove?(:SUBSTITUTE)
              miniscore*=1.2
              if attacker.effects[PBEffects::Substitute]>0
                miniscore*=1.3
              end
            end
            if attacker.pbHasMove?(:FOULPLAY)
              miniscore*=1.5
            end
            miniscore/=100.0
            score*=miniscore
          else
            score=0
          end
        else
          if opponent.pbCanConfuse?(false)
            score*=0.5
          else
            score*=1.5
          end
          if opponent.attack>opponent.spatk
            score*=1.5
          end
          if (1.0/opponent.totalhp)*opponent.hp < 0.6
            score*=0.3
          end
          if opponent.effects[PBEffects::Attract]>=0 || opponent.status==PBStatuses::PARALYSIS ||
             opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
            score*=0.3
          end
          if (oppitemworks && opponent.item == PBItems::PERSIMBERRY) ||
             (oppitemworks && opponent.item == PBItems::LUMBERRY)
            score*=1.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
            score*=0
          end
          if opponent.effects[PBEffects::Substitute]>0
            score*=0
          end
          opp1 = attacker.pbOppositeOpposing
          opp2 = opp1.pbPartner
          if opponent.pbSpeed > opp1.pbSpeed && opponent.pbSpeed > opp2.pbSpeed
            score*=1.3
          else
            score*=0.7
          end
          if opp1.pbHasMove?(:FOULPLAY) || opp2.pbHasMove?(:FOULPLAY)
            score*=0.3
          end
        end
      when 0x42 # Growl
        if (pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)) ||
           opponent.stages[PBStats::ATTACK]>0 || !opponent.pbCanReduceStatStage?(PBStats::ATTACK)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::LUNGE)
              if $fefieldeffect==13 # Icy Field
                miniscore*=1.5
              end
            end
            if move.id==(PBMoves::AURORABEAM)
              if $fefieldeffect==30 # Mirror Field
                if (attacker.stages[PBStats::ACCURACY] < 0 || opponent.stages[PBStats::EVASION] > 0 ||
                   (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
                   ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
                   ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL) ||
                   opponent.vanished) &&
                   !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) &&
                   !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD)
                  miniscore*=2
                end
              end
            end
          end
          miniscore *= unsetupminiscore(attacker,opponent,skill,move,roles,1,true)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x43 # Tail Whip
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        if !physmove || opponent.stages[PBStats::DEFENSE]>0 || !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          if move.basedamage==0
            score=0
          end
        else
          score*=unsetupminiscore(attacker,opponent,skill,move,roles,2,true)
        end
      when 0x44 # Rock Tomb / Bulldoze / Glaciate
        if ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)) ||
           opponent.stages[PBStats::SPEED]>0 || !opponent.pbCanReduceStatStage?(PBStats::SPEED)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if opponent.stages[PBStats::SPEED]<0
            minimini = 5*opponent.stages[PBStats::SPEED]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::GLACIATE)
              if $fefieldeffect==26 # Murkwater Surface
                poisonvar=false
                watervar=false
                icevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:POISON)
                    poisonvar=true
                  end
                  if mon.hasType?(:WATER)
                    watervar=true
                  end
                  if mon.hasType?(:ICE)
                    icevar=true
                  end
                end
                if !poisonvar && !watervar
                  miniscore*=1.3
                end
                if icevar
                  miniscore*=1.5
                end
              end
              if $fefieldeffect==21 # Water Surface
                watervar=false
                icevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:WATER)
                    watervar=true
                  end
                  if mon.hasType?(:ICE)
                    icevar=true
                  end
                end
                if !watervar
                  miniscore*=1.3
                end
                if icevar
                  miniscore*=1.5
                end
              end
              if $fefieldeffect==32 # Dragon's Den
                dragonvar=false
                rockvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:DRAGON)
                    dragonvar=true
                  end
                  if mon.hasType?(:ROCK)
                    rockvar=true
                  end
                end
                if !dragonvar
                  miniscore*=1.3
                end
                if rockvar
                  miniscore*=1.3
                end
              end
              if $fefieldeffect==16 # Superheated
                firevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                end
                if !firevar
                  miniscore*=1.5
                end
              end
            end
            if move.id==(PBMoves::BULLDOZE)
              if $fefieldeffect==4 # Dark Crystal Cavern
                darkvar=false
                rockvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:DARK)
                    darkvar=true
                  end
                  if mon.hasType?(:ROCK)
                    rockvar=true
                  end
                end
                if !darkvar
                  miniscore*=1.3
                end
                if rockvar
                  miniscore*=1.2
                end
              end
              if $fefieldeffect==25 # Crystal Cavern
                dragonvar=false
                rockvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:DRAGON)
                    dragonvar=true
                  end
                  if mon.hasType?(:ROCK)
                    rockvar=true
                  end
                end
                if !dragonvar
                  miniscore*=1.3
                end
                if rockvar
                  miniscore*=1.2
                end
              end
              if $fefieldeffect==13 # Icy Field
                icevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:ICE)
                    icevar=true
                  end
                end
                if !icevar
                  miniscore*=1.5
                end
              end
              if $fefieldeffect==17 # Factory
                miniscore*=1.2
                darkvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:DARK)
                    darkvar=true
                  end
                end
                if darkvar
                  miniscore*=1.3
                end
              end
              if $fefieldeffect==23 # Cave
                if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD) &&
                   !(!attacker.abilitynulled && attacker.ability == PBAbilities::BULLETPROOF)
                  miniscore*=0.7
                  if $fecounter >=1
                    miniscore *= 0.3
                  end
                end
              end
              if $fefieldeffect==30 # Mirror Arena
                if opponent.stages[PBStats::EVASION] > 0 ||
                  (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
                  ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
                  ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
                  miniscore*=1.3
                else
                  miniscore*=0.5
                end
              end
            end
          end
          greatmoves = hasgreatmoves(initialscores,scoreindex,skill)
          miniscore*=unsetupminiscore(attacker,opponent,skill,move,roles,3,false,greatmoves)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x45 # Snarl
        if (pbRoughStat(opponent,PBStats::SPATK,skill)<pbRoughStat(opponent,PBStats::ATTACK,skill)) ||
           opponent.stages[PBStats::SPATK]>0 || !opponent.pbCanReduceStatStage?(PBStats::SPATK)
          if move.basedamage==0
            score=0
          end
        else
          score*=unsetupminiscore(attacker,opponent,skill,move,roles,1,false)
        end
      when 0x46 # Psychic
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if !specmove || opponent.stages[PBStats::SPDEF]>0 || !opponent.pbCanReduceStatStage?(PBStats::SPDEF)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if opponent.stages[PBStats::SPDEF]<0
            minimini = 5*opponent.stages[PBStats::SPDEF]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::FLASHCANNON) || move.id==(PBMoves::LUSTERPURGE)
              if $fefieldeffect==30 # Mirror Arena
                if (attacker.stages[PBStats::ACCURACY] < 0 || opponent.stages[PBStats::EVASION] > 0 ||
                   (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
                   ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
                   ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL) ||
                   opponent.vanished) &&
                   !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) &&
                   !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD)
                  miniscore*=2
                end
              end
            end
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,2,false)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x47 # Sand Attack
        if checkAIaccuracy(aimem) || opponent.stages[PBStats::ACCURACY]>0 || !opponent.pbCanReduceStatStage?(PBStats::ACCURACY)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if opponent.stages[PBStats::ACCURACY]<0
            minimini = 5*opponent.stages[PBStats::ACCURACY]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::KINESIS)
              if $fefieldeffect==20 # Ashen Beach
                miniscore*=1.3
              end
              if $fefieldeffect==37 # Psychic Terrain
                miniscore*=1.6
              end
            end
            if move.id==(PBMoves::SANDATTACK)
              if $fefieldeffect==20 || $fefieldeffect==12 # Ashen Beach/Desert
                miniscore*=1.3
              end
            end
            if move.id==(PBMoves::MIRRORSHOT)
              if $fefieldeffect==30 # Mirror Arena
                if (attacker.stages[PBStats::ACCURACY] < 0 || opponent.stages[PBStats::EVASION] > 0 ||
                  (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
                  ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
                  ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL) ||
                  opponent.vanished) &&
                   !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) &&
                   !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD)
                  miniscore*=2
                end
              end
            end
            if move.id==(PBMoves::MUDDYWATER)
              if $fefieldeffect==7 # Burning
                firevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                end
                if firevar
                  miniscore*=0
                else
                  miniscore*=2
                end
              end
              if $fefieldeffect==16 # Superheated
                miniscore*=0.7
              end
              if $fefieldeffect==32 # Dragon's Den
                firevar=false
                dragonvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                  if mon.hasType?(:DRAGON)
                    dragonvar=true
                  end
                end
                if firevar || dragonvar
                  miniscore*=0
                else
                  miniscore*=1.5
                end
              end
            end
            if move.id==(PBMoves::NIGHTDAZE)
              if $fefieldeffect==25 # Crystal Cavern
                darkvar=false
                dragonvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:DARK)
                    darkvar=true
                  end
                  if mon.hasType?(:DRAGON)
                    dragonvar=true
                  end
                end
                if darkvar
                  miniscore*=2
                end
                if dragonvar
                  miniscore*=0.75
                end
              end
            end
            if move.id==(PBMoves::LEAFTORNADO)
              if $fefieldeffect==20 # Ahsen Beach
                miniscore*=0.7
              end
            end
            if move.id==(PBMoves::FLASH)
              if $fefieldeffect==4 || $fefieldeffect==18 || $fefieldeffect==30 ||
                 $fefieldeffect==34 || $fefieldeffect==35 # Dark Crystal Cavern/Short-Circuit/Mirror/Starlight/New World
                miniscore*=1.3
              end
            end
            if move.id==(PBMoves::SMOKESCREEN)
              if $fefieldeffect==7 || $fefieldeffect==11 # Burning/Corrosive Mist
                miniscore*=1.3
              end
            end
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,1,false)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x48 # Sweet Scent
        score=0 #no
      when 0x49 # Defog
        miniscore=100
        livecount1=0
        for i in pbParty(attacker.index)
          next if i.nil?
          livecount1+=1 if i.hp!=0
        end
        livecount2=0
        for i in pbParty(opponent.index)
          next if i.nil?
          livecount2+=1 if i.hp!=0
        end
        if livecount1>1
          miniscore*=2 if attacker.pbOwnSide.effects[PBEffects::StealthRock]
          miniscore*=3 if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
          miniscore*=(1.5**attacker.pbOwnSide.effects[PBEffects::Spikes])
          miniscore*=(1.7**attacker.pbOwnSide.effects[PBEffects::ToxicSpikes])
        end
        miniscore-=100
        miniscore*=(livecount1-1) if livecount1>1
        minimini=100
        if livecount2>1
          minimini*=0.5 if attacker.pbOwnSide.effects[PBEffects::StealthRock]
          minimini*=0.3 if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
          minimini*=(0.7**attacker.pbOwnSide.effects[PBEffects::Spikes])
          minimini*=(0.6**attacker.pbOwnSide.effects[PBEffects::ToxicSpikes])
        end
        minimini-=100
        minimini*=(livecount2-1) if livecount2>1
        miniscore+=minimini
        miniscore+=100
        if miniscore<0
          miniscore=0
        end
        miniscore/=100.0
        score*=miniscore
        if opponent.pbOwnSide.effects[PBEffects::Reflect]>0
          score*=2
        end
        if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0
          score*=2
        end
        if opponent.pbOwnSide.effects[PBEffects::Safeguard]>0
          score*=1.3
        end
        if opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          score*=3
        end
        if opponent.pbOwnSide.effects[PBEffects::Mist]>0
          score*=1.3
        end
      when 0x4A # Tickle
        miniscore=100
        if (pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)) ||
           opponent.stages[PBStats::ATTACK]>0 || !opponent.pbCanReduceStatStage?(PBStats::ATTACK)
          if move.basedamage==0
            miniscore*=0.5
          end
        else
          if opponent.stages[PBStats::ATTACK]+opponent.stages[PBStats::DEFENSE]<0
            minimini = 5*opponent.stages[PBStats::ATTACK]
            minimini+= 5*opponent.stages[PBStats::DEFENSE]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,1,true)
        end
        miniscore/=100.0
        score*=miniscore
        miniscore=100
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        if !physmove || opponent.stages[PBStats::DEFENSE]>0 || !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          if move.basedamage==0
            miniscore*=0.5
          end
        else
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,2,true)
        end
        miniscore/=100.0
        score*=miniscore
      when 0x4B # Feather Dance
        if (pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)) ||
           opponent.stages[PBStats::ATTACK]>1 || !opponent.pbCanReduceStatStage?(PBStats::ATTACK)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if opponent.stages[PBStats::ATTACK]<0
            minimini = 5*opponent.stages[PBStats::ATTACK]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==6 # Big Top
              miniscore*=1.5
            end
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,1,true)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x4C # Screech
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        if !physmove || opponent.stages[PBStats::DEFENSE]>1 || !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          if move.basedamage==0
            score=0
          end
        else
          if opponent.stages[PBStats::DEFENSE]<0
            minimini = 5*opponent.stages[PBStats::DEFENSE]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,2,true)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x4D # Scary Face
        if ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)) ||
           opponent.stages[PBStats::SPEED]>1 || !opponent.pbCanReduceStatStage?(PBStats::SPEED)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if opponent.stages[PBStats::SPEED]<0
            minimini = 5*opponent.stages[PBStats::SPEED]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          greatmoves = hasgreatmoves(initialscores,scoreindex,skill)
          miniscore*=unsetupminiscore(attacker,opponent,skill,move,roles,3,false,greatmoves)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x4E # Captivate
        canattract=true
        agender=attacker.gender
        ogender=opponent.gender
        if agender==2 || ogender==2 || agender==ogender # Pokemon are genderless or same gender
          canattract=false
        elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::OBLIVIOUS)
          canattract=false
        end
        if (pbRoughStat(opponent,PBStats::SPATK,skill)<pbRoughStat(opponent,PBStats::ATTACK,skill)) ||
           opponent.stages[PBStats::SPATK]>1 || !opponent.pbCanReduceStatStage?(PBStats::SPATK)
          if move.basedamage==0
            score=0
          end
        elsif !canattract
          score=0
        else
          miniscore=100
          if opponent.stages[PBStats::SPATK]<0
            minimini = 5*opponent.stages[PBStats::SPATK]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,1,false)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x4F # Acid Spray
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if !specmove || opponent.stages[PBStats::SPDEF]>1 || !opponent.pbCanReduceStatStage?(PBStats::SPDEF)
          if move.basedamage==0
            score=0
          end
        else
          miniscore=100
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::METALSOUND)
              if $fefieldeffect==17 || $fefieldeffect==18 # Factory/Short-Circuit
                miniscore*=1.5
              end
            end
            if move.id==(PBMoves::SEEDFLARE)
              if $fefieldeffect==10 # Corrosive
                poisonvar=false
                grassvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:POISON)
                    poisonvar=true
                  end
                  if mon.hasType?(:GRASS)
                    grassvar=true
                  end
                end
                if !poisonvar
                  miniscore*=1.5
                end
                if grassvar
                  miniscore*=1.5
                end
              end
            end
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,2,false)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x50 # Clear Smog
        if opponent.effects[PBEffects::Substitute]<=0
          miniscore = 5*statchangecounter(opponent,1,7)
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
            score*=1.1
          end
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==3 # Misty
              poisonvar=false
              fairyvar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:POISON)
                  poisonvar=true
                end
                if mon.hasType?(:FAIRY)
                  fairyvar=true
                end
              end
              if poisonvar
                score*=1.3
              end
              if !fairyvar
                score*=1.3
              end
            end
          end
        end
      when 0x51 # Haze
        miniscore = (-10)* statchangecounter(attacker,1,7)
        minimini = (10)* statchangecounter(opponent,1,7)
        if @doublebattle
          if attacker.pbPartner.hp>0
            miniscore+= (-10)* statchangecounter(attacker.pbPartner,1,7)
          end
          if opponent.pbPartner.hp>0
            minimini+= (10)* statchangecounter(opponent.pbPartner,1,7)
          end
        end
        if miniscore==0 && minimini==0
          score*=0
        else
          miniscore+=minimini
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST) ||
           checkAImoves(PBStuff::SETUPMOVE,aimem)
          score*=0.8
        end
      when 0x52 # Power Swap
        stages=0
        stages+=attacker.stages[PBStats::ATTACK]
        stages+=attacker.stages[PBStats::SPATK]
        miniscore = (-10)*stages
        if attacker.attack > attacker.spatk
          if attacker.stages[PBStats::ATTACK]!=0
            miniscore*=2
          end
        else
          if attacker.stages[PBStats::SPATK]!=0
            miniscore*=2
          end
        end
        stages=0
        stages+=opponent.stages[PBStats::ATTACK]
        stages+=opponent.stages[PBStats::SPATK]
        minimini = (10)*stages
        if opponent.attack > opponent.spatk
          if opponent.stages[PBStats::ATTACK]!=0
            minimini*=2
          end
        else
          if opponent.stages[PBStats::SPATK]!=0
            minimini*=2
          end
        end
        if miniscore==0 && minimini==0
          score*=0
        else
          miniscore+=minimini
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          if @doublebattle
            score*=0.8
          end
        end
      when 0x53 # Guard Swap
        stages=0
        stages+=attacker.stages[PBStats::DEFENSE]
        stages+=attacker.stages[PBStats::SPDEF]
        miniscore = (-10)*stages
        if attacker.defense > attacker.spdef
          if attacker.stages[PBStats::DEFENSE]!=0
            miniscore*=2
          end
        else
          if attacker.stages[PBStats::SPDEF]!=0
            miniscore*=2
          end
        end
        stages=0
        stages+=opponent.stages[PBStats::DEFENSE]
        stages+=opponent.stages[PBStats::SPDEF]
        minimini = (10)*stages
        if opponent.defense > opponent.spdef
          if opponent.stages[PBStats::DEFENSE]!=0
            minimini*=2
          end
        else
          if opponent.stages[PBStats::SPDEF]!=0
            minimini*=2
          end
        end
        if miniscore==0 && minimini==0
          score*=0
        else
          miniscore+=minimini
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          if @doublebattle
            score*=0.8
          end
        end
      when 0x54 # Heart Swap
        stages=0
        stages+=attacker.stages[PBStats::ATTACK] unless attacker.attack<attacker.spatk
        stages+=attacker.stages[PBStats::DEFENSE] unless opponent.attack<opponent.spatk
        stages+=attacker.stages[PBStats::SPEED]
        stages+=attacker.stages[PBStats::SPATK] unless attacker.attack>attacker.spatk
        stages+=attacker.stages[PBStats::SPDEF] unless opponent.attack>opponent.spatk
        stages+=attacker.stages[PBStats::EVASION]
        stages+=attacker.stages[PBStats::ACCURACY]
        miniscore = (-10)*stages
        stages=0
        stages+=opponent.stages[PBStats::ATTACK] unless opponent.attack<opponent.spatk
        stages+=opponent.stages[PBStats::DEFENSE] unless attacker.attack<attacker.spatk
        stages+=opponent.stages[PBStats::SPEED]
        stages+=opponent.stages[PBStats::SPATK] unless opponent.attack>opponent.spatk
        stages+=opponent.stages[PBStats::SPDEF] unless attacker.attack>attacker.spatk
        stages+=opponent.stages[PBStats::EVASION]
        stages+=opponent.stages[PBStats::ACCURACY]
        minimini = (10)*stages
        if !(miniscore==0 && minimini==0)
          miniscore+=minimini
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          if @doublebattle
            score*=0.8
          end
        else
          if $fefieldeffect==35 # New World
            score=25
          else
            score=0
          end
        end
        if $fefieldeffect==35 # New World
          ministat = opponent.hp + attacker.hp*0.5
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>ministat
            score*=0.5
          else
            if maxdam>attacker.hp
              if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
                score*=2
              else
                score*=0*5
              end
            else
              miniscore = opponent.hp * (1.0/attacker.hp)
              score*=miniscore
            end
          end
        end
      when 0x55 # Psych Up
        stages=0
        stages+=attacker.stages[PBStats::ATTACK] unless attacker.attack<attacker.spatk
        stages+=attacker.stages[PBStats::DEFENSE] unless opponent.attack<opponent.spatk
        stages+=attacker.stages[PBStats::SPEED]
        stages+=attacker.stages[PBStats::SPATK] unless attacker.attack>attacker.spatk
        stages+=attacker.stages[PBStats::SPDEF] unless opponent.attack>opponent.spatk
        stages+=attacker.stages[PBStats::EVASION]
        stages+=attacker.stages[PBStats::ACCURACY]
        miniscore = (-10)*stages
        stages=0
        stages+=opponent.stages[PBStats::ATTACK] unless attacker.attack<attacker.spatk
        stages+=opponent.stages[PBStats::DEFENSE] unless opponent.attack<opponent.spatk
        stages+=opponent.stages[PBStats::SPEED]
        stages+=opponent.stages[PBStats::SPATK] unless attacker.attack>attacker.spatk
        stages+=opponent.stages[PBStats::SPDEF] unless opponent.attack>opponent.spatk
        stages+=opponent.stages[PBStats::EVASION]
        stages+=opponent.stages[PBStats::ACCURACY]
        minimini = (10)*stages
        if !(miniscore==0 && minimini==0)
          miniscore+=minimini
          miniscore+=100
          miniscore/=100
          score*=miniscore
        else
          if $fefieldeffect==37 # Psychic Terrain
            score=35
          else
            score=0
          end
        end
        if $fefieldeffect==37 # Psychic Terrain
          miniscore=100
          if initialscores.length>0
            miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
          end
          if attacker.hp*(1.0/attacker.totalhp)>=0.75
            miniscore*=1.2
          end
          if opponent.effects[PBEffects::HyperBeam]>0
            miniscore*=1.3
          end
          if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
            miniscore*=1.3
          end
          if opponent.effects[PBEffects::Encore]>0
            if opponent.moves[(opponent.effects[PBEffects::EncoreIndex])].basedamage==0
              miniscore*=1.5
            end
          end
          if attacker.effects[PBEffects::Confusion]>0
            miniscore*=0.5
          end
          if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
            miniscore*=0.5
          end
          if skill>=PBTrainerAI.bestSkill
            miniscore*=1.3 if checkAIhealing(aimem)
            miniscore*=0.6 if checkAIpriority(aimem)
          end
          if roles.include?(PBMonRoles::SWEEPER)
            miniscore*=1.3
          end
          specialvar = false
          for i in attacker.moves
            if i.pbIsSpecial?(i.type)
              special=true
            end
          end
          if attacker.stages[PBStats::SPATK]!=6 && specialvar
            score*=miniscore
          else
            score=0
          end
        end
      when 0x56 # Mist
        miniscore = 1
        minimini = 1
        if attacker.pbOwnSide.effects[PBEffects::Mist]==0
          minimini*=1.1
          movecheck=false
          # check opponent for stat decreasing moves
          if aimem.length > 0
            for j in aimem
              movecheck=true if (j.function==0x42 || j.function==0x43 || j.function==0x44 ||
                                j.function==0x45 || j.function==0x46 || j.function==0x47 ||
                                j.function==0x48 || j.function==0x49 || j.function==0x4A ||
                                j.function==0x4B || j.function==0x4C || j.function==0x4D ||
                                j.function==0x4E || j.function==0x4F || j.function==0xE2 ||
                                j.function==0x138 || j.function==0x13B || j.function==0x13F)
            end
          end
          if movecheck
            minimini*=1.3
          end
        end
        if $fefieldeffect!=3 && $fefieldeffect!=22 && $fefieldeffect!=35# (not) Misty Terrain
          miniscore*=getFieldDisruptScore(attacker,opponent,skill)
          fairyvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:FAIRY)
              fairyvar=true
            end
          end
          if fairyvar
            miniscore*=1.3
          end
          if opponent.pbHasType?(:DRAGON) && !attacker.pbHasType?(:FAIRY)
            miniscore*=1.3
          end
          if attacker.pbHasType?(:DRAGON)
            miniscore*=0.5
          end
          if opponent.pbHasType?(:FAIRY)
            miniscore*=0.5
          end
          if attacker.pbHasType?(:FAIRY) && opponent.spatk>opponent.attack
            miniscore*=1.5
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
        end
        score*=miniscore
        score*=minimini
        if miniscore<=1 && minimini<=1
          score*=0
        end
      when 0x57 # Power Trick
        if attacker.attack - attacker.defense >= 100
          if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) ||
             (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom!=0)
            score*=1.5
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            score*=2
          end
          healmove=false
          for j in attacker.moves
            if j.isHealingMove?
              healmove=true
            end
          end
          if healmove
            score*=2
          end
        elsif attacker.defense - attacker.attack >= 100
          if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) ||
             (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom!=0)
            score*=1.5
            if attacker.hp==attacker.totalhp &&
               (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
               ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
               (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
               (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
              score*=2
            end
          else
            score*=0
          end
        else
          score*=0.1
        end
        if attacker.effects[PBEffects::PowerTrick]
          score*=0.1
        end
      when 0x58 # Power Split
        if  pbRoughStat(opponent,PBStats::ATTACK,skill)> pbRoughStat(opponent,PBStats::SPATK,skill)
          if attacker.attack > pbRoughStat(opponent,PBStats::ATTACK,skill)
            score*=0
          else
            miniscore = pbRoughStat(opponent,PBStats::ATTACK,skill) - attacker.attack
            miniscore+=100
            miniscore/=100
            if attacker.attack>attacker.spatk
              miniscore*=2
            else
              miniscore*=0.5
            end
            score*=miniscore
          end
        else
          if attacker.spatk > pbRoughStat(opponent,PBStats::SPATK,skill)
            score*=0
          else
            miniscore = pbRoughStat(opponent,PBStats::SPATK,skill) - attacker.spatk
            miniscore+=100
            miniscore/=100
            if attacker.attack<attacker.spatk
              miniscore*=2
            else
              miniscore*=0.5
            end
            score*=miniscore
          end
        end
      when 0x59 # Guard Split
        if  pbRoughStat(opponent,PBStats::ATTACK,skill)> pbRoughStat(opponent,PBStats::SPATK,skill)
          if attacker.defense > pbRoughStat(opponent,PBStats::DEFENSE,skill)
            score*=0
          else
            miniscore = pbRoughStat(opponent,PBStats::DEFENSE,skill) - attacker.defense
            miniscore+=100
            miniscore/=100
            if attacker.attack>attacker.spatk
              miniscore*=2
            else
              miniscore*=0.5
            end
            score*=miniscore
          end
        else
          if attacker.spdef > pbRoughStat(opponent,PBStats::SPDEF,skill)
            score*=0
          else
            miniscore = pbRoughStat(opponent,PBStats::SPDEF,skill) - attacker.spdef
            miniscore+=100
            miniscore/=100
            if attacker.attack<attacker.spatk
              miniscore*=2
            else
              miniscore*=0.5
            end
            score*=miniscore
          end
        end
      when 0x5A # Pain Split
        if opponent.effects[PBEffects::Substitute]<=0
          ministat = opponent.hp + (attacker.hp/2.0)
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam>ministat
            score*=0
          elsif maxdam>attacker.hp
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            else
              score*=0
            end
          else
            miniscore=(opponent.hp/(attacker.hp).to_f)
            score*=miniscore
          end
        else
          score*=0
        end
      when 0x5B # Tailwind
        if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
          score = 0
        else
          score*=1.5
          if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && !roles.include?(PBMonRoles::LEAD)
            score*=0.9
            livecount=0
            for i in pbParty(attacker.index)
              next if i.nil?
              livecount+=1 if i.hp!=0
            end
            if livecount==1
                score*=0.4
            end
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
            score*=0.5
          end
          score*=0.1 if @trickroom!=0 || checkAImoves([PBMoves::TRICKROOM],aimem)
          if roles.include?(PBMonRoles::LEAD)
            score*=1.4
          end
          if @opponent.is_a?(Array) == false
            if @opponent.trainertype==PBTrainers::ADRIENN
              score *= 2.5
            end
          end
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==3 # Misty
              fairyvar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:FAIRY)
                  fairyvar=true
                end
              end
              if !fairyvar
                score*=1.5
              end
              if !@opponent.is_a?(Array)
                if @opponent.trainertype==PBTrainers::ADRIENN
                  score*=2
                end
              end
            end
            if $fefieldeffect==7 # Burning
              firevar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:FIRE)
                  firevar=true
                end
                if !firevar
                  score*=1.2
                end
              end
            end
            if $fefieldeffect==11 # Corromist
              poisonvar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:POISON)
                  poisonvar=true
                end
                if !poisonvar
                  score*=1.2
                end
              end
            end
            if $fefieldeffect==27 || $fefieldeffect==28 # Mountain/Snowy Mountain
              score*=1.5
              for mon in pbParty(attacker.index)
                flyingvar=false
                next if mon.nil?
                if mon.hasType?(:FLYING)
                  flyingvar=true
                end
                if flyingvar
                  score*=1.5
                end
              end
            end
          end
        end
      when 0x5C # Mimic
        blacklist=[
          0x02,   # Struggle
          0x14,   # Chatter
          0x5C,   # Mimic
          0x5D,   # Sketch
          0xB6    # Metronome
        ]
        miniscore = $pkmn_move[opponent.lastMoveUsed][1]
        if miniscore=0
          miniscore=40
        end
        miniscore+=100
        miniscore/=100.0
        if miniscore<=1.5
          miniscore*=0.5
        end
        score*=miniscore
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if blacklist.include?($pkmn_move[opponent.lastMoveUsed][1]) || opponent.lastMoveUsed<0
            score*=0
          end
        else
          score*=0.5
        end
        if opponent.effects[PBEffects::Substitute] > 0
          score*=0
        end
      when 0x5D # Sketch
        blacklist=[
          0x02,   # Struggle
          0x14,   # Chatter
          0x5D,   # Sketch
        ]
        miniscore = $pkmn_move[opponent.lastMoveUsedSketch][1]
        if miniscore=0
          miniscore=40
        end
        miniscore+=100
        miniscore/=100.0
        if miniscore<=1.5
          miniscore*=0.5
        end
        score*=miniscore
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if blacklist.include?($pkmn_move[opponent.lastMoveUsedSketch][0]) || opponent.lastMoveUsedSketch<0
            score*=0
          end
        else
          score*=0.5
        end
        if opponent.effects[PBEffects::Substitute]>0
          score*= 0
        end
      when 0x5E # Conversion
        miniscore = [PBTypes.getCombinedEffectiveness(opponent.type1,attacker.type1,attacker.type2),
                     PBTypes.getCombinedEffectiveness(opponent.type2,attacker.type1,attacker.type2)].max
        minimini = [PBTypes.getEffectiveness(opponent.type1,attacker.moves[0].type),
                    PBTypes.getEffectiveness(opponent.type2,attacker.moves[0].type)].max
        if minimini < miniscore
          score*=3
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.2
          else
            score*=0.5
          end
          stabvar = false
          for i in attacker.moves
            if i.type==attacker.type1 || i.type==attacker.type2
              stabvar = true
            end
          end
          if !stabvar
            score*=1.3
          end
          if $feconversionuse==1
            score*=0.3
          end
        else
          score*=0
        end
        if $fefieldeffect!=24 && $fefieldeffect!=22 && $fefieldeffect!=35
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if $feconversionuse!=2
            miniscore-=1
            miniscore/=2.0
            miniscore+=1
          end
          score*=miniscore
        end
        if (attacker.moves[0].type == attacker.type1 && attacker.moves[0].type == attacker.type2)
          score = 0
        end
      when 0x5F # Conversion 2
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.2
        else
          score*=0.7
        end
        stabvar = false
        for i in attacker.moves
          if i.type==attacker.type1 || i.type==attacker.type2
            stabvar = true
          end
        end
        if stabvar
          score*=1.3
        else
          score*=0.7
        end
        if $feconversionuse==2
          score*=0.3
        end
        if $fefieldeffect!=24 && $fefieldeffect!=22 && $fefieldeffect!=35
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if $feconversionuse!=1
            miniscore-=1
            miniscore/=2.0
            miniscore+=1
          end
          score*=miniscore
        end
      when 0x60 # Camouflage
        type = 0
        case $fefieldeffect
          when 25
            type = PBTypes::QMARKS #type is random
          when 35
            type = PBTypes::QMARKS
          else
            camotypes = FieldEffects::MIMICRY
            type = camotypes[$fefieldeffect]
        end
        miniscore = [PBTypes.getCombinedEffectiveness(opponent.type1,attacker.type1,attacker.type2),
                     PBTypes.getCombinedEffectiveness(opponent.type2,attacker.type1,attacker.type2)].max
        minimini = [PBTypes.getEffectiveness(opponent.type1,type),
                    PBTypes.getEffectiveness(opponent.type2,type)].max
        if minimini < miniscore
          score*=2
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.2
          else
            score*=0.7
          end
          stabvar = false
          for i in attacker.moves
            if i.type==attacker.type1 || i.type==attacker.type2
              stabvar = true
            end
          end
          if !stabvar
            score*=1.2
          else
            score*=0.6
          end
        else
          score*=0
        end
      when 0x61 # Soak
        sevar = false
        for i in attacker.moves
          if (i.type == PBTypes::ELECTRIC) || (i.type == PBTypes::GRASS)
            sevar = true
          end
        end
        if sevar
          score*=1.5
        else
          score*=0.7
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          if attacker.pbHasMove?(:TOXIC)
            if attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:POISON)
              score*=1.5
            end
          end
        end
        if aimem.length > 0
          movecheck=false
          for j in aimem
            movecheck=true if (j.type == PBTypes::WATER)
          end
          if movecheck
            score*=0.5
          else
            score*=1.1
          end
        end
        if opponent.type1==(PBTypes::WATER) && opponent.type1==(PBTypes::WATER)
          score=0
        end
      when 0x62 # Reflect Type
        typeid=getID(PBTypes,type)
        miniscore = [PBTypes.getCombinedEffectiveness(opponent.type1,attacker.type1,attacker.type2),
                     PBTypes.getCombinedEffectiveness(opponent.type2,attacker.type1,attacker.type2)].max
        minimini = [PBTypes.getCombinedEffectiveness(opponent.type1,opponent.type1,opponent.type2),
                    PBTypes.getCombinedEffectiveness(opponent.type2,opponent.type1,opponent.type2)].max
        if minimini < miniscore
          score*=3
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.2
          else
            score*=0.7
          end
          stabvar = false
          oppstab = false
          for i in attacker.moves
            if i.type == attacker.type1 || i.type == attacker.type2
              stabvar = true
            end
            if i.type == opponent.type1 || i.type == opponent.type2
              oppstab = true
            end
          end
          if !stabvar
            score*=1.2
          end
          if oppstab
            score*=1.3
          end
        else
          score*=0
        end
        if (attacker.ability == PBAbilities::MULTITYPE) ||
           (attacker.type1 == opponent.type1 && attacker.type2 == opponent.type2) ||
           (attacker.type1 == opponent.type2 && attacker.type2 == opponent.type1)
          score*=0
        end
      when 0x63 # Simple Beam
        score = 0 if opponent.unstoppableAbility? ||
                     isConst?(opponent.ability, PBAbilities, :TRUANT) ||
                     isConst?(opponent.ability, PBAbilities, :SIMPLE)
        if score > 0
          miniscore = getAbilityDisruptScore(move,attacker,opponent,skill)
          if opponent == attacker.pbPartner
            if miniscore < 2
              miniscore = 2 - miniscore
            else
              miniscore = 0
            end
          end
          score*=miniscore
          if checkAImoves(PBStuff::SETUPMOVE,aimem)
            if opponent==attacker.pbPartner
              score*=1.3
            else
              score*=0.5
            end
          end
        end
      when 0x64 # Worry Seed
        score = 0 if opponent.unstoppableAbility? ||
                     isConst?(opponent.ability, PBAbilities, :TRUANT) ||
                     isConst?(opponent.ability, PBAbilities, :INSOMNIA)
        score = 0 if opponent.effects[PBEffects::Substitute] > 0
        if score > 0
          miniscore = getAbilityDisruptScore(move,attacker,opponent,skill)
          score*=miniscore
          if checkAImoves([PBMoves::SNORE,PBMoves::SLEEPTALK],aimem)
            score*=1.3
          end
          if checkAImoves([PBMoves::REST],aimem)
            score*=2
          end
          if attacker.pbHasMove?(:SPORE) ||
             attacker.pbHasMove?(:SLEEPPOWDER) ||
             attacker.pbHasMove?(:HYPNOSIS) ||
             attacker.pbHasMove?(:SING) ||
             attacker.pbHasMove?(:GRASSWHISTLE) ||
             attacker.pbHasMove?(:DREAMEATER) ||
             attacker.pbHasMove?(:NIGHTMARE) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::BADDREAMS)
            score*=0.3
          end
        end
      when 0x65 # Role Play
        score = 0 if opponent.ungainableAbility? ||
                     isConst?(opponent.ability, PBAbilities, :POWEROFALCHEMY) ||
                     isConst?(opponent.ability, PBAbilities, :RECEIVER) ||
                     isConst?(opponent.ability, PBAbilities, :TRACE) ||
                     isConst?(opponent.ability, PBAbilities, :WONDERGUARD)
        score = 0 if attacker.unstoppableAbility?
        score = 0 if opponent.ability == 0 || attacker.ability == opponent.ability
        if score != 0
          miniscore = getAbilityDisruptScore(move,opponent,attacker,skill)
          minimini = getAbilityDisruptScore(move,attacker,opponent,skill)
          score *= (1 + (minimini-miniscore))
        end
      when 0x66 # Entrainment
        score = 0 if attacker.ungainableAbility? ||
                     isConst?(attacker.ability, PBAbilities, :POWEROFALCHEMY) ||
                     isConst?(attacker.ability, PBAbilities, :RECEIVER) ||
                     isConst?(attacker.ability, PBAbilities, :TRACE)
        score = 0 if opponent.unstoppableAbility? ||
                     isConst?(opponent.ability, PBAbilities, :TRUANT)
        score = 0 if attacker.ability == 0 || attacker.ability == opponent.ability
        if score > 0
          miniscore = getAbilityDisruptScore(move,opponent,attacker,skill)
          minimini = getAbilityDisruptScore(move,attacker,opponent,skill)
          if opponent != attacker.pbPartner
            score *= (1 + (minimini-miniscore))
            if (attacker.ability == PBAbilities::TRUANT)
              score*=3
            elsif (attacker.ability == PBAbilities::WONDERGUARD)
              score=0
            end
          else
            score *= (1 + (miniscore-minimini))
            if (attacker.ability == PBAbilities::WONDERGUARD)
              score +=85
            elsif (attacker.ability == PBAbilities::SPEEDBOOST)
              score +=25
            elsif (opponent.ability == PBAbilities::DEFEATIST)
              score +=30
            elsif (opponent.ability == PBAbilities::SLOWSTART)
              score +=50
            end
          end
        end
      when 0x67 # Skill Swap
        score = 0 if attacker.unstoppableAbility? || opponent.unstoppableAbility?
        score = 0 if attacker.ungainableAbility? || isConst?(attacker.ability, PBAbilities, :WONDERGUARD)
        score = 0 if opponent.ungainableAbility? || isConst?(opponent.ability, PBAbilities, :WONDERGUARD)
        score = 0 if attacker.ability == 0 || opponent.ability == 0 ||
                     (attacker.ability == opponent.ability && !NEWEST_BATTLE_MECHANICS)
        if score > 0
          miniscore = getAbilityDisruptScore(move,opponent,attacker,skill)
          minimini = getAbilityDisruptScore(move,attacker,opponent,skill)
          if opponent == attacker.pbPartner
            if minimini < 2
              minimini = 2 - minimini
            else
              minimini = 0
            end
          end
          score *= (1 + (minimini-miniscore)*2)
          if (attacker.ability == PBAbilities::TRUANT) && opponent!=attacker.pbPartner
            score*=2
          end
          if (opponent.ability == PBAbilities::TRUANT) && opponent==attacker.pbPartner
            score*=2
          end
        end
      when 0x68 # Gastro Acid
        score = 0 if opponent.effects[PBEffects::GastroAcid] ||
                     opponent.effects[PBEffects::Substitute] > 0
        score = 0 if opponent.unstoppableAbility?
        if score > 0
          miniscore = getAbilityDisruptScore(move,attacker,opponent,skill)
          score*=miniscore
        end
      when 0x69 # Transform
        if !(attacker.effects[PBEffects::Transform] ||
           attacker.effects[PBEffects::Illusion] ||
           attacker.effects[PBEffects::Substitute]>0)
          miniscore = opponent.level
          miniscore -= attacker.level
          miniscore*=5
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          miniscore=(10)*statchangecounter(opponent,1,5)
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
          miniscore=(-10)*statchangecounter(attacker,1,5)
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        else
          score=0
        end
      when 0x6A # Sonicboom
      when 0x6B # Dragon Rage
      when 0x6C # Super Fang
      when 0x6D # Seismic Toss
      when 0x6E # Endeavor
        if attacker.hp > opponent.hp
          score=0
        else
          privar = false
          for i in attacker.moves
            if i.priority>0
              privar=true
            end
          end
          if privar
            score*=1.5
          end
          if ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH)) && attacker.hp == attacker.totalhp
            score*=1.5
          end
          if pbWeather==PBWeather::SANDSTORM && (!opponent.pbHasType?(:ROCK) && !opponent.pbHasType?(:GROUND) && !opponent.pbHasType?(:STEEL))
            score*=1.5
          end
          if opponent.level - attacker.level > 9
            score*=2
          end
        end
      when 0x6F # Psywave
      when 0x70 # Fissure
        if !(opponent.level>attacker.level) &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY)
          if opponent.effects[PBEffects::LockOn]>0
            score*=3.5
          else
            score*=0.7
          end
        else
          score*=0
        end
        if move.id==(PBMoves::FISSURE)
          if $fefieldeffect==17 # Factory
            score*=1.2
            darkvar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:DARK)
                darkvar=true
              end
            end
            if darkvar
              score*=1.5
            end
          end
        end
      when 0x71 # Counter
        maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.5
        end
        if ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
           (attitemworks && attacker.item == PBItems::FOCUSSASH)) && attacker.hp == attacker.totalhp
          score*=1.2
        else
          score*=0.8
          if maxdam>attacker.hp
            score*=0.8
          end
        end
        if $pkmn_move[attacker.lastMoveUsed][0]==0x71
          score*=0.7
        end
        score*=0.6 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        miniscore = attacker.hp*(1.0/attacker.totalhp)
        score*=miniscore
        if opponent.spatk>opponent.attack
          score*=0.3
        end
        score*=0.05 if checkAIbest(aimem,3,[],false,attacker,opponent,skill)
        if $pkmn_move[attacker.lastMoveUsed][0]==0x72
          score*=1.1
        end
      when 0x72 # Mirror Coat
        maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.5
        end
        if ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
           (attitemworks && attacker.item == PBItems::FOCUSSASH)) && attacker.hp == attacker.totalhp
          score*=1.2
        else
          score*=0.8
          if maxdam>attacker.hp
            score*=0.8
          end
        end
        if $pkmn_move[attacker.lastMoveUsed][0]==0x72
          score*=0.7
        end
        score*=0.6 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        miniscore = attacker.hp*(1.0/attacker.totalhp)
        score*=miniscore
        if opponent.spatk<opponent.attack
          score*=0.3
        end
        score*=0.05 if checkAIbest(aimem,2,[],false,attacker,opponent,skill)
        if $pkmn_move[attacker.lastMoveUsed][0]==0x71
          score*=1.1
        end
      when 0x73 # Metal Burst
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.01
        end
        if ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
           (attitemworks && attacker.item == PBItems::FOCUSSASH)) && attacker.hp == attacker.totalhp
          score*=1.2
        else
          score*=0.8 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        if $pkmn_move[attacker.lastMoveUsed][0]==0x73
          score*=0.7
        end
        movecheck=false
        score*=0.6 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        miniscore = attacker.hp*(1.0/attacker.totalhp)
        score*=miniscore
      when 0x74 # Flame Burst
        if @doublebattle && opponent.pbPartner.hp>0
          score*=1.1
        end
        roastvar=false
        firevar=false
        poisvar=false
        icevar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:GRASS) || mon.hasType?(:BUG)
            roastvar=true
          end
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:POISON)
            poisvar=true
          end
          if mon.hasType?(:ICE)
            icevar=true
          end
        end
        if $fefieldeffect==2 || $fefieldeffect==15 || ($fefieldeffect==33 && $fecounter>1)
          if firevar && !roastvar
            score*=2
          end
        end
        if $fefieldeffect==16
          if firevar
            score*=2
          end
        end
        if $fefieldeffect==11
          if !poisvar
            score*=1.2
          end
          if attacker.hp*(1.0/attacker.totalhp)<0.2
            score*=2
          end
          if pbPokemonCount(pbParty(opponent.index))==1
            score*=5
          end
        end
        if $fefieldeffect==13 || $fefieldeffect==28
          if !icevar
            score*=1.5
          end
        end
      when 0x75 # Surf
        firevar=false
        dragvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:DRAGON)
            dragvar=true
          end
        end
        if $fefieldeffect==7
          if firevar
            score=0
          else
            score*=2
          end
        end
        if $fefieldeffect==16
          score*=0.7
        end
        if $fefieldeffect==32
          if dragvar || firevar
            score=0
          else
            score*=1.5
          end
        end
      when 0x76 # Earthquake
        darkvar=false
        rockvar=false
        dragvar=false
        icevar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:DARK)
            darkvar=true
          end
          if mon.hasType?(:ROCK)
            rockvar=true
          end
          if mon.hasType?(:DRAGON)
            dragvar=true
          end
          if mon.hasType?(:ICE)
            icevar=true
          end
        end
        if $fefieldeffect==4
          if !darkvar
            score*=1.3
            if rockvar
              score*=1.2
            end
          end
        end
        if $fefieldeffect==25
          if !dragonvar
            score*=1.3
            if rockvar
              score*=1.2
            end
          end
        end
        if $fefieldeffect==13
          if !icevar
            score*=1.5
          end
        end
        if $fefieldeffect==17
          score*=1.2
          if darkvar
            score*=1.3
          end
        end
        if $fefieldeffect==23
          if !(!attacker.abilitynulled && attacker.ability == PBAbilities::ROCKHEAD) &&
             !(!attacker.abilitynulled && attacker.ability == PBAbilities::BULLETPROOF)
            score*=0.7
            if $fecounter >=1
              score *= 0.3
            end
          end
        end
        if $fefieldeffect==30
          if (opponent.stages[PBStats::EVASION] > 0 ||
             (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) ||
             (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
             ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
             ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL))
            score*=1.3
          else
            score*=0.5
          end
        end
      when 0x77 # Gust
        fairvar=false
        firevar=false
        poisvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FAIRY)
            fairvar=true
          end
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:POISON)
            poisvar=true
          end
        end
        if $fefieldeffect==3
          score*=1.3
          if !fairyvar
            score*=1.3
          else
            score*=0.6
          end
        end
        if $fefieldeffect==7
          if !firevar
            score*=1.8
          else
            score*=0.5
          end
        end
        if $fefieldeffect==11
          if !poisvar
            score*=3
          else
            score*=0.8
          end
        end
      when 0x78 # Twister
        if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
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
            end
            miniscore+=100
            if move.addlEffect.to_f != 100
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore/=100.0
            score*=miniscore
          end
        end
        fairvar=false
        firevar=false
        poisvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FAIRY)
            fairvar=true
          end
          if mon.hasType?(:FIRE)
            firevar=true
          end
          if mon.hasType?(:POISON)
            poisvar=true
          end
        end
        if $fefieldeffect==3
          score*=1.3
          if !fairyvar
            score*=1.3
          else
            score*=0.6
          end
        end
        if $fefieldeffect==7
          if !firevar
            score*=1.8
          else
            score*=0.5
          end
        end
        if $fefieldeffect==11
          if !poisvar
            score*=3
          else
            score*=0.8
          end
        end
        if $fefieldeffect==20
          score*=0.7
        end
      when 0x79 # Fusion Bolt
      when 0x7A # Fusion Flare
      when 0x7B # Venoshock
      when 0x7C # Smelling Salts
        if opponent.status==PBStatuses::PARALYSIS  && opponent.effects[PBEffects::Substitute]<=0
          score*=0.8
          if opponent.speed>attacker.speed && opponent.speed/2.0<attacker.speed
            score*=0.5
          end
        end
      when 0x7D # Wake-Up Slap
        if opponent.status==PBStatuses::SLEEP && opponent.effects[PBEffects::Substitute]<=0
          score*=0.8
          if (!attacker.abilitynulled &&
             attacker.ability == PBAbilities::BADDREAMS) ||
             attacker.pbHasMove?(:DREAMEATER) ||
             attacker.pbHasMove?(:NIGHTMARE)
            score*=0.3
          end
          if opponent.pbHasMove?(:SNORE) ||
            opponent.pbHasMove?(:SLEEPTALK)
            score*=1.3
          end
        end
      when 0x7E # Facade
      when 0x7F # Hex
    end
    return score
  end
end
