module ScreenPosHelper
  def self.pbScreenZoomX(ch)
    return Game_Map::TILE_WIDTH / 32.0
  end

  def self.pbScreenZoomY(ch)
    return Game_Map::TILE_HEIGHT / 32.0
  end

  def self.pbScreenX(ch)
    return ch.screen_x
  end

  def self.pbScreenY(ch)
    return ch.screen_y
  end

  @heightcache = {}

  def self.bmHeight(bm)
    h = @heightcache[bm]
    if !h
      bmap = AnimatedBitmap.new("Graphics/Characters/" + bm, 0)
      h = bmap.height
      @heightcache[bm] = h
      bmap.dispose
    end
    return h
  end

  def self.pbScreenZ(ch, height = nil)
    if height.nil?
      height = 0
      if ch.tile_id > 0
        height = 32
      elsif ch.character_name != ""
        height = bmHeight(ch.character_name) / 4
      end
    end
    ret = ch.screen_z(height)
    return ret
  end
end
