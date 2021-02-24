module Mouse
  module_function
  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere=false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end

end
