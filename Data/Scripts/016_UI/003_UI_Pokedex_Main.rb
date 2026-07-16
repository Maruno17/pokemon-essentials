#===============================================================================
#
#===============================================================================
class UI::PokedexVisualsList < Window_DrawableCommand
  attr_accessor :sorting

  def initialize(x, y, width, height, viewport)
    @dex = []
    super(x, y, width, height, viewport)
    @selarrow  = AnimatedBitmap.new(pokedex_folder + "cursor_list")
    @own_icon  = AnimatedBitmap.new(pokedex_folder + "icon_own")
    @seen_icon = AnimatedBitmap.new(pokedex_folder + "icon_seen")
    self.baseColor   = Color.new(88, 88, 80)
    self.shadowColor = Color.new(168, 184, 184)
    self.windowskin = nil
  end

  def dispose
    @own_icon.dispose
    @seen_icon.dispose
    super
  end

  #-----------------------------------------------------------------------------

  def page_row_max;  return UI::PokedexVisuals::SPECIES_VISIBLE; end
  def page_item_max; return page_row_max; end

  def itemCount
    return @dex.length
  end

  def pokedex_folder
    return UI::PokedexVisuals::UI_FOLDER + UI::PokedexVisuals::GRAPHICS_FOLDER
  end

  def dex=(value)
    @dex = value
    refresh
  end

  def species_id
    return (@dex[self.index]) ? @dex[self.index][1] : nil
  end

  #-----------------------------------------------------------------------------

  # Custom method that allows for an extra option to be displayed above and
  # below the main visible list.
  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    end
    cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
    x = item % @column_max * (cursor_width + @column_spacing)
    y = (item / @column_max * @row_height) - @virtualOy
    return Rect.new(x, y, cursor_width, @row_height)
  end

  #-----------------------------------------------------------------------------

  # This draws all the visible options first, and then draws the cursor. It also
  # draws an additional option above the main visible ones.
  def refresh
    @item_max = itemCount
    update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item || i >= self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def drawItem(this_index, _count, rect)
    textpos = []
    rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
    # Draw seen/owned icon
    if $player.owned?(@dex[this_index][1])
      pbCopyBitmap(self.contents, @own_icon.bitmap, rect.x - 6, rect.y + 10)
    elsif $player.seen?(@dex[this_index][1])
      pbCopyBitmap(self.contents, @seen_icon.bitmap, rect.x - 6, rect.y + 10)
    end
    # Draw Dex number
    num_text = sprintf("%03d", @dex[this_index][0])
    pbDrawShadowText(self.contents, rect.x + 36, rect.y + 6, rect.width, rect.height,
                     num_text, self.baseColor, self.shadowColor)
    # Draw species name
    name_text = ($player.seen?(@dex[this_index][1])) ? GameData::Species.get(@dex[this_index][1]).name : "----------"
    pbDrawShadowText(self.contents, rect.x + 84 + (@dex[this_index][0] >= 1000 ? 8 : 0), rect.y + 6, rect.width, rect.height,
                     name_text, self.baseColor, self.shadowColor)
  end

  def drawCursor(this_index, rect)
    return if self.index != this_index
    bmp = @selarrow.bitmap
    pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
  end

  #-----------------------------------------------------------------------------

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokedexSearchCursor < ChangelingSprite
  attr_accessor :options
  attr_writer   :page

  BITMAPS = {
    :normal       => ["Graphics/UI/Pokedex/cursor_search", 0, 244, 152, 40],
    :sort_by      => ["Graphics/UI/Pokedex/cursor_search", 0, 0, 184, 44],
    :first_letter => ["Graphics/UI/Pokedex/cursor_search", 0, 44, 124, 44],
    :type         => ["Graphics/UI/Pokedex/cursor_search", 0, 88, 252, 44],
    :height       => ["Graphics/UI/Pokedex/cursor_search", 0, 132, 232, 44],
    :weight       => ["Graphics/UI/Pokedex/cursor_search", 0, 132, 232, 44],
    :color        => ["Graphics/UI/Pokedex/cursor_search", 0, 44, 124, 44],
    :shape        => ["Graphics/UI/Pokedex/cursor_search", 0, 176, 68, 68],
    # Used in individual parameter pages
    :letter       => ["Graphics/UI/Pokedex/cursor_search", 0, 284, 44, 44],
    :type_grid    => ["Graphics/UI/Pokedex/cursor_search", 0, 44, 124, 44],
    :size_max     => ["Graphics/UI/Pokedex/cursor_search", 0, 328, 120, 96],
    :size_min     => ["Graphics/UI/Pokedex/cursor_search", 0, 424, 120, 96]
  }

  def initialize(viewport = nil)
    super(0, 0, viewport)
    change_bitmap(:normal)
    self.z = 1600
    self.visible = false
    @page = :search
    self.index = 0
  end

  def index=(value)
    @index = value
    refresh_appearance
    refresh_position
  end

  def refresh_appearance
    if @page == :search
      case @index
      when 0 then change_bitmap(:sort_by)
      when 1 then change_bitmap(:first_letter)
      when 2 then change_bitmap(:type)
      when 3 then change_bitmap(:height)
      when 4 then change_bitmap(:weight)
      when 5 then change_bitmap(:color)
      when 6 then change_bitmap(:shape)
      when 7, 8, 9 then change_bitmap(:normal)   # Reset, Start, Cancel buttons
      end
    elsif @index < 0
      change_bitmap(:normal)   # OK, Cancel buttons
    else
      case @page
      when :first_letter
        change_bitmap(:letter)
      when :type
        change_bitmap(:type_grid)
      when :height, :weight
        change_bitmap((@index >= 100) ? :size_max : :size_min)
      else
        change_bitmap(@page)
      end
    end
  end

  def refresh_position
    if @page == :search
      case @index
      when 0   # Order
        self.x = 252
        self.y = 52
      when 1, 2, 3, 4   # Name, type, height, weight
        self.x = 114
        self.y = 110 + ((@index - 1) * 52)
      when 5   # Color
        self.x = 382
        self.y = 110
      when 6   # Shape
        self.x = 420
        self.y = 214
      when 7, 8, 9   # Reset, start, cancel buttons
        self.x = 4 + ((@index - 7) * 176)
        self.y = 334
      end
    elsif @index == -2   # OK button
      self.x = 4
      self.y = 334
    elsif @index == -3   # Cancel button
      self.x = 356
      self.y = 334
    else
      case @page
      when :sort_by, :first_letter, :type, :color, :shape
        metrics = UI::PokedexVisuals::BUTTON_GRID_ARRANGEMENTS[@page]
        if @index >= @options.length   # Blank/nil button
          blank_index = (((@options.length / metrics[:columns]) + 1) * metrics[:columns]) - 1
          self.x = metrics[:start_pos][0] - 2 + ((blank_index % metrics[:columns]) * (metrics[:size][0] + metrics[:spacing][0]))
          self.y = metrics[:start_pos][1] - 2 + ((blank_index / metrics[:columns]) * (metrics[:size][1] + metrics[:spacing][1]))
        else
          self.x = metrics[:start_pos][0] - 2 + ((@index % metrics[:columns]) * (metrics[:size][0] + metrics[:spacing][0]))
          self.y = metrics[:start_pos][1] - 2 + ((@index / metrics[:columns]) * (metrics[:size][1] + metrics[:spacing][1]))
        end
      when :height
        plain_index = (@index >= 100) ? @index - 100 : @index
        self.x = lerp(44, 348, UI::PokedexVisuals::HEIGHT_INTERVALS.length - 1, plain_index)
        self.y = (@index >= 100) ? 110 : 222
      when :weight
        plain_index = (@index >= 100) ? @index - 100 : @index
        self.x = lerp(44, 348, UI::PokedexVisuals::WEIGHT_INTERVALS.length - 1, plain_index)
        self.y = (@index >= 100) ? 110 : 222
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class UI::PokedexVisuals < UI::BaseVisuals
  attr_reader :index
  attr_reader :display_dex

  GRAPHICS_FOLDER            = "Pokedex/"   # Subfolder in Graphics/UI
  BACKGROUND_FILENAME        = "bg_main"
  SEARCH_BACKGROUND_FILENAME = "bg_search"
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :dex_name => [Color.new(248, 248, 248), Color.black],
    :search   => [Color.new(248, 248, 248), Color.new(72, 72, 72)]
  }
  SLIDER_COORDS = {   # Size of elements in slider graphic
    :arrow_size  => [40, 30],
    :box_heights => [12, 12, 16]   # Heights of top, middle and bottom segments of slider box
  }
  SPECIES_VISIBLE = 10
  HEIGHT_INTERVALS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
                      10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                      20, 21, 22, 23, 24, 25, 30, 35, 40, 45,
                      50, 55, 60, 65, 70, 80, 90, 100, 999]
  WEIGHT_INTERVALS = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45,
                      50, 55, 60, 70, 80, 90, 100, 110, 120, 140,
                      160, 180, 200, 250, 300, 350, 400, 500, 600, 700,
                      800, 900, 1000, 1250, 1500, 2000, 3000, 5000, 9999]
  BUTTON_GRID_ARRANGEMENTS = {
    :sort_by => {
      :src_pos   => [0, 0],
      :size      => [184, 44],
      :start_pos => [48, 130],
      :spacing   => [52, 20],   # Horizontal spacing, vertical spacing
      :columns   => 2
    },
    :first_letter => {
      :src_pos   => [0, 156],
      :size      => [44, 44],
      :start_pos => [80, 116],
      :spacing   => [8, 8],   # Horizontal spacing, vertical spacing
      :columns   => 7
    },
    :type => {
      :src_pos   => [0, 44],
      :size      => [124, 44],
      :start_pos => [10, 106],
      :spacing   => [0, 0],   # Horizontal spacing, vertical spacing
      :columns   => 4
    },
    :color => {
      :src_pos   => [0, 44],
      :size      => [124, 44],
      :start_pos => [64, 116],
      :spacing   => [8, 8],   # Horizontal spacing, vertical spacing
      :columns   => 3
    },
    :shape => {
      :src_pos   => [0, 88],
      :size      => [68, 68],
      :start_pos => [84, 118],
      :spacing   => [2, 2],   # Horizontal spacing, vertical spacing
      :columns   => 5
    }
  }

  #-----------------------------------------------------------------------------

  PAGE_HANDLERS = HandlerHash.new
  PAGE_HANDLERS.add(:main, {
    :draw => [
      :refresh_slider,
      :refresh_selected_species,
      :draw_dex_name,
      :draw_input_helpers,
      :draw_completion_info,
      :draw_search_results_info
    ]
  })
  PAGE_HANDLERS.add(:search, {
    :draw => [
      :draw_search_page
    ]
  })
  PAGE_HANDLERS.add(:sort_by, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_sort_by_page
    ]
  })
  PAGE_HANDLERS.add(:first_letter, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_first_letter_page
    ]
  })
  PAGE_HANDLERS.add(:type, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_type_page
    ]
  })
  PAGE_HANDLERS.add(:height, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_height_page
    ]
  })
  PAGE_HANDLERS.add(:weight, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_weight_page
    ]
  })
  PAGE_HANDLERS.add(:color, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_color_page
    ]
  })
  PAGE_HANDLERS.add(:shape, {
    :draw => [
      :draw_common_search_sub_page_contents,
      :draw_search_shape_page
    ]
  })

  #-----------------------------------------------------------------------------

  # @dex is the defined Dex, where each entry is a hash containing all the
  # parameters that can be filtered/sorted by.
  # @display_dex is an array of [number, species] which is @dex with the filters
  # and sorting option applied.
  def initialize(dex, dex_id, start_index = 0)
    @dex = dex
    @dex_id = dex_id
    @start_index = start_index
    @page = :main
    clear_filters
    refresh_display_dex
    super()
  end

  def initialize_bitmaps
    super
    @bitmaps[:slider]         = AnimatedBitmap.new(graphics_folder + "icon_slider")
    @bitmaps[:types]          = AnimatedBitmap.new(graphics_folder + _INTL("types"))
    @bitmaps[:height_weight]  = AnimatedBitmap.new(graphics_folder + _INTL("icon_height_weight"))
    @bitmaps[:shapes]         = AnimatedBitmap.new(graphics_folder + "shapes")
    @bitmaps[:size_sliders]   = AnimatedBitmap.new(graphics_folder + _INTL("icon_size_sliders"))
    @bitmaps[:search_buttons] = AnimatedBitmap.new(graphics_folder + "icon_search_buttons")
  end

  def initialize_overlay
    super
    add_overlay(:pokemon_name_overlay, 156, 32)
    @sprites[:pokemon_name_overlay].x = 26
    @sprites[:pokemon_name_overlay].y = 52
    @sprites[:pokemon_name_overlay].z = 200
    add_overlay(:shiny_overlay, 14, 16)
    @sprites[:shiny_overlay].x = 10
    @sprites[:shiny_overlay].y = 94
    @sprites[:shiny_overlay].z = 200
    add_overlay(:slider_overlay, 40, 328)
    @sprites[:slider_overlay].x = 468
    @sprites[:slider_overlay].y = 48
    @sprites[:slider_overlay].z = 200
  end

  def initialize_background
    super
    addBackgroundPlane(@sprites, :page_background, self.class::GRAPHICS_FOLDER + page_background_filename, @viewport)
    @sprites[:page_background].z = 100
  end

  def initialize_sprites
    initialize_list_sprites
    initialize_search_sprites
  end

  def initialize_list_sprites
    # Dex list
    @sprites[:dex_list] = UI::PokedexVisualsList.new(190, 30, 292, 44 + (SPECIES_VISIBLE * 32), @viewport)
    @sprites[:dex_list].z           = 200
    @sprites[:dex_list].dex         = @display_dex
    @sprites[:dex_list].index       = @start_index
    @sprites[:dex_list].baseColor   = get_text_color_theme(:gray)[0]
    @sprites[:dex_list].shadowColor = get_text_color_theme(:gray)[1]
    @sprites[:dex_list].active      = false
    # Pokémon sprite
    @sprites[:pokemon] = PokemonSprite.new(@viewport)
    @sprites[:pokemon].setOffset(PictureOrigin::CENTER)
    @sprites[:pokemon].x = 104
    @sprites[:pokemon].y = 196
    @sprites[:pokemon].z = 50
  end

  def initialize_search_sprites
    # Cursor
    @sprites[:search_cursor] = UI::PokedexSearchCursor.new(@viewport)
    @sprites[:search_cursor].visible = false
  end

  #-----------------------------------------------------------------------------

  def background_filename
    return SEARCH_BACKGROUND_FILENAME if @page != :main
    return BACKGROUND_FILENAME
  end

  def page_background_filename
    if @page == :main
      ret = BACKGROUND_FILENAME + "_list"
      ret = BACKGROUND_FILENAME + "_filtered" if list_filtered?
    elsif @page == :search
      ret = SEARCH_BACKGROUND_FILENAME + "_main"
    else
      ret = SEARCH_BACKGROUND_FILENAME + "_" + @page.to_s
    end
    return ret
  end

  def index
    return @sprites[:dex_list].index
  end

  def set_index(value)
    @sprites[:dex_list].index = value
    refresh_on_index_changed(nil)
  end

  def set_page(new_page)
    @page = new_page
    refresh
  end

  def species
    return @sprites[:dex_list].species_id
  end

  def order_texts
    return {
      :number       => _INTL("Numerical"),
      :alphabetical => _INTL("A to Z"),
      :heaviest     => _INTL("Heaviest"),
      :lightest     => _INTL("Lightest"),
      :tallest      => _INTL("Tallest"),
      :shortest     => _INTL("Smallest")
    }
  end

  def first_letter_texts
    return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
  end

  #-----------------------------------------------------------------------------

  def clear_filters
    @filters = {
      :sort_by      => :number,
      :first_letter => nil,
      :type1        => nil,
      :type2        => nil,
      :min_height   => nil,
      :max_height   => nil,
      :min_weight   => nil,
      :max_weight   => nil,
      :color        => nil,
      :shape        => nil
    }
  end

  def list_filtered?
    return true if @filters[:sort_by] != :number
    return @filters.any? { |key, value| key != :sort_by && !value.nil? }
  end

  # Sets @display_dex as an array of [number, species].
  def refresh_display_dex
    if !list_filtered?
      @display_dex = @dex.map { |entry| [entry[:number], entry[:species]] }
      return
    end
    # Get a starting Dex list to apply filters to (seen species only)
    @display_dex = @dex.clone
    @display_dex.filter! { |value| $player.pokedex.seen?(value[:species]) }
    # Apply first letter filter
    if @filters[:first_letter]
      @display_dex.filter! { |value| value[:name][0].upcase == @filters[:first_letter].upcase }
    end
    # Apply type filters
    if @filters[:type1] && @filters[:type2]
      @display_dex.filter! do |value|
        value[:types].any? { |this_types| this_types.include?(@filters[:type1]) && this_types.include?(@filters[:type2]) }
      end
    elsif @filters[:type1]
      @display_dex.filter! do |value|
        value[:types].any? { |this_types| this_types.include?(@filters[:type1]) }
      end
    elsif @filters[:type2]
      @display_dex.filter! do |value|
        value[:types].any? { |this_types| this_types.include?(@filters[:type2]) }
      end
    end
    # Apply height filters
    if @filters[:min_height] && @filters[:max_height]
      @display_dex.filter! do |value|
        value[:height].any? { |this_height| this_height >= @filters[:min_height] && this_height <= @filters[:max_height] }
      end
    elsif @filters[:min_height]
      @display_dex.filter! do |value|
        value[:height].any? { |this_height| this_height >= @filters[:min_height] }
      end
    elsif @filters[:max_height]
      @display_dex.filter! do |value|
        value[:height].any? { |this_height| this_height <= @filters[:max_height] }
      end
    end
    # Apply weight filters
    if @filters[:min_weight] && @filters[:max_weight]
      @display_dex.filter! do |value|
        value[:weight].any? { |this_weight| this_weight >= @filters[:min_weight] && this_weight <= @filters[:max_weight] }
      end
    elsif @filters[:min_weight]
      @display_dex.filter! do |value|
        value[:weight].any? { |this_weight| this_weight >= @filters[:min_weight] }
      end
    elsif @filters[:max_weight]
      @display_dex.filter! do |value|
        value[:weight].any? { |this_weight| this_weight <= @filters[:max_weight] }
      end
    end
    # Apply color filter
    if @filters[:color]
      @display_dex.filter! { |value| value[:color].include?(@filters[:color]) }
    end
    # Apply shape filter
    if @filters[:shape]
      @display_dex.filter! { |value| value[:shape].include?(@filters[:shape]) }
    end
    # Some filter options only work for owned species; ensure only owned species
    # are in the results if those filters apply
    if @filters[:type1] || @filters[:type2] ||
       @filters[:min_height] || @filters[:max_height] ||
       @filters[:min_weight] || @filters[:max_weight] ||
       [:heaviest, :lightest, :tallest, :shortest].include?(@filters[:sort_by])
      @display_dex.filter! { |value| $player.pokedex.owned?(value[:species]) }
    end
    # Apply the sorting order
    case @filters[:sort_by]
    when :number
      @display_dex.sort! { |a, b| a[:number] <=> b[:number] }
    when :alphabetical
      @display_dex.sort! { |a, b| a[:name] <=> b[:name] }
    when :heaviest
      @display_dex.sort! { |a, b| a[:weight] == b[:weight] ? a[:number] <=> b[:number] : b[:weight] <=> a[:weight] }
    when :lightest
      @display_dex.sort! { |a, b| a[:weight] == b[:weight] ? a[:number] <=> b[:number] : a[:weight] <=> b[:weight] }
    when :tallest
      @display_dex.sort! { |a, b| a[:height] == b[:height] ? a[:number] <=> b[:number] : b[:height] <=> a[:height] }
    when :shortest
      @display_dex.sort! { |a, b| a[:height] == b[:height] ? a[:number] <=> b[:number] : a[:height] <=> b[:height] }
    end
    # Condense into an array of [number, species]
    @display_dex.map! { |entry| [entry[:number], entry[:species]] }
  end

  def apply_display_dex
    current_species = species
    @sprites[:dex_list].dex = @display_dex
    new_index = @display_dex.index { |entry| entry[1] == current_species } || 0
    @sprites[:dex_list].index = new_index
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    @sprites[:pokemon_name_overlay].visible = (@page == :main)
    @sprites[:shiny_overlay].visible        = (@page == :main)
    @sprites[:slider_overlay].visible       = (@page == :main)
    @sprites[:dex_list].visible             = (@page == :main)
    @sprites[:pokemon].visible              = (@page == :main)
    @sprites[:search_cursor].visible = (@page != :main)
    refresh_background
    draw_page_contents
  end

  def refresh_on_index_changed(old_index)
    refresh_slider
    refresh_selected_species
  end

  def refresh_background
    @sprites[:background].setBitmap(graphics_folder + background_filename)
    @sprites[:page_background].setBitmap(graphics_folder + page_background_filename)
  end

  def refresh_slider
    @sprites[:slider_overlay].bitmap.clear
    slider_x       = 0
    slider_y       = 0
    slider_height  = 328   # Includes heights of arrows at either end
    visible_top    = @sprites[:dex_list].top_row
    visible_height = @sprites[:dex_list].page_row_max
    total_height   = @sprites[:dex_list].row_max
    draw_slider(@bitmaps[:slider], slider_x, slider_y, slider_height,
                visible_top, visible_height, total_height, overlay: :slider_overlay)
  end

  def refresh_selected_species
    this_species = species
    gender, form, shiny = $player.pokedex.last_form_seen(this_species)
    this_species = nil if !$player.pokedex.seen?(this_species)
    @sprites[:pokemon].setSpeciesBitmap(this_species, gender, form, shiny)
    refresh_species_name
    refresh_shiny_icon
  end

  def refresh_species_name
    @sprites[:pokemon_name_overlay].bitmap.clear
    return if !$player.pokedex.seen?(species)
    species_name = GameData::Species.get(species).name
    draw_text(species_name, 78, 6, align: :center, overlay: :pokemon_name_overlay)
  end

  def refresh_shiny_icon
    @sprites[:shiny_overlay].bitmap.clear
    _gender, _form, shiny = $player.pokedex.last_form_seen(species)
    draw_image(UI_FOLDER + "shiny", 0, 0, overlay: :shiny_overlay) if shiny
  end

  def draw_page_contents
    PAGE_HANDLERS[@page][:draw].each { |method| self.send(method) }
  end

  #-----------------------------------------------------------------------------

  def draw_dex_name
    dex_name = _INTL("Pokédex")
    this_dex = Settings.pokedex_names[@dex_id]
    if this_dex
      dex_name = (this_dex.is_a?(Array)) ? this_dex[0] : this_dex
    end
    draw_text(dex_name, Graphics.width / 2, 10, align: :center, theme: :dex_name)
  end

  def draw_input_helpers
    search_text = _INTL("Search")
    image_x = Graphics.width - 4
    draw_input_icon(image_x, 2, Input::ACTION, search_text, align: :right, theme: :white)
  end

  def draw_completion_info
    return if list_filtered?
    draw_text(_INTL("Seen:"), 42, 314)
    draw_text($player.pokedex.seen_count(@dex_id).to_s, 166, 314, align: :right)
    draw_text(_INTL("Owned:"), 42, 346)
    draw_text($player.pokedex.owned_count(@dex_id).to_s, 166, 346, align: :right)
  end

  def draw_search_results_info
    return if !list_filtered?
    draw_text(_INTL("Search results"), 104, 314, align: :center)
    draw_text(@display_dex.length.to_s, 104, 346, align: :center)
  end

  def draw_search_page
    imperial_offset = Translation.imperial_measurements?
    # Draw title
    draw_text(_INTL("Search Mode"), Graphics.width / 2, 10, align: :center, theme: :search)
    # Draw sort order
    draw_text(_INTL("Order"), 136, 64, align: :center, theme: :search)
    order_text = order_texts[@filters[:sort_by]]
    draw_text(order_text, 344, 66, align: :center, theme: :search, outline: :outline)
    # Draw "name starts with"
    draw_text(_INTL("Name"), 58, 122, align: :center, theme: :search)
    first_letter_text = @filters[:first_letter]&.upcase || "----"
    draw_text(first_letter_text, 176, 124, align: :center, theme: :search, outline: :outline)
    # Draw type
    draw_text(_INTL("Type"), 58, 174, align: :center, theme: :search)
    if @filters[:type1]
      type_number = GameData::Type.get(@filters[:type1]).icon_position
      draw_image(@bitmaps[:types], 128, 168,
                 0, type_number * UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1],
                 *UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE)
    else
      draw_text("----", 176, 176, align: :center, theme: :search, outline: :outline)
    end
    if @filters[:type2]
      type_number = GameData::Type.get(@filters[:type2]).icon_position
      draw_image(@bitmaps[:types], 256, 168,
                 0, type_number * UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1],
                 *UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE)
    else
      draw_text("----", 304, 176, align: :center, theme: :search, outline: :outline)
    end
    # Draw height
    draw_text(_INTL("Height"), 58, 226, align: :center, theme: :search)
    min_height = @filters[:min_height] || HEIGHT_INTERVALS.first
    max_height = @filters[:max_height] || HEIGHT_INTERVALS.last
    if imperial_offset
      min_height = (min_height >= HEIGHT_INTERVALS.last) ? (HEIGHT_INTERVALS.last / 10) * 12 : (min_height / 0.254).round
      max_height = (max_height >= HEIGHT_INTERVALS.last) ? (HEIGHT_INTERVALS.last / 10) * 12 : (max_height / 0.254).round
      min_inch = sprintf("%02d", min_height % 12)
      max_inch = sprintf("%02d", max_height % 12)
      draw_text(sprintf("%d'%s''", min_height / 12, min_inch), 166, 228, align: :center, theme: :search, outline: :outline)
      draw_text(sprintf("%d'%s''", max_height / 12, max_inch), 294, 228, align: :center, theme: :search, outline: :outline)
    else
      draw_text(sprintf("%.1f", min_height / 10.0).format_number, 166, 228, align: :center, theme: :search, outline: :outline)
      draw_text(sprintf("%.1f", max_height / 10.0).format_number, 294, 228, align: :center, theme: :search, outline: :outline)
    end
    draw_image(@bitmaps[:height_weight], 344, 214,
               0, (imperial_offset) ? 44 : 0, 32, 44)
    # Draw weight
    draw_text(_INTL("Weight"), 58, 278, align: :center, theme: :search)
    min_weight = @filters[:min_weight] || WEIGHT_INTERVALS.first
    max_weight = @filters[:max_weight] || WEIGHT_INTERVALS.last
    if imperial_offset
      min_weight = (min_weight >= WEIGHT_INTERVALS.last) ? WEIGHT_INTERVALS.last * 10 : (min_weight / 0.45359).round
      max_weight = (max_weight >= WEIGHT_INTERVALS.last) ? WEIGHT_INTERVALS.last * 10 : (max_weight / 0.45359).round
    end
    draw_text(sprintf("%.1f", min_weight / 10.0).format_number, 166, 280, align: :center, theme: :search, outline: :outline)
    draw_text(sprintf("%.1f", max_weight / 10.0).format_number, 294, 280, align: :center, theme: :search, outline: :outline)
    draw_image(@bitmaps[:height_weight], 344, 266,
               32, (imperial_offset) ? 44 : 0, 32, 44)
    # Draw color
    draw_text(_INTL("Color"), 326, 122, align: :center, theme: :search)
    color_name = (@filters[:color]) ? GameData::BodyColor.get(@filters[:color]).name : "----"
    draw_text(color_name, 444, 124, align: :center, theme: :search, outline: :outline)
    # Draw shape
    draw_text(_INTL("Shape"), 454, 174, align: :center, theme: :search)
    if @filters[:shape]
      shape_number = GameData::BodyShape.get(@filters[:shape]).icon_position
      draw_image(@bitmaps[:shapes], 424, 218,
                 0, shape_number * GameData::BodyShape::ICON_SIZE[1], *GameData::BodyShape::ICON_SIZE)
    end
    # Draw bottom bar text
    draw_text(_INTL("Reset"), 80, 346, align: :center, theme: :search, outline: :outline)
    draw_text(_INTL("Start"), Graphics.width / 2, 346, align: :center, theme: :search, outline: :outline)
    draw_text(_INTL("Cancel"), Graphics.width - 80, 346, align: :center, theme: :search, outline: :outline)
  end

  def draw_common_search_sub_page_contents
    # Draw title
    draw_text(_INTL("Search Mode"), Graphics.width / 2, 10, align: :center, theme: :search)
    # Draw bottom buttons text
    draw_text(_INTL("OK"), 80, 346, align: :center, theme: :search, outline: :outline)
    draw_text(_INTL("Cancel"), Graphics.width - 80, 346, align: :center, theme: :search, outline: :outline)
    # Draw filter name
    filter_name = {
      :sort_by      => _INTL("Order"),
      :first_letter => _INTL("Name"),
      :type         => _INTL("Type"),
      :height       => _INTL("Height"),
      :weight       => _INTL("Weight"),
      :color        => _INTL("Color"),
      :shape        => _INTL("Shape")
    }[@page]
    draw_text(filter_name, 102, (@page == :shape) ? 70 : 64, theme: :search)
  end

  # Yields:
  #   -1 when drawing the current filter value(s) at the top
  #   0...options.length when drawing the value buttons
  #   options.length when drawing the blank/nil option button
  def draw_search_page_button_grid(filter_value, options, draw_text, blank_text)
    metrics = BUTTON_GRID_ARRANGEMENTS[@page]
    # Draw filter value at top
    if draw_text
      if !filter_value.is_a?(Array)
        filter_text = (options.is_a?(Hash) ? options[filter_value] : filter_value) || blank_text
        draw_text(filter_text, 362, 66, align: :center, theme: :search, outline: :outline)
      end
    else
      yield -1, 0, 0 if block_given?
    end
    # Draw buttons with text
    (options.is_a?(Hash) ? options.keys : options).each_with_index do |value, i|
      button_x = metrics[:start_pos][0] + ((i % metrics[:columns]) * (metrics[:size][0] + metrics[:spacing][0]))
      button_y = metrics[:start_pos][1] + ((i / metrics[:columns]) * (metrics[:size][1] + metrics[:spacing][1]))
      src_x = metrics[:src_pos][0]
      src_x += 184 if (filter_value.is_a?(Array) && filter_value.include?(value)) ||
                      (!filter_value.is_a?(Array) && filter_value == value)
      draw_image(@bitmaps[:search_buttons], button_x, button_y,
                 src_x, metrics[:src_pos][1], *metrics[:size])
      # NOTE: Drop shadow of buttons is included in button graphic and is
      #       assumed to be 4 pixels thick.
      if draw_text
        button_text = (options.is_a?(Hash)) ? options[value] : options[i]
        draw_text(button_text, button_x + ((metrics[:size][0] - 4) / 2), button_y + 12, align: :center, theme: :search, outline: :outline)
      else
        yield i, button_x, button_y if block_given?
      end
    end
    # Draw blank button
    if blank_text
      blank_index = (((options.length / metrics[:columns]) + 1) * metrics[:columns]) - 1
      button_x = metrics[:start_pos][0] + ((blank_index % metrics[:columns]) * (metrics[:size][0] + metrics[:spacing][0]))
      button_y = metrics[:start_pos][1] + ((blank_index / metrics[:columns]) * (metrics[:size][1] + metrics[:spacing][1]))
      src_x = metrics[:src_pos][0]
      src_x += 184 if (filter_value.is_a?(Array) && filter_value.include?(nil)) ||
                      (!filter_value.is_a?(Array) && filter_value == nil)
      draw_image(@bitmaps[:search_buttons], button_x, button_y,
                 src_x, metrics[:src_pos][1], *metrics[:size])
      if blank_text != ""
        draw_text(blank_text, button_x + ((metrics[:size][0] - 4) / 2), button_y + 12, align: :center, theme: :search, outline: :outline)
      else
        yield options.length, button_x, button_y if block_given?
      end
    end
  end

  def draw_search_sort_by_page
    draw_search_page_button_grid(@filters[:sort_by], order_texts, true, nil)
  end

  def draw_search_first_letter_page
    draw_search_page_button_grid(@filters[:first_letter], first_letter_texts, true, "-")
  end

  def draw_search_type_page
    metrics = BUTTON_GRID_ARRANGEMENTS[@page]
    types = []
    GameData::Type.each { |type| types.push(type.id) if !type.pseudo_type }
    draw_search_page_button_grid([@filters[:type1], @filters[:type2]], types, false, "----") do |index, button_x, button_y|
      case index
      when -1   # Current filter value
        if @filters[:type1]
          draw_image(@bitmaps[:types], 250, 58,
                     0, GameData::Type.get(@filters[:type1]).icon_position * UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1],
                     *UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE)
        else
          draw_text("----", 298, 66, align: :center, theme: :search, outline: :outline)
        end
        if @filters[:type2]
          draw_image(@bitmaps[:types], 378, 58,
                     0, GameData::Type.get(@filters[:type2]).icon_position * UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1],
                     *UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE)
        else
          draw_text("----", 426, 66, align: :center, theme: :search, outline: :outline)
        end
      when types.length   # Blank
      else
        button_x += (metrics[:size][0] - 4) / 2
        button_x -= UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[0] / 2
        button_y += (metrics[:size][1] - 4) / 2
        button_y -= UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1] / 2
        draw_image(@bitmaps[:types], button_x, button_y,
                   0, GameData::Type.get(types[index]).icon_position * UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE[1],
                   *UI::PokedexEntryVisuals::POKEDEX_TYPE_ICON_SIZE)
      end
    end
  end

  def draw_search_height_weight_page(min_filter, max_filter, intervals, is_weight)
    imperial_offset = Translation.imperial_measurements?
    min_index = intervals.index(@filters[min_filter]) || 0
    max_index = intervals.index(@filters[max_filter]) || (intervals.length - 1)
    # Draw filter values at top
    min_value = @filters[min_filter] || intervals.first
    max_value = @filters[max_filter] || intervals.last
    if imperial_offset
      if is_weight
        min_value = (min_value >= intervals.last) ? intervals.last * 10 : (min_value / 0.45359).round
        max_value = (max_value >= intervals.last) ? intervals.last * 10 : (max_value / 0.45359).round
        min_text = sprintf("%.1f", min_value / 10.0).format_number
        max_text = sprintf("%.1f", max_value / 10.0).format_number
      else   # Height
        min_value = (min_value >= intervals.last) ? (intervals.last / 10) * 12 : (min_value / 0.254).round
        max_value = (max_value >= intervals.last) ? (intervals.last / 10) * 12 : (max_value / 0.254).round
        min_inch = sprintf("%02d", min_value % 12)
        max_inch = sprintf("%02d", max_value % 12)
        min_text = sprintf("%d'%s''", min_value / 12, min_inch)
        max_text = sprintf("%d'%s''", max_value / 12, max_inch)
      end
    else
      min_text = sprintf("%.1f", min_value / 10.0).format_number
      max_text = sprintf("%.1f", max_value / 10.0).format_number
    end
    draw_text(min_text, 286, 66, align: :center, theme: :search, outline: :outline)
    draw_text(max_text, 414, 66, align: :center, theme: :search, outline: :outline)
    draw_image(@bitmaps[:height_weight], 462, 52,
              (is_weight) ? 32 : 0, (imperial_offset) ? 44 : 0, 32, 44)
    # Draw min left/right arrows
    draw_image(@bitmaps[:size_sliders], 16, 264,
              0, 192, 32, 44) if min_index > 0
    draw_image(@bitmaps[:size_sliders], 464, 264,
              32, 192, 32, 44) if min_index < max_index
    # Draw max left/right arrows
    draw_image(@bitmaps[:size_sliders], 16, 120,
              0, 192, 32, 44) if max_index > min_index
    draw_image(@bitmaps[:size_sliders], 464, 120,
              32, 192, 32, 44) if max_index < intervals.length - 1
    # Draw slider boxes and their texts
    start_x = 44
    end_x = 348
    min_x = lerp(start_x, end_x, intervals.length - 1, min_index)
    max_x = lerp(start_x, end_x, intervals.length - 1, max_index)
    draw_image(@bitmaps[:size_sliders], min_x, 222,
              0, 96, 120, 96)
    draw_image(@bitmaps[:size_sliders], max_x, 110,
              0, 0, 120, 96)
    draw_text(min_text, min_x + 60, 290, align: :center, theme: :search, outline: :none)
    draw_text(max_text, max_x + 60, 146, align: :center, theme: :search, outline: :none)
  end

  def draw_search_height_page
    draw_search_height_weight_page(:min_height, :max_height, HEIGHT_INTERVALS, false)
  end

  def draw_search_weight_page
    draw_search_height_weight_page(:min_weight, :max_weight, WEIGHT_INTERVALS, true)
  end

  def draw_search_color_page
    color_texts = {}
    GameData::BodyColor.each { |color| color_texts[color.id] = color.name }
    draw_search_page_button_grid(@filters[:color], color_texts, true, "----")
  end

  def draw_search_shape_page
    shapes = GameData::BodyShape.keys
    draw_search_page_button_grid(@filters[:shape], shapes, false, "") do |index, button_x, button_y|
      case index
      when -1   # Current filter value
        if @filters[:shape]
          draw_image(@bitmaps[:shapes], 332, 50,
                     0, GameData::BodyShape.get(@filters[:shape]).icon_position * GameData::BodyShape::ICON_SIZE[1],
                     *GameData::BodyShape::ICON_SIZE)
        end
      when shapes.length   # Blank
      else
        draw_image(@bitmaps[:shapes], button_x + 2, button_y + 2,
                   0, GameData::BodyShape.get(shapes[index]).icon_position * GameData::BodyShape::ICON_SIZE[1],
                   *GameData::BodyShape::ICON_SIZE)
      end
    end
  end

  #-----------------------------------------------------------------------------

  def update_input
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
      if $player.pokedex.seen?(species)
        pbSEPlay("GUI pokedex open")
        return :view_entry
      end
    when Input::ACTION
      pbSEPlay("GUI pokedex open")
      return :open_search
    when Input::BACK
      if list_filtered?
        pbPlayCloseMenuSE
        pbFadeOutIn do
          clear_filters
          refresh_display_dex
          apply_display_dex
          refresh
        end
      else
        pbPlayCloseMenuSE
        return :quit
      end
    end
    return nil
  end

  def navigate
    @page = :main
    @sprites[:dex_list].active = true
    ret = super
    @sprites[:dex_list].active = false
    $PokemonGlobal.pokedexIndex[@dex_id] = @sprites[:dex_list].index if !list_filtered?
    return ret
  end

  #-----------------------------------------------------------------------------

  def update_input_search
    # Check for cursor movement
    if Input.repeat?(Input::UP)
      if @search_index >= 7
        @search_index = 4
      elsif @search_index == 5
        @search_index = 0
      elsif @search_index > 0
        @search_index -= 1
      end
    elsif Input.repeat?(Input::DOWN)
      if [4, 6].include?(@search_index)
        @search_index = 8
      elsif @search_index < 7
        @search_index += 1
      end
    elsif Input.repeat?(Input::LEFT)
      if @search_index == 5
        @search_index = 1
      elsif @search_index == 6
        @search_index = 3
      elsif @search_index > 7
        @search_index -= 1
      end
    elsif Input.repeat?(Input::RIGHT)
      if @search_index == 1
        @search_index = 5
      elsif @search_index >= 2 && @search_index <= 4
        @search_index = 6
      elsif [7, 8].include?(@search_index)
        @search_index += 1
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE if @search_index <= 6   # Go to another page
      case @search_index
      when 0   # Sort order
        navigate_sub_search(:sort_by)
      when 1   # Name starts with
        navigate_sub_search(:first_letter)
      when 2   # Type
        navigate_sub_search(:type)
      when 3   # Height range
        navigate_sub_search(:height)
      when 4   # Weight range
        navigate_sub_search(:weight)
      when 5   # Color
        navigate_sub_search(:color)
      when 6   # Shape
        navigate_sub_search(:shape)
      when 7   # Clear filters
        pbPlayDecisionSE
        clear_filters
        refresh
      when 8   # Start search
        pbSEPlay("GUI pokedex open")
        old_display_dex = @display_dex
        refresh_display_dex
        if @display_dex.empty?
          show_message(_INTL("No matching Pokémon were found."))
          @display_dex = old_display_dex   # Revert to previous results
        else
          return true
        end
      when 9   # Cancel
        pbPlayCloseMenuSE
        @filters = @old_filters
        return true
      end
      if @page != :search
        set_page(:search)
        @sprites[:search_cursor].page = @page
        @sprites[:search_cursor].index = @search_index
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCloseMenuSE
      @filters = @old_filters
      return true
    elsif Input.trigger?(Input::ACTION)
      @search_index = 8   # Jump to "Start" button
    end
    return false
  end

  def navigate_search
    @search_index = 0
    @old_filters = @filters.clone
    pbFadeOutIn do
      set_page(:search)
      @sprites[:search_cursor].page = @page
      @sprites[:search_cursor].index = @search_index
    end
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_search_index = @search_index
      break if update_input_search
      if @search_index != old_search_index
        pbPlayCursorSE
        @sprites[:search_cursor].index = @search_index
      end
    end
    # Clean up
    pbFadeOutIn do
      apply_display_dex
      set_page(:main)
    end
  end

  #-----------------------------------------------------------------------------

  def set_sub_search_initial_values(new_page)
    case new_page
    when :type
      @old_filter = [@filters[:type1], @filters[:type2]]
      @search_sub_index = 0
    when :height
      @old_filter = [@filters[:min_height], @filters[:max_height]]
      @search_sub_index = 100 + (HEIGHT_INTERVALS.index(@filters[:max_height]) || HEIGHT_INTERVALS.length - 1)
    when :weight
      @old_filter = [@filters[:min_weight], @filters[:max_weight]]
      @search_sub_index = 100 + (WEIGHT_INTERVALS.index(@filters[:max_weight]) || WEIGHT_INTERVALS.length - 1)
    else
      @old_filter = @filters[new_page]
      @search_sub_index = 0
    end
    # Pass options to cursor so it knows how many rows of options there are
    # (only needed for filters which have a blank/nil option that is part of a
    # grid of buttons)
    case new_page
    when :sort_by
      @sprites[:search_cursor].options = order_texts.keys
    when :first_letter
      @sprites[:search_cursor].options = first_letter_texts
    when :type
      types = []
      GameData::Type.each { |type| types.push(type.id) if !type.pseudo_type }
      @sprites[:search_cursor].options = types
    when :color
      @sprites[:search_cursor].options = GameData::BodyColor.keys
    when :shape
      @sprites[:search_cursor].options = GameData::BodyShape.keys
    end
  end

  def update_input_button_grid(filter, options, columns, has_blank)
    max_index = options.length - 1 + (has_blank ? 1 : 0)
    rows = (max_index / columns) + 1
    if Input.repeat?(Input::UP)
      if @search_sub_index == -2   # OK
        @search_sub_index = (rows - 1) * columns
      elsif @search_sub_index == -3   # Cancel
        @search_sub_index = max_index
      elsif @search_sub_index >= columns
        if @search_sub_index >= options.length
          @search_sub_index = ((rows - 1) * columns) - 1
          @search_sub_index = 0 if @search_sub_index < 0
        else
          @search_sub_index -= columns
        end
      end
    elsif Input.repeat?(Input::DOWN)
      if @search_sub_index >= 0
        @search_sub_index += columns
        if @search_sub_index > max_index
          if @search_sub_index - columns >= max_index
            @search_sub_index = -3   # Cancel
          elsif @search_sub_index / columns <= rows - 1
            @search_sub_index = max_index
          elsif @search_sub_index % columns < columns / 2.0
            @search_sub_index = -2   # OK
          else
            @search_sub_index = -3   # Cancel
          end
        end
      end
    elsif Input.repeat?(Input::LEFT)
      if @search_sub_index == -3   # Cancel
        @search_sub_index = -2   # OK
      elsif @search_sub_index >= 0 && @search_sub_index % columns > 0
        @search_sub_index -= 1
      end
    elsif Input.repeat?(Input::RIGHT)
      if @search_sub_index == -2   # OK
        @search_sub_index = -3   # Cancel
      elsif @search_sub_index >= 0 && @search_sub_index % columns < columns - 1
        @search_sub_index += 1 if @search_sub_index < max_index
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @search_sub_index >= 0
        new_value = (@search_sub_index < options.length) ? options[@search_sub_index] : nil
        if @filters[filter] != new_value
          pbPlayDecisionSE
          @filters[filter] = new_value
          refresh
        end
      elsif @search_sub_index == -2   # OK
        pbPlayDecisionSE
        return true
      elsif @search_sub_index == -3   # Cancel
        pbPlayDecisionSE
        @filters[filter] = @old_filter
        return true
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      @filters[filter] = @old_filter
      return true
    elsif Input.trigger?(Input::ACTION)
      @search_sub_index = -2   # OK
    end
    return false
  end

  def update_input_button_grid_types(filter, options, columns, has_blank)
    if Input.trigger?(Input::USE)
      if @search_sub_index >= 0
        new_value = (@search_sub_index < options.length) ? options[@search_sub_index] : nil
        if @search_sub_index >= options.length   # Blank/nil button
          filter_to_change = (@filters[:type2] != new_value) ? :type2 : :type1
          if @filters[filter_to_change] != new_value
            pbPlayDecisionSE
            @filters[filter_to_change] = new_value
            refresh
          end
        else
          pbPlayDecisionSE
          if @filters[:type1] == new_value
            @filters[:type1] = @filters[:type2]
            @filters[:type2] = nil
          elsif @filters[:type2] == new_value
            @filters[:type2] = nil
          elsif @filters[:type1].nil?
            @filters[:type1] = new_value
          else
            @filters[:type2] = new_value
          end
          refresh
        end
      elsif @search_sub_index == -2   # OK
        pbPlayDecisionSE
        return true
      elsif @search_sub_index == -3   # Cancel
        pbPlayDecisionSE
        @filters[:type1] = @old_filter[0]
        @filters[:type2] = @old_filter[1]
        return true
      end
      return false
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      @filters[:type1] = @old_filter[0]
      @filters[:type2] = @old_filter[1]
      return true
    end
    return update_input_button_grid(filter, options, columns, has_blank)
  end

  def update_input_height_weight(min_filter, max_filter, intervals)
    max_offset = 100
    old_index = @search_sub_index
    # Check for cursor movement
    if Input.repeat?(Input::UP)
      if @search_sub_index < -1   # From OK/Cancel
        @search_sub_index = intervals.index(@filters[min_filter]) || 0
      elsif @search_sub_index < max_offset   # From min height/weight
        @search_sub_index = max_offset + (intervals.index(@filters[max_filter]) || (intervals.length - 1))
      end
    elsif Input.repeat?(Input::DOWN)
      if @search_sub_index >= max_offset   # From max height/weight
        @search_sub_index = intervals.index(@filters[min_filter]) || 0
      elsif @search_sub_index >= 0   # From min height/weight
        @search_sub_index = -2
      end
    elsif Input.repeat?(Input::LEFT)
      min_index = intervals.index(@filters[min_filter]) || 0
      max_index = intervals.index(@filters[max_filter]) || (intervals.length - 1)
      if @search_sub_index >= max_offset   # Max height/weight
        if max_index > min_index
          @filters[max_filter] = intervals[max_index - 1]
          @search_sub_index = max_offset + (intervals.index(@filters[max_filter]) || (intervals.length - 1))
          refresh
        end
      elsif @search_sub_index >= 0   # Min height/weight
        if min_index > 0
          @filters[min_filter] = intervals[min_index - 1]
          @search_sub_index = intervals.index(@filters[min_filter]) || 0
          refresh
        end
      elsif @search_sub_index == -3   # Cancel
        @search_sub_index = -2   # OK
      end
    elsif Input.repeat?(Input::RIGHT)
      min_index = intervals.index(@filters[min_filter]) || 0
      max_index = intervals.index(@filters[max_filter]) || (intervals.length - 1)
      if @search_sub_index >= max_offset   # Max height/weight
        if max_index < intervals.length - 1
          @filters[max_filter] = intervals[max_index + 1]
          @search_sub_index = max_offset + (intervals.index(@filters[max_filter]) || (intervals.length - 1))
          refresh
        end
      elsif @search_sub_index >= 0   # Min height/weight
        if min_index < max_index
          @filters[min_filter] = intervals[min_index + 1]
          @search_sub_index = intervals.index(@filters[min_filter]) || 0
          refresh
        end
      elsif @search_sub_index == -2   # OK
        @search_sub_index = -3   # Cancel
      end
    end
    # Check for interaction
    if Input.trigger?(Input::USE)
      if @search_sub_index == -2   # OK
        pbPlayDecisionSE
        @filters[min_filter] = nil if @filters[min_filter] == intervals.first
        @filters[max_filter] = nil if @filters[max_filter] == intervals.last
        return true
      elsif @search_sub_index == -3   # Cancel
        pbPlayDecisionSE
        @filters[min_filter] = @old_filter[0]
        @filters[max_filter] = @old_filter[1]
        return true
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      @filters[min_filter] = @old_filter[0]
      @filters[max_filter] = @old_filter[1]
      return true
    elsif Input.trigger?(Input::ACTION)
      @search_sub_index = -2   # OK
    end
    return false
  end

  def update_input_sub_search
    case @page
    when :sort_by
      return update_input_button_grid(@page, order_texts.keys, BUTTON_GRID_ARRANGEMENTS[@page][:columns], false)
    when :first_letter
      return update_input_button_grid(@page, first_letter_texts, BUTTON_GRID_ARRANGEMENTS[@page][:columns], true)
    when :type
      types = []
      GameData::Type.each { |type| types.push(type.id) if !type.pseudo_type }
      return update_input_button_grid_types([:type1, :type2], types, BUTTON_GRID_ARRANGEMENTS[@page][:columns], true)
    when :height
      return update_input_height_weight(:min_height, :max_height, HEIGHT_INTERVALS)
    when :weight
      return update_input_height_weight(:min_weight, :max_weight, WEIGHT_INTERVALS)
    when :color
      return update_input_button_grid(@page, GameData::BodyColor.keys, BUTTON_GRID_ARRANGEMENTS[@page][:columns], true)
    when :shape
      return update_input_button_grid(@page, GameData::BodyShape.keys, BUTTON_GRID_ARRANGEMENTS[@page][:columns], true)
    end
    return true
  end

  # Generic navigate method usable by all search pages (except the main one).
  def navigate_sub_search(new_page)
    set_sub_search_initial_values(new_page)
    set_page(new_page)
    @sprites[:search_cursor].page = @page
    @sprites[:search_cursor].index = @search_sub_index
    # Navigate loop
    loop do
      Graphics.update
      Input.update
      update_visuals
      old_search_index = @search_sub_index
      break if update_input_sub_search
      if @search_sub_index != old_search_index
        pbPlayCursorSE
        @sprites[:search_cursor].index = @search_sub_index
      end
    end
    # Clean up
    set_page(:search)
    @sprites[:search_cursor].page = @page
    @sprites[:search_cursor].index = @search_index
  end
