#===============================================================================
#
#===============================================================================
class AnimationEditor::AnimationSelector
  ANIMATIONS_LIST_X      = 4
  ANIMATIONS_LIST_Y      = 4
  ANIMATIONS_LIST_WIDTH  = 300
  ANIMATIONS_LIST_HEIGHT = AnimationEditor::WINDOW_HEIGHT - (ANIMATIONS_LIST_Y * 2)

  LOAD_BUTTON_WIDTH  = 200
  LOAD_BUTTON_HEIGHT = 48
  LOAD_BUTTON_X      = ANIMATIONS_LIST_WIDTH + 100
  LOAD_BUTTON_Y      = ANIMATIONS_LIST_Y + (ANIMATIONS_LIST_HEIGHT / 2) - (LOAD_BUTTON_HEIGHT / 2)

  def initialize
    generate_list
    @viewport = Viewport.new(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, @viewport)
    draw_editor_background
    @load_animation_id = nil
    create_controls
  end

  def dispose
    @screen_bitmap.dispose
    @viewport.dispose
  end

  # TODO: Make separate arrays for move and common animations. Group animations
  #       for the same move/common animation together somehow to be listed in
  #       the main list - individual animations are shown in the secondary list.
  #       The display names will need improving accordingly. Usage of
  #       @animations in this class will need redoing.
  def generate_list
    @animations = []
    GameData::Animation.keys.each do |id|
      anim = GameData::Animation.get(id)
      if anim.version > 0
        name = "#{anim.type}: #{anim.move} (#{anim.version}) - #{anim.name}"
      else
        name = "#{anim.type}: #{anim.move} - #{anim.name}"
      end
      @animations.push([id, name])
    end
    # TODO: For scrollbar testing purposes.
    rand(400).times do |i|
      @animations.push([42 + i, "Extra animation #{i + 1}"])
    end
  end

  def draw_editor_background
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT, Color.black)
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
      # TODO: This line was quoted out previously, and I'm not sure why.
      @screen_bitmap.bitmap.fill_rect(area[0], area[1], area[2], area[3], Color.white)
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
    # TODO: Filter dropdown list to pick a move type? Other filter options?
    # "Load animation" button
    @load_button = UIControls::Button.new(LOAD_BUTTON_WIDTH, LOAD_BUTTON_HEIGHT, @viewport, "Load animation")
    @load_button.x = LOAD_BUTTON_X
    @load_button.y = LOAD_BUTTON_Y
    @load_button.set_fixed_size
    @load_button.set_interactive_rects
    @controls[:load] = @load_button
    # TODO: "New animation" button, "Delete animation" button, "Duplicate
    #       animation" button.
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
      # Open editor with animation
#      @load_animation_id = 2   # TODO: For quickstart testing purposes.
      if @load_animation_id
        screen = AnimationEditor.new(@load_animation_id, GameData::Animation.get(@load_animation_id).clone_as_hash)
        screen.run
        @load_animation_id = nil
#        break   # TODO: For quickstart testing purposes.
        # Refresh list of animations, in case the edited one changed its type,
        # move, version or name
        generate_list
        @list.values = @animations
        repaint
        next
      end
      # Typing text into a text box; don't want key presses to trigger anything
      next if inputting_text
      # Inputs
      break if Input.trigger?(Input::BACK)
    end
    dispose
  end
end

#===============================================================================
# Add to Debug menu.
#===============================================================================
MenuHandlers.add(:debug_menu, :use_pc, {
  "name"        => _INTL("New Animation Editor"),
  "parent"      => :main,
  "description" => _INTL("Open the new animation editor."),
  "effect"      => proc {
    Graphics.resize_screen(AnimationEditor::WINDOW_WIDTH, AnimationEditor::WINDOW_HEIGHT)
    pbSetResizeFactor(1)
    screen = AnimationEditor::AnimationSelector.new
    screen.run
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    pbSetResizeFactor($PokemonSystem.screensize)
    $game_map&.autoplay
  }
})
