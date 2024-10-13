#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisualsSidePane < UI::SpriteContainer
  attr_reader :pokemon

  GRAPHICS_FOLDER = "Storage/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(88, 88, 80), Color.new(168, 184, 184)],   # Base and shadow colour
    :no_item => [Color.new(192, 200, 208), Color.new(212, 216, 220)],
    :male    => [Color.new(24, 112, 216), Color.new(136, 168, 208)],
    :female  => [Color.new(248, 56, 32), Color.new(224, 152, 144)]
  }
  MARK_WIDTH  = 16
  MARK_HEIGHT = 16

  def initialize_bitmaps
    @bitmaps[:types]    = AnimatedBitmap.new(UI_FOLDER + _INTL("types"))
    @bitmaps[:markings] = AnimatedBitmap.new(graphics_folder + "markings")
    @bitmaps[:numbers]  = AnimatedBitmap.new(graphics_folder + "numbers")
  end

  def initialize_sprites
    initialize_pane_bg
    initialize_overlay
    initialize_pokemon_sprite
  end

  def initialize_pane_bg
    add_icon_sprite(:pane_bg, 0, 0, graphics_folder + "overlay_side_pane")
    record_values(:pane_bg)
  end

  def initialize_overlay
    add_overlay(:overlay, @sprites[:pane_bg].bitmap.width, @sprites[:pane_bg].bitmap.height)
    @sprites[:overlay].z = 10
    record_values(:overlay)
  end

  def initialize_pokemon_sprite
    # TODO: The Pokémon sprite probably needs its own viewport, to avoid
    #       spillover of overly large sprites. Also put it beneath the main
    #       background sprite and put another sprite beneath it?
    @sprites[:pokemon] = UI::PokemonStorageVisualsMosaicPokemonSprite.new(@viewport)
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].x = 90
    @sprites[:pokemon].y = 164
    @sprites[:pokemon].z = 1
    record_values(:pokemon)
    mosaic_pokemon_sprite
  end

  #-----------------------------------------------------------------------------

  def width
    return @sprites[:pane_bg].width
  end

  def pokemon=(value)
    @pokemon = value
    @sprites[:pokemon].setPokemonBitmap(@pokemon) if @sprites[:pokemon] && !@sprites[:pokemon].disposed?
    refresh
  end

  def mosaic_pokemon_sprite
    @sprites[:pokemon].mosaic_duration = 0.25   # In seconds
  end

  #-----------------------------------------------------------------------------

  def refresh_overlay
    super
    return if @pokemon.nil?
    draw_name
    draw_level
    draw_shiny_icon
    draw_gender
    draw_markings
    draw_type
    draw_item
  end

  def draw_name
    pokemon_name = @pokemon.name
    pokemon_name = crop_text(pokemon_name, 158)
    draw_text(pokemon_name, 8, 14)
  end

  def draw_level
    return if @pokemon.egg?
    draw_image(graphics_folder + _INTL("overlay_lv"), 8, 48)
    draw_number_from_image(@bitmaps[:numbers], @pokemon.level, 30, 48)
  end

  def draw_shiny_icon
    return if @pokemon.egg?
    draw_image(UI_FOLDER + "shiny", 106, 46) if @pokemon.shiny?
  end

  def draw_gender
    return if @pokemon.egg?
    if @pokemon.male?
      draw_text(_INTL("♂"), 150, 44, theme: :male)
    elsif @pokemon.female?
      draw_text(_INTL("♀"), 150, 44, theme: :female)
    end
  end

  def draw_markings
    mark_variants = @bitmaps[:markings].bitmap.height / MARK_HEIGHT
    (@bitmaps[:markings].bitmap.width / MARK_WIDTH).times do |i|
      draw_image(@bitmaps[:markings], 38 + (i * MARK_WIDTH), 262,
                i * MARK_WIDTH, [(@pokemon.markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT,
                MARK_WIDTH, MARK_HEIGHT)
    end
  end

  def draw_type
    return if @pokemon.egg?
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_x = (@pokemon.types.length == 1) ? 52 : 18 + ((GameData::Type::ICON_SIZE[0] + 6) * i)
      draw_image(@bitmaps[:types], type_x, 282,
                 0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    end
  end

  def draw_item
    return if @pokemon.egg?
    if @pokemon.hasItem?
      item_name = @pokemon.item.name
      item_name = crop_text(item_name, 166)
      draw_text(item_name, 86, 316, align: :center)
    else
      draw_text(_INTL("No item"), 86, 316, align: :center, theme: :no_item)
    end
  end
end

#===============================================================================
# Pokémon sprite.
#===============================================================================
class UI::PokemonStorageVisualsMosaicPokemonSprite < PokemonSprite
  attr_reader :mosaic

  INITIAL_MOSAIC = 10   # Pixellation factor

  def initialize(*args)
    super(*args)
    @mosaic = 0
    @in_refresh = false
    @mosaic_bitmap = nil
    @mosaic_bitmap2 = nil
    @old_bitmap = self.bitmap
  end

  def dispose
    super
    @mosaic_bitmap&.dispose
    @mosaic_bitmap = nil
    @mosaic_bitmap2&.dispose
    @mosaic_bitmap2 = nil
  end

  def bitmap=(value)
    super
    refresh_mosaic(value)
  end

  def mosaic=(value)
    @mosaic = value
    @mosaic = 0 if @mosaic < 0
    @start_mosaic = @mosaic if !@start_mosaic
  end

  def mosaic_duration=(val)
    @mosaic_duration = val
    @mosaic_duration = 0 if @mosaic_duration < 0
    @mosaic_timer_start = System.uptime if @mosaic_duration > 0
  end

  def refresh_mosaic(bitmap)
    return if @in_refresh
    @in_refresh = true
    @old_bitmap = bitmap
    if @mosaic <= 0 || !@old_bitmap
      @mosaic_bitmap&.dispose
      @mosaic_bitmap = nil
      @mosaic_bitmap2&.dispose
      @mosaic_bitmap2 = nil
      self.bitmap = @old_bitmap
    else
      newWidth  = [(@old_bitmap.width / @mosaic), 1].max
      newHeight = [(@old_bitmap.height / @mosaic), 1].max
      @mosaic_bitmap2&.dispose
      @mosaic_bitmap = pbDoEnsureBitmap(@mosaic_bitmap, newWidth, newHeight)
      @mosaic_bitmap.clear
      @mosaic_bitmap2 = pbDoEnsureBitmap(@mosaic_bitmap2, @old_bitmap.width, @old_bitmap.height)
      @mosaic_bitmap2.clear
      @mosaic_bitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @old_bitmap, @old_bitmap.rect)
      @mosaic_bitmap2.stretch_blt(
        Rect.new((-@mosaic / 2) + 1, (-@mosaic / 2) + 1, @mosaic_bitmap2.width, @mosaic_bitmap2.height),
        @mosaic_bitmap, Rect.new(0, 0, newWidth, newHeight)
      )
      self.bitmap = @mosaic_bitmap2
    end
    @in_refresh = false
  end

  def update
    super
    if @mosaic_timer_start
      @start_mosaic = INITIAL_MOSAIC if !@start_mosaic || @start_mosaic == 0
      new_mosaic = lerp(@start_mosaic, 0, @mosaic_duration, @mosaic_timer_start, System.uptime).to_i
      self.mosaic = new_mosaic
      refresh_mosaic(@old_bitmap)
      if new_mosaic == 0
        @mosaic_timer_start = nil
        @start_mosaic = nil
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisualsPokemonIcon < PokemonIconSprite
  OUTLINE_COLOR = Color.new(248, 0, 0)
  FULL_BORDER  = true   # true = draws the corners

  def create_outline_bitmap
    @selected_bitmap = Bitmap.new(@animBitmap.height + 4, @animBitmap.height + 4)
    # Copy the icon's bitmap to the new bitmap
    @selected_bitmap.blt(2, 2, @animBitmap.bitmap, Rect.new(0, 0, @animBitmap.height, @animBitmap.height))
    # Determine where the outline's pixels go
    pixels = []
    size = @animBitmap.height / 2
    size.times do |j|
      size.times do |i|
        pixel = @animBitmap.bitmap.get_pixel(i * 2, j * 2)
        this_coord = ((j + 1) * (size + 2)) + i + 1
        pixels[this_coord] = 1 if pixel.alpha == 255   # Visible pixel
        next if pixels[this_coord] != 1
        pixels[this_coord - 1] ||= 2
        pixels[this_coord + 1] = 2
        pixels[this_coord - size - 2] ||= 2
        pixels[this_coord + size + 2] = 2
        if FULL_BORDER
          pixels[this_coord - size - 2 - 1] ||= 2
          pixels[this_coord - size - 2 + 1] ||= 2
          pixels[this_coord + size + 2 - 1] = 2
          pixels[this_coord + size + 2 + 1] = 2
        end
      end
    end
    # Draw the outline
    (size + 2).times do |j|
      (size + 2).times do |i|
        if pixels[(j * (size + 2)) + i] == 3
          @selected_bitmap.fill_rect(i * 2, j * 2, 2, 2, Color.new(255,255,0))
        end
        next if pixels[(j * (size + 2)) + i] != 2
        @selected_bitmap.fill_rect(i * 2, j * 2, 2, 2, OUTLINE_COLOR)
      end
    end
  end

  def pokemon=(value)
    super
    # NOTE: This only matters when refreshing the screen after giving an item to
    #       a Pokémon (a selected Pokémon). It should remain selected.
    if @selected_bitmap
      self.bitmap = @selected_bitmap
      self.src_rect.width  = @selected_bitmap.width
      self.src_rect.height = @selected_bitmap.height
      changeOrigin
    end
  end

  def make_selected
    return if @selected_bitmap
    create_outline_bitmap
    self.bitmap = @selected_bitmap
    self.src_rect.width  = @selected_bitmap.width
    self.src_rect.height = @selected_bitmap.height
    changeOrigin
    self.z += 1
  end

  def make_not_selected
    return if !@selected_bitmap
    @selected_bitmap.dispose
    @selected_bitmap = nil
    if @animBitmap
      self.bitmap = @animBitmap.bitmap
      self.src_rect.width  = @animBitmap.height
      self.src_rect.height = @animBitmap.height
      changeOrigin
    end
    self.z -= 1
  end

  def update; end   # Don't animate it
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisualsBox < UI::SpriteContainer
  attr_reader :sprites

  GRAPHICS_FOLDER = "Storage/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(248, 248, 240), Color.new(40, 48, 48)],   # Base and shadow colour
  }

  def initialize(storage, box_number, viewport)
    @storage = storage
    @box_number = box_number
    super(viewport)
  end

  def initialize_sprites
    initialize_box_background
    initialize_overlay
    initialize_pokemon_icons
  end

  def initialize_box_background
    set_box_background
    record_values(:background)
  end

  def initialize_overlay
    add_overlay(:overlay, @sprites[:background].bitmap.width, @sprites[:background].bitmap.height)
    @sprites[:overlay].z = 10
    record_values(:overlay)
  end

  def initialize_pokemon_icons
    PokemonBox::BOX_SIZE.times do |i|
      @sprites["pokemon_#{i}"] = UI::PokemonStorageVisualsPokemonIcon.new(@storage[@box_number, i], @viewport)
      @sprites["pokemon_#{i}"].x, @sprites["pokemon_#{i}"].y = pokemon_coords(i)
      @sprites["pokemon_#{i}"].z = 1
      @sprites["pokemon_#{i}"].setOffset
      record_values("pokemon_#{i}")
    end
  end

  #-----------------------------------------------------------------------------

  def width
    return @sprites[:background].width
  end

  def pokemon_coords(index)
    return 42 + (48 * (index % PokemonBox::BOX_WIDTH)),
           70 + (48 * (index / PokemonBox::BOX_WIDTH))
  end

  def pokemon_icon(index)
    return @sprites["pokemon_#{index}"]
  end

  def reset_pokemon_icon_position(index)
    new_coords = pokemon_coords(index)
    @sprites["pokemon_#{index}"].x = self.x + new_coords[0]
    @sprites["pokemon_#{index}"].y = self.y + new_coords[1]
  end

  def set_box_background(wallpaper_number = -1)
    @sprites[:background]&.dispose
    add_icon_sprite(:background, self.x, self.y, graphics_folder + box_bitmap(wallpaper_number))
  end

  def box_bitmap(wallpaper_number = -1)
    return "box_#{wallpaper_number}" if wallpaper_number >= 0
    ret = @storage[@box_number].background
    if !ret.is_a?(Integer) || !@storage.isAvailableWallpaper?(ret)
      ret = @box_number % PokemonStorage::BASIC_WALLPAPER_COUNT
      @storage[@box_number].background = ret
    end
    return "box_#{ret}"
  end

  def set_visible_proc(this_proc)
    @visible_proc = this_proc
    apply_visible_proc
  end

  def apply_visible_proc
    PokemonBox::BOX_SIZE.times do |i|
      if @visible_proc && !@visible_proc.call(@sprites["pokemon_#{i}"].pokemon)
        @sprites["pokemon_#{i}"].opacity = 96
      else
        @sprites["pokemon_#{i}"].opacity = 255
      end
    end
  end

  def fade_all_pokemon
    PokemonBox::BOX_SIZE.times { |i| @sprites["pokemon_#{i}"].opacity = 96 }
  end

  def unfade_all_pokemon
    apply_visible_proc
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    set_box_background
    draw_box_name
    refresh_existing_pokemon
  end

  def refresh_box_name
    draw_box_name
  end

  def draw_box_name
    box_name = @storage[@box_number].name
    box_name = crop_text(box_name, 216)
    draw_text(box_name, 162, 14, align: :center)
  end

  def refresh_existing_pokemon
    PokemonBox::BOX_SIZE.times do |i|
      @sprites["pokemon_#{i}"].pokemon = @storage[@box_number, i]
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisualsPartyPanel < UI::SpriteContainer
  attr_reader :sprites

  GRAPHICS_FOLDER = "Storage/"
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(248, 248, 240), Color.new(40, 48, 48)],   # Base and shadow colour
  }

  def initialize(party, mode, viewport)
    @party = party
    @mode = mode
    super(viewport)
    refresh
  end

  def initialize_sprites
    initialize_panel_background
    initialize_overlay
    initialize_pokemon_icons
  end

  def initialize_panel_background
    add_icon_sprite(:background, 0, 0, graphics_folder + "overlay_party")
    record_values(:background)
  end

  def initialize_overlay
    add_overlay(:overlay, @sprites[:background].bitmap.width, @sprites[:background].bitmap.height)
    @sprites[:overlay].z = 10
    record_values(:overlay)
  end

  def initialize_pokemon_icons
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon_#{i}"] = UI::PokemonStorageVisualsPokemonIcon.new(@party[i], @viewport)
      @sprites["pokemon_#{i}"].x, @sprites["pokemon_#{i}"].y = pokemon_coords(i)
      @sprites["pokemon_#{i}"].z = 1
      @sprites["pokemon_#{i}"].setOffset
      record_values("pokemon_#{i}")
    end
  end

  #-----------------------------------------------------------------------------

  def height
    return @sprites[:background].bitmap.height
  end

  def pokemon_coords(index)
    return 50 + (72 * (index % 2)),
           42 + (16 * (index % 2)) + (64 * (index / 2))
  end

  def pokemon_icon(index)
    return @sprites["pokemon_#{index}"]
  end

  def reset_pokemon_icon_position(index)
    new_coords = pokemon_coords(index)
    @sprites["pokemon_#{index}"].x = self.x + new_coords[0]
    @sprites["pokemon_#{index}"].y = self.y + new_coords[1]
  end

  def set_visible_proc(this_proc)
    @visible_proc = this_proc
    apply_visible_proc
  end

  def apply_visible_proc
    Settings::MAX_PARTY_SIZE.times do |i|
      if @visible_proc && !@visible_proc.call(@sprites["pokemon_#{i}"].pokemon)
        @sprites["pokemon_#{i}"].opacity = 96
      else
        @sprites["pokemon_#{i}"].opacity = 255
      end
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    draw_button_text
    refresh_existing_pokemon
  end

  def draw_button_text
    text = (@mode == :deposit) ? _INTL("Exit") : _INTL("Back")
    draw_text(text, 86, 248, align: :center, outline: :outline)
  end

  def refresh_existing_pokemon
    Settings::MAX_PARTY_SIZE.times do |i|
      @sprites["pokemon_#{i}"].pokemon = @party[i]
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisualsCursor < UI::SpriteContainer
  attr_reader :quick_swap_mode

  GRAPHICS_FOLDER = "Storage/"
  BITMAPS = {
    :point1  => ["cursor_point_1"],
    :point2  => ["cursor_point_2"],
    :grab    => ["cursor_grab"],
    :fist    => ["cursor_fist"],
    :point1q => ["cursor_point_1_q"],
    :point2q => ["cursor_point_2_q"],
    :grabq   => ["cursor_grab_q"],
    :fistq   => ["cursor_fist_q"]
  }
  # Time in seconds for the cursor to move down or back up to grab/drop a
  # Pokémon.
  GRAB_TIME = 0.2

  def initialize_sprites
    initialize_cursor
    initialize_pokemon_icon
    initialize_item_icon
  end

  def initialize_cursor
    @sprites[:cursor] = ChangelingSprite.new(0, 0, @viewport)
    BITMAPS.each_pair do |key, data|
      @sprites[:cursor].add_bitmap(key, graphics_folder + data[0])
    end
    @sprites[:cursor].change_bitmap(:fist)
    record_values(:cursor)
  end

  def initialize_pokemon_icon
    @sprites[:pokemon] = UI::PokemonStorageVisualsPokemonIcon.new(nil, @viewport)
    @sprites[:pokemon].x = 32
    @sprites[:pokemon].y = 48
    @sprites[:pokemon].z = -1
    @sprites[:pokemon].setOffset
    record_values(:pokemon)
  end

  def initialize_item_icon
    @sprites[:item] = ItemIconSprite.new(32, 48, nil, @viewport)
    @sprites[:item].z = -1
    @sprites[:item].setOffset
    @sprites[:item].blankzero = true
    record_values(:item)
  end

  #-----------------------------------------------------------------------------

  def held_pokemon
    return @sprites[:pokemon].pokemon
  end

  def held_pokemon=(value)
    @sprites[:pokemon].pokemon = value
  end

  def holding_pokemon?
    return !held_pokemon.nil?
  end

  def held_item
    return @sprites[:item].item
  end

  def held_item=(value)
    @sprites[:item].item = value
  end

  def holding_item?
    return !held_item.nil?
  end

  def pokemon_icon
    return @sprites[:pokemon]
  end

  def quick_swap_mode=(value)
    return if @quick_swap_mode == value
    @quick_swap_mode = value
    refresh_cursor
  end

  #-----------------------------------------------------------------------------

  def animating?
    return @pick_up_timer_1_start || @pick_up_timer_2_start ||
           @put_down_timer_1_start || @put_down_timer_2_start
  end

  def pick_up_animation_1
    @pick_up_timer_1_start = System.uptime
    @start_y = self.y
    @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :grabq : :grab)
  end

  def pick_up_animation_2
    @pick_up_timer_2_start = System.uptime
    @start_y = self.y
    @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :fistq : :fist)
  end

  def put_down_animation_1
    @put_down_timer_1_start = System.uptime
    @start_y = self.y
    @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :fistq : :fist)
  end

  def put_down_animation_2
    @put_down_timer_2_start = System.uptime
    @start_y = self.y
    @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :grabq : :grab)
  end

  #-----------------------------------------------------------------------------

  def refresh_cursor
    if (System.uptime / 0.5).to_i.even?   # Changes every 0.5 seconds
      @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :point1q : :point1)
    else
      @sprites[:cursor].change_bitmap((@quick_swap_mode) ? :point2q : :point2)
    end
  end

  def update
    super
    if @pick_up_timer_1_start
      y_offset = lerp(0, 16, GRAB_TIME, @pick_up_timer_1_start, System.uptime)
      self.y = @start_y + y_offset
      @pick_up_timer_1_start = nil if y_offset == 16
    elsif @pick_up_timer_2_start
      y_offset = lerp(0, -16, GRAB_TIME, @pick_up_timer_2_start, System.uptime)
      self.y = @start_y + y_offset
      @pick_up_timer_2_start = nil if y_offset == -16
    elsif @put_down_timer_1_start
      y_offset = lerp(0, 16, GRAB_TIME, @put_down_timer_1_start, System.uptime)
      self.y = @start_y + y_offset
      @put_down_timer_1_start = nil if y_offset == 16
    elsif @put_down_timer_2_start
      y_offset = lerp(0, -16, GRAB_TIME, @put_down_timer_2_start, System.uptime)
      self.y = @start_y + y_offset
      @put_down_timer_2_start = nil if y_offset == -16
    elsif !holding_pokemon? && !holding_item?   # Idling animation
      refresh_cursor
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorageVisuals < UI::BaseVisuals
  # -3 = Exit button
  # -2 = Party button, or Back button in party panel
  # -1 = Box name
  # 0+ = index in box/party
  attr_reader :index
  # -1 = party
  # 0+ = box number
  attr_reader :box
  attr_reader :sub_mode
  attr_reader :sprites

  GRAPHICS_FOLDER   = "Storage/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default => [Color.new(248, 248, 240), Color.new(40, 48, 48)],   # Base and shadow colour
  }
  MARKING_WIDTH  = 16
  MARKING_HEIGHT = 16

  def initialize(storage, mode = :normal)
    @storage = storage
    @mode    = mode
    @index   = 0
    @box     = (@mode == :deposit) ? -1 : @storage.currentBox
    super()
    set_index(@index)
  end

  def initialize_bitmaps
    @bitmaps[:markings] = AnimatedBitmap.new(graphics_folder + "markings")
  end

  def initialize_message_box
    super
    @sprites[:speech_box].width = Graphics.width - 180
  end

  def initialize_sprites
    initialize_side_pane
    initialize_box
    initialize_party_panel
    initialize_marking_sprites
    initialize_cursor
    initialize_buttons
  end

  def initialize_side_pane
    @sprites[:side_pane] = UI::PokemonStorageVisualsSidePane.new(@viewport)
    @sprites[:side_pane].y = 16
    @sprites[:side_pane].z = 100
  end

  def initialize_box
    @sprites[:box] = create_box_sprite(@storage.currentBox)
  end

  def create_box_sprite(box_index)
    ret = UI::PokemonStorageVisualsBox.new(@storage, box_index, @viewport)
    ret.x = 184
    ret.y = 18
    ret.refresh
    return ret
  end

  def initialize_party_panel
    @sprites[:party_panel] = UI::PokemonStorageVisualsPartyPanel.new(@storage.party, @mode, @viewport)
    @sprites[:party_panel].x = 184
    @sprites[:party_panel].y = (showing_party_panel?) ? Graphics.height - 352 : Graphics.height
    @sprites[:party_panel].z = 1100
  end

  def initialize_marking_sprites
    # Background image of marking panel
    add_icon_sprite(:marking_bg, 290, 68, graphics_folder + "overlay_marking")
    @sprites[:marking_bg].z       = 1900
    @sprites[:marking_bg].visible = false
    # Overlay for marking panel
    add_overlay(:marking_overlay)
    @sprites[:marking_overlay].z       = 1901
    @sprites[:marking_overlay].visible = false
    # Cursor to highlight the currently selected marking option
    add_icon_sprite(:marking_cursor, 0, 0, graphics_folder + "cursor_marking")
    @sprites[:marking_cursor].z       = 1902
    @sprites[:marking_cursor].visible = false
    @sprites[:marking_cursor].src_rect.height = @sprites[:marking_cursor].bitmap.height / 2
  end

  def initialize_cursor
    @sprites[:cursor] = UI::PokemonStorageVisualsCursor.new(@viewport)
    @sprites[:cursor].z = 1500
  end

  def initialize_buttons
    @sprites[:party_button] = IconSprite.new(188, 320, @viewport)
    @sprites[:party_button].setBitmap(graphics_folder + "overlay_buttons")
    @sprites[:party_button].src_rect.height = @sprites[:party_button].height / 2
    @sprites[:party_button].visible = ([:organize, :choose_pokemon].include?(@mode))
    @sprites[:exit_button] = IconSprite.new(386, 320, @viewport)
    @sprites[:exit_button].setBitmap(graphics_folder + "overlay_buttons")
    @sprites[:exit_button].src_rect.y = @sprites[:exit_button].height / 2
    @sprites[:exit_button].src_rect.height = @sprites[:exit_button].height / 2
    @sprites[:exit_button].visible = (@mode != :deposit)
  end

  #-----------------------------------------------------------------------------

  def can_access_screen_menu?
    return @mode == :organize
  end

  def pokemon
    return @sprites[:cursor].held_pokemon if holding_pokemon?
    return slot_pokemon
  end

  # Returns the Pokémon in the storage space the cursor is over.
  def slot_pokemon
    return nil if @index < 0
    return @storage.party[@index] if @box < 0
    return @storage[@box][@index]
  end

  def holding_pokemon?
    return @sprites[:cursor].holding_pokemon?
  end

  def pokemon_icon
    return @sprites[:cursor].pokemon_icon if holding_pokemon?
    return @sprites[:box].pokemon_icon(@index) if @box >= 0
    return @sprites[:party_panel].pokemon_icon(@index)
  end

  def item
    return @sprites[:cursor].held_item
  end

  def holding_item?
    return @sprites[:cursor].holding_item?
  end

  def showing_party_panel?
    return @box == -1
  end

  def set_index(new_index)
    mosaic_pokemon_sprite
    @index = new_index
    refresh_on_index_changed(@index)
  end

  def set_sub_mode(sub_mode = :normal)
    @sub_mode = sub_mode
    @sprites[:cursor].quick_swap_mode = (@sub_mode != :normal)
    @visible_proc = nil
    if @sub_mode == :rearrange_items
      @visible_proc = proc { |pkmn| pkmn.hasItem? }
    end
    @sprites[:box].set_visible_proc(@visible_proc)
    @sprites[:party_panel].set_visible_proc(@visible_proc)
  end

  def select_pokemon
    pokemon_icon&.make_selected if !holding_pokemon?
  end

  def deselect_pokemon
    pokemon_icon&.make_not_selected if !holding_pokemon?
  end

  #-----------------------------------------------------------------------------

  def go_to_next_box(new_box_number = -1)
    @sprites[:side_pane].pokemon = nil if !holding_pokemon?
    new_box_number = (@storage.currentBox + 1) % @storage.maxBoxes if new_box_number < 0
    @sprites[:cursor].visible = false
    # Animate the boxes moving
    offset_x = @sprites[:box].width + 12
    start_x = @sprites[:box].x
    new_box = create_box_sprite(new_box_number)
    new_box.x = start_x + offset_x
    timer_start = System.uptime
    loop do
      @sprites[:box].x = lerp(start_x, start_x - offset_x, 0.25, timer_start, System.uptime)
      new_box.x = @sprites[:box].x + offset_x
      update
      Graphics.update
      break if new_box.x == start_x
    end
    @sprites[:box].dispose
    @sprites[:box] = new_box
    Input.update
    # Tidy up
    @sprites[:cursor].visible = true
    @storage.currentBox = new_box_number
    @box = new_box_number
    refresh_side_pane
    mosaic_pokemon_sprite
  end

  def go_to_previous_box(new_box_number = -1)
    @sprites[:side_pane].pokemon = nil if !holding_pokemon?
    new_box_number = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes if new_box_number < 0
    @sprites[:cursor].visible = false
    # Animate the boxes moving
    offset_x = @sprites[:box].width + 12
    start_x = @sprites[:box].x
    new_box = create_box_sprite(new_box_number)
    new_box.x = start_x - offset_x
    timer_start = System.uptime
    loop do
      @sprites[:box].x = lerp(start_x, start_x + offset_x, 0.25, timer_start, System.uptime)
      new_box.x = @sprites[:box].x - offset_x
      update
      Graphics.update
      break if new_box.x == start_x
    end
    @sprites[:box].dispose
    @sprites[:box] = new_box
    Input.update
    # Tidy up
    @sprites[:cursor].visible = true
    @storage.currentBox = new_box_number
    @box = new_box_number
    refresh_side_pane
    mosaic_pokemon_sprite
  end

  def show_party_panel
    pbSEPlay("GUI storage show party panel")
    @sprites[:cursor].visible = false
    @sprites[:side_pane].pokemon = nil if !holding_pokemon?
    start_y = @sprites[:party_panel].y   # Graphics.height
    timer_start = System.uptime
    loop do
      @sprites[:party_panel].y = lerp(start_y, start_y - @sprites[:party_panel].height,
                                      0.4, timer_start, System.uptime)
      update
      Graphics.update
      break if @sprites[:party_panel].y == start_y - @sprites[:party_panel].height
    end
    Input.update
    @box = -1
    set_index(0)
    mosaic_pokemon_sprite
    @sprites[:cursor].visible = true
  end

  def hide_party_panel
    pbSEPlay("GUI storage hide party panel")
    @sprites[:cursor].visible = false
    @sprites[:side_pane].pokemon = nil if !holding_pokemon?
    start_y = @sprites[:party_panel].y   # Graphics.height - @sprites[:party_panel].height
    timer_start = System.uptime
    loop do
      @sprites[:party_panel].y = lerp(start_y, start_y + @sprites[:party_panel].height,
                                    0.4, timer_start, System.uptime)
      self.update
      Graphics.update
      break if @sprites[:party_panel].y == start_y + @sprites[:party_panel].height
    end
    Input.update
    @box = @storage.currentBox
    set_index(-2)   # Party button
    mosaic_pokemon_sprite
    @sprites[:cursor].visible = true
  end

  #-----------------------------------------------------------------------------

  def animate_cursor(anim_method)
    @sprites[:cursor].send(anim_method)
    loop do
      Graphics.update
      update_visuals
      break if !@sprites[:cursor].animating?
    end
  end

  def pick_up_pokemon
    pbSEPlay("GUI storage pick up")
    deselect_pokemon
    # Animate cursor moving down to grab the Pokémon
    animate_cursor(:pick_up_animation_1)
    # Move Pokémon to cursor
    sprite_key = (@box >= 0) ? :box : :party_panel
    spr = @sprites[sprite_key].pokemon_icon(@index)
    @sprites[:cursor].held_pokemon = spr.pokemon
    spr.pokemon = nil
    @sprites[sprite_key].reset_pokemon_icon_position(@index)
    # Animate cursor moving back up holding the picked-up Pokémon
    animate_cursor(:pick_up_animation_2)
    Input.update
  end

  def swap_pokemon
    pbSEPlay("GUI storage pick up")
    # Move Pokémon between cursor and slot
    held_pkmn = pokemon
    slot_pkmn = slot_pokemon
    sprite_key = (@box >= 0) ? :box : :party_panel
    spr = @sprites[sprite_key].pokemon_icon(@index)
    @sprites[:cursor].held_pokemon = slot_pkmn
    spr.pokemon = held_pkmn
    @sprites[sprite_key].reset_pokemon_icon_position(@index)
    mosaic_pokemon_sprite(true)
  end

  def put_down_pokemon
    pbSEPlay("GUI storage put down")
    # Animate cursor moving down to put down the held Pokémon
    animate_cursor(:put_down_animation_1)
    # Move Pokémon to slot
    sprite_key = (@box >= 0) ? :box : :party_panel
    spr = @sprites[sprite_key].pokemon_icon(@index)
    spr.pokemon = @sprites[:cursor].held_pokemon
    @sprites[:cursor].held_pokemon = nil
    # Animate cursor moving back up after putting down the held Pokémon
    animate_cursor(:put_down_animation_2)
    Input.update
  end

  # Called when interacting with a Pokémon in the box. Automatically puts that
  # Pokemon into the party.
  def withdraw_pokemon
    old_index = @index
    pick_up_pokemon if !holding_pokemon?
    show_party_panel
    set_index(@storage.party.length)
    put_down_pokemon
    hide_party_panel
    set_index(old_index)
  end

  # Called when interacting with a Pokémon in the party. Automatically puts that
  # Pokemon into the box.
  def store_pokemon(new_box, new_index)
    pick_up_pokemon if !holding_pokemon?
    hide_party_panel
    old_index = @index
    if new_box != @box
      pbPlayCursorSE
      (new_box > @box) ? go_to_next_box(new_box) : go_to_previous_box(new_box)
    end
    set_index(new_index)
    put_down_pokemon
    yield if block_given?
    refresh_party_panel
    show_party_panel
  end

  def release_pokemon(skip_anim = false)
    deselect_pokemon
    sprite = pokemon_icon
    if !skip_anim
      timer_start = System.uptime
      loop do
        Graphics.update
        update_visuals
        sprite.zoom_x = lerp(1.0, 0.0, 1.5, timer_start, System.uptime)
        sprite.zoom_y = sprite.zoom_x
        sprite.opacity = lerp(255, 0, 1.5, timer_start, System.uptime)
        break if sprite.opacity == 0
      end
      Input.update
      sprite.zoom_x = 1.0
      sprite.zoom_y = 1.0
      sprite.opacity = 255
    end
    sprite.pokemon = nil
  end

  def mosaic_pokemon_sprite(forced = false)
    return if !forced && holding_pokemon?
    @sprites[:side_pane].mosaic_pokemon_sprite if pokemon
  end

  #-----------------------------------------------------------------------------

  def pick_up_item
    pbSEPlay("GUI storage pick up")
    # Animate cursor moving down to grab the item
    animate_cursor(:pick_up_animation_1)
    # Move item to cursor
    @sprites[:cursor].held_item = pokemon.item
    pokemon.item = nil
    refresh_side_pane
    @sprites[:box].set_visible_proc(@visible_proc)
    @sprites[:party_panel].set_visible_proc(@visible_proc)
    # Animate cursor moving back up holding the picked-up item
    animate_cursor(:pick_up_animation_2)
    Input.update
  end

  def swap_items
    pbSEPlay("GUI storage pick up")
    # Move item from slot Pokémon to cursor
    @sprites[:cursor].held_item = pokemon.item
  end

  def put_down_item
    pbSEPlay("GUI storage put down")
    # Animate cursor moving down to put down the held item
    animate_cursor(:put_down_animation_1)
    # Move item to slot Pokémon
    pokemon.item = @sprites[:cursor].held_item
    @sprites[:cursor].held_item = nil
    refresh_side_pane
    @sprites[:box].set_visible_proc(@visible_proc)
    @sprites[:party_panel].set_visible_proc(@visible_proc)
    # Animate cursor moving back up after putting down the held item
    animate_cursor(:put_down_animation_2)
    Input.update
  end

  #-----------------------------------------------------------------------------

  def choose_box(message, start_box = -1)
    start_box = @storage.currentBox if start_box < 0
    commands = {}
    @storage.maxBoxes.times do |i|
      box = @storage[i]
      commands[i] = _INTL("{1} ({2}/{3})", box.name, box.nitems, box.length) if box
    end
    return show_menu(message, commands, commands.keys.index(start_box) || 0)
  end

  #-----------------------------------------------------------------------------

  def position_speech_box(text)
    @sprites[:speech_box].resizeHeightToFit(text, Graphics.width - @sprites[:side_pane].width)
    pbBottomRight(@sprites[:speech_box])
  end

  # Replaces the version in class UI::BaseVisuals because the speech box needs
  # to be positioned differently.
  def show_choice_message(text, options, index = 0, align: :vertical, cmd_side: :right)
    ret = -1
    commands = options
    commands = options.values if options.is_a?(Hash)
    @sprites[:speech_box].visible = true
    @sprites[:speech_box].text    = text
    using(cmd_window = Window_AdvancedCommandPokemon.new(commands)) do
      position_speech_box(text)
      cmd_window.viewport = @viewport
      cmd_window.z        = @sprites[:speech_box].z + 1
      pbBottomRight(cmd_window)
      cmd_window.height   = [cmd_window.height, Graphics.height - @sprites[:speech_box].height].min
      cmd_window.y        = Graphics.height - @sprites[:speech_box].height - cmd_window.height
      cmd_window.visible  = !@sprites[:speech_box].busy?
      cmd_window.index    = index
      loop do
        Graphics.update
        Input.update
        update_visuals
        cmd_window.visible = true if !@sprites[:speech_box].busy?
        cmd_window.update
        if !@sprites[:speech_box].busy?
          if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            ret = -1
            break
          elsif Input.trigger?(Input::USE) && @sprites[:speech_box].resume
            pbPlayDecisionSE
            ret = cmd_window.index
            break
          end
        end
      end
    end
    @sprites[:speech_box].visible = false
    if options.is_a?(Hash)
      ret = (ret < 0) ? nil : options.keys[ret]
    end
    return ret
  end

  def choose_box_wallpaper(text, options, index = 0)
    original_index = index
    ret = -1
    commands = options
    commands = options.values if options.is_a?(Hash)
    old_letter_by_letter = @sprites[:speech_box].letterbyletter
    @sprites[:speech_box].letterbyletter = false
    @sprites[:speech_box].visible = true
    @sprites[:speech_box].text    = text
    @sprites[:box].fade_all_pokemon
    using(cmd_window = Window_AdvancedCommandPokemon.new(commands)) do
      position_speech_box(text)
      cmd_window.viewport = @viewport
      cmd_window.z        = @sprites[:speech_box].z + 1
      pbBottomLeft(cmd_window)
      cmd_window.width    = @sprites[:side_pane].width
      cmd_window.height   = [cmd_window.height, Graphics.height].min
      cmd_window.y        = Graphics.height - cmd_window.height
      cmd_window.visible  = !@sprites[:speech_box].busy?
      cmd_window.index    = index
      loop do
        Graphics.update
        Input.update
        update_visuals
        cmd_window.visible = true if !@sprites[:speech_box].busy?
        old_index = cmd_window.index
        cmd_window.update
        if cmd_window.index != old_index
          paper_num = (options.is_a?(Hash)) ? options.keys[cmd_window.index] : cmd_window.index
          @sprites[:box].set_box_background(paper_num)
        end
        if !@sprites[:speech_box].busy?
          if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            ret = -1
            break
          elsif Input.trigger?(Input::USE) && @sprites[:speech_box].resume
            pbPlayDecisionSE
            ret = cmd_window.index
            break
          end
        end
      end
    end
    if options.is_a?(Hash)
      ret = (ret < 0) ? nil : options.keys[ret]
    end
    @sprites[:speech_box].letterbyletter = old_letter_by_letter
    @sprites[:speech_box].visible = false
    @sprites[:box].unfade_all_pokemon
    @sprites[:box].set_box_background(options.keys[original_index]) if ret.nil?
    return ret
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_box
    refresh_side_pane
    refresh_party_panel
    refresh_buttons
    refresh_cursor_position
  end

  def refresh_box
    @sprites[:box].refresh
  end

  def refresh_side_pane
    return if holding_pokemon?   # Selected Pokémon is always the held one
    refresh_selected_pokemon
  end

  def refresh_party_panel
    @sprites[:party_panel].refresh
  end

  def refresh_selected_pokemon
    @sprites[:side_pane].pokemon = pokemon
  end

  def refresh_buttons
    if [:organize, :choose_pokemon].include?(@mode)
      draw_text(_INTL("Party: {1}", @storage.party.length), 270, 334, align: :center, outline: :outline)
    end
    if @mode != :deposit
      draw_text(_INTL("Exit"), 446, 334, align: :center, outline: :outline)
    end
  end

  def refresh_cursor_position
    if showing_party_panel?
      if @index < 0   # Back button
        @sprites[:cursor].x = 236
        @sprites[:cursor].y = 220
      else
        coords = @sprites[:party_panel].pokemon_coords(@index)
        @sprites[:cursor].x = @sprites[:party_panel].x + coords[0] - 32
        @sprites[:cursor].y = @sprites[:party_panel].y + coords[1] - 64
      end
      return
    end
    case @index
    when -1   # Box name
      @sprites[:cursor].x = 314
      @sprites[:cursor].y = -24
    when -2   # Party Pokémon button
      @sprites[:cursor].x = 238
      @sprites[:cursor].y = 278
    when -3   # Close Box button
      @sprites[:cursor].x = 414
      @sprites[:cursor].y = 278
    else      # Box space
      coords = @sprites[:box].pokemon_coords(@index)
      @sprites[:cursor].x = @sprites[:box].x + coords[0] - 32
      @sprites[:cursor].y = @sprites[:box].y + coords[1] - 64
    end
  end

  def refresh_on_index_changed(old_index)
    refresh_cursor_position
    refresh_side_pane
  end

  def refresh_markings_cursor
    case @marking_index
    when 6   # OK
      @sprites[:marking_cursor].x = 318
      @sprites[:marking_cursor].y = 196
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    when 7   # Cancel
      @sprites[:marking_cursor].x = 318
      @sprites[:marking_cursor].y = 260
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    else
      @sprites[:marking_cursor].x = 318 + (58 * (@marking_index % 3))
      @sprites[:marking_cursor].y = 96 + (50 * (@marking_index / 3))
      @sprites[:marking_cursor].src_rect.y = 0
    end
  end

  def refresh_markings_panel
    # Set values to use when drawing the markings panel
    marking_x = 334
    marking_y = 106
    marking_spacing_x = 42 + MARKING_WIDTH
    marking_spacing_y = 34 + MARKING_HEIGHT
    markings_per_row = 3
    mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
    # Clear the bitmap
    @sprites[:marking_overlay].bitmap.clear
    # Draw marking icons
    (@bitmaps[:markings].bitmap.width / MARKING_WIDTH).times do |i|
      src_x = i * MARKING_WIDTH
      src_y = [(@markings[i] || 0), mark_variants - 1].min * MARKING_HEIGHT
      draw_image(@bitmaps[:markings],
                 marking_x + (marking_spacing_x * (i % markings_per_row)),
                 marking_y + (marking_spacing_y * (i / markings_per_row)),
                 src_x, src_y, MARKING_WIDTH, MARKING_HEIGHT,
                 overlay: :marking_overlay)
    end
    # Draw text
    draw_text(_INTL("OK"), 400, 216, align: :center, outline: :outline, overlay: :marking_overlay)
    draw_text(_INTL("Cancel"), 400, 280, align: :center, outline: :outline, overlay: :marking_overlay)
  end

  #-----------------------------------------------------------------------------

  def update_input
    deselect_pokemon
    # Check for movement to a new Pokémon/button
    old_index = @index
    update_cursor_movement
    if @index != old_index
      pbPlayCursorSE
      set_index(@index)
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    elsif Input.trigger?(Input::ACTION)
      return update_interaction(Input::ACTION)
    elsif Input.trigger?(Input::JUMPUP)
      return update_interaction(Input::JUMPUP)
    elsif Input.trigger?(Input::JUMPDOWN)
      return update_interaction(Input::JUMPDOWN)
    end
    return nil
  end

  def update_cursor_movement
    if showing_party_panel?
      update_cursor_movement_party
      return
    end
    if Input.repeat?(Input::UP)
      case @index
      when -1   # Box name
        @index = (@mode == :withdraw) ? -3 : -2   # Exit button : Party button
      when -2   # Party button
        @index = PokemonBox::BOX_SIZE - 1 - (PokemonBox::BOX_WIDTH * 2 / 3)   # 25
      when -3   # Exit button
        @index = PokemonBox::BOX_SIZE - (PokemonBox::BOX_WIDTH / 3)   # 28
      else
        @index -= PokemonBox::BOX_WIDTH
        @index = -1 if @index < 0   # Box name
      end
    elsif Input.repeat?(Input::DOWN)
      case @index
      when -1   # Box name
        @index = PokemonBox::BOX_WIDTH / 3   # 2
      when -2, -3     # Party button, Exit button
        @index = -1   # Box name
      else
        @index += PokemonBox::BOX_WIDTH
        if @index >= PokemonBox::BOX_SIZE
          if @index < PokemonBox::BOX_SIZE + (PokemonBox::BOX_WIDTH / 2) && @mode != :withdraw
            @index = -2   # Party button
          else
            @index = -3   # Exit button
          end
        end
      end
    end
    if Input.repeat?(Input::LEFT)
      if @index == -1   # Box name
        pbPlayCursorSE
        go_to_previous_box
      elsif @index == -2                    # Party button
        @index = -3                         # Exit button
      elsif @index == -3                    # Exit button
        @index = -2 if @mode != :withdraw   # Party button
      elsif (@index % PokemonBox::BOX_WIDTH) == 0   # Wrap around
        @index += PokemonBox::BOX_WIDTH - 1
      else
        @index -= 1
      end
    elsif Input.repeat?(Input::RIGHT)
      if @index == -1   # Box name
        pbPlayCursorSE
        go_to_next_box
      elsif @index == -2                    # Party button
        @index = -3                         # Exit button
      elsif @index == -3                    # Exit button
        @index = -2 if @mode != :withdraw   # Party button
      elsif (@index % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1   # Wrap around
        @index -= PokemonBox::BOX_WIDTH - 1
      else
        @index += 1
      end
    end
  end

  # The Back button is at @index -2.
  def update_cursor_movement_party
    if Input.repeat?(Input::UP)
      if @index == -2   # Back button
        @index = Settings::MAX_PARTY_SIZE - 1
      else
        @index -= 2
        @index = -2 if @index < 0   # Back button
      end
    elsif Input.repeat?(Input::DOWN)
      if @index == -2   # Back button
        @index = 0
      else
        @index += 2
        @index = -2 if @index >= Settings::MAX_PARTY_SIZE   # Back button
      end
    end
    if Input.repeat?(Input::LEFT)
      @index -= 1
      @index = Settings::MAX_PARTY_SIZE - 1 if @index < -2
      @index = -2 if @index < 0   # Back button
    elsif Input.repeat?(Input::RIGHT)
      @index += 1
      @index = 0 if @index < 0
      @index = -2 if @index >= Settings::MAX_PARTY_SIZE   # Back button
    end
  end

  def update_interaction(input)
    case input
    when Input::USE
      if @index == -1   # Box name
        pbPlayDecisionSE
        return :interact_box_name_menu
      elsif @index == -2   # Party button, or Back button in party panel
        pbPlayDecisionSE
        return :exit_screen if @mode == :deposit
        return (showing_party_panel?) ? :hide_party_panel : :show_party_panel
      elsif @index == -3   # Exit button
        pbPlayDecisionSE
        return :exit_screen
      else
        if pokemon
          return :rearrange_pokemon if @sub_mode == :rearrange_pokemon
          return :rearrange_items if @sub_mode == :rearrange_items
          pbPlayDecisionSE
          select_pokemon
          return :interact_menu
        end
      end
    when Input::ACTION
      if can_access_screen_menu?
        pbPlayDecisionSE
        return :screen_menu
      end
    when Input::BACK
      pbPlayCancelSE
      if showing_party_panel?
        return (@mode == :deposit) ? :exit_screen : :hide_party_panel
      end
      return :clear_sub_mode if (@sub_mode || :normal) != :normal
      return :exit_screen
    when Input::JUMPUP
      pbPlayCursorSE
      go_to_previous_box
    when Input::JUMPDOWN
      pbPlayCursorSE
      go_to_next_box
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  # NOTE: This is hardcoded to assume there are 6 marks, arranged in a 3x2 grid,
  #       with an OK and Cancel button below.
  def update_input_marking
    # Check for movement to a new option
    if Input.repeat?(Input::UP)
      if @marking_index == 7   # Cancel
        @marking_index = 6
      elsif @marking_index == 6   # OK
        @marking_index = 4
      elsif @marking_index < 3
        @marking_index = 7
      else
        @marking_index -= 3
      end
    elsif Input.repeat?(Input::DOWN)
      if @marking_index == 7   # Cancel
        @marking_index = 1
      elsif @marking_index == 6   # OK
        @marking_index = 7
      elsif @marking_index >= 3
        @marking_index = 6
      else
        @marking_index += 3
      end
    elsif Input.repeat?(Input::LEFT)
      if @marking_index < 6
        @marking_index -= 1
        @marking_index += 3 if (@marking_index % 3) == 2
      end
    elsif Input.repeat?(Input::RIGHT)
      if @marking_index < 6
        @marking_index += 1
        @marking_index -= 3 if (@marking_index % 3) == 0
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      case @marking_index
      when 6   # OK
        return true
      when 7   # Cancel
        @marking_index = -1
        return true
      else   # Change marking
        mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
        @markings[@marking_index] = ((@markings[@marking_index] || 0) + 1) % mark_variants
        refresh_markings_panel
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @marking_index = -1
      return true
    elsif Input.trigger?(Input::ACTION)
      if @marking_index < 6 && @markings[@marking_index] > 0
        pbPlayDecisionSE
        @markings[@marking_index] = 0
        refresh_markings_panel
      end
    end
    return false
  end

  def navigate_markings
    help_text = _INTL("Mark your Pokémon.")
    help_window = Window_AdvancedTextPokemon.newWithSize(
      help_text, 180, 0, Graphics.width - 180, 32, @viewport
    )
    help_window.z = 2000
    help_window.setSkin(MessageConfig.pbGetSpeechFrame)
    help_window.letterbyletter = false
    help_window.resizeHeightToFit(help_text, Graphics.width - 180)
    pbBottomRight(help_window)
    # Setup
    @sprites[:marking_bg].visible      = true
    @sprites[:marking_overlay].visible = true
    @sprites[:marking_cursor].visible  = true
    @markings = pokemon.markings.clone
    @marking_index = 0
    refresh_markings_panel
    refresh_markings_cursor
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_marking_index = @marking_index
      break if update_input_marking
      if @marking_index != old_marking_index
        pbPlayCursorSE
        refresh_markings_panel
        refresh_markings_cursor
      end
    end
    # Clean up
    @sprites[:marking_bg].visible      = false
    @sprites[:marking_overlay].visible = false
    @sprites[:marking_cursor].visible  = false
    pokemon.markings = @markings if @marking_index >= 0
    @marking_index = nil
    help_window.dispose
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonStorage < UI::BaseScreen
  attr_reader :storage, :mode

  SCREEN_ID = :pokemon_storage_screen

  # mode is one of:
  #     :withdraw
  #     :deposit
  #     :organize
  #     :choose_pokemon
  def initialize(storage, mode: :organize)
    @storage = storage
    @mode    = mode
    super()
  end

  def initialize_visuals
    @visuals = UI::PokemonStorageVisuals.new(@storage, @mode)
  end

  def start_screen
    pbSEPlay("PC access")
    super
  end

  def end_screen
    pbSEPlay("PC close")
    super
  end

  #-----------------------------------------------------------------------------

  # Returns the "active" Pokémon, i.e. the one that gets interacted with and is
  # shown in the side pane.
  def pokemon
    return @visuals.pokemon
  end

  def slot_pokemon
    return @visuals.slot_pokemon
  end

  # Returns whether the cursor is holding a Pokémon.
  def holding_pokemon?
    return @visuals.holding_pokemon?
  end

  def item
    return @visuals.item
  end

  def holding_item?
    return @visuals.holding_item?
  end

  # -1 is the party, 0+ is a box.
  def box
    return @visuals.box
  end

  def choose_box(message, start_box = -1)
    return @visuals.choose_box(message, start_box)
  end

  def set_index(new_index)
    @visuals.set_index(new_index)
  end

  def set_sub_mode(sub_mode = :normal)
    @visuals.set_sub_mode(sub_mode)
  end

  def party_able_count
    return @storage.party.count { |pkmn| pkmn.able? }
  end

  def deselect_pokemon
    @visuals.deselect_pokemon
  end

  #-----------------------------------------------------------------------------

  def refresh_selected_pokemon
    @visuals.refresh_selected_pokemon
  end

  def refresh_box
    @visuals.refresh_box
  end
end

#===============================================================================
# Actions that can be triggered in the Pokémon storage screen.
#===============================================================================
# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :screen_menu, {
  :menu         => :storage_screen_menu,
  :menu_message => proc { |screen| _INTL("What do you want to do?") }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :rearrange_pokemon_mode, {
  :effect => proc { |screen|
    if screen.holding_item?
      screen.show_message(_INTL("You're holding an item!"))
      next
    end
    screen.set_sub_mode(:rearrange_pokemon)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :rearrange_items_mode, {
  :effect => proc { |screen|
    if screen.holding_pokemon?
      screen.show_message(_INTL("You're holding a Pokémon!"))
      next
    end
    screen.set_sub_mode(:rearrange_items)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :clear_sub_mode, {
  :effect => proc { |screen|
    if screen.holding_pokemon?
      screen.show_message(_INTL("You're holding a Pokémon!"))
      next
    elsif screen.holding_item?
      item_name = GameData::Item.get(screen.item).name
      if screen.show_confirm_message(_INTL("Put the {1} in your Bag?", item_name))
        $bag.add(screen.item)
        screen.visuals.sprites[:cursor].held_item = nil
      end
      next
    end
    screen.set_sub_mode(:normal)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :rearrange_pokemon, {
  :effect => proc { |screen|
    if screen.holding_pokemon?
      if screen.slot_pokemon
        screen.perform_action(:swap_pokemon)
      else
        screen.perform_action(:put_down_pokemon)
      end
    else
      screen.perform_action(:pick_up_pokemon)
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :rearrange_items, {
  :effect => proc { |screen|
    next if !screen.slot_pokemon
    if screen.holding_item?
      if screen.slot_pokemon && screen.slot_pokemon.hasItem?
        screen.perform_action(:swap_items)
      else
        screen.perform_action(:put_down_item)
      end
    elsif screen.slot_pokemon && screen.slot_pokemon.hasItem?
      screen.perform_action(:pick_up_item)
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :pick_up_item, {
  :effect => proc { |screen|
    next if screen.holding_item? || !screen.slot_pokemon || !screen.slot_pokemon.hasItem?
    if screen.slot_pokemon.mail
      screen.show_message("You can't move mail.")
      next
    end
    screen.visuals.pick_up_item
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :swap_items, {
  :effect => proc { |screen|
    next if !screen.holding_item? || !screen.slot_pokemon || !screen.slot_pokemon.hasItem?
    held_item = screen.item
    slot_pkmn = screen.slot_pokemon
    if slot_pkmn.mail
      screen.show_message("You can't move mail.")
      next
    end
    screen.visuals.swap_items
    slot_pkmn.item = held_item
    screen.refresh_selected_pokemon
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :put_down_item, {
  :effect => proc { |screen|
    next if !screen.holding_item? || !screen.slot_pokemon || screen.slot_pokemon.hasItem?
    pkmn = screen.slot_pokemon
    screen.visuals.put_down_item
  }
})

#-------------------------------------------------------------------------------

# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :interact_menu, {
  :menu         => :storage_pokemon_interact,
  :menu_message => proc { |screen| _INTL("Do what with {1}?", screen.pokemon.name) }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :select_pokemon, {
  :returns_value => true,
  :effect        => proc { |screen|
    if screen.slot_pokemon
      screen.result = [screen.box, screen.index]
      next :quit
    end
    next nil
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :pick_up_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Tried picking up a Pokémon when holding one.") if screen.holding_pokemon?
    raise _INTL("Position {1},{2} is empty...", screen.box, screen.index) if !screen.slot_pokemon
    if screen.box < 0 && screen.slot_pokemon.able? && screen.party_able_count <= 1
      pbPlayBuzzerSE
      screen.show_message(_INTL("That's your last Pokémon!"))
      next
    end
    screen.visuals.pick_up_pokemon
    screen.storage.pbDelete(screen.box, screen.index)
    screen.refresh
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :swap_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Tried swapping a Pokémon when not holding one.") if !screen.holding_pokemon?
    raise _INTL("Position {1},{2} is empty...", screen.box, screen.index) if !screen.slot_pokemon
    held_pkmn = screen.pokemon
    slot_pkmn = screen.slot_pokemon
    if screen.box >= 0
      if screen.index >= @storage.maxPokemon(screen.box)
        screen.show_message("Can't place that there.")
        next
      elsif held_pkmn.mail
        screen.show_message("Please remove the mail.")
        next
      elsif held_pkmn.cannot_store
        screen.show_message(_INTL("{1} refuses to go into storage!", held_pkmn.name))
        next
      end
    elsif screen.box < 0 && slot_pkmn.able? && screen.party_able_count <= 1 && !held_pkmn.able?
      pbPlayBuzzerSE
      screen.show_message(_INTL("That's your last Pokémon!"))
      next
    end
    screen.visuals.swap_pokemon
    screen.storage[screen.box, screen.index] = held_pkmn
    if Settings::HEAL_STORED_POKEMON && screen.box >= 0
      old_ready_evo = held_pkmn.ready_to_evolve
      held_pkmn.heal
      held_pkmn.ready_to_evolve = old_ready_evo
    end
    screen.refresh
    screen.refresh_selected_pokemon
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :put_down_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Tried placing a Pokémon when not holding one.") if !screen.holding_pokemon?
    raise _INTL("Position {1},{2} is not empty...", screen.box, screen.index) if screen.slot_pokemon
    pkmn = screen.pokemon   # The held Pokémon
    if screen.box >= 0
      if screen.index >= screen.storage.maxPokemon(screen.box)
        screen.show_message("Can't place that there.")
        next
      elsif pkmn.mail
        screen.show_message("Please remove the mail.")
        next
      elsif pkmn.cannot_store
        screen.show_message(_INTL("{1} refuses to go into storage!", pkmn.name))
        next
      end
    end
    screen.visuals.put_down_pokemon
    screen.storage[screen.box, screen.index] = pkmn
    screen.storage.party.compact! if screen.box < 0
    if Settings::HEAL_STORED_POKEMON && screen.box >= 0
      old_ready_evo = pkmn.ready_to_evolve
      pkmn.heal
      pkmn.ready_to_evolve = old_ready_evo
    end
    screen.refresh
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :summary, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      screen.deselect_pokemon
      if screen.holding_pokemon?
        UI::PokemonSummary.new(screen.pokemon, 0).main
      else
        party = (screen.box >= 0) ? screen.storage[screen.box].pokemon : screen.storage[screen.box]
        new_index = UI::PokemonSummary.new(party, screen.index).main
        screen.set_index(new_index)
      end
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :withdraw, {
  :effect => proc { |screen|
    screen.perform_action(:withdraw_pokemon)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :withdraw_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Can't withdraw from party...") if screen.box < 0
    if screen.storage.party_full?
      screen.show_message(_INTL("Your party's full!"))
      next
    end
    was_holding = screen.holding_pokemon?
    pkmn = screen.pokemon
    screen.visuals.withdraw_pokemon
    if was_holding
      screen.storage.pbMoveCaughtToParty(pkmn)
    else
      screen.storage.pbMove(-1, -1, screen.box, screen.index)
    end
    screen.refresh
    screen.refresh_selected_pokemon
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :store, {
  :effect => proc { |screen|
    screen.perform_action(:store_pokemon)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :store_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Can't deposit from box...") if screen.box >= 0
    was_holding = screen.holding_pokemon?
    pkmn = screen.pokemon
    if pkmn.able? && screen.party_able_count <= 1 && !screen.holding_pokemon?
      pbPlayBuzzerSE
      screen.show_message(_INTL("That's your last Pokémon!"))
      next
    elsif pkmn.mail
      screen.show_message("Please remove the mail.")
      next
    elsif pkmn.cannot_store
      screen.show_message(_INTL("{1} refuses to go into storage!", pkmn.name))
      next
    end
    old_box = screen.box
    old_index = screen.index
    loop do
      new_box = screen.choose_box(_INTL("Deposit in which Box?"), old_box)
      break if !new_box
      new_index = screen.storage.pbFirstFreePos(new_box)
      if new_index < 0
        screen.show_message(_INTL("The Box is full."))
        next
      end
      screen.visuals.store_pokemon(new_box, new_index) {
        if was_holding
          screen.storage.pbMoveCaughtToBox(pkmn, new_box)
        else
          screen.storage.pbMove(new_box, new_index, old_box, old_index)
        end
      }
      screen.refresh
      screen.refresh_selected_pokemon
      break
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :give_or_take_item, {
  :effect => proc { |screen|
    pkmn = screen.pokemon
    if pkmn.egg?
      screen.show_message(_INTL("Eggs can't hold items."))
      next
    elsif pkmn.mail
      screen.show_message(_INTL("Please remove the mail."))
      next
    end
    # Take an item
    if pkmn.hasItem?
      item_name = pkmn.item.portion_name
      if screen.show_confirm_message(_INTL("Take the {1}?", item_name))
        if $bag.add(pkmn.item)
          pkmn.item = nil
          screen.refresh
          screen.show_message(_INTL("Took the {1}.", item_name))
        else
          screen.show_message(_INTL("Can't store the {1}.", item_name))
        end
      end
      screen.deselect_pokemon
      next
    end
    # Give an item
    new_item = nil
    pbFadeOutInWithUpdate(screen.sprites) do
      bag_screen = UI::Bag.new($bag, mode: :choose_item)
      bag_screen.set_filter_proc(proc { |itm| GameData::Item.get(itm).can_hold? })
      new_item = bag_screen.choose_item
      screen.deselect_pokemon if !new_item
    end
    if new_item
      item_name = GameData::Item.get(new_item).name
      pkmn.item = new_item
      $bag.remove(new_item)
      screen.refresh
      screen.show_message(_INTL("{1} is now being held.", item_name))
      screen.deselect_pokemon
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :mark_pokemon, {
  :effect => proc { |screen|
    screen.visuals.navigate_markings
    screen.deselect_pokemon
    screen.refresh
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :release_pokemon, {
  :effect => proc { |screen|
    raise _INTL("Tried releasing a Pokémon when not selecting or holding one.", screen.box, screen.index) if !screen.pokemon
    pkmn = screen.pokemon
    if pkmn.egg?
      screen.show_message(_INTL("You can't release an Egg."))
      next
    elsif pkmn.mail
      screen.show_message(_INTL("Please remove the mail."))
      next
    elsif pkmn.cannot_release
      screen.show_message(_INTL("{1} refuses to leave you!", pkmn.name))
      next
    elsif screen.box < 0 && pkmn.able? && screen.party_able_count <= 1 && !screen.holding_pokemon?
      pbPlayBuzzerSE
      screen.show_message(_INTL("That's your last Pokémon!"))
      next
    end
    if screen.show_confirm_serious_message(_INTL("Release this Pokémon?"))
      $bag.add(pkmn.item_id) if pkmn.hasItem?
      pkmn_name = pkmn.name
      screen.visuals.release_pokemon
      screen.storage.pbDelete(screen.box, screen.index) if !screen.holding_pokemon?
      screen.refresh
      screen.show_message(_INTL("{1} was released.", pkmn_name))
      screen.show_message(_INTL("Bye-bye, {1}!", pkmn_name))
      $stats.pokemon_release_count += 1
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :debug, {
  :effect => proc { |screen|
    screen.pokemon_debug_menu(screen.pokemon, [screen.box, screen.index])
  }
})

#-------------------------------------------------------------------------------

# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :interact_box_name_menu, {
  :menu         => :storage_box_interact,
  :menu_message => proc { |screen| _INTL("Choose an option.") }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :jump_to_box, {
  :effect => proc { |screen|
    new_box = screen.choose_box(_INTL("Jump to which Box?"))
    next if !new_box || new_box == box
    (new_box > box) ? screen.visuals.go_to_next_box(new_box) : screen.visuals.go_to_previous_box(new_box)
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :rename_box, {
  :effect => proc { |screen|
    pbFadeOutInWithUpdate(screen.sprites) do
      ret = pbEnterBoxName(_INTL("Box name?"), 0, 16)
      if ret.length > 0
        screen.storage[screen.storage.currentBox].name = ret
        screen.refresh_box
      end
    end
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :change_box_wallpaper, {
  :effect => proc { |screen|
    papers = screen.storage.availableWallpapers
    old_paper = screen.storage[screen.storage.currentBox].background
    index = papers.keys.index(old_paper) || 0
    new_paper = screen.visuals.choose_box_wallpaper(_INTL("Pick the wallpaper."), papers, index)
    if new_paper && new_paper != old_paper
      screen.storage[screen.storage.currentBox].background = new_paper
      screen.refresh_box
    end
  }
})

#-------------------------------------------------------------------------------

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :show_party_panel, {
  :effect => proc { |screen|
    screen.visuals.show_party_panel
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :hide_party_panel, {
  :effect => proc { |screen|
    screen.visuals.hide_party_panel
  }
})

UIActionHandlers.add(UI::PokemonStorage::SCREEN_ID, :exit_screen, {
  :returns_value => true,
  :effect        => proc { |screen|
    if screen.holding_pokemon?
      screen.show_message(_INTL("You're holding a Pokémon!"))
      next nil
    elsif screen.holding_item?
      screen.show_message(_INTL("You're holding an item!"))
      next nil
    end
    next :quit if screen.show_confirm_message(_INTL("Exit from the Box?"))
    next nil
  }
})

#===============================================================================
# Menu options for choice menus that exist in the Pokémon storage screen.
#===============================================================================
MenuHandlers.add(:storage_screen_menu, :rearrange_pokemon_mode, {
  "name"      => _INTL("Mode: Switch Pokémon"),
  "order"     => 10
})

MenuHandlers.add(:storage_screen_menu, :rearrange_items_mode, {
  "name"      => _INTL("Mode: Switch items"),
  "order"     => 20
})

MenuHandlers.add(:storage_screen_menu, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#-------------------------------------------------------------------------------

# NOTE: This option is first in withdraw mode.
MenuHandlers.add(:storage_pokemon_interact, :withdraw, {
  "name"      => _INTL("Withdraw"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.mode == :withdraw && screen.box >= 0 }
})

# NOTE: This option is first in store mode.
MenuHandlers.add(:storage_pokemon_interact, :store, {
  "name"      => _INTL("Store"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.mode == :deposit && screen.box < 0 }
})

# NOTE: This option is for when in "choose a Pokémon" mode.
MenuHandlers.add(:storage_pokemon_interact, :select_pokemon, {
  "name"      => _INTL("Select"),
  "order"     => 10,
  "condition" => proc { |screen| next screen.mode == :choose_pokemon }
})

MenuHandlers.add(:storage_pokemon_interact, :pick_up_pokemon, {
  "name"      => _INTL("Move"),
  "order"     => 20,
  "condition" => proc { |screen| next screen.mode == :organize && !screen.holding_pokemon? }
})

MenuHandlers.add(:storage_pokemon_interact, :swap_pokemon, {
  "name"      => _INTL("Shift"),
  "order"     => 20,
  "condition" => proc { |screen| next screen.mode == :organize && screen.holding_pokemon? && screen.slot_pokemon }
})

MenuHandlers.add(:storage_pokemon_interact, :put_down_pokemon, {
  "name"      => _INTL("Place"),
  "order"     => 20,
  "condition" => proc { |screen| next screen.mode == :organize && screen.holding_pokemon? && !screen.slot_pokemon }
})

MenuHandlers.add(:storage_pokemon_interact, :summary, {
  "name"      => _INTL("Summary"),
  "order"     => 30
})

MenuHandlers.add(:storage_pokemon_interact, :withdraw_pokemon, {
  "name"      => _INTL("Withdraw"),
  "order"     => 40,
  "condition" => proc { |screen| next screen.mode == :organize && screen.box >= 0 }
})

MenuHandlers.add(:storage_pokemon_interact, :store_pokemon, {
  "name"      => _INTL("Store"),
  "order"     => 40,
  "condition" => proc { |screen| next screen.mode == :organize && screen.box < 0 }
})

MenuHandlers.add(:storage_pokemon_interact, :give_or_take_item, {
  "name"      => _INTL("Item"),
  "order"     => 50,
  "condition" => proc { |screen| next screen.mode == :organize }
})

MenuHandlers.add(:storage_pokemon_interact, :mark_pokemon, {
  "name"      => _INTL("Mark"),
  "order"     => 60
})

MenuHandlers.add(:storage_pokemon_interact, :release_pokemon, {
  "name"      => _INTL("Release"),
  "order"     => 70,
  "condition" => proc { |screen| next screen.mode != :choose_pokemon }
})

MenuHandlers.add(:storage_pokemon_interact, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 80,
  "condition" => proc { |screen| next $DEBUG }
})

MenuHandlers.add(:storage_pokemon_interact, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#-------------------------------------------------------------------------------

MenuHandlers.add(:storage_box_interact, :jump_to_box, {
  "name"      => _INTL("Jump to box"),
  "order"     => 10
})

MenuHandlers.add(:storage_box_interact, :rename_box, {
  "name"      => _INTL("Rename box"),
  "order"     => 20
})

MenuHandlers.add(:storage_box_interact, :change_box_wallpaper, {
  "name"      => _INTL("Change wallpaper"),
  "order"     => 30
})

MenuHandlers.add(:storage_box_interact, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})
