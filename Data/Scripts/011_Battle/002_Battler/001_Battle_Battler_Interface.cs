using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for the Battle::Battler class, representing a battler in a Pokémon battle.
	/// </summary>
	public interface IBattler
	{
		// Fundamental to this object
		/// <summary>Reference to the battle this battler is part of.</summary>
		IBattle battle { get; }
		/// <summary>The index of this battler in the battle.</summary>
		int index { get; set; }
		// The Pokémon and its properties
		/// <summary>The Pokémon instance this battler represents.</summary>
		IPokemon pokemon { get; }
		/// <summary>The index of the Pokémon in the party.</summary>
		int pokemonIndex { get; set; }
		/// <summary>The species ID of the Pokémon.</summary>
		int species { get; set; }
		/// <summary>The types of the Pokémon.</summary>
		IList<int> types { get; set; }
		/// <summary>The ability ID of the Pokémon.</summary>
		int ability_id { get; set; }
		/// <summary>The item ID held by the Pokémon.</summary>
		int item_id { get; set; }
		/// <summary>The moves known by the Pokémon.</summary>
		IList<IMove> moves { get; set; }
		/// <summary>The attack stat.</summary>
		int attack { get; set; }
		/// <summary>The special attack stat.</summary>
		int spatk { get; set; }
		/// <summary>The speed stat.</summary>
		int speed { get; set; }
		/// <summary>The stat stages for this battler.</summary>
		IDictionary<int, int> stages { get; set; }
		/// <summary>The total HP of the Pokémon.</summary>
		int totalhp { get; }
		/// <summary>Whether the battler has fainted.</summary>
		bool fainted { get; }
		/// <summary>Whether the battler was captured.</summary>
		bool captured { get; set; }
		/// <summary>Whether this is a dummy battler (used for Future Sight, etc.).</summary>
		bool dummy { get; }
		/// <summary>Effects currently applied to this battler.</summary>
		//IDictionary<int, object> effects { get; set; }
		IEffectsPosition effects { get; set; }
		// Things the battler has done in battle
		/// <summary>The number of turns this battler has been active.</summary>
		int turnCount { get; set; }
		/// <summary>Participants in the battle (for Exp. gain).</summary>
		IList<int> participants { get; set; }
		/// <summary>List of last attackers (by battler index).</summary>
		IList<int> lastAttacker { get; set; }
		/// <summary>List of last foe attackers (by battler index).</summary>
		IList<int> lastFoeAttacker { get; set; }
		/// <summary>Last HP lost.</summary>
		int lastHPLost { get; set; }
		/// <summary>Last HP lost from a foe.</summary>
		int lastHPLostFromFoe { get; set; }
		/// <summary>Last move used.</summary>
		IMove lastMoveUsed { get; set; }
		/// <summary>Type of the last move used.</summary>
		int lastMoveUsedType { get; set; }
		/// <summary>Last regular move used.</summary>
		IMove lastRegularMoveUsed { get; set; }
		/// <summary>Target of the last regular move used.</summary>
		int lastRegularMoveTarget { get; set; }
		/// <summary>Last round moved.</summary>
		int lastRoundMoved { get; set; }
		/// <summary>Whether the last move failed.</summary>
		bool lastMoveFailed { get; set; }
		/// <summary>Whether the last round's move failed.</summary>
		bool lastRoundMoveFailed { get; set; }
		/// <summary>Moves used by this battler (by move ID).</summary>
		IList<int> movesUsed { get; set; }
		/// <summary>ID of the multi-turn move currently being used.</summary>
		int currentMove { get; set; }
		/// <summary>Whether HP dropped below half this round.</summary>
		bool droppedBelowHalfHP { get; set; }
		/// <summary>Whether stats were dropped this round.</summary>
		bool statsDropped { get; set; }
		/// <summary>Whether this battler took move damage this round.</summary>
		bool tookMoveDamageThisRound { get; set; }
		/// <summary>Whether this battler took any damage this round.</summary>
		bool tookDamageThisRound { get; set; }
		/// <summary>Whether this battler took a physical hit.</summary>
		bool tookPhysicalHit { get; set; }
		/// <summary>Whether stats were raised this round.</summary>
		bool statsRaisedThisRound { get; set; }
		/// <summary>Whether stats were lowered this round.</summary>
		bool statsLoweredThisRound { get; set; }
		/// <summary>Whether Ice Face can be restored.</summary>
		bool canRestoreIceFace { get; set; }
		/// <summary>Damage state for this battler.</summary>
		IDamageState damageState { get; set; }
		// Complex accessors
		/// <summary>The level of the Pokémon.</summary>
		int level { get; set; }
		/// <summary>The form of the Pokémon.</summary>
		int form { get; set; }
		/// <summary>The ability of the Pokémon.</summary>
		IAbility ability { get; set; }
		/// <summary>The item held by the Pokémon.</summary>
		IItem item { get; set; }
		/// <summary>The defense stat.</summary>
		int defense { get; set; }
		/// <summary>The special defense stat.</summary>
		int spdef { get; set; }
		/// <summary>The current HP.</summary>
		int hp { get; set; }
		bool fainted_check { get; }
		/// <summary>The current status condition.</summary>
		int status { get; set; }
		/// <summary>The status count (turns left for status).</summary>
		int statusCount { get; set; }
		// Properties from Pokémon
		/// <summary>The Pokémon's happiness value.</summary>
		int happiness { get; }
		/// <summary>The Pokémon's affection level.</summary>
		int affection_level { get; }
		/// <summary>The Pokémon's gender (0 = male, 1 = female, 2 = genderless).</summary>
		int gender { get; }
		/// <summary>The Pokémon's nature (as string or enum if defined).</summary>
		string nature { get; }
		/// <summary>The Pokémon's Pokerus stage.</summary>
		int pokerusStage { get; }
		// Mega Evolution, Primal Reversion, Shadow Pokémon
		/// <summary>Returns true if this battler can Mega Evolve.</summary>
		bool hasMega();
		/// <summary>Returns true if this battler is Mega Evolved.</summary>
		bool mega();
		/// <summary>Returns true if this battler can undergo Primal Reversion.</summary>
		bool hasPrimal();
		/// <summary>Returns true if this battler is in Primal form.</summary>
		bool primal();
		/// <summary>Returns true if this battler is a Shadow Pokémon.</summary>
		bool shadowPokemon();
		/// <summary>Returns true if this battler is in Hyper Mode.</summary>
		bool inHyperMode();
		// Display-only properties
		/// <summary>The display name of the Pokémon (may be affected by Illusion, etc.).</summary>
		string name { get; set; }
		/// <summary>The Pokémon to display (may be affected by Illusion, etc.).</summary>
		IPokemon displayPokemon { get; }
		/// <summary>The species to display (may be affected by Illusion, etc.).</summary>
		int displaySpecies { get; }
		/// <summary>The gender to display (may be affected by Illusion, etc.).</summary>
		int displayGender { get; }
		/// <summary>The form to display (may be affected by Illusion, etc.).</summary>
		int displayForm { get; }
		/// <summary>Returns true if the Pokémon is shiny.</summary>
		bool shiny { get; }
		/// <summary>Returns true if the Pokémon is super shiny.</summary>
		bool super_shiny { get; }
		/// <summary>Returns true if the Pokémon is owned by the player.</summary>
		bool owned { get; }
		/// <summary>Returns the name of the ability.</summary>
		string abilityName { get; }
		/// <summary>Returns the name of the held item.</summary>
		string itemName { get; }
		/// <summary>Returns a string representing this battler (e.g., "The opposing Pikachu").</summary>
		string ToString(bool lowerCase = false);
		/// <summary>Returns a string representing this battler's team.</summary>
		string pbTeam(bool lowerCase = false);
		/// <summary>Returns a string representing the opposing team.</summary>
		string pbOpposingTeam(bool lowerCase = false);
		// Calculated properties and queries
		/// <summary>Returns the speed of the battler, factoring in stat stages and effects.</summary>
		int Speed();
		/// <summary>Returns the weight of the battler, factoring in effects and items.</summary>
		int pbWeight();
		/// <summary>Returns a dictionary of plain stats (base stats, not modified by stages).</summary>
		IDictionary<int, int> plainStats();
		/// <summary>Returns true if the battler is of the given species.</summary>
		bool isSpecies(int species);
		/// <summary>Returns a list of types, optionally including extra type.</summary>
		IList<int> pbTypes(bool withExtraType = false);
		/// <summary>Returns true if the battler has the given type.</summary>
		bool pbHasType(int type);
		/// <summary>Returns true if the battler has another type besides the given one.</summary>
		bool pbHasOtherType(int type);
		/// <summary>Returns true if the battler's ability is active.</summary>
		bool abilityActive(bool ignore_fainted = false, int? check_ability = null);
		/// <summary>Returns true if the battler has the given active ability.</summary>
		bool hasActiveAbility(int check_ability, bool ignore_fainted = false);
		/// <summary>Returns true if the battler's ability is unstoppable (cannot be negated).</summary>
		bool unstoppableAbility(int? abil = null);
		/// <summary>Returns true if the battler's ability cannot be gained.</summary>
		bool ungainableAbility(int? abil = null);
		/// <summary>Returns true if the battler's item is active.</summary>
		bool itemActive(bool ignoreFainted = false);
		/// <summary>Returns true if the battler has the given active item.</summary>
		bool hasActiveItem(int check_item, bool ignore_fainted = false);
		bool hasWorkingItem(string check_item, bool ignore_fainted = false);
		/// <summary>Returns true if the given item is unlosable for this Pokémon.</summary>
		bool unlosableItem(int check_item);
		void eachMove(Action<IMove> action);
		void eachMoveWithIndex(Action<IMove, int> action);
		/// <summary>Returns true if the battler has the given move.</summary>
		bool pbHasMove(string move_id);
		/// <summary>Returns true if the battler has a move of the given type.</summary>
		bool pbHasMoveType(int check_type);
		/// <summary>Returns true if the battler has a move with the given function code(s).</summary>
		bool pbHasMoveFunction(params string[] arg);
		/// <summary>Returns the move with the given ID, or null if not found.</summary>
		IMove pbGetMoveWithID(string move_id);
		/// <summary>Returns true if the battler has Mold Breaker or similar abilities.</summary>
		bool hasMoldBreaker();
		/// <summary>Returns true if the battler is being affected by Mold Breaker or similar effects.</summary>
		bool beingMoldBroken();
		/// <summary>Returns true if the battler can change type.</summary>
		bool canChangeType();
		/// <summary>Returns true if the battler is airborne (Flying, Levitate, etc.).</summary>
		bool airborne();
		/// <summary>Returns true if the battler is affected by terrain effects.</summary>
		bool affectedByTerrain();
		/// <summary>Returns true if the battler takes indirect damage (e.g., from weather).</summary>
		bool takesIndirectDamage(bool showMsg = false);
		/// <summary>Returns true if the battler takes sandstorm damage.</summary>
		bool takesSandstormDamage();
		/// <summary>Returns true if the battler takes hail damage.</summary>
		bool takesHailDamage();
		/// <summary>Returns true if the battler takes Shadow Sky damage.</summary>
		bool takesShadowSkyDamage();
		/// <summary>Returns the effective weather for this battler.</summary>
		string effectiveWeather();
		/// <summary>Returns true if the battler is affected by powder moves.</summary>
		bool affectedByPowder(bool showMsg = false);
		/// <summary>Returns true if the battler can heal.</summary>
		bool canHeal();
		/// <summary>Returns true if the battler is affected by contact effects.</summary>
		bool affectedByContactEffect(bool showMsg = false);
		/// <summary>Returns true if the battler is trapped in battle.</summary>
		bool trappedInBattle();
		/// <summary>Returns true if the battler moved this round.</summary>
		bool movedThisRound();
		/// <summary>Returns true if the battler is using a multi-turn attack.</summary>
		bool usingMultiTurnAttack();
		/// <summary>Returns true if the battler is in a two-turn attack state.</summary>
		bool inTwoTurnAttack(params int[] arg);
		bool inTwoTurnAttack(params string[] arg);
		/// <summary>Returns true if the battler is semi-invulnerable (e.g., Fly, Dig).</summary>
		bool semiInvulnerable();
		/// <summary>Returns the index of the encored move, or -1 if none.</summary>
		int pbEncoredMoveIndex();
		/// <summary>Returns the initial item held by the battler.</summary>
		int initialItem();
		/// <summary>Sets the initial item held by the battler.</summary>
		void setInitialItem(int value);
		/// <summary>Returns the item available for recycle.</summary>
		int recycleItem();
		/// <summary>Sets the item available for recycle.</summary>
		void setRecycleItem(int value);
		/// <summary>Returns true if the battler has belched (used a berry for Belch move).</summary>
		bool belched { get; }
		/// <summary>Marks the battler as having belched.</summary>
		void setBelched();
		/// <summary>Returns true if the given position belongs to the opposing side.</summary>
		bool opposes(int i = 0);
		/// <summary>Returns true if the given position/battler is near to this battler.</summary>
		bool near(int i);
		/// <summary>Returns true if this battler is owned by the player.</summary>
		bool pbOwnedByPlayer();
		/// <summary>Returns true if this battler is wild.</summary>
		bool wild { get; }
		/// <summary>Returns 0 if on player's side, 1 if on opposing side.</summary>
		int idxOwnSide { get; }
		/// <summary>Returns 1 if on player's side, 0 if on opposing side.</summary>
		int idxOpposingSide { get; }
		/// <summary>Returns the data structure for this battler's side.</summary>
		IActiveSide pbOwnSide { get; }
		/// <summary>Returns the data structure for the opposing side.</summary>
		IActiveSide pbOpposingSide { get; }
		/// <summary>Yields each unfainted ally Pokémon.</summary>
		void eachAlly(Action<IBattler> action);
		IEnumerable<IBattler> eachAlly();
		/// <summary>Returns a list of all unfainted ally Pokémon.</summary>
		IList<IBattler> allAllies { get; }
		/// <summary>Yields each unfainted opposing Pokémon.</summary>
		void eachOpposing(Action<IBattler> action);
		IEnumerable<IBattler> eachOpposing();
		IList<IBattler> allOpposing { get; }
		/// <summary>Returns the battler most directly opposite to this one.</summary>
		IBattler pbDirectOpposing(bool unfaintedOnly = false);
	}
}