#===============================================================================
#
#===============================================================================
module Graphics
  @@transition = nil
  STOP_WHILE_TRANSITION = true

  unless defined?(transition_KGC_SpecialTransition)
    class << Graphics
      alias transition_KGC_SpecialTransition transition
    end

    class << Graphics
      alias update_KGC_SpecialTransition update
    end
  end

  # duration is in 1/20ths of a second
  def self.transition(duration = 8, filename = "", vague = 20)
    duration = duration.floor
    if judge_special_transition(duration, filename)
      duration = 0
      filename = ""
    end
    duration *= Graphics.frame_rate / 20   # For default fade-in animation, must be in frames
    begin
      transition_KGC_SpecialTransition(duration, filename, vague)
    rescue Exception
      transition_KGC_SpecialTransition(duration, "", vague) if filename != ""
    end
    if STOP_WHILE_TRANSITION && !@_interrupt_transition
      while @@transition && !@@transition.disposed?
        update
      end
    end
  end

  def self.update
    update_KGC_SpecialTransition
    @@transition.update if @@transition && !@@transition.disposed?
    @@transition = nil if @@transition&.disposed?
  end

  def self.judge_special_transition(duration, filename)
    return false if @_interrupt_transition
    ret = true
    if @@transition && !@@transition.disposed?
      @@transition.dispose
      @@transition = nil
    end
    duration /= 20.0   # Turn into seconds
    dc = File.basename(filename).downcase
    case dc
    # Other coded transitions
    when "breakingglass"    then @@transition = Transitions::BreakingGlass.new(duration)
    when "rotatingpieces"   then @@transition = Transitions::ShrinkingPieces.new(duration, true)
    when "shrinkingpieces"  then @@transition = Transitions::ShrinkingPieces.new(duration, false)
    when "splash"           then @@transition = Transitions::SplashTransition.new(duration, 9.6)
    when "random_stripe_v"  then @@transition = Transitions::RandomStripeTransition.new(duration, 0)
    when "random_stripe_h"  then @@transition = Transitions::RandomStripeTransition.new(duration, 1)
    when "zoomin"           then @@transition = Transitions::ZoomInTransition.new(duration)
    when "scrolldown"       then @@transition = Transitions::ScrollScreen.new(duration, 2)
    when "scrollleft"       then @@transition = Transitions::ScrollScreen.new(duration, 4)
    when "scrollright"      then @@transition = Transitions::ScrollScreen.new(duration, 6)
    when "scrollup"         then @@transition = Transitions::ScrollScreen.new(duration, 8)
    when "scrolldownleft"   then @@transition = Transitions::ScrollScreen.new(duration, 1)
    when "scrolldownright"  then @@transition = Transitions::ScrollScreen.new(duration, 3)
    when "scrollupleft"     then @@transition = Transitions::ScrollScreen.new(duration, 7)
    when "scrollupright"    then @@transition = Transitions::ScrollScreen.new(duration, 9)
    when "mosaic"           then @@transition = Transitions::MosaicTransition.new(duration)
    # HGSS transitions
    when "snakesquares"     then @@transition = Transitions::SnakeSquares.new(duration)
    when "diagonalbubbletl" then @@transition = Transitions::DiagonalBubble.new(duration, 0)
    when "diagonalbubbletr" then @@transition = Transitions::DiagonalBubble.new(duration, 1)
    when "diagonalbubblebl" then @@transition = Transitions::DiagonalBubble.new(duration, 2)
    when "diagonalbubblebr" then @@transition = Transitions::DiagonalBubble.new(duration, 3)
    when "risingsplash"     then @@transition = Transitions::RisingSplash.new(duration)
    when "twoballpass"      then @@transition = Transitions::TwoBallPass.new(duration)
    when "spinballsplit"    then @@transition = Transitions::SpinBallSplit.new(duration)
    when "threeballdown"    then @@transition = Transitions::ThreeBallDown.new(duration)
    when "balldown"         then @@transition = Transitions::BallDown.new(duration)
    when "wavythreeballup"  then @@transition = Transitions::WavyThreeBallUp.new(duration)
    when "wavyspinball"     then @@transition = Transitions::WavySpinBall.new(duration)
    when "fourballburst"    then @@transition = Transitions::FourBallBurst.new(duration)
    when "vstrainer"        then @@transition = Transitions::VSTrainer.new(duration)
    when "vselitefour"      then @@transition = Transitions::VSEliteFour.new(duration)
    when "rocketgrunt"      then @@transition = Transitions::RocketGrunt.new(duration)
    when "vsrocketadmin"    then @@transition = Transitions::VSRocketAdmin.new(duration)
    # Graphic transitions
    when "fadetoblack"      then @@transition = Transitions::FadeToBlack.new(duration)
    when "fadefromblack"    then @@transition = Transitions::FadeFromBlack.new(duration)
    else                         ret = false
    end
    Graphics.frame_reset if ret
    return ret
  end
end

