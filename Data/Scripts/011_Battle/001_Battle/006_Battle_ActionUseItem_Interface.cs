using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining battle item usage mechanics.
    /// Handles item usage on Pokémon, item consumption, and item effects in battle.
    /// </summary>
    public interface IBattleActionUseItem : IBattle
    {
        /// <summary>
        /// Checks if an item can be used on a Pokémon.
        /// </summary>
        /// <param name="item">The item to use.</param>
        /// <param name="pkmn">The Pokémon to use the item on.</param>
        /// <param name="battler">The battler using the item.</param>
        /// <param name="scene">The battle scene for displaying messages.</param>
        /// <param name="showMessages">Whether to display messages.</param>
        /// <returns>True if the item can be used, false otherwise.</returns>
        bool CanUseItemOnPokemon(int item, IPokemon pkmn, IBattler battler, object scene, bool showMessages = true);

        /// <summary>
        /// Checks if using an item consumes all actions for the round.
        /// </summary>
        /// <param name="item">The item to check.</param>
        /// <returns>True if the item uses all actions, false otherwise.</returns>
        bool ItemUsesAllActions(int item);

        /// <summary>
        /// Registers an item usage command for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="item">The item to use.</param>
        /// <param name="idxTarget">Optional party index of the target Pokémon.</param>
        /// <param name="idxMove">Optional index of the move to recharge.</param>
        /// <returns>True if the item was registered, false otherwise.</returns>
        bool RegisterItem(int idxBattler, int item, int? idxTarget = null, int? idxMove = null);

        /// <summary>
        /// Consumes an item from the bag after use.
        /// </summary>
        /// <param name="item">The item to consume.</param>
        /// <param name="idxBattler">The battler using the item.</param>
        void ConsumeItemInBag(int item, int idxBattler);

        /// <summary>
        /// Returns an unused item to the bag.
        /// </summary>
        /// <param name="item">The item to return.</param>
        /// <param name="idxBattler">The battler who used the item.</param>
        void ReturnUnusedItemToBag(int item, int idxBattler);

        /// <summary>
        /// Displays a message when an item is used.
        /// </summary>
        /// <param name="item">The item being used.</param>
        /// <param name="trainerName">The name of the trainer using the item.</param>
        void UseItemMessage(int item, string trainerName);

        /// <summary>
        /// Uses an item on a Pokémon in the trainer's party.
        /// </summary>
        /// <param name="item">The item to use.</param>
        /// <param name="idxParty">The party index of the target Pokémon.</param>
        /// <param name="userBattler">The battler using the item.</param>
        void UseItemOnPokemon(int item, int idxParty, IBattler userBattler);

        /// <summary>
        /// Uses an item on a Pokémon in battle.
        /// </summary>
        /// <param name="item">The item to use.</param>
        /// <param name="idxParty">The party index of the target Pokémon.</param>
        /// <param name="userBattler">The battler using the item.</param>
        void UseItemOnBattler(int item, int idxParty, IBattler userBattler);

        /// <summary>
        /// Uses a Poké Ball in battle.
        /// </summary>
        /// <param name="item">The Poké Ball to use.</param>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="userBattler">The battler using the Poké Ball.</param>
        void UsePokeBallInBattle(int item, int idxBattler, IBattler userBattler);

        /// <summary>
        /// Uses an item directly in battle.
        /// </summary>
        /// <param name="item">The item to use.</param>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="userBattler">The battler using the item.</param>
        void UseItemInBattle(int item, int idxBattler, IBattler userBattler);
    }
}