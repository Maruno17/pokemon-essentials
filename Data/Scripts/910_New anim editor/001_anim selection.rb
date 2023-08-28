# TODO: Come up with a better name for this class. I'm not sure I want to merge
#       this class with the editor class.
class AnimationEditorLoadScreen
  WINDOW_WIDTH  = Settings::SCREEN_WIDTH + (32 * 10)
  WINDOW_HEIGHT = Settings::SCREEN_HEIGHT + (32 * 10)

  ANIMATIONS_LIST_X      = 4
  ANIMATIONS_LIST_Y      = 4
  ANIMATIONS_LIST_WIDTH  = 300
  ANIMATIONS_LIST_HEIGHT = WINDOW_HEIGHT - (ANIMATIONS_LIST_Y * 2)

  def initialize
    @viewport = Viewport.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @viewport)
    draw_editor_background
  end

  def dispose
    @screen_bitmap.dispose
    @viewport.dispose
  end

  def draw_editor_background
    # Fill the whole screen with black
    @screen_bitmap.bitmap.fill_rect(
      0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, Color.black
    )
    # Outline around animations list
    @screen_bitmap.bitmap.outline_rect(
      ANIMATIONS_LIST_X - 3, ANIMATIONS_LIST_Y - 3,
      ANIMATIONS_LIST_WIDTH + 6, ANIMATIONS_LIST_HEIGHT + 6, Color.white
    )
    @screen_bitmap.bitmap.outline_rect(
      ANIMATIONS_LIST_X - 2, ANIMATIONS_LIST_Y - 2,
      ANIMATIONS_LIST_WIDTH + 4, ANIMATIONS_LIST_HEIGHT + 4, Color.black
    )
    @screen_bitmap.bitmap.outline_rect(
      ANIMATIONS_LIST_X - 1, ANIMATIONS_LIST_Y - 1,
      ANIMATIONS_LIST_WIDTH + 2, ANIMATIONS_LIST_HEIGHT + 2, Color.white
    )
    # Fill the animations list with white
    @screen_bitmap.bitmap.fill_rect(
      ANIMATIONS_LIST_X, ANIMATIONS_LIST_Y, ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT, Color.white
    )
  end

  def update
    # TODO: Update the controls (animations list, Load button, etc.).
  end

  def run
    Input.text_input = false
    loop do
      inputting_text = Input.text_input
      Graphics.update
      Input.update
      update
      if !inputting_text
        break if Input.trigger?(Input::BACK)
      end
      # Open editor with animation
      # TODO: If the Load button is pressed while an animation is selected.
      if Input.trigger?(Input::USE)
        # TODO: Add animation to be edited as an argument.
        screen = AnimationEditor.new
        screen.run
      end
    end
    dispose
  end
end

#===============================================================================
# Start
#===============================================================================
def test_anim_editor
  Graphics.resize_screen(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
  pbSetResizeFactor(1)
  screen = AnimationEditorLoadScreen.new
  screen.run
  Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  pbSetResizeFactor($PokemonSystem.screensize)
  $game_map&.autoplay
end

#===============================================================================
# Add to Debug menu
#===============================================================================
MenuHandlers.add(:debug_menu, :use_pc, {
  "name"        => "Test new animation editor",
  "parent"      => :main,
  "description" => "Test new animation editor",
  "effect"      => proc {
    test_anim_editor
  }
})
