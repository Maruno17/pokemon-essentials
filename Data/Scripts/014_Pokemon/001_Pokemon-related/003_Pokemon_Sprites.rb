#===============================================================================
# Pokémon sprite (used out of battle).
#===============================================================================
class PokemonSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap&.dispose
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def clearBitmap
    @_iconbitmap&.dispose
    @_iconbitmap = nil
    self.bitmap = nil
  end

  def setOffset(offset = PictureOrigin::CENTER)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::CENTER if !@offset
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
      self.ox = 0
    when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
      self.ox = self.bitmap.width / 2
    when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
      self.ox = self.bitmap.width
    end
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
      self.oy = 0
    when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
      self.oy = self.bitmap.height / 2
    when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
      self.oy = self.bitmap.height
    end
  end

  def setPokemonBitmap(pokemon, back = false)
    @_iconbitmap&.dispose
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

  def setPokemonBitmapSpecies(pokemon, species, back = false)
    @_iconbitmap&.dispose
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    @_iconbitmap&.dispose
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
# Pokémon icon (for defined Pokémon).
#===============================================================================
class PokemonIconSprite < Sprite
  attr_accessor :selected
  attr_accessor :active
  attr_reader   :pokemon

  # Time in seconds for one animation cycle of this Pokémon icon. It is doubled
  # if the Pokémon is at 50% HP or lower, and doubled again if it is at 25% HP
  # or lower. The icon doesn't animate at all if the Pokémon is fainted.
  ANIMATION_DURATION = 0.25

  def initialize(pokemon, viewport = nil)
    super(viewport)
    @selected      = false
    @active        = false
    @frames_count  = 0
    @current_frame = 0
    self.pokemon   = pokemon
    @logical_x     = 0   # Actual x coordinate
    @logical_y     = 0   # Actual y coordinate
    @adjusted_x    = 0   # Offset due to "jumping" animation in party screen
    @adjusted_y    = 0   # Offset due to "jumping" animation in party screen
  end

  def dispose
    @animBitmap&.dispose
    super
  end

  def x; return @logical_x; end
  def y; return @logical_y; end

  def x=(value)
    @logical_x = value
    super(@logical_x + @adjusted_x)
  end

  def y=(value)
    @logical_y = value
    super(@logical_y + @adjusted_y)
  end

  def pokemon=(value)
    @pokemon = value
    @animBitmap&.dispose
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @current_frame = 0
      return
    end
    @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(value))
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @frames_count = @animBitmap.width / @animBitmap.height
    @current_frame = 0 if @current_frame >= @frames_count
    changeOrigin
  end

  def setOffset(offset = PictureOrigin::CENTER)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TOP_LEFT if !@offset
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
      self.ox = 0
    when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
      self.ox = self.src_rect.width / 2
    when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
      self.oy = 0
    when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height * 5 / 8
    when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
      self.oy = self.src_rect.height
    end
  end

  def update_frame
    if @pokemon.fainted?
      @current_frame = 0
      return
    end
    duration = ANIMATION_DURATION
    if @pokemon.hp <= @pokemon.totalhp / 4      # Red HP - 1 second
      duration *= 4
    elsif @pokemon.hp <= @pokemon.totalhp / 2   # Yellow HP - 0.5 seconds
      duration *= 2
    end
    @current_frame = (@frames_count * (System.uptime % duration) / duration).floor
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    update_frame
    self.src_rect.x = self.src_rect.width * @current_frame
    # Update "jumping" animation (used in party screen)
    if @selected
      @adjusted_x = 4
      @adjusted_y = (@current_frame >= @frames_count / 2) ? -2 : 6
    else
      @adjusted_x = 0
      @adjusted_y = 0
    end
    self.x = self.x
    self.y = self.y
  end
end

#===============================================================================
# Pokémon icon (for species).
#===============================================================================
class PokemonSpeciesIconSprite < Sprite
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :shiny

  # Time in seconds for one animation cycle of this Pokémon icon.
  ANIMATION_DURATION = 0.25

  def initialize(species, viewport = nil)
    super(viewport)
    @species       = species
    @gender        = 0
    @form          = 0
    @shiny         = 0
    @frames_count  = 0
    @current_frame = 0
    refresh
  end

  def dispose
    @animBitmap&.dispose
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

  def pbSetParams(species, gender, form, shiny = false)
    @species = species
    @gender  = gender
    @form    = form
    @shiny   = shiny
    refresh
  end

  def setOffset(offset = PictureOrigin::CENTER)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TOP_LEFT if !@offset
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::LEFT, PictureOrigin::BOTTOM_LEFT
      self.ox = 0
    when PictureOrigin::TOP, PictureOrigin::CENTER, PictureOrigin::BOTTOM
      self.ox = self.src_rect.width / 2
    when PictureOrigin::TOP_RIGHT, PictureOrigin::RIGHT, PictureOrigin::BOTTOM_RIGHT
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TOP_LEFT, PictureOrigin::TOP, PictureOrigin::TOP_RIGHT
      self.oy = 0
    when PictureOrigin::LEFT, PictureOrigin::CENTER, PictureOrigin::RIGHT
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height * 5 / 8
    when PictureOrigin::BOTTOM_LEFT, PictureOrigin::BOTTOM, PictureOrigin::BOTTOM_RIGHT
      self.oy = self.src_rect.height
    end
  end

  def refresh
    @animBitmap&.dispose
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @frames_count = @animBitmap.width / @animBitmap.height
    @current_frame = 0 if @current_frame >= @frames_count
    changeOrigin
  end

  def update_frame
    @current_frame = (@frames_count * (System.uptime % ANIMATION_DURATION) / ANIMATION_DURATION).floor
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    update_frame
    self.src_rect.x = self.src_rect.width * @current_frame
  end
end
