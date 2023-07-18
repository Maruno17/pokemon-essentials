#===============================================================================
#
#===============================================================================
class PictureOrigin
  TOP_LEFT     = 0
  CENTER       = 1
  TOP_RIGHT    = 2
  BOTTOM_LEFT  = 3
  LOWER_LEFT   = 3
  BOTTOM_RIGHT = 4
  LOWER_RIGHT  = 4
  TOP          = 5
  BOTTOM       = 6
  LEFT         = 7
  RIGHT        = 8
end

#===============================================================================
#
#===============================================================================
class Processes
  XY          = 0
  DELTA_XY    = 1
  Z           = 2
  CURVE       = 3
  ZOOM        = 4
  ANGLE       = 5
  TONE        = 6
  COLOR       = 7
  HUE         = 8
  OPACITY     = 9
  VISIBLE     = 10
  BLEND_TYPE  = 11
  SE          = 12
  NAME        = 13
  ORIGIN      = 14
  SRC         = 15
  SRC_SIZE    = 16
  CROP_BOTTOM = 17
end

#===============================================================================
#
#===============================================================================
def getCubicPoint2(src, t)
  x0  = src[0]
  y0  = src[1]
  cx0 = src[2]
  cy0 = src[3]
  cx1 = src[4]
  cy1 = src[5]
  x1  = src[6]
  y1  = src[7]

  x1 = cx1 + ((x1 - cx1) * t)
  x0 += ((cx0 - x0) * t)
  cx0 += ((cx1 - cx0) * t)
  cx1 = cx0 + ((x1 - cx0) * t)
  cx0 = x0 + ((cx0 - x0) * t)
  cx = cx0 + ((cx1 - cx0) * t)
  # a = x1 - 3 * cx1 + 3 * cx0 - x0
  # b = 3 * (cx1 - 2 * cx0 + x0)
  # c = 3 * (cx0 - x0)
  # d = x0
  # cx = a*t*t*t + b*t*t + c*t + d
  y1 = cy1 + ((y1 - cy1) * t)
  y0 += ((cy0 - y0) * t)
  cy0 += ((cy1 - cy0) * t)
  cy1 = cy0 + ((y1 - cy0) * t)
  cy0 = y0 + ((cy0 - y0) * t)
  cy = cy0 + ((cy1 - cy0) * t)
  # a = y1 - 3 * cy1 + 3 * cy0 - y0
  # b = 3 * (cy1 - 2 * cy0 + y0)
  # c = 3 * (cy0 - y0)
  # d = y0
  # cy = a*t*t*t + b*t*t + c*t + d
  return [cx, cy]
end

