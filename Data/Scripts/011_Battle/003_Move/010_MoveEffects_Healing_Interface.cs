using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for healing-related move effects, including HP restoration, draining, sacrifice moves, and status effects.
	/// Provides functionality for moves like Rest, Moonlight, Dream Eater, Explosion, and Perish Song.
	/// </summary>
	public interface IBattleMoveEffectsHealing : IBattleMove
	{
	}

	/// <summary>
	/// Interface for moves that heal the user to full HP and put them to sleep.
	/// Examples: Rest
	/// </summary>
	public interface IHealUserFullyAndFallAsleep : IHealingMove, IHasHealAmount
	{
		/// <summary>
		/// Checks if the move fails due to already being asleep or inability to sleep.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Calculates the amount of HP to heal.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);

		/// <summary>
		/// Applies the sleep and healing effect.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that heal the user by half their max HP.
	/// Examples: Recover, Soft-Boiled
	/// </summary>
	public interface IHealUserHalfOfTotalHP
	{
		/// <summary>
		/// Calculates the amount of HP to heal (half of max HP).
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);
	}

	/// <summary>
	/// Interface for weather-dependent healing moves.
	/// Examples: Moonlight, Morning Sun, Synthesis
	/// </summary>
	public interface IHealUserDependingOnWeather
	{
		/// <summary>
		/// Calculates heal amount based on current weather conditions.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Gets the pre-calculated heal amount.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);
	}

	/// <summary>
	/// Interface for moves that heal more in sandstorm conditions.
	/// Examples: Shore Up
	/// </summary>
	public interface IHealUserDependingOnSandstorm
	{
		/// <summary>
		/// Calculates heal amount based on sandstorm presence.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);
	}

	/// <summary>
	/// Interface for moves that heal and remove Flying type temporarily.
	/// Examples: Roost
	/// </summary>
	public interface IHealUserHalfOfTotalHPLoseFlyingTypeThisTurn
	{
		/// <summary>
		/// Calculates heal amount (half of max HP).
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);

		/// <summary>
		/// Applies healing and Flying type removal effects.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that cure target's status and heal the user.
	/// Examples: Purify
	/// </summary>
	public interface ICureTargetStatusHealUserHalfOfTotalHP
	{
		/// <summary>
		/// Checks if the move can be snatched.
		/// </summary>
		/// <returns>False for moves that affect targets</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if reflectable</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Calculates heal amount for the user.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <returns>Amount of HP to restore</returns>
		int HealAmount(IBattler user);

		/// <summary>
		/// Cures target's status and heals the user.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that heal based on target's Attack stat.
	/// Examples: Strength Sap
	/// </summary>
	public interface IHealUserByTargetAttackLowerTargetAttack1
	{
		/// <summary>
		/// Gets the stat that will be lowered.
		/// </summary>
		object statDown { get; }

		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if reflectable</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Lowers target's Attack and heals user based on Attack value.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for draining moves that heal half the damage dealt.
	/// Examples: Absorb, Giga Drain, Drain Punch
	/// </summary>
	public interface IHealUserByHalfOfDamageDone
	{
		/// <summary>
		/// Checks if this is a healing move based on generation.
		/// </summary>
		/// <returns>True if healing move in current generation</returns>
		bool healingMove();

		/// <summary>
		/// Heals the user based on damage dealt to the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for draining moves that only work on sleeping targets.
	/// Examples: Dream Eater
	/// </summary>
	public interface IHealUserByHalfOfDamageDoneIfTargetAsleep : IHealUserByHalfOfDamageDone
	{
		/// <summary>
		/// Checks if the move fails due to target not being asleep.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);
	}

	/// <summary>
	/// Interface for draining moves that also burn the target.
	/// Examples: Matcha Gotcha
	/// </summary>
	public interface IHealUserByHalfOfDamageDoneBurnTarget : IHealUserByHalfOfDamageDone
	{
		// Inherits draining functionality and adds burn effect
	}

	/// <summary>
	/// Interface for strong draining moves that heal 75% of damage dealt.
	/// Examples: Draining Kiss, Oblivion Wing
	/// </summary>
	public interface IHealUserByThreeQuartersOfDamageDone
	{
		/// <summary>
		/// Checks if this is a healing move based on generation.
		/// </summary>
		/// <returns>True if healing move in current generation</returns>
		bool healingMove();

		/// <summary>
		/// Heals the user based on 75% of damage dealt to the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that heal all allies by 25% of their max HP.
	/// Examples: Life Dew
	/// </summary>
	public interface IHealUserAndAlliesQuarterOfTotalHP
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move fails due to no Pokemon being able to heal.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Heals the target by 25% of their max HP.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that heal all allies and cure their status.
	/// Examples: Jungle Healing
	/// </summary>
	public interface IHealUserAndAlliesQuarterOfTotalHPCureStatus
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move fails due to no valid targets.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Heals and cures status of the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that heal the target by half their max HP.
	/// Examples: Heal Pulse
	/// </summary>
	public interface IHealTargetHalfOfTotalHP
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if reflectable</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Heals the target, with bonus healing if user has Mega Launcher.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that heal based on Grassy Terrain.
	/// Examples: Floral Healing
	/// </summary>
	public interface IHealTargetDependingOnGrassyTerrain
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if reflectable</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Heals the target with bonus healing in Grassy Terrain.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for delayed healing moves.
	/// Examples: Wish
	/// </summary>
	public interface IHealUserPositionNextTurn
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move can be snatched.
		/// </summary>
		/// <returns>True if snatchable</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails due to Wish already being in effect.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Sets up the Wish effect for next turn.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that provide continuous healing each turn.
	/// Examples: Aqua Ring
	/// </summary>
	public interface IStartHealUserEachTurn
	{
		/// <summary>
		/// Checks if the move can be snatched.
		/// </summary>
		/// <returns>True if snatchable</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails due to already being in effect.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Starts the continuous healing effect.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that provide healing and trap the user.
	/// Examples: Ingrain
	/// </summary>
	public interface IStartHealUserEachTurnTrapUserInBattle : IStartHealUserEachTurn
	{
		// Inherits healing functionality and adds trapping effect
	}

	/// <summary>
	/// Interface for moves that cause damage to sleeping targets each turn.
	/// Examples: Nightmare
	/// </summary>
	public interface IStartDamageTargetEachTurnIfTargetAsleep
	{
		/// <summary>
		/// Checks if the move fails due to target conditions.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Applies the nightmare effect to the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that drain HP from target each turn.
	/// Examples: Leech Seed
	/// </summary>
	public interface IStartLeechSeedTarget
	{
		/// <summary>
		/// Checks if the move can be reflected by Magic Coat.
		/// </summary>
		/// <returns>True if reflectable</returns>
		bool canMagicCoat();

		/// <summary>
		/// Checks if the move fails due to target conditions.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Displays custom miss message for evasion.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <returns>True if custom message was shown</returns>
		bool MissMessage(IBattler user, IBattler target);

		/// <summary>
		/// Applies the Leech Seed effect to the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves where user loses half their HP.
	/// Examples: Steel Beam
	/// </summary>
	public interface IUserLosesHalfOfTotalHP
	{
		/// <summary>
		/// Applies HP loss to the user after all hits.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for explosive moves where user loses half HP.
	/// Examples: Mind Blown
	/// </summary>
	public interface IUserLosesHalfOfTotalHPExplosive
	{
		/// <summary>
		/// Checks if the move can work without targets.
		/// </summary>
		/// <returns>True if it works with no targets</returns>
		bool worksWithNoTargets();

		/// <summary>
		/// Checks if the move fails due to Damp ability.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Causes the user to lose half their HP.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void SelfKO(IBattler user);
	}

	/// <summary>
	/// Interface for explosive moves that cause the user to faint.
	/// Examples: Explosion, Self-Destruct
	/// </summary>
	public interface IUserFaintsExplosive
	{
		/// <summary>
		/// Checks if the move can work without targets.
		/// </summary>
		/// <returns>True if it works with no targets</returns>
		bool worksWithNoTargets();

		/// <summary>
		/// Gets the number of hits for this move.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>Number of hits (1)</returns>
		int NumHits(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Checks if the move fails due to Damp ability.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Causes the user to faint.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void SelfKO(IBattler user);
	}

	/// <summary>
	/// Interface for explosive moves powered up in Misty Terrain.
	/// Examples: Misty Explosion
	/// </summary>
	public interface IUserFaintsPowersUpInMistyTerrainExplosive : IUserFaintsExplosive
	{
		/// <summary>
		/// Modifies base damage based on Misty Terrain.
		/// </summary>
		/// <param name="baseDmg">The base damage</param>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <returns>Modified damage value</returns>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that deal damage equal to user's current HP and cause fainting.
	/// Examples: Final Gambit
	/// </summary>
	public interface IUserFaintsFixedDamageUserHP
	{
		/// <summary>
		/// Gets the number of hits for this move.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>Number of hits (1)</returns>
		int NumHits(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Stores the user's current HP for damage calculation.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Returns the stored HP value as fixed damage.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <returns>Fixed damage equal to user's HP</returns>
		int FixedDamage(IBattler user, IBattler target);

		/// <summary>
		/// Causes the user to faint.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void SelfKO(IBattler user);
	}

	/// <summary>
	/// Interface for moves that cause fainting and heal replacement Pokemon.
	/// Examples: Healing Wish
	/// </summary>
	public interface IUserFaintsHealAndCureReplacement
	{
		/// <summary>
		/// Checks if this is a healing move.
		/// </summary>
		/// <returns>True for healing moves</returns>
		bool healingMove();

		/// <summary>
		/// Checks if the move can be snatched.
		/// </summary>
		/// <returns>True if snatchable</returns>
		bool canSnatch();

		/// <summary>
		/// Checks if the move fails due to no replacement Pokemon available.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Causes user to faint and sets up healing for replacement.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void SelfKO(IBattler user);
	}

	/// <summary>
	/// Interface for moves that heal and restore PP of replacement Pokemon.
	/// Examples: Lunar Dance
	/// </summary>
	public interface IUserFaintsHealAndCureReplacementRestorePP : IUserFaintsHealAndCureReplacement
	{
		// Inherits healing functionality and adds PP restoration
	}

	/// <summary>
	/// Interface for moves that cause all battlers to faint after 3 turns.
	/// Examples: Perish Song
	/// </summary>
	public interface IStartPerishCountsForAllBattlers
	{
		/// <summary>
		/// Checks if the move fails due to all targets already having perish counts.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Checks if the move fails against a specific target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		/// <param name="show_message">Whether to show failure message</param>
		/// <returns>True if the move fails against the target</returns>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool show_message);

		/// <summary>
		/// Applies the perish count effect to the target.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="target">The target Pokemon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);

		/// <summary>
		/// Shows the move animation and displays the perish song message.
		/// </summary>
		/// <param name="id">Animation ID</param>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <param name="hitNum">Hit number</param>
		/// <param name="showAnimation">Whether to show animation</param>
		void ShowAnimation(object id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Interface for moves that cause mutual KO if user faints.
	/// Examples: Destiny Bond
	/// </summary>
	public interface IAttackerFaintsIfUserFaints
	{
		/// <summary>
		/// Checks if the move fails due to recent usage restrictions.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		/// <param name="targets">The target Pokemon</param>
		/// <returns>True if the move fails</returns>
		bool MoveFailed(IBattler user, IList<IBattler> targets);

		/// <summary>
		/// Sets up the Destiny Bond effect on the user.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that cause attacker's move to lose all PP if user faints.
	/// Examples: Grudge
	/// </summary>
	public interface ISetAttackerMovePPTo0IfUserFaints
	{
		/// <summary>
		/// Sets up the Grudge effect on the user.
		/// </summary>
		/// <param name="user">The Pokemon using the move</param>
		void EffectGeneral(IBattler user);
	}
}