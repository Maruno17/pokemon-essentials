using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a sprite that displays the base for surfing and diving animations.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for displaying and managing the base sprite
    /// used when a character is surfing or diving. It handles the visual effects and animations
    /// associated with these special movement states.
    /// </remarks>
    public interface ISpriteSurfBase : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Gets or sets the visibility of the surf base sprite.
        /// </summary>
        /// <remarks>
        /// When setting visibility, also updates the visibility of the underlying sprite
        /// if it exists and hasn't been disposed.
        /// </remarks>
        int visible { get; set; }

        /// <summary>
        /// Initializes the surf base sprite with a parent sprite and optional viewport.
        /// </summary>
        /// <param name="parent_sprite">The parent sprite to attach to.</param>
        /// <param name="viewport">The viewport where the sprite will be displayed. Can be null.</param>
        /// <remarks>
        /// Sets up the surf base sprite with the specified parent sprite and viewport.
        /// Loads the necessary bitmap resources for surfing and diving animations.
        /// </remarks>
        ISpriteSurfBase initialize(ISpriteCharacter parent_sprite, IViewport viewport = null);

        /// <summary>
        /// Gets whether the surf base sprite has been disposed.
        /// </summary>
        /// <returns>True if the sprite has been disposed; otherwise, false.</returns>
        /// <remarks>
        /// This method is used to check if the surf base sprite is still valid and can be used.
        /// </remarks>
        bool disposed();

        /// <summary>
        /// Gets the game character associated with the parent sprite.
        /// </summary>
        /// <returns>The game character that the surf base is attached to.</returns>
        /// <remarks>
        /// Returns the character that the surf base is following, which is used to determine
        /// the sprite's position and animation state.
        /// </remarks>
        IGameCharacter Event();

        /// <summary>
        /// Updates the surf base sprite's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the surf base's visual state, including:
        /// - Creating or disposing the sprite as needed
        /// - Updating position and dimensions
        /// - Applying visual effects
        /// - Handling surfing and diving animations
        /// - Managing coordinate transformations
        /// </remarks>
        void update();
    }
}