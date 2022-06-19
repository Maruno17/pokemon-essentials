################################################################################
# Controls
################################################################################
class Window_Menu < Window_CommandPokemon
  def initialize(commands, x, y)
    tempbitmap = Bitmap.new(32, 32)
    w = 0
    commands.each do |i|
      width = tempbitmap.text_size(i).width
      w = width if w < width
    end
    w += 16 + self.borderX
    super(commands, w)
    h = [commands.length * 32, 480].min
    h += self.borderY
    right = [x + w, 640].min
    bottom = [y + h, 480].min
    left = right - w
    top = bottom - h
    self.x = left
    self.y = top
    self.width = w
    self.height = h
    tempbitmap.dispose
  end

  def hittest
    mousepos = Mouse.getMousePos
    return -1 if !mousepos
    toprow = self.top_row
    (toprow...toprow + @item_max).each do |i|
      rc = Rect.new(0, 32 * (i - toprow), self.contents.width, 32)
      rc.x += self.x + self.leftEdge
      rc.y += self.y + self.topEdge
      if rc.contains(mousepos[0], mousepos[1])
        return i
      end
    end
    return -1
  end
end



################################################################################
# Clipboard
################################################################################
module Clipboard
  @data = nil
  @typekey = ""

  def self.data
    return nil if !@data
    return Marshal.load(@data)
  end

  def self.typekey
    return @typekey
  end

  def self.setData(data, key)
    @data = Marshal.dump(data)
    @typekey = key
  end
end



################################################################################
# Collision testing
################################################################################
class Rect < Object
  def contains(x, y)
    return x >= self.x && x < self.x + self.width &&
           y >= self.y && y < self.y + self.height
  end
end



def pbSpriteHitTest(sprite, x, y, usealpha = true, wholecanvas = false)
  return false if !sprite || sprite.disposed?
  return false if !sprite.bitmap
  return false if !sprite.visible
  return false if sprite.bitmap.disposed?
  width = sprite.src_rect.width
  height = sprite.src_rect.height
  if wholecanvas
    xwidth = 0
    xheight = 0
  else
    xwidth = width - 64
    xheight = height - 64
    width = 64 if width > 64 && !usealpha
    height = 64 if height > 64 && !usealpha
  end
  width = sprite.bitmap.width if width > sprite.bitmap.width
  height = sprite.bitmap.height if height > sprite.bitmap.height
  if usealpha
    spritex = sprite.x - (sprite.ox * sprite.zoom_x)
    spritey = sprite.y - (sprite.oy * sprite.zoom_y)
    width *= sprite.zoom_x
    height *= sprite.zoom_y
  else
    spritex = sprite.x - sprite.ox
    spritey = sprite.y - sprite.oy
    spritex += xwidth / 2
    spritey += xheight / 2
  end
  if !(x >= spritex && x <= spritex + width && y >= spritey && y <= spritey + height)
    return false
  end
  if usealpha
    # TODO: This should account for sprite.angle as well
    bitmapX = sprite.src_rect.x
    bitmapY = sprite.src_rect.y
    bitmapX += sprite.ox
    bitmapY += sprite.oy
    bitmapX += (x - sprite.x) / sprite.zoom_x if sprite.zoom_x > 0
    bitmapY += (y - sprite.y) / sprite.zoom_y if sprite.zoom_y > 0
    bitmapX = bitmapX.round
    bitmapY = bitmapY.round
    if sprite.mirror
      xmirror = bitmapX - sprite.src_rect.x
      bitmapX = sprite.src_rect.x + 192 - xmirror
    end
    color = sprite.bitmap.get_pixel(bitmapX, bitmapY)
    return false if color.alpha == 0
  end
  return true
end

