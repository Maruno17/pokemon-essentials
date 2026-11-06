#===============================================================================
#
#===============================================================================
class AnimationEditor::AnimationSelector
  CONTAINER_BORDER    = AnimationEditor::CONTAINER_BORDER
  WINDOW_WIDTH        = AnimationEditor::WINDOW_WIDTH
  WINDOW_HEIGHT       = AnimationEditor::WINDOW_HEIGHT
  LIST_BORDER_PADDING = (UIControls::List::LIST_FRAME_THICKNESS * 2)
  # NOTE: The innermost ring of pixels drawn around an area are the same color
  #       as it, making it look 1 pixel wider in each direction than it actually
  #       is. EDGE_BUFFER compensates for this.
  EDGE_BUFFER         = 1
  ELEMENT_SPACING     = 2
  HEADER_HEIGHT       = 32
  HEADER_OFFSET_X     = 0   # Position of headers relative to what they're labelling
  HEADER_OFFSET_Y     = -30

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

  ANIMATION_LISTS_X       = CONTAINER_BORDER
  ANIMATION_LISTS_Y       = MENU_BAR_Y + MENU_BAR_HEIGHT + (CONTAINER_BORDER * 2)
  ANIM_TYPE_BUTTON_X      = ANIMATION_LISTS_X + ELEMENT_SPACING - EDGE_BUFFER
  ANIM_TYPE_BUTTON_Y      = ANIMATION_LISTS_Y + HEADER_HEIGHT + ELEMENT_SPACING - EDGE_BUFFER
  ANIM_TYPE_BUTTON_WIDTH  = 100
  ANIM_TYPE_BUTTON_HEIGHT = 26
  MOVES_LIST_X            = ANIM_TYPE_BUTTON_X + ANIM_TYPE_BUTTON_WIDTH + ELEMENT_SPACING
  MOVES_LIST_Y            = ANIM_TYPE_BUTTON_Y
  MOVES_LIST_WIDTH        = 220 + LIST_BORDER_PADDING
  MOVES_LIST_HEIGHT       = WINDOW_HEIGHT - MOVES_LIST_Y - CONTAINER_BORDER - (ELEMENT_SPACING - EDGE_BUFFER)
  MOVES_LIST_HEIGHT       = (((MOVES_LIST_HEIGHT - LIST_BORDER_PADDING) / UIControls::List::ROW_HEIGHT) * UIControls::List::ROW_HEIGHT)
  MOVES_LIST_HEIGHT       += LIST_BORDER_PADDING
  ANIMATIONS_LIST_X       = MOVES_LIST_X + MOVES_LIST_WIDTH + ELEMENT_SPACING
  ANIMATIONS_LIST_Y       = MOVES_LIST_Y
  ANIMATIONS_LIST_WIDTH   = MOVES_LIST_WIDTH
  ANIMATIONS_LIST_HEIGHT  = (12 * UIControls::List::ROW_HEIGHT) + LIST_BORDER_PADDING
  ACTION_BUTTON_X         = ANIMATIONS_LIST_X
  ACTION_BUTTON_Y         = ANIMATIONS_LIST_Y + ANIMATIONS_LIST_HEIGHT + ELEMENT_SPACING
  ACTION_BUTTON_WIDTH     = ANIMATIONS_LIST_WIDTH
  ACTION_BUTTON_HEIGHT    = ANIM_TYPE_BUTTON_HEIGHT
  ANIMATION_LISTS_WIDTH   = ANIMATIONS_LIST_X + ANIMATIONS_LIST_WIDTH + (ELEMENT_SPACING - EDGE_BUFFER) - ANIMATION_LISTS_X
  ANIMATION_LISTS_HEIGHT  = WINDOW_HEIGHT - ANIMATION_LISTS_Y - CONTAINER_BORDER

  FILTERS_X                = ANIMATION_LISTS_X + ANIMATION_LISTS_WIDTH + (CONTAINER_BORDER * 2)
  FILTERS_Y                = ANIMATION_LISTS_Y
  FILTERS_WIDTH            = WINDOW_WIDTH - FILTERS_X - CONTAINER_BORDER
  FILTERS_HEIGHT           = ANIMATION_LISTS_HEIGHT
  FILTER_ROW_WIDTH         = 340
  FILTER_ROW_LABEL_WIDTH   = 200
  FILTER_ROW_CONTROL_WIDTH = FILTER_ROW_WIDTH - FILTER_ROW_LABEL_WIDTH
  FILTER_ROW_HEIGHT        = 24
  FILTER_ROW_LABEL_X       = FILTERS_X + ((FILTERS_WIDTH - FILTER_ROW_WIDTH) / 2)
  FILTER_ROW_CONTROL_X     = FILTER_ROW_LABEL_X + FILTER_ROW_LABEL_WIDTH
  FILTER_ROW_Y             = FILTERS_Y + HEADER_HEIGHT + ELEMENT_SPACING - EDGE_BUFFER
  FILTER_BUTTON_WIDTH      = 120
  FILTER_BUTTON_HEIGHT     = ANIM_TYPE_BUTTON_HEIGHT

  # Pop-up window
  MESSAGE_BOX_WIDTH         = AnimationEditor::WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT        = 160
  MESSAGE_BOX_BUTTON_WIDTH  = 150
  MESSAGE_BOX_BUTTON_HEIGHT = 32
  MESSAGE_BOX_SPACING       = 16

  include AnimationEditor::SettingsMixin
  include UIControls::StyleMixin

  #-----------------------------------------------------------------------------

  def initialize
    load_settings
    @animation_type = 0   # 0=move, 1=common
    @filters = {
      :move_name => "",
      :anim_name => "",
      :credit    => "",
      :usable    => :none,
      :count     => :none,
      :foe       => :none
    }
    @quit = false
    generate_full_lists
    initialize_viewports
    initialize_bitmaps
    initialize_controls
    self.color_scheme = @settings[:color_scheme]
    refresh
  end

  def initialize_viewports
    @viewport = Viewport.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    @viewport.z = 99999
    @pop_up_viewport = Viewport.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    @pop_up_viewport.z = @viewport.z + 50
  end

  def initialize_bitmaps
    # Background
    @screen_bitmap = BitmapSprite.new(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @viewport)
    # Semi-transparent black overlay to dim the screen while a pop-up window is open
    @pop_up_bg_bitmap = BitmapSprite.new(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @pop_up_viewport)
    @pop_up_bg_bitmap.z = -100
    @pop_up_bg_bitmap.visible = false
    # Draw in these bitmaps
    draw_editor_background
  end

  def initialize_controls
    @components = UIControls::ListedContainer.new(
      0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @pop_up_viewport
    )
    initialize_menu_bar_controls
    initialize_lists_controls
    initialize_filter_controls
  end

  def initialize_menu_bar_controls
    [
      [:quit, _INTL("Quit")],
      [:new, _INTL("New")]
    ].each_with_index do |button, i|
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
  end

  def initialize_lists_controls
    # Type header
    label = UIControls::Label.new(ANIM_TYPE_BUTTON_WIDTH, HEADER_HEIGHT,
                                  @viewport, _INTL("Anim types"))
    label.header = true
    @components.add_control_at(:type_label,
                               ANIM_TYPE_BUTTON_X + HEADER_OFFSET_X,
                               ANIM_TYPE_BUTTON_Y + HEADER_OFFSET_Y,
                               label)
    # Animation type toggle buttons
    [
      [:moves, _INTL("Moves")],
      [:commons, _INTL("Common")]
    ].each_with_index do |button, i|
      btn = UIControls::Button.new(ANIM_TYPE_BUTTON_WIDTH, ANIM_TYPE_BUTTON_HEIGHT,
                                   @viewport, button[1])
      @components.add_control_at(
        button[0],
        ANIM_TYPE_BUTTON_X,
        ANIM_TYPE_BUTTON_Y + (i * (ANIM_TYPE_BUTTON_HEIGHT + ELEMENT_SPACING)),
        btn
      )
    end
    # Moves header
    label = UIControls::Label.new(MOVES_LIST_WIDTH, HEADER_HEIGHT,
                                  @viewport, _INTL("Move names"))
    label.header = true
    @components.add_control_at(:moves_label,
                               MOVES_LIST_X + HEADER_OFFSET_X,
                               MOVES_LIST_Y + HEADER_OFFSET_Y,
                               label)
    # Moves list
    list = UIControls::List.new(MOVES_LIST_WIDTH, MOVES_LIST_HEIGHT, @viewport, [])
    @components.add_control_at(:moves_list, MOVES_LIST_X, MOVES_LIST_Y, list)
    # Animations header
    label = UIControls::Label.new(ANIMATIONS_LIST_WIDTH, HEADER_HEIGHT,
                                  @viewport, _INTL("Animations"))
    label.header = true
    @components.add_control_at(:animations_label,
                               ANIMATIONS_LIST_X + HEADER_OFFSET_X,
                               ANIMATIONS_LIST_Y + HEADER_OFFSET_Y,
                               label)
    # Animations list
    list = UIControls::List.new(ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT, @viewport, [])
    @components.add_control_at(:animations_list, ANIMATIONS_LIST_X, ANIMATIONS_LIST_Y, list)
    # Edit, Copy and Delete buttons
    [
      [:edit, _INTL("Edit animation")],
      [:copy, _INTL("Copy animation")],
      [:delete, _INTL("Delete animation")]
    ].each_with_index do |button, i|
      btn = UIControls::Button.new(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT, @viewport, button[1])
      @components.add_control_at(
        button[0],
        ACTION_BUTTON_X,
        ACTION_BUTTON_Y + (i * (ACTION_BUTTON_HEIGHT + ELEMENT_SPACING)),
        btn
      )
    end
  end

  def initialize_filter_controls
    row_y = FILTER_ROW_Y
    # Header
    label = UIControls::Label.new(FILTERS_WIDTH, HEADER_HEIGHT,
                                  @viewport, _INTL("Filters"))
    label.header = true
    @components.add_control_at(:filters_label,
                               FILTERS_X + HEADER_OFFSET_X,
                               FILTER_ROW_Y + HEADER_OFFSET_Y,
                               label)
    # Move name
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Move name contains"))
    @components.add_control_at(:move_name_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    text_box = UIControls::TextBox.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, "")
    @components.add_control_at(:move_name_filter, FILTER_ROW_CONTROL_X, row_y, text_box)
    row_y += FILTER_ROW_HEIGHT
    # Animation name
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Animation name contains"))
    @components.add_control_at(:anim_name_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    text_box = UIControls::TextBoxDropdownList.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, [], "")
    @components.add_control_at(:anim_name_filter, FILTER_ROW_CONTROL_X, row_y, text_box)
    row_y += FILTER_ROW_HEIGHT
    # Credit name
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Credit text contains"))
    @components.add_control_at(:credit_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    text_box = UIControls::TextBoxDropdownList.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, [], "")
    @components.add_control_at(:credit_filter, FILTER_ROW_CONTROL_X, row_y, text_box)
    row_y += FILTER_ROW_HEIGHT
    # Usable in battle
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Usable in battle?"))
    @components.add_control_at(:usable_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    menu = UIControls::DropdownList.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, {
      :none => "---",
      :yes  => _INTL("Yes"),
      :no   => _INTL("No")
    }, :none)
    @components.add_control_at(:usable_filter, FILTER_ROW_CONTROL_X, row_y, menu)
    row_y += FILTER_ROW_HEIGHT
    # Number of animations
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Number of hit versions"))
    @components.add_control_at(:count_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    menu = UIControls::DropdownList.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, {
      :none => "---",
      :one  => _INTL("Exactly 1"),
      :many => _INTL("More than 1")
    }, :none)
    @components.add_control_at(:count_filter, FILTER_ROW_CONTROL_X, row_y, menu)
    row_y += FILTER_ROW_HEIGHT
    # Has foe version
    label = UIControls::Label.new(FILTER_ROW_LABEL_WIDTH, FILTER_ROW_HEIGHT,
                                  @viewport, _INTL("Has foe version?"))
    @components.add_control_at(:foe_filter_label, FILTER_ROW_LABEL_X, row_y, label)
    menu = UIControls::DropdownList.new(FILTER_ROW_CONTROL_WIDTH, FILTER_ROW_HEIGHT, @viewport, {
      :none => "---",
      :yes  => _INTL("Yes"),
      :no   => _INTL("No")
    }, :none)
    @components.add_control_at(:foe_filter, FILTER_ROW_CONTROL_X, row_y, menu)
    row_y += FILTER_ROW_HEIGHT
    # Button to clear all filters
    btn = UIControls::Button.new(FILTER_BUTTON_WIDTH, FILTER_BUTTON_HEIGHT,
                                 @viewport, _INTL("Clear all filters"))
    @components.add_control_at(:clear_filters,
                               FILTERS_X + ((FILTERS_WIDTH - FILTER_BUTTON_WIDTH) / 2),
                               row_y + 2,
                               btn)
    set_filter_options
  end

  def dispose
    @screen_bitmap.dispose
    @pop_up_bg_bitmap.dispose
    @components.dispose
    @viewport.dispose
    @pop_up_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    draw_editor_background
    @components.color_scheme = value
    refresh
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    bg_color = get_color_of(:background)
    contrast_color = get_color_of(:line)
    middle_color = get_color_of(:gray_background)
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, bg_color)
    # Outline around elements
    [
      [MENU_BAR_X, MENU_BAR_Y, MENU_BAR_WIDTH, MENU_BAR_HEIGHT],
      [ANIMATION_LISTS_X, ANIMATION_LISTS_Y, ANIMATION_LISTS_WIDTH, ANIMATION_LISTS_HEIGHT],
      [FILTERS_X, FILTERS_Y, FILTERS_WIDTH, FILTERS_HEIGHT]
    ].each do |rect|
      @screen_bitmap.bitmap.border_rect(*rect, CONTAINER_BORDER, bg_color, contrast_color, middle_color)
    end
    # Make the pop-up background semi-transparent
    @pop_up_bg_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, get_color_of(:semi_transparent))
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

  def message(text, *options)
    @pop_up_bg_bitmap.visible = true
    msg_bitmap = create_pop_up_window(MESSAGE_BOX_WIDTH, MESSAGE_BOX_HEIGHT)
    # Draw text
    text_size = msg_bitmap.bitmap.text_size(text)
    msg_bitmap.bitmap.draw_text(0, (msg_bitmap.height / 2) - MESSAGE_BOX_BUTTON_HEIGHT,
                                msg_bitmap.width, text_size.height, text, 1)
    # Create buttons
    buttons = []
    options.each_with_index do |option, i|
      btn = UIControls::Button.new(MESSAGE_BOX_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT,
                                   @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + ((msg_bitmap.width - ((MESSAGE_BOX_BUTTON_WIDTH + ELEMENT_SPACING) * options.length)) / 2) + ELEMENT_SPACING
      btn.x += (MESSAGE_BOX_BUTTON_WIDTH + ELEMENT_SPACING) * i
      btn.y = msg_bitmap.y + msg_bitmap.height - MESSAGE_BOX_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
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
      end
      if !captured || !captured.respond_to?("mouse_in_control?") ||
         !captured.mouse_in_control?
        buttons.each do |btn|
          next if captured && btn[1] == captured
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
    @pop_up_bg_bitmap.visible = false
    return ret
  end

  def confirm_message(text)
    return message(text, [:yes, _INTL("Yes")], [:no, _INTL("No")]) == :yes
  end

  #-----------------------------------------------------------------------------

  def filterable_anim_properties(id, anim)
    ret = {}
    ret[:id]        = id
    ret[:move_name] = anim.move
    if anim.move_animation?
      move_name = GameData::Move.try_get(anim.move)&.name
      ret[:move_name] = move_name if move_name
    end
    ret[:anim_name] = anim.name || anim.move
    ret[:version]   = anim.version
    ret[:credit]    = anim.credit
    ret[:usable]    = !anim.ignore
    ret[:foe]       = anim.opposing_animation?
    display_name = ""
    display_name += "\\c[2]" if anim.ignore
    display_name += _INTL("[Foe]") + " " if anim.opposing_animation?
    display_name += "[#{anim.version}]" + " " if anim.version > 0
    display_name += (anim.name || anim.move)
    ret[:display_name] = display_name
    return ret
  end

  def generate_full_lists
    @full_move_animations = {}
    @full_common_animations = {}
    GameData::Animation.keys.each do |id|
      anim = GameData::Animation.get(id)
      hash = filterable_anim_properties(id, anim)
      if anim.move_animation?
        @full_move_animations[anim.move] ||= []
        @full_move_animations[anim.move].push(hash)
      elsif anim.common_animation?
        @full_common_animations[anim.move] ||= []
        @full_common_animations[anim.move].push(hash)
      end
    end
    @full_move_animations.values.each do |val|
      val.sort! { |a, b| a[:display_name] <=> b[:display_name] }
    end
    @full_common_animations.values.each do |val|
      val.sort! { |a, b| a[:display_name] <=> b[:display_name] }
    end
    apply_list_filter
  end

  def apply_list_filter
    # Apply filters to move animations
    @move_animations ||= {}
    @move_animations.clear
    @common_animations ||= {}
    @common_animations.clear
    # Apply filters to animations
    [
      [@full_move_animations, @move_animations],
      [@full_common_animations, @common_animations]
    ].each do |anim_set|
      anim_set[0].each_pair do |move, anims|
        next if @filters[:count] == :one && anims.any? { |anim| anim[:version] > 0 }
        next if @filters[:count] == :many && anims.none? { |anim| anim[:version] > 0 }
        next if @filters[:foe] == :yes && anims.none? { |anim| anim[:foe] }
        next if @filters[:foe] == :no && anims.any? { |anim| anim[:foe] }
        anims.each do |anim|
          next if @filters[:move_name] != "" && !anim[:move_name].downcase.include?(@filters[:move_name].downcase)
          next if @filters[:anim_name] != "" && !anim[:anim_name].downcase.include?(@filters[:anim_name].downcase)
          next if @filters[:credit] != "" && !anim[:credit].downcase.include?(@filters[:credit].downcase)
          next if @filters[:usable] == :yes && !anim[:usable]
          next if @filters[:usable] == :no && anim[:usable]
          anim_set[1][move] ||= []
          anim_set[1][move].push(anim)
        end
      end
    end
    # Create move list from the filtered results
    @move_list = []
    @move_animations.each_pair do |move_id, anims|
      @move_list.push([move_id, anims[0][:move_name]])
    end
    @move_list.uniq!
    @move_list.sort!
    # Create common list from the filtered results
    @common_list = []
    @common_animations.each_pair do |move_id, anims|
      @common_list.push([move_id, move_id])
    end
    @common_list.uniq!
    @common_list.sort!
  end

  def set_filter_options
    anim_names = []
    credits = []
    GameData::Animation.each do |anim|
      anim_names.push(anim.name) if anim.name && anim.name != "" && !anim_names.include?(anim.name)
      credits.push(anim.credit) if anim.credit && anim.credit != "" && !credits.include?(anim.credit)
    end
    anim_names.sort! { |a, b| a.downcase <=> b.downcase }
    credits.sort! { |a, b| a.downcase <=> b.downcase }
    @components.get_control(:anim_name_filter).options = anim_names.to_h { |item| [item, item] }
    @components.get_control(:credit_filter).options = credits.to_h { |item| [item, item] }
  end

  def selected_move_display_animations
    val = @components.get_control(:moves_list).value
    return [] if !val
    ret = []
    ret = @move_animations[val] if @animation_type == 0
    ret = @common_animations[val] if @animation_type == 1
    ret = ret.map { |val| val[:display_name] }
    return ret
  end

  def selected_animation_id
    move = @components.get_control(:moves_list).value
    anim = @components.get_control(:animations_list).value
    return @move_animations[move][anim][:id] if @animation_type == 0
    return @common_animations[move][anim][:id] if @animation_type == 1
    return nil
  end

  #-----------------------------------------------------------------------------

  def refresh
    # Put the correct list into the moves list
    case @animation_type
    when 0
      @components.get_control(:moves).set_highlighted
      @components.get_control(:commons).set_not_highlighted
      @components.get_control(:moves_list).options = @move_list
      @components.get_control(:moves_label).text = _INTL("Move names")
      @components.get_control(:move_name_filter_label).text = _INTL("Move name contains")
    when 1
      @components.get_control(:moves).set_not_highlighted
      @components.get_control(:commons).set_highlighted
      @components.get_control(:moves_list).options = @common_list
      @components.get_control(:moves_label).text = _INTL("Common names")
      @components.get_control(:move_name_filter_label).text = _INTL("Common name contains")
    end
    # Put the correct list into the animations list
    @components.get_control(:animations_list).options = selected_move_display_animations
    # Enable/disable buttons depending on what is selected
    if @components.get_control(:animations_list).value
      @components.get_control(:edit).enable
      @components.get_control(:copy).enable
      @components.get_control(:delete).enable
    else
      @components.get_control(:edit).disable
      @components.get_control(:copy).disable
      @components.get_control(:delete).disable
    end
  end

  #-----------------------------------------------------------------------------

  def apply_button_press(button)
    case button
    when :quit
      @quit = true
      return   # Don't need to refresh the screen
    when :new
      new_anim = GameData::Animation.new_hash(@animation_type, @components.get_control(:moves_list).value)
      new_id = GameData::Animation.keys.max + 1
      screen = AnimationEditor.new(new_id, new_anim)
      screen.run
      generate_full_lists
      set_filter_options
    when :color_scheme
      @settings[:color_scheme] = @components.get_control(button).value
      save_settings
      self.color_scheme = @settings[:color_scheme]
    when :moves
      @animation_type = 0
      @components.get_control(:moves_list).selected = -1
      @components.get_control(:animations_list).selected = -1
    when :commons
      @animation_type = 1
      @components.get_control(:moves_list).selected = -1
      @components.get_control(:animations_list).selected = -1
    when :edit
      anim_id = selected_animation_id
      if anim_id
        screen = AnimationEditor.new(anim_id, GameData::Animation.get(anim_id).clone_as_hash)
        screen.run
        load_settings
        @components.get_control(:color_scheme).value = @settings[:color_scheme]
        self.color_scheme = @settings[:color_scheme]
        generate_full_lists
        set_filter_options
        refresh
      end
    when :copy
      anim_id = selected_animation_id
      if anim_id
        new_anim = GameData::Animation.get(anim_id).clone_as_hash
        new_anim[:name] += " " + _INTL("(copy)") if !nil_or_empty?(new_anim[:name])
        new_id = GameData::Animation.keys.max + 1
        screen = AnimationEditor.new(new_id, new_anim)
        screen.run
        generate_full_lists
        set_filter_options
      end
    when :delete
      anim_id = selected_animation_id
      if anim_id && confirm_message(_INTL("Are you sure you want to delete this animation?"))
        pbs_path = GameData::Animation.get(anim_id).pbs_path
        GameData::Animation::DATA.delete(anim_id)
        if GameData::Animation::DATA.any? { |_key, anim| anim.pbs_path == pbs_path }
          Compiler.write_battle_animation_file(pbs_path)
        elsif FileTest.exist?("PBS/Animations/" + pbs_path + ".txt")
          File.delete("PBS/Animations/" + pbs_path + ".txt")
        end
        generate_full_lists
        set_filter_options
      end
    when :clear_filters
      [:move_name_filter, :anim_name_filter, :credit_filter].each do |filter|
        @components.get_control(filter).value = ""
      end
      [:usable_filter, :count_filter, :foe_filter].each do |filter|
        @components.get_control(filter).value = :none
      end
      apply_list_filter
      refresh
    end
    refresh
  end

  def update_filters
    changed = false
    # Detect change to filters
    [
      [:move_name_filter, :move_name],
      [:anim_name_filter, :anim_name],
      [:credit_filter, :credit],
      [:usable_filter, :usable],
      [:count_filter, :count],
      [:foe_filter, :foe]
    ].each do |filter|
      ctrl = @components.get_control(filter[0])
      next if @filters[filter[1]] == ctrl.value
      @filters[filter[1]] = ctrl.value
      changed = true
    end
    # Refresh if changed
    if changed
      apply_list_filter
      refresh
    end
  end

  def update
    @components.update
    if @components.changed?
      @components.changed_controls.each_pair do |property, value|
        apply_button_press(property)
      end
      @components.clear_changed
    end
    update_filters
  end

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
