using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for animation frame constants and properties.
    /// Defines all the property indices used in animation frame data arrays
    /// for controlling sprite positioning, visual effects, and rendering properties.
    /// </summary>
    public interface IAnimFrame
    {
        /// <summary>X position property index.</summary>
        int X { get; }
        /// <summary>Y position property index.</summary>
        int Y { get; }
        /// <summary>X zoom/scale property index.</summary>
        int ZOOMX { get; }
        /// <summary>Rotation angle property index.</summary>
        int ANGLE { get; }
        /// <summary>Mirror/flip property index.</summary>
        int MIRROR { get; }
        /// <summary>Blend type property index.</summary>
        int BLENDTYPE { get; }
        /// <summary>Visibility property index.</summary>
        int VISIBLE { get; }
        /// <summary>Pattern/texture property index.</summary>
        int PATTERN { get; }
        /// <summary>Opacity property index.</summary>
        int OPACITY { get; }
        /// <summary>Y zoom/scale property index.</summary>
        int ZOOMY { get; }
        /// <summary>Color red component property index.</summary>
        int COLORRED { get; }
        /// <summary>Color green component property index.</summary>
        int COLORGREEN { get; }
        /// <summary>Color blue component property index.</summary>
        int COLORBLUE { get; }
        /// <summary>Color alpha component property index.</summary>
        int COLORALPHA { get; }
        /// <summary>Tone red component property index.</summary>
        int TONERED { get; }
        /// <summary>Tone green component property index.</summary>
        int TONEGREEN { get; }
        /// <summary>Tone blue component property index.</summary>
        int TONEBLUE { get; }
        /// <summary>Tone gray component property index.</summary>
        int TONEGRAY { get; }
        /// <summary>Lock state property index.</summary>
        int LOCKED { get; }
        /// <summary>Flash red component property index.</summary>
        int FLASHRED { get; }
        /// <summary>Flash green component property index.</summary>
        int FLASHGREEN { get; }
        /// <summary>Flash blue component property index.</summary>
        int FLASHBLUE { get; }
        /// <summary>Flash alpha component property index.</summary>
        int FLASHALPHA { get; }
        /// <summary>Rendering priority property index.</summary>
        int PRIORITY { get; }
        /// <summary>Focus target property index.</summary>
        int FOCUS { get; }
    }

    /// <summary>
    /// Interface for animation geometry calculations and transformations.
    /// Provides methods for coordinate system transformations and sprite positioning
    /// used in battle animation positioning and line-based transformations.
    /// </summary>
    public interface IMainAnimationGeometry : IMain
    {
        /// <summary>
        /// Calculates intersection parameters for a point relative to a line.
        /// Used for determining position ratios along animation transformation lines.
        /// </summary>
        /// <param name="x1">Line start X coordinate</param>
        /// <param name="y1">Line start Y coordinate</param>
        /// <param name="x2">Line end X coordinate</param>
        /// <param name="y2">Line end Y coordinate</param>
        /// <param name="px">Point X coordinate</param>
        /// <param name="py">Point Y coordinate</param>
        /// <returns>Intersection parameters as [x_ratio, y_ratio]</returns>
        double[] yaxisIntersect(double x1, double y1, double x2, double y2, double px, double py);

        /// <summary>
        /// Repositions a point along a line using transformation ratios.
        /// Maps a point from one coordinate system to another using line-based transformation.
        /// </summary>
        /// <param name="x1">Target line start X coordinate</param>
        /// <param name="y1">Target line start Y coordinate</param>
        /// <param name="x2">Target line end X coordinate</param>
        /// <param name="y2">Target line end Y coordinate</param>
        /// <param name="tx">X transformation ratio</param>
        /// <param name="ty">Y transformation ratio</param>
        /// <returns>Repositioned coordinates as [x, y]</returns>
        double[] repositionY(double x1, double y1, double x2, double y2, double tx, double ty);

        /// <summary>
        /// Transforms a point from one line coordinate system to another.
        /// Used for mapping animation coordinates between different reference frames.
        /// </summary>
        /// <param name="x1">Source line start X</param>
        /// <param name="y1">Source line start Y</param>
        /// <param name="x2">Source line end X</param>
        /// <param name="y2">Source line end Y</param>
        /// <param name="x3">Destination line start X</param>
        /// <param name="y3">Destination line start Y</param>
        /// <param name="x4">Destination line end X</param>
        /// <param name="y4">Destination line end Y</param>
        /// <param name="px">Source point X</param>
        /// <param name="py">Source point Y</param>
        /// <returns>Transformed coordinates as [x, y]</returns>
        double[] transformPoint(double x1, double y1, double x2, double y2,
                              double x3, double y3, double x4, double y4,
                              double px, double py);

        /// <summary>
        /// Gets the center coordinates of a sprite accounting for all transformations.
        /// Calculates the visual center point considering position, zoom, and origin offsets.
        /// </summary>
        /// <param name="sprite">Sprite to get center of</param>
        /// <returns>Center coordinates as [x, y], or [0, 0] if sprite is invalid</returns>
        double[] getSpriteCenter(ISprite sprite);

        /// <summary>
        /// Determines if a transformation between two lines results in reversed direction.
        /// Used to detect when animation sprites need to be flipped during transformation.
        /// </summary>
        /// <param name="src0">Source line start coordinate</param>
        /// <param name="src1">Source line end coordinate</param>
        /// <param name="dst0">Destination line start coordinate</param>
        /// <param name="dst1">Destination line end coordinate</param>
        /// <returns>True if transformation reverses direction, false otherwise</returns>
        bool isReversed(double src0, double src1, double dst0, double dst1);
    //}

    /// <summary>
    /// Interface for animation cel (frame element) creation and management.
    /// Provides methods for creating and configuring individual animation frame elements
    /// with their positioning, visual properties, and focus settings.
    /// </summary>
    //public interface IAnimationCel
    //{
        /// <summary>
        /// Creates a new animation cel with basic positioning and pattern information.
        /// Initializes a cel data structure for use in animation frames with default properties.
        /// </summary>
        /// <param name="x">X position of the cel</param>
        /// <param name="y">Y position of the cel</param>
        /// <param name="pattern">Pattern/texture index for the cel</param>
        /// <param name="focus">Focus type (1=target, 2=user, 3=user and target, 4=screen)</param>
        /// <returns>Initialized cel data array</returns>
        int[] CreateCel(int x, int y, int pattern, int focus = 4);

        /// <summary>
        /// Resets all visual properties of an animation cel to default values.
        /// Restores zoom, color, tone, opacity, and other visual effects to neutral state.
        /// </summary>
        /// <param name="frame">Cel data array to reset</param>
        void ResetCel(int[] frame);
    //}

    /// <summary>
    /// Interface for converting between different animation formats.
    /// Handles conversion from RPG Maker animation data to Pokemon Essentials animation format
    /// with proper coordinate transformation and timing preservation.
    /// </summary>
    //public interface IAnimationConverter
    //{
        /// <summary>
        /// Converts an RPG Maker animation to Pokemon Essentials animation format.
        /// Transforms coordinate systems, frame data, and timing information while
        /// preserving visual appearance and audio cues.
        /// </summary>
        /// <param name="animation">Source RPG animation to convert</param>
        /// <returns>Converted Pokemon Essentials animation</returns>
        IPBAnimation ConvertRPGAnimation(PokemonEssentials.RPGMaker.IAnimation animation);
    //}

    /// <summary>
    /// Interface for sprite animation frame application.
    /// Handles applying animation frame data to sprites including positioning,
    /// visual effects, and rendering properties with focus-based positioning.
    /// </summary>
    //public interface ISpriteAnimationFramer
    //{
        /// <summary>
        /// Applies animation frame properties to a sprite.
        /// Sets all visual properties including position, zoom, color, opacity, and visibility
        /// based on the frame data and focus settings.
        /// </summary>
        /// <param name="sprite">Sprite to modify</param>
        /// <param name="frame">Frame data array with animation properties</param>
        /// <param name="user">User sprite for focus calculations</param>
        /// <param name="target">Target sprite for focus calculations</param>
        /// <param name="inEditor">Whether running in animation editor mode</param>
        void SpriteSetAnimFrame(ISprite sprite, int[] frame, ISprite user = null,
                                 ISprite target = null, bool inEditor = false);
    }

    /// <summary>
    /// Interface for RPG Maker animation extension methods.
    /// Provides additional functionality for RPG animations including sound effects,
    /// animation composition, and frame management operations.
    /// </summary>
    public interface IRPGAnimationExtensions
    {
        /// <summary>
        /// Creates a new RPG animation from another animation with a different ID.
        /// Used for creating animation variants or duplicates with modified properties.
        /// </summary>
        /// <param name="otherAnim">Source animation to copy from</param>
        /// <param name="id">New animation ID</param>
        /// <returns>New RPG animation based on the source</returns>
        PokemonEssentials.RPGMaker.IAnimation fromOther(PokemonEssentials.RPGMaker.IAnimation otherAnim, int id);

        /// <summary>
        /// Adds a sound effect to play at a specific frame in the animation.
        /// Associates audio cues with visual animation frames for synchronized playback.
        /// </summary>
        /// <param name="frame">Frame number to play sound at</param>
        /// <param name="se">Sound effect filename</param>
        void addSound(int frame, string se);

        /// <summary>
        /// Combines another animation into this animation at a specific frame and position.
        /// Allows for complex animations composed of multiple sub-animations with timing offsets.
        /// </summary>
        /// <param name="otherAnim">Animation to add</param>
        /// <param name="frame">Frame to start the added animation</param>
        /// <param name="x">X offset for the added animation</param>
        /// <param name="y">Y offset for the added animation</param>
        void addAnimation(PokemonEssentials.RPGMaker.IAnimation otherAnim, int frame, int x, int y);
    }

    /// <summary>
    /// Interface for animation timing events that control background/foreground effects and audio.
    /// Manages timing-based events including sound effects, background changes, and screen effects
    /// that occur at specific frames during animation playback.
    /// </summary>
    public interface IPBAnimTiming
    {
        /// <summary>Animation frame when this timing event occurs.</summary>
        int frame { get; set; }

        /// <summary>Type of timing event (0=SE, 1=set bg, 2=bg mod, 3=set fg, 4=fg mod).</summary>
        int timingType { get; set; }

        /// <summary>Filename for sound effect or background/foreground graphic.</summary>
        string name { get; set; }

        /// <summary>Volume for sound effects (0-100).</summary>
        int volume { get; set; }

        /// <summary>Pitch for sound effects (50-150, 100=normal).</summary>
        int pitch { get; set; }

        /// <summary>X coordinate for background/foreground positioning.</summary>
        int? bgX { get; set; }

        /// <summary>Y coordinate for background/foreground positioning.</summary>
        int? bgY { get; set; }

        /// <summary>Opacity for background/foreground graphics (0-255).</summary>
        int? opacity { get; set; }

        /// <summary>Red color component for background/foreground (0-255).</summary>
        int? colorRed { get; set; }

        /// <summary>Green color component for background/foreground (0-255).</summary>
        int? colorGreen { get; set; }

        /// <summary>Blue color component for background/foreground (0-255).</summary>
        int? colorBlue { get; set; }

        /// <summary>Alpha color component for background/foreground (0-255).</summary>
        int? colorAlpha { get; set; }

        /// <summary>Duration in frames for gradual changes.</summary>
        int duration { get; set; }

        /// <summary>Flash scope for screen flash effects.</summary>
        int flashScope { get; set; }

        /// <summary>Flash color for screen flash effects.</summary>
        IColor flashColor { get; set; }

        /// <summary>Flash duration for screen flash effects.</summary>
        int flashDuration { get; set; }

        /// <summary>
        /// Returns a string representation of the timing event for debugging.
        /// Describes the timing type, parameters, and effects in human-readable format.
        /// </summary>
        /// <returns>Formatted description of the timing event</returns>
        string ToString();
    }

    /// <summary>
    /// Interface for collection of Pokemon Essentials animations.
    /// Manages arrays of PBAnimation objects with selection tracking and array operations
    /// for animation libraries and animation set management.
    /// </summary>
    public interface IPBAnimations
    {
        /// <summary>Internal array of animations.</summary>
        IPBAnimation[] array { get; }

        /// <summary>Currently selected animation index.</summary>
        int selected { get; set; }

        /// <summary>Number of animations in the collection.</summary>
        int length { get; }

        /// <summary>
        /// Gets an animation by name from the collection.
        /// Searches through all animations to find one with matching name.
        /// </summary>
        /// <param name="name">Name of animation to find</param>
        /// <returns>Animation with matching name, or null if not found</returns>
        IPBAnimation get_from_name(string name);

        /// <summary>
        /// Removes null entries from the animation array.
        /// Compacts the array by removing gaps left by deleted animations.
        /// </summary>
        void compact();

        /// <summary>
        /// Inserts an animation at a specific index in the collection.
        /// Shifts existing animations to make room for the new entry.
        /// </summary>
        /// <param name="index">Index to insert at</param>
        /// <param name="val">Animation to insert</param>
        void insert(int index, IPBAnimation val);

        /// <summary>
        /// Removes an animation at a specific index from the collection.
        /// Shifts remaining animations to fill the gap.
        /// </summary>
        /// <param name="index">Index to remove</param>
        void delete_at(int index);

        /// <summary>
        /// Resizes the animation collection to a specific length.
        /// Adds new empty animations or removes excess animations as needed.
        /// </summary>
        /// <param name="len">New length for the collection</param>
        void resize(int len);
    }

    /// <summary>
    /// Interface for Pokemon Essentials animation data structure.
    /// Represents a complete animation with frames, timing events, and metadata
    /// used for battle move animations and visual effects.
    /// </summary>
    public interface IPBAnimation
    {
        /// <summary>Unique identifier for the animation.</summary>
        int id { get; set; }

        /// <summary>Display name of the animation.</summary>
        string name { get; set; }

        /// <summary>Filename of the animation graphic/spritesheet.</summary>
        string graphic { get; set; }

        /// <summary>Hue adjustment for the animation graphic (0-360).</summary>
        int hue { get; set; }

        /// <summary>Position type (1=target, 2=user, 3=user and target, 4=screen).</summary>
        int position { get; set; }

        /// <summary>Animation speed (frames per second, default 20).</summary>
        int speed { get; set; }

        /// <summary>Array of animation frames containing cel data.</summary>
        int[][] array { get; }

        /// <summary>Array of timing events for sound and visual effects.</summary>
        IPBAnimTiming[] timing { get; }

        /// <summary>Maximum number of sprites supported per frame.</summary>
        int MAX_SPRITES { get; }

        /// <summary>Number of frames in the animation.</summary>
        int length { get; }

        /// <summary>
        /// Resizes the animation to have a specific number of frames.
        /// Adds new frames or removes excess frames as needed.
        /// </summary>
        /// <param name="len">New number of frames</param>
        void resize(int len);

        /// <summary>
        /// Adds a new frame to the animation with default user and target placeholders.
        /// Creates frame data with locked user and target sprites at standard positions.
        /// </summary>
        /// <returns>The newly created frame array</returns>
        int[][] addFrame();

        /// <summary>
        /// Processes timing events for a specific frame during animation playback.
        /// Handles sound effects, background changes, and visual effects that occur at this frame.
        /// </summary>
        /// <param name="frame">Current frame number</param>
        /// <param name="bgGraphic">Background graphic sprite</param>
        /// <param name="bgColor">Background color overlay</param>
        /// <param name="foGraphic">Foreground graphic sprite</param>
        /// <param name="foColor">Foreground color overlay</param>
        /// <param name="oldbg">Previous background state for transitions</param>
        /// <param name="oldfo">Previous foreground state for transitions</param>
        /// <param name="user">User battler for cry sounds</param>
        void playTiming(int frame, ISprite bgGraphic, ISprite bgColor, ISprite foGraphic,
                       ISprite foColor, object[] oldbg, object[] oldfo, IBattler user = null);
    }

    /// <summary>
    /// Interface for battle animation player that handles real-time animation playback.
    /// Manages sprite updates, timing synchronization, background/foreground effects,
    /// and coordinate transformations during battle animations.
    /// </summary>
    public interface IPBAnimationPlayerX : IHaveUpdate, IDisposable
    {
        /// <summary>Whether the animation should loop continuously.</summary>
        bool looping { get; set; }

        /// <summary>Maximum number of sprites supported simultaneously.</summary>
        int MAX_SPRITES { get; }

        /// <summary>
        /// Removes the original user and target sprites from animation involvement.
        /// Makes the animation show only its particle effects without battler sprites.
        /// </summary>
        void discard_user_and_target_sprites();

        /// <summary>
        /// Sets the target origin point for focus calculations.
        /// Used when the target position differs from the standard battle position.
        /// </summary>
        /// <param name="x">New target X coordinate</param>
        /// <param name="y">New target Y coordinate</param>
        void set_target_origin(int x, int y);

        /// <summary>
        /// Starts the animation playback from frame 0.
        /// Initializes timing and begins the animation sequence.
        /// </summary>
        void start();

        /// <summary>
        /// Checks if the animation has finished playing.
        /// Returns true when animation has completed and is no longer updating.
        /// </summary>
        /// <returns>True if animation is done, false if still playing</returns>
        bool animDone();

        /// <summary>
        /// Sets up line transformation coordinates for focus type 3 animations.
        /// Defines source and destination lines for coordinate transformation calculations.
        /// </summary>
        /// <param name="x1">Source line start X</param>
        /// <param name="y1">Source line start Y</param>
        /// <param name="x2">Source line end X</param>
        /// <param name="y2">Source line end Y</param>
        /// <param name="x3">Destination line start X</param>
        /// <param name="y3">Destination line start Y</param>
        /// <param name="x4">Destination line end X</param>
        /// <param name="y4">Destination line end Y</param>
        void setLineTransform(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4);

        /// <summary>
        /// Updates the animation by one frame based on elapsed time.
        /// Processes sprite positions, timing events, and visual effects for the current frame.
        /// Handles animation looping and disposal when animation completes.
        /// </summary>
        void update();

        /// <summary>
        /// Disposes of all animation resources including sprites and graphics.
        /// Cleans up memory used by the animation player and its components.
        /// </summary>
        void dispose();
    }
}