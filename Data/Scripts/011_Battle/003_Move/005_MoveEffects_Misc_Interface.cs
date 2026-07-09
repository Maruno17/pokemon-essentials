using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// No additional effect.
	/// </summary>
	/// <remarks>
	/// Interface for miscellaneous move effects including no effect moves, weather changes, terrain effects, entry hazards, and other various move behaviors.
	/// </remarks>
	//public interface IBattleMoveNone : IBattleMove
	public interface IBattleMoveEffectsMisc : IBattleMove
	{
	}

	#region No Effect Moves

	/// <summary>
	/// Does absolutely nothing. Shows a special message. (Celebrate)
	/// </summary>
	/// <remarks>
	/// Interface for moves that do absolutely nothing. Shows a special message.
	/// Examples: Celebrate
	/// </remarks>
	public interface IBattleMoveDoesNothingCongratulations : IBattleMove, IHasGeneralEffect
	{
		/// <summary>
		/// Performs the general effect when the move is used, showing a congratulations message.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Does absolutely nothing. (Hold Hands)
	/// </summary>
	/// <remarks>
	/// Interface for moves that do absolutely nothing and fail if there's no ally.
	/// Examples: Hold Hands
	/// </remarks>
	public interface IDoesNothingFailsIfNoAlly : IBattleMove, ICanFail
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
	}

	/// <summary>
	/// Does absolutely nothing. (Splash)
	/// </summary>
	/// <remarks>
	/// Interface for moves that do absolutely nothing and are unusable in Gravity.
	/// Examples: Splash
	/// </remarks>
	public interface IDoesNothingUnusableInGravity : IBattleMove, IHasGeneralEffect
	{
		/// <summary>
		/// Determines if the move is unusable when Gravity is in effect.
		/// </summary>
		/// <returns>True if unusable in Gravity</returns>
		bool unusableInGravity();

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion

	#region Money-Related Effects

	/// <summary>
	/// Scatters coins that the player picks up after winning the battle. (Pay Day)
	/// </summary>
	/// <remarks>
	/// Interface for moves that scatter coins for the player to pick up after battle.
	/// Examples: Pay Day
	/// NOTE: In Gen 6+, if the user levels up after this move is used, the amount of
	///       money picked up depends on the user's new level rather than its level
	///       when it used the move. I think this is silly, so I haven't coded this
	///       effect.
	/// </remarks>
	public interface IAddMoneyGainedFromBattle : IBattleMove, IHasGeneralEffect
	{
		/// <summary>
		/// Performs the general effect, adding money based on user's level.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Doubles the prize money the player gets after winning the battle. (Happy Hour)
	/// </summary>
	/// <remarks>
	/// Interface for moves that double the prize money from battle.
	/// Examples: Happy Hour
	/// </remarks>
	public interface IDoubleMoneyGainedFromBattle : IBattleMove, IHasGeneralEffect
	{
		/// <summary>
		/// Performs the general effect, setting the happy hour flag.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion

	#region Turn-Based Failure Conditions

	/// <summary>
	/// Fails if this isn't the user's first turn. (First Impression)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail if not used on the user's first turn.
	/// Examples: First Impression
	/// </remarks>
	public interface IFailsIfNotUserFirstTurn : IBattleMove, ICanFail
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
	/// Fails unless user has already used all other moves it knows. (Last Resort)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail unless the user has used all other known moves.
	/// Examples: Last Resort
	/// </remarks>
	public interface IFailsIfUserHasUnusedMove : IBattleMove
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
	/// Fails unless user has consumed a berry at some point. (Belch)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail unless the user has consumed a berry.
	/// Examples: Belch
	/// </remarks>
	public interface IFailsIfUserNotConsumedBerry : IBattleMove, ICanFail
	{
		/// <summary>
		/// Checks if the move can be chosen during command phase.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="commandPhase">Whether this is during command phase</param>
		/// <param name="showMessages">Whether to show messages</param>
		/// <returns>True if the move can be chosen</returns>
		bool CanChooseMove(IBattler user, bool commandPhase, bool showMessages);

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	#endregion

	#region Item-Based Conditions

	/// <summary>
	/// Fails if the target is not holding an item, or if the target is affected by
	/// Magic Room/Klutz. (Poltergeist)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail if the target has no item.
	/// Examples: Poltergeist
	/// </remarks>
	public interface IFailsIfTargetHasNoItem : IBattleMove
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

	#endregion

	#region Type-Based Conditions

	/// <summary>
	/// Only damages Pokémon that share a type with the user. (Synchronoise)
	/// </summary>
	/// <remarks>
	/// Interface for moves that only work against targets sharing a type with the user.
	/// Examples: Synchronoise
	/// </remarks>
	public interface IFailsUnlessTargetSharesTypeWithUser : IBattleMove
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

	#endregion

	#region Damage-Based Conditions

	/// <summary>
	/// ails if user was hit by a damaging move this round. (Focus Punch)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail if the user was damaged this turn.
	/// Examples: Focus Punch
	/// </remarks>
	public interface IFailsIfUserDamagedThisTurn : IBattleMove, ICanFail
	{
		/// <summary>
		/// Displays the charging message for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void DisplayChargeMessage(IBattler user);

		/// <summary>
		/// Displays the use message for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void DisplayUseMessage(IBattler user);

		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Fails if the target didn't choose a damaging move to use this round, or has
	/// already moved. (Sucker Punch)
	/// </summary>
	/// <remarks>
	/// Interface for moves that fail if the target has already acted or didn't choose a damaging move.
	/// Examples: Sucker Punch
	/// </remarks>
	public interface IFailsIfTargetActed : IBattleMove
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

	#endregion

	#region Crash Damage Moves

	/// <summary>
	/// If attack misses, user takes crash damage of 1/2 of max HP. (Supercell Slam)
	/// </summary>
	/// <remarks>
	/// Interface for moves that cause crash damage if they fail.
	/// Examples: Supercell Slam
	/// </remarks>
	public interface ICrashDamageIfFails : IBattleMove
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

	/// <summary>
	/// Interface for crash damage moves that are also unusable in Gravity.
	/// Examples: High Jump Kick, Jump Kick
	/// </summary>
	public interface ICrashDamageIfFailsUnusableInGravity : ICrashDamageIfFails
	{
		/// <summary>
		/// Determines if the move is unusable when Gravity is in effect.
		/// </summary>
		/// <returns>True if unusable in Gravity</returns>
		bool unusableInGravity();
	}

	#endregion

	#region Weather Effects

	/// <summary>
	/// Base interface for weather-changing moves.
	/// </summary>
	//public interface IWeatherMove : IBattleMove
	//{
	//}

	/// <summary>
	/// Interface for moves that start sunny weather.
	/// Examples: Sunny Day
	/// </summary>
	public interface IStartSunWeather : IWeatherMove
	{
	}

	/// <summary>
	/// Interface for moves that start rainy weather.
	/// Examples: Rain Dance
	/// </summary>
	public interface IStartRainWeather : IWeatherMove
	{
	}

	/// <summary>
	/// Interface for moves that start sandstorm weather.
	/// Examples: Sandstorm
	/// </summary>
	public interface IStartSandstormWeather : IWeatherMove
	{
	}

	/// <summary>
	/// Interface for moves that start hail weather.
	/// Examples: Hail
	/// </summary>
	public interface IStartHailWeather : IWeatherMove
	{
	}

	#endregion

	#region Terrain Effects

	/// <summary>
	/// For 5 rounds, creates an electric terrain which boosts Electric-type moves and
	/// prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
	/// (Electric Terrain)
	/// </summary>
	/// <remarks>
	/// Interface for moves that start Electric Terrain.
	/// Examples: Electric Terrain
	/// </remarks>
	public interface IStartElectricTerrain : IBattleMove, IHasGeneralEffect, ICanFail
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
	/// For 5 rounds, creates a grassy terrain which boosts Grass-type moves and heals
	/// Pokémon at the end of each round. Affects non-airborne Pokémon only.
	/// (Grassy Terrain)
	/// </summary>
	/// <remarks>
	/// Interface for moves that start Grassy Terrain.
	/// Examples: Grassy Terrain
	/// </remarks>
	public interface IStartGrassyTerrain : IBattleMove, IHasGeneralEffect, ICanFail
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
	/// For 5 rounds, creates a misty terrain which weakens Dragon-type moves and
	/// protects Pokémon from status problems. Affects non-airborne Pokémon only.
	/// (Misty Terrain)
	/// </summary>
	/// <remarks>
	/// Interface for moves that start Misty Terrain.
	/// Examples: Misty Terrain
	/// </remarks>
	public interface IStartMistyTerrain : IBattleMove, IHasGeneralEffect, ICanFail
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
	/// Interface for moves that start Psychic Terrain.
	/// Examples: Psychic Terrain
	/// </summary>
	public interface IStartPsychicTerrain : IBattleMove, IHasGeneralEffect, ICanFail
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
	/// Interface for moves that remove the current terrain.
	/// Examples: Ice Spinner
	/// </summary>
	public interface IRemoveTerrain : IBattleMove, IHasGeneralEffect
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that remove terrain but fail if no terrain is active.
	/// Examples: Steel Roller
	/// </summary>
	public interface IRemoveTerrainFailsIfNoTerrain : IRemoveTerrain, ICanFail
	{
		/// <summary>
		/// Checks if the move fails when used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	#endregion

	#region Entry Hazards

	/// <summary>
	/// Interface for moves that lay spikes on the opposing side.
	/// Examples: Spikes
	/// </summary>
	public interface IAddSpikesToFoeSide : IBattleMove, IHasGeneralEffect, ICanFail
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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that lay toxic spikes on the opposing side.
	/// Examples: Toxic Spikes
	/// </summary>
	public interface IAddToxicSpikesToFoeSide : IBattleMove, IHasGeneralEffect, ICanFail
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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that lay stealth rocks on the opposing side.
	/// Examples: Stealth Rock
	/// </summary>
	public interface IAddStealthRocksToFoeSide : IBattleMove, IHasGeneralEffect, ICanFail
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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that lay sticky web on the opposing side.
	/// Examples: Sticky Web
	/// </summary>
	public interface IAddStickyWebToFoeSide : IBattleMove, IHasGeneralEffect, ICanFail
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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Field Effect Manipulation

	/// <summary>
	/// Interface for moves that swap side effects between the two sides.
	/// Examples: Court Change
	/// </summary>
	public interface ISwapSideEffects : IBattleMove, IHasGeneralEffect, ICanFail
	{
		/// <summary>
		/// Gets the list of numeric side effects that can be swapped.
		/// </summary>
		int[] number_effects { get; }

		/// <summary>
		/// Gets the list of boolean side effects that can be swapped.
		/// </summary>
		int[] boolean_effects { get; }

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

	#region Substitute and Binding

	/// <summary>
	/// Interface for moves that create a substitute for the user.
	/// Examples: Substitute
	/// </summary>
	public interface IUserMakeSubstitute : IBattleMove, IHasGeneralEffect, ICanFail
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
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that remove binding moves and entry hazards.
	/// Examples: Rapid Spin
	/// </summary>
	public interface IRemoveUserBindingAndEntryHazards : IBattleMove
	{
		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);

		/// <summary>
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	#endregion

	#region Future Attack

	/// <summary>
	/// Interface for moves that attack two turns in the future.
	/// Examples: Doom Desire, Future Sight
	/// </summary>
	public interface IAttackTwoTurnsLater : IBattleMove
	{
		/// <summary>
		/// Determines if the move targets a position rather than a Pokémon.
		/// </summary>
		/// <returns>True if the move targets a position</returns>
		bool targetsPosition();

		/// <summary>
		/// Determines if this is currently a damaging move.
		/// </summary>
		/// <returns>True if this is a damaging move</returns>
		bool DamagingMove();

		/// <summary>
		/// Performs accuracy check for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the move hits</returns>
		bool AccuracyCheck(IBattler user, IBattler target);

		/// <summary>
		/// Displays the use message for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void DisplayUseMessage(IBattler user);

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
		void ShowAnimation(string id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	#endregion

	#region Position Swapping

	/// <summary>
	/// Interface for moves that swap positions with an ally.
	/// Examples: Ally Switch
	/// </summary>
	public interface IUserSwapsPositionsWithAlly : IBattleMove, IHasGeneralEffect, ICanFail
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

	#region Contact-Based Effects

	/// <summary>
	/// Interface for moves that burn attackers who make contact before the user acts.
	/// Examples: Beak Blast
	/// </summary>
	public interface IBurnAttackerBeforeUserActs : IBattleMove
	{
		/// <summary>
		/// Displays the charging message for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void DisplayChargeMessage(IBattler user);
	}

	#endregion
}