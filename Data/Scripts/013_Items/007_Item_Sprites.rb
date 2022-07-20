#===============================================================================
# Item icon
#===============================================================================
class ItemIconSprite < Sprite
  attr_reader :item

  ANIM_ICON_SIZE   = 48
  FRAMES_PER_CYCLE = Graphics.frame_rate

  def initialize(x, y, item, viewport = nil)
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
    @animbitmap&.dispose
    super
  end

  def width
    return 0 if !self.bitmap || self.bitmap.disposed?
    return (@numframes == 1) ? self.bitmap.width : ANIM_ICON_SIZE
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

  def setOffset(offset = PictureOrigin::CENTER)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    @offset = PictureOrigin::CENTER if !@offset
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
      self.oy = 0
    when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
      self.oy = self.height / 2
    when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
      self.oy = self.height
    end
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
      self.ox = 0
    when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
      self.ox = self.width / 2
    when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
      self.ox = self.width
    end
  end

  def item=(value)
    return if @item == value && !@forceitemchange
    @item = value
    @animbitmap&.dispose
    @animbitmap = nil
    if @item || !@blankzero
      @animbitmap = AnimatedBitmap.new(GameData::Item.icon_filename(@item))
      self.bitmap = @animbitmap.bitmap
      if self.bitmap.height == ANIM_ICON_SIZE
        @numframes = [(self.bitmap.width / ANIM_ICON_SIZE).floor, 1].max
        self.src_rect = Rect.new(0, 0, ANIM_ICON_SIZE, ANIM_ICON_SIZE)
      else
        @numframes = 1
        self.src_rect = Rect.new(0, 0, self.bitmap.width, self.bitmap.height)
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
      if @numframes > 1
        frameskip = (FRAMES_PER_CYCLE / @numframes).floor
        @frame = (@frame + 1) % FRAMES_PER_CYCLE
        if @frame >= frameskip
          @animframe = (@animframe + 1) % @numframes
          self.src_rect.x = @animframe * ANIM_ICON_SIZE
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
class HeldItemIconSprite < Sprite
  def initialize(x, y, pokemon, viewport = nil)
    super(viewport)
    self.x = x
    self.y = y
    @pokemon = pokemon
    @item = nil
    self.item = @pokemon.item_id
  end

  def dispose
    @animbitmap&.dispose
    super
  end

  def pokemon=(value)
    @pokemon = value
    self.item = @pokemon.item_id
  end

  def item=(value)
    return if @item == value
    @item = value
    @animbitmap&.dispose
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
