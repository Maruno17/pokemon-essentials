using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Battle-specific game settings and configuration interface.
	/// </summary>
	public interface IBattleSettings
	{
		#region Turn Order and Disobedience

		/// <summary>
		/// Whether turn order is recalculated after a Pokemon Mega Evolves.
		/// </summary>
		bool RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION { get; }

		/// <summary>
		/// Whether turn order is recalculated after a Pokemon's Speed stat changes.
		/// </summary>
		bool RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES { get; }

		/// <summary>
		/// Whether any Pokemon (originally owned by the player or foreign) can disobey
		/// the player's commands if the Pokemon is too high a level compared to the
		/// number of Gym Badges the player has.
		/// </summary>
		bool ANY_HIGH_LEVEL_POKEMON_CAN_DISOBEY { get; }

		/// <summary>
		/// Whether foreign Pokemon can disobey the player's commands if the Pokemon is
		/// too high a level compared to the number of Gym Badges the player has.
		/// </summary>
		bool FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY { get; }

		#endregion

		#region Mega Evolution

		/// <summary>
		/// The Game Switch which, while ON, prevents all Pokemon in battle from Mega
		/// Evolving even if they otherwise could.
		/// </summary>
		int NO_MEGA_EVOLUTION { get; }

		#endregion

		#region Move Usage Calculations

		/// <summary>
		/// Whether a move's physical/special category depends on the move itself as in
		/// newer Gens (true), or on its type as in older Gens (false).
		/// </summary>
		bool MOVE_CATEGORY_PER_MOVE { get; }

		/// <summary>
		/// Whether critical hits do 1.5x damage and have 4 stages (true), or they do 2x
		/// damage and have 5 stages as in Gen 5 (false). Also determines whether
		/// critical hit rate can be copied by Transform/Psych Up.
		/// </summary>
		bool NEW_CRITICAL_HIT_RATE_MECHANICS { get; }

		/// <summary>
		/// Whether several effects apply relating to a Pokemon's type:
		/// * Electric-type immunity to paralysis
		/// * Ghost-type immunity to being trapped
		/// * Grass-type immunity to powder moves and Effect Spore
		/// * Poison-type Pokemon can't miss when using Toxic
		/// </summary>
		bool MORE_TYPE_EFFECTS { get; }

		/// <summary>
		/// The minimum number of Gym Badges required to boost Attack by 1.1x in battle.
		/// </summary>
		int NUM_BADGES_BOOST_ATTACK { get; }

		/// <summary>
		/// The minimum number of Gym Badges required to boost Defense by 1.1x in battle.
		/// </summary>
		int NUM_BADGES_BOOST_DEFENSE { get; }

		/// <summary>
		/// The minimum number of Gym Badges required to boost Special Attack by 1.1x in battle.
		/// </summary>
		int NUM_BADGES_BOOST_SPATK { get; }

		/// <summary>
		/// The minimum number of Gym Badges required to boost Special Defense by 1.1x in battle.
		/// </summary>
		int NUM_BADGES_BOOST_SPDEF { get; }

		/// <summary>
		/// The minimum number of Gym Badges required to boost Speed by 1.1x in battle.
		/// </summary>
		int NUM_BADGES_BOOST_SPEED { get; }

		#endregion

		#region Move, Ability and Item Effects

		/// <summary>
		/// Whether the in-battle hail weather is replaced by Snowstorm (from Gen 9+).
		/// </summary>
		bool USE_SNOWSTORM_WEATHER_INSTEAD_OF_HAIL { get; }

		/// <summary>
		/// Whether weather caused by an ability lasts 5 rounds (true) or forever (false).
		/// </summary>
		bool FIXED_DURATION_WEATHER_FROM_ABILITY { get; }

		/// <summary>
		/// Whether X items (X Attack, etc.) raise their stat by 2 stages (true) or 1 (false).
		/// </summary>
		bool X_STAT_ITEMS_RAISE_BY_TWO_STAGES { get; }

		/// <summary>
		/// Whether some Poke Balls have catch rate multipliers from Gen 7 (true) or
		/// from earlier generations (false).
		/// </summary>
		bool NEW_POKE_BALL_CATCH_RATES { get; }

		/// <summary>
		/// Whether Soul Dew powers up Psychic and Dragon-type moves by 20% (true) or
		/// raises the holder's Special Attack and Special Defense by 50% (false).
		/// </summary>
		bool SOUL_DEW_POWERS_UP_TYPES { get; }

		#endregion

		#region Affection

		/// <summary>
		/// Whether Pokemon with high happiness will gain more Exp from battles, have a
		/// chance of avoiding/curing negative effects by themselves, resisting fainting, etc.
		/// </summary>
		bool AFFECTION_EFFECTS { get; }

		/// <summary>
		/// Whether a Pokemon's happiness is limited to 179, and can only be increased
		/// further with friendship-raising berries. Also lowers the happiness evolution threshold to 160.
		/// </summary>
		bool APPLY_HAPPINESS_SOFT_CAP { get; }

		#endregion

		#region Capturing Pokemon

		/// <summary>
		/// Whether the critical capture mechanic applies.
		/// Based on having caught 600+ species for maximum effect (2.5x chance).
		/// </summary>
		bool ENABLE_CRITICAL_CAPTURES { get; }

		/// <summary>
		/// Whether the player is asked what to do with a newly caught Pokemon if their
		/// party is full. Can be toggled in Options if true.
		/// </summary>
		bool NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER { get; }

		#endregion

		#region Experience and EV Gain

		/// <summary>
		/// Whether the Exp gained from beating a Pokemon should be scaled depending on
		/// the gainer's level.
		/// </summary>
		bool SCALED_EXP_FORMULA { get; }

		/// <summary>
		/// Whether the Exp gained from beating a Pokemon should be divided equally
		/// between each participant. Also affects Exp Share distribution.
		/// </summary>
		bool SPLIT_EXP_BETWEEN_GAINERS { get; }

		/// <summary>
		/// Whether the Exp gained from beating a Pokemon is multiplied by 1.5 if that
		/// Pokemon is owned by another trainer.
		/// </summary>
		bool MORE_EXP_FROM_TRAINER_POKEMON { get; }

		/// <summary>
		/// Whether a Pokemon holding a Power item gains 8 (true) or 4 (false) EVs in
		/// the relevant stat.
		/// </summary>
		bool MORE_EVS_FROM_POWER_ITEMS { get; }

		/// <summary>
		/// Whether Pokemon gain Exp for capturing a Pokemon.
		/// </summary>
		bool GAIN_EXP_FOR_CAPTURE { get; }

		#endregion

		#region End of Battle

		/// <summary>
		/// Whether trainer battles can be forfeited.
		/// </summary>
		bool CAN_FORFEIT_TRAINER_BATTLES { get; }

		/// <summary>
		/// The Game Switch which, while ON, prevents the player from losing money if
		/// they lose a battle (they can still gain money from trainers for winning).
		/// </summary>
		int NO_MONEY_LOSS { get; }

		/// <summary>
		/// Whether party Pokemon check whether they can evolve after all battles
		/// regardless of the outcome (true), or only after battles the player won (false).
		/// </summary>
		bool CHECK_EVOLUTION_AFTER_ALL_BATTLES { get; }

		/// <summary>
		/// Whether fainted Pokemon can try to evolve after a battle.
		/// </summary>
		bool CHECK_EVOLUTION_FOR_FAINTED_POKEMON { get; }

		#endregion

		#region AI

		/// <summary>
		/// Whether wild Pokemon with the "Legendary", "Mythical" or "UltraBeast" flag
		/// have a smarter AI. Their skill level is set to 32 (medium).
		/// </summary>
		bool SMARTER_WILD_LEGENDARY_POKEMON { get; }

		#endregion
	}
}