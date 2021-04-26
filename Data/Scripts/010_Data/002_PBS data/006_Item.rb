module GameData
  class Item
    attr_reader :id
    attr_reader :id_number
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

    extend ClassMethods
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
      @id_number        = hash[:id_number]   || -1
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
      return pbGetMessage(MessageTypes::Items, @id_number)
    end

    # @return [String] the translated plural version of the name of this item
    def name_plural
      return pbGetMessage(MessageTypes::ItemPlurals, @id_number)
    end

    # @return [String] the translated description of this item
    def description
      return pbGetMessage(MessageTypes::ItemDescriptions, @id_number)
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

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetPocket(item)
  Deprecation.warn_method('pbGetPocket', 'v20', 'GameData::Item.get(item).pocket')
  return GameData::Item.get(item).pocket
end

# @deprecated This alias is slated to be removed in v20.
def pbGetPrice(item)
  Deprecation.warn_method('pbGetPrice', 'v20', 'GameData::Item.get(item).price')
  return GameData::Item.get(item).price
end

# @deprecated This alias is slated to be removed in v20.
def pbGetMachine(item)
  Deprecation.warn_method('pbGetMachine', 'v20', 'GameData::Item.get(item).move')
  return GameData::Item.get(item).move
end

# @deprecated This alias is slated to be removed in v20.
def pbIsTechnicalMachine?(item)
  Deprecation.warn_method('pbIsTechnicalMachine?', 'v20', 'GameData::Item.get(item).is_TM?')
  return GameData::Item.get(item).is_TM?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsHiddenMachine?(item)
  Deprecation.warn_method('pbIsHiddenMachine?', 'v20', 'GameData::Item.get(item).is_HM?')
  return GameData::Item.get(item).is_HM?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsMachine?(item)
  Deprecation.warn_method('pbIsMachine?', 'v20', 'GameData::Item.get(item).is_machine?')
  return GameData::Item.get(item).is_machine?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsMail?(item)
  Deprecation.warn_method('pbIsMail?', 'v20', 'GameData::Item.get(item).is_mail?')
  return GameData::Item.get(item).is_mail?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsMailWithPokemonIcons?(item)
  Deprecation.warn_method('pbIsMailWithPokemonIcons?', 'v20', 'GameData::Item.get(item).is_icon_mail?')
  return GameData::Item.get(item).is_icon_mail?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsPokeBall?(item)
  Deprecation.warn_method('pbIsPokeBall?', 'v20', 'GameData::Item.get(item).is_poke_ball?')
  return GameData::Item.get(item).is_poke_ball?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsSnagBall?(item)
  Deprecation.warn_method('pbIsSnagBall?', 'v20', 'GameData::Item.get(item).is_snag_ball?')
  return GameData::Item.get(item).is_snag_ball?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsBerry?(item)
  Deprecation.warn_method('pbIsBerry?', 'v20', 'GameData::Item.get(item).is_berry?')
  return GameData::Item.get(item).is_berry?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsKeyItem?(item)
  Deprecation.warn_method('pbIsKeyItem?', 'v20', 'GameData::Item.get(item).is_key_item?')
  return GameData::Item.get(item).is_key_item?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsEvolutionStone?(item)
  Deprecation.warn_method('pbIsEvolutionStone?', 'v20', 'GameData::Item.get(item).is_evolution_stone?')
  return GameData::Item.get(item).is_evolution_stone?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsFossil?(item)
  Deprecation.warn_method('pbIsFossil?', 'v20', 'GameData::Item.get(item).is_fossil?')
  return GameData::Item.get(item).is_fossil?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsApricorn?(item)
  Deprecation.warn_method('pbIsApricorn?', 'v20', 'GameData::Item.get(item).is_apricorn?')
  return GameData::Item.get(item).is_apricorn?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsGem?(item)
  Deprecation.warn_method('pbIsGem?', 'v20', 'GameData::Item.get(item).is_gem?')
  return GameData::Item.get(item).is_gem?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsMulch?(item)
  Deprecation.warn_method('pbIsMulch?', 'v20', 'GameData::Item.get(item).is_mulch?')
  return GameData::Item.get(item).is_mulch?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsMegaStone?(item)
  Deprecation.warn_method('pbIsMegaStone?', 'v20', 'GameData::Item.get(item).is_mega_stone?')
  return GameData::Item.get(item).is_mega_stone?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsImportantItem?(item)
  Deprecation.warn_method('pbIsImportantItem?', 'v20', 'GameData::Item.get(item).is_important?')
  return GameData::Item.get(item).is_important?
end

# @deprecated This alias is slated to be removed in v20.
def pbCanHoldItem?(item)
  Deprecation.warn_method('pbCanHoldItem?', 'v20', 'GameData::Item.get(item).can_hold?')
  return GameData::Item.get(item).can_hold?
end

# @deprecated This alias is slated to be removed in v20.
def pbIsUnlosableItem?(check_item, species, ability)
  Deprecation.warn_method('pbIsUnlosableItem?', 'v20', 'GameData::Item.get(item).unlosable?')
  return GameData::Item.get(check_item).unlosable?(species, ability)
end

# @deprecated This alias is slated to be removed in v20.
def pbItemIconFile(item)
  Deprecation.warn_method('pbItemIconFile', 'v20', 'GameData::Item.icon_filename(item)')
  return GameData::Item.icon_filename(item)
end

# @deprecated This alias is slated to be removed in v20.
def pbHeldItemIconFile(item)
  Deprecation.warn_method('pbHeldItemIconFile', 'v20', 'GameData::Item.held_icon_filename(item)')
  return GameData::Item.held_icon_filename(item)
end

# @deprecated This alias is slated to be removed in v20.
def pbMailBackFile(item)
  Deprecation.warn_method('pbMailBackFile', 'v20', 'GameData::Item.mail_filename(item)')
  return GameData::Item.mail_filename(item)
end
