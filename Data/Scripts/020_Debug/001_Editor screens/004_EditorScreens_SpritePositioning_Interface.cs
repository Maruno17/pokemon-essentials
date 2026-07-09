using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Utility function for finding the bottom pixel of a sprite bitmap.
    /// Used in automatic sprite positioning to determine ground level.
    /// </summary>
    public interface IMainSpritePositioningUtilities : IMain
    {
        /// <summary>
        /// Finds the bottom-most pixel with alpha transparency in a bitmap.
        /// Used to determine where a Pokémon sprite's feet should be positioned.
        /// </summary>
        /// <param name="bitmap">The bitmap to analyze.</param>
        /// <returns>The Y coordinate of the bottom-most visible pixel.</returns>
        int findBottom(object bitmap);

        /// <summary>
        /// Automatically positions all Pokémon sprites based on their bottom pixels.
        /// Calculates optimal positioning for both player and enemy battle sprites.
        /// </summary>
        void AutoPositionAll();
    }

    /// <summary>
    /// Provides an interactive interface for positioning Pokémon battle sprites.
    /// Allows developers to fine-tune sprite positions, shadow settings, and preview changes in battle context.
    /// </summary>
    //public interface ISpritePositioner : IScene
    public interface ISpritePositionerScene : IScene, IHaveUpdate, IHaveRefresh
    {
        /// <summary>
        /// Opens the sprite positioning interface and initializes all visual elements.
        /// Sets up battle background, sprite displays, and positioning controls.
        /// </summary>
        void Open();

        /// <summary>
        /// Closes the sprite positioning interface and handles saving changes.
        /// Prompts user to save metrics changes before exiting.
        /// </summary>
        void Close();

        /// <summary>
        /// Saves all sprite positioning metrics to file.
        /// Writes the current positioning data to the game data files.
        /// </summary>
        void SaveMetrics();

        /// <summary>
        /// Updates all sprites and interface elements.
        /// Called every frame to maintain visual consistency.
        /// </summary>
        void update();

        /// <summary>
        /// Refreshes the sprite display with current positioning data.
        /// Updates sprite positions based on current metrics and species selection.
        /// </summary>
        void refresh();

        /// <summary>
        /// Automatically calculates optimal sprite positions based on sprite content.
        /// Analyzes sprite pixels to determine appropriate ground positioning.
        /// </summary>
        void AutoPosition();

        /// <summary>
        /// Changes the currently displayed Pokémon species and form.
        /// Updates all sprites to show the specified species for positioning.
        /// </summary>
        /// <param name="species">The species to display.</param>
        /// <param name="form">The form of the species to display.</param>
        void ChangeSpecies(object species, int form);

        /// <summary>
        /// Opens the shadow size selection interface.
        /// Allows selection of appropriate shadow sprite for the current species.
        /// </summary>
        /// <returns>True if the shadow size was changed, false otherwise.</returns>
        bool ShadowSize();

        /// <summary>
        /// Sets up interactive positioning for a specific parameter.
        /// Allows real-time adjustment of sprite positions using keyboard input.
        /// </summary>
        /// <param name="param">The parameter to adjust (0=ally position, 1=enemy position, 2=shadow size, 3=shadow position, 4=auto-position).</param>
        /// <returns>True if moving to next parameter, false if done.</returns>
        bool SetParameter(int param);

        /// <summary>
        /// Displays the main parameter selection menu.
        /// Shows options for different positioning parameters that can be adjusted.
        /// </summary>
        /// <returns>The selected parameter index, or -1 if cancelled.</returns>
        int Menu();

        /// <summary>
        /// Displays the species selection interface.
        /// Allows choosing which Pokémon species to position.
        /// </summary>
        /// <returns>True if a species was selected, false if cancelled.</returns>
        bool ChooseSpecies();
    }

    /// <summary>
    /// Provides the main screen interface for sprite positioning.
    /// Coordinates the overall sprite positioning workflow and user interaction.
    /// </summary>
    public interface ISpritePositionerScreen : IScreen
    {
        /// <summary>
        /// Initializes the sprite positioner screen with the specified scene.
        /// </summary>
        /// <param name="scene">The sprite positioner scene to use.</param>
        ISpritePositionerScreen initialize(ISpritePositionerScene scene);

        /// <summary>
        /// Starts the sprite positioning interface.
        /// Manages the complete workflow of species selection and parameter adjustment.
        /// </summary>
        void Start();
    }
}