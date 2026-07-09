using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.EventArg;

namespace PokemonEssentials
{
	namespace EventArg
	{
		#region Item Handlers EventArgs
		public interface IUseFromBagEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(UseFromBagEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			//ItemUseResults Response { get; set; }
			int Response { get; set; }
		}
		public interface IUseInFieldEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(UseInFieldEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			//Action Action { get; set; }
			bool Response { get; set; }
		}
		public interface IUseOnPokemonEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(UseOnPokemonEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			IPokemon Pokemon { get; set; }
			//ICanDisplayMessage Scene { get; set; }
			IPartyDisplayScene Scene { get; set; }
			bool Response { get; set; }
		}
		public interface IBattleUseOnPokemonEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(BattleUseOnPokemonEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			IPokemon Pokemon { get; set; }
			IBattler Battler { get; set; }
			//ICanDisplayMessage Scene { get; set; }
			IPartyDisplayScene Scene { get; set; }
			bool Response { get; set; }
		}
		public interface IBattleUseOnBattlerEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(BattleUseOnBattlerEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			IBattler Battler { get; set; }
			ICanDisplayMessage Scene { get; set; }
			bool Response { get; set; }
		}
		public interface ICanUseInBattleEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(BattleUseOnBattlerEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			int Move { get; set; }
			IBattle Battle { get; set; }
			IBattler Battler { get; set; }
			IPokemon Pokemon { get; set; }
			ICanDisplayMessage Scene { get; set; }
			bool Response { get; set; }
		}
		public interface IUseInBattleEventArgs : IEventArgs
		{
			//readonly int EventId = typeof(UseInBattleEventArgs).GetHashCode();

			//int Id { get { return EventId; } }
			int Item { get; set; }
			IBattler Battler { get; set; }
			IBattle Battle { get; set; }
		}
		#endregion

		public delegate bool UseOnPokemonDelegate(int item, IPokemon pokemon, ICanDisplayMessage scene);
		public delegate bool CanUseInBattleDelegate(int item, IPokemon pkmn, IBattler battler, int move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages = true);
		public delegate void UseInBattleDelegate(int item, IBattler battler, IBattle battle);
		public delegate bool BattleUseOnBattlerDelegate(int item, IBattler battler, IBattleScene scene); //or Pokemon Party Scene
		public delegate bool BattleUseOnPokemonDelegate(IPokemon pokemon, IBattler battler, IBattleScene scene); //or Pokemon Party Scene
	}

	/// <summary>
	/// Interface for item handlers module that manages various item usage scenarios.
	/// </summary>
	public interface IItemHandlers
	{
		/// <summary>
		/// Gets the UseText handler hash.
		/// </summary>
		//IItemHandlerHash UseText { get; }
		IDictionary<int,Action> UseText { get; }

		/// <summary>
		/// Gets the UseFromBag handler hash.
		/// </summary>
		//IItemHandlerHash UseFromBag { get; }
		IDictionary<int,Func<int>> UseFromBag { get; }
		//event EventHandler<IUseFromBagEventArgs> OnUseFromBag;
		event Action<object,IUseFromBagEventArgs> OnUseFromBag;

		/// <summary>
		/// Gets the ConfirmUseInField handler hash.
		/// </summary>
		//IItemHandlerHash ConfirmUseInField { get; }
		IDictionary<int,Action> ConfirmUseInField { get; }

		/// <summary>
		/// Gets the UseInField handler hash.
		/// </summary>
		//IItemHandlerHash UseInField { get; }
		IDictionary<int,Func<int>> UseInField { get; }
		//event EventHandler<IUseInFieldEventArgs> OnUseInField;
		event Action<object,IUseInFieldEventArgs> OnUseInField;

		/// <summary>
		/// Gets the UseOnPokemon handler hash.
		/// </summary>
		//IItemHandlerHash UseOnPokemon { get; }
		//IDictionary<int,UseOnPokemonDelegate> UseOnPokemon { get; }
		IDictionary<int,IUseOnPokemonEventArgs> UseOnPokemon { get; }
		//event EventHandler<IUseOnPokemonEventArgs> OnUseOnPokemon;
		event Action<object,IUseOnPokemonEventArgs> OnUseOnPokemon;

