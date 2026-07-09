using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon evolution scene that displays the evolution animation.
    /// Manages the visual transformation from one Pokemon species to another with scaling effects.
    /// </summary>
    public interface IScenePokemonEvolution : IScene, IHaveUpdate
    {
        /// <summary>
        /// Creates a duplicate Pokemon with the new species for special evolution cases.
        /// Clones the original Pokemon and modifies it to be the evolved form.
        /// </summary>
        /// <param name="pkmn">The original Pokemon to duplicate.</param>
        /// <param name="new_species">The species ID for the evolved Pokemon.</param>
        void DuplicatePokemon(IPokemon pkmn, int new_species);

        /// <summary>
        /// Starts the evolution screen with the specified Pokemon and target species.
        /// Initializes viewports, sprites, background, and animation setup.
        /// </summary>
        /// <param name="pokemon">The Pokemon that is evolving.</param>
        /// <param name="newspecies">The species the Pokemon is evolving into.</param>
        void StartScreen(IPokemon pokemon, int newspecies);

        /// <summary>
        /// Sets up the animation sequences for the evolution process.
        /// Creates scaling and color transition effects for sprite transformation.
        /// </summary>
        void set_up_animation();

        /// <summary>
        /// Opens the evolution screen and handles the complete evolution process.
        /// Manages animation, user input, and evolution success or cancellation.
        /// </summary>
        /// <param name="cancancel">Whether the evolution can be cancelled by the player (default: true).</param>
        void Evolution(bool cancancel = true);

        /// <summary>
        /// Updates the viewport to create a narrowing screen effect during evolution.
        /// Gradually reduces the visible screen area to focus on the Pokemon.
        /// </summary>
        /// <param name="timer_start">The timestamp when the effect started.</param>
        void UpdateNarrowScreen(double timer_start);

        /// <summary>
        /// Updates the viewport to expand the screen back to full size.
        /// Gradually restores the full screen view after evolution completes.
        /// </summary>
        /// <param name="timer_start">The timestamp when the expansion started.</param>
        void UpdateExpandScreen(double timer_start);

        /// <summary>
        /// Creates a flash transition effect for evolution completion or cancellation.
        /// Handles the white flash and sprite visibility changes.
        /// </summary>
        /// <param name="canceled">Whether the evolution was cancelled.</param>
        void FlashInOut(bool canceled);

        /// <summary>
        /// Handles successful evolution completion with species change and moves.
        /// Updates Pokemon data, plays success jingle, and handles move learning.
        /// </summary>
        void EvolutionSuccess();

        /// <summary>
        /// Executes post-evolution methods specific to the evolution type.
        /// Handles special cases like item consumption or form changes.
        /// </summary>
        void EvolutionMethodAfterEvolution();

        /// <summary>
        /// Updates the evolution scene sprites and animation.
        /// Provides different update behavior during animation versus normal display.
        /// </summary>
        /// <param name="animating">Whether the scene is currently animating (default: false).</param>
        void Update(bool animating = false);

        /// <summary>
        /// Closes the evolution screen and cleans up resources.
        /// Disposes sprites, viewports, and handles fade out transition.
        /// </summary>
        /// <param name="need_fade_out">Whether to fade out before closing (default: true).</param>
        void EndScreen(bool need_fade_out = true);
    }
}