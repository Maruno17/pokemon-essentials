#===============================================================================
#
#===============================================================================
class UIControls::Label < UIControls::BaseControl
  attr_reader :text

  LEFT_PADDING = 4   # Blank space to left of text

  def initialize(width, height, viewport, text)
    super(width, height, viewport)
    @text = text
    @underlined = false
    @header = false
    @disabled = true   # No interactivity
  end

  #-----------------------------------------------------------------------------

  def text=(value)
    @text = value
    refresh
  end

  def underlined=(val)
    @underlined = val
    refresh
  end

  def header=(val)
    @header = val
    refresh
  end

  def text_width
    return self.bitmap.text_size(@text).width
  end

  #-----------------------------------------------------------------------------

  def refresh
    super
    if @header
      draw_text_centered(self.bitmap, 0, TEXT_OFFSET_Y, width, @text)
      # Draw underline
      text_size = self.bitmap.text_size(@text)
      self.bitmap.fill_rect((width - text_size.width) / 2, TEXT_OFFSET_Y + text_size.height,
                            text_size.width, 1, get_color_of(:text))
    else
      draw_text(self.bitmap, LEFT_PADDING, TEXT_OFFSET_Y, @text)
      if @underlined
        text_size = self.bitmap.text_size(@text)
        self.bitmap.fill_rect(LEFT_PADDING, TEXT_OFFSET_Y + text_size.height,
                              text_size.width, 1, get_color_of(:text))
      end
    end
  end
end
