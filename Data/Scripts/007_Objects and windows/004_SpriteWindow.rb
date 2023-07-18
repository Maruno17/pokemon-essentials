#===============================================================================
# SpriteWindow is a class based on Window which emulates Window's functionality.
# This class is necessary in order to change the viewport of windows (with
# viewport=) and to make windows fade in and out (with tone=).
#===============================================================================
class SpriteWindow < Window
  attr_reader :tone
  attr_reader :color
  attr_reader :viewport
  attr_reader :contents
  attr_reader :ox
  attr_reader :oy
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :zoom_x
  attr_reader :zoom_y
  attr_reader :offset_x
  attr_reader :offset_y
  attr_reader :width
  attr_reader :active
  attr_reader :pause
  attr_reader :height
  attr_reader :opacity
  attr_reader :back_opacity
  attr_reader :contents_opacity
  attr_reader :visible
  attr_reader :cursor_rect
  attr_reader :contents_blend_type
  attr_reader :blend_type
  attr_reader :openness

  def windowskin
    @_windowskin
  end

  # Flags used to preserve compatibility with RGSS/RGSS2's version of Window
  module CompatBits
    CORRECT_Z          = 1
    EXPAND_BACK        = 2
    SHOW_SCROLL_ARROWS = 4
    STRETCH_SIDES      = 8
    SHOW_PAUSE         = 16
    SHOW_CURSOR        = 32
  end

  attr_reader :compat
  attr_reader :skinformat
  attr_reader :skinrect

  def compat=(value)
    @compat = value
    privRefresh(true)
  end

  def initialize(viewport = nil)
    @sprites = {}
    @spritekeys = [
      "back",
      "corner0", "side0", "scroll0",
      "corner1", "side1", "scroll1",
      "corner2", "side2", "scroll2",
      "corner3", "side3", "scroll3",
      "cursor", "contents", "pause"
    ]
    @viewport = viewport
    @sidebitmaps = [nil, nil, nil, nil]
    @cursorbitmap = nil
    @bgbitmap = nil
    @spritekeys.each do |i|
      @sprites[i] = Sprite.new(@viewport)
    end
    @disposed = false
    @tone = Tone.new(0, 0, 0)
    @color = Color.new(0, 0, 0, 0)
    @blankcontents = Bitmap.new(1, 1) # RGSS2 requires this
    @contents = @blankcontents
    @_windowskin = nil
    @rpgvx = false
    @compat = CompatBits::EXPAND_BACK | CompatBits::STRETCH_SIDES
    @x = 0
    @y = 0
    @width = 0
    @height = 0
    @offset_x = 0
    @offset_y = 0
    @zoom_x = 1.0
    @zoom_y = 1.0
    @ox = 0
    @oy = 0
    @z = 0
    @stretch = true
    @visible = true
    @active = true
    @openness = 255
    @opacity = 255
    @back_opacity = 255
    @blend_type = 0
    @contents_blend_type = 0
    @contents_opacity = 255
    @cursor_rect = WindowCursorRect.new(self)
    @cursoropacity = 255
    @pause = false
    @pauseframe = 0
    @flash_duration = 0
    @pauseopacity = 0
    @skinformat = 0
    @skinrect = Rect.new(0, 0, 0, 0)
    @trim = [16, 16, 16, 16]
    privRefresh(true)
  end

  def dispose
    if !self.disposed?
      @sprites.each do |i|
        i[1]&.dispose
        @sprites[i[0]] = nil
      end
      @sidebitmaps.each_with_index do |bitmap, i|
        bitmap&.dispose
        @sidebitmaps[i] = nil
      end
      @blankcontents.dispose
      @cursorbitmap&.dispose
      @backbitmap&.dispose
      @sprites.clear
      @sidebitmaps.clear
      @_windowskin = nil
      @disposed = true
    end
  end

  def stretch=(value)
    @stretch = value
    privRefresh(true)
  end

  def visible=(value)
    @visible = value
    privRefresh
  end

  def viewport=(value)
    @viewport = value
    @spritekeys.each do |i|
      @sprites[i]&.dispose
      if @sprites[i].is_a?(Sprite)
        @sprites[i] = Sprite.new(@viewport)
      else
        @sprites[i] = nil
      end
    end
    privRefresh(true)
  end

  def z=(value)
    @z = value
    privRefresh
  end

  def disposed?
    return @disposed
  end

  def contents=(value)
    if @contents != value
      @contents = value
      privRefresh if @visible
    end
  end

  def ox=(value)
    if @ox != value
      @ox = value
      privRefresh if @visible
    end
  end

  def oy=(value)
    if @oy != value
      @oy = value
      privRefresh if @visible
    end
  end

  def active=(value)
    @active = value
    privRefresh(true)
  end

  def cursor_rect=(value)
    if value
      @cursor_rect.set(value.x, value.y, value.width, value.height)
    else
      @cursor_rect.empty
    end
  end

  def openness=(value)
    @openness = value
    @openness = 0 if @openness < 0
    @openness = 255 if @openness > 255
    privRefresh
  end

  def width=(value)
    @width = value
    privRefresh(true)
  end

  def height=(value)
    @height = value
    privRefresh(true)
  end

  def pause=(value)
    @pause = value
    @pauseopacity = 0 if !value
    privRefresh if @visible
  end

  def x=(value)
    @x = value
    privRefresh if @visible
  end

  def y=(value)
    @y = value
    privRefresh if @visible
  end

  def zoom_x=(value)
    @zoom_x = value
    privRefresh if @visible
  end

  def zoom_y=(value)
    @zoom_y = value
    privRefresh if @visible
  end

  def offset_x=(value)
    @x = value
    privRefresh if @visible
  end

  def offset_y=(value)
    @y = value
    privRefresh if @visible
  end

  def opacity=(value)
    @opacity = value
    @opacity = 0 if @opacity < 0
    @opacity = 255 if @opacity > 255
    privRefresh if @visible
  end

  def back_opacity=(value)
    @back_opacity = value
    @back_opacity = 0 if @back_opacity < 0
    @back_opacity = 255 if @back_opacity > 255
    privRefresh if @visible
  end

  def contents_opacity=(value)
    @contents_opacity = value
    @contents_opacity = 0 if @contents_opacity < 0
    @contents_opacity = 255 if @contents_opacity > 255
    privRefresh if @visible
  end

  def tone=(value)
    @tone = value
    privRefresh if @visible
  end

  def color=(value)
    @color = value
    privRefresh if @visible
  end

  def blend_type=(value)
    @blend_type = value
    privRefresh if @visible
  end

  # duration is in 1/20ths of a second
  def flash(color, duration)
    return if disposed?
    @flash_duration = duration / 20.0
    @flash_timer_start = System.uptime
    @sprites.each do |i|
      i[1].flash(color, (@flash_duration * Graphics.frame_rate).to_i)   # Must be in frames
    end
  end

  def update
    return if disposed?
    mustchange = false
    if @active
      cursor_time = System.uptime / 0.4
      if cursor_time.to_i.even?
        @cursoropacity = lerp(255, 128, 0.4, cursor_time % 2)
      else
        @cursoropacity = lerp(128, 255, 0.4, (cursor_time - 1) % 2)
      end
    else
      @cursoropacity = 128
    end
    privRefreshCursor
    if @pause
      oldpauseframe = @pauseframe
      oldpauseopacity = @pauseopacity
      @pauseframe = (System.uptime * 5).to_i % 4   # 4 frames, 5 frames per second
      @pauseopacity = [@pauseopacity + 64, 255].min
      mustchange = @pauseframe != oldpauseframe || @pauseopacity != oldpauseopacity
    end
    privRefresh if mustchange
    if @flash_timer_start
      @sprites.each_value { |i| i.update }
      @flash_timer_start = nil if System.uptime - @flash_timer_start >= @flash_duration
    end
  end

  def loadSkinFile(_file)
    if (self.windowskin.width == 80 || self.windowskin.width == 96) &&
       self.windowskin.height == 48
      # Body = X, Y, width, height of body rectangle within windowskin
      @skinrect.set(32, 16, 16, 16)
      # Trim = X, Y, width, height of trim rectangle within windowskin
      @trim = [32, 16, 16, 16]
    elsif self.windowskin.width == 80 && self.windowskin.height == 80
      @skinrect.set(32, 32, 16, 16)
      @trim = [32, 16, 16, 48]
    end
  end

  def windowskin=(value)
    oldSkinWidth = (@_windowskin && !@_windowskin.disposed?) ? @_windowskin.width : -1
    oldSkinHeight = (@_windowskin && !@_windowskin.disposed?) ? @_windowskin.height : -1
    @_windowskin = value
    if @skinformat == 1
      @rpgvx = false
      if @_windowskin && !@_windowskin.disposed?
        if @_windowskin.width != oldSkinWidth || @_windowskin.height != oldSkinHeight
          # Update skinrect and trim if windowskin's dimensions have changed
          @skinrect.set((@_windowskin.width - 16) / 2, (@_windowskin.height - 16) / 2, 16, 16)
          @trim = [@skinrect.x, @skinrect.y, @skinrect.x, @skinrect.y]
        end
      else
        @skinrect.set(16, 16, 16, 16)
        @trim = [16, 16, 16, 16]
      end
    else
      if value.is_a?(Bitmap) && !value.disposed? && value.width == 128
        @rpgvx = true
      else
        @rpgvx = false
      end
      @trim = [16, 16, 16, 16]
    end
    privRefresh(true)
  end

  def skinrect=(value)
    @skinrect = value
    privRefresh
  end

  def skinformat=(value)
    if @skinformat != value
      @skinformat = value
      privRefresh(true)
    end
  end

  def borderX
    return 32 if !@trim || skinformat == 0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[0] + (@_windowskin.width - @trim[2] - @trim[0])
    end
    return 32
  end

  def borderY
    return 32 if !@trim || skinformat == 0
    if @_windowskin && !@_windowskin.disposed?
      return @trim[1] + (@_windowskin.height - @trim[3] - @trim[1])
    end
    return 32
  end

  def leftEdge; self.startX; end
  def topEdge; self.startY; end
  def rightEdge; self.borderX - self.leftEdge; end
  def bottomEdge; self.borderY - self.topEdge; end

  def startX
    return !@trim || skinformat == 0  ? 16 : @trim[0]
  end

  def startY
    return !@trim || skinformat == 0  ? 16 : @trim[1]
  end

  def endX
    return !@trim || skinformat == 0  ? 16 : @trim[2]
  end

  def endY
    return !@trim || skinformat == 0  ? 16 : @trim[3]
  end

  def startX=(value)
    @trim[0] = value
    privRefresh
  end

  def startY=(value)
    @trim[1] = value
    privRefresh
  end

  def endX=(value)
    @trim[2] = value
    privRefresh
  end

  def endY=(value)
    @trim[3] = value
    privRefresh
  end

  #-----------------------------------------------------------------------------

  private

  def ensureBitmap(bitmap, dwidth, dheight)
    if !bitmap || bitmap.disposed? || bitmap.width < dwidth || bitmap.height < dheight
      bitmap&.dispose
      bitmap = Bitmap.new([1, dwidth].max, [1, dheight].max)
    end
    return bitmap
  end

  def tileBitmap(dstbitmap, dstrect, srcbitmap, srcrect)
    return if !srcbitmap || srcbitmap.disposed?
    left = dstrect.x
    top = dstrect.y
    y = 0
    loop do
      break unless y < dstrect.height
      x = 0
      loop do
        break unless x < dstrect.width
        dstbitmap.blt(x + left, y + top, srcbitmap, srcrect)
        x += srcrect.width
      end
      y += srcrect.height
    end
  end

  def privRefreshCursor
    contopac = self.contents_opacity
    cursoropac = @cursoropacity * contopac / 255
    @sprites["cursor"].opacity = cursoropac
  end

  def privRefresh(changeBitmap = false)
    return if !self || self.disposed?
    backopac = self.back_opacity * self.opacity / 255
    contopac = self.contents_opacity
    cursoropac = @cursoropacity * contopac / 255
    haveskin = @_windowskin && !@_windowskin.disposed?
    4.times do |i|
      @sprites["corner#{i}"].bitmap = @_windowskin
      @sprites["scroll#{i}"].bitmap = @_windowskin
    end
    @sprites["pause"].bitmap = @_windowskin
    @sprites["contents"].bitmap = @contents
    if haveskin
      4.times do |i|
        @sprites["corner#{i}"].opacity = backopac
        @sprites["corner#{i}"].tone = @tone
        @sprites["corner#{i}"].color = @color
        @sprites["corner#{i}"].visible = @visible
        @sprites["corner#{i}"].blend_type = @blend_type
        @sprites["side#{i}"].opacity = backopac
        @sprites["side#{i}"].tone = @tone
        @sprites["side#{i}"].color = @color
        @sprites["side#{i}"].blend_type = @blend_type
        @sprites["side#{i}"].visible = @visible
        @sprites["scroll#{i}"].opacity = @opacity
        @sprites["scroll#{i}"].tone = @tone
        @sprites["scroll#{i}"].color = @color
        @sprites["scroll#{i}"].visible = @visible
        @sprites["scroll#{i}"].blend_type = @blend_type
      end
      ["back", "cursor", "pause", "contents"].each do |i|
        @sprites[i].color = @color
        @sprites[i].tone = @tone
        @sprites[i].blend_type = @blend_type
      end
      @sprites["contents"].blend_type = @contents_blend_type
      @sprites["back"].opacity = backopac
      @sprites["contents"].opacity = contopac
      @sprites["cursor"].opacity = cursoropac
      @sprites["pause"].opacity = @pauseopacity
      supported = (@skinformat == 0)
      hascontents = (@contents && !@contents.disposed?)
      @sprites["back"].visible = @visible
      @sprites["contents"].visible = @visible && @openness == 255
      @sprites["pause"].visible = supported && @visible && @pause &&
                                  (@combat & CompatBits::SHOW_PAUSE)
      @sprites["cursor"].visible = supported && @visible && @openness == 255 &&
                                   (@combat & CompatBits::SHOW_CURSOR)
      @sprites["scroll0"].visible = false
      @sprites["scroll1"].visible = false
      @sprites["scroll2"].visible = false
      @sprites["scroll3"].visible = false
    else
      4.times do |i|
        @sprites["corner#{i}"].visible = false
        @sprites["side#{i}"].visible = false
        @sprites["scroll#{i}"].visible = false
      end
      @sprites["contents"].visible = @visible && @openness == 255
      @sprites["contents"].color = @color
      @sprites["contents"].tone = @tone
      @sprites["contents"].blend_type = @contents_blend_type
      @sprites["contents"].opacity = contopac
      @sprites["back"].visible = false
      @sprites["pause"].visible = false
      @sprites["cursor"].visible = false
    end
    @spritekeys.each do |i|
      @sprites[i].z = @z
    end
    if (@compat & CompatBits::CORRECT_Z) > 0 && @skinformat == 0 && !@rpgvx
      # Compatibility Mode: Cursor, pause, and contents have higher Z
      @sprites["cursor"].z = @z + 1
      @sprites["contents"].z = @z + 2
      @sprites["pause"].z = @z + 2
    end
    if @skinformat == 0
      startX = 16
      startY = 16
      endX = 16
      endY = 16
      trimStartX = 16
      trimStartY = 16
      trimWidth = 32
      trimHeight = 32
      if @rpgvx
        trimX = 64
        trimY = 0
        backRect = Rect.new(0, 0, 64, 64)
        blindsRect = Rect.new(0, 64, 64, 64)
      else
        trimX = 128
        trimY = 0
        backRect = Rect.new(0, 0, 128, 128)
        blindsRect = nil
      end
      if @_windowskin && !@_windowskin.disposed?
        @sprites["corner0"].src_rect.set(trimX, trimY + 0, 16, 16)
        @sprites["corner1"].src_rect.set(trimX + 48, trimY + 0, 16, 16)
        @sprites["corner2"].src_rect.set(trimX, trimY + 48, 16, 16)
        @sprites["corner3"].src_rect.set(trimX + 48, trimY + 48, 16, 16)
        @sprites["scroll0"].src_rect.set(trimX + 24, trimY + 16, 16, 8) # up
        @sprites["scroll3"].src_rect.set(trimX + 24, trimY + 40, 16, 8) # down
        @sprites["scroll1"].src_rect.set(trimX + 16, trimY + 24, 8, 16) # left
        @sprites["scroll2"].src_rect.set(trimX + 40, trimY + 24, 8, 16) # right
        cursorX = trimX
        cursorY = trimY + 64
        sideRects = [Rect.new(trimX + 16, trimY + 0, 32, 16),
                     Rect.new(trimX, trimY + 16, 16, 32),
                     Rect.new(trimX + 48, trimY + 16, 16, 32),
                     Rect.new(trimX + 16, trimY + 48, 32, 16)]
        pauseRects = [trimX + 32, trimY + 64,
                      trimX + 48, trimY + 64,
                      trimX + 32, trimY + 80,
                      trimX + 48, trimY + 80]
        pauseWidth = 16
        pauseHeight = 16
        @sprites["pause"].src_rect.set(
          pauseRects[@pauseframe * 2],
          pauseRects[(@pauseframe * 2) + 1],
          pauseWidth, pauseHeight
        )
      end
    else
      trimStartX = @trim[0]
      trimStartY = @trim[1]
      trimWidth = @trim[0] + (@skinrect.width - @trim[2] + @trim[0])
      trimHeight = @trim[1] + (@skinrect.height - @trim[3] + @trim[1])
      if @_windowskin && !@_windowskin.disposed?
        # width of left end of window
        startX = @skinrect.x
        # width of top end of window
        startY = @skinrect.y
        cx = @skinrect.x + @skinrect.width # right side of BODY rect
        cy = @skinrect.y + @skinrect.height # bottom side of BODY rect
        # width of right end of window
        endX = (!@_windowskin || @_windowskin.disposed?) ? @skinrect.x : @_windowskin.width - cx
        # height of bottom end of window
        endY = (!@_windowskin || @_windowskin.disposed?) ? @skinrect.y : @_windowskin.height - cy
        @sprites["corner0"].src_rect.set(0, 0, startX, startY)
        @sprites["corner1"].src_rect.set(cx, 0, endX, startY)
        @sprites["corner2"].src_rect.set(0, cy, startX, endY)
        @sprites["corner3"].src_rect.set(cx, cy, endX, endY)
        backRect = Rect.new(@skinrect.x, @skinrect.y, @skinrect.width, @skinrect.height)
        blindsRect = nil
        sideRects = [
          Rect.new(startX, 0, @skinrect.width, startY),  # side0 (top)
          Rect.new(0, startY, startX, @skinrect.height), # side1 (left)
          Rect.new(cx, startY, endX, @skinrect.height),  # side2 (right)
          Rect.new(startX, cy, @skinrect.width, endY)    # side3 (bottom)
        ]
      end
    end
    if @width > trimWidth && @height > trimHeight
      @sprites["contents"].src_rect.set(@ox, @oy, @width - trimWidth, @height - trimHeight)
    else
      @sprites["contents"].src_rect.set(0, 0, 0, 0)
    end
    @sprites["contents"].x = @x + trimStartX
    @sprites["contents"].y = @y + trimStartY
    if (@compat & CompatBits::SHOW_SCROLL_ARROWS) > 0 && @skinformat == 0 &&
       @_windowskin && !@_windowskin.disposed? &&
       @contents && !@contents.disposed?
      @sprites["scroll0"].visible = @visible && hascontents && @oy > 0
      @sprites["scroll1"].visible = @visible && hascontents && @ox > 0
      @sprites["scroll2"].visible = @visible && (@contents.width - @ox) > @width - trimWidth
      @sprites["scroll3"].visible = @visible && (@contents.height - @oy) > @height - trimHeight
    end
    if @_windowskin && !@_windowskin.disposed?
      borderX = startX + endX
      borderY = startY + endY
      @sprites["corner0"].x = @x
      @sprites["corner0"].y = @y
      @sprites["corner1"].x = @x + @width - endX
      @sprites["corner1"].y = @y
      @sprites["corner2"].x = @x
      @sprites["corner2"].y = @y + @height - endY
      @sprites["corner3"].x = @x + @width - endX
      @sprites["corner3"].y = @y + @height - endY
      @sprites["side0"].x = @x + startX
      @sprites["side0"].y = @y
      @sprites["side1"].x = @x
      @sprites["side1"].y = @y + startY
      @sprites["side2"].x = @x + @width - endX
      @sprites["side2"].y = @y + startY
      @sprites["side3"].x = @x + startX
      @sprites["side3"].y = @y + @height - endY
      @sprites["scroll0"].x = @x + (@width / 2) - 8
      @sprites["scroll0"].y = @y + 8
      @sprites["scroll1"].x = @x + 8
      @sprites["scroll1"].y = @y + (@height / 2) - 8
      @sprites["scroll2"].x = @x + @width - 16
      @sprites["scroll2"].y = @y + (@height / 2) - 8
      @sprites["scroll3"].x = @x + (@width / 2) - 8
      @sprites["scroll3"].y = @y + @height - 16
      @sprites["cursor"].x = @x + startX + @cursor_rect.x
      @sprites["cursor"].y = @y + startY + @cursor_rect.y
      if (@compat & CompatBits::EXPAND_BACK) > 0 && @skinformat == 0
        # Compatibility mode: Expand background
        @sprites["back"].x = @x + 2
        @sprites["back"].y = @y + 2
      else
        @sprites["back"].x = @x + startX
        @sprites["back"].y = @y + startY
      end
    end
    if changeBitmap && @_windowskin && !@_windowskin.disposed?
      if @skinformat == 0
        @sprites["cursor"].x = @x + startX + @cursor_rect.x
        @sprites["cursor"].y = @y + startY + @cursor_rect.y
        width = @cursor_rect.width
        height = @cursor_rect.height
        if width > 0 && height > 0
          cursorrects = [
            # sides
            Rect.new(cursorX + 2, cursorY + 0, 28, 2),
            Rect.new(cursorX + 0, cursorY + 2, 2, 28),
            Rect.new(cursorX + 30, cursorY + 2, 2, 28),
            Rect.new(cursorX + 2, cursorY + 30, 28, 2),
            # corners
            Rect.new(cursorX + 0, cursorY + 0, 2, 2),
            Rect.new(cursorX + 30, cursorY + 0, 2, 2),
            Rect.new(cursorX + 0, cursorY + 30, 2, 2),
            Rect.new(cursorX + 30, cursorY + 30, 2, 2),
            # back
            Rect.new(cursorX + 2, cursorY + 2, 28, 28)
          ]
          margin = 2
          fullmargin = 4
          @cursorbitmap = ensureBitmap(@cursorbitmap, width, height)
          @cursorbitmap.clear
          @sprites["cursor"].bitmap = @cursorbitmap
          @sprites["cursor"].src_rect.set(0, 0, width, height)
          rect = Rect.new(margin, margin, width - fullmargin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[8])
          @cursorbitmap.blt(0, 0, @_windowskin, cursorrects[4])   # top left
          @cursorbitmap.blt(width - margin, 0, @_windowskin, cursorrects[5])   # top right
          @cursorbitmap.blt(0, height - margin, @_windowskin, cursorrects[6])   # bottom right
          @cursorbitmap.blt(width - margin, height - margin, @_windowskin, cursorrects[7])   # bottom left
          rect = Rect.new(margin, 0, width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[0])
          rect = Rect.new(0, margin, margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[1])
          rect = Rect.new(width - margin, margin, margin, height - fullmargin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[2])
          rect = Rect.new(margin, height - margin, width - fullmargin, margin)
          @cursorbitmap.stretch_blt(rect, @_windowskin, cursorrects[3])
        else
          @sprites["cursor"].visible = false
          @sprites["cursor"].src_rect.set(0, 0, 0, 0)
        end
      end
      4.times do |i|
        case i
        when 0
          dwidth  = @width - startX - endX
          dheight = startY
        when 1
          dwidth  = startX
          dheight = @height - startY - endY
        when 2
          dwidth  = endX
          dheight = @height - startY - endY
        when 3
          dwidth  = @width - startX - endX
          dheight = endY
        end
        @sidebitmaps[i] = ensureBitmap(@sidebitmaps[i], dwidth, dheight)
        @sprites["side#{i}"].bitmap = @sidebitmaps[i]
        @sprites["side#{i}"].src_rect.set(0, 0, dwidth, dheight)
        @sidebitmaps[i].clear
        if sideRects[i].width > 0 && sideRects[i].height > 0
          if (@compat & CompatBits::STRETCH_SIDES) > 0 && @skinformat == 0
            # Compatibility mode: Stretch sides
            @sidebitmaps[i].stretch_blt(@sprites["side#{i}"].src_rect,
                                        @_windowskin, sideRects[i])
          else
            tileBitmap(@sidebitmaps[i], @sprites["side#{i}"].src_rect,
                       @_windowskin, sideRects[i])
          end
        end
      end
      if (@compat & CompatBits::EXPAND_BACK) > 0 && @skinformat == 0
        # Compatibility mode: Expand background
        backwidth = @width - 4
        backheight = @height - 4
      else
        backwidth = @width - borderX
        backheight = @height - borderY
      end
      if backwidth > 0 && backheight > 0
        @backbitmap = ensureBitmap(@backbitmap, backwidth, backheight)
        @sprites["back"].bitmap = @backbitmap
        @sprites["back"].src_rect.set(0, 0, backwidth, backheight)
        @backbitmap.clear
        if @stretch
          @backbitmap.stretch_blt(@sprites["back"].src_rect, @_windowskin, backRect)
        else
          tileBitmap(@backbitmap, @sprites["back"].src_rect, @_windowskin, backRect)
        end
        if blindsRect
          tileBitmap(@backbitmap, @sprites["back"].src_rect, @_windowskin, blindsRect)
        end
      else
        @sprites["back"].visible = false
        @sprites["back"].src_rect.set(0, 0, 0, 0)
      end
    end
    if @openness == 255
      @spritekeys.each do |k|
        sprite = @sprites[k]
        sprite.zoom_x = 1.0
        sprite.zoom_y = 1.0
      end
    else
      opn = @openness / 255.0
      @spritekeys.each do |k|
        sprite = @sprites[k]
        ratio = (@height <= 0) ? 0 : (sprite.y - @y) / @height.to_f
        sprite.zoom_y = opn
        sprite.zoom_x = 1.0
        sprite.oy = 0
        sprite.y = (@y + (@height / 2.0) + (@height * ratio * opn) - (@height / 2 * opn)).floor
      end
    end
    i = 0
    # Ensure Z order
    @spritekeys.each do |k|
      sprite = @sprites[k]
      y = sprite.y
      sprite.y = i
      sprite.oy = (sprite.zoom_y <= 0) ? 0 : (i - y) / sprite.zoom_y
      sprite.zoom_x *= @zoom_x
      sprite.zoom_y *= @zoom_y
      sprite.x *= @zoom_x
      sprite.y *= @zoom_y
      sprite.x += (@offset_x / sprite.zoom_x)
      sprite.y += (@offset_y / sprite.zoom_y)
    end
  end
