module ScreenPosHelper
  def self.pbScreenZoomX(ch)
    zoom=1.0
    if $PokemonSystem.tilemap==2
      zoom=((ch.screen_y - 16) - (Graphics.height / 2)) *
         (Draw_Tilemap::Pitch*1.0 / (Graphics.height * 25)) + 1
    end
    return zoom*Game_Map::TILE_WIDTH/32.0
  end

  def self.pbScreenZoomY(ch)
    zoom=1.0
    if $PokemonSystem.tilemap==2
      zoom=((ch.screen_y - 16) - (Graphics.height / 2)) *
         (Draw_Tilemap::Pitch*1.0 / (Graphics.height * 25)) + 1
    end
    return zoom*Game_Map::TILE_HEIGHT/32.0
  end

  def self.pbScreenX(ch)
    ret=ch.screen_x
    if $PokemonSystem.tilemap==2
      widthdiv2=(Graphics.width / 2)
      ret=widthdiv2+(ret-widthdiv2)*pbScreenZoomX(ch)
    end
    return ret
  end

  def self.pbScreenY(ch)
    ret=ch.screen_y
    if $PokemonSystem.tilemap==2 && Draw_Tilemap::Curve && Draw_Tilemap::Pitch != 0
      zoomy=pbScreenZoomY(ch)
      oneMinusZoomY=1-zoomy
      ret += (8 * oneMinusZoomY * (oneMinusZoomY /
         (2 * ((Draw_Tilemap::Pitch*1.0 / 100) / (Graphics.height*1.0 / 16.0))) + 0.5))
    end
    return ret
  end

  @heightcache={}

  def self.bmHeight(bm)
    h=@heightcache[bm]
    if !h
      bmap=AnimatedBitmap.new("Graphics/Characters/"+bm,0)
      h=bmap.height
      @heightcache[bm]=h
      bmap.dispose
    end
    return h
  end

  def self.pbScreenZ(ch,height=nil)
    if height==nil
      height=0
      if ch.tile_id > 0
        height=32
      elsif ch.character_name!=""
        height=bmHeight(ch.character_name)/4
      end
    end
    ret=ch.screen_z(height)
    if $PokemonSystem.tilemap==2
      ret-=(pbScreenZoomY(ch) < 0.5 ? 1000 : 0)
    end
    return ret
  end
end

###############################################



