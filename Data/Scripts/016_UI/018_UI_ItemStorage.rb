#===============================================================================
#
#===============================================================================
class Window_PokemonItemStorage < Window_DrawableCommand
  attr_reader :bag
  attr_reader :pocket
  attr_reader :sortIndex

  def sortIndex=(value)
    @sortIndex = value
    refresh
  end

  def initialize(bag, x, y, width, height)
    @bag = bag
    @sortIndex = -1
    @adapter = PokemonMartAdapter.new
    super(x, y, width, height)
    self.windowskin = nil
  end

  def item
    item = @bag[self.index]
    return item ? item[0] : nil
  end

  def itemCount
    return @bag.length + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    textpos = []
    if index == @bag.length
      textpos.push([_INTL("CANCEL"), rect.x, rect.y, :left, self.baseColor, self.shadowColor])
    else
      item     = @bag[index][0]
      itemname = @adapter.getDisplayName(item)
      baseColor = (index == @sortIndex) ? Color.new(248, 24, 24) : self.baseColor
      textpos.push([itemname, rect.x, rect.y, :left, self.baseColor, self.shadowColor])
      if GameData::Item.get(item).show_quantity?
        qty     = _ISPRINTF("x{1: 2d}", @bag[index][1])
        sizeQty = self.contents.text_size(qty).width
        xQty = rect.x + rect.width - sizeQty - 2
        textpos.push([qty, xQty, rect.y, :left, baseColor, self.shadowColor])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class ItemStorage_Scene
  ITEMLISTBASECOLOR   = Color.new(88, 88, 80)
  ITEMLISTSHADOWCOLOR = Color.new(168, 184, 184)
  ITEMTEXTBASECOLOR   = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR = Color.new(0, 0, 0)
  TITLEBASECOLOR      = Color.new(248, 248, 248)
  TITLESHADOWCOLOR    = Color.new(0, 0, 0)
  ITEMSVISIBLE        = 7

  def initialize(title)
    @title = title
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag)
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag = bag
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/itemstorage_bg")
    @sprites["icon"] = ItemIconSprite.new(50, 334, nil, @viewport)
    # Item list
    @sprites["itemwindow"] = Window_PokemonItemStorage.new(@bag, 98, 14, 334, 32 + (ITEMSVISIBLE * 32))
    @sprites["itemwindow"].viewport    = @viewport
    @sprites["itemwindow"].index       = 0
    @sprites["itemwindow"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemwindow"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemwindow"].refresh
    # Title
    @sprites["pocketwindow"] = BitmapSprite.new(88, 64, @viewport)
    @sprites["pocketwindow"].x = 14
    @sprites["pocketwindow"].y = 16
    pbSetNarrowFont(@sprites["pocketwindow"].bitmap)
    # Item description
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize("", 84, 272, Graphics.width - 84, 128, @viewport)
    @sprites["itemtextwindow"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtextwindow"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtextwindow"].windowskin  = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    # Letter-by-letter message window
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChooseNumber(helptext, maximum)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum) { update }
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { update }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { update }
  end

  def pbShowCommands(helptext, commands)
    return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands) { update }
  end

  def pbRefresh
    bm = @sprites["pocketwindow"].bitmap
    # Draw title at upper left corner ("Toss Item/Withdraw Item")
    drawTextEx(bm, 0, 8, bm.width, 2, @title, TITLEBASECOLOR, TITLESHADOWCOLOR)
    itemwindow = @sprites["itemwindow"]
    # Draw item icon
    @sprites["icon"].item = itemwindow.item
    # Get item description
    if itemwindow.item
      @sprites["itemtextwindow"].text = GameData::Item.get(itemwindow.item).description
    else
      @sprites["itemtextwindow"].text = _INTL("Close storage.")
    end
    itemwindow.refresh
  end

  def pbChooseItem
    pbRefresh
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemwindow"]
    itemwindow.refresh
    pbActivateWindow(@sprites, "itemwindow") do
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        pbRefresh if itemwindow.item != olditem
        if Input.trigger?(Input::BACK)
          return nil
        elsif Input.trigger?(Input::USE)
          if itemwindow.index < @bag.length
            pbRefresh
            return @bag[itemwindow.index][0]
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
class WithdrawItemScene < ItemStorage_Scene
  def initialize
    super(_INTL("Withdraw\nItem"))
  end
end

#===============================================================================
#
#===============================================================================
class TossItemScene < ItemStorage_Scene
  def initialize
    super(_INTL("Toss\nItem"))
  end
end

