#===============================================================================
# NOTE: Time bar is the bit at the top with the numbers in it. Timeline is
#       the large area beneath it where the commands for particles are
#       displayed.
#===============================================================================
class AnimationEditor::Timeline < UIControls::BaseContainer
  attr_reader :duration
  attr_reader :selected_keyframe, :selected_row

  VIEWPORT_SPACING = 1

  # Move Particle Up/Down buttons go to the right of the Add Particle button.
  ADD_PARTICLE_BUTTON_X = VIEWPORT_SPACING
  ADD_PARTICLE_BUTTON_Y = VIEWPORT_SPACING
  BUTTON_SIZE           = 20   # Full size of button; bitmap in the button is 12
  BUTTON_SPACING        = VIEWPORT_SPACING

  TIME_BAR_HEIGHT = ADD_PARTICLE_BUTTON_Y + BUTTON_SIZE + (VIEWPORT_SPACING * 2)   # Not including separator line
  LIST_X          = 0
  LIST_Y          = TIME_BAR_HEIGHT + VIEWPORT_SPACING   # After black horizontal line
  LIST_WIDTH      = 210   # Not including the last pixel between particle list and black line

  TIMELINE_X = LIST_X + LIST_WIDTH + (VIEWPORT_SPACING * 2)
  TIMELINE_Y = LIST_Y

  TIME_BAR_LEFT_BUFFER = 4   # Allows command diamonds at keyframe 0 to be drawn fully
  TIME_BAR_TEXT_SIZE   = 16
  KEYFRAME_SPACING     = 20

  DURATION_BUFFER = 36   # Extra keyframes shown after the animation's end

  def initialize(x, y, width, height, viewport, particles)
    @particles         = particles
    calculate_duration
    @timeline_ox       = 0
    @timeline_oy       = 0
    @selected_keyframe = 0
    @selected_row      = 0
    @display_particles = []
    super(x, y, width, height, viewport)
    refresh
  end

  def initialize_viewport
    super   # Not needed
    # Viewport for the list of particles/properties on the left
    @list_viewport = Viewport.new(
      x + LIST_X, y + LIST_Y,
      LIST_WIDTH, height - LIST_Y - UIControls::Scrollbar::SLIDER_WIDTH - (VIEWPORT_SPACING * 2)
    )
    @list_viewport.z = self.viewport.z + 1
    # Viewport for background graphics in the timeline
    @timeline_bg_viewport = Viewport.new(
      x + TIMELINE_X, y + TIMELINE_Y,
      width - TIMELINE_X - UIControls::Scrollbar::SLIDER_WIDTH - (VIEWPORT_SPACING * 2), @list_viewport.rect.height
    )
    @timeline_bg_viewport.z = self.viewport.z + 1
    # Viewport for the indicators of the currently selected row/keyframe
    @position_viewport = Viewport.new(@timeline_bg_viewport.rect.x, y, @timeline_bg_viewport.rect.width, height)
    @position_viewport.z = self.viewport.z + 2
    # Viewport for foreground graphics in the timeline
    @timeline_viewport = Viewport.new(@timeline_bg_viewport.rect.x, @timeline_bg_viewport.rect.y,
                                      @timeline_bg_viewport.rect.width, @timeline_bg_viewport.rect.height)
    @timeline_viewport.z = self.viewport.z + 3
  end

  # NOTE: This method is also called when changing the color scheme.
  def initialize_bitmaps
    bitmap_size = BUTTON_SIZE - (UIControls::BitmapButton::BUTTON_FRAME_THICKNESS * 2)   # 12
    arrow_graphic = %w(
      . . . . . . . . . . . .
      . . . . . . . . . . . .
      . . . . . . . . . . . .
      . . . . . X X . . . . .
      . . . . X X X X . . . .
      . . . X X X X X X . . .
      . . X X X . . X X X . .
      . X X X . . . . X X X .
      . X X . . . . . . X X .
      . . . . . . . . . . . .
      . . . . . . . . . . . .
      . . . . . . . . . . . .
    )
    # "Add Particle" bitmap
    @bitmaps[:add_particle] = Bitmap.new(bitmap_size, bitmap_size) if !@bitmaps[:add_particle]
    @bitmaps[:add_particle].clear
    @bitmaps[:add_particle].fill_rect(1, (bitmap_size / 2) - 1, bitmap_size - 2, 2, get_color_of(:text))
    @bitmaps[:add_particle].fill_rect((bitmap_size / 2) - 1, 1, 2, bitmap_size - 2, get_color_of(:text))
    # "Move Particle Up" bitmap
    @bitmaps[:move_up] = Bitmap.new(bitmap_size, bitmap_size) if !@bitmaps[:move_up]
    @bitmaps[:move_up].clear
    arrow_graphic.length.times do |i|
      next if arrow_graphic[i] == "."
      @bitmaps[:move_up].fill_rect(i % bitmap_size, i / bitmap_size, 1, 1, get_color_of(:text))
    end
    # "Move Particle Down" bitmap
    @bitmaps[:move_down] = Bitmap.new(bitmap_size, bitmap_size) if !@bitmaps[:move_down]
    @bitmaps[:move_down].clear
    arrow_graphic.length.times do |i|
      next if arrow_graphic[i] == "."
      @bitmaps[:move_down].fill_rect(i % bitmap_size, bitmap_size - 1 - (i / bitmap_size), 1, 1, get_color_of(:text))
    end
  end

  # NOTE: This method is also called when changing the color scheme.
  def initialize_background
    if !@sprites[:background]
      @sprites[:background] = BitmapSprite.new(width, height, self.viewport)
      @sprites[:background].x = x
      @sprites[:background].y = y
      @sprites[:background].z = -100
    end
    bg_sprite = @sprites[:background]
    scrollbar_width = UIControls::Scrollbar::SLIDER_WIDTH
    # Draw separator lines
    bg_sprite.bitmap.fill_rect(0, TIME_BAR_HEIGHT,
                               width, VIEWPORT_SPACING, get_color_of(:line))
    bg_sprite.bitmap.fill_rect(TIMELINE_X - VIEWPORT_SPACING, 0,
                               VIEWPORT_SPACING, height, get_color_of(:line))
    bg_sprite.bitmap.fill_rect(0, height - scrollbar_width - (VIEWPORT_SPACING * 2),
                               width, VIEWPORT_SPACING, get_color_of(:line))
    bg_sprite.bitmap.fill_rect(width - scrollbar_width - (VIEWPORT_SPACING * 2), 0,
                               VIEWPORT_SPACING, height, get_color_of(:line))
    # Draw grey boxes in unused areas
    bg_sprite.bitmap.fill_rect(0, height - scrollbar_width,
                               LIST_WIDTH, scrollbar_width, get_color_of(:gray_background))
    bg_sprite.bitmap.fill_rect(width - scrollbar_width, 0,
                               scrollbar_width, TIME_BAR_HEIGHT - VIEWPORT_SPACING, get_color_of(:gray_background))
    bg_sprite.bitmap.fill_rect(width - scrollbar_width, height - scrollbar_width,
                               scrollbar_width, scrollbar_width, get_color_of(:gray_background))
  end

  # NOTE: Ideally the time_bar markings would be in their own new viewport,
  #       and the background grey/gridlines would be in @commands_bg_viewport
  #       and be full width. However, they would be arbitrarily wide due to
  #       animations being able to be any duration, and it would be more of a
  #       hassle to account for that. The simpler option is to just redraw them
  #       entirely whenever the time scrollbar is moved.
  def initialize_sprites
    # Timeline background
    @sprites[:timeline_bg] = BitmapSprite.new(
      @timeline_bg_viewport.rect.width, TIME_BAR_HEIGHT + VIEWPORT_SPACING + @timeline_bg_viewport.rect.height, self.viewport
    )
    @sprites[:timeline_bg].x = @timeline_bg_viewport.rect.x
    @sprites[:timeline_bg].y = y
    @sprites[:timeline_bg].z = -3
    # Timeline gridlines background
    @sprites[:timeline_bg2] = BitmapSprite.new(
      @timeline_bg_viewport.rect.width, TIME_BAR_HEIGHT + VIEWPORT_SPACING + @timeline_bg_viewport.rect.height, self.viewport
    )
    @sprites[:timeline_bg2].x = @timeline_bg_viewport.rect.x
    @sprites[:timeline_bg2].y = y
    @sprites[:timeline_bg2].z = -2
    # Time bar
    @sprites[:time_bar] = BitmapSprite.new(
      @timeline_bg_viewport.rect.width, TIME_BAR_HEIGHT, self.viewport
    )
    @sprites[:time_bar].x = @timeline_bg_viewport.rect.x
    @sprites[:time_bar].y = y
    @sprites[:time_bar].z = -1
    @sprites[:time_bar].bitmap.font.color = get_color_of(:text)
    @sprites[:time_bar].bitmap.font.size = TIME_BAR_TEXT_SIZE
    # Horizontal and vertical lines showing the selected row/keyframe
    initialize_selected_lines
  end

  # NOTE: This method is also called when changing the color scheme.
  def initialize_selected_lines
    # Vertical line showing the selected keyframe
    if !@sprites[:selected_keyframe]
      @sprites[:selected_keyframe] = BitmapSprite.new(
        3, height - UIControls::Scrollbar::SLIDER_WIDTH - (VIEWPORT_SPACING * 2), @position_viewport
      )
      @sprites[:selected_keyframe].ox = @sprites[:selected_keyframe].width / 2
    end
    @sprites[:selected_keyframe].bitmap.fill_rect(0, 0,
                                                  @sprites[:selected_keyframe].bitmap.width,
                                                  @sprites[:selected_keyframe].bitmap.height,
                                                  get_color_of(:selected_lines))
    # Horizontal line showing the selected row
    if !@sprites[:selected_row]
      @sprites[:selected_row] = BitmapSprite.new(
        @timeline_viewport.rect.width, 3, @timeline_viewport
      )
      @sprites[:selected_row].oy = @sprites[:selected_row].height / 2
      @sprites[:selected_row].z = -10
    end
    @sprites[:selected_row].bitmap.fill_rect(0, 0,
                                             @sprites[:selected_row].bitmap.width,
                                             @sprites[:selected_row].bitmap.height,
                                             get_color_of(:selected_lines))
  end

  def initialize_controls
    initialize_scrollbars
    initialize_buttons
    initialize_listed_particles
    refresh_all_row_positions_and_visibilities
    # For detecting a mouse button press in the time bar, including keeping the
    # button held and moving to quickly change the selected keyframe
    add_control_at(:time_bar, x + TIMELINE_X, y,
                   UIControls::ClickableArea.new(@timeline_viewport.rect.width, TIME_BAR_HEIGHT, self.viewport, false))
    initialize_rects
  end

  def initialize_scrollbars
    # Vertical scrollbar
    add_control_at(:v_scrollbar, x + width - UIControls::Scrollbar::SLIDER_WIDTH, @timeline_bg_viewport.rect.y,
                   UIControls::Scrollbar.new(@timeline_bg_viewport.rect.height, self.viewport, :vertical, true))
    # Horizontal scrollbar
    add_control_at(:h_scrollbar, @timeline_bg_viewport.rect.x, y + height - UIControls::Scrollbar::SLIDER_WIDTH,
                   UIControls::Scrollbar.new(@timeline_bg_viewport.rect.width, self.viewport, :horizontal, true))
    get_control(:h_scrollbar).range = TIME_BAR_LEFT_BUFFER + ((@duration + DURATION_BUFFER) * KEYFRAME_SPACING) + 1
    # NOTE: Don't need to set timeline_ox = get_control(:h_scrollbar).position
    #       because when initializing, both will be 0.
  end

  def initialize_buttons
    button_x = x + ADD_PARTICLE_BUTTON_X
    button_y = y + ADD_PARTICLE_BUTTON_Y
    add_control_at(:add_particle, button_x, button_y,
                   UIControls::BitmapButton.new(@viewport, @bitmaps[:add_particle]))
    button_x += BUTTON_SIZE + BUTTON_SPACING
    add_control_at(:move_particle_up, button_x, button_y,
                   UIControls::BitmapButton.new(@viewport, @bitmaps[:move_up]))
    button_x += BUTTON_SIZE + BUTTON_SPACING
    add_control_at(:move_particle_down, button_x, button_y,
                   UIControls::BitmapButton.new(@viewport, @bitmaps[:move_down]))
  end

  # These are areas of the screen used to detect various mouse interactions.
  # Note that the time bar has a control for this rather than a rect because
  # UIControls::ClickableArea can be "captured", which is useful because its
  # interactivity involves keeping the left mouse button held down rather than
  # simply detecting a one-off click.
  def initialize_rects
    # For scrolling the timeline using the mouse scroll wheel
    @scrollable_rect = Rect.new(
      LIST_X, LIST_Y,
      LIST_WIDTH + VIEWPORT_SPACING + @timeline_viewport.rect.width, @timeline_viewport.rect.height
    )
    # For detecting clicking on a new row or keyframe, changing them
    @list_rect = Rect.new(
      LIST_X, LIST_Y,
      LIST_WIDTH + VIEWPORT_SPACING, @timeline_viewport.rect.height
    )
    @timeline_rect = Rect.new(
      TIMELINE_X, TIMELINE_Y,
      @timeline_viewport.rect.width, @timeline_viewport.rect.height
    )
  end

  # NOTE: This method is also called when setting a whole new set of particles.
  def initialize_listed_particles
    @display_particles.each { |particle| particle.dispose }
    @display_particles.clear
    @particles.each_with_index do |particle, i|
      @display_particles[i] = create_new_listed_particle(particle)
    end
  end

  def create_new_listed_particle(particle)
    ret = AnimationEditor::ListedParticle.new(
      particle, @viewport, @list_viewport, @timeline_viewport, @timeline_bg_viewport
    )
    ret.duration = @duration
    ret.timeline_ox = @timeline_ox
    ret.selected_keyframe = @selected_keyframe
    ret.color_scheme = @color_scheme
    return ret
  end

  def dispose
    @display_particles.each { |particle| particle.dispose }
    @display_particles.clear
    @list_viewport.dispose
    @timeline_bg_viewport.dispose
    @position_viewport.dispose
    @timeline_viewport.dispose
    super
  end

  #-----------------------------------------------------------------------------

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    return if @bitmaps.empty?   # Nothing has been initialized yet
    @controls.each_value { |c| c.color_scheme = value }
    @display_particles.each { |particle| particle.color_scheme = value }
    @sprites[:time_bar].bitmap.font.color = get_color_of(:text)
    draw_bitmaps
    repaint
  end

  #-----------------------------------------------------------------------------

  def rows_count
    rows_count = 0
    @display_particles.each { |particle| rows_count += particle.visible_rows_count }
    return rows_count
  end

  def particle_index
    return -1 if @selected_row < 0
    ret = 0
    rows_count = 0
    @display_particles.each do |particle|
      rows = particle.visible_rows_count
      break if @selected_row < rows_count + rows
      rows_count += rows
      ret += 1
    end
    return ret
  end

  def particle_index_and_property
    return -1, nil if @selected_row < 0
    idx = 0
    property = nil
    rows_count = 0
    @display_particles.each do |particle|
      rows = particle.visible_rows_count
      break if @selected_row < rows_count + rows
      rows_count += rows
      idx += 1
    end
    property = @display_particles[idx].property_of_row(@selected_row - rows_count)
    return idx, property
  end

  def particle_index=(value)
    return if self.particle_index == value   # Already selecting a row for that particle
    old_val = @selected_row
    @selected_row = row_for_particle_index(value)
    return if @selected_row == old_val
    refresh_selected_row_sprite_position
    scroll_to_row(@selected_row)
  end

  def row_for_particle_index(index)
    rows_count = 0
    @display_particles.each_with_index do |particle, i|
      break if i >= index
      rows_count += particle.visible_rows_count
    end
    return rows_count
  end

  def selected_row=(value)
    value = value.clamp(0, rows_count - 1)
    return if @selected_row == value
    @selected_row = value
    refresh_selected_row_sprite_position
    scroll_to_row(@selected_row)
  end

  def selected_keyframe=(value)
    value = value.clamp(0, @duration + DURATION_BUFFER - 1)
    return if @selected_keyframe == value
    @selected_keyframe = value
    @display_particles.each { |particle| particle.selected_keyframe = @selected_keyframe }
    refresh_selected_keyframe_sprite_position
    scroll_to_keyframe(@selected_keyframe)
  end

  def timeline_ox=(value)
    old_val = @timeline_ox
    total_width = ((@duration + DURATION_BUFFER) * KEYFRAME_SPACING) + TIME_BAR_LEFT_BUFFER + 1
    if total_width <= @timeline_viewport.rect.width
      @timeline_ox = 0
    else
      @timeline_ox = value
      @timeline_ox = @timeline_ox.clamp(0, total_width - @timeline_viewport.rect.width)
    end
    return if @timeline_ox == old_val
    @display_particles.each { |particle| particle.timeline_ox = @timeline_ox }
    refresh_timeline_ox_moved
  end

  def timeline_oy=(value)
    old_val = @timeline_oy
    total_height = (rows_count * (AnimationEditor::ListedParticle::FULL_ROW_HEIGHT)) + AnimationEditor::ListedParticle::ROW_SPACING
    if total_height <= @list_viewport.rect.height
      @timeline_oy = 0
    else
      @timeline_oy = value
      @timeline_oy = @timeline_oy.clamp(0, total_height - @list_viewport.rect.height)
    end
    return if @timeline_oy == old_val
    @list_viewport.oy        = @timeline_oy
    @timeline_bg_viewport.oy = @timeline_oy
    @timeline_viewport.oy    = @timeline_oy
    refresh_timeline_oy_moved
  end

  def scroll_to_keyframe(new_keyframe)
    new_pos = TIME_BAR_LEFT_BUFFER + (new_keyframe * KEYFRAME_SPACING)
    if new_pos - (KEYFRAME_SPACING / 2) < @timeline_ox
      # Scroll left
      new_pos -= KEYFRAME_SPACING / 2
      scrollbar = get_control(:h_scrollbar)
      loop do
        scrollbar.slider_top -= 1
        break if scrollbar.position <= new_pos || scrollbar.minimum?
      end
      refresh_timeline_ox_moved
    elsif new_pos + (KEYFRAME_SPACING / 2) > @timeline_ox + @timeline_viewport.rect.width
      # Scroll right
      new_pos += (KEYFRAME_SPACING / 2) - @timeline_viewport.rect.width
      scrollbar = get_control(:h_scrollbar)
      loop do
        scrollbar.slider_top += 1
        break if scrollbar.position >= new_pos || scrollbar.maximum?
      end
      refresh_timeline_ox_moved
    end
  end

  def scroll_to_row(new_row)
    space_per_row = AnimationEditor::ListedParticle::FULL_ROW_HEIGHT
    new_pos = AnimationEditor::ListedParticle::ROW_SPACING + (new_row * space_per_row)
    if new_pos < @timeline_oy
      # Scroll up
      scrollbar = get_control(:v_scrollbar)
      loop do
        scrollbar.slider_top -= 1
        break if scrollbar.position <= new_pos || scrollbar.minimum?
      end
      refresh_timeline_oy_moved
    elsif new_pos + space_per_row > @timeline_oy + @timeline_viewport.rect.height
      # Scroll down
      new_pos += space_per_row - @timeline_viewport.rect.height
      scrollbar = get_control(:v_scrollbar)
      loop do
        scrollbar.slider_top += 1
        break if scrollbar.position >= new_pos || scrollbar.maximum?
      end
      refresh_timeline_oy_moved
    end
  end

  #-----------------------------------------------------------------------------

  def calculate_duration
    @duration = AnimationPlayer::Helper.get_duration(@particles)
    if get_control(:h_scrollbar)
      get_control(:h_scrollbar).range = TIME_BAR_LEFT_BUFFER + ((@duration + DURATION_BUFFER) * KEYFRAME_SPACING) + 1
      timeline_ox = get_control(:h_scrollbar).position
    end
  end

  # Called when a change is made to a particle's commands.
  def change_particle_commands(index)
    old_dur = @duration
    calculate_duration
    if @duration == old_dur
      change_particle(index)
    else
      refresh
      self.selected_keyframe = @selected_keyframe
      self.selected_row = @selected_row
    end
  end

  # Called when a change is made to a particle's general properties.
  def change_particle(index)
    @display_particles[index].refresh
  end

  #-----------------------------------------------------------------------------

  def add_particle(index)
    @display_particles.insert(index, create_new_listed_particle(@particles[index]))
    calculate_duration
    @display_particles.each { |particle| particle.duration = @duration }
    refresh_all_row_positions_and_visibilities
  end

  def delete_particle(index)
    @display_particles[index].dispose
    @display_particles.delete_at(index)
    calculate_duration
    @display_particles.each { |particle| particle.duration = @duration }
    refresh_all_row_positions_and_visibilities
    self.selected_keyframe = @selected_keyframe
    self.selected_row = @selected_row
  end

  def swap_particles(idx1, idx2)
    @display_particles[idx1], @display_particles[idx2] = @display_particles[idx2], @display_particles[idx1]
    refresh_all_row_positions_and_visibilities
  end

  # Used by undo/redo.
  def set_particles(new_particles)
    @particles = new_particles
    calculate_duration
    expansions = {}
    @display_particles.each do |particle|
      expansions[particle.particle[:name]] = Marshal.load(Marshal.dump(particle.groups_expanded))
    end
    initialize_listed_particles   # Disposes old @display_particles, makes new ones
    @display_particles.each { |particle| particle.duration = @duration }
    @display_particles.each do |particle|
      particle.groups_expanded = expansions[particle.particle[:name]] if expansions[particle.particle[:name]]
    end
    refresh_all_row_positions_and_visibilities
    self.selected_keyframe = @selected_keyframe
    self.selected_row = @selected_row
  end

  #-----------------------------------------------------------------------------

  def draw_bitmaps
    initialize_bitmaps
    initialize_background
    initialize_selected_lines
  end

  def draw_timeline_bg
    dur = @duration
    # Draw grey over the time after the end of the animation
    @sprites[:timeline_bg].bitmap.clear
    draw_x = TIME_BAR_LEFT_BUFFER + (dur * KEYFRAME_SPACING) - @timeline_ox
    greyed_width = @sprites[:timeline_bg].width - draw_x
    if greyed_width > 0
      @sprites[:timeline_bg].bitmap.fill_rect(
        draw_x, 0, greyed_width, TIME_BAR_HEIGHT, get_color_of(:after_end_bg)
      )
      @sprites[:timeline_bg].bitmap.fill_rect(
        draw_x, LIST_Y,
        greyed_width, @sprites[:timeline_bg].height - LIST_Y,
        get_color_of(:after_end_bg)
      )
    end
    # Draw vertical gridlines every 5 keyframes
    draw_frame = 0
    loop do
      draw_x = TIME_BAR_LEFT_BUFFER - @timeline_ox + (draw_frame * KEYFRAME_SPACING)
      break if draw_x >= @sprites[:timeline_bg2].width
      if draw_x >= 0
        grid_color = (draw_frame >= dur) ? get_color_of(:gridline_after_end) : get_color_of(:gridline)
        @sprites[:timeline_bg].bitmap.fill_rect(
          draw_x, TIME_BAR_HEIGHT, 1, @sprites[:timeline_bg2].height - TIME_BAR_HEIGHT, grid_color
        )
      end
      draw_frame += 5
    end
  end

  def draw_time_bar
    @sprites[:time_bar].bitmap.clear
    this_keyframe = 0
    loop do
      draw_x = TIME_BAR_LEFT_BUFFER + (this_keyframe * KEYFRAME_SPACING) - @timeline_ox
      if draw_x >= 0
        line_height = 6
        if (this_keyframe % 20) == 0
          line_height = TIME_BAR_HEIGHT - 2
        elsif (this_keyframe % 5) == 0
          line_height = TIME_BAR_HEIGHT / 2
        end
        @sprites[:time_bar].bitmap.fill_rect(
          draw_x, TIME_BAR_HEIGHT - line_height, 1, line_height, get_color_of(:text)
        )
      end
      if (this_keyframe % 5) == 0 && draw_x >= -KEYFRAME_SPACING
        text = this_keyframe.to_s
        draw_text(@sprites[:time_bar].bitmap, draw_x + 1, 0, text)
      end
      this_keyframe += 1
      break if draw_x + KEYFRAME_SPACING >= @sprites[:timeline_bg2].width
    end
  end

  #-----------------------------------------------------------------------------

  def repaint
    return if disposed?
    super
    @display_particles.each { |particle| particle.repaint }
  end

  def refresh
    calculate_duration
    @display_particles.each { |particle| particle.duration = @duration }
    @display_particles.each { |particle| particle.refresh }
    refresh_timeline_ox_moved
    refresh_timeline_oy_moved
    refresh_all_row_positions_and_visibilities
  end

  def refresh_timeline_ox_moved
    draw_timeline_bg
    draw_time_bar
    refresh_selected_keyframe_sprite_position
  end

  def refresh_timeline_oy_moved
    refresh_selected_row_sprite_position
  end

  def refresh_selected_keyframe_sprite_position
    @sprites[:selected_keyframe].visible = (@selected_keyframe >= 0)
    if @selected_keyframe >= 0
      @sprites[:selected_keyframe].x = TIME_BAR_LEFT_BUFFER + (@selected_keyframe * KEYFRAME_SPACING) - @timeline_ox
    end
  end

  def refresh_selected_row_sprite_position
    @sprites[:selected_row].visible = (@selected_row >= 0)
    if @selected_row >= 0
      row_height = AnimationEditor::ListedParticle::ROW_HEIGHT
      row_spacing = AnimationEditor::ListedParticle::ROW_SPACING
      new_pos = row_spacing + (@selected_row * (row_height + row_spacing))
      @sprites[:selected_row].y = new_pos + (row_height / 2)
    end
  end

  def refresh_all_row_positions_and_visibilities
    this_row = 0
    @display_particles.each do |particle|
      particle.refresh_all_row_positions_and_visibilities(this_row)
      this_row += particle.visible_rows_count
    end
    row_height = AnimationEditor::ListedParticle::ROW_HEIGHT
    row_spacing = AnimationEditor::ListedParticle::ROW_SPACING
    get_control(:v_scrollbar).range = row_spacing + (this_row * (row_height + row_spacing))
    timeline_oy = get_control(:v_scrollbar).position
  end

  #-----------------------------------------------------------------------------

  def update_controls_and_particles
    # Update only a thing that is being interacted with
    if @captured
      @captured.update
      @captured = nil if !@captured.busy?
      update_time_bar_control
      return
    end
    # Update controls
    @controls.each_value do |c|
      c.update
      @captured = c if c.busy?
    end
    # Update listed particles
    @display_particles.each_with_index do |particle, i|
      particle.update
      if particle.busy?
        @captured = particle
        @captured_index = i
      end
    end
  end

  # Clicking the left mouse button on the time bar changes the keyframe. You can
  # keep the left mouse button pressed and move it left/right to keep changing
  # the keyframe to wherever you move the mouse.
  def update_time_bar_control
    ctrl = get_control(:time_bar)
    if ctrl == @captured
      time_pos = ctrl.mouse_pos
      if time_pos && time_pos[0]
        this_keyframe = ((time_pos[0] + @timeline_ox - TIME_BAR_LEFT_BUFFER) / KEYFRAME_SPACING.to_f).round
        self.selected_keyframe = this_keyframe
      end
    end
    ctrl.clear_changed
  end

  def update_changed_controls_and_particles
    ret = false
    # Check for updated controls
    @controls.each_pair do |id, c|
      next if !c.changed?
      @changed_controls ||= {}
      @changed_controls[id] = c.value
      c.clear_changed
      ret = true
    end
    # Check for updated listed particles
    @display_particles.each_with_index do |particle, particle_index|
      next if !particle.changed?
      particle.changed_controls.each_pair do |row, value|
        if value[0] == AnimationEditor::ListedParticle::LIST_ARROW
          particle.toggle_group_visibility(row)
          self.selected_row = @selected_row
          refresh_all_row_positions_and_visibilities
        else
          @changed_controls ||= {}
          @changed_controls[row] = [particle_index, value[1]]   # [particle_index, value]
        end
      end
      particle.clear_changed
      ret = true
    end
    return ret
  end

  def update_input
    update_input_navigation
    update_input_left_click
    update_input_scroll_wheel
  end

  def update_input_navigation
    increment = (Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)) ? 5 : 1
    # A/D to change selected keyframe
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      self.selected_keyframe -= increment
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      self.selected_keyframe += increment
    end
    # W/S to change selected row
    if Input.triggerex?(:UP) || Input.repeatex?(:UP)
      self.selected_row -= increment
    elsif Input.triggerex?(:DOWN) || Input.repeatex?(:DOWN)
      self.selected_row += increment
    end
    # Tab to change selected particle
    if Input.triggerex?(:TAB) || Input.repeatex?(:TAB)
      if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT)
        if self.particle_index > 0
          self.particle_index -= 1
        else
          self.particle_index = @particles.length - 1
        end
      else
        if self.particle_index >= @particles.length - 1
          self.particle_index = 0
        else
          self.particle_index += 1
        end
      end
    end
  end

  # Change selected keyframe/row if clicked on.
  def update_input_left_click
    return if !Input.trigger?(Input::MOUSELEFT)
    pos = mouse_pos
    if pos[0] && pos[1] && (@list_rect.contains?(*pos) || @timeline_rect.contains?(*pos))
      if @timeline_rect.contains?(*pos)
        this_keyframe = ((pos[0] - @timeline_rect.x + @timeline_ox - TIME_BAR_LEFT_BUFFER) / KEYFRAME_SPACING.to_f).round
        self.selected_keyframe = this_keyframe if this_keyframe >= 0
      end
      this_row = (pos[1] - @timeline_rect.y + @timeline_oy - AnimationEditor::ListedParticle::ROW_SPACING) / AnimationEditor::ListedParticle::FULL_ROW_HEIGHT
      self.selected_row = this_row if this_row >= 0 && this_row < rows_count
    end
  end

  # Scroll timeline with mouse scroll wheel.
  def update_input_scroll_wheel
    wheel_v = Input.scroll_v
    return if wheel_v == 0
    if @scrollable_rect.contains?(*mouse_pos)
      if wheel_v > 0   # Scroll up
        if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT)
          get_control(:h_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
        else
          get_control(:v_scrollbar).slider_top -= UIControls::Scrollbar::SCROLL_DISTANCE
        end
      elsif wheel_v < 0   # Scroll down
        if Input.pressex?(:LSHIFT) || Input.pressex?(:RSHIFT)
          get_control(:h_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
        else
          get_control(:v_scrollbar).slider_top += UIControls::Scrollbar::SCROLL_DISTANCE
        end
      end
    end
  end

  def update
    return if disposed? || !@visible
    update_controls_and_particles
    changed = update_changed_controls_and_particles
    if !changed && !@captured &&
       (!@display_particles || @display_particles.none? { |ctrl| ctrl.choosing_interpolation? })
      update_input
    end
    # Refresh sprites if a scrollbar has been moved
    self.timeline_ox = get_control(:h_scrollbar).position
    self.timeline_oy = get_control(:v_scrollbar).position
    # Redraw controls if needed
    repaint
  end
end
