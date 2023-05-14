class PokeBattle_Battle
  alias __f__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    score = __f__pbGetMoveScoreFunctionCode(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                            score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      when 0x140 # Venom Drench
        if opponent.status==PBStatuses::POISON || $fefieldeffect==10 || $fefieldeffect==11 || $fefieldeffect==19 || $fefieldeffect==26
          if (!opponent.pbCanReduceStatStage?(PBStats::ATTACK) &&
             !opponent.pbCanReduceStatStage?(PBStats::SPATK)) ||
             (opponent.stages[PBStats::ATTACK]==-6 && opponent.stages[PBStats::SPATK]==-6) ||
             (opponent.stages[PBStats::ATTACK]>0 && opponent.stages[PBStats::SPATK]>0)
            score*=0.5
          else
            miniscore=100
            if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
              miniscore*=1.4
            end
            sweepvar = false
            for i in pbParty(attacker.index)
              next if i.nil?
              temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
              if temprole.include?(PBMonRoles::SWEEPER)
                sweepvar = true
              end
            end
            if sweepvar
              miniscore*=1.1
            end
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
               (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
               opponent.effects[PBEffects::MeanLook]>=0 ||  opponent.pbNonActivePokemonCount==0
              miniscore*=1.5
            end
            ministat= 5*statchangecounter(opponent,1,7,-1)
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            if attacker.pbHasMove?(:FOULPLAY)
              miniscore*=0.5
            end
            miniscore/=100.0
            score*=miniscore
          end
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ||
            opponent.stages[PBStats::SPEED]>0 || !opponent.pbCanReduceStatStage?(PBStats::SPEED)
            score*=0.5
          else
            miniscore=100
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
              miniscore*=0.9
            end
            if attacker.pbHasMove?(:ELECTROBALL)
              miniscore*=1.5
            end
            if attacker.pbHasMove?(:GYROBALL)
              miniscore*=0.5
            end
            if (oppitemworks && opponent.item == PBItems::LAGGINGTAIL) || (oppitemworks && opponent.item == PBItems::IRONBALL)
              miniscore*=0.8
            end
            miniscore*=0.1 if checkAImoves([PBMoves::TRICKROOM],aimem) || @trickroom!=0
            miniscore*=1.3 if checkAImoves([PBMoves::ELECTROBALL],aimem)
            miniscore*=0.5 if checkAImoves([PBMoves::GYROBALL],aimem)
            miniscore/=100.0
            score*=miniscore
            if attacker.pbNonActivePokemonCount==0
              score*=0.5
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT)
              score*=0
            end
          end
        else
          score*=0
        end
      when 0x141 # Topsy-Turvy
        ministat= 10* statchangecounter(opponent,1,7)
        ministat+=100
        if ministat<0
          ministat=0
        end
        ministat/=100.0
        if opponent == attacker.pbPartner
          ministat = 2-ministat
        end
        score*=ministat
        if $fefieldeffect!=22 && $fefieldeffect!=35 && $fefieldeffect!=36
          effcheck = PBTypes.getCombinedEffectiveness(opponent.type1,attacker.type1,attacker.type2)
          if effcheck>4
            score*=2
          else
            if effcheck!=0 && effcheck<4
              score*=0.5
            end
            if effcheck==0
              score*=0.1
            end
          end
          effcheck = PBTypes.getCombinedEffectiveness(opponent.type2,attacker.type1,attacker.type2)
          if effcheck>4
            score*=2
          else
            if effcheck!=0 && effcheck<4
              score*=0.5
            end
            if effcheck==0
              score*=0.1
            end
          end
          effcheck = PBTypes.getCombinedEffectiveness(attacker.type1,opponent.type1,opponent.type2)
          if effcheck>4
            score*=0.5
          else
            if effcheck!=0 && effcheck<4
              score*=2
            end
            if effcheck==0
              score*=3
            end
          end
          effcheck = PBTypes.getCombinedEffectiveness(attacker.type2,opponent.type1,opponent.type2)
          if effcheck>4
            score*=0.5
          else
            if effcheck!=0 && effcheck<4
              score*=2
            end
            if effcheck==0
              score*=3
            end
          end
        end
      when 0x142 # Trick or Treat
        ghostvar = false
        if aimem.length > 0
          for j in aimem
            ghostvar = true if (j.type == PBTypes::GHOST)
          end
        end
        effmove = false
        for m in attacker.moves
          if (m.type == PBTypes::DARK) || (m.type == PBTypes::GHOST)
            effmove = true
            break
          end
        end
        if effmove
          score*=1.5
        else
          score*=0.7
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          if attacker.pbHasMove?(:TOXIC) && (opponent.pbHasType?(:STEEL) || opponent.pbHasType?(:POISON))
            score*=1.5
          end
        end
        if ghostvar
          score*=0.5
        else
          score*=1.1
        end
        if (opponent.ability == PBAbilities::MULTITYPE) || (opponent.ability == PBAbilities::RKSSYSTEM) ||
           (opponent.type1==(PBTypes::GHOST) && opponent.type2==(PBTypes::GHOST)) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::PROTEAN) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::COLORCHANGE)
          score*=0
        end
      when 0x143 # Forest's Curse
        grassvar = false
        if aimem.length > 0
          for j in aimem
            grassvar = true if (j.type == PBTypes::GRASS)
          end
        end
        effmove = false
        for m in attacker.moves
          if (m.type == PBTypes::FIRE) || (m.type == PBTypes::ICE) || (m.type == PBTypes::BUG) || (m.type == PBTypes::FLYING) || (m.type == PBTypes::POISON)
            effmove = true
            break
          end
        end
        if effmove
          score*=1.5
        else
          score*=0.7
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          if attacker.pbHasMove?(:TOXIC) && (opponent.pbHasType?(:STEEL) || opponent.pbHasType?(:POISON))
            score*=1.5
          end
        end
        if grassvar
          score*=0.5
        else
          score*=1.1
        end
        if (opponent.ability == PBAbilities::MULTITYPE) || (opponent.ability == PBAbilities::RKSSYSTEM) ||
           (opponent.type1==(PBTypes::GRASS) && opponent.type2==(PBTypes::GRASS)) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::PROTEAN) ||
           (!opponent.abilitynulled && opponent.ability == PBAbilities::COLORCHANGE)
          score*=0
        end
        if $fefieldeffect == 15 || $fefieldeffect == 31
          if !opponent.effects[PBEffects::Curse]
            score+=25
            ministat= 5*statchangecounter(opponent,1,7)
            ministat+=100
            ministat/=100.0
            score*=ministat
            if opponent.pbNonActivePokemonCount==0 || (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) || opponent.effects[PBEffects::MeanLook]>0
              score*=1.3
            else
              score*=0.8
            end
            if @doublebattle
              score*=0.5
            end
            if initialscores.length>0
              score*=1.3 if hasbadmoves(initialscores,scoreindex,25)
            end
          end
        end
      when 0x144 # Flying Press
        if opponent.effects[PBEffects::Minimize]
          score*=2
        end
        if @field.effects[PBEffects::Gravity]>0
          score*=0
        end
      when 0x145 # Electrify
        startscore = score
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::VOLTABSORB)
            if attacker.hp<attacker.totalhp*0.8
              score*=1.5
            else
              score*=0.1
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::LIGHTNINGROD)
            if attacker.spatk > attacker.attack && attacker.stages[PBStats::SPATK]!=6
              score*=1.5
            else
              score*=0.1
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOTORDRIVE)
            if attacker.stages[PBStats::SPEED]!=6
              score*=1.2
            else
              score*=0.1
            end
          end
          if attacker.pbHasType?(:GROUND)
            score*=1.3
          end
          if score==startscore
            score*=0.1
          end
          score*=0.5 if checkAIpriority(aimem)
        else
          score*=0
        end
      when 0x146 # Ion Deluge
        maxnormal = checkAIbest(aimem,1,[PBTypes::NORMAL],false,attacker,opponent,skill)
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.9
        elsif (!attacker.abilitynulled && attacker.ability == PBAbilities::MOTORDRIVE)
          if maxnormal
            score*=1.5
          end
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::LIGHTNINGROD) || (!attacker.abilitynulled && attacker.ability == PBAbilities::VOLTABSORB)
          if ((attacker.hp.to_f)/attacker.totalhp)<0.6
            if maxnormal
              score*=1.5
            end
          end
        end
        if attacker.pbHasType?(:GROUND)
          score*=1.1
        end
        if @doublebattle
          if (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MOTORDRIVE) ||
             (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::LIGHTNINGROD) ||
             (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::VOLTABSORB)
            score*=1.2
          end
          if attacker.pbPartner.pbHasType?(:GROUND)
            score*=1.1
          end
        end
        if !maxnormal
          score*=0.5
        end
        if $fefieldeffect != 35 && $fefieldeffect != 1 && $fefieldeffect != 22
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
            miniscore*=1.5
          end
          if attacker.pbHasType?(:ELECTRIC)
            miniscore*=1.5
          end
          elecvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:ELECTRIC)
              elecvar=true
            end
          end
          if elecvar
            miniscore*=1.5
          end
          if opponent.pbHasType?(:ELECTRIC)
            miniscore*=0.5
          end
          for m in attacker.moves
            if m.function==0x03
              miniscore*=0.5
              break
            end
          end
          if sleepcheck
            miniscore*=2
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
          score*=miniscore
        end
      when 0x146 # Plasma Fists
        maxdam = 0
        maxtype = -1
        if aimem.length > 0
          for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxtype = j.type
            end
          end
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore=100
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::VOLTABSORB)
            if attacker.hp<attacker.totalhp*0.8
              miniscore*=1.5
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::LIGHTNINGROD)
            if attacker.spatk > attacker.attack && attacker.stages[PBStats::SPATK]!=6
              miniscore*=1.5
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOTORDRIVE)
            if attacker.stages[PBStats::SPEED]!=6
              miniscore*=1.2
            end
          end
          if attacker.pbHasType?(:GROUND)
            miniscore*=1.3
          end
          miniscore*=0.5 if checkAIpriority(aimem)
          if maxtype == (PBTypes::NORMAL)
            miniscore*=2
          end
          score*=miniscore
        end
      when 0x147 # Hyperspace Hole
        if checkAImoves(PBStuff::PROTECTMOVE,aimem)
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
        if !(!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
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
          if (oppitemworks && opponent.item == PBItems::LAXINCENSE) || (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER)
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
      when 0x148 # Powder
        firecheck = false
        movecount = 0
        if aimem.length > 0
          for j in aimem
            movecount+=1
            if j.type == (PBTypes::FIRE)
              firecheck = true
            end
          end
        end
        if !(opponent.pbHasType?(:GRASS) || (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) || (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES))
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.2
          end
          if checkAIbest(aimem,1,[PBTypes::FIRE],false,attacker,opponent,skill)
            score*=3
          else
            if opponent.pbHasType?(:FIRE)
              score*=2
            else
              score*=0.2
            end
          end
          effcheck = PBTypes.getCombinedEffectiveness((PBTypes::FIRE),attacker.type1,attacker.type2)
          if effcheck>4
            score*=2
            if effcheck>8
              score*=2
            end
          end
          if attacker.lastMoveUsed==600
            score*=0.6
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICGUARD)
            score*=0.5
          end
          if !firecheck && movecount==4
            score*=0
          end
        else
          score*=0
        end
      when 0x149 # Mat Block
        if attacker.turncount==0
          if @doublebattle
            score*=1.3
            if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && ((attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
              score*=1.2
            else
              score*=0.7
              if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && ((attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
                score*=0
              end
            end
            score*=0.3 if checkAImoves(PBStuff::SETUPMOVE,aimem) && checkAIhealing(aimem)
            if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
               ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
               attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing] || $fefieldeffect==2
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
            score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
            if attacker.effects[PBEffects::Wish]>0
              score*=1.3
            end
          end
        else
          score*=0
        end
      when 0x14A # Crafty Shield
        if attacker.lastMoveUsed==565
          score*=0.5
        else
          nodam = true
          for m in opponent.moves
            if m.basedamage>0
              nodam=false
              break
            end
          end
          if nodam
            score+=10
          end
          if attacker.hp==attacker.totalhp
            score*=1.5
          end
        end
        if $fefieldeffect==31
          score+=25
          miniscore=100
          if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
            miniscore*=1.3
          end
          if initialscores.length>0
            miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
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
          miniscore*=1.1 if checkAIdamage(aimem,attacker,opponent,skill) < attacker.hp*0.3 && (aimem.length > 0)
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
              miniscore*=1.5
            end
          end
          if attacker.effects[PBEffects::Confusion]>0
            miniscore*=0.5
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
          miniscore*=0.3 if checkAIdamage(aimem,attacker,opponent,skill)<attacker.hp*0.12 && (aimem.length > 0)
          miniscore/=100.0
          score*=miniscore
          miniscore=100
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.5
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) || ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
            miniscore*=1.2
          end
          healmove=false
          for j in attacker.moves
            if j.isHealingMove?
              healmove=true
            end
          end
          if healmove
            miniscore*=1.7
          end
          if attacker.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
          end
          if attacker.pbHasMove?(:PAINSPLIT)
            miniscore*=1.2
          end
          if attacker.stages[PBStats::SPDEF]!=6 && attacker.stages[PBStats::DEFENSE]!=6
            score*=miniscore
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            score=0
          end
        end
      when 0x14B # Kings Shield
        if opponent.turncount==0
          score*=1.5
        end
        score*=0.6 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SPEEDBOOST) && attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          score*=4
          #experimental -- cancels out drop if killing moves
          if initialscores.length>0
            score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          #end experimental
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
           attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing] || $fefieldeffect==2
          score*=1.2
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN
          score*=1.2
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        if attacker.status==PBStatuses::POISON || attacker.status==PBStatuses::BURN
          score*=0.8
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
        if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && (attacker.species == PBSpecies::AEGISLASH) && attacker.form==1
          score*=4
          #experimental -- cancels out drop if killing moves
          if initialscores.length>0
            score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          #end experimental
        else
          score*=0.8
        end
        score*=0.3 if checkAImoves(PBStuff::PROTECTIGNORINGMOVE,aimem)
        if attacker.effects[PBEffects::Wish]>0
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=3
          else
            score*=1.4
          end
        end
        if aimem.length > 0
          contactcheck=false
          for j in aimem
            contactcheck=j.isContactMove?
          end
          if contactcheck
            score*=1.3
          end
        end
        if skill>=PBTrainerAI.bestSkill && $fefieldeffect==31 # Fairy Tale
          score*=1.4
        else
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            score*=1.5
          end
          if attacker.status==0
            score*=0.1 if checkAImoves([PBMoves::WILLOWISP,PBMoves::THUNDERWAVE,PBMoves::TOXIC],aimem)
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
      when 0x14C # Spiky Shield
        if opponent.turncount==0
          score*=1.5
        end
        score*=0.3 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SPEEDBOOST) && attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          score*=4
          #experimental -- cancels out drop if killing moves
          if initialscores.length>0
            score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          #end experimental
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
           attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing] || $fefieldeffect==2
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
            score*=3
          else
            score*=1.4
          end
        end
        if aimem.length > 0
          contactcheck=false
          maxdam=0
          for j in aimem
            contactcheck=j.isContactMove?
          end
          if contactcheck
            score*=1.3
          end
        end
        if attacker.status==0
          score*=0.7 if checkAImoves([PBMoves::WILLOWISP,PBMoves::THUNDERWAVE,PBMoves::TOXIC],aimem)
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
      when 0x14E # Geomancy
        maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        if !(attitemworks && attacker.item == PBItems::POWERHERB)
          if maxdam>attacker.hp
            score*=0.4
          elsif attacker.hp*(1.0/attacker.totalhp)<0.5
            score*=0.6
          end
          if attacker.turncount<2
            score*=1.5
          else
            score*=0.7
          end
          if opponent.effects[PBEffects::TwoTurnAttack]!=0 || opponent.effects[PBEffects::HyperBeam]>0
            score*=2
          end
          if @doublebattle
            score*=0.5
          end
        else
          score*=2
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
            score*=1.5
          end
        end
        miniscore=100
        if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
          miniscore*=1.3
        end
        if initialscores.length>0
          miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,40)
        end
        if (attacker.hp.to_f)/attacker.totalhp>0.75
          miniscore*=1.2
        end
        if opponent.effects[PBEffects::Yawn]>0
          miniscore*=1.7
        end
        if maxdam*4<attacker.hp
          miniscore*=1.2
        else
          if move.basedamage==0
            miniscore*=0.8
            if maxdam>attacker.hp
              miniscore*=0.1
            end
          end
        end
        if opponent.status!=0
          miniscore*=1.2
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
          miniscore*=0.3
        end
        miniscore*=0.5 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
          miniscore*=2
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=0.5
        end
        miniscore/=100.0
        score*=miniscore
        miniscore=100
        if attacker.stages[PBStats::SPEED]<0
          ministat=attacker.stages[PBStats::SPEED]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        ministat=0
        ministat+=opponent.stages[PBStats::ATTACK]
        ministat+=opponent.stages[PBStats::SPATK]
        ministat+=opponent.stages[PBStats::SPEED]
        if ministat>0
          minimini=(-5)*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        miniscore*=1.3 if checkAIhealing(aimem)
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        miniscore/=100.0
        if !attacker.pbTooHigh?(PBStats::SPATK)
          score*=miniscore
        end
        miniscore=100
        if attacker.effects[PBEffects::Toxic]>0
          miniscore*=0.2
        end
        if pbRoughStat(opponent,PBStats::ATTACK,skill)<pbRoughStat(opponent,PBStats::SPATK,skill)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) || ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
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
        miniscore/=100.0
        if !attacker.pbTooHigh?(PBStats::SPDEF)
          score*=miniscore
        end
        miniscore=100
        if attacker.stages[PBStats::SPATK]<0
          ministat=attacker.stages[PBStats::SPATK]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=0.8
        end
        if @trickroom!=0
          miniscore*=0.2
        else
          miniscore*=0.2 if checkAImoves([PBMoves::TRICKROOM],aimem)
        end
        miniscore/=100.0
        if !attacker.pbTooHigh?(PBStats::SPEED)
          score*=miniscore=0
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=0
        end
        psyvar=false
        fairyvar=false
        darkvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:PSYCHIC)
            psyvar=true
          end
          if mon.hasType?(:FAIRY)
            fairyvar=true
          end
          if mon.hasType?(:DARK)
            darkvar=true
          end
        end
        if $fefieldeffect==35
          if !(!attacker.abilitynulled && attacker.ability == PBAbilities::LEVITATE) && !attacker.pbHasType?(:FLYING)
            score*=2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::LEVITATE) || opponent.pbHasType?(:FLYING)
            score*=2
          end
          if psyvar || fairyvar || darkvar
            score*=2
            if attacker.pbHasType?(:PSYCHIC) || attacker.pbHasType?(:FAIRY) || attacker.pbHasType?(:DARK)
              score*=2
            end
          end
        end
        if attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::SPDEF) && attacker.pbTooHigh?(PBStats::SPEED)
          score*=0
        end
      when 0x14F # Draining Kiss
        minimini = score*0.01
        miniscore = (opponent.hp*minimini)*(3.0/4.0)
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
        if (attacker.hp!=attacker.totalhp || ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0))) && opponent.effects[PBEffects::Substitute]==0
          score*=miniscore
        end
        if $fefieldeffect==31 && move.id==(PBMoves::DRAININGKISS)
          if opponent.status==PBStatuses::SLEEP
            score*=0.2
          end
        end
      when 0x150 # Fell Stinger
        if attacker.stages[PBStats::ATTACK]!=6
          if score>=100
            score*=2
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=2
            end
          end
        end
      when 0x151 # Parting Shot
        if (!opponent.pbCanReduceStatStage?(PBStats::ATTACK) &&
           !opponent.pbCanReduceStatStage?(PBStats::SPATK)) ||
           (opponent.stages[PBStats::ATTACK]==-6 && opponent.stages[PBStats::SPATK]==-6) ||
           (opponent.stages[PBStats::ATTACK]>0 && opponent.stages[PBStats::SPATK]>0)
          score*=0
        else
          if attacker.pbNonActivePokemonCount==0
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
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.1
            end
            sweepvar = false
            for i in pbParty(attacker.index)
              next if i.nil?
              temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
              if temprole.include?(PBMonRoles::SWEEPER)
                sweepvar = true
              end
            end
            if sweepvar
              score*=1.5
            end
            if roles.include?(PBMonRoles::LEAD)
              score*=1.1
            end
            if roles.include?(PBMonRoles::PIVOT)
              score*=1.2
            end
            ministat= 5*statchangecounter(opponent,1,7,-1)
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
            miniscore= (-5)*statchangecounter(attacker,1,7,1)
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
            if attacker.effects[PBEffects::Toxic]>0 || attacker.effects[PBEffects::Attract]>-1 || attacker.effects[PBEffects::Confusion]>0
              score*=1.3
            end
            if attacker.effects[PBEffects::LeechSeed]>-1
              score*=1.5
            end
            miniscore=130
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
               (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
               opponent.effects[PBEffects::MeanLook]>=0 ||  opponent.pbNonActivePokemonCount==0
              miniscore*=1.4
            end
            ministat= 5*statchangecounter(opponent,1,7,-1)
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::COMPETITIVE) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
              miniscore*=0.1
            end
            miniscore/=100.0
            score*=miniscore
          end
        end
      when 0x152 # Fairy Lock
        if attacker.effects[PBEffects::PerishSong]==1 || attacker.effects[PBEffects::PerishSong]==2
          score*=0
        else
          if opponent.effects[PBEffects::PerishSong]==2
            score*=10
          end
          if opponent.effects[PBEffects::PerishSong]==1
            score*=20
          end
          if attacker.effects[PBEffects::LeechSeed]>=0
            score*=0.8
          end
          if opponent.effects[PBEffects::LeechSeed]>=0
            score*=1.2
          end
          if opponent.effects[PBEffects::Curse]
            score*=1.3
          end
          if attacker.effects[PBEffects::Curse]
            score*=0.7
          end
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.1
          end
          if attacker.effects[PBEffects::Confusion]>0
            score*=1.1
          end
        end
      when 0x153 # Sticky Web
        if !attacker.pbOpposingSide.effects[PBEffects::StickyWeb]
          if roles.include?(PBMonRoles::LEAD)
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::FOCUSSASH) && attacker.hp==attacker.totalhp
            score*=1.3
          end
          if attacker.turncount<2
            score*=1.3
          end
          if opponent.pbNonActivePokemonCount>1
            miniscore = opponent.pbNonActivePokemonCount
            miniscore/=100.0
            miniscore*=0.3
            miniscore+=1
            score*=miniscore
          else
            score*=0.2
          end
          if skill>=PBTrainerAI.bestSkill
            for k in 0...pbParty(opponent.index).length
              next if pbParty(opponent.index)[k].nil?
              if @aiMoveMemory[2][k].length>0
                movecheck=false
                for j in @aiMoveMemory[2][k]
                  movecheck=true if j.id==(PBMoves::DEFOG) || j.id==(PBMoves::RAPIDSPIN)
                end
                score*=0.3 if movecheck
              end
            end
          elsif skill>=PBTrainerAI.mediumSkill
            score*=0.3 if checkAImoves([PBMoves::DEFOG,PBMoves::RAPIDSPIN],aimem)
          end
          if $fefieldeffect==15
            score*=2
          end
        else
          score*=0
        end
        if $fefieldeffect==19
          if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) || opponent.stages[PBStats::SPEED]>0 || !opponent.pbCanReduceStatStage?(PBStats::SPEED)
            score*=0
          else
            score+=15
            miniscore=100
            if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
              miniscore*=1.1
            end
            if opponent.pbNonActivePokemonCount==0 || (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) || opponent.effects[PBEffects::MeanLook]>0
              miniscore*=1.3
            end
            if opponent.stages[PBStats::SPEED]<0
              minimini = 5*opponent.stages[PBStats::SPEED]
              minimini+=100
              minimini/=100.0
              miniscore*=minimini
            end
            if attacker.pbNonActivePokemonCount==0
              miniscore*=0.5
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::COMPETITIVE) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
              miniscore*=0.1
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
              miniscore*=0.5
            end
            if attacker.pbHasMove?(:ELECTROBALL)
              miniscore*=1.5
            end
            if attacker.pbHasMove?(:GYROBALL)
              miniscore*=0.5
            end
            if (oppitemworks && opponent.item == PBItems::LAGGINGTAIL) || (oppitemworks && opponent.item == PBItems::IRONBALL)
              miniscore*=0.1
            end
            miniscore*=0.1 if checkAImoves([PBMoves::TRICKROOM],aimem) || @trickroom!=0
            miniscore*=1.3 if checkAImoves([PBMoves::ELECTROBALL],aimem)
            miniscore*=0.5 if checkAImoves([PBMoves::GYROBALL],aimem)
            miniscore/=100.0
            score*=miniscore
          end
        end
      when 0x154 # Electric Terrain
        sleepvar=false
        if aimem.length > 0
          for j in aimem
            sleepvar = true if j.function==0x03
          end
        end
        if @field.effects[PBEffects::Terrain]==0 && $fefieldeffect!=1 &&
          $fefieldeffect!=22 && $fefieldeffect!=35
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
            miniscore*=1.5
          end
          if attacker.pbHasType?(:ELECTRIC)
            miniscore*=1.5
          end
          elecvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:ELECTRIC)
              elecvar=true
            end
          end
          if elecvar
            miniscore*=2
          end
          if opponent.pbHasType?(:ELECTRIC)
            miniscore*=0.5
          end
          for m in attacker.moves
            if m.function==0x03
              miniscore*=0.5
              break
            end
          end
          if sleepvar
            miniscore*=2
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
          score*=miniscore
        else
          score*=0
        end
      when 0x155 # Grassy Terrain
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
        end
        if @field.effects[PBEffects::Terrain]==0 && $fefieldeffect!=2 &&
          $fefieldeffect!=22 && $fefieldeffect!=35
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.5
          end
          if attacker.pbHasType?(:FIRE)
            miniscore*=2
          end
          if firevar
            miniscore*=2
          end
          if opponent.pbHasType?(:FIRE)
            miniscore*=0.5
            if pbWeather!=PBWeather::RAINDANCE
              miniscore*=0.5
            end
            if attacker.pbHasType?(:GRASS)
              miniscore*=0.5
            end
          else
            if attacker.pbHasType?(:GRASS)
              miniscore*=2
            end
          end
          if grassvar
            miniscore*=2
          end
          miniscore*=0.5 if checkAIhealing(aimem)
          miniscore*=0.5 if checkAImoves([PBMoves::SLUDGEWAVE],aimem)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::GRASSPELT)
            miniscore*=1.5
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
          score*=miniscore
        else
          score*=0
        end
      when 0x156 # Misty Terrain
        fairyvar=false
        dragonvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FAIRY)
            fairyvar=true
          end
          if mon.hasType?(:DRAGON)
            dragonvar=true
          end
        end
        if @field.effects[PBEffects::Terrain]==0 && $fefieldeffect!=3 &&
          $fefieldeffect!=22 && $fefieldeffect!=35
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if fairyvar
            miniscore*=2
          end
          if !attacker.pbHasType?(:FAIRY) && opponent.pbHasType?(:DRAGON)
            miniscore*=2
          end
          if attacker.pbHasType?(:DRAGON)
            miniscore*=0.5
          end
          if opponent.pbHasType?(:FAIRY)
            miniscore*=0.5
          end
          if attacker.pbHasType?(:FAIRY) && opponent.spatk>opponent.attack
            miniscore*=2
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
          score*=miniscore
        else
          score*=0
        end
      when 0x15A # Sparkling Aria
        if opponent.status==PBStatuses::BURN
          score*=0.6
        end
      when 0x158 # Belch
        if attacker.effects[PBEffects::Belch]==false
          score*=0
        end
      when 0x159 # Toxic Thread
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
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::TOXICBOOST) || (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            miniscore*=0.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL) || (!opponent.abilitynulled && opponent.ability == PBAbilities::MAGICGUARD)
            miniscore*=0.1
          end
          miniscore*=0.2 if checkAImoves([PBMoves::FACADE],aimem)
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
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
          miniscore/=100.0
          score*=miniscore
        else
          score*=0.5
        end
        if opponent.stages[PBStats::SPEED]>0 || opponent.stages[PBStats::SPEED]==-6
          score*=0.5
        else
          miniscore=100
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.1
          end
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
          if livecount2==1 || (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) || opponent.effects[PBEffects::MeanLook]>0
            miniscore*=1.4
          end
          if opponent.stages[PBStats::SPEED]<0
            minimini = 5*opponent.stages[PBStats::SPEED]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if livecount1==1
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::COMPETITIVE) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
            miniscore*=0.1
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
            miniscore*=0.5
          end
          if attacker.pbHasMove?(:ELECTROBALL)
            miniscore*=1.5
          end
          if attacker.pbHasMove?(:GYROBALL)
            miniscore*=0.5
          end
          miniscore*=0.1 if  @trickroom!=0 || checkAImoves([PBMoves::TRICKROOM],aimem)
          if (oppitemworks && opponent.item == PBItems::LAGGINGTAIL) || (oppitemworks && opponent.item == PBItems::IRONBALL)
            miniscore*=0.1
          end
          miniscore*=1.3 if checkAImoves([PBMoves::ELECTROBALL],aimem)
          miniscore*=0.5 if checkAImoves([PBMoves::GYROBALL],aimem)
          if (attacker.pbSpeed>pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=0.5
          end
          miniscore/=100.0
          score*=miniscore
        end
      when 0x15B # Purify
        if opponent==attacker.pbPartner && opponent.status!=0
          score*=1.5
          if opponent.hp>opponent.totalhp*0.8
            score*=0.8
          else
            if opponent.hp>opponent.totalhp*0.3
              score*=2
            end
          end
          if opponent.effects[PBEffects::Toxic]>3
            score*=1.3
          end
          if opponent.pbHasMove?(:HEX)
            score*=1.3
          end
        else
          score*=0
        end
      when 0x15C # Gear Up
        if !((!attacker.abilitynulled && attacker.ability == PBAbilities::PLUS) || (!attacker.abilitynulled && attacker.ability == PBAbilities::MINUS) ||
           (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::PLUS) || (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MINUS))
          score*=0
        else
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::PLUS) || (!attacker.abilitynulled && attacker.ability == PBAbilities::MINUS)
            miniscore = setupminiscore(attacker,opponent,skill,move,true,5,false,initialscores,scoreindex)
            if opponent.stages[PBStats::SPEED]<0
              ministat = 5*opponent.stages[PBStats::SPEED]
              ministat+=100
              ministat/=100.0
              miniscore*=ministat
            end
            ministat=0
            ministat+=opponent.stages[PBStats::ATTACK]
            ministat+=opponent.stages[PBStats::SPEED]
            ministat+=opponent.stages[PBStats::SPATK]
            if ministat>0
              ministat*=(-5)
              ministat+=100
              ministat/=100.0
              miniscore*=ministat
            end
            score*=miniscore
            miniscore=100
            miniscore*=1.3 if checkAIhealing(aimem)
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              miniscore*=1.5
            end
            if roles.include?(PBMonRoles::SWEEPER)
              miniscore*=1.3
            end
            if attacker.status==PBStatuses::BURN
              miniscore*=0.5
            end
            if attacker.status==PBStatuses::PARALYSIS
              miniscore*=0.5
            end
            miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
            if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
               ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
               (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
               (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
              miniscore*=1.4
            end
            miniscore*=0.3 if checkAIpriority(aimem)
            physmove=false
            for j in attacker.moves
              if j.pbIsPhysical?(j.type)
                physmove=true
              end
            end
            specmove=false
            for j in attacker.moves
              if j.pbIsSpecial?(j.type)
                specmove=true
              end
            end
            if (!physmove || !attacker.pbTooHigh?(PBStats::ATTACK)) && (!specmove || !attacker.pbTooHigh?(PBStats::SPATK))
              miniscore/=100.0
              score*=miniscore
            end
          elsif @doublebattle && (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::PLUS) ||
             (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MINUS)
            if initialscores.length>0
              score*=1.3 if hasbadmoves(initialscores,scoreindex,20)
            end
            if attacker.pbPartner.hp>attacker.pbPartner.totalhp*0.75
              score*=1.1
            end
            if attacker.pbPartner.effects[PBEffects::Yawn]>0 || attacker.pbPartner.effects[PBEffects::LeechSeed]>=0 ||
               attacker.pbPartner.effects[PBEffects::Attract]>=0 || attacker.pbPartner.status!=0
              score*=0.3
            end
            if movecheck
              score*=0.3
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
              score*=0.5
            end
          else
            score*=0
          end
        end
      when 0x15D # Spectral Thief
        if opponent.effects[PBEffects::Substitute]>0
          score*=1.2
        end
        ministat= 10*statchangecounter(opponent,1,7)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          ministat*=(-1)
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
          ministat*=2
        end
        ministat+=100
        ministat/=100.0
        score*=ministat
      when 0x15E # Laser Focus
        if !(!opponent.abilitynulled && opponent.ability == PBAbilities::BATTLEARMOR) &&
           !(!opponent.abilitynulled && opponent.ability == PBAbilities::SHELLARMOR) &&
           attacker.effects[PBEffects::LaserFocus]==0
          miniscore = 100
          ministat=0
          ministat+=opponent.stages[PBStats::DEFENSE]
          ministat+=opponent.stages[PBStats::SPDEF]
          if ministat>0
            miniscore+= 10*ministat
          end
          ministat=0
          ministat+=attacker.stages[PBStats::ATTACK]
          ministat+=attacker.stages[PBStats::SPATK]
          if ministat>0
            miniscore+= 10*ministat
          end
          if attacker.effects[PBEffects::FocusEnergy]>0
            miniscore *= 0.8**attacker.effects[PBEffects::FocusEnergy]
          end
          miniscore/=100.0
          score*=miniscore
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::ANGERPOINT) && opponent.stages[PBStats::ATTACK] !=6
            score*=0.7
            if opponent.attack>opponent.spatk
              score*=0.2
            end
          end
        else
          score*=0
        end
      when 0x15F # Clanging Scales
        maxdam=0
        maxphys = false
        healvar=false
        privar=false
        if aimem.length > 0
          for j in aimem
            healvar=true if j.isHealingMove?
            privar=true if j.priority>0
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxphys = j.pbIsPhysical?(j.type)
            end
          end
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.5
        else
          if score<100
            score*=0.8
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.3
            else
              score*=1.2 if checkAIpriority(aimem)
            end
            score*=0.5 if checkAIhealing(aimem)
          end
          if initialscores.length>0
            score*=0.5 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          if opponent.pbNonActivePokemonCount!=0
            miniscore*=opponent.pbNonActivePokemonCount
            miniscore/=100.0
            miniscore*=0.05
            miniscore = 1-miniscore
            score*=miniscore
          end
          if attacker.pbNonActivePokemonCount==0 && opponent.pbNonActivePokemonCount!=0
            score*=0.7
          end
          if opponent.attack>opponent.spatk
            score*=0.7
          end
          score*=0.7 if checkAIbest(aimem,2,[],false,attacker,opponent,skill)
        end
      when 0x160 # Strength Sap
        if opponent.effects[PBEffects::Substitute]<=0
          if attacker.effects[PBEffects::HealBlock]>0
            score*=0
          else
            if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
              score*=3
              if skill>=PBTrainerAI.bestSkill
                if checkAIdamage(aimem,attacker,opponent,skill)*1.5 > attacker.hp
                  score*=1.5
                end
                if (attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
                  if checkAIdamage(aimem,attacker,opponent,skill)*2 > attacker.hp
                    score*=2
                  else
                    score*=0.2
                  end
                end
              end
            end
          end
          if opponent.pbHasMove?(:CALMMIND) || opponent.pbHasMove?(:WORKUP) ||
             opponent.pbHasMove?(:NASTYPLOT) || opponent.pbHasMove?(:TAILGLOW) ||
             opponent.pbHasMove?(:GROWTH) || opponent.pbHasMove?(:QUIVERDANCE)
            score*=0.7
          end
          if (attacker.hp.to_f)/attacker.totalhp<0.5
            score*=1.5
          else
            score*=0.5
          end
          if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
            score*=0.8
          end
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN || opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
            score*=1.3
            if opponent.effects[PBEffects::Toxic]>0
              score*=1.3
            end
          end
          score*=1.2 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
          if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
            score*=1.2
          end
          ministat = opponent.attack
          ministat/=(attacker.totalhp).to_f
          ministat+=0.5
          score*=ministat
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::LIQUIDOOZE)
            score*=0.2
          end
          if $fefieldeffect==15 || $fefieldeffect==8
            score*=1.3
          end
          if (attitemworks && attacker.item == PBItems::BIGROOT)
            score*=1.3
          end
          miniscore=100
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.3
          end
          count=-1
          party=pbParty(attacker.index)
          sweepvar=false
          for i in 0...party.length
            count+=1
            next if (count==attacker.pokemonIndex || party[i].nil?)
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::SWEEPER)
              sweepvar=true
            end
          end
          if sweepvar
            miniscore*=1.1
          end
          livecount2=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if livecount2==1 || (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) || opponent.effects[PBEffects::MeanLook]>0
            miniscore*=1.4
          end
          if opponent.status==PBStatuses::POISON
            miniscore*=1.2
          end
          if opponent.stages[PBStats::ATTACK]<0
            minimini = 5*opponent.stages[PBStats::ATTACK]
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if attacker.pbHasMove?(:FOULPLAY)
            miniscore*=0.5
          end
          if opponent.status==PBStatuses::BURN
            miniscore*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) || (!opponent.abilitynulled && opponent.ability == PBAbilities::COMPETITIVE)
            miniscore*=0.1
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT) || (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end
          miniscore/=100.0
          if attacker.stages[PBStats::ATTACK]!=6
            score*=miniscore
          end
        else
          score = 0
        end
      when 0x161 # Speed Swap
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore= (10)*opponent.stages[PBStats::SPEED]
          minimini= (-10)*attacker.stages[PBStats::SPEED]
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
        else
          score*=0
        end
      when 0x162 # Burn Up
        maxdam=0
        maxtype = -1
        healvar=false
        if aimem.length > 0
          for j in aimem
            healvar=true if j.isHealingMove?
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxtype = j.type
            end
          end
        end
        if !attacker.pbHasType?(:FIRE)
          score*=0
        else
          if score<100
            score*=0.9
            if healvar
              score*=0.5
            end
          end
          if initialscores.length>0
            score*=0.5 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          if opponent.pbNonActivePokemonCount!=0
            miniscore*=opponent.pbNonActivePokemonCount
            miniscore/=100.0
            miniscore*=0.05
            miniscore = 1-miniscore
            score*=miniscore
          end
          if attacker.pbNonActivePokemonCount==0 && opponent.pbNonActivePokemonCount!=0
            score*=0.7
          end
          effcheck = PBTypes.getCombinedEffectiveness(opponent.type1,(PBTypes::FIRE),(PBTypes::FIRE))
          if effcheck > 4
            score*=1.5
          else
            if effcheck<4
              score*=0.5
            end
          end
          effcheck = PBTypes.getCombinedEffectiveness(opponent.type2,(PBTypes::FIRE),(PBTypes::FIRE))
          if effcheck > 4
            score*=1.5
          else
            if effcheck<4
              score*=0.5
            end
          end
          if maxtype!=-1
            effcheck = PBTypes.getCombinedEffectiveness(maxtype,(PBTypes::FIRE),(PBTypes::FIRE))
            if effcheck > 4
              score*=1.5
            else
              if effcheck<4
                score*=0.5
              end
            end
          end
        end
      when 0x163 # Moongeist Beam
        damcount = 0
        firemove = false
        for m in attacker.moves
          if m.basedamage>0
            damcount+=1
            if m.type==(PBTypes::FIRE)
              firemove = true
            end
          end
        end
        if !opponent.moldbroken && !opponent.abilitynulled
          if opponent.ability == PBAbilities::SANDVEIL
            if pbWeather!=PBWeather::SANDSTORM
              score*=1.1
            end
          elsif opponent.ability == PBAbilities::VOLTABSORB || opponent.ability == PBAbilities::LIGHTNINGROD
            if move.type==(PBTypes::ELECTRIC)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::ELECTRIC),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif opponent.ability == PBAbilities::WATERABSORB || opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN
            if move.type==(PBTypes::WATER)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::WATER),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
            if opponent.ability == PBAbilities::DRYSKIN && firemove
              score*=0.5
            end
          elsif opponent.ability == PBAbilities::FLASHFIRE
            if move.type==(PBTypes::FIRE)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::FIRE),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif opponent.ability == PBAbilities::LEVITATE
            if move.type==(PBTypes::GROUND)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::GROUND),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif opponent.ability == PBAbilities::WONDERGUARD
            score*=5
          elsif opponent.ability == PBAbilities::SOUNDPROOF
            if move.isSoundBased?
              score*=3
            end
          elsif opponent.ability == PBAbilities::THICKFAT
            if move.type==(PBTypes::FIRE) || move.type==(PBTypes::ICE)
              score*=1.5
            end
          elsif opponent.ability == PBAbilities::MOLDBREAKER
            score*=1.1
          elsif opponent.ability == PBAbilities::UNAWARE
            score*=1.7
          elsif opponent.ability == PBAbilities::MULTISCALE
            if attacker.hp==attacker.totalhp
              score*=1.5
            end
          elsif opponent.ability == PBAbilities::SAPSIPPER
            if move.type==(PBTypes::GRASS)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::GRASS),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif opponent.ability == PBAbilities::SNOWCLOAK
            if pbWeather!=PBWeather::HAIL
              score*=1.1
            end
          elsif opponent.ability == PBAbilities::FURCOAT
            if attacker.attack>attacker.spatk
              score*=1.5
            end
          elsif opponent.ability == PBAbilities::FLUFFY
            score*=1.5
            if move.type==(PBTypes::FIRE)
              score*=0.5
            end
          elsif opponent.ability == PBAbilities::WATERBUBBLE
            score*=1.5
            if move.type==(PBTypes::FIRE)
              score*=1.3
            end
          end
        end
      when 0x164 # Photon Geyser
        damcount = 0
        firemove = false
        for m in attacker.moves
          if m.basedamage>0
            damcount+=1
            if m.type==(PBTypes::FIRE)
              firemove = true
            end
          end
        end
        if !opponent.moldbroken
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL)
            if pbWeather!=PBWeather::SANDSTORM
              score*=1.1
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::VOLTABSORB) || (!opponent.abilitynulled && opponent.ability == PBAbilities::LIGHTNINGROD)
            if move.type==(PBTypes::ELECTRIC)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::ELECTRIC),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::WATERABSORB) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::STORMDRAIN) ||
             (!opponent.abilitynulled && opponent.ability == PBAbilities::DRYSKIN)
            if move.type==(PBTypes::WATER)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::WATER),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::DRYSKIN) && firemove
              score*=0.5
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::FLASHFIRE)
            if move.type==(PBTypes::FIRE)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::FIRE),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::LEVITATE)
            if move.type==(PBTypes::GROUND)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::GROUND),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::WONDERGUARD)
            score*=5
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::SOUNDPROOF)
            if move.isSoundBased?
              score*=3
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::THICKFAT)
            if move.type==(PBTypes::FIRE) || move.type==(PBTypes::ICE)
              score*=1.5
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::MOLDBREAKER)
            score*=1.1
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            score*=1.7
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::MULTISCALE)
            if attacker.hp==attacker.totalhp
              score*=1.5
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::SAPSIPPER)
            if move.type==(PBTypes::GRASS)
              if damcount==1
                score*=3
              end
              if PBTypes.getCombinedEffectiveness((PBTypes::GRASS),opponent.type1,opponent.type2)>4
                score*=2
              end
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK)
            if pbWeather!=PBWeather::HAIL
              score*=1.1
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::FURCOAT)
            if attacker.attack>attacker.spatk
              score*=1.5
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::FLUFFY)
            score*=1.5
            if move.type==(PBTypes::FIRE)
              score*=0.5
            end
          elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::WATERBUBBLE)
            score*=1.5
            if move.type==(PBTypes::FIRE)
              score*=1.3
            end
          end
        end
      when 0x165 # Core Enforcer
        if !opponent.unstoppableAbility? && !opponent.effects[PBEffects::GastroAcid]
          miniscore = getAbilityDisruptScore(move,attacker,opponent,skill)
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            miniscore*=1.3
          else
            miniscore*=0.5
          end
          miniscore*=1.3 if checkAIpriority(aimem)
          score*=miniscore
        end
      when 0x166 # Stomping Tantrum
        if $fefieldeffect==5
          psyvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:PSYCHIC)
              psyvar=true
            end
          end
          if !attacker.pbHasType?(:PSYCHIC)
            score*=1.3
          end
          if !psyvar
            score*=1.8
          else
            score*=0.7
          end
        end
      when 0x167 # Aurora Veil
        if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]<=0
          if pbWeather==PBWeather::HAIL || (skill>=PBTrainerAI.bestSkill &&
             ($fefieldeffect==28 || $fefieldeffect==30 || $fefieldeffect==34 || $fefieldeffect==4 || $fefieldeffect==9 || $fefieldeffect==13 || $fefieldeffect==25))
            score*=1.5
            if attacker.pbOwnSide.effects[PBEffects::AuroraVeil]>0
              score*=0.1
            end
            if (attitemworks && attacker.item == PBItems::LIGHTCLAY)
              score*=1.5
            end
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.1
              score*=2 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp && (checkAIdamage(aimem,attacker,opponent,skill)/2.0)<attacker.hp
            end
            if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
               ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
               (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
               (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
              score*=1.3
            end
            score*=0.1 if checkAImoves([PBMoves::DEFOG,PBMoves::RAPIDSPIN],aimem)
            if skill>=PBTrainerAI.bestSkill
              if $fefieldeffect==30 # Mirror
                score*=1.5
              end
            end
          else
            score=0
          end
        else
          score=0
        end
      when 0x168 # Baneful Bunker
        if opponent.turncount==0
          score*=1.5
        end
        score*=0.3 if opponent.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SPEEDBOOST) && attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          score*=4
          #experimental -- cancels out drop if killing moves
          if initialscores.length>0
            score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          #end experimental
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON)) ||
           attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::AquaRing] || $fefieldeffect==2
          score*=1.2
        end
        if opponent.status!=0
          score*=0.8
        else
          if opponent.pbCanPoison?(false)
            score*=1.3
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::MERCILESS)
              score*=1.3
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL)
              score*=0.3
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::TOXICBOOST)
              score*=0.7
            end
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
        score*=0.1 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
        if attacker.effects[PBEffects::Wish]>0
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=3
          else
            score*=1.4
          end
        end
        if aimem.length > 0
          contactcheck=false
          for j in aimem
            contactcheck=j.isContactMove?
          end
          if contactcheck
            score*=1.3
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
      when 0x169 # Revelation Dance
      when 0x16A # Spotlight
        maxdam=0
        maxtype = -1
        contactcheck = false
        if aimem.length > 0
          for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxtype = j.type
              contactcheck = j.isContactMove?
            end
          end
        end
        if @doublebattle && opponent==attacker.pbPartner
          if !opponent.abilitynulled
            if opponent.ability == PBAbilities::FLASHFIRE
              score*=3 if checkAIbest(aimem,1,[PBTypes::FIRE],false,attacker,opponent,skill)
            elsif opponent.ability == PBAbilities::STORMDRAIN || opponent.ability == PBAbilities::DRYSKIN || opponent.ability == PBAbilities::WATERABSORB
              score*=3 if checkAIbest(aimem,1,[PBTypes::WATER],false,attacker,opponent,skill)
            elsif opponent.ability == PBAbilities::MOTORDRIVE || opponent.ability == PBAbilities::LIGHTNINGROD || opponent.ability == PBAbilities::VOLTABSORB
              score*=3 if checkAIbest(aimem,1,[PBTypes::ELECTRIC],false,attacker,opponent,skill)
            elsif opponent.ability == PBAbilities::SAPSIPPER
              score*=3 if checkAIbest(aimem,1,[PBTypes::GRASS],false,attacker,opponent,skill)
            end
          end
          if opponent.pbHasMove?(:KINGSSHIELD) || opponent.pbHasMove?(:BANEFULBUNKER) || opponent.pbHasMove?(:SPIKYSHIELD)
            if checkAIbest(aimem,4,[],false,attacker,opponent,skill)
              score*=2
            end
          end
          if opponent.pbHasMove?(:COUNTER) || opponent.pbHasMove?(:METALBURST) || opponent.pbHasMove?(:MIRRORCOAT)
            score*=2
          end
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.5
          end
          if (attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.5
          end
        else
          score=1
        end
      when 0x16B # Instruct
        if !@doublebattle || opponent!=attacker.pbPartner || opponent.lastMoveUsedSketch<=0
          score=1
        else
          score*=3
          #if @opponent.trainertype==PBTrainers::MIME
          #  score+=35
          #end
          if attacker.pbPartner.hp*2 < attacker.pbPartner.totalhp
            score*=0.5
          else
            if attacker.pbPartner.hp==attacker.pbPartner.totalhp
              score*=1.2
            end
          end
          if initialscores.length>0
            badmoves=true
            for i in 0...initialscores.length
              next if attacker.moves[i].basedamage<=0
              next if i==scoreindex
              if initialscores[i]>20
                badmoves=false
              end
            end
            score*=1.2 if badmoves
          end
          if ((attacker.pbPartner.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
             ((attacker.pbPartner.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
            score*=1.4
          end
          ministat = [attacker.pbPartner.attack,attacker.pbPartner.spatk].max
          minimini = [attacker.attack,attacker.spatk].max
          ministat-=minimini
          ministat+=100
          ministat/=100.0
          score*=ministat
          if attacker.pbPartner.hp==0
            score=1
          end
        end
      when 0x16C # Throat Chop
        maxdam=0
        maxsound = false
        soundcheck = false
        if aimem.length > 0
          for j in aimem
            soundcheck=true if j.isSoundBased?
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxsound = j.isSoundBased?
            end
          end
        end
        if maxsound
          score*=1.5
        else
          if soundcheck
            score*=1.3
          end
        end
      when 0x16D # Shore Up
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
        if attacker.status==PBStatuses::PARALYSIS || attacker.effects[PBEffects::Attract]>=0 || attacker.effects[PBEffects::Confusion]>0
          score*=1.1
        end
        if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN || opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
          score*=1.3
          if opponent.effects[PBEffects::Toxic]>0
            score*=1.3
          end
        end
        score*=1.2 if checkAImoves(PBStuff::CONTRARYBAITMOVE,aimem)
        if opponent.vanished || opponent.effects[PBEffects::HyperBeam]>0
          score*=1.2
        end
        if pbWeather==PBWeather::SANDSTORM
          score*=1.5
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==12 # Desert
            score*=1.3
          end
          if $fefieldeffect==20 # Ashen Beach
            score*=1.5
          end
          if $fefieldeffect==21 || $fefieldeffect==26 # (Murk)Water Surface
            if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
              score*=1.5
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
      when 0x16E # Floral Healing
        if !@doublebattle || attacker.pbIsOpposing?(opponent.index)
          score*=0
        else
          if !attacker.pbIsOpposing?(opponent.index)
            if opponent.hp*(1.0/opponent.totalhp)<0.7 && opponent.hp*(1.0/opponent.totalhp)>0.3
              score*=3
            end
            if opponent.hp*(1.0/opponent.totalhp)<0.3
              score*=1.7
            end
            if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN || opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
              score*=0.8
              if opponent.effects[PBEffects::Toxic]>0
                score*=0.7
              end
            end
            if opponent.hp*(1.0/opponent.totalhp)>0.8
              if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && ((attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
                score*=0.5
              else
                score*=0
              end
            end
          else
            score*=0
          end
        end
        if $fefieldeffect==2 || $fefieldeffect==31 || ($fefieldeffect==33 && $fecounter>1)
          score*=1.5
        end
        if attacker.status!=PBStatuses::POISON && ($fefieldeffect==10 || $fefieldeffect==11)
          score*=0.2
        end
      when 0x16F # Pollen Puff
        if opponent==attacker.pbPartner
          score = 15
          if opponent.hp>opponent.totalhp*0.3 && opponent.hp<opponent.totalhp*0.7
            score*=3
          end
          if opponent.hp*(1.0/opponent.totalhp)<0.3
            score*=1.7
          end
          if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN || opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Curse]
            score*=0.8
            if opponent.effects[PBEffects::Toxic]>0
              score*=0.7
            end
          end
          if opponent.hp*(1.0/opponent.totalhp)>0.8
            if ((attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && ((attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0))
              score*=0.5
            else
              score*=0
            end
          end
          if attacker.effects[PBEffects::HealBlock]>0 || opponent.effects[PBEffects::HealBlock]>0
            score*=0
          end
        end
      when 0x170 # Mind Blown
        startscore = score
        maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        if (!(!attacker.abilitynulled && attacker.ability == PBAbilities::MAGICGUARD) &&
           attacker.hp<attacker.totalhp*0.5) || (attacker.hp<attacker.totalhp*0.75 &&
           ((opponent.pbSpeed>attacker.pbSpeed) ^ (@trickroom!=0))) ||  $fefieldeffect==3 || $fefieldeffect==8 || pbCheckGlobalAbility(:DAMP)
          score*=0
          if !(!attacker.abilitynulled && attacker.ability == PBAbilities::MAGICGUARD)
            score*=0.7
            if startscore < 100
              score*=0.7
            end
            if (attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=0.5
            end
            if maxdam < attacker.totalhp*0.2
              score*=1.3
            end
            healcheck = false
            for m in attacker.moves
              healcheck=true if m.isHealingMove?
              break
            end
            if healcheck
              score*=1.2
            end
            if initialscores.length>0
              score*=1.3 if hasbadmoves(initialscores,scoreindex,25)
            end
            score*=0.5 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
            ministat=0
            ministat+=opponent.stages[PBStats::EVASION]
            minimini=(-10)*ministat
            minimini+=100
            minimini/=100.0
            score*=minimini
            ministat=0
            ministat+=attacker.stages[PBStats::ACCURACY]
            minimini=(10)*ministat
            minimini+=100
            minimini/=100.0
            score*=minimini
            if (oppitemworks && opponent.item == PBItems::LAXINCENSE) || (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER)
              score*=0.7
            end
            if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
               ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
              score*=0.7
            end
          else
            score*=1.1
          end
          firevar=false
          grassvar=false
          bugvar=false
          poisonvar=false
          icevar=false
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
            if mon.hasType?(:POISON)
              poisonvar=true
            end
            if mon.hasType?(:ICE)
              icevar=true
            end
          end
          if $fefieldeffect==2 || $fefieldeffect==15 || ($fefieldeffect==33 && $fecounter>1)
            if firevar && !bugvar && !grassvar
              score*=2
            end
          elsif $fefieldeffect==16
            if firevar
              score*=2
            end
          elsif $fefieldeffect==11
            if !poisonvar
              score*=1.2
            end
            if attacker.hp*5 < attacker.totalhp
              score*=2
            end
            if opponent.pbNonActivePokemonCount==0
              score*=5
            end
          elsif $fefieldeffect==13 || $fefieldeffect==28
            if !icevar
              score*=1.5
            end
          end
        end
      when 0x171 # Shell Trap
        maxdam=0
        specialvar = false
        if aimem.length > 0
        for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              if j.pbIsSpecial?(j.type)
                specialvar = true
              else
                specialvar = false
              end
            end
          end
        end
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.5
        end
        if attacker.hp==attacker.totalhp && (attitemworks && attacker.item == PBItems::FOCUSSASH)
          score*=1.2
        else
          score*=0.8
          score*=0.8 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
        end
        if attacker.lastMoveUsed==671
          score*=0.7
        end
        score*=0.6 if checkAImoves(PBStuff::SETUPMOVE,aimem)
        miniscore = attacker.hp*(1.0/attacker.totalhp)
        score*=miniscore
        if opponent.spatk > opponent.attack
          score*=0.3
        end
        score*=0.05 if checkAIbest(aimem,3,[],false,attacker,opponent,skill)
      when 0x172 # Beak Blast
        contactcheck = false
        if aimem.length > 0
          for j in aimem
            if j.isContactMove?
              contactcheck=true
            end
          end
        end
        if opponent.pbCanBurn?(false)
          miniscore=120
          ministat = 5*opponent.stages[PBStats::ATTACK]
          if ministat>0
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
          end
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.1 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::FLAREBOOST
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
            miniscore*=0.5 if opponent.ability == PBAbilities::MAGICGUARD
            miniscore*=0.3 if opponent.ability == PBAbilities::QUICKFEET
            miniscore*=1.1 if opponent.ability == PBAbilities::STURDY
          end
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          miniscore*=0.2 if checkAImoves([PBMoves::FACADE],aimem)
          if opponent.attack > opponent.spatk
            miniscore*=1.7
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          if startscore==110
            miniscore*=0.8
          end
          miniscore-=100
          minimini = 100
          if contactcheck
            minimini*=1.5
          else
            if opponent.attack>opponent.spatk
              minimini*=1.3
            else
              minimini*=0.3
            end
          end
          minimini/=100.0
          miniscore*=minimini
          miniscore+=100
          miniscore/=100.0
          score*=miniscore
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.7
        end
      when 0x173 # Psychic Terrain
        psyvar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:PSYCHIC)
            psyvar=true
          end
        end
        pricheck = false
        for m in attacker.moves
          if m.priority>0
            pricheck=true
            break
          end
        end
        if @field.effects[PBEffects::Terrain]==0 && $fefieldeffect!=22
          $fefieldeffect!=35 && $fefieldeffect!=37
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::TELEPATHY)
            miniscore*=1.5
          end
          if attacker.pbHasType?(:PSYCHIC)
            miniscore*=1.5
          end
          if psyvar
            miniscore*=2
          end
          if opponent.pbHasType?(:PSYCHIC)
            miniscore*=0.5
          end
          if pricheck
            miniscore*=0.7
          end
          miniscore*=1.3 if checkAIpriority(aimem)
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK)
            miniscore*=2
          end
          score*=miniscore
        else
          score*=0
        end
      when 0x174 # First Impression
        score = 0 if attacker.turncount!=0
        score *= 1.1 if score==110
    end
    return score
  end
end