def pbTrackPopupMenu(commands)
  mousepos = Mouse.getMousePos
  return -1 if !mousepos
  menuwindow = Window_Menu.new(commands, mousepos[0], mousepos[1])
  menuwindow.z = 99999
  loop do
    Graphics.update
    Input.update
    menuwindow.update
    hit = menuwindow.hittest
    menuwindow.index = hit if hit >= 0
    if Input.trigger?(Input::MOUSELEFT) || Input.trigger?(Input::MOUSERIGHT) # Left or right button
      menuwindow.dispose
      return hit
    end
    if Input.trigger?(Input::USE)
      hit = menuwindow.index
      menuwindow.dispose
      return hit
    end
    if Input.trigger?(Input::BACK) # Escape
      break
    end
  end
  menuwindow.dispose
  return -1
end



################################################################################
# Sprite sheet scrolling bar
################################################################################
class AnimationWindow < Sprite
  attr_reader :animbitmap
  attr_reader :start
  attr_reader :selected

  NUMFRAMES = 5

  def initialize(x, y, width, height, viewport = nil)
    super(viewport)
    @animbitmap = nil
    @arrows = AnimatedBitmap.new("Graphics/Pictures/arrows")
    self.x = x
    self.y = y
    @start = 0
    @selected = 0
    @contents = Bitmap.new(width, height)
    self.bitmap = @contents
    refresh
  end

  def animbitmap=(val)
    @animbitmap = val
    @start = 0
    refresh
  end

  def selected=(val)
    @selected = val
    refresh
  end

  def dispose
    @contents.dispose
    @arrows.dispose
    @start = 0
    @selected = 0
    @changed = false
    super
  end

  def drawrect(bm, x, y, width, height, color)
    bm.fill_rect(x, y, width, 1, color)
    bm.fill_rect(x, y + height - 1, width, 1, color)
    bm.fill_rect(x, y, 1, height, color)
    bm.fill_rect(x + width - 1, y, 1, height, color)
  end

  def drawborder(bm, x, y, width, height, color)
    bm.fill_rect(x, y, width, 2, color)
    bm.fill_rect(x, y + height - 2, width, 2, color)
    bm.fill_rect(x, y, 2, height, color)
    bm.fill_rect(x + width - 2, y, 2, height, color)
  end

  def refresh
    arrowwidth = @arrows.bitmap.width / 2
    @contents.clear
    @contents.fill_rect(0, 0, @contents.width, @contents.height, Color.new(180, 180, 180))
    @contents.blt(0, 0, @arrows.bitmap, Rect.new(0, 0, arrowwidth, 96))
    @contents.blt(arrowwidth + (NUMFRAMES * 96), 0, @arrows.bitmap,
                  Rect.new(arrowwidth, 0, arrowwidth, 96))
    havebitmap = (self.animbitmap && !self.animbitmap.disposed?)
    if havebitmap
      rect = Rect.new(0, 0, 0, 0)
      rectdst = Rect.new(0, 0, 0, 0)
      x = arrowwidth
      NUMFRAMES.times do |i|
        j = i + @start
        rect.set((j % 5) * 192, (j / 5) * 192, 192, 192)
        rectdst.set(x, 0, 96, 96)
        @contents.stretch_blt(rectdst, self.animbitmap, rect)
        x += 96
      end
    end
    NUMFRAMES.times do |i|
      drawrect(@contents, arrowwidth + (i * 96), 0, 96, 96, Color.new(100, 100, 100))
      if @start + i == @selected && havebitmap
        drawborder(@contents, arrowwidth + (i * 96), 0, 96, 96, Color.new(255, 0, 0))
      end
    end
  end

  def changed?
    return @changed
  end

  def update
    mousepos = Mouse.getMousePos
    @changed = false
    return if !Input.repeat?(Input::MOUSELEFT)
    return if !mousepos
    return if !self.animbitmap
    arrowwidth = @arrows.bitmap.width / 2
    maxindex = (self.animbitmap.height / 192) * 5
    left = Rect.new(0, 0, arrowwidth, 96)
    right = Rect.new(arrowwidth + (NUMFRAMES * 96), 0, arrowwidth, 96)
    left.x += self.x
    left.y += self.y
    right.x += self.x
    right.y += self.y
    swatchrects = []
    repeattime = Input.time?(Input::MOUSELEFT) / 1000
    NUMFRAMES.times do |i|
      swatchrects.push(Rect.new(arrowwidth + (i * 96) + self.x, self.y, 96, 96))
    end
    NUMFRAMES.times do |i|
      next if !swatchrects[i].contains(mousepos[0], mousepos[1])
      @selected = @start + i
      @changed = true
      refresh
      return
    end
    # Left arrow
    if left.contains(mousepos[0], mousepos[1])
      if repeattime > 750
        @start -= 3
      else
        @start -= 1
      end
      @start = 0 if @start < 0
      refresh
    end
    # Right arrow
    if right.contains(mousepos[0], mousepos[1])
      if repeattime > 750
        @start += 3
      else
        @start += 1
      end
      @start = maxindex if @start >= maxindex
      refresh
    end
  end
