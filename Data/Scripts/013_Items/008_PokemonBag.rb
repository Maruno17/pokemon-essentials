#===============================================================================
# The Bag object, which actually contains all the items.
#===============================================================================
class PokemonBag
  attr_accessor :last_viewed_pocket
  attr_accessor :last_pocket_selections
  attr_reader   :registered_items
  attr_reader   :ready_menu_selection

  def self.pocket_names
    return Settings.bag_pocket_names
  end

  def self.pocket_count
    return self.pocket_names.length
  end

  def initialize
    @pockets              = []
    (0..PokemonBag.pocket_count).each { |i| @pockets[i] = [] }
    reset_last_selections
    @registered_items     = []
    @ready_menu_selection = [0, 0, 1]   # Used by the Ready Menu to remember cursor positions
  end

  def reset_last_selections
    @last_viewed_pocket     = 1
    @last_pocket_selections ||= []
    (0..PokemonBag.pocket_count).each { |i| @last_pocket_selections[i] = 0 }
  end

  def clear
    @pockets.each { |pocket| pocket.clear }
    (PokemonBag.pocket_count + 1).times { |i| @last_pocket_selections[i] = 0 }
  end

  def pockets
    rearrange
    return @pockets
  end

  #=============================================================================

  # Gets the index of the current selected item in the pocket
  def last_viewed_index(pocket)
    if pocket <= 0 || pocket > PokemonBag.pocket_count
      raise ArgumentError.new(_INTL("Invalid pocket: {1}", pocket.inspect))
    end
    rearrange
    return [@last_pocket_selections[pocket], @pockets[pocket].length].min || 0
  end

  # Sets the index of the current selected item in the pocket
  def set_last_viewed_index(pocket, value)
    if pocket <= 0 || pocket > PokemonBag.pocket_count
      raise ArgumentError.new(_INTL("Invalid pocket: {1}", pocket.inspect))
    end
    rearrange
    @last_pocket_selections[pocket] = value if value <= @pockets[pocket].length
  end

  #=============================================================================

  def quantity(item)
    item_data = GameData::Item.try_get(item)
    return 0 if !item_data
    pocket = item_data.pocket
    return ItemStorageHelper.quantity(@pockets[pocket], item_data.id)
  end

  def has?(item, qty = 1)
    return quantity(item) >= qty
  end
  alias can_remove? has?

  def can_add?(item, qty = 1)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    max_size = max_pocket_size(pocket)
    max_size = @pockets[pocket].length + 1 if max_size < 0   # Infinite size
    return ItemStorageHelper.can_add?(
      @pockets[pocket], max_size, Settings::BAG_MAX_PER_SLOT, item_data.id, qty
    )
  end

  def add(item, qty = 1)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    max_size = max_pocket_size(pocket)
    max_size = @pockets[pocket].length + 1 if max_size < 0   # Infinite size
    ret = ItemStorageHelper.add(@pockets[pocket],
                                max_size, Settings::BAG_MAX_PER_SLOT, item_data.id, qty)
    if ret && Settings::BAG_POCKET_AUTO_SORT[pocket - 1]
      @pockets[pocket].sort! { |a, b| GameData::Item.keys.index(a[0]) <=> GameData::Item.keys.index(b[0]) }
    end
    return ret
  end

  # Adds qty number of item. Doesn't add anything if it can't add all of them.
  def add_all(item, qty = 1)
    return false if !can_add?(item, qty)
    return add(item, qty)
  end

  # Deletes as many of item as possible (up to qty), and returns whether it
  # managed to delete qty of them.
  def remove(item, qty = 1)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    return ItemStorageHelper.remove(@pockets[pocket], item_data.id, qty)
  end

  # Deletes qty number of item. Doesn't delete anything if there are less than
  # qty of the item in the Bag.
  def remove_all(item, qty = 1)
    return false if !can_remove?(item, qty)
    return remove(item, qty)
  end

  # This only works if the old and new items are in the same pocket. Used for
  # switching on/off certain Key Items. Replaces all old_item in its pocket with
  # new_item.
  def replace_item(old_item, new_item)
    old_item_data = GameData::Item.try_get(old_item)
    new_item_data = GameData::Item.try_get(new_item)
    return false if !old_item_data || !new_item_data
    pocket = old_item_data.pocket
    old_id = old_item_data.id
    new_id = new_item_data.id
    ret = false
    @pockets[pocket].each do |item|
      next if !item || item[0] != old_id
      item[0] = new_id
      ret = true
    end
    return ret
  end

  #=============================================================================

  # Returns whether item has been registered for quick access in the Ready Menu.
  def registered?(item)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    return @registered_items.include?(item_data.id)
  end

  # Registers the item in the Ready Menu.
  def register(item)
    item_data = GameData::Item.try_get(item)
    return if !item_data
    @registered_items.push(item_data.id) if !@registered_items.include?(item_data.id)
  end

  # Unregisters the item from the Ready Menu.
  def unregister(item)
    item_data = GameData::Item.try_get(item)
    @registered_items.delete(item_data.id) if item_data
  end

  #=============================================================================

  private

  def max_pocket_size(pocket)
    return Settings::BAG_MAX_POCKET_SIZE[pocket - 1] || -1
  end

  def rearrange
    return if @pockets.length == PokemonBag.pocket_count + 1
    @last_viewed_pocket = 1
    new_pockets = []
    @last_pocket_selections = []
    (PokemonBag.pocket_count + 1).times do |i|
      new_pockets[i] = []
      @last_pocket_selections[i] = 0
    end
    @pockets.each do |pocket|
      next if !pocket
      pocket.each do |item|
        item_pocket = GameData::Item.get(item[0]).pocket
        new_pockets[item_pocket].push(item)
      end
    end
    new_pockets.each_with_index do |pocket, i|
      next if i == 0 || !Settings::BAG_POCKET_AUTO_SORT[i - 1]
      pocket.sort! { |a, b| GameData::Item.keys.index(a[0]) <=> GameData::Item.keys.index(b[0]) }
    end
    @pockets = new_pockets
  end
