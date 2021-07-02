
AUTOSAVE_ENABLED_SWITCH = 48
AUTOSAVE_HEALING_VAR = 24
AUTOSAVE_CATCH_SWITCH = 782
AUTOSAVE_WIN_SWITCH = 783
AUTOSAVE_STEPS_SWITCH = 784
AUTOSAVE_STEPS_VAR = 236

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
  pbSave(false)
end


def Kernel.tryAutosave()
  Kernel.Autosave if $game_switches[AUTOSAVE_ENABLED_SWITCH]
end

if AUTOSAVE_STEPS_SWITCH
  Events.onMapUpdate+=proc {|sender,e|
    stepsNum = pbGet(AUTOSAVE_STEPS_VAR)
    if stepsNum > 0 && !$PokemonGlobal.sliding
      return if $PokemonGlobal.stepcount < 100
      if $PokemonGlobal.stepcount % stepsNum == 0
        Kernel.tryAutosave()
      end
    end
  }
end