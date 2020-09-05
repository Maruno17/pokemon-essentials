module GifLibrary
  @@loadlib = Win32API.new("Kernel32.dll","LoadLibrary",'p','')
  if safeExists?("gif.dll")
    PngDll                = @@loadlib.call("gif.dll")
    GifToPngFiles         = Win32API.new("gif.dll","GifToPngFiles",'pp','l')
    GifToPngFilesInMemory = Win32API.new("gif.dll","GifToPngFilesInMemory",'plp','l')
    CopyDataString        = Win32API.new("gif.dll","CopyDataString",'lpl','l')
    FreeDataString        = Win32API.new("gif.dll","FreeDataString",'l','')
  else
    PngDll=nil
  end

  def self.getDataFromResult(result)
    datasize=CopyDataString.call(result,"",0)
    ret=nil
    if datasize!=0
      data="0"*datasize
      CopyDataString.call(result,data,datasize)
      ret=data.unpack("V*")
    end
    FreeDataString.call(result)
    return ret
  end
end



class AnimatedBitmap
  def initialize(file,hue=0)
    if file==nil
      raise "Filename is nil (missing graphic)\r\n\r\n"+
            "If you see this error in the Continue/New Game screen, you may be loading another game's save file. "+
            "Check your project's title (\"Game > Change Title...\" in RMXP).\r\n"
    end
    if file.split(/[\\\/]/)[-1][/^\[\d+(?:,\d+)?]/]   # Starts with 1 or more digits in square brackets
      @bitmap = PngAnimatedBitmap.new(file,hue)
    else
      @bitmap = GifBitmap.new(file,hue)
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
  # Creates an animated bitmap from a PNG file.
  def initialize(file,hue=0)
    @frames=[]
    @currentFrame=0
    @framecount=0
    panorama=BitmapCache.load_bitmap(file,hue)
    if file.split(/[\\\/]/)[-1][/^\[(\d+)(?:,(\d+))?]/]   # Starts with 1 or more digits in brackets
      # File has a frame count
      numFrames = $1.to_i
      delay = $2.to_i || 10
      raise "Invalid frame count in #{file}" if numFrames<=0
      raise "Invalid frame delay in #{file}" if delay<=0
      if panorama.width % numFrames != 0
        raise "Bitmap's width (#{panorama.width}) is not divisible by frame count: #{file}"
      end
      @frameDelay = delay
      subWidth=panorama.width/numFrames
      for i in 0...numFrames
        subBitmap=BitmapWrapper.new(subWidth,panorama.height)
        subBitmap.blt(0,0,panorama,Rect.new(subWidth*i,0,subWidth,panorama.height))
        @frames.push(subBitmap)
      end
      panorama.dispose
    else
      @frames=[panorama]
    end
  end

  def [](index)
    return @frames[index]
  end

  def width; self.bitmap.width; end

  def height; self.bitmap.height; end

  def deanimate
    for i in 1...@frames.length
      @frames[i].dispose
    end
    @frames=[@frames[0]]
    @currentFrame=0
    return @frames[0]
  end

  def bitmap
    @frames[@currentFrame]
  end

  def currentIndex
    @currentFrame
  end

  def frameDelay(index)
    return @frameDelay
  end

  def length
    @frames.length
  end

  def each
    @frames.each { |item| yield item}
  end

  def totalFrames
    @frameDelay*@frames.length
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?
    if @frames.length>1
      @framecount+=1
      if @framecount>=@frameDelay
        @framecount=0
        @currentFrame+=1
        @currentFrame%=@frames.length
      end
    end
  end

  def dispose
    if !@disposed
      for i in @frames
        i.dispose
      end
    end
    @disposed=true
  end

  attr_accessor :frames   # internal

  def copy
    x=self.clone
    x.frames=x.frames.clone
    for i in 0...x.frames.length
      x.frames[i]=x.frames[i].copy
    end
    return x
  end
end