		/// <summary>
		/// Gets the UseOnPokemonMaximum handler hash.
		/// </summary>
		//IItemHandlerHash UseOnPokemonMaximum { get; }
		IDictionary<int,IUseOnPokemonEventArgs> UseOnPokemonMaximum { get; }
		//event EventHandler<IUseOnPokemonEventArgs> OnUseOnPokemonMaximum;
		event Action<object,IUseOnPokemonEventArgs> OnUseOnPokemonMaximum;

		/// <summary>
		/// Gets the CanUseInBattle handler hash.
		/// </summary>
		//IItemHandlerHash CanUseInBattle { get; }
		IDictionary<int,ICanUseInBattleEventArgs> CanUseInBattle { get; }
		//event EventHandler<ICanUseInBattleEventArgs> OnCanUseInBattle;
		event Action<object,ICanUseInBattleEventArgs> OnCanUseInBattle;

		/// <summary>
		/// Gets the UseInBattle handler hash.
		/// </summary>
		//IItemHandlerHash UseInBattle { get; }
		//IDictionary<int,UseInBattleDelegate> UseInBattle { get; }
		IDictionary<int,IUseInBattleEventArgs> UseInBattle { get; }
		//event EventHandler<IUseInBattleEventArgs> OnUseInBattle;
		event Action<object,IUseInBattleEventArgs> OnUseInBattle;

		/// <summary>
		/// Gets the BattleUseOnBattler handler hash.
		/// </summary>
		//IItemHandlerHash BattleUseOnBattler { get; }
		//IDictionary<int,BattleUseOnBattlerDelegate> BattleUseOnBattler { get; }
		IDictionary<int,IBattleUseOnBattlerEventArgs> BattleUseOnBattler { get; }
		//event EventHandler<IBattleUseOnBattlerEventArgs> OnBattleUseOnBattler;
		event Action<object,IBattleUseOnBattlerEventArgs> OnBattleUseOnBattler;

		/// <summary>
		/// Gets the BattleUseOnPokemon handler hash.
		/// </summary>
		//IItemHandlerHash BattleUseOnPokemon { get; }
		//IDictionary<int,BattleUseOnPokemonDelegate> BattleUseOnPokemon { get; }
		IDictionary<int,IBattleUseOnPokemonEventArgs> BattleUseOnPokemon { get; }
		//event EventHandler<IBattleUseOnPokemonEventArgs> OnBattleUseOnPokemon;
		event Action<object,IBattleUseOnPokemonEventArgs> OnBattleUseOnPokemon;

		/// <summary>
		/// Checks if an item has custom use text.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item has custom use text</returns>
		bool hasUseText(int item);

		/// <summary>
		/// Checks if an item shows "Use" option in Bag.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used from bag</returns>
		bool hasOutHandler(int item);

		/// <summary>
		/// Checks if an item shows "Register" option in Bag.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be registered</returns>
		bool hasUseInFieldHandler(int item);

		/// <summary>
		/// Checks if an item can be used on a Pokémon.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used on Pokémon</returns>
		bool hasUseOnPokemon(int item);

		/// <summary>
		/// Checks if an item has a maximum usage limit on Pokémon.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item has a usage limit</returns>
		bool hasUseOnPokemonMaximum(int item);

		/// <summary>
		/// Checks if an item can be used in battle.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used in battle</returns>
		bool hasUseInBattle(int item);

		/// <summary>
		/// Checks if an item can be used on a battler in battle.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used on battlers</returns>
		bool hasBattleUseOnBattler(int item);

		/// <summary>
		/// Checks if an item can be used on a Pokémon in battle.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used on Pokémon in battle</returns>
		bool hasBattleUseOnPokemon(int item);

		/// <summary>
		/// Gets custom use text for an item instead of "Use".
		/// </summary>
		/// <remarks>
		/// Returns text to display instead of "Use".
		/// </remarks>
		/// <param name="item">The item</param>
		/// <returns>Custom use text or null</returns>
		string getUseText(int item);

		/// <summary>
		/// Triggers using an item from the bag.
		/// </summary>
		/// <remarks>
		/// Return value:
		/// 0 - Item not used
		/// 1 - Item used, don't end screen
		/// 2 - Item used, end screen
		/// </remarks>
		/// <param name="item">The item to use</param>
		/// <returns>0=not used, 1=used don't end screen, 2=used end screen</returns>
		int triggerUseFromBag(int item);

