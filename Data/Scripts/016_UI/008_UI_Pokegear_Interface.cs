using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for individual Pokégear button sprites that represent menu options.
    /// Handles button appearance, selection states, and rendering of button graphics and text.
    /// </summary>
    public interface IPokegearButton : ISprite, IHaveRefresh, IDisposable
    {
        /// <summary>
        /// Gets the index of this button in the Pokégear menu.
        /// Identifies the button's position and associated action.
        /// </summary>
        /// <value>The button's index number.</value>
        int index { get; }

        /// <summary>
        /// Gets the display name of this Pokégear button.
        /// Returns the text label shown on the button.
        /// </summary>
        /// <value>The button's display name.</value>
        string name { get; }

        /// <summary>
        /// Gets or sets whether this button is currently selected.
        /// Controls the visual appearance and highlighting state of the button.
        /// </summary>
        /// <value>True if the button is selected, false otherwise.</value>
        bool selected { get; set; }

		/// <summary>
		/// Initializes the Pokégear button with command data and position.
		/// Sets up button graphics, text, and initial state based on player character.
		/// </summary>
		/// <param name="command">Array containing button image and name data.</param>
		/// <param name="x">X coordinate for button placement.</param>
		/// <param name="y">Y coordinate for button placement.</param>
		/// <param name="viewport">Viewport to display the button in, or null for default.</param>
		IPokegearButton initialize(object[] command, int x, int y, IViewport viewport = null);

        /// <summary>
        /// Disposes of bitmap resources used by the button.
        /// Cleans up button graphics and content bitmaps.
        /// </summary>
        void dispose();

        /// <summary>
        /// Refreshes the button display with current selection state.
        /// Updates the button graphics and text based on selected status.
        /// </summary>
        void refresh();
    }

    /// <summary>
    /// Interface for the Pokégear scene that manages the main menu interface.
    /// Handles button navigation, app launching, and overall Pokégear functionality.
    /// </summary>
    public interface IPokemonPokegear_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Pokégear scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Pokégear scene with available applications.
        /// Initializes background, buttons, and sets up the main interface.
        /// </summary>
        /// <param name="commands">List of available Pokégear applications and their data.</param>
        void StartScene(IList<object[]> commands);

        /// <summary>
        /// Handles the main scene interaction loop for app selection.
        /// Processes navigation between apps and handles selection input.
        /// </summary>
        /// <returns>Index of selected app, or -1 if cancelled.</returns>
        int Scene();

        /// <summary>
        /// Ends the Pokégear scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Updates the button selection highlighting.
        /// Refreshes button states to show current selection and available options.
        /// </summary>
        void UpdateButtonSelection();

        /// <summary>
        /// Handles directional navigation between Pokégear buttons.
        /// Updates selection based on direction input and button layout.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateButtons(int direction);
    }

    /// <summary>
    /// Interface for the Pokégear screen that orchestrates the main device interface.
    /// Coordinates between scenes and manages app launching and navigation flow.
    /// </summary>
    public interface IPokemonPokegearScreen
    {
		/// <summary>
		/// Initializes the Pokégear screen with the specified scene.
		/// Sets up the scene instance for managing the Pokégear interface.
		/// </summary>
		/// <param name="scene">The Pokégear scene to use.</param>
		IPokemonPokegearScreen initialize(IPokemonPokegear_Scene scene);

        /// <summary>
        /// Starts the Pokégear screen and handles app selection flow.
        /// Builds the list of available apps and manages navigation to selected app.
        /// </summary>
        void StartScreen();
    }
}