#internal class
class GifBitmap
  # Creates a bitmap from a GIF file with the specified
  # optional viewport.  Can also load non-animated bitmaps.
  def initialize(file,hue=0)
    @gifbitmaps=[]
    @gifdelays=[]
    @totalframes=0
    @framecount=0
    @currentIndex=0
    @disposed=false
    bitmap=nil
    filestring=nil
    filestrName=nil
    file="" if !file
    file=canonicalize(file)
    begin
      bitmap=BitmapCache.load_bitmap(file,hue)
    rescue
      bitmap=nil
    end
    if !bitmap || (bitmap.width==32 && bitmap.height==32)
      if !file || file.length<1 || file[file.length-1]!=0x2F
        if (filestring=pbGetFileChar(file))
          filestrName=file
        elsif (filestring=pbGetFileChar(file+".gif"))
          filestrName=file+".gif"
        elsif (filestring=pbGetFileChar(file+".png"))
          filestrName=file+".png"
        elsif (filestring=pbGetFileChar(file+".jpg"))
          filestrName=file+".jpg"
        elsif (filestring=pbGetFileChar(file+".bmp"))
          filestrName=file+".bmp"
        end
      end
    end
    if bitmap && filestring && filestring[0]==0x47 &&
       bitmap.width==32 && bitmap.height==32
      #File.open("debug.txt","ab") { |f| f.puts("rejecting bitmap") }
      bitmap.dispose
      bitmap=nil
    end
    if bitmap
      #File.open("debug.txt","ab") { |f| f.puts("reusing bitmap") }
      # Have a regular non-animated bitmap
      @totalframes=1
      @framecount=0
      @gifbitmaps=[bitmap]
      @gifdelays=[1]
    else
      tmpBase=File.basename(file)+"_tmp_"
      filestring=pbGetFileString(filestrName) if filestring
      Dir.chdir(ENV["TEMP"]) { # navigate to temp folder since game might be on a CD-ROM
        if filestring && filestring[0]==0x47 && GifLibrary::PngDll
          result=GifLibrary::GifToPngFilesInMemory.call(filestring,
             filestring.length,tmpBase)
        else
          result=0
        end
        if result>0
          @gifdelays=GifLibrary.getDataFromResult(result)
          @totalframes=@gifdelays.pop
          for i in 0...@gifdelays.length
            @gifdelays[i]=[@gifdelays[i],1].max
            bmfile=sprintf("%s%d.png",tmpBase,i)
            if safeExists?(bmfile)
              gifbitmap=BitmapWrapper.new(bmfile)
              @gifbitmaps.push(gifbitmap)
              bmfile.hue_change(hue) if hue!=0
              if hue==0 && @gifdelays.length==1
                BitmapCache.setKey(file,gifbitmap)
              end
              File.delete(bmfile)
            else
              @gifbitmaps.push(BitmapWrapper.new(32,32))
            end
          end
        end
      }
      if @gifbitmaps.length==0
        @gifbitmaps=[BitmapWrapper.new(32,32)]
        @gifdelays=[1]
      end
      if @gifbitmaps.length==1
        BitmapCache.setKey(file,@gifbitmaps[0])
      end
    end
  end

  def [](index)
    return @gifbitmaps[index]
  end

  def width; self.bitmap.width; end

  def height; self.bitmap.height; end

  def deanimate
    for i in 1...@gifbitmaps.length
      @gifbitmaps[i].dispose
    end
    @gifbitmaps=[@gifbitmaps[0]]
    @currentIndex=0
    return @gifbitmaps[0]
  end

  def bitmap
    @gifbitmaps[@currentIndex]
  end

  def currentIndex
    @currentIndex
  end

  def frameDelay(index)
    return @gifdelay[index]/2 # Due to frame count being incremented by 2
  end

  def length
    @gifbitmaps.length
  end

  def each
    @gifbitmaps.each { |item| yield item }
  end

  def totalFrames
    @totalframes/2 # Due to frame count being incremented by 2
  end

  def disposed?
    @disposed
  end

  def width
    @gifbitmaps.length==0 ? 0 : @gifbitmaps[0].width
  end

  def height
    @gifbitmaps.length==0 ? 0 : @gifbitmaps[0].height
  end

 # This function must be called in order to animate the GIF image.
  def update
    return if disposed?
    if @gifbitmaps.length>0
      @framecount+=2
      @framecount=@totalframes<=0 ? 0 : @framecount%@totalframes
      frametoshow=0
      for i in 0...@gifdelays.length
        frametoshow=i if @gifdelays[i]<=@framecount
      end
      @currentIndex=frametoshow
    end
  end

  def dispose
    if !@disposed
      for i in @gifbitmaps
        i.dispose
      end
    end
    @disposed=true
  end

  attr_accessor :gifbitmaps # internal
  attr_accessor :gifdelays # internal

  def copy
    x=self.clone
    x.gifbitmaps=x.gifbitmaps.clone
    x.gifdelays=x.gifdelays.clone
    for i in 0...x.gifbitmaps.length
      x.gifbitmaps[i]=x.gifbitmaps[i].copy
    end
    return x
  end
