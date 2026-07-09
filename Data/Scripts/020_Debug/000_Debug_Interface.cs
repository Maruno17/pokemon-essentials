using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for debug menu functionality in Pokemon Essentials.
    /// Provides access to debugging tools, editors, and testing utilities.
    /// </summary>
    public interface IDebugMenu
    {
        /// <summary>
        /// Shows the main debug menu with all available options.
        /// </summary>
        /// <returns>The selected debug option, or -1 if cancelled.</returns>
        int showDebugMenu();

        /// <summary>
        /// Checks if debug mode is currently enabled.
        /// </summary>
        /// <returns>True if debug mode is enabled, false otherwise.</returns>
        bool isDebugMode();

        /// <summary>
        /// Enables or disables debug mode.
        /// </summary>
        /// <param name="enabled">Whether to enable debug mode.</param>
        void setDebugMode(bool enabled);

        /// <summary>
        /// Executes a debug command.
        /// </summary>
        /// <param name="command">The debug command to execute.</param>
        /// <param name="parameters">Optional parameters for the command.</param>
        /// <returns>The result of the command execution.</returns>
        object executeDebugCommand(string command, params object[] parameters);

        /// <summary>
        /// Logs a debug message.
        /// </summary>
        /// <param name="message">The message to log.</param>
        /// <param name="level">The log level (info, warning, error).</param>
        void logDebugMessage(string message, string level = "info");

        /// <summary>
        /// Gets all available debug commands.
        /// </summary>
        /// <returns>List of debug command names.</returns>
        IList<string> getAvailableCommands();
    }

    /// <summary>
    /// Interface for Pokemon-related debug commands and utilities.
    /// </summary>
    public interface IPokemonDebugCommands
    {
        /// <summary>
        /// Gives a Pokemon to the player's party.
        /// </summary>
        /// <param name="species">The species of Pokemon to give.</param>
        /// <param name="level">The level of the Pokemon.</param>
        /// <param name="form">The form of the Pokemon (optional).</param>
        /// <returns>The created Pokemon.</returns>
        object givePokemon(string species, int level, int form = 0);

        /// <summary>
        /// Sets the level of a Pokemon in the party.
        /// </summary>
        /// <param name="partyIndex">The index of the Pokemon in the party.</param>
        /// <param name="level">The new level.</param>
        void setPokemonLevel(int partyIndex, int level);

        /// <summary>
        /// Sets the stats of a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to modify.</param>
        /// <param name="stats">Dictionary of stat names to values.</param>
        void setPokemonStats(object pokemon, IDictionary<string, int> stats);

        /// <summary>
        /// Makes a Pokemon shiny or not shiny.
        /// </summary>
        /// <param name="pokemon">The Pokemon to modify.</param>
        /// <param name="shiny">Whether the Pokemon should be shiny.</param>
        void setPokemonShiny(object pokemon, bool shiny);

        /// <summary>
        /// Heals all Pokemon in the party.
        /// </summary>
        void healParty();

        /// <summary>
        /// Fills the party with Pokemon of a specific level.
        /// </summary>
        /// <param name="level">The level for all Pokemon.</param>
        void fillParty(int level = 50);

        /// <summary>
        /// Clears all Pokemon from the party.
        /// </summary>
        void clearParty();

        /// <summary>
        /// Sets the nature of a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to modify.</param>
        /// <param name="nature">The nature to set.</param>
        void setPokemonNature(object pokemon, string nature);

        /// <summary>
        /// Sets the ability of a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to modify.</param>
        /// <param name="ability">The ability to set.</param>
        void setPokemonAbility(object pokemon, string ability);

        /// <summary>
        /// Teaches a move to a Pokemon.
        /// </summary>
        /// <param name="pokemon">The Pokemon to teach the move to.</param>
        /// <param name="move">The move to teach.</param>
        void teachMove(object pokemon, string move);
    }

    /// <summary>
    /// Interface for battle-related debug commands.
    /// </summary>
    public interface IBattleDebugCommands
    {
        /// <summary>
        /// Starts a debug battle with specific parameters.
        /// </summary>
        /// <param name="trainerType">The type of trainer to battle.</param>
        /// <param name="trainerId">The ID of the trainer.</param>
        /// <param name="canLose">Whether the player can lose this battle.</param>
        void startDebugBattle(string trainerType, string trainerId, bool canLose = true);

        /// <summary>
        /// Starts a wild Pokemon battle.
        /// </summary>
        /// <param name="species">The species of wild Pokemon.</param>
        /// <param name="level">The level of the wild Pokemon.</param>
        void startWildBattle(string species, int level);

        /// <summary>
        /// Forces the current battle to end with a specific result.
        /// </summary>
        /// <param name="result">The battle result (win, lose, draw).</param>
        void forceBattleEnd(string result);

        /// <summary>
        /// Sets the HP of a battler during battle.
        /// </summary>
        /// <param name="battlerIndex">The index of the battler.</param>
        /// <param name="hp">The HP value to set.</param>
        void setBattlerHP(int battlerIndex, int hp);

        /// <summary>
        /// Inflicts a status condition on a battler.
        /// </summary>
        /// <param name="battlerIndex">The index of the battler.</param>
        /// <param name="status">The status condition to inflict.</param>
        void inflictStatus(int battlerIndex, string status);

        /// <summary>
        /// Sets the weather in the current battle.
        /// </summary>
        /// <param name="weather">The weather condition to set.</param>
        /// <param name="duration">The duration of the weather.</param>
        void setBattleWeather(string weather, int duration = -1);

        /// <summary>
        /// Forces a Pokemon to use a specific move.
        /// </summary>
        /// <param name="battlerIndex">The index of the battler.</param>
        /// <param name="move">The move to use.</param>
        void forceMove(int battlerIndex, string move);
    }

    /// <summary>
    /// Interface for game state debug commands.
    /// </summary>
    public interface IGameStateDebugCommands
    {
        /// <summary>
        /// Sets the value of a game switch.
        /// </summary>
        /// <param name="switchId">The ID of the switch.</param>
        /// <param name="value">The value to set (true/false).</param>
        void setSwitch(int switchId, bool value);

        /// <summary>
        /// Sets the value of a game variable.
        /// </summary>
        /// <param name="variableId">The ID of the variable.</param>
        /// <param name="value">The value to set.</param>
        void setVariable(int variableId, object value);

        /// <summary>
        /// Gives an item to the player.
        /// </summary>
        /// <param name="item">The item to give.</param>
        /// <param name="quantity">The quantity to give.</param>
        void giveItem(string item, int quantity = 1);

        /// <summary>
        /// Gives money to the player.
        /// </summary>
        /// <param name="amount">The amount of money to give.</param>
        void giveMoney(int amount);

        /// <summary>
        /// Sets the player's money to a specific amount.
        /// </summary>
        /// <param name="amount">The amount to set.</param>
        void setMoney(int amount);

        /// <summary>
        /// Toggles noclip mode for the player.
        /// </summary>
        /// <param name="enabled">Whether to enable noclip mode.</param>
        void setNoclip(bool enabled);

        /// <summary>
        /// Teleports the player to a specific map and coordinates.
        /// </summary>
        /// <param name="mapId">The ID of the map to teleport to.</param>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        void teleport(int mapId, int x, int y);

        /// <summary>
        /// Sets the player's name.
        /// </summary>
        /// <param name="name">The new name for the player.</param>
        void setPlayerName(string name);

        /// <summary>
        /// Completes the Pokedex by marking all Pokemon as seen/owned.
        /// </summary>
        /// <param name="owned">Whether to mark Pokemon as owned (true) or just seen (false).</param>
        void completePokedex(bool owned = false);
    }

    /// <summary>
    /// Interface for data editor functionality in debug mode.
    /// </summary>
    public interface IDataEditor
    {
        /// <summary>
        /// Opens the Pokemon species editor.
        /// </summary>
        /// <param name="species">The species to edit (optional).</param>
        void openSpeciesEditor(string species = null);

        /// <summary>
        /// Opens the move editor.
        /// </summary>
        /// <param name="move">The move to edit (optional).</param>
        void openMoveEditor(string move = null);

        /// <summary>
        /// Opens the item editor.
        /// </summary>
        /// <param name="item">The item to edit (optional).</param>
        void openItemEditor(string item = null);

        /// <summary>
        /// Opens the trainer editor.
        /// </summary>
        /// <param name="trainerId">The trainer to edit (optional).</param>
        void openTrainerEditor(string trainerId = null);

        /// <summary>
        /// Opens the map connections editor.
        /// </summary>
        void openMapConnectionsEditor();

        /// <summary>
        /// Opens the terrain tags editor.
        /// </summary>
        void openTerrainTagsEditor();

        /// <summary>
        /// Opens the sprite positioning editor.
        /// </summary>
        void openSpritePositioningEditor();

        /// <summary>
        /// Saves all pending data changes.
        /// </summary>
        void saveAllData();

        /// <summary>
        /// Reloads data from files.
        /// </summary>
        void reloadData();

        /// <summary>
        /// Validates data integrity and reports any errors.
        /// </summary>
        /// <returns>List of validation errors found.</returns>
        IList<string> validateData();
    }

    /// <summary>
    /// Interface for animation editor functionality.
    /// </summary>
    public interface IAnimationEditor
    {
        /// <summary>
        /// Opens the animation editor for a specific animation.
        /// </summary>
        /// <param name="animationId">The ID of the animation to edit.</param>
        void openAnimationEditor(int animationId);

        /// <summary>
        /// Creates a new animation.
        /// </summary>
        /// <returns>The ID of the newly created animation.</returns>
        int createNewAnimation();

        /// <summary>
        /// Deletes an animation.
        /// </summary>
        /// <param name="animationId">The ID of the animation to delete.</param>
        void deleteAnimation(int animationId);

        /// <summary>
        /// Copies an animation.
        /// </summary>
        /// <param name="animationId">The ID of the animation to copy.</param>
        /// <returns>The ID of the copied animation.</returns>
        int copyAnimation(int animationId);

        /// <summary>
        /// Plays an animation for preview.
        /// </summary>
        /// <param name="animationId">The ID of the animation to play.</param>
        void previewAnimation(int animationId);

        /// <summary>
        /// Exports an animation to a file.
        /// </summary>
        /// <param name="animationId">The ID of the animation to export.</param>
        /// <param name="filename">The filename to export to.</param>
        void exportAnimation(int animationId, string filename);

        /// <summary>
        /// Imports an animation from a file.
        /// </summary>
        /// <param name="filename">The filename to import from.</param>
        /// <returns>The ID of the imported animation.</returns>
        int importAnimation(string filename);
    }

    /// <summary>
    /// Interface for debug console functionality.
    /// </summary>
    public interface IDebugConsole
    {
        /// <summary>
        /// Shows the debug console window.
        /// </summary>
        void showConsole();

        /// <summary>
        /// Hides the debug console window.
        /// </summary>
        void hideConsole();

        /// <summary>
        /// Executes a command in the debug console.
        /// </summary>
        /// <param name="command">The command to execute.</param>
        /// <returns>The result of the command execution.</returns>
        object executeConsoleCommand(string command);

        /// <summary>
        /// Prints a message to the debug console.
        /// </summary>
        /// <param name="message">The message to print.</param>
        /// <param name="color">The color to use for the message (optional).</param>
        void printMessage(string message, string color = null);

        /// <summary>
        /// Clears all messages from the debug console.
        /// </summary>
        void clearConsole();

        /// <summary>
        /// Gets the command history from the debug console.
        /// </summary>
        /// <returns>List of previously executed commands.</returns>
        IList<string> getCommandHistory();

        /// <summary>
        /// Saves the console output to a file.
        /// </summary>
        /// <param name="filename">The filename to save to.</param>
        void saveConsoleOutput(string filename);
    }

    /// <summary>
    /// Interface for debug utilities and helper functions.
    /// </summary>
    public interface IDebugUtilities
    {
        /// <summary>
        /// Enables or disables debug features globally.
        /// </summary>
        /// <param name="enabled">Whether to enable debug features.</param>
        void setGlobalDebugMode(bool enabled);

        /// <summary>
        /// Gets performance information about the game.
        /// </summary>
        /// <returns>Dictionary containing performance metrics.</returns>
        IDictionary<string, object> getPerformanceInfo();

        /// <summary>
        /// Takes a screenshot and saves it to a file.
        /// </summary>
        /// <param name="filename">The filename to save the screenshot to (optional).</param>
        /// <returns>The path where the screenshot was saved.</returns>
        string takeScreenshot(string filename = null);

        /// <summary>
        /// Dumps the current game state to a file for debugging.
        /// </summary>
        /// <param name="filename">The filename to save the state dump to.</param>
        void dumpGameState(string filename);

        /// <summary>
        /// Loads a game state from a dump file.
        /// </summary>
        /// <param name="filename">The filename to load the state from.</param>
        void loadGameState(string filename);

        /// <summary>
        /// Validates game data and reports any inconsistencies.
        /// </summary>
        /// <returns>List of validation errors or warnings.</returns>
        IList<string> validateGameData();

        /// <summary>
        /// Forces garbage collection for memory management testing.
        /// </summary>
        void forceGarbageCollection();

        /// <summary>
        /// Gets memory usage information.
        /// </summary>
        /// <returns>Memory usage statistics.</returns>
        object getMemoryUsage();
    }
}