#===============================================================================
#
#===============================================================================
class AnimationEditor::MenuBar < UIControls::BaseContainer
  # NOTE: The innermost ring of pixels outside this container are the same color
  #       as it, making it look 1 pixel wider in each direction than it actually
  #       is. EDGE_BUFFER compensates for this.
  EDGE_BUFFER    = 1
  BUTTON_WIDTH   = 74
  BUTTON_HEIGHT  = 26
  BUTTON_SPACING = 2

  QUIT_BUTTON_X          = BUTTON_SPACING - EDGE_BUFFER   # 1
  QUIT_BUTTON_Y          = BUTTON_SPACING - EDGE_BUFFER   # 1
  SAVE_BUTTON_X          = QUIT_BUTTON_X + BUTTON_WIDTH + BUTTON_SPACING   # 77
  SAVE_BUTTON_Y          = QUIT_BUTTON_Y   # 1
  HELP_BUTTON_X          = SAVE_BUTTON_X + BUTTON_WIDTH + BUTTON_SPACING   # 153
  HELP_BUTTON_Y          = SAVE_BUTTON_Y   # 1
  SETTINGS_BUTTON_X      = HELP_BUTTON_X + BUTTON_WIDTH + BUTTON_SPACING   # 229
  SETTINGS_BUTTON_Y      = HELP_BUTTON_Y   # 1
  SETTINGS_BUTTON_WIDTH  = BUTTON_HEIGHT   # 26, button's bitmap width is 18
  SETTINGS_BUTTON_HEIGHT = BUTTON_HEIGHT   # 26, button's bitmap height is 18
  NAME_BUTTON_X          = QUIT_BUTTON_X   # 1
  NAME_BUTTON_Y          = QUIT_BUTTON_Y + BUTTON_HEIGHT + BUTTON_SPACING   # 29
  NAME_BUTTON_WIDTH      = SETTINGS_BUTTON_X + SETTINGS_BUTTON_WIDTH - NAME_BUTTON_X   # 254
  NAME_BUTTON_HEIGHT     = (BUTTON_HEIGHT - UIControls::Button::BUTTON_FRAME_THICKNESS) * 2   # 44

  TOTAL_WIDTH  = NAME_BUTTON_X + NAME_BUTTON_WIDTH + BUTTON_SPACING - EDGE_BUFFER   # 256
  TOTAL_HEIGHT = NAME_BUTTON_Y + NAME_BUTTON_HEIGHT + BUTTON_SPACING - EDGE_BUFFER   # 74

  def initialize(x, y, width, height, viewport)
    super(x, y, width, height)
    @viewport.z = viewport.z + 10   # So that it appears over the canvas
  end

  def initialize_bitmaps
    # Editor settings button bitmap
    btmp_width = (SETTINGS_BUTTON_WIDTH / 2) - UIControls::BitmapButton::BUTTON_FRAME_THICKNESS   # 9
    btmp_height = (SETTINGS_BUTTON_HEIGHT / 2) - UIControls::BitmapButton::BUTTON_FRAME_THICKNESS   # 9
    # The top left quarter of a cog
    btmp_graphic = %w(
      . . . . . . . . X
      . . . . . . . X X
      . . X X X . . X X
      . . X X X X . X X
      . . X X X X X X X
      . . . X X X X X X
      . . . . X X X X .
      . X X X X X X . .
      X X X X X X . . .
    )
    @bitmaps[:settings] = Bitmap.new(btmp_width * 2, btmp_height * 2) if !@bitmaps[:settings]
    btmp = @bitmaps[:settings]
    icon_color = get_color_of(:text)
    btmp_graphic.length.times do |i|
      next if btmp_graphic[i] == "."
      pixel_x = i % btmp_width
      pixel_y = i / btmp_width
      btmp.fill_rect(pixel_x, pixel_y, 1, 1, icon_color)
      btmp.fill_rect(btmp.width - 1 - pixel_x, pixel_y, 1, 1, icon_color)
      btmp.fill_rect(pixel_x, btmp.height - 1 - pixel_y, 1, 1, icon_color)
      btmp.fill_rect(btmp.width - 1 - pixel_x, btmp.height - 1 - pixel_y, 1, 1, icon_color)
    end
  end

  def initialize_controls
    add_control_at(:quit, QUIT_BUTTON_X, QUIT_BUTTON_Y,
                   UIControls::Button.new(BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, _INTL("Quit")))
    add_control_at(:save, SAVE_BUTTON_X, SAVE_BUTTON_Y,
                   UIControls::Button.new(BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, _INTL("Save")))
    add_control_at(:help, HELP_BUTTON_X, HELP_BUTTON_Y,
                   UIControls::Button.new(BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, _INTL("Help")))
    add_control_at(:settings, SETTINGS_BUTTON_X, SETTINGS_BUTTON_Y,
                   UIControls::BitmapButton.new(@viewport, @bitmaps[:settings]))
    add_control_at(:name, NAME_BUTTON_X, NAME_BUTTON_Y,
                   UIControls::Button.new(NAME_BUTTON_WIDTH, NAME_BUTTON_HEIGHT, @viewport, ""))
  end

  #-----------------------------------------------------------------------------

  def anim_name=(val)
    ctrl = get_control(:name)
    ctrl.set_text(val) if ctrl
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    initialize_bitmaps
    if @controls
      @controls.each_value { |c| c.color_scheme = value }
      repaint
    end
  end
