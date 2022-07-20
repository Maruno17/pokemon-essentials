#===============================================================================
#
#===============================================================================
class AnimatedBitmap
  def initialize(file, hue = 0)
    raise "Filename is nil (missing graphic)." if file.nil?
    path     = file
    filename = ""
    if file.last != "/"   # Isn't just a directory
      split_file = file.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join("/") + "/"
    end
    if filename[/^\[\d+(?:,\d+)?\]/]   # Starts with 1 or 2 numbers in square brackets
      @bitmap = PngAnimatedBitmap.new(path, filename, hue)
    else
      @bitmap = GifBitmap.new(path, filename, hue)
    end
  end

  def [](index);    @bitmap[index];                     end
  def width;        @bitmap.bitmap.width;               end
  def height;       @bitmap.bitmap.height;              end
  def length;       @bitmap.length;                     end
  def each;         @bitmap.each { |item| yield item }; end
  def bitmap;       @bitmap.bitmap;                     end
  def currentIndex; @bitmap.currentIndex;               end
  def totalFrames;  @bitmap.totalFrames;                end
  def disposed?;    @bitmap.disposed?;                  end
  def update;       @bitmap.update;                     end
  def dispose;      @bitmap.dispose;                    end
  def deanimate;    @bitmap.deanimate;                  end
  def copy;         @bitmap.copy;                       end
end

#===============================================================================
#
#===============================================================================
class PngAnimatedBitmap
  attr_accessor :frames

  # Creates an animated bitmap from a PNG file.
  def initialize(dir, filename, hue = 0)
    @frames       = []
    @currentFrame = 0
    @framecount   = 0
    panorama = RPG::Cache.load_bitmap(dir, filename, hue)
    if filename[/^\[(\d+)(?:,(\d+))?\]/]   # Starts with 1 or 2 numbers in brackets
      # File has a frame count
      numFrames = $1.to_i
      delay     = $2.to_i
      delay     = 10 if delay == 0
      raise "Invalid frame count in #{filename}" if numFrames <= 0
      raise "Invalid frame delay in #{filename}" if delay <= 0
      if panorama.width % numFrames != 0
        raise "Bitmap's width (#{panorama.width}) is not divisible by frame count: #{filename}"
      end
      @frameDelay = delay
      subWidth = panorama.width / numFrames
      numFrames.times do |i|
        subBitmap = BitmapWrapper.new(subWidth, panorama.height)
        subBitmap.blt(0, 0, panorama, Rect.new(subWidth * i, 0, subWidth, panorama.height))
        @frames.push(subBitmap)
      end
      panorama.dispose
    else
      @frames = [panorama]
    end
  end

  def [](index)
    return @frames[index]
  end

  def width;  self.bitmap.width;  end
  def height; self.bitmap.height; end

  def deanimate
    (1...@frames.length).each do |i|
      @frames[i].dispose
    end
    @frames = [@frames[0]]
    @currentFrame = 0
    return @frames[0]
  end

  def bitmap
    return @frames[@currentFrame]
  end

  def currentIndex
    return @currentFrame
  end

  def frameDelay(_index)
    return @frameDelay
  end

  def length
    return @frames.length
  end

  def each
    @frames.each { |item| yield item }
  end

  def totalFrames
    return @frameDelay * @frames.length
  end

  def disposed?
    return @disposed
  end

  def update
    return if disposed?
    if @frames.length > 1
      @framecount += 1
      if @framecount >= @frameDelay
        @framecount = 0
        @currentFrame += 1
        @currentFrame %= @frames.length
      end
    end
  end

  def dispose
    if !@disposed
      @frames.each { |f| f.dispose }
    end
    @disposed = true
  end

  def copy
    x = self.clone
    x.frames = x.frames.clone
    x.frames.each_with_index { |frame, i| x.frames[i] = frame.copy }
    return x
  end
end

#===============================================================================
#
#===============================================================================
class GifBitmap
  attr_accessor :bitmap

  # Creates a bitmap from a GIF file. Can also load non-animated bitmaps.
  def initialize(dir, filename, hue = 0)
    @bitmap   = nil
    @disposed = false
    filename  = "" if !filename
    begin
      @bitmap = RPG::Cache.load_bitmap(dir, filename, hue)
    rescue
      @bitmap = nil
    end
    @bitmap = BitmapWrapper.new(32, 32) if @bitmap.nil?
    @bitmap.play if @bitmap&.animated?
  end

  def [](_index)
    return @bitmap
  end

  def deanimate
    @bitmap&.goto_and_stop(0) if @bitmap&.animated?
    return @bitmap
  end

  def currentIndex
    return @bitmap&.current_frame || 0
  end

  def length
    return @bitmap&.frame_count || 1
  end

  def each
    yield @bitmap
  end

  def totalFrames
    f_rate = @bitmap.frame_rate
    f_rate = 1 if f_rate.nil? || f_rate == 0
    return (@bitmap) ? (@bitmap.frame_count / f_rate).floor : 1
  end

  def disposed?
    return @disposed
  end

  def width
    return @bitmap&.width || 0
  end

  def height
    return @bitmap&.height || 0
  end

  # Gifs are animated automatically by mkxp-z. This function does nothing.
  def update; end

  def dispose
    return if @disposed
    @bitmap.dispose
    @disposed = true
  end

  def copy
    x = self.clone
    x.bitmap = @bitmap.copy if @bitmap
    return x
  end
end

#===============================================================================
#
#===============================================================================
def pbGetTileBitmap(filename, tile_id, hue, width = 1, height = 1)
  return RPG::Cache.tileEx(filename, tile_id, hue, width, height) { |f|
    AnimatedBitmap.new("Graphics/Tilesets/" + filename).deanimate
  }
end

def pbGetTileset(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Tilesets/" + name, hue).deanimate
end

def pbGetAutotile(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Autotiles/" + name, hue).deanimate
end

def pbGetAnimation(name, hue = 0)
  return AnimatedBitmap.new("Graphics/Animations/" + name, hue).deanimate
end
