#===============================================================================
#
#===============================================================================
class AnimFrame
  X          = 0
  Y          = 1
  ZOOMX      = 2
  ANGLE      = 3
  MIRROR     = 4
  BLENDTYPE  = 5
  VISIBLE    = 6
  PATTERN    = 7
  OPACITY    = 8
  ZOOMY      = 11
  COLORRED   = 12
  COLORGREEN = 13
  COLORBLUE  = 14
  COLORALPHA = 15
  TONERED    = 16
  TONEGREEN  = 17
  TONEBLUE   = 18
  TONEGRAY   = 19
  LOCKED     = 20
  FLASHRED   = 21
  FLASHGREEN = 22
  FLASHBLUE  = 23
  FLASHALPHA = 24
  PRIORITY   = 25
  FOCUS      = 26
end



#===============================================================================
#
#===============================================================================
def yaxisIntersect(x1, y1, x2, y2, px, py)
  dx = x2 - x1
  dy = y2 - y1
  x = (dx == 0) ? 0.0 : (px - x1).to_f / dx
  y = (dy == 0) ? 0.0 : (py - y1).to_f / dy
  return [x, y]
end

def repositionY(x1, y1, x2, y2, tx, ty)
  dx = x2 - x1
  dy = y2 - y1
  x = x1 + (tx * dx.to_f)
  y = y1 + (ty * dy.to_f)
  return [x, y]
end

def transformPoint(x1, y1, x2, y2,  # Source line
                   x3, y3, x4, y4,  # Destination line
                   px, py)        # Source point
  ret = yaxisIntersect(x1, y1, x2, y2, px, py)
  ret2 = repositionY(x3, y3, x4, y4, ret[0], ret[1])
  return ret2
end

def getSpriteCenter(sprite)
  return [0, 0] if !sprite || sprite.disposed?
  return [sprite.x, sprite.y] if !sprite.bitmap || sprite.bitmap.disposed?
  centerX = sprite.src_rect.width / 2
  centerY = sprite.src_rect.height / 2
  offsetX = (centerX - sprite.ox) * sprite.zoom_x
  offsetY = (centerY - sprite.oy) * sprite.zoom_y
  return [sprite.x + offsetX, sprite.y + offsetY]
end

def isReversed(src0, src1, dst0, dst1)
  return false if src0 == src1
  return (dst0 > dst1) if src0 < src1
  return (dst0 < dst1)
end

def pbCreateCel(x, y, pattern, focus = 4)
  frame = []
  frame[AnimFrame::X]       = x
  frame[AnimFrame::Y]       = y
  frame[AnimFrame::PATTERN] = pattern
  frame[AnimFrame::FOCUS]   = focus   # 1=target, 2=user, 3=user and target, 4=screen
  frame[AnimFrame::LOCKED]  = 0
  pbResetCel(frame)
  return frame
end

def pbResetCel(frame)
  return if !frame
  frame[AnimFrame::ZOOMX]      = 100
  frame[AnimFrame::ZOOMY]      = 100
  frame[AnimFrame::BLENDTYPE]  = 0
  frame[AnimFrame::VISIBLE]    = 1
  frame[AnimFrame::ANGLE]      = 0
  frame[AnimFrame::MIRROR]     = 0
  frame[AnimFrame::OPACITY]    = 255
  frame[AnimFrame::COLORRED]   = 0
  frame[AnimFrame::COLORGREEN] = 0
  frame[AnimFrame::COLORBLUE]  = 0
  frame[AnimFrame::COLORALPHA] = 0
  frame[AnimFrame::TONERED]    = 0
  frame[AnimFrame::TONEGREEN]  = 0
  frame[AnimFrame::TONEBLUE]   = 0
  frame[AnimFrame::TONEGRAY]   = 0
  frame[AnimFrame::FLASHRED]   = 0
  frame[AnimFrame::FLASHGREEN] = 0
  frame[AnimFrame::FLASHBLUE]  = 0
  frame[AnimFrame::FLASHALPHA] = 0
  frame[AnimFrame::PRIORITY]   = 1   # 0=back, 1=front, 2=behind focus, 3=before focus
end

