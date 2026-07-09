using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    public interface IMainChallengeExtensions : IMain
    {
        void BattleChallenge();
        void BattleChallengeBattle();
        //bool HasEligible(*arg);
        bool HasEligible();
        void GetBTTrainers(int challengeID);
        void GetBTPokemon(int challengeID);
        /// <summary>
        /// Continue to EntryScreen if Pokemon(s) were chosen
        /// </summary>
        /// <returns></returns>
        //int EntryScreen(*arg);
        bool EntryScreen();
        void BattleChallengeGraphic(IGameEvent @event);
        void BattleChallengeBeginSpeech();
    }

    /// <summary>
    /// Interface for extended Game_Player functionality in challenges
    /// </summary>
    public interface IGamePlayerChallengeExtensions : IGamePlayer
    {
        /// <summary>
        /// Moves the player to a specific position without animation
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        void moveto2(int x, int y);
    }

    /// <summary>
    /// Interface for extended Game_Event functionality in challenges
    /// </summary>
    public interface IGameEventChallengeExtensions : IGameEvent
    {
        /// <summary>
        /// Checks if a challenge is currently active
        /// </summary>
        /// <returns>True if in challenge, false otherwise</returns>
        bool pbInChallenge();
    }

    /// <summary>
    /// Interface for Battle Tower/Cup Pokemon data structure
    /// </summary>
    public interface IPBPokemon
    {
        /// <summary>
        /// Gets or sets the Pokemon species
        /// </summary>
        int species { get; set; }

        /// <summary>
        /// Gets or sets the held item
        /// </summary>
        int item { get; set; }

        /// <summary>
        /// Gets or sets the Pokemon nature
        /// </summary>
        int nature { get; set; }

        /// <summary>
        /// Gets or sets the first move
        /// </summary>
        int move1 { get; set; }

        /// <summary>
        /// Gets or sets the second move
        /// </summary>
        int move2 { get; set; }

        /// <summary>
        /// Gets or sets the third move
        /// </summary>
        int move3 { get; set; }

        /// <summary>
        /// Gets or sets the fourth move
        /// </summary>
        int move4 { get; set; }

        /// <summary>
        /// Gets or sets the EV distribution array
        /// </summary>
        IList<int> ev { get; set; }

        /// <summary>
        /// Creates a PBPokemon from an inspected string representation
        /// </summary>
        /// <param name="str">String representation of Pokemon data</param>
        /// <returns>PBPokemon instance</returns>
        //static IPBPokemon fromInspected(string str);

        /// <summary>
        /// Creates a PBPokemon from an existing Pokemon instance
        /// </summary>
        /// <param name="pkmn">Pokemon to convert</param>
        /// <returns>PBPokemon instance</returns>
        //static IPBPokemon fromPokemon(IPokemon pkmn);

        /// <summary>
        /// Initializes a new PBPokemon with specified parameters
        /// </summary>
        /// <param name="species">Pokemon species</param>
        /// <param name="item">Held item</param>
        /// <param name="nature">Pokemon nature</param>
        /// <param name="move1">First move</param>
        /// <param name="move2">Second move</param>
        /// <param name="move3">Third move</param>
        /// <param name="move4">Fourth move</param>
        /// <param name="ev">EV distribution</param>
        void initialize(int species, int item, int nature, int move1, int move2, int move3, int move4, IList<int> ev);

        /// <summary>
        /// Returns a string representation of the Pokemon data
        /// </summary>
        /// <returns>Formatted Pokemon data string</returns>
        string inspect();

        /// <summary>
        /// Returns a compact string representation of the Pokemon data
        /// </summary>
        /// <returns>Compact Pokemon data string</returns>
        string tocompact();

        /// <summary>
        /// Converts problematic moves to alternatives
        /// </summary>
        /// <param name="move">Move to convert</param>
        /// <returns>Converted move</returns>
        int convertMove(int move);

        /// <summary>
        /// Creates a full Pokemon instance from this PBPokemon data
        /// </summary>
        /// <param name="level">Pokemon level</param>
        /// <param name="iv">IV value for all stats</param>
        /// <param name="trainer">Owner trainer</param>
        /// <returns>Created Pokemon instance</returns>
        IPokemon createPokemon(int level, int iv, ITrainer trainer);
    }
}