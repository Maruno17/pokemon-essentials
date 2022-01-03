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
  attr_reader :name

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

  def initialize(name, values, getProc, setProc)
    @name    = name
    @values  = values.map { |val| _INTL(val) }
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
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, range, getProc, setProc)
    @name = name
    case range
    when Range
      @optstart = range.begin
      @optend = range.end
    when Array
      @optstart = range[0]
      @optend = range[1]
    end
    @getProc = getProc
    @setProc = setProc
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

  def initialize(name, range, getProc, setProc)
    @name        = name
    @optstart    = range[0]
    @optend      = range[1]
    @optinterval = range[2]
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
    @options = options
    @nameBaseColor   = Color.new(192, 120, 0)
    @nameShadowColor = Color.new(248, 176, 80)
    @selBaseColor    = Color.new(248, 48, 24)
    @selShadowColor  = Color.new(248, 136, 128)
    @optvalues = []
    @mustUpdateOptions = false
    @options.length.times do |i|
      @optvalues[i] = 0
    end
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
    optionname = (index == @options.length) ? _INTL("Close") : @options[index].name
    optionwidth = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     @nameBaseColor, @nameShadowColor)
    return if index == @options.length
    case @options[index]
    when EnumOption
      if @options[index].values.length > 1
        totalwidth = 0
        @options[index].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        @options[index].values.each do |value|
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
      value = _INTL("Type {1}/{2}", @options[index].optstart + self[index],
                    @options[index].optend - @options[index].optstart + 1)
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    when SliderOption
      value = sprintf(" %d", @options[index].optend)
      sliderlength = optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + (rect.height / 2),
                              optionwidth - self.contents.text_size(value).width, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[index].optstart + self[index]) / @options[index].optend),
        rect.y - 8 + (rect.height / 2),
        8, 16, @selBaseColor
      )
      value = sprintf("%d", @options[index].optstart + self[index])
      xpos += optionwidth - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       @selBaseColor, @selShadowColor)
    else
      value = @options[index].values[self[index]]
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
        self[self.index] = @options[self.index].prev(self[self.index])
        dorefresh = true
        @mustUpdateOptions = true
      elsif Input.repeat?(Input::RIGHT)
        self[self.index] = @options[self.index].next(self[self.index])
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
  attr_reader :in_load_screen

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(in_load_screen = false)
    @in_load_screen = in_load_screen
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Options"), 0, 0, Graphics.width, 64, @viewport
    )
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # Get all options
    @options = []
    MenuHandlers.each_available(:options_menu) do |option, hash, name|
      @options.push(
        hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
      )
    end
    @sprites["option"] = Window_PokemonOption.new(
      @options, 0, @sprites["title"].height, Graphics.width,
      Graphics.height - @sprites["title"].height - @sprites["textbox"].height
    )
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    @options.length.times do |i|
      @sprites["option"].setValueNoRefresh(i, (@options[i].get || 0))
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
          @sprites["textbox"].letterbyletter = false
          # Set the values of each option
          @options.length.times do |i|
            @options[i].set(@sprites["option"][i], self)
          end
          if $PokemonSystem.textskin != oldTextSkin
            @sprites["textbox"].text = _INTL("Speech frame {1}.", 1 + $PokemonSystem.textskin)
            oldTextSkin = $PokemonSystem.textskin
          end
          if $PokemonSystem.frame != oldSystemSkin
            @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame)
            oldSystemSkin = $PokemonSystem.frame
          end
        end
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          break if @sprites["option"].index == @options.length
        end
      end
    }
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    @options.length.times do |i|
      @options[i].set(@sprites["option"][i], self)
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

  def pbStartScreen(in_load_screen = false)
    @scene.pbStartScene(in_load_screen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end

#===============================================================================
# Options Menu commands
#===============================================================================
MenuHandlers.add(:options_menu, :bgm_volume, {
  "name"        => _INTL("Music Volume"),
  "order"       => 10,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { next $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.bgmvolume == value
    $PokemonSystem.bgmvolume = value
    next if scene.in_load_screen || $game_system.playing_bgm.nil?
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgm_resume(playingBGM)
  }
})

MenuHandlers.add(:options_menu, :se_volume, {
  "name"        => _INTL("SE Volume"),
  "order"       => 20,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "get_proc"    => proc { next $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.sevolume == value
    $PokemonSystem.sevolume = value
    if $game_system.playing_bgs
      $game_system.playing_bgs.volume = value
      playingBGS = $game_system.getPlayingBGS
      $game_system.bgs_pause
      $game_system.bgs_resume(playingBGS)
    end
    pbPlayCursorSE
  }
})

MenuHandlers.add(:options_menu, :text_speed, {
  "name"        => _INTL("Text Speed"),
  "order"       => 30,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Slow"), _INTL("Normal"), _INTL("Fast")],
  "get_proc"    => proc { next $PokemonSystem.textspeed },
  "set_proc"    => proc { |value, scene|
    next if value == $PokemonSystem.textspeed
    $PokemonSystem.textspeed = value
    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    # Display the message with the selected text speed to gauge it better.
    scene.sprites["textbox"].textspeed      = MessageConfig.pbGetTextSpeed
    scene.sprites["textbox"].letterbyletter = true
    scene.sprites["textbox"].text           = scene.sprites["textbox"].text
  }
})

MenuHandlers.add(:options_menu, :battle_animations, {
  "name"        => _INTL("Battle Effects"),
  "order"       => 40,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "get_proc"    => proc { next $PokemonSystem.battlescene },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlescene = value }
})