#===============================================================================
#
#===============================================================================
def pbConvertRPGAnimation(animation)
  pbAnim = PBAnimation.new
  pbAnim.id       = animation.id
  pbAnim.name     = animation.name.clone
  pbAnim.graphic  = animation.animation_name
  pbAnim.hue      = animation.animation_hue
  pbAnim.array.clear
  yOffset = 0
  pbAnim.position = animation.position
  yOffset = -64 if animation.position == 0
  yOffset = 64 if animation.position == 2
  animation.frames.length.times do |i|
    frame = pbAnim.addFrame
    animFrame = animation.frames[i]
    animFrame.cell_max.times do |j|
      data = animFrame.cell_data
      if data[j, 0] == -1
        frame.push(nil)
        next
      end
      if animation.position == 3   # Screen
        point = transformPoint(
          -160, 80, 160, -80,
          Battle::Scene::FOCUSUSER_X, Battle::Scene::FOCUSUSER_Y,
          Battle::Scene::FOCUSTARGET_X, Battle::Scene::FOCUSTARGET_Y,
          data[j, 1], data[j, 2]
        )
        cel = pbCreateCel(point[0], point[1], data[j, 0])
      else
        cel = pbCreateCel(data[j, 1], data[j, 2] + yOffset, data[j, 0])
      end
      cel[AnimFrame::ZOOMX]     = data[j, 3]
      cel[AnimFrame::ZOOMY]     = data[j, 3]
      cel[AnimFrame::ANGLE]     = data[j, 4]
      cel[AnimFrame::MIRROR]    = data[j, 5]
      cel[AnimFrame::OPACITY]   = data[j, 6]
      cel[AnimFrame::BLENDTYPE] = 0
      frame.push(cel)
    end
  end
  animation.timings.each do |timing|
    newTiming = PBAnimTiming.new
    newTiming.frame         = timing.frame
    newTiming.name          = timing.se.name
    newTiming.volume        = timing.se.volume
    newTiming.pitch         = timing.se.pitch
    newTiming.flashScope    = timing.flash_scope
    newTiming.flashColor    = timing.flash_color.clone
    newTiming.flashDuration = timing.flash_duration
    pbAnim.timing.push(newTiming)
  end
  return pbAnim
end



#===============================================================================
#
#===============================================================================
class RPG::Animation
  def self.fromOther(otherAnim, id)
    ret = RPG::Animation.new
    ret.id             = id
    ret.name           = otherAnim.name.clone
    ret.animation_name = otherAnim.animation_name.clone
    ret.animation_hue  = otherAnim.animation_hue
    ret.position       = otherAnim.position
    return ret
  end

  def addSound(frame, se)
    timing = RPG::Animation::Timing.new
    timing.frame = frame
    timing.se    = RPG::AudioFile.new(se, 100)
    self.timings.push(timing)
  end

  def addAnimation(otherAnim, frame, x, y)   # frame is zero-based
    if frame + otherAnim.frames.length >= self.frames.length
      totalframes = frame + otherAnim.frames.length + 1
      (totalframes - self.frames.length).times do
        self.frames.push(RPG::Animation::Frame.new)
      end
    end
    self.frame_max = self.frames.length
    otherAnim.frame_max.times do |i|
      thisframe = self.frames[frame + i]
      otherframe = otherAnim.frames[i]
      cellStart = thisframe.cell_max
      thisframe.cell_max += otherframe.cell_max
      thisframe.cell_data.resize(thisframe.cell_max, 8)
      otherframe.cell_max.times do |j|
        thisframe.cell_data[cellStart + j, 0] = otherframe.cell_data[j, 0]
        thisframe.cell_data[cellStart + j, 1] = otherframe.cell_data[j, 1] + x
        thisframe.cell_data[cellStart + j, 2] = otherframe.cell_data[j, 2] + y
        thisframe.cell_data[cellStart + j, 3] = otherframe.cell_data[j, 3]
        thisframe.cell_data[cellStart + j, 4] = otherframe.cell_data[j, 4]
        thisframe.cell_data[cellStart + j, 5] = otherframe.cell_data[j, 5]
        thisframe.cell_data[cellStart + j, 6] = otherframe.cell_data[j, 6]
        thisframe.cell_data[cellStart + j, 7] = otherframe.cell_data[j, 7]
      end
    end
    otherAnim.timings.each do |othertiming|
      timing = RPG::Animation::Timing.new
      timing.frame          = frame + othertiming.frame
      timing.se             = RPG::AudioFile.new(othertiming.se.name.clone,
                                                 othertiming.se.volume,
                                                 othertiming.se.pitch)
      timing.flash_scope    = othertiming.flash_scope
      timing.flash_color    = othertiming.flash_color.clone
      timing.flash_duration = othertiming.flash_duration
      timing.condition      = othertiming.condition
      self.timings.push(timing)
    end
    self.timings.sort! { |a, b| a.frame <=> b.frame }
  end
