class Hangup < Exception; end



def strsplit(str, re)
  ret = []
  tstr = str
  while re =~ tstr
    ret[ret.length] = $~.pre_match
    tstr = $~.post_match
  end
  ret[ret.length] = tstr if ret.length
  return ret
end

def canonicalize(c)
  csplit = strsplit(c, /[\/\\]/)
  pos = -1
  ret = []
  retstr = ""
  for x in csplit
    if x == ".."
      if pos >= 0
        ret.delete_at(pos)
        pos -= 1
      end
    elsif x != "."
      ret.push(x)
      pos += 1
    end
  end
  for i in 0...ret.length
    retstr += "/" if i > 0
    retstr += ret[i]
  end
  return retstr
end



#####################################################################
# TODO: Delete this class in Ruby 2+.
class WeakRef
  @@id_map =  {}
  @@id_rev_map =  {}
  @@final = lambda do |id|
    rids = @@id_map[id]
    if rids
      rids.each { |rid| @@id_rev_map.delete(rid) }
      @@id_map.delete(id)
    end
    rid = @@id_rev_map[id]
    if rid
      @@id_rev_map.delete(id)
      @@id_map[rid].delete(id)
      @@id_map.delete(rid) if @@id_map[rid].empty?
    end
  end

  # Create a new WeakRef from +orig+.
  def initialize(orig)
    __setobj__(orig)
  end

  def __getobj__
    unless @@id_rev_map[self.__id__] == @__id
      return nil
    end
    begin
      ObjectSpace._id2ref(@__id)
    rescue RangeError
      return nil
    end
  end

  def __setobj__(obj)
    @__id = obj.__id__
    unless @@id_rev_map.key?(self)
      ObjectSpace.define_finalizer obj, @@final
      ObjectSpace.define_finalizer self, @@final
    end
    @@id_map[@__id] = [] unless @@id_map[@__id]
    @@id_map[@__id].push self.__id__
    @@id_rev_map[self.__id__] = @__id
  end

  # Returns true if the referenced object still exists, and false if it has
  # been garbage collected.
  def weakref_alive?
    @@id_rev_map[self.__id__] == @__id
  end
end



# TODO: Delete this class in Ruby 2+.
class WeakHashtable
  include Enumerable

  def initialize
    @hash = {}
  end

  def clear
    @hash.clear
  end

  def delete(value)
    @hash.delete(value)
  end

  def include?(value)
    @hash.include?(value)
  end

  def each
    @hash.each { |i| yield i }
  end

  def keys
    @hash.keys
  end

  def values
    @hash.values
  end

  def [](key)
    o = @hash[key]
    return o if !o
    if o.weakref_alive?
      o = o.__getobj__
    else
      @hash.delete(key)
      o = nil
    end
    return o
  end

  def []=(key, o)
    o = WeakRef.new(o) if o != nil
    @hash[key] = o
  end
end



module RPG
  module Cache
    def self.load_bitmap(folder_name, filename, hue = 0)
      BitmapCache.load_bitmap(folder_name + filename.to_s, hue, true)
    end

    def self.animation(filename, hue)
      self.load_bitmap("Graphics/Animations/", filename, hue)
    end

    def self.autotile(filename)
      self.load_bitmap("Graphics/Autotiles/", filename)
    end

    def self.battleback(filename)
      self.load_bitmap("Graphics/Battlebacks/", filename)
    end

    def self.battler(filename, hue)
      self.load_bitmap("Graphics/Battlers/", filename, hue)
    end

    def self.character(filename, hue)
      self.load_bitmap("Graphics/Characters/", filename, hue)
    end

    def self.fog(filename, hue)
      self.load_bitmap("Graphics/Fogs/", filename, hue)
    end

    def self.gameover(filename)
      self.load_bitmap("Graphics/Gameovers/", filename)
    end

    def self.icon(filename)
      self.load_bitmap("Graphics/Icons/", filename)
    end

    def self.panorama(filename, hue)
      self.load_bitmap("Graphics/Panoramas/", filename, hue)
    end

    def self.picture(filename)
      self.load_bitmap("Graphics/Pictures/", filename)
    end

    def self.tileset(filename)
      self.load_bitmap("Graphics/Tilesets/", filename)
    end

    def self.title(filename)
      self.load_bitmap("Graphics/Titles/", filename)
    end

    def self.windowskin(filename)
      self.load_bitmap("Graphics/Windowskins/", filename)
    end

    def self.tile(filename, tile_id, hue)
      BitmapCache.tile(filename, tile_id, hue)
    end

    def self.clear
      BitmapCache.clear()
    end
  end
end