end

#===============================================================================
#
#===============================================================================
class AnimationEditor::BattlersLayout < UIControls::BaseContainer
  LABEL_X      = 4
  CONTROL_X    = 143
  FIRST_LINE_Y = 0
  LINE_SPACING = 24

  def initialize_controls
    label_width = CONTROL_X - LABEL_X
    ctrl_y = FIRST_LINE_Y
    ctrl_width = @width - CONTROL_X
    # Header
    add_control_at(:header, 0, ctrl_y,
                   UIControls::Label.new(@width, LINE_SPACING, @viewport, _INTL("Battler positions")))
    @controls[:header].header = true
    ctrl_y += LINE_SPACING
    # Side sizes
    add_control_at(:side_size_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("Side sizes")))
    add_control_at(:side_size_1, CONTROL_X, ctrl_y,
                   UIControls::DropdownList.new(38, LINE_SPACING, @viewport, {
                     1 => "1",
                     2 => "2",
                     3 => "3"
                   }, 1))
    add_control_at(:side_size_vs_label, CONTROL_X + 39, ctrl_y,
                   UIControls::Label.new(24, LINE_SPACING, @viewport, _INTL("vs.")))
    add_control_at(:side_size_2, CONTROL_X + 67, ctrl_y,
                   UIControls::DropdownList.new(38, LINE_SPACING, @viewport, {
                     1 => "1",
                     2 => "2",
                     3 => "3"
                   }, 1))
    ctrl_y += LINE_SPACING
    # User index
    add_control_at(:user_index_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("User index")))
    add_control_at(:user_index, CONTROL_X, ctrl_y,
                   UIControls::DropdownList.new(38, LINE_SPACING, @viewport, {
                     1 => "1",
                     2 => "2",
                     3 => "3"
                   }, 1))
    ctrl_y += LINE_SPACING
    # Target indices
    add_control_at(:target_indices_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("Target indices")))
    add_control_at(:target_indices, CONTROL_X, ctrl_y,
                   UIControls::TextBox.new(105, LINE_SPACING, @viewport, ""))
    ctrl_y += LINE_SPACING
    # User opposes
    add_control_at(:user_opposes_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("User is opposing?")))
    add_control_at(:user_opposes, CONTROL_X, ctrl_y,
                   UIControls::Checkbox.new(40, LINE_SPACING, @viewport, false))
  end
end