		/// <summary>
		/// Checks if item usage in field should be confirmed.
		/// </summary>
		/// <remarks>
		/// Returns whether item can be used.
		/// </remarks>
		/// <param name="item">The item</param>
		/// <returns>True if usage can proceed</returns>
		bool triggerConfirmUseInField(int item);

		/// <summary>
		/// Triggers using an item in the field.
		/// </summary>
		/// <remarks>
		/// Return value:
		/// -1 - Item effect not found
		/// 0  - Item not used
		/// 1  - Item used
		/// </remarks>
		/// <param name="item">The item to use</param>
		/// <returns>-1=not found, 0=not used, 1=used</returns>
		int triggerUseInField(int item);

		/// <summary>
		/// Triggers using an item on a Pokémon.
		/// </summary>
		/// <remarks>
		/// Returns whether item was used.
		/// </remarks>
		/// <param name="item">The item to use</param>
		/// <param name="qty">Quantity to use</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if item was used</returns>
		bool triggerUseOnPokemon(int item, int qty, IPokemon pkmn, ICanDisplayMessage scene);

		/// <summary>
		/// Gets the maximum number of items that can be used on a Pokémon at once.
		/// </summary>
		/// <remarks>
		/// Returns the maximum number of the item that can be used on the Pokémon at once.
		/// </remarks>
		/// <param name="item">The item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <returns>Maximum quantity</returns>
		int triggerUseOnPokemonMaximum(int item, IPokemon pkmn);

		/// <summary>
		/// Checks if an item can be used in battle with full context.
		/// </summary>
		/// <param name="item">The item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="battler">The battler</param>
		/// <param name="move">The move</param>
		/// <param name="firstAction">Whether this is the first action</param>
		/// <param name="battle">The battle instance</param>
		/// <param name="scene">The battle scene</param>
		/// <param name="showMessages">Whether to show messages</param>
		/// <returns>True if the item can be used</returns>
		bool triggerCanUseInBattle(int item, IPokemon pkmn, IBattler battler, int move, bool firstAction, IBattle battle, IBattleScene scene, bool showMessages = true);

		/// <summary>
		/// Triggers using an item in battle.
		/// </summary>
		/// <param name="item">The item</param>
		/// <param name="battler">The battler</param>
		/// <param name="battle">The battle instance</param>
		void triggerUseInBattle(int item, IBattler battler, IBattle battle);

		/// <summary>
		/// Triggers using an item on a battler in battle.
		/// </summary>
		/// <param name="item">The item</param>
		/// <param name="battler">The battler</param>
		/// <param name="scene">The battle scene</param>
		/// <returns>True if item was used</returns>
		bool triggerBattleUseOnBattler(int item, IBattler battler, IBattleScene scene);

		/// <summary>
		/// Triggers using an item on a Pokémon in battle.
		/// </summary>
		/// <param name="item">The item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="battler">The battler</param>
		/// <param name="choices">Battle choices</param>
		/// <param name="scene">The battle scene</param>
		/// <returns>True if item was used</returns>
		bool triggerBattleUseOnPokemon(int item, IPokemon pkmn, IBattler battler, IBattleChoice choices, IBattleScene scene);
	}

	//public enum ItemUseResults
	//{
	//	/// <summary>
	//	/// not used
	//	/// </summary>
	//	NotUsed = 0,
	//	/// <summary>
	//	/// used, item not consumed
	//	/// </summary>
	//	UsedNotConsumed = 1,
	//	/// <summary>
	//	/// close the Bag to use, item not consumed
	//	/// </summary>
	//	CloseBagNotConsumed = 2,
	//	/// <summary>
	//	/// used, item consumed
	//	/// </summary>
	//	UsedItemConsumed = 3,
	//	/// <summary>
	//	/// close the Bag to use, item consumed
	//	/// </summary>
	//	CloseBagItemConsumed = 4
	//}

	/// <summary>
	/// Interface for basic item utility functions.
	/// </summary>
	public interface IMainItemUtilities : IMain
	{
		/// <summary>
		/// Checks if an item can be registered for quick use.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be registered</returns>
		bool CanRegisterItem(int item);

