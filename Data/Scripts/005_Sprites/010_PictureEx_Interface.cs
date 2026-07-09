using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents an extended picture with advanced animation and transformation capabilities.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for manipulating and animating pictures in the game.
    /// It supports various transformations, effects, and animations through a process-based system.
    /// </remarks>
    public interface IPictureEx : IHaveUpdate
    {
        /// <summary>Gets or sets the x-coordinate of the picture.</summary>
        int x { get; set; }

        /// <summary>Gets or sets the y-coordinate of the picture.</summary>
        int y { get; set; }

        /// <summary>Gets or sets the z-order of the picture.</summary>
        int z { get; set; }

        /// <summary>Gets or sets the x-direction zoom rate of the picture.</summary>
        int zoom_x { get; set; }

        /// <summary>Gets or sets the y-direction zoom rate of the picture.</summary>
        int zoom_y { get; set; }

        /// <summary>Gets or sets the rotation angle of the picture.</summary>
        int angle { get; set; }

        /// <summary>Gets or sets the tone of the picture.</summary>
        ITone tone { get; set; }

        /// <summary>Gets or sets the color of the picture.</summary>
        IColor color { get; set; }

        /// <summary>Gets or sets the hue of the picture.</summary>
        int hue { get; set; }

        /// <summary>Gets or sets the opacity level of the picture.</summary>
        int opacity { get; set; }

        /// <summary>Gets or sets the visibility of the picture.</summary>
        int visible { get; set; }

        /// <summary>Gets or sets the blend method of the picture.</summary>
        int blend_type { get; set; }

        /// <summary>Gets or sets the file name of the picture.</summary>
        int name { get; set; }

        /// <summary>Gets or sets the origin point of the picture.</summary>
        int origin { get; set; }

        /// <summary>Gets the source rectangle of the picture.</summary>
        IRect src_rect { get; }

        /// <summary>Gets the y-coordinate for cropping the bottom of the picture.</summary>
        int cropBottom { get; }

        /// <summary>Gets the array of processes updated in a frame.</summary>
        int frameUpdates { get; }

        /// <summary>
        /// Gets a list of movement processes for the picture.
        /// </summary>
        /// <returns>A list of movement process descriptions.</returns>
        /// <remarks>
        /// This method analyzes the picture's processes and returns a human-readable
        /// description of all movement-related processes (XY and DELTA_XY).
        /// </remarks>
        void move_processes();

		/// <summary>
		/// Initializes a new instance of the PictureEx class.
		/// </summary>
		/// <param name="z">The initial z-order of the picture.</param>
		/// <remarks>
		/// Sets up a new picture with default values for all properties and initializes
		/// the process list. The picture starts with default position, scale, and visual
		/// properties.
		/// </remarks>
		IPictureEx initialize(int z);

        /// <summary>
        /// Executes a callback function for the picture.
        /// </summary>
        /// <param name="cb">The callback to execute.</param>
        /// <remarks>
        /// This method handles different types of callbacks (Proc, Array, or Method)
        /// and executes them with the picture as the context.
        /// </remarks>
        void callback(object cb);

        /// <summary>
        /// Sets a callback to be executed after a delay.
        /// </summary>
        /// <param name="delay">The delay before executing the callback.</param>
        /// <param name="cb">The callback to execute. Can be null.</param>
        /// <remarks>
        /// Adds a callback process to the picture's process list. The callback will be
        /// executed after the specified delay.
        /// </remarks>
        void setCallback(int delay, object cb = null);

        /// <summary>
        /// Checks if the picture has any running processes.
        /// </summary>
        /// <returns>True if there are any processes in the process list; otherwise, false.</returns>
        /// <remarks>
        /// This method is used to determine if the picture is currently undergoing
        /// any transformations or animations.
        /// </remarks>
        bool running();

        /// <summary>
        /// Calculates the total duration of all processes.
        /// </summary>
        /// <returns>The total duration in frames.</returns>
        /// <remarks>
        /// This method finds the longest duration among all processes in the process list,
        /// which represents the total time needed to complete all animations and transformations.
        /// </remarks>
        void totalDuration();

        /// <summary>
        /// Ensures that a delay and duration are valid.
        /// </summary>
        /// <param name="delay">The delay to validate.</param>
        /// <param name="duration">The duration to validate. Can be null.</param>
        /// <returns>The validated delay and duration.</returns>
        /// <remarks>
        /// If the delay is negative, it is set to the total duration of all processes.
        /// This ensures that new processes start after all existing processes are complete.
        /// </remarks>
        void ensureDelayAndDuration(int delay, int? duration = null);

        /// <summary>
        /// Ensures that a delay is valid.
        /// </summary>
        /// <param name="delay">The delay to validate.</param>
        /// <returns>The validated delay.</returns>
        /// <remarks>
        /// This is a convenience method that calls ensureDelayAndDuration with a null duration.
        /// </remarks>
        void ensureDelay(int delay);

        /// <summary>
        /// Sets the rotation speed for the picture.
        /// </summary>
        /// <param name="speed">The angle to change by in 1/20 of a second.</param>
        /// <remarks>
        /// This method sets up automatic rotation for the picture. The speed parameter
        /// is converted to a per-frame rotation amount. Note that this is not compatible
        /// with manual angle changes.
        /// </remarks>
        void rotate(int speed);

        /// <summary>
        /// Erases the picture by clearing its name.
        /// </summary>
        /// <remarks>
        /// This method effectively removes the picture by setting its name to an empty string.
        /// </remarks>
        void erase();

        /// <summary>
        /// Clears all processes from the picture.
        /// </summary>
        /// <remarks>
        /// This method removes all pending transformations and animations from the picture's
        /// process list and resets the timer.
        /// </remarks>
        void clearProcesses();

        /// <summary>
        /// Adjusts the position of all XY processes.
        /// </summary>
        /// <param name="xOffset">The amount to offset the x-coordinate.</param>
        /// <param name="yOffset">The amount to offset the y-coordinate.</param>
        /// <remarks>
        /// This method modifies all XY processes in the process list by adding the specified
        /// offsets to their target positions.
        /// </remarks>
        void adjustPosition(int xOffset, int yOffset);

        /// <summary>
        /// Moves the picture with multiple transformations.
        /// </summary>
        /// <param name="delay">The delay before starting the movement.</param>
        /// <param name="duration">The duration of the movement.</param>
        /// <param name="origin">The origin point for the movement.</param>
        /// <param name="x">The target x-coordinate.</param>
        /// <param name="y">The target y-coordinate.</param>
        /// <param name="zoom_x">The target x-zoom rate. Default is 100.0f.</param>
        /// <param name="zoom_y">The target y-zoom rate. Default is 100.0f.</param>
        /// <param name="opacity">The target opacity. Default is 255.</param>
        /// <remarks>
        /// This method combines multiple transformations into a single movement process,
        /// including position, zoom, and opacity changes.
        /// </remarks>
        void move(int delay, int duration, int origin, int x, int y, float zoom_x = 100.0f, float zoom_y = 100.0f, int opacity = 255);

        void moveXY(int delay, int duration, int x, int y, object cb = null);
        void setXY(int delay, int x, int y, object cb = null);
        void moveCurve(int delay, int duration, int x1, int y1, int x2, int y2, int x3, int y3, object cb = null);
        void moveDelta(int delay, int duration, int x, int y, object cb = null);
        void setDelta(int delay, int x, int y, object cb = null);
        void moveZ(int delay, int duration, int z, object cb = null);
        void setZ(int delay, int z, object cb = null);
        void moveZoomXY(int delay, int duration, float zoom_x, float zoom_y, object cb = null);
        void setZoomXY(int delay, float zoom_x, float zoom_y, object cb = null);
        void moveZoom(int delay, int duration, float zoom, object cb = null);
        void setZoom(int delay, float zoom, object cb = null);
        void moveAngle(int delay, int duration, float angle, object cb = null);
        void setAngle(int delay, float angle, object cb = null);
        void moveTone(int delay, int duration, float tone, object cb = null);
        void setTone(int delay, int tone, object cb = null);
        void moveColor(int delay, float duration, int color, object cb = null);
        void setColor(int delay, int color, object cb = null);
        [System.Obsolete("Hue changes don't actually work.")]
        void moveHue(int delay, int duration, int hue, object cb = null);
        [System.Obsolete("Hue changes don't actually work.")]
        void setHue(int delay, int hue, object cb = null);
        void moveOpacity(int delay, int duration, int opacity, object cb = null);
        void setOpacity(int delay, int opacity, object cb = null);
        void setVisible(int delay, int visible, object cb = null);
        [System.Obsolete("Only values of 0 (normal), 1 (additive) and 2 (subtractive) are allowed.")]
        void setBlendType(int delay, int blend, object cb = null);
        void setSE(int delay, int seFile, float? volume = null, float? pitch = null, object cb = null);
        void setName(int delay, string name, object cb = null);
        void setOrigin(int delay, int origin, object cb = null);
        void setSrc(int delay, int srcX, int srcY, object cb = null);
        void setSrcSize(int delay, int srcWidth, int srcHeight, object cb = null);
        [System.Obsolete("Used to cut Pokémon sprites off when they faint and sink into the ground.")]
        void setCropBottom(int delay, int y, object cb = null);

        /// <summary>
        /// Updates the picture's state.
        /// </summary>
        /// <remarks>
        /// This method is called each frame to update the picture's state, including:
        /// - Processing all active transformations
        /// - Updating animations
        /// - Applying visual effects
        /// - Managing callbacks
        /// </remarks>
        void update();
    }

    public interface IMainPictureEx : IMain
    {
        void getCubicPoint2(object src, int t);
        void setPictureSprite(ISprite sprite, IPictureEx picture, bool iconSprite = false);
        void setPictureIconSprite(ISprite sprite, IPictureEx picture);
    }
}