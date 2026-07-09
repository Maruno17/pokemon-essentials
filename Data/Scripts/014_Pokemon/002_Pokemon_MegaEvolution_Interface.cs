using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Pokemon mega evolution and primal reversion functionality.
    /// Provides methods for managing mega evolution states and form changes.
    /// </summary>
    /// <remarks>
    /// NOTE: These are treated as form changes in Essentials.
    /// </remarks>
    public interface IPokemonMegaEvolution
    {
        /// <summary>
        /// Gets the mega evolution form number for this Pokemon.
        /// Checks if the Pokemon has the required mega stone or move.
        /// </summary>
        /// <returns>The mega form number, or 0 if no accessible mega form exists.</returns>
        int getMegaForm();

        /// <summary>
        /// Gets the base form number that this Pokemon reverts to when un-mega evolving.
        /// </summary>
        /// <returns>The unmega form number, or -1 if this Pokemon is not currently mega evolved.</returns>
        int getUnmegaForm();

        /// <summary>
        /// Determines if this Pokemon has an accessible mega evolution form.
        /// </summary>
        /// <returns>True if the Pokemon can mega evolve, false otherwise.</returns>
        bool hasMegaForm();

        /// <summary>
        /// Determines if this Pokemon is currently in a mega evolved state.
        /// </summary>
        /// <returns>True if the Pokemon is mega evolved, false otherwise.</returns>
        bool mega();

        /// <summary>
        /// Mega evolves this Pokemon if it has an accessible mega form.
        /// </summary>
        void makeMega();

        /// <summary>
        /// Reverts this Pokemon from its mega evolved form to its base form.
        /// </summary>
        void makeUnmega();

        /// <summary>
        /// Gets the display name for this Pokemon's mega evolved form.
        /// </summary>
        /// <returns>The mega form name, or a default "Mega [species]" format.</returns>
        string megaName();

        /// <summary>
        /// Gets the message type to display when mega evolving.
        /// </summary>
        /// <returns>0 for default message, 1 for Rayquaza message, or other custom message numbers.</returns>
        int megaMessage();

        /// <summary>
        /// Determines if this Pokemon has an accessible primal reversion form.
        /// </summary>
        /// <remarks>
        /// NOTE: These are treated as form changes in Essentials.
        /// </remarks>
        /// <returns>True if the Pokemon can undergo primal reversion, false otherwise.</returns>
        bool hasPrimalForm();

        /// <summary>
        /// Determines if this Pokemon is currently in a primal reverted state.
        /// </summary>
        /// <returns>True if the Pokemon is primal reverted, false otherwise.</returns>
        bool primal();

        /// <summary>
        /// Performs primal reversion on this Pokemon if it has an accessible primal form.
        /// </summary>
        void makePrimal();

        /// <summary>
        /// Reverts this Pokemon from its primal form to its base form.
        /// </summary>
        void makeUnprimal();
    }
}