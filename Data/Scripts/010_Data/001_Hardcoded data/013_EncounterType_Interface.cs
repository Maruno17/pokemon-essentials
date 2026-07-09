using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the encounter type system for Pokémon.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing Pokémon encounter types,
    /// including encounter rates, conditions, and state management.
    /// </remarks>
    public interface IEncounterType
    {
        /// <summary>
        /// Gets or sets the encounter type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the encounter type name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the encounter type description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the encounter rate.
        /// </summary>
        float Rate { get; set; }

        /// <summary>
        /// Gets or sets the encounter conditions.
        /// </summary>
        IDictionary<string, object> Conditions { get; set; }

        /// <summary>
        /// Gets or sets the encounter parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the encounter type system.
        /// </summary>
        IEncounterType Initialize();

        /// <summary>
        /// Disposes of the encounter type system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the encounter type system has been disposed.
        /// </summary>
        /// <returns>True if the encounter type system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the encounter type system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the encounter type system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Calculates the encounter rate for a given Pokémon.
        /// </summary>
        /// <param name="pokemon">The Pokémon to calculate the encounter rate for.</param>
        /// <returns>The encounter rate for the Pokémon.</returns>
        float CalculateEncounterRate(IPokemon pokemon);

        /// <summary>
        /// Checks if the encounter conditions are met.
        /// </summary>
        /// <param name="pokemon">The Pokémon to check the encounter conditions for.</param>
        /// <returns>True if the encounter conditions are met, false otherwise.</returns>
        bool CheckEncounterConditions(IPokemon pokemon);

        /// <summary>
        /// Gets the encounter type.
        /// </summary>
        /// <returns>The encounter type.</returns>
        int GetType();

        /// <summary>
        /// Sets the encounter type.
        /// </summary>
        /// <param name="type">The encounter type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the encounter type name.
        /// </summary>
        /// <returns>The encounter type name.</returns>
        string GetName();

        /// <summary>
        /// Sets the encounter type name.
        /// </summary>
        /// <param name="name">The encounter type name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the encounter type description.
        /// </summary>
        /// <returns>The encounter type description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the encounter type description.
        /// </summary>
        /// <param name="description">The encounter type description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the encounter rate.
        /// </summary>
        /// <returns>The encounter rate.</returns>
        float GetRate();

        /// <summary>
        /// Sets the encounter rate.
        /// </summary>
        /// <param name="rate">The encounter rate to set.</param>
        void SetRate(float rate);

        /// <summary>
        /// Gets the encounter conditions.
        /// </summary>
        /// <returns>The encounter conditions.</returns>
        IDictionary<string, object> GetConditions();

        /// <summary>
        /// Sets the encounter conditions.
        /// </summary>
        /// <param name="conditions">The encounter conditions to set.</param>
        void SetConditions(IDictionary<string, object> conditions);

        /// <summary>
        /// Gets an encounter condition.
        /// </summary>
        /// <param name="key">The key of the condition to get.</param>
        /// <returns>The value of the condition.</returns>
        object GetCondition(string key);

        /// <summary>
        /// Sets an encounter condition.
        /// </summary>
        /// <param name="key">The key of the condition to set.</param>
        /// <param name="value">The value to set.</param>
        void SetCondition(string key, object value);

        /// <summary>
        /// Gets whether an encounter condition exists.
        /// </summary>
        /// <param name="key">The key of the condition to check.</param>
        /// <returns>True if the condition exists, false otherwise.</returns>
        bool HasCondition(string key);

        /// <summary>
        /// Removes an encounter condition.
        /// </summary>
        /// <param name="key">The key of the condition to remove.</param>
        void RemoveCondition(string key);

        /// <summary>
        /// Clears the encounter conditions.
        /// </summary>
        void ClearConditions();

        /// <summary>
        /// Gets the encounter parameters.
        /// </summary>
        /// <returns>The encounter parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the encounter parameters.
        /// </summary>
        /// <param name="parameters">The encounter parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets an encounter parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets an encounter parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether an encounter parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes an encounter parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the encounter parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the encounter type as a string.
        /// </summary>
        /// <returns>The encounter type as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the encounter type as a JSON string.
        /// </summary>
        /// <returns>The encounter type as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the encounter type as a binary string.
        /// </summary>
        /// <returns>The encounter type as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the encounter type as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the encounter type as a stream.
        /// </summary>
        /// <returns>The encounter type as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the encounter type as a memory stream.
        /// </summary>
        /// <returns>The encounter type as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the encounter type as a byte array.
        /// </summary>
        /// <returns>The encounter type as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the encounter type as a string array.
        /// </summary>
        /// <returns>The encounter type as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the encounter type as an object array.
        /// </summary>
        /// <returns>The encounter type as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the encounter type as a list.
        /// </summary>
        /// <returns>The encounter type as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the encounter type as a collection.
        /// </summary>
        /// <returns>The encounter type as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the encounter type as an enumerable.
        /// </summary>
        /// <returns>The encounter type as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the encounter type as an enumerator.
        /// </summary>
        /// <returns>The encounter type as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}