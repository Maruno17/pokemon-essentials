using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the tile puzzle cursor with visual feedback and mode management.
    /// Handles cursor positioning, selection states, and directional arrows for puzzle navigation.
    /// </summary>
    public interface ITilePuzzleCursor : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets the puzzle game type (affects cursor behavior).
        /// </summary>
        int game { get; set; }

        /// <summary>
        /// Gets or sets the current cursor position on the puzzle board.
        /// </summary>
        int position { get; set; }

        /// <summary>
        /// Gets or sets the array of directional arrows showing valid moves.
        /// </summary>
        bool[] arrows { get; set; }

        /// <summary>
        /// Gets or sets whether the cursor is in selection mode.
        /// </summary>
        bool selected { get; set; }

        /// <summary>
        /// Gets or sets whether the cursor is holding a tile.
        /// </summary>
        bool holding { get; set; }

        /// <summary>
        /// Updates the cursor display and visual effects.
        /// Renders position, selection state, and directional indicators.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the main tile puzzle scene and visual management.
    /// Handles rendering, animations, input processing, and game state management for multiple puzzle types.
    /// </summary>
    public interface ITilePuzzleScene : IHaveUpdate
    {
        /// <summary>
        /// Updates all visual elements including tile positions and cursor display.
        /// Synchronizes game state with sprite positions and handles tile rotations.
        /// </summary>
        void update();

        /// <summary>
        /// Updates cursor arrows to show valid movement directions.
        /// Determines which directions the cursor can move based on current position and game rules.
        /// </summary>
        void updateCursor();

        /// <summary>
        /// Initializes the puzzle scene with graphics and tile arrangement.
        /// Sets up the game board, loads tile graphics, and shuffles the initial state.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Shuffles tiles to create a solvable puzzle configuration.
        /// Uses different algorithms based on puzzle type to ensure valid starting states.
        /// </summary>
        /// <returns>Array representing the shuffled tile arrangement</returns>
        int[] ShuffleTiles();

        /// <summary>
        /// Determines the default cursor starting position for the puzzle type.
        /// For Mystic Square, finds the blank space; for others, returns position 0.
        /// </summary>
        /// <returns>Starting cursor position</returns>
        int DefaultCursorPosition();

        /// <summary>
        /// Calculates cursor movement to an adjacent position.
        /// Handles wrapping and boundary conditions for different puzzle layouts.
        /// </summary>
        /// <param name="pos">Current position</param>
        /// <param name="dir">Direction (2=down, 4=left, 6=right, 8=up)</param>
        /// <returns>New cursor position</returns>
        int MoveCursor(int pos, int dir);

        /// <summary>
        /// Checks if cursor movement is valid in the specified direction.
        /// Considers puzzle boundaries and special game mode restrictions.
        /// </summary>
        /// <param name="pos">Current position</param>
        /// <param name="dir">Movement direction</param>
        /// <param name="swapping">Whether this check is for tile swapping mode</param>
        /// <returns>True if movement is allowed</returns>
        bool CanMoveInDir(int pos, int dir, bool swapping);

        /// <summary>
        /// Rotates tiles with smooth animation effects.
        /// Handles both single tile rotation and group rotations for specific game modes.
        /// </summary>
        /// <param name="pos">Position of tile(s) to rotate</param>
        /// <param name="anim">Whether to show rotation animation</param>
        void RotateTile(int pos, bool anim = true);

        /// <summary>
        /// Gets tiles affected by rotation for puzzle types with group rotation.
        /// Returns the tile and its neighbors for simultaneous rotation effects.
        /// </summary>
        /// <param name="pos">Center position for rotation</param>
        /// <returns>Array of affected tile positions</returns>
        int[] GetNearTiles(int pos);

        /// <summary>
        /// Swaps two adjacent tiles with smooth animation.
        /// Handles both simple swapping and complex line shifting mechanics.
        /// </summary>
        /// <param name="dir">Direction of the swap</param>
        /// <returns>True if swap was successful</returns>
        bool SwapTiles(int dir);

        /// <summary>
        /// Shifts entire rows or columns of tiles in Rubik's square mode.
        /// Creates rotating line effects with visual feedback and animation.
        /// </summary>
        /// <param name="dir">Direction of the shift</param>
        /// <param name="cursor">Starting position for the shift</param>
        /// <param name="anim">Whether to show shift animation</param>
        /// <returns>True if shift was successful</returns>
        bool ShiftLine(int dir, int cursor, bool anim = true);

        /// <summary>
        /// Handles tile pickup and placement for Ruins of Alph puzzle modes.
        /// Switches between holding and placing tiles at the cursor position.
        /// </summary>
        /// <param name="pos">Position to grab or place tile</param>
        void GrabTile(int pos);

        /// <summary>
        /// Checks if the puzzle has been solved.
        /// Verifies that all tiles are in correct positions with proper orientations.
        /// </summary>
        /// <returns>True if puzzle is complete</returns>
        bool CheckWin();

        /// <summary>
        /// Executes the main puzzle game loop.
        /// Handles input processing, win condition checking, and game state transitions.
        /// </summary>
        /// <returns>True if puzzle was solved, false if player quit</returns>
        bool Main();

        /// <summary>
        /// Cleans up and disposes of all scene resources.
        /// </summary>
        void EndScene();
    }

    /// <summary>
    /// Interface for the tile puzzle game controller.
    /// Coordinates between scene management and puzzle logic for different game types.
    /// </summary>
    public interface ITilePuzzle
    {
        /// <summary>
        /// Starts a complete tile puzzle game session.
        /// Initializes the scene, runs the main loop, and handles cleanup.
        /// </summary>
        /// <returns>True if puzzle was completed successfully</returns>
        bool StartScreen();
    }

    /// <summary>
    /// Interface for global tile puzzle functionality and game type management.
    /// Provides factory methods for creating different types of tile puzzle games.
    /// </summary>
    public interface ITilePuzzleManager
    {
        /// <summary>
        /// Initiates a tile puzzle game with specified parameters.
        /// Creates the appropriate puzzle type with custom board size and graphics.
        /// </summary>
        /// <param name="game">Game type (1-7 representing different puzzle mechanics)</param>
        /// <param name="board">Graphics board identifier</param>
        /// <param name="width">Board width in tiles (0 for default of 4)</param>
        /// <param name="height">Board height in tiles (0 for default of 4)</param>
        /// <returns>True if puzzle was completed, false if quit</returns>
        bool TilePuzzle(int game, object board, int width = 0, int height = 0);
    }

    /// <summary>
    /// Enumeration of available tile puzzle game types.
    /// Defines the different puzzle mechanics and interaction modes.
    /// </summary>
    public enum TilePuzzleGameType
    {
        /// <summary>
        /// Ruins of Alph puzzle - pick up and place tiles.
        /// </summary>
        RuinsOfAlph = 1,

        /// <summary>
        /// Ruins of Alph puzzle with tile rotations.
        /// </summary>
        RuinsOfAlphWithRotation = 2,

        /// <summary>
        /// Mystic Square (15-puzzle) - slide tiles into empty space.
        /// </summary>
        MysticSquare = 3,

        /// <summary>
        /// Swap two adjacent tiles.
        /// </summary>
        AdjacentSwap = 4,

        /// <summary>
        /// Swap two adjacent tiles with rotations.
        /// </summary>
        AdjacentSwapWithRotation = 5,

        /// <summary>
        /// Rubik's square - shift entire rows/columns.
        /// </summary>
        RubiksSquare = 6,

        /// <summary>
        /// Rotate selected tile plus adjacent tiles simultaneously.
        /// </summary>
        GroupRotation = 7
    }
}