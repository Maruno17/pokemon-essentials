class Hangup < Exception; end



def strsplit(str,re)
  ret=[]
  tstr=str
  while re=~tstr
    ret[ret.length]=$~.pre_match
    tstr=$~.post_match
  end
  ret[ret.length]=tstr if ret.length
  return ret
end

def canonicalize(c)
  csplit = strsplit(c,/[\/\\]/)
  pos = -1
  ret = []
  retstr = ""
  for x in csplit
    if x=="."
    elsif x==".."
      if pos>=0
        ret.delete_at(pos)
        pos -= 1
      end
    else
      ret.push(x)
      pos += 1
    end
  end
  for i in 0...ret.length
    retstr += "/" if i>0
    retstr += ret[i]
  end
  return retstr
end



#####################################################################
class WeakRef
  @@id_map =  {}
  @@id_rev_map =  {}
  @@final = lambda { |id|
    old_thread_status = Thread.critical
    Thread.critical = true
    begin
      rids = @@id_map[id]
      if rids
	      for rid in rids
	        @@id_rev_map.delete(rid)
        end
        @@id_map.delete(id)
      end
      rid = @@id_rev_map[id]
      if rid
	      @@id_rev_map.delete(id)
	      @@id_map[rid].delete(id)
	      @@id_map.delete(rid) if @@id_map[rid].empty?
      end
    ensure
      Thread.critical = old_thread_status
    end
  }

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
    old_thread_status = Thread.critical
    begin
      Thread.critical = true
      unless @@id_rev_map.key?(self)
        ObjectSpace.define_finalizer obj, @@final
        ObjectSpace.define_finalizer self, @@final
      end
      @@id_map[@__id] = [] unless @@id_map[@__id]
    ensure
      Thread.critical = old_thread_status
    end
    @@id_map[@__id].push self.__id__
    @@id_rev_map[self.__id__] = @__id
  end

  # Returns true if the referenced object still exists, and false if it has
  # been garbage collected.
  def weakref_alive?
    @@id_rev_map[self.__id__] == @__id
  end
end



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
    o=@hash[key]
    return o if !o
    if o.weakref_alive?
      o=o.__getobj__
    else
      @hash.delete(key)
      o=nil
    end
    return o
  end

  def []=(key,o)
    if o!=nil
      o=WeakRef.new(o)
    end
    @hash[key]=o
  end
end



