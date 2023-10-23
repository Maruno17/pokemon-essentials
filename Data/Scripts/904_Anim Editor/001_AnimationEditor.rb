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
  WINDOW_WIDTH  = Settings::SCREEN_WIDTH + (32 * 10)
  WINDOW_HEIGHT = Settings::SCREEN_HEIGHT + (32 * 10)

  TOP_BAR_HEIGHT = 30

  BORDER_THICKNESS = 4
  CANVAS_X         = BORDER_THICKNESS
  CANVAS_Y         = TOP_BAR_HEIGHT + BORDER_THICKNESS
  CANVAS_WIDTH     = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT    = Settings::SCREEN_HEIGHT

  PLAY_CONTROLS_X      = CANVAS_X
  PLAY_CONTROLS_Y      = CANVAS_Y + CANVAS_HEIGHT + (BORDER_THICKNESS * 2)
  PLAY_CONTROLS_WIDTH  = CANVAS_WIDTH
  PLAY_CONTROLS_HEIGHT = 64 - (BORDER_THICKNESS * 2)

  SIDE_PANE_X      = CANVAS_X + CANVAS_WIDTH + (BORDER_THICKNESS * 2)
  SIDE_PANE_Y      = CANVAS_Y
  SIDE_PANE_WIDTH  = WINDOW_WIDTH - SIDE_PANE_X - BORDER_THICKNESS
  SIDE_PANE_HEIGHT = CANVAS_HEIGHT + PLAY_CONTROLS_HEIGHT + (BORDER_THICKNESS * 2)

  PARTICLE_LIST_X      = BORDER_THICKNESS
  PARTICLE_LIST_Y      = SIDE_PANE_Y + SIDE_PANE_HEIGHT + (BORDER_THICKNESS * 2)
  PARTICLE_LIST_WIDTH  = WINDOW_WIDTH - (BORDER_THICKNESS * 2)
  PARTICLE_LIST_HEIGHT = WINDOW_HEIGHT - PARTICLE_LIST_Y - BORDER_THICKNESS

  def initialize(anim_id, anim)
    @anim_id = anim_id
    @anim = anim
    # Viewports
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @canvas_viewport = Viewport.new(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT)
    @canvas_viewport.z = @viewport.z
    # Background sprite
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    draw_editor_background
    # Canvas
    @canvas = AnimationEditor::Canvas.new(@canvas_viewport)
    # Play controls
    @play_controls = AnimationEditor::PlayControls.new(
      PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT, @viewport
    )
    # Side panes
    @commands_pane = UIControls::ControlsContainer.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    @se_pane       = UIControls::ControlsContainer.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    @particle_pane = UIControls::ControlsContainer.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    @keyframe_pane = UIControls::ControlsContainer.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    # TODO: Make more side panes for:
    #       - colour/tone editor (accessed from @commands_pane via a
    #         button; has Apply/Cancel buttons to only apply all its values at
    #         the end of editing them, although canvas will be updated in real
    #         time to show the changes)
    #       - effects particle properties (depends on keyframe; for screen
    #         shake, etc.)
    # Timeline/particle list
    @particle_list = AnimationEditor::ParticleList.new(
      PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT, @viewport
    )
    @particle_list.set_interactive_rects
    @captured = nil
    set_canvas_contents
    set_side_panes_contents
    set_particle_list_contents
    set_play_controls_contents
    refresh
  end

  def dispose
    @screen_bitmap.dispose
    @canvas.dispose
    @commands_pane.dispose
    @se_pane.dispose
    @particle_pane.dispose
    @keyframe_pane.dispose
    @play_controls.dispose
    @particle_list.dispose
    @viewport.dispose
    @canvas_viewport.dispose
  end

  def keyframe
    return @particle_list.keyframe
  end

  def particle_index
    return @particle_list.particle_index
  end

  #-----------------------------------------------------------------------------

  def set_canvas_contents
    @canvas.bg_name = "indoor1"
  end

  def set_commands_pane_contents
    # :frame (related to graphic) - If the graphic is user's sprite/target's
    # sprite, make this instead a choice of front/back/same as the main sprite/
    # opposite of the main sprite. Probably need two controls in the same space
    # and refresh_commands_pane makes the appropriate one visible.
    @commands_pane.add_labelled_number_text_box(:x, _INTL("X"), -128, CANVAS_WIDTH + 128, 64)
    @commands_pane.add_labelled_number_text_box(:y, _INTL("Y"), -128, CANVAS_HEIGHT + 128, 96)
    @commands_pane.add_labelled_checkbox(:visible, _INTL("Visible"), true)
    @commands_pane.add_labelled_number_slider(:opacity, _INTL("Opacity"), 0, 255, 255)
    @commands_pane.add_labelled_number_text_box(:zoom_x, _INTL("Zoom X"), 0, 1000, 100)
    @commands_pane.add_labelled_number_text_box(:zoom_y, _INTL("Zoom Y"), 0, 1000, 100)
    @commands_pane.add_labelled_number_text_box(:angle, _INTL("Angle"), -1080, 1080, 0)
    @commands_pane.add_labelled_checkbox(:flip, _INTL("Flip"), false)
    @commands_pane.add_labelled_dropdown_list(:blending, _INTL("Blending"), {
      0 => _INTL("None"),
      1 => _INTL("Additive"),
      2 => _INTL("Subtractive")
    }, 0)
    @commands_pane.add_labelled_button(:color_tone, _INTL("Color/Tone"), _INTL("Edit"))
    # @commands_pane.add_labelled_dropdown_list(:priority, _INTL("Priority"), {   # TODO: Include sub-priority.
    #   :behind_all  => _INTL("Behind all"),
    #   :behind_user => _INTL("Behind user"),
    #   :above_user  => _INTL("In front of user"),
    #   :above_all   => _INTL("In front of everything")
    # }, :above_user)
    # :sub_priority
