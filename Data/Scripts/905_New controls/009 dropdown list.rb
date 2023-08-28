#===============================================================================
# TODO
#===============================================================================
class UIControls::DropdownList < UIControls::BaseControl
  def initialize(width, height, viewport, options, value)
    # NOTE: options is a hash: keys are symbols, values are display names.
    super(width, height, viewport)
  end
end
