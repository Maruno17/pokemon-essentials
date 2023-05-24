#===============================================================================
# ** Game_Screen
#-------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
#  flashing, etc. Refer to "$game_screen" for the instance of this class.
#===============================================================================
class Game_Screen
  attr_reader   :brightness         # brightness
  attr_reader   :tone               # color tone
  attr_reader   :flash_color        # flash color
  attr_reader   :shake              # shake positioning
  attr_reader   :pictures           # pictures
  attr_reader   :weather_type       # weather type
  attr_reader   :weather_max        # max number of weather sprites
  attr_accessor :weather_duration   # ticks in which the weather should fade in

  def initialize
    @brightness        = 255
    @fadeout_duration  = 0
    @fadein_duration   = 0
    @tone              = Tone.new(0, 0, 0, 0)
    @tone_target       = Tone.new(0, 0, 0, 0)
    @tone_duration     = 0
    @tone_timer_start  = nil
    @flash_color       = Color.new(0, 0, 0, 0)
    @flash_duration    = 0
    @flash_timer_start = nil
    @shake_power       = 0
    @shake_speed       = 0
    @shake_duration    = 0
    @shake_direction   = 1
    @shake             = 0
    @pictures          = [nil]
    (1..100).each { |i| @pictures.push(Game_Picture.new(i)) }
    @weather_type      = :None
    @weather_max       = 0.0
    @weather_duration  = 0
  end

  # duration is time in 1/20ths of a second.
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

  # duration is time in 1/20ths of a second.
  def start_flash(color, duration)
    @flash_color         = color.clone
    @flash_initial_alpha = @flash_color.alpha
    @flash_duration      = duration / 20.0
    @flash_timer_start   = $stats.play_time
  end

  def start_shake(power, speed, duration)
    @shake_power    = power
    @shake_speed    = speed
    @shake_duration = duration
  end

  def weather(type, power, duration)
    @weather_type     = GameData::Weather.get(type).id
    @weather_max      = (power + 1) * RPG::Weather::MAX_SPRITES / 10
    @weather_duration = duration   # In 1/20ths of a seconds
  end

  def update
    if @fadeout_duration && @fadeout_duration >= 1
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
    if @fadein_duration && @fadein_duration >= 1
      d = @fadein_duration
      @brightness = ((@brightness * (d - 1)) + 255) / d
      @fadein_duration -= 1
    end
    now = $stats.play_time
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
    if @flash_timer_start
      @flash_color.alpha = lerp(@flash_initial_alpha, 0, @flash_duration, @flash_timer_start, now)
      if now - @flash_timer_start >= @flash_duration
        @flash_initial_alpha = nil
        @flash_timer_start = nil
      end
    end
    if @shake_duration >= 1 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      @shake_direction = -1 if @shake > @shake_power * 2
      @shake_direction = 1 if @shake < -@shake_power * 2
      @shake_duration -= 1 if @shake_duration >= 1
    end
    if $game_temp.in_battle
      (51..100).each { |i| @pictures[i].update }
    else
      (1..50).each { |i|  @pictures[i].update }
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbToneChangeAll(tone, duration)
  $game_screen.start_tone_change(tone, duration)
  $game_screen.pictures.each { |picture| picture&.start_tone_change(tone, duration) }
end

def pbFlash(color, frames)
  $game_screen.start_flash(color, frames)
end

def pbShake(power, speed, frames)
  $game_screen.start_shake(power, speed, frames * Graphics.frame_rate / 20)
end
