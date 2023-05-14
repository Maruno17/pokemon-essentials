module GameData
  class Move
    attr_reader :id
    attr_reader :real_name
    attr_reader :type
    attr_reader :category
    attr_reader :power
    attr_reader :accuracy
    attr_reader :total_pp
    attr_reader :target
    attr_reader :priority
    attr_reader :function_code
    attr_reader :flags
    attr_reader :effect_chance
    attr_reader :real_description
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "moves.dat"
    PBS_BASE_FILENAME = "moves"

    SCHEMA = {
      "SectionName"  => [:id,               "m"],
      "Name"         => [:real_name,        "s"],
      "Type"         => [:type,             "e", :Type],
      "Category"     => [:category,         "e", ["Physical", "Special", "Status"]],
      "Power"        => [:power,            "u"],
      "Accuracy"     => [:accuracy,         "u"],
      "TotalPP"      => [:total_pp,         "u"],
      "Target"       => [:target,           "e", :Target],
      "Priority"     => [:priority,         "i"],
      "FunctionCode" => [:function_code,    "s"],
      "Flags"        => [:flags,            "*s"],
      "EffectChance" => [:effect_chance,    "u"],
      "Description"  => [:real_description, "q"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:real_name]        || "Unnamed"
      @type             = hash[:type]             || :NONE
      @category         = hash[:category]         || 2
      @power            = hash[:power]            || 0
      @accuracy         = hash[:accuracy]         || 100
      @total_pp         = hash[:total_pp]         || 5
      @target           = hash[:target]           || :None
      @priority         = hash[:priority]         || 0
      @function_code    = hash[:function_code]    || "None"
      @flags            = hash[:flags]            || []
      @flags            = [@flags] if !@flags.is_a?(Array)
      @effect_chance    = hash[:effect_chance]    || 0
      @real_description = hash[:real_description] || "???"
      @pbs_file_suffix  = hash[:pbs_file_suffix]  || ""
    end

    # @deprecated This method is slated to be removed in v22.
    def base_damage
      Deprecation.warn_method("base_damage", "v22", "power")
      return @power
    end

    # @return [String] the translated name of this move
    def name
      return pbGetMessageFromHash(MessageTypes::MOVE_NAMES, @real_name)
    end

    # @return [String] the translated description of this move
    def description
      return pbGetMessageFromHash(MessageTypes::MOVE_DESCRIPTIONS, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def physical?
      return false if @power == 0
      return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).physical?
    end

    def special?
      return false if @power == 0
      return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).special?
    end

    def damaging?
      return @category != 2
    end

    def status?
      return @category == 2
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
          ret = GameData::Move.get(pkmn.item.move).power
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
      return @power
    end

    def display_category(pkmn, move = nil); return @category; end
    def display_accuracy(pkmn, move = nil); return @accuracy; end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      ret = nil if ["Power", "Priority", "EffectChance"].include?(key) && ret == 0
      return ret
    end
  end
end
