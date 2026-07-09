using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the PC scene that manages the main computer interface.
    /// Provides access to Pokemon storage, item storage, and other PC functions.
    /// </summary>
    public interface IPokemonPC_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the PC scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the PC scene with available computer functions.
        /// Initializes PC interface, menu options, and system access.
        /// </summary>
        /// <param name="commands">List of available PC functions and options.</param>
        void StartScene(IList<string> commands);

        /// <summary>
        /// Handles the main scene interaction loop for PC function selection.
        /// Processes navigation through PC options and handles command execution.
        /// </summary>
        /// <returns>Index of selected PC function, or -1 if cancelled.</returns>
        int Scene();

        /// <summary>
        /// Ends the PC scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the PC menu display with available functions.
        /// Updates command list, availability status, and interface elements.
        /// </summary>
        void RefreshMenu();

        /// <summary>
        /// Updates the information display for the currently selected PC function.
        /// Shows function description and usage information.
        /// </summary>
        void UpdateFunctionInfo();

        /// <summary>
        /// Handles navigation between PC functions in the menu.
        /// Updates selection and refreshes function information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateFunctions(int direction);

        /// <summary>
        /// Executes the selected PC function with appropriate scene transition.
        /// Launches the corresponding interface for the chosen PC function.
        /// </summary>
        /// <param name="function_index">Index of the PC function to execute.</param>
        void ExecuteFunction(int function_index);

        /// <summary>
        /// Opens the Pokemon storage system interface.
        /// Provides access to PC boxes for Pokemon management.
        /// </summary>
        void OpenPokemonStorage();

        /// <summary>
        /// Opens the item storage system interface.
        /// Provides access to PC item storage for inventory management.
        /// </summary>
        void OpenItemStorage();

        /// <summary>
        /// Opens the mailbox system for message management.
        /// Provides access to stored mail and message functionality.
        /// </summary>
        void OpenMailbox();

        /// <summary>
        /// Opens the decoration storage for secret base management.
        /// Provides access to decoration items and placement tools.
        /// </summary>
        void OpenDecorationStorage();

        /// <summary>
        /// Handles PC system logout with confirmation.
        /// Provides safe exit from PC system with save prompts if needed.
        /// </summary>
        void Logout();

        /// <summary>
        /// Checks if the specified PC function is currently available.
        /// Validates function availability based on game progress and conditions.
        /// </summary>
        /// <param name="function_name">Name of the PC function to check.</param>
        /// <returns>True if the function is available for use.</returns>
        bool IsFunctionAvailable(string function_name);
    }

    /// <summary>
    /// Interface for the PC screen that orchestrates computer system functionality.
    /// Coordinates between scenes and manages overall PC experience.
    /// </summary>
    public interface IPokemonPCScreen
    {
        /// <summary>
        /// Initializes the PC screen with the specified scene.
        /// Sets up the scene instance for managing the PC interface.
        /// </summary>
        /// <param name="scene">The PC scene to use.</param>
        IPokemonPCScreen initialize(IPokemonPC_Scene scene);

        /// <summary>
        /// Starts the PC screen for system access and management.
        /// Displays PC functions and manages computer system functionality.
        /// </summary>
        void StartScreen();
    }
}