using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Pokemon summary screen scene that displays detailed Pokemon information.
    /// Shows stats, moves, ribbons, and other Pokemon details across multiple pages.
    /// </summary>
    public interface IPokemonSummaryScene : IPokemonUIScene
    {
        /// <summary>
        /// Sets the party and initial Pokemon index for the summary.
        /// </summary>
        /// <param name="party">The party of Pokemon to display.</param>
        /// <param name="partyIndex">The index of the Pokemon to show initially.</param>
        void setPartyIndex(IList<object> party, int partyIndex);

        /// <summary>
        /// Gets the currently displayed page index.
        /// </summary>
        /// <returns>The current page index.</returns>
        int getCurrentPage();

        /// <summary>
        /// Sets the current page to display.
        /// </summary>
        /// <param name="pageIndex">The page index to show.</param>
        void setCurrentPage(int pageIndex);

        /// <summary>
        /// Gets the total number of pages available.
        /// </summary>
        /// <returns>The total number of pages.</returns>
        int getPageCount();

        /// <summary>
        /// Shows the next Pokemon in the party.
        /// </summary>
        /// <returns>True if successfully moved to next Pokemon, false if at end.</returns>
        bool showNextPokemon();

        /// <summary>
        /// Shows the previous Pokemon in the party.
        /// </summary>
        /// <returns>True if successfully moved to previous Pokemon, false if at start.</returns>
        bool showPreviousPokemon();

        /// <summary>
        /// Refreshes the current page display.
        /// </summary>
        void refreshPage();

        /// <summary>
        /// Shows page-specific content (stats, moves, ribbons, etc.).
        /// </summary>
        /// <param name="pageType">The type of page to display.</param>
        void showPageContent(string pageType);

        /// <summary>
        /// Handles move selection on the moves page.
        /// </summary>
        /// <returns>The index of the selected move, or -1 if cancelled.</returns>
        int selectMove();

        /// <summary>
        /// Shows detailed information about a specific move.
        /// </summary>
        /// <param name="moveIndex">The index of the move to show details for.</param>
        void showMoveDetails(int moveIndex);
    }

    /// <summary>
    /// Interface for the Pokemon summary screen that manages the summary scene.
    /// </summary>
    public interface IPokemonSummaryScreen : IUIScreen
    {
        /// <summary>
        /// Starts the summary screen for a single Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to display summary for.</param>
        /// <param name="partyIndex">The index of the Pokemon in the party.</param>
        /// <returns>The result of the summary screen interaction.</returns>
        int StartScreen(object pokemon, int partyIndex = 0);

        /// <summary>
        /// Starts the summary screen with a party of Pokemon.
        /// </summary>
        /// <param name="party">The party of Pokemon.</param>
        /// <param name="partyIndex">The index of the Pokemon to show initially.</param>
        /// <returns>The result of the summary screen interaction.</returns>
        int StartScreen(IList<object> party, int partyIndex);

        /// <summary>
        /// Shows the summary screen in move selection mode.
        /// </summary>
        /// <param name="pokemon">The Pokemon to show summary for.</param>
        /// <param name="moveToLearn">The move being learned (if any).</param>
        /// <returns>The index of the selected move, or -1 if cancelled.</returns>
        int StartForgetScreen(object pokemon, object moveToLearn = null);
    }

    /// <summary>
    /// Interface for summary screen utilities and helper functions.
    /// </summary>
    public interface ISummaryUtilities
    {
        /// <summary>
        /// Opens the Pokemon summary screen.
        /// </summary>
        /// <param name="pokemon">The Pokemon to show summary for.</param>
        /// <param name="partyIndex">The index in the party (optional).</param>
        /// <returns>The result of showing the summary.</returns>
        int ShowPokemonSummary(object pokemon, int partyIndex = 0);

        /// <summary>
        /// Shows the summary screen for choosing which move to forget.
        /// </summary>
        /// <param name="pokemon">The Pokemon learning a new move.</param>
        /// <param name="newMove">The new move being learned.</param>
        /// <returns>The index of the move to forget, or -1 if cancelled.</returns>
        int ForgetMove(object pokemon, object newMove);

        /// <summary>
        /// Gets formatted text for displaying Pokemon stats.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get stat text for.</param>
        /// <returns>Formatted stat information.</returns>
        string getStatText(object pokemon);

        /// <summary>
        /// Gets formatted text for displaying Pokemon moves.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get move text for.</param>
        /// <returns>Formatted move information.</returns>
        IList<string> getMoveText(object pokemon);

        /// <summary>
        /// Gets the color to use for a stat value based on nature effects.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check.</param>
        /// <param name="statId">The stat to get the color for.</param>
        /// <returns>The color to use for the stat display.</returns>
        IColor getStatColor(object pokemon, string statId);
    }

    /// <summary>
    /// Interface for summary page management and content display.
    /// </summary>
    public interface ISummaryPageManager
    {
        /// <summary>
        /// Gets the names of all available summary pages.
        /// </summary>
        /// <returns>List of page names.</returns>
        IList<string> getPageNames();

        /// <summary>
        /// Checks if a specific page is available for the given Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to check.</param>
        /// <param name="pageType">The page type to check.</param>
        /// <returns>True if the page is available, false otherwise.</returns>
        bool isPageAvailable(object pokemon, string pageType);

        /// <summary>
        /// Gets the content data for a specific page.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get page content for.</param>
        /// <param name="pageType">The type of page to get content for.</param>
        /// <returns>The page content data.</returns>
        object getPageContent(object pokemon, string pageType);

        /// <summary>
        /// Updates the content of a specific page.
        /// </summary>
        /// <param name="pokemon">The Pokemon the page is for.</param>
        /// <param name="pageType">The type of page to update.</param>
        void updatePageContent(object pokemon, string pageType);
    }

    /// <summary>
    /// Interface for ribbon and achievement display in the summary screen.
    /// </summary>
    public interface IRibbonDisplay
    {
        /// <summary>
        /// Gets the ribbons owned by a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to get ribbons for.</param>
        /// <returns>List of ribbon data.</returns>
        IList<object> getPokemonRibbons(object pokemon);

        /// <summary>
        /// Shows detailed information about a specific ribbon.
        /// </summary>
        /// <param name="ribbon">The ribbon to show details for.</param>
        void showRibbonDetails(object ribbon);

        /// <summary>
        /// Gets the display position for a ribbon in the grid.
        /// </summary>
        /// <param name="ribbonIndex">The index of the ribbon.</param>
        /// <returns>The display position coordinates.</returns>
        //(int x, int y) getRibbonPosition(int ribbonIndex);
        IPoint getRibbonPosition(int ribbonIndex);
    }
}