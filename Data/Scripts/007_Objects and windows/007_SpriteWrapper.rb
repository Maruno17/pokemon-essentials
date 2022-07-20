#===============================================================================
# SpriteWrapper is a class which wraps (most of) Sprite's properties.
# (unused) Use class Sprite instead
#===============================================================================
class SpriteWrapper
  def initialize(viewport = nil)
    @sprite = Sprite.new(viewport)
  end

  def dispose;                @sprite.dispose;                       end
  def disposed?;              return @sprite.disposed?;              end
  def viewport;               return @sprite.viewport;               end
  def flash(color, duration); return @sprite.flash(color, duration); end
  def update;                 return @sprite.update;                 end
  def x;                      @sprite.x;                             end
  def x=(value);              @sprite.x = value;                     end
  def y;                      @sprite.y;                             end
  def y=(value);              @sprite.y = value;                     end
  def bitmap;                 @sprite.bitmap;                        end
  def bitmap=(value);         @sprite.bitmap = value;                end
  def src_rect;               @sprite.src_rect;                      end
  def src_rect=(value);       @sprite.src_rect = value;              end
  def visible;                @sprite.visible;                       end
  def visible=(value);        @sprite.visible = value;               end
  def z;                      @sprite.z;                             end
  def z=(value);              @sprite.z = value;                     end
  def ox;                     @sprite.ox;                            end
  def ox=(value);             @sprite.ox = value;                    end
  def oy;                     @sprite.oy;                            end
  def oy=(value);             @sprite.oy = value;                    end
  def zoom_x;                 @sprite.zoom_x;                        end
  def zoom_x=(value);         @sprite.zoom_x = value;                end
  def zoom_y;                 @sprite.zoom_y;                        end
  def zoom_y=(value);         @sprite.zoom_y = value;                end
  def angle;                  @sprite.angle;                         end
  def angle=(value);          @sprite.angle = value;                 end
  def mirror;                 @sprite.mirror;                        end
  def mirror=(value);         @sprite.mirror = value;                end
  def bush_depth;             @sprite.bush_depth;                    end
  def bush_depth=(value);     @sprite.bush_depth = value;            end
  def opacity;                @sprite.opacity;                       end
  def opacity=(value);        @sprite.opacity = value;               end
  def blend_type;             @sprite.blend_type;                    end
  def blend_type=(value);     @sprite.blend_type = value;            end
  def color;                  @sprite.color;                         end
  def color=(value);          @sprite.color = value;                 end
  def tone;                   @sprite.tone;                          end
  def tone=(value);           @sprite.tone = value;                  end

  def viewport=(value)
    return if self.viewport == value
    bitmap     = @sprite.bitmap
    src_rect   = @sprite.src_rect
    visible    = @sprite.visible
    x          = @sprite.x
    y          = @sprite.y
    z          = @sprite.z
    ox         = @sprite.ox
    oy         = @sprite.oy
    zoom_x     = @sprite.zoom_x
    zoom_y     = @sprite.zoom_y
    angle      = @sprite.angle
    mirror     = @sprite.mirror
    bush_depth = @sprite.bush_depth
    opacity    = @sprite.opacity
    blend_type = @sprite.blend_type
    color      = @sprite.color
    tone       = @sprite.tone
    @sprite.dispose
    @sprite = Sprite.new(value)
    @sprite.bitmap     = bitmap
    @sprite.src_rect   = src_rect
    @sprite.visible    = visible
    @sprite.x          = x
    @sprite.y          = y
    @sprite.z          = z
    @sprite.ox         = ox
    @sprite.oy         = oy
    @sprite.zoom_x     = zoom_x
    @sprite.zoom_y     = zoom_y
    @sprite.angle      = angle
    @sprite.mirror     = mirror
    @sprite.bush_depth = bush_depth
    @sprite.opacity    = opacity
    @sprite.blend_type = blend_type
    @sprite.color      = color
    @sprite.tone       = tone
  end
end



