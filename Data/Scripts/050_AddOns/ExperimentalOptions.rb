
module OptionTypes
  WILD_POKE = 0
  TRAINER_POKE = 1
end

class ExperimentalOptionsScene < PokemonOption_Scene
  def initialize
    super
    @openTrainerOptions = false
    @openWildOptions = false
    @openGymOptions = false
    @openItemOptions = false
    $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true
  end

  def getDefaultDescription
    return _INTL("Set the randomizer settings")
  end

  def pbStartScene(inloadscreen = false)
    super
    @changedColor = true
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Experimental options"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = getDefaultDescription
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Base stats mode"), [_INTL("On"), _INTL("Off")],
                     proc {
                       $game_switches[SWITCH_NO_LEVELS_MODE] ? 0 : 1
                     },
                     proc { |value|
                       $game_switches[SWITCH_NO_LEVELS_MODE] = value == 0
                     }, "All Pokémon use their base stats, regardless of levels."
      )
    ]
    return options
  end


end
