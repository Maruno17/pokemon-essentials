#===============================================================================
#
#===============================================================================
class BushBitmap
  def initialize(bitmap, isTile, depth)
    @bitmaps  = []
    @bitmap   = bitmap
    @isTile   = isTile
    @isBitmap = @bitmap.is_a?(Bitmap)
    @depth    = depth
  end

  def dispose
    @bitmaps.each { |b| b&.dispose }
  end

  def bitmap
    thisBitmap = (@isBitmap) ? @bitmap : @bitmap.bitmap
    current = (@isBitmap) ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current] = pbBushDepthTile(thisBitmap, @depth)
      else
        @bitmaps[current] = pbBushDepthBitmap(thisBitmap, @depth)
      end
    end
    return @bitmaps[current]
  end

  def pbBushDepthBitmap(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height / 4
    cy = charheight - depth - 2
    4.times do |i|
      y = i * charheight
      if cy >= 0
        ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
        ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
      end
      ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    end
    return ret
  end

  def pbBushDepthTile(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height
    cy = charheight - depth - 2
    y = charheight
    if cy >= 0
      ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
      ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
    end
    ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class Sprite_Character < RPG::Sprite
  attr_accessor :character

  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @old_bush_depth = 0
    @spriteoffset = false
    if !character || character == $game_player || (character.name[/reflection/i] rescue false)
      @reflection = Sprite_Reflection.new(self, viewport)
    end
    @surfbase = Sprite_SurfBase.new(self, viewport) if character == $game_player
    self.zoom_x = TilemapRenderer::ZOOM_X
    self.zoom_y = TilemapRenderer::ZOOM_Y
    update
  end

  def dispose
    @bushbitmap&.dispose
    @bushbitmap = nil
    @charbitmap&.dispose
    @charbitmap = nil
    @reflection&.dispose
    @reflection = nil
    @surfbase&.dispose
    @surfbase = nil
    @character = nil
    super
  end

  #-----------------------------------------------------------------------------

  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
  end

  # Used by class Sprite_Reflection.
  def ground_y
    return @character.screen_y_ground
  end

  def source_frame_x
    return @character.pattern
  end

  def source_frame_y
    return (@character.direction - 2) / 2
  end

  def screen_x
    ret = @character.screen_x
    ret = ((ret - (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
    return ret
  end

  def screen_y
    ret = @character.screen_y
    ret = ((ret - (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
    return ret
  end

  def screen_z
    return @character.screen_z(@ch)
  end

  def bush_depth
    return @character.bush_depth
  end

  #-----------------------------------------------------------------------------

  def refresh_graphic
    return if @tile_id == @character.tile_id &&
              @character_name == @character.character_name &&
              @character_hue == @character.character_hue &&
              @old_bush_depth == @character.bush_depth
    @tile_id        = @character.tile_id
    @character_name = @character.character_name
    @character_hue  = @character.character_hue
    @old_bush_depth = @character.bush_depth
    @charbitmap&.dispose
    @charbitmap = nil
    @bushbitmap&.dispose
    @bushbitmap = nil
    if @tile_id >= TilemapRenderer::TILESET_START_ID
      set_tile_graphic
    elsif @character_name != ""
      set_charset_graphic
    else
      self.bitmap = nil
      @cw = 0
      @ch = 0
      @reflection&.update
    end
    @character.sprite_size = [@cw, @ch]
  end

  def set_tile_graphic
    @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                  @character_hue, @character.width, @character.height)
    @charbitmapAnimated = false
    @spriteoffset = false
    @cw = Game_Map::TILE_WIDTH * @character.width
    @ch = Game_Map::TILE_HEIGHT * @character.height
    self.src_rect.set(0, 0, @cw, @ch)
    self.ox = @cw / 2
    self.oy = @ch
  end

  def set_charset_graphic
    @charbitmap = AnimatedBitmap.new(
      "Graphics/Characters/" + @character_name, @character_hue
    )
    RPG::Cache.retain("Graphics/Characters/", @character_name, @character_hue) if @character == $game_player
    @charbitmapAnimated = true
    @spriteoffset = @character_name[/offset/i]
    @cw = @charbitmap.width / 4
    @ch = @charbitmap.height / 4
    self.ox = @cw / 2
  end

  #-----------------------------------------------------------------------------

  def update
    return if @character.is_a?(Game_Event) && !@character.should_update?
    super
    refresh_graphic   # Check if it has changed, and changes it if so
    return if !@charbitmap
    @charbitmap.update if @charbitmapAnimated
    # Update graphic
    update_bitmap   # For bush bitmaps and animated charbitmaps
    update_charset_frame
    # Update position
    update_charset_offset
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    # Update appearance
    update_visibility
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    update_tone
    # Update extra animation
    start_pending_animation
    # Update child graphics
    update_child_graphics
  end

  #-----------------------------------------------------------------------------

  private

  # Update animated bitmap, and alternate between bitmaps depending on whether
  # self has a bush depth (i.e. it makes the bottom few pixels transparent).
  def update_bitmap
    bushdepth = bush_depth
    if bushdepth == 0
      # Not in a bush, just update self's bitmap
      new_bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
      self.bitmap = new_bitmap if bitmap != new_bitmap
      return
    end
    # Make and use a bush bitmap
    @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= TilemapRenderer::TILESET_START_ID), bushdepth) if !@bushbitmap
    new_bitmap = @bushbitmap.bitmap
    self.bitmap = new_bitmap if bitmap != new_bitmap
  end

  def update_visibility
    self.visible = !@character.transparent
  end

  def update_charset_frame
    return if @tile_id > 0   # Is using a tile
    sx = source_frame_x * @cw
    sy = source_frame_y * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
    self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
  end

  def update_charset_offset
    return if @tile_id > 0   # Is using a tile
    self.oy -= @character.bob_height   # For the player when surfing/diving
  end

  def update_tone
    return if !self.visible
    if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
      self.tone.set(0, 0, 0, 0)
      return
    end
    pbDayNightTint(self)
  end

  def start_pending_animation
    return if !@character.animation_id || @character.animation_id == 0
    animation = $data_animations[@character.animation_id]
    animation(animation, true, @character.animation_height || 3, @character.animation_regular_tone || false)
    @character.animation_id = 0
  end

  def update_child_graphics
    @reflection&.update
    @surfbase&.update
  end
end
