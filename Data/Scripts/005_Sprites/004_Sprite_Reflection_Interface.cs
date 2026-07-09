using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a sprite that displays a reflection of another sprite.
    /// </summary>
    /// <remarks>
    /// This interface defines the basic functionality for displaying and managing reflection sprites
    /// in the game. Reflection sprites are used to create mirror effects for characters and other
    /// sprites, such as reflections in water or other reflective surfaces.
    /// </remarks>
    public interface ISpriteReflection : IHaveUpdate, IDisposable
    {
        ISpriteReflection initialize(ISpriteCharacter parent_sprite, IViewport viewport = null);

        /// <summary>
        /// Gets the game character associated with the parent sprite.
        /// </summary>
        /// <remarks>
        /// Returns the game character that the reflection is based on. This is used to access
        /// character-specific properties and behaviors.
        /// </remarks>
        IGameCharacter Event { get; }

        /// <summary>
        /// Gets or sets the visibility of the reflection sprite.
        /// </summary>
        /// <remarks>
        /// When setting visibility, also updates the visibility of the underlying sprite
        /// if it exists and hasn't been disposed.
        /// </remarks>
        bool visible { get; set; }

        /// <summary>
        /// Gets whether the reflection sprite has been disposed.
        /// </summary>
        /// <returns>True if the sprite has been disposed; otherwise, false.</returns>
        /// <remarks>
        /// This method is used to check if the reflection sprite is still valid and can be used.
        /// </remarks>
        bool disposed();

        /// <summary>
        /// Updates the reflection sprite's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the reflection's visual state, including:
        /// - Creating or disposing the reflection sprite as needed
        /// - Updating position and dimensions
        /// - Applying visual effects (mirroring, coloring, opacity)
        /// - Handling animated reflections
        /// - Managing bridge height adjustments
        /// </remarks>
        void update();
    }
}