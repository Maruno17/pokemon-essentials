#===============================================================================
# Base class for all three menu classes below
#===============================================================================
class Battle::Scene::MenuBase
  attr_accessor :x
  attr_accessor :y
  attr_reader   :z
  attr_reader   :visible
  attr_reader   :color
  attr_reader   :index
  attr_reader   :mode

  # NOTE: Button width is half the width of the graphic containing them all.
  BUTTON_HEIGHT = 46
  TEXT_BASE_COLOR   = Battle::Scene::MESSAGE_BASE_COLOR
  TEXT_SHADOW_COLOR = Battle::Scene::MESSAGE_SHADOW_COLOR

  def initialize(viewport = nil)
    @x          = 0
    @y          = 0
    @z          = 0
    @visible    = false
    @color      = Color.new(0, 0, 0, 0)
    @index      = 0
    @mode       = 0
    @disposed   = false
    @sprites    = {}
    @visibility = {}
  end

  def dispose
    return if disposed?
    pbDisposeSpriteHash(@sprites)
    @disposed = true
  end

  def disposed?; return @disposed; end

  def z=(value)
    @z = value
    @sprites.each do |i|
      i[1].z = value if !i[1].disposed?
    end
  end

  def visible=(value)
    @visible = value
    @sprites.each do |i|
      i[1].visible = (value && @visibility[i[0]]) if !i[1].disposed?
    end
  end

  def color=(value)
    @color = value
    @sprites.each do |i|
      i[1].color = value if !i[1].disposed?
    end
  end

  def index=(value)
    oldValue = @index
    @index = value
    @cmdWindow.index = @index if @cmdWindow
    refresh if @index != oldValue
  end

  def mode=(value)
    oldValue = @mode
    @mode = value
    refresh if @mode != oldValue
  end

  def addSprite(key, sprite)
    @sprites[key]    = sprite
    @visibility[key] = true
  end

  def setIndexAndMode(index, mode)
    oldIndex = @index
    oldMode  = @mode
    @index = index
    @mode  = mode
    @cmdWindow.index = @index if @cmdWindow
    refresh if @index != oldIndex || @mode != oldMode
  end

  def refresh; end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end



