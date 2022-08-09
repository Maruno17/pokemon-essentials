class PokeBattle_Battle
  ##############################################################################
  # Get a score for each move being considered (trainer-owned Pokémon only).
  # Moves with higher scores are more likely to be chosen.
  ##############################################################################
  def pbGetMoveScoreFunctions(move,attacker,opponent,skill,roughdamage,initialscores,scoreindex,
                              score, oppitemworks, attitemworks, aimem, bettertype, roles, tempdam)
    case move.function
      #---------------------------------------------------------------------------
      when 0x00 # No extra effect

      #---------------------------------------------------------------------------
      when 0x01 # Splash

      #---------------------------------------------------------------------------
      when 0x02 # Struggle

      #---------------------------------------------------------------------------
      when 0x03 # Sleep
=begin
        if opponent.pbCanSleep?(false) && opponent.effects[PBEffects::Yawn]==0
=end
          miniscore=100
          # Prefer if attacker has setup moves (i.e. want to stall to get them set up)
          miniscore*=1.3 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          # Greatly don't prefer if opponent has used Sleep Talk/Snore in the past
          miniscore*=0.1 if checkAImoves([PBMoves::SLEEPTALK,PBMoves::SNORE],aimem)
          # Prefer if attacker doesn't have moves that'll damage more than 35% of opponent's current HP
          if initialscores.length>0
            miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,35)
          end
=begin
          # Inherently prefer this move
          miniscore*=1.3
          # Prefer if attacker has a move/ability that depends on opponent being asleep
          if attacker.pbHasMove?(:DREAMEATER) || attacker.pbHasMove?(:NIGHTMARE) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::BADDREAMS)
            miniscore*=1.5
          end
          # Prefer if attacker has certain roles
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::CLERIC) || roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          # Prefer if attacker knows Leech Seed (stall for time in which Leech Seed can sap more HP)
          if attacker.pbHasMove?(:LEECHSEED)
            miniscore*=1.3
          end
          # Prefer if attacker knows Substitute (another stall tactic)
          if attacker.pbHasMove?(:SUBSTITUTE)
            miniscore*=1.3
          end
          # Prefer if opponent is at full HP
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          # Prefer if opponent's stat stages are increased (don't want to give
          # opponent a chance to use their raised stat stages)
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          # Don't prefer if opponent's ability will cure sleep/give it back to attacker
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
          end
          # Prefer if attacker is faster than opponent
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
            miniscore*=1.3
          end
          # Prefer if attacker has EOR healing items (stall to give them more time to work)
          if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::POISONHEAL) && attacker.status==PBStatuses::POISON)
            miniscore*=1.2
          end
          # Don't prefer if opponent is confused (better to let it hurt itself in confusion)
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=0.6
          end
          # Don't prefer if opponent is infatuated (better to let it miss from infatuation(?))
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=0.7
          end
          # Discard if move is sound-based and opponent is immune to sound moves
          # (this is checked elsewhere and is redundant here)
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::SING)
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::SOUNDPROOF)
                miniscore=0
              end
            end
            if move.id==(PBMoves::GRASSWHISTLE)
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::SOUNDPROOF)
                miniscore=0
              end
            end
          end
          # Discard if move is powder-based and opponent is immune to powder moves
          # (this is checked elsewhere and is redundant here)
          if move.id==(PBMoves::SPORE)
            if (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES) ||
               (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) || opponent.pbHasType?(:GRASS)
              miniscore=0
            end
          end
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::SLEEPPOWDER)
              if (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) || opponent.pbHasType?(:GRASS)
                miniscore=0
              end
            end
          end
          # Discard if opponent will cure itself of sleep because of its ability
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            miniscore=0
          end
          # Discard Dark Void if attacker isn't Darkrai (ignores whether attacker is Transformed into Darkrai)
          if (move.id == PBMoves::DARKVOID) && !(attacker.species == PBSpecies::DARKRAI)
            score=0
          end
          # Apply above modifiers to score
          if move.basedamage>0
            miniscore-=100
            # Take additional effect chance into account
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          else
            miniscore/=100.0
            score*=miniscore
          end
        else
          # Discard status move if it won't have an effect/is superfluous because Yawn is whirring
          if move.basedamage==0
            score=0
          end
        end
=end

      #---------------------------------------------------------------------------
      when 0x04 # Yawn
        if opponent.effects[PBEffects::Yawn]<=0 && opponent.pbCanSleep?(false)
          # Prefer if attacker doesn't have moves that'll damage more than 30% of opponent's current HP
          if initialscores.length>0
            score*=1.3 if hasbadmoves(initialscores,scoreindex,30)
          end
=begin
          # Inherently prefer this move
          score*=1.2
          # Prefer if attacker has a move/ability that depends on opponent being asleep
          if attacker.pbHasMove?(:DREAMEATER) ||
            attacker.pbHasMove?(:NIGHTMARE) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::BADDREAMS)
            score*=1.4
          end
          # Prefer if attacker has certain roles
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::CLERIC) || roles.include?(PBMonRoles::PIVOT)
            score*=1.2
          end
          # Prefer if opponent is at full HP
          if opponent.hp==opponent.totalhp
            score*=1.2
          end
          # Prefer if opponent's stat stages are increased (don't want to give
          # opponent a chance to use their raised stat stages)
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            miniscore=10*ministat
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          end
          # Greatly don't prefer if opponent has used Sleep Talk/Snore in the past
          score*=0.1 if checkAImoves([PBMoves::SLEEPTALK,PBMoves::SNORE],aimem)
          # Don't prefer if opponent's ability will cure sleep
          if !opponent.abilitynulled
            score*=0.1 if opponent.ability == PBAbilities::NATURALCURE
            score*=0.8 if opponent.ability == PBAbilities::MARVELSCALE
          end
          # Don't prefer if opponent is confused (better to let it hurt itself in confusion)
          if opponent.effects[PBEffects::Confusion]>0
            score*=0.4
          end
          # Don't prefer if opponent is infatuated (better to let it miss from infatuation(?))
          if opponent.effects[PBEffects::Attract]>=0
            score*=0.5
          end
          # Discard if opponent will cure itself of sleep because of its ability
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            score=0
          end

        else
          # Discard if it won't have an effect
          score=0
=end
        end

      #---------------------------------------------------------------------------
      when 0x05 # Poison
        if opponent.pbCanPoison?(false)
          miniscore=100
          # Prefer if attacker doesn't have moves that'll damage more than 30% of opponent's current HP
          if initialscores.length>0
            miniscore*=1.2 if hasbadmoves(initialscores,scoreindex,30)
          end
=begin
          # Inherently prefer this move
          miniscore*=1.2
          # Prefer if attacker has certain roles
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.5
          end
          # Prefer if some of opponent's stat stages are increased (they'd lessen
          # damage taken, so poison damage is a better prospect)
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
          # Don't prefer if opponent's ability makes it immune to poisoning/benefit
          # from poisoning/will give it back to attacker
          # Prefer if damaging move and opponent has Sturdy
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.2 if opponent.ability == PBAbilities::TOXICBOOST || opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.1 if opponent.ability == PBAbilities::POISONHEAL || opponent.ability == PBAbilities::MAGICGUARD
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=1.1 if opponent.ability == PBAbilities::STURDY && move.basedamage>0
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0 && !attacker.pbHasType?(:POISON) && !attacker.pbHasType?(:STEEL)
          end
          # Discard if opponent will cure itself of poisoning because of its ability
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            miniscore=0
          end
          # Greatly don't prefer if opponent has used Facade or Rest in the past
          miniscore*=0.2 if checkAImoves([PBMoves::FACADE],aimem)
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          # Prefer if attacker knows a move that works better on a poisoned target,
          # or attacker has Merciless (guaranteed crits against poisoned targets)
          if attacker.pbHasMove?(:VENOSHOCK) ||
             attacker.pbHasMove?(:VENOMDRENCH) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::MERCILESS)
            miniscore*=1.6
          end
          # Don't prefer is opponent is yawning and will fall asleep
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          # Discard if move is powder-based and opponent is immune to powder moves
          # (this is checked elsewhere and is redundant here)
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::POISONPOWDER)
              if (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) || opponent.pbHasType?(:GRASS)
                miniscore=0
              end
            end
          end
          # Apply above modifiers to score
          if move.basedamage>0
            miniscore-=100
            # Take additional effect chance into account
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          else
            miniscore/=100.0
            score*=miniscore
          end

        else
          # Discard status move if it won't have an effect
          if move.basedamage<=0
            score=0
          end
