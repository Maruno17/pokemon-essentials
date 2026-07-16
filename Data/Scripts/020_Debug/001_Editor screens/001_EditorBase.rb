module Debug
  DEBUG_SETTINGS_FILE_PATH = if File.directory?(System.data_directory)
                              System.data_directory + "debug_settings.rxdata"
                            else
                              "./debug_settings.rxdata"
                            end
  MAP_ZOOM_FACTORS = [1, 2, 4]

  def self.load_settings
    ret = {}
    if File.file?(DEBUG_SETTINGS_FILE_PATH)
      ret = SaveData.get_data_from_file(DEBUG_SETTINGS_FILE_PATH)
    end
    ret[:color_scheme]    ||= :light
    ret[:map_zoom_factor] ||= 1
    return ret
  end

  def self.save_settings(settings)
    File.open(DEBUG_SETTINGS_FILE_PATH, "wb") { |file| Marshal.dump(settings, file) }
  end
end

#===============================================================================
# TODO: Undo/redo.
#===============================================================================
class Debug::EditorBase
  CONTAINER_BORDER    = 3
  WINDOW_WIDTH        = 1024
  WINDOW_HEIGHT       = 768
  LIST_BORDER_PADDING = UIControls::List::LIST_FRAME_THICKNESS * 2
  # NOTE: The innermost ring of pixels drawn around an area are the same color
  #       as it, making it look 1 pixel wider in each direction than it actually
  #       is. EDGE_BUFFER compensates for this.
  EDGE_BUFFER         = 1
  ELEMENT_SPACING     = 2
  HEADER_HEIGHT       = 32
  HEADER_OFFSET_X     = 0   # Position of headers relative to what they're labelling
  HEADER_OFFSET_Y     = 3
  ROW_HEIGHT          = 24

  BIG_BUTTON_WIDTH     = 150
  BIG_BUTTON_HEIGHT    = 32
  INLINE_BUTTON_WIDTH  = 50   # For small buttons next to text
  INLINE_BUTTON_HEIGHT = 20

  SCROLLBAR_THICKNESS = UIControls::Scrollbar::SLIDER_WIDTH

  MENU_BAR_BUTTON_X           = CONTAINER_BORDER + ELEMENT_SPACING - EDGE_BUFFER
  MENU_BAR_BUTTON_Y           = CONTAINER_BORDER + ELEMENT_SPACING - EDGE_BUFFER
  MENU_BAR_BUTTON_WIDTH       = 74   # Same as AnimationEditor::MenuBar::BUTTON_WIDTH
  MENU_BAR_BUTTON_HEIGHT      = 26   # Same as AnimationEditor::MenuBar::BUTTON_HEIGHT
  MENU_BAR_X                  = CONTAINER_BORDER
  MENU_BAR_Y                  = CONTAINER_BORDER
  MENU_BAR_WIDTH              = WINDOW_WIDTH - (CONTAINER_BORDER * 2)
  MENU_BAR_HEIGHT             = MENU_BAR_BUTTON_HEIGHT + (ELEMENT_SPACING - EDGE_BUFFER) * 2   # 28
  COLOR_SCHEME_CONTROL_WIDTH  = 100
  COLOR_SCHEME_CONTROL_HEIGHT = 24
  COLOR_SCHEME_CONTROL_X      = MENU_BAR_X + MENU_BAR_WIDTH - COLOR_SCHEME_CONTROL_WIDTH - (ELEMENT_SPACING - EDGE_BUFFER) - 3
  COLOR_SCHEME_CONTROL_Y      = MENU_BAR_Y + ((MENU_BAR_HEIGHT - COLOR_SCHEME_CONTROL_HEIGHT) / 2)
  COLOR_SCHEME_LABEL_X        = COLOR_SCHEME_CONTROL_X - 105

  # Pop-up window
  MESSAGE_BOX_WIDTH   = WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT  = 160
  MESSAGE_BOX_SPACING = 16

  GRAPHIC_CHOOSER_PREVIEW_SIZE     = [480, 320]
  GRAPHIC_CHOOSER_PREVIEW_BORDER   = 2
  GRAPHIC_CHOOSER_FILE_LIST_X      = EDGE_BUFFER
  GRAPHIC_CHOOSER_FILE_LIST_Y      = HEADER_HEIGHT
  GRAPHIC_CHOOSER_FILE_LIST_WIDTH  = (BIG_BUTTON_WIDTH * 2) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  GRAPHIC_CHOOSER_FILE_LIST_HEIGHT = (ROW_HEIGHT * 15) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  GRAPHIC_CHOOSER_WINDOW_WIDTH     = GRAPHIC_CHOOSER_FILE_LIST_X + GRAPHIC_CHOOSER_FILE_LIST_WIDTH + (ELEMENT_SPACING + GRAPHIC_CHOOSER_PREVIEW_BORDER * 2) + GRAPHIC_CHOOSER_PREVIEW_SIZE[0] + EDGE_BUFFER
  GRAPHIC_CHOOSER_WINDOW_HEIGHT    = GRAPHIC_CHOOSER_FILE_LIST_Y + GRAPHIC_CHOOSER_FILE_LIST_HEIGHT + ELEMENT_SPACING + 20 + EDGE_BUFFER

  LOCATION_CHOOSER_VIEWPORT_SIZE   = [512, 384]
  LOCATION_CHOOSER_PREVIEW_BORDER  = 2
  LOCATION_CHOOSER_MAP_LIST_X      = EDGE_BUFFER
  LOCATION_CHOOSER_MAP_LIST_Y      = HEADER_HEIGHT
  LOCATION_CHOOSER_MAP_LIST_WIDTH  = (BIG_BUTTON_WIDTH * 2) + (UIControls::List::LIST_FRAME_THICKNESS * 2) + 3
  LOCATION_CHOOSER_MAP_LIST_HEIGHT = (ROW_HEIGHT * 20) + (UIControls::List::LIST_FRAME_THICKNESS * 2)
  LOCATION_CHOOSER_WINDOW_WIDTH    = LOCATION_CHOOSER_MAP_LIST_X + LOCATION_CHOOSER_MAP_LIST_WIDTH + (ELEMENT_SPACING + LOCATION_CHOOSER_PREVIEW_BORDER * 2) + LOCATION_CHOOSER_VIEWPORT_SIZE[0] + SCROLLBAR_THICKNESS + EDGE_BUFFER + 3
  LOCATION_CHOOSER_WINDOW_HEIGHT   = LOCATION_CHOOSER_MAP_LIST_Y + LOCATION_CHOOSER_MAP_LIST_HEIGHT + ELEMENT_SPACING + 20 + EDGE_BUFFER

  GRAPHICS_FILE_TYPES = [".png", ".jpg", ".jpeg"]

  include UIControls::StyleMixin

  def initialize
    @viewports = []
    @bitmaps = {}
    @sprites = {}
    @settings = Debug.load_settings
    @quit = false
    initialize_parameters
    initialize_viewports
    initialize_bitmaps
    initialize_background
    initialize_overlay
    initialize_sprites
    initialize_controls
    initialize_values
    self.color_scheme = @settings[:color_scheme]
    refresh
  end

  def initialize_parameters
  end

  def initialize_viewports
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @pop_up_viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @pop_up_viewport.z = @viewport.z + 50
  end

  def initialize_bitmaps
  end

  def initialize_background
    # Background
    @sprites[:background] = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    @sprites[:background].z = -1000
    # Semi-transparent black overlay to dim the screen while a pop-up window is open
    @sprites[:pop_up_background] = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @pop_up_viewport)
    @sprites[:pop_up_background].z = -100
    @sprites[:pop_up_background].visible = false
    # Draw in these sprites
    draw_background
  end

  def initialize_overlay
  end

  def initialize_sprites
  end

  def initialize_controls
    @components = UIControls::ListedContainer.new(
      0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, @viewport
    )
    initialize_menu_bar_controls
  end

  def initialize_menu_bar_controls
    menu_bar_buttons.each_with_index do |button, i|
      btn = UIControls::Button.new(MENU_BAR_BUTTON_WIDTH, MENU_BAR_BUTTON_HEIGHT, @viewport, button[1])
      @components.add_control_at(
        button[0],
        MENU_BAR_BUTTON_X + (i * (MENU_BAR_BUTTON_WIDTH + ELEMENT_SPACING)),
        MENU_BAR_BUTTON_Y,
        btn
      )
    end
    # Color scheme
    label = UIControls::Label.new(COLOR_SCHEME_CONTROL_WIDTH, COLOR_SCHEME_CONTROL_HEIGHT,
                                  @viewport, _INTL("Color scheme"))
    @components.add_control_at(:color_scheme_label, COLOR_SCHEME_LABEL_X, COLOR_SCHEME_CONTROL_Y, label)
    menu = UIControls::DropdownList.new(COLOR_SCHEME_CONTROL_WIDTH, COLOR_SCHEME_CONTROL_HEIGHT,
                                        @viewport, color_scheme_options, @settings[:color_scheme])
    @components.add_control_at(:color_scheme, COLOR_SCHEME_CONTROL_X, COLOR_SCHEME_CONTROL_Y, menu)
    # Editor label
    label = UIControls::Label.new(WINDOW_WIDTH, COLOR_SCHEME_CONTROL_HEIGHT, @viewport, editor_name)
    label.header = true
    @components.add_control_at(:editor_label, 0, COLOR_SCHEME_CONTROL_Y, label)
  end

  def initialize_values
  end

  def dispose
    @components.dispose
    @graphic_chooser_components&.dispose
    @location_chooser_components&.dispose
    @sprites.each_value { |s| s.dispose if s && !s.disposed? }
    @sprites.clear
    @bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
    @bitmaps.clear
    @viewport.dispose
    @pop_up_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def menu_bar_buttons
    return [
      [:quit, _INTL("Quit")],
      [:save, _INTL("Save")]
    ]
  end

  def editor_name
    return _INTL("Editor")
  end

  #-----------------------------------------------------------------------------

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    initialize_bitmaps
    draw_background
    @components.color_scheme = value
    refresh
  end

  #-----------------------------------------------------------------------------

  def draw_background
    bg_color = get_color_of(:background)
    contrast_color = get_color_of(:line)
    middle_color = get_color_of(:gray_background)
    # Fill the whole screen with white
    @sprites[:background].bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, bg_color)
    # Outline around elements
    [
      [MENU_BAR_X, MENU_BAR_Y, MENU_BAR_WIDTH, MENU_BAR_HEIGHT]
    ].each do |rect|
      @sprites[:background].bitmap.border_rect(*rect, CONTAINER_BORDER, bg_color, contrast_color, middle_color)
    end
    # Make the pop-up background semi-transparent
    @sprites[:pop_up_background].bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, get_color_of(:semi_transparent))
  end

  #-----------------------------------------------------------------------------

  def create_pop_up_window(width, height)
    ret = BitmapSprite.new(width + (CONTAINER_BORDER * 2),
                           height + (CONTAINER_BORDER * 2), @pop_up_viewport)
    ret.x = (WINDOW_WIDTH - ret.width) / 2
    ret.y = (WINDOW_HEIGHT - ret.height) / 2
    ret.z = -1
    ret.bitmap.font.color = get_color_of(:text)
    ret.bitmap.font.size = text_size
    # Draw pop-up box border
    ret.bitmap.border_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height,
                           CONTAINER_BORDER, get_color_of(:background), get_color_of(:line))
    # Fill pop-up box with white
    ret.bitmap.fill_rect(CONTAINER_BORDER, CONTAINER_BORDER, width, height, get_color_of(:background))
    return ret
  end

  #-----------------------------------------------------------------------------

  def message_with_options(text, *options)
    @sprites[:pop_up_background].visible = true
    msg_bitmap = create_pop_up_window(MESSAGE_BOX_WIDTH, MESSAGE_BOX_HEIGHT)
    # Draw text
    text_size = msg_bitmap.bitmap.text_size(text)
    msg_bitmap.bitmap.draw_text(0, (msg_bitmap.height / 2) - BIG_BUTTON_HEIGHT,
                                msg_bitmap.width, text_size.height, text, 1)
    # Create buttons
    buttons = []
    options.each_with_index do |option, i|
      btn = UIControls::Button.new(BIG_BUTTON_WIDTH, BIG_BUTTON_HEIGHT,
                                   @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + ((msg_bitmap.width - ((BIG_BUTTON_WIDTH + ELEMENT_SPACING) * options.length)) / 2) + ELEMENT_SPACING
      btn.x += (BIG_BUTTON_WIDTH + ELEMENT_SPACING) * i
      btn.y = msg_bitmap.y + msg_bitmap.height - BIG_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
      btn.color_scheme = @color_scheme
      btn.set_interactive_rects
      buttons.push([option[0], btn])
    end
    # Interaction loop
    ret = nil
    captured = nil
    loop do
      Graphics.update
      Input.update
      if captured
        captured.update
        captured = nil if !captured.busy?
      else
        buttons.each do |btn|
          btn[1].update
          captured = btn[1] if btn[1].busy?
        end
      end
      buttons.each do |btn|
        next if !btn[1].changed?
        ret = btn[0]
        break
      end
      ret = :cancel if Input.triggerex?(:ESCAPE)
      break if ret
      buttons.each { |btn| btn[1].repaint }
    end
    # Dispose and return
    buttons.each { |btn| btn[1].dispose }
    buttons.clear
    msg_bitmap.dispose
    @sprites[:pop_up_background].visible = false
    return ret
  end

  def message(text)
    message_with_options(text, [:ok, _INTL("OK")])
  end

  def confirm_message(text)
    return message_with_options(text, [:yes, _INTL("Yes")], [:no, _INTL("No")]) == :yes
  end

  def confirm_cancel_message(text)
    return message_with_options(text, [:yes, _INTL("Yes")], [:no, _INTL("No")], [:cancel, _INTL("Cancel")])
  end

  #-----------------------------------------------------------------------------

  # Generates a list of all files in the given folder and its subfolders which
  # have a file extension that matches one in exts. Removes any files from the
  # list whose filename is the same as one in blacklist (case insensitive) or
  # whose filename matches any Regexp in blacklist.
  def get_all_files_in_folder(folder, exts, blacklist = [])
    ret = []
    Dir.all(folder).each do |f|
      next if !exts.include?(File.extname(f))
      file = f.sub(folder + "/", "")
      file_no_ext = file.sub(File.extname(file), "")
      next if blacklist.any? do |black|
        (black.is_a?(Regexp)) ? file_no_ext[black] : black.upcase == file_no_ext.upcase
      end
      ret.push([file_no_ext, file])
    end
    ret.sort! do |a, b|   # Sorts files in subfolders above ones in main folder
      if a[0][/\//]
        if b[0][/\//]
          next a[0].downcase <=> b[0].downcase
        else
          next -1
        end
      elsif b[0][/\//]
        next 1
      end
      next a[0].downcase <=> b[0].downcase
    end
    return ret
  end

  def create_graphic_chooser_controls
    return @graphic_chooser_components if @graphic_chooser_components
    control_container = UIControls::ListedContainer.new(
      (Graphics.width - GRAPHIC_CHOOSER_WINDOW_WIDTH) / 2,
      (Graphics.height - GRAPHIC_CHOOSER_WINDOW_HEIGHT) / 2,
      GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT, @pop_up_viewport
    )
    @graphic_chooser_components = control_container
    # Header
    label = UIControls::Label.new(GRAPHIC_CHOOSER_WINDOW_WIDTH, HEADER_HEIGHT, control_container.viewport, _INTL("Choose a file"))
    label.header = true
    control_container.add_control_at(:header,
                                     control_container.x + HEADER_OFFSET_X,
                                     control_container.y + HEADER_OFFSET_Y,
                                     label)
    # List of files
    list = UIControls::List.new(GRAPHIC_CHOOSER_FILE_LIST_WIDTH, GRAPHIC_CHOOSER_FILE_LIST_HEIGHT, control_container.viewport, [])
    control_container.add_control_at(:list,
                                    control_container.x + GRAPHIC_CHOOSER_FILE_LIST_X,
                                    control_container.y + GRAPHIC_CHOOSER_FILE_LIST_Y,
                                    list)
    # Filter
    filter_y = control_container.y + GRAPHIC_CHOOSER_FILE_LIST_Y + GRAPHIC_CHOOSER_FILE_LIST_HEIGHT + ELEMENT_SPACING - 2
    filter_label_width = 60
    control_container.add_control_at(:filter_label,
      control_container.x + GRAPHIC_CHOOSER_FILE_LIST_X,
      filter_y,
      UIControls::Label.new(GRAPHIC_CHOOSER_FILE_LIST_WIDTH, ROW_HEIGHT, control_container.viewport, _INTL("Filter:"))
    )
    control_container.add_control_at(:filter,
      control_container.x + GRAPHIC_CHOOSER_FILE_LIST_X + filter_label_width,
      filter_y,
      UIControls::TextBox.new(GRAPHIC_CHOOSER_FILE_LIST_WIDTH - filter_label_width - INLINE_BUTTON_WIDTH - ELEMENT_SPACING,
                              ROW_HEIGHT, control_container.viewport, "")
    )
    control_container.add_control_at(:filter_clear,
      control_container.x + GRAPHIC_CHOOSER_FILE_LIST_X + GRAPHIC_CHOOSER_FILE_LIST_WIDTH - INLINE_BUTTON_WIDTH,
      filter_y + 2,
      UIControls::Button.new(INLINE_BUTTON_WIDTH, INLINE_BUTTON_HEIGHT, control_container.viewport, _INTL("Clear"))
    )
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(BIG_BUTTON_WIDTH, BIG_BUTTON_HEIGHT, control_container.viewport, option[1])
      control_container.add_control_at(option[0],
                                      control_container.x + control_container.width - (BIG_BUTTON_WIDTH * 2) - ELEMENT_SPACING - EDGE_BUFFER + ((BIG_BUTTON_WIDTH + ELEMENT_SPACING) * i),
                                      control_container.y + control_container.height - BIG_BUTTON_HEIGHT - EDGE_BUFFER,
                                      btn)
    end
    return control_container
  end

  def choose_graphic_file(folder, selected, blacklist = [], none_option = false)
    selected ||= ""
    sprite_folder = folder
    # Show pop-up window
    @sprites[:pop_up_background].visible = true   # Semi-transparent black overlay
    bg_sprite = create_pop_up_window(GRAPHIC_CHOOSER_WINDOW_WIDTH, GRAPHIC_CHOOSER_WINDOW_HEIGHT)
    # Create controls
    controls = create_graphic_chooser_controls
    controls.visible = true
    list = controls.get_control(:list)
    # Get a list of files
    list = controls.get_control(:list)
    all_files = get_all_files_in_folder(sprite_folder, GRAPHICS_FILE_TYPES, blacklist)
    all_files.prepend(["", _INTL("[[None]]")]) if none_option
    idx = 0
    all_files.each_with_index do |file, i|
      next if file[0] != selected
      idx = i
      break
    end
    # Set control values
    list.options = all_files
    list.selected = idx
    controls.get_control(:filter).value = ""
    # Create sprite preview
    preview_area_x = CONTAINER_BORDER - controls.x + list.x + list.width + ELEMENT_SPACING + GRAPHIC_CHOOSER_PREVIEW_BORDER
    preview_area_y = CONTAINER_BORDER - controls.y + list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER
    bg_sprite.bitmap.outline_rect(preview_area_x - GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                  preview_area_y - GRAPHIC_CHOOSER_PREVIEW_BORDER,
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE[0] + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  GRAPHIC_CHOOSER_PREVIEW_SIZE[1] + (GRAPHIC_CHOOSER_PREVIEW_BORDER * 2),
                                  get_color_of(:line))
    preview_sprite = Sprite.new(@pop_up_viewport)
    preview_sprite.x = list.x + list.width + ELEMENT_SPACING + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE[0] / 2)
    preview_sprite.y = list.y + GRAPHIC_CHOOSER_PREVIEW_BORDER + (GRAPHIC_CHOOSER_PREVIEW_SIZE[1] / 2)
    preview_sprite.z = controls.z
    preview_bitmap = nil
    # Create lambda function that refreshes the sprite preview
    set_preview_graphic = lambda do |sprite, filename|
      preview_bitmap&.dispose
      sprite.visible = false
      bg_sprite.bitmap.fill_rect(preview_area_x, preview_area_y, *GRAPHIC_CHOOSER_PREVIEW_SIZE, get_color_of(:background))
      next if filename.nil? || filename == ""
      folder = sprite_folder + "/"
      fname = filename
      preview_bitmap = AnimatedBitmap.new(folder + fname)
      next if !preview_bitmap
      sprite.visible = true
      sprite.bitmap = preview_bitmap.bitmap
      zoom = [[GRAPHIC_CHOOSER_PREVIEW_SIZE[0].to_f / preview_bitmap.width,
              GRAPHIC_CHOOSER_PREVIEW_SIZE[1].to_f / preview_bitmap.height].min, 1.0].min
      sprite.zoom_x = sprite.zoom_y = zoom
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      bg_sprite.bitmap.fill_rect(CONTAINER_BORDER + sprite.x - controls.x - (sprite.width * sprite.zoom_x / 2).round,
                                 CONTAINER_BORDER + sprite.y - controls.y - (sprite.height * sprite.zoom_y / 2).round,
                                 sprite.width * sprite.zoom_x, sprite.height * sprite.zoom_y,
                                 Color.magenta)
    end
    set_preview_graphic.call(preview_sprite, list.value)
    # Interaction loop
    filter_text = ""
    ret = nil
    loop do
      Graphics.update
      Input.update
      controls.update
      # Check if filter text has changed
      if controls.get_control(:filter).value != filter_text
        filter_text = controls.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_files
        else
          files = all_files.filter { |val| val[0].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
        set_preview_graphic.call(preview_sprite, list.value)
      end
      # Check if other controls have changed
      if controls.changed?
        controls.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = list.value
          when :cancel
            ret = selected
          when :list
            set_preview_graphic.call(preview_sprite, list.value)
          when :filter_clear
            old_val = list.value
            filter_text = ""
            controls.get_control(:filter).value = ""
            list.options = all_files
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
            set_preview_graphic.call(preview_sprite, list.value)
          end
          controls.clear_changed
        end
        break if ret
        controls.repaint
      end
      # Disable OK button if nothing in the list is selected
      controls.get_control(:ok).enabled = !list.value.nil?
      # Cancel with Esc key
      if !controls.busy? && Input.triggerex?(:ESCAPE)
        ret = selected
        break
      end
    end
    # Dispose and return
    bg_sprite.dispose
    preview_sprite.dispose
    preview_bitmap&.dispose
    controls.visible = false
    @sprites[:pop_up_background].visible = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def get_all_maps
    map_infos = pbLoadMapInfos
    map_levels = []
    map_infos.each_key do |i|
      info = map_infos[i]
      level = -1
      while info
        info = map_infos[info.parent_id]
        level += 1
      end
      next if level < 0
      info = map_infos[i]
      map_levels.push([i, level, info.parent_id, info.order])
    end
    map_levels.sort! do |a, b|
      next a[1] <=> b[1] if a[1] != b[1]   # level
      next a[2] <=> b[2] if a[2] != b[2]   # parent ID
      next a[3] <=> b[3]                   # order
    end
    ret = []
    stack = []
    stack.push(0, 0)
    while stack.length > 0
      parent = stack[stack.length - 1]
      index = stack[stack.length - 2]
      if index >= map_levels.length
        stack.pop
        stack.pop
        next
      end
      map_level = map_levels[index]
      stack[stack.length - 2] += 1
      if map_level[2] != parent
        stack.pop
        stack.pop
        next
      end
      padding = ""
      padding += "      " * (map_level[1] - 1) if map_level[1] > 1
      padding += "└─ " if map_level[1] > 0
      ret.push([map_level[0], sprintf("%s%03d: %s", padding, map_level[0], map_infos[map_level[0]].name)])
      (index + 1...map_levels.length).each do |i|
        next if map_levels[i][2] != map_level[0]
        stack.push(i)
        stack.push(map_level[0])
        break
      end
    end
    return ret
  end

  def create_location_chooser_controls
    return @location_chooser_components if @location_chooser_components
    control_container = UIControls::ListedContainer.new(
      (Graphics.width - LOCATION_CHOOSER_WINDOW_WIDTH) / 2,
      (Graphics.height - LOCATION_CHOOSER_WINDOW_HEIGHT) / 2,
      LOCATION_CHOOSER_WINDOW_WIDTH, LOCATION_CHOOSER_WINDOW_HEIGHT, @pop_up_viewport
    )
    @location_chooser_components = control_container
    # Header
    label = UIControls::Label.new(LOCATION_CHOOSER_WINDOW_WIDTH, HEADER_HEIGHT, control_container.viewport, _INTL("Choose a location"))
    label.header = true
    control_container.add_control_at(:header,
                                     control_container.x + HEADER_OFFSET_X,
                                     control_container.y + HEADER_OFFSET_Y,
                                     label)
    # List of maps
    list = UIControls::List.new(LOCATION_CHOOSER_MAP_LIST_WIDTH, LOCATION_CHOOSER_MAP_LIST_HEIGHT, control_container.viewport, [])
    control_container.add_control_at(:list,
                                    control_container.x + LOCATION_CHOOSER_MAP_LIST_X,
                                    control_container.y + LOCATION_CHOOSER_MAP_LIST_Y,
                                    list)
    # Filter
    filter_y = control_container.y + LOCATION_CHOOSER_MAP_LIST_Y + LOCATION_CHOOSER_MAP_LIST_HEIGHT + ELEMENT_SPACING - 2
    filter_label_width = 60
    control_container.add_control_at(:filter_label,
      control_container.x + LOCATION_CHOOSER_MAP_LIST_X,
      filter_y,
      UIControls::Label.new(LOCATION_CHOOSER_MAP_LIST_WIDTH, ROW_HEIGHT, control_container.viewport, _INTL("Filter:"))
    )
    control_container.add_control_at(:filter,
      control_container.x + LOCATION_CHOOSER_MAP_LIST_X + filter_label_width,
      filter_y,
      UIControls::TextBox.new(LOCATION_CHOOSER_MAP_LIST_WIDTH - filter_label_width - INLINE_BUTTON_WIDTH - ELEMENT_SPACING,
                              ROW_HEIGHT, control_container.viewport, "")
    )
    control_container.add_control_at(:filter_clear,
      control_container.x + LOCATION_CHOOSER_MAP_LIST_X + LOCATION_CHOOSER_MAP_LIST_WIDTH - INLINE_BUTTON_WIDTH,
      filter_y + 2,
      UIControls::Button.new(INLINE_BUTTON_WIDTH, INLINE_BUTTON_HEIGHT, control_container.viewport, _INTL("Clear"))
    )
    # Zoom buttons
    Debug::MAP_ZOOM_FACTORS.each_with_index do |factor, i|
      btn = UIControls::Button.new(INLINE_BUTTON_WIDTH, BIG_BUTTON_HEIGHT, control_container.viewport, "1/#{factor}")
      control_container.add_control_at("zoom_factor_#{factor}".to_sym,
                                      list.x + list.width + ELEMENT_SPACING + ((INLINE_BUTTON_WIDTH + ELEMENT_SPACING) * i),
                                      list.y,
                                      btn)
      if factor == @settings[:map_zoom_factor]
        control_container.get_control("zoom_factor_#{factor}".to_sym).set_highlighted
      else
        control_container.get_control("zoom_factor_#{factor}".to_sym).set_not_highlighted
      end
    end
    # Clickable map area
    preview_area_x = list.x + list.width + ELEMENT_SPACING + LOCATION_CHOOSER_PREVIEW_BORDER
    preview_area_y = list.y + BIG_BUTTON_HEIGHT + ELEMENT_SPACING + LOCATION_CHOOSER_PREVIEW_BORDER
    control_container.add_control_at(:map_area, preview_area_x, preview_area_y,
                                     UIControls::ClickableArea.new(*LOCATION_CHOOSER_VIEWPORT_SIZE, control_container.viewport, false))
    control_container.get_control(:map_area).changed_upon_click = true
    # Scrollbars
    control_container.add_control_at(:v_scrollbar, preview_area_x + LOCATION_CHOOSER_VIEWPORT_SIZE[0] + 3, preview_area_y,
                                     UIControls::Scrollbar.new(LOCATION_CHOOSER_VIEWPORT_SIZE[1], control_container.viewport, :vertical))
    control_container.add_control_at(:h_scrollbar, preview_area_x, preview_area_y + LOCATION_CHOOSER_VIEWPORT_SIZE[1] + 3,
                                     UIControls::Scrollbar.new(LOCATION_CHOOSER_VIEWPORT_SIZE[0], control_container.viewport, :horizontal))
    # Buttons
    [[:ok, _INTL("OK")], [:cancel, _INTL("Cancel")]].each_with_index do |option, i|
      btn = UIControls::Button.new(BIG_BUTTON_WIDTH, BIG_BUTTON_HEIGHT, control_container.viewport, option[1])
      control_container.add_control_at(option[0],
                                      control_container.x + control_container.width - (BIG_BUTTON_WIDTH * 2) - ELEMENT_SPACING - EDGE_BUFFER + ((BIG_BUTTON_WIDTH + ELEMENT_SPACING) * i),
                                      control_container.y + control_container.height - BIG_BUTTON_HEIGHT - EDGE_BUFFER,
                                      btn)
    end
    return control_container
  end

  def choose_map_location(selected_map, selected_x, selected_y, none_option = false)
    coordinates = [selected_x, selected_y]
    # Show pop-up window
    @sprites[:pop_up_background].visible = true   # Semi-transparent black overlay
    bg_sprite = create_pop_up_window(LOCATION_CHOOSER_WINDOW_WIDTH, LOCATION_CHOOSER_WINDOW_HEIGHT)
    # Create controls
    controls = create_location_chooser_controls
    controls.visible = true
    list = controls.get_control(:list)
    # Get a list of files
    list = controls.get_control(:list)
    all_maps = get_all_maps
    all_maps.prepend([0, _INTL("[[None]]")]) if none_option
    idx = 0
    all_maps.each_with_index do |file, i|
      next if file[0] != selected_map
      idx = i
      break
    end
    # Set control values
    list.options = all_maps
    list.selected = idx
    list.show_selection
    controls.get_control(:filter).value = ""
    # Draw around map and scrollbars
    preview_area_x = CONTAINER_BORDER - controls.x + list.x + list.width + ELEMENT_SPACING + LOCATION_CHOOSER_PREVIEW_BORDER
    preview_area_y = CONTAINER_BORDER - controls.y + list.y + BIG_BUTTON_HEIGHT + ELEMENT_SPACING + LOCATION_CHOOSER_PREVIEW_BORDER
    map_outline_x = preview_area_x - LOCATION_CHOOSER_PREVIEW_BORDER
    map_outline_y = preview_area_y - LOCATION_CHOOSER_PREVIEW_BORDER
    map_outline_width = LOCATION_CHOOSER_VIEWPORT_SIZE[0] + (LOCATION_CHOOSER_PREVIEW_BORDER * 2)
    map_outline_height = LOCATION_CHOOSER_VIEWPORT_SIZE[1] + (LOCATION_CHOOSER_PREVIEW_BORDER * 2)
    [
      [map_outline_x, map_outline_y, map_outline_width, map_outline_height],
      [map_outline_x + map_outline_width - 1, map_outline_y, SCROLLBAR_THICKNESS + 4, map_outline_height],
      [map_outline_x, map_outline_y + map_outline_height - 1, map_outline_width, SCROLLBAR_THICKNESS + 4],
      [map_outline_x + map_outline_width - 1, map_outline_y + map_outline_height - 1, SCROLLBAR_THICKNESS + 4, SCROLLBAR_THICKNESS + 4]
    ].each do |rect|
      bg_sprite.bitmap.outline_rect(*rect, get_color_of(:line))
    end
    rect = [
      map_outline_x + map_outline_width + 1, map_outline_y + map_outline_height + 1,
      SCROLLBAR_THICKNESS, SCROLLBAR_THICKNESS
    ]
    bg_sprite.bitmap.fill_rect(*rect, get_color_of(:gray_background))
    bg_sprite.bitmap.outline_rect(*rect, get_color_of(:line))
    # Create map elements
    map_location_viewport = Viewport.new(controls.x + preview_area_x - CONTAINER_BORDER,
                                         controls.y + preview_area_y - CONTAINER_BORDER,
                                         *LOCATION_CHOOSER_VIEWPORT_SIZE)
    map_location_viewport.z = @pop_up_viewport.z + 1
    map_sprite = Sprite.new(map_location_viewport)
    cursor_bitmaps = {}
    Debug::MAP_ZOOM_FACTORS.each do |factor|
      this_bitmap = Bitmap.new(Game_Map::TILE_WIDTH / factor, Game_Map::TILE_HEIGHT / factor)
      this_bitmap.border_rect(4, 4, this_bitmap.width - 8, this_bitmap.height - 8,
                              4, Color.black, Color.white, Color.white, Color.black)
      cursor_bitmaps[factor] = this_bitmap
    end
    cursor_sprite = Sprite.new(map_location_viewport)
    cursor_sprite.bitmap = cursor_bitmaps[1]
    # Create lambda function that refreshes the map sprite
    set_map_bitmap = lambda do |map_id|
      bitmap_sym = "map_#{map_id}".to_sym
      @bitmaps[bitmap_sym] ||= createMapBitmap(map_id)
      map_sprite.bitmap = @bitmaps[bitmap_sym]
      map_sprite.zoom_x = 1.0 / @settings[:map_zoom_factor]
      map_sprite.zoom_y = 1.0 / @settings[:map_zoom_factor]
      controls.get_control(:v_scrollbar).range = [map_sprite.height || 1, 1].max / @settings[:map_zoom_factor]
      controls.get_control(:h_scrollbar).range = [map_sprite.width || 1, 1].max / @settings[:map_zoom_factor]
      if map_sprite.width && map_sprite.width > 0
        coordinates[0] = coordinates[0].clamp(0, (map_sprite.bitmap.width - 1) / Game_Map::TILE_WIDTH)
        coordinates[1] = coordinates[1].clamp(0, (map_sprite.bitmap.height - 1) / Game_Map::TILE_HEIGHT)
      end
    end
    set_cursor_position = lambda do |new_x, new_y|
      tile_size_x = Game_Map::TILE_WIDTH / @settings[:map_zoom_factor]
      tile_size_y = Game_Map::TILE_HEIGHT / @settings[:map_zoom_factor]
      cursor_sprite.x = new_x * tile_size_x
      cursor_sprite.y = new_y * tile_size_y
      cursor_sprite.bitmap = cursor_bitmaps[@settings[:map_zoom_factor]]
      cursor_sprite.visible = (list.value > 0)
    end
    # Final setup before loop
    set_map_bitmap.call(list.value)
    set_cursor_position.call(*coordinates)
    if controls.get_control(:h_scrollbar).can_scroll?
      scrollbar = controls.get_control(:h_scrollbar)
      tile_size_x = Game_Map::TILE_WIDTH / @settings[:map_zoom_factor]
      new_left_pixel = (coordinates[0] * tile_size_x) + (tile_size_x / 2) - (LOCATION_CHOOSER_VIEWPORT_SIZE[0] / 2)
      proportion = new_left_pixel.to_f / (scrollbar.range - LOCATION_CHOOSER_VIEWPORT_SIZE[0] - 1)
      scrollbar.slider_top = proportion * (scrollbar.tray_size - scrollbar.slider_size - 1)
    end
    if controls.get_control(:v_scrollbar).can_scroll?
      scrollbar = controls.get_control(:v_scrollbar)
      tile_size_y = Game_Map::TILE_HEIGHT / @settings[:map_zoom_factor]
      new_top_pixel = (coordinates[1] * tile_size_y) + (tile_size_y / 2) - (LOCATION_CHOOSER_VIEWPORT_SIZE[1] / 2)
      proportion = new_top_pixel.to_f / (scrollbar.range - LOCATION_CHOOSER_VIEWPORT_SIZE[1] - 1)
      scrollbar.slider_top = proportion * (scrollbar.tray_size - scrollbar.slider_size - 1)
    end
    # Interaction loop
    filter_text = ""
    ret = nil
    loop do
      Graphics.update
      Input.update
      controls.update
      # Check if filter text has changed
      if controls.get_control(:filter).value != filter_text
        filter_text = controls.get_control(:filter).value
        old_val = list.value
        if filter_text == ""
          list.options = all_maps
        else
          files = all_maps.filter { |val| val[1].downcase.include?(filter_text.downcase) }
          list.options = files
        end
        list.selected = list.options.index { |val| val && val[0] == old_val } || -1
        set_map_bitmap.call(list.value)
      end
      # Check if other controls have changed
      if controls.changed?
        controls.changed_controls.each_pair do |ctrl, value|
          case ctrl
          when :ok
            ret = [list.value, *coordinates]
          when :cancel
            ret = [selected_map, selected_x, selected_y]
          when :list
            set_map_bitmap.call(list.value)
            set_cursor_position.call(*coordinates)
          when :filter_clear
            old_val = list.value
            filter_text = ""
            controls.get_control(:filter).value = ""
            list.options = all_maps
            list.selected = list.options.index { |val| val && val[0] == old_val } || -1
            set_map_bitmap.call(list.value)
            set_cursor_position.call(*coordinates)
          when :map_area
            map_pos = controls.get_control(ctrl).mouse_pos
            if map_pos && map_pos[0]
              tile_size_x = Game_Map::TILE_WIDTH / @settings[:map_zoom_factor]
              tile_size_y = Game_Map::TILE_HEIGHT / @settings[:map_zoom_factor]
              new_coordinate_x = (map_pos[0] + map_location_viewport.ox) / tile_size_x
              new_coordinate_y = (map_pos[1] + map_location_viewport.oy) / tile_size_y
              if new_coordinate_x >= 0 && new_coordinate_x < map_sprite.width / Game_Map::TILE_WIDTH &&
                 new_coordinate_y >= 0 && new_coordinate_y < map_sprite.height / Game_Map::TILE_HEIGHT
                coordinates = [new_coordinate_x, new_coordinate_y]
                set_cursor_position.call(*coordinates)
              end
            end
          else
            if ctrl[/^zoom_factor_(\d+)$/]
              @settings[:map_zoom_factor] = $~[1].to_i
              Debug.save_settings(@settings)
              set_map_bitmap.call(list.value)
              set_cursor_position.call(*coordinates)
              controls.get_control(ctrl).set_highlighted
              Debug::MAP_ZOOM_FACTORS.each do |factor|
                controls.get_control("zoom_factor_#{factor}".to_sym).set_highlight(factor == @settings[:map_zoom_factor])
              end
            end
          end
          controls.clear_changed
        end
        break if ret
        controls.repaint
      end
      # Disable OK button if nothing in the list is selected
      controls.get_control(:ok).enabled = !list.value.nil?
      # Cancel with Esc key
      if !controls.busy? && Input.triggerex?(:ESCAPE)
        ret = [selected_map, selected_x, selected_y]
        break
      end
      # Scroll with mouse wheel
      mouse_coords = Mouse.getMousePos
      if mouse_coords && map_location_viewport.rect.contains?(*mouse_coords)
        wheel_v = Input.scroll_v
        if wheel_v > 0   # Scroll up
          if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT) || !controls.get_control(:v_scrollbar).can_scroll?
            controls.get_control(:h_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
          else
            controls.get_control(:v_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
          end
        elsif wheel_v < 0   # Scroll down
          if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT) || !controls.get_control(:v_scrollbar).can_scroll?
            controls.get_control(:h_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
          else
            controls.get_control(:v_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
          end
        end
      end
      # Update map viewport based on scrollbars
      map_location_viewport.oy = controls.get_control(:v_scrollbar).position
      map_location_viewport.ox = controls.get_control(:h_scrollbar).position
    end
    # Dispose and return
    bg_sprite.dispose
    map_sprite.dispose
    cursor_sprite.dispose
    cursor_bitmaps.each_value { |b| b.dispose if b && !b.disposed? }
    cursor_bitmaps.clear
    map_location_viewport.dispose
    controls.visible = false
    @sprites[:pop_up_background].visible = false
    return ret
  end

  #-----------------------------------------------------------------------------

  def refresh
  end

  #-----------------------------------------------------------------------------

  def apply_button_press(button)
    case button
    when :quit
      case confirm_cancel_message(_INTL("Do you want to save changes?"))
      when :yes
        apply_button_press(:save)
        @quit = true
      when :no
        @quit = true
      end
      return if @quit   # Don't need to refresh the screen
    when :color_scheme
      @settings[:color_scheme] = @components.get_control(button).value
      Debug.save_settings(@settings)
      self.color_scheme = @settings[:color_scheme]
    end
  end

  def update_input
  end

  def update
    @components.update
    if @components.changed?
      @components.changed_controls.each_pair do |property, value|
        apply_button_press(property)
      end
      @components.clear_changed
    else
      update_input
    end
  end

  #-----------------------------------------------------------------------------

  def run
    Input.text_input = false
    loop do
      Graphics.update
      Input.update
      update
      break if !@components.busy? && @quit
    end
    dispose
  end
end
