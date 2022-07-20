class Interpolator
  ZOOM_X  = 1
  ZOOM_Y  = 2
  X       = 3
  Y       = 4
  OPACITY = 5
  COLOR   = 6
  WAIT    = 7

  def initialize
    @tweening = false
    @tweensteps = []
    @sprite = nil
    @frames = 0
    @step = 0
  end

  def tweening?
    return @tweening
  end

  def tween(sprite, items, frames)
    @tweensteps = []
    if sprite && !sprite.disposed? && frames > 0
      @frames = frames
      @step = 0
      @sprite = sprite
      items.each do |item|
        case item[0]
        when ZOOM_X
          @tweensteps[item[0]] = [sprite.zoom_x, item[1] - sprite.zoom_x]
        when ZOOM_Y
          @tweensteps[item[0]] = [sprite.zoom_y, item[1] - sprite.zoom_y]
        when X
          @tweensteps[item[0]] = [sprite.x, item[1] - sprite.x]
        when Y
          @tweensteps[item[0]] = [sprite.y, item[1] - sprite.y]
        when OPACITY
          @tweensteps[item[0]] = [sprite.opacity, item[1] - sprite.opacity]
        when COLOR
          @tweensteps[item[0]] = [sprite.color.clone,
                                  Color.new(item[1].red - sprite.color.red,
                                            item[1].green - sprite.color.green,
                                            item[1].blue - sprite.color.blue,
                                            item[1].alpha - sprite.color.alpha)]
        end
      end
      @tweening = true
    end
  end

  def update
    if @tweening
      t = @step.to_f / @frames
      @tweensteps.length.times do |i|
        item = @tweensteps[i]
        next if !item
        case i
        when ZOOM_X
          @sprite.zoom_x = item[0] + (item[1] * t)
        when ZOOM_Y
          @sprite.zoom_y = item[0] + (item[1] * t)
        when X
          @sprite.x = item[0] + (item[1] * t)
        when Y
          @sprite.y = item[0] + (item[1] * t)
        when OPACITY
          @sprite.opacity = item[0] + (item[1] * t)
        when COLOR
          @sprite.color = Color.new(item[0].red + (item[1].red * t),
                                    item[0].green + (item[1].green * t),
                                    item[0].blue + (item[1].blue * t),
                                    item[0].alpha + (item[1].alpha * t))
        end
      end
      @step += 1
      if @step == @frames
        @step = 0
        @frames = 0
        @tweening = false
      end
    end
  end
end



class RectInterpolator
  def initialize(oldrect, newrect, frames)
    restart(oldrect, newrect, frames)
  end

  def restart(oldrect, newrect, frames)
    @oldrect = oldrect
    @newrect = newrect
    @frames = [frames, 1].max
    @curframe = 0
    @rect = oldrect.clone
  end

  def set(rect)
    rect.set(@rect.x, @rect.y, @rect.width, @rect.height)
  end

  def done?
    @curframe > @frames
  end

  def update
    return if done?
    t = @curframe.to_f / @frames
    x1 = @oldrect.x
    x2 = @newrect.x
    x = x1 + (t * (x2 - x1))
    y1 = @oldrect.y
    y2 = @newrect.y
    y = y1 + (t * (y2 - y1))
    rx1 = @oldrect.x + @oldrect.width
    rx2 = @newrect.x + @newrect.width
    rx = rx1 + (t * (rx2 - rx1))
    ry1 = @oldrect.y + @oldrect.height
    ry2 = @newrect.y + @newrect.height
    ry = ry1 + (t * (ry2 - ry1))
    minx = x < rx ? x : rx
    maxx = x > rx ? x : rx
    miny = y < ry ? y : ry
    maxy = y > ry ? y : ry
    @rect.set(minx, miny, maxx - minx, maxy - miny)
    @curframe += 1
  end
end



class PointInterpolator
  attr_reader :x
  attr_reader :y

  def initialize(oldx, oldy, newx, newy, frames)
    restart(oldx, oldy, newx, newy, frames)
  end

  def restart(oldx, oldy, newx, newy, frames)
    @oldx = oldx
    @oldy = oldy
    @newx = newx
    @newy = newy
    @frames = frames
    @curframe = 0
    @x = oldx
    @y = oldy
  end

  def done?
    @curframe > @frames
  end

  def update
    return if done?
    t = @curframe.to_f / @frames
    rx1 = @oldx
    rx2 = @newx
    @x = rx1 + (t * (rx2 - rx1))
    ry1 = @oldy
    ry2 = @newy
    @y = ry1 + (t * (ry2 - ry1))
    @curframe += 1
  end
end
