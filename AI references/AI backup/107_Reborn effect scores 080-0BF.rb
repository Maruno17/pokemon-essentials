class PokeBattle_Battle
  alias __c__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    score = __c__pbGetMoveScoreFunctionCode(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                            score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      when 0x80 # Brine
      when 0x81 # Revenge
        if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
          score*=0.5
        else
          score*=1.5
        end
        if attacker.hp==attacker.totalhp
          score*=1.2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) ||
             (attitemworks && attacker.item == PBItems::FOCUSSASH)
            score*=1.1
          end
        else
          score*=0.3 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        score*=0.8 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        #miniscore=attacker.hp*(1.0/attacker.totalhp)
        #score*=miniscore
      when 0x82 # Assurance
        if (pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed) ^ (@trickroom!=0)
          score*=1.5
        end
      when 0x83 # Round
        if @doublebattle && attacker.pbPartner.pbHasMove?(:ROUND)
          score*=1.5
        end
      when 0x84 # Payback
        if (pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed) ^ (@trickroom!=0)
          score*=2
        end
      when 0x85 # Retaliate
      when 0x86 # Acrobatics
      when 0x87 # Weather Ball
      when 0x88 # Pursuit
        miniscore=(-10)*statchangecounter(opponent,1,7,-1)
        miniscore+=100
        miniscore/=100.0
        score*=miniscore
        if opponent.effects[PBEffects::Confusion]>0
          score*=1.2
        end
        if opponent.effects[PBEffects::LeechSeed]>=0
          score*=1.5
        end
        if opponent.effects[PBEffects::Attract]>=0
          score*=1.3
        end
        if opponent.effects[PBEffects::Substitute]>0
          score*=0.7
        end
        if opponent.effects[PBEffects::Yawn]>0
          score*=1.5
        end
        if pbTypeModNoMessages(bettertype,attacker,opponent,move,skill)>4
          score*=1.5
        end
      when 0x89 # Return
      when 0x8A # Frustration
      when 0x8B # Water Spout
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.5
        end
        if skill>=PBTrainerAI.bestSkill
          if move.id==(PBMoves::WATERSPOUT)
            if $fefieldeffect==7 # Burning
              firevar=false
              watervar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:FIRE)
                  firevar=true
                end
                if mon.hasType?(:WATER)
                  watervar=true
                end
                if !firevar
                  score*=1.5
                end
                if watervar
                  score*=1.5
                end
              end
            end
            if $fefieldeffect==16 # Superheated
              score*=0.7
            end
          end
          if move.id==(PBMoves::ERUPTION)
            if $fefieldeffect==2 # Grassy
              if pbWeather!=PBWeather::RAINDANCE && @field.effects[PBEffects::WaterSport]==0
                firevar=false
                grassvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                  if mon.hasType?(:GRASS)
                    grassvar=true
                  end
                  if firevar
                    score*=1.5
                  end
                  if !grassvar
                    score*=1.5
                  end
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
              end
              if !poisonvar
                score*=1.5
              end
              if (attacker.hp.to_f)/attacker.totalhp<0.5
                score*=2
              end
            end
            if $fefieldeffect==13 # Icy
              watervar=false
              icevar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:WATER)
                  watervar=true
                end
                if mon.hasType?(:ICE)
                  grassvar=true
                end
                if watervar
                  score*=1.3
                end
                if !icevar
                  score*=1.2
                end
              end
            end
            if $fefieldeffect==15 # Forest
              if pbWeather!=PBWeather::RAINDANCE && @field.effects[PBEffects::WaterSport]==0
                firevar=false
                grassvar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                  if mon.hasType?(:GRASS)
                    grassvar=true
                  end
                  if firevar
                    score*=1.5
                  end
                  if !grassvar
                    score*=1.5
                  end
                end
              end
            end
            if $fefieldeffect==16 # Superheated
              if pbWeather!=PBWeather::RAINDANCE && @field.effects[PBEffects::WaterSport]==0
                firevar=false
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                  if firevar
                    score*=2
                  end
                end
              end
            end
            if $fefieldeffect==28 # Snowy Mountain
              icevar=false
              for mon in pbParty(attacker.index)
                next if mon.nil?
                if mon.hasType?(:ICE)
                  grassvar=true
                end
                if !icevar
                  score*=1.5
                end
              end
            end
            if $fefieldeffect==33 && $fecounter>=2 # Flower Garden
              if pbWeather!=PBWeather::RAINDANCE && @field.effects[PBEffects::WaterSport]==0
                firevar=false
                grassvar=false
                bugvar=falsw
                for mon in pbParty(attacker.index)
                  next if mon.nil?
                  if mon.hasType?(:FIRE)
                    firevar=true
                  end
                  if mon.hasType?(:GRASS)
                    grassvar=true
                  end
                  if mon.hasType?(:BUG)
                    bugvar=true
                  end
                  if firevar
                    score*=1.5
                  end
                  if !grassvar && !bugvar
                    score*=1.5
                  end
                end
              end
            end
          end
        end
      when 0x8C # Crush Grip
      when 0x8D # Gyro Ball
      when 0x8E # Stored Power
      when 0x8F # Punishment
      when 0x90 # Hidden Power
      when 0x91 # Fury Cutter
        if attacker.status==PBStatuses::PARALYSIS
          score*=0.7
        end
        if attacker.effects[PBEffects::Confusion]>0
          score*=0.7
        end
        if attacker.effects[PBEffects::Attract]>=0
          score*=0.7
        end
        if attacker.stages[PBStats::ACCURACY]<0
          ministat = attacker.stages[PBStats::ACCURACY]
          minimini = 15 * ministat
          minimini += 100
          minimini /= 100.0
          score*=minimini
        end
        miniscore = opponent.stages[PBStats::EVASION]
        miniscore*=(-5)
        miniscore+=100
        miniscore/=100.0
        score*=miniscore
        if attacker.hp==attacker.totalhp
          score*=1.3
        end
        score*=1.5 if checkAIdamage(aimem,attacker,opponent,skill)<(attacker.hp/3.0) && (aimem.length > 0)
        score*=0.8 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
      when 0x92 # Echoed Voice
        if attacker.status==PBStatuses::PARALYSIS
          score*=0.7
        end
        if attacker.effects[PBEffects::Confusion]>0
          score*=0.7
        end
        if attacker.effects[PBEffects::Attract]>=0
          score*=0.7
        end
        if attacker.hp==attacker.totalhp
          score*=1.3
        end
        score*=1.5 if checkAIdamage(aimem,attacker,opponent,skill)<(attacker.hp/3.0) && (aimem.length > 0)
      when 0x93 # Rage
        if attacker.attack>attacker.spatk
          score*=1.2
        end
        if attacker.hp==attacker.totalhp
          score*=1.3
        end
        score*=1.3 if checkAIdamage(aimem,attacker,opponent,skill)<(attacker.hp/4.0) && (aimem.length > 0)
      when 0x94 # Present
        if opponent.hp==opponent.totalhp
          score*=1.2
        end
      when 0x95 # Magnitude
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
      when 0x96 # Natural Gift
        if !pbIsBerry?(attacker.item) || (!attacker.abilitynulled && attacker.ability == PBAbilities::KLUTZ) ||
           @field.effects[PBEffects::MagicRoom]>0 || attacker.effects[PBEffects::Embargo]>0 ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::UNNERVE)
          score*=0
        end
      when 0x97 # Trump Card
        if attacker.hp==attacker.totalhp
          score*=1.2
        end
        score*=1.3 if checkAIdamage(aimem,attacker,opponent,skill)<(attacker.hp/3.0) && (aimem.length > 0)
      when 0x98 # Reversal
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=1.1
          if attacker.hp<attacker.totalhp
            score*=1.3
          end
        end
      when 0x99 # Electro Ball
      when 0x9A # Low Kick
      when 0x9B # Heat Crash
      when 0x9C # Helping Hand
        if @doublebattle
          effvar = false
          for i in attacker.moves
            if pbTypeModNoMessages(i.type,attacker,opponent,i,skill)>=4
              effvar = true
            end
          end
          if !effvar
            score*=2
          end
          if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
             ((attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
            score*=1.2
            if attacker.hp*(1.0/attacker.totalhp) < 0.33
              score*=1.5
            end
            if attacker.pbPartner.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) &&
               attacker.pbPartner.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)
              score*=1.5
            end
          end
          ministat = [attacker.pbPartner.attack,attacker.pbPartner.spatk].max
          minimini = [attacker.attack,attacker.spatk].max
          ministat-=minimini
          ministat+=100
          ministat/=100.0
          score*=ministat
          if attacker.pbPartner.hp==0
            score*=0
          end
        else
          score*=0
        end
      when 0x9D # Mud Sport
        if @field.effects[PBEffects::MudSport]==0
          eff1 = PBTypes.getCombinedEffectiveness(PBTypes::ELECTRIC,attacker.type1,attacker.type2)
          eff2 = PBTypes.getCombinedEffectiveness(PBTypes::ELECTRIC,attacker.pbPartner.type1,attacker.pbPartner.type2)
          if eff1>4 || eff2>4 && opponent.hasType?(:ELECTRIC)
            score*=1.5
          end
          elevar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:ELECTRIC)
              elevar=true
            end
          end
          if elevar
            score*=0.7
          end
          if $fefieldeffect==1
            if !elevar
              score*=2
            else
              score*=0.3
            end
          end
        else
          score*=0
        end
      when 0x9E # Water Sport
        if @field.effects[PBEffects::WaterSport]==0
          eff1 = PBTypes.getCombinedEffectiveness(PBTypes::FIRE,attacker.type1,attacker.type2)
          eff2 = PBTypes.getCombinedEffectiveness(PBTypes::FIRE,attacker.pbPartner.type1,attacker.pbPartner.type2)
          if eff1>4 || eff2>4 && opponent.hasType?(:FIRE)
            score*=1.5
          end
          firevar=false
          grassvar=false
          bugvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:FIRE)
              firevar=true
            end
            if mon.hasType?(:GRASS)
              grassvar=true
            end
            if mon.hasType?(:BUG)
              bugvar=true
            end
          end
          if firevar
            score*=0.7
          end
          if $fefieldeffect==7
            if !firevar
              score*=2
            else
              score*=0
            end
          elsif $fefieldeffect==16
            score*=0.7
            if !firevar
              score*=1.8
            else
              score*=0
            end
          elsif $fefieldeffect==2 || $fefieldeffect==15 || $fefieldeffect==33
            if !attacker.hasType?(:FIRE) && opponent.hasType?(:FIRE)
              score*=3
            end
            if grassvar || bugvar
              score*=2
              if $fefieldeffect==33 && $fecounter<4
                score*=3
              end
            end
            if firevar
              score*=0.5
            end
          end
        else
          score*=0
        end
      when 0x9F # Judgement
      when 0xA0 # Frost Breath
        thisinitial = score
        if !(!opponent.abilitynulled && opponent.ability == PBAbilities::BATTLEARMOR) &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::SHELLARMOR) &&
           attacker.effects[PBEffects::LaserFocus]==0
          miniscore = 100
          ministat = 0
          ministat += opponent.stages[PBStats::DEFENSE] if opponent.stages[PBStats::DEFENSE]>0
          ministat += opponent.stages[PBStats::SPDEF] if opponent.stages[PBStats::SPDEF]>0
          miniscore += 10*ministat
          ministat = 0
          ministat -= attacker.stages[PBStats::ATTACK] if attacker.stages[PBStats::ATTACK]<0
          ministat -= attacker.stages[PBStats::SPATK] if attacker.stages[PBStats::SPATK]<0
          miniscore += 10*ministat
          if attacker.effects[PBEffects::FocusEnergy]>0
            miniscore -= 10*attacker.effects[PBEffects::FocusEnergy]
          end
          miniscore/=100.0
          score*=miniscore
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::ANGERPOINT) && opponent.stages[PBStats::ATTACK]!=6
            if opponent == attacker.pbPartner
              if opponent.attack>opponent.spatk
                if thisinitial>99
                  score=0
                else
                  score = (100-thisinitial)
                  enemy1 = attacker.pbOppositeOpposing
                  enemy2 = enemy1.pbPartner
                  if opponent.pbSpeed > enemy1.pbSpeed && opponent.pbSpeed > enemy2.pbSpeed
                    score*=1.3
                  else
                    score*=0.7
                  end
                end
              end
            else
              if thisinitial<100
                score*=0.7
                if opponent.attack>opponent.spatk
                  score*=0.2
                end
              end
            end
          else
            if opponent == attacker.pbPartner
              score = 0
            end
          end
        else
          score*=0.7
        end
      when 0xA1 # Lucky Chant
        if attacker.pbOwnSide.effects[PBEffects::LuckyChant]==0 &&
           !(!attacker.abilitynulled && attacker.ability == PBAbilities::BATTLEARMOR) ||
           !(!attacker.abilitynulled && attacker.ability == PBAbilities::SHELLARMOR) &&
           (opponent.effects[PBEffects::FocusEnergy]>1 || opponent.effects[PBEffects::LaserFocus]>0)
          score+=20
        end
      when 0xA2 # Reflect
        if attacker.pbOwnSide.effects[PBEffects::Reflect]<=0
          score*=1.2
          if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
            score*=0.5
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::LIGHTCLAY)
            score*=1.5
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.1
            if skill>=PBTrainerAI.bestSkill
              if aimem.length > 0
                maxdam=0
                for j in aimem
                  if !j.pbIsPhysical?(j.type)
                    next
                  end
                  tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
                  maxdam=tempdam if maxdam<tempdam
                end
                if maxdam>attacker.hp && (maxdam/2.0)<attacker.hp
                  score*=2
                end
              end
            end
          end
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount<=2
            score*=0.7
            if livecount==1
              score*=0.7
            end
          end
          if (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
             (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
             (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=1.3
          end
          score*=0.1 if checkAImoves(PBStuff::PBStuff::SCREENBREAKERMOVE,aimem)
        else
          score=0
        end
      when 0xA3 # Light Screen
        if attacker.pbOwnSide.effects[PBEffects::LightScreen]<=0
          score*=1.2
          if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
            score*=0.5
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)<pbRoughStat(opponent,PBStats::SPATK,skill)
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::LIGHTCLAY)
            score*=1.5
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.1
            if aimem.length > 0
              maxdam=0
              for j in aimem
                if !j.pbIsSpecial?(j.type)
                  next
                end
                tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
                maxdam=tempdam if maxdam<tempdam
              end
              if maxdam>attacker.hp && (maxdam/2.0)<attacker.hp
                score*=2
              end
            end
          end
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount<=2
            score*=0.7
            if livecount==1
              score*=0.7
            end
          end
          if (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
             (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
             (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=1.3
          end
          score*=0.1 if checkAImoves(PBStuff::PBStuff::SCREENBREAKERMOVE,aimem)
        else
          score=0
        end
      when 0xA4 # Secret Power
        score*=1.2
      when 0xA5 # Never Miss
        if score==110
          score*=1.05
        end
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
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
      when 0xA6 # Lock On
        if opponent.effects[PBEffects::LockOn]>0 ||  opponent.effects[PBEffects::Substitute]>0
          score*=0
        else
          if attacker.pbHasMove?(:INFERNO) ||
             attacker.pbHasMove?(:ZAPCANNON) ||
             attacker.pbHasMove?(:DYNAMICPUNCH)
            if !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) &&
               !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
              score*=3
            end
          end
          if attacker.pbHasMove?(:GUILLOTINE) ||
             attacker.pbHasMove?(:SHEERCOLD) ||
             attacker.pbHasMove?(:GUILLOTINE) ||
             attacker.pbHasMove?(:FISSURE) ||
             attacker.pbHasMove?(:HORNDRILL)
            score*=10
          end
          ministat=0
          ministat = attacker.stages[PBStats::ACCURACY] if attacker.stages[PBStats::ACCURACY]<0
          ministat*=10
          ministat+=100
          ministat/=100.0
          score*=ministat
          ministat = opponent.stages[PBStats::EVASION]
          ministat*=10
          ministat+=100
          ministat/=100.0
          score*=ministat
        end
        if $fefieldeffect==37
          if (move.id == PBMoves::MINDREADER)
            if attacker.stages[PBStats::SPATK]<6
              score+=10
            end
            if attacker.spatk>attacker.attack
              score*=2
            end
            if attacker.hp==attacker.totalhp
              score*=1.5
            else
              score*=0.8
            end
            if roles.include?(PBMonRoles::SWEEPER)
              score*=1.3
            end
            if attacker.hp<attacker.totalhp*0.5
              score*=0.5
            end
          end
        end
      when 0xA7 # Foresight
        if opponent.effects[PBEffects::Foresight]
          score*=0
        else
          ministat = 0
          ministat = opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION]>0
          ministat*=10
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.pbHasType?(:GHOST)
            score*=1.5
            effectvar = false
            for i in attacker.moves
              next if i.basedamage==0
              if !(i.type == PBTypes::NORMAL) && !(i.type == PBTypes::FIGHTING)
                effectvar = true
                break
              end
            end
            if !effectvar && !(!attacker.abilitynulled && attacker.ability == PBAbilities::SCRAPPY)
              score*=5
            end
          end
        end
      when 0xA8 # Miracle Eye
        if opponent.effects[PBEffects::MiracleEye]
          score*=0
        else
          ministat = 0
          ministat = opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION]>0
          ministat*=10
          ministat+=100
          ministat/=100.0
          score*=ministat
          if opponent.pbHasType?(:DARK)
            score*=1.1
            effectvar = false
            for i in attacker.moves
              next if i.basedamage==0
              if !(i.type == PBTypes::PSYCHIC)
                effectvar = true
                break
              end
            end
            if !effectvar
              score*=2
            end
          end
        end
        if $fefieldeffect==37 || $fefieldeffect==29 || $fefieldeffect==31
          if attacker.stages[PBStats::SPATK]<6
            score+=10
          end
          if attacker.spatk>attacker.attack
            score*=2
          end
          if attacker.hp==attacker.totalhp
            score*=1.5
          else
            score*=0.8
          end
          if roles.include?(PBMonRoles::SWEEPER)
            score*=1.3
          end
          if attacker.hp<attacker.totalhp*0.5
            score*=0.5
          end
        end
      when 0xA9 # Chip Away
        ministat = 0
        ministat+=opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION]>0
        ministat+=opponent.stages[PBStats::DEFENSE] if opponent.stages[PBStats::DEFENSE]>0
        ministat+=opponent.stages[PBStats::SPDEF] if opponent.stages[PBStats::SPDEF]>0
        ministat*=5
        ministat+=100
        ministat/=100.0
        score*=ministat
      when 0xAA # Protect
        score*=0.3 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SPEEDBOOST) &&
           attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          score*=4
          #experimental -- cancels out drop if killing moves
          if initialscores.length>0
            score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          #end experimental
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
           attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing] ||
           $fefieldeffect==2
          score*=1.2
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN
          score*=1.2
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        if attacker.status==PBStatuses::POISON || attacker.status==PBStatuses::BURN
          score*=0.7
          if attacker.effects[PBEffects::Toxic]>0
            score*=0.3
          end
        end
        if opponent.effects[PBEffects::LeechSeed]>=0
          score*=1.3
        end
        if opponent.effects[PBEffects::PerishSong]!=0
          score*=2
        end
        if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
          score*=0.3
        end
        if opponent.vanished
          score*=2
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.5
          end
        end
        score*=0.1 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE,aimem)
        if attacker.effects[PBEffects::Wish]>0
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=10
          else
            score*=3
          end
        end
        ratesharers=[
        391,   # Protect
        121,   # Detect
        122,   # Quick Guard
        515,   # Wide Guard
        361,   # Endure
        584,   # King's Shield
        603,    # Spiky Shield
        641    # Baneful Bunker
          ]
        if ratesharers.include?(attacker.lastMoveUsed)
          score/=(attacker.effects[PBEffects::ProtectRate]*2.0)
        end
      when 0xAB # Quick Guard
        ratesharers=[
        391,   # Protect
        121,   # Detect
        122,   # Quick Guard
        515,   # Wide Guard
        361,   # Endure
        584,   # King's Shield
        603,    # Spiky Shield
        641    # Baneful Bunker
          ]
        if ratesharers.include?(attacker.lastMoveUsed)
          score/=(attacker.effects[PBEffects::ProtectRate]*2.0)
        end

        if ((!opponent.abilitynulled && opponent.ability == PBAbilities::GALEWINGS) &&
           opponent.hp == opponent.totalhp) || ((!opponent.abilitynulled &&
           opponent.ability == PBAbilities::PRANKSTER) &&
           attacker.pbHasType?(:POISON)) || checkAIpriority(aimem)
          score*=2
          if @doublebattle
            score*=1.3
            score*=0.3 if checkAIhealing(aimem) || checkAImoves(PBStuff::SETUPMOVE,aimem)
            score*=0.1 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE,aimem)
            if attacker.effects[PBEffects::Wish]>0
              score*=2 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp ||
                          (attacker.pbPartner.hp*(1.0/attacker.pbPartner.totalhp))<0.25
            end
          end
        else
          score*=0
        end
      when 0xAC # Wide Guard
        ratesharers=[
        391,   # Protect
        121,   # Detect
        122,   # Quick Guard
        515,   # Wide Guard
        361,   # Endure
        584,   # King's Shield
        603,    # Spiky Shield
        641    # Baneful Bunker
          ]
        if ratesharers.include?(attacker.lastMoveUsed)
          score/=(attacker.effects[PBEffects::ProtectRate]*2.0)
        end
        widevar = false
        if aimem.length > 0
          for j in aimem
            widevar = true if (j.target == PBTargets::AllOpposing || j.target == PBTargets::AllNonUsers)
          end
        end
        if @doublebattle
          if widevar
            score*=2
            score*=0.3 if checkAIhealing(aimem) || checkAImoves(PBStuff::SETUPMOVE,aimem)
            score*=0.1 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE,aimem)
            if attacker.effects[PBEffects::Wish]>0
              maxdam = checkAIdamage(aimem,attacker,opponent,skill)
              if maxdam>attacker.hp || (attacker.pbPartner.hp*(1.0/attacker.pbPartner.totalhp))<0.25
                score*=2
              end
            end
            if $fefieldeffect==11
              score*=2 if checkAImoves([PBMoves::HEATWAVE,PBMoves::LAVAPLUME,PBMoves::ERUPTION,PBMoves::MINDBLOWN],aimem)
            end
            if $fefieldeffect==23
              score*=2 if checkAImoves([PBMoves::MAGNITUDE,PBMoves::EARTHQUAKE,PBMoves::BULLDOZE],aimem)
            end
            if $fefieldeffect==30
              score*=2 if (checkAImoves([PBMoves::MAGNITUDE,PBMoves::EARTHQUAKE,PBMoves::BULLDOZE],aimem) ||
                          checkAImoves([PBMoves::HYPERVOICE,PBMoves::BOOMBURST],aimem))
            end
          end
        else
          score*=0
        end
      when 0xAD # Feint
        if checkAImoves(PBStuff::PROTECTIGNORINGMOVE,aimem)
          score*=1.1
          ratesharers=[
          391,   # Protect
          121,   # Detect
          122,   # Quick Guard
          515,   # Wide Guard
          361,   # Endure
          584,   # King's Shield
          603,    # Spiky Shield
          641    # Baneful Bunker
            ]
          if !ratesharers.include?(opponent.lastMoveUsed)
            score*=1.2
          end
        end
      when 0xAE # Mirror Move
        if opponent.lastMoveUsed>0
          mirrored = PBMove.new(opponent.lastMoveUsed)
          mirrmove = PokeBattle_Move.pbFromPBMove(self,mirrored,attacker)
          if mirrmove.flags&0x10==0
            score*=0
          else
            rough = pbRoughDamage(mirrmove,attacker,opponent,skill,mirrmove.basedamage)
            mirrorscore = pbGetMoveScore(mirrmove,attacker,opponent,skill,rough,initialscores,scoreindex)
            score = mirrorscore
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=0.5
            end
          end
        else
          score*=0
        end
      when 0xAF # Copycat
        if opponent.lastMoveUsed>0  && opponent.effects[PBEffects::Substitute]<=0
          copied = PBMove.new(opponent.lastMoveUsed)
          copymove = PokeBattle_Move.pbFromPBMove(self,copied,attacker)
          if copymove.flags&0x10==0
            score*=0
          else
            rough = pbRoughDamage(copymove,attacker,opponent,skill,copymove.basedamage)
            copyscore = pbGetMoveScore(copymove,attacker,opponent,skill,rough,initialscores,scoreindex)
            score = copyscore
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=0.5
            end
            if $fefieldeffect==30
              score*=1.5
            end
          end
        else
          score*=0
        end
      when 0xB0 # Me First
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if checkAImoves(PBStuff::SETUPMOVE,aimem)
            score*=0.8
          else
            score*=1.5
          end
          if checkAIpriority(aimem) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::PRANKSTER) ||
             ((!opponent.abilitynulled && opponent.ability == PBAbilities::GALEWINGS) && opponent.hp==opponent.totalhp)
            score*=0.6
          else
            score*=1.5
          end
          if opponent.hp>0 && initialscores.length>0
            if checkAIdamage(aimem,attacker,opponent,skill)/(1.0*opponent.hp)>initialscores.max
              score*=2
            else
              score*=0.5
            end
          end
        else
          score*=0
        end
      when 0xB1 # Magic Coat
        if attacker.lastMoveUsed>0
          olddata = PBMove.new(attacker.lastMoveUsed)
          oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
          if oldmove.function==0xB1
            score*=0.5
          else
            if attacker.hp==attacker.totalhp
              score*=1.5
            end
            statvar = true
            for i in opponent.moves
              if i.basedamage>0
                statvar=false
              end
            end
            if statvar
              score*=3
            end
          end
        else
          if attacker.hp==attacker.totalhp
            score*=1.5
          end
          statvar = true
          for i in opponent.moves
            if i.basedamage>0
              statvar=false
            end
          end
          if statvar
            score*=3
          end
        end
      when 0xB2 # Snatch
        if attacker.lastMoveUsed>0
          olddata = PBMove.new(attacker.lastMoveUsed)
          oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
          if oldmove.function==0xB2
            score*=0.5
          else
            if opponent.hp==opponent.totalhp
              score*=1.5
            end
            score*=2 if checkAImoves(PBStuff::SETUPMOVE,aimem)
            if opponent.attack>opponent.spatk
              if attacker.attack>attacker.spatk
                score*=1.5
              else
                score*=0.7
              end
            else
              if attacker.spatk>attacker.attack
                score*=1.5
              else
                score*=0.7
              end
            end
          end
        else
          if opponent.hp==opponent.totalhp
            score*=1.5
          end
          score*=2 if checkAImoves(PBStuff::SETUPMOVE,aimem)
          if opponent.attack>opponent.spatk
            if attacker.attack>attacker.spatk
              score*=1.5
            else
              score*=0.7
            end
          else
            if attacker.spatk>attacker.attack
              score*=1.5
            else
              score*=0.7
            end
          end
        end
      when 0xB3 # Nature Power
        case $fefieldeffect
          when 33
            if $fecounter == 4
              newmove=PBMoves::PETALBLIZZARD
            else
              newmove=PBMoves::GROWTH
            end
          else
            if $fefieldeffect > 0 && $fefieldeffect <= 37
              naturemoves = FieldEffects::NATUREMOVES
              newmove= naturemoves[$fefieldeffect]
            else
              newmove=PBMoves::TRIATTACK
            end
          end
        newdata = PBMove.new(newmove)
        naturemove = PokeBattle_Move.pbFromPBMove(self,newdata,attacker)
        if naturemove.basedamage<=0
          naturedam=pbStatusDamage(naturemove)
        else
          tempdam=pbRoughDamage(naturemove,attacker,opponent,skill,naturemove.basedamage)
          naturedam=(tempdam*100)/(opponent.hp.to_f)
        end
        naturedam=110 if naturedam>110
        score = pbGetMoveScore(naturemove,attacker,opponent,skill,naturedam)
      when 0xB4 # Sleep Talk
        if attacker.status==PBStatuses::SLEEP
          if attacker.statusCount<=1
            score*=0
          else
            if attacker.pbHasMove?(:SNORE)
              count=-1
              for k in attacker.moves
                count+=1
                if k.id == 312 # Snore index
                  break
                end
              end
              if initialscores
                snorescore = initialscores[count]
                otherscores = 0
                for s in initialscores
                  next if s.index==scoreindex
                  next if s.index==count
                  otherscores+=s
                end
                otherscores/=2.0
                if otherscores>snorescore
                  score*=0.1
                else
                  score*=5
                end
              end
            end
          end
        else
          score*=0
        end
      when 0xB5 # Assist
        if attacker.pbNonActivePokemonCount > 0
          if initialscores.length>0
            scorecheck = false
            for s in initialscores
              next if initialscores.index(s) == scoreindex
              scorecheck=true if s>25
            end
            if scorecheck
              score*=0.5
            else
              score*=1.5
            end
          end
        else
          score*=0
        end
      when 0xB6 # Metronome
        if $fefieldeffect==24
          if initialscores.length>0
            scorecheck = false
            for s in initialscores
              next if initialscores.index(s) == scoreindex
              scorecheck=true if s>40
            end
            if scorecheck
              score*=0.8
            else
              score*=2
            end
          end
        else
          if initialscores.length>0
            scorecheck = false
            for s in initialscores
              next if initialscores.index(s) == scoreindex
              scorecheck=true if s>21
            end
            if scorecheck
              score*=0.5
            else
              score*=1.2
            end
          end
        end
      when 0xB7 # Torment
        olddata = PBMove.new(attacker.lastMoveUsed)
        oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
        maxdam = 0
        moveid = -1
        if aimem.length > 0
          for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              moveid = j.id
            end
          end
        end
        if opponent.effects[PBEffects::Torment] || (pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken))
          score=0
        else
          if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK))
            score*=1.2
          else
            score*=0.7
          end
          if oldmove.basedamage>0
            score*=1.5
            if moveid == oldmove.id
              score*=1.3
              if maxdam*3<attacker.totalhp
                score*=1.5
              end
            end
            if attacker.pbHasMove?(:PROTECT)
              score*=1.5
            end
            if (attitemworks && attacker.item == PBItems::LEFTOVERS)
              score*=1.3
            end
          else
            score*=0.5
          end
        end
      when 0xB8 # Imprison
        if attacker.effects[PBEffects::Imprison]
          score*=0
        else
          miniscore=1
          ourmoves = []
          olddata = PBMove.new(attacker.lastMoveUsed)
          oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
          for m in attacker.moves
            ourmoves.push(m.id) unless m.id<1
          end
          if ourmoves.include?(oldmove.id)
            score*=1.3
          end
          if aimem.length > 0
            for j in aimem
              if ourmoves.include?(j.id)
                miniscore+=1
                if j.isHealingMove?
                  score*=1.5
                end
              else
                score*=0.5
              end
            end
          end
          score*=miniscore
        end
      when 0xB9 # Disable
        olddata = PBMove.new(opponent.lastMoveUsed)
        oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
        maxdam = 0
        moveid = -1
        if aimem.length > 0
          for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              moveid = j.id
            end
          end
        end
        if oldmove.id == -1 && (((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK)))
          score=0
        end
        if opponent.effects[PBEffects::Disable]>0 || (pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken))
          score=0
        else
          if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK))
            score*=1.2
          else
            score*=0.3
          end
          if oldmove.basedamage>0 || oldmove.isHealingMove?
            score*=1.5
            if moveid == oldmove.id
              score*=1.3
              if maxdam*3<attacker.totalhp
                score*=1.5
              end
            end
          else
            score*=0.5
          end
        end
      when 0xBA # Taunt
        olddata = PBMove.new(attacker.lastMoveUsed)
        oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
        if opponent.effects[PBEffects::Taunt]>0 || (pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken))
          score=0
        else
          if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK))
            score*=1.5
          else
            score*=0.7
          end
          if (pbGetMonRole(opponent,attacker,skill)).include?(PBMonRoles::LEAD)
            score*=1.2
          else
            score*=0.8
          end
          if opponent.turncount<=1
            score*=1.1
          else
            score*=0.9
          end
          if oldmove.isHealingMove?
            score*=1.3
          end
          if @doublebattle
            score *= 0.6
          end
        end
      when 0xBB # Heal Block
        olddata = PBMove.new(attacker.lastMoveUsed)
        oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
        if opponent.effects[PBEffects::HealBlock]>0 ||
           (pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)) ||
           opponent.effects[PBEffects::Substitute]>0
          score=0
        else
          if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK))
            score*=1.5
          end
          if oldmove.isHealingMove?
            score*=2.5
          end
          if (oppitemworks && opponent.item == PBItems::LEFTOVERS)
            score*=1.3
          end
        end
      when 0xBC # Encore
        olddata = PBMove.new(opponent.lastMoveUsed)
        oldmove = PokeBattle_Move.pbFromPBMove(self,olddata,attacker)
        if opponent.effects[PBEffects::Encore]>0 ||
           (pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken))
          score=0
        else
          if opponent.lastMoveUsed<=0
            score*=0.2
          else
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.5
            else
              if ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) && !opponent.pbHasType?(:DARK))
                score*=2
              else
                score*=0.2
              end
            end
            if oldmove.basedamage>0 && pbRoughDamage(oldmove,opponent,attacker,skill,oldmove.basedamage)*5>attacker.hp
              score*=0.3
            else
              if opponent.stages[PBStats::SPEED]>0
                if (opponent.pbHasType?(:DARK) ||
                   !(!attacker.abilitynulled && attacker.ability == PBAbilities::PRANKSTER) ||
                   (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST))
                  score*=0.5
                else
                  score*=2
                end
              else
                score*=2
              end
            end
            if $fefieldeffect == 6
              score*=1.5
            end
          end
        end
      when 0xBD # Double Kick
        if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::IRONBARBS) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::ROUGHSKIN)
          score*=0.9
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
          score*=1.1
        end
      when 0xBE # Twinneedle
        if opponent.pbCanPoison?(false)
          miniscore=100
          miniscore*=1.2
          ministat=0
          ministat+=opponent.stages[PBStats::DEFENSE]
          ministat+=opponent.stages[PBStats::SPDEF]
          ministat+=opponent.stages[PBStats::EVASION]
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
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::TOXICBOOST) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICGUARD)
            miniscore*=0.1
          end
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          miniscore*=0.2 if checkAImoves([PBMoves::FACADE],aimem)
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.5
          end
          if initialscores.length>0
            miniscore*=1.2 if hasbadmoves(initialscores,scoreindex,30)
          end
          if attacker.pbHasMove?(:VENOSHOCK) ||
            attacker.pbHasMove?(:VENOMDRENCH) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::MERCILESS)
            miniscore*=1.6
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
        if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::IRONBARBS) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::ROUGHSKIN)
          score*=0.8
        end
        if opponent.hp==opponent.totalhp && ((oppitemworks && opponent.item == PBItems::FOCUSSASH) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY))
          score*=1.3
        end
        if opponent.effects[PBEffects::Substitute]>0
          score*=1.3
        end
        if (attitemworks && attacker.item == PBItems::RAZORFANG) ||
           (attitemworks && attacker.item == PBItems::KINGSROCK)
          score*=1.1
        end
      when 0xBF # Triple Kick
        if (oppitemworks && opponent.item == PBItems::ROCKYHELMET) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::IRONBARBS) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::ROUGHSKIN)
          score*=0.8
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
          score*=1.2
        end
    end
    return score
  end
end
