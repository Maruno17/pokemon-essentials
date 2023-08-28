#===============================================================================
#
#===============================================================================
class AnimationEditor::ControlPane < UIControls::ControlsContainer
  def on_control_release
    # TODO: Update data for @captured control, because it may have changed.
    #       Gather data from all controls in this container and put them in a
    #       hash; it's up to the main editor screen to notice/read it, edit
    #       animation data accordingly, and then tell this container to nil that
    #       hash again.
  end
end
