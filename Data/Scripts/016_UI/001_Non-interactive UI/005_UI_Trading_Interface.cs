using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon trading scene that displays the trade animation.
    /// Manages the visual sequence of Pokemon being recalled to balls and exchanged.
    /// </summary>
    public interface IScenePokemonTrade : IScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the trading scene.
        /// Called during animation loops to refresh sprite states.
        /// </summary>
        void Update();

        /// <summary>
        /// Runs picture animations synchronously with sprite updates.
        /// Manages the coordination between picture effects and sprite display.
        /// </summary>
        /// <param name="pictures">Array of picture animation objects to run.</param>
        /// <param name="sprites">Array of sprites to synchronize with pictures.</param>
        void RunPictures(IList<object> pictures, IList<ISprite> sprites);

        /// <summary>
        /// Starts the trading screen with the specified Pokemon and trader information.
        /// Initializes viewports, sprites, background, and message windows.
        /// </summary>
        /// <param name="pokemon">The player's Pokemon being traded away.</param>
        /// <param name="pokemon2">The Pokemon being received in trade.</param>
        /// <param name="trader1">The name of the first trader (usually player).</param>
        /// <param name="trader2">The name of the second trader.</param>
        void StartScreen(IPokemon pokemon, IPokemon pokemon2, string trader1, string trader2);

        /// <summary>
        /// Animates the first scene where the player's Pokemon is recalled to its ball.
        /// Shows the Pokemon being drawn into the Poke Ball and sent away.
        /// </summary>
        void Scene1();

        /// <summary>
        /// Animates the second scene where the received Pokemon emerges from its ball.
        /// Shows the ball dropping, bouncing, opening, and Pokemon appearing.
        /// </summary>
        void Scene2();

        /// <summary>
        /// Ends the trading screen and handles post-trade evolution checks.
        /// Cleans up resources and triggers evolution if applicable.
        /// </summary>
        /// <param name="need_fade_out">Whether to fade out before closing (default: true).</param>
        void EndScreen(bool need_fade_out = true);

        /// <summary>
        /// Executes the complete trading sequence with messages and animations.
        /// Handles Pokedex registration, music, scenes, and post-trade activities.
        /// </summary>
        void Trade();
    }

    /// <summary>
    /// Global interface for trading functionality and utilities.
    /// Provides methods for initiating trades between players and NPCs.
    /// </summary>
    public interface IMainTradingUtility : IMain
    {
        /// <summary>
        /// Starts a trade sequence between the player and another trainer.
        /// Handles the complete trade process including Pokemon exchange and scene management.
        /// </summary>
        /// <param name="pokemonIndex">Index of the Pokemon in player's party to trade.</param>
        /// <param name="newpoke">The Pokemon or species to receive (Pokemon object or species ID).</param>
        /// <param name="nickname">The nickname for the received Pokemon.</param>
        /// <param name="trainerName">The name of the trainer giving the Pokemon.</param>
        /// <param name="trainerGender">The gender of the trainer (default: 0).</param>
        void StartTrade(int pokemonIndex, int newpoke, string nickname, string trainerName, int trainerGender = 0);
    }
}