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
  attr_reader :name

  def initialize(name, parameters, getProc, setProc)
    @name    = name
    @values  = parameters
    @getProc = getProc
    @setProc = setProc
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
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, parameters, getProc, setProc)
    @name     = name
    @optstart = parameters[0]
    @optend   = parameters[1]
    @getProc  = getProc
    @setProc  = setProc
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
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, parameters, getProc, setProc)
    @name        = name
    @optstart    = parameters[0]
    @optend      = parameters[1]
    @optinterval = parameters[2]
    @getProc     = getProc
    @setProc     = setProc
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
    @nameBaseColor     = Color.new(24 * 8, 15 * 8, 0)
    @nameShadowColor   = Color.new(31 * 8, 22 * 8, 10 * 8)
    @selBaseColor      = Color.new(31 * 8, 6 * 8, 3 * 8)
    @selShadowColor    = Color.new(31 * 8, 17 * 8, 16 * 8)
    @optvalues         = []
    @mustUpdateOptions = false
    @options.length.times { |i| @optvalues[i] = 0 }
    super(x, y, width, height)
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
    optionname = (index == @options.length) ? _INTL("Cancel") : @options[key].name
    optionwidth = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     @nameBaseColor, @nameShadowColor)
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
                       @selBaseColor, @selShadowColor)
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
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(inloadscreen = false)
    @sprites     = {}
    @load_screen = inloadscreen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Options"), 0, 0, Graphics.width, 64, @viewport
    )
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = {}
    MenuHandlers.each_available(:options) do |option, hash, name|
      @PokemonOptions[option] = hash["type"].new(hash["name"], hash["parameters"], hash["get_proc"], hash["set_proc"])
    end
    @sprites["option"] = Window_PokemonOption.new(
      @PokemonOptions, 0, @sprites["title"].height, Graphics.width,
      Graphics.height - @sprites["title"].height - @sprites["textbox"].height
    )
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    @PokemonOptions.keys.each_with_index do |key, i|
      @sprites["option"].setValueNoRefresh(i, (@PokemonOptions[key].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbAddOnOptions(options)
    return options
  end

  def pbOptions
    oldSystemSkin = $PokemonSystem.frame      # Menu
    oldTextSkin   = $PokemonSystem.textskin   # Speech
    pbActivateWindow(@sprites, "option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          @PokemonOptions.keys.each_with_index do |key, i|
            @PokemonOptions[key].set(@sprites["option"][i], @load_screen)
          end
          if $PokemonSystem.textskin != oldTextSkin
            @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
            @sprites["textbox"].text = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
            oldTextSkin = $PokemonSystem.textskin
          end
          if $PokemonSystem.frame != oldSystemSkin
            @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame)
            @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
            oldSystemSkin = $PokemonSystem.frame
          end
        end
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          break if @sprites["option"].index == @PokemonOptions.length
        end
      end
    }
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    @PokemonOptions.keys.each_with_index do |key, i|
      @PokemonOptions[key].set(@sprites["option"][i], @load_screen)
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
  "parameters"  => [0, 100, 5], # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, load_screen|
    if $PokemonSystem.bgmvolume != value
      $PokemonSystem.bgmvolume = value
      if $game_system.playing_bgm != nil && !load_screen
        playingBGM = $game_system.getPlayingBGM
        $game_system.bgm_pause
        $game_system.bgm_resume(playingBGM)
      end
    end
  }
})

MenuHandlers.add(:options, :se_volume, {
  "name"        => _INTL("SE Volume"),
  "type"        => SliderOption,
  "order"       => 20,
  "parameters"  => [0, 100, 5], # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _load_screen|
    if $PokemonSystem.sevolume != value
      $PokemonSystem.sevolume = value
      if $game_system.playing_bgs != nil
        $game_system.playing_bgs.volume = value
        playingBGS = $game_system.getPlayingBGS
        $game_system.bgs_pause
        $game_system.bgs_resume(playingBGS)
      end
      pbPlayCursorSE
    end
  }
})

MenuHandlers.add(:options, :text_speed, {
  "name"        => _INTL("Text Speed"),
  "type"        => EnumOption,
  "order"       => 30,
  "parameters"  => [_INTL("Slow"), _INTL("Normal"), _INTL("Fast")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.textspeed },
  "set_proc"    => proc { |value, _load_screen|
    $PokemonSystem.textspeed = value
    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
  }
})

MenuHandlers.add(:options, :battle_animations, {
  "name"        => _INTL("Battle Effects"),
  "type"        => EnumOption,
  "order"       => 40,
  "parameters"  => [_INTL("On"), _INTL("Off")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.battlescene },
  "set_proc"    => proc { |value, _load_screen| $PokemonSystem.battlescene = value }
})

MenuHandlers.add(:options, :battle_style, {
  "name"        => _INTL("Battle Style"),
  "type"        => EnumOption,
  "order"       => 50,
  "parameters"  => [_INTL("Switch"), _INTL("Set")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.battlestyle },
  "set_proc"    => proc { |value, _load_screen| $PokemonSystem.battlestyle = value }
})

MenuHandlers.add(:options, :movement_style, {
  "name"        => _INTL("Default Movement"),
  "type"        => EnumOption,
  "order"       => 60,
  "condition"   => proc { $player&.has_running_shoes },
  "description" => _INTL("Choose whether you want to always run when moving or not."),
  "parameters"  => [_INTL("Walking"), _INTL("Running")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.runstyle },
  "set_proc"    => proc { |value, _load_screen| $PokemonSystem.runstyle = value }
})

MenuHandlers.add(:options, :give_nicknames, {
  "name"        => _INTL("Give Nicknames"),
  "type"        => EnumOption,
  "order"       => 70,
  "parameters"  => [_INTL("Give"), _INTL("Don't give")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.givenicknames },
  "set_proc"    => proc { |value, _load_screen| $PokemonSystem.givenicknames = value }
})

MenuHandlers.add(:options, :speech_frame, {
  "name"        => _INTL("Speech Frame"),
  "type"        => NumberOption,
  "order"       => 80,
  "parameters"  => [1, Settings::SPEECH_WINDOWSKINS.length], # [minimum_value, maximum_value]
  "get_proc"    => proc { $PokemonSystem.textskin },
  "set_proc"    => proc { |value, _load_screen|
    $PokemonSystem.textskin = value
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
  }
})

MenuHandlers.add(:options, :menu_frame, {
  "name"        => _INTL("Menu Frame"),
  "type"        => NumberOption,
  "order"       => 90,
  "parameters"  => [1, Settings::MENU_WINDOWSKINS.length], # [minimum_value, maximum_value]
  "get_proc"    => proc { $PokemonSystem.frame },
  "set_proc"    => proc { |value, _load_screen|
    $PokemonSystem.frame = value
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
  }
})

MenuHandlers.add(:options, :text_input_style, {
  "name"        => _INTL("Text Entry"),
  "type"        => EnumOption,
  "order"       => 100,
  "parameters"  => [_INTL("Cursor"), _INTL("Keyboard")], # all possible choices
  "get_proc"    => proc { $PokemonSystem.textinput },
  "set_proc"    => proc { |value, _load_screen| $PokemonSystem.textinput = value }
})

MenuHandlers.add(:options, :screen_size, {
  "name"        => _INTL("Screen Size"),
  "type"        => EnumOption,
  "order"       => 110,
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")], # all possible choices
  "get_proc"    => proc { [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _load_screen|
    if $PokemonSystem.screensize != value
      $PokemonSystem.screensize = value
      pbSetResizeFactor($PokemonSystem.screensize)
    end
  }
})