end

#===============================================================================
#
#===============================================================================
class SpriteWindow_Base < SpriteWindow
  TEXT_PADDING = 4   # In pixels

  def initialize(x, y, width, height)
    super()
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    @curframe = MessageConfig.pbGetSystemFrame
    @curfont = MessageConfig.pbGetSystemFontName
    @sysframe = AnimatedBitmap.new(@curframe)
    RPG::Cache.retain(@curframe) if @curframe && !@curframe.empty?
    @customskin = nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame
    pbSetSystemFont(self.contents) if self.contents
  end

  def __setWindowskin(skin)
    if skin && ((skin.width == 192 && skin.height == 128) ||   # RPGXP Windowskin
       (skin.width == 128 && skin.height == 128))              # RPGVX Windowskin
      self.skinformat = 0
    else
      self.skinformat = 1
    end
    self.windowskin = skin
  end

  def __resolveSystemFrame
    if self.skinformat == 1
      if !@resolvedFrame
        @resolvedFrame = MessageConfig.pbGetSystemFrame
        @resolvedFrame.sub!(/\.[^\.\/\\]+$/, "")
      end
      self.loadSkinFile("#{@resolvedFrame}.txt") if @resolvedFrame != ""
    end
  end

  # Filename of windowskin to apply. Supports XP, VX, and animated skins.
  def setSkin(skin)
    @customskin&.dispose
    @customskin = nil
    resolvedName = pbResolveBitmap(skin)
    return if nil_or_empty?(resolvedName)
    @customskin = AnimatedBitmap.new(resolvedName)
    RPG::Cache.retain(resolvedName)
    __setWindowskin(@customskin.bitmap)
    if self.skinformat == 1
      skinbase = resolvedName.sub(/\.[^\.\/\\]+$/, "")
      self.loadSkinFile("#{skinbase}.txt")
    end
  end

  def setSystemFrame
    @customskin&.dispose
    @customskin = nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame
  end

  def update
    super
    if self.windowskin
      if @customskin
        if @customskin.totalFrames > 1
          @customskin.update
          __setWindowskin(@customskin.bitmap)
        end
      elsif @sysframe
        if @sysframe.totalFrames > 1
          @sysframe.update
          __setWindowskin(@sysframe.bitmap)
        end
      end
    end
    if @curframe != MessageConfig.pbGetSystemFrame
      @curframe = MessageConfig.pbGetSystemFrame
      if @sysframe && !@customskin
        @sysframe&.dispose
        @sysframe = AnimatedBitmap.new(@curframe)
        RPG::Cache.retain(@curframe) if @curframe && !@curframe.empty?
        @resolvedFrame = nil
        __setWindowskin(@sysframe.bitmap)
        __resolveSystemFrame
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
    if @curfont != MessageConfig.pbGetSystemFontName
      @curfont = MessageConfig.pbGetSystemFontName
      if self.contents && !self.contents.disposed?
        pbSetSystemFont(self.contents)
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
  end

  def dispose
    self.contents&.dispose
    @sysframe.dispose
    @customskin&.dispose
    super
  end
end
