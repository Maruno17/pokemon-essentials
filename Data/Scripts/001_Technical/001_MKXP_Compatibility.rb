$MKXP = !!defined?(System)

def mkxp?
  return $MKXP
end

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
end

class Bitmap
  alias mkxp_draw_text draw_text

  def draw_text(x, y, width, height, text, align = 0)
    height = text_size(text).height
    mkxp_draw_text(x, y, width, height, text, align)
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
