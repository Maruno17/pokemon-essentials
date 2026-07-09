using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Core game settings and configuration interface.
    /// </summary>
    public interface ISettings
    {
        /// <summary>
        /// The version of the game in MAJOR.MINOR.PATCH format.
        /// </summary>
        string GAME_VERSION { get; }

        /// <summary>
        /// The generation that the battle system follows.
        /// Only generations 5 and later are reasonably supported.
        /// </summary>
        int MECHANICS_GENERATION { get; }

        /// <summary>
        /// Gets the game's credits as an array of strings.
        /// Lines can be translated using _INTL().
        /// Use "<s>" to split a line into two columns.
        /// </summary>
        string[] game_credits { get; }

        #region Player and NPCs

        /// <summary>
        /// The maximum amount of money the player can have.
        /// </summary>
        int MAX_MONEY { get; }

        /// <summary>
        /// The maximum number of Game Corner coins the player can have.
        /// </summary>
        int MAX_COINS { get; }

        /// <summary>
        /// The maximum number of Battle Points the player can have.
        /// </summary>
        int MAX_BATTLE_POINTS { get; }

        /// <summary>
        /// The maximum amount of soot the player can have.
        /// </summary>
        int MAX_SOOT { get; }

        /// <summary>
        /// The maximum length, in characters, that the player's name can be.
        /// </summary>
        int MAX_PLAYER_NAME_SIZE { get; }

        /// <summary>
        /// A set of arrays each containing a trainer type followed by a Game Variable number.
        /// If the Variable isn't set to 0, then all trainers with the associated trainer type
        /// will be named as whatever is in that Variable.
        /// </summary>
        IDictionary<int, string> RIVAL_NAMES { get; }

        #endregion

        #region Overworld

        /// <summary>
        /// Whether outdoor maps should be shaded according to the time of day.
        /// </summary>
        bool TIME_SHADING { get; }

        /// <summary>
        /// Whether the reflections of the player/events will ripple horizontally.
        /// </summary>
        bool ANIMATE_REFLECTIONS { get; }

        /// <summary>
        /// Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3 mechanics (false).
        /// </summary>
        bool NEW_BERRY_PLANTS { get; }

        /// <summary>
        /// Whether fishing automatically hooks the Pokémon (true), or whether there is a reaction test first (false).
        /// </summary>
        bool FISHING_AUTO_HOOK { get; }

        /// <summary>
        /// The ID of the common event that runs when the player starts fishing.
        /// Runs instead of showing the casting animation.
        /// </summary>
        int FISHING_BEGIN_COMMON_EVENT { get; }

        /// <summary>
        /// The ID of the common event that runs when the player stops fishing.
        /// Runs instead of showing the reeling in animation.
        /// </summary>
        int FISHING_END_COMMON_EVENT { get; }

        /// <summary>
        /// The number of steps allowed before a Safari Zone game is over (0=infinite).
        /// </summary>
        int SAFARI_STEPS { get; }

        /// <summary>
        /// The number of seconds a Bug-Catching Contest lasts for (0=infinite).
        /// </summary>
        int BUG_CONTEST_TIME { get; }

        /// <summary>
        /// Pairs of map IDs where the location signpost isn't shown when moving between them.
        /// Useful for single long routes/towns that are spread over multiple maps.
        /// </summary>
        IList<int> NO_SIGNPOSTS { get; }

        /// <summary>
        /// Whether poisoned Pokémon will lose HP while walking around in the field.
        /// </summary>
        bool POISON_IN_FIELD { get; }

        /// <summary>
        /// Whether poisoned Pokémon will faint while walking around in the field (true),
        /// or survive the poisoning with 1 HP (false).
        /// </summary>
        bool POISON_FAINT_IN_FIELD { get; }

        #endregion

        #region Field Moves

        /// <summary>
        /// Whether you need at least a certain number of badges to use hidden moves (true),
        /// or whether you need one specific badge (false).
        /// </summary>
        bool FIELD_MOVES_COUNT_BADGES { get; }

        /// <summary>
        /// Badge requirement for using Cut in the field.
        /// If FIELD_MOVES_COUNT_BADGES is true, this is the minimum number of badges needed.
        /// If false, this is the specific badge number required (0-based index).
        /// </summary>
        int BADGE_FOR_CUT { get; }

        /// <summary>
        /// Badge requirement for using Flash in the field.
        /// </summary>
        int BADGE_FOR_FLASH { get; }

        /// <summary>
        /// Badge requirement for using Rock Smash in the field.
        /// </summary>
        int BADGE_FOR_ROCKSMASH { get; }

        /// <summary>
        /// Badge requirement for using Surf in the field.
        /// </summary>
        int BADGE_FOR_SURF { get; }

        /// <summary>
        /// Badge requirement for using Fly in the field.
        /// </summary>
        int BADGE_FOR_FLY { get; }

        /// <summary>
        /// Badge requirement for using Strength in the field.
        /// </summary>
        int BADGE_FOR_STRENGTH { get; }

        /// <summary>
        /// Badge requirement for using Dive in the field.
        /// </summary>
        int BADGE_FOR_DIVE { get; }

        /// <summary>
        /// Badge requirement for using Waterfall in the field.
        /// </summary>
        int BADGE_FOR_WATERFALL { get; }

        #endregion

        #region Pokemon

        /// <summary>
        /// The maximum level Pokémon can reach.
        /// </summary>
        int MAXIMUM_LEVEL { get; }

        /// <summary>
        /// The level of newly hatched Pokémon.
        /// </summary>
        int EGG_LEVEL { get; }

        /// <summary>
        /// The odds of a newly generated Pokémon being shiny (out of 65536).
        /// </summary>
        int SHINY_POKEMON_CHANCE { get; }

        /// <summary>
        /// Whether super shininess is enabled (uses a different shiny animation).
        /// </summary>
        bool SUPER_SHINY { get; }

        /// <summary>
        /// Whether Pokémon with the "Legendary", "Mythical" or "Ultra Beast" flags will
        /// have at least 3 perfect IVs.
        /// </summary>
        bool LEGENDARIES_HAVE_SOME_PERFECT_IVS { get; }

        /// <summary>
        /// The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
        /// </summary>
        int POKERUS_CHANCE { get; }

        /// <summary>
        /// Whether IVs and EVs are treated as 0 when calculating a Pokémon's stats.
        /// IVs and EVs still exist, and are used by Hidden Power and some cosmetic things.
        /// </summary>
        bool DISABLE_IVS_AND_EVS { get; }

        /// <summary>
        /// Whether the Move Relearner can teach egg moves that the Pokémon knew when hatched
        /// and moves that the Pokémon was once taught by a TR.
        /// </summary>
        bool MOVE_RELEARNER_CAN_TEACH_MORE_MOVES { get; }

        #endregion

        #region Breeding and Day Care

        /// <summary>
        /// Whether Pokémon in the Day Care gain Exp for each step the player takes.
        /// Should be true for Day Care and false for Pokémon Nursery.
        /// </summary>
        bool DAY_CARE_POKEMON_GAIN_EXP_FROM_WALKING { get; }

        /// <summary>
        /// Whether two Pokémon in the Day Care can learn egg moves from each other if
        /// they are the same species.
        /// </summary>
        bool DAY_CARE_POKEMON_CAN_SHARE_EGG_MOVES { get; }

        /// <summary>
        /// Whether a bred baby Pokémon can inherit any TM/TR/HM moves from its father.
        /// It can never inherit TM/TR/HM moves from its mother.
        /// </summary>
        bool BREEDING_CAN_INHERIT_MACHINE_MOVES { get; }

        /// <summary>
        /// Whether a bred baby Pokémon can inherit egg moves from its mother.
        /// It can always inherit egg moves from its father.
        /// </summary>
        bool BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER { get; }

        #endregion

        #region Roaming Pokemon

        /// <summary>
        /// A list of maps used by roaming Pokémon. Each map has an array of other maps
        /// it can lead to.
        /// </summary>
        IDictionary<int, IList<int>> ROAMING_AREAS { get; }

        /// <summary>
        /// A set of roaming Pokémon configurations.
        /// </summary>
        IList<IRoamingSpeciesData> ROAMING_SPECIES { get; }

        #endregion

        #region Party and Pokemon Storage

        /// <summary>
        /// The maximum number of Pokémon that can be in the party.
        /// </summary>
        int MAX_PARTY_SIZE { get; }

        /// <summary>
        /// The number of boxes in Pokémon storage.
        /// </summary>
        int NUM_STORAGE_BOXES { get; }

        /// <summary>
        /// Whether putting a Pokémon into Pokémon storage will heal it.
        /// If false, they are healed by the Recover All: Entire Party event command.
        /// </summary>
        bool HEAL_STORED_POKEMON { get; }

        #endregion

        #region Items

        /// <summary>
        /// Whether various HP-healing items heal the amounts they do in Gen 7+ (true)
        /// or in earlier Generations (false).
        /// </summary>
        bool REBALANCED_HEALING_ITEM_AMOUNTS { get; }

        /// <summary>
        /// Whether vitamins can add EVs no matter how many that stat already has (true),
        /// or whether they can't make that stat's EVs greater than 100 (false).
        /// </summary>
        bool NO_VITAMIN_EV_CAP { get; }

        /// <summary>
        /// Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
        /// </summary>
        bool RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS { get; }

        /// <summary>
        /// Whether the Black/White Flutes will raise/lower the levels of wild Pokémon (true),
        /// or will lower/raise the wild encounter rate (false).
        /// </summary>
        bool FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS { get; }

        /// <summary>
        /// Whether Rare Candy can be used on a Pokémon at max level if it can evolve.
        /// </summary>
        bool RARE_CANDY_USABLE_AT_MAX_LEVEL { get; }

        /// <summary>
        /// Whether multiple stat items can be used at once on a Pokémon.
        /// Applies to Exp/EV-changing items.
        /// </summary>
        bool USE_MULTIPLE_STAT_ITEMS_AT_ONCE { get; }

        /// <summary>
        /// Whether moves taught by TMs/TRs/HMs keep their old PP when replacing a move.
        /// </summary>
        bool TAUGHT_MACHINES_KEEP_OLD_PP { get; }

        /// <summary>
        /// Whether buying 10+ Poké Balls at once gives multiple Premier Balls.
        /// </summary>
        bool MORE_BONUS_PREMIER_BALLS { get; }

        /// <summary>
        /// The divisor used to calculate item sell prices.
        /// </summary>
        int ITEM_SELL_PRICE_DIVISOR { get; }

        /// <summary>
        /// Names of the bag pockets.
        /// </summary>
        string[] bag_pocket_names { get; }

        /// <summary>
        /// Maximum size of each bag pocket (-1 = unlimited).
        /// </summary>
        int[] BAG_MAX_POCKET_SIZE { get; }

        /// <summary>
        /// Whether each bag pocket auto-sorts its contents.
        /// </summary>
        bool[] BAG_POCKET_AUTO_SORT { get; }

        /// <summary>
        /// Maximum number of items that can be held in a single inventory slot.
        /// </summary>
        int BAG_MAX_PER_SLOT { get; }

        #endregion

        #region Pokedex

        /// <summary>
        /// Names of the Pokédex list modes.
        /// </summary>
        string[] pokedex_names { get; }

        /// <summary>
        /// Whether to use only the current region's Pokédex list.
        /// </summary>
        bool USE_CURRENT_REGION_DEX { get; }

        /// <summary>
        /// Whether the Pokédex shows all forms of each Pokémon.
        /// </summary>
        bool DEX_SHOWS_ALL_FORMS { get; }

        /// <summary>
        /// List of Pokédex numbers that are actually relative to a region's base number.
        /// </summary>
        IList<int> DEXES_WITH_OFFSETS { get; }

        /// <summary>
        /// Whether to show the "new Pokémon" message more frequently.
        /// </summary>
        bool SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN { get; }

        #endregion

        #region Region Map

        /// <summary>
        /// Extra data shown on the region map.
        /// </summary>
        IList<IList<object>> REGION_MAP_EXTRAS { get; }

        /// <summary>
        /// Whether the player can use Fly from the Town Map.
        /// </summary>
        bool CAN_FLY_FROM_TOWN_MAP { get; }

        #endregion

        #region Phone

        /// <summary>
        /// Whether rematches can be triggered from the beginning of the game.
        /// </summary>
        bool PHONE_REMATCHES_POSSIBLE_FROM_BEGINNING { get; }

		/// <summary>
		/// Whether phone call messages are colored based on the contact's gender.
		/// </summary>
		bool COLOR_PHONE_CALL_MESSAGES_BY_CONTACT_GENDER { get; }

		#endregion

		#region Wild Encounters

		/// <summary>
		/// Whether fainted Pokémon count for Repel's effects.
		/// </summary>
		bool REPEL_COUNTS_FAINTED_POKEMON { get; }

		/// <summary>
		/// Whether more abilities affect wild encounters.
		/// </summary>
		bool MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS { get; }

		/// <summary>
		/// Whether shiny chances increase with number of Pokémon battled.
		/// </summary>
		bool HIGHER_SHINY_CHANCES_WITH_NUMBER_BATTLED { get; }

		/// <summary>
		/// Whether overworld weather sets the battle terrain.
		/// </summary>
		bool OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN { get; }

		#endregion

		#region Game Switches

		/// <summary>
		/// Switch ID for starting over.
		/// </summary>
		int STARTING_OVER_SWITCH { get; }

		/// <summary>
		/// Switch ID for having seen Pokérus.
		/// </summary>
		int SEEN_POKERUS_SWITCH { get; }

		/// <summary>
		/// Switch ID for shiny wild Pokémon.
		/// </summary>
		int SHINY_WILD_POKEMON_SWITCH { get; }

		/// <summary>
		/// Switch ID for fateful encounters.
		/// </summary>
		int FATEFUL_ENCOUNTER_SWITCH { get; }

		/// <summary>
		/// Switch ID for disabling Box Link.
		/// </summary>
		int DISABLE_BOX_LINK_SWITCH { get; }

		#endregion

		#region Animation IDs

		/// <summary>
		/// Animation ID for grass movement.
		/// </summary>
		int GRASS_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for dust clouds.
		/// </summary>
		int DUST_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for water ripples.
		/// </summary>
		int WATER_RIPPLE_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for exclamation mark.
		/// </summary>
		int EXCLAMATION_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for normal grass rustle.
		/// </summary>
		int RUSTLE_NORMAL_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for vigorous grass rustle.
		/// </summary>
		int RUSTLE_VIGOROUS_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for shiny grass rustle.
		/// </summary>
		int RUSTLE_SHINY_ANIMATION_ID { get; }

		/// <summary>
		/// Animation ID for berry plant sparkle.
		/// </summary>
		int PLANT_SPARKLE_ANIMATION_ID { get; }

        #endregion

        #region Languages and Screen

        /// <summary>
        /// List of available language IDs.
        /// </summary>
		IDictionary<int,string> LANGUAGES { get; }

        /// <summary>
        /// Screen width in pixels.
        /// </summary>
        int SCREEN_WIDTH { get; }

        /// <summary>
        /// Screen height in pixels.
        /// </summary>
        int SCREEN_HEIGHT { get; }

        /// <summary>
        /// Screen scaling factor.
        /// </summary>
        double SCREEN_SCALE { get; }

        #endregion

        #region UI

        /// <summary>
        /// Available windowskins for speech windows.
        /// </summary>
        IList<string> SPEECH_WINDOWSKINS { get; }

        /// <summary>
        /// Available windowskins for menu windows.
        /// </summary>
        IList<string> MENU_WINDOWSKINS { get; }

        #endregion

        #region Debug

        /// <summary>
        /// Whether to prompt for compilation.
        /// </summary>
        bool PROMPT_TO_COMPILE { get; }

        /// <summary>
        /// Whether to skip the title screen.
        /// </summary>
        bool SKIP_TITLE_SCREEN { get; }

        /// <summary>
        /// Whether to skip the continue screen.
        /// </summary>
        bool SKIP_CONTINUE_SCREEN { get; }

        #endregion
    }

    public partial interface IEssentials
    {
        string VERSION { get; }
        string ERROR_TEXT { get; }
        string MKXPZ_VERSION { get; }
    }
}