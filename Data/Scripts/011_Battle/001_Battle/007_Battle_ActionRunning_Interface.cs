using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining battle running mechanics.
    /// Handles fleeing from battles, trainer battle forfeits, and escape calculations.
    /// </summary>
    public interface IBattleActionRunning : IBattle
    {
        /// <summary>
        /// Checks if a battler can run from battle.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the battler can run, false otherwise.</returns>
        bool CanRun(int idxBattler);

        /// <summary>
        /// Handles debug mode battle ending options.
        /// </summary>
        /// <returns>
        /// -1: Chose not to end the battle via Debug means
        ///  0: Couldn't end the battle via Debug means; carry on trying to run
        ///  1: Ended the battle via Debug means
        /// </returns>
        int DebugRun();

        /// <summary>
        /// Attempts to run from battle.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="duringBattle">Whether this is called during battle (e.g., replacing a fainted Pokémon).</param>
        /// <returns>
        /// -1: Failed fleeing
        ///  0: Wasn't possible to attempt fleeing, continue choosing action for the round
        ///  1: Succeeded at fleeing, battle will end
        /// </returns>
        int Run(int idxBattler, bool duringBattle = false);
    }
}