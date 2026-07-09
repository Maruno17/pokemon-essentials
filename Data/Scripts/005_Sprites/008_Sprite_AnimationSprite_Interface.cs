using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a sprite that handles animation effects.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing sprite animations, including:
    /// - One-time animations
    /// - Loop animations
    /// - Animation timing and effects
    /// - Sprite positioning and transformations
    /// </remarks>
    public interface ISpriteAnimation : IHaveUpdate, IDisposable
    {
        /// <summary>
        /// Initializes the animation sprite with a parent sprite.
        /// </summary>
        /// <param name="sprite">The parent sprite to attach to.</param>
        /// <remarks>
        /// Sets up the animation sprite with the specified parent sprite.
        /// </remarks>
        ISpriteAnimation initialize(ISpriteCharacter sprite);

        /// <summary>
        /// Gets or sets the x-coordinate of the animation sprite.
        /// </summary>
        int x { get; set; }

        /// <summary>
        /// Gets or sets the y-coordinate of the animation sprite.
        /// </summary>
        int y { get; set; }

        /// <summary>
        /// Gets or sets the origin x-coordinate of the animation sprite.
        /// </summary>
        int ox { get; set; }

        /// <summary>
        /// Gets or sets the origin y-coordinate of the animation sprite.
        /// </summary>
        int oy { get; set; }

        /// <summary>
        /// Gets or sets the viewport of the animation sprite.
        /// </summary>
        IViewport viewport { get; set; }

        /// <summary>
        /// Flashes the animation sprite with a color.
        /// </summary>
        /// <param name="color">The color to flash with.</param>
        /// <param name="duration">The duration of the flash.</param>
        void flash(IColor color, int duration);

        /// <summary>
        /// Gets or sets the source rectangle of the animation sprite.
        /// </summary>
        IRect src_rect { get; set; }

        /// <summary>
        /// Gets or sets the opacity of the animation sprite.
        /// </summary>
        int opacity { get; set; }

        /// <summary>
        /// Gets or sets the tone of the animation sprite.
        /// </summary>
        ITone tone { get; set; }

        /// <summary>
        /// Clears all animations.
        /// </summary>
        /// <remarks>
        /// Removes all stored animations and resets the animation system.
        /// </remarks>
        void clear();

        /// <summary>
        /// Plays a one-time animation.
        /// </summary>
        /// <param name="animation">The animation to play.</param>
        /// <param name="hit">Whether the animation hit its target.</param>
        /// <param name="height">The height level of the animation.</param>
        /// <param name="no_tone">Whether to ignore tone effects.</param>
        /// <remarks>
        /// Plays a single animation sequence with the specified parameters.
        /// </remarks>
        void animation(IAnimation animation, bool hit, int height = 3, bool no_tone = false);

        /// <summary>
        /// Plays a looping animation.
        /// </summary>
        /// <param name="animation">The animation to loop.</param>
        /// <remarks>
        /// Plays an animation that repeats continuously until stopped.
        /// </remarks>
        void loop_animation(IAnimation animation);

        /// <summary>
        /// Disposes of the current animation.
        /// </summary>
        /// <remarks>
        /// Cleans up resources used by the current one-time animation.
        /// </remarks>
        void dispose_animation();

        /// <summary>
        /// Disposes of the current loop animation.
        /// </summary>
        /// <remarks>
        /// Cleans up resources used by the current looping animation.
        /// </remarks>
        void dispose_loop_animation();

        /// <summary>
        /// Checks if any animation is currently active.
        /// </summary>
        /// <returns>True if an animation is active; otherwise, false.</returns>
        //bool active();
        bool active { get; }

        /// <summary>
        /// Checks if an effect is currently playing.
        /// </summary>
        /// <returns>True if an effect is playing; otherwise, false.</returns>
        bool effect();

        /// <summary>
        /// Updates the animation sprite's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the animation state, including:
        /// - Updating one-time animations
        /// - Updating loop animations
        /// - Processing animation timing
        /// - Managing sprite transformations
        /// </remarks>
        void update();

        void update_animation();

        void update_loop_animation();

        /// <summary></summary>
        void animation_set_sprites(RPGMaker.ISystem[] sprites, int[,] cell_data, int position, bool quick_update = false);

        /// <summary></summary>
        void animation_process_timing(ISpriteTimer timing, bool hit);
    }

    /// <summary>
    /// Represents a container for animation sprites.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing collections of animation sprites,
    /// particularly for map-based animations and effects.
    /// </remarks>
    public interface IAnimationContainerSprite : PokemonEssentials.RPGMaker.Kernel.ISprite, IHaveUpdate
    {
        /// <summary>
        /// Initializes the animation container with animation parameters.
        /// </summary>
        /// <param name="animID">The ID of the animation to play.</param>
        /// <param name="map">The map where the animation is displayed.</param>
        /// <param name="tileX">The x-coordinate of the tile.</param>
        /// <param name="tileY">The y-coordinate of the tile.</param>
        /// <param name="viewport">The viewport to display in. Can be null.</param>
        /// <param name="tinting">Whether to apply tinting effects.</param>
        /// <param name="height">The height level of the animation.</param>
        void initialize(int animID, IGameMap map, int tileX, int tileY, IViewport viewport = null, bool tinting = false, int height = 3);

        /// <summary>
        /// Sets the coordinates of the animation container.
        /// </summary>
        /// <remarks>
        /// Updates the position of the animation container based on its tile coordinates.
        /// </remarks>
        void setCoords();

        /// <summary>
        /// Updates the animation container's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the animation container's state,
        /// including position and animation progress.
        /// </remarks>
        void update();
    }

    public interface ISpritesetMapAnimationSprite : ISpritesetMap, IHaveUpdate, IDisposable
    {
        //IGameMap map			{ get; }
        //IViewport viewport1		{ get; }
        //ITilemapLoader tilemap	{ get; }

        new ISpritesetMapAnimationSprite initialize(IGameMap map = null);

        // Used to display animations that remain in the same location on the map.
        // Typically for grass rustling and dust clouds, and other animations that
        // aren't relative to an event.
        void addUserAnimation(int animID, float x, float y, bool tinting = false, int height = 3);

        void addUserSprite(ISpriteAnimation new_sprite);

        //void dispose();

        void update();
    }
}