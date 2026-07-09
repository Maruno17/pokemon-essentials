using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the phone contact list scene that manages trainer contacts.
    /// Displays registered trainers, handles contact selection, and manages call functionality.
    /// </summary>
    public interface IPokemonPhone_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the phone scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the phone scene with available trainer contacts.
        /// Initializes contact list, background, and phone interface elements.
        /// </summary>
        /// <param name="contacts">List of registered trainer contacts available for calling.</param>
        void StartScene(IList<object> contacts);

        /// <summary>
        /// Handles the main scene interaction loop for contact selection.
        /// Processes navigation through contacts and handles call initiation.
        /// </summary>
        /// <returns>Index of selected contact, or -1 if cancelled.</returns>
        int Scene();

        /// <summary>
        /// Ends the phone scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the contact list display with current information.
        /// Updates contact availability, names, and status indicators.
        /// </summary>
        void RefreshContactList();

        /// <summary>
        /// Updates the information display for the currently selected contact.
        /// Shows trainer details, availability status, and call history.
        /// </summary>
        void UpdateContactInfo();

        /// <summary>
        /// Handles navigation between contacts in the phone list.
        /// Updates selection and refreshes contact information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateContacts(int direction);

        /// <summary>
        /// Initiates a phone call with the selected trainer contact.
        /// Handles call animation, dialogue, and trainer interactions.
        /// </summary>
        /// <param name="contact_index">Index of the contact to call.</param>
        void MakeCall(int contact_index);
    }

    /// <summary>
    /// Interface for the phone screen that orchestrates trainer communication.
    /// Coordinates between scenes and manages overall phone functionality.
    /// </summary>
    public interface IPokemonPhoneScreen
    {
		/// <summary>
		/// Initializes the phone screen with the specified scene.
		/// Sets up the scene instance for managing the phone interface.
		/// </summary>
		/// <param name="scene">The phone scene to use.</param>
		IPokemonPhoneScreen initialize(IPokemonPhone_Scene scene);

        /// <summary>
        /// Starts the phone screen and handles contact management.
        /// Displays available contacts and manages calling functionality.
        /// </summary>
        void StartScreen();
    }
}