#===============================================================================
# TODO: Ideally the menu buttons (add_button) will be replaced by a proper
#       menu control (basically multiple DropdownList controls where the headers
#       have fixed names and, while captured, hovering over a header changes
#       which list is displayed). The menu control should go under UI controls
#       rather than be unique to the Animation Editor.
#===============================================================================
class AnimationEditor::MenuBar < UIControls::ControlsContainer
  MENU_BUTTON_WIDTH = 80
  NAME_BUTTON_WIDTH = 400   # The animation's name

  def initialize(x, y, width, height, viewport)
    super(x, y, width, height)
    @viewport.z = viewport.z + 10   # So that it appears over the canvas
  end

  #-----------------------------------------------------------------------------

  def add_button(id, button_text)
    ctrl = UIControls::Button.new(MENU_BUTTON_WIDTH, @height, @viewport, button_text)
    ctrl.set_fixed_size
    add_control(id, ctrl)
  end

  def add_name_button(id, button_text)
    ctrl = UIControls::Button.new(NAME_BUTTON_WIDTH, @height, @viewport, button_text)
    ctrl.set_fixed_size
    add_control(id, ctrl)
  end

  def anim_name=(val)
    ctrl = get_control(:name)
    ctrl.set_text(val) if ctrl
  end

  #-----------------------------------------------------------------------------

  private

  def add_control(id, control, add_offset = false)
    i = @controls.length
    control_x = (add_offset ? @row_count - 1 : @row_count) * MENU_BUTTON_WIDTH
    control_x = @width - control.width if control.width == NAME_BUTTON_WIDTH
    @control_rects[i] = Rect.new(control_x, 0, control.width, control.height)
    control.x = @control_rects[i].x + (add_offset ? OFFSET_FROM_LABEL_X : 0)
    control.y = @control_rects[i].y + (add_offset ? OFFSET_FROM_LABEL_Y : 0)
    control.set_interactive_rects
    @controls[i] = [id, control]
    @row_count += 1 if !add_offset
    repaint
  end
end
