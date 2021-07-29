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
    #super
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
    y = top
    while y<dstrect.height
      x = left
      while x<dstrect.width
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
