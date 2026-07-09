using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for individual slot machine reels with spinning mechanics.
    /// Manages reel animation, icon sequences, and stopping behavior with difficulty adjustments.
    /// </summary>
    public interface ISlotMachineReel : IHaveUpdate
    {
        /// <summary>
        /// Initiates the spinning animation for this reel.
        /// Records the starting time and initial position for smooth animation.
        /// </summary>
        void startSpinning();

        /// <summary>
        /// Checks if this reel is currently spinning.
        /// </summary>
        /// <returns>True if the reel is in motion</returns>
        bool spinning();

        /// <summary>
        /// Signals the reel to begin stopping with optional slip prevention.
        /// Applies difficulty-based slipping mechanics for varied stopping behavior.
        /// </summary>
        /// <param name="noslipping">If true, stops immediately without slipping</param>
        void stopSpinning(bool noslipping = false);

        /// <summary>
        /// Gets the current visible icons on this reel.
        /// Returns the three icons currently displayed (top, middle, bottom).
        /// </summary>
        /// <returns>Array of three icon indices [top, middle, bottom]</returns>
        int[] showing();

        /// <summary>
        /// Updates the reel animation and position.
        /// Handles spinning motion, stopping mechanics, and visual rendering.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for score display components in the slot machine.
    /// Manages numeric display of coins with proper formatting and limits.
    /// </summary>
    public interface ISlotMachineScore : IHaveRefresh
    {
        /// <summary>
        /// Gets the current score value.
        /// </summary>
        int score { get; }

        /// <summary>
        /// Sets the score value with automatic limit enforcement.
        /// Ensures the score does not exceed the maximum coin limit.
        /// </summary>
        /// <param name="value">The new score value</param>
        void SetScore(int value);

        /// <summary>
        /// Refreshes the visual display of the score.
        /// Updates the digit sprites to show the current value.
        /// </summary>
        void refresh();
    }

    /// <summary>
    /// Interface for the main slot machine scene and visual management.
    /// Handles all rendering, animations, user interface, and game flow.
    /// </summary>
    public interface ISlotMachineScene : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets whether the game is currently running (reels spinning).
        /// </summary>
        bool gameRunning { get; set; }

        /// <summary>
        /// Gets or sets whether the game has ended and payouts should be calculated.
        /// </summary>
        bool gameEnd { get; set; }

        /// <summary>
        /// Gets or sets the current wager amount (1-3 coins).
        /// </summary>
        int wager { get; set; }

        /// <summary>
        /// Gets or sets whether the player earned a replay bonus.
        /// </summary>
        bool replay { get; set; }

        /// <summary>
        /// Updates all sprite animations and display elements.
        /// </summary>
        void update();

        /// <summary>
        /// Calculates payouts based on reel combinations and displays winning animations.
        /// Handles different payout types, bonus animations, and coin distribution.
        /// </summary>
        void Payout();

        /// <summary>
        /// Initializes the slot machine scene with sprites and interface elements.
        /// Sets up reels, buttons, score displays, and background graphics.
        /// </summary>
        /// <param name="difficulty">Difficulty level affecting reel speed and behavior</param>
        void StartScene(int difficulty);

        /// <summary>
        /// Executes the main game loop for slot machine operation.
        /// Handles player input, game state transitions, and win/loss conditions.
        /// </summary>
        void Main();

        /// <summary>
        /// Cleans up and disposes of all scene resources.
        /// Updates player coin totals and statistics before ending.
        /// </summary>
        void EndScene();
    }

    /// <summary>
    /// Interface for the slot machine game controller.
    /// Coordinates between scene management and game logic.
    /// </summary>
    public interface ISlotMachine
    {
        /// <summary>
        /// Starts a complete slot machine game session.
        /// Initializes the scene, runs the main loop, and handles cleanup.
        /// </summary>
        /// <param name="difficulty">Game difficulty level (0=easy, 1=normal, 2=hard)</param>
        void StartScreen(int difficulty);
    }

    /// <summary>
    /// Interface for global slot machine functionality and access control.
    /// Manages prerequisites and entry conditions for slot machine play.
    /// </summary>
    public interface ISlotMachineManager
    {
        /// <summary>
        /// Initiates a slot machine game with difficulty and prerequisite checking.
        /// Validates coin case possession, coin availability, and coin limits before starting.
        /// </summary>
        /// <param name="difficulty">Difficulty level (0=easy, 1=default, 2=hard)</param>
        void SlotMachine(int difficulty = 1);
    }
}