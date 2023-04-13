module BattleAnimationEditor
  module_function

  #=============================================================================
  # Importing and exporting
  #=============================================================================
  def pbRgssChdir(dir)
    RTP.eachPathFor(dir) { |path| Dir.chdir(path) { yield } }
  end

  def tryLoadData(file)
    begin
      return load_data(file)
    rescue
      return nil
    end
  end

  def dumpBase64Anim(s)
    return [Zlib::Deflate.deflate(Marshal.dump(s))].pack("m").gsub(/\n/, "\r\n")
  end

  def loadBase64Anim(s)
    return Marshal.restore(Zlib::Inflate.inflate(s.unpack("m")[0]))
  end

  def pbExportAnim(animations)
    filename = pbMessageFreeText(_INTL("Enter a filename."), "", false, 32)
    if filename != ""
      begin
        filename += ".anm"
        File.open(filename, "wb") do |f|
          f.write(dumpBase64Anim(animations[animations.selected]))
        end
        failed = false
      rescue
        pbMessage(_INTL("Couldn't save the animation to {1}.", filename))
        failed = true
      end
      if !failed
        pbMessage(_INTL("Animation was saved to {1} in the game folder.", filename))
        pbMessage(_INTL("It's a text file, so it can be transferred to others easily."))
      end
    end
  end

  def pbImportAnim(animations, canvas, animwin)
    animfiles = []
    pbRgssChdir(".") { animfiles.concat(Dir.glob("*.anm")) }
    cmdwin = pbListWindow(animfiles, 320)
    cmdwin.opacity = 200
    cmdwin.height = 480
    cmdwin.viewport = canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      if Input.trigger?(Input::USE) && animfiles.length > 0
        begin
          textdata = loadBase64Anim(IO.read(animfiles[cmdwin.index]))
          throw "Bad data" if !textdata.is_a?(PBAnimation)
          textdata.id = -1 # this is not an RPG Maker XP animation
          pbConvertAnimToNewFormat(textdata)
          animations[animations.selected] = textdata
        rescue
          pbMessage(_INTL("The animation is invalid or could not be loaded."))
          next
        end
        graphic = animations[animations.selected].graphic
        graphic = "Graphics/Animations/#{graphic}"
        if graphic && graphic != "" && !FileTest.image_exist?(graphic)
          pbMessage(_INTL("The animation file {1} was not found. The animation will load anyway.", graphic))
        end
        canvas.loadAnimation(animations[animations.selected])
        animwin.animbitmap = canvas.animbitmap
        break
      end
      if Input.trigger?(Input::BACK)
        break
      end
    end
    cmdwin.dispose
    return
  end

  #=============================================================================
  # Format conversion
  #=============================================================================
  def pbConvertAnimToNewFormat(textdata)
    needconverting = false
    textdata.length.times do |i|
      next if !textdata[i]
      PBAnimation::MAX_SPRITES.times do |j|
        next if !textdata[i][j]
        needconverting = true if textdata[i][j][AnimFrame::FOCUS].nil?
        break if needconverting
      end
      break if needconverting
    end
    if needconverting
      textdata.length.times do |i|
        next if !textdata[i]
        PBAnimation::MAX_SPRITES.times do |j|
          next if !textdata[i][j]
          textdata[i][j][AnimFrame::PRIORITY] = 1 if textdata[i][j][AnimFrame::PRIORITY].nil?
          case j
          when 0      # User battler
            textdata[i][j][AnimFrame::FOCUS] = 2
            textdata[i][j][AnimFrame::X] = Battle::Scene::FOCUSUSER_X
            textdata[i][j][AnimFrame::Y] = Battle::Scene::FOCUSUSER_Y
          when 1   # Target battler
            textdata[i][j][AnimFrame::FOCUS] = 1
            textdata[i][j][AnimFrame::X] = Battle::Scene::FOCUSTARGET_X
            textdata[i][j][AnimFrame::Y] = Battle::Scene::FOCUSTARGET_Y
          else
            textdata[i][j][AnimFrame::FOCUS] = (textdata.position || 4)
            if textdata.position == 1
              textdata[i][j][AnimFrame::X] += Battle::Scene::FOCUSTARGET_X
              textdata[i][j][AnimFrame::Y] += Battle::Scene::FOCUSTARGET_Y - 2
            end
          end
        end
      end
    end
    return needconverting
  end

  def pbConvertAnimsToNewFormat
    pbMessage(_INTL("Will convert animations now."))
    count = 0
    animations = pbLoadBattleAnimations
    if !animations || !animations[0]
      pbMessage(_INTL("No animations exist."))
      return
    end
    animations.length.times do |k|
      next if !animations[k]
      ret = pbConvertAnimToNewFormat(animations[k])
      count += 1 if ret
    end
    if count > 0
      save_data(animations, "Data/PkmnAnimations.rxdata")
      $game_temp.battle_animations_data = nil
    end
    pbMessage(_INTL("{1} animations converted to new format.", count))
  end
end
