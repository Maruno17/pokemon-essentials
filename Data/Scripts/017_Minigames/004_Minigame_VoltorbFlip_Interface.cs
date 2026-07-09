using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the main Voltorb Flip game implementation.
    /// Manages the complete game logic, board generation, input handling, and progression system.
    /// </summary>
    public interface IVoltorbFlip : IHaveUpdate
    {
        /// <summary>
        /// Updates all sprite animations and display elements.
        /// </summary>
        void update();

        /// <summary>
        /// Starts a new game session beginning at level 1.
        /// Initializes game state and creates the first game board.
        /// </summary>
        void Start();

        /// <summary>
        /// Generates a valid game board based on current level constraints.
        /// Uses tile distribution tables to create balanced puzzles with appropriate difficulty.
        /// </summary>
        /// <returns>Array representing the board tiles (0=Voltorb, 1=×1, 2=×2, 3=×3)</returns>
        int[] generate_board();

        /// <summary>
        /// Initializes a new game round with board generation and interface setup.
        /// Creates sprites, calculates hint numbers, and handles level progression displays.
        /// </summary>
        void NewGame();

        /// <summary>
        /// Creates all sprite objects and UI elements for the game.
        /// Sets up the board grid, cursor, animation layers, and score displays.
        /// </summary>
        void CreateSprites();

        /// <summary>
        /// Processes player input and game interactions.
        /// Handles cursor movement, tile selection, mode switching, and quit functionality.
        /// </summary>
        void getInput();

        /// <summary>
        /// Updates the hint numbers for a specific row.
        /// Calculates and displays the point total and Voltorb count for the row.
        /// </summary>
        /// <param name="num">Point total for the row</param>
        /// <param name="voltorbs">Number of Voltorbs in the row</param>
        /// <param name="i">Row index</param>
        void UpdateRowNumbers(int num, int voltorbs, int i);

        /// <summary>
        /// Updates the hint numbers for a specific column.
        /// Calculates and displays the point total and Voltorb count for the column.
        /// </summary>
        /// <param name="num">Point total for the column</param>
        /// <param name="voltorbs">Number of Voltorbs in the column</param>
        /// <param name="i">Column index</param>
        void UpdateColumnNumbers(int num, int voltorbs, int i);

        /// <summary>
        /// Creates coin display sprites for score visualization.
        /// Formats numeric values into graphical digit representations.
        /// </summary>
        /// <param name="source">The numeric value to display</param>
        /// <param name="y">Y position for the display</param>
        void CreateCoins(int source, int y);

        /// <summary>
        /// Updates both total coin and current point displays.
        /// Refreshes the visual representation of player progress and potential winnings.
        /// </summary>
        void UpdateCoins();

        /// <summary>
        /// Animates the tile flip sequence when a tile is revealed.
        /// Shows the tile transformation from hidden to revealed state.
        /// </summary>
        /// <param name="x">X position of the tile</param>
        /// <param name="y">Y position of the tile</param>
        /// <param name="tile">Tile value to reveal</param>
        void AnimateTile(int x, int y, int tile);

        /// <summary>
        /// Displays all tiles on the board and handles end-game cleanup.
        /// Shows the complete board state and waits for player acknowledgment.
        /// </summary>
        void ShowAndDispose();

        /// <summary>
        /// Ends the game session with closing animations.
        /// Performs curtain effects and resource cleanup.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Executes the main game loop.
        /// Continues until the player quits or reaches maximum coins.
        /// </summary>
        void Scene();
    }

    /// <summary>
    /// Interface for the Voltorb Flip screen controller.
    /// Manages the overall game session and coordinates with the game scene.
    /// </summary>
    public interface IVoltorbFlipScreen
    {
        /// <summary>
        /// Starts a complete Voltorb Flip game session.
        /// Initializes the game, runs the main loop, and handles cleanup.
        /// </summary>
        void StartScreen();
    }

    /// <summary>
    /// Interface for global Voltorb Flip functionality and access control.
    /// Manages prerequisites and entry conditions for Voltorb Flip play.
    /// </summary>
    public interface IVoltorbFlipManager
    {
        /// <summary>
        /// Initiates a Voltorb Flip game with prerequisite checking.
        /// Validates coin case possession and coin limits before starting the game.
        /// </summary>
        void VoltorbFlip();
    }
}