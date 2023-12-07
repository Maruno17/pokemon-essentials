#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class BattlePointShopAdapter
  def getBP
    return $player.battle_points
  end

  def getBPString
    return _INTL("{1} BP", $player.battle_points.to_s_formatted)
  end

  def setBP(value)
    $player.battle_points = value
  end

  def getInventory
    return $bag
  end

  def getName(item)
    return GameData::Item.get(item).portion_name
  end

  def getNamePlural(item)
    return GameData::Item.get(item).portion_name_plural
  end

  def getDisplayName(item)
    item_name = GameData::Item.get(item).name
    if GameData::Item.get(item).is_machine?
      machine = GameData::Item.get(item).move
      item_name = _INTL("{1} {2}", item_name, GameData::Move.get(machine).name)
    end
    return item_name
  end

  def getDisplayNamePlural(item)
    item_name_plural = GameData::Item.get(item).name_plural
    if GameData::Item.get(item).is_machine?
      machine = GameData::Item.get(item).move
      item_name_plural = _INTL("{1} {2}", item_name_plural, GameData::Move.get(machine).name)
    end
    return item_name_plural
  end

  def getDescription(item)
    return GameData::Item.get(item).description
  end

  def getItemIcon(item)
    return (item) ? GameData::Item.icon_filename(item) : nil
  end

  # Unused
  def getItemIconRect(_item)
    return Rect.new(0, 0, 48, 48)
  end

  def getQuantity(item)
    return $bag.quantity(item)
  end

  def showQuantity?(item)
    return !GameData::Item.get(item).is_important?
  end

  def getPrice(item)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if $game_temp.mart_prices[item][0] > 0
        return $game_temp.mart_prices[item][0]
      end
    end
    return GameData::Item.get(item).bp_price
  end

  def getDisplayPrice(item, selling = false)
    price = getPrice(item).to_s_formatted
    return _INTL("{1} BP", price)
  end

  def addItem(item)
    return $bag.add(item)
  end

  def removeItem(item)
    return $bag.remove(item)
  end
end

