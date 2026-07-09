using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the battle terrain system for Pokémon battles.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing terrain conditions during battles,
    /// including terrain effects, transitions, and state management.
    /// </remarks>
    public interface IBattleTerrain
    {
        /// <summary>
        /// Gets or sets the battle terrain type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the battle terrain name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the battle terrain description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the battle terrain duration.
        /// </summary>
        int Duration { get; set; }

        /// <summary>
        /// Gets or sets the battle terrain intensity.
        /// </summary>
        float Intensity { get; set; }

        /// <summary>
        /// Gets or sets the battle terrain parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the battle terrain system.
        /// </summary>
        IBattleTerrain Initialize();

        /// <summary>
        /// Disposes of the battle terrain system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the battle terrain system has been disposed.
        /// </summary>
        /// <returns>True if the battle terrain system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the battle terrain system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the battle terrain system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Changes the battle terrain to a new type.
        /// </summary>
        /// <param name="type">The new battle terrain type.</param>
        /// <param name="duration">The duration of the new battle terrain.</param>
        /// <param name="intensity">The intensity of the new battle terrain.</param>
        void ChangeBattleTerrain(int type, int duration = -1, float intensity = 1.0f);

        /// <summary>
        /// Gets the current battle terrain type.
        /// </summary>
        /// <returns>The current battle terrain type.</returns>
        int GetType();

        /// <summary>
        /// Sets the battle terrain type.
        /// </summary>
        /// <param name="type">The battle terrain type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the battle terrain name.
        /// </summary>
        /// <returns>The battle terrain name.</returns>
        string GetName();

        /// <summary>
        /// Sets the battle terrain name.
        /// </summary>
        /// <param name="name">The battle terrain name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the battle terrain description.
        /// </summary>
        /// <returns>The battle terrain description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the battle terrain description.
        /// </summary>
        /// <param name="description">The battle terrain description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the battle terrain duration.
        /// </summary>
        /// <returns>The battle terrain duration.</returns>
        int GetDuration();

        /// <summary>
        /// Sets the battle terrain duration.
        /// </summary>
        /// <param name="duration">The battle terrain duration to set.</param>
        void SetDuration(int duration);

        /// <summary>
        /// Gets the battle terrain intensity.
        /// </summary>
        /// <returns>The battle terrain intensity.</returns>
        float GetIntensity();

        /// <summary>
        /// Sets the battle terrain intensity.
        /// </summary>
        /// <param name="intensity">The battle terrain intensity to set.</param>
        void SetIntensity(float intensity);

        /// <summary>
        /// Gets the battle terrain parameters.
        /// </summary>
        /// <returns>The battle terrain parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the battle terrain parameters.
        /// </summary>
        /// <param name="parameters">The battle terrain parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets a battle terrain parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets a battle terrain parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether a battle terrain parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes a battle terrain parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the battle terrain parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the battle terrain as a string.
        /// </summary>
        /// <returns>The battle terrain as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the battle terrain as a JSON string.
        /// </summary>
        /// <returns>The battle terrain as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the battle terrain as a binary string.
        /// </summary>
        /// <returns>The battle terrain as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the battle terrain as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the battle terrain as a stream.
        /// </summary>
        /// <returns>The battle terrain as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the battle terrain as a memory stream.
        /// </summary>
        /// <returns>The battle terrain as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the battle terrain as a byte array.
        /// </summary>
        /// <returns>The battle terrain as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the battle terrain as a string array.
        /// </summary>
        /// <returns>The battle terrain as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the battle terrain as an object array.
        /// </summary>
        /// <returns>The battle terrain as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the battle terrain as a list.
        /// </summary>
        /// <returns>The battle terrain as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the battle terrain as a collection.
        /// </summary>
        /// <returns>The battle terrain as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the battle terrain as an enumerable.
        /// </summary>
        /// <returns>The battle terrain as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the battle terrain as an enumerator.
        /// </summary>
        /// <returns>The battle terrain as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}