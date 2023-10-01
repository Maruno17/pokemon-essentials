# TODO: Should I split this code into visual and mechanical classes, a la the
#       other UI screens?
#===============================================================================
# TODO: Need a way to recognise when text is being input into something
#       (Input.text_input) and disable all keyboard shortcuts if so. If only
#       this class has keyboard shortcuts in it, then it should be okay already.
# TODO: When creating a new particle, blacklist the names "User", "Target" and
#       "SE". Make particles with those names undeletable.
# TODO: Remove the particle named "Target" if the animation's focus is changed
#       to one that doesn't include a target, and vice versa. Do the same for
#       "User".
# TODO: Things that need pop-up windows (draws a semi-transparent grey over the
#       whole screen behind the window):
#       - graphic picker
#       - SE file picker
#       - animation properties (Move/OppMove/Common/OppCommon, move, version,
#         extra name, target, filepath, flags, etc.)
#       - editor settings (theme, canvas BG graphics, user/target graphics,
#         display of canvas particle boxes, etc.)
# TODO: While playing the animation, draw a semi-transparent grey over the
#       screen except for the canvas and playback controls. Can't edit anything
#       while it's playing.
#===============================================================================
class AnimationEditor
  WINDOW_WIDTH  = AnimationEditorLoadScreen::WINDOW_WIDTH
  WINDOW_HEIGHT = AnimationEditorLoadScreen::WINDOW_HEIGHT

  BORDER_THICKNESS = 4
  CANVAS_X         = BORDER_THICKNESS
  CANVAS_Y         = 32 + BORDER_THICKNESS
  CANVAS_WIDTH     = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT    = Settings::SCREEN_HEIGHT
  SIDE_PANE_X      = CANVAS_X + CANVAS_WIDTH + (BORDER_THICKNESS * 2)
  SIDE_PANE_Y      = CANVAS_Y
  SIDE_PANE_WIDTH  = WINDOW_WIDTH - SIDE_PANE_X - BORDER_THICKNESS
  SIDE_PANE_HEIGHT = CANVAS_HEIGHT + (32 * 2)

  def initialize(anim_id, anim)
    @anim_id = anim_id
    @anim = anim
    @keyframe = 0
    @particle = -1
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    draw_editor_background
    # Canvas
    @canvas = Sprite.new(@viewport)
    @canvas.x = CANVAS_X
    @canvas.y = CANVAS_Y
    @canvas.bitmap = RPG::Cache.load_bitmap("Graphics/Battlebacks/", "field_bg")
    # Side panes
    @keyframe_particle_pane = ControlPane.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    # TODO: Make more side panes for:
    #       - colour/tone editor (accessed from keyframe_particle_pane via a
    #         button; has Apply/Cancel buttons to only apply all its values at
    #         the end of editing them, although canvas will be updated in real
    #         time to show the changes)
    #       - particle properties (that don't change during the animation; name,
    #         focus...)
    #       - SE particle properties (depends on keyframe)
    #       - effects particle properties (depends on keyframe; for screen
    #         shake, etc.)
    #       - keyframe properties (shift all later particle commands forward/
    #         backward).
    set_side_panes_contents
    refresh
  end

  def dispose
    @screen_bitmap.dispose
    @canvas.dispose
    @keyframe_particle_pane.dispose
    @viewport.dispose
  end

  #-----------------------------------------------------------------------------

  def set_keyframe_particle_pane_contents
    # TODO: Move these properties to a new side pane for particle properties
    #       (ones that don't change during the animation).
    @keyframe_particle_pane.add_labelled_text_box(:name, "Name", "Untitled")
    #    @keyframe_particle_pane.add_labelled_dropdown_list(:focus, "Focus", {
    #      :user => "User",
    #      :target => "Target",
    #      :user_and_target => "User and target",
    #      :screen => "Screen"
    #    }, :user)

    # TODO: Make sure the IDs for these controls all match up to particle
    #       properties that can change during the animation.
    @keyframe_particle_pane.add_labelled_value_box(:x, "X", -128, CANVAS_WIDTH + 128, 64)
    @keyframe_particle_pane.add_labelled_value_box(:y, "Y", -128, CANVAS_HEIGHT + 128, 96)
    @keyframe_particle_pane.add_labelled_value_box(:zoom_x, "Zoom X", 0, 1000, 100)
    @keyframe_particle_pane.add_labelled_value_box(:zoom_y, "Zoom Y", 0, 1000, 100)
    @keyframe_particle_pane.add_labelled_checkbox(:visible, "Visible", true)
    @keyframe_particle_pane.add_labelled_slider(:opacity, "Opacity", 0, 255, 255)
    @keyframe_particle_pane.add_labelled_value_box(:angle, "Angle", -1080, 1080, 0)
    @keyframe_particle_pane.add_labelled_checkbox(:flip, "Flip", false)
    @keyframe_particle_pane.add_labelled_dropdown_list(:priority, "Priority", {   # TODO: Include sub-priority.
      :behind_all  => "Behind all",
      :behind_user => "Behind user",
      :above_user  => "In front of user",
      :above_all   => "In front of everything"
    }, :above_user)
    @keyframe_particle_pane.add_labelled_button(:color, "Color", "Edit")
    @keyframe_particle_pane.add_labelled_button(:tone, "Tone", "Edit")
    @keyframe_particle_pane.add_labelled_button(:graphic, "Graphic", "Change")
    # :frame (related to graphic)
    # :blending
    # TODO: Add buttons that shift all commands from the current keyframe and
    #       later forwards/backwards in time?
  end

  def set_side_panes_contents
    set_keyframe_particle_pane_contents
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    # Fill the whole screen with black
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.black)
    # Outline around canvas
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 3, CANVAS_Y - 3, CANVAS_WIDTH + 6, CANVAS_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 2, CANVAS_Y - 2, CANVAS_WIDTH + 4, CANVAS_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(CANVAS_X - 1, CANVAS_Y - 1, CANVAS_WIDTH + 2, CANVAS_HEIGHT + 2, Color.white)
    # Outline around side pane
    @screen_bitmap.bitmap.outline_rect(SIDE_PANE_X - 3, SIDE_PANE_Y - 3, SIDE_PANE_WIDTH + 6, SIDE_PANE_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(SIDE_PANE_X - 2, SIDE_PANE_Y - 2, SIDE_PANE_WIDTH + 4, SIDE_PANE_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(SIDE_PANE_X - 1, SIDE_PANE_Y - 1, SIDE_PANE_WIDTH + 2, SIDE_PANE_HEIGHT + 2, Color.white)
    # Fill the side pane with white
    @screen_bitmap.bitmap.fill_rect(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT, Color.white)
  end

  def get_keyframe_particle_value(particle, frame, property)
    if !GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.include?(property)
      raise _INTL("Couldn't get default value for property {1} for particle {2}.",
                  property, particle[:name])
    end
    ret = [GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[property], false]
    if particle[property]
      # NOTE: The commands are already in keyframe order, so we can just run
      #       through them in order, applying their changes until we reach
      #       frame.
      particle[property].each do |cmd|
        break if cmd[0] > frame   # Command is in the future; no more is needed
        break if cmd[0] == frame && cmd[1] > 0   # Start of a "MoveXYZ" command; won't have changed yet
        if cmd[0] + cmd[1] <= frame   # Command has finished; use its end value
          ret[0] = cmd[2]
          next
        end
        # In a "MoveXYZ" command; need to interpolate
        ret[0] = lerp(ret[0], cmd[2], cmd[1], cmd[0], frame).to_i
        ret[1] = true   # Interpolating
        break
      end
    end
    # NOTE: Particles are assumed to be not visible at the start of the
    #       animation, and automatically become visible when the particle has
    #       its first command. This does not apply to the "User" and "Target"
    #       particles, which start the animation visible.
    if property == :visible
      first_cmd = (["User", "Target"].include?(particle[:name])) ? 0 : -1
      first_visible_cmd = -1
      if first_cmd < 0
        particle.each_pair do |prop, value|
          next if !value.is_a?(Array) || value.length == 0
          first_cmd = value[0][0] if first_cmd < 0 || first_cmd > value[0][0]
          first_visible_cmd = value[0][0] if prop == :visible && (first_visible_cmd < 0 || first_visible_cmd > value[0][0])
        end
      end
      ret[0] = true if first_cmd >= 0 && first_cmd <= frame &&
                       (first_visible_cmd < 0 || frame < first_visible_cmd)
    end
    return ret
  end

  def get_all_keyframe_particle_values(particle, frame)
    ret = {}
    GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES.each_pair do |prop, default|
      ret[prop] = get_keyframe_particle_value(particle, frame, prop)
    end
    return ret
  end

  def refresh_keyframe_particle_pane
    if @particle < 0 || !@anim[:particles][@particle]
      @keyframe_particle_pane.visible = false
    else
      @keyframe_particle_pane.visible = true
      new_vals = get_all_keyframe_particle_values(@anim[:particles][@particle], @keyframe)
      # TODO: Need to do something special for :color, :tone and :graphic/:frame
      #       which all have button controls.
      @keyframe_particle_pane.controls.each do |ctrl|
        next if !new_vals.include?(ctrl[0])
        ctrl.value = new_vals[ctrl[0]][0]
        # TODO: new_vals[ctrl[0]][1] is whether the value is being interpolated,
        #       which should be indicated somehow in ctrl.
      end
    end
  end

  def refresh
    # Set all side pane controls to values from animation
    refresh_keyframe_particle_pane
  end

  #-----------------------------------------------------------------------------

  def update_canvas
    @canvas.update
    # TODO: Detect and apply changes made in canvas, e.g. moving particle,
    #       double-clicking to add particle, deleting particle.
  end

  def update_keyframe_particle_pane
    @keyframe_particle_pane.update
    if @keyframe_particle_pane.changed?
      # TODO: Make undo/redo snapshot.
      values = @keyframe_particle_pane.values
      # TODO: Apply vals to the animation data, unless the changed control is a
      #       button (its value will be true), in which case run some special
      #       code. Maybe this special code should be passed to/run in the
      #       control as a proc instead, and the button control can be given a
      #       value like any other control? Probably not.
      echoln values
      if values[:color]
      elsif values[:tone]
      elsif values[:graphic]
      end
      @keyframe_particle_pane.clear_changed
    end
  end

  def update
    update_canvas
    update_keyframe_particle_pane
  end

  #-----------------------------------------------------------------------------

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
