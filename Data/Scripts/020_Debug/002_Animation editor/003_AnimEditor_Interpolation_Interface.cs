using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides interpolation and path functionality for battle animation editing.
    /// Contains tools for creating smooth animation paths and managing control points in the animation editor.
    /// </summary>
    public interface IBattleAnimationEditorInterpolation : IBattleAnimationEditor
    {
    }

    /// <summary>
    /// Provides a draggable control point sprite for defining animation paths.
    /// Used to create Bezier curves and other smooth animation trajectories.
    /// </summary>
    public interface IControlPointSprite
    {
        /// <summary>
        /// Whether the control point is currently being dragged.
        /// </summary>
        bool dragging { get; set; }

        /// <summary>
        /// Initializes the control point sprite with color coding and viewport.
        /// </summary>
        /// <param name="red">Whether the control point should be colored red for emphasis.</param>
        /// <param name="viewport">Optional viewport for the sprite.</param>
        void initialize(bool red, IViewport viewport = null);

        /// <summary>
        /// Handles mouse interaction for dragging the control point.
        /// Updates the sprite position based on mouse movement when dragging.
        /// </summary>
        void mouseover();

        /// <summary>
        /// Performs hit testing to determine if the mouse is over this control point.
        /// </summary>
        /// <returns>True if the mouse cursor is over the control point.</returns>
        bool hittest();

        /// <summary>
        /// Returns a string representation of the control point's position.
        /// </summary>
        /// <returns>Formatted string showing X and Y coordinates.</returns>
        string inspect();

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();
    }

    /// <summary>
    /// Provides a simple point sprite for marking positions in animation paths.
    /// Used to visualize points along calculated animation curves.
    /// </summary>
    public interface IPointSprite
    {
        /// <summary>
        /// Initializes the point sprite at the specified coordinates.
        /// </summary>
        /// <param name="x">X coordinate for the point.</param>
        /// <param name="y">Y coordinate for the point.</param>
        /// <param name="viewport">Optional viewport for the sprite.</param>
        void initialize(int x, int y, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();
    }

    /// <summary>
    /// Provides a path system for managing sequences of points in animations.
    /// Used to create complex animation trajectories and interpolated movement paths.
    /// </summary>
    public interface IPointPath
    {
        /// <summary>
        /// Gets a point at the specified index.
        /// </summary>
        /// <param name="x">Index of the point to retrieve.</param>
        /// <returns>Copy of the point at the specified index.</returns>
        object this[int x] { get; }

        /// <summary>
        /// Gets the number of points in the path.
        /// </summary>
        /// <returns>The total number of points.</returns>
        int size { get; }

        /// <summary>
        /// Gets the length of the path.
        /// </summary>
        /// <returns>The number of points in the path.</returns>
        int length { get; }

        /// <summary>
        /// Initializes an empty point path.
        /// </summary>
        void initialize();

        /// <summary>
        /// Iterates through all points in the path.
        /// </summary>
        /// <returns>Enumerable collection of path points.</returns>
        IEnumerable<object> each();
    }
}