class BitmapWrapper < Bitmap
  attr_reader :refcount

  def dispose
    return if self.disposed?
    @refcount -= 1
    super if @refcount == 0
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



module BitmapCache
  # TODO: Replace this with the commented line in Ruby 2+.
  @cache = WeakHashtable.new
#  @cache = ObjectSpace::WeakMap.new

  def self.fromCache(i)
    return nil if !@cache.include?(i)
    obj = @cache[i]
    return nil if obj && obj.disposed?
    return obj
  end

  def self.setKey(key, obj)
    @cache[key] = obj
  end

  def self.debug
    File.open("bitmapcache2.txt", "wb") { |f|
      for i in @cache.keys
        k = fromCache(i)
        if !k
          f.write("#{i} (nil)\r\n")
        elsif k.disposed?
          f.write("#{i} (disposed)\r\n")
        else
          f.write("#{i} (#{k.refcount}, #{k.width}x#{k.height})\r\n")
        end
      end
    }
  end

  def self.load_bitmap(path, hue = 0, failsafe = false)
    cached = true
    path = canonicalize(path)
    objPath = fromCache(path)
    if !objPath
      # TODO: Delete this in Ruby 2+.
      @cleancounter = ((@cleancounter || 0) + 1) % 10
      if @cleancounter == 0
        for i in @cache.keys
          @cache.delete(i) if !fromCache(i)
        end
      end
      # TODO: Up to here.
      begin
        bm = BitmapWrapper.new(path)
      rescue Hangup
        begin
          bm = BitmapWrapper.new(path)
        rescue
          raise _INTL("Failed to load the bitmap located at: {1}", path) if !failsafe
          bm = BitmapWrapper.new(32, 32)
        end
      rescue
        raise _INTL("Failed to load the bitmap located at: {1}", path) if !failsafe
        bm = BitmapWrapper.new(32, 32)
      end
      objPath = bm
      @cache[path] = objPath
      cached = false
    end
    if hue == 0
      objPath.addRef if cached
      return objPath
    else
      key = [path, hue]
      objKey = fromCache(key)
      if !objKey
        bitmap = objPath.copy
        bitmap.hue_change(hue) if hue != 0
        objKey = bitmap
        @cache[key] = objKey
      else
        objKey.addRef
      end
      return objKey
    end
  end

  def self.animation(filename, hue)
    self.load_bitmap("Graphics/Animations/" + filename, hue)
  end

  def self.autotile(filename)
    self.load_bitmap("Graphics/Autotiles/" + filename)
  end

  def self.battleback(filename)
    self.load_bitmap("Graphics/Battlebacks/" + filename)
  end

  def self.battler(filename, hue)
    self.load_bitmap("Graphics/Battlers/" + filename, hue)
  end

  def self.character(filename, hue)
    self.load_bitmap("Graphics/Characters/" + filename, hue)
  end

  def self.fog(filename, hue)
    self.load_bitmap("Graphics/Fogs/" + filename, hue)
  end

  def self.gameover(filename)
    self.load_bitmap("Graphics/Gameovers/" + filename)
  end

  def self.icon(filename)
    self.load_bitmap("Graphics/Icons/" + filename)
  end

  def self.panorama(filename, hue)
    self.load_bitmap("Graphics/Panoramas/" + filename, hue)
  end

  def self.picture(filename)
    self.load_bitmap("Graphics/Pictures/" + filename)
  end

  def self.tileset(filename)
    self.load_bitmap("Graphics/Tilesets/" + filename)
  end

  def self.title(filename)
    self.load_bitmap("Graphics/Titles/" + filename)
  end

  def self.windowskin(filename)
    self.load_bitmap("Graphics/Windowskins/" + filename)
  end

  def self.tileEx(filename, tile_id, hue)
    key = [filename, tile_id, hue]
    objKey = fromCache(key)
    if !objKey
      bitmap = BitmapWrapper.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
      x = (tile_id - 384) % 8 * 32
      y = (tile_id - 384) / 8 * 32
      rect = Rect.new(x, y, Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
      tileset = yield(filename)
      bitmap.blt(0, 0, tileset, rect)
      tileset.dispose
      bitmap.hue_change(hue) if hue != 0
      objKey = bitmap
      @cache[key] = objKey
    else
      objKey.addRef
    end
    objKey
  end

  def self.tile(filename, tile_id, hue)
    return self.tileEx(filename, tile_id, hue) { |f| self.tileset(f) }
  end

  def self.clear
    # TODO: Replace this with the commented line in Ruby 2+.
    @cache.clear
#    @cache = ObjectSpace::WeakMap.new
    GC.start
  end
end