#===============================================================================
#
#===============================================================================
class AnimationEditor::PlayControls < UIControls::BaseContainer
  attr_reader :slowdown, :looping
  attr_writer :anim

  SLOWDOWN_FACTORS     = [1, 2, 4, 6, 8]

  BUTTON_SPACING       = 2
  LABEL_HEIGHT         = 28
  PLAY_BUTTON_X        = 11
  PLAY_BUTTON_Y        = 11
  PLAY_BUTTON_SIZE     = 50   # Full size of button; bitmap in the button is 42
  LOOP_BUTTON_SIZE     = 24   # Full size of button; bitmap in the button is 16
  LOOP_BUTTON_X        = PLAY_BUTTON_X + PLAY_BUTTON_SIZE + BUTTON_SPACING
  LOOP_BUTTON_Y        = PLAY_BUTTON_Y + ((PLAY_BUTTON_SIZE - LOOP_BUTTON_SIZE) / 2)
  SLOWDOWN_BUTTON_X    = AnimationEditor::MenuBar::TOTAL_WIDTH - PLAY_BUTTON_X   # This is the right side of the buttons, not the left
  SLOWDOWN_BUTTON_Y    = LOOP_BUTTON_Y
  SLOWDOWN_BUTTON_SIZE = LOOP_BUTTON_SIZE
  # NOTE: Slowdown label is centered horizontally over the buttons.
  SLOWDOWN_LABEL_X     = SLOWDOWN_BUTTON_X
  SLOWDOWN_LABEL_X     -= ((SLOWDOWN_FACTORS.length * (SLOWDOWN_BUTTON_SIZE + BUTTON_SPACING)) - BUTTON_SPACING) / 2
  SLOWDOWN_LABEL_X     -= UIControls::Label::LEFT_PADDING
  SLOWDOWN_LABEL_Y     = 0
  # NOTE: Duration label and value are centered horizontally on DURATION_TEXT_X.
  DURATION_LABEL_X     = 122
  DURATION_LABEL_Y     = 48
  DURATION_VALUE_X     = DURATION_LABEL_X + 109   # This is the right side of the label, not the left
  DURATION_VALUE_Y     = DURATION_LABEL_Y

  def initialize(x, y, width, height, viewport, anim)
    @anim = anim
    @fps = @anim[:fps]
    @duration = 0
    @slowdown = SLOWDOWN_FACTORS[0]
    @looping  = false
    super(x, y, width, height)
    @viewport.z = viewport.z + 10
  end

  # This is also called when the color scheme changes.
  def initialize_bitmaps
    icon_color = get_color_of(:text)
    # Play button
    play_bitmap_size = PLAY_BUTTON_SIZE - (UIControls::Button::BUTTON_FRAME_THICKNESS * 2)
    @bitmaps[:play] = Bitmap.new(play_bitmap_size, play_bitmap_size) if !@bitmaps[:play]
    @bitmaps[:play].clear
    (play_bitmap_size - 10).times do |j|
      @bitmaps[:play].fill_rect(
        11, j + 5,
        (j >= (play_bitmap_size - 10) / 2) ? play_bitmap_size - j - 4 : j + 7,
        1,
        icon_color
      )
    end
    # Stop button
    @bitmaps[:stop] = Bitmap.new(play_bitmap_size, play_bitmap_size) if !@bitmaps[:stop]
    @bitmaps[:stop].clear
    @bitmaps[:stop].fill_rect(8, 8, play_bitmap_size - 16, play_bitmap_size - 16, icon_color)
    # Loop button (play once)
    loop_btmp_size = LOOP_BUTTON_SIZE - (UIControls::BitmapButton::BUTTON_FRAME_THICKNESS * 2)   # 16
    @bitmaps[:play_once] = Bitmap.new(loop_btmp_size, loop_btmp_size) if !@bitmaps[:play_once]
    @bitmaps[:play_once].clear
    %w(
      . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . X X . . . X X .
      . . . . . . . . X X X . . X X .
      . X X X X X X X X X X X . X X .
      . X X X X X X X X X X X . X X .
      . . . . . . . . X X X . . X X .
      . . . . . . . . X X . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . X X .
      . . . . . . . . . . . . . . . .

    ).each_with_index do |val, i|
      next if val == "."
      @bitmaps[:play_once].fill_rect(i % loop_btmp_size, i / loop_btmp_size, 1, 1, icon_color)
    end
    # Loop button (looping)
    @bitmaps[:play_loop] = Bitmap.new(loop_btmp_size, loop_btmp_size) if !@bitmaps[:play_loop]
    @bitmaps[:play_loop].clear
    %w(
      . . . . . . . . . . . . . . . .
      . . . . . . . . . X X . . . . .
      . . . . . . . . . X X X . . . .
      . . X X X X X X X X X X X . . .
      . X X X X X X X X X X X X . . .
      . X X X . . . . . X X X . . X .
      . X X . . . . . . X X . . X X .
      . X X . . . . . . . . . . X X .
      . X X . . . . . . . . . . X X .
      . X X . . X X . . . . . . X X .
      . X . . X X X . . . . . X X X .
      . . . X X X X X X X X X X X X .
      . . . X X X X X X X X X X X . .
      . . . . X X X . . . . . . . . .
      . . . . . X X . . . . . . . . .
      . . . . . . . . . . . . . . . .
    ).each_with_index do |val, i|
      next if val == "."
      @bitmaps[:play_loop].fill_rect(i % loop_btmp_size, i / loop_btmp_size, 1, 1, icon_color)
    end
  end

  def initialize_controls
    # Play button
    add_control_at(:play, PLAY_BUTTON_X, PLAY_BUTTON_Y,
                   UIControls::BitmapButton.new(self.viewport, @bitmaps[:play]))
    @controls[:play].disable
    # Stop button
    add_control_at(:stop, PLAY_BUTTON_X, PLAY_BUTTON_Y,
                   UIControls::BitmapButton.new(self.viewport, @bitmaps[:stop]))
    @controls[:stop].visible = false
    # Loop button (play once)
    add_control_at(:loop, LOOP_BUTTON_X, LOOP_BUTTON_Y,
                   UIControls::BitmapButton.new(self.viewport, @bitmaps[:play_once]))
    @controls[:loop].visible = !@looping
    # Loop button (looping)
    add_control_at(:unloop, LOOP_BUTTON_X, LOOP_BUTTON_Y,
                   UIControls::BitmapButton.new(self.viewport, @bitmaps[:play_loop]))
    @controls[:unloop].visible = @looping
    # Slowdown label
    add_control_at(:slowdown_label, SLOWDOWN_LABEL_X, SLOWDOWN_LABEL_Y,
                   UIControls::Label.new(200, LABEL_HEIGHT, self.viewport, _INTL("Slowdown factor")))
    @controls[:slowdown_label].x -= (@controls[:slowdown_label].text_width / 2)
    # Slowdown factor buttons
    SLOWDOWN_FACTORS.each_with_index do |value, i|
      id = ("slowdown" + value.to_s).to_sym
      button_x = SLOWDOWN_BUTTON_X - (SLOWDOWN_FACTORS.length * (SLOWDOWN_BUTTON_SIZE + BUTTON_SPACING)) + BUTTON_SPACING
      button_x += i * (SLOWDOWN_BUTTON_SIZE + BUTTON_SPACING)
      add_control_at(id, button_x, SLOWDOWN_BUTTON_Y,
                     UIControls::Button.new(SLOWDOWN_BUTTON_SIZE, SLOWDOWN_BUTTON_SIZE, self.viewport, value.to_s))
      @controls[id].set_highlighted if value == @slowdown
    end
    # Duration label
    add_control_at(:duration_label, DURATION_LABEL_X, DURATION_LABEL_Y,
                   UIControls::Label.new(200, LABEL_HEIGHT, self.viewport, _INTL("Duration:")))
    # Duration value
    add_control_at(:duration_value, DURATION_VALUE_X, DURATION_VALUE_Y,
                   UIControls::Label.new(200, LABEL_HEIGHT, self.viewport,
                                         _ISPRINTF("{1:.02f}s", @duration / @anim[:fps].to_f)))
    @controls[:duration_value].x -= @controls[:duration_value].text_width
  end

  #-----------------------------------------------------------------------------

  def duration=(new_val)
    return if @duration == new_val && @fps == @anim[:fps]
    @fps = @anim[:fps]
    @duration = new_val
    if @duration == 0
      get_control(:play).disable
    else
      get_control(:play).enable
    end
    ctrl = get_control(:duration_value)
    ctrl.text = _ISPRINTF("{1:.02f}s", @duration / @anim[:fps].to_f)
    ctrl.x = DURATION_VALUE_X - ctrl.text_width
    refresh
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    initialize_bitmaps   # Needs to be before repainting
    if @controls
      @controls.each_value { |c| c.color_scheme = value }
      repaint
    end
  end

  #-----------------------------------------------------------------------------

  def prepare_to_play_animation
    get_control(:play).visible = false
    get_control(:stop).visible = true
    @controls.each_pair { |id, c| c.disable if id != :stop }
  end

  def end_playing_animation
    get_control(:stop).visible = false
    get_control(:play).visible = true
    @controls.each_value { |c| c.enable }
  end

  #-----------------------------------------------------------------------------

  def make_control_change(key)
    case key
    when :loop
      get_control(:loop).visible = false
      get_control(:unloop).visible = true
      @looping = true
      @changed_controls.delete(key)   # Don't need to announce this has changed
    when :unloop
      get_control(:unloop).visible = false
      get_control(:loop).visible = true
      @looping = false
      @changed_controls.delete(key)   # Don't need to announce this has changed
    else
      if key.to_s[/slowdown/]
        # A slowdown button was pressed; apply its effect now
        @slowdown = key.to_s.sub("slowdown", "").to_i
        @controls.each_pair do |id, c|
          next if !id.to_s[/slowdown\d+/]
          if id.to_s.sub("slowdown", "").to_i == @slowdown
            c.set_highlighted
          else
            c.set_not_highlighted
          end
        end
        @changed_controls.delete(key)   # Don't need to announce this has changed
      end
    end
  end

  def update
    super
    if @changed_controls
      @changed_controls.keys.each { |key| make_control_change(key) }
      @changed_controls = nil if @changed_controls.empty?
    end
  end
