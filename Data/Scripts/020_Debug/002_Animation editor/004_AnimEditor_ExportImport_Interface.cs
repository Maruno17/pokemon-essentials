using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides export and import functionality for battle animations.
    /// Allows saving animation data to external formats and loading animations from files for sharing and backup purposes.
    /// </summary>
    public interface IBattleAnimationEditorExportImport : IBattleAnimationEditor
    {
        /// <summary>
        /// Changes to specified directory and executes code within RTP paths.
        /// Provides safe directory navigation within the game's resource paths.
        /// </summary>
        /// <param name="dir">The directory to change to</param>
        /// <param name="action">The action to execute in the directory</param>
        void rgssChdir(string dir, System.Action action);

        /// <summary>
        /// Attempts to load data from a file with error handling.
        /// Returns null if the file cannot be loaded or is corrupted.
        /// </summary>
        /// <param name="file">The file path to load data from</param>
        /// <returns>The loaded data object or null if failed</returns>
        object tryLoadData(string file);

        /// <summary>
        /// Converts animation data to Base64-encoded compressed format.
        /// Used for exporting animations in a transferable text format.
        /// </summary>
        /// <param name="animation">The animation object to encode</param>
        /// <returns>Base64-encoded compressed animation data</returns>
        string dumpBase64Anim(object animation);

        /// <summary>
        /// Decodes Base64-encoded compressed animation data.
        /// Used for importing animations from text format files.
        /// </summary>
        /// <param name="data">The Base64-encoded data to decode</param>
        /// <returns>The decoded animation object</returns>
        object loadBase64Anim(string data);

        /// <summary>
        /// Exports the currently selected animation to a .anm file.
        /// Prompts user for filename and saves as transferable text format.
        /// </summary>
        /// <param name="animations">The animation collection containing the animation to export</param>
        void exportAnim(object animations);

        /// <summary>
        /// Imports an animation from a .anm file with file selection interface.
        /// Displays available .anm files and loads the selected animation.
        /// </summary>
        /// <param name="animations">The animation collection to import into</param>
        /// <param name="canvas">The animation canvas for loading the imported animation</param>
        /// <param name="animwin">The animation window for updating the display</param>
        void importAnim(object animations, object canvas, object animwin);

        /// <summary>
        /// Converts animation data to new format specification.
        /// Updates older animation format to current Pokemon Essentials standards.
        /// </summary>
        /// <param name="textdata">The animation data to convert</param>
        /// <returns>True if conversion was needed and performed</returns>
        bool convertAnimToNewFormat(object textdata);

        /// <summary>
        /// Batch converts all animations to new format.
        /// Processes entire animation database and updates format where needed.
        /// </summary>
        void convertAnimsToNewFormat();
    }
    /*
    /// <summary>
    /// Animation file format management for import/export operations.
    /// </summary>
    public interface IAnimationFileManager
    {
        /// <summary>
        /// Gets the list of available .anm files in the current directory.
        /// </summary>
        /// <returns>Array of animation file names</returns>
        IList<string> getAnimationFiles();

        /// <summary>
        /// Validates that an animation file contains valid data.
        /// </summary>
        /// <param name="filename">The animation file to validate</param>
        /// <returns>True if the file contains valid animation data</returns>
        bool validateAnimationFile(string filename);

        /// <summary>
        /// Checks if the animation's graphic file exists.
        /// Warns user if the required graphic is missing.
        /// </summary>
        /// <param name="graphicPath">The path to the animation graphic</param>
        /// <returns>True if the graphic file exists</returns>
        bool checkAnimationGraphic(string graphicPath);
    }

    /// <summary>
    /// Animation format conversion utilities for version compatibility.
    /// </summary>
    public interface IAnimationFormatConverter
    {
        /// <summary>
        /// Identifies animations that need format conversion.
        /// Checks for missing required fields in animation data.
        /// </summary>
        /// <param name="animationData">The animation data to check</param>
        /// <returns>True if conversion is needed</returns>
        bool needsFormatConversion(object animationData);

        /// <summary>
        /// Updates animation sprite focus and positioning data.
        /// Applies current battle scene focus coordinates to sprite frames.
        /// </summary>
        /// <param name="frameData">The animation frame data to update</param>
        /// <param name="spriteIndex">The sprite index (0=user, 1=target, 2+=other)</param>
        /// <param name="animationPosition">The animation's target position</param>
        void updateSpriteFocus(object frameData, int spriteIndex, int animationPosition);

        /// <summary>
        /// Applies priority settings to animation frames.
        /// Ensures proper sprite layering in battle scenes.
        /// </summary>
        /// <param name="frameData">The animation frame data to update</param>
        void updateSpritePriority(object frameData);

        /// <summary>
        /// Saves converted animation data to the game database.
        /// Updates the PkmnAnimations.rxdata file with new format.
        /// </summary>
        /// <param name="animations">The converted animation collection</param>
        void saveConvertedAnimations(object animations);
    }

    /// <summary>
    /// File I/O operations for animation data management.
    /// </summary>
    public interface IAnimationIO
    {
        /// <summary>
        /// Reads animation data from a file with compression handling.
        /// Supports both text and binary animation formats.
        /// </summary>
        /// <param name="filename">The file to read from</param>
        /// <returns>The loaded animation data</returns>
        object readAnimationFile(string filename);

        /// <summary>
        /// Writes animation data to a file with compression.
        /// Creates transferable text format for sharing animations.
        /// </summary>
        /// <param name="filename">The file to write to</param>
        /// <param name="animationData">The animation data to save</param>
        /// <returns>True if save was successful</returns>
        bool writeAnimationFile(string filename, object animationData);

        /// <summary>
        /// Compresses animation data using Zlib deflate.
        /// Reduces file size for efficient storage and transfer.
        /// </summary>
        /// <param name="data">The data to compress</param>
        /// <returns>Compressed data bytes</returns>
        byte[] compressData(object data);

        /// <summary>
        /// Decompresses animation data using Zlib inflate.
        /// Restores original data from compressed format.
        /// </summary>
        /// <param name="compressedData">The compressed data to decompress</param>
        /// <returns>The original uncompressed data</returns>
        object decompressData(byte[] compressedData);
    }
    */
}