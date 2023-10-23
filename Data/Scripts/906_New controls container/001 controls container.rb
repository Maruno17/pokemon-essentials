#===============================================================================
# Controls are arranged in a list in self's bitmap. Each control is given a
# "self's bitmap's width" x LINE_SPACING area of self's bitmap to draw itself
# in.
# TODO: The act of "capturing" a control makes other controls in this container
#       not update themselves, i.e. they won't colour themselves with a hover
#       highlight if the mouse happens to move over it while another control is
#       captured. Is there a better way of dealing with this? I'm leaning
#       towards the control itself deciding if it's captured, and it being
#       treated as uncaptured once it says its value has changed, but I think
#       this would require manually telling all other controls in this container
#       that something else is captured and they shouldn't show a hover
#       highlight when updated (perhaps as a parameter in def update), which I
#       don't think is ideal.
#===============================================================================
class UIControls::ControlsContainer
  attr_reader :x, :y
  attr_reader :controls
  attr_reader :values
  attr_reader :visible

  LINE_SPACING        = 28
  OFFSET_FROM_LABEL_X = 90
  OFFSET_FROM_LABEL_Y = 0

  def initialize(x, y, width, height)
    @viewport = Viewport.new(x, y, width, height)
    @viewport.z = 99999
    @x = x
    @y = y
    @width = width
    @height = height
    @controls = []
    @control_rects = []
    @row_count = 0
    @captured = nil
    @visible = true
  end

  def dispose
    @controls.each { |c| c[1]&.dispose }
    @controls.clear
    @viewport.dispose
  end

  def busy?
    return !@captured.nil?
  end

  def changed?
    return !@values.nil?
  end

  def clear_changed
    @values = nil
  end

  def visible=(value)
    @visible = value
    @controls.each { |c| c[1].visible = value }
    repaint if @visible
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

  def add_label(id, label, has_label = false)
    id = (id.to_s + "_label").to_sym
    add_control(id, UIControls::Label.new(*control_size(has_label), @viewport, label), has_label)
  end

  def add_checkbox(id, value, has_label = false)
    add_control(id, UIControls::Checkbox.new(*control_size(has_label), @viewport, value), has_label)
  end

  def add_labelled_checkbox(id, label, value)
    add_label(id, label)
    add_checkbox(id, value, true)
  end

  def add_text_box(id, value, has_label = false)
    add_control(id, UIControls::TextBox.new(*control_size(has_label), @viewport, value), has_label)
  end

  def add_labelled_text_box(id, label, value)
    add_label(id, label)
    add_text_box(id, value, true)
  end

  def add_slider(id, min_value, max_value, value, has_label = false)
    add_control(id, UIControls::Slider.new(*control_size(has_label), @viewport, min_value, max_value, value), has_label)
  end

  def add_labelled_slider(id, label, min_value, max_value, value)
    add_label(id, label)
    add_slider(id, min_value, max_value, value, true)
  end

  def add_value_box(id, min_value, max_value, value, has_label = false)
    add_control(id, UIControls::ValueBox.new(*control_size(has_label), @viewport, min_value, max_value, value), has_label)
  end

  def add_labelled_value_box(id, label, min_value, max_value, value)
    add_label(id, label)
    add_value_box(id, min_value, max_value, value, true)
  end

  def add_button(id, button_text, has_label = false)
    add_control(id, UIControls::Button.new(*control_size(has_label), @viewport, button_text), has_label)
  end

  def add_labelled_button(id, label, button_text)
    add_label(id, label)
    add_button(id, button_text, true)
  end

  def add_dropdown_list(id, options, value, has_label = false)
    add_control(id, UIControls::DropdownList.new(*control_size(has_label), @viewport, options, value), has_label)
  end

  def add_labelled_dropdown_list(id, label, options, value)
    add_label(id, label)
    add_dropdown_list(id, options, value, true)
  end

  #-----------------------------------------------------------------------------

  def repaint
    @controls.each { |ctrl| ctrl[1].repaint }
  end

  #-----------------------------------------------------------------------------

  def update
    return if !@visible
    # Update controls
    if @captured
      # TODO: Ideally all controls will be updated here, if only to redraw
      #       themselves if they happen to be invalidated somehow. But that
      #       involves telling each control whether any other control is busy,
      #       to ensure that they don't show their hover colours or anything,
      #       which is fiddly and I'm not sure if it's the best approach.
      @captured.update
      @captured = nil if !@captured.busy?
    else
      @controls.each do |ctrl|
        ctrl[1].update
        @captured = ctrl[1] if ctrl[1].busy?
      end
    end
    # Check for updated controls
    @controls.each do |ctrl|
      next if !ctrl[1].changed?
      @values ||= {}
      @values[ctrl[0]] = ctrl[1].value
      ctrl[1].clear_changed
    end
    # Redraw controls if needed
    repaint
  end

  #-----------------------------------------------------------------------------

  private

  def control_size(has_label = false)
    if has_label
      return @width - OFFSET_FROM_LABEL_X, LINE_SPACING - OFFSET_FROM_LABEL_Y
    end
    return @width, LINE_SPACING
  end

  def add_control(id, control, add_offset = false)
    i = @controls.length
    control_y = (add_offset ? @row_count - 1 : @row_count) * LINE_SPACING
    @control_rects[i] = Rect.new(0, control_y, control.width, control.height)
    control.x = @control_rects[i].x + (add_offset ? OFFSET_FROM_LABEL_X : 0)
    control.y = @control_rects[i].y + (add_offset ? OFFSET_FROM_LABEL_Y : 0)
    control.set_interactive_rects
    @controls[i] = [id, control]
    @row_count += 1 if !add_offset
    repaint
  end
end