		/// <summary>
		/// Checks if an item can be used on a Pokémon.
		/// </summary>
		/// <param name="item">The item to check</param>
		/// <returns>True if the item can be used on Pokémon</returns>
		bool CanUseOnPokemon(int item);
	//}

	/// <summary>
	/// Interface for Pokémon level changing functions.
	/// </summary>
	//public interface IPokemonLevelChanger
	//{
		/// <summary>
		/// Change a Pokémon's level.
		/// </summary>
		/// <remarks>
		/// Changes a Pokémon's level and handles all related effects.
		/// </remarks>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="new_level">The new level</param>
		/// <param name="scene">The scene</param>
		void ChangeLevel(IPokemon pkmn, int new_level, IScene scene);

		/// <summary>
		/// Shows a top-right window with text.
		/// </summary>
		/// <param name="text">Text to display</param>
		/// <param name="scene">Optional scene</param>
		void TopRightWindow(string text, IScene scene = null);

		/// <summary>
		/// Changes a Pokémon's experience points and handles level changes.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="new_exp">The new experience amount</param>
		/// <param name="scene">The scene</param>
		void ChangeExp(IPokemon pkmn, int new_exp, IScene scene);

		/// <summary>
		/// Gives experience from Exp Candy items.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="base_amt">Base experience amount</param>
		/// <param name="qty">Quantity of candies</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if experience was gained</returns>
		bool GainExpFromExpCandy(IPokemon pkmn, int base_amt, int qty, IScene scene);
	//}

	/// <summary>
	/// Interface for HP restoration functions.
	/// </summary>
	//public interface IHPRestoration
	//{
		/// <summary>
		/// Restores HP to a Pokémon.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="restoreHP">Amount of HP to restore</param>
		/// <returns>Actual HP gained</returns>
		int ItemRestoreHP(IPokemon pkmn, int restoreHP);

		/// <summary>
		/// Uses an HP restoration item on a Pokémon.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="restoreHP">Amount of HP to restore</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if item was used successfully</returns>
		bool HPItem(IPokemon pkmn, int restoreHP, IScene scene);

		/// <summary>
		/// Uses an HP restoration item in battle.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="battler">The battler (if in battle)</param>
		/// <param name="restoreHP">Amount of HP to restore</param>
		/// <param name="scene">The battle scene</param>
		/// <returns>True if item was used successfully</returns>
		bool BattleHPItem(IPokemon pkmn, IBattler battler, int restoreHP, IScene scene);
	//}

	/// <summary>
	/// Interface for PP restoration functions.
	/// </summary>
	//public interface IPPRestoration
	//{
		/// <summary>
		/// Restores PP to a specific move.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="idxMove">Index of the move</param>
		/// <param name="pp">Amount of PP to restore</param>
		/// <returns>Actual PP restored</returns>
		int RestorePP(IPokemon pkmn, int idxMove, int pp);

		/// <summary>
		/// Restores PP to a move in battle context.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="battler">The battler</param>
		/// <param name="idxMove">Index of the move</param>
		/// <param name="pp">Amount of PP to restore</param>
		void BattleRestorePP(IPokemon pkmn, IBattler battler, int idxMove, int pp);
	//}

	/// <summary>
	/// Interface for EV (Effort Value) manipulation functions.
	/// </summary>
	//public interface IEVManipulation
	//{
		/// <summary>
		/// Raises effort values without applying the 100 EV limit.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="stat">The stat to raise</param>
		/// <param name="evGain">Amount of EVs to gain</param>
		/// <returns>Actual EVs gained</returns>
		int JustRaiseEffortValues(IPokemon pkmn, int stat, int evGain);

		/// <summary>
		/// Raises effort values with optional cap enforcement.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="stat">The stat to raise</param>
		/// <param name="evGain">Amount of EVs to gain</param>
		/// <param name="no_ev_cap">Whether to ignore the 100 EV limit</param>
		/// <returns>Actual EVs gained</returns>
		int RaiseEffortValues(IPokemon pkmn, int stat, int evGain = 10, bool no_ev_cap = false);

