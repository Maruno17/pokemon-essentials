using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Plugin Manager system (PluginManager module).
    /// </summary>
    public interface IPluginManager
    {
        /// <summary>
        /// Registers a plugin with the plugin manager system.
        /// </summary>
        void register(IPluginMetadata options);

        /// <summary>
        /// Throws a plugin error message and exits the application.
        /// </summary>
        void error(string msg);

        /// <summary>
        /// Checks if a specific plugin is installed, optionally with version checking.
        /// </summary>
        bool installed(string plugin_name, string plugin_version = null, bool mustequal = false);

        /// <summary>
        /// Gets the names of all currently installed plugins.
        /// </summary>
        IList<string> plugins { get; }

        /// <summary>
        /// Gets the version of a specific installed plugin.
        /// </summary>
        string version(string plugin_name);

        /// <summary>
        /// Gets the download/website link for a specific plugin.
        /// </summary>
        string link(string plugin_name);

        /// <summary>
        /// Gets the credits list for a specific plugin.
        /// </summary>
        IList<string> credits(string plugin_name);

        /// <summary>
        /// Compares two version strings to determine their relative ordering.
        /// </summary>
        int compare_versions(string v1, string v2);

        /// <summary>
        /// Formats and displays a plugin error message.
        /// </summary>
        void pluginErrorMsg(string name, string script);

        /// <summary>
        /// Reads and parses a plugin's meta.txt file to extract metadata.
        /// </summary>
        IPluginMetadata readMeta(string dir, string file);

        /// <summary>
        /// Gets a list of all plugin directories to inspect for valid plugins.
        /// </summary>
        IList<string> listAll();

        /// <summary>
        /// Validates plugin dependencies to catch circular dependency loops.
        /// </summary>
        void validateDependencies(string name, IDictionary<string, IPluginMetadata> meta, IList<string> og = null);

        /// <summary>
        /// Sorts the plugin load order based on dependencies.
        /// </summary>
        IList<string> sortLoadOrder(IList<string> order, IDictionary<string, IPluginMetadata> plugins);

        /// <summary>
        /// Determines the correct order to load plugins based on their dependencies.
        /// </summary>
        KeyValuePair<IList<string>, IDictionary<string, IPluginMetadata>> getPluginOrder();

        /// <summary>
        /// Checks if plugins need to be recompiled based on file modification times.
        /// </summary>
        bool needCompiling(IList<string> order, IDictionary<string, IPluginMetadata> plugins);

        /// <summary>
        /// Compiles all plugins.
        /// </summary>
        void compilePlugins(IList<string> order, IDictionary<string, IPluginMetadata> plugins);

        /// <summary>
        /// Main entry point that runs the complete plugin system.
        /// </summary>
        void runPlugins();

        /// <summary>
        /// Finds the directory path for a plugin by its name.
        /// </summary>
        string findDirectory(string name);
    }

    /// <summary>
    /// Interface for plugin metadata and configuration.
    /// </summary>
    public interface IPluginMetadata
    {
        string name { get; set; }
        string version { get; set; }
        IList<string> essentials { get; set; }
        string link { get; set; }
        IList<object> dependencies { get; set; }
        IList<string> incompatibilities { get; set; }
        IList<string> credits { get; set; }
        IList<string> scripts { get; set; }
        string dir { get; set; }
    }
}