end



class CanvasAnimationWindow < AnimationWindow
  def animbitmap
    return @canvas.animbitmap
  end

  def initialize(canvas, x, y, width, height, viewport = nil)
    @canvas = canvas
    super(x, y, width, height, viewport)
  end
end



################################################################################
# Cel sprite
################################################################################
class InvalidatableSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @invalid = false
  end

# Marks that the control must be redrawn to reflect current logic.
  def invalidate
    @invalid = true
  end

# Determines whether the control is invalid
  def invalid?
    return @invalid
  end

# Marks that the control is valid.  Normally called only by repaint.
  def validate
    @invalid = false
  end

# Redraws the sprite only if it is invalid, and then revalidates the sprite
  def repaint
    if self.invalid?
      refresh
      validate
    end
  end

 # Redraws the sprite.  This method should not check whether
 # the sprite is invalid, to allow it to be explicitly called.
  def refresh
  end
end



class SpriteFrame < InvalidatableSprite
  attr_reader :id
  attr_reader :locked
  attr_reader :selected
  attr_reader :sprite

  NUM_ROWS = (PBAnimation::MAX_SPRITES.to_f / 10).ceil   # 10 frame number icons in each row

  def initialize(id, sprite, viewport, previous = false)
    super(viewport)
    @id = id
    @sprite = sprite
    @previous = previous
    @locked = false
    @selected = false
    @selcolor = Color.new(0, 0, 0)
    @unselcolor = Color.new(220, 220, 220)
    @prevcolor = Color.new(64, 128, 192)
    @contents = Bitmap.new(64, 64)
    self.z = (@previous) ? 49 : 50
    @iconbitmap = AnimatedBitmap.new("Graphics/Pictures/animFrameIcon")
    self.bitmap = @contents
    self.invalidate
  end

  def dispose
    @contents.dispose
    super
  end

  def sprite=(value)
    @sprite = value
    self.invalidate
  end

  def locked=(value)
    @locked = value
    self.invalidate
  end

  def selected=(value)
    @selected = value
    self.invalidate
  end

  def refresh
    @contents.clear
    self.z = (@previous) ? 49 : (@selected) ? 51 : 50
    # Draw frame
    color = (@previous) ? @prevcolor : (@selected) ? @selcolor : @unselcolor
    @contents.fill_rect(0, 0, 64, 1, color)
    @contents.fill_rect(0, 63, 64, 1, color)
    @contents.fill_rect(0, 0, 1, 64, color)
    @contents.fill_rect(63, 0, 1, 64, color)
    # Determine frame number graphic to use from @iconbitmap
    yoffset = (@previous) ? (NUM_ROWS + 1) * 16 : 0   # 1 is for padlock icon
    bmrect = Rect.new((@id % 10) * 16, yoffset + ((@id / 10) * 16), 16, 16)
    @contents.blt(0, 0, @iconbitmap.bitmap, bmrect)
    # Draw padlock if frame is locked
    if @locked && !@previous
      bmrect = Rect.new(0, NUM_ROWS * 16, 16, 16)
      @contents.blt(16, 0, @iconbitmap.bitmap, bmrect)
    end
  end
end



