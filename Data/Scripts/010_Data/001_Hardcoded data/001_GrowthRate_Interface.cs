using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the growth rate system for Pokémon.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing Pokémon growth rates,
    /// including experience point calculations and level-up requirements.
    /// </remarks>
    public interface IGrowthRate
    {
        /// <summary>
        /// Gets or sets the growth rate type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the growth rate name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the growth rate description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the growth rate formula.
        /// </summary>
        string Formula { get; set; }

        /// <summary>
        /// Gets or sets the growth rate parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the growth rate system.
        /// </summary>
        IGrowthRate Initialize();

        /// <summary>
        /// Disposes of the growth rate system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the growth rate system has been disposed.
        /// </summary>
        /// <returns>True if the growth rate system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the growth rate system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the growth rate system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Calculates the experience points required for a given level.
        /// </summary>
        /// <param name="level">The level to calculate experience points for.</param>
        /// <returns>The experience points required for the level.</returns>
        int CalculateExperience(int level);

        /// <summary>
        /// Calculates the level for a given amount of experience points.
        /// </summary>
        /// <param name="experience">The experience points to calculate the level for.</param>
        /// <returns>The level for the given experience points.</returns>
        int CalculateLevel(int experience);

        /// <summary>
        /// Gets the growth rate type.
        /// </summary>
        /// <returns>The growth rate type.</returns>
        int GetType();

        /// <summary>
        /// Sets the growth rate type.
        /// </summary>
        /// <param name="type">The growth rate type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the growth rate name.
        /// </summary>
        /// <returns>The growth rate name.</returns>
        string GetName();

        /// <summary>
        /// Sets the growth rate name.
        /// </summary>
        /// <param name="name">The growth rate name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the growth rate description.
        /// </summary>
        /// <returns>The growth rate description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the growth rate description.
        /// </summary>
        /// <param name="description">The growth rate description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the growth rate formula.
        /// </summary>
        /// <returns>The growth rate formula.</returns>
        string GetFormula();

        /// <summary>
        /// Sets the growth rate formula.
        /// </summary>
        /// <param name="formula">The growth rate formula to set.</param>
        void SetFormula(string formula);

        /// <summary>
        /// Gets the growth rate parameters.
        /// </summary>
        /// <returns>The growth rate parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the growth rate parameters.
        /// </summary>
        /// <param name="parameters">The growth rate parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets a growth rate parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets a growth rate parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether a growth rate parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes a growth rate parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the growth rate parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the growth rate as a string.
        /// </summary>
        /// <returns>The growth rate as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the growth rate as a JSON string.
        /// </summary>
        /// <returns>The growth rate as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the growth rate as a binary string.
        /// </summary>
        /// <returns>The growth rate as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the growth rate as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the growth rate as a stream.
        /// </summary>
        /// <returns>The growth rate as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the growth rate as a memory stream.
        /// </summary>
        /// <returns>The growth rate as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the growth rate as a byte array.
        /// </summary>
        /// <returns>The growth rate as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the growth rate as a string array.
        /// </summary>
        /// <returns>The growth rate as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the growth rate as an object array.
        /// </summary>
        /// <returns>The growth rate as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the growth rate as a list.
        /// </summary>
        /// <returns>The growth rate as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the growth rate as a collection.
        /// </summary>
        /// <returns>The growth rate as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the growth rate as an enumerable.
        /// </summary>
        /// <returns>The growth rate as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the growth rate as an enumerator.
        /// </summary>
        /// <returns>The growth rate as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}