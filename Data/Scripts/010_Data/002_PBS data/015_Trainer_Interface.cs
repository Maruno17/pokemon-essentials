using System;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Interface for Trainer data, representing individual trainers and their properties.
    /// Provides read-only access to trainer information including Pokemon teams, items, and battle data.
    /// </summary>
    public interface ITrainer
    {
        /// <summary>
        /// Gets the unique identifier for this trainer.
        /// </summary>
        int id { get; }

        /// <summary>
        /// Gets the trainer type for this trainer.
        /// </summary>
        ITrainerType trainer_type { get; }

        /// <summary>
        /// Gets the real name of the trainer as stored in the data files.
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the version number for this trainer.
        /// Allows multiple versions of the same trainer with different teams.
        /// </summary>
        int version { get; }

        /// <summary>
        /// Gets the collection of items this trainer carries in battle.
        /// </summary>
        IList<IItem> items { get; }

        /// <summary>
        /// Gets the real lose text for this trainer as stored in the data files.
        /// </summary>
        string real_lose_text { get; }

        /// <summary>
        /// Gets the collection of Pokemon data for this trainer's team.
        /// Contains all Pokemon information including levels, moves, and stats.
        /// </summary>
        IList<object> pokemon { get; }

        /// <summary>
        /// Gets the PBS file suffix for this trainer entry.
        /// Used for organizing and loading related data files.
        /// </summary>
        string pbs_file_suffix { get; }

        /// <summary>
        /// Gets the translated name of this trainer for display to players.
        /// This method retrieves the localized name from the message system.
        /// </summary>
        /// <returns>The translated trainer name</returns>
        string name { get; }

        /// <summary>
        /// Gets the translated lose text for this trainer for display to players.
        /// This method retrieves the localized text from the message system.
        /// </summary>
        /// <returns>The translated lose text</returns>
        string lose_text { get; }

        /// <summary>
        /// Creates a battle-ready version of this trainer's data.
        /// Converts the static trainer data into a fully functional trainer object for battles.
        /// </summary>
        /// <returns>A complete trainer object ready for battle</returns>
        object to_trainer();
    }

    /// <summary>
    /// Interface representing individual Pokemon data within a trainer's team.
    /// Defines the structure for Pokemon-specific properties that can be customized per trainer.
    /// </summary>
    public interface ITrainerPokemon
    {
        /// <summary>
        /// Gets the species of this Pokemon.
        /// </summary>
        ISpecies species { get; }

        /// <summary>
        /// Gets the level of this Pokemon.
        /// </summary>
        int level { get; }

        /// <summary>
        /// Gets the form number of this Pokemon.
        /// </summary>
        int? form { get; }

        /// <summary>
        /// Gets the real name of this Pokemon (if nicknamed).
        /// </summary>
        string real_name { get; }

        /// <summary>
        /// Gets the collection of moves this Pokemon knows.
        /// </summary>
        IList<IMove> moves { get; }

        /// <summary>
        /// Gets the specific ability this Pokemon has.
        /// </summary>
        IAbility ability { get; }

        /// <summary>
        /// Gets the ability index for this Pokemon.
        /// </summary>
        int? ability_index { get; }

        /// <summary>
        /// Gets the item this Pokemon is holding.
        /// </summary>
        IItem item { get; }

        /// <summary>
        /// Gets the gender of this Pokemon.
        /// 0 = Male, 1 = Female
        /// </summary>
        int? gender { get; }

        /// <summary>
        /// Gets the nature of this Pokemon.
        /// </summary>
        object nature { get; }

        /// <summary>
        /// Gets the Individual Values (IVs) for this Pokemon.
        /// </summary>
        IDictionary<int, int> iv { get; }

        /// <summary>
        /// Gets the Effort Values (EVs) for this Pokemon.
        /// </summary>
        IDictionary<int, int> ev { get; }

        /// <summary>
        /// Gets the happiness value for this Pokemon.
        /// </summary>
        int? happiness { get; }

        /// <summary>
        /// Gets whether this Pokemon is shiny.
        /// </summary>
        bool? shininess { get; }

        /// <summary>
        /// Gets whether this Pokemon is super shiny.
        /// </summary>
        bool? super_shininess { get; }

        /// <summary>
        /// Gets whether this Pokemon is a Shadow Pokemon.
        /// </summary>
        bool? shadowness { get; }

        /// <summary>
        /// Gets the Poke Ball this Pokemon is in.
        /// </summary>
        IItem poke_ball { get; }
    }
}