module GameData
  class Item
    attr_reader :id
    attr_reader :real_name
    attr_reader :real_name_plural
    attr_reader :real_portion_name
    attr_reader :real_portion_name_plural
    attr_reader :pocket
    attr_reader :price
    attr_reader :sell_price
    attr_reader :bp_price
    attr_reader :field_use
    attr_reader :battle_use
    attr_reader :flags
    attr_reader :consumable
    attr_reader :show_quantity
    attr_reader :move
    attr_reader :real_description
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "items.dat"
    PBS_BASE_FILENAME = "items"

    SCHEMA = {
      "SectionName"       => [:id,                       "m"],
      "Name"              => [:real_name,                "s"],
      "NamePlural"        => [:real_name_plural,         "s"],
      "PortionName"       => [:real_portion_name,        "s"],
      "PortionNamePlural" => [:real_portion_name_plural, "s"],
      "Pocket"            => [:pocket,                   "v"],
      "Price"             => [:price,                    "u"],
      "SellPrice"         => [:sell_price,               "u"],
      "BPPrice"           => [:bp_price,                 "u"],
      "FieldUse"          => [:field_use,                "e", {"OnPokemon" => 1, "Direct" => 2,
                                                               "TM" => 3, "HM" => 4, "TR" => 5}],
      "BattleUse"         => [:battle_use,               "e", {"OnPokemon" => 1, "OnMove" => 2,
                                                               "OnBattler" => 3, "OnFoe" => 4, "Direct" => 5}],
      "Flags"             => [:flags,                    "*s"],
      "Consumable"        => [:consumable,               "b"],
      "ShowQuantity"      => [:show_quantity,            "b"],
      "Move"              => [:move,                     "e", :Move],
      "Description"       => [:real_description,         "q"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.editor_properties
      field_use_array = [_INTL("Can't use in field")]
      self.schema["FieldUse"][2].each { |key, value| field_use_array[value] = key if !field_use_array[value] }
      battle_use_array = [_INTL("Can't use in battle")]
      self.schema["BattleUse"][2].each { |key, value| battle_use_array[value] = key if !battle_use_array[value] }
      return [
        ["ID",                ReadOnlyProperty,                        _INTL("ID of this item (used as a symbol like :XXX).")],
        ["Name",              ItemNameProperty,                        _INTL("Name of this item as displayed by the game.")],
        ["NamePlural",        ItemNameProperty,                        _INTL("Plural name of this item as displayed by the game.")],
        ["PortionName",       ItemNameProperty,                        _INTL("Name of a portion of this item as displayed by the game.")],
        ["PortionNamePlural", ItemNameProperty,                        _INTL("Name of 2 or more portions of this item as displayed by the game.")],
        ["Pocket",            PocketProperty,                          _INTL("Pocket in the Bag where this item is stored.")],
        ["Price",             LimitProperty.new(Settings::MAX_MONEY),  _INTL("Purchase price of this item.")],
        ["SellPrice",         LimitProperty2.new(Settings::MAX_MONEY), _INTL("Sell price of this item. If blank, is half the purchase price.")],
        ["BPPrice",           LimitProperty.new(Settings::MAX_BATTLE_POINTS), _INTL("Purchase price of this item in Battle Points (BP).")],
        ["FieldUse",          EnumProperty.new(field_use_array),       _INTL("How this item can be used outside of battle.")],
        ["BattleUse",         EnumProperty.new(battle_use_array),      _INTL("How this item can be used within a battle.")],
        ["Flags",             StringListProperty,                      _INTL("Words/phrases that can be used to group certain kinds of items.")],
        ["Consumable",        BooleanProperty,                         _INTL("Whether this item is consumed after use.")],
        ["ShowQuantity",      BooleanProperty,                         _INTL("Whether the Bag shows how many of this item are in there.")],
        ["Move",              MoveProperty,                            _INTL("Move taught by this HM, TM or TR.")],
        ["Description",       StringProperty,                          _INTL("Description of this item.")]
      ]
    end

    def self.icon_filename(item)
      return "Graphics/Items/back" if item.nil?
      item_data = self.try_get(item)
      return "Graphics/Items/000" if item_data.nil?
      # Check for files
      ret = sprintf("Graphics/Items/%s", item_data.id)
      return ret if pbResolveBitmap(ret)
      # Check for TM/HM type icons
      if item_data.is_machine?
        prefix = "machine"
        if item_data.is_HM?
          prefix = "machine_hm"
        elsif item_data.is_TR?
          prefix = "machine_tr"
        end
        move_type = GameData::Move.get(item_data.move).type
        type_data = GameData::Type.get(move_type)
        ret = sprintf("Graphics/Items/%s_%s", prefix, type_data.id)
        return ret if pbResolveBitmap(ret)
        if !item_data.is_TM?
          ret = sprintf("Graphics/Items/machine_%s", type_data.id)
          return ret if pbResolveBitmap(ret)
        end
      end
      return "Graphics/Items/000"
    end

    def self.held_icon_filename(item)
      item_data = self.try_get(item)
      return nil if !item_data
      name_base = (item_data.is_mail?) ? "mail" : "item"
      # Check for files
      ret = sprintf("Graphics/UI/Party/icon_%s_%s", name_base, item_data.id)
      return ret if pbResolveBitmap(ret)
      return sprintf("Graphics/UI/Party/icon_%s", name_base)
    end

    def self.mail_filename(item)
      item_data = self.try_get(item)
      return nil if !item_data
      # Check for files
      ret = sprintf("Graphics/UI/Mail/mail_%s", item_data.id)
      return pbResolveBitmap(ret) ? ret : nil
    end

    def initialize(hash)
      @id                       = hash[:id]
      @real_name                = hash[:real_name]        || "Unnamed"
      @real_name_plural         = hash[:real_name_plural] || "Unnamed"
      @real_portion_name        = hash[:real_portion_name]
      @real_portion_name_plural = hash[:real_portion_name_plural]
      @pocket                   = hash[:pocket]           || 1
      @price                    = hash[:price]            || 0
      @sell_price               = hash[:sell_price]       || (@price / 2)
      @bp_price                 = hash[:bp_price]         || 1
      @field_use                = hash[:field_use]        || 0
      @battle_use               = hash[:battle_use]       || 0
      @flags                    = hash[:flags]            || []
      @consumable               = hash[:consumable]
      @consumable               = !is_important? if @consumable.nil?
      @show_quantity            = hash[:show_quantity]
      @move                     = hash[:move]
      @real_description         = hash[:real_description] || "???"
      @pbs_file_suffix          = hash[:pbs_file_suffix]  || ""
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessageFromHash(MessageTypes::ITEM_NAMES, @real_name)
    end

    # @return [String] the translated plural version of the name of this item
    def name_plural
      return pbGetMessageFromHash(MessageTypes::ITEM_NAME_PLURALS, @real_name_plural)
    end

    # @return [String] the translated portion name of this item
    def portion_name
      return pbGetMessageFromHash(MessageTypes::ITEM_PORTION_NAMES, @real_portion_name) if @real_portion_name
      return name
    end

    # @return [String] the translated plural version of the portion name of this item
    def portion_name_plural
      return pbGetMessageFromHash(MessageTypes::ITEM_PORTION_NAME_PLURALS, @real_portion_name_plural) if @real_portion_name_plural
      return name_plural
    end

    # @return [String] the translated description of this item
    def description
      return pbGetMessageFromHash(MessageTypes::ITEM_DESCRIPTIONS, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def is_TM?;              return @field_use == 3; end
    def is_HM?;              return @field_use == 4; end
    def is_TR?;              return @field_use == 5; end
    def is_machine?;         return is_TM? || is_HM? || is_TR?; end
    def is_mail?;            return has_flag?("Mail") || has_flag?("IconMail"); end
    def is_icon_mail?;       return has_flag?("IconMail"); end
    def is_poke_ball?;       return has_flag?("PokeBall") || has_flag?("SnagBall"); end
    def is_snag_ball?;       return has_flag?("SnagBall") || (is_poke_ball? && $player.has_snag_machine); end
    def is_berry?;           return has_flag?("Berry"); end
    def is_key_item?;        return has_flag?("KeyItem"); end
    def is_evolution_stone?; return has_flag?("EvolutionStone"); end
    def is_fossil?;          return has_flag?("Fossil"); end
    def is_apricorn?;        return has_flag?("Apricorn"); end
    def is_gem?;             return has_flag?("TypeGem"); end
    def is_mulch?;           return has_flag?("Mulch"); end
    def is_mega_stone?;      return has_flag?("MegaStone"); end   # Does NOT include Red Orb/Blue Orb
    def is_scent?;           return has_flag?("Scent"); end

    def is_important?
      return true if is_key_item? || is_HM? || is_TM?
      return false
    end

    def can_hold?; return !is_important?; end

    def consumed_after_use?
      return !is_important? && @consumable
    end

    def show_quantity?
      return @show_quantity || !is_important?
    end

    def unlosable?(species, ability)
      return false if species == :ARCEUS && ability != :MULTITYPE
      return false if species == :SILVALLY && ability != :RKSSYSTEM
      combos = {
        :ARCEUS    => [:FISTPLATE,   :FIGHTINIUMZ,
                       :SKYPLATE,    :FLYINIUMZ,
                       :TOXICPLATE,  :POISONIUMZ,
                       :EARTHPLATE,  :GROUNDIUMZ,
                       :STONEPLATE,  :ROCKIUMZ,
                       :INSECTPLATE, :BUGINIUMZ,
                       :SPOOKYPLATE, :GHOSTIUMZ,
                       :IRONPLATE,   :STEELIUMZ,
                       :FLAMEPLATE,  :FIRIUMZ,
                       :SPLASHPLATE, :WATERIUMZ,
                       :MEADOWPLATE, :GRASSIUMZ,
                       :ZAPPLATE,    :ELECTRIUMZ,
                       :MINDPLATE,   :PSYCHIUMZ,
                       :ICICLEPLATE, :ICIUMZ,
                       :DRACOPLATE,  :DRAGONIUMZ,
                       :DREADPLATE,  :DARKINIUMZ,
                       :PIXIEPLATE,  :FAIRIUMZ],
        :SILVALLY  => [:FIGHTINGMEMORY,
                       :FLYINGMEMORY,
                       :POISONMEMORY,
                       :GROUNDMEMORY,
                       :ROCKMEMORY,
                       :BUGMEMORY,
                       :GHOSTMEMORY,
                       :STEELMEMORY,
                       :FIREMEMORY,
                       :WATERMEMORY,
                       :GRASSMEMORY,
                       :ELECTRICMEMORY,
                       :PSYCHICMEMORY,
                       :ICEMEMORY,
                       :DRAGONMEMORY,
                       :DARKMEMORY,
                       :FAIRYMEMORY],
        :GIRATINA  => [:GRISEOUSORB],
        :GENESECT  => [:BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE],
        :KYOGRE    => [:BLUEORB],
        :GROUDON   => [:REDORB],
        :ZACIAN    => [:RUSTEDSWORD],
        :ZAMAZENTA => [:RUSTEDSHIELD]
      }
      return combos[species]&.include?(@id)
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      key = "SectionName" if key == "ID"
      ret = __orig__get_property_for_PBS(key)
      case key
      when "SellPrice"
        ret = nil if ret == @price / 2
      when "BPPrice"
        ret = nil if ret == 1
      when "FieldUse", "BattleUse"
        ret = nil if ret == 0
      when "Consumable"
        ret = @consumable
        ret = nil if ret || is_important?   # Only return false, only for non-important items
      end
      return ret
    end
  end
end
