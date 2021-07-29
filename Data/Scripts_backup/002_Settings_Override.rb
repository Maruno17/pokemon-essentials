GAME_VERSION_NUMBER = "4.8.6.2 - debug build"

###############################
###### Settings ##############
###SCRIPTEDIT5
##########################
NUM_BADGES    = 16
CONST_NB_POKE = 420
NB_POKEMON = CONST_NB_POKE

#todo: refactor les 2 sont utilisés dans le code pour aucune bonne raison
NUM_ZAPMOLCUNO = 176821
ZAPMOLCUNO_NB = NUM_ZAPMOLCUNO

RIVAL_STARTER_PLACEHOLDER_SPECIES = 151 #(MEW)

#non impémenté parce que ca fuck avec le turbo
#OW_FRAMERATE = 40
BATTLE_FRAMERATE_MULTI = 1.5
BASE_FRAMERATE = 40
TURBO_FRAMERATE = 80

#===============================================================================
# * The maximum level Pokémon can reach.
# * The level of newly hatched Pokémon.
# * The odds of a newly generated Pokémon being shiny (out of 65536).
# * The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
#===============================================================================
MAXIMUMLEVEL       = 100
EGGINITIALLEVEL    = 1
SHINYPOKEMONCHANCE = 0 #64
POKERUSCHANCE      = 3

#===============================================================================
# * The default screen width (at a zoom of 1.0; size is half this at zoom 0.5).
# * The default screen height (at a zoom of 1.0).
# * The default screen zoom. (1.0 means each tile is 32x32 pixels, 0.5 means
#      each tile is 16x16 pixels, 2.0 means each tile is 64x64 pixels.)
# * Map view mode (0=original, 1=custom, 2=perspective).
#===============================================================================
DEFAULTSCREENWIDTH  = 512
DEFAULTSCREENHEIGHT =384
DEFAULTSCREENZOOM   = 2
MAPVIEWMODE         = 0#$game_variables[25]


# To forbid the player from changing the screen size themselves, quote out or
# delete the relevant bit of code in the PokemonOptions script section.

#===============================================================================
# * Whether poisoned Pokémon will lose HP while walking around in the field.
# * Whether poisoned Pokémon will faint while walking around in the field
#      (true), or survive the poisoning with 1HP (false).
# * Whether fishing automatically hooks the Pokémon (if false, there is a
#      reaction test first).
# * Whether TMs can be used infinitely as in Gen 5 (true), or are one-use-only
#      as in older Gens (false).
# * Whether the player can surface from anywhere while diving (true), or only in
#      spots where they could dive down from above (false).
# * Whether a move's physical/special category depends on the move itself as in
#      newer Gens (true), or on its type as in older Gens (false).
# * Whether the Exp gained from beating a Pokémon should be scaled depending on
#      the gainer's level as in Gen 5 (true), or not as in older Gens (false).
# * Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
#      mechanics (false).
#===============================================================================
POISONINFIELD         = true
POISONFAINTINFIELD    = false
FISHINGAUTOHOOK       = false
INFINITETMS           = true
DIVINGSURFACEANYWHERE = true
USEMOVECATEGORY       = true
USENEWEXPFORMULA      = false
NEWBERRYPLANTS        = true
$Bubble = 0

#===============================================================================
# * Pairs of map IDs, where the location signpost isn't shown when moving from
#      one of the maps in a pair to the other (and vice versa).  Useful for
#      single long routes/towns that are spread over multiple maps.
# e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
#   Moving between two maps that have the exact same name won't show the
#      location signpost anyway, so you don't need to list those maps here.
#===============================================================================
NOSIGNPOSTS = []

#===============================================================================
# * Whether outdoor maps should be shaded according to the time of day.
#===============================================================================
ENABLESHADING = true