#===============================================================================
# Sprite class that maintains a bitmap of its own.
# This bitmap can't be changed to a different one.
#===============================================================================
class BitmapSprite < Sprite
  def initialize(width, height, viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(width, height)
    @initialized = true
  end

  def bitmap=(value)
    super(value) if !@initialized
  end

  def dispose
    self.bitmap.dispose if !self.disposed?
    super
  end
end



#===============================================================================
#
#===============================================================================
class AnimatedSprite < Sprite
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname

  def initializeLong(animname, framecount, framewidth, frameheight, frameskip)
    @animname = pbBitmapName(animname)
    @realframes = 0
    @frameskip = [1, frameskip].max
    @frameskip *= Graphics.frame_rate / 20
    raise _INTL("Frame width is 0") if framewidth == 0
    raise _INTL("Frame height is 0") if frameheight == 0
    begin
      @animbitmap = AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap = Bitmap.new(framewidth, frameheight)
    end
    if @animbitmap.width % framewidth != 0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
                  @animbitmap.width, framewidth, animname)
    end
    if @animbitmap.height % frameheight != 0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
                  @animbitmap.height, frameheight, animname)
    end
    @framecount = framecount
    @framewidth = framewidth
    @frameheight = frameheight
    @framesperrow = @animbitmap.width / @framewidth
    @playing = false
    self.bitmap = @animbitmap
    self.src_rect.width = @framewidth
    self.src_rect.height = @frameheight
    self.frame = 0
  end

  # Shorter version of AnimationSprite.  All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand
  def initializeShort(animname, framecount, frameskip)
    @animname = pbBitmapName(animname)
    @realframes = 0
    @frameskip = [1, frameskip].max
    @frameskip *= Graphics.frame_rate / 20
    begin
      @animbitmap = AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap = Bitmap.new(framecount * 4, 32)
    end
    if @animbitmap.width % framecount != 0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
                  @animbitmap.width, framewidth, animname)
    end
    @framecount = framecount
    @framewidth = @animbitmap.width / @framecount
    @frameheight = @animbitmap.height
    @framesperrow = framecount
    @playing = false
    self.bitmap = @animbitmap
    self.src_rect.width = @framewidth
    self.src_rect.height = @frameheight
    self.frame = 0
  end

  def initialize(*args)
    if args.length == 1
      super(args[0][3])
      initializeShort(args[0][0], args[0][1], args[0][2])
    else
      super(args[5])
      initializeLong(args[0], args[1], args[2], args[3], args[4])
    end
  end

  def self.create(animname, framecount, frameskip, viewport = nil)
    return self.new([animname, framecount, frameskip, viewport])
  end

  def dispose
    return if disposed?
    @animbitmap.dispose
    @animbitmap = nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
    @frame = value
    @realframes = 0
    self.src_rect.x = @frame % @framesperrow * @framewidth
    self.src_rect.y = @frame / @framesperrow * @frameheight
  end

  def start
    @playing = true
    @realframes = 0
  end

  alias play start

  def stop
    @playing = false
  end

  def update
    super
    if @playing
      @realframes += 1
      if @realframes == @frameskip
        @realframes = 0
        self.frame += 1
        self.frame %= self.framecount
      end
    end
  end
end



#===============================================================================
# Displays an icon bitmap in a sprite. Supports animated images.
#===============================================================================
class IconSprite < Sprite
  attr_reader :name

  def initialize(*args)
    case args.length
    when 0
      super(nil)
      self.bitmap = nil
    when 1
      super(args[0])
      self.bitmap = nil
    when 2
      super(nil)
      self.x = args[0]
      self.y = args[1]
    else
      super(args[2])
      self.x = args[0]
      self.y = args[1]
    end
    @name = ""
    @_iconbitmap = nil
  end

  def dispose
    clearBitmaps
    super
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file, hue = 0)
    oldrc = self.src_rect
    clearBitmaps
    @name = file
    return if file.nil?
    if file == ""
      @_iconbitmap = nil
    else
      @_iconbitmap = AnimatedBitmap.new(file, hue)
      # for compatibility
      self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect = oldrc
    end
  end

  def clearBitmaps
    @_iconbitmap&.dispose
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
  end

  def update
    super
    return if !@_iconbitmap
    @_iconbitmap.update
    if self.bitmap != @_iconbitmap.bitmap
      oldrc = self.src_rect
      self.bitmap = @_iconbitmap.bitmap
      self.src_rect = oldrc
    end
  end
end



#===============================================================================
# Sprite class that stores multiple bitmaps, and displays only one at once.
#===============================================================================
class ChangelingSprite < Sprite
  def initialize(x = 0, y = 0, viewport = nil)
    super(viewport)
    self.x = x
    self.y = y
    @bitmaps = {}
    @currentBitmap = nil
  end

  def addBitmap(key, path)
    @bitmaps[key]&.dispose
    @bitmaps[key] = AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap = @bitmaps[key]
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    @bitmaps.each_value { |bm| bm.dispose }
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    @bitmaps.each_value { |bm| bm.update }
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end
end
