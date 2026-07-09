using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for directory operations and file management (Dir class).
    /// </summary>
    public interface IDir
    {
        /// <summary>
        /// Reads all files in a directory that match the specified filters.
        /// </summary>
        /// <param name="dir">The directory path to search in.</param>
        /// <param name="filters">File pattern filters to match. Can be a single pattern or array of patterns.</param>
        /// <param name="full">Whether to return full paths or relative paths.</param>
        IList<string> get(string dir, object filters = null, bool full = true);

        /// <summary>
        /// Generates entire file/folder tree from a certain directory recursively.
        /// </summary>
        /// <param name="dir">The root directory to start the recursive search.</param>
        /// <param name="filters">File pattern filters to match.</param>
        /// <param name="full">Whether to return full paths or relative paths.</param>
        IList<string> all(string dir, object filters = null, bool full = true);

        /// <summary>
        /// Checks if the specified path is a directory.
        /// </summary>
        /// <param name="dir">The directory path to check.</param>
        bool safe(string dir);

        /// <summary>
        /// Creates all the required directories for the specified path.
        /// </summary>
        /// <param name="path">The directory path to create.</param>
        void create(string path);

        /// <summary>
        /// Generates entire folder tree from a certain directory recursively.
        /// </summary>
        /// <param name="dir">The root directory to start the recursive search.</param>
        IList<string> all_dirs(string dir);

        /// <summary>
        /// Deletes all files and subdirectories in a directory.
        /// </summary>
        /// <param name="dir">The directory to delete all contents from.</param>
        void delete_all(string dir);
    }

    /// <summary>
    /// Interface for top-level file test and resolution functions.
    /// </summary>
    public interface IMainFileTests : IMain
    {
        /// <summary>
        /// Safely performs file globbing with special character compatibility.
        /// </summary>
        /// <param name="dir">The directory path to search in.</param>
        /// <param name="wildcard">The filename pattern to match.</param>
        /// <param name="block">Optional action block to run on each found file.</param>
        IList<string> safeGlob(string dir, string wildcard, Action<string> block = null);

        /// <summary>
        /// Resolves the full path for an audio sound effect file.
        /// </summary>
        /// <param name="file">The base filename to search for.</param>
        string pbResolveAudioSE(string file);

        /// <summary>
        /// Finds the real path for an image file, checking search paths and extensions.
        /// </summary>
        /// <param name="x">The image filename to search for.</param>
        string pbResolveBitmap(string x);

        /// <summary>
        /// Finds the real path for an image file, returning the original filename if not found.
        /// </summary>
        /// <param name="x">The image filename to search for.</param>
        string pbBitmapName(string x);

        /// <summary>
        /// Splits a string using a regular expression pattern.
        /// </summary>
        IList<string> strsplit(string str, System.Text.RegularExpressions.Regex re);

        /// <summary>
        /// Canonicalizes a file path by resolving relative path components.
        /// </summary>
        string canonicalize(string c);

        /// <summary>
        /// Checks if a file exists, including checking within encrypted game archives.
        /// </summary>
        bool pbRgssExists(string filename);

        /// <summary>
        /// Opens a stream for a file, even if it is in an encrypted archive.
        /// </summary>
        object pbRgssOpen(string file, string mode = null, Action<System.IO.Stream> @yield = null);

        /// <summary>
        /// Gets the first byte of a file, checking encrypted archives.
        /// </summary>
        string pbGetFileChar(string file);

        /// <summary>
        /// Attempts to get a string representation of a file if it exists.
        /// </summary>
        string pbTryString(string x);

        /// <summary>
        /// Gets the complete contents of a file as a string.
        /// </summary>
        string pbGetFileString(string file);
    }

    /// <summary>
    /// Interface for RTP (Run Time Package) path management.
    /// </summary>
    public interface IRTP
    {
        /// <summary>
        /// Checks if a file exists in the RTP search paths.
        /// </summary>
        bool exists(string filename, IList<string> extensions = null);

        /// <summary>
        /// Gets the full path for an image file.
        /// </summary>
        string getImagePath(string filename);

        /// <summary>
        /// Gets the full path for an audio file.
        /// </summary>
        string getAudioPath(string filename);

        /// <summary>
        /// Gets the full path for a file with specified extensions.
        /// </summary>
        string getPath(string filename, IList<string> extensions = null);

        /// <summary>
        /// Iterates through possible paths for a given filename.
        /// </summary>
        void eachPathFor(string filename, Action<string> @yield);

        /// <summary>
        /// Gets all search paths.
        /// </summary>
        void eachPath(Action<string> @yield);

        /// <summary>
        /// Gets the full path for a save file.
        /// </summary>
        string getSaveFileName(string fileName);

        /// <summary>
        /// Gets the path to the save data folder.
        /// </summary>
        string getSaveFolder();
    }

    /// <summary>
    /// Interface for file testing capabilities (FileTest module).
    /// </summary>
    public interface IFileTest
    {
        /// <summary>
        /// Supported image file extensions.
        /// </summary>
        IList<string> IMAGE_EXTENSIONS { get; }

        /// <summary>
        /// Supported audio file extensions.
        /// </summary>
        IList<string> AUDIO_EXTENSIONS { get; }

        /// <summary>
        /// Checks if an audio file exists.
        /// </summary>
        bool audio_exist(string filename);

        /// <summary>
        /// Checks if an image file exists.
        /// </summary>
        bool image_exist(string filename);
    }

    /// <summary>
    /// Interface for string-based input stream functionality (StringInput class).
    /// </summary>
    public interface IStringInput : IEnumerable<string>
    {
        /// <summary>
        /// Gets the current line number.
        /// </summary>
        int lineno { get; }

        /// <summary>
        /// Gets the source string.
        /// </summary>
        string @string { get; }

        /// <summary>
        /// Checks if the stream is closed.
        /// </summary>
        bool closed();

        /// <summary>
        /// Gets or sets the current position in the string.
        /// </summary>
        int pos { get; set; }

        /// <summary>
        /// Closes the stream.
        /// </summary>
        void close();

        /// <summary>
        /// Rewinds the position to the beginning.
        /// </summary>
        void rewind();

        /// <summary>
        /// Seeks to a specific position in the string.
        /// </summary>
        int seek(int offset, int whence = 0);

        /// <summary>
        /// Checks if the stream is at end-of-file.
        /// </summary>
        bool eof();

        /// <summary>
        /// Iterates through the lines.
        /// </summary>
        void each(Action<string> @yield);

        /// <summary>
        /// Gets the next line from the stream.
        /// </summary>
        string gets();

        /// <summary>
        /// Gets the next character.
        /// </summary>
        string getc();

        /// <summary>
        /// Reads characters from the stream.
        /// </summary>
        string read(int? len = null);
    }
}