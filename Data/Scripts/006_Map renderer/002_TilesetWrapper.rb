#===============================================================================
# This module is a little fix that works around PC hardware limitations. Since
# Essentials isn't working with software rendering anymore, it now has to deal
# with the limits of the GPU. For the most part this is no big deal, but people
# do have some really big tilesets.
#
# The fix is simple enough: If your tileset is too big, a new bitmap will be
# constructed with all the excess pixels sent to the image's right side. This
# basically means that you now have a limit far higher than you should ever
# actually need.
#
# Hardware limit   -> max tileset length:
# 1024px           -> 4096px
# 2048px           -> 16384px   (enough to get the normal limit)
# 4096px           -> 65536px   (enough to load pretty much any tileset)
# 8192px           -> 262144px
# 16384px          -> 1048576px (what most people have at this point)
#
#                             ~Roza/Zoroark
#===============================================================================
class TilemapRenderer
  module TilesetWrapper
    TILESET_WIDTH        = SOURCE_TILE_WIDTH * TILESET_TILES_PER_ROW
    # Looks useless, but covers weird numbers given to mkxp.json or a funky driver
    MAX_TEX_SIZE         = (Bitmap.max_size / 1024) * 1024
    MAX_TEX_SIZE_BOOSTED = (MAX_TEX_SIZE**2) / TILESET_WIDTH

    module_function

    def wrapTileset(originalbmp)
      width = originalbmp.width
      height = originalbmp.height
      if width == TILESET_WIDTH && originalbmp.mega?
        columns = (height / MAX_TEX_SIZE.to_f).ceil
        if columns * TILESET_WIDTH > MAX_TEX_SIZE
          raise "Tileset is too long!\n\nSIZE: #{originalbmp.height}px\nHARDWARE LIMIT: #{MAX_TEX_SIZE}px\nBOOSTED LIMIT: #{MAX_TEX_SIZE_BOOSTED}px"
        end
        bmp = Bitmap.new(TILESET_WIDTH * columns, MAX_TEX_SIZE)
        remainder = height % MAX_TEX_SIZE
        remainder = MAX_TEX_SIZE if remainder == 0
        columns.times do |col|
          srcrect = Rect.new(0, col * MAX_TEX_SIZE, width, (col + 1 == columns) ? remainder : MAX_TEX_SIZE)
          bmp.blt(col * TILESET_WIDTH, 0, originalbmp, srcrect)
        end
        return bmp
      end
      return originalbmp
    end

    def getWrappedRect(src_rect)
      ret = Rect.new(0, 0, 0, 0)
      col = (src_rect.y / MAX_TEX_SIZE.to_f).floor
      ret.x = (col * TILESET_WIDTH) + src_rect.x.clamp(0, TILESET_WIDTH)
      ret.y = src_rect.y % MAX_TEX_SIZE
      ret.width = src_rect.width.clamp(0, TILESET_WIDTH - src_rect.x)
      ret.height = src_rect.height.clamp(0, MAX_TEX_SIZE)
      return ret
    end

    #---------------------------------------------------------------------------

    private

    def blitWrappedPixels(destX, destY, dest, src, srcrect)
      if srcrect.y + srcrect.width < MAX_TEX_SIZE
        # Save the processing power
        dest.blt(destX, destY, src, srcrect)
        return
      end
      merge = (srcrect.y % MAX_TEX_SIZE) > ((srcrect.y + srcrect.height) % MAX_TEX_SIZE)
      srcrect_mod = getWrappedRect(srcrect)
      if merge
        # FIXME: won't work on heights longer than two columns, but nobody should need
        # more than 32k pixels high at once anyway
        side = {
          :a => MAX_TEX_SIZE - srcrect_mod.y,
          :b => srcrect_mod.height - MAX_TEX_SIZE + srcrect_mod.y
        }
        dest.blt(destX, destY, src, Rect.new(srcrect_mod.x, srcrect_mod.y, srcrect_mod.width, side[:a]))
        dest.blt(destX, destY + side[:a], src, Rect.new(srcrect_mod.x + TILESET_WIDTH, 0, srcrect_mod.width, side[:b]))
      else
        dest.blt(destX, destY, src, srcrect_mod)
      end
    end

    def stretchBlitWrappedPixels(destrect, dest, src, srcrect)
      if srcrect.y + srcrect.width < MAX_TEX_SIZE
        # Save the processing power
        dest.stretch_blt(destrect, src, srcrect)
        return
      end
      # Does a regular blit to a non-megasurface, then stretch_blts that to
      # the destination. Yes it is slow
      tmp = Bitmap.new(srcrect.width, srcrect.height)
      blitWrappedPixels(0, 0, tmp, src, srcrect)
      dest.stretch_blt(destrect, tmp, Rect.new(0, 0, srcrect.width, srcrect.height))
    end
  end
end
