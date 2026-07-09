using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Used when generating new trainers for battle challenges.
    /// </summary>
    /// <remarks>
    /// Interface for the debug/no-visuals battle scene used for trainer generation and testing.
    /// </remarks>
    public interface IDebugSceneNoVisuals : IHaveUpdate, IHaveRefresh
    {
        /// <summary>Initializes the debug scene.</summary>
        void Initialize(bool logMessages = false);
        /// <summary>
        /// Called whenever the battle begins.
        /// </summary>
        /// <remarks>
        /// Starts the battle in debug mode.
        /// </remarks>
        void StartBattle(IBattle battle);
        /// <summary>Performs a blitz action with the given keys.</summary>
        int Blitz(IList<int> keys);
        /// <summary>
        /// Called whenever a new round begins.
        /// </summary>
        /// <remarks>
        /// Begins the command phase.
        /// </remarks>
        void BeginCommandPhase();
        /// <summary>Begins the attack phase.</summary>
        void BeginAttackPhase();
        /// <summary>Begins the end-of-round phase.</summary>
        void BeginEndOfRoundPhase();
        /// <summary>Shows the opponent trainer.</summary>
        void ShowOpponent(int idxTrainer);
        /// <summary>Animates damage for a battler.</summary>
        void DamageAnimation(IBattler battler, int effectiveness = 0);
        /// <summary>Plays a common animation.</summary>
        void CommonAnimation(string animName, IBattler user = null, IBattler target = null);
        /// <summary>Plays a move animation.</summary>
        void Animation(int moveID, IBattler user, IList<IBattler> targets, int hitNum = 0);
        /// <summary>Animates HP loss for multiple battlers.</summary>
        void HitAndHPLossAnimation(IList<IBattler> targets);
        /// <summary>Shows the party lineup.</summary>
        void ShowPartyLineup(int side, bool fullAnim = false);
        /// <summary>Shows the ability splash for a battler.</summary>
        void ShowAbilitySplash(IBattler battler, bool delay = false, bool logTrigger = true);
        /// <summary>Replaces the ability splash for a battler.</summary>
        void ReplaceAbilitySplash(IBattler battler);
        /// <summary>Hides the ability splash for a battler.</summary>
        void HideAbilitySplash(IBattler battler);
        /// <summary>Ends the battle with the given result.</summary>
        void EndBattle(int result);
        /// <summary>Handles wild battle success.</summary>
        void WildBattleSuccess();
        /// <summary>Handles trainer battle success.</summary>
        void TrainerBattleSuccess();
        /// <summary>Performs battle arena judgment.</summary>
        void BattleArenaJudgment(IBattler b1, IBattler b2, int r1, int r2);
        /// <summary>Handles battle arena battlers.</summary>
        void BattleArenaBattlers(IBattler b1, IBattler b2);
        /// <summary>Updates the debug scene.</summary>
        void Update(IWindow_CommandPokemon cw = null);
        /// <summary>Refreshes the debug scene.</summary>
        void Refresh();
        /// <summary>Refreshes a single battler in the debug scene.</summary>
        void RefreshOne(int idxBattler);
        /// <summary>Displays a message in the debug scene.</summary>
        void DisplayMessage(string msg, bool brief = false);
        /// <summary>Displays a paused message in the debug scene.</summary>
        void DisplayPausedMessage(string msg);
        /// <summary>Displays a confirmation message in the debug scene.</summary>
        bool DisplayConfirmMessage(string msg);
        /// <summary>Shows a command selection window in the debug scene.</summary>
        int ShowCommands(string msg, IList<string> commands, int defaultValue);
        /// <summary>Sends out battlers in the debug scene.</summary>
        void SendOutBattlers(IList<IBattler> sendOuts, bool startBattle = false);
        /// <summary>Recalls a battler in the debug scene.</summary>
        void Recall(int idxBattler);
        /// <summary>Handles the item menu in the debug scene.</summary>
        int ItemMenu(int idxBattler, bool firstAction);
        /// <summary>Resets the command index for a battler.</summary>
        void ResetCommandsIndex(int idxBattler);
        /// <summary>Animates HP change for a battler.</summary>
        void HPChanged(IBattler battler, int oldHP, bool showAnim = false);
        /// <summary>Changes the Pokémon for a battler.</summary>
        void ChangePokemon(int idxBattler, IPokemon pkmn);
        /// <summary>Animates a battler fainting.</summary>
        void FaintBattler(IBattler battler);
        /// <summary>Animates the Exp bar for a battler.</summary>
        void EXPBar(IBattler battler, int startExp, int endExp, int tempExp1, int tempExp2);
        /// <summary>Shows the level up window for a Pokémon.</summary>
        void LevelUp(IPokemon pkmn, IBattler battler, int oldTotalHP, int oldAttack, int oldDefense, int oldSpAtk, int oldSpDef, int oldSpeed);
        /// <summary>
        /// Handles forgetting a move for a Pokémon.
        /// </summary>
        /// <remarks>
        /// Always forget first move
        /// </remarks>
        int ForgetMove(IPokemon pkmn, IMove moveToLearn);
        /// <summary>Handles the command menu for a battler.</summary>
        int CommandMenu(int idxBattler, bool firstAction);
        /// <summary>Handles the fight menu for a battler.</summary>
        void FightMenu(int idxBattler, bool megaEvoPossible = false);
        /// <summary>Handles choosing a target for a move.</summary>
        int ChooseTarget(int idxBattler, object targetData, IDictionary<string, bool> visibleSprites = null);
        /// <summary>Handles the party screen for a battler.</summary>
        void PartyScreen(int idxBattler, bool canCancel = false);
    }
}