#===============================================================================
#
#===============================================================================
class UIControls::ColorPicker < UIControls::BaseControl
  BUTTON_WIDTH  = 30
  BUTTON_HEIGHT = 20

  PICKER_BOX_PREVIEW_X            = 7   # For the colored part, not the preview's outline
  PICKER_BOX_PREVIEW_Y            = 7   # For the colored part, not the preview's outline
  PICKER_BOX_PREVIEW_WIDTH        = 48
  PICKER_BOX_PREVIEW_HEIGHT       = PICKER_BOX_PREVIEW_WIDTH   # Make it square
  PICKER_BOX_ROW_HEIGHT           = 24
  PICKER_BOX_LABEL_SPACING        = 7   # Gap between label and its control
  PICKER_BOX_SLIDER_X             = PICKER_BOX_PREVIEW_X + PICKER_BOX_PREVIEW_WIDTH + 30
  PICKER_BOX_SLIDER_Y             = 3
  PICKER_BOX_SLIDER_WIDTH         = 64
  PICKER_BOX_SLIDER_HEIGHT        = 14
  PICKER_BOX_SLIDER_CONTROL_X     = PICKER_BOX_SLIDER_X + PICKER_BOX_SLIDER_WIDTH + 8
  PICKER_BOX_SLIDER_CONTROL_WIDTH = 48
  PICKER_BOX_HEX_BOX_WIDTH        = 72

  PICKER_BOX_WIDTH  = PICKER_BOX_SLIDER_CONTROL_X + PICKER_BOX_SLIDER_CONTROL_WIDTH + 5
  PICKER_BOX_HEIGHT = (PICKER_BOX_SLIDER_Y * 2) + (PICKER_BOX_ROW_HEIGHT * 5)

  # value is a 32-bit hex code for RGBA.
  def initialize(width, height, viewport, value)
    super(width, height, viewport)
    @color_bitmap = BitmapSprite.new(width, height, viewport)
    @color_bitmap.z = self.z + 1
    @value               = value
    @toggling_picker_box = false
  end

  def dispose
    remove_picker_box
    @color_bitmap.dispose
    @color_bitmap = nil
    super
  end

  #-----------------------------------------------------------------------------

  def x=(value)
    super
    @color_bitmap.x = self.x
  end

  def y=(value)
    super
    @color_bitmap.y = self.y
  end

  def visible=(value)
    super
    @color_bitmap.visible = self.visible
  end

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    if @picker_box_viewport
      mouse_coords = Mouse.getMousePos
      return true if mouse_coords && @picker_box_viewport.rect.contains?(*mouse_coords)
    end
    return super
  end

  def busy?
    return true if @picker_box || @toggling_picker_box
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @button_rect = Rect.new(0, (height - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  def make_picker_box
    return if @picker_box
    # Viewport
    view_x = self.x + @button_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @button_rect.y + @button_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_x + PICKER_BOX_WIDTH >= Graphics.width
      view_x = self.x + @button_rect.x + @button_rect.width - PICKER_BOX_WIDTH + self.viewport.rect.x - self.viewport.ox
    end
    if view_y + PICKER_BOX_HEIGHT >= Graphics.height
      view_y = self.y + @button_rect.y - PICKER_BOX_HEIGHT + self.viewport.rect.y - self.viewport.oy
    end
    @picker_box_viewport = Viewport.new(view_x, view_y, PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT)
    @picker_box_viewport.z = self.viewport.z + 100
    # Picker box's background (white box with outline)
    @picker_box_bg = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box_bg.z = -100
    draw_picker_box_background
    # Picker box's foreground (labels, color sliders)
    @picker_box = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box.bitmap.font.color = get_color_of(:text)
    @picker_box.bitmap.font.size = text_size
    # Controls
    make_picker_box_controls
    refresh_picker_box
  end

  def make_picker_box_controls
    @picker_controls = {}
    this_color = Color.new_from_rgb(@value)
    # NumberTextBoxes for each of R, G, B, A
    [:red, :green, :blue, :alpha].each_with_index do |id, i|
      # Slider
      ctrl = UIControls::ClickableArea.new(
        PICKER_BOX_SLIDER_WIDTH, PICKER_BOX_SLIDER_HEIGHT, @picker_box_viewport,
        false
      )
      ctrl.x = PICKER_BOX_SLIDER_X
      ctrl.y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2) + (i * PICKER_BOX_ROW_HEIGHT)
      ctrl.set_interactive_rects
      @picker_controls[(id.to_s + "_slider").to_sym] = ctrl
      # Number text box
      case id
      when :red   then col = this_color.red
      when :green then col = this_color.green
      when :blue  then col = this_color.blue
      when :alpha then col = this_color.alpha
      end
      ctrl = UIControls::FittedNumberTextBox.new(
        PICKER_BOX_SLIDER_CONTROL_WIDTH, PICKER_BOX_ROW_HEIGHT, @picker_box_viewport,
        0, 255, col
      )
      ctrl.x = PICKER_BOX_SLIDER_CONTROL_X
      ctrl.y = PICKER_BOX_SLIDER_Y + (i * PICKER_BOX_ROW_HEIGHT)
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @picker_controls[id] = ctrl
    end
    # TextBox for RGBA value
    ctrl = UIControls::FittedHexNumberTextBox.new(
      PICKER_BOX_HEX_BOX_WIDTH, PICKER_BOX_ROW_HEIGHT, @picker_box_viewport, @value[0, 6]
    )
    ctrl.x = PICKER_BOX_SLIDER_CONTROL_X + PICKER_BOX_SLIDER_CONTROL_WIDTH - PICKER_BOX_HEX_BOX_WIDTH
    ctrl.y = PICKER_BOX_SLIDER_Y + (4 * PICKER_BOX_ROW_HEIGHT)
    ctrl.color_scheme = @color_scheme
    ctrl.set_interactive_rects
    @picker_controls[:hex] = ctrl
    # Cancel button
    ctrl = UIControls::Button.new(PICKER_BOX_PREVIEW_WIDTH + 4, 20, @picker_box_viewport, _INTL("Cancel"))
    ctrl.x = PICKER_BOX_PREVIEW_X - 2
    ctrl.y = PICKER_BOX_SLIDER_Y + (4 * PICKER_BOX_ROW_HEIGHT) + ((PICKER_BOX_ROW_HEIGHT - ctrl.height) / 2)
    ctrl.color_scheme = @color_scheme
    ctrl.set_interactive_rects
    @picker_controls[:cancel] = ctrl
  end

  def remove_picker_box
    @picker_controls&.each_value { |ctrl| ctrl&.dispose }
    @picker_controls = nil
    @picker_box_bg&.dispose
    @picker_box_bg = nil
    @picker_box&.dispose
    @picker_box = nil
    @picker_box_viewport&.dispose
    @picker_box_viewport = nil
    @picker_captured = nil
    @picker_captured_id = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  # This is only called when the picker box is created, because it doesn't need
  # redrawing later.
  def draw_picker_box_background
    # White background with black outline
    @picker_box_bg.bitmap.fill_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                    get_color_of(:background))
    @picker_box_bg.bitmap.outline_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                       get_color_of(:line))
    # Checkerboard behind color preview
    checkerboard_colors = [get_color_of(:checkerboard_light), get_color_of(:checkerboard_dark)]
    PICKER_BOX_PREVIEW_WIDTH.times do |i|
      this_x = PICKER_BOX_PREVIEW_X + i
      PICKER_BOX_PREVIEW_HEIGHT.times do |j|
        this_y = PICKER_BOX_PREVIEW_Y + j
        this_color = checkerboard_colors[(((this_x + 1) / 4) + ((this_y + 1) / 4)) % 2]
        @picker_box_bg.bitmap.fill_rect(this_x, this_y, 1, 1, this_color)
      end
    end
    # Checkerboard behind alpha slider
    alpha_slider_y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2) + (3 * PICKER_BOX_ROW_HEIGHT)
    PICKER_BOX_SLIDER_WIDTH.times do |i|
      this_x = PICKER_BOX_SLIDER_X + i
      PICKER_BOX_SLIDER_HEIGHT.times do |j|
        this_y = alpha_slider_y + j
        this_color = checkerboard_colors[(((this_x + 1) / 4) + ((this_y + 1) / 4)) % 2]
        @picker_box_bg.bitmap.fill_rect(this_x, this_y, 1, 1, this_color)
      end
    end
  end

  def draw_picker_box
    return if !@picker_box
    @picker_box.bitmap.clear
    # Color preview
    this_color = Color.new_from_rgb(@value)
    @picker_box.bitmap.fill_rect(PICKER_BOX_PREVIEW_X, PICKER_BOX_PREVIEW_Y,
                                 PICKER_BOX_PREVIEW_WIDTH, PICKER_BOX_PREVIEW_HEIGHT, this_color)
    @picker_box.bitmap.outline_rect(PICKER_BOX_PREVIEW_X - 2, PICKER_BOX_PREVIEW_Y - 2,
                                    PICKER_BOX_PREVIEW_WIDTH + 4, PICKER_BOX_PREVIEW_HEIGHT + 4, get_color_of(:line))
    # Color slider labels
    label_y = PICKER_BOX_SLIDER_Y + TEXT_OFFSET_Y
    [_INTL("R:"), _INTL("G:"), _INTL("B:"), _INTL("A:")].each do |label|
      txt_x = PICKER_BOX_SLIDER_X - PICKER_BOX_LABEL_SPACING
      txt_x -= @picker_box.bitmap.text_size(label).width
      draw_text(@picker_box.bitmap, txt_x, label_y, label)
      label_y += PICKER_BOX_ROW_HEIGHT
    end
    hex_text = _INTL("Hex:")
    hex_x = PICKER_BOX_SLIDER_CONTROL_X + PICKER_BOX_SLIDER_CONTROL_WIDTH - PICKER_BOX_HEX_BOX_WIDTH - PICKER_BOX_LABEL_SPACING
    hex_x -= @picker_box.bitmap.text_size(hex_text).width
    draw_text(@picker_box.bitmap, hex_x, PICKER_BOX_SLIDER_Y + TEXT_OFFSET_Y + (4 * PICKER_BOX_ROW_HEIGHT), hex_text)
    # Color sliders
    slider_start_y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2)
    4.times do |j|
      this_color = Color.new_from_rgb(@value)
      this_val = [this_color.red, this_color.green, this_color.blue, this_color.alpha][j]
      this_color.alpha = 255   # Don't make the RGB sliders semi-transparent
      PICKER_BOX_SLIDER_WIDTH.times do |i|
        val = i * 255 / (PICKER_BOX_SLIDER_WIDTH - 1)
        this_color.red = val if j == 0
        this_color.green = val if j == 1
        this_color.blue = val if j == 2
        this_color.alpha = val if j == 3
        @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + i,
                                     slider_start_y + (j * PICKER_BOX_ROW_HEIGHT),
                                     1, PICKER_BOX_SLIDER_HEIGHT, this_color)
      end
      # Arrow
      arrow_x = this_val * (PICKER_BOX_SLIDER_WIDTH - 1) / 255
      arrow_height = 8
      5.times do |i|
        this_x = arrow_x - 2 + i
        this_y = [4, 2, 0, 2, 4][i]
        @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + this_x,
                                    slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT - (arrow_height / 2) + this_y,
                                    1, arrow_height - this_y, get_color_of(:negative_text))
      end
      @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + arrow_x,
                                   slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT - 1,
                                   1, 4, get_color_of(:line))
      @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + arrow_x - 1,
                                  slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT + 1,
                                  3, 2, get_color_of(:line))
    end
  end

  def refresh_picker_box
    return if !@picker_box
    draw_picker_box
    this_color = Color.new_from_rgb(@value)
    @picker_controls[:red].value   = this_color.red
    @picker_controls[:green].value = this_color.green
    @picker_controls[:blue].value  = this_color.blue
    @picker_controls[:alpha].value = this_color.alpha
    @picker_controls[:hex].value   = @value[0, 6]
    @picker_controls.each_value { |ctrl| ctrl.repaint }
  end

  def refresh
    refresh_picker_box
    return if @picker_box
    super
    if disabled?
      # Draw disabled color
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            get_color_of(:disabled_fill))
    else
      # Checkerboard behind color preview
      checkerboard_colors = [get_color_of(:checkerboard_light), get_color_of(:checkerboard_dark)]
      (@button_rect.width - 2).times do |i|
        this_x = @button_rect.x + 1 + i
        (@button_rect.height - 2).times do |j|
          this_y = @button_rect.y + 1 + j
          this_color = checkerboard_colors[(((this_x + 1) / 4) + ((this_y + 2) / 4)) % 2]
          self.bitmap.fill_rect(this_x, this_y, 1, 1, this_color)
        end
      end
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw value
    @color_bitmap.bitmap.clear
    @color_bitmap.bitmap.fill_rect(@button_rect.x + 1, @button_rect.y + 1,
                                   @button_rect.width - 2, @button_rect.height - 2,
                                   Color.new_from_rgb(@value))
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    if @picker_box
      mouse_coords = Mouse.getMousePos
      if mouse_coords && !@picker_box_viewport.rect.contains?(*mouse_coords)
        set_changed if @value != @old_value
        remove_picker_box
        @toggling_picker_box = true
      end
    else
      @captured_area = nil
      super
      if @captured_area == :button
        @old_value = @value.clone
        make_picker_box
        @toggling_picker_box = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@picker_box && !@toggling_picker_box
    refresh
    if @toggling_picker_box
      @toggling_picker_box = false
      return
    end
    super
  end

  def update_slider
    return if ![:red_slider, :green_slider, :blue_slider, :alpha_slider].include?(@picker_captured_id)
    slider_mouse_pos = @picker_captured.mouse_pos
    return if !slider_mouse_pos || !slider_mouse_pos[0]
    old_val = @picker_controls[@picker_captured_id].value
    slider_pos = slider_mouse_pos[0].clamp(0, @picker_captured.width)
    val = slider_pos * 256 / @picker_captured.width   # Makes each increment a nice multiple of 4
    val = val.clamp(0, 255)
    return if val == old_val
    case @picker_captured_id
    when :red_slider   then @picker_controls[:red].value = val
    when :green_slider then @picker_controls[:green].value = val
    when :blue_slider  then @picker_controls[:blue].value = val
    when :alpha_slider then @picker_controls[:alpha].value = val
    end
    @picker_captured.set_changed
  end

  def update
    # Update picker controls
    if @picker_captured
      @picker_captured.update
      if !@picker_captured.busy?
        @picker_captured = nil
        @picker_captured_id = nil
      end
      update_slider if @picker_captured_id
    elsif @picker_controls
      @picker_controls.each_pair do |id, ctrl|
        ctrl.update
        next if !ctrl.busy?
        @picker_captured = ctrl
        @picker_captured_id = id
      end
    end
    # Check for updated controls
    close_picker = false
    @picker_controls&.each_pair do |id, ctrl|
      next if !ctrl.changed?
      case id
      when :red, :green, :blue, :alpha, :red_slider, :green_slider, :blue_slider, :alpha_slider
        this_color = Color.new(
          @picker_controls[:red].value, @picker_controls[:green].value,
          @picker_controls[:blue].value, @picker_controls[:alpha].value
        )
        @value = this_color.to_rgb32(true)
        refresh
      when :hex
        this_color = Color.new_from_rgb(ctrl.value)
        this_color.alpha = @picker_controls[:alpha].value
        @value = this_color.to_rgb32(true)
        refresh
      when :cancel
        @value = @old_value
        close_picker = true
      end
      ctrl.clear_changed
    end
    if close_picker
      remove_picker_box
      @toggling_picker_box = true
      refresh
    end
    @picker_controls&.each_value { |ctrl| ctrl.repaint }
    super
  end
