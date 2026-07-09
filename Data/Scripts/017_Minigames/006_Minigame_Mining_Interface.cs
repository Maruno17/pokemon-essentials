using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the mining game crack counter display.
    /// Manages visual representation of remaining hits before wall collapse.
    /// </summary>
    public interface IMiningGameCounter : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets the current number of hits taken.
        /// </summary>
        int hits { get; set; }

        /// <summary>
        /// Updates the visual display of the crack counter.
        /// Shows crack progression as mining damage accumulates.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for individual mining game tiles.
    /// Represents dirt/rock layers that can be excavated to reveal hidden items.
    /// </summary>
    public interface IMiningGameTile : IHaveUpdate
    {
        /// <summary>
        /// Gets the current layer depth of this tile.
        /// </summary>
        int layer { get; }

        /// <summary>
        /// Sets the layer depth with automatic clamping to valid range.
        /// </summary>
        /// <param name="value">New layer value (minimum 0)</param>
        void SetLayer(int value);

        /// <summary>
        /// Updates the visual representation based on current layer depth.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the mining game cursor with tool animations.
    /// Handles cursor positioning, tool switching, and mining action animations.
    /// </summary>
    public interface IMiningGameCursor : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets the cursor position on the mining board.
        /// </summary>
        int position { get; set; }

        /// <summary>
        /// Gets or sets the current tool mode (0=pick, 1=hammer).
        /// </summary>
        int mode { get; set; }

        /// <summary>
        /// Starts the mining animation for the specified hit type.
        /// </summary>
        /// <param name="hit">Hit type (0=regular, 1=hit item, 2=hit iron)</param>
        void animate(int hit);

        /// <summary>
        /// Checks if the cursor is currently playing an animation.
        /// </summary>
        /// <returns>True if animation is in progress</returns>
        bool isAnimating();

        /// <summary>
        /// Updates the cursor display and animation frames.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the main mining game scene and mechanics.
    /// Manages the complete mining gameplay including item distribution, collision detection, and progression.
    /// </summary>
    public interface IMiningGameScene : IHaveUpdate
    {
        /// <summary>
        /// Updates all sprite animations and display elements.
        /// </summary>
        void update();

        /// <summary>
        /// Initializes the mining game scene with board setup and item placement.
        /// Creates the mining grid, distributes items and iron obstacles, and sets up UI elements.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Distributes valuable items randomly across the mining board.
        /// Uses probability tables to place fossils, stones, and other treasures with overlap checking.
        /// </summary>
        void DistributeItems();

        /// <summary>
        /// Distributes iron obstacles randomly across the mining board.
        /// Places harder-to-mine iron deposits that require more hits to clear.
        /// </summary>
        void DistributeIron();

        /// <summary>
        /// Checks for duplicate item conflicts during placement.
        /// Prevents multiple rare items of the same type from being placed simultaneously.
        /// </summary>
        /// <param name="newitem">The item being considered for placement</param>
        /// <returns>True if the item can be placed without conflicts</returns>
        bool NoDuplicateItems(object newitem);

        /// <summary>
        /// Checks for spatial overlaps between items and iron during placement.
        /// Ensures proper spacing and prevents items from occupying the same board positions.
        /// </summary>
        /// <param name="checkiron">Whether to include iron obstacles in overlap checking</param>
        /// <param name="provx">Proposed X position</param>
        /// <param name="provy">Proposed Y position</param>
        /// <param name="provwidth">Proposed item width</param>
        /// <param name="provheight">Proposed item height</param>
        /// <param name="provpattern">Item pattern for shape checking</param>
        /// <returns>True if placement is valid without overlaps</returns>
        bool CheckOverlaps(bool checkiron, int provx, int provy, int provwidth, int provheight, int[] provpattern);

        /// <summary>
        /// Executes a mining hit action at the cursor position.
        /// Processes tool effects, layer damage, item discovery, and iron interactions.
        /// </summary>
        void Hit();

        /// <summary>
        /// Checks if an item is located at the specified board position.
        /// Used to detect when excavation reveals a hidden treasure.
        /// </summary>
        /// <param name="position">Board position to check</param>
        /// <returns>True if an item is present at the position</returns>
        bool IsItemThere(int position);

        /// <summary>
        /// Checks if iron is located at the specified board position.
        /// Used to determine if special iron-hitting mechanics should be applied.
        /// </summary>
        /// <param name="position">Board position to check</param>
        /// <returns>True if iron is present at the position</returns>
        bool IsIronThere(int position);

        /// <summary>
        /// Checks for fully revealed items and returns their indices.
        /// Determines when items have been completely excavated and can be collected.
        /// </summary>
        /// <returns>Array of revealed item indices</returns>
        int[] CheckRevealed();

        /// <summary>
        /// Displays flash animation for newly revealed items.
        /// Provides visual feedback when items are successfully excavated.
        /// </summary>
        /// <param name="revealed">Array of item indices to flash</param>
        void FlashItems(int[] revealed);

        /// <summary>
        /// Executes the main mining game loop.
        /// Handles player input, win/loss conditions, and game state transitions.
        /// </summary>
        void Main();

        /// <summary>
        /// Awards discovered items to the player's inventory.
        /// Processes all successfully mined items and handles inventory limits.
        /// </summary>
        void GiveItems();

        /// <summary>
        /// Cleans up and disposes of all scene resources.
        /// </summary>
        void EndScene();
    }

    /// <summary>
    /// Interface for the mining game controller.
    /// Coordinates between scene management and game logic.
    /// </summary>
    public interface IMiningGame
    {
        /// <summary>
        /// Starts a complete mining game session.
        /// Initializes the scene, runs the main loop, and handles cleanup.
        /// </summary>
        void StartScreen();
    }

    /// <summary>
    /// Interface for global mining game functionality.
    /// Provides entry point for starting mining game sessions.
    /// </summary>
    public interface IMiningGameManager
    {
        /// <summary>
        /// Initiates a mining game session.
        /// Sets up the game environment and starts the mining minigame.
        /// </summary>
        void MiningGame();
    }
}