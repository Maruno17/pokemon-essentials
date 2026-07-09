using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the button event scene that displays keyboard controls help.
    /// Shows a multi-screen help interface listing all keyboard controls and their functions.
    /// Extends the base EventScene interface with controls-specific functionality.
    /// </summary>
    /// <remarks>
    /// Shows a help screen listing the keyboard controls.
    /// Display with:
    ///      <see cref="IMainEventScene.EventScreen(ISceneButtonEvent)"/>
    /// </remarks>
    public interface ISceneButtonEvent : IEventScene
    {
        /// <summary>
        /// Initializes the button event scene with control help screens.
        /// Sets up the background, labels, images, and screen navigation.
        /// </summary>
        /// <param name="viewport">The viewport to display the scene in, or null for default.</param>
        ISceneButtonEvent initialize(IViewport viewport = null);

        /// <summary>
        /// Adds a text label to a specific screen with positioning and content.
        /// Labels provide descriptive text for control explanations.
        /// </summary>
        /// <param name="number">The screen number this label belongs to.</param>
        /// <param name="x">The X coordinate for label placement.</param>
        /// <param name="y">The Y coordinate for label placement.</param>
        /// <param name="width">The width of the label text area.</param>
        /// <param name="text">The text content to display.</param>
        void addLabelForScreen(int number, int x, int y, int width, string text);

        /// <summary>
        /// Adds an image to a specific screen with positioning and filename.
        /// Images typically show visual representations of keyboard keys.
        /// </summary>
        /// <param name="number">The screen number this image belongs to.</param>
        /// <param name="x">The X coordinate for image placement.</param>
        /// <param name="y">The Y coordinate for image placement.</param>
        /// <param name="filename">The filename of the image to display.</param>
        void addImageForScreen(int number, int x, int y, string filename);

        /// <summary>
        /// Sets up and displays the specified screen number.
        /// Handles opacity transitions to show/hide screen elements.
        /// </summary>
        /// <param name="number">The screen number to display.</param>
        void set_up_screen(int number);

        /// <summary>
        /// Handles the end of screen event when the user presses the action key.
        /// Progresses to the next screen or ends the help sequence.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Additional arguments passed to the method.</param>
        void OnScreenEnd(IScene scene, params object[] args);
    }
}