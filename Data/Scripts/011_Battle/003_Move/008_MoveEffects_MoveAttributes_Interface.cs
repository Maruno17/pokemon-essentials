using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for move effects that modify move attributes like damage calculation, type, accuracy, and special mechanics.
	/// </summary>
	public interface IMoveEffectsMoveAttributes
	{
	}

	#region Fixed Damage Moves

	/// <summary>
	/// Interface for moves that inflict a fixed 20HP damage.
	/// Examples: Sonic Boom
	/// </summary>
	public interface IFixedDamage20 : IFixedDamageMove
	{
		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that inflict a fixed 40HP damage.
	/// Examples: Dragon Rage
	/// </summary>
	public interface IFixedDamage40 : IFixedDamageMove
	{
		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that halve the target's current HP.
	/// Examples: Nature's Madness, Super Fang
	/// </summary>
	public interface IFixedDamageHalfTargetHP : IFixedDamageMove
	{
		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that inflict damage equal to the user's level.
	/// Examples: Night Shade, Seismic Toss
	/// </summary>
	public interface IFixedDamageUserLevel : IFixedDamageMove
	{
		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that inflict damage between 0.5 and 1.5 times the user's level.
	/// Examples: Psywave
	/// </summary>
	public interface IFixedDamageUserLevelRandom : IFixedDamageMove
	{
		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that bring target's HP down to equal the user's HP.
	/// Examples: Endeavor
	/// </summary>
	public interface ILowerTargetHPToUserHP : IFixedDamageMove
	{
		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Returns the number of hits for this move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>Number of hits</returns>
		int NumHits(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);
	}

	#endregion

	#region OHKO Moves

	/// <summary>
	/// Interface for One-Hit KO moves.
	/// </summary>
	public interface IOHKO : IFixedDamageMove
	{
		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Performs accuracy check for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the move hits</returns>
		bool AccuracyCheck(IBattler user, IBattler target);

		/// <summary>
		/// Calculates the fixed damage amount.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Fixed damage value</returns>
		int FixedDamage(IBattler user, IBattler target);

		/// <summary>
		/// Shows hit effectiveness messages.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="numTargets">Number of targets</param>
		void HitEffectivenessMessages(IBattler user, IBattler target, int numTargets = 1);
	}

	/// <summary>
	/// Interface for Ice-type OHKO moves with special conditions.
	/// Examples: Sheer Cold (Gen 7+)
	/// </summary>
	public interface IOHKOIce : IOHKO
	{
		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Performs accuracy check for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the move hits</returns>
		bool AccuracyCheck(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for OHKO moves that hit underground targets.
	/// Examples: Fissure
	/// </summary>
	public interface IOHKOHitsUndergroundTarget : IOHKO
	{
		/// <summary>
		/// Determines if the move hits digging targets.
		/// </summary>
		/// <returns>True if the move hits digging targets</returns>
		bool hitsDiggingTargets();
	}

	#endregion

	#region Special Damage Effects

	/// <summary>
	/// Interface for moves that damage the target's ally.
	/// Examples: Flame Burst
	/// </summary>
	public interface IDamageTargetAlly : IBattleMove
	{
		/// <summary>
		/// Performs effects when dealing damage to target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectWhenDealingDamage(IBattler user, IBattler target);
	}

	#endregion

	#region HP-Based Power Moves

	/// <summary>
	/// Interface for moves with power that increases with user's HP.
	/// Examples: Eruption, Water Spout
	/// </summary>
	public interface IPowerHigherWithUserHP : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that decreases with user's HP.
	/// Examples: Flail, Reversal
	/// </summary>
	public interface IPowerLowerWithUserHP : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases with target's HP (100 base).
	/// Examples: Hard Press
	/// </summary>
	public interface IPowerHigherWithTargetHP100 : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases with target's HP (120 base).
	/// Examples: Crush Grip, Wring Out
	/// </summary>
	public interface IPowerHigherWithTargetHP120 : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Happiness-Based Power Moves

	/// <summary>
	/// Interface for moves with power that increases with user's happiness.
	/// Examples: Return
	/// </summary>
	public interface IPowerHigherWithUserHappiness : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that decreases with user's happiness.
	/// Examples: Frustration
	/// </summary>
	public interface IPowerLowerWithUserHappiness : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Stat Stage-Based Power Moves

	/// <summary>
	/// Interface for moves with power that increases with user's positive stat stages.
	/// Examples: Power Trip, Stored Power
	/// </summary>
	public interface IPowerHigherWithUserPositiveStatStages : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases with target's positive stat stages.
	/// Examples: Punishment
	/// </summary>
	public interface IPowerHigherWithTargetPositiveStatStages : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Speed-Based Power Moves

	/// <summary>
	/// Interface for moves with power that increases when user is faster than target.
	/// Examples: Electro Ball
	/// </summary>
	public interface IPowerHigherWithUserFasterThanTarget : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases when target is faster than user.
	/// Examples: Gyro Ball
	/// </summary>
	public interface IPowerHigherWithTargetFasterThanUser : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region PP and Weight-Based Power Moves

	/// <summary>
	/// Interface for moves with power that increases with less PP.
	/// Examples: Trump Card
	/// </summary>
	public interface IPowerHigherWithLessPP : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases with target's weight.
	/// Examples: Grass Knot, Low Kick
	/// </summary>
	public interface IPowerHigherWithTargetWeight : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases when user is heavier than target.
	/// Examples: Heat Crash, Heavy Slam
	/// </summary>
	public interface IPowerHigherWithUserHeavierThanTarget : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Consecutive Use Power Moves

	/// <summary>
	/// Interface for moves with power that doubles for each consecutive use.
	/// Examples: Fury Cutter
	/// </summary>
	public interface IPowerHigherWithConsecutiveUse : IBattleMove
	{
		/// <summary>
		/// Changes usage counters when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="specialUsage">Whether this is a special usage</param>
		void ChangeUsageCounters(IBattler user, bool specialUsage);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with power that increases with consecutive use on user's side.
	/// Examples: Echoed Voice
	/// </summary>
	public interface IPowerHigherWithConsecutiveUseOnUserSide : IBattleMove
	{
		/// <summary>
		/// Changes usage counters when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="specialUsage">Whether this is a special usage</param>
		void ChangeUsageCounters(IBattler user, bool specialUsage);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Random and Variable Power Moves

	/// <summary>
	/// Interface for moves with random power that double if target is underground.
	/// Examples: Magnitude
	/// </summary>
	public interface IRandomPowerDoublePowerIfTargetUnderground : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits digging targets.
		/// </summary>
		/// <returns>True if the move hits digging targets</returns>
		bool hitsDiggingTargets();

		/// <summary>
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Modifies damage calculation.
		/// </summary>
		/// <param name="damageMult">Damage multiplier</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage multiplier</returns>
		float ModifyDamage(float damageMult, IBattler user, IBattler target);
	}

	#endregion

	#region Environmental Power Modifiers

	/// <summary>
	/// Interface for moves with increased power in sunny weather.
	/// Examples: Hydro Steam
	/// </summary>
	public interface IIncreasePowerInSun : IBattleMove
	{
	}

	/// <summary>
	/// Interface for moves with increased power in Electric Terrain.
	/// Examples: Psyblade
	/// </summary>
	public interface IIncreasePowerInElectricTerrain : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with increased power if super effective.
	/// Examples: Electro Drift
	/// </summary>
	public interface IIncreasePowerIfSuperEffective : IBattleMove
	{
		/// <summary>
		/// Modifies damage calculation.
		/// </summary>
		/// <param name="damageMult">Damage multiplier</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage multiplier</returns>
		float ModifyDamage(float damageMult, IBattler user, IBattler target);
	}

	#endregion

	#region Conditional Double Power Moves

	/// <summary>
	/// Interface for moves with 30% chance to double power.
	/// Examples: Fickle Beam
	/// </summary>
	public interface IDoublePower30PercentChance : IBattleMove
	{
		/// <summary>
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves with double power if target's HP is 1/2 or less.
	/// Examples: Brine
	/// </summary>
	public interface IDoublePowerIfTargetHPLessThanHalf : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with double power if user has status conditions.
	/// Examples: Facade
	/// </summary>
	public interface IDoublePowerIfUserPoisonedBurnedParalyzed : IBattleMove
	{
		/// <summary>
		/// Determines if damage is reduced by burn.
		/// </summary>
		/// <returns>True if burn reduces damage</returns>
		bool damageReducedByBurn();

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with double power if target is asleep and wake them up.
	/// Examples: Wake-Up Slap
	/// </summary>
	public interface IDoublePowerIfTargetAsleepCureTarget : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with double power if target is poisoned.
	/// Examples: Venoshock
	/// </summary>
	public interface IDoublePowerIfTargetPoisoned : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target poisoned, then poison target.
	/// Examples: Barb Barrage
	/// </summary>
	public interface IDoublePowerIfTargetPoisonedPoisonTarget : IPoisonTarget
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target paralyzed and cure them.
	/// Examples: Smelling Salts
	/// </summary>
	public interface IDoublePowerIfTargetParalyzedCureTarget : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target has any status problem.
	/// Examples: Hex
	/// </summary>
	public interface IDoublePowerIfTargetStatusProblem : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target has status, then burn target.
	/// Examples: Infernal Parade
	/// </summary>
	public interface IDoublePowerIfTargetStatusProblemBurnTarget : IBurnTarget
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if user has no held item.
	/// Examples: Acrobatics
	/// </summary>
	public interface IDoublePowerIfUserHasNoItem : IBattleMove
	{
		/// <summary>
		/// Calculates base damage multiplier for the move.
		/// </summary>
		/// <param name="damageMult">Damage multiplier</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage multiplier</returns>
		float BaseDamageMultiplier(float damageMult, IBattler user, IBattler target);
	}

	#endregion

	#region Environmental Double Power Moves

	/// <summary>
	/// Interface for moves that double power if target is underwater.
	/// Examples: Surf
	/// </summary>
	public interface IDoublePowerIfTargetUnderwater : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits diving targets.
		/// </summary>
		/// <returns>True if the move hits diving targets</returns>
		bool hitsDivingTargets();

		/// <summary>
		/// Modifies damage calculation.
		/// </summary>
		/// <param name="damageMult">Damage multiplier</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage multiplier</returns>
		float ModifyDamage(float damageMult, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target is underground.
	/// Examples: Earthquake
	/// </summary>
	public interface IDoublePowerIfTargetUnderground : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits digging targets.
		/// </summary>
		/// <returns>True if the move hits digging targets</returns>
		bool hitsDiggingTargets();

		/// <summary>
		/// Modifies damage calculation.
		/// </summary>
		/// <param name="damageMult">Damage multiplier</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage multiplier</returns>
		float ModifyDamage(float damageMult, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target is in the sky.
	/// Examples: Gust
	/// </summary>
	public interface IDoublePowerIfTargetInSky : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits flying targets.
		/// </summary>
		/// <returns>True if the move hits flying targets</returns>
		bool hitsFlyingTargets();

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power in Electric Terrain.
	/// Examples: Rising Voltage
	/// </summary>
	public interface IDoublePowerInElectricTerrain : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Situational Double Power Moves

	/// <summary>
	/// Interface for moves that double power if user's last move failed.
	/// Examples: Stomping Tantrum
	/// </summary>
	public interface IDoublePowerIfUserLastMoveFailed : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if ally fainted last turn.
	/// Examples: Retaliate
	/// </summary>
	public interface IDoublePowerIfAllyFaintedLastTurn : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if user lost HP from target this turn.
	/// Examples: Avalanche, Revenge
	/// </summary>
	public interface IDoublePowerIfUserLostHPThisTurn : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target lost HP this turn.
	/// Examples: Assurance
	/// </summary>
	public interface IDoublePowerIfTargetLostHPThisTurn : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if user's stats were lowered this turn.
	/// Examples: Lash Out
	/// </summary>
	public interface IDoublePowerIfUserStatsLoweredThisTurn : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target has already acted.
	/// Examples: Payback
	/// </summary>
	public interface IDoublePowerIfTargetActed : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that double power if target hasn't acted yet.
	/// Examples: Bolt Beak, Fishious Rend
	/// </summary>
	public interface IDoublePowerIfTargetNotActed : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	#endregion

	#region Critical Hit Effects

	/// <summary>
	/// Interface for moves that always critical hit.
	/// Examples: Frost Breath, Storm Throw
	/// </summary>
	public interface IAlwaysCriticalHit : IBattleMove
	{
		/// <summary>
		/// Overrides critical hit calculation.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Critical hit override value</returns>
		int CritialOverride(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that ensure next move is a critical hit.
	/// Examples: Laser Focus
	/// </summary>
	public interface IEnsureNextCriticalHit : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that prevent critical hits against user's side.
	/// Examples: Lucky Chant
	/// </summary>
	public interface IStartPreventCriticalHitsAgainstUserSide : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion

	#region Special Damage Mechanics

	/// <summary>
	/// Interface for moves that cannot make the target faint.
	/// Examples: False Swipe, Hold Back
	/// </summary>
	public interface ICannotMakeTargetFaint : IBattleMove
	{
		/// <summary>
		/// Determines if this is a non-lethal move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the move is non-lethal</returns>
		bool nonLethal(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that allow user to endure fainting this turn.
	/// Examples: Endure
	/// </summary>
	public interface IUserEnduresFaintingThisTurn : IProtectMove
	{
		/// <summary>
		/// Shows the protection message.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void ProtectMessage(IBattler user);
	}

	#endregion

	#region Move Type Weakening

	/// <summary>
	/// Interface for moves that weaken Electric attacks.
	/// Examples: Mud Sport
	/// </summary>
	public interface IStartWeakenElectricMoves : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that weaken Fire attacks.
	/// Examples: Water Sport
	/// </summary>
	public interface IStartWeakenFireMoves : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion

	#region Defensive Barriers

	/// <summary>
	/// Interface for moves that weaken physical damage against user's side.
	/// Examples: Reflect
	/// </summary>
	public interface IStartWeakenPhysicalDamageAgainstUserSide : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that weaken special damage against user's side.
	/// Examples: Light Screen
	/// </summary>
	public interface IStartWeakenSpecialDamageAgainstUserSide : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that weaken damage against user's side in hail.
	/// Examples: Aurora Veil
	/// </summary>
	public interface IStartWeakenDamageAgainstUserSideIfHail : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that remove opponent's screens.
	/// Examples: Brick Break, Psychic Fangs
	/// </summary>
	public interface IRemoveScreens : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Reflect.
		/// </summary>
		/// <returns>True if the move ignores Reflect</returns>
		bool ignoresReflect();

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	#endregion

	#region Protection Moves

	/// <summary>
	/// Interface for standard protection moves.
	/// Examples: Detect, Protect
	/// </summary>
	public interface IProtectUser : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that poison on contact.
	/// Examples: Baneful Bunker
	/// </summary>
	public interface IProtectUserBanefulBunker : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that burn on contact.
	/// Examples: Burning Bulwark
	/// </summary>
	public interface IProtectUserFromDamagingMovesBurningBulwark : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that lower Attack on contact.
	/// Examples: King's Shield
	/// </summary>
	public interface IProtectUserFromDamagingMovesKingsShield : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that lower Defense on contact.
	/// Examples: Obstruct
	/// </summary>
	public interface IProtectUserFromDamagingMovesObstruct : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that lower Speed on contact.
	/// Examples: Silk Trap
	/// </summary>
	public interface IProtectUserFromDamagingMovesSilkTrap : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that damage on contact.
	/// Examples: Spiky Shield
	/// </summary>
	public interface IProtectUserFromTargetingMovesSpikyShield : IProtectMove
	{
	}

	/// <summary>
	/// Interface for protection moves that protect side from damage if first turn.
	/// Examples: Mat Block
	/// </summary>
	public interface IProtectUserSideFromDamagingMovesIfUserFirstTurn : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that protect side from status moves.
	/// Examples: Crafty Shield
	/// </summary>
	public interface IProtectUserSideFromStatusMoves : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that protect side from priority moves.
	/// Examples: Quick Guard
	/// </summary>
	public interface IProtectUserSideFromPriorityMoves : IProtectMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();
	}

	/// <summary>
	/// Interface for moves that protect side from multi-target moves.
	/// Examples: Wide Guard
	/// </summary>
	public interface IProtectUserSideFromMultiTargetDamagingMoves : IProtectMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();
	}

	#endregion

	#region Protection Removal

	/// <summary>
	/// Interface for moves that remove target's protections.
	/// Examples: Feint
	/// </summary>
	public interface IRemoveProtections : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that remove protections and bypass Substitute.
	/// Examples: Hyperspace Hole
	/// </summary>
	public interface IRemoveProtectionsBypassSubstitute : IRemoveProtections
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);
	}

	/// <summary>
	/// Interface for Hoopa's special protection-removing move.
	/// Examples: Hyperspace Fury
	/// </summary>
	public interface IHoopaRemoveProtectionsBypassSubstituteLowerUserDef1 : IStatDownMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	#endregion

	#region Recoil Moves

	/// <summary>
	/// Interface for moves with 1/4 recoil damage.
	/// </summary>
	public interface IRecoilQuarterOfDamageDealt : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with 1/3 recoil damage.
	/// </summary>
	public interface IRecoilThirdOfDamageDealt : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with 1/3 recoil damage that may paralyze.
	/// Examples: Volt Tackle
	/// </summary>
	public interface IRecoilThirdOfDamageDealtParalyzeTarget : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with 1/3 recoil damage that may burn.
	/// Examples: Flare Blitz
	/// </summary>
	public interface IRecoilThirdOfDamageDealtBurnTarget : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with 1/2 recoil damage.
	/// Examples: Head Smash, Light of Ruin
	/// </summary>
	public interface IRecoilHalfOfDamageDealt : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with 1/2 max HP recoil damage.
	/// Examples: Chloroblast
	/// </summary>
	public interface IRecoilHalfOfTotalHP : IRecoilMove
	{
		/// <summary>
		/// Calculates recoil damage.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Recoil damage amount</returns>
		int RecoilDamage(IBattler user, IBattler target);
	}

	#endregion

	#region Type Effectiveness Modifiers

	/// <summary>
	/// Interface for moves that include Flying-type effectiveness.
	/// Examples: Flying Press
	/// </summary>
	public interface IEffectivenessIncludesFlyingType : IBattleMove
	{
		/// <summary>
		/// Calculates type effectiveness modifier for single type matchup.
		/// </summary>
		/// <param name="moveType">The move's type</param>
		/// <param name="defType">The defending type</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Type effectiveness multiplier</returns>
		float CalcTypeModSingle(int moveType, int defType, IBattler user, IBattler target);
	}

	#endregion

	#region Category-Dependent Moves

	/// <summary>
	/// Interface for moves with category based on higher damage and poison target.
	/// Examples: Shell Side Arm
	/// </summary>
	public interface ICategoryDependsOnHigherDamagePoisonTarget : IPoisonTarget
	{
		/// <summary>
		/// Determines if this is a physical move.
		/// </summary>
		/// <param name="thisType">Type being checked</param>
		/// <returns>True if physical</returns>
		bool physicalMove(int? thisType = null);

		/// <summary>
		/// Determines if this is a special move.
		/// </summary>
		/// <param name="thisType">Type being checked</param>
		/// <returns>True if special</returns>
		bool specialMove(int? thisType = null);

		/// <summary>
		/// Determines if this move makes contact.
		/// </summary>
		/// <returns>True if contact move</returns>
		bool contactMove();

		/// <summary>
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves with category based on higher damage, ignoring ability.
	/// Examples: Photon Geyser
	/// </summary>
	public interface ICategoryDependsOnHigherDamageIgnoreTargetAbility : IIgnoreTargetAbility
	{
		/// <summary>
		/// Determines if this is a physical move.
		/// </summary>
		/// <param name="thisType">Type being checked</param>
		/// <returns>True if physical</returns>
		bool physicalMove(int? thisType = null);

		/// <summary>
		/// Determines if this is a special move.
		/// </summary>
		/// <param name="thisType">Type being checked</param>
		/// <returns>True if special</returns>
		bool specialMove(int? thisType = null);

		/// <summary>
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);
	}

	#endregion

	#region Stat-Based Damage Calculation

	/// <summary>
	/// Interface for moves that use user's Defense instead of Attack.
	/// Examples: Body Press
	/// </summary>
	public interface IUseUserDefenseInsteadOfUserAttack : IBattleMove
	{
		/// <summary>
		/// Gets the attack stats for damage calculation.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Attack stat and stage values</returns>
		//(int stat, int stage) GetAttackStats(IBattler user, IBattler target);
		KeyValuePair<int, int> GetAttackStats(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that use target's Attack instead of user's Attack.
	/// Examples: Foul Play
	/// </summary>
	public interface IUseTargetAttackInsteadOfUserAttack : IBattleMove
	{
		/// <summary>
		/// Gets the attack stats for damage calculation.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Attack stat and stage values</returns>
		//(int stat, int stage) GetAttackStats(IBattler user, IBattler target);
		KeyValuePair<int, int> GetAttackStats(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that use target's Defense instead of Sp. Defense.
	/// Examples: Psyshock, Psystrike, Secret Sword
	/// </summary>
	public interface IUseTargetDefenseInsteadOfTargetSpDef : IBattleMove
	{
		/// <summary>
		/// Gets the defense stats for damage calculation.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Defense stat and stage values</returns>
		//(int stat, int stage) GetDefenseStats(IBattler user, IBattler target);
		KeyValuePair<int, int> GetDefenseStats(IBattler user, IBattler target);
	}

	#endregion

	#region Accuracy and Targeting

	/// <summary>
	/// Interface for moves that ensure next move always hits.
	/// Examples: Lock-On, Mind Reader
	/// </summary>
	public interface IEnsureNextMoveAlwaysHits : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that negate target's evasion and Ghost immunity.
	/// Examples: Foresight, Odor Sleuth
	/// </summary>
	public interface IStartNegateTargetEvasionStatStageAndGhostImmunity : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that negate target's evasion and Dark immunity.
	/// Examples: Miracle Eye
	/// </summary>
	public interface IStartNegateTargetEvasionStatStageAndDarkImmunity : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that ignore target's defensive stat stages.
	/// Examples: Chip Away, Darkest Lariat, Sacred Sword
	/// </summary>
	public interface IIgnoreTargetDefSpDefEvaStatStages : IBattleMove
	{
		/// <summary>
		/// Calculates accuracy modifiers for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="modifiers">Dictionary of accuracy modifiers</param>
		void CalcAccuracyModifiers(IBattler user, IBattler target, IDictionary<int, object> modifiers);

		/// <summary>
		/// Gets the defense stats for damage calculation.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Defense stat and stage values</returns>
		//(int stat, int stage) GetDefenseStats(IBattler user, IBattler target);
		KeyValuePair<int, int> GetDefenseStats(IBattler user, IBattler target);
	}

	#endregion

	#region Type-Changing Moves by User

	/// <summary>
	/// Interface for moves with type based on user's first type.
	/// Examples: Revelation Dance
	/// </summary>
	public interface ITypeIsUserFirstType : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Interface for moves with type based on Ogerpon's form.
	/// Examples: Ivy Cudgel
	/// </summary>
	public interface ITypeDependsOnUserOgerponForm : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Interface for moves with type based on Tauros form that remove screens.
	/// Examples: Raging Bull
	/// </summary>
	public interface ITypeDependsOnUserTaurosFormRemoveScreens : IRemoveScreens
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Interface for moves with type and power based on user's IVs.
	/// Examples: Hidden Power
	/// </summary>
	public interface ITypeDependsOnUserIVs : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves with type and power based on user's berry.
	/// Examples: Natural Gift
	/// </summary>
	public interface ITypeAndPowerDependOnUserBerry : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Called at the end of move usage to handle item consumption.
		/// </summary>
		/// <param name="user">The Pokémon that used the move</param>
		/// <param name="targets">Array of targets hit</param>
		/// <param name="numHits">Number of successful hits</param>
		/// <param name="switchedBattlers">Array of switched battlers</param>
		void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, IList<IBattler> switchedBattlers);
	}

	/// <summary>
	/// Interface for moves with type based on user's held Plate.
	/// Examples: Judgment
	/// </summary>
	public interface ITypeDependsOnUserPlate : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Interface for moves with type based on user's held Memory.
	/// Examples: Multi-Attack
	/// </summary>
	public interface ITypeDependsOnUserMemory : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Interface for moves with type based on user's held Drive.
	/// Examples: Techno Blast
	/// </summary>
	public interface ITypeDependsOnUserDrive : IBattleMove
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves with type based on Morpeko's form and raise Speed.
	/// Examples: Aura Wheel
	/// </summary>
	public interface ITypeDependsOnUserMorpekoFormRaiseUserSpeed1 : IRaiseUserSpeed1
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);
	}

	#endregion

	#region Environmental Type-Changing Moves

	/// <summary>
	/// Interface for moves with type and power based on weather.
	/// Examples: Weather Ball
	/// </summary>
	public interface ITypeAndPowerDependOnWeather : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves with type and power based on terrain.
	/// Examples: Terrain Pulse
	/// </summary>
	public interface ITypeAndPowerDependOnTerrain : IBattleMove
	{
		/// <summary>
		/// Calculates base damage for the move.
		/// </summary>
		/// <param name="baseDmg">Base damage value</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);

		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>The move's type</returns>
		int BaseType(IBattler user);

		/// <summary>
		/// Shows the animation for the move.
		/// </summary>
		/// <param name="id">The move ID</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <param name="hitNum">Hit number for multi-hit moves</param>
		/// <param name="showAnimation">Whether to show the animation</param>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	#endregion

	#region Move Type Changing Effects

	/// <summary>
	/// Interface for moves that make target's moves become Electric-type.
	/// Examples: Electrify
	/// </summary>
	public interface ITargetMovesBecomeElectric : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that make all Normal moves become Electric-type.
	/// Examples: Ion Deluge, Plasma Fists
	/// </summary>
	public interface INormalMovesBecomeElectric : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion
}