using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Purify Chamber scene that manages Shadow Pokemon purification.
    /// Handles placement of Pokemon in purification chambers and purification process management.
    /// </summary>
    public interface IPokemonPurifyChamber_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Purify Chamber scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Purify Chamber scene with available chambers and Pokemon.
        /// Initializes chamber display, Pokemon placement interface, and purification controls.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Handles the main scene interaction loop for chamber management.
        /// Processes navigation, Pokemon placement, and purification commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Purify Chamber scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the chamber display with current Pokemon placement and status.
        /// Updates chamber contents, purification progress, and interface elements.
        /// </summary>
        void RefreshChambers();

        /// <summary>
        /// Updates the information display for the currently selected chamber or Pokemon.
        /// Shows chamber details, Pokemon status, and purification information.
        /// </summary>
        void UpdateChamberInfo();

        /// <summary>
        /// Handles navigation between chambers and Pokemon positions.
        /// Updates selection cursor and changes active display area.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateChambers(int direction);

        /// <summary>
        /// Places a Pokemon into the selected chamber position.
        /// Handles Pokemon placement with validation for chamber compatibility.
        /// </summary>
        /// <param name="pokemon">Pokemon to place in the chamber.</param>
        /// <param name="chamber_slot">Specific slot within the chamber to place Pokemon.</param>
        /// <returns>True if Pokemon was successfully placed.</returns>
        //bool PlacePokemon(object pokemon, (int chamber, int slot) chamber_slot);
        bool PlacePokemon(object pokemon, KeyValuePair<int,int> chamber_slot);

        /// <summary>
        /// Removes a Pokemon from the selected chamber position.
        /// Handles Pokemon withdrawal from purification chambers.
        /// </summary>
        /// <param name="chamber_slot">Chamber slot to remove Pokemon from.</param>
        /// <returns>Pokemon that was removed from the chamber.</returns>
        //object RemovePokemon((int chamber, int slot) chamber_slot);
        object RemovePokemon(KeyValuePair<int, int> chamber_slot);

        /// <summary>
        /// Initiates the purification process for Shadow Pokemon in chambers.
        /// Handles purification animation and Pokemon transformation.
        /// </summary>
        /// <param name="shadow_pokemon">Shadow Pokemon to purify.</param>
        /// <returns>True if purification was successful.</returns>
        bool PurifyPokemon(object shadow_pokemon);

        /// <summary>
        /// Calculates and displays the purification effectiveness of chamber setups.
        /// Shows how chamber arrangements affect purification rates.
        /// </summary>
        /// <param name="chamber_index">Chamber to calculate effectiveness for.</param>
        /// <returns>Effectiveness rating of the chamber setup.</returns>
        float CalculateChamberEffectiveness(int chamber_index);

        /// <summary>
        /// Validates Pokemon placement in chambers based on type and compatibility.
        /// Checks if Pokemon can be placed in the specified chamber position.
        /// </summary>
        /// <param name="pokemon">Pokemon to validate for placement.</param>
        /// <param name="chamber_slot">Chamber slot being considered for placement.</param>
        /// <returns>True if placement is valid and allowed.</returns>
        //bool ValidatePlacement(object pokemon, (int chamber, int slot) chamber_slot);
        bool ValidatePlacement(object pokemon, KeyValuePair<int, int> chamber_slot);

        /// <summary>
        /// Displays detailed information about Shadow Pokemon purification process.
        /// Shows purification requirements, progress, and chamber benefits.
        /// </summary>
        /// <param name="shadow_pokemon">Shadow Pokemon to show information for.</param>
        void ShowPurificationInfo(object shadow_pokemon);

        /// <summary>
        /// Manages chamber configuration and optimization suggestions.
        /// Provides guidance for optimal Pokemon placement for purification.
        /// </summary>
        void ManageChamberSetup();

        /// <summary>
        /// Gets the list of Shadow Pokemon available for purification.
        /// Returns Shadow Pokemon from party and storage that can be purified.
        /// </summary>
        /// <returns>List of Shadow Pokemon available for purification.</returns>
        IList<object> getShadowPokemon();

        /// <summary>
        /// Updates the purification progress display for all chambers.
        /// Refreshes progress bars and status indicators for ongoing purification.
        /// </summary>
        void UpdatePurificationProgress();
    }

    /// <summary>
    /// Interface for the Purify Chamber screen that orchestrates Shadow Pokemon purification.
    /// Coordinates between scenes and manages overall purification experience.
    /// </summary>
    public interface IPokemonPurifyChamberScreen
    {
        /// <summary>
        /// Initializes the Purify Chamber screen with the specified scene.
        /// Sets up the scene instance for managing the purification interface.
        /// </summary>
        /// <param name="scene">The Purify Chamber scene to use.</param>
        IPokemonPurifyChamberScreen initialize(IPokemonPurifyChamber_Scene scene);

        /// <summary>
        /// Starts the Purify Chamber screen for Shadow Pokemon management.
        /// Displays purification chambers and manages Shadow Pokemon purification.
        /// </summary>
        void StartScreen();
    }
}