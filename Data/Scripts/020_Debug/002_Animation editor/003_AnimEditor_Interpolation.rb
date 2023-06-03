module BattleAnimationEditor
  module_function

  #=============================================================================
  # Paths and interpolation
  #=============================================================================
  class ControlPointSprite < Sprite
    attr_accessor :dragging

    def initialize(red, viewport = nil)
      super(viewport)
      self.bitmap = Bitmap.new(6, 6)
      self.bitmap.fill_rect(0, 0, 6, 1, Color.black)
      self.bitmap.fill_rect(0, 0, 1, 6, Color.black)
      self.bitmap.fill_rect(0, 5, 6, 1, Color.black)
      self.bitmap.fill_rect(5, 0, 1, 6, Color.black)
      color = (red) ? Color.new(255, 0, 0) : Color.black
      self.bitmap.fill_rect(2, 2, 2, 2, color)
      self.x = -6
      self.y = -6
      self.visible = false
      @dragging = false
    end

    def mouseover
      if Input.time?(Input::MOUSELEFT) == 0 || !@dragging
        @dragging = false
        return
      end
      mouse = Mouse.getMousePos(true)
      return if !mouse
      self.x = [[mouse[0], 0].max, 512].min
      self.y = [[mouse[1], 0].max, 384].min
    end

    def hittest?
      return true if !self.visible
      mouse = Mouse.getMousePos(true)
      return false if !mouse
      return mouse[0] >= self.x && mouse[0] < self.x + 6 &&
             mouse[1] >= self.y && mouse[1] < self.y + 6
    end

    def inspect
      return "[#{self.x},#{self.y}]"
    end

    def dispose
      self.bitmap.dispose
      super
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class PointSprite < Sprite
    def initialize(x, y, viewport = nil)
      super(viewport)
      self.bitmap = Bitmap.new(2, 2)
      self.bitmap.fill_rect(0, 0, 2, 2, Color.black)
      self.x = x
      self.y = y
    end

    def dispose
      self.bitmap.dispose
      super
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class PointPath
    include Enumerable

    def initialize
      @points = []
      @distances = []
      @totaldist = 0
    end

    def [](x)
      return @points[x].clone
    end

    def each
      @points.each { |o| yield o.clone }
    end

    def size
      return @points.size
    end

    def length
      return @points.length
    end

    def totalDistance
      return @totaldist
    end

    def inspect
      p = []
      @points.each do |point|
        p.push([point[0].to_i, point[1].to_i])
      end
      return p.inspect
    end

    def isEndPoint?(x, y)
      return false if @points.length == 0
      index = @points.length - 1
      return @points[index][0] == x &&
             @points[index][1] == y
    end

    def addPoint(x, y)
      @points.push([x, y])
      if @points.length > 1
        len = @points.length
        dx = @points[len - 2][0] - @points[len - 1][0]
        dy = @points[len - 2][1] - @points[len - 1][1]
        dist = Math.sqrt((dx * dx) + (dy * dy))
        @distances.push(dist)
        @totaldist += dist
      end
    end

    def clear
      @points.clear
      @distances.clear
      @totaldist = 0
    end

    def smoothPointPath(frames, roundValues = false)
      raise ArgumentError.new("frames out of range: #{frames}") if frames < 0
      ret = PointPath.new
      return ret if @points.length == 0
      step = 1.0 / frames
      t = 0.0
      (frames + 2).times do
        point = pointOnPath(t)
        if roundValues
          ret.addPoint(point[0].round, point[1].round)
        else
          ret.addPoint(point[0], point[1])
        end
        t += step
        t = [1.0, t].min
      end
      return ret
    end

    def pointOnPath(t)
      if t < 0 || t > 1
        raise ArgumentError.new("t out of range for pointOnPath: #{t}")
      end
      return nil if @points.length == 0
      ret = @points[@points.length - 1].clone
      return ret if @points.length == 1
      curdist = 0
      distForT = @totaldist * t
      i = 0
      @distances.each do |dist|
        curdist += dist
        if dist > 0.0 && curdist >= distForT
          distT = 1.0 - ((curdist - distForT) / dist)
          dx = @points[i + 1][0] - @points[i][0]
          dy = @points[i + 1][1] - @points[i][1]
          ret = [@points[i][0] + (dx * distT),
                 @points[i][1] + (dy * distT)]
          break
        end
        i += 1
      end
      return ret
    end
  end

  #=============================================================================
  #
  #=============================================================================
  def catmullRom(p1, p2, p3, p4, t)
    # p1=prevPoint, p2=startPoint, p3=endPoint, p4=nextPoint, t is from 0 through 1
    t2 = t * t
    t3 = t2 * t
    return 0.5 * ((2 * p2) + (t * (p3 - p1)) +
           (t2 * ((2 * p1) - (5 * p2) + (4 * p3) - p4)) +
           (t3 * (p4 - (3 * p3) + (3 * p2) - p1)))
  end

  def getCatmullRomPoint(src, t)
    x = 0, y = 0
    t *= 3.0
    if t < 1.0
      x = catmullRom(src[0].x, src[0].x, src[1].x, src[2].x, t)
      y = catmullRom(src[0].y, src[0].y, src[1].y, src[2].y, t)
    elsif t < 2.0
      t -= 1.0
      x = catmullRom(src[0].x, src[1].x, src[2].x, src[3].x, t)
      y = catmullRom(src[0].y, src[1].y, src[2].y, src[3].y, t)
    else
      t -= 2.0
      x = catmullRom(src[1].x, src[2].x, src[3].x, src[3].x, t)
      y = catmullRom(src[1].y, src[2].y, src[3].y, src[3].y, t)
    end
    return [x, y]
  end

  def getCurvePoint(src, t)
    return getCatmullRomPoint(src, t)
  end

  def curveToPointPath(curve, numpoints)
    return nil if numpoints < 2
    path = PointPath.new
    step = 1.0 / (numpoints - 1)
    t = 0.0
    numpoints.times do
      point = getCurvePoint(curve, t)
      path.addPoint(point[0], point[1])
      t += step
    end
    return path
  end

  def pbDefinePath(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 320)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.addSlider(_INTL("Number of frames:"), 2, 500, 20)
    sliderwin2.opacity = 200
    defcurvebutton = sliderwin2.addButton(_INTL("Define Smooth Curve"))
    defpathbutton = sliderwin2.addButton(_INTL("Define Freehand Path"))
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    points = []
    path = nil
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(0)   # Number of frames
        if path
          path = path.smoothPointPath(sliderwin2.value(0), false)
          i = 0
          path.each do |point|
            if i < points.length
              points[i].x = point[0]
              points[i].y = point[1]
            else
              points.push(PointSprite.new(point[0], point[1], canvas.viewport))
            end
            i += 1
          end
          (i...points.length).each do |j|
            points[j].dispose
            points[j] = nil
          end
          points.compact!
        end
      elsif sliderwin2.changed?(defcurvebutton)
        points.each do |point|
          point.dispose
        end
        points.clear
        30.times do
          point = PointSprite.new(0, 0, canvas.viewport)
          point.visible = false
          points.push(point)
        end
        curve = [
          ControlPointSprite.new(true, canvas.viewport),
          ControlPointSprite.new(false, canvas.viewport),
          ControlPointSprite.new(false, canvas.viewport),
          ControlPointSprite.new(true, canvas.viewport)
        ]
        showline = false
        sliderwin2.visible = false
        # This window displays the mouse's current position
        window = Window_UnformattedTextPokemon.newWithSize(
          "", 0, 320 - 64, 128, 64, canvas.viewport
        )
        loop do
          Graphics.update
          Input.update
          if Input.trigger?(Input::BACK)
            break
          end
          if Input.trigger?(Input::MOUSELEFT)
            4.times do |j|
              next if !curve[j].hittest?
              if [1, 2].include?(j) && (!curve[0].visible || !curve[3].visible)
                next
              end
              curve[j].visible = true
              4.times do |k|
                curve[k].dragging = (k == j)
              end
              break
            end
          end
          4.times do |j|
            curve[j].mouseover
          end
          mousepos = Mouse.getMousePos(true)
          newtext = (mousepos) ? sprintf("(%d,%d)", mousepos[0], mousepos[1]) : "(??,??)"
          window.text = newtext if window.text != newtext
          if curve[0].visible && curve[3].visible &&
             !curve[0].dragging && !curve[3].dragging
            points.each do |point|
              point.visible = true
            end
            if !showline
              curve[1].visible = true
              curve[2].visible = true
              curve[1].x = curve[0].x + (0.3333 * (curve[3].x - curve[0].x))
              curve[1].y = curve[0].y + (0.3333 * (curve[3].y - curve[0].y))
              curve[2].x = curve[0].x + (0.6666 * (curve[3].x - curve[0].x))
              curve[2].y = curve[0].y + (0.6666 * (curve[3].y - curve[0].y))
            end
            showline = true
          end
          if showline
            step = 1.0 / (points.length - 1)
            t = 0.0
            points.length.times do |j|
              point = getCurvePoint(curve, t)
              points[j].x = point[0]
              points[j].y = point[1]
              t += step
            end
          end
        end
        window.dispose
        # dispose temporary path
        points.each do |point|
          point.dispose
        end
        points.clear
        if showline
          path = curveToPointPath(curve, sliderwin2.value(0))
