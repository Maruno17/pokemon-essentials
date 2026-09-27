#===============================================================================
#
#===============================================================================
class UI::BPShopStockWrapper < UI::MartStockWrapper
  def money
    return $player.battle_points
  end

  def buy_price(item)
    return 0 if item.nil?
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0] > 0
    end
    return GameData::Item.get(item).bp_price
  end

  def buy_price_string(item)
    price = buy_price(item)
    return _INTL("{1} BP", price.to_s_formatted)
  end
end

#===============================================================================
#
#===============================================================================
class UI::BPShopVisuals < UI::MartVisuals
  def initialize_item_list
    @sprites[:item_list] = UI::MartVisualsList.new(@stock, 152, 10, 374, 38 + (ITEMS_VISIBLE * 32), self, @viewport)
    @sprites[:item_list].expensive_base_color   = get_text_color_theme(:expensive)[0]
    @sprites[:item_list].expensive_shadow_color = get_text_color_theme(:expensive)[1]
    @sprites[:item_list].active                 = false
  end

  #-----------------------------------------------------------------------------

  # Like the one in class BaseVisuals, but shows the money as BP instead of $.
  def choose_number_as_money_multiplier(help_text, money_per_unit, maximum, init_value = 1)
    @sprites[:speech_box].visible = true
    @sprites[:speech_box].text = help_text
    pbBottomLeftLines(@sprites[:speech_box], 2)
    # Show the help text
    loop do
      Graphics.update
      Input.update
      update_visuals
      if @sprites[:speech_box].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites[:speech_box].pausing?
          @sprites[:speech_box].resume
        end
      else
        break
      end
    end
    # Choose a quantity
    item_price = money_per_unit
    quantity = init_value
    using(num_window = Window_AdvancedTextPokemon.newWithSize(
          _INTL("×{1}<r>{2} BP", quantity, (quantity * item_price).to_s_formatted),
          0, 0, 224, 64, @viewport)) do
      num_window.z              = 2000
      num_window.visible        = true
      num_window.letterbyletter = false
      pbBottomRight(num_window)
      num_window.y -= @sprites[:speech_box].height
      loop do
        Graphics.update
        Input.update
        update
        num_window.update
        # Change quantity
        old_quantity = quantity
        if Input.repeat?(Input::LEFT)
          quantity = [quantity - 10, 1].max
        elsif Input.repeat?(Input::RIGHT)
          quantity = [quantity + 10, maximum].min
        elsif Input.repeat?(Input::UP)
          quantity += 1
          quantity = 1 if quantity > maximum
        elsif Input.repeat?(Input::DOWN)
          quantity -= 1
          quantity = maximum if quantity < 1
        end
        if quantity != old_quantity
          num_window.text = _INTL("×{1}<r>{2} BP", quantity, (quantity * item_price).to_s_formatted)
          pbPlayCursorSE
        end
        # Finish choosing a quantity
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          quantity = 0
          break
        end
      end
    end
    @sprites[:speech_box].visible = false
    return quantity
  end

  #-----------------------------------------------------------------------------

  def refresh_money_window
    @sprites[:money_window].text = _INTL("BP:\n<r>{1}", $player.battle_points.to_s_formatted)
  end
end

#===============================================================================
#
#===============================================================================
class UI::BPShop < UI::Mart
  ACTIONS = HandlerHash.new

  def initialize_stock(stock)
    @stock = UI::BPShopStockWrapper.new(stock)
  end

  def initialize_visuals
    @visuals = UI::BPShopVisuals.new(@stock, @bag)
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:interact, {
    :effect => proc { |screen|
      item_data = screen.item_data
      item_price = screen.stock.buy_price(item_data.id)
      max_quantity = screen.stock.maximum_affordable_quantity(item_data.id)
      # Check affordability
      if max_quantity == 0
        screen.show_message(_INTL("I'm sorry, you don't have enough BP."))
        next
      end
      # Choose how many of the item to buy
      quantity = 1
      if item_data.is_important?
        next if !screen.show_confirm_message(
          _INTL("You would like the {1}?\nThat will be {2} BP.",
                item_data.portion_name, item_price.to_s_formatted)
        )
      else
        quantity = screen.choose_number_as_money_multiplier(
          _INTL("How many {1} would you like?", item_data.portion_name_plural), item_price, max_quantity
        )
        next if quantity == 0
        item_price *= quantity
        if quantity > 1
          next if !screen.show_confirm_message(
            _INTL("So you want {1} {2}?\nThey'll be {3} BP. All right?",
                  quantity, item_data.portion_name_plural, item_price.to_s_formatted)
          )
        elsif quantity > 0
          next if !screen.show_confirm_message(
            _INTL("So you want {1} {2}?\nIt'll be {3} BP. All right?",
                  quantity, item_data.portion_name, item_price.to_s_formatted)
          )
        end
      end
      # Check the item can be put in the Bag
      if !screen.bag.can_add?(item_data.id, quantity)
        screen.show_message(_INTL("You have no room in your Bag."))
        next
      end
      # Add the bought item(s)
      screen.bag.add(item_data.id, quantity)
      $stats.battle_points_spent += item_price
      $stats.mart_items_bought += quantity
      $player.battle_points -= item_price
      screen.stock.remove_from_stock(item_data.id, quantity)
      screen.stock.refresh   # Removes bought important items
      screen.refresh
      screen.show_message(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
    }
  })
end

#===============================================================================
#
#===============================================================================
def pbBattlePointShop(stock, speech = nil)
  if speech.nil?
    pbMessage(_INTL("Welcome to the Exchange Service Corner!"))
    pbMessage(_INTL("We can exchange your BP for fabulous items."))
  else
    pbMessage(speech)
  end
  UI::BPShop.new(stock, $bag).main
  pbMessage(_INTL("Thank you for visiting."))
  pbMessage(_INTL("Please visit us again when you have saved up more BP."))
  $game_temp.clear_mart_prices
end
