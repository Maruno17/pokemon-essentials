using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Reset exception, used to restart the game.
    /// </summary>
    public interface IReset
    {
    }

    /// <summary>
    /// Interface for event script errors that occur during map event execution.
    /// </summary>
    public interface IEventScriptError
    {
        /// <summary>
        /// Gets or sets the event-specific error message.
        /// </summary>
        string event_message { get; set; }
    }

    /// <summary>
    /// Extension interface for <see cref="IMain"/> hosting global exception and error handling functions.
    /// </summary>
    public interface IMainErrors : IMain
    {
        /// <summary>
        /// Extracts and formats an exception message for display or logging.
        /// </summary>
        /// <param name="e">The exception to get the message from.</param>
        /// <param name="_script">Optional script context information.</param>
        /// <returns>A formatted error message string.</returns>
        string pbGetExceptionMessage(Exception e, string _script = "");

        /// <summary>
        /// Prints and logs an exception with full error details and backtrace.
        /// </summary>
        /// <param name="e">The exception to print and log.</param>
        void pbPrintException(Exception e);

        /// <summary>
        /// Executes critical code with exception handling and error recovery.
        /// </summary>
        /// <param name="yield">The block of code to execute. Escape keyword <c>yield</c> with <c>@</c>.</param>
        /// <returns>
        /// Status code: 0 = exception occurred and was handled; 1 = success; 2 = Hangup occurred.
        /// </returns>
        int pbCriticalCode(Action @yield);
    }
}