using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for map and event compilation system.
    /// Handles compilation of map data, events, and metadata from source files to runtime format.
    /// </summary>
    public interface ICompilerMapEvent
    {
        /// <summary>
        /// Compiles all maps and their associated event data.
        /// Processes map files, event scripts, and metadata for runtime use.
        /// </summary>
        void CompileAllMapsAndEvents();

        /// <summary>
        /// Compiles individual map data from map files.
        /// Processes map tiles, properties, and basic structure.
        /// </summary>
        void CompileMapData();

        /// <summary>
        /// Compiles event data for all maps.
        /// Processes event scripts, conditions, and interactions.
        /// </summary>
        void CompileEventData();

        /// <summary>
        /// Compiles map metadata and properties.
        /// Processes map settings, connections, and special properties.
        /// </summary>
        void CompileMapMetadata();

        /// <summary>
        /// Compiles common event data that applies across multiple maps.
        /// Processes shared events and global event scripts.
        /// </summary>
        void CompileCommonEvents();

        /// <summary>
        /// Compiles map connection data for seamless transitions.
        /// Processes connections between different map areas.
        /// </summary>
        void CompileMapConnections();

        /// <summary>
        /// Validates all compiled map and event data for consistency.
        /// </summary>
        /// <returns>True if all map and event data is valid, false otherwise.</returns>
        bool ValidateMapsAndEvents();

        /// <summary>
        /// Gets compilation statistics for map and event processing.
        /// </summary>
        /// <returns>Dictionary containing compilation statistics.</returns>
        IDictionary<string, object> GetCompilationStats();
    }

    /// <summary>
    /// Interface for map data parsing and processing.
    /// Handles parsing of RPG Maker map files and related data.
    /// </summary>
    public interface IMapDataParser
    {
        /// <summary>
        /// Parses a map file and extracts map structure and tile data.
        /// </summary>
        /// <param name="mapFilename">The map file to parse (.rxdata format).</param>
        /// <returns>Parsed map data structure containing tiles, events, and properties.</returns>
        IDictionary<string, object> ParseMapFile(string mapFilename);

        /// <summary>
        /// Parses tileset data and tile properties.
        /// </summary>
        /// <param name="tilesetData">The tileset data to parse.</param>
        /// <returns>Processed tileset information with tile properties.</returns>
        IDictionary<string, object> ParseTilesetData(object tilesetData);

        /// <summary>
        /// Parses map events and their script commands.
        /// </summary>
        /// <param name="eventData">The event data to parse.</param>
        /// <returns>Processed event information with script commands.</returns>
        IList<object> ParseMapEvents(object eventData);

        /// <summary>
        /// Parses event command scripts and converts them to runtime format.
        /// </summary>
        /// <param name="commands">The event commands to parse.</param>
        /// <returns>Converted event script commands.</returns>
        IList<object> ParseEventCommands(IList<object> commands);

        /// <summary>
        /// Validates map data structure and integrity.
        /// </summary>
        /// <param name="mapData">The map data to validate.</param>
        /// <param name="mapId">The map ID for error reporting.</param>
        /// <returns>True if map data is valid, false otherwise.</returns>
        bool ValidateMapData(IDictionary<string, object> mapData, int mapId);
    }

    /// <summary>
    /// Interface for event script processing and compilation.
    /// Handles conversion of event scripts to optimized runtime format.
    /// </summary>
    public interface IEventScriptProcessor
    {
        /// <summary>
        /// Processes event script commands for runtime execution.
        /// Optimizes and validates event script command sequences.
        /// </summary>
        /// <param name="commands">The event commands to process.</param>
        /// <param name="eventId">The event ID for error reporting.</param>
        /// <returns>Processed and optimized event commands.</returns>
        IList<object> ProcessEventCommands(IList<object> commands, int eventId);

        /// <summary>
        /// Optimizes conditional branches and flow control in events.
        /// </summary>
        /// <param name="commands">The event commands to optimize.</param>
        /// <returns>Optimized command sequence.</returns>
        IList<object> OptimizeConditionalFlow(IList<object> commands);

        /// <summary>
        /// Validates event script syntax and command parameters.
        /// </summary>
        /// <param name="commands">The event commands to validate.</param>
        /// <param name="eventContext">Context information for error reporting.</param>
        /// <returns>True if event script is valid, false otherwise.</returns>
        bool ValidateEventScript(IList<object> commands, string eventContext);

        /// <summary>
        /// Converts event script references to use compiled data IDs.
        /// </summary>
        /// <param name="commands">The event commands to convert.</param>
        /// <param name="compiledData">The compiled game data for reference lookup.</param>
        /// <returns>Commands with converted references.</returns>
        IList<object> ConvertScriptReferences(IList<object> commands, IDictionary<string, object> compiledData);

        /// <summary>
        /// Processes custom script calls within events.
        /// </summary>
        /// <param name="scriptCall">The script call to process.</param>
        /// <returns>Processed script call data.</returns>
        object ProcessCustomScriptCall(string scriptCall);
    }

    /// <summary>
    /// Interface for map metadata compilation and management.
    /// Handles processing of map properties, connections, and special settings.
    /// </summary>
    public interface IMapMetadataProcessor
    {
        /// <summary>
        /// Processes map metadata from metadata files.
        /// Parses and validates map properties and settings.
        /// </summary>
        /// <param name="metadataFile">The metadata file to process.</param>
        /// <returns>Processed map metadata indexed by map ID.</returns>
        IDictionary<int, IDictionary<string, object>> ProcessMapMetadata(string metadataFile);

        /// <summary>
        /// Processes map connection data for seamless area transitions.
        /// </summary>
        /// <param name="connectionData">The connection data to process.</param>
        /// <returns>Processed connection information.</returns>
        IDictionary<string, object> ProcessMapConnections(object connectionData);

        /// <summary>
        /// Processes encounter area data for wild Pokemon.
        /// </summary>
        /// <param name="encounterData">The encounter data to process.</param>
        /// <returns>Processed encounter area information.</returns>
        IDictionary<string, object> ProcessEncounterAreas(object encounterData);

        /// <summary>
        /// Validates map metadata consistency and completeness.
        /// </summary>
        /// <param name="metadata">The metadata to validate.</param>
        /// <returns>True if metadata is valid, false otherwise.</returns>
        bool ValidateMapMetadata(IDictionary<int, IDictionary<string, object>> metadata);

        /// <summary>
        /// Generates default metadata for maps that don't have custom settings.
        /// </summary>
        /// <param name="mapId">The map ID to generate defaults for.</param>
        /// <returns>Default metadata settings for the map.</returns>
        IDictionary<string, object> GenerateDefaultMetadata(int mapId);
    }

    /// <summary>
    /// Interface for map and event data output and serialization.
    /// Handles writing compiled map and event data to runtime format files.
    /// </summary>
    public interface IMapEventCompilerOutput
    {
        /// <summary>
        /// Writes compiled map data to output files.
        /// </summary>
        /// <param name="mapData">The compiled map data to write.</param>
        /// <param name="outputDirectory">The directory to write map files to.</param>
        void WriteMapData(IDictionary<int, object> mapData, string outputDirectory);

        /// <summary>
        /// Writes compiled event data to output files.
        /// </summary>
        /// <param name="eventData">The compiled event data to write.</param>
        /// <param name="outputPath">The output file path for event data.</param>
        void WriteEventData(IDictionary<string, object> eventData, string outputPath);

        /// <summary>
        /// Writes map metadata to output files.
        /// </summary>
        /// <param name="metadata">The compiled metadata to write.</param>
        /// <param name="outputPath">The output file path for metadata.</param>
        void WriteMapMetadata(IDictionary<int, IDictionary<string, object>> metadata, string outputPath);

        /// <summary>
        /// Serializes map and event data for runtime loading.
        /// </summary>
        /// <param name="data">The data to serialize.</param>
        /// <param name="format">The serialization format to use.</param>
        /// <returns>Serialized data.</returns>
        byte[] SerializeMapEventData(object data, string format);

        /// <summary>
        /// Creates map data archives for distribution.
        /// </summary>
        /// <param name="mapFiles">List of map files to archive.</param>
        /// <param name="archivePath">The output archive path.</param>
        void CreateMapDataArchive(IList<string> mapFiles, string archivePath);

        /// <summary>
        /// Backs up existing map data before overwriting.
        /// </summary>
        /// <param name="mapDataPath">The map data path to backup.</param>
        void BackupMapData(string mapDataPath);
    }

    /// <summary>
    /// Interface for map optimization and performance enhancement.
    /// Provides methods to optimize map data for runtime performance.
    /// </summary>
    public interface IMapOptimizer
    {
        /// <summary>
        /// Optimizes map tile data for faster rendering.
        /// </summary>
        /// <param name="mapData">The map data to optimize.</param>
        /// <returns>Optimized map data with improved rendering performance.</returns>
        object OptimizeMapTiles(object mapData);

        /// <summary>
        /// Optimizes event data for faster execution.
        /// </summary>
        /// <param name="eventData">The event data to optimize.</param>
        /// <returns>Optimized event data with improved execution performance.</returns>
        object OptimizeEventData(object eventData);

        /// <summary>
        /// Compresses map data to reduce memory usage.
        /// </summary>
        /// <param name="mapData">The map data to compress.</param>
        /// <param name="compressionLevel">The compression level to apply.</param>
        /// <returns>Compressed map data.</returns>
        object CompressMapData(object mapData, int compressionLevel);

        /// <summary>
        /// Generates pre-computed pathfinding data for AI optimization.
        /// </summary>
        /// <param name="mapData">The map data to generate pathfinding for.</param>
        /// <returns>Pre-computed pathfinding data.</returns>
        object GeneratePathfindingData(object mapData);

        /// <summary>
        /// Optimizes map loading order for better performance.
        /// </summary>
        /// <param name="mapList">List of maps to optimize loading for.</param>
        /// <returns>Optimized map loading order.</returns>
        IList<int> OptimizeMapLoadingOrder(IList<int> mapList);
    }
}