#===============================================================================
#
#===============================================================================
module GameData
  class BagPocket
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this pocket's icon is within icon_pocket.png
    attr_reader :order
    attr_reader :max_slots
    attr_reader :auto_sort

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def self.all_pockets
      ret = []
      DATA.each_value { |pocket| ret.push([pocket.bag_pocket]) }
      ret.uniq!
      ret.each { |data| data.push(self.get(data[0]).order) }
      ret.sort_by! { |pckt| pckt[1] }
      ret.map! { |pckt| pckt[0] }
      return ret
    end

    def self.index(pocket)
      return self.all_pockets.index(pocket)
    end

    # @param other [Symbol, self, String]
    # @return [self]
    def self.get(other)
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = self.all_pockets[other - 1] if other.is_a?(Integer)
      other = other.to_sym if other.is_a?(String)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    # @param other [Symbol, self, String]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = self.all_pockets[other - 1] if other.is_a?(Integer)
      other = other.to_sym if other.is_a?(String)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || "Unnamed"
      @icon_position = hash[:icon_position] || 0
      @order         = hash[:order]         || 999
      @max_slots     = hash[:max_slots]     || -1
      @auto_sort     = hash[:auto_sort]     || false
      @parent_pocket = hash[:parent_pocket]
    end

    # @return [String] the translated name of this nature
    def name
      return _INTL(@real_name)
    end

    def bag_pocket
      return @parent_pocket || @id
    end
  end
end

#===============================================================================
# NOTE: If :parent_pocket is defined for a BagPocket below, that parent pocket
#       is assumed to be one that appears in the Bag. They don't chain.
#       i.e. You can't give "MegaStones" a :parent_pocket of "HeldItems", and
#       "HeldItems" a :parent_pocket of "Items" (where "Items" is the only one
#       of these pockets that appears in the Bag). Both "MegaStones" and
#       "HeldItems" should have a :parent_pocket of "Items".
#===============================================================================

GameData::BagPocket.register({
  :id            => :Items,
  :name          => _INTL("Other Items"),
  :icon_position => 0,
  :order         => 10
})

GameData::BagPocket.register({
  :id            => :Mail,
  :parent_pocket => :Items
})

GameData::BagPocket.register({
  :id            => :Medicine,
  :name          => _INTL("Medicine"),
  :icon_position => 1,
  :order         => 20
})

GameData::BagPocket.register({
  :id            => :PokeBalls,
  :name          => _INTL("Poké Balls"),
  :icon_position => 2,
  :order         => 30
})

GameData::BagPocket.register({
  :id            => :Berries,
  :name          => _INTL("Berries"),
  :icon_position => 3,
  :order         => 40,
  :auto_sort     => true
})

GameData::BagPocket.register({
  :id            => :HeldItems,
  :name          => _INTL("Held Items"),
  :icon_position => 4,
  :order         => 50
})

GameData::BagPocket.register({
  :id            => :MegaStones,
  :parent_pocket => :HeldItems
})

GameData::BagPocket.register({
  :id            => :BattleItems,
  :name          => _INTL("Battle Items"),
  :icon_position => 5,
  :order         => 60
})

# This pocket is hardcoded to allow showing the details of a machine item in
# this pocket in the Bag. The display of this information is toggled by pressing
# the Action input. It is not possible to open the screen menu with the Action
# input in this pocket (although you also can't open it if the pocket auto-sorts
# so that's not a problem).
GameData::BagPocket.register({
  :id            => :Machines,
  :name          => _INTL("TMs & HMs"),
  :icon_position => 6,
  :order         => 70,
  :auto_sort     => true
})

GameData::BagPocket.register({
  :id            => :KeyItems,
  :name          => _INTL("Key Items"),
  :icon_position => 7,
  :order         => 80
})
