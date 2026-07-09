using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the SaveData module (SaveData module).
    /// </summary>
    public interface ISaveData
    {
        /// <summary>
        /// Gets the file path of the save file.
        /// </summary>
        string FILE_PATH { get; }

        /// <summary>
        /// Checks if the save file exists.
        /// </summary>
        bool exists();

        /// <summary>
        /// Fetches the save data from the given file.
        /// </summary>
        object get_data_from_file(string file_path);

        /// <summary>
        /// Fetches save data from the given file. If it needed converting, resaves it.
        /// </summary>
        IDictionary<string, object> read_from_file(string file_path);

        /// <summary>
        /// Compiles the save data and saves a marshaled version of it into the given file.
        /// </summary>
        void save_to_file(string file_path);

        /// <summary>
        /// Deletes the save file and backup files.
        /// </summary>
        void delete_file();

        /// <summary>
        /// Converts pre-v19 format data to the new format.
        /// </summary>
        IDictionary<string, object> to_hash_format(IList<object> old_format);
    }
}