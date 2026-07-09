using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining the command phase of battle, including command menus, choice registration, and command phase logic.
    /// </summary>
    public interface IBattleCommandPhase : IBattle
    {
        /// <summary>
        /// Clears the choice for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void ClearChoice(int idxBattler);

        /// <summary>
        /// Cancels the choice for a battler, returning items and unregistering Mega Evolution if needed.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void CancelChoice(int idxBattler);

        /// <summary>
        /// Opens the main command menu (Fight/Pokémon/Bag/Run) for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="firstAction">Whether this is the first action of the turn.</param>
        int CommandMenu(int idxBattler, bool firstAction);

        /// <summary>
        /// Checks if commands can be shown for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if commands can be shown, false otherwise.</returns>
        bool CanShowCommands(int idxBattler);

        /// <summary>
        /// Checks if the fight menu can be shown for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the fight menu can be shown, false otherwise.</returns>
        bool CanShowFightMenu(int idxBattler);

        /// <summary>
        /// Opens the fight menu for a battler and registers the chosen move.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if a choice was made, false if cancelled.</returns>
        bool FightMenu(int idxBattler, bool megaEvoPossible = false);

        /// <summary>
        /// Handles auto-fight menu logic (e.g., Battle Palace).
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if auto-fight was handled, false otherwise.</returns>
        bool AutoFightMenu(int idxBattler);

        /// <summary>
        /// Opens the target selection menu for a move.
        /// </summary>
        /// <param name="battler">The battler using the move.</param>
        /// <param name="move">The move being used.</param>
        /// <returns>True if a target was chosen, false otherwise.</returns>
        bool ChooseTarget(IBattler battler, IMove move);

        /// <summary>
        /// Opens the item menu for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="firstAction">Whether this is the first action of the turn.</param>
        /// <returns>True if an item was chosen, false otherwise.</returns>
        bool ItemMenu(int idxBattler, bool firstAction);

        /// <summary>
        /// Opens the party menu for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if a party member was chosen, false otherwise.</returns>
        bool PartyMenu(int idxBattler);

        /// <summary>
        /// Handles the run command for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the run command was handled, false otherwise.</returns>
        bool RunMenu(int idxBattler);

        /// <summary>
        /// Handles the call command for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the call command was handled, false otherwise.</returns>
        bool CallMenu(int idxBattler);

        /// <summary>
        /// Opens the debug menu for the battle.
        /// </summary>
        void DebugMenu();

        /// <summary>
        /// Handles the command phase logic for the battle.
        /// </summary>
        void CommandPhase();

        void CommandPhaseLoop(bool isPlayer);
    }
}