=end
        end

      #---------------------------------------------------------------------------
      when 0x06 # Toxic
        if opponent.pbCanPoison?(false)
          miniscore=100
          # Greatly prefer if opponent has used a healing move in the past (because
          # toxic just keeps getting worse and will overwhelm healing effects)
          miniscore*=2 if checkAIhealing(aimem)
          # Prefer if attacker doesn't have moves that'll damage more than 30% of opponent's current HP
          if initialscores.length>0
            miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,30)
          end
=begin
          # Inherently prefer this move
          miniscore*=1.3
          # Prefer if attacker knows a move that works better on a poisoned target,
          # or attacker has Merciless (guaranteed crits against poisoned targets)
          if attacker.pbHasMove?(:VENOSHOCK) ||
             attacker.pbHasMove?(:VENOMDRENCH) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::MERCILESS)
            miniscore*=1.6
          end
          # Prefer if attacker has certain roles
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.6
          end
          # Prefer if attacker is Poison-type (because Toxic has infinite accuracy
          # when used by Poison-type users)
          if move.id==(PBMoves::TOXIC)
            if attacker.pbHasType?(:POISON)
              miniscore*=1.1
            end
          end
          # Prefer if some of opponent's stat stages are increased (they'd lessen
          # damage taken, so poison damage is a better prospect)
          ministat=0
          ministat+=opponent.stages[PBStats::DEFENSE]
          ministat+=opponent.stages[PBStats::SPDEF]
          ministat+=opponent.stages[PBStats::EVASION]
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
            PBDebug.log(sprintf("kll2")) if $INTERNAL
          end
          # Don't prefer is opponent is yawning and will fall asleep
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.1
          end
          # Greatly don't prefer if opponent has used Facade or Rest in the past
          miniscore*=0.3 if checkAImoves([PBMoves::FACADE],aimem)
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          # Don't prefer if opponent's ability makes it immune to poisoning/benefit
          # from poisoning/will give it back to attacker
          # Prefer if damaging move and opponent has Sturdy
          if !opponent.abilitynulled
            miniscore*=0.2 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.8 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.2 if opponent.ability == PBAbilities::TOXICBOOST || opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.1 if opponent.ability == PBAbilities::POISONHEAL || opponent.ability == PBAbilities::MAGICGUARD
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=1.1 if opponent.ability == PBAbilities::STURDY && move.basedamage>0
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0 && !attacker.pbHasType?(:POISON) && !attacker.pbHasType?(:STEEL)
          end
          # Discard if opponent will cure itself of poisoning because of its ability
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            miniscore=0
          end

          # Apply above modifiers to score
          if move.basedamage>0
            miniscore-=100
            # Take additional effect chance into account
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          else
            miniscore/=100.0
            score*=miniscore
          end

        else
          # Discard status move if it won't have an effect
          if move.basedamage<=0
            PBDebug.log(sprintf("KILL")) if $INTERNAL
            score=0
          end
=end
        end

      #---------------------------------------------------------------------------
      when 0x07 # Paralysis
=begin
        wavefail=false
        if move.id==(PBMoves::THUNDERWAVE)
          typemod=move.pbTypeModifier(move.type,attacker,opponent)
          if typemod==0
            wavefail=true
          end
        end
=end
        if opponent.pbCanParalyze?(false) #&& !wavefail
          miniscore=100
          # Prefer if attacker has setup moves (i.e. want to stall to get them set up)
          miniscore*=1.1 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          # Prefer if opponent's SpAtk is higher than its Atk - why?
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.1
          end
=begin
          # Prefer if attacker has certain roles
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.3
          end
          # Prefer if opponent is at full HP
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          # Prefer if opponent is confused (better to let it hurt itself in confusion)
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          # Prefer if opponent is infatuated (better to let it miss from infatuation(?))
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          # Prefer if some of opponent's stat stages are increased (they'd increase
          # the damage that opponent deals/speed opponent up, so paralysis is a better prospect)
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
          # Don't prefer is opponent is yawning and will fall asleep
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          # Don't prefer if opponent's ability makes it immune to paralysis/benefit
          # from paralysis/will give it back to attacker
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.5 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.2 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
          end
          # Discard if opponent will cure itself of poisoning because of its ability
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            miniscore=0
          end
          # Prefer if attacker is slower than opponent but will be faster if
          # opponent is paralysed
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2.0)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.5
          end
          # Prefer if any mon in attacker's party fills the sweeper role
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
          # Discard if move is powder-based and opponent is immune to powder moves
          # (this is checked elsewhere and is redundant here)
          if skill>=PBTrainerAI.bestSkill
            if move.id==(PBMoves::STUNSPORE)
              if (oppitemworks && opponent.item == PBItems::SAFETYGOGGLES) ||
                 (!opponent.abilitynulled && opponent.ability == PBAbilities::OVERCOAT) || opponent.pbHasType?(:GRASS)
                miniscore=0
              end
            end
          end
          # Apply above modifiers to score
          if move.basedamage>0
            miniscore-=100
            # Take additional effect chance into account
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
            miniscore/=100.0
            score*=miniscore
          else
            miniscore/=100.0
            score*=miniscore
          end

        else
          # Discard status move if it won't have an effect (can't paralyse or
          # opponent is immune to Thunder Wave)
          if move.basedamage==0
            score=0
          end
=end
        end

      #---------------------------------------------------------------------------
      when 0x08 # Thunder + Paralyze
        if opponent.pbCanParalyze?(false) && opponent.effects[PBEffects::Yawn]<=0
          miniscore=100
          miniscore*=1.1 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          # Why this?
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.1
          end
          if (pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed) ^ (@trickroom!=0)
            score*=1.2 if checkAImoves(PBStuff::TWOTURNAIRMOVE,aimem)
          end
=begin
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) ||
            roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.3
          end
          if opponent.hp==opponent.totalhp
            miniscore*=1.2
          end
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
#          if opponent.effects[PBEffects::Yawn]>0   # Impossible as Yawn is checked above
#            miniscore*=0.4
#          end
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
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.5 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.2 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
          end
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2.0)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.5
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
          invulmove=$pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0]
          if invulmove==0xC9 || invulmove==0xCC || invulmove==0xCE
            if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
              score*=2
            end
          end
=end
        end

      #---------------------------------------------------------------------------
      when 0x09 # Paralysis + Flinch
        if opponent.pbCanParalyze?(false)
          miniscore=100
          miniscore*=1.1 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          # Why this?
          if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
            miniscore*=1.1
          end
=begin
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL) ||
             roles.include?(PBMonRoles::PIVOT)
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::TANK)
            miniscore*=1.1
          end
          if opponent.hp==opponent.totalhp
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Confusion]>0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
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
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.5 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.2 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
          end
          if pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed &&
             (pbRoughStat(opponent,PBStats::SPEED,skill)/2)<attacker.pbSpeed && @trickroom==0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
            if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
              miniscore*=1.1
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STEADFAST)
              miniscore*=0.3
            end
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
=end
        end

      #---------------------------------------------------------------------------
      when 0x0A # Burn
