#===============================================================================
# ** Game_Screen
#-------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
#  flashing, etc. Refer to "$game_screen" for the instance of this class.
#===============================================================================

class Game_Screen
  #-----------------------------------------------------------------------------
  # * Public Instance Variables
  #-----------------------------------------------------------------------------
  attr_reader   :brightness         # brightness
  attr_reader   :tone               # color tone
  attr_reader   :flash_color        # flash color
  attr_reader   :shake              # shake positioning
  attr_reader   :pictures           # pictures
  attr_reader   :weather_type       # weather type
  attr_reader   :weather_max        # max number of weather sprites
  attr_accessor :weather_duration   # ticks in which the weather should fade in

  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @brightness       = 255
    @fadeout_duration = 0
    @fadein_duration  = 0
    @tone             = Tone.new(0, 0, 0, 0)
    @tone_target      = Tone.new(0, 0, 0, 0)
    @tone_duration    = 0
    @flash_color      = Color.new(0, 0, 0, 0)
    @flash_duration   = 0
    @shake_power      = 0
    @shake_speed      = 0
    @shake_duration   = 0
    @shake_direction  = 1
    @shake            = 0
    @pictures         = [nil]
    (1..100).each do |i|
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type     = :None
    @weather_max      = 0.0
    @weather_duration = 0
  end
  #-----------------------------------------------------------------------------
  # * Start Changing Color Tone
  #     tone : color tone
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target   = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  #-----------------------------------------------------------------------------
  # * Start Flashing
  #     color : color
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_flash(color, duration)
    @flash_color    = color.clone
    @flash_duration = duration
  end
  #-----------------------------------------------------------------------------
  # * Start Shaking
  #     power : strength
  #     speed : speed
  #     duration : time
  #-----------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power    = power
    @shake_speed    = speed
    @shake_duration = duration
  end
  #-----------------------------------------------------------------------------
  # * Set Weather
  #     type : type
  #     power : strength
  #     duration : time
  #-----------------------------------------------------------------------------
  def weather(type, power, duration)
    @weather_type     = GameData::Weather.get(type).id
    @weather_max      = (power + 1) * RPG::Weather::MAX_SPRITES / 10
    @weather_duration = duration   # In 1/20ths of a seconds
  end
  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
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
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red   = ((@tone.red * (d - 1)) + @tone_target.red) / d
      @tone.green = ((@tone.green * (d - 1)) + @tone_target.green) / d
      @tone.blue  = ((@tone.blue * (d - 1)) + @tone_target.blue) / d
      @tone.gray  = ((@tone.gray * (d - 1)) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
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
      (51..100).each do |i|
        @pictures[i].update
      end
    else
      (1..50).each do |i|
        @pictures[i].update
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbToneChangeAll(tone, duration)
  $game_screen.start_tone_change(tone, duration * Graphics.frame_rate / 20)
  $game_screen.pictures.each do |picture|
    picture&.start_tone_change(tone, duration * Graphics.frame_rate / 20)
  end
end

def pbShake(power, speed, frames)
  $game_screen.start_shake(power, speed, frames * Graphics.frame_rate / 20)
end

def pbFlash(color, frames)
  $game_screen.start_flash(color, frames * Graphics.frame_rate / 20)
end
