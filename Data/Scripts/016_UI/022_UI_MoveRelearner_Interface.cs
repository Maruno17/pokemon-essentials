using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Move Relearner scene that manages Pokemon move relearning.
    /// Handles move selection, relearning process, and move management functionality.
    /// </summary>
    public interface IPokemonMoveRelearner_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the Move Relearner scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the Move Relearner scene with the specified Pokemon.
        /// Initializes Pokemon display, move list, and relearning interface.
        /// </summary>
        /// <param name="pokemon">Pokemon that will be relearning moves.</param>
        void StartScene(object pokemon);

        /// <summary>
        /// Handles the main scene interaction loop for move relearning.
        /// Processes navigation, move selection, and relearning commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the Move Relearner scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the scene display with current Pokemon and move data.
        /// Updates move lists, Pokemon info, and interface elements.
        /// </summary>
        void RefreshScene();

        /// <summary>
        /// Updates the information display for the currently selected move.
        /// Shows move details, type, power, accuracy, and description.
        /// </summary>
        void UpdateMoveInfo();

        /// <summary>
        /// Handles navigation between available moves for relearning.
        /// Updates selection and refreshes move information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateMoves(int direction);

        /// <summary>
        /// Initiates the move relearning process for the selected move.
        /// Handles move teaching and potential move replacement.
        /// </summary>
        /// <param name="move">Move to teach to the Pokemon.</param>
        /// <returns>True if move was successfully taught.</returns>
        bool RelearnMove(object move);

        /// <summary>
        /// Handles move replacement when Pokemon already knows four moves.
        /// Provides interface for selecting which move to replace.
        /// </summary>
        /// <param name="new_move">New move to learn.</param>
        /// <returns>Index of move to replace, or -1 if cancelled.</returns>
        int ChooseMoveToReplace(object new_move);

        /// <summary>
        /// Confirms move relearning with the player before processing.
        /// Shows move details and requests confirmation for teaching.
        /// </summary>
        /// <param name="move">Move being taught to the Pokemon.</param>
        /// <returns>True if relearning is confirmed by player.</returns>
        bool ConfirmMoveRelearning(object move);

        /// <summary>
        /// Gets the list of moves that the Pokemon can relearn.
        /// Returns moves available for relearning based on Pokemon species and level.
        /// </summary>
        /// <param name="pokemon">Pokemon to get relearnable moves for.</param>
        /// <returns>List of moves available for relearning.</returns>
        IList<object> getRelearnableMoves(object pokemon);

        /// <summary>
        /// Validates if the specified move can be taught to the Pokemon.
        /// Checks move compatibility and learning requirements.
        /// </summary>
        /// <param name="pokemon">Pokemon that would learn the move.</param>
        /// <param name="move">Move to validate for teaching.</param>
        /// <returns>True if move can be taught to the Pokemon.</returns>
        bool CanLearnMove(object pokemon, object move);

        /// <summary>
        /// Displays the cost or requirements for move relearning.
        /// Shows any payment or items required for the relearning service.
        /// </summary>
        void DisplayRelearningCost();

        /// <summary>
        /// Processes payment or requirements for move relearning service.
        /// Handles any costs associated with the move relearning process.
        /// </summary>
        /// <returns>True if payment/requirements were satisfied.</returns>
        bool ProcessRelearningPayment();

        /// <summary>
        /// Shows a comparison between the new move and existing moves.
        /// Displays move statistics for informed decision making.
        /// </summary>
        /// <param name="new_move">New move being considered.</param>
        /// <param name="existing_move">Existing move to compare against.</param>
        void CompareMoves(object new_move, object existing_move);
    }

    /// <summary>
    /// Interface for the Move Relearner screen that orchestrates move relearning functionality.
    /// Coordinates between scenes and manages overall move relearning experience.
    /// </summary>
    public interface IPokemonMoveRelearnerScreen
    {
        /// <summary>
        /// Initializes the Move Relearner screen with the specified scene.
        /// Sets up the scene instance for managing the move relearning interface.
        /// </summary>
        /// <param name="scene">The Move Relearner scene to use.</param>
        IPokemonMoveRelearnerScreen initialize(IPokemonMoveRelearner_Scene scene);

        /// <summary>
        /// Starts the Move Relearner screen for the specified Pokemon.
        /// Displays available moves and manages the relearning process.
        /// </summary>
        /// <param name="pokemon">Pokemon that will be relearning moves.</param>
        void StartScreen(object pokemon);
    }
}