=begin
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
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          miniscore*=0.3 if checkAImoves([PBMoves::FACADE],aimem)
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.1 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::FLAREBOOST
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
            miniscore*=0.5 if opponent.ability == PBAbilities::MAGICGUARD
            miniscore*=0.3 if opponent.ability == PBAbilities::QUICKFEET
            miniscore*=1.1 if opponent.ability == PBAbilities::STURDY && move.basedamage>0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE
            miniscore=0
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.4
          end
          if move.basedamage>0
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
          else
            miniscore/=100.0
            score*=miniscore
          end
        else
          if move.basedamage==0
            score=0
          end
        end
=end
      when 0x0B # Burn + Flinch
=begin
        if opponent.pbCanBurn?(false)
          miniscore=100
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
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.4
          end
          if opponent.effects[PBEffects::Yawn]>0
            miniscore*=0.4
          end
          miniscore*=0.1 if checkAImoves([PBMoves::REST],aimem)
          miniscore*=0.3 if checkAImoves([PBMoves::FACADE],aimem)
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.1 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::FLAREBOOST
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
            miniscore*=0.5 if opponent.ability == PBAbilities::MAGICGUARD
            miniscore*=0.3 if opponent.ability == PBAbilities::QUICKFEET
            miniscore*=1.1 if opponent.ability == PBAbilities::STURDY && move.basedamage>0
          end
          if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
            if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
              miniscore*=1.1
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STEADFAST)
              miniscore*=0.3
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
=end
      when 0x0C # Freeze
        if opponent.pbCanFreeze?(false)
          miniscore=100
          miniscore*=1.2 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          miniscore*=1.2 if checkAIhealing(aimem)
          miniscore*=0 if checkAImoves(PBStuff::UNFREEZEMOVE,aimem)
=begin
          miniscore*=1.2
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.8 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
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
=end
        end
      when 0x0D # Blizzard Freeze
        if opponent.pbCanFreeze?(false)
          miniscore=100
          miniscore*=1.3 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          miniscore*=1.2 if checkAIhealing(aimem)
          miniscore*=0 if checkAImoves(PBStuff::UNFREEZEMOVE,aimem)
=begin
          miniscore*=1.4
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.8 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
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
        #  if pbWeather == PBWeather::HAIL
        #    score*=1.3
        #  end
=end
        end
      when 0x0E # Freeze + Flinch
        if opponent.pbCanFreeze?(false)
          miniscore=100
          miniscore*=1.3 if attacker.moves.any? {|moveloop| (PBStuff::SETUPMOVE).include?(moveloop)}
          miniscore*=1.2 if checkAIhealing(aimem)
          miniscore*=0 if checkAImoves(PBStuff::UNFREEZEMOVE,aimem)
=begin
          miniscore*=1.1
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.8 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
          end
          if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
            if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
              miniscore*=1.1
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STEADFAST)
              miniscore*=0.3
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
=end
        end
      when 0x0F # Flinch
=begin
        if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed)  ^ (@trickroom!=0)
            miniscore=100
            miniscore*=1.3
            if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN ||
               (pbWeather == PBWeather::HAIL && !opponent.pbHasType?(:ICE)) ||
               (pbWeather == PBWeather::SANDSTORM && !opponent.pbHasType?(:ROCK) && !opponent.pbHasType?(:GROUND) && !opponent.pbHasType?(:STEEL)) ||
               opponent.effects[PBEffects::LeechSeed]>-1 || opponent.effects[PBEffects::Curse]
              miniscore*=1.1
              if opponent.effects[PBEffects::Toxic]>0
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
=end
      when 0x10 # Stomp
=begin
        if opponent.effects[PBEffects::Substitute]==0 && !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
            miniscore=100
            miniscore*=1.3
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
        score*=2 if opponent.effects[PBEffects::Minimize]
=end
      when 0x11 # Snore
=begin
        if attacker.status==PBStatuses::SLEEP
          score*=2
          if opponent.effects[PBEffects::Substitute]!=0
            score*=1.3
          end
          if !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS) &&
             ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0))
            miniscore=100
            miniscore*=1.3
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
        else
          score=0
        end
=end
      when 0x12 # Fake Out
        if attacker.turncount==0
          if opponent.effects[PBEffects::Substitute]==0 &&
             !(!opponent.abilitynulled && opponent.ability == PBAbilities::INNERFOCUS)
            score*=0.3 if checkAImoves([PBMoves::ENCORE],aimem)
=begin
            if score>1
              score+=115
            end
            if @doublebattle
              score*=0.7
            end
            if (attitemworks && attacker.item == PBItems::NORMALGEM)
              score*=1.1
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::UNBURDEN)
                score*=1.5
              end
            end
            if (!opponent.abilitynulled && opponent.ability == PBAbilities::STEADFAST)
              score*=0.3
            end
=end
          end
        else
=begin
          score=0
=end
        end
      when 0x13 # Confusion
        if opponent.pbCanConfuse?(false)
          miniscore=100
          if initialscores.length>0
            miniscore*=1.4 if hasbadmoves(initialscores,scoreindex,40)
          end
=begin
          miniscore*=1.2
          if attacker.pbHasMove?(:SUBSTITUTE)
            if attacker.effects[PBEffects::Substitute]>0
              miniscore*=1.3
            end
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.3
          end
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          if ministat>0
            minimini=10*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.2
          end
          if opponent.status==PBStatuses::PARALYSIS
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::TANGLEDFEET)
            miniscore*=0.7
          end
          if move.basedamage>0
            miniscore-=100
            if move.addlEffect.to_f != 100
              miniscore*=(move.addlEffect.to_f/100)
              if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
                miniscore*=2
              end
            end
            miniscore+=100
          end
          miniscore/=100.0
          score*=miniscore
        else
          if move.basedamage<=0
            score=0
          end
=end
        end
      when 0x14 # Chatter
        #This is no longer used, Chatter works off of the standard confusion
        #function code, 0x13
      when 0x15 # Hurricane
=begin
        if (pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed) ^ (@trickroom!=0)
          score*=1.2 if checkAImoves(PBStuff::TWOTURNAIRMOVE,aimem)
        end
        if opponent.pbCanConfuse?(false)
          miniscore=100
          miniscore*=1.2
          if attacker.pbHasMove?(:SUBSTITUTE)
            if attacker.effects[PBEffects::Substitute]>0
              miniscore*=1.3
            end
            miniscore*=1.2
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            miniscore*=1.3
          end
          ministat=0
          ministat+=opponent.stages[PBStats::ATTACK]
          if ministat>0
            minimini=10*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
            miniscore*=1.2
          end
          if opponent.status==PBStatuses::PARALYSIS
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Attract]>=0
            miniscore*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
            miniscore*=0.4
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::TANGLEDFEET)
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
        # Already accounted for elsewhere (can hit sky semi-invulnerable targets)
        invulmove=$pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move
        if invulmove==0xC9 || invulmove==0xCC || invulmove==0xCE
          if (pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)
            score*=2
          end
        end
=end
      when 0x16 # Attract
=begin
        canattract=true
        agender=attacker.gender
        ogender=opponent.gender
        if agender==2 || ogender==2 || agender==ogender # Pokemon are genderless or same gender
          canattract=false
        elsif opponent.effects[PBEffects::Attract]>=0
          canattract=false
        elsif (!opponent.abilitynulled && opponent.ability == PBAbilities::OBLIVIOUS)
          canattract=false
        elsif pbCheckSideAbility(:AROMAVEIL,opponent)!=nil && !(opponent.moldbroken)
          canattract = false
        end
        if canattract
          score*=1.2
          if attacker.pbHasMove?(:SUBSTITUTE)
            score*=1.2
            if attacker.effects[PBEffects::Substitute]>0
              score*=1.3
            end
          end
          if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
            score*=1.3
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CUTECHARM)
            score*=0.7
          end
          if opponent.status==PBStatuses::PARALYSIS
            score*=1.1
          end
          if opponent.effects[PBEffects::Confusion]>0
            score*=1.1
          end
          if opponent.effects[PBEffects::Yawn]>0 || opponent.status==PBStatuses::SLEEP
            score*=0.5
          end
          if (oppitemworks && opponent.item == PBItems::DESTINYKNOT)
            score*=0.1
          end
        else
          score=0
        end
