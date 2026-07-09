using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a window that can display sprites.
    /// This interface defines the functionality for managing windows that can display sprites,
    /// including sprite management, animation, and rendering.
    /// </summary>
    /// <remarks>
    /// SpriteWindow is a class based on <see cref="IWindow"/> which emulates Window's functionality.
    /// This class is necessary in order to change the viewport of windows (with
    /// <see cref="Viewport"/>) and to make windows fade in and out (with <see cref="Tone"/>).
    /// </remarks>
    public interface ISpriteWindow : IWindow, IHaveUpdate, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Gets or sets the window's sprite.
        /// </summary>
        ISprite Sprite { get; set; }

        /// <summary>
        /// Gets or sets the window's bitmap.
        /// </summary>
        IBitmap Bitmap { get; set; }

        /// <summary>
        /// Gets or sets the window's viewport.
        /// </summary>
        IViewport Viewport { get; set; }

        /// <summary>
        /// Gets or sets whether the window is visible.
        /// </summary>
        bool Visible { get; set; }

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
        /// Gets or sets the window's height.
        /// </summary>
        int Height { get; set; }

        /// <summary>
        /// Gets or sets the window's opacity.
        /// </summary>
        int Opacity { get; set; }

        /// <summary>
        /// Gets or sets the window's blend type.
        /// </summary>
        int BlendType { get; set; }

        /// <summary>
        /// Gets or sets the window's tone.
        /// </summary>
        ITone Tone { get; set; }

        /// <summary>
        /// Gets or sets the window's color.
        /// </summary>
        IColor Color { get; set; }

        /// <summary>
        /// Initializes the sprite window with an optional viewport.
        /// </summary>
        /// <param name="viewport">The viewport to use, or null for the default.</param>
        new ISpriteWindow initialize(IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite window and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the sprite window has been disposed.
        /// </summary>
        /// <returns>True if the sprite window has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the sprite window's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the sprite window's appearance.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Sets the window's bitmap.
        /// </summary>
        /// <param name="bitmap">The bitmap to set.</param>
        void SetBitmap(IBitmap bitmap);

        /// <summary>
        /// Sets the window's sprite.
        /// </summary>
        /// <param name="sprite">The sprite to set.</param>
        void SetSprite(ISprite sprite);

        /// <summary>
        /// Sets the window's viewport.
        /// </summary>
        /// <param name="viewport">The viewport to set.</param>
        void SetViewport(IViewport viewport);
    }

    public interface ISpriteWindow_Base : ISpriteWindow, IHaveUpdate, IDisposable
    {
        //TEXTPADDING=4; // In pixels

        ISpriteWindow_Base initialize(float x, float y, float width, float height);

        void __setWindowskin(int skin);

        void __resolveSystemFrame();

        // Filename of windowskin to apply. Supports XP, VX, and animated skins.
        void setSkin(int skin);

        void setSystemFrame();

        //void update();

        //void dispose();
    }
}