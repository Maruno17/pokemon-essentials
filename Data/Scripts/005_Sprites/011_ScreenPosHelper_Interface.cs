using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a helper class for screen position calculations.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for calculating screen positions
    /// and handling screen-related transformations.
    /// </remarks>
    public interface IScreenPosHelper
    {
        /// <summary>
        /// Gets the screen width.
        /// </summary>
        int ScreenWidth { get; }

        /// <summary>
        /// Gets the screen height.
        /// </summary>
        int ScreenHeight { get; }

        /// <summary>
        /// Gets the screen center x-zoom.
        /// </summary>
        int ScreenZoomX { get; }

        /// <summary>
        /// Gets the screen center y-zoom.
        /// </summary>
        int ScreenZoomY { get; }

        /// <summary>
        /// Gets the screen center x-coordinate.
        /// </summary>
        int ScreenCenterX { get; }

        /// <summary>
        /// Gets the screen center y-coordinate.
        /// </summary>
        int ScreenCenterY { get; }

        /// <summary>
        /// Gets the screen scale.
        /// </summary>
        float ScreenScale { get; }
        /*
        /// <summary>
        /// Initializes the screen position helper.
        /// </summary>
        void Initialize();

        /// <summary>
        /// Disposes of the screen position helper and its resources.
        /// </summary>
        void Dispose();

        /// <summary>
        /// Checks if the screen position helper has been disposed.
        /// </summary>
        /// <returns>True if the screen position helper has been disposed, false otherwise.</returns>
        bool IsDisposed();

        /// <summary>
        /// Updates the screen position helper's state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the screen position helper's state.
        /// </summary>
        /// <param name="force_refresh">Whether to force a complete refresh.</param>
        void Refresh(bool force_refresh = false);

        /// <summary>
        /// Converts a world position to a screen position.
        /// </summary>
        /// <param name="x">The world x-coordinate.</param>
        /// <param name="y">The world y-coordinate.</param>
        /// <returns>A tuple containing the screen x and y coordinates.</returns>
        (int x, int y) WorldToScreen(int x, int y);

        /// <summary>
        /// Converts a screen position to a world position.
        /// </summary>
        /// <param name="x">The screen x-coordinate.</param>
        /// <param name="y">The screen y-coordinate.</param>
        /// <returns>A tuple containing the world x and y coordinates.</returns>
        (int x, int y) ScreenToWorld(int x, int y);

        /// <summary>
        /// Checks if a world position is visible on screen.
        /// </summary>
        /// <param name="x">The world x-coordinate.</param>
        /// <param name="y">The world y-coordinate.</param>
        /// <returns>True if the position is visible on screen, false otherwise.</returns>
        bool IsOnScreen(int x, int y);

        /// <summary>
        /// Gets the screen bounds.
        /// </summary>
        /// <returns>A tuple containing the screen bounds (x, y, width, height).</returns>
        (int x, int y, int width, int height) GetScreenBounds();

        /// <summary>
        /// Gets the screen center position.
        /// </summary>
        /// <returns>A tuple containing the screen center x and y coordinates.</returns>
        (int x, int y) GetScreenCenter();

        /// <summary>
        /// Gets the screen scale.
        /// </summary>
        /// <returns>The screen scale.</returns>
        float GetScreenScale();

        /// <summary>
        /// Sets the screen scale.
        /// </summary>
        /// <param name="scale">The screen scale to set.</param>
        void SetScreenScale(float scale);*/
    }
}