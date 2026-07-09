using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for catch and store mixin which handles Pokemon capture mechanics and storage.
    /// Manages the complete Pokemon capture process including Poke Ball throwing, capture calculations,
    /// Pokemon storage decisions, Pokedex registration, and post-capture handling.
    /// </summary>
    public interface IBattleCatchAndStoreMixin
    {
        /// <summary>
        /// Store caught Pokémon.
        /// </summary>
        /// <remarks>
        /// Stores a caught Pokemon in the player's party or PC with nickname and storage options.
        /// Handles nickname prompts, party management, and provides storage location choices
        /// when the party is full. Manages UI interactions for Pokemon placement decisions.
        /// </remarks>
        /// <param name="pkmn">The Pokemon to store</param>
        void StorePokemon(IPokemon pkmn);

        /// <summary>
        /// Register all caught Pokémon in the Pokédex, and store them.
        /// </summary>
        /// <remarks>
        /// Records all caught Pokemon in the Pokedex and stores them appropriately.
        /// Processes the entire caught Pokemon list, updating Pokedex entries,
        /// displaying new species notifications, and storing each Pokemon via StorePokemon.
        /// Clears the caught Pokemon list after processing.
        /// </remarks>
        void RecordAndStoreCaughtPokemon();

        /// <summary>
        /// Throw a Poké Ball.
        /// </summary>
        /// <remarks>
        /// Executes the complete Poke Ball throw sequence including targeting, animations, and capture resolution.
        /// Handles trainer battle blocks, calculates capture success, manages ball animations,
        /// processes capture outcomes, and handles post-capture Pokemon modifications.
        /// </remarks>
        /// <param name="idxBattler">Index of the battler throwing the ball</param>
        /// <param name="ball">The Poke Ball item being thrown</param>
        /// <param name="catch_rate">Override catch rate, uses species default if null</param>
        /// <param name="showPlayer">Whether to show player animation during throw</param>
        void ThrowPokeBall(int idxBattler, int ball, int? catch_rate = null, bool showPlayer = false);

        /// <summary>
        /// Calculate how many shakes a thrown Poké Ball will make (4 = capture).
        /// </summary>
        /// <remarks>
        /// Calculates the number of shakes a thrown Poke Ball will make during capture attempt.
        /// Implements the core Pokemon capture formula including HP ratio, status effects,
        /// Poke Ball modifiers, critical capture mechanics, and randomization.
        /// </remarks>
        /// <param name="pkmn">The Pokemon being captured</param>
        /// <param name="battler">The battler representation of the Pokemon</param>
        /// <param name="catch_rate">Base catch rate for the calculation</param>
        /// <param name="ball">The Poke Ball being used</param>
        /// <returns>Number of shakes (0-3 for failure, 4 for capture success)</returns>
        int CaptureCalc(IPokemon pkmn, IBattler battler, int catch_rate, int ball);
    }
}