using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining other battle actions such as shifting, calling, mega evolution, and primal reversion.
    /// </summary>
    public interface IBattleActionOther : IBattle
    {
        /// <summary>
        /// Checks if a battler can shift to another position in multi-battles.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the battler can shift, false otherwise.</returns>
        bool CanShift(int idxBattler);

        /// <summary>
        /// Registers a shift action for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the shift was registered, false otherwise.</returns>
        bool RegisterShift(int idxBattler);

        /// <summary>
        /// Registers a call action for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the call was registered, false otherwise.</returns>
        bool RegisterCall(int idxBattler);

        /// <summary>
        /// Executes a call action for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void Call(int idxBattler);

        /// <summary>
        /// Checks if a battler has a Mega Ring.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the battler has a Mega Ring, false otherwise.</returns>
        bool HasMegaRing(int idxBattler);

        /// <summary>
        /// Gets the name of the Mega Ring for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>The name of the Mega Ring.</returns>
        string GetMegaRingName(int idxBattler);

        /// <summary>
        /// Checks if a battler can Mega Evolve.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if the battler can Mega Evolve, false otherwise.</returns>
        bool CanMegaEvolve(int idxBattler);

        /// <summary>
        /// Registers a Mega Evolution for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void RegisterMegaEvolution(int idxBattler);

        /// <summary>
        /// Unregisters a Mega Evolution for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void UnregisterMegaEvolution(int idxBattler);

        /// <summary>
        /// Toggles the registration of Mega Evolution for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void ToggleRegisteredMegaEvolution(int idxBattler);

        /// <summary>
        /// Checks if a battler is registered for Mega Evolution.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if registered for Mega Evolution, false otherwise.</returns>
        bool RegisteredMegaEvolution(int idxBattler);

        /// <summary>
        /// Executes Mega Evolution for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void MegaEvolve(int idxBattler);

        /// <summary>
        /// Executes Primal Reversion for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        void PrimalReversion(int idxBattler);
    }
}