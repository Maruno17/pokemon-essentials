using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining the attack phase of battle, including attack phase actions, move processing, and attack phase logic.
    /// </summary>
    public interface IBattleAttackPhase : IBattle
    {
        /// <summary>
        /// Handles priority change messages for Quick Claw, Custap Berry, etc.
        /// </summary>
        void AttackPhasePriorityChangeMessages();

        /// <summary>
        /// Handles call actions during the attack phase.
        /// </summary>
        void AttackPhaseCall();

        /// <summary>
        /// Handles Pursuit move logic when a Pokémon is switching out.
        /// </summary>
        /// <param name="idxSwitcher">The index of the switching battler.</param>
        void Pursuit(int idxSwitcher);

        /// <summary>
        /// Handles switching actions during the attack phase.
        /// </summary>
        void AttackPhaseSwitch();

        /// <summary>
        /// Handles item usage during the attack phase.
        /// </summary>
        void AttackPhaseItems();

        /// <summary>
        /// Handles Mega Evolution during the attack phase.
        /// </summary>
        void AttackPhaseMegaEvolution();

        /// <summary>
        /// Handles move processing during the attack phase.
        /// </summary>
        void AttackPhaseMoves();

        /// <summary>
        /// Handles the overall attack phase logic.
        /// </summary>
        void AttackPhase();
    }
}