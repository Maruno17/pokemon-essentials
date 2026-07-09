using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the party screen scene that displays the player's Pokemon party.
    /// Allows viewing and interacting with Pokemon in the party.
    /// </summary>
    public interface IPartyDisplayScene : IScene, IPokemonUIScene, IListUIScene
    {
        /// <summary>
        /// Sets the party of Pokemon to display.
        /// </summary>
        /// <param name="party">The party array of Pokemon.</param>
        void setParty(IList<IPokemon> party);

        /// <summary>
        /// Gets the currently displayed party.
        /// </summary>
        /// <returns>The party array of Pokemon.</returns>
        IList<IPokemon> getParty();

        /// <summary>
        /// Shows the party selection interface.
        /// </summary>
        /// <param name="helpText">Optional help text to display.</param>
        /// <returns>The index of the selected Pokemon, or -1 if cancelled.</returns>
        int ChoosePokemon(string helpText = null);

        /// <summary>
        /// Shows party annotations (like status conditions, items held).
        /// </summary>
        /// <param name="annotations">The annotation mode to display.</param>
        void ShowAnnotations(string annotations);

        /// <summary>
        /// Hides party annotations.
        /// </summary>
        void HideAnnotations();

        /// <summary>
        /// Updates the display for a specific Pokemon in the party.
        /// </summary>
        /// <param name="index">The index of the Pokemon to update.</param>
        void UpdatePokemon(int index);

        /// <summary>
        /// Shows a summary popup for the selected Pokemon.
        /// </summary>
        /// <param name="pokemonIndex">The index of the Pokemon to show summary for.</param>
        void ShowPokemonSummary(int pokemonIndex);
    }

    /// <summary>
    /// Interface for the party screen that manages party display and interactions.
    /// </summary>
    public interface IPartyDisplayScreen : IScreen, IUIScreen
    {
        /// <summary>
        /// Starts the party screen for Pokemon selection.
        /// </summary>
        /// <param name="party">The party of Pokemon to display.</param>
        /// <param name="helpText">Help text to show the user.</param>
        /// <param name="canCancel">Whether the user can cancel the selection.</param>
        /// <returns>The index of the selected Pokemon, or -1 if cancelled.</returns>
        int StartScreen(IList<object> party, string helpText, bool canCancel = true);

        /// <summary>
        /// Shows the party screen for choosing a Pokemon.
        /// </summary>
        /// <param name="variableNumber">The variable to store the result in.</param>
        /// <param name="nameVarNumber">The variable to store the Pokemon name in.</param>
        /// <param name="ableProc">Function to determine if a Pokemon can be selected.</param>
        /// <param name="allowIneligible">Whether ineligible Pokemon can still be selected.</param>
        /// <returns>The index of the selected Pokemon.</returns>
        int ChoosePokemon(int variableNumber, int nameVarNumber = 0, Func<IPokemon, bool> ableProc = null, bool allowIneligible = false);
    }

    /// <summary>
    /// Interface for party-related utilities and helper functions.
    /// </summary>
    public interface IPartyUtilities
    {
        /// <summary>
        /// Opens the party screen to choose a Pokemon.
        /// </summary>
        /// <param name="variableNumber">The variable to store the selected index.</param>
        /// <param name="nameVarNumber">The variable to store the Pokemon name.</param>
        /// <param name="ableProc">Function to check if a Pokemon can be selected.</param>
        /// <param name="allowIneligible">Whether ineligible Pokemon can be selected.</param>
        /// <returns>The selected Pokemon index.</returns>
        int ChoosePokemon(int variableNumber, int nameVarNumber = 0, Func<IPokemon, bool> ableProc = null, bool allowIneligible = false);

        /// <summary>
        /// Shows the party screen with specific annotation mode.
        /// </summary>
        /// <param name="annotationMode">The type of annotations to show.</param>
        /// <returns>The result of the party screen interaction.</returns>
        int PokemonScreen(string annotationMode = null);

        /// <summary>
        /// Gets the number of able (non-fainted) Pokemon in the party.
        /// </summary>
        /// <returns>The count of able Pokemon.</returns>
        int getAblePokemonCount();

        /// <summary>
        /// Checks if the party has any able Pokemon.
        /// </summary>
        /// <returns>True if there are able Pokemon, false otherwise.</returns>
        bool hasAblePokemon();

        /// <summary>
        /// Gets the first able Pokemon in the party.
        /// </summary>
        /// <returns>The first able Pokemon, or null if none are able.</returns>
        IPokemon getFirstAblePokemon();

        /// <summary>
        /// Switches the positions of two Pokemon in the party.
        /// </summary>
        /// <param name="index1">The index of the first Pokemon.</param>
        /// <param name="index2">The index of the second Pokemon.</param>
        /// <returns>True if the switch was successful, false otherwise.</returns>
        bool switchPokemon(int index1, int index2);
    }

    /// <summary>
    /// Interface for party screen annotations that provide additional Pokemon information.
    /// </summary>
    public interface IPartyAnnotations
    {
        /// <summary>
        /// Gets annotation text for a Pokemon based on the annotation mode.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get annotations for.</param>
        /// <param name="annotationMode">The type of annotation to generate.</param>
        /// <returns>The annotation text for the Pokemon.</returns>
        string getAnnotationText(IPokemon pokemon, string annotationMode);

        /// <summary>
        /// Checks if a Pokemon should be highlighted based on annotation criteria.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check.</param>
        /// <param name="annotationMode">The annotation mode to check against.</param>
        /// <returns>True if the Pokemon should be highlighted, false otherwise.</returns>
        bool shouldHighlightPokemon(IPokemon pokemon, string annotationMode);

        /// <summary>
        /// Gets the color to use for highlighting a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get the highlight color for.</param>
        /// <param name="annotationMode">The annotation mode being used.</param>
        /// <returns>The color to use for highlighting.</returns>
        IColor getHighlightColor(IPokemon pokemon, string annotationMode);
    }
}