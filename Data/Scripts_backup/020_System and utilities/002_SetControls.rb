#===============================================================================
# * Set the Controls Screen - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's make a "Set the controls"
# option screen allowing the player to map the actions to the keys in keyboard,
# customizing the controls.
#
#===============================================================================
#
# To this script works, put it between PSystem_Controls and PSystem_System. 
#
# To this screen be displayed in the pause menu, in PScreen_PauseMenu script,
# before line 'commands[cmdDebug=commands.length]=_INTL("Debug") if $DEBUG' add:
#
# cmdControls=-1
# commands[cmdControls=commands.length]=_INTL("Controls")
#
# Before line 'elsif cmdOption>=0 && command==cmdOption' add:
#
# elsif cmdControls>=0 && command==cmdControls
#   scene=PokemonControlsScene.new       
#   screen=PokemonControls.new(scene)
#   pbFadeOutIn(99999) {
#     screen.pbStartScreen
#   }
#
# Using the last five lines you can start this scene in other places like at
# an event.
#
# Note that this script, by default, doesn't allows the player to redefine some
# commands like F8 (screenshot key), but if the player assign an action to
# this key, like the "Run" action, this key will do this action AND take
# screenshots when pressed. Remember that F12 will reset the game.
#
#===============================================================================

module Keys  
  # Available keys
  CONTROLSLIST = {
    # Mouse buttons
    _INTL("Backspace") => 0x08,
    _INTL("Tab") => 0x09,
    _INTL("Clear") => 0x0C,
    _INTL("Enter") => 0x0D,
    _INTL("Shift") => 0x10,
    _INTL("Ctrl") => 0x11,
    _INTL("Alt") => 0x12,
    _INTL("Pause") => 0x13,
    _INTL("Caps Lock") => 0x14,
    # IME keys
    _INTL("Esc") => 0x1B,
    # More IME keys
    _INTL("Space") => 0x20,
    _INTL("Page Up") => 0x21,
    _INTL("Page Down") => 0x22,
    _INTL("End") => 0x23,
    _INTL("Home") => 0x24,
    _INTL("Left") => 0x25,
    _INTL("Up") => 0x26,
    _INTL("Right") => 0x27,
    _INTL("Down") => 0x28,
    _INTL("Select") => 0x29,
    _INTL("Print") => 0x2A,
    _INTL("Execute") => 0x2B,
   # _INTL("Print Screen") => 0x2C,
    _INTL("Insert") => 0x2D,
    _INTL("Delete") => 0x2E,
    _INTL("Help") => 0x2F,
    _INTL("0") => 0x30,
    _INTL("1") => 0x31,
    _INTL("2") => 0x32,
    _INTL("3") => 0x33,
    _INTL("4") => 0x34,
    _INTL("5") => 0x35,
    _INTL("6") => 0x36,
    _INTL("7") => 0x37,
    _INTL("8") => 0x38,
    _INTL("9") => 0x39,
    _INTL("A") => 0x41,
    _INTL("B") => 0x42,
    _INTL("C") => 0x43,
    _INTL("D") => 0x44,
    _INTL("E") => 0x45,
    _INTL("F") => 0x46,
    _INTL("G") => 0x47,
    _INTL("H") => 0x48,
    _INTL("I") => 0x49,
    _INTL("J") => 0x4A,
    _INTL("K") => 0x4B,
    _INTL("L") => 0x4C,
    _INTL("M") => 0x4D,
    _INTL("N") => 0x4E,
    _INTL("O") => 0x4F,
    _INTL("P") => 0x50,
    _INTL("Q") => 0x51,
    _INTL("R") => 0x52,
    _INTL("S") => 0x53,
    _INTL("T") => 0x54,
    _INTL("U") => 0x55,
    _INTL("V") => 0x56,
    _INTL("W") => 0x57,
    _INTL("X") => 0x58,
    _INTL("Y") => 0x59,
    _INTL("Z") => 0x5A,
    # Windows keys
    _INTL("Numpad 0") => 0x60,
    _INTL("Numpad 1") => 0x61,
    _INTL("Numpad 2") => 0x62,
    _INTL("Numpad 3") => 0x63,
    _INTL("Numpad 4") => 0x64,
    _INTL("Numpad 5") => 0x65,
    _INTL("Numpad 6") => 0x66,
    _INTL("Numpad 7") => 0x67,
    _INTL("Numpad 8") => 0x68,
    _INTL("Numpad 9") => 0x69,
    _INTL("Multiply") => 0x6A,
    _INTL("Add") => 0x6B,
    _INTL("Separator") => 0x6C,
    _INTL("Subtract") => 0x6D,
    _INTL("Decimal") => 0x6E,
    _INTL("Divide") => 0x6F,
    _INTL("F1") => 0x70,
    _INTL("F2") => 0x71,
    _INTL("F3") => 0x72,
    _INTL("F4") => 0x73,
    _INTL("F5") => 0x74,
    _INTL("F6") => 0x75,
    _INTL("F7") => 0x76,
    _INTL("F8") => 0x77,
    _INTL("F9") => 0x78,
    _INTL("F10") => 0x79,
    _INTL("F11") => 0x7A,
    _INTL("F12") => 0x7B,
    _INTL("F13") => 0x7C,
    _INTL("F14") => 0x7D,
    _INTL("F15") => 0x7E,
    _INTL("F16") => 0x7F,
    _INTL("F17") => 0x80,
    _INTL("F18") => 0x81,
    _INTL("F19") => 0x82,
    _INTL("F20") => 0x83,
    _INTL("F21") => 0x84,
    _INTL("F22") => 0x85,
    _INTL("F23") => 0x86,
    _INTL("F24") => 0x87,
    _INTL("Num Lock") => 0x90,
    _INTL("Scroll Lock") => 0x91,
    # Multiple position Shift, Ctrl and Menu keys
    _INTL(";:") => 0xBA,
    _INTL("+") => 0xBB,
    _INTL(",") => 0xBC,
    _INTL("-") => 0xBD,
    _INTL(".") => 0xBE,
    _INTL("/?") => 0xBF,
    _INTL("`~") => 0xC0,
    _INTL("{") => 0xDB,
    _INTL("\|") => 0xDC,
    _INTL("}") => 0xDD,
    _INTL("'\"") => 0xDE,
    _INTL("AX") => 0xE1, # Japan only
    _INTL("\|") => 0xE2
    # Disc keys
  }
  
  # Here you can change the number of keys for each action and the
  # default values
  def self.defaultControls
    return [
      ControlConfig.new(_INTL("Down"),_INTL("Down")),
      ControlConfig.new(_INTL("Left"),_INTL("Left")),
      ControlConfig.new(_INTL("Right"),_INTL("Right")),
      ControlConfig.new(_INTL("Up"),_INTL("Up")),
      ControlConfig.new(_INTL("Action"),_INTL("C")),
      ControlConfig.new(_INTL("Action"),_INTL("Enter")),
      ControlConfig.new(_INTL("Action"),_INTL("Space")),
      ControlConfig.new(_INTL("Cancel"),_INTL("X")),
      ControlConfig.new(_INTL("Cancel"),_INTL("Esc")),
      ControlConfig.new(_INTL("Run"),_INTL("Z")),
      ControlConfig.new(_INTL("Scroll down"),_INTL("Page Down")),
      ControlConfig.new(_INTL("Scroll up"),_INTL("Page Up")),
      ControlConfig.new(_INTL("Registered/Sort"),_INTL("F5")),
      ControlConfig.new(_INTL("Run toggle"),_INTL("S")),
      ControlConfig.new(_INTL("Turbo"),_INTL("Ctrl"))
    ]
  end  
  
  def self.getKeyName(keyCode)
    ret  = CONTROLSLIST.index(keyCode) 
    return ret ? ret : (keyCode==0 ? _INTL(" - ") : "?")
  end  
  
  def self.getKeyCode(keyName)
    ret  = CONTROLSLIST[keyName] 
    raise "The button #{keyName} no longer exists! " if !ret
    return ret
  end  
  
  def self.detectKey
    loop do
      Graphics.update
      Input.update
      for keyCode in CONTROLSLIST.values
        return keyCode if Input.triggerex?(keyCode)
      end
    end 
  end  
