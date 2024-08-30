#===============================================================================
# Sprite class that maintains a bitmap of its own.
# This bitmap can't be changed to a different one.
#===============================================================================
class BitmapSprite < Sprite
  attr_reader :text_themes

  def initialize(width, height, viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(width, height)
    @text_themes = {}
    @initialized = true
  end

  def dispose
    self.bitmap.dispose if !self.disposed?
    super
  end

  def bitmap=(value)
    super(value) if !@initialized
  end

  #-----------------------------------------------------------------------------

  def add_text_theme(id, base_color, shadow_color = nil)
    @text_themes[id] = [base_color, shadow_color]
  end

  # TODO: Replaces def pbDrawTextPositions.
  def draw_themed_text(string, text_x, text_y, align = :left, theme = :default, outline = :shadow)
    string_size = self.bitmap.text_size(string)
    case align
    when :right
      text_x -= string_size.width
    when :center
      text_x -= (string_size.width / 2)
    end
    if !@text_themes[theme]
      theme = (@text_themes[:default]) ? :default : @text_themes.keys.first
    end
    case outline || :shadow
    when :shadow
      draw_shadowed_text(string, text_x, text_y, theme)
    when :outline
      draw_outlined_text(string, text_x, text_y, theme)
    when :none
      draw_plain_text(string, text_x, text_y, theme)
    end
  end

  # TODO: Replaces def pbDrawShadowText.
  def draw_shadowed_text(string, text_x, text_y, theme)
    return if !@text_themes[theme]
    base_color, shadow_color = @text_themes[theme]
    string_size = self.bitmap.text_size(string)
    string_width = string_size.width + 1
    string_height = string_size.height + 1
    if shadow_color && shadow_color.alpha > 0
      self.bitmap.font.color = shadow_color
      self.bitmap.draw_text(text_x + 2, text_y, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x, text_y + 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x + 2, text_y + 2, string_width, string_height, string, 0)
    end
    if base_color && base_color.alpha > 0
      self.bitmap.font.color = base_color
      self.bitmap.draw_text(text_x, text_y, string_width, string_height, string, 0)
    end
  end

  # TODO: Replaces def pbDrawOutlineText.
  def draw_outlined_text(string, text_x, text_y, theme)
    return if !@text_themes[theme]
    base_color, shadow_color = @text_themes[theme]
    string_size = self.bitmap.text_size(string)
    string_width = string_size.width + 1
    string_height = string_size.height + 1
    if shadow_color && shadow_color.alpha > 0
      self.bitmap.font.color = shadow_color
      self.bitmap.draw_text(text_x - 2, text_y - 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x, text_y - 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x + 2, text_y - 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x - 2, text_y, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x + 2, text_y, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x - 2, text_y + 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x, text_y + 2, string_width, string_height, string, 0)
      self.bitmap.draw_text(text_x + 2, text_y + 2, string_width, string_height, string, 0)
    end
    if base_color && base_color.alpha > 0
      self.bitmap.font.color = base_color
      self.bitmap.draw_text(text_x, text_y, string_width, string_height, string, 0)
    end
  end

  # TODO: Replaces def pbDrawPlainText.
  def draw_plain_text(string, text_x, text_y, theme)
    return if !@text_themes[theme]
    base_color = @text_themes[theme][0]
    return if !base_color || base_color.alpha == 0
    string_size = self.bitmap.text_size(string)
    string_width = string_size.width + 1
    string_height = string_size.height + 1
    self.bitmap.font.color = base_color
    self.bitmap.draw_text(text_x, text_y, string_width, string_height, string, 0)
  end

  #-----------------------------------------------------------------------------

  # TODO: Replaces def pbDrawImagePositions.
  def draw_image(filename, image_x, image_y, src_x = 0, src_y = 0, src_width = -1, src_height = -1)
    src_bitmap = (filename.is_a?(AnimatedBitmap)) ? filename : AnimatedBitmap.new(pbBitmapName(filename))
    src_width = (src_width >= 0) ? src_width : src_bitmap.width
    src_height = (src_height >= 0) ? src_height : src_bitmap.height
    src_rect = Rect.new(src_x, src_y, src_width, src_height)
    self.bitmap.blt(image_x, image_y, src_bitmap.bitmap, src_rect)
    src_bitmap.dispose if !filename.is_a?(AnimatedBitmap)
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

  # frameskip is in 1/20ths of a second, and is the time between frame changes.
  def initializeLong(animname, framecount, framewidth, frameheight, frameskip)
    @animname = pbBitmapName(animname)
    @time_per_frame = [1, frameskip].max / 20.0
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

  # Shorter version of AnimatedSprite. All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand.
  # frameskip is in 1/20ths of a second, and is the time between frame changes.
  def initializeShort(animname, framecount, frameskip)
    @animname = pbBitmapName(animname)
    @time_per_frame = [1, frameskip].max / 20.0
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
    self.src_rect.x = @frame % @framesperrow * @framewidth
    self.src_rect.y = @frame / @framesperrow * @frameheight
  end

  def start
    @playing = true
  end

  alias play start

  def stop
    @playing = false
  end

  def update
    super
    if @playing
      new_frame = (System.uptime / @time_per_frame).to_i % self.framecount
      self.frame = new_frame if self.frame != new_frame
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
  # Key is the mode (a symbol).
  # Value is one of:
  #   filepath
  #   [filepath, src_x, src_y, src_width, src_height]
  BITMAPS = {}

  def initialize(x = 0, y = 0, viewport = nil)
    super(viewport)
    self.x = x
    self.y = y
    @bitmaps = {}
    @changeling_data = {}
    @current_bitmap = nil
    initialize_changeling_data
  end

  def initialize_changeling_data
    self.class::BITMAPS.each_pair { |mode, data| add_bitmap(mode, data) }
  end

  def dispose
    return if disposed?
    @bitmaps.each_value { |bm| bm.dispose }
    @bitmaps.clear
    super
  end

  #-----------------------------------------------------------------------------

  def add_bitmap(mode, *data)
    raise ArgumentError.new(_INTL("wrong number of arguments (given {1}, expected 2 or 6)", data.length + 1)) if ![1, 5].include?(data.length)
    filepath = (data[0].is_a?(Array)) ? data[0][0] : data[0]
    @bitmaps[filepath] = AnimatedBitmap.new(filepath) if !@bitmaps[filepath]
    @changeling_data[mode] = (data[0].is_a?(Array) ? data[0].clone : [data[0]])
  end

  def change_bitmap(mode)
    @current_mode = mode
    if @current_mode && @changeling_data[@current_mode]
      data = @changeling_data[@current_mode]
      @current_bitmap = @bitmaps[data[0]]
      self.bitmap = @current_bitmap.bitmap
      if data.length > 1
        self.src_rect.set(data[1], data[2], data[3], data[4])
      else
        self.src_rect.set(0, 0, self.bitmap.width, self.bitmap.height)
      end
    else
      @current_bitmap = nil
      self.bitmap = nil
    end
  end

  #-----------------------------------------------------------------------------

  def update
    return if disposed?
    @bitmaps.each_value { |bm| bm.update }
    self.bitmap = @current_bitmap.bitmap if @current_bitmap
  end
end
