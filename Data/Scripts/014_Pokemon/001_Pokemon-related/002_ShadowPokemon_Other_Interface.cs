using System;
using System.Collections.Generic;
using PokemonEssentials;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for shadow Pokemon purification functionality.
	/// Provides methods for purifying shadow Pokemon and managing their heart gauge.
	/// </summary>
	/// <remarks>
	/// All types except Shadow have Shadow as a weakness.
	/// Shadow has Shadow as a resistance.
	/// On a side note, the Shadow moves in Colosseum will not be affected by
	/// Weaknesses or Resistances, while in XD the Shadow-type is Super-Effective
	/// against all other types.
	/// 2/5 - display nature
	///
	/// XD - Shadow Rush -- 55, 100 - Deals damage.
	/// Colosseum - Shadow Rush -- 90, 100
	/// If this attack is successful, user loses half of HP lost by opponent due to
	/// this attack (recoil). If user is in Hyper Mode, this attack has a good chance
	/// for a critical hit.
	/// </remarks>
	//public interface IShadowPokemonPurification
	public interface IMainShadowPokemon : IMain
	{
		/// <summary>
		/// Purifies a shadow Pokemon, restoring its original moves and applying saved experience/EVs.
		/// </summary>
		/// <param name="pkmn">The shadow Pokemon to purify.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		void Purify(IShadowPokemon pkmn, object scene);

		/// <summary>
		/// Raises a Pokemon's happiness and reduces its heart gauge using a scent item.
		/// </summary>
		/// <param name="pkmn">The Pokemon to affect.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		/// <param name="multiplier">The multiplier for heart gauge reduction.</param>
		/// <param name="show_fail_message">Whether to show failure message if item has no effect.</param>
		/// <returns>True if the item had an effect, false otherwise.</returns>
		bool RaiseHappinessAndReduceHeart(IShadowPokemon pkmn, ICanDisplayMessage scene, int multiplier, bool show_fail_message = true);

		/// <summary>
		/// Record current heart gauges of Pokémon in party, to see if they drop to zero
		/// during battle and need to say they're ready to be purified afterwards.
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_start_battle, :record_party_heart_gauges,
		///   proc {
		///     $game_temp.party_heart_gauges_before_battle = []
		///     $player.party.each_with_index do |pkmn, i|
		///       $game_temp.party_heart_gauges_before_battle[i] = pkmn.heart_gauge
		///     end
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnStartBattle"/>
		void on_start_battleTrigger_record_party_heart_gauges();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// </code>
		/// </example>
		/// EventHandlers.add(:on_end_battle, :check_ready_to_purify,
		///   proc { |_outcome, _canLose|
		///     $game_temp.party_heart_gauges_before_battle.each_with_index do |value, i|
		///       pkmn = $player.party[i]
		///       next if !pkmn || !value || value == 0
		///       pkmn.check_ready_to_purify if pkmn.heart_gauge == 0
		///     end
		///   }
		/// )
		/// <seealso cref="IEvents.OnEndBattle"/>
		/// <seealso cref="EventArg.IOnEndBattleEventArgs"/>
		/// <param name="outcome"></param>
		/// <param name="canLose"></param>
		void on_end_battleTrigger_check_ready_to_purify(int outcome, int canLose);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_step_taken, :lower_heart_gauges,
		///   proc {
		///     $player.able_party.each do |pkmn|
		///       next if pkmn.heart_gauge == 0
		///       pkmn.heart_gauge_step_counter = 0 if !pkmn.heart_gauge_step_counter
		///       pkmn.heart_gauge_step_counter += 1
		///       next if pkmn.heart_gauge_step_counter < 256
		///       old_stage = pkmn.heartStage
		///       pkmn.change_heart_gauge("walking")
		///       new_stage = pkmn.heartStage
		///       if new_stage == 0
		///         pkmn.check_ready_to_purify
		///       elsif new_stage != old_stage
		///         pkmn.update_shadow_moves
		///       end
		///       pkmn.heart_gauge_step_counter = 0
		///     end
		///     $PokemonGlobal.purifyChamber&.update
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnStepTaken"/>
		/// <seealso cref="IEvents.OnPlayerStepTaken"/>
		/// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
		/// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
		void on_player_step_takenTrigger_lower_heart_gauges();
	//}

	/// <summary>
	/// Interface for Relic Stone functionality.
	/// Provides methods for displaying the Relic Stone screen and handling purification.
	/// </summary>
	//public interface IMainRelicStone : IMain
	//{
		/// <summary>
		/// Shows the Relic Stone screen for the specified Pokemon.
		/// </summary>
		/// <param name="pkmn">The Pokemon to purify.</param>
		/// <returns>The result of the purification process.</returns>
		object RelicStoneScreen(IShadowPokemon pkmn);

		/// <summary>
		/// Handles the Relic Stone interaction, allowing the player to choose a purifiable Pokemon.
		/// </summary>
		void RelicStone();
	}

	/// <summary>
	/// Interface for the Relic Stone scene that handles shadow Pokemon purification.
	/// </summary>
	public interface ISceneRelicStone : IScene, ICanDisplayMessage, IHaveUpdate
	{
		ISceneRelicStone initialize(IScene scene);

		/// <summary>
		/// Performs the purification ritual animation.
		/// </summary>
		void Purify();

		/// <summary>
		/// Updates the scene graphics and animations.
		/// </summary>
		void Update();

		/// <summary>
		/// Ends the scene and cleans up resources.
		/// </summary>
		void EndScene();

		/// <summary>
		/// Displays a message on the screen.
		/// </summary>
		/// <param name="msg">The message to display.</param>
		/// <param name="brief">Whether to show the message briefly.</param>
		void Display(string msg, bool brief = false);

		/// <summary>
		/// Shows a confirmation dialog.
		/// </summary>
		/// <param name="msg">The confirmation message.</param>
		/// <returns>True if user confirmed, false otherwise.</returns>
		bool Confirm(string msg);

		/// <summary>
		/// Starts the Relic Stone scene with the specified Pokemon.
		/// </summary>
		/// <param name="pokemon">The Pokemon to purify.</param>
		void StartScene(IShadowPokemon pokemon);
	}

	/// <summary>
	/// Interface for the Relic Stone screen that manages the purification process.
	/// </summary>
	public interface IScreenRelicStone : IScreen, ICanDisplayMessage, IHaveUpdate, IHaveRefresh
	{
		IScreenRelicStone initialize(ISceneRelicStone scene);

		/// <summary>
		/// Displays a message using the scene.
		/// </summary>
		/// <param name="x">The message to display.</param>
		void Display(string x);

		/// <summary>
		/// Shows a confirmation dialog using the scene.
		/// </summary>
		/// <param name="x">The confirmation message.</param>
		/// <returns>True if user confirmed, false otherwise.</returns>
		bool Confirm(string x);

		/// <summary>
		/// Updates the screen state.
		/// </summary>
		void Update();

		/// <summary>
		/// Refreshes the screen display.
		/// </summary>
		void Refresh();

		/// <summary>
		/// Starts the purification process for the specified Pokemon.
		/// </summary>
		/// <param name="pokemon">The Pokemon to purify.</param>
		/// <returns>The result of the purification process.</returns>
		object StartScreen(IShadowPokemon pokemon);
	}

	/// <summary>
	/// Shadow Pokémon in battle.
	/// </summary>
	/// <remarks>
	/// Interface for shadow Pokemon battle functionality.
	/// Handles hyper mode, battle interactions, and shadow Pokemon specific behaviors.
	/// </remarks>
	//public interface IShadowPokemonBattle : IBattle
	public interface IBattleShadowPokemon : IBattle
	{
		/// <summary>
		/// Checks if an item can be used on a Pokemon in battle, considering shadow Pokemon restrictions.
		/// </summary>
		/// <param name="item">The item to use.</param>
		/// <param name="pkmn">The Pokemon to use the item on.</param>
		/// <param name="battler">The battler object.</param>
		/// <param name="scene">The battle scene.</param>
		/// <param name="showMessages">Whether to show error messages.</param>
		/// <returns>True if the item can be used, false otherwise.</returns>
		bool CanUseItemOnPokemon(int item, IPokemon pkmn, IBattler battler, ICanDisplayMessage scene, bool showMessages = true);
	}

	public interface IBattlerShadowPokemon : IBattler
	{
		/// <summary>
		/// Initializes a shadow Pokemon when entering battle.
		/// </summary>
		/// <param name="args">Initialization arguments.</param>
		void InitPokemon(params object[] args);

		/// <summary>
		/// Determines if this battler is a shadow Pokemon.
		/// </summary>
		/// <returns>True if this is a shadow Pokemon, false otherwise.</returns>
		bool shadowPokemon();

		/// <summary>
		/// Determines if this Pokemon is currently in hyper mode.
		/// </summary>
		/// <returns>True if in hyper mode, false otherwise.</returns>
		bool inHyperMode();

		/// <summary>
		/// Attempts to trigger hyper mode for this shadow Pokemon.
		/// </summary>
		void HyperMode();

		/// <summary>
		/// Checks if the Pokemon will obey in hyper mode when using a non-shadow move.
		/// </summary>
		/// <param name="move">The move being used.</param>
		/// <returns>True if the Pokemon will obey, false otherwise.</returns>
		bool HyperModeObedience(IBattleMove move);
	}

	/// <summary>
	/// Interface for shadow Pokemon event handling.
	/// Manages events related to shadow Pokemon during battles and gameplay.
	/// </summary>
	//public interface IShadowPokemonEvents
	public interface ITempMetadataShadowPokemon : ITempMetadata
	{
		/// <summary>
		/// Gets or sets the party heart gauges before battle for comparison after battle.
		/// </summary>
		IList<int> party_heart_gauges_before_battle { get; set; }

		/// <summary>
		/// Records the heart gauges of all party Pokemon before starting a battle.
		/// </summary>
		//void RecordPartyHeartGauges();

		/// <summary>
		/// Checks if any shadow Pokemon are ready to purify after battle ends.
		/// </summary>
		/// <param name="outcome">The battle outcome.</param>
		/// <param name="canLose">Whether the player can lose.</param>
		//void CheckReadyToPurify(object outcome, bool canLose);

		/// <summary>
		/// Lowers heart gauges when the player takes steps, and updates shadow moves accordingly.
		/// </summary>
		//void LowerHeartGauges();
	}
