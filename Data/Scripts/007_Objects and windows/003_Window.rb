class WindowCursorRect < Rect
  def initialize(window)
    super(0, 0, 0, 0)
    @window = window
  end

  def empty
    return unless needs_update?(0, 0, 0, 0)
    set(0, 0, 0, 0)
  end

  def empty?
    return self.x == 0 && self.y == 0 && self.width == 0 && self.height == 0
  end

  def set(x, y, width, height)
    return unless needs_update?(x, y, width, height)
    super(x, y, width, height)
    @window.width = @window.width
  end

  def height=(value)
    super(value)
    @window.width = @window.width
  end

  def width=(value)
    super(value)
    @window.width = @window.width
  end

  def x=(value)
    super(value)
    @window.width = @window.width
  end

  def y=(value)
    super(value)
    @window.width = @window.width
  end

  private

  def needs_update?(x, y, width, height)
    return self.x != x || self.y != y || self.width != width || self.height != height
  end
end


class Window
  attr_reader :tone
  attr_reader :color
  attr_reader :blend_type
  attr_reader :contents_blend_type
  attr_reader :viewport
  attr_reader :contents
  attr_reader :ox
  attr_reader :oy
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :width
  attr_reader :active
  attr_reader :pause
  attr_reader :height
  attr_reader :opacity
  attr_reader :back_opacity
  attr_reader :contents_opacity
  attr_reader :visible
  attr_reader :cursor_rect
  attr_reader :openness
  attr_reader :stretch

  def windowskin
    @_windowskin
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
    @sidebitmaps = [nil, nil, nil, nil]
    @cursorbitmap = nil
    @bgbitmap = nil
    @viewport = viewport
    @spritekeys.each do |i|
      @sprites[i] = Sprite.new(@viewport)
    end
    @disposed = false
    @tone = Tone.new(0, 0, 0)
    @color = Color.new(0, 0, 0, 0)
    @blankcontents = Bitmap.new(1, 1) # RGSS2 requires this
    @contents = @blankcontents
    @_windowskin = nil
    @rpgvx = false # Set to true to emulate RPGVX windows
    @x = 0
    @y = 0
    @width = 0
    @openness = 255
    @height = 0
    @ox = 0
    @oy = 0
    @z = 0
    @stretch = true
    @visible = true
    @active = true
    @blend_type = 0
    @contents_blend_type = 0
    @opacity = 255
    @back_opacity = 255
    @contents_opacity = 255
    @cursor_rect = WindowCursorRect.new(self)
    @cursorblink = 0
    @cursoropacity = 255
    @pause = false
    @pauseopacity = 255
    @pauseframe = 0
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
      @_contents = nil
      @disposed = true
    end
  end

  def openness=(value)
    @openness = value
    @openness = 0 if @openness < 0
    @openness = 255 if @openness > 255
    privRefresh
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
      @sprites[i].dispose
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
    @contents = value
    privRefresh
  end

  def windowskin=(value)
    @_windowskin = value
    if value.is_a?(Bitmap) && !value.disposed? && value.width == 128
      @rpgvx = true
    else
      @rpgvx = false
    end
    privRefresh(true)
  end

  def ox=(value)
    @ox = value
    privRefresh
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

  def oy=(value)
    @oy = value
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
    privRefresh
  end

  def x=(value)
    @x = value
    privRefresh
  end

  def y=(value)
    @y = value
    privRefresh
  end

  def opacity=(value)
    @opacity = value
    @opacity = 0 if @opacity < 0
    @opacity = 255 if @opacity > 255
    privRefresh
  end

  def back_opacity=(value)
    @back_opacity = value
    @back_opacity = 0 if @back_opacity < 0
    @back_opacity = 255 if @back_opacity > 255
    privRefresh
  end

  def contents_opacity=(value)
    @contents_opacity = value
    @contents_opacity = 0 if @contents_opacity < 0
    @contents_opacity = 255 if @contents_opacity > 255
    privRefresh
  end

  def tone=(value)
    @tone = value
    privRefresh
  end

  def color=(value)
    @color = value
    privRefresh
  end

  def blend_type=(value)
    @blend_type = value
    privRefresh
  end

  def flash(color, duration)
    return if disposed?
    @sprites.each do |i|
      i[1].flash(color, duration)
    end
  end

  def update
    return if disposed?
    mustchange = false
    if @active
      if @cursorblink == 0
        @cursoropacity -= 8
        @cursorblink = 1 if @cursoropacity <= 128
      else
        @cursoropacity += 8
        @cursorblink = 0 if @cursoropacity >= 255
      end
      mustchange = true if !@cursor_rect.empty?
    else
      mustchange = true if @cursoropacity != 128
      @cursoropacity = 128
    end
    if @pause
      @pauseframe = (Graphics.frame_count / 8) % 4
      @pauseopacity = [@pauseopacity + 64, 255].min
      mustchange = true
    end
    privRefresh if mustchange
    @sprites.each do |i|
      i[1].update
    end
  end

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

  def privRefresh(changeBitmap = false)
    return if self.disposed?
    backopac = self.back_opacity * self.opacity / 255
    contopac = self.contents_opacity
    cursoropac = @cursoropacity * contopac / 255
    4.times do |i|
      @sprites["corner#{i}"].bitmap = @_windowskin
      @sprites["scroll#{i}"].bitmap = @_windowskin
    end
    @sprites["pause"].bitmap = @_windowskin
    @sprites["contents"].bitmap = @contents
    if @_windowskin && !@_windowskin.disposed?
      4.times do |i|
        @sprites["corner#{i}"].opacity = @opacity
        @sprites["corner#{i}"].tone = @tone
        @sprites["corner#{i}"].color = @color
        @sprites["corner#{i}"].blend_type = @blend_type
        @sprites["corner#{i}"].visible = @visible
        @sprites["side#{i}"].opacity = @opacity
        @sprites["side#{i}"].tone = @tone
        @sprites["side#{i}"].color = @color
        @sprites["side#{i}"].blend_type = @blend_type
        @sprites["side#{i}"].visible = @visible
        @sprites["scroll#{i}"].opacity = @opacity
        @sprites["scroll#{i}"].tone = @tone
        @sprites["scroll#{i}"].blend_type = @blend_type
        @sprites["scroll#{i}"].color = @color
        @sprites["scroll#{i}"].visible = @visible
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
      @sprites["back"].visible = @visible
      @sprites["contents"].visible = @visible && @openness == 255
      @sprites["pause"].visible = @visible && @pause
      @sprites["cursor"].visible = @visible && @openness == 255
      hascontents = (@contents && !@contents.disposed?)
      @sprites["scroll0"].visible = @visible && hascontents && @oy > 0
      @sprites["scroll1"].visible = @visible && hascontents && @ox > 0
      @sprites["scroll2"].visible = @visible && hascontents &&
                                    (@contents.width - @ox) > @width - 32
      @sprites["scroll3"].visible = @visible && hascontents &&
                                    (@contents.height - @oy) > @height - 32
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
    @sprites.each do |i|
      i[1].z = @z
    end
    if @rpgvx
      @sprites["cursor"].z = @z # For Compatibility
      @sprites["contents"].z = @z # For Compatibility
      @sprites["pause"].z = @z # For Compatibility
    else
      @sprites["cursor"].z = @z + 1 # For Compatibility
      @sprites["contents"].z = @z + 2 # For Compatibility
      @sprites["pause"].z = @z + 2 # For Compatibility
    end
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
    sideRects = [
      Rect.new(trimX + 16, trimY + 0, 32, 16),
      Rect.new(trimX, trimY + 16, 16, 32),
      Rect.new(trimX + 48, trimY + 16, 16, 32),
      Rect.new(trimX + 16, trimY + 48, 32, 16)
    ]
    if @width > 32 && @height > 32
      @sprites["contents"].src_rect.set(@ox, @oy, @width - 32, @height - 32)
    else
      @sprites["contents"].src_rect.set(0, 0, 0, 0)
    end
    pauseRects = [
      trimX + 32, trimY + 64,
      trimX + 48, trimY + 64,
      trimX + 32, trimY + 80,
      trimX + 48, trimY + 80
    ]
    pauseWidth = 16
    pauseHeight = 16
    @sprites["pause"].src_rect.set(pauseRects[@pauseframe * 2],
                                   pauseRects[(@pauseframe * 2) + 1],
                                   pauseWidth,
                                   pauseHeight)
    @sprites["pause"].x = @x + (@width / 2) - (pauseWidth / 2)
    @sprites["pause"].y = @y + @height - 16 # 16 refers to skin margin
    @sprites["contents"].x = @x + 16
    @sprites["contents"].y = @y + 16
    @sprites["corner0"].x = @x
    @sprites["corner0"].y = @y
    @sprites["corner1"].x = @x + @width - 16
    @sprites["corner1"].y = @y
    @sprites["corner2"].x = @x
    @sprites["corner2"].y = @y + @height - 16
    @sprites["corner3"].x = @x + @width - 16
    @sprites["corner3"].y = @y + @height - 16
    @sprites["side0"].x = @x + 16
    @sprites["side0"].y = @y
    @sprites["side1"].x = @x
    @sprites["side1"].y = @y + 16
    @sprites["side2"].x = @x + @width - 16
    @sprites["side2"].y = @y + 16
    @sprites["side3"].x = @x + 16
    @sprites["side3"].y = @y + @height - 16
    @sprites["scroll0"].x = @x + (@width / 2) - 8
    @sprites["scroll0"].y = @y + 8
    @sprites["scroll1"].x = @x + 8
    @sprites["scroll1"].y = @y + (@height / 2) - 8
    @sprites["scroll2"].x = @x + @width - 16
    @sprites["scroll2"].y = @y + (@height / 2) - 8
    @sprites["scroll3"].x = @x + (@width / 2) - 8
    @sprites["scroll3"].y = @y + @height - 16
    @sprites["back"].x = @x + 2
    @sprites["back"].y = @y + 2
    @sprites["cursor"].x = @x + 16 + @cursor_rect.x
    @sprites["cursor"].y = @y + 16 + @cursor_rect.y
    if changeBitmap && @_windowskin && !@_windowskin.disposed?
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
      4.times do |i|
        dwidth  = [0, 3].include?(i) ? @width - 32 : 16
        dheight = [0, 3].include?(i) ? 16 : @height - 32
        @sidebitmaps[i] = ensureBitmap(@sidebitmaps[i], dwidth, dheight)
        @sprites["side#{i}"].bitmap = @sidebitmaps[i]
        @sprites["side#{i}"].src_rect.set(0, 0, dwidth, dheight)
        @sidebitmaps[i].clear
        if sideRects[i].width > 0 && sideRects[i].height > 0
          @sidebitmaps[i].stretch_blt(@sprites["side#{i}"].src_rect, @_windowskin, sideRects[i])
        end
      end
      backwidth = @width - 4
      backheight = @height - 4
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
        sprite.zoom_y = 1.0
      end
    else
      opn = @openness / 255.0
      @spritekeys.each do |k|
        sprite = @sprites[k]
        ratio = (@height <= 0) ? 0 : (sprite.y - @y) / @height.to_f
        sprite.zoom_y = opn
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
    end
  end
end