=end
      when 0x17 # Tri Attack
=begin
        if opponent.status==0
          miniscore=100
          miniscore*=1.4
          ministat = statchangecounter(opponent,1,7)
          if ministat>0
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
          if !opponent.abilitynulled
            miniscore*=0.3 if opponent.ability == PBAbilities::NATURALCURE
            miniscore*=0.7 if opponent.ability == PBAbilities::MARVELSCALE
            miniscore*=0.3 if opponent.ability == PBAbilities::GUTS || opponent.ability == PBAbilities::QUICKFEET
            miniscore*=0.7 if opponent.ability == PBAbilities::SHEDSKIN
            miniscore*=0.5 if opponent.ability == PBAbilities::SYNCHRONIZE && attacker.status==0
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
=end
      when 0x18 # Refresh
        score*=1.3 if checkAImoves([PBMoves::HEX],aimem)
        score*=0.1 if checkAIdamage(aimem,attacker,opponent,skill)>attacker.hp
=begin
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::POISON || attacker.status==PBStatuses::PARALYSIS
          score*=3
        else
          score=0
        end
        if (attacker.hp.to_f)/attacker.totalhp>0.5
          score*=1.5
        else
          score*=0.3
        end
        if opponent.effects[PBEffects::Yawn]>0
          score*=0.1
        end
        if opponent.effects[PBEffects::Toxic]>2
          score*=1.3
        end
=end
      when 0x19 # Aromatherapy
        party=pbParty(attacker.index)
        statuses=0
        for i in 0...party.length
          statuses+=1 if party[i] && party[i].status!=0
        end
        if statuses!=0
          score*=1.1 if checkAIhealing(aimem)
=begin
          score*=1.2
          if attacker.status!=0
            score*=1.3
          end
          if attacker.effects[PBEffects::Toxic]>2
            score*=1.3
          end
          count=-1
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            if party[i].status==PBStatuses::SLEEP || party[i].status==PBStatuses::FROZEN
              score*=1.1
            end
            if party[i].attack>party[i].spatk && party[i].status==PBStatuses::BURN
              score*=1.2
            end
            if party[i].status==PBStatuses::POISON && (party[i].ability == PBAbilities::POISONHEAL)
              score*=0.5
            end
            if (party[i].ability == PBAbilities::GUTS) ||
               (party[i].ability == PBAbilities::QUICKFEET) || party[i].knowsMove?(:FACADE)
              score*=0.8
            end
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if (temproles.include?(PBMonRoles::PHYSICALWALL) ||
               temproles.include?(PBMonRoles::SPECIALWALL)) && party[i].status==PBStatuses::POISON
              score*=1.2
            end
            if temproles.include?(PBMonRoles::SWEEPER) && party[i].status==PBStatuses::PARALYSIS
              score*=1.2
            end
          end
        else
          score=0
=end
        end
      when 0x1A # Safeguard
        if attacker.pbOwnSide.effects[PBEffects::Safeguard]<=0 &&
           ((pbRoughStat(opponent,PBStats::SPEED,skill)<attacker.pbSpeed) ^ (@trickroom!=0)) &&
           attacker.status==0 && !roles.include?(PBMonRoles::STATUSABSORBER)
          score+=50 if checkAImoves([PBMoves::SPORE],aimem)
        end
      when 0x1B # Psycho Shift
        if attacker.status!=0 && opponent.effects[PBEffects::Substitute]<=0
=begin
          score*=1.3
          if attacker.pbHasMove?(:HEX)
            score*=1.3
          end
=end
          if opponent.status==0 && opponent.effects[PBEffects::Yawn]==0
            score*=0.7 if checkAImoves([PBMoves::HEX],aimem)
=begin
            score*=1.3
            if attacker.status==PBStatuses::BURN && opponent.pbCanBurn?(false)
              if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
                score*=1.2
              end
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::FLAREBOOST)
                score*=0.7
              end
            end
            if attacker.status==PBStatuses::PARALYSIS && opponent.pbCanParalyze?(false)
              if pbRoughStat(opponent,PBStats::ATTACK,skill)<pbRoughStat(opponent,PBStats::SPATK,skill)
                score*=1.1
              end
              if (pbRoughStat(opponent,PBStats::SPEED,skill)>attacker.pbSpeed) ^ (@trickroom!=0)
                score*=1.2
              end
            end
            if attacker.status==PBStatuses::POISON && opponent.pbCanPoison?(false)
              score*=1.1 if checkAIhealing(aimem)
              if attacker.effects[PBEffects::Toxic]>0
                score*=1.4
              end
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::POISONHEAL)
                score*=0.3
              end
              if (!opponent.abilitynulled && opponent.ability == PBAbilities::TOXICBOOST)
                score*=0.7
              end
            end
            if !opponent.abilitynulled && (opponent.ability == PBAbilities::SHEDSKIN ||
               opponent.ability == PBAbilities::NATURALCURE ||
               opponent.ability == PBAbilities::GUTS ||
               opponent.ability == PBAbilities::QUICKFEET ||
               opponent.ability == PBAbilities::MARVELSCALE)
              score*=0.7
            end
=end
          end
=begin
        else
          score=0
=end
        end
      when 0x1C # Howl
        miniscore = setupminiscore(attacker,opponent,skill,move,true,1,false,initialscores,scoreindex)
        miniscore*=1.3 if checkAIhealing(aimem)
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
=begin
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
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        if move.basedamage>0
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0

          if attacker.pbTooHigh?(PBStats::ATTACK)
            miniscore=1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end

        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::ATTACK)
            miniscore=0
          end
=end
          miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        if move.basedamage==0
          physmove=false
          for j in attacker.moves
            if j.pbIsPhysical?(j.type)
              physmove=true
            end
          end
          score=0 if !physmove
        end
=end
      when 0x1D # Harden
        miniscore = setupminiscore(attacker,opponent,skill,move,false,2,false,initialscores,scoreindex)
        if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
          miniscore*=1.3
        end
        if skill>=PBTrainerAI.mediumSkill
          miniscore*=0.3 if (checkAIdamage(aimem,attacker,opponent,skill).to_f/attacker.hp)<0.12 && (aimem.length > 0)
        end
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
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
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if attacker.stages[PBStats::DEFENSE]>0
          ministat=attacker.stages[PBStats::DEFENSE]
          minimini=-15*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if move.basedamage>0
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
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::DEFENSE)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end

          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
