using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for move usage calculations, mirroring the Ruby Battle::Move logic.
	/// </summary>
	public interface IBattleMoveUsageCalculations : IBattleMove
	{
		#region Move's type calculation.
		/// <summary>
		/// Gets the base type of the move, possibly modified by abilities.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <returns>The base type as an enum.</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Calculates the effective type of the move, considering field effects and Electrify/Ion Deluge.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <returns>The calculated type as an enum.</returns>
		int CalcType(IBattler user);
		#endregion

		#region Type effectiveness calculation.
		/// <summary>
		/// Calculates the type effectiveness modifier for a single defending type.
		/// </summary>
		/// <param name="moveType">The attacking type.</param>
		/// <param name="defType">The defending type.</param>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The effectiveness multiplier.</returns>
		double CalcTypeModSingle(int moveType, int defType, IBattler user, IBattler target);

		/// <summary>
		/// Calculates the total type effectiveness modifier for the target.
		/// </summary>
		/// <param name="moveType">The attacking type.</param>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The effectiveness multiplier.</returns>
		double CalcTypeMod(int moveType, IBattler user, IBattler target);
		#endregion

		#region Accuracy check.
		/// <summary>
		/// Gets the base accuracy of the move against the target.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The base accuracy value.</returns>
		int BaseAccuracy(IBattler user, IBattler target);

		/// <summary>
		/// Checks if the move hits the target, considering all accuracy/evasion modifiers.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>True if the move hits, false otherwise.</returns>
		bool AccuracyCheck(IBattler user, IBattler target);

		/// <summary>
		/// Calculates all accuracy/evasion modifiers for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <param name="modifiers">A structure holding all relevant modifiers.</param>
		void CalcAccuracyModifiers(IBattler user, IBattler target, AccuracyModifiers modifiers);
		#endregion

		#region Critical hit check.
		/// <summary>
		/// Returns whether the move is always/never/normal critical hit.
		/// -1: Never critical, 0: Normal, 1: Always critical.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>Critical hit override value.</returns>
		int CritialOverride(IBattler user, IBattler target);

		/// <summary>
		/// Returns whether the move will be a critical hit.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>True if critical, false otherwise.</returns>
		bool IsCritical(IBattler user, IBattler target);
		#endregion

		#region Damage calculation.
		/// <summary>
		/// Gets the base damage for the move.
		/// </summary>
		/// <param name="baseDmg">The base damage value.</param>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The base damage value.</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Modifies the base damage multiplier for the move.
		/// </summary>
		/// <param name="damageMult">The current damage multiplier.</param>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The modified damage multiplier.</returns>
		double BaseDamageMultiplier(double damageMult, IBattler user, IBattler target);

		/// <summary>
		/// Modifies the final damage multiplier for the move.
		/// </summary>
		/// <param name="damageMult">The current damage multiplier.</param>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The modified damage multiplier.</returns>
		double ModifyDamage(double damageMult, IBattler user, IBattler target);

		/// <summary>
		/// Gets the user's attack stat and stage for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>A tuple of (attack stat, stage).</returns>
		KeyValuePair<int, int> GetAttackStats(IBattler user, IBattler target);

		/// <summary>
		/// Gets the target's defense stat and stage for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>A tuple of (defense stat, stage).</returns>
		KeyValuePair<int, int> GetDefenseStats(IBattler user, IBattler target);

		/// <summary>
		/// Calculates the damage for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <param name="numTargets">The number of targets.</param>
		void CalcDamage(IBattler user, IBattler target, int numTargets = 1);

		/// <summary>
		/// Calculates all damage multipliers for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <param name="numTargets">The number of targets.</param>
		/// <param name="type">The move type.</param>
		/// <param name="baseDmg">The base damage.</param>
		/// <param name="multipliers">A structure holding all relevant multipliers.</param>
		void CalcDamageMultipliers(IBattler user, IBattler target, int numTargets, int type, int baseDmg, DamageMultipliers multipliers);
		#endregion

		#region Additional effect chance.
		/// <summary>
		/// Gets the additional effect chance for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <param name="effectChance">The base effect chance (optional).</param>
		/// <returns>The final effect chance.</returns>
		int AdditionalEffectChance(IBattler user, IBattler target, int effectChance = 0);

		/// <summary>
		/// Gets the flinch chance for the move.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		/// <returns>The flinch chance as a percentage.</returns>
		int FlinchChance(IBattler user, IBattler target);
		#endregion
	}

	/// <summary>
	/// Structure for accuracy/evasion modifiers.
	/// </summary>
	public struct AccuracyModifiers
	{
		public int BaseAccuracy;
		public int AccuracyStage;
		public int EvasionStage;
		public double AccuracyMultiplier;
		public double EvasionMultiplier;
	}

	/// <summary>
	/// Structure for damage multipliers.
	/// </summary>
	public struct DamageMultipliers
	{
		public double PowerMultiplier;
		public double AttackMultiplier;
		public double DefenseMultiplier;
		public double FinalDamageMultiplier;
	}
}