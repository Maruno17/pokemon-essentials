using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Stored in <see cref="IGameManager.stats"/>
	/// </summary>
	/// Stored in Game.GameData.stats
	public interface IGameStats {
		#region Travel
		/// <summary>
		/// Gets or sets the total distance walked by the player in tiles.
		/// </summary>
		/// <remarks>
		/// This is the primary movement statistic and includes all walking movement.
		/// </remarks>
		int distance_walked		{ get; set; }
		/// <summary>
		/// Gets or sets the total distance cycled by the player in tiles.
		/// </summary>
		/// <remarks>
		/// Only counts movement while on a bicycle.
		/// </remarks>
		int distance_cycled		{ get; set; }
		/// <summary>
		/// Gets or sets the total distance surfed by the player in tiles.
		/// </summary>
		/// <remarks>
		/// Includes both surfing and diving movement.
		/// </remarks>
		int distance_surfed		{ get; set; }
		/// <summary>
		/// Gets or sets the total distance slid on ice in tiles.
		/// </summary>
		/// <remarks>
		/// Also counted in distance_walked.
		/// </remarks>
		int distance_slid_on_ice	{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player walked into something.
		/// </summary>
		/// <remarks>
		/// Incremented when player movement is blocked by an obstacle.
		/// </remarks>
		int bump_count		{ get; set; }
		int cycle_count		{ get; set; }
		int surf_count		{ get; set; }
		int dive_count		{ get; set; }
		#endregion
		#region Field actions
		/// <summary>
		/// Gets or sets the number of times the player has used Fly.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Fly HM.
		/// </remarks>
		int fly_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used Cut.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Cut HM.
		/// </remarks>
		int cut_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used Flash.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Flash HM.
		/// </remarks>
		int flash_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used Rock Smash.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Rock Smash HM.
		/// </remarks>
		int rock_smash_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of battles initiated by using Rock Smash.
		/// </summary>
		int rock_smash_battles		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used Headbutt.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Headbutt move on trees.
		/// </remarks>
		int headbutt_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of battles initiated by using Headbutt.
		/// </summary>
		int headbutt_battles		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has pushed objects with Strength.
		/// </summary>
		/// <remarks>
		/// Number of shoves, not the times Strength was used.
		/// </remarks>
		int strength_push_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used Waterfall.
		/// </summary>
		/// <remarks>
		/// Incremented when the player uses the Waterfall HM.
		/// </remarks>
		int waterfall_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has descended waterfalls.
		/// </summary>
		int waterfalls_descended		{ get; set; }
		#endregion
		#region Items
		/// <summary>
		/// Gets or sets the number of times the player has used a Repel.
		/// </summary>
		int repel_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used the Itemfinder.
		/// </summary>
		int itemfinder_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has gone fishing.
		/// </summary>
		int fishing_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of battles initiated by fishing.
		/// </summary>
		int fishing_battles		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has used the Poké Radar.
		/// </summary>
		int poke_radar_count		{ get; set; }
		/// <summary>
		/// Gets or sets the longest chain achieved with the Poké Radar.
		/// </summary>
		int poke_radar_longest_chain		{ get; set; }
		/// <summary>
		/// Gets or sets the number of berry plants the player has picked from.
		/// </summary>
		int berry_plants_picked		{ get; set; }
		/// <summary>
		/// Gets or sets the number of berry plants that yielded maximum berries.
		/// </summary>
		int max_yield_berry_plants		{ get; set; }
		/// <summary>
		/// Gets or sets the number of berries the player has planted.
		/// </summary>
		int berries_planted		{ get; set; }
		#endregion
		#region NPCs
		/// <summary>
		/// Gets or sets the number of times the player has visited a Poké Center.
		/// </summary>
		/// <remarks>
		/// Incremented in Poké Center nurse events.
		/// </remarks>
		int poke_center_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of fossils the player has revived.
		/// </summary>
		/// <remarks>
		/// Incremented in fossil reviver events.
		/// </remarks>
		int revived_fossil_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has won any prize.
		/// </summary>
		/// <remarks>
		/// Incremented in lottery NPC events.
		/// </remarks>
		int lottery_prize_count		{ get; set; }
		#endregion
		#region Pokémon
		/// <summary>
		/// Gets or sets the number of eggs the player has hatched.
		/// </summary>
		int eggs_hatched		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times a Pokémon has evolved.
		/// </summary>
		int evolution_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has cancelled an evolution.
		/// </summary>
		int evolutions_cancelled		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Pokémon the player has traded.
		/// </summary>
		int trade_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of moves taught using items.
		/// </summary>
		int moves_taught_by_item		{ get; set; }
		/// <summary>
		/// Gets or sets the number of moves taught by move tutors.
		/// </summary>
		int moves_taught_by_tutor		{ get; set; }
		/// <summary>
		/// Gets or sets the number of moves taught by move reminder.
		/// </summary>
		int moves_taught_by_reminder		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Pokémon left at the Day Care.
		/// </summary>
		int day_care_deposits		{ get; set; }
		/// <summary>
		/// Gets or sets the total levels gained at the Day Care.
		/// </summary>
		int day_care_levels_gained		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times a Pokémon has been infected with Pokérus.
		/// </summary>
		int pokerus_infections		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Shadow Pokémon purified.
		/// </summary>
		int shadow_pokemon_purified		{ get; set; }
		#endregion
		#region Battles
		/// <summary>
		/// Gets or sets the number of wild battles won.
		/// </summary>
		int wild_battles_won		{ get; set; }
		/// <summary>
		/// Gets or sets the number of wild battles lost or fled from.
		/// </summary>
		int wild_battles_lost		{ get; set; }
		/// <summary>
		/// Gets or sets the number of trainer battles won.
		/// </summary>
		int trainer_battles_won		{ get; set; }
		/// <summary>
		/// Gets or sets the number of trainer battles lost.
		/// </summary>
		int trainer_battles_lost		{ get; set; }
		/// <summary>
		/// Gets or sets the total experience points gained in battles.
		/// </summary>
		int total_exp_gained		{ get; set; }
		/// <summary>
		/// Gets or sets the total money gained from battles.
		/// </summary>
		int battle_money_gained		{ get; set; }
		/// <summary>
		/// Gets or sets the total money lost in battles.
		/// </summary>
		int battle_money_lost		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times the player has blacked out.
		/// </summary>
		int blacked_out_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times a Pokémon has Mega Evolved.
		/// </summary>
		int mega_evolution_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times a Pokémon has undergone Primal Reversion.
		/// </summary>
		int primal_reversion_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of failed Poké Ball throws.
		/// </summary>
		int failed_poke_ball_count		{ get; set; }
		#endregion
		#region Currency
		/// <summary>
		/// Gets or sets the total money spent at Poké Marts.
		/// </summary>
		int money_spent_at_marts		{ get; set; }
		/// <summary>
		/// Gets or sets the total money earned at Poké Marts.
		/// </summary>
		int money_earned_at_marts	{ get; set; }
		/// <summary>
		/// Gets or sets the number of items bought at Poké Marts.
		/// </summary>
		int mart_items_bought		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Premier Balls earned from purchases.
		/// </summary>
		int premier_balls_earned		{ get; set; }
		/// <summary>
		/// Gets or sets the number of drinks bought from vending machines.
		/// </summary>
		/// <remarks>
		/// Incremented in vending machine events.
		/// </remarks>
		int drinks_bought		{ get; set; }
		/// <summary>
		/// Gets or sets the number of drinks won from vending machines.
		/// </summary>
		/// <remarks>
		/// Incremented in vending machine events.
		/// </remarks>
		int drinks_won		{ get; set; }
		/// <summary>
		/// Gets or sets the number of coins won at the Game Corner.
		/// </summary>
		int coins_won		{ get; set; }
		/// <summary>
		/// Gets or sets the number of coins lost at the Game Corner.
		/// </summary>
		/// <remarks>
		/// Not bought, not spent.
		/// </remarks>
		int coins_lost		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Battle Points won.
		/// </summary>
		int battle_points_won		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Battle Points spent.
		/// </summary>
		int battle_points_spent		{ get; set; }
		/// <summary>
		/// Gets or sets the amount of soot collected.
		/// </summary>
		int soot_collected		{ get; set; }
		#endregion
		#region Special stats
		/// <summary>
		/// Gets or sets the number of attempts at each Gym Leader.
		/// </summary>
		/// <remarks>
		/// Array length must be 50 (arbitrary but suitably large).
		/// Each element represents attempts for a specific Gym Leader.
		/// </remarks>
		/// <exception cref="ArgumentException">Thrown when array length is not 50</exception>
		int[] gym_leader_attempts		{ get; set; }
		/// <summary>
		/// Gets or sets the times taken to earn each badge.
		/// </summary>
		/// <remarks>
		/// An array of times in seconds.
		/// Set with <see cref="set_time_to_badge(int)"/> in Gym Leader events.
		/// </remarks>
		IList<int> times_to_get_badges		{ get; set; }
		/// <summary>
		/// Gets or sets the number of attempts at the Elite Four.
		/// </summary>
		/// <remarks>
		/// Incremented in door event leading to the first E4 member.
		/// </remarks>
		int elite_four_attempts		{ get; set; }
		/// <summary>
		/// Gets or sets the number of times entered in the Hall of Fame.
		/// </summary>
		/// <remarks>
		/// See also Game Variable 13.
		/// Incremented in Hall of Fame event.
		/// </remarks>
		int hall_of_fame_entry_count		{ get; set; }
		/// <summary>
		/// Gets or sets the time taken to enter the Hall of Fame.
		/// </summary>
		/// <remarks>
		/// In seconds.
		/// Set with <see cref="set_time_to_hall_of_fame"/> in Hall of Fame event.
		/// </remarks>
		int time_to_enter_hall_of_fame		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Pokémon caught in Safari Zone.
		/// </summary>
		int safari_pokemon_caught		{ get; set; }
		/// <summary>
		/// Gets or sets the highest number of captures in a single Safari game.
		/// </summary>
		int most_captures_per_safari_game		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Bug Contests entered.
		/// </summary>
		int bug_contest_count		{ get; set; }
		/// <summary>
		/// Gets or sets the number of Bug Contests won.
		/// </summary>
		int bug_contest_wins		{ get; set; }
		#endregion
		#region Play
		/// <summary>
		/// Gets the total play time in seconds.
		/// </summary>
		/// <remarks>
		/// The reader also updates this value.
		/// Must be non-negative.
		/// </remarks>
		/// <exception cref="ArgumentOutOfRangeException">Thrown when value is negative</exception>
		int play_time		{ get; }
		int play_sessions		{ get; set; }
		/// <summary>
		/// Gets or sets the time of the last save in seconds.
		/// </summary>
		int time_last_saved		{ get; set; }
		#endregion

		/// <summary>
		/// Initializes all statistics to their default values.
		/// </summary>
		void initialize();

		/// <summary>
		/// Calculates the total distance moved by the player.
		/// </summary>
		/// <returns>The total distance moved in tiles</returns>
		int distance_moved();

		/// <summary>
		/// Gets the total number of Pokémon caught.
		/// </summary>
		/// <returns>The number of Pokémon caught</returns>
		int caught_pokemon_count();

		int save_count();

		void set_time_to_badge(int number);

		void set_time_to_hall_of_fame();

		float play_time_per_session();

		void set_time_last_saved();

		float time_since_last_save();
	}

	/// <summary>
	/// Temporary metadata for game statistics.
	/// </summary>
	public interface ITempMetadataGameStats : ITempMetadata {
		/// <summary>
		/// Gets or sets the last time the play time was refreshed.
		/// </summary>
		/// <remarks>
		/// Used to track when the play time was last updated to prevent double-counting.
		/// </remarks>
		int last_uptime_refreshed_play_time { get; set; }
	}
}