#===============================================================================
# * The minimum number of badges required to boost each stat of a player's
#      Pokémon by 1.1x, while using moves in battle only.
# * Whether the badge restriction on using certain hidden moves is either owning
#      at least a certain number of badges (true), or owning a particular badge
#      (false).
# * Depending on HIDDENMOVESCOUNTBADGES, either the number of badges required to
#      use each hidden move, or the specific badge number required to use each
#      move.  Remember that badge 0 is the first badge, badge 1 is the second
#      badge, etc.
# e.g. To require the second badge, put false and 1.
#      To require at least 2 badges, put true and 2.
#===============================================================================
BADGESBOOSTATTACK      = 20
BADGESBOOSTDEFENSE     = 20
BADGESBOOSTSPEED       = 20
BADGESBOOSTSPATK       = 20
BADGESBOOSTSPDEF       = 20
HIDDENMOVESCOUNTBADGES = true
BADGEFORCUT            = 1
BADGEFORFLASH          = 2
BADGEFORROCKSMASH      = 0
BADGEFORSURF           = 5
BADGEFORFLY            = 3
BADGEFORSTRENGTH       = 5
BADGEFORDIVE           = 9
BADGEFORWATERFALL      = 8
BADGEFORTELEPORT       = 3
BADGEFORBOUNCE         = 8
BADGEFORROCKCLIMB      = 16


#===============================================================================
# * The names of each pocket of the Bag.  Leave the first entry blank.
# * The maximum number of slots per pocket (-1 means infinite number).  Ignore
#      the first number (0).
# * The maximum number of items each slot in the Bag can hold.
# * Whether each pocket in turn auto-sorts itself by item ID number.  Ignore
#      the first entry (the 0).
# * The pocket number containing all berries.  Is opened when choosing one to
#      plant, and cannot view a different pocket while doing so.
#===============================================================================
def pbPocketNames; return ["",
                           _INTL("Items"),
                           _INTL("Medicine"),
                           _INTL("Poké Balls"),
                           _INTL("TMs & HMs"),
                           _INTL("Berries"),
                           _INTL("Mail"),
                           _INTL("Battle Items"),
                           _INTL("Key Items")
]; end
MAXPOCKETSIZE  = [0,-1,-1,-1,-1,-1,-1,-1,-1]
BAGMAXPERSLOT  = 99
POCKETAUTOSORT = [0,true,false,false,true,true,false,false,false]
BERRYPOCKET    = 5

#===============================================================================
# * The name of the person who created the Pokémon storage system.
# * The number of boxes in Pokémon storage.
#===============================================================================
def pbStorageCreator
  return _INTL("Bill")
end
STORAGEBOXES = 16

#===============================================================================
# * Whether the Pokédex list shown is the one for the player's current region
#      (true), or whether a menu pops up for the player to manually choose which
#      Dex list to view when appropriate (false).
# * The names of each Dex list in the game, in order and with National Dex at
#      the end.  This is also the order that $PokemonGlobal.pokedexUnlocked is
#      in, which records which Dexes have been unlocked (first is unlocked by
#      default).
#      You can define which region a particular Dex list is linked to.  This
#      means the area map shown while viewing that Dex list will ALWAYS be that
#      of the defined region, rather than whichever region the player is
#      currently in.  To define this, put the Dex name and the region number in
#      an array, like the Kanto and Johto Dexes are.  The National Dex isn't in
#      an array with a region number, therefore its area map is whichever region
#      the player is currently in.
# * Whether all forms of a given species will be immediately available to view
#      in the Pokédex so long as that species has been seen at all (true), or
#      whether each form needs to be seen specifically before that form appears
#      in the Pokédex (false).
# * An array of numbers, where each number is that of a Dex list (National Dex
#      is -1).  All Dex lists included here have the species numbers in them
#      reduced by 1, thus making the first listed species have a species number
#      of 0 (e.g. Victini).
#===============================================================================
DEXDEPENDSONLOCATION = false
def pbDexNames; return [
    #[_INTL("Kanto Pokédex"),0],
    #[_INTL("Johto Pokédex"),1],
    #_INTL("Pokédex")
]; end
ALWAYSSHOWALLFORMS = true
DEXINDEXOFFSETS    = []

