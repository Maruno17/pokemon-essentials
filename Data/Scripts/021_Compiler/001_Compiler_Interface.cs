using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for file line data tracking during compilation.
    /// Records the current file, line, and section being processed for error reporting.
    /// </summary>
    public interface IFileLineData
    {
        /// <summary>
        /// Gets or sets the current file being processed.
        /// </summary>
        string file { get; set; }

        /// <summary>
        /// Gets the current line data being processed.
        /// </summary>
        string linedata { get; }

        /// <summary>
        /// Gets the current line number being processed.
        /// </summary>
        int lineno { get; }

        /// <summary>
        /// Gets the current section being processed.
        /// </summary>
        string section { get; }

        /// <summary>
        /// Gets the current key being processed.
        /// </summary>
        string key { get; }

        /// <summary>
        /// Gets the current value being processed.
        /// </summary>
        string value { get; }

        /// <summary>
        /// Clears all file line data tracking information.
        /// Resets file, line, section, key, and value to default states.
        /// </summary>
        void clear();

        /// <summary>
        /// Sets the current section, key, and value being processed.
        /// Used when processing structured data files with sections and key-value pairs.
        /// </summary>
        /// <param name="sectionName">The section name being processed.</param>
        /// <param name="keyName">The key name being processed.</param>
        /// <param name="valueName">The value being processed (truncated if over 200 characters).</param>
        void setSection(string sectionName, string keyName, string valueName);

        /// <summary>
        /// Sets the current line and line number being processed.
        /// Used when processing line-by-line text files.
        /// </summary>
        /// <param name="line">The line content being processed (truncated if over 200 characters).</param>
        /// <param name="lineNumber">The line number being processed.</param>
        void setLine(string line, int lineNumber);

        /// <summary>
        /// Generates a formatted error report with current file, line, and section information.
        /// Provides context for where an error occurred during compilation.
        /// </summary>
        /// <returns>A formatted string containing file location and context information.</returns>
        string linereport();
    }

    /// <summary>
    /// Interface for the main compiler system.
    /// Handles compilation of game data files and scripts.
    /// </summary>
    public interface ICompiler
    {
        /// <summary>
        /// Processes each prepared line from a file with error handling and line tracking.
        /// Handles comment removal, empty line skipping, and error context tracking.
        /// </summary>
        /// <param name="filename">The file to process.</param>
        /// <param name="lineProcessor">Action to process each valid line with line number.</param>
        /// <remarks>Unused</remarks>
        [System.Obsolete("Unused")]
        void CompilerEachPreppedLine(string filename, Action<string, int> lineProcessor);

        /// <summary>
        /// Processes each section from a structured data file.
        /// Handles PBS-style files with [SectionName] headers and key=value pairs.
        /// </summary>
        /// <param name="filename">The file to process.</param>
        /// <param name="sectionProcessor">Action to process each section with its data.</param>
        void CompilerEachSection(string filename, Action<string, IDictionary<string, string>> sectionProcessor);

        /// <summary>
        /// Compiles all game data files in the PBS directory.
        /// Processes Pokemon data, moves, abilities, items, maps, and other game content.
        /// </summary>
        void CompileAll();

        /// <summary>
        /// Compiles Pokemon species data from PBS files.
        /// </summary>
        void CompilePokemon();

        /// <summary>
        /// Compiles move data from PBS files.
        /// </summary>
        void CompileMoves();

        /// <summary>
        /// Compiles ability data from PBS files.
        /// </summary>
        void CompileAbilities();

        /// <summary>
        /// Compiles item data from PBS files.
        /// </summary>
        void CompileItems();

        /// <summary>
        /// Compiles trainer type data from PBS files.
        /// </summary>
        void CompileTrainerTypes();

        /// <summary>
        /// Compiles trainer data from PBS files.
        /// </summary>
        void CompileTrainers();

        /// <summary>
        /// Compiles map data and metadata from map files.
        /// </summary>
        void CompileMaps();

        /// <summary>
        /// Compiles encounter data from PBS files.
        /// </summary>
        void CompileEncounters();

        /// <summary>
        /// Compiles battle animation data.
        /// </summary>
        void CompileAnimations();

        /// <summary>
        /// Validates that required data files exist and are properly formatted.
        /// </summary>
        /// <returns>True if all required files are valid, false otherwise.</returns>
        bool ValidateCompiledData();

        /// <summary>
        /// Gets the last compilation time for tracking file changes.
        /// </summary>
        /// <returns>The DateTime when compilation was last performed.</returns>
        DateTime GetLastCompilationTime();

        /// <summary>
        /// Checks if recompilation is needed based on file modification times.
        /// </summary>
        /// <returns>True if any source files have been modified since last compilation.</returns>
        bool NeedsRecompilation();
    }

    /// <summary>
    /// Interface for compilation error handling and reporting.
    /// Provides methods to handle and report compilation errors with context.
    /// </summary>
    public interface ICompilerErrorHandler
    {
        /// <summary>
        /// Reports a compilation error with file context information.
        /// </summary>
        /// <param name="message">The error message to report.</param>
        /// <param name="filename">The file where the error occurred.</param>
        /// <param name="lineNumber">The line number where the error occurred.</param>
        void ReportError(string message, string filename = null, int? lineNumber = null);

        /// <summary>
        /// Reports a warning during compilation.
        /// </summary>
        /// <param name="message">The warning message to report.</param>
        /// <param name="filename">The file where the warning occurred.</param>
        /// <param name="lineNumber">The line number where the warning occurred.</param>
        void ReportWarning(string message, string filename = null, int? lineNumber = null);

        /// <summary>
        /// Validates data format and reports errors if invalid.
        /// </summary>
        /// <param name="data">The data to validate.</param>
        /// <param name="expectedFormat">Description of the expected format.</param>
        /// <param name="context">Context information for error reporting.</param>
        /// <returns>True if data is valid, false otherwise.</returns>
        bool ValidateDataFormat(object data, string expectedFormat, string context);
    }

    /// <summary>
    /// Interface for compilation progress tracking and reporting.
    /// Provides methods to track and report compilation progress.
    /// </summary>
    public interface ICompilerProgressTracker
    {
        /// <summary>
        /// Reports the start of a compilation phase.
        /// </summary>
        /// <param name="phaseName">The name of the compilation phase starting.</param>
        /// <param name="totalItems">The total number of items to process in this phase.</param>
        void StartPhase(string phaseName, int totalItems);

        /// <summary>
        /// Reports progress within the current compilation phase.
        /// </summary>
        /// <param name="itemsProcessed">The number of items processed so far.</param>
        /// <param name="currentItem">The name of the current item being processed.</param>
        void ReportProgress(int itemsProcessed, string currentItem = null);

        /// <summary>
        /// Reports the completion of the current compilation phase.
        /// </summary>
        /// <param name="success">Whether the phase completed successfully.</param>
        void CompletePhase(bool success);

        /// <summary>
        /// Gets the current compilation progress as a percentage.
        /// </summary>
        /// <returns>The completion percentage (0-100).</returns>
        int GetProgressPercentage();
    }
}