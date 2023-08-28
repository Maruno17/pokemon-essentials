#===============================================================================
# TODO
# TODO: Click an option to select it. It remains selected indefinitely. Once an
#       option is selected, there's probably no way to unselect everything; the
#       selection can only be moved to a different option.
# TODO: Scrollable.
# TODO: Find some way to not redraw the entire thing if the hovered option
#       changes. Maybe have another bitmap to write the text on (refreshed only
#       when the list is scrolled), and self's bitmap draws the hover colour
#       only.
#===============================================================================
class UIControls::List < UIControls::BaseControl
end
