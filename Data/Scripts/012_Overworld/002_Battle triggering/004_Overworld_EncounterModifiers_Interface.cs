namespace PokemonEssentials
{
    /// <summary>
    /// Overworld encounter modifiers interface for modifying wild Pokémon and trainers before battles.
    /// </summary>
    /// <remarks>
    /// This section was created solely for you to put various bits of code that
    /// modify various wild Pokémon and trainers immediately prior to battling them.
    /// Be sure that any code you use here ONLY applies to the Pokémon/trainers you
    /// want it to apply to!
    /// </remarks>
    public interface IMainOverworldEncounterModifiers : IMain
    {
        /// <summary>
        /// Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
        /// </summary>
        /// <remarks>
        /// Forces wild Pokemon to be shiny when specific switch is active.
        /// Makes all wild Pokemon shiny while designated switch is ON.
        /// Useful for special events or debugging purposes.
        /// </remarks>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_wild_pokemon_created, :make_shiny_switch,
        ///   proc { |pkmn|
        ///     pkmn.shiny = true if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <param name="pokemon">Wild Pokemon to potentially make shiny</param>
        /// <seealso cref="IEvents.OnWildPokemonCreated"/>
        /// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
        void OnWildPokemonCreatedTrigger_makeShinyBySwitch(IPokemon pokemon);

        /// <summary>
        /// Rerolls IVs for Safari Zone and Bug Contest Pokemon.
        /// </summary>
        /// <remarks>
        /// In Safari Zone and Bug-Catching Contests, wild Pokemon reroll their IVs
        /// up to 4 times if they don't have a perfect IV, improving encounter quality.
        /// </remarks>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_wild_pokemon_created, :reroll_ivs_in_safari_and_bug_contest,
        ///   proc { |pkmn|
        ///     next if !pbInSafari? && !pbInBugContest?
        ///     rerolled = false
        ///     4.times do
        ///       break if pkmn.iv.any? { |_stat, val| val == Pokemon::IV_STAT_LIMIT }
        ///       rerolled = true
        ///       GameData::Stat.each_main do |s|
        ///         pkmn.iv[s.id] = rand(Pokemon::IV_STAT_LIMIT + 1)
        ///       end
        ///     end
        ///     pkmn.calc_stats if rerolled
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <param name="pokemon">Wild Pokemon to reroll IVs for</param>
        /// <seealso cref="IEvents.OnWildPokemonCreated"/>
        /// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
        void OnWildPokemonCreatedTrigger_rerollIVsInSpecialAreas(IPokemon pokemon);

        /// <summary>
        /// Guarantees perfect IVs for legendary Pokemon.
        /// </summary>
        /// <remarks>
        /// In Gen 6 and later, Legendary/Mythical/Ultra Beast Pokemon are guaranteed
        /// to have at least 3 perfect IVs for competitive viability.
        /// </remarks>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_wild_pokemon_created, :some_perfect_ivs_for_legendaries,
        ///   proc { |pkmn|
        ///     next if !Settings::LEGENDARIES_HAVE_SOME_PERFECT_IVS
        ///     data = pkmn.species_data
        ///     next if !data.has_flag?("Legendary") && !data.has_flag?("Mythical") && !data.has_flag?("UltraBeast")
        ///     stats = []
        ///     GameData::Stat.each_main { |s| stats.push(s.id) }
        ///     perfect_stats = stats.sample(3)
        ///     perfect_stats.each { |s| pkmn.iv[s] = Pokemon::IV_STAT_LIMIT }
        ///     pkmn.calc_stats
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <param name="pokemon">Wild Pokemon to check for legendary status</param>
        /// <seealso cref="IEvents.OnWildPokemonCreated"/>
        /// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
        void OnWildPokemonCreatedTrigger_ensurePerfectIVsForLegendaries(IPokemon pokemon);

        /// <summary>
        /// Scales wild Pokemon levels based on player's party.
        /// Used in random dungeons and scaling areas to make encounters
        /// appropriately challenging relative to player's team strength.
        /// </summary>
        /// <remarks>
        /// Used in the random dungeon map. Makes the levels of all wild Pokémon in that
        /// map depend on the levels of Pokémon in the player's party.
        /// This is a simple method, and can/should be modified to account for evolutions
        /// and other such details.  Of course, you don't HAVE to use this code.
        /// </remarks>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_wild_pokemon_created, :level_depends_on_party,
        ///   proc { |pkmn|
        ///     next if !$game_map.metadata&.has_flag?("ScaleWildEncounterLevels")
        ///     new_level = pbBalancedLevel($player.party) - 4 + rand(5)   # For variety
        ///     new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
        ///     pkmn.level = new_level
        ///     pkmn.calc_stats
        ///     pkmn.reset_moves
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <param name="pokemon">Wild Pokemon to scale level for</param>
        /// <seealso cref="IEvents.OnWildPokemonCreated"/>
        /// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
        void OnWildPokemonCreatedTrigger_scaleLevelBasedOnParty(IPokemon pokemon);
    }
    /*
    /// <summary>
    /// Interface for wild Pokemon encounter modification system.
    /// Provides hooks for modifying wild Pokemon and trainers immediately before battles
    /// including shiny forcing, IV rerolling, and level scaling mechanics.
    /// </summary>
    public interface IEncounterModifiers
    {
        /// <summary>
        /// Forces wild Pokemon to be shiny when specific switch is active.
        /// Makes all wild Pokemon shiny while designated switch is ON.
        /// Useful for special events or debugging purposes.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon to potentially make shiny</param>
        void makeShinyBySwitch(IPokemon pokemon);

        /// <summary>
        /// Rerolls IVs for Safari Zone and Bug Contest Pokemon.
        /// In Safari Zone and Bug-Catching Contests, wild Pokemon reroll their IVs
        /// up to 4 times if they don't have a perfect IV, improving encounter quality.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon to reroll IVs for</param>
        void rerollIVsInSpecialAreas(IPokemon pokemon);

        /// <summary>
        /// Guarantees perfect IVs for legendary Pokemon.
        /// In Gen 6 and later, Legendary/Mythical/Ultra Beast Pokemon are guaranteed
        /// to have at least 3 perfect IVs for competitive viability.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon to check for legendary status</param>
        void ensurePerfectIVsForLegendaries(IPokemon pokemon);

        /// <summary>
        /// Scales wild Pokemon levels based on player's party.
        /// Used in random dungeons and scaling areas to make encounters
        /// appropriately challenging relative to player's team strength.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon to scale level for</param>
        void scaleLevelBasedOnParty(IPokemon pokemon);

        /// <summary>
        /// Applies all registered encounter modifications.
        /// Processes all active encounter modifiers for a wild Pokemon.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon to apply modifications to</param>
        void applyEncounterModifications(IPokemon pokemon);
    }

    /// <summary>
    /// Interface for trainer modification system.
    /// Provides hooks for modifying trainers and their Pokemon immediately before battles
    /// including both opponent trainers and partner trainers.
    /// </summary>
    public interface ITrainerModifiers
    {
        /// <summary>
        /// Applies modifications to trainer before battle.
        /// Modifies trainer data, Pokemon, items, and other properties
        /// when trainer is loaded for battle or partnership.
        /// </summary>
        /// <param name="trainer">Trainer to apply modifications to</param>
        void applyTrainerModifications(ITrainer trainer);

        /// <summary>
        /// Modifies trainer Pokemon party.
        /// Applies changes to trainer's Pokemon including levels, movesets, abilities, etc.
        /// </summary>
        /// <param name="trainer">Trainer whose party to modify</param>
        void modifyTrainerParty(ITrainer trainer);

        /// <summary>
        /// Modifies trainer items and equipment.
        /// Changes trainer's held items, battle items, and other equipment.
        /// </summary>
        /// <param name="trainer">Trainer whose items to modify</param>
        void modifyTrainerItems(ITrainer trainer);

        /// <summary>
        /// Modifies trainer battle text and dialogue.
        /// Changes victory text, defeat text, and other trainer dialogue.
        /// </summary>
        /// <param name="trainer">Trainer whose text to modify</param>
        void modifyTrainerText(ITrainer trainer);
    }

    /// <summary>
    /// Interface for IV rerolling system.
    /// Handles Pokemon IV regeneration and optimization for special encounter scenarios.
    /// </summary>
    public interface IIVRerollSystem
    {
        /// <summary>Maximum number of reroll attempts.</summary>
        int maxRerollAttempts { get; }

        /// <summary>
        /// Rerolls Pokemon IVs with specified attempts.
        /// Continues rerolling until perfect IV is found or max attempts reached.
        /// </summary>
        /// <param name="pokemon">Pokemon to reroll IVs for</param>
        /// <param name="maxAttempts">Maximum reroll attempts</param>
        /// <returns>True if any rerolls were performed</returns>
        bool rerollIVs(IPokemon pokemon, int maxAttempts = 4);

        /// <summary>
        /// Checks if Pokemon has any perfect IVs.
        /// Determines if Pokemon has at least one IV at maximum value.
        /// </summary>
        /// <param name="pokemon">Pokemon to check IVs for</param>
        /// <returns>True if Pokemon has at least one perfect IV</returns>
        bool hasPerfectIV(IPokemon pokemon);

        /// <summary>
        /// Sets guaranteed perfect IVs for legendary Pokemon.
        /// Ensures specified number of random stats have perfect IVs.
        /// </summary>
        /// <param name="pokemon">Pokemon to set perfect IVs for</param>
        /// <param name="count">Number of perfect IVs to guarantee</param>
        void guaranteePerfectIVs(IPokemon pokemon, int count = 3);

        /// <summary>
        /// Generates random IV value.
        /// Creates random individual value within valid range.
        /// </summary>
        /// <returns>Random IV value (0-31)</returns>
        int generateRandomIV();
    }

    /// <summary>
    /// Interface for level scaling system.
    /// Handles dynamic level adjustment for wild Pokemon based on party strength
    /// and encounter context for balanced gameplay experiences.
    /// </summary>
    public interface ILevelScalingSystem
    {
        /// <summary>
        /// Calculates appropriate level based on player's party.
        /// Analyzes party Pokemon levels to determine suitable encounter level.
        /// </summary>
        /// <param name="playerParty">Player's Pokemon party</param>
        /// <returns>Calculated encounter level</returns>
        int calculateBalancedLevel(IPokemon[] playerParty);

        /// <summary>
        /// Scales Pokemon level with variety adjustment.
        /// Adjusts Pokemon level based on party strength with random variation.
        /// </summary>
        /// <param name="pokemon">Pokemon to scale level for</param>
        /// <param name="baseLevel">Base calculated level</param>
        /// <param name="variation">Random variation range</param>
        void scaleLevel(IPokemon pokemon, int baseLevel, int variation = 5);

        /// <summary>
        /// Checks if map has level scaling enabled.
        /// Determines if current map uses dynamic level scaling for encounters.
        /// </summary>
        /// <returns>True if level scaling is active</returns>
        bool isLevelScalingActive();

        /// <summary>
        /// Gets minimum allowed level for encounters.
        /// Returns the lowest level Pokemon can be scaled to.
        /// </summary>
        /// <returns>Minimum encounter level</returns>
        int getMinimumLevel();

        /// <summary>
        /// Gets maximum allowed level for encounters.
        /// Returns the highest level Pokemon can be scaled to.
        /// </summary>
        /// <returns>Maximum encounter level</returns>
        int getMaximumLevel();
    }

    /// <summary>
    /// Interface for special area encounter rules.
    /// Manages unique encounter mechanics for special areas like Safari Zone,
    /// Bug Contests, and other special encounter locations.
    /// </summary>
    public interface ISpecialAreaEncounters
    {
        /// <summary>
        /// Checks if player is currently in Safari Zone.
        /// </summary>
        /// <returns>True if in Safari Zone</returns>
        bool isInSafariZone();

        /// <summary>
        /// Checks if player is currently in Bug Contest.
        /// </summary>
        /// <returns>True if in Bug Contest</returns>
        bool isInBugContest();

        /// <summary>
        /// Applies Safari Zone encounter rules.
        /// Modifies Pokemon according to Safari Zone mechanics.
        /// </summary>
        /// <param name="pokemon">Pokemon to apply Safari rules to</param>
        void applySafariZoneRules(IPokemon pokemon);

        /// <summary>
        /// Applies Bug Contest encounter rules.
        /// Modifies Pokemon according to Bug Contest mechanics.
        /// </summary>
        /// <param name="pokemon">Pokemon to apply Bug Contest rules to</param>
        void applyBugContestRules(IPokemon pokemon);

        /// <summary>
        /// Gets special area type for current location.
        /// Identifies what type of special encounter area player is in.
        /// </summary>
        /// <returns>Special area type or null if in normal area</returns>
        SpecialAreaType? getCurrentSpecialArea();
    }

    /// <summary>
    /// Enumeration for special encounter area types.
    /// Categorizes different special areas with unique encounter rules.
    /// </summary>
    public enum SpecialAreaType
    {
        /// <summary>Safari Zone with catching mechanics.</summary>
        SafariZone,

        /// <summary>Bug-Catching Contest area.</summary>
        BugContest,

        /// <summary>Random dungeon with scaling.</summary>
        RandomDungeon,

        /// <summary>Battle facility area.</summary>
        BattleFacility,

        /// <summary>Special event area.</summary>
        EventArea
    }

    /// <summary>
    /// Interface for encounter modification event system.
    /// Manages event-driven encounter modifications with customizable hooks
    /// for developers to add their own encounter modification logic.
    /// </summary>
    public interface IEncounterModificationEvents
    {
        /// <summary>
        /// Registers wild Pokemon creation handler.
        /// Adds custom handler for when wild Pokemon are created.
        /// </summary>
        /// <param name="handlerName">Unique name for handler</param>
        /// <param name="handler">Modification function</param>
        void registerWildPokemonHandler(string handlerName, System.Action<IPokemon> handler);

        /// <summary>
        /// Registers trainer load handler.
        /// Adds custom handler for when trainers are loaded.
        /// </summary>
        /// <param name="handlerName">Unique name for handler</param>
        /// <param name="handler">Modification function</param>
        void registerTrainerLoadHandler(string handlerName, System.Action<ITrainer> handler);

        /// <summary>
        /// Unregisters encounter modification handler.
        /// Removes previously registered modification handler.
        /// </summary>
        /// <param name="handlerName">Name of handler to remove</param>
        void unregisterHandler(string handlerName);

        /// <summary>
        /// Triggers wild Pokemon creation handlers.
        /// Executes all registered wild Pokemon modification handlers.
        /// </summary>
        /// <param name="pokemon">Wild Pokemon being created</param>
        void triggerWildPokemonCreation(IPokemon pokemon);

        /// <summary>
        /// Triggers trainer load handlers.
        /// Executes all registered trainer modification handlers.
        /// </summary>
        /// <param name="trainer">Trainer being loaded</param>
        void triggerTrainerLoad(ITrainer trainer);

        /// <summary>
        /// Gets list of registered handler names.
        /// Returns all currently registered modification handlers.
        /// </summary>
        /// <returns>Array of handler names</returns>
        string[] getRegisteredHandlers();
    }*/
}