end  

class ControlConfig
  attr_reader :controlAction
  attr_accessor :keyCode
  
  def initialize(controlAction,defaultKey)
    @controlAction = controlAction
    @keyCode = Keys.getKeyCode(defaultKey)
  end
  
  def keyName
    return Keys.getKeyName(@keyCode)
  end  
end

module Input
  class << self
    alias :buttonToKeyOldFL :buttonToKey
    # Here I redefine this method with my controlAction.
    # Note that I don't declare action for all commands.
    def buttonToKey(button)
      $PokemonSystem = PokemonSystem.new if !$PokemonSystem
      case button
        when Input::DOWN
          return $PokemonSystem.getGameControlCodes(_INTL("Down"))
        when Input::LEFT
          return $PokemonSystem.getGameControlCodes(_INTL("Left"))
        when Input::RIGHT
          return $PokemonSystem.getGameControlCodes(_INTL("Right"))
        when Input::UP
          return $PokemonSystem.getGameControlCodes(_INTL("Up"))
        when Input::A # Z, Shift
          return $PokemonSystem.getGameControlCodes(_INTL("Run"))
        when Input::B # X, ESC 
          return $PokemonSystem.getGameControlCodes(_INTL("Cancel"))
        when Input::C # C, ENTER, Space
          return $PokemonSystem.getGameControlCodes(_INTL("Action"))
        when Input::L # Page Up
          return $PokemonSystem.getGameControlCodes(_INTL("Scroll up"))
        when Input::R # Page Down
          return $PokemonSystem.getGameControlCodes(_INTL("Scroll down"))
