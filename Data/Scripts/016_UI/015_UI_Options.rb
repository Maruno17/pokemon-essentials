#===============================================================================
#
#===============================================================================
class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :givenicknames
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :runstyle
  attr_accessor :bgmvolume
  attr_accessor :sevolume
  attr_accessor :textinput

  def initialize
    @textspeed     = 1     # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene   = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle   = 0     # Battle style (0=switch, 1=set)
    @givenicknames = 0     # Give nicknames (0=give, 1=don't give)
    @frame         = 0     # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin      = 0     # Speech frame
    @screensize    = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language      = 0     # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle      = 0     # Default movement speed (0=walk, 1=run)
    @bgmvolume     = 100   # Volume of background music and ME
    @sevolume      = 100   # Volume of sound effects
    @textinput     = 0     # Text input mode (0=cursor, 1=keyboard)
  end
end

#===============================================================================
#
#===============================================================================
module PropertyMixin
  attr_reader   :name
  attr_reader   :description

  def get
    (@getProc) ? @getProc.call : nil
  end

  def set(*args)
    @setProc&.call(*args)
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption
  include PropertyMixin
  attr_reader :values

  def initialize(name, parameters, getProc, setProc, description)
    @name        = name
    @values      = parameters
    @getProc     = getProc
    @setProc     = setProc
    @description = description
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    return index
  end
end

#===============================================================================
#
#===============================================================================
class NumberOption
  include PropertyMixin
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, parameters, getProc, setProc, description)
    @name        = name
    @optstart    = parameters[0]
    @optend      = parameters[1]
    @getProc     = getProc
    @setProc     = setProc
    @description = description
  end

  def next(current)
    index = current + @optstart
    index += 1
    index = @optstart if index > @optend
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= 1
    index = @optend if index < @optstart
    return index - @optstart
  end
end

#===============================================================================
#
#===============================================================================
class SliderOption
  include PropertyMixin
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, parameters, getProc, setProc, description)
    @name        = name
    @optstart    = parameters[0]
    @optend      = parameters[1]
    @optinterval = parameters[2]
    @getProc     = getProc
    @setProc     = setProc
    @description = description
  end

  def next(current)
    index = current + @optstart
    index += @optinterval
    index = @optend if index > @optend
    return index - @optstart
  end

  def prev(current)
    index = current + @optstart
    index -= @optinterval
    index = @optstart if index < @optstart
    return index - @optstart
  end
end

