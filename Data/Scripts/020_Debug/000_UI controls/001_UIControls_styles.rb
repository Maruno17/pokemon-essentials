#===============================================================================
# Container module for control classes.
#===============================================================================
module UIControls; end

#===============================================================================
#
#===============================================================================
module UIControls::StyleMixin
  DEFAULT_SCHEME = :light
  COLOR_SCHEMES = {
    :light => {
      :background          => Color.new(248, 248, 248),
      :control_background  => Color.white,
      :gray_background     => Color.new(160, 160, 160),
      :semi_transparent    => Color.new(0, 0, 0, 128),
      :text                => Color.black,
      :disabled_text       => Color.new(160, 160, 160),
      :line                => Color.black,
      :disabled_fill       => Color.gray,
      :hover               => Color.new(224, 255, 255),
      :capture             => Color.new(255, 64, 128),
      :highlight           => Color.new(224, 192, 32),
      # Checkbox
      :checked             => Color.new(48, 192, 48),
      :unchecked           => Color.gray,
      # ColorPicker
      :negative_text       => Color.white,   # Lighter than :background
      :checkerboard_light  => Color.gray,
      :checkerboard_dark   => Color.new(144, 144, 144),
      # Timeline
      :selected_lines      => Color.new(248, 96, 96),
      :after_end_bg        => Color.new(160, 160, 160),
      :gridline            => Color.new(192, 192, 192),
      :gridline_after_end  => Color.new(128, 128, 128),
      # ListedParticle
      :se_background       => Color.gray,
      :property_background => Color.new(224, 224, 224),
      # ListedParticle and Canvas
      :focus_colors        => {
        :foreground                        => Color.new(128, 160, 248),   # Blue
        :midground                         => Color.new(128, 160, 248),   # Blue
        :background                        => Color.new(128, 160, 248),   # Blue
        :user                              => Color.new(64, 224, 64),     # Green
        :user_position                     => Color.new(64, 224, 64),     # Green
        :target                            => Color.new(224, 64, 64),     # Red
        :target_position                   => Color.new(224, 64, 64),     # Red
        :user_and_target                   => Color.new(224, 224, 64),    # Yellow
        :user_position_and_target          => Color.new(224, 224, 64),    # Yellow
        :user_and_target_position          => Color.new(224, 224, 64),    # Yellow
        :user_position_and_target_position => Color.new(224, 224, 64),    # Yellow
        :user_side_foreground              => Color.new(128, 224, 224),   # Cyan
        :user_side_background              => Color.new(128, 224, 224),   # Cyan
        :target_side_foreground            => Color.new(128, 224, 224),   # Cyan
        :target_side_background            => Color.new(128, 224, 224)    # Cyan
      }
    },
    :dark => {
      :background          => Color.new(32, 32, 32),
      :control_background  => Color.new(16, 16, 16),
      :gray_background     => Color.new(96, 96, 96),
#      :semi_transparent    => Color.new(0, 0, 0, 128),   # Unchanged
      :text                => Color.new(224, 224, 224),
      :disabled_text       => Color.new(96, 96, 96),
      :line                => Color.new(224, 224, 224),
      :disabled_fill       => Color.new(128, 128, 128),
      :hover               => Color.new(16, 56, 56),
      :capture             => Color.new(224, 32, 96),
      :highlight           => Color.new(160, 128, 16),
      # Checkbox
      :checked             => Color.new(32, 160, 32),
      :unchecked           => Color.new(128, 128, 128),
      # ColorPicker
      :negative_text       => Color.black,   # Darker than :background
      :checkerboard_light  => Color.new(144, 144, 144),
      :checkerboard_dark   => Color.gray,
      # Timeline
#      :selected_lines      => Color.new(248, 96, 96),   # Unchanged
      :after_end_bg        => Color.new(80, 80, 80),
      :gridline            => Color.new(48, 48, 48),
      :gridline_after_end  => Color.new(112, 112, 112),
      # ListedParticle
      :se_background       => Color.new(160, 160, 160),
      :property_background => Color.new(96, 96, 96),
      # ListedParticle and Canvas
      :focus_colors        => {
        :foreground                        => Color.new(80, 112, 248),   # Blue
        :midground                         => Color.new(80, 112, 248),   # Blue
        :background                        => Color.new(80, 112, 248),   # Blue
        :user                              => Color.new(32, 192, 32),    # Green
        :user_position                     => Color.new(32, 192, 32),    # Green
        :target                            => Color.new(192, 32, 32),    # Red
        :target_position                   => Color.new(192, 32, 32),    # Red
        :user_and_target                   => Color.new(192, 192, 32),   # Yellow
        :user_position_and_target          => Color.new(192, 192, 32),   # Yellow
        :user_and_target_position          => Color.new(192, 192, 32),   # Yellow
        :user_position_and_target_position => Color.new(192, 192, 32),   # Yellow
        :user_side_foreground              => Color.new(80, 208, 208),   # Cyan
        :user_side_background              => Color.new(80, 208, 208),   # Cyan
        :target_side_foreground            => Color.new(80, 208, 208),   # Cyan
        :target_side_background            => Color.new(80, 208, 208)    # Cyan
      }
    }
  }

  def color_scheme_options
    return {
      :light => _INTL("Light"),
      :dark  => _INTL("Dark")
    }
  end

  #-----------------------------------------------------------------------------

  def text_size
    return 16   # Default is 22 if size isn't explicitly set
  end

  #-----------------------------------------------------------------------------

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = get_color_of(:text)
    self.bitmap.font.size = text_size
    invalidate if self.respond_to?(:invalidate)
  end

  def get_color_of(element)
    if COLOR_SCHEMES[@color_scheme] && COLOR_SCHEMES[@color_scheme][element]
      return COLOR_SCHEMES[@color_scheme][element]
    end
    if COLOR_SCHEMES[DEFAULT_SCHEME] && COLOR_SCHEMES[DEFAULT_SCHEME][element]
      return COLOR_SCHEMES[DEFAULT_SCHEME][element]
    end
    return Color.magenta
  end

  def focus_color(focus)
    if COLOR_SCHEMES[@color_scheme] && COLOR_SCHEMES[@color_scheme][:focus_colors] &&
       COLOR_SCHEMES[@color_scheme][:focus_colors][focus]
      return COLOR_SCHEMES[@color_scheme][:focus_colors][focus]
    end
    if COLOR_SCHEMES[DEFAULT_SCHEME] && COLOR_SCHEMES[DEFAULT_SCHEME][:focus_colors] &&
       COLOR_SCHEMES[DEFAULT_SCHEME][:focus_colors][focus]
      return COLOR_SCHEMES[DEFAULT_SCHEME][:focus_colors][focus]
    end
    return Color.magenta
  end
end