=end
      when 0x1E # Defense Curl
        miniscore = setupminiscore(attacker,opponent,skill,move,false,2,false,initialscores,scoreindex)
        if pbRoughStat(opponent,PBStats::ATTACK,skill)>pbRoughStat(opponent,PBStats::SPATK,skill)
          miniscore*=1.3
        end
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if (maxdam.to_f/attacker.hp)<0.12 && (aimem.length > 0)
            miniscore*=0.3
          end
        end
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          miniscore*=1.2
        end
        for j in attacker.moves
          if j.isHealingMove?
            healmove=true
          end
        end
        if healmove
          miniscore*=1.3
        end
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if attacker.pbHasMove?(:ROLLOUT) && attacker.effects[PBEffects::DefenseCurl]==false
          score*=1.3
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if attacker.stages[PBStats::DEFENSE]>0
          ministat=attacker.stages[PBStats::DEFENSE]
          minimini=-15*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        healmove=false
        if move.basedamage>0
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
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::DEFENSE)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
=end
      when 0x1F # Flame Charge
        miniscore = setupminiscore(attacker,opponent,skill,move,true,16,false,initialscores,scoreindex)
        if @trickroom!=0 || checkAImoves([PBMoves::TRICKROOM],aimem)
          miniscore*=0.2
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
        if attacker.attack<attacker.spatk
          if attacker.stages[PBStats::SPATK]<0
            ministat=attacker.stages[PBStats::SPATK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        else
          if attacker.stages[PBStats::ATTACK]<0
            ministat=attacker.stages[PBStats::ATTACK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        end
        ministat=0
        ministat+=opponent.stages[PBStats::DEFENSE]
        ministat+=opponent.stages[PBStats::SPDEF]
        if ministat>0
          minimini=(-5)*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.2
        end
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        if move.basedamage>0
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPEED)
            miniscore=1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end
        else
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
            miniscore*=0.6
          end
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPEED)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
=end
        end
      when 0x20 # Charge Beam
        miniscore = setupminiscore(attacker,opponent,skill,move,true,4,false,initialscores,scoreindex)
        # Why?
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=1.3 if checkAIhealing(aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
        if move.basedamage==0
          specmove=false
          for j in attacker.moves
            if j.pbIsSpecial?(j.type)
              specmove=true
            end
          end
          score=0 if !specmove
        end
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
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
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        end
        if move.basedamage>0
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPATK)
            miniscore=1
          end
          if miniscore<1
            miniscore = 1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPATK)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
=end
      when 0x21 # Charge
        miniscore = setupminiscore(attacker,opponent,skill,move,false,8,false,initialscores,scoreindex)
        if pbRoughStat(opponent,PBStats::ATTACK,skill)<pbRoughStat(opponent,PBStats::SPATK,skill)
          miniscore*=1.1
        end
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if (maxdam.to_f/attacker.hp)<0.12 && (aimem.length > 0)
            miniscore*=0.3
          end
        end
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
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
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        elecmove=false
        for j in attacker.moves
          if j.type==13 # Move is Electric
            if j.basedamage>0
              elecmove=true
            end
          end
        end
        if elecmove==true && attacker.effects[PBEffects::Charge]==0
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if attacker.stages[PBStats::SPDEF]>0
          ministat=attacker.stages[PBStats::SPDEF]
          minimini=-15*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if move.basedamage>0
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPDEF)
            miniscore=1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::SPDEF)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=miniscore
=end
      when 0x22 # Double Team
        miniscore = setupminiscore(attacker,opponent,skill,move,false,0,false,initialscores,scoreindex)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) || checkAIaccuracy(aimem)
          miniscore*=0.2
        end
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
=begin
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          miniscore*=1.2
        end
        if (attitemworks && attacker.item == PBItems::BRIGHTPOWDER) || (attitemworks && attacker.item == PBItems::LAXINCENSE) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          miniscore*=1.3
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
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.3
        end
        if move.basedamage>0
          miniscore-=100
          if move.addlEffect.to_f != 100
            miniscore*=(move.addlEffect.to_f/100)
            if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
              miniscore*=2
            end
          end
          miniscore+=100
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::EVASION)
            miniscore=1
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0.5
          end
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::EVASION)
            miniscore=0
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
=end
      when 0x23 # Focus Energy
        if attacker.effects[PBEffects::FocusEnergy]!=2
          score*=1.2 if (attacker.hp/4.0)>checkAIdamage(aimem,attacker,opponent,skill) && (aimem.length > 0)
          score*=0.5 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
=begin
          if (attacker.hp.to_f)/attacker.totalhp>0.75
            score*=1.2
          end
          if (attacker.hp.to_f)/attacker.totalhp<0.33
            score*=0.3
          end
          if attacker.turncount<2
            score*=1.2
          end
          if !attacker.abilitynulled && (attacker.ability == PBAbilities::SUPERLUCK || attacker.ability == PBAbilities::SNIPER)
            score*=2
          end
          if attitemworks && (attacker.item == PBItems::SCOPELENS ||
             attacker.item == PBItems::RAZORCLAW ||
             (attacker.item == PBItems::STICK && attacker.species==83) ||
             (attacker.item == PBItems::LUCKYPUNCH && attacker.species==113))
            score*=1.2
          end
          if (attitemworks && attacker.item == PBItems::LANSATBERRY)
            score*=1.3
          end
          for j in attacker.moves
            if j.hasHighCriticalRate?
              score*=2
            end
          end
          if attacker.effects[PBEffects::Confusion]>0
            score*=0.2
          end
          if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
            score*=0.6
          end
          if (attacker.hp.to_f)/attacker.totalhp<0.75 &&
             ((!attacker.abilitynulled && attacker.ability == PBAbilities::EMERGENCYEXIT) ||
             (!attacker.abilitynulled && attacker.ability == PBAbilities::WIMPOUT) ||
             (attitemworks && attacker.item == PBItems::EJECTBUTTON))
            score*=0.3
          end
          if attacker.pbHasMove?(:LASERFOCUS) ||
             attacker.pbHasMove?(:FROSTBREATH) ||
             attacker.pbHasMove?(:STORMTHROW)
            score*=0.5
          end
          if opponent.status!=0
            score*=1.2
          end
          if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
            score*=1.3
          end
          if opponent.effects[PBEffects::Yawn]>0
            score*=1.7
          end
          if opponent.effects[PBEffects::HyperBeam]>0
            score*=1.3
          end
          if opponent.effects[PBEffects::Encore]>0
            if opponent.moves[(opponent.effects[PBEffects::EncoreIndex])].basedamage==0
              score*=1.5
            end
          end
          if !opponent.abilitynulled && (opponent.ability == PBAbilities::ANGERPOINT ||
             opponent.ability == PBAbilities::SHELLARMOR || opponent.ability == PBAbilities::BATTLEARMOR)
            score*=0.2
          end
          if (opponent.level-5)>attacker.level
            score*=0.6
            if (opponent.level-10)>attacker.level
              score*=0.2
            end
          end
          if attacker.pbOpposingSide.effects[PBEffects::Retaliate]
            score*=0.3
          end
          if @doublebattle
            score*=0.5
          end
        else
          score=0
=end
      end
      when 0x24 # Bulk Up
        miniscore=100
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
=begin
        if attacker.pbTooHigh?(PBStats::ATTACK) && attacker.pbTooHigh?(PBStats::DEFENSE)
          score*=0
        end
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
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        miniscore = setupminiscore(attacker,opponent,skill,move,true,3,false,initialscores,scoreindex)
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
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
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.2
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
          miniscore*=1.2
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        if attacker.effects[PBEffects::Toxic]>0
          miniscore*=0.2
        end
        if attacker.stages[PBStats::SPEED]<0
          ministat=attacker.stages[PBStats::SPEED]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        miniscore*=1.3 if checkAIhealing(aimem)
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
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        if !attacker.pbTooHigh?(PBStats::DEFENSE)
          miniscore/=100.0
          score*=miniscore
        end
        miniscore=100
