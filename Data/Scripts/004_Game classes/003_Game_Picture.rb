#===============================================================================
# ** Game_Picture
#-------------------------------------------------------------------------------
#  This class handles the picture. It's used within the Game_Screen class
#  ($game_screen).
#===============================================================================
class Game_Picture
  attr_reader   :number                   # picture number
  attr_reader   :name                     # file name
  attr_reader   :origin                   # starting point
  attr_reader   :x                        # x-coordinate
  attr_reader   :y                        # y-coordinate
  attr_reader   :zoom_x                   # x directional zoom rate
  attr_reader   :zoom_y                   # y directional zoom rate
  attr_reader   :opacity                  # opacity level
  attr_reader   :blend_type               # blend method
  attr_reader   :tone                     # color tone
  attr_reader   :angle                    # rotation angle

  def initialize(number)
    @number = number
    @name = ""
    @origin = 0
    @x = 0.0
    @y = 0.0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @duration = 0
    @move_timer_start = nil
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @tone_timer_start = nil
    @angle = 0
    @rotate_speed = 0
  end

  # Show Picture
  #     name       : file name
  #     origin     : starting point
  #     x          : x-coordinate
  #     y          : y-coordinate
  #     zoom_x     : x directional zoom rate
  #     zoom_y     : y directional zoom rate
  #     opacity    : opacity level
  #     blend_type : blend method
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type || 0
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @tone_timer_start = nil
    @angle = 0
    @rotate_speed = 0
  end

  # Move Picture
  #     duration   : time in 1/20ths of a second
  #     origin     : starting point
  #     x          : x-coordinate
  #     y          : y-coordinate
  #     zoom_x     : x directional zoom rate
  #     zoom_y     : y directional zoom rate
  #     opacity    : opacity level
  #     blend_type : blend method
  def move(duration, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @duration         = duration / 20.0
    @origin           = origin
    @initial_x        = @x
    @initial_y        = @y
    @target_x         = x.to_f
    @target_y         = y.to_f
    @initial_zoom_x   = @zoom_x
    @initial_zoom_y   = @zoom_y
    @target_zoom_x    = zoom_x.to_f
    @target_zoom_y    = zoom_y.to_f
    @initial_opacity  = @opacity
    @target_opacity   = opacity.to_f
    @blend_type       = blend_type || 0
    @move_timer_start = $stats.play_time
  end

  # Change Rotation Speed
  #     speed : rotation speed (degrees to change per 1/20th of a second)
  def rotate(speed)
    @rotate_timer = (speed == 0) ? nil : System.uptime   # Time since last frame
    @rotate_speed = speed
  end

  # Start Change of Color Tone
  #     tone     : color tone
  #     duration : time in 1/20ths of a second
  def start_tone_change(tone, duration)
    if duration == 0
      @tone = tone.clone
      return
    end
    @tone_initial = @tone.clone
    @tone_target = tone.clone
    @tone_duration = duration / 20.0
    @tone_timer_start = $stats.play_time
  end

  def erase
    @name = ""
  end

  def update
    return if @name == ""
    now = $stats.play_time
    if @move_timer_start
      @x = lerp(@initial_x, @target_x, @duration, @move_timer_start, now)
      @y = lerp(@initial_y, @target_y, @duration, @move_timer_start, now)
      @zoom_x = lerp(@initial_zoom_x, @target_zoom_x, @duration, @move_timer_start, now)
      @zoom_y = lerp(@initial_zoom_y, @target_zoom_y, @duration, @move_timer_start, now)
      @opacity = lerp(@initial_opacity, @target_opacity, @duration, @move_timer_start, now)
      if now - @move_timer_start >= @duration
        @initial_x        = nil
        @initial_y        = nil
        @initial_zoom_x   = nil
        @initial_zoom_y   = nil
        @initial_opacity  = nil
        @move_timer_start = nil
      end
    end
    if @tone_timer_start
      @tone.red = lerp(@tone_initial.red, @tone_target.red, @tone_duration, @tone_timer_start, now)
      @tone.green = lerp(@tone_initial.green, @tone_target.green, @tone_duration, @tone_timer_start, now)
      @tone.blue = lerp(@tone_initial.blue, @tone_target.blue, @tone_duration, @tone_timer_start, now)
      @tone.gray = lerp(@tone_initial.gray, @tone_target.gray, @tone_duration, @tone_timer_start, now)
      if now - @tone_timer_start >= @tone_duration
        @tone_initial = nil
        @tone_timer_start = nil
      end
    end
    if @rotate_speed != 0
      @rotate_timer = System.uptime if !@rotate_timer
      @angle += @rotate_speed * (System.uptime - @rotate_timer) * 20.0
      @rotate_timer = System.uptime
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end
