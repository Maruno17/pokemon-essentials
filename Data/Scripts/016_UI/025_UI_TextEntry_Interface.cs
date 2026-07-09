using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the text entry scene that manages user text input functionality.
    /// Handles character input, text editing, and input validation for various text entry needs.
    /// </summary>
    public interface IPokemonTextEntry_Scene : ITextEntryUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the text entry scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the text entry scene with specified parameters and constraints.
        /// Initializes keyboard interface, text display, and input validation.
        /// </summary>
        /// <param name="helptext">Help text to display for guidance.</param>
        /// <param name="minlength">Minimum required length of text input.</param>
        /// <param name="maxlength">Maximum allowed length of text input.</param>
        /// <param name="initialText">Initial text to pre-populate in the input field.</param>
        /// <param name="subject">Subject context for text entry (e.g., Pokemon, trainer).</param>
        /// <param name="pokemon">Pokemon object if text entry is Pokemon-related.</param>
        void StartScene(string helptext, int minlength, int maxlength, string initialText = "", object subject = null, object pokemon = null);

        /// <summary>
        /// Handles the main scene interaction loop for text input.
        /// Processes character input, editing commands, and text submission.
        /// </summary>
        /// <returns>Final entered text string, or null if cancelled.</returns>
        string Scene();

        /// <summary>
        /// Ends the text entry scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the text entry display with current input and cursor state.
        /// Updates text field, keyboard layout, and interface elements.
        /// </summary>
        void RefreshText();

        /// <summary>
        /// Updates the help information display for text entry guidance.
        /// Shows instructions, constraints, and current input status.
        /// </summary>
        void UpdateHelpInfo();

        /// <summary>
        /// Handles navigation between keyboard characters and input controls.
        /// Updates selection cursor on the virtual keyboard interface.
        /// </summary>
        /// <param name="direction">Direction of navigation input.</param>
        void NavigateKeyboard(int direction);

        /// <summary>
        /// Processes character input from the virtual keyboard.
        /// Adds selected character to the current text input if valid.
        /// </summary>
        /// <param name="character">Character selected from the keyboard.</param>
        /// <returns>True if character was successfully added to input.</returns>
        bool InputCharacter(char character);

        /// <summary>
        /// Deletes the last character from the current text input.
        /// Handles backspace functionality for text editing.
        /// </summary>
        /// <returns>True if a character was successfully deleted.</returns>
        bool DeleteCharacter();

        /// <summary>
        /// Moves the text cursor position within the input field.
        /// Handles cursor positioning for text editing and insertion.
        /// </summary>
        /// <param name="direction">Direction to move cursor (left/right).</param>
        void MoveCursor(int direction);

        /// <summary>
        /// Validates the current text input against specified constraints.
        /// Checks length requirements, character restrictions, and content rules.
        /// </summary>
        /// <returns>True if current text input is valid for submission.</returns>
        bool ValidateInput();

        /// <summary>
        /// Toggles between different input modes (uppercase, lowercase, symbols).
        /// Changes the virtual keyboard layout and input character set.
        /// </summary>
        void ToggleInputMode();

        /// <summary>
        /// Clears all text from the input field.
        /// Resets text input to empty state with confirmation if needed.
        /// </summary>
        void ClearText();

        /// <summary>
        /// Handles special text entry features like word suggestions or auto-complete.
        /// Provides enhanced input functionality for specific contexts.
        /// </summary>
        void SpecialInputFeatures();

        /// <summary>
        /// Formats the final text input according to specified requirements.
        /// Applies formatting rules, capitalization, or other text processing.
        /// </summary>
        /// <param name="text">Raw text input to format.</param>
        /// <returns>Formatted text ready for submission.</returns>
        string formatFinalText(string text);

        /// <summary>
        /// Validates individual characters for input acceptance.
        /// Checks if specific characters are allowed in the current context.
        /// </summary>
        /// <param name="character">Character to validate for input.</param>
        /// <returns>True if character is allowed in current input context.</returns>
        bool ValidateCharacter(char character);

        /// <summary>
        /// Updates the character count display showing current and maximum length.
        /// Refreshes length indicators and constraint status.
        /// </summary>
        void UpdateCharacterCount();

        /// <summary>
        /// Handles clipboard operations for text input (if supported).
        /// Provides copy, cut, and paste functionality for text editing.
        /// </summary>
        /// <param name="operation">Type of clipboard operation to perform.</param>
        void ClipboardOperation(string operation);
    }

    /// <summary>
    /// Interface for the text entry screen that orchestrates user text input functionality.
    /// Coordinates between scenes and manages overall text input experience.
    /// </summary>
    public interface IPokemonTextEntryScreen
    {
        /// <summary>
        /// Initializes the text entry screen with the specified scene.
        /// Sets up the scene instance for managing the text entry interface.
        /// </summary>
        /// <param name="scene">The text entry scene to use.</param>
        IPokemonTextEntryScreen initialize(IPokemonTextEntry_Scene scene);

        /// <summary>
        /// Starts the text entry screen for user input collection.
        /// Displays text entry interface and manages input validation and submission.
        /// </summary>
        /// <param name="helptext">Help text to guide user input.</param>
        /// <param name="minlength">Minimum required text length.</param>
        /// <param name="maxlength">Maximum allowed text length.</param>
        /// <param name="initialText">Initial text to pre-populate.</param>
        /// <param name="subject">Context subject for the text entry.</param>
        /// <param name="pokemon">Pokemon object if applicable to the input.</param>
        /// <returns>Final entered text, or null if cancelled.</returns>
        string StartScreen(string helptext, int minlength, int maxlength, string initialText = "", object subject = null, object pokemon = null);
    }
}