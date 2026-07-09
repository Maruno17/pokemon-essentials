using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for animated item icon sprites that can display item graphics with animation support.
    /// Handles both static and animated item icons with proper frame cycling.
    /// </summary>
    public interface IItemIconSprite : ISprite, IHaveUpdate, IDisposable
    {
        /// <summary>
        /// The item this sprite represents.
        /// </summary>
        int item { get; set; }

        /// <summary>
        /// Height in pixels the item's icon graphic must be for it to be animated.
        /// Default value is 48 pixels for horizontal frame animations.
        /// </summary>
        int ANIM_ICON_SIZE { get; }

        /// <summary>
        /// Time in seconds for one animation cycle of this item icon.
        /// Default value is 1.0 second per complete cycle.
        /// </summary>
        double ANIMATION_DURATION { get; }

        /// <summary>
        /// Whether to display a blank sprite when the item is null/zero.
        /// </summary>
        bool blankzero { set; }

        /// <summary>
        /// Initializes the item icon sprite.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="item">The item to display</param>
        /// <param name="viewport">The viewport (optional)</param>
        IItemIconSprite initialize(int x, int y, object item, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Gets the width of the sprite.
        /// For animated sprites, returns the width of a single frame.
        /// </summary>
        /// <returns>The sprite width in pixels</returns>
        int width();

        /// <summary>
        /// Gets the height of the sprite.
        /// </summary>
        /// <returns>The sprite height in pixels</returns>
        int height();

        /// <summary>
        /// Sets the origin offset for the sprite positioning.
        /// </summary>
        /// <param name="offset">The picture origin (default: CENTER)</param>
        void setOffset(int offset);

        /// <summary>
        /// Changes the sprite's origin based on the current offset setting.
        /// </summary>
        void changeOrigin();

        /// <summary>
        /// Updates the current animation frame based on elapsed time.
        /// </summary>
        void update_frame();

        /// <summary>
        /// Updates the sprite, including animation frame progression.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for item held icon sprites used in party screens to show items held by Pokémon.
    /// Automatically updates to reflect the Pokémon's currently held item.
    /// </summary>
    public interface IHeldItemIconSprite : ISprite, IHaveUpdate, IDisposable
    {
        /// <summary>
        /// The Pokémon whose held item this sprite represents.
        /// </summary>
        IPokemon pokemon { set; }

        /// <summary>
        /// The item currently being displayed.
        /// </summary>
        int item { set; }

        /// <summary>
        /// Initializes the held item icon sprite.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="pokemon">The Pokémon to track</param>
        /// <param name="viewport">The viewport (optional)</param>
        IHeldItemIconSprite initialize(int x, int y, IPokemon pokemon, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Updates the sprite to reflect the Pokémon's current held item.
        /// </summary>
        void update();
    }
    /*
    /// <summary>
    /// Interface for item sprite management and utility functions.
    /// </summary>
    public interface IItemSpriteManager
    {
        /// <summary>
        /// Creates a new item icon sprite.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="item">The item to display</param>
        /// <param name="viewport">The viewport (optional)</param>
        /// <returns>A new item icon sprite instance</returns>
        IItemIconSprite create_item_icon(int x, int y, object item, IViewport viewport = null);

        /// <summary>
        /// Creates a new held item icon sprite.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <param name="pokemon">The Pokémon to track</param>
        /// <param name="viewport">The viewport (optional)</param>
        /// <returns>A new held item icon sprite instance</returns>
        IHeldItemIconSprite create_held_item_icon(int x, int y, IPokemon pokemon, IViewport viewport = null);

        /// <summary>
        /// Gets the icon filename for an item.
        /// </summary>
        /// <param name="item">The item</param>
        /// <returns>The filename for the item's icon</returns>
        string get_item_icon_filename(object item);

        /// <summary>
        /// Gets the held icon filename for an item.
        /// </summary>
        /// <param name="item">The item</param>
        /// <returns>The filename for the item's held icon</returns>
        string get_held_item_icon_filename(object item);

        /// <summary>
        /// Checks if an item has an animated icon.
        /// </summary>
        /// <param name="item">The item to check</param>
        /// <returns>True if the item has animation frames</returns>
        bool is_animated_item(object item);

        /// <summary>
        /// Gets the number of animation frames for an item.
        /// </summary>
        /// <param name="item">The item</param>
        /// <returns>The number of animation frames</returns>
        int get_animation_frame_count(object item);

        /// <summary>
        /// Calculates the current animation frame for an item.
        /// </summary>
        /// <param name="frameCount">Total number of frames</param>
        /// <param name="duration">Animation duration in seconds</param>
        /// <returns>The current frame index</returns>
        int calculate_current_frame(int frameCount, double duration);
    }

    /// <summary>
    /// Interface for sprite positioning and origin management.
    /// </summary>
    public interface ISpritePositioning
    {
        /// <summary>
        /// Sets the sprite's position.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        void set_position(int x, int y);

        /// <summary>
        /// Sets the sprite's origin offset.
        /// </summary>
        /// <param name="ox">X origin offset</param>
        /// <param name="oy">Y origin offset</param>
        void set_origin(int ox, int oy);

        /// <summary>
        /// Applies positioning based on picture origin settings.
        /// </summary>
        /// <param name="origin">The picture origin type</param>
        /// <param name="width">Sprite width</param>
        /// <param name="height">Sprite height</param>
        void apply_origin_positioning(object origin, int width, int height);

        /// <summary>
        /// Centers the sprite at the given coordinates.
        /// </summary>
        /// <param name="x">Center X coordinate</param>
        /// <param name="y">Center Y coordinate</param>
        void center_at(int x, int y);

        /// <summary>
        /// Aligns the sprite to a specific edge or corner.
        /// </summary>
        /// <param name="alignment">The alignment type</param>
        /// <param name="bounds">The bounds to align within</param>
        void align_to(object alignment, object bounds);
    }

    /// <summary>
    /// Interface for animated bitmap management within item sprites.
    /// </summary>
    public interface IAnimatedBitmapManager
    {
        /// <summary>
        /// Loads an animated bitmap from a file.
        /// </summary>
        /// <param name="filename">The bitmap file to load</param>
        /// <returns>An animated bitmap instance</returns>
        object load_animated_bitmap(string filename);

        /// <summary>
        /// Updates an animated bitmap's current frame.
        /// </summary>
        /// <param name="animatedBitmap">The animated bitmap to update</param>
        void update_animated_bitmap(object animatedBitmap);

        /// <summary>
        /// Disposes of an animated bitmap's resources.
        /// </summary>
        /// <param name="animatedBitmap">The animated bitmap to dispose</param>
        void dispose_animated_bitmap(object animatedBitmap);

        /// <summary>
        /// Gets the current bitmap frame from an animated bitmap.
        /// </summary>
        /// <param name="animatedBitmap">The animated bitmap</param>
        /// <returns>The current frame bitmap</returns>
        object get_current_frame(object animatedBitmap);

        /// <summary>
        /// Checks if a bitmap file contains animation frames.
        /// </summary>
        /// <param name="filename">The bitmap filename</param>
        /// <returns>True if the bitmap contains multiple frames</returns>
        bool has_animation_frames(string filename);

        /// <summary>
        /// Sets the source rectangle for a specific animation frame.
        /// </summary>
        /// <param name="sprite">The sprite to update</param>
        /// <param name="frameIndex">The frame index</param>
        /// <param name="frameWidth">Width of each frame</param>
        /// <param name="frameHeight">Height of each frame</param>
        void set_frame_source_rect(object sprite, int frameIndex, int frameWidth, int frameHeight);
    }
    */
}