end

#===============================================================================
#
#===============================================================================
class UIControls::TonePicker < UIControls::BaseControl
  BUTTON_WIDTH  = 30
  BUTTON_HEIGHT = 20

  PICKER_BOX_PREVIEW_X            = 7   # For the colored part, not the preview's outline
  PICKER_BOX_PREVIEW_Y            = 7   # For the colored part, not the preview's outline
  PICKER_BOX_PREVIEW_WIDTH        = 48
  PICKER_BOX_PREVIEW_HEIGHT       = 88
  PICKER_BOX_ROW_HEIGHT           = 24
  PICKER_BOX_LABEL_SPACING        = 7   # Gap between label and its control
  PICKER_BOX_SLIDER_X             = PICKER_BOX_PREVIEW_X + PICKER_BOX_PREVIEW_WIDTH + 30
  PICKER_BOX_SLIDER_Y             = 3
  PICKER_BOX_SLIDER_WIDTH         = 64
  PICKER_BOX_SLIDER_HEIGHT        = 14
  PICKER_BOX_SLIDER_CONTROL_X     = PICKER_BOX_SLIDER_X + PICKER_BOX_SLIDER_WIDTH + 8
  PICKER_BOX_SLIDER_CONTROL_WIDTH = 54

  PICKER_BOX_WIDTH  = PICKER_BOX_SLIDER_CONTROL_X + PICKER_BOX_SLIDER_CONTROL_WIDTH + 5
  PICKER_BOX_HEIGHT = (PICKER_BOX_SLIDER_Y * 2) + (PICKER_BOX_ROW_HEIGHT * 5)

  # value is in the form "+RR+GG+BB+GG" where "+" could be "-".
  def initialize(width, height, viewport, value)
    super(width, height, viewport)
    @tone_bitmap = BitmapSprite.new(width, height, viewport)
    @tone_bitmap.z = self.z + 1
    @value               = value
    @toggling_picker_box = false
  end

  def dispose
    remove_picker_box
    @tone_bitmap.dispose
    @tone_bitmap = nil
    super
  end

  #-----------------------------------------------------------------------------

  def x=(value)
    super
    @tone_bitmap.x = self.x
  end

  def y=(value)
    super
    @tone_bitmap.y = self.y
  end

  def visible=(new_val)
    super
    @tone_bitmap.visible = new_val
  end

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    if @picker_box_viewport
      mouse_coords = Mouse.getMousePos
      return true if mouse_coords && @picker_box_viewport.rect.contains?(*mouse_coords)
    end
    return super
  end

  def busy?
    return true if @picker_box || @toggling_picker_box
    return super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @button_rect = Rect.new(0, (height - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  def make_picker_box
    return if @picker_box
    view_x = self.x + @button_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @button_rect.y + @button_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_x + PICKER_BOX_WIDTH >= Graphics.width
      view_x = self.x + @button_rect.x + @button_rect.width - PICKER_BOX_WIDTH + self.viewport.rect.x - self.viewport.ox
    end
    if view_y + PICKER_BOX_HEIGHT >= Graphics.height
      view_y = self.y + @button_rect.y - PICKER_BOX_HEIGHT + self.viewport.rect.y - self.viewport.oy
    end
    @picker_box_viewport = Viewport.new(view_x, view_y, PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT)
    @picker_box_viewport.z = self.viewport.z + 100
    # Picker box's background (white box with outline)
    @picker_box_bg = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box_bg.z = -100
    draw_picker_box_background
    # Picker box's foreground (labels, tone sliders)
    @picker_box = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box.bitmap.font.color = get_color_of(:text)
    @picker_box.bitmap.font.size = text_size
    # Picker box preview sprite
    @picker_box_preview = BitmapSprite.new(PICKER_BOX_PREVIEW_WIDTH, PICKER_BOX_PREVIEW_HEIGHT, @picker_box_viewport)
    @picker_box_preview.x = PICKER_BOX_PREVIEW_X
    @picker_box_preview.y = PICKER_BOX_PREVIEW_Y
    @picker_box_preview.z = 1
    draw_picker_preview
    # Controls
    make_picker_box_controls
    refresh_picker_box
  end

  def make_picker_box_controls
    @picker_controls = {}
    this_tone = Tone.new_from_rgbg(@value)
    # NumberTextBoxes for each of R, G, B, G
    [:red, :green, :blue, :gray].each_with_index do |id, i|
      # Slider
      ctrl = UIControls::ClickableArea.new(
        PICKER_BOX_SLIDER_WIDTH, PICKER_BOX_SLIDER_HEIGHT, @picker_box_viewport,
        false
      )
      ctrl.x = PICKER_BOX_SLIDER_X
      ctrl.y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2) + (i * PICKER_BOX_ROW_HEIGHT)
      ctrl.set_interactive_rects
      @picker_controls[(id.to_s + "_slider").to_sym] = ctrl
      # Number text box
      case id
      when :red   then ton = this_tone.red
      when :green then ton = this_tone.green
      when :blue  then ton = this_tone.blue
      when :gray  then ton = this_tone.gray
      end
      ctrl = UIControls::FittedNumberTextBox.new(
        PICKER_BOX_SLIDER_CONTROL_WIDTH, PICKER_BOX_ROW_HEIGHT, @picker_box_viewport,
        (id == :gray) ? 0 : -255, 255, ton
      )
      ctrl.x = PICKER_BOX_SLIDER_CONTROL_X
      ctrl.y = PICKER_BOX_SLIDER_Y + (i * PICKER_BOX_ROW_HEIGHT)
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @picker_controls[id] = ctrl
    end
    # Cancel button
    ctrl = UIControls::Button.new(PICKER_BOX_PREVIEW_WIDTH + 4, 20, @picker_box_viewport, _INTL("Cancel"))
    ctrl.x = PICKER_BOX_PREVIEW_X - 2
    ctrl.y = PICKER_BOX_SLIDER_Y + (4 * PICKER_BOX_ROW_HEIGHT) + ((PICKER_BOX_ROW_HEIGHT - ctrl.height) / 2)
    ctrl.color_scheme = @color_scheme
    ctrl.set_interactive_rects
    @picker_controls[:cancel] = ctrl
  end

  def remove_picker_box
    @picker_controls&.each_value { |ctrl| ctrl&.dispose }
    @picker_controls = nil
    @picker_box_bg&.dispose
    @picker_box_bg = nil
    @picker_box&.dispose
    @picker_box = nil
    @picker_box_preview&.dispose
    @picker_box_preview = nil
    @picker_box_viewport&.dispose
    @picker_box_viewport = nil
    @picker_captured = nil
    @picker_captured_id = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  # This is only called when the picker box is created, because it doesn't need
  # redrawing later.
  def draw_picker_box_background
    # White background with black outline
    @picker_box_bg.bitmap.fill_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                    get_color_of(:background))
    @picker_box_bg.bitmap.outline_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height, get_color_of(:line))
    # Tone sliders
    slider_start_y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2)
    4.times do |j|
      this_color = Color.black
      PICKER_BOX_SLIDER_WIDTH.times do |i|
        if i < PICKER_BOX_SLIDER_WIDTH / 2
          val = lerp(0, 255, PICKER_BOX_SLIDER_WIDTH / 2, i)
          other_val = 0
        else
          val = 255
          other_val = lerp(0, 255, PICKER_BOX_SLIDER_WIDTH / 2, PICKER_BOX_SLIDER_WIDTH / 2, i)
        end
        if j == 3
          val = lerp(0, 255, PICKER_BOX_SLIDER_WIDTH, i)
          this_color.red = val
          this_color.green = val
          this_color.blue = val
        else
          this_color.red = (j == 0) ? val : other_val
          this_color.green = (j == 1) ? val : other_val
          this_color.blue = (j == 2) ? val : other_val
        end
        @picker_box_bg.bitmap.fill_rect(PICKER_BOX_SLIDER_X + i,
                                        slider_start_y + (j * PICKER_BOX_ROW_HEIGHT),
                                        1, PICKER_BOX_SLIDER_HEIGHT, this_color)
      end
    end
  end

  def draw_picker_box
    return if !@picker_box
    @picker_box.bitmap.clear
    # Tone preview outline
    @picker_box.bitmap.outline_rect(PICKER_BOX_PREVIEW_X - 2, PICKER_BOX_PREVIEW_Y - 2,
                                    PICKER_BOX_PREVIEW_WIDTH + 4, PICKER_BOX_PREVIEW_HEIGHT + 4, get_color_of(:line))
    # Tone slider labels
    label_y = PICKER_BOX_SLIDER_Y + TEXT_OFFSET_Y
    [_INTL("R:"), _INTL("G:"), _INTL("B:"), _INTL("G:")].each do |label|
      txt_x = PICKER_BOX_SLIDER_X - PICKER_BOX_LABEL_SPACING
      txt_x -= @picker_box.bitmap.text_size(label).width
      draw_text(@picker_box.bitmap, txt_x, label_y, label)
      label_y += PICKER_BOX_ROW_HEIGHT
    end
    # Tone arrows
    slider_start_y = PICKER_BOX_SLIDER_Y + ((PICKER_BOX_ROW_HEIGHT - PICKER_BOX_SLIDER_HEIGHT) / 2)
    4.times do |j|
      this_tone = Tone.new_from_rgbg(@value)
      this_val = [this_tone.red, this_tone.green, this_tone.blue, this_tone.gray][j]
      if j == 3   # 0..255
        arrow_x = this_val * (PICKER_BOX_SLIDER_WIDTH - 1) / 255
      else   # -255..255
        arrow_x = (PICKER_BOX_SLIDER_WIDTH / 2) + (this_val * (PICKER_BOX_SLIDER_WIDTH - 1) / (255 * 2))
      end
      arrow_height = 8
      5.times do |i|
        this_x = arrow_x - 2 + i
        this_y = [4, 2, 0, 2, 4][i]
        @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + this_x,
                                    slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT - (arrow_height / 2) + this_y,
                                    1, arrow_height - this_y, get_color_of(:negative_text))
      end
      @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + arrow_x,
                                   slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT - 1,
                                   1, 4, get_color_of(:line))
      @picker_box.bitmap.fill_rect(PICKER_BOX_SLIDER_X + arrow_x - 1,
                                  slider_start_y + (j * PICKER_BOX_ROW_HEIGHT) + PICKER_BOX_SLIDER_HEIGHT + 1,
                                  3, 2, get_color_of(:line))
    end
  end

  def draw_picker_preview
    this_color = Color.black
    PICKER_BOX_PREVIEW_HEIGHT.times do |j|
      cols = {
        :red => 0,
        :green => 0,
        :blue => 0
      }
      3.times do |col|
        col_j = (j - (col * PICKER_BOX_PREVIEW_HEIGHT / 3)) % PICKER_BOX_PREVIEW_HEIGHT
        if col_j < PICKER_BOX_PREVIEW_HEIGHT / 2
          val = lerp(255 * 2, -255, PICKER_BOX_PREVIEW_HEIGHT / 2, col_j).clamp(0, 255)
        else
          val = lerp(-255, 255 * 2, PICKER_BOX_PREVIEW_HEIGHT / 2, PICKER_BOX_PREVIEW_HEIGHT / 2, col_j).clamp(0, 255)
        end
        cols[:red] = val if col == 0
        cols[:green] = val if col == 1
        cols[:blue] = val if col == 2
      end
      PICKER_BOX_PREVIEW_WIDTH.times do |i|
        if i < PICKER_BOX_PREVIEW_WIDTH / 2
          this_color.red = lerp(0, cols[:red], PICKER_BOX_PREVIEW_WIDTH / 2, i)
          this_color.green = lerp(0, cols[:green], PICKER_BOX_PREVIEW_WIDTH / 2, i)
          this_color.blue = lerp(0, cols[:blue], PICKER_BOX_PREVIEW_WIDTH / 2, i)
        else
          this_color.red = lerp(cols[:red], 255, PICKER_BOX_PREVIEW_WIDTH / 2, PICKER_BOX_PREVIEW_WIDTH / 2, i)
          this_color.green = lerp(cols[:green], 255, PICKER_BOX_PREVIEW_WIDTH / 2, PICKER_BOX_PREVIEW_WIDTH / 2, i)
          this_color.blue = lerp(cols[:blue], 255, PICKER_BOX_PREVIEW_WIDTH / 2, PICKER_BOX_PREVIEW_WIDTH / 2, i)
        end
        @picker_box_preview.bitmap.fill_rect(i, j, 1, 1, this_color)
      end
    end
  end

  def refresh_picker_box
    return if !@picker_box
    draw_picker_box
    this_tone = Tone.new_from_rgbg(@value)
    @picker_box_preview.tone = this_tone
    @picker_controls[:red].value   = this_tone.red
    @picker_controls[:green].value = this_tone.green
    @picker_controls[:blue].value  = this_tone.blue
    @picker_controls[:gray].value = this_tone.gray
    @picker_controls.each_value { |ctrl| ctrl.repaint }
  end

  def refresh
    refresh_picker_box
    return if @picker_box
    super
    # Draw disabled color
    if disabled?
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            get_color_of(:disabled_fill))
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw value
    @tone_bitmap.bitmap.clear
    col_r = (@value[0, 3].to_i(16) + 255) / 2
    col_g = (@value[3, 3].to_i(16) + 255) / 2
    col_b = (@value[6, 3].to_i(16) + 255) / 2
    @tone_bitmap.bitmap.fill_rect(@button_rect.x + 1, @button_rect.y + 1,
                                  @button_rect.width - 2, @button_rect.height - 2,
                                  Color.new(col_r, col_g, col_b))
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    if @picker_box
      mouse_coords = Mouse.getMousePos
      if mouse_coords && !@picker_box_viewport.rect.contains?(*mouse_coords)
        set_changed if @value != @old_value
        remove_picker_box
        @toggling_picker_box = true
      end
    else
      @captured_area = nil
      super
      if @captured_area == :button
        @old_value = @value.clone
        make_picker_box
        @toggling_picker_box = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@picker_box && !@toggling_picker_box
    refresh
    if @toggling_picker_box
      @toggling_picker_box = false
      return
    end
    super
  end

  def update_slider
    return if ![:red_slider, :green_slider, :blue_slider, :gray_slider].include?(@picker_captured_id)
    slider_mouse_pos = @picker_captured.mouse_pos
    return if !slider_mouse_pos || !slider_mouse_pos[0]
    old_val = @picker_controls[@picker_captured_id].value
    slider_pos = slider_mouse_pos[0].clamp(0, @picker_captured.width)
    if @picker_captured_id == :gray_slider   # 0..255
      val = slider_pos * 256 / @picker_captured.width   # Makes each increment a nice multiple of 4
      val = val.clamp(0, 255)
    else   # -255..255
      val = slider_pos * 256 * 2 / @picker_captured.width   # Makes each increment a nice multiple of 8
      val -= 256
      val = val.clamp(-255, 255)
    end
    return if val == old_val
    case @picker_captured_id
    when :red_slider   then @picker_controls[:red].value = val
    when :green_slider then @picker_controls[:green].value = val
    when :blue_slider  then @picker_controls[:blue].value = val
    when :gray_slider  then @picker_controls[:gray].value = val
    end
    @picker_captured.set_changed
  end

  def update
    # Update picker controls
    if @picker_captured
      @picker_captured.update
      if !@picker_captured.busy?
        @picker_captured = nil
        @picker_captured_id = nil
      end
      update_slider if @picker_captured_id
    elsif @picker_controls
      @picker_controls.each_pair do |id, ctrl|
        ctrl.update
        next if !ctrl.busy?
        @picker_captured = ctrl
        @picker_captured_id = id
      end
    end
    # Check for updated controls
    close_picker = false
    @picker_controls&.each_pair do |id, ctrl|
      next if !ctrl.changed?
      case id
      when :red, :green, :blue, :gray, :red_slider, :green_slider, :blue_slider, :gray_slider
        this_tone = Tone.new(
          @picker_controls[:red].value, @picker_controls[:green].value,
          @picker_controls[:blue].value, @picker_controls[:gray].value
        )
        @value = this_tone.to_rgb32
        refresh
      when :cancel
        @value = @old_value
        close_picker = true
      end
      ctrl.clear_changed
    end
    if close_picker
      remove_picker_box
      @toggling_picker_box = true
      refresh
    end
    @picker_controls&.each_value { |ctrl| ctrl.repaint }
    super
  end