/*
	/// <summary>
	/// Interface for shadow move effects in battle.
	/// Defines special move behaviors for shadow Pokemon.
	/// </summary>
	public interface IShadowMoveEffects
	{
		/// <summary>
		/// Checks if the "Shadow Half" move failed.
		/// </summary>
		/// <param name="user">The Pokemon using the move.</param>
		/// <param name="targets">The target Pokemon.</param>
		/// <returns>True if the move failed, false otherwise.</returns>
		bool MoveFailed(IBattler user, object targets);

		/// <summary>
		/// Executes the general effect of halving all active Pokemon's HP.
		/// </summary>
		/// <param name="user">The Pokemon using the move.</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Calculates recoil damage for "Shadow End" move.
		/// </summary>
		/// <param name="user">The Pokemon using the move.</param>
		/// <param name="target">The target Pokemon.</param>
		/// <returns>The amount of recoil damage.</returns>
		int RecoilDamage(IBattler user, IBattler target);

		/// <summary>
		/// Applies recoil damage after all hits.
		/// </summary>
		/// <param name="user">The Pokemon using the move.</param>
		/// <param name="target">The target Pokemon.</param>
		void EffectAfterAllHits(IBattler user, IBattler target);

		/// <summary>
		/// Starts shadow weather (Shadow Sky).
		/// </summary>
		/// <param name="battle">The battle object.</param>
		/// <param name="move">The move object.</param>
		IShadowMoveEffects initialize(IBattle battle, object move);

		/// <summary>
		/// Removes all screens and safeguard effects from both sides.
		/// </summary>
		/// <param name="user">The Pokemon using the move.</param>
		void RemoveAllScreensAndSafeguard(IBattler user);
	}

	/// <summary>
	/// Interface for shadow Pokemon item effects.
	/// Handles special items that affect shadow Pokemon.
	/// </summary>
	public interface IShadowPokemonItems
	{
		/// <summary>
		/// Handles the use of Joy Scent on a Pokemon.
		/// </summary>
		/// <param name="item">The item being used.</param>
		/// <param name="qty">The quantity of the item.</param>
		/// <param name="pkmn">The Pokemon to use the item on.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		/// <returns>True if the item was used successfully, false otherwise.</returns>
		bool UseJoyScent(int item, int qty, IPokemon pkmn, object scene);

		/// <summary>
		/// Handles the use of Excite Scent on a Pokemon.
		/// </summary>
		/// <param name="item">The item being used.</param>
		/// <param name="qty">The quantity of the item.</param>
		/// <param name="pkmn">The Pokemon to use the item on.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		/// <returns>True if the item was used successfully, false otherwise.</returns>
		bool UseExciteScent(int item, int qty, IPokemon pkmn, object scene);

		/// <summary>
		/// Handles the use of Vivid Scent on a Pokemon.
		/// </summary>
		/// <param name="item">The item being used.</param>
		/// <param name="qty">The quantity of the item.</param>
		/// <param name="pkmn">The Pokemon to use the item on.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		/// <returns>True if the item was used successfully, false otherwise.</returns>
		bool UseVividScent(int item, int qty, IPokemon pkmn, object scene);

		/// <summary>
		/// Handles the use of Time Flute on a Pokemon (instantly purifies shadow Pokemon).
		/// </summary>
		/// <param name="item">The item being used.</param>
		/// <param name="qty">The quantity of the item.</param>
		/// <param name="pkmn">The Pokemon to use the item on.</param>
		/// <param name="scene">The scene object for displaying messages.</param>
		/// <returns>True if the item was used successfully, false otherwise.</returns>
		bool UseTimeFlute(int item, int qty, IPokemon pkmn, object scene);

		/// <summary>
		/// Checks if a scent item can be used on a Pokemon in battle.
		/// </summary>
		/// <param name="item">The item to check.</param>
		/// <param name="pokemon">The Pokemon to use the item on.</param>
		/// <param name="battler">The battler object.</param>
		/// <param name="move">The move being used.</param>
		/// <param name="firstAction">Whether this is the first action.</param>
		/// <param name="battle">The battle object.</param>
		/// <param name="scene">The battle scene.</param>
		/// <param name="showMessages">Whether to show error messages.</param>
		/// <returns>True if the item can be used, false otherwise.</returns>
		bool CanUseInBattle(int item, IPokemon pokemon, IBattler battler, object move, bool firstAction, object battle, object scene, bool showMessages);

		/// <summary>
		/// Uses a scent item on a Pokemon during battle.
		/// </summary>
		/// <param name="item">The item being used.</param>
		/// <param name="pokemon">The Pokemon to use the item on.</param>
		/// <param name="battler">The battler object.</param>
		/// <param name="choices">The battle choices.</param>
		/// <param name="scene">The battle scene.</param>
		/// <returns>True if the item was used successfully, false otherwise.</returns>
		bool BattleUseOnPokemon(int item, IPokemon pokemon, IBattler battler, IBattleChoice choices, object scene);
	}
*/
}