#===============================================================================
# PictureEx
#===============================================================================
class PictureEx
  attr_accessor :x              # x-coordinate
  attr_accessor :y              # y-coordinate
  attr_accessor :z              # z value
  attr_accessor :zoom_x         # x directional zoom rate
  attr_accessor :zoom_y         # y directional zoom rate
  attr_accessor :angle          # rotation angle
  attr_accessor :tone           # tone
  attr_accessor :color          # color
  attr_accessor :hue            # filename hue
  attr_accessor :opacity        # opacity level
  attr_accessor :visible        # visibility boolean
  attr_accessor :blend_type     # blend method
  attr_accessor :name           # file name
  attr_accessor :origin         # starting point
  attr_reader   :src_rect       # source rect
  attr_reader   :cropBottom     # crops sprite to above this y-coordinate
  attr_reader   :frameUpdates   # Array of processes updated in a frame

  def move_processes
    ret = []
    @processes.each do |p|
      next if ![Processes::XY, Processes::DELTA_XY].include?(p[0])
      pro = []
      pro.push(p[0] == Processes::XY ? "XY" : "DELTA")
      if p[1] == 0 && p[2] == 0
        pro.push("start " + p[7].to_i.to_s + ", " + p[8].to_i.to_s)
      else
        pro.push("for " + p[2].to_s) if p[2] > 0
        if p[0] == Processes::XY
          pro.push("go to " + p[7].to_i.to_s + ", " + p[8].to_i.to_s)
        else
          pro.push("move by " + p[7].to_i.to_s + ", " + p[8].to_i.to_s)
        end
      end
      ret.push(pro)
    end
    return ret
  end

  def initialize(z)
    # process: [type, delay, total_duration, frame_counter, cb, etc.]
    @processes     = []
    @x             = 0.0
    @y             = 0.0
    @z             = z
    @zoom_x        = 100.0
    @zoom_y        = 100.0
    @angle         = 0
    @rotate_speed  = 0
    @auto_angle    = 0   # Cumulative angle change caused by @rotate_speed
    @tone          = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @color         = Color.new(0, 0, 0, 0)
    @hue           = 0
    @opacity       = 255.0
    @visible       = true
    @blend_type    = 0
    @name          = ""
    @origin        = PictureOrigin::TOP_LEFT
    @src_rect      = Rect.new(0, 0, -1, -1)
    @cropBottom    = -1
    @frameUpdates  = []
  end

  def callback(cb)
    case cb
    when Proc
      cb.call(self)
    when Array
      cb[0].method(cb[1]).call(self, *cb[2])
    when Method
      cb.call(self)
    end
  end

  def setCallback(delay, cb = nil)
    delay = ensureDelayAndDuration(delay)
    @processes.push([nil, delay, 0, false, cb])
  end

  def running?
    return @processes.length > 0
  end

  def totalDuration
    ret = 0
    @processes.each do |process|
      dur = process[1] + process[2]
      ret = dur if dur > ret
    end
    return ret
  end

  def ensureDelayAndDuration(delay, duration = nil)
    delay = self.totalDuration if delay < 0
    return delay, duration if !duration.nil?
    return delay
  end

  def ensureDelay(delay)
    return ensureDelayAndDuration(delay)
  end

  # speed is the angle to change by in 1/20 of a second. @rotate_speed is the
  # angle to change by per frame.
  # NOTE: This is not compatible with manually changing the angle at a certain
  #       point. If you make a sprite auto-rotate, you should not try to alter
  #       the angle another way too.
  def rotate(speed)
    @rotate_speed = speed * 20.0
  end

  def erase
    self.name = ""
  end

  def clearProcesses
    @processes = []
    @timer_start = nil
  end

  def adjustPosition(xOffset, yOffset)
    @processes.each do |process|
      next if process[0] != Processes::XY
      process[5] += xOffset
      process[6] += yOffset
      process[7] += xOffset
      process[8] += yOffset
    end
  end

  def move(delay, duration, origin, x, y, zoom_x = 100.0, zoom_y = 100.0, opacity = 255)
    setOrigin(delay, duration, origin)
    moveXY(delay, duration, x, y)
    moveZoomXY(delay, duration, zoom_x, zoom_y)
    moveOpacity(delay, duration, opacity)
  end

  def moveXY(delay, duration, x, y, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::XY, delay, duration, false, cb, @x, @y, x, y])
  end

  def setXY(delay, x, y, cb = nil)
    moveXY(delay, 0, x, y, cb)
  end

  def moveCurve(delay, duration, x1, y1, x2, y2, x3, y3, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::CURVE, delay, duration, false, cb, [@x, @y, x1, y1, x2, y2, x3, y3]])
  end

  def moveDelta(delay, duration, x, y, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::DELTA_XY, delay, duration, false, cb, @x, @y, x, y])
  end

  def setDelta(delay, x, y, cb = nil)
    moveDelta(delay, 0, x, y, cb)
  end

  def moveZ(delay, duration, z, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::Z, delay, duration, false, cb, @z, z])
  end

  def setZ(delay, z, cb = nil)
    moveZ(delay, 0, z, cb)
  end

  def moveZoomXY(delay, duration, zoom_x, zoom_y, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::ZOOM, delay, duration, false, cb, @zoom_x, @zoom_y, zoom_x, zoom_y])
  end

  def setZoomXY(delay, zoom_x, zoom_y, cb = nil)
    moveZoomXY(delay, 0, zoom_x, zoom_y, cb)
  end

  def moveZoom(delay, duration, zoom, cb = nil)
    moveZoomXY(delay, duration, zoom, zoom, cb)
  end

  def setZoom(delay, zoom, cb = nil)
    moveZoomXY(delay, 0, zoom, zoom, cb)
  end

  def moveAngle(delay, duration, angle, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::ANGLE, delay, duration, false, cb, @angle, angle])
  end

  def setAngle(delay, angle, cb = nil)
    moveAngle(delay, 0, angle, cb)
  end

  def moveTone(delay, duration, tone, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    target = (tone) ? tone.clone : Tone.new(0, 0, 0, 0)
    @processes.push([Processes::TONE, delay, duration, false, cb, @tone.clone, target])
  end

  def setTone(delay, tone, cb = nil)
    moveTone(delay, 0, tone, cb)
  end

  def moveColor(delay, duration, color, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    target = (color) ? color.clone : Color.new(0, 0, 0, 0)
    @processes.push([Processes::COLOR, delay, duration, false, cb, @color.clone, target])
  end

  def setColor(delay, color, cb = nil)
    moveColor(delay, 0, color, cb)
  end

  # Hue changes don't actually work.
  def moveHue(delay, duration, hue, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::HUE, delay, duration, false, cb, @hue, hue])
  end

  # Hue changes don't actually work.
  def setHue(delay, hue, cb = nil)
    moveHue(delay, 0, hue, cb)
  end

  def moveOpacity(delay, duration, opacity, cb = nil)
    delay, duration = ensureDelayAndDuration(delay, duration)
    @processes.push([Processes::OPACITY, delay, duration, false, cb, @opacity, opacity])
  end

  def setOpacity(delay, opacity, cb = nil)
    moveOpacity(delay, 0, opacity, cb)
  end

  def setVisible(delay, visible, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::VISIBLE, delay, 0, false, cb, visible])
  end

  # Only values of 0 (normal), 1 (additive) and 2 (subtractive) are allowed.
  def setBlendType(delay, blend, cb = nil)
    delay = ensureDelayAndDuration(delay)
    @processes.push([Processes::BLEND_TYPE, delay, 0, false, cb, blend])
  end

  def setSE(delay, seFile, volume = nil, pitch = nil, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::SE, delay, 0, false, cb, seFile, volume, pitch])
  end

  def setName(delay, name, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::NAME, delay, 0, false, cb, name])
  end

  def setOrigin(delay, origin, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::ORIGIN, delay, 0, false, cb, origin])
  end

  def setSrc(delay, srcX, srcY, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::SRC, delay, 0, false, cb, srcX, srcY])
  end

  def setSrcSize(delay, srcWidth, srcHeight, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::SRC_SIZE, delay, 0, false, cb, srcWidth, srcHeight])
  end

  # Used to cut Pokémon sprites off when they faint and sink into the ground.
  def setCropBottom(delay, y, cb = nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::CROP_BOTTOM, delay, 0, false, cb, y])
  end

  def update
    time_now = System.uptime
    @timer_start = time_now if !@timer_start
    this_frame = ((time_now - @timer_start) * 20).to_i   # 20 frames per second
    procEnded = false
    @frameUpdates.clear
    @processes.each_with_index do |process, i|
      # Skip processes that aren't due to start yet
      next if process[1] > this_frame
      # Set initial values if the process has just started
      if !process[3]   # Not started yet
        process[3] = true   # Running
        case process[0]
        when Processes::XY
          process[5] = @x
          process[6] = @y
        when Processes::DELTA_XY
          process[5] = @x
          process[6] = @y
          process[7] += @x
          process[8] += @y
        when Processes::CURVE
          process[5][0] = @x
          process[5][1] = @y
        when Processes::Z
          process[5] = @z
        when Processes::ZOOM
          process[5] = @zoom_x
          process[6] = @zoom_y
        when Processes::ANGLE
          process[5] = @angle
        when Processes::TONE
          process[5] = @tone.clone
        when Processes::COLOR
          process[5] = @color.clone
        when Processes::HUE
          process[5] = @hue
        when Processes::OPACITY
          process[5] = @opacity
        end
      end
      # Update process
      @frameUpdates.push(process[0]) if !@frameUpdates.include?(process[0])
      start_time = @timer_start + (process[1] / 20.0)
      duration = process[2] / 20.0
      case process[0]
      when Processes::XY, Processes::DELTA_XY
        @x = lerp(process[5], process[7], duration, start_time, time_now)
        @y = lerp(process[6], process[8], duration, start_time, time_now)
      when Processes::CURVE
        @x, @y = getCubicPoint2(process[5], (time_now - start_time) / duration)
      when Processes::Z
        @z = lerp(process[5], process[6], duration, start_time, time_now)
      when Processes::ZOOM
        @zoom_x = lerp(process[5], process[7], duration, start_time, time_now)
        @zoom_y = lerp(process[6], process[8], duration, start_time, time_now)
      when Processes::ANGLE
        @angle = lerp(process[5], process[6], duration, start_time, time_now)
      when Processes::TONE
        @tone.red = lerp(process[5].red, process[6].red, duration, start_time, time_now)
        @tone.green = lerp(process[5].green, process[6].green, duration, start_time, time_now)
        @tone.blue = lerp(process[5].blue, process[6].blue, duration, start_time, time_now)
        @tone.gray = lerp(process[5].gray, process[6].gray, duration, start_time, time_now)
      when Processes::COLOR
        @color.red = lerp(process[5].red, process[6].red, duration, start_time, time_now)
        @color.green = lerp(process[5].green, process[6].green, duration, start_time, time_now)
        @color.blue = lerp(process[5].blue, process[6].blue, duration, start_time, time_now)
        @color.alpha = lerp(process[5].alpha, process[6].alpha, duration, start_time, time_now)
      when Processes::HUE
        @hue = lerp(process[5], process[6], duration, start_time, time_now)
      when Processes::OPACITY
        @opacity = lerp(process[5], process[6], duration, start_time, time_now)
      when Processes::VISIBLE
        @visible = process[5]
      when Processes::BLEND_TYPE
        @blend_type = process[5]
      when Processes::SE
        pbSEPlay(process[5], process[6], process[7])
      when Processes::NAME
        @name = process[5]
      when Processes::ORIGIN
        @origin = process[5]
      when Processes::SRC
        @src_rect.x = process[5]
        @src_rect.y = process[6]
      when Processes::SRC_SIZE
        @src_rect.width  = process[5]
        @src_rect.height = process[6]
      when Processes::CROP_BOTTOM
        @cropBottom = process[5]
      end
      # Erase process if its duration has elapsed
      if process[1] + process[2] <= this_frame
        callback(process[4]) if process[4]
        @processes[i] = nil
        procEnded = true
      end
    end
    # Clear out empty spaces in @processes array caused by finished processes
    @processes.compact! if procEnded
    @timer_start = nil if @processes.empty? && @rotate_speed == 0
    # Add the constant rotation speed
    if @rotate_speed != 0
      @frameUpdates.push(Processes::ANGLE) if !@frameUpdates.include?(Processes::ANGLE)
      @auto_angle = @rotate_speed * (time_now - @timer_start)
      while @auto_angle < 0
        @auto_angle += 360
      end
      @auto_angle %= 360
      @angle += @rotate_speed
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end

