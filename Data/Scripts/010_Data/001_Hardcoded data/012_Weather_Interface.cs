using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials.Data
{
    /// <summary>
    /// Represents the weather system for the game world.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing weather conditions,
    /// including weather effects, transitions, and state management.
    /// </remarks>
    public interface IWeather
    {
        /// <summary>
        /// Gets or sets the weather type.
        /// </summary>
        int Type { get; set; }

        /// <summary>
        /// Gets or sets the weather name.
        /// </summary>
        string Name { get; set; }

        /// <summary>
        /// Gets or sets the weather description.
        /// </summary>
        string Description { get; set; }

        /// <summary>
        /// Gets or sets the weather duration.
        /// </summary>
        int Duration { get; set; }

        /// <summary>
        /// Gets or sets the weather intensity.
        /// </summary>
        float Intensity { get; set; }

        /// <summary>
        /// Gets or sets the weather parameters.
        /// </summary>
        IDictionary<string, object> Parameters { get; set; }

        /// <summary>
        /// Initializes the weather system.
        /// </summary>
        IWeather Initialize();

        /// <summary>
        /// Disposes of the weather system and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the weather system has been disposed.
        /// </summary>
        /// <returns>True if the weather system has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the weather system's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the weather system's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Changes the weather to a new type.
        /// </summary>
        /// <param name="type">The new weather type.</param>
        /// <param name="duration">The duration of the new weather.</param>
        /// <param name="intensity">The intensity of the new weather.</param>
        void ChangeWeather(int type, int duration = -1, float intensity = 1.0f);

        /// <summary>
        /// Gets the current weather type.
        /// </summary>
        /// <returns>The current weather type.</returns>
        int GetType();

        /// <summary>
        /// Sets the weather type.
        /// </summary>
        /// <param name="type">The weather type to set.</param>
        void SetType(int type);

        /// <summary>
        /// Gets the weather name.
        /// </summary>
        /// <returns>The weather name.</returns>
        string GetName();

        /// <summary>
        /// Sets the weather name.
        /// </summary>
        /// <param name="name">The weather name to set.</param>
        void SetName(string name);

        /// <summary>
        /// Gets the weather description.
        /// </summary>
        /// <returns>The weather description.</returns>
        string GetDescription();

        /// <summary>
        /// Sets the weather description.
        /// </summary>
        /// <param name="description">The weather description to set.</param>
        void SetDescription(string description);

        /// <summary>
        /// Gets the weather duration.
        /// </summary>
        /// <returns>The weather duration.</returns>
        int GetDuration();

        /// <summary>
        /// Sets the weather duration.
        /// </summary>
        /// <param name="duration">The weather duration to set.</param>
        void SetDuration(int duration);

        /// <summary>
        /// Gets the weather intensity.
        /// </summary>
        /// <returns>The weather intensity.</returns>
        float GetIntensity();

        /// <summary>
        /// Sets the weather intensity.
        /// </summary>
        /// <param name="intensity">The weather intensity to set.</param>
        void SetIntensity(float intensity);

        /// <summary>
        /// Gets the weather parameters.
        /// </summary>
        /// <returns>The weather parameters.</returns>
        IDictionary<string, object> GetParameters();

        /// <summary>
        /// Sets the weather parameters.
        /// </summary>
        /// <param name="parameters">The weather parameters to set.</param>
        void SetParameters(IDictionary<string, object> parameters);

        /// <summary>
        /// Gets a weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to get.</param>
        /// <returns>The value of the parameter.</returns>
        object GetParameter(string key);

        /// <summary>
        /// Sets a weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to set.</param>
        /// <param name="value">The value to set.</param>
        void SetParameter(string key, object value);

        /// <summary>
        /// Gets whether a weather parameter exists.
        /// </summary>
        /// <param name="key">The key of the parameter to check.</param>
        /// <returns>True if the parameter exists, false otherwise.</returns>
        bool HasParameter(string key);

        /// <summary>
        /// Removes a weather parameter.
        /// </summary>
        /// <param name="key">The key of the parameter to remove.</param>
        void RemoveParameter(string key);

        /// <summary>
        /// Clears the weather parameters.
        /// </summary>
        void ClearParameters();

        /// <summary>
        /// Gets the weather as a string.
        /// </summary>
        /// <returns>The weather as a string.</returns>
        string ToString();

        /// <summary>
        /// Gets the weather as a JSON string.
        /// </summary>
        /// <returns>The weather as a JSON string.</returns>
        string ToJson();

        /// <summary>
        /// Gets the weather as a binary string.
        /// </summary>
        /// <returns>The weather as a binary string.</returns>
        byte[] ToBinary();

        /// <summary>
        /// Gets the weather as a file.
        /// </summary>
        /// <param name="path">The path to save the file to.</param>
        void ToFile(string path);

        /// <summary>
        /// Gets the weather as a stream.
        /// </summary>
        /// <returns>The weather as a stream.</returns>
        System.IO.Stream ToStream();

        /// <summary>
        /// Gets the weather as a memory stream.
        /// </summary>
        /// <returns>The weather as a memory stream.</returns>
        System.IO.MemoryStream ToMemoryStream();

        /// <summary>
        /// Gets the weather as a byte array.
        /// </summary>
        /// <returns>The weather as a byte array.</returns>
        byte[] ToByteArray();

        /// <summary>
        /// Gets the weather as a string array.
        /// </summary>
        /// <returns>The weather as a string array.</returns>
        string[] ToStringArray();

        /// <summary>
        /// Gets the weather as an object array.
        /// </summary>
        /// <returns>The weather as an object array.</returns>
        object[] ToObjectArray();

        /// <summary>
        /// Gets the weather as a list.
        /// </summary>
        /// <returns>The weather as a list.</returns>
        IList ToList();

        /// <summary>
        /// Gets the weather as a collection.
        /// </summary>
        /// <returns>The weather as a collection.</returns>
        ICollection ToCollection();

        /// <summary>
        /// Gets the weather as an enumerable.
        /// </summary>
        /// <returns>The weather as an enumerable.</returns>
        IEnumerable ToEnumerable();

        /// <summary>
        /// Gets the weather as an enumerator.
        /// </summary>
        /// <returns>The weather as an enumerator.</returns>
        IEnumerator ToEnumerator();
    }
}