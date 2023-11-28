# TODO: Should I split this code into visual and mechanical classes, a la the
#       other UI screens?
#===============================================================================
# TODO: When creating a new particle, blacklist the names "User", "Target" and
#       "SE". Make particles with those names undeletable.
# TODO: Remove the particle named "Target" if the animation's focus is changed
#       to one that doesn't include a target, and vice versa. Do the same for
#       "User"(?).
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

  BORDER_THICKNESS = 4

  MENU_BAR_WIDTH  = WINDOW_WIDTH
  MENU_BAR_HEIGHT = 30

  CANVAS_X      = BORDER_THICKNESS
  CANVAS_Y      = MENU_BAR_HEIGHT + BORDER_THICKNESS
  CANVAS_WIDTH  = Settings::SCREEN_WIDTH
  CANVAS_HEIGHT = Settings::SCREEN_HEIGHT

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
    @pbs_path = anim[:pbs_path]
    @quit = false
    # Viewports
    @viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @viewport.z = 99999
    @canvas_viewport = Viewport.new(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT)
    @canvas_viewport.z = @viewport.z
    @pop_up_viewport = Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    @pop_up_viewport.z = @viewport.z + 50
    # Background sprite
    @screen_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    @screen_bitmap.z = -100
    @se_list_box_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @viewport)
    @se_list_box_bitmap.z = -90
    @se_list_box_bitmap.visible = false
    @pop_up_bg_bitmap = BitmapSprite.new(WINDOW_WIDTH, WINDOW_HEIGHT, @pop_up_viewport)
    @pop_up_bg_bitmap.z = -100
    @pop_up_bg_bitmap.visible = false
    draw_editor_background
    @components = {}
    # Menu bar
    @components[:menu_bar] = AnimationEditor::MenuBar.new(0, 0, MENU_BAR_WIDTH, MENU_BAR_HEIGHT, @viewport)
    # Canvas
    @components[:canvas] = AnimationEditor::Canvas.new(@canvas_viewport)
    # Play controls
    @components[:play_controls] = AnimationEditor::PlayControls.new(
      PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT, @viewport
    )
    # Side panes
    [:commands_pane, :se_pane, :particle_pane, :keyframe_pane].each do |pane|
      @components[pane] = UIControls::ControlsContainer.new(SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    end
    # TODO: Make more side panes for:
    #       - colour/tone editor (accessed from @components[:commands_pane] via
    #         a button; has Apply/Cancel buttons to only apply all its values at
    #         the end of editing them, although canvas will be updated in real
    #         time to show the changes)
    #       - effects particle properties (depends on keyframe; for screen
    #         shake, etc.)
    # Timeline/particle list
    @components[:particle_list] = AnimationEditor::ParticleList.new(
      PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT, @viewport
    )
    @components[:particle_list].set_interactive_rects
    @captured = nil
    set_menu_bar_contents
    set_canvas_contents
    set_side_panes_contents
    set_particle_list_contents
    set_play_controls_contents
    refresh
  end

  def dispose
    @screen_bitmap.dispose
    @se_list_box_bitmap.dispose
    @pop_up_bg_bitmap.dispose
    @components.each_value { |c| c.dispose }
    @components.clear
    @viewport.dispose
    @canvas_viewport.dispose
  end

  def keyframe
    return @components[:particle_list].keyframe
  end

  def particle_index
    return @components[:particle_list].particle_index
  end

  #-----------------------------------------------------------------------------

  # Returns the animation's name for display in the menu bar and elsewhere.
  def get_animation_display_name
    ret = ""
    case @anim[:type]
    when :move       then ret += _INTL("[Move]")
    when :opp_move   then ret += _INTL("[Foe Move]")
    when :common     then ret += _INTL("[Common]")
    when :opp_common then ret += _INTL("[Foe Common]")
    else
      raise _INTL("Unknown animation type.")
    end
    case @anim[:type]
    when :move, :opp_move
      move_data = GameData::Move.try_get(@anim[:move])
      move_name = (move_data) ? move_data.name : @anim[:move]
      ret += " " + move_name
    when :common, :opp_common
      ret += " " + @anim[:move]
    end
    ret += " (" + @anim[:version].to_s + ")" if @anim[:version] > 0
    ret += " - " + @anim[:name] if @anim[:name]
    return ret
  end

  def set_menu_bar_contents
    @components[:menu_bar].add_button(:quit, _INTL("Quit"))
    @components[:menu_bar].add_button(:save, _INTL("Save"))
    @components[:menu_bar].add_name_button(:name, get_animation_display_name)
  end

  def set_canvas_contents
    @components[:canvas].bg_name = "indoor1"
  end

  def set_commands_pane_contents
    commands_pane = @components[:commands_pane]
    commands_pane.add_header_label(:header, _INTL("Edit particle at keyframe"))
    # :frame (related to graphic) - If the graphic is user's sprite/target's
    # sprite, make this instead a choice of front/back/same as the main sprite/
    # opposite of the main sprite. Probably need two controls in the same space
    # and refresh_component(:commands_pane) makes the appropriate one visible.
    commands_pane.add_labelled_number_text_box(:x, _INTL("X"), -128, CANVAS_WIDTH + 128, 64)
    commands_pane.add_labelled_number_text_box(:y, _INTL("Y"), -128, CANVAS_HEIGHT + 128, 96)
    commands_pane.add_labelled_checkbox(:visible, _INTL("Visible"), true)
    commands_pane.add_labelled_number_slider(:opacity, _INTL("Opacity"), 0, 255, 255)
    commands_pane.add_labelled_number_text_box(:zoom_x, _INTL("Zoom X"), 0, 1000, 100)
    commands_pane.add_labelled_number_text_box(:zoom_y, _INTL("Zoom Y"), 0, 1000, 100)
    commands_pane.add_labelled_number_text_box(:angle, _INTL("Angle"), -1080, 1080, 0)
    commands_pane.add_labelled_checkbox(:flip, _INTL("Flip"), false)
    commands_pane.add_labelled_dropdown_list(:blending, _INTL("Blending"), {
      0 => _INTL("None"),
      1 => _INTL("Additive"),
      2 => _INTL("Subtractive")
    }, 0)
    commands_pane.add_labelled_button(:color_tone, _INTL("Color/Tone"), _INTL("Edit"))
    # commands_pane.add_labelled_dropdown_list(:priority, _INTL("Priority"), {   # TODO: Include sub-priority.
    #   :behind_all  => _INTL("Behind all"),
    #   :behind_user => _INTL("Behind user"),
    #   :above_user  => _INTL("In front of user"),
    #   :above_all   => _INTL("In front of everything")
    # }, :above_user)
    # :sub_priority
#    commands_pane.add_labelled_button(:masking, _INTL("Masking"), _INTL("Edit"))
    # TODO: Add buttons that shift all commands from the current keyframe and
    #       later forwards/backwards in time?
  end

  def set_se_pane_contents
    se_pane = @components[:se_pane]
    se_pane.add_header_label(:header, _INTL("Edit sound effects at keyframe"))
    size = se_pane.control_size
    size[0] -= 10
    size[1] = UIControls::List::ROW_HEIGHT * 5   # 5 rows
    list = UIControls::List.new(*size, se_pane.viewport, [])
    se_pane.add_control_at(:list, list, 5, 30)
    button_height = UIControls::ControlsContainer::LINE_SPACING
    add = UIControls::Button.new(101, button_height, se_pane.viewport, _INTL("Add"))
    add.set_fixed_size
    se_pane.add_control_at(:add, add, 1, 154)
    edit = UIControls::Button.new(100, button_height, se_pane.viewport, _INTL("Edit"))
    edit.set_fixed_size
    se_pane.add_control_at(:edit, edit, 102, 154)
    delete = UIControls::Button.new(101, button_height, se_pane.viewport, _INTL("Delete"))
    delete.set_fixed_size
    se_pane.add_control_at(:delete, delete, 202, 154)
  end

  def set_particle_pane_contents
    particle_pane = @components[:particle_pane]
    particle_pane.add_header_label(:header, _INTL("Edit particle properties"))
    # TODO: Name should blacklist certain names ("User", "Target", "SE") and
    #       should be disabled if the value is one of those.
    particle_pane.add_labelled_text_box(:name, _INTL("Name"), _INTL("Untitled"))
    # TODO: Graphic should show the graphic's name alongside a "Change" button.
    #       New kind of control that is a label plus a button?
    particle_pane.add_labelled_label(:graphic_name, _INTL("Graphic"), "")
    particle_pane.add_labelled_button(:graphic, "", _INTL("Change"))
    particle_pane.add_labelled_dropdown_list(:focus, _INTL("Focus"), {
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
    keyframe_pane = @components[:keyframe_pane]
    keyframe_pane.add_header_label(:header, _INTL("Edit keyframe"))
    # TODO: Various command-shifting options.
  end

  def set_side_panes_contents
    set_commands_pane_contents
    set_se_pane_contents
    set_particle_pane_contents
    set_keyframe_pane_contents
  end

  def set_particle_list_contents
    @components[:particle_list].set_particles(@anim[:particles])
  end

  def set_play_controls_contents
    @components[:play_controls].duration = @components[:particle_list].duration
  end

  #-----------------------------------------------------------------------------

  def save
    GameData::Animation.register(@anim, @anim_id)
    Compiler.write_battle_animation_file(@anim[:pbs_path])
    if @anim[:pbs_path] != @pbs_path
      if GameData::Animation::DATA.any? { |_key, anim| anim.pbs_path == @pbs_path }
        Compiler.write_battle_animation_file(@pbs_path)
      elsif FileTest.exist?("PBS/Animations/" + @pbs_path + ".txt")
        File.delete("PBS/Animations/" + @pbs_path + ".txt")
      end
      @pbs_path = @anim[:pbs_path]
    end
  end

  #-----------------------------------------------------------------------------

  def draw_editor_background
    draw_big_outline = lambda do |bitmap, x, y, width, height|
      BORDER_THICKNESS.times do |i|
        col = (i.even?) ? Color.white : Color.black
        bitmap.outline_rect(x - i - 1, y - i - 1, width + (i * 2) + 2, height + (i * 2) + 2, col)
      end
    end
    # Fill the whole screen with white
    @screen_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.white)
    # Outline around elements
    draw_big_outline.call(@screen_bitmap.bitmap, CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT)
    draw_big_outline.call(@screen_bitmap.bitmap, PLAY_CONTROLS_X, PLAY_CONTROLS_Y, PLAY_CONTROLS_WIDTH, PLAY_CONTROLS_HEIGHT)
    draw_big_outline.call(@screen_bitmap.bitmap, SIDE_PANE_X, SIDE_PANE_Y, SIDE_PANE_WIDTH, SIDE_PANE_HEIGHT)
    draw_big_outline.call(@screen_bitmap.bitmap, PARTICLE_LIST_X, PARTICLE_LIST_Y, PARTICLE_LIST_WIDTH, PARTICLE_LIST_HEIGHT)
    # Draw box around SE list box in side pane
    @se_list_box_bitmap.bitmap.outline_rect(SIDE_PANE_X + 3, SIDE_PANE_Y + 24 + 4,
                                            SIDE_PANE_WIDTH - 6, (5 * UIControls::List::ROW_HEIGHT) + 4, Color.black)
    # Make the pop-up background semi-transparent
    @pop_up_bg_bitmap.bitmap.fill_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, Color.new(0, 0, 0, 128))
  end

  def refresh_component_visibility(component_sym)
    component = @components[component_sym]
    # Panes are all mutually exclusive
    case component_sym
    when :commands_pane
      component.visible = (keyframe >= 0 && particle_index >= 0 &&
                          @anim[:particles][particle_index] &&
                          @anim[:particles][particle_index][:name] != "SE")
    when :se_pane
      component.visible = (keyframe >= 0 && particle_index >= 0 &&
                          @anim[:particles][particle_index] &&
                          @anim[:particles][particle_index][:name] == "SE")
      @se_list_box_bitmap.visible = component.visible
    when :particle_pane
      component.visible = (keyframe < 0 && particle_index >= 0)
    when :keyframe_pane
      component.visible = (keyframe >= 0 && particle_index < 0)
    end
  end

  def refresh_component_values(component_sym)
    component = @components[component_sym]
    case component_sym
    when :commands_pane
      new_vals = AnimationEditor::ParticleDataHelper.get_all_keyframe_particle_values(@anim[:particles][particle_index], keyframe)
      # TODO: Need to do something special for :color, :tone and :frame which
      #       all have button controls.
      component.controls.each do |ctrl|
        next if !new_vals.include?(ctrl[0])
        ctrl[1].value = new_vals[ctrl[0]][0] if ctrl[1].respond_to?("value=")
        # TODO: new_vals[ctrl[0]][1] is whether the value is being interpolated,
        #       which should be indicated somehow in ctrl[1].
      end
    when :se_pane
      # TODO: Activate/deactivate Edit/Delete buttons accordingly.
      se_particle = @anim[:particles].select { |p| p[:name] == "SE" }[0]
      kyfrm = keyframe
      # Populate list of files
      list = []
      se_particle.each_pair do |property, values|
        next if !values.is_a?(Array)
        values.each do |val|
          next if val[0] != kyfrm
          text = AnimationEditor::ParticleDataHelper.get_se_display_text(property, val)
          case property
          when :user_cry   then list.push(["USER", text])
          when :target_cry then list.push(["TARGET", text])
          when :se         then list.push([val[2], text])
          end
        end
      end
      list.sort! { |a, b| a[1].downcase <=> b[1].downcase }
      component.get_control(:list).values = list
    when :particle_pane
      new_vals = AnimationEditor::ParticleDataHelper.get_all_particle_values(@anim[:particles][particle_index])
      component.controls.each do |ctrl|
        next if !new_vals.include?(ctrl[0])
        ctrl[1].value = new_vals[ctrl[0]] if ctrl[1].respond_to?("value=")
      end
      graphic_name = @anim[:particles][particle_index][:graphic]
      graphic_override_names = {
        "USER"         => _INTL("[[User's sprite]]"),
        "USER_OPP"     => _INTL("[[User's other side sprite]]"),
        "USER_FRONT"   => _INTL("[[User's front sprite]]"),
        "USER_BACK"    => _INTL("[[User's back sprite]]"),
        "TARGET"       => _INTL("[[Target's sprite]]"),
        "TARGET_OPP"   => _INTL("[[Target's other side sprite]]"),
        "TARGET_FRONT" => _INTL("[[Target's front sprite]]"),
        "TARGET_BACK"  => _INTL("[[Target's back sprite]]"),
      }
      graphic_name = graphic_override_names[graphic_name] if graphic_override_names[graphic_name]
      component.get_control(:graphic_name).label = graphic_name
      # TODO: Disable the name, graphic and focus controls for "User"/"Target".
    end
  end

  def refresh_component(component_sym)
    refresh_component_visibility(component_sym)
    return if !@components[component_sym].visible
    refresh_component_values(component_sym)
    @components[component_sym].refresh
  end

  def refresh
    @components.each_key { |sym| refresh_component(sym) }
  end

  #-----------------------------------------------------------------------------

  # TODO: Every component that contains a button, etc. should respond to
  #       "values", which returns the changed elements.
  def apply_changed_value(component_sym, property, value)
    case component_sym
    when :menu_bar
      case property
      when :quit
        @quit = true
      when :save
        save
      when :name
        # TODO: Open the animation properties pop-up window.
        echoln "animation name clicked"
      end
    when :canvas
      # TODO: Detect and apply changes made in canvas, e.g. moving particle,
      #       double-clicking to add particle, deleting particle.
    when :commands_pane
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
        @components[:particle_list].change_particle_commands(particle_index)
        @components[:play_controls].duration = @components[:particle_list].duration
        refresh_component(:commands_pane)
      end
    when :se_pane
      case property
      when :add   # Button
        new_file, new_volume, new_pitch = choose_audio_file("", 100, 100)
        if new_file != ""
          particle = @anim[:particles][particle_index]
          AnimationEditor::ParticleDataHelper.add_se_command(particle, keyframe, new_file, new_volume, new_pitch)
          @components[:particle_list].change_particle_commands(particle_index)
          @components[:play_controls].duration = @components[:particle_list].duration
          refresh_component(:se_pane)
        end
      when :edit   # Button
        particle = @anim[:particles][particle_index]
        list = @components[:se_pane].get_control(:list)
        old_file = list.value
        old_volume, old_pitch = AnimationEditor::ParticleDataHelper.get_se_values_from_filename_and_frame(particle, keyframe, old_file)
        if old_file
          new_file, new_volume, new_pitch = choose_audio_file(old_file, old_volume, old_pitch)
          if new_file != old_file || new_volume != old_volume || new_pitch != old_pitch
            AnimationEditor::ParticleDataHelper.delete_se_command(particle, keyframe, old_file)
            AnimationEditor::ParticleDataHelper.add_se_command(particle, keyframe, new_file, new_volume, new_pitch)
            @components[:particle_list].change_particle_commands(particle_index)
            @components[:play_controls].duration = @components[:particle_list].duration
            refresh_component(:se_pane)
          end
        end
      when :delete   # Button
        particle = @anim[:particles][particle_index]
        list = @components[:se_pane].get_control(:list)
        old_file = list.value
        if old_file
          AnimationEditor::ParticleDataHelper.delete_se_command(particle, keyframe, old_file)
          @components[:particle_list].change_particle_commands(particle_index)
          @components[:play_controls].duration = @components[:particle_list].duration
          refresh_component(:se_pane)
        end
      else
#        particle = @anim[:particles][particle_index]
      end
    when :particle_pane
      case property
      when :graphic   # Button
        p_index = particle_index
        new_file = choose_graphic_file(@anim[:particles][p_index][:graphic])
        if @anim[:particles][p_index][:graphic] != new_file
          @anim[:particles][p_index][:graphic] = new_file
          refresh_component(:particle_pane)
          # TODO: refresh_component(:canvas)
        end
      else
        particle = @anim[:particles][particle_index]
        new_cmds = AnimationEditor::ParticleDataHelper.set_property(particle, property, value)
        @components[:particle_list].change_particle(particle_index)
        refresh_component(:particle_pane)
      end
    when :keyframe_pane
      # TODO: Stuff here once I decide what controls to add.
    when :particle_list
#      refresh if keyframe != old_keyframe || particle_index != old_particle_index
      # TODO: Lots of stuff here.
    when :play_controls
      # TODO: Will the play controls ever signal themselves as changed? I don't
      #       think so.
    end
  end

  def update
    old_keyframe = keyframe
    old_particle_index = particle_index
    @components.each_pair do |sym, component|
      next if @captured && @captured != sym
      next if !component.visible
      component.update
      @captured = sym if component.busy?
      if component.changed?
        if sym == :particle_list
          refresh if keyframe != old_keyframe || particle_index != old_particle_index
        end
        if component.respond_to?("values")
          # TODO: Make undo/redo snapshot.
          values = component.values
          values.each_pair do |property, value|
            apply_changed_value(sym, property, value)
          end
        end
        component.clear_changed
      end
      component.repaint if sym == :particle_list || sym == :menu_bar
      if @captured
        @captured = nil if !component.busy?
        break
      end
    end
  end

  #-----------------------------------------------------------------------------

  def run
    Input.text_input = false
    loop do
      # TODO: Do we need to check for Input.text_input? I think just checking
      #       @captured != nil will suffice.
      inputting_text = Input.text_input
      Graphics.update
      Input.update
      update
      if !inputting_text && @captured.nil? && @quit
        case message(_INTL("Do you want to save changes to the animation?"),
                     [:yes, _INTL("Yes")], [:no, _INTL("No")], [:cancel, _INTL("Cancel")])
        when :yes
          save
        when :cancel
          @quit = false
        end
        break if @quit
      end
    end
    dispose
  end
end
