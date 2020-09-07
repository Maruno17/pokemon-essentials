JUICESHOPPE_BERRYDATA={
  :CHERIBERRY   => [0,0],
  :LEPPABERRY   => [0,0],
  :RAZZBERRY    => [0,0],
  :SPELONBERRY  => [0,0],
  :CHESTOBERRY  => [1,0],
  :BLUKBERRY    => [1,0],
  :CORNNBERRY   => [1,0],
  :PAMTREBERRY  => [1,0],
  :BELUEBERRY   => [1,0],
  :PECHABERRY   => [2,0],
  :PERSIMBERRY  => [2,0],
  :NANABBERRY   => [2,0],
  :MAGOSTBERRY  => [2,0],
  :WATMELBERRY  => [2,0],
  :RAWSTBERRY   => [3,0],
  :WEPEARBERRY  => [3,0],
  :RABUTABERRY  => [3,0],
  :DURINBERRY   => [3,0],
  :ASPEARBERRY  => [4,0],
  :PINAPBERRY   => [4,0],
  :NOMELBERRY   => [4,0],
  :ORANBERRY    => [5,0],
  
  :OCCABERRY    => [0,1],
  :CHOPLEBERRY  => [0,1],
  :HABANBERRY   => [0,1],
  :PAYAPABERRY  => [1,1],
  :KASIBBERRY   => [1,1],
  :COLBURBERRY  => [1,1],
  :MAGOBERRY    => [2,1],
  :LUMBERRY     => [3,1],
  :RINDOBERRY   => [3,1],
  :KEBIABERRY   => [3,1],
  :TANGABERRY   => [3,1],
  :BABIRIBERRY  => [3,1],
  :SITRUSBERRY  => [4,1],
  :WACANBERRY   => [4,1],
  :SHUCABERRY   => [4,1],
  :CHARTIBERRY  => [4,1],
  :CHILANBERRY  => [4,1],
  :PASSHOBERRY  => [5,1],
  :YACHEBERRY   => [5,1],
  :COBABERRY    => [5,1],
  
  :FIGYBERRY    => [0,2],
  :POMEGBERRY   => [0,2],
  :TAMATOBERRY  => [0,2],
  :LIECHIBERRY  => [0,2],
  :LANSATBERRY  => [0,2],
  :CUSTAPBERRY  => [0,2],
  :WIKIBERRY    => [1,2],
  :GANLONBERRY  => [1,2],
  :ENIGMABERRY  => [1,2],
  :PETAYABERRY  => [2,2],
  :ROSELIBERRY  => [2,2],
  :AGUAVBERRY   => [3,2],
  :HONDEWBERRY  => [3,2],
  :SALACBERRY   => [3,2],
  :STARFBERRY   => [3,2],
  :MICLEBERRY   => [3,2],
  :IAPAPABERRY  => [4,2],
  :QUALOTBERRY  => [4,2],
  :GREPABERRY   => [4,2],
  :JABOCABERRY  => [4,2],
  :KEEBERRY     => [4,2],
  :KELPSYBERRY  => [5,2],
  :APICOTBERRY  => [5,2],
  :ROWAPBERRY   => [5,2],
  :MARANGABERRY => [5,2],
}
JUICESHOPPE_COLORBLEND_STRENGTHS=[
  [12,16,24],
  [16,24,32],
  [24,32,32]
]
JUICESHOPPE_EVBLEND_STRENGTHS=[
  [ 8,12,16],
  [12,16,32],
  [16,32,32],
  [ 4, 8,12]
]
def pbJuiceShoppe(event,move_route1=nil,move_route2=nil)
  Kernel.pbMessage(_INTL("Hiya! Welcome to the counter\nfor fresh Berry juice!\\1"))
  if Kernel.pbConfirmMessage(_INTL("Shall I make a juice using your Berries?"))
    Kernel.pbMessage(_INTL("All right! Please chose Berries to blend.\\1"))
    berry1=0
    pbFadeOutIn(99999){
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$PokemonBag)
      berry1 = screen.pbChooseItemScreen(Proc.new{|item| pbIsBerry?(item) })
    }
    if berry1>0
      $PokemonBag.pbDeleteItem(berry1)
      berry1name=PBItems.getName(berry1)
      if ['a','e','i','o','u'].include?(berry1name[0,1].downcase)
        Kernel.pbMessage(_INTL("Hmmm. An {1}.\nA great choice!\\1",berry1name))
      else
        Kernel.pbMessage(_INTL("Hmmm. A {1}.\nA great choice!\\1",berry1name))
      end
      Kernel.pbMessage(_INTL("Now, please chose another Berry to blend!\\1"))
      berry2=0
      pbFadeOutIn(99999){
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        berry2 = screen.pbChooseItemScreen(Proc.new{|item| pbIsBerry?(item) })
      }
      if berry2>0
        $PokemonBag.pbDeleteItem(berry2)
        berry2name=PBItems.getName(berry2)
        if ['a','e','i','o','u'].include?(berry2name[0,1].downcase)
          Kernel.pbMessage(_INTL("Hmmm. An {1}.\nIt's another great choice!\\1",berry2name))
        else
          Kernel.pbMessage(_INTL("Hmmm. A {1}.\nIt's another great choice!\\1",berry2name))
        end
        move_route=(move_route1)? move_route1 : [PBMoveRoute::TurnAwayFromPlayer]
        pbMoveRoute(event,move_route)
        Kernel.pbMessage(_INTL("Mixing, blending...\\1"))
        Kernel.pbMessage(_INTL("Blending, mixing...\\1"))
        move_route=(move_route2)? move_route2 : [PBMoveRoute::TurnTowardPlayer]
        pbMoveRoute(event,move_route)
        b1data=JUICESHOPPE_BERRYDATA[getConstantName(PBItems,berry1).to_sym]
        b2data=JUICESHOPPE_BERRYDATA[getConstantName(PBItems,berry2).to_sym]
        drink_type=-1
        drink_strength=0
        drink_name=""
        if [berry1,berry2].include?(getID(PBItems,:LANSATBERRY)) && 
           [berry1,berry2].include?(getID(PBItems,:STARFBERRY))
           drink_type=7
           drink_strength=3
           drink_name=_INTL("Rare Soda")
        elsif [berry1,berry2].include?(getID(PBItems,:ENIGMABERRY)) && 
              [berry1,berry2].include?(getID(PBItems,:ROSELIBERRY))
           drink_type=7
           drink_strength=5
           drink_name=_INTL("Ultra Rare Soda")
        elsif [berry1,berry2].include?(getID(PBItems,:KEEBERRY)) && 
              [berry1,berry2].include?(getID(PBItems,:MARANGABERRY))
          drink_type=8
          drink_name=_INTL("Perilous Soup")
        elsif b1data[0] != b2data[0]
          drink_type=0
          drink_strength=JUICESHOPPE_COLORBLEND_STRENGTHS[b1data[1]][b2data[1]]
          drink_name=_INTL("Colorful Shake")
        else
          drink_type=b1data[0]+1
          drink_name=[_INTL("Red Shake"),_INTL("Purple Shake"),_INTL("Pink Shake"),
                      _INTL("Green Shake"),_INTL("Yellow Shake"),_INTL("Blue Shake")][drink_type-1]
          if berry1 == berry2
            drink_strength=JUICESHOPPE_EVBLEND_STRENGTHS[3][b1data[1]]
          else
            drink_strength=JUICESHOPPE_EVBLEND_STRENGTHS[b1data[1]][b2data[1]]
          end
        end
        Kernel.pbMessage(_INTL("Ta-da!\nHere's a fresh {1}!\\1",drink_name))
        Kernel.pbMessage(_INTL("Which Pokémon will you give this to?\\1"))
        chosen = -1
        loop do
          break if chosen>=0
          pbFadeOutIn(99999){
            scene = PokemonParty_Scene.new
            screen = PokemonPartyScreen.new(scene,$Trainer.party)
            chosen=screen.pbChooseAblePokemon(proc {|poke|!poke.egg?})
          }
          if chosen<0
             if Kernel.pbConfirmMessage(_INTL("Huh?\nAre you sure you want to cancel?"))
               Kernel.pbMessage(_INTL("See you next time then!"))
               break
             end
          end
        end
        return if chosen<0
        mon=$Trainer.party[chosen]
        Kernel.pbMessage(_INTL("{1} drank\nthe {2}!\\1",mon.name,drink_name))
        case drink_type
        when 0
          gain=drink_strength
          if isConst?(mon.item,PBItems,:SOOTHEBELL) && gain>0
            gain=(gain*1.5).floor
          end
          mon.happiness+=gain
          mon.happiness=[[255,mon.happiness].min,0].max
          Kernel.pbMessage(_INTL("{1} became friendlier!\\1",mon.name))
        when 1,2,3,4,5,6
          stat=[PBStats::ATTACK,PBStats::HP,PBStats::SPEED,
                PBStats::SPDEF,PBStats::DEFENSE,PBStats::SPATK][drink_type]
          gain=pbJustRaiseEffortValues(mon,stat,drink_strength)
          if gain==0
            Kernel.pbMessage(_INTL("But it had no effect...\\1"))
          else
            Kernel.pbMessage(_INTL("{1}'s base {2} increased!\\1",mon.name,PBStats.getName(stat)))
            gain=4
            if isConst?(mon.item,PBItems,:SOOTHEBELL) && gain>0
              gain=(gain*1.5).floor
            end
            mon.happiness+=gain
            mon.happiness=[[255,mon.happiness].min,0].max
          end
        when 7
          pbJustChangeLevel(mon,mon.level+drink_strength,nil,true)
        when 8
          for i in 0..5
            mon.ev[i]=0
          end
          mon.calcStats
          Kernel.pbMessage(_INTL("{1}'s base stats became zero!\\1",mon.name))
        end
        Kernel.pbMessage(_INTL("Did your Pokémon like it?\nPlease come back again!"))
      else
        $PokemonBag.pbStoreItem(berry1)
        Kernel.pbMessage(_INTL("Please come back again!"))
      end
    else
      Kernel.pbMessage(_INTL("Please come back again!"))
    end
  else
    Kernel.pbMessage(_INTL("Please come back again!"))
  end