end

#===============================================================================
#
#===============================================================================
class UI::Pokedex < UI::BaseScreen
  ACTIONS = HandlerHash.new

  def initialize(dex_id)
    @dex_id = dex_id
    get_dex_list
    super()
  end

  def initialize_visuals
    @visuals = UI::PokedexVisuals.new(@dex, @dex_id, $PokemonGlobal.pokedexIndex[@dex_id] || 0)
  end

  #-----------------------------------------------------------------------------

  def species
    return @visuals.species
  end

  #-----------------------------------------------------------------------------

  def get_dex_list
    if @dex_id < 0   # National Dex
      all_species = []
      GameData::Species.each_species { |species| all_species.push(species.id) }
    else
      all_species = pbAllRegionalSpecies(@dex_id)
      if !all_species || all_species.empty?
        raise _INTL("Regional Dex number {1} is undefined or empty.", @dex_id)
      end
    end
    @dex = []
    number_shift = Settings::DEXES_WITH_OFFSETS.include?(@dex_id)
    species_map = {}
    all_species.each_with_index do |this_species, i|
      species_data = GameData::Species.get(this_species)
      data = {
        :number  => i + 1,
        :species => species_data.species,
        :name    => species_data.name,
        :types   => [species_data.types.clone],
        :height  => [species_data.height],
        :weight  => [species_data.weight],
        :color   => [species_data.color],
        :shape   => [species_data.shape]
      }
      data[:number] -= 1 if number_shift
      @dex.push(data)
      species_map[data[:species]] = @dex.length - 1
    end
    # Get searchable properties for all alternate forms of the species in the Dex
    GameData::Species.each do |sp|
      next if sp.form == 0 || species_map[sp.species].nil?
      @dex[species_map[sp.species]][:types].push(sp.types.clone)
      @dex[species_map[sp.species]][:height].push(sp.height)
      @dex[species_map[sp.species]][:weight].push(sp.weight)
      @dex[species_map[sp.species]][:color].push(sp.color)
      @dex[species_map[sp.species]][:shape].push(sp.shape)
    end
  end

  def display_dex
    return @visuals.display_dex
  end

  def set_index(new_index)
    @visuals.set_index(new_index)
  end

  #-----------------------------------------------------------------------------

  ACTIONS.add(:view_entry, {
    :effect => proc { |screen|
      pbFadeOutIn do
        dex = screen.display_dex
        seen_dex = dex.filter { |entry| $player.pokedex.seen?(entry[1]) }
        species = screen.species
        index = seen_dex.index { |entry| entry[1] == species }
        new_index = UI::PokedexEntry.new(seen_dex, index).main
        if new_index == index
          screen.refresh   # In case form has changed
        else
          new_species = seen_dex[new_index][1]
          new_main_index = dex.index { |entry| entry[1] == new_species }
          screen.set_index(new_main_index)
        end
      end
    }
  })
  ACTIONS.add(:open_search, {
    :effect => proc { |screen|
      screen.visuals.navigate_search
    }
  })
end
