using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Firshing.
    /// </summary>
    /// <remarks>
    /// Interface for fishing functionality in the overworld.
    /// </remarks>
    public interface IMainOverworldFishing : IMain
    {
        /// <summary>
        /// Begins the fishing animation and state.
        /// </summary>
        void FishingBegin();

        /// <summary>
        /// Ends the fishing animation and state.
        /// </summary>
        void FishingEnd();

        /// <summary>
        /// Performs the fishing minigame with specified parameters.
        /// </summary>
        /// <param name="hasEncounter">Whether an encounter is possible</param>
        /// <param name="rodType">The type of fishing rod (1=Old Rod, 2=Good Rod, 3=Super Rod)</param>
        /// <returns>True if a Pokémon was successfully caught</returns>
        bool Fishing(bool hasEncounter, int rodType = 1);

        /// <summary>
        /// Show waiting dots before a Pokémon bites
        /// </summary>
        /// <remarks>
        /// Shows waiting dots before a Pokémon bites, allowing player to cancel.
        /// </remarks>
        /// <param name="msgWindow">The message window to display in</param>
        /// <param name="time">The time to wait in deciseconds</param>
        /// <returns>True if the player cancelled the fishing</returns>
        bool WaitMessage(object msgWindow, int time);

        /// <summary>
        /// A Pokémon is biting, reflex test to reel it in
        /// </summary>
        /// <remarks>
        /// Reflex test for when a Pokémon is biting - player must press a button in time.
        /// </remarks>
        /// <param name="msgWindow">The message window to display in</param>
        /// <param name="message">The message to display</param>
        /// <param name="duration">The duration the player has to react</param>
        /// <returns>True if the player pressed a button in time</returns>
        bool WaitForInput(object msgWindow, string message, double duration);
    }
}