#        when Input::SHIFT
#          return [0x10] # Shift
          #return [0x11] # Ctrl

#        when Input::ALT
#          return [0x12] # Alt
        when Input::F5 # F5
          return $PokemonSystem.getGameControlCodes(_INTL("Registered/Sort"))

        when Input::Y
           return $PokemonSystem.getGameControlCodes(_INTL("Run toggle"))  
          
        when Input::CTRL
           return $PokemonSystem.getGameControlCodes(_INTL("Turbo"))
           
         
#        when Input::F6
#          return [0x75] # F6
#        when Input::F7
#          return [0x76] # F7
#        when Input::F8
#          return [0x77] # F8
#        when Input::F9
#          return [0x78] # F9
        else
          return buttonToKeyOldFL(button)
      end
    end
  end
end

class Window_PokemonControls < Window_DrawableCommand
  attr_reader :readingInput
  attr_reader :controls
  attr_reader :changed
  
  def initialize(controls,x,y,width,height)
    @controls=controls
    @nameBaseColor=Color.new(88,88,80)
    @nameShadowColor=Color.new(168,184,184)
    @selBaseColor=Color.new(24,112,216)
    @selShadowColor=Color.new(136,168,208)
    @readingInput=false
    @changed=false
    super(x,y,width,height)
  end
  
  def setNewInput(newInput)
    @readingInput = false
    return if @controls[@index].keyCode==newInput
    for control in @controls # Remove the same input for the same array
      control.keyCode = 0 if control.keyCode==newInput
    end  
    @controls[@index].keyCode=newInput
    @changed = true
    refresh
  end

  def itemCount
    return @controls.length+2
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    optionname = ""
    if index==(@controls.length+1)
      optionname = _INTL("Exit")
    elsif index==(@controls.length)
      optionname = _INTL("Default")
    else
      optionname = @controls[index].controlAction
    end  
    optionwidth=(rect.width*9/20)
    pbDrawShadowText(self.contents,rect.x,rect.y,optionwidth,rect.height,
      optionname,@nameBaseColor,@nameShadowColor)
    self.contents.draw_text(rect.x,rect.y,optionwidth,rect.height,optionname)
    return if index>=@controls.length
    value=@controls[index].keyName
    xpos=optionwidth+rect.x
    pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
       @selBaseColor,@selShadowColor)
    self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
  end

  def update
    dorefresh=false
    oldindex=self.index
    super
    dorefresh=self.index!=oldindex
    if self.active && self.index<=@controls.length
      if Input.trigger?(Input::C)
        if self.index == @controls.length # Default
          @controls = Keys.defaultControls
          @changed = true
          dorefresh = true
        else
          @readingInput = true
        end  
      end
    end
    refresh if dorefresh
  end
end

class PokemonControlsScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Controls"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    gameControls = []
    for control in $PokemonSystem.gameControls
      gameControls.push(control.clone)
    end  
    @sprites["controlwindow"]=Window_PokemonControls.new(gameControls,0,
    @sprites["title"].height,Graphics.width,
    Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["controlwindow"].viewport=@viewport
    @sprites["controlwindow"].visible=true
    @changed = false
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbMain
    pbActivateWindow(@sprites,"controlwindow"){
    loop do
      Graphics.update
      Input.update
      pbUpdate
      exit = false
      if @sprites["controlwindow"].readingInput
        @sprites["textbox"].text=_INTL("Press a new key.")
        @sprites["controlwindow"].setNewInput(Keys.detectKey)
        @sprites["textbox"].text=""
        @changed = true
      else
        if Input.trigger?(Input::B) || (Input.trigger?(Input::C) && 
           @sprites["controlwindow"].index==(
           @sprites["controlwindow"].itemCount-1))
          exit = true  
          if(@sprites["controlwindow"].changed && 
              Kernel.pbConfirmMessage(_INTL("Save changes?")))
            @sprites["textbox"].text = "" # Visual effect
            newControls = @sprites["controlwindow"].controls 
            emptyCommand = false
            for control in newControls
              emptyCommand = true if control.keyCode == 0
            end
            if emptyCommand
              @sprites["textbox"].text=_INTL("Fill all fields!")
              exit = false  
            else
              $PokemonSystem.gameControls = newControls
            end
          end
        end
       end
       break if exit
     end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonControls
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbMain
    @scene.pbEndScene
  end
end

class PokemonSystem
  attr_accessor :gameControls
  def gameControls
    @gameControls = Keys.defaultControls if !@gameControls
    return @gameControls
  end
  
  def getGameControlCodes(controlAction)
    ret = []
    for control in gameControls
      ret.push(control.keyCode) if control.controlAction == controlAction
    end
    return ret
  end  
end