#===============================================================================
#
#===============================================================================
class AnimationEditor::AnimationSelector
  QUIT_BUTTON_WIDTH      = 80
  QUIT_BUTTON_HEIGHT     = 30

  TYPE_BUTTONS_X         = 2
  TYPE_BUTTONS_Y         = 62
  TYPE_BUTTON_WIDTH      = 100
  TYPE_BUTTON_HEIGHT     = 48

  MOVES_LIST_X           = TYPE_BUTTONS_X + TYPE_BUTTON_WIDTH + 4
  MOVES_LIST_Y           = TYPE_BUTTONS_Y + 4
  MOVES_LIST_WIDTH       = 200
  MOVES_LIST_HEIGHT      = 26 * UIControls::List::ROW_HEIGHT

  ANIMATIONS_LIST_X      = MOVES_LIST_X + MOVES_LIST_WIDTH + 8
  ANIMATIONS_LIST_Y      = MOVES_LIST_Y
  ANIMATIONS_LIST_WIDTH  = 300
  ANIMATIONS_LIST_HEIGHT = MOVES_LIST_HEIGHT

  ACTION_BUTTON_WIDTH    = 200
  ACTION_BUTTON_HEIGHT   = 48
  ACTION_BUTTON_X        = ANIMATIONS_LIST_X + ANIMATIONS_LIST_WIDTH + 4
  ACTION_BUTTON_Y        = TYPE_BUTTONS_Y + ((ANIMATIONS_LIST_HEIGHT - (ACTION_BUTTON_HEIGHT * 3)) / 2) + 4

  def initialize
    generate_lists
    @viewport = Viewport.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @viewport)
    draw_editor_background
    @animation_type = 0   # 0=move, 1=common
    @quit = false
    create_controls
    refresh
  end

  def dispose
    @screen_bitmap.dispose
    @components.dispose
    @viewport.dispose
  end

  LABEL_OFFSET_X = -4
  LABEL_OFFSET_Y = -32

  def create_controls
    @components = UIControls::ControlsContainer.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    # Quit button
    btn = UIControls::Button.new(QUIT_BUTTON_WIDTH, QUIT_BUTTON_HEIGHT, @viewport, _INTL("Quit"))
    btn.set_fixed_size
    @components.add_control_at(:quit, btn, 0, 0)
    # New button
    btn = UIControls::Button.new(QUIT_BUTTON_WIDTH, QUIT_BUTTON_HEIGHT, @viewport, _INTL("New"))
    btn.set_fixed_size
    @components.add_control_at(:new, btn, QUIT_BUTTON_WIDTH, 0)
    # Type label
    label = UIControls::Label.new(TYPE_BUTTON_WIDTH, TYPE_BUTTON_HEIGHT, @viewport, _INTL("Anim types"))
    label.header = true
    @components.add_control_at(:type_label, label, TYPE_BUTTONS_X + LABEL_OFFSET_X + 4, TYPE_BUTTONS_Y + LABEL_OFFSET_Y + 4)
    # Animation type toggle buttons
    [[:moves, _INTL("Moves")], [:commons, _INTL("Common")]].each_with_index do |val, i|
      btn = UIControls::Button.new(TYPE_BUTTON_WIDTH, TYPE_BUTTON_HEIGHT, @viewport, val[1])
      btn.set_fixed_size
      @components.add_control_at(val[0], btn, TYPE_BUTTONS_X, TYPE_BUTTONS_Y + (i * TYPE_BUTTON_HEIGHT))
    end
    # TODO: Filter text box for :moves_list's contents. Applies the filter upon
    #       every change to the text box's value. Perhaps it should only do so
    #       after 0.5 seconds of non-typing. What exactly should the filter be
    #       applied to? Animation's name, move's name (if there is one), what
    #       else?
    # Moves list label
    label = UIControls::Label.new(MOVES_LIST_WIDTH, TYPE_BUTTON_HEIGHT, @viewport, _INTL("Moves"))
    label.header = true
    @components.add_control_at(:moves_label, label, MOVES_LIST_X + LABEL_OFFSET_X, MOVES_LIST_Y + LABEL_OFFSET_Y)
    # Moves list
    list = UIControls::List.new(MOVES_LIST_WIDTH, MOVES_LIST_HEIGHT, @viewport, [])
    @components.add_control_at(:moves_list, list, MOVES_LIST_X, MOVES_LIST_Y)
    # Animations list label
    label = UIControls::Label.new(ANIMATIONS_LIST_WIDTH, TYPE_BUTTON_HEIGHT, @viewport, _INTL("Animations"))
    label.header = true
    @components.add_control_at(:animations_label, label, ANIMATIONS_LIST_X + LABEL_OFFSET_X, ANIMATIONS_LIST_Y + LABEL_OFFSET_Y)
    # Animations list
    list = UIControls::List.new(ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT, @viewport, [])
    @components.add_control_at(:animations_list, list, ANIMATIONS_LIST_X, ANIMATIONS_LIST_Y)
    # Edit, Copy and Delete buttons
    [[:edit, _INTL("Edit animation")], [:copy, _INTL("Copy animation")], [:delete, _INTL("Delete animation")]].each_with_index do |val, i|
      btn = UIControls::Button.new(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT, @viewport, val[1])
      btn.set_fixed_size
      @components.add_control_at(val[0], btn, ACTION_BUTTON_X, ACTION_BUTTON_Y + (i * ACTION_BUTTON_HEIGHT))
    end
  end

  def draw_editor_background
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, Color.white)
    # Outlines around lists
    areas = [
      [MOVES_LIST_X, MOVES_LIST_Y, MOVES_LIST_WIDTH, MOVES_LIST_HEIGHT],
      [ANIMATIONS_LIST_X, ANIMATIONS_LIST_Y, ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT]
    ]
    areas.each do |area|
      @screen_bitmap.bitmap.outline_rect(area[0] - 2, area[1] - 2, area[2] + 4, area[3] + 4, Color.black)
    end
  end

  #-----------------------------------------------------------------------------

  def generate_lists
    @move_list = []
    @common_list = []
    @move_animations = {}
    @common_animations = {}
    GameData::Animation.keys.each do |id|
      anim = GameData::Animation.get(id)
      name = ""
      name += _INTL("[Foe]") + " " if anim.opposing_animation?
      name += "[#{anim.version}]" + " " if anim.version > 0
      name += (anim.name || anim.move)
      if anim.move_animation?
        move_name = GameData::Move.try_get(anim.move)&.name || anim.move
        @move_list.push([anim.move, move_name]) if !@move_animations[anim.move]
        @move_animations[anim.move] ||= []
        @move_animations[anim.move].push([id, name])
      elsif anim.common_animation?
        @common_list.push([anim.move, anim.move]) if !@common_animations[anim.move]
        @common_animations[anim.move] ||= []
        @common_animations[anim.move].push([id, name])
      end
    end
    @move_list.sort!
    @common_list.sort!
    @move_animations.values.each do |val|
      val.sort! { |a, b| a[1] <=> b[1] }
    end
    @common_animations.values.each do |val|
      val.sort! { |a, b| a[1] <=> b[1] }
    end
  end

  def selected_move_animations
    val = @components.get_control(:moves_list).value
    return [] if !val
    return @move_animations[val] if @animation_type == 0
    return @common_animations[val] if @animation_type == 1
    return []
  end

  def selected_animation_id
    return @components.get_control(:animations_list).value
  end

  #-----------------------------------------------------------------------------

  def refresh
    # Put the correct list into the moves list
    case @animation_type
    when 0
      @components.get_control(:moves).disable
      @components.get_control(:commons).enable
      @components.get_control(:moves_list).values = @move_list
      @components.get_control(:moves_label).text = _INTL("Moves")
    when 1
      @components.get_control(:moves).enable
      @components.get_control(:commons).disable
      @components.get_control(:moves_list).values = @common_list
      @components.get_control(:moves_label).text = _INTL("Common animations")
    end
    # Put the correct list into the animations list
    @components.get_control(:animations_list).values = selected_move_animations
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
      # TODO: New animation.
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
        # TODO: Might want to select whichever options in each list get to
        #       the animation with ID anim_id.
        generate_lists
      end
    when :copy
      anim_id = selected_animation_id
      if anim_id
        # TODO: Copy animation.
      end
    when :delete
      anim_id = selected_animation_id
      if anim_id
        # TODO: Delete animation.
      end
    end
    refresh
  end

  def update
    @components.update
    if @components.changed?
      @components.values.each_pair do |property, value|
        apply_button_press(property)
      end
      @components.clear_changed
    end
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

#===============================================================================
# Add to Debug menu.
#===============================================================================
MenuHandlers.add(:debug_menu, :use_pc, {
  "name"        => _INTL("New Animation Editor"),
  "parent"      => :main,
  "description" => _INTL("Open the new animation editor."),
  "effect"      => proc {
    Graphics.resize_screen(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    pbSetResizeFactor(1)
    screen = AnimationEditor::AnimationSelector.new
    screen.run
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    pbSetResizeFactor($PokemonSystem.screensize)
    $game_map&.autoplay
  }
})
