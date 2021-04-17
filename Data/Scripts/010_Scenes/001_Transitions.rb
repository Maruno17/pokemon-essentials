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

  def self.transition(duration = 8, filename = "", vague = 20)
    duration = duration.floor
    if judge_special_transition(duration, filename)
      duration = 0
      filename = ""
    end
    begin
      transition_KGC_SpecialTransition(duration, filename, vague)
    rescue Exception
      if filename != ""
        transition_KGC_SpecialTransition(duration, "", vague)
      end
    end
    if STOP_WHILE_TRANSITION && !@_interrupt_transition
      while @@transition && !@@transition.disposed?
        update
      end
    end
  end

  def self.update
    update_KGC_SpecialTransition
=begin
    if Graphics.frame_count % 40 == 0
      count = 0
      ObjectSpace.each_object(Object) { |o| count += 1 }
      echoln("Objects: #{count}")
    end
=end
    @@transition.update if @@transition && !@@transition.disposed?
    @@transition = nil if @@transition && @@transition.disposed?
  end

  def self.judge_special_transition(duration,filename)
    return false if @_interrupt_transition
    ret = true
    if @@transition && !@@transition.disposed?
      @@transition.dispose
      @@transition = nil
    end
    dc = File.basename(filename).downcase
    case dc
    # Other coded transitions
    when "breakingglass"    then @@transition = Transitions::BreakingGlass.new(duration)
    when "rotatingpieces"   then @@transition = Transitions::ShrinkingPieces.new(duration, true)
    when "shrinkingpieces"  then @@transition = Transitions::ShrinkingPieces.new(duration, false)
    when "splash"           then @@transition = Transitions::SplashTransition.new(duration)
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
    when ""                 then @@transition = Transitions::FadeFromBlack.new(duration)
    else                         ret = false
    end
    Graphics.frame_reset if ret
    return ret
  end
end



