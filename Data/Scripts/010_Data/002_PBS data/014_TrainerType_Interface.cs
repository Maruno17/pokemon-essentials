using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for TrainerType data, representing different types of trainers and their properties.
    /// Provides read-only access to trainer type information including money rewards, skill levels, and audio settings.
    /// </summary>
    public interface ITrainerType
    {
        /// <summary>
        /// Gets the unique identifier for this trainer type.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the real name of the trainer type as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the gender of this trainer type.
        /// 0 = Male, 1 = Female, 2 = Unknown/Mixed
        /// </summary>
        int gender { get; }

        /// <summary>
        /// Gets the base money multiplier for this trainer type.
        /// Player earns this amount times the highest level among the trainer's Pokemon.
        /// </summary>
        int base_money { get; }

        /// <summary>
        /// Gets the skill level of this trainer type.
        /// Affects AI behavior and battle difficulty.
        /// </summary>
        int skill_level { get; }

        /// <summary>
        /// Gets the default Poke Ball used by trainers of this type.
        /// </summary>
        IItem poke_ball { get; }

        /// <summary>
        /// Gets the collection of flags associated with this trainer type.
        /// Flags can be used to make trainers behave differently.
        /// </summary>
        IList<string> flags { get; }

        /// <summary>
        /// Gets the intro BGM played before battles against this trainer type.
        /// </summary>
        string intro_BGM { get; }

        /// <summary>
        /// Gets the battle BGM played during battles against this trainer type.
        /// </summary>
        string battle_BGM { get; }

        /// <summary>
        /// Gets the victory BGM played when the player wins against this trainer type.
        /// </summary>
        string victory_BGM { get; }

        /// <summary>
        /// Gets the PBS file suffix for this trainer type entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this trainer type for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated trainer type name</returns>
        string name { get; }

        /// <summary>
        /// Checks if this trainer type is male.
        /// </summary>
        /// <returns>True if the trainer type is male, false otherwise</returns>
        bool male();

        /// <summary>
        /// Checks if this trainer type is female.
        /// </summary>
        /// <returns>True if the trainer type is female, false otherwise</returns>
        bool female();

        /// <summary>
        /// Checks if this trainer type has a specific flag.
        /// </summary>
        /// <param name="flag">The flag to check for (case-insensitive)</param>
        /// <returns>True if the trainer type has the specified flag, false otherwise</returns>
        bool has_flag(string flag);

        /// <summary>
        /// Gets a property value for PBS data export.
        /// </summary>
        /// <param name="key">The property key to retrieve</param>
        /// <returns>The property value, or null if the value should be omitted</returns>
        object get_property_for_PBS(string key);

        /// <summary>
        /// Checks for a file with the given path and optional suffix.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <param name="path">The base path</param>
        /// <param name="optional_suffix">Optional suffix to try first</param>
        /// <param name="suffix">Standard suffix</param>
        /// <returns>The resolved filename, or null if not found</returns>
        string check_file(int tr_type, string path, string optional_suffix = "", string suffix = "");

        /// <summary>
        /// Gets the charset filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The charset filename</returns>
        string charset_filename(int tr_type);

        /// <summary>
        /// Gets the brief charset filename (without path) for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The brief charset filename</returns>
        string charset_filename_brief(int tr_type);

        /// <summary>
        /// Gets the front sprite filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The front sprite filename</returns>
        string front_sprite_filename(int tr_type);

        /// <summary>
        /// Gets the player front sprite filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The player front sprite filename</returns>
        string player_front_sprite_filename(int tr_type);

        /// <summary>
        /// Gets the back sprite filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The back sprite filename</returns>
        string back_sprite_filename(int tr_type);

        /// <summary>
        /// Gets the player back sprite filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The player back sprite filename</returns>
        string player_back_sprite_filename(int tr_type);

        /// <summary>
        /// Gets the map icon filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The map icon filename</returns>
        string map_icon_filename(int tr_type);

        /// <summary>
        /// Gets the player map icon filename for this trainer type.
        /// </summary>
        /// <param name="tr_type">The trainer type</param>
        /// <returns>The player map icon filename</returns>
        string player_map_icon_filename(int tr_type);
    }
}