#===============================================================================
# * The amount of money the player starts the game with.
# * The maximum amount of money the player can have.
# * The maximum number of Game Corner coins the player can have.
#===============================================================================
INITIALMONEY = 3000
MAXMONEY     = 9999999
MAXCOINS     = 999999

#===============================================================================
# * A set of arrays each containing a trainer type followed by a Global Variable
#      number.  If the variable isn't set to 0, then all trainers with the
#      associated trainer type will be named as whatever is in that variable.
#===============================================================================
RIVALNAMES = [
    [:RIVAL1,12],
    [:RIVAL2,12],
    [:CHAMPION,12]
]

#===============================================================================
# * A list of maps used by roaming Pokémon.  Each map has an array of other maps
#      it can lead to.
# * A set of arrays each containing the details of a roaming Pokémon.  The
#      information within is as follows:
#      - Species.
#      - Level.
#      - Global Switch; the Pokémon roams while this is ON.
#      - Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
#           4=surfing/fishing).  See bottom of PokemonRoaming for lists.
#      - Name of BGM to play for that encounter (optional).
#      - Roaming areas specifically for this Pokémon (optional).
#===============================================================================
RoamingAreas = {
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

seviiRoaming = {
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

RoamingSpecies = [
    [:ENTEI, 50, 350, 1, "Legendary Birds"],
    [:B245H243, 50, 341, 1, "Legendary Birds"],
    [:LATIOS, 50, 602, 0, "Legendary Birds",seviiRoaming],
    [:LATIAS, 50, 602, 0, "Legendary Birds",seviiRoaming],
    [:FEEBAS, 15, 4, 3, "Pokemon HeartGold and SoulSilver - Wild Pokemon Battle (Kanto)",seviiRoaming]
]


#===============================================================================
# * A set of arrays each containing details of a wild encounter that can only
#      occur via using the Poké Radar.  The information within is as follows:
#      - Map ID on which this encounter can occur.
#      - Probability that this encounter will occur (as a percentage).
#      - Species.
#      - Minimum possible level.
#      - Maximum possible level (optional).
#===============================================================================
POKERADAREXCLUSIVES=[
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
    [145, 5, :ABSOL,30,35],             #Rt. 26
    [147, 5, :ABSOL,30,35],             #Rt. 27
    [311, 30, :BIDOOF,5,5],             #Rt. 29
    [265, 30, :KIRLIA,25,30],           #Rt. 34
    [300, 30, :ROSELIA,30,30],          #National Park
    [300, 30, :BRELOOM,30,30],          #Ilex Forest
    [670, 30, :WEAVILE,50,50],          #Ice mountains
    [528, 30, :PYUKUMUKU,20,20],        #Treasure Beach
    [690, 30, :OCTILLERY,32,45],        #Deep Ocean
    [561, 30, :MAGMAR,32,45],           #Mt. Ember
    [654, 30, :WHIMSICOTT,32,45],       #Brine Road
]

#===============================================================================
# * A set of arrays each containing details of a graphic to be shown on the
#      region map if appropriate.  The values for each array are as follows:
#      - Region number.
#      - Global Switch; the graphic is shown if this is ON (non-wall maps only).
#      - X coordinate of the graphic on the map, in squares.
#      - Y coordinate of the graphic on the map, in squares.
#      - Name of the graphic, found in the Graphics/Pictures folder.
#      - The graphic will always (true) or never (false) be shown on a wall map.
#===============================================================================
REGIONMAPEXTRAS = [
    [0,51,16,15,"mapHiddenDaroxy",false],
    [0,52,20,14,"mapHiddenFaraday",false]
]

#===============================================================================
# * The number of steps allowed before a Safari Zone game is over (0=infinite).
# * The number of seconds a Bug Catching Contest lasts for (0=infinite).
#===============================================================================
SAFARISTEPS    = 500
BUGCONTESTTIME = 1200

#===============================================================================
# * The Global Switch that is set to ON when the player whites out.
# * The Global Switch that is set to ON when the player has seen Pokérus in the
#      Poké Center, and doesn't need to be told about it again.
# * The Global Switch which, while ON, makes all wild Pokémon created be
#      shiny.
# * The Global Switch which, while ON, makes all Pokémon created considered to
#      be met via a fateful encounter.
# * The Global Switch which determines whether the player will lose money if
#      they lose a battle (they can still gain money from trainers for winning).
# * The Global Switch which, while ON, prevents all Pokémon in battle from Mega
#      Evolving even if they otherwise could.
# * The ID of the common event that runs when the player starts fishing (runs
#      instead of showing the casting animation).
# * The ID of the common event that runs when the player stops fishing (runs
#      instead of showing the reeling in animation).
#===============================================================================
STARTING_OVER_SWITCH      = 1
SEEN_POKERUS_SWITCH       = 2
SHINY_WILD_POKEMON_SWITCH = 31
FATEFUL_ENCOUNTER_SWITCH  = 32
NO_MONEY_LOSS             = 33
NO_MEGA_EVOLUTION         = 34
FISHINGBEGINCOMMONEVENT   = -1
FISHINGENDCOMMONEVENT     = -1

#===============================================================================
# * The ID of the animation played when the player steps on grass (shows grass
#      rustling).
# * The ID of the animation played when a trainer notices the player (an
#      exclamation bubble).
# * The ID of the animation played when a patch of grass rustles due to using
#      the Poké Radar.
# * The ID of the animation played when a patch of grass rustles vigorously due
#      to using the Poké Radar. (Rarer species)
# * The ID of the animation played when a patch of grass rustles and shines due
#      to using the Poké Radar. (Shiny encounter)
# * The ID of the animation played when a berry tree grows a stage while the
#      player is on the map (for new plant growth mechanics only).
#===============================================================================
GRASS_ANIMATION_ID           = 1
DUST_ANIMATION_ID            = 2
EXCLAMATION_ANIMATION_ID     = 3
RUSTLE_NORMAL_ANIMATION_ID   = 1
RUSTLE_VIGOROUS_ANIMATION_ID = 5
RUSTLE_SHINY_ANIMATION_ID    = 6
PLANT_SPARKLE_ANIMATION_ID   = 7

#===============================================================================
# * An array of available languages in the game, and their corresponding
#      message file in the Data folder.  Edit only if you have 2 or more
#      languages to choose from.
#===============================================================================
LANGUAGES = [
    #  ["English","english.dat"],
    #  ["Deutsch","deutsch.dat"]
]

HIDDEN_MAP_ALWAYS = [178,655,570,356]
RANDOM_HIDDEN_MAP_LIST =  [8,109,431,446,402,403,467,468,10,23,167,16,19,78,185,86,
                           491,90,40,342,490,102,103,104,105,106,1,12,413,445,484,485,486,140,350,146,
                           149,304,356,307,409,351,495,154,349,322,323,544,198,144,155,444,58,59,229,52,53,54,
                           55,98,173,174,181,187,95,159,162,437,220,440,438,57,171,172,528,265,288,364,329,
                           335,254,261,262,266,230,145,147,258,284,283,267,586,285,286,287,300,311,47,580,529,
                           635,638,646,560,559,526,600,564,594,566,562,619,563,603,561,597,633,640,641,621,312,
                           670,692,643,523,698,
                           602,642,623,569,588,573,362,645,651,376
]
#the last line is legendary maps


# Various config constants used for sprite scaling
# used to scale the trainer bitmaps to 200%
TRAINERSPRITESCALE = 1.2

# used to scale the Pokemon bitmaps to 200%
POKEMONSPRITESCALE = 0.66666

# used to scale the backsprite for battle perspective (200%)
BACKSPRITESCALE =   0.875       #0.8

BATTLER_Y_OFFSET = 20
OPPONENT_Y_OFFSET=20