		/// <summary>
		/// Calculates maximum uses of an EV raising item.
		/// </summary>
		/// <param name="stat">The stat</param>
		/// <param name="amt_per_use">Amount gained per use</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="no_ev_cap">Whether to ignore the 100 EV limit</param>
		/// <returns>Maximum number of uses</returns>
		int MaxUsesOfEVRaisingItem(int stat, int amt_per_use, IPokemon pkmn, bool no_ev_cap = false);

		/// <summary>
		/// Uses an EV raising item multiple times.
		/// </summary>
		/// <param name="stat">The stat to raise</param>
		/// <param name="amt_per_use">Amount gained per use</param>
		/// <param name="qty">Number of times to use</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="happiness_type">Type of happiness change</param>
		/// <param name="scene">The scene</param>
		/// <param name="no_ev_cap">Whether to ignore the 100 EV limit</param>
		/// <returns>True if any EVs were gained</returns>
		bool UseEVRaisingItem(int stat, int amt_per_use, int qty, IPokemon pkmn, int happiness_type, IScene scene, bool no_ev_cap = false);

		/// <summary>
		/// Calculates maximum uses of an EV lowering berry.
		/// </summary>
		/// <param name="stat">The stat</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <returns>Maximum number of uses</returns>
		int MaxUsesOfEVLoweringBerry(int stat, IPokemon pkmn);

		/// <summary>
		/// Raises happiness and lowers EVs (berry effect).
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <param name="stat">The stat to lower</param>
		/// <param name="qty">Number of berries</param>
		/// <param name="messages">Messages to display</param>
		/// <returns>True if the berry had an effect</returns>
		bool RaiseHappinessAndLowerEV(IPokemon pkmn, IScene scene, int stat, int qty, string[] messages);
	//}

	/// <summary>
	/// Interface for nature changing functions.
	/// </summary>
	//public interface INatureChanger
	//{
		/// <summary>
		/// Changes a Pokémon's nature using a mint.
		/// </summary>
		/// <param name="new_nature">The new nature</param>
		/// <param name="item">The mint item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if nature was changed</returns>
		bool NatureChangingMint(int new_nature, int item, IPokemon pkmn, IScene scene);
	//}

	/// <summary>
	/// Interface for battle item functions.
	/// </summary>
	//public interface IBattleItemHelpers
	//{
		/// <summary>
		/// Checks if an item can cure a specific status condition.
		/// </summary>
		/// <param name="status">The status to cure</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <param name="showMessages">Whether to show messages</param>
		/// <returns>True if the item can cure the status</returns>
		bool BattleItemCanCureStatus(int status, IPokemon pkmn, IScene scene, bool showMessages);

		/// <summary>
		/// Checks if an item can raise a battler's stat.
		/// </summary>
		/// <param name="stat">The stat to raise</param>
		/// <param name="battler">The battler</param>
		/// <param name="scene">The scene</param>
		/// <param name="showMessages">Whether to show messages</param>
		/// <returns>True if the stat can be raised</returns>
		bool BattleItemCanRaiseStat(int stat, IBattler battler, IScene scene, bool showMessages);
	//}

	/// <summary>
	/// Interface for bicycle usage functions.
	/// </summary>
	//public interface IBicycleChecker
	//{
		/// <summary>
		/// Checks whether the player can ride or dismount their bicycle.
		/// </summary>
		/// <returns>True if bicycle usage is allowed</returns>
		bool BikeCheck();
	//}

	/// <summary>
	/// Interface for hidden item finder functions.
	/// </summary>
	//public interface IHiddenItemFinder
	//{
		/// <summary>
		/// Finds the closest hidden item (for Itemfinder).
		/// </summary>
		/// <returns>The closest hidden item event or null</returns>
		int ClosestHiddenItem();
	//}

	/// <summary>
	/// Interface for move learning functions.
	/// </summary>
	//public interface IMoveTeacher
	//{
		/// <summary>
		/// Teaches a move to a Pokémon.
		/// </summary>
		/// <remarks>
		/// Teach and forget a move.
		/// </remarks>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="move">The move to learn</param>
		/// <param name="ignore_if_known">Whether to ignore if already known</param>
		/// <param name="by_machine">Whether taught by a machine</param>
		/// <returns>True if the move was learned</returns>
		bool LearnMove(IPokemon pkmn, int move, bool ignore_if_known = false, bool by_machine = false);

