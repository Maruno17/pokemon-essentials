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
    def is_machine?;         return is_TM? || is_HM?; end
    def is_mail?;            return @type == 1 || @type == 2; end
    def is_icon_mail?;       return @type == 2; end
    def is_poke_ball?;       return @type == 3 || @type == 4; end
    def is_snag_ball?;       return @type == 3 || (@type == 4 && $PokemonGlobal.snagMachine); end
    def is_berry?;           return @type == 5; end
    def is_key_item?;        return @type == 6; end
    def is_evolution_stone?; return @type == 7; end
    def is_fossil?;          return @type == 8; end
    def is_apricorn?;        return @type == 9; end
    def is_gem?;             return @type == 10; end
    def is_mulch?;           return @type == 11; end
    def is_mega_stone?;      return @type == 12; end   # Does NOT include Red Orb/Blue Orb

    def is_important?
      return true if is_key_item? || is_HM?
      return true if is_TM? && INFINITE_TMS
      return false
    end

    def can_hold?;           return !is_important?; end

    def unlosable?(species, ability)
      return false if isConst?(species, PBSpecies, :ARCEUS) && ability != :MULTITYPE
      return false if isConst?(species, PBSpecies, :SILVALLY) && ability != :RKSSYSTEM
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
      combos.each do |comboSpecies, items|
        next if !isConst?(species, PBSpecies, comboSpecies)
        return items.include?(@id)
      end
      return false
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
def pbGetPocket(item)
  Deprecation.warn_method('pbGetPocket', 'v20', 'GameData::Item.get(item).pocket')
  return GameData::Item.get(item).pocket
end

def pbGetPrice(item)
  Deprecation.warn_method('pbGetPrice', 'v20', 'GameData::Item.get(item).price')
  return GameData::Item.get(item).price
end

def pbGetMachine(item)
  Deprecation.warn_method('pbGetMachine', 'v20', 'GameData::Item.get(item).move')
  return GameData::Item.get(item).move
end

def pbIsTechnicalMachine?(item)
  Deprecation.warn_method('pbIsTechnicalMachine?', 'v20', 'GameData::Item.get(item).is_TM?')
  return GameData::Item.get(item).is_TM?
end

def pbIsHiddenMachine?(item)
  Deprecation.warn_method('pbIsHiddenMachine?', 'v20', 'GameData::Item.get(item).is_HM?')
  return GameData::Item.get(item).is_HM?
end

def pbIsMachine?(item)
  Deprecation.warn_method('pbIsMachine?', 'v20', 'GameData::Item.get(item).is_machine?')
  return GameData::Item.get(item).is_machine?
end

def pbIsMail?(item)
  Deprecation.warn_method('pbIsMail?', 'v20', 'GameData::Item.get(item).is_mail?')
  return GameData::Item.get(item).is_mail?
end

def pbIsMailWithPokemonIcons?(item)
  Deprecation.warn_method('pbIsMailWithPokemonIcons?', 'v20', 'GameData::Item.get(item).is_icon_mail?')
  return GameData::Item.get(item).is_icon_mail?
end

def pbIsPokeBall?(item)
  Deprecation.warn_method('pbIsPokeBall?', 'v20', 'GameData::Item.get(item).is_poke_ball?')
  return GameData::Item.get(item).is_poke_ball?
end

def pbIsSnagBall?(item)
  Deprecation.warn_method('pbIsSnagBall?', 'v20', 'GameData::Item.get(item).is_snag_ball?')
  return GameData::Item.get(item).is_snag_ball?
end

def pbIsBerry?(item)
  Deprecation.warn_method('pbIsBerry?', 'v20', 'GameData::Item.get(item).is_berry?')
  return GameData::Item.get(item).is_berry?
end

def pbIsKeyItem?(item)
  Deprecation.warn_method('pbIsKeyItem?', 'v20', 'GameData::Item.get(item).is_key_item?')
  return GameData::Item.get(item).is_key_item?
end

def pbIsEvolutionStone?(item)
  Deprecation.warn_method('pbIsEvolutionStone?', 'v20', 'GameData::Item.get(item).is_evolution_stone?')
  return GameData::Item.get(item).is_evolution_stone?
end

def pbIsFossil?(item)
  Deprecation.warn_method('pbIsFossil?', 'v20', 'GameData::Item.get(item).is_fossil?')
  return GameData::Item.get(item).is_fossil?
end

def pbIsApricorn?(item)
  Deprecation.warn_method('pbIsApricorn?', 'v20', 'GameData::Item.get(item).is_apricorn?')
  return GameData::Item.get(item).is_apricorn?
end

def pbIsGem?(item)
  Deprecation.warn_method('pbIsGem?', 'v20', 'GameData::Item.get(item).is_gem?')
  return GameData::Item.get(item).is_gem?
end

def pbIsMulch?(item)
  Deprecation.warn_method('pbIsMulch?', 'v20', 'GameData::Item.get(item).is_mulch?')
  return GameData::Item.get(item).is_mulch?
end

def pbIsMegaStone?(item)
  Deprecation.warn_method('pbIsMegaStone?', 'v20', 'GameData::Item.get(item).is_mega_stone?')
  return GameData::Item.get(item).is_mega_stone?
end

def pbIsImportantItem?(item)
  Deprecation.warn_method('pbIsImportantItem?', 'v20', 'GameData::Item.get(item).is_important?')
  return GameData::Item.get(item).is_important?
end

def pbCanHoldItem?(item)
  Deprecation.warn_method('pbCanHoldItem?', 'v20', 'GameData::Item.get(item).can_hold?')
  return GameData::Item.get(item).can_hold?
end

def pbIsUnlosableItem?(check_item, species, ability)
  Deprecation.warn_method('pbIsUnlosableItem?', 'v20', 'GameData::Item.get(item).unlosable?')
  return GameData::Item.get(check_item).unlosable?(species, ability)
end
