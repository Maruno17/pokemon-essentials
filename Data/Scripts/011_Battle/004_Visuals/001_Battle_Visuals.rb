#===============================================================================
# Battle visuals class
#===============================================================================
class Battle::Visuals
  attr_accessor :abortable   # For non-interactive battles, can quit immediately
  attr_reader   :battle
  attr_reader   :viewport
  attr_reader   :sprites

  USE_ABILITY_SPLASH            = (Settings::MECHANICS_GENERATION >= 5)
  MESSAGE_PAUSE_TIME            = 1.0   # In seconds
  # Text colors
  MESSAGE_BASE_COLOR            = Color.new(80, 80, 88)
  MESSAGE_SHADOW_COLOR          = Color.new(160, 160, 168)
  MESSAGE_BASE_CRITICAL_COLOR   = Color.new(248, 96, 8)
  MESSAGE_SHADOW_CRITICAL_COLOR = Color.new(248, 176, 128)
  # The number of party balls to show in each side's lineup.
  NUM_BALLS                     = Settings::MAX_PARTY_SIZE
  # Centre bottom of the player's side base graphic
  PLAYER_BASE_X                 = 128
  PLAYER_BASE_Y                 = Settings::SCREEN_HEIGHT - 80
  # Centre middle of the foe's side base graphic
  FOE_BASE_X                    = Settings::SCREEN_WIDTH - 128
  FOE_BASE_Y                    = (Settings::SCREEN_HEIGHT * 3 / 4) - 112
  # Default focal points of user and target in animations - do not change!
  # Is the centre middle of each sprite
  FOCUSUSER_X                   = 128
  FOCUSUSER_Y                   = 224
  FOCUSTARGET_X                 = 384
  FOCUSTARGET_Y                 = 96
  # Menu types
  BLANK                         = 0
  MESSAGE_BOX                   = 1
  COMMAND_BOX                   = 2
  FIGHT_BOX                     = 3
  TARGET_BOX                    = 4

  # Returns where the centre bottom of a battler's sprite should be, given its
  # index and the number of battlers on its side, assuming the battler has
  # metrics of 0 (those are added later).
  def self.pbBattlerPosition(index, sideSize = 1)
    # Start at the centre of the base for the appropriate side
    if (index & 1) == 0
      ret = [PLAYER_BASE_X, PLAYER_BASE_Y]
    else
      ret = [FOE_BASE_X, FOE_BASE_Y]
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
    when 2
      ret[0] += [-48, 48, 32, -32][index]
      ret[1] += [  0,  0, 16, -16][index]
    when 3
      ret[0] += [-80, 80,  0,  0, 80, -80][index]
      ret[1] += [  0,  0,  8, -8, 16, -16][index]
    end
    return ret
  end

  # Returns where the centre bottom of a trainer's sprite should be, given its
  # side (0/1), index and the number of trainers on its side.
  def self.pbTrainerPosition(side, index = 0, sideSize = 1)
    # Start at the centre of the base for the appropriate side
    if side == 0
      ret = [PLAYER_BASE_X, PLAYER_BASE_Y - 16]
    else
      ret = [FOE_BASE_X, FOE_BASE_Y + 6]
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
    when 2
      ret[0] += [-48, 48, 32, -32][(2 * index) + side]
      ret[1] += [  0,  0,  0, -16][(2 * index) + side]
    when 3
      ret[0] += [-80, 80,  0,  0, 80, -80][(2 * index) + side]
      ret[1] += [  0,  0,  0, -8,  0, -16][(2 * index) + side]
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Updating and refreshing.
  #-----------------------------------------------------------------------------

  def pbUpdate(cw = nil)
    Graphics.update
    Input.update
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate(cw)
  end

  def pbGraphicsUpdate
    # Update lineup animations
    if @animations.length > 0
      shouldCompact = false
      @animations.each_with_index do |a, i|
        a.update
        next if !a.animDone?
        a.dispose
        @animations[i] = nil
        shouldCompact = true
      end
      @animations.compact! if shouldCompact
    end
    # Update other graphics
    @sprites["battle_bg"].update if @sprites["battle_bg"].respond_to?("update")
  end

  def pbInputUpdate
    if Input.trigger?(Input::BACK) && @abortable && !@aborted
      @aborted = true
      @battle.pbAbort
    end
  end

  def pbFrameUpdate(cw = nil)
    cw&.update
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"]&.update
      @sprites["pokemon_#{i}"]&.update
      @sprites["shadow_#{i}"]&.update
    end
  end

  def pbRefresh
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"]&.refresh
    end
  end

  def pbRefreshOne(idxBattler)
    @sprites["dataBox_#{idxBattler}"]&.refresh
  end

  def pbRefreshEverything
    pbCreateBackdropSprites
    @battle.battlers.each_with_index do |battler, i|
      next if !battler
      pbChangePokemon(i, @sprites["pokemon_#{i}"].pkmn)
      @sprites["dataBox_#{i}"].initializeDataBoxBitmap
      @sprites["dataBox_#{i}"].calculateDataBoxPosition
      @sprites["dataBox_#{i}"].refresh
    end
  end

  #-----------------------------------------------------------------------------
  # Party lineup.
  #-----------------------------------------------------------------------------

  # Returns whether the party line-ups are currently coming on-screen
  def inPartyAnimation?
    return @animations.length > 0
  end

  #-----------------------------------------------------------------------------
  # Window displays.
  #-----------------------------------------------------------------------------

  def pbShowWindow(windowType)
    @sprites["messageBox"].visible    = (windowType == MESSAGE_BOX)
    @sprites["messageWindow"].visible = (windowType == MESSAGE_BOX)
    @sprites["commandWindow"].visible = (windowType == COMMAND_BOX)
    @sprites["fightWindow"].visible   = (windowType == FIGHT_BOX)
    @sprites["targetWindow"].visible  = (windowType == TARGET_BOX)
  end

  # This is for the end of brief messages, which have been lingering on-screen
  # while other things happened. This is only called when another message wants
  # to be shown, and makes the brief message linger for one more second first.
  # Some animations skip this extra second by setting @briefMessage to false
  # despite not having any other messages to show.
  def pbWaitMessage
    return if !@briefMessage
    pbShowWindow(MESSAGE_BOX)
    msg_window = @sprites["messageWindow"]
    timer_start = System.uptime
    while System.uptime - timer_start < MESSAGE_PAUSE_TIME
      pbUpdate(msg_window)
    end
    msg_window.text    = ""
    msg_window.visible = false
    @briefMessage = false
  end

  # NOTE: A regular message is displayed for 1 second after it fully appears (or
  #       less if Back/Use is pressed). Disappears automatically after that
  #       time. Meanwhile, a brief message doesn't wait for 1 second (or an
  #       input) afterwards, and the message doesn't disappear.
  def pbDisplayMessage(msg, brief = false)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    msg_window = @sprites["messageWindow"]
    # Display message
    PBDebug.log_message(msg)
    pbMessageDisplay(msg_window, msg, true, proc { |msg_wndw| }) { pbUpdate }
    # Check if the message is brief
    @briefMessage = true if brief   # Don't wait at all if a brief message
    return if @briefMessage
    # After message has finished displaying, wait for 1 second or input
    timer_start = System.uptime
    loop do
      pbUpdate(msg_window)
      break if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
      break if System.uptime - timer_start >= MESSAGE_PAUSE_TIME   # Autoclose after 1 second
    end
    msg_window.text = ""
    msg_window.visible = false
  end
  alias pbDisplay pbDisplayMessage

  # NOTE: A paused message has the arrow in the bottom corner indicating there
  #       is another message immediately afterward. It is displayed for 3
  #       seconds after it fully appears (or less if Back/Use is pressed) and
  #       disappears automatically after that time, except at the end of battle.
  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    msg_window = @sprites["messageWindow"]
    # Display message
    PBDebug.log_message(msg)
    pbMessageDisplay(msg_window, msg + "\1", true, proc { |msg_wndw| }) { pbUpdate }
    # After message has finished displaying, wait for 3 seconds or input
    timer_start = System.uptime
    loop do
      pbUpdate(msg_window)
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
      break if !@battleEnd && System.uptime - timer_start >= MESSAGE_PAUSE_TIME * 3   # Autoclose after 3 seconds
    end
    msg_window.text = ""
    msg_window.visible = false
  end

  def pbDisplayConfirmMessage(msg)
    return pbShowCommands(msg, [_INTL("Yes"), _INTL("No")], 1) == 0
  end

  def pbShowCommands(msg, commands, defaultValue)
    pbWaitMessage
    pbShowWindow(MESSAGE_BOX)
    msg_window = @sprites["messageWindow"]
    # Display message
    PBDebug.log_message(msg)
    ret = pbMessageDisplay(msg_window, msg, true, proc { |msg_wndw|
      next Kernel.pbShowCommands(msg_wndw, commands, defaultValue + 1, 0) { pbGraphicsUpdate; pbFrameUpdate(msg_window) }
    }) { pbGraphicsUpdate; pbFrameUpdate(msg_window) }
    msg_window.text = ""
    msg_window.visible = false
    return ret
  end

  #-----------------------------------------------------------------------------
  # Sprites.
  #-----------------------------------------------------------------------------

  def pbAddSprite(id, x, y, filename, viewport)
    sprite = @sprites[id] || IconSprite.new(x, y, viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbAddPlane(id, filename, viewport)
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
  def pbSwapBattlerSprites(idxA, idxB)
    @sprites["pokemon_#{idxA}"], @sprites["pokemon_#{idxB}"] = @sprites["pokemon_#{idxB}"], @sprites["pokemon_#{idxA}"]
    @sprites["shadow_#{idxA}"], @sprites["shadow_#{idxB}"] = @sprites["shadow_#{idxB}"], @sprites["shadow_#{idxA}"]
    @lastCmd[idxA], @lastCmd[idxB] = @lastCmd[idxB], @lastCmd[idxA]
    @lastMove[idxA], @lastMove[idxB] = @lastMove[idxB], @lastMove[idxA]
    [idxA, idxB].each do |i|
      @sprites["pokemon_#{i}"].index = i
      @sprites["pokemon_#{i}"].pbSetPosition
      @sprites["shadow_#{i}"].index = i
      @sprites["shadow_#{i}"].pbSetPosition
      @sprites["dataBox_#{i}"].battler = @battle.battlers[i]
    end
    pbRefresh
  end

  def pbForceBattlerInvisibility(idxBattler, value)
    @sprites["pokemon_#{idxBattler}"].forceInvisible = value
    @sprites["shadow_#{idxBattler}"].forceInvisible = value
  end

  #-----------------------------------------------------------------------------
  # Phases.
  #-----------------------------------------------------------------------------

  def pbBeginCommandPhase
    @sprites["messageWindow"].text = ""
  end

  def pbBeginAttackPhase
    pbSelectBattler(-1)
    pbShowWindow(MESSAGE_BOX)
  end

  def pbBeginEndOfRoundPhase; end

  def pbEndBattle(_result)
    @abortable = false
    pbShowWindow(BLANK)
    # Fade out all sprites
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSprites
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------

  def pbSelectBattler(idxBattler, selectMode = 1)
    numWindows = @battle.sideSizes.max * 2
    numWindows.times do |i|
      sel = (idxBattler.is_a?(Array)) ? !idxBattler[i].nil? : i == idxBattler
      selVal = (sel) ? selectMode : 0
      @sprites["dataBox_#{i}"].selected = selVal if @sprites["dataBox_#{i}"]
      @sprites["pokemon_#{i}"].selected = selVal if @sprites["pokemon_#{i}"]
    end
  end

  def pbChangePokemon(idxBattler, pkmn)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back = !@battle.opposes?(idxBattler)
    pkmnSprite.refreshBitmap(pkmn, back)
    shadowSprite.refreshBitmap(pkmn)
    # Set visibility of battler's shadow
    shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
    @sprites["dataBox_#{idxBattler}"].refresh
  end

  def pbResetCommandsIndex(idxBattler)
    @lastCmd[idxBattler] = 0
    @lastMove[idxBattler] = 0
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------

  # This method is called when the player wins a wild Pokémon battle.
  # This method can change the battle's music for example.
  def pbWildBattleSuccess
    @battleEnd = true
    pbBGMPlay(pbGetWildVictoryBGM)
  end

  # This method is called when the player wins a trainer battle.
  # This method can change the battle's music for example.
  def pbTrainerBattleSuccess
    @battleEnd = true
    pbBGMPlay(pbGetTrainerVictoryBGM(@battle.opponent))
  end
end
