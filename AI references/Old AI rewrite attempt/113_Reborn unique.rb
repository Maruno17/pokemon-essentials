class PokeBattle_Battle
=begin
  # Added to Essentials
  def pbStatusDamage(move)
    if (move.id == PBMoves::AFTERYOU || move.id == PBMoves::BESTOW ||   # 11D, 0F3
       move.id == PBMoves::CRAFTYSHIELD || move.id == PBMoves::LUCKYCHANT ||   # 14A, 0A1
       move.id == PBMoves::MEMENTO || move.id == PBMoves::QUASH ||   # 0E2, 11E
       move.id == PBMoves::SAFEGUARD || move.id == PBMoves::SPITE ||   # 01A, 10E
       move.id == PBMoves::SPLASH || move.id == PBMoves::SWEETSCENT ||   # 001, 048
       move.id == PBMoves::TELEKINESIS || move.id == PBMoves::TELEPORT)   # 11A, 0EA
      # "001", "01A", "048", "0A1", "0E2", "0EA", "0F3", "10E", "11A", "11D", "11E", "14A"
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
      # "013", "047", "049", "052", "053", "057", "058", "059", "05E", "061",
      # "062", "066", "067", "09C", "09D", "09E", "0A6", "0A6", "0A7", "0A7",
      # "0A8", "0AB", "0AC", "0B1", "0B2", "0B8", "0BB", "0E6", "0E8", "0F6",
      # "0F9", "10F", "114", "118", "119", "120", "124", "138", "13E", "13F",
      # "143", "152", "15E", "161", "16A", "16B"
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
      # "013", "01C", "01C", "01D", "01D", "01E", "023", "027", "028", "029",
      # "037", "042", "043", "043", "047", "047", "047", "04B", "04D", "04F",
      # "051", "055", "060", "0B7", "0F8", "139", "13A", "13A", "13C", "148"
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
       # "003", "003", "003", "003", "005", "018", "01C", "021", "022", "030",
       # "042", "04A", "04B", "04C", "04D", "04D", "04E", "04F", "05C", "05D",
       # "065", "0B0", "0B5", "0DB", "0DF", "0E3", "0E4", "0FF", "100", "101",
       # "102", "137", "13D", "140", "142", "151", "15C", "16E"
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
      # "003", "003", "004", "005", "013", "040", "041", "054", "056", "05F",
      # "063", "064", "068", "069", "0AE", "0AF", "0B6", "0D9", "0DA", "0E5",
      # "0EB", "0EB", "0EF", "0EF", "0EF", "145", "146", "159"
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
      # "006", "007", "00A", "013", "016", "01B", "02A", "02A", "02F", "02F",
      # "02F", "030", "031", "033", "034", "038", "03A", "05A", "0AA", "0AA",
      # "0B9", "0BA", "0D5", "0D5", "0D5", "0D5", "0D5", "0D6", "0D7", "0D8",
      # "0D8", "0D8", "0DC", "0E7", "0F2", "0F2", "10C", "112", "117", "117",
      # "141", "160", "16D"
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
      # "007", "007", "024", "025", "02C", "0B3", "0B4", "0BC", "0ED", "103",
      # "104", "105", "10D", "11F", "14C", "154", "155", "156", "15B", "173"
      return 30
    elsif (move.id == PBMoves::AROMATHERAPY || move.id == PBMoves::BANEFULBUNKER ||
      move.id == PBMoves::HEALBELL || move.id == PBMoves::KINGSSHIELD ||
      move.id == PBMoves::LIGHTSCREEN || move.id == PBMoves::MATBLOCK ||
      move.id == PBMoves::NASTYPLOT || move.id == PBMoves::REFLECT ||
      move.id == PBMoves::SWORDSDANCE || move.id == PBMoves::TAILGLOW ||
      move.id == PBMoves::TAILWIND)
      # "019", "019", "02E", "032", "039", "05B", "0A2", "0A3", "149", "14B", "168"
      return 35
    elsif (move.id == PBMoves::DRAGONDANCE || move.id == PBMoves::GEOMANCY ||
      move.id == PBMoves::QUIVERDANCE || move.id == PBMoves::SHELLSMASH ||
      move.id == PBMoves::SHIFTGEAR)
      # "026", "02B", "035", "036", "14E"
      return 40
    elsif (move.id == PBMoves::AURORAVEIL || move.id == PBMoves::STICKYWEB ||
      move.id == PBMoves::SPORE)
      # "003", "153", "167"
      return 60
    end
  end