#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options, x, y, width, height)
    @options           = options
    @nameBaseColor     = Color.new(0, 112, 248)
    @nameShadowColor   = Color.new(144, 200, 248)
    @selBaseColor      = Color.new(232, 32, 16)
    @selShadowColor    = Color.new(248, 168, 184)
    @optvalues         = []
    @mustUpdateOptions = false
    @options.length.times { |i| @optvalues[i] = 0 }
    super(x, y, width, height)
  end

  def current_option
    return @options.values[index]
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i, value)
    @optvalues[i] = value
    refresh
  end

  def setValueNoRefresh(i, value)
    @optvalues[i] = value
  end

  def itemCount
    return @options.length + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    key = @options.keys[index]
    optionname   = (index == @options.length) ? _INTL("Cancel") : @options[key].name
    optionwidth  = rect.width * 9 / 20
    base_color   = index == self.index ? @nameBaseColor : self.baseColor
    shadow_color = index == self.index ? @nameShadowColor : self.shadowColor
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     base_color, shadow_color)
    return if index == @options.length
    case @options[key]
    when EnumOption
      if @options[key].values.length > 1
        totalwidth = 0
        @options[key].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth - totalwidth) / (@options[key].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        @options[key].values.each do |value|
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? @selBaseColor : self.baseColor,
                           (ivalue == self[index]) ? @selShadowColor : self.shadowColor)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    when NumberOption
      value = _INTL("Type {1}/{2}", @options[key].optstart + self[index],
                    @options[key].optend - @options[key].optstart + 1)
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor, 1)
    when SliderOption
      value = sprintf(" %d", @options[key].optend)
      sliderlength = optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + (rect.height / 2),
                              optionwidth - self.contents.text_size(value).width, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[key].optstart + self[index]) / @options[key].optend),
        rect.y - 8 + (rect.height / 2),
        8, 16, @selBaseColor
      )
      value = sprintf("%d", @options[key].optstart + self[index])
      xpos += optionwidth - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    else
      value = @options[key].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    end
  end

  def update
    oldindex = self.index
    @mustUpdateOptions = false
    super
    dorefresh = (self.index != oldindex)
    if self.active && self.index < @options.length
      if Input.repeat?(Input::LEFT)
        self[self.index] = current_option.prev(self[self.index])
        dorefresh = true
        @mustUpdateOptions = true
      elsif Input.repeat?(Input::RIGHT)
        self[self.index] = current_option.next(self[self.index])
        dorefresh = true
        @mustUpdateOptions = true
      end
    end
    refresh if dorefresh
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class PokemonOption_Scene
  attr_reader :sprites
  attr_reader :load_screen

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(inloadscreen = false)
    @sprites     = {}
    @load_screen = inloadscreen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundOrColoredPlane(@sprites, "bg", "optionsbg", Color.new(198, 206, 214), @viewport)
    @sprites["title"] = BitmapSprite.new(Graphics.width, 64, @viewport)
    pbSetSystemFont(@sprites["title"].bitmap)
    pbDrawShadowText(@sprites["title"].bitmap, 32, 16,
       @sprites["title"].bitmap.width, @sprites["title"].bitmap.height,
        _INTL("Options"), Color.new(80, 80, 80), Color.new(160, 160, 160)
    )
    @sprites["textbox"] = pbCreateMessageWindow
    pbSetSystemFont(@sprites["textbox"].contents)
    @options = {}
    MenuHandlers.each_available(:options) do |option, hash, name|
      @options[option] = hash["type"].new(
        hash["name"], hash["parameters"], hash["get_proc"], hash["set_proc"],
        hash["description"]
      )
    end
    @sprites["textbox"].text = @options.values.first&.description || _INTL("Close the Options Menu.")
    @sprites["textbox"].letterbyletter = false
    @sprites["option"] = Window_PokemonOption.new(
      @options, 0, @sprites["title"].bitmap.height, Graphics.width,
      Graphics.height - @sprites["title"].bitmap.height - @sprites["textbox"].height
    )
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    @options.keys.each_with_index do |key, i|
      @sprites["option"].setValueNoRefresh(i, (@options[key].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbAddOnOptions(options)
    return options
  end

  def pbOptions
    old_index     = -1
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          @sprites["textbox"].letterbyletter = false
          @options.keys.each_with_index do |key, i|
            @options[key].set(@sprites["option"][i], self)
          end
        end
        if @sprites["option"].index != old_index
          @sprites["textbox"].letterbyletter = false
          text = @sprites["option"].current_option&.description || _INTL("Close the Options Menu.")
          @sprites["textbox"].text = text
        end
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          break if @sprites["option"].index == @options.length
        end
        old_index = @sprites["option"].index
      end
    }
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    @options.keys.each_with_index do |key, i|
      @options[key].set(@sprites["option"][i], self)
    end
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonOptionScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(inloadscreen = false)
    @scene.pbStartScene(inloadscreen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end

#===============================================================================
# Options Menu commands
#===============================================================================
MenuHandlers.add(:options, :bgm_volume, {
  "name"        => _INTL("Music Volume"),
  "type"        => SliderOption,
  "order"       => 10,
  "description" => _INTL("Adjust the volume of the background music."),
  "parameters"  => [0, 100, 5], # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.bgmvolume == value
    $PokemonSystem.bgmvolume = value
    if !$game_system.playing_bgm.nil? && !scene.load_screen
      playingBGM = $game_system.getPlayingBGM
      $game_system.bgm_pause
      $game_system.bgm_resume(playingBGM)
    end
  }
})

MenuHandlers.add(:options, :se_volume, {
  "name"        => _INTL("SE Volume"),
  "type"        => SliderOption,
  "order"       => 20,
  "description" => _INTL("Adjust the volume of sound effects."),
  "parameters"  => [0, 100, 5], # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.sevolume == value
    $PokemonSystem.sevolume = value
    if !$game_system.playing_bgs.nil?
      $game_system.playing_bgs.volume = value
      playingBGS = $game_system.getPlayingBGS
      $game_system.bgs_pause
      $game_system.bgs_resume(playingBGS)
    end
    pbPlayCursorSE
  }
})

