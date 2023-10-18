#===============================================================================
# TODO: Would be nice to make command sprites wider than their viewport and
#       change @commands_viewport's ox to @left_pos, similar to how the vertical
#       scrollbar works, i.e. every visible @commands_sprites isn't redrawn each
#       time the horizontal scrollbar changes.
#===============================================================================
class UIControls::AnimationParticleList < UIControls::BaseControl
  LIST_WIDTH           = 150
  ROW_HEIGHT           = 24
  TIMELINE_HEIGHT      = 24
  DIAMOND_SIZE         = 3
  TIMELINE_LEFT_BUFFER = DIAMOND_SIZE + 1   # Allows diamonds at keyframe 0 to be drawn fully
  TIMELINE_TEXT_SIZE   = 16
  KEYFRAME_SPACING     = 20
  INTERP_LINE_HEIGHT   = KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3)
  INTERP_LINE_Y        = (TIMELINE_HEIGHT / 2) - (INTERP_LINE_HEIGHT / 2)
  DURATION_BUFFER      = 20   # Extra keyframes shown after the animation's end
  CONTROL_BG_COLORS    = {
    :user            => Color.new(96, 248, 96),   # Green
    :target          => Color.new(248, 96, 96),   # Red
    :user_and_target => Color.new(248, 248, 96),   # Yellow
    :screen          => Color.new(128, 160, 248)   # Blue
  }
  SE_CONTROL_BG        = Color.gray

  attr_reader :keyframe   # The selected keyframe
  attr_reader :particle_index   # Index in @particles

  def initialize(x, y, width, height, viewport)
    super(width, height, viewport)
    self.x = x
    self.y = y
    draw_control_background
    # Create viewports
    @list_viewport = Viewport.new(
      x, y + TIMELINE_HEIGHT, LIST_WIDTH, height - TIMELINE_HEIGHT - UIControls::Scrollbar::SLIDER_WIDTH - 1
    )
    @list_viewport.z = self.viewport.z + 1
    @commands_bg_viewport = Viewport.new(@list_viewport.rect.x + LIST_WIDTH, @list_viewport.rect.y,
                                      width - @list_viewport.rect.width - UIControls::Scrollbar::SLIDER_WIDTH,
                                      @list_viewport.rect.height)
    @commands_bg_viewport.z = self.viewport.z + 1
    @position_viewport = Viewport.new(@list_viewport.rect.x + LIST_WIDTH, y, @commands_bg_viewport.rect.width, height)
    @position_viewport.z = self.viewport.z + 2
    @commands_viewport = Viewport.new(@list_viewport.rect.x + LIST_WIDTH, @list_viewport.rect.y,
                                      width - @list_viewport.rect.width - UIControls::Scrollbar::SLIDER_WIDTH,
                                      @list_viewport.rect.height)
    @commands_viewport.z = self.viewport.z + 3
    # Create scrollbar
    @list_scrollbar = UIControls::Scrollbar.new(
      @commands_viewport.rect.x + @commands_viewport.rect.width, @commands_viewport.rect.y,
      @commands_viewport.rect.height + 1, self.viewport, false, true
    )
    @list_scrollbar.set_interactive_rects
    @time_scrollbar = UIControls::Scrollbar.new(
      @commands_viewport.rect.x, @commands_viewport.rect.y + @commands_viewport.rect.height + 1,
      @commands_viewport.rect.width, self.viewport, true, true
    )
    @time_scrollbar.set_interactive_rects
    # Timeline bitmap sprite
    @timeline_sprite = BitmapSprite.new(@commands_viewport.rect.width, TIMELINE_HEIGHT, self.viewport)
    @timeline_sprite.x = @commands_viewport.rect.x
    @timeline_sprite.y = self.y
    @timeline_sprite.bitmap.font.color = TEXT_COLOR
    @timeline_sprite.bitmap.font.size = TIMELINE_TEXT_SIZE
    # Position line sprite
    @position_sprite = BitmapSprite.new(3, height - UIControls::Scrollbar::SLIDER_WIDTH - 1, @position_viewport)
    @position_sprite.ox = @position_sprite.width / 2
    @position_sprite.bitmap.fill_rect(0, 0, @position_sprite.bitmap.width, @position_sprite.bitmap.height, Color.red)
    # List sprites and commands sprites
    @list_sprites = []
    @commands_bg_sprites = []
    @commands_sprites = []
    # Scrollbar positions
    @left_pos = 0
    @top_pos = 0
    @duration = 0
    # Selected things
    @keyframe = 0
    @particle_index = 0
    # Particle information to display (one row each)
    @particles = []   # Reference to particle data from the editor scene
    @particle_list = []   # Each element is index in @particles or [index, property]
    @visibilities = []   # Per particle
    @commands = {}
  end

  def draw_control_background
    self.bitmap.clear
    # Background
    self.bitmap.fill_rect(0, 0, width, height, Color.white)
    # Separator lines
    self.bitmap.fill_rect(0, TIMELINE_HEIGHT - 1, width, 1, Color.black)
    self.bitmap.fill_rect(LIST_WIDTH - 1, 0, 1, height, Color.black)
    self.bitmap.fill_rect(0, height - UIControls::Scrollbar::SLIDER_WIDTH - 1, width, 1, Color.black)
    self.bitmap.fill_rect(width - UIControls::Scrollbar::SLIDER_WIDTH - 1, 0, 1, height, Color.black)
  end

  def dispose_listed_sprites
    @list_sprites.each { |p| p&.dispose }
    @list_sprites.clear
    @commands_bg_sprites.each { |p| p&.dispose }
    @commands_bg_sprites.clear
    @commands_sprites.each { |p| p&.dispose }
    @commands_sprites.clear
  end

  def dispose
    @list_scrollbar.dispose
    @time_scrollbar.dispose
    @timeline_sprite.dispose
    @position_sprite.dispose
    dispose_listed_sprites
    @list_viewport.dispose
    @commands_bg_viewport.dispose
    @commands_viewport.dispose
  end

  def left_pos=(val)
    old_val = @left_pos
    total_width = (@duration * KEYFRAME_SPACING) + TIMELINE_LEFT_BUFFER + 1
    if total_width <= @commands_viewport.rect.width
      @left_pos = 0
    else
      @left_pos = val
      @left_pos = @left_pos.clamp(0, total_width - @commands_viewport.rect.width)
    end
    if @left_pos != old_val
      refresh_position_line
      invalidate_time
    end
  end

  def top_pos=(val)
    old_val = @top_pos
    total_height = @particle_list.length * ROW_HEIGHT
    if total_height <= @list_viewport.rect.height
      @top_pos = 0
    else
      @top_pos = val
      @top_pos = @top_pos.clamp(0, total_height - @list_viewport.rect.height)
    end
    @list_viewport.oy = @top_pos
    @commands_viewport.oy = @top_pos
    if @top_pos != old_val
      invalidate_rows
      @old_top_pos = old_val
    end
  end

  def set_particles(particles)
    @particles = particles
    @particle_list.clear
    calculate_all_commands_and_durations
    # Dispose of and clear all existing list/commands sprites
    dispose_listed_sprites
    # Fill in @particle_list with indices from @particles
    @particles.length.times { |i| @particle_list.push(i) }
    # Create new sprites for each particle (1x list and 2x commands)
    @particle_list.length.times do
      list_sprite = BitmapSprite.new(@list_viewport.rect.width, ROW_HEIGHT, @list_viewport)
      list_sprite.y = @list_sprites.length * ROW_HEIGHT
      list_sprite.bitmap.font.color = TEXT_COLOR
      list_sprite.bitmap.font.size = TEXT_SIZE
      @list_sprites.push(list_sprite)
      commands_bg_sprite = BitmapSprite.new(@commands_viewport.rect.width, ROW_HEIGHT, @commands_bg_viewport)
      commands_bg_sprite.y = @commands_bg_sprites.length * ROW_HEIGHT
      commands_bg_sprite.bitmap.font.color = TEXT_COLOR
      commands_bg_sprite.bitmap.font.size = TEXT_SIZE
      @commands_bg_sprites.push(commands_bg_sprite)
      commands_sprite = BitmapSprite.new(@commands_viewport.rect.width, ROW_HEIGHT, @commands_viewport)
      commands_sprite.y = @commands_sprites.length * ROW_HEIGHT
      commands_sprite.bitmap.font.color = TEXT_COLOR
      commands_sprite.bitmap.font.size = TEXT_SIZE
      @commands_sprites.push(commands_sprite)
    end
    @list_scrollbar.range = @particle_list.length * ROW_HEIGHT
    @time_scrollbar.range = (@duration * KEYFRAME_SPACING) + TIMELINE_LEFT_BUFFER + 1
    self.left_pos = @left_pos
    invalidate
  end

  def set_interactive_rects
    @list_rect = Rect.new(0, TIMELINE_HEIGHT, LIST_WIDTH - 1, @list_viewport.rect.height)
    @timeline_rect = Rect.new(LIST_WIDTH, 0, width - LIST_WIDTH - UIControls::Scrollbar::SLIDER_WIDTH - 1, TIMELINE_HEIGHT - 1)
    @commands_rect = Rect.new(LIST_WIDTH, TIMELINE_HEIGHT, @timeline_rect.width, @list_rect.height)
    @interactions = {
      :list => @list_rect,
      :timeline => @timeline_rect,
      :commands => @commands_rect
    }
  end

  #-----------------------------------------------------------------------------

  def invalid?
    return @invalid || @invalid_time || @invalid_rows || @invalid_commands
  end

  def invalidate_time
    @invalid_time = true
  end

  def invalidate_rows
    @invalid_rows = true
  end

  def invalidate_commands
    @invalid_commands = true
  end

  def validate
    super
    @invalid_time = false
    @invalid_rows = false
    @invalid_commands = false
  end

  #-----------------------------------------------------------------------------

  def calculate_duration
    @duration = AnimationEditor::ParticleDataHelper.get_duration(@particles)
    @duration += DURATION_BUFFER
  end

  # TODO: Call this only from set_particles and when changes are made to
  #       @particles by the main editor scene. If we can be specific about which
  #       particle was changed, recalculate only that particle's commands.
  def calculate_all_commands_and_durations
    calculate_duration
    @commands = {}
    @particles.each_with_index do |particle, i|
      overall_commands = []
      particle.each_pair do |property, value|
        next if !value.is_a?(Array)
        cmds = AnimationEditor::ParticleDataHelper.get_particle_property_commands_timeline(value, property)
        @commands[[i, property]] = cmds
        cmds.each_with_index do |cmd, j|
          next if !cmd
          overall_commands[j] = (cmd.is_a?(Array)) ? cmd.clone : cmd
        end
      end
      @commands[i] = overall_commands
    end
    # Calculate visibilities for every keyframe
    @particles.each_with_index do |particle, i|
      @visibilities[i] = AnimationEditor::ParticleDataHelper.get_timeline_particle_visibilities(
        particle, @duration - DURATION_BUFFER
      )
    end
  end

  # TODO: Methods that will show/hide individual property rows for a given
  #       @particles index.

  def each_visible_keyframe(early_start = false)
    full_width = @commands_viewport.rect.width
    start_keyframe = ((@left_pos - TIMELINE_LEFT_BUFFER) / KEYFRAME_SPACING)
    start_keyframe = 0 if start_keyframe < 0
    start_keyframe -= 1 if early_start && start_keyframe > 0   # For drawing long timestamps
    end_keyframe = (@left_pos + full_width / KEYFRAME_SPACING)
    (start_keyframe..end_keyframe).each { |i| yield i }
  end

  def each_visible_particle
    full_height = @list_viewport.rect.height
    start_row = @top_pos / ROW_HEIGHT
    end_row = (@top_pos + full_height) / ROW_HEIGHT
    if @old_top_pos
      old_start_row = @old_top_pos / ROW_HEIGHT
      old_end_row = (@old_top_pos + full_height) / ROW_HEIGHT
      (start_row..end_row).each { |i| yield i if !(old_start_row..old_end_row).include?(i) }
    else
      (start_row..end_row).each { |i| yield i }
    end
  end

  #-----------------------------------------------------------------------------

  def property_display_name(property)
    return {
      :graphic  => "Graphic",
      :frame    => "Graphic frame",
      :blending => "Blending",
      :flip     => "Flip",
      :x        => "X",
      :y        => "Y",
      :zoom_x   => "Zoom X",
      :zoom_y   => "Zoom Y",
      :angle    => "Angle",
      :visible  => "Visible",
      :opacity  => "Opacity"
    }[property] || "Unnamed property"
  end

  def repaint
    @list_scrollbar.repaint if @list_scrollbar.invalid?
    @time_scrollbar.repaint if @time_scrollbar.invalid?
    super if invalid?
  end

  def refresh_timeline
    @timeline_sprite.bitmap.clear
    # Draw hover highlight
    hover_color = nil
    if @captured_keyframe && !@captured_row
      if @hover_keyframe && @hover_keyframe == @captured_keyframe && !@hover_row
        hover_color = HOVER_COLOR
      else
        hover_color = CAPTURE_COLOR
      end
      draw_x = TIMELINE_LEFT_BUFFER + (@captured_keyframe * KEYFRAME_SPACING) - @left_pos
      @timeline_sprite.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 0,
                                        KEYFRAME_SPACING, TIMELINE_HEIGHT - 1, hover_color)
    elsif !@captured_keyframe && !@captured_row && @hover_keyframe && !@hover_row
      hover_color = HOVER_COLOR
      draw_x = TIMELINE_LEFT_BUFFER + (@hover_keyframe * KEYFRAME_SPACING) - @left_pos
      @timeline_sprite.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 0,
                                        KEYFRAME_SPACING, TIMELINE_HEIGHT - 1, hover_color)
    end
    # Draw timeline markings
    each_visible_keyframe(true) do |i|
      draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
      line_height = 6
      if (i % 20) == 0
        line_height = TIMELINE_HEIGHT - 2
      elsif (i % 5) == 0
        line_height = TIMELINE_HEIGHT / 2
      end
      @timeline_sprite.bitmap.fill_rect(draw_x, TIMELINE_HEIGHT - line_height, 1, line_height, TEXT_COLOR)
      draw_text(@timeline_sprite.bitmap, draw_x + 1, 0, (i / 20.0).to_s) if (i % 5) == 0
    end
  end

  def refresh_position_line
    @position_sprite.visible = (@keyframe && @keyframe >= 0)
    if @keyframe >= 0
      @position_sprite.x = TIMELINE_LEFT_BUFFER + (@keyframe * KEYFRAME_SPACING) - @left_pos
    end
  end

  # TODO: Add indicator that this is selected (if so).
  def refresh_particle_list_sprite(index)
    spr = @list_sprites[index]
    return if !spr
    spr.bitmap.clear
    # Get the background color
    p_index = (@particle_list[index].is_a?(Array)) ? @particle_list[index][0] : @particle_list[index]
    particle_data = @particles[p_index]
    if particle_data[:name] == "SE"
      bg_color = SE_CONTROL_BG
    else
      bg_color = CONTROL_BG_COLORS[@particles[@particle_list[index][0]][:focus]] || Color.magenta
    end
    # Draw hover highlight
    hover_color = nil
    if @captured_row && !@captured_keyframe
      if @captured_row == index
        if @hover_row && @hover_row == index && !@hover_keyframe
          hover_color = HOVER_COLOR
        else
          hover_color = CAPTURE_COLOR
        end
      end
    elsif !@captured_row && !@captured_keyframe && @hover_row && @hover_row == index && !@hover_keyframe
      hover_color = HOVER_COLOR
    end
    spr.bitmap.fill_rect(0, 1, spr.width - 1, spr.height - 1, hover_color) if hover_color
    # Draw outline
    spr.bitmap.outline_rect(0, 1, spr.width - 1, spr.height - 1, bg_color, 2)
    # Draw text
    if @particle_list[index].is_a?(Array)
      draw_text(spr.bitmap, 3 + 40, 3, property_display_name(@particle_list[index][1]))
    else
      draw_text(spr.bitmap, 3, 3, @particles[p_index][:name] || "Unnamed")
    end
  end

  def refresh_particle_commands_bg_sprites(index)
    bg_spr = @commands_bg_sprites[index]
    return if !bg_spr
    bg_spr.bitmap.clear
    p_index = (@particle_list[index].is_a?(Array)) ? @particle_list[index][0] : @particle_list[index]
    particle_data = @particles[p_index]
    # Get the background color
    if particle_data[:name] == "SE"
      bg_color = SE_CONTROL_BG
    else
      bg_color = CONTROL_BG_COLORS[@particles[@particle_list[index][0]][:focus]] || Color.magenta
    end
    # Get visibilities of particle for each keyframe
    visible_cmds = @visibilities[p_index]
    # Draw background for visible parts of the particle
    each_visible_keyframe do |i|
      draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
      # Draw bg
      if i < @duration - DURATION_BUFFER && (particle_data[:name] == "SE" || visible_cmds[i])
        bg_spr.bitmap.fill_rect(draw_x, 1, KEYFRAME_SPACING, ROW_HEIGHT - 2, bg_color)
      end
      # Draw hover highlight
      hover_color = nil
      if @captured_row && @captured_keyframe
        if @captured_row == index && @captured_keyframe == i
          if @hover_row && @hover_row == index && @hover_keyframe && @hover_keyframe == i
            hover_color = HOVER_COLOR
          else
            hover_color = CAPTURE_COLOR
          end
        end
      elsif !@captured_row && !@captured_keyframe &&
            @hover_row && @hover_row == index && @hover_keyframe && @hover_keyframe == i
        hover_color = HOVER_COLOR
      end
      bg_spr.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 2, KEYFRAME_SPACING, ROW_HEIGHT - 3, hover_color) if hover_color
      next if i >= @duration - DURATION_BUFFER
      next if particle_data[:name] != "SE" && !visible_cmds[i]
      # Draw outline
      bg_spr.bitmap.fill_rect(draw_x, 1, KEYFRAME_SPACING, 1, Color.black)   # Top
      bg_spr.bitmap.fill_rect(draw_x, ROW_HEIGHT - 1, KEYFRAME_SPACING, 1, Color.black)   # Bottom
      if i <= 0 || (particle_data[:name] != "SE" && !visible_cmds[i - 1])
        bg_spr.bitmap.fill_rect(draw_x, 1, 1, ROW_HEIGHT - 1, Color.black)   # Left
      end
      if i == @duration - DURATION_BUFFER - 1 || (particle_data[:name] != "SE" && i < @duration - 1 && !visible_cmds[i + 1])
        bg_spr.bitmap.fill_rect(draw_x + KEYFRAME_SPACING, 1, 1, ROW_HEIGHT - 1, Color.black)   # Right
      end
    end
  end

  def refresh_particle_commands_sprite(index)
    spr = @commands_sprites[index]
    return if !spr
    spr.bitmap.clear
    cmds = @commands[@particle_list[index]]
    return if !cmds
    # Draw command diamonds
    first_keyframe = -1
    each_visible_keyframe do |i|
      first_keyframe = i if first_keyframe < 0
      next if !cmds[i]
      draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
      # Draw command diamond
      spr.bitmap.fill_diamond(draw_x, TIMELINE_HEIGHT / 2, DIAMOND_SIZE, TEXT_COLOR)
      # Draw interpolation line
      if cmds[i].is_a?(Array)
        spr.bitmap.draw_interpolation_line(
          draw_x + DIAMOND_SIZE + 2,
          INTERP_LINE_Y,
          cmds[i][0].abs * KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3),
          INTERP_LINE_HEIGHT,
          cmds[i][0] > 0,   # Increases or decreases
          cmds[i][1],       # Interpolation type
          TEXT_COLOR
        )
      end
    end
    # Draw any interpolation lines that start before the first visible keyframe
    if first_keyframe > 0
      (0...first_keyframe).each do |i|
        next if !cmds[i] || !cmds[i].is_a?(Array)
        next if i + cmds[i][0].abs < first_keyframe
        draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
        spr.bitmap.draw_interpolation_line(
          draw_x + DIAMOND_SIZE + 2,
          INTERP_LINE_Y,
          cmds[i][0].abs * KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3),
          INTERP_LINE_HEIGHT,
          cmds[i][0] > 0,   # Increases or decreases
          cmds[i][1],       # Interpolation type
          TEXT_COLOR
        )
      end
    end
  end

  def refresh
    draw_area_highlight
    refresh_timeline if @invalid || @invalid_time
    each_visible_particle do |i|
      refresh_particle_list_sprite(i) if @invalid || @invalid_rows
      refresh_particle_commands_bg_sprites(i)
      refresh_particle_commands_sprite(i)
    end
    @old_top_pos = nil   # For refreshing only rows that became visible via using vertical scrollbar
  end

  # Does nothing, because area highlights are drawn in other sprites rather than
  # this one.
  def draw_area_highlight; end

  #-----------------------------------------------------------------------------

  def get_interactive_element_at_mouse
    ret = nil
    mouse_x, mouse_y = mouse_pos
    return ret if !mouse_x || !mouse_y
    @interactions.each_pair do |area, rect|
      next if !rect.contains?(mouse_x, mouse_y)
      ret = area
      case area
      when :list
        new_hover_row = (mouse_y + @top_pos - rect.y) / ROW_HEIGHT
        break if new_hover_row >= @particle_list.length
        ret = [area, nil, new_hover_row]
      when :timeline
        new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2)) / KEYFRAME_SPACING
        break if new_hover_keyframe < 0 || new_hover_keyframe >= @duration
        ret = [area, new_hover_keyframe, nil]
      when :commands
        new_hover_row = (mouse_y + @top_pos - rect.y) / ROW_HEIGHT
        new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2)) / KEYFRAME_SPACING
        break if new_hover_row >= @particle_list.length
        break if new_hover_keyframe < 0 || new_hover_keyframe >= @duration
        ret = [area, new_hover_keyframe, new_hover_row]
      end
      break
    end
    return ret
  end

  def on_mouse_press
    return if @captured_area
    hover_element = get_interactive_element_at_mouse
    if hover_element.is_a?(Array)
      @captured_area = hover_element[0]
      @captured_keyframe = hover_element[1]
      @captured_row = hover_element[2]
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    hover_element = get_interactive_element_at_mouse
    if hover_element.is_a?(Array)
      if @captured_area == hover_element[0] &&
         @captured_keyframe == hover_element[1] &&
         @captured_row == hover_element[2]
        set_changed if @keyframe != @captured_keyframe || @particle_index != @captured_row
        @keyframe = @captured_keyframe || -1
        @particle_index = @captured_row || -1
      end
    end
    @captured_keyframe = nil
    @captured_row = nil
    super   # Make this control not busy again
  end

  def update_hover_highlight
    # Remove the hover highlight if there are no interactions for this control
    # or if the mouse is off-screen
    mouse_x, mouse_y = mouse_pos
    if !@interactions || @interactions.empty? || !mouse_x || !mouse_y
      invalidate if @hover_area
      @hover_area = nil
      @hover_keyframe = nil
      @hover_row = nil
      return
    end
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    hover_element = get_interactive_element_at_mouse
    if hover_element.is_a?(Array)
      invalidate if @hover_area != hover_element[0]   # Moved to a different region
      case hover_element[0]
      when :list
        invalidate_rows if @hover_row != hover_element[2]
      when :timeline
        invalidate_time if @hover_keyframe != hover_element[1]
      when :commands
        invalidate_commands if @hover_row != hover_element[2] ||
                               @hover_keyframe != hover_element[1]
      end
      @hover_area = hover_element[0]
      @hover_keyframe = hover_element[1]
      @hover_row = hover_element[2]
    elsif hover_element
      if @hover_area == hover_element
        case @hover_area
        when :list
          invalidate_rows if @hover_row
        when :timeline
          invalidate_time if @hover_keyframe
        when :commands
          invalidate_commands if @hover_keyframe || @hover_row
        end
      else   # Moved to a different region
        invalidate
      end
      @hover_area = hover_element
      @hover_keyframe = nil
      @hover_row = nil
    else
      invalidate if @hover_area
      @hover_area = nil
      @hover_keyframe = nil
      @hover_row = nil
    end
  end

  def update
    return if !self.visible
    @list_scrollbar.update
    @time_scrollbar.update
    super
    # Refresh sprites if a scrollbar has been moved
    self.left_pos = @time_scrollbar.position
    self.top_pos = @list_scrollbar.position
    # Update the current keyframe line's position
    refresh_position_line

    # TODO: This is testing code, and should be replaced by clicking on the
    #       timeline or a command sprite. Maybe keep it after all?
    if Input.trigger?(Input::LEFT)
      if @keyframe > 0
        @keyframe -= 1
        echoln "keyframe = #{@keyframe}"
        set_changed
      end
    elsif Input.trigger?(Input::RIGHT)
      if @keyframe < @duration - DURATION_BUFFER
        @keyframe += 1
        echoln "keyframe = #{@keyframe}"
        set_changed
      end
    elsif Input.trigger?(Input::UP)
      if @particle_index > 0
        @particle_index -= 1
        echoln "particle_index = #{@particle_index}"
        set_changed
      end
    elsif Input.trigger?(Input::DOWN)
      if @particle_index < @particles.length - 1
        @particle_index += 1
        echoln "particle_index = #{@particle_index}"
        set_changed
      end
    end
  end
end
