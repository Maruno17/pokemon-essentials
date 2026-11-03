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