end



def pbGetTileBitmap(filename, tile_id, hue)
  return BitmapCache.tileEx(filename, tile_id, hue) { |f|
    AnimatedBitmap.new("Graphics/Tilesets/"+filename).deanimate;
  }
end

def pbGetTileset(name,hue=0)
  return AnimatedBitmap.new("Graphics/Tilesets/"+name,hue).deanimate
end

def pbGetAutotile(name,hue=0)
  return AnimatedBitmap.new("Graphics/Autotiles/"+name,hue).deanimate
end

def pbGetAnimation(name,hue=0)
  return AnimatedBitmap.new("Graphics/Animations/"+name,hue).deanimate
end



#===============================================================================
# SpriteWrapper is a class based on Sprite which wraps Sprite's properties.
#===============================================================================
class SpriteWrapper < Sprite
  def initialize(viewport=nil)
    @sprite = Sprite.new(viewport)
  end

  def dispose;               @sprite.dispose;                      end
  def disposed?;             return @sprite.disposed?;             end
  def viewport;              return @sprite.viewport;              end
  def flash(color,duration); return @sprite.flash(color,duration); end
  def update;                return @sprite.update;                end
  def x;                     @sprite.x;                            end
  def x=(value);             @sprite.x = value;                    end
  def y;                     @sprite.y;                            end
  def y=(value);             @sprite.y = value;                    end
  def bitmap;                @sprite.bitmap;                       end
  def bitmap=(value);        @sprite.bitmap = value;               end
  def src_rect;              @sprite.src_rect;                     end
  def src_rect=(value);      @sprite.src_rect = value;             end
  def visible;               @sprite.visible;                      end
  def visible=(value);       @sprite.visible = value;              end
  def z;                     @sprite.z;                            end
  def z=(value);             @sprite.z = value;                    end
  def ox;                    @sprite.ox;                           end
  def ox=(value);            @sprite.ox = value;                   end
  def oy;                    @sprite.oy;                           end
  def oy=(value);            @sprite.oy = value;                   end
  def zoom_x;                @sprite.zoom_x;                       end
  def zoom_x=(value);        @sprite.zoom_x = value;               end
  def zoom_y;                @sprite.zoom_y;                       end
  def zoom_y=(value);        @sprite.zoom_y = value;               end
  def angle;                 @sprite.angle;                        end
  def angle=(value);         @sprite.angle = value;                end
  def mirror;                @sprite.mirror;                       end
  def mirror=(value);        @sprite.mirror = value;               end
  def bush_depth;            @sprite.bush_depth;                   end
  def bush_depth=(value);    @sprite.bush_depth = value;           end
  def opacity;               @sprite.opacity;                      end
  def opacity=(value);       @sprite.opacity = value;              end
  def blend_type;            @sprite.blend_type;                   end
  def blend_type=(value);    @sprite.blend_type = value;           end
  def color;                 @sprite.color;                        end
  def color=(value);         @sprite.color = value;                end
  def tone;                  @sprite.tone;                         end
  def tone=(value);          @sprite.tone = value;                 end

  def viewport=(value)
    return if self.viewport==value
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
class BitmapSprite < SpriteWrapper
  def initialize(width,height,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(width,height)
    @initialized=true
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
class AnimatedSprite < SpriteWrapper
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname

  def initializeLong(animname,framecount,framewidth,frameheight,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    @frameskip *= Graphics.frame_rate/20
    raise _INTL("Frame width is 0") if framewidth==0
    raise _INTL("Frame height is 0") if frameheight==0
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap=Bitmap.new(framewidth,frameheight)
    end
    if @animbitmap.width%framewidth!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    if @animbitmap.height%frameheight!=0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
         @animbitmap.height,frameheight,animname)
    end
    @framecount=framecount
    @framewidth=framewidth
    @frameheight=frameheight
    @framesperrow=@animbitmap.width/@framewidth
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  # Shorter version of AnimationSprite.  All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand
  def initializeShort(animname,framecount,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    @frameskip *= Graphics.frame_rate/20
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap=Bitmap.new(framecount*4,32)
    end
    if @animbitmap.width%framecount!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    @framecount=framecount
    @framewidth=@animbitmap.width/@framecount
    @frameheight=@animbitmap.height
    @framesperrow=framecount
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  def initialize(*args)
    if args.length==1
      super(args[0][3])
      initializeShort(args[0][0],args[0][1],args[0][2])
    else
      super(args[5])
      initializeLong(args[0],args[1],args[2],args[3],args[4])
    end
  end

  def self.create(animname,framecount,frameskip,viewport=nil)
    return self.new([animname,framecount,frameskip,viewport])
  end

  def dispose
    return if disposed?
    @animbitmap.dispose
    @animbitmap=nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
    @frame=value
    @realframes=0
    self.src_rect.x=@frame%@framesperrow*@framewidth
    self.src_rect.y=@frame/@framesperrow*@frameheight
  end

  def start
    @playing=true
    @realframes=0
  end

  alias play start

  def stop
    @playing=false
  end

  def update
    super
    if @playing
      @realframes+=1
      if @realframes==@frameskip
        @realframes=0
        self.frame+=1
        self.frame%=self.framecount
      end
    end
  end
end



#===============================================================================
# Displays an icon bitmap in a sprite. Supports animated images.
#===============================================================================
class IconSprite < SpriteWrapper
  attr_reader :name

  def initialize(*args)
    if args.length==0
      super(nil)
      self.bitmap=nil
    elsif args.length==1
      super(args[0])
      self.bitmap=nil
    elsif args.length==2
      super(nil)
      self.x=args[0]
      self.y=args[1]
    else
      super(args[2])
      self.x=args[0]
      self.y=args[1]
    end
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    oldrc=self.src_rect
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.bitmap=@_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect=oldrc
    else
      @_iconbitmap=nil
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.bitmap=nil if !self.disposed?
  end

  def update
    super
    return if !@_iconbitmap
    @_iconbitmap.update
    if self.bitmap!=@_iconbitmap.bitmap
      oldrc=self.src_rect
      self.bitmap=@_iconbitmap.bitmap
      self.src_rect=oldrc
    end
  end
end



#===============================================================================
# Old GifSprite class, retained for compatibility
#===============================================================================
class GifSprite < IconSprite
  def initialize(path)
    super(0,0)
    setBitmap(path)
  end
end



#===============================================================================
# SpriteWrapper that stores multiple bitmaps, and displays only one at once.
#===============================================================================
class ChangelingSprite < SpriteWrapper
  def initialize(x=0,y=0,viewport=nil)
    super(viewport)
    self.x = x
    self.y = y
    @bitmaps = {}
    @currentBitmap = nil
  end

  def addBitmap(key,path)
    @bitmaps[key].dispose if @bitmaps[key]
    @bitmaps[key] = AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap = @bitmaps[key]
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    for bm in @bitmaps.values; bm.dispose; end
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    for bm in @bitmaps.values; bm.update; end
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end
end



#===============================================================================
# Displays an icon bitmap in a window. Supports animated images.
#===============================================================================
class IconWindow < SpriteWindow_Base
  attr_reader :name

  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport
    self.contents=nil
    @name=""
    @_iconbitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.contents=@_iconbitmap.bitmap
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  # Sets the icon's filename.
  def setBitmap(file,hue=0)
    clearBitmaps()
    @name=file
    return if file==nil
    if file!=""
      @_iconbitmap=AnimatedBitmap.new(file,hue)
      # for compatibility
      self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
    else
      @_iconbitmap=nil
    end
  end
end



#===============================================================================
# Displays an icon bitmap in a window. Supports animated images.
# Accepts bitmaps and paths to bitmap files in its constructor.
#===============================================================================
class PictureWindow < SpriteWindow_Base
  def initialize(pathOrBitmap)
    super(0,0,32,32)
    self.viewport=viewport
    self.contents=nil
    @_iconbitmap=nil
    setBitmap(pathOrBitmap)
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @_iconbitmap
      if @_iconbitmap.is_a?(Bitmap)
        self.contents=@_iconbitmap
      else
        @_iconbitmap.update
        self.contents=@_iconbitmap.bitmap
      end
    end
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap=nil
    self.contents=nil if !self.disposed?
  end

  # Sets the icon's bitmap or filename. (hue parameter
  # is ignored unless pathOrBitmap is a filename)
  def setBitmap(pathOrBitmap,hue=0)
    clearBitmaps()
    if pathOrBitmap!=nil && pathOrBitmap!=""
      if pathOrBitmap.is_a?(Bitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap
        self.width=@_iconbitmap.width+self.borderX
        self.height=@_iconbitmap.height+self.borderY
      elsif pathOrBitmap.is_a?(AnimatedBitmap)
        @_iconbitmap=pathOrBitmap
        self.contents=@_iconbitmap.bitmap
        self.width=@_iconbitmap.bitmap.width+self.borderX
        self.height=@_iconbitmap.bitmap.height+self.borderY
      else
        @_iconbitmap=AnimatedBitmap.new(pathOrBitmap,hue)
        self.contents=@_iconbitmap ? @_iconbitmap.bitmap : nil
        self.width=@_iconbitmap ? @_iconbitmap.bitmap.width+self.borderX :
           32+self.borderX
        self.height=@_iconbitmap ? @_iconbitmap.bitmap.height+self.borderY :
           32+self.borderY
      end
    else
      @_iconbitmap=nil
      self.width=32+self.borderX
      self.height=32+self.borderY
    end
  end
end



#===============================================================================
#
#===============================================================================
class Plane
  def update; end
  def refresh; end
end



#===============================================================================
# This class works around a limitation that planes are always
# 640 by 480 pixels in size regardless of the window's size.
#===============================================================================
class LargePlane < Plane
  attr_accessor :borderX
  attr_accessor :borderY

  def initialize(viewport=nil)
    @__sprite=Sprite.new(viewport)
    @__disposed=false
    @__ox=0
    @__oy=0
    @__bitmap=nil
    @__visible=true
    @__sprite.visible=false
    @borderX=0
    @borderY=0
  end

  def disposed?
    return @__disposed
  end

  def dispose
    if !@__disposed
      @__sprite.bitmap.dispose if @__sprite.bitmap
      @__sprite.dispose
      @__sprite=nil
      @__bitmap=nil
      @__disposed=true
    end
    super
  end

  def ox; @__ox; end
  def oy; @__oy; end

  def ox=(value);
    return if @__ox==value
    @__ox = value
    refresh
  end

  def oy=(value);
    return if @__oy==value
    @__oy = value
    refresh
  end

  def bitmap
    return @__bitmap
  end

  def bitmap=(value)
    if value==nil
      if @__bitmap!=nil
        @__bitmap=nil
        @__sprite.visible=(@__visible && !@__bitmap.nil?)
      end
    elsif @__bitmap!=value && !value.disposed?
      @__bitmap=value
      refresh
    elsif value.disposed?
      if @__bitmap!=nil
        @__bitmap=nil
        @__sprite.visible=(@__visible && !@__bitmap.nil?)
      end
    end
  end

  def viewport; @__sprite.viewport; end
  def zoom_x; @__sprite.zoom_x; end
  def zoom_y; @__sprite.zoom_y; end
  def opacity; @__sprite.opacity; end
  def blend_type; @__sprite.blend_type; end
  def visible; @__visible; end
  def z; @__sprite.z; end
  def color; @__sprite.color; end
  def tone; @__sprite.tone; end

  def zoom_x=(v);
    return if @__sprite.zoom_x==v
    @__sprite.zoom_x = v
    refresh
  end

  def zoom_y=(v);
    return if @__sprite.zoom_y==v
    @__sprite.zoom_y = v
    refresh
  end

  def opacity=(v); @__sprite.opacity=(v); end
  def blend_type=(v); @__sprite.blend_type=(v); end
  def visible=(v); @__visible=v; @__sprite.visible=(@__visible && !@__bitmap.nil?); end
  def z=(v); @__sprite.z=(v); end
  def color=(v); @__sprite.color=(v); end
  def tone=(v); @__sprite.tone=(v); end
  def update; ;end

  def refresh
    @__sprite.visible = (@__visible && !@__bitmap.nil?)
    if @__bitmap
      if !@__bitmap.disposed?
        @__ox += @__bitmap.width*@__sprite.zoom_x if @__ox<0
        @__oy += @__bitmap.height*@__sprite.zoom_y if @__oy<0
        @__ox -= @__bitmap.width*@__sprite.zoom_x if @__ox>@__bitmap.width
        @__oy -= @__bitmap.height*@__sprite.zoom_y if @__oy>@__bitmap.height
        dwidth  = (Graphics.width/@__sprite.zoom_x+@borderX).to_i # +2
        dheight = (Graphics.height/@__sprite.zoom_y+@borderY).to_i # +2
        @__sprite.bitmap = ensureBitmap(@__sprite.bitmap,dwidth,dheight)
        @__sprite.bitmap.clear
        tileBitmap(@__sprite.bitmap,@__bitmap,@__bitmap.rect)
      else
        @__sprite.visible = false
      end
    end
  end

  private

  def ensureBitmap(bitmap,dwidth,dheight)
    if !bitmap || bitmap.disposed? || bitmap.width<dwidth || bitmap.height<dheight
      bitmap.dispose if bitmap
      bitmap = Bitmap.new([1,dwidth].max,[1,dheight].max)
    end
    return bitmap
  end

  def tileBitmap(dstbitmap,srcbitmap,srcrect)
    return if !srcbitmap || srcbitmap.disposed?
    dstrect = dstbitmap.rect
    left = (dstrect.x-@__ox/@__sprite.zoom_x).to_i
    top  = (dstrect.y-@__oy/@__sprite.zoom_y).to_i
    while left>0; left -= srcbitmap.width; end
    while top>0; top -= srcbitmap.height; end
    y = top; while y<dstrect.height
      x = left; while x<dstrect.width
        dstbitmap.blt(x+@borderX,y+@borderY,srcbitmap,srcrect)
        x += srcrect.width
      end
      y += srcrect.height
    end
  end
end



#===============================================================================
# A plane class that displays a single color.
#===============================================================================
class ColoredPlane < LargePlane
  def initialize(color,viewport=nil)
    super(viewport)
    self.bitmap=Bitmap.new(32,32)
    setPlaneColor(color)
  end

  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end

  def update; super; end

  def setPlaneColor(value)
    self.bitmap.fill_rect(0,0,self.bitmap.width,self.bitmap.height,value)
    self.refresh
  end
end



#===============================================================================
# A plane class that supports animated images.
#===============================================================================
class AnimatedPlane < LargePlane
  def initialize(viewport)
    super(viewport)
    @bitmap=nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    super
    if @bitmap
      @bitmap.update
      self.bitmap=@bitmap.bitmap
    end
  end

  def clearBitmaps
    @bitmap.dispose if @bitmap
    @bitmap=nil
    self.bitmap=nil if !self.disposed?
  end

  def setPanorama(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new("Graphics/Panoramas/"+file,hue)
  end

  def setFog(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new("Graphics/Fogs/"+file,hue)
  end

  def setBitmap(file, hue=0)
    clearBitmaps()
    return if file==nil
    @bitmap=AnimatedBitmap.new(file,hue)
  end
end
