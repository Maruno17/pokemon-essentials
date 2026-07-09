using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the duel window that displays player information during battles.
    /// Manages display of health points, player names, and color-coded text formatting.
    /// </summary>
    public interface IDuelWindow
    {
        /// <summary>
        /// Gets the current health points of the participant.
        /// </summary>
        int hp { get; }

        /// <summary>
        /// Gets the name of the participant.
        /// </summary>
        string name { get; }

        /// <summary>
        /// Gets whether this window represents an enemy participant.
        /// </summary>
        bool is_enemy { get; }

        /// <summary>
        /// Sets the health points and refreshes the display.
        /// </summary>
        /// <param name="value">The new health point value</param>
        void SetHp(int value);

        /// <summary>
        /// Sets the participant name and refreshes the display.
        /// </summary>
        /// <param name="value">The new name</param>
        void SetName(string value);

        /// <summary>
        /// Sets whether this represents an enemy and refreshes the display.
        /// </summary>
        /// <param name="value">True if enemy, false if player</param>
        void SetIsEnemy(bool value);

        /// <summary>
        /// Refreshes the window display with current values.
        /// Updates text colors based on enemy status and formats HP display.
        /// </summary>
        void duel_refresh();
    }

    /// <summary>
    /// Interface for the main Pokemon duel minigame system.
    /// Handles duel setup, battle mechanics, animation sequences, and screen management.
    /// </summary>
    public interface IPokemonDuel
    {
        /// <summary>
        /// Starts a duel sequence with animated sprite introductions.
        /// Sets up player and opponent sprites with smooth movement animations.
        /// </summary>
        /// <param name="opponent">The opponent trainer data</param>
        /// <param name="gameEvent">The map event representing the opponent</param>
        void StartDuel(ITrainer opponent, IGameEvent gameEvent);

        /// <summary>
        /// Executes the main duel gameplay loop with turn-based combat.
        /// Handles player input, AI decisions, battle calculations, and win conditions.
        /// </summary>
        /// <param name="opponent">The opponent trainer</param>
        /// <param name="gameEvent">The map event</param>
        /// <param name="speeches">Array of 12 speech texts for opponent actions</param>
        /// <returns>True if player wins, false if player loses</returns>
        bool Duel(ITrainer opponent, IGameEvent gameEvent, string[] speeches);

        /// <summary>
        /// Ends the duel with cleanup and restoration of normal game state.
        /// Restores player and event movement speeds and disposes of sprites.
        /// </summary>
        void EndDuel();

        /// <summary>
        /// Creates screen flash effects for both player and opponent during attacks.
        /// Provides visual feedback for successful hits and defensive actions.
        /// </summary>
        /// <param name="player">Whether to flash the player sprite</param>
        /// <param name="opponent">Whether to flash the opponent sprite</param>
        void FlashScreens(bool player, bool opponent);

        /// <summary>
        /// Updates the health display windows for both participants.
        /// Synchronizes HP values between game logic and visual display.
        /// </summary>
        void Refresh();
    }

    /// <summary>
    /// Interface for global duel functionality and initialization.
    /// Provides factory methods for starting duels with proper parameter validation.
    /// </summary>
    public interface IDuelManager
    {
        /// <summary>
        /// Initiates a duel minigame with specified parameters.
        /// Creates trainer objects, validates speech arrays, and starts the duel sequence.
        /// </summary>
        /// <param name="trainer_id">ID or symbol of the opponent's trainer type</param>
        /// <param name="trainer_name">Name of the opponent trainer</param>
        /// <param name="gameEvent">Game event object for the character's event</param>
        /// <param name="speeches">Array of 12 speeches for different opponent actions</param>
        /// <returns>True if player wins, false if player loses</returns>
        bool Duel(object trainer_id, string trainer_name, IGameEvent gameEvent, string[] speeches);
    }
}