end

def pbJustChangeLevel(pokemon,newlevel,scene=nil,msgcont=false)
  newlevel=1 if newlevel<1
  newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
  if pokemon.level>newlevel
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    pokemon.level=newlevel
    pokemon.calcStats
    scene.pbRefresh if scene
    if msgcont
      Kernel.pbMessage(_INTL("{1} was downgraded to Level {2}!\\1",pokemon.name,pokemon.level))
    else
      Kernel.pbMessage(_INTL("{1} was downgraded to Level {2}!",pokemon.name,pokemon.level))
    end
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  elsif pokemon.level==newlevel
    if msgcont
      Kernel.pbMessage(_INTL("{1}'s level remained unchanged.{2}\\1",pokemon.name,(msgcont ? "\\1":"")))
    else
      Kernel.pbMessage(_INTL("{1}'s level remained unchanged.{2}",pokemon.name,(msgcont ? "\\1":"")))
    end
  else
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    oldlevel=pokemon.level
    pokemon.level=newlevel
    pokemon.changeHappiness("levelup")
    pokemon.calcStats
    scene.pbRefresh if scene
    if msgcont
      Kernel.pbMessage(_INTL("{1} was elevated to Level {2}!\\1",pokemon.name,pokemon.level))
    else
      Kernel.pbMessage(_INTL("{1} was elevated to Level {2}!",pokemon.name,pokemon.level))
    end
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  end
end