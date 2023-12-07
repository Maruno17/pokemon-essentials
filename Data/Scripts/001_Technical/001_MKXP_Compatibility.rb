# Using mkxp-z v2.4.2/c9378cf - built 2023-07-07
# https://github.com/mkxp-z/mkxp-z/actions/runs/5482601942
$VERBOSE = nil
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
end

class Bitmap
  attr_accessor :text_offset_y

  alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

  def draw_text(x, y, width, height = nil, text = "", align = 0)
    if x.is_a?(Rect)
      x.y -= (@text_offset_y || 0)
      # rect, string & alignment
      mkxp_draw_text(x, y, width)
    else
      y -= (@text_offset_y || 0)
      height = text_size(text).height
      mkxp_draw_text(x, y, width, height, text, align)
    end
  end
end

def pbSetResizeFactor(factor)
  if !$ResizeInitialized
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    $ResizeInitialized = true
  end
  if factor < 0 || factor == 4
    Graphics.fullscreen = true if !Graphics.fullscreen
  else
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = (factor + 1) * 0.5
    Graphics.center
  end
end

if System::VERSION != Essentials::MKXPZ_VERSION
  printf(sprintf("\e[1;33mWARNING: mkxp-z version %s detected, but this version of Pokémon Essentials was designed for mkxp-z version %s.\e[0m\r\n",
                 System::VERSION, Essentials::MKXPZ_VERSION))
  printf("\e[1;33mWARNING: Pokémon Essentials may not work properly.\e[0m\r\n")
end
