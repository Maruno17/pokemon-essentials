#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class PokemonMartAdapter
  def getMoney
    return $Trainer.money
  end

  def getMoneyString
    return pbGetGoldString
  end

  def setMoney(value)
    $Trainer.money=value
  end

  def getInventory
    return $PokemonBag
  end

  def getName(item)
    return GameData::Item.get(item).name
  end

  def getDisplayName(item)
    item_name = getName(item)
    if GameData::Item.get(item).is_machine?
      machine = GameData::Item.get(item).move
      item_name = _INTL("{1} {2}", item_name, GameData::Move.get(machine).name)
    end
    return item_name
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
    return $PokemonBag.pbQuantity(item)
  end

  def showQuantity?(item)
    return !GameData::Item.get(item).is_important?
  end

  def getPrice(item, selling = false)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
      else
        return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0] > 0
      end
    end
    return GameData::Item.get(item).price
  end

  def getDisplayPrice(item, selling = false)
    price = getPrice(item, selling).to_s_formatted
    return _INTL("$ {1}", price)
  end

  def canSell?(item)
    return getPrice(item, true) > 0 && !GameData::Item.get(item).is_important?
  end

  def addItem(item)
    return $PokemonBag.pbStoreItem(item)
  end

  def removeItem(item)
    return $PokemonBag.pbDeleteItem(item)
  end
end

#===============================================================================
# Buy and Sell adapters
#===============================================================================
class BuyAdapter
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    @adapter.getDisplayPrice(item, false)
  end

  def isSelling?
    return false
  end
end

#===============================================================================
#
#===============================================================================
class SellAdapter
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    if @adapter.showQuantity?(item)
      return sprintf("x%d", @adapter.getQuantity(item))
    else
      return ""
    end
  end

  def isSelling?
    return true
  end
end

