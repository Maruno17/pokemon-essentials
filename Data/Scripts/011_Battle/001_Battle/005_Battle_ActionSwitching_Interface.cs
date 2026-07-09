using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining battle switching mechanics.
    /// Handles Pokémon switching, party screen interactions, end-of-round switching, and all related effects.
    /// </summary>
    public interface IBattleActionSwitching : IBattle
    {
        /// <summary>
        /// Checks whether the replacement Pokémon (at party index idxParty) can enter battle.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        /// <param name="partyScene">Optional party screen scene for displaying messages.</param>
        /// <returns>True if the Pokémon can switch in, false otherwise.</returns>
        bool CanSwitchIn(int idxBattler, int idxParty, IPartyDisplayScene partyScene = null);

        /// <summary>
        /// Checks whether the currently active Pokémon (at battler index idxBattler) can switch out.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="partyScene">Optional party screen scene for displaying messages.</param>
        /// <returns>True if the battler can switch out, false otherwise.</returns>
        bool CanSwitchOut(int idxBattler, IPartyDisplayScene partyScene = null);

        /// <summary>
        /// Checks whether the currently active Pokémon (at battler index idxBattler) can switch out and that its replacement at party index idxParty can switch in.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        /// <param name="partyScene">Optional party screen scene for displaying messages.</param>
        /// <returns>True if the switch is possible, false otherwise.</returns>
        bool CanSwitch(int idxBattler, int idxParty = -1, IPartyDisplayScene partyScene = null);

        /// <summary>
        /// Checks if there are any non-active Pokémon that can be switched in for the given battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>True if there are available Pokémon to switch in, false otherwise.</returns>
        bool CanChooseNonActive(int idxBattler);

        /// <summary>
        /// Registers a switch command for a battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        /// <returns>True if the switch was registered, false otherwise.</returns>
        bool RegisterSwitch(int idxBattler, int idxParty);

        /// <summary>
        /// Opens the party screen and allows choosing a replacement Pokémon.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="checkLaxOnly">Whether to only check if the Pokémon can switch in.</param>
        /// <param name="canCancel">Whether the player can cancel the selection.</param>
        /// <param name="shouldRegister">Whether to register the switch immediately.</param>
        /// <returns>The index of the chosen party Pokémon, or -1 if cancelled.</returns>
        int PartyScreen(int idxBattler, bool checkLaxOnly = false, bool canCancel = false, bool shouldRegister = false);

        /// <summary>
        /// Handles switching in a replacement Pokémon between actions (e.g., U-turn, Baton Pass).
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="checkLaxOnly">Whether to only check if the Pokémon can switch in.</param>
        /// <param name="canCancel">Whether the player can cancel the selection.</param>
        /// <returns>The index of the chosen party Pokémon, or -1 if cancelled.</returns>
        int SwitchInBetween(int idxBattler, bool checkLaxOnly = false, bool canCancel = false);

        /// <summary>
        /// Handles end-of-round switching for fainted Pokémon.
        /// </summary>
        /// <param name="favorDraws">Whether to favor draw outcomes.</param>
        void EORSwitch(bool favorDraws = false);

        /// <summary>
        /// Gets the index of a replacement Pokémon for a fainted battler.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="random">Whether to select randomly (AI/auto).</param>
        /// <returns>The index of the replacement Pokémon in the party.</returns>
        int GetReplacementPokemonIndex(int idxBattler, bool random = false);

        /// <summary>
        /// Recalls a battler and sends out its replacement.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        /// <param name="randomReplacement">Whether this is a random replacement (AI/auto).</param>
        /// <param name="batonPass">Whether Baton Pass is being used.</param>
        void RecallAndReplace(int idxBattler, int idxParty, bool randomReplacement = false, bool batonPass = false);

        /// <summary>
        /// Displays the recall message for a battler.
        /// </summary>
        /// <param name="battler">The battler being recalled.</param>
        void MessageOnRecall(IBattler battler);

        /// <summary>
        /// Displays the message for sending out a replacement Pokémon.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        void MessagesOnReplace(int idxBattler, int idxParty);

        /// <summary>
        /// Actually performs the replacement of a battler with a new Pokémon.
        /// </summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="idxParty">The party index of the Pokémon to switch in.</param>
        /// <param name="batonPass">Whether Baton Pass is being used.</param>
        void Replace(int idxBattler, int idxParty, bool batonPass = false);

        /// <summary>
        /// Sends out one or more Pokémon into battle.
        /// </summary>
        /// <param name="sendOuts">A list of tuples: (battler index, Pokémon).</param>
        /// <param name="startBattle">Whether this is the start of battle.</param>
        void SendOut(IEnumerable<KeyValuePair<int, IPokemon>> sendOuts, bool startBattle = false);

        /// <summary>
        /// Called at the start of battle only. Handles all battlers entering battle.
        /// </summary>
        void OnAllBattlersEnteringBattle();

        /// <summary>
        /// Called when one or more Pokémon switch in. Handles entry hazards, form changes, and triggers.
        /// </summary>
        /// <param name="battlerIndex">The battler index or indices.</param>
        /// <param name="skipEventReset">Whether to skip event reset (for certain switch commands).</param>
        void OnBattlerEnteringBattle(int battlerIndex, bool skipEventReset = false);

        /// <summary>
        /// Records a battler as having participated in battle (for Exp/EVs, Amulet Coin, etc.).
        /// </summary>
        /// <param name="battler">The battler to record.</param>
        void RecordBattlerAsParticipated(IBattler battler);

        /// <summary>
        /// Displays messages for a battler entering battle (e.g., Shadow Pokémon intro).
        /// </summary>
        /// <param name="battler">The battler entering battle.</param>
        void MessagesOnBattlerEnteringBattle(IBattler battler);

        /// <summary>
        /// Handles effects upon a Pokémon entering battle (Healing Wish, Lunar Dance, etc.).
        /// </summary>
        /// <param name="battler">The battler entering battle.</param>
        void EffectsOnBattlerEnteringPosition(IBattler battler);

        /// <summary>
        /// Handles entry hazards for a battler (Stealth Rock, Spikes, etc.).
        /// </summary>
        /// <param name="battler">The battler affected by entry hazards.</param>
        void EntryHazards(IBattler battler);
    }
}