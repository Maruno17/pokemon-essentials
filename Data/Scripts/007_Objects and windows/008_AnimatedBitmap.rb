# Disabling animated GIF stuff because gif.dll is awful,
# but leaving the code here just in case someone wants
# to make Linux and macOS versions of it for some reason
=begin
module GifLibrary
  @@loadlib = Win32API.new("Kernel32.dll", "LoadLibrary", 'p', '')
  if safeExists?("gif.dll")
    PngDll                = @@loadlib.call("gif.dll")
    GifToPngFiles         = Win32API.new("gif.dll", "GifToPngFiles", 'pp', 'l')
    GifToPngFilesInMemory = Win32API.new("gif.dll", "GifToPngFilesInMemory", 'plp', 'l')
    CopyDataString        = Win32API.new("gif.dll", "CopyDataString", 'lpl', 'l')
    FreeDataString        = Win32API.new("gif.dll", "FreeDataString", 'l', '')
  else
    PngDll = nil
  end

  def self.getDataFromResult(result)
    datasize = CopyDataString.call(result, "", 0)
    ret = nil
    if datasize != 0
      data = "0" * datasize
      CopyDataString.call(result, data, datasize)
      ret = data.unpack("V*")
    end
    FreeDataString.call(result)
    return ret
  end
end
=end



class AnimatedBitmap
  def initialize(file, hue = 0)
    raise "Filename is nil (missing graphic)." if file.nil?
    path     = file
    filename = ""
    if file.last != '/'   # Isn't just a directory
      split_file = file.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join('/') + '/'
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
  def frameDelay;   @bitmap.frameDelay;                 end
  def totalFrames;  @bitmap.totalFrames;                end
  def disposed?;    @bitmap.disposed?;                  end
  def update;       @bitmap.update;                     end
  def dispose;      @bitmap.dispose;                    end
  def deanimate;    @bitmap.deanimate;                  end
  def copy;         @bitmap.copy;                       end
end



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
      for i in 0...numFrames
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
    for i in 1...@frames.length
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
    for i in 0...x.frames.length
      x.frames[i] = x.frames[i].copy
    end
    return x
  end
end



#internal class
class GifBitmap
  attr_accessor :gifbitmaps   # internal
  attr_accessor :gifdelays    # internal

  # Creates a bitmap from a GIF file with the specified
  # optional viewport. Can also load non-animated bitmaps.
  def initialize(dir, filename, hue = 0)
    @gifbitmaps   = []
    @gifdelays    = []
    @totalframes  = 0
    @framecount   = 0
    @currentIndex = 0
    @disposed     = false
    bitmap        = nil
    filestring    = nil
    filestrName   = nil
    filename      = "" if !filename
    full_path     = canonicalize(dir + filename)
    begin
      bitmap = RPG::Cache.load_bitmap(dir, filename, hue)
    rescue
      bitmap = nil
    end
    if !bitmap || (bitmap.width == 32 && bitmap.height == 32)
      if !full_path || full_path.length < 1 || full_path[full_path.length - 1] != 0x2F
        if (filestring = pbGetFileChar(full_path))
          filestrName = full_path
        elsif (filestring = pbGetFileChar(full_path + ".gif"))
          filestrName = full_path + ".gif"
        elsif (filestring = pbGetFileChar(full_path + ".png"))
          filestrName = full_path + ".png"
#        elsif (filestring = pbGetFileChar(full_path + ".jpg"))
#          filestrName = full_path + ".jpg"
#        elsif (filestring = pbGetFileChar(full_path + ".bmp"))
#          filestrName = full_path + ".bmp"
        end
      end
    end
    if bitmap && filestring && filestring[0].ord == 0x47 &&
       bitmap.width == 32 && bitmap.height == 32
#      File.open("debug.txt","ab") { |f| f.puts("rejecting bitmap") }
      bitmap.dispose
      bitmap = nil
    end
    # Note: MKXP can open .gif files just fine, first frame only
    if bitmap
