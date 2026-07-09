using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Day Care egg generation module.
    /// </summary>
    /// <remarks>
    /// Code that generates an egg based on two given Pokémon.
    /// </remarks>
    public interface IDayCareEggGenerator
    {
        /// <summary>
        /// Generates an egg from two parent Pokémon.
        /// </summary>
        /// <param name="mother">The mother Pokémon</param>
        /// <param name="father">The father Pokémon</param>
        /// <returns>The generated egg Pokémon</returns>
        IPokemon generate(IPokemon mother, IPokemon father);

        /// <summary>
        /// Determines the species of the egg based on the parent species.
        /// </summary>
        /// <param name="parent_species">The parent species to base the egg on</param>
        /// <param name="mother">The mother Pokémon</param>
        /// <param name="father">The father Pokémon</param>
        /// <returns>The species ID for the egg</returns>
        IPokemon determine_egg_species(int parent_species, IPokemon mother, IPokemon father);

        /// <summary>
        /// Generates a basic egg Pokémon of the specified species.
        /// </summary>
        /// <param name="species">The species of the egg</param>
        /// <returns>The basic egg Pokémon</returns>
        IPokemon generate_basic_egg(int species);

        /// <summary>
        /// Inherits form from parents based on breeding rules.
        /// </summary>
        /// <param name="egg">The egg to modify</param>
        /// <param name="species_parent">The parent that determined the species</param>
        /// <param name="mother">Mother data array [pokemon, is_ditto, can_produce_species]</param>
        /// <param name="father">Father data array [pokemon, is_ditto, can_produce_species]</param>
        void inherit_form(IPokemon egg, IPokemon species_parent, object[] mother, object[] father);

        /// <summary>
        /// Gets the list of moves to inherit from parents.
        /// </summary>
        /// <param name="egg">The egg Pokémon</param>
        /// <param name="mother">Mother data array [pokemon, is_ditto, can_produce_species]</param>
        /// <param name="father">Father data array [pokemon, is_ditto, can_produce_species]</param>
        /// <returns>List of moves to inherit</returns>
        IList<object> get_moves_to_inherit(IPokemon egg, object[] mother, object[] father);

        /// <summary>
        /// Inherits moves from parents.
        /// </summary>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">Mother data array [pokemon, is_ditto, can_produce_species]</param>
        /// <param name="father">Father data array [pokemon, is_ditto, can_produce_species]</param>
        void inherit_moves(IPokemon egg, object[] mother, object[] father);

        /// <summary>
        /// Inherits nature from parents with Ever Stones.
        /// </summary>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">The mother Pokémon</param>
        /// <param name="father">The father Pokémon</param>
        void inherit_nature(IPokemon egg, IPokemon mother, IPokemon father);

        /// <summary>
        /// Inherits ability from the female or non-Ditto parent.
        /// </summary>
        /// <remarks>
        /// The female parent (or the non-Ditto parent) can pass down its Hidden
        /// Ability (60% chance) or its regular ability (80% chance).
        /// NOTE: This is how ability inheritance works in Gen 6+. Gen 5 is more
        ///       restrictive, and even works differently between BW and B2W2, and I
        ///       don't think that is worth adding in. Gen 4 and lower don't have
        ///       ability inheritance at all, and again, I'm not bothering to add that
        ///       in.
        /// </remarks>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">Mother data array [pokemon, is_ditto, can_produce_species]</param>
        /// <param name="father">Father data array [pokemon, is_ditto, can_produce_species]</param>
        void inherit_ability(IPokemon egg, object[] mother, object[] father);

        /// <summary>
        /// Inherits IVs from parents based on items and random selection.
        /// </summary>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">The mother Pokémon</param>
        /// <param name="father">The father Pokémon</param>
        void inherit_IVs(IPokemon egg, IPokemon mother, IPokemon father);

        /// <summary>
        /// Inherits Poké Ball from related parents.
        /// </summary>
        /// <remarks>
        /// Poké Balls can only be inherited from parents that are related to the
        /// egg's species.
        /// NOTE: This is how Poké Ball inheritance works in Gen 7+. Gens 5 and lower
        ///       don't have Poké Ball inheritance at all. In Gen 6, only a female
        ///       parent can pass down its Poké Ball. I don't think it's worth adding
        ///       in these variations on the mechanic.
        /// NOTE: The official games treat Nidoran M/F and Volbeat/Illumise as
        ///       unrelated for the purpose of this mechanic. Essentials treats them
        ///       as related and allows them to pass down their Poké Balls.
        /// </remarks>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">Mother data array [pokemon, is_ditto, can_produce_species]</param>
        /// <param name="father">Father data array [pokemon, is_ditto, can_produce_species]</param>
        void inherit_poke_ball(IPokemon egg, object[] mother, object[] father);

        /// <summary>
        /// Sets shininess using Masuda Method and Shiny Charm.
        /// </summary>
        /// <remarks>
        /// NOTE: There is a bug in Gen 8 that skips the original generation of an
        ///       egg's personal ID if the Masuda Method/Shiny Charm can cause any
        ///       rerolls. Essentials doesn't have this bug, meaning eggs are slightly
        ///       more likely to be shiny (in Gen 8+ mechanics) than in Gen 8 itself.
        /// </remarks>
        /// <param name="egg">The egg to modify</param>
        /// <param name="mother">The mother Pokémon</param>
        /// <param name="father">The father Pokémon</param>
        void set_shininess(IPokemon egg, IPokemon mother, IPokemon father);

        /// <summary>
        /// Sets Pokérus infection for the egg.
        /// </summary>
        /// <param name="egg">The egg to modify</param>
        void set_pokerus(IPokemon egg);
    }

    /// <summary>
    /// Interface for a slot in the Day Care that can contain a Pokémon.
    /// </summary>
    public interface IDayCareSlot
    {
        /// <summary>
        /// Gets the Pokémon in this slot.
        /// </summary>
        IPokemon pokemon { get; }

        /// <summary>
        /// Resets the slot to empty state.
        /// </summary>
        void reset();

        /// <summary>
        /// Deposits a Pokémon in this slot.
        /// </summary>
        /// <param name="pkmn">The Pokémon to deposit</param>
        void deposit(IPokemon pkmn);

        /// <summary>
        /// Checks if this slot contains a Pokémon.
        /// </summary>
        /// <returns>True if filled</returns>
        bool filled();

        /// <summary>
        /// Gets the name of the Pokémon in this slot.
        /// </summary>
        /// <returns>Pokémon name or empty string</returns>
        string pokemon_name();

        /// <summary>
        /// Gets the number of levels gained since deposit.
        /// </summary>
        /// <returns>Level gain</returns>
        int level_gain();

        /// <summary>
        /// Gets the cost to withdraw the Pokémon.
        /// </summary>
        /// <returns>Withdrawal cost</returns>
        int cost();

        /// <summary>
        /// Gets the choice text for selection menus.
        /// </summary>
        /// <returns>Choice text or null if empty</returns>
        string choice_text();

        /// <summary>
        /// Adds experience to the Pokémon in this slot.
        /// </summary>
        /// <param name="amount">Amount of experience to add</param>
        void add_exp(int amount = 1);
    }

    /// <summary>
    /// Interface for the Day Care facility.
    /// </summary>
    /// <remarks>
    /// NOTE: In Gen 7+, the Day Care is replaced by the Pokémon Nursery, which works
    ///       in much the same way except deposited Pokémon no longer gain Exp because
    ///       of the player walking around and, in Gen 8+, deposited Pokémon are able
    ///       to learn egg moves from each other if they are the same species. In
    ///       Essentials, this code can be used for both facilities, and these
    ///       mechanics differences are set by some Settings.
    /// NOTE: The Day Care has a different price than the Pokémon Nursery. For the Day
    ///       Care, you are charged when you withdraw a deposited Pokémon and you pay
    ///       an amount based on how many levels it gained. For the Nursery, you pay
    ///       $500 up-front when you deposit a Pokémon. This difference will appear in
    ///       the Day Care Lady's event, not in these scripts.
    /// </remarks>
    public interface IDayCare
    {
        /// <summary>
        /// Gets the Day Care slots.
        /// </summary>
        IDayCareSlot[] slots { get; }

        /// <summary>
        /// Gets or sets whether an egg has been generated.
        /// </summary>
        bool egg_generated { get; set; }

        /// <summary>
        /// Gets or sets the step counter for egg generation.
        /// </summary>
        int step_counter { get; set; }

        /// <summary>
        /// Gets or sets whether deposited Pokémon gain experience from walking.
        /// </summary>
        bool gain_exp { get; set; }

        /// <summary>
        /// Gets or sets whether deposited Pokémon can share egg moves.
        /// </summary>
        /// <remarks>
        /// For deposited Pokémon of the same species
        /// </remarks>
        bool share_egg_moves { get; set; }

        /// <summary>
        /// Maximum number of slots in the Day Care.
        /// </summary>
        int MAX_SLOTS { get; }

        /// <summary>
        /// Gets a slot by index.
        /// </summary>
        /// <param name="index">The slot index</param>
        /// <returns>The Day Care slot</returns>
        IDayCareSlot this[int index] { get; }

        /// <summary>
        /// Resets the egg generation counters.
        /// </summary>
        void reset_egg_counters();

        /// <summary>
        /// Gets the number of filled slots.
        /// </summary>
        /// <returns>Number of Pokémon in Day Care</returns>
        int count();

        /// <summary>
        /// Gets the compatibility rating of the two deposited Pokémon.
        /// </summary>
        /// <returns>Compatibility rating (0-3)</returns>
        int get_compatibility();

        /// <summary>
        /// Generates an egg from the two deposited Pokémon.
        /// </summary>
        /// <returns>The generated egg or null if not possible</returns>
        IPokemon generate_egg();

        /// <summary>
        /// Shares an egg move between two deposited Pokémon of the same species.
        /// </summary>
        void share_egg_move();

        /// <summary>
        /// Updates the Day Care when a step is taken.
        /// </summary>
        void update_on_step_taken();
    }

    /// <summary>
    /// Interface for Day Care static methods and utilities.
    /// </summary>
    public interface IDayCareUtils
    {
        /// <summary>
        /// Gets the number of Pokémon in the Day Care.
        /// </summary>
        /// <returns>Number of deposited Pokémon</returns>
        int count();

        /// <summary>
        /// Checks if an egg has been generated.
        /// </summary>
        /// <returns>True if an egg is available</returns>
        bool egg_generated();

        /// <summary>
        /// Resets the egg generation counters.
        /// </summary>
        void reset_egg_counters();

        /// <summary>
        /// Gets details about a deposited Pokémon.
        /// </summary>
        /// <param name="index">The slot index</param>
        /// <param name="name_var">Variable to store the Pokémon name</param>
        /// <param name="cost_var">Variable to store the withdrawal cost</param>
        void get_details(int index, int name_var, int cost_var);

        /// <summary>
        /// Gets level gain information for a deposited Pokémon.
        /// </summary>
        /// <param name="index">The slot index</param>
        /// <param name="name_var">Variable to store the Pokémon name</param>
        /// <param name="level_var">Variable to store the level gain</param>
        void get_level_gain(int index, int name_var, int level_var);

        /// <summary>
        /// Gets the compatibility rating of deposited Pokémon.
        /// </summary>
        /// <param name="compat_var">Variable to store the compatibility rating</param>
        void get_compatibility(int compat_var);

        /// <summary>
        /// Deposits a Pokémon from the party into the Day Care.
        /// </summary>
        /// <param name="party_index">Index of the Pokémon in the party</param>
        void deposit(int party_index);

        /// <summary>
        /// Withdraws a Pokémon from the Day Care to the party.
        /// </summary>
        /// <param name="index">The slot index to withdraw from</param>
        void withdraw(int index);

        /// <summary>
        /// Shows a choice menu to select a deposited Pokémon.
        /// </summary>
        /// <param name="message">The message to display</param>
        /// <param name="choice_var">Variable to store the chosen slot index</param>
        void choose(string message, int choice_var);

        /// <summary>
        /// Collects the generated egg and adds it to the party.
        /// </summary>
        void collect_egg();
    }

    public interface IMainOverworldDayCare : IMain
    {
        /// <summary>
        /// With each step taken, add Exp to Pokémon in the Day Care and try to generate
        /// an egg.
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_player_step_taken, :update_day_care,
        ///   proc {
        ///     $PokemonGlobal.day_care.update_on_step_taken
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnPlayerStepTaken"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        void OnPlayerStepTaken_update_day_care();
    }
}