#===============================================================================
# Common UI functions used in both the Bag and item storage screens.
# Displays messages and allows the user to choose a number/command.
# The window _helpwindow_ will display the _helptext_.
#===============================================================================
module UIHelper
  # Letter by letter display of the message _msg_ by the window _helpwindow_.
  def self.pbDisplay(helpwindow, msg, brief)
    cw = helpwindow
    oldvisible = cw.visible
    cw.letterbyletter = true
    cw.text           = msg + "\1"
    cw.visible        = true
    pbBottomLeftLines(cw, 2)
    loop do
      Graphics.update
      Input.update
      (block_given?) ? yield : cw.update
      if !cw.busy? && (brief || (Input.trigger?(Input::USE) && cw.resume))
        break
      end
    end
    cw.visible = oldvisible
  end

  def self.pbDisplayStatic(msgwindow, message)
    oldvisible = msgwindow.visible
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.width          = Graphics.width
    msgwindow.resizeHeightToFit(message, Graphics.width)
    msgwindow.text = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      (block_given?) ? yield : msgwindow.update
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        break
      end
    end
    msgwindow.visible = oldvisible
    Input.update
  end

  # Letter by letter display of the message _msg_ by the window _helpwindow_,
  # used to ask questions.  Returns true if the user chose yes, false if no.
  def self.pbConfirm(helpwindow, msg)
    dw = helpwindow
    oldvisible = dw.visible
    dw.letterbyletter = true
    dw.text           = msg
    dw.visible        = true
    pbBottomLeftLines(dw, 2)
    commands = [_INTL("Yes"), _INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.index = 0
    cw.viewport = helpwindow.viewport
    pbBottomRight(cw)
    cw.y -= dw.height
    ret = false
    loop do
      cw.visible = (!dw.busy?)
      Graphics.update
      Input.update
      cw.update
      (block_given?) ? yield : dw.update
      if !dw.busy? && dw.resume
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = (cw.index == 0)
          break
        end
      end
    end
    cw.dispose
    dw.visible = oldvisible
    return ret
  end

  def self.pbChooseNumber(helpwindow, helptext, maximum, initnum = 1)
    oldvisible = helpwindow.visible
    helpwindow.visible        = true
    helpwindow.text           = helptext
    helpwindow.letterbyletter = false
    curnumber = initnum
    ret = 0
    numwindow = Window_UnformattedTextPokemon.new("x000")
    numwindow.viewport       = helpwindow.viewport
    numwindow.letterbyletter = false
    numwindow.text           = _ISPRINTF("x{1:03d}", curnumber)
    numwindow.resizeToFit(numwindow.text, Graphics.width)
    pbBottomRight(numwindow)
    helpwindow.resizeHeightToFit(helpwindow.text, Graphics.width - numwindow.width)
    pbBottomLeft(helpwindow)
    loop do
      Graphics.update
      Input.update
      numwindow.update
      helpwindow.update
      yield if block_given?
      oldnumber = curnumber
      if Input.trigger?(Input::BACK)
        ret = 0
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        ret = curnumber
        pbPlayDecisionSE
        break
      elsif Input.repeat?(Input::UP)
        curnumber += 1
        curnumber = 1 if curnumber > maximum
        if curnumber != oldnumber
          numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
          pbPlayCursorSE
        end
      elsif Input.repeat?(Input::DOWN)
        curnumber -= 1
        curnumber = maximum if curnumber < 1
        if curnumber != oldnumber
          numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
          pbPlayCursorSE
        end
      elsif Input.repeat?(Input::LEFT)
        curnumber -= 10
        curnumber = 1 if curnumber < 1
        if curnumber != oldnumber
          numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
          pbPlayCursorSE
        end
      elsif Input.repeat?(Input::RIGHT)
        curnumber += 10
        curnumber = maximum if curnumber > maximum
        if curnumber != oldnumber
          numwindow.text = _ISPRINTF("x{1:03d}", curnumber)
          pbPlayCursorSE
        end
      end
    end
    numwindow.dispose
    helpwindow.visible = oldvisible
    return ret
  end

  def self.pbShowCommands(helpwindow, helptext, commands, initcmd = 0)
    ret = -1
    oldvisible = helpwindow.visible
    helpwindow.visible        = helptext ? true : false
    helpwindow.letterbyletter = false
    helpwindow.text           = helptext || ""
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.index = initcmd
    begin
      cmdwindow.viewport = helpwindow.viewport
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helpwindow.text, Graphics.width - cmdwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        yield
        cmdwindow.update
        if Input.trigger?(Input::BACK)
          ret = -1
          pbPlayCancelSE
          break
        end
        if Input.trigger?(Input::USE)
          ret = cmdwindow.index
          pbPlayDecisionSE
          break
        end
      end
    ensure
      cmdwindow&.dispose
    end
    helpwindow.visible = oldvisible
    return ret
  end
end