=end
      when 0x25 # Coil
        miniscore*=1.3 if checkAIhealing(aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
        if pbRoughStat(opponent,PBStats::SPATK,skill)<pbRoughStat(opponent,PBStats::ATTACK,skill)
          if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
            if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
               (attacker.hp.to_f)/attacker.totalhp>0.75
              miniscore*=1.1
            elsif (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              miniscore*=0.7
            end
          end
          miniscore*=1.1
        end
=begin
        miniscore = setupminiscore(attacker,opponent,skill,move,true,5,false,initialscores,scoreindex)
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
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.1
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
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
        if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
          miniscore*=1.1
        end
        if (attitemworks && attacker.item == PBItems::LEFTOVERS) ||
           ((attitemworks && attacker.item == PBItems::BLACKSLUDGE) && attacker.pbHasType?(:POISON))
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
          miniscore*=1.2
        end
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if !attacker.pbTooHigh?(PBStats::DEFENSE)
          miniscore/=100.0
          score*=miniscore
        end
        miniscore=100
        weakermove=false
        for j in attacker.moves
          if j.basedamage<95
            weakermove=true
          end
        end
        if weakermove
          miniscore*=1.1
        end
        if opponent.stages[PBStats::EVASION]>0
          ministat=opponent.stages[PBStats::EVASION]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
          ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
          ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          miniscore*=1.1
        end
        if !attacker.pbTooHigh?(PBStats::ACCURACY)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::ATTACK) && attacker.pbTooHigh?(PBStats::DEFENSE) && attacker.pbTooHigh?(PBStats::ACCURACY)
          score*=0
        end
=end
      when 0x26 # Dragon Dance
        miniscore*=1.2 if checkAIhealing(aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
=begin
        miniscore = setupminiscore(attacker,opponent,skill,move,true,17,false,initialscores,scoreindex)
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
        if (attacker.pbSpeed<=pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.3
        end
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
        if attacker.stages[PBStats::ATTACK]<0
          ministat=attacker.stages[PBStats::ATTACK]
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
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        if !attacker.pbTooHigh?(PBStats::SPEED)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)

        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::ATTACK) && attacker.pbTooHigh?(PBStats::SPEED)
          score*=0
        end
=end
      when 0x27 # Work Up
        miniscore*=1.3 if checkAIhealing(aimem)
        miniscore*=0.6 if checkAIpriority(aimem)
=begin
        miniscore = setupminiscore(attacker,opponent,skill,move,true,5,false,initialscores,scoreindex)
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
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if attacker.status==PBStatuses::BURN && !specmove
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
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        if (physmove && !attacker.pbTooHigh?(PBStats::ATTACK)) || (specmove && !attacker.pbTooHigh?(PBStats::SPATK))
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::ATTACK)
          score*=0
        end
