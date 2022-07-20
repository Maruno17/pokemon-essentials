module GameData
  class Item
    attr_reader :id
    attr_reader :real_name
    attr_reader :real_name_plural
    attr_reader :pocket
    attr_reader :price
    attr_reader :sell_price
    attr_reader :real_description
    attr_reader :field_use
    attr_reader :battle_use
    attr_reader :consumable
    attr_reader :flags
    attr_reader :move

    DATA = {}
    DATA_FILENAME = "items.dat"

    SCHEMA = {
      "Name"        => [:name,        "s"],
      "NamePlural"  => [:name_plural, "s"],
      "Pocket"      => [:pocket,      "v"],
      "Price"       => [:price,       "u"],
      "SellPrice"   => [:sell_price,  "u"],
      "Description" => [:description, "q"],
      "FieldUse"    => [:field_use,   "e", { "OnPokemon" => 1, "Direct" => 2, "TM" => 3,
                                             "HM" => 4, "TR" => 5 }],
      "BattleUse"   => [:battle_use,  "e", { "OnPokemon" => 1, "OnMove" => 2, "OnBattler" => 3,
                                             "OnFoe" => 4, "Direct" => 5 }],
      "Consumable"  => [:consumable,  "b"],
      "Flags"       => [:flags,       "*s"],
      "Move"        => [:move,        "e", :Move]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

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
      ret = sprintf("Graphics/Pictures/Party/icon_%s_%s", name_base, item_data.id)
      return ret if pbResolveBitmap(ret)
      return sprintf("Graphics/Pictures/Party/icon_%s", name_base)
    end

    def self.mail_filename(item)
      item_data = self.try_get(item)
      return nil if !item_data
      # Check for files
      ret = sprintf("Graphics/Pictures/Mail/mail_%s", item_data.id)
      return pbResolveBitmap(ret) ? ret : nil
    end

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]        || "Unnamed"
      @real_name_plural = hash[:name_plural] || "Unnamed"
      @pocket           = hash[:pocket]      || 1
      @price            = hash[:price]       || 0
      @sell_price       = hash[:sell_price]  || (@price / 2)
      @real_description = hash[:description] || "???"
      @field_use        = hash[:field_use]   || 0
      @battle_use       = hash[:battle_use]  || 0
      @flags            = hash[:flags]       || []
      @consumable       = hash[:consumable]
      @consumable       = !is_important? if @consumable.nil?
      @move             = hash[:move]
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessageFromHash(MessageTypes::Items, @real_name)
    end

    # @return [String] the translated plural version of the name of this item
    def name_plural
      return pbGetMessageFromHash(MessageTypes::ItemPlurals, @real_name_plural)
    end

    # @return [String] the translated description of this item
    def description
      return pbGetMessageFromHash(MessageTypes::ItemDescriptions, @real_description)
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

    def can_hold?;           return !is_important?; end

    def consumed_after_use?
      return !is_important? && @consumable
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
  end
end
