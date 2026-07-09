using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for PBS (Pokemon Battle System) file compilation.
    /// Handles compilation of structured data files containing game content definitions.
    /// </summary>
    public interface ICompilerPBS
    {
        /// <summary>
        /// Compiles all PBS files in the project.
        /// Processes all structured data files and converts them to runtime format.
        /// </summary>
        /// <remarks>
        /// text_files = get_all_pbs_files_to_compile
        /// modify_pbs_file_contents_before_compiling
        /// compile_town_map(*text_files[:TownMap][1])
        /// compile_connections(*text_files[:Connection][1])
        /// compile_types(*text_files[:Type][1])
        /// compile_abilities(*text_files[:Ability][1])
        /// compile_moves(*text_files[:Move][1])                       # Depends on Type
        /// compile_items(*text_files[:Item][1])                       # Depends on Move
        /// compile_berry_plants(*text_files[:BerryPlant][1])          # Depends on Item
        /// compile_pokemon(*text_files[:Species][1])                  # Depends on Move, Item, Type, Ability
        /// compile_pokemon_forms(*text_files[:Species1][1])           # Depends on Species, Move, Item, Type, Ability
        /// compile_pokemon_metrics(*text_files[:SpeciesMetrics][1])   # Depends on Species
        /// compile_shadow_pokemon(*text_files[:ShadowPokemon][1])     # Depends on Species
        /// compile_regional_dexes(*text_files[:RegionalDex][1])       # Depends on Species
        /// compile_ribbons(*text_files[:Ribbon][1])
        /// compile_encounters(*text_files[:Encounter][1])             # Depends on Species
        /// compile_trainer_types(*text_files[:TrainerType][1])
        /// compile_trainers(*text_files[:Trainer][1])                 # Depends on Species, Item, Move
        /// compile_trainer_lists                                      # Depends on TrainerType
        /// compile_metadata(*text_files[:Metadata][1])                # Depends on TrainerType
        /// compile_map_metadata(*text_files[:MapMetadata][1])
        /// compile_dungeon_tilesets(*text_files[:DungeonTileset][1])
        /// compile_dungeon_parameters(*text_files[:DungeonParameters][1])
        /// compile_phone(*text_files[:PhoneMessage][1])               # Depends on TrainerType
        /// </remarks>
        void CompileAllPBS();

        void CompileTownMapData();
        void CompileConnectionData();
        void CompileDungeonTilesetData();
        void CompileDungeonParameterData();
        void CompilePhoneData();

        /// <summary>
        /// Compiles Pokemon species definitions from pokemon.txt.
        /// Processes species data including stats, types, abilities, and evolution data.
        /// </summary>
        void CompilePokemonData();

        /// <summary>
        /// Compiles move definitions from moves.txt.
        /// Processes move data including power, accuracy, effects, and battle mechanics.
        /// </summary>
        void CompileMoveData();

        /// <summary>
        /// Compiles ability definitions from abilities.txt.
        /// Processes ability data including names, descriptions, and battle effects.
        /// </summary>
        void CompileAbilityData();

        /// <summary>
        /// Compiles item definitions from items.txt.
        /// Processes item data including names, descriptions, prices, and effects.
        /// </summary>
        void CompileItemData();

        /// <summary>
        /// Compiles trainer type definitions from trainertypes.txt.
        /// Processes trainer type data including names, battle music, and prizes.
        /// </summary>
        void CompileTrainerTypeData();

        /// <summary>
        /// Compiles individual trainer definitions from trainers.txt.
        /// Processes trainer data including teams, AI levels, and battle items.
        /// </summary>
        void CompileTrainerData();

        /// <summary>
        /// Compiles encounter data from encounters.txt.
        /// Processes wild Pokemon encounter tables for different areas and methods.
        /// </summary>
        void CompileEncounterData();

        /// <summary>
        /// Compiles regional Pokedex definitions from regionaldexes.txt.
        /// Processes regional Pokedex data including species lists and ordering.
        /// </summary>
        void CompileRegionalDexData();

        /// <summary>
        /// Compiles ribbon definitions from ribbons.txt.
        /// Processes ribbon data including names, descriptions, and unlock conditions.
        /// </summary>
        void CompileRibbonData();

        /// <summary>
        /// Compiles battle frontier data from various battle facility files.
        /// Processes battle facility configurations and challenges.
        /// </summary>
        void CompileBattleFrontierData();
    }

    /// <summary>
    /// Interface for PBS file parsing and data extraction.
    /// Provides methods to parse structured PBS file content.
    /// </summary>
    public interface IPBSFileParser
    {
        /// <summary>
        /// Parses a PBS file and extracts structured data.
        /// </summary>
        /// <param name="filename">The PBS file to parse.</param>
        /// <returns>Dictionary containing parsed sections and their data.</returns>
        IDictionary<string, IDictionary<string, string>> ParsePBSFile(string filename);

        /// <summary>
        /// Parses a single PBS section and validates its structure.
        /// </summary>
        /// <param name="sectionName">The name of the section being parsed.</param>
        /// <param name="sectionData">The key-value data for the section.</param>
        /// <param name="requiredFields">List of required fields for this section type.</param>
        /// <returns>Validated and processed section data.</returns>
        IDictionary<string, object> ParseSection(string sectionName, IDictionary<string, string> sectionData, IList<string> requiredFields);

        /// <summary>
        /// Parses a comma-separated value list from PBS data.
        /// </summary>
        /// <param name="csvString">The CSV string to parse.</param>
        /// <param name="expectedType">The expected type for each value (int, string, bool, etc.).</param>
        /// <returns>List of parsed values converted to the expected type.</returns>
        IList<object> ParseCSVList(string csvString, Type expectedType);

        /// <summary>
        /// Parses and validates an ID value from PBS data.
        /// </summary>
        /// <param name="idString">The ID string to parse.</param>
        /// <param name="idType">The type of ID (species, move, item, etc.).</param>
        /// <returns>The validated ID value.</returns>
        object ParseID(string idString, string idType);

        /// <summary>
        /// Validates that all required fields are present in a PBS section.
        /// </summary>
        /// <param name="sectionData">The section data to validate.</param>
        /// <param name="requiredFields">List of required field names.</param>
        /// <param name="sectionName">The section name for error reporting.</param>
        /// <returns>True if all required fields are present, false otherwise.</returns>
        bool ValidateRequiredFields(IDictionary<string, string> sectionData, IList<string> requiredFields, string sectionName);
    }

    /// <summary>
    /// Interface for PBS data validation and error checking.
    /// Provides methods to validate PBS data consistency and completeness.
    /// </summary>
    public interface IPBSDataValidator
    {
        /// <summary>
        /// Validates that all referenced IDs exist in their respective data sets.
        /// </summary>
        /// <param name="compiledData">The compiled data to validate.</param>
        /// <returns>True if all references are valid, false otherwise.</returns>
        bool ValidateReferences(IDictionary<string, object> compiledData);

        /// <summary>
        /// Validates Pokemon species data for consistency and completeness.
        /// </summary>
        /// <param name="speciesData">The species data to validate.</param>
        /// <returns>True if species data is valid, false otherwise.</returns>
        bool ValidateSpeciesData(IDictionary<string, object> speciesData);

        /// <summary>
        /// Validates move data for consistency and completeness.
        /// </summary>
        /// <param name="moveData">The move data to validate.</param>
        /// <returns>True if move data is valid, false otherwise.</returns>
        bool ValidateMoveData(IDictionary<string, object> moveData);

        /// <summary>
        /// Validates item data for consistency and completeness.
        /// </summary>
        /// <param name="itemData">The item data to validate.</param>
        /// <returns>True if item data is valid, false otherwise.</returns>
        bool ValidateItemData(IDictionary<string, object> itemData);

        /// <summary>
        /// Validates trainer data for consistency and completeness.
        /// </summary>
        /// <param name="trainerData">The trainer data to validate.</param>
        /// <returns>True if trainer data is valid, false otherwise.</returns>
        bool ValidateTrainerData(IDictionary<string, object> trainerData);

        /// <summary>
        /// Validates encounter data for consistency and completeness.
        /// </summary>
        /// <param name="encounterData">The encounter data to validate.</param>
        /// <returns>True if encounter data is valid, false otherwise.</returns>
        bool ValidateEncounterData(IDictionary<string, object> encounterData);
    }

    /// <summary>
    /// Interface for PBS compilation output and serialization.
    /// Handles the output of compiled PBS data to runtime format files.
    /// </summary>
    public interface IPBSCompilerOutput
    {
        /// <summary>
        /// Writes compiled data to the appropriate data files.
        /// </summary>
        /// <param name="dataType">The type of data being written (species, moves, etc.).</param>
        /// <param name="compiledData">The compiled data to write.</param>
        /// <param name="outputPath">The output file path.</param>
        void WriteCompiledData(string dataType, object compiledData, string outputPath);

        /// <summary>
        /// Serializes data using the appropriate format for runtime loading.
        /// </summary>
        /// <param name="data">The data to serialize.</param>
        /// <param name="format">The serialization format (marshal, json, etc.).</param>
        /// <returns>The serialized data.</returns>
        byte[] SerializeData(object data, string format);

        /// <summary>
        /// Generates metadata about the compilation process.
        /// </summary>
        /// <param name="compilationResults">Results from the compilation process.</param>
        /// <returns>Metadata containing compilation statistics and information.</returns>
        IDictionary<string, object> GenerateCompilationMetadata(IDictionary<string, object> compilationResults);

        /// <summary>
        /// Creates backup copies of existing data files before overwriting.
        /// </summary>
        /// <param name="dataFiles">List of data files to backup.</param>
        void BackupExistingData(IList<string> dataFiles);
    }
}