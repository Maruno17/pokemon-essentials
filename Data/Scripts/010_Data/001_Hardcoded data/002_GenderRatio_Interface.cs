using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the gender ratio system for Pokémon.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing Pokémon gender ratios,
    /// including gender determination and ratio calculations.
    /// </remarks>
    public interface IGenderRatio
    {
        /// <summary>
        /// Gets or sets the gender ratio type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the gender ratio name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the gender ratio description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the gender ratio formula.
        /// </summary>
        string Formula { get; set; }

        /// <summary>
        /// Gets or sets the gender ratio parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the gender ratio system.
        /// </summary>
        IGenderRatio Initialize();

        /// <summary>
        /// Disposes of the gender ratio system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the gender ratio system has been disposed.
        /// </summary>
        /// <returns>True if the gender ratio system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the gender ratio system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the gender ratio system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Calculates the gender ratio for a given Pokémon.
        /// </summary>
        /// <param name="pokemon">The Pokémon to calculate the gender ratio for.</param>
        /// <returns>The gender ratio for the Pokémon.</returns>
        float CalculateGenderRatio(IPokemon pokemon);

        /// <summary>
        /// Determines the gender for a given Pokémon.
        /// </summary>
        /// <param name="pokemon">The Pokémon to determine the gender for.</param>
        /// <returns>The determined gender for the Pokémon.</returns>
        int DetermineGender(IPokemon pokemon);

        /// <summary>
        /// Gets the gender ratio type.
        /// </summary>
        /// <returns>The gender ratio type.</returns>
        int GetType();

        /// <summary>
        /// Sets the gender ratio type.
        /// </summary>
        /// <param name="type">The gender ratio type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the gender ratio name.
        /// </summary>
        /// <returns>The gender ratio name.</returns>
        string GetName();

        /// <summary>
        /// Sets the gender ratio name.
        /// </summary>
        /// <param name="name">The gender ratio name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the gender ratio description.
        /// </summary>
        /// <returns>The gender ratio description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the gender ratio description.
        /// </summary>
        /// <param name="description">The gender ratio description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the gender ratio formula.
        /// </summary>
        /// <returns>The gender ratio formula.</returns>
        string GetFormula();

        /// <summary>
        /// Sets the gender ratio formula.
        /// </summary>
        /// <param name="formula">The gender ratio formula to set.</param>
        void SetFormula(string formula);

        /// <summary>
        /// Gets the gender ratio parameters.
        /// </summary>
        /// <returns>The gender ratio parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the gender ratio parameters.
        /// </summary>
        /// <param name="parameters">The gender ratio parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets a gender ratio parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets a gender ratio parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether a gender ratio parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes a gender ratio parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the gender ratio parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the gender ratio as a string.
        /// </summary>
        /// <returns>The gender ratio as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the gender ratio as a JSON string.
        /// </summary>
        /// <returns>The gender ratio as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the gender ratio as a binary string.
        /// </summary>
        /// <returns>The gender ratio as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the gender ratio as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the gender ratio as a stream.
        /// </summary>
        /// <returns>The gender ratio as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the gender ratio as a memory stream.
        /// </summary>
        /// <returns>The gender ratio as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the gender ratio as a byte array.
        /// </summary>
        /// <returns>The gender ratio as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the gender ratio as a string array.
        /// </summary>
        /// <returns>The gender ratio as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the gender ratio as an object array.
        /// </summary>
        /// <returns>The gender ratio as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the gender ratio as a list.
        /// </summary>
        /// <returns>The gender ratio as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the gender ratio as a collection.
        /// </summary>
        /// <returns>The gender ratio as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the gender ratio as an enumerable.
        /// </summary>
        /// <returns>The gender ratio as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the gender ratio as an enumerator.
        /// </summary>
        /// <returns>The gender ratio as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}