module OptionTypes
  WILD_POKE = 0
  TRAINER_POKE = 1
end

class RandomizerOptionsScene < PokemonOption_Scene
  def initialize
    super
    @openTrainerOptions = false
    @openWildOptions = false
    @openGymOptions = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @changedColor = true
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
        _INTL("Randomizer settings"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Set the randomizer settings")
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
        EnumOption.new(_INTL("Starters"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOM_STARTERS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[SWITCH_RANDOM_STARTERS] = value == 0
                       }
        ),

        EnumOption.new(_INTL("Trainers"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOM_TRAINERS] ? 0 : 1 },
                       proc { |value|
                         if !$game_switches[SWITCH_RANDOM_TRAINERS] && value == 0
                           @openTrainerOptions = true
                           openTrainerOptionsMenu()
                         end
                         $game_switches[SWITCH_RANDOM_TRAINERS] = value == 0
                       }
        ),

        EnumOption.new(_INTL("Gym trainers"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] ? 0 : 1 },
                       proc { |value|
                         if !$game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] && value == 0
                           @openGymOptions = true
                           openGymOptionsMenu()
                         end
                         $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] = value == 0
                       }
        ),

        EnumOption.new(_INTL("Wild Pokémon"), [_INTL("On"), _INTL("Off")],
                       proc {
                         $game_switches[SWITCH_RANDOM_WILD] ? 0 : 1
                       },
                       proc { |value|
                         if !$game_switches[SWITCH_RANDOM_WILD] && value == 0
                           @openWildOptions = true
                           openWildPokemonOptionsMenu()
                         end
                         $game_switches[SWITCH_RANDOM_WILD] = value == 0
                       }
        ),
        EnumOption.new(_INTL("Items"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOM_ITEMS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[SWITCH_RANDOM_ITEMS] = value == 0
                       }
        ),
        EnumOption.new(_INTL("TMs"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOM_TMS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[SWITCH_RANDOM_TMS] = value == 0
                       }
        ),
    ]
    return options
  end

  def openGymOptionsMenu()
    return if !@openGymOptions
    pbFadeOutIn {
      scene = RandomizerGymOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openGymOptions = false
  end

  def openTrainerOptionsMenu()
    return if !@openTrainerOptions
    pbFadeOutIn {
      scene = RandomizerTrainerOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openTrainerOptions = false
  end

  def openWildPokemonOptionsMenu()
    return if !@openWildOptions
    pbFadeOutIn {
      scene = RandomizerWildPokemonOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openWildOptions = false
  end


end


class RandomizerTrainerOptionsScene < PokemonOption_Scene
  RANDOM_TEAMS_CUSTOM_SPRITES = 600
  RANDOM_HELD_ITEMS = 843
  RANDOM_GYM_TYPES = 921

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
        _INTL("Randomizer settings: Trainers"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Set the randomizer settings for trainers")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
        EnumOption.new(_INTL("Custom Sprites only"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] ? 0 : 1 },
                       proc { |value|
                         $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] = value == 0
                       }
        ),
        EnumOption.new(_INTL("Trainer Held items"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[RANDOM_HELD_ITEMS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[RANDOM_HELD_ITEMS] = value == 0
                       }
        )
    ]
    return options
  end
end


class RandomizerWildPokemonOptionsScene < PokemonOption_Scene
  RANDOM_WILD_AREA = 777
  RANDOM_WILD_GLOBAL = 956
  RANDOM_STATIC = 955
  REGULAR_TO_FUSIONS = 953
  GIFT_POKEMON = 780

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(70, 170, 40)
    @sprites["option"].nameShadowColor = Color.new(40, 100, 20)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
        _INTL("Randomizer settings: Wild Pokémon"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Set the randomizer settings for wild Pokémon")
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
        EnumOption.new(_INTL("Type"), [_INTL("Global")],#, _INTL("Area")],
                       proc {
                         if $game_switches[RANDOM_WILD_AREA]
                           1
                         else
                           0
                         end
                       },
                       proc { |value|
                         if value == 0
                           $game_switches[RANDOM_WILD_GLOBAL] = true
                           $game_switches[RANDOM_WILD_AREA] = false
                         else
                           value == 1
                           $game_switches[RANDOM_WILD_GLOBAL] = false
                           $game_switches[RANDOM_WILD_AREA] = true
                         end
                       }
        ),
        # EnumOption.new(_INTL("Static encounters"), [_INTL("On"), _INTL("Off")],
        #                proc { $game_switches[RANDOM_STATIC] ? 0 : 1 },
        #                proc { |value|
        #                  $game_switches[RANDOM_STATIC] = value == 0
        #                }
        # ),
        
        EnumOption.new(_INTL("Gift Pokémon"), [_INTL("On"), _INTL("Off")],
               proc { $game_switches[GIFT_POKEMON] ? 0 : 1 },
               proc { |value|
                 $game_switches[GIFT_POKEMON] = value == 0
               }
        ),
        
        EnumOption.new(_INTL("Fuse everything"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[REGULAR_TO_FUSIONS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[REGULAR_TO_FUSIONS] = value == 0
                       }
        ),
        EnumOption.new(_INTL("Custom sprites only"), [_INTL("On"), _INTL("Off")],
                       proc { $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] ? 0 : 1 },
                       proc { |value|
                         $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] = value == 0
                       }
        )
    ]
    return options
  end
end


class RandomizerGymOptionsScene < PokemonOption_Scene
  RANDOM_GYM_TYPES = 921

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
      _INTL("Randomizer settings: Gyms"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"].text=_INTL("Set the randomizer settings for gyms")


    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Gym types"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[RANDOM_GYM_TYPES] ? 0 : 1 },
                     proc { |value|
                       $game_switches[RANDOM_GYM_TYPES] = value == 0
                     }
      ),
      EnumOption.new(_INTL("Rerandomize each battle"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = value == 0
                       $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] = !$game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE]
                     }
      ),
      EnumOption.new(_INTL("Custom sprites only (Slower)"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] = value == 0
                     }
      )
    ]
    return options
  end
end