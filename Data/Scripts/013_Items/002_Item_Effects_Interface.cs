using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for item effect handler system.
	/// Manages various item usage effects including use text, bag usage,
	/// field usage, and confirmation handlers for different item types.
	/// </summary>
	//public interface IItemEffectHandlers
	//{
	//	/// <summary>Use text handlers for displaying item action text.</summary>
	//	IItemUseTextHandlers useTextHandlers { get; }
	//
	//	/// <summary>Use from bag handlers for bag-based item usage.</summary>
	//	IItemUseFromBagHandlers useFromBagHandlers { get; }
	//
	//	/// <summary>Confirm use in field handlers for ready menu usage.</summary>
	//	IItemConfirmUseInFieldHandlers confirmUseInFieldHandlers { get; }
	//
	//	/// <summary>Use in field handlers for overworld item usage.</summary>
	//	IItemUseInFieldHandlers useInFieldHandlers { get; }
	//
	//	/// <summary>Battle use on Pokemon handlers for battle item usage.</summary>
	//	IItemBattleUseOnPokemonHandlers battleUseOnPokemonHandlers { get; }
	//
	//	/// <summary>Battle use on battler handlers for battle targeting.</summary>
	//	IItemBattleUseOnBattlerHandlers battleUseOnBattlerHandlers { get; }
	//
	//	/// <summary>Use on Pokemon handlers for Pokemon-targeted usage.</summary>
	//	IItemUseOnPokemonHandlers useOnPokemonHandlers { get; }
	//
	//	/// <summary>
	//	/// Initializes item effect handler system.
	//	/// Sets up all handler categories and default implementations.
	//	/// </summary>
	//	void initialize();
	//
	//	/// <summary>
	//	/// Registers custom item effect handler.
	//	/// Adds new handler for specific item effect category.
	//	/// </summary>
	//	/// <param name="category">Handler category type</param>
	//	/// <param name="item">Item to register handler for</param>
	//	/// <param name="handler">Handler function</param>
	//	void registerHandler(ItemHandlerCategory category, int item, System.Delegate handler);
	//
	//	/// <summary>
	//	/// Copies handler from one item to others.
	//	/// Reuses existing handler implementation for multiple items.
	//	/// </summary>
	//	/// <param name="category">Handler category type</param>
	//	/// <param name="sourceItem">Item with existing handler</param>
	//	/// <param name="targetItems">Items to copy handler to</param>
	//	void copyHandler(ItemHandlerCategory category, IItem sourceItem, params IItem[] targetItems);
	//}
	/*
	/// <summary>
	/// Interface for item use text handler system.
	/// Manages display text for item actions in menus and interfaces,
	/// providing context-appropriate action descriptions.
	/// </summary>
	public interface IItemUseTextHandlers
	{
		/// <summary>
		/// Gets use text for bicycle items.
		/// Returns "Walk" if bicycle is active, "Use" if not.
		/// </summary>
		/// <param name="item">Bicycle item</param>
		/// <returns>Appropriate action text</returns>
		string getBicycleUseText(int item);

		/// <summary>
		/// Gets use text for Exp. Share items.
		/// Returns "Turn on" for OFF state, "Turn off" for ON state.
		/// </summary>
		/// <param name="item">Exp. Share item</param>
		/// <returns>Appropriate toggle text</returns>
		string getExpShareUseText(int item);

		/// <summary>
		/// Gets generic use text for item.
		/// Returns default "Use" text for most items.
		/// </summary>
		/// <param name="item">Item to get text for</param>
		/// <returns>Default use text</returns>
		string getGenericUseText(int item);

		/// <summary>
		/// Registers use text handler for item.
		/// Associates custom text handler with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Text generation function</param>
		void registerUseTextHandler(int item, System.Func<IItem, string> handler);
	}

	/// <summary>
	/// Interface for use from bag handler system.
	/// Manages item usage when selected from the bag interface,
	/// determining usage behavior and screen transitions.
	/// </summary>
	public interface IItemUseFromBagHandlers
	{
		/// <summary>
		/// Handles honey usage from bag.
		/// Returns 2 to close bag and use in field.
		/// </summary>
		/// <param name="item">Honey item</param>
		/// <returns>Usage result code</returns>
		int handleHoneyUsage(int item);

		/// <summary>
		/// Handles escape rope usage from bag.
		/// Checks for escape point availability and follower restrictions.
		/// </summary>
		/// <param name="item">Escape rope item</param>
		/// <returns>Usage result code (0=not used, 2=use in field)</returns>
		int handleEscapeRopeUsage(int item);

		/// <summary>
		/// Handles bicycle usage from bag.
		/// Checks if bicycle can be used in current location.
		/// </summary>
		/// <param name="item">Bicycle item</param>
		/// <returns>Usage result code (0=not used, 2=use in field)</returns>
		int handleBicycleUsage(int item);

		/// <summary>
		/// Handles fishing rod usage from bag.
		/// Checks if current location supports fishing.
		/// </summary>
		/// <param name="item">Fishing rod item</param>
		/// <returns>Usage result code (0=not used, 2=use in field)</returns>
		int handleFishingRodUsage(int item);

		/// <summary>
		/// Handles item finder usage from bag.
		/// Returns 2 to close bag and use in field.
		/// </summary>
		/// <param name="item">Item finder device</param>
		/// <returns>Usage result code</returns>
		int handleItemFinderUsage(int item);

		/// <summary>
		/// Handles town map usage from bag.
		/// Opens region map interface for viewing and flying.
		/// </summary>
		/// <param name="item">Town map item</param>
		/// <returns>Usage result code</returns>
		int handleTownMapUsage(int item);

		/// <summary>
		/// Handles move machine (TM/TR) usage from bag.
		/// Opens move tutor interface for teaching moves.
		/// </summary>
		/// <param name="item">Move machine item</param>
		/// <returns>Usage result code (0=not used, 1=used)</returns>
		int handleMoveMachineUsage(int item);

		/// <summary>
		/// Registers use from bag handler for item.
		/// Associates custom bag usage handler with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Usage function returning result code</param>
		void registerUseFromBagHandler(int item, System.Func<IItem, int> handler);
	}

	/// <summary>
	/// Interface for confirm use in field handler system.
	/// Manages confirmation dialogs for items used from ready menu,
	/// preventing accidental usage of important items.
	/// </summary>
	public interface IItemConfirmUseInFieldHandlers
	{
		/// <summary>
		/// Confirms bicycle usage in field.
		/// Checks if bicycle can be mounted/dismounted at current location.
		/// </summary>
		/// <param name="item">Bicycle item</param>
		/// <returns>True if usage is confirmed</returns>
		bool confirmBicycleUsage(int item);

		/// <summary>
		/// Confirms escape rope usage in field.
		/// Verifies escape point is available and no restrictions apply.
		/// </summary>
		/// <param name="item">Escape rope item</param>
		/// <returns>True if usage is confirmed</returns>
		bool confirmEscapeRopeUsage(int item);

		/// <summary>
		/// Confirms repel usage in field.
		/// Checks if repel effect is needed and can be applied.
		/// </summary>
		/// <param name="item">Repel item</param>
		/// <returns>True if usage is confirmed</returns>
		bool confirmRepelUsage(int item);

		/// <summary>
		/// Default confirmation for most items.
		/// Returns true unless specific restrictions apply.
		/// </summary>
		/// <param name="item">Item to confirm usage for</param>
		/// <returns>True if usage is confirmed</returns>
		bool defaultConfirmUsage(int item);

		/// <summary>
		/// Registers confirm use handler for item.
		/// Associates custom confirmation logic with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Confirmation function</param>
		void registerConfirmHandler(int item, System.Func<IItem, bool> handler);
	}

	/// <summary>
	/// Interface for use in field handler system.
	/// Manages item effects when used in the overworld field,
	/// handling various field-specific item behaviors.
	/// </summary>
	public interface IItemUseInFieldHandlers
	{
		/// <summary>
		/// Handles repel usage in field.
		/// Activates repel effect to prevent wild encounters.
		/// </summary>
		/// <param name="item">Repel item</param>
		/// <returns>True if item was consumed</returns>
		bool handleRepelUsage(int item);

		/// <summary>
		/// Handles honey usage in field.
		/// Spreads honey on sweet-scented trees for encounters.
		/// </summary>
		/// <param name="item">Honey item</param>
		/// <returns>True if item was consumed</returns>
		bool handleHoneyFieldUsage(int item);

		/// <summary>
		/// Handles escape rope usage in field.
		/// Teleports player to escape point if available.
		/// </summary>
		/// <param name="item">Escape rope item</param>
		/// <returns>True if item was consumed</returns>
		bool handleEscapeRopeFieldUsage(int item);

		/// <summary>
		/// Handles bicycle usage in field.
		/// Mounts or dismounts bicycle based on current state.
		/// </summary>
		/// <param name="item">Bicycle item</param>
		/// <returns>True if state was changed</returns>
		bool handleBicycleFieldUsage(int item);

		/// <summary>
		/// Handles fishing rod usage in field.
		/// Initiates fishing encounter at current location.
		/// </summary>
		/// <param name="item">Fishing rod item</param>
		/// <returns>True if fishing was initiated</returns>
		bool handleFishingRodFieldUsage(int item);

		/// <summary>
		/// Registers use in field handler for item.
		/// Associates custom field usage logic with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Field usage function</param>
		void registerFieldUsageHandler(int item, System.Func<IItem, bool> handler);
	}

	/// <summary>
	/// Interface for battle use on Pokemon handler system.
	/// Manages item usage targeting specific Pokemon during battles,
	/// including healing items, status items, and enhancement items.
	/// </summary>
	public interface IItemBattleUseOnPokemonHandlers
	{
		/// <summary>
		/// Handles healing item usage on Pokemon in battle.
		/// Restores HP based on item's healing properties.
		/// </summary>
		/// <param name="item">Healing item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if item was successfully used</returns>
		bool handleHealingItemUsage(int item, IPokemon pokemon, IBattleScene scene);

		/// <summary>
		/// Handles status cure item usage on Pokemon in battle.
		/// Cures status conditions based on item properties.
		/// </summary>
		/// <param name="item">Status cure item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if status was cured</returns>
		bool handleStatusCureUsage(int item, IPokemon pokemon, IBattleScene scene);

		/// <summary>
		/// Handles PP restoration item usage on Pokemon in battle.
		/// Restores PP for moves based on item type.
		/// </summary>
		/// <param name="item">PP restoration item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if PP was restored</returns>
		bool handlePPRestorationUsage(int item, IPokemon pokemon, IBattleScene scene);

		/// <summary>
		/// Registers battle use on Pokemon handler for item.
		/// Associates custom battle usage logic with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Battle usage function</param>
		void registerBattleUsageHandler(int item, System.Func<IItem, IPokemon, IBattleScene, bool> handler);
	}

	/// <summary>
	/// Interface for battle use on battler handler system.
	/// Manages item usage targeting active battlers during combat,
	/// including stat boost items and temporary effect items.
	/// </summary>
	public interface IItemBattleUseOnBattlerHandlers
	{
		/// <summary>
		/// Handles X item usage on battler.
		/// Applies temporary stat boosts during battle.
		/// </summary>
		/// <param name="item">X stat item</param>
		/// <param name="battler">Target battler</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if stat was boosted</returns>
		bool handleXItemUsage(int item, IBattler battler, IBattleScene scene);

		/// <summary>
		/// Handles guard spec usage on battler.
		/// Prevents stat reduction for several turns.
		/// </summary>
		/// <param name="item">Guard spec item</param>
		/// <param name="battler">Target battler</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if effect was applied</returns>
		bool handleGuardSpecUsage(int item, IBattler battler, IBattleScene scene);

		/// <summary>
		/// Handles dire hit usage on battler.
		/// Increases critical hit ratio for several turns.
		/// </summary>
		/// <param name="item">Dire hit item</param>
		/// <param name="battler">Target battler</param>
		/// <param name="scene">Battle scene for display</param>
		/// <returns>True if effect was applied</returns>
		bool handleDireHitUsage(int item, IBattler battler, IBattleScene scene);

		/// <summary>
		/// Registers battle use on battler handler for item.
		/// Associates custom battler targeting logic with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Battler usage function</param>
		void registerBattlerUsageHandler(int item, System.Func<IItem, IBattler, IBattleScene, bool> handler);
	}

	/// <summary>
	/// Interface for use on Pokemon handler system.
	/// Manages item usage targeting Pokemon outside of battle,
	/// including healing, evolution, and enhancement items.
	/// </summary>
	public interface IItemUseOnPokemonHandlers
	{
		/// <summary>
		/// Handles healing item usage on Pokemon.
		/// Restores HP outside of battle situations.
		/// </summary>
		/// <param name="item">Healing item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <returns>True if item was successfully used</returns>
		bool handleOutOfBattleHealing(int item, IPokemon pokemon);

		/// <summary>
		/// Handles evolution stone usage on Pokemon.
		/// Triggers evolution if Pokemon is compatible.
		/// </summary>
		/// <param name="item">Evolution stone</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <returns>True if evolution occurred</returns>
		bool handleEvolutionStoneUsage(int item, IPokemon pokemon);

		/// <summary>
		/// Handles vitamin usage on Pokemon.
		/// Increases base stats permanently.
		/// </summary>
		/// <param name="item">Vitamin item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <returns>True if stat was increased</returns>
		bool handleVitaminUsage(int item, IPokemon pokemon);

		/// <summary>
		/// Handles rare candy usage on Pokemon.
		/// Increases Pokemon level by one.
		/// </summary>
		/// <param name="item">Rare candy item</param>
		/// <param name="pokemon">Target Pokemon</param>
		/// <returns>True if level was increased</returns>
		bool handleRareCandyUsage(int item, IPokemon pokemon);

		/// <summary>
		/// Registers use on Pokemon handler for item.
		/// Associates custom Pokemon targeting logic with specific item.
		/// </summary>
		/// <param name="item">Item to register handler for</param>
		/// <param name="handler">Pokemon usage function</param>
		void registerPokemonUsageHandler(int item, System.Func<IItem, IPokemon, bool> handler);
	}
	*/
	/// <summary>
	/// Enumeration for item handler categories.
	/// Categorizes different types of item effect handlers for organization.
	/// </summary>
	public enum ItemHandlerCategory
	{
		/// <summary>Use text display handlers.</summary>
		UseText,

		/// <summary>Use from bag interface handlers.</summary>
		UseFromBag,

		/// <summary>Confirm use in field handlers.</summary>
		ConfirmUseInField,

		/// <summary>Use in field handlers.</summary>
		UseInField,

		/// <summary>Battle use on Pokemon handlers.</summary>
		BattleUseOnPokemon,

		/// <summary>Battle use on battler handlers.</summary>
		BattleUseOnBattler,

		/// <summary>Use on Pokemon handlers.</summary>
		UseOnPokemon
	}
}