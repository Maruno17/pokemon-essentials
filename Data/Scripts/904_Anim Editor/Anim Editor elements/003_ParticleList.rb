#===============================================================================
#
#===============================================================================
class AnimationEditor::ParticleList < UIControls::BaseControl
  VIEWPORT_SPACING     = 1
  TIMELINE_HEIGHT      = 24 - VIEWPORT_SPACING
  LIST_X               = 0
  LIST_Y               = TIMELINE_HEIGHT + VIEWPORT_SPACING
  LIST_WIDTH           = 180 - VIEWPORT_SPACING
  EXPAND_BUTTON_X      = VIEWPORT_SPACING
  EXPAND_BUTTON_WIDTH  = 19
  LIST_BOX_X           = EXPAND_BUTTON_X + EXPAND_BUTTON_WIDTH + VIEWPORT_SPACING
  LIST_INDENT          = 8
  COMMANDS_X           = LIST_WIDTH + VIEWPORT_SPACING
  COMMANDS_Y           = LIST_Y

  ROW_HEIGHT           = 24
  ROW_SPACING          = 1   # Gap at top of each row
  DIAMOND_SIZE         = 3
  TIMELINE_LEFT_BUFFER = DIAMOND_SIZE + 1   # Allows diamonds at keyframe 0 to be drawn fully
  TIMELINE_TEXT_SIZE   = 16
  KEYFRAME_SPACING     = 20
  INTERP_LINE_HEIGHT   = KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3)
  INTERP_LINE_Y        = (ROW_HEIGHT / 2) - (INTERP_LINE_HEIGHT / 2)
  DURATION_BUFFER      = 20   # Extra keyframes shown after the animation's end

  attr_reader :keyframe   # The selected keyframe
  attr_reader :values

  def initialize(x, y, width, height, viewport)
    super(width, height, viewport)
    self.x = x
    self.y = y
    draw_control_background
    initialize_viewports
    initialize_scrollbars
    initialize_timeline_bitmaps
    initialize_selection_bitmaps
    initialize_controls
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
    @expanded_particles = []   # Each element is index in @particles
    @particle_list = []   # Each element is index in @particles or [index, property]
    @visibilities = []   # Per particle
    @commands = {}
  end

  def initialize_viewports
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
  end

  def initialize_scrollbars
    # Vertical scrollbar
    @list_scrollbar = UIControls::Scrollbar.new(
      x + width - UIControls::Scrollbar::SLIDER_WIDTH, @commands_bg_viewport.rect.y,
      @commands_bg_viewport.rect.height, self.viewport, false, true
    )
    @list_scrollbar.set_interactive_rects
    # Horizontal scrollbar
    @time_scrollbar = UIControls::Scrollbar.new(
      @commands_bg_viewport.rect.x, y + height - UIControls::Scrollbar::SLIDER_WIDTH,
      @commands_bg_viewport.rect.width, self.viewport, true, true
    )
    @time_scrollbar.set_interactive_rects
  end

  def initialize_timeline_bitmaps
    # Time background bitmap sprite
    @time_bg_sprite = BitmapSprite.new(
      @commands_viewport.rect.width,
      TIMELINE_HEIGHT + VIEWPORT_SPACING + @list_viewport.rect.height, self.viewport
    )
    @time_bg_sprite.x = @commands_viewport.rect.x
    @time_bg_sprite.y = self.y
    # Timeline bitmap sprite
    @timeline_sprite = BitmapSprite.new(@commands_viewport.rect.width, TIMELINE_HEIGHT, self.viewport)
    @timeline_sprite.x = @commands_viewport.rect.x
    @timeline_sprite.y = self.y
    @timeline_sprite.bitmap.font.color = text_color
    @timeline_sprite.bitmap.font.size = TIMELINE_TEXT_SIZE
  end

  def initialize_selection_bitmaps
    # Position line sprite
    if !@position_sprite
      @position_sprite = BitmapSprite.new(3, height - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, @position_viewport)
      @position_sprite.ox = @position_sprite.width / 2
    end
    @position_sprite.bitmap.clear
    @position_sprite.bitmap.fill_rect(0, 0, @position_sprite.bitmap.width, @position_sprite.bitmap.height, position_line_color)
    # Selected particle line sprite
    if !@particle_line_sprite
      @particle_line_sprite = BitmapSprite.new(@position_viewport.rect.width, 3, @commands_viewport)
      @particle_line_sprite.z = -10
      @particle_line_sprite.oy = @particle_line_sprite.height / 2
    end
    @particle_line_sprite.bitmap.clear
    @particle_line_sprite.bitmap.fill_rect(0, 0, @particle_line_sprite.bitmap.width, @particle_line_sprite.bitmap.height, position_line_color)
  end

  def initialize_controls
    generate_button_bitmaps
    @controls = []
    add_particle_button = UIControls::BitmapButton.new(x + 1, y + 1, viewport, @bitmaps[:add_button])
    add_particle_button.set_interactive_rects
    @controls.push([:add_particle, add_particle_button])
    up_particle_button = UIControls::BitmapButton.new(x + 22, y + 1, viewport, @bitmaps[:up_button])
    up_particle_button.set_interactive_rects
    @controls.push([:move_particle_up, up_particle_button])
    down_particle_button = UIControls::BitmapButton.new(x + 43, y + 1, viewport, @bitmaps[:down_button])
    down_particle_button.set_interactive_rects
    @controls.push([:move_particle_down, down_particle_button])
  end

  def generate_button_bitmaps
    @bitmaps = {} if !@bitmaps
    @bitmaps[:add_button] = Bitmap.new(12, 12) if !@bitmaps[:add_button]
    @bitmaps[:add_button].clear
    @bitmaps[:add_button].fill_rect(1, 5, 10, 2, text_color)
    @bitmaps[:add_button].fill_rect(5, 1, 2, 10, text_color)
    @bitmaps[:up_button] = Bitmap.new(12, 12) if !@bitmaps[:up_button]
    @bitmaps[:up_button].clear
    5.times do |i|
      @bitmaps[:up_button].fill_rect(1 + i, 7 - i, 1, (i == 0) ? 2 : 3, text_color)
      @bitmaps[:up_button].fill_rect(10 - i, 7 - i, 1, (i == 0) ? 2 : 3, text_color)
    end
    @bitmaps[:down_button] = Bitmap.new(12, 12) if !@bitmaps[:down_button]
    5.times do |i|
      @bitmaps[:down_button].fill_rect(1 + i, 2 + i + (i == 0 ? 1 : 0), 1, (i == 0) ? 2 : 3, text_color)
      @bitmaps[:down_button].fill_rect(10 - i, 2 + i + (i == 0 ? 1 : 0), 1, (i == 0) ? 2 : 3, text_color)
    end
  end

  def dispose
    @list_scrollbar.dispose
    @time_scrollbar.dispose
    @time_bg_sprite.dispose
    @timeline_sprite.dispose
    @position_sprite.dispose
    @particle_line_sprite.dispose
    @controls.each { |c| c[1].dispose }
    @controls.clear
    @bitmaps.each_value { |b| b&.dispose }
    @bitmaps.clear
    dispose_listed_sprites
    @list_viewport.dispose
    @commands_bg_viewport.dispose
    @commands_viewport.dispose
    super
  end

  def dispose_listed_sprites
    @list_sprites.each { |p| p&.dispose }
    @list_sprites.clear
    @commands_bg_sprites.each { |p| p&.dispose }
    @commands_bg_sprites.clear
    @commands_sprites.each { |p| p&.dispose }
    @commands_sprites.clear
  end

  #-----------------------------------------------------------------------------

  def position_line_color
    return get_color_scheme_color_for_element(:position_line_color, Color.new(248, 96, 96))
  end

  def after_end_bg_color
    return get_color_scheme_color_for_element(:after_end_bg_color, Color.new(160, 160, 160))
  end

  def se_background_color
    return get_color_scheme_color_for_element(:se_background_color, Color.gray)
  end

  def property_background_color
    return get_color_scheme_color_for_element(:property_background_color, Color.new(224, 224, 224))
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    return if !@bitmaps
    draw_control_background
    initialize_selection_bitmaps
    generate_button_bitmaps
    self.bitmap.font.color = text_color
    self.bitmap.font.size = text_size
    @list_scrollbar.color_scheme = value
    @time_scrollbar.color_scheme = value
    @timeline_sprite.bitmap.font.color = text_color
    @controls.each { |c| c[1].color_scheme = value }
    @list_sprites.each { |spr| spr.bitmap.font.color = text_color }
    invalidate
  end

  def duration
    return [@duration - DURATION_BUFFER, 0].max
  end

  def particle_index
    return -1 if @row_index < 0 || @row_index >= @particle_list.length
    ret = @particle_list[@row_index]
    return (ret.is_a?(Array)) ? ret[0] : ret
  end

  def particle_index=(val)
    old_index = @row_index
    @row_index = @particle_list.index { |row| !row.is_a?(Array) && row == val }
    return if @row_index == old_index
    invalidate
    scroll_to_row(@row_index)
  end

  def keyframe=(val)
    return if @keyframe == val
    @keyframe = val
    scroll_to_keyframe(@keyframe)
    invalidate
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
      refresh_particle_line
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

  def scroll_to_row(new_row)
    if new_row * ROW_HEIGHT < @top_pos
      # Scroll up
      new_pos = new_row * ROW_HEIGHT
      loop do
        @list_scrollbar.slider_top -= 1
        break if @list_scrollbar.position <= new_pos || @list_scrollbar.minimum?
      end
    elsif new_row * ROW_HEIGHT > @top_pos + @list_viewport.rect.height - ROW_HEIGHT
      # Scroll down
      new_pos = (new_row * ROW_HEIGHT) - @list_viewport.rect.height + ROW_HEIGHT
      loop do
        @list_scrollbar.slider_top += 1
        break if @list_scrollbar.position >= new_pos || @list_scrollbar.maximum?
      end
    end
  end

  def scroll_to_keyframe(new_keyframe)
    if TIMELINE_LEFT_BUFFER + (new_keyframe * KEYFRAME_SPACING) - (KEYFRAME_SPACING / 2) < @left_pos
      # Scroll left
      new_pos = TIMELINE_LEFT_BUFFER + (new_keyframe * KEYFRAME_SPACING) - (KEYFRAME_SPACING / 2)
      loop do
        @time_scrollbar.slider_top -= 1
        break if @time_scrollbar.position <= new_pos || @time_scrollbar.minimum?
      end
    elsif TIMELINE_LEFT_BUFFER + (new_keyframe * KEYFRAME_SPACING) + (KEYFRAME_SPACING / 2) > @left_pos + @commands_bg_viewport.rect.width
      # Scroll right
      new_pos = TIMELINE_LEFT_BUFFER + (new_keyframe * KEYFRAME_SPACING) + (KEYFRAME_SPACING / 2) - @commands_bg_viewport.rect.width
      loop do
        @time_scrollbar.slider_top += 1
        break if @time_scrollbar.position >= new_pos || @time_scrollbar.maximum?
      end
    end
  end

  # Ensures that the array of which particle rows have been expanded ends up
  # with the same particles having expanded rows after adding a particle.
  def add_particle(index)
    @expanded_particles.each_with_index do |idx, i|
      @expanded_particles[i] += 1 if idx >= index
    end
  end

  # Ensures that the array of which particle rows have been expanded ends up
  # with the same particles having expanded rows after deleting a particle.
  def delete_particle(index)
    @expanded_particles.delete(index)
    @expanded_particles.each_with_index do |idx, i|
      @expanded_particles[i] -= 1 if idx > index
    end
  end

  # Ensures that the array of which particle rows have been expanded ends up
  # with the same particles having expanded rows after the swap.
  def swap_particles(idx1, idx2)
    if @expanded_particles.include?(idx1) && !@expanded_particles.include?(idx2)
      @expanded_particles.delete(idx1)
      @expanded_particles.push(idx2)
    elsif @expanded_particles.include?(idx2) && !@expanded_particles.include?(idx1)
      @expanded_particles.delete(idx2)
      @expanded_particles.push(idx1)
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
    @row_index = @particle_list.length - 1 if @row_index >= @particle_list.length
    # Dispose of and clear all existing list/commands sprites
    dispose_listed_sprites
    # Create new sprites for each particle (1x list and 2x commands)
    @particle_list.length.times do
      list_sprite = BitmapSprite.new(@list_viewport.rect.width, ROW_HEIGHT, @list_viewport)
      list_sprite.y = @list_sprites.length * ROW_HEIGHT
      list_sprite.bitmap.font.color = text_color
      list_sprite.bitmap.font.size = text_size
      @list_sprites.push(list_sprite)
      commands_bg_sprite = BitmapSprite.new(@commands_viewport.rect.width, ROW_HEIGHT, @commands_bg_viewport)
      commands_bg_sprite.y = @commands_bg_sprites.length * ROW_HEIGHT
      commands_bg_sprite.bitmap.font.color = text_color
      commands_bg_sprite.bitmap.font.size = text_size
      @commands_bg_sprites.push(commands_bg_sprite)
      commands_sprite = BitmapSprite.new(@commands_viewport.rect.width, ROW_HEIGHT, @commands_viewport)
      commands_sprite.y = @commands_sprites.length * ROW_HEIGHT
      commands_sprite.bitmap.font.color = text_color
      commands_sprite.bitmap.font.size = text_size
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

  def busy?
    return true if controls_busy?
    return super
  end

  def controls_busy?
    return @controls.any? { |c| c[1].busy? }
  end

  def changed?
    return @changed
  end

  def set_changed
    @changed = true
    @values = {}
  end

  def clear_changed
    super
    @values = nil
  end

  def get_control(id)
    ret = nil
    @controls.each do |c|
      ret = c[1] if c[0] == id
      break if ret
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  def calculate_all_commands_and_durations
    calculate_duration
    calculate_all_commands
  end

  def calculate_duration
    @duration = AnimationPlayer::Helper.get_duration(@particles)
    @duration += DURATION_BUFFER
  end

  def calculate_all_commands
    @commands = {}
    @particles.each_with_index do |particle, index|
      calculate_commands_for_particle(index)
    end
  end

  def calculate_commands_for_particle(index)
    @commands.delete_if { |cmd| cmd == index || (cmd.is_a?(Array) && cmd[0] == index) }
    overall_commands = []
    @particles[index].each_pair do |property, value|
      next if !value.is_a?(Array)
      cmds = AnimationEditor::ParticleDataHelper.get_particle_property_commands_timeline(@particles[index], property, value)
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
      @keyframe = @keyframe.clamp(-1, @duration - 1)
      @row_index = @row_index.clamp(0, @particle_list.length - 1)
      create_sprites
    end
    invalidate
  end

  # Called when a change is made to a particle's general properties.
  def change_particle(index)
    invalidate_rows
  end

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

  def draw_control_background
    self.bitmap.clear
    # Separator lines
    self.bitmap.fill_rect(0, TIMELINE_HEIGHT, width, VIEWPORT_SPACING, line_color)
    self.bitmap.fill_rect(LIST_WIDTH, 0, VIEWPORT_SPACING, height, line_color)
    self.bitmap.fill_rect(0, height - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, width, VIEWPORT_SPACING, line_color)
    self.bitmap.fill_rect(width - UIControls::Scrollbar::SLIDER_WIDTH - VIEWPORT_SPACING, 0, VIEWPORT_SPACING, height, line_color)
  end

  #-----------------------------------------------------------------------------

  def repaint
    @list_scrollbar.repaint if @list_scrollbar.invalid?
    @time_scrollbar.repaint if @time_scrollbar.invalid?
    @controls.each { |c| c[1].repaint if c[1].invalid? }
    super if invalid?
  end

  def refresh_timeline
    @time_bg_sprite.bitmap.clear
    @timeline_sprite.bitmap.clear
    # Draw grey over the time after the end of the animation
    dur = duration
    draw_x = TIMELINE_LEFT_BUFFER + (dur * KEYFRAME_SPACING) - @left_pos
    greyed_width = @time_bg_sprite.width - draw_x
    if greyed_width > 0
      @time_bg_sprite.bitmap.fill_rect(draw_x, 0, greyed_width, @time_bg_sprite.height, after_end_bg_color)
      @time_bg_sprite.bitmap.fill_rect(draw_x, TIMELINE_HEIGHT, greyed_width, VIEWPORT_SPACING, line_color)
    end
    # Draw hover highlight
    if !controls_busy?
      this_hover_color = nil
      if @captured_keyframe && !@captured_row
        if @hover_keyframe && @hover_keyframe == @captured_keyframe && !@hover_row
          this_hover_color = hover_color
        else
          this_hover_color = capture_color
        end
        draw_x = TIMELINE_LEFT_BUFFER + (@captured_keyframe * KEYFRAME_SPACING) - @left_pos
        @timeline_sprite.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 0,
                                          KEYFRAME_SPACING, TIMELINE_HEIGHT - 1, this_hover_color)
      elsif !@captured_keyframe && !@captured_row && @hover_keyframe && !@hover_row
        this_hover_color = hover_color
        draw_x = TIMELINE_LEFT_BUFFER + (@hover_keyframe * KEYFRAME_SPACING) - @left_pos
        @timeline_sprite.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 0,
                                          KEYFRAME_SPACING, TIMELINE_HEIGHT - 1, this_hover_color)
      end
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
      @timeline_sprite.bitmap.fill_rect(draw_x, TIMELINE_HEIGHT - line_height, 1, line_height, text_color)
      draw_text(@timeline_sprite.bitmap, draw_x + 1, 0, (i / 20.0).to_s) if (i % 5) == 0
    end
  end

  def refresh_position_line
    @position_sprite.visible = (@keyframe >= 0)
    if @keyframe >= 0
      @position_sprite.x = TIMELINE_LEFT_BUFFER + (@keyframe * KEYFRAME_SPACING) - @left_pos
    end
  end

  def refresh_particle_line
    @particle_line_sprite.visible = (particle_index >= 0)
    if particle_index >= 0
      @particle_line_sprite.y = ((@row_index + 0.5) * ROW_HEIGHT).to_i
    end
  end

  def refresh_particle_list_sprite(index)
    spr = @list_sprites[index]
    return if !spr
    spr.bitmap.clear
    # Get useful information
    is_property = @particle_list[index].is_a?(Array)
    p_index = (is_property) ? @particle_list[index][0] : @particle_list[index]
    particle_data = @particles[p_index]
    box_x = LIST_BOX_X
    box_x += LIST_INDENT if is_property
    # Get the background color
    if particle_data[:name] == "SE"
      bg_color = se_background_color
    elsif is_property
      bg_color = property_background_color
    else
      bg_color = focus_color(@particles[p_index][:focus])
    end
    # Draw hover highlight
    if !controls_busy? && !@captured_keyframe
      hover_color = nil
      if @captured_row
        if @captured_row == index
          if !@hover_keyframe && @hover_row && @hover_row == index &&
             @captured_row_button && @hover_row_button == @captured_row_button
            this_hover_color = hover_color
          else
            this_hover_color = capture_color
          end
        end
      elsif @hover_row && @hover_row == index && !@hover_keyframe
        this_hover_color = hover_color
      end
      if this_hover_color
        case @captured_row_button || @hover_row_button
        when :expand
          spr.bitmap.fill_rect(EXPAND_BUTTON_X, (ROW_HEIGHT - EXPAND_BUTTON_WIDTH + 1) / 2,
                               EXPAND_BUTTON_WIDTH, EXPAND_BUTTON_WIDTH, this_hover_color)
        when :row
          spr.bitmap.fill_rect(box_x, ROW_SPACING, spr.width - box_x, spr.height - ROW_SPACING, this_hover_color)
        end
      end
    end
    # Draw outline
    spr.bitmap.outline_rect(box_x, ROW_SPACING, spr.width - box_x, spr.height - ROW_SPACING, bg_color, 2)
    # Draw text
    if is_property
      draw_text(spr.bitmap, box_x + 4, 3, GameData::Animation.property_display_name(@particle_list[index][1]) + ":")
    else
      draw_text(spr.bitmap, box_x + 4, 3, @particles[p_index][:name] || "Unnamed")
    end
    # Draw expand/collapse arrow or dotted lines
    icon_color = text_color
    dotted_color = line_color
    if is_property
      6.times do |j|
        spr.bitmap.fill_rect(10, j * 2, 1, 1, dotted_color)
      end
      9.times do |i|
        spr.bitmap.fill_rect(10 + (i * 2), 12, 1, 1, dotted_color)
      end
    elsif @expanded_particles.include?(p_index)
      # Draw down-pointing arrow
      11.times do |i|
        j = (i == 0 || i == 10) ? 1 : 0
        h = [2, 4, 5, 6, 7, 8, 7, 6, 5, 4, 2][i]
        h = ((i > 5) ? 10 - i : i) + 3 - j
        spr.bitmap.fill_rect(5 + i, 9 + j, 1, h, icon_color)
      end
    elsif particle_data[:name] != "SE"
      # Draw right-pointing arrow
      11.times do |j|
        i = (j == 0 || j == 10) ? 1 : 0
        w = [2, 4, 5, 6, 7, 8, 7, 6, 5, 4, 2][j]
        w = ((j > 5) ? 10 - j : j) + 3 - i
        spr.bitmap.fill_rect(7 + i, 7 + j, w, 1, icon_color)
      end
    end
    # Draw dotted line leading to the next property line
    if @particle_list[index + 1]&.is_a?(Array)
      5.times do |j|
        spr.bitmap.fill_rect(10, 14 + (j * 2), 1, 1, dotted_color)
      end
    end
  end

  def refresh_particle_commands_bg_sprites(index)
    bg_spr = @commands_bg_sprites[index]
    return if !bg_spr
    bg_spr.bitmap.clear
    is_property = @particle_list[index].is_a?(Array)
    p_index = (is_property) ? @particle_list[index][0] : @particle_list[index]
    particle_data = @particles[p_index]
    # Get the background color
    if particle_data[:name] == "SE"
      bg_color = se_background_color
    elsif is_property
      bg_color = property_background_color
    else
      bg_color = focus_color(@particles[p_index][:focus])
    end
    # Get visibilities of particle for each keyframe
    visible_cmds = @visibilities[p_index]
    # Draw background for visible parts of the particle
    each_visible_keyframe do |i|
      draw_x = TIMELINE_LEFT_BUFFER + (i * KEYFRAME_SPACING) - @left_pos
      # Draw bg
      if i < @duration - DURATION_BUFFER && visible_cmds[i] == 1
        bg_spr.bitmap.fill_rect(draw_x, ROW_SPACING, KEYFRAME_SPACING, ROW_HEIGHT - ROW_SPACING, bg_color)
      end
      # Draw hover highlight
      this_hover_color = nil
      if !controls_busy?
        earlier_captured_keyframe = @captured_keyframe
        later_captured_keyframe = (earlier_captured_keyframe || -1) + 1
        earlier_hovered_keyframe = @hover_keyframe
        later_hovered_keyframe = (earlier_hovered_keyframe || -1) + 1
        if is_property
          later_captured_keyframe = @captured_row_button || 0
          later_hovered_keyframe = @hover_row_button || 0
        end
        if @captured_row && @captured_keyframe
          if @captured_row == index && i >= earlier_captured_keyframe && i < later_captured_keyframe
            if @hover_row && @hover_row == index && @hover_keyframe && i >= earlier_hovered_keyframe && i < later_hovered_keyframe
              this_hover_color = hover_color
            else
              this_hover_color = capture_color
            end
          end
        elsif !@captured_row && !@captured_keyframe && @hover_row && @hover_keyframe &&
              @hover_row == index && i >= earlier_hovered_keyframe && i < later_hovered_keyframe
          this_hover_color = hover_color
        end
      end
      if this_hover_color
        if is_property
          bg_spr.bitmap.fill_rect(draw_x, 2, KEYFRAME_SPACING, ROW_HEIGHT - 3, this_hover_color)
        else
          bg_spr.bitmap.fill_rect(draw_x - (KEYFRAME_SPACING / 2), 2, KEYFRAME_SPACING, ROW_HEIGHT - 3, this_hover_color)
        end
      end
      next if i >= @duration - DURATION_BUFFER
      outline_color = line_color
      case visible_cmds[i]
      when 1   # Particle is visible
        # Draw outline
        if is_property
          outline_color = focus_color(@particles[p_index][:focus])
        end
        bg_spr.bitmap.fill_rect(draw_x, ROW_SPACING, KEYFRAME_SPACING, 1, outline_color)   # Top
        bg_spr.bitmap.fill_rect(draw_x, ROW_HEIGHT - 1, KEYFRAME_SPACING, 1, outline_color)   # Bottom
        if i <= 0 || visible_cmds[i - 1] != 1
          bg_spr.bitmap.fill_rect(draw_x, ROW_SPACING, 1, ROW_HEIGHT - ROW_SPACING, outline_color)   # Left
        end
        if i == @duration - DURATION_BUFFER - 1 || (i < @duration - 1 && visible_cmds[i + 1] != 1)
          bg_spr.bitmap.fill_rect(draw_x + KEYFRAME_SPACING, ROW_SPACING, 1, ROW_HEIGHT - ROW_SPACING, outline_color)   # Right
        end
      when 2   # Particle is a spawner and delays its particles into this frame
        if !is_property
          # Draw dotted outline
          KEYFRAME_SPACING.times do |j|
            next if j.odd?
            bg_spr.bitmap.fill_rect(draw_x + j, ROW_SPACING, 1, 1, outline_color)   # Top
            bg_spr.bitmap.fill_rect(draw_x + j, ROW_HEIGHT - 1, 1, 1, outline_color)   # Bottom
          end
          (ROW_HEIGHT - ROW_SPACING).times do |j|
            next if j.odd?
            if i <= 0 || visible_cmds[i - 1] != 2
              bg_spr.bitmap.fill_rect(draw_x, ROW_SPACING + j, 1, 1, outline_color)   # Left
            end
            if i == @duration - DURATION_BUFFER - 1 || (i < @duration - 1 && visible_cmds[i + 1] != 2)
              bg_spr.bitmap.fill_rect(draw_x + KEYFRAME_SPACING, ROW_SPACING + j, 1, 1, outline_color)   # Right
            end
          end
        end
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
      spr.bitmap.fill_diamond(draw_x, ROW_HEIGHT / 2, DIAMOND_SIZE, text_color)
      # Draw interpolation line
      if cmds[i].is_a?(Array)
        spr.bitmap.draw_interpolation_line(
          draw_x + DIAMOND_SIZE + 2,
          INTERP_LINE_Y,
          cmds[i][0].abs * KEYFRAME_SPACING - ((DIAMOND_SIZE * 2) + 3),
          INTERP_LINE_HEIGHT,
          cmds[i][0] > 0,   # Increases or decreases
          cmds[i][1],       # Interpolation type
          text_color
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
          text_color
        )
      end
    end
  end

  def refresh
    @old_top_pos = nil if @invalid
    @controls.each { |c| c[1].refresh }
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
        mouse_y_in_row = mouse_y + @top_pos - (new_hover_row * ROW_HEIGHT) - rect.y
        case mouse_x
        when EXPAND_BUTTON_X...(EXPAND_BUTTON_X + EXPAND_BUTTON_WIDTH)
          next if listed_element.is_a?(Array)
          next if mouse_y_in_row < (ROW_HEIGHT - EXPAND_BUTTON_WIDTH + 1) / 2
          next if mouse_y_in_row >= ((ROW_HEIGHT - EXPAND_BUTTON_WIDTH + 1) / 2) + EXPAND_BUTTON_WIDTH
          ret = [area, nil, new_hover_row, :expand]
        when LIST_BOX_X...(@list_viewport.rect.width)
          next if listed_element.is_a?(Array)
          next if mouse_y_in_row < ROW_SPACING
          ret = [area, nil, new_hover_row, :row]
        end
      when :timeline
        new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2) - 1) / KEYFRAME_SPACING
        break if new_hover_keyframe < 0 || new_hover_keyframe >= @duration
        ret = [area, new_hover_keyframe, nil]
      when :commands
        new_hover_row = (mouse_y + @top_pos - rect.y) / ROW_HEIGHT
        break if new_hover_row >= @particle_list.length
        listed_element = @particle_list[new_hover_row]
        if listed_element.is_a?(Array)
          new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER - 1) / KEYFRAME_SPACING
        else
          new_hover_keyframe = (mouse_x + @left_pos - rect.x - TIMELINE_LEFT_BUFFER + (KEYFRAME_SPACING / 2) - 1) / KEYFRAME_SPACING
        end
        break if new_hover_keyframe < 0 || new_hover_keyframe >= @duration
        if listed_element.is_a?(Array)
          break if !GameData::Animation.property_can_interpolate?(listed_element[1])
          cmds = @commands[listed_element]
          break if !cmds
          earlier_keyframe = nil
          later_keyframe = nil
          cmds.each_with_index do |cmd, i|
            earlier_keyframe = i if cmd && i <= new_hover_keyframe
            later_keyframe = i if cmd && !later_keyframe && i > new_hover_keyframe
          end
          break if !earlier_keyframe || !later_keyframe
          ret = [area, earlier_keyframe, new_hover_row, later_keyframe]
        else
          ret = [area, new_hover_keyframe, new_hover_row]
        end
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
      @captured_row_button = hover_element[3]
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    # Change this control's value
    hover_element = get_interactive_element_at_mouse
    if hover_element.is_a?(Array)
      if @captured_area == hover_element[0] &&
         @captured_keyframe == hover_element[1] &&
         @captured_row == hover_element[2] &&
         @captured_row_button == hover_element[3]
        if @captured_area == :commands && @captured_row && @particle_list[@captured_row].is_a?(Array)
          set_changed
          @values[:cycle_interpolation] = [*@particle_list[@captured_row], @captured_keyframe]
        else
          case @captured_row_button
          when :expand
            old_row_idx_particle = @particle_list[@row_index]
            idx_particle = @particle_list[@captured_row]
            idx_particle = idx_particle[0] if idx_particle.is_a?(Array)
            if @expanded_particles.include?(idx_particle)   # Contract
              @expanded_particles.delete(idx_particle)
            else                                            # Expand
              @expanded_particles.push(idx_particle)
            end
            set_particles(@particles)
            @row_index = @particle_list.index(old_row_idx_particle)
          else   # :row button or somewhere in the commands area or timeline, just change selection
            if @captured_row && @particle_list[@captured_row].is_a?(Array)
              @captured_row = @particle_list.index(@particle_list[@captured_row][0])
            end
            set_changed if @keyframe != @captured_keyframe || @row_index != @captured_row
            @keyframe = @captured_keyframe || -1
            @row_index = @captured_row if @captured_row
          end
        end
      end
    end
    @captured_keyframe = nil
    @captured_row = nil
    @captured_row_button = nil
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
      @hover_row_button = nil
      return
    end
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    hover_element = get_interactive_element_at_mouse
    if hover_element.is_a?(Array)
      invalidate if @hover_area != hover_element[0]   # Moved to a different region
      case hover_element[0]
      when :list
        invalidate_rows if @hover_row != hover_element[2] || @hover_row_button != hover_element[3]
      when :timeline
        invalidate_time if @hover_keyframe != hover_element[1]
      when :commands
        invalidate_commands if @hover_row != hover_element[2] ||
                               @hover_keyframe != hover_element[1]
      end
      @hover_area = hover_element[0]
      @hover_keyframe = hover_element[1]
      @hover_row = hover_element[2]
      @hover_row_button = hover_element[3]
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
      @hover_row_button = nil
    else
      invalidate if @hover_area
      @hover_area = nil
      @hover_keyframe = nil
      @hover_row = nil
      @hover_row_button = nil
    end
  end

  def update_input
    # Left/right to change current keyframe
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @keyframe >= 0
        @keyframe -= 1
        scroll_to_keyframe(@keyframe)
        set_changed
      end
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @keyframe < @duration - 1
        @keyframe += 1
        scroll_to_keyframe(@keyframe)
        set_changed
      end
    end
    # Up/down to change selected particle
    if Input.triggerex?(:UP) || Input.repeatex?(:UP)
      if @row_index > 0
        loop do
          @row_index -= 1
          break if !@particle_list[@row_index].is_a?(Array)
        end
        scroll_to_row(@row_index)
        set_changed
      end
    elsif Input.triggerex?(:DOWN) || Input.repeatex?(:DOWN)
      if @row_index < @particle_list.length - 1
        old_row_index = @row_index
        loop do
          @row_index += 1
          break if !@particle_list[@row_index].is_a?(Array) || @row_index >= @particle_list.length
        end
        if @row_index < @particle_list.length
          @keyframe = 0 if @keyframe < 0 && !@particle_list[@row_index].is_a?(Array) &&
                           @particles[@particle_list[@row_index]][:name] == "SE"
          scroll_to_row(@row_index)
          set_changed
        else
          @row_index = old_row_index
        end
      end
    end
    if Input.triggerex?(:P)
      idx_particle = @particle_list[@row_index]
      idx_particle = idx_particle[0] if idx_particle.is_a?(Array)
      if @row_index >= 0 && @particles[idx_particle][:name] != "SE"
        if @expanded_particles.include?(idx_particle)   # Contract
          @expanded_particles.delete(idx_particle)
        else                                            # Expand
          @expanded_particles.push(idx_particle)
        end
        set_particles(@particles)
      end
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

  def update
    return if !self.visible
    @list_scrollbar.update
    @time_scrollbar.update
    if !@captured_area
      @controls.each { |c| c[1].update }
    end
    super
    # Refresh sprites if a scrollbar has been moved
    self.top_pos = @list_scrollbar.position
    self.left_pos = @time_scrollbar.position
    # Update the positions of the selected particle/keyframe lines
    refresh_position_line
    refresh_particle_line
    # Add/move particle buttons
    @controls.each do |c|
      next if !c[1].changed?
      set_changed
      @values[c[0]] = true
      c[1].clear_changed
    end
    # Up/down/left/right navigation, and mouse scroll wheel
    update_input
  end
end
