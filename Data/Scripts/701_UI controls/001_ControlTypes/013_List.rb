#===============================================================================
# TODO: TEXT_OFFSET_Y was replaced with ((@row_height - 16) / 2) here. Can it be
#       replaced with something similar elsewhere too?
#===============================================================================
class UIControls::List < UIControls::BaseControl
  attr_reader :options
  attr_reader :selected

  LIST_FRAME_THICKNESS = 2
  ROW_HEIGHT           = 24
  TEXT_PADDING_X       = 4

  def initialize(width, height, viewport, options = [], row_height = ROW_HEIGHT)
    super(width, height, viewport)
    @scrollbar = UIControls::Scrollbar.new(height - (LIST_FRAME_THICKNESS * 2), viewport)
    @scrollbar.x = width - UIControls::Scrollbar::SLIDER_WIDTH - LIST_FRAME_THICKNESS
    @scrollbar.y = LIST_FRAME_THICKNESS
    @scrollbar.color_scheme = @color_scheme
    @scrollbar.set_interactive_rects
    @scrollbar.range = row_height
    @scrollbar.z = self.z + 1
    @row_height = row_height
    @rows_count = (height / @row_height).floor   # Number of rows visible at once
    @top_row  = 0
    @selected = -1
    self.options = options
  end

  def dispose
    @scrollbar.dispose
    @scrollbar = nil
    super
  end

  #-----------------------------------------------------------------------------

  def x=(new_val)
    super(new_val)
    @scrollbar.x = new_val + width - UIControls::Scrollbar::SLIDER_WIDTH - LIST_FRAME_THICKNESS
  end

  def y=(new_val)
    super(new_val)
    @scrollbar.y = new_val + LIST_FRAME_THICKNESS
  end

  def z=(new_val)
    super(new_val)
    @scrollbar.z = new_val + 1
  end

  def visible=(new_val)
    super
    @scrollbar.visible = new_val
  end

  def color_scheme=(value)
    return if @color_scheme == value
    @color_scheme = value
    self.bitmap.font.color = get_color_of(:text)
    self.bitmap.font.size = text_size
    @scrollbar&.color_scheme = value
    invalidate if self.respond_to?(:invalidate)
  end

  # Each value in @options is an array: [id, text].
  def options=(new_vals)
    @options = new_vals
    set_interactive_rects
    @scrollbar.range = [@options.length, 1].max * @row_height
    if @scrollbar.visible
      self.top_row = (@scrollbar.position.to_f / @row_height).round
    else
      self.top_row = 0
    end
    self.selected = -1 if @selected >= @options.length
    invalidate
  end

  # Returns the ID of the selected row.
  def value
    return nil if @selected < 0
    if @options.is_a?(Array)
      return (@options[@selected].is_a?(Array)) ? @options[@selected][0] : @selected
    elsif @options.is_a?(Hash)
      return @options.keys[@selected]
    end
    return nil
  end

  def top_row=(val)
    old_val = @top_row
    @top_row = val
    if @scrollbar.visible
      @top_row = @top_row.clamp(0, @options.length - @rows_count)
    else
      @top_row = 0
    end
    invalidate if @top_row != old_val
  end

  def selected=(val)
    return if @selected == val
    @selected = val
    invalidate
  end

  #-----------------------------------------------------------------------------

  def mouse_in_control?
    mouse_x, mouse_y = mouse_pos
    return false if !mouse_x || !mouse_y
    return true if Rect.new(0, 0, width, height).contains?(mouse_x, mouse_y)
    return true if @scrollbar.mouse_in_control?
    return false
  end

  def busy?
    return !@captured_area.nil?
  end

  #-----------------------------------------------------------------------------

  def set_interactive_rects
    @interactions = {}
    @options.length.times do |i|
      @interactions[i] = Rect.new(
        LIST_FRAME_THICKNESS, LIST_FRAME_THICKNESS + (@row_height * i),
        width - (LIST_FRAME_THICKNESS * 2), @row_height
      )
    end
  end

  #-----------------------------------------------------------------------------

  def draw_background
    self.bitmap.fill_rect(0, 0, width, height, get_color_of(:control_background))
  end

  def draw_area_highlight
    # If a row is captured, it will automatically be selected and the selection
    # color will be drawn over the highlight. There's no point drawing a
    # highlight at all if anything is captured.
    return if @captured_area
    # Draw mouse hover over row highlight
    rect = @interactions[@hover_area]
    if rect
      rect_y = rect.y
      rect_y -= @top_row * @row_height if @hover_area.is_a?(Integer)
      self.bitmap.fill_rect(rect.x, rect_y, rect.width, rect.height, get_color_of(:hover))
    end
  end

  def repaint
    @scrollbar.repaint if @scrollbar.invalid?
    super if invalid?
  end

  def refresh
    super
    # Draw control outline
    self.bitmap.outline_rect(0, 0, width, height, get_color_of(:line))
    # Draw text options
    @options.each_with_index do |val, i|
      next if i < @top_row || i >= @top_row + @rows_count
      if @selected == i
        self.bitmap.fill_rect(
           @interactions[i].x,
           @interactions[i].y - (@top_row * @row_height),
           @interactions[i].width, @interactions[i].height,
           get_color_of(:highlight)
         )
      end
      txt = (val.is_a?(Array)) ? val[1] : val.to_s
      old_text_color = self.bitmap.font.color.clone
      if txt[/^\\c\[([0-9]+)\]/i]
        text_colors = [
          [  0, 112, 248], [120, 184, 232],   # 1  Blue
          [232,  32,  16], [248, 168, 184],   # 2  Red
          [ 96, 176,  72], [174, 208, 144],   # 3  Green
          [ 72, 216, 216], [168, 224, 224],   # 4  Cyan
          [208,  56, 184], [232, 160, 224],   # 5  Magenta
          [232, 208,  32], [248, 232, 136],   # 6  Yellow
          [160, 160, 168], [208, 208, 216],   # 7  Gray
          [240, 240, 248], [200, 200, 208],   # 8  White
          [114,  64, 232], [184, 168, 224],   # 9  Purple
          [248, 152,  24], [248, 200, 152],   # 10 Orange
          MessageConfig::DARK_TEXT_MAIN_COLOR,
          MessageConfig::DARK_TEXT_SHADOW_COLOR,   # 11 Dark default
          MessageConfig::LIGHT_TEXT_MAIN_COLOR,
          MessageConfig::LIGHT_TEXT_SHADOW_COLOR   # 12 Light default
        ]
        self.bitmap.font.color = Color.new(*text_colors[2 * ($1.to_i - 1)])
        txt = txt.gsub(/^\\c\[[0-9]+\]/i, "")
      end
      draw_text(self.bitmap,
                @interactions[i].x + TEXT_PADDING_X,
                @interactions[i].y + ((@row_height - 16) / 2) - (@top_row * @row_height),
                txt)
      self.bitmap.font.color = old_text_color
    end
  end

  #-----------------------------------------------------------------------------

  def on_mouse_press
    @captured_area = nil
    mouse_x, mouse_y = mouse_pos
    return if !mouse_x || !mouse_y
    return if @scrollbar.visible && (@scrollbar.busy? || mouse_x >= @scrollbar.x - self.x)
    # Check for mouse presses on rows
    mouse_y += @top_row * @row_height
    @interactions.each_pair do |area, rect|
      next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
      next if !rect.contains?(mouse_x, mouse_y)
      @captured_area = area
      invalidate
      break
    end
  end

  def on_mouse_release
    return if !@captured_area   # Wasn't captured to begin with
    set_changed
    super
  end

  def update_hover_highlight
    # Remove the hover highlight if there are no interactions for this control
    # or if the mouse is off-screen
    mouse_x, mouse_y = mouse_pos
    if !@interactions || @interactions.empty? || !mouse_x || !mouse_y
      invalidate if @hover_area
      @hover_area = nil
      return
    end
    # Don't update the highlight if the mouse is using the scrollbar
    if @scrollbar.visible && (@scrollbar.busy? || mouse_x >= @scrollbar.x - self.x)
      invalidate if @hover_area
      @hover_area = nil
      return
    end
    # Check each interactive area for whether the mouse is hovering over it, and
    # set @hover_area accordingly
    in_area = false
    mouse_y += @top_row * @row_height
    @interactions.each_pair do |area, rect|
      next if !area.is_a?(Integer) || area < @top_row || area >= @top_row + @rows_count
      next if !rect.contains?(mouse_x, mouse_y)
      invalidate if @hover_area != area
      @hover_area = area
      in_area = true
      break
    end
    if !in_area
      invalidate if @hover_area
      @hover_area = nil
    end
  end

  def update
    return if !self.visible
    @scrollbar.update
    super
    # Refresh the list's position if changed by moving the scrollbar
    self.top_row = (@scrollbar.position.to_f / @row_height).round
    # Set the selected row to the row the mouse is over, if clicked on
    if @captured_area
      @selected = @hover_area if @hover_area.is_a?(Integer)
    elsif @hover_area
      wheel_v = Input.scroll_v
      scroll_dist = UIControls::Scrollbar::SCROLL_DISTANCE
      scroll_dist /= 2 if @options.length / @rows_count > 20   # Arbitrary 20
      if wheel_v > 0   # Scroll up
        @scrollbar.slider_top -= scroll_dist
      elsif wheel_v < 0   # Scroll down
        @scrollbar.slider_top += scroll_dist
      end
      if wheel_v != 0
        self.top_row = (@scrollbar.position.to_f / @row_height).round
        update_hover_highlight
      end
    end
  end
end