################################################################################
# Canvas
################################################################################
class AnimationCanvas < Sprite
  attr_reader :viewport
  attr_reader :sprites
  attr_reader :currentframe # Currently active frame
  attr_reader :currentcel
  attr_reader :animation # Currently selected animation
  attr_reader :animbitmap # Currently selected animation bitmap
  attr_accessor :pattern  # Currently selected pattern

  BORDERSIZE = 64

  def initialize(animation, viewport = nil)
    super(viewport)
    @currentframe = 0
    @currentcel = -1
    @pattern = 0
    @sprites = {}
    @celsprites = []
    @framesprites = []
    @lastframesprites = []
    @dirty = []
    @viewport = viewport
    @selecting = false
    @selectOffsetX = 0
    @selectOffsetY = 0
    @playing = false
    @playingframe = 0
    @player = nil
    @battle = MiniBattle.new
    @user = AnimatedBitmap.new("Graphics/Pictures/testback").deanimate
    @target = AnimatedBitmap.new("Graphics/Pictures/testfront").deanimate
    @testscreen = AnimatedBitmap.new("Graphics/Pictures/testscreen")
    self.bitmap = @testscreen.bitmap
    PBAnimation::MAX_SPRITES.times do |i|
      @lastframesprites[i] = SpriteFrame.new(i, @celsprites[i], viewport, true)
      @lastframesprites[i].selected = false
      @lastframesprites[i].visible = false
    end
    PBAnimation::MAX_SPRITES.times do |i|
      @celsprites[i] = Sprite.new(viewport)
      @celsprites[i].visible = false
      @celsprites[i].src_rect = Rect.new(0, 0, 0, 0)
      @celsprites[i].bitmap = nil
      @framesprites[i] = SpriteFrame.new(i, @celsprites[i], viewport)
      @framesprites[i].selected = false
      @framesprites[i].visible = false
      @dirty[i] = true
    end
    loadAnimation(animation)
  end

  def loadAnimation(anim)
    @animation = anim
    @animbitmap&.dispose
    if @animation.graphic == ""
      @animbitmap = nil
    else
      begin
        @animbitmap = AnimatedBitmap.new("Graphics/Animations/" + @animation.graphic,
                                         @animation.hue).deanimate
      rescue
        @animbitmap = nil
      end
    end
    @currentcel = -1
    self.currentframe = 0
    @selecting = false
    @pattern = 0
    self.invalidate
  end

  def animbitmap=(value)
    @animbitmap&.dispose
    @animbitmap = value
    (2...PBAnimation::MAX_SPRITES).each do |i|
      @celsprites[i].bitmap = @animbitmap if @celsprites[i]
    end
    self.invalidate
  end

  def dispose
    @user.dispose
    @target.dispose
    @animbitmap&.dispose
    @selectedbitmap&.dispose
    @celbitmap&.dispose
    self.bitmap&.dispose
    PBAnimation::MAX_SPRITES.times do |i|
      @celsprites[i]&.dispose
    end
    super
  end

  def play(oppmove = false)
    if !@playing
      @sprites["pokemon_0"] = Sprite.new(@viewport)
      @sprites["pokemon_0"].bitmap = @user
      @sprites["pokemon_0"].z = 21
      @sprites["pokemon_1"] = Sprite.new(@viewport)
      @sprites["pokemon_1"].bitmap = @target
      @sprites["pokemon_1"].z = 16
      pbSpriteSetAnimFrame(@sprites["pokemon_0"],
                           pbCreateCel(Battle::Scene::FOCUSUSER_X,
                                       Battle::Scene::FOCUSUSER_Y, -1, 2),
                           @sprites["pokemon_0"], @sprites["pokemon_1"])
      pbSpriteSetAnimFrame(@sprites["pokemon_1"],
                           pbCreateCel(Battle::Scene::FOCUSTARGET_X,
                                       Battle::Scene::FOCUSTARGET_Y, -2, 1),
                           @sprites["pokemon_0"], @sprites["pokemon_1"])
      usersprite = @sprites["pokemon_#{oppmove ? 1 : 0}"]
      targetsprite = @sprites["pokemon_#{oppmove ? 0 : 1}"]
      olduserx = usersprite ? usersprite.x : 0
      oldusery = usersprite ? usersprite.y : 0
      oldtargetx = targetsprite ? targetsprite.x : 0
      oldtargety = targetsprite ? targetsprite.y : 0
      @player = PBAnimationPlayerX.new(@animation,
                                       @battle.battlers[oppmove ? 1 : 0],
                                       @battle.battlers[oppmove ? 0 : 1],
                                       self, oppmove, true)
      @player.setLineTransform(
        Battle::Scene::FOCUSUSER_X, Battle::Scene::FOCUSUSER_Y,
        Battle::Scene::FOCUSTARGET_X, Battle::Scene::FOCUSTARGET_Y,
        olduserx, oldusery,
        oldtargetx, oldtargety
      )
      @player.start
      @playing = true
      @sprites["pokemon_0"].x += BORDERSIZE
      @sprites["pokemon_0"].y += BORDERSIZE
      @sprites["pokemon_1"].x += BORDERSIZE
      @sprites["pokemon_1"].y += BORDERSIZE
      oldstate = []
      PBAnimation::MAX_SPRITES.times do |i|
        oldstate.push([@celsprites[i].visible, @framesprites[i].visible, @lastframesprites[i].visible])
        @celsprites[i].visible = false
        @framesprites[i].visible = false
        @lastframesprites[i].visible = false
      end
      loop do
        Graphics.update
        self.update
        break if !@playing
      end
      PBAnimation::MAX_SPRITES.times do |i|
        @celsprites[i].visible = oldstate[i][0]
        @framesprites[i].visible = oldstate[i][1]
        @lastframesprites[i].visible = oldstate[i][2]
      end
      @sprites["pokemon_0"].dispose
      @sprites["pokemon_1"].dispose
      @player.dispose
      @player = nil
    end
  end

  def invalidate
    PBAnimation::MAX_SPRITES.times do |i|
      invalidateCel(i)
    end
  end

  def invalidateCel(i)
    @dirty[i] = true
  end

  def currentframe=(value)
    @currentframe = value
    invalidate
  end

  def getCurrentFrame
    return nil if @currentframe >= @animation.length
    return @animation[@currentframe]
  end

  def setFrame(i)
    if @celsprites[i]
      @framesprites[i].ox = 32
      @framesprites[i].oy = 32
      @framesprites[i].selected = (i == @currentcel)
      @framesprites[i].locked = self.locked?(i)
      @framesprites[i].x = @celsprites[i].x
      @framesprites[i].y = @celsprites[i].y
      @framesprites[i].visible = @celsprites[i].visible
      @framesprites[i].repaint
    end
  end

  def setPreviousFrame(i)
    if @currentframe > 0
      cel = @animation[@currentframe - 1][i]
      if cel.nil?
        @lastframesprites[i].visible = false
      else
        @lastframesprites[i].ox = 32
        @lastframesprites[i].oy = 32
        @lastframesprites[i].selected = false
        @lastframesprites[i].locked = false
        @lastframesprites[i].x = cel[AnimFrame::X] + 64
        @lastframesprites[i].y = cel[AnimFrame::Y] + 64
        @lastframesprites[i].visible = true
        @lastframesprites[i].repaint
      end
    else
      @lastframesprites[i].visible = false
    end
  end

  def offsetFrame(frame, ox, oy)
    if frame >= 0 && frame < @animation.length
      PBAnimation::MAX_SPRITES.times do |i|
        if !self.locked?(i) && @animation[frame][i]
          @animation[frame][i][AnimFrame::X] += ox
          @animation[frame][i][AnimFrame::Y] += oy
        end
        @dirty[i] = true if frame == @currentframe
      end
    end
  end

  # Clears all items in the frame except locked items
  def clearFrame(frame)
    if frame >= 0 && frame < @animation.length
      PBAnimation::MAX_SPRITES.times do |i|
        if self.deletable?(i)
          @animation[frame][i] = nil
        else
          pbResetCel(@animation[frame][i])
        end
        @dirty[i] = true if frame == @currentframe
      end
    end
  end

  def insertFrame(frame)
    return if frame >= @animation.length
    @animation.insert(frame, @animation[frame].clone)
    self.invalidate
  end

  def copyFrame(src, dst)
    return if dst >= @animation.length
    PBAnimation::MAX_SPRITES.times do |i|
      clonedframe = @animation[src][i]
      clonedframe = clonedframe.clone if clonedframe && clonedframe != true
      @animation[dst][i] = clonedframe
    end
    self.invalidate if dst == @currentframe
  end

  def pasteFrame(frame)
    return if frame < 0 || frame >= @animation.length
    return if Clipboard.typekey != "PBAnimFrame"
    @animation[frame] = Clipboard.data
    self.invalidate if frame == @currentframe
  end

  def deleteFrame(frame)
    return if frame < 0 || frame >= @animation.length || @animation.length <= 1
    self.currentframe -= 1 if frame == @animation.length - 1
    @animation.delete_at(frame)
    @currentcel = -1
    self.invalidate
  end

  # This frame becomes a copy of the previous frame
  def pasteLast
    copyFrame(@currentframe - 1, @currentframe) if @currentframe > 0
  end

  def currentCel
    return nil if @currentcel < 0
    return nil if @currentframe >= @animation.length
    return @animation[@currentframe][@currentcel]
  end

  def pasteCel(x, y)
    return if @currentframe >= @animation.length
    return if Clipboard.typekey != "PBAnimCel"
    PBAnimation::MAX_SPRITES.times do |i|
      next if @animation[@currentframe][i]
      @animation[@currentframe][i] = Clipboard.data
      cel = @animation[@currentframe][i]
      cel[AnimFrame::X] = x
      cel[AnimFrame::Y] = y
      cel[AnimFrame::LOCKED] = 0
      @celsprites[i].bitmap = @user if cel[AnimFrame::PATTERN] == -1
      @celsprites[i].bitmap = @target if cel[AnimFrame::PATTERN] == -2
      @currentcel = i
      break
    end
    invalidate
  end

  def deleteCel(cel)
    return if cel < 0
    return if @currentframe < 0 || @currentframe >= @animation.length
    return if !deletable?(cel)
    @animation[@currentframe][cel] = nil
    @dirty[cel] = true
  end

  def swapCels(cel1, cel2)
    return if cel1 < 0 || cel2 < 0
    return if @currentframe < 0 || @currentframe >= @animation.length
    t = @animation[@currentframe][cel1]
    @animation[@currentframe][cel1] = @animation[@currentframe][cel2]
    @animation[@currentframe][cel2] = t
    @currentcel = cel2
    @dirty[cel1] = true
    @dirty[cel2] = true
  end

  def locked?(celindex)
    cel = @animation[self.currentframe]
    return false if !cel
    cel = cel[celindex]
    return cel ? (cel[AnimFrame::LOCKED] != 0) : false
  end

  def deletable?(celindex)
    cel = @animation[self.currentframe]
    return true if !cel
    cel = cel[celindex]
    return true if !cel
    return false if cel[AnimFrame::LOCKED] != 0
    if cel[AnimFrame::PATTERN] < 0
      count = 0
      pattern = cel[AnimFrame::PATTERN]
      PBAnimation::MAX_SPRITES.times do |i|
        othercel = @animation[self.currentframe][i]
        count += 1 if othercel && othercel[AnimFrame::PATTERN] == pattern
      end
      return false if count <= 1
    end
    return true
  end

  def setBitmap(i, frame)
    if @celsprites[i]
      cel = @animation[frame][i]
      @celsprites[i].bitmap = @animbitmap
      if cel
        @celsprites[i].bitmap = @user if cel[AnimFrame::PATTERN] == -1
        @celsprites[i].bitmap = @target if cel[AnimFrame::PATTERN] == -2
      end
    end
  end

  def setSpriteBitmap(sprite, cel)
    if sprite && !sprite.disposed?
      sprite.bitmap = @animbitmap
      if cel
        sprite.bitmap = @user if cel[AnimFrame::PATTERN] == -1
        sprite.bitmap = @target if cel[AnimFrame::PATTERN] == -2
      end
    end
  end

  def addSprite(x, y)
    return false if @currentframe >= @animation.length
    PBAnimation::MAX_SPRITES.times do |i|
      next if @animation[@currentframe][i]
      @animation[@currentframe][i] = pbCreateCel(x, y, @pattern, @animation.position)
      @dirty[i] = true
      @currentcel = i
      return true
    end
    return false
  end

  def updateInput
    cel = currentCel
    mousepos = Mouse.getMousePos
    if Input.trigger?(Input::MOUSELEFT) && mousepos &&
       pbSpriteHitTest(self, mousepos[0], mousepos[1], false, true)
      selectedcel = -1
      usealpha = Input.press?(Input::ALT)
      PBAnimation::MAX_SPRITES.times do |j|
        if pbSpriteHitTest(@celsprites[j], mousepos[0], mousepos[1], usealpha, false)
          selectedcel = j
        end
      end
      if selectedcel < 0
        if @animbitmap && addSprite(mousepos[0] - BORDERSIZE, mousepos[1] - BORDERSIZE)
          @selecting = true if !self.locked?(@currentcel)
          @selectOffsetX = 0
          @selectOffsetY = 0
          cel = currentCel
          invalidate
        end
      else
        @currentcel = selectedcel
        @selecting = true if !self.locked?(@currentcel)
        cel = currentCel
        @selectOffsetX = cel[AnimFrame::X] - mousepos[0] + BORDERSIZE
        @selectOffsetY = cel[AnimFrame::Y] - mousepos[1] + BORDERSIZE
        invalidate
      end
    end
    currentFrame = getCurrentFrame
    if currentFrame && !@selecting &&
       (Input.triggerex?(:TAB) || Input.repeatex?(:TAB))
      currentFrame.length.times {
        @currentcel += 1
        @currentcel = 0 if @currentcel >= currentFrame.length
        break if currentFrame[@currentcel]
      }
      invalidate
      return
    end
    if cel && @selecting && mousepos
      cel[AnimFrame::X] = mousepos[0] - BORDERSIZE + @selectOffsetX
      cel[AnimFrame::Y] = mousepos[1] - BORDERSIZE + @selectOffsetY
      @dirty[@currentcel] = true
    end
    if !Input.press?(Input::MOUSELEFT) && @selecting
      @selecting = false
    end
    if cel
      if (Input.triggerex?(:DELETE) || Input.repeatex?(:DELETE)) && self.deletable?(@currentcel)
        @animation[@currentframe][@currentcel] = nil
        @dirty[@currentcel] = true
        return
      end
      if Input.triggerex?(:P) || Input.repeatex?(:P)   # Properties
        pbCellProperties(self)
        @dirty[@currentcel] = true
        return
      end
      if Input.triggerex?(:L) || Input.repeatex?(:L)   # Lock
        cel[AnimFrame::LOCKED] = (cel[AnimFrame::LOCKED] == 0) ? 1 : 0
        @dirty[@currentcel] = true
      end
      if Input.triggerex?(:R) || Input.repeatex?(:R)   # Rotate right
        cel[AnimFrame::ANGLE] += 10
        cel[AnimFrame::ANGLE] %= 360
        @dirty[@currentcel] = true
      end
      if Input.triggerex?(:E) || Input.repeatex?(:E)   # Rotate left
        cel[AnimFrame::ANGLE] -= 10
        cel[AnimFrame::ANGLE] %= 360
        @dirty[@currentcel] = true
      end
      if Input.triggerex?(:KP_PLUS) || Input.repeatex?(:KP_PLUS)   # Zoom in
        cel[AnimFrame::ZOOMX] += 10
        cel[AnimFrame::ZOOMX] = 1000 if cel[AnimFrame::ZOOMX] > 1000
        cel[AnimFrame::ZOOMY] += 10
        cel[AnimFrame::ZOOMY] = 1000 if cel[AnimFrame::ZOOMY] > 1000
        @dirty[@currentcel] = true
      end
      if Input.triggerex?(:KP_MINUS) || Input.repeatex?(:KP_MINUS)   # Zoom out
        cel[AnimFrame::ZOOMX] -= 10
        cel[AnimFrame::ZOOMX] = 10 if cel[AnimFrame::ZOOMX] < 10
        cel[AnimFrame::ZOOMY] -= 10
        cel[AnimFrame::ZOOMY] = 10 if cel[AnimFrame::ZOOMY] < 10
        @dirty[@currentcel] = true
      end
      if !self.locked?(@currentcel)
        if Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
          increment = (Input.press?(Input::ALT)) ? 1 : 8
          cel[AnimFrame::Y] -= increment
          @dirty[@currentcel] = true
        end
        if Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
          increment = (Input.press?(Input::ALT)) ? 1 : 8
          cel[AnimFrame::Y] += increment
          @dirty[@currentcel] = true
        end
        if Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
          increment = (Input.press?(Input::ALT)) ? 1 : 8
          cel[AnimFrame::X] -= increment
          @dirty[@currentcel] = true
        end
        if Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
          increment = (Input.press?(Input::ALT)) ? 1 : 8
          cel[AnimFrame::X] += increment
          @dirty[@currentcel] = true
        end
      end
    end
  end

  def update
    super
    if @playing
      if @player.animDone?
        @playing = false
        invalidate
      else
        @player.update
      end
      return
    end
    updateInput
