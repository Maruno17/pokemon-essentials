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
      delay = $2.to_i
      delay = 10 if delay == 0
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

  def frameDelay(_index)
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
    AnimatedBitmap.new("Graphics/Tilesets/"+filename).deanimate
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
