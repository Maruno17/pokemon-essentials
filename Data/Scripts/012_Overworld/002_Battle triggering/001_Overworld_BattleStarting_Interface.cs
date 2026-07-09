using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials//.Overworld.BattleStarting
{
	/// <summary>
	/// Battle preparation.
	/// </summary>
	public interface IGlobalMetadataBattleStarting : IGlobalMetadata {
		IAudioBGM nextBattleBGM			{ get; set; }
		IAudioBGM nextBattleVictoryBGM	{ get; set; }
		IAudioME nextBattleCaptureME	{ get; set; }
		string nextBattleBack			{ get; set; }
	}

	//===============================================================================
	//
	//===============================================================================
	public interface ITempMetadataBattleStarting : ITempMetadata {
		bool encounter_triggered				{ get; set; }
		int encounter_type						{ get; set; }
		IList<int> party_levels_before_battle	{ get; set; }

		/// <summary>
		/// </summary>
		/// <remarks>
		/// Value can be bool or int, so parse the int to bool if needed. If the value is an int, 0 is false, and any other value is true.
		/// </remarks>
		IDictionary<string, int?> battle_rules { get; }

		void clear_battle_rules();

		void add_battle_rule(string rule, int? var = null);
	}

	/// <summary>
	/// Helper methods for setting up and closing down battles.
	/// </summary>
	public interface IBattleCreationHelperMethods {
		/// <summary>
		/// Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
		/// </summary>
		/// <returns></returns>
		bool skip_battle();

		int skip_battle(int outcome_variable, bool trainer_battle = false);

		bool partner_can_participate(IList<IPokemon> foe_party);

		/// <summary>
		/// Generate information for the player and partner trainer(s)
		/// </summary>
		/// <param name="foe_party"></param>
		void set_up_player_trainers(IList<IPokemon> foe_party);

		void create_battle_scene();

		/// <summary>
		/// Sets up various battle parameters and applies special rules.
		/// </summary>
		/// <param name="battle"></param>
		void prepare_battle(IBattle battle);

		void after_battle(int outcome, bool can_lose);

		/// <summary>
		/// Save the result of the battle in a Game Variable (1 by default)
		/// </summary>
		/// <remarks>
		///    0 - Undecided or aborted
		///    1 - Player won
		///    2 - Player lost
		///    3 - Player or wild Pokémon ran from battle, or player forfeited the match
		///    4 - Wild Pokémon was caught
		///    5 - Draw
		/// </remarks>
		/// <param name="outcome"></param>
		/// <param name="outcome_variable"></param>
		/// <param name="trainer_battle"></param>
		void set_outcome(int outcome, int outcome_variable = 1, bool trainer_battle = false);
	}

	/// <summary>
	/// Wild battles.
	/// </summary>
	public interface IWildBattle {
		//void start(*args, bool can_override = false);
		/// <summary>
		/// Used when walking in tall grass, hence the additional code.
		/// </summary>
		/// <param name="encounter"></param>
		/// <param name="can_override"></param>
		void start(IPokemon encounter, bool can_override = false);
		void start(IPokemon encounter, IPokemon encounter2, bool can_override = false);
		void start(IList<IPokemon> encounter, bool can_override = false);

		int start_core(params IPokemon[] args);

		IList<IPokemon> generate_foes(params IPokemon[] args);
	}

	/// <summary>
	/// Trainer battles.
	/// </summary>
	public interface ITrainerBattle {
		//bool start(*args);
		/// <summary>
		/// Used by most trainer events, which can be positioned in such a way that
		/// multiple trainer events spot the player at once. The extra code in this
		/// method deals with that case and can cause a double trainer battle instead.
		/// </summary>
		/// <param name="trainer"></param>
		void start(ITrainer trainer);
		void start(ITrainer trainer, ITrainer trainer2);
		void start(IList<ITrainer> trainer);

		//int start_core(*args);
		int start_core(params ITrainer[] trainers);

		void generate_foes(params INPCTrainer[] args);
	}

	public interface IMainBattleStarting : IMain
	{
		//===============================================================================
		//
		//===============================================================================
		void setBattleRule(params string[] args);

		/// <summary>
		/// Used to determine the environment in battle, and also the form of Burmy/
		/// Wormadam.
		/// </summary>
		void GetEnvironment();

		/// <summary>
		/// Record current levels of Pokémon in party, to see if they gain a level during
		/// battle and may need to evolve afterwards
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_start_battle, :record_party_status,
		/// 	block: () => {
		/// 		Game.GameData.game_temp.party_levels_before_battle = new List<int>();
		/// 		for (int i = 0; i < Game.GameData.player.party.Count; i++) { //.each_with_index do |pkmn, i|
		/// 			//Game.GameData.game_temp.party_levels_before_battle[i] = pkmn.level;
		/// 			Game.GameData.game_temp.party_levels_before_battle.Add(Game.GameData.player.party[i].level);
		/// 		}
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnStartBattle"/>
		void OnStartBattleTrigger();

		bool CanDoubleBattle();

		bool CanTripleBattle();

		/// <summary>
		/// After battles.
		/// </summary>
		/// <remarks>
		/// Evolution checks are done here, as well as blacking out if the player lost the battle. Pickup and Honey Gather items are also given here.
		/// </remarks>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_end_battle, :evolve_and_black_out,
		/// 	block: (outcome, canLose) => {
		/// 		// Check for evolutions
		/// 		if (Settings.CHECK_EVOLUTION_AFTER_ALL_BATTLES ||
		/// 			!Battle.Outcome.should_black_out(outcome)) EvolutionCheck();
		/// 		Game.GameData.game_temp.party_levels_before_battle = null;
		/// 		// Check for blacking out or gaining Pickup/Huney Gather items
		/// 		switch (outcome) {
		/// 			case Battle.Outcome.WIN: case Battle.Outcome.CATCH:
		/// 				foreach (IPokemon pkmn in Game.GameData.player.pokemon_party) { //'Game.GameData.player.pokemon_party.each' do => |pkmn|
		/// 					Pickup(pkmn);
		/// 					HoneyGather(pkmn);
		/// 				}
		/// 				break;
		/// 			default:
		/// 				if (IBattle.Outcome.should_black_out(outcome) && !canLose) {
		/// 					Game.GameData.game_system.bgm_unpause();
		/// 					Game.GameData.game_system.bgs_unpause();
		/// 					StartOver();
		/// 				}
		/// 				break;
		/// 		}
		/// 	}
		/// );
		/// </code>
		/// </example>
		/// <param name="outcome"></param>
		/// <param name="canLose"></param>
		/// <seealso cref="IEvents.OnEndBattle"/>
		/// <seealso cref="EventArg.IOnEndBattleEventArgs"/>
		void OnEndBattleTrigger(int outcome, bool canLose);

		void EvolutionCheck();

		void DynamicItemList(params int[] items);

		/// <summary>
		/// Common items to find via <see cref="Pickup"/>. Items from this list are added to the pool in
		/// order, starting from a point depending on the Pokémon's level. The number of
		/// items added is how many probabilities are in the <see cref="PICKUP_COMMON_ITEM_CHANCES"/>
		/// array below.
		/// </summary>
		/// <remarks>
		/// There must be 9 + <see cref="PICKUP_COMMON_ITEM_CHANCES"/>.length number of items in this
		/// array (18 by default). The 9 is actually (100 / num_rarity_levels) - 1, where
		/// num_rarity_levels is in <see cref="Pickup"/> below.
		/// </remarks>
		/// <example>
		/// <code>
		/// const Items[] PICKUP_COMMON_ITEMS = new Items[] {
		/// 	Items.POTION,        // Levels 1-10
		/// 	Items.ANTIDOTE,      // Levels 1-10, 11-20
		/// 	Items.SUPERPOTION,   // Levels 1-10, 11-20, 21-30
		/// 	Items.GREATBALL,     // Levels 1-10, 11-20, 21-30, 31-40
		/// 	Items.REPEL,         // Levels 1-10, 11-20, 21-30, 31-40, 41-50
		/// 	Items.ESCAPEROPE,    // Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60
		/// 	Items.FULLHEAL,      // Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70
		/// 	Items.HYPERPOTION,   // Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80
		/// 	Items.ULTRABALL,     // Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90
		/// 	Items.REVIVE,        // Levels       11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
		/// 	Items.RARECANDY,     // Levels              21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
		/// 	Items.SUNSTONE,      // Levels                     31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
		/// 	Items.MOONSTONE,     // Levels                            41-50, 51-60, 61-70, 71-80, 81-90, 91-100
		/// 	Items.HEARTSCALE,    // Levels                                   51-60, 61-70, 71-80, 81-90, 91-100
		/// 	Items.FULLRESTORE,   // Levels                                          61-70, 71-80, 81-90, 91-100
		/// 	Items.MAXREVIVE,     // Levels                                                 71-80, 81-90, 91-100
		/// 	Items.PPUP,          // Levels                                                        81-90, 91-100
		/// 	Items.MAXELIXIR      // Levels                                                               91-100
		/// };
		/// </code>
		/// </example>
		int[] PICKUP_COMMON_ITEMS { get; }

		/// <summary>
		/// Chances to get each item added to the pool from the array above.
		/// </summary>
		/// <example>
		/// <code>
		/// int[] PICKUP_COMMON_ITEM_CHANCES = new int[] {30, 10, 10, 10, 10, 10, 10, 4, 4};
		/// </code>
		/// </example>
		int[] PICKUP_COMMON_ITEM_CHANCES { get; }

		/// <summary>
		/// Rare items to find via Pickup. Items from this list are added to the pool in
		/// order, starting from a point depending on the Pokémon's level. The number of
		/// items added is how many probabilities are in the PICKUP_RARE_ITEM_CHANCES
		/// array below.
		/// </summary>
		/// <remarks>
		/// There must be 9 + PICKUP_RARE_ITEM_CHANCES.length number of items in this
		/// array (11 by default). The 9 is actually (100 / num_rarity_levels) - 1, where
		/// num_rarity_levels is in def Pickup below.
		/// </remarks>
		/// <example>
		/// <code>
		/// Items[] PICKUP_RARE_ITEMS = new Items[] {
		/// 	Items.HYPERPOTION,   // Levels 1-10
		/// 	Items.NUGGET,        // Levels 1-10, 11-20
		/// 	Items.KINGSROCK,     // Levels       11-20, 21-30
		/// 	Items.FULLRESTORE,   // Levels              21-30, 31-40
		/// 	Items.ETHER,         // Levels                     31-40, 41-50
		/// 	Items.IRONBALL,      // Levels                            41-50, 51-60
		/// 	Items.DESTINYKNOT,   // Levels                                   51-60, 61-70
		/// 	Items.ELIXIR,        // Levels                                          61-70, 71-80
		/// 	Items.DESTINYKNOT,   // Levels                                                 71-80, 81-90
		/// 	Items.LEFTOVERS,     // Levels                                                        81-90, 91-100
		/// 	Items.DESTINYKNOT    // Levels                                                               91-100
		/// };
		/// </code>
		/// </example>
		int[] PICKUP_RARE_ITEMS { get; }

		/// <summary>
		/// Chances to get each item added to the pool from the array above.
		/// </summary>
		/// <example>
		/// <code>
		/// int[] PICKUP_RARE_ITEM_CHANCES = new int[] {1, 1};
		/// </code>
		/// </example>
		int[] PICKUP_RARE_ITEM_CHANCES { get; }

		/// <summary>
		/// Try to gain an item after a battle if a Pokemon has the ability Pickup.
		/// </summary>
		/// <param name="pkmn"></param>
		void Pickup(IPokemon pkmn);

		/// <summary>
		/// Try to gain a Honey item after a battle if a Pokemon has the ability Honey Gather.
		/// </summary>
		/// <param name="pkmn"></param>
		void HoneyGather(IPokemon pkmn);
	}
}