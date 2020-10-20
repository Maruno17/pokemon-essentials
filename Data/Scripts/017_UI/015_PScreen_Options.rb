class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_writer   :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_writer   :border
  attr_writer   :language
  attr_writer   :runstyle
  attr_writer   :bgmvolume
  attr_writer   :sevolume
  attr_writer   :textinput

  def initialize
    @textspeed   = 1     # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle = 0     # Battle style (0=switch, 1=set)
    @frame       = 0     # Default window frame (see also $TextFrames)
    @textskin    = 0     # Speech frame
    @font        = 0     # Font (see also $VersionStyles)
    @screensize  = (SCREEN_ZOOM.floor).to_i   # 0=half size, 1=full size, 2=double size
    @border      = 0     # Screen border (0=off, 1=on)
    @language    = 0     # Language (see also LANGUAGES in script PokemonSystem)
    @runstyle    = 0     # Run key functionality (0=hold to run, 1=toggle auto-run)
    @bgmvolume   = 100   # Volume of background music and ME
    @sevolume    = 100   # Volume of sound effects
    @textinput   = 0     # Text input mode (0=cursor, 1=keyboard)
  end

  def textskin;  return @textskin || 0;    end
  def border;    return @border || 0;      end
  def language;  return @language || 0;    end
  def runstyle;  return @runstyle || 0;    end
  def bgmvolume; return @bgmvolume || 100; end
  def sevolume;  return @sevolume || 100;  end
  def textinput; return @textinput || 0;   end
  def tilemap;   return MAP_VIEW_MODE;     end
end



#===============================================================================
# Stores game options
# Default options are at the top of script section SpriteWindow.
#===============================================================================
$SpeechFrames = [
  MessageConfig::TextSkinName,   # Default: speech hgss 1
  "speech hgss 2",
  "speech hgss 3",
  "speech hgss 4",
  "speech hgss 5",
  "speech hgss 6",
  "speech hgss 7",
  "speech hgss 8",
  "speech hgss 9",
  "speech hgss 10",
  "speech hgss 11",
  "speech hgss 12",
  "speech hgss 13",
  "speech hgss 14",
  "speech hgss 15",
  "speech hgss 16",
  "speech hgss 17",
  "speech hgss 18",
  "speech hgss 19",
  "speech hgss 20",
  "speech pl 18"
]

$TextFrames = [
  "Graphics/Windowskins/"+MessageConfig::ChoiceSkinName,   # Default: choice 1
  "Graphics/Windowskins/choice 2",
  "Graphics/Windowskins/choice 3",
  "Graphics/Windowskins/choice 4",
  "Graphics/Windowskins/choice 5",
  "Graphics/Windowskins/choice 6",
  "Graphics/Windowskins/choice 7",
  "Graphics/Windowskins/choice 8",
  "Graphics/Windowskins/choice 9",
  "Graphics/Windowskins/choice 10",
  "Graphics/Windowskins/choice 11",
  "Graphics/Windowskins/choice 12",
  "Graphics/Windowskins/choice 13",
  "Graphics/Windowskins/choice 14",
  "Graphics/Windowskins/choice 15",
  "Graphics/Windowskins/choice 16",
  "Graphics/Windowskins/choice 17",
  "Graphics/Windowskins/choice 18",
  "Graphics/Windowskins/choice 19",
  "Graphics/Windowskins/choice 20",
  "Graphics/Windowskins/choice 21",
  "Graphics/Windowskins/choice 22",
  "Graphics/Windowskins/choice 23",
  "Graphics/Windowskins/choice 24",
  "Graphics/Windowskins/choice 25",
  "Graphics/Windowskins/choice 26",
  "Graphics/Windowskins/choice 27",
  "Graphics/Windowskins/choice 28"
]

$VersionStyles = [
  [MessageConfig::FontName],   # Default font style - Power Green/"Pokemon Emerald"
  ["Power Red and Blue"],
  ["Power Red and Green"],
  ["Power Clear"]
]

def pbSettingToTextSpeed(speed)
  case speed
  when 0; return 2
  when 1; return 1
  when 2; return -2
  end
  return MessageConfig::TextSpeed || 1
end



module MessageConfig
  def self.pbDefaultSystemFrame
    begin
      return pbResolveBitmap($TextFrames[$PokemonSystem.frame]) || ""
    rescue
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::ChoiceSkinName) || ""
    end
  end

  def self.pbDefaultSpeechFrame
    begin
      return pbResolveBitmap("Graphics/Windowskins/"+$SpeechFrames[$PokemonSystem.textskin]) || ""
    rescue
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::TextSkinName) || ""
    end
  end

  def self.pbDefaultSystemFontName
    begin
      return MessageConfig.pbTryFonts($VersionStyles[$PokemonSystem.font][0],"Arial Narrow","Arial")
    rescue
      return MessageConfig.pbTryFonts(MessageConfig::FontName,"Arial Narrow","Arial")
    end
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed(($PokemonSystem.textspeed rescue nil))
  end

  def pbGetSystemTextSpeed
    begin
      return $PokemonSystem.textspeed
    rescue
      return (Graphics.frame_rate>40) ? 2 :  3
    end
  end
