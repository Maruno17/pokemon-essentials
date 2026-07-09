using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for trainer selection algorithms and Pokemon generation for Battle Challenges
    /// </summary>
    public interface IMainChallengeOpponentGenerator : IMain
    {
        /// <summary>
        /// Selects a trainer based on win count and available trainers
        /// Given an array of trainers and the number of wins the player already has,
        /// returns a random trainer index. The more wins, the later in the list the
        /// trainer comes from.
        /// </summary>
        /// <param name="win_count">Number of wins the player has</param>
        /// <param name="bttrainers">Array of available trainers</param>
        /// <returns>Index of selected trainer</returns>
        int BattleChallengeTrainer(int win_count, IList<object> bttrainers);

        /// <summary>
        /// Generates a complete trainer with Pokemon team for battle
        /// </summary>
        /// <param name="idxTrainer">Index of the trainer to generate</param>
        /// <param name="rules">Challenge rules to follow</param>
        /// <returns>Generated trainer with Pokemon party</returns>
        ITrainer GenerateBattleTrainer(int idxTrainer, IPokemonChallengeRules rules);

        /// <summary>
        /// Generates a full team of Pokemon for Battle Factory that obey the given rules
        /// </summary>
        /// <param name="rules">Challenge rules to follow</param>
        /// <param name="win_count">Current number of wins</param>
        /// <param name="swap_count">Number of swaps made</param>
        /// <param name="rentals">Current rental Pokemon (empty for initial generation)</param>
        /// <returns>List of generated Pokemon</returns>
        IList<IPokemon> BattleFactoryPokemon(IPokemonChallengeRules rules, int win_count, int swap_count, IList<IPokemon> rentals);
    }
}