MenuHandlers.add(:options_menu, :battle_style, {
  "name"        => _INTL("Battle Style"),
  "order"       => 50,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Switch"), _INTL("Set")],
  "get_proc"    => proc { next $PokemonSystem.battlestyle },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlestyle = value }
})

MenuHandlers.add(:options_menu, :movement_style, {
  "name"        => _INTL("Default Movement"),
  "order"       => 60,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Walking"), _INTL("Running")],
  "condition"   => proc { next $player&.has_running_shoes },
  "get_proc"    => proc { next $PokemonSystem.runstyle },
  "set_proc"    => proc { |value, _sceme| $PokemonSystem.runstyle = value }
})

MenuHandlers.add(:options_menu, :give_nicknames, {
  "name"        => _INTL("Give Nicknames"),
  "order"       => 70,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Give"), _INTL("Don't give")],
  "get_proc"    => proc { next $PokemonSystem.givenicknames },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.givenicknames = value }
})

MenuHandlers.add(:options_menu, :speech_frame, {
  "name"        => _INTL("Speech Frame"),
  "order"       => 80,
  "type"        => NumberOption,
  "parameters"  => 1..Settings::SPEECH_WINDOWSKINS.length,
  "get_proc"    => proc { next $PokemonSystem.textskin },
  "set_proc"    => proc { |value, scene|
    $PokemonSystem.textskin = value
    MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
    # Change the windowskin of the options text box to selected one
    scene.sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
  }
})

MenuHandlers.add(:options_menu, :menu_frame, {
  "name"        => _INTL("Menu Frame"),
  "order"       => 90,
  "type"        => NumberOption,
  "parameters"  => 1..Settings::MENU_WINDOWSKINS.length,
  "get_proc"    => proc { next $PokemonSystem.frame },
  "set_proc"    => proc { |value, scene|
    $PokemonSystem.frame = value
    MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
    # Change the windowskin of the options text box to selected one
    scene.sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
  }
})

MenuHandlers.add(:options_menu, :text_input_style, {
  "name"        => _INTL("Text Entry"),
  "order"       => 100,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Cursor"), _INTL("Keyboard")],
  "get_proc"    => proc { next $PokemonSystem.textinput },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.textinput = value }
})

MenuHandlers.add(:options_menu, :screen_size, {
  "name"        => _INTL("Screen Size"),
  "order"       => 110,
  "type"        => EnumOption,
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
  "get_proc"    => proc { next [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.screensize == value
    $PokemonSystem.screensize = value
    pbSetResizeFactor($PokemonSystem.screensize)
  }
})