#    @testscreen.update
#    self.bitmap=@testscreen.bitmap
    if @currentframe < @animation.length
      PBAnimation::MAX_SPRITES.times do |i|
        next if !@dirty[i]
        if @celsprites[i]
          setBitmap(i, @currentframe)
          pbSpriteSetAnimFrame(@celsprites[i], @animation[@currentframe][i], @celsprites[0], @celsprites[1], true)
          @celsprites[i].x += BORDERSIZE
          @celsprites[i].y += BORDERSIZE
        end
        setPreviousFrame(i)
        setFrame(i)
        @dirty[i] = false
      end
    else
      PBAnimation::MAX_SPRITES.times do |i|
        pbSpriteSetAnimFrame(@celsprites[i], nil, @celsprites[0], @celsprites[1], true)
        @celsprites[i].x += BORDERSIZE
        @celsprites[i].y += BORDERSIZE
        setPreviousFrame(i)
        setFrame(i)
        @dirty[i] = false
      end
    end
  end
end



################################################################################
# Window classes
################################################################################
class BitmapDisplayWindow < SpriteWindow_Base
  attr_reader :bitmapname
  attr_reader :hue

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @bitmapname = ""
    @hue = 0
    self.contents = Bitmap.new(width - 32, height - 32)
  end

  def bitmapname=(value)
    if @bitmapname != value
      @bitmapname = value
      refresh
    end
  end

  def hue=(value)
    if @hue != value
      @hue = value
      refresh
    end
  end

  def refresh
    self.contents.clear
    bmap = AnimatedBitmap.new("Graphics/Animations/" + @bitmapname, @hue).deanimate
    return if !bmap
    ww = bmap.width
    wh = bmap.height
    sx = self.contents.width / ww.to_f
    sy = self.contents.height / wh.to_f
    if sx > sy
      ww = sy * ww
      wh = self.contents.height
    else
      wh = sx * wh
      ww = self.contents.width
    end
    dest = Rect.new((self.contents.width - ww) / 2,
                    (self.contents.height - wh) / 2,
                    ww, wh)
    src = Rect.new(0, 0, bmap.width, bmap.height)
    self.contents.stretch_blt(dest, bmap, src)
    bmap.dispose
  end
end



class AnimationNameWindow
  def initialize(canvas, x, y, width, height, viewport = nil)
    @canvas = canvas
    @oldname = nil
    @window = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Name: {1}", @canvas.animation.name), x, y, width, height, viewport
    )
  end

  def viewport=(value); @window.viewport = value; end

  def update
    newtext = _INTL("Name: {1}", @canvas.animation.name)
    if @oldname != newtext
      @window.text = newtext
      @oldname = newtext
    end
    @window.update
  end

  def refresh; @window.refresh; end
  def dispose; @window.dispose; end
  def disposed; @window.disposed?; end
end