#===============================================================================
# Command menu (Fight/Pokémon/Bag/Run)
#===============================================================================
class Battle::Scene::CommandMenu < Battle::Scene::MenuBase
  # If true, displays graphics from Graphics/Pictures/Battle/overlay_command.png
  #     and Graphics/Pictures/Battle/cursor_command.png.
  # If false, just displays text and the command window over the graphic
  #     Graphics/Pictures/Battle/overlay_message.png. You will need to edit def
  #     pbShowWindow to make the graphic appear while the command menu is being
  #     displayed.
  USE_GRAPHICS = true
  # Lists of which button graphics to use in different situations/types of battle.
  MODES = [
    [0, 2, 1, 3],   # 0 = Regular battle
    [0, 2, 1, 9],   # 1 = Regular battle with "Cancel" instead of "Run"
    [0, 2, 1, 4],   # 2 = Regular battle with "Call" instead of "Run"
    [5, 7, 6, 3],   # 3 = Safari Zone
    [0, 8, 1, 3]    # 4 = Bug Catching Contest
  ]

  def initialize(viewport, z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height - 96
    # Create message box (shows "What will X do?")
    @msgBox = Window_UnformattedTextPokemon.newWithSize(
      "", self.x + 16, self.y + 2, 220, Graphics.height - self.y, viewport
    )
    @msgBox.baseColor   = TEXT_BASE_COLOR
    @msgBox.shadowColor = TEXT_SHADOW_COLOR
    @msgBox.windowskin  = nil
    addSprite("msgBox", @msgBox)
    if USE_GRAPHICS
      # Create background graphic
      background = IconSprite.new(self.x, self.y, viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_command")
      addSprite("background", background)
      # Create bitmaps
      @buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_command"))
      # Create action buttons
      @buttons = Array.new(4) do |i|   # 4 command options, therefore 4 buttons
        button = Sprite.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x = self.x + Graphics.width - 260
        button.x += (i.even? ? 0 : (@buttonBitmap.width / 2) - 4)
        button.y = self.y + 6
        button.y += (((i / 2) == 0) ? 0 : BUTTON_HEIGHT - 4)
        button.src_rect.width  = @buttonBitmap.width / 2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}", button)
        next button
      end
    else
      # Create command window (shows Fight/Bag/Pokémon/Run)
      @cmdWindow = Window_CommandPokemon.newWithSize(
        [], self.x + Graphics.width - 240, self.y, 240, Graphics.height - self.y, viewport
      )
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      addSprite("cmdWindow", @cmdWindow)
    end
    self.z = z
    refresh
  end

  def dispose
    super
    @buttonBitmap&.dispose
  end

  def z=(value)
    super
    @msgBox.z    += 1
    @cmdWindow.z += 1 if @cmdWindow
  end

  def setTexts(value)
    @msgBox.text = value[0]
    return if USE_GRAPHICS
    commands = []
    (1..4).each { |i| commands.push(value[i]) if value[i] }
    @cmdWindow.commands = commands
  end

  def refreshButtons
    return if !USE_GRAPHICS
    @buttons.each_with_index do |button, i|
      button.src_rect.x = (i == @index) ? @buttonBitmap.width / 2 : 0
      button.src_rect.y = MODES[@mode][i] * BUTTON_HEIGHT
      button.z          = self.z + ((i == @index) ? 3 : 2)
    end
  end

  def refresh
    @msgBox.refresh
    @cmdWindow&.refresh
    refreshButtons
  end
end



#===============================================================================
# Fight menu (choose a move)
#===============================================================================
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  attr_reader :battler
  attr_reader :shiftMode

  GET_MOVE_TEXT_COLOR_FROM_MOVE_BUTTON = true

  # If true, displays graphics from Graphics/Pictures/Battle/overlay_fight.png
  #     and Graphics/Pictures/Battle/cursor_fight.png.
  # If false, just displays text and the command window over the graphic
  #     Graphics/Pictures/Battle/overlay_message.png. You will need to edit def
  #     pbShowWindow to make the graphic appear while the command menu is being
  #     displayed.
  USE_GRAPHICS     = true
  TYPE_ICON_HEIGHT = 28
  # Text colours of PP of selected move
  PP_COLORS = [
    Color.new(248, 72, 72), Color.new(136, 48, 48),    # Red, zero PP
    Color.new(248, 136, 32), Color.new(144, 72, 24),   # Orange, 1/4 of total PP or less
    Color.new(248, 192, 0), Color.new(144, 104, 0),    # Yellow, 1/2 of total PP or less
    TEXT_BASE_COLOR, TEXT_SHADOW_COLOR                 # Black, more than 1/2 of total PP
  ]

  def initialize(viewport, z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height - 96
    @battler   = nil
    @shiftMode = 0
    # NOTE: @mode is for the display of the Mega Evolution button.
    #       0=don't show, 1=show unpressed, 2=show pressed
    if USE_GRAPHICS
      # Create bitmaps
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @megaEvoBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      # Create background graphic
      background = IconSprite.new(0, Graphics.height - 96, viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background", background)
      # Create move buttons
      @buttons = Array.new(Pokemon::MAX_MOVES) do |i|
        button = Sprite.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x = self.x + 4
        button.x += (i.even? ? 0 : (@buttonBitmap.width / 2) - 4)
        button.y = self.y + 6
        button.y += (((i / 2) == 0) ? 0 : BUTTON_HEIGHT - 4)
        button.src_rect.width  = @buttonBitmap.width / 2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}", button)
        next button
      end
      # Create overlay for buttons (shows move names)
      @overlay = BitmapSprite.new(Graphics.width, Graphics.height - self.y, viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay", @overlay)
      # Create overlay for selected move's info (shows move's PP)
      @infoOverlay = BitmapSprite.new(Graphics.width, Graphics.height - self.y, viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay", @infoOverlay)
      # Create type icon
      @typeIcon = Sprite.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x + 416
      @typeIcon.y      = self.y + 20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon", @typeIcon)
      # Create Mega Evolution button
      @megaButton = Sprite.new(viewport)
      @megaButton.bitmap = @megaEvoBitmap.bitmap
      @megaButton.x      = self.x + 120
      @megaButton.y      = self.y - (@megaEvoBitmap.height / 2)
      @megaButton.src_rect.height = @megaEvoBitmap.height / 2
      addSprite("megaButton", @megaButton)
      # Create Shift button
      @shiftButton = Sprite.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x + 4
      @shiftButton.y      = self.y - @shiftBitmap.height
      addSprite("shiftButton", @shiftButton)
    else
      # Create message box (shows type and PP of selected move)
      @msgBox = Window_AdvancedTextPokemon.newWithSize(
        "", self.x + 320, self.y, Graphics.width - 320, Graphics.height - self.y, viewport
      )
      @msgBox.baseColor   = TEXT_BASE_COLOR
      @msgBox.shadowColor = TEXT_SHADOW_COLOR
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox", @msgBox)
      # Create command window (shows moves)
      @cmdWindow = Window_CommandPokemon.newWithSize(
        [], self.x, self.y, 320, Graphics.height - self.y, viewport
      )
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow", @cmdWindow)
    end
    self.z = z
  end

  def dispose
    super
    @buttonBitmap&.dispose
    @typeBitmap&.dispose
    @megaEvoBitmap&.dispose
    @shiftBitmap&.dispose
  end

  def z=(value)
    super
    @msgBox.z      += 1 if @msgBox
    @cmdWindow.z   += 2 if @cmdWindow
    @overlay.z     += 5 if @overlay
    @infoOverlay.z += 6 if @infoOverlay
    @typeIcon.z    += 1 if @typeIcon
  end

  def battler=(value)
    @battler = value
    refresh
    refreshButtonNames
  end

  def shiftMode=(value)
    oldValue = @shiftMode
    @shiftMode = value
    refreshShiftButton if @shiftMode != oldValue
  end

  def refreshButtonNames
    moves = (@battler) ? @battler.moves : []
    if !USE_GRAPHICS
      # Fill in command window
      commands = []
      [4, moves.length].max.times do |i|
        commands.push((moves[i]) ? moves[i].name : "-")
      end
      @cmdWindow.commands = commands
      return
    end
    # Draw move names onto overlay
    @overlay.bitmap.clear
    textPos = []
    @buttons.each_with_index do |button, i|
      next if !@visibility["button_#{i}"]
      x = button.x - self.x + (button.src_rect.width / 2)
      y = button.y - self.y + 14
      moveNameBase = TEXT_BASE_COLOR
      if GET_MOVE_TEXT_COLOR_FROM_MOVE_BUTTON && moves[i].display_type(@battler)
        # NOTE: This takes a color from a particular pixel in the button
        #       graphic and makes the move name's base color that same color.
        #       The pixel is at coordinates 10,34 in the button box. If you
        #       change the graphic, you may want to change the below line of
        #       code to ensure the font is an appropriate color.
        moveNameBase = button.bitmap.get_pixel(10, button.src_rect.y + 34)
      end
      textPos.push([moves[i].name, x, y, 2, moveNameBase, TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap, textPos)
  end

  def refreshSelection
    moves = (@battler) ? @battler.moves : []
    if USE_GRAPHICS
      # Choose appropriate button graphics and z positions
      @buttons.each_with_index do |button, i|
        if !moves[i]
          @visibility["button_#{i}"] = false
          next
        end
        @visibility["button_#{i}"] = true
        button.src_rect.x = (i == @index) ? @buttonBitmap.width / 2 : 0
        button.src_rect.y = GameData::Type.get(moves[i].display_type(@battler)).icon_position * BUTTON_HEIGHT
        button.z          = self.z + ((i == @index) ? 4 : 3)
      end
    end
    refreshMoveData(moves[@index])
  end

  def refreshMoveData(move)
    # Write PP and type of the selected move
    if !USE_GRAPHICS
      moveType = GameData::Type.get(move.display_type(@battler)).name
      if move.total_pp <= 0
        @msgBox.text = _INTL("PP: ---<br>TYPE/{1}", moveType)
      else
        @msgBox.text = _ISPRINTF("PP: {1: 2d}/{2: 2d}<br>TYPE/{3:s}",
                                 move.pp, move.total_pp, moveType)
      end
      return
    end
    @infoOverlay.bitmap.clear
    if !move
      @visibility["typeIcon"] = false
      return
    end
    @visibility["typeIcon"] = true
    # Type icon
    type_number = GameData::Type.get(move.display_type(@battler)).icon_position
    @typeIcon.src_rect.y = type_number * TYPE_ICON_HEIGHT
    # PP text
    if move.total_pp > 0
      ppFraction = [(4.0 * move.pp / move.total_pp).ceil, 3].min
      textPos = []
      textPos.push([_INTL("PP: {1}/{2}", move.pp, move.total_pp),
                    448, 56, 2, PP_COLORS[ppFraction * 2], PP_COLORS[(ppFraction * 2) + 1]])
      pbDrawTextPositions(@infoOverlay.bitmap, textPos)
    end
  end

  def refreshMegaEvolutionButton
    return if !USE_GRAPHICS
    @megaButton.src_rect.y    = (@mode - 1) * @megaEvoBitmap.height / 2
    @megaButton.x             = self.x + ((@shiftMode > 0) ? 204 : 120)
    @megaButton.z             = self.z - 1
    @visibility["megaButton"] = (@mode > 0)
  end

  def refreshShiftButton
    return if !USE_GRAPHICS
    @shiftButton.src_rect.y    = (@shiftMode - 1) * @shiftBitmap.height
    @shiftButton.z             = self.z - 1
    @visibility["shiftButton"] = (@shiftMode > 0)
  end

  def refresh
    return if !@battler
    refreshSelection
    refreshMegaEvolutionButton
    refreshShiftButton
  end
end



#===============================================================================
# Target menu (choose a move's target)
# NOTE: Unlike the command and fight menus, this one doesn't have a textbox-only
#       version.
#===============================================================================
class Battle::Scene::TargetMenu < Battle::Scene::MenuBase
  attr_accessor :mode

  # Lists of which button graphics to use in different situations/types of battle.
  MODES = [
    [0, 2, 1, 3],   # 0 = Regular battle
    [0, 2, 1, 9],   # 1 = Regular battle with "Cancel" instead of "Run"
    [0, 2, 1, 4],   # 2 = Regular battle with "Call" instead of "Run"
    [5, 7, 6, 3],   # 3 = Safari Zone
    [0, 8, 1, 3]    # 4 = Bug Catching Contest
  ]
  CMD_BUTTON_WIDTH_SMALL = 170
  TEXT_BASE_COLOR   = Color.new(240, 248, 224)
  TEXT_SHADOW_COLOR = Color.new(64, 64, 64)

  def initialize(viewport, z, sideSizes)
    super(viewport)
    @sideSizes = sideSizes
    maxIndex = (@sideSizes[0] > @sideSizes[1]) ? (@sideSizes[0] - 1) * 2 : (@sideSizes[1] * 2) - 1
    @smallButtons = (@sideSizes.max > 2)
    self.x = 0
    self.y = Graphics.height - 96
    @texts = []
    # NOTE: @mode is for which buttons are shown as selected.
    #       0=select 1 button (@index), 1=select all buttons with text
    # Create bitmaps
    @buttonBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/cursor_target")
    # Create target buttons
    @buttons = Array.new(maxIndex + 1) do |i|
      numButtons = @sideSizes[i % 2]
      next if numButtons <= i / 2
      # NOTE: Battler indices go from left to right from the perspective of
      #       that side's trainer, so inc is different for each side for the
      #       same value of i/2.
      inc = (i.even?) ? i / 2 : numButtons - 1 - (i / 2)
      button = Sprite.new(viewport)
      button.bitmap = @buttonBitmap.bitmap
      button.src_rect.width  = (@smallButtons) ? CMD_BUTTON_WIDTH_SMALL : @buttonBitmap.width / 2
      button.src_rect.height = BUTTON_HEIGHT
      if @smallButtons
        button.x    = self.x + 170 - [0, 82, 166][numButtons - 1]
      else
        button.x    = self.x + 138 - [0, 116][numButtons - 1]
      end
      button.x += (button.src_rect.width - 4) * inc
      button.y = self.y + 6
      button.y += (BUTTON_HEIGHT - 4) * ((i + 1) % 2)
      addSprite("button_#{i}", button)
      next button
    end
    # Create overlay (shows target names)
    @overlay = BitmapSprite.new(Graphics.width, Graphics.height - self.y, viewport)
    @overlay.x = self.x
    @overlay.y = self.y
    pbSetNarrowFont(@overlay.bitmap)
    addSprite("overlay", @overlay)
    self.z = z
    refresh
  end

  def dispose
    super
    @buttonBitmap&.dispose
  end

  def z=(value)
    super
    @overlay.z += 5 if @overlay
  end

  def setDetails(texts, mode)
    @texts = texts
    @mode  = mode
    refresh
  end

  def refreshButtons
    # Choose appropriate button graphics and z positions
    @buttons.each_with_index do |button, i|
      next if !button
      sel = false
      buttonType = 0
      if @texts[i]
        sel ||= (@mode == 0 && i == @index)
        sel ||= (@mode == 1)
        buttonType = (i.even?) ? 1 : 2
      end
      buttonType = (2 * buttonType) + ((@smallButtons) ? 1 : 0)
      button.src_rect.x = (sel) ? @buttonBitmap.width / 2 : 0
      button.src_rect.y = buttonType * BUTTON_HEIGHT
      button.z          = self.z + ((sel) ? 3 : 2)
    end
    # Draw target names onto overlay
    @overlay.bitmap.clear
    textpos = []
    @buttons.each_with_index do |button, i|
      next if !button || nil_or_empty?(@texts[i])
      x = button.x - self.x + (button.src_rect.width / 2)
      y = button.y - self.y + 14
      textpos.push([@texts[i], x, y, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def refresh
    refreshButtons
  end
end