#===============================================================================
# Pokémon Mart
#===============================================================================
class Window_PokemonMart < Window_DrawableCommand
  def initialize(stock, adapter, x, y, width, height, viewport = nil)
    @stock       = stock
    @adapter     = adapter
    super(x, y, width, height, viewport)
    @selarrow    = AnimatedBitmap.new("Graphics/Pictures/martSel")
    @baseColor   = Color.new(88,88,80)
    @shadowColor = Color.new(168,184,184)
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
    if index == count-1
      textpos.push([_INTL("CANCEL"), rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
    else
      item = @stock[index]
      itemname = @adapter.getDisplayName(item)
      qty = @adapter.getDisplayPrice(item)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos - 4, false, self.baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonMart_Scene
  def update
    pbUpdateSpriteHash(@sprites)
    @subscene.pbUpdate if @subscene
  end

  def pbRefresh
    if @subscene
      @subscene.pbRefresh
    else
      itemwindow = @sprites["itemwindow"]
      @sprites["icon"].item = itemwindow.item
      @sprites["itemtextwindow"].text =
         (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
      itemwindow.refresh
    end
    @sprites["moneywindow"].text = _INTL("Money:\r\n<r>{1}", @adapter.getMoneyString)
  end

  def pbStartBuyOrSellScene(buying, stock, adapter)
    # Scroll right before showing screen
    pbScrollMap(6, 5, 5)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"] = Window_PokemonMart.new(stock, winAdapter,
       Graphics.width - 316 - 16, 12, 330 + 16, Graphics.height - 126)
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize("",
       64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport)
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = true
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 190
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    pbDeactivateWindows(@sprites)
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, adapter)
    pbStartBuyOrSellScene(true, stock, adapter)
  end

  def pbStartSellScene(bag, adapter)
    if $PokemonBag
      pbStartSellScene2(bag, adapter)
    else
      pbStartBuyOrSellScene(false, bag, adapter)
    end
  end

  def pbStartSellScene2(bag, adapter)
    @subscene = PokemonBag_Scene.new
    @adapter = adapter
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 99999
    numFrames = Graphics.frame_rate * 4 / 10
    alphaDiff = (255.0 / numFrames).ceil
    for j in 0..numFrames
      col = Color.new(0, 0, 0, j * alphaDiff)
      @viewport2.color = col
      Graphics.update
      Input.update
    end
    @subscene.pbStartScene(bag)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = false
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 186
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    pbDeactivateWindows(@sprites)
    @buying = false
    pbRefresh
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4, 5, 5)
  end

  def pbEndSellScene
    @subscene.pbEndScene if @subscene
    pbDisposeSpriteHash(@sprites)
    if @viewport2
      numFrames = Graphics.frame_rate * 4 / 10
      alphaDiff = (255.0 / numFrames).ceil
      for j in 0..numFrames
        col = Color.new(0, 0, 0, (numFrames - j) * alphaDiff)
        @viewport2.color = col
        Graphics.update
        Input.update
      end
      @viewport2.dispose
    end
    @viewport.dispose
    pbScrollMap(4, 5, 5) if !@subscene
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbShowMoney
    pbRefresh
    @sprites["moneywindow"].visible = true
  end

  def pbHideMoney
    pbRefresh
    @sprites["moneywindow"].visible = false
  end

  def pbDisplay(msg, brief = false)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    i = 0
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      self.update
      if !cw.busy?
        return if brief
        pbRefresh if i == 0
      end
      if Input.trigger?(Input::USE) && cw.busy?
        cw.resume
      end
      return if i >= Graphics.frame_rate * 3 / 2
      i += 1 if !cw.busy?
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
      if Input.trigger?(Input::USE) && cw.resume && !cw.busy?
        @sprites["helpwindow"].visible = false
        return
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

  def pbChooseNumber(helptext,item,maximum)
    curnumber = 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    itemprice = @adapter.getPrice(item, !@buying)
    itemprice /= 2 if !@buying
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) {   # Showing number of items
      qty = @adapter.getQuantity(item)
      using(inbagwindow = Window_AdvancedTextPokemon.new("")) {   # Showing quantity in bag
        pbPrepareWindow(numwindow)
        pbPrepareWindow(inbagwindow)
        numwindow.viewport = @viewport
        numwindow.width = 224
        numwindow.height = 64
        numwindow.baseColor = Color.new(88, 88, 80)
        numwindow.shadowColor = Color.new(168, 184, 184)
        inbagwindow.visible = @buying
        inbagwindow.viewport = @viewport
        inbagwindow.width = 190
        inbagwindow.height = 64
        inbagwindow.baseColor = Color.new(88, 88, 80)
        inbagwindow.shadowColor = Color.new(168, 184, 184)
        inbagwindow.text = _INTL("In Bag:<r>{1}  ", qty)
        numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
        pbBottomRight(numwindow)
        numwindow.y -= helpwindow.height
        pbBottomLeft(inbagwindow)
        inbagwindow.y -= helpwindow.height
        loop do
          Graphics.update
          Input.update
          numwindow.update
          inbagwindow.update
          self.update
          if Input.repeat?(Input::LEFT)
            pbPlayCursorSE
            curnumber -= 10
            curnumber = 1 if curnumber < 1
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
          elsif Input.repeat?(Input::RIGHT)
            pbPlayCursorSE
            curnumber += 10
            curnumber = maximum if curnumber > maximum
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
          elsif Input.repeat?(Input::UP)
            pbPlayCursorSE
            curnumber += 1
            curnumber = 1 if curnumber > maximum
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
          elsif Input.repeat?(Input::DOWN)
            pbPlayCursorSE
            curnumber -= 1
            curnumber = maximum if curnumber < 1
            numwindow.text = _INTL("x{1}<r>$ {2}", curnumber, (curnumber * itemprice).to_s_formatted)
          elsif Input.trigger?(Input::USE)
            pbPlayDecisionSE
            ret = curnumber
            break
          elsif Input.trigger?(Input::BACK)
            pbPlayCancelSE
            ret = 0
            break
          end
        end
      }
    }
    helpwindow.visible = false
    return ret
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          @sprites["icon"].item = itemwindow.item
          @sprites["itemtextwindow"].text =
             (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
        end
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
    }
  end

  def pbChooseSellItem
    if @subscene
      return @subscene.pbChooseItem
    else
      return pbChooseBuyItem
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonMartScreen
  def initialize(scene,stock)
    @scene=scene
    @stock=stock
    @adapter=PokemonMartAdapter.new
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg,&block)
    return @scene.pbDisplayPaused(msg,&block)
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock,@adapter)
    item=nil
    loop do
      item=@scene.pbChooseBuyItem
      break if !item
      quantity=0
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item)
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      if GameData::Item.get(item).is_important?
        if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
           itemname,price.to_s_formatted))
          next
        end
        quantity=1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity=@scene.pbChooseNumber(
           _INTL("{1}? Certainly. How many would you like?",itemname),item,maxafford)
        next if quantity==0
        price*=quantity
        if !pbConfirm(_INTL("{1}, and you want {2}. That will be ${3}. OK?",
           itemname,quantity,price.to_s_formatted))
          next
        end
      end
      if @adapter.getMoney<price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      added=0
      quantity.times do
        break if !@adapter.addItem(item)
        added+=1
      end
      if added!=quantity
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no more room in the Bag."))
      else
        @adapter.setMoney(@adapter.getMoney-price)
        for i in 0...@stock.length
          if GameData::Item.get(@stock[i]).is_important? && $PokemonBag.pbHasItem?(@stock[i])
            @stock[i]=nil
          end
        end
        @stock.compact!
        pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("Mart buy item") }
        if quantity >= 10 && $PokemonBag && GameData::Item.exists?(:PREMIERBALL)
          if Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item).is_poke_ball?
            premier_balls_added = 0
            (quantity / 10).times do
              break if !@adapter.addItem(:PREMIERBALL)
              premier_balls_added += 1
            end
            if premier_balls_added > 1
              pbDisplayPaused(_INTL("I'll throw in some {1}, too.", GameData::Item.get(:PREMIERBALL).name_plural))
            elsif premier_balls_added > 0
              pbDisplayPaused(_INTL("I'll throw in a {1}, too.", GameData::Item.get(:PREMIERBALL).name))
            end
          elsif !Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item) == :POKEBALL
            if @adapter.addItem(GameData::Item.get(:PREMIERBALL))
              pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too."))
            end
          end
        end
      end
    end
    @scene.pbEndBuyScene
  end

  def pbSellScreen
    item=@scene.pbStartSellScene(@adapter.getInventory,@adapter)
    loop do
      item=@scene.pbChooseSellItem
      break if !item
      itemname=@adapter.getDisplayName(item)
      price=@adapter.getPrice(item,true)
      if !@adapter.canSell?(item)
        pbDisplayPaused(_INTL("{1}? Oh, no. I can't buy that.",itemname))
        next
      end
      qty=@adapter.getQuantity(item)
      next if qty==0
      @scene.pbShowMoney
      if qty>1
        qty=@scene.pbChooseNumber(
           _INTL("{1}? How many would you like to sell?",itemname),item,qty)
      end
      if qty==0
        @scene.pbHideMoney
        next
      end
      price/=2
      price*=qty
      if pbConfirm(_INTL("I can pay ${1}. Would that be OK?",price.to_s_formatted))
        @adapter.setMoney(@adapter.getMoney+price)
        qty.times do
          @adapter.removeItem(item)
        end
        pbDisplayPaused(_INTL("Turned over the {1} and received ${2}.",itemname,price.to_s_formatted)) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
    end
    @scene.pbEndSellScene
  end
