#===============================================================================
# Pokémon sprite (used out of battle)
#===============================================================================
class PokemonSprite < SpriteWrapper
  def initialize(viewport=nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def clearBitmap
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil
  end

  def setOffset(offset=PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::Center if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.bitmap.width/2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.bitmap.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      self.oy = self.bitmap.height/2
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.bitmap.height
    end
  end

  def setPokemonBitmap(pokemon,back=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0,0,0,0)
    changeOrigin
  end

  def setPokemonBitmapSpecies(pokemon,species,back=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
  end
end



#===============================================================================
# Pokémon icon (for defined Pokémon)
#===============================================================================
class PokemonIconSprite < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader   :pokemon

  def initialize(pokemon,viewport=nil)
    super(viewport)
    @selected     = false
    @active       = false
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    self.pokemon  = pokemon
    @logical_x    = 0   # Actual x coordinate
    @logical_y    = 0   # Actual y coordinate
    @adjusted_x   = 0   # Offset due to "jumping" animation in party screen
    @adjusted_y   = 0   # Offset due to "jumping" animation in party screen
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end

  def x; return @logical_x; end
  def y; return @logical_y; end

  def x=(value)
    @logical_x = value
    super(@logical_x+@adjusted_x)
  end

  def y=(value)
    @logical_y = value
    super(@logical_y+@adjusted_y)
  end

  def pokemon=(value)
    @pokemon = value
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @currentFrame = 0
      @counter = 0
      return
    end
    @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(value))
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames    = @animBitmap.width/@animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end

  def setOffset(offset=PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TopLeft if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.src_rect.width/2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height*5/8
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.src_rect.height
    end
  end

  # How long to show each frame of the icon for
  def counterLimit
    return 0 if @pokemon.fainted?    # Fainted - no animation
    # ret is initially the time a whole animation cycle lasts. It is divided by
    # the number of frames in that cycle at the end.
    ret = Graphics.frame_rate/4                       # Green HP - 0.25 seconds
    if @pokemon.hp<=@pokemon.totalhp/4;    ret *= 4   # Red HP - 1 second
    elsif @pokemon.hp<=@pokemon.totalhp/2; ret *= 2   # Yellow HP - 0.5 seconds
    end
    ret /= @numFrames
    ret = 1 if ret<1
    return ret
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    cl = self.counterLimit
    if cl==0
      @currentFrame = 0
    else
      @counter += 1
      if @counter>=cl
        @currentFrame = (@currentFrame+1)%@numFrames
        @counter = 0
      end
    end
    self.src_rect.x = self.src_rect.width*@currentFrame
    # Update "jumping" animation (used in party screen)
    if @selected
      @adjusted_x = 4
      @adjusted_y = (@currentFrame>=@numFrames/2) ? -2 : 6
    else
      @adjusted_x = 0
      @adjusted_y = 0
    end
    self.x = self.x
    self.y = self.y
  end
end



#===============================================================================
# Pokémon icon (for species)
#===============================================================================
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :shiny

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = 0
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    refresh
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end

  def species=(value)
    @species = value
    refresh
  end

  def gender=(value)
    @gender = value
    refresh
  end

  def form=(value)
    @form = value
    refresh
  end

  def shiny=(value)
    @shiny = value
    refresh
  end

  def pbSetParams(species,gender,form,shiny=false)
    @species = species
    @gender  = gender
    @form    = form
    @shiny   = shiny
    refresh
  end

  def setOffset(offset=PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TopLeft if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.src_rect.width/2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height*5/8
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.src_rect.height
    end
  end

  # How long to show each frame of the icon for
  def counterLimit
    # ret is initially the time a whole animation cycle lasts. It is divided by
    # the number of frames in that cycle at the end.
    ret = Graphics.frame_rate/4   # 0.25 seconds
    ret /= @numFrames
    ret = 1 if ret<1
    return ret
  end

  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    @counter += 1
    if @counter>=self.counterLimit
      @currentFrame = (@currentFrame+1)%@numFrames
      @counter = 0
    end
    self.src_rect.x = self.src_rect.width*@currentFrame
  end
end