# Cache from RPG Maker VX library
module Cache
  def self.system(x,hue=0)
    BitmapCache.load_bitmap("Graphics/System/"+x,hue, true)
  end

  def self.character(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Characters/"+x,hue, true)
  end

  def self.picture(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Pictures/"+x,hue, true)
  end

  def self.animation(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Animations/"+x,hue, true)
  end

  def self.battler(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Battlers/"+x,hue, true)
  end

  def self.face(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Faces/"+x,hue, true)
  end

  def self.parallax(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Parallaxes/"+x,hue, true)
  end

  def self.clear
    BitmapCache.clear()
  end

  def self.load_bitmap(dir,name,hue=0)
    BitmapCache.load_bitmap(dir+name,hue, true)
  end
end



# RPG::Cache from RPG Maker XP library
module RPG
  module Cache
    def self.load_bitmap(folder_name, filename, hue = 0)
	    BitmapCache.load_bitmap(folder_name+filename.to_s,hue, true)
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
      BitmapCache.tile(filename,tile_id,hue)
    end

    def self.clear
      BitmapCache.clear()
    end
  end
end



# A safer version of RPG::Cache, this module loads bitmaps that keep an internal
# reference count.  Each call to dispose decrements the reference count and the
# bitmap is freed when the reference count reaches 0.
class Thread
  def Thread.exclusive
    old_thread_status = Thread.critical
    begin
      Thread.critical = true
      return yield
    ensure
      Thread.critical = old_thread_status
    end
  end
end



class BitmapWrapper < Bitmap
  @@disposedBitmaps={}
  @@keys={}
=begin
  @@final = lambda { |id|
    Thread.exclusive {
      if @@disposedBitmaps[id]!=true
        File.open("debug.txt","ab") { |f|
          f.write("Bitmap finalized without being disposed: #{@@keys[id]}\r\n")
        }
      end
      @@disposedBitmaps[id]=nil
    }
  }
=end
  attr_reader :refcount

  def dispose
    return if self.disposed?
    @refcount-=1
    if @refcount==0
      super
      #Thread.exclusive { @@disposedBitmaps[__id__]=true }
    end
  end

  def initialize(*arg)
    super
    @refcount=1
    #Thread.exclusive { @@keys[__id__]=arg.inspect+caller(1).inspect }
    #ObjectSpace.define_finalizer(self,@@final)
  end

  def resetRef # internal
    @refcount=1
  end

  def copy
    bm=self.clone
    bm.resetRef
    return bm
  end

  def addRef
    @refcount+=1
  end
end



module BitmapCache
  @cache = WeakHashtable.new

  def self.fromCache(i)
    return nil if !@cache.include?(i)
    obj=@cache[i]
    return nil if obj && obj.disposed?
    return obj
  end

  def self.setKey(key,obj)
    @cache[key]=obj
  end

  def self.debug
    File.open("bitmapcache2.txt","wb") { |f|
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
      @cleancounter = ((@cleancounter || 0) + 1)%10
      if @cleancounter == 0
        for i in @cache.keys
          @cache.delete(i) if !fromCache(i)
        end
      end
      begin
        bm = BitmapWrapper.new(path)
      rescue Hangup
        begin
          bm = BitmapWrapper.new(path)
        rescue
          raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
          bm = BitmapWrapper.new(32,32)
        end
      rescue
        raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
        bm = BitmapWrapper.new(32,32)
      end
      objPath = bm
      @cache[path] = objPath
      cached=false
    end
    if hue == 0
      objPath.addRef if cached
      return objPath
    else
      key = [path, hue]
      objKey = fromCache(key)
      if !objKey
        bitmap = objPath.copy
        bitmap.hue_change(hue) if hue!=0
        objKey = bitmap
        @cache[key] = objKey
      else
        objKey.addRef
      end
      return objKey
    end
  end

  def self.animation(filename, hue)
    self.load_bitmap("Graphics/Animations/"+filename, hue)
  end

  def self.autotile(filename)
    self.load_bitmap("Graphics/Autotiles/"+ filename)
  end

  def self.battleback(filename)
    self.load_bitmap("Graphics/Battlebacks/"+ filename)
  end

  def self.battler(filename, hue)
    self.load_bitmap("Graphics/Battlers/"+ filename, hue)
  end

  def self.character(filename, hue)
    self.load_bitmap("Graphics/Characters/"+ filename, hue)
  end

  def self.fog(filename, hue)
    self.load_bitmap("Graphics/Fogs/"+ filename, hue)
  end

  def self.gameover(filename)
    self.load_bitmap("Graphics/Gameovers/"+ filename)
  end

  def self.icon(filename)
    self.load_bitmap("Graphics/Icons/"+ filename)
  end

  def self.panorama(filename, hue)
    self.load_bitmap("Graphics/Panoramas/"+ filename, hue)
  end

  def self.picture(filename)
    self.load_bitmap("Graphics/Pictures/"+ filename)
  end

  def self.tileset(filename)
    self.load_bitmap("Graphics/Tilesets/"+ filename)
  end

  def self.title(filename)
    self.load_bitmap("Graphics/Titles/"+ filename)
  end

  def self.windowskin(filename)
    self.load_bitmap("Graphics/Windowskins/"+ filename)
  end

  def self.tileEx(filename, tile_id, hue)
    key = [filename, tile_id, hue]
    objKey=fromCache(key)
    if !objKey
      bitmap=BitmapWrapper.new(32, 32)
      x = (tile_id - 384) % 8 * 32
      y = (tile_id - 384) / 8 * 32
      rect = Rect.new(x, y, 32, 32)
      tileset = yield(filename)
      bitmap.blt(0, 0, tileset, rect)
      tileset.dispose
      bitmap.hue_change(hue) if hue!=0
      objKey=bitmap
      @cache[key]=objKey
    else
      objKey.addRef
    end
    objKey
  end

  def self.tile(filename, tile_id, hue)
    return self.tileEx(filename, tile_id,hue) { |f| self.tileset(f) }
  end

  def self.clear
    @cache = {}
    GC.start
  end
end
