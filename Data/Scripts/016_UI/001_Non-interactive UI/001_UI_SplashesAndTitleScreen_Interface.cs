using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the intro event scene that manages splash screens and title screen display.
    /// Extends the base EventScene interface with splash screen and title screen functionality.
    /// </summary>
    public interface ISceneIntroEvent : IEventScene
    {
        /// <summary>
        /// Initializes the intro event scene with an optional viewport.
        /// Sets up the image containers and starts either splash screens or title screen.
        /// </summary>
        /// <param name="viewport">The viewport to display the scene in, or null for default.</param>
        ISceneIntroEvent initialize(IViewport viewport = null);

        /// <summary>
        /// Opens and displays the splash screen sequence.
        /// Shows each splash image in order with fade effects.
        /// </summary>
        /// <param name="_scene">The scene instance.</param>
        /// <param name="args">Additional arguments passed to the method.</param>
        void open_splash(IScene _scene, params object[] args);

        /// <summary>
        /// Closes the current splash screen and proceeds to the next.
        /// Handles the transition between splash screens or to the title screen.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Arguments passed to the method.</param>
        void close_splash(IScene scene, object args);

        /// <summary>
        /// Updates the splash screen display each frame.
        /// Handles automatic progression after the specified time duration.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Arguments passed to the method.</param>
        void splash_update(IScene scene, object args);

        /// <summary>
        /// Opens and displays the main title screen.
        /// Shows the title background and animated "Press Enter" prompt.
        /// </summary>
        /// <param name="_scene">The scene instance.</param>
        /// <param name="args">Additional arguments passed to the method.</param>
        void open_title_screen(IScene _scene, params object[] args);

        /// <summary>
        /// Handles the fade out transition from the title screen.
        /// Plays a random Pokemon cry and fades out all elements.
        /// </summary>
        /// <param name="scene">The scene instance to fade out.</param>
        void fade_out_title_screen(IScene scene);

        /// <summary>
        /// Closes the title screen and opens the load screen.
        /// Handles the transition to the game loading interface.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Additional arguments passed to the method.</param>
        void close_title_screen(IScene scene, params object[] args);

        /// <summary>
        /// Closes the title screen and opens the delete screen.
        /// Handles the transition to the save file deletion interface.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Additional arguments passed to the method.</param>
        void close_title_screen_delete(IScene scene, params object[] args);

        /// <summary>
        /// Updates the title screen display each frame.
        /// Handles the flashing "Press Enter" animation and special key combinations.
        /// </summary>
        /// <param name="scene">The scene instance.</param>
        /// <param name="args">Arguments passed to the method.</param>
        void title_screen_update(IScene scene, object args);
    }

    /// <summary>
    /// Interface for the main intro scene that orchestrates the entire intro sequence.
    /// Manages the overall flow from splash screens to title screen.
    /// </summary>
    public interface ISceneIntro
    {
        /// <summary>
        /// Main entry point for the intro scene.
        /// Initializes graphics transition, creates the event scene, and manages the intro flow.
        /// </summary>
        /// <remarks>
        /// Beginning starting point that runs and operates the entire game application.
        /// Enumerates through each frame tick and calls `update` across entire game assembly.
        /// This is supposed to mimic behavior of Unity's Monobehavior `OnUpdate`.
        /// </remarks>
        void main();
    }
}