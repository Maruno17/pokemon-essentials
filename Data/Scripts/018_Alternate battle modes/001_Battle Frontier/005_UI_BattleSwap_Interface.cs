using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Battle Swap scene visual management and user interaction
    /// </summary>
    public interface ISceneBattleSwap : IScene, IHaveUpdate
    {
        /// <summary>
        /// Initializes the rental Pokemon selection scene
        /// </summary>
        /// <param name="rentals">List of available rental Pokemon</param>
        void pbStartRentScene(IList<IPokemon> rentals);

        /// <summary>
        /// Initializes the Pokemon swap scene
        /// </summary>
        /// <param name="currentPokemon">Player's current Pokemon</param>
        /// <param name="newPokemon">Available Pokemon to swap for</param>
        void pbStartSwapScene(IList<IPokemon> currentPokemon, IList<IPokemon> newPokemon);

        /// <summary>
        /// Initializes the swap screen interface
        /// </summary>
        void pbInitSwapScreen();

        /// <summary>
        /// Ends the scene and cleans up resources
        /// </summary>
        void pbEndScene();

        /// <summary>
        /// Shows command options to the player
        /// </summary>
        /// <param name="commands">List of command options</param>
        /// <returns>Selected command index</returns>
        int pbShowCommands(IList<string> commands);

        /// <summary>
        /// Shows a confirmation dialog
        /// </summary>
        /// <param name="message">Confirmation message</param>
        /// <returns>True if confirmed, false otherwise</returns>
        bool pbConfirm(string message);

        /// <summary>
        /// Generates command list for Pokemon display
        /// </summary>
        /// <param name="list">List of Pokemon</param>
        /// <param name="choices">Currently selected Pokemon indices</param>
        /// <returns>Formatted command list</returns>
        IList<string> pbGetCommands(IList<IPokemon> list, IList<int> choices);

        /// <summary>
        /// Handles Pokemon selection with optional cancel
        /// </summary>
        /// <param name="canCancel">Whether canceling is allowed</param>
        /// <returns>Selected Pokemon index, or -1 for cancel</returns>
        int pbChoosePokemon(bool canCancel);

        /// <summary>
        /// Updates the display based on current choices
        /// </summary>
        /// <param name="choices">Currently selected Pokemon indices</param>
        void pbUpdateChoices(IList<int> choices);

        /// <summary>
        /// Updates display when a Pokemon is chosen for swapping
        /// </summary>
        /// <param name="pkmnindex">Index of chosen Pokemon</param>
        void pbSwapChosen(int pkmnindex);

        /// <summary>
        /// Handles swap cancellation
        /// </summary>
        void pbSwapCanceled();

        /// <summary>
        /// Shows Pokemon summary screen
        /// </summary>
        /// <param name="list">List of Pokemon</param>
        /// <param name="index">Index of Pokemon to show summary for</param>
        void pbSummary(IList<IPokemon> list, int index);

        /// <summary>
        /// Updates the scene sprites and display
        /// </summary>
        void Update();
    }

    /// <summary>
    /// Interface for Battle Swap screen logic and flow control
    /// </summary>
    public interface IScreenBattleSwap : IScreen
    {
        /// <summary>
        /// Initializes the Battle Swap screen with a scene
        /// </summary>
        /// <param name="scene">Battle swap scene to use</param>
        IScreenBattleSwap initialize(ISceneBattleSwap scene);

        /// <summary>
        /// Starts the rental Pokemon selection process
        /// </summary>
        /// <param name="rentals">Available rental Pokemon</param>
        /// <returns>List of chosen rental Pokemon</returns>
        IList<IPokemon> pbStartRent(IList<IPokemon> rentals);

        /// <summary>
        /// Starts the Pokemon swapping process
        /// </summary>
        /// <param name="currentPokemon">Player's current Pokemon</param>
        /// <param name="newPokemon">Available Pokemon to swap for</param>
        /// <returns>True if a swap was made, false if canceled</returns>
        bool pbStartSwap(IList<IPokemon> currentPokemon, IList<IPokemon> newPokemon);
    }
}