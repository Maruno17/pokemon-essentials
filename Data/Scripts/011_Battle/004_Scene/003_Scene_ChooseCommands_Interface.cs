using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for global methods related to choosing commands in the battle scene.
    /// </summary>
    public interface IBattleSceneChooseCommands : IBattleScene
    {
        /// <summary>
        /// The player chooses a main command for a Pokémon.
        /// </summary>
        /// <returns>
        /// Return values: -1=Cancel, 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
        /// </returns>
        int CommandMenu(int idxBattler, bool firstAction);

        /// <summary>
        /// The player chooses a main command for a Pokémon, with custom texts and mode.
        /// </summary>
        /// <remarks>
        /// Mode: 0 = regular battle with "Run" (first choosable action in the round only)
        /// <br/> 1 = regular battle with "Cancel"
        /// <br/> 2 = regular battle with "Call" (for Shadow Pokémon battles)
        /// <br/> 3 = Safari Zone
        /// <br/> 4 = Bug-Catching Contest
        /// </remarks>
        int CommandMenuEx(int idxBattler, IList<string> texts, int mode = 0);

        /// <summary>
        /// The player chooses a move for a Pokémon to use.
        /// </summary>
        void FightMenu(int idxBattler, bool megaEvoPossible = false);

        /// <summary>
        /// Opens the party screen to choose a Pokémon to switch in (or just view its summary screens).
        /// </summary>
        /// <param name="mode">0=Pokémon command, 1=choose a Pokémon to send to the Boxes, 2=view summaries only</param>
        void PartyScreen(int idxBattler, bool canCancel = false, int mode = 0);

        /// <summary>
        /// Opens the Bag screen and chooses an item to use.
        /// </summary>
        void ItemMenu(int idxBattler, bool firstAction);

        /// <summary>
        /// Returns an array containing battler names to display when choosing a move's target.
        /// </summary>
        /// <returns>
        /// null means can't select that position, "" means can select that position but
        /// there is no battler there, otherwise is a battler's name.
        /// </returns>
        IList<string> CreateTargetTexts(int idxBattler, ITarget targetData);

        /// <summary>
        /// Returns the initial position of the cursor when choosing a target for a move in a non-single battle.
        /// </summary>
        int FirstTarget(int idxBattler, ITarget targetData);

        /// <summary>
        /// The player chooses a target battler for a move/item (non-single battles only).
        /// </summary>
        int ChooseTarget(int idxBattler, ITarget targetData, IDictionary<string, bool> visibleSprites = null);

        /// <summary>
        /// Opens a Pokémon's summary screen to try to learn a new move.
        /// </summary>
        /// <remarks>
        /// Called whenever a Pokémon should forget a move.
        /// It should not allow HM moves to be forgotten.
        /// </remarks>
        /// <returns>Returns -1 if cancelled, or 0-3 for the move to forget.</returns>
        int ForgetMove(IPokemon pkmn, IMove moveToLearn);

        /// <summary>
        /// Opens the nicknaming screen for a newly caught Pokémon.
        /// </summary>
        string NameEntry(string helpText, IPokemon pkmn);

        /// <summary>
        /// Shows the Pokédex entry screen for a newly caught Pokémon.
        /// </summary>
        void ShowPokedex(int species);
    }
}