#===============================================================================
#
#===============================================================================
class TileDrawingHelper
  attr_accessor :tileset
  attr_accessor :autotiles

  AUTOTILE_PATTERNS = [
    [[27, 28, 33, 34], [5, 28, 33, 34], [27,  6, 33, 34], [5,  6, 33, 34],
     [27, 28, 33, 12], [5, 28, 33, 12], [27,  6, 33, 12], [5,  6, 33, 12]],
    [[27, 28, 11, 34], [5, 28, 11, 34], [27,  6, 11, 34], [5,  6, 11, 34],
     [27, 28, 11, 12], [5, 28, 11, 12], [27,  6, 11, 12], [5,  6, 11, 12]],
    [[25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
     [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12]],
    [[29, 30, 35, 36], [29, 30, 11, 36], [5, 30, 35, 36], [5, 30, 11, 36],
     [39, 40, 45, 46], [5, 40, 45, 46], [39,  6, 45, 46], [5,  6, 45, 46]],
    [[25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
     [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [5, 42, 47, 48]],
    [[37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
     [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [1,  2,  7,  8]]
  ]

  # converts neighbors returned from tableNeighbors to tile indexes
  NEIGHBORS_TO_AUTOTILE_INDEX = [
    46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
    42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
    46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
    42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
    45, 39, 45, 39, 33, 31, 33, 29, 45, 39, 45, 39, 33, 31, 33, 29,
    37, 27, 37, 27, 23, 15, 23, 13, 37, 27, 37, 27, 22, 11, 22,  9,
    45, 39, 45, 39, 33, 31, 33, 29, 45, 39, 45, 39, 33, 31, 33, 29,
    36, 26, 36, 26, 21,  7, 21,  5, 36, 26, 36, 26, 20,  3, 20,  1,
    46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
    42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
    46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
    42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
    45, 38, 45, 38, 33, 30, 33, 28, 45, 38, 45, 38, 33, 30, 33, 28,
    37, 25, 37, 25, 23, 14, 23, 12, 37, 25, 37, 25, 22, 10, 22,  8,
    45, 38, 45, 38, 33, 30, 33, 28, 45, 38, 45, 38, 33, 30, 33, 28,
    36, 24, 36, 24, 21,  6, 21,  4, 36, 24, 36, 24, 20,  2, 20,  0
  ]

  def self.tableNeighbors(data, x, y, layer = nil)
    return 0 if x < 0 || x >= data.xsize
    return 0 if y < 0 || y >= data.ysize
    if layer.nil?
      t = data[x, y]
    else
      t = data[x, y, layer]
    end
    xp1 = [x + 1, data.xsize - 1].min
    yp1 = [y + 1, data.ysize - 1].min
    xm1 = [x - 1, 0].max
    ym1 = [y - 1, 0].max
    i = 0
    if layer.nil?
      i |= 0x01 if data[  x, ym1] == t   # N
      i |= 0x02 if data[xp1, ym1] == t   # NE
      i |= 0x04 if data[xp1,   y] == t   # E
      i |= 0x08 if data[xp1, yp1] == t   # SE
      i |= 0x10 if data[  x, yp1] == t   # S
      i |= 0x20 if data[xm1, yp1] == t   # SW
      i |= 0x40 if data[xm1,   y] == t   # W
      i |= 0x80 if data[xm1, ym1] == t   # NW
    else
      i |= 0x01 if data[  x, ym1, layer] == t   # N
      i |= 0x02 if data[xp1, ym1, layer] == t   # NE
      i |= 0x04 if data[xp1,   y, layer] == t   # E
      i |= 0x08 if data[xp1, yp1, layer] == t   # SE
      i |= 0x10 if data[  x, yp1, layer] == t   # S
      i |= 0x20 if data[xm1, yp1, layer] == t   # SW
      i |= 0x40 if data[xm1,   y, layer] == t   # W
      i |= 0x80 if data[xm1, ym1, layer] == t   # NW
    end
    return i
  end

  def self.fromTileset(tileset)
    bmtileset = pbGetTileset(tileset.tileset_name)
    bmautotiles = []
    7.times do |i|
      bmautotiles.push(pbGetAutotile(tileset.autotile_names[i]))
    end
    return self.new(bmtileset, bmautotiles)
  end

  #-----------------------------------------------------------------------------

  def initialize(tileset, autotiles)
    if tileset.mega?
      @tileset = TilemapRenderer::TilesetWrapper.wrapTileset(tileset)
      tileset.dispose
      @shouldWrap = true
    else
      @tileset = tileset
      @shouldWrap = false
    end
    @autotiles = autotiles
  end

  def dispose
    @tileset&.dispose
    @tileset = nil
    @autotiles.each_with_index do |autotile, i|
      autotile.dispose
      @autotiles[i] = nil
    end
  end

  def bltSmallAutotile(bitmap, x, y, cxTile, cyTile, id, frame)
    return if id >= TilemapRenderer::TILESET_START_ID || frame < 0 || !@autotiles
    autotile = @autotiles[(id / TilemapRenderer::TILES_PER_AUTOTILE) - 1]
    return if !autotile || autotile.disposed?
    cxTile = [cxTile / 2, 1].max
    cyTile = [cyTile / 2, 1].max
    if autotile.height == 32
      anim = frame * 32
      src_rect = Rect.new(anim, 0, 32, 32)
      bitmap.stretch_blt(Rect.new(x, y, cxTile * 2, cyTile * 2), autotile, src_rect)
    else
      anim = frame * 32 * 3   # Frames of a large autotile are 3 tiles wide
      id %= TilemapRenderer::TILES_PER_AUTOTILE
      tiles = AUTOTILE_PATTERNS[id >> 3][id & 7]
      src = Rect.new(0, 0, 0, 0)
      4.times do |i|
        tile_position = tiles[i] - 1
        src.set(((tile_position % 6) * 16) + anim, (tile_position / 6) * 16, 16, 16)
        bitmap.stretch_blt(Rect.new((i % 2 * cxTile) + x, (i / 2 * cyTile) + y, cxTile, cyTile),
                           autotile, src)
      end
    end
  end

  def bltSmallRegularTile(bitmap, x, y, cxTile, cyTile, id)
    return if id < TilemapRenderer::TILESET_START_ID || !@tileset || @tileset.disposed?
    rect = Rect.new(((id - TilemapRenderer::TILESET_START_ID) % TilemapRenderer::TILESET_TILES_PER_ROW) * 32,
                    ((id - TilemapRenderer::TILESET_START_ID) / TilemapRenderer::TILESET_TILES_PER_ROW) * 32, 32, 32)
    rect = TilemapRenderer::TilesetWrapper.getWrappedRect(rect) if @shouldWrap
    bitmap.stretch_blt(Rect.new(x, y, cxTile, cyTile), @tileset, rect)
  end

  def bltSmallTile(bitmap, x, y, cxTile, cyTile, id, frame = 0)
    if id >= TilemapRenderer::TILESET_START_ID
      bltSmallRegularTile(bitmap, x, y, cxTile, cyTile, id)
    elsif id > 0
      bltSmallAutotile(bitmap, x, y, cxTile, cyTile, id, frame)
    end
  end

  def bltAutotile(bitmap, x, y, id, frame)
    bltSmallAutotile(bitmap, x, y, 32, 32, id, frame)
  end

  def bltRegularTile(bitmap, x, y, id)
    bltSmallRegularTile(bitmap, x, y, 32, 32, id)
  end

  def bltTile(bitmap, x, y, id, frame = 0)
    if id >= TilemapRenderer::TILESET_START_ID
      bltRegularTile(bitmap, x, y, id)
    elsif id > 0
      bltAutotile(bitmap, x, y, id, frame)
    end
  end
end

#===============================================================================
#
#===============================================================================
def createMapBitmap(map_id, tile_width = Game_Map::TILE_WIDTH, tile_height = Game_Map::TILE_HEIGHT, with_outline = false)
  map_file = sprintf("Data/Map%03d.rxdata", map_id)
  map = nil
  if pbRgssExists?(map_file)
    map = load_data(map_file) rescue nil
  end
  return Bitmap.new(32, 32) if !map
  bitmap = Bitmap.new(map.width * tile_width, map.height * tile_height)
  tileset = $data_tilesets[map.tileset_id]
  return bitmap if !tileset
  helper = TileDrawingHelper.fromTileset(tileset)
  map.height.times do |y|
    map.width.times do |x|
      Game_Map::LAYERS_COUNT.times do |layer|
        id = map.data[x, y, layer]
        id = 0 if !id
        helper.bltSmallTile(bitmap, x * tile_width, y * tile_height, tile_width, tile_height, id)
      end
    end
  end
  if with_outline
    black = Color.black
    bitmap.fill_rect(0, 0, bitmap.width, 1, black)
    bitmap.fill_rect(0, bitmap.height - 1, bitmap.width, 1, black)
    bitmap.fill_rect(0, 0, 1, bitmap.height, black)
    bitmap.fill_rect(bitmap.width - 1, 0, 1, bitmap.height, black)
  end
  return bitmap
end

# Creates a bitmap of a map, with each tile being 4x4 pixels (0.125x zoom). It
# has a black outline around it.
def createMinimap(map_id)
  return createMapBitmap(map_id, 4, 4, true)
end

def bltMinimapAutotile(dstBitmap, x, y, srcBitmap, id)
  return if id >= 48 || !srcBitmap || srcBitmap.disposed?
  anim = 0
  cxTile = 3
  cyTile = 3
  tiles = TileDrawingHelper::AUTOTILE_PATTERNS[id >> 3][id & 7]
  src = Rect.new(0, 0, 0, 0)
  4.times do |i|
    tile_position = tiles[i] - 1
    src.set((tile_position % 6 * cxTile) + anim,
            tile_position / 6 * cyTile, cxTile, cyTile)
    dstBitmap.blt((i % 2 * cxTile) + x, (i / 2 * cyTile) + y, srcBitmap, src)
  end
end

def passable?(passages, tile_id)
  return false if tile_id.nil?
  passage = passages[tile_id]
  return (passage && passage < 15)
end

# Unused
def getPassabilityMinimap(mapid)
  map = load_data(sprintf("Data/Map%03d.rxdata", mapid))
  tileset = $data_tilesets[map.tileset_id]
  minimap = AnimatedBitmap.new("Graphics/UI/minimap_tiles")
  ret = Bitmap.new(map.width * 6, map.height * 6)
  passtable = Table.new(map.width, map.height)
  passages = tileset.passages
  map.width.times do |i|
    map.height.times do |j|
      pass = true
      (Game_Map::LAYERS_COUNT - 1).downto(0) do |layer|
        if !passable?(passages, map.data[i, j, layer])
          pass = false
          break
        end
      end
      passtable[i, j] = pass ? 1 : 0
    end
  end
  neighbors = TileDrawingHelper::NEIGHBORS_TO_AUTOTILE_INDEX
  map.width.times do |i|
    map.height.times do |j|
      next if passtable[i, j] != 0
      nb = TileDrawingHelper.tableNeighbors(passtable, i, j)
      tile = neighbors[nb]
      bltMinimapAutotile(ret, i * 6, j * 6, minimap.bitmap, tile)
    end
  end
  minimap.dispose
  return ret
end
