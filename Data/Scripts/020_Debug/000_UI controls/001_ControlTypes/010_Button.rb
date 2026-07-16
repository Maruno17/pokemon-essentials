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