class Draw_Tilemap          # This class controls a set of sprites, with
  attr_reader :tileset    # different Z values, arranged into horizontal bars
  attr_reader :map_data
  attr_reader :flash_data
  attr_reader :priorities
  attr_reader :terrain_tags
  attr_reader :autotiles
  attr_accessor :bitmaps
  attr_accessor :pitch
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :visible
  attr_reader :viewport
  attr_accessor :color
  attr_accessor :tone
  StripSize    = 16
  Curve        = true
  Pitch        = 3
  FlashOpacity = [100,90,80,70,80,90]

  def initialize(viewport=nil)
    @tileset=nil
    @map_data=nil
    @priorities=nil
    @terrain_tags=nil
    @autotiles=[nil,nil,nil,nil,nil,nil,nil]
    @viewport=viewport
    @visible=true
    @helper=TileDrawingHelper.new(nil,@autotiles)
    @drawnstrips=[]
    @contentstrips=[]
    @disposed=false
    @bitmaps=[]
    @sprites=[]
    @ox=0
    @oy=0
    @tone=Tone.new(0,0,0,0)
    @color=Color.new(0,0,0,0)
    @flash_data=nil
    @numsprites=0
  end

  def tileset=(value)
    @tileset=value
    @helper.tileset=value
    @doredraw=true
  end

  def map_data=(value)
    @map_data=value
    @doredraw=true
  end

  def flash_data=(value)
    @flash_data=value
    @doredraw=true
  end

  def priorities=(value)
    @priorities=value
    @doredraw=true
  end

  def terrain_tags=(value)
    @terrain_tags=value
    @doredraw=true
  end

  def redrawmap
    # Provide blank data in proper object form
    self.clear
    xsize=@map_data.xsize
    ysize=@map_data.ysize
    # Bitmaps used for each priority's drawing. Priorities 2-5 are combined.
    @bitmaps = [Bitmap.new(xsize*32, ysize*32+StripSize),
                Bitmap.new(xsize*32, ysize*32+StripSize),
                Bitmap.new(xsize*32, ysize*32+StripSize)]
    for i in @bitmaps
      i.clear
    end
    if @flash_data
      @bitmaps.push(Bitmap.new(xsize*32, ysize*32+StripSize))
    end
    @drawnstrips.clear
    @contentstrips.clear
    # Generate blank sprites
    @sprites.clear
    @numsprites=ysize * (32 / StripSize)
    @map_data.zsize.times do   # For each layer
      @sprites.push([])
      @contentstrips.push([])
    end
    if @flash_data
      @sprites.push([])
      @contentstrips.push([])
    end
  end

  def update
    if !@flash_data.nil? && @sprites.length>0
      flashindex=@sprites.length-1
      for j in 0...@numsprites
        sprite=@sprites[flashindex][j]
        next if !sprite.is_a?(Sprite)
        sprite.opacity=FlashOpacity[(Graphics.frame_count/2) % 6]
      end
    end
    for s in @sprites
      for sprite in s
        next if !sprite.is_a?(Sprite)
 #       sprite.tone=@tone
 #       sprite.color=@color
      end
    end
    if @doredraw
      @drawnstrips=[]
      redrawmap
      @doredraw=false
    elsif @oldOx==@ox && @oldOy==@oy
      return
    end
    @oldOx=@ox
    @oldOy=@oy
    @pitch = Pitch
    minvalue=[0, ((Graphics.height / 2) -
       ((Graphics.height * 60) / @pitch) + @oy) / StripSize].max.to_i
    maxvalue=[@numsprites - 1,(@oy + Graphics.height) / StripSize].min.to_i
    return if minvalue>maxvalue
    for j in 0...@numsprites
      if j<minvalue || j>maxvalue
        for i in 0...@sprites.length
          sprite=@sprites[i][j]
          if sprite
            sprite.dispose if sprite.is_a?(Sprite)
            @sprites[i][j]=nil
          end
        end
      else
        drawStrip(j)
      end
    end
    vpy=@viewport.rect.y
    vpr=@viewport.rect.x+@viewport.rect.width
    numsprites=0
    for i in @sprites
      numsprites+=i.compact.length
    end
    for j in minvalue..maxvalue
      # For each strip within the visible screen, update OX/Y
      x=Graphics.width/2
      sox=@ox+x
      y = (j * StripSize - @oy)
      zoom_x=1.0
      zoom_y=1.0
      unless @pitch == 0 # Apply X Zoom
        zoom_x = (y - Graphics.height*1.0 / 2) * (@pitch*1.0 / (Graphics.height * 25)) + 1
        if Curve # Zoom Y values same as X, and compensate
          zoom_y = zoom_x
          yadd = StripSize*1.0 * (1 - zoom_y) * ((1 - zoom_y) /
             (2 * ((@pitch*1.0 / 100) / (Graphics.height*1.0 / (StripSize * 2)))) + 0.5)
          y+=yadd
        end
      end
      xstart=(x-sox*zoom_x)
      yend=(y+(StripSize*2)*zoom_y)
      if xstart>vpr || yend<=vpy
        for i in 0...@sprites.length
          sprite=@sprites[i][j]
          if sprite.is_a?(Sprite)
            sprite.dispose
            @sprites[i][j]=nil
          end
        end
      else
        for i in 0...@sprites.length
          sprite=@sprites[i][j]
          next if !sprite
          if sprite==true
            sprite=newSprite(i,j)
            @sprites[i][j]=sprite
          end
          sprite.visible=@visible
          sprite.x = x
          sprite.ox = sox
          sprite.y = y
          sprite.zoom_x = zoom_x
          sprite.zoom_y = zoom_y
        end
      end
    end
  end

  def clear
    for i in @bitmaps
      i.dispose
    end
    @bitmaps.clear
    for i in 0...@sprites.length
      for j in 0...@sprites[i].length
        @sprites[i][j].dispose if @sprites[i][j].is_a?(Sprite)
      end
      @sprites[i].clear
    end
    @sprites.clear
  end

  def dispose
    return if @disposed
    self.clear
    for i in 0...7
      self.autotiles[i]=nil
    end
    @helper=nil
    @sprites=nil
    @bitmaps=nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def newSprite(i,j)
    sprite=Sprite.new(@viewport)
    sprite.bitmap=@bitmaps[i]
    sprite.src_rect.set(0, j * StripSize, @map_data.xsize * 32, StripSize * 2)
    sprite.x = Graphics.width / 2
    sprite.y = -64
    sprite.z = (i * 32)
    sprite.tone=@tone
    sprite.color=@color
    if i==@bitmaps.length-1 && !@flash_data.nil?
      sprite.blend_type=1
      sprite.z=1
      sprite.opacity=FlashOpacity[(Graphics.frame_count/2) % 6]
    end
    return sprite
  end

  def drawStrip(j)
    minY=(j*StripSize)/32
    maxY=(j*StripSize+StripSize*2)/32
    minY=0 if minY<0
    minY=@map_data.ysize-1 if minY>@map_data.ysize-1
    maxY=0 if maxY<0
    maxY=@map_data.ysize-1 if maxY>@map_data.ysize-1
    for y in minY..maxY
      if !@drawnstrips[y]
        for x in 0...@map_data.xsize
          draw_position(x, y)
        end
        @drawnstrips[y]=true
      end
    end
    for i in 0...@sprites.length # For each priority
      sprite=@sprites[i][j]
      if !sprite || (sprite!=true && sprite.disposed?)
        havecontent=false
        for y in minY..maxY
          havecontent=havecontent||@contentstrips[i][y]
        end
        sprite=(havecontent) ? true : nil
        @sprites[i][j]=sprite
      end
    end
  end

  def draw_position(x, y)
    for layer in 0...@map_data.zsize
      pos = @map_data[x, y, layer]
      priopos=@priorities[pos]
      priopos=0 if !priopos
      prio=(2<priopos) ? 2 : priopos
      @contentstrips[prio][y]=true if pos>0
      @helper.bltTile(@bitmaps[prio],x*32,y*32,pos,0)
    end
    if !@flash_data.nil?
      lastlayer=@bitmaps.length-1
      id=@flash_data[x,y,0]
      r=(id>>8)&15
      g=(id>>4)&15
      b=(id)&15
      @contentstrips[lastlayer][y]=true
      color=Color.new(r*16,g*16,b*16)
      @bitmaps[lastlayer].fill_rect(x*32,y*32,32,32,color)
    end
  end
end



class Sprite_Character
  alias perspectivetilemap_initialize initialize
  attr_accessor :character

  def initialize(viewport, character = nil)
    @character = character
    perspectivetilemap_initialize(viewport,character)
  end

  alias update_or :update

  def update
    update_or
    if $PokemonSystem.tilemap==2
      self.zoom_y=ScreenPosHelper.pbScreenZoomY(@character)
      self.zoom_x=ScreenPosHelper.pbScreenZoomX(@character)
      self.x=ScreenPosHelper.pbScreenX(@character)
      self.y=ScreenPosHelper.pbScreenY(@character)
      self.z=ScreenPosHelper.pbScreenZ(@character,@ch)
    end
  end
end