end



#===============================================================================
#
#===============================================================================
class PBAnimTiming
  attr_accessor :frame
  attr_writer   :timingType   # 0=play SE, 1=set bg, 2=bg mod
  attr_accessor :name         # Name of SE file or BG file
  attr_accessor :volume
  attr_accessor :pitch
  attr_accessor :bgX          # x coordinate of bg (or to move bg to)
  attr_accessor :bgY          # y coordinate of bg (or to move bg to)
  attr_accessor :opacity      # Opacity of bg (or to change bg to)
  attr_accessor :colorRed     # Color of bg (or to change bg to)
  attr_accessor :colorGreen   # Color of bg (or to change bg to)
  attr_accessor :colorBlue    # Color of bg (or to change bg to)
  attr_accessor :colorAlpha   # Color of bg (or to change bg to)
  attr_writer   :duration     # How long to spend changing to the new bg coords/color
  attr_accessor :flashScope
  attr_accessor :flashColor
  attr_accessor :flashDuration

  def initialize(type = 0)
    @frame         = 0
    @timingType    = type
    @name          = ""
    @volume        = 80
    @pitch         = 100
    @bgX           = nil
    @bgY           = nil
    @opacity       = nil
    @colorRed      = nil
    @colorGreen    = nil
    @colorBlue     = nil
    @colorAlpha    = nil
    @duration      = 5
    @flashScope    = 0
    @flashColor    = Color.new(255, 255, 255, 255)
    @flashDuration = 5
  end

  def timingType
    return @timingType || 0
  end

  def duration
    return @duration || 5
  end

  def to_s
    case self.timingType
    when 0
      return "[#{@frame + 1}] Play SE: #{name} (volume #{@volume}, pitch #{@pitch})"
    when 1
      text = sprintf("[%d] Set BG: \"%s\"", @frame + 1, name)
      text += sprintf(" (color=%s,%s,%s,%s)",
                      @colorRed || "-",
                      @colorGreen || "-",
                      @colorBlue || "-",
                      @colorAlpha || "-")
      text += sprintf(" (opacity=%d)", @opacity)
      text += sprintf(" (coords=%s,%s)", @bgX || "-", @bgY || "-")
      return text
    when 2
      text = sprintf("[%d] Change BG: @%d", @frame + 1, duration)
      if @colorRed || @colorGreen || @colorBlue || @colorAlpha
        text += sprintf(" (color=%s,%s,%s,%s)",
                        @colorRed || "-",
                        @colorGreen || "-",
                        @colorBlue || "-",
                        @colorAlpha || "-")
      end
      text += sprintf(" (opacity=%d)", @opacity) if @opacity
      text += sprintf(" (coords=%s,%s)", @bgX || "-", @bgY || "-") if @bgX || @bgY
      return text
    when 3
      text = sprintf("[%d] Set FG: \"%s\"", @frame + 1, name)
      text += sprintf(" (color=%s,%s,%s,%s)",
                      @colorRed || "-",
                      @colorGreen | "-",
                      @colorBlue || "-",
                      @colorAlpha || "-")
      text += sprintf(" (opacity=%d)", @opacity)
      text += sprintf(" (coords=%s,%s)", @bgX || "-", @bgY || "-")
      return text
    when 4
      text = sprintf("[%d] Change FG: @%d", @frame + 1, duration)
      if @colorRed || @colorGreen || @colorBlue || @colorAlpha
        text += sprintf(" (color=%s,%s,%s,%s)",
                        @colorRed || "-",
                        @colorGreen || "-",
                        @colorBlue || "-",
                        @colorAlpha || "-")
      end
      text += sprintf(" (opacity=%d)", @opacity) if @opacity
      text += sprintf(" (coords=%s,%s)", @bgX || "-", @bgY || "-") if @bgX || @bgY
      return text
    end
    return ""
  end
