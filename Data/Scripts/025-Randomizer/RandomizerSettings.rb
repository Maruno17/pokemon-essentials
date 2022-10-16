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
      _INTL("Randomizer settings"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = getDefaultDescription
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Pokémon"), [_INTL("On"), _INTL("Off")],
                     proc {
                       $game_switches[SWITCH_RANDOM_WILD] ? 0 : 1
                     },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_WILD] && value == 0
                         @openWildOptions = true
                         openWildPokemonOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_WILD] = value == 0
                     }, "Select the randomizer options for Pokémon"
      ),
      EnumOption.new(_INTL("NPC Trainers"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_TRAINERS] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_TRAINERS] && value == 0
                         @openTrainerOptions = true
                         openTrainerOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_TRAINERS] = value == 0
                     }, "Select the randomizer options for trainers"
      ),

      EnumOption.new(_INTL("Gym trainers"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] && value == 0
                         @openGymOptions = true
                         openGymOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] = value == 0
                     }, "Limit gym trainers to a single type"
      ),

      EnumOption.new(_INTL("Items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_ITEMS_GENERAL] && value == 0
                         @openItemOptions = true
                         openItemOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] = value == 0
                     }, "Select the randomizer options for items"
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

  def openItemOptionsMenu()
    return if !@openItemOptions
    pbFadeOutIn {
      scene = RandomizerItemOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openItemOptions = false
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
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Randomizer settings: Trainers"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Set the randomizer settings for trainers")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Randomness degree"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_TRAINER_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_TRAINER_BST] = value
                                  })
    end
    options << EnumOption.new(_INTL("Custom Sprites only"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] = value == 0
                              },
                              "Use only Pokémon that have custom sprites in trainer teams"
    )

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
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Randomizer settings: Pokémon"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Set the randomizer settings for wild Pokémon")
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Randomness degree"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] = value
                                  })
    end

    options << EnumOption.new(_INTL("Type"), [_INTL("Global"), _INTL("Area")],
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
                              },
                              [
                                "Randomizes Pokémon using a one-to-one mapping of the Pokedex",
                                "Randomizes the encounters in each route individually"
                              ]
    )
    options << EnumOption.new(_INTL("Custom sprites only"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] = value == 0
                              }, "['Fuse everything' & starters] Include only  Pokémon with a custom sprite."
    )

    options << EnumOption.new(_INTL("Starters"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_STARTERS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_STARTERS] = value == 0
                              }, "Randomize the selection of starters to choose from at the start of the game"
    )
    options << EnumOption.new(_INTL("Static encounters"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_STATIC] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_STATIC] = value == 0
                              },
                              "Randomize Pokémon that appear in the overworld (including legendaries)"
    )

    options << EnumOption.new(_INTL("Gift Pokémon"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[GIFT_POKEMON] ? 0 : 1 },
                              proc { |value|
                                $game_switches[GIFT_POKEMON] = value == 0
                              }, "Randomize Pokémon that are gifted to the player"
    )

    options << EnumOption.new(_INTL("Fuse everything"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[REGULAR_TO_FUSIONS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[REGULAR_TO_FUSIONS] = value == 0
                              }, "Include fused Pokémon in the randomize pool for wild Pokémon"
    )
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
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Randomizer settings: Gyms"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Set the randomizer settings for gyms")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Randomness degree"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_TRAINER_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_TRAINER_BST] = value
                                  })
    end
    options << EnumOption.new(_INTL("Custom sprites only"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] = value == 0
                              }, "Use only Pokémon that have custom sprites in gym trainers or gym leader teams"
    )
    options << EnumOption.new(_INTL("Gym types"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_GYM_TYPES] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_GYM_TYPES] = value == 0
                              }, "Shuffle the gym types"
    )
    options << EnumOption.new(_INTL("Rerandomize each battle"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = value == 0
                                $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] = !$game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE]
                              }, "Gym trainers and leaders have a new team each try instead of keeping the same one"
    )

    return options
  end
end

class RandomizerItemOptionsScene < PokemonOption_Scene
  RANDOM_HELD_ITEMS = 843

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
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Randomizer settings: Items"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Set the randomizer settings for items")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Type"), [_INTL("Mapped"), _INTL("Dynamic")],
                     proc {
                       if $game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC]
                         1
                       else
                         0
                       end
                     },
                     proc { |value|
                       if value == 0
                         $game_switches[SWITCH_RANDOM_ITEMS_MAPPED] = true
                         $game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC] = false
                       else
                         value == 1
                         $game_switches[SWITCH_RANDOM_ITEMS_MAPPED] = false
                         $game_switches[SWITCH_RANDOM_ITEMS_DYNAMIC] = true
                       end
                     },
                     [
                       "Random items are decided at the start of the game",
                       "Random items are decided as you obtain them"],
      # proc { $game_switches[SWITCH_RANDOM_ITEMS_FULL] ? 0 : 1 },
      # proc { |value|
      #   $game_switches[SWITCH_RANDOM_ITEMS_MAPPED] = value == 0
      #   $game_switches[SWITCH_RANDOM_ITEMS_FULL] = value == 1
      # }, ["Random items are decided at the start of the game", "Random items are decided as you obtain them"]
      ),
      EnumOption.new(_INTL("Found items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomize the items picked up on the ground"
      ),
      EnumOption.new(_INTL("Found TMs"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomize the TMs picked up on the ground"
      ),
      EnumOption.new(_INTL("Given items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomize the items given by NPCs (may make some quests impossible to complete)"
      ),
      EnumOption.new(_INTL("Given TMs"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomize the TMs given by NPCs"
      ),

      EnumOption.new(_INTL("Shop items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_SHOP_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_SHOP_ITEMS] = value == 0
                     }, "Randomizes the items available in shops (always mapped)"
      ),

      EnumOption.new(_INTL("Trainer Held items"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[RANDOM_HELD_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[RANDOM_HELD_ITEMS] = value == 0
                     }, "Give random held items to all trainers"
      )
    ]
    return options
  end
end