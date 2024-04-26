#===============================================================================
#
#===============================================================================
class AnimationEditor::AnimationSelector
  BORDER_THICKNESS          = 4
  LABEL_OFFSET_X            = -4   # Position of label relative to what they're labelling
  LABEL_OFFSET_Y            = -32

  QUIT_BUTTON_WIDTH         = 80
  QUIT_BUTTON_HEIGHT        = 30

  TYPE_BUTTONS_X            = 2
  TYPE_BUTTONS_Y            = 62
  TYPE_BUTTON_WIDTH         = 100
  TYPE_BUTTON_HEIGHT        = 48

  MOVES_LIST_X              = TYPE_BUTTONS_X + TYPE_BUTTON_WIDTH + 2
  MOVES_LIST_Y              = TYPE_BUTTONS_Y + 2
  MOVES_LIST_WIDTH          = 200 + (UIControls::List::BORDER_THICKNESS * 2)
  MOVES_LIST_HEIGHT         = (29 * UIControls::List::ROW_HEIGHT) + (UIControls::List::BORDER_THICKNESS * 2)

  ANIMATIONS_LIST_X         = MOVES_LIST_X + MOVES_LIST_WIDTH + 4
  ANIMATIONS_LIST_Y         = MOVES_LIST_Y
  ANIMATIONS_LIST_WIDTH     = 300 + (UIControls::List::BORDER_THICKNESS * 2)
  ANIMATIONS_LIST_HEIGHT    = MOVES_LIST_HEIGHT

  ACTION_BUTTON_WIDTH       = 200
  ACTION_BUTTON_HEIGHT      = 48
  ACTION_BUTTON_X           = ANIMATIONS_LIST_X + ANIMATIONS_LIST_WIDTH + 2
  ACTION_BUTTON_Y           = TYPE_BUTTONS_Y + ((ANIMATIONS_LIST_HEIGHT - (ACTION_BUTTON_HEIGHT * 3)) / 2) + 4

  FILTER_BOX_WIDTH          = ACTION_BUTTON_WIDTH
  FILTER_BOX_HEIGHT         = UIControls::TextBox::TEXT_BOX_HEIGHT
  FILTER_BOX_X              = ACTION_BUTTON_X
  FILTER_BOX_Y              = MOVES_LIST_Y

  # Pop-up window
  MESSAGE_BOX_WIDTH         = AnimationEditor::WINDOW_WIDTH * 3 / 4
  MESSAGE_BOX_HEIGHT        = 160
  MESSAGE_BOX_BUTTON_WIDTH  = 150
  MESSAGE_BOX_BUTTON_HEIGHT = 32
  MESSAGE_BOX_SPACING       = 16

  def initialize
    @animation_type = 0   # 0=move, 1=common
    @filter_text = ""
    @quit = false
    generate_full_lists
    initialize_viewports
    initialize_bitmaps
    initialize_controls
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
    # Filter text box
    text_box = UIControls::TextBox.new(FILTER_BOX_WIDTH, FILTER_BOX_HEIGHT, @viewport, "")
    @components.add_control_at(:filter, text_box, FILTER_BOX_X, FILTER_BOX_Y)
    # Filter text box label
    label = UIControls::Label.new(FILTER_BOX_WIDTH, TYPE_BUTTON_HEIGHT, @viewport, _INTL("Filter text"))
    label.header = true
    @components.add_control_at(:filter_label, label, FILTER_BOX_X + LABEL_OFFSET_X, FILTER_BOX_Y + LABEL_OFFSET_Y)
  end

  def dispose
    @screen_bitmap.dispose
    @pop_up_bg_bitmap.dispose
    @components.dispose
    @viewport.dispose
    @pop_up_viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, Color.white)
    # Make the pop-up background semi-transparent
    @pop_up_bg_bitmap.bitmap.fill_rect(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, Color.new(0, 0, 0, 128))
  end

  #-----------------------------------------------------------------------------

  def create_pop_up_window(width, height)
    ret = BitmapSprite.new(width + (BORDER_THICKNESS * 2),
                           height + (BORDER_THICKNESS * 2), @pop_up_viewport)
    ret.x = (AnimationEditor::WINDOW_WIDTH - ret.width) / 2
    ret.y = (AnimationEditor::WINDOW_HEIGHT - ret.height) / 2
    ret.z = -1
    ret.bitmap.font.color = Color.black
    ret.bitmap.font.size = 18
    # Draw pop-up box border
    ret.bitmap.border_rect(BORDER_THICKNESS, BORDER_THICKNESS, width, height,
                           BORDER_THICKNESS, Color.white, Color.black)
    # Fill pop-up box with white
    ret.bitmap.fill_rect(BORDER_THICKNESS, BORDER_THICKNESS, width, height, Color.white)
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
      btn = UIControls::Button.new(MESSAGE_BOX_BUTTON_WIDTH, MESSAGE_BOX_BUTTON_HEIGHT, @pop_up_viewport, option[1])
      btn.x = msg_bitmap.x + (msg_bitmap.width - (MESSAGE_BOX_BUTTON_WIDTH * options.length)) / 2
      btn.x += MESSAGE_BOX_BUTTON_WIDTH * i
      btn.y = msg_bitmap.y + msg_bitmap.height - MESSAGE_BOX_BUTTON_HEIGHT - MESSAGE_BOX_SPACING
      btn.set_fixed_size
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
    @pop_up_bg_bitmap.visible = false
    return ret
  end

  def confirm_message(text)
    return message(text, [:yes, _INTL("Yes")], [:no, _INTL("No")]) == :yes
  end

  #-----------------------------------------------------------------------------

  def generate_full_lists
    @full_move_animations = {}
    @full_common_animations = {}
    GameData::Animation.keys.each do |id|
      anim = GameData::Animation.get(id)
      name = ""
      name += "\\c[2]" if anim.ignore
      name += _INTL("[Foe]") + " " if anim.opposing_animation?
      name += "[#{anim.version}]" + " " if anim.version > 0
      name += (anim.name || anim.move)
      if anim.move_animation?
        move_name = GameData::Move.try_get(anim.move)&.name || anim.move
        @full_move_animations[anim.move] ||= []
        @full_move_animations[anim.move].push([id, name, move_name])
      elsif anim.common_animation?
        @full_common_animations[anim.move] ||= []
        @full_common_animations[anim.move].push([id, name])
      end
    end
    @full_move_animations.values.each do |val|
      val.sort! { |a, b| a[1] <=> b[1] }
    end
    @full_common_animations.values.each do |val|
      val.sort! { |a, b| a[1] <=> b[1] }
    end
    apply_list_filter
  end

  def apply_list_filter
    # Apply filter
    if @filter_text == ""
      @move_animations = @full_move_animations.clone
      @common_animations = @full_common_animations.clone
    else
      filter = @filter_text.downcase
      @move_animations.clear
      @full_move_animations.each_pair do |move, anims|
        anims.each do |anim|
          next if !anim[1].downcase.include?(filter) && !anim[2].downcase.include?(filter)
          @move_animations[move] ||= []
          @move_animations[move].push(anim)
        end
      end
      @common_animations.clear
      @full_common_animations.each_pair do |common, anims|
        anims.each do |anim|
          next if !anim[1].downcase.include?(filter) && !common.downcase.include?(filter)
          @common_animations[common] ||= []
          @common_animations[common].push(anim)
        end
      end
    end
    # Create move list from the filtered results
    @move_list = []
    @move_animations.each_pair do |move_id, anims|
      @move_list.push([move_id, anims[0][2]])
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
      @components.get_control(:moves).set_highlighted
      @components.get_control(:commons).set_not_highlighted
      @components.get_control(:moves_list).values = @move_list
      @components.get_control(:moves_label).text = _INTL("Moves")
    when 1
      @components.get_control(:moves).set_not_highlighted
      @components.get_control(:commons).set_highlighted
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
      new_anim = GameData::Animation.new_hash(@animation_type, @components.get_control(:moves_list).value)
      new_id = GameData::Animation.keys.max + 1
      screen = AnimationEditor.new(new_id, new_anim)
      screen.run
      generate_full_lists
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
        generate_full_lists
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
    # Detect change to filter text
    filter_ctrl = @components.get_control(:filter)
    if filter_ctrl.value != @filter_text
      @filter_text = filter_ctrl.value
      apply_list_filter
      refresh
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