end



#===============================================================================
#
#===============================================================================
module PropertyMixin
  def get
    (@getProc) ? @getProc.call : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end



class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)
    @name    = name
    @values  = options
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current+1
    index = @values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index = current-1
    index = 0 if index<0
    return index
  end
end



class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)
    @name    = name
    @values  = options
    @getProc = getProc
    @setProc = setProc
  end

  def next(current)
    index = current+1
    index = @values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index = current-1
    index = 0 if index<0
    return index
  end
end



class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name,optstart,optend,getProc,setProc)
    @name     = name
    @optstart = optstart
    @optend   = optend
    @getProc  = getProc
    @setProc  = setProc
  end

  def next(current)
    index = current+@optstart
    index += 1
    index = @optstart if index>@optend
    return index-@optstart
  end

  def prev(current)
    index = current+@optstart
    index -= 1
    index = @optend if index<@optstart
    return index-@optstart
  end
end



class SliderOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name,optstart,optend,optinterval,getProc,setProc)
    @name        = name
    @optstart    = optstart
    @optend      = optend
    @optinterval = optinterval
    @getProc     = getProc
    @setProc     = setProc
  end

  def next(current)
    index = current+@optstart
    index += @optinterval
    index = @optend if index>@optend
    return index-@optstart
  end

  def prev(current)
    index = current+@optstart
    index -= @optinterval
    index = @optstart if index<@optstart
    return index-@optstart
  end
end



