# TODO: Come up with a better name for this class. I'm not sure I want to merge
#       this class with the editor class.
class AnimationEditorLoadScreen
  WINDOW_WIDTH  = Settings::SCREEN_WIDTH + (32 * 10)
  WINDOW_HEIGHT = Settings::SCREEN_HEIGHT + (32 * 10)

  ANIMATIONS_LIST_X      = 4
  ANIMATIONS_LIST_Y      = 4
  ANIMATIONS_LIST_WIDTH  = 300
  ANIMATIONS_LIST_HEIGHT = WINDOW_HEIGHT - (ANIMATIONS_LIST_Y * 2)

  LOAD_BUTTON_WIDTH  = 200
  LOAD_BUTTON_HEIGHT = 48
  LOAD_BUTTON_X      = ANIMATIONS_LIST_WIDTH + 100
  LOAD_BUTTON_Y      = ANIMATIONS_LIST_Y + (ANIMATIONS_LIST_HEIGHT / 2) - (LOAD_BUTTON_HEIGHT / 2)

  def initialize
    generate_list
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    draw_editor_background
    @load_animation_id = nil
    create_controls
  end

  def dispose
    @screen_bitmap.dispose
    @viewport.dispose
  end

  def generate_list
    @animations = []
    # TODO: Look through GameData to populate @animations; below is temporary.
    #       There will be separate arrays for move animations, common animations
    #       and overworld animations. The move animations one will primarily be
    #       a list of moves that have any animations, with the actual GameData
    #       animations being in a sub-array for each move.
    67.times { |i| @animations.push([i, "Animation #{i + 1}"]) }
  end

  def draw_editor_background
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.black)
    # Outline around animations list
    areas = [
      [ANIMATIONS_LIST_X, ANIMATIONS_LIST_Y, ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT],
      [LOAD_BUTTON_X, LOAD_BUTTON_Y, LOAD_BUTTON_WIDTH, LOAD_BUTTON_HEIGHT]
    ]
    areas.each do |area|
      # Draw outlines around area
      @screen_bitmap.bitmap.outline_rect(area[0] - 3, area[1] - 3, area[2] + 6, area[3] + 6, Color.white)
      @screen_bitmap.bitmap.outline_rect(area[0] - 2, area[1] - 2, area[2] + 4, area[3] + 4, Color.black)
      @screen_bitmap.bitmap.outline_rect(area[0] - 1, area[1] - 1, area[2] + 2, area[3] + 2, Color.white)
      # Fill the area with white
#      @screen_bitmap.bitmap.fill_rect(area[0], area[1], area[2], area[3], Color.white)
    end
  end

  def create_controls
    @controls = {}
    # TODO: Buttons to toggle between listing moves that have animations, and
    #       common animations (and overworld animations).
    # Animations list
    @list = UIControls::List.new(ANIMATIONS_LIST_WIDTH, ANIMATIONS_LIST_HEIGHT, @viewport, @animations)
    @list.x = ANIMATIONS_LIST_X
    @list.y = ANIMATIONS_LIST_Y
    @controls[:list] = @list
    # TODO: A secondary list for displaying all the animations related to the
    #       selected move. For common anims/overworld anims, this will only ever
    #       list one animation. The first animation listed in here will be
    #       selected by default.
    # TODO: Filter text box for @list's contents. Applies the filter upon every
    #       change to the text box's value. Perhaps it should only do so after
    #       0.5 seconds of non-typing. What exactly should the filter be applied
    #       to? Animation's name, move's name (if there is one), what else?
    # TODO: Filter dropdown list to pick a type? Other filter options?
    # "Load animation" button
    @load_button = UIControls::Button.new(LOAD_BUTTON_WIDTH, LOAD_BUTTON_HEIGHT, @viewport, "Load animation")
    @load_button.x = LOAD_BUTTON_X
    @load_button.y = LOAD_BUTTON_Y
    @load_button.set_fixed_size
    @load_button.set_interactive_rects
    @controls[:load] = @load_button
    # TODO: "New animation" button, "Delete animation" button.
    repaint
  end

  def repaint
    @controls.each { |ctrl| ctrl[1].repaint }
  end

  def update
    # Update all controls
    if @captured
      @captured.update
      @captured = nil if !@captured.busy?
    else
      @controls.each do |ctrl|
        ctrl[1].update
        @captured = ctrl[1] if ctrl[1].busy?
      end
    end
    # Check for changes in controls
    @list.clear_changed if @list.changed?   # We don't need @list's value now
    if @load_button.changed?
      # TODO: This will need to get the animation ID from the sublist instead.
      @load_animation_id = @list.value
      @load_button.clear_changed
    end
    repaint   # Only repaints if needed
  end

  def run
    Input.text_input = false
    loop do
      inputting_text = Input.text_input
      Graphics.update
      Input.update
      update
      if @load_animation_id
        # Open editor with animation
        # TODO: Add animation to be edited as an argument. This will be
        #       GameData::Animation.get(@load_animation_id).to_hash.
        echoln "Anim number #{@load_animation_id}: #{@animations[@load_animation_id][1]}"
        screen = AnimationEditor.new
        screen.run
        @load_animation_id = nil
        # TODO: Regenerate @animations in case the edited animation changed its
        #       name/move/version. Reapply @animations to @list and the sublist
        #       (this should invalidate them).
        repaint
      elsif !inputting_text
        break if Input.trigger?(Input::BACK)
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
