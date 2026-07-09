using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IClippableSprite : ISpriteCharacter, IHaveUpdate
	{
		//IClippableSprite initialize(IViewport viewport,IGameEvent @event,ITilemapLoader tilemap);

		//void update();
	}

    /// <summary>
    /// Represents a spriteset that manages map-related sprites and visual effects.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing map sprites including:
    /// - Panorama backgrounds
    /// - Fog effects
    /// - Character sprites
    /// - Map tilesets and autotiles
    /// - Viewport management
    /// </remarks>
    public interface ISpritesetMap : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Gets the map associated with this spriteset.
        /// </summary>
        /// <remarks>
        /// The game map that this spriteset is rendering.
        /// </remarks>
        IGameMap map { get; }

        /// <summary>
        /// Gets the main viewport used for map rendering.
        /// </summary>
        /// <returns>The viewport used for map rendering.</returns>
        /// <remarks>
        /// This viewport is used for rendering the map, events, player, and fog effects.
        /// </remarks>
        IViewport viewport { get; }

        /// <summary>
        /// Initializes the map spriteset with an optional map.
        /// </summary>
        /// <param name="map">The map to render. If null, uses the current game map.</param>
        /// <remarks>
        /// Sets up all map-related sprites including:
        /// - Panorama background
        /// - Fog effects
        /// - Character sprites
        /// - Tilesets and autotiles
        /// </remarks>
        ISpritesetMap initialize(IGameMap map = null);

        /// <summary>
        /// Gets the current animations in the spriteset.
        /// </summary>
        /// <returns>The current animations.</returns>
        /// <remarks>
        /// Returns the user sprites that are currently active in the spriteset.
        /// </remarks>
        object getAnimations();

        /// <summary>
        /// Restores previously saved animations.
        /// </summary>
        /// <param name="anims">The animations to restore.</param>
        /// <remarks>
        /// Restores a previously saved set of animations to the spriteset.
        /// </remarks>
        void restoreAnimations(ISpriteAnimation anims);

        /// <summary>
        /// Updates all map sprites and effects.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the state of all map-related sprites, including:
        /// - Panorama background
        /// - Fog effects
        /// - Character sprites
        /// - Viewport positions and effects
        /// - Screen effects (shake, tone, flash)
        /// </remarks>
        void update();
    }
}