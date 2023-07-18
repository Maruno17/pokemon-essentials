#===============================================================================
#
#===============================================================================
class Battle::AI
  def pbAIRandom(x); return rand(x); end

  #-----------------------------------------------------------------------------

  def each_battler
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i
    end
  end

  def each_foe_battler(side)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i.even? != side.even?
    end
  end

  def each_same_side_battler(side)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i.even? == side.even?
    end
  end

  def each_ally(index)
    @battlers.each_with_index do |battler, i|
      next if !battler || battler.fainted?
      yield battler, i if i != index && i.even? == index.even?
    end
  end

  #-----------------------------------------------------------------------------

  # Assumes that pkmn's ability is not negated by a global effect (e.g.
  # Neutralizing Gas).
  # pkmn is either a Battle::AI::AIBattler or a Pokemon.
  # move is a Battle::Move or a Pokemon::Move.
  def pokemon_can_absorb_move?(pkmn, move, move_type)
    return false if pkmn.is_a?(Battle::AI::AIBattler) && !pkmn.ability_active?
    # Check pkmn's ability
    # Anything with a Battle::AbilityEffects::MoveImmunity handler
    case pkmn.ability_id
    when :BULLETPROOF
      move_data = GameData::Move.get(move.id)
      return move_data.has_flag?("Bomb")
    when :FLASHFIRE
      return move_type == :FIRE
    when :LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB
      return move_type == :ELECTRIC
    when :SAPSIPPER
      return move_type == :GRASS
    when :SOUNDPROOF
      move_data = GameData::Move.get(move.id)
      return move_data.has_flag?("Sound")
    when :STORMDRAIN, :WATERABSORB, :DRYSKIN
      return move_type == :WATER
    when :TELEPATHY
      # NOTE: The move is being used by a foe of pkmn.
      return false
    when :WONDERGUARD
      types = pkmn.types
      types = pkmn.pbTypes(true) if pkmn.is_a?(Battle::AI::AIBattler)
      return !Effectiveness.super_effective_type?(move_type, *types)
    end
    return false
  end

  # Used by Toxic Spikes.
  def pokemon_can_be_poisoned?(pkmn)
    # Check pkmn's immunity to being poisoned
    return false if @battle.field.terrain == :Misty
    return false if pkmn.hasType?(:POISON)
    return false if pkmn.hasType?(:STEEL)
    return false if pkmn.hasAbility?(:IMMUNITY)
    return false if pkmn.hasAbility?(:PASTELVEIL)
    return false if pkmn.hasAbility?(:FLOWERVEIL) && pkmn.hasType?(:GRASS)
    return false if pkmn.hasAbility?(:LEAFGUARD) && [:Sun, :HarshSun].include?(@battle.pbWeather)
    return false if pkmn.hasAbility?(:COMATOSE) && pkmn.isSpecies?(:KOMALA)
    return false if pkmn.hasAbility?(:SHIELDSDOWN) && pkmn.isSpecies?(:MINIOR) && pkmn.form < 7
    return true
  end

  def pokemon_airborne?(pkmn)
    return false if pkmn.hasItem?(:IRONBALL)
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pkmn.hasType?(:FLYING)
    return true if pkmn.hasAbility?(:LEVITATE)
    return true if pkmn.hasItem?(:AIRBALLOON)
    return false
  end

  #-----------------------------------------------------------------------------

  # These values are taken from the Complete-Fire-Red-Upgrade decomp here:
  # https://github.com/Skeli789/Complete-Fire-Red-Upgrade/blob/f7f35becbd111c7e936b126f6328fc52d9af68c8/src/ability_battle_effects.c#L41
  BASE_ABILITY_RATINGS = {
    10 => [:DELTASTREAM, :DESOLATELAND, :HUGEPOWER, :MOODY, :PARENTALBOND,
           :POWERCONSTRUCT, :PRIMORDIALSEA, :PUREPOWER, :SHADOWTAG,
           :STANCECHANGE, :WONDERGUARD],
    9  => [:ARENATRAP, :DRIZZLE, :DROUGHT, :IMPOSTER, :MAGICBOUNCE, :MAGICGUARD,
           :MAGNETPULL, :SANDSTREAM, :SPEEDBOOST],
    8  => [:ADAPTABILITY, :AERILATE, :CONTRARY, :DISGUISE, :DRAGONSMAW,
           :ELECTRICSURGE, :GALVANIZE, :GRASSYSURGE, :ILLUSION, :LIBERO,
           :MISTYSURGE, :MULTISCALE, :MULTITYPE, :NOGUARD, :POISONHEAL,
           :PIXILATE, :PRANKSTER, :PROTEAN, :PSYCHICSURGE, :REFRIGERATE,
           :REGENERATOR, :RKSSYSTEM, :SERENEGRACE, :SHADOWSHIELD, :SHEERFORCE,
           :SIMPLE, :SNOWWARNING, :TECHNICIAN, :TRANSISTOR, :WATERBUBBLE],
    7  => [:BEASTBOOST, :BULLETPROOF, :COMPOUNDEYES, :DOWNLOAD, :FURCOAT,
           :HUSTLE, :ICESCALES, :INTIMIDATE, :LEVITATE, :LIGHTNINGROD,
           :MEGALAUNCHER, :MOLDBREAKER, :MOXIE, :NATURALCURE, :SAPSIPPER,
           :SHEDSKIN, :SKILLLINK, :SOULHEART, :STORMDRAIN, :TERAVOLT, :THICKFAT,
           :TINTEDLENS, :TOUGHCLAWS, :TRIAGE, :TURBOBLAZE, :UNBURDEN,
           :VOLTABSORB, :WATERABSORB],
    6  => [:BATTLEBOND, :CHLOROPHYLL, :COMATOSE, :DARKAURA, :DRYSKIN,
           :FAIRYAURA, :FILTER, :FLASHFIRE, :FORECAST, :GALEWINGS, :GUTS,
           :INFILTRATOR, :IRONBARBS, :IRONFIST, :MIRRORARMOR, :MOTORDRIVE,
           :NEUROFORCE, :PRISMARMOR, :QUEENLYMAJESTY, :RECKLESS, :ROUGHSKIN,
           :SANDRUSH, :SCHOOLING, :SCRAPPY, :SHIELDSDOWN, :SOLIDROCK, :STAKEOUT,
           :STAMINA, :STEELWORKER, :STRONGJAW, :STURDY, :SWIFTSWIM, :TOXICBOOST,
           :TRACE, :UNAWARE, :VICTORYSTAR],
    5  => [:AFTERMATH, :AIRLOCK, :ANALYTIC, :BERSERK, :BLAZE, :CLOUDNINE,
           :COMPETITIVE, :CORROSION, :DANCER, :DAZZLING, :DEFIANT, :FLAREBOOST,
           :FLUFFY, :GOOEY, :HARVEST, :HEATPROOF, :INNARDSOUT, :LIQUIDVOICE,
           :MARVELSCALE, :MUMMY, :NEUTRALIZINGGAS, :OVERCOAT, :OVERGROW,
           :PRESSURE, :QUICKFEET, :ROCKHEAD, :SANDSPIT, :SHIELDDUST, :SLUSHRUSH,
           :SWARM, :TANGLINGHAIR, :TORRENT],
    4  => [:ANGERPOINT, :BADDREAMS, :CHEEKPOUCH, :CLEARBODY, :CURSEDBODY,
           :EARLYBIRD, :EFFECTSPORE, :FLAMEBODY, :FLOWERGIFT, :FULLMETALBODY,
           :GORILLATACTICS, :HYDRATION, :ICEFACE, :IMMUNITY, :INSOMNIA,
           :JUSTIFIED, :MERCILESS, :PASTELVEIL, :POISONPOINT, :POISONTOUCH,
           :RIPEN, :SANDFORCE, :SOUNDPROOF, :STATIC, :SURGESURFER, :SWEETVEIL,
           :SYNCHRONIZE, :VITALSPIRIT, :WATERCOMPACTION, :WATERVEIL,
           :WHITESMOKE, :WONDERSKIN],
    3  => [:AROMAVEIL, :AURABREAK, :COTTONDOWN, :DAUNTLESSSHIELD,
           :EMERGENCYEXIT, :GLUTTONY, :GULPMISSLE, :HYPERCUTTER, :ICEBODY,
           :INTREPIDSWORD, :LIMBER, :LIQUIDOOZE, :LONGREACH, :MAGICIAN,
           :OWNTEMPO, :PICKPOCKET, :RAINDISH, :RATTLED, :SANDVEIL,
           :SCREENCLEANER, :SNIPER, :SNOWCLOAK, :SOLARPOWER, :STEAMENGINE,
           :STICKYHOLD, :SUPERLUCK, :UNNERVE, :WIMPOUT],
    2  => [:BATTLEARMOR, :COLORCHANGE, :CUTECHARM, :DAMP, :GRASSPELT,
           :HUNGERSWITCH, :INNERFOCUS, :LEAFGUARD, :LIGHTMETAL, :MIMICRY,
           :OBLIVIOUS, :POWERSPOT, :PROPELLORTAIL, :PUNKROCK, :SHELLARMOR,
           :STALWART, :STEADFAST, :STEELYSPIRIT, :SUCTIONCUPS, :TANGLEDFEET,
           :WANDERINGSPIRIT, :WEAKARMOR],
    1  => [:BIGPECKS, :KEENEYE, :MAGMAARMOR, :PICKUP, :RIVALRY, :STENCH],
    0  => [:ANTICIPATION, :ASONECHILLINGNEIGH, :ASONEGRIMNEIGH, :BALLFETCH,
           :BATTERY, :CHILLINGNEIGH, :CURIOUSMEDICINE, :FLOWERVEIL, :FOREWARN,
           :FRIENDGUARD, :FRISK, :GRIMNEIGH, :HEALER, :HONEYGATHER, :ILLUMINATE,
           :MINUS, :PLUS, :POWEROFALCHEMY, :QUICKDRAW, :RECEIVER, :RUNAWAY,
           :SYMBIOSIS, :TELEPATHY, :UNSEENFIST],
    -1 => [:DEFEATIST, :HEAVYMETAL, :KLUTZ, :NORMALIZE, :PERISHBODY, :STALL,
           :ZENMODE],
    -2 => [:SLOWSTART, :TRUANT]
  }

  #-----------------------------------------------------------------------------

  BASE_ITEM_RATINGS = {
    10 => [:EVIOLITE, :FOCUSSASH, :LIFEORB, :THICKCLUB],
    9  => [:ASSAULTVEST, :BLACKSLUDGE, :CHOICEBAND, :CHOICESCARF, :CHOICESPECS,
           :DEEPSEATOOTH, :LEFTOVERS],
    8  => [:LEEK, :STICK, :THROATSPRAY, :WEAKNESSPOLICY],
    7  => [:EXPERTBELT, :LIGHTBALL, :LUMBERRY, :POWERHERB, :ROCKYHELMET,
           :SITRUSBERRY],
    6  => [:KINGSROCK, :LIECHIBERRY, :LIGHTCLAY, :PETAYABERRY, :RAZORFANG,
           :REDCARD, :SALACBERRY, :SHELLBELL, :WHITEHERB,
           # Type-resisting berries
           :BABIRIBERRY, :CHARTIBERRY, :CHILANBERRY, :CHOPLEBERRY, :COBABERRY,
           :COLBURBERRY, :HABANBERRY, :KASIBBERRY, :KEBIABERRY, :OCCABERRY,
           :PASSHOBERRY, :PAYAPABERRY, :RINDOBERRY, :ROSELIBERRY, :SHUCABERRY,
           :TANGABERRY, :WACANBERRY, :YACHEBERRY,
           # Gems
           :BUGGEM, :DARKGEM, :DRAGONGEM, :ELECTRICGEM, :FAIRYGEM, :FIGHTINGGEM,
           :FIREGEM, :FLYINGGEM, :GHOSTGEM, :GRASSGEM, :GROUNDGEM, :ICEGEM,
           :NORMALGEM, :POISONGEM, :PSYCHICGEM, :ROCKGEM, :STEELGEM, :WATERGEM,
           # Legendary Orbs
           :ADAMANTORB, :GRISEOUSORB, :LUSTROUSORB, :SOULDEW,
           # Berries that heal HP and may confuse
           :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY],
    5  => [:CUSTAPBERRY, :DEEPSEASCALE, :EJECTBUTTON, :FOCUSBAND, :JABOCABERRY,
           :KEEBERRY, :LANSATBERRY, :MARANGABERRY, :MENTALHERB, :METRONOME,
           :MUSCLEBAND, :QUICKCLAW, :RAZORCLAW, :ROWAPBERRY, :SCOPELENS,
           :WISEGLASSES,
           # Type power boosters
           :BLACKBELT, :BLACKGLASSES, :CHARCOAL, :DRAGONFANG, :HARDSTONE,
           :MAGNET, :METALCOAT, :MIRACLESEED, :MYSTICWATER, :NEVERMELTICE,
           :POISONBARB, :SHARPBEAK, :SILKSCARF, :SILVERPOWDER, :SOFTSAND,
           :SPELLTAG, :TWISTEDSPOON,
           :ODDINCENSE, :ROCKINCENSE, :ROSEINCENSE, :SEAINCENSE, :WAVEINCENSE,
           # Plates
           :DRACOPLATE, :DREADPLATE, :EARTHPLATE, :FISTPLATE, :FLAMEPLATE,
           :ICICLEPLATE, :INSECTPLATE, :IRONPLATE, :MEADOWPLATE, :MINDPLATE,
           :PIXIEPLATE, :SKYPLATE, :SPLASHPLATE, :SPOOKYPLATE, :STONEPLATE,
           :TOXICPLATE, :ZAPPLATE,
           # Weather/terrain extenders
           :DAMPROCK, :HEATROCK, :ICYROCK, :SMOOTHROCK, :TERRAINEXTENDER],
    4  => [:ADRENALINEORB, :APICOTBERRY, :BLUNDERPOLICY, :CHESTOBERRY,
           :EJECTPACK, :ENIGMABERRY, :GANLONBERRY, :HEAVYDUTYBOOTS,
           :ROOMSERVICE, :SAFETYGOGGLES, :SHEDSHELL, :STARFBERRY],
    3  => [:BIGROOT, :BRIGHTPOWDER, :LAXINCENSE, :LEPPABERRY, :PERSIMBERRY,
           :PROTECTIVEPADS, :UTILITYUMBRELLA,
           # Status problem-curing berries (except Chesto which is in 4)
           :ASPEARBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY],
    2  => [:ABSORBBULB, :BERRYJUICE, :CELLBATTERY, :GRIPCLAW, :LUMINOUSMOSS,
           :MICLEBERRY, :ORANBERRY, :SNOWBALL, :WIDELENS, :ZOOMLENS,
           # Terrain seeds
           :ELECTRICSEED, :GRASSYSEED, :MISTYSEED, :PSYCHICSEED],
    1  => [:AIRBALLOON, :BINDINGBAND, :DESTINYKNOT, :FLOATSTONE, :LUCKYPUNCH,
           :METALPOWDER, :QUICKPOWDER,
           # Drives
           :BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE,
           # Memories
           :BUGMEMORY, :DARKMEMORY, :DRAGONMEMORY, :ELECTRICMEMORY,
           :FAIRYMEMORY, :FIGHTINGMEMORY, :FIREMEMORY, :FLYINGMEMORY,
           :GHOSTMEMORY, :GRASSMEMORY, :GROUNDMEMORY, :ICEMEMORY, :POISONMEMORY,
           :PSYCHICMEMORY, :ROCKMEMORY, :STEELMEMORY, :WATERMEMORY],
    0  => [:SMOKEBALL],
    -5 => [:FULLINCENSE, :LAGGINGTAIL, :RINGTARGET],
    -6 => [:MACHOBRACE, :POWERANKLET, :POWERBAND, :POWERBELT, :POWERBRACER,
           :POWERLENS, :POWERWEIGHT],
    -7 => [:FLAMEORB, :IRONBALL, :TOXICORB],
    -9 => [:STICKYBARB]
  }
