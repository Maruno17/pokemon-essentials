#===============================================================================
#
#===============================================================================
class UI::PokedexEntryVisuals < UI::BaseVisuals
  attr_reader :index
  attr_reader :region

  GRAPHICS_FOLDER     = "Pokedex/"   # Subfolder in Graphics/UI
  BACKGROUND_FILENAME = "bg_entry"
  TEXT_COLOR_THEMES   = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :white        => [Color.new(248, 248, 248), Color.new(0, 0, 0)],
  }
  POKEDEX_TYPE_ICON_SIZE = [96, 32]
  MAP_TOP_LEFT           = [16, 48]
  MAP_DISPLAY_SIZE       = [480, 320]
  AREA_HIGHLIGHT_COLORS  = [Color.new(0, 248, 248), Color.new(192, 248, 248)]   # Fill, outline
  AREA_MOVE_TIME         = 0.08   # In seconds

  #-----------------------------------------------------------------------------

  PAGE_HANDLERS = HandlerHash.new
  PAGE_HANDLERS.add(:info, {
    :order      => 10,
    :icon_index => 0,
    :draw       => [
      :draw_common_page_contents,
      :draw_owned_icon,
      :draw_species_number_and_name,
      :draw_shiny_icon,
      :draw_category_text,
      :draw_footprint,
      :draw_species_types,
      :draw_height,
      :draw_weight,
      :draw_entry_text,
      :draw_input_helpers
    ]
  })
  PAGE_HANDLERS.add(:area, {
    :order       => 20,
    :icon_index  => 1,
    :should_show => proc { |visuals| next visuals.mode != :new_entry },
    :draw        => [
      :draw_common_page_contents,
      :draw_area_region_name,
      :draw_area_species_name,
      :draw_area_unknown,
      :draw_area_highlights,
      :draw_area_player,
      :draw_input_helpers
    ]
  })
  PAGE_HANDLERS.add(:forms, {
    :order       => 30,
    :icon_index  => 2,
    :should_show => proc { |visuals| next visuals.mode != :new_entry },
    :draw        => [
      :draw_common_page_contents,
      :draw_forms_form_name,
      :draw_input_helpers
    ]
  })

  #-----------------------------------------------------------------------------

  def initialize(dex, initial_index = 0, mode = :normal, region = -1)
    @dex   = dex
    @index = initial_index
    @mode  = mode
    @page  = all_pages[0]
    get_unlocked_regions
    @region = region
    if @region < 0 || !@unlocked_regions.include?(@region)
      @region = ($game_map.metadata&.town_map_position || [0])[0]   # Current region
      @region = @unlocked_regions.first if !@unlocked_regions.include?(@region)
    end
    @town_map_data = GameData::TownMap.get(@region)
    set_species
    super()
  end

  def initialize_bitmaps
    super
    @bitmaps[:page_arrows]   = AnimatedBitmap.new(graphics_folder + "entry_page_arrows")
    @bitmaps[:page_icons]    = AnimatedBitmap.new(graphics_folder + _INTL("entry_page_icons"))
    @bitmaps[:owned]         = AnimatedBitmap.new(graphics_folder + "icon_own")
    @bitmaps[:types]         = AnimatedBitmap.new(graphics_folder + _INTL("types"))
    @bitmaps[:area_navigate] = AnimatedBitmap.new(graphics_folder + "overlay_area_navigate")
    @bitmaps[:area_region]   = AnimatedBitmap.new(graphics_folder + "overlay_area_region")
    @bitmaps[:area_unknown]  = AnimatedBitmap.new(graphics_folder + "overlay_area_unknown")
    @bitmaps[:player]        = AnimatedBitmap.new(GameData::TrainerType.player_map_icon_filename($player.trainer_type))
  end

  def initialize_background
    super
    addBackgroundPlane(@sprites, :page_background, self.class::GRAPHICS_FOLDER + page_background_filename, @viewport)
    @sprites[:page_background].z = 100
  end

  def initialize_sprites
    initialize_sprites_info
    if @mode != :new_entry
      initialize_sprites_area
      initialize_sprites_forms
    end
    refresh_sprite_species
  end

  def initialize_sprites_info
    # Pokémon sprite
    @sprites[:pokemon] = PokemonSprite.new(@viewport)
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].x = 104
    @sprites[:pokemon].y = 136
    @sprites[:pokemon].z = 500
  end

  def initialize_sprites_area
    # Town Map graphic
    @sprites[:area_map]&.dispose
    add_icon_sprite(:area_map, *MAP_TOP_LEFT, UI_FOLDER + "Town Map/#{@town_map_data.filename}")
    @sprites[:area_map].z = 90
    @sprites[:area_map].src_rect.width = MAP_DISPLAY_SIZE[0]
    @sprites[:area_map].src_rect.height = MAP_DISPLAY_SIZE[1]
    # Town Map extras
    @sprites[:area_map_extras]&.dispose
    @sprites[:area_map_extras] = BitmapSprite.new(@sprites[:area_map].width, @sprites[:area_map].height, @viewport)
    @sprites[:area_map_extras].x = @sprites[:area_map].x
    @sprites[:area_map_extras].y = @sprites[:area_map].y
    @sprites[:area_map_extras].z = @sprites[:area_map].z + 1
    @sprites[:area_map_extras].src_rect.width = MAP_DISPLAY_SIZE[0]
    @sprites[:area_map_extras].src_rect.height = MAP_DISPLAY_SIZE[1]
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @region
      next if graphic[1] <= 0 || !$game_switches[graphic[1]]
      draw_image(UI_FOLDER + "Town Map/#{graphic[4]}",
                 (graphic[2] * @town_map_data.point_size[0]) + @town_map_data.margins[0],
                 (graphic[3] * @town_map_data.point_size[1]) + @town_map_data.margins[1],
                 overlay: :area_map_extras)
    end
    # Area highlights
    @sprites[:area_highlights]&.dispose
    @sprites[:area_highlights] = BitmapSprite.new(@sprites[:area_map].width, @sprites[:area_map].height, @viewport)
    @sprites[:area_highlights].x = @sprites[:area_map].x
    @sprites[:area_highlights].y = @sprites[:area_map].y
    @sprites[:area_highlights].z = @sprites[:area_map].z + 2
    @sprites[:area_highlights].src_rect.width = MAP_DISPLAY_SIZE[0]
    @sprites[:area_highlights].src_rect.height = MAP_DISPLAY_SIZE[1]
    # Player's location
    @sprites[:area_player]&.dispose
    @sprites[:area_player] = BitmapSprite.new(@sprites[:area_map].width, @sprites[:area_map].height, @viewport)
    @sprites[:area_player].x = @sprites[:area_map].x
    @sprites[:area_player].y = @sprites[:area_map].y
    @sprites[:area_player].z = @sprites[:area_map].z + 3
    @sprites[:area_player].src_rect.width = MAP_DISPLAY_SIZE[0]
    @sprites[:area_player].src_rect.height = MAP_DISPLAY_SIZE[1]
    # Arrows
    add_animated_arrow(:area_up, (Graphics.width - 28) / 2, 30, :up)
    @sprites[:area_up].z = 600
    add_animated_arrow(:area_down, (Graphics.width - 28) / 2, Graphics.height - 58, :down)
    @sprites[:area_down].z = 600
    add_animated_arrow(:area_left, -2, (Graphics.height + 4) / 2, :left)
    @sprites[:area_left].z = 600
    add_animated_arrow(:area_right, Graphics.width - 38, (Graphics.height + 4) / 2, :right)
    @sprites[:area_right].z = 600
  end

  def initialize_sprites_forms
    # Front sprite
    @sprites[:front_form] = PokemonSprite.new(@viewport)
    @sprites[:front_form].setOffset(PictureOrigin::CENTER)
    @sprites[:front_form].x = 130
    @sprites[:front_form].y = 158
    @sprites[:front_form].z = 500
    # Back sprite
    @sprites[:back_form] = PokemonSprite.new(@viewport)
    @sprites[:back_form].setOffset(PictureOrigin::BOTTOM)
    @sprites[:back_form].x = 382   # y is set below as it depends on metrics
    @sprites[:back_form].z = 500
    # Menu icon
    @sprites[:icon_form] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites[:icon_form].setOffset(PictureOrigin::CENTER)
    @sprites[:icon_form].x = 82
    @sprites[:icon_form].y = 328
    @sprites[:icon_form].z = 500
    # Up arrow
    add_animated_arrow(:form_up, (Graphics.width - 28) / 2, 268, :up)
    @sprites[:form_up].z = 600
    # Down arrow
    add_animated_arrow(:form_down, (Graphics.width - 28) / 2, 348, :down)
    @sprites[:form_down].z = 600
  end

  #-----------------------------------------------------------------------------

  def page_background_filename
    ret = BACKGROUND_FILENAME + "_" + @page.to_s
    return ret
  end

  #-----------------------------------------------------------------------------

  def all_pages
    ret = []
    PAGE_HANDLERS.each do |key, hash|
      next if hash[:should_show] && !hash[:should_show].call(self)
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
    pbPlayCursorSE
    center_map_cursor if @page == :area && !@cursor_pos
    refresh
  end

  def go_to_previous_page
    pages = all_pages
    return if pages.length == 1
    page_index = pages.index(@page)
    return if page_index.nil? || page_index == 0
    @page = pages[page_index - 1]
    pbPlayCursorSE
    center_map_cursor if @page == :area && !@cursor_pos
    refresh
  end

  def set_dex_index(new_index)
    return if @index == new_index
    # Set the new species
    @index = new_index
    set_species
    # Play sound effect
    (@page == :info) ? play_species_cry : pbPlayCursorSE
    refresh_sprite_species
    refresh
  end

  # Determines the species to show based on @index.
  def set_species
    @dex_number = (@dex[@index].is_a?(Array)) ? @dex[@index][0] : -1
    @species    = (@dex[@index].is_a?(Array)) ? @dex[@index][1] : @dex[@index]
    @gender, @form, @shiny = $player.pokedex.last_form_seen(@species)
    @shiny = false if !Settings::SHOW_SHINY_SPRITES_IN_POKEDEX
    # Get other useful information for the currently viewed species
    @species_data = GameData::Species.get_species_form(@species, @form)
    get_viewable_forms
    get_encounter_maps
  end

  def play_species_cry
    pbSEStop
    Pokemon.play_cry(@species, @form)
  end

  def owned_species?
    # NOTE: This intentionally only checks if you have owned the species and not
    #       the specific form.
    return $player.owned?(@species)
  end

  def map_total_size
    map_size = @town_map_data.size
    point_size = @town_map_data.point_size
    margins = @town_map_data.margins
    return (map_size[0] * point_size[0]) + (margins[0] * 2), (map_size[1] * point_size[1]) + (margins[1] * 2)
  end

  # Returns whether the Town Map is larger than MAP_DISPLAY_SIZE.
  def map_scrollable?
    map_size = map_total_size
    return map_size[0] > MAP_DISPLAY_SIZE[0] || map_size[1] > MAP_DISPLAY_SIZE[1]
  end

  def map_scrollable_in_direction?(dir)
    case dir
    when :up
      return true if @sprites[:area_map].src_rect.y > 0
    when :down
      return true if @sprites[:area_map].src_rect.y + @sprites[:area_map].src_rect.height < map_total_size[1]
    when :left
      return true if @sprites[:area_map].src_rect.x > 0
    when :right
      return true if @sprites[:area_map].src_rect.x + @sprites[:area_map].src_rect.width < map_total_size[0]
    end
    return false
  end

  # Positions the map so that it is centred on the player (or on the middle of
  # the map if the player isn't in that region).
  def center_map_cursor
    player_pos = $game_map.metadata&.town_map_position
    if player_pos && player_pos[0] == @region
      @cursor_pos = [player_pos[1], player_pos[2]]
    else
      map_size = @town_map_data.size
      @cursor_pos = [(map_size[0] - 1) / 2, (map_size[1] - 1) / 2]
    end
    point_size = @town_map_data.point_size
    margins = @town_map_data.margins
    @sprites[:area_map].src_rect.x = (@cursor_pos[0] * point_size[0]) + margins[0] + (point_size[0] / 2) - (MAP_DISPLAY_SIZE[0] / 2)
    @sprites[:area_map].src_rect.y = (@cursor_pos[1] * point_size[1]) + margins[1] + (point_size[1] / 2) - (MAP_DISPLAY_SIZE[1] / 2)
    clamp_map_position
    sync_map_sprites
  end

  def clamp_map_position
    map_full_size = map_total_size
    extent = [map_full_size[0] - MAP_DISPLAY_SIZE[0], map_full_size[1] - MAP_DISPLAY_SIZE[1]]
    @sprites[:area_map].src_rect.x = extent[0] if @sprites[:area_map].src_rect.x > extent[0]
    @sprites[:area_map].src_rect.y = extent[1] if @sprites[:area_map].src_rect.y > extent[1]
    @sprites[:area_map].src_rect.x = 0 if @sprites[:area_map].src_rect.x < 0
    @sprites[:area_map].src_rect.y = 0 if @sprites[:area_map].src_rect.y < 0
  end

  def sync_map_sprites
    @sprites[:area_map_extras].src_rect.x = @sprites[:area_map].src_rect.x
    @sprites[:area_map_extras].src_rect.y = @sprites[:area_map].src_rect.y
    @sprites[:area_highlights].src_rect.x = @sprites[:area_map].src_rect.x
    @sprites[:area_highlights].src_rect.y = @sprites[:area_map].src_rect.y
    @sprites[:area_player].src_rect.x     = @sprites[:area_map].src_rect.x
    @sprites[:area_player].src_rect.y     = @sprites[:area_map].src_rect.y
  end

  #-----------------------------------------------------------------------------

  def get_unlocked_regions
    @unlocked_regions = []
    GameData::MapMetadata.each do |map_data|
      next if !map_data.town_map_position || @unlocked_regions.include?(map_data.town_map_position[0])
      next if !$PokemonGlobal.visitedMaps[map_data.id]
      @unlocked_regions.push(map_data.town_map_position[0])
    end
    @unlocked_regions.sort!
    @unlocked_regions.push(0) if @unlocked_regions.empty?
  end

  # NOTE: Only form 0 can have gender differences. They will be listed with a
  #       form name of "Male" and "Female". Alternate forms with gender
  #       differences should have each gender being a different form with their
  #       form names containing their gender.
  def get_viewable_forms
    @viewable_forms ||= []
    @viewable_forms.clear
    @form_index = 0
    has_multiple_forms = false
    has_gender_differences = (GameData::Species.front_sprite_filename(@species, 0, 0) != GameData::Species.front_sprite_filename(@species, 0, 1))
    # Find all genders/forms/shininesses of @species that have been seen
    GameData::Species.each_form_for_species(@species) do |sp|
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)   # Unnamed form
      next if sp.pokedex_form != sp.form   # Aliased form
      has_multiple_forms = true if sp.form > 0
      if sp.single_gendered?   # Or genderless
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        [false, true].each do |real_shiny|
          next if !$player.pokedex.seen_form?(@species, real_gender, sp.form, real_shiny) && !Settings::POKEDEX_SHOWS_ALL_FORMS
          record_gender = real_gender
          record_gender = 2 if sp.gender_ratio == :Genderless
          record_shiny = (Settings::SHOW_SHINY_SPRITES_IN_POKEDEX) ? real_shiny : false
          @viewable_forms.push([sp.form_name, record_gender, sp.form, record_shiny])
        end
        next
      end
      has_form_gender_differences = (GameData::Species.front_sprite_filename(@species, sp.form, 0) != GameData::Species.front_sprite_filename(@species, sp.form, 1))
      if has_form_gender_differences
        2.times do |real_gender|
          [false, true].each do |real_shiny|
            next if !$player.pokedex.seen_form?(@species, real_gender, sp.form, real_shiny) && !Settings::POKEDEX_SHOWS_ALL_FORMS
            record_shiny = (Settings::SHOW_SHINY_SPRITES_IN_POKEDEX) ? real_shiny : false
            @viewable_forms.push([sp.form_name, real_gender, sp.form, record_shiny])
          end
        end
      else
        2.times do |real_gender|
          found_for_gender = false
          [false, true].each do |real_shiny|
            next if !$player.pokedex.seen_form?(@species, real_gender, sp.form, real_shiny) && !Settings::POKEDEX_SHOWS_ALL_FORMS
            found_for_gender = true
            record_shiny = (Settings::SHOW_SHINY_SPRITES_IN_POKEDEX) ? real_shiny : false
            @viewable_forms.push([sp.form_name || _INTL("One Form"), 0, sp.form, record_shiny])
          end
          break if found_for_gender
        end
      end
    end
    # Sort all entries
    @viewable_forms.uniq!
    @viewable_forms.sort! do |a, b|
      if a[2] == b[2]   # Same form
        if a[1] == b[1]   # Same gender
          (a[3] ? 1 : 0) <=> (b[3] ? 1 : 0)   # Sort by shininess
        else
          a[1] <=> b[1]   # Sort by gender
        end
      else
        a[2] <=> b[2]   # Sort by form
      end
    end
    # Create form names for entries if they don't already exist
    @viewable_forms.each_with_index do |entry, i|
      if !entry[0]   # Doesn't have a form name (male/female/genderless form 0 only)
        case entry[1]
        when 0 then entry[0] = _INTL("Male")
        when 1 then entry[0] = _INTL("Female")
        else
          entry[0] = (has_multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
      @form_index = i if entry[1] == @gender && entry[2] == @form && entry[3] == @shiny
    end
  end

  def get_encounter_maps
    @encounter_maps ||= []   # [region][map ID, [coords of squares occupied]]
    @encounter_maps.clear
    @town_map_invalid_points ||= []
    GameData::Encounter.each_with_species(@species, $PokemonGlobal.encounter_version) do |enc_data|
      add_encounter_for_map(enc_data.map)
    end
    each_active_roamer do |roamer, i|
      add_encounter_for_map($PokemonGlobal.roamPosition[i]) if roamer[:species] == @species
    end
  end

  def add_encounter_for_map(map_id)
    # Ensure encounter map is shown in Town Map and is displayable in Pokédex
    map_metadata = GameData::MapMetadata.try_get(map_id)
    return if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
    map_pos = map_metadata.town_map_position
    return if !map_pos   # Map isn't in any region
    # Get the size and shape of the encounter map in the Town Map
    map_size = map_metadata.town_map_size
    map_width = 1
    map_height = 1
    map_shape = "1"
    if map_size && map_size[0] && map_size[0] > 0   # Map occupies multiple points
      map_width = map_size[0]
      map_shape = map_size[1]
      map_height = (map_shape.length.to_f / map_width).ceil
    end
    # Ensure we know which squares in the encounter map's region are hidden
    if !@town_map_invalid_points[map_pos[0]]
      @town_map_invalid_points[map_pos[0]] = []
      this_town_map_data = GameData::TownMap.get(map_pos[0])
      if this_town_map_data
        this_town_map_data.points.each do |point|
          next if !point[:switch] || $game_switches[point[:switch]]   # Point is visible
          @town_map_invalid_points[map_pos[0]].push(point[:position])
        end
      end
    end
    # Remember encounter map's info
    @encounter_maps[map_pos[0]] ||= []
    map_array = [map_id, []]
    @encounter_maps[map_pos[0]].push(map_array)
    # Mark each visible point covered by the map as containing the area
    map_width.times do |i|
      map_height.times do |j|
        next if map_shape[i + (j * map_width), 1].to_i == 0   # Point isn't part of map
        next if @town_map_invalid_points[map_pos[0]].include?([map_pos[1] + i, map_pos[2] + j])   # Point isn't visible
        map_array[1].push([map_pos[1] + i, map_pos[2] + j])
      end
    end
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    refresh_background
    refresh_sprite_visibility
    draw_page_contents
  end

  def refresh_background
    @sprites[:background].setBitmap(graphics_folder + background_filename)
    @sprites[:page_background].setBitmap(graphics_folder + page_background_filename)
  end

  def refresh_sprite_species
    @sprites[:pokemon].setSpeciesBitmap(@species, @gender, @form, @shiny)
    @sprites[:front_form]&.setSpeciesBitmap(@species, @gender, @form, @shiny)
    if @sprites[:back_form]
      @sprites[:back_form].setSpeciesBitmap(@species, @gender, @form, @shiny, false, true)
      metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
      @sprites[:back_form].y = 256 + metrics_data.back_sprite[1] * 2
    end
    @sprites[:icon_form]&.pbSetParams(@species, @gender, @form, @shiny)
  end

  def refresh_sprite_visibility
    @sprites[:pokemon].visible     = (@page == :info)
    @sprites[:area_map]&.visible        = (@page == :area)
    @sprites[:area_map_extras]&.visible = (@page == :area)
    @sprites[:area_highlights]&.visible = (@page == :area)
    @sprites[:area_player]&.visible     = (@page == :area)
    @sprites[:front_form]&.visible = (@page == :forms)
    @sprites[:back_form]&.visible  = (@page == :forms)
    @sprites[:icon_form]&.visible  = (@page == :forms)
  end

  def draw_page_contents
    PAGE_HANDLERS[@page][:draw].each { |method| self.send(method) }
  end

  def refresh_shown_form
    refresh_overlay
    draw_page_contents
    refresh_sprite_species
  end

  #-----------------------------------------------------------------------------

  def draw_common_page_contents
    draw_page_icons
  end

  def draw_page_icons
    arrow_width = 32
    arrow_height = 32
    icon_width = 80
    icon_height = 32
    start_x = 14
    start_y = 0
    spacing_x = 0
    pages = all_pages
    page_index = pages.index(@page) || 0
    page_src_index = PAGE_HANDLERS[@page][:icon_index] || 0
    can_go_left = (page_index > 0)
    can_go_right = (page_index < pages.length - 1)
    # Draw left arrow
    if can_go_left || can_go_right
      draw_image(@bitmaps[:page_arrows], start_x, start_y,
                 arrow_width * (can_go_left ? 2 : 0), page_src_index * arrow_height,
                 arrow_width, arrow_height)
    end
    # Draw page icons
    pages.each_with_index do |this_page, i|
      this_src_index = PAGE_HANDLERS[this_page][:icon_index] || 0
      icon_x = start_x + arrow_width + (i * (icon_width + spacing_x))
      draw_image(@bitmaps[:page_icons], icon_x, start_y,
                 this_src_index * icon_width, page_src_index * icon_height, icon_width, icon_height)
    end
    # Draw right arrow
    if can_go_left || can_go_right
      arrow_x = start_x + arrow_width + (pages.length * icon_width) + ((pages.length - 1) * spacing_x)
      draw_image(@bitmaps[:page_arrows], arrow_x, start_y,
                 arrow_width * (can_go_right ? 3 : 1), page_src_index * arrow_height,
                 arrow_width, arrow_height)
    end
  end

  def draw_input_helpers
    case @page
    when :area
      # Navigate map
      if @sub_mode == :scroll_map || map_scrollable?
        draw_image(@bitmaps[:area_navigate], 0, 40)
        input = (@sub_mode == :scroll_map) ? Input::BACK : Input::USE
        draw_input_icon(2, 44, input)
      end
      # Change region
      if @unlocked_regions.length > 1
        draw_input_icon(Graphics.width - 34, 44, Input::ACTION)
      end
    when :forms
      # Choose form
      if @sub_mode == :forms || @viewable_forms.length > 1
        input = (@sub_mode == :forms) ? Input::BACK : Input::USE
        draw_input_icon(Graphics.width - 78, Graphics.height - 46, input)
      end
    end
  end

  def draw_owned_icon
    draw_image(@bitmaps[:owned], 212, 44) if owned_species?
  end

  def draw_species_number_and_name
    text_x = 246
    spacing = 12
    # Draw species number
    index_text = (@dex_number < 0) ? "???" : sprintf("%03d", @dex_number)
    draw_text(index_text, text_x, 48, theme: :white)
    # Draw species name
    draw_text(@species_data.name, text_x + @sprites[:overlay].bitmap.text_size(index_text).width + spacing, 48, theme: :white)
  end

  def draw_shiny_icon
    draw_image(UI_FOLDER + "shiny", 218, 82) if @shiny
  end

  def draw_category_text
    category_text = (owned_species?) ? @species_data.category : "?????"
    draw_text(_INTL("{1} Pokémon", category_text), 246, 80)
  end

  def draw_footprint
    return if !owned_species?
    footprint_file = GameData::Species.footprint_filename(@species, @form)
    draw_image(footprint_file, 226, 138) if footprint_file
  end

  # x and y are the top left corner of the first type icon.
  def draw_species_types
    return if !owned_species?
    icon_x = 296
    icon_y = 120
    spacing = 4
    @species_data.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_x = icon_x + ((POKEDEX_TYPE_ICON_SIZE[0] + spacing) * i)
      draw_image(@bitmaps[:types], type_x, icon_y,
                 0, type_number * POKEDEX_TYPE_ICON_SIZE[1], *POKEDEX_TYPE_ICON_SIZE)
    end
  end

  def draw_height
    draw_text(_INTL("Height"), 314, 164)
    value_x = (Translation.imperial_measurements?) ? 464 : 470
    value_y = 164
    if owned_species?
      height = @species_data.height
      if Translation.imperial_measurements?
        inches = (height / 0.254).round
        inch = sprintf("%02d", inches % 12)
        draw_text(_INTL("{1}'{2}''", (inches / 12).to_s_formatted, inch), value_x, value_y, align: :right)
      else
        hei = sprintf("%.1f", height / 10.0)
        draw_text(_INTL("{1} m", hei.format_number), value_x, value_y, align: :right)
      end
    else
      if Translation.imperial_measurements?
        draw_text(_INTL("???'??''"), value_x, value_y, align: :right)
      else
        draw_text(_INTL("????.? m"), value_x, value_y, align: :right)
      end
    end
  end

  def draw_weight
    draw_text(_INTL("Weight"), 314, 196)
    value_x = (Translation.imperial_measurements?) ? 494 : 482
    value_y = 196
    if owned_species?
      weight = @species_data.weight
      if Translation.imperial_measurements?
        pounds = (weight / 0.45359).round
        wei = sprintf("%.1f", pounds / 10.0)
        draw_text(_INTL("{1} lbs.", wei.format_number), value_x, value_y, align: :right)
      else
        wei = sprintf("%.1f", weight / 10.0)
        draw_text(_INTL("{1} kg", wei.format_number), value_x, value_y, align: :right)
      end
    else
      if Translation.imperial_measurements?
        draw_text(_INTL("????.? lbs."), value_x, value_y, align: :right)
      else
        draw_text(_INTL("????.? kg"), value_x, value_y, align: :right)
      end
    end
  end

  def draw_entry_text
    return if !owned_species?
    draw_paragraph_text(@species_data.pokedex_entry, 40, 246, Graphics.width - 80, 4)
  end

  def draw_area_region_name
    return if @unlocked_regions.length == 1
    draw_image(@bitmaps[:area_region], Graphics.width - @bitmaps[:area_region].width, 40)
    draw_text(@town_map_data.name, Graphics.width - (@bitmaps[:area_region].width / 2) - 4, 50, align: :center)
  end

  def draw_area_species_name
    draw_text(@species_data.name, Graphics.width / 2, 358, align: :center)
  end

  def draw_area_unknown
    return if @encounter_maps[@region] && !@encounter_maps[@region].empty?
    draw_image(@bitmaps[:area_unknown], (Graphics.width - @bitmaps[:area_unknown].width) / 2, 188)
    draw_text(_INTL("Area unknown"), Graphics.width / 2, (Graphics.height / 2) + 6, align: :center)
  end

  def draw_area_highlights
    @sprites[:area_highlights].bitmap.clear
    point_size = @town_map_data.point_size
    margins = @town_map_data.margins
    @encounter_maps[@region]&.each do |map|
      map[1].each do |square|
        # Fill square
        @sprites[:area_highlights].bitmap.fill_rect(
          (square[0] * point_size[0]) + margins[0],
          (square[1] * point_size[1]) + margins[1],
          *point_size, AREA_HIGHLIGHT_COLORS[0]
        )
        # Draw top edge
        if @encounter_maps[@region].none? { |map| map[1].include?([square[0], square[1] - 1]) }
          @sprites[:area_highlights].bitmap.fill_rect(
            (square[0] * point_size[0]) + margins[0],
            (square[1] * point_size[1]) + margins[1] - 2,
            point_size[0], 2, AREA_HIGHLIGHT_COLORS[1]
          )
        end
        # Draw bottom edge
        if @encounter_maps[@region].none? { |map| map[1].include?([square[0], square[1] + 1]) }
          @sprites[:area_highlights].bitmap.fill_rect(
            (square[0] * point_size[0]) + margins[0],
            (square[1] * point_size[1]) + margins[1] + point_size[1],
            point_size[0], 2, AREA_HIGHLIGHT_COLORS[1]
          )
        end
        # Draw left edge
        if @encounter_maps[@region].none? { |map| map[1].include?([square[0] - 1, square[1]]) }
          @sprites[:area_highlights].bitmap.fill_rect(
            (square[0] * point_size[0]) + margins[0] - 2,
            (square[1] * point_size[1]) + margins[1],
            2, point_size[1], AREA_HIGHLIGHT_COLORS[1]
          )
        end
        # Draw right edge
        if @encounter_maps[@region].none? { |map| map[1].include?([square[0] + 1, square[1]]) }
          @sprites[:area_highlights].bitmap.fill_rect(
            (square[0] * point_size[0]) + margins[0] + point_size[0],
            (square[1] * point_size[1]) + margins[1],
            2, point_size[1], AREA_HIGHLIGHT_COLORS[1]
          )
        end
      end
    end
  end

  def draw_area_player
    @sprites[:area_player].bitmap.clear
    player_pos = $game_map.metadata&.town_map_position
    return if !player_pos || player_pos[0] != @region
    point_size = @town_map_data.point_size
    margins = @town_map_data.margins
    draw_image(@bitmaps[:player],
               (player_pos[1] * point_size[0]) + margins[0] + ((point_size[0] - @bitmaps[:player].width) / 2),
               (player_pos[2] * point_size[1]) + margins[1] + ((point_size[1] - @bitmaps[:player].height) / 2),
               overlay: :area_player)
  end

  def draw_forms_form_name
    text_center_x = Graphics.width / 2
    draw_text(@species_data.name, text_center_x, Graphics.height - 82, align: :center)
    form_name = @viewable_forms[@form_index][0]
    if @viewable_forms[@form_index][3]
      text_center_x -= 10
      draw_image(UI_FOLDER + "shiny",
                 text_center_x + (@sprites[:overlay].bitmap.text_size(form_name).width / 2) + 6,
                 Graphics.height - 48)
    end
    draw_text(form_name, text_center_x, Graphics.height - 50, align: :center)
  end

  #-----------------------------------------------------------------------------

  def update_visuals
    super
    if @page == :area
      # Area highlights
      half_time_per_glow = 0.75
      intensity_time = System.uptime % (half_time_per_glow * 2)
      if intensity_time >= half_time_per_glow
        intensity = lerp(64, 256 + 64, half_time_per_glow, intensity_time - half_time_per_glow)
      else
        intensity = lerp(256 + 64, 64, half_time_per_glow, intensity_time)
      end
      @sprites[:area_highlights].opacity = intensity
      # Player's location
      player_pos = $game_map.metadata&.town_map_position
      if player_pos && player_pos[0] == @region && @encounter_maps[@region]&.any? { |map| map[1].include?([player_pos[1], player_pos[2]]) }
        half_time_per_flash = 0.25
        intensity_time = System.uptime % (half_time_per_flash * 2)
        intensity = (intensity_time >= half_time_per_flash) ? 255 : 0
      else
        intensity = 255
      end
      @sprites[:area_player].opacity = intensity
    end
  end

  def update_input
    # Check for movement to a new Pokémon
    if Input.trigger?(Input::UP)
      return :go_to_previous_species
    elsif Input.trigger?(Input::DOWN)
      return :go_to_next_species
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
      when :info
        play_species_cry
      when :area
        if map_scrollable?
          pbPlayDecisionSE
          navigate_area
          refresh
        end
      when :forms
        if @viewable_forms.length > 1
          pbPlayDecisionSE
          navigate_forms
          refresh
        end
      end
    when Input::ACTION
      case @page
      when :info, :forms
        play_species_cry
      when :area
        if @unlocked_regions.length > 1
          pbPlayDecisionSE
          choose_region
        end
      end
    when Input::BACK
      pbPlayCloseMenuSE
      return :quit
    end
    return nil
  end

  #-----------------------------------------------------------------------------

  def choose_region
    options = {}
    @unlocked_regions.each { |id| options[id] = GameData::TownMap.get(id).name }
    options[-1] = _INTL("Cancel")
    index = options.keys.index(@region) || 0
    new_region = show_choice_message(_INTL("Which region's map do you want to view?"), options, index)
    return if !new_region || new_region < 0 || new_region == @region
    @region = new_region
    @town_map_data = GameData::TownMap.get(@region)
    initialize_sprites_area
    center_map_cursor
    refresh
  end

  #-----------------------------------------------------------------------------

  def cursor_moving?
    return @cursor_offset && (@cursor_offset[0] != 0 || @cursor_offset[1] != 0)
  end

  def update_move_area_cursor
    now = System.uptime
    if @cursor_offset && @cursor_offset[0] && @cursor_offset[0] != 0
      point_size = @town_map_data.point_size
      offset_x = lerp(0, @cursor_offset[0] * point_size[0],
                      AREA_MOVE_TIME * @cursor_offset[0].abs,
                      @cursor_timer_start, now)
      @sprites[:area_map].src_rect.x = (@cursor_pos[0] * point_size[0]) + @town_map_data.margins[0] + (point_size[0] / 2) - (MAP_DISPLAY_SIZE[0] / 2)
      @sprites[:area_map].src_rect.x += offset_x
      clamp_map_position
      if @cursor_timer_start + (AREA_MOVE_TIME * @cursor_offset[0].abs) <= now
        @cursor_pos[0] += @cursor_offset[0]
        @cursor_offset[0] = 0
      end
    end
    if @cursor_offset && @cursor_offset[1] && @cursor_offset[1] != 0
      point_size = @town_map_data.point_size
      offset_y = lerp(0, @cursor_offset[1] * point_size[1],
                      AREA_MOVE_TIME * @cursor_offset[1].abs,
                      @cursor_timer_start, now)
      @sprites[:area_map].src_rect.y = (@cursor_pos[1] * point_size[1]) + @town_map_data.margins[1] + (point_size[1] / 2) - (MAP_DISPLAY_SIZE[1] / 2)
      @sprites[:area_map].src_rect.y += offset_y
      clamp_map_position
      if @cursor_timer_start + (AREA_MOVE_TIME * @cursor_offset[1].abs) <= now
        @cursor_pos[1] += @cursor_offset[1]
        @cursor_offset[1] = 0
      end
    end
    sync_map_sprites
    return true if cursor_moving?
    @sprites[:area_up].visible = map_scrollable_in_direction?(:up)
    @sprites[:area_down].visible = map_scrollable_in_direction?(:down)
    @sprites[:area_left].visible = map_scrollable_in_direction?(:left)
    @sprites[:area_right].visible = map_scrollable_in_direction?(:right)
    @cursor_timer_start = nil
    return false
  end

  def update_area_direction_input
    x_offset = 0
    y_offset = 0
    x_offset = -1 if Input.press?(Input::LEFT) && map_scrollable_in_direction?(:left)
    x_offset = 1 if Input.press?(Input::RIGHT) && map_scrollable_in_direction?(:right)
    y_offset = -1 if Input.press?(Input::UP) && map_scrollable_in_direction?(:up)
    y_offset = 1 if Input.press?(Input::DOWN) && map_scrollable_in_direction?(:down)
    return if x_offset == 0 && y_offset == 0
    @cursor_offset ||= []
    @cursor_offset[0] = x_offset
    @cursor_offset[1] = y_offset
  end

  # Returns true to finish choosing a move.
  def update_input_area
    return if cursor_moving? && update_move_area_cursor
    # Check for cursor movement
    update_area_direction_input
    if cursor_moving?
      @cursor_timer_start ||= System.uptime
      return
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      return true
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      return true
    end
    return false
  end

  def navigate_area
    # Setup
    @sub_mode = :scroll_map
    @sprites[:area_up].visible = map_scrollable_in_direction?(:up)
    @sprites[:area_down].visible = map_scrollable_in_direction?(:down)
    @sprites[:area_left].visible = map_scrollable_in_direction?(:left)
    @sprites[:area_right].visible = map_scrollable_in_direction?(:right)
    refresh
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      break if update_input_area
    end
    # Clean up
    @sprites[:area_up].visible = false
    @sprites[:area_down].visible = false
    @sprites[:area_left].visible = false
    @sprites[:area_right].visible = false
    @sub_mode = :nil
  end

  #-----------------------------------------------------------------------------

  # Returns true to finish choosing a move.
  def update_input_forms
    # Check for movement to a new move
    old_form_index = @form_index
    if Input.trigger?(Input::UP)
      @form_index -= 1
      @form_index = @viewable_forms.length - 1 if @form_index < 0   # Wrap around
    elsif Input.repeat?(Input::UP)
      @form_index -= 1 if @form_index > 0
    elsif Input.trigger?(Input::DOWN)
      @form_index += 1
      @form_index = 0 if @form_index >= @viewable_forms.length   # Wrap around
    elsif Input.repeat?(Input::DOWN)
      @form_index += 1 if @form_index < @viewable_forms.length - 1
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      return true
    elsif Input.trigger?(Input::ACTION)
      play_species_cry
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      return true
    end
    return false
  end

  def navigate_forms
    # Setup
    @sub_mode = :forms
    @sprites[:form_up].visible = (@form_index > 0)
    @sprites[:form_down].visible = (@form_index < @viewable_forms.length - 1)
    refresh_shown_form
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_form_index = @form_index
      break if update_input_forms
      if @form_index != old_form_index
        pbPlayCursorSE
        @gender = @viewable_forms[@form_index][1]
        @form   = @viewable_forms[@form_index][2]
        @shiny  = @viewable_forms[@form_index][3]
        @shiny = false if !Settings::SHOW_SHINY_SPRITES_IN_POKEDEX
        refresh_shown_form
        @sprites[:form_up].visible = (@form_index > 0)
        @sprites[:form_down].visible = (@form_index < @viewable_forms.length - 1)
      end
    end
    # Clean up
    @sprites[:form_up].visible = false
    @sprites[:form_down].visible = false
    $player.pokedex.set_last_form_seen(@species, @gender, @form, @shiny)
    @sub_mode = :nil
    @species_data = GameData::Species.get_species_form(@species, @form)
    refresh_shown_form
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokedexEntry < UI::BaseScreen
  attr_reader :dex

  ACTIONS = HandlerHash.new

  # dex is an array of [Pokémon species symbol] or [Dex number, Pokemon species symbol].
  # mode is :normal or :new_entry.
  def initialize(dex, initial_index = 0, region = -1, mode: :normal)
    @dex           = (dex[0].is_a?(Array)) ? dex : [dex]
    @initial_index = initial_index
    @mode          = mode
    @region        = region
    super()
  end

  def initialize_visuals
    @visuals = UI::PokedexEntryVisuals.new(@dex, @initial_index, @mode, @region)
  end

  def start_screen
    super   # Fade in
    @visuals.play_species_cry
  end

  #-----------------------------------------------------------------------------

  def index=(value)
    # NOTE: @visuals.set_index plays an SE.
    @visuals.set_dex_index(value)
  end

  def region
    return @visuals.region
  end

  ACTIONS.add(:go_to_previous_species, {
    :effect => proc { |screen|
      screen.index -= 1 if screen.index > 0
    }
  })
  ACTIONS.add(:go_to_next_species, {
    :effect => proc { |screen|
      screen.index += 1 if screen.index < screen.dex.length - 1
    }
  })

  #-----------------------------------------------------------------------------

  def main
    super
    return index
  end
end

#===============================================================================
#
#===============================================================================
def pbShowPokedexEntry(species, unlocked = true, no_fade = false)
  # Determine the Pokédex number
  dex_number = 0
  if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
    species_data = GameData::Species.try_get(species)
    if species_data
      species_list = []
      GameData::Species.each_species { |s| species_list.push(s.species) }
      dex_number = (species_list.index(species_data.species) + 1) || 0
      dex_number -= 1 if dex_number > 0 && Settings::DEXES_WITH_OFFSETS.include?(-1)
    end
  else
    ($player.pokedex.dexes_count - 1).times do |i|   # Regional Dexes
      next if !$player.pokedex.unlocked?(i)
      this_num = pbGetRegionalNumber(i, species)
      next if this_num <= 0
      dex_number = this_num
      dex_number -= 1 if Settings::DEXES_WITH_OFFSETS.include?(i)
      break
    end
  end
  # Show the Pokédex entry
  mode = (unlocked) ? :new_entry : :normal
  if no_fade
    UI::PokedexEntry.new([[dex_number, species]], mode: mode).main
  else
    pbFadeOutIn do
      UI::PokedexEntry.new([[dex_number, species]], mode: mode).main
    end
  end
end
