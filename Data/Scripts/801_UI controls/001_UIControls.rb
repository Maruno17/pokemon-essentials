#===============================================================================
# Container module for control classes.
#===============================================================================
module UIControls; end

#===============================================================================
#
#===============================================================================
module UIControls::StyleMixin
  COLOR_SCHEMES = {
    :dark => {
      :background_color          => Color.new(32, 32, 32),
      :text_color                => Color.white,
      :disabled_text_color       => Color.new(96, 96, 96),
      :line_color                => Color.white,
      :disabled_fill_color       => Color.new(128, 128, 128),
      :hover_color               => Color.new(64, 80, 80),
      :capture_color             => Color.new(224, 32, 96),
      :highlight_color           => Color.new(160, 128, 16),
      # Sidebars
#      :delete_icon_color         => Color.new(248, 96, 96),   # Unchanged
      # Checkbox
      :checked_color             => Color.new(32, 160, 32),
      :unchecked_color           => Color.new(160, 160, 160),
      # ParticleList
#      :position_line_color       => Color.new(248, 96, 96),   # Unchanged
      :after_end_bg_color        => Color.new(80, 80, 80),
      :se_background_color       => Color.new(160, 160, 160),
      :property_background_color => Color.new(96, 96, 96),
      # ParticleList and Canvas
      :focus_colors              => {
        :foreground             => Color.new(80, 112, 248),   # Blue
        :midground              => Color.new(80, 112, 248),   # Blue
        :background             => Color.new(80, 112, 248),   # Blue
        :user                   => Color.new(32, 192, 32),    # Green
        :target                 => Color.new(192, 32, 32),    # Red
        :user_and_target        => Color.new(192, 192, 32),   # Yellow
        :user_side_foreground   => Color.new(80, 208, 208),   # Cyan
        :user_side_background   => Color.new(80, 208, 208),   # Cyan
        :target_side_foreground => Color.new(80, 208, 208),   # Cyan
        :target_side_background => Color.new(80, 208, 208)    # Cyan
      }
    }
  }
  FOCUS_COLORS = {
    :foreground             => Color.new(128, 160, 248),   # Blue
    :midground              => Color.new(128, 160, 248),   # Blue
    :background             => Color.new(128, 160, 248),   # Blue
    :user                   => Color.new(64, 224, 64),     # Green
    :target                 => Color.new(224, 64, 64),     # Red
    :user_and_target        => Color.new(224, 224, 64),    # Yellow
    :user_side_foreground   => Color.new(128, 224, 224),   # Cyan
    :user_side_background   => Color.new(128, 224, 224),   # Cyan
    :target_side_foreground => Color.new(128, 224, 224),   # Cyan
    :target_side_background => Color.new(128, 224, 224)    # Cyan
  }

  def color_scheme_options
    return {
      :light => _INTL("Light"),
      :dark  => _INTL("Dark")
    }
  end

  #-----------------------------------------------------------------------------

  def background_color
    return get_color_scheme_color_for_element(:background_color, Color.white)
  end

  def semi_transparent_color
    return get_color_scheme_color_for_element(:semi_transparent_color, Color.new(0, 0, 0, 128))
  end

  #-----------------------------------------------------------------------------

  def text_color
    return get_color_scheme_color_for_element(:text_color, Color.black)
  end

  def disabled_text_color
    return get_color_scheme_color_for_element(:disabled_text_color, Color.new(160, 160, 160))
  end

  def text_size
    return 18   # Default is 22 if size isn't explicitly set
  end

  def line_color
    return get_color_scheme_color_for_element(:line_color, Color.black)
  end

  def delete_icon_color
    return get_color_scheme_color_for_element(:delete_icon_color, Color.new(248, 96, 96))
  end

  #-----------------------------------------------------------------------------

  def disabled_fill_color
    return get_color_scheme_color_for_element(:disabled_fill_color, Color.gray)
  end

  def hover_color
    return get_color_scheme_color_for_element(:hover_color, Color.new(224, 255, 255))
  end

  def capture_color
    return get_color_scheme_color_for_element(:capture_color, Color.new(255, 64, 128))
  end

  def highlight_color
    return get_color_scheme_color_for_element(:highlight_color, Color.new(224, 192, 32))
  end

  #-----------------------------------------------------------------------------

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = text_color
    self.bitmap.font.size = text_size
    invalidate if self.respond_to?(:invalidate)
  end

  def get_color_scheme_color_for_element(element, default)
    if COLOR_SCHEMES[@color_scheme] && COLOR_SCHEMES[@color_scheme][element]
      return COLOR_SCHEMES[@color_scheme][element]
    end
    return default
  end

  def focus_color(focus)
    if COLOR_SCHEMES[@color_scheme] && COLOR_SCHEMES[@color_scheme][:focus_colors] &&
       COLOR_SCHEMES[@color_scheme][:focus_colors][focus]
      return COLOR_SCHEMES[@color_scheme][:focus_colors][focus]
    end
    return FOCUS_COLORS[focus] || Color.magenta
  end

end
