#===============================================================================
# Item icon
#===============================================================================
class ItemIconSprite < SpriteWrapper
  attr_reader :item
  ANIM_ICON_SIZE   = 48
  FRAMES_PER_CYCLE = Graphics.frame_rate

  def initialize(x,y,item,viewport=nil)
    super(viewport)
    @animbitmap = nil
    @animframe = 0
    @numframes = 1
    @frame = 0
    self.x = x
    self.y = y
    @blankzero = false
    @forceitemchange = true
    self.item = item
    @forceitemchange = false
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def width
    return 0 if !self.bitmap || self.bitmap.disposed?
    return (@numframes==1) ? self.bitmap.width : ANIM_ICON_SIZE
  end

  def height
    return (self.bitmap && !self.bitmap.disposed?) ? self.bitmap.height : 0
  end

  def blankzero=(val)
    @blankzero = val
    @forceitemchange = true
    self.item = @item
    @forceitemchange = false
  end

  def setOffset(offset=PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    @offset = PictureOrigin::Center if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      self.oy = self.height/2
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.height
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.width/2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.width
    end
  end

  def item=(value)
    return if @item==value && !@forceitemchange
    @item = value
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    if @item || !@blankzero
      @animbitmap = AnimatedBitmap.new(GameData::Item.icon_filename(@item))
      self.bitmap = @animbitmap.bitmap
      if self.bitmap.height==ANIM_ICON_SIZE
        @numframes = [(self.bitmap.width/ANIM_ICON_SIZE).floor,1].max
        self.src_rect = Rect.new(0,0,ANIM_ICON_SIZE,ANIM_ICON_SIZE)
      else
        @numframes = 1
        self.src_rect = Rect.new(0,0,self.bitmap.width,self.bitmap.height)
      end
      @animframe = 0
      @frame = 0
    else
      self.bitmap = nil
    end
    changeOrigin
  end

  def update
    @updating = true
    super
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
      if @numframes>1
        frameskip = (FRAMES_PER_CYCLE/@numframes).floor
        @frame = (@frame+1)%FRAMES_PER_CYCLE
        if @frame>=frameskip
          @animframe = (@animframe+1)%@numframes
          self.src_rect.x = @animframe*ANIM_ICON_SIZE
          @frame = 0
        end
      end
    end
    @updating = false
  end
end



#===============================================================================
# Item held icon (used in the party screen)
#===============================================================================
class HeldItemIconSprite < SpriteWrapper
  def initialize(x,y,pokemon,viewport=nil)
    super(viewport)
    self.x = x
    self.y = y
    @pokemon = pokemon
    @item = nil
    self.item = @pokemon.item_id
  end

  def dispose
    @animbitmap.dispose if @animbitmap
    super
  end

  def pokemon=(value)
    @pokemon = value
    self.item = @pokemon.item_id
  end

  def item=(value)
    return if @item==value
    @item = value
    @animbitmap.dispose if @animbitmap
    @animbitmap = nil
    if @item
      @animbitmap = AnimatedBitmap.new(GameData::Item.held_icon_filename(@item))
      self.bitmap = @animbitmap.bitmap
    else
      self.bitmap = nil
    end
  end

  def update
    super
    self.item = @pokemon.item_id
    if @animbitmap
      @animbitmap.update
      self.bitmap = @animbitmap.bitmap
    end
  end
end
