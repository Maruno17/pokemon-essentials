class PokeBattle_Battle
  def pbStatusDamage(move)
    if (move.id == PBMoves::AFTERYOU || move.id == PBMoves::BESTOW ||
      move.id == PBMoves::CRAFTYSHIELD || move.id == PBMoves::LUCKYCHANT ||
      move.id == PBMoves::MEMENTO || move.id == PBMoves::QUASH ||
      move.id == PBMoves::SAFEGUARD || move.id == PBMoves::SPITE ||
      move.id == PBMoves::SPLASH || move.id == PBMoves::SWEETSCENT ||
      move.id == PBMoves::TELEKINESIS || move.id == PBMoves::TELEPORT)
      return 0
    elsif (move.id == PBMoves::ALLYSWITCH || move.id == PBMoves::AROMATICMIST ||
      move.id == PBMoves::CONVERSION || move.id == PBMoves::ENDURE ||
      move.id == PBMoves::ENTRAINMENT || move.id == PBMoves::FLOWERSHIELD ||
      move.id == PBMoves::FORESIGHT || move.id == PBMoves::FORESTSCURSE ||
      move.id == PBMoves::GRAVITY || move.id == PBMoves::DEFOG ||
      move.id == PBMoves::GUARDSWAP || move.id == PBMoves::HEALBLOCK ||
      move.id == PBMoves::IMPRISON || move.id == PBMoves::INSTRUCT ||
      move.id == PBMoves::FAIRYLOCK || move.id == PBMoves::LASERFOCUS ||
      move.id == PBMoves::HELPINGHAND || move.id == PBMoves::MAGICROOM ||
      move.id == PBMoves::MAGNETRISE || move.id == PBMoves::SOAK ||
      move.id == PBMoves::LOCKON || move.id == PBMoves::MINDREADER ||
      move.id == PBMoves::MIRACLEEYE || move.id == PBMoves::MUDSPORT ||
      move.id == PBMoves::NIGHTMARE || move.id == PBMoves::ODORSLEUTH ||
      move.id == PBMoves::POWERSPLIT || move.id == PBMoves::POWERSWAP ||
      move.id == PBMoves::GRUDGE || move.id == PBMoves::GUARDSPLIT ||
      move.id == PBMoves::POWERTRICK || move.id == PBMoves::QUICKGUARD ||
      move.id == PBMoves::RECYCLE || move.id == PBMoves::REFLECTTYPE ||
      move.id == PBMoves::ROTOTILLER || move.id == PBMoves::SANDATTACK ||
      move.id == PBMoves::SKILLSWAP || move.id == PBMoves::SNATCH ||
      move.id == PBMoves::MAGICCOAT || move.id == PBMoves::SPEEDSWAP ||
      move.id == PBMoves::SPOTLIGHT || move.id == PBMoves::SWALLOW ||
      move.id == PBMoves::TEETERDANCE || move.id == PBMoves::WATERSPORT ||
      move.id == PBMoves::WIDEGUARD || move.id == PBMoves::WONDERROOM)
      return 5
    elsif (move.id == PBMoves::ACUPRESSURE || move.id == PBMoves::CAMOUFLAGE ||
      move.id == PBMoves::CHARM || move.id == PBMoves::CONFIDE ||
      move.id == PBMoves::DEFENSECURL || move.id == PBMoves::GROWTH ||
      move.id == PBMoves::EMBARGO || move.id == PBMoves::FLASH ||
      move.id == PBMoves::FOCUSENERGY || move.id == PBMoves::GROWL ||
      move.id == PBMoves::HARDEN || move.id == PBMoves::HAZE ||
      move.id == PBMoves::HONECLAWS || move.id == PBMoves::HOWL ||
      move.id == PBMoves::KINESIS || move.id == PBMoves::LEER ||
      move.id == PBMoves::METALSOUND || move.id == PBMoves::NOBLEROAR ||
      move.id == PBMoves::PLAYNICE || move.id == PBMoves::POWDER ||
      move.id == PBMoves::PSYCHUP || move.id == PBMoves::SHARPEN ||
      move.id == PBMoves::SMOKESCREEN || move.id == PBMoves::STRINGSHOT ||
      move.id == PBMoves::SUPERSONIC || move.id == PBMoves::TAILWHIP ||
      move.id == PBMoves::TEARFULLOOK || move.id == PBMoves::TORMENT ||
      move.id == PBMoves::WITHDRAW || move.id == PBMoves::WORKUP)
      return 10
    elsif (move.id == PBMoves::ASSIST || move.id == PBMoves::BABYDOLLEYES ||
      move.id == PBMoves::CAPTIVATE || move.id == PBMoves::COTTONSPORE ||
      move.id == PBMoves::DARKVOID || move.id == PBMoves::AGILITY ||
      move.id == PBMoves::DOUBLETEAM || move.id == PBMoves::EERIEIMPULSE ||
      move.id == PBMoves::FAKETEARS || move.id == PBMoves::FEATHERDANCE ||
      move.id == PBMoves::FLORALHEALING || move.id == PBMoves::GRASSWHISTLE ||
      move.id == PBMoves::HEALPULSE || move.id == PBMoves::HEALINGWISH ||
      move.id == PBMoves::HYPNOSIS || move.id == PBMoves::INGRAIN ||
      move.id == PBMoves::LUNARDANCE || move.id == PBMoves::MEFIRST ||
      move.id == PBMoves::MEDITATE || move.id == PBMoves::MIMIC ||
      move.id == PBMoves::PARTINGSHOT || move.id == PBMoves::POISONPOWDER ||
      move.id == PBMoves::REFRESH || move.id == PBMoves::ROLEPLAY ||
      move.id == PBMoves::SCARYFACE || move.id == PBMoves::SCREECH ||
      move.id == PBMoves::SING || move.id == PBMoves::SKETCH ||
      move.id == PBMoves::TICKLE || move.id == PBMoves::CHARGE ||
      move.id == PBMoves::TRICKORTREAT || move.id == PBMoves::VENOMDRENCH ||
      move.id == PBMoves::GEARUP || move.id == PBMoves::MAGNETICFLUX ||
      move.id == PBMoves::SANDSTORM || move.id == PBMoves::HAIL ||
       move.id == PBMoves::SUNNYDAY || move.id == PBMoves::RAINDANCE)
      return 15
    elsif (move.id == PBMoves::AQUARING || move.id == PBMoves::BLOCK ||
      move.id == PBMoves::CONVERSION2 || move.id == PBMoves::ELECTRIFY ||
      move.id == PBMoves::FLATTER || move.id == PBMoves::GASTROACID ||
      move.id == PBMoves::HEARTSWAP || move.id == PBMoves::IONDELUGE ||
      move.id == PBMoves::MEANLOOK || move.id == PBMoves::LOVELYKISS ||
      move.id == PBMoves::METRONOME || move.id == PBMoves::COPYCAT ||
      move.id == PBMoves::MIRRORMOVE || move.id == PBMoves::MIST ||
      move.id == PBMoves::PERISHSONG || move.id == PBMoves::REST ||
      move.id == PBMoves::ROAR || move.id == PBMoves::SIMPLEBEAM ||
      move.id == PBMoves::SLEEPPOWDER || move.id == PBMoves::SPIDERWEB ||
      move.id == PBMoves::SWAGGER || move.id == PBMoves::SWEETKISS ||
      move.id == PBMoves::POISONGAS || move.id == PBMoves::TOXICTHREAD ||
      move.id == PBMoves::TRANSFORM || move.id == PBMoves::WHIRLWIND ||
      move.id == PBMoves::WORRYSEED || move.id == PBMoves::YAWN)
      return 20
    elsif (move.id == PBMoves::AMNESIA || move.id == PBMoves::ATTRACT ||
      move.id == PBMoves::BARRIER || move.id == PBMoves::BELLYDRUM ||
      move.id == PBMoves::CONFUSERAY || move.id == PBMoves::DESTINYBOND ||
      move.id == PBMoves::DETECT || move.id == PBMoves::DISABLE ||
      move.id == PBMoves::ACIDARMOR || move.id == PBMoves::COSMICPOWER ||
      move.id == PBMoves::COTTONGUARD || move.id == PBMoves::DEFENDORDER ||
      move.id == PBMoves::FOLLOWME || move.id == PBMoves::AUTOTOMIZE ||
      move.id == PBMoves::HEALORDER || move.id == PBMoves::IRONDEFENSE ||
      move.id == PBMoves::LEECHSEED || move.id == PBMoves::MILKDRINK ||
      move.id == PBMoves::MINIMIZE || move.id == PBMoves::MOONLIGHT ||
      move.id == PBMoves::MORNINGSUN || move.id == PBMoves::PAINSPLIT ||
      move.id == PBMoves::PROTECT || move.id == PBMoves::PSYCHOSHIFT ||
      move.id == PBMoves::RAGEPOWDER || move.id == PBMoves::ROOST ||
      move.id == PBMoves::RECOVER || move.id == PBMoves::ROCKPOLISH ||
      move.id == PBMoves::SHOREUP || move.id == PBMoves::SLACKOFF ||
      move.id == PBMoves::SOFTBOILED || move.id == PBMoves::STRENGTHSAP ||
      move.id == PBMoves::STOCKPILE || move.id == PBMoves::STUNSPORE ||
      move.id == PBMoves::SUBSTITUTE ||
      move.id == PBMoves::SWITCHEROO || move.id == PBMoves::SYNTHESIS ||
      move.id == PBMoves::TAUNT || move.id == PBMoves::TOPSYTURVY ||
      move.id == PBMoves::TOXIC || move.id == PBMoves::TRICK ||
      move.id == PBMoves::WILLOWISP || move.id == PBMoves::WISH)
      return 25
    elsif (move.id == PBMoves::BATONPASS || move.id == PBMoves::BULKUP ||
      move.id == PBMoves::CALMMIND || move.id == PBMoves::COIL ||
      move.id == PBMoves::CURSE || move.id == PBMoves::ELECTRICTERRAIN ||
      move.id == PBMoves::ENCORE || move.id == PBMoves::GLARE ||
      move.id == PBMoves::GRASSYTERRAIN || move.id == PBMoves::MISTYTERRAIN ||
      move.id == PBMoves::NATUREPOWER || move.id == PBMoves::PSYCHICTERRAIN ||
      move.id == PBMoves::PURIFY || move.id == PBMoves::SLEEPTALK ||
      move.id == PBMoves::SPIKES || move.id == PBMoves::STEALTHROCK ||
      move.id == PBMoves::SPIKYSHIELD || move.id == PBMoves::THUNDERWAVE ||
      move.id == PBMoves::TOXICSPIKES || move.id == PBMoves::TRICKROOM)
      return 30
    elsif (move.id == PBMoves::AROMATHERAPY || move.id == PBMoves::BANEFULBUNKER ||
      move.id == PBMoves::HEALBELL || move.id == PBMoves::KINGSSHIELD ||
      move.id == PBMoves::LIGHTSCREEN || move.id == PBMoves::MATBLOCK ||
      move.id == PBMoves::NASTYPLOT || move.id == PBMoves::REFLECT ||
      move.id == PBMoves::SWORDSDANCE || move.id == PBMoves::TAILGLOW ||
      move.id == PBMoves::TAILWIND)
      return 35
    elsif (move.id == PBMoves::DRAGONDANCE || move.id == PBMoves::GEOMANCY ||
      move.id == PBMoves::QUIVERDANCE || move.id == PBMoves::SHELLSMASH ||
      move.id == PBMoves::SHIFTGEAR)
      return 40
    elsif (move.id == PBMoves::AURORAVEIL || move.id == PBMoves::STICKYWEB ||
      move.id == PBMoves::SPORE)
      return 60
    end
  end

  def pbAegislashStats(aegi)
    if aegi.form==1
      return aegi
    else
      bladecheck = aegi.clone
      bladecheck.form = 1
      if $fefieldeffect==31 && bladecheck.stages[PBStats::ATTACK]<6
        bladecheck.stages[PBStats::ATTACK] += 1
      end
      return bladecheck
    end
  end

  def pbMegaStats(mon)
    if mon.isMega?
      return mon
    else
      megacheck = mon.clone
      megacheck.stages = mon.stages.clone
      megacheck.form = mon.getMegaForm
      return megacheck
    end
  end

  def pbChangeMove(move,attacker)
    move = PokeBattle_Move.pbFromPBMove(self,PBMove.new(move.id),attacker)
    case move.id
      when PBMoves::WEATHERBALL
        weather=pbWeather
        move.type=(PBTypes::NORMAL)
        move.type=PBTypes::FIRE if (weather==PBWeather::SUNNYDAY && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
        move.type=PBTypes::WATER if (weather==PBWeather::RAINDANCE && !attacker.hasWorkingItem(:UTILITYUMBRELLA))
        move.type=PBTypes::ROCK if weather==PBWeather::SANDSTORM
        move.type=PBTypes::ICE if weather==PBWeather::HAIL
        if pbWeather !=0 || $fefieldeffect==9
          move.basedamage*=2 if move.basedamage == 50
        end

      when PBMoves::HIDDENPOWER
        if attacker
          move.type = move.pbType(type,attacker,nil)
        end

      when PBMoves::NATUREPOWER
        move=0
        case $fefieldeffect
          when 33
            if $fecounter == 4
              move=PBMoves::PETALBLIZZARD
            else
              move=PBMoves::GROWTH
            end
          else
            if $fefieldeffect > 0 && $fefieldeffect <= 37
              naturemoves = FieldEffects::NATUREMOVES
              move= naturemoves[$fefieldeffect]
            else
              move=PBMoves::TRIATTACK
            end
          end
        move = PokeBattle_Move.pbFromPBMove(self,PBMove.new(move),attacker)
      end
    return move
  end

  def getAbilityDisruptScore(move,attacker,opponent,skill)
    abilityscore=100.0
    return abilityscore if !opponent.abilitynulled == false #if the ability doesn't work, then nothing here matters
    if opponent.ability == PBAbilities::SPEEDBOOST
      PBDebug.log(sprintf("Speedboost Disrupt")) if $INTERNAL
      abilityscore*=1.1
      if opponent.stages[PBStats::SPEED]<2
        abilityscore*=1.3
      end
    elsif opponent.ability == PBAbilities::SANDVEIL
      PBDebug.log(sprintf("Sand veil Disrupt")) if $INTERNAL
      if @weather==PBWeather::SANDSTORM
        abilityscore*=1.3
      end
    elsif opponent.ability == PBAbilities::VOLTABSORB ||
          opponent.ability == PBAbilities::LIGHTNINGROD ||
          opponent.ability == PBAbilities::MOTORDRIVE
      PBDebug.log(sprintf("Volt Absorb Disrupt")) if $INTERNAL
      elecvar = false
      totalelec=true
      elecmove=nil
      for i in attacker.moves
        if !(i.type == PBTypes::ELECTRIC)
          totalelec=false
        end
        if (i.type == PBTypes::ELECTRIC)
          elecvar=true
          elecmove=i
        end
      end
      if elecvar
        if totalelec
          abilityscore*=3
        end
        if pbTypeModNoMessages(elecmove.type,attacker,opponent,elecmove,skill)>4
          abilityscore*=2
        end
      end
    elsif opponent.ability == PBAbilities::WATERABSORB ||
          opponent.ability == PBAbilities::STORMDRAIN ||
          opponent.ability == PBAbilities::DRYSKIN
      PBDebug.log(sprintf("Water Absorb Disrupt")) if $INTERNAL
      watervar = false
      totalwater=true
      watermove=nil
      firevar=false
      for i in attacker.moves
        if !(i.type == PBTypes::WATER)
          totalwater=false
        end
        if (i.type == PBTypes::WATER)
          watervar=true
          watermove=i
        end
        if (i.type == PBTypes::FIRE)
          firevar=true
        end
      end
      if watervar
        if totalwater
          abilityscore*=3
        end
        if pbTypeModNoMessages(watermove.type,attacker,opponent,watermove,skill)>4
          abilityscore*=2
        end
      end
      if opponent.ability == PBAbilities::DRYSKIN
        if firevar
          abilityscore*=0.5
        end
      end
    elsif opponent.ability == PBAbilities::FLASHFIRE
      PBDebug.log(sprintf("Flash Fire Disrupt")) if $INTERNAL
      firevar = false
      totalfire=true
      firemove=nil
      for i in attacker.moves
        if !(i.type == PBTypes::FIRE)
          totalfire=false
        end
        if (i.type == PBTypes::FIRE)
          firevar=true
          firemove=i
        end
      end
      if firevar
        if totalfire
          abilityscore*=3
        end
        if pbTypeModNoMessages(firemove.type,attacker,opponent,firemove,skill)>4
          abilityscore*=2
        end
      end
    elsif opponent.ability == PBAbilities::LEVITATE
      PBDebug.log(sprintf("Levitate Disrupt")) if $INTERNAL
      groundvar = false
      totalground=true
      groundmove=nil
      for i in attacker.moves
        if !(i.type == PBTypes::GROUND)
          totalground=false
        end
        if (i.type == PBTypes::GROUND)
          groundvar=true
          groundmove=i
        end
      end
      if groundvar
        if totalground
          abilityscore*=3
        end
        if pbTypeModNoMessages(groundmove.type,attacker,opponent,groundmove,skill)>4
          abilityscore*=2
        end
      end
    elsif opponent.ability == PBAbilities::SHADOWTAG
      PBDebug.log(sprintf("Shadow Tag Disrupt")) if $INTERNAL
      if !attacker.hasType?(PBTypes::GHOST)
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::ARENATRAP
      PBDebug.log(sprintf("Arena Trap Disrupt")) if $INTERNAL
      if attacker.isAirborne?
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::WONDERGUARD
      PBDebug.log(sprintf("Wonder Guard Disrupt")) if $INTERNAL
      wondervar=false
      for i in attacker.moves
        if pbTypeModNoMessages(i.type,attacker,opponent,i,skill)>4
          wondervar=true
        end
      end
      if !wondervar
        abilityscore*=5
      end
    elsif opponent.ability == PBAbilities::SERENEGRACE
      PBDebug.log(sprintf("Serene Grace Disrupt")) if $INTERNAL
      abilityscore*=1.3
    elsif opponent.ability == PBAbilities::PUREPOWER || opponent.ability == PBAbilities::HUGEPOWER
      PBDebug.log(sprintf("Pure Power Disrupt")) if $INTERNAL
      abilityscore*=2
    elsif opponent.ability == PBAbilities::SOUNDPROOF
      PBDebug.log(sprintf("Soundproof Disrupt")) if $INTERNAL
      soundvar=false
      for i in attacker.moves
        if i.isSoundBased?
          soundvar=true
        end
      end
      if !soundvar
        abilityscore*=3
      end
    elsif opponent.ability == PBAbilities::THICKFAT
      PBDebug.log(sprintf("Thick Fat Disrupt")) if $INTERNAL
      totalguard=true
      for i in attacker.moves
        if !(i.type == PBTypes::FIRE) && !(i.type == PBTypes::ICE)
          totalguard=false
        end
      end
      if totalguard
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::TRUANT
      PBDebug.log(sprintf("Truant Disrupt")) if $INTERNAL
      abilityscore*=0.1
    elsif opponent.ability == PBAbilities::GUTS ||
          opponent.ability == PBAbilities::QUICKFEET ||
          opponent.ability == PBAbilities::MARVELSCALE
      PBDebug.log(sprintf("Guts Disrupt")) if $INTERNAL
      if opponent.status!=0
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::LIQUIDOOZE
      PBDebug.log(sprintf("Liquid Ooze Disrupt")) if $INTERNAL
      if opponent.effects[PBEffects::LeechSeed]>=0 || attacker.pbHasMove?((PBMoves::LEECHSEED))
        abilityscore*=2
      end
    elsif opponent.ability == PBAbilities::AIRLOCK || opponent.ability == PBAbilities::CLOUDNINE
      PBDebug.log(sprintf("Airlock Disrupt")) if $INTERNAL
      abilityscore*=1.1
    elsif opponent.ability == PBAbilities::HYDRATION
      PBDebug.log(sprintf("Hydration Disrupt")) if $INTERNAL
      if @weather==PBWeather::RAINDANCE
        abilityscore*=1.3
      end
    elsif opponent.ability == PBAbilities::ADAPTABILITY
      PBDebug.log(sprintf("Adaptability Disrupt")) if $INTERNAL
      abilityscore*=1.3
    elsif opponent.ability == PBAbilities::SKILLLINK
      PBDebug.log(sprintf("Skill Link Disrupt")) if $INTERNAL
      abilityscore*=1.5
    elsif opponent.ability == PBAbilities::POISONHEAL
      PBDebug.log(sprintf("Poison Heal Disrupt")) if $INTERNAL
      if opponent.status==PBStatuses::POISON
        abilityscore*=2
      end
    elsif opponent.ability == PBAbilities::NORMALIZE
      PBDebug.log(sprintf("Normalize Disrupt")) if $INTERNAL
      abilityscore*=0.6
    elsif opponent.ability == PBAbilities::MAGICGUARD
      PBDebug.log(sprintf("Magic Guard Disrupt")) if $INTERNAL
      abilityscore*=1.4
    elsif opponent.ability == PBAbilities::STALL
      PBDebug.log(sprintf("Stall Disrupt")) if $INTERNAL
      abilityscore*=0.5
    elsif opponent.ability == PBAbilities::TECHNICIAN
      PBDebug.log(sprintf("Technician Disrupt")) if $INTERNAL
      abilityscore*=1.3
    elsif opponent.ability == PBAbilities::MOLDBREAKER
      PBDebug.log(sprintf("Mold Breaker Disrupt")) if $INTERNAL
      abilityscore*=1.1
    elsif opponent.ability == PBAbilities::UNAWARE
      PBDebug.log(sprintf("Unaware Disrupt")) if $INTERNAL
      abilityscore*=1.7
    elsif opponent.ability == PBAbilities::SLOWSTART
      PBDebug.log(sprintf("Slow Start Disrupt")) if $INTERNAL
      abilityscore*=0.3
    elsif opponent.ability == PBAbilities::MULTITYPE || opponent.ability == PBAbilities::STANCECHANGE ||
          opponent.ability == PBAbilities::SCHOOLING || opponent.ability == PBAbilities::SHIELDSDOWN ||
          opponent.ability == PBAbilities::DISGUISE || opponent.ability == PBAbilities::RKSSYSTEM ||
          opponent.ability == PBAbilities::POWERCONSTRUCT
      PBDebug.log(sprintf("Multitype Disrupt")) if $INTERNAL
      abilityscore*=0
    elsif opponent.ability == PBAbilities::SHEERFORCE
      PBDebug.log(sprintf("Sheer Force Disrupt")) if $INTERNAL
      abilityscore*=1.2
    elsif opponent.ability == PBAbilities::CONTRARY
      PBDebug.log(sprintf("Contrary Disrupt")) if $INTERNAL
      abilityscore*=1.4
      if opponent.stages[PBStats::ATTACK]>0 || opponent.stages[PBStats::SPATK]>0 ||
         opponent.stages[PBStats::DEFENSE]>0 || opponent.stages[PBStats::SPDEF]>0 ||
         opponent.stages[PBStats::SPEED]>0
        abilityscore*=2
      end
    elsif opponent.ability == PBAbilities::DEFEATIST
      PBDebug.log(sprintf("Defeatist Disrupt")) if $INTERNAL
      abilityscore*=0.5
    elsif opponent.ability == PBAbilities::MULTISCALE
      PBDebug.log(sprintf("Multiscale Disrupt")) if $INTERNAL
      if opponent.hp==opponent.totalhp
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::HARVEST
      PBDebug.log(sprintf("Harvest Disrupt")) if $INTERNAL
      abilityscore*=1.2
    elsif opponent.ability == PBAbilities::MOODY
      PBDebug.log(sprintf("Moody Disrupt")) if $INTERNAL
      abilityscore*=1.8
    elsif opponent.ability == PBAbilities::SAPSIPPER
      PBDebug.log(sprintf("Sap Sipper Disrupt")) if $INTERNAL
      grassvar = false
      totalgrass=true
      grassmove=nil
      for i in attacker.moves
        if !(i.type == PBTypes::GRASS)
          totalgrass=false
        end
        if (i.type == PBTypes::GRASS)
          grassvar=true
          grassmove=i
        end
      end
      if grassvar
        if totalgrass
          abilityscore*=3
        end
        if pbTypeModNoMessages(grassmove.type,attacker,opponent,grassmove,skill)>4
          abilityscore*=2
        end
      end
    elsif opponent.ability == PBAbilities::PRANKSTER
      PBDebug.log(sprintf("Prankster Disrupt")) if $INTERNAL
      if attacker.speed>opponent.speed
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::SNOWCLOAK
      PBDebug.log(sprintf("Snow Cloak Disrupt")) if $INTERNAL
      if @weather==PBWeather::HAIL
        abilityscore*=1.1
      end
    elsif opponent.ability == PBAbilities::FURCOAT
      PBDebug.log(sprintf("Fur Coat Disrupt")) if $INTERNAL
      if attacker.attack>attacker.spatk
        abilityscore*=1.5
      end
    elsif opponent.ability == PBAbilities::PARENTALBOND
      PBDebug.log(sprintf("Parental Bond Disrupt")) if $INTERNAL
      abilityscore*=3
    elsif opponent.ability == PBAbilities::PROTEAN
      PBDebug.log(sprintf("Protean Disrupt")) if $INTERNAL
      abilityscore*=3
    elsif opponent.ability == PBAbilities::TOUGHCLAWS
      PBDebug.log(sprintf("Tough Claws Disrupt")) if $INTERNAL
      abilityscore*=1.2
    elsif opponent.ability == PBAbilities::BEASTBOOST
      PBDebug.log(sprintf("Beast Boost Disrupt")) if $INTERNAL
      abilityscore*=1.1
    elsif opponent.ability == PBAbilities::COMATOSE
      PBDebug.log(sprintf("Comatose Disrupt")) if $INTERNAL
      abilityscore*=1.3
    elsif opponent.ability == PBAbilities::FLUFFY
      PBDebug.log(sprintf("Fluffy Disrupt")) if $INTERNAL
      abilityscore*=1.5
      firevar = false
      for i in attacker.moves
        if (i.type == PBTypes::FIRE)
          firevar=true
        end
      end
      if firevar
        abilityscore*=0.5
      end
    elsif opponent.ability == PBAbilities::MERCILESS
      PBDebug.log(sprintf("Merciless Disrupt")) if $INTERNAL
      abilityscore*=1.3
    elsif opponent.ability == PBAbilities::WATERBUBBLE
      PBDebug.log(sprintf("Water Bubble Disrupt")) if $INTERNAL
      abilityscore*=1.5
      firevar = false
      for i in attacker.moves
        if (i.type == PBTypes::FIRE)
          firevar=true
        end
      end
      if firevar
        abilityscore*=1.3
      end
    elsif attacker.pbPartner==opponent
      if abilityscore!=0
        if abilityscore>200
          abilityscore=200
        end
        tempscore = abilityscore
        abilityscore = 200 - tempscore
      end
    end
    abilityscore*=0.01
    return abilityscore
  end

  def getFieldDisruptScore(attacker,opponent,skill)
    fieldscore=100.0
    aroles = pbGetMonRole(attacker,opponent,skill)
    oroles = pbGetMonRole(opponent,attacker,skill)
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    if $fefieldeffect==1 # Electric Terrain
      PBDebug.log(sprintf("Electric Terrain Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ELECTRIC)
        fieldscore*=0.5
      end
      partyelec=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ELECTRIC)
          partyelec=true
        end
      end
      if partyelec
        fieldscore*=0.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SURGESURFER)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==2 # Grassy Terrain
      PBDebug.log(sprintf("Grassy Terrain Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:GRASS)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:GRASS)
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.8
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.2
      end
      partygrass=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:GRASS)
          partygrass=true
        end
      end
      if partygrass
        fieldscore*=0.5
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.2
      end
      if aroles.include?(PBMonRoles::SPECIALWALL) || aroles.include?(PBMonRoles::PHYSICALWALL)
        fieldscore*=0.8
      end
      if oroles.include?(PBMonRoles::SPECIALWALL) || oroles.include?(PBMonRoles::PHYSICALWALL)
        fieldscore*=1.2
      end
    end
    if $fefieldeffect==3 # Misty Terrain
      PBDebug.log(sprintf("Misty Terrain Disrupt")) if $INTERNAL
      if attacker.spatk>attacker.attack
        if opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY)
          fieldscore*=1.3
        end
      end
      if opponent.spatk>opponent.attack
        if attacker.pbHasType?(:FAIRY)
          fieldscore*=0.7
        end
      end
      if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
        fieldscore*=0.5
      end
      if attacker.pbHasType?(:DRAGON)
        fieldscore*=1.5
      end
      partyfairy=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FAIRY)
          partyfairy=true
        end
      end
      if partyfairy
        fieldscore*=0.7
      end
      partydragon=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DRAGON)
          partydragon=true
        end
      end
      if partydragon
        fieldscore*=1.5
      end
      if !(attacker.pbHasType?(:POISON) || attacker.pbHasType?(:STEEL))
        if $fecounter==1
          fieldscore*=1.8
        end
      end
    end
    if $fefieldeffect==4 # Dark Crystal Cavern
      PBDebug.log(sprintf("Dark Crystal Cavern Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) ||
         opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
        fieldscore*=0.7
      end
      partyspook=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DARK) || k.hasType?(:GHOST)
          partyspook=true
        end
      end
      if partyspook
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==5 # Chess field
      PBDebug.log(sprintf("Chess Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:PSYCHIC)
        fieldscore*=0.7
      end
      partypsy=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:PSYCHIC)
          partypsy=true
        end
      end
      if partypsy
        fieldscore*=0.7
      end
      if attacker.speed>opponent.speed
        fieldscore*=1.3
      else
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==6 # Big Top field
      PBDebug.log(sprintf("Big Top Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:FIGHTING) || opponent.pbPartner.pbHasType?(:FIGHTING)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:FIGHTING)
        fieldscore*=0.5
      end
      partyfight=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIGHTING)
          partyfight=true
        end
      end
      if partyfight
        fieldscore*=0.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::DANCER)
        fieldscore*=1.5
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::DANCER)
        fieldscore*=0.5
      end
      if attacker.pbHasMove?((PBMoves::SING)) ||
          attacker.pbHasMove?((PBMoves::DRAGONDANCE)) ||
          attacker.pbHasMove?((PBMoves::QUIVERDANCE))
        fieldscore*=0.5
      end
      fieldscore*=1.5 if checkAImoves([PBMoves::SING,PBMoves::DRAGONDANCE,PBMoves::QUIVERDANCE],aimem)
    end
    if $fefieldeffect==7 # Burning Field
      PBDebug.log(sprintf("Burning Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.8
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.3
      else
        fieldscore*=1.5
        if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:ICE) ||
           attacker.pbHasType?(:BUG) || attacker.pbHasType?(:STEEL)
          fieldscore*=1.8
        end
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.7
      end
      partyflamm=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:GRASS) || k.hasType?(:ICE) || k.hasType?(:BUG) || k.hasType?(:STEEL)
          partyflamm=true
        end
      end
      if partyflamm
        fieldscore*=1.5
      end
    end
    if $fefieldeffect==8 # Swamp field
      PBDebug.log(sprintf("Swamp Field Disrupt")) if $INTERNAL
      if attacker.pbHasMove?((PBMoves::SLEEPPOWDER))
        fieldscore*=0.7
      end
      fieldscore*=1.3 if checkAImoves([PBMoves::SLEEPPOWDER],aimem)
    end
    if $fefieldeffect==9 # Rainbow field
      PBDebug.log(sprintf("Rainbow Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:NORMAL)
        fieldscore*=0.5
      end
      partynorm=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:NORMAL)
          partynorm=true
        end
      end
      if partynorm
        fieldscore*=0.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::CLOUDNINE)
        fieldscore*=1.4
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::CLOUDNINE)
        fieldscore*=0.6
      end
      if attacker.pbHasMove?((PBMoves::SONICBOOM))
        fieldscore*=0.8
      end
      fieldscore*=1.2 if checkAImoves([PBMoves::SONICBOOM],aimem)
    end
    if $fefieldeffect==10 # Corrosive field
      PBDebug.log(sprintf("Corrosive Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:POISON)
        fieldscore*=0.7
      end
      partypoison=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:POISON)
          partypoison=true
        end
      end
      if partypoison
        fieldscore*=0.7
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::CORROSION)
        fieldscore*=1.5
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::CORROSION)
        fieldscore*=0.5
      end
      if attacker.pbHasMove?((PBMoves::SLEEPPOWDER))
        fieldscore*=0.7
      end
      fieldscore*=1.3 if checkAImoves([PBMoves::SLEEPPOWDER],aimem)
    end
    if $fefieldeffect==11 # Corromist field
      PBDebug.log(sprintf("Corrosive Mist Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:POISON)
        fieldscore*=0.7
      else
        if !attacker.pbHasType?(:STEEL)
          fieldscore*=1.4
        end
      end
      nopartypoison=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if !(k.hasType?(:POISON))
          nopartypoison=true
        end
      end
      if nopartypoison
        fieldscore*=1.4
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::CORROSION)
        fieldscore*=1.5
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::CORROSION)
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.8
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.8
      end
    end
    if $fefieldeffect==12 # Desert field
      PBDebug.log(sprintf("Desert Field Disrupt")) if $INTERNAL
      if attacker.spatk > attacker.attack
        if opponent.pbHasType?(:GROUND) || opponent.pbPartner.pbHasType?(:GROUND)
          fieldscore*=1.3
        end
      end
      if opponent.spatk > opponent.attack
        if attacker.pbHasType?(:GROUND)
          fieldscore*=0.7
        end
      end
      if attacker.pbHasType?(:ELECTRIC) || attacker.pbHasType?(:WATER)
        fieldscore*=1.5
      end
      if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:WATER)
        fieldscore*=0.5
      end
      partyground=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:GROUND)
          partyground=true
        end
      end
      if partyground
        fieldscore*=0.7
      end
      partyweak=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ELECTRIC) || k.hasType?(:WATER)
          partyweak=true
        end
      end
      if partyweak
        fieldscore*=1.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SANDRUSH) && @weather!=PBWeather::SANDSTORM
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SANDRUSH) && @weather!=PBWeather::SANDSTORM
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==13 # Icy field
      PBDebug.log(sprintf("Icy Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ICE)
        fieldscore*=0.5
      end
      partyice=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ICE)
          partyice=true
        end
      end
      if partyice
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=0.5
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=1.5
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=1.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SLUSHRUSH) && @weather!=PBWeather::HAIL
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SLUSHRUSH) && @weather!=PBWeather::HAIL
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==14 # Rocky field
      PBDebug.log(sprintf("Rocky Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ROCK)
        fieldscore*=0.5
      end
      partyrock=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ROCK)
          partyrock=true
        end
      end
      if partyrock
        fieldscore*=0.5
      end
    end
    if $fefieldeffect==15 # Forest field
      PBDebug.log(sprintf("Forest Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:GRASS) || opponent.pbHasType?(:BUG) ||
         opponent.pbPartner.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:BUG)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:BUG)
        fieldscore*=0.5
      end
      partygrowth=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:GRASS) || k.hasType?(:BUG)
          partygrowth=true
        end
      end
      if partygrowth
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.8
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.2
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.2
      end
    end
    if $fefieldeffect==16 # Superheated field
      PBDebug.log(sprintf("Superheated Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.8
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.2
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.2
      end
      if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
        fieldscore*=0.5
      end
      if attacker.pbHasType?(:ICE)
        fieldscore*=1.5
      end
      partyice=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ICE)
          partyice=true
        end
      end
      if partyice
        fieldscore*=1.5
      end
      if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
        fieldscore*=0.8
      end
      if attacker.pbHasType?(:WATER)
        fieldscore*=1.2
      end
      partywater=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:WATER)
          partywater=true
        end
      end
      if partywater
        fieldscore*=1.2
      end
    end
    if $fefieldeffect==17 # Factory field
      PBDebug.log(sprintf("Factory Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
        fieldscore*=1.2
      end
      if attacker.pbHasType?(:ELECTRIC)
        fieldscore*=0.8
      end
      partyelec=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ELECTRIC)
          partyelec=true
        end
      end
      if partyelec
        fieldscore*=0.8
      end
    end
    if $fefieldeffect==18 # Short-Circuit field
      PBDebug.log(sprintf("Short-Circuit Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ELECTRIC) || opponent.pbPartner.pbHasType?(:ELECTRIC)
        fieldscore*=1.4
      end
      if attacker.pbHasType?(:ELECTRIC)
        fieldscore*=0.6
      end
      partyelec=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ELECTRIC)
          partyelec=true
        end
      end
      if partyelec
        fieldscore*=0.6
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SURGESURFER)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
        fieldscore*=0.7
      end
      if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) ||
         opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
        fieldscore*=0.7
      end
      partyspook=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DARK) || k.hasType?(:GHOST)
          partyspook=true
        end
      end
      if partyspook
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==19 # Wasteland field
      PBDebug.log(sprintf("Wasteland Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:POISON)
        fieldscore*=0.7
      end
      partypoison=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:POISON)
          partypoison=true
        end
      end
      if partypoison
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==20 # Ashen Beach field
      PBDebug.log(sprintf("Ashen Beach Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:FIGHTING) || opponent.pbPartner.pbHasType?(:FIGHTING) ||
         opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:FIGHTING) || attacker.pbHasType?(:PSYCHIC)
        fieldscore*=0.7
      end
      partyfocus=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIGHTING) || k.hasType?(:PSYCHIC)
          partyfocus=true
        end
      end
      if partyfocus
        fieldscore*=0.7
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SANDRUSH) && @weather!=PBWeather::SANDSTORM
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SANDRUSH) && @weather!=PBWeather::SANDSTORM
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==21 # Water Surface field
      PBDebug.log(sprintf("Water Surface Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
        fieldscore*=1.6
      end
      if attacker.pbHasType?(:WATER)
        fieldscore*=0.4
      else
        if !attacker.isAirborne?
          fieldscore*=1.3
        end
      end
      partywater=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:WATER)
          partywater=true
        end
      end
      if partywater
        fieldscore*=0.4
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SWIFTSWIM) && @weather!=PBWeather::RAINDANCE
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SWIFTSWIM) && @weather!=PBWeather::RAINDANCE
        fieldscore*=0.7
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SURGESURFER)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
        fieldscore*=0.7
      end
      if !attacker.pbHasType?(:POISON) && $fecounter==1
        fieldscore*=1.3
      end
    end
    if $fefieldeffect==22 # Underwater field
      PBDebug.log(sprintf("Underwater Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
        fieldscore*=2
      end
      if attacker.pbHasType?(:WATER)
        fieldscore*=0.1
      else
        fieldscore*=1.5
        if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:GROUND)
          fieldscore*=2
        end
      end
      if attacker.attack > attacker.spatk
        fieldscore*=1.2
      end
      if opponent.attack > opponent.spatk
        fieldscore*=0.8
      end
      partywater=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:WATER)
          partywater=true
        end
      end
      if partywater
        fieldscore*=0.1
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SWIFTSWIM)
        fieldscore*=0.9
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SWIFTSWIM)
        fieldscore*=1.1
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SURGESURFER)
        fieldscore*=1.1
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
        fieldscore*=0.9
      end
      if !attacker.pbHasType?(:POISON) && $fecounter==1
        fieldscore*=1.3
      end
    end
    if $fefieldeffect==23 # Cave field
      PBDebug.log(sprintf("Cave Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ROCK)
        fieldscore*=0.5
      end
      partyrock=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ROCK)
          partyrock=true
        end
      end
      if partyrock
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:GROUND) || opponent.pbPartner.pbHasType?(:GROUND)
        fieldscore*=1.2
      end
      if attacker.pbHasType?(:GROUND)
        fieldscore*=0.8
      end
      partyground=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:GROUND)
          partyground=true
        end
      end
      if partyground
        fieldscore*=0.8
      end
      if opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING)
        fieldscore*=0.7
      end
      if attacker.pbHasType?(:FLYING)
        fieldscore*=1.3
      end
      partyflying=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FLYING)
          partyflying=true
        end
      end
      if partyflying
        fieldscore*=1.3
      end
    end
    if $fefieldeffect==24 # Glitch field
      PBDebug.log(sprintf("Glitch Field Disrupt")) if $INTERNAL
      if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:FAIRY)
        fieldscore*=1.3
      end
      partynew=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DARK) || k.hasType?(:STEEL) || k.hasType?(:FAIRY)
          partynew=true
        end
      end
      if partynew
        fieldscore*=1.3
      end
      ratio1 = attacker.spatk/attacker.spdef.to_f
      ratio2 = attacker.spdef/attacker.spatk.to_f
      if ratio1 < 1
        fieldscore*=ratio1
      elsif ratio2 < 1
        fieldscore*=ratio2
      end
      oratio1 = opponent.spatk/attacker.spdef.to_f
      oratio2 = opponent.spdef/attacker.spatk.to_f
      if oratio1 > 1
        fieldscore*=oratio1
      elsif oratio2 > 1
        fieldscore*=oratio2
      end
    end
    if $fefieldeffect==25 # Crystal Cavern field
      PBDebug.log(sprintf("Crystal Cavern Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) ||
         opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:DRAGON)
        fieldscore*=0.5
      end
      partycryst=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ROCK) || k.hasType?(:DRAGON)
          partycryst=true
        end
      end
      if partycryst
        fieldscore*=0.5
      end
    end
    if $fefieldeffect==26 # Murkwater Surface field
      PBDebug.log(sprintf("Murkwater Surface Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:WATER) || opponent.pbPartner.pbHasType?(:WATER)
        fieldscore*=1.6
      end
      if attacker.pbHasType?(:WATER)
        fieldscore*=0.4
      else
        if !attacker.isAirborne?
          fieldscore*=1.3
        end
      end
      partywater=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:WATER)
          partywater=true
        end
      end
      if partywater
        fieldscore*=0.4
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SWIFTSWIM) && @weather!=PBWeather::RAINDANCE
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SWIFTSWIM) && @weather!=PBWeather::RAINDANCE
        fieldscore*=0.7
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SURGESURFER)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SURGESURFER)
        fieldscore*=0.7
      end
      if opponent.pbHasType?(:STEEL) || opponent.pbPartner.pbHasType?(:STEEL) ||
         opponent.pbHasType?(:POISON) || opponent.pbPartner.pbHasType?(:POISON)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:POISON)
        fieldscore*=0.7
      else
        if !attacker.pbHasType?(:STEEL)
          fieldscore*=1.8
        end
      end
      partymurk=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:POISON)
          partymurk=true
        end
      end
      if partymurk
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==27 # Mountain field
      PBDebug.log(sprintf("Mountain Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) ||
         opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:FLYING)
        fieldscore*=0.5
      end
      partymount=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ROCK) || k.hasType?(:FLYING)
          partymount=true
        end
      end
      if partymount
        fieldscore*=0.5
      end
    end
    if $fefieldeffect==28 # Snowy Mountain field
      PBDebug.log(sprintf("Snowy Mountain Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:ROCK) || opponent.pbPartner.pbHasType?(:ROCK) ||
         opponent.pbHasType?(:FLYING) || opponent.pbPartner.pbHasType?(:FLYING) ||
         opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ROCK) || attacker.pbHasType?(:FLYING) || attacker.pbHasType?(:ICE)
        fieldscore*=0.5
      end
      partymount=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ROCK) || k.hasType?(:FLYING) || k.hasType?(:ICE)
          partymount=true
        end
      end
      if partymount
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=0.5
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=1.5
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=1.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::SLUSHRUSH) && @weather!=PBWeather::HAIL
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::SLUSHRUSH) && @weather!=PBWeather::HAIL
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==29 # Holy field
      PBDebug.log(sprintf("Holy Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL) ||
         opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY)
        fieldscore*=1.4
      end
      if attacker.pbHasType?(:NORMAL) || attacker.pbHasType?(:FAIRY)
        fieldscore*=0.6
      end
      partynorm=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:NORMAL) || k.hasType?(:FAIRY)
          partynorm=true
        end
      end
      if partynorm
        fieldscore*=0.6
      end
      if opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK) ||
         opponent.pbHasType?(:GHOST) || opponent.pbPartner.pbHasType?(:GHOST)
        fieldscore*=0.5
      end
      if attacker.pbHasType?(:DARK) || attacker.pbHasType?(:GHOST)
        fieldscore*=1.5
      end
      partyspook=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DARK) || k.hasType?(:GHOST)
          partyspook=true
        end
      end
      if partyspook
        fieldscore*=1.5
      end
      if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON) ||
         opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
        fieldscore*=1.2
      end
      if attacker.pbHasType?(:DRAGON) || attacker.pbHasType?(:PSYCHIC)
        fieldscore*=0.8
      end
      partymyst=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DRAGON) || k.hasType?(:PSYCHIC)
          partymyst=true
        end
      end
      if partymyst
        fieldscore*=0.8
      end
    end
    if $fefieldeffect==30 # Mirror field
      PBDebug.log(sprintf("Mirror Field Disrupt")) if $INTERNAL
      if opponent.stages[PBStats::ACCURACY]!=0
        minimini = opponent.stages[PBStats::ACCURACY]
        minimini*=10.0
        minimini+=100
        minimini/=100
        fieldscore*=minimini
      end
      if opponent.stages[PBStats::EVASION]!=0
        minimini = opponent.stages[PBStats::EVASION]
        minimini*=10.0
        minimini+=100
        minimini/=100
        fieldscore*=minimini
      end
      if attacker.stages[PBStats::ACCURACY]!=0
        minimini = attacker.stages[PBStats::ACCURACY]
        minimini*=(-10.0)
        minimini+=100
        minimini/=100
        fieldscore*=minimini
      end
      if attacker.stages[PBStats::EVASION]!=0
        minimini = attacker.stages[PBStats::EVASION]
        minimini*=(-10.0)
        minimini+=100
        minimini/=100
        fieldscore*=minimini
      end
    end
    if $fefieldeffect==31 # Fairytale field
      PBDebug.log(sprintf("Fairytale Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON) ||
         opponent.pbHasType?(:STEEL) || opponent.pbPartner.pbHasType?(:STEEL) ||
         opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:DRAGON) || attacker.pbHasType?(:STEEL) || attacker.pbHasType?(:FAIRY)
        fieldscore*=0.5
      end
      partyfair=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DRAGON) || k.hasType?(:STEEL) || k.hasType?(:FAIRY)
          partyfair=true
        end
      end
      if partyfair
        fieldscore*=0.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::STANCECHANGE)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::STANCECHANGE)
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==32 # Dragon's Den field
      PBDebug.log(sprintf("Dragon's Den Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:DRAGON) || opponent.pbPartner.pbHasType?(:DRAGON)
        fieldscore*=1.7
      end
      if attacker.pbHasType?(:DRAGON)
        fieldscore*=0.3
      end
      partydrago=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:DRAGON)
          partydrago=true
        end
      end
      if partydrago
        fieldscore*=0.3
      end
      if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:FIRE)
        fieldscore*=0.5
      end
      partyfire=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FIRE)
          partyfire=true
        end
      end
      if partyfire
        fieldscore*=0.5
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::MULTISCALE)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::MULTISCALE)
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==33 # Flower Garden field
      PBDebug.log(sprintf("Flower Garden Field Disrupt")) if $INTERNAL
      if $fecounter>2
        if opponent.pbHasType?(:BUG) || opponent.pbPartner.pbHasType?(:BUG) || opponent.pbHasType?(:GRASS) || opponent.pbPartner.pbHasType?(:GRASS)
          fieldscore*=(0.5*$fecounter)
        end
        if attacker.pbHasType?(:GRASS) || attacker.pbHasType?(:BUG)
          fieldscore*= (1.0/$fecounter)
        end
        partygrass=false
        for k in pbParty(attacker.index)
          next if k.nil?
          if k.hasType?(:BUG) || k.hasType?(:GRASS)
            partygrass=true
          end
        end
        if partygrass
          fieldscore*= (1.0/$fecounter)
        end
        if opponent.pbHasType?(:FIRE) || opponent.pbPartner.pbHasType?(:FIRE)
          fieldscore*=(0.4*$fecounter)
        end
        if attacker.pbHasType?(:FIRE)
          fieldscore*= (1.0/$fecounter)
        end
        partyfire=false
        for k in pbParty(attacker.index)
          next if k.nil?
          if k.hasType?(:FIRE)
            partyfire=true
          end
        end
        if partyfire
          fieldscore*= (1.0/$fecounter)
        end
      end
    end
    if $fefieldeffect==34 # Starlight Arena field
      PBDebug.log(sprintf("Starlight Arena Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:PSYCHIC)
        fieldscore*=0.5
      end
      partypsy=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:PSYCHIC)
          partypsy=true
        end
      end
      if partypsy
        fieldscore*=0.5
      end
      if opponent.pbHasType?(:FAIRY) || opponent.pbPartner.pbHasType?(:FAIRY) || opponent.pbHasType?(:DARK) || opponent.pbPartner.pbHasType?(:DARK)
        fieldscore*=1.3
      end
      if attacker.pbHasType?(:FAIRY) || attacker.pbHasType?(:DARK)
        fieldscore*=0.7
      end
      partystar=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:FAIRY) || k.hasType?(:DARK)
          partystar=true
        end
      end
      if partystar
        fieldscore*=0.7
      end
    end
    if $fefieldeffect==35 # New World field
      PBDebug.log(sprintf("New World Field Disrupt")) if $INTERNAL
      fieldscore = 0
    end
    if $fefieldeffect==36 # Inverse field
      PBDebug.log(sprintf("Inverse Field Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:NORMAL) || opponent.pbPartner.pbHasType?(:NORMAL)
        fieldscore*=1.7
      end
      if attacker.pbHasType?(:NORMAL)
        fieldscore*=0.3
      end
      partynorm=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:NORMAL)
          partynorm=true
        end
      end
      if partynorm
        fieldscore*=0.3
      end
      if opponent.pbHasType?(:ICE) || opponent.pbPartner.pbHasType?(:ICE)
        fieldscore*=1.5
      end
      if attacker.pbHasType?(:ICE)
        fieldscore*=0.5
      end
      partyice=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:ICE)
          partyice=true
        end
      end
      if partyice
        fieldscore*=0.5
      end
    end
    if $fefieldeffect==37 # Psychic Terrain
      PBDebug.log(sprintf("Psychic Terrain Disrupt")) if $INTERNAL
      if opponent.pbHasType?(:PSYCHIC) || opponent.pbPartner.pbHasType?(:PSYCHIC)
        fieldscore*=1.7
      end
      if attacker.pbHasType?(:PSYCHIC)
        fieldscore*=0.3
      end
      partypsy=false
      for k in pbParty(attacker.index)
        next if k.nil?
        if k.hasType?(:PSYCHIC)
          partypsy=true
        end
      end
      if partypsy
        fieldscore*=0.3
      end
      if (!opponent.abilitynulled && opponent.ability == PBAbilities::TELEPATHY)
        fieldscore*=1.3
      end
      if (!attacker.abilitynulled && attacker.ability == PBAbilities::TELEPATHY)
        fieldscore*=0.7
      end
    end
    fieldscore*=0.01
    return fieldscore
  end

  def setupminiscore(attacker,opponent,skill,move,sweep,code,double,initialscores,scoreindex)
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    miniscore=100
    if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
      miniscore*=1.3
    end
    if initialscores.length>0
      miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
    end
    if (attacker.hp.to_f)/attacker.totalhp>0.75
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
    end
    if (attacker.hp.to_f)/attacker.totalhp<0.33
      miniscore*=0.3
    end
    if (attacker.hp.to_f)/attacker.totalhp<0.75 &&
       (!attacker.abilitynulled && (attacker.ability == PBAbilities::EMERGENCYEXIT || attacker.ability == PBAbilities::WIMPOUT) ||
       (attacker.itemWorks? && attacker.item == PBItems::EJECTBUTTON))
      miniscore*=0.3
    end
    if attacker.pbOpposingSide.effects[PBEffects::Retaliate]
      miniscore*=0.3
    end
    if opponent.effects[PBEffects::HyperBeam]>0
      miniscore*=1.3 if sweep
      miniscore*=1.2 if !sweep
    end
    if opponent.effects[PBEffects::Yawn]>0
      miniscore*=1.7 if sweep
      miniscore*=1.3 if !sweep
    end
    if skill>=PBTrainerAI.mediumSkill
      if aimem.length > 0
        maxdam = checkAIdamage(aimem,attacker,opponent,skill)
        if maxdam<(attacker.hp/4.0) && sweep
          miniscore*=1.2
        elsif maxdam<(attacker.hp/3.0) && !sweep
          miniscore*=1.1
        elsif maxdam<(attacker.hp/4.0) && code == 10
          miniscore*=1.5
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
    end
    #hi we are going in the comments for this one because it is in dire need of explanation
    #up until this point, most of the key differences between different set up moves has
    #been whether they are good for setting up to sweep or not.
    #this is not the case past here.
    #there are some really obnoxious differences between moves, and the way i'm dealing
    #with it is through binary strings.
    #this string is passed as a single number and is then processed by the function as such:
    # 00001 = attack    00010 = defense   00100 = sp.attack   01000 = sp.defense  10000 = speed
    #cosmic power would be  01010 in binary or 10 in normal, bulk up would be 00011 or 3, etc
    #evasion has a code of 0
    #this way new moves can be added and still use this function without any loss in
    #the overall scoring precision of the AI
    if attacker.turncount<2
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
    end
    if opponent.status!=0
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
    end
    if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
      miniscore*=1.3
    end
    if opponent.effects[PBEffects::Encore]>0
      if opponent.moves[(opponent.effects[PBEffects::EncoreIndex])].basedamage==0
        if sweep || code == 10 #cosmic power
          miniscore*=1.5
        else
          miniscore*=1.3
        end
      end
    end
    if attacker.effects[PBEffects::Confusion]>0
      if code & 0b1 == 0b1 #if move boosts attack
        miniscore*=0.2
        miniscore*=0.5 if double #using swords dance or shell smash while confused is Extra Bad
        miniscore*=1.5 if code & 0b11 == 0b11 #adds a correction for moves that boost attack and defense
      else
        miniscore*=0.5
      end
    end
    sweep = false if code == 3 #from here on out, bulk up is not a sweep move
    if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
      miniscore*=0.6 if sweep
      miniscore*=0.3 if !sweep
    end
    if !sweep
      miniscore*=0.2 if attacker.effects[PBEffects::Toxic]>0
      miniscore*=1.1 if opponent.status==PBStatuses::BURN && code & 0b1000 == 0b1000 #sp.def boosting
    end
    if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
      miniscore*=0.5 if sweep
      miniscore*=0.2 if !sweep
      miniscore*=1.5 if code == 0 #correction for evasion moves
    end
    if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
      miniscore*=2
    end
    if @doublebattle
      miniscore*=0.5
      miniscore*=0.5 if !sweep  #drop is doubled
    end
    return miniscore
  end

  def hasgreatmoves(initialscores,scoreindex,skill)
    #slight variance in precision based on trainer skill
    threshold = 100
    threshold = 105 if skill>=PBTrainerAI.highSkill
    threshold = 110 if skill>=PBTrainerAI.bestSkill
    for i in 0...initialscores.length
      next if i==scoreindex
      if initialscores[i]>=threshold
        return true
      end
    end
    return false
  end

  def hasbadmoves(initialscores,scoreindex,threshold)
    for i in 0...initialscores.length
      next if i==scoreindex
      if initialscores[i]>threshold
        return false
      end
    end
    return false
  end

  def unsetupminiscore(attacker,opponent,skill,move,roles,type,physical,greatmoves=false)
    #general processing for stat-dropping moves
    #attack stat = type 1   defense stat = type 2   speed = 3   evasion = no
    miniscore = 100
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    if type == 3  #speed stuff
      if (pbRoughStat(opponent,PBStats::SPEED,skill)*0.66)<attacker.pbSpeed
        if greatmoves
          miniscore*=1.5 if greatmoves
        else
          miniscore*=1.1
        end
      end
    else    #non-speed stuff
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
    end
    if type == 2    #defense stuff
      miniscore*=1.5 if checkAIhealing(aimem)
      miniscore*=1.5 if move.function == 0x4C
    else
      if roles.include?(PBMonRoles::PHYSICALWALL) || roles.include?(PBMonRoles::SPECIALWALL)
        miniscore*=1.3 if type == 1
        miniscore*=1.1 if type == 3
      end
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
    #status section
    if type == 2 || !physical
      miniscore*=1.2 if opponent.status==PBStatuses::POISON || opponent.status==PBStatuses::BURN
    elsif type == 1
      miniscore*=1.2 if opponent.status==PBStatuses::POISON
      miniscore*=0.5 if opponent.status==PBStatuses::BURN
    end
    #move checks
    if type == 1 && physical
      miniscore*=0.5 if attacker.pbHasMove?(PBMoves::FOULPLAY)
    elsif type == 3
      miniscore*=0.5 if attacker.pbHasMove?(PBMoves::GYROBALL)
      miniscore*=1.5 if attacker.pbHasMove?(PBMoves::ELECTROBALL)
      miniscore*=1.3 if checkAImoves([PBMoves::ELECTROBALL],aimem)
      miniscore*=0.5 if checkAImoves([PBMoves::GYROBALL],aimem)
      miniscore*=0.1 if  @trickroom!=0 || checkAImoves([PBMoves::TRICKROOM],aimem)
    end
    #final things
    if type == 3
      miniscore*=0.1 if opponent.itemWorks? && (opponent.item == PBItems::LAGGINGTAIL || opponent.item == PBItems::IRONBALL)
      miniscore*=0.2 if !opponent.abilitynulled && [PBAbilities::COMPETITIVE, PBAbilities::DEFIANT, PBAbilities::CONTRARY].include?(opponent.ability)
    else
      miniscore*=0.1 if !opponent.abilitynulled && [PBAbilities::UNAWARE, PBAbilities::COMPETITIVE, PBAbilities::DEFIANT, PBAbilities::CONTRARY].include?(opponent.ability)
    end
    if move.basedamage>0
      miniscore-=100
      if move.addlEffect.to_f != 100
        miniscore*=(move.addlEffect.to_f/100)
        if !attacker.abilitynulled && attacker.ability == PBAbilities::SERENEGRACE
          miniscore*=2
        end
      end
      miniscore+=100
    else
      if livecount1==1
        miniscore*=0.5
      end
      if attacker.status!=0
        miniscore*=0.7
      end
    end
    miniscore /= 100
    return miniscore
  end

  def statchangecounter(mon,initial,final,limiter=0)
    count = 0
    case limiter
      when 0 #all stats
        for i in initial..final
          count += mon.stages[i]
        end
      when 1 #increases only
        for i in initial..final
          count += mon.stages[i] if mon.stages[i]>0
        end
      when -1 #decreases only
        for i in initial..final
          count += mon.stages[i] if mon.stages[i]<0
        end
    end
    return count
  end

end
