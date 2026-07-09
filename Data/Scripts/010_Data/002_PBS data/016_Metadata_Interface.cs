using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Metadata data, representing global game metadata and settings.
    /// Provides read-only access to game-wide configuration including starting values, audio settings, and locations.
    /// </summary>
    public interface IMetadata
    {
        /// <summary>
        /// Gets the unique identifier for this metadata entry.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the amount of money the player starts the game with.
        /// </summary>
        int start_money { get; }

        /// <summary>
        /// Gets the collection of items that are already in the player's PC at the start of the game.
        /// </summary>
        IList<IItem> start_item_storage { get; }

        /// <summary>
        /// Gets the home location coordinates.
        /// Contains map ID and X/Y coordinates where the player goes after a loss if no Pokemon Center was visited.
        /// </summary>
        int[] home { get; }

        /// <summary>
        /// Gets the real name of the Pokemon Storage creator as stored in the data files.
        /// The storage option is named "XXX's PC".
        /// </summary>
        string real_storage_creator { get; }

        /// <summary>
        /// Gets the default BGM for wild Pokemon battles.
        /// </summary>
        string wild_battle_BGM { get; }

        /// <summary>
        /// Gets the default BGM for trainer battles.
        /// </summary>
        string trainer_battle_BGM { get; }

        /// <summary>
        /// Gets the default BGM played after winning a wild Pokemon battle.
        /// </summary>
        string wild_victory_BGM { get; }

        /// <summary>
        /// Gets the default BGM played after winning a trainer battle.
        /// </summary>
        string trainer_victory_BGM { get; }

        /// <summary>
        /// Gets the default ME played after catching a Pokemon.
        /// </summary>
        string wild_capture_ME { get; }

        /// <summary>
        /// Gets the BGM played while surfing.
        /// </summary>
        string surf_BGM { get; }

        /// <summary>
        /// Gets the BGM played while on a bicycle.
        /// </summary>
        string bicycle_BGM { get; }

        /// <summary>
        /// Gets the PBS file suffix for this metadata entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of the Pokemon Storage creator for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated storage creator name</returns>
        string storage_creator { get; }
    }
}