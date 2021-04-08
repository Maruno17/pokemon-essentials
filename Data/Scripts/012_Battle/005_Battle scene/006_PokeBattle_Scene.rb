# Battle scene (the visuals of the battle)
class PokeBattle_Scene
  attr_accessor :abortable   # For non-interactive battles, can quit immediately
  attr_reader   :viewport
  attr_reader   :sprites

  BLANK       = 0
  MESSAGE_BOX = 1
  COMMAND_BOX = 2
  FIGHT_BOX   = 3
  TARGET_BOX  = 4

  MESSAGE_PAUSE_TIME = (Graphics.frame_rate*1.0).floor   # 1 second

  #=============================================================================
  # Updating and refreshing
  #=============================================================================
  def pbUpdate(cw=nil)
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate(cw)
  end

  def pbGraphicsUpdate
    # Update lineup animations
    if @animations.length>0
      shouldCompact = false
      @animations.each_with_index do |a,i|
        a.update
        if a.animDone?
          a.dispose
          @animations[i] = nil
          shouldCompact = true
        end
      end
      @animations.compact! if shouldCompact
    end
    # Update other graphics
    @sprites["battle_bg"].update if @sprites["battle_bg"].respond_to?("update")
    Graphics.update
    @frameCounter += 1
    @frameCounter = @frameCounter%(Graphics.frame_rate*12/20)
  end

  def pbInputUpdate
    Input.update
    if Input.trigger?(Input::BACK) && @abortable && !@aborted
      @aborted = true
      @battle.pbAbort
    end
  end

  def pbFrameUpdate(cw=nil)
    cw.update if cw
    @battle.battlers.each_with_index do |b,i|
      next if !b
      @sprites["dataBox_#{i}"].update(@frameCounter) if @sprites["dataBox_#{i}"]
      @sprites["pokemon_#{i}"].update(@frameCounter) if @sprites["pokemon_#{i}"]
      @sprites["shadow_#{i}"].update(@frameCounter) if @sprites["shadow_#{i}"]
    end
  end

  def pbRefresh
    @battle.battlers.each_with_index do |b,i|
      next if !b
      @sprites["dataBox_#{i}"].refresh if @sprites["dataBox_#{i}"]
    end
  end

  def pbRefreshOne(idxBattler)
    @sprites["dataBox_#{idxBattler}"].refresh if @sprites["dataBox_#{idxBattler}"]
  end

  #=============================================================================
  # Party lineup
  #=============================================================================
  # Returns whether the party line-ups are currently coming on-screen
  def inPartyAnimation?
    return @animations.length>0
  end

  #=============================================================================
  # Window displays
  #=============================================================================
  def pbShowWindow(windowType)
    # NOTE: If you are not using fancy graphics for the command/fight menus, you
    #       will need to make "messageBox" also visible if the windowtype if
    #       COMMAND_BOX/FIGHT_BOX respectively.
    @sprites["messageBox"].visible    = (windowType==MESSAGE_BOX)
    @sprites["messageWindow"].visible = (windowType==MESSAGE_BOX)
    @sprites["commandWindow"].visible = (windowType==COMMAND_BOX)
    @sprites["fightWindow"].visible   = (windowType==FIGHT_BOX)
    @sprites["targetWindow"].visible  = (windowType==TARGET_BOX)
  end

  # This is for the end of brief messages, which have been lingering on-screen
  # while other things happened. This is only called when another message wants
  # to be shown, and makes the brief message linger for one more second first.
  # Some animations skip this extra second by setting @briefMessage to false
  # despite not having any other messages to show.
  def pbWaitMessage
    return if !@briefMessage
    pbShowWindow(MESSAGE_BOX)
    cw = @sprites["messageWindow"]
    MESSAGE_PAUSE_TIME.times do
      pbUpdate(cw)
    end
    cw.text    = ""
    cw.visible = false
    @briefMessage = false
  end

  # NOTE: A regular message is displayed for 1 second after it fully appears (or
  #       less if Back/Use is pressed). Disappears automatically after that time.
  def pbDisplayMessage(msg,brief=false)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    cw = @sprites["messageWindow"]
    cw.setText(msg)
    PBDebug.log(msg)
    yielded = false
    i = 0
    loop do
      pbUpdate(cw)
      if !cw.busy?
        if !yielded
          yield if block_given?   # For playing SE as soon as the message is all shown
          yielded = true
        end
        if brief
          # NOTE: A brief message lingers on-screen while other things happen. A
          #       regular message has to end before the game can continue.
          @briefMessage = true
          break
        end
        if i>=MESSAGE_PAUSE_TIME   # Autoclose after 1 second
          cw.text = ""
          cw.visible = false
          break
        end
        i += 1
      end
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE) || @abortable
        if cw.busy?
          pbPlayDecisionSE if cw.pausing? && !@abortable
          cw.skipAhead
        elsif !@abortable
          cw.text = ""
          cw.visible = false
          break
        end
      end
    end
  end
  alias pbDisplay pbDisplayMessage

  # NOTE: A paused message has the arrow in the bottom corner indicating there
  #       is another message immediately afterward. It is displayed for 3
  #       seconds after it fully appears (or less if B/C is pressed) and
  #       disappears automatically after that time, except at the end of battle.
  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    cw = @sprites["messageWindow"]
    cw.text = _INTL("{1}\1",msg)
    PBDebug.log(msg)
    yielded = false
    i = 0
    loop do
      pbUpdate(cw)
      if !cw.busy?
        if !yielded
          yield if block_given?   # For playing SE as soon as the message is all shown
          yielded = true
        end
        if !@battleEnd
          if i>=MESSAGE_PAUSE_TIME*3   # Autoclose after 3 seconds
            cw.text = ""
            cw.visible = false
            break
          end
          i += 1
        end
      end
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE) || @abortable
        if cw.busy?
          pbPlayDecisionSE if cw.pausing? && !@abortable
          cw.skipAhead
        elsif !@abortable
          cw.text = ""
          pbPlayDecisionSE
          break
        end
      end
    end
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg,[_INTL("Yes"),_INTL("No")],1)==0
  end

  def pbShowCommands(msg,commands,defaultValue)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    dw = @sprites["messageWindow"]
    dw.text = msg
    cw = Window_CommandPokemon.new(commands)
    cw.x        = Graphics.width-cw.width
    cw.y        = Graphics.height-cw.height-dw.height
    cw.z        = dw.z+1
    cw.index    = 0
    cw.viewport = @viewport
    PBDebug.log(msg)
    loop do
      cw.visible = (!dw.busy?)
      pbUpdate(cw)
      dw.update
      if Input.trigger?(Input::BACK) && defaultValue>=0
        if dw.busy?
          pbPlayDecisionSE if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text = ""
          return defaultValue
        end
      elsif Input.trigger?(Input::USE)
        if dw.busy?
          pbPlayDecisionSE if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text = ""
          return cw.index
        end
      end
    end
  end

  #=============================================================================
  # Sprites
  #=============================================================================
  def pbAddSprite(id,x,y,filename,viewport)
    sprite = IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbAddPlane(id,filename,viewport)
    sprite = AnimatedPlane.new(viewport)
    if filename
      sprite.setBitmap(filename)
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbDisposeSprites
    pbDisposeSpriteHash(@sprites)
  end

  # Used by Ally Switch.
  def pbSwapBattlerSprites(idxA,idxB)
    @sprites["pokemon_#{idxA}"], @sprites["pokemon_#{idxB}"] = @sprites["pokemon_#{idxB}"], @sprites["pokemon_#{idxA}"]
    @sprites["shadow_#{idxA}"], @sprites["shadow_#{idxB}"] = @sprites["shadow_#{idxB}"], @sprites["shadow_#{idxA}"]
    @lastCmd[idxA], @lastCmd[idxB] = @lastCmd[idxB], @lastCmd[idxA]
    @lastMove[idxA], @lastMove[idxB] = @lastMove[idxB], @lastMove[idxA]
    [idxA,idxB].each do |i|
      @sprites["pokemon_#{i}"].index = i
      @sprites["pokemon_#{i}"].pbSetPosition
      @sprites["shadow_#{i}"].index = i
      @sprites["shadow_#{i}"].pbSetPosition
      @sprites["dataBox_#{i}"].battler = @battle.battlers[i]
    end
    pbRefresh
  end

  #=============================================================================
  # Phases
  #=============================================================================
  def pbBeginCommandPhase
    @sprites["messageWindow"].text = ""
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
    pbShowWindow(MESSAGE_BOX)
  end

  def pbBeginEndOfRoundPhase
  end

  def pbEndBattle(_result)
    @abortable = false
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end

  #=============================================================================
  #
  #=============================================================================
  def pbSelectBattler(idxBattler,selectMode=1)
    numWindows = @battle.sideSizes.max*2
    for i in 0...numWindows
      sel = (idxBattler.is_a?(Array)) ? !idxBattler[i].nil? : i==idxBattler
      selVal = (sel) ? selectMode : 0
      @sprites["dataBox_#{i}"].selected = selVal if @sprites["dataBox_#{i}"]
      @sprites["pokemon_#{i}"].selected = selVal if @sprites["pokemon_#{i}"]
    end
  end

  def pbChangePokemon(idxBattler,pkmn)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back = !@battle.opposes?(idxBattler)
    pkmnSprite.setPokemonBitmap(pkmn,back)
    shadowSprite.setPokemonBitmap(pkmn)
    # Set visibility of battler's shadow
    shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
  end

  def pbResetMoveIndex(idxBattler)
    @lastMove[idxBattler] = 0
  end

  #=============================================================================
  #
  #=============================================================================
  # This method is called when the player wins a wild Pokémon battle.
  # This method can change the battle's music for example.
  def pbWildBattleSuccess
    @battleEnd = true
    pbBGMPlay(pbGetWildVictoryME)
  end

  # This method is called when the player wins a trainer battle.
  # This method can change the battle's music for example.
  def pbTrainerBattleSuccess
    @battleEnd = true
    pbBGMPlay(pbGetTrainerVictoryME(@battle.opponent))
  end
end
