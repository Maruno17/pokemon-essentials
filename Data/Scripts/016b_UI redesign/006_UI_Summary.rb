#===============================================================================
#
#===============================================================================
class UI::PokemonSummaryMoveCursor < Sprite
  attr_reader :index

  CURSOR_THICKNESS = 6

  def initialize(viewport = nil, preselected = false, new_move = false)
    super(viewport)
    @cursor_bitmap = AnimatedBitmap.new("Graphics/UI/Summary/cursor_move")
    @frame = 0
    @index = 0
    @preselected = preselected
    @new_move = new_move
    self.z = 1600
    refresh
  end

  def dispose
    @cursor_bitmap.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def refresh
    cursor_width = @cursor_bitmap.width
    cursor_height = @cursor_bitmap.height / 2
    self.x = UI::PokemonSummaryVisuals::MOVE_LIST_X_DETAILED - CURSOR_THICKNESS
    self.y = UI::PokemonSummaryVisuals::MOVE_LIST_Y - CURSOR_THICKNESS + (self.index * UI::PokemonSummaryVisuals::MOVE_LIST_SPACING)
    self.y += UI::PokemonSummaryVisuals::MOVE_LIST_OFFSET_WHEN_NEW_MOVE if @new_move
    self.y += UI::PokemonSummaryVisuals::MOVE_LIST_NEW_MOVE_SPACING if @new_move && self.index == Pokemon::MAX_MOVES
    self.bitmap = @cursor_bitmap.bitmap
    if @preselected
      self.src_rect.set(0, cursor_height, cursor_width, cursor_height)
    else
      self.src_rect.set(0, 0, cursor_width, cursor_height)
    end
  end

  def update
    super
    @cursor_bitmap.update
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonSummaryRibbonCursor < Sprite
  attr_reader :index

  CURSOR_THICKNESS = 2

  def initialize(viewport = nil, preselected = false)
    super(viewport)
    @cursor_bitmap = AnimatedBitmap.new("Graphics/UI/Summary/cursor_ribbon")
    @frame = 0
    @index = 0
    @preselected = preselected
    @updating = false
    @cursor_visible = true
    self.z = 1600
    refresh
  end

  def dispose
    @cursor_bitmap.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def visible=(value)
    super
    @cursor_visible = value if !@updating
  end

  def recheck_visibility
    @updating = true
    self.visible = @cursor_visible && @index >= 0 &&
                   @index < UI::PokemonSummaryVisuals::RIBBON_COLUMNS * UI::PokemonSummaryVisuals::RIBBON_ROWS
    @updating = false
  end

  def refresh
    recheck_visibility
    cols = UI::PokemonSummaryVisuals::RIBBON_COLUMNS
    offset_x = UI::PokemonSummaryVisuals::RIBBON_SIZE[0] + UI::PokemonSummaryVisuals::RIBBON_SPACING_X
    offset_y = UI::PokemonSummaryVisuals::RIBBON_SIZE[1] + UI::PokemonSummaryVisuals::RIBBON_SPACING_Y
    self.x = UI::PokemonSummaryVisuals::RIBBON_X - CURSOR_THICKNESS + ((self.index % cols) * offset_x)
    self.y = UI::PokemonSummaryVisuals::RIBBON_Y - CURSOR_THICKNESS + ((self.index / cols) * offset_y)
    self.bitmap = @cursor_bitmap.bitmap
    w = @cursor_bitmap.width
    h = @cursor_bitmap.height / 2
    if @preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    super
    recheck_visibility
    @cursor_bitmap.update
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonSummaryVisuals < UI::BaseVisuals
  GRAPHICS_FOLDER   = "Summary/"   # Subfolder in Graphics/UI
  TEXT_COLOR_THEMES = {   # These color themes are added to @sprites[:overlay]
    :default      => [Color.new(248, 248, 248), Color.new(104, 104, 104)],   # Base and shadow colour
    :white        => [Color.new(248, 248, 248), Color.new(104, 104, 104)],
    :raised_stat  => [Color.new(248, 248, 248), Color.new(136, 96, 72)],
    :lowered_stat => [Color.new(248, 248, 248), Color.new(64, 120, 152)],
    :black        => [Color.new(64, 64, 64), Color.new(176, 176, 176)],
    :faded        => [Color.new(192, 200, 208), Color.new(208, 216, 224)],
    :male         => [Color.new(24, 112, 216), Color.new(136, 168, 208)],
    :female       => [Color.new(248, 56, 32), Color.new(224, 152, 144)],
    :shiny        => [Color.new(248, 56, 32), Color.new(224, 152, 144)],
    :pp_half      => [Color.new(248, 192, 0), Color.new(144, 104, 0)],
    :pp_quarter   => [Color.new(248, 136, 32), Color.new(144, 72, 24)],
    :pp_zero      => [Color.new(248, 72, 72), Color.new(136, 48, 48)]
  }
  PARTY_ICONS_COUNT              = 6
  PARTY_ICON_SIZE                = [18, 18]   # In the party_icons.png graphic
  MARKING_WIDTH                  = 16
  MARKING_HEIGHT                 = 16
  MOVE_LIST_X                    = 230
  MOVE_LIST_X_DETAILED           = MOVE_LIST_X + 32
  MOVE_LIST_Y                    = 98
  MOVE_LIST_SPACING              = 64    # Y distance between top of two adjacent move areas
  MOVE_LIST_OFFSET_WHEN_NEW_MOVE = -76   # Offset for y coordinate
  MOVE_LIST_NEW_MOVE_SPACING     = 22    # New move is separated from known moves
  RIBBON_SIZE                    = [64, 64]   # [width, height]
  RIBBON_SPACING_X               = 4
  RIBBON_SPACING_Y               = 4
  RIBBON_COLUMNS                 = 4
  RIBBON_ROWS                    = 3
  RIBBON_X                       = 230   # Left edge of top left ribbon
  RIBBON_Y                       = 78    # Top edge of top left ribbon
  RIBBON_COLUMNS_GRAPHIC         = 8     # In the ribbons.png graphic

  #-----------------------------------------------------------------------------

  PAGE_HANDLERS = HandlerHash.new
  PAGE_HANDLERS.add(:info, {
    :name       => proc { next _INTL("INFO") },
    :order      => 10,
    :icon_index => 0,
    :draw       => [
      :draw_common_page_contents,
      :draw_pokedex_number,
      :draw_species,
      :draw_original_trainer_details,
      :draw_held_item,
      :draw_exp,
      :draw_shadow_pokemon_info
    ]
  })
  PAGE_HANDLERS.add(:skills, {
    :name       => proc { next _INTL("SKILLS") },
    :order      => 20,
    :icon_index => 1,
    :draw       => [
      :draw_common_page_contents,
      :draw_stats,
      :draw_ability
    ]
  })
  PAGE_HANDLERS.add(:moves, {
    :name       => proc { next _INTL("MOVES") },
    :order      => 30,
    :icon_index => 2,
    :draw       => [
      :draw_common_page_contents,
      :draw_moves_list
    ]
  })
  PAGE_HANDLERS.add(:ribbons, {
    :name       => proc { next _INTL("RIBBONS") },
    :order      => 40,
    :icon_index => 3,
    :should_show => proc { |pokemon| next pokemon.numRibbons > 0 },
    :draw       => [
      :draw_common_page_contents,
      :draw_ribbon_count,
      :draw_ribbons_in_grid,
      :draw_ribbon_properties
    ]
  })
  PAGE_HANDLERS.add(:memo, {
    :name       => proc { next _INTL("TRAINER MEMO") },
    :order      => 50,
    :icon_index => 4,
    :draw       => [
      :draw_common_page_contents,
      :draw_memo
    ]
  })
  PAGE_HANDLERS.add(:egg_memo, {
    :name       => proc { next _INTL("TRAINER MEMO") },
    :egg_page   => true,
    :icon_index => 5,
    :draw       => [
      :draw_page_name,
      :draw_page_icons,
      :draw_poke_ball,
      :draw_pokemon_name,
      :draw_markings,
      :draw_egg_memo
    ]
  })
  # Pseudo-page, only used to draw different contents for the detailed moves
  # page.
  PAGE_HANDLERS.add(:detailed_moves, {
    :icon_index  => 2,
    :should_show => proc { |pokemon| next false },
    :draw        => [
      :draw_page_name,
      :draw_page_icons,
      :draw_pokemon_types_for_detailed_moves_page,
      :draw_moves_list,
      :draw_move_properties
    ]
  })

  #-----------------------------------------------------------------------------

  def initialize(party, party_index = 0, mode = :normal, new_move = nil)
    @party                = party
    @party_index          = party_index
    @pokemon              = @party[@party_index]
    @visible_party_length = 0
    @visible_index        = 0
    @party.each_with_index do |pkmn, i|
      next if !pkmn
      @visible_party_length += 1
      @visible_index = @visible_party_length - 1 if i == @party_index
    end
    @visible_top_index    = 0
    @mode                 = mode
    @new_move             = new_move   # Only used if @mode is :choose_move
    @page                 = (@mode == :choose_move) ? :moves : all_pages[0]
    @move_index           = (@mode == :choose_move) ? 0 : nil
    super()
  end

  def initialize_bitmaps
    @bitmaps[:types]       = AnimatedBitmap.new(UI_FOLDER + _INTL("types"))
    @bitmaps[:markings]    = AnimatedBitmap.new(graphics_folder + "markings")
    @bitmaps[:numbers]     = AnimatedBitmap.new(graphics_folder + "numbers")
    @bitmaps[:page_icons]  = AnimatedBitmap.new(graphics_folder + "page_icons")
    @bitmaps[:party_icons] = AnimatedBitmap.new(graphics_folder + "party_icons")
  end

  def initialize_background
    super
    addBackgroundPlane(@sprites, :page_background, self.class::GRAPHICS_FOLDER + page_background_filename, @viewport)
    @sprites[:page_background].z = 100
  end

  def initialize_sprites
    # Pokémon sprite
    @sprites[:pokemon] = PokemonSprite.new(@viewport)
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].x       = 112
    @sprites[:pokemon].y       = 208
    @sprites[:pokemon].visible = (@mode != :choose_move)
    @sprites[:pokemon].setPokemonBitmap(@pokemon)
    # Page-specific sprites
    initialize_info_page_sprites
    initialize_move_page_sprites
    initialize_ribbon_page_sprites
    initialize_marking_sprites
  end

  def initialize_info_page_sprites
    # Held item icon
    @sprites[:held_item_icon] = ItemIconSprite.new(260, 256, @pokemon.item_id, @viewport)
    @sprites[:held_item_icon].z         = 200
    @sprites[:held_item_icon].blankzero = true
  end

  def initialize_move_page_sprites
    # Pokémon icon
    @sprites[:pokemon_icon] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites[:pokemon_icon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon_icon].x       = 50
    @sprites[:pokemon_icon].y       = 92
    @sprites[:pokemon_icon].z       = 200
    @sprites[:pokemon_icon].visible = (@mode == :choose_move)
    # Cursor to highlight a move selected to be swapped
    @sprites[:selected_move_cursor] = UI::PokemonSummaryMoveCursor.new(@viewport, true)
    @sprites[:selected_move_cursor].visible = false
    # Cursor to highlight the currently selected move
    @sprites[:move_cursor] = UI::PokemonSummaryMoveCursor.new(@viewport, false, !@new_move.nil?)
    @sprites[:move_cursor].visible = (@mode == :choose_move)
  end

  def initialize_ribbon_page_sprites
    # Cursor to highlight a ribbon selected to be swapped
    @sprites[:selected_ribbon_cursor] = UI::PokemonSummaryRibbonCursor.new(@viewport, true)
    @sprites[:selected_ribbon_cursor].visible = false
    # Cursor to highlight the currently selected ribbon
    @sprites[:ribbon_cursor] = UI::PokemonSummaryRibbonCursor.new(@viewport)
    @sprites[:ribbon_cursor].visible = false
    # Arrow to indicate more ribbons are above the ones visible when navigating ribbons
    add_animated_arrow(:up_arrow, 350, 56, :up)
    @sprites[:up_arrow].z = 1700
    # Arrow to indicate more ribbons are below the ones visible when navigating ribbons
    add_animated_arrow(:down_arrow, 350, 260, :down)
    @sprites[:down_arrow].z = 1700
  end

  def initialize_marking_sprites
    # Background image of marking panel
    add_icon_sprite(:marking_bg, 254, 88, graphics_folder + "overlay_marking")
    @sprites[:marking_bg].z       = 1400
    @sprites[:marking_bg].visible = false
    # Overlay for marking panel
    add_overlay(:marking_overlay)
    @sprites[:marking_overlay].z       = 1500
    @sprites[:marking_overlay].visible = false
    # Cursor to highlight the currently selected marking option
    add_icon_sprite(:marking_cursor, 0, 0, graphics_folder + "cursor_marking")
    @sprites[:marking_cursor].z       = 1600
    @sprites[:marking_cursor].visible = false
    @sprites[:marking_cursor].src_rect.height = @sprites[:marking_cursor].bitmap.height / 2
  end

  #-----------------------------------------------------------------------------

  def page_background_filename
    return "bg_moves_learning" if @new_move     # Intentionally first
    return "bg_moves_detailed" if @move_index   # Intentionally second
    ret = BACKGROUND_FILENAME + "_" + @page.to_s
    return ret
  end

  #-----------------------------------------------------------------------------

  def all_pages
    ret = []
    PAGE_HANDLERS.each do |key, hash|
      next if @pokemon.egg? != !!hash[:egg_page]
      next if hash[:should_show] && !hash[:should_show].call(@pokemon)
      ret.push([key, hash[:order] || 0])
    end
    ret.sort_by! { |val| val[1] }
    ret.map! { |val| val[0] }
    return ret
  end

  def go_to_next_page
    pages = all_pages
    return if pages.length == 1
    page_index = pages.index(@page)
    return if page_index.nil? || page_index >= pages.length - 1
    @page = pages[page_index + 1]
    @ribbon_offset = 0
    pbSEPlay("GUI summary change page")
    refresh
  end

  def go_to_previous_page
    pages = all_pages
    return if pages.length == 1
    page_index = pages.index(@page)
    return if page_index.nil? || page_index == 0
    @page = pages[page_index - 1]
    @ribbon_offset = 0
    pbSEPlay("GUI summary change page")
    refresh
  end

  def set_party_index(new_index)
    return if @party_index == new_index
    old_page_index = all_pages.index(@page)
    # Set the new Pokémon
    @party_index = new_index
    @pokemon = @party[@party_index]
    @visible_index = 0
    @party.each_with_index do |pkmn, i|
      next if !pkmn
      break if i == @party_index
      @visible_index += 1
    end
    # Want to stay on the nth page, or the closest available one
    pages = all_pages
    new_page_index = old_page_index.clamp(0, pages.length - 1)
    @page = pages[new_page_index]
    # Set the Pokémon's sprite
    @sprites[:pokemon].setPokemonBitmap(@pokemon)
    @ribbon_offset = 0
    # Play sound effect
    play_pokemon_cry
    refresh
  end

  def play_pokemon_cry
    pbSEStop
    (@pokemon.egg?) ? pbSEPlay("GUI summary change page") : @pokemon.play_cry
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    @sprites[:held_item_icon].visible = false
    refresh_background
    draw_page_contents
  end

  def refresh_background
    @sprites[:background].setBitmap(graphics_folder + background_filename)
    @sprites[:page_background].setBitmap(graphics_folder + page_background_filename)
  end

  def draw_page_contents
    PAGE_HANDLERS[page_to_draw][:draw].each { |method| self.send(method) }
  end

  def page_to_draw
    ret = @page
    ret = :detailed_moves if showing_detailed_move_page?
    return ret
  end

  def showing_detailed_move_page?
    return !(@new_move || @move_index).nil?
  end

  #-----------------------------------------------------------------------------

  def draw_common_page_contents
    draw_page_name
    draw_page_icons
    draw_poke_ball
    draw_pokemon_name
    draw_shiny_icon
    draw_pokemon_level
    draw_pokerus_icon
    draw_gender
    draw_party_icons
    draw_markings
    draw_pokemon_types_common
    draw_hp_numbers
    draw_hp_bar
    draw_status_icon
  end

  def draw_page_name
    draw_text(PAGE_HANDLERS[@page][:name].call, 30, 22)
  end

  def draw_page_icons
    return if @new_move
    icon_width = 56
    icon_height = 64
    start_x = 226
    start_y = 2
    spacing_x = 0
    # Draw all inactive page icons
    pages = all_pages
    pages.each_with_index do |this_page, i|
      src_index = PAGE_HANDLERS[this_page][:icon_index]
      next if !src_index
      draw_image(@bitmaps[:page_icons], start_x + (i * (icon_width + spacing_x)), start_y,
                 src_index * icon_width, 0, icon_width, icon_height)
    end
    # Draw current page's active icon
    index = pages.index(@page)
    src_index = PAGE_HANDLERS[@page][:icon_index]
    if src_index
      draw_image(@bitmaps[:page_icons], start_x + (index * (icon_width + spacing_x)), start_y,
                src_index * icon_width, icon_height, icon_width, icon_height)
    end
  end

  # Show the Poké Ball containing the Pokémon
  def draw_poke_ball
    ball_filename = graphics_folder + sprintf("icon_ball_%s", @pokemon.poke_ball)
    draw_image(ball_filename, 6, 60)
  end

  def draw_pokemon_name
    draw_text(@pokemon.name, 42, 68)
  end

  def draw_shiny_icon
    draw_image(UI_FOLDER + "shiny", 14, 100) if @pokemon.shiny?
  end

  def draw_pokemon_level
    draw_image(graphics_folder + _INTL("level"), 42, 102)
    draw_number_from_image(@bitmaps[:numbers], @pokemon.level, 64, 102)
  end

  def draw_pokerus_icon
    return if @pokemon.pokerusStage != 2
    draw_image(graphics_folder + "icon_pokerus", 134, 100)
  end

  def draw_gender
    if @pokemon.male?
      draw_text(_INTL("♂"), 174, 98, theme: :male)
    elsif @pokemon.female?
      draw_text(_INTL("♀"), 174, 98, theme: :female)
    end
  end

  def draw_party_icons
    # Don't show any party icons if there is 0 or 1 Pokémon in the party
    return if @visible_party_length <= 1
    # Setup numbers
    @visible_top_index = [@visible_top_index, @visible_index - ((PARTY_ICONS_COUNT - 1) / 2)].min
    @visible_top_index = [@visible_top_index, @visible_index - (PARTY_ICONS_COUNT / 2), 0].max
    @visible_top_index = @visible_top_index.clamp(0, [@visible_party_length - PARTY_ICONS_COUNT, 0].max)
    x_pos = 0
    y_pos = 162
    # Draw up arrow
    arrow_y = y_pos - PARTY_ICON_SIZE[1]
    arrow_y -= PARTY_ICON_SIZE[1] if @visible_top_index > 0   # Showing up dots
    if @visible_index > 0   # Enabled arrow
      draw_image(@bitmaps[:party_icons], x_pos, arrow_y,
                 PARTY_ICON_SIZE[0] * 2, 0, *PARTY_ICON_SIZE)
    else   # Disabled arrow
      draw_image(@bitmaps[:party_icons], x_pos, arrow_y,
                PARTY_ICON_SIZE[0] * 3, 0, *PARTY_ICON_SIZE)
    end
    # Draw up dots
    if @visible_top_index > 0
      draw_image(@bitmaps[:party_icons], x_pos, y_pos - PARTY_ICON_SIZE[1],
                 PARTY_ICON_SIZE[0] * 4, 0, *PARTY_ICON_SIZE)
    end
    # Draw party icons
    num_balls = [@visible_party_length, PARTY_ICONS_COUNT].min
    num_balls.times do |i|
      src_x_index = (i + @visible_top_index == @visible_index) ? 1 : 0
      draw_image(@bitmaps[:party_icons], x_pos, y_pos + (i * PARTY_ICON_SIZE[1]),
                 PARTY_ICON_SIZE[0] * src_x_index, 0, *PARTY_ICON_SIZE)
    end
    # Draw down dots
    if @visible_party_length - @visible_top_index > PARTY_ICONS_COUNT
      draw_image(@bitmaps[:party_icons], x_pos, y_pos + (num_balls * PARTY_ICON_SIZE[1]),
                 PARTY_ICON_SIZE[0] * 7, 0, *PARTY_ICON_SIZE)
    end
    # Draw down arrow
    arrow_y = y_pos + (num_balls * PARTY_ICON_SIZE[1])
    arrow_y += PARTY_ICON_SIZE[1] if @visible_party_length - @visible_top_index > PARTY_ICONS_COUNT   # Showing down dots
    if @visible_index < @visible_party_length - 1   # Enabled arrow
      draw_image(@bitmaps[:party_icons], x_pos, arrow_y,
                 PARTY_ICON_SIZE[0] * 5, 0, *PARTY_ICON_SIZE)
    else   # Disabled arrow
      draw_image(@bitmaps[:party_icons], x_pos, arrow_y,
                 PARTY_ICON_SIZE[0] * 6, 0, *PARTY_ICON_SIZE)
    end
  end

  def draw_markings
    x = 106
    y = 288
    mark_variants = @bitmaps[:markings].bitmap.height / MARKING_HEIGHT
    markings = @pokemon.markings
    (@bitmaps[:markings].bitmap.width / MARKING_WIDTH).times do |i|
      src_x = i * MARKING_WIDTH
      src_y = [(markings[i] || 0), mark_variants - 1].min * MARKING_HEIGHT
      draw_image(@bitmaps[:markings], x + (i * MARKING_WIDTH), y,
                 src_x, src_y, MARKING_WIDTH, MARKING_HEIGHT)
    end
  end

  def draw_pokemon_types_common
    draw_pokemon_type_icons(66, 314, 2)
  end

  # x and y are the top left corner of the type icon if there is only one type.
  def draw_pokemon_type_icons(x, y, spacing)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      offset = ((@pokemon.types.length - 1) * (GameData::Type::ICON_SIZE[0] + spacing) / 2)
      offset = (offset / 2) * 2
      type_x = x - offset + ((GameData::Type::ICON_SIZE[0] + spacing) * i)
      draw_image(@bitmaps[:types], type_x, y,
                 0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    end
  end

  def draw_hp_bar
    return if @pokemon.fainted?
    bar_x = 48
    bar_y = 352
    bar_total_width = 128
    bar_width = [@pokemon.hp * bar_total_width / @pokemon.totalhp.to_f, 1.0].max
    bar_width = ((bar_width / 2).round) * 2   # Make the bar's length a multiple of 2 pixels
    hp_zone = 0                                                  # Green
    hp_zone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor   # Yellow
    hp_zone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor   # Red
    draw_image(graphics_folder + "hp_bar_fill", bar_x, bar_y,
               0, hp_zone * 6, bar_width, 6)
  end

  def draw_hp_numbers
    hp_text = sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp)
    draw_number_from_image(@bitmaps[:numbers], hp_text, 182, 366, align: :right)
  end

  # Show status/fainted/Pokérus infected icon
  def draw_status_icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      draw_image(UI_FOLDER + _INTL("statuses"), 12, 364,
                0, status * GameData::Status::ICON_SIZE[1], *GameData::Status::ICON_SIZE)
    end
  end

  #-----------------------------------------------------------------------------

  def draw_pokedex_number
    draw_text(_INTL("Dex No."), 238, 86)
    # Figure out what the Dex number is
    dex_num = 0
    dex_num_shift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      dex_num = (GameData::Species.keys.index(@pokemon.species_data.species) || 0) + 1
      dex_num_shift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else   # Only Regional Dexes are unlocked
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, @pokemon.species)
        break if num <= 0
        dex_num = num
        dex_num_shift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    # Draw text
    number_x = 428
    number_y = 86
    dex_num_theme = (@pokemon.shiny?) ? :shiny : :black
    if dex_num <= 0
      draw_text("???", number_x, number_y, align: :center, theme: dex_num_theme)
    else
      dex_num -= 1 if dex_num_shift
      draw_text(sprintf("%03d", dex_num), number_x, number_y, align: :center, theme: dex_num_theme)
    end
  end

  def draw_species
    draw_text(_INTL("Species"), 238, 118)
    draw_text(@pokemon.speciesName, 428, 118, align: :center, theme: :black)
  end

  def draw_original_trainer_details
    draw_text(_INTL("OT"), 238, 150)
    draw_text(_INTL("ID No."), 238, 182)
    owner_name = (@pokemon.owner.name.empty?) ? _INTL("RENTAL") : @pokemon.owner.name
    owner_theme = [:male, :female][@pokemon.owner.gender || 99] || :black
    draw_text(owner_name, 428, 150, align: :center, theme: owner_theme)
    owner_number = (@pokemon.owner.name.empty?) ? "?????" : sprintf("%05d", @pokemon.owner.public_id)
    draw_text(owner_number, 428, 182, align: :center, theme: :black)
  end

  def draw_held_item
    @sprites[:held_item_icon].visible = true
    @sprites[:held_item_icon].item = @pokemon.item_id
    draw_text(_INTL("Held Item"), 302, 230)
    # Write the held item's name
    if @pokemon.hasItem?
      draw_text(@pokemon.item.name, 302, 262, theme: :black)
    else
      draw_text(_INTL("None"), 302, 262, theme: :black)
    end
  end

  def draw_exp
    return if @pokemon.shadowPokemon?
    # Draw text
    draw_text(_INTL("Exp. Points"), 238, 310)
    draw_text(@pokemon.exp.to_s_formatted, 490, 310, align: :right, theme: :black)
    draw_text(_INTL("To Next Lv."), 238, 342)
    end_exp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
    draw_text((end_exp - @pokemon.exp).to_s_formatted, 490, 342, align: :right, theme: :black)
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      exp_width = @pokemon.exp_fraction * 128
      exp_width = ((exp_width / 2).round) * 2
      draw_image(graphics_folder + "exp_bar_fill", 362, 372,
                 0, 0, exp_width, -1)
    end
  end

  def draw_shadow_pokemon_info
    return if !@pokemon.shadowPokemon?
    # Draw background to cover the Exp area
    draw_image(graphics_folder + "overlay_shadow", 224, 298)
    # Draw heart gauge bar
    shadow_fract = @pokemon.heart_gauge.to_f / @pokemon.max_gauge_size
    draw_image(graphics_folder + "shadow_bar_fill", 242, 372,
               0, 0, (shadow_fract * 248).floor, -1)
    # Draw heart gauge text
    heart_message = [_INTL("The door to its heart is open! Undo the final lock!"),
                     _INTL("The door to its heart is almost fully open."),
                     _INTL("The door to its heart is nearly open."),
                     _INTL("The door to its heart is opening wider."),
                     _INTL("The door to its heart is opening up."),
                     _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
    draw_formatted_text(heart_message, 232, 310, 268, theme: :black)
  end

  def draw_stats
    # Determine which stats are boosted and lowered by the Pokémon's nature
    stat_themes = {}
    GameData::Stat.each_main { |s| stat_themes[s.id] = :default }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        stat_themes[change[0]] = :raised_stat if change[1] > 0
        stat_themes[change[0]] = :lowered_stat if change[1] < 0
      end
    end
    # Write stats text (except for HP)
    text_y = 86
    GameData::Stat.each_main do |stat|
      next if stat.id == :HP
      draw_text(stat.name_semi_brief, 238, text_y, theme: stat_themes[stat.id])
      draw_text(@pokemon.stat(stat.id), 458, text_y, align: :right, theme: :black)
      text_y += 32
    end
  end

  def draw_ability
    draw_text(_INTL("Ability"), 224, 262)
    ability = @pokemon.ability
    return if !ability
    draw_text(ability.name, 332, 262, theme: :black)
    draw_paragraph_text(ability.description, 224, 294, 284, 3, theme: :black)
  end

  def draw_moves_list
    limit = (@new_move) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = (i == Pokemon::MAX_MOVES) ? @new_move : @pokemon.moves[i]
      text_y = MOVE_LIST_Y + (i * MOVE_LIST_SPACING)
      text_y += MOVE_LIST_OFFSET_WHEN_NEW_MOVE if @new_move   # Showing an extra move being learned
      text_y += MOVE_LIST_NEW_MOVE_SPACING if i == Pokemon::MAX_MOVES   # New move is separated from known moves
      area_x = MOVE_LIST_X
      area_x = MOVE_LIST_X_DETAILED if showing_detailed_move_page?
      draw_move_in_list(move, area_x, text_y)
    end
  end

  def draw_move_in_list(move, x, y)
    pp_numbers_x = (showing_detailed_move_page?) ? x + 234 : x + 256
    if !move
      draw_text("---", x + 8, y + 6, theme: :black)
      return
    end
    # Draw move name
    draw_text(move.name, x + 8, y + 6, theme: :black)
    # Draw move type icon
    type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
    draw_image(@bitmaps[:types], x + 8, y + 32,
               0, type_number * GameData::Type::ICON_SIZE[1], *GameData::Type::ICON_SIZE)
    # Draw move category
    draw_image(UI_FOLDER + "category", x + 74, y + 32,
               0, move.display_category(@pokemon) * GameData::Move::CATEGORY_ICON_SIZE[1], *GameData::Move::CATEGORY_ICON_SIZE)
    # Draw PP text
    if move.total_pp > 0
      pp_text_x = (showing_detailed_move_page?) ? x + 144 : x + 154
      draw_text(_INTL("PP"), pp_text_x, y + 38, theme: :black)
      pp_text_theme = :black
      if move.pp == 0
        pp_text_theme = :pp_zero
      elsif move.pp * 4 <= move.total_pp
        pp_text_theme = :pp_quarter
      elsif move.pp * 2 <= move.total_pp
        pp_text_theme = :pp_half
      end
      draw_text(sprintf("%d/%d", move.pp, move.total_pp), pp_numbers_x, y + 38, align: :right, theme: pp_text_theme)
    end
  end

  def draw_pokemon_types_for_detailed_moves_page
    draw_pokemon_type_icons(138, 78, 6)
  end

  def draw_move_properties
    selected_move = ((@move_index || 0) == Pokemon::MAX_MOVES) ? @new_move : @pokemon.moves[@move_index || 0]
    # Power
    draw_text(_INTL("POWER"), 20, 128)
    power_text = selected_move.display_damage(@pokemon)
    power_text = "---" if power_text == 0   # Status move
    power_text = "???" if power_text == 1   # Variable power move
    draw_text(power_text, 222, 128, align: :right, theme: :black)
    # Accuracy
    draw_text(_INTL("ACCURACY"), 20, 160)
    accuracy = selected_move.display_accuracy(@pokemon)
    if accuracy == 0
      draw_text("---", 222, 160, align: :right, theme: :black)
    else
      draw_text(accuracy, 222, 160, align: :right, theme: :black)
      draw_text("%", 222, 160, theme: :black)
    end
    # Description
    draw_paragraph_text(selected_move.description, 4, 192, 246, 6, theme: :black)
  end

  def draw_ribbon_count
    draw_text(_INTL("No. of Ribbons:"), 234, 338, theme: :black)
    draw_text(@pokemon.numRibbons, 450, 338, align: :right, theme: :black)
  end

  def draw_ribbons_in_grid
    (RIBBON_COLUMNS * RIBBON_ROWS).times do |index|   # Number of visible ribbons
      r_index = (@ribbon_offset * RIBBON_COLUMNS) + index
      break if !@pokemon.ribbons[r_index]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[r_index])
      image_offset = ribbon_data.icon_position
      draw_image(graphics_folder + "ribbons",
                RIBBON_X + ((RIBBON_SIZE[0] + RIBBON_SPACING_X) * (index % RIBBON_COLUMNS)),
                RIBBON_Y + ((RIBBON_SIZE[1] + RIBBON_SPACING_Y) * (index / RIBBON_COLUMNS).floor),
                RIBBON_SIZE[0] * (image_offset % RIBBON_COLUMNS_GRAPHIC),
                RIBBON_SIZE[1] * (image_offset / RIBBON_COLUMNS_GRAPHIC).floor,
                *RIBBON_SIZE)
    end
  end

  def draw_ribbon_properties
    return if !@ribbon_index
    ribbon_id = @pokemon.ribbons[@ribbon_index]
    # Draw the description box
    draw_image(graphics_folder + "overlay_ribbon", 8, 280)
    if ribbon_id
      ribbon_data = GameData::Ribbon.get(ribbon_id)
      # Draw name of selected ribbon
      draw_text(ribbon_data.name, 18, 292)
      # Draw selected ribbon's description
      draw_paragraph_text(ribbon_data.description, 18, 324, 480, 2, theme: :black)
    end
  end

  def draw_memo
    # Set up memo
    red_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:shiny])
    black_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:black])
    memo = ""
    show_nature = (!@pokemon.shadowPokemon? || @pokemon.heartStage <= 3)
    # Add nature to memo
    if show_nature
      nature_name = red_text_tag + @pokemon.nature.name + black_text_tag
      memo += _INTL("{1} nature.", nature_name) + "\n"
    end
    # Add characteristic to memo
    if show_nature
      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length   # Tiebreaker
      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end
      characteristics = {
        :HP              => [_INTL("Loves to eat."),
                             _INTL("Takes plenty of siestas."),
                             _INTL("Nods off a lot."),
                             _INTL("Scatters things often."),
                             _INTL("Likes to relax.")],
        :ATTACK          => [_INTL("Proud of its power."),
                             _INTL("Likes to thrash about."),
                             _INTL("A little quick tempered."),
                             _INTL("Likes to fight."),
                             _INTL("Quick tempered.")],
        :DEFENSE         => [_INTL("Sturdy body."),
                             _INTL("Capable of taking hits."),
                             _INTL("Highly persistent."),
                             _INTL("Good endurance."),
                             _INTL("Good perseverance.")],
        :SPECIAL_ATTACK  => [_INTL("Highly curious."),
                             _INTL("Mischievous."),
                             _INTL("Thoroughly cunning."),
                             _INTL("Often lost in thought."),
                             _INTL("Very finicky.")],
        :SPECIAL_DEFENSE => [_INTL("Strong willed."),
                             _INTL("Somewhat vain."),
                             _INTL("Strongly defiant."),
                             _INTL("Hates to lose."),
                             _INTL("Somewhat stubborn.")],
        :SPEED           => [_INTL("Likes to run."),
                             _INTL("Alert to sounds."),
                             _INTL("Impetuous and silly."),
                             _INTL("Somewhat of a clown."),
                             _INTL("Quick to flee.")]
      }
      memo += black_text_tag + characteristics[best_stat][best_iv % 5] + "\n"
    end
    # Add blank line
    memo += "\n" if show_nature
    # Write how Pokémon was obtained
    met_text = [
      _INTL("Met at Lv. {1}.", @pokemon.obtain_level),
      _INTL("Egg received."),
      _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
      "",
      _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)
    ][@pokemon.obtain_method]
    memo += black_text_tag + met_text + "\n" if met_text && met_text != ""
    # Add date received to memo
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      # TODO: Write this date the wrong way round for United States of Americans.
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Add map name Pokémon was received on to memo
    map_name = pbGetMapNameFromId(@pokemon.obtain_map)
    map_name = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    map_name = _INTL("Faraway place") if nil_or_empty?(map_name)
    memo += red_text_tag + map_name + "\n"
    # If Pokémon was hatched, add when and where it hatched to memo
    if @pokemon.obtain_method == 1
      memo += black_text_tag + _INTL("Egg hatched.") + "\n"
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        # TODO: Write this date the wrong way round for United States of Americans.
        memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
      end
      map_name = pbGetMapNameFromId(@pokemon.hatched_map)
      map_name = _INTL("Faraway place") if nil_or_empty?(map_name)
      memo += red_text_tag + map_name + "\n"
    end
    # Write memo
    draw_formatted_text(memo, 232, 86, 268)
  end

  def draw_egg_memo
    # Set up memo
    red_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:shiny])
    black_text_tag = shadowc3tag(*TEXT_COLOR_THEMES[:black])
    memo = ""
    # Add date received to memo
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      # TODO: Write this date the wrong way round for United States of Americans.
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    # Add map name egg was received on to memo
    map_name = pbGetMapNameFromId(@pokemon.obtain_map)
    map_name = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if map_name && map_name != ""
      map_name = red_text_tag + map_name + black_text_tag
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg received from {1}.", map_name) + "\n"
    else
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg.") + "\n"
    end
    # Draw obtain text
    draw_formatted_text(memo, 232, 86, 268)
    # Add Egg Watch blurb to memo
    draw_text(_INTL("The Egg Watch"), 238, 246)
    egg_state = _INTL("It looks like this Egg will take a long time to hatch.")
    egg_state = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.steps_to_hatch < 10_200
    egg_state = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.steps_to_hatch < 2550
    egg_state = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.steps_to_hatch < 1275
    memo = black_text_tag + egg_state
    # Draw all text
    draw_formatted_text(memo, 232, 278, 268)
  end

  #-----------------------------------------------------------------------------

  def refresh_move_cursor
    # Update cursor positions
    @sprites[:move_cursor].index = @move_index
    @sprites[:selected_move_cursor].index = @swap_move_index
    # Update cursor z values
    if @swap_move_index >= 0
      @sprites[:selected_move_cursor].z = @sprites[:move_cursor].z + 1
      @sprites[:selected_move_cursor].z -= 2 if @move_index != @swap_move_index
    end
  end

  def refresh_ribbon_cursor
    # Scroll ribbons grid to keep cursor on-screen
    sel_ribbon_row = @ribbon_index / RIBBON_COLUMNS
    @ribbon_offset = [@ribbon_offset, sel_ribbon_row].min   # Scroll up
    @ribbon_offset = [@ribbon_offset, sel_ribbon_row - RIBBON_ROWS + 1].max   # Scroll down
    # Update cursor positions
    @sprites[:ribbon_cursor].index = @ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
    @sprites[:selected_ribbon_cursor].index = @swap_ribbon_index - (@ribbon_offset * RIBBON_COLUMNS)
    # Update cursor z values
    if @swap_ribbon_index >= 0
      @sprites[:selected_ribbon_cursor].z = @sprites[:ribbon_cursor].z + 1
      @sprites[:selected_ribbon_cursor].z -= 2 if @ribbon_index != @swap_ribbon_index
    end
  end

  def refresh_markings_cursor
    case @marking_index
    when 6   # OK
      @sprites[:marking_cursor].x = 282
      @sprites[:marking_cursor].y = 244
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    when 7   # Cancel
      @sprites[:marking_cursor].x = 282
      @sprites[:marking_cursor].y = 294
      @sprites[:marking_cursor].src_rect.y = @sprites[:marking_cursor].bitmap.height / 2
    else
      @sprites[:marking_cursor].x = 282 + (62 * (@marking_index % 3))
      @sprites[:marking_cursor].y = 144 + (50 * (@marking_index / 3))
      @sprites[:marking_cursor].src_rect.y = 0
    end
  end

  def refresh_markings_panel
    # Set values to use when drawing the markings panel
    marking_x = 298
    marking_y = 154
    marking_spacing_x = 46 + MARKING_WIDTH
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
    draw_text(_INTL("Mark {1}", @pokemon.name), 368, 102, align: :center, overlay: :marking_overlay)
    draw_text(_INTL("OK"), 368, 254, align: :center, overlay: :marking_overlay)
    draw_text(_INTL("Cancel"), 368, 304, align: :center, overlay: :marking_overlay)
  end

  #-----------------------------------------------------------------------------

  def update_input
    # Check for movement to a new Pokémon
    if Input.trigger?(Input::UP)
      return :go_to_previous_pokemon
    elsif Input.trigger?(Input::DOWN)
      return :go_to_next_pokemon
    end
    # Check for movement to a new page
    if Input.trigger?(Input::LEFT)
      go_to_previous_page
    elsif Input.trigger?(Input::RIGHT)
      go_to_next_page
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    elsif Input.trigger?(Input::ACTION)
      return update_interaction(Input::ACTION)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      case @page
      when :moves
        pbPlayDecisionSE
        return :navigate_moves
      when :ribbons
        pbPlayDecisionSE
        return :navigate_ribbons
      else
        if @mode != :in_battle
          pbPlayDecisionSE
          return :interact_menu
        end
      end
    when Input::ACTION
      @pokemon.play_cry if !@pokemon.egg?
    when Input::BACK
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  # Returns true to finish choosing a move.
  def update_input_move
    # Check for movement to a new move
    if Input.repeat?(Input::UP)
      max_move_index = (@new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
      @move_index -= 1
      @move_index = max_move_index if @move_index < 0   # Wrap around
      if @move_index < Pokemon::MAX_MOVES && @move_index >= @pokemon.numMoves
        @move_index = @pokemon.numMoves - 1   # Wrap around
      end
    elsif Input.repeat?(Input::DOWN)
      max_move_index = (@new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
      @move_index += 1
      @move_index = 0 if @move_index > max_move_index   # Wrap around
      if @move_index < Pokemon::MAX_MOVES && @move_index >= @pokemon.numMoves
        @move_index = (@new_move) ? max_move_index : 0   # Wrap around or go to new move
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      return true if @mode == :choose_move
      if !@pokemon.shadowPokemon?
        if @swap_move_index >= 0
          # End swapping moves
          if @move_index != @swap_move_index
            @pokemon.moves[@move_index], @pokemon.moves[@swap_move_index] = @pokemon.moves[@swap_move_index], @pokemon.moves[@move_index]
          end
          @swap_move_index = -1
          @sprites[:selected_move_cursor].visible = false
          refresh
        else
          # Start swapping moves
          @swap_move_index = @move_index
          @sprites[:selected_move_cursor].visible = true
          refresh_move_cursor
        end
      end
    elsif Input.trigger?(Input::BACK)
      if @mode == :choose_move
        pbPlayCloseMenuSE
        @move_index = -1
        return true
      end
      # Cancel swapping moves, or return true to close
      if @swap_move_index >= 0
        pbPlayCancelSE
        @swap_move_index = -1
        @sprites[:selected_move_cursor].visible = false
      else
        pbPlayCloseMenuSE
        return true
      end
    end
    return false
  end

  # This is used for both general navigating through the list of moves (allowing
  # swapping of moves) and for choosing a move to forget when trying to learn a
  # new one.
  def navigate_moves
    # Setup
    @move_index ||= 0
    @swap_move_index = -1
    @sprites[:pokemon].visible = false if @sprites[:pokemon]
    @sprites[:pokemon_icon].pokemon = @pokemon
    @sprites[:pokemon_icon].visible = true
    @sprites[:move_cursor].visible = true
    refresh_move_cursor
    refresh
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_move_index = @move_index
      break if update_input_move
      if @move_index != old_move_index
        pbPlayCursorSE
        refresh_move_cursor
        refresh
      end
    end
    # Clean up
    if @mode != :choose_move
      @sprites[:move_cursor].visible = false
      @sprites[:pokemon].visible  = true
      @sprites[:pokemon_icon].visible = false
    end
    ret = @move_index
    @move_index = nil
    return ret
  end

  #-----------------------------------------------------------------------------

  def update_input_ribbon
    # Check for movement to a new ribbon
    if Input.repeat?(Input::UP)
      total_rows = [((@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS).floor, RIBBON_ROWS].max
      @ribbon_index -= RIBBON_COLUMNS
      @ribbon_index += total_rows * RIBBON_COLUMNS if @ribbon_index < 0   # Wrap around
    elsif Input.repeat?(Input::DOWN)
      total_rows = [((@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS).floor, RIBBON_ROWS].max
      @ribbon_index += RIBBON_COLUMNS
      @ribbon_index -= total_rows * RIBBON_COLUMNS if @ribbon_index >= total_rows * RIBBON_COLUMNS   # Wrap around
    elsif Input.repeat?(Input::LEFT)
      @ribbon_index -= 1
      @ribbon_index += RIBBON_COLUMNS if (@ribbon_index % RIBBON_COLUMNS) == RIBBON_COLUMNS - 1
    elsif Input.repeat?(Input::RIGHT)
      @ribbon_index += 1
      @ribbon_index -= RIBBON_COLUMNS if (@ribbon_index % RIBBON_COLUMNS) == 0
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @swap_ribbon_index >= 0
        # End swapping ribbons
        pbPlayDecisionSE
        if @ribbon_index != @swap_ribbon_index
          @pokemon.ribbons[@ribbon_index], @pokemon.ribbons[@swap_ribbon_index] = @pokemon.ribbons[@swap_ribbon_index], @pokemon.ribbons[@ribbon_index]
          @pokemon.ribbons.compact!   # Don't leave gaps
          if @ribbon_index >= @pokemon.ribbons.length
            @ribbon_index = @pokemon.ribbons.length - 1
          end
        end
        @swap_ribbon_index = -1
        @sprites[:selected_ribbon_cursor].visible = false
        refresh
      elsif @pokemon.ribbons[@ribbon_index]
        # Start swapping ribbons
        pbPlayDecisionSE
        @swap_ribbon_index = @ribbon_index
        @sprites[:selected_ribbon_cursor].visible = true
        refresh_ribbon_cursor
      end
    elsif Input.trigger?(Input::BACK)
      # Cancel swapping ribbons, or return true to close
      if @swap_ribbon_index >= 0
        pbPlayCancelSE
        @swap_ribbon_index = -1
        @sprites[:selected_ribbon_cursor].visible = false
      else
        pbPlayCloseMenuSE
        return true
      end
    end
    return false
  end

  def navigate_ribbons
    # Setup
    @ribbon_index = @ribbon_offset * RIBBON_COLUMNS
    @swap_ribbon_index = -1
    total_rows = [(@pokemon.ribbons.length + RIBBON_COLUMNS - 1) / RIBBON_COLUMNS, RIBBON_ROWS].max
    @sprites[:ribbon_cursor].visible = true
    refresh_ribbon_cursor
    refresh
    # Navigate loop
    loop do
      @sprites[:up_arrow].visible = (@ribbon_offset > 0)
      @sprites[:down_arrow].visible = (@ribbon_offset < total_rows - RIBBON_ROWS)
      Graphics.update
      Input.update
      update_visuals
      old_ribbon_index = @ribbon_index
      old_swap_ribbon_index = @swap_ribbon_index
      break if update_input_ribbon
      if @ribbon_index != old_ribbon_index || @swap_ribbon_index != old_swap_ribbon_index
        pbPlayCursorSE if @swap_ribbon_index == old_swap_ribbon_index
        refresh_ribbon_cursor
        refresh
      end
    end
    # Clean up
    @sprites[:ribbon_cursor].visible = false
    @sprites[:up_arrow].visible      = false
    @sprites[:down_arrow].visible    = false
    @ribbon_index = nil
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
    # Setup
    @sprites[:marking_bg].visible      = true
    @sprites[:marking_overlay].visible = true
    @sprites[:marking_cursor].visible  = true
    @markings = @pokemon.markings.clone
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
    @pokemon.markings = @markings if @marking_index >= 0
    @marking_index = nil
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokemonSummary < UI::BaseScreen
  attr_reader   :party, :mode
  attr_accessor :party_index, :pokemon

  SCREEN_ID = :summary_screen

  # party is an array of Pokemon objects or a single Pokemon object.
  # mode is :normal or :choose_move or :in_battle.
  # If mode is :choose_move, new_move is either nil or a move ID.
  def initialize(party, party_index = 0, mode: :normal, new_move: nil)
    @party       = (party.is_a?(Array)) ? party : [party]
    @party_index = party_index
    @pokemon     = @party[@party_index]
    @mode        = mode
    @new_move    = (new_move) ? Pokemon::Move.new(new_move) : nil
    super()
    @result = @party_index if @result.nil?
  end

  def initialize_visuals
    @visuals = UI::PokemonSummaryVisuals.new(@party, @party_index, @mode, @new_move)
  end

  def start_screen
    super   # Fade in
    @visuals.play_pokemon_cry if @mode != :choose_move
  end

  #-----------------------------------------------------------------------------

  def main
    if @mode == :choose_move
      pbSEPlay("GUI menu open")
      start_screen
      @result = perform_action(:navigate_moves)
      end_screen
      return
    end
    super
  end
end

#===============================================================================
# Actions that can be triggered in the Pokémon summary screen.
#===============================================================================
UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :go_to_previous_pokemon,
  :effect => proc { |screen|
    if screen.party_index > 0
      new_index = screen.party_index
      loop do
        new_index -= 1
        break if screen.party[new_index]
        break if new_index <= 0
      end
      if new_index != screen.party_index && screen.party[new_index]
        # NOTE: @visuals.set_party_index plays an SE.
        screen.party_index = new_index
        screen.pokemon = screen.party[screen.party_index]
        screen.visuals.set_party_index(screen.party_index)
      end
    end
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :go_to_next_pokemon,
  :effect => proc { |screen|
    if screen.party_index < screen.party.length - 1
      new_index = screen.party_index
      loop do
        new_index += 1
        break if screen.party[new_index]
        break if new_index >= screen.party.length - 1
      end
      if new_index != screen.party_index && screen.party[new_index]
        # NOTE: @visuals.set_party_index plays an SE.
        screen.party_index = new_index
        screen.pokemon = screen.party[screen.party_index]
        screen.visuals.set_party_index(screen.party_index)
      end
    end
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :navigate_moves,
  :returns_value => true,
  :effect => proc { |screen|
    move_index = screen.visuals.navigate_moves
    next move_index if screen.mode == :choose_move
    screen.refresh
    next nil
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :navigate_ribbons,
  :effect => proc { |screen|
    screen.visuals.navigate_ribbons
    screen.refresh
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :marking,
  :effect => proc { |screen|
    screen.visuals.navigate_markings
    screen.refresh
  }
)

# Shows a choice menu using the MenuHandlers options below.
UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :interact_menu,
  :menu      => :summary_screen_interact,
  :condition => proc { |screen| next screen.mode != :in_battle }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :give_item,
  :effect => proc { |screen|
    item = nil
    pbFadeOutIn do
      bag_scene = PokemonBag_Scene.new
      bag_screen = PokemonBagScreen.new(bag_scene, $bag)
      item = bag_screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
    end
    screen.refresh if pbGiveItemToPokemon(item, screen.pokemon, screen, screen.party_index)
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :take_item,
  :effect => proc { |screen|
    screen.refresh if pbTakeItemFromPokemon(screen.pokemon, screen)
  }
)

UIActionHandlers.add(UI::PokemonSummary::SCREEN_ID, :pokedex,
  :effect => proc { |screen|
    $player.pokedex.register_last_seen(screen.pokemon)
    pbFadeOutIn do
      dex_scene = PokemonPokedexInfo_Scene.new
      dex_screen = PokemonPokedexInfoScreen.new(dex_scene)
      dex_screen.pbStartSceneSingle(screen.pokemon.species)
    end
  }
)

#===============================================================================
# Menu options for choice menus that exist in the Pokémon summary screen.
#===============================================================================
MenuHandlers.add(:summary_screen_interact, :give_item, {
  "name"      => _INTL("Give item"),
  "order"     => 10,
  "condition" => proc { |screen| next !screen.pokemon.egg? }
})

MenuHandlers.add(:summary_screen_interact, :take_item, {
  "name"      => _INTL("Take item"),
  "order"     => 20,
  "condition" => proc { |screen| next !screen.pokemon.egg? && screen.pokemon.hasItem? }
})

MenuHandlers.add(:summary_screen_interact, :pokedex, {
  "name"      => _INTL("View Pokédex"),
  "order"     => 30,
  "condition" => proc { |screen| next !screen.pokemon.egg? && $player.has_pokedex }
})

MenuHandlers.add(:summary_screen_interact, :marking, {
  "name"      => _INTL("Mark"),
  "order"     => 40
})

MenuHandlers.add(:summary_screen_interact, :cancel, {
  "name"      => _INTL("Cancel"),
  "order"     => 9999
})

#===============================================================================
#
#===============================================================================
def pbChooseMove(pokemon, variableNumber, nameVarNumber)
  return if !pokemon
  ret = -1
  pbFadeOutIn do
    screen = UI::PokemonSummary.new(pokemon, mode: :choose_move)
    ret = screen.result
  end
  $game_variables[variableNumber] = ret
  if ret >= 0
    $game_variables[nameVarNumber] = pokemon.moves[ret].name
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end
