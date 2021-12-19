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
    duration *= Graphics.frame_rate / 20   # For default fade-in animation
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
    @@transition = nil if @@transition && @@transition.disposed?
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
      @timer = 0.0
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

    def dispose
      return if disposed?
      dispose_all
      @sprites.each { |s| s.dispose if s }
      @sprites.clear
      @overworld_sprite.dispose
      @overworld_bitmap.dispose if @overworld_bitmap
      @viewport.dispose if @viewport
      @disposed = true
    end

    def disposed?; return @disposed; end

    def update
      return if disposed?
      @timer += Graphics.delta_s
      if @timer >= @duration
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @sprites[idx_sprite] = new_sprite(i * sprite_width, j * sprite_height, @overworld_bitmap)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def set_up_timings
      @start_y = []
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @start_y[idx_sprite] = @sprites[idx_sprite].y
          @timings[idx_sprite] = 0.5 + rand
        end
      end
    end

    def update_anim
      proportion = @timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.y = @start_y[i] + Graphics.height * @timings[i] * proportion * proportion
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @sprites[idx_sprite] = new_sprite((i + 0.5) * sprite_width, (j + 0.5) * sprite_height,
                                            @overworld_bitmap, sprite_width / 2, sprite_height / 2)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def update_anim
      proportion = @timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.zoom_x = 1.0 * (1 - proportion)
        sprite.zoom_y = sprite.zoom_x
        if @parameters[0]   # Rotation
          direction = (1 - 2 * ((i / NUM_SPRITES_X + i % NUM_SPRITES_X) % 2))
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
      @black_sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      # Overworld sprites
      sprite_width = @overworld_bitmap.width / NUM_SPRITES_X
      sprite_height = @overworld_bitmap.height / NUM_SPRITES_Y
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          spr = @sprites[idx_sprite]
          @start_positions[idx_sprite] = [spr.x, spr.y]
          dx = spr.x - Graphics.width / 2
          dy = spr.y - Graphics.height / 2
          move_x = move_y = 0
          if dx == 0 && dy == 0
            move_x = (dx == 0) ? rand_sign * vague : dx * SPEED * 1.5
            move_y = (dy == 0) ? rand_sign * vague : dy * SPEED * 1.5
          else
            radius = Math.sqrt(dx**2 + dy**2)
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
      proportion = @timer / @duration
      @sprites.each_with_index do |sprite, i|
        sprite.x = @start_positions[i][0] + @move_vectors[i][0] * proportion
        sprite.y = @start_positions[i][1] + @move_vectors[i][1] * proportion
        sprite.opacity = 384 * (1 - proportion)
      end
    end

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
      for j in 0...num_stripes_y
        for i in 0...num_stripes_x
          idx_sprite = j * num_stripes_x + i
          @sprites[idx_sprite] = new_sprite(i * sprite_width, j * sprite_height, @overworld_bitmap)
          @sprites[idx_sprite].src_rect.set(i * sprite_width, j * sprite_height, sprite_width, sprite_height)
        end
      end
    end

    def set_up_timings
      for i in 0...@sprites.length
        @timings[i] = @duration * i / @sprites.length
      end
      @timings.shuffle!
    end

    def update_anim
      @sprites.each_with_index do |sprite, i|
        next if @timings[i] < 0 || @timer < @timings[i]
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
      proportion = @timer / @duration
      @overworld_sprite.zoom_x = 1.0 + 7.0 * proportion
      @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
      @overworld_sprite.opacity = 255 * (1 - proportion)
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ScrollScreen < Transition_Base
    def update_anim
      proportion = @timer / @duration
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
      @buffer_original.dispose if @buffer_original
      @buffer_temp.dispose if @buffer_temp
    end

    def update_anim
      proportion = @timer / @duration
      inv_proportion = 1 / (1 + proportion * (MAX_PIXELLATION_FACTOR - 1))
      new_size_rect = Rect.new(0, 0, @overworld_bitmap.width * inv_proportion,
                               @overworld_bitmap.height * inv_proportion)
      # Take all of buffer_original, shrink it and put it into buffer_temp
      @buffer_temp.stretch_blt(new_size_rect,
         @buffer_original, Rect.new(0, 0, @overworld_bitmap.width, @overworld_bitmap.height))
      # Take shrunken area from buffer_temp and stretch it into buffer
      @overworld_bitmap.stretch_blt(Rect.new(0, 0, @overworld_bitmap.width, @overworld_bitmap.height),
         @buffer_temp, new_size_rect)
      if @timer >= @start_black_fade
        @overworld_sprite.opacity = 255 * (1 - (@timer - @start_black_fade) / (@duration - @start_black_fade))
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeToBlack < Transition_Base
    def update_anim
      @overworld_sprite.opacity = 255 * (1 - (@timer / @duration))
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeFromBlack < Transition_Base
    def update_anim
      @overworld_sprite.opacity = 255 * @timer / @duration
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
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
        next if @timings[i] < 0 || @timer < @timings[i]
        sprite.visible = true
        sprite.zoom_x = @zoom_x_target * (@timer - @timings[i]) / TIME_TO_ZOOM
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @sprites[idx_sprite] = new_sprite((i * @bitmap.width + @bitmap.width / 2) * @zoom_x_target,
                                            (j * @bitmap.height + @bitmap.height / 2) * @zoom_y_target,
                                            @bitmap, @bitmap.width / 2, @bitmap.height / 2)
          @sprites[idx_sprite].visible = false
        end
      end
    end

    def set_up_timings
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_from_start = j * NUM_SPRITES_X + i   # Top left -> bottom right
          case @parameters[0]   # Origin
          when 1   # Top right -> bottom left
            idx_from_start = j * NUM_SPRITES_X + NUM_SPRITES_X - i - 1
          when 2   # Bottom left -> top right
            idx_from_start = TOTAL_SPRITES - 1 - (j * NUM_SPRITES_X + NUM_SPRITES_X - i - 1)
          when 3   # Bottom right -> top left
            idx_from_start = TOTAL_SPRITES - 1 - idx_from_start
          end
          dist = i + j.to_f * (NUM_SPRITES_X - 1) / (NUM_SPRITES_Y - 1)
          @timings[idx_from_start] = (dist / ((NUM_SPRITES_X - 1) * 2)) * (@duration - TIME_TO_ZOOM)
        end
      end
    end

    def dispose_all
      @bitmap.dispose
    end

    def update_anim
      @sprites.each_with_index do |sprite, i|
        next if @timings[i] < 0 || @timer < @timings[i]
        sprite.visible = true
        size = (@timer - @timings[i]) / TIME_TO_ZOOM
        sprite.zoom_x = @zoom_x_target * size
        sprite.zoom_y = @zoom_y_target * size
        if size >= 1.0
          sprite.zoom_x = @zoom_x_target
          sprite.zoom_y = @zoom_y_target
          @timings[i] = -1
        end
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
      for i in 0...Graphics.height / 2
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
      @bubbles_sprite.dispose if @bubbles_sprite
      @splash_sprite.dispose if @splash_sprite
      @black_sprite.dispose if @black_sprite
      # Dispose bitmaps
      @bubble_bitmap.dispose if @bubble_bitmap
      @splash_bitmap.dispose if @splash_bitmap
      @black_bitmap.dispose if @black_bitmap
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [@timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = amplitude * Math.sin(@timer * WAVE_SPEED + i * WAVE_SPACING)
      end
      # Move bubbles sprite up and oscillate side to side
      @bubbles_sprite.x = (Graphics.width - @bubble_bitmap.width) / 2
      @bubbles_sprite.x += MAX_BUBBLE_AMPLITUDE * Math.sin(@timer * BUBBLES_WAVE_SPEED)
      @bubbles_sprite.y = Graphics.height * (1 - @timer * 1.2)
      # Move splash sprite up
      if @timer >= @splash_rising_start
        proportion = (@timer - @splash_rising_start) / (@duration - @splash_rising_start)
        @splash_sprite.y = Graphics.height * (1 - proportion * 2)
      end
      # Move black sprite up
      if @timer >= @black_rising_start
        proportion = (@timer - @black_rising_start) / (@duration - @black_rising_start)
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
      for i in 0...2
        x = (1 - i) * Graphics.width + (1 - i * 2) * @ball_bitmap.width / 2
        y = (Graphics.height + (i * 2 - 1) * @ball_bitmap.width) / 2
        @ball_sprites[i] = new_sprite(x, y, @ball_bitmap,
                                      @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 2
      end
      # Black foreground sprites
      for i in 0...2
        @sprites[i] = new_sprite((1 - i * 2) * Graphics.width, i * Graphics.height / 2, @black_bitmap)
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
        @ball_sprites.each { |s| s.dispose if s }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      if @timer <= @ball_roll_end
        # Roll ball sprites across screen
        proportion = @timer / @ball_roll_end
        total_distance = Graphics.width + @ball_bitmap.width
        @ball_sprites.each_with_index do |sprite, i|
          sprite.x = @ball_start_x[i] + (2 * i - 1) * (total_distance * proportion)
          sprite.angle = (2 * i - 1) * 360 * proportion * 2
        end
      else
        proportion = (@timer - @ball_roll_end) / (@duration - @ball_roll_end)
        # Hide ball sprites
        if @ball_sprites[0].visible
          @ball_sprites.each { |s| s.visible = false }
        end
        # Zoom in overworld sprite
        @overworld_sprite.zoom_x = 1.0 + proportion * proportion   # Ends at 2x zoom
        @overworld_sprite.zoom_y = @overworld_sprite.zoom_x
        # Slide first two black bars across
        @sprites[0].x = Graphics.width * (1 - proportion * proportion)
        @sprites[1].x = Graphics.width * (proportion * proportion - 1)
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
      for i in 0...2
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
        @overworld_sprites.each { |s| s.dispose if s }
        @overworld_sprites.clear
      end
      if @black_sprites
        @black_sprites.each { |s| s.dispose if s }
        @black_sprites.clear
      end
      if @ball_sprites
        @ball_sprites.each { |s| s.dispose if s }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      if @timer < @ball_spin_end
        # Ball spin
        proportion = @timer / @ball_spin_end
        @ball_sprites[0].zoom_x = proportion
        @ball_sprites[0].zoom_y = proportion
        @ball_sprites[0].angle = 360 * (1 - proportion)
      elsif @timer < @slide_start
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
        proportion = (@timer - @slide_start) / (@duration - @slide_start)
        @overworld_sprites.each_with_index do |sprite, i|
          sprite.x = (0.5 + (i * 2 - 1) * proportion * proportion) * Graphics.width
          sprite.zoom_x = 1.0 + proportion * proportion   # Ends at 2x zoom
          sprite.zoom_y = sprite.zoom_x
          @black_sprites[i].x = sprite.x + (1 - i * 2) * Graphics.width / 2
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
      for j in 0...NUM_SPRITES_Y
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @sprites[idx_sprite] = new_sprite(i * @black_bitmap.width * @zoom_x_target,
                                            j * @black_bitmap.height * @zoom_y_target, @black_bitmap)
          @sprites[idx_sprite].visible = false
        end
      end
      # Falling balls
      @ball_sprites = []
      for i in 0...3
        @ball_sprites[i] = new_sprite(Graphics.width / 2 + (i - 1) * 160,
                                      -@ball_bitmap.height - BALL_START_Y_OFFSETS[i],
                                      @ball_bitmap, @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 2
      end
    end

    def set_up_timings
      @black_appear_start = @duration * 0.2
      appear_order = [0, 4, 1, 6, 7, 2, 5, 3]
      period = @duration - @black_appear_start
      for j in 0...NUM_SPRITES_Y
        row_offset = NUM_SPRITES_Y - j - 1
        for i in 0...NUM_SPRITES_X
          idx_sprite = j * NUM_SPRITES_X + i
          @timings[idx_sprite] = period * (row_offset * NUM_SPRITES_X + appear_order[i]) / TOTAL_SPRITES
          @timings[idx_sprite] += @black_appear_start
        end
      end
    end

    def dispose_all
      # Dispose sprites
      if @ball_sprites
        @ball_sprites.each { |s| s.dispose if s }
        @ball_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      if @timer < @black_appear_start
        # Balls drop down screen while spinning
        proportion = @timer / @black_appear_start
        @ball_sprites.each_with_index do |sprite, i|
          sprite.y = -@ball_bitmap.height - BALL_START_Y_OFFSETS[i]
          sprite.y += (Graphics.height + BALL_START_Y_OFFSETS.max + @ball_bitmap.height * 2) * proportion
          sprite.angle = 1.5 * 360 * proportion * ([1, -1][(i == 2) ? 0 : 1])
        end
      else
        if @ball_sprites[0].visible
          @ball_sprites.each { |s| s.visible = false }
        end
        # Black squares appear
        @timings.each_with_index do |timing, i|
          next if timing < 0 || @timer < timing
          @sprites[i].visible = true
          @timings[i] = -1
        end
        # Zoom in overworld sprite
        proportion = (@timer - @black_appear_start) / (@duration - @black_appear_start)
        @overworld_sprite.zoom_x = 1.0 + proportion * proportion   # Ends at 2x zoom
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
      @ball_sprite.dispose if @ball_sprite
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @curve_bitmap.dispose if @curve_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      if @timer <= @ball_appear_end
        # Make ball drop down and zoom in
        proportion = @timer / @ball_appear_end
        @ball_sprite.y = -@ball_bitmap.height / 2 + (Graphics.height + @ball_bitmap.height * 3) * proportion * proportion
        @ball_sprite.angle = -1.5 * 360 * proportion
        @ball_sprite.zoom_x = 3 * proportion * proportion
        @ball_sprite.zoom_y = @ball_sprite.zoom_x
      else
        @ball_sprite.visible = false
        # Black curve and blackness descends
        proportion = (@timer - @ball_appear_end) / (@duration - @ball_appear_end)
        @sprites.each do |sprite|
          sprite.y = -@curve_bitmap.height + (Graphics.height + @curve_bitmap.height) * proportion
        end
        # Zoom in overworld sprite
        @overworld_sprite.zoom_x = 1.0 + proportion * proportion   # Ends at 2x zoom
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
      for i in 0...Graphics.height / 4
        @sprites[i] = new_sprite(0, i * 4, @overworld_bitmap)
        @sprites[i].z = 2
        rect.y = i * 4
        @sprites[i].src_rect = rect
      end
      # Ball sprites
      @ball_sprites = []
      for i in 0...3
        @ball_sprites[i] = new_sprite((2 * i + 1) * Graphics.width / 6,
                                      BALL_OFFSETS[i] * Graphics.height,
                                      @ball_bitmap, @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = 4
      end
      # Black columns that follow the ball sprites
      @black_trail_sprites = []
      for i in 0...3
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
        @ball_sprites.each { |s| s.dispose if s }
        @ball_sprites.clear
      end
      if @black_trail_sprites
        @black_trail_sprites.each { |s| s.dispose if s }
        @black_trail_sprites.clear
      end
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [@timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = (1 - (i % 2) * 2) * amplitude * Math.sin(@timer * WAVE_SPEED + i * WAVE_SPACING)
      end
      # Move balls and trailing blackness up
      if @timer >= @ball_rising_start
        proportion = (@timer - @ball_rising_start) / (@duration - @ball_rising_start)
        @ball_sprites.each_with_index do |sprite, i|
          sprite.y = BALL_OFFSETS[i] * Graphics.height - Graphics.height * 3.5 * proportion
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
      for i in 0...Graphics.height / 4
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
      @ball_sprite.dispose if @ball_sprite
      @black_sprite.dispose if @black_sprite
      # Dispose bitmaps
      @black_bitmap.dispose if @black_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      # Make overworld wave strips oscillate
      amplitude = MAX_WAVE_AMPLITUDE * [@timer / 0.1, 1].min   # Build up to max in 0.1 seconds
      @sprites.each_with_index do |sprite, i|
        sprite.x = (1 - (i % 2) * 2) * amplitude * Math.sin(@timer * WAVE_SPEED + i * WAVE_SPACING)
      end
      if @timer <= @ball_appear_end
        # Fade in ball while spinning
        proportion = @timer / @ball_appear_end
        @ball_sprite.opacity = 255 * proportion
        @ball_sprite.angle = -360 * proportion
      elsif @timer <= @black_appear_start
        # Fix opacity/angle of ball sprite
        @ball_sprite.opacity = 255
        @ball_sprite.angle = 0
      else
        # Spread blackness from centre
        proportion = (@timer - @black_appear_start) / (@duration - @black_appear_start)
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
      for i in 0...4
        @ball_sprites[i] = new_sprite(Graphics.width / 2, Graphics.height / 2, @ball_bitmap,
                                      @ball_bitmap.width / 2, @ball_bitmap.height / 2)
        @ball_sprites[i].z = [2, 1, 3, 0][i]
      end
      # Black wedges
      for i in 0...4
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
      @ball_sprites.each { |s| s.dispose if s }
      @ball_sprites.clear
      # Dispose bitmaps
      @black_1_bitmap.dispose if @black_1_bitmap
      @black_2_bitmap.dispose if @black_2_bitmap
      @black_3_bitmap.dispose if @black_3_bitmap
      @black_4_bitmap.dispose if @black_4_bitmap
      @ball_bitmap.dispose if @ball_bitmap
    end

    def update_anim
      if @timer <= @ball_appear_end
        # Balls fly out from centre of screen
        proportion = @timer / @ball_appear_end
        ball_travel_x = (Graphics.width + @ball_bitmap.width * 2) / 2
        ball_travel_y = (Graphics.height + @ball_bitmap.height * 2) / 2
        @ball_sprites.each_with_index do |sprite, i|
          sprite.x = Graphics.width / 2 + [0, 1, 0, -1][i] * ball_travel_x * proportion if i.odd?
          sprite.y = Graphics.height / 2 + [1, 0, -1, 0][i] * ball_travel_y * proportion if i.even?
        end
      else
        # Black wedges expand to fill screen
        proportion = (@timer - @ball_appear_end) / (@duration - @ball_appear_end)
        @sprites.each_with_index do |sprite, i|
          sprite.visible = true
          sprite.zoom_x = proportion if i.even?
          sprite.zoom_y = proportion if i.odd?
        end
      end
    end
  end
end
