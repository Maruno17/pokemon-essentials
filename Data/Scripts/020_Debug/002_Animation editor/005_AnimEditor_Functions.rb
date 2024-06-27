#===============================================================================
#
#===============================================================================
module BattleAnimationEditor
  module_function

  #=============================================================================
  # Mini battle scene.
  #=============================================================================
  class MiniBattler
    attr_accessor :index
    attr_accessor :pokemon

    def initialize(index); self.index = index; end
  end

  #=============================================================================
  #
  #=============================================================================
  class MiniBattle
    attr_accessor :battlers

    def initialize
      @battlers = []
      4.times { |i| @battlers[i] = MiniBattler.new(i) }
    end
  end

  #=============================================================================
  # Pop-up menus for buttons in bottom menu.
  #=============================================================================
  def pbSelectAnim(canvas, animwin)
    animfiles = []
    pbRgssChdir(File.join("Graphics", "Animations")) { animfiles.concat(Dir.glob("*.png")) }
    cmdwin = pbListWindow(animfiles, 320)
    cmdwin.opacity = 200
    cmdwin.height = 512
    bmpwin = BitmapDisplayWindow.new(320, 0, 320, 448)
    ctlwin = ControlWindow.new(320, 448, 320, 64)
    cmdwin.viewport = canvas.viewport
    bmpwin.viewport = canvas.viewport
    ctlwin.viewport = canvas.viewport
    ctlwin.addSlider(_INTL("Hue:"), 0, 359, 0)
    loop do
      bmpwin.bitmapname = cmdwin.commands[cmdwin.index]
      Graphics.update
      Input.update
      cmdwin.update
      bmpwin.update
      ctlwin.update
      bmpwin.hue = ctlwin.value(0) if ctlwin.changed?(0)
      if Input.trigger?(Input::USE) && animfiles.length > 0
        filename = cmdwin.commands[cmdwin.index]
        bitmap = AnimatedBitmap.new("Graphics/Animations/" + filename, ctlwin.value(0)).deanimate
        canvas.animation.graphic = File.basename(filename, ".*")
        canvas.animation.hue = ctlwin.value(0)
        canvas.animbitmap = bitmap
        animwin.animbitmap = bitmap
        break
      end
      if Input.trigger?(Input::BACK)
        break
      end
    end
    bmpwin.dispose
    cmdwin.dispose
    ctlwin.dispose
    return
  end

  def pbChangeMaximum(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 4)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.addSlider(_INTL("Frames:"), 1, 1000, canvas.animation.length)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    sliderwin2.opacity = 200
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        canvas.animation.resize(sliderwin2.value(0))
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbAnimName(animation, cmdwin)
    window = ControlWindow.new(320, 128, 320, 32 * 4)
    window.z = 99999
    window.addControl(TextField.new(_INTL("New Name:"), animation.name))
    Input.text_input = true
    okbutton = window.addButton(_INTL("OK"))
    cancelbutton = window.addButton(_INTL("Cancel"))
    window.opacity = 224
    loop do
      Graphics.update
      Input.update
      window.update
      if window.changed?(okbutton) || Input.triggerex?(:RETURN)
        cmdwin.commands[cmdwin.index] = _INTL("{1} {2}", cmdwin.index, window.controls[0].text)
        animation.name = window.controls[0].text
        break
      end
      if window.changed?(cancelbutton) || Input.triggerex?(:ESCAPE)
        break
      end
    end
    window.dispose
    Input.text_input = false
    return
  end

  def pbAnimList(animations, canvas, animwin)
    commands = []
    animations.length.times do |i|
      animations[i] = PBAnimation.new if !animations[i]
      commands[commands.length] = _INTL("{1} {2}", i, animations[i].name)
    end
    cmdwin = pbListWindow(commands, 320)
    cmdwin.height = 416
    cmdwin.opacity = 224
    cmdwin.index = animations.selected
    cmdwin.viewport = canvas.viewport
    helpwindow = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Enter: Load/rename an animation\nEsc: Cancel"),
      320, 0, 320, 128, canvas.viewport
    )
    maxsizewindow = ControlWindow.new(0, 416, 320, 32 * 3)
    maxsizewindow.addSlider(_INTL("Total Animations:"), 1, 2000, animations.length)
    maxsizewindow.addButton(_INTL("Resize Animation List"))
    maxsizewindow.opacity = 224
    maxsizewindow.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      maxsizewindow.update
      helpwindow.update
      if maxsizewindow.changed?(1)
        newsize = maxsizewindow.value(0)
        animations.resize(newsize)
        commands.clear
        animations.length.times do |i|
          commands[commands.length] = _INTL("{1} {2}", i, animations[i].name)
        end
        cmdwin.commands = commands
        cmdwin.index = animations.selected
        next
      end
      if Input.trigger?(Input::USE) && animations.length > 0
        cmd2 = pbShowCommands(helpwindow,
                              [_INTL("Load Animation"),
                               _INTL("Rename"),
                               _INTL("Delete")], -1)
        case cmd2
        when 0   # Load Animation
          canvas.loadAnimation(animations[cmdwin.index])
          animwin.animbitmap = canvas.animbitmap
          animations.selected = cmdwin.index
          break
        when 1   # Rename
          pbAnimName(animations[cmdwin.index], cmdwin)
          cmdwin.refresh
        when 2   # Delete
          if pbConfirmMessage(_INTL("Are you sure you want to delete this animation?"))
            animations[cmdwin.index] = PBAnimation.new
            cmdwin.commands[cmdwin.index] = _INTL("{1} {2}", cmdwin.index, animations[cmdwin.index].name)
            cmdwin.refresh
          end
        end
      end
      if Input.trigger?(Input::BACK)
        break
      end
    end
    helpwindow.dispose
    maxsizewindow.dispose
    cmdwin.dispose
  end

  #=============================================================================
  # Pop-up menus for individual cels.
  #=============================================================================
  def pbChooseNum(cel)
    ret = cel
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 5)
    sliderwin2.z = 99999
    sliderwin2.addLabel(_INTL("Old Number: {1}", cel))
    sliderwin2.addSlider(_INTL("New Number:"), 2, PBAnimation::MAX_SPRITES, cel)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        ret = sliderwin2.value(1)
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        ret = -1
        break
      end
    end
    sliderwin2.dispose
    return ret
  end

  def pbSetTone(cel, previewsprite)
    sliderwin2 = ControlWindow.new(0, 0, 320, 320)
    sliderwin2.z = 99999
    sliderwin2.addSlider(_INTL("Red Offset:"), -255, 255, cel[AnimFrame::TONERED])
    sliderwin2.addSlider(_INTL("Green Offset:"), -255, 255, cel[AnimFrame::TONEGREEN])
    sliderwin2.addSlider(_INTL("Blue Offset:"), -255, 255, cel[AnimFrame::TONEBLUE])
    sliderwin2.addSlider(_INTL("Gray Tone:"), 0, 255, cel[AnimFrame::TONEGRAY])
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    loop do
      previewsprite.tone.set(sliderwin2.value(0), sliderwin2.value(1),
                             sliderwin2.value(2), sliderwin2.value(3))
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        cel[AnimFrame::TONERED] = sliderwin2.value(0)
        cel[AnimFrame::TONEGREEN] = sliderwin2.value(1)
        cel[AnimFrame::TONEBLUE] = sliderwin2.value(2)
        cel[AnimFrame::TONEGRAY] = sliderwin2.value(3)
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbSetFlash(cel, previewsprite)
    sliderwin2 = ControlWindow.new(0, 0, 320, 320)
    sliderwin2.z = 99999
    sliderwin2.addSlider(_INTL("Red:"), 0, 255, cel[AnimFrame::COLORRED])
    sliderwin2.addSlider(_INTL("Green:"), 0, 255, cel[AnimFrame::COLORGREEN])
    sliderwin2.addSlider(_INTL("Blue:"), 0, 255, cel[AnimFrame::COLORBLUE])
    sliderwin2.addSlider(_INTL("Alpha:"), 0, 255, cel[AnimFrame::COLORALPHA])
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    loop do
      previewsprite.tone.set(sliderwin2.value(0), sliderwin2.value(1),
                             sliderwin2.value(2), sliderwin2.value(3))
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        cel[AnimFrame::COLORRED] = sliderwin2.value(0)
        cel[AnimFrame::COLORGREEN] = sliderwin2.value(1)
        cel[AnimFrame::COLORBLUE] = sliderwin2.value(2)
        cel[AnimFrame::COLORALPHA] = sliderwin2.value(3)
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbCellProperties(canvas)
    cel = canvas.currentCel.clone # Clone cell, in case operation is canceled
    return if !cel
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 16)
    previewwin = ControlWindow.new(320, 0, 192, 192)
    sliderwin2.viewport = canvas.viewport
    previewwin.viewport = canvas.viewport
    previewsprite = Sprite.new(canvas.viewport)
    previewsprite.bitmap = canvas.animbitmap
    previewsprite.z = previewwin.z + 1
    sliderwin2.z = previewwin.z + 2
    set0 = sliderwin2.addSlider(_INTL("Pattern:"), -2, 1000, cel[AnimFrame::PATTERN])
    set1 = sliderwin2.addSlider(_INTL("X:"), -64, 512 + 64, cel[AnimFrame::X])
    set2 = sliderwin2.addSlider(_INTL("Y:"), -64, 384 + 64, cel[AnimFrame::Y])
    set3 = sliderwin2.addSlider(_INTL("Zoom X:"), 5, 1000, cel[AnimFrame::ZOOMX])
    set4 = sliderwin2.addSlider(_INTL("Zoom Y:"), 5, 1000, cel[AnimFrame::ZOOMY])
    set5 = sliderwin2.addSlider(_INTL("Angle:"), 0, 359, cel[AnimFrame::ANGLE])
    set6 = sliderwin2.addSlider(_INTL("Opacity:"), 0, 255, cel[AnimFrame::OPACITY])
    set7 = sliderwin2.addSlider(_INTL("Blending:"), 0, 2, cel[AnimFrame::BLENDTYPE])
    set8 = sliderwin2.addTextSlider(_INTL("Flip:"), [_INTL("False"), _INTL("True")], cel[AnimFrame::MIRROR])
    prio = [_INTL("Back"), _INTL("Front"), _INTL("Behind focus"), _INTL("Above focus")]
    set9 = sliderwin2.addTextSlider(_INTL("Priority:"), prio, cel[AnimFrame::PRIORITY] || 1)
    foc = [_INTL("User"), _INTL("Target"), _INTL("User and target"), _INTL("Screen")]
    curfoc = [3, 1, 0, 2, 3][cel[AnimFrame::FOCUS] || canvas.animation.position || 4]
    set10 = sliderwin2.addTextSlider(_INTL("Focus:"), foc, curfoc)
    flashbutton = sliderwin2.addButton(_INTL("Set Blending Color"))
    tonebutton = sliderwin2.addButton(_INTL("Set Color Tone"))
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    # Set X and Y for preview sprite
    cel[AnimFrame::X] = 320 + 96
    cel[AnimFrame::Y] = 96
    canvas.setSpriteBitmap(previewsprite, cel)
    pbSpriteSetAnimFrame(previewsprite, cel, nil, nil)
    previewsprite.z = previewwin.z + 1
    sliderwin2.opacity = 200
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(set0) ||
         sliderwin2.changed?(set3) ||
         sliderwin2.changed?(set4) ||
         sliderwin2.changed?(set5) ||
         sliderwin2.changed?(set6) ||
         sliderwin2.changed?(set7) ||
         sliderwin2.changed?(set8) ||
         sliderwin2.changed?(set9) ||
         sliderwin2.changed?(set10)
        # Update preview sprite
        cel[AnimFrame::PATTERN] = sliderwin2.value(set0) if set0 >= 0
        cel[AnimFrame::ZOOMX] = sliderwin2.value(set3)
        cel[AnimFrame::ZOOMY] = sliderwin2.value(set4)
        cel[AnimFrame::ANGLE] = sliderwin2.value(set5)
        cel[AnimFrame::OPACITY] = sliderwin2.value(set6)
        cel[AnimFrame::BLENDTYPE] = sliderwin2.value(set7)
        cel[AnimFrame::MIRROR] = sliderwin2.value(set8)
        cel[AnimFrame::PRIORITY] = sliderwin2.value(set9)
        cel[AnimFrame::FOCUS] = [2, 1, 3, 4][sliderwin2.value(set10)]
        canvas.setSpriteBitmap(previewsprite, cel)
        pbSpriteSetAnimFrame(previewsprite, cel, nil, nil)
        previewsprite.z = previewwin.z + 1
      end
      if sliderwin2.changed?(flashbutton)
        pbSetFlash(cel, previewsprite)
        pbSpriteSetAnimFrame(previewsprite, cel, nil, nil)
        previewsprite.z = previewwin.z + 1
      end
      if sliderwin2.changed?(tonebutton)
        pbSetTone(cel, previewsprite)
        pbSpriteSetAnimFrame(previewsprite, cel, nil, nil)
        previewsprite.z = previewwin.z + 1
      end
      if sliderwin2.changed?(okbutton)
        cel[AnimFrame::PATTERN] = sliderwin2.value(set0) if set0 >= 0
        cel[AnimFrame::X] = sliderwin2.value(set1)
        cel[AnimFrame::Y] = sliderwin2.value(set2)
        cel[AnimFrame::ZOOMX] = sliderwin2.value(set3)
        cel[AnimFrame::ZOOMY] = sliderwin2.value(set4)
        cel[AnimFrame::ANGLE] = sliderwin2.value(set5)
        cel[AnimFrame::OPACITY] = sliderwin2.value(set6)
        cel[AnimFrame::BLENDTYPE] = sliderwin2.value(set7)
        cel[AnimFrame::MIRROR] = sliderwin2.value(set8)
        cel[AnimFrame::PRIORITY] = sliderwin2.value(set9)
        cel[AnimFrame::FOCUS] = [2, 1, 3, 4][sliderwin2.value(set10)]
        thiscel = canvas.currentCel
        # Save by replacing current cell
        thiscel[0, thiscel.length] = cel
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    previewwin.dispose
    previewsprite.dispose
    sliderwin2.dispose
    return
  end

  #=============================================================================
  # Pop-up menus for buttons in right hand menu.
  #=============================================================================
  def pbTimingList(canvas)
    commands = []
    cmdNewSound = -1
    cmdNewBG = -1
    cmdEditBG = -1
    cmdNewFO = -1
    cmdEditFO = -1
    canvas.animation.timing.each { |i| commands.push(i.to_s) }
    commands[cmdNewSound = commands.length] = _INTL("Add: Play Sound...")
    commands[cmdNewBG = commands.length] = _INTL("Add: Set Background Graphic...")
    commands[cmdEditBG = commands.length] = _INTL("Add: Edit Background Color/Location...")
    commands[cmdNewFO = commands.length] = _INTL("Add: Set Foreground Graphic...")
    commands[cmdEditFO = commands.length] = _INTL("Add: Edit Foreground Color/Location...")
    cmdwin = pbListWindow(commands, 480)
    cmdwin.x = 0
    cmdwin.y = 0
    cmdwin.width = 640
    cmdwin.height = 384
    cmdwin.opacity = 200
    cmdwin.viewport = canvas.viewport
    framewindow = ControlWindow.new(0, 384, 640, 32 * 4)
    framewindow.addSlider(_INTL("Frame:"), 1, canvas.animation.length, canvas.currentframe + 1)
    framewindow.addButton(_INTL("Set Frame"))
    framewindow.addButton(_INTL("Delete Timing"))
    framewindow.opacity = 200
    framewindow.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      framewindow.update
      if cmdwin.index != cmdNewSound &&
         cmdwin.index != cmdNewBG &&
         cmdwin.index != cmdEditBG &&
         cmdwin.index != cmdNewFO &&
         cmdwin.index != cmdEditFO
        if framewindow.changed?(1)   # Set Frame
          canvas.animation.timing[cmdwin.index].frame = framewindow.value(0) - 1
          cmdwin.commands[cmdwin.index] = canvas.animation.timing[cmdwin.index].to_s
          cmdwin.refresh
          next
        end
        if framewindow.changed?(2)   # Delete Timing
          canvas.animation.timing.delete_at(cmdwin.index)
          cmdwin.commands.delete_at(cmdwin.index)
          cmdNewSound -= 1 if cmdNewSound >= 0
          cmdNewBG -= 1 if cmdNewBG >= 0
          cmdEditBG -= 1 if cmdEditBG >= 0
          cmdNewFO -= 1 if cmdNewFO >= 0
          cmdEditFO -= 1 if cmdEditFO >= 0
          cmdwin.refresh
          next
        end
      end
      if Input.trigger?(Input::USE)
        redrawcmds = false
        if cmdwin.index == cmdNewSound   # Add new sound
          newaudio = PBAnimTiming.new(0)
          if pbSelectSE(canvas, newaudio)
            newaudio.frame = framewindow.value(0) - 1
            canvas.animation.timing.push(newaudio)
            redrawcmds = true
          end
        elsif cmdwin.index == cmdNewBG   # Add new background graphic set
          newtiming = PBAnimTiming.new(1)
          if pbSelectBG(canvas, newtiming)
            newtiming.frame = framewindow.value(0) - 1
            canvas.animation.timing.push(newtiming)
            redrawcmds = true
          end
        elsif cmdwin.index == cmdEditBG   # Add new background edit
          newtiming = PBAnimTiming.new(2)
          if pbEditBG(canvas, newtiming)
            newtiming.frame = framewindow.value(0) - 1
            canvas.animation.timing.push(newtiming)
            redrawcmds = true
          end
        elsif cmdwin.index == cmdNewFO   # Add new foreground graphic set
          newtiming = PBAnimTiming.new(3)
          if pbSelectBG(canvas, newtiming)
            newtiming.frame = framewindow.value(0) - 1
            canvas.animation.timing.push(newtiming)
            redrawcmds = true
          end
        elsif cmdwin.index == cmdEditFO   # Add new foreground edit
          newtiming = PBAnimTiming.new(4)
          if pbEditBG(canvas, newtiming)
            newtiming.frame = framewindow.value(0) - 1
            canvas.animation.timing.push(newtiming)
            redrawcmds = true
          end
        else
          # Edit a timing here
          case canvas.animation.timing[cmdwin.index].timingType
          when 0
            pbSelectSE(canvas, canvas.animation.timing[cmdwin.index])
          when 1, 3
            pbSelectBG(canvas, canvas.animation.timing[cmdwin.index])
          when 2, 4
            pbEditBG(canvas, canvas.animation.timing[cmdwin.index])
          end
          cmdwin.commands[cmdwin.index] = canvas.animation.timing[cmdwin.index].to_s
          cmdwin.refresh
        end
        if redrawcmds
          cmdwin.commands[cmdNewSound] = nil if cmdNewSound >= 0
          cmdwin.commands[cmdNewBG] = nil if cmdNewBG >= 0
          cmdwin.commands[cmdEditBG] = nil if cmdEditBG >= 0
          cmdwin.commands[cmdNewFO] = nil if cmdNewFO >= 0
          cmdwin.commands[cmdEditFO] = nil if cmdEditFO >= 0
          cmdwin.commands.compact!
          cmdwin.commands.push(canvas.animation.timing[canvas.animation.timing.length - 1].to_s)
          cmdwin.commands[cmdNewSound = cmdwin.commands.length] = _INTL("Add: Play Sound...")
          cmdwin.commands[cmdNewBG = cmdwin.commands.length] = _INTL("Add: Set Background Graphic...")
          cmdwin.commands[cmdEditBG = cmdwin.commands.length] = _INTL("Add: Edit Background Color/Location...")
          cmdwin.commands[cmdNewFO = cmdwin.commands.length] = _INTL("Add: Set Foreground Graphic...")
          cmdwin.commands[cmdEditFO = cmdwin.commands.length] = _INTL("Add: Edit Foreground Color/Location...")
          cmdwin.refresh
        end
      elsif Input.trigger?(Input::BACK)
        break
      end
    end
    cmdwin.dispose
    framewindow.dispose
    return
  end

  def pbSelectSE(canvas, audio)
    filename = (audio.name != "") ? audio.name : ""
    displayname = (filename != "") ? filename : _INTL("<user's cry>")
    animfiles = []
    ret = false
    pbRgssChdir(File.join("Audio", "SE", "Anim")) do
      animfiles.concat(Dir.glob("*.wav"))
      animfiles.concat(Dir.glob("*.ogg"))
      animfiles.concat(Dir.glob("*.mp3"))
      animfiles.concat(Dir.glob("*.wma"))
    end
    animfiles.uniq!
    animfiles.sort! { |a, b| a.downcase <=> b.downcase }
    animfiles = [_INTL("[Play user's cry]")] + animfiles
    cmdwin = pbListWindow(animfiles, 320)
    cmdwin.height = 480
    cmdwin.opacity = 200
    cmdwin.viewport = canvas.viewport
    maxsizewindow = ControlWindow.new(320, 0, 320, 32 * 8)
    maxsizewindow.addLabel(_INTL("File: \"{1}\"", displayname))
    maxsizewindow.addSlider(_INTL("Volume:"), 0, 100, audio.volume)
    maxsizewindow.addSlider(_INTL("Pitch:"), 20, 250, audio.pitch)
    maxsizewindow.addButton(_INTL("Play Sound"))
    maxsizewindow.addButton(_INTL("Stop Sound"))
    maxsizewindow.addButton(_INTL("OK"))
    maxsizewindow.addButton(_INTL("Cancel"))
    maxsizewindow.opacity = 200
    maxsizewindow.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      maxsizewindow.update
      if maxsizewindow.changed?(3) && animfiles.length > 0 && filename != ""   # Play Sound
        pbSEPlay(RPG::AudioFile.new("Anim/" + filename, maxsizewindow.value(1), maxsizewindow.value(2)))
      end
      pbSEStop if maxsizewindow.changed?(4) && animfiles.length > 0   # Stop Sound
      if maxsizewindow.changed?(5) # OK
        audio.name = File.basename(filename, ".*")
        audio.volume = maxsizewindow.value(1)
        audio.pitch = maxsizewindow.value(2)
        ret = true
        break
      end
      break if maxsizewindow.changed?(6)   # Cancel
      if Input.trigger?(Input::USE) && animfiles.length > 0
        filename = (cmdwin.index == 0) ? "" : cmdwin.commands[cmdwin.index]
        displayname = (filename != "") ? filename : _INTL("<user's cry>")
        maxsizewindow.controls[0].text = _INTL("File: \"{1}\"", displayname)
      elsif Input.trigger?(Input::BACK)
        break
      end
    end
    cmdwin.dispose
    maxsizewindow.dispose
    return ret
  end

  def pbSelectBG(canvas, timing)
    filename = timing.name
    cmdErase = -1
    animfiles = []
    animfiles[cmdErase = animfiles.length] = _INTL("[Erase background graphic]")
    ret = false
    pbRgssChdir(File.join("Graphics", "Animations")) do
      animfiles.concat(Dir.glob("*.png"))
      animfiles.concat(Dir.glob("*.gif"))
  #    animfiles.concat(Dir.glob("*.jpg"))
  #    animfiles.concat(Dir.glob("*.jpeg"))
  #    animfiles.concat(Dir.glob("*.bmp"))
    end
    animfiles.uniq!
    animfiles.sort! { |a, b| a.downcase <=> b.downcase }
    cmdwin = pbListWindow(animfiles, 320)
    cmdwin.height = 480
    cmdwin.opacity = 200
    cmdwin.viewport = canvas.viewport
    maxsizewindow = ControlWindow.new(320, 0, 320, 32 * 11)
    maxsizewindow.addLabel(_INTL("File: \"{1}\"", filename))
    maxsizewindow.addSlider(_INTL("X:"), -500, 500, timing.bgX || 0)
    maxsizewindow.addSlider(_INTL("Y:"), -500, 500, timing.bgY || 0)
    maxsizewindow.addSlider(_INTL("Opacity:"), 0, 255, timing.opacity || 0)
    maxsizewindow.addSlider(_INTL("Red:"), 0, 255, timing.colorRed || 0)
    maxsizewindow.addSlider(_INTL("Green:"), 0, 255, timing.colorGreen || 0)
    maxsizewindow.addSlider(_INTL("Blue:"), 0, 255, timing.colorBlue || 0)
    maxsizewindow.addSlider(_INTL("Alpha:"), 0, 255, timing.colorAlpha || 0)
    maxsizewindow.addButton(_INTL("OK"))
    maxsizewindow.addButton(_INTL("Cancel"))
    maxsizewindow.opacity = 200
    maxsizewindow.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      maxsizewindow.update
      if maxsizewindow.changed?(8)   # OK
        timing.name = File.basename(filename, ".*")
        timing.bgX = maxsizewindow.value(1)
        timing.bgY = maxsizewindow.value(2)
        timing.opacity = maxsizewindow.value(3)
        timing.colorRed = maxsizewindow.value(4)
        timing.colorGreen = maxsizewindow.value(5)
        timing.colorBlue = maxsizewindow.value(6)
        timing.colorAlpha = maxsizewindow.value(7)
        ret = true
        break
      end
      break if maxsizewindow.changed?(9)   # Cancel
      if Input.trigger?(Input::USE) && animfiles.length > 0
        filename = (cmdwin.index == cmdErase) ? "" : cmdwin.commands[cmdwin.index]
        maxsizewindow.controls[0].text = _INTL("File: \"{1}\"", filename)
      elsif Input.trigger?(Input::BACK)
        break
      end
    end
    cmdwin.dispose
    maxsizewindow.dispose
    return ret
  end

  def pbEditBG(canvas, timing)
    ret = false
    maxsizewindow = ControlWindow.new(0, 0, 320, 32 * 11)
    maxsizewindow.addSlider(_INTL("Duration:"), 0, 50, timing.duration)
    maxsizewindow.addOptionalSlider(_INTL("X:"), -500, 500, timing.bgX || 0)
    maxsizewindow.addOptionalSlider(_INTL("Y:"), -500, 500, timing.bgY || 0)
    maxsizewindow.addOptionalSlider(_INTL("Opacity:"), 0, 255, timing.opacity || 0)
    maxsizewindow.addOptionalSlider(_INTL("Red:"), 0, 255, timing.colorRed || 0)
    maxsizewindow.addOptionalSlider(_INTL("Green:"), 0, 255, timing.colorGreen || 0)
    maxsizewindow.addOptionalSlider(_INTL("Blue:"), 0, 255, timing.colorBlue || 0)
    maxsizewindow.addOptionalSlider(_INTL("Alpha:"), 0, 255, timing.colorAlpha || 0)
    maxsizewindow.addButton(_INTL("OK"))
    maxsizewindow.addButton(_INTL("Cancel"))
    maxsizewindow.controls[1].checked = !timing.bgX.nil?
    maxsizewindow.controls[2].checked = !timing.bgY.nil?
    maxsizewindow.controls[3].checked = !timing.opacity.nil?
    maxsizewindow.controls[4].checked = !timing.colorRed.nil?
    maxsizewindow.controls[5].checked = !timing.colorGreen.nil?
    maxsizewindow.controls[6].checked = !timing.colorBlue.nil?
    maxsizewindow.controls[7].checked = !timing.colorAlpha.nil?
    maxsizewindow.opacity = 200
    maxsizewindow.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      maxsizewindow.update
      if maxsizewindow.changed?(8)   # OK
        if maxsizewindow.controls[1].checked ||
           maxsizewindow.controls[2].checked ||
           maxsizewindow.controls[3].checked ||
           maxsizewindow.controls[4].checked ||
           maxsizewindow.controls[5].checked ||
           maxsizewindow.controls[6].checked ||
           maxsizewindow.controls[7].checked
          timing.duration = maxsizewindow.value(0)
          timing.bgX = maxsizewindow.value(1)
          timing.bgY = maxsizewindow.value(2)
          timing.opacity = maxsizewindow.value(3)
          timing.colorRed = maxsizewindow.value(4)
          timing.colorGreen = maxsizewindow.value(5)
          timing.colorBlue = maxsizewindow.value(6)
          timing.colorAlpha = maxsizewindow.value(7)
          ret = true
        end
        break
      end
      break if maxsizewindow.changed?(9)   # Cancel
      if Input.trigger?(Input::BACK)
        break
      end
    end
    maxsizewindow.dispose
    return ret
  end

  def pbCopyFrames(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 6)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.addSlider(_INTL("First Frame:"), 1, canvas.animation.length, 1)
    sliderwin2.addSlider(_INTL("Last Frame:"), 1, canvas.animation.length, canvas.animation.length)
    sliderwin2.addSlider(_INTL("Copy to:"), 1, canvas.animation.length, canvas.currentframe + 1)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    sliderwin2.opacity = 200
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        startvalue = sliderwin2.value(0) - 1
        endvalue = sliderwin2.value(1) - 1
        dstvalue = sliderwin2.value(2) - 1
        length = (endvalue - startvalue) + 1
        if length > 0   # Ensure correct overlap handling
          if startvalue < dstvalue
            startvalue += length
            dstvalue += length
            while length != 0
              canvas.copyFrame(startvalue - 1, dstvalue - 1)
              startvalue -= 1
              dstvalue -= 1
              length -= 1
            end
          elsif startvalue != dstvalue
            while length != 0
              canvas.copyFrame(startvalue, dstvalue)
              startvalue += 1
              dstvalue += 1
              length -= 1
            end
          end
        end
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbClearFrames(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 5)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.addSlider(_INTL("First Frame:"), 1, canvas.animation.length, 1)
    sliderwin2.addSlider(_INTL("Last Frame:"), 1, canvas.animation.length, canvas.animation.length)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    sliderwin2.opacity = 200
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        startframe = sliderwin2.value(0) - 1
        endframe = sliderwin2.value(1) - 1
        (startframe..endframe).each do |i|
          canvas.clearFrame(i)
        end
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbTweening(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 10)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.opacity = 200
    s1set0 = sliderwin2.addSlider(_INTL("Starting Frame:"), 1, canvas.animation.length, 1)
    s1set1 = sliderwin2.addSlider(_INTL("Ending Frame:"), 1, canvas.animation.length, canvas.animation.length)
    s1set2 = sliderwin2.addSlider(_INTL("First Cel:"), 0, PBAnimation::MAX_SPRITES - 1, 0)
    s1set3 = sliderwin2.addSlider(_INTL("Last Cel:"), 0, PBAnimation::MAX_SPRITES - 1, PBAnimation::MAX_SPRITES - 1)
    set0 = sliderwin2.addCheckbox(_INTL("Pattern"))
    set1 = sliderwin2.addCheckbox(_INTL("Position/Zoom/Angle"))
    set2 = sliderwin2.addCheckbox(_INTL("Opacity/Blending"))
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton) || Input.trigger?(Input::USE)
        startframe = sliderwin2.value(s1set0) - 1
        endframe = sliderwin2.value(s1set1) - 1
        break if startframe >= endframe
        frames = endframe - startframe
        startcel = sliderwin2.value(s1set2)
        endcel = sliderwin2.value(s1set3)
        (startcel..endcel).each do |j|
          cel1 = canvas.animation[startframe][j]
          cel2 = canvas.animation[endframe][j]
          next if !cel1 || !cel2
          diffPattern = cel2[AnimFrame::PATTERN] - cel1[AnimFrame::PATTERN]
          diffX = cel2[AnimFrame::X] - cel1[AnimFrame::X]
          diffY = cel2[AnimFrame::Y] - cel1[AnimFrame::Y]
          diffZoomX = cel2[AnimFrame::ZOOMX] - cel1[AnimFrame::ZOOMX]
          diffZoomY = cel2[AnimFrame::ZOOMY] - cel1[AnimFrame::ZOOMY]
          diffAngle = cel2[AnimFrame::ANGLE] - cel1[AnimFrame::ANGLE]
          diffOpacity = cel2[AnimFrame::OPACITY] - cel1[AnimFrame::OPACITY]
          diffBlend = cel2[AnimFrame::BLENDTYPE] - cel1[AnimFrame::BLENDTYPE]
          startPattern = cel1[AnimFrame::PATTERN]
          startX = cel1[AnimFrame::X]
          startY = cel1[AnimFrame::Y]
          startZoomX = cel1[AnimFrame::ZOOMX]
          startZoomY = cel1[AnimFrame::ZOOMY]
          startAngle = cel1[AnimFrame::ANGLE]
          startOpacity = cel1[AnimFrame::OPACITY]
          startBlend = cel1[AnimFrame::BLENDTYPE]
          (0..frames).each do |k|
            cel = canvas.animation[startframe + k][j]
            curcel = cel
            if !cel
              cel = pbCreateCel(0, 0, 0)
              canvas.animation[startframe + k][j] = cel
            end
            if sliderwin2.value(set0) || !curcel
              cel[AnimFrame::PATTERN] = startPattern + (diffPattern * k / frames)
            end
            if sliderwin2.value(set1) || !curcel
              cel[AnimFrame::X] = startX + (diffX * k / frames)
              cel[AnimFrame::Y] = startY + (diffY * k / frames)
              cel[AnimFrame::ZOOMX] = startZoomX + (diffZoomX * k / frames)
              cel[AnimFrame::ZOOMY] = startZoomY + (diffZoomY * k / frames)
              cel[AnimFrame::ANGLE] = startAngle + (diffAngle * k / frames)
            end
            if sliderwin2.value(set2) || !curcel
              cel[AnimFrame::OPACITY] = startOpacity + (diffOpacity * k / frames)
              cel[AnimFrame::BLENDTYPE] = startBlend + (diffBlend * k / frames)
            end
          end
        end
        canvas.invalidate
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
  end

  def pbCellBatch(canvas)
    sliderwin1 = ControlWindow.new(0, 0, 300, 32 * 5)
    sliderwin1.viewport = canvas.viewport
    sliderwin1.opacity = 200
    s1set0 = sliderwin1.addSlider(_INTL("First Frame:"), 1, canvas.animation.length, 1)
    s1set1 = sliderwin1.addSlider(_INTL("Last Frame:"), 1, canvas.animation.length, canvas.animation.length)
    s1set2 = sliderwin1.addSlider(_INTL("First Cel:"), 0, PBAnimation::MAX_SPRITES - 1, 0)
    s1set3 = sliderwin1.addSlider(_INTL("Last Cel:"), 0, PBAnimation::MAX_SPRITES - 1, PBAnimation::MAX_SPRITES - 1)
    sliderwin2 = ControlWindow.new(300, 0, 340, 32 * 14)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.opacity = 200
    set0 = sliderwin2.addOptionalSlider(_INTL("Pattern:"), -2, 1000, 0)
    set1 = sliderwin2.addOptionalSlider(_INTL("X:"), -64, 512 + 64, 0)
    set2 = sliderwin2.addOptionalSlider(_INTL("Y:"), -64, 384 + 64, 0)
    set3 = sliderwin2.addOptionalSlider(_INTL("Zoom X:"), 5, 1000, 100)
    set4 = sliderwin2.addOptionalSlider(_INTL("Zoom Y:"), 5, 1000, 100)
    set5 = sliderwin2.addOptionalSlider(_INTL("Angle:"), 0, 359, 0)
    set6 = sliderwin2.addOptionalSlider(_INTL("Opacity:"), 0, 255, 255)
    set7 = sliderwin2.addOptionalSlider(_INTL("Blending:"), 0, 2, 0)
    set8 = sliderwin2.addOptionalTextSlider(_INTL("Flip:"), [_INTL("False"), _INTL("True")], 0)
    prio = [_INTL("Back"), _INTL("Front"), _INTL("Behind focus"), _INTL("Above focus")]
    set9 = sliderwin2.addOptionalTextSlider(_INTL("Priority:"), prio, 1)
    foc = [_INTL("User"), _INTL("Target"), _INTL("User and target"), _INTL("Screen")]
    curfoc = [3, 1, 0, 2, 3][canvas.animation.position || 4]
    set10 = sliderwin2.addOptionalTextSlider(_INTL("Focus:"), foc, curfoc)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    loop do
      Graphics.update
      Input.update
      sliderwin1.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton) || Input.trigger?(Input::USE)
        startframe = sliderwin1.value(s1set0) - 1
        endframe = sliderwin1.value(s1set1) - 1
        startcel = sliderwin1.value(s1set2)
        endcel = sliderwin1.value(s1set3)
        (startframe..endframe).each do |i|
          (startcel..endcel).each do |j|
            next if !canvas.animation[i][j]
            cel = canvas.animation[i][j]
            cel[AnimFrame::PATTERN] = sliderwin2.value(set0) if sliderwin2.value(set0)
            cel[AnimFrame::X] = sliderwin2.value(set1) if sliderwin2.value(set1)
            cel[AnimFrame::Y] = sliderwin2.value(set2) if sliderwin2.value(set2)
            cel[AnimFrame::ZOOMX] = sliderwin2.value(set3) if sliderwin2.value(set3)
            cel[AnimFrame::ZOOMY] = sliderwin2.value(set4) if sliderwin2.value(set4)
            cel[AnimFrame::ANGLE] = sliderwin2.value(set5) if sliderwin2.value(set5)
            cel[AnimFrame::OPACITY] = sliderwin2.value(set6) if sliderwin2.value(set6)
            cel[AnimFrame::BLENDTYPE] = sliderwin2.value(set7) if sliderwin2.value(set7)
            cel[AnimFrame::MIRROR] = sliderwin2.value(set8) if sliderwin2.value(set8)
            cel[AnimFrame::PRIORITY] = sliderwin2.value(set9) if sliderwin2.value(set9)
            cel[AnimFrame::FOCUS] = [2, 1, 3, 4][sliderwin2.value(set10)] if sliderwin2.value(set10)
          end
        end
        canvas.invalidate
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin1.dispose
    sliderwin2.dispose
  end

  def pbEntireSlide(canvas)
    sliderwin2 = ControlWindow.new(0, 0, 320, 32 * 7)
    sliderwin2.viewport = canvas.viewport
    sliderwin2.addSlider(_INTL("First Frame:"), 1, canvas.animation.length, 1)
    sliderwin2.addSlider(_INTL("Last Frame:"), 1, canvas.animation.length, canvas.animation.length)
    sliderwin2.addSlider(_INTL("X-Axis Movement"), -500, 500, 0)
    sliderwin2.addSlider(_INTL("Y-Axis Movement"), -500, 500, 0)
    okbutton = sliderwin2.addButton(_INTL("OK"))
    cancelbutton = sliderwin2.addButton(_INTL("Cancel"))
    sliderwin2.opacity = 200
    loop do
      Graphics.update
      Input.update
      sliderwin2.update
      if sliderwin2.changed?(okbutton)
        startvalue = sliderwin2.value(0) - 1
        endvalue = sliderwin2.value(1) - 1
        xoffset = sliderwin2.value(2)
        yoffset = sliderwin2.value(3)
        (startvalue..endvalue).each do |i|
          canvas.offsetFrame(i, xoffset, yoffset)
        end
        break
      end
      if sliderwin2.changed?(cancelbutton) || Input.trigger?(Input::BACK)
        break
      end
    end
    sliderwin2.dispose
    return
  end

  def pbAnimEditorHelpWindow
    helptext = "" +
               "To add a cel to the scene, click on the canvas. The selected cel will have a black " +
               "frame. After a cel is selected, you can modify its properties using the keyboard:\n" +
               "E, R - Rotate left/right.\nP - Open properties screen.\nArrow keys - Move cel 8 pixels " +
               "(hold ALT for 2 pixels).\n+/- : Zoom in/out.\nL - Lock a cel. Locking a cel prevents it " +
               "from being moved or deleted.\nDEL - Deletes the cel.\nAlso press TAB to switch the selected cel."
    cmdwin = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 640, 512)
    cmdwin.opacity = 224
    cmdwin.z = 99999
    cmdwin.text = helptext
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      break if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
    end
    cmdwin.dispose
  end

  #=============================================================================
  # Main.
  #=============================================================================
  def animationEditorMain(animation)
    viewport = Viewport.new(0, 0, Settings::SCREEN_WIDTH + 288, Settings::SCREEN_HEIGHT + 288)
    viewport.z = 99999
    # Canvas
    canvas = AnimationCanvas.new(animation[animation.selected] || animation[0], viewport)
    # Right hand menu
    sidewin = ControlWindow.new(512 + 128, 0, 160, 384 + 128)
    sidewin.addButton(_INTL("SE and BG..."))
    sidewin.addButton(_INTL("Cel Focus..."))
    sidewin.addSpace
    sidewin.addButton(_INTL("Paste Last"))
    sidewin.addButton(_INTL("Copy Frames..."))
    sidewin.addButton(_INTL("Clear Frames..."))
    sidewin.addButton(_INTL("Tweening..."))
    sidewin.addButton(_INTL("Cel Batch..."))
    sidewin.addButton(_INTL("Entire Slide..."))
    sidewin.addSpace
    sidewin.addButton(_INTL("Play Animation"))
    sidewin.addButton(_INTL("Play Opp Anim"))
    sidewin.addButton(_INTL("Import Anim..."))
    sidewin.addButton(_INTL("Export Anim..."))
    sidewin.addButton(_INTL("Help"))
    sidewin.viewport = canvas.viewport
    # Bottom left menu
    sliderwin = ControlWindow.new(0, 384 + 128, 240, 160)
    sliderwin.addControl(FrameCountSlider.new(canvas))
    sliderwin.addControl(FrameCountButton.new(canvas))
    sliderwin.addButton(_INTL("Set Animation Sheet"))
    sliderwin.addButton(_INTL("List of Animations"))
    sliderwin.viewport = canvas.viewport
    # Animation sheet window
    animwin = CanvasAnimationWindow.new(canvas, 240, 384 + 128, 512, 96, canvas.viewport)
    # Name window
    bottomwindow = AnimationNameWindow.new(canvas, 240, 384 + 128 + 96, 512, 64, canvas.viewport)
    loop do
      Graphics.update
      Input.update
      sliderwin.update
      canvas.update
      sidewin.update
      animwin.update
      bottomwindow.update
      canvas.pattern = animwin.selected if animwin.changed?
      if Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Save changes?"))
          save_data(animation, "Data/PkmnAnimations.rxdata")
        end
        if pbConfirmMessage(_INTL("Exit from the editor?"))
          $game_temp.battle_animations_data = nil
          break
        end
      end
      if Input.triggerex?(:F5)
        pbAnimEditorHelpWindow
        next
      elsif Input.trigger?(Input::MOUSERIGHT) && sliderwin.hittest?(0)   # Right mouse button
        commands = [
          _INTL("Copy Frame"),
          _INTL("Paste Frame"),
          _INTL("Clear Frame"),
          _INTL("Insert Frame"),
          _INTL("Delete Frame")
        ]
        hit = pbTrackPopupMenu(commands)
        case hit
        when 0 # Copy
          if canvas.currentframe >= 0
            Clipboard.setData(canvas.animation[canvas.currentframe], "PBAnimFrame")
          end
        when 1 # Paste
          canvas.pasteFrame(canvas.currentframe) if canvas.currentframe >= 0
        when 2 # Clear Frame
          canvas.clearFrame(canvas.currentframe)
        when 3 # Insert Frame
          canvas.insertFrame(canvas.currentframe)
          sliderwin.invalidate
        when 4 # Delete Frame
          canvas.deleteFrame(canvas.currentframe)
          sliderwin.controls[0].curvalue = canvas.currentframe + 1
          sliderwin.invalidate
        end
        next
      elsif Input.triggerex?(:Q)
        if canvas.currentCel
          pbDefinePath(canvas)
          sliderwin.invalidate
        end
        next
      elsif Input.trigger?(Input::MOUSERIGHT)   # Right mouse button
        mousepos = Mouse.getMousePos
        mousepos = [0, 0] if !mousepos
        commands = [
          _INTL("Properties..."),
          _INTL("Cut"),
          _INTL("Copy"),
          _INTL("Paste"),
          _INTL("Delete"),
          _INTL("Renumber..."),
          _INTL("Extrapolate Path...")
        ]
        hit = pbTrackPopupMenu(commands)
        case hit
        when 0   # Properties
          if canvas.currentCel
            pbCellProperties(canvas)
            canvas.invalidateCel(canvas.currentcel)
          end
        when 1   # Cut
          if canvas.currentCel
            Clipboard.setData(canvas.currentCel, "PBAnimCel")
            canvas.deleteCel(canvas.currentcel)
          end
        when 2   # Copy
          Clipboard.setData(canvas.currentCel, "PBAnimCel") if canvas.currentCel
        when 3   # Paste
          canvas.pasteCel(mousepos[0], mousepos[1])
        when 4   # Delete
          canvas.deleteCel(canvas.currentcel)
        when 5   # Renumber
          if canvas.currentcel && canvas.currentcel >= 2
            cel1 = canvas.currentcel
            cel2 = pbChooseNum(cel1)
            canvas.swapCels(cel1, cel2) if cel2 >= 2 && cel1 != cel2
          end
        when 6   # Extrapolate Path
          if canvas.currentCel
            pbDefinePath(canvas)
            sliderwin.invalidate
          end
        end
        next
      end
      if sliderwin.changed?(0)   # Current frame changed
        canvas.currentframe = sliderwin.value(0) - 1
      end
      if sliderwin.changed?(1)   # Change frame count
        pbChangeMaximum(canvas)
        if canvas.currentframe >= canvas.animation.length
          canvas.currentframe = canvas.animation.length - 1
          sliderwin.controls[0].curvalue = canvas.currentframe + 1
        end
        sliderwin.refresh
      end
      if sliderwin.changed?(2)   # Set Animation Sheet
        pbSelectAnim(canvas, animwin)
        animwin.refresh
        sliderwin.refresh
      end
      if sliderwin.changed?(3)   # List of Animations
        pbAnimList(animation, canvas, animwin)
        sliderwin.controls[0].curvalue = canvas.currentframe + 1
        bottomwindow.refresh
        animwin.refresh
        sliderwin.refresh
      end
      pbTimingList(canvas) if sidewin.changed?(0)
      if sidewin.changed?(1)
        positions = [_INTL("User"), _INTL("Target"), _INTL("User and target"), _INTL("Screen")]
        indexes = [2, 1, 3, 4]   # Keeping backwards compatibility
        positions.length.times do |i|
          selected = "[  ]"
          selected = "[X]" if animation[animation.selected].position == indexes[i]
          positions[i] = sprintf("%s %s", selected, positions[i])
        end
        pos = pbShowCommands(nil, positions, -1)
        if pos >= 0
          animation[animation.selected].position = indexes[pos]
          canvas.update
        end
      end
      canvas.pasteLast if sidewin.changed?(3)
      pbCopyFrames(canvas) if sidewin.changed?(4)
      pbClearFrames(canvas) if sidewin.changed?(5)
      pbTweening(canvas) if sidewin.changed?(6)
      pbCellBatch(canvas) if sidewin.changed?(7)
      pbEntireSlide(canvas) if sidewin.changed?(8)
      canvas.play if sidewin.changed?(10)
      canvas.play(true) if sidewin.changed?(11)
      if sidewin.changed?(12)
        pbImportAnim(animation, canvas, animwin)
        sliderwin.controls[0].curvalue = canvas.currentframe + 1
        bottomwindow.refresh
        animwin.refresh
        sliderwin.refresh
      end
      if sidewin.changed?(13)
        pbExportAnim(animation)
        bottomwindow.refresh
        animwin.refresh
        sliderwin.refresh
      end
      pbAnimEditorHelpWindow if sidewin.changed?(14)
    end
    canvas.dispose
    animwin.dispose
    sliderwin.dispose
    sidewin.dispose
    bottomwindow.dispose
    viewport.dispose
    RPG::Cache.clear
  end
end

#===============================================================================
# Start.
#===============================================================================
def pbAnimationEditor
  pbBGMStop
  animation = pbLoadBattleAnimations
  if !animation || !animation[0]
    animation = PBAnimations.new
    animation[0].graphic = ""
  end
  Graphics.resize_screen(Settings::SCREEN_WIDTH + 288, Settings::SCREEN_HEIGHT + 288)
  pbSetResizeFactor(1)
  BattleAnimationEditor.animationEditorMain(animation)
  Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  pbSetResizeFactor($PokemonSystem.screensize)
  $game_map&.autoplay
end