#===============================================================================
# Screen transition animation classes.
#===============================================================================
module Transitions
  #=============================================================================
  # A base class that all other screen transition animations inherit from.
  #=============================================================================
  class Transition_Base
    DURATION = nil

    def initialize(duration, *args)
      @disposed = false
      if duration <= 0
        @disposed = true
        return
      end
      @duration = self.class::DURATION || duration
      @parameters = args
      @timer_start = System.uptime
      @overworld_bitmap = $game_temp.background_bitmap
      initialize_bitmaps
      return if disposed?
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = []
      @overworld_sprite = new_sprite(0, 0, @overworld_bitmap)
      @overworld_sprite.z = -1
      initialize_sprites
      @timings = []
      set_up_timings
    end

    def new_sprite(x, y, bitmap, ox = 0, oy = 0)
      s = Sprite.new(@viewport)
      s.x = x
      s.y = y
      s.ox = ox
      s.oy = oy
      s.bitmap = bitmap
      return s
    end

    def timer
      return System.uptime - @timer_start
    end

    def dispose
      return if disposed?
      dispose_all
      @sprites.each { |s| s&.dispose }
      @sprites.clear
      @overworld_sprite.dispose
      @overworld_bitmap&.dispose
      @viewport&.dispose
      @disposed = true
    end

    def disposed?; return @disposed; end

    def update
      return if disposed?
      if timer >= @duration
        dispose
        return
      end
      update_anim
    end

    def initialize_bitmaps; end
    def initialize_sprites; end
    def set_up_timings;     end
    def dispose_all;        end
    def update_anim;        end
  end

  #=============================================================================
  #
  #=============================================================================
  class BreakingGlass < Transition_Base
    NUM_SPRITES_X = 8
    NUM_SPRITES_Y = 6

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld sprites
      sprite_width = @overworld_bitmap.width / NUM_SPRITES_X
      sprite_height = @overworld_bitmap.height / NUM_SPRITES_Y
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @sprites[idx_sprite] = new_sprite(i * sprite_width, j * sprite_height, @overworld_bitmap)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def set_up_timings
      @start_y = []
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @start_y[idx_sprite] = @sprites[idx_sprite].y
          @timings[idx_sprite] = 0.5 + rand
        end
      end
    end

    def update_anim
      proportion = timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.y = @start_y[i] + (Graphics.height * @timings[i] * proportion * proportion)
        sprite.opacity = 255 * (1 - proportion)
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ShrinkingPieces < Transition_Base
    NUM_SPRITES_X = 8
    NUM_SPRITES_Y = 6

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld sprites
      sprite_width = @overworld_bitmap.width / NUM_SPRITES_X
      sprite_height = @overworld_bitmap.height / NUM_SPRITES_Y
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @sprites[idx_sprite] = new_sprite((i + 0.5) * sprite_width, (j + 0.5) * sprite_height,
                                            @overworld_bitmap, sprite_width / 2, sprite_height / 2)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def update_anim
      proportion = timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.zoom_x = (1 - proportion).to_f
        sprite.zoom_y = sprite.zoom_x
        if @parameters[0]   # Rotation
          direction = (1 - (2 * (((i / NUM_SPRITES_X) + (i % NUM_SPRITES_X)) % 2)))
          sprite.angle = direction * 360 * 2 * proportion
        end
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class SplashTransition < Transition_Base
    NUM_SPRITES_X = 16
    NUM_SPRITES_Y = 12
    SPEED         = 40

    def initialize_sprites
      @overworld_sprite.visible = false
      # Black background
      @black_sprite = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @black_sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.black)
      # Overworld sprites
      sprite_width = @overworld_bitmap.width / NUM_SPRITES_X
      sprite_height = @overworld_bitmap.height / NUM_SPRITES_Y
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @sprites[idx_sprite] = new_sprite((i + 0.5) * sprite_width, (j + 0.5) * sprite_height,
                                            @overworld_bitmap, sprite_width / 2, sprite_height / 2)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def set_up_timings
      @start_positions = []
      @move_vectors = []
      vague = (@parameters[0] || 9.6) * SPEED
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          spr = @sprites[idx_sprite]
          @start_positions[idx_sprite] = [spr.x, spr.y]
          dx = spr.x - (Graphics.width / 2)
          dy = spr.y - (Graphics.height / 2)
          move_x = move_y = 0
          if dx == 0 && dy == 0
            move_x = (dx == 0) ? rand_sign * vague : dx * SPEED * 1.5
            move_y = (dy == 0) ? rand_sign * vague : dy * SPEED * 1.5
          else
            radius = Math.sqrt((dx**2) + (dy**2))
            move_x = dx * vague / radius
            move_y = dy * vague / radius
          end
          move_x += (rand - 0.5) * vague
          move_y += (rand - 0.5) * vague
          @move_vectors[idx_sprite] = [move_x, move_y]
        end
      end
    end

    def update_anim
      proportion = timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.x = @start_positions[i][0] + (@move_vectors[i][0] * proportion)
        sprite.y = @start_positions[i][1] + (@move_vectors[i][1] * proportion)
        sprite.opacity = 384 * (1 - proportion)
      end
    end

    #---------------------------------------------------------------------------

    private

    def rand_sign
      return (rand(2) == 0) ? 1 : -1
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class RandomStripeTransition < Transition_Base
    STRIPE_WIDTH = 2

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld sprites
      if @parameters[0] == 0   # Vertical stripes
        sprite_width = STRIPE_WIDTH
        sprite_height = @overworld_bitmap.height
        num_stripes_x = @overworld_bitmap.width / STRIPE_WIDTH
        num_stripes_y = 1
      else   # Horizontal stripes
        sprite_width = @overworld_bitmap.width
        sprite_height = STRIPE_WIDTH
        num_stripes_x = 1
        num_stripes_y = @overworld_bitmap.height / STRIPE_WIDTH
      end
      num_stripes_y.times do |j|
        num_stripes_x.times do |i|
          idx_sprite = (j * num_stripes_x) + i
          @sprites[idx_sprite] = new_sprite(i * sprite_width, j * sprite_height, @overworld_bitmap)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def set_up_timings
      @sprites.length.times do |i|
        @timings[i] = @duration * i / @sprites.length
      end
      @timings.shuffle!
    end

    def update_anim
      @sprites.each_with_index do |sprite, i|
        next if @timings[i] < 0 || timer < @timings[i]
        sprite.visible = false
        @timings[i] = -1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ZoomInTransition < Transition_Base
    def initialize_sprites
      @overworld_sprite.x = Graphics.width / 2
      @overworld_sprite.y = Graphics.height / 2
      @overworld_sprite.ox = @overworld_bitmap.width / 2
      @overworld_sprite.oy = @overworld_bitmap.height / 2
    end

    def update_anim
      proportion = timer / @duration
      @overworld_sprite.zoom_x = 1 + (7 * proportion)
      @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
      @overworld_sprite.opacity = 255 * (1 - proportion)
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ScrollScreen < Transition_Base
    def update_anim
      proportion = timer / @duration
      if (@parameters[0] % 3) != 2
        @overworld_sprite.x = [1, -1, 0][@parameters[0] % 3] * Graphics.width * proportion
      end
      if ((@parameters[0] - 1) / 3) != 1
        @overworld_sprite.y = [1, 0, -1][(@parameters[0] - 1) / 3] * Graphics.height * proportion
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class MosaicTransition < Transition_Base
    MAX_PIXELLATION_FACTOR = 16

    def initialize_bitmaps
      @buffer_original = @overworld_bitmap.clone   # Copy of original, never changes
      @buffer_temp = @overworld_bitmap.clone       # "Clipboard" holding shrunken overworld
    end

    def set_up_timings
      @start_black_fade = @duration * 0.8
    end

    def dispose_all
      @buffer_original&.dispose
      @buffer_temp&.dispose
    end

    def update_anim
      proportion = timer / @duration
      inv_proportion = 1 / (1 + (proportion * (MAX_PIXELLATION_FACTOR - 1)))
      new_size_rect = Rect.new(0, 0, @overworld_bitmap.width * inv_proportion,
                               @overworld_bitmap.height * inv_proportion)
      # Take all of buffer_original, shrink it and put it into buffer_temp
      @buffer_temp.stretch_blt(new_size_rect,
                               @buffer_original, Rect.new(0, 0, @overworld_bitmap.width, @overworld_bitmap.height))
      # Take shrunken area from buffer_temp and stretch it into buffer
      @overworld_bitmap.stretch_blt(Rect.new(0, 0, @overworld_bitmap.width, @overworld_bitmap.height),
                                    @buffer_temp, new_size_rect)
      if timer >= @start_black_fade
        @overworld_sprite.opacity = 255 * (1 - ((timer - @start_black_fade) / (@duration - @start_black_fade)))
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeToBlack < Transition_Base
    def update_anim
      @overworld_sprite.opacity = 255 * (1 - (timer / @duration))
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeFromBlack < Transition_Base
    def update_anim
      @overworld_sprite.opacity = 255 * timer / @duration
    end
  end

  #=============================================================================
  # HGSS wild outdoor
  #=============================================================================
  class SnakeSquares < Transition_Base
    DURATION      = 1.25
    TIME_TO_ZOOM  = 0.2   # In seconds
    NUM_SPRITES_X = 8
    NUM_SPRITES_Y = 6   # Must be an even number
    TOTAL_SPRITES = NUM_SPRITES_X * NUM_SPRITES_Y

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_square")
      if !@black_bitmap
        @disposed = true
        return
      end
      @zoom_x_target = Graphics.width.to_f / (@black_bitmap.width * NUM_SPRITES_X)
      @zoom_y_target = Graphics.height.to_f / (@black_bitmap.height * NUM_SPRITES_Y)
    end

    def initialize_sprites
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          if idx_sprite >= TOTAL_SPRITES / 2
            sprite_x = ((j.odd?) ? i : (NUM_SPRITES_X - i - 1)) * @black_bitmap.width
          else
            sprite_x = ((j.even?) ? i : (NUM_SPRITES_X - i - 1)) * @black_bitmap.width
          end
          sprite_x += @black_bitmap.width / 2
          @sprites[idx_sprite] = new_sprite(sprite_x, j * @black_bitmap.height * @zoom_y_target,
                                            @black_bitmap, @black_bitmap.width / 2)
          @sprites[idx_sprite].zoom_y  = @zoom_y_target
          @sprites[idx_sprite].visible = false
        end
      end
    end

    def set_up_timings
      time_between_zooms = (@duration - TIME_TO_ZOOM) * 2 / (TOTAL_SPRITES - 1)
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          idx_from_start = (idx_sprite >= TOTAL_SPRITES / 2) ? TOTAL_SPRITES - 1 - idx_sprite : idx_sprite
          @timings[idx_sprite] = time_between_zooms * idx_from_start
        end
      end
    end

    def dispose_all
      @black_bitmap.dispose
    end

    def update_anim
      @sprites.each_with_index do |sprite, i|
        next if @timings[i] < 0 || timer < @timings[i]
        sprite.visible = true
        sprite.zoom_x = @zoom_x_target * (timer - @timings[i]) / TIME_TO_ZOOM
        if sprite.zoom_x >= @zoom_x_target
          sprite.zoom_x = @zoom_x_target
          @timings[i] = -1
        end
      end
    end
  end

  #=============================================================================
  # HGSS wild indoor day (origin=0)
  # HGSS wild indoor night (origin=3)
  # HGSS wild cave (origin=3)
  #=============================================================================
  class DiagonalBubble < Transition_Base
    DURATION      = 1.25
    TIME_TO_ZOOM  = 0.2   # In seconds
    NUM_SPRITES_X = 8
    NUM_SPRITES_Y = 6
    TOTAL_SPRITES = NUM_SPRITES_X * NUM_SPRITES_Y

    def initialize_bitmaps
      @bitmap = RPG::Cache.transition("black_square")
      if !@bitmap
        @disposed = true
        return
      end
      @zoom_x_target = Graphics.width.to_f / (@bitmap.width * NUM_SPRITES_X)
      @zoom_y_target = Graphics.height.to_f / (@bitmap.height * NUM_SPRITES_Y)
    end

    def initialize_sprites
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @sprites[idx_sprite] = new_sprite(((i * @bitmap.width) + (@bitmap.width / 2)) * @zoom_x_target,
                                            ((j * @bitmap.height) + (@bitmap.height / 2)) * @zoom_y_target,
                                            @bitmap, @bitmap.width / 2, @bitmap.height / 2)
          @sprites[idx_sprite].visible = false
        end
      end
    end

    def set_up_timings
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_from_start = (j * NUM_SPRITES_X) + i   # Top left -> bottom right
          case @parameters[0]   # Origin
          when 1   # Top right -> bottom left
            idx_from_start = (j * NUM_SPRITES_X) + NUM_SPRITES_X - i - 1
          when 2   # Bottom left -> top right
            idx_from_start = TOTAL_SPRITES - 1 - ((j * NUM_SPRITES_X) + NUM_SPRITES_X - i - 1)
          when 3   # Bottom right -> top left
            idx_from_start = TOTAL_SPRITES - 1 - idx_from_start
          end
          dist = i + (j.to_f * (NUM_SPRITES_X - 1) / (NUM_SPRITES_Y - 1))
          @timings[idx_from_start] = (dist / ((NUM_SPRITES_X - 1) * 2)) * (@duration - TIME_TO_ZOOM)
        end
      end
    end

    def dispose_all
      @bitmap.dispose
    end

    def update_anim
      @sprites.each_with_index do |sprite, i|
        next if @timings[i] < 0 || timer < @timings[i]
        sprite.visible = true
        size = (timer - @timings[i]) / TIME_TO_ZOOM
        sprite.zoom_x = @zoom_x_target * size
        sprite.zoom_y = @zoom_y_target * size
        next if size < 1.0
        sprite.zoom_x = @zoom_x_target
        sprite.zoom_y = @zoom_y_target
        @timings[i] = -1
      end
    end
  end

  #=============================================================================
  # HGSS wild water
  #=============================================================================
  class RisingSplash < Transition_Base
    DURATION             = 1.25
    MAX_WAVE_AMPLITUDE   = 6
    WAVE_SPACING         = Math::PI / 10   # Density of overworld waves (20 strips per wave)
    WAVE_SPEED           = Math::PI * 10   # Speed of overworld waves going up the screen
    MAX_BUBBLE_AMPLITUDE = -32
    BUBBLES_WAVE_SPEED   = Math::PI * 2

    def initialize_bitmaps
      @bubble_bitmap = RPG::Cache.transition("water_1")
      @splash_bitmap = RPG::Cache.transition("water_2")
      @black_bitmap  = RPG::Cache.transition("black_half")
      dispose if !@bubble_bitmap || !@splash_bitmap || !@black_bitmap
    end

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld strips (they go all wavy)
      rect = Rect.new(0, 0, Graphics.width, 2)
      (Graphics.height / 2).times do |i|
        @sprites[i] = new_sprite(0, i * 2, @overworld_bitmap)
        @sprites[i].z = 2
        rect.y = i * 2
        @sprites[i].src_rect = rect
      end
      # Bubbles
      @bubbles_sprite = new_sprite(0, Graphics.height, @bubble_bitmap)
      @bubbles_sprite.z = 3
      # Water splash
      @splash_sprite = new_sprite(0, Graphics.height, @splash_bitmap)
      @splash_sprite.z = 4
      # Foreground black
      @black_sprite = new_sprite(0, Graphics.height, @black_bitmap)
      @black_sprite.z      = 5
      @black_sprite.zoom_y = 2.0
    end

    def set_up_timings
      @splash_rising_start = @duration * 0.5
      @black_rising_start  = @duration * 0.9
    end

    def dispose_all
      # Dispose sprites
      @bubbles_sprite&.dispose
      @splash_sprite&.dispose
      @black_sprite&.dispose
      # Dispose bitmaps
      @bubble_bitmap&.dispose
      @splash_bitmap&.dispose
      @black_bitmap&.dispose
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = amplitude * Math.sin((timer * WAVE_SPEED) + (i * WAVE_SPACING))
      end
      # Move bubbles sprite up and oscillate side to side
      @bubbles_sprite.x = (Graphics.width - @bubble_bitmap.width) / 2
      @bubbles_sprite.x += MAX_BUBBLE_AMPLITUDE * Math.sin(timer * BUBBLES_WAVE_SPEED)
      @bubbles_sprite.y = Graphics.height * (1 - (timer * 1.2))
      # Move splash sprite up
      if timer >= @splash_rising_start
        proportion = (timer - @splash_rising_start) / (@duration - @splash_rising_start)
        @splash_sprite.y = Graphics.height * (1 - (proportion * 2))
      end
      # Move black sprite up
      if timer >= @black_rising_start
        proportion = (timer - @black_rising_start) / (@duration - @black_rising_start)
        @black_sprite.y = Graphics.height * (1 - proportion)
      end
    end
  end

  #=============================================================================
  # HGSS trainer outdoor day
  #=============================================================================
  class TwoBallPass < Transition_Base
    DURATION = 1.0

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_half")
      @ball_bitmap  = RPG::Cache.transition("ball_small")
      dispose if !@black_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      @overworld_sprite.x = Graphics.width / 2
      @overworld_sprite.y = Graphics.height / 2
      @overworld_sprite.ox = @overworld_bitmap.width / 2
      @overworld_sprite.oy = @overworld_bitmap.height / 2
      # Balls that roll across the screen
      @ball_sprites = []
      2.times do |i|
        x = ((1 - i) * Graphics.width) + ((1 - (i * 2)) * @ball_bitmap.width / 2)
        y = (Graphics.height + (((i * 2) - 1) * @ball_bitmap.width)) / 2
        @ball_sprites[i] = new_sprite(x, y, @ball_bitmap,
                                      @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 2
      end
      # Black foreground sprites
      2.times do |i|
        @sprites[i] = new_sprite((1 - (i * 2)) * Graphics.width, i * Graphics.height / 2, @black_bitmap)
        @sprites[i].z = 1
      end
      @sprites[2] = new_sprite(0, Graphics.height / 2, @black_bitmap, 0, @black_bitmap.height / 2)
      @sprites[2].z = 1
      @sprites[2].zoom_y = 0.0
    end

    def set_up_timings
      @ball_start_x  = [@ball_sprites[0].x, @ball_sprites[1].x]
      @ball_roll_end = @duration * 0.4
    end

    def dispose_all
      # Dispose sprites
      if @ball_sprites
        @ball_sprites.each { |s| s&.dispose }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      if timer <= @ball_roll_end
        # Roll ball sprites across screen
        proportion = timer / @ball_roll_end
        total_distance = Graphics.width + @ball_bitmap.width
        @ball_sprites.each_with_index do |sprite, i|
          sprite.x = @ball_start_x[i] + (((2 * i) - 1) * (total_distance * proportion))
          sprite.angle = ((2 * i) - 1) * 360 * proportion * 2
        end
      else
        proportion = (timer - @ball_roll_end) / (@duration - @ball_roll_end)
        # Hide ball sprites
        if @ball_sprites[0].visible
          @ball_sprites.each { |s| s.visible = false }
        end
        # Zoom in overworld sprite
        @overworld_sprite.zoom_x = 1.0 + (proportion * proportion)   # Ends at 2x zoom
        @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
        # Slide first two black bars across
        @sprites[0].x = Graphics.width * (1 - (proportion * proportion))
        @sprites[1].x = Graphics.width * ((proportion * proportion) - 1)
        # Expand third black bar
        @sprites[2].zoom_y = 2.0 * proportion * proportion   # Ends at 2x zoom
      end
    end
  end

  #=============================================================================
  # HGSS trainer outdoor night
  #=============================================================================
  class SpinBallSplit < Transition_Base
    DURATION = 1.0

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_half")
      @ball_bitmap  = RPG::Cache.transition("ball_large")
      dispose if !@black_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      @overworld_sprite.visible = false
      @overworld_sprites = []
      @black_sprites = []
      @ball_sprites = []
      2.times do |i|
        # Overworld sprites (they split apart)
        @overworld_sprites[i] = new_sprite(Graphics.width / 2, Graphics.height / 2, @overworld_bitmap,
                                           Graphics.width / 2, (1 - i) * Graphics.height / 2)
        @overworld_sprites[i].src_rect.set(0, i * Graphics.height / 2, Graphics.width, Graphics.height / 2)
        # Black sprites
        @black_sprites[i] = new_sprite((1 - i) * Graphics.width, i * Graphics.height / 2, @black_bitmap,
                                       i * @black_bitmap.width, 0)
        @black_sprites[i].z = 1
        # Ball sprites
        @ball_sprites[i] = new_sprite(Graphics.width / 2, Graphics.height / 2, @ball_bitmap,
                                      @ball_bitmap.width / 2, (1 - i) * @ball_bitmap.height / 2)
        @ball_sprites[i].z = 2
        @ball_sprites[i].zoom_x = 0.0
        @ball_sprites[i].zoom_y = 0.0
      end
    end

    def set_up_timings
      @ball_spin_end = @duration * 0.4
      @slide_start   = @duration * 0.5
    end

    def dispose_all
      # Dispose sprites
      if @overworld_sprites
        @overworld_sprites.each { |s| s&.dispose }
        @overworld_sprites.clear
      end
      if @black_sprites
        @black_sprites.each { |s| s&.dispose }
        @black_sprites.clear
      end
      if @ball_sprites
        @ball_sprites.each { |s| s&.dispose }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      if timer < @ball_spin_end
        # Ball spin
        proportion = timer / @ball_spin_end
        @ball_sprites[0].zoom_x = proportion
        @ball_sprites[0].zoom_y = proportion
        @ball_sprites[0].angle = 360 * (1 - proportion)
      elsif timer < @slide_start
        # Fix zoom/angle of ball sprites
        if @ball_sprites[0].src_rect.height == @ball_bitmap.height
          @ball_sprites.each_with_index do |sprite, i|
            sprite.zoom_x = 1.0
            sprite.zoom_y = 1.0
            sprite.angle = 0
            sprite.src_rect.set(0, i * @ball_bitmap.height / 2,
                                @ball_bitmap.width, @ball_bitmap.height / 2)
          end
        end
      else
        # Split overworld/ball apart, move blackness in following them
        proportion = (timer - @slide_start) / (@duration - @slide_start)
        @overworld_sprites.each_with_index do |sprite, i|
          sprite.x = (0.5 + (((i * 2) - 1) * proportion * proportion)) * Graphics.width
          sprite.zoom_x = 1.0 + (proportion * proportion)   # Ends at 2x zoom
          sprite.zoom_y = sprite.zoom_x
          @black_sprites[i].x = sprite.x + ((1 - (i * 2)) * Graphics.width / 2)
          @ball_sprites[i].x = sprite.x
        end
      end
    end
  end

  #=============================================================================
  # HGSS trainer indoor day
  #=============================================================================
  class ThreeBallDown < Transition_Base
    DURATION      = 2.0
    NUM_SPRITES_X = 8
    NUM_SPRITES_Y = 6
    TOTAL_SPRITES = NUM_SPRITES_X * NUM_SPRITES_Y
    BALL_START_Y_OFFSETS = [400, 0, 100]

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_square")
      @ball_bitmap  = RPG::Cache.transition("ball_small")
      if !@black_bitmap || !@ball_bitmap
        dispose
        return
      end
      @zoom_x_target = Graphics.width.to_f / (@black_bitmap.width * NUM_SPRITES_X)
      @zoom_y_target = Graphics.height.to_f / (@black_bitmap.height * NUM_SPRITES_Y)
    end

    def initialize_sprites
      @overworld_sprite.x = Graphics.width / 2
      @overworld_sprite.y = Graphics.height / 2
      @overworld_sprite.ox = @overworld_bitmap.width / 2
      @overworld_sprite.oy = @overworld_bitmap.height / 2
      # Black squares
      NUM_SPRITES_Y.times do |j|
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @sprites[idx_sprite] = new_sprite(i * @black_bitmap.width * @zoom_x_target,
                                            j * @black_bitmap.height * @zoom_y_target, @black_bitmap)
          @sprites[idx_sprite].visible = false
        end
      end
      # Falling balls
      @ball_sprites = []
      3.times do |i|
        @ball_sprites[i] = new_sprite((Graphics.width / 2) + ((i - 1) * 160),
                                      -@ball_bitmap.height - BALL_START_Y_OFFSETS[i],
                                      @ball_bitmap, @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 2
      end
    end

    def set_up_timings
      @black_appear_start = @duration * 0.2
      appear_order = [0, 4, 1, 6, 7, 2, 5, 3]
      period = @duration - @black_appear_start
      NUM_SPRITES_Y.times do |j|
        row_offset = NUM_SPRITES_Y - j - 1
        NUM_SPRITES_X.times do |i|
          idx_sprite = (j * NUM_SPRITES_X) + i
          @timings[idx_sprite] = period * ((row_offset * NUM_SPRITES_X) + appear_order[i]) / TOTAL_SPRITES
          @timings[idx_sprite] += @black_appear_start
        end
      end
    end

    def dispose_all
      # Dispose sprites
      if @ball_sprites
        @ball_sprites.each { |s| s&.dispose }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      if timer < @black_appear_start
        # Balls drop down screen while spinning
        proportion = timer / @black_appear_start
        @ball_sprites.each_with_index do |sprite, i|
          sprite.y = -@ball_bitmap.height - BALL_START_Y_OFFSETS[i]
          sprite.y += (Graphics.height + BALL_START_Y_OFFSETS.max + (@ball_bitmap.height * 2)) * proportion
          sprite.angle = 1.5 * 360 * proportion * ([1, -1][(i == 2) ? 0 : 1])
        end
      else
        if @ball_sprites[0].visible
          @ball_sprites.each { |s| s.visible = false }
        end
        # Black squares appear
        @timings.each_with_index do |timing, i|
          next if timing < 0 || timer < timing
          @sprites[i].visible = true
          @timings[i] = -1
        end
        # Zoom in overworld sprite
        proportion = (timer - @black_appear_start) / (@duration - @black_appear_start)
        @overworld_sprite.zoom_x = 1.0 + (proportion * proportion)   # Ends at 2x zoom
        @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
      end
    end
  end

  #=============================================================================
  # HGSS trainer indoor night
  # HGSS trainer cave
  #=============================================================================
  class BallDown < Transition_Base
    DURATION = 0.9

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_half")
      @curve_bitmap = RPG::Cache.transition("black_curve")
      @ball_bitmap  = RPG::Cache.transition("ball_small")
      dispose if !@black_bitmap || !@curve_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      @overworld_sprite.x = Graphics.width / 2
      @overworld_sprite.y = Graphics.height / 2
      @overworld_sprite.ox = @overworld_bitmap.width / 2
      @overworld_sprite.oy = @overworld_bitmap.height / 2
      # Black sprites
      @sprites[0] = new_sprite(0, -@curve_bitmap.height, @black_bitmap, 0, @black_bitmap.height)
      @sprites[0].z = 1
      @sprites[0].zoom_y = 2.0
      @sprites[1] = new_sprite(0, -@curve_bitmap.height, @curve_bitmap)
      @sprites[1].z = 1
      # Ball sprite
      @ball_sprite = new_sprite(Graphics.width / 2, -@ball_bitmap.height / 2, @ball_bitmap,
                                @ball_bitmap.width / 2, @ball_bitmap.height / 2)
      @ball_sprite.z = 2
      @ball_sprite.zoom_x = 0.0
      @ball_sprite.zoom_y = 0.0
    end

    def set_up_timings
      @ball_appear_end = @duration * 0.7
    end

    def dispose_all
      # Dispose sprites
      @ball_sprite&.dispose
      # Dispose bitmaps
      @black_bitmap&.dispose
      @curve_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      if timer <= @ball_appear_end
        # Make ball drop down and zoom in
        proportion = timer / @ball_appear_end
        @ball_sprite.y = (-@ball_bitmap.height / 2) + ((Graphics.height + (@ball_bitmap.height * 3)) * proportion * proportion)
        @ball_sprite.angle = -1.5 * 360 * proportion
        @ball_sprite.zoom_x = 3 * proportion * proportion
        @ball_sprite.zoom_y = @ball_sprite.zoom_x
      else
        @ball_sprite.visible = false
        # Black curve and blackness descends
        proportion = (timer - @ball_appear_end) / (@duration - @ball_appear_end)
        @sprites.each do |sprite|
          sprite.y = -@curve_bitmap.height + ((Graphics.height + @curve_bitmap.height) * proportion)
        end
        # Zoom in overworld sprite
        @overworld_sprite.zoom_x = 1.0 + (proportion * proportion)   # Ends at 2x zoom
        @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
      end
    end
  end

  #=============================================================================
  # HGSS trainer water day
  #=============================================================================
  class WavyThreeBallUp < Transition_Base
    DURATION           = 1.1
    BALL_OFFSETS       = [1.5, 3.25, 2.5]
    MAX_WAVE_AMPLITUDE = 24
    WAVE_SPACING       = Math::PI / 24   # Density of overworld waves (48 strips per wave)
    WAVE_SPEED         = Math::PI * 4   # Speed of overworld waves going up the screen

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_half")
      @ball_bitmap  = RPG::Cache.transition("ball_small")
      dispose if !@black_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld strips (they go all wavy)
      rect = Rect.new(0, 0, Graphics.width, 4)
      (Graphics.height / 4).times do |i|
        @sprites[i] = new_sprite(0, i * 4, @overworld_bitmap)
        @sprites[i].z = 2
        rect.y = i * 4
        @sprites[i].src_rect = rect
      end
      # Ball sprites
      @ball_sprites = []
      3.times do |i|
        @ball_sprites[i] = new_sprite(((2 * i) + 1) * Graphics.width / 6,
                                      BALL_OFFSETS[i] * Graphics.height,
                                      @ball_bitmap, @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 4
      end
      # Black columns that follow the ball sprites
      @black_trail_sprites = []
      3.times do |i|
        @black_trail_sprites[i] = new_sprite((i - 1) * Graphics.width * 2 / 3,
                                             BALL_OFFSETS[i] * Graphics.height, @black_bitmap)
        @black_trail_sprites[i].z = 3
        @black_trail_sprites[i].zoom_y = 2.0
      end
    end

    def set_up_timings
      @ball_rising_start = @duration * 0.4
    end

    def dispose_all
      # Dispose sprites
      if @ball_sprites
        @ball_sprites.each { |s| s&.dispose }
        @ball_sprites.clear
      end
      if @black_trail_sprites
        @black_trail_sprites.each { |s| s&.dispose }
        @black_trail_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = (1 - ((i % 2) * 2)) * amplitude * Math.sin((timer * WAVE_SPEED) + (i * WAVE_SPACING))
      end
      # Move balls and trailing blackness up
      if timer >= @ball_rising_start
        proportion = (timer - @ball_rising_start) / (@duration - @ball_rising_start)
        @ball_sprites.each_with_index do |sprite, i|
          sprite.y = (BALL_OFFSETS[i] * Graphics.height) - (Graphics.height * 3.5 * proportion)
          sprite.angle = [-1, -1, 1][i] * 360 * 2 * proportion
          @black_trail_sprites[i].y = sprite.y
          @black_trail_sprites[i].y = 0 if @black_trail_sprites[i].y < 0
        end
      end
    end
  end

  #=============================================================================
  # HGSS trainer water night
  #=============================================================================
  class WavySpinBall < Transition_Base
    DURATION           = 1.0
    MAX_WAVE_AMPLITUDE = 24
    WAVE_SPACING       = Math::PI / 24   # Density of overworld waves (48 strips per wave)
    WAVE_SPEED         = Math::PI * 4   # Speed of overworld waves going up the screen

    def initialize_bitmaps
      @black_bitmap = RPG::Cache.transition("black_half")
      @ball_bitmap  = RPG::Cache.transition("ball_large")
      dispose if !@black_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      @overworld_sprite.visible = false
      # Overworld strips (they go all wavy)
      rect = Rect.new(0, 0, Graphics.width, 4)
      (Graphics.height / 4).times do |i|
        @sprites[i] = new_sprite(0, i * 4, @overworld_bitmap)
        @sprites[i].z = 2
        rect.y = i * 4
        @sprites[i].src_rect = rect
      end
      # Ball sprite
      @ball_sprite = new_sprite(Graphics.width / 2, Graphics.height / 2, @ball_bitmap,
                                @ball_bitmap.width / 2, @ball_bitmap.height / 2)
      @ball_sprite.z = 3
      @ball_sprite.opacity = 0
      # Black sprite
      @black_sprite = new_sprite(Graphics.width / 2, Graphics.height / 2, @black_bitmap,
                                 @black_bitmap.width / 2, @black_bitmap.height / 2)
      @black_sprite.z = 4
      @black_sprite.zoom_x = 0.0
      @black_sprite.zoom_y = 0.0
    end

    def set_up_timings
      @ball_appear_end    = @duration * 0.4
      @black_appear_start = @duration * 0.5
    end

    def dispose_all
      # Dispose sprites
      @ball_sprite&.dispose
      @black_sprite&.dispose
      # Dispose bitmaps
      @black_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = (1 - ((i % 2) * 2)) * amplitude * Math.sin((timer * WAVE_SPEED) + (i * WAVE_SPACING))
      end
      if timer <= @ball_appear_end
        # Fade in ball while spinning
        proportion = timer / @ball_appear_end
        @ball_sprite.opacity = 255 * proportion
        @ball_sprite.angle = -360 * proportion
      elsif timer <= @black_appear_start
        # Fix opacity/angle of ball sprite
        @ball_sprite.opacity = 255
        @ball_sprite.angle = 0
      else
        # Spread blackness from centre
        proportion = (timer - @black_appear_start) / (@duration - @black_appear_start)
        @black_sprite.zoom_x = proportion
        @black_sprite.zoom_y = proportion * 2
      end
    end
  end

  #=============================================================================
  # HGSS double trainers
  #=============================================================================
  class FourBallBurst < Transition_Base
    DURATION = 0.9

    def initialize_bitmaps
      @black_1_bitmap = RPG::Cache.transition("black_wedge_1")
      @black_2_bitmap = RPG::Cache.transition("black_wedge_2")
      @black_3_bitmap = RPG::Cache.transition("black_wedge_3")
      @black_4_bitmap = RPG::Cache.transition("black_wedge_4")
      @ball_bitmap    = RPG::Cache.transition("ball_small")
      dispose if !@black_1_bitmap || !@black_2_bitmap || !@black_3_bitmap ||
                 !@black_4_bitmap || !@ball_bitmap
    end

    def initialize_sprites
      # Ball sprites
      @ball_sprites = []
      4.times do |i|
        @ball_sprites[i] = new_sprite(Graphics.width / 2, Graphics.height / 2, @ball_bitmap,
                                      @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = [2, 1, 3, 0][i]
      end
      # Black wedges
      4.times do |i|
        b = [@black_1_bitmap, @black_2_bitmap, @black_3_bitmap, @black_4_bitmap][i]
        @sprites[i] = new_sprite((i == 1) ? 0 : Graphics.width / 2, (i == 2) ? 0 : Graphics.height / 2, b,
                                 (i.even?) ? b.width / 2 : 0, (i.even?) ? 0 : b.height / 2)
        @sprites[i].zoom_x = 0.0 if i.even?
        @sprites[i].zoom_y = 0.0 if i.odd?
        @sprites[i].visible = false
      end
    end

    def set_up_timings
      @ball_appear_end = @duration * 0.4
    end

    def dispose_all
      # Dispose sprites
      @ball_sprites.each { |s| s&.dispose }
      @ball_sprites.clear
      # Dispose bitmaps
      @black_1_bitmap&.dispose
      @black_2_bitmap&.dispose
      @black_3_bitmap&.dispose
      @black_4_bitmap&.dispose
      @ball_bitmap&.dispose
    end

    def update_anim
      if timer <= @ball_appear_end
        # Balls fly out from centre of screen
        proportion = timer / @ball_appear_end
        ball_travel_x = (Graphics.width + (@ball_bitmap.width * 2)) / 2
        ball_travel_y = (Graphics.height + (@ball_bitmap.height * 2)) / 2
        @ball_sprites.each_with_index do |sprite, i|
          sprite.x = (Graphics.width / 2) + ([0, 1, 0, -1][i] * ball_travel_x * proportion) if i.odd?
          sprite.y = (Graphics.height / 2) + ([1, 0, -1, 0][i] * ball_travel_y * proportion) if i.even?
        end
      else
        # Black wedges expand to fill screen
        proportion = (timer - @ball_appear_end) / (@duration - @ball_appear_end)
        @sprites.each_with_index do |sprite, i|
          sprite.visible = true
          sprite.zoom_x = proportion if i.even?
          sprite.zoom_y = proportion if i.odd?
        end
      end
    end
  end

  #=============================================================================
  # HGSS VS Trainer animation
  # Uses $game_temp.transition_animation_data, and expects it to be an array
  # like so: [:TRAINERTYPE, "display name"]
  # Bar graphics are named hgss_vsBar_TRAINERTYPE.png.
  # Trainer sprites are named hgss_vs_TRAINERTYPE.png.
  #=============================================================================
  class VSTrainer < Transition_Base
    DURATION           = 4.0
    BAR_Y              = 80
    BAR_SCROLL_SPEED   = 1800
    BAR_MASK           = [8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7]
    FOE_SPRITE_X_LIMIT = 384   # Slides to here before jumping to final position
    FOE_SPRITE_X       = 428   # Final position of foe sprite

    def initialize_bitmaps
      @bar_bitmap   = RPG::Cache.transition("hgss_vsBar_#{$game_temp.transition_animation_data[0]}")
      @vs_1_bitmap  = RPG::Cache.transition("hgss_vs1")
      @vs_2_bitmap  = RPG::Cache.transition("hgss_vs2")
      @foe_bitmap   = RPG::Cache.transition("hgss_vs_#{$game_temp.transition_animation_data[0]}")
      @black_bitmap = RPG::Cache.transition("black_half")
      dispose if !@bar_bitmap || !@vs_1_bitmap || !@vs_2_bitmap || !@foe_bitmap || !@black_bitmap
    end

    def initialize_sprites
      @flash_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @flash_viewport.z     = 99999
      @flash_viewport.color = Color.new(255, 255, 255, 0)
      # Background black
      @rear_black_sprite = new_sprite(0, 0, @black_bitmap)
      @rear_black_sprite.z       = 1
      @rear_black_sprite.zoom_y  = 2.0
      @rear_black_sprite.opacity = 224
      @rear_black_sprite.visible = false
      # Bar sprites (need 2 of them to make them loop around)
      ((Graphics.width.to_f / @bar_bitmap.width).ceil + 1).times do |i|
        spr = new_sprite(@bar_bitmap.width * i, BAR_Y, @bar_bitmap)
        spr.z = 2
        @sprites.push(spr)
      end
      # Overworld sprite
      @bar_mask_sprite = new_sprite(0, 0, @overworld_bitmap.clone)
      @bar_mask_sprite.z = 3
      # VS logo
      @vs_x = 144
      @vs_y = @sprites[0].y + (@sprites[0].height / 2)
      @vs_main_sprite = new_sprite(@vs_x, @vs_y, @vs_1_bitmap, @vs_1_bitmap.width / 2, @vs_1_bitmap.height / 2)
      @vs_main_sprite.z       = 4
      @vs_main_sprite.visible = false
      @vs_1_sprite = new_sprite(@vs_x, @vs_y, @vs_2_bitmap, @vs_2_bitmap.width / 2, @vs_2_bitmap.height / 2)
      @vs_1_sprite.z       = 5
      @vs_1_sprite.zoom_x  = 2.0
      @vs_1_sprite.zoom_y  = @vs_1_sprite.zoom_x
      @vs_1_sprite.visible = false
      @vs_2_sprite = new_sprite(@vs_x, @vs_y, @vs_2_bitmap, @vs_2_bitmap.width / 2, @vs_2_bitmap.height / 2)
      @vs_2_sprite.z       = 6
      @vs_2_sprite.zoom_x  = 2.0
      @vs_2_sprite.zoom_y  = @vs_2_sprite.zoom_x
      @vs_2_sprite.visible = false
      # Foe sprite
      @foe_sprite = new_sprite(Graphics.width + @foe_bitmap.width, @sprites[0].y + @sprites[0].height - 12,
                               @foe_bitmap, @foe_bitmap.width / 2, @foe_bitmap.height)
      @foe_sprite.z     = 7
      @foe_sprite.color = Color.black
      # Sprite with foe's name written in it
      @text_sprite = BitmapSprite.new(Graphics.width, @bar_bitmap.height, @viewport)
      @text_sprite.y       = BAR_Y
      @text_sprite.z       = 8
      @text_sprite.visible = false
      pbSetSystemFont(@text_sprite.bitmap)
      pbDrawTextPositions(@text_sprite.bitmap,
                          [[$game_temp.transition_animation_data[1], 244, 86, :left,
                            Color.new(248, 248, 248), Color.new(72, 80, 80)]])
      # Foreground black
      @black_sprite = new_sprite(0, 0, @black_bitmap)
      @black_sprite.z       = 10
      @black_sprite.zoom_y  = 2.0
      @black_sprite.visible = false
    end

    def set_up_timings
      @bar_x = 0
      @bar_appear_end      = 0.2   # Starts appearing at 0.0
      @vs_appear_start     = 0.7
      @vs_appear_start_2   = 0.9
      @vs_shrink_time      = @vs_appear_start_2 - @vs_appear_start
      @vs_appear_final     = @vs_appear_start_2 + @vs_shrink_time
      @foe_appear_start    = 1.25
      @foe_appear_end      = 1.4
      @flash_start         = 1.9
      @flash_duration      = 0.25
      @fade_to_white_start = 3.0
      @fade_to_white_end   = 3.5
      @fade_to_black_start = 3.8
    end

    def dispose_all
      # Dispose sprites
      @rear_black_sprite&.dispose
      @bar_mask_sprite&.dispose
      @vs_main_sprite&.dispose
      @vs_1_sprite&.dispose
      @vs_2_sprite&.dispose
      @foe_sprite&.dispose
      @text_sprite&.dispose
      @black_sprite&.dispose
      # Dispose bitmaps
      @bar_bitmap&.dispose
      @vs_1_bitmap&.dispose
      @vs_2_bitmap&.dispose
      @foe_bitmap&.dispose
      @black_bitmap&.dispose
      # Dispose viewport
      @flash_viewport&.dispose
    end

    def update_anim
      # Bar scrolling
      @bar_x = -timer * BAR_SCROLL_SPEED
      while @bar_x <= -@bar_bitmap.width
        @bar_x += @bar_bitmap.width
      end
      @sprites.each_with_index { |spr, i| spr.x = @bar_x + (i * @bar_bitmap.width) }
      # Vibrate VS sprite
      vs_phase = (timer * 30).to_i % 3
      @vs_main_sprite.x = @vs_x + [0, 4, 0][vs_phase]
      @vs_main_sprite.y = @vs_y + [0, 0, -4][vs_phase]
      if timer >= @fade_to_black_start
        # Fade to black
        @black_sprite.visible = true
        proportion = (timer - @fade_to_black_start) / (@duration - @fade_to_black_start)
        @flash_viewport.color.alpha = 255 * (1 - proportion)
      elsif timer >= @fade_to_white_start
        # Slowly fade to white
        proportion = (timer - @fade_to_white_start) / (@fade_to_white_end - @fade_to_white_start)
        @flash_viewport.color.alpha = 255 * proportion
      elsif timer >= @flash_start + @flash_duration
        @flash_viewport.color.alpha = 0
      elsif timer >= @flash_start
        # Flash the screen white
        proportion = (timer - @flash_start) / @flash_duration
        if proportion >= 0.5
          @flash_viewport.color.alpha = 320 * 2 * (1 - proportion)
          @rear_black_sprite.visible = true
          @foe_sprite.color.alpha = 0
          @text_sprite.visible = true
        else
          @flash_viewport.color.alpha = 320 * 2 * proportion
        end
      elsif timer >= @foe_appear_end
        @foe_sprite.x = FOE_SPRITE_X
      elsif timer >= @foe_appear_start
        # Foe sprite appears
        proportion = (timer - @foe_appear_start) / (@foe_appear_end - @foe_appear_start)
        start_x = Graphics.width + (@foe_bitmap.width / 2)
        @foe_sprite.x = start_x + ((FOE_SPRITE_X_LIMIT - start_x) * proportion)
      elsif timer >= @vs_appear_final
        @vs_1_sprite.visible = false
      elsif timer >= @vs_appear_start_2
        # Temp VS sprites enlarge and shrink again
        if @vs_2_sprite.visible
          @vs_2_sprite.zoom_x = 1.6 - (0.8 * (timer - @vs_appear_start_2) / @vs_shrink_time)
          @vs_2_sprite.zoom_y = @vs_2_sprite.zoom_x
          if @vs_2_sprite.zoom_x <= 1.2
            @vs_2_sprite.visible = false
            @vs_main_sprite.visible = true
          end
        end
        @vs_1_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start_2) / @vs_shrink_time)
        @vs_1_sprite.zoom_y = @vs_1_sprite.zoom_x
      elsif timer >= @vs_appear_start
        # Temp VS sprites appear and start shrinking
        @vs_2_sprite.visible = true
        @vs_2_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start) / @vs_shrink_time)
        @vs_2_sprite.zoom_y = @vs_2_sprite.zoom_x
        if @vs_1_sprite.visible || @vs_2_sprite.zoom_x <= 1.6   # Halfway between 2.0 and 1.2
          @vs_1_sprite.visible = true
          @vs_1_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start - (@vs_shrink_time / 2)) / @vs_shrink_time)
          @vs_1_sprite.zoom_y = @vs_1_sprite.zoom_x
        end
      elsif timer >= @bar_appear_end
        @bar_mask_sprite.visible = false
      else
        start_x = Graphics.width * (1 - (timer / @bar_appear_end))
        color = Color.new(0, 0, 0, 0)   # Transparent
        (@sprites[0].height / 2).times do |i|
          x = start_x - (BAR_MASK[i % BAR_MASK.length] * 4)
          @bar_mask_sprite.bitmap.fill_rect(x, BAR_Y + (i * 2), @bar_mask_sprite.width - x, 2, color)
        end
      end
    end
  end

  #=============================================================================
  # HGSS VS Elite Four/Champion animation
  # Uses $game_temp.transition_animation_data, and expects it to be an array
  # like so: [:TRAINERTYPE, "display name", "player sprite name minus 'vsE4_'"]
  # Bar graphics are named vsE4Bar_TRAINERTYPE.png.
  # Trainer sprites are named vsE4_TRAINERTYPE.png.
  #=============================================================================
  class VSEliteFour < Transition_Base
    DURATION           = 3.5
    BAR_X_INDENT       = 48
    BAR_Y_INDENT       = 64   # = height of trainer sprite / 2
    BAR_OVERSHOOT      = 20
    TRAINER_X_OFFSET   = 160
    TRAINER_Y_OFFSET   = 8
    BAR_HEIGHT         = 192   # = Graphics.height / 2
    FOE_SPRITE_X_LIMIT = 384   # Slides to here before jumping to final position
    FOE_SPRITE_X       = 428   # Final position of foe sprite

    def initialize_bitmaps
      @bar_bitmap    = RPG::Cache.transition("vsE4Bar_#{$game_temp.transition_animation_data[0]}")
      @vs_1_bitmap   = RPG::Cache.transition("hgss_vs1")
      @vs_2_bitmap   = RPG::Cache.transition("hgss_vs2")
      @player_bitmap = RPG::Cache.transition("vsE4_#{$game_temp.transition_animation_data[2]}")
      @foe_bitmap    = RPG::Cache.transition("vsE4_#{$game_temp.transition_animation_data[0]}")
      @black_bitmap  = RPG::Cache.transition("black_half")
      dispose if !@bar_bitmap || !@vs_1_bitmap || !@vs_2_bitmap || !@foe_bitmap || !@black_bitmap
      @num_bar_frames = @bar_bitmap.height / BAR_HEIGHT
    end

    def initialize_sprites
      @flash_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @flash_viewport.z     = 99999
      @flash_viewport.color = Color.new(255, 255, 255, 0)
      # Background black
      @rear_black_sprite = new_sprite(0, 0, @black_bitmap)
      @rear_black_sprite.z       = 1
      @rear_black_sprite.zoom_y  = 2.0
      @rear_black_sprite.opacity = 192
      @rear_black_sprite.visible = false
      # Player's bar sprite
      @player_bar_x = -BAR_X_INDENT
      @player_bar_start_x = @player_bar_x - (@bar_bitmap.width / 2)
      @player_bar_y = BAR_Y_INDENT
      @player_bar_sprite = new_sprite(@player_bar_start_x, @player_bar_y, @bar_bitmap)
      @player_bar_sprite.z = 2
      @player_bar_sprite.src_rect.width = @bar_bitmap.width / 2
      @player_bar_sprite.src_rect.height = BAR_HEIGHT
      # Foe's bar sprite
      @foe_bar_x = Graphics.width + BAR_X_INDENT - (@bar_bitmap.width / 2)
      @foe_bar_start_x = @foe_bar_x + (@bar_bitmap.width / 2)
      @foe_bar_y = Graphics.height - BAR_HEIGHT - BAR_Y_INDENT
      @foe_bar_sprite = new_sprite(@foe_bar_start_x, @foe_bar_y, @bar_bitmap)
      @foe_bar_sprite.z = 2
      @foe_bar_sprite.src_rect.x = @bar_bitmap.width / 2
      @foe_bar_sprite.src_rect.width = @bar_bitmap.width / 2
      @foe_bar_sprite.src_rect.height = BAR_HEIGHT
      # Player sprite
      @player_sprite = new_sprite(@player_bar_sprite.x + TRAINER_X_OFFSET,
                                  @player_bar_sprite.y + BAR_HEIGHT - TRAINER_Y_OFFSET,
                                  @player_bitmap, @player_bitmap.width / 2, @player_bitmap.height)
      @player_sprite.z     = 7
      @player_sprite.color = Color.black
      # Foe sprite
      @foe_sprite = new_sprite(@foe_bar_sprite.x + (@bar_bitmap.width / 2) - TRAINER_X_OFFSET,
                               @foe_bar_sprite.y + @foe_bitmap.height - TRAINER_Y_OFFSET,
                               @foe_bitmap, @foe_bitmap.width / 2, @foe_bitmap.height)
      @foe_sprite.z     = 7
      @foe_sprite.color = Color.black
      # Sprite with foe's name written in it
      @text_sprite = BitmapSprite.new(@bar_bitmap.width / 2, BAR_HEIGHT, @viewport)
      @text_sprite.x = @foe_bar_start_x
      @text_sprite.y = @foe_bar_y
      @text_sprite.z = 8
      pbSetSystemFont(@text_sprite.bitmap)
      pbDrawTextPositions(@text_sprite.bitmap,
                          [[$game_temp.transition_animation_data[1], 160, 86, :left,
                            Color.new(248, 248, 248), Color.new(72, 80, 80)]])
      # VS logo
      @vs_main_sprite = new_sprite(Graphics.width / 2, Graphics.height / 2, @vs_1_bitmap,
                                   @vs_1_bitmap.width / 2, @vs_1_bitmap.height / 2)
      @vs_main_sprite.z       = 14
      @vs_main_sprite.visible = false
      @vs_1_sprite = new_sprite(Graphics.width / 2, Graphics.height / 2, @vs_2_bitmap,
                                @vs_2_bitmap.width / 2, @vs_2_bitmap.height / 2)
      @vs_1_sprite.z       = 15
      @vs_1_sprite.zoom_x  = 2.0
      @vs_1_sprite.zoom_y  = @vs_1_sprite.zoom_x
      @vs_1_sprite.visible = false
      @vs_2_sprite = new_sprite(Graphics.width / 2, Graphics.height / 2, @vs_2_bitmap,
                                @vs_2_bitmap.width / 2, @vs_2_bitmap.height / 2)
      @vs_2_sprite.z       = 16
      @vs_2_sprite.zoom_x  = 2.0
      @vs_2_sprite.zoom_y  = @vs_2_sprite.zoom_x
      @vs_2_sprite.visible = false
      # Foreground black
      @black_sprite = new_sprite(0, 0, @black_bitmap)
      @black_sprite.z       = 20
      @black_sprite.zoom_y  = 2.0
      @black_sprite.visible = false
    end

    def set_up_timings
      @flash_1_start       = 0.0
      @flash_1_duration    = 0.25
      @bar_appear_start    = 0.5
      @bar_appear_end      = 0.7
      @vs_appear_start     = 0.6
      @vs_appear_start_2   = 0.8
      @vs_shrink_time      = @vs_appear_start_2 - @vs_appear_start
      @vs_appear_final     = @vs_appear_start_2 + @vs_shrink_time
      @flash_start         = 1.7
      @flash_duration      = 0.35
      @fade_to_white_start = 2.7
      @fade_to_white_end   = 3.0
      @fade_to_black_start = 3.3
    end

    def dispose_all
      # Dispose sprites
      @rear_black_sprite&.dispose
      @player_bar_sprite&.dispose
      @foe_bar_sprite&.dispose
      @player_sprite&.dispose
      @foe_sprite&.dispose
      @text_sprite&.dispose
      @vs_main_sprite&.dispose
      @vs_1_sprite&.dispose
      @vs_2_sprite&.dispose
      @black_sprite&.dispose
      # Dispose bitmaps
      @bar_bitmap&.dispose
      @vs_1_bitmap&.dispose
      @vs_2_bitmap&.dispose
      @player_bitmap&.dispose
      @foe_bitmap&.dispose
      @black_bitmap&.dispose
      # Dispose viewport
      @flash_viewport&.dispose
    end

    def update_anim
      # Bars/trainer sprites slide in
      if timer > @bar_appear_end
        @player_bar_sprite.x = @player_bar_x
        @player_sprite.x = @player_bar_sprite.x + TRAINER_X_OFFSET
        @foe_bar_sprite.x = @foe_bar_x
        @foe_sprite.x = @foe_bar_sprite.x + (@bar_bitmap.width / 2) - TRAINER_X_OFFSET
        @text_sprite.x = @foe_bar_sprite.x
      elsif timer > @bar_appear_start
        # Bars/trainer sprites slide in
        proportion = (timer - @bar_appear_start) / (@bar_appear_end - @bar_appear_start)
        sqrt_proportion = Math.sqrt(proportion)
        @player_bar_sprite.x = @player_bar_start_x + ((@player_bar_x + BAR_OVERSHOOT - @player_bar_start_x) * sqrt_proportion)
        @player_sprite.x = @player_bar_sprite.x + TRAINER_X_OFFSET
        @foe_bar_sprite.x = @foe_bar_start_x + ((@foe_bar_x - BAR_OVERSHOOT - @foe_bar_start_x) * sqrt_proportion)
        @foe_sprite.x = @foe_bar_sprite.x + (@bar_bitmap.width / 2) - TRAINER_X_OFFSET
        @text_sprite.x = @foe_bar_sprite.x
      end
      # Animate bars
      if timer >= @flash_start + (0.33 * @flash_duration)
        bar_phase = (timer * 30).to_i % @num_bar_frames
        @player_bar_sprite.src_rect.y = bar_phase * BAR_HEIGHT
        @foe_bar_sprite.src_rect.y = bar_phase * BAR_HEIGHT
      end
      # Vibrate VS sprite
      vs_phase = (timer * 30).to_i % 3
      @vs_main_sprite.x = (Graphics.width / 2) + [0, 4, 0][vs_phase]
      @vs_main_sprite.y = (Graphics.height / 2) + [0, 0, -4][vs_phase]
      # VS sprites appearing
      if timer >= @vs_appear_final
        @vs_1_sprite.visible = false
      elsif timer >= @vs_appear_start_2
        # Temp VS sprites enlarge and shrink again
        if @vs_2_sprite.visible
          @vs_2_sprite.zoom_x = 1.6 - (0.8 * (timer - @vs_appear_start_2) / @vs_shrink_time)
          @vs_2_sprite.zoom_y = @vs_2_sprite.zoom_x
          if @vs_2_sprite.zoom_x <= 1.2
            @vs_2_sprite.visible = false
            @vs_main_sprite.visible = true
          end
        end
        @vs_1_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start_2) / @vs_shrink_time)
        @vs_1_sprite.zoom_y = @vs_1_sprite.zoom_x
      elsif timer >= @vs_appear_start
        # Temp VS sprites appear and start shrinking
        @vs_2_sprite.visible = true
        @vs_2_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start) / @vs_shrink_time)
        @vs_2_sprite.zoom_y = @vs_2_sprite.zoom_x
        if @vs_1_sprite.visible || @vs_2_sprite.zoom_x <= 1.6   # Halfway between 2.0 and 1.2
          @vs_1_sprite.visible = true
          @vs_1_sprite.zoom_x = 2.0 - (0.8 * (timer - @vs_appear_start - (@vs_shrink_time / 2)) / @vs_shrink_time)
          @vs_1_sprite.zoom_y = @vs_1_sprite.zoom_x
        end
      end
      # Flash white (two flashes)
      if timer >= @flash_start + @flash_duration
        @flash_viewport.color.alpha = 0
      elsif timer >= @flash_start
        # Flash the screen white (coming from white lasts twice as long as going to white)
        proportion = (timer - @flash_start) / @flash_duration
        if proportion >= 0.33   # Coming from white
          @flash_viewport.color.alpha = 320 * 3 * (1 - proportion) / 2
          @player_sprite.color.alpha = 0
          @foe_sprite.color.alpha = 0
        else   # Going to white
          @flash_viewport.color.alpha = 320 * 3 * proportion
        end
      elsif timer >= @flash_1_start + @flash_1_duration
        @flash_viewport.color.alpha = 0
      elsif timer >= @flash_1_start
        # Flash the screen white
        proportion = (timer - @flash_1_start) / @flash_1_duration
        if proportion >= 0.5   # Coming from white
          @flash_viewport.color.alpha = 320 * 2 * (1 - proportion)
          @rear_black_sprite.visible = true
        else   # Going to white
          @flash_viewport.color.alpha = 320 * 2 * proportion
        end
      end
      # Fade to white at end
      if timer >= @fade_to_black_start
        # Fade to black
        @black_sprite.visible = true
        proportion = (timer - @fade_to_black_start) / (@duration - @fade_to_black_start)
        @flash_viewport.color.alpha = 255 * (1 - proportion)
      elsif timer >= @fade_to_white_start
        @text_sprite.visible = false
        # Slowly fade to white
        proportion = (timer - @fade_to_white_start) / (@fade_to_white_end - @fade_to_white_start)
        @flash_viewport.color.alpha = 255 * proportion
        # Move bars and trainer sprites off-screen
        dist = BAR_Y_INDENT + BAR_HEIGHT
        @player_bar_sprite.x = @player_bar_x - (dist * proportion)
        @player_bar_sprite.y = @player_bar_y - (dist * proportion)
        @player_sprite.x = @player_bar_sprite.x + TRAINER_X_OFFSET
        @player_sprite.y = @player_bar_sprite.y + BAR_HEIGHT - TRAINER_Y_OFFSET
        @foe_bar_sprite.x = @foe_bar_x + (dist * proportion)
        @foe_bar_sprite.y = @foe_bar_y + (dist * proportion)
        @foe_sprite.x = @foe_bar_sprite.x + (@bar_bitmap.width / 2) - TRAINER_X_OFFSET
        @foe_sprite.y = @foe_bar_sprite.y + @foe_bitmap.height - TRAINER_Y_OFFSET
      end
    end
  end

  #=============================================================================
  # HGSS Rocket Grunt trainer(s)
  #=============================================================================
  class RocketGrunt < Transition_Base
    DURATION     = 1.6
    ROCKET_X     = [ 1.5, -0.5, -0.5, 0.75,  1.5, -0.5]   # * Graphics.width
    ROCKET_Y     = [-0.5,  1.0, -0.5,  1.5,  0.5, 0.75]   # * Graphics.height
    ROCKET_ANGLE = [   1,  0.5, -1.5,   -1, -1.5,  0.5]   # * 360 * sprite.zoom_x

    def initialize_bitmaps
      @black_1_bitmap = RPG::Cache.transition("black_wedge_1")
      @black_2_bitmap = RPG::Cache.transition("black_wedge_2")
      @black_3_bitmap = RPG::Cache.transition("black_wedge_3")
      @black_4_bitmap = RPG::Cache.transition("black_wedge_4")
      @rocket_bitmap  = RPG::Cache.transition("rocket_logo")
      dispose if !@black_1_bitmap || !@black_2_bitmap || !@black_3_bitmap ||
                 !@black_4_bitmap || !@rocket_bitmap
    end

    def initialize_sprites
      # Rocket sprites
      @rocket_sprites = []
      ROCKET_X.length.times do |i|
        @rocket_sprites[i] = new_sprite(
          ROCKET_X[i] * Graphics.width, ROCKET_Y[i] * Graphics.height,
          @rocket_bitmap, @rocket_bitmap.width / 2, @rocket_bitmap.height / 2
        )
      end
      # Black wedges
      4.times do |i|
        b = [@black_1_bitmap, @black_2_bitmap, @black_3_bitmap, @black_4_bitmap][i]
        @sprites[i] = new_sprite((i == 1) ? 0 : Graphics.width / 2, (i == 2) ? 0 : Graphics.height / 2, b,
                                 (i.even?) ? b.width / 2 : 0, (i.even?) ? 0 : b.height / 2)
        @sprites[i].zoom_x  = 0.0 if i.even?
        @sprites[i].zoom_y  = 0.0 if i.odd?
        @sprites[i].visible = false
      end
    end

    def set_up_timings
      @rocket_appear_end   = @duration * 0.75
      @rocket_appear_delay = 1.0 / (ROCKET_X.length + 1)
      @rocket_appear_time  = @rocket_appear_delay * 2   # 2 logos on screen at once
    end

    def dispose_all
      # Dispose sprites
      @rocket_sprites.each { |s| s&.dispose }
      @rocket_sprites.clear
      # Dispose bitmaps
      @black_1_bitmap&.dispose
      @black_2_bitmap&.dispose
      @black_3_bitmap&.dispose
      @black_4_bitmap&.dispose
      @rocket_bitmap&.dispose
    end

    def update_anim
      if timer <= @rocket_appear_end
        # Rocket logos fly in from edges of screen
        proportion = timer / @rocket_appear_end
        @rocket_sprites.each_with_index do |sprite, i|
          next if !sprite.visible
          start_time = i * @rocket_appear_delay
          next if proportion < start_time
          single_proportion = (proportion - start_time) / @rocket_appear_time
          sqrt_single_proportion = Math.sqrt(single_proportion)
          sprite.x = (ROCKET_X[i] + ((0.5 - ROCKET_X[i]) * sqrt_single_proportion)) * Graphics.width
          sprite.y = (ROCKET_Y[i] + ((0.5 - ROCKET_Y[i]) * sqrt_single_proportion)) * Graphics.height
          sprite.zoom_x = 2.5 * (1 - single_proportion)
          sprite.zoom_y = sprite.zoom_x
          sprite.angle = sprite.zoom_x * ROCKET_ANGLE[i] * 360
          sprite.visible = false if sprite.zoom_x <= 0
        end
      else
        @rocket_sprites.last.visible = false
        # Black wedges expand to fill screen
        proportion = (timer - @rocket_appear_end) / (@duration - @rocket_appear_end)
        @sprites.each_with_index do |sprite, i|
          sprite.visible = true
          sprite.zoom_x = proportion if i.even?
          sprite.zoom_y = proportion if i.odd?
        end
      end
    end
  end

  #=============================================================================
  # HGSS VS Team Rocket Admin animation
  # Uses $game_temp.transition_animation_data, and expects it to be an array
  # like so: [:TRAINERTYPE, "display name"]
  # Bar graphics are named hgss_vsBar_TRAINERTYPE.png.
  # Trainer sprites are named hgss_vs_TRAINERTYPE.png.
  #=============================================================================
  class VSRocketAdmin < Transition_Base
    DURATION            = 3.1
    STROBE_SCROLL_SPEED = 1440
    FOE_SPRITE_Y        = 318

    def initialize_bitmaps
      @strobes_bitmap = RPG::Cache.transition("rocket_strobes")
      @bg_1_bitmap    = RPG::Cache.transition("rocket_bg_1")
      @bg_2_bitmap    = RPG::Cache.transition("rocket_bg_2")
      @foe_bitmap     = RPG::Cache.transition("rocket_#{$game_temp.transition_animation_data[0]}")
      @black_bitmap   = RPG::Cache.transition("black_half")
      dispose if !@strobes_bitmap || !@bg_1_bitmap || !@bg_2_bitmap || !@foe_bitmap || !@black_bitmap
    end

    def initialize_sprites
      @flash_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @flash_viewport.z     = 99999
      @flash_viewport.color = Color.new(255, 255, 255, 0)
      # Strobe sprites (need 2 of them to make them loop around)
      ((Graphics.width.to_f / @strobes_bitmap.width).ceil + 1).times do |i|
        spr = new_sprite(@strobes_bitmap.width * i, 0, @strobes_bitmap)
        spr.z       = 1
        spr.opacity = 0
        @sprites.push(spr)
      end
      # First bg sprite
      @bg_1_sprite = new_sprite(0, Graphics.height / 2, @bg_1_bitmap)
      @bg_1_sprite.z = 3
      @bg_1_sprite.src_rect.height = 0
      # Second bg sprite
      @bg_2_sprite = new_sprite(0, 0, @bg_2_bitmap)
      @bg_2_sprite.z       = 5
      @bg_2_sprite.opacity = 0
      # Foe sprite
      @foe_sprite = new_sprite(Graphics.width + @foe_bitmap.width, FOE_SPRITE_Y,
                               @foe_bitmap, @foe_bitmap.width / 2, @foe_bitmap.height)
      @foe_sprite.z = 7
      # Sprite with foe's name written in it
      @text_sprite = BitmapSprite.new(Graphics.width, Graphics.height - FOE_SPRITE_Y, @viewport)
      @text_sprite.y       = FOE_SPRITE_Y
      @text_sprite.z       = 8
      @text_sprite.visible = false
      pbSetSystemFont(@text_sprite.bitmap)
      pbDrawTextPositions(@text_sprite.bitmap,
                          [[$game_temp.transition_animation_data[1], 272, 8, :left,
                            Color.new(248, 248, 248), Color.new(72, 80, 80)]])
      # Foreground black
      @black_sprite = new_sprite(0, 0, @black_bitmap)
      @black_sprite.z       = 10
      @black_sprite.zoom_y  = 2.0
      @black_sprite.visible = false
    end

    def set_up_timings
      @strobes_x = 0
      @strobe_appear_end   = 0.15   # Starts appearing at 0.0
      # White flash between these two times
      @bg_1_appear_start   = 0.5
      @bg_1_appear_end     = 0.65
      @bg_2_appear_start   = 1.0   # Also when foe sprite/name start appearing
      @bg_2_appear_end     = 1.1   # Also when foe sprite/name end appearing
      @flash_end           = 1.35   # Starts at @bg_2_appear_end
      @foe_disappear_start = 2.1
      @foe_disappear_end   = 2.3   # Also when screen starts turning white
      @fade_to_white_end   = 2.5
      @fade_to_black_start = 2.9
    end

    def dispose_all
      # Dispose sprites
      @bg_1_sprite&.dispose
      @bg_2_sprite&.dispose
      @foe_sprite&.dispose
      @text_sprite&.dispose
      @black_sprite&.dispose
      # Dispose bitmaps
      @strobes_bitmap&.dispose
      @bg_1_bitmap&.dispose
      @bg_2_bitmap&.dispose
      @foe_bitmap&.dispose
      @black_bitmap&.dispose
      # Dispose viewport
      @flash_viewport&.dispose
    end

    def update_anim
      # Strobes scrolling
      if @sprites[0].visible
        @strobes_x = -timer * STROBE_SCROLL_SPEED
        while @strobes_x <= -@strobes_bitmap.width
          @strobes_x += @strobes_bitmap.width
        end
        @sprites.each_with_index { |spr, i| spr.x = @strobes_x + (i * @strobes_bitmap.width) }
      end
      if timer >= @fade_to_black_start
        # Fade to black
        proportion = (timer - @fade_to_black_start) / (@duration - @fade_to_black_start)
        @flash_viewport.color.alpha = 255 * (1 - proportion)
      elsif timer >= @fade_to_white_end
        @flash_viewport.color.alpha = 255   # Ensure screen is white
        @black_sprite.visible = true   # Make black overlay visible
      elsif timer >= @foe_disappear_end
        @foe_sprite.visible = false   # Ensure foe sprite has vanished
        @text_sprite.visible = false   # Ensure name sprite has vanished
        # Slowly fade to white
        proportion = (timer - @foe_disappear_end) / (@fade_to_white_end - @foe_disappear_end)
        @flash_viewport.color.alpha = 255 * proportion
      elsif timer >= @foe_disappear_start
        # Slide foe sprite/name off-screen
        proportion = (timer - @foe_disappear_start) / (@foe_disappear_end - @foe_disappear_start)
        start_x = Graphics.width / 2
        @foe_sprite.x = start_x - ((@foe_bitmap.width + start_x) * proportion * proportion)
        @text_sprite.x = @foe_sprite.x - (Graphics.width / 2)
      elsif timer >= @flash_end
        @flash_viewport.color.alpha = 0   # Ensure flash has ended
      elsif timer >= @bg_2_appear_end
        @bg_2_sprite.opacity = 255   # Ensure BG 2 sprite is fully opaque
        @foe_sprite.x = Graphics.width / 2   # Ensure foe sprite is in the right place
        @text_sprite.x = 0   # Ensure name sprite is in the right place
        # Flash screen
        proportion = (timer - @bg_2_appear_end) / (@flash_end - @bg_2_appear_end)
        @flash_viewport.color.alpha = 320 * (1 - proportion)
      elsif timer >= @bg_2_appear_start
        # BG 2 sprite appears
        proportion = (timer - @bg_2_appear_start) / (@bg_2_appear_end - @bg_2_appear_start)
        @bg_2_sprite.opacity = 255 * proportion
        # Foe sprite/name appear
        start_x = Graphics.width + (@foe_bitmap.width / 2)
        @foe_sprite.x = start_x + (((Graphics.width / 2) - start_x) * Math.sqrt(proportion))
        @text_sprite.x = @foe_sprite.x - (Graphics.width / 2)
        @text_sprite.visible = true
      elsif timer >= @bg_1_appear_end
        @bg_1_sprite.oy = Graphics.height / 2
        @bg_1_sprite.src_rect.y = 0
        @bg_1_sprite.src_rect.height = @bg_1_bitmap.height
        @sprites.each { |sprite| sprite.visible = false }   # Hide strobes
      elsif timer >= @bg_1_appear_start
        @flash_viewport.color.alpha = 0   # Ensure flash has ended
        # BG 1 sprite appears
        proportion = (timer - @bg_1_appear_start) / (@bg_1_appear_end - @bg_1_appear_start)
        half_height = ((proportion * @bg_1_bitmap.height) / 2).to_i
        @bg_1_sprite.src_rect.height = half_height * 2
        @bg_1_sprite.src_rect.y = (@bg_1_bitmap.height / 2) - half_height
        @bg_1_sprite.oy = half_height
      elsif timer >= @strobe_appear_end
        @sprites.each { |sprite| sprite.opacity = 255 }   # Ensure strobes are fully opaque
        # Flash the screen white
        proportion = (timer - @strobe_appear_end) / (@bg_1_appear_start - @strobe_appear_end)
        if proportion >= 0.5
          @flash_viewport.color.alpha = 320 * 2 * (1 - proportion)
        else
          @flash_viewport.color.alpha = 320 * proportion
        end
      else
        # Strobes fade in
        @sprites.each do |sprite|
          sprite.opacity = 255 * (timer / @strobe_appear_end)
        end
      end
    end
  end
end
