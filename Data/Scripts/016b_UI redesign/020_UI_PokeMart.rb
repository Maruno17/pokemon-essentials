#===============================================================================
#
#===============================================================================
class UI::MartStockWrapper
  def initialize(stock)
    @stock = stock
    refresh
  end

  def length
    return @stock.length
  end

  def [](index)
    return @stock[index]
  end

  def buy_price(item)
    return 0 if item.nil?
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0] > 0
    end
    return GameData::Item.get(item).price
  end

  def buy_price_string(item)
    price = buy_price(item)
    return _INTL("${1}", price.to_s_formatted)
  end

  def sell_price(item)
    return 0 if item.nil?
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
    end
    return GameData::Item.get(item).sell_price
  end

  def refresh
    @stock.delete_if { |itm| GameData::Item.get(itm).is_important? && $bag.has?(itm) }
  end
end

#===============================================================================
# Pokémon Mart.
#===============================================================================
class UI::MartVisualsList < Window_DrawableCommand
  def initialize(stock, x, y, width, height, viewport = nil)
    @stock = stock
    super(x, y, width, height, viewport)
    @selarrow    = AnimatedBitmap.new(bag_folder + "cursor")
    @baseColor   = UI::MartVisuals::TEXT_COLOR_THEMES[:black][0]
    @shadowColor = UI::MartVisuals::TEXT_COLOR_THEMES[:black][1]
    self.windowskin = nil
  end

  #-----------------------------------------------------------------------------

  def itemCount
    return @stock.length + 1   # The extra 1 is the Cancel option
  end

  def bag_folder
    return UI::MartVisuals::UI_FOLDER + UI::MartVisuals::GRAPHICS_FOLDER
  end

  def item_id
    return (self.index >= @stock.length) ? nil : @stock[self.index]
  end

  def expensive_base_color=(value)
    @expensive_base_color = value
  end

  def expensive_shadow_color=(value)
    @expensive_shadow_color = value
  end

  def expensive?(this_item)
    return @stock.buy_price(this_item) > $player.money
  end

  #-----------------------------------------------------------------------------

  # This draws all the visible options first, and then draws the cursor.
  def refresh
    @item_max = itemCount
    update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    this_item = @stock[index]
    if this_item
      # Draw item name
      item_name = GameData::Item.get(this_item).display_name
      textpos.push([item_name, rect.x, ypos + 2, :left, self.baseColor, self.shadowColor])
      # Draw item price
      price = @stock.buy_price_string(this_item)
      price_width = self.contents.text_size(price).width
      price_x = rect.x + rect.width - price_width - 2 - 16
      expensive = expensive?(this_item)
      price_base_color = (expensive) ? @expensive_base_color || self.baseColor : self.baseColor
      price_shadow_color = (expensive) ? @expensive_shadow_color || self.shadowColor : self.shadowColor
      textpos.push([price, price_x, ypos + 2, :left, price_base_color, price_shadow_color])
    else
      textpos.push([_INTL("CANCEL"), rect.x, ypos + 2, :left, self.baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class UI::MartVisuals < UI::BaseVisuals
  attr_reader :sprites
  attr_reader :pocket

  GRAPHICS_FOLDER   = "Mart/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default   => [Color.new(248, 248, 248), Color.new(56, 56, 56)],   # Base and shadow colour
    :white     => [Color.new(248, 248, 248), Color.new(56, 56, 56)],
    :black     => [Color.new(88, 88, 80), Color.new(168, 184, 184)],
    :expensive => [Color.new(224, 0, 0), Color.new(248, 144, 144)]
  }
  ITEMS_VISIBLE = 7

  def initialize(stock, bag)
    @stock = stock
    @bag = bag
    super()
  end

  def initialize_sprites
    initialize_item_list
    initialize_item_sprites
    initialize_money_window
    initialize_bag_quantity_window
  end

  def initialize_item_list
    @sprites[:item_list] = UI::MartVisualsList.new(@stock, 152, 10, 374, 38 + (ITEMS_VISIBLE * 32), @viewport)
    @sprites[:item_list].expensive_base_color   = TEXT_COLOR_THEMES[:expensive][0]
    @sprites[:item_list].expensive_shadow_color = TEXT_COLOR_THEMES[:expensive][1]
    @sprites[:item_list].active                 = false
  end

  def initialize_item_sprites
    # Selected item's icon
    @sprites[:item_icon] = ItemIconSprite.new(48, Graphics.height - 48, nil, @viewport)
    # Selected item's description text box
    @sprites[:item_description] = Window_UnformattedTextPokemon.newWithSize(
      "", 80, 272, Graphics.width - 98, 128, @viewport
    )
    @sprites[:item_description].baseColor   = TEXT_COLOR_THEMES[:white][0]
    @sprites[:item_description].shadowColor = TEXT_COLOR_THEMES[:white][1]
    @sprites[:item_description].visible     = true
    @sprites[:item_description].windowskin  = nil
  end

  def initialize_money_window
    @sprites[:money_window] = Window_AdvancedTextPokemon.newWithSize("", 0, 0, 162, 96, @viewport)
    @sprites[:money_window].setSkin("Graphics/Windowskins/goldskin")
    @sprites[:money_window].baseColor      = TEXT_COLOR_THEMES[:black][0]
    @sprites[:money_window].shadowColor    = TEXT_COLOR_THEMES[:black][1]
    @sprites[:money_window].letterbyletter = false
    @sprites[:money_window].visible        = true
  end

  def initialize_bag_quantity_window
    @sprites[:bag_quantity_window] = Window_AdvancedTextPokemon.newWithSize(
      _INTL("In Bag:<r>{1}", @bag.quantity(item)), 0, 0, 162, 64, @viewport
    )
    @sprites[:bag_quantity_window].setSkin("Graphics/Windowskins/goldskin")
    @sprites[:bag_quantity_window].baseColor      = TEXT_COLOR_THEMES[:black][0]
    @sprites[:bag_quantity_window].shadowColor    = TEXT_COLOR_THEMES[:black][1]
    @sprites[:bag_quantity_window].letterbyletter = false
    @sprites[:bag_quantity_window].visible        = true
    @sprites[:bag_quantity_window].y              = Graphics.height - 102 - @sprites[:bag_quantity_window].height
  end

  #-----------------------------------------------------------------------------

  def index
    return @sprites[:item_list].index
  end

  def set_index(value)
    @sprites[:item_list].index = value
    refresh_on_index_changed(nil)
  end

  def item
    return @sprites[:item_list].item_id
  end

  def show_money_window
    @sprites[:money_window].visible = true
  end

  def hide_money_window
    @sprites[:money_window].visible = false
  end

  def show_bag_quantity_window
    @sprites[:bag_quantity_window].visible = true
  end

  def hide_bag_quantity_window
    @sprites[:bag_quantity_window].visible = false
  end

  #-----------------------------------------------------------------------------

  def refresh
    refresh_item_list
    refresh_selected_item
    refresh_money_window
  end

  def refresh_item_list
    @sprites[:item_list].refresh
  end

  def refresh_selected_item
    selected_item = item
    # Set the selected item's icon
    @sprites[:item_icon].item = selected_item
    # Set the selected item's description
    if selected_item
      @sprites[:item_description].text = GameData::Item.get(selected_item).description
    else
      @sprites[:item_description].text = _INTL("Quit shopping.")
    end
    refresh_bag_quantity_window
  end

  def refresh_bag_quantity_window
    @sprites[:bag_quantity_window].text = _INTL("In Bag:<r>{1}", @bag.quantity(item))
    (item) ? show_bag_quantity_window : hide_bag_quantity_window
  end

  def refresh_money_window
    @sprites[:money_window].text = _INTL("Money:\n<r>${1}", $player.money.to_s_formatted)
  end

  def refresh_on_index_changed(old_index)
    refresh_selected_item
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      if item
        pbPlayDecisionSE
        return :interact
      end
      pbPlayCloseMenuSE
      return :quit
    when Input::BACK
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  def navigate
    @sprites[:item_list].active = true
    ret = super
    @sprites[:item_list].active = false
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class UI::Mart < UI::BaseScreen
  attr_reader :stock, :bag

  SCREEN_ID = :mart_screen

  def initialize(stock, bag)
    pbScrollMap(6, 5, 5)   # Direction 6 (right), 5 tiles, speed 5 (cycling speed, 10 tiles/second)
    @bag = bag
    initialize_stock(stock)
    super()
  end

  def initialize_stock(stock)
    @stock = UI::MartStockWrapper.new(stock)
  end

  def initialize_visuals
    @visuals = UI::MartVisuals.new(@stock, @bag)
  end

  def start_screen
    pbSEPlay("GUI menu open")
  end

  def end_screen
    return if @disposed
    pbPlayCloseMenuSE
    silent_end_screen
    pbScrollMap(4, 5, 5)   # Direction 4 (left), 5 tiles, speed 5 (cycling speed, 10 tiles/second)
  end

  #-----------------------------------------------------------------------------

  def item
    return nil if @visuals.item.nil?
    return GameData::Item.get(@visuals.item)
  end
end

#===============================================================================
#
#===============================================================================
UIActionHandlers.add(UI::Mart::SCREEN_ID, :interact, {
  :effect => proc { |screen|
    item = screen.item
    item_price = screen.stock.buy_price(item)
    # Check affordability
    if $player.money < item_price
      screen.show_message(_INTL("You don't have enough money."))
      next
    end
    # Choose how many of the item to buy
    quantity = 0
    if item.is_important?
      quantity = 1
      next if !screen.show_confirm_message(
        _INTL("So you want the {1}?\nIt'll be ${2}. All right?",
              item.portion_name, item_price.to_s_formatted)
      )
    else
      max_quantity = (item_price <= 0) ? PokemonBag::MAX_PER_SLOT : $player.money / item_price
      max_quantity = [max_quantity, PokemonBag::MAX_PER_SLOT].min
      quantity = screen.choose_number_as_money_multiplier(
        _INTL("How many {1} would you like?", item.portion_name_plural), item_price, max_quantity
      )
      next if quantity == 0
      item_price *= quantity
      if quantity > 1
        next if !screen.show_confirm_message(
          _INTL("So you want {1} {2}?\nThey'll be ${3}. All right?",
                quantity, item.portion_name_plural, item_price.to_s_formatted)
        )
      elsif quantity > 0
        next if !screen.show_confirm_message(
          _INTL("So you want {1} {2}?\nIt'll be ${3}. All right?",
                quantity, item.portion_name, item_price.to_s_formatted)
        )
      end
    end
    # Check affordability (should always be possible, but just make sure)
    if $player.money < item_price
      screen.show_message(_INTL("You don't have enough money."))
      next
    end
    # Check the item can be put in the Bag
    if !screen.bag.can_add?(item.id, quantity)
      screen.show_message(_INTL("You have no room in your Bag."))
      next
    end
    # Add the bought item(s)
    screen.bag.add(item.id, quantity)
    $stats.money_spent_at_marts += item_price
    $stats.mart_items_bought += quantity
    $player.money -= item_price
    screen.stock.refresh
    screen.refresh
    screen.show_message(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
    # Give bonus Premier Ball(s)
    if quantity >= 10 && item.is_poke_ball? && GameData::Item.exists?(:PREMIERBALL)
      if Settings::MORE_BONUS_PREMIER_BALLS || item.id == :POKEBALL
        premier_balls_earned = (Settings::MORE_BONUS_PREMIER_BALLS) ? (quantity / 10) : 1
        premier_balls_added = 0
        premier_balls_earned.times do
          break if !screen.bag.add(:PREMIERBALL)
          premier_balls_added += 1
        end
        if premier_balls_added > 0
          $stats.premier_balls_earned += premier_balls_added
          if premier_balls_added > 1
            ball_name = GameData::Item.get(:PREMIERBALL).portion_name_plural
          else
            ball_name = GameData::Item.get(:PREMIERBALL).portion_name
          end
          screen.show_message(_INTL("And have {1} {2} on the house!", premier_balls_added, ball_name))
        end
      end
    end
  }
})

#===============================================================================
#
#===============================================================================
class UI::BagSellVisuals < UI::BagVisuals
  def initialize(bag, stock, mode = :choose_item)
    @stock = stock
    super(bag, mode: mode)
  end

  def initialize_sprites
    super
    @sprites[:money_window] = Window_AdvancedTextPokemon.newWithSize("", 0, 36, 184, 96, @viewport)
    @sprites[:money_window].setSkin("Graphics/Windowskins/goldskin")
    @sprites[:money_window].z              = 2000
    @sprites[:money_window].baseColor      = TEXT_COLOR_THEMES[:black][0]
    @sprites[:money_window].shadowColor    = TEXT_COLOR_THEMES[:black][1]
    @sprites[:money_window].letterbyletter = false
    @sprites[:money_window].visible        = true
    @sprites[:unit_price_window] = Window_AdvancedTextPokemon.newWithSize("", 0, 184, 184, 96, @viewport)
    @sprites[:unit_price_window].setSkin("Graphics/Windowskins/goldskin")
    @sprites[:unit_price_window].z              = 2000
    @sprites[:unit_price_window].baseColor      = TEXT_COLOR_THEMES[:black][0]
    @sprites[:unit_price_window].shadowColor    = TEXT_COLOR_THEMES[:black][1]
    @sprites[:unit_price_window].letterbyletter = false
    @sprites[:unit_price_window].visible        = true
  end

  def refresh
    super
    @sprites[:money_window].text = _INTL("Money:\n<r>${1}", $player.money.to_s_formatted)
    refresh_unit_price_window
  end

  def refresh_input_indicators; end

  def refresh_unit_price_window
    @sprites[:unit_price_window].visible = (!item.nil?)
    return if item.nil?
    price = @stock.sell_price(item)
    if GameData::Item.get(item).is_important? || price == 0
      @sprites[:unit_price_window].text = _INTL("You can't sell this item.")
    else
      @sprites[:unit_price_window].text = _INTL("Price each:\n<r>${1}", price.to_s_formatted)
    end
  end

  def refresh_on_index_changed(old_index)
    refresh_unit_price_window
  end
end

#===============================================================================
#
#===============================================================================
class UI::BagSell < UI::Bag
  def initialize(bag, mode: :choose_item)
    @stock = UI::MartStockWrapper.new([])
    super(bag, mode: mode)
  end

  def initialize_visuals
    @visuals = UI::BagSellVisuals.new(@bag, @stock, mode: @mode)
  end

  def sell_items
    choose_item do |item|
      item_data = GameData::Item.get(item)
      item_name        = item_data.portion_name
      item_name_plural = item_data.portion_name_plural
      price = @stock.sell_price(item)
      # Ensure item can be sold
      if item_data.is_important? || price == 0
        show_message(_INTL("Oh, no. I can't buy {1}.", item_name_plural))
        next
      end
      # Choose a quantity of the item to sell
      quantity = @bag.quantity(item)
      if quantity > 1
        quantity = choose_number_as_money_multiplier(
          _INTL("How many {1} would you like to sell?", item_name_plural), price, quantity
        )
      end
      next if quantity == 0
      # Sell the item(s)
      price *= quantity
      if show_confirm_message(_INTL("I can pay ${1}.\nWould that be OK?", price.to_s_formatted))
        @bag.remove(item, quantity)
        old_money = $player.money
        $player.money += price
        $stats.money_earned_at_marts += $player.money - old_money
        refresh
        sold_item_name = (quantity > 1) ? item_name_plural : item_name
        show_message(_INTL("You turned over the {1} and got ${2}.",
                           sold_item_name, price.to_s_formatted)) { pbSEPlay("Mart buy item") }
      end
      next false
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPokemonMart(stock, speech = nil, cannot_sell = false)
  commands = {}
  commands[:buy]    = _INTL("I'm here to buy")
  commands[:sell]   = _INTL("I'm here to sell") if !cannot_sell
  commands[:cancel] = _INTL("No, thanks")
  cmd = pbMessage(speech || _INTL("Welcome! How may I help you?"), commands.values, commands.length)
  loop do
    case commands.keys[cmd]
    when :buy
      UI::Mart.new(stock, $bag).main
    when :sell
      pbFadeOutIn { UI::BagSell.new($bag).sell_items }
    else
      pbMessage(_INTL("Do come again!"))
      break
    end
    cmd = pbMessage(_INTL("Is there anything else I can do for you?"), commands.values, commands.length, nil, cmd)
  end
  $game_temp.clear_mart_prices
end
