using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for move effects that affect other battler properties like status conditions, types, abilities, and positioning.
	/// </summary>
	public interface IBattleMoveEffectsBattlerOther : IBattleMove
	{
	}

	#region Sleep Effects

	/// <summary>
	/// Interface for moves that put the target to sleep.
	/// </summary>
	public interface ISleepTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that put target to sleep but fail if user is not Darkrai.
	/// Examples: Dark Void (Gen 7+)
	/// </summary>
	public interface ISleepTargetIfUserDarkrai : ISleepTarget
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Interface for moves that put target to sleep and change user's form if Meloetta.
	/// Examples: Relic Song
	/// </summary>
	public interface ISleepTargetChangeUserMeloettaForm : ISleepTarget
	{
		/// <summary>
		/// Called at the end of move usage to handle form changes.
		/// </summary>
		/// <param name="user">The Pokémon that used the move</param>
		/// <param name="targets">Array of targets hit</param>
		/// <param name="numHits">Number of successful hits</param>
		/// <param name="switchedBattlers">Array of switched battlers</param>
		void EndOfMoveUsageEffect(IBattler user, IList<IBattler> targets, int numHits, IList<IBattler> switchedBattlers);
	}

	/// <summary>
	/// Interface for moves that make the target drowsy (sleep next turn).
	/// Examples: Yawn
	/// </summary>
	public interface ISleepTargetNextTurn : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

	#endregion

	#region Poison Effects

	/// <summary>
	/// Interface for moves that poison the target.
	/// </summary>
	public interface IPoisonTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that poison target and lower its Speed by 1 stage.
	/// Examples: Toxic Thread
	/// </summary>
	public interface IPoisonTargetLowerTargetSpeed1 : IBattleMove
	{
		/// <summary>
		/// Gets the stat information for the lowering effect.
		/// </summary>
		string[] statDown { get; }

		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that poison target and remove user's binding/hazards.
	/// Examples: Mortal Spin
	/// </summary>
	public interface IPoisonTargetRemoveUserBindingAndEntryHazards : IPoisonTarget
	{
		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that badly poison the target.
	/// Examples: Poison Fang, Toxic
	/// </summary>
	public interface IBadPoisonTarget : IPoisonTarget
	{
		/// <summary>
		/// Overrides success check per hit for certain conditions.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the check should be overridden</returns>
		bool OverrideSuccessCheckPerHit(IBattler user, IBattler target);
	}

	#endregion

	#region Paralysis Effects

	/// <summary>
	/// Interface for moves that paralyze the target.
	/// </summary>
	public interface IParalyzeTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that paralyze but don't affect type-immune targets.
	/// Examples: Thunder Wave
	/// </summary>
	public interface IParalyzeTargetIfNotTypeImmune : IParalyzeTarget
	{
		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
	}

	/// <summary>
	/// Interface for moves that paralyze and have perfect accuracy in rain.
	/// Examples: Wildbolt Storm
	/// </summary>
	public interface IParalyzeTargetAlwaysHitsInRain : IParalyzeTarget
	{
		/// <summary>
		/// Calculates base accuracy for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Accuracy value</returns>
		int BaseAccuracy(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that paralyze, have weather-based accuracy, and hit flying targets.
	/// Examples: Thunder
	/// </summary>
	public interface IParalyzeTargetAlwaysHitsInRainHitsTargetInSky : IParalyzeTarget
	{
		/// <summary>
		/// Determines if the move hits flying targets.
		/// </summary>
		/// <returns>True if the move hits flying targets</returns>
		bool hitsFlyingTargets();

		/// <summary>
		/// Calculates base accuracy for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Accuracy value</returns>
		int BaseAccuracy(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that can paralyze and flinch the target.
	/// Examples: Thunder Fang
	/// </summary>
	public interface IParalyzeFlinchTarget : IBattleMove
	{
		/// <summary>
		/// Determines if this is a flinching move.
		/// </summary>
		/// <returns>True if this move can cause flinching</returns>
		bool flinchingMove();

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Burn Effects

	/// <summary>
	/// Interface for moves that burn the target.
	/// </summary>
	public interface IBurnTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that burn and have perfect accuracy in rain.
	/// Examples: Sandsear Storm
	/// </summary>
	public interface IBurnTargetAlwaysHitsInRain : IBurnTarget
	{
		/// <summary>
		/// Calculates base accuracy for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Accuracy value</returns>
		int BaseAccuracy(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that burn if target's stats were raised this turn.
	/// Examples: Burning Jealousy
	/// </summary>
	public interface IBurnTargetIfTargetStatsRaisedThisTurn : IBurnTarget
	{
		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that can burn and flinch the target.
	/// Examples: Fire Fang
	/// </summary>
	public interface IBurnFlinchTarget : IBattleMove
	{
		/// <summary>
		/// Determines if this is a flinching move.
		/// </summary>
		/// <returns>True if this move can cause flinching</returns>
		bool flinchingMove();

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Freeze Effects

	/// <summary>
	/// Interface for moves that freeze the target.
	/// </summary>
	public interface IFreezeTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that freeze and are super effective against Water.
	/// Examples: Freeze-Dry
	/// </summary>
	public interface IFreezeTargetSuperEffectiveAgainstWater : IFreezeTarget
	{
		/// <summary>
		/// Calculates type effectiveness modifier for single type matchup.
		/// </summary>
		/// <param name="moveType">The move's type</param>
		/// <param name="defType">The defending type</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Type effectiveness multiplier</returns>
		float CalcTypeModSingle(string moveType, string defType, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that freeze and have perfect accuracy in hail.
	/// Examples: Blizzard
	/// </summary>
	public interface IFreezeTargetAlwaysHitsInHail : IFreezeTarget
	{
		/// <summary>
		/// Calculates base accuracy for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Accuracy value</returns>
		int BaseAccuracy(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that can freeze and flinch the target.
	/// Examples: Ice Fang
	/// </summary>
	public interface IFreezeFlinchTarget : IBattleMove
	{
		/// <summary>
		/// Determines if this is a flinching move.
		/// </summary>
		/// <returns>True if this move can cause flinching</returns>
		bool flinchingMove();

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Multi-Status Effects

	/// <summary>
	/// Interface for moves that randomly burn, freeze, or paralyze the target.
	/// Examples: Tri Attack
	/// </summary>
	public interface IParalyzeBurnOrFreezeTarget : IBattleMove
	{
		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that randomly poison, paralyze, or put to sleep.
	/// Examples: Dire Claw
	/// </summary>
	public interface IPoisonParalyzeOrSleepTarget : IBattleMove
	{
		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Status Transfer and Curing

	/// <summary>
	/// Interface for moves that pass user's status problem to target.
	/// Examples: Psycho Shift
	/// </summary>
	public interface IGiveUserStatusToTarget : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

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
	/// Interface for moves that cure user of burn, poison, and paralysis.
	/// Examples: Refresh
	/// </summary>
	public interface ICureUserBurnPoisonParalysis : IBattleMove
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
	/// Interface for moves that cure all party Pokémon of status problems.
	/// Examples: Aromatherapy, Heal Bell
	/// </summary>
	public interface ICureUserPartyStatus : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be snatched.
		/// </summary>
		/// <returns>True if the move can be snatched</returns>
		bool canSnatch();

		/// <summary>
		/// Determines if the move works with no targets.
		/// </summary>
		/// <returns>True if the move works without targets</returns>
		bool worksWithNoTargets();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Heals a Pokémon using aromatherapy effect.
		/// </summary>
		/// <param name="pkmn">The Pokémon to heal</param>
		/// <param name="battler">The battler version (if applicable)</param>
		void AromatherapyHeal(IPokemon pkmn, IBattler battler = null);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);

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
		void ShowAnimation(string id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves that cure the target's burn.
	/// Examples: Sparkling Aria
	/// </summary>
	public interface ICureTargetBurn : IBattleMove
	{
		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that protect user's side from status problems.
	/// Examples: Safeguard
	/// </summary>
	public interface IStartUserSideImmunityToInflictedStatus : IBattleMove
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

	#region Flinching Effects

	/// <summary>
	/// Interface for moves that cause the target to flinch.
	/// </summary>
	public interface IFlinchTarget : IBattleMove
	{
		/// <summary>
		/// Determines if this is a flinching move.
		/// </summary>
		/// <returns>True if this move can cause flinching</returns>
		bool flinchingMove();

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that flinch but fail if user is not asleep.
	/// Examples: Snore
	/// </summary>
	public interface IFlinchTargetFailsIfUserNotAsleep : IFlinchTarget
	{
		/// <summary>
		/// Determines if the move is usable when asleep.
		/// </summary>
		/// <returns>True if usable when asleep</returns>
		bool usableWhenAsleep();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Interface for moves that flinch but fail if not user's first turn.
	/// Examples: Fake Out
	/// </summary>
	public interface IFlinchTargetFailsIfNotUserFirstTurn : IFlinchTarget
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Interface for moves that flinch and have double power against airborne targets.
	/// Examples: Twister
	/// </summary>
	public interface IFlinchTargetDoublePowerIfTargetInSky : IFlinchTarget
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

	#endregion

	#region Confusion Effects

	/// <summary>
	/// Interface for moves that confuse the target.
	/// </summary>
	public interface IConfuseTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that confuse and have weather-based accuracy and hit flying targets.
	/// Examples: Hurricane
	/// </summary>
	public interface IConfuseTargetAlwaysHitsInRainHitsTargetInSky : IConfuseTarget
	{
		/// <summary>
		/// Determines if the move hits flying targets.
		/// </summary>
		/// <returns>True if the move hits flying targets</returns>
		bool hitsFlyingTargets();

		/// <summary>
		/// Calculates base accuracy for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Accuracy value</returns>
		int BaseAccuracy(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that confuse and cause crash damage if they fail.
	/// Examples: Axe Kick
	/// </summary>
	public interface IConfuseTargetCrashDamageIfFails : IConfuseTarget
	{
		/// <summary>
		/// Determines if this is a recoil move.
		/// </summary>
		/// <returns>True if this is a recoil move</returns>
		bool recoilMove();

		/// <summary>
		/// Applies crash damage to the user when the move fails.
		/// </summary>
		/// <param name="user">The Pokémon that used the move</param>
		void CrashDamage(IBattler user);
	}

	#endregion

	#region Attraction Effects

	/// <summary>
	/// Interface for moves that attract the target.
	/// Examples: Attract
	/// </summary>
	public interface IAttractTarget : IBattleMove
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

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Type Changing Effects

	/// <summary>
	/// Interface for moves that change user's type based on environment.
	/// Examples: Camouflage
	/// </summary>
	public interface ISetUserTypesBasedOnEnvironment : IBattleMove
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
	/// Interface for moves that change user's type to resist the last attack.
	/// Examples: Conversion 2
	/// </summary>
	public interface ISetUserTypesToResistLastAttack : IBattleMove
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
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="show_message">Whether to show failure messages</param>
		/// <returns>True if the move fails</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that copy target's types.
	/// Examples: Reflect Type
	/// </summary>
	public interface ISetUserTypesToTargetTypes : IBattleMove
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
	/// Interface for moves that change user's type to a move's type.
	/// Examples: Conversion
	/// </summary>
	public interface ISetUserTypesToUserMoveType : IBattleMove
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
	/// Interface for moves that change target's type to Psychic.
	/// Examples: Magic Powder
	/// </summary>
	public interface ISetTargetTypesToPsychic : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that change target's type to Water.
	/// Examples: Soak
	/// </summary>
	public interface ISetTargetTypesToWater : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that add Ghost type to target.
	/// Examples: Trick-or-Treat
	/// </summary>
	public interface IAddGhostTypeToTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that add Grass type to target.
	/// Examples: Forest's Curse
	/// </summary>
	public interface IAddGrassTypeToTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that make user lose their Fire type.
	/// Examples: Burn Up
	/// </summary>
	public interface IUserLosesFireType : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that make user lose their Electric type.
	/// Examples: Double Shock
	/// </summary>
	public interface IUserLosesElectricType : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	#endregion

	#region Ability Manipulation

	/// <summary>
	/// Interface for moves that change target's ability to Simple.
	/// Examples: Simple Beam
	/// </summary>
	public interface ISetTargetAbilityToSimple : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

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
	/// Interface for moves that change target's ability to Insomnia.
	/// Examples: Worry Seed
	/// </summary>
	public interface ISetTargetAbilityToInsomnia : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

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
	/// Interface for moves that copy target's ability.
	/// Examples: Role Play
	/// </summary>
	public interface ISetUserAbilityToTargetAbility : IBattleMove
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
	/// Interface for moves that give target the user's ability.
	/// Examples: Entrainment
	/// </summary>
	public interface ISetTargetAbilityToUserAbility : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

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
	/// Interface for moves that swap user and target's abilities.
	/// Examples: Skill Swap
	/// </summary>
	public interface IUserTargetSwapAbilities : IBattleMove
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
	/// Interface for moves that negate target's ability.
	/// Examples: Gastro Acid
	/// </summary>
	public interface INegateTargetAbility : IBattleMove
	{
		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that negate target's ability if target acted.
	/// Examples: Core Enforcer
	/// </summary>
	public interface INegateTargetAbilityIfTargetActed : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that ignore target abilities for damage calculation.
	/// Examples: Moongeist Beam, Sunsteel Strike
	/// </summary>
	public interface IIgnoreTargetAbility : IBattleMove
	{
		/// <summary>
		/// Changes usage counters and sets mold breaker flag.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="specialUsage">Whether this is a special usage</param>
		void ChangeUsageCounters(IBattler user, bool specialUsage);
	}

	#endregion

	#region Positioning Effects

	/// <summary>
	/// Interface for moves that make user airborne for 5 rounds.
	/// Examples: Magnet Rise
	/// </summary>
	public interface IStartUserAirborne : IBattleMove
	{
		/// <summary>
		/// Determines if the move is unusable when Gravity is in effect.
		/// </summary>
		/// <returns>True if unusable in Gravity</returns>
		bool unusableInGravity();

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
	/// Interface for moves that make target airborne and always hit.
	/// Examples: Telekinesis
	/// </summary>
	public interface IStartTargetAirborneAndAlwaysHitByMoves : IBattleMove
	{
		/// <summary>
		/// Determines if the move is unusable when Gravity is in effect.
		/// </summary>
		/// <returns>True if unusable in Gravity</returns>
		bool unusableInGravity();

		/// <summary>
		/// Determines if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if the move can be reflected</returns>
		bool canMagicCoat();

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
	/// Interface for moves that hit airborne targets.
	/// Examples: Sky Uppercut
	/// </summary>
	public interface IHitsTargetInSky : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits flying targets.
		/// </summary>
		/// <returns>True if the move hits flying targets</returns>
		bool hitsFlyingTargets();
	}

	/// <summary>
	/// Interface for moves that hit airborne targets and ground them.
	/// Examples: Smack Down, Thousand Arrows
	/// </summary>
	public interface IHitsTargetInSkyGroundsTarget : IBattleMove
	{
		/// <summary>
		/// Determines if the move hits flying targets.
		/// </summary>
		/// <returns>True if the move hits flying targets</returns>
		bool hitsFlyingTargets();

		/// <summary>
		/// Calculates type effectiveness modifier for single type matchup.
		/// </summary>
		/// <param name="moveType">The move's type</param>
		/// <param name="defType">The defending type</param>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>Type effectiveness multiplier</returns>
		float CalcTypeModSingle(int moveType, int defType, IBattler user, IBattler target);

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that increase gravity for 5 rounds.
	/// Examples: Gravity
	/// </summary>
	public interface IStartGravity : IBattleMove
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

	#region Transformation

	/// <summary>
	/// Interface for moves that transform user into target.
	/// Examples: Transform
	/// </summary>
	public interface ITransformUserIntoTarget : IBattleMove
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

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
}