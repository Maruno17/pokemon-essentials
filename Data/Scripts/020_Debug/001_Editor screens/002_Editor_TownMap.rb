module Debug::PBSEditor; end

#===============================================================================
#
#===============================================================================
class Debug::PBSEditor::TownMap < Debug::EditorBase

  REGIONS_LIST_WIDTH    = 196
  REGIONS_LIST_HEIGHT   = (ROW_HEIGHT * 8) + ((EDGE_BUFFER + 1) * 2)   # 196
  REGIONS_BUTTON_WIDTH  = (REGIONS_LIST_WIDTH - ELEMENT_SPACING) / 2
  REGIONS_BUTTON_HEIGHT = 26

  REGIONS_LIST_AREA_X      = CONTAINER_BORDER
  REGIONS_LIST_AREA_Y      = MENU_BAR_Y + MENU_BAR_HEIGHT + (CONTAINER_BORDER * 2)
  REGIONS_LIST_AREA_WIDTH  = REGIONS_LIST_WIDTH + (ELEMENT_SPACING - EDGE_BUFFER) * 2
  REGIONS_LIST_AREA_HEIGHT = HEADER_HEIGHT + REGIONS_LIST_HEIGHT + ELEMENT_SPACING + REGIONS_BUTTON_HEIGHT + EDGE_BUFFER

  GAME_SWITCHES_LIST_WIDTH    = REGIONS_LIST_WIDTH
  GAME_SWITCHES_LIST_HEIGHT   = (ROW_HEIGHT * 8) + ((EDGE_BUFFER + 1) * 2)   # 196
  GAME_SWITCHES_BUTTON_WIDTH  = (GAME_SWITCHES_LIST_WIDTH - ELEMENT_SPACING) / 2
  GAME_SWITCHES_BUTTON_HEIGHT = 26

  DISPLAY_CONTROLS_X      = REGIONS_LIST_AREA_X
  DISPLAY_CONTROLS_Y      = REGIONS_LIST_AREA_Y + REGIONS_LIST_AREA_HEIGHT + (CONTAINER_BORDER * 2)
  DISPLAY_CONTROLS_WIDTH  = REGIONS_LIST_AREA_WIDTH
  DISPLAY_CONTROLS_HEIGHT = WINDOW_HEIGHT - DISPLAY_CONTROLS_Y - CONTAINER_BORDER

  MAP_X      = REGIONS_LIST_AREA_X + REGIONS_LIST_AREA_WIDTH + (CONTAINER_BORDER * 2)
  MAP_Y      = REGIONS_LIST_AREA_Y
  MAP_WIDTH  = UI::TownMapVisuals::MAP_SIZE[0]
  MAP_HEIGHT = UI::TownMapVisuals::MAP_SIZE[1]

  VERTICAL_SCROLLBAR_X      = MAP_X + MAP_WIDTH + (EDGE_BUFFER * 2) + 1
  VERTICAL_SCROLLBAR_Y      = MAP_Y
  VERTICAL_SCROLLBAR_WIDTH  = SCROLLBAR_THICKNESS
  VERTICAL_SCROLLBAR_HEIGHT = MAP_HEIGHT

  HORIZONTAL_SCROLLBAR_X      = MAP_X
  HORIZONTAL_SCROLLBAR_Y      = MAP_Y + MAP_HEIGHT + (EDGE_BUFFER * 2) + 1
  HORIZONTAL_SCROLLBAR_WIDTH  = MAP_WIDTH
  HORIZONTAL_SCROLLBAR_HEIGHT = SCROLLBAR_THICKNESS

  REGION_CONTROLS_X      = VERTICAL_SCROLLBAR_X + VERTICAL_SCROLLBAR_WIDTH + (CONTAINER_BORDER * 2)
  REGION_CONTROLS_Y      = REGIONS_LIST_AREA_Y
  REGION_CONTROLS_WIDTH  = WINDOW_WIDTH - REGION_CONTROLS_X - CONTAINER_BORDER
  REGION_CONTROLS_HEIGHT = MAP_HEIGHT + (EDGE_BUFFER * 2) + 1 + HORIZONTAL_SCROLLBAR_HEIGHT

  REGION_CONTROLS_LABEL_WIDTH   = 105
  REGION_CONTROLS_CONTROL_WIDTH = REGION_CONTROLS_WIDTH - REGION_CONTROLS_LABEL_WIDTH - 1

  POINT_CONTROLS_X      = MAP_X
  POINT_CONTROLS_Y      = HORIZONTAL_SCROLLBAR_Y + HORIZONTAL_SCROLLBAR_HEIGHT + (CONTAINER_BORDER * 2)
  POINT_CONTROLS_WIDTH  = WINDOW_WIDTH - POINT_CONTROLS_X - CONTAINER_BORDER
  POINT_CONTROLS_HEIGHT = WINDOW_HEIGHT - POINT_CONTROLS_Y - CONTAINER_BORDER

  POINT_CONTROLS_LABEL_WIDTH   = 125
  POINT_CONTROLS_CONTROL_WIDTH = 300
  POINT_CONTROLS_BUTTON_WIDTH  = 96
  POINT_CONTROLS_BUTTON_HEIGHT = 26

  MAP_FOLDER         = "Graphics/UI/Town Map/"
  GRAPHICS_BLACKLIST = [/^bg/, "cursor", /^details_marking_bg/, /^details_panel/,
                        "icon_fly", "icon_marking", "map_markings", /^marking_bg/,
                        "marking_cursor", /^pin_/, /^player_/]

  def initialize_parameters
    @data      = load_data("Data/#{GameData::TownMap::DATA_FILENAME}") || {}
    if @data.empty?
      @data[0] = GameData::TownMap.new({ :id => 0 })
    end
    @region_id = @data.keys.first || 0
    @region    = @data[@region_id]   # An instance of GameData::TownMap
    determine_used_game_switches
    @coordinate     = nil
    @selected_point = nil
  end

  def initialize_viewports
    super
    @map_viewport = Viewport.new(MAP_X, MAP_Y, MAP_WIDTH, MAP_HEIGHT)
    @map_viewport.z = @viewport.z + 1
  end

  def initialize_bitmaps
    return if @bitmaps[:point]
    btmp_width = 6
    btmp_height = 6
    # Point and selected point bitmaps
    btmp_graphic = %w(
      . . . . . .
      . . . . X X
      . . . X - -
      . . X - X X
      . X - X ~ ~
      . X - X ~ ~
    )
    @bitmaps[:point] = Bitmap.new(btmp_width * 2, btmp_height * 2) if !@bitmaps[:point]
    @bitmaps[:selected_point] = Bitmap.new(btmp_width * 2, btmp_height * 2) if !@bitmaps[:selected_point]
    btmps = [@bitmaps[:point], @bitmaps[:selected_point]]
    bg_color = get_color_of(:background)
    unsel_color = Color.new(128, 128, 128)
    sel_color = Color.new(192, 0, 0)
    btmp_graphic.length.times do |i|
      next if btmp_graphic[i] == "."
      btmps.each_with_index do |btmp, j|
        if j == 0
          clr = (btmp_graphic[i] == "-") ? unsel_color : bg_color
        else
          clr = (["-", "~"].include?(btmp_graphic[i])) ? sel_color : bg_color
        end
        pixel_x = i % btmp_width
        pixel_y = i / btmp_width
        btmp.fill_rect(pixel_x, pixel_y, 1, 1, clr)
        btmp.fill_rect(btmp.width - 1 - pixel_x, pixel_y, 1, 1, clr)
        btmp.fill_rect(pixel_x, btmp.height - 1 - pixel_y, 1, 1, clr)
        btmp.fill_rect(btmp.width - 1 - pixel_x, btmp.height - 1 - pixel_y, 1, 1, clr)
      end
    end
  end

  def initialize_overlay
    @sprites[:map_extras_overlay] = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @map_viewport)
    @sprites[:map_extras_overlay].z = 1
    @sprites[:map_grid_overlay] = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @map_viewport)
    @sprites[:map_grid_overlay].z = 100
  end

  def initialize_sprites
    @sprites[:map] = IconSprite.new(0, 0, @map_viewport)
    @sprites[:selected_point] = Sprite.new(@map_viewport)
    @sprites[:selected_point].bitmap = @bitmaps[:selected_point]
    @sprites[:selected_point].ox = @sprites[:selected_point].bitmap.width / 2
    @sprites[:selected_point].oy = @sprites[:selected_point].bitmap.height / 2
    @sprites[:selected_point].z = 10
  end

  def initialize_controls
    super
    initialize_regions_list_controls
    initialize_display_options
    initialize_map_controls
    initialize_region_property_controls
    initialize_point_controls
  end

  def initialize_regions_list_controls
    # Regions header
    label = UIControls::Label.new(REGIONS_LIST_AREA_WIDTH, HEADER_HEIGHT, @viewport, _INTL("Regions"))
    label.header = true
    @components.add_control_at(:regions_label,
                               REGIONS_LIST_AREA_X + HEADER_OFFSET_X,
                               REGIONS_LIST_AREA_Y + HEADER_OFFSET_Y,
                               label)
    # Regions list
    list = UIControls::List.new(REGIONS_LIST_WIDTH, REGIONS_LIST_HEIGHT, @viewport, [])
    @components.add_control_at(:regions_list, REGIONS_LIST_AREA_X + EDGE_BUFFER, REGIONS_LIST_AREA_Y + HEADER_HEIGHT, list)
    # Add and Delete buttons
    [
      [:add_region, _INTL("Add")],
      [:delete_region, _INTL("Delete")]
    ].each_with_index do |button, i|
      btn = UIControls::Button.new(REGIONS_BUTTON_WIDTH, REGIONS_BUTTON_HEIGHT, @viewport, button[1])
      @components.add_control_at(
        button[0],
        REGIONS_LIST_AREA_X + EDGE_BUFFER + (i * (REGIONS_BUTTON_WIDTH + ELEMENT_SPACING)),
        REGIONS_LIST_AREA_Y + HEADER_HEIGHT + REGIONS_LIST_HEIGHT + ELEMENT_SPACING,
        btn
      )
    end
  end

  def initialize_display_options
    # Game Switches header
    label = UIControls::Label.new(DISPLAY_CONTROLS_WIDTH, HEADER_HEIGHT, @viewport, _INTL("Game Switches"))
    label.header = true
    @components.add_control_at(:display_options_label,
                               DISPLAY_CONTROLS_X + HEADER_OFFSET_X,
                               DISPLAY_CONTROLS_Y + HEADER_OFFSET_Y,
                               label)
    # Game Switches list
    list = UIControls::CheckboxList.new(GAME_SWITCHES_LIST_WIDTH, GAME_SWITCHES_LIST_HEIGHT, @viewport, [], ROW_HEIGHT)
    @components.add_control_at(:game_switches,
      DISPLAY_CONTROLS_X + EDGE_BUFFER, DISPLAY_CONTROLS_Y + HEADER_HEIGHT,
      list
    )
    # All and None buttons
    [
      [:all_switches, _INTL("Select all")],
      [:no_switches, _INTL("Select none")]
    ].each_with_index do |button, i|
      btn = UIControls::Button.new(GAME_SWITCHES_BUTTON_WIDTH, GAME_SWITCHES_BUTTON_HEIGHT, @viewport, button[1])
      @components.add_control_at(
        button[0],
        DISPLAY_CONTROLS_X + EDGE_BUFFER + (i * (GAME_SWITCHES_BUTTON_WIDTH + ELEMENT_SPACING)),
        DISPLAY_CONTROLS_Y + HEADER_HEIGHT + GAME_SWITCHES_LIST_HEIGHT + ELEMENT_SPACING,
        btn
      )
    end
  end

  def initialize_map_controls
    # Clickable area
    @components.add_control_at(:map_control, MAP_X, MAP_Y,
                               UIControls::ClickableArea.new(MAP_WIDTH, MAP_HEIGHT, @viewport, false))
    @components.get_control(:map_control).changed_upon_click = true
    # Vertical scrollbar
    @components.add_control_at(:v_scrollbar, VERTICAL_SCROLLBAR_X, VERTICAL_SCROLLBAR_Y,
                               UIControls::Scrollbar.new(VERTICAL_SCROLLBAR_HEIGHT, @viewport, :vertical))
    # Horizontal scrollbar
    @components.add_control_at(:h_scrollbar, HORIZONTAL_SCROLLBAR_X, HORIZONTAL_SCROLLBAR_Y,
                               UIControls::Scrollbar.new(HORIZONTAL_SCROLLBAR_WIDTH, @viewport, :horizontal))
  end

  def initialize_region_property_controls
    label_x = REGION_CONTROLS_X
    row_y = REGION_CONTROLS_Y
    # Region properties header
    label = UIControls::Label.new(REGION_CONTROLS_WIDTH, HEADER_HEIGHT, @viewport, _INTL("Region properties"))
    label.header = true
    @components.add_control_at(:region_properties_label,
                               REGION_CONTROLS_X + HEADER_OFFSET_X,
                               row_y + HEADER_OFFSET_Y,
                               label)
    row_y += HEADER_HEIGHT
    # Region number
    label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("ID"))
    @components.add_control_at(:region_id_label, label_x, row_y, label)
    text_box = UIControls::FittedNumberTextBox.new(52, ROW_HEIGHT, @viewport, 0, 999, 0)
    @components.add_control_at(:region_id, label_x + REGION_CONTROLS_LABEL_WIDTH, row_y, text_box)
    row_y += ROW_HEIGHT
    # Region name
    label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("Name"))
    @components.add_control_at(:region_name_label, label_x, row_y, label)
    text_box = UIControls::TextBox.new(REGION_CONTROLS_CONTROL_WIDTH, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:region_name, label_x + REGION_CONTROLS_LABEL_WIDTH, row_y, text_box)
    row_y += ROW_HEIGHT
    # Region filename
    label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("Filename"))
    @components.add_control_at(:filename_label, label_x, row_y, label)
    button = UIControls::Button.new(INLINE_BUTTON_WIDTH, INLINE_BUTTON_HEIGHT, @viewport, _INTL("Edit"))
    @components.add_control_at(:filename_button, label_x + REGION_CONTROLS_LABEL_WIDTH + REGION_CONTROLS_CONTROL_WIDTH - button.width, row_y + 2, button)
    label = UIControls::Label.new(REGION_CONTROLS_CONTROL_WIDTH - button.width, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:filename, label_x + REGION_CONTROLS_LABEL_WIDTH, row_y, label)
    row_y += ROW_HEIGHT
    # Margins, point size and map size
    [
      [:margins_x, :margins_y, _INTL("Margins"), _INTL("pixels"), 0, 999],
      [:point_size_x, :point_size_y, _INTL("Point size"), _INTL("pixels"), 2, 999],
      [:size_x, :size_y, _INTL("Map size"), _INTL("points"), 2, 999]
    ].each do |property|
      label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, property[2])
      @components.add_control_at((property[0].to_s + "_label").to_sym, label_x, row_y, label)
      2.times do |i|
        text_box = UIControls::FittedNumberTextBox.new(52, ROW_HEIGHT, @viewport, property[4], property[5], property[4])
        @components.add_control_at(property[i], label_x + REGION_CONTROLS_LABEL_WIDTH + (i * 77), row_y, text_box)
      end
      label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, "×")
      @components.add_control_at((property[0].to_s + "_mult_label").to_sym, label_x + REGION_CONTROLS_LABEL_WIDTH + 56, row_y, label)
      label = UIControls::Label.new(REGION_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, property[3])
      @components.add_control_at((property[0].to_s + "_units_label").to_sym, label_x + REGION_CONTROLS_LABEL_WIDTH + 133, row_y, label)
      row_y += ROW_HEIGHT
    end
  end

  def initialize_point_controls
    column_width = MAP_WIDTH + (EDGE_BUFFER * 2) + 1 + VERTICAL_SCROLLBAR_WIDTH
    label_x = POINT_CONTROLS_X
    row_y = POINT_CONTROLS_Y
    # Point properties header
    label = UIControls::Label.new(column_width, HEADER_HEIGHT, @viewport, _INTL("Point properties"))
    label.header = true
    @components.add_control_at(:point_properties_label,
                               POINT_CONTROLS_X + HEADER_OFFSET_X,
                               row_y + HEADER_OFFSET_Y,
                               label)
    row_y += HEADER_HEIGHT
    # Position
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("Position"))
    @components.add_control_at(:position_label, label_x, row_y, label)
    2.times do |i|
      text_box = UIControls::FittedNumberTextBox.new(52, ROW_HEIGHT, @viewport, 0, 999, 0)
      @components.add_control_at([:position_x, :position_y][i], label_x + POINT_CONTROLS_LABEL_WIDTH + (i * 77), row_y, text_box)
    end
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, ",")
    @components.add_control_at(:position_comma_label, label_x + POINT_CONTROLS_LABEL_WIDTH + 56, row_y, label)
    row_y += ROW_HEIGHT
    # Point name
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT,
                                  @viewport, _INTL("Name"))
    @components.add_control_at(:point_name_label, label_x, row_y, label)
    text_box = UIControls::TextBox.new(POINT_CONTROLS_CONTROL_WIDTH, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:point_name, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, text_box)
    row_y += ROW_HEIGHT
    # Point description
    # TODO: Make a multiline text box for this.
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT,
                                  @viewport, _INTL("Description"))
    @components.add_control_at(:point_description_label, label_x, row_y, label)
    text_box = UIControls::TextBox.new(POINT_CONTROLS_CONTROL_WIDTH, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:point_description, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, text_box)
    row_y += ROW_HEIGHT
    # Point image filename
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT,
                                  @viewport, _INTL("Image filename"))
    @components.add_control_at(:point_filename_label, label_x, row_y, label)
    button = UIControls::Button.new(INLINE_BUTTON_WIDTH, INLINE_BUTTON_HEIGHT, @viewport, _INTL("Edit"))
    @components.add_control_at(:point_filename_button, label_x + POINT_CONTROLS_LABEL_WIDTH + POINT_CONTROLS_CONTROL_WIDTH - button.width, row_y + 2, button)
    label = UIControls::Label.new(POINT_CONTROLS_CONTROL_WIDTH - button.width, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:point_filename, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, label)
    row_y += ROW_HEIGHT
    # Game Switch
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("Game Switch"))
    @components.add_control_at(:point_switch_label, label_x, row_y, label)
    text_box = UIControls::FittedNumberTextBox.new(52, ROW_HEIGHT, @viewport, 0, 999, 0)
    @components.add_control_at(:point_switch, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, text_box)
    row_y += ROW_HEIGHT

    # Fly section label
    label = UIControls::Label.new(column_width, HEADER_HEIGHT, @viewport, _INTL("Using Fly"))
    label.underlined = true
    @components.add_control_at(:point_fly_section_label, label_x, row_y, label)
    row_y += ROW_HEIGHT

    # Fly destination
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT,
                                  @viewport, _INTL("Fly destination"))
    @components.add_control_at(:point_fly_destination_label, label_x, row_y, label)
    button = UIControls::Button.new(INLINE_BUTTON_WIDTH, INLINE_BUTTON_HEIGHT, @viewport, _INTL("Edit"))
    @components.add_control_at(:point_fly_destination_button, label_x + POINT_CONTROLS_LABEL_WIDTH + POINT_CONTROLS_CONTROL_WIDTH - button.width, row_y + 2, button)
    label = UIControls::Label.new(POINT_CONTROLS_CONTROL_WIDTH - button.width, ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:point_fly_destination, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, label)
    row_y += ROW_HEIGHT
    # Hide Fly icon
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT,
                                  @viewport, _INTL("Hide Fly icon?"))
    @components.add_control_at(:point_hide_fly_icon_label, label_x, row_y, label)
    checkbox = UIControls::Checkbox.new(POINT_CONTROLS_CONTROL_WIDTH, ROW_HEIGHT, @viewport)
    @components.add_control_at(:point_hide_fly_icon, label_x + POINT_CONTROLS_LABEL_WIDTH, row_y, checkbox)
    row_y += ROW_HEIGHT

    # Fly icon offset
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("Fly icon offset"))
    @components.add_control_at(:point_fly_icon_offset_label, label_x, row_y, label)
    2.times do |i|
      text_box = UIControls::FittedNumberTextBox.new(52, ROW_HEIGHT, @viewport, 0, 999, 0)
      @components.add_control_at([:point_fly_icon_offset_x, :point_fly_icon_offset_y][i], label_x + POINT_CONTROLS_LABEL_WIDTH + (i * 77), row_y, text_box)
    end
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, "×")
    @components.add_control_at(:point_fly_icon_offset_mult_label, label_x + POINT_CONTROLS_LABEL_WIDTH + 56, row_y, label)
    label = UIControls::Label.new(POINT_CONTROLS_LABEL_WIDTH, ROW_HEIGHT, @viewport, _INTL("pixels"))
    @components.add_control_at(:point_fly_icon_offset_units_label, label_x + POINT_CONTROLS_LABEL_WIDTH + 133, row_y, label)
    row_y += ROW_HEIGHT
    # Empty row
    row_y += ROW_HEIGHT
    # Delete point button
    btn = UIControls::Button.new(POINT_CONTROLS_BUTTON_WIDTH, POINT_CONTROLS_BUTTON_HEIGHT, @viewport, _INTL("Delete point"))
    @components.add_control_at(:delete_point, label_x + EDGE_BUFFER, row_y, btn)
  end

  def initialize_values
    set_all_component_values
  end

  def dispose
    super
    @map_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def editor_name
    return _INTL("Town Map Editor")
  end

  #-----------------------------------------------------------------------------

  def draw_background
    super
    bg_color = get_color_of(:background)
    contrast_color = get_color_of(:line)
    middle_color = get_color_of(:gray_background)
    # Outline around elements
    [
      [REGIONS_LIST_AREA_X, REGIONS_LIST_AREA_Y, REGIONS_LIST_AREA_WIDTH, REGIONS_LIST_AREA_HEIGHT],
      [DISPLAY_CONTROLS_X, DISPLAY_CONTROLS_Y, DISPLAY_CONTROLS_WIDTH, DISPLAY_CONTROLS_HEIGHT],
      [MAP_X, MAP_Y,
       MAP_WIDTH + (EDGE_BUFFER * 2) + 1 + VERTICAL_SCROLLBAR_WIDTH,
       MAP_HEIGHT + (EDGE_BUFFER * 2) + 1 + HORIZONTAL_SCROLLBAR_HEIGHT],
      [REGION_CONTROLS_X, REGION_CONTROLS_Y, REGION_CONTROLS_WIDTH, REGION_CONTROLS_HEIGHT],
      [POINT_CONTROLS_X, POINT_CONTROLS_Y, POINT_CONTROLS_WIDTH, POINT_CONTROLS_HEIGHT]
    ].each do |rect|
      @sprites[:background].bitmap.border_rect(*rect, CONTAINER_BORDER, bg_color, contrast_color, middle_color)
    end
    # Lines separating scrollbars from map
    [
      [VERTICAL_SCROLLBAR_X - EDGE_BUFFER - 1, VERTICAL_SCROLLBAR_Y - EDGE_BUFFER - 1,
       1, VERTICAL_SCROLLBAR_HEIGHT + HORIZONTAL_SCROLLBAR_HEIGHT + (EDGE_BUFFER + 1) * 3],
      [HORIZONTAL_SCROLLBAR_X - EDGE_BUFFER - 1, HORIZONTAL_SCROLLBAR_Y - EDGE_BUFFER - 1,
       HORIZONTAL_SCROLLBAR_WIDTH + VERTICAL_SCROLLBAR_WIDTH + (EDGE_BUFFER + 1) * 3, 1]
    ].each do |rect|
      @sprites[:background].bitmap.fill_rect(*rect, contrast_color)
    end
    # Fill unused area where the two map scrollbars meet
    rect = [
      VERTICAL_SCROLLBAR_X + 1, HORIZONTAL_SCROLLBAR_Y + 1,
      VERTICAL_SCROLLBAR_WIDTH - 2, HORIZONTAL_SCROLLBAR_HEIGHT - 2
    ]
    @sprites[:background].bitmap.fill_rect(*rect, middle_color)
    @sprites[:background].bitmap.border_rect(*rect, 1, contrast_color)
  end

  def set_region(new_region)
    return if @region_id == new_region
    @region_id = new_region
    @region        = @data[@region_id]   # An instance of GameData::TownMap
    determine_used_game_switches
    set_coordinate(nil, nil)
    set_all_component_values
    refresh
  end

  def set_coordinate(new_x, new_y, force_set = false)
    return if @coordinate && @coordinate == [new_x, new_y] && !force_set
    return if new_x.nil? || new_y.nil?
    @coordinate = [new_x, new_y]
    @selected_point = @region.points.select { |point| point[:position] == @coordinate }&.first
    set_point_component_values
    @sprites[:selected_point].visible = !@coordinate.nil?
    if @coordinate
      @sprites[:selected_point].x = @region.margins[0] + (@coordinate[0] * @region.point_size[0]) + (@region.point_size[0] / 2)
      @sprites[:selected_point].y = @region.margins[1] + (@coordinate[1] * @region.point_size[1]) + (@region.point_size[1] / 2)
    end
  end

  def set_all_component_values
    set_display_component_values
    set_region_component_values
    set_point_component_values
  end

  def set_display_component_values
    @components.get_control(:game_switches).options = @game_switches
    @components.get_control(:game_switches).select_all
  end

  # NOTE: Places that call this method later call refresh, so no need to refresh
  #       now.
  def set_region_component_values
    @components.get_control(:region_id).value    = @region_id
    @components.get_control(:region_name).value  = @region.real_name
    @components.get_control(:filename).text      = @region.filename || ""
    @components.get_control(:margins_x).value    = @region.margins[0]
    @components.get_control(:margins_y).value    = @region.margins[1]
    @components.get_control(:point_size_x).value = @region.point_size[0]
    @components.get_control(:point_size_y).value = @region.point_size[1]
    @components.get_control(:size_x).value       = @region.size[0]
    @components.get_control(:size_y).value       = @region.size[1]
  end

  def set_point_component_values
    able_controls = [:position_x, :position_y, :point_name, :point_description,
                     :point_switch, :point_hide_fly_icon,
                     :point_fly_icon_offset_x, :point_fly_icon_offset_y]
    if @coordinate
      able_controls.each { |ctrl| @components.get_control(ctrl).enable }
    else
      able_controls.each { |ctrl| @components.get_control(ctrl).disable }
    end
    if @selected_point.nil?
      @components.get_control(:position_x).value              = (@coordinate) ? @coordinate[0] : 0
      @components.get_control(:position_y).value              = (@coordinate) ? @coordinate[1] : 0
      @components.get_control(:point_name).value              = ""
      @components.get_control(:point_description).value       = ""
      @components.get_control(:point_filename).text           = ""
      @components.get_control(:point_switch).value            = 0
      @components.get_control(:point_fly_destination).text    = ""
      @components.get_control(:point_hide_fly_icon).value     = false
      @components.get_control(:point_fly_icon_offset_x).value = 0
      @components.get_control(:point_fly_icon_offset_y).value = 0
      return
    end
    @components.get_control(:position_x).value              = @coordinate[0]
    @components.get_control(:position_y).value              = @coordinate[1]
    @components.get_control(:point_name).value              = @selected_point[:real_name]
    @components.get_control(:point_description).value       = @selected_point[:real_description]
    @components.get_control(:point_filename).text           = @selected_point[:image]
    @components.get_control(:point_switch).value            = @selected_point[:switch]
    set_point_fly_spot_text
    @components.get_control(:point_hide_fly_icon).value     = @selected_point[:hide_fly_icon]
    @components.get_control(:point_fly_icon_offset_x).value = (@selected_point[:fly_icon_offset]) ? @selected_point[:fly_icon_offset][0] : 0
    @components.get_control(:point_fly_icon_offset_y).value = (@selected_point[:fly_icon_offset]) ? @selected_point[:fly_icon_offset][1] : 0
  end

  def set_point_fly_spot_text
    if @selected_point.nil?
      @components.get_control(:point_fly_destination).text = ""
      return
    end
    spot = @selected_point[:fly_spot]
    fly_spot_text = ""
    if spot
      map_infos = pbLoadMapInfos
      # TODO: Crop map_name if the full string ends ups too long.
      map_name = map_infos[spot[0]].name
      fly_spot_text = sprintf("%03d: %s (%d,%d)", spot[0], map_name, spot[1], spot[2])
    end
    @components.get_control(:point_fly_destination).text = fly_spot_text
  end

  def determine_used_game_switches
    @game_switches = []
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @region_id
      next if graphic[1] <= 0
      next if @game_switches.any? { |val| val[0] == graphic[1] }
      switch_name = $data_system.switches[graphic[1]]
      @game_switches.push([graphic[1], "#{graphic[1]}: #{switch_name}"])
    end
    @game_switches.sort! { |a, b| a[0] <=> b[0] }
  end

  # Creates point data at @coordinate if it doesn't exist.
  def ensure_point_data
    return if @selected_point
    @selected_point = { :position => @coordinate.clone, :real_name => "" }
    @region.points.push(@selected_point)
    refresh_map_points
  end

  # Checks point data at @coordinate and deletes it if it's empty.
  def ensure_no_point_data
    return if @selected_point.nil?
    return if (@selected_point[:real_name] && @selected_point[:real_name] != "") ||
              (@selected_point[:real_description] && @selected_point[:real_description] != "") ||
              (@selected_point[:image] && @selected_point[:image] != "") ||
              (@selected_point[:switch] && @selected_point[:switch] != 0) ||
              @selected_point[:fly_spot] ||
              @selected_point[:hide_fly_icon] ||
              (@selected_point[:fly_icon_offset] && @selected_point[:fly_icon_offset] != [0, 0])
    @region.points.delete_if { |point| point[:position] == @coordinate }
    refresh_map_points
    set_coordinate(*@coordinate, true)
  end

  #-----------------------------------------------------------------------------

  def refresh
    refresh_regions_list
    refresh_map_filename
  end

  def refresh_regions_list
    regions = []
    index = 0
    @data.each_pair do |key, region|
      index = regions.length if key == @region_id
      regions.push([key, "[#{key}] #{region.real_name}"])
    end
    @components.get_control(:regions_list).options = regions
    @components.get_control(:regions_list).selected = index
  end

  def refresh_map_filename
    if @region.filename
      @sprites[:map].visible = true
      @sprites[:map].setBitmap(MAP_FOLDER + @region.filename)
    else
      @sprites[:map].visible = false
    end
    @components.get_control(:filename).text = @region.filename
    clamp_size_property
    @components.get_control(:v_scrollbar).range = [@sprites[:map].height || 1, 1].max
    @components.get_control(:v_scrollbar).slider_top = 0
    @components.get_control(:h_scrollbar).range = [@sprites[:map].width || 1, 1].max
    @components.get_control(:h_scrollbar).slider_top = 0
    refresh_map_extra_graphics
    refresh_map_grid
    refresh_map_points
  end

  def refresh_map_extra_graphics
    if @sprites[:map].width > @sprites[:map_extras_overlay].width ||
       @sprites[:map].height > @sprites[:map_extras_overlay].height
      @sprites[:map_extras_overlay].dispose
      @sprites[:map_extras_overlay] = BitmapSprite.new(@sprites[:map].width, @sprites[:map].height, @map_viewport)
      @sprites[:map_extras_overlay].z = 1
    end
    switches = @components.get_control(:game_switches).value
    @sprites[:map_extras_overlay].bitmap.clear
    return if !switches
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != @region_id
      # TODO: Add a checkbox to mimic the Town Map being a wall map?
