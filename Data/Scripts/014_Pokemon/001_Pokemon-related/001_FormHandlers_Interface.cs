using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the MultipleForms module that handles Pokemon form variations.
    /// Provides methods for registering and managing Pokemon form handlers.
    /// </summary>
    public interface IMultipleForms
    {
        /// <summary>
        /// Copies form handlers from one species to other species.
        /// </summary>
        /// <param name="sym">The source species symbol.</param>
        /// <param name="syms">Array of target species symbols to copy handlers to.</param>
        void copy(int sym, params object[] syms);

        /// <summary>
        /// Registers form handlers for a specific Pokemon species.
        /// </summary>
        /// <param name="sym">The species symbol to register handlers for.</param>
        /// <param name="hash">Dictionary of handler functions.</param>
        void register(int sym, IDictionary<string, object> hash);

        /// <summary>
        /// Conditionally registers form handlers for a specific Pokemon species.
        /// </summary>
        /// <param name="sym">The species symbol to register handlers for.</param>
        /// <param name="cond">The condition that must be met for registration.</param>
        /// <param name="hash">Dictionary of handler functions.</param>
        void registerIf(int sym, bool cond, IDictionary<string, object> hash);

        /// <summary>
        /// Checks if a Pokemon species has a specific form handler function.
        /// </summary>
        /// <param name="pkmn">The Pokemon or species to check.</param>
        /// <param name="func">The function name to check for.</param>
        /// <returns>True if the function exists, false otherwise.</returns>
        bool hasFunction(IPokemon pkmn, string func);

        /// <summary>
        /// Gets a specific form handler function for a Pokemon species.
        /// </summary>
        /// <param name="pkmn">The Pokemon or species to get the function for.</param>
        /// <param name="func">The function name to retrieve.</param>
        /// <returns>The handler function if it exists, null otherwise.</returns>
        string getFunction(IPokemon pkmn, string func);

        /// <summary>
        /// Calls a form handler function for a Pokemon with optional arguments.
        /// </summary>
        /// <param name="func">The function name to call.</param>
        /// <param name="pkmn">The Pokemon to call the function on.</param>
        /// <param name="args">Optional arguments to pass to the function.</param>
        /// <returns>The result of the function call, or null if function doesn't exist.</returns>
        int? call(string func, IPokemon pkmn, params object[] args);
    }

    /// <summary>
    /// Interface for Pokemon form drawing utilities.
    /// Provides methods for drawing spots and patterns on Pokemon sprites.
    /// </summary>
    public interface IMainPokemonFormDrawing : IMain
    {
        /// <summary>
        /// Draws a spot pattern on a bitmap at specified coordinates with color adjustments.
        /// </summary>
        /// <param name="bitmap">The bitmap to draw on.</param>
        /// <param name="spotpattern">2D array defining the spot pattern.</param>
        /// <param name="x">X coordinate to start drawing.</param>
        /// <param name="y">Y coordinate to start drawing.</param>
        /// <param name="red">Red color adjustment.</param>
        /// <param name="green">Green color adjustment.</param>
        /// <param name="blue">Blue color adjustment.</param>
        void drawSpot(IBitmap bitmap, int[][] spotpattern, int x, int y, int red, int green, int blue);

        /// <summary>
        /// Draws Spinda's unique spot pattern on a Pokemon sprite.
        /// The pattern is based on the Pokemon's personality ID.
        /// </summary>
        /// <param name="pkmn">The Pokemon whose spots to draw.</param>
        /// <param name="bitmap">The bitmap to draw the spots on.</param>
        void SpindaSpots(IPokemon pkmn, IBitmap bitmap);
    }
    /*
    /// <summary>
    /// Interface for Pokemon form handler functions.
    /// Defines all the possible form handler function signatures.
    /// </summary>
    public interface IPokemonFormHandlerFunctions
    {
        /// <summary>
        /// Gets the form to use when creating a new Pokemon.
        /// </summary>
        /// <param name="pkmn">The Pokemon being created.</param>
        /// <returns>The form number to use.</returns>
        int getFormOnCreation(object pkmn);

        /// <summary>
        /// Gets the current form for a Pokemon based on its state.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the form for.</param>
        /// <returns>The form number to use.</returns>
        int getForm(object pkmn);

        /// <summary>
        /// Gets the form to use when a Pokemon enters battle.
        /// </summary>
        /// <param name="pkmn">The Pokemon entering battle.</param>
        /// <param name="wild">Whether this is a wild Pokemon encounter.</param>
        /// <returns>The form number to use in battle.</returns>
        int getFormOnEnteringBattle(object pkmn, bool wild);

        /// <summary>
        /// Gets the form to use when a Pokemon starts a battle turn.
        /// </summary>
        /// <param name="pkmn">The Pokemon starting the battle.</param>
        /// <param name="wild">Whether this is a wild Pokemon encounter.</param>
        /// <returns>The form number to use.</returns>
        int getFormOnStartingBattle(object pkmn, bool wild);

        /// <summary>
        /// Gets the form to use when a Pokemon leaves battle.
        /// </summary>
        /// <param name="pkmn">The Pokemon leaving battle.</param>
        /// <param name="battle">The battle object.</param>
        /// <param name="usedInBattle">Whether the Pokemon was used in battle.</param>
        /// <param name="endBattle">Whether the battle is ending.</param>
        /// <returns>The form number to use after battle.</returns>
        int getFormOnLeavingBattle(object pkmn, object battle, bool usedInBattle, bool endBattle);

        /// <summary>
        /// Gets the form to use when creating an egg.
        /// </summary>
        /// <param name="pkmn">The Pokemon whose egg is being created.</param>
        /// <returns>The form number for the egg Pokemon.</returns>
        int getFormOnEggCreation(object pkmn);

        /// <summary>
        /// Gets the primal form for a Pokemon (used for primal reversion).
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the primal form for.</param>
        /// <returns>The primal form number, or null if no primal form exists.</returns>
        int? getPrimalForm(object pkmn);

        /// <summary>
        /// Gets the form to revert to from primal form.
        /// </summary>
        /// <param name="pkmn">The Pokemon to get the unprimal form for.</param>
        /// <returns>The unprimal form number.</returns>
        int getUnprimalForm(object pkmn);

        /// <summary>
        /// Called when a Pokemon's form is changed.
        /// </summary>
        /// <param name="pkmn">The Pokemon whose form changed.</param>
        /// <param name="form">The new form number.</param>
        /// <param name="oldForm">The previous form number.</param>
        void onSetForm(object pkmn, int form, int oldForm);

        /// <summary>
        /// Modifies a Pokemon when it enters battle.
        /// </summary>
        /// <param name="pkmn">The Pokemon entering battle.</param>
        /// <param name="battle">The battle object.</param>
        void changePokemonOnStartingBattle(object pkmn, object battle);

        /// <summary>
        /// Modifies a Pokemon when it leaves battle.
        /// </summary>
        /// <param name="pkmn">The Pokemon leaving battle.</param>
        /// <param name="battle">The battle object.</param>
        /// <param name="usedInBattle">Whether the Pokemon was used in battle.</param>
        /// <param name="endBattle">Whether the battle is ending.</param>
        void changePokemonOnLeavingBattle(object pkmn, object battle, bool usedInBattle, bool endBattle);

        /// <summary>
        /// Alters a Pokemon's bitmap sprite.
        /// </summary>
        /// <param name="pkmn">The Pokemon whose sprite to alter.</param>
        /// <param name="bitmap">The bitmap to modify.</param>
        void alterBitmap(object pkmn, object bitmap);
    }
    */
}