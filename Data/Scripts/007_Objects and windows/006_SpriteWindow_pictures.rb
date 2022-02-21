#===============================================================================
# Displays an icon bitmap in a window. Supports animated images.
#===============================================================================
class IconWindow < SpriteWindow_Base
  attr_reader :name

  def initialize(x, y, width, height, viewport = nil)
    super(x, y, width, height)
    self.viewport = viewport
    self.contents = nil
    @name = ""
    @_iconbitmap = nil
  end

  def dispose
    clearBitmaps
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.contents = @_iconbitmap.bitmap
    end
  end

  def clearBitmaps
    @_iconbitmap&.dispose
    @_iconbitmap = nil
    self.contents = nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file, hue = 0)
    clearBitmaps
    @name = file
    return if file.nil?
    if file == ""
      @_iconbitmap = nil
    else
      @_iconbitmap = AnimatedBitmap.new(file, hue)
      # for compatibility
      self.contents = @_iconbitmap ? @_iconbitmap.bitmap : nil
    end
  end
end



#===============================================================================
# Displays an icon bitmap in a window. Supports animated images.
# Accepts bitmaps and paths to bitmap files in its constructor.
#===============================================================================
class PictureWindow < SpriteWindow_Base
  def initialize(pathOrBitmap)
    super(0, 0, 32, 32)
    self.viewport = viewport
    self.contents = nil
    @_iconbitmap = nil
    setBitmap(pathOrBitmap)
  end

  def dispose
    clearBitmaps
    super
  end

  def update
    super
    if @_iconbitmap
      if @_iconbitmap.is_a?(Bitmap)
        self.contents = @_iconbitmap
      else
        @_iconbitmap.update
        self.contents = @_iconbitmap.bitmap
      end
    end
  end

  def clearBitmaps
    @_iconbitmap&.dispose
    @_iconbitmap = nil
    self.contents = nil if !self.disposed?
  end

  # Sets the icon's bitmap or filename. (hue parameter
  # is ignored unless pathOrBitmap is a filename)
  def setBitmap(pathOrBitmap, hue = 0)
    clearBitmaps
    if pathOrBitmap && pathOrBitmap != ""
      case pathOrBitmap
      when Bitmap
        @_iconbitmap = pathOrBitmap
        self.contents = @_iconbitmap
        self.width = @_iconbitmap.width + self.borderX
        self.height = @_iconbitmap.height + self.borderY
      when AnimatedBitmap
        @_iconbitmap = pathOrBitmap
        self.contents = @_iconbitmap.bitmap
        self.width = @_iconbitmap.bitmap.width + self.borderX
        self.height = @_iconbitmap.bitmap.height + self.borderY
      else
        @_iconbitmap = AnimatedBitmap.new(pathOrBitmap, hue)
        self.contents = @_iconbitmap&.bitmap
        self.width = self.borderX + (@_iconbitmap&.bitmap&.width || 32)
        self.height = self.borderY + (@_iconbitmap&.bitmap&.height || 32)
      end
    else
      @_iconbitmap = nil
      self.width = 32 + self.borderX
      self.height = 32 + self.borderY
    end
  end
end
