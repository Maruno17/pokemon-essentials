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
