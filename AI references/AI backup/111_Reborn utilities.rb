class PokeBattle_Battle
  def pbRoughStat(battler,stat,skill)
    if skill>=PBTrainerAI.highSkill && stat==PBStats::SPEED
      return battler.pbSpeed
    end
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    stage=battler.stages[stat]+6
    value=0
    value=battler.attack if stat==PBStats::ATTACK
    value=battler.defense if stat==PBStats::DEFENSE
    value=battler.speed if stat==PBStats::SPEED
    value=battler.spatk if stat==PBStats::SPATK
    value=battler.spdef if stat==PBStats::SPDEF
    return (value*1.0*stagemul[stage]/stagediv[stage]).floor
  end

  def pbBetterBaseDamage(move,attacker,opponent,skill,basedamage)
    # Covers all function codes which have their own def pbBaseDamage
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    case move.function
      when 0x6A # SonicBoom
        basedamage=20
        if $fefieldeffect==9
          basedamage=140
        end
      when 0x6B # Dragon Rage
        basedamage=40
      when 0x6C # Super Fang
        basedamage=(opponent.hp/2.0).floor
        if (move.id == PBMoves::NATURESMADNESS) && ($fefieldeffect == 2 || $fefieldeffect == 15 || $fefieldeffect == 35)
          basedamage=(opponent.hp*0.75).floor
        elsif (move.id == PBMoves::NATURESMADNESS) && $fefieldeffect == 29
          basedamage=(opponent.hp*0.66).floor
        end
      when 0x6D # Night Shade
        basedamage=attacker.level
      when 0x6E # Endeavor
        basedamage=opponent.hp-attacker.hp
      when 0x6F # Psywave
        basedamage=attacker.level
      when 0x70 # OHKO
        basedamage=opponent.totalhp
      when 0x71 # Counter
        maxdam=60
        if aimem.length > 0
          for j in aimem
            next if j.pbIsSpecial?(j.type)
            next if j.basedamage<=1
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)*2
            if tempdam>maxdam
              maxdam=tempdam
            end
          end
        end
        basedamage = maxdam
      when 0x72 # Mirror Coat
        maxdam=60
        if aimem.length > 0
          for j in aimem
            next if j.pbIsPhysical?(j.type)
            next if j.basedamage<=1
            tempdam = pbRoughDamage(j,opponent,attacker,skill,j.basedamage)*2
            if tempdam>maxdam
              maxdam=tempdam
            end
          end
        end
        basedamage = maxdam
      when 0x73 # Metal Burst
        maxdam=45
        if aimem.length > 0
          maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        end
        basedamage = maxdam
      when 0x75, 0x12D # Surf, Shadow Storm
        basedamage*=2 if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCB # Dive
      when 0x76 # Earthquake
        basedamage*=2 if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCA # Dig
      when 0x77, 0x78 # Gust, Twister
        basedamage*=2 if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xC9 || # Fly
                         $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCC || # Bounce
                         $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCE    # Sky Drop
      when 0x79 # Fusion Bolt
        basedamage*=2 if previousMove == 127 || previousMove == 131
      when 0x7A # Fusion Flare
        basedamage*=2 if previousMove == 64 || previousMove == 68
      when 0x7B # Venoshock
        if opponent.status==PBStatuses::POISON
          basedamage*=2
        elsif skill>=PBTrainerAI.bestSkill
          if $fefieldeffect==10 || $fefieldeffect==11 || $fefieldeffect==19 || $fefieldeffect==26 # Corrosive/Corromist/Wasteland/Murkwater
            basedamage*=2
          end
        end
      when 0x7C # SmellingSalt
        basedamage*=2 if opponent.status==PBStatuses::PARALYSIS  && opponent.effects[PBEffects::Substitute]<=0
      when 0x7D # Wake-Up Slap
        basedamage*=2 if opponent.status==PBStatuses::SLEEP && opponent.effects[PBEffects::Substitute]<=0
      when 0x7E # Facade
        basedamage*=2 if attacker.status==PBStatuses::POISON ||
                         attacker.status==PBStatuses::BURN ||
                         attacker.status==PBStatuses::PARALYSIS
      when 0x7F # Hex
        basedamage*=2 if opponent.status!=0
      when 0x80 # Brine
        basedamage*=2 if opponent.hp<=(opponent.totalhp/2.0).floor
      when 0x85 # Retaliate
        basedamage*=2 if attacker.pbOwnSide.effects[PBEffects::Retaliate]
      when 0x86 # Acrobatics
        basedamage*=2 if attacker.item ==0 || attacker.hasWorkingItem(:FLYINGGEM) ||
         $fefieldeffect == 6
      when 0x87 # Weather Ball
        basedamage*=2 if (pbWeather!=0 || $fefieldeffect==9)
      when 0x89 # Return
        basedamage=[(attacker.happiness*2/5).floor,1].max
      when 0x8A # Frustration
        basedamage=[((255-attacker.happiness)*2/5).floor,1].max
      when 0x8B # Eruption
        basedamage=[(150*(attacker.hp.to_f)/attacker.totalhp).floor,1].max
      when 0x8C # Crush Grip
        basedamage=[(120*(opponent.hp.to_f)/opponent.totalhp).floor,1].max
      when 0x8D # Gyro Ball
        ospeed=pbRoughStat(opponent,PBStats::SPEED,skill)
        aspeed=pbRoughStat(attacker,PBStats::SPEED,skill)
        basedamage=[[(25*ospeed/aspeed).floor,150].min,1].max
      when 0x8E # Stored Power
        mult=0
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          mult+=attacker.stages[i] if attacker.stages[i]>0
        end
        basedamage=20*(mult+1)
      when 0x8F # Punishment
        mult=0
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          mult+=opponent.stages[i] if opponent.stages[i]>0
        end
        basedamage=[20*(mult+3),200].min
      #when 0x90 # Hidden Power
      #hp=pbHiddenPower(attacker.iv)

      when 0x91 # Fury Cutter
        basedamage=basedamage<<(attacker.effects[PBEffects::FuryCutter]-1)
      when 0x92 # Echoed Voice
        basedamage*=attacker.effects[PBEffects::EchoedVoice]
      when 0x94 # Present
        basedamage=50
      when 0x95 # Magnitude
        basedamage=71
        basedamage*=2 if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCA # Dig
      when 0x96 # Natural Gift
        damagearray = PBStuff::NATURALGIFTDAMAGE
        haveanswer=false
        for i in damagearray.keys
          data=damagearray[i]
          if data
            for j in data
              if isConst?(attacker.item,PBItems,j)
                basedamage=i; haveanswer=true; break
              end
            end
          end
          break if haveanswer
        end
      when 0x97 # Trump Card
        dmgs=[200,80,60,50,40]
        ppleft=[move.pp-1,4].min   # PP is reduced before the move is used
        basedamage=dmgs[ppleft]
      when 0x98 # Flail
        n=(48*(attacker.hp.to_f)/attacker.totalhp).floor
        basedamage=20
        basedamage=40 if n<33
        basedamage=80 if n<17
        basedamage=100 if n<10
        basedamage=150 if n<5
        basedamage=200 if n<2
      when 0x99 # Electro Ball
        n=(attacker.pbSpeed/opponent.pbSpeed).floor
        basedamage=40
        basedamage=60 if n>=1
        basedamage=80 if n>=2
        basedamage=120 if n>=3
        basedamage=150 if n>=4
      when 0x9A # Low Kick
        weight=opponent.weight
        basedamage=20
        basedamage=40 if weight>100
        basedamage=60 if weight>250
        basedamage=80 if weight>500
        basedamage=100 if weight>1000
        basedamage=120 if weight>2000
      when 0x9B # Heavy Slam
        n=(attacker.weight/opponent.weight).floor
        basedamage=40
        basedamage=60 if n>=2
        basedamage=80 if n>=3
        basedamage=100 if n>=4
        basedamage=120 if n>=5
      when 0xA0 # Frost Breath
        basedamage*=1.5
      when 0xBD, 0xBE # Double Kick, Twineedle
        basedamage*=2
      when 0xBF # Triple Kick
        basedamage*=6
      when 0xC0 # Fury Attack
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::SKILLLINK)
          basedamage*=5
        else
          basedamage=(basedamage*19/6).floor
        end
      when 0xC1 # Beat Up
        party=pbParty(attacker.index)
        mult=0
        for i in 0...party.length
          mult+=1 if party[i] && !party[i].isEgg? &&
                      party[i].hp>0 && party[i].status==0
        end
        basedamage*=mult
      when 0xC4 # SolarBeam
        if pbWeather!=0 && pbWeather!=PBWeather::SUNNYDAY
          basedamage=(basedamage*0.5).floor
        end
      when 0xD0 # Whirlpool
        if skill>=PBTrainerAI.mediumSkill
          basedamage*=2 if $pkmn_move[opponent.effects[PBEffects::TwoTurnAttack]][0] #the function code of the current move==0xCB # Dive
        end
      when 0xD3 # Rollout
        if skill>=PBTrainerAI.mediumSkill
          basedamage*=2 if attacker.effects[PBEffects::DefenseCurl]
        end
      when 0xD4 # Bide
        maxdam=30
        if skill>=PBTrainerAI.bestSkill
          if aimem.length > 0
            maxdam = checkAIdamage(aimem,attacker,opponent,skill)
          end
        end
        basedamage = maxdam
      when 0xE1 # Final Gambit
        basedamage=attacker.hp
      when 0xF0 # Knock Off
        if opponent.item!=0 && !pbIsUnlosableItem(opponent,opponent.item)
          basedamage*=1.5
        end
      when 0xF7 # Fling
        if attacker.item ==0
          basedamage=0
        else
          basedamage=10 if pbIsBerry?(attacker.item)
          flingarray = PBStuff::FLINGDAMAGE
          for i in flingarray.keys
            data=flingarray[i]
            if data
              for j in data
                basedamage = i if isConst?(attacker.item,PBItems,j)
              end
            end
          end
        end
      when 0x113 # Spit Up
        basedamage = 100*attacker.effects[PBEffects::Stockpile]
      when 0x171 # Stomping Tantrum
        if attacker.effects[PBEffects::Tantrum]
          basedamage*=2
        end
    end
    return basedamage
  end

  def pbRoughDamage(move,attacker,opponent,skill,basedamage)
    if opponent.species==0 || attacker.species==0
      return 0
    end
    move = pbChangeMove(move,attacker)
    basedamage = move.basedamage
    if move.basedamage==0
      return 0
    end
    #Temporarly mega-ing pokemon if it can    #perry
    if pbCanMegaEvolve?(attacker.index)
      attacker.pokemon.makeMega
      attacker.pbUpdate(true)
      attacker.form=attacker.startform
      megaEvolved=true
    end
    if skill>=PBTrainerAI.highSkill
      basedamage = pbBetterBaseDamage(move,attacker,opponent,skill,basedamage)
    end
    if move.function==0x6A ||   # SonicBoom
       move.function==0x6B ||   # Dragon Rage
       move.function==0x6C ||   # Super Fang
       move.function==0x6D ||   # Night Shade
       move.function==0x6E ||   # Endeavor
       move.function==0x6F ||   # Psywave
       move.function==0x70 ||   # OHKO
       move.function==0x71 ||   # Counter
       move.function==0x72 ||   # Mirror Coat
       move.function==0x73 ||   # Metal Burst
       move.function==0xD4 ||   # Bide
       move.function==0xE1      # Final Gambit
      attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #un-mega pokemon #perry
      return basedamage
    end
    type=move.type
    # More accurate move type (includes Normalize, most type-changing moves, etc.)

    if skill>=PBTrainerAI.minimumSkill
      type=move.pbType(type,attacker,opponent)
    end

    oppitemworks = opponent.itemWorks?
    attitemworks = attacker.itemWorks?

    # ATTACKING/BASE DAMAGE SECTION
    atk=pbRoughStat(attacker,PBStats::ATTACK,skill)
    if attacker.species==681
      originalform = attacker.form
      dummymon = pbAegislashStats(attacker)
      dummymon.pbUpdate
      atk=pbRoughStat(dummymon,PBStats::ATTACK,skill)
      dummymon.form = originalform
      dummymon.pbUpdate
    end
    if move.function==0x121 # Foul Play
      atk=pbRoughStat(opponent,PBStats::ATTACK,skill)
    end
    if type>=0 && move.pbIsSpecial?(type)
      atk=pbRoughStat(attacker,PBStats::SPATK,skill)
      if attacker.species==681
        originalform = attacker.form
        dummymon = pbAegislashStats(attacker)
        dummymon.pbUpdate
        atk=pbRoughStat(dummymon,PBStats::SPATK,skill)
        dummymon.form = originalform
        dummymon.pbUpdate
      end
      if move.function==0x121 # Foul Play
        atk=pbRoughStat(opponent,PBStats::SPATK,skill)
      end
      if $fefieldeffect == 24
        stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
        stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
        gl1 = pbRoughStat(attacker,PBStats::SPATK,skill)
        gl2 = pbRoughStat(attacker,PBStats::SPDEF,skill)
        gl3 = attacker.stages[PBStats::SPDEF]+6
        gl4 = attacker.stages[PBStats::SPATK]+6
        if attitemworks
          gl2 *= 1.5 if attacker.item == PBItems::ASSAULTVEST
          gl1 *= 1.5 if attacker.item == PBItems::CHOICESPECS
          gl2 *= 1.5 if attacker.item == PBItems::EVIOLITE && pbGetEvolvedFormData(attacker.species).length>0
          gl1 *= 2 if attacker.item == PBItems::DEEPSEATOOTH && attacker.species == PBSpecies::CLAMPERL
          gl1 *= 2 if attacker.item == PBItems::LIGHTBALL && attacker.species == PBSpecies::PIKACHU
          gl2 *= 2 if attacker.item == PBItems::DEEPSEASCALE && attacker.species == PBSpecies::CLAMPERL
          gl2 *= 1.5 if attacker.item == PBItems::METALPOWDER && attacker.species == PBSpecies::DITTO
        end
        if !attacker.abilitynulled
          gl1 *= 1.5 if attacker.ability == PBAbilities::FLAREBOOST && attacker.status==PBStatuses::BURN
          gl1 *= 1.5 if attacker.ability == PBAbilities::MINUS && (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::PLUS)
          gl1 *= 1.5 if attacker.ability == PBAbilities::PLUS && (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::MINUS)
          gl1 *= 1.5 if attacker.ability == PBAbilities::SOLARPOWER && pbWeather==PBWeather::SUNNYDAY
          gl2 *= 1.5 if attacker.ability == PBAbilities::FLOWERGIFT && pbWeather==PBWeather::SUNNYDAY
        end
        gl1 *= 1.3 if (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::BATTERY)
        gl1=(gl1*stagemul[gl4]/stagediv[gl4]).floor
        gl2=(gl2*stagemul[gl3]/stagediv[gl3]).floor
        if gl1 < gl2
          atk=pbRoughStat(attacker,PBStats::SPDEF,skill)
        end
      end
    end

    #Field effect base damage adjustment
    if skill>=PBTrainerAI.bestSkill
      case $fefieldeffect
      when 1 # Electric Field
        if (move.id == PBMoves::EXPLOSION || move.id == PBMoves::SELFDESTRUCT ||
          move.id == PBMoves::HURRICANE || move.id == PBMoves::SURF ||
          move.id == PBMoves::SMACKDOWN || move.id == PBMoves::MUDDYWATER ||
          move.id == PBMoves::THOUSANDARROWS)
          basedamage=(basedamage*1.5).round
        elsif (move.id == PBMoves::MAGNETBOMB || move.id == PBMoves::PLASMAFISTS)
          basedamage=(basedamage*2).round
        end
      when 2 # Grassy Field
        if (move.id == PBMoves::FAIRYWIND || move.id == PBMoves::SILVERWIND)
          basedamage=(basedamage*1.5).round
        elsif (move.id == PBMoves::MUDDYWATER || move.id == PBMoves::SURF || move.id == PBMoves::EARTHQUAKE ||
          move.id == PBMoves::MAGNITUDE || move.id == PBMoves::BULLDOZE)
          basedamage=(basedamage*0.5).round
        end
      when 3 # Misty Field
        if (move.id == PBMoves::FAIRYWIND || move.id == PBMoves::MYSTICALFIRE ||
          move.id == PBMoves::MOONBLAST || move.id == PBMoves::MAGICALLEAF ||
          move.id == PBMoves::DOOMDUMMY || move.id == PBMoves::ICYWIND ||
          move.id == PBMoves::MISTBALL || move.id == PBMoves::AURASPHERE ||
          move.id == PBMoves::STEAMERUPTION || move.id == PBMoves::DAZZLINGGLEAM||
          move.id == PBMoves::SILVERWIND || move.id == PBMoves::MOONGEISTBEAM)
          basedamage=(basedamage*1.5).round
        elsif (move.id == PBMoves::DARKPULSE || move.id == PBMoves::SHADOWBALL ||
          move.id == PBMoves::NIGHTDAZE)
          basedamage=(basedamage*0.5).round
        end
      when 4 # Dark Crystal Cavern
        if (move.id == PBMoves::DARKPULSE ||
          move.id == PBMoves::NIGHTDAZE || move.id == PBMoves::NIGHTSLASH ||
          move.id == PBMoves::SHADOWBALL || move.id == PBMoves::SHADOWPUNCH ||
          move.id == PBMoves::SHADOWCLAW || move.id == PBMoves::SHADOWSNEAK ||
          move.id == PBMoves::SHADOWFORCE || move.id == PBMoves::SHADOWBONE)
          basedamage=(basedamage*1.5).round
        elsif (move.id == PBMoves::AURORABEAM || move.id == PBMoves::SIGNALBEAM ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::LUSTERPURGE ||
          move.id == PBMoves::DAZZLINGGLEAM || move.id == PBMoves::MIRRORSHOT ||
          move.id == PBMoves::TECHNOBLAST || move.id == PBMoves::DOOMDUMMY ||
          move.id == PBMoves::POWERGEM || move.id == PBMoves::MOONGEISTBEAM)
          basedamage=(basedamage*1.5).round
        elsif (move.id == PBMoves::PRISMATICLASER)
          basedamage=(basedamage*2).round
        end
      when 5 # Chess Board
        if (move.id == PBMoves::STRENGTH || move.id == PBMoves::ANCIENTPOWER ||
          move.id == PBMoves::PSYCHIC)
          basedamage=(basedamage*1.5).round
          if (opponent.ability == PBAbilities::ADAPTABILITY) ||
            (opponent.ability == PBAbilities::ANTICIPATION) ||
            (opponent.ability == PBAbilities::SYNCHRONIZE) ||
            (opponent.ability == PBAbilities::TELEPATHY)
            basedamage=(basedamage*0.5).round
          end
          if (opponent.ability == PBAbilities::OBLIVIOUS) ||
            (opponent.ability == PBAbilities::KLUTZ) ||
            (opponent.ability == PBAbilities::UNAWARE) ||
            (opponent.ability == PBAbilities::SIMPLE) ||
            opponent.effects[PBEffects::Confusion]>0
            basedamage=(basedamage*2).round
          end
        end
        if (move.id == PBMoves::FEINT || move.id == PBMoves::FEINTATTACK ||
          move.id == PBMoves::FAKEOUT)
          basedamage=(basedamage*1.5).round
        end
      when 6 # Big Top
        if (((move.type == PBTypes::FIGHTING) && move.pbIsPhysical?(move.type)) ||
          move.id == PBMoves::STRENGTH || move.id == PBMoves::WOODHAMMER ||
          move.id == PBMoves::DUALCHOP || move.id == PBMoves::HEATCRASH ||
          move.id == PBMoves::SKYDROP || move.id == PBMoves::BULLDOZE ||
          move.id == PBMoves::ICICLECRASH || move.id == PBMoves::BODYSLAM ||
          move.id == PBMoves::STOMP || move.id == PBMoves::POUND ||
          move.id == PBMoves::SLAM || move.id == PBMoves::GIGAIMPACT ||
          move.id == PBMoves::SMACKDOWN || move.id == PBMoves::IRONTAIL ||
          move.id == PBMoves::METEORMASH || move.id == PBMoves::DRAGONRUSH ||
          move.id == PBMoves::CRABHAMMER || move.id == PBMoves::BOUNCE ||
          move.id == PBMoves::HEAVYSLAM || move.id == PBMoves::MAGNITUDE ||
          move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::STOMPINGTANTRUM ||
          move.id == PBMoves::BRUTALSWING || move.id == PBMoves::HIGHHORSEPOWER ||
          move.id == PBMoves::ICEHAMMER || move.id == PBMoves::DRAGONHAMMER ||
          move.id == PBMoves::BLAZEKICK)
          if (!attacker.abilitynulled && attacker.ability == PBAbilities::HUGEPOWER) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::GUTS) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::PUREPOWER) ||
            (!attacker.abilitynulled && attacker.ability == PBAbilities::SHEERFORCE)
            basedamage=(basedamage*2.2).round
          else
            basedamage=(basedamage*1.2).round
          end
        end
        if (move.id == PBMoves::PAYDAY)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::VINEWHIP || move.id == PBMoves::POWERWHIP ||
          move.id == PBMoves::FIRELASH)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::FIERYDANCE || move.id == PBMoves::PETALDANCE ||
          move.id == PBMoves::REVELATIONDANCE)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::FLY || move.id == PBMoves::ACROBATICS)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::FIRSTIMPRESSION)
          basedamage=(basedamage*1.5).round
        end
        if move.isSoundBased?
          basedamage=(basedamage*1.5).round
        end
      when 7 # Burning Field
        if (move.id == PBMoves::SMOG || move.id == PBMoves::CLEARSMOG)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::SMACKDOWN || move.id == PBMoves::THOUSANDARROWS)
          basedamage=(basedamage*1.5).round
        end
      when 8 # Swamp Field
        if (move.id == PBMoves::MUDBOMB || move.id == PBMoves::MUDSHOT ||
          move.id == PBMoves::MUDSLAP || move.id == PBMoves::MUDDYWATER ||
          move.id == PBMoves::SURF || move.id == PBMoves::SLUDGEWAVE ||
          move.id == PBMoves::GUNKSHOT || move.id == PBMoves::BRINE ||
          move.id == PBMoves::SMACKDOWN || move.id == PBMoves::THOUSANDARROWS)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::MAGNITUDE ||
         move.id == PBMoves::BULLDOZE)
          basedamage=(basedamage*0.25).round
        end
      when 9 # Rainbow Field
        if (move.id == PBMoves::SILVERWIND || move.id == PBMoves::MYSTICALFIRE ||
          move.id == PBMoves::DRAGONPULSE || move.id == PBMoves::TRIATTACK ||
          move.id == PBMoves::SACREDFIRE || move.id == PBMoves::FIREPLEDGE ||
          move.id == PBMoves::WATERPLEDGE || move.id == PBMoves::GRASSPLEDGE ||
          move.id == PBMoves::AURORABEAM || move.id == PBMoves::JUDGMENT ||
          move.id == PBMoves::RELICSONG || move.id == PBMoves::HIDDENPOWER ||
          move.id == PBMoves::SECRETPOWER || move.id == PBMoves::WEATHERBALL ||
          move.id == PBMoves::MISTBALL || move.id == PBMoves::HEARTSTAMP ||
          move.id == PBMoves::MOONBLAST || move.id == PBMoves::ZENHEADBUTT ||
          move.id == PBMoves::SPARKLINGARIA || move.id == PBMoves::FLEURCANNON ||
          move.id == PBMoves::PRISMATICLASER)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::DARKPULSE || move.id == PBMoves::SHADOWBALL ||
          move.id == PBMoves::NIGHTDAZE)
          basedamage=(basedamage*0.5).round
        end
      when 10 # Corrosive Field
        if (move.id == PBMoves::SMACKDOWN || move.id == PBMoves::MUDSLAP ||
          move.id == PBMoves::MUDSHOT || move.id == PBMoves::MUDBOMB ||
          move.id == PBMoves::MUDDYWATER || move.id == PBMoves::WHIRLPOOL ||
          move.id == PBMoves::THOUSANDARROWS)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::ACID || move.id == PBMoves::ACIDSPRAY ||
          move.id == PBMoves::GRASSKNOT)
          basedamage=(basedamage*2).round
        end
      when 11 # Corrosive Mist Field
        if (move.id == PBMoves::BUBBLEBEAM || move.id == PBMoves::ACIDSPRAY ||
          move.id == PBMoves::BUBBLE || move.id == PBMoves::SMOG ||
          move.id == PBMoves::CLEARSMOG || move.id == PBMoves::SPARKLINGARIA)
          basedamage=(basedamage*1.5).round
        end
      when 12 # Desert Field
        if (move.id == PBMoves::NEEDLEARM || move.id == PBMoves::PINMISSILE ||
          move.id == PBMoves::DIG || move.id == PBMoves::SANDTOMB ||
          move.id == PBMoves::HEATWAVE || move.id == PBMoves::THOUSANDWAVES ||
          move.id == PBMoves::BURNUP)
          basedamage=(basedamage*1.5).round
        end
      when 13 # Icy Field
        if (move.id == PBMoves::SCALD || move.id == PBMoves::STEAMERUPTION)
          basedamage=(basedamage*0.5).round
        end
      when 14 # Rocky Field
        if (move.id == PBMoves::ROCKSMASH)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::ROCKCLIMB || move.id == PBMoves::STRENGTH ||
          move.id == PBMoves::MAGNITUDE || move.id == PBMoves::EARTHQUAKE ||
          move.id == PBMoves::BULLDOZE || move.id == PBMoves::ACCELEROCK)
          basedamage=(basedamage*1.5).round
        end
      when 15 # Forest Field
        if (move.id == PBMoves::CUT)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::ATTACKORDER)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::SURF || move.id == PBMoves::MUDDYWATER)
          basedamage=(basedamage*0.5).round
        end
      when 16 # Superheated Field
        if (move.id == PBMoves::SURF || move.id == PBMoves::MUDDYWATER ||
          move.id == PBMoves::WATERPLEDGE || move.id == PBMoves::WATERSPOUT ||
          move.id == PBMoves::SPARKLINGARIA)
          basedamage=(basedamage*0.625).round
        end
        if (move.id == PBMoves::SCALD || move.id == PBMoves::STEAMERUPTION)
        basedamage=(basedamage*1.667).round
        end
      when 17 # Factory Field
        if (move.id == PBMoves::FLASHCANNON || move.id == PBMoves::GYROBALL ||
          move.id == PBMoves::MAGNETBOMB || move.id == PBMoves::GEARGRIND)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::STEAMROLLER || move.id == PBMoves::TECHNOBLAST)
          basedamage=(basedamage*1.5).round
        end
      when 18 # Shortcircuit Field
        if (move.type == PBTypes::ELECTRIC)
          basedamage=(basedamage*1.2).round
        end
        if (move.id == PBMoves::DAZZLINGGLEAM)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::DARKPULSE ||
          move.id == PBMoves::NIGHTDAZE || move.id == PBMoves::NIGHTSLASH ||
          move.id == PBMoves::SHADOWBALL || move.id == PBMoves::SHADOWPUNCH ||
          move.id == PBMoves::SHADOWCLAW || move.id == PBMoves::SHADOWSNEAK ||
          move.id == PBMoves::SHADOWFORCE || move.id == PBMoves::SHADOWBONE)
          basedamage=(basedamage*1.3).round
        end
        if (move.id == PBMoves::SURF || move.id == PBMoves::MUDDYWATER ||
          move.id == PBMoves::MAGNETBOMB || move.id == PBMoves::GYROBALL ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::GEARGRIND)
          basedamage=(basedamage*1.5).round
        end
      when 19 # Wasteland
        if (move.id == PBMoves::OCTAZOOKA || move.id == PBMoves::SLUDGE ||
          move.id == PBMoves::GUNKSHOT || move.id == PBMoves::SLUDGEWAVE ||
          move.id == PBMoves::SLUDGEBOMB)
          basedamage=(basedamage*1.2).round
        end
        if (move.id == PBMoves::SPITUP)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::VINEWHIP || move.id == PBMoves::POWERWHIP)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::MUDSLAP || move.id == PBMoves::MUDBOMB ||
          move.id == PBMoves::MUDSHOT)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::MAGNITUDE ||
          move.id == PBMoves::BULLDOZE)
          basedamage=(basedamage*0.25).round
        end
      when 20 # Ashen Beach
        if (move.id == PBMoves::MUDSLAP || move.id == PBMoves::MUDSHOT ||
          move.id == PBMoves::MUDBOMB  || move.id == PBMoves::SANDTOMB)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::HIDDENPOWER || move.id == PBMoves::STRENGTH)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::LANDSWRATH || move.id == PBMoves::THOUSANDWAVES)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::PSYCHIC)
          basedamage=(basedamage*1.2).round
        end
        if (move.id == PBMoves::STOREDPOWER || move.id == PBMoves::ZENHEADBUTT ||
          move.id == PBMoves::FOCUSBLAST || move.id == PBMoves::AURASPHERE)
          basedamage=(basedamage*1.3).round
        end
        if (move.id == PBMoves::SURF|| move.id == PBMoves::MUDDYWATER)
          basedamage=(basedamage*1.5).round
        end
      when 21 # Water Surface
        if (move.id == PBMoves::SURF || move.id == PBMoves::MUDDYWATER ||
          move.id == PBMoves::WHIRLPOOL || move.id == PBMoves::DIVE)
          basedamage=(basedamage*1.5).round
        end
      when 22 # Underwater
        if (move.id == PBMoves::WATERPULSE)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::ANCHORSHOT)
          basedamage=(basedamage*2).round
        end
      when 23 # Cave
        if move.isSoundBased?
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::ROCKTOMB)
          basedamage=(basedamage*1.5).round
        end
      when 25 # Crystal Cavern
        if (move.id == PBMoves::AURORABEAM || move.id == PBMoves::SIGNALBEAM ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::LUSTERPURGE ||
          move.id == PBMoves::DAZZLINGGLEAM || move.id == PBMoves::MIRRORSHOT ||
          move.id == PBMoves::TECHNOBLAST || move.id == PBMoves::DOOMDUMMY ||
          move.id == PBMoves::MOONGEISTBEAM || move.id == PBMoves::PHOTONGEYSER)
          basedamage=(basedamage*1.3).round
        end
        if (move.id == PBMoves::POWERGEM || move.id == PBMoves::DIAMONDSTORM ||
          move.id == PBMoves::ANCIENTPOWER || move.id == PBMoves::JUDGMENT ||
          move.id == PBMoves::ROCKSMASH || move.id == PBMoves::ROCKTOMB ||
          move.id == PBMoves::STRENGTH || move.id == PBMoves::ROCKCLIMB ||
          move.id == PBMoves::MULTIATTACK)
          basedamage=(basedamage*1.5).round
        end
      when 26 # Murkwater Surface
        if (move.id == PBMoves::MUDBOMB || move.id == PBMoves::MUDSLAP ||
          move.id == PBMoves::MUDSHOT || move.id == PBMoves::SMACKDOWN ||
          move.id == PBMoves::ACID || move.id == PBMoves::ACIDSPRAY ||
          move.id == PBMoves::BRINE || move.id == PBMoves::THOUSANDWAVES)
          basedamage=(basedamage*1.5).round
        end
      when 27 # Mountain
        if (move.id == PBMoves::VITALTHROW || move.id == PBMoves::CIRCLETHROW ||
          move.id == PBMoves::STORMTHROW)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::OMINOUSWIND || move.id == PBMoves::ICYWIND ||
          move.id == PBMoves::SILVERWIND || move.id == PBMoves::TWISTER ||
          move.id == PBMoves::RAZORWIND || move.id == PBMoves::FAIRYWIND)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::OMINOUSWIND || move.id == PBMoves::ICYWIND ||
          move.id == PBMoves::SILVERWIND || move.id == PBMoves::TWISTER ||
          move.id == PBMoves::RAZORWIND || move.id == PBMoves::FAIRYWIND ||
          move.id == PBMoves::GUST) && pbWeather==PBWeather::STRONGWINDS
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::THUNDER || move.id == PBMoves::ERUPTION||
          move.id == PBMoves::AVALANCHE)
          basedamage=(basedamage*1.5).round
        end
      when 28 # Snowy Mountain
        if (move.id == PBMoves::VITALTHROW || move.id == PBMoves::CIRCLETHROW ||
          move.id == PBMoves::STORMTHROW)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::OMINOUSWIND ||
          move.id == PBMoves::SILVERWIND || move.id == PBMoves::TWISTER ||
          move.id == PBMoves::RAZORWIND || move.id == PBMoves::FAIRYWIND)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::ICYWIND)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::OMINOUSWIND || move.id == PBMoves::ICYWIND ||
          move.id == PBMoves::SILVERWIND || move.id == PBMoves::TWISTER ||
          move.id == PBMoves::RAZORWIND || move.id == PBMoves::FAIRYWIND ||
          move.id == PBMoves::GUST) && pbWeather==PBWeather::STRONGWINDS
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::SCALD || move.id == PBMoves::STEAMERUPTION)
          basedamage=(basedamage*0.5).round
        end
        if (move.id == PBMoves::AVALANCHE || move.id == PBMoves::POWDERSNOW)
          basedamage=(basedamage*1.5).round
        end
      when 29 # Holy
        if (move.id == PBMoves::MYSTICALFIRE || move.id == PBMoves::MAGICALLEAF ||
          move.id == PBMoves::ANCIENTPOWER)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::JUDGMENT || move.id == PBMoves::SACREDFIRE)
          basedamage=(basedamage*1.2).round
        end
        if (move.id == PBMoves::PSYSTRIKE || move.id == PBMoves::AEROBLAST ||
          move.id == PBMoves::SACREDFIRE || move.id == PBMoves::ORIGINPULSE ||
          move.id == PBMoves::DOOMDUMMY || move.id == PBMoves::JUDGMENT ||
          move.id == PBMoves::MISTBALL || move.id == PBMoves::CRUSHGRIP ||
          move.id == PBMoves::LUSTERPURGE || move.id == PBMoves::SECRETSWORD ||
          move.id == PBMoves::PSYCHOBOOST || move.id == PBMoves::RELICSONG ||
          move.id == PBMoves::SPACIALREND || move.id == PBMoves::HYPERSPACEHOLE ||
          move.id == PBMoves::ROAROFTIME || move.id == PBMoves::LANDSWRATH ||
          move.id == PBMoves::PRECIPICEBLADES || move.id == PBMoves::DRAGONASCENT ||
          move.id == PBMoves::MOONGEISTBEAM || move.id == PBMoves::SUNSTEELSTRIKE ||
          move.id == PBMoves::PRISMATICLASER || move.id == PBMoves::FLEURCANNON ||
          move.id == PBMoves::DIAMONDSTORM )
          basedamage=(basedamage*1.3).round
        end
      when 30 # Mirror
        if (move.id == PBMoves::MIRRORSHOT)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::CHARGEBEAM || move.id == PBMoves::SOLARBEAM ||
          move.id == PBMoves::PSYBEAM || move.id == PBMoves::TRIATTACK ||
          move.id == PBMoves::BUBBLEBEAM || move.id == PBMoves::HYPERBEAM ||
          move.id == PBMoves::ICEBEAM || move.id == PBMoves::ORIGINPULSE ||
          move.id == PBMoves::MOONGEISTBEAM || move.id == PBMoves::FLEURCANNON) && $fecounter ==1
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::AURORABEAM || move.id == PBMoves::SIGNALBEAM ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::LUSTERPURGE ||
          move.id == PBMoves::DAZZLINGGLEAM || move.id == PBMoves::TECHNOBLAST ||
          move.id == PBMoves::DOOMDUMMY || move.id == PBMoves::PRISMATICLASER ||
          move.id == PBMoves::PHOTONGEYSER)
          basedamage=(basedamage*1.5).round
        end
        $fecounter = 0
      when 31 # Fairy Tale
        if (move.id == PBMoves::DRAININGKISS)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::NIGHTSLASH || move.id == PBMoves::LEAFBLADE || move.id == PBMoves::PSYCHOCUT ||
          move.id == PBMoves::SMARTSTRIKE || move.id == PBMoves::AIRSLASH || move.id == PBMoves::SOLARBLADE)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::MAGICALLEAF || move.id == PBMoves::MYSTICALFIRE ||
          move.id == PBMoves::ANCIENTPOWER || move.id == PBMoves::RELICSONG ||
          move.id == PBMoves::SPARKLINGARIA || move.id == PBMoves::MOONGEISTBEAM ||
          move.id == PBMoves::FLEURCANNON)
          basedamage=(basedamage*1.5).round
        end
      when 32 # Dragon's Den
        if (move.id == PBMoves::MEGAKICK)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::SMACKDOWN || move.id == PBMoves::THOUSANDARROWS)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::MAGMASTORM || move.id == PBMoves::LAVAPLUME)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::DRAGONASCENT)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::PAYDAY)
          basedamage=(basedamage*2).round
        end
      when 33 # Flower Garden
        if (move.id == PBMoves::CUT) && $fecounter > 0
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::PETALBLIZZARD || move.id == PBMoves::PETALDANCE || move.id == PBMoves::FLEURCANNON) && $fecounter == 2
          basedamage=(basedamage*1.2).round
        end
        if (move.id == PBMoves::PETALBLIZZARD || move.id == PBMoves::PETALDANCE || move.id == PBMoves::FLEURCANNON) && $fecounter > 2
          basedamage=(basedamage*1.5).round
        end
      when 34 # Starlight Arena
        if (move.id == PBMoves::AURORABEAM || move.id == PBMoves::SIGNALBEAM ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::LUSTERPURGE ||
          move.id == PBMoves::DAZZLINGGLEAM || move.id == PBMoves::MIRRORSHOT ||
          move.id == PBMoves::TECHNOBLAST || move.id == PBMoves::SOLARBEAM ||
          move.id == PBMoves::PHOTONGEYSER)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::MOONBLAST)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::DRACOMETEOR || move.id == PBMoves::METEORMASH ||
          move.id == PBMoves::COMETPUNCH || move.id == PBMoves::SPACIALREND ||
          move.id == PBMoves::SWIFT || move.id == PBMoves::HYPERSPACEHOLE ||
          move.id == PBMoves::HYPERSPACEFURY || move.id == PBMoves::MOONGEISTBEAM ||
          move.id == PBMoves::SUNSTEELSTRIKE)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::DOOMDUMMY)
          basedamage=(basedamage*4).round
        end
      when 35 # New World
        if (move.id == PBMoves::AURORABEAM || move.id == PBMoves::SIGNALBEAM ||
          move.id == PBMoves::FLASHCANNON || move.id == PBMoves::DAZZLINGGLEAM ||
          move.id == PBMoves::MIRRORSHOT && move.id == PBMoves::PHOTONGEYSER)
          basedamage=(basedamage*1.5).round
        end
         if (move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::MAGNITUDE ||
         move.id == PBMoves::BULLDOZE)
          basedamage=(basedamage*0.25).round
        end
        if (move.id == PBMoves::EARTHPOWER || move.id == PBMoves::POWERGEM ||
          move.id == PBMoves::ERUPTION)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::PSYSTRIKE || move.id == PBMoves::AEROBLAST ||
          move.id == PBMoves::SACREDFIRE || move.id == PBMoves::MISTBALL ||
          move.id == PBMoves::LUSTERPURGE || move.id == PBMoves::ORIGINPULSE ||
          move.id == PBMoves::PRECIPICEBLADES || move.id == PBMoves::DRAGONASCENT ||
          move.id == PBMoves::PSYCHOBOOST || move.id == PBMoves::ROAROFTIME ||
          move.id == PBMoves::MAGMASTORM || move.id == PBMoves::CRUSHGRIP ||
          move.id == PBMoves::JUDGMENT || move.id == PBMoves::SEEDFLARE ||
          move.id == PBMoves::SHADOWFORCE || move.id == PBMoves::SEARINGSHOT ||
          move.id == PBMoves::VCREATE || move.id == PBMoves::SECRETSWORD ||
          move.id == PBMoves::SACREDSWORD || move.id == PBMoves::RELICSONG ||
          move.id == PBMoves::FUSIONBOLT || move.id == PBMoves::FUSIONFLARE ||
          move.id == PBMoves::ICEBURN || move.id == PBMoves::FREEZESHOCK ||
          move.id == PBMoves::BOLTSTRIKE || move.id == PBMoves::BLUEFLARE ||
          move.id == PBMoves::TECHNOBLAST || move.id == PBMoves::OBLIVIONWING ||
          move.id == PBMoves::LANDSWRATH || move.id == PBMoves::THOUSANDARROWS ||
          move.id == PBMoves::THOUSANDWAVES || move.id == PBMoves::DIAMONDSTORM ||
          move.id == PBMoves::STEAMERUPTION || move.id == PBMoves::COREENFORCER ||
          move.id == PBMoves::FLEURCANNON || move.id == PBMoves::PRISMATICLASER ||
          move.id == PBMoves::SUNSTEELSTRIKE || move.id == PBMoves::SPECTRALTHIEF ||
          move.id == PBMoves::MOONGEISTBEAM || move.id == PBMoves::MULTIATTACK ||
          move.id == PBMoves::MINDBLOWN || move.id == PBMoves::PLASMAFISTS)
          basedamage=(basedamage*1.5).round
        end
        if (move.id == PBMoves::VACUUMWAVE || move.id == PBMoves::DRACOMETEOR ||
          move.id == PBMoves::METEORMASH || move.id == PBMoves::MOONBLAST ||
          move.id == PBMoves::COMETPUNCH || move.id == PBMoves::SWIFT ||
          move.id == PBMoves::HYPERSPACEHOLE || move.id == PBMoves::SPACIALREND ||
          move.id == PBMoves::HYPERSPACEFURY|| move.id == PBMoves::ANCIENTPOWER ||
          move.id == PBMoves::FUTUREDUMMY)
          basedamage=(basedamage*2).round
        end
        if (move.id == PBMoves::DOOMDUMMY)
          basedamage=(basedamage*4).round
        end
      when 37 # Psychic Terrain
          if (move.id == PBMoves::HEX || move.id == PBMoves::MAGICALLEAF ||
            move.id == PBMoves::MYSTICALFIRE || move.id == PBMoves::MOONBLAST ||
            move.id == PBMoves::AURASPHERE || move.id == PBMoves::MINDBLOWN)
            basedamage=(basedamage*1.5).round
          end
      end
    end

    #Glitch field attack power adjustment
    if skill>=PBTrainerAI.highSkill
      if $fefieldeffect == 24 && type>=0 && move.pbIsSpecial?(type)
        if (attitemworks && attacker.item == PBItems::ASSAULTVEST)
          if gl1 < gl2
            atk=(atk*1.5).round
          end
        end
        if (attitemworks && attacker.item == PBItems::EVIOLITE) &&
          pbGetEvolvedFormData(attacker.species).length>0
          if gl1 < gl2
            atk=(atk*1.5).round
          end
        end
        if (attitemworks && attacker.item == PBItems::DEEPSEASCALE) &&
          (attacker.species == PBSpecies::CLAMPERL)
          if gl1 < gl2
            atk=(atk*2).round
          end
        end
        if (attitemworks && attacker.item == PBItems::METALPOWDER) &&
          (attacker.species == PBSpecies::DITTO)
          if gl1 < gl2
            atk=(atk*1.5).round
          end
        end
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::FLOWERGIFT) && pbWeather==PBWeather::SUNNYDAY
          if gl1 < gl2
            atk=(atk*1.5).round
          end
        end
      end
    end

    if skill>=PBTrainerAI.mediumSkill
      ############ ATTACKER ABILITY CHECKS ############
      if !attacker.abilitynulled
        #Technician
        if attacker.ability == PBAbilities::TECHNICIAN
          if (basedamage<=60) || ($fefieldeffect == 17 && basedamage<=80)
            basedamage=(basedamage*1.5).round
          end
        # Iron Fist
        elsif attacker.ability == PBAbilities::IRONFIST
          if move.isPunchingMove?
            basedamage=(basedamage*1.2).round
          end
        # Strong Jaw
        elsif attacker.ability == PBAbilities::STRONGJAW
          if (move.id == PBMoves::BITE || move.id == PBMoves::CRUNCH ||
            move.id == PBMoves::THUNDERFANG || move.id == PBMoves::FIREFANG ||
            move.id == PBMoves::ICEFANG || move.id == PBMoves::POISONFANG ||
            move.id == PBMoves::HYPERFANG || move.id == PBMoves::PSYCHICFANGS)
            basedamage=(basedamage*1.5).round
          end
        #Tough Claws
        elsif attacker.ability == PBAbilities::TOUGHCLAWS
          if move.isContactMove?
            basedamage=(basedamage*1.3).round
          end
        # Reckless
        elsif attacker.ability == PBAbilities::RECKLESS
          if @function==0xFA ||  # Take Down, etc.
              @function==0xFB ||  # Double-Edge, etc.
              @function==0xFC ||  # Head Smash
              @function==0xFD ||  # Volt Tackle
              @function==0xFE ||  # Flare Blitz
              @function==0x10B || # Jump Kick, Hi Jump Kick
              @function==0x130    # Shadow End
            basedamage=(basedamage*1.2).round
          end
        # Flare Boost
        elsif attacker.ability == PBAbilities::FLAREBOOST
          if (attacker.status==PBStatuses::BURN || $fefieldeffect == 7) && move.pbIsSpecial?(type)
            basedamage=(basedamage*1.5).round
          end
        # Toxic Boost
        elsif attacker.ability == PBAbilities::TOXICBOOST
          if (attacker.status==PBStatuses::POISON ||
          $fefieldeffect == 10 || $fefieldeffect == 11 ||
          $fefieldeffect == 19 || $fefieldeffect == 26) && move.pbIsPhysical?(type)
            basedamage=(basedamage*1.5).round
          end
        # Rivalry
        elsif attacker.ability == PBAbilities::RIVALRY
          if attacker.gender!=2 && opponent.gender!=2
            if attacker.gender==opponent.gender
              basedamage=(basedamage*1.25).round
            else
              basedamage=(basedamage*0.75).round
            end
          end
        # Sand Force
        elsif attacker.ability == PBAbilities::SANDFORCE
          if pbWeather==PBWeather::SANDSTORM && (type == PBTypes::ROCK ||
            (type == PBTypes::GROUND) || type == PBTypes::STEEL)
            basedamage=(basedamage*1.3).round
          end
        # Analytic
        elsif attacker.ability == PBAbilities::ANALYTIC
          if opponent.hasMovedThisRound?
            basedamage = (basedamage*1.3).round
          end
        # Sheer Force
        elsif attacker.ability == PBAbilities::SHEERFORCE
          if move.addlEffect>0
            basedamage=(basedamage*1.3).round
          end
        # Normalize
        elsif attacker.ability == PBAbilities::NORMALIZE
          type=PBTypes::NORMAL
          basedamage=(basedamage*1.2).round
        # Hustle
        elsif attacker.ability == PBAbilities::HUSTLE
          if move.pbIsPhysical?(type)
            atk=(atk*1.5).round
          end
        # Guts
        elsif attacker.ability == PBAbilities::GUTS
          if attacker.status!=0 && move.pbIsPhysical?(type)
          atk=(atk*1.5).round
          end
        #Plus/Minus
        elsif attacker.ability == PBAbilities::PLUS ||  attacker.ability == PBAbilities::MINUS
          if move.pbIsSpecial?(type)
            partner=attacker.pbPartner
            if (!partner.abilitynulled && partner.ability == PBAbilities::PLUS) || (!partner.abilitynulled && partner.ability == PBAbilities::MINUS)
              atk=(atk*1.5).round
            elsif $fefieldeffect == 18 && skill>=PBTrainerAI.bestSkill
              atk=(atk*1.5).round
            end
          end
        #Defeatist
        elsif attacker.ability == PBAbilities::DEFEATIST
          if attacker.hp<=(attacker.totalhp/2.0).floor
            atk=(atk*0.5).round
          end
        #Pure/Huge Power
        elsif attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::HUGEPOWER
          if skill>=PBTrainerAI.bestSkill
            if attacker.ability == PBAbilities::PUREPOWER && $fefieldeffect==37
              if move.pbIsSpecial?(type)
                atk=(atk*2.0).round
              end
            else
              if move.pbIsPhysical?(type)
                atk=(atk*2.0).round
              end
            end
          elsif move.pbIsPhysical?(type)
            atk=(atk*2.0).round
          end
        #Solar Power
        elsif attacker.ability == PBAbilities::SOLARPOWER
          if pbWeather==PBWeather::SUNNYDAY && move.pbIsSpecial?(type)
            atk=(atk*1.5).round
          end
        #Flash Fire
        elsif attacker.ability == PBAbilities::FLASHFIRE
          if attacker.effects[PBEffects::FlashFire] && type == PBTypes::FIRE
            atk=(atk*1.5).round
          end
        #Slow Start
        elsif attacker.ability == PBAbilities::SLOWSTART
          if attacker.turncount<5 && move.pbIsPhysical?(type)
            atk=(atk*0.5).round
          end
        # Type Changing Abilities
        elsif type == PBTypes::NORMAL && attacker.ability != PBAbilities::NORMALIZE
          # Aerilate
          if attacker.ability == PBAbilities::AERILATE
            type=PBTypes::FLYING
            basedamage=(basedamage*1.2).round
          # Galvanize
          elsif attacker.ability == PBAbilities::GALVANIZE
            type=PBTypes::ELECTRIC
            if skill>=PBTrainerAI.bestSkill
              if $fefieldeffect == 1 || $fefieldeffect == 17 # Electric or Factory Fields
                basedamage=(basedamage*1.5).round
              elsif $fefieldeffect == 18 # Short-Circuit Field
                basedamage=(basedamage*2).round
              else
                basedamage=(basedamage*1.2).round
              end
            else
              basedamage=(basedamage*1.2).round
            end
          # Pixilate
          elsif attacker.ability == PBAbilities::PIXILATE
            if skill>=PBTrainerAI.bestSkill
              type=PBTypes::FAIRY unless $fefieldeffect == 24
              if $fefieldeffect == 3 # Misty Field
                basedamage=(basedamage*1.5).round
              else
                basedamage=(basedamage*1.2).round
              end
            else
              type=PBTypes::FAIRY
              basedamage=(basedamage*1.2).round
            end
          # Refrigerate
          elsif attacker.ability == PBAbilities::REFRIGERATE
            type=PBTypes::ICE
            if skill>=PBTrainerAI.bestSkill
              if $fefieldeffect == 13 || $fefieldeffect == 28 # Icy Fields
                basedamage=(basedamage*1.5).round
              else
                basedamage=(basedamage*1.2).round
              end
            else
              basedamage=(basedamage*1.2).round
            end
          end
        end
      end

      ############ OPPONENT ABILITY CHECKS ############
      if !opponent.abilitynulled && !(opponent.moldbroken)
        # Heatproof
        if opponent.ability == PBAbilities::HEATPROOF
          if type == PBTypes::FIRE
            basedamage=(basedamage*0.5).round
          end
        # Dry Skin
        elsif opponent.ability == PBAbilities::DRYSKIN
          if type == PBTypes::FIRE
            basedamage=(basedamage*1.25).round
          end
        elsif opponent.ability == PBAbilities::THICKFAT
          if type == PBTypes::ICE || type == PBTypes::FIRE
           atk=(atk*0.5).round
          end
        end
      end

      ############ ATTACKER ITEM CHECKS ############
      if attitemworks #don't bother with this if it doesn't work
        #Type-boosting items
        case type
        when 0
          if attacker.item == PBItems::SILKSCARF
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::NORMALGEM
            basedamage=(basedamage*1.3).round
          end
        when 1
          if (attacker.item == PBItems::BLACKBELT || attacker.item == PBItems::FISTPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::FIGHTINGGEM
            basedamage=(basedamage*1.3).round
          end
        when 2
          if (attacker.item == PBItems::SHARPBEAK || attacker.item == PBItems::SKYPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::FLYINGGEM
            basedamage=(basedamage*1.3).round
          end
        when 3
          if (attacker.item == PBItems::POISONBARB || attacker.item == PBItems::TOXICPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::POISONGEM
            basedamage=(basedamage*1.3).round
          end
        when 4
          if (attacker.item == PBItems::SOFTSAND || attacker.item == PBItems::EARTHPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::GROUNDGEM
            basedamage=(basedamage*1.3).round
          end
        when 5
          if (attacker.item == PBItems::HARDSTONE || attacker.item == PBItems::STONEPLATE || attacker.item == PBItems::ROCKINCENSE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::ROCKGEM
            basedamage=(basedamage*1.3).round
          end
        when 6
          if (attacker.item == PBItems::SILVERPOWDER || attacker.item == PBItems::INSECTPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::BUGGEM
            basedamage=(basedamage*1.3).round
          end
        when 7
          if (attacker.item == PBItems::SPELLTAG || attacker.item == PBItems::SPOOKYPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::GHOSTGEM
            basedamage=(basedamage*1.3).round
          end
        when 8
          if (attacker.item == PBItems::METALCOAT || attacker.item == PBItems::IRONPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::STEELGEM
            basedamage=(basedamage*1.3).round
          end
        when 9 #?????
        when 10
          if (attacker.item == PBItems::CHARCOAL || attacker.item == PBItems::FLAMEPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::FIREGEM
            basedamage=(basedamage*1.3).round
          end
        when 11
          if (attacker.item == PBItems::MYSTICWATER || attacker.item == PBItems::SPLASHPLATE ||
              attacker.item == PBItems::SEAINCENSE || attacker.item == PBItems::WAVEINCENSE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::WATERGEM
            basedamage=(basedamage*1.3).round
          end
        when 12
          if (attacker.item == PBItems::MIRACLESEED || attacker.item == PBItems::MEADOWPLATE || attacker.item == PBItems::ROSEINCENSE) #it me
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::GRASSGEM
            basedamage=(basedamage*1.3).round
          end
        when 13
          if (attacker.item == PBItems::MAGNET || attacker.item == PBItems::ZAPPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::ELECTRICGEM
            basedamage=(basedamage*1.3).round
          end
        when 14
          if (attacker.item == PBItems::TWISTEDSPOON || attacker.item == PBItems::MINDPLATE || attacker.item == PBItems::ODDINCENSE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::PSYCHICGEM
            basedamage=(basedamage*1.3).round
          end
        when 15
          if (attacker.item == PBItems::NEVERMELTICE || attacker.item == PBItems::ICICLEPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::ICEGEM
            basedamage=(basedamage*1.3).round
          end
        when 16
          if (attacker.item == PBItems::DRAGONFANG || attacker.item == PBItems::DRACOPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::DRAGONGEM
            basedamage=(basedamage*1.3).round
          end
        when 17
          if (attacker.item == PBItems::BLACKGLASSES || attacker.item == PBItems::DREADPLATE)
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::DARKGEM
            basedamage=(basedamage*1.3).round
          end
        when 18
          if attacker.item == PBItems::PIXIEPLATE
            basedamage=(basedamage*1.2).round
          elsif attacker.item == PBItems::FAIRYGEM
            basedamage=(basedamage*1.3).round
          end
        end
        # Muscle Band
        if attacker.item == PBItems::MUSCLEBAND && move.pbIsPhysical?(type)
          basedamage=(basedamage*1.1).round
        # Wise Glasses
        elsif attacker.item == PBItems::WISEGLASSES && move.pbIsSpecial?(type)
          basedamage=(basedamage*1.1).round
        # Legendary Orbs
        elsif attacker.item == PBItems::LUSTROUSORB
          if (attacker.species == PBSpecies::PALKIA) && (type == PBTypes::DRAGON || type == PBTypes::WATER)
            basedamage=(basedamage*1.2).round
          end
        elsif attacker.item == PBItems::ADAMANTORB
          if (attacker.species == PBSpecies::DIALGA) && (type == PBTypes::DRAGON || type == PBTypes::STEEL)
            basedamage=(basedamage*1.2).round
          end
        elsif attacker.item == PBItems::GRISEOUSORB
          if (attacker.species == PBSpecies::GIRATINA) && (type == PBTypes::DRAGON || type == PBTypes::GHOST)
            basedamage=(basedamage*1.2).round
          end
        elsif attacker.item == PBItems::SOULDEW
          if (attacker.species == PBSpecies::LATIAS) || (attacker.species == PBSpecies::LATIOS) &&
            (type == PBTypes::DRAGON || type == PBTypes::PSYCHIC)
            basedamage=(basedamage*1.2).round
          end
        end
      end

      ############ MISC CHECKS ############
      # Charge
      if attacker.effects[PBEffects::Charge]>0 && type == PBTypes::ELECTRIC
        basedamage=(basedamage*2.0).round
      end
      # Helping Hand
      if attacker.effects[PBEffects::HelpingHand]
        basedamage=(basedamage*1.5).round
      end
      # Water/Mud Sport
      if type == PBTypes::FIRE
        if @field.effects[PBEffects::WaterSport]>0
          basedamage=(basedamage*0.33).round
        end
      elsif type == PBTypes::ELECTRIC
        if @field.effects[PBEffects::MudSport]>0
          basedamage=(basedamage*0.33).round
        end
      # Dark Aura/Aurabreak
      elsif type == PBTypes::DARK
        for i in @battlers
          if i.ability == PBAbilities::DARKAURA
            breakaura=0
            for j in @battlers
              if j.ability == PBAbilities::AURABREAK
                breakaura+=1
              end
            end
            if breakaura!=0
              basedamage=(basedamage*2/3).round
            else
              basedamage=(basedamage*1.33).round
            end
          end
        end
      # Fairy Aura/Aurabreak
      elsif type == PBTypes::FAIRY
        for i in @battlers
          if i.ability == PBAbilities::FAIRYAURA
            breakaura=0
            for j in @battlers
              if j.ability == PBAbilities::AURABREAK
                breakaura+=1
              end
            end
            if breakaura!=0
              basedamage=(basedamage*2/3).round
            else
              basedamage=(basedamage*1.3).round
            end
          end
        end
      end
      #Battery
      if (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::BATTERY) && move.pbIsSpecial?(type)
        atk=(atk*1.3).round
      end
      #Flower Gift
      if pbWeather==PBWeather::SUNNYDAY && move.pbIsPhysical?(type)
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::FLOWERGIFT) &&
           (attacker.species == PBSpecies::CHERRIM)
          atk=(atk*1.5).round
        end
        if (!attacker.pbPartner.abilitynulled && attacker.pbPartner.ability == PBAbilities::FLOWERGIFT) &&
           attacker.pbPartner.species == PBSpecies::CHERRIM
          atk=(atk*1.5).round
        end
      end
    end

    # Pinch Abilities
    if !attacker.abilitynulled
      if skill>=PBTrainerAI.bestSkill
        if $fefieldeffect == 7 && attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE
          atk=(atk*1.5).round
        elsif $fefieldeffect == 15 && attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS
          atk=(atk*1.5).round
        elsif $fefieldeffect == 15 && attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG
          atk=(atk*1.5).round
        elsif ($fefieldeffect == 21 || $fefieldeffect == 22) && attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER
          atk=(atk*1.5).round
        elsif $fefieldeffect == 33 && attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG
          atk=(atk*1.5).round if $fecounter == 0 || $fecounter == 1
          atk=(atk*2).round if $fecounter == 2 || $fecounter == 3
          atk=(atk*3).round if $fecounter == 4
        elsif $fefieldeffect == 33 && attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS
          case $fecounter
          when 1
            if attacker.hp<=(attacker.totalhp*0.67).floor
              atk=(atk*1.5).round
            end
          when 2
              atk=(atk*1.5).round
          when 3
              atk=(atk*2).round
          when 4
              atk=(atk*3).round
          end
        else
          if attacker.ability == PBAbilities::OVERGROW
            if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::GRASS
              atk=(atk*1.5).round
            end
          elsif attacker.ability == PBAbilities::BLAZE
            if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::FIRE
              atk=(atk*1.5).round
            end
          elsif attacker.ability == PBAbilities::TORRENT
            if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::WATER
              atk=(atk*1.5).round
            end
          elsif attacker.ability == PBAbilities::SWARM
            if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::BUG
              atk=(atk*1.5).round
            end
          end
        end
      elsif skill>=PBTrainerAI.mediumSkill
        if attacker.ability == PBAbilities::OVERGROW
          if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::GRASS
            atk=(atk*1.5).round
          end
        elsif attacker.ability == PBAbilities::BLAZE
          if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::FIRE
            atk=(atk*1.5).round
          end
        elsif attacker.ability == PBAbilities::TORRENT
          if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::WATER
            atk=(atk*1.5).round
          end
        elsif attacker.ability == PBAbilities::SWARM
          if attacker.hp<=(attacker.totalhp/3.0).floor || type == PBTypes::BUG
            atk=(atk*1.5).round
          end
        end
      end
    end

    # Attack-boosting items
    if skill>=PBTrainerAI.highSkill
      if (attitemworks && attacker.item == PBItems::THICKCLUB)
        if ((attacker.species == PBSpecies::CUBONE) || (attacker.species == PBSpecies::MAROWAK)) && move.pbIsPhysical?(type)
          atk=(atk*2.0).round
        end
      elsif (attitemworks && attacker.item == PBItems::DEEPSEATOOTH)
        if (attacker.species == PBSpecies::CLAMPERL) && move.pbIsSpecial?(type)
          atk=(atk*2.0).round
        end
      elsif (attitemworks && attacker.item == PBItems::LIGHTBALL)
        if (attacker.species == PBSpecies::PIKACHU)
          atk=(atk*2.0).round
        end
      elsif (attitemworks && attacker.item == PBItems::CHOICEBAND) && move.pbIsPhysical?(type)
        atk=(atk*1.5).round
      elsif (attitemworks && attacker.item == PBItems::CHOICESPECS) && move.pbIsSpecial?(type)
        atk=(atk*1.5).round
      end
    end

    #Specific ability field boosts
    if skill>=PBTrainerAI.bestSkill
      if $fefieldeffect == 34 || $fefieldeffect == 35
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::VICTORYSTAR)
          atk=(atk*1.5).round
        end
        partner=attacker.pbPartner
        if partner && (!partner.abilitynulled && partner.ability == PBAbilities::VICTORYSTAR)
          atk=(atk*1.5).round
        end
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::QUEENLYMAJESTY) &&
        ($fefieldeffect==5 || $fefieldeffect==31)
       atk=(atk*1.5).round
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::LONGREACH) &&
        ($fefieldeffect==27 || $fefieldeffect==28)
        atk=(atk*1.5).round
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::CORROSION) &&
        ($fefieldeffect==10 || $fefieldeffect==11)
        atk=(atk*1.5).round
      end
    end

    # Get base defense stat
    defense=pbRoughStat(opponent,PBStats::DEFENSE,skill)
    applysandstorm=false
    if type>=0 && move.pbIsSpecial?(type)
      if move.function!=0x122 # Psyshock
        defense=pbRoughStat(opponent,PBStats::SPDEF,skill)
        if $fefieldeffect == 24
          gl1 = pbRoughStat(opponent,PBStats::SPATK,skill)
          gl2 = pbRoughStat(opponent,PBStats::SPDEF,skill)
          gl3 = opponent.stages[PBStats::SPDEF]+6
          gl4 = opponent.stages[PBStats::SPATK]+6
          if oppitemworks
            gl2 *= 1.5 if opponent.item == PBItems::ASSAULTVEST
            gl1 *= 1.5 if opponent.item == PBItems::CHOICESPECS
            gl2 *= 1.5 if opponent.item == PBItems::EVIOLITE && pbGetEvolvedFormData(opponent.species).length>0
            gl1 *= 2 if opponent.item == PBItems::DEEPSEATOOTH && opponent.species == PBSpecies::CLAMPERL
            gl1 *= 2 if opponent.item == PBItems::LIGHTBALL && opponent.species == PBSpecies::PIKACHU
            gl2 *= 2 if opponent.item == PBItems::DEEPSEASCALE && opponent.species == PBSpecies::CLAMPERL
            gl2 *= 1.5 if opponent.item == PBItems::METALPOWDER && opponent.species == PBSpecies::DITTO
          end
          if !opponent.abilitynulled
            gl1 *= 1.5 if opponent.ability == PBAbilities::FLAREBOOST && opponent.status==PBStatuses::BURN
            gl1 *= 1.5 if opponent.ability == PBAbilities::MINUS && (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::PLUS)
            gl1 *= 1.5 if opponent.ability == PBAbilities::PLUS && (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::MINUS)
            gl1 *= 1.5 if opponent.ability == PBAbilities::SOLARPOWER && pbWeather==PBWeather::SUNNYDAY
            gl2 *= 1.5 if opponent.ability == PBAbilities::FLOWERGIFT && pbWeather==PBWeather::SUNNYDAY
          end
          gl1 *= 1.3 if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::BATTERY)
          gl1=(gl1*stagemul[gl4]/stagediv[gl4]).floor
          gl2=(gl2*stagemul[gl3]/stagediv[gl3]).floor
          if gl1 > gl2
            defense=pbRoughStat(opponent,PBStats::SPATK,skill)
          end
        end
        applysandstorm=true
      end
    end
    if opponent.effects[PBEffects::PowerTrick]
      defense=pbRoughStat(opponent,PBStats::ATTACK,skill)
    end
    defense = 1 if (defense == 0 || !defense)

    #Glitch Item Checks
    if skill>=PBTrainerAI.highSkill && $fefieldeffect == 24
      if type>=0 && move.pbIsSpecial?(type) && move.function!=0x122
        # Glitch Specs
        if (oppitemworks && opponent.item == PBItems::CHOICESPECS)
          if gl1 > gl2
            defense=(defense*1.5).round
          end
        # Glitchsea Tooth
        elsif (oppitemworks && opponent.item == PBItems::DEEPSEATOOTH) && (opponent.species == PBSpecies::CLAMPERL)
          if gl1 > gl2
            defense=(defense*2).round
          end
        elsif (oppitemworks && opponent.item == PBItems::LIGHTBALL) && (opponent.species == PBSpecies::PIKACHU)
          if gl1 > gl2
            defense=(defense*2).round
          end
        end
      end
    end

    if skill>=PBTrainerAI.mediumSkill
      # Sandstorm weather
      if pbWeather==PBWeather::SANDSTORM
        if opponent.pbHasType?(:ROCK) && applysandstorm
          defense=(defense*1.5).round
        end
      end
      # Defensive Abilities
      if !opponent.abilitynulled
        if opponent.ability == PBAbilities::MARVELSCALE
          if move.pbIsPhysical?(type)
            if opponent.status>0
              defense=(defense*1.5).round
            elsif ($fefieldeffect == 3 || $fefieldeffect == 9 ||
              $fefieldeffect == 31 || $fefieldeffect == 32 || $fefieldeffect == 34) &&
              skill>=PBTrainerAI.bestSkill
              defense=(defense*1.5).round
            end
          end
        elsif opponent.ability == PBAbilities::GRASSPELT
          if move.pbIsPhysical?(type) && ($fefieldeffect == 2 || $fefieldeffect == 15) # Grassy Field
            defense=(defense*1.5).round
          end
        elsif opponent.ability == PBAbilities::FLUFFY && !(opponent.moldbroken)
          if move.isContactMove? && !(!attacker.abilitynulled && attacker.ability == PBAbilities::LONGREACH)
            defense=(defense*2).round
          end
          if type == PBTypes::FIRE
            defense=(defense*0.5).round
          end
        elsif opponent.ability == PBAbilities::FURCOAT
          if move.pbIsPhysical?(type) && !(opponent.moldbroken)
            defense=(defense*2).round
          end
        end
      end
      if (pbWeather==PBWeather::SUNNYDAY || $fefieldeffect == 33) && move.pbIsSpecial?(type)
        if (!opponent.abilitynulled && opponent.ability == PBAbilities::FLOWERGIFT) &&
           (opponent.species == PBSpecies::CHERRIM)
          defense=(defense*1.5).round
        end
        if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::FLOWERGIFT) && opponent.pbPartner.species == PBSpecies::CHERRIM
          defense=(defense*1.5).round
        end
      end
    end

    # Various field boosts
    if skill>=PBTrainerAI.bestSkill
      if $fefieldeffect == 3 && move.pbIsSpecial?(type) && opponent.pbHasType?(:FAIRY)
        defense=(defense*1.5).round
      end
      if $fefieldeffect == 12 && move.pbIsSpecial?(type) && opponent.pbHasType?(:GROUND)
        defense=(defense*1.5).round
      end
      if $fefieldeffect == 22 && move.pbIsPhysical?(type) && !type == PBTypes::WATER
        defense=(defense*1.5).round
      end
    end

    # Defense-boosting items
    if skill>=PBTrainerAI.highSkill
      if (oppitemworks && opponent.item == PBItems::EVIOLITE)
        evos=pbGetEvolvedFormData(opponent.species)
        if evos && evos.length>0
          defense=(defense*1.5).round
        end
      elsif (oppitemworks && opponent.item == PBItems::ASSAULTVEST)
        if move.pbIsSpecial?(type)
          defense=(defense*1.5).round
        end
      elsif (oppitemworks && opponent.item == PBItems::DEEPSEASCALE)
        if (opponent.species == PBSpecies::CLAMPERL) && move.pbIsSpecial?(type)
          defense=(defense*2.0).round
        end
      elsif (oppitemworks && opponent.item == PBItems::METALPOWDER)
        if (opponent.species == PBSpecies::DITTO) && !opponent.effects[PBEffects::Transform] && move.pbIsPhysical?(type)
          defense=(defense*2.0).round
        end
      end
    end

    # Prism Armor & Shadow Shield
    if skill>=PBTrainerAI.bestSkill
      if ((!attacker.abilitynulled && attacker.ability == PBAbilities::PRISMARMOR) ||
        (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWSHIELD)) && $fefieldeffect==4
        defense=(defense*2.0).round
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::PRISMARMOR) && ($fefieldeffect==9 || $fefieldeffect==25)
        defense=(defense*2.0).round
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SHADOWSHIELD) && ($fefieldeffect==34 || $fefieldeffect==35)
        defense=(defense*2.0).round
      end
    end

    # Main damage calculation
    damage=(((2.0*attacker.level/5+2).floor*basedamage*atk/defense).floor/50).floor+2 if basedamage >= 0
    # Multi-targeting attacks
    if skill>=PBTrainerAI.mediumSkill
      if move.pbTargetsAll?(attacker)
        damage=(damage*0.75).round
      end
    end
    #determining if pokemon is grounded
    isgrounded=move.pbTypeModifier(PBTypes::GROUND,opponent,attacker)
    isgrounded = 4 if (isgrounded==0 && attacker.effects[PBEffects::Roost])
    isgrounded = 0 if attacker.effects[PBEffects::MagnetRise]>0
    isgrounded = 0 if attacker.ability == (PBAbilities::LEVITATE)
    isgrounded = 0 if (attitemworks && attacker.item == PBItems::AIRBALLOON)
    # Field Boosts
    if skill>=PBTrainerAI.bestSkill
      case $fefieldeffect
      when 1 # Electric Field
        if type == PBTypes::ELECTRIC
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
      when 2 # Grassy Field
        if type == PBTypes::GRASS
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
        if type == PBTypes::FIRE
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
      when 3 # Misty Field
        if type == PBTypes::DRAGON
          damage=(damage*0.5).floor
        end
      when 4 # Dark Crystal Cavern
        if type == PBTypes::DARK
          damage=(damage*1.5).floor
        end
      when 7 # Burning Field
        if type == PBTypes::FIRE
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
        if type == PBTypes::GRASS
          if isgrounded != 0
            damage=(damage*0.5).floor
          end
        end
        if type == PBTypes::ICE
          damage=(damage*0.5).floor
        end
      when 8 # Swamp Field
        if type == PBTypes::POISON
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
      when 9 # Rainbow Field
        if type == PBTypes::NORMAL &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent))
          damage=(damage*1.5).floor
        end
      when 11 # Corrosive Field
        if type == PBTypes::FIRE
          damage=(damage*1.5).floor
        end
      when 12 # DESERT Field
        if type == PBTypes::WATER
          if isgrounded != 0
            damage=(damage*0.5).floor
          end
        end
        if type == PBTypes::ELECTRIC
          if isgrounded != 0
            damage=(damage*0.5).floor
          end
        end
      when 13 # Icy Field
        if type == PBTypes::FIRE
          damage=(damage*0.5).floor
        end
        if type == PBTypes::ICE
          damage=(damage*1.5).floor
        end
      when 14 # Rocky Field
        if type == PBTypes::ROCK
          damage=(damage*1.5).floor
        end
      when 15 # Forest Field
        if type == PBTypes::GRASS
          damage=(damage*1.5).floor
        end
        if type == PBTypes::BUG &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent))
          damage=(damage*1.5).floor
        end
      when 16 # Superheated Field
        if type == PBTypes::FIRE
          damage=(damage*1.1).floor
        end
        if type == PBTypes::ICE
          damage=(damage*0.5).floor
        end
        if type == PBTypes::WATER
          damage=(damage*0.9).floor
        end
      when 17 # Factory Field
        if type == PBTypes::ELECTRIC
          damage=(damage*1.2).floor
        end
      when 21 # Water Surface
        if type == PBTypes::WATER
          damage=(damage*1.5).floor
        end
        if type == PBTypes::ELECTRIC
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
        if type == PBTypes::FIRE
          if isgrounded != 0
            damage=(damage*0.5).floor
          end
        end
      when 22 # Underwater
        if type == PBTypes::WATER
          damage=(damage*1.5).floor
        end
        if type == PBTypes::ELECTRIC
          damage=(damage*2).floor
        end
      when 23 # Cave
        if type == PBTypes::FLYING && (move.flags&0x01)==0 #not a contact move
          damage=(damage*0.5).floor
        end
        if type == PBTypes::ROCK
          damage=(damage*1.5).floor
        end
      when 24 # Glitch
        if type == PBTypes::PSYCHIC
          damage=(damage*1.2).floor
        end
      when 25 # Crystal Cavern
        if type == PBTypes::ROCK
          damage=(damage*1.5).floor
        end
        if type == PBTypes::DRAGON
          damage=(damage*1.5).floor
        end
      when 26 # Murkwater Surface
        if type == PBTypes::WATER || type == PBTypes::POISON
          damage=(damage*1.5).floor
        end
        if type == PBTypes::ELECTRIC
          if isgrounded != 0
            damage=(damage*1.3).floor
          end
        end
      when 27 # Mountain
        if type == PBTypes::ROCK
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FLYING
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FLYING &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent)) &&
          pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
      when 28 # Snowy Mountain
        if type == PBTypes::ROCK || type == PBTypes::ICE
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FLYING
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FLYING &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent)) &&
          pbWeather==PBWeather::STRONGWINDS
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FIRE
          damage=(damage*0.5).floor
        end
      when 29 # Holy Field
        if (type == PBTypes::GHOST || type == PBTypes::DARK &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent)))
          damage=(damage*0.5).floor
        end
        if (type == PBTypes::FAIRY ||(type == PBTypes::NORMAL) &&
          !move.pbIsPhysical?(move.pbType(type,attacker,opponent)))
          damage=(damage*1.5).floor
        end
        if type == PBTypes::PSYCHIC || type == PBTypes::DRAGON
          damage=(damage*1.2).floor
        end
      when 31# Fairy Tale
        if type == PBTypes::STEEL
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FAIRY
          damage=(damage*1.5).floor
        end
        if type == PBTypes::DRAGON
          damage=(damage*2).floor
        end
      when 32 # Dragon's Den
        if type == PBTypes::FIRE
          damage=(damage*1.5).floor
        end
          if type == PBTypes::ICE || type == PBTypes::WATER
          damage=(damage*0.5).floor
        end
        if type == PBTypes::DRAGON
          damage=(damage*2).floor
        end
      when 33 # Flower Field
        if type == PBTypes::GRASS
          case $fecounter
            when 1
              damage=(damage*1.2).floor
            when 2
              damage=(damage*1.5).floor
            when 3
              damage=(damage*2).floor
            when 4
              damage=(damage*3).floor
          end
        end
        if $fecounter > 1
          if type == PBTypes::FIRE
            damage=(damage*1.5).floor
          end
        end
        if $fecounter > 3
          if type == PBTypes::BUG
            damage=(damage*2).floor
          end
        elsif $fecounter > 1
          if type == PBTypes::BUG
            damage=(damage*1.5).floor
          end
        end
      when 34 # Starlight Arena
        if type == PBTypes::DARK
          damage=(damage*1.5).floor
        end
          if type == PBTypes::PSYCHIC
          damage=(damage*1.5).floor
        end
        if type == PBTypes::FAIRY
          damage=(damage*1.3).floor
        end
      when 35 # New World
        if type == PBTypes::DARK
          damage=(damage*1.5).floor
        end
      when 37 # Psychic Terrain
        if type == PBTypes::PSYCHIC
          if isgrounded != 0
            damage=(damage*1.5).floor
          end
        end
      end
    end
    if skill>=PBTrainerAI.bestSkill
      # FIELD TRANSFORMATIONS
      case $fefieldeffect
        when 2 # Grassy Field
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE) &&
           field.effects[PBEffects::WaterSport] <= 0 &&
           pbWeather != PBWeather::RAINDANCE
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::SLUDGEWAVE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 3 # Misty Field
          if (move.id == PBMoves::WHIRLWIND || move.id == PBMoves::GUST ||
           move.id == PBMoves::RAZORWIND || move.id == PBMoves::HURRICANE||
           move.id == PBMoves::DEFOG || move.id == PBMoves::TAILWIND ||
           move.id == PBMoves::TWISTER)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::CLEARSMOG || move.id == PBMoves::SMOG)
            damage=(damage*1.5).floor if damage >= 0
          end
        when 4 # Dark Crystal Cavern
          if (move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::BULLDOZE ||
           move.id == PBMoves::MAGNITUDE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 5 # Chess Field
          if (move.id == PBMoves::STOMPINGTANTRUM)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 7 # Burning Field
          if (move.id == PBMoves::SLUDGEWAVE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::WHIRLWIND || move.id == PBMoves::GUST ||
           move.id == PBMoves::RAZORWIND || move.id == PBMoves::DEFOG ||
           move.id == PBMoves::TAILWIND || move.id == PBMoves::HURRICANE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::SURF || move.id == PBMoves::MUDDYWATER ||
           move.id == PBMoves::WATERSPORT || move.id == PBMoves::WATERSPOUT ||
           move.id == PBMoves::WATERPLEDGE || move.id == PBMoves::SPARKLINGARIA)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::SANDTOMB)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 10 # Corrosive Field
          if (move.id == PBMoves::SEEDFLARE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 11 # Corrosive Mist Field
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::EXPLOSION || move.id == PBMoves::SELFDESTRUCT ||
           move.id == PBMoves::TWISTER || move.id == PBMoves::MINDBLOWN ||
           move.id == PBMoves::INCINERATE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::GUST || move.id == PBMoves::HURRICANE ||
           move.id == PBMoves::RAZORWIND)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 13 # Icy Field
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE)
            damage=(damage*1.3).floor if damage >= 0
          end
          #if (move.id == PBMoves::EARTHQUAKE || move.id == PBMoves::MAGNITUDE ||
          # move.id == PBMoves::BULLDOZE)
          # damage=(damage*1.3).floor if damage >= 0
          #end
        when 15 # Forest Field
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE) &&
           field.effects[PBEffects::WaterSport] <= 0
           pbWeather != PBWeather::RAINDANCE
            damage=(damage*1.3).floor if damage >= 0
          end
        when 16 # Superheated Field
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::SELFDESTRUCT || move.id == PBMoves::EXPLOSION ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE) &&
           pbWeather != PBWeather::RAINDANCE &&
           field.effects[PBEffects::WaterSport] <= 0
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::BLIZZARD || move.id == PBMoves::GLACIATE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 17 # Factory Field
          if (move.id == PBMoves::DISCHARGE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::EXPLOSION || move.id == PBMoves::SELFDESTRUCT ||
           move.id == PBMoves::MAGNITUDE || move.id == PBMoves::EARTHQUAKE ||
           move.id == PBMoves::BULLDOZE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 18 # Shortcircuit Field
          if (move.id == PBMoves::DISCHARGE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::PARABOLICCHARGE ||
           move.id == PBMoves::WILDCHARGE || move.id == PBMoves::CHARGEBEAM)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 21 # Water Surface
          if (move.id == PBMoves::DIVE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::BLIZZARD || move.id == PBMoves::GLACIATE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::SLUDGEWAVE)
            damage=(damage*1.5).floor if damage >= 0
          end
        when 22 # Underwater
          if (move.id == PBMoves::DIVE || move.id == PBMoves::SKYDROP ||
           move.id == PBMoves::FLY || move.id == PBMoves::BOUNCE)
            damage=(damage*1.3).floor if damage >= 0
          end
          if (move.id == PBMoves::SLUDGEWAVE)
            damage=(damage*2).floor if damage >= 0
          end
        when 23 # Cave Field
          if (move.id == PBMoves::POWERGEM || move.id == PBMoves::DIAMONDSTORM)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 25 # Crystal Cavern
          if (move.id == PBMoves::DARKPULSE || move.id == PBMoves::NIGHTDAZE ||
           move.id == PBMoves::BULLDOZE|| move.id == PBMoves::EARTHQUAKE ||
           move.id == PBMoves::MAGNITUDE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 26 # Murkwater Surface
          if (move.id == PBMoves::BLIZZARD || move.id == PBMoves::GLACIATE ||
           move.id == PBMoves::WHIRLPOOL)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 27 # Mountain
          if (move.id == PBMoves::BLIZZARD || move.id == PBMoves::GLACIATE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 28 # Snowy Mountain
          if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
           move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
           move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
           move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 30 # Mirror Arena
          if (move.id == PBMoves::BOOMBURST || move.id == PBMoves::BULLDOZE ||
           move.id == PBMoves::HYPERVOICE || move.id == PBMoves::EARTHQUAKE ||
           move.id == PBMoves::EXPLOSION || move.id == PBMoves::SELFDESTRUCT ||
           move.id == PBMoves::MAGNITUDE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 32 # Dragon's Den
          if (move.id == PBMoves::GLACIATE)
            damage=(damage*1.3).floor if damage >= 0
          end
        when 33 # Flower Garden Field
          if $fecounter > 1
            if (move.id == PBMoves::HEATWAVE || move.id == PBMoves::ERUPTION ||
             move.id == PBMoves::SEARINGSHOT || move.id == PBMoves::FLAMEBURST ||
             move.id == PBMoves::LAVAPLUME || move.id == PBMoves::FIREPLEDGE ||
             move.id == PBMoves::MINDBLOWN || move.id == PBMoves::INCINERATE) &&
             field.effects[PBEffects::WaterSport] <= 0 &&
             pbWeather != PBWeather::RAINDANCE
              damage=(damage*1.3).floor if damage >= 0
            end
          end
      end
    end
    # Weather
    if skill>=PBTrainerAI.mediumSkill
      case pbWeather
        when PBWeather::SUNNYDAY
          if field.effects[PBEffects::HarshSunlight] &&
             type == PBTypes::WATER
            damage=0
          end
          if type == PBTypes::FIRE
            damage=(damage*1.5).round
          elsif type == PBTypes::WATER
            damage=(damage*0.5).round
          end
        when PBWeather::RAINDANCE
          if field.effects[PBEffects::HeavyRain] &&
          type == PBTypes::FIRE
            damage=0
          end
          if type == PBTypes::FIRE
            damage=(damage*0.5).round
          elsif type == PBTypes::WATER
            damage=(damage*1.5).round
          end
       end
    end

    outgoingdamage = false
    if attacker.index == 2 && pbOwnedByPlayer?(attacker.index) == false
      if opponent.index==1 || opponent.index==3
        outgoingdamage = true
      end
    else
      if opponent.index==0 || opponent.index==2
        outgoingdamage = true
      end
    end
    if outgoingdamage == true
      random=85
      damage=(damage*random/100.0).floor
    end
    # Water Bubble
    if skill>=PBTrainerAI.mediumSkill
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::WATERBUBBLE) && type == PBTypes::WATER
        damage=(damage*=2).round
      end
      # STAB
      if (attacker.pbHasType?(type) || (!attacker.abilitynulled && attacker.ability == PBAbilities::PROTEAN))
        if (!attacker.abilitynulled && attacker.ability == PBAbilities::ADAPTABILITY)
          damage=(damage*2).round
        else
          damage=(damage*1.5).round
        end
      elsif ((!attacker.abilitynulled && attacker.ability == PBAbilities::STEELWORKER) && type == PBTypes::STEEL)
        if $fefieldeffect==17 # Factory Field
          damage=(damage*2).round
        else
          damage=(damage*1.5).round
        end
      end
    end
    # Type effectiveness
    #typemod=pbTypeModifier(type,attacker,opponent)
    typemod=pbTypeModNoMessages(type,attacker,opponent,move,skill)
    if skill>=PBTrainerAI.minimumSkill
      damage=(damage*typemod/4.0).round
    end
    # Water Bubble
    if skill>=PBTrainerAI.mediumSkill
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::WATERBUBBLE) && type == PBTypes::FIRE
        damage=(damage*=0.5).round
      end
      # Burn
      if attacker.status==PBStatuses::BURN && move.pbIsPhysical?(type) &&
         !(!attacker.abilitynulled && attacker.ability == PBAbilities::GUTS)
        damage=(damage*0.5).round
      end
    end
    # Make sure damage is at least 1
    damage=1 if damage<1
    # Screens
    if skill>=PBTrainerAI.highSkill
      if move.pbIsPhysical?(type)
        if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 || opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          if !opponent.pbPartner.isFainted?
            damage=(damage*0.66).round
          else
            damage=(damage*0.5).round
          end
        end
      elsif move.pbIsSpecial?(type)
        if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 || opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
          if !opponent.pbPartner.isFainted?
            damage=(damage*0.66).round
          else
            damage=(damage*0.5).round
          end
        end
      end
    end

    # Multiscale
    if skill>=PBTrainerAI.mediumSkill
      if !opponent.abilitynulled
        if opponent.ability == PBAbilities::MULTISCALE || opponent.ability == PBAbilities::SHADOWSHIELD
          if opponent.hp==opponent.totalhp
            damage=(damage*0.5).round
          end

        elsif opponent.ability == PBAbilities::SOLIDROCK || opponent.ability == PBAbilities::FILTER || opponent.ability == PBAbilities::PRISMARMOR
          if typemod>4
            damage=(damage*0.75).round
          end
        end
      end
      if (!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::FRIENDGUARD)
        damage=(damage*0.75).round
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::STAKEOUT) && switchedOut[opponent.index]
        damage=(damage*2.0).round
      end
    end

    # Tinted Lens
    if skill>=PBTrainerAI.mediumSkill
      if !attacker.abilitynulled && attacker.ability == PBAbilities::TINTEDLENS && typemod<4
        damage=(damage*2.0).round
      end
    end

    # Neuroforce
    if skill>=PBTrainerAI.mediumSkill
      if !attacker.abilitynulled && attacker.ability == PBAbilities::NEUROFORCE && typemod>4
        damage=(damage*1.25).round
      end
    end

    # Flower Veil + Flower Garden Shenanigans
    if skill>=PBTrainerAI.bestSkill
      if $fefieldeffect == 33 && $fecounter >1
        if ((!opponent.pbPartner.abilitynulled && opponent.pbPartner.ability == PBAbilities::FLOWERVEIL) &&
         opponent.pbHasType?(:GRASS)) ||
         (!opponent.abilitynulled && opponent.ability == PBAbilities::FLOWERVEIL)
          damage=(damage*0.5).round
        end
        case $fecounter
        when 2
          if opponent.pbHasType?(:GRASS)
            damage=(damage*0.75).round
          end
        when 3
          if opponent.pbHasType?(:GRASS)
            damage=(damage*0.67).round
          end
        when 4
          if opponent.pbHasType?(:GRASS)
            damage=(damage*0.5).round
          end
        end
      end
    end
    # Final damage-altering items
    if skill>=PBTrainerAI.highSkill
      if (attitemworks && attacker.item == PBItems::METRONOME)
        if attacker.effects[PBEffects::Metronome]>4
          damage=(damage*2.0).round
        else
          met=1.0+attacker.effects[PBEffects::Metronome]*0.2
          damage=(damage*met).round
        end
      elsif (attitemworks && attacker.item == PBItems::EXPERTBELT) && typemod>4
        damage=(damage*1.2).round
      elsif (attitemworks && attacker.item == PBItems::LIFEORB)
        damage=(damage*1.3).round
      elsif typemod>4 && oppitemworks
        #SE Damage reducing berries
        if (opponent.item == (PBItems::CHOPLEBERRY) && type == PBTypes::FIGHTING) ||
           (opponent.item == (PBItems::COBABERRY) && type == PBTypes::FLYING) ||
           (opponent.item == (PBItems::KEBIABERRY) && type == PBTypes::POISON) ||
           (opponent.item == (PBItems::SHUCABERRY) && (type == PBTypes::GROUND)) ||
           (opponent.item == (PBItems::CHARTIBERRY) && type == PBTypes::ROCK) ||
           (opponent.item == (PBItems::TANGABERRY) && type == PBTypes::BUG) ||
           (opponent.item == (PBItems::KASIBBERRY) && type == PBTypes::GHOST) ||
           (opponent.item == (PBItems::BABIRIBERRY) && type == PBTypes::STEEL) ||
           (opponent.item == (PBItems::OCCABERRY) && type == PBTypes::FIRE) ||
           (opponent.item == (PBItems::PASSHOBERRY) && type == PBTypes::WATER) ||
           (opponent.item == (PBItems::RINDOBERRY) && type == PBTypes::GRASS) ||
           (opponent.item == (PBItems::WACANBERRY) && type == PBTypes::ELECTRIC) ||
           (opponent.item == (PBItems::PAYAPABERRY) && type == PBTypes::PSYCHIC) ||
           (opponent.item == (PBItems::YACHEBERRY) && type == PBTypes::ICE) ||
           (opponent.item == (PBItems::HABANBERRY) && type == PBTypes::DRAGON) ||
           (opponent.item == (PBItems::COLBURBERRY) && type == PBTypes::DARK) ||
           (opponent.item == (PBItems::ROSELIBERRY) && type == PBTypes::FAIRY)
          if opponent.ability == (PBAbilities::RIPEN)
            damage=(damage*0.25).round
          else
            damage=(damage*0.5).round
          end
        end
      end
    end
    # pbModifyDamage - TODO
    # "AI-specific calculations below"
    # Increased critical hit rates
    if skill>=PBTrainerAI.mediumSkill
      critrate = pbAICritRate(attacker,opponent,move)
      if critrate==2
        damage=(damage*1.25).round
      elsif critrate>2
        damage=(damage*1.5).round
      end
    end
    attacker.pbUpdate(true) if defined?(megaEvolved) && megaEvolved==true #un-mega pokemon #perry
    return damage
  end

  def pbTypeModNoMessages(type,attacker,opponent,move,skill)
    return 4 if type<0
    id = move.id

    if !attacker.abilitynulled
      type=PBTypes::ELECTRIC if type == PBTypes::NORMAL && attacker.ability == PBAbilities::GALVANIZE
      type=PBTypes::FLYING if type == PBTypes::NORMAL && attacker.ability == PBAbilities::AERILATE
      type=PBTypes::FAIRY if type == PBTypes::NORMAL && attacker.ability == PBAbilities::PIXILATE
      type=PBTypes::ICE if type == PBTypes::NORMAL && attacker.ability == PBAbilities::REFRIGERATE
      type=PBTypes::NORMAL if attacker.ability == PBAbilities::NORMALIZE
    end
    if !opponent.abilitynulled && !(opponent.moldbroken)
      if opponent.ability == PBAbilities::SAPSIPPER
        return 0 if type == PBTypes::GRASS || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::GRASS
      elsif opponent.ability == PBAbilities::LEVITATE
        return 0 if type == PBTypes::GROUND || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::GROUND
      elsif opponent.ability == PBAbilities::STORMDRAIN
        return 0 if type == PBTypes::WATER || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER
      elsif opponent.ability == PBAbilities::LIGHTNINGROD
        return 0 if type == PBTypes::ELECTRIC || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC
      elsif opponent.ability == PBAbilities::MOTORDRIVE
        return 0 if type == PBTypes::ELECTRIC || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC
      elsif opponent.ability == PBAbilities::DRYSKIN
        return 0 if type == PBTypes::WATER || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER && opponent.effects[PBEffects::HealBlock]==0
      elsif opponent.ability == PBAbilities::VOLTABSORB
        return 0 if type == PBTypes::ELECTRIC || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::ELECTRIC && opponent.effects[PBEffects::HealBlock]==0
      elsif opponent.ability == PBAbilities::WATERABSORB
        return 0 if type == PBTypes::WATER || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::WATER && opponent.effects[PBEffects::HealBlock]==0
      elsif opponent.ability == PBAbilities::BULLETPROOF
        return 0 if (PBStuff::BULLETMOVE).include?(id)
      elsif opponent.ability == PBAbilities::FLASHFIRE
        return 0 if type == PBTypes::FIRE || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE
      elsif opponent.ability == PBAbilities::MAGMAARMOR
        return 0 if (type == PBTypes::FIRE || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE) && $fefieldeffect == 32
      elsif move.basedamage>0 && opponent.ability == PBAbilities::TELEPATHY
        partner=attacker.pbPartner
        if opponent.index == partner.index
          return 0
        end
      end
    end
    if $fefieldeffect == 14 && (opponent.effects[PBEffects::Substitute]>0 || opponent.stages[PBStats::EVASION] > 0)
      return 0 if (PBStuff::BULLETMOVE).include?(id)
    end
    if ($fefieldeffect == 21 || $fefieldeffect == 26) &&
      ((type == PBTypes::GROUND) || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::GROUND)
      return 0
    end
    if $fefieldeffect == 22 && (type == PBTypes::FIRE || move.FieldTypeChange(attacker,opponent,1,true)==PBTypes::FIRE)
      return 0
    end
    # UPDATE Implementing Flying Press + Freeze Dry
    faintedcount=0
    for i in pbParty(opponent.index)
      next if i.nil?
      faintedcount+=1 if (i.hp==0 && i.hp!=0)
    end
    if opponent.effects[PBEffects::Illusion]
      if skill>=PBTrainerAI.bestSkill
        if !(opponent.turncount>1 || faintedcount>2)
          zorovar=true
        else
          zorovar=false
        end
      elsif skill>=PBTrainerAI.highSkill
        if !(faintedcount>4)
          zorovar=true
        else
          zorovar=false
        end
      else
        zorovar = true
      end
    else
      zorovar=false
    end
    typemod=move.pbTypeModifier(type,attacker,opponent,zorovar)
    typemod2= nil
    typemod3= nil
    if type == PBTypes::WATER &&
     (opponent.pbHasType?(PBTypes::WATER)) &&
      $fefieldeffect == 22
      typemod*= 2
    end
    if $fefieldeffect == 24
      if type == PBTypes::DRAGON
        typemod = 4
      end
      if type == PBTypes::GHOST && (opponent.pbHasType?(PBTypes::PSYCHIC))
        typemod = 0
      end
      if type == PBTypes::BUG && (opponent.pbHasType?(PBTypes::POISON))
        typemod*= 4
      end
      if type == PBTypes::ICE && (opponent.pbHasType?(PBTypes::FIRE))
        typemod*= 2
      end
      if type == PBTypes::POISON && (opponent.pbHasType?(PBTypes::BUG))
        typemod*= 2
      end
    end
    if $fefieldeffect == 29
      if type == PBTypes::NORMAL && (opponent.pbHasType?(PBTypes::DARK) ||
       opponent.pbHasType?(PBTypes::GHOST))
        typemod*= 2
      end
    end
    if $fefieldeffect == 31
      if type == PBTypes::STEEL && (opponent.pbHasType?(PBTypes::DRAGON))
        typemod*= 2
      end
    end
    if id == PBMoves::FREEZEDRY && (opponent.pbHasType?(PBTypes::WATER))
      typemod*= 4
    end
    if id == PBMoves::CUT && (opponent.pbHasType?(PBTypes::GRASS)) &&
     $fefieldeffect == 33 && $fecounter > 0
      typemod*= 2
    end
    if pbWeather==PBWeather::STRONGWINDS &&
     ((opponent.pbHasType?(PBTypes::FLYING)) &&
     !opponent.effects[PBEffects::Roost]) &&
     (type == PBTypes::ELECTRIC || type == PBTypes::ICE ||
     type == PBTypes::ROCK)
      typemod /= 2
    end
    if $fefieldeffect == 32 && # Dragons Den Multiscale
     (!opponent.abilitynulled && opponent.ability == PBAbilities::MULTISCALE) &&
     (type == PBTypes::FAIRY || type == PBTypes::ICE ||
     type == PBTypes::DRAGON) && !(opponent.moldbroken)
      typemod /= 2
    end
    if id == PBMoves::FLYINGPRESS
      typemod2=move.pbTypeModifier(PBTypes::FLYING,attacker,opponent,zorovar)
      typemod3= ((typemod*typemod2)/4.0)
      typemod=typemod3
    end
    # Field Effect type changes go here
    typemod=move.FieldTypeChange(attacker,opponent,typemod,false)
    if typemod==0
      if @function==0x111
        return 1
      end
    end
    return typemod
  end

  def pbAICritRate(attacker,opponent,move)
    if ((!opponent.abilitynulled && opponent.ability == PBAbilities::BATTLEARMOR) ||
        (!opponent.abilitynulled && opponent.ability == PBAbilities::SHELLARMOR)) &&
        !(opponent.moldbroken)
            return 0
    end
    return 0 if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    $buffs = 0
    if $fefieldeffect == 30
      $buffs = attacker.stages[PBStats::EVASION] if attacker.stages[PBStats::EVASION] > 0
      $buffs = $buffs.to_i + attacker.stages[PBStats::ACCURACY] if attacker.stages[PBStats::ACCURACY] > 0
      $buffs = $buffs.to_i - opponent.stages[PBStats::EVASION] if opponent.stages[PBStats::EVASION] < 0
      $buffs = $buffs.to_i - opponent.stages[PBStats::ACCURACY] if opponent.stages[PBStats::ACCURACY] < 0
      $buffs = $buffs.to_i
    end
    if attacker.effects[PBEffects::LaserFocus]>0
      return 3
    end
    return 3 if move.function==0xA0 # Frost Breath
    return 3 if (!attacker.abilitynulled && attacker.ability == PBAbilities::MERCILESS) && (opponent.status == PBStatuses::POISON ||
    $fefieldeffect==10 || $fefieldeffect==11 || $fefieldeffect==19 || $fefieldeffect==26)
    c=0
    c+=attacker.effects[PBEffects::FocusEnergy]
    c+=1 if move.hasHighCriticalRate?
    c+=1 if (!attacker.abilitynulled && attacker.ability == PBAbilities::SUPERLUCK)
    if (attacker.species == PBSpecies::FARFETCHD) && attacker.hasWorkingItem(:STICK)
      c+=2
    end
    if (attacker.species == PBSpecies::CHANSEY) && attacker.hasWorkingItem(:LUCKYPUNCH)
      c+=2
    end
    c+=1 if attacker.hasWorkingItem(:RAZORCLAW)
    c+=1 if attacker.hasWorkingItem(:SCOPELENS)
    c+=1 if attacker.speed > opponent.speed && $fefieldeffect == 24
    if $fefieldeffect == 30
      c += $buffs if $buffs > 0
    end
    c=3 if c>3
    return c
  end

  def pbRoughAccuracy(move,attacker,opponent,skill)
    # Get base accuracy
    baseaccuracy=move.accuracy
    if skill>=PBTrainerAI.mediumSkill
      if pbWeather==PBWeather::SUNNYDAY &&
         (move.function==0x08 || move.function==0x15) # Thunder, Hurricane
        accuracy=50
      end
    end
    # Accuracy stages
    accstage=attacker.stages[PBStats::ACCURACY]
    accstage=0 if (!opponent.abilitynulled && opponent.ability == PBAbilities::UNAWARE)
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    evastage=opponent.stages[PBStats::EVASION]
    evastage-=2 if @field.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=0 if opponent.effects[PBEffects::Foresight] ||
                  opponent.effects[PBEffects::MiracleEye] ||
                  move.function==0xA9 || # Chip Away
                  (!attacker.abilitynulled && attacker.ability == PBAbilities::UNAWARE)
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    accuracy*=baseaccuracy/evasion
    # Accuracy modifiers
    if skill>=PBTrainerAI.mediumSkill
      accuracy*=1.3 if (!attacker.abilitynulled && attacker.ability == PBAbilities::COMPOUNDEYES)

      accuracy*=1.1 if (!attacker.abilitynulled && attacker.ability == PBAbilities::VICTORYSTAR)
      if skill>=PBTrainerAI.highSkill
        partner=attacker.pbPartner
        accuracy*=1.1 if partner && (!partner.abilitynulled && partner.ability == PBAbilities::VICTORYSTAR)
      end

      if skill>=PBTrainerAI.highSkill
        accuracy*=0.8 if (!attacker.abilitynulled && attacker.ability == PBAbilities::HUSTLE) &&
                         move.basedamage>0 && move.pbIsPhysical?(move.pbType(move.type,attacker,opponent))
      end
      if skill>=PBTrainerAI.bestSkill
        accuracy/=2 if (!opponent.abilitynulled && opponent.ability == PBAbilities::WONDERSKIN) &&
                       move.basedamage==0 && attacker.pbIsOpposing?(opponent.index)
        accuracy/=1.2 if (!opponent.abilitynulled && opponent.ability == PBAbilities::TANGLEDFEET) &&
                         opponent.effects[PBEffects::Confusion]>0
        accuracy/=1.2 if pbWeather==PBWeather::SANDSTORM &&
                         (!opponent.abilitynulled && opponent.ability == PBAbilities::SANDVEIL)
        accuracy/=1.2 if pbWeather==PBWeather::HAIL &&
                         (!opponent.abilitynulled && opponent.ability == PBAbilities::SNOWCLOAK)
      end
      if attacker.itemWorks?
        accuracy*=1.1 if attacker.item == PBItems::WIDELENS
        accuracy*=1.2 if attacker.item == PBItems::ZOOMLENS && attacker.pbSpeed<opponent.pbSpeed
        if attacker.item == PBItems::MICLEBERRY
          accuracy*=1.2 if ((!attacker.abilitynulled && attacker.ability == PBAbilities::GLUTTONY) &&
                          attacker.hp<=(attacker.totalhp/2.0).floor) ||
                          attacker.hp<=(attacker.totalhp/4.0).floor
        end
        if skill>=PBTrainerAI.highSkill
          accuracy/=1.1 if opponent.item == PBItems::BRIGHTPOWDER
          accuracy/=1.1 if opponent.item == PBItems::LAXINCENSE
        end
      end
    end
    # Override accuracy
    accuracy=100 if move.accuracy==0   # Doesn't do accuracy check (always hits)
    accuracy=100 if move.function==0xA5 # Swift
    if skill>=PBTrainerAI.mediumSkill
      accuracy=100 if opponent.effects[PBEffects::LockOn]>0 &&
                      opponent.effects[PBEffects::LockOnPos]==attacker.index
      if skill>=PBTrainerAI.highSkill
        accuracy=100 if (!attacker.abilitynulled && attacker.ability == PBAbilities::NOGUARD) ||
                        (!opponent.abilitynulled && opponent.ability == PBAbilities::NOGUARD)
      end
      accuracy=100 if opponent.effects[PBEffects::Telekinesis]>0
      case pbWeather
        when PBWeather::HAIL
          accuracy=100 if move.function==0x0D # Blizzard
        when PBWeather::RAINDANCE
          accuracy=100 if move.function==0x08 || move.function==0x15 # Thunder, Hurricane
      end
          accuracy=100 if (move.function==0x08 || move.function==0x15) && # Thunder, Hurricane
              ($fefieldeffect == 27 || $fefieldeffect == 28)
      if move.function==0x70 # OHKO moves
        accuracy=move.accuracy+attacker.level-opponent.level
        accuracy=0 if (!opponent.abilitynulled && opponent.ability == PBAbilities::STURDY)
        accuracy=0 if opponent.level>attacker.level
      end
    end
    accuracy=100 if accuracy>100
    return accuracy
  end

end
