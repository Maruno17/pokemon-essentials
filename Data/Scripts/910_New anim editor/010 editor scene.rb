# TODO: Should I split this code into visual and mechanical classes, a la the
#       other UI screens?
#===============================================================================
# TODO: Need a way to recognise when text is being input into something
#       (Input.text_input) and disable all keyboard shortcuts if so. If only
#       this class has keyboard shortcuts in it, then it should be okay already.
#===============================================================================
class AnimationEditor
  WINDOW_WIDTH  = AnimationEditorLoadScreen::WINDOW_WIDTH
  WINDOW_HEIGHT = AnimationEditorLoadScreen::WINDOW_HEIGHT

  CANVAS_X          = 4
  CANVAS_Y          = 32 + 4
  CANVAS_WIDTH      = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT     = Settings::SCREEN_HEIGHT
  SIDE_PANEL_X      = CANVAS_X + CANVAS_WIDTH + 4 + 4
  SIDE_PANEL_Y      = CANVAS_Y
  SIDE_PANEL_WIDTH  = WINDOW_WIDTH - SIDE_PANEL_X - 4
  SIDE_PANEL_HEIGHT = CANVAS_HEIGHT + (32 * 2)

  # TODO: Add a parameter which is the animation to be edited, and also a
  #       parameter for that animation's ID in GameData (just for the sake of
  #       saving changes over the same GameData slot).
  def initialize
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    draw_editor_background
    # Canvas
    @canvas = Sprite.new(@viewport)
    @canvas.x = CANVAS_X
    @canvas.y = CANVAS_Y
    @canvas.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", "field_bg")
    # Side pane
    @side_pane = ControlPane.new(SIDE_PANEL_X, SIDE_PANEL_Y, SIDE_PANEL_WIDTH, SIDE_PANEL_HEIGHT)
    set_side_panel_contents
  end

  def dispose
    @screen_bitmap.dispose
    @canvas.dispose
    @side_pane.dispose
    @viewport.dispose
  end

  def draw_editor_background
    # Fill the whole screen with black
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.black)
    # Outline around canvas
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 3, CANVAS_Y - 3, CANVAS_WIDTH + 6, CANVAS_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 2, CANVAS_Y - 2, CANVAS_WIDTH + 4, CANVAS_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 1, CANVAS_Y - 1, CANVAS_WIDTH + 2, CANVAS_HEIGHT + 2, Color.white)
    # Outline around side panel
    @screen_bitmap.bitmap.outline_rect(SIDE_PANEL_X - 3, SIDE_PANEL_Y - 3, SIDE_PANEL_WIDTH + 6, SIDE_PANEL_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(SIDE_PANEL_X - 2, SIDE_PANEL_Y - 2, SIDE_PANEL_WIDTH + 4, SIDE_PANEL_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(SIDE_PANEL_X - 1, SIDE_PANEL_Y - 1, SIDE_PANEL_WIDTH + 2, SIDE_PANEL_HEIGHT + 2, Color.white)
    # Fill the side panel with white
    @screen_bitmap.bitmap.fill_rect(SIDE_PANEL_X, SIDE_PANEL_Y, SIDE_PANEL_WIDTH, SIDE_PANEL_HEIGHT, Color.white)
  end

  def set_side_panel_contents
    @side_pane.add_labelled_text_box(:name, "Name", "Untitled")
    @side_pane.add_labelled_value_box(:x, "X", -128, CANVAS_WIDTH + 128, 64)
    @side_pane.add_labelled_value_box(:y, "Y", -128, CANVAS_HEIGHT + 128, 96)
    @side_pane.add_labelled_value_box(:zoom_x, "Zoom X", 0, 1000, 100)
    @side_pane.add_labelled_value_box(:zoom_y, "Zoom Y", 0, 1000, 100)
    @side_pane.add_labelled_value_box(:angle, "Angle", -1080, 1080, 0)
    @side_pane.add_labelled_checkbox(:visible, "Visible", true)
    @side_pane.add_labelled_slider(:opacity, "Opacity", 0, 255, 255)
    @side_pane.add_labelled_checkbox(:flip, "Flip", false)
    @side_pane.add_labelled_dropdown_list(:priority, "Priority", {   # TODO: Include sub-priority.
      :behind_all  => "Behind all",
      :behind_user => "Behind user",
      :above_user  => "In front of user",
      :above_all   => "In front of everything"
    }, :above_user)
#    @side_pane.add_labelled_dropdown_list(:focus, "Focus", {
#      :user => "User",
#      :target => "Target",
#      :user_and_target => "User and target",
#      :screen => "Screen"
#    }, :user)
    @side_pane.add_labelled_button(:color, "Color/tone", "Edit")
    @side_pane.add_labelled_button(:graphic, "Graphic", "Change")
  end

  def update
    @canvas.update
    @side_pane.update
    # TODO: Check @side_pane for whether it's changed. Note that it includes
    #       buttons which won't themselves have a value but will flag themselves
    #       as changed when clicked; code here should determine what happens if
    #       a button is pressed (unless I put said code in a proc passed to the
    #       button control; said code will be lengthy).
  end

  def run
    Input.text_input = false
    loop do
      inputting_text = Input.text_input
      Graphics.update
      Input.update
      update
      if !inputting_text
        if Input.trigger?(Input::BACK)
          # TODO: Ask to save/discard changes.
          # TODO: When saving, add animation to GameData and rewrite animation's
          #       parent PBS file (which could include multiple animations).
          break
        end
      end
    end
    dispose
  end
end