end



#===============================================================================
# The PC item storage object, which actually contains all the items
#===============================================================================
class PCItemStorage
  attr_reader :items

  MAX_SIZE     = 999   # Number of different slots in storage
  MAX_PER_SLOT = 999   # Max. number of items per slot

  def initialize
    @items = []
    # Start storage with initial items (e.g. a Potion)
    GameData::Metadata.get.start_item_storage.each do |item|
      add(item) if GameData::Item.exists?(item)
    end
  end

  def [](i)
    return @items[i]
  end

  def length
    return @items.length
  end

  def empty?
    return @items.length == 0
  end

  def clear
    @items.clear
  end

  # Unused
  def get_item(index)
    return (index < 0 || index >= @items.length) ? nil : @items[index][0]
  end

  # Number of the item in the given index
  # Unused
  def get_item_count(index)
    return (index < 0 || index >= @items.length) ? 0 : @items[index][1]
  end

  def quantity(item)
    item = GameData::Item.get(item).id
    return ItemStorageHelper.quantity(@items, item)
  end

  def can_add?(item, qty = 1)
    item = GameData::Item.get(item).id
    return ItemStorageHelper.can_add?(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
  end

  def add(item, qty = 1)
    item = GameData::Item.get(item).id
    return ItemStorageHelper.add(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
  end

  def remove(item, qty = 1)
    item = GameData::Item.get(item).id
    return ItemStorageHelper.remove(@items, item, qty)
  end
end



#===============================================================================
# Implements methods that act on arrays of items.  Each element in an item
# array is itself an array of [itemID, itemCount].
# Used by the Bag, PC item storage, and Triple Triad.
#===============================================================================
module ItemStorageHelper
  # Returns the quantity of item in items
  def self.quantity(items, item)
    ret = 0
    items.each { |i| ret += i[1] if i && i[0] == item }
    return ret
  end

  def self.can_add?(items, max_slots, max_per_slot, item, qty)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0
    max_slots.times do |i|
      item_slot = items[i]
      if !item_slot
        qty -= [qty, max_per_slot].min
        return true if qty == 0
      elsif item_slot[0] == item && item_slot[1] < max_per_slot
        new_amt = item_slot[1]
        new_amt = [new_amt + qty, max_per_slot].min
        qty -= (new_amt - item_slot[1])
        return true if qty == 0
      end
    end
    return false
  end

  def self.add(items, max_slots, max_per_slot, item, qty)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0
    max_slots.times do |i|
      item_slot = items[i]
      if !item_slot
        items[i] = [item, [qty, max_per_slot].min]
        qty -= items[i][1]
        return true if qty == 0
      elsif item_slot[0] == item && item_slot[1] < max_per_slot
        new_amt = item_slot[1]
        new_amt = [new_amt + qty, max_per_slot].min
        qty -= (new_amt - item_slot[1])
        item_slot[1] = new_amt
        return true if qty == 0
      end
    end
    return false
  end

  # Deletes an item (items array, max. size per slot, item, no. of items to delete)
  def self.remove(items, item, qty)
    raise "Invalid value for qty: #{qty}" if qty < 0
    return true if qty == 0
    ret = false
    items.each_with_index do |item_slot, i|
      next if !item_slot || item_slot[0] != item
      amount = [qty, item_slot[1]].min
      item_slot[1] -= amount
      qty -= amount
      items[i] = nil if item_slot[1] == 0
      next if qty > 0
      ret = true
      break
    end
    items.compact!
    return ret
  end
end



#===============================================================================
# Deprecated methods
#===============================================================================
class PokemonBag
  # @deprecated This method is slated to be removed in v21.
  def pbQuantity(item)
    Deprecation.warn_method("pbQuantity", "v21", "$bag.quantity(item)")
    return quantity(item)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbHasItem?(item)
    Deprecation.warn_method("pbHasItem?", "v21", "$bag.has?(item)")
    return has?(item)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbCanStore?(item, quantity = 1)
    Deprecation.warn_method("pbCanStore?", "v21", "$bag.can_add?(item, quantity)")
    return can_add?(item, quantity)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbStoreItem(item, quantity = 1)
    Deprecation.warn_method("pbStoreItem", "v21", "$bag.add(item, quantity)")
    return add(item, quantity)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbStoreAllOrNone(item, quantity = 1)
    Deprecation.warn_method("pbStoreAllOrNone", "v21", "$bag.add_all(item, quantity)")
    return add_all(item, quantity)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbChangeItem(old_item, new_item)
    Deprecation.warn_method("pbChangeItem", "v21", "$bag.replace_item(old_item, new_item)")
    return replace_item(old_item, new_item)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbDeleteItem(item, quantity = 1)
    Deprecation.warn_method("pbDeleteItem", "v21", "$bag.remove(item, quantity)")
    return remove(item, quantity)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbIsRegistered?(item)
    Deprecation.warn_method("pbIsRegistered?", "v21", "$bag.registered?(item)")
    return registered?(item)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbRegisterItem(item)
    Deprecation.warn_method("pbRegisterItem", "v21", "$bag.register(item)")
    register(item)
  end

  # @deprecated This method is slated to be removed in v21.
  def pbUnregisterItem(item)
    Deprecation.warn_method("pbUnregisterItem", "v21", "$bag.unregister(item)")
    unregister(item)
  end
end

# @deprecated This method is slated to be removed in v21.
def pbQuantity(item)
  Deprecation.warn_method("pbQuantity", "v21", "$bag.quantity(item)")
  return $bag.quantity(item)
end

# @deprecated This method is slated to be removed in v21.
def pbHasItem?(item)
  Deprecation.warn_method("pbHasItem?", "v21", "$bag.has?(item)")
  return $bag.has?(item)
end

# @deprecated This method is slated to be removed in v21.
def pbCanStore?(item, quantity = 1)
  Deprecation.warn_method("pbCanStore?", "v21", "$bag.can_add?(item, quantity)")
  return $bag.can_add?(item, quantity)
end

# @deprecated This method is slated to be removed in v21.
def pbStoreItem(item, quantity = 1)
  Deprecation.warn_method("pbStoreItem", "v21", "$bag.add(item, quantity)")
  return $bag.add(item, quantity)
end

# @deprecated This method is slated to be removed in v21.
def pbStoreAllOrNone(item, quantity = 1)
  Deprecation.warn_method("pbStoreAllOrNone", "v21", "$bag.add_all(item, quantity)")
  return $bag.add_all(item, quantity)
end
