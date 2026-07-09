using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a cursor rectangle within a window.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing a cursor rectangle within a window,
    /// including position, size, and update tracking.
    /// </remarks>
    public interface IWindowCursorRect : IRect
    {
        /// <summary>
        /// Initializes the cursor rectangle with a reference to its parent window.
        /// </summary>
        /// <param name="window">The parent window.</param>
        IWindowCursorRect Initialize(IWindow window);

        /// <summary>
        /// Empties the cursor rectangle by setting all dimensions to 0.
        /// </summary>
        void Empty();

        /// <summary>
        /// Checks if the cursor rectangle is empty.
        /// </summary>
        /// <returns>True if all dimensions are 0, false otherwise.</returns>
        bool IsEmpty();

        /// <summary>
        /// Sets the position and size of the cursor rectangle.
        /// </summary>
        /// <param name="x">The x-coordinate.</param>
        /// <param name="y">The y-coordinate.</param>
        /// <param name="width">The width.</param>
        /// <param name="height">The height.</param>
        void Set(int x, int y, int width, int height);

        int height { set; }

        int width { set; }

        int x { set; }

        int y { set; }
    }

    /// <summary>
    /// Represents a window in the game interface.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing windows in the game interface,
    /// including appearance, content, and interaction.
    /// </remarks>
    public interface IWindow : IHaveUpdate, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Gets or sets the window's tone.
        /// </summary>
        ITone Tone { get; set; }

        /// <summary>
        /// Gets or sets the window's color.
        /// </summary>
        IColor Color { get; set; }

        /// <summary>
        /// Gets or sets the window's blend type.
        /// </summary>
        int blend_type { get; set; }
        //int BlendType { get; set; }

        /// <summary>
        /// Gets or sets the window's contents blend type.
        /// </summary>
        int contents_blend_type { get; set; }
        //int ContentsBlendType { get; set; }

        /// <summary>
        /// Gets or sets the window's viewport.
        /// </summary>
        IViewport Viewport { get; set; }

        /// <summary>
        /// Gets or sets the window's contents.
        /// </summary>
        IBitmap Contents { get; set; }

        /// <summary>
        /// Gets or sets the window's x-offset.
        /// </summary>
        int Ox { get; set; }

        /// <summary>
        /// Gets or sets the window's y-offset.
        /// </summary>
        int Oy { get; set; }

        /// <summary>
        /// Gets or sets the window's x-coordinate.
        /// </summary>
        int X { get; set; }

        /// <summary>
        /// Gets or sets the window's y-coordinate.
        /// </summary>
        int Y { get; set; }

        /// <summary>
        /// Gets or sets the window's z-coordinate.
        /// </summary>
        int Z { get; set; }

        /// <summary>
        /// Gets or sets the window's width.
        /// </summary>
        int Width { get; set; }

        /// <summary>
        /// Gets or sets whether the window is active.
        /// </summary>
        bool Active { get; set; }

        /// <summary>
        /// Gets or sets whether the window is paused.
        /// </summary>
        bool Pause { get; set; }

        /// <summary>
        /// Gets or sets the window's height.
        /// </summary>
        int Height { get; set; }

        /// <summary>
        /// Gets or sets the window's opacity.
        /// </summary>
        int Opacity { get; set; }

        /// <summary>
        /// Gets or sets the window's back opacity.
        /// </summary>
        int back_opacity { get; set; }
        //int BackOpacity { get; set; }

        /// <summary>
        /// Gets or sets the window's contents opacity.
        /// </summary>
        int contents_opacity { get; set; }
        //int ContentsOpacity { get; set; }

        /// <summary>
        /// Gets or sets whether the window is visible.
        /// </summary>
        bool Visible { get; set; }

        /// <summary>
        /// Gets or sets the window's cursor rectangle.
        /// </summary>
        IWindowCursorRect cursor_rect { get; set; }
        //IWindowCursorRect CursorRect { get; set; }

        /// <summary>
        /// Gets or sets the window's openness.
        /// </summary>
        int Openness { get; set; }

        /// <summary>
        /// Gets or sets whether the window's contents are stretched.
        /// </summary>
        bool Stretch { get; set; }

        /// <summary>
        /// Gets the window's windowskin.
        /// </summary>
        IBitmap Windowskin { get; }

        /// <summary>
        /// Initializes the window with an optional viewport.
        /// </summary>
        /// <param name="viewport">The viewport to use, or null for the default.</param>
        IWindow initialize(IViewport viewport = null);

        /// <summary>
        /// Disposes of the window and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the window has been disposed.
        /// </summary>
        /// <returns>True if the window has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the window's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the window's appearance.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        //void Refresh(bool force_refresh = false);
    }
}