=end
      when 0x28 # Growth
        miniscore = setupminiscore(attacker,opponent,skill,move,true,5,false,initialscores,scoreindex)
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
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if attacker.status==PBStatuses::BURN && !specmove
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
        miniscore*=0.6 if checkAIpriority(aimem)
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        if (physmove && !attacker.pbTooHigh?(PBStats::ATTACK)) || (specmove && !attacker.pbTooHigh?(PBStats::SPATK))
          if skill>=PBTrainerAI.bestSkill
            if pbWeather==PBWeather::SUNNYDAY
              miniscore*=2
            end
          end
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::ATTACK)
          score*=0
        end
      when 0x29 # Hone Claws
        miniscore = setupminiscore(attacker,opponent,skill,move,true,1,false,initialscores,scoreindex)
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
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=1.5
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
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
        weakermove=false
        for j in attacker.moves
          if j.basedamage<95
            weakermove=true
          end
        end
        if weakermove
          miniscore*=1.3
        end
        if opponent.stages[PBStats::EVASION]>0
          ministat=opponent.stages[PBStats::EVASION]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (oppitemworks && opponent.item == PBItems::BRIGHTPOWDER) || (oppitemworks && opponent.item == PBItems::LAXINCENSE) ||
          ((!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
          ((!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          miniscore*=1.3
        end
        if !attacker.pbTooHigh?(PBStats::ACCURACY)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::ACCURACY) && attacker.pbTooHigh?(PBStats::ATTACK)
          score*=0
        end
      when 0x2A # Cosmic Power
        miniscore = setupminiscore(attacker,opponent,skill,move,false,10,false,initialscores,scoreindex)
        if attacker.stages[PBStats::SPDEF]>0 || attacker.stages[PBStats::DEFENSE]>0
          ministat=attacker.stages[PBStats::SPDEF]
          ministat+=attacker.stages[PBStats::DEFENSE]
          minimini=-5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
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
          miniscore*=1.7
        end
        if attacker.pbHasMove?(:LEECHSEED)
          miniscore*=1.3
        end
        if attacker.pbHasMove?(:PAINSPLIT)
          miniscore*=1.2
        end
        if !attacker.pbTooHigh?(PBStats::SPDEF) || !attacker.pbTooHigh?(PBStats::DEFENSE)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPDEF) && attacker.pbTooHigh?(PBStats::DEFENSE)
          score*=0
        end
      when 0x2B # Quiver Dance
        miniscore = setupminiscore(attacker,opponent,skill,move,true,28,false,initialscores,scoreindex)
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
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if specmove && !attacker.pbTooHigh?(PBStats::SPATK)
          miniscore/=100.0
          score*=miniscore
        end
        miniscore=100
        if attacker.effects[PBEffects::Toxic]>0
          miniscore*=0.2
        end
        if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
          if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
            if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
               (attacker.hp.to_f)/attacker.totalhp>0.75
              miniscore*=1.3
            elsif (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              miniscore*=0.7
            end
          end
          miniscore*=1.3
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
        if !attacker.pbTooHigh?(PBStats::SPDEF)
          miniscore/=100.0
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
        if !attacker.pbTooHigh?(PBStats::SPEED)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::SPDEF) && attacker.pbTooHigh?(PBStats::SPEED)
          score*=0
        end
      when 0x2C # Calm Mind
        miniscore = setupminiscore(attacker,opponent,skill,move,true,12,false,initialscores,scoreindex)
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
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if specmove && !attacker.pbTooHigh?(PBStats::SPATK)
          miniscore/=100.0
          score*=miniscore
        end
        miniscore=100
        if attacker.effects[PBEffects::Toxic]>0
          miniscore*=0.2
        end
        if pbRoughStat(opponent,PBStats::SPATK,skill)>pbRoughStat(opponent,PBStats::ATTACK,skill)
          if !(roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL))
            if ((attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)) &&
               (attacker.hp.to_f)/attacker.totalhp>0.75
              miniscore*=1.3
            elsif (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              miniscore*=0.7
            end
          end
          miniscore*=1.3
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
        if !attacker.pbTooHigh?(PBStats::SPDEF)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
        if attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::SPDEF)
          score*=0
        end
      when 0x2D # Ancient power
        miniscore=100
        miniscore*=2
        if score == 110
          miniscore *= 1.3
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
            miniscore*=1.3
          end
        end
        miniscore*=0.2 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
          miniscore*=2
        end
        if @doublebattle
          miniscore*=0.3
        end
        if attacker.hp==attacker.totalhp && (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        miniscore-=100
        if move.addlEffect.to_f != 100
          miniscore*=(move.addlEffect.to_f/100)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE)
            miniscore*=2
          end
        end
        miniscore+=100
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::ATTACK) && attacker.pbTooHigh?(PBStats::DEFENSE) &&
           attacker.pbTooHigh?(PBStats::SPATK) && attacker.pbTooHigh?(PBStats::SPDEF) &&
           attacker.pbTooHigh?(PBStats::SPEED)
          miniscore=0
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score *= 0.9
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=0.9
        end
        if miniscore > 1
          score*=miniscore
        end
      when 0x2E # Swords Dance
        miniscore = setupminiscore(attacker,opponent,skill,move,true,1,true,initialscores,scoreindex)
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
          miniscore*=1.2
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.2 if checkAImoves([PBMoves::FOULPLAY],aimem)
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.5
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::ATTACK)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        miniscore=0 if !physmove
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x2F # Iron Defense
        miniscore = setupminiscore(attacker,opponent,skill,move,false,2,true,initialscores,scoreindex)
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
        if move.basedamage>0
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
        else
          miniscore/=100.0
          if attacker.pbTooHigh?(PBStats::DEFENSE)
            miniscore=0
          end
          miniscore*=0 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
            miniscore*=0
          end
          if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
            miniscore*=1
          end
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x30 # Agility
        miniscore = setupminiscore(attacker,opponent,skill,move,true,16,true,initialscores,scoreindex)
        if attacker.attack<attacker.spatk
          if attacker.stages[PBStats::SPATK]<0
            ministat=attacker.stages[PBStats::SPATK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        else
          if attacker.stages[PBStats::ATTACK]<0
            ministat=attacker.stages[PBStats::ATTACK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        end
        ministat=0
        ministat+=opponent.stages[PBStats::DEFENSE]
        ministat+=opponent.stages[PBStats::SPDEF]
        if ministat>0
          minimini=(-5)*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=0.3
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount==1
              miniscore*=0.1
          end
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if @trickroom!=0
          miniscore*=0.2
        else
          miniscore*=0.2 if checkAImoves([PBMoves::TRICKROOM],aimem)
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.2
        end
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::SPEED)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x31 # Autotomize
        miniscore = setupminiscore(attacker,opponent,skill,move,true,16,true,initialscores,scoreindex)
        if attacker.attack<attacker.spatk
          if attacker.stages[PBStats::SPATK]<0
            ministat=attacker.stages[PBStats::SPATK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        else
          if attacker.stages[PBStats::ATTACK]<0
            ministat=attacker.stages[PBStats::ATTACK]
            minimini=5*ministat
            minimini+=100
            minimini/=100.0
            miniscore*=minimini
          end
        end
        ministat=0
        ministat+=opponent.stages[PBStats::DEFENSE]
        ministat+=opponent.stages[PBStats::SPDEF]
        if ministat>0
          minimini=(-5)*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=0.3
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount==1
              miniscore*=0.1
          end
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if @trickroom!=0
          miniscore*=0.2
        else
          miniscore*=0.2 if checkAImoves([PBMoves::TRICKROOM],aimem)
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.2
        end
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        miniscore*=1.5 if checkAImoves([PBMoves::LOWKICK,PBMoves::GRASSKNOT],aimem)
        miniscore*=0.5 if checkAImoves([PBMoves::HEATCRASH,PBMoves::HEAVYSLAM],aimem)
        if attacker.pbHasMove?(:HEATCRASH) || attacker.pbHasMove?(:HEAVYSLAM)
          miniscore*=0.8
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::SPEED)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x32 # Nasty Plot
        miniscore = setupminiscore(attacker,opponent,skill,move,true,4,true,initialscores,scoreindex)
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
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::SPATK)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        miniscore=0 if !specmove
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x33 # Amnesia
        miniscore = setupminiscore(attacker,opponent,skill,move,false,0,true,initialscores,scoreindex)
        if attacker.stages[PBStats::SPDEF]>0
          ministat=attacker.stages[PBStats::SPDEF]
          minimini=-15*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if pbRoughStat(opponent,PBStats::ATTACK,skill)<pbRoughStat(opponent,PBStats::SPATK,skill)
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
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::SPDEF)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x34 # Minimize
        miniscore = setupminiscore(attacker,opponent,skill,move,false,0,true,initialscores,scoreindex)
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
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) || checkAIaccuracy(aimem)
          miniscore*=0.2
        end
        if (attitemworks && (attacker.item == PBItems::BRIGHTPOWDER || attacker.item == PBItems::LAXINCENSE)) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          miniscore*=1.3
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::EVASION)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x35 # Shell Smash
        miniscore = setupminiscore(attacker,opponent,skill,move,true,21,true,initialscores,scoreindex)
        miniscore/=100.0
        score*=miniscore
        miniscore=100
        miniscore*=1.3 if checkAIhealing(aimem)
        if attacker.pbSpeed<=pbRoughStat(opponent,PBStats::SPEED,skill) &&
           (2*attacker.pbSpeed)>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.5
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        if attacker.status==PBStatuses::BURN && !specmove
          miniscore*=0.5
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.5
        end
        miniscore*=0.2 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore/=100.0
        score*=miniscore
        miniscore=100
        if (attitemworks && attacker.item == PBItems::WHITEHERB)
          miniscore *= 1.5
        else
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            miniscore*=0.1
          end
        end
        if @trickroom!=0
          miniscore*=0.2
        else
          miniscore*=0.2 if checkAImoves([PBMoves::TRICKROOM],aimem)
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        if (attitemworks && attacker.item == PBItems::WHITEHERB)
          miniscore*=1.5
        end
        if !attacker.pbTooHigh?(PBStats::SPEED)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        healmove=false
        for j in attacker.moves
          if j.isHealingMove?
            healmove=true
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY) && !healmove
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score=0
        end
      when 0x36 # Shift Gear
        miniscore = setupminiscore(attacker,opponent,skill,move,true,17,false,initialscores,scoreindex)
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
        if (attacker.pbSpeed<=pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=1.3
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.5
        end
        if attacker.status==PBStatuses::BURN || attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.5
        end
        miniscore*=0.3 if checkAImoves([PBMoves::FOULPLAY],aimem)
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
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
        if attacker.stages[PBStats::ATTACK]<0
          ministat=attacker.stages[PBStats::ATTACK]
          minimini=5*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
          miniscore*=0.8
        end
        if @trickroom!=0 || checkAImoves([PBMoves::TRICKROOM],aimem)
          miniscore*=0.1
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
          miniscore*=1.3
        end
        if !attacker.pbTooHigh?(PBStats::SPEED)
          miniscore/=100.0
          score*=miniscore
        end
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          score = 0
        end
      when 0x37 # Acupressure
        miniscore = setupminiscore(attacker,opponent,skill,move,false,0,false,initialscores,scoreindex)
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
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD) || checkAIaccuracy(aimem)
          miniscore*=0.2
        end
        if (attitemworks && attacker.item == PBItems::BRIGHTPOWDER) || (attitemworks && attacker.item == PBItems::LAXINCENSE) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SANDVEIL) && pbWeather==PBWeather::SANDSTORM) ||
          ((!attacker.abilitynulled && attacker.ability == PBAbilities::SNOWCLOAK) && pbWeather==PBWeather::HAIL)
          miniscore*=1.3
        end
        miniscore/=100.0
        maxstat=0
        maxstat+=1 if attacker.pbTooHigh?(PBStats::ATTACK)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::DEFENSE)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::SPATK)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::SPDEF)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::SPEED)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::ACCURACY)
        maxstat+=1 if attacker.pbTooHigh?(PBStats::EVASION)
        if maxstat>1
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x38 # Cotton Guard
        miniscore = setupminiscore(attacker,opponent,skill,move,false,2,true,initialscores,scoreindex)
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
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::DEFENSE)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x39 # Tail Glow
        miniscore = setupminiscore(attacker,opponent,skill,move,true,4,true,initialscores,scoreindex)
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
        if attacker.hp==attacker.totalhp &&
           (((attitemworks && attacker.item == PBItems::FOCUSSASH) ||
           ((!attacker.abilitynulled && attacker.ability == PBAbilities::STURDY) && !attacker.moldbroken)) &&
           (pbWeather!=PBWeather::HAIL || attacker.pbHasType?(:ICE)) &&
           (pbWeather!=PBWeather::SANDSTORM || attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND) || attacker.pbHasType?(:STEEL)))
          miniscore*=1.4
        end
        miniscore*=0.6 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::SPATK)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=1
        end
        specmove=false
        for j in attacker.moves
          if j.pbIsSpecial?(j.type)
            specmove=true
          end
        end
        miniscore=0 if !specmove
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x3A # Belly Drum
        miniscore=100
        if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
          miniscore*=1.5
        end
        if initialscores.length>0
          miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
        end
        if (attacker.hp.to_f)/attacker.totalhp>0.85
          miniscore*=1.2
        end
        if opponent.effects[PBEffects::HyperBeam]>0
          miniscore*=1.5
        end
        if opponent.effects[PBEffects::Yawn]>0
          miniscore*=1.7
        end
        if skill>=PBTrainerAI.mediumSkill
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          if maxdam<(attacker.hp/4.0) && (aimem.length > 0)
            miniscore*=1.4
          else
            if move.basedamage==0
              miniscore*=0.8
              if maxdam>attacker.hp
                miniscore*=0.1
              end
            end
          end
        else
          if move.basedamage==0
            effcheck = PBTypes.getCombinedEffectiveness(opponent.type1,attacker.type1,attacker.type2)
            if effcheck > 4
              miniscore*=0.5
            end
            effcheck2 = PBTypes.getCombinedEffectiveness(opponent.type2,attacker.type1,attacker.type2)
            if effcheck2 > 4
              miniscore*=0.5
            end
          end
        end
        if attacker.turncount<1
          miniscore*=1.2
        end
        if opponent.status!=0
          miniscore*=1.2
        end
        if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
          miniscore*=1.4
        end
        if opponent.effects[PBEffects::Encore]>0
          if opponent.moves[(opponent.effects[PBEffects::EncoreIndex])].basedamage==0
            miniscore*=1.5
          end
        end
        if attacker.effects[PBEffects::Confusion]>0
          miniscore*=0.1
        end
        if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
          miniscore*=0.2
        end
        miniscore*=0.1 if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
          miniscore*=0
        end
        if @doublebattle
          miniscore*=0.1
        end
        if attacker.stages[PBStats::SPEED]<0
          ministat=attacker.stages[PBStats::SPEED]
          minimini=10*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        ministat=0
        ministat+=opponent.stages[PBStats::ATTACK]
        ministat+=opponent.stages[PBStats::SPATK]
        ministat+=opponent.stages[PBStats::SPEED]
        if ministat>0
          minimini=(-10)*ministat
          minimini+=100
          minimini/=100.0
          miniscore*=minimini
        end
        miniscore*=1.3 if checkAIhealing(aimem)
        if attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill) && @trickroom==0
          miniscore*=1.5
        else
          primove=false
          for j in attacker.moves
            if j.priority>0
              primove=true
            end
          end
          if !primove
            miniscore*=0.3
          end
        end
        if roles.include?(PBMonRoles::SWEEPER)
          miniscore*=1.3
        end
        if attacker.status==PBStatuses::BURN
          miniscore*=0.8
        end
        if attacker.status==PBStatuses::PARALYSIS
          miniscore*=0.2
        end
        miniscore*=0.1 if checkAImoves([PBMoves::FOULPLAY],aimem)
        miniscore*=0.1 if checkAIpriority(aimem)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::SPEEDBOOST)
          miniscore*=0.6
        end
        miniscore/=100.0
        if attacker.pbTooHigh?(PBStats::ATTACK)
          miniscore=0
        end
        score*=0.3 if checkAImoves([PBMoves::CLEARSMOG,PBMoves::HAZE],aimem)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          miniscore*=0
        end
        physmove=false
        for j in attacker.moves
          if j.pbIsPhysical?(j.type)
            physmove=true
          end
        end
        miniscore=0 if !physmove
        score*=miniscore
        if (opponent.level-5)>attacker.level
          score*=0.6
          if (opponent.level-10)>attacker.level
            score*=0.2
          end
        end
      when 0x3B # Superpower
        thisinitial = score
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.7
        else
          if thisinitial<100
            score*=0.9
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.2
            else
              score*=0.5 if checkAIhealing(aimem)
            end
          end
          if initialscores.length>0
            score*=0.7 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount>1
            miniscore*=(livecount-3)
            miniscore/=100.0
            miniscore*=0.05
            miniscore=(1-miniscore)
            score*=miniscore
          end
          count=-1
          party=pbParty(attacker.index)
          pivotvar=false
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::PIVOT)
              pivotvar=true
            end
          end
          if pivotvar && !@doublebattle
            score*=1.2
          end
          livecount2=0
          for i in pbParty(attacker.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if livecount>1 && livecount2==1
            score*=0.8
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::MOXIE)
            score*=1.5
          end
        end
      when 0x3C # Close Combat
        thisinitial = score
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.5
        else
          if thisinitial<100
            score*=0.9
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.3
            else
              score*=0.7 if checkAIpriority(aimem)
            end
            score*=0.7 if checkAIhealing(aimem)
          end
          if initialscores.length>0
            score*=0.7 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount>1
            miniscore*=(livecount-3)
            miniscore/=100.0
            miniscore*=0.05
            miniscore=(1-miniscore)
            score*=miniscore
          end
          count=-1
          party=pbParty(attacker.index)
          pivotvar=false
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::PIVOT)
              pivotvar=true
            end
          end
          if pivotvar && !@doublebattle
            score*=1.2
          end
          livecount2=0
          for i in pbParty(attacker.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if livecount>1 && livecount2==1
            score*=0.9
          end
        end
      when 0x3D # V-Create
        thisinitial = score
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.7
        else
          if thisinitial<100
            score*=0.8
            if (attacker.pbSpeed<pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
              score*=1.3
            else
              livecount=0
              for i in pbParty(opponent.index)
                next if i.nil?
                livecount+=1 if i.hp!=0
              end
              livecount2=0
              for i in pbParty(attacker.index)
                next if i.nil?
                livecount2+=1 if i.hp!=0
              end
              if livecount>1 && livecount2==1
                score*=0.7
              end
              score*=0.7 if checkAIpriority(aimem)
            end
          end
          if initialscores.length>0
            score*=0.7 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          miniscore=100
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount>1
            miniscore*=(livecount-3)
            miniscore/=100.0
            miniscore*=0.05
            miniscore=(1-miniscore)
            score*=miniscore
          end
          count=-1
          party=pbParty(attacker.index)
          pivotvar=false
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::PIVOT)
              pivotvar=true
            end
          end
          if pivotvar && !@doublebattle
            score*=1.2
          end
        end
      when 0x3E # Hammer Arm
        thisinitial = score
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.3
        else
          if thisinitial<100
            score*=0.9
          end
          if initialscores.length>0
            score*=0.7 if hasgreatmoves(initialscores,scoreindex,skill)
          end
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          livecount2=0
          for i in pbParty(attacker.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if (attacker.pbSpeed>pbRoughStat(opponent,PBStats::SPEED,skill)) ^ (@trickroom!=0)
            score*=0.8
            if livecount>1 && livecount2==1
              score*=0.8
            end
          else
            score*=1.1
          end
          if roles.include?(PBMonRoles::TANK)
            score*=1.1
          end
          miniscore=100
          livecount=0
          for i in pbParty(opponent.index)
            next if i.nil?
            livecount+=1 if i.hp!=0
          end
          if livecount>1
            miniscore*=(livecount-3)
            miniscore/=100.0
            miniscore*=0.05
            miniscore=(1-miniscore)
            score*=miniscore
          end
          count=-1
          party=pbParty(attacker.index)
          pivotvar=false
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::PIVOT)
              pivotvar=true
            end
          end
          if pivotvar && !@doublebattle
            score*=1.2
          end
        end
      when 0x3F # Overheat
        thisinitial = score
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::CONTRARY)
          score*=1.7
        else
          if thisinitial<100
            score*=0.9
            score*=0.5 if checkAIhealing(aimem)
          end
          if initialscores.length>0
            score*=0.7 if hasgreatmoves(initialscores,scoreindex,skill)
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
            miniscore*=0.05
            miniscore=(1-miniscore)
            score*=miniscore
          end
          count=-1
          party=pbParty(attacker.index)
          pivotvar=false
          for i in 0...party.length
            count+=1
            next if party[i].nil?
            temproles = pbGetMonRole(party[i],opponent,skill,count,party)
            if temproles.include?(PBMonRoles::PIVOT)
              pivotvar=true
            end
          end
          if pivotvar && !@doublebattle
            score*=1.2
          end
          livecount2=0
          for i in pbParty(attacker.index)
            next if i.nil?
            livecount2+=1 if i.hp!=0
          end
          if livecount>1 && livecount2==1
            score*=0.8
          end
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::SOULHEART)
            score*=1.3
          end
        end
    end
    return score
  end
end
