#===============================================================================
# TODO: Would be nice to make command sprites wider than their viewport and
#       change @commands_viewport's ox to @left_pos, similar to how the vertical
#       scrollbar works, i.e. every visible @commands_sprites isn't redrawn each
#       time the horizontal scrollbar changes.
#===============================================================================
class AnimationEditor::ParticleList < UIControls::BaseControl
  VIEWPORT_SPACING     = 1
  TIMELINE_HEIGHT      = 24 - VIEWPORT_SPACING
  LIST_X               = 0
  LIST_Y               = TIMELINE_HEIGHT + VIEWPORT_SPACING
  LIST_WIDTH           = 150 - VIEWPORT_SPACING
  COMMANDS_X           = LIST_WIDTH + VIEWPORT_SPACING
  COMMANDS_Y           = LIST_Y

  ROW_HEIGHT           = 24
  DIAMOND_SIZE         = 3
  TIMELINE_LEFT_BUFFER = DIAMOND_SIZE + 1   # Allows diamonds at keyframe 0 to be drawn fully
  TIMELINE_TEXT_SIZE   = 16
  KEYFRAME_SPACING     = 20
  INTERP_LINE_HEIGHT   = KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3)
  INTERP_LINE_Y        = (ROW_HEIGHT / 2) - (INTERP_LINE_HEIGHT / 2)
  DURATION_BUFFER      = 20   # Extra keyframes shown after the animation's end
  CONTROL_BG_COLORS    = {
    :user            => Color.new(96, 248, 96),   # Green
    :target          => Color.new(248, 96, 96),   # Red
    :user_and_target => Color.new(248, 248, 96),   # Yellow
    :screen          => Color.new(128, 160, 248)   # Blue
  }
  SE_CONTROL_BG        = Color.gray

  attr_reader :keyframe   # The selected keyframe

  def initialize(x, y, width, height, viewport)
    super(width, height, viewport)
    self.x = x
    self.y = y
    draw_control_background
    # Create viewports
    @list_viewport = Viewport.new(
      x + LIST_X, y + LIST_Y, LIST_WIDTH, height - LIST_Y - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING
    )
    @list_viewport.z = self.viewport.z + 1
    @commands_bg_viewport = Viewport.new(
      x + COMMANDS_X, y + COMMANDS_Y,
      width - COMMANDS_X - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, @list_viewport.rect.height
    )
    @commands_bg_viewport.z = self.viewport.z + 1
    @position_viewport = Viewport.new(@commands_bg_viewport.rect.x, y, @commands_bg_viewport.rect.width, height)
    @position_viewport.z = self.viewport.z + 2
    @commands_viewport = Viewport.new(@commands_bg_viewport.rect.x, @commands_bg_viewport.rect.y,
                                      @commands_bg_viewport.rect.width, @commands_bg_viewport.rect.height)
    @commands_viewport.z = self.viewport.z + 3
    # Create scrollbar
    @list_scrollbar = UIControls::Scrollbar.new(
      x + width - UIControls::Scrollbar::SLIDER_WIDTH, @commands_bg_viewport.rect.y,
      @commands_bg_viewport.rect.height, self.viewport, false, true
    )
    @list_scrollbar.set_interactive_rects
    @time_scrollbar = UIControls::Scrollbar.new(
      @commands_bg_viewport.rect.x, y + height - UIControls::Scrollbar::SLIDER_WIDTH,
      @commands_bg_viewport.rect.width, self.viewport, true, true
    )
    @time_scrollbar.set_interactive_rects
    # Timeline bitmap sprite
    @timeline_sprite = BitmapSprite.new(@commands_viewport.rect.width, TIMELINE_HEIGHT, self.viewport)
    @timeline_sprite.x = @commands_viewport.rect.x
    @timeline_sprite.y = self.y
    @timeline_sprite.bitmap.font.color = TEXT_COLOR
    @timeline_sprite.bitmap.font.size = TIMELINE_TEXT_SIZE
    # Position line sprite
    @position_sprite = BitmapSprite.new(3, height - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, @position_viewport)
    @position_sprite.ox = @position_sprite.width / 2
    @position_sprite.bitmap.fill_rect(0, 0, @position_sprite.bitmap.width, @position_sprite.bitmap.height, Color.red)
    # List sprites and commands sprites
    @list_sprites = []
    @commands_bg_sprites = []
    @commands_sprites = []
    # Scrollbar positions
    @top_pos = 0
    @left_pos = 0
    @duration = 0
    # Selected things
    @keyframe = 0
    @row_index = 0
    # Particle information to display (one row each)
    @particles = []   # Reference to particle data from the editor scene
    @expanded_particles = [0]   # Each element is index in @particles
    @particle_list = []   # Each element is index in @particles or [index, property]
    @visibilities = []   # Per particle
    @commands = {}
  end

  def draw_control_background
    self.bitmap.clear
    # Separator lines
    self.bitmap.fill_rect(0, TIMELINE_HEIGHT, width, VIEWPORT_SPACING, Color.black)
    self.bitmap.fill_rect(LIST_WIDTH, 0, VIEWPORT_SPACING, height, Color.black)
    self.bitmap.fill_rect(0, height - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, width, VIEWPORT_SPACING, Color.black)
    self.bitmap.fill_rect(width - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, 0, VIEWPORT_SPACING, height, Color.black)
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

  def duration
    return [@duration - DURATION_BUFFER, 0].max
  end

  def particle_index
    return -1 if @row_index < 0
    ret = @particle_list[@row_index]
    return (ret.is_a?(Array)) ? ret[0] : ret
  end

  def top_pos=(val)
    old_val = @top_pos
    total_height = (@particle_list.length * ROW_HEIGHT) + 1
    if total_height <= @list_viewport.rect.height
      @top_pos = 0
    else
      @top_pos = val
      @top_pos = @top_pos.clamp(0, total_height - @list_viewport.rect.height)
    end
    @list_viewport.oy = @top_pos
    @commands_bg_viewport.oy = @top_pos
    @commands_viewport.oy = @top_pos
    if @top_pos != old_val
      invalidate_rows
      @old_top_pos = old_val
    end
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

  def set_particles(particles)
    @particles = particles
    calculate_all_commands_and_durations
    create_sprites
  end

  def create_sprites
    # Fill in @particle_list with indices from @particles
    @particle_list.clear
    @particles.length.times do |i|
      @particle_list.push(i)
      next if !@expanded_particles.include?(i)
      @particles[i].each_pair do |property, value|
        @particle_list.push([i, property]) if value.is_a?(Array)
      end
    end
    # Dispose of and clear all existing list/commands sprites
    dispose_listed_sprites
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
    # Set scrollbars to the correct lengths
    @list_scrollbar.range = (@particle_list.length * ROW_HEIGHT) + 1
    @time_scrollbar.range = (@duration * KEYFRAME_SPACING) + TIMELINE_LEFT_BUFFER + 1
    self.top_pos = @list_scrollbar.position
    self.left_pos = @time_scrollbar.position
    # Redraw all sprites
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
    # TODO: Refresh lots of things if the duration changed (e.g. SE command
    #       line).
    @duration = AnimationEditor::ParticleDataHelper.get_duration(@particles)
    @duration += DURATION_BUFFER
  end

  # TODO: Call this only from set_particles and when changes are made to
  #       @particles by the main editor scene. If we can be specific about which
  #       particle was changed, recalculate only that particle's commands.
  def calculate_all_commands_and_durations
    calculate_duration
    calculate_all_commands
  end

  def calculate_all_commands
    @commands = {}
    @particles.each_with_index do |particle, index|
      calculate_commands_for_particle(index)
    end
  end

  def calculate_commands_for_particle(index)
    # TODO: Delete everything from @commands that includes index.
    overall_commands = []
    @particles[index].each_pair do |property, value|
      next if !value.is_a?(Array)
      cmds = AnimationEditor::ParticleDataHelper.get_particle_property_commands_timeline(@particles[index], value, property)
      @commands[[index, property]] = cmds
      cmds.each_with_index do |cmd, i|
        next if !cmd
        overall_commands[i] = (cmd.is_a?(Array)) ? cmd.clone : cmd
      end
    end
    @commands[index] = overall_commands
    # Calculate visibilities for every keyframe
    @visibilities[index] = AnimationEditor::ParticleDataHelper.get_timeline_particle_visibilities(
      @particles[index], @duration - DURATION_BUFFER
    )
  end

  # Returns whether the sprites need replacing due to the addition or
  # subtraction of one.
  def ensure_sprites
    # TODO: Check through @particle_list to ensure only ones are shown which
    #       correspond to something in @particles.
    # Go through all @particles to ensure there are sprites for each of them
    missing = false
    @particles.each_with_index do |particle, index|
      if @particle_list.none? { |value| next !value.is_a?(Array) && value == index }
        missing = true
        break
      end
      next if !@expanded_particles.include?(index)
      particle.each_pair do |property, value|
        next if !value.is_a?(Array)
        if @particle_list.none? { |value| next value.is_a?(Array) && value[0] == index && value[1] == property }
          missing = true
          break
        end
      end
      break if missing
    end
    return true if missing
    # Go through all sprites to ensure there are none for a particle or
    # particle/property that don't exist
    excess = false
    @particle_list.each do |value|
      if value.is_a?(Array)
        excess = true if !@particles[value[0]] || !@particles[value[0]][value[1]] ||
                         @particles[value[0]][value[1]].empty?
      else
        excess = true if !@particles[value]
      end
      break if excess
    end
    return excess
  end

  # Called when a change is made to a particle's commands.
  def change_particle_commands(index)
    old_duration = @duration
    calculate_duration
    if @duration != old_duration
      calculate_all_commands
    else
      calculate_commands_for_particle(index)
    end
    sprites_need_changing = ensure_sprites
    if @duration != old_duration || sprites_need_changing
      @keyframe = @keyframe.clamp(0, @duration - 1)
      @row_index = @row_index.clamp(0, @particle_list.length - 1)
      create_sprites
    end
    invalidate
  end

  # Called when a change is made to a particle's general properties.
  def change_particle(index)
    invalidate_rows
  end

  # TODO: Methods that will show/hide individual property rows for a given
  #       @particles index.

  #-----------------------------------------------------------------------------

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
      :frame    => _INTL("Graphic frame"),
      :blending => _INTL("Blending"),
      :flip     => _INTL("Flip"),
      :x        => _INTL("X"),
      :y        => _INTL("Y"),
      :zoom_x   => _INTL("Zoom X"),
      :zoom_y   => _INTL("Zoom Y"),
      :angle    => _INTL("Angle"),
      :visible  => _INTL("Visible"),
      :opacity  => _INTL("Opacity")
    }[property] || property.capitalize
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
    @position_sprite.visible = (@keyframe >= 0)
    if @keyframe >= 0
      @position_sprite.x = TIMELINE_LEFT_BUFFER + (@keyframe * KEYFRAME_SPACING) - @left_pos
    end
  end

  # TODO: Add indicator that this is selected (if so).
  def refresh_particle_list_sprite(index)
    spr = @list_sprites[index]
    return if !spr
    spr.bitmap.clear
    box_x = (@particle_list[index].is_a?(Array)) ? 16 : 0
    # Get the background color
    p_index = (@particle_list[index].is_a?(Array)) ? @particle_list[index][0] : @particle_list[index]
    particle_data = @particles[p_index]
    if particle_data[:name] == "SE"
      bg_color = SE_CONTROL_BG
    else
      bg_color = CONTROL_BG_COLORS[@particles[p_index][:focus]] || Color.magenta
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
    spr.bitmap.fill_rect(box_x, 1, spr.width - box_x, spr.height - 1, hover_color) if hover_color
    # Draw outline
    spr.bitmap.outline_rect(box_x, 1, spr.width - box_x, spr.height - 1, bg_color, 2)
    # Draw text
    if @particle_list[index].is_a?(Array)
      draw_text(spr.bitmap, box_x + 4, 0, "→")   # ►
      draw_text(spr.bitmap, box_x + 4 + 17, 3, property_display_name(@particle_list[index][1]))
    else
      draw_text(spr.bitmap, 4, 3, @particles[p_index][:name] || "Unnamed")
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
      bg_color = CONTROL_BG_COLORS[@particles[p_index][:focus]] || Color.magenta
    end
    # Get visibilities of particle for each keyframe
    visible_cmds = @visibilities[p_index]
    # Draw background for visible parts of the particle
    each_visible_keyframe do |i|
      draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
      # Draw bg
      if i < @duration - DURATION_BUFFER && visible_cmds[i]
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
      next if !visible_cmds[i]
      # Draw outline
      bg_spr.bitmap.fill_rect(draw_x, 1, KEYFRAME_SPACING, 1, Color.black)   # Top
      bg_spr.bitmap.fill_rect(draw_x, ROW_HEIGHT - 1, KEYFRAME_SPACING, 1, Color.black)   # Bottom
      if i <= 0 || !visible_cmds[i - 1]
        bg_spr.bitmap.fill_rect(draw_x, 1, 1, ROW_HEIGHT - 1, Color.black)   # Left
      end
      if i == @duration - DURATION_BUFFER - 1 || (i < @duration - 1 && !visible_cmds[i + 1])
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
      spr.bitmap.fill_diamond(draw_x, ROW_HEIGHT / 2, DIAMOND_SIZE, TEXT_COLOR)
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
    @old_top_pos = nil if @invalid
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
        listed_element = @particle_list[new_hover_row]
        p_index = listed_element.is_a?(Array) ? listed_element[0] : listed_element
        break if @particles[p_index][:name] == "SE"
        ret = [area, nil, new_hover_row]
      when :timeline
        new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2) - 1) / KEYFRAME_SPACING
        break if new_hover_keyframe < 0 || new_hover_keyframe >= @duration
        ret = [area, new_hover_keyframe, nil]
      when :commands
        new_hover_row = (mouse_y + @top_pos - rect.y) / ROW_HEIGHT
        new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2) - 1) / KEYFRAME_SPACING
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
        if @captured_row && @particle_list[@captured_row].is_a?(Array)
          # TODO: If I want to be able to select individual property rows and/or
          #       diamonds, I shouldn't have this line.
          @captured_row = @particle_list.index(@particle_list[@captured_row][0])
        end
        set_changed if @keyframe != @captured_keyframe || @row_index != @captured_row
        @keyframe = @captured_keyframe || -1
        @row_index = @captured_row || -1
      end
    end
    @captured_keyframe = nil
    @captured_row = nil
    super   # Make this control not busy again
  end

  def on_right_mouse_release
    # TODO: Toggle interpolation line at mouse's position. Should this also have
    #       a def on_right_mouse_press and @right_captured_whatever?
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
    self.top_pos = @list_scrollbar.position
    self.left_pos = @time_scrollbar.position
    # Update the current keyframe line's position
    refresh_position_line

    if Input.release?(Input::MOUSERIGHT)
      on_right_mouse_release
    end

    # TODO: This is testing code, and should be replaced by clicking on the
    #       timeline or a command sprite. Maybe keep it after all? If so,
    #       probably change left/right to <>, and also move the scrollbar(s) to
    #       keep the "cursor" on-screen.
    if Input.repeat?(Input::LEFT)
      if @keyframe > 0
        @keyframe -= 1
        set_changed
      end
    elsif Input.repeat?(Input::RIGHT)
      if @keyframe < @duration - 1
        @keyframe += 1
        set_changed
      end
      # TODO: If this is to be kept, @row_index should be changed by potentially
      #       more than 1, so that @particle_list[@row_index] is an integer and
      #       not an array.
    # elsif Input.repeat?(Input::UP)
    #   if @row_index > 0
    #     @row_index -= 1
    #     set_changed
    #   end
    # elsif Input.repeat?(Input::DOWN)
    #   if @row_index < @particles.length - 1
    #     @row_index += 1
    #     set_changed
    #   end
    end

    # Mouse scroll wheel
    mouse_x, mouse_y = mouse_pos
    if mouse_x && mouse_y
      if @interactions[:list].contains?(mouse_x, mouse_y) ||
         @interactions[:commands].contains?(mouse_x, mouse_y)
        wheel_v = Input.scroll_v
        if wheel_v > 0   # Scroll up
          @list_scrollbar.slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
          self.top_pos = @list_scrollbar.position
        elsif wheel_v < 0   # Scroll down
          @list_scrollbar.slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
          self.top_pos = @list_scrollbar.position
        end
      end
    end

  end
end
