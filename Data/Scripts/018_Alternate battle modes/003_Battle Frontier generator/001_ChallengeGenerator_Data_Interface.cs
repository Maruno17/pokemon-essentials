using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for base stat restriction based on minimum and maximum BST
    /// </summary>
    public interface IBaseStatRestriction : IBattleRestriction
    {
        /// <summary>
        /// Initializes with BST range
        /// </summary>
        /// <param name="mn">Minimum base stat total</param>
        /// <param name="mx">Maximum base stat total</param>
        IBaseStatRestriction initialize(int mn, int mx);

        /// <summary>
        /// Validates Pokemon based on base stat total
        /// </summary>
        /// <param name="pkmn">Pokemon to validate</param>
        /// <returns>True if BST is within range, false otherwise</returns>
        bool isValid(IPokemon pkmn);
    }

    /// <summary>
    /// Interface for non-legendary Pokemon restriction
    /// </summary>
    public interface INonlegendaryRestriction : IBattleRestriction
    {
        /// <summary>
        /// Validates that Pokemon is not legendary
        /// </summary>
        /// <param name="pkmn">Pokemon to validate</param>
        /// <returns>True if not legendary, false otherwise</returns>
        bool isValid(IPokemon pkmn);
    }

    /// <summary>
    /// Interface for inverse restriction (negates another restriction)
    /// </summary>
    public interface IInverseRestriction : IBattleRestriction
    {
        /// <summary>
        /// Initializes with restriction to invert
        /// </summary>
        /// <param name="r">Restriction to invert</param>
        IInverseRestriction initialize(IBattleRestriction r);

        /// <summary>
        /// Validates by inverting the wrapped restriction
        /// </summary>
        /// <param name="pkmn">Pokemon to validate</param>
        /// <returns>Inverse of wrapped restriction result</returns>
        bool isValid(IPokemon pkmn);
    }

    /// <summary>
    /// Interface for challenge Pokemon generation utilities
    /// </summary>
    public interface IMainChallengeGeneratorData : IMain
    {
        /// <summary>
        /// Creates restriction rules with base stat and legendary parameters
        /// </summary>
        /// <param name="rule">Base rule to extend</param>
        /// <param name="minbs">Minimum base stat total</param>
        /// <param name="maxbs">Maximum base stat total</param>
        /// <param name="legendary">Legendary restriction (0=non-legendary, 1=legendary, 2=any)</param>
        /// <returns>Challenge rules with restrictions</returns>
        IPokemonChallengeRules withRestr(IPokemonChallengeRules rule, int minbs, int maxbs, int legendary);

        /// <summary>
        /// Arranges Pokemon list by tier based on base stats and position
        /// </summary>
        /// <param name="pokemonlist">List of Pokemon to arrange</param>
        /// <param name="rule">Rule to validate against</param>
        /// <returns>Tiered and sorted Pokemon list</returns>
        IList<IPokemon> pbArrangeByTier(IList<IPokemon> pokemonlist, IPokemonChallengeRules rule);

        /// <summary>
        /// Replenishes party with random Pokemon to reach target size
        /// </summary>
        /// <param name="party">Party to replenish</param>
        /// <param name="rule">Rule to generate Pokemon from</param>
        void pbReplenishBattlePokemon(IList<IPokemon> party, IPokemonChallengeRules rule);

        /// <summary>
        /// Checks if two Pokemon are considered duplicates for battle purposes
        /// </summary>
        /// <param name="pk">First Pokemon</param>
        /// <param name="pk2">Second Pokemon</param>
        /// <returns>True if considered duplicates, false otherwise</returns>
        bool isBattlePokemonDuplicate(IPokemon pk, IPokemon pk2);

        /// <summary>
        /// Removes duplicate Pokemon from a party
        /// </summary>
        /// <param name="party">Party to remove duplicates from</param>
        /// <returns>Party with duplicates removed</returns>
        IList<IPokemon> pbRemoveDuplicates(IList<IPokemon> party);
    }
}