=end

  def pbAegislashStats(aegi)
    if aegi.form==1
      return aegi
    else
      bladecheck = aegi.clone
      bladecheck.form = 1
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
        if pbWeather !=0
          move.basedamage*=2 if move.basedamage == 50
        end

      when PBMoves::HIDDENPOWER
        if attacker
          move.type = move.pbType(type,attacker,nil)
        end

      when PBMoves::NATUREPOWER
        move=0
        if $fefieldeffect > 0
          naturemoves = FieldEffects::NATUREMOVES
          move= naturemoves[$fefieldeffect]   # Combination of environment and Terrain
        else
          move=PBMoves::TRIATTACK
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
    if $fefieldeffect==1   # Electric Terrain
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
    if $fefieldeffect==2   # Grassy Terrain
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
    if $fefieldeffect==3   # Misty Terrain
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
    if $fefieldeffect==37   # Psychic Terrain
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

  # Used by all moves that raise the user's stat(s)
  def setupminiscore(attacker,opponent,skill,move,sweep,code,double,initialscores,scoreindex)
    aimem = getAIMemory(skill,opponent.pokemonIndex)
    miniscore=100
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
    if initialscores.length>0
      miniscore*=1.3 if hasbadmoves(initialscores,scoreindex,20)
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
    if attacker.effects[PBEffects::Confusion]>0
      if code & 0b1 == 0b1 #if move boosts attack
        miniscore*=0.2
        miniscore*=0.5 if double #using swords dance or shell smash while confused is Extra Bad
        miniscore*=1.5 if code & 0b11 == 0b11 #adds a correction for moves that boost attack and defense
      else
        miniscore*=0.5
      end
    end
    if !sweep
      miniscore*=1.1 if opponent.status==PBStatuses::BURN && code & 0b1000 == 0b1000 #sp.def boosting
    end
    if checkAImoves(PBStuff::SWITCHOUTMOVE,aimem)
      miniscore*=0.5 if sweep
      miniscore*=0.2 if !sweep
      miniscore*=1.5 if code == 0 #correction for evasion moves
    end
=begin
    if attacker.effects[PBEffects::Substitute]>0 || attacker.effects[PBEffects::Disguise]
      miniscore*=1.3
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
    if opponent.status==PBStatuses::SLEEP || opponent.status==PBStatuses::FROZEN
      miniscore*=1.3
    end
    if (!attacker.abilitynulled && attacker.ability == PBAbilities::SIMPLE)
      miniscore*=2
    end
    if (attacker.hp.to_f)/attacker.totalhp>0.75
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
    end
    if opponent.effects[PBEffects::HyperBeam]>0
      miniscore*=1.3 if sweep
      miniscore*=1.2 if !sweep
    end
    if opponent.effects[PBEffects::Yawn]>0
      miniscore*=1.7 if sweep
      miniscore*=1.3 if !sweep
    end
    if attacker.turncount<2
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
    end
    if opponent.status!=0
      miniscore*=1.2 if sweep
      miniscore*=1.1 if !sweep
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
    sweep = false if code == 3 #from here on out, bulk up is not a sweep move
    if attacker.effects[PBEffects::LeechSeed]>=0 || attacker.effects[PBEffects::Attract]>=0
      miniscore*=0.6 if sweep
      miniscore*=0.3 if !sweep
    end
    miniscore*=0.2 if attacker.effects[PBEffects::Toxic]>0 && !sweep
    if @doublebattle
      miniscore*=0.5
      miniscore*=0.5 if !sweep  #drop is doubled
    end
=end

    return miniscore
  end

  # General processing for stat-dropping moves
  def unsetupminiscore(attacker,opponent,skill,move,roles,type,physical,greatmoves=false)
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
