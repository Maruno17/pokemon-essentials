using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Provides field-related debug commands and options.
    /// Contains debug functionality for map warping, switch/variable editing, PC access, and other field operations used during development and testing.
    /// </summary>
    public interface IDebugMenuCommands
    {
        /// <summary>
        /// Field options submenu containing various field-related debug commands.
        /// Provides access to map manipulation, game state editing, and development utilities.
        /// </summary>
        void field_menu();

        /// <summary>
        /// Warp to map functionality for instant travel between game maps.
        /// Allows developers to quickly navigate to any map for testing purposes.
        /// </summary>
        void warp();

        /// <summary>
        /// Access PC functionality from anywhere in the game.
        /// Provides quick access to Pokemon storage and PC utilities for testing.
        /// </summary>
        void use_pc();

        /// <summary>
        /// Edit game switches for testing different game states.
        /// Allows modification of boolean flags that control game behavior.
        /// </summary>
        void switches();

        /// <summary>
        /// Edit game variables for testing different values.
        /// Allows modification of numeric and text variables used throughout the game.
        /// </summary>
        void variables();

        /// <summary>
        /// Edit Safari Zone and Bug-Catching Contest parameters.
        /// Allows modification of steps remaining, time limits, and usable Poke Balls.
        /// </summary>
        void safari_zone_and_bug_contest();
    }
}