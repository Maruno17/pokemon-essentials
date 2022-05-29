module GameData
  class Move
    attr_reader :id
    attr_reader :real_name
    attr_reader :type
    attr_reader :category
    # TODO: Rename base_damage to power everywhere.
    attr_reader :base_damage
    attr_reader :accuracy
    attr_reader :total_pp
    attr_reader :target
    attr_reader :priority
    attr_reader :function_code
    attr_reader :flags
    attr_reader :effect_chance
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "moves.dat"

    SCHEMA = {
      "Name"         => [:name,          "s"],
      "Type"         => [:type,          "e", :Type],
      "Category"     => [:category,      "e", ["Physical", "Special", "Status"]],
      "Power"        => [:base_damage,   "u"],
      "Accuracy"     => [:accuracy,      "u"],
      "TotalPP"      => [:total_pp,      "u"],
      "Target"       => [:target,        "e", :Target],
      "Priority"     => [:priority,      "i"],
      "FunctionCode" => [:function_code, "s"],
      "Flags"        => [:flags,         "*s"],
      "EffectChance" => [:effect_chance, "u"],
      "Description"  => [:description,   "q"],
      # All properties below here are old names for some properties above.
      # They will be removed in v21.
      "BaseDamage"   => [:base_damage,   "u"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      convert_move_data(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]          || "Unnamed"
      @type             = hash[:type]          || :NONE
      @category         = hash[:category]      || 2
      @base_damage      = hash[:base_damage]   || 0
      @accuracy         = hash[:accuracy]      || 100
      @total_pp         = hash[:total_pp]      || 5
      @target           = hash[:target]        || :None
      @priority         = hash[:priority]      || 0
      @function_code    = hash[:function_code] || "None"
      @flags            = hash[:flags]         || []
      @flags            = [@flags] if !@flags.is_a?(Array)
      @effect_chance    = hash[:effect_chance] || 0
      @real_description = hash[:description]   || "???"
    end

    # @return [String] the translated name of this move
    def name
      return pbGetMessageFromHash(MessageTypes::Moves, @real_name)
    end

    # @return [String] the translated description of this move
    def description
      return pbGetMessageFromHash(MessageTypes::MoveDescriptions, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def physical?
      return false if @base_damage == 0
      return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).physical?
    end

    def special?
      return false if @base_damage == 0
      return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).special?
    end

    def hidden_move?
      GameData::Item.each do |i|
        return true if i.is_HM? && i.move == @id
      end
      return false
    end

    def display_type(pkmn, move = nil)
=begin
      case @function_code
      when "TypeDependsOnUserIVs"
        return pbHiddenPower(pkmn)[0]
      when "TypeAndPowerDependOnUserBerry"
        type_array = {
          :NORMAL   => [:CHILANBERRY],
          :FIRE     => [:CHERIBERRY,  :BLUKBERRY,   :WATMELBERRY, :OCCABERRY],
          :WATER    => [:CHESTOBERRY, :NANABBERRY,  :DURINBERRY,  :PASSHOBERRY],
          :ELECTRIC => [:PECHABERRY,  :WEPEARBERRY, :BELUEBERRY,  :WACANBERRY],
          :GRASS    => [:RAWSTBERRY,  :PINAPBERRY,  :RINDOBERRY,  :LIECHIBERRY],
          :ICE      => [:ASPEARBERRY, :POMEGBERRY,  :YACHEBERRY,  :GANLONBERRY],
          :FIGHTING => [:LEPPABERRY,  :KELPSYBERRY, :CHOPLEBERRY, :SALACBERRY],
          :POISON   => [:ORANBERRY,   :QUALOTBERRY, :KEBIABERRY,  :PETAYABERRY],
          :GROUND   => [:PERSIMBERRY, :HONDEWBERRY, :SHUCABERRY,  :APICOTBERRY],
          :FLYING   => [:LUMBERRY,    :GREPABERRY,  :COBABERRY,   :LANSATBERRY],
          :PSYCHIC  => [:SITRUSBERRY, :TAMATOBERRY, :PAYAPABERRY, :STARFBERRY],
          :BUG      => [:FIGYBERRY,   :CORNNBERRY,  :TANGABERRY,  :ENIGMABERRY],
          :ROCK     => [:WIKIBERRY,   :MAGOSTBERRY, :CHARTIBERRY, :MICLEBERRY],
          :GHOST    => [:MAGOBERRY,   :RABUTABERRY, :KASIBBERRY,  :CUSTAPBERRY],
          :DRAGON   => [:AGUAVBERRY,  :NOMELBERRY,  :HABANBERRY,  :JABOCABERRY],
          :DARK     => [:IAPAPABERRY, :SPELONBERRY, :COLBURBERRY, :ROWAPBERRY, :MARANGABERRY],
          :STEEL    => [:RAZZBERRY,   :PAMTREBERRY, :BABIRIBERRY],
          :FAIRY    => [:ROSELIBERRY, :KEEBERRY]
        }
        if pkmn.hasItem?
          type_array.each do |type, items|
            return type if items.include?(pkmn.item_id) && GameData::Type.exists?(type)
          end
        end
      when "TypeDependsOnUserPlate"
        item_types = {
          :FISTPLATE   => :FIGHTING,
          :SKYPLATE    => :FLYING,
          :TOXICPLATE  => :POISON,
          :EARTHPLATE  => :GROUND,
          :STONEPLATE  => :ROCK,
          :INSECTPLATE => :BUG,
          :SPOOKYPLATE => :GHOST,
          :IRONPLATE   => :STEEL,
          :FLAMEPLATE  => :FIRE,
          :SPLASHPLATE => :WATER,
          :MEADOWPLATE => :GRASS,
          :ZAPPLATE    => :ELECTRIC,
          :MINDPLATE   => :PSYCHIC,
          :ICICLEPLATE => :ICE,
          :DRACOPLATE  => :DRAGON,
          :DREADPLATE  => :DARK,
          :PIXIEPLATE  => :FAIRY
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeDependsOnUserMemory"
        item_types = {
          :FIGHTINGMEMORY => :FIGHTING,
          :FLYINGMEMORY   => :FLYING,
          :POISONMEMORY   => :POISON,
          :GROUNDMEMORY   => :GROUND,
          :ROCKMEMORY     => :ROCK,
          :BUGMEMORY      => :BUG,
          :GHOSTMEMORY    => :GHOST,
          :STEELMEMORY    => :STEEL,
          :FIREMEMORY     => :FIRE,
          :WATERMEMORY    => :WATER,
          :GRASSMEMORY    => :GRASS,
          :ELECTRICMEMORY => :ELECTRIC,
          :PSYCHICMEMORY  => :PSYCHIC,
          :ICEMEMORY      => :ICE,
          :DRAGONMEMORY   => :DRAGON,
          :DARKMEMORY     => :DARK,
          :FAIRYMEMORY    => :FAIRY
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeDependsOnUserDrive"
        item_types = {
          :SHOCKDRIVE => :ELECTRIC,
          :BURNDRIVE  => :FIRE,
          :CHILLDRIVE => :ICE,
          :DOUSEDRIVE => :WATER
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeIsUserFirstType"
        return pkmn.types[0]
      end
=end
      return @type
    end

    def display_damage(pkmn, move = nil)
=begin
      case @function_code
      when "TypeDependsOnUserIVs"
        return pbHiddenPower(pkmn)[1]
      when "TypeAndPowerDependOnUserBerry"
        damage_array = {
          60 => [:CHERIBERRY,  :CHESTOBERRY, :PECHABERRY,  :RAWSTBERRY,  :ASPEARBERRY,
                 :LEPPABERRY,  :ORANBERRY,   :PERSIMBERRY, :LUMBERRY,    :SITRUSBERRY,
                 :FIGYBERRY,   :WIKIBERRY,   :MAGOBERRY,   :AGUAVBERRY,  :IAPAPABERRY,
                 :RAZZBERRY,   :OCCABERRY,   :PASSHOBERRY, :WACANBERRY,  :RINDOBERRY,
                 :YACHEBERRY,  :CHOPLEBERRY, :KEBIABERRY,  :SHUCABERRY,  :COBABERRY,
                 :PAYAPABERRY, :TANGABERRY,  :CHARTIBERRY, :KASIBBERRY,  :HABANBERRY,
                 :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :ROSELIBERRY],
          70 => [:BLUKBERRY,   :NANABBERRY,  :WEPEARBERRY, :PINAPBERRY,  :POMEGBERRY,
                 :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY,  :TAMATOBERRY,
                 :CORNNBERRY,  :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY,  :SPELONBERRY,
                 :PAMTREBERRY],
          80 => [:WATMELBERRY, :DURINBERRY,  :BELUEBERRY,  :LIECHIBERRY, :GANLONBERRY,
                 :SALACBERRY,  :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY,
                 :ENIGMABERRY, :MICLEBERRY,  :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY,
                 :KEEBERRY,    :MARANGABERRY]
        }
        if pkmn.hasItem?
          damage_array.each do |dmg, items|
            next if !items.include?(pkmn.item_id)
            ret = dmg
            ret += 20 if Settings::MECHANICS_GENERATION >= 6
            return ret
          end
        end
      when "ThrowUserItemAtTarget"
        fling_powers = {
          130 => [:IRONBALL
                 ],
          100 => [:HARDSTONE,:RAREBONE,
                  # Fossils
                  :ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,
                  :JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:ROOTFOSSIL,:SAILFOSSIL,
                  :SKULLFOSSIL
                 ],
           90 => [:DEEPSEATOOTH,:GRIPCLAW,:THICKCLUB,
                  # Plates
                  :DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,
                  :ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,
                  :PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,
                  :TOXICPLATE,:ZAPPLATE
                 ],
           80 => [:ASSAULTVEST,:CHIPPEDPOT,:CRACKEDPOT,:DAWNSTONE,:DUSKSTONE,
                  :ELECTIRIZER,:HEAVYDUTYBOOTS,:MAGMARIZER,:ODDKEYSTONE,:OVALSTONE,
                  :PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SACHET,:SAFETYGOGGLES,
                  :SHINYSTONE,:STICKYBARB,:WEAKNESSPOLICY,:WHIPPEDDREAM
                 ],
           70 => [:DRAGONFANG,:POISONBARB,
                  # EV-training items (Macho Brace is 60)
                  :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
                  :POWERWEIGHT,
                  # Drives
                  :BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:SHOCKDRIVE
                 ],
           60 => [:ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LEEK,:LUSTROUSORB,
                  :MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER
                 ],
           50 => [:DUBIOUSDISC,:SHARPBEAK,
                  # Memories
                  :BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,
                  :FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,
                  :GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,
                  :PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY
                 ],
           40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH
                 ],
           30 => [:ABSORBBULB,:ADRENALINEORB,:AMULETCOIN,:BINDINGBAND,:BLACKBELT,
                  :BLACKGLASSES,:BLACKSLUDGE,:BOTTLECAP,:CELLBATTERY,:CHARCOAL,
                  :CLEANSETAG,:DEEPSEASCALE,:DRAGONSCALE,:EJECTBUTTON,:ESCAPEROPE,
                  :EXPSHARE,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,
                  :HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,
                  :LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,
                  :MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,
                  :POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,
                  :SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,
                  :SOULDEW,:SPELLTAG,:TOXICORB,:TWISTEDSPOON,:UPGRADE,
                  # Healing items
                  :ANTIDOTE,:AWAKENING,:BERRYJUICE,:BIGMALASADA,:BLUEFLUTE,
                  :BURNHEAL,:CASTELIACONE,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,:ETHER,
                  :FRESHWATER,:FULLHEAL,:FULLRESTORE,:HEALPOWDER,:HYPERPOTION,
                  :ICEHEAL,:LAVACOOKIE,:LEMONADE,:LUMIOSEGALETTE,:MAXELIXIR,
                  :MAXETHER,:MAXHONEY,:MAXPOTION,:MAXREVIVE,:MOOMOOMILK,:OLDGATEAU,
                  :PARALYZEHEAL,:PARLYZHEAL,:PEWTERCRUNCHIES,:POTION,:RAGECANDYBAR,
                  :REDFLUTE,:REVIVALHERB,:REVIVE,:SHALOURSABLE,:SODAPOP,
                  :SUPERPOTION,:SWEETHEART,:YELLOWFLUTE,
                  # Battle items
                  :XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
                  :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,
                  :XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,
                  :XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,
                  :XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,
                  :XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,
                  :XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,
                  :XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
                  :DIREHIT,:DIREHIT2,:DIREHIT3,
                  :ABILITYURGE,:GUARDSPEC,:ITEMDROP,:ITEMURGE,:RESETURGE,
                  :MAXMUSHROOMS,
                  # Vitamins
                  :CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PPMAX,:PROTEIN,:ZINC,
                  :RARECANDY,
                  # Most evolution stones (see also 80)
                  :EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,
                  :THUNDERSTONE,:WATERSTONE,:SWEETAPPLE,:TARTAPPLE, :GALARICACUFF,
                  :GALARICAWREATH,
                  # Repels
                  :MAXREPEL,:REPEL,:SUPERREPEL,
                  # Mulches
                  :AMAZEMULCH,:BOOSTMULCH,:DAMPMULCH,:GOOEYMULCH,:GROWTHMULCH,
                  :RICHMULCH,:STABLEMULCH,:SURPRISEMULCH,
                  # Shards
                  :BLUESHARD,:GREENSHARD,:REDSHARD,:YELLOWSHARD,
                  # Valuables
                  :BALMMUSHROOM,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:COMETSHARD,
                  :NUGGET,:PEARL,:PEARLSTRING,:RELICBAND,:RELICCOPPER,:RELICCROWN,
                  :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:STARDUST,
                  :STARPIECE,:STRANGESOUVENIR,:TINYMUSHROOM,
                  # Exp Candies
                  :EXPCANDYXS, :EXPCANDYS, :EXPCANDYM, :EXPCANDYL, :EXPCANDYXL
                 ],
           20 => [# Feathers
                  :CLEVERFEATHER,:GENIUSFEATHER,:HEALTHFEATHER,:MUSCLEFEATHER,
                  :PRETTYFEATHER,:RESISTFEATHER,:SWIFTFEATHER,
                  :CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
                  :RESISTWING,:SWIFTWING
                 ],
           10 => [:AIRBALLOON,:BIGROOT,:BRIGHTPOWDER,:CHOICEBAND,:CHOICESCARF,
                  :CHOICESPECS,:DESTINYKNOT,:DISCOUNTCOUPON,:EXPERTBELT,:FOCUSBAND,
                  :FOCUSSASH,:LAGGINGTAIL,:LEFTOVERS,:MENTALHERB,:METALPOWDER,
                  :MUSCLEBAND,:POWERHERB,:QUICKPOWDER,:REAPERCLOTH,:REDCARD,
                  :RINGTARGET,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,:SMOOTHROCK,
                  :SOFTSAND,:SOOTHEBELL,:WHITEHERB,:WIDELENS,:WISEGLASSES,:ZOOMLENS,
                  # Terrain seeds
                  :ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED,
                  # Nectar
                  :PINKNECTAR,:PURPLENECTAR,:REDNECTAR,:YELLOWNECTAR,
                  # Incenses
                  :FULLINCENSE,:LAXINCENSE,:LUCKINCENSE,:ODDINCENSE,:PUREINCENSE,
                  :ROCKINCENSE,:ROSEINCENSE,:SEAINCENSE,:WAVEINCENSE,
                  # Scarves
                  :BLUESCARF,:GREENSCARF,:PINKSCARF,:REDSCARF,:YELLOWSCARF,
                  # Mints
                  :LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT, :BOLDMINT,
                  :IMPISHMINT, :LAXMINT, :RELAXEDMINT, :MODESTMINT, :MILDMINT,
                  :RASHMINT, :QUIETMINT, :CALMMINT, :GENTLEMINT, :CAREFULMINT,
                  :SASSYMINT, :TIMIDMINT, :HASTYMINT, :JOLLYMINT, :NAIVEMINT,
                  :SERIOUSMINT,
                  # Sweets
                  :STRAWBERRYSWEET, :LOVESWEET, :BERRYSWEET, :CLOVERSWEET,
                  :FLOWERSWEET, :STARSWEET, :RIBBONSWEET
                 ]
        }
        return 0 if !pkmn.item
        return 10 if pkmn.item.is_berry?
        return 80 if pkmn.item.is_mega_stone?
        if pkmn.item.is_TR?
          ret = GameData::Move.get(pkmn.item.move).base_damage
          ret = 10 if ret < 10
          return ret
        end
        fling_powers.each do |power,items|
          return power if items.include?(pkmn.item_id)
        end
        return 10
      when "PowerHigherWithUserHP"
        return [150 * pkmn.hp / pkmn.totalhp, 1].max
      when "PowerLowerWithUserHP"
        n = 48 * pkmn.hp / pkmn.totalhp
        return 200 if n < 2
        return 150 if n < 5
        return 100 if n < 10
        return 80 if n < 17
        return 40 if n < 33
        return 20
      when "PowerHigherWithUserHappiness"
        return [(pkmn.happiness * 2 / 5).floor, 1].max
      when "PowerLowerWithUserHappiness"
        return [((255 - pkmn.happiness) * 2 / 5).floor, 1].max
      when "PowerHigherWithLessPP"
        dmgs = [200, 80, 60, 50, 40]
        ppLeft = [[(move&.pp || @total_pp) - 1, 0].max, dmgs.length - 1].min
        return dmgs[ppLeft]
      end
=end
      return @base_damage
    end

    def display_category(pkmn, move = nil); return @category; end
    def display_accuracy(pkmn, move = nil); return @accuracy; end

    def convert_move_data(data)
      new_code = data[:function_code]
      case data[:function_code]
      when "000" then new_code = "None"
      when "001" then new_code = "DoesNothingUnusableInGravity"
      when "002" then new_code = "Struggle"
      when "003"
        if data[:id] == :RELICSONG
          new_code = "SleepTargetChangeUserMeloettaForm"
        elsif data[:id] == :DARKVOID && Settings::MECHANICS_GENERATION >= 7
          new_code = "SleepTargetIfUserDarkrai"
        else
          new_code = "SleepTarget"
        end
      when "004" then new_code = "SleepTargetNextTurn"
      when "005" then new_code = "PoisonTarget"
      when "006" then new_code = "BadPoisonTarget"
      when "007"
        if data[:id] == :THUNDERWAVE
          new_code = "ParalyzeTargetIfNotTypeImmune"
        else
          new_code = "ParalyzeTarget"
        end
      when "008" then new_code = "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"
      when "009" then new_code = "ParalyzeFlinchTarget"
      when "00A" then new_code = "BurnTarget"
      when "00B" then new_code = "BurnFlinchTarget"
      when "00C" then new_code = "FreezeTarget"
      when "00D" then new_code = "FreezeTargetAlwaysHitsInHail"
      when "00E" then new_code = "FreezeFlinchTarget"
      when "00F", "010" then new_code = "FlinchTarget"
      when "011" then new_code = "FlinchTargetFailsIfUserNotAsleep"
      when "012" then new_code = "FlinchTargetFailsIfNotUserFirstTurn"
      when "013", "014" then new_code = "ConfuseTarget"
      when "015" then new_code = "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
      when "016" then new_code = "AttractTarget"
      when "017" then new_code = "ParalyzeBurnOrFreezeTarget"
      when "018" then new_code = "CureUserBurnPoisonParalysis"
      when "019" then new_code = "CureUserPartyStatus"
      when "01A" then new_code = "StartUserSideImmunityToInflictedStatus"
      when "01B" then new_code = "GiveUserStatusToTarget"
      when "01C" then new_code = "RaiseUserAttack1"
      when "01D" then new_code = "RaiseUserDefense1"
      when "01E" then new_code = "RaiseUserDefense1CurlUpUser"
      when "01F" then new_code = "RaiseUserSpeed1"
      when "020" then new_code = "RaiseUserSpAtk1"
      when "021" then new_code = "RaiseUserSpDef1PowerUpElectricMove"
      when "022" then new_code = "RaiseUserEvasion1"
      when "023" then new_code = "RaiseUserCriticalHitRate2"
      when "024" then new_code = "RaiseUserAtkDef1"
      when "025" then new_code = "RaiseUserAtkDefAcc1"
      when "026" then new_code = "RaiseUserAtkSpd1"
      when "027" then new_code = "RaiseUserAtkSpAtk1"
      when "028" then new_code = "RaiseUserAtkSpAtk1Or2InSun"
      when "029" then new_code = "RaiseUserAtkAcc1"
      when "02A" then new_code = "RaiseUserDefSpDef1"
      when "02B" then new_code = "RaiseUserSpAtkSpDefSpd1"
      when "02C" then new_code = "RaiseUserSpAtkSpDef1"
      when "02D" then new_code = "RaiseUserMainStats1"
      when "02E" then new_code = "RaiseUserAttack2"
      when "02F" then new_code = "RaiseUserDefense2"
      when "030" then new_code = "RaiseUserSpeed2"
      when "031" then new_code = "RaiseUserSpeed2LowerUserWeight"
      when "032" then new_code = "RaiseUserSpAtk2"
      when "033" then new_code = "RaiseUserSpDef2"
      when "034" then new_code = "RaiseUserEvasion2MinimizeUser"
      when "035" then new_code = "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2"
      when "036" then new_code = "RaiseUserAtk1Spd2"
      when "037" then new_code = "RaiseTargetRandomStat2"
      when "038" then new_code = "RaiseUserDefense3"
      when "039" then new_code = "RaiseUserSpAtk3"
      when "03A" then new_code = "MaxUserAttackLoseHalfOfTotalHP"
      when "03B" then new_code = "LowerUserAtkDef1"
      when "03C" then new_code = "LowerUserDefSpDef1"
      when "03D" then new_code = "LowerUserDefSpDefSpd1"
      when "03E" then new_code = "LowerUserSpeed1"
      when "03F" then new_code = "LowerUserSpAtk2"
      when "040" then new_code = "RaiseTargetSpAtk1ConfuseTarget"
      when "041" then new_code = "RaiseTargetAttack2ConfuseTarget"
      when "042" then new_code = "LowerTargetAttack1"
      when "043" then new_code = "LowerTargetDefense1"
      when "044"
        if data[:id] == :BULLDOZE
          new_code = "LowerTargetSpeed1WeakerInGrassyTerrain"
        else
          new_code = "LowerTargetSpeed1"
        end
      when "045" then new_code = "LowerTargetSpAtk1"
      when "046" then new_code = "LowerTargetSpDef1"
      when "047" then new_code = "LowerTargetAccuracy1"
      when "048"
        if data[:id] == :SWEETSCENT && Settings::MECHANICS_GENERATION >= 6
          new_code = "LowerTargetEvasion2"
        else
          new_code = "LowerTargetEvasion1"
        end
      when "049" then new_code = "LowerTargetEvasion1RemoveSideEffects"
      when "04A" then new_code = "LowerTargetAtkDef1"
      when "04B" then new_code = "LowerTargetAttack2"
      when "04C" then new_code = "LowerTargetDefense2"
      when "04D" then new_code = "LowerTargetSpeed2"
      when "04E" then new_code = "LowerTargetSpAtk2IfCanAttract"
      when "04F" then new_code = "LowerTargetSpDef2"
      when "050" then new_code = "ResetTargetStatStages"
      when "051" then new_code = "ResetAllBattlersStatStages"
      when "052" then new_code = "UserTargetSwapAtkSpAtkStages"
      when "053" then new_code = "UserTargetSwapDefSpDefStages"
      when "054" then new_code = "UserTargetSwapStatStages"
      when "055" then new_code = "UserCopyTargetStatStages"
      when "056" then new_code = "StartUserSideImmunityToStatStageLowering"
      when "057" then new_code = "UserSwapBaseAtkDef"
      when "058" then new_code = "UserTargetAverageBaseAtkSpAtk"
      when "059" then new_code = "UserTargetAverageBaseDefSpDef"
      when "05A" then new_code = "UserTargetAverageHP"
      when "05B" then new_code = "StartUserSideDoubleSpeed"
      when "05C" then new_code = "ReplaceMoveThisBattleWithTargetLastMoveUsed"
      when "05D" then new_code = "ReplaceMoveWithTargetLastMoveUsed"
      when "05E" then new_code = "SetUserTypesToUserMoveType"
      when "05F" then new_code = "SetUserTypesToResistLastAttack"
      when "060" then new_code = "SetUserTypesBasedOnEnvironment"
      when "061" then new_code = "SetTargetTypesToWater"
      when "062" then new_code = "SetUserTypesToTargetTypes"
      when "063" then new_code = "SetTargetAbilityToSimple"
      when "064" then new_code = "SetTargetAbilityToInsomnia"
      when "065" then new_code = "SetUserAbilityToTargetAbility"
      when "066" then new_code = "SetTargetAbilityToUserAbility"
      when "067" then new_code = "UserTargetSwapAbilities"
      when "068" then new_code = "NegateTargetAbility"
      when "069" then new_code = "TransformUserIntoTarget"
      when "06A" then new_code = "FixedDamage20"
      when "06B" then new_code = "FixedDamage40"
      when "06C" then new_code = "FixedDamageHalfTargetHP"
      when "06D" then new_code = "FixedDamageUserLevel"
      when "06E" then new_code = "LowerTargetHPToUserHP"
      when "06F" then new_code = "FixedDamageUserLevelRandom"
      when "070"
        if data[:id] == :FISSURE
          new_code = "OHKOHitsUndergroundTarget"
        elsif data[:id] == :SHEERCOLD && Settings::MECHANICS_GENERATION >= 7
          new_code = "OHKOIce"
        else
          new_code = "OHKO"
        end
      when "071" then new_code = "CounterPhysicalDamage"
      when "072" then new_code = "CounterSpecialDamage"
      when "073" then new_code = "CounterDamagePlusHalf"
      when "074" then new_code = "DamageTargetAlly"
      when "075" then new_code = "DoublePowerIfTargetUnderwater"
      when "076" then new_code = "DoublePowerIfTargetUnderground"
      when "077" then new_code = "DoublePowerIfTargetInSky"
      when "078" then new_code = "FlinchTargetDoublePowerIfTargetInSky"
      when "079" then new_code = "DoublePowerAfterFusionFlare"
      when "07A" then new_code = "DoublePowerAfterFusionBolt"
      when "07B" then new_code = "DoublePowerIfTargetPoisoned"
      when "07C" then new_code = "DoublePowerIfTargetParalyzedCureTarget"
      when "07D" then new_code = "DoublePowerIfTargetAsleepCureTarget"
      when "07E" then new_code = "DoublePowerIfUserPoisonedBurnedParalyzed"
      when "07F" then new_code = "DoublePowerIfTargetStatusProblem"
      when "080" then new_code = "DoublePowerIfTargetHPLessThanHalf"
      when "081" then new_code = "DoublePowerIfUserLostHPThisTurn"
      when "082" then new_code = "DoublePowerIfTargetLostHPThisTurn"
      when "083" then new_code = "UsedAfterAllyRoundWithDoublePower"
      when "084" then new_code = "DoublePowerIfTargetActed"
      when "085" then new_code = "DoublePowerIfAllyFaintedLastTurn"
      when "086" then new_code = "DoublePowerIfUserHasNoItem"
      when "087" then new_code = "TypeAndPowerDependOnWeather"
      when "088" then new_code = "PursueSwitchingFoe"
      when "089" then new_code = "PowerHigherWithUserHappiness"
      when "08A" then new_code = "PowerLowerWithUserHappiness"
      when "08B" then new_code = "PowerHigherWithUserHP"
      when "08C" then new_code = "PowerHigherWithTargetHP"
      when "08D" then new_code = "PowerHigherWithTargetFasterThanUser"
      when "08E" then new_code = "PowerHigherWithUserPositiveStatStages"
      when "08F" then new_code = "PowerHigherWithTargetPositiveStatStages"
      when "090" then new_code = "TypeDependsOnUserIVs"
      when "091" then new_code = "PowerHigherWithConsecutiveUse"
      when "092" then new_code = "PowerHigherWithConsecutiveUseOnUserSide"
      when "093" then new_code = "StartRaiseUserAtk1WhenDamaged"
      when "094" then new_code = "RandomlyDamageOrHealTarget"
      when "095" then new_code = "RandomPowerDoublePowerIfTargetUnderground"
      when "096" then new_code = "TypeAndPowerDependOnUserBerry"
      when "097" then new_code = "PowerHigherWithLessPP"
      when "098" then new_code = "PowerLowerWithUserHP"
      when "099" then new_code = "PowerHigherWithUserFasterThanTarget"
      when "09A" then new_code = "PowerHigherWithTargetWeight"
      when "09B" then new_code = "PowerHigherWithUserHeavierThanTarget"
      when "09C" then new_code = "PowerUpAllyMove"
      when "09D" then new_code = "StartWeakenElectricMoves"
      when "09E" then new_code = "StartWeakenFireMoves"
      when "09F"
        case data[:id]
        when :MULTIATTACK
          new_code = "TypeDependsOnUserMemory"
        when :TECHNOBLAST
          new_code = "TypeDependsOnUserDrive"
        else
          new_code = "TypeDependsOnUserPlate"
        end
      when "0A0" then new_code = "AlwaysCriticalHit"
      when "0A1" then new_code = "StartPreventCriticalHitsAgainstUserSide"
      when "0A2" then new_code = "StartWeakenPhysicalDamageAgainstUserSide"
      when "0A3" then new_code = "StartWeakenSpecialDamageAgainstUserSide"
      when "0A4" then new_code = "EffectDependsOnEnvironment"
      when "0A5"
        new_code = "None"
        data[:accuracy] = 0
      when "0A6" then new_code = "EnsureNextMoveAlwaysHits"
      when "0A7" then new_code = "StartNegateTargetEvasionStatStageAndGhostImmunity"
      when "0A8" then new_code = "StartNegateTargetEvasionStatStageAndDarkImmunity"
      when "0A9" then new_code = "IgnoreTargetDefSpDefEvaStatStages"
      when "0AA" then new_code = "ProtectUser"
      when "0AB" then new_code = "ProtectUserSideFromPriorityMoves"
      when "0AC" then new_code = "ProtectUserSideFromMultiTargetDamagingMoves"
      when "0AD" then new_code = "RemoveProtections"
      when "0AE" then new_code = "UseLastMoveUsedByTarget"
      when "0AF" then new_code = "UseLastMoveUsed"
      when "0B0" then new_code = "UseMoveTargetIsAboutToUse"
      when "0B1" then new_code = "BounceBackProblemCausingStatusMoves"
      when "0B2" then new_code = "StealAndUseBeneficialStatusMove"
      when "0B3" then new_code = "UseMoveDependingOnEnvironment"
      when "0B4" then new_code = "UseRandomUserMoveIfAsleep"
      when "0B5" then new_code = "UseRandomMoveFromUserParty"
      when "0B6" then new_code = "UseRandomMove"
      when "0B7" then new_code = "DisableTargetUsingSameMoveConsecutively"
      when "0B8" then new_code = "DisableTargetMovesKnownByUser"
      when "0B9" then new_code = "DisableTargetLastMoveUsed"
      when "0BA" then new_code = "DisableTargetStatusMoves"
      when "0BB" then new_code = "DisableTargetHealingMoves"
      when "0BC" then new_code = "DisableTargetUsingDifferentMove"
      when "0BD" then new_code = "HitTwoTimes"
      when "0BE" then new_code = "HitTwoTimesPoisonTarget"
      when "0BF" then new_code = "HitThreeTimesPowersUpWithEachHit"
      when "0C0"
        if data[:id] == :WATERSHURIKEN
          new_code = "HitTwoToFiveTimesOrThreeForAshGreninja"
        else
          new_code = "HitTwoToFiveTimes"
        end
      when "0C1" then new_code = "HitOncePerUserTeamMember"
      when "0C2" then new_code = "AttackAndSkipNextTurn"
      when "0C3" then new_code = "TwoTurnAttack"
      when "0C4" then new_code = "TwoTurnAttackOneTurnInSun"
      when "0C5" then new_code = "TwoTurnAttackParalyzeTarget"
      when "0C6" then new_code = "TwoTurnAttackBurnTarget"
      when "0C7" then new_code = "TwoTurnAttackFlinchTarget"
      when "0C8" then new_code = "TwoTurnAttackChargeRaiseUserDefense1"
      when "0C9" then new_code = "TwoTurnAttackInvulnerableInSky"
      when "0CA" then new_code = "TwoTurnAttackInvulnerableUnderground"
      when "0CB" then new_code = "TwoTurnAttackInvulnerableUnderwater"
      when "0CC" then new_code = "TwoTurnAttackInvulnerableInSkyParalyzeTarget"
      when "0CD" then new_code = "TwoTurnAttackInvulnerableRemoveProtections"
      when "0CE" then new_code = "TwoTurnAttackInvulnerableInSkyTargetCannotAct"
      when "0CF" then new_code = "BindTarget"
      when "0D0" then new_code = "BindTargetDoublePowerIfTargetUnderwater"
      when "0D1" then new_code = "MultiTurnAttackPreventSleeping"
      when "0D2" then new_code = "MultiTurnAttackConfuseUserAtEnd"
      when "0D3" then new_code = "MultiTurnAttackPowersUpEachTurn"
      when "0D4" then new_code = "MultiTurnAttackBideThenReturnDoubleDamage"
      when "0D5" then new_code = "HealUserHalfOfTotalHP"
      when "0D6" then new_code = "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn"
      when "0D7" then new_code = "HealUserPositionNextTurn"
      when "0D8" then new_code = "HealUserDependingOnWeather"
      when "0D9" then new_code = "HealUserFullyAndFallAsleep"
      when "0DA" then new_code = "StartHealUserEachTurn"
      when "0DB" then new_code = "StartHealUserEachTurnTrapUserInBattle"
      when "0DC" then new_code = "StartLeechSeedTarget"
      when "0DD" then new_code = "HealUserByHalfOfDamageDone"
      when "0DE" then new_code = "HealUserByHalfOfDamageDoneIfTargetAsleep"
      when "0DF" then new_code = "HealTargetHalfOfTotalHP"
      when "0E0" then new_code = "UserFaintsExplosive"
      when "0E1" then new_code = "UserFaintsFixedDamageUserHP"
      when "0E2" then new_code = "UserFaintsLowerTargetAtkSpAtk2"
      when "0E3" then new_code = "UserFaintsHealAndCureReplacement"
      when "0E4" then new_code = "UserFaintsHealAndCureReplacementRestorePP"
      when "0E5" then new_code = "StartPerishCountsForAllBattlers"
      when "0E6" then new_code = "SetAttackerMovePPTo0IfUserFaints"
      when "0E7" then new_code = "AttackerFaintsIfUserFaints"
      when "0E8" then new_code = "UserEnduresFaintingThisTurn"
      when "0E9" then new_code = "CannotMakeTargetFaint"
      when "0EA"
        if Settings::MECHANICS_GENERATION >= 8
          new_code = "SwitchOutUserStatusMove"
        else
          new_code = "FleeFromBattle"
        end
      when "0EB" then new_code = "SwitchOutTargetStatusMove"
      when "0EC" then new_code = "SwitchOutTargetDamagingMove"
      when "0ED" then new_code = "SwitchOutUserPassOnEffects"
      when "0EE" then new_code = "SwitchOutUserDamagingMove"
      when "0EF" then new_code = "TrapTargetInBattle"
      when "0F0" then new_code = "RemoveTargetItem"
      when "0F1" then new_code = "UserTakesTargetItem"
      when "0F2" then new_code = "UserTargetSwapItems"
      when "0F3" then new_code = "TargetTakesUserItem"
      when "0F4" then new_code = "UserConsumeTargetBerry"
      when "0F5" then new_code = "DestroyTargetBerryOrGem"
      when "0F6" then new_code = "RestoreUserConsumedItem"
      when "0F7" then new_code = "ThrowUserItemAtTarget"
      when "0F8" then new_code = "StartTargetCannotUseItem"
      when "0F9" then new_code = "StartNegateHeldItems"
      when "0FA" then new_code = "RecoilQuarterOfDamageDealt"
      when "0FB" then new_code = "RecoilThirdOfDamageDealt"
      when "0FC" then new_code = "RecoilHalfOfDamageDealt"
      when "0FD" then new_code = "RecoilThirdOfDamageDealtParalyzeTarget"
      when "0FE" then new_code = "RecoilThirdOfDamageDealtBurnTarget"
      when "0FF" then new_code = "StartSunWeather"
      when "100" then new_code = "StartRainWeather"
      when "101" then new_code = "StartSandstormWeather"
      when "102" then new_code = "StartHailWeather"
      when "103" then new_code = "AddSpikesToFoeSide"
      when "104" then new_code = "AddToxicSpikesToFoeSide"
      when "105" then new_code = "AddStealthRocksToFoeSide"
      when "106" then new_code = "GrassPledge"
      when "107" then new_code = "FirePledge"
      when "108" then new_code = "WaterPledge"
      when "109" then new_code = "AddMoneyGainedFromBattle"
      when "10A" then new_code = "RemoveScreens"
      when "10B" then new_code = "CrashDamageIfFailsUnusableInGravity"
      when "10C" then new_code = "UserMakeSubstitute"
      when "10D" then new_code = "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1"
      when "10E" then new_code = "LowerPPOfTargetLastMoveBy4"
      when "10F" then new_code = "StartDamageTargetEachTurnIfTargetAsleep"
      when "110" then new_code = "RemoveUserBindingAndEntryHazards"
      when "111" then new_code = "AttackTwoTurnsLater"
      when "112" then new_code = "UserAddStockpileRaiseDefSpDef1"
      when "113" then new_code = "PowerDependsOnUserStockpile"
      when "114" then new_code = "HealUserDependingOnUserStockpile"
      when "115" then new_code = "FailsIfUserDamagedThisTurn"
      when "116" then new_code = "FailsIfTargetActed"
      when "117" then new_code = "RedirectAllMovesToUser"
      when "118" then new_code = "StartGravity"
      when "119" then new_code = "StartUserAirborne"
      when "11A" then new_code = "StartTargetAirborneAndAlwaysHitByMoves"
      when "11B" then new_code = "HitsTargetInSky"
      when "11C" then new_code = "HitsTargetInSkyGroundsTarget"
      when "11D" then new_code = "TargetActsNext"
      when "11E" then new_code = "TargetActsLast"
      when "11F" then new_code = "StartSlowerBattlersActFirst"
      when "120" then new_code = "UserSwapsPositionsWithAlly"
      when "121" then new_code = "UseTargetAttackInsteadOfUserAttack"
      when "122" then new_code = "UseTargetDefenseInsteadOfTargetSpDef"
      when "123" then new_code = "FailsUnlessTargetSharesTypeWithUser"
      when "124" then new_code = "StartSwapAllBattlersBaseDefensiveStats"
      when "125" then new_code = "FailsIfUserHasUnusedMove"
      when "126" then new_code = "None"
      when "127" then new_code = "ParalyzeTarget"
      when "128" then new_code = "BurnTarget"
      when "129" then new_code = "FreezeTarget"
      when "12A" then new_code = "ConfuseTarget"
      when "12B" then new_code = "LowerTargetDefense2"
      when "12C" then new_code = "LowerTargetEvasion2"
      when "12D" then new_code = "DoublePowerIfTargetUnderwater"
      when "12E" then new_code = "AllBattlersLoseHalfHPUserSkipsNextTurn"
      when "12F" then new_code = "TrapTargetInBattle"
      when "130" then new_code = "UserLosesHalfHP"
      when "131" then new_code = "StartShadowSkyWeather"
      when "132" then new_code = "RemoveAllScreens"
      when "133" then new_code = "DoesNothingFailsIfNoAlly"
      when "134" then new_code = "DoesNothingCongratulations"
      when "135" then new_code = "FreezeTargetSuperEffectiveAgainstWater"
      when "136" then new_code = "RaiseUserDefense2"
      when "137" then new_code = "RaisePlusMinusUserAndAlliesDefSpDef1"
      when "138" then new_code = "RaiseTargetSpDef1"
      when "139" then new_code = "LowerTargetAttack1BypassSubstitute"
      when "13A" then new_code = "LowerTargetAtkSpAtk1"
      when "13B" then new_code = "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
      when "13C" then new_code = "LowerTargetSpAtk1"
      when "13D" then new_code = "LowerTargetSpAtk2"
      when "13E" then new_code = "RaiseGroundedGrassBattlersAtkSpAtk1"
      when "13F" then new_code = "RaiseGrassBattlersDef1"
      when "140" then new_code = "LowerPoisonedTargetAtkSpAtkSpd1"
      when "141" then new_code = "InvertTargetStatStages"
      when "142" then new_code = "AddGhostTypeToTarget"
      when "143" then new_code = "AddGrassTypeToTarget"
      when "144" then new_code = "EffectivenessIncludesFlyingType"
      when "145" then new_code = "TargetMovesBecomeElectric"
      when "146" then new_code = "NormalMovesBecomeElectric"
      when "147" then new_code = "RemoveProtectionsBypassSubstitute"
      when "148" then new_code = "TargetNextFireMoveDamagesTarget"
      when "149" then new_code = "ProtectUserSideFromDamagingMovesIfUserFirstTurn"
      when "14A" then new_code = "ProtectUserSideFromStatusMoves"
      when "14B" then new_code = "ProtectUserFromDamagingMovesKingsShield"
      when "14C" then new_code = "ProtectUserFromTargetingMovesSpikyShield"
      when "14D" then new_code = "TwoTurnAttackInvulnerableRemoveProtections"
      when "14E" then new_code = "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
      when "14F" then new_code = "HealUserByThreeQuartersOfDamageDone"
      when "150" then new_code = "RaiseUserAttack3IfTargetFaints"
      when "151" then new_code = "LowerTargetAtkSpAtk1SwitchOutUser"
      when "152" then new_code = "TrapAllBattlersInBattleForOneTurn"
      when "153" then new_code = "AddStickyWebToFoeSide"
      when "154" then new_code = "StartElectricTerrain"
      when "155" then new_code = "StartGrassyTerrain"
      when "156" then new_code = "StartMistyTerrain"
      when "157" then new_code = "DoubleMoneyGainedFromBattle"
      when "158" then new_code = "FailsIfUserNotConsumedBerry"
      when "159" then new_code = "PoisonTargetLowerTargetSpeed1"
      when "15A" then new_code = "CureTargetBurn"
      when "15B" then new_code = "CureTargetStatusHealUserHalfOfTotalHP"
      when "15C" then new_code = "RaisePlusMinusUserAndAlliesAtkSpAtk1"
      when "15D" then new_code = "UserStealTargetPositiveStatStages"
      when "15E" then new_code = "EnsureNextCriticalHit"
      when "15F" then new_code = "LowerUserDefense1"
      when "160" then new_code = "HealUserByTargetAttackLowerTargetAttack1"
      when "161" then new_code = "UserTargetSwapBaseSpeed"
      when "162" then new_code = "UserLosesFireType"
      when "163" then new_code = "IgnoreTargetAbility"
      when "164" then new_code = "CategoryDependsOnHigherDamageIgnoreTargetAbility"
      when "165" then new_code = "NegateTargetAbilityIfTargetActed"
      when "166" then new_code = "DoublePowerIfUserLastMoveFailed"
      when "167" then new_code = "StartWeakenDamageAgainstUserSideIfHail"
      when "168" then new_code = "ProtectUserBanefulBunker"
      when "169" then new_code = "TypeIsUserFirstType"
      when "16A" then new_code = "RedirectAllMovesToTarget"
      when "16B" then new_code = "TargetUsesItsLastUsedMoveAgain"
      when "16C" then new_code = "DisableTargetSoundMoves"
      when "16D" then new_code = "HealUserDependingOnSandstorm"
      when "16E" then new_code = "HealTargetDependingOnGrassyTerrain"
      when "16F" then new_code = "HealAllyOrDamageFoe"
      when "170" then new_code = "UserLosesHalfOfTotalHPExplosive"
      when "171" then new_code = "UsedAfterUserTakesPhysicalDamage"
      when "172" then new_code = "BurnAttackerBeforeUserActs"
      when "173" then new_code = "StartPsychicTerrain"
      when "174" then new_code = "FailsIfNotUserFirstTurn"
      when "175" then new_code = "HitTwoTimesFlinchTarget"
      end
      data[:function_code] = new_code
      return data
    end
  end
end
