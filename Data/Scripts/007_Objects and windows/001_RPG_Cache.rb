class Hangup < Exception; end



module RPG
  module Cache
    def self.debug
      t = Time.now
      filename = t.strftime("%H %M %S.%L.txt")
      File.open("cache_" + filename, "wb") { |f|
        @cache.each do |key, value|
          if !value
            f.write("#{key} (nil)\r\n")
          elsif value.disposed?
            f.write("#{key} (disposed)\r\n")
          else
            f.write("#{key} (#{value.refcount}, #{value.width}x#{value.height})\r\n")
          end
        end
      }
    end

    def self.setKey(key, obj)
      @cache[key] = obj
    end

    def self.fromCache(i)
      return nil if !@cache.include?(i)
      obj = @cache[i]
      return nil if obj&.disposed?
      return obj
    end

    def self.load_bitmap(folder_name, filename, hue = 0)
      path = folder_name + filename
      cached = true
      ret = fromCache(path)
      if !ret
        if filename == ""
          ret = BitmapWrapper.new(32, 32)
        else
          ret = BitmapWrapper.new(path)
        end
        @cache[path] = ret
        cached = false
      end
      if hue == 0
        ret.addRef if cached
        return ret
      end
      key = [path, hue]
      ret2 = fromCache(key)
      if ret2
        ret2.addRef
      else
        ret2 = ret.copy
        ret2.hue_change(hue)
        @cache[key] = ret2
      end
      return ret2
    end

    def self.tileEx(filename, tile_id, hue, width = 1, height = 1)
      key = [filename, tile_id, hue, width, height]
      ret = fromCache(key)
      if ret
        ret.addRef
      else
        ret = BitmapWrapper.new(32 * width, 32 * height)
        x = (tile_id - 384) % 8 * 32
        y = (((tile_id - 384) / 8) - height + 1) * 32
        tileset = yield(filename)
        ret.blt(0, 0, tileset, Rect.new(x, y, 32 * width, 32 * height))
        tileset.dispose
        ret.hue_change(hue) if hue != 0
        @cache[key] = ret
      end
      return ret
    end

    def self.tile(filename, tile_id, hue)
      return self.tileEx(filename, tile_id, hue) { |f| self.tileset(f) }
    end

    def self.transition(filename)
      self.load_bitmap("Graphics/Transitions/", filename)
    end

    def self.retain(folder_name, filename = "", hue = 0)
      path = folder_name + filename
      ret = fromCache(path)
      if hue > 0
        key = [path, hue]
        ret2 = fromCache(key)
        if ret2
          ret2.never_dispose = true
          return
        end
      end
      ret.never_dispose = true if ret
    end
  end
end



class BitmapWrapper < Bitmap
  attr_reader   :refcount
  attr_accessor :never_dispose

  def dispose
    return if self.disposed?
    @refcount -= 1
    super if @refcount <= 0 && !never_dispose
  end

  def initialize(*arg)
    super
    @refcount = 1
  end

  def resetRef
    @refcount = 1
  end

  def copy
    bm = self.clone
    bm.resetRef
    return bm
  end

  def addRef
    @refcount += 1
  end
end