end

#===============================================================================
#
#===============================================================================
class UIControls::SEPicker < UIControls::BaseControl
  BUTTON_WIDTH  = 20
  BUTTON_HEIGHT = 20

  PICKER_BOX_SPACING       = 4
  PICKER_BOX_BUTTON_WIDTH  = 64
  PICKER_BOX_BUTTON_HEIGHT = 20
  PICKER_BOX_LIST_X        = PICKER_BOX_SPACING + 1
  PICKER_BOX_LIST_Y        = PICKER_BOX_SPACING + 1
  PICKER_BOX_LIST_WIDTH    = (3 * PICKER_BOX_BUTTON_WIDTH) + (2 * PICKER_BOX_SPACING)   # 200
  PICKER_BOX_LIST_HEIGHT   = 88
  PICKER_BOX_LIST_ROW_HEIGHT = 20

  PICKER_BOX_WIDTH  = (2 * PICKER_BOX_LIST_X) + PICKER_BOX_LIST_WIDTH   # 210
  PICKER_BOX_HEIGHT = (2 * PICKER_BOX_LIST_Y) + PICKER_BOX_LIST_HEIGHT + PICKER_BOX_SPACING + PICKER_BOX_BUTTON_HEIGHT   # 126

  # NOTE: @options are the contents of the list. @value is temporary and used
  #       only when a button is pressed (it contains the ID of that button and
  #       the list's index at that time).
  def initialize(width, height, viewport, options)
    super(width, height, viewport)
    @options             = options
    @toggling_picker_box = false
  end

  def dispose
    remove_picker_box
    super
  end

  #-----------------------------------------------------------------------------

  def value=(new_options)
    return if @options == new_options
    @options = new_options
    invalidate
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    if @picker_box_viewport
      mouse_coords = Mouse.getMousePos
      return true if mouse_coords && @picker_box_viewport.rect.contains?(*mouse_coords)
    end
    return super
  end

  def busy?
    return true if @picker_box_bg || @toggling_picker_box
    return super
  end

  def clear_changed
    @value = nil
    super
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @button_rect = Rect.new(0, (height - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT)
    @interactions = {
      :button => @button_rect
    }
  end

  def make_picker_box
    return if @picker_box_bg
    # Viewport
    view_x = self.x + @button_rect.x + self.viewport.rect.x - self.viewport.ox
    view_y = self.y + @button_rect.y + @button_rect.height + self.viewport.rect.y - self.viewport.oy
    if view_x + PICKER_BOX_WIDTH >= Graphics.width
      view_x = self.x + @button_rect.x + @button_rect.width - PICKER_BOX_WIDTH + self.viewport.rect.x - self.viewport.ox
    end
    if view_y + PICKER_BOX_HEIGHT >= Graphics.height
      view_y = self.y + @button_rect.y - PICKER_BOX_HEIGHT + self.viewport.rect.y - self.viewport.oy
    end
    @picker_box_viewport = Viewport.new(view_x, view_y, PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT)
    @picker_box_viewport.z = self.viewport.z + 100
    # Picker box's background (white box with outline)
    @picker_box_bg = BitmapSprite.new(PICKER_BOX_WIDTH, PICKER_BOX_HEIGHT, @picker_box_viewport)
    @picker_box_bg.z = -100
    @picker_box_bg.bitmap.fill_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                    get_color_of(:background))
    @picker_box_bg.bitmap.outline_rect(0, 0, @picker_box_bg.width, @picker_box_bg.height,
                                       get_color_of(:line))
    # Controls
    make_picker_box_controls
    refresh_picker_box
  end

  def make_picker_box_controls
    @picker_controls = {}
    # List box
    ctrl = UIControls::List.new(PICKER_BOX_LIST_WIDTH, PICKER_BOX_LIST_HEIGHT, @picker_box_viewport, [], PICKER_BOX_LIST_ROW_HEIGHT)
    ctrl.x = PICKER_BOX_LIST_X
    ctrl.y = PICKER_BOX_LIST_Y
    ctrl.set_interactive_rects
    ctrl.color_scheme = @color_scheme
    @picker_controls[:list] = ctrl
    # Buttons
    button_x = PICKER_BOX_LIST_X
    [[:add, _INTL("Add")],
     [:edit, _INTL("Edit")],
     [:delete, _INTL("Delete")]].each do |ct|
      ctrl = UIControls::Button.new(PICKER_BOX_BUTTON_WIDTH, PICKER_BOX_BUTTON_HEIGHT, @picker_box_viewport, ct[1])
      ctrl.x = button_x
      ctrl.y = PICKER_BOX_LIST_Y + PICKER_BOX_LIST_HEIGHT + PICKER_BOX_SPACING
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @picker_controls[ct[0]] = ctrl
      button_x += PICKER_BOX_BUTTON_WIDTH + PICKER_BOX_SPACING
    end
  end

  def remove_picker_box
    @picker_controls&.each_value { |ctrl| ctrl&.dispose }
    @picker_controls = nil
    @picker_box_bg&.dispose
    @picker_box_bg = nil
    @picker_box_viewport&.dispose
    @picker_box_viewport = nil
    @picker_captured = nil
    @captured_area = nil
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if @captured_area == :button
    super
  end

  def refresh_picker_box
    return if !@picker_box_bg
    @picker_controls[:list].options = @options
    if @picker_controls[:list].value
      @picker_controls[:edit].enable
      @picker_controls[:delete].enable
    else
      @picker_controls[:edit].disable
      @picker_controls[:delete].disable
    end
    @picker_controls.each_value { |ctrl| ctrl.repaint }
  end

  def refresh
    refresh_picker_box
    return if @picker_box_bg
    super
    # Draw disabled color
    if disabled?
      self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                            @button_rect.width, @button_rect.height,
                            get_color_of(:disabled_fill))
    end
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw button graphic
    btmp_graphic = %w(
      . . . . . . . . . . . . . . . .
      . . . . . . . . . . . . X . . .
      . . . . . . X . . . . . . X . .
      . . . . . X X . . . X . . . X .
      . . . . X . X . . . . X . . X .
      X X X X . . X . X . . X . . . X
      X . . . . . X . . X . . X . . X
      X . . . . . X . . X . . X . . X
    )
    icon_color = get_color_of(:text)
    btmp_width = BUTTON_WIDTH - 4
    btmp_graphic.length.times do |i|
      next if btmp_graphic[i] == "."
      pixel_x = i % btmp_width
      pixel_y = i / btmp_width
      self.bitmap.fill_rect(@button_rect.x + 2 + pixel_x, @button_rect.y + 2 + pixel_y, 1, 1, icon_color)
      self.bitmap.fill_rect(@button_rect.x + 2 + pixel_x, @button_rect.y + @button_rect.height - 3 - pixel_y, 1, 1, icon_color)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    if @picker_box_bg
      mouse_coords = Mouse.getMousePos
      if mouse_coords && !@picker_box_viewport.rect.contains?(*mouse_coords)
        remove_picker_box
        @toggling_picker_box = true
      end
    else
      @captured_area = nil
      super
      if @captured_area == :button
        make_picker_box
        @toggling_picker_box = true
      end
    end
  end

  def on_mouse_release
    return if !@captured_area && !@picker_box_bg && !@toggling_picker_box
    refresh
    if @toggling_picker_box
      @toggling_picker_box = false
      return
    end
    super
  end

  def update
    # Update picker controls
    if @picker_captured
      @picker_captured.update
      @picker_captured = nil if !@picker_captured.busy?
    elsif @picker_controls
      @picker_controls.each_pair do |id, ctrl|
        ctrl.update
        next if !ctrl.busy?
        @picker_captured = ctrl
      end
    end
    # Check for updated controls
    @picker_controls&.each_pair do |id, ctrl|
      next if !ctrl.changed?
      if id == :list
        refresh
      else
        if id == :add || @picker_controls[:list].value
          @value = [id, @picker_controls[:list].value]
          set_changed
        end
      end
      ctrl.clear_changed
    end
    @picker_controls&.each_value { |ctrl| ctrl.repaint }
    super
  end
end
