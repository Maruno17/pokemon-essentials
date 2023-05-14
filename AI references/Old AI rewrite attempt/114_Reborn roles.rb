=begin
class PokeBattle_Battle
  def pbGetMonRole(mon,opponent,skill,position=0,party=nil)
    #PBDebug.log(sprintf("Beginning role assignment for %s",PBSpecies.getName(mon.species))) if $INTERNAL
    monRoles=[]
    monability = mon.ability.to_i
    curemove=false
    healingmove=false
    wishmove=false
    phasemove=false
    priorityko=false
    pivotmove=false
    spinmove=false
    batonmove=false
    tauntmove=false
    restmove=false
    weathermove=false
    fieldmove=false

    if mon.class == PokeBattle_Battler
      if mon.ev[3]>251 && (mon.nature==PBNatures::MODEST ||
         mon.nature==PBNatures::JOLLY || mon.nature==PBNatures::TIMID ||
         mon.nature==PBNatures::ADAMANT) || (mon.item==(PBItems::CHOICEBAND) ||
         mon.item==(PBItems::CHOICESPECS) || mon.item==(PBItems::CHOICESCARF))
        monRoles.push(PBMonRoles::SWEEPER)
      end

      for i in mon.moves
        next if i.nil?
        next if i.id == 0
        # Unused as only counts for REVENGEKILLER, which is only used if mon is
        # a Pokémon and not a battler (used in switching calculation)
        if i.priority>0
          dam=pbRoughDamage(i,mon,opponent,skill,i.basedamage)
          if opponent.hp>0
            percentage=(dam*100.0)/opponent.hp
            priorityko=true if percentage>100
          end
        end
        if i.isHealingMove?
          healingmove=true
        elsif (i.id == (PBMoves::HEALBELL) || i.id == (PBMoves::AROMATHERAPY))
          curemove=true
        elsif (i.id == (PBMoves::WISH))
          wishmove=true
        elsif (i.id == (PBMoves::YAWN) || i.id == (PBMoves::PERISHSONG) ||
               i.id == (PBMoves::DRAGONTAIL) || i.id == (PBMoves::CIRCLETHROW) ||
               i.id == (PBMoves::WHIRLWIND) || i.id == (PBMoves::ROAR))
          phasemove=true
        elsif (i.id == (PBMoves::UTURN) || i.id == (PBMoves::VOLTSWITCH))
          pivotmove=true
        elsif (i.id == (PBMoves::RAPIDSPIN))
          spinmove=true
        elsif (i.id == (PBMoves::BATONPASS))
          batonmove=true
        elsif (i.id == (PBMoves::TAUNT))
          tauntmove=true
        elsif (i.id == (PBMoves::REST))
          restmove=true
        elsif (i.id == (PBMoves::SUNNYDAY) || i.id == (PBMoves::RAINDANCE) ||
               i.id == (PBMoves::HAIL) || i.id == (PBMoves::SANDSTORM))
          weathermove=true
        elsif (i.id == (PBMoves::GRASSYTERRAIN) || i.id == (PBMoves::ELECTRICTERRAIN) ||
               i.id == (PBMoves::MISTYTERRAIN) || i.id == (PBMoves::PSYCHICTERRAIN) ||
               i.id == (PBMoves::MIST) || i.id == (PBMoves::IONDELUGE) ||
               i.id == (PBMoves::TOPSYTURVY))
          fieldmove=true
        end
      end

      if healingmove && (mon.ev[2]>251 && (mon.nature==PBNatures::BOLD ||
         mon.nature==PBNatures::RELAXED || mon.nature==PBNatures::IMPISH ||
         mon.nature==PBNatures::LAX))
        monRoles.push(PBMonRoles::PHYSICALWALL)
      end
      if healingmove && (mon.ev[5]>251 && (mon.nature==PBNatures::CALM ||
         mon.nature==PBNatures::GENTLE || mon.nature==PBNatures::SASSY ||
         mon.nature==PBNatures::CAREFUL))
        monRoles.push(PBMonRoles::SPECIALWALL)
      end
      if mon.pokemonIndex==0
        monRoles.push(PBMonRoles::LEAD)
      end
      if curemove || (wishmove && mon.ev[0]>251)
        monRoles.push(PBMonRoles::CLERIC)
      end
      if phasemove == true
        monRoles.push(PBMonRoles::PHAZER)
      end
      if mon.item==(PBItems::LIGHTCLAY)
        monRoles.push(PBMonRoles::SCREENER)
      end

      # Unused
      if priorityko || (mon.speed>opponent.speed)
        monRoles.push(PBMonRoles::REVENGEKILLER)
      end

      if (pivotmove && healingmove) || (monability == PBAbilities::REGENERATOR)
        monRoles.push(PBMonRoles::PIVOT)
      end
      if spinmove
        monRoles.push(PBMonRoles::SPINNER)
      end
      if (mon.ev[0]>251 && !healingmove) || mon.item==(PBItems::ASSAULTVEST)
        monRoles.push(PBMonRoles::TANK)
      end
      if batonmove
        monRoles.push(PBMonRoles::BATONPASSER)
      end
      if tauntmove || mon.item==(PBItems::CHOICEBAND) ||
         mon.item==(PBItems::CHOICESPECS)
        monRoles.push(PBMonRoles::STALLBREAKER)
      end
      if restmove || (monability == PBAbilities::COMATOSE) ||
         mon.item==(PBItems::TOXICORB) || mon.item==(PBItems::FLAMEORB) ||
         (monability == PBAbilities::GUTS) ||
         (monability == PBAbilities::QUICKFEET)||
         (monability == PBAbilities::FLAREBOOST) ||
         (monability == PBAbilities::TOXICBOOST) ||
         (monability == PBAbilities::NATURALCURE) ||
         (monability == PBAbilities::MAGICGUARD) ||
         (monability == PBAbilities::MAGICBOUNCE) ||
         ((monability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE)
        monRoles.push(PBMonRoles::STATUSABSORBER)
      end
      if (monability == PBAbilities::SHADOWTAG) ||
         (monability == PBAbilities::ARENATRAP) ||
         (monability == PBAbilities::MAGNETPULL)
        monRoles.push(PBMonRoles::TRAPPER)
      end
      if weathermove || (monability == PBAbilities::DROUGHT) ||
         (monability == PBAbilities::SANDSTREAM) ||
         (monability == PBAbilities::DRIZZLE) ||
         (monability == PBAbilities::SNOWWARNING) ||
         (monability == PBAbilities::PRIMORDIALSEA) ||
         (monability == PBAbilities::DESOLATELAND) ||
         (monability == PBAbilities::DELTASTREAM)
        monRoles.push(PBMonRoles::WEATHERSETTER)
      end
      if fieldmove || (monability == PBAbilities::GRASSYSURGE) ||
         (monability == PBAbilities::ELECTRICSURGE) ||
         (monability == PBAbilities::MISTYSURGE) ||
         (monability == PBAbilities::PSYCHICSURGE) ||
         mon.item==(PBItems::AMPLIFIELDROCK)
        monRoles.push(PBMonRoles::FIELDSETTER)
      end
      #if $game_switches[525] && mon.pokemonIndex==(pbParty(mon.index).length-1)
      if mon.pokemonIndex==(pbParty(mon.index).length-1)
        monRoles.push(PBMonRoles::ACE)
      end

      secondhighest=true
      if pbParty(mon.index).length>2
        for i in 0..(pbParty(mon.index).length-2)
          next if pbParty(mon.index)[i].nil?
          if mon.level<pbParty(mon.index)[i].level
            secondhighest=false
          end
        end
      end
      #if $game_switches[525]&& secondhighest
      if secondhighest
        monRoles.push(PBMonRoles::SECOND)
      end

      #PBDebug.log(sprintf("Ending role assignment for %s",PBSpecies.getName(mon.species))) if $INTERNAL
      #PBDebug.log(sprintf("")) if $INTERNAL
      return monRoles



    elsif mon.class == PokeBattle_Pokemon
      movelist = []
      for i in mon.moves
        next if i.nil?
        next if i.id == 0
        movedummy = PokeBattle_Move.pbFromPBMove(self,i,mon)
        movelist.push(movedummy)
      end
      if mon.ev[3]>251 && (mon.nature==PBNatures::MODEST ||
         mon.nature==PBNatures::JOLLY || mon.nature==PBNatures::TIMID ||
         mon.nature==PBNatures::ADAMANT) || (mon.item==(PBItems::CHOICEBAND) ||
         mon.item==(PBItems::CHOICESPECS) || mon.item==(PBItems::CHOICESCARF))
        monRoles.push(PBMonRoles::SWEEPER)
      end
      for i in movelist
        next if i.nil?
        if i.isHealingMove?
          healingmove=true
        elsif (i.id == (PBMoves::HEALBELL) || i.id == (PBMoves::AROMATHERAPY))
          curemove=true
        elsif (i.id == (PBMoves::WISH))
          wishmove=true
        elsif (i.id == (PBMoves::YAWN) || i.id == (PBMoves::PERISHSONG) ||
               i.id == (PBMoves::DRAGONTAIL) || i.id == (PBMoves::CIRCLETHROW) ||
               i.id == (PBMoves::WHIRLWIND) || i.id == (PBMoves::ROAR))
           phasemove=true
        elsif (i.id == (PBMoves::UTURN) || i.id == (PBMoves::VOLTSWITCH))
          pivotmove=true
        elsif (i.id == (PBMoves::RAPIDSPIN))
          spinmove=true
        elsif (i.id == (PBMoves::BATONPASS))
          batonmove=true
        elsif(i.id == (PBMoves::TAUNT))
          tauntmove=true
        elsif (i.id == (PBMoves::REST))
          restmove=true
        elsif (i.id == (PBMoves::SUNNYDAY) || i.id == (PBMoves::RAINDANCE) ||
               i.id == (PBMoves::HAIL) || i.id == (PBMoves::SANDSTORM))
          weathermove=true
        elsif (i.id == (PBMoves::GRASSYTERRAIN) || i.id == (PBMoves::ELECTRICTERRAIN) ||
               i.id == (PBMoves::MISTYTERRAIN) || i.id == (PBMoves::PSYCHICTERRAIN) ||
               i.id == (PBMoves::MIST) || i.id == (PBMoves::IONDELUGE) ||
               i.id == (PBMoves::TOPSYTURVY))
          fieldmove=true
        end
      end
      if healingmove && (mon.ev[2]>251 && (mon.nature==PBNatures::BOLD ||
         mon.nature==PBNatures::RELAXED || mon.nature==PBNatures::IMPISH ||
         mon.nature==PBNatures::LAX))
        monRoles.push(PBMonRoles::PHYSICALWALL)
      end
      if healingmove && (mon.ev[5]>251 && (mon.nature==PBNatures::CALM ||
         mon.nature==PBNatures::GENTLE || mon.nature==PBNatures::SASSY ||
         mon.nature==PBNatures::CAREFUL))
        monRoles.push(PBMonRoles::SPECIALWALL)
      end
      if position==0
        monRoles.push(PBMonRoles::LEAD)
      end
      if curemove || (wishmove && mon.ev[0]>251)
        monRoles.push(PBMonRoles::CLERIC)
      end
      if (phasemove)
        monRoles.push(PBMonRoles::PHAZER)
      end
      if mon.item==(PBItems::LIGHTCLAY)
        monRoles.push(PBMonRoles::SCREENER)
      end
      # pbRoughDamage does not take Pokemon objects, this will cause issues
      priorityko=false
      for i in movelist
        next if i.priority<1
        next if i.basedamage<10
        priorityko=true
      end
      if priorityko || (mon.speed>opponent.speed)
        monRoles.push(PBMonRoles::REVENGEKILLER)
      end
      if (pivotmove && healingmove) || (monability == PBAbilities::REGENERATOR)
        monRoles.push(PBMonRoles::PIVOT)
      end
      if spinmove
        monRoles.push(PBMonRoles::SPINNER)
      end
      if (mon.ev[0]>251 && !healingmove) || mon.item==(PBItems::ASSAULTVEST)
        monRoles.push(PBMonRoles::TANK)
      end
      if batonmove
        monRoles.push(PBMonRoles::BATONPASSER)
      end
      if tauntmove || mon.item==(PBItems::CHOICEBAND) ||
         mon.item==(PBItems::CHOICESPECS)
        monRoles.push(PBMonRoles::STALLBREAKER)
      end
      if restmove || (monability == PBAbilities::COMATOSE) ||
         mon.item==(PBItems::TOXICORB) || mon.item==(PBItems::FLAMEORB) ||
         (monability == PBAbilities::GUTS) ||
         (monability == PBAbilities::QUICKFEET) ||
         (monability == PBAbilities::FLAREBOOST) ||
         (monability == PBAbilities::TOXICBOOST) ||
         (monability == PBAbilities::NATURALCURE) ||
         (monability == PBAbilities::MAGICGUARD) ||
         (monability == PBAbilities::MAGICBOUNCE) ||
         # TODO: Reference to the weather here.
         ((monability == PBAbilities::HYDRATION) && pbWeather==PBWeather::RAINDANCE)
        monRoles.push(PBMonRoles::STATUSABSORBER)
      end
      if (monability == PBAbilities::SHADOWTAG) ||
         (monability == PBAbilities::ARENATRAP) ||
         (monability == PBAbilities::MAGNETPULL)
        monRoles.push(PBMonRoles::TRAPPER)
      end
      if weathermove || (monability == PBAbilities::DROUGHT) ||
         (monability == PBAbilities::SANDSTREAM) ||
         (monability == PBAbilities::DRIZZLE) ||
         (monability == PBAbilities::SNOWWARNING) ||
         (monability == PBAbilities::PRIMORDIALSEA) ||
         (monability == PBAbilities::DESOLATELAND) ||
         (monability == PBAbilities::DELTASTREAM)
        monRoles.push(PBMonRoles::WEATHERSETTER)
      end
      if fieldmove || (monability == PBAbilities::GRASSYSURGE) ||
         (monability == PBAbilities::ELECTRICSURGE) ||
         (monability == PBAbilities::MISTYSURGE) ||
         (monability == PBAbilities::PSYCHICSURGE) ||
         mon.item==(PBItems::AMPLIFIELDROCK)
        monRoles.push(PBMonRoles::FIELDSETTER)
      end
      if position==(party.length-1)
      #if $game_switches[525] && position==(party.length-1)
        monRoles.push(PBMonRoles::ACE)
      end
      secondhighest=true
      if party.length>2
        for i in 0...(party.length-1)
          next if party[i].nil?
          if mon.level<party[i].level
            secondhighest=false
          end
        end
      end
      #if $game_switches[525]&& secondhighest
      if secondhighest
        monRoles.push(PBMonRoles::SECOND)
      end
      #PBDebug.log(sprintf("Ending role assignment for %s",PBSpecies.getName(mon.species))) if $INTERNAL
      #PBDebug.log(sprintf("")) if $INTERNAL
      return monRoles
    end
    #PBDebug.log(sprintf("Ending role assignment for %s",PBSpecies.getName(mon.species))) if $INTERNAL
    #PBDebug.log(sprintf("")) if $INTERNAL
    return monRoles
  end
end
=end
