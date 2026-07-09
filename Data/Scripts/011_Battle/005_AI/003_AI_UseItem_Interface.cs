using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI logic related to using items in battle.
    /// </summary>
    public interface IBattleAIUseItemLogic :  IBattleAI
    {
        /// <summary>Determines if the AI should use an item on the current Pokémon.</summary>
        /// <returns>True if an item should be used, otherwise false.</returns>
        bool ChooseToUseItem();

        /// <summary>Chooses the item to use, the target index, and the move index (if applicable).</summary>
        /// <returns>Tuple of (item ID, target index, move index).</returns>
        //(int item, int targetIndex, int? moveIndex)? ChooseItemToUse();
        IBattleAIUseItem ChooseItemToUse();

        /// <summary>Gets the usability of an item on a Pokémon.</summary>
        /// <param name="item">The item to check.</param>
        /// <param name="partyIndex">The party index of the Pokémon.</param>
        /// <param name="side">The side index (0=player, 1=opponent).</param>
        /// <returns>Dictionary of usage types to lists of item usage details.</returns>
        IDictionary<string, IList<object>> GetUsabilityOfItemOnPokemon(object item, int partyIndex, int side);
    }

    public interface IBattleAIUseItem
    {
        int item { get; }
        int targetIndex { get; }
        int? moveIndex { get; }
    }
}