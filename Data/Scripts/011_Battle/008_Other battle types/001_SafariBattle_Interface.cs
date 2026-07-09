using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for fake battler class used in Safari Zone battles.
    /// Provides a simplified battler representation for wild Pokemon in Safari battles
    /// without full battle mechanics, focusing only on display and capture functionality.
    /// </summary>
    /// <remarks>
    /// Simple battler class for the wild Pokémon in a Safari Zone battle.
    /// </remarks>
    public interface IFakeBattler
    {
        /// <summary>Reference to the Safari battle instance.</summary>
        ISafariBattle battle { get; }

        /// <summary>Battler index position.</summary>
        int index { get; }

        /// <summary>Pokemon data being represented.</summary>
        IPokemon pokemon { get; }

        /// <summary>Whether this Pokemon species is owned by the player.</summary>
        /// <remarks>Checks if the Pokemon species is owned by the player.</remarks>
        /// <returns>True if species is in player's Pokedex as owned</returns>
        bool owned { get; set; }

        /// <summary>Pokemon index in party (always 0 for Safari).</summary>
        int pokemonIndex { get; }

        /// <summary>Pokemon species.</summary>
        int species { get; }

        /// <summary>Pokemon gender.</summary>
        int gender { get; }

        /// <summary>Pokemon status condition.</summary>
        int status { get; }

        /// <summary>Current HP of the Pokemon.</summary>
        int hp { get; }

        /// <summary>Pokemon level.</summary>
        int level { get; }

        /// <summary>Pokemon name.</summary>
        string name { get; }

        /// <summary>Maximum HP of the Pokemon.</summary>
        int totalhp { get; }

        /// <summary>Display gender for UI purposes.</summary>
        int displayGender { get; }

        /// <summary>Whether the Pokemon is shiny.</summary>
        bool shiny { get; }

        /// <summary>Whether the Pokemon is super shiny.</summary>
        bool super_shiny { get; }

        /// <summary>
        /// Checks if the Pokemon is of a specific species.
        /// </summary>
        /// <param name="check_species">Species to check against</param>
        /// <returns>True if Pokemon matches the species</returns>
        bool isSpecies(int check_species);

        /// <summary>Whether the Pokemon has fainted (always false in Safari).</summary>
        bool fainted { get; }

        /// <summary>Whether the Pokemon is a Shadow Pokemon (always false in Safari).</summary>
        bool shadowPokemon { get; }

        /// <summary>Whether the Pokemon can mega evolve (always false in Safari).</summary>
        bool hasMega { get; }

        /// <summary>Whether the Pokemon is mega evolved (always false in Safari).</summary>
        bool mega { get; }

        /// <summary>Whether the Pokemon can primal revert (always false in Safari).</summary>
        bool hasPrimal { get; }

        /// <summary>Whether the Pokemon is primal (always false in Safari).</summary>
        bool primal { get; }

        /// <summary>Whether the Pokemon was captured (always false in Safari until caught).</summary>
        bool captured { get; set; }

        /// <summary>
        /// Checks if the Pokemon species is owned by the player.
        /// </summary>
        /// <returns>True if species is in player's Pokedex as owned</returns>
        //bool owned();

        /// <summary>
        /// Gets display text for this wild Pokemon.
        /// </summary>
        /// <param name="lowerCase">Whether to use lowercase formatting</param>
        /// <returns>Formatted display text</returns>
        //string This(bool lowerCase = false);
        string ToString(bool lowerCase = false);

        /// <summary>
        /// Checks if this battler opposes another battler index.
        /// </summary>
        /// <param name="i">Battler index or fake battler to check against</param>
        /// <returns>True if battlers are on opposing sides</returns>
        bool opposes(object i);

        /// <summary>
        /// Resets the fake battler state (no-op for Safari battles).
        /// </summary>
        void Reset();
    }

    /// <summary>
    /// Interface for Safari Zone data box UI component.
    /// Displays Safari Ball count and other Safari-specific information during battle.
    /// </summary>
    /// <remarks>
    /// Data box for safari battles.
    /// </remarks>
    public interface ISafariDataBox : ISprite
    {
        /// <summary>Currently selected option index.</summary>
        int selected { get; set; }

        /// <summary>
        /// Refreshes the data box display with current information.
        /// Updates Safari Ball count and other relevant Safari Zone data.
        /// </summary>
        void refresh();
    }

    /// <summary>
    /// Interface for bait throwing animation in Safari battles.
    /// Handles the visual sequence of the player throwing bait to make Pokemon less likely to flee.
    /// </summary>
    /// <remarks>
    /// Shows the player throwing bait at a wild Pokémon in a Safari battle.
    /// </remarks>
    public interface IThrowBaitAnimation : IAnimation
    {
        /// <summary>
        /// Creates the animation sequence for throwing bait.
        /// Includes trainer throwing motion, bait trajectory, and Pokemon reaction.
        /// </summary>
        void createProcesses();
    }

    /// <summary>
    /// Interface for rock throwing animation in Safari battles.
    /// Handles the visual sequence of the player throwing a rock to make Pokemon easier to catch but more likely to flee.
    /// </summary>
    /// <remarks>
    /// Shows the player throwing a rock at a wild Pokémon in a Safari battle.
    /// </remarks>
    public interface IThrowRockAnimation : IAnimation
    {
        /// <summary>
        /// Creates the animation sequence for throwing a rock.
        /// Includes trainer throwing motion, rock trajectory, impact effect, and Pokemon anger reaction.
        /// </summary>
        void createProcesses();
    }

    /// <summary>
    /// Interface for Safari Zone battle scene extensions.
    /// Provides Safari-specific UI and animation functionality for the battle scene.
    /// </summary>
    /// <remarks>
    /// Safari Zone battle scene (the visuals of the battle).
    /// </remarks>
    public interface IBattleSceneSafari : IBattleScene
    {
        /// <summary>
        /// Initializes Safari Zone battle display.
        /// Sets up Safari-specific UI elements including the Safari data box.
        /// </summary>
        void SafariStart();

        /// <summary>
        /// Shows the Safari Zone command menu.
        /// Displays options for Ball, Bait, Rock, and Run actions.
        /// </summary>
        /// <param name="index">Battler index (always 0 for Safari)</param>
        /// <returns>Selected command index</returns>
        int SafariCommandMenu(int index);

        /// <summary>
        /// Plays the bait throwing animation.
        /// Shows visual sequence of throwing bait and Pokemon reaction.
        /// </summary>
        void ThrowBait();

        /// <summary>
        /// Plays the rock throwing animation.
        /// Shows visual sequence of throwing rock and Pokemon anger reaction.
        /// </summary>
        void ThrowRock();

        /// <summary>
        /// Handles successful capture in Safari Zone.
        /// Extends the base throw success method with Safari-specific handling.
        /// </summary>
        void ThrowSuccess();
    }

    /// <summary>
    /// Interface for Safari Zone battle class that implements simplified Pokemon encounters.
    /// Manages Safari Zone mechanics including bait/rock effects, Safari Ball usage,
    /// escape calculations, and catch rate modifications without traditional battle complexity.
    /// </summary>
    public interface ISafariBattle : ICanDisplayMessage
    {
        /// <summary>Array of fake battler objects representing Pokemon in Safari encounter.</summary>
        IFakeBattler[] battlers { get; }

        /// <summary>Array of number of battlers per side (always [1,1] for Safari).</summary>
        int[] sideSizes { get; set; }

        /// <summary>Filename fragment used for background graphics.</summary>
        int backdrop { get; set; }

        /// <summary>Filename fragment used for base graphics.</summary>
        int backdropBase { get; set; }

        /// <summary>Time of day (0=day, 1=evening, 2=night).</summary>
        int time { get; set; }

        /// <summary>Battle environment for visual purposes.</summary>
        int environment { get; set; }

        /// <summary>Current weather condition.</summary>
        int weather { get; }

        /// <summary>Player trainer.</summary>
        ITrainer player { get; }

        /// <summary>Wild Pokemon party (single Pokemon).</summary>
        IPokemon[] party2 { get; set; }

        /// <summary>Whether player can run from Safari encounter.</summary>
        bool canRun { get; set; }

        /// <summary>Whether player won't black out if they lose.</summary>
        bool canLose { get; set; }

        /// <summary>Switch/Set battle style option.</summary>
        bool switchStyle { get; set; }

        /// <summary>Battle scene animation display option.</summary>
        bool showAnims { get; set; }

        /// <summary>Whether Pokemon can gain experience (disabled in Safari).</summary>
        bool expGain { get; set; }

        /// <summary>Whether the player can gain money (disabled in Safari).</summary>
        bool moneyGain { get; set; }

        /// <summary>Safari Zone rules.</summary>
        IList<string> rules { get; set; }

        /// <summary>Number of Safari Balls remaining.</summary>
        int ballCount { get; set; }

        /// <summary>Battle decision/outcome.</summary>
        int decision { get; }

        /// <summary>Caught Pokemon storage.</summary>
        IPokemon[] caughtPokemon { get; }

        /// <summary>Battle scene reference.</summary>
        IBattleScene scene { get; }

        /// <summary>Peer object for Pokemon storage.</summary>
        IPeer peer { get; }

        /// <summary>
        /// Generates a random number for Safari calculations.
        /// </summary>
        /// <param name="x">Maximum value (exclusive)</param>
        /// <returns>Random number from 0 to x-1</returns>
        int Random(int x);

        /// <summary>
        /// Initializes a new Safari Zone battle.
        /// </summary>
        /// <param name="scene">Battle scene for visuals</param>
        /// <param name="player">Player trainer</param>
        /// <param name="party2">Wild Pokemon party</param>
        ISafariBattle initialize(IBattleScene scene, ITrainer player, IPokemon[] party2);

        /// <summary>
        /// Checks if the Safari encounter has been decided.
        /// </summary>
        /// <returns>True if outcome is determined</returns>
        bool decided();

        /// <summary>
        /// Sets Poke Ball disabling (no effect in Safari).
        /// </summary>
        bool disablePokeBalls { set; }

        /// <summary>
        /// Sets send to boxes behavior (no effect in Safari).
        /// </summary>
        int sendToBoxes { set; }

        /// <summary>
        /// Sets default weather for the Safari encounter.
        /// </summary>
        int defaultWeather { set; }

        /// <summary>
        /// Sets default terrain (no effect in Safari).
        /// </summary>
        int defaultTerrain { set; }

        /// <summary>Whether this is a wild Pokemon encounter (always true).</summary>
        bool wildBattle { get; }

        /// <summary>Whether this is a trainer battle (always false).</summary>
        bool trainerBattle { get; }

        /// <summary>
        /// Sets battle mode (no effect in Safari - always single).
        /// </summary>
        /// <param name="mode">Battle mode string</param>
        void setBattleMode(string mode);

        /// <summary>
        /// Gets the number of battlers on a specific side.
        /// </summary>
        /// <param name="index">Side index</param>
        /// <returns>Number of battlers (always 1)</returns>
        int SideSize(int index);

        /// <summary>Gets the player trainer.</summary>
        ITrainer Player { get; }

        /// <summary>Gets the opponent (always null in Safari).</summary>
        ITrainer opponent { get; }

        /// <summary>
        /// Gets the owner of a battler (always player).
        /// </summary>
        /// <param name="idxBattler">Battler index</param>
        /// <returns>Player trainer</returns>
        ITrainer GetOwnerFromBattlerIndex(int idxBattler);

        /// <summary>
        /// Registers a Pokemon as seen in the Pokedex.
        /// </summary>
        /// <param name="battler">Battler to register</param>
        void SetSeen(IBattler battler);

        /// <summary>
        /// Registers a Pokemon as caught in the Pokedex.
        /// </summary>
        /// <param name="battler">Battler to register</param>
        void SetCaught(IBattler battler);

        /// <summary>
        /// Gets the party for a specific battler.
        /// </summary>
        /// <param name="idxBattler">Battler index</param>
        /// <returns>Pokemon party (null for player, party2 for wild Pokemon)</returns>
        IPokemon[] Party(int idxBattler);

        /// <summary>
        /// Checks if all Pokemon have fainted (always false in Safari).
        /// </summary>
        /// <param name="idxBattler">Battler index</param>
        /// <returns>Always false</returns>
        bool AllFainted(int idxBattler = 0);

        /// <summary>
        /// Checks if two battlers are on opposing sides.
        /// </summary>
        /// <param name="idxBattler1">First battler index</param>
        /// <param name="idxBattler2">Second battler index</param>
        /// <returns>True if battlers oppose each other</returns>
        bool opposes(int idxBattler1, int idxBattler2 = 0);

        /// <summary>
        /// Removes Pokemon from party (no effect in Safari).
        /// </summary>
        /// <param name="idxBattler">Battler index</param>
        /// <param name="idxParty">Party index</param>
        void RemoveFromParty(int idxBattler, int idxParty);

        /// <summary>
        /// Gains experience (no effect in Safari).
        /// </summary>
        void GainExp();

        /// <summary>
        /// Displays a message in the Safari battle.
        /// </summary>
        /// <param name="msg">Message to display</param>
        /// <param name="block">Optional callback</param>
        void Display(string msg, System.Action block = null);

        /// <summary>
        /// Displays a paused message in the Safari battle.
        /// </summary>
        /// <param name="msg">Message to display</param>
        /// <param name="block">Optional callback</param>
        void DisplayPaused(string msg, System.Action block = null);

        /// <summary>
        /// Displays a brief message in the Safari battle.
        /// </summary>
        /// <param name="msg">Message to display</param>
        void DisplayBrief(string msg);

        /// <summary>
        /// Displays a confirmation dialog.
        /// </summary>
        /// <param name="msg">Message for confirmation</param>
        /// <returns>True if confirmed</returns>
        bool DisplayConfirm(string msg);

        /// <summary>
        /// Aborts the Safari battle.
        /// Throws exception to interrupt battle flow.
        /// </summary>
        void Abort();

        /// <summary>
        /// Calculates escape rate based on Pokemon's catch rate.
        /// Determines how likely the wild Pokemon is to flee based on its natural catch difficulty.
        /// </summary>
        /// <param name="catch_rate">Base catch rate of the Pokemon</param>
        /// <returns>Escape factor for flee calculations</returns>
        int EscapeRate(int catch_rate);

        /// <summary>
        /// Starts and manages the complete Safari Zone battle sequence.
        /// Handles turn-based Safari mechanics including Ball throwing, Bait/Rock usage,
        /// escape calculations, and battle resolution until capture, flee, or defeat.
        /// </summary>
        /// <returns>Battle outcome result</returns>
        int StartBattle();
    }
}