#          File.open("pointpath.txt", "wb") { |f| f.write(path.inspect) }
          path.each do |point|
            points.push(PointSprite.new(point[0], point[1], canvas.viewport))
          end
        end
        curve.each do |point|
          point.dispose
        end
        sliderwin2.visible = true
        next
      elsif sliderwin2.changed?(defpathbutton)
        canceled = false
        pointpath = PointPath.new
        points.each do |point|
          point.dispose
        end
        points.clear
        window = Window_UnformattedTextPokemon.newWithSize(
          "", 0, 320 - 64, 128, 64, canvas.viewport
        )
        sliderwin2.visible = false
        loop do
          Graphics.update
          Input.update
          if Input.triggerex?(:ESCAPE)
            canceled = true
            break
          end
          if Input.trigger?(Input::MOUSELEFT)
            break
          end
          mousepos = Mouse.getMousePos(true)
          window.text = (mousepos) ? sprintf("(%d,%d)", mousepos[0], mousepos[1]) : "(??,??)"
        end
        until canceled
          mousepos = Mouse.getMousePos(true)
          if mousepos && !pointpath.isEndPoint?(mousepos[0], mousepos[1])
            pointpath.addPoint(mousepos[0], mousepos[1])
            points.push(PointSprite.new(mousepos[0], mousepos[1], canvas.viewport))
          end
          window.text = (mousepos) ? sprintf("(%d,%d)", mousepos[0], mousepos[1]) : "(??,??)"
          Graphics.update
          Input.update
          if Input.triggerex?(:ESCAPE) || Input.time?(Input::MOUSELEFT) == 0
            break
          end
        end
        window.dispose
        # dispose temporary path
        points.each do |point|
          point.dispose
        end
        points.clear
        # generate smooth path from temporary path
        path = pointpath.smoothPointPath(sliderwin2.value(0), true)
        # redraw path from smooth path
        path.each do |point|
          points.push(PointSprite.new(point[0], point[1], canvas.viewport))
        end
#        File.open("pointpath.txt", "wb") { |f| f.write(path.inspect) }
        sliderwin2.visible = true
        next
      elsif sliderwin2.changed?(okbutton) && path
#        File.open("pointpath.txt", "wb") { |f| f.write(path.inspect) }
        neededsize = canvas.currentframe + sliderwin2.value(0)
        if neededsize > canvas.animation.length
          canvas.animation.resize(neededsize)
        end
        thiscel = canvas.currentCel
        celnumber = canvas.currentcel
        (canvas.currentframe...neededsize).each do |j|
          cel = canvas.animation[j][celnumber]
          if !canvas.animation[j][celnumber]
            cel = pbCreateCel(0, 0, thiscel[AnimFrame::PATTERN], canvas.animation.position)
            canvas.animation[j][celnumber] = cel
          end
          cel[AnimFrame::X] = path[j - canvas.currentframe][0]
          cel[AnimFrame::Y] = path[j - canvas.currentframe][1]
        end
        break
      elsif sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    # dispose all points
    points.each do |point|
      point.dispose
    end
    points.clear
    sliderwin2.dispose
    return
  end
end
