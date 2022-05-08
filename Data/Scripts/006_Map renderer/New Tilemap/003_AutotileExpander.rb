class TilemapRenderer
  module AutotileExpander
    MAX_TEXTURE_SIZE = (Bitmap.max_size / 1024) * 1024
    AUTOTILE_PATTERNS = [
      [ [27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],
        [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12] ],
      [ [27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],
        [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12] ],
      [ [25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
        [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12] ],
      [ [29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],
        [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46] ],
      [ [25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
        [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48] ],
      [ [37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
        [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8] ]
    ]

    # TODO: Doesn't allow for cache sizes smaller than 768.
    def self.expand(bitmap)
      return bitmap if bitmap.height == SOURCE_TILE_HEIGHT
      wrap = false
      if MAX_TEXTURE_SIZE < TILES_PER_AUTOTILE * SOURCE_TILE_HEIGHT
        wrap = true   # Each autotile will occupy two columns instead of one
      end
      frames_count = [bitmap.width / (3 * SOURCE_TILE_WIDTH), 1].max
      new_bitmap = Bitmap.new(frames_count * (wrap ? 2 : 1) * SOURCE_TILE_WIDTH,
                              TILES_PER_AUTOTILE * SOURCE_TILE_HEIGHT / (wrap ? 2 : 1))
      rect = Rect.new(0, 0, SOURCE_TILE_WIDTH / 2, SOURCE_TILE_HEIGHT / 2)
      TILES_PER_AUTOTILE.times do |id|
        pattern = AUTOTILE_PATTERNS[id >> 3][id % TILESET_TILES_PER_ROW]
        wrap_offset_x = (wrap && id >= TILES_PER_AUTOTILE / 2) ? SOURCE_TILE_WIDTH : 0
        wrap_offset_y = (wrap && id >= TILES_PER_AUTOTILE / 2) ? (TILES_PER_AUTOTILE / 2) * SOURCE_TILE_HEIGHT : 0
        frames_count.times do |frame|
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
