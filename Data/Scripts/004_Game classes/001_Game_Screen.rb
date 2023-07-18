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
    @tone_initial     = @tone.clone
    @tone_target      = tone.clone
    @tone_duration    = duration / 20.0
    @tone_timer_start = $stats.play_time
  end

  # duration is time in 1/20ths of a second.
  def start_flash(color, duration)
    @flash_color         = color.clone
    @flash_initial_alpha = @flash_color.alpha
    @flash_duration      = duration / 20.0
    @flash_timer_start   = $stats.play_time
  end

  # duration is time in 1/20ths of a second.
  def start_shake(power, speed, duration)
    @shake_power       = power
    @shake_speed       = speed
    @shake_duration    = duration / 20.0
    @shake_timer_start = $stats.play_time
  end

  # duration is time in 1/20ths of a second.
  def weather(type, power, duration)
    @weather_type     = GameData::Weather.get(type).id
    @weather_max      = (power + 1) * RPG::Weather::MAX_SPRITES / 10
    @weather_duration = duration
  end

  def update
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
    if @shake_timer_start
      delta_t = now - @shake_timer_start
      movement_per_second = @shake_power * @shake_speed * 4
      limit = @shake_power * 2.5   # Maximum pixel displacement
      phase = (delta_t * movement_per_second / limit).to_i % 4
      case phase
      when 0, 2
        @shake = (movement_per_second * delta_t) % limit
        @shake *= -1 if phase == 2
      else
        @shake = limit - ((movement_per_second * delta_t) % limit)
        @shake *= -1 if phase == 3
      end
      if delta_t >= @shake_duration
        @shake_phase = phase if !@shake_phase || phase == 1 || phase == 3
        if phase != @shake_phase || @shake < 2
          @shake_timer_start = nil
          @shake = 0
        end
      end
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
  $game_screen.start_shake(power, speed, frames)
end
