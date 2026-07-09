using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Base interface for all Pokemon Essentials UI scenes.
    /// Provides common functionality for managing UI scenes and their lifecycle.
    /// </summary>
    public interface IUIScene : IHaveUpdate
    {
        /// <summary>
        /// Starts the scene and initializes all UI elements.
        /// </summary>
        void StartScene();

        /// <summary>
        /// Ends the scene and cleans up resources.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Updates the scene's graphics and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Displays a message to the user.
        /// </summary>
        /// <param name="text">The message text to display.</param>
        void Display(string text);

        /// <summary>
        /// Shows a confirmation dialog to the user.
        /// </summary>
        /// <param name="text">The confirmation message.</param>
        /// <returns>True if user confirmed, false otherwise.</returns>
        bool Confirm(string text);
    }

    /// <summary>
    /// Base interface for UI screens that manage scenes and handle user interaction.
    /// </summary>
    public interface IUIScreen : IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Starts the screen with its associated scene.
        /// </summary>
        void StartScreen();

        /// <summary>
        /// Updates the screen state.
        /// </summary>
        void Update();

        /// <summary>
        /// Refreshes the screen display.
        /// </summary>
        void Refresh();
    }

    /// <summary>
    /// Interface for menu-based UI scenes that handle command selection.
    /// </summary>
    public interface IMenuScene : IUIScene
    {
        /// <summary>
        /// Shows information text in the info window.
        /// </summary>
        /// <param name="text">The information text to display.</param>
        void ShowInfo(string text);

        /// <summary>
        /// Shows help text in the help window.
        /// </summary>
        /// <param name="text">The help text to display.</param>
        void ShowHelp(string text);

        /// <summary>
        /// Shows the menu UI elements.
        /// </summary>
        void ShowMenu();

        /// <summary>
        /// Hides the menu UI elements.
        /// </summary>
        void HideMenu();

        /// <summary>
        /// Displays a list of commands and returns the selected index.
        /// </summary>
        /// <param name="commands">The list of command options.</param>
        /// <returns>The index of the selected command, or -1 if cancelled.</returns>
        int ShowCommands(IList<string> commands);
    }

    /// <summary>
    /// Interface for Pokemon-related UI scenes that display Pokemon information.
    /// </summary>
    public interface IPokemonUIScene : IUIScene
    {
        /// <summary>
        /// Sets the Pokemon to display in the UI.
        /// </summary>
        /// <param name="pokemon">The Pokemon to display.</param>
        void setPokemon(object pokemon);

        /// <summary>
        /// Gets the currently displayed Pokemon.
        /// </summary>
        /// <returns>The Pokemon currently being displayed.</returns>
        object getPokemon();

        /// <summary>
        /// Refreshes the Pokemon display with updated information.
        /// </summary>
        void refreshPokemon();
    }

    /// <summary>
    /// Interface for list-based UI scenes that allow selection from multiple items.
    /// </summary>
    public interface IListUIScene : IUIScene
    {
        /// <summary>
        /// Gets the currently selected index.
        /// </summary>
        /// <returns>The index of the currently selected item.</returns>
        int getSelectedIndex();

        /// <summary>
        /// Sets the selected index.
        /// </summary>
        /// <param name="index">The index to select.</param>
        void setSelectedIndex(int index);

        /// <summary>
        /// Gets the total number of items in the list.
        /// </summary>
        /// <returns>The total number of items.</returns>
        int getItemCount();

        /// <summary>
        /// Refreshes the list display.
        /// </summary>
        void refreshList();
    }

    /// <summary>
    /// Interface for animated UI scenes that handle sprite animations and effects.
    /// </summary>
    public interface IAnimatedUIScene : IUIScene
    {
        /// <summary>
        /// Starts an animation sequence.
        /// </summary>
        /// <param name="animationType">The type of animation to start.</param>
        void startAnimation(string animationType);

        /// <summary>
        /// Stops the current animation.
        /// </summary>
        void stopAnimation();

        /// <summary>
        /// Checks if an animation is currently playing.
        /// </summary>
        /// <returns>True if an animation is playing, false otherwise.</returns>
        bool isAnimationPlaying();
    }

    /// <summary>
    /// Interface for input-handling UI scenes that process user input.
    /// </summary>
    public interface IInputUIScene : IUIScene
    {
        /// <summary>
        /// Processes user input and updates the scene accordingly.
        /// </summary>
        /// <returns>True if input was processed, false otherwise.</returns>
        bool processInput();

        /// <summary>
        /// Handles directional input (arrow keys, D-pad).
        /// </summary>
        /// <param name="direction">The direction of input.</param>
        void handleDirectionalInput(int direction);

        /// <summary>
        /// Handles action input (confirm, cancel buttons).
        /// </summary>
        /// <param name="action">The action type.</param>
        /// <returns>True if the action was handled, false otherwise.</returns>
        bool handleActionInput(string action);
    }

    /// <summary>
    /// Interface for storage-related UI scenes that manage Pokemon and item storage.
    /// </summary>
    public interface IStorageUIScene : IUIScene
    {
        /// <summary>
        /// Gets the currently selected box index.
        /// </summary>
        /// <returns>The selected box index.</returns>
        int getSelectedBox();

        /// <summary>
        /// Sets the selected box index.
        /// </summary>
        /// <param name="boxIndex">The box index to select.</param>
        void setSelectedBox(int boxIndex);

        /// <summary>
        /// Gets the currently selected slot position.
        /// </summary>
        /// <returns>The selected slot position.</returns>
        //(int x, int y) getSelectedPosition();
        IPoint getSelectedPosition();

        /// <summary>
        /// Sets the selected slot position.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        void setSelectedPosition(int x, int y);

        /// <summary>
        /// Refreshes the storage display.
        /// </summary>
        void refreshStorage();
    }

    /// <summary>
    /// Interface for text entry UI scenes that handle user text input.
    /// </summary>
    public interface ITextEntryUIScene : IUIScene
    {
        /// <summary>
        /// Gets the current text input.
        /// </summary>
        /// <returns>The current text string.</returns>
        string getCurrentText();

        /// <summary>
        /// Sets the text input.
        /// </summary>
        /// <param name="text">The text to set.</param>
        void setText(string text);

        /// <summary>
        /// Gets the maximum allowed text length.
        /// </summary>
        /// <returns>The maximum text length.</returns>
        int getMaxLength();

        /// <summary>
        /// Processes character input.
        /// </summary>
        /// <param name="character">The character to input.</param>
        /// <returns>True if the character was accepted, false otherwise.</returns>
        bool inputCharacter(char character);

        /// <summary>
        /// Deletes the last character.
        /// </summary>
        /// <returns>True if a character was deleted, false otherwise.</returns>
        bool deleteCharacter();
    }
}