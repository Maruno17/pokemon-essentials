using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Base interface for all minigame implementations in Pokemon Essentials.
    /// Provides common functionality for minigame lifecycle and state management.
    /// </summary>
    public interface IMinigame : IHaveUpdate
    {
        /// <summary>
        /// Starts the minigame and initializes all necessary components.
        /// </summary>
        void StartGame();

        /// <summary>
        /// Ends the minigame and cleans up resources.
        /// </summary>
        void EndGame();

        /// <summary>
        /// Updates the minigame state and graphics.
        /// </summary>
        void Update();

        /// <summary>
        /// Processes user input for the minigame.
        /// </summary>
        /// <returns>True if input was processed, false otherwise.</returns>
        bool ProcessInput();

        /// <summary>
        /// Gets the current score or points in the minigame.
        /// </summary>
        /// <returns>The current score.</returns>
        int getScore();

        /// <summary>
        /// Checks if the minigame is currently active.
        /// </summary>
        /// <returns>True if the game is active, false otherwise.</returns>
        bool isActive();

        /// <summary>
        /// Pauses or unpauses the minigame.
        /// </summary>
        /// <param name="paused">Whether to pause the game.</param>
        void setPaused(bool paused);

        /// <summary>
        /// Gets the result of the minigame when it ends.
        /// </summary>
        /// <returns>The game result (win/lose/score/etc.).</returns>
        object getGameResult();
    }

    /// <summary>
    /// Interface for minigames that use a grid-based playing field.
    /// </summary>
    public interface IGridMinigame : IMinigame
    {
        /// <summary>
        /// Gets the width of the game grid.
        /// </summary>
        /// <returns>The grid width in cells.</returns>
        int getGridWidth();

        /// <summary>
        /// Gets the height of the game grid.
        /// </summary>
        /// <returns>The grid height in cells.</returns>
        int getGridHeight();

        /// <summary>
        /// Gets the value at a specific grid position.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <returns>The value at the specified position.</returns>
        object getGridValue(int x, int y);

        /// <summary>
        /// Sets the value at a specific grid position.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <param name="value">The value to set.</param>
        void setGridValue(int x, int y, object value);

        /// <summary>
        /// Gets the currently selected grid position.
        /// </summary>
        /// <returns>The selected coordinates.</returns>
        //(int x, int y) getSelectedPosition();
        KeyValuePair<int,int> getSelectedPosition();

        /// <summary>
        /// Sets the selected grid position.
        /// </summary>
        /// <param name="x">The X coordinate to select.</param>
        /// <param name="y">The Y coordinate to select.</param>
        void setSelectedPosition(int x, int y);
    }

    /// <summary>
    /// Interface for card-based minigames.
    /// </summary>
    public interface ICardMinigame : IMinigame
    {
        /// <summary>
        /// Shuffles the deck of cards.
        /// </summary>
        void shuffleDeck();

        /// <summary>
        /// Deals cards to players or the playing field.
        /// </summary>
        /// <param name="numCards">The number of cards to deal.</param>
        void dealCards(int numCards);

        /// <summary>
        /// Gets the player's current hand.
        /// </summary>
        /// <returns>List of cards in the player's hand.</returns>
        IList<object> getPlayerHand();

        /// <summary>
        /// Plays a card from the player's hand.
        /// </summary>
        /// <param name="cardIndex">The index of the card to play.</param>
        /// <returns>True if the card was played successfully, false otherwise.</returns>
        bool playCard(int cardIndex);

        /// <summary>
        /// Gets the number of cards remaining in the deck.
        /// </summary>
        /// <returns>The number of cards left in the deck.</returns>
        int getRemainingCards();
    }

    /// <summary>
    /// Interface for gambling/casino-style minigames.
    /// </summary>
    public interface IGamblingMinigame : IMinigame
    {
        /// <summary>
        /// Places a bet for the current game.
        /// </summary>
        /// <param name="amount">The amount to bet.</param>
        /// <returns>True if the bet was placed successfully, false otherwise.</returns>
        bool placeBet(int amount);

        /// <summary>
        /// Gets the current bet amount.
        /// </summary>
        /// <returns>The current bet amount.</returns>
        int getCurrentBet();

        /// <summary>
        /// Gets the player's current coins or credits.
        /// </summary>
        /// <returns>The number of coins/credits the player has.</returns>
        int getPlayerCoins();

        /// <summary>
        /// Awards coins to the player.
        /// </summary>
        /// <param name="amount">The amount of coins to award.</param>
        void awardCoins(int amount);

        /// <summary>
        /// Gets the payout multiplier for the current game state.
        /// </summary>
        /// <returns>The payout multiplier.</returns>
        float getPayoutMultiplier();

        /// <summary>
        /// Checks if the player can afford to place a bet.
        /// </summary>
        /// <param name="amount">The bet amount to check.</param>
        /// <returns>True if the player can afford the bet, false otherwise.</returns>
        bool canAffordBet(int amount);
    }

    /// <summary>
    /// Interface for the Voltorb Flip minigame.
    /// A logic puzzle game involving revealing tiles without hitting Voltorbs.
    /// </summary>
    public interface IVoltorbFlipMinigame : IGridMinigame, IGamblingMinigame
    {
        /// <summary>
        /// Reveals a tile at the specified position.
        /// </summary>
        /// <param name="x">The X coordinate of the tile.</param>
        /// <param name="y">The Y coordinate of the tile.</param>
        /// <returns>The value revealed (number or Voltorb).</returns>
        object revealTile(int x, int y);

        /// <summary>
        /// Marks or unmarks a tile as containing a Voltorb.
        /// </summary>
        /// <param name="x">The X coordinate of the tile.</param>
        /// <param name="y">The Y coordinate of the tile.</param>
        /// <param name="marked">Whether to mark the tile.</param>
        void markTile(int x, int y, bool marked);

        /// <summary>
        /// Gets the hint numbers for a row.
        /// </summary>
        /// <param name="row">The row index.</param>
        /// <returns>Tuple containing (points sum, Voltorb count).</returns>
        //(int points, int voltorbs) getRowHint(int row);
        KeyValuePair<int, int> getRowHint(int row);

        /// <summary>
        /// Gets the hint numbers for a column.
        /// </summary>
        /// <param name="col">The column index.</param>
        /// <returns>Tuple containing (points sum, Voltorb count).</returns>
        //(int points, int voltorbs) getColumnHint(int col);
        KeyValuePair<int, int> getColumnHint(int col);

        /// <summary>
        /// Gets the current level of the Voltorb Flip game.
        /// </summary>
        /// <returns>The current level.</returns>
        int getCurrentLevel();

        /// <summary>
        /// Checks if the current board is solved.
        /// </summary>
        /// <returns>True if all non-Voltorb tiles are revealed, false otherwise.</returns>
        bool isBoardSolved();
    }

    /// <summary>
    /// Interface for slot machine minigames.
    /// </summary>
    public interface ISlotMachineMinigame : IGamblingMinigame
    {
        /// <summary>
        /// Spins the slot machine reels.
        /// </summary>
        void spinReels();

        /// <summary>
        /// Stops a specific reel.
        /// </summary>
        /// <param name="reelIndex">The index of the reel to stop.</param>
        void stopReel(int reelIndex);

        /// <summary>
        /// Gets the symbols currently displayed on the reels.
        /// </summary>
        /// <returns>Array of symbols for each reel.</returns>
        IList<object> getReelSymbols();

        /// <summary>
        /// Checks if the current combination is a winning one.
        /// </summary>
        /// <returns>True if it's a winning combination, false otherwise.</returns>
        bool isWinningCombination();

        /// <summary>
        /// Gets the payout for the current symbol combination.
        /// </summary>
        /// <returns>The payout amount.</returns>
        int calculatePayout();

        /// <summary>
        /// Checks if any reels are currently spinning.
        /// </summary>
        /// <returns>True if reels are spinning, false otherwise.</returns>
        bool areReelsSpinning();
    }

    /// <summary>
    /// Interface for puzzle-based minigames like tile puzzles.
    /// </summary>
    public interface IPuzzleMinigame : IGridMinigame
    {
        /// <summary>
        /// Shuffles the puzzle pieces.
        /// </summary>
        void shufflePuzzle();

        /// <summary>
        /// Moves a puzzle piece to an adjacent empty space.
        /// </summary>
        /// <param name="x">The X coordinate of the piece to move.</param>
        /// <param name="y">The Y coordinate of the piece to move.</param>
        /// <returns>True if the piece was moved, false otherwise.</returns>
        bool movePiece(int x, int y);

        /// <summary>
        /// Checks if the puzzle is solved.
        /// </summary>
        /// <returns>True if the puzzle is in the correct state, false otherwise.</returns>
        bool isPuzzleSolved();

        /// <summary>
        /// Gets the number of moves made so far.
        /// </summary>
        /// <returns>The move count.</returns>
        int getMoveCount();

        /// <summary>
        /// Resets the puzzle to the starting state.
        /// </summary>
        void resetPuzzle();

        /// <summary>
        /// Gets the position of the empty space.
        /// </summary>
        /// <returns>The coordinates of the empty space.</returns>
        //(int x, int y) getEmptySpacePosition();
        KeyValuePair<int, int> getEmptySpacePosition();
    }

    /// <summary>
    /// Interface for mining minigames where players dig for items.
    /// </summary>
    public interface IMiningMinigame : IGridMinigame
    {
        /// <summary>
        /// Digs at a specific position on the mining grid.
        /// </summary>
        /// <param name="x">The X coordinate to dig at.</param>
        /// <param name="y">The Y coordinate to dig at.</param>
        /// <returns>The item found, or null if nothing was found.</returns>
        object dig(int x, int y);

        /// <summary>
        /// Uses a specific tool for digging.
        /// </summary>
        /// <param name="toolType">The type of tool to use.</param>
        /// <param name="x">The X coordinate to use the tool at.</param>
        /// <param name="y">The Y coordinate to use the tool at.</param>
        /// <returns>The result of using the tool.</returns>
        object useTool(string toolType, int x, int y);

        /// <summary>
        /// Gets the items found during mining.
        /// </summary>
        /// <returns>List of items discovered.</returns>
        IList<object> getFoundItems();

        /// <summary>
        /// Gets the remaining time for mining.
        /// </summary>
        /// <returns>The time remaining in seconds.</returns>
        float getTimeRemaining();

        /// <summary>
        /// Checks if there are any hidden items at the specified position.
        /// </summary>
        /// <param name="x">The X coordinate to check.</param>
        /// <param name="y">The Y coordinate to check.</param>
        /// <returns>True if there's a hidden item, false otherwise.</returns>
        bool hasHiddenItem(int x, int y);

        /// <summary>
        /// Gets the crack pattern around a position (for detecting nearby items).
        /// </summary>
        /// <param name="x">The X coordinate to check around.</param>
        /// <param name="y">The Y coordinate to check around.</param>
        /// <returns>The crack pattern indicator.</returns>
        int getCrackPattern(int x, int y);
    }

    /// <summary>
    /// Interface for lottery-style minigames.
    /// </summary>
    public interface ILotteryMinigame : IMinigame
    {
        /// <summary>
        /// Purchases a lottery ticket.
        /// </summary>
        /// <returns>The lottery ticket number or identifier.</returns>
        object buyTicket();

        /// <summary>
        /// Checks if a ticket is a winner.
        /// </summary>
        /// <param name="ticket">The ticket to check.</param>
        /// <returns>The prize won, or null if not a winner.</returns>
        object checkTicket(object ticket);

        /// <summary>
        /// Gets the current jackpot amount.
        /// </summary>
        /// <returns>The jackpot amount.</returns>
        int getJackpot();

        /// <summary>
        /// Gets the cost of a lottery ticket.
        /// </summary>
        /// <returns>The ticket cost.</returns>
        int getTicketCost();

        /// <summary>
        /// Draws the winning numbers for the lottery.
        /// </summary>
        /// <returns>The winning numbers or combination.</returns>
        object drawWinningNumbers();
    }

    /// <summary>
    /// Interface for minigame utilities and management functions.
    /// </summary>
    public interface IMinigameUtilities
    {
        /// <summary>
        /// Starts a specific minigame by name.
        /// </summary>
        /// <param name="minigameName">The name of the minigame to start.</param>
        /// <param name="parameters">Optional parameters for the minigame.</param>
        /// <returns>The result of the minigame.</returns>
        object startMinigame(string minigameName, object parameters = null);

        /// <summary>
        /// Checks if a minigame is available to play.
        /// </summary>
        /// <param name="minigameName">The name of the minigame to check.</param>
        /// <returns>True if the minigame is available, false otherwise.</returns>
        bool isMinigameAvailable(string minigameName);

        /// <summary>
        /// Gets the high score for a specific minigame.
        /// </summary>
        /// <param name="minigameName">The name of the minigame.</param>
        /// <returns>The high score.</returns>
        int getHighScore(string minigameName);

        /// <summary>
        /// Sets a new high score for a minigame.
        /// </summary>
        /// <param name="minigameName">The name of the minigame.</param>
        /// <param name="score">The new high score.</param>
        void setHighScore(string minigameName, int score);

        /// <summary>
        /// Gets a list of all available minigames.
        /// </summary>
        /// <returns>List of minigame names.</returns>
        IList<string> getAvailableMinigames();
    }
}