		/// <summary>
		/// Opens the move forgetting interface.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="moveToLearn">The move to learn</param>
		/// <returns>Index of the move to forget, or -1</returns>
		int ForgetMove(IPokemon pkmn, int moveToLearn);
	//}

	/// <summary>
	/// Interface for item usage functions.
	/// </summary>
	//public interface IItemUsage
	//{
		/// <summary>
		/// Uses an item from the bag.
		/// </summary>
		/// <remarks>
		/// Use an item from the Bag and/or on a Pokémon.
		/// </remarks>
		/// <param name="bag">The bag</param>
		/// <param name="item">The item to use</param>
		/// <param name="bagscene">The bag scene</param>
		/// <returns>0=not used, 1=used, 2=close bag</returns>
		int UseItem(IGameBag bag, int item, IBagScene bagscene = null);

		/// <summary>
		/// Uses an item on a specific Pokémon.
		/// </summary>
		/// <remarks>
		/// Only called when in the party screen and having chosen an item to be used on
		/// the selected Pokémon.
		/// </remarks>
		/// <param name="item">The item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if item was used</returns>
		bool UseItemOnPokemon(int item, IPokemon pkmn, IScene scene);

		/// <summary>
		/// Uses a key item in the field.
		/// </summary>
		/// <param name="item">The key item</param>
		/// <returns>True if item was used</returns>
		bool UseKeyItemInField(int item);

		/// <summary>
		/// Shows the standard item usage message.
		/// </summary>
		/// <param name="item">The item</param>
		void UseItemMessage(int item);

		/// <summary>
		/// Checks if an item can be used on a Pokémon.
		/// </summary>
		/// <param name="item">The item</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="screen">The screen</param>
		/// <returns>True if usage is allowed</returns>
		bool CheckUseOnPokemon(int item, IPokemon pkmn, object screen);
	//}

	/// <summary>
	/// Interface for item giving and taking functions.
	/// </summary>
	//public interface IItemManagement
	//{
		/// <summary>
		/// Gives an item to a Pokémon to hold.
		/// </summary>
		/// <remarks>
		/// Give an item to a Pokémon to hold, and take a held item from a Pokémon.
		/// </remarks>
		/// <param name="item">The item to give</param>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <param name="pkmnid">The Pokémon ID for mail</param>
		/// <returns>True if item was given</returns>
		bool GiveItemToPokemon(int item, IPokemon pkmn, IScene scene, int pkmnid = 0);

		/// <summary>
		/// Takes a held item from a Pokémon.
		/// </summary>
		/// <param name="pkmn">The Pokémon</param>
		/// <param name="scene">The scene</param>
		/// <returns>True if item was taken</returns>
		bool TakeItemFromPokemon(IPokemon pkmn, IScene scene);
	//}

	/// <summary>
	/// Interface for item choosing functions.
	/// </summary>
	//public interface IItemChooser
	//{
		/// <summary>
		/// Opens the bag to choose an item.
		/// </summary>
		/// <param name="var">Variable to store the result</param>
		/// <param name="args">Additional arguments</param>
		/// <returns>The chosen item or null</returns>
		int ChooseItem(int var = 0, params object[] args);

		/// <summary>
		/// Opens the bag to choose an apricorn.
		/// </summary>
		/// <param name="var">Variable to store the result</param>
		/// <returns>The chosen apricorn or null</returns>
		int ChooseApricorn(int var = 0);

		/// <summary>
		/// Opens the bag to choose a fossil.
		/// </summary>
		/// <param name="var">Variable to store the result</param>
		/// <returns>The chosen fossil or null</returns>
		int ChooseFossil(int var = 0);

		/// <summary>
		/// Shows a list of specific items for the player to choose from.
		/// </summary>
		/// <remarks>
		/// Shows a list of items to choose from, with the chosen item's ID being stored
		/// in the given Game Variable. Only items which the player has are listed.
		/// </remarks>
		/// <param name="message">Message to display</param>
		/// <param name="variable">Variable to store the result</param>
		/// <param name="args">Items to choose from</param>
		/// <returns>The chosen item or null</returns>
		int ChooseItemFromList(string message, int variable, params object[] args);
	}
}