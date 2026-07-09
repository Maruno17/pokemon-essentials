using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for writing PBS (Pokemon Battle System) files from runtime data.
    /// Handles the reverse process of compilation - converting runtime data back to PBS format.
    /// </summary>
    public interface ICompilerPBSWriter
    {
        /// <summary>
        /// Writes all runtime data back to PBS files.
        /// Converts compiled game data back to editable PBS format files.
        /// </summary>
        void WriteAllPBS();

        /// <summary>
        /// Writes Pokemon species data to pokemon.txt.
        /// Converts runtime species data back to PBS format with all species properties.
        /// </summary>
        void WritePokemonData();

        /// <summary>
        /// Writes move data to moves.txt.
        /// Converts runtime move data back to PBS format with all move properties.
        /// </summary>
        void WriteMoveData();

        /// <summary>
        /// Writes ability data to abilities.txt.
        /// Converts runtime ability data back to PBS format with all ability properties.
        /// </summary>
        void WriteAbilityData();

        /// <summary>
        /// Writes item data to items.txt.
        /// Converts runtime item data back to PBS format with all item properties.
        /// </summary>
        void WriteItemData();

        /// <summary>
        /// Writes trainer type data to trainertypes.txt.
        /// Converts runtime trainer type data back to PBS format.
        /// </summary>
        void WriteTrainerTypeData();

        /// <summary>
        /// Writes trainer data to trainers.txt.
        /// Converts runtime trainer data back to PBS format with teams and properties.
        /// </summary>
        void WriteTrainerData();

        /// <summary>
        /// Writes encounter data to encounters.txt.
        /// Converts runtime encounter data back to PBS format with area and method information.
        /// </summary>
        void WriteEncounterData();

        /// <summary>
        /// Writes regional Pokedex data to regionaldexes.txt.
        /// Converts runtime regional dex data back to PBS format.
        /// </summary>
        void WriteRegionalDexData();

        /// <summary>
        /// Writes ribbon data to ribbons.txt.
        /// Converts runtime ribbon data back to PBS format.
        /// </summary>
        void WriteRibbonData();

        /// <summary>
        /// Writes metadata files to metadata.txt.
        /// Converts runtime metadata back to PBS format with player and global settings.
        /// </summary>
        void WriteMetadata();

        /// <summary>
        /// Writes map metadata files to mapmetadata.txt.
        /// Converts runtime metadata back to PBS format with map settings.
        /// </summary>
        void WriteMapMetadata();

        void WriteDungeonTilesetData();

        void WriteDungeonParameterData();

        void WritePhoneData();
    }

    /// <summary>
    /// Interface for PBS file formatting and structure.
    /// Provides methods to format data according to PBS file conventions.
    /// </summary>
    public interface IPBSFileFormatter
    {
        /// <summary>
        /// Formats a section header for PBS files.
        /// </summary>
        /// <param name="sectionId">The section identifier.</param>
        /// <param name="sectionName">Optional section name for documentation.</param>
        /// <returns>Formatted section header string.</returns>
        string FormatSectionHeader(string sectionId, string sectionName = null);

        /// <summary>
        /// Formats a key-value pair for PBS files.
        /// </summary>
        /// <param name="key">The property key.</param>
        /// <param name="value">The property value.</param>
        /// <param name="valueType">The type of value for proper formatting.</param>
        /// <returns>Formatted key-value string.</returns>
        string FormatKeyValue(string key, object value, Type valueType);

        /// <summary>
        /// Formats a list of values as a comma-separated string.
        /// </summary>
        /// <param name="values">The list of values to format.</param>
        /// <param name="valueType">The type of values for proper formatting.</param>
        /// <returns>Formatted CSV string.</returns>
        string FormatCSVList(IList<object> values, Type valueType);

        /// <summary>
        /// Formats an ID value according to PBS conventions.
        /// </summary>
        /// <param name="id">The ID value to format.</param>
        /// <param name="idType">The type of ID (species, move, item, etc.).</param>
        /// <returns>Formatted ID string.</returns>
        string FormatID(object id, string idType);

        /// <summary>
        /// Formats a comment line for PBS files.
        /// </summary>
        /// <param name="comment">The comment text.</param>
        /// <returns>Formatted comment string with proper prefix.</returns>
        string FormatComment(string comment);

        /// <summary>
        /// Adds proper line breaks and spacing to PBS content.
        /// </summary>
        /// <param name="content">The content to format.</param>
        /// <returns>Content with proper PBS formatting.</returns>
        string FormatContent(string content);
    }

    /// <summary>
    /// Interface for PBS data conversion from runtime format.
    /// Handles conversion of complex runtime objects back to PBS-compatible data.
    /// </summary>
    public interface IPBSDataConverter
    {
        /// <summary>
        /// Converts a runtime Pokemon species object to PBS data.
        /// </summary>
        /// <param name="species">The species object to convert.</param>
        /// <returns>Dictionary containing PBS-compatible species data.</returns>
        IDictionary<string, object> ConvertSpeciesToPBS(object species);

        /// <summary>
        /// Converts a runtime move object to PBS data.
        /// </summary>
        /// <param name="move">The move object to convert.</param>
        /// <returns>Dictionary containing PBS-compatible move data.</returns>
        IDictionary<string, object> ConvertMoveToPBS(object move);

        /// <summary>
        /// Converts a runtime item object to PBS data.
        /// </summary>
        /// <param name="item">The item object to convert.</param>
        /// <returns>Dictionary containing PBS-compatible item data.</returns>
        IDictionary<string, object> ConvertItemToPBS(object item);

        /// <summary>
        /// Converts a runtime trainer object to PBS data.
        /// </summary>
        /// <param name="trainer">The trainer object to convert.</param>
        /// <returns>Dictionary containing PBS-compatible trainer data.</returns>
        IDictionary<string, object> ConvertTrainerToPBS(object trainer);

        /// <summary>
        /// Converts runtime encounter data to PBS format.
        /// </summary>
        /// <param name="encounters">The encounter data to convert.</param>
        /// <returns>Dictionary containing PBS-compatible encounter data.</returns>
        IDictionary<string, object> ConvertEncountersToPBS(object encounters);

        /// <summary>
        /// Converts complex data types to PBS-compatible strings.
        /// </summary>
        /// <param name="data">The data to convert.</param>
        /// <param name="dataType">The type of data being converted.</param>
        /// <returns>PBS-compatible string representation.</returns>
        string ConvertComplexDataToPBS(object data, string dataType);
    }

    /// <summary>
    /// Interface for PBS file output and writing operations.
    /// Handles the actual file writing with proper encoding and formatting.
    /// </summary>
    public interface IPBSFileWriter
    {
        /// <summary>
        /// Writes content to a PBS file with proper encoding and formatting.
        /// </summary>
        /// <param name="filename">The PBS file to write to.</param>
        /// <param name="content">The formatted PBS content to write.</param>
        /// <param name="encoding">The text encoding to use (defaults to UTF-8).</param>
        void WritePBSFile(string filename, string content, string encoding = "UTF-8");

        /// <summary>
        /// Creates a backup of an existing PBS file before overwriting.
        /// </summary>
        /// <param name="filename">The PBS file to backup.</param>
        /// <param name="backupPath">Optional custom backup path.</param>
        void BackupPBSFile(string filename, string backupPath = null);

        /// <summary>
        /// Validates that the written PBS file can be read back correctly.
        /// </summary>
        /// <param name="filename">The PBS file to validate.</param>
        /// <returns>True if the file is valid and readable, false otherwise.</returns>
        bool ValidateWrittenPBSFile(string filename);

        /// <summary>
        /// Generates a header comment for PBS files with timestamp and version info.
        /// </summary>
        /// <param name="fileType">The type of PBS file (pokemon, moves, etc.).</param>
        /// <returns>Formatted header comment string.</returns>
        string GeneratePBSFileHeader(string fileType);

        /// <summary>
        /// Ensures the PBS directory exists and is writable.
        /// </summary>
        /// <param name="pbsDirectory">The PBS directory path to check.</param>
        /// <returns>True if directory is accessible, false otherwise.</returns>
        bool EnsurePBSDirectoryExists(string pbsDirectory);
    }

    /// <summary>
    /// Interface for PBS export configuration and options.
    /// Provides settings for controlling how PBS files are written.
    /// </summary>
    public interface IPBSExportOptions
    {
        /// <summary>
        /// Gets or sets whether to include comments in exported PBS files.
        /// </summary>
        bool IncludeComments { get; set; }

        /// <summary>
        /// Gets or sets whether to sort sections alphabetically.
        /// </summary>
        bool SortSections { get; set; }

        /// <summary>
        /// Gets or sets whether to include default values in exports.
        /// </summary>
        bool IncludeDefaults { get; set; }

        /// <summary>
        /// Gets or sets the line ending style to use (CRLF, LF, etc.).
        /// </summary>
        string LineEnding { get; set; }

        /// <summary>
        /// Gets or sets whether to validate data before writing.
        /// </summary>
        bool ValidateBeforeWrite { get; set; }

        /// <summary>
        /// Gets or sets whether to create backup files.
        /// </summary>
        bool CreateBackups { get; set; }

        /// <summary>
        /// Gets or sets the text encoding to use for PBS files.
        /// </summary>
        string TextEncoding { get; set; }
    }
}