#===============================================================================
# Battle Point Shop
#===============================================================================
class Window_BattlePointShop < Window_DrawableCommand
  def initialize(stock, adapter, x, y, width, height, viewport = nil)
    @stock       = stock
    @adapter     = adapter
    super(x, y, width, height, viewport)
    @selarrow    = AnimatedBitmap.new("Graphics/UI/Mart/cursor")
    @baseColor   = Color.new(88, 88, 80)
    @shadowColor = Color.new(168, 184, 184)
    self.windowskin = nil
  end

  def itemCount
    return @stock.length + 1
  end

  def item
    return (self.index >= @stock.length) ? nil : @stock[self.index]
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    if index == count - 1
      textpos.push([_INTL("CANCEL"), rect.x, ypos + 2, :left, self.baseColor, self.shadowColor])
    else
      item = @stock[index]
      itemname = @adapter.getDisplayName(item)
      qty = @adapter.getDisplayPrice(item)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos + 2, :left, self.baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos + 2, :left, self.baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class BattlePointShop_Scene
  def update
    pbUpdateSpriteHash(@sprites)
    @subscene&.pbUpdate
  end

  def pbRefresh
    if @subscene
      @subscene.pbRefresh
    else
      itemwindow = @sprites["itemwindow"]
      @sprites["icon"].item = itemwindow.item
      @sprites["itemtextwindow"].text =
        (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
      @sprites["qtywindow"].visible = !itemwindow.item.nil?
      @sprites["qtywindow"].text    = _INTL("In Bag:<r>{1}", @adapter.getQuantity(itemwindow.item))
      @sprites["qtywindow"].y       = Graphics.height - 102 - @sprites["qtywindow"].height
      itemwindow.refresh
    end
    @sprites["battlepointwindow"].text = _INTL("Battle Points:\n<r>{1}", @adapter.getBPString)
  end

  def pbStartScene(stock, adapter)
    # Scroll right before showing screen
    pbScrollMap(6, 5, 5)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Mart/bg")
    @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    winAdapter = BattlePointShopAdapter.new
    @sprites["itemwindow"] = Window_BattlePointShop.new(
      stock, winAdapter, Graphics.width - 316 - 16, 10, 330 + 16, Graphics.height - 124
    )
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize(
      "", 64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport
    )
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["battlepointwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["battlepointwindow"])
    @sprites["battlepointwindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["battlepointwindow"].visible = true
    @sprites["battlepointwindow"].viewport = @viewport
    @sprites["battlepointwindow"].x = 0
    @sprites["battlepointwindow"].y = 0
    @sprites["battlepointwindow"].width = 190
    @sprites["battlepointwindow"].height = 96
    @sprites["battlepointwindow"].baseColor = Color.new(88, 88, 80)
    @sprites["battlepointwindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["qtywindow"])
    @sprites["qtywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["qtywindow"].viewport = @viewport
    @sprites["qtywindow"].width = 190
    @sprites["qtywindow"].height = 64
    @sprites["qtywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["qtywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"].text = _INTL("In Bag:<r>{1}", @adapter.getQuantity(@sprites["itemwindow"].item))
    @sprites["qtywindow"].y = Graphics.height - 102 - @sprites["qtywindow"].height
    pbDeactivateWindows(@sprites)
    pbRefresh
    Graphics.frame_reset
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4, 5, 5)
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbShowBattlePoints
    pbRefresh
    @sprites["battlepointwindow"].visible = true
  end

  def pbHideBattlePoints
    pbRefresh
    @sprites["battlepointwindow"].visible = false
  end

  def pbShowQuantity
    pbRefresh
    @sprites["qtywindow"].visible = true
  end

  def pbHideQuantity
    pbRefresh
    @sprites["qtywindow"].visible = false
  end

  def pbDisplay(msg, brief = false)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    pbPlayDecisionSE
    refreshed_after_busy = false
    timer_start = System.uptime
    loop do
      Graphics.update
      Input.update
      self.update
      if !cw.busy?
        return if brief
        if !refreshed_after_busy
          pbRefresh
          timer_start = System.uptime
          refreshed_after_busy = true
        end
      end
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        cw.resume if cw.busy?
      end
      return if refreshed_after_busy && System.uptime - timer_start >= 1.5
    end
  end

  def pbDisplayPaused(msg)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    yielded = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      wasbusy = cw.busy?
      self.update
      if !cw.busy? && !yielded
        yield if block_given?   # For playing SE as soon as the message is all shown
        yielded = true
      end
      pbRefresh if !cw.busy? && wasbusy
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        if cw.resume && !cw.busy?
          @sprites["helpwindow"].visible = false
          break
        end
      end
    end
  end

  def pbConfirm(msg)
    dw = @sprites["helpwindow"]
    dw.letterbyletter = true
    dw.text = msg
    dw.visible = true
    pbBottomLeftLines(dw, 2)
    commands = [_INTL("Yes"), _INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport = @viewport
    pbBottomRight(cw)
    cw.y -= dw.height
    cw.index = 0
    pbPlayDecisionSE
    loop do
      cw.visible = !dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::BACK) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible = false
        return false
      end
      if Input.trigger?(Input::USE) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible = false
        return (cw.index == 0)
      end
    end
  end

  def pbChooseNumber(helptext, item, maximum)
    curnumber = 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    itemprice = @adapter.getPrice(item)
    itemprice /= 2 if !@buying
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) do   # Showing number of items
      pbPrepareWindow(numwindow)
      numwindow.viewport = @viewport
      numwindow.width = 224
      numwindow.height = 64
      numwindow.baseColor = Color.new(88, 88, 80)
      numwindow.shadowColor = Color.new(168, 184, 184)
      numwindow.text = _INTL("x{1}<r>{2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
      pbBottomRight(numwindow)
      numwindow.y -= helpwindow.height
      loop do
        Graphics.update
        Input.update
        numwindow.update
        update
        oldnumber = curnumber
        if Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = 1 if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::USE)
          ret = curnumber
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = 0
          break
        end
      end
    end
    helpwindow.visible = false
    return ret
  end

  def pbChooseItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") do
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        pbRefresh if itemwindow.item != olditem
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          if itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class BattlePointShopScreen
  def initialize(scene, stock)
    @scene = scene
    @stock = stock
    @adapter = BattlePointShopAdapter.new
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg, &block)
    return @scene.pbDisplayPaused(msg, &block)
  end

  def pbBuyScreen
    @scene.pbStartScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      quantity       = 0
      itemname       = @adapter.getName(item)
      itemnameplural = @adapter.getNamePlural(item)
      price = @adapter.getPrice(item)
      if @adapter.getBP < price
        pbDisplayPaused(_INTL("You don't have enough BP."))
        next
      end
      if GameData::Item.get(item).is_important?
        next if !pbConfirm(_INTL("You would like the {1}?\nThat will be {2} BP.",
                                 itemname, price.to_s_formatted))
        quantity = 1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getBP / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity = @scene.pbChooseNumber(
          _INTL("How many {1} would you like?", itemnameplural), item, maxafford
        )
        next if quantity == 0
        price *= quantity
        if quantity > 1
          next if !pbConfirm(_INTL("You would like {1} {2}?\nThey'll be {3} BP.",
                                   quantity, itemnameplural, price.to_s_formatted))
        elsif quantity > 0
          next if !pbConfirm(_INTL("So you want {1} {2}?\nIt'll be {3} BP.",
                                   quantity, itemname, price.to_s_formatted))
        end
      end
      if @adapter.getBP < price
        pbDisplayPaused(_INTL("I'm sorry, you don't have enough BP."))
        next
      end
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.battle_points_spent += price
        $stats.mart_items_bought += quantity
        @adapter.setBP(@adapter.getBP - price)
        @stock.delete_if { |itm| GameData::Item.get(itm).is_important? && $bag.has?(itm) }
        pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
      else
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no room in your Bag."))
      end
    end
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
def pbBattlePointShop(stock, speech = nil)
  stock.delete_if { |item| GameData::Item.get(item).is_important? && $bag.has?(item) }
  if speech.nil?
    pbMessage(_INTL("Welcome to the Exchange Service Corner!"))
    pbMessage(_INTL("We can exchange your BP for fabulous items."))
  else
    pbMessage(speech)
  end
  scene = BattlePointShop_Scene.new
  screen = BattlePointShopScreen.new(scene, stock)
  screen.pbBuyScreen
  pbMessage(_INTL("Thank you for visiting."))
  pbMessage(_INTL("Please visit us again when you have saved up more BP."))
  $game_temp.clear_mart_prices
end