#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options,x,y,width,height)
    @options = options
    @nameBaseColor   = Color.new(24*8,15*8,0)
    @nameShadowColor = Color.new(31*8,22*8,10*8)
    @selBaseColor    = Color.new(31*8,6*8,3*8)
    @selShadowColor  = Color.new(31*8,17*8,16*8)
    @optvalues = []
    @mustUpdateOptions = false
    for i in 0...@options.length
      @optvalues[i] = 0
    end
    super(x,y,width,height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i,value)
    @optvalues[i] = value
    refresh
  end

  def setValueNoRefresh(i,value)
    @optvalues[i] = value
  end

  def itemCount
    return @options.length+1
  end

  def drawItem(index,_count,rect)
    rect = drawCursor(index,rect)
    optionname = (index==@options.length) ? _INTL("Cancel") : @options[index].name
    optionwidth = rect.width*9/20
    text_y = rect.y + (mkxp? ? 6 : 0)
    pbDrawShadowText(self.contents,rect.x,text_y,optionwidth,rect.height,optionname,
       @nameBaseColor,@nameShadowColor)
    return if index==@options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length>1
        totalwidth = 0
        for value in @options[index].values
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth-totalwidth)/(@options[index].values.length-1)
        spacing = 0 if spacing<0
        xpos = optionwidth+rect.x
        ivalue = 0
        for value in @options[index].values
          pbDrawShadowText(self.contents,xpos,text_y,optionwidth,rect.height,value,
             (ivalue==self[index]) ? @selBaseColor : self.baseColor,
             (ivalue==self[index]) ? @selShadowColor : self.shadowColor
          )
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents,rect.x+optionwidth,text_y,optionwidth,rect.height,
           optionname,self.baseColor,self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value = _INTL("Type {1}/{2}",@options[index].optstart+self[index],
         @options[index].optend-@options[index].optstart+1)
      xpos = optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,text_y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    elsif @options[index].is_a?(SliderOption)
      value = sprintf(" %d",@options[index].optend)
      sliderlength = optionwidth-self.contents.text_size(value).width
      xpos = optionwidth+rect.x
      self.contents.fill_rect(xpos,rect.y-2+rect.height/2,
         optionwidth-self.contents.text_size(value).width,4,self.baseColor)
      self.contents.fill_rect(
         xpos+(sliderlength-8)*(@options[index].optstart+self[index])/@options[index].optend,
         rect.y-8+rect.height/2,
         8,16,@selBaseColor)
      value = sprintf("%d",@options[index].optstart+self[index])
      xpos += optionwidth-self.contents.text_size(value).width
      pbDrawShadowText(self.contents,xpos,text_y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,text_y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    end
  end

  def update
    oldindex = self.index
    @mustUpdateOptions = false
    super
    dorefresh = (self.index!=oldindex)
    if self.active && self.index<@options.length
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
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(inloadscreen=false)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = [
       SliderOption.new(_INTL("Music Volume"),0,100,5,
         proc { $PokemonSystem.bgmvolume },
         proc { |value|
           if $PokemonSystem.bgmvolume!=value
             $PokemonSystem.bgmvolume = value
             if $game_system.playing_bgm!=nil && !inloadscreen
               $game_system.playing_bgm.volume = value
               playingBGM = $game_system.getPlayingBGM
               $game_system.bgm_pause
               $game_system.bgm_resume(playingBGM)
             end
           end
         }
       ),
       SliderOption.new(_INTL("SE Volume"),0,100,5,
         proc { $PokemonSystem.sevolume },
         proc { |value|
           if $PokemonSystem.sevolume!=value
             $PokemonSystem.sevolume = value
             if $game_system.playing_bgs!=nil
               $game_system.playing_bgs.volume = value
               playingBGS = $game_system.getPlayingBGS
               $game_system.bgs_pause
               $game_system.bgs_resume(playingBGS)
             end
             pbPlayCursorSE
           end
         }
       ),
       EnumOption.new(_INTL("Text Speed"),[_INTL("Slow"),_INTL("Normal"),_INTL("Fast")],
         proc { $PokemonSystem.textspeed },
         proc { |value|
           $PokemonSystem.textspeed = value
           MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value))
         }
       ),
       EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.battlescene },
         proc { |value| $PokemonSystem.battlescene = value }
       ),
       EnumOption.new(_INTL("Battle Style"),[_INTL("Switch"),_INTL("Set")],
         proc { $PokemonSystem.battlestyle },
         proc { |value| $PokemonSystem.battlestyle = value }
       ),
       EnumOption.new(_INTL("Running Key"),[_INTL("Hold"),_INTL("Toggle")],
         proc { $PokemonSystem.runstyle },
         proc { |value|
           if $PokemonSystem.runstyle!=value
             $PokemonSystem.runstyle = value
             $PokemonGlobal.runtoggle = false if $PokemonGlobal
           end
         }
       ),
       NumberOption.new(_INTL("Speech Frame"),1,$SpeechFrames.length,
         proc { $PokemonSystem.textskin },
         proc { |value|
           $PokemonSystem.textskin = value
           MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/"+$SpeechFrames[value])
         }
       ),
       NumberOption.new(_INTL("Menu Frame"),1,$TextFrames.length,
         proc { $PokemonSystem.frame },
         proc { |value|
           $PokemonSystem.frame = value
           MessageConfig.pbSetSystemFrame($TextFrames[value])
         }
       ),
       EnumOption.new(_INTL("Font Style"),[_INTL("Em"),_INTL("R/S"),_INTL("FRLG"),_INTL("DP")],
         proc { $PokemonSystem.font },
         proc { |value|
           $PokemonSystem.font = value
           MessageConfig.pbSetSystemFontName($VersionStyles[value])
         }
       ),
       EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
         proc { $PokemonSystem.textinput },
         proc { |value| $PokemonSystem.textinput = value }
       ),
       EnumOption.new(_INTL("Screen Size"),[_INTL("S"),_INTL("M"),_INTL("L"),_INTL("Full")],
         proc { [$PokemonSystem.screensize,3].min },
         proc { |value|
           oldvalue = $PokemonSystem.screensize
           $PokemonSystem.screensize = value
           if value!=oldvalue
             pbSetResizeFactor($PokemonSystem.screensize)
             ObjectSpace.each_object(TilemapLoader) { |o| o.updateClass if !o.disposed? }
           end
         }
       ),
       EnumOption.new(_INTL("Screen Border"),[_INTL("Off"),_INTL("On")],
         proc { $PokemonSystem.border },
         proc { |value|
           oldvalue = $PokemonSystem.border
           $PokemonSystem.border = value
           if value!=oldvalue
             pbSetResizeFactor($PokemonSystem.screensize)
             ObjectSpace.each_object(TilemapLoader) { |o| o.updateClass if !o.disposed? }
           end
         }
       )
    ]
    @PokemonOptions = pbAddOnOptions(@PokemonOptions)
    @sprites["option"] = Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"].setValueNoRefresh(i,(@PokemonOptions[i].get || 0))
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
    oldFont       = $PokemonSystem.font
    pbActivateWindow(@sprites,"option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option
          for i in 0...@PokemonOptions.length
            @PokemonOptions[i].set(@sprites["option"][i])
          end
          if $PokemonSystem.textskin!=oldTextSkin
            @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
            @sprites["textbox"].text = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
            oldTextSkin = $PokemonSystem.textskin
          end
          if $PokemonSystem.frame!=oldSystemSkin
            @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame())
            @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame())
            oldSystemSkin = $PokemonSystem.frame
          end
          if $PokemonSystem.font!=oldFont
            pbSetSystemFont(@sprites["textbox"].contents)
            @sprites["textbox"].text = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
            oldFont = $PokemonSystem.font
          end
        end
        if Input.trigger?(Input::B)
          break
        elsif Input.trigger?(Input::C)
          break if @sprites["option"].index==@PokemonOptions.length
        end
      end
    }
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@PokemonOptions.length
      @PokemonOptions[i].set(@sprites["option"][i])
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

  def pbStartScreen(inloadscreen=false)
    @scene.pbStartScene(inloadscreen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end
