#===============================================================================
# NOTE: Strictly speaking, this is a toggle switch and not a checkbox.
#===============================================================================
class UIControls::Checkbox < UIControls::BaseControl
  CHECKBOX_X         = 0
  CHECKBOX_WIDTH     = 35   # Actual width of the drawn checkbox
  CHECKBOX_HEIGHT    = 20   # Actual height of the drawn checkbox
  CHECKBOX_FILL_SIZE = CHECKBOX_HEIGHT - 4

  # width does nothing.
  # height is the height of the line this control is being drawn in.
  def initialize(width, height, viewport, value = false)
    super(width, height, viewport)
    @value = value
  end

  #-----------------------------------------------------------------------------

  def value=(new_value)
    return if @value == new_value
    @value = new_value
    invalidate
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @checkbox_rect = Rect.new(CHECKBOX_X, (height - CHECKBOX_HEIGHT) / 2,
                              CHECKBOX_WIDTH, CHECKBOX_HEIGHT)
    @interactions = {
      :checkbox => @checkbox_rect
    }
  end

  #-----------------------------------------------------------------------------

  def draw_background
    bg_color = (disabled?) ? :disabled_fill : :control_background
    self.bitmap.fill_rect(@checkbox_rect.x, @checkbox_rect.y,
                          @checkbox_rect.width, @checkbox_rect.height,
                          get_color_of(bg_color))
  end

  def refresh
    super
    # Draw checkbox outline
    self.bitmap.outline_rect(@checkbox_rect.x, @checkbox_rect.y,
                             @checkbox_rect.width, @checkbox_rect.height,
                             get_color_of(:line))
    # Draw checkbox fill
    box_x = (@value) ? @checkbox_rect.width - CHECKBOX_FILL_SIZE - 2 : 2
    if disabled?
      box_color = get_color_of(:disabled_text)
    else
      box_color = (@value) ? get_color_of(:checked) : get_color_of(:unchecked)
    end
    self.bitmap.fill_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                          CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, box_color)
    self.bitmap.outline_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                             CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, get_color_of(:line))
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :checkbox
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y && @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @value = !@value   # The actual change of this control's value
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end
