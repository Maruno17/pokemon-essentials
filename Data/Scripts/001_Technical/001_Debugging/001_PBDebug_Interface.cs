using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for application error handling and logging within the debug module.
    /// </summary>
    public interface IPBDebug : IDebugger
    {
        /// <summary>
        /// Executes a block of code, rescuing any exceptions and logging them.
        /// </summary>
        /// <param name="yield">The action block to execute.</param>
        void logonerr(Action yield);

        /// <summary>
        /// Flushes the log buffer to the debug log file if in debug and internal mode.
        /// </summary>
        void flush();

        /// <summary>
        /// Logs a standard debug message.
        /// </summary>
        /// <param name="msg">The message to log.</param>
        void log(string msg);

        /// <summary>
        /// Logs a header message, styled differently in the console.
        /// </summary>
        /// <param name="msg">The header message to log.</param>
        void log_header(string msg);

        /// <summary>
        /// Logs a detailed message, styled differently in the console.
        /// </summary>
        /// <param name="msg">The message to log.</param>
        void log_message(string msg);

        /// <summary>
        /// Logs an AI-specific debug message.
        /// </summary>
        /// <param name="msg">The AI message to log.</param>
        void log_ai(string msg);

        /// <summary>
        /// Logs an AI scoring adjustment message.
        /// </summary>
        /// <param name="amt">The score change amount (e.g. +10, -5).</param>
        /// <param name="msg">Description of why the score changed.</param>
        void log_score_change(int amt, string msg);

        /// <summary>
        /// Dumps the message immediately to a dumplog file if in debug and internal mode.
        /// </summary>
        /// <param name="msg">The message to dump.</param>
        void dump(string msg);
    }
}