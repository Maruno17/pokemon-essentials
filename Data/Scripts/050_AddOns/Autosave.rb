
AUTOSAVE_ENABLED_SWITCH = 48
AUTOSAVE_HEALING_VAR = 24
AUTOSAVE_CATCH_SWITCH = 782
AUTOSAVE_WIN_SWITCH = 783
AUTOSAVE_STEPS_SWITCH = 784
AUTOSAVE_STEPS_VAR = 236
DEFAULT_AUTOSAVE_STEPS = 500

def pbSetPokemonCenter
  $PokemonGlobal.pokecenterMapId     = $game_map.map_id
  $PokemonGlobal.pokecenterX         = $game_player.x
  $PokemonGlobal.pokecenterY         = $game_player.y
  $PokemonGlobal.pokecenterDirection = $game_player.direction
  if $game_variables[AUTOSAVE_HEALING_VAR]==0
    pbSEPlay("save",100,100)
    Kernel.tryAutosave()
  end
end

def Kernel.Autosave
  #Game.auto_save
  #showSaveIcon()
   pbSave(false)
  # #hideSaveIcon()
end


def Kernel.tryAutosave()
  return if  !$Trainer.save_slot
  Kernel.Autosave if $game_switches[AUTOSAVE_ENABLED_SWITCH]
end

Events.onMapUpdate += proc { |sender, e|
  next if !$game_switches
  next if !$game_switches[AUTOSAVE_STEPS_SWITCH]
  stepsNum = pbGet(AUTOSAVE_STEPS_VAR)
  if stepsNum > 0 && !$PokemonGlobal.sliding
    next if $PokemonGlobal.stepcount < 100
    if $PokemonGlobal.stepcount % stepsNum == 0
      $PokemonGlobal.stepcount += 1
      Kernel.tryAutosave()
    end
  end
}



class AutosaveOptionsScene < PokemonOption_Scene
  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(35, 130, 200)
    @sprites["option"].nameShadowColor = Color.new(20, 75, 115)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
      _INTL("Autosave settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Customize the autosave settings")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("When healing"), [_INTL("On"), _INTL("Off")],
                     proc { $game_variables[AUTOSAVE_HEALING_VAR]},
                     proc { |value|
                       $game_variables[AUTOSAVE_HEALING_VAR]=value
                     },
                     "Autosave when healing at a Pokémon Center"
      ),
      EnumOption.new(_INTL("When catching Pokémon"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[AUTOSAVE_CATCH_SWITCH] ? 0 : 1 },
                     proc { |value|
                       $game_switches[AUTOSAVE_CATCH_SWITCH] = value == 0
                     },
                     "Autosave everytime a new Pokémon is caught"
      ),
      EnumOption.new(_INTL("After trainer battles"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[AUTOSAVE_WIN_SWITCH] ? 0 : 1 },
                     proc { |value|
                       $game_switches[AUTOSAVE_WIN_SWITCH] = value == 0
                     },
                     "Autosave after each trainer battle"
      ),
      EnumOption.new(_INTL("Every x steps"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[AUTOSAVE_STEPS_SWITCH] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[AUTOSAVE_STEPS_SWITCH] && value == 0
                         @set_steps = true
                         selectAutosaveSteps()
                       end
                       $game_switches[AUTOSAVE_STEPS_SWITCH] = value == 0
                     }, "Autosave after a defined amount of steps"
      )
    ]
    return options
  end


  def selectAutosaveSteps()
    if pbGet(AUTOSAVE_STEPS_VAR) == 0
      pbSet(AUTOSAVE_STEPS_VAR,DEFAULT_AUTOSAVE_STEPS)
    end
    params=ChooseNumberParams.new
    params.setRange(20,999999)
    params.setInitialValue(pbGet(AUTOSAVE_STEPS_VAR))
    params.setCancelValue(0)
    val = Kernel.pbMessageChooseNumber(_INTL("Autosave every how many steps?"),params)
    if val < 200
      Kernel.pbMessage("Warning: Choosing a low number of steps may decrease performance.")
    end
    if val == 0
      val = 1
    end
    pbSet(AUTOSAVE_STEPS_VAR,val)
  end

end