#      next if !graphic[5] && @mode == :wall_map
      next if graphic[1] <= 0 || !switches[graphic[1]]
      @sprites[:map_extras_overlay].draw_image(
        MAP_FOLDER + graphic[4],
        (graphic[2] * @region.point_size[0]) + @region.margins[0],
        (graphic[3] * @region.point_size[1]) + @region.margins[1]
      )
    end
  end

  def refresh_map_grid
    if @sprites[:map].width > @sprites[:map_grid_overlay].width ||
       @sprites[:map].height > @sprites[:map_grid_overlay].height
      @sprites[:map_grid_overlay].dispose
      @sprites[:map_grid_overlay] = BitmapSprite.new(@sprites[:map].width, @sprites[:map].height, @map_viewport)
      @sprites[:map_grid_overlay].z = 100
    end
    @sprites[:map_grid_overlay].bitmap.clear
    return if @sprites[:map].bitmap.nil? || @sprites[:map].width == 32
    margins = @region.margins
    point_size = @region.point_size
    color = Color.new(0, 0, 0, 48)
    @region.size[0].times do |i|
      @region.size[1].times do |j|
        point_size[0].times do |sq_i|
          2.times do |sq_j|
            x_coord = margins[0] + (i * point_size[0]) + sq_i
            y_coord = margins[1] + (j * point_size[1]) + (sq_j * (point_size[1] - 1))
            next if (x_coord + y_coord).odd?
            @sprites[:map_grid_overlay].bitmap.fill_rect(x_coord, y_coord, 1, 1, color)
          end
        end
        point_size[1].times do |sq_j|
          2.times do |sq_i|
            x_coord = margins[0] + (i * point_size[0]) + (sq_i * (point_size[0] - 1))
            y_coord = margins[1] + (j * point_size[1]) + sq_j
            next if (x_coord + y_coord).odd?
            @sprites[:map_grid_overlay].bitmap.fill_rect(x_coord, y_coord, 1, 1, color)
          end
        end
      end
    end
  end

  def refresh_map_points
    margins = @region.margins
    point_size = @region.point_size
    # Go through all sprites and reposition them/delete any that don't
    # correspond to an entry in @region.points
    @sprites.each_pair do |key, sprite|
      next if !sprite || sprite.disposed?
      next if !key.to_s[/^point_(\d+)_(\d+)$/]
      point_x = $~[1].to_i
      point_y = $~[2].to_i
      if @region.points.any? { |point| point[:position] == [point_x, point_y] }
        sprite.x = margins[0] + (point_x * point_size[0]) + (point_size[0] / 2)
        sprite.y = margins[1] + (point_y * point_size[1]) + (point_size[1] / 2)
      else
        sprite.dispose
        @sprites[key] = nil
      end
    end
    # Go through all @region.points and create any missing sprites
    @region.points.each do |point|
      key = "point_#{point[:position][0]}_#{point[:position][1]}".to_sym
      next if @sprites[key] && !@sprites[key].disposed?
      spr = Sprite.new(@map_viewport)
      spr.bitmap = @bitmaps[:point]
      spr.ox = spr.bitmap.width / 2
      spr.oy = spr.bitmap.height / 2
      spr.x = margins[0] + (point[:position][0] * point_size[0]) + (point_size[0] / 2)
      spr.y = margins[1] + (point[:position][1] * point_size[1]) + (point_size[1] / 2)
      spr.z = 2
      @sprites[key] = spr
    end
  end

  #-----------------------------------------------------------------------------

  def apply_button_press(button)
    super
    return if @quit
    case button
    when :save
      save_data(@data, "Data/#{GameData::TownMap::DATA_FILENAME}")
      GameData::TownMap.load
      Compiler.write_town_map
    when :regions_list
      new_val = @components.get_control(button).value
      if new_val != @region_id
        set_region(new_val)
      end
    when :add_region
      new_region_id = @data.keys.max + 1
      new_region = GameData::TownMap.new({
        :id => new_region_id
      })
      @data[new_region_id] = new_region
      set_region(new_region_id)
    when :delete_region
      if @data.length > 1
        if confirm_message(_INTL("Are you sure you want to delete this region?"))
          region_index = @data.keys.index(@region_id)
          @data.delete(@region_id)
          set_region(@data.keys[region_index] || @data.keys.last)
        end
      else
        message(_INTL("You can't delete your only region!"))
      end
    when :map_control
      map_pos = @components.get_control(:map_control).mouse_pos
      if map_pos && map_pos[0]
        new_coordinate_x = (map_pos[0] + @map_viewport.ox - @region.margins[0]) / @region.point_size[0]
        new_coordinate_y = (map_pos[1] + @map_viewport.oy - @region.margins[1]) / @region.point_size[1]
        if new_coordinate_x >= 0 && new_coordinate_x < @region.size[0] &&
           new_coordinate_y >= 0 && new_coordinate_y < @region.size[1]
          set_coordinate(new_coordinate_x, new_coordinate_y)
        else
          set_coordinate(nil, nil)
        end
      end
    else
      apply_changed_display_property(button)
      apply_changed_region_property(button)
      apply_changed_point_property(button)
    end
  end

  def apply_changed_display_property(property)
    case property
    when :game_switches
      refresh_map_extra_graphics
    when :all_switches
      @components.get_control(:game_switches).select_all
      refresh_map_extra_graphics
    when :no_switches
      @components.get_control(:game_switches).deselect_all
      refresh_map_extra_graphics
    end
  end

  def apply_changed_region_property(property)
    case property
    when :region_id
      new_val = @components.get_control(property).value
      if new_val != @region_id
        if @data.keys.none?(new_val)
          @data[new_val] = @data[@region_id]
          @data.delete(@region_id)
          set_region(new_val)
        else
          pbPlayBuzzerSE
          @components.get_control(property).value = @region_id
        end
      end
    when :region_name
      new_val = @components.get_control(property).value
      if new_val != @region.real_name
        @region.instance_eval { @real_name = new_val }
        refresh_regions_list
      end
    when :filename_button
      new_val = choose_graphic_file(MAP_FOLDER, @region.filename, GRAPHICS_BLACKLIST) || ""
      if new_val != @region.filename
        @region.instance_eval { @filename = new_val }
        refresh_map_filename
      end
    when :margins_x, :margins_y
      new_val_x = @components.get_control(:margins_x).value
      new_val_y = @components.get_control(:margins_y).value
      if new_val_x != @region.margins[0] || new_val_y != @region.margins[1]
        @region.instance_eval { @margins = [new_val_x, new_val_y] }
        clamp_size_property
        refresh_map_extra_graphics
        refresh_map_grid
        refresh_map_points
      end
    when :point_size_x, :point_size_y
      new_val_x = @components.get_control(:point_size_x).value
      new_val_y = @components.get_control(:point_size_y).value
      if new_val_x != @region.point_size[0] || new_val_y != @region.point_size[1]
        @region.instance_eval { @point_size = [new_val_x, new_val_y] }
        clamp_size_property
        refresh_map_extra_graphics
        refresh_map_grid
        refresh_map_points
      end
    when :size_x, :size_y
      new_val_x = @components.get_control(:size_x).value
      new_val_y = @components.get_control(:size_y).value
      if new_val_x != @region.size[0] || new_val_y != @region.size[1]
        @region.instance_eval { @size = [new_val_x, new_val_y] }
        clamp_size_property
        refresh_map_grid
        refresh_map_points
      end
    end
  end

  def clamp_size_property
    margins = @region.margins
    point_size = @region.point_size
    max_width = (@sprites[:map].width - margins[0] * 2) / point_size[0]
    max_height = (@sprites[:map].height - margins[1] * 2) / point_size[1]
    return if @region.size[0] <= max_width && @region.size[1] <= max_height
    return if max_width < 2 || max_height < 2   # Avoids an error with clamp
    @region.instance_eval { @size = [@size[0].clamp(2, max_width), @size[1].clamp(2, max_height)] }
    @components.get_control(:size_x).value = @region.size[0]
    @components.get_control(:size_y).value = @region.size[1]
  end

  def apply_changed_point_property(property)
    return if @coordinate.nil?
    case property
    when :position_x, :position_y
      new_x = @components.get_control(:position_x).value
      new_y = @components.get_control(:position_y).value
      if @region.points.any? { |point| point[:position] == [new_x, new_y] }
        if @selected_point
          pbPlayBuzzerSE
          @components.get_control(:position_x).value = @coordinate[0]
          @components.get_control(:position_y).value = @coordinate[1]
        else
          set_coordinate(new_x, new_y)
        end
      else
        if @selected_point
          @selected_point[:position] = [new_x, new_y]
          refresh_map_points
        end
        set_coordinate(new_x, new_y, true)
      end
    when :point_name
      ensure_point_data
      @selected_point[:real_name] = @components.get_control(property).value
    when :point_description
      ensure_point_data
      @selected_point[:real_description] = @components.get_control(property).value
    when :point_filename_button
      new_val = choose_graphic_file(MAP_FOLDER, @selected_point[:image], GRAPHICS_BLACKLIST) || ""
      if new_val != @selected_point[:image]
        @selected_point[:image] = new_val
        @components.get_control(:point_filename).text = new_val
      end
    when :point_switch
      ensure_point_data
      @selected_point[:switch] = @components.get_control(property).value
    when :point_fly_destination_button
      ensure_point_data
      fly_spot = @selected_point[:fly_spot] || [0, 0, 0]
      new_fly_spot = choose_map_location(*fly_spot, true)
      if new_fly_spot != fly_spot
        @selected_point[:fly_spot] = (new_fly_spot == [0, 0, 0]) ? nil : new_fly_spot
        set_point_fly_spot_text
      end
    when :point_hide_fly_icon
      ensure_point_data
      @selected_point[:hide_fly_icon] = @components.get_control(property).value
    when :point_fly_icon_offset_x, :point_fly_icon_offset_y
      ensure_point_data
      @selected_point[:fly_icon_offset] = [@components.get_control(:point_fly_icon_offset_x).value,
                                           @components.get_control(:point_fly_icon_offset_y).value]
    when :delete_point
      @region.points.delete_if { |point| point[:position] == @coordinate }
      refresh_map_points
      set_coordinate(*@coordinate, true)
    end
    ensure_no_point_data
  end

  def update_input
    # Scroll map with mouse wheel
    return if !@components.get_control(:map_control).mouse_in_control?
    wheel_v = Input.scroll_v
    return if wheel_v == 0
    if wheel_v > 0   # Scroll up
      if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT) || !@components.get_control(:v_scrollbar).can_scroll?
        @components.get_control(:h_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
      else
        @components.get_control(:v_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
      end
    elsif wheel_v < 0   # Scroll down
      if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT) || !@components.get_control(:v_scrollbar).can_scroll?
        @components.get_control(:h_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
      else
        @components.get_control(:v_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
      end
    end
  end

  def update
    super
    @map_viewport.oy = @components.get_control(:v_scrollbar).position
    @map_viewport.ox = @components.get_control(:h_scrollbar).position
  end

end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:debug_menu, :set_town_map, {
  "name"        => _INTL("Edit town_map.txt"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Edit the contents of the Town Maps."),
  "effect"      => proc {
    pbBGMStop
    Graphics.resize_screen(Debug::EditorBase::WINDOW_WIDTH, Debug::EditorBase::WINDOW_HEIGHT)
    pbSetResizeFactor(1)
    Debug::PBSEditor::TownMap.new.run
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    pbSetResizeFactor($PokemonSystem.screensize)
    $game_map&.autoplay
  }
})
