#===============================================================================
#
#===============================================================================
class AnimationEditor::ListedParticle < UIControls::BaseContainer
  def create_list_sprite(row)
    return @rows[row][LIST_SPRITE] if @rows[row][LIST_SPRITE]
    spr_width = @list_viewport.rect.width
    spr_height = ROW_HEIGHT + ROW_SPACING
    sprite = BitmapSprite.new(spr_width, spr_height, @list_viewport)
    sprite.bitmap.font.color = get_color_of(:text)
    sprite.bitmap.font.size = text_size
    @rows[row][LIST_SPRITE] = sprite
    return sprite
  end

  def draw_list_sprite(row)
    sprite = create_list_sprite(row)
    sprite.bitmap.clear
    group = group_for_row(row)   # Could be a group or :main or nil
    level = 2   # Property
    arrow = 0   # 0 = no arrow, 1 = collapsed arrow, 2 = expanded arrow
    arrow_level = 0   # No arrow
    draw_box = true
    bg_color = get_color_of(:property_background)
    text = "Unnamed"
    groups = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
    if row == :main
      level = 0
      if @particle[:name] == "SE"
        bg_color = get_color_of(:se_background)
      else
        arrow = @groups_expanded[row] ? 2 : 1
        bg_color = focus_color(@particle[:focus])
      end
      text = @particle[:name] || "Unnamed"
    elsif groups.keys.include?(row)
      level = 1
      arrow = @groups_expanded[row] ? 2 : 1
      draw_box = false
      text = group_name(row)
    elsif groups[:main] && groups[:main].include?(row)   # Properties
      # Treated as level 2
      text = GameData::Animation.property_display_name(row) + ":"
    else   # Properties
      text = GameData::Animation.property_display_name(row) + ":"
    end
    box_x = LIST_BOX_TOP_LEVEL_X + (LIST_BOX_INDENT_X * level)
    # Draw box
    if draw_box
      sprite.bitmap.outline_rect(box_x, 0, sprite.width - box_x, ROW_HEIGHT, bg_color, 2)
    end
    # Draw text
    text_x = box_x
    text_x += 5 if draw_box   # 2 for box's thickness + 3 for padding
    draw_text(sprite.bitmap, text_x, UIControls::BaseControl::TEXT_OFFSET_Y, text)
    # Draw tree lines and arrow
    draw_list_sprite_tree(row, group, level, arrow, sprite)
  end

  def draw_list_sprite_tree(row, group, level, arrow, sprite)
    return if @particle[:name] == "SE"
    line_color = get_color_of(:property_background)
    top_level_x = (LIST_BOX_TOP_LEVEL_X - 1) / 2   # 9
    upper_seg_height = ROW_HEIGHT / 2   # 12
    lower_seg_height = FULL_ROW_HEIGHT - upper_seg_height   # 13
    groups = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
    # Top level vertical line
    if !group || group != groups.keys.last
      # Top level top half of vertical line
      if row != :main
        sprite.bitmap.fill_rect(top_level_x, 0,
                                1, upper_seg_height, line_color)
      end
      # Top level bottom half of vertical line
      if row != groups.keys.last && (group || @groups_expanded[:main])
        sprite.bitmap.fill_rect(top_level_x, upper_seg_height,
                                1, lower_seg_height, line_color)
      end
    end
    # Second level vertical line
    if row != :main
      if group && group != :main
        # Second level top half of vertical line
        sprite.bitmap.fill_rect(top_level_x + LIST_BOX_INDENT_X, 0,
                                1, upper_seg_height, line_color)
      end
      if (groups.has_key?(row) && @groups_expanded[row]) ||
         (group && group != :main && row != groups[group].last)
        # Second level bottom half of vertical line
        sprite.bitmap.fill_rect(top_level_x + LIST_BOX_INDENT_X, upper_seg_height,
                                1, lower_seg_height, line_color)
      end
    end
    # Horizontal line
    if row != :main
      if groups.has_key?(row)   # Group
        sprite.bitmap.fill_rect(top_level_x, upper_seg_height - 1,
                                LIST_BOX_INDENT_X + 1, 1, line_color)
      else   # Property
        start_x = top_level_x
        start_x += LIST_BOX_INDENT_X if group != :main
        box_x = LIST_BOX_TOP_LEVEL_X + (LIST_BOX_INDENT_X * level)
        sprite.bitmap.fill_rect(start_x, upper_seg_height - 1,
                                box_x - start_x - 1, 1, line_color)
      end
    end
  end

  #-----------------------------------------------------------------------------

  def create_list_expand_arrow(row)
    return if @particle[:name] == "SE"
    return if @rows[row][LIST_ARROW]
    groups = (is_emitter?) ? EMITTER_PROPERTY_GROUPS : PROPERTY_GROUPS
    return if row != :main && !groups.has_key?(row)
    ctrl = UIControls::ClickableBitmap.new(@list_viewport, @bitmaps[:collapsed_arrow], @bitmaps[:expanded_arrow])
    ctrl.x = (LIST_BOX_TOP_LEVEL_X - LIST_ARROW_SIZE) / 2
    ctrl.x += LIST_BOX_INDENT_X if row != :main && groups.has_key?(row)
    ctrl.z = 1
    ctrl.color_scheme = @color_scheme
    ctrl.set_interactive_rects
    @rows[row][LIST_ARROW] = ctrl
  end

  #-----------------------------------------------------------------------------

  def create_list_control(row)
    return if @rows[row][LIST_CONTROL]
    return if !row_is_property?(row) && row != :main
    ctrl = nil
    ctrl_width = AnimationEditor::Timeline::LIST_WIDTH - CONTROL_X - 2
    ctrl_height = ROW_HEIGHT
    case row
    when :main   # Particle properties
      if @particle[:name] == "SE"
        ctrl = UIControls::SEPicker.new(ctrl_width, ctrl_height, @list_viewport, [])
        ctrl.x = AnimationEditor::Timeline::LIST_WIDTH - UIControls::SEPicker::BUTTON_WIDTH - 2
      else
        ctrl = UIControls::BitmapButton.new(@list_viewport, @bitmaps[:properties])
        ctrl.x = AnimationEditor::Timeline::LIST_WIDTH - PROPERTIES_BUTTON_SIZE - 2
      end
      ctrl.y = (ROW_HEIGHT - PROPERTIES_BUTTON_SIZE) / 2
      ctrl.z = 1
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @rows[row][LIST_CONTROL] = ctrl
      return
    when :x, :y, :r, :theta, :z, :zoom_x, :zoom_y, :angle, :opacity, :frame,
         :x2, :y2, :z2, :zoom_x2, :zoom_y2, :angle2, :opacity2, :frame2,
         :mask_opacity, :mask_x, :mask_y, :mask_zoom_x, :mask_zoom_y,
         :emit_x, :emit_y, :emit_r, :emit_theta,
         :emit_x_range, :emit_y_range, :emit_r_range, :emit_theta_range,
         :emit_speed, :emit_speed_range,
         :emit_direction, :emit_direction_range,
         :emit_gravity, :emit_gravity_range,
         :emit_period_x, :emit_period_x_range,
         :emit_period_y, :emit_period_y_range,
         :emit_period_z, :emit_period_z_range,
         :emit_radius_x_range, :emit_radius_y_range, :emit_radius_z_range,
         :emit_x_multiplier, :emit_y_multiplier,
         :emit_zoom_multiplier,
         :emit_zoom_range, :emit_zoom_x_range, :emit_zoom_y_range,
         :emit_opacity_multiplier,
         :radius_x, :radius_y, :radius_z
      vals = AnimationEditor::PROPERTY_RANGES[row] || [0, 0]
      default = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[row] || 0
      ctrl = UIControls::FittedNumberTextBox.new(ctrl_width, ctrl_height, @list_viewport, *vals, default)
    when :flip, :flip2, :invert_color, :invert_color2, :emitting, :emit_clockwise
      default = GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[row] || false
      ctrl = UIControls::Checkbox.new(ctrl_width, ctrl_height, @list_viewport, default)
    when :visible
      ctrl = UIControls::Checkbox.new(ctrl_width, ctrl_height, @list_viewport, true)
    when :color, :color2
      ctrl = UIControls::ColorPicker.new(ctrl_width, ctrl_height, @list_viewport,
                                         GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:color])
    when :tone, :tone2
      ctrl = UIControls::TonePicker.new(ctrl_width, ctrl_height, @list_viewport,
                                        GameData::Animation::PARTICLE_KEYFRAME_DEFAULT_VALUES[:tone])
    when :blending, :blending2, :mask_blending
      vals = {
        0 => _INTL("None"),
        1 => _INTL("Add"),
        2 => _INTL("Sub")
      }
      ctrl = UIControls::DropdownList.new(ctrl_width, ctrl_height, @list_viewport, vals, 0)
    else
      raise _INTL("Couldn't decide what kind of control to make for property {1}.", row)
    end
    if ctrl
      ctrl.x = CONTROL_X
      ctrl.z = 1
      ctrl.color_scheme = @color_scheme
      ctrl.set_interactive_rects
      @rows[row][LIST_CONTROL] = ctrl
    end
  end

  #-----------------------------------------------------------------------------

  # NOTE: Despite being able to have arbitrarily long animations, the timeline
  #       sprite is only ever as wide as its visible part. Instead of the
  #       viewport's ox being shifted depending on the horizontal scrollbar's
  #       position, the contents of all the timeline sprites are redrawn each
  #       time that scrollbar is moved.
  def create_timeline_bg_sprite(row)
    return @rows[row][COMMAND_BG_SPRITE] if @rows[row][COMMAND_BG_SPRITE]
    spr_width = @timeline_bg_viewport.rect.width
    spr_height = ROW_HEIGHT
    sprite = BitmapSprite.new(spr_width, spr_height, @timeline_bg_viewport)
    sprite.bitmap.font.color = get_color_of(:text)
    sprite.bitmap.font.size = text_size
    @rows[row][COMMAND_BG_SPRITE] = sprite
    return sprite
  end

  def draw_timeline_bg_sprite(row)
    return if (PROPERTY_GROUPS.has_key?(row) || EMITTER_PROPERTY_GROUPS.has_key?(row)) && row != :main
    sprite = create_timeline_bg_sprite(row)
    sprite.bitmap.clear
    keyframe_spacing = AnimationEditor::Timeline::KEYFRAME_SPACING
    # Get the background colors
    bg_color = get_color_of(:property_background)
    outline_color = (@particle[:name] == "SE") ? get_color_of(:se_background) : focus_color(@particle[:focus])
    if row == :main
      bg_color = outline_color
      outline_color = get_color_of(:line)
    end
    # Get visibilities of particle for each keyframe
    visible_cmds = @visibilities
    visible_cmds = @emitter_visibilities if is_emitter? && PROPERTY_GROUPS.has_key?(group_for_row(row))
    # Draw background for visible parts of the particle, one keyframe at a time
    each_visible_keyframe do |i|
      draw_x = TIMELINE_LEFT_SPACING + (i * keyframe_spacing) - @timeline_ox
      # Draw bg
      if i < @duration && visible_cmds[i] == 1
        sprite.bitmap.fill_rect(draw_x, 0, keyframe_spacing, ROW_HEIGHT, bg_color)
      end
      next if i >= @duration
      # Draw outlines
      case visible_cmds[i]
      when 1   # Particle is visible
        # Top edge
        sprite.bitmap.fill_rect(draw_x, 0, keyframe_spacing, 1, outline_color)
        # Bottom edge
        sprite.bitmap.fill_rect(draw_x, ROW_HEIGHT - 1, keyframe_spacing, 1, outline_color)
        # Left edge
        if i <= 0 || visible_cmds[i - 1] != 1
          sprite.bitmap.fill_rect(draw_x, 0, 1, ROW_HEIGHT, outline_color)
        end
        # Right edge
        if i == @duration - 1 || (i < @duration - 1 && visible_cmds[i + 1] != 1)
          sprite.bitmap.fill_rect(draw_x + keyframe_spacing, 0, 1, ROW_HEIGHT, outline_color)
        end
      when 2   # Particle is an emitter and delays its particles into this frame
        next if row != :main
        # Draw dotted outline
        keyframe_spacing.times do |j|
          next if j.odd?
          # Top edge
          sprite.bitmap.fill_rect(draw_x + j, 0, 1, 1, outline_color)
          # Bottom edge
          sprite.bitmap.fill_rect(draw_x + j, ROW_HEIGHT - 1, 1, 1, outline_color)
        end
        ROW_HEIGHT.times do |j|
          next if j.odd?
          # Left edge
          if i <= 0 || visible_cmds[i - 1] != 2
            sprite.bitmap.fill_rect(draw_x, j, 1, 1, outline_color)
          end
          # Right edge
          if i == @duration - 1 || (i < @duration - 1 && visible_cmds[i + 1] != 2)
            sprite.bitmap.fill_rect(draw_x + keyframe_spacing, j, 1, 1, outline_color)
          end
        end
      end
    end
  end

  #-----------------------------------------------------------------------------

  # NOTE: Despite being able to have arbitrarily long animations, the timeline
  #       sprite is only ever as wide as its visible part. Instead of the
  #       viewport's ox being shifted depending on the horizontal scrollbar's
  #       position, the contents of all the timeline sprites are redrawn each
  #       time that scrollbar is moved.
  def create_timeline_sprite(row)
    return @rows[row][COMMAND_SPRITE] if @rows[row][COMMAND_SPRITE]
    spr_width = @timeline_viewport.rect.width
    spr_height = ROW_HEIGHT
    sprite = BitmapSprite.new(spr_width, spr_height, @timeline_viewport)
    sprite.bitmap.font.color = get_color_of(:text)
    sprite.bitmap.font.size = text_size
    @rows[row][COMMAND_SPRITE] = sprite
    return sprite
  end

  def draw_timeline_sprite(row)
    sprite = create_timeline_sprite(row)
    sprite.bitmap.clear
    cmds = commands_for_row(row)
    return if !cmds || cmds.empty?
    diamond_color = get_color_of(:text)
    diamond_move_color = get_color_of(:background)
    interp_color = get_color_of(:text)
    keyframe_spacing = AnimationEditor::Timeline::KEYFRAME_SPACING
    first_keyframe = -1
    # Draw command diamonds and interpolation lines
    each_visible_keyframe do |i|
      first_keyframe = i if first_keyframe < 0
      next if !cmds[i]
      draw_x = TIMELINE_LEFT_SPACING + (i * keyframe_spacing) - @timeline_ox
      # Draw command diamonds
      sprite.bitmap.fill_diamond(draw_x, ROW_HEIGHT / 2, DIAMOND_SIZE, diamond_color)
      if @command_move_current && row == @command_move_start[0] && i == @command_move_current
        sprite.bitmap.fill_diamond(draw_x, ROW_HEIGHT / 2, DIAMOND_SIZE - 1, diamond_move_color)
      end
      # Draw interpolation lines between command diamonds
      if cmds[i][0] != 0 && cmds[i][1] != :none   # [duration, interp_type]
        sprite.bitmap.draw_interpolation_line(
          draw_x + DIAMOND_SIZE + 2,
          INTERP_LINE_Y,
          (cmds[i][0].abs * keyframe_spacing) - ((DIAMOND_SIZE * 2) + 3),
          INTERP_LINE_HEIGHT,
          cmds[i][0] > 0,   # Increases or decreases
          cmds[i][1],       # Interpolation type
          interp_color
        )
      end
    end
    # Draw any interpolation lines that start before the first visible keyframe
    if first_keyframe > 0
      (0...first_keyframe).each do |i|
        next if !cmds[i] || !cmds[i].is_a?(Array)
        next if i + cmds[i][0].abs < first_keyframe
        draw_x = TIMELINE_LEFT_SPACING + (i * keyframe_spacing) - @timeline_ox
        sprite.bitmap.draw_interpolation_line(
          draw_x + DIAMOND_SIZE + 2,
          INTERP_LINE_Y,
          (cmds[i][0].abs * keyframe_spacing) - ((DIAMOND_SIZE * 2) + 3),
          INTERP_LINE_HEIGHT,
          cmds[i][0] > 0,   # Increases or decreases
          cmds[i][1],       # Interpolation type
          interp_color
        )
      end
    end
  end

end