end

#===============================================================================
#
#===============================================================================

Battle::AI::Handlers::AbilityRanking.add(:BLAZE,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:FIRE)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:CUTECHARM,
  proc { |ability, score, battler, ai|
    next 0 if battler.gender == 2
    next score
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:CUTECHARM, :RIVALRY)

Battle::AI::Handlers::AbilityRanking.add(:FRIENDGUARD,
  proc { |ability, score, battler, ai|
    has_ally = false
    ai.each_ally(battler.side) { |b, i| has_ally = true }
    next score if has_ally
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:FRIENDGUARD, :HEALER, :SYMBOISIS, :TELEPATHY)

Battle::AI::Handlers::AbilityRanking.add(:GALEWINGS,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.type == :FLYING }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:HUGEPOWER,
  proc { |ability, score, battler, ai|
    next score if ai.stat_raise_worthwhile?(battler, :ATTACK, true)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:HUGEPOWER, :PUREPOWER)

Battle::AI::Handlers::AbilityRanking.add(:IRONFIST,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.punchingMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:LIQUIDVOICE,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.soundMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:MEGALAUNCHER,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.pulseMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:OVERGROW,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:GRASS)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:PRANKSTER,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.statusMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:PUNKROCK,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.damagingMove? && m.soundMove? }
    next 1
  }
)

