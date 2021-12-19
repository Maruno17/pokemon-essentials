class TilemapRenderer
  module AutotileExpander
    MAX_TEXTURE_SIZE = (Bitmap.max_size / 1024) * 1024

    module_function

    # This doesn't allow for cache sizes smaller than 768, but if that applies
    # to you, you've got bigger problems.
    def expand(bitmap)
      return bitmap if bitmap.height == SOURCE_TILE_HEIGHT
      expanded_format = (bitmap.height == SOURCE_TILE_HEIGHT * 6)
      wrap = false
      if MAX_TEXTURE_SIZE < TILES_PER_AUTOTILE * SOURCE_TILE_HEIGHT
        wrap = true   # Each autotile will occupy two columns instead of one
      end
      frames_count = [bitmap.width / (3 * SOURCE_TILE_WIDTH), 1].max
      new_bitmap = Bitmap.new(frames_count * (wrap ? 2 : 1) * SOURCE_TILE_WIDTH,
                              TILES_PER_AUTOTILE * SOURCE_TILE_HEIGHT / (wrap ? 2 : 1))
      rect = Rect.new(0, 0, SOURCE_TILE_WIDTH / 2, SOURCE_TILE_HEIGHT / 2)
      TILES_PER_AUTOTILE.times do |id|
        pattern = TileDrawingHelper::AUTOTILE_PATTERNS[id >> 3][id % TILESET_TILES_PER_ROW]
        wrap_offset_x = (wrap && id >= TILES_PER_AUTOTILE / 2) ? SOURCE_TILE_WIDTH : 0
        wrap_offset_y = (wrap && id >= TILES_PER_AUTOTILE / 2) ? (TILES_PER_AUTOTILE / 2) * SOURCE_TILE_HEIGHT : 0
        frames_count.times do |frame|
          if expanded_format && [1, 2, 4, 8].include?(id)
            dest_x = frame * SOURCE_TILE_WIDTH * (wrap ? 2 : 1)
            dest_x += wrap_offset_x
            next if dest_x > MAX_TEXTURE_SIZE
            dest_y = id * SOURCE_TILE_HEIGHT
            dest_y -= wrap_offset_y
            next if dest_y > MAX_TEXTURE_SIZE
            case id
            when 1   # Top left corner
              new_bitmap.blt(dest_x, dest_y, bitmap,
                             Rect.new(frame * SOURCE_TILE_WIDTH * 3, SOURCE_TILE_HEIGHT * 4,
                                      SOURCE_TILE_WIDTH, SOURCE_TILE_HEIGHT))
            when 2   # Top right corner
              new_bitmap.blt(dest_x, dest_y, bitmap,
                             Rect.new(SOURCE_TILE_WIDTH + (frame * SOURCE_TILE_WIDTH * 3), SOURCE_TILE_HEIGHT * 4,
                                      SOURCE_TILE_WIDTH, SOURCE_TILE_HEIGHT))
            when 4   # Bottom right corner
              new_bitmap.blt(dest_x, dest_y, bitmap,
                             Rect.new(SOURCE_TILE_WIDTH + (frame * SOURCE_TILE_WIDTH * 3), SOURCE_TILE_HEIGHT * 5,
                                      SOURCE_TILE_WIDTH, SOURCE_TILE_HEIGHT))
            when 8   # Bottom left corner
              new_bitmap.blt(dest_x, dest_y, bitmap,
                             Rect.new(frame * SOURCE_TILE_WIDTH * 3, SOURCE_TILE_HEIGHT * 5,
                                      SOURCE_TILE_WIDTH, SOURCE_TILE_HEIGHT))
            end
            next
          end
          pattern.each_with_index do |src_chunk, i|
            real_src_chunk = src_chunk - 1
            dest_x = (i % 2) * SOURCE_TILE_WIDTH / 2
            dest_x += frame * SOURCE_TILE_WIDTH * (wrap ? 2 : 1)
            dest_x += wrap_offset_x
            next if dest_x > MAX_TEXTURE_SIZE
            dest_y = (i / 2) * SOURCE_TILE_HEIGHT / 2
            dest_y += id * SOURCE_TILE_HEIGHT
            dest_y -= wrap_offset_y
            next if dest_y > MAX_TEXTURE_SIZE
            rect.x = (real_src_chunk % 6) * SOURCE_TILE_WIDTH / 2
            rect.x += SOURCE_TILE_WIDTH * 3 * frame
            rect.y = (real_src_chunk / 6) * SOURCE_TILE_HEIGHT / 2
            new_bitmap.blt(dest_x, dest_y, bitmap, rect)
          end
        end
      end
      return new_bitmap
    end
  end
end