end



#===============================================================================
#
#===============================================================================
class PBAnimations < Array
  include Enumerable
  attr_reader   :array
  attr_accessor :selected

  def initialize(size = 1)
    @array = []
    @selected = 0
    size = 1 if size < 1   # Always create at least one animation
    size.times do
      @array.push(PBAnimation.new)
    end
  end

  def length
    return @array.length
  end

  def each
    @array.each { |i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def get_from_name(name)
    @array.each { |i| return i if i&.name == name }
    return nil
  end

  def compact
    @array.compact!
  end

  def insert(index, val)
    @array.insert(index, val)
  end

  def delete_at(index)
    @array.delete_at(index)
  end

  def resize(len)
    idxStart = @array.length
    idxEnd   = len
    if idxStart > idxEnd
      (idxStart - idxEnd).times { @array.pop }
    else
      (idxEnd - idxStart).times { @array.push(PBAnimation.new) }
    end
    self.selected = len if self.selected >= len
  end
end



#===============================================================================
#
#===============================================================================
class PBAnimation < Array
  include Enumerable
  attr_accessor :id
  attr_accessor :name
  attr_accessor :graphic
  attr_accessor :hue
  attr_accessor :position
  attr_writer   :speed
  attr_reader   :array
  attr_reader   :timing

  MAX_SPRITES = 60

  def speed
    return @speed || 20
  end

  def initialize(size = 1)
    @id       = -1
    @name     = ""
    @graphic  = ""
    @hue      = 0
    @position = 4             # 1=target, 2=user, 3=user and target, 4=screen
    @array    = []
    size      = 1 if size < 1   # Always create at least one frame
    size.times { addFrame }
    @timing   = []
    @scope    = 0
  end

  def length
    return @array.length
  end

  def each
    @array.each { |i| yield i }
  end

  def [](i)
    return @array[i]
  end

  def []=(i, value)
    @array[i] = value
  end

  def insert(*arg)
    return @array.insert(*arg)
  end

  def delete_at(*arg)
    return @array.delete_at(*arg)
  end

  def resize(len)
    if len < @array.length
      @array[len, @array.length - len] = []
    elsif len > @array.length
      (len - @array.length).times do
        addFrame
      end
    end
  end

  def addFrame
    pos = @array.length
    @array[pos] = []
    # Move's user
    @array[pos][0] = pbCreateCel(Battle::Scene::FOCUSUSER_X, Battle::Scene::FOCUSUSER_Y, -1)
    @array[pos][0][AnimFrame::FOCUS]  = 2
    @array[pos][0][AnimFrame::LOCKED] = 1
    # Move's target
    @array[pos][1] = pbCreateCel(Battle::Scene::FOCUSTARGET_X, Battle::Scene::FOCUSTARGET_Y, -2)
    @array[pos][1][AnimFrame::FOCUS]  = 1
    @array[pos][1][AnimFrame::LOCKED] = 1
    return @array[pos]
  end

  def playTiming(frame, bgGraphic, bgColor, foGraphic, foColor, oldbg = [], oldfo = [], user = nil)
    @timing.each do |i|
      next if i.frame != frame
      case i.timingType
      when 0   # Play SE
        if i.name && i.name != ""
          pbSEPlay("Anim/" + i.name, i.volume, i.pitch)
        elsif user&.pokemon
          name = GameData::Species.cry_filename_from_pokemon(user.pokemon)
          pbSEPlay(name, i.volume, i.pitch) if name
        end
#        if sprite
#          sprite.flash(i.flashColor, i.flashDuration * 2) if i.flashScope == 1
#          sprite.flash(nil, i.flashDuration * 2) if i.flashScope == 3
#        end
      when 1   # Set background graphic (immediate)
        if i.name && i.name != ""
          bgGraphic.setBitmap("Graphics/Animations/" + i.name)
          bgGraphic.ox      = -i.bgX || 0
          bgGraphic.oy      = -i.bgY || 0
          bgGraphic.color   = Color.new(i.colorRed || 0, i.colorGreen || 0, i.colorBlue || 0, i.colorAlpha || 0)
          bgGraphic.opacity = i.opacity || 0
          bgColor.opacity = 0
        else
          bgGraphic.setBitmap(nil)
          bgGraphic.opacity = 0
          bgColor.color   = Color.new(i.colorRed || 0, i.colorGreen || 0, i.colorBlue || 0, i.colorAlpha || 0)
          bgColor.opacity = i.opacity || 0
        end
      when 2   # Move/recolour background graphic
        if bgGraphic.bitmap.nil?
          oldbg[0] = 0
          oldbg[1] = 0
          oldbg[2] = bgColor.opacity || 0
          oldbg[3] = bgColor.color.clone || Color.new(0, 0, 0, 0)
        else
          oldbg[0] = bgGraphic.ox || 0
          oldbg[1] = bgGraphic.oy || 0
          oldbg[2] = bgGraphic.opacity || 0
          oldbg[3] = bgGraphic.color.clone || Color.new(0, 0, 0, 0)
        end
      when 3   # Set foreground graphic (immediate)
        if i.name && i.name != ""
          foGraphic.setBitmap("Graphics/Animations/" + i.name)
          foGraphic.ox      = -i.bgX || 0
          foGraphic.oy      = -i.bgY || 0
          foGraphic.color   = Color.new(i.colorRed || 0, i.colorGreen || 0, i.colorBlue || 0, i.colorAlpha || 0)
          foGraphic.opacity = i.opacity || 0
          foColor.opacity = 0
        else
          foGraphic.setBitmap(nil)
          foGraphic.opacity = 0
          foColor.color   = Color.new(i.colorRed || 0, i.colorGreen || 0, i.colorBlue || 0, i.colorAlpha || 0)
          foColor.opacity = i.opacity || 0
        end
      when 4   # Move/recolour foreground graphic
        if foGraphic.bitmap.nil?
          oldfo[0] = 0
          oldfo[1] = 0
          oldfo[2] = foColor.opacity || 0
          oldfo[3] = foColor.color.clone || Color.new(0, 0, 0, 0)
        else
          oldfo[0] = foGraphic.ox || 0
          oldfo[1] = foGraphic.oy || 0
          oldfo[2] = foGraphic.opacity || 0
          oldfo[3] = foGraphic.color.clone || Color.new(0, 0, 0, 0)
        end
      end
    end
    @timing.each do |i|
      case i.timingType
      when 2
        next if !i.duration || i.duration <= 0
        next if frame < i.frame || frame > i.frame + i.duration
        fraction = (frame - i.frame).to_f / i.duration
        if bgGraphic.bitmap.nil?
          bgColor.opacity = oldbg[2] + ((i.opacity - oldbg[2]) * fraction) if i.opacity
          cr = (i.colorRed) ? oldbg[3].red + ((i.colorRed - oldbg[3].red) * fraction) : oldbg[3].red
          cg = (i.colorGreen) ? oldbg[3].green + ((i.colorGreen - oldbg[3].green) * fraction) : oldbg[3].green
          cb = (i.colorBlue) ? oldbg[3].blue + ((i.colorBlue - oldbg[3].blue) * fraction) : oldbg[3].blue
          ca = (i.colorAlpha) ? oldbg[3].alpha + ((i.colorAlpha - oldbg[3].alpha) * fraction) : oldbg[3].alpha
          bgColor.color = Color.new(cr, cg, cb, ca)
        else
          bgGraphic.ox      = oldbg[0] - ((i.bgX - oldbg[0]) * fraction) if i.bgX
          bgGraphic.oy      = oldbg[1] - ((i.bgY - oldbg[1]) * fraction) if i.bgY
          bgGraphic.opacity = oldbg[2] + ((i.opacity - oldbg[2]) * fraction) if i.opacity
          cr = (i.colorRed) ? oldbg[3].red + ((i.colorRed - oldbg[3].red) * fraction) : oldbg[3].red
          cg = (i.colorGreen) ? oldbg[3].green + ((i.colorGreen - oldbg[3].green) * fraction) : oldbg[3].green
          cb = (i.colorBlue) ? oldbg[3].blue + ((i.colorBlue - oldbg[3].blue) * fraction) : oldbg[3].blue
          ca = (i.colorAlpha) ? oldbg[3].alpha + ((i.colorAlpha - oldbg[3].alpha) * fraction) : oldbg[3].alpha
          bgGraphic.color = Color.new(cr, cg, cb, ca)
        end
      when 4
        next if !i.duration || i.duration <= 0
        next if frame < i.frame || frame > i.frame + i.duration
        fraction = (frame - i.frame).to_f / i.duration
        if foGraphic.bitmap.nil?
          foColor.opacity = oldfo[2] + ((i.opacity - oldfo[2]) * fraction) if i.opacity
          cr = (i.colorRed) ? oldfo[3].red + ((i.colorRed - oldfo[3].red) * fraction) : oldfo[3].red
          cg = (i.colorGreen) ? oldfo[3].green + ((i.colorGreen - oldfo[3].green) * fraction) : oldfo[3].green
          cb = (i.colorBlue) ? oldfo[3].blue + ((i.colorBlue - oldfo[3].blue) * fraction) : oldfo[3].blue
          ca = (i.colorAlpha) ? oldfo[3].alpha + ((i.colorAlpha - oldfo[3].alpha) * fraction) : oldfo[3].alpha
          foColor.color = Color.new(cr, cg, cb, ca)
        else
          foGraphic.ox      = oldfo[0] - ((i.bgX - oldfo[0]) * fraction) if i.bgX
          foGraphic.oy      = oldfo[1] - ((i.bgY - oldfo[1]) * fraction) if i.bgY
          foGraphic.opacity = oldfo[2] + ((i.opacity - oldfo[2]) * fraction) if i.opacity
          cr = (i.colorRed) ? oldfo[3].red + ((i.colorRed - oldfo[3].red) * fraction) : oldfo[3].red
          cg = (i.colorGreen) ? oldfo[3].green + ((i.colorGreen - oldfo[3].green) * fraction) : oldfo[3].green
          cb = (i.colorBlue) ? oldfo[3].blue + ((i.colorBlue - oldfo[3].blue) * fraction) : oldfo[3].blue
          ca = (i.colorAlpha) ? oldfo[3].alpha + ((i.colorAlpha - oldfo[3].alpha) * fraction) : oldfo[3].alpha
          foGraphic.color = Color.new(cr, cg, cb, ca)
        end
      end
    end
  end
end



#===============================================================================
#
#===============================================================================
def pbSpriteSetAnimFrame(sprite, frame, user = nil, target = nil, inEditor = false)
  return if !sprite
  if !frame
    sprite.visible  = false
    sprite.src_rect = Rect.new(0, 0, 1, 1)
    return
  end
  sprite.blend_type = frame[AnimFrame::BLENDTYPE]
  sprite.angle      = frame[AnimFrame::ANGLE]
  sprite.mirror     = (frame[AnimFrame::MIRROR] > 0)
  sprite.opacity    = frame[AnimFrame::OPACITY]
  sprite.visible    = true
  if !frame[AnimFrame::VISIBLE] == 1 && inEditor
    sprite.opacity /= 2
  else
    sprite.visible = (frame[AnimFrame::VISIBLE] == 1)
  end
  pattern = frame[AnimFrame::PATTERN]
  if pattern >= 0
    animwidth = 192
    sprite.src_rect.set((pattern % 5) * animwidth, (pattern / 5) * animwidth,
                        animwidth, animwidth)
  else
    sprite.src_rect.set(0, 0,
                        (sprite.bitmap) ? sprite.bitmap.width : 128,
                        (sprite.bitmap) ? sprite.bitmap.height : 128)
  end
  sprite.zoom_x = frame[AnimFrame::ZOOMX] / 100.0
  sprite.zoom_y = frame[AnimFrame::ZOOMY] / 100.0
  sprite.color.set(
    frame[AnimFrame::COLORRED],
    frame[AnimFrame::COLORGREEN],
    frame[AnimFrame::COLORBLUE],
    frame[AnimFrame::COLORALPHA]
  )
  sprite.tone.set(
    frame[AnimFrame::TONERED],
    frame[AnimFrame::TONEGREEN],
    frame[AnimFrame::TONEBLUE],
    frame[AnimFrame::TONEGRAY]
  )
  sprite.ox = sprite.src_rect.width / 2
  sprite.oy = sprite.src_rect.height / 2
  sprite.x  = frame[AnimFrame::X]
  sprite.y  = frame[AnimFrame::Y]
  if sprite != user && sprite != target
    case frame[AnimFrame::PRIORITY]
    when 0   # Behind everything
      sprite.z = 10
    when 1   # In front of everything
      sprite.z = 80
    when 2   # Just behind focus
      case frame[AnimFrame::FOCUS]
      when 1   # Focused on target
        sprite.z = (target) ? target.z - 1 : 20
      when 2   # Focused on user
        sprite.z = (user) ? user.z - 1 : 20
      else     # Focused on user and target, or screen
        sprite.z = 20
      end
    when 3   # Just in front of focus
      case frame[AnimFrame::FOCUS]
      when 1   # Focused on target
        sprite.z = (target) ? target.z + 1 : 80
      when 2   # Focused on user
        sprite.z = (user) ? user.z + 1 : 80
      else     # Focused on user and target, or screen
        sprite.z = 80
      end
    else
      sprite.z = 80
    end
  end
end



#===============================================================================
# Animation player
#===============================================================================
class PBAnimationPlayerX
  attr_accessor :looping

  MAX_SPRITES = 60

  def initialize(animation, user, target, scene = nil, oppMove = false, inEditor = false)
    @animation     = animation
    @user          = (oppMove) ? target : user   # Just used for playing user's cry
    @usersprite    = (user) ? scene.sprites["pokemon_#{user.index}"] : nil
    @targetsprite  = (target) ? scene.sprites["pokemon_#{target.index}"] : nil
    @userbitmap    = @usersprite&.bitmap # not to be disposed
    @targetbitmap  = @targetsprite&.bitmap # not to be disposed
    @scene         = scene
    @viewport      = scene&.viewport
    @inEditor      = inEditor
    @looping       = false
    @animbitmap    = nil   # Animation sheet graphic
    @frame         = -1
    @framesPerTick = [Graphics.frame_rate / 20, 1].max   # 20 ticks per second
    @srcLine       = nil
    @dstLine       = nil
    @userOrig      = getSpriteCenter(@usersprite)
    @targetOrig    = getSpriteCenter(@targetsprite)
    @oldbg         = []
    @oldfo         = []
    initializeSprites
  end

  def initializeSprites
    # Create animation sprites (0=user's sprite, 1=target's sprite)
    @animsprites = []
    @animsprites[0] = @usersprite
    @animsprites[1] = @targetsprite
    (2...MAX_SPRITES).each do |i|
      @animsprites[i] = Sprite.new(@viewport)
      @animsprites[i].bitmap  = nil
      @animsprites[i].visible = false
    end
    # Create background colour sprite
    @bgColor = ColoredPlane.new(Color.new(0, 0, 0), @viewport)
    @bgColor.z       = 5
    @bgColor.opacity = 0
    @bgColor.refresh
    # Create background graphic sprite
    @bgGraphic = AnimatedPlane.new(@viewport)
    @bgGraphic.setBitmap(nil)
    @bgGraphic.z       = 5
    @bgGraphic.opacity = 0
    @bgGraphic.refresh
    # Create foreground colour sprite
    @foColor = ColoredPlane.new(Color.new(0, 0, 0), @viewport)
    @foColor.z       = 85
    @foColor.opacity = 0
    @foColor.refresh
    # Create foreground graphic sprite
    @foGraphic = AnimatedPlane.new(@viewport)
    @foGraphic.setBitmap(nil)
    @foGraphic.z       = 85
    @foGraphic.opacity = 0
    @foGraphic.refresh
  end

  def dispose
    @animbitmap&.dispose
    (2...MAX_SPRITES).each do |i|
      @animsprites[i]&.dispose
    end
    @bgGraphic.dispose
    @bgColor.dispose
    @foGraphic.dispose
    @foColor.dispose
  end

  # Makes the original user and target sprites be uninvolved with the animation.
  # The animation shows just its particles.
  def discard_user_and_target_sprites
    @animsprites[0] = nil
    @animsprites[1] = nil
  end

  def set_target_origin(x, y)
    @targetOrig = [x, y]
  end

  def start
    @frame = 0
  end

  def animDone?
    return @frame < 0
  end

  def setLineTransform(x1, y1, x2, y2, x3, y3, x4, y4)
    @srcLine = [x1, y1, x2, y2]
    @dstLine = [x3, y3, x4, y4]
  end

  def update
    return if @frame < 0
    animFrame = @frame / @framesPerTick

    # Loop or end the animation if the animation has reached the end
    if animFrame >= @animation.length
      @frame = (@looping) ? 0 : -1
      if @frame < 0
        @animbitmap&.dispose
        @animbitmap = nil
        return
      end
    end
    # Load the animation's spritesheet and assign it to all the sprites.
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap = AnimatedBitmap.new("Graphics/Animations/" + @animation.graphic,
                                       @animation.hue).deanimate
      MAX_SPRITES.times do |i|
        @animsprites[i].bitmap = @animbitmap if @animsprites[i]
      end
    end
    # Update background and foreground graphics
    @bgGraphic.update
    @bgColor.update
    @foGraphic.update
    @foColor.update

    # Update all the sprites to depict the animation's next frame
    if @framesPerTick == 1 || (@frame % @framesPerTick) == 0
      thisframe = @animation[animFrame]
      # Make all cel sprites invisible
      MAX_SPRITES.times do |i|
        @animsprites[i].visible = false if @animsprites[i]
      end
      # Set each cel sprite acoordingly
      thisframe.length.times do |i|
        cel = thisframe[i]
        next if !cel
        sprite = @animsprites[i]
        next if !sprite
        # Set cel sprite's graphic
        case cel[AnimFrame::PATTERN]
        when -1
          sprite.bitmap = @userbitmap
        when -2
          sprite.bitmap = @targetbitmap
        else
          sprite.bitmap = @animbitmap
        end
        # Apply settings to the cel sprite
        pbSpriteSetAnimFrame(sprite, cel, @usersprite, @targetsprite)
        case cel[AnimFrame::FOCUS]
        when 1   # Focused on target
          sprite.x = cel[AnimFrame::X] + @targetOrig[0] - Battle::Scene::FOCUSTARGET_X
          sprite.y = cel[AnimFrame::Y] + @targetOrig[1] - Battle::Scene::FOCUSTARGET_Y
        when 2   # Focused on user
          sprite.x = cel[AnimFrame::X] + @userOrig[0] - Battle::Scene::FOCUSUSER_X
          sprite.y = cel[AnimFrame::Y] + @userOrig[1] - Battle::Scene::FOCUSUSER_Y
        when 3   # Focused on user and target
          next if !@srcLine || !@dstLine
          point = transformPoint(@srcLine[0], @srcLine[1], @srcLine[2], @srcLine[3],
                                 @dstLine[0], @dstLine[1], @dstLine[2], @dstLine[3],
                                 sprite.x, sprite.y)
          sprite.x = point[0]
          sprite.y = point[1]
          if isReversed(@srcLine[0], @srcLine[2], @dstLine[0], @dstLine[2]) &&
             cel[AnimFrame::PATTERN] >= 0
            # Reverse direction
            sprite.mirror = !sprite.mirror
          end
        end
        sprite.x += 64 if @inEditor
        sprite.y += 64 if @inEditor
      end
      # Play timings
      @animation.playTiming(animFrame, @bgGraphic, @bgColor, @foGraphic, @foColor, @oldbg, @oldfo, @user)
    end
    @frame += 1
  end
end