#    @commands_pane.add_labelled_button(:masking, _INTL("Masking"), _INTL("Edit"))
    # TODO: Add buttons that shift all commands from the current keyframe and
    #       later forwards/backwards in time?
  end

  def set_se_pane_contents
    # TODO: A list containing all SE files that play this keyframe. Lists SE,
    #       user cry and target cry.
    @se_pane.add_button(:add, _INTL("Add"))
    @se_pane.add_button(:edit, _INTL("Edit"))
    @se_pane.add_button(:delete, _INTL("Delete"))
  end

  def set_particle_pane_contents
    # TODO: Name should blacklist certain names ("User", "Target", "SE") and
    #       should be disabled if the value is one of those.
    @particle_pane.add_labelled_text_box(:name, _INTL("Name"), _INTL("Untitled"))
    # TODO: Graphic should show the graphic's name alongside a "Change" button.
    #       New kind of control that is a label plus a button?
    @particle_pane.add_labelled_button(:graphic, _INTL("Graphic"), _INTL("Change"))
    @particle_pane.add_labelled_dropdown_list(:focus, _INTL("Focus"), {
      :user            => _INTL("User"),
      :target          => _INTL("Target"),
      :user_and_target => _INTL("User and target"),
      :screen          => _INTL("Screen")
    }, :user)
    # FlipIfFoe
    # RotateIfFoe
    # Delete button (if not "User"/"Target"/"SE")
    # Duplicate button
    # Shift all command timings by X keyframes (text box and button)
    # Move particle up/down the list?
  end

  def set_keyframe_pane_contents
    @keyframe_pane.add_label(:temp, _INTL("Keyframe pane"))
    # TODO: Various command-shifting options.
  end

  def set_side_panes_contents
    set_commands_pane_contents
    set_se_pane_contents
    set_particle_pane_contents
    set_keyframe_pane_contents
  end

  def set_particle_list_contents
    @particle_list.set_particles(@anim[:particles])
  end

  def set_play_controls_contents
    @play_controls.duration = @particle_list.duration
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    # Fill the whole screen with black
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.black)
    # Fill the top bar with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, TOP_BAR_HEIGHT, Color.white)
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
    # Outline around play controls
    @screen_bitmap.bitmap.outline_rect(PLAY_CONTROLS_X - 3, PLAY_CONTROLS_Y - 3, PLAY_CONTROLS_WIDTH + 6, PLAY_CONTROLS_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(PLAY_CONTROLS_X - 2, PLAY_CONTROLS_Y - 2, PLAY_CONTROLS_WIDTH + 4, PLAY_CONTROLS_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(PLAY_CONTROLS_X - 1, PLAY_CONTROLS_Y - 1, PLAY_CONTROLS_WIDTH + 2, PLAY_CONTROLS_HEIGHT + 2, Color.white)
    # Fill the play controls with white
    @screen_bitmap.bitmap.fill_rect(PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT, Color.white)
    # Outline around timeline/particle list
    @screen_bitmap.bitmap.outline_rect(PARTICLE_LIST_X - 3, PARTICLE_LIST_Y - 3, PARTICLE_LIST_WIDTH + 6, PARTICLE_LIST_HEIGHT + 6, Color.white)
    @screen_bitmap.bitmap.outline_rect(PARTICLE_LIST_X - 2, PARTICLE_LIST_Y - 2, PARTICLE_LIST_WIDTH + 4, PARTICLE_LIST_HEIGHT + 4, Color.black)
    @screen_bitmap.bitmap.outline_rect(PARTICLE_LIST_X - 1, PARTICLE_LIST_Y - 1, PARTICLE_LIST_WIDTH + 2, PARTICLE_LIST_HEIGHT + 2, Color.white)
  end

  def refresh_canvas
  end

  def refresh_commands_pane
    if keyframe < 0 || particle_index < 0 || !@anim[:particles][particle_index] ||
       @anim[:particles][particle_index][:name] == "SE"
      @commands_pane.visible = false
    else
      @commands_pane.visible = true
      new_vals = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(@anim[:particles][particle_index], keyframe)
      # TODO: Need to do something special for :color, :tone and :frame which
      #       all have button controls.
      @commands_pane.controls.each do |ctrl|
        next if !new_vals.include?(ctrl[0])
        ctrl[1].value = new_vals[ctrl[0]][0] if ctrl[1].respond_to?("value=")
        # TODO: new_vals[ctrl[0]][1] is whether the value is being interpolated,
        #       which should be indicated somehow in ctrl[1].
      end
    end
  end

  def refresh_se_pane
    if keyframe < 0 || particle_index < 0 || !@anim[:particles][particle_index] ||
       @anim[:particles][particle_index][:name] != "SE"
      @se_pane.visible = false
    else
      @se_pane.visible = true
      # TODO: Set list of SEs, activate/deactivate buttons accordingly.
    end
  end

  def refresh_particle_pane
    if keyframe >= 0 || particle_index < 0
      @particle_pane.visible = false
    else
      @particle_pane.visible = true
      new_vals = AnimationEditor::ParticleDataHelper.get_all_particle_values(@anim[:particles][particle_index])
      @particle_pane.controls.each do |ctrl|
        next if !new_vals.include?(ctrl[0])
        ctrl[1].value = new_vals[ctrl[0]] if ctrl[1].respond_to?("value=")
      end
      # TODO: Disable the name and graphic controls for "User"/"Target".
    end
  end

  def refresh_keyframe_pane
    if keyframe < 0 || particle_index >= 0
      @keyframe_pane.visible = false
    else
      @keyframe_pane.visible = true
    end
  end

  def refresh_particle_list
    @particle_list.refresh
  end

  def refresh_play_controls
    @play_controls.refresh
  end

  def refresh
    # Set canvas display
    refresh_canvas
    # Set all side pane controls to values from animation
    refresh_commands_pane
    refresh_se_pane
    refresh_particle_pane
    refresh_keyframe_pane
    # Set particle list's contents
    refresh_particle_list
    # Set play controls' information
    refresh_play_controls
  end

  #-----------------------------------------------------------------------------

  def update_canvas
    @canvas.update
    # TODO: Detect and apply changes made in canvas, e.g. moving particle,
    #       double-clicking to add particle, deleting particle.
  end

  def update_commands_pane
    return if !@commands_pane.visible
    @commands_pane.update
    if @commands_pane.busy?
      @captured = [@commands_pane, :update_commands_pane]
    end
    if @commands_pane.changed?
      # TODO: Make undo/redo snapshot.
      values = @commands_pane.values
      values.each_pair do |property, value|
        case property
        when :color_tone   # Button
          # TODO: Open the colour/tone side pane.
        else
          particle = @anim[:particles][particle_index]
          new_cmds = AnimationEditor::ParticleDataHelper.add_command(particle, property, keyframe, value)
          if new_cmds
            particle[property] = new_cmds
          else
            particle.delete(property)
          end
          @particle_list.change_particle_commands(particle_index)
          @play_controls.duration = @particle_list.duration
          refresh_commands_pane
        end
      end
      @commands_pane.clear_changed
    end
  end

  def update_se_pane
    return if !@se_pane.visible
    @se_pane.update
    if @se_pane.busy?
      @captured = [@se_pane, :update_se_pane]
    end
    # TODO: Enable the "Edit" and "Delete" controls only if an SE is selected.
    if @se_pane.changed?
      # TODO: Make undo/redo snapshot.
      values = @se_pane.values
      values.each_pair do |property, value|
        case property
        when :add   # Button
        when :edit   # Button
        when :delete   # Button
        else
          particle = @anim[:particles][particle_index]
        end
      end
      @se_pane.clear_changed
    end
  end

  def update_particle_pane
    return if !@particle_pane.visible
    @particle_pane.update
    if @particle_pane.busy?
      @captured = [@particle_pane, :update_particle_pane]
    end
    if @particle_pane.changed?
      # TODO: Make undo/redo snapshot.
      values = @particle_pane.values
      values.each_pair do |property, value|
        case property
        when :graphic   # Button
          # TODO: Open the graphic chooser pop-up window.
        else
          particle = @anim[:particles][particle_index]
          new_cmds = AnimationEditor::ParticleDataHelper.set_property(particle, property, value)
          @particle_list.change_particle(particle_index)
          refresh_particle_pane
        end
      end
      @particle_pane.clear_changed
    end
  end

  def update_keyframe_pane
    return if !@keyframe_pane.visible
    @keyframe_pane.update
    if @keyframe_pane.busy?
      @captured = [@keyframe_pane, :update_keyframe_pane]
    end
    if @keyframe_pane.changed?
      # TODO: Make undo/redo snapshot.
      values = @keyframe_pane.values
      values.each_pair do |property, value|
        # TODO: Stuff here once I decide what controls to add.
      end
      @keyframe_pane.clear_changed
    end
  end

  def update_particle_list
    old_keyframe = keyframe
    old_particle_index = particle_index
    @particle_list.update
    if @particle_list.busy?
      @captured = [@particle_list, :update_particle_list]
    end
    if @particle_list.changed?
      refresh if keyframe != old_keyframe || particle_index != old_particle_index
      # TODO: Lots of stuff here.
      @particle_list.clear_changed
    end
    @particle_list.repaint
  end

  def update_play_controls
    @play_controls.update
    @play_controls.repaint
    if @play_controls.busy?
      @captured = [@play_controls, :update_play_controls]
    end
    # TODO: Will the play controls ever signal themselves as changed? I don't
    #       think so.
    if @play_controls.changed?
      @play_controls.clear_changed
    end
    @play_controls.repaint
  end

  def update
    if @captured
      self.send(@captured[1])
      @captured = nil if !@captured[0].busy?
      return
    end
    update_canvas
    update_commands_pane
    update_se_pane
    update_particle_pane
    update_keyframe_pane
    update_particle_list
    update_play_controls
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