Battle::AI::Handlers::AbilityRanking.add(:RECKLESS,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.recoilMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ROCKHEAD,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.recoilMove? && !m.is_a?(Battle::Move::CrashDamageIfFailsUnusableInGravity) }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:RUNAWAY,
  proc { |ability, score, battler, ai|
    next 0 if battler.wild?
    next score
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SANDFORCE,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:GROUND, :ROCK, :STEEL)
    next 2
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SKILLLINK,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::HitTwoToFiveTimes) }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:STEELWORKER,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:STEEL)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SWARM,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:BUG)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:TORRENT,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:WATER)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:TRIAGE,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.healingMove? }
    next 0
  }
)

#===============================================================================
#
#===============================================================================

Battle::AI::Handlers::ItemRanking.add(:ADAMANTORB,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:DIALGA) &&
                  battler.has_damaging_move_of_type?(:DRAGON, :STEEL)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:AGUAVBERRY,
  proc { |item, score, battler, ai|
    if Settings::MECHANICS_GENERATION == 7   # Heals 50%
      score += 2
    elsif Settings::MECHANICS_GENERATION <= 6   # Heals 12.5%
      score -= 3
    end
    if ai.trainer.high_skill?
      if battler.battler.nature.stat_changes.any? { |val| val[0] == :SPECIAL_DEFENSE && val[1] < 0 }
        score -= 2   # Will confuse
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:ASSAULTVEST,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score += 1 if !battler.check_for_move { |m| m.statusMove? && !m.is_a?(Battle::Move::UseMoveTargetIsAboutToUse) }
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:BERRYJUICE,
  proc { |item, score, battler, ai|
    next [10 - (battler.totalhp / 15), 1].max
  }
)