#===============================================================================
# Screen transition classes
#===============================================================================
module Transitions
  #=============================================================================
  #
  #=============================================================================
  class BreakingGlass
    def initialize(numframes)
      @disposed = false
      @numframes = numframes
      @opacitychange = (numframes<=0) ? 255 : 255.0/numframes
      cx = 6
      cy = 5
      @bitmap = Graphics.snap_to_bitmap
      if !@bitmap
        @disposed = true
        return
      end
      width  = @bitmap.width/cx
      height = @bitmap.height/cy
      @numtiles = cx*cy
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprites = []
      @offset = []
      @y = []
      for i in 0...@numtiles
        @sprites[i] = Sprite.new(@viewport)
        @sprites[i].bitmap = @bitmap
        @sprites[i].x = width*(i%cx)
        @sprites[i].y = height*(i/cx)
        @sprites[i].src_rect.set(@sprites[i].x,@sprites[i].y,width,height)
        @offset[i] = (rand(100)+1)*3.0/100.0
        @y[i] = @sprites[i].y
      end
    end

    def disposed?; @disposed; end

    def dispose
      if !disposed?
        @bitmap.dispose
        for i in 0...@numtiles
          @sprites[i].visible = false
          @sprites[i].dispose
        end
        @sprites.clear
        @viewport.dispose if @viewport
        @disposed = true
      end
    end

    def update
      return if disposed?
      continue = false
      for i in 0...@numtiles
        @sprites[i].opacity -= @opacitychange
        @y[i] += @offset[i]
        @sprites[i].y = @y[i]
        continue = true if @sprites[i].opacity>0
      end
      self.dispose if !continue
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ShrinkingPieces
    def initialize(numframes,rotation)
      @disposed = false
      @rotation = rotation
      @numframes = numframes
      @opacitychange = (numframes<=0) ? 255 : 255.0/numframes
      cx = 6
      cy = 5
      @bitmap = Graphics.snap_to_bitmap
      if !@bitmap
        @disposed = true
        return
      end
      width  = @bitmap.width/cx
      height = @bitmap.height/cy
      @numtiles = cx*cy
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprites = []
      for i in 0...@numtiles
        @sprites[i] = Sprite.new(@viewport)
        @sprites[i].bitmap = @bitmap
        @sprites[i].ox = width/2
        @sprites[i].oy = height/2
        @sprites[i].x = width*(i%cx)+@sprites[i].ox
        @sprites[i].y = height*(i/cx)+@sprites[i].oy
        @sprites[i].src_rect.set(width*(i%cx),height*(i/cx),width,height)
      end
    end

    def disposed?; @disposed; end

    def dispose
      if !disposed?
        @bitmap.dispose
        for i in 0...@numtiles
          @sprites[i].visible = false
          @sprites[i].dispose
        end
        @sprites.clear
        @viewport.dispose if @viewport
        @disposed = true
      end
    end

    def update
      return if disposed?
      continue = false
      for i in 0...@numtiles
        @sprites[i].opacity -= @opacitychange
        if @rotation
          @sprites[i].angle += 40
          @sprites[i].angle %= 360
        end
        @sprites[i].zoom_x = @sprites[i].opacity/255.0
        @sprites[i].zoom_y = @sprites[i].opacity/255.0
        continue = true if @sprites[i].opacity>0
      end
      self.dispose if !continue
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class SplashTransition
    SPLASH_SIZE = 32

    def initialize(numframes,vague=9.6)
      @duration = numframes
      @numframes = numframes
      @splash_dir = []
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @buffer = Graphics.snap_to_bitmap
      if !@buffer
        @disposed = true
        return
      end
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      size = SPLASH_SIZE
      size = [size,1].max
      cells = Graphics.width*Graphics.height/(size**2)
      rows = Graphics.width/size
      rect = Rect.new(0,0,size,size)
      mag = 40.0/@numframes
      cells.times { |i|
        rect.x = i%rows*size
        rect.y = i/rows*size
        x = rect.x/size-(rows>>1)
        y = rect.y/size-((cells/rows)>>1)
        r = Math.sqrt(x**2+y**2)/vague
        @splash_dir[i] = []
        if r!=0
          @splash_dir[i][0] = x/r
          @splash_dir[i][1] = y/r
        else
          @splash_dir[i][0] = (x!= 0) ? x*1.5 : pmrand*vague
          @splash_dir[i][1] = (y!= 0) ? y*1.5 : pmrand*vague
        end
        @splash_dir[i][0] += (rand-0.5)*vague
        @splash_dir[i][1] += (rand-0.5)*vague
        @splash_dir[i][0] *= mag
        @splash_dir[i][1] *= mag
      }
      @sprite.bitmap.blt(0,0,@buffer,@buffer.rect)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @sprite.visible = false
      @sprite.bitmap.dispose
      @sprite.dispose
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        size = SPLASH_SIZE
        cells = Graphics.width*Graphics.height/(size**2)
        rows = Graphics.width/size
        rect = Rect.new(0,0,size,size)
        buffer = @buffer
        sprite = @sprite
        phase = @numframes-@duration
        sprite.bitmap.clear
        cells.times { |i|
          rect.x = (i%rows)*size
          rect.y = (i/rows)*size
          dx = rect.x+@splash_dir[i][0]*phase
          dy = rect.y+@splash_dir[i][1]*phase
          sprite.bitmap.blt(dx,dy,buffer,rect)
        }
        sprite.opacity = 384*@duration/@numframes
        @duration -= 1
      end
    end

    private

    def pmrand
      return (rand(2)==0) ? 1 : -1
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class RandomStripeTransition
    RAND_STRIPE_SIZE = 2

    def initialize(numframes,direction)
      @duration = numframes
      @numframes = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @buffer = Graphics.snap_to_bitmap
      if !@buffer
        @disposed = true
        return
      end
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = Bitmap.new(Graphics.width,Graphics.height)
      ##########
      @direction = direction
      size = RAND_STRIPE_SIZE
      bands = ((@direction==0) ? Graphics.width : Graphics.height)/size
      @rand_stripe_deleted = []
      @rand_stripe_deleted_count = 0
      ary = (0...bands).to_a
      @rand_stripe_index_array = ary.sort_by { rand }
      ##########
      @sprite.bitmap.blt(0,0,@buffer,@buffer.rect)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @sprite.visible = false
      @sprite.bitmap.dispose
      @sprite.dispose
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        dir = @direction
        size = RAND_STRIPE_SIZE
        bands = ((dir==0) ? Graphics.width : Graphics.height)/size
        rect = Rect.new(0,0,(dir==0) ? size : Graphics.width,(dir==0) ? Graphics.height : size)
        buffer = @buffer
        sprite = @sprite
        count = (bands-bands*@duration/@numframes)-@rand_stripe_deleted_count
        while count > 0
          @rand_stripe_deleted[@rand_stripe_index_array.pop] = true
          @rand_stripe_deleted_count += 1
          count -= 1
        end
        sprite.bitmap.clear
        bands.to_i.times { |i|
          unless @rand_stripe_deleted[i]
            if dir==0
              rect.x = i*size
              sprite.bitmap.blt(rect.x,0,buffer,rect)
            else
              rect.y = i*size
              sprite.bitmap.blt(0,rect.y,buffer,rect)
            end
          end
        }
        @duration -= 1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ZoomInTransition
    def initialize(numframes)
      @duration = numframes
      @numframes = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @buffer = Graphics.snap_to_bitmap
      if !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = @buffer
      @sprite.ox = @width/2
      @sprite.oy = @height/2
      @sprite.x = @width/2
      @sprite.y = @height/2
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @sprite.dispose if @sprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        @sprite.zoom_x += 0.2
        @sprite.zoom_y += 0.2
        @sprite.opacity = (@duration-1)*255/@numframes
        @duration -= 1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class ScrollScreen
    def initialize(numframes,direction)
      @numframes = numframes
      @duration = numframes
      @dir = direction
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @buffer = Graphics.snap_to_bitmap
      if !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = @buffer
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @sprite.dispose if @sprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        case @dir
        when 1 # down left
          @sprite.y += (@height/@numframes)
          @sprite.x -= (@width/@numframes)
        when 2 # down
          @sprite.y += (@height/@numframes)
        when 3 # down right
          @sprite.y += (@height/@numframes)
          @sprite.x += (@width/@numframes)
        when 4 # left
          @sprite.x -= (@width/@numframes)
        when 6 # right
          @sprite.x += (@width/@numframes)
        when 7 # up left
          @sprite.y -= (@height/@numframes)
          @sprite.x -= (@width/@numframes)
        when 8 # up
          @sprite.y -= (@height/@numframes)
        when 9 # up right
          @sprite.y -= (@height/@numframes)
          @sprite.x += (@width/@numframes)
        end
        @duration -= 1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class MosaicTransition
    def initialize(numframes)
      @duration = numframes
      @numframes = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @buffer = Graphics.snap_to_bitmap
      if !@buffer
        @disposed = true
        return
      end
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = @buffer
      @bitmapclone = @buffer.clone
      @bitmapclone2 = @buffer.clone
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @sprite.dispose if @sprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        @bitmapclone2.stretch_blt(
           Rect.new(0,0,@buffer.width*@duration/@numframes,@buffer.height*@duration/@numframes),
           @bitmapclone,
           Rect.new(0,0,@buffer.width,@buffer.height))
        @buffer.stretch_blt(
           Rect.new(0,0,@buffer.width,@buffer.height),
           @bitmapclone2,
           Rect.new(0,0,@buffer.width*@duration/@numframes,@buffer.height*@duration/@numframes))
        @duration -= 1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeToBlack
    def initialize(numframes)
      @duration = numframes
      @numframes = numframes
      @disposed = false
      if @duration<=0
        @disposed = true
        return
      end
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprite = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
      @sprite.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
      @sprite.opacity = 0
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @sprite.dispose if @sprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        @sprite.opacity = (@numframes - @duration + 1) * 255 / @numframes
        @duration -= 1
      end
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class FadeFromBlack
    def initialize(numframes)
      @duration = numframes
      @numframes = numframes
      @disposed = false
      if @duration<=0
        @disposed = true
        return
      end
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprite = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
      @sprite.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
      @sprite.opacity = 255
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @sprite.dispose if @sprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        @sprite.opacity = (@duration-1)*255/@numframes
        @duration -= 1
      end
    end
  end

  #=============================================================================
  # HGSS wild outdoor
  #=============================================================================
  class SnakeSquares
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      @bitmap = RPG::Cache.transition("black_square")
      if !@bitmap
        @disposed = true
        return
      end
      width  = @bitmap.width
      height = @bitmap.height
      cx = Graphics.width/width     # 8
      cy = Graphics.height/height   # 6
      @numtiles = cx*cy
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprites = []
      @frame = []
      @addzoom  = 0.125*50/@numframes
      for i in 0...cy
        for j in 0...cx
          k = i*cx+j
          x = width*(j%cx)
          x = (cx-1)*width-x if (i<3 && i%2==1) || (i>=3 && i%2==0)
          @sprites[k] = Sprite.new(@viewport)
          @sprites[k].x = x+width/2
          @sprites[k].y = height*i
          @sprites[k].ox = width/2
          @sprites[k].visible = false
          @sprites[k].bitmap = @bitmap
          if k>=@numtiles/2
            @frame[k] = 2*(@numtiles-k-1)*(@numframes-1/@addzoom)/50
          else
            @frame[k] = 2*k*(@numframes-1/@addzoom)/50
          end
        end
      end
    end

    def disposed?; @disposed; end

    def dispose
      if !disposed?
        @bitmap.dispose
        for i in 0...@numtiles
          if @sprites[i]
            @sprites[i].visible = false
            @sprites[i].dispose
          end
        end
        @sprites.clear
        @viewport.dispose if @viewport
        @disposed = true
      end
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        count = @numframes-@duration
        for i in 0...@numtiles
          if @frame[i]<count && @frame[i]+(1/@addzoom)+1>=count
            @sprites[i].visible = true
            @sprites[i].zoom_x = @addzoom*(count-@frame[i])
            @sprites[i].zoom_x = 1.0 if @sprites[i].zoom_x>1.0
          end
        end
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS wild indoor day (origin=0)
  # HGSS wild indoor night (origin=3)
  # HGSS wild cave (origin=3)
  #=============================================================================
  class DiagonalBubble
    def initialize(numframes,origin=0)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      @bitmap = RPG::Cache.transition("black_square")
      if !@bitmap
        @disposed = true
        return
      end
      width  = @bitmap.width
      height = @bitmap.height
      cx = Graphics.width/width # 8
      cy = Graphics.height/height # 6
      @numtiles = cx*cy
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @sprites = []
      @frame = []
      # 1.2, 0.6 and 0.8 determined by trigonometry of default screen size
      l = 1.2*Graphics.width/(@numtiles-8)
      for i in 0...cy
        for j in 0...cx
          k = i*cx+j
          @sprites[k] = Sprite.new(@viewport)
          @sprites[k].x = width*j+width/2
          @sprites[k].y = height*i+height/2
          @sprites[k].ox = width/2
          @sprites[k].oy = height/2
          @sprites[k].visible = false
          @sprites[k].bitmap = @bitmap
          case origin
          when 1 then k = i*cx+(cx-1-j)               # Top right
          when 2 then k = @numtiles-1-(i*cx+(cx-1-j)) # Bottom left
          when 3 then k = @numtiles-1-k               # Bottom right
          end
          @frame[k] = ((0.6*j*width+0.8*i*height)*(@numframes/50.0)/l).floor
        end
      end
      @addzoom  = 0.125*50/@numframes
    end

    def disposed?; @disposed; end

    def dispose
      if !disposed?
        @bitmap.dispose
        for i in 0...@numtiles
          if @sprites[i]
            @sprites[i].visible = false
            @sprites[i].dispose
          end
        end
        @sprites.clear
        @viewport.dispose if @viewport
        @disposed = true
      end
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        count = @numframes-@duration
        for i in 0...@numtiles
          if @frame[i]<count && @frame[i]+(1/@addzoom)+1>=count
            @sprites[i].visible = true
            @sprites[i].zoom_x = @addzoom*(count-@frame[i])
            @sprites[i].zoom_x = 1.0 if @sprites[i].zoom_x>1.0
            @sprites[i].zoom_y = @sprites[i].zoom_x
          end
        end
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS wild water
  #=============================================================================
  class RisingSplash
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @bubblebitmap = RPG::Cache.transition("water_1")
      @splashbitmap = RPG::Cache.transition("water_2")
      @blackbitmap  = RPG::Cache.transition("black_half")
      @buffer = Graphics.snap_to_bitmap
      if !@bubblebitmap || !@splashbitmap || !@blackbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @rearsprite = Sprite.new(@viewport)
      @rearsprite.z = 1
      @rearsprite.zoom_y = 2.0
      @rearsprite.bitmap = @blackbitmap
      @bgsprites = []
      rect = Rect.new(0,0,@width,2)
      for i in 0...@height/2
        @bgsprites[i] = Sprite.new(@viewport)
        @bgsprites[i].y = i*2
        @bgsprites[i].z = 2
        @bgsprites[i].bitmap = @buffer
        rect.y = i*2
        @bgsprites[i].src_rect = rect
      end
      @bubblesprite = Sprite.new(@viewport)
      @bubblesprite.y = @height
      @bubblesprite.z = 3
      @bubblesprite.bitmap = @bubblebitmap
      @splashsprite = Sprite.new(@viewport)
      @splashsprite.y = @height
      @splashsprite.z = 4
      @splashsprite.bitmap = @splashbitmap
      @blacksprite = Sprite.new(@viewport)
      @blacksprite.y = @height
      @blacksprite.z = 5
      @blacksprite.zoom_y = 2.0
      @blacksprite.bitmap = @blackbitmap
      @bubblesuby = @height*2/@numframes
      @splashsuby = @bubblesuby*2
      @blacksuby  = @height/(@numframes*0.1).floor
      @angmult = 2/(@numframes/50.0)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @bubblebitmap.dispose if @bubblebitmap
      @bubblebitmap = nil
      @splashbitmap.dispose if @splashbitmap
      @splashbitmap = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @rearsprite.dispose if @rearsprite
      for i in @bgsprites; i.dispose if i; end
      @bgsprites.clear
      @bubblesprite.dispose if @bubblesprite
      @splashsprite.dispose if @splashsprite
      @blacksprite.dispose if @blacksprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        angadd = (@numframes-@duration)*@angmult
        amp = 6*angadd/8; amp = 6 if amp>6
        for i in 0...@bgsprites.length
          @bgsprites[i].x = amp*Math.sin((i+angadd)*Math::PI/10)
        end
        @bubblesprite.x = (@width-@bubblebitmap.width)/2
        @bubblesprite.x -= 32*Math.sin((@numframes-@duration)/(@numframes/50)*3*Math::PI/60)
        @bubblesprite.y -= @bubblesuby
        if @duration<@numframes*0.5
          @splashsprite.y -= @splashsuby
        end
        if @duration<@numframes*0.1
          @blacksprite.y -= @blacksuby
          @blacksprite.y = 0 if @blacksprite.y<0
        end
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer outdoor day
  #=============================================================================
  class TwoBallPass
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_half")
      @ballbitmap  = RPG::Cache.transition("ball_small")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @bgsprite = Sprite.new(@viewport)
      @bgsprite.x = @width/2
      @bgsprite.y = @height/2
      @bgsprite.ox = @width/2
      @bgsprite.oy = @height/2
      @bgsprite.bitmap = @buffer
      @blacksprites = []
      @ballsprites = []
      for i in 0...2
        @blacksprites[i] = Sprite.new(@viewport)
        @blacksprites[i].x = (1-i*2)*@width
        @blacksprites[i].y = i*@height/2
        @blacksprites[i].z = 1
        @blacksprites[i].bitmap = @blackbitmap
        @ballsprites[i] = Sprite.new(@viewport)
        @ballsprites[i].x = (1-i)*@width + (1-i*2)*@ballbitmap.width/2
        @ballsprites[i].y = @height/2 + (i*2-1)*@ballbitmap.height/2
        @ballsprites[i].z = 2
        @ballsprites[i].ox = @ballbitmap.width/2
        @ballsprites[i].oy = @ballbitmap.height/2
        @ballsprites[i].bitmap = @ballbitmap
      end
      @blacksprites[2] = Sprite.new(@viewport)
      @blacksprites[2].y = @height/2
      @blacksprites[2].z = 1
      @blacksprites[2].oy = @height/4
      @blacksprites[2].zoom_y = 0.0
      @blacksprites[2].bitmap = @blackbitmap
      @addxmult = 2.0*@width/((@numframes*0.6)**2)
      @addzoom  = 0.02*50/@numframes
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      @bgsprite.dispose if @bgsprite
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      for i in @ballsprites; i.dispose if i; end
      @ballsprites.clear
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      elsif @duration>=@numframes*0.6
        for i in 0...2
          @ballsprites[i].x += (2*i-1)*((@width+@ballbitmap.width)/(0.4*@numframes))
          @ballsprites[i].angle += (2*i-1)*(360.0/(0.2*@numframes))
        end
      else
        addx = (@numframes*0.6-@duration)*@addxmult
        for i in 0...2
          @bgsprite.zoom_x += @addzoom
          @bgsprite.zoom_y += @addzoom
          @blacksprites[i].x += (2*i-1)*addx
        end
        @blacksprites[2].zoom_y += 2*addx/@width
        @blacksprites[0].x = 0 if @blacksprites[0].x<0
        @blacksprites[1].x = 0 if @blacksprites[1].x>0
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer outdoor night
  #=============================================================================
  class SpinBallSplit
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_half")
      @ballbitmap  = RPG::Cache.transition("ball_large")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @bgsprites = []
      @blacksprites = []
      @ballsprites = []
      for i in 0...2
        @bgsprites[i] = Sprite.new(@viewport)
        @bgsprites[i].x = @width/2
        @bgsprites[i].y = @height/2
        @bgsprites[i].ox = @width/2
        @bgsprites[i].oy = (1-i)*@height/2
        @bgsprites[i].bitmap = @buffer
        @bgsprites[i].src_rect.set(0,i*@height/2,@width,@height/2)
        @blacksprites[i] = Sprite.new(@viewport)
        @blacksprites[i].x = (1-i*2)*@width
        @blacksprites[i].y = i*@height/2
        @blacksprites[i].z = 1
        @blacksprites[i].bitmap = @blackbitmap
        @ballsprites[i] = Sprite.new(@viewport)
        @ballsprites[i].x = @width/2
        @ballsprites[i].y = @height/2
        @ballsprites[i].z = 2
        @ballsprites[i].ox = @ballbitmap.width/2
        @ballsprites[i].oy = (1-i)*@ballbitmap.height/2
        @ballsprites[i].zoom_x = 0.0
        @ballsprites[i].zoom_y = 0.0
        @ballsprites[i].bitmap = @ballbitmap
      end
      @addxmult = 2.0*@width/((@numframes*0.5)**2)
      @addzoom  = 0.02*50/@numframes
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      for i in @bgsprites; i.dispose if i; end
      @bgsprites.clear
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      for i in @ballsprites; i.dispose if i; end
      @ballsprites.clear
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      elsif @duration>=@numframes*0.6
        if @ballsprites[0].zoom_x<1.0
          @ballsprites[0].zoom_x += (1.0/(0.4*@numframes))
          @ballsprites[0].zoom_y += (1.0/(0.4*@numframes))
          @ballsprites[0].angle -= (360.0/(0.4*@numframes))
          if @ballsprites[0].zoom_x>=1.0
            for i in 0...2
              @ballsprites[i].src_rect.set(0,i*@ballbitmap.height/2,
                 @ballbitmap.width,@ballbitmap.height/2)
              @ballsprites[i].zoom_x = @ballsprites[i].zoom_y = 1.0
              @ballsprites[i].angle = 0.0
            end
          end
        end
      # Gap between 0.6*@numframes and 0.5*@numframes
      elsif @duration<@numframes*0.5
        addx = (@numframes*0.5-@duration)*@addxmult
        for i in 0...2
          @bgsprites[i].x += (2*i-1)*addx
          @bgsprites[i].zoom_x += @addzoom
          @bgsprites[i].zoom_y += @addzoom
          @blacksprites[i].x += (2*i-1)*addx
          @ballsprites[i].x += (2*i-1)*addx
        end
        @blacksprites[0].x = 0 if @blacksprites[0].x<0
        @blacksprites[1].x = 0 if @blacksprites[1].x>0
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer indoor day
  #=============================================================================
  class ThreeBallDown
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_square")
      @ballbitmap  = RPG::Cache.transition("ball_small")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      cx = Graphics.width/@blackbitmap.width # 8
      cy = Graphics.height/@blackbitmap.height # 6
      @numtiles = cx*cy
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @bgsprite = Sprite.new(@viewport)
      @bgsprite.x = @width/2
      @bgsprite.y = @height/2
      @bgsprite.ox = @width/2
      @bgsprite.oy = @height/2
      @bgsprite.bitmap = @buffer
      @frame = []
      @blacksprites = []
      for i in 0...cy
        for j in 0...cx
          k = i*cx+j
          @blacksprites[k] = Sprite.new(@viewport)
          @blacksprites[k].x = @blackbitmap.width*j
          @blacksprites[k].y = @blackbitmap.height*i
          @blacksprites[k].visible = false
          @blacksprites[k].bitmap = @blackbitmap
          @frame[k] = (((cy-i-1)*8+[0,4,1,6,7,2,5,3][j])*(@numframes*0.75)/@numtiles).floor
        end
      end
      @ballsprites = []
      for i in 0...3
        @ballsprites[i] = Sprite.new(@viewport)
        @ballsprites[i].x = 96+i*160
        @ballsprites[i].y = -@ballbitmap.height-[400,0,100][i]
        @ballsprites[i].z = 2
        @ballsprites[i].ox = @ballbitmap.width/2
        @ballsprites[i].oy = @ballbitmap.height/2
        @ballsprites[i].bitmap = @ballbitmap
      end
      @addyball = (@height+400+@ballbitmap.height*2)/(0.25*@numframes)
      @addangle = 1.5*360/(0.25*@numframes)
      @addzoom  = 0.02*50/@numframes
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      @bgsprite.dispose if @bgsprite
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      for i in @ballsprites; i.dispose if i; end
      @ballsprites.clear
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      elsif @duration>=@numframes*0.75
        for i in 0...@ballsprites.length
          @ballsprites[i].y += @addyball
          @ballsprites[i].angle -= @addangle*([1,-1][(i==2) ? 1 : 0])
        end
      else
        count = (@numframes*0.75).floor-@duration
        for i in 0...@numtiles
          @blacksprites[i].visible = true if @frame[i]<=count
        end
        @bgsprite.zoom_x += @addzoom
        @bgsprite.zoom_y += @addzoom
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer indoor night
  # HGSS trainer cave
  #=============================================================================
  class BallDown
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_half")
      @curvebitmap = RPG::Cache.transition("black_curve")
      @ballbitmap  = RPG::Cache.transition("ball_small")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@curvebitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @bgsprite = Sprite.new(@viewport)
      @bgsprite.x = @width/2
      @bgsprite.y = @height/2
      @bgsprite.ox = @width/2
      @bgsprite.oy = @height/2
      @bgsprite.bitmap = @buffer
      @blacksprites = []
      @blacksprites[0] = Sprite.new(@viewport)
      @blacksprites[0].y = -@curvebitmap.height
      @blacksprites[0].z = 1
      @blacksprites[0].oy = @blackbitmap.height
      @blacksprites[0].zoom_y = 2.0
      @blacksprites[0].bitmap = @blackbitmap
      @blacksprites[1] = Sprite.new(@viewport)
      @blacksprites[1].y = -@curvebitmap.height
      @blacksprites[1].z = 1
      @blacksprites[1].bitmap = @curvebitmap
      @ballsprite = Sprite.new(@viewport)
      @ballsprite.x = @width/2
      @ballsprite.y = -@ballbitmap.height/2
      @ballsprite.z = 2
      @ballsprite.ox = @ballbitmap.width/2
      @ballsprite.oy = @ballbitmap.height/2
      @ballsprite.zoom_x = 0.25
      @ballsprite.zoom_y = 0.25
      @ballsprite.bitmap = @ballbitmap
      @addyball = (@height+@ballbitmap.height*2.5)/(0.5*@numframes)
      @addangle = 1.5*360/(0.5*@numframes)
      @addzoomball = 2.5/(0.5*@numframes)
      @addy = (@height+@curvebitmap.height)/(@numframes*0.5)
      @addzoom  = 0.02*50/@numframes
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @curvebitmap.dispose if @curvebitmap
      @curvebitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      @bgsprite.dispose if @bgsprite
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      @ballsprite.dispose
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      elsif @duration>=@numframes*0.5
        @ballsprite.y += @addyball
        @ballsprite.angle -= @addangle
        @ballsprite.zoom_x += @addzoomball
        @ballsprite.zoom_y += @addzoomball
      else
        @blacksprites[1].y += @addy
        @blacksprites[0].y = @blacksprites[1].y
        @bgsprite.zoom_x += @addzoom
        @bgsprite.zoom_y += @addzoom
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer water day
  #=============================================================================
  class WavyThreeBallUp
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_half")
      @ballbitmap  = RPG::Cache.transition("ball_small")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @rearsprite = Sprite.new(@viewport)
      @rearsprite.z = 1
      @rearsprite.zoom_y = 2.0
      @rearsprite.bitmap = @blackbitmap
      @bgsprites = []
      rect = Rect.new(0,0,@width,2)
      for i in 0...@height/2
        @bgsprites[i] = Sprite.new(@viewport)
        @bgsprites[i].y = i*2
        @bgsprites[i].z = 2
        @bgsprites[i].bitmap = @buffer
        rect.y = i*2
        @bgsprites[i].src_rect = rect
      end
      @blacksprites = []
      @ballsprites = []
      for i in 0...3
        @blacksprites[i] = Sprite.new(@viewport)
        @blacksprites[i].x = (i-1)*@width*2/3
        @blacksprites[i].y = [@height*1.5,@height*3.25,@height*2.5][i]
        @blacksprites[i].z = 3
        @blacksprites[i].zoom_y = 2.0
        @blacksprites[i].bitmap = @blackbitmap
        @ballsprites[i] = Sprite.new(@viewport)
        @ballsprites[i].x = (2*i+1)*@width/6
        @ballsprites[i].y = [@height*1.5,@height*3.25,@height*2.5][i]
        @ballsprites[i].z = 4
        @ballsprites[i].ox = @ballbitmap.width/2
        @ballsprites[i].oy = @ballbitmap.height/2
        @ballsprites[i].bitmap = @ballbitmap
      end
      @suby = (@height*3.5)/(@numframes*0.6)
      @angmult = 4/(@numframes/50.0)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      @rearsprite.dispose if @rearsprite
      for i in @bgsprites; i.dispose if i; end
      @bgsprites.clear
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      for i in @ballsprites; i.dispose if i; end
      @ballsprites.clear
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        angadd = (@numframes-@duration)*@angmult
        amp = 24*angadd/16; amp = 24 if amp>24
        for i in 0...@bgsprites.length
          @bgsprites[i].x = amp*Math.sin((i+angadd)*Math::PI/48)*((i%2)*2-1)
        end
        if @duration<@numframes*0.6
          for i in 0...3
            @blacksprites[i].y -= @suby
            @blacksprites[i].y = 0 if @blacksprites[i].y<0
            @ballsprites[i].y -= @suby
            @ballsprites[i].angle += (2*(i%2)-1)*(360.0/(0.2*@numframes))
          end
        end
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS trainer water night
  #=============================================================================
  class WavySpinBall
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @blackbitmap = RPG::Cache.transition("black_half")
      @ballbitmap  = RPG::Cache.transition("ball_large")
      @buffer = Graphics.snap_to_bitmap
      if !@blackbitmap || !@ballbitmap || !@buffer
        @disposed = true
        return
      end
      @width  = @buffer.width
      @height = @buffer.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @rearsprite = Sprite.new(@viewport)
      @rearsprite.z = 1
      @rearsprite.zoom_y = 2.0
      @rearsprite.bitmap = @blackbitmap
      @bgsprites = []
      rect = Rect.new(0,0,@width,2)
      for i in 0...@height/2
        @bgsprites[i] = Sprite.new(@viewport)
        @bgsprites[i].y = i*2
        @bgsprites[i].z = 2
        @bgsprites[i].bitmap = @buffer
        rect.y = i*2
        @bgsprites[i].src_rect = rect
      end
      @ballsprite = Sprite.new(@viewport)
      @ballsprite.x = @width/2
      @ballsprite.y = @height/2
      @ballsprite.z = 3
      @ballsprite.ox = @ballbitmap.width/2
      @ballsprite.oy = @ballbitmap.height/2
      @ballsprite.visible = false
      @ballsprite.bitmap = @ballbitmap
      @blacksprite = Sprite.new(@viewport)
      @blacksprite.x = @width/2
      @blacksprite.y = @height/2
      @blacksprite.z = 4
      @blacksprite.ox = @blackbitmap.width/2
      @blacksprite.oy = @blackbitmap.height/2
      @blacksprite.visible = false
      @blacksprite.bitmap = @blackbitmap
      @angmult = 4/(@numframes/50.0)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @buffer.dispose if @buffer
      @buffer = nil
      @blackbitmap.dispose if @blackbitmap
      @blackbitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      @rearsprite.dispose if @rearsprite
      for i in @bgsprites; i.dispose if i; end
      @bgsprites.clear
      @ballsprite.dispose if @ballsprite
      @blacksprite.dispose if @blacksprite
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      else
        angadd = (@numframes-@duration)*@angmult
        amp = 24*angadd/16; amp = 24 if amp>24
        for i in 0...@bgsprites.length
          @bgsprites[i].x = amp*Math.sin((i+angadd)*Math::PI/48)*((i%2)*2-1)
        end
        @ballsprite.visible = true
        if @duration>=@numframes*0.6
          @ballsprite.opacity = 255*(@numframes-@duration)/(@numframes*0.4)
          @ballsprite.angle = -360.0*(@numframes-@duration)/(@numframes*0.4)
        elsif @duration<@numframes*0.5
          @blacksprite.visible = true
          @blacksprite.zoom_x = (@numframes*0.5-@duration)/(@numframes*0.5)
          @blacksprite.zoom_y = 2*(@numframes*0.5-@duration)/(@numframes*0.5)
        end
      end
      @duration -= 1
    end
  end

  #=============================================================================
  # HGSS double trainers
  #=============================================================================
  class FourBallBurst
    def initialize(numframes)
      @numframes = numframes
      @duration = numframes
      @disposed = false
      if @numframes<=0
        @disposed = true
        return
      end
      @black1bitmap = RPG::Cache.transition("black_wedge_1")
      @black2bitmap = RPG::Cache.transition("black_wedge_2")
      @black3bitmap = RPG::Cache.transition("black_wedge_3")
      @black4bitmap = RPG::Cache.transition("black_wedge_4")
      @ballbitmap   = RPG::Cache.transition("ball_small")
      if !@black1bitmap || !@black2bitmap || !@black3bitmap || !@black4bitmap || !@ballbitmap
        @disposed = true
        return
      end
      @width  = Graphics.width
      @height = Graphics.height
      @viewport = Viewport.new(0,0,@width,@height)
      @viewport.z = 99999
      @ballsprites = []
      for i in 0...4
        @ballsprites[i] = Sprite.new(@viewport)
        @ballsprites[i].x = @width/2
        @ballsprites[i].y = @height/2
        @ballsprites[i].z = [2,1,3,0][i]
        @ballsprites[i].ox = @ballbitmap.width/2
        @ballsprites[i].oy = @ballbitmap.height/2
        @ballsprites[i].bitmap = @ballbitmap
      end
      @blacksprites = []
      for i in 0...4
        b = [@black1bitmap,@black2bitmap,@black3bitmap,@black4bitmap][i]
        @blacksprites[i] = Sprite.new(@viewport)
        @blacksprites[i].x = (i==1) ? 0 : @width/2
        @blacksprites[i].y = (i==2) ? 0 : @height/2
        @blacksprites[i].ox = (i%2==0) ? b.width/2 : 0
        @blacksprites[i].oy = (i%2==0) ? 0 : b.height/2
        @blacksprites[i].zoom_x = (i%2==0) ? 0.0 : 1.0
        @blacksprites[i].zoom_y = (i%2==0) ? 1.0 : 0.0
        @blacksprites[i].visible = false
        @blacksprites[i].bitmap = b
      end
      @addxball = (@width/2+@ballbitmap.width/2)/(@numframes*0.4)
      @addyball = (@height/2+@ballbitmap.height/2)/(@numframes*0.4)
      @addzoom  = 1.0/(@numframes*0.6)
    end

    def disposed?; @disposed; end

    def dispose
      return if disposed?
      @black1bitmap.dispose if @black1bitmap
      @black1bitmap = nil
      @black2bitmap.dispose if @black2bitmap
      @black2bitmap = nil
      @black3bitmap.dispose if @black3bitmap
      @black3bitmap = nil
      @black4bitmap.dispose if @black4bitmap
      @black4bitmap = nil
      @ballbitmap.dispose if @ballbitmap
      @ballbitmap = nil
      for i in @ballsprites; i.dispose if i; end
      @ballsprites.clear
      for i in @blacksprites; i.dispose if i; end
      @blacksprites.clear
      @viewport.dispose if @viewport
      @disposed = true
    end

    def update
      return if disposed?
      if @duration==0
        dispose
      elsif @duration>=@numframes*0.6
        for i in 0...@ballsprites.length
          @ballsprites[i].x += (i==1) ? @addxball : (i==3) ? -@addxball : 0
          @ballsprites[i].y += (i==0) ? @addyball : (i==2) ? -@addyball : 0
        end
      else
        for i in 0...@blacksprites.length
          @blacksprites[i].visible = true
          @blacksprites[i].zoom_x += (i%2==0) ? @addzoom : 0
          @blacksprites[i].zoom_y += (i%2==0) ? 0 : @addzoom
        end
      end
      @duration -= 1
    end
  end
end
