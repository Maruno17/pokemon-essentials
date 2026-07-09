using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	public enum BattleResults : int
	{
		InProgress = -1,
		/// <summary>
		/// 0 - Undecided or aborted
		/// </summary>
		ABORTED = 0,
		/// <summary>
		/// 1 - Player won
		/// </summary>
		WON = 1,
		/// <summary>
		/// 2 - Player lost
		/// </summary>
		LOST = 2,
		/// <summary>
		/// 3 - Player or wild Pokémon ran from battle, or player forfeited the match
		/// </summary>
		FORFEIT = 3,
		/// <summary>
		/// 4 - Wild Pokémon was caught
		/// </summary>
		CAPTURED = 4,
		/// <summary>
		/// 5 - Draw
		/// </summary>
		DRAW = 5
	}

	/// <summary>Outcome constants and helper methods for battle results.</summary>
	//public static partial class IOutcome
	public interface IOutcome
	{
		/// <summary>Battle is undecided.</summary>
		//public const int UNDECIDED = 0;
		int UNDECIDED { get;}
		/// <summary>Player won the battle.</summary>
		//public const int WIN = 1;
		int WIN { get;}
		/// <summary>Player lost the battle (also used for forfeits).</summary>
		//public const int LOSE = 2;
		int LOSE { get;}
		/// <summary>Player or wild Pokémon ran away, counts as a win.</summary>
		//public const int FLEE = 3;
		int FLEE { get;}
		/// <summary>Pokémon was caught, counts as a win.</summary>
		//public const int CATCH = 4;
		int CATCH { get;}
		/// <summary>The battle ended in a draw.</summary>
		//public const int DRAW = 5;
		int DRAW { get;}

		/// <summary>Returns true if the battle outcome is decided.</summary>
		bool decided(int decision);
		/// <summary>Returns true if the player should black out after this outcome.</summary>
		bool should_black_out(int decision);
		/// <summary>Returns true if the outcome is a success (win, flee, catch).</summary>
		bool success(int decision);
	}

	/// <summary>
	/// Results of battle (<see cref="IOutcome"/>)
	/// Possible actions a battler can take in a round: <see cref="BattleActions"/>
	/// </summary>
	/// <remarks>
	/// NOTE: If you want to have more than 3 Pokémon on a side at once, you will need
	///       to edit some code. Mainly this is to change/add coordinates for the
	///       sprites, describe the relationships between Pokémon and trainers, and to
	///       change messages. The methods that will need editing are as follows:
	///           class <see cref="IBattle"/>
	///             <see cref="IBattle.setBattleMode(string)"/>						public void setBattleMode() {
	///             <see cref="IBattle.pbGetOwnerIndexFromBattlerIndex"/>		public void GetOwnerIndexFromBattlerIndex() {
	///             <see cref="IBattle.pbGetOpposingIndicesInOrder"/>			public void GetOpposingIndicesInOrder() {
	///             <see cref="IBattle.nearBattlers(int, int)"/>						public bool nearBattlers() {
	///             <see cref="IBattle.pbStartBattleSendOut"/>					public void StartBattleSendOut() {
	///             <see cref="IBattle.pbEORShiftDistantBattlers"/>			public void EORShiftDistantBattlers() {
	///             <see cref="IBattle.pbCanShift"/>							public bool CanShift() {
	///             <see cref="IBattle.pbEndOfRoundPhase"/>					public void EndOfRoundPhase() {
	///           class Battle.<see cref="IBattleScene.TargetMenu"/>
	///             <see cref="ITargetMenu.Initialize(IViewport, int, IList{int})"/>
	///           class Battle.<see cref="IBattleScene.PokemonDataBox"/>
	///             <see cref="IPokemonDataBox.initializeDataBoxGraphic(int)"/>
	///           class <see cref="IBattle.scene"/>
	///             <see cref="IBattleScene.BattlerPosition(int, int)"/>
	///             <see cref="IBattleScene.TrainerPosition(int, int, int)"/>
	///           class Game_Temp (<see cref="ITempMetadata"/>)
	///             <see cref="ITempMetadataBattleStarting.add_battle_rule(string, object)"/>
	///       (There is no guarantee that this list is complete.)
	/// </remarks>
	public interface IBattle
	{
		/// <summary>Scene object for this battle.</summary>
		IBattleScene scene { get; }
		/// <summary>Peer object for networked battles.</summary>
		IPeer peer { get; }
		/// <summary>Effects common to the whole of a battle.</summary>
		IActiveField field { get; }
		/// <summary>Effects common to each side of a battle.</summary>
		IActiveSide[] sides { get; }
		/// <summary>Effects that apply to a battler position.</summary>
		IActivePosition[] positions { get; }
		/// <summary>Currently active Pokémon.</summary>
		IBattler[] battlers { get; }
		/// <summary>Array of number of battlers per side.</summary>
		int[] sideSizes { get; }
		/// <summary>Filename fragment used for background graphics.</summary>
		string backdrop { get; set; }
		/// <summary>Filename fragment used for base graphics.</summary>
		string backdropBase { get; set; }
		/// <summary>Time of day (0=day, 1=eve, 2=night).</summary>
		int time { get; set; }
		/// <summary>Battle surroundings (for mechanics purposes).</summary>
		int environment { get; set; }
		/// <summary>Current turn count.</summary>
		int turnCount { get; }
		/// <summary>Outcome of battle.</summary>
		int decision { get; set; }
		/// <summary>Player trainer (or array of trainers).</summary>
		ITrainer[] player { get; }
		/// <summary>Opponent trainer (or array of trainers).</summary>
		ITrainer[] opponent { get; }
		/// <summary>Items held by opponents.</summary>
		int[] items { get; set; }
		/// <summary>Items held by allies.</summary>
		int[] ally_items { get; set; }
		/// <summary>Array of start indexes for each player-side trainer's party.</summary>
		int[] party1starts { get; set; }
		/// <summary>Array of start indexes for each opponent-side trainer's party.</summary>
		int[] party2starts { get; set; }
		/// <summary>Internal battle flag.</summary>
		bool internalBattle { get; set; }
		/// <summary>Debug flag.</summary>
		bool debug { get; set; }
		/// <summary>True if player can run from battle.</summary>
		bool canRun { get; set; }
		/// <summary>True if player won't black out if they lose.</summary>
		bool canLose { get; set; }
		/// <summary>True if player is allowed to switch Pokémon.</summary>
		bool canSwitch { get; set; }
		/// <summary>Switch/Set "battle style" option.</summary>
		bool switchStyle { get; set; }
		/// <summary>"Battle Effects" option.</summary>
		bool showAnims { get; set; }
		/// <summary>Whether player's Pokémon are AI controlled.</summary>
		bool controlPlayer { get; set; }
		/// <summary>Whether Pokémon can gain Exp/EVs.</summary>
		bool expGain { get; set; }
		/// <summary>Whether the player can gain/lose money.</summary>
		bool moneyGain { get; set; }
		/// <summary>Whether Poké Balls cannot be thrown at all.</summary>
		bool disablePokeBalls { get; set; }
		/// <summary>Send to Boxes (0=ask, 1=don't ask, 2=must add to party).</summary>
		int sendToBoxes { get; set; }
		/// <summary>Battle rules bitmask or object.</summary>
		IDictionary<string, object> rules { get; set; }
		/// <summary>Choices made by each Pokémon this round.</summary>
		IBattleChoice[] choices { get; set; }
		/// <summary>Battle index of each trainer's Pokémon to Mega Evolve.</summary>
		int[][] megaEvolution { get; set; }
		/// <summary>Initial items held by battlers.</summary>
		int[][] initialItems { get; }
		/// <summary>Items that can be recycled.</summary>
		IList<IList<int>> recycleItems { get; }
		/// <summary>Tracks use of Belch move.</summary>
		bool[][] belch { get; }
		/// <summary>Tracks Battle Bond state.</summary>
		bool[][] battleBond { get; }
		/// <summary>Tracks Corrosive Gas state.</summary>
		bool[][] corrosiveGas { get; }
		/// <summary>Whether each Pokémon was used in battle (for Burmy).</summary>
		bool[][] usedInBattle { get; }
		/// <summary>Success states for the battle.</summary>
		ISuccessState[] successStates { get; }
		/// <summary>Last move used in the battle.</summary>
		int lastMoveUsed { get; set; }
		/// <summary>Last move user in the battle.</summary>
		int lastMoveUser { get; set; }
		/// <summary>ID of the first thrown Poké Ball that failed.</summary>
		int first_poke_ball { get; set; }
		/// <summary>Set after first_poke_ball to prevent it being set again.</summary>
		bool poke_ball_failed { get; set; }
		/// <summary>True if during the switching phase of the round.</summary>
		bool switching { get; }
		/// <summary>True if Future Sight is hitting.</summary>
		bool futureSight { get; }
		/// <summary>Current command phase.</summary>
		bool command_phase { get; }
		/// <summary>True during the end of round.</summary>
		bool endOfRound { get; }
		/// <summary>True if Mold Breaker applies.</summary>
		bool moldBreaker { get; set; }
		/// <summary>The Struggle move instance.</summary>
		int struggle { get; }

		/// <summary>Returns a random integer from 0 to x-1.</summary>
		int Random(int x);

		/// <summary>Initializes the battle with the given scene, parties, and trainers.</summary>
		IBattle initialize(IScene scene, IList<IPokemon> p1, IList<IPokemon> p2, IList<ITrainer> player, IList<ITrainer> opponent);

		/// <summary>Returns true if the battle outcome is decided.</summary>
		bool decided();
		/// <summary>Returns true if this is a wild battle.</summary>
		bool wildBattle();
		/// <summary>Returns true if this is a trainer battle.</summary>
		bool trainerBattle();
		/// <summary>Sets the number of battler slots on each side of the field.</summary>
		void setBattleMode(string mode);
		/// <summary>Returns true if this is a single battle (1v1).</summary>
		bool singleBattle();
		/// <summary>Returns the number of battler slots on the given side.</summary>
		int SideSize(int index);
		/// <summary>Returns the maximum battler index for the current battle mode.</summary>
		int maxBattlerIndex { get; }
		/// <summary>Returns the player trainer index.</summary>
		IPlayer Player { get; }
		/// <summary>Returns the index of the trainer that owns the given battler index.</summary>
		int GetOwnerIndexFromBattlerIndex(int idxBattler);
		/// <summary>Returns the trainer object that owns the given battler index.</summary>
		IOwner pbGetOwnerFromBattlerIndex(int idxBattler);
		/// <summary>Returns the index of the trainer that owns the given party index.</summary>
		int GetOwnerIndexFromPartyIndex(int idxBattler, int idxParty);
		/// <summary>Returns the trainer object that owns the given party index.</summary>
		IOwner pbGetOwnerFromPartyIndex(int idxBattler, int idxParty);
		/// <summary>Returns the full name of the trainer that owns the given battler index.</summary>
		string GetOwnerName(int idxBattler);
		/// <summary>Returns the items held by the trainer that owns the given battler index.</summary>
		IList<int> GetOwnerItems(int idxBattler);
		/// <summary>Returns true if the battler and party slot are owned by the same trainer.</summary>
		bool IsOwner(int idxBattler, int idxParty);
		/// <summary>Returns true if the battler is owned by the player.</summary>
		bool OwnedByPlayer(int idxBattler);
		/// <summary>Returns the number of Pokémon positions controlled by the given trainer on the given side.</summary>
		int NumPositions(int side, int idxTrainer);
		/// <summary>Returns the party for the given battler index.</summary>
		IPokemon[] pbParty(int idxBattler);
		/// <summary>Returns the opposing party for the given battler index.</summary>
		IPokemon[] pbOpposingParty(int idxBattler);
		/// <summary>Returns the party order for the given battler index.</summary>
		int[] pbPartyOrder(int idxBattler);
		/// <summary>Returns the party start indices for the given battler index.</summary>
		int[] pbPartyStarts(int idxBattler);
		/// <summary>Returns the player's team in display order for the given battler index.</summary>
		IPokemon[] pbPlayerDisplayParty(int idxBattler = 0);
		/// <summary>Returns the number of able Pokémon in the party for the given battler index.</summary>
		int AbleCount(int idxBattler = 0);
		/// <summary>Returns the number of able, non-active Pokémon in the party for the given battler index.</summary>
		int AbleNonActiveCount(int idxBattler = 0);
		/// <summary>Returns true if all Pokémon in the party for the given battler index have fainted.</summary>
		bool AllFainted(int idxBattler = 0);
		/// <summary>Returns the number of able, non-active Pokémon in the team for the given battler index.</summary>
		int pbTeamAbleNonActiveCount(int idxBattler = 0);
		int[] pbAbleTeamCounts(int side);
		IRange pbTeamIndexRangeFromBattlerIndex(int idxBattler);
		int pbTeamLengthFromBattlerIndex(int idxBattler);
		void eachInTeamFromBattlerIndex(int idxBattler, Action<IPokemon, int> action = null);
		void eachInTeam(int side, int idxTrainer, Action<IPokemon, int> action = null);
		/// <summary>Returns the index of the last able Pokémon in the team for Illusion.</summary>
		int LastInTeam(int idxBattler);
		/// <summary>Returns the maximum level in the team for the given side and trainer index.</summary>
		int MaxLevelInTeam(int side, int idxTrainer);
		/// <summary>Iterates through all battlers.</summary>
		void eachBattler(Action<IBattler> action);
		/// <summary>Returns a list of all active battlers.</summary>
		IBattler[] allBattlers();
		/// <summary>Iterates through all same-side battlers for the given battler index.</summary>
		void eachSameSideBattler(int idxBattler = 0, Action<IBattler> action = null);
		/// <summary>Returns a list of all same-side battlers for the given battler index.</summary>
		IBattler[] allSameSideBattlers(int idxBattler = 0);
		/// <summary>Iterates through all other-side battlers for the given battler index.</summary>
		void eachOtherSideBattler(int idxBattler = 0, Action<IBattler> action = null);
		/// <summary>Returns a list of all other-side battlers for the given battler index.</summary>
		IBattler[] allOtherSideBattlers(int idxBattler = 0);
		/// <summary>Returns the number of same-side battlers for the given battler index.</summary>
		int SideBattlerCount(int idxBattler = 0);
		/// <summary>Returns the number of opposing-side battlers for the given battler index.</summary>
		int OpposingBattlerCount(int idxBattler = 0);
		/// <summary>Returns the number of player-owned battlers on the same side.</summary>
		int PlayerBattlerCount();
		/// <summary>Checks for a global ability among all battlers.</summary>
		IBattler pbCheckGlobalAbility(int abil, bool check_mold_breaker = false);
		/// <summary>Checks for an opposing ability among all other-side battlers.</summary>
		IBattler pbCheckOpposingAbility(int abil, int idxBattler = 0, bool nearOnly = false);
		/// <summary>Returns a list of all active abilities among battlers.</summary>
		IList<string> AllActiveAbilities();
		/// <summary>Returns the indices of opposing battlers in order for targeting.</summary>
		IList<int> GetOpposingIndicesInOrder(int idxBattler);
		/// <summary>Returns true if the two battler indices are on opposing sides.</summary>
		bool opposes(int idxBattler1, int idxBattler2 = 0);
		/// <summary>Returns true if the two battler indices are near each other.</summary>
		bool nearBattlers(int idxBattler1, int idxBattler2);
		/// <summary>Removes a Pokémon from the party at the given indices.</summary>
		void pbRemoveFromParty(int idxBattler, int idxParty);
		bool pbSwapBattlers(int idxA, int idxB);
		/// <summary>Finds the battler representing the Pokémon at the given party index.</summary>
		IBattler FindBattler(int idxParty, int idxBattlerOther = 0);
		/// <summary>Returns a display string for the Pokémon at the given indices (used for Wish).</summary>
		string ThisEx(int idxBattler, int idxParty);
		/// <summary>Registers a Pokémon as seen in the Pokédex.</summary>
		void SetSeen(IBattler battler);
		/// <summary>Registers a Pokémon as caught in the Pokédex.</summary>
		void SetCaught(IBattler battler);
		/// <summary>Registers a Pokémon as defeated in the Pokédex.</summary>
		void SetDefeated(IBattler battler);
		/// <summary>Increments and returns the next Pickup use counter.</summary>
		int nextPickupUse();
		/// <summary>Sets the default weather for the battle.</summary>
		int defaultWeather { set; }
		/// <summary>Returns the current effective weather.</summary>
		int pbWeather();
		/// <summary>Starts a new weather effect in battle.</summary>
		void pbStartWeather(IBattler user, int newWeather, bool fixedDuration = false, bool showAnim = true);
		/// <summary>Ends primordial weather effects if present.</summary>
		void EndPrimordialWeather();
		/// <summary>Starts a weather effect due to an ability.</summary>
		void pbStartWeatherAbility(int new_weather, IBattler battler, bool ignore_primal = false);
		/// <summary>Sets the default terrain for the battle.</summary>
		int defaultTerrain { set; }
		/// <summary>Starts a new terrain effect in battle.</summary>
		void pbStartTerrain(IBattler user, int newTerrain, bool fixedDuration = true);
		/// <summary>Displays a message in the battle scene.</summary>
		void Display(string msg, Action block = null);
		/// <summary>Displays a brief message in the battle scene.</summary>
		void DisplayBrief(string msg);
		/// <summary>Displays a paused message in the battle scene.</summary>
		void pbDisplayPaused(string msg, Action block = null);
		bool pbDisplayConfirm(string msg);
		int pbShowCommands(string msg, IList<string> commands, int defaultValue = -1);
		void pbAnimation(IMove move, IBattler user, IList<IBattler> targets, int hitNum = 0);
		void pbCommonAnimation(string name, IBattler user = null, IBattler targets = null);
		void pbShowAbilitySplash(IBattler battler, bool delay = false, bool logTrigger = true);
		void pbHideAbilitySplash(IBattler battler);
		void pbReplaceAbilitySplash(IBattler battler);
	}
}