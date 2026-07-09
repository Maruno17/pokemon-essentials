using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents the configuration for message windows and text display.
    /// </summary>
    /// <remarks>
    /// This interface defines the functionality for managing message window appearance,
    /// text formatting, and window positioning, including:
    /// - Window skin management
    /// - Font configuration
    /// - Text speed settings
    /// - Color schemes
    /// - Window positioning
    /// </remarks>
    public interface IMessageConfig
    {
        /// <summary>
        /// Gets the default system window frame.
        /// </summary>
        /// <remarks>
        /// Returns the default window frame bitmap based on the current system settings.
        /// </remarks>
        string DefaultSystemFrame { get; }

        /// <summary>
        /// Gets the default speech window frame.
        /// </summary>
        /// <remarks>
        /// Returns the default speech window frame bitmap based on the current system settings.
        /// </remarks>
        string DefaultSpeechFrame { get; }

        /// <summary>
        /// Gets the default windowskin.
        /// </summary>
        /// <remarks>
        /// Returns the default windowskin bitmap based on the current system settings.
        /// </remarks>
        string DefaultWindowskin { get; }

        /// <summary>
        /// Gets the current system frame.
        /// </summary>
        /// <remarks>
        /// Returns the currently active system frame bitmap.
        /// </remarks>
        string GetSystemFrame { get; }

        /// <summary>
        /// Gets the current speech frame.
        /// </summary>
        /// <remarks>
        /// Returns the currently active speech frame bitmap.
        /// </remarks>
        string GetSpeechFrame { get; }

        /// <summary>
        /// Sets the system frame.
        /// </summary>
        /// <param name="value">The path to the new system frame bitmap.</param>
        void SetSystemFrame(string value);

        /// <summary>
        /// Sets the speech frame.
        /// </summary>
        /// <param name="value">The path to the new speech frame bitmap.</param>
        void SetSpeechFrame(string value);

        /// <summary>
        /// Gets the default text speed.
        /// </summary>
        /// <remarks>
        /// Returns the default text speed based on the current system settings.
        /// </remarks>
        float DefaultTextSpeed { get; }

        /// <summary>
        /// Gets the current text speed.
        /// </summary>
        /// <remarks>
        /// Returns the currently active text speed setting.
        /// </remarks>
        float GetTextSpeed { get; }

        /// <summary>
        /// Sets the text speed.
        /// </summary>
        /// <param name="value">The new text speed value.</param>
        void SetTextSpeed(float value);

        /// <summary>
        /// Converts a speed setting to a text speed value.
        /// </summary>
        /// <param name="speed">The speed setting to convert.</param>
        /// <returns>The corresponding text speed value.</returns>
        float SettingToTextSpeed(int? speed);

        /// <summary>
        /// Gets the default system font name.
        /// </summary>
        /// <remarks>
        /// Returns the default system font name based on the current system settings.
        /// </remarks>
        string DefaultSystemFontName { get; }

        /// <summary>
        /// Gets the default small font name.
        /// </summary>
        /// <remarks>
        /// Returns the default small font name based on the current system settings.
        /// </remarks>
        string DefaultSmallFontName { get; }

        /// <summary>
        /// Gets the default narrow font name.
        /// </summary>
        /// <remarks>
        /// Returns the default narrow font name based on the current system settings.
        /// </remarks>
        string DefaultNarrowFontName { get; }

        /// <summary>
        /// Gets the current system font name.
        /// </summary>
        /// <remarks>
        /// Returns the currently active system font name.
        /// </remarks>
        string GetSystemFontName { get; }

        /// <summary>
        /// Gets the current small font name.
        /// </summary>
        /// <remarks>
        /// Returns the currently active small font name.
        /// </remarks>
        string GetSmallFontName { get; }

        /// <summary>
        /// Gets the current narrow font name.
        /// </summary>
        /// <remarks>
        /// Returns the currently active narrow font name.
        /// </remarks>
        string GetNarrowFontName { get; }

        /// <summary>
        /// Sets the system font name.
        /// </summary>
        /// <param name="value">The new system font name.</param>
        void SetSystemFontName(string value);

        /// <summary>
        /// Sets the small font name.
        /// </summary>
        /// <param name="value">The new small font name.</param>
        void SetSmallFontName(string value);

        /// <summary>
        /// Sets the narrow font name.
        /// </summary>
        /// <param name="value">The new narrow font name.</param>
        void SetNarrowFontName(string value);

        /// <summary>
        /// Tries to find an available font from a list of options.
        /// </summary>
        /// <param name="args">The list of font names to try.</param>
        /// <returns>The first available font name, or an empty string if none are available.</returns>
        string TryFonts(params string[] args);
    }

    /// <summary>
    /// Represents a collection of window positioning and management functions.
    /// </summary>
    /// <remarks>
    /// This interface defines utility functions for positioning and managing windows,
    /// including message windows, command windows, and face windows.
    /// </remarks>
    public interface IMainWindowPositioner : IMain
    {
        /// <summary>
        /// Positions a window at the bottom right of the screen.
        /// </summary>
        /// <param name="window">The window to position.</param>
        void BottomRight(IWindow window);

        /// <summary>
        /// Positions a window at the bottom left of the screen.
        /// </summary>
        /// <param name="window">The window to position.</param>
        void BottomLeft(IWindow window);

        /// <summary>
        /// Positions a window at the bottom left with a specific number of lines.
        /// </summary>
        /// <param name="window">The window to position.</param>
        /// <param name="lines">The number of lines to display.</param>
        /// <param name="width">The width of the window. If null, uses screen width.</param>
        void BottomLeftLines(IWindow window, int lines, float? width = null);

        /// <summary>
        /// Positions a face window relative to a message window.
        /// </summary>
        /// <param name="facewindow">The face window to position.</param>
        /// <param name="msgwindow">The message window to position relative to.</param>
        void PositionFaceWindow(IWindow facewindow, IWindow msgwindow);

        /// <summary>
        /// Positions a command window near a message window.
        /// </summary>
        /// <param name="cmdwindow">The command window to position.</param>
        /// <param name="msgwindow">The message window to position relative to.</param>
        /// <param name="side">The side to position the command window on.</param>
        void PositionNearMsgWindow(IWindow cmdwindow, IWindow msgwindow, string side);

        /// <summary>
        /// Repositions a message window.
        /// </summary>
        /// <param name="msgwindow">The message window to reposition.</param>
        /// <param name="linecount">The number of lines to display.</param>
        void RepositionMessageWindow(IWindow msgwindow, int linecount = 2);

        /// <summary>
        /// Updates a message window's position based on an event.
        /// </summary>
        /// <param name="msgwindow">The message window to update.</param>
        /// <param name="_event">The event to position relative to.</param>
        /// <param name="eventChanged">Whether the event has changed.</param>
        void UpdateMsgWindowPos(IWindow msgwindow, IGameEvent _event, bool eventChanged = false);

        // Determine the colour of a background.
        bool isDarkBackground(string background, IRect rect = null);
        void isDarkWindowskin(string windowskin);

        // Determine which text colours to use based on the darkness of the background.
        void get_text_colors_for_windowskin(string windowskin, IColor color, bool isDarkSkin);
        void getDefaultTextColors(string windowskin);
        /// <summary>
        /// Makes sure a bitmap exists.
        /// </summary>
        /// <param name="bitmap"></param>
        /// <param name="dwidth"></param>
        /// <param name="dheight"></param>
        void DoEnsureBitmap(IBitmap bitmap, int dwidth,int dheight);

        // Set a bitmap's font.
        /// <summary>
        /// Sets a bitmap's font to the system font.
        /// </summary>
        /// <param name="bitmap"></param>
        void SetSystemFont(IBitmap bitmap);
        /// <summary>
        /// Sets a bitmap's font to the system small font.
        /// </summary>
        /// <param name="bitmap"></param>
        void SetSmallFont(IBitmap bitmap);
        /// <summary>
        /// Sets a bitmap's font to the system narrow font.
        /// </summary>
        /// <param name="bitmap"></param>
        void SetNarrowFont(IBitmap bitmap);

        // Blend colours, set the colour of all bitmaps in a sprite hash.
        void AlphaBlend(IColor dstColor,IColor  srcColor);
        void SrcOver(IColor dstColor, IColor srcColor);
        void SetSpritesToColor(IDictionary<string, ISprite> sprites, IColor color);
        // Update and dispose sprite hashes.
        void UpdateSpriteHash(IWindow windows);
        /// <summary>
        /// Disposes all objects in the specified hash.
        /// </summary>
        /// <param name="sprites"></param>
        void DisposeSpriteHash(IDictionary<string, ISprite> sprites);
        /// <summary>
        /// Disposes the specified graphics object within the specified hash.
        /// </summary>
        /// <remarks>
        /// Basically like:   sprites[id].dispose();
        /// </remarks>
        /// <param name="sprites"></param>
        /// <param name="id"></param>
        void DisposeSprite(IDictionary<string, ISprite> sprites, int id);

        // Fades and window activations for sprite hashes.
        void PushFade();
        void IsFaded();
        void PopFade();
        /// <summary>
        /// Fades out the screen before a block is run and fades it back in after the block exits.
        /// </summary>
        /// <param name="z">indicates the z-coordinate of the viewport used for this effect</param>
        /// <param name="nofadeout"></param>
        void FadeOutIn(int z = 99999, bool nofadeout = false);
        void FadeOutInWithUpdate(int z, IDictionary<string, ISprite> sprites, bool nofadeout = false);
        /// <summary>
        /// Similar to FadeOutIn, but pauses the music as it fades out.
        /// </summary>
        /// <param name="zViewport"></param>
        /// Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for FadeOutIn).
        void FadeOutInWithMusic(int zViewport = 99999);
        void FadeOutAndHide(IDictionary<string, ISprite> sprites);
        void FadeInAndShow(IDictionary<string, ISprite> sprites, IList<ISprite> visiblesprites = null);
        /// <summary>
        /// Restores which windows are active for the given sprite hash.
        /// </summary>
        /// <param name="sprites"></param>
        /// <param name="activeStatuses">the result of a previous call to ActivateWindows</param>
        void RestoreActivations(IDictionary<string, ISprite> sprites, IDictionary<string,bool> activeStatuses);
        /// <summary>
        /// Deactivates all windows.
        /// </summary>
        /// <param name="sprites"></param>
        /// <param name="">If a code block is given, deactivates all windows, runs the code in the block, and reactivates them.</param>
        void DeactivateWindows(IDictionary<string, ISprite> sprites);
        /// <summary>
        /// Activates a specific window of a sprite hash.
        /// </summary>
        /// <param name="sprites"></param>
        /// <param name="key">the key of the window in the sprite hash.</param>
        /// <param name="">If a code block is given, deactivates all windows except the specified window, runs the code in the block, and reactivates them.</param>
        void ActivateWindow(IDictionary<string, ISprite> sprites, string key);

        /// <summary>
        /// Adds a background to the sprite hash.
        /// </summary>
        /// <param name="sprites"></param>
        /// <param name="planename">the hash key of the background.</param>
        /// <param name="background">a filename within the Graphics/UI/ folder and can be an animated image.</param>
        /// <param name="viewport">a viewport to place the background in.</param>
        void addBackgroundPlane(IDictionary<string,ISprite> sprites, string planename, string background, IViewport viewport = null);
        /// <summary>
        /// Adds a background to the sprite hash.
        /// </summary>
        /// <param name="sprites"></param>
        /// <param name="planename">the hash key of the background.</param>
        /// <param name="background">a filename within the Graphics/UI/ folder and can be an animated image.</param>
        /// <param name="color">the color to use if the background can't be found.</param>
        /// <param name="viewport">a viewport to place the background in.</param>
        void addBackgroundOrColoredPlane(IDictionary<string,ISprite> sprites, string planename, string background, ICollection color, IViewport viewport = null);

        // Ensure required method definitions.
        string _INTL(string args);
        string _ISPRINTF(string args);
        string _MAPINTL(string args);
    }
}