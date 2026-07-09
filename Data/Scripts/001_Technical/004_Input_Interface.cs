using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Input module.
    /// </summary>
    public interface IInput : IHaveUpdate
    {
        int USE { get; }
        int BACK { get; }
        int ACTION { get; }
        int JUMPUP { get; }
        int JUMPDOWN { get; }
        int SPECIAL { get; }
        int AUX1 { get; }
        int AUX2 { get; }

        /// <summary>
        /// Updates the input state.
        /// </summary>
        void update();

        /// <summary>
        /// Preserved alias for original update logic.
        /// </summary>
        void update_KGC_ScreenCapture();

        /// <summary>
        /// Checks if a key is triggered.
        /// </summary>
        bool trigger(int key);

        /// <summary>
        /// Gets the current mouse X coordinate.
        /// </summary>
        int mouse_x { get; }

        /// <summary>
        /// Gets the current mouse Y coordinate.
        /// </summary>
        int mouse_y { get; }

        /// <summary>
        /// Checks if the mouse is in the window.
        /// </summary>
        bool mouse_in_window { get; }

        /// <summary>
        /// Gets or sets the clipboard contents.
        /// </summary>
        string clipboard { get; set; }
    }

    /// <summary>
    /// Interface for the Mouse module.
    /// </summary>
    public interface IMouse
    {
        /// <summary>
        /// Returns the position of the mouse relative to the game window.
        /// </summary>
        IPoint getMousePos(bool catch_anywhere = false);
    }
}