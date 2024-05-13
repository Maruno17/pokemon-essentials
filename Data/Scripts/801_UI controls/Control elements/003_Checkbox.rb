#===============================================================================
# NOTE: Strictly speaking, this is a toggle switch and not a checkbox.
#===============================================================================
class UIControls::Checkbox < UIControls::BaseControl
  CHECKBOX_X         = 2
  CHECKBOX_WIDTH     = 40
  CHECKBOX_HEIGHT    = 24
  CHECKBOX_FILL_SIZE = CHECKBOX_HEIGHT - 4

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

  def checked_color
    return get_color_scheme_color_for_element(:checked_color, Color.new(48, 192, 48))
  end

  def unchecked_color
    return get_color_scheme_color_for_element(:unchecked_color, Color.gray)
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

  def refresh
    super
    # Draw disabled colour
    if disabled?
      self.bitmap.fill_rect(@checkbox_rect.x, @checkbox_rect.y,
                            @checkbox_rect.width, @checkbox_rect.height,
                            disabled_fill_color)
    end
    # Draw checkbox outline
    self.bitmap.outline_rect(@checkbox_rect.x, @checkbox_rect.y,
                             @checkbox_rect.width, @checkbox_rect.height,
                             line_color)
    # Draw checkbox fill
    box_x = (@value) ? @checkbox_rect.width - CHECKBOX_FILL_SIZE - 2 : 2
    if disabled?
      box_color = disabled_text_color
    else
      box_color = (@value) ? checked_color : unchecked_color
    end
    self.bitmap.fill_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                          CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, box_color)
    self.bitmap.outline_rect(@checkbox_rect.x + box_x, @checkbox_rect.y + 2,
                             CHECKBOX_FILL_SIZE, CHECKBOX_FILL_SIZE, line_color)
  end

  #-----------------------------------------------------------------------------

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    if @captured_area == :checkbox
      mouse_x, mouse_y = mouse_pos
      if mouse_x && mouse_y &&  @interactions[@captured_area].contains?(mouse_x, mouse_y)
        @value = !@value   # The actual change of this control's value
        set_changed
      end
    end
    super   # Make this control not busy again
  end
end
