class PokeBattle_Battle
  alias __e__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    score = __e__pbGetMoveScoreFunctionCode(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                                            score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      when 0x100 # Rain Dance
        if pbCheckGlobalAbility(:AIRLOCK) ||
          pbCheckGlobalAbility(:CLOUDNINE) ||
          pbCheckGlobalAbility(:DELTASTREAM) ||
          pbCheckGlobalAbility(:DESOLATELAND) ||
          pbCheckGlobalAbility(:PRIMORDIALSEA) ||
          pbWeather==PBWeather::RAINDANCE
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
        if (attitemworks && attacker.item == PBItems::DAMPROCK)
          score*=1.3
        end
        if attacker.pbHasMove?(:WEATHERBALL) || (!attacker.abilitynulled && attacker.ability == PBAbilities::FORECAST)
          score*=2
        end
        if pbWeather!=0 && pbWeather!=PBWeather::RAINDANCE
          score*=1.3
        end
        if attacker.pbHasMove?(:THUNDER) || attacker.pbHasMove?(:HURRICANE)
          score*=1.5
        end
        if attacker.pbHasType?(:WATER)
          score*=1.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SWIFTSWIM)
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
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::DRYSKIN) || pbWeather==PBWeather::RAINDANCE
          score*=1.5
        end
        if pbWeather==PBWeather::SUNNYDAY
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if attacker.pbHasType?(:NORMAL)
            miniscore*=1.2
          end
          score*=miniscore
        end
        firevar=false
        for mon in pbParty(attacker.index)
          next if mon.nil?
          if mon.hasType?(:FIRE)
            firevar=true
          end
        end
        if firevar
          score*=0.5
        end
        if attacker.pbHasMove?(:MOONLIGHT) || attacker.pbHasMove?(:SYNTHESIS) ||
           attacker.pbHasMove?(:MORNINGSUN) || attacker.pbHasMove?(:GROWTH) ||
           attacker.pbHasMove?(:SOLARBEAM) || attacker.pbHasMove?(:SOLARBLADE)
          score*=0.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::HYDRATION)
          score*=1.5
        end
        if @opponent.is_a?(Array) == false
          if (@opponent.trainertype==PBTrainers::SHELLY || @opponent.trainertype==PBTrainers::BENNETTLAURA) && # Shelly / Laura
          ($fefieldeffect == 2 || $fefieldeffect == 15 || $fefieldeffect == 33)
            score *= 3.5
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==6 # Big Top
            score*=1.2
          end
          if $fefieldeffect==2 || $fefieldeffect==15 || $fefieldeffect==16 # Grassy/Forest/Superheated
            score*=1.5
          end
          if $fefieldeffect==7 || $fefieldeffect==33 # Burning/Flower Garden
            score*=2
          end
          if $fefieldeffect==34 # Starlight
            darkvar=false
            fairyvar=false
            psychicvar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:DARK)
                darkvar=true
              end
              if mon.hasType?(:FAIRY)
                fairyvar=true
              end
              if mon.hasType?(:PSYCHIC)
                psychicvar=true
              end
            end
            if !darkvar && !fairyvar && !psychicvar
              score*=2
            end
          end
          if $fefieldeffect==22 || $fefieldeffect==35 # Underwater or New World
            score*=0
          end
        end
      when 0x101 # Sandstorm
        if pbCheckGlobalAbility(:AIRLOCK) ||
          pbCheckGlobalAbility(:CLOUDNINE) ||
          pbCheckGlobalAbility(:DELTASTREAM) ||
          pbCheckGlobalAbility(:DESOLATELAND) ||
          pbCheckGlobalAbility(:PRIMORDIALSEA) ||
          pbWeather==PBWeather::SANDSTORM
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
        if (attitemworks && attacker.item == PBItems::SMOOTHROCK)
          score*=1.3
        end
        if attacker.pbHasMove?(:WEATHERBALL) || (!attacker.abilitynulled && attacker.ability == PBAbilities::FORECAST)
          score*=2
        end
        if pbWeather!=0 && pbWeather!=PBWeather::SANDSTORM
          score*=2
        end
        if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)
          score*=1.3
        else
          score*=0.7
        end
        if attacker.pbHasType?(:ROCK)
          score*=1.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SANDRUSH)
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
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SANDVEIL)
          score*=1.3
        end
        if attacker.pbHasMove?(:MOONLIGHT) || attacker.pbHasMove?(:SYNTHESIS) ||
           attacker.pbHasMove?(:MORNINGSUN) || attacker.pbHasMove?(:GROWTH) ||
           attacker.pbHasMove?(:SOLARBEAM) || attacker.pbHasMove?(:SOLARBLADE)
          score*=0.5
        end
        if attacker.pbHasMove?(:SHOREUP)
          score*=1.5
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SANDFORCE)
          score*=1.5
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==20 || $fefieldeffect==12 # Ashen Beach/Desert
            score*=1.3
          end
          if $fefieldeffect==9 # Rainbow
            score*=1.5
          end
          if $fefieldeffect==7 # Burning
            score*=3
          end
          if $fefieldeffect==34 # Starlight
            darkvar=false
            fairyvar=false
            psychicvar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:DARK)
                darkvar=true
              end
              if mon.hasType?(:FAIRY)
                fairyvar=true
              end
              if mon.hasType?(:PSYCHIC)
                psychicvar=true
              end
            end
            if !darkvar && !fairyvar && !psychicvar
              score*=2
            end
          end
          if $fefieldeffect==22 || $fefieldeffect==35 # Underwater or New World
            score*=0
          end
        end
      when 0x102 # Hail
        if pbCheckGlobalAbility(:AIRLOCK) ||
          pbCheckGlobalAbility(:CLOUDNINE) ||
          pbCheckGlobalAbility(:DELTASTREAM) ||
          pbCheckGlobalAbility(:DESOLATELAND) ||
          pbCheckGlobalAbility(:PRIMORDIALSEA) ||
          pbWeather==PBWeather::HAIL
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
        if (attitemworks && attacker.item == PBItems::ICYROCK)
          score*=1.3
        end
        if attacker.pbHasMove?(:WEATHERBALL) || (!attacker.abilitynulled && attacker.ability == PBAbilities::FORECAST)
          score*=2
        end
        if pbWeather!=0 && pbWeather!=PBWeather::HAIL
          score*=1.3
        end
        if attacker.pbHasType?(:ICE)
          score*=5
        else
          score*=0.7
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SLUSHRUSH)
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
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SNOWCLOAK) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::ICEBODY)
          score*=1.3
        end
        if attacker.pbHasMove?(:MOONLIGHT) || attacker.pbHasMove?(:SYNTHESIS) ||
           attacker.pbHasMove?(:MORNINGSUN) || attacker.pbHasMove?(:GROWTH) ||
           attacker.pbHasMove?(:SOLARBEAM) || attacker.pbHasMove?(:SOLARBLADE)
          score*=0.5
        end
        if attacker.pbHasMove?(:AURORAVEIL)
          score*=2
        end
        if attacker.pbHasMove?(:BLIZZARD)
          score*=1.3
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==13 || $fefieldeffect==28 # Icy/Snowy Mountain
            score*=1.2
          end
          if $fefieldeffect==9 || $fefieldeffect==27 # Rainbow/Mountian
            score*=1.5
          end
          if $fefieldeffect==16 # Superheated
            score*=0
          end
          if $fefieldeffect==34 # Starlight
            darkvar=false
            fairyvar=false
            psychicvar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:DARK)
                darkvar=true
              end
              if mon.hasType?(:FAIRY)
                fairyvar=true
              end
              if mon.hasType?(:PSYCHIC)
                psychicvar=true
              end
            end
            if !darkvar && !fairyvar && !psychicvar
              score*=2
            end
          end
          if $fefieldeffect==22 || $fefieldeffect==35 # Underwater or New World
            score*=0
          end
        end
      when 0x103 # Spikes
        if attacker.pbOpposingSide.effects[PBEffects::Spikes]!=3
          if roles.include?(PBMonRoles::LEAD)
            score*=1.1
          end
          if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
             (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
             (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=1.1
          end
          if attacker.turncount<2
            score*=1.2
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
          if livecount1>3
            miniscore=(livecount1-1)
            miniscore*=0.2
            score*=miniscore
          else
            score*=0.1
          end
          if attacker.pbOpposingSide.effects[PBEffects::Spikes]>0
            score*=0.9
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
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==21 || $fefieldeffect==26 # (Murk)Water Surface
              score*=0
            end
          end
        else
          score*=0
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==19 # Wasteland
            score = ((opponent.totalhp/3.0)/opponent.hp)*100
            score*=1.5 if @doublebattle
          end
        end
      when 0x104 # Toxic Spikes
        if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]!=2
          if roles.include?(PBMonRoles::LEAD)
            score*=1.1
          end
          if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
             (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
             (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=1.1
          end
          if attacker.turncount<2
            score*=1.2
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
          if livecount1>3
            miniscore=(livecount1-1)
            miniscore*=0.2
            score*=miniscore
          else
            score*=0.1
          end
          if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
            score*=0.9
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
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==21 || $fefieldeffect==26 # (Murk)Water Surface
              score*=0
            end
            if $fefieldeffect==10 # Corrosive
              score*=1.2
            end
          end
        else
          score*=0
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==19 # Wasteland
            score = ((opponent.totalhp*0.13)/opponent.hp)*100
            if opponent.pbCanPoison?(false)
              score*=1.5
            else
              score*=0
            end
            score*=1.5 if @doublebattle
            if opponent.hasType?(:POISON)
              score*=0
            end
          end
        end
      when 0x105 # Stealth Rock
        if !attacker.pbOpposingSide.effects[PBEffects::StealthRock]
          if roles.include?(PBMonRoles::LEAD)
            score*=1.1
          end
          if attacker.hp==attacker.totalhp &&
             (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
             (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
             (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
            score*=1.4
          end
          if attacker.turncount<2
            score*=1.3
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
          if livecount1>3
            miniscore=(livecount1-1)
            miniscore*=0.2
            score*=miniscore
          else
            score*=0.1
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
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect==23 || $fefieldeffect==14 # Cave/Rocky
              score*=2
            end
            if $fefieldeffect==25 # Crystal Cavern
              score*=1.3
            end
          end
        else
          score*=0
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==19 # Wasteland
            atype=(PBTypes::ROCK)
            score = ((opponent.totalhp/4.0)/opponent.hp)*100
            score*=2 if pbTypeModNoMessages(atype,attacker,opponent,move,skill)>4
            score*=1.5 if @doublebattle
          end
        end
      when 0x106 # Grass Pledge
        if $fepledgefield != 3
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if $fepledgefield!=1 && $fepledgefield!=2
            miniscore*=0.7
          else
            firevar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:FIRE)
                firevar=true
              end
            end
            if $fepledgefield==1
              if attacker.pbHasType?(:FIRE)
                miniscore*=1.4
              else
                miniscore*=0.3
              end
              if opponent.pbHasType?(:FIRE)
                miniscore*=0.3
              else
                miniscore*=1.4
              end
              if firevar
                miniscore*=1.4
              else
                miniscore*=1.3
              end
            end
          end
          score*=miniscore
        end
      when 0x107 # Fire Pledge
        firevar=false
        poisonvar=false
        bugvar=false
        grassvar=false
        icevar=false
        poisonvar=false
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
          if mon.hasType?(:POISON)
            poisonvar=true
          end
        end
        if $fepledgefield != 1
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if $fepledgefield!=3 && $fepledgefield!=2
            miniscore*=0.7
          else
            if $fepledgefield==3
              if attacker.pbHasType?(:FIRE)
                miniscore*=1.4
              else
                miniscore*=0.3
              end
              if opponent.pbHasType?(:FIRE)
                miniscore*=0.3
              else
                miniscore*=1.4
              end
              if firevar
                miniscore*=1.4
              else
                miniscore*=1.3
              end
            end
            if $fepledgefield==2
              miniscore*=1.2
              if attacker.pbHasType?(:NORMAL)
                miniscore*=1.2
              end
            end
          end
          score*=miniscore
        end
        if $fefieldeffect==2 || $fefieldeffect==15 || ($fefieldeffect==33 && $fecounter>1)
          if firevar && !(bugvar || grassvar)
            score*=2
          end
        elsif $fefieldeffect==16
          if firevar
            score*=2
          end
        elsif $fefieldeffect==11
          if !poisonvar
            score*=1.1
          end
          if attacker.hp*5<attacker.totalhp
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
      when 0x108 # Water Pledge
        if $fepledgefield != 2
          miniscore = getFieldDisruptScore(attacker,opponent,skill)
          if $fepledgefield!=1 && $fepledgefield!=3
            miniscore*=0.7
          else
            firevar=false
            for mon in pbParty(attacker.index)
              next if mon.nil?
              if mon.hasType?(:FIRE)
                firevar=true
              end
            end
            if $fepledgefield==1
              miniscore*=1.2
              if attacker.pbHasType?(:NORMAL)
                miniscore*=1.2
              end
            end
          end
          score*=miniscore
        end
        if $fefieldeffect==7
          if firevar
            score*=0
          else
            score*=2
          end
        end
      when 0x109 # Pay Day
      when 0x10A # Brick Break
        if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
          score*=1.8
        end
        if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
          score*=1.3
        end
        if attacker.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
          score*=2.0
        end
      when 0x10B # Hi Jump Kick
        if score < 100
          score *= 0.8
        end
        score*=0.5 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
        ministat=opponent.stages[PBStats::EVASION]
        ministat*=(-10)
        ministat+=100
        ministat/=100.0
        score*=ministat
        ministat=attacker.stages[PBStats::ACCURACY]
        ministat*=(10)
        ministat+=100
        ministat/=100.0
        score*=ministat
        if ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) || ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          score*=0.7
        end
        if (oppitemworks && opponent.item == PBItems::LAXINCENSE) || (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER)
          score*=0.7
        end
        if attacker.index != 2
          if skill>=PBTrainerAI.bestSkill
            if $fefieldeffect!=36
              ghostvar = false
              for mon in pbParty(opponent.index)
                next if mon.nil?
                ghostvar=true if mon.hasType?(:GHOST)
              end
              if ghostvar
                score*=0.5
              end
            end
          end
        end
      when 0x10C # Substitute
        if attacker.hp*4>attacker.totalhp
          if attacker.effects[PBEffects::Substitute]>0
            if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=0
            else
              if opponent.effects[PBEffects::LeechSeed]<0
                score*=0
              end
            end
          else
            if attacker.hp==attacker.totalhp
              score*=1.1
            else
              score*= (attacker.hp*(1.0/attacker.totalhp))
            end
            if opponent.effects[PBEffects::LeechSeed]>=0
              score*=1.2
            end
            if (attitemworks && attacker.item == PBItems::LEFTOVERS)
              score*=1.2
            end
            for j in attacker.moves
              if j.isHealingMove?
                score*=1.2
                break
              end
            end
            if opponent.pbHasMove?(:SPORE) || opponent.pbHasMove?(:SLEEPPOWDER)
              score*=1.2
            end
            if attacker.pbHasMove?(:FOCUSPUNCH)
              score*=1.5
            end
            if opponent.status==PBStatuses::SLEEP
              score*=1.5
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::INFILTRATOR)
              score*=0.3
            end
            if opponent.pbHasMove?(:UPROAR) || opponent.pbHasMove?(:HYPERVOICE) ||
               opponent.pbHasMove?(:ECHOEDVOICE) || opponent.pbHasMove?(:SNARL) ||
               opponent.pbHasMove?(:BUGBUZZ) || opponent.pbHasMove?(:BOOMBURST)
              score*=0.3
            end
            score*=2 if checkAIdamage(aimem,attacker,opponent,skill)*4<attacker.totalhp && (aimem.length > 0)
            if opponent.effects[PBEffects::Confusion]>0
              score*=1.3
            end
            if opponent.status==PBStatuses::PARALYSIS
              score*=1.3
            end
            if opponent.effects[PBEffects::Attract]>=0
              score*=1.3
            end
            if attacker.pbHasMove?(:BATONPASS)
              score*=1.2
            end
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SPEEDBOOST)
              score*=1.1
            end
            if @doublebattle
              score*=0.5
            end
          end
        else
          score*=0
        end
      when 0x10D # Curse
        if attacker.pbHasType?(:GHOST)
          if opponent.effects[PBEffects::Curse] || attacker.hp*2<attacker.totalhp
            score*=0
          else
            score*=0.7
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=0.5
            end
            if checkAIdamage(aimem,attacker,opponent,skill)*5 < attacker.hp && (aimem.length > 0)
              score*=1.3
            end
            for j in attacker.moves
              if j.isHealingMove?
                score*=1.2
                break
              end
            end
            ministat= 5*statchangecounter(opponent,1,7)
            ministat+=100
            ministat/=100.0
            score*=ministat
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
               (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
               opponent.effects[PBEffects::MeanLook]>=0 ||  opponent.pbNonActivePokemonCount==0
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
            if $fefieldeffect==29
              score*=0
            end
          end
        else
          miniscore=100
          if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
            miniscore*=1.3
          end
          if initialscores.length>0
            miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
          end
          if (attacker.hp.to_f)/attacker.totalhp>0.75
            miniscore*=1.2
          end
          if (attacker.hp.to_f)/attacker.totalhp<0.33
            miniscore*=0.3
          end
          if (attacker.hp.to_f)/attacker.totalhp<0.75 &&
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::EMERGENCYEXIT) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::WIMPOUT) ||
             (attitemworks && attacker.item == PBItems::EJECTBUTTON))
            miniscore*=0.3
          end
          if attacker.pbOpposingSide.effects[PBEffects::Retaliate]
            miniscore*=0.3
          end
          if opponent.effects[PBEffects::HyperBeam]>0
            miniscore*=1.3
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=1.7
          end
          if checkAIdamage(aimem,attacker,opponent,skill)<(attacker.hp/4.0) && (aimem.length > 0)
            miniscore*=1.2
          elsif checkAIdamage(aimem,attacker,opponent,skill)>(attacker.hp/2.0)
            miniscore*=0.3
          end
          if attacker.turncount<2
            miniscore*=1.1
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
            miniscore*=0.3
          end
          if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
            miniscore*=0.3
          end
          score*=0.3 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
            miniscore*=2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore*=0.5
          end
          if @doublebattle
            miniscore*=0.5
          end
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
          miniscore/=100.0
          score*=miniscore
          miniscore=100
          miniscore*=1.3 if checkAIhealing(aimem)
          if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
            miniscore*=0.5
          else
            miniscore*=1.1
          end
          if attacker.status==PBStatuses::BURN
            miniscore*=0.5
          end
          if attacker.status==PBStatuses::PARALYSIS
            miniscore*=0.5
          end
          miniscore*=0.8 if checkAImoves([PBMoves::FOULPLAY],aimem)
          physmove=false
          for j in attacker.moves
            if j.pbIsPhysical?(j.type)
              physmove=true
            end
          end
          if physmove && !attacker.pbTooHigh?(PBStats::ATTACK)
            miniscore/=100.0
            score*=miniscore
          end
          miniscore=100
          if attacker.effects[PBEffects::Toxic]>0
            miniscore*=0.2
          end
          if pbRoughStat(opponent,PBStats::SPATK,skill)<pbRoughStat(opponent,PBStats::ATTACK,skill)
            if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
              if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) && (attacker.hp.to_f)/attacker.totalhp>0.75
                miniscore*=1.3
              elsif (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
                miniscore*=0.7
              end
            end
            miniscore*=1.3
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.1
          end
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) || ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
            miniscore*=1.1
          end
          healmove=false
          for j in attacker.moves
            if j.isHealingMove?
              healmove=true
            end
          end
          if healmove
            miniscore*=1.2
          end
          if attacker.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
          end
          if attacker.pbHasMove?(:PAINSPLIT)
            miniscore*=1.2
          end
          if !attacker.pbTooHigh?(PBStats::DEFENSE)
            miniscore/=100.0
            score*=miniscore
          end
          if (opponent.level-5)>attacker.level
            score*=0.6
            if (opponent.level-10)>attacker.level
              score*=0.2
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            score=0
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=0.7
          end
          if attacker.pbTooHigh?(PBStats::DEFENSE) && attacker.pbTooHigh?(PBStats::ATTACK)
            score *= 0
          end
        end
      when 0x10E # Spite
        count=0
        for i in opponent.moves
          if i.basedamage>0
            count+=1
          end
        end
        lastmove = PBMove.new(opponent.lastMoveUsed)
        if lastmove.basedamage>0 && count==1
          score+=10
        end
        if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          score*=0.5
        end
        if lastmove.totalpp==5
          score*=1.5
        else
          if lastmove.totalpp==10
            score*=1.2
          else
            score*=0.7
          end
        end
      when 0x10F # Nightmare
        if !opponent.effects[PBEffects::Nightmare] && opponent.status==PBStatuses::SLEEP && opponent.effects[PBEffects::Substitute]<=0
          if opponent.statusCount>2
            score*=4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::EARLYBIRD)
            score*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::COMATOSE)
            score*=6
          end
          if initialscores.length>0
            score*=6 if hasbadmoves(initialscores,scoreindex,25)
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
            score*=0.5
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
             opponent.effects[PBEffects::MeanLook]>=0 ||  opponent.pbNonActivePokemonCount==0
            score*=1.3
          else
            score*=0.8
          end
          if @doublebattle
            score*=0.5
          end
          if $fefieldeffect==9
            score*=0
          end
        else
          score*=0
        end
      when 0x110 # Rapid Spin
        if attacker.effects[PBEffects::LeechSeed]>=0
          score+=20
        end
        if attacker.effects[PBEffects::MultiTurn]>0
          score+=10
        end
        if attacker.pbNonActivePokemonCount>0
          score+=25 if attacker.pbOwnSide.effects[PBEffects::StealthRock]
          score+=25 if attacker.pbOwnSide.effects[PBEffects::StickyWeb]
          score += (10*attacker.pbOwnSide.effects[PBEffects::Spikes])
          score += (15*attacker.pbOwnSide.effects[PBEffects::ToxicSpikes])
        end
      when 0x111 # Future Sight
        whichdummy = 0
        if move.id == 516
          whichdummy = 637
        elsif move.id == 450
          whichdummy = 636
        end
        dummydata = PBMove.new(whichdummy)
        dummymove = PokeBattle_Move.pbFromPBMove(self,dummydata,attacker)
        tempdam=pbRoughDamage(dummymove,attacker,opponent,skill,dummymove.basedamage)
        dummydam=(tempdam*100)/(opponent.hp.to_f)
        dummydam=110 if dummydam>110
        score = pbGetMoveScore(dummymove,attacker,opponent,skill,dummydam)
        if opponent.effects[PBEffects::FutureSight]>0
          score*=0
        else
          score*=0.6
          if @doublebattle
            score*=0.7
          end
          if attacker.pbNonActivePokemonCount==0
            score*=0.7
          end
          if attacker.effects[PBEffects::Substitute]>0
            score*=1.2
          end
          protectmove=false
          for j in attacker.moves
            protectmove = true if j.id==(PBMoves::PROTECT) || j.id==(PBMoves::DETECT) ||
                                  j.id==(PBMoves::BANEFULBUNKER) || j.id==(PBMoves::SPIKYSHIELD)
          end
          if protectmove
            score*=1.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=1.1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOODY) ||
             attacker.pbHasMove?(:QUIVERDANCE) ||
             attacker.pbHasMove?(:NASTYPLOT) ||
             attacker.pbHasMove?(:TAILGLOW)
            score*=1.2
          end
        end
      when 0x112 # Stockpile
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
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam<(attacker.hp/4.0) && (aimem.length > 0)
            miniscore*=1.1
          else
            if move.basedamage==0
              miniscore*=0.8
              if maxdam>attacker.hp
                miniscore*=0.1
              end
            end
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
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if (maxdam.to_f/attacker.hp)<0.12 && (aimem.length > 0)
            miniscore*=0.3
          end
        end
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
        if attacker.pbHasMove?(:SPITUP) || attacker.pbHasMove?(:SWALLOW)
          miniscore*=1.6
        end
        if attacker.effects[PBEffects::Stockpile]<3
          miniscore/=100.0
          score*=miniscore
        else
          score=0
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPDEF) && attacker.pbTooHigh?(PBStats::DEFENSE)
          score*=0
        end
      when 0x113 # Spit Up
        startscore = score
        if attacker.effects[PBEffects::Stockpile]==0
          score*=0
        else
          score*=0.8
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=0.7
          end
          if roles.include?(PBMonRoles::TANK)
            score*=0.9
          end
          count=0
          for m in attacker.moves
            count+=1 if m.basedamage>0
          end
          if count>1
            score*=0.5
          end
          if opponent.pbNonActivePokemonCount==0
            score*=0.7
          else
            score*=1.2
          end
          if startscore < 110
            score*=0.5
          else
            score*=1.3
          end
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.1
          else
            score*=0.8
          end
          if attacker.pbHasMove?(:SWALLOW)
            if attacker.hp/(attacker.totalhp.to_f) < 0.66
              score*=0.8
              if attacker.hp/(attacker.totalhp.to_f) < 0.4
                score*=0.5
              end
            end
          end
        end
      when 0x114 # Swallow
        startscore = score
        if attacker.effects[PBEffects::Stockpile]==0
          score*=0
        else
          score+= 10*attacker.effects[PBEffects::Stockpile]
          score*=0.8
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=0.9
          end
          if roles.include?(PBMonRoles::TANK)
            score*=0.9
          end
          count=0
          for m in attacker.moves
            count+=1 if m.isHealingMove?
          end
          if count>1
            score*=0.5
          end
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=1.1
          else
            score*=0.8
          end
          if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
            score*=2
          elsif checkAIdamage(aimem,attacker,opponent,skill)*1.5 > attacker.hp
            score*=1.5
          end
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if checkAIdamage(aimem,attacker,opponent,skill)*2 > attacker.hp
              score*=2
            else
              score*=0.2
            end
          end
          score*=0.7 if checkAImoves(PBStuff::SETUPMOVE,aimem)
          if attacker.hp*2 < attacker.totalhp
            score*=1.5
          end
          if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::POISON || attacker.effects[PBEffects::Curse] || attacker.effects[PBEffects::LeechSeed]>=0
            score*=1.3
            if attacker.effects[PBEffects::Toxic]>0
              score*=1.3
            end
          end
          if opponent.effects[PBEffects::HyperBeam]>0
            score*=1.2
          end
          if attacker.hp/(attacker.totalhp.to_f) > 0.8
            score*=0
          end
        end
      when 0x115 # Focus Punch
        startscore=score
        soundcheck=false
        multicheck=false
        if aimem.length > 0
          for j in aimem
            soundcheck=true if (j.isSoundBased? && j.basedamage>0)
            multicheck=true if j.pbNumHits(opponent)>1
          end
        end
        if attacker.effects[PBEffects::Substitute]>0
          if multicheck || soundcheck || (!opponent.abilitynulled && opponent.ability == PBAbilities::INFILTRATOR)
            score*=0.9
          else
            score*=1.3
          end
        else
          score *= 0.8
        end
        if opponent.status==PBStatuses::SLEEP && !(!opponent.abilitynulled && opponent.ability == PBAbilities::EARLYBIRD) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::SHEDSKIN)
          score*=1.2
        end
        if @doublebattle
          score *= 0.5
        end
        #if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) ^ @trickroom!=0
        #  score*=0.9
        #end
        if opponent.effects[PBEffects::HyperBeam]>0
          score*=1.5
        end
        if score<=startscore
          score*=0.3
        end
      when 0x116 # Sucker Punch
        knowncount = 0
        alldam = true
        if aimem.length > 0
          for j in aimem
            knowncount+=1
            if j.basedamage<=0
              alldam = false
            end
          end
        end
        if knowncount==4 && alldam
          score*=1.3
        else
          score*=0.6 if checkAIhealing(aimem)
          score*=0.8 if checkAImoves(PBStuff::SETUPMOVE,aimem)
          if attacker.lastMoveUsed==26 # Sucker Punch last turn
            check = rand(3)
            if check != 1
              score*=0.3
            end
            if checkAImoves(PBStuff::SETUPMOVE,aimem)
              score*=0.5
            end
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=0.8
            if initialscores.length>0
              test = initialscores[scoreindex]
              if initialscores.max!=test
                score*=0.6
              end
            end
          else
            if checkAIpriority(aimem)
              score*=0.5
            else
              score*=1.3
            end
          end
        end
      when 0x117 # Follow Me
        if @doublebattle && attacker.pbPartner.hp!=0
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=1.2
          end

          if (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MOODY)
            score*=1.3
          end
          if attacker.pbPartner.turncount<1
            score*=1.2
          else
            score*=0.8
          end
          if attacker.hp==attacker.totalhp
            score*=1.2
          else
            score*=0.8
            if attacker.hp*2 < attacker.totalhp
              score*=0.5
            end
          end
          if attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) || attacker.pbSpeed<pbRoughStat(opponent.pbPartner,PBStats::SPEED,skill)
            score*=1.2
          end
        else
          score*=0
        end
      when 0x118 # Gravity
        maxdam=0
        maxid = -1
        if aimem.length > 0
          for j in aimem
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)
            if tempdam>maxdam
              maxdam=tempdam
              maxid = j.id
            end
          end
        end
        if @field.effects[PBEffects::Gravity]>0
          score*=0
        else
          for i in attacker.moves
            if i.accuracy<=70
              score*=2
              break
            end
          end
          if attacker.pbHasMove?(:ZAPCANNON) || attacker.pbHasMove?(:INFERNO)
            score*=3
          end
          if maxid==(PBMoves::SKYDROP) || maxid==(PBMoves::BOUNCE) || maxid==(PBMoves::FLY) ||
             maxid==(PBMoves::JUMPKICK) || maxid==(PBMoves::FLYINGPRESS) ||
             maxid==(PBMoves::HIJUMPKICK) || maxid==(PBMoves::SPLASH)
            score*=2
          end
          for m in attacker.moves
            if m.id==(PBMoves::SKYDROP) || m.id==(PBMoves::BOUNCE) || m.id==(PBMoves::FLY) ||
               m.id==(PBMoves::JUMPKICK) || m.id==(PBMoves::FLYINGPRESS) ||
               m.id==(PBMoves::HIJUMPKICK) || m.id==(PBMoves::SPLASH)
              score*=0
              break
            end
          end
          if attacker.pbHasType?(:GROUND) &&
             (opponent.pbHasType?(:FLYING) || (!opponent.abilitynulled && opponent.ability == PBAbilities::LEVITATE) || (oppitemworks && opponent.item == PBItems::AIRBALLOON))
            score*=2
          end
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK) || $fefieldeffect==37
            score*=1.5
          end
          psyvar=false
          poisonvar=false
          fairyvar=false
          darkvar=false
          for mon in pbParty(attacker.index)
            next if mon.nil?
            if mon.hasType?(:PSYCHIC)
              psyvar=true
            end
            if mon.hasType?(:POISON)
              poisonvar=true
            end
            if mon.hasType?(:FAIRY)
              fairyvar=true
            end
            if mon.hasType?(:DARK)
              darkvar=true
            end
          end
          if $fefieldeffect==11
            if !attacker.pbHasType?(:POISON)
              score*=3
            else
              score*=0.5
            end
            if !poisonvar
              score*=3
            end
          elsif $fefieldeffect==21
            if attacker.pbHasType?(:WATER)
              score*=2
            else
              score*=0.5
            end
          elsif $fefieldeffect==35
            if !attacker.pbHasType?(:FLYING) && !(!attacker.abilitynulled && attacker.ability == PBAbilities::LEVITATE)
              score*=2
            end
            if opponent.pbHasType?(:FLYING) || (!opponent.abilitynulled && opponent.ability == PBAbilities::LEVITATE)
              score*=2
            end
            if psyvar || fairyvar || darkvar
              score*=2
              if attacker.pbHasType?(:PSYCHIC) || attacker.pbHasType?(:FAIRY) || attacker.pbHasType?(:DARK)
                score*=2
              end
            end
          end
        end
      when 0x119 # Magnet Rise
        if !(attacker.effects[PBEffects::MagnetRise]>0 || attacker.effects[PBEffects::Ingrain] || attacker.effects[PBEffects::SmackDown])
          if checkAIbest(aimem,1,[PBTypes::GROUND],false,attacker,opponent,skill)# Highest expected dam from a ground move
            score*=3
          end
          if opponent.pbHasType?(:GROUND)
            score*=3
          end
          if $fefieldeffect==1 || $fefieldeffect==17 || $fefieldeffect==18
            score*=1.3
          end
        else
          score*=0
        end
      when 0x11A # Telekinesis
        if !(opponent.effects[PBEffects::Telekinesis]>0 || opponent.effects[PBEffects::Ingrain] ||
           opponent.effects[PBEffects::SmackDown] || @field.effects[PBEffects::Gravity]>0 ||
           (oppitemworks && opponent.item == PBItems::IRONBALL) ||
           opponent.species==50 || opponent.species==51 || opponent.species==769 || opponent.species==770 || (opponent.species==94 && opponent.form==1))
          for i in attacker.moves
            if i.accuracy<=70
              score+=10
              break
            end
          end
          if attacker.pbHasMove?(:ZAPCANNON) || attacker.pbHasMove?(:INFERNO)
            score*=2
          end
          if $fefieldeffect==37
            if !(!opponent.abilitynulled && opponent.ability == PBAbilities::CLEARBODY) && !(!opponent.abilitynulled && opponent.ability == PBAbilities::WHITESMOKE)
              score+=15
              miniscore=100
              miniscore*=1.3 if checkAIhealing(aimem)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWTAG) ||
                 (!attacker.abilitynulled && attacker.ability == PBAbilities::ARENATRAP) ||
                 opponent.effects[PBEffects::MeanLook]>=0 ||  opponent.pbNonActivePokemonCount==0
                miniscore*=1.4
              end
              if opponent.status==PBStatuses::BURN || opponent.status==PBStatuses::POISON
                miniscore*=1.2
              end
              ministat= 5*statchangecounter(opponent,1,7,-1)
              ministat+=100
              ministat/=100.0
              miniscore*=ministat
              if attacker.pbNonActivePokemonCount==0
                miniscore*=0.5
              end
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::DEFIANT) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::COMPETITIVE) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
                miniscore*=0.1
              end
              if attacker.status!=0
                miniscore*=0.7
              end
              miniscore/=100.0
              score*=miniscore
            end
          end
        else
          score*=0
        end
      when 0x11B # Sky Uppercut
      when 0x11C # Smack Down
        if !(opponent.effects[PBEffects::Ingrain] ||
           opponent.effects[PBEffects::SmackDown] ||
           @field.effects[PBEffects::Gravity]>0 ||
           (oppitemworks && opponent.item == PBItems::IRONBALL)) && opponent.effects[PBEffects::Substitute]<=0
          miniscore=100
          if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            if opponent.pbHasMove?(:BOUNCE) || opponent.pbHasMove?(:FLY) || opponent.pbHasMove?(:SKYDROP)
              miniscore*=1.3
            else
              opponent.effects[PBEffects::TwoTurnAttack]!=0
              miniscore*=2
            end
          end
          groundmove = false
          for i in attacker.moves
            if i.type == 4
              groundmove = true
            end
          end
          if opponent.pbHasType?(:FLYING) || (!opponent.abilitynulled && opponent.ability == PBAbilities::LEVITATE)
            miniscore*=2
          end
          miniscore/=100.0
          score*=miniscore
        end
      when 0x11D # After You
      when 0x11E # Quash
      when 0x11F # Trick Room
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
        if !sweepvar
          score*=1.3
        end
        if roles.include?(PBMonRoles::TANK) || roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          score*=1.3
        end
        if roles.include?(PBMonRoles::LEAD)
          score*=1.5
        end
        if @doublebattle
          score*=1.3
        end
        if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK) || (attitemworks && attacker.item == PBItems::FOCUSSASH)
          score*=1.5
        end
        if skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==5 || $fefieldeffect==35 || $fefieldeffect==37 # Chess/New World/Psychic Terrain
            score*=1.5
          end
        end
        if attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill) || (attitemworks && attacker.item == PBItems::IRONBALL)
          if @trickroom > 0
            score*=0
          else
            score*=2
            #experimental -- cancels out drop if killing moves
            if initialscores.length>0
              score*=6 if hasgreatmoves(initialscores,scoreindex,skill)
            end
            #end experimental
          end
        else
          if @trickroom > 0
            score*=1.3
          else
            score*=0
          end
        end
      when 0x120 # Ally Switch
        if checkAIdamage(aimem,attacker,opponent,skill)<attacker.hp && attacker.pbNonActivePokemonCount!=0 && (aimem.length > 0)
          score*=1.3
          sweepvar = false
          for i in pbParty(attacker.index)
            next if i.nil?
            temprole = pbGetMonRole(i,opponent,skill,count,pbParty(attacker.index))
            if temprole.include?(PBMonRoles::SWEEPER)
              sweepvar = true
            end
          end
          if sweepvar
            score*=2
          end
          if attacker.pbNonActivePokemonCount<3
            score*=2
          end
          if attacker.pbOwnSide.effects[PBEffects::StealthRock] || attacker.pbOwnSide.effects[PBEffects::Spikes]>0
            score*=0.5
          end
        else
          score*=0
        end
      when 0x121 # Foul Play
      when 0x122 # Secret Sword
      when 0x123 # Synchonoise
        if !opponent.pbHasType?(attacker.type1) && !opponent.pbHasType?(attacker.type2)
          score*=0
        end
      when 0x124 # Wonder Room
        if @field.effects[PBEffects::WonderRoom]!=0
          score*=0
        else
          if (attitemworks && attacker.item == PBItems::AMPLIFIELDROCK) || $fefieldeffect==35 || $fefieldeffect==37
            score*=1.3
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            if attacker.defense>attacker.spdef
              score*=0.5
            else
              score*=2
            end
          else
            if attacker.defense<attacker.spdef
              score*=0.5
            else
              score*=2
            end
          end
          if attacker.attack>attacker.spatk
            if pbRoughStat(opponent,PBStats::DEFENSE,skill)>pbRoughStat(opponent,PBStats::SPDEF,skill)
              score*=2
            else
              score*=0.5
            end
          else
            if pbRoughStat(opponent,PBStats::DEFENSE,skill)<pbRoughStat(opponent,PBStats::SPDEF,skill)
              score*=2
            else
              score*=0.5
            end
          end
        end
      when 0x125 # Last Resort
        totalMoves = []
        for i in attacker.moves
          totalMoves[i.id] = false
          if i.function == 0x125
            totalMoves[i.id] = true
          end
          if i.id == 0
            totalMoves[i.id] = true
          end
        end
        for i in attacker.movesUsed
          for j in attacker.moves
            if i == j.id
              totalMoves[j.id] = true
            end
          end
        end
        for i in attacker.moves
          if !totalMoves[i.id]
            score=0
          end
        end
      when 0x126 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
      when 0x127 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if opponent.pbCanParalyze?(false)
          score*=1.3
          if skill>=PBTrainerAI.mediumSkill
            aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
            ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
            if aspeed<ospeed
              score*=1.3
            elsif aspeed>ospeed
              score*=0.6
            end
          end
          if skill>=PBTrainerAI.highSkill
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET)
          end
        end
      when 0x128 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if opponent.pbCanBurn?(false)
          score*=1.3
          if skill>=PBTrainerAI.highSkill
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::GUTS)
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::QUICKFEET)
            score*=0.6 if (!opponent.abilitynulled && opponent.ability == PBAbilities::FLAREBOOST)
          end
        end
      when 0x129 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if opponent.pbCanFreeze?(false)
          score*=1.3
          if skill>=PBTrainerAI.highSkill
            score*=0.8 if (!opponent.abilitynulled && opponent.ability == PBAbilities::MARVELSCALE)
          end
        end
      when 0x12A # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if opponent.pbCanConfuse?(false)
          score*=1.3
        else
          if skill>=PBTrainerAI.mediumSkill
            score*=0.1
          end
        end
      when 0x12B # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE)
          score*=0.1
        else
          score*=1.4 if attacker.turncount==0
          score+=opponent.stages[PBStats::DEFENSE]*20
        end
      when 0x12C # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if !opponent.pbCanReduceStatStage?(PBStats::EVASION)
          score*=0.1
        else
          score+=opponent.stages[PBStats::EVASION]*15
        end
      when 0x12D # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
      when 0x12E # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        score*=1.2 if opponent.hp>=(opponent.totalhp/2.0)
        score*=0.8 if attacker.hp<(attacker.hp/2.0)
      when 0x12F # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        score*=0 if opponent.effects[PBEffects::MeanLook]>=0
      when 0x130 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        score*=0.6
      when 0x131 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if pbCheckGlobalAbility(:AIRLOCK) ||
          pbCheckGlobalAbility(:CLOUDNINE)
          score*=0.1
        elsif pbWeather==PBWeather::SHADOWSKY
          score*=0.1
        end
      when 0x132 # Shadow Stuff
        score*=1.2 # Shadow moves are more preferable
        if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 ||
          opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
          opponent.pbOwnSide.effects[PBEffects::Safeguard]>0
          score*=1.3
          score*=0.1 if attacker.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                      attacker.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                      attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
        else
          score*=0
        end
      when 0x133 # Hold Hands
      when 0x134 # Celebrate
      when 0x137 # Magnetic Flux
        if !((!attacker.abilitynulled && attacker.ability == PBAbilities::PLUS) ||
           (!attacker.abilitynulled && attacker.ability == PBAbilities::MINUS) ||
           (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::PLUS) || (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MINUS))
          score*=0
        else
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::PLUS) || (!attacker.abilitynulled && attacker.ability == PBAbilities::MINUS)
            miniscore = setupminiscore(attacker,opponent,skill,move,false,10,true,initialscores,scoreindex)
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
          elsif @doublebattle && attacker.pbPartner.stages[PBStats::SPDEF]!=6 && attacker.pbPartner.stages[PBStats::DEFENSE]!=6
            score*=0.7
            if initialscores.length>0
              score*=1.3 if hasbadmoves(initialscores,scoreindex,20)
            end
            if attacker.pbPartner.hp >= attacker.pbPartner.totalhp*0.75
              score*=1.1
            end
            if attacker.pbPartner.effects[PBEffects::Yawn]>0 ||
               attacker.pbPartner.effects[PBEffects::LeechSeed]>=0 ||
               attacker.pbPartner.effects[PBEffects::Attract]>=0 ||
               attacker.pbPartner.status!=0
              score*=0.3
            end
            if movecheck
              score*=0.3
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
              score*=0.5
            end
            if attacker.pbPartner.hasWorkingItem(:LEFTOVERS) || (attacker.pbPartner.hasWorkingItem(:BLACKSLUDGE) && attacker.pbPartner.pbHasType?(:POISON))
              score*=1.2
            end
          else
            score*=0
          end
        end
      when 0x138 # Aromatic Mist
        newopp = attacker.pbOppositeOpposing
        movecheck = false
        if skill>=PBTrainerAI.bestSkill
          if @aiMoveMemory[2][newopp.pokemonIndex].length>0
            for j in @aiMoveMemory[2][newopp.pokemonIndex]
              movecheck=true if (PBStuff::PHASEMOVE).include?(j.id)
            end
          end
        elsif skill>=PBTrainerAI.mediumSkill
          movecheck=checkAImoves(PBStuff::PHASEMOVE,aimem)
        end
        if @doublebattle && opponent==attacker.pbPartner && opponent.stages[PBStats::SPDEF]!=6
          if newopp.spatk > newopp.attack
            score*=2
          else
            score*=0.5
          end
          if initialscores.length>0
            score*=1.3 if hasbadmoves(initialscores,scoreindex,20)
          end
          if opponent.hp*(1.0/opponent.totalhp)>0.75
            score*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0 ||
             opponent.effects[PBEffects::LeechSeed]>=0 ||
             opponent..effects[PBEffects::Attract]>=0 ||
             opponent.status!=0
            score*=0.3
          end
          if movecheck
            score*=0.2
          end
          if !opponent.abilitynulled && opponent.ability == PBAbilities::SIMPLE
            score*=2
          end
          if !newopp.abilitynulled && newopp.ability == PBAbilities::UNAWARE
            score*=0.5
          end
          if (oppitemworks && opponent.item == PBItems::LEFTOVERS) ||
             ((oppitemworks && opponent.item == PBItems::BLACKSLUDGE) && opponent.pbHasType?(:POISON))
            score*=1.2
          end
          if !opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY
            score*=0
          end
          if $fefieldeffect==3
            score*=2
          end
        else
          score*=0
        end
      when 0x13A # Noble Roar
        if (!opponent.pbCanReduceStatStage?(PBStats::ATTACK) &&
           !opponent.pbCanReduceStatStage?(PBStats::SPATK)) ||
           (opponent.stages[PBStats::ATTACK]==-6 && opponent.stages[PBStats::SPATK]==-6) ||
           (opponent.stages[PBStats::ATTACK]>0 && opponent.stages[PBStats::SPATK]>0)
          score*=0
        else
          miniscore=100
          ministat= 5*statchangecounter(opponent,1,7,-1)
          ministat+=100
          ministat/=100.0
          miniscore*=ministat
              if $fefieldeffect==31 || $fefieldeffect==32
            miniscore*=2
          end
          miniscore*= unsetupminiscore(attacker,opponent,skill,move,roles,1,false)
          miniscore/=100.0
          score*=miniscore
        end
      when 0x13B # Hyperspace Fury
        startscore = score
        if attacker.species==720 && attacker.form==1 # Hoopa-U
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
            if opponent.vanished && (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=3
            end
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            score*=1.7
          else
            if startscore<100
              score*=0.8
              if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
                score*=1.2
              else
                score*=0.8
              end
              score*=0.7 if checkAIhealing(aimem)
              if initialscores.length>0
                score*=0.5 if hasgreatmoves(initialscores,scoreindex,skill)
              end
              miniscore=100
              if opponent.pbNonActivePokemonCount!=0
                miniscore*=opponent.pbNonActivePokemonCount
                miniscore/=1000.0
                miniscore= 1-miniscore
                score*=miniscore
              end
              if opponent.pbNonActivePokemonCount!=0 && attacker.pbNonActivePokemonCount==0
                score*=0.7
              end
            end
          end
        else
          score*=0
        end
      when 0x13D # Eerie Impulse
        if (pbRoughStat(opponent,PBStats::SPATK,skill)<pbRoughStat(opponent,PBStats::ATTACK,skill)) || opponent.stages[PBStats::SPATK]>1 || !opponent.pbCanReduceStatStage?(PBStats::SPATK)
          if move.basedamage==0
            score=0
          end
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
      when 0x13E # Rototiller
        opp1 = attacker.pbOppositeOpposing
        opp2 = opp1.pbPartner
        if @doublebattle && opponent.pbHasType?(:GRASS) && opponent==attacker.pbPartner &&
           opponent.stages[PBStats::SPATK]!=6 && opponent.stages[PBStats::ATTACK]!=6
          if initialscores.length>0
            score*=1.3 if hasbadmoves(initialscores,scoreindex,20)
          end
          if (opponent.hp.to_f)/opponent.totalhp>0.75
            score*=1.1
          end
          if opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Attract]>=0 || opponent.status!=0 || opponent.effects[PBEffects::Yawn]>0
            score*=0.3
          end
          if movecheck
            score*=0.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SIMPLE)
            score*=2
          end
          if (!opp1.abilitynulled && opp1.ability == PBAbilities::UNAWARE)
            score*=0.5
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::CONTRARY)
            score*=0
          end
          if $fefieldeffect==33 && $fecounter!=4
            score+=30
          end
          if $fefieldeffect==33
            score+=20
            miniscore=100
            if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
              miniscore*=1.3
            end
            if initialscores.length>0
              miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
            end
            if (opponent.hp.to_f)/opponent.totalhp>0.75
              miniscore*=1.1
            end
            if opp1.effects[PBEffects::HyperBeam]>0
              miniscore*=1.2
            end
            if opp1.effects[PBEffects::Yawn]>0
              miniscore*=1.3
            end
            miniscore*=1.1 if checkAIdamage(aimem,attacker,opponent,skill) < opponent.hp*0.25 && (aimem.length > 0)
            if opponent.turncount<2
              miniscore*=1.1
            end
            if opp1.status!=0
              miniscore*=1.1
            end
            if opp1.status==PBStatuses::SLEEP || opp1.status==PBStatuses::FROZEN
              miniscore*=1.3
            end
            if opp1.effects[PBEffects::Encore]>0
              if opp1.moves[(opp1.effects[PBEffects::EncoreIndex])].basedamage==0
                miniscore*=1.5
              end
            end
            if opponent.effects[PBEffects::Confusion]>0
              miniscore*=0.2
            end
            if opponent.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
              miniscore*=0.6
            end
            miniscore*=0.5 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::SIMPLE)
              miniscore*=2
            end
            if (!opp1.abilitynulled && opp1.ability == PBAbilities::UNAWARE)
              miniscore*=0.5
            end
            if @doublebattle
              miniscore*=0.3
            end
            ministat=0
            ministat+=opponent.stages[PBStats::SPEED] if opponent.stages[PBStats::SPEED]<0
            ministat*=5
            ministat+=100
            ministat/=100.0
            miniscore*=ministat
            ministat=0
            ministat+=opponent.stages[PBStats::ATTACK]
            ministat+=opponent.stages[PBStats::SPEED]
            ministat+=opponent.stages[PBStats::SPATK]
            if ministat > 0
              ministat*=(-5)
              ministat+=100
              ministat/=100.0
              miniscore*=ministat
            end
            miniscore/=100.0
            score*=miniscore
            miniscore=100
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
            miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
            if attacker.hp==attacker.totalhp && (attitemworks && attacker.item == PBItems::FOCUSSASH)
              miniscore*=1.4
            end
            miniscore*=0.4 if checkAIpriority(aimem)
            if attacker.stages[PBStats::SPATK]!=6 && attacker.stages[PBStats::ATTACK]!=6
              score*=miniscore
            end
          end
        else
          score*=0
        end
      when 0x13F # Flower Shield
        opp1 = attacker.pbOppositeOpposing
        opp2 = opp1.pbPartner
        if @doublebattle && opponent.pbHasType?(:GRASS) && opponent==attacker.pbPartner && opponent.stages[PBStats::DEFENSE]!=6
          if $fefieldeffect!=33 || $fecounter==0
            if opp1.attack>opp1.spatk
              score*=2
            else
              score*=0.5
            end
            if opp2.attack>opp2.spatk
              score*=2
            else
              score*=0.5
            end
          else
            score*=2
          end
          if initialscores.length>0
            score*=1.3 if hasbadmoves(initialscores,scoreindex,20)
          end
          if (opponent.hp.to_f)/opponent.totalhp>0.75
            score*=1.1
          end
          if opponent.effects[PBEffects::LeechSeed]>=0 || opponent.effects[PBEffects::Attract]>=0 || opponent.status!=0 || opponent.effects[PBEffects::Yawn]>0
            score*=0.3
          end
          if movecheck
            score*=0.2
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SIMPLE)
            score*=2
          end
          if (!opp1.abilitynulled && opp1.ability == PBAbilities::UNAWARE)
            score*=0.5
          end
          if $fefieldeffect==33 && $fecounter!=4
            score+=30
          end
          if ($fefieldeffect==33 && $fecounter>0) || $fefieldeffect==31
            score+=20
            miniscore=100
            if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
              miniscore*=1.3
            end
            if initialscores.length>0
              miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
            end
            if (opponent.hp.to_f)/opponent.totalhp>0.75
              miniscore*=1.1
            end
            if opp1.effects[PBEffects::HyperBeam]>0
              miniscore*=1.2
            end
            if opp1.effects[PBEffects::Yawn]>0
              miniscore*=1.3
            end
            miniscore*=1.1 if checkAIdamage(aimem,attacker,opponent,skill) < opponent.hp*0.3 && (aimem.length > 0)
            if opponent.turncount<2
              miniscore*=1.1
            end
            if opp1.status!=0
              miniscore*=1.1
            end
            if opp1.status==PBStatuses::SLEEP || opp1.status==PBStatuses::FROZEN
              miniscore*=1.3
            end
            if opp1.effects[PBEffects::Encore]>0
              if opp1.moves[(opp1.effects[PBEffects::EncoreIndex])].basedamage==0
                miniscore*=1.5
              end
            end
            if opponent.effects[PBEffects::Confusion]>0
              miniscore*=0.5
            end
            if opponent.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
              miniscore*=0.3
            end
            if opponent.effects[PBEffects::Toxic]>0
              miniscore*=0.2
            end
            miniscore*=0.2 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::SIMPLE)
              miniscore*=2
            end
            if (!opp1.abilitynulled && opp1.ability == PBAbilities::UNAWARE)
              miniscore*=0.5
            end
            if @doublebattle
              miniscore*=0.3
            end
            miniscore*=0.3 if checkAIdamage(aimem,attacker,opponent,skill)<opponent.hp*0.12 && (aimem.length > 0)
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
        else
          score*=0
        end
    end
    return score
  end
end