end

#===============================================================================
#
#===============================================================================
def pbPokemonMart(stock,speech=nil,cantsell=false)
  for i in 0...stock.length
    stock[i] = GameData::Item.get(stock[i]).id
    stock[i] = nil if GameData::Item.get(stock[i]).is_important? && $PokemonBag.pbHasItem?(stock[i])
  end
  stock.compact!
  commands = []
  cmdBuy  = -1
  cmdSell = -1
  cmdQuit = -1
  commands[cmdBuy = commands.length]  = _INTL("Buy")
  commands[cmdSell = commands.length] = _INTL("Sell") if !cantsell
  commands[cmdQuit = commands.length] = _INTL("Quit")
  cmd = pbMessage(
     speech ? speech : _INTL("Welcome! How may I serve you?"),
     commands,cmdQuit+1)
  loop do
    if cmdBuy>=0 && cmd==cmdBuy
      scene = PokemonMart_Scene.new
      screen = PokemonMartScreen.new(scene,stock)
      screen.pbBuyScreen
    elsif cmdSell>=0 && cmd==cmdSell
      scene = PokemonMart_Scene.new
      screen = PokemonMartScreen.new(scene,stock)
      screen.pbSellScreen
    else
      pbMessage(_INTL("Please come again!"))
      break
    end
    cmd = pbMessage(_INTL("Is there anything else I can help you with?"),
       commands,cmdQuit+1)
  end
  $game_temp.clear_mart_prices
end
