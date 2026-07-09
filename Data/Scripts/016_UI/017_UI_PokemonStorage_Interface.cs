using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon storage scene that manages PC box organization.
    /// Handles Pokemon storage, withdrawal, organization, and box management functionality.
    /// </summary>
    public interface IPokemonStorage_Scene : IStorageUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Pokemon storage scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Pokemon storage scene with access to PC boxes.
        /// Initializes box display, Pokemon sprites, and storage interface.
        /// </summary>
        /// <param name="storage">Pokemon storage system instance.</param>
        /// <param name="party">Player's current Pokemon party.</param>
        void StartScene(object storage, IList<object> party);

        /// <summary>
        /// Handles the main scene interaction loop for Pokemon management.
        /// Processes navigation, selection, and Pokemon organization commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Pokemon storage scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the storage display with current box and Pokemon data.
        /// Updates box contents, Pokemon sprites, and interface elements.
        /// </summary>
        void RefreshStorage();

        /// <summary>
        /// Updates the information display for the currently selected Pokemon.
        /// Shows Pokemon details, stats, and summary information.
        /// </summary>
        void UpdatePokemonInfo();

        /// <summary>
        /// Handles navigation between storage boxes and positions.
        /// Updates selection cursor and changes active display area.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateStorage(int direction);

        /// <summary>
        /// Selects or deselects the Pokemon at the current cursor position.
        /// Handles Pokemon picking up and placing operations.
        /// </summary>
        void SelectPokemon();

        /// <summary>
        /// Moves Pokemon between storage positions or to/from party.
        /// Handles Pokemon transfer operations with validation.
        /// </summary>
        /// <param name="source_pos">Source position of Pokemon to move.</param>
        /// <param name="dest_pos">Destination position for Pokemon.</param>
        //void MovePokemon((int box, int slot) source_pos, (int box, int slot) dest_pos);
        void MovePokemon(KeyValuePair<int, int> source_pos, KeyValuePair<int, int> dest_pos);

        /// <summary>
        /// Changes the currently active storage box for viewing and organization.
        /// Switches between different PC boxes and updates display.
        /// </summary>
        /// <param name="box_index">Index of the box to switch to.</param>
        void ChangeBox(int box_index);

        /// <summary>
        /// Opens the Pokemon summary screen for detailed information viewing.
        /// Displays comprehensive Pokemon data and statistics.
        /// </summary>
        /// <param name="pokemon">Pokemon to show summary information for.</param>
        void ShowPokemonSummary(object pokemon);

        /// <summary>
        /// Manages box naming and organization options.
        /// Provides interface for renaming boxes and changing wallpapers.
        /// </summary>
        void ManageBoxes();

        /// <summary>
        /// Handles Pokemon release operations with confirmation.
        /// Provides interface for permanently releasing Pokemon from storage.
        /// </summary>
        /// <param name="pokemon">Pokemon to release from storage.</param>
        /// <returns>True if Pokemon was released successfully.</returns>
        bool ReleasePokemon(object pokemon);

        /// <summary>
        /// Validates Pokemon movement operations for legality and safety.
        /// Checks if Pokemon can be moved to specified destination.
        /// </summary>
        /// <param name="source">Source position of Pokemon.</param>
        /// <param name="destination">Destination position for Pokemon.</param>
        /// <returns>True if move operation is valid and allowed.</returns>
        //bool ValidateMove((int box, int slot) source, (int box, int slot) destination);
        bool ValidateMove(KeyValuePair<int,int> source, KeyValuePair<int, int> destination);
    }

    /// <summary>
    /// Interface for the Pokemon storage screen that orchestrates PC box management.
    /// Coordinates between scenes and manages overall Pokemon storage experience.
    /// </summary>
    public interface IPokemonStorageScreen
    {
        /// <summary>
        /// Initializes the Pokemon storage screen with the specified scene.
        /// Sets up the scene instance for managing the storage interface.
        /// </summary>
        /// <param name="scene">The Pokemon storage scene to use.</param>
        IPokemonStorageScreen initialize(IPokemonStorage_Scene scene);

        /// <summary>
        /// Starts the Pokemon storage screen for PC box management.
        /// Displays Pokemon storage system with organization functionality.
        /// </summary>
        void StartScreen();
    }
}