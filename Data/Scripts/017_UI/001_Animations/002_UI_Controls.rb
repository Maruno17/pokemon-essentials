#==============================================================================
# * Scene_Controls
#------------------------------------------------------------------------------
# Shows a help screen listing the keyboard controls.
# Display with:
#      pbEventScreen(ButtonEventScene)
#==============================================================================
class ButtonEventScene < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/helpbg")
    @labels = [
      addLabel(52 * 2, 13 * 2, Graphics.width * 3 / 4, _INTL("Moves the main character. Also used to scroll through list entries.")),
      addLabel(52 * 2, 53 * 2, Graphics.width * 3 / 4, _INTL("Used to confirm a choice, check things, and talk to people.")),
      addLabel(52 * 2, 93 * 2, Graphics.width * 3 / 4, _INTL("Used to exit, cancel a choice or mode, and open the pause menu.")),
      addLabel(52 * 2, 133 * 2, Graphics.width * 3 / 4, _INTL("Hold down while walking to run.")),
      addLabel(52 * 2, 157 * 2, Graphics.width * 3 / 4, _INTL("Press to use a registered Key Item."))
    ]
    @keys = [
      addImage(26 * 2, 18 * 2, "Graphics/Pictures/helpArrowKeys"),
      addImage(26 * 2, 59 * 2, "Graphics/Pictures/helpCkey"),
      addImage(26 * 2, 99 * 2, "Graphics/Pictures/helpXkey"),
      addImage(26 * 2, 130 * 2, "Graphics/Pictures/helpZkey"),
      addImage(26 * 2, 154 * 2, "Graphics/Pictures/helpFkey")
    ]
    for key in @keys
      key.origin = PictureOrigin::Top
    end
    for i in 0...5   # Make everything show (almost) immediately
      @keys[i].setOrigin(0, PictureOrigin::Top)
      @keys[i].setOpacity(0, 255)
    end
    pictureWait   # Update event scene with the changes
    Graphics.transition(20)
    # Go to next screen when user presses C
    onCTrigger.set(method(:pbOnScreen1))
  end

  def pbOnScreen1(scene,*args)
    # End scene
    Graphics.freeze
    scene.dispose
    Graphics.transition(20)
  end
end
