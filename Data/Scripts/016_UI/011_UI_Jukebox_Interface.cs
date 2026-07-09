using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the jukebox scene that manages music playback and selection.
    /// Handles music track listing, playback controls, and audio management.
    /// </summary>
    public interface IPokemonJukebox_Scene : IUIScene, IHaveUpdate
    {
        /// <summary>
        /// Updates all sprites in the jukebox scene.
        /// Called during the main loop to refresh sprite states and animations.
        /// </summary>
        void Update();

        /// <summary>
        /// Starts the jukebox scene with available music tracks.
        /// Initializes track list, playback controls, and music interface elements.
        /// </summary>
        /// <param name="tracks">List of available music tracks for playback.</param>
        void StartScene(IList<object> tracks);

        /// <summary>
        /// Handles the main scene interaction loop for music selection and control.
        /// Processes navigation through tracks and handles playback commands.
        /// </summary>
        /// <returns>Result code indicating action taken or exit condition.</returns>
        int Scene();

        /// <summary>
        /// Ends the jukebox scene and cleans up resources.
        /// Handles fade out transition and disposes of sprites and viewports.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Refreshes the music track list display with current information.
        /// Updates track names, playback status, and availability indicators.
        /// </summary>
        void RefreshTrackList();

        /// <summary>
        /// Updates the information display for the currently selected track.
        /// Shows track details, duration, and playback information.
        /// </summary>
        void UpdateTrackInfo();

        /// <summary>
        /// Handles navigation between music tracks in the jukebox.
        /// Updates selection and refreshes track information display.
        /// </summary>
        /// <param name="direction">Direction of navigation (up/down).</param>
        void NavigateTracks(int direction);

        /// <summary>
        /// Starts playback of the selected music track.
        /// Begins audio playback and updates interface to show playing status.
        /// </summary>
        /// <param name="track_index">Index of the track to play.</param>
        void PlayTrack(int track_index);

        /// <summary>
        /// Stops the currently playing music track.
        /// Halts audio playback and updates interface to show stopped status.
        /// </summary>
        void StopTrack();

        /// <summary>
        /// Pauses or resumes the currently playing music track.
        /// Toggles playback state and updates interface accordingly.
        /// </summary>
        void TogglePlayback();

        /// <summary>
        /// Adjusts the volume level for music playback.
        /// Changes audio volume and updates volume indicator display.
        /// </summary>
        /// <param name="direction">Direction of volume adjustment (up/down).</param>
        void AdjustVolume(int direction);
    }

    /// <summary>
    /// Interface for the jukebox screen that orchestrates music management functionality.
    /// Coordinates between scenes and manages overall music playback experience.
    /// </summary>
    public interface IPokemonJukeboxScreen
    {
		/// <summary>
		/// Initializes the jukebox screen with the specified scene.
		/// Sets up the scene instance for managing the jukebox interface.
		/// </summary>
		/// <param name="scene">The jukebox scene to use.</param>
		IPokemonJukeboxScreen initialize(IPokemonJukebox_Scene scene);

        /// <summary>
        /// Starts the jukebox screen and handles music management.
        /// Displays available tracks and manages playback functionality.
        /// </summary>
        void StartScreen();
    }
}