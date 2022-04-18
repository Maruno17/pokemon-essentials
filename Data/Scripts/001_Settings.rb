#==============================================================================#
#                              Pokémon Essentials                              #
#                               Version 19.1.dev                               #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#
module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = '5.0.0'
  GAME_VERSION_NUMBER = "5.0.19 - beta"

  POKERADAR_LIGHT_ANIMATION_RED_ID = 17
  POKERADAR_LIGHT_ANIMATION_GREEN_ID = 18
  POKERADAR_HIDDEN_ABILITY_POKE_CHANCE = 32
  POKERADAR_BATTERY_STEPS = 0

  #
  FUSION_ICON_SPRITE_OFFSET = 10

  #Infinite fusion settings
  NB_POKEMON = 420
  CUSTOM_BATTLERS_FOLDER = "Graphics/CustomBattlers/"
  BATTLERS_FOLDER = "Graphics/Battlers/"
  FRONTSPRITE_POSITION_OFFSET = 15
  FRONTSPRITE_SCALE = 0.6666666
  BACKRPSPRITE_SCALE = 1

  BACKSPRITE_POSITION_OFFSET = 20

  RIVAL_STARTER_PLACEHOLDER_SPECIES = :MEW #(MEW)
  VAR_1_PLACEHOLDER_SPECIES = :DIALGA
  VAR_2_PLACEHOLDER_SPECIES = :PALKIA
  VAR_3_PLACEHOLDER_SPECIES = :GIRATINA

  RIVAL_STARTER_PLACEHOLDER_VARIABLE = 250

  OVERRIDE_BATTLE_LEVEL_SWITCH = 785
  OVERRIDE_BATTLE_LEVEL_VALUE_VAR = 240
  HARD_MODE_LEVEL_MODIFIER = 1.1

  ZAPMOLCUNO_NB = 176821

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other settings which are used in and out of battle
  # (you can of course change those settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 5

  #=============================================================================

  # The default screen width (at a scale of 1.0).
  SCREEN_WIDTH = 512
  # The default screen height (at a scale of 1.0).
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE = 1.0

  #=============================================================================

  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL = 1
  # Number of badges in the game
  NB_BADGES = 16
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  SHINY_POKEMON_CHANCE = (MECHANICS_GENERATION >= 6) ? 16 : 8
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE = 3
  # Whether a bred baby Pokémon can inherit any TM/HM moves from its father. It
  # can never inherit TM/HM moves from its mother.
  BREEDING_CAN_INHERIT_MACHINE_MOVES = (MECHANICS_GENERATION <= 5)
  # Whether a bred baby Pokémon can inherit egg moves from its mother. It can
  # always inherit egg moves from its father.
  BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER = (MECHANICS_GENERATION >= 6)

  #=============================================================================

  # The amount of money the player starts the game with.
  INITIAL_MONEY = 3000
  # The maximum amount of money the player can have.
  MAX_MONEY = 999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 10
  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE = 6

  #=============================================================================

  # A set of arrays each containing a trainer type followed by a Global Variable
  # number. If the variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that variable.
  RIVAL_NAMES = [
    [:RIVAL1, 12],
    [:RIVAL2, 12],
    [:CHAMPION, 12]
  ]

  #=============================================================================

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING = true

  #=============================================================================

  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD = true #(MECHANICS_GENERATION <= 4)
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD = (MECHANICS_GENERATION >= 3)
  # Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
  # mechanics (false).
  NEW_BERRY_PLANTS = (MECHANICS_GENERATION >= 4)
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK = false
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT = -1

  #=============================================================================

  # The number of steps allowed before a Safari Zone game is over (0=infinite).
  SAFARI_STEPS = 600
  # The number of seconds a Bug Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME = 20 * 60 # 20 minutes

  #=============================================================================

  # Pairs of map IDs, where the location signpost isn't shown when moving from
  # one of the maps in a pair to the other (and vice versa). Useful for single
  # long routes/towns that are spread over multiple maps.
  #   e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
  # Moving between two maps that have the exact same name won't show the
  # location signpost anyway, so you don't need to list those maps here.
  NO_SIGNPOSTS = []

  #=============================================================================

  # Whether you need at least a certain number of badges to use some hidden
  # moves in the field (true), or whether you need one specific badge to use
  # them (false). The amounts/specific badges are defined below.
  FIELD_MOVES_COUNT_BADGES = true
  # Depending on FIELD_MOVES_COUNT_BADGES, either the number of badges required
  # to use each hidden move in the field, or the specific badge number required
  # to use each move. Remember that badge 0 is the first badge, badge 1 is the
  # second badge, etc.
  #   e.g. To require the second badge, put false and 1.
  #        To require at least 2 badges, put true and 2.
  BADGE_FOR_CUT = 1
  BADGE_FOR_FLASH = 2
  BADGE_FOR_ROCKSMASH = 0
  BADGE_FOR_SURF = 5
  BADGE_FOR_FLY = 3
  BADGE_FOR_STRENGTH = 5
  BADGE_FOR_DIVE = 9
  BADGE_FOR_WATERFALL = 8
  BADGE_FOR_TELEPORT = 3
  BADGE_FOR_BOUNCE = 8
  BADGE_FOR_ROCKCLIMB = 16
  #=============================================================================

  # If a move taught by a TM/HM/TR replaces another move, this setting is
  # whether the machine's move retains the replaced move's PP (true), or whether
  # the machine's move has full PP (false).
  TAUGHT_MACHINES_KEEP_OLD_PP = (MECHANICS_GENERATION == 5)
  # Whether the Black/White Flutes will raise/lower the levels of wild Pokémon
  # respectively (true), or will lower/raise the wild encounter rate
  # respectively (false).
  FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS = (MECHANICS_GENERATION >= 6)
  # Whether Repel uses the level of the first Pokémon in the party regardless of
  # its HP (true), or it uses the level of the first unfainted Pokémon (false).
  REPEL_COUNTS_FAINTED_POKEMON = (MECHANICS_GENERATION >= 6)
  # Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
  RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS = (MECHANICS_GENERATION >= 7)

  #=============================================================================

  # The name of the person who created the Pokémon storage system.
  def self.storage_creator_name
    return _INTL("Bill")
  end

  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES = 30

  #=============================================================================

  # The names of each pocket of the Bag. Ignore the first entry ("").
  def self.bag_pocket_names
    return ["",
            _INTL("Items"),
            _INTL("Medicine"),
            _INTL("Poké Balls"),
            _INTL("TMs & HMs"),
            _INTL("Berries"),
            _INTL("Mail"),
            _INTL("Battle Items"),
            _INTL("Key Items")
    ]
  end

  # The maximum number of slots per pocket (-1 means infinite number). Ignore
  # the first number (0).
  BAG_MAX_POCKET_SIZE = [0, -1, -1, -1, -1, -1, -1, -1, -1]
  # The maximum number of items each slot in the Bag can hold.
  BAG_MAX_PER_SLOT = 999
  # Whether each pocket in turn auto-sorts itself by item ID number. Ignore the
  # first entry (the 0).
  BAG_POCKET_AUTO_SORT = [0, false, false, false, true, true, false, false, false]

  #=============================================================================

  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = false
  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regionaldexes.txt". The last name is for the National Dex and is added
  # onto the end of this array (remember that you don't need to use it). This
  # array's order is also the order of $Trainer.pokedex.unlocked_dexes, which
  # records which Dexes have been unlocked (the first is unlocked by default).
  # If an entry is just a name, then the region map shown in the Area page while
  # viewing that Dex list will be the region map of the region the player is
  # currently in. The National Dex entry should always behave like this.
  # If an entry is of the form [name, number], then the number is a region
  # number. That region's map will appear in the Area page while viewing that
  # Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      # [_INTL("Kanto Pokédex"), 0]
    ]
  end

  # Whether all forms of a given species will be immediately available to view
  # in the Pokédex so long as that species has been seen at all (true), or
  # whether each form needs to be seen specifically before that form appears in
  # the Pokédex (false).
  DEX_SHOWS_ALL_FORMS = false
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  # will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
  DEXES_WITH_OFFSETS = []

  #=============================================================================

  # A set of arrays, each containing details of a graphic to be shown on the
  # region map if appropriate. The values for each array are as follows:
  #   * Region number.
  #   * Game Switch; the graphic is shown if this is ON (non-wall maps only).
  #   * X coordinate of the graphic on the map, in squares.
  #   * Y coordinate of the graphic on the map, in squares.
  #   * Name of the graphic, found in the Graphics/Pictures folder.
  #   * The graphic will always (true) or never (false) be shown on a wall map.
  REGION_MAP_EXTRAS = [
    [0, 51, 16, 15, "mapHiddenBerth", false],
    [0, 52, 20, 14, "mapHiddenFaraday", false]
  ]

  #=============================================================================

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
    262  => [261,311],
    311 => [262,312],
    312 => [311],
    261 => [262,288,267],
    288 => [261,267,285],
    267 => [261,288,300,254],
    284 => [288,266,285],
    300 => [267,254],
    254 => [300,265],
    266 => [284,265],
    265 => [266,254],
    285 => [284,288]}

  SEVII_ROAMING = {
    528  => [526],         #Treasure beach
    526 => [528,559],          #Knot Island
    559 => [526,561,564],      #Kindle Road
    561 => [559],              #Mt. Ember
    564 => [559,562,563,594],  #brine road
    562 => [564],              #boon island
    563 => [564,600] ,         #kin island
    594 => [564,566,603],      #water labyrinth
    600 => [563,619],          #bond bridge
    619 => [600] ,             #Berry forest
    566 => [594,603],          #Resort gorgeous
    603 => [566,594],          #Chrono Island
  }
  # A set of arrays, each containing the details of a roaming Pokémon. The
  # information within each array is as follows:
  #   * Species.
  #   * Level.
  #   * Game Switch; the Pokémon roams while this is ON.
  #   * Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
  #     4=surfing/fishing). See the bottom of PField_RoamingPokemon for lists.
  #   * Name of BGM to play for that encounter (optional).
  #   * Roaming areas specifically for this Pokémon (optional).
  ROAMING_SPECIES = [
    [:ENTEI, 50, 350, 1, "Legendary Birds"],
    [:B245H243, 50, 341, 1, "Legendary Birds"],
    [:LATIOS, 50, 602, 0, "Legendary Birds",SEVII_ROAMING],
    [:LATIAS, 50, 602, 0, "Legendary Birds",SEVII_ROAMING],
    [:FEEBAS, 15, 4, 3, "Pokemon HeartGold and SoulSilver - Wild Pokemon Battle (Kanto)",SEVII_ROAMING]
  ]

  #=============================================================================

  # A set of arrays, each containing the details of a wild encounter that can
  # only occur via using the Poké Radar. The information within each array is as
  # follows:
  #   * Map ID on which this encounter can occur.
  #   * Probability that this encounter will occur (as a percentage).
  #   * Species.
  #   * Minimum possible level.
  #   * Maximum possible level (optional).
  POKE_RADAR_ENCOUNTERS = [
    [78, 30,  :FLETCHLING,2,5],         #Rt. 1
    [86, 30,  :FLETCHLING,2,5],         #Rt. 2
    [90, 30,  :FLETCHLING,2,5],      #Rt. 2
    [491, 30, :SHROOMISH,2,5],          #Viridian Forest
    [490, 30, :BUDEW,4,9],              #Rt. 3
    [106, 30, :NINCADA,8,10],           #Rt. 4
    [12, 30,  :TOGEPI,10,10],           #Rt. 5
    [16, 30,  :SLAKOTH,12,15],          #Rt. 6
    [413, 30, :DRIFLOON,17,20],         #Rt. 7
    [409, 30, :SHINX,17,18],            #Rt. 8
    [495, 30, :ARON,12,15],             #Rt. 9
    [351, 30, :ARON,12,15],             #Rt. 9
    [154, 30, :KLINK,14,17],            #Rt. 10
    [155, 30, :NINCADA,12,15],          #Rt. 11
    [159, 30, :COTTONEE,22,25],         #Rt. 12
    [437, 30, :COTTONEE,22,25],         #Rt. 13
    [437, 30, :JOLTIK,22,25],           #Rt. 13
    [440, 30, :JOLTIK,22,25],           #Rt. 14
    [444, 30, :SOLOSIS,22,25],          #Rt. 15
    [438, 30, :NATU,22,25],             #Rt. 16
    [146, 30, :KLEFKI,22,25],           #Rt. 17
    [517, 30, :FERROSEED,22,25],        #Rt. 18
    [445, 30, :BAGON,20,20],            #Safari zone 1
    [484, 30, :AXEW,20,20],             #Safari zone 2
    [485, 30, :DEINO,20,20],            #Safari zone 3
    [486, 30, :LARVITAR,20,20],         #Safari zone 4
    [487, 30, :BELDUM,20,20],           #Safari zone 5
    [59, 30,  :DUNSPARSE,25,30],        #Rt. 21
    [171, 30, :BIDOOF,2,5],             #Rt. 22
    [143, 30, :RIOLU,25,25],            #Rt. 23
    [8, 30,   :BUNEARY,12,13],          #Rt. 24
    [145, 30, :ABSOL,30,35],             #Rt. 26
    [147, 30, :ABSOL,30,35],             #Rt. 27
    [311, 30, :BIDOOF,5,5],             #Rt. 29
    [284, 30, :LUXIO,40,45],             #Rt. 33
    [288, 30, :VIGOROTH,40,45],             #Rt. 32
    [342, 30, :GOLETT,40,45],             #Ruins of Alph
    [261, 30, :BELLOSSOM,45,50],             #Rt. 31
    [261, 30, :BIBAREL,45,50],             #Rt. 30
    [265, 30, :KIRLIA,25,30],           #Rt. 34
    [267, 30, :SUDOWOODO,25,30],           #Rt. 36
    [300, 30, :ROSELIA,30,30],          #National Park
    [300, 30, :BRELOOM,30,30],          #Ilex Forest
    [670, 30, :WEAVILE,50,50],          #Ice mountains
    [528, 30, :PYUKUMUKU,20,20],        #Treasure Beach
    [690, 30, :OCTILLERY,32,45],        #Deep Ocean
    [561, 30, :MAGMAR,32,45],           #Mt. Ember
    [562, 30, :NINJASK,45,50],           #Boon Island
    [603, 30, :KECLEON,45,50],           #Chrono Island
    [654, 30, :WHIMSICOTT,32,45]       #Brine Road
  ]

  #=============================================================================

  # The Game Switch that is set to ON when the player blacks out.
  STARTING_OVER_SWITCH = 1
  # The Game Switch that is set to ON when the player has seen Pokérus in the
  # Poké Center (and doesn't need to be told about it again).
  SEEN_POKERUS_SWITCH = 2
  # The Game Switch which, while ON, makes all wild Pokémon created be shiny.
  SHINY_WILD_POKEMON_SWITCH = 31
  # The Game Switch which, while ON, makes all Pokémon created considered to be
  # met via a fateful encounter.
  FATEFUL_ENCOUNTER_SWITCH = 32

  #=============================================================================

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID = 2
  # ID of the animation played when a trainer notices the player (an exclamation
  # bubble).
  EXCLAMATION_ANIMATION_ID = 3
  # ID of the animation played when a patch of grass rustles due to using the
  # Poké Radar.
  RUSTLE_NORMAL_ANIMATION_ID = 1
  # ID of the animation played when a patch of grass rustles vigorously due to
  # using the Poké Radar. (Rarer species)
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  # ID of the animation played when a patch of grass rustles and shines due to
  # using the Poké Radar. (Shiny encounter)
  RUSTLE_SHINY_ANIMATION_ID = 6
  # ID of the animation played when a berry tree grows a stage while the player
  # is on the map (for new plant growth mechanics only).
  PLANT_SPARKLE_ANIMATION_ID = 7

  CUT_TREE_ANIMATION_ID = 19
  ROCK_SMASH_ANIMATION_ID = 20

  #=============================================================================

  # An array of available languages in the game, and their corresponding message
  # file in the Data folder. Edit only if you have 2 or more languages to choose
  # from.
  LANGUAGES = [
    #  ["English", "english.dat"],
    #  ["Deutsch", "deutsch.dat"]
  ]

  #=============================================================================

  # Available speech frames. These are graphic files in "Graphics/Windowskins/".
  SPEECH_WINDOWSKINS = [
    "speech hgss 1",
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

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "choice 1",
    "choice 2",
    "choice 3",
    "choice 4",
    "choice 5",
    "choice 6",
    "choice 7",
    "choice 8",
    "choice 9",
    "choice 10",
    "choice 11",
    "choice 12",
    "choice 13",
    "choice 14",
    "choice 15",
    "choice 16",
    "choice 17",
    "choice 18",
    "choice 19",
    "choice 20",
    "choice 21",
    "choice 22",
    "choice 23",
    "choice 24",
    "choice 25",
    "choice 26",
    "choice 27",
    "choice 28"
  ]
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "19.1.dev"
  ERROR_TEXT = ""
end
