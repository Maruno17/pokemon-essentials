#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 21.99                                #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = "1.0.0"

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other Settings which are used in and out of battle
  # (you can of course change those Settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 9

  # The save slot options available to the player. Is one of:
  #   * :one       = Classic saving. There is only one save file and it is
  #                  replaced upon saving..
  #   * :adventure = Each adventure (i.e. starting a New Game) has its own
  #                  single save slot. Allows the player to have multiple
  #                  adventures saved, but each adventure behaves clasically
  #                  when it comes to saving.
  #   * :multiple  = An infinite number of save slots are always available. The
  #                  player can choose to save in an empty save slot at any
  #                  time, or overwrite an existing save slot.
  SAVE_SLOTS = :multiple

  #-----------------------------------------------------------------------------
  # Credits.
  #-----------------------------------------------------------------------------

  # Your game's credits, in an array. You can allow certain lines to be
  # translated by wrapping them in _INTL() as shown. Blank lines are just "".
  # To split a line into two columns, put "<s>" in it. Plugin credits and
  # Essentials engine credits are added to the end of these credits
  # automatically.
  # Everything in here is just an example! Replace it all with your credits.
  def self.game_credits
    return [
      _INTL("My Game by:"),
      "Maruno",
      "",
      _INTL("Also involved were:"),
      "A. Lee Uss<s>Anne O'Nymus",
      "Ecksam Pell<s>Jane Doe",
      "Joe Dan<s>Nick Nayme",
      "Sue Donnim<s>",
      "",
      _INTL("Special thanks to:"),
      "Pizza"
    ]
  end

  #-----------------------------------------------------------------------------
  # The player and NPCs.
  #-----------------------------------------------------------------------------

  # The maximum amount of money the player can have.
  MAX_MONEY            = 9_999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS            = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS    = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT             = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 12
  # A set of arrays each containing a trainer type followed by a Game Variable
  # number. If the Variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that Variable.
  RIVAL_NAMES = [
    [:RIVAL1,   12],
    [:RIVAL2,   12],
    [:CHAMPION, 12]
  ]

  #-----------------------------------------------------------------------------
  # Overworld.
  #-----------------------------------------------------------------------------

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING               = true
  # Whether the reflections of the player/events will ripple horizontally.
  ANIMATE_REFLECTIONS        = true
  # Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
  # mechanics (false).
  NEW_BERRY_PLANT_MECHANICS  = (MECHANICS_GENERATION >= 4)
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK          = false
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT   = -1
  # The number of steps allowed in a Safari Zone game before it ends (0=infinite).
  SAFARI_STEPS               = 600
  # The number of seconds a Bug-Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME           = 20 * 60   # 20 minutes
  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD            = (MECHANICS_GENERATION <= 4)
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD      = (MECHANICS_GENERATION <= 3)

  #-----------------------------------------------------------------------------
  # Using moves in the overworld.
  #-----------------------------------------------------------------------------
  # Whether you need at least a certain number of Gym Badges to use some hidden
  # moves in the field (true), or whether you need one specific Gym Badge to use
  # them (false). The amounts/specific Gym Badges are defined below.
  FIELD_MOVES_COUNT_BADGES = true
  # Depending on FIELD_MOVES_COUNT_BADGES, either the number of Gym Badges
  # required to use each hidden move in the field, or the specific Gym Badge
  # required to use each move. Remember that Gym Badge 0 is the first Gym Badge,
  # Gym Badge 1 is the second Gym Badge, etc.
  #   e.g. To specifically require the second Gym Badge, put false and 1.
  #        To require at least 2 Gym Badges, put true and 2.
  BADGE_FOR_CUT       = 1
  BADGE_FOR_FLASH     = 2
  BADGE_FOR_ROCKSMASH = 3
  BADGE_FOR_SURF      = 4
  BADGE_FOR_FLY       = 5
  BADGE_FOR_STRENGTH  = 6
  BADGE_FOR_DIVE      = 7
  BADGE_FOR_WATERFALL = 8

  #-----------------------------------------------------------------------------
  # Pokémon.
  #-----------------------------------------------------------------------------

  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL                            = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL                                = 1
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  SHINY_POKEMON_CHANCE                     = (MECHANICS_GENERATION >= 6) ? 16 : 8
  # Whether super shininess is enabled (uses a different shiny animation).
  SUPER_SHINY                              = (MECHANICS_GENERATION == 8)
  # Whether Pokémon with the "Legendary", "Mythical" or "Ultra Beast" flags will
  # have at least 3 perfect IVs.
  LEGENDARIES_HAVE_SOME_PERFECT_IVS        = (MECHANICS_GENERATION >= 6)
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE                           = 3
  # Whether IVs and EVs are treated as 0 when calculating a Pokémon's stats.
  # IVs and EVs still exist, and are used by Hidden Power and some cosmetic
  # things as normal.
  DISABLE_IVS_AND_EVS                      = false
  # Whether the Move Relearner can also teach egg moves that the Pokémon knew
  # when it hatched and moves that the Pokémon was once taught by a TR. Moves
  # from the Pokémon's level-up moveset of the same or a lower level than the
  # Pokémon can always be relearned.
  MOVE_RELEARNER_CAN_TEACH_MORE_MOVES      = (MECHANICS_GENERATION >= 6)
  # Whether the Move Relearner can teach all moves in the Pokémon's moveset
  # (true) or only the moves normally learned at/below the Pokémon's current
  # level (false).
  MOVE_RELEARNER_CAN_TEACH_ANY_LEVEL_MOVES = (MECHANICS_GENERATION == 7)

  #-----------------------------------------------------------------------------
  # Breeding Pokémon and Day Care.
  #-----------------------------------------------------------------------------

  # Whether Pokémon in the Day Care gain Exp for each step the player takes.
  # This should be true for the Day Care and false for the Pokémon Nursery, both
  # of which use the same code in Essentials.
  DAY_CARE_POKEMON_GAIN_EXP_FROM_WALKING     = (MECHANICS_GENERATION <= 6)
  # Whether two Pokémon in the Day Care can learn egg moves from each other if
  # they are the same species.
  DAY_CARE_POKEMON_CAN_SHARE_EGG_MOVES       = (MECHANICS_GENERATION >= 8)
  # Whether a bred baby Pokémon can inherit any TM/TR/HM moves from its father.
  # It can never inherit TM/TR/HM moves from its mother.
  BREEDING_CAN_INHERIT_MACHINE_MOVES         = (MECHANICS_GENERATION <= 5)
  # Whether a bred baby Pokémon can inherit egg moves from its mother. It can
  # always inherit egg moves from its father.
  BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER = (MECHANICS_GENERATION >= 6)

  #-----------------------------------------------------------------------------
  # Roaming Pokémon.
  #-----------------------------------------------------------------------------

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
    5  => [   21, 28, 31, 39, 41, 44, 47, 66, 69],
    21 => [5,     28, 31, 39, 41, 44, 47, 66, 69],
    28 => [5, 21,     31, 39, 41, 44, 47, 66, 69],
    31 => [5, 21, 28,     39, 41, 44, 47, 66, 69],
    39 => [5, 21, 28, 31,     41, 44, 47, 66, 69],
    41 => [5, 21, 28, 31, 39,     44, 47, 66, 69],
    44 => [5, 21, 28, 31, 39, 41,     47, 66, 69],
    47 => [5, 21, 28, 31, 39, 41, 44,     66, 69],
    66 => [5, 21, 28, 31, 39, 41, 44, 47,     69],
    69 => [5, 21, 28, 31, 39, 41, 44, 47, 66    ]
  }
  # A set of hashes, each containing the details of a roaming Pokémon. The
  # information within each hash is as follows:
  #   * :species
  #   * :level
  #   * :icon - Filename in Graphics/UI/Town Map/ of the roamer's Town Map icon.
  #   * :game_switch - The Pokémon roams if this is nil or <=0 or if that Game
  #                    Switch is ON. Optional.
  #   * :encounter_type - One of:
  #       :all     = grass, walking in cave, surfing (default)
  #       :land    = grass, walking in cave
  #       :water   = surfing, fishing
  #       :surfing = surfing
  #       :fishing = fishing
  #   * :bgm - The BGM to play for the encounter. Optional.
  #   * :areas - A hash of map IDs that determine where this Pokémon roams. Used
  #              instead of ROAMING_AREAS above. Optional.
  ROAMING_SPECIES = [
    {
      :species        => :LATIAS,
      :level          => 30,
      :icon           => "pin_latias",
      :game_switch    => 53,
      :encounter_type => :all,
      :bgm            => "Battle roaming"
    },
    {
      :species        => :LATIOS,
      :level          => 30,
      :icon           => "pin_latios",
      :game_switch    => 53,
      :encounter_type => :all,
      :bgm            => "Battle roaming"
    },
    {
      :species        => :KYOGRE,
      :level          => 40,
      :game_switch    => 54,
      :encounter_type => :surfing,
      :areas          => {
        2  => [   21, 31    ],
        21 => [2,     31, 69],
        31 => [2, 21,     69],
        69 => [   21, 31    ]
      }
    },
    {
      :species        => :ENTEI,
      :level          => 40,
      :icon           => "pin_entei",
      :game_switch    => 55,
      :encounter_type => :land
    }
  ]

  #-----------------------------------------------------------------------------
  # Party and Pokémon storage.
  #-----------------------------------------------------------------------------

  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE      = 6
  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES   = 40
  # Whether putting a Pokémon into Pokémon storage will heal it. If false, they
  # are healed by the Recover All: Entire Party event command (at Poké Centers).
  HEAL_STORED_POKEMON = (MECHANICS_GENERATION <= 7)

  #-----------------------------------------------------------------------------
  # Items.
  #-----------------------------------------------------------------------------

  # Whether various HP-healing items heal the amounts they do in Gen 7+ (true)
  # or in earlier Generations (false).
  REBALANCED_HEALING_ITEM_AMOUNTS      = (MECHANICS_GENERATION >= 7)
  # Whether vitamins can add EVs no matter how many that stat already has in it
  # (true), or whether they can't make that stat's EVs greater than 100 (false).
  NO_VITAMIN_EV_CAP                    = (MECHANICS_GENERATION >= 8)
  # Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
  RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS = (MECHANICS_GENERATION >= 7)
  # Whether the Black/White Flutes will raise/lower the levels of wild Pokémon
  # respectively (true), or will lower/raise the wild encounter rate
  # respectively (false).
  FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS  = (MECHANICS_GENERATION >= 6)
  # Whether Rare Candy can be used on a Pokémon that is already at its maximum
  # level if it is able to evolve by level-up (if so, triggers that evolution).
  RARE_CANDY_USABLE_AT_MAX_LEVEL       = (MECHANICS_GENERATION >= 8)
  # Whether the player can choose how many of an item to use at once on a
  # Pokémon. This applies to Exp-changing items (Rare Candy, Exp Candies) and
  # EV-changing items (vitamins, feathers, EV-lowering berries).
  USE_MULTIPLE_STAT_ITEMS_AT_ONCE      = (MECHANICS_GENERATION >= 8)
  # If a move taught by a TM/HM/TR replaces another move, this Setting is
  # whether the machine's move retains the replaced move's PP (true), or whether
  # the machine's move has full PP (false).
  TAUGHT_MACHINES_KEEP_OLD_PP          = (MECHANICS_GENERATION == 5)
  # Whether you get 1 Premier Ball for every 10 of any kind of Poké Ball bought
  # from a Mart at once (true), or 1 Premier Ball for buying 10+ regular Poké
  # Balls (false).
  MORE_BONUS_PREMIER_BALLS             = (MECHANICS_GENERATION >= 8)
  # The default sell price of an item to a Poké Mart is its buy price divided by
  # this number.
  ITEM_SELL_PRICE_DIVISOR              = (MECHANICS_GENERATION >= 9) ? 4 : 2

  #-----------------------------------------------------------------------------
  # Pokédex.
  #-----------------------------------------------------------------------------

  # The names of the Regional Pokédex lists, in the order they are defined in
  # the PBS file "regional_dexes.txt". The National Dex is (and must be) added
  # to the end of this array of names.
  # Each entry is either just a name, or is an array containing a name and a
  # number. If there is a number, it is a region number as defined in
  # town_map.txt. If there is no number, the number of the region the player is
  # currently in will be used. The region number determines which Town Map is
  # shown in the Area page when viewing that Pokédex list.
  def self.pokedex_names
    return [
      [_INTL("Kanto Pokédex"), 0],
      [_INTL("Johto Pokédex"), 1],
      _INTL("National Pokédex")
    ]
  end
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  # will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
  DEXES_WITH_OFFSETS                        = []
  # Whether the Pokédex entry of a newly owned species will be shown after it
  # hatches from an egg, after it evolves and after obtaining it from a trade,
  # in addition to after catching it in battle.
  SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN = (MECHANICS_GENERATION >= 7)

  #-----------------------------------------------------------------------------
  # Phone contact rematches.
  #-----------------------------------------------------------------------------

  # The default value of Phone.rematches_enabled, which determines whether
  # trainers registered in the Phone can become ready for a rematch. If false,
  # Phone.rematches_enabled = true will enable rematches at any point you want.
  PHONE_REMATCHES_POSSIBLE_FROM_BEGINNING = false

  #-----------------------------------------------------------------------------
  # Battle starting.
  #-----------------------------------------------------------------------------

  # Whether Repel uses the level of the first Pokémon in the party regardless of
  # its HP (true), or it uses the level of the first unfainted Pokémon (false).
  REPEL_COUNTS_FAINTED_POKEMON             = (MECHANICS_GENERATION >= 6)
  # Whether more abilities affect whether wild Pokémon appear, which Pokémon
  # they are, etc.
  MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS    = (MECHANICS_GENERATION >= 8)
  # Whether shiny wild Pokémon are more likely to appear if the player has
  # previously defeated/caught lots of other Pokémon of the same species.
  HIGHER_SHINY_CHANCES_WITH_NUMBER_BATTLED = (MECHANICS_GENERATION == 8)
  # Whether overworld weather can set the default terrain effect in battle.
  # Storm weather sets Electric Terrain, and fog weather sets Misty Terrain.
  OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN    = (MECHANICS_GENERATION >= 8)

  #-----------------------------------------------------------------------------
  # Game Switches.
  #-----------------------------------------------------------------------------

  # The Game Switch that is set to ON when the player blacks out.
  STARTING_OVER_SWITCH      = 1
  # The Game Switch that is set to ON when the player has seen Pokérus in the
  # Poké Center (and doesn't need to be told about it again).
  SEEN_POKERUS_SWITCH       = 2
  # The Game Switch which, while ON, makes all wild Pokémon created be shiny.
  SHINY_WILD_POKEMON_SWITCH = 31
  # The Game Switch which, while ON, makes all Pokémon created considered to be
  # met via a fateful encounter.
  FATEFUL_ENCOUNTER_SWITCH  = 32
  # The Game Switch which, while ON, disables the effect of the Pokémon Box Link
  # and prevents the player from accessing Pokémon storage via the party screen
  # with it.
  DISABLE_BOX_LINK_SWITCH   = 35

  #-----------------------------------------------------------------------------
  # Overworld animation IDs.
  #-----------------------------------------------------------------------------

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID           = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID            = 2
  # ID of the animation played when the player finishes taking a step onto still
  # water (shows a water ripple).
  WATER_RIPPLE_ANIMATION_ID    = 8
  # ID of the animation played when a trainer notices the player (an exclamation
  # bubble).
  EXCLAMATION_ANIMATION_ID     = 3
  # ID of the animation played when a patch of grass rustles due to using the
  # Poké Radar.
  RUSTLE_NORMAL_ANIMATION_ID   = 1
  # ID of the animation played when a patch of grass rustles vigorously due to
  # using the Poké Radar. (Rarer species)
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  # ID of the animation played when a patch of grass rustles and shines due to
  # using the Poké Radar. (Shiny encounter)
  RUSTLE_SHINY_ANIMATION_ID    = 6
  # ID of the animation played when a berry tree grows a stage while the player
  # is on the map (for new plant growth mechanics only).
  PLANT_SPARKLE_ANIMATION_ID   = 7

  #-----------------------------------------------------------------------------
  # Files.
  #-----------------------------------------------------------------------------

  DEFAULT_WILD_BATTLE_BGM     = "Battle wild"
  DEFAULT_WILD_VICTORY_BGM    = "Battle victory"
  DEFAULT_WILD_CAPTURE_ME     = "Battle capture success"
  DEFAULT_TRAINER_BATTLE_BGM  = "Battle trainer"
  DEFAULT_TRAINER_VICTORY_BGM = "Battle victory"

  #-----------------------------------------------------------------------------
  # Languages.
  #-----------------------------------------------------------------------------

  # An array of available languages in the game. Each one is an array containing
  # the display name of the language in-game, and that language's filename
  # fragment. A language will use the language data files from the Data folder
  # called messages_FRAGMENT_core.dat and messages_FRAGMENT_game.dat (if they
  # exist).
  # NOTE: Some messages or parts of code are different depending on the selected
  #       language. These things depend on the display name of the language as
  #       defined here. See:
  #       - def self.more_possessive_messages?
  #       - def self.whitespace_separates_words?
  LANGUAGES = [
#    ["English", "english"],
#    ["Français", "francais"],
#    ["Deutsch", "deutsch"],
#    ["中文", "chinese"],
#    ["日本語", "japanese"],
#    ["한국어", "korean"]
  ]

  #-----------------------------------------------------------------------------
  # Screen size and zoom.
  #-----------------------------------------------------------------------------

  # The default screen width (at a scale of 1.0). You should also edit the
  # property "defScreenW" in mkxp.json to match.
  SCREEN_WIDTH  = 512
  # The default screen height (at a scale of 1.0). You should also edit the
  # property "defScreenH" in mkxp.json to match.
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE  = 1.0

  #-----------------------------------------------------------------------------
  # Debug helpers.
  #-----------------------------------------------------------------------------

  # Whether the game will ask you if you want to fully compile every time you
  # start the game (in Debug mode). You will not need to hold Ctrl/Shift to
  # compile anything.
  PROMPT_TO_COMPILE    = false
  # Whether the game will skip the intro splash screens and title screen, and go
  # straight to the Continue/New Game screen. Only applies to playing in Debug
  # mode.
  SKIP_TITLE_SCREEN    = true
  # Whether the game will skip the Continue/New Game screen and go straight into
  # a saved game (if there is one) or start a new game (if there isn't). Only
  # applies to playing in Debug mode.
  SKIP_CONTINUE_SCREEN = false
end

#===============================================================================
# DO NOT EDIT THESE!
#===============================================================================
module Essentials
  VERSION = "21.99"
  ERROR_TEXT = ""
  MKXPZ_VERSION = "2.4.2/d13f35c"
end