end

#===============================================================================
#
#===============================================================================
class AnimationEditor::BatchEdits < UIControls::BaseContainer
  LABEL_X      = 4
  CONTROL_X    = 143
  FIRST_LINE_Y = 0
  LINE_SPACING = 24

  LEFT_RIGHT_BUTTON_WIDTH = 20
  UNDO_BUTTON_WIDTH = 74
  BUTTON_HEIGHT = 20
  BUTTON_SPACING = 4
  BUTTON_Y_OFFSET = (LINE_SPACING - BUTTON_HEIGHT) / 2

  def initialize_controls
    label_width = CONTROL_X - LABEL_X
    ctrl_y = FIRST_LINE_Y
    ctrl_width = @width - CONTROL_X
    # Header
    add_control_at(:header, 0, ctrl_y,
                   UIControls::Label.new(@width, LINE_SPACING, @viewport, _INTL("Batch edits")))
    @controls[:header].header = true
    ctrl_y += LINE_SPACING
    # Undo/redo buttons
    add_control_at(:undo, ((@width - BUTTON_SPACING) / 2) - UNDO_BUTTON_WIDTH, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(UNDO_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "Undo"))
    add_control_at(:redo, ((@width + BUTTON_SPACING) / 2), ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(UNDO_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "Redo"))
    ctrl_y += LINE_SPACING
    # Time shifts header
    add_control_at(:time_shifts_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(@width, LINE_SPACING, @viewport, _INTL("Time shifts")))
    get_control(:time_shifts_label).underlined = true
    ctrl_y += LINE_SPACING
    # Shift all particles
    add_control_at(:shift_all_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("All particles")))
    add_control_at(:shift_all_left, CONTROL_X, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "<"))
    add_control_at(:shift_all_right, CONTROL_X + LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, ">"))
    add_control_at(:shift_all_after_left, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 2, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|<"))
    add_control_at(:shift_all_after_right, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 3, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|>"))
    ctrl_y += LINE_SPACING
    # Shift selected particle
    add_control_at(:shift_one_label, LABEL_X, ctrl_y,
                   UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("Selected particle")))
    add_control_at(:shift_one_left, CONTROL_X, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "<"))
    add_control_at(:shift_one_right, CONTROL_X + LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, ">"))
    add_control_at(:shift_one_after_left, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 2, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|<"))
    add_control_at(:shift_one_after_right, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 3, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|>"))
    ctrl_y += LINE_SPACING
    # Shift selected row
    add_control_at(:shift_row_label, LABEL_X, ctrl_y,
                  UIControls::Label.new(label_width, LINE_SPACING, @viewport, _INTL("Selected row")))
    add_control_at(:shift_row_left, CONTROL_X, ctrl_y + BUTTON_Y_OFFSET,
                  UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "<"))
    add_control_at(:shift_row_right, CONTROL_X + LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING, ctrl_y + BUTTON_Y_OFFSET,
                  UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, ">"))
    add_control_at(:shift_row_after_left, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 2, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|<"))
    add_control_at(:shift_row_after_right, CONTROL_X + (LEFT_RIGHT_BUTTON_WIDTH + BUTTON_SPACING) * 3, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(LEFT_RIGHT_BUTTON_WIDTH, BUTTON_HEIGHT, @viewport, "|>"))
    ctrl_y += LINE_SPACING
    # Command values header
    add_control_at(:command_values_label, LABEL_X, ctrl_y,
                  UIControls::Label.new(@width, LINE_SPACING, @viewport, _INTL("Command values")))
    get_control(:command_values_label).underlined = true
    ctrl_y += LINE_SPACING
    # Edit command values button
    add_control_at(:offset_commands, LABEL_X, ctrl_y + BUTTON_Y_OFFSET,
                   UIControls::Button.new(100, BUTTON_HEIGHT, @viewport, _INTL("Apply offset")))
    ctrl_y += LINE_SPACING
  end
end