#===============================================================================
#
#===============================================================================
def setPictureSprite(sprite, picture, iconSprite = false)
  return if picture.frameUpdates.length == 0
  picture.frameUpdates.each do |type|
    case type
    when Processes::XY, Processes::DELTA_XY
      sprite.x = picture.x.round
      sprite.y = picture.y.round
    when Processes::Z
      sprite.z = picture.z
    when Processes::ZOOM
      sprite.zoom_x = picture.zoom_x / 100.0
      sprite.zoom_y = picture.zoom_y / 100.0
    when Processes::ANGLE
      sprite.angle = picture.angle
    when Processes::TONE
      sprite.tone = picture.tone
    when Processes::COLOR
      sprite.color = picture.color
    when Processes::HUE
      # This doesn't do anything.
    when Processes::BLEND_TYPE
      sprite.blend_type = picture.blend_type
    when Processes::OPACITY
      sprite.opacity = picture.opacity
    when Processes::VISIBLE
      sprite.visible = picture.visible
    when Processes::NAME
      sprite.name = picture.name if iconSprite && sprite.name != picture.name
    when Processes::ORIGIN
      case picture.origin
      when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
        sprite.ox = 0
      when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
        sprite.ox = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.width / 2 : 0
      when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
        sprite.ox = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.width : 0
      end
      case picture.origin
      when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
        sprite.oy = 0
      when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
        sprite.oy = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.height / 2 : 0
      when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
        sprite.oy = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.height : 0
      end
    when Processes::SRC
      next unless iconSprite && sprite.src_rect
      sprite.src_rect.x = picture.src_rect.x
      sprite.src_rect.y = picture.src_rect.y
    when Processes::SRC_SIZE
      next unless iconSprite && sprite.src_rect
      sprite.src_rect.width  = picture.src_rect.width
      sprite.src_rect.height = picture.src_rect.height
    end
  end
  if iconSprite && sprite.src_rect && picture.cropBottom >= 0
    spriteBottom = sprite.y - sprite.oy + sprite.src_rect.height
    if spriteBottom > picture.cropBottom
      sprite.src_rect.height = [picture.cropBottom - sprite.y + sprite.oy, 0].max
    end
  end
end

def setPictureIconSprite(sprite, picture)
  setPictureSprite(sprite, picture, true)
end