MenuHandlers.add(:options, :text_speed, {
  "name"        => _INTL("Text Speed"),
  "type"        => EnumOption,
  "order"       => 30,
  "description" => _INTL("Choose the speed at which messages are displayed."),
  "parameters"  => [_INTL("Slow"), _INTL("Normal"), _INTL("Fast")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.textspeed },
  "set_proc"    => proc { |value, scene|
    old_text  = scene.sprites["textbox"].text
    old_speed = $PokemonSystem.textspeed
    $PokemonSystem.textspeed = value
    next if $PokemonSystem.textspeed == old_speed
    # Display the message with the selected text speed to gauge it better.
    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    pbSetSystemFont(scene.sprites["textbox"].contents)
    scene.sprites["textbox"].textspeed      = MessageConfig.pbGetTextSpeed
    scene.sprites["textbox"].letterbyletter = true
    scene.sprites["textbox"].text           = old_text
  }
})

MenuHandlers.add(:options, :battle_animations, {
  "name"        => _INTL("Battle Effects"),
  "type"        => EnumOption,
  "order"       => 40,
  "description" => _INTL("Choose whether you wish to see move animations in battle or not."),
  "parameters"  => [_INTL("On"), _INTL("Off")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.battlescene },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlescene = value }
})

MenuHandlers.add(:options, :battle_style, {
  "name"        => _INTL("Battle Style"),
  "type"        => EnumOption,
  "order"       => 50,
  "description" => _INTL("Choose if you want to switch Pokémon after an opponent faints or not."),
  "parameters"  => [_INTL("Switch"), _INTL("Set")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.battlestyle },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlestyle = value }
})

MenuHandlers.add(:options, :movement_style, {
  "name"        => _INTL("Default Movement"),
  "type"        => EnumOption,
  "order"       => 60,
  "condition"   => proc { $player&.has_running_shoes },
  "description" => _INTL("Choose whether you want to always run when moving or not."),
  "parameters"  => [_INTL("Walking"), _INTL("Running")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.runstyle },
  "set_proc"    => proc { |value, _sceme| $PokemonSystem.runstyle = value }
})

MenuHandlers.add(:options, :give_nicknames, {
  "name"        => _INTL("Give Nicknames"),
  "type"        => EnumOption,
  "order"       => 70,
  "description" => _INTL("Choose whether you wish to give a nickname to a Pokémon when you obtain it."),
  "parameters"  => [_INTL("Give"), _INTL("Don't give")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.givenicknames },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.givenicknames = value }
})

MenuHandlers.add(:options, :speech_frame, {
  "name"        => _INTL("Speech Frame"),
  "type"        => NumberOption,
  "order"       => 80,
  "description" => _INTL("Choose the type of frame you want to use for dialogue boxes."),
  "parameters"  => [1, Settings::SPEECH_WINDOWSKINS.length], # [minimum_value, maximum_value]
  "get_proc"    => proc { $PokemonSystem.textskin },
  "set_proc"    => proc { |value, scene|
    $PokemonSystem.textskin = value
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
    # Change the windowskin of the options text box to selected one
    scene.sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
  }
})

MenuHandlers.add(:options, :menu_frame, {
  "name"        => _INTL("Menu Frame"),
  "type"        => NumberOption,
  "order"       => 90,
  "description" => _INTL("Choose the type of frame you want to use for choice boxes."),
  "parameters"  => [1, Settings::MENU_WINDOWSKINS.length], # [minimum_value, maximum_value]
  "get_proc"    => proc { $PokemonSystem.frame },
  "set_proc"    => proc { |value, scene|
    $PokemonSystem.frame = value
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    # Change the windowskin of the options text box to selected one
    scene.sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
  }
})

MenuHandlers.add(:options, :text_input_style, {
  "name"        => _INTL("Text Entry"),
  "type"        => EnumOption,
  "order"       => 100,
  "description" => _INTL("Choose if you want to input text using the keyboard or an on-screen cursor."),
  "parameters"  => [_INTL("Cursor"), _INTL("Keyboard")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.textinput },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.textinput = value }
})

MenuHandlers.add(:options, :screen_size, {
  "name"        => _INTL("Screen Size"),
  "type"        => EnumOption,
  "order"       => 110,
  "description" => _INTL("Adjust the size of the game window."),
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")], # all possible choices
  "get_proc"    => proc { [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.screensize == value
    $PokemonSystem.screensize = value
    pbSetResizeFactor($PokemonSystem.screensize)
  }
})
