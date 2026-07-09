using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a spriteset that manages global sprites in the game.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing global sprites such as the player,
    /// followers, weather effects, pictures, and timer. It handles the creation, updating,
    /// and disposal of these sprites.
    /// </remarks>
    public interface ISpritesetGlobal : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Gets the player sprite.
        /// </summary>
        /// <remarks>
        /// The sprite representing the player character.
        /// </remarks>
        int playersprite { get; }

        /// <summary>
        /// Initializes the global spriteset.
        /// </summary>
        /// <remarks>
        /// Sets up all global sprites including:
        /// - Follower sprites
        /// - Player sprite
        /// - Weather effects
        /// - Picture sprites
        /// - Timer sprite
        /// </remarks>
        void initialize();

        /// <summary>
        /// Updates all global sprites.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the state of all global sprites, including:
        /// - Follower sprites
        /// - Player sprite
        /// - Weather effects
        /// - Picture sprites
        /// - Timer sprite
        /// Also handles map transitions and weather effect positioning.
        /// </remarks>
        void update();
    }
}