Battle::AI::Handlers::ItemRanking.add(:BIGROOT,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move do |m|
      m.is_a?(Battle::Move::HealUserByHalfOfDamageDone) ||
      m.is_a?(Battle::Move::HealUserByHalfOfDamageDoneIfTargetAsleep) ||
      m.is_a?(Battle::Move::HealUserByThreeQuartersOfDamageDone) ||
      m.is_a?(Battle::Move::HealUserByTargetAttackLowerTargetAttack1) ||
      m.is_a?(Battle::Move::StartLeechSeedTarget)
    end
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:BINDINGBAND,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::BindTarget) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.copy(:BINDINGBAND, :GRIPCLAW)

Battle::AI::Handlers::ItemRanking.add(:BLACKSLUDGE,
  proc { |item, score, battler, ai|
    next score if battler.has_type?(:POISON)
    next -9
  }
)

Battle::AI::Handlers::ItemRanking.add(:CHESTOBERRY,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score += 1 if battler.has_move_with_function?("HealUserFullyAndFallAsleep")
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:CHOICEBAND,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.physicalMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.copy(:CHOICEBAND, :MUSCLEBAND)

Battle::AI::Handlers::ItemRanking.add(:CHOICESPECS,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.specialMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.copy(:CHOICESPECS, :WISEGLASSES)

Battle::AI::Handlers::ItemRanking.add(:DEEPSEASCALE,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:CLAMPERL)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:DAMPROCK,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartRainWeather) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:DEEPSEATOOTH,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:CLAMPERL) &&
                  battler.check_for_move { |m| m.specialMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:ELECTRICSEED,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartElectricTerrain) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:EVIOLITE,
  proc { |item, score, battler, ai|
    next score if battler.battler.pokemon.species_data.get_evolutions(true).length > 0
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:FIGYBERRY,
  proc { |item, score, battler, ai|
    if Settings::MECHANICS_GENERATION == 7   # Heals 50%
      score += 2
    elsif Settings::MECHANICS_GENERATION <= 6   # Heals 12.5%
      score -= 3
    end
    if ai.trainer.high_skill?
      if battler.battler.nature.stat_changes.any? { |val| val[0] == :ATTACK && val[1] < 0 }
        score -= 2   # Will confuse
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:FLAMEORB,
  proc { |item, score, battler, ai|
    next 0 if battler.status != :NONE
    next 7 if battler.wants_status_problem?(:BURN)
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:FULLINCENSE,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score = 7 if battler.has_active_ability?(:ANALYTIC)
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.copy(:FULLINCENSE, :LAGGINGTAIL)

Battle::AI::Handlers::ItemRanking.add(:GRASSYSEED,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartGrassyTerrain) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:GRISEOUSORB,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:GIRATINA) &&
                  battler.has_damaging_move_of_type?(:DRAGON, :GHOST)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:HEATROCK,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartSunWeather) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:IAPAPABERRY,
  proc { |item, score, battler, ai|
    if Settings::MECHANICS_GENERATION == 7   # Heals 50%
      score += 2
    elsif Settings::MECHANICS_GENERATION <= 6   # Heals 12.5%
      score -= 3
    end
    if ai.trainer.high_skill?
      if battler.battler.nature.stat_changes.any? { |val| val[0] == :DEFENSE && val[1] < 0 }
        score -= 2   # Will confuse
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:ICYROCK,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartHailWeather) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:IRONBALL,
  proc { |item, score, battler, ai|
    next 0 if battler.has_move_with_function?("ThrowUserItemAtTarget")
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:KINGSROCK,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score += 1 if battler.check_for_move { |m| m.multiHitMove? }
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.copy(:KINGSROCK, :RAZORFANG)

Battle::AI::Handlers::ItemRanking.add(:LEEK,
  proc { |item, score, battler, ai|
    next score if (battler.battler.isSpecies?(:FARFETCHD) || battler.battler.isSpecies?(:SIRFETCHD)) &&
                  battler.check_for_move { |m| m.damagingMove? }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.copy(:LEEK, :STICK)

Battle::AI::Handlers::ItemRanking.add(:LIGHTBALL,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:PIKACHU) &&
                  battler.check_for_move { |m| m.damagingMove? }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:LIGHTCLAY,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move do |m|
      m.is_a?(Battle::Move::StartWeakenPhysicalDamageAgainstUserSide) ||
      m.is_a?(Battle::Move::StartWeakenSpecialDamageAgainstUserSide) ||
      m.is_a?(Battle::Move::StartWeakenDamageAgainstUserSideIfHail)
    end
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:LUCKYPUNCH,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:CHANSEY)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:LUSTROUSORB,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:PALKIA) &&
                  battler.has_damaging_move_of_type?(:DRAGON, :WATER)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:MAGOBERRY,
  proc { |item, score, battler, ai|
    if Settings::MECHANICS_GENERATION == 7   # Heals 50%
      score += 2
    elsif Settings::MECHANICS_GENERATION <= 6   # Heals 12.5%
      score -= 3
    end
    if ai.trainer.high_skill?
      if battler.battler.nature.stat_changes.any? { |val| val[0] == :SPEED && val[1] < 0 }
        score -= 2   # Will confuse
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:METALPOWDER,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:DITTO) && !battler.effects[PBEffects::Transform]
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.copy(:METALPOWDER, :QUICKPOWDER)

Battle::AI::Handlers::ItemRanking.add(:MISTYSEED,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartMistyTerrain) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:ORANBERRY,
  proc { |item, score, battler, ai|
    next [10 - (battler.totalhp / 8), 1].max
  }
)

Battle::AI::Handlers::ItemRanking.add(:POWERHERB,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move do |m|
      m.is_a?(Battle::Move::TwoTurnMove) &&
      !m.is_a?(Battle::Move::TwoTurnAttackInvulnerableInSkyTargetCannotAct)
    end
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:PSYCHICSEED,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartPsychicTerrain) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:RINGTARGET,
  proc { |item, score, battler, ai|
    has_immunity = false
    battler.pbTypes(true).each do |type|
      has_immunity = GameData::Type.get(type).immunities.length > 0
      break if has_immunity
    end
    next score if has_immunity
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:SMOOTHROCK,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.is_a?(Battle::Move::StartSandstormWeather) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:SOULDEW,
  proc { |item, score, battler, ai|
    next 0 if !battler.battler.isSpecies?(:LATIAS) && !battler.battler.isSpecies?(:LATIOS)
    if Settings::SOUL_DEW_POWERS_UP_TYPES
      next 0 if !battler.has_damaging_move_of_type?(:PSYCHIC, :DRAGON)
    elsif battler.check_for_move { |m| m.specialMove?(m.type) }
      next 10
    else
      next 6   # Boosts SpDef
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:TERRAINEXTENDER,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move do |m|
      m.is_a?(Battle::Move::StartElectricTerrain) ||
      m.is_a?(Battle::Move::StartGrassyTerrain) ||
      m.is_a?(Battle::Move::StartMistyTerrain) ||
      m.is_a?(Battle::Move::StartPsychicTerrain)
    end
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:THICKCLUB,
  proc { |item, score, battler, ai|
    next score if (battler.battler.isSpecies?(:CUBONE) || battler.battler.isSpecies?(:MAROWAK)) &&
                  battler.check_for_move { |m| m.physicalMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:THROATSPRAY,
  proc { |item, score, battler, ai|
    next score if battler.check_for_move { |m| m.soundMove? }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:TOXICORB,
  proc { |item, score, battler, ai|
    next 0 if battler.status != :NONE
    next 7 if battler.wants_status_problem?(:POISON)
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:WHITEHERB,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score += 1 if battler.has_move_with_function?("LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2")
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:WIKIBERRY,
  proc { |item, score, battler, ai|
    if Settings::MECHANICS_GENERATION == 7   # Heals 50%
      score += 2
    elsif Settings::MECHANICS_GENERATION <= 6   # Heals 12.5%
      score -= 3
    end
    if ai.trainer.high_skill?
      if battler.battler.nature.stat_changes.any? { |val| val[0] == :SPECIAL_ATTACK && val[1] < 0 }
        score -= 2   # Will confuse
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:ZOOMLENS,
  proc { |item, score, battler, ai|
    if ai.trainer.high_skill?
      score += 1 if battler.stages[:ACCURACY] < 0
      battler.battler.eachMove do |m|
        next if m.accuracy == 0 || m.is_a?(Battle::Move::OHKO)
        next if m.accuracy > 70
        score += 1
        break
      end
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:type_boosting_items,
  proc { |item|
    next [:BLACKBELT, :BLACKGLASSES, :CHARCOAL, :DRAGONFANG, :HARDSTONE,
          :MAGNET, :METALCOAT, :MIRACLESEED, :MYSTICWATER, :NEVERMELTICE,
          :POISONBARB, :SHARPBEAK, :SILKSCARF, :SILVERPOWDER, :SOFTSAND,
          :SPELLTAG, :TWISTEDSPOON,
          :DRACOPLATE, :DREADPLATE, :EARTHPLATE, :FISTPLATE, :FLAMEPLATE,
          :ICICLEPLATE, :INSECTPLATE, :IRONPLATE, :MEADOWPLATE, :MINDPLATE,
          :PIXIEPLATE, :SKYPLATE, :SPLASHPLATE, :SPOOKYPLATE, :STONEPLATE,
          :TOXICPLATE, :ZAPPLATE,
          :ODDINCENSE, :ROCKINCENSE, :ROSEINCENSE, :SEAINCENSE, :WAVEINCENSE].include?(item)
  },
  proc { |item, score, battler, ai|
    boosters = {
      :BUG      => [:SILVERPOWDER, :INSECTPLATE],
      :DARK     => [:BLACKGLASSES, :DREADPLATE],
      :DRAGON   => [:DRAGONFANG, :DRACOPLATE],
      :ELECTRIC => [:MAGNET, :ZAPPLATE],
      :FAIRY    => [:PIXIEPLATE],
      :FIGHTING => [:BLACKBELT, :FISTPLATE],
      :FIRE     => [:CHARCOAL, :FLAMEPLATE],
      :FLYING   => [:SHARPBEAK, :SKYPLATE],
      :GHOST    => [:SPELLTAG, :SPOOKYPLATE],
      :GRASS    => [:MIRACLESEED, :MEADOWPLATE, :ROSEINCENSE],
      :GROUND   => [:SOFTSAND, :EARTHPLATE],
      :ICE      => [:NEVERMELTICE, :ICICLEPLATE],
      :NORMAL   => [:SILKSCARF],
      :POISON   => [:POISONBARB, :TOXICPLATE],
      :PSYCHIC  => [:TWISTEDSPOON, :MINDPLATE, :ODDINCENSE],
      :ROCK     => [:HARDSTONE, :STONEPLATE, :ROCKINCENSE],
      :STEEL    => [:METALCOAT, :IRONPLATE],
      :WATER    => [:MYSTICWATER, :SPLASHPLATE, :SEAINCENSE, :WAVEINCENSE]
    }
    boosted_type = nil
    boosters.each_pair do |type, items|
      next if !items.include?(item)
      boosted_type = type
      break
    end
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:gems,
  proc { |item|
    next [:FIREGEM, :WATERGEM, :ELECTRICGEM, :GRASSGEM, :ICEGEM, :FIGHTINGGEM,
          :POISONGEM, :GROUNDGEM, :FLYINGGEM, :PSYCHICGEM, :BUGGEM, :ROCKGEM,
          :GHOSTGEM, :DRAGONGEM, :DARKGEM, :STEELGEM, :FAIRYGEM, :NORMALGEM].include?(item)
  },
  proc { |item, score, battler, ai|
    score += 2 if Settings::MECHANICS_GENERATION <= 5   # 1.5x boost rather than 1.3x
    boosted_type = {
      :BUGGEM      => :BUG,
      :DARKGEM     => :DARK,
      :DRAGONGEM   => :DRAGON,
      :ELECTRICGEM => :ELECTRIC,
      :FAIRYGEM    => :FAIRY,
      :FIGHTINGGEM => :FIGHTING,
      :FIREGEM     => :FIRE,
      :FLYINGGEM   => :FLYING,
      :GHOSTGEM    => :GHOST,
      :GRASSGEM    => :GRASS,
      :GROUNDGEM   => :GROUND,
      :ICEGEM      => :ICE,
      :NORMALGEM   => :NORMAL,
      :POISONGEM   => :POISON,
      :PSYCHICGEM  => :PSYCHIC,
      :ROCKGEM     => :ROCK,
      :STEELGEM    => :STEEL,
      :WATERGEM    => :WATER
    }[item]
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)