#      File.open("debug.txt","ab") { |f| f.puts("reusing bitmap") }
      # Have a regular non-animated bitmap
      @totalframes = 1
      @framecount  = 0
      @gifbitmaps  = [bitmap]
      @gifdelays   = [1]
    else
      tmpBase = File.basename(full_path) + "_tmp_"
      filestring = pbGetFileString(filestrName) if filestring
=begin
      Dir.chdir(ENV["TEMP"]) {   # navigate to temp folder since game might be on a CD-ROM
        if filestring && filestring[0] == 0x47 && GifLibrary::PngDll
          result = GifLibrary::GifToPngFilesInMemory.call(filestring,
             filestring.length, tmpBase)
        else
          result = 0
        end
        if result  >0
          @gifdelays = GifLibrary.getDataFromResult(result)
          @totalframes = @gifdelays.pop
          for i in 0...@gifdelays.length
            @gifdelays[i] = [@gifdelays[i], 1].max
            bmfile = sprintf("%s%d.png", tmpBase, i)
            if safeExists?(bmfile)
              gifbitmap = BitmapWrapper.new(bmfile)
              @gifbitmaps.push(gifbitmap)
              bmfile.hue_change(hue) if hue != 0
              if hue == 0 && @gifdelays.length == 1
                RPG::Cache.setKey(full_path, gifbitmap)
              end
              File.delete(bmfile)
            else
              @gifbitmaps.push(BitmapWrapper.new(32, 32))
            end
          end
        end
      }
=end
      if @gifbitmaps.length == 0
        @gifbitmaps = [BitmapWrapper.new(32, 32)]
        @gifdelays  = [1]
      end
      if @gifbitmaps.length == 1
        RPG::Cache.setKey(full_path, @gifbitmaps[0])
      end
    end
  end

  def [](index)
    return @gifbitmaps[index]
  end

  def deanimate
    for i in 1...@gifbitmaps.length
      @gifbitmaps[i].dispose
    end
    @gifbitmaps = [@gifbitmaps[0]]
    @currentIndex = 0
    return @gifbitmaps[0]
  end

  def bitmap
    return @gifbitmaps[@currentIndex]
  end

  def currentIndex
    return @currentIndex
  end

  def frameDelay(index)
    return @gifdelay[index] / 2   # Due to frame count being incremented by 2
  end

  def length
    return @gifbitmaps.length
  end

  def each
    @gifbitmaps.each { |item| yield item }
  end

  def totalFrames
    return @totalframes / 2   # Due to frame count being incremented by 2
  end

  def disposed?
    return @disposed
  end

  def width
    return (@gifbitmaps.length == 0) ? 0 : @gifbitmaps[0].width
  end

  def height
    return (@gifbitmaps.length == 0) ? 0 : @gifbitmaps[0].height
  end

  # This function must be called in order to animate the GIF image.
  def update
    return if disposed?
    if @gifbitmaps.length > 0
      @framecount += 2
      @framecount = (@totalframes <= 0) ? 0 : @framecount % @totalframes
      frametoshow = 0
      for i in 0...@gifdelays.length
        frametoshow = i if @gifdelays[i] <= @framecount
      end
      @currentIndex = frametoshow
    end
  end

  def dispose
    if !@disposed
      @gifbitmaps.each { |b| b.dispose }
    end
    @disposed = true
  end

  def copy
    x = self.clone
    x.gifbitmaps = x.gifbitmaps.clone
    x.gifdelays = x.gifdelays.clone
    for i in 0...x.gifbitmaps.length
      x.gifbitmaps[i] = x.gifbitmaps[i].copy
    end
    return x
  end
end



def pbGetTileBitmap(filename, tile_id, hue, width = 1, height = 1)
  return RPG::Cache.tileEx(filename, tile_id, hue, width, height) { |f|
    AnimatedBitmap.new("Graphics/Tilesets/" + filename).deanimate
  }
end

def pbGetTileset(name,hue=0)
  return AnimatedBitmap.new("Graphics/Tilesets/" + name, hue).deanimate
end

def pbGetAutotile(name,hue=0)
  return AnimatedBitmap.new("Graphics/Autotiles/" + name, hue).deanimate
end

def pbGetAnimation(name,hue=0)
  return AnimatedBitmap.new("Graphics/Animations/" + name, hue).deanimate
end
