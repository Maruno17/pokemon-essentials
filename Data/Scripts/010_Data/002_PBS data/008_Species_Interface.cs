using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Species data, representing Pokemon species and their forms.
    /// Provides read-only access to species information including stats, abilities, moves, evolution, and breeding data.
    /// </summary>
    public interface ISpecies
    {
        /// <summary>
        /// Gets the unique identifier for this species form.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the base species identifier.
        /// </summary>
        int species { get; }

        /// <summary>
        /// Gets the form number for this species.
        /// Form 0 is the base form.
        /// </summary>
        int form { get; }

        /// <summary>
        /// Gets the real name of this species as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the real form name as stored in the data files.
        /// </summary>
        string real_form_name { get; }

        /// <summary>
        /// Gets the real category (Pokemon type description) as stored in the data files.
        /// </summary>
        string real_category { get; }

        /// <summary>
        /// Gets the real Pokedex entry as stored in the data files.
        /// </summary>
        string real_pokedex_entry { get; }

        /// <summary>
        /// Gets the form number used for Pokedex entries.
        /// </summary>
        int pokedex_form { get; }

        /// <summary>
        /// Gets the collection of types for this species.
        /// </summary>
        IList<IType> types { get; }

        /// <summary>
        /// Gets the base stats for this species.
        /// Contains HP, Attack, Defense, Special Attack, Special Defense, and Speed.
        /// </summary>
        IDictionary<int, int> base_stats { get; }

        /// <summary>
        /// Gets the Effort Values (EVs) awarded when defeating this species.
        /// </summary>
        IDictionary<int, int> evs { get; }

        /// <summary>
        /// Gets the base experience points awarded when defeating this species.
        /// </summary>
        int base_exp { get; }

        /// <summary>
        /// Gets the growth rate for this species.
        /// Determines how quickly the Pokemon levels up.
        /// </summary>
        int growth_rate { get; }

        /// <summary>
        /// Gets the gender ratio for this species.
        /// Determines the likelihood of male vs female Pokemon.
        /// </summary>
        int gender_ratio { get; }

        /// <summary>
        /// Gets the catch rate for this species (0-255).
        /// Higher values make the Pokemon easier to catch.
        /// </summary>
        int catch_rate { get; }

        /// <summary>
        /// Gets the base happiness for this species (0-255).
        /// </summary>
        int happiness { get; }

        /// <summary>
        /// Gets the collection of moves this species learns by leveling up.
        /// </summary>
        IList<object> moves { get; }

        /// <summary>
        /// Gets the collection of moves this species can learn from tutors.
        /// </summary>
        IList<IMove> tutor_moves { get; }

        /// <summary>
        /// Gets the collection of moves this species can learn through breeding.
        /// </summary>
        IList<IMove> egg_moves { get; }

        /// <summary>
        /// Gets the collection of normal abilities this species can have.
        /// </summary>
        IList<IAbility> abilities { get; }

        /// <summary>
        /// Gets the collection of hidden abilities this species can have.
        /// </summary>
        IList<IAbility> hidden_abilities { get; }

        /// <summary>
        /// Gets the collection of items commonly held by wild Pokemon of this species.
        /// </summary>
        IList<IItem> wild_item_common { get; }

        /// <summary>
        /// Gets the collection of items uncommonly held by wild Pokemon of this species.
        /// </summary>
        IList<IItem> wild_item_uncommon { get; }

        /// <summary>
        /// Gets the collection of items rarely held by wild Pokemon of this species.
        /// </summary>
        IList<IItem> wild_item_rare { get; }

        /// <summary>
        /// Gets the egg groups this species belongs to for breeding purposes.
        /// </summary>
        IList<int> egg_groups { get; }

        /// <summary>
        /// Gets the number of steps required to hatch an egg of this species.
        /// </summary>
        int hatch_steps { get; }

        /// <summary>
        /// Gets the incense item needed to breed for this species.
        /// </summary>
        IItem incense { get; }

        /// <summary>
        /// Gets the collection of possible offspring species when breeding.
        /// </summary>
        IList<string> offspring { get; }

        /// <summary>
        /// Gets the evolution data for this species.
        /// </summary>
        IList<object> evolutions { get; }

        /// <summary>
        /// Gets the height of this species in decimeters (0.1 meters).
        /// </summary>
        float height { get; }

        /// <summary>
        /// Gets the weight of this species in hectograms (0.1 kilograms).
        /// </summary>
        float weight { get; }

        /// <summary>
        /// Gets the body color of this species.
        /// </summary>
        int color { get; }

        /// <summary>
        /// Gets the body shape of this species.
        /// </summary>
        int shape { get; }

        /// <summary>
        /// Gets the habitat where this species is typically found.
        /// </summary>
        int habitat { get; }

        /// <summary>
        /// Gets the generation number when this species was introduced.
        /// </summary>
        int generation { get; }

        /// <summary>
        /// Gets the collection of flags associated with this species.
        /// Flags provide additional metadata and special properties.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the Mega Stone required for Mega Evolution.
        /// </summary>
        IItem mega_stone { get; }

        /// <summary>
        /// Gets the move required for Mega Evolution.
        /// </summary>
        IMove mega_move { get; }

        /// <summary>
        /// Gets the form to revert to when Mega Evolution ends.
        /// </summary>
        int unmega_form { get; }

        /// <summary>
        /// Gets the message type for Mega Evolution.
        /// </summary>
        int mega_message { get; }

        /// <summary>
        /// Gets the PBS file suffix for this species entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this species for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated species name</returns>
        string name { get; }

        /// <summary>
        /// Gets the translated form name for display to players.
        /// </summary>
        /// <returns>The translated form name</returns>
        string form_name { get; }

        /// <summary>
        /// Gets the translated category for display to players.
        /// </summary>
        /// <returns>The translated category</returns>
        string category { get; }

        /// <summary>
        /// Gets the translated Pokedex entry for display to players.
        /// </summary>
        /// <returns>The translated Pokedex entry</returns>
        string pokedex_entry { get; }

        /// <summary>
        /// Gets the default form number for this species.
        /// </summary>
        /// <returns>The default form number, or -1 if none specified</returns>
        int default_form();

        /// <summary>
        /// Gets the base form number for this species.
        /// </summary>
        /// <returns>The base form number</returns>
        int base_form();

        /// <summary>
        /// Checks if this species is single-gendered.
        /// </summary>
        /// <returns>True if the species is single-gendered, false otherwise</returns>
        bool single_gendered();

        /// <summary>
        /// Calculates the total of all base stats.
        /// </summary>
        /// <returns>The sum of all base stats</returns>
        int base_stat_total();

        /// <summary>
        /// Checks if this species has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the species has the specified flag, false otherwise</returns>
        bool has_flag(string flag);

        /// <summary>
        /// Applies metrics to a sprite for proper positioning and scaling.
        /// </summary>
        /// <param name="sprite">The sprite to apply metrics to</param>
        /// <param name="index">The sprite index</param>
        /// <param name="shadow">Whether this is for a shadow sprite</param>
        void apply_metrics_to_sprite(ISprite sprite, int index, bool shadow = false);

        /// <summary>
        /// Checks if this species should show a shadow.
        /// </summary>
        /// <returns>True if the species should show a shadow, false otherwise</returns>
        bool shows_shadow();

        /// <summary>
        /// Gets the evolution paths for this species.
        /// </summary>
        /// <param name="exclude_invalid">Whether to exclude invalid evolutions</param>
        /// <returns>Array of evolution data</returns>
        IList<object> get_evolutions(bool exclude_invalid = false);

        /// <summary>
        /// Gets all evolution paths in this species' family.
        /// </summary>
        /// <param name="exclude_invalid">Whether to exclude invalid evolutions</param>
        /// <returns>Array of family evolution data</returns>
        IList<object> get_family_evolutions(bool exclude_invalid = true);

        /// <summary>
        /// Gets the previous species in the evolution line.
        /// </summary>
        /// <returns>The previous species ID</returns>
        int get_previous_species();

        /// <summary>
        /// Gets the baby species in the evolution family.
        /// </summary>
        /// <param name="check_items">Whether to check for incense items</param>
        /// <param name="item1">First item to check</param>
        /// <param name="item2">Second item to check</param>
        /// <returns>The baby species ID</returns>
        int get_baby_species(bool check_items = false, IItem item1 = null, IItem item2 = null);

        /// <summary>
        /// Gets all species in this evolution family.
        /// </summary>
        /// <returns>Array of species IDs in the family</returns>
        IList<int> get_family_species();

        /// <summary>
        /// Checks if breeding this species can produce another species.
        /// </summary>
        /// <param name="other_species">The species to check</param>
        /// <returns>True if breeding can produce the other species, false otherwise</returns>
        bool breeding_can_produce(int other_species);
    }
}