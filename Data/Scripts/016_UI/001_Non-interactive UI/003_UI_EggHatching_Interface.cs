using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon egg hatching scene that displays the egg hatching animation.
    /// Manages the visual sequence from egg cracking to Pokemon emergence with sound effects.
    /// </summary>
    /// <remarks>
    /// To this script works, put it above Main and put a picture (a 5 frames
    /// sprite sheet) with egg sprite height and 5 times the egg sprite width at
    /// Graphics/Battlers/eggCracks.
    /// </remarks>
    /// Egg Hatch Animation - by FL (Credits will be apreciated) | Tweaked by Maruno
    public interface IScenePokemonEggHatch : IScene, IHaveUpdate
    {
        /// <summary>
        /// Starts the egg hatching scene with the specified Pokemon.
        /// Initializes sprites, background, egg cracks bitmap, and flash overlay.
        /// </summary>
        /// <param name="pokemon">The Pokemon that will hatch from the egg.</param>
        void StartScene(IPokemon pokemon);

        /// <summary>
        /// Main animation sequence for the egg hatching process.
        /// Handles the complete sequence from egg shaking to Pokemon reveal.
        /// </summary>
        void Main();

        /// <summary>
        /// Ends the hatching scene and cleans up resources.
        /// Disposes sprites, bitmaps, and viewport unless Pokemon was nicknamed.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Positions the egg crack mask to show the specified crack frame.
        /// Updates the source rectangle to display progressive cracking.
        /// </summary>
        /// <param name="index">The crack frame index (0-4) to display.</param>
        void PositionHatchMask(int index);

        /// <summary>
        /// Animates the egg swinging motion with specified speed and repetitions.
        /// Creates left-right swinging movement with variable intensity.
        /// </summary>
        /// <param name="speed">The speed of the swinging animation.</param>
        /// <param name="swingTimes">The number of swing cycles to perform (default: 1).</param>
        void swingEgg(int speed, int swingTimes = 1);

        /// <summary>
        /// Updates the scene for the specified duration.
        /// Provides timing control for animation sequences and waits.
        /// </summary>
        /// <param name="duration">The duration to update in seconds (default: 0.01).</param>
        void updateScene(float duration = 0.01f);

        /// <summary>
        /// Updates all sprites in the scene.
        /// Called during the animation loop to refresh sprite states.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the Pokemon egg hatching screen that orchestrates the hatching process.
    /// Coordinates between the scene and provides the main entry point for egg hatching.
    /// </summary>
    public interface IScreenPokemonEggHatch : IScreen
    {
        /// <summary>
        /// Initializes the hatching screen with the specified scene.
        /// Sets up the scene instance for managing the hatching animation.
        /// </summary>
        /// <param name="scene">The egg hatching scene to use.</param>
        IScreenPokemonEggHatch initialize(IScenePokemonEggHatch scene);

        /// <summary>
        /// Starts the egg hatching screen for the specified Pokemon.
        /// Orchestrates the complete hatching process from start to finish.
        /// </summary>
        /// <param name="pokemon">The Pokemon to hatch from the egg.</param>
        void StartScreen(IPokemon pokemon);
    }

    /// <summary>
    /// Global interface for egg hatching functionality and utilities.
    /// Provides methods for triggering hatch animations and processing hatching.
    /// </summary>
    public interface IMainEggHatchingUtility : IMain
    {
        /// <summary>
        /// Triggers the egg hatching animation for the specified Pokemon.
        /// Displays the complete hatching sequence with fade transitions.
        /// </summary>
        /// <param name="pokemon">The Pokemon to show hatching for.</param>
        /// <returns>True if the animation completed successfully.</returns>
        bool HatchAnimation(IPokemon pokemon);

        /// <summary>
        /// Processes the Pokemon hatching with stats, ownership, and naming.
        /// Handles the complete hatching process including Pokedex registration.
        /// </summary>
        /// <param name="pokemon">The Pokemon that is hatching.</param>
        void Hatch(IPokemon pokemon);

        /// <summary>
        /// </summary>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_player_step_taken, :hatch_eggs,
        ///   proc {
        ///     $player.party.each do |egg|
        ///       next if egg.steps_to_hatch <= 0
        ///       egg.steps_to_hatch -= 1
        ///       $player.pokemon_party.each do |pkmn|
        ///         next if !pkmn.ability&.has_flag?("FasterEggHatching")
        ///         egg.steps_to_hatch -= 1
        ///         break
        ///       end
        ///       if egg.steps_to_hatch <= 0
        ///         egg.steps_to_hatch = 0
        ///         pbHatch(egg)
        ///       end
        ///     end
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="IEvents.OnPlayerStepTaken"/>
        /// <seealso cref="IEvents.OnStepTaken"/>
        void on_player_step_takenTrigger_hatch_eggs();
    }
}