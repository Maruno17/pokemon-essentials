module GameData
  class Item
    attr_reader :id
    attr_reader :real_name
    attr_reader :real_name_plural
    attr_reader :pocket
    attr_reader :price
    attr_reader :real_description
    attr_reader :field_use
    attr_reader :battle_use
    attr_reader :type
    attr_reader :move

    DATA = {}
    DATA_FILENAME = "items.dat"

    SCHEMA = {
      "Name"        => [:name,        "s"],
      "NamePlural"  => [:name_plural, "s"],
      "Pocket"      => [:pocket,      "v"],
      "Price"       => [:price,       "u"],
      "Description" => [:description, "q"],
      "FieldUse"    => [:field_use,   "e", {"OnPokemon" => 1, "Direct" => 2, "TM" => 3,
                                            "HM" => 4, "OnPokemonReusable" => 5, "TR" => 6}],
      "BattleUse"   => [:battle_use,  "e", {"OnPokemon" => 1, "OnMove" => 2, "OnBattler" => 3,
                                            "OnFoe" => 4, "Direct" => 5, "OnPokemonReusable" => 6,
                                            "OnMoveReusable" => 7, "OnBattlerReusable" => 8,
                                            "OnFoeReusable" => 9, "DirectReusable" => 10}],
      "Type"        => [:type,        "e", {"Mail" => 1, "IconMail" => 2, "SnagBall" => 3,
                                            "PokeBall" => 4, "Berry" => 5, "KeyItem" => 6,
                                            "EvolutionStone" => 7, "Fossil" => 8, "Apricorn" => 9,
                                            "TypeGem" => 10, "Mulch" => 11, "MegaStone" => 12}],
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
      @real_description = hash[:description] || "???"
      @field_use        = hash[:field_use]   || 0
      @battle_use       = hash[:battle_use]  || 0
      @type             = hash[:type]        || 0
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

    def is_TM?;              return @field_use == 3; end
    def is_HM?;              return @field_use == 4; end
    def is_TR?;              return @field_use == 6; end
    def is_machine?;         return is_TM? || is_HM? || is_TR?; end
    def is_mail?;            return @type == 1 || @type == 2; end
    def is_icon_mail?;       return @type == 2; end
    def is_poke_ball?;       return @type == 3 || @type == 4; end
    def is_snag_ball?;       return @type == 3 || (@type == 4 && $Trainer.has_snag_machine); end
    def is_berry?;           return @type == 5; end
    def is_key_item?;        return @type == 6; end
    def is_evolution_stone?; return @type == 7; end
    def is_fossil?;          return @type == 8; end
    def is_apricorn?;        return @type == 9; end
    def is_gem?;             return @type == 10; end
    def is_mulch?;           return @type == 11; end
    def is_mega_stone?;      return @type == 12; end   # Does NOT include Red Orb/Blue Orb

    def is_important?
      return true if is_key_item? || is_HM? || is_TM?
      return false
    end

    def can_hold?;           return !is_important?; end

    def unlosable?(species, ability)
      return false if species == :ARCEUS && ability != :MULTITYPE
      return false if species == :SILVALLY && ability != :RKSSYSTEM
      combos = {
         :ARCEUS   => [:FISTPLATE,   :FIGHTINIUMZ,
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
         :SILVALLY => [:FIGHTINGMEMORY,
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
         :GIRATINA => [:GRISEOUSORB],
         :GENESECT => [:BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE],
         :KYOGRE   => [:BLUEORB],
         :GROUDON  => [:REDORB]
      }
      return combos[species] && combos[species].include?(@id)
    end
  end
end
