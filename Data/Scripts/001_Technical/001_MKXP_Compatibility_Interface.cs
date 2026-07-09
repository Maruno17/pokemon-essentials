using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for window and screen compatibility layer functions.
    /// </summary>
    public interface IMainMKXPCompatibility : IMain
    {
        /// <summary>
        /// Sets the window title text.
        /// </summary>
        /// <param name="string">The text to set as the window title.</param>
        void pbSetWindowText(string @string);

        /// <summary>
        /// Sets the window resize factor.
        /// </summary>
        /// <param name="factor">The resize factor.</param>
        void pbSetResizeFactor(int factor);
    }

    /// <summary>
    /// Interface for extended bitmap operations.
    /// </summary>
    public interface IBitmap : global::PokemonEssentials.RPGMaker.Kernel.IBitmap
    {
        /// <summary>
        /// Gets or sets the vertical text offset for drawing.
        /// </summary>
        int text_offset_y { get; set; }

        /// <summary>
        /// Draws text using a rectangle.
        /// </summary>
        /// <param name="rect">The rectangle defining the text bounds.</param>
        /// <param name="text">The text to draw.</param>
        /// <param name="align">The text alignment (0=left, 1=center, 2=right).</param>
        void draw_text(IRect rect, string text, int align = 0);

        /// <summary>
        /// Draws text using coordinates and dimensions.
        /// </summary>
        /// <param name="x">The x coordinate.</param>
        /// <param name="y">The y coordinate.</param>
        /// <param name="width">The width of the text area.</param>
        /// <param name="height">The height of the text area.</param>
        /// <param name="text">The text to draw.</param>
        /// <param name="align">The text alignment.</param>
        void draw_text(int x, int y, int width, int? height = null, string text = "", int align = 0);

        /// <summary>
        /// Original draw_text implementation, aliased to preserve behavior.
        /// </summary>
        void mkxp_draw_text(IRect rect, string text, int align = 0);

        /// <summary>
        /// Original draw_text implementation, aliased to preserve behavior.
        /// </summary>
        void mkxp_draw_text(int x, int y, int width, int height, string text, int align = 0);
    }

    /// <summary>
    /// Interface for a size object.
    /// </summary>
    public interface ISize
    {
        /// <summary>
        /// Gets or sets the width.
        /// </summary>
        int Width { get; set; }

        /// <summary>
        /// Gets or sets the height.
        /// </summary>
        int Height { get; set; }
    }

    /// <summary>
    /// Interface for version check utility.
    /// </summary>
    public interface IMKXPVersionCheck
    {
        /// <summary>
        /// Checks the engine version compatibility.
        /// </summary>
        void CheckVersion();
    }
}