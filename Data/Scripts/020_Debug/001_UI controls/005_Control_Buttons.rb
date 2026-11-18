#===============================================================================
# A simple control that designates a rectangular area and detects when it has
# been clicked in. The highlight parameter determines whether the area
# highlights when hovered over or clicked on.
#===============================================================================
class UIControls::ClickableArea < UIControls::BaseControl
  attr_accessor :changed_upon_click

  def initialize(width, height, viewport, highlight = true, can_right_click = false)
    super(width, height, viewport)
    @highlight = highlight
    @can_right_click = can_right_click
    @changed_upon_click = false
  end

  #-----------------------------------------------------------------------------

  def left_clicked?
    return @input == Input::MOUSELEFT
  end

  def right_clicked?
    return @input == Input::MOUSERIGHT
  end

  def make_not_busy
    @input = nil
    @captured_area = nil
  end

  def set_interactive_rects
    @area_rect = Rect.new(0, 0, width, height)
    @interactions = {
      :area => @area_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if !@highlight
    super
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    was_captured = busy?
    super
    if !was_captured && busy? && @changed_upon_click
      set_changed
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :area && !@changed_upon_click
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        set_changed
      end
    end
    super   # Make this control not busy again
  end

  def on_mouse_right_press
    on_mouse_press
  end

  def on_mouse_right_release
    on_mouse_release
  end

  # Updates the logic on the control, invalidating it if necessary.
  def update
    return if !self.visible
    return if disabled? && !busy?   # This control still works if it becomes disabled while using it
    update_hover_highlight
    # Detect a mouse press/release
    if @interactions && !@interactions.empty?
      if Input.trigger?(Input::MOUSELEFT)
        @input = Input::MOUSELEFT
        on_mouse_press
      elsif busy? && Input.release?(Input::MOUSELEFT)
        on_mouse_release
        @input = nil
      elsif Input.trigger?(Input::MOUSERIGHT) && @can_right_click
        @input = Input::MOUSERIGHT
        on_mouse_right_press
      elsif busy? && Input.release?(Input::MOUSERIGHT) && @can_right_click
        on_mouse_right_release
        @input = nil
      end
    end
  end
end

#===============================================================================
# An area that can be clicked on. It uses a bitmap as a graphic, and has a
# number of states equal to the number of bitmaps given to it. Its state (value)
# cycles through each of them in order. Assumes all bitmaps are the same size.
# Whether the bitmap highlights itself when hovered over/clicked on can be set
# by the "highlight" variable.
#===============================================================================
class UIControls::ClickableBitmap < UIControls::BaseControl
  attr_accessor :highlight

  def initialize(viewport, *bitmaps)
    @bitmaps = bitmaps
    @highlight = true
    @value = 0
    super(@bitmaps.first.width, @bitmaps.first.height, viewport)
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @area_rect = Rect.new(0, 0, width, height)
    @interactions = {
      :area => @area_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_area_highlight
    return if !@highlight
    super
  end

  def refresh
    super
    # Draw bitmap
    this_bitmap = @bitmaps[@value % @bitmaps.length]
    if this_bitmap
      self.bitmap.blt(0, 0, this_bitmap,
                      Rect.new(0, 0, this_bitmap.width, this_bitmap.height))
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :area && @bitmaps.length > 1
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @value = (@value + 1) % @bitmaps.length   # The actual change of this control's value
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end

#===============================================================================
# Supports multi-line text, just separate lines with "\n".
#===============================================================================
class UIControls::Button < UIControls::BaseControl
  BUTTON_FRAME_THICKNESS = 4
  BUTTON_X               = 0
  BUTTON_Y               = 0
  TEXT_BASE_OFFSET_Y     = 8   # Text is centred vertically in the button
  TEXT_LINE_SPACING      = 18

  def initialize(width, height, viewport, text = "")
    super(width, height, viewport)
    @text = text
    @highlight = false
  end

  #-----------------------------------------------------------------------------

  def real_width
    return @button_rect&.width || self.width
  end

  def set_text(val)
    return if @text == val
    @text = val
    invalidate
  end

  #-----------------------------------------------------------------------------

  def disabled?
    return highlighted? || super
  end

  def set_changed
    @value = true
    super
  end

  def clear_changed
    @value = false
    super
  end

  def highlighted?
    return @highlight
  end

  def set_highlight(value)
    (value) ? set_highlighted : set_not_highlighted
  end

  def set_highlighted
    return if highlighted?
    @highlight = true
    invalidate
  end

  def set_not_highlighted
    return if !highlighted?
    @highlight = false
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    button_width = width - (BUTTON_X * 2)
    button_height = height - (2 * BUTTON_Y)
    button_height = [button_height, height - (2 * BUTTON_Y)].min
    @button_rect = Rect.new(BUTTON_X, (height - button_height) / 2, button_width, button_height)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_background
    bg_color = (disabled?) ? :disabled_fill : :control_background
    bg_color = :highlight if highlighted?
    self.bitmap.fill_rect(@button_rect.x, @button_rect.y,
                          @button_rect.width, @button_rect.height,
                          get_color_of(bg_color))
  end

  def draw_area_highlight
    super if !highlighted?
  end

  def refresh
    super
    # Draw button outline
    self.bitmap.outline_rect(@button_rect.x, @button_rect.y,
                             @button_rect.width, @button_rect.height,
                             get_color_of(:line))
    # Draw inner grey ring that shows this is a button rather than a text box
    if !disabled?
      shade = get_color_of(:line).clone
      shade.alpha = (shade.red > 128) ? 160 : 64   # Dark : light
      self.bitmap.outline_rect(@button_rect.x + 2, @button_rect.y + 2,
                               @button_rect.width - 4, @button_rect.height - 4,
                               shade, 1)
    end
    # Draw button text
    lines = @text.split("\n")
    lines.each_with_index do |line, i|
      text_y = @button_rect.y + (@button_rect.height / 2) - TEXT_BASE_OFFSET_Y
      text_y -= ((lines.length - 1) * TEXT_LINE_SPACING / 2)
      text_y += TEXT_LINE_SPACING * i
      draw_text_centered(self.bitmap, @button_rect.x, text_y, @button_rect.width, line)
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :button
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end

#===============================================================================
# A text button, but its width changes to fit the text on it. The height is a
# constant.
#===============================================================================
class UIControls::FittedButton < UIControls::Button
  BUTTON_PADDING = 10
  BUTTON_HEIGHT  = 28

  def set_text(val)
    super(val)
    set_interactive_rects
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    button_width = self.bitmap.text_size(@text).width + (BUTTON_PADDING * 2)
    button_height = BUTTON_HEIGHT
    button_height = [button_height, height - (2 * BUTTON_Y)].min
    @button_rect = Rect.new(BUTTON_X, (height - button_height) / 2, button_width, button_height)
    @interactions = {
      :button => @button_rect
    }
  end
end

#===============================================================================
#
#===============================================================================
class UIControls::BitmapButton < UIControls::Button
  def initialize(viewport, button_bitmap, disabled_bitmap = nil)
    super(button_bitmap.width + (BUTTON_FRAME_THICKNESS * 2),
          button_bitmap.height + (BUTTON_FRAME_THICKNESS * 2), viewport)
    @button_bitmap = button_bitmap
    @disabled_bitmap = disabled_bitmap
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions&.clear
    @button_rect = Rect.new(0, 0, width, height)
    @interactions = {
      :button => @button_rect
    }
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    # Draw button bitmap
    if @disabled_bitmap && disabled?
      self.bitmap.blt(BUTTON_FRAME_THICKNESS, BUTTON_FRAME_THICKNESS, @disabled_bitmap,
                      Rect.new(0, 0, @disabled_bitmap.width, @disabled_bitmap.height))
    else
      self.bitmap.blt(BUTTON_FRAME_THICKNESS, BUTTON_FRAME_THICKNESS, @button_bitmap,
                      Rect.new(0, 0, @button_bitmap.width, @button_bitmap.height))
    end
  end
end
