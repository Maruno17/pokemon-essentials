#===============================================================================
#
#===============================================================================
class AnimationEditor::MenuBar < UIControls::ControlsContainer
  MENU_BUTTON_WIDTH     = 80
  SETTINGS_BUTTON_WIDTH = 30
  NAME_BUTTON_WIDTH     = 400   # The animation's name

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

  def add_settings_button(id, bitmap)
    ctrl = UIControls::BitmapButton.new(0, 0, @viewport, bitmap)
    add_control_at(id, ctrl, @width - SETTINGS_BUTTON_WIDTH + 2, 2)
  end

  def add_name_button(id, button_text)
    ctrl = UIControls::Button.new(NAME_BUTTON_WIDTH, @height, @viewport, button_text)
    ctrl.set_fixed_size
    add_control_at(id, ctrl, @width - ctrl.width - SETTINGS_BUTTON_WIDTH, 0)
  end

  def anim_name=(val)
    ctrl = get_control(:name)
    ctrl.set_text(val) if ctrl
  end

  #-----------------------------------------------------------------------------

  private

  def next_control_position(add_offset = false)
    row_x = @row_count * MENU_BUTTON_WIDTH
    row_y = 0
    return row_x, row_y
  end
end
