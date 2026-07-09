using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Defines the interface for interpreter commands that handle event processing in the game.
    /// This interface contains methods for executing various event commands and managing their state.
    /// </summary>
    public interface IInterpreterCommands
    {
        /// <summary>
        /// Executes the current command in the event list.
        /// </summary>
        /// <returns>True if the command was executed successfully, false otherwise.</returns>
        bool execute_command();

        /// <summary>
        /// Executes a dummy command that does nothing.
        /// </summary>
        /// <returns>Always returns true.</returns>
        bool command_dummy();

        /// <summary>
        /// Ends the current event processing.
        /// </summary>
        void command_end();

        /// <summary>
        /// Skips to the next command at the same indentation level.
        /// </summary>
        /// <returns>True if the skip was successful.</returns>
        bool command_skip();

        /// <summary>
        /// Executes a conditional branch command.
        /// </summary>
        /// <param name="value">The value to check against.</param>
        /// <returns>True if the condition was met, false otherwise.</returns>
        bool command_if(int value);

        #region Text and Choice Commands

        /// <summary>
        /// Shows text in a message window.
        /// </summary>
        /// <returns>True if the text was displayed successfully.</returns>
        bool command_101();

        /// <summary>
        /// Shows a list of choices to the player.
        /// </summary>
        /// <returns>True if the choices were displayed successfully.</returns>
        bool command_102();

        /// <summary>
        /// Processes a "When" branch in a choice command.
        /// </summary>
        /// <returns>True if the branch was processed successfully.</returns>
        bool command_402();

        /// <summary>
        /// Processes a "When Cancel" branch in a choice command.
        /// </summary>
        /// <returns>True if the branch was processed successfully.</returns>
        bool command_403();

        /// <summary>
        /// Processes number input from the player.
        /// </summary>
        /// <returns>True if the input was processed successfully.</returns>
        bool command_103();

        /// <summary>
        /// Changes text display options.
        /// </summary>
        /// <returns>True if the options were changed successfully.</returns>
        bool command_104();

        /// <summary>
        /// Processes button input from the player.
        /// </summary>
        /// <returns>True if the input was processed successfully.</returns>
        bool command_105();

        /// <summary>
        /// Waits for a specified number of frames.
        /// </summary>
        /// <returns>True if the wait was successful.</returns>
        bool command_106();

        #endregion

        #region Control Flow Commands

        /// <summary>
        /// Executes a conditional branch.
        /// </summary>
        /// <returns>True if the branch was executed successfully.</returns>
        bool command_111();

        /// <summary>
        /// Executes an "Else" branch.
        /// </summary>
        /// <returns>True if the branch was executed successfully.</returns>
        bool command_411();

        /// <summary>
        /// Starts a loop.
        /// </summary>
        /// <returns>True if the loop was started successfully.</returns>
        bool command_112();

        /// <summary>
        /// Repeats the commands above the current index.
        /// </summary>
        /// <returns>True if the repeat was successful.</returns>
        bool command_413();

        /// <summary>
        /// Breaks out of a loop.
        /// </summary>
        /// <returns>True if the break was successful.</returns>
        bool command_113();

        /// <summary>
        /// Exits event processing.
        /// </summary>
        /// <returns>True if the exit was successful.</returns>
        bool command_115();

        /// <summary>
        /// Erases the current event.
        /// </summary>
        /// <returns>True if the event was erased successfully.</returns>
        bool command_116();

        /// <summary>
        /// Calls a common event.
        /// </summary>
        /// <returns>True if the common event was called successfully.</returns>
        bool command_117();

        /// <summary>
        /// Defines a label in the event.
        /// </summary>
        /// <returns>True if the label was defined successfully.</returns>
        bool command_118();

        /// <summary>
        /// Jumps to a label in the event.
        /// </summary>
        /// <returns>True if the jump was successful.</returns>
        bool command_119();

        #endregion

        #region Game State Commands

        /// <summary>
        /// Controls game switches.
        /// </summary>
        /// <returns>True if the switches were controlled successfully.</returns>
        bool command_121();

        /// <summary>
        /// Controls game variables.
        /// </summary>
        /// <returns>True if the variables were controlled successfully.</returns>
        bool command_122();

        /// <summary>
        /// Controls self switches.
        /// </summary>
        /// <returns>True if the self switches were controlled successfully.</returns>
        bool command_123();

        /// <summary>
        /// Controls the game timer.
        /// </summary>
        /// <returns>True if the timer was controlled successfully.</returns>
        bool command_124();

        /// <summary>
        /// Changes the player's money.
        /// </summary>
        /// <returns>True if the money was changed successfully.</returns>
        bool command_125();

        #endregion

        #region Map and Character Commands

        /// <summary>
        /// Transfers the player to a new location.
        /// </summary>
        /// <returns>True if the transfer was successful.</returns>
        bool command_201();

        /// <summary>
        /// Sets an event's location.
        /// </summary>
        /// <returns>True if the location was set successfully.</returns>
        bool command_202();

        /// <summary>
        /// Scrolls the map.
        /// </summary>
        /// <returns>True if the scroll was successful.</returns>
        bool command_203();

        /// <summary>
        /// Changes map settings.
        /// </summary>
        /// <returns>True if the settings were changed successfully.</returns>
        bool command_204();

        /// <summary>
        /// Changes fog color tone.
        /// </summary>
        /// <returns>True if the fog color was changed successfully.</returns>
        bool command_205();

        /// <summary>
        /// Changes fog opacity.
        /// </summary>
        /// <returns>True if the fog opacity was changed successfully.</returns>
        bool command_206();

        /// <summary>
        /// Shows an animation.
        /// </summary>
        /// <returns>True if the animation was shown successfully.</returns>
        bool command_207();

        /// <summary>
        /// Changes the transparent flag.
        /// </summary>
        /// <returns>True if the flag was changed successfully.</returns>
        bool command_208();

        /// <summary>
        /// Sets a move route.
        /// </summary>
        /// <returns>True if the move route was set successfully.</returns>
        bool command_209();

        /// <summary>
        /// Waits for a move route to complete.
        /// </summary>
        /// <returns>True if the wait was successful.</returns>
        bool command_210();

        #endregion

        #region Screen Effects Commands

        /// <summary>
        /// Prepares for a screen transition.
        /// </summary>
        /// <returns>True if the preparation was successful.</returns>
        bool command_221();

        /// <summary>
        /// Executes a screen transition.
        /// </summary>
        /// <returns>True if the transition was successful.</returns>
        bool command_222();

        /// <summary>
        /// Changes the screen color tone.
        /// </summary>
        /// <returns>True if the color tone was changed successfully.</returns>
        bool command_223();

        /// <summary>
        /// Flashes the screen.
        /// </summary>
        /// <returns>True if the flash was successful.</returns>
        bool command_224();

        /// <summary>
        /// Shakes the screen.
        /// </summary>
        /// <returns>True if the shake was successful.</returns>
        bool command_225();

        #endregion

        #region Picture Commands

        /// <summary>
        /// Shows a picture.
        /// </summary>
        /// <returns>True if the picture was shown successfully.</returns>
        bool command_231();

        /// <summary>
        /// Moves a picture.
        /// </summary>
        /// <returns>True if the picture was moved successfully.</returns>
        bool command_232();

        /// <summary>
        /// Rotates a picture.
        /// </summary>
        /// <returns>True if the picture was rotated successfully.</returns>
        bool command_233();

        /// <summary>
        /// Changes a picture's color tone.
        /// </summary>
        /// <returns>True if the color tone was changed successfully.</returns>
        bool command_234();

        /// <summary>
        /// Erases a picture.
        /// </summary>
        /// <returns>True if the picture was erased successfully.</returns>
        bool command_235();

        /// <summary>
        /// Sets weather effects.
        /// </summary>
        /// <returns>True if the weather effects were set successfully.</returns>
        bool command_236();

        #endregion

        #region Audio Commands

        /// <summary>
        /// Plays background music.
        /// </summary>
        /// <returns>True if the music was played successfully.</returns>
        bool command_241();

        /// <summary>
        /// Fades out background music.
        /// </summary>
        /// <returns>True if the fade was successful.</returns>
        bool command_242();

        /// <summary>
        /// Plays background sound.
        /// </summary>
        /// <returns>True if the sound was played successfully.</returns>
        bool command_245();

        /// <summary>
        /// Fades out background sound.
        /// </summary>
        /// <returns>True if the fade was successful.</returns>
        bool command_246();

        /// <summary>
        /// Memorizes current BGM/BGS.
        /// </summary>
        /// <returns>True if the memorization was successful.</returns>
        bool command_247();

        /// <summary>
        /// Restores memorized BGM/BGS.
        /// </summary>
        /// <returns>True if the restoration was successful.</returns>
        bool command_248();

        /// <summary>
        /// Plays a music effect.
        /// </summary>
        /// <returns>True if the effect was played successfully.</returns>
        bool command_249();

        /// <summary>
        /// Plays a sound effect.
        /// </summary>
        /// <returns>True if the effect was played successfully.</returns>
        bool command_250();

        /// <summary>
        /// Stops all sound effects.
        /// </summary>
        /// <returns>True if the sounds were stopped successfully.</returns>
        bool command_251();

        #endregion

        #region Battle Commands

        /// <summary>
        /// Processes a battle.
        /// </summary>
        /// <returns>True if the battle was processed successfully.</returns>
        bool command_301();

        /// <summary>
        /// Processes a battle win condition.
        /// </summary>
        /// <returns>True if the condition was processed successfully.</returns>
        bool command_601();

        /// <summary>
        /// Processes a battle escape condition.
        /// </summary>
        /// <returns>True if the condition was processed successfully.</returns>
        bool command_602();

        /// <summary>
        /// Processes a battle loss condition.
        /// </summary>
        /// <returns>True if the condition was processed successfully.</returns>
        bool command_603();

        #endregion

        #region System Commands

        /// <summary>
        /// Processes a shop.
        /// </summary>
        /// <returns>True if the shop was processed successfully.</returns>
        bool command_302();

        /// <summary>
        /// Processes name input.
        /// </summary>
        /// <returns>True if the input was processed successfully.</returns>
        bool command_303();

        /// <summary>
        /// Calls the menu screen.
        /// </summary>
        /// <returns>True if the menu was called successfully.</returns>
        bool command_351();

        /// <summary>
        /// Calls the save screen.
        /// </summary>
        /// <returns>True if the save screen was called successfully.</returns>
        bool command_352();

        /// <summary>
        /// Triggers game over.
        /// </summary>
        /// <returns>True if the game over was triggered successfully.</returns>
        bool command_353();

        /// <summary>
        /// Returns to the title screen.
        /// </summary>
        /// <returns>True if the return was successful.</returns>
        bool command_354();

        /// <summary>
        /// Executes a script.
        /// </summary>
        /// <returns>True if the script was executed successfully.</returns>
        bool command_355();

        #endregion
    }
}