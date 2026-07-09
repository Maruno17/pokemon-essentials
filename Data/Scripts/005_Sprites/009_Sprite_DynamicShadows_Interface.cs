using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a sprite that displays dynamic shadows for characters.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing dynamic shadows in the game,
    /// including shadow positioning, opacity, and angle calculations based on light sources.
    /// </remarks>
    public interface ISpriteShadow : ISprite, IHaveUpdate
    {
        /// <summary>
        /// Gets or sets the character associated with this shadow.
        /// </summary>
        /// <remarks>
        /// The character that this shadow is following.
        /// </remarks>
        int character { get; set; }

        /// <summary>
        /// Initializes the shadow sprite with a viewport and optional character.
        /// </summary>
        /// <param name="viewport">The viewport where the shadow will be displayed.</param>
        /// <param name="character">The character to attach the shadow to. Can be null.</param>
        /// <param name="parameters">Additional parameters for shadow configuration.</param>
        /// <remarks>
        /// Sets up the shadow sprite with the specified viewport and character.
        /// Parameters can include source, angle limits, opacity, and maximum distance.
        /// </remarks>
        void initialize(IViewport viewport, IGameCharacter character = null, List<string> parameters = null);

        /// <summary>
        /// Updates the shadow sprite's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the shadow's visual state, including:
        /// - Position and dimensions
        /// - Opacity based on distance
        /// - Angle based on light source
        /// - Character animation synchronization
        /// </remarks>
        void update();

        /// <summary>
        /// Checks if an element is within range of an object.
        /// </summary>
        /// <param name="element">The element to check.</param>
        /// <param name="object">The object to check against.</param>
        /// <param name="range">The maximum range to check.</param>
        /// <returns>True if the element is within range; otherwise, false.</returns>
        /// <remarks>
        /// Calculates if an element is within the specified range of an object
        /// using screen coordinates.
        /// </remarks>
        bool in_range(object element, object @object, int range);
    }

    /// <summary>
    /// Represents a character sprite with dynamic shadow support.
    /// </summary>
    /// <remarks>
    /// This interface extends the basic character sprite functionality to include
    /// dynamic shadow management.
    /// </remarks>
    public interface ISpriteCharacterWithShadows : ISpriteCharacter
    {
        /// <summary>
        /// Sets up shadows for the character.
        /// </summary>
        /// <param name="map">The map containing shadow sources.</param>
        /// <param name="shadows">The list of shadow configurations.</param>
        /// <remarks>
        /// Configures shadows for the character based on the map's shadow sources
        /// and shadow parameters.
        /// </remarks>
        void setShadows(IGameMap map, List<string> shadows);

        /// <summary>
        /// Clears all shadows associated with the character.
        /// </summary>
        /// <remarks>
        /// Removes and disposes of all shadow sprites attached to this character.
        /// </remarks>
        void clearShadows();
    }

    /// <summary>
    /// Represents a map spriteset with dynamic shadow support.
    /// </summary>
    /// <remarks>
    /// This interface extends the basic map spriteset functionality to include
    /// dynamic shadow management for all characters on the map.
    /// </remarks>
    public interface ISpritesetMapWithShadows : ISpritesetMap
    {
        /// <summary>
        /// Gets or sets the list of shadow configurations.
        /// </summary>
        /// <remarks>
        /// The list of shadow sources and their parameters for the current map.
        /// </remarks>
        int shadows { get; set; }
    }
}