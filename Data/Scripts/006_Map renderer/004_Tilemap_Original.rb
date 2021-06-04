#===============================================================================
#
#===============================================================================
class SynchronizedTilemapAutotilesInternal
  def initialize(oldat)
    @atdisposables = [[],[],[],[],[],[],[]]
    @atframes      = [[],[],[],[],[],[],[]]
    @atframe       = [-1,-1,-1,-1,-1,-1,-1]
    @autotiles     = []
    @oldat         = oldat
  end

  def dispose
    for i in 0...7
      for bitmap in @atdisposables[i]
        bitmap.dispose
      end
      @atdisposables[i].clear
      @atframes[i].clear
    end
  end

  def [](i)
    return @autotiles[i]
  end

  def []=(i,value)
    for frame in @atdisposables[i]
      frame.dispose
    end
    @atframe[i] = -1
    @atframes[i].clear
    @atdisposables[i].clear
    if value && !value.disposed?
      if value.height==32
        frames = value.width/32
        for j in 0...frames
          @atdisposables[i][j] = Bitmap.new(32,32)
          @atdisposables[i][j].blt(0,0,value,Rect.new(j*32,0,32,32))
          @atframes[i][j] = @atdisposables[i][j]
        end
      elsif value.height==128
        frames = value.width/96
        for j in 0...frames
          @atdisposables[i][j] = Bitmap.new(96,128)
          @atdisposables[i][j].blt(0,0,value,Rect.new(j*96,0,96,128))
          @atframes[i][j] = @atdisposables[i][j]
        end
      else
        @atframes[i][0] = value
      end
    else
      @atframes[i][0] = value
    end
    @autotiles[i] = value
    sync
  end

  def sync
    for i in 0...7
      frames = [1,@atframes[i].length].max
      frame = (Graphics.frame_count/15)%frames
      if frames>1 && @atframe[i]!=frame
        @oldat[i] = @atframes[i][frame]
        @atframe[i] = frame
      end
    end
  end
end



class SynchronizedTilemapAutotiles
  def initialize(autotiles)
    @autotiles = autotiles
  end

  def [](i)
    return @autotiles[i]
  end

  def []=(i,value)
    @autotiles[i] = value
  end
end



class SynchronizedTilemap < Tilemap
  # This class derives from Tilemap just to synchronize
  # the tilemap animation.
  attr_accessor :numupdates

  def initialize(viewport=nil)
    super(viewport)
    @updating  = true
    @autotiles = SynchronizedTilemapAutotilesInternal.new(self.autotiles)
    @autos     = SynchronizedTilemapAutotiles.new(@autotiles)
    @updating  = false
  end

  def dispose
    @autotiles.dispose
    super
  end

  def autotiles
    return @autos if !@updating
    super
  end

  def update
    return if disposed?
    @autotiles.sync
    super
  end
end
