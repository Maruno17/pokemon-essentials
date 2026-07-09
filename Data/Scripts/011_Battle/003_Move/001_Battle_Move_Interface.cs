using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface representing a battle move, encapsulating all move data, properties, and logic for move classification and display.
	/// <para>This interface provides access to all move attributes, flags, and classification logic, and is used throughout the battle system for move effect processing, targeting, and UI display.</para>
	/// </summary>
	public interface IBattleMove
	{
		/// <summary>
		/// The battle context in which this move is used.
		/// </summary>
		IBattle Battle { get; }

		/// <summary>
		/// The underlying move data object (from the Pokémon's moveset).
		/// </summary>
		IMove RealMove { get; }

		/// <summary>
		/// The unique identifier for this move.
		/// </summary>
		int Id { get; set; }

		/// <summary>
		/// The display name of the move.
		/// </summary>
		string Name { get; }

		/// <summary>
		/// The function code that determines the move's effect.
		/// </summary>
		string function_code { get; }
		//string FunctionCode { get; }

		/// <summary>
		/// The base power of the move.
		/// </summary>
		int Power { get; }

		/// <summary>
		/// The type of the move (e.g., Fire, Water).
		/// </summary>
		int Type { get; }

		/// <summary>
		/// The move's category (Physical, Special, Status).
		/// </summary>
		int Category { get; }

		/// <summary>
		/// The accuracy of the move.
		/// </summary>
		int Accuracy { get; }

		/// <summary>
		/// The current PP of the move.
		/// </summary>
		int PP { get; set; }

		/// <summary>
		/// The total PP of the move (including PP Ups and modifiers).
		/// </summary>
		int total_pp { get; set; }
		//int TotalPP { get; set; }

		/// <summary>
		/// The additional effect chance of the move (e.g., chance to paralyze).
		/// </summary>
		int AddlEffect { get; }

		/// <summary>
		/// The targeting mode of the move (e.g., single target, all foes).
		/// </summary>
		int Target { get; }

		/// <summary>
		/// The move's priority (higher values go first in turn order).
		/// </summary>
		int Priority { get; }

		/// <summary>
		/// The set of flags that describe move properties (e.g., Contact, Sound, Biting).
		/// </summary>
		//IList<MoveFlag> Flags { get; }
		IList<string> Flags { get; }

		/// <summary>
		/// The calculated type of the move (may differ from base type due to effects like Electrify).
		/// </summary>
		int CalcType { get; set; }

		/// <summary>
		/// Whether the move's power is boosted by certain abilities (e.g., Aerilate, Pixilate).
		/// </summary>
		bool PowerBoost { get; set; }

		/// <summary>
		/// Whether the move has been snatched (e.g., by the move Snatch).
		/// </summary>
		bool Snatched { get; set; }

		/// <summary>
		/// Returns the move's target data for the given user, used for targeting logic and UI.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		//MoveTargetData TargetData(IBattler user);
		ITarget TargetData(IBattler user);

		/// <summary>
		/// Gets the total PP for this move, considering all modifiers and effects.
		/// </summary>
		int GetTotalPP();

		/// <summary>
		/// Returns true if the move is physical, considering type and category. Used for damage calculation and UI.
		/// </summary>
		/// <param name="thisType">Optional override for the move's type.</param>
		bool IsPhysical(int? thisType = null);

		/// <summary>
		/// Returns true if the move is special, considering type and category. Used for damage calculation and UI.
		/// </summary>
		/// <param name="thisType">Optional override for the move's type.</param>
		bool IsSpecial(int? thisType = null);

		/// <summary>
		/// Returns true if the move is damaging (not a status move). Used for effect and damage logic.
		/// </summary>
		bool IsDamaging();

		/// <summary>
		/// Returns true if the move is a status move. Used for effect and damage logic.
		/// </summary>
		bool IsStatus();

		/// <summary>
		/// Returns the move's priority for the given user, used for turn order calculation.
		/// </summary>
		/// <param name="user">The user of the move.</param>
		int GetPriority(IBattler user);

		/// <summary>
		/// Returns true if the move can be used while asleep (e.g., Sleep Talk).
		/// </summary>
		bool UsableWhenAsleep();

		/// <summary>
		/// Returns true if the move cannot be used in Gravity (e.g., High Jump Kick).
		/// </summary>
		bool UnusableInGravity();

		/// <summary>
		/// Returns true if the move heals the user or target (e.g., Recover, Heal Pulse).
		/// </summary>
		bool IsHealingMove();

		/// <summary>
		/// Returns true if the move causes recoil damage to the user (e.g., Double-Edge).
		/// </summary>
		bool IsRecoilMove();

		/// <summary>
		/// Returns true if the move can cause flinching (e.g., Headbutt).
		/// </summary>
		bool IsFlinchingMove();

		/// <summary>
		/// Returns true if the move calls another move (e.g., Metronome, Assist).
		/// </summary>
		bool CallsAnotherMove();

		/// <summary>
		/// Returns true if the move can hit more than once in the same turn (e.g., Double Slap).
		/// </summary>
		/// <remarks>
		/// Whether the move can/will hit more than once in the same turn (including
		/// Beat Up which may instead hit just once). Not the same as pbNumHits>1.
		/// </remarks>
		bool IsMultiHitMove();

		/// <summary>
		/// Returns true if the move requires a charging turn (e.g., Solar Beam).
		/// </summary>
		bool IsChargingTurnMove();

		/// <summary>
		/// Returns true if the move performs a success check per hit (e.g., multi-hit moves).
		/// </summary>
		bool SuccessCheckPerHit();

		/// <summary>
		/// Returns true if the move can hit targets that are flying (e.g., Thunder).
		/// </summary>
		bool HitsFlyingTargets();

		/// <summary>
		/// Returns true if the move can hit targets that are digging (e.g., Earthquake).
		/// </summary>
		bool HitsDiggingTargets();

		/// <summary>
		/// Returns true if the move can hit targets that are diving (e.g., Surf).
		/// </summary>
		bool HitsDivingTargets();

		/// <summary>
		/// Returns true if the move ignores Reflect (e.g., Brick Break).
		/// </summary>
		/// <remarks>
		/// For Brick Break
		/// </remarks>
		bool IgnoresReflect();

		/// <summary>
		/// Returns true if the move targets a position rather than a battler (e.g., Future Sight).
		/// </summary>
		/// <remarks>
		/// For Future Sight/Doom Desire
		/// </remarks>
		bool TargetsPosition();

		/// <summary>
		/// Returns true if the move cannot be redirected (e.g., Snipe Shot).
		/// </summary>
		/// <remarks>
		/// For Snipe Shot
		/// </remarks>
		bool CannotRedirect();

		/// <summary>
		/// Returns true if the move works even with no targets (e.g., Explosion).
		/// </summary>
		/// <remarks>
		/// For Explosion
		/// </remarks>
		bool WorksWithNoTargets();

		/// <summary>
		/// Returns true if the move's damage is reduced by burn (e.g., Facade).
		/// </summary>
		/// <remarks>
		/// For Facade
		/// </remarks>
		bool DamageReducedByBurn();

		/// <summary>
		/// Returns true if the move triggers Hyper Mode (for Shadow Pokémon).
		/// </summary>
		bool TriggersHyperMode();

		/// <summary>
		/// Returns true if the move can be snatched (e.g., by the move Snatch).
		/// </summary>
		bool CanSnatch();

		/// <summary>
		/// Returns true if the move can be reflected by Magic Coat.
		/// </summary>
		bool CanMagicCoat();

		/// <summary>
		/// Returns true if the move makes contact (e.g., Tackle, Close Combat).
		/// </summary>
		bool IsContactMove();

		/// <summary>
		/// Returns true if the move can be protected against (e.g., Protect).
		/// </summary>
		bool CanProtectAgainst();

		/// <summary>
		/// Returns true if the move can be copied by Mirror Move.
		/// </summary>
		bool CanMirrorMove();

		/// <summary>
		/// Returns true if the move thaws the user (e.g., Flame Wheel).
		/// </summary>
		bool ThawsUser();

		/// <summary>
		/// Returns true if the move has a high critical hit rate (e.g., Slash).
		/// </summary>
		bool HasHighCriticalRate();

		/// <summary>
		/// Returns true if the move is a biting move (e.g., Bite, Crunch).
		/// </summary>
		bool IsBitingMove();

		/// <summary>
		/// Returns true if the move is a punching move (e.g., Fire Punch).
		/// </summary>
		bool IsPunchingMove();

		/// <summary>
		/// Returns true if the move is a sound-based move (e.g., Hyper Voice).
		/// </summary>
		bool IsSoundMove();

		/// <summary>
		/// Returns true if the move is a powder move (e.g., Sleep Powder).
		/// </summary>
		bool IsPowderMove();

		/// <summary>
		/// Returns true if the move is a pulse move (e.g., Dragon Pulse).
		/// </summary>
		bool IsPulseMove();

		/// <summary>
		/// Returns true if the move is a bomb move (e.g., Sludge Bomb).
		/// </summary>
		bool IsBombMove();

		/// <summary>
		/// Returns true if the move is a dance move (e.g., Swords Dance).
		/// </summary>
		bool IsDanceMove();

		/// <summary>
		/// Returns true if the move is a slicing move (e.g., Air Slash).
		/// </summary>
		bool IsSlicingMove();

		/// <summary>
		/// Returns true if the move is a wind move (e.g., Bleakwind Storm).
		/// </summary>
		bool IsWindMove();

		/// <summary>
		/// Returns true if the move tramples Minimize (perfect accuracy and double damage).
		/// </summary>
		/// <remarks>
		/// Causes perfect accuracy and double damage if target used Minimize. Perfect accuracy only with Gen 6+ mechanics.
		/// </remarks>
		bool TramplesMinimize();

		/// <summary>
		/// Returns true if the move is non-lethal (e.g., False Swipe), never causing a KO.
		/// </summary>
		/// <remarks>
		/// For False Swipe
		/// </remarks>
		/// <param name="user">The user of the move.</param>
		/// <param name="target">The target of the move.</param>
		bool IsNonLethal(IBattler user, IBattler target);

		/// <summary>
		/// Returns true if the move prevents the battler from consuming a healing berry (e.g., Bug Bite/Pluck).
		/// </summary>
		/// <remarks>
		/// For Bug Bite/Pluck
		/// </remarks>
		/// <param name="battler">The battler affected.</param>
		/// <param name="targets">The targets of the move.</param>
		bool PreventsBattlerConsumingHealingBerry(IBattler battler, IList<IBattler> targets);

		/// <summary>
		/// Returns true if the move ignores Substitute for the given user (e.g., Infiltrator, sound moves).
		/// </summary>
		/// <remarks>
		/// <paramref name="user"/> is the Pokémon using this move.
		/// </remarks>
		/// <param name="user">The user of the move.</param>
		bool IgnoresSubstitute(IBattler user);

		/// <summary>
		/// Gets the display type of the move for the given battler (for UI purposes).
		/// </summary>
		/// <param name="battler">The battler for which to display the type.</param>
		int DisplayType(IBattler battler);

		/// <summary>
		/// Gets the display damage of the move for the given battler (for UI purposes).
		/// </summary>
		/// <param name="battler">The battler for which to display the damage.</param>
		int DisplayDamage(IBattler battler);

		/// <summary>
		/// Gets the display category of the move for the given battler (for UI purposes).
		/// </summary>
		/// <param name="battler">The battler for which to display the category.</param>
		int DisplayCategory(IBattler battler);

		/// <summary>
		/// Gets the display accuracy of the move for the given battler (for UI purposes).
		/// </summary>
		/// <param name="battler">The battler for which to display the accuracy.</param>
		int DisplayAccuracy(IBattler battler);
	}
}