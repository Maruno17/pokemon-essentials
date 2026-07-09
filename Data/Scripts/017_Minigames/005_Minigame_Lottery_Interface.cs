using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for lottery number generation and management.
    /// Handles daily lottery number creation using date-based seeding for consistency.
    /// </summary>
    public interface ILotteryNumberGenerator
    {
        /// <summary>
        /// Generates and sets the daily lottery number based on current date.
        /// Uses deterministic seeding to ensure the same number is generated throughout the day.
        /// The lottery number is stored in the specified game variable as a 5-digit string.
        /// </summary>
        /// <param name="variable">Game variable ID to store the lottery number (default: 1)</param>
        void SetLotteryNumber(int variable = 1);
    }

    /// <summary>
    /// Interface for lottery prize checking and winner determination.
    /// Searches through player's Pokemon collection to find lottery matches and determine prizes.
    /// </summary>
    public interface ILotteryChecker
    {
        /// <summary>
        /// Checks all Pokemon in party and storage for lottery number matches.
        /// Compares the rightmost digits of each Pokemon's Trainer ID against the winning number.
        /// Finds the Pokemon with the most matching consecutive digits from the right.
        /// </summary>
        /// <param name="winnum">The winning lottery number to check against</param>
        /// <param name="nameVar">Game variable to store the name of the winning Pokemon (default: 2)</param>
        /// <param name="positionVar">Game variable to store location of winner (default: 3) - 1=Party, 2=Storage</param>
        /// <param name="matchedVar">Game variable to store number of matched digits (default: 4)</param>
        void Lottery(object winnum, int nameVar = 2, int positionVar = 3, int matchedVar = 4);
    }

    /// <summary>
    /// Interface for combined lottery system functionality.
    /// Provides high-level operations for the complete lottery minigame system.
    /// </summary>
    public interface ILotteryManager : ILotteryNumberGenerator, ILotteryChecker
    {
        /// <summary>
        /// Executes a complete lottery check cycle.
        /// Generates today's lottery number and immediately checks for winners in the player's collection.
        /// </summary>
        /// <param name="nameVar">Variable for winner name</param>
        /// <param name="positionVar">Variable for winner location</param>
        /// <param name="matchedVar">Variable for matched digits</param>
        void ExecuteLotteryCheck(int nameVar = 2, int positionVar = 3, int matchedVar = 4);

        /// <summary>
        /// Gets the current day's lottery number without regenerating it.
        /// </summary>
        /// <param name="variable">Variable containing the lottery number</param>
        /// <returns>The current lottery number as a string</returns>
        string GetCurrentLotteryNumber(int variable = 1);

        /// <summary>
        /// Calculates the prize tier based on number of matched digits.
        /// </summary>
        /// <param name="matchedDigits">Number of consecutive matching digits from right</param>
        /// <returns>Prize tier (0=no prize, 1-5=increasing prize value)</returns>
        int GetPrizeTier(int matchedDigits);
    }
}