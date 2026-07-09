using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the battle weather system for Pokémon battles.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing weather conditions during battles,
    /// including weather effects, transitions, and state management.
    /// </remarks>
    public interface IBattleWeather
    {
        /// <summary>
        /// Gets or sets the battle weather type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the battle weather name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the battle weather description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the battle weather duration.
        /// </summary>
        int Duration { get; set; }

        /// <summary>
        /// Gets or sets the battle weather intensity.
        /// </summary>
        float Intensity { get; set; }

        /// <summary>
        /// Gets or sets the battle weather parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the battle weather system.
        /// </summary>
        IBattleWeather Initialize();

        /// <summary>
        /// Disposes of the battle weather system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the battle weather system has been disposed.
        /// </summary>
        /// <returns>True if the battle weather system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the battle weather system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the battle weather system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Changes the battle weather to a new type.
        /// </summary>
        /// <param name="type">The new battle weather type.</param>
        /// <param name="duration">The duration of the new battle weather.</param>
        /// <param name="intensity">The intensity of the new battle weather.</param>
        void ChangeBattleWeather(int type, int duration = -1, float intensity = 1.0f);

        /// <summary>
        /// Gets the current battle weather type.
        /// </summary>
        /// <returns>The current battle weather type.</returns>
        int GetType();

        /// <summary>
        /// Sets the battle weather type.
        /// </summary>
        /// <param name="type">The battle weather type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the battle weather name.
        /// </summary>
        /// <returns>The battle weather name.</returns>
        string GetName();

        /// <summary>
        /// Sets the battle weather name.
        /// </summary>
        /// <param name="name">The battle weather name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the battle weather description.
        /// </summary>
        /// <returns>The battle weather description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the battle weather description.
        /// </summary>
        /// <param name="description">The battle weather description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the battle weather duration.
        /// </summary>
        /// <returns>The battle weather duration.</returns>
        int GetDuration();

        /// <summary>
        /// Sets the battle weather duration.
        /// </summary>
        /// <param name="duration">The battle weather duration to set.</param>
        void SetDuration(int duration);

        /// <summary>
        /// Gets the battle weather intensity.
        /// </summary>
        /// <returns>The battle weather intensity.</returns>
        float GetIntensity();

        /// <summary>
        /// Sets the battle weather intensity.
        /// </summary>
        /// <param name="intensity">The battle weather intensity to set.</param>
        void SetIntensity(float intensity);

        /// <summary>
        /// Gets the battle weather parameters.
        /// </summary>
        /// <returns>The battle weather parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the battle weather parameters.
        /// </summary>
        /// <param name="parameters">The battle weather parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets a battle weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets a battle weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether a battle weather parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes a battle weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the battle weather parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the battle weather as a string.
        /// </summary>
        /// <returns>The battle weather as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the battle weather as a JSON string.
        /// </summary>
        /// <returns>The battle weather as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the battle weather as a binary string.
        /// </summary>
        /// <returns>The battle weather as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the battle weather as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the battle weather as a stream.
        /// </summary>
        /// <returns>The battle weather as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the battle weather as a memory stream.
        /// </summary>
        /// <returns>The battle weather as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the battle weather as a byte array.
        /// </summary>
        /// <returns>The battle weather as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the battle weather as a string array.
        /// </summary>
        /// <returns>The battle weather as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the battle weather as an object array.
        /// </summary>
        /// <returns>The battle weather as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the battle weather as a list.
        /// </summary>
        /// <returns>The battle weather as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the battle weather as a collection.
        /// </summary>
        /// <returns>The battle weather as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the battle weather as an enumerable.
        /// </summary>
        /// <returns>The battle weather as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the battle weather as an enumerator.
        /// </summary>
        /// <returns>The battle weather as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}