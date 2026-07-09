using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon Essentials data compiler.
    /// Handles compilation of PBS (Pokemon Battle System) data files into game data.
    /// </summary>
    public interface ICompiler
    {
        /// <summary>
        /// Compiles all PBS data files into game data format.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileAll();

        /// <summary>
        /// Compiles a specific PBS data file.
        /// </summary>
        /// <param name="filename">The PBS file to compile.</param>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileFile(string filename);

        /// <summary>
        /// Gets the compilation progress as a percentage.
        /// </summary>
        /// <returns>The compilation progress (0-100).</returns>
        float getCompilationProgress();

        /// <summary>
        /// Checks if the compiler is currently running.
        /// </summary>
        /// <returns>True if compilation is in progress, false otherwise.</returns>
        bool isCompiling();

        /// <summary>
        /// Cancels the current compilation process.
        /// </summary>
        void cancelCompilation();

        /// <summary>
        /// Gets a list of compilation errors from the last run.
        /// </summary>
        /// <returns>List of error messages.</returns>
        IList<string> getCompilationErrors();

        /// <summary>
        /// Gets a list of compilation warnings from the last run.
        /// </summary>
        /// <returns>List of warning messages.</returns>
        IList<string> getCompilationWarnings();

        /// <summary>
        /// Validates PBS data without compiling.
        /// </summary>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validatePBSData();
    }

    /// <summary>
    /// Interface for PBS (Pokemon Battle System) data compilation.
    /// </summary>
    public interface IPBSCompiler : ICompiler
    {
        /// <summary>
        /// Compiles Pokemon species data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileSpeciesData();

        /// <summary>
        /// Compiles move data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileMoveData();

        /// <summary>
        /// Compiles item data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileItemData();

        /// <summary>
        /// Compiles trainer data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileTrainerData();

        /// <summary>
        /// Compiles ability data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileAbilityData();

        /// <summary>
        /// Compiles type data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileTypeData();

        /// <summary>
        /// Compiles encounter data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileEncounterData();

        /// <summary>
        /// Compiles map metadata from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileMapMetadata();

        /// <summary>
        /// Compiles town map data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileTownMapData();

        /// <summary>
        /// Compiles shadow Pokemon data from PBS files.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileShadowPokemonData();
    }

    /// <summary>
    /// Interface for writing data back to PBS files.
    /// </summary>
    public interface IPBSWriter
    {
        /// <summary>
        /// Writes all game data back to PBS files.
        /// </summary>
        /// <returns>True if writing was successful, false otherwise.</returns>
        bool writeAllPBSFiles();

        /// <summary>
        /// Writes species data to PBS files.
        /// </summary>
        /// <param name="speciesData">The species data to write.</param>
        /// <returns>True if writing was successful, false otherwise.</returns>
        bool writeSpeciesData(object speciesData);

        /// <summary>
        /// Writes move data to PBS files.
        /// </summary>
        /// <param name="moveData">The move data to write.</param>
        /// <returns>True if writing was successful, false otherwise.</returns>
        bool writeMoveData(object moveData);

        /// <summary>
        /// Writes item data to PBS files.
        /// </summary>
        /// <param name="itemData">The item data to write.</param>
        /// <returns>True if writing was successful, false otherwise.</returns>
        bool writeItemData(object itemData);

        /// <summary>
        /// Writes trainer data to PBS files.
        /// </summary>
        /// <param name="trainerData">The trainer data to write.</param>
        /// <returns>True if writing was successful, false otherwise.</returns>
        bool writeTrainerData(object trainerData);

        /// <summary>
        /// Backs up existing PBS files before overwriting.
        /// </summary>
        /// <param name="backupDirectory">The directory to store backups in.</param>
        /// <returns>True if backup was successful, false otherwise.</returns>
        bool backupPBSFiles(string backupDirectory);

        /// <summary>
        /// Restores PBS files from a backup.
        /// </summary>
        /// <param name="backupDirectory">The directory containing the backup files.</param>
        /// <returns>True if restore was successful, false otherwise.</returns>
        bool restorePBSFiles(string backupDirectory);
    }

    /// <summary>
    /// Interface for animation data compilation.
    /// </summary>
    public interface IAnimationCompiler : ICompiler
    {
        /// <summary>
        /// Compiles battle animation data.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileBattleAnimations();

        /// <summary>
        /// Compiles move animation data.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileMoveAnimations();

        /// <summary>
        /// Optimizes animation data for better performance.
        /// </summary>
        /// <returns>True if optimization was successful, false otherwise.</returns>
        bool optimizeAnimations();

        /// <summary>
        /// Validates animation data integrity.
        /// </summary>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateAnimations();

        /// <summary>
        /// Exports animations to a specific format.
        /// </summary>
        /// <param name="format">The export format.</param>
        /// <param name="outputPath">The output directory.</param>
        /// <returns>True if export was successful, false otherwise.</returns>
        bool exportAnimations(string format, string outputPath);

        /// <summary>
        /// Imports animations from external files.
        /// </summary>
        /// <param name="importPath">The path containing animations to import.</param>
        /// <returns>True if import was successful, false otherwise.</returns>
        bool importAnimations(string importPath);
    }

    /// <summary>
    /// Interface for map and event compilation.
    /// </summary>
    public interface IMapCompiler : ICompiler
    {
        /// <summary>
        /// Compiles map data and events.
        /// </summary>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileMapsAndEvents();

        /// <summary>
        /// Compiles a specific map.
        /// </summary>
        /// <param name="mapId">The ID of the map to compile.</param>
        /// <returns>True if compilation was successful, false otherwise.</returns>
        bool compileMap(int mapId);

        /// <summary>
        /// Validates map connections and warps.
        /// </summary>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateMapConnections();

        /// <summary>
        /// Optimizes map data for better loading performance.
        /// </summary>
        /// <returns>True if optimization was successful, false otherwise.</returns>
        bool optimizeMaps();

        /// <summary>
        /// Generates map preview images.
        /// </summary>
        /// <param name="outputDirectory">The directory to save preview images to.</param>
        /// <returns>True if generation was successful, false otherwise.</returns>
        bool generateMapPreviews(string outputDirectory);

        /// <summary>
        /// Exports map data to external format.
        /// </summary>
        /// <param name="mapId">The ID of the map to export.</param>
        /// <param name="format">The export format.</param>
        /// <param name="outputPath">The output file path.</param>
        /// <returns>True if export was successful, false otherwise.</returns>
        bool exportMap(int mapId, string format, string outputPath);

        /// <summary>
        /// Imports map data from external format.
        /// </summary>
        /// <param name="filePath">The path of the file to import.</param>
        /// <returns>The ID of the imported map, or -1 if failed.</returns>
        int importMap(string filePath);
    }

    /// <summary>
    /// Interface for compiler utilities and helper functions.
    /// </summary>
    public interface ICompilerUtilities
    {
        /// <summary>
        /// Checks if PBS data needs to be recompiled.
        /// </summary>
        /// <returns>True if recompilation is needed, false otherwise.</returns>
        bool needsRecompilation();

        /// <summary>
        /// Gets the last compilation timestamp.
        /// </summary>
        /// <returns>The timestamp of the last compilation.</returns>
        DateTime getLastCompilationTime();

        /// <summary>
        /// Cleans up temporary compilation files.
        /// </summary>
        void cleanupTempFiles();

        /// <summary>
        /// Gets compilation statistics.
        /// </summary>
        /// <returns>Dictionary containing compilation statistics.</returns>
        IDictionary<string, object> getCompilationStats();

        /// <summary>
        /// Sets compiler options and preferences.
        /// </summary>
        /// <param name="options">Dictionary of compiler options.</param>
        void setCompilerOptions(IDictionary<string, object> options);

        /// <summary>
        /// Gets the current compiler options.
        /// </summary>
        /// <returns>Dictionary of current compiler options.</returns>
        IDictionary<string, object> getCompilerOptions();

        /// <summary>
        /// Logs a compilation message.
        /// </summary>
        /// <param name="message">The message to log.</param>
        /// <param name="level">The log level (info, warning, error).</param>
        void logMessage(string message, string level = "info");

        /// <summary>
        /// Gets the compilation log.
        /// </summary>
        /// <returns>List of log messages from the last compilation.</returns>
        IList<string> getCompilationLog();

        /// <summary>
        /// Saves the compilation log to a file.
        /// </summary>
        /// <param name="filename">The filename to save the log to.</param>
        void saveCompilationLog(string filename);
    }

    /// <summary>
    /// Interface for data validation during compilation.
    /// </summary>
    public interface IDataValidator
    {
        /// <summary>
        /// Validates that all required data fields are present.
        /// </summary>
        /// <param name="data">The data to validate.</param>
        /// <param name="dataType">The type of data being validated.</param>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateRequiredFields(object data, string dataType);

        /// <summary>
        /// Validates data type consistency.
        /// </summary>
        /// <param name="data">The data to validate.</param>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateDataTypes(object data);

        /// <summary>
        /// Validates references between data entries.
        /// </summary>
        /// <param name="data">The data to validate.</param>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateReferences(object data);

        /// <summary>
        /// Validates data ranges and constraints.
        /// </summary>
        /// <param name="data">The data to validate.</param>
        /// <returns>True if validation passed, false otherwise.</returns>
        bool validateRanges(object data);

        /// <summary>
        /// Gets detailed validation results.
        /// </summary>
        /// <returns>Dictionary containing validation results and details.</returns>
        IDictionary<string, object> getValidationResults();

        /// <summary>
        /// Fixes common data validation issues automatically.
        /// </summary>
        /// <param name="data">The data to fix.</param>
        /// <returns>The fixed data.</returns>
        object autoFixValidationIssues(object data);
    }
}