using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Base interfaces for move effects, mirroring the Ruby Battle::Move base effect classes.
	/// </summary>
	public interface ICanFail
	{
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	// --- Common feature interfaces ---

	/// <summary>
	/// Indicates the move can be snatched (i.e., copied by the Snatch move).
	/// </summary>
	public interface ICanSnatch
	{
		/// <summary>
		/// Returns true if the move can be snatched.
		/// </summary>
		bool CanSnatch();
	}

	/// <summary>
	/// Indicates the move can be reflected by Magic Coat.
	/// </summary>
	public interface ICanMagicCoat
	{
		/// <summary>
		/// Returns true if the move can be reflected by Magic Coat.
		/// </summary>
		bool CanMagicCoat();
	}

	/// <summary>
	/// Indicates the move has a stat up property (e.g., raises stats).
	/// </summary>
	public interface IHasStatUp : IBattleMoveEffectsBattlerStats
	{
		/// <summary>
		/// Gets the stat up array (stat, amount).
		/// </summary>
		KeyValuePair<int, int>[] StatUp { get; }
	}

	/// <summary>
	/// Indicates the move has a stat down property (e.g., lowers stats).
	/// </summary>
	public interface IHasStatDown : IBattleMoveEffectsBattlerStats
	{
		/// <summary>
		/// Gets the stat down array (stat, amount).
		/// </summary>
		KeyValuePair<int, int>[] StatDown { get; }
	}

	/// <summary>
	/// Indicates the move has an additional effect method (e.g., secondary effects).
	/// </summary>
	public interface IHasAdditionalEffect
	{
		/// <summary>
		/// Applies the additional effect of the move to the user or target.
		/// </summary>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Indicates the move has a general effect method (e.g., applies to the user).
	/// </summary>
	public interface IHasGeneralEffect
	{
		/// <summary>
		/// Applies the general effect of the move to the user.
		/// </summary>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Indicates the move has an effect against a target.
	/// </summary>
	public interface IHasEffectAgainstTarget
	{
		/// <summary>
		/// Applies the effect of the move against a target.
		/// </summary>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Indicates the move has an effect after all hits (e.g., recoil, status).
	/// </summary>
	public interface IHasEffectAfterAllHits
	{
		/// <summary>
		/// Applies the effect after all hits have occurred.
		/// </summary>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Indicates the move has a heal amount method (e.g., recovers HP).
	/// </summary>
	public interface IHasHealAmount : IBattleMoveEffectsHealing
	{
		/// <summary>
		/// Gets the amount of HP to heal.
		/// </summary>
		int HealAmount(IBattler user);
	}

	/// <summary>
	/// Indicates the move has recoil (e.g., damages the user after use).
	/// </summary>
	public interface IHasRecoil
	{
		/// <summary>
		/// Returns true if the move causes recoil.
		/// </summary>
		bool RecoilMove();
		/// <summary>
		/// Gets the amount of recoil damage.
		/// </summary>
		int RecoilDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Indicates the move has a weather type property (e.g., induces weather).
	/// </summary>
	public interface IHasWeatherType
	{
		/// <summary>
		/// Gets the weather type induced by the move.
		/// </summary>
		int WeatherType { get; }
	}

	/// <summary>
	/// Indicates the move has a charging turn property (e.g., two-turn moves).
	/// </summary>
	public interface IHasChargingTurn
	{
		/// <summary>
		/// Gets whether the move is in its charging turn.
		/// </summary>
		bool ChargingTurn { get; }
	}

	/// <summary>
	/// Indicates the move has a base type method (e.g., for pledge moves).
	/// </summary>
	public interface IHasBaseType
	{
		/// <summary>
		/// Gets the base type of the move.
		/// </summary>
		int BaseType(IBattler user);
	}

	/// <summary>
	/// Indicates the move has a base damage method (e.g., for pledge moves).
	/// </summary>
	public interface IHasBaseDamage
	{
		/// <summary>
		/// Gets the base damage for the move.
		/// </summary>
		int BaseDamage(int baseDmg, IBattler user, IBattler target);
	}

	// --- Base move effect interfaces ---

	/// <summary>
	/// Superclass that handles moves using a non-existent function code.
	/// Damaging moves just do damage with no additional effect.
	/// Status moves always fail.
	/// </summary>
	/// <remarks>
	/// Interface for moves with no implemented effect (default/fallback behavior).
	/// </remarks>
	public interface IUnimplementedMove : IBattleMove, ICanFail
	{
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Pseudomove for confusion damage.
	/// </summary>
	/// <remarks>
	/// Interface for the confusion pseudo-move (self-damage from confusion).
	/// </remarks>
	public interface IConfusionMove : IBattleMove
	{
		/// <summary>
		/// Gets whether this move is physical.
		/// </summary>
		bool PhysicalMove(int? thisType = null);
		/// <summary>
		/// Gets whether this move is special.
		/// </summary>
		bool SpecialMove(int? thisType = null);
		/// <summary>
		/// Returns the critical hit override value for this move.
		/// </summary>
		int CritialOverride(IBattler user, IBattler target);
	}

	/// <summary>
	/// Struggle.
	/// </summary>
	/// <remarks>
	/// Interface for the Struggle move (default move when out of PP).
	/// </remarks>
	public interface IStruggleMove : IBattleMove, IHasEffectAfterAllHits
	{
		/// <summary>
		/// Gets whether this move is physical.
		/// </summary>
		bool PhysicalMove(int? thisType = null);
		/// <summary>
		/// Gets whether this move is special.
		/// </summary>
		bool SpecialMove(int? thisType = null);
	}

	/// <summary>
	/// Raise one of user's stats.
	/// </summary>
	/// <remarks>
	/// Interface for moves that raise a single stat of the user.
	/// </remarks>
	public interface IStatUpMove : IBattleMove, ICanSnatch, IHasStatUp, IHasGeneralEffect, IHasAdditionalEffect, ICanFail
	{
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Raise multiple of user's stats.
	/// </summary>
	/// <remarks>
	/// Interface for moves that raise multiple stats of the user.
	/// </remarks>
	public interface IMultiStatUpMove : IBattleMove, ICanSnatch, IHasStatUp, IHasGeneralEffect, IHasAdditionalEffect, ICanFail
	{
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Lower multiple of user's stats.
	/// </summary>
	/// <remarks>
	/// Interface for moves that lower multiple stats of the user.
	/// </remarks>
	public interface IStatDownMove : IBattleMove, IHasStatDown
	{
		/// <summary>
		/// Called at the start of move use.
		/// </summary>
		void OnStartUse(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Applies the effect when dealing damage.
		/// </summary>
		void EffectWhenDealingDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Lower one of target's stats.
	/// </summary>
	/// <remarks>
	/// Interface for moves that lower a single stat of the target.
	/// </remarks>
	public interface ITargetStatDownMove : IBattleMove, ICanMagicCoat, IHasStatDown, IHasEffectAgainstTarget, IHasAdditionalEffect
	{
		/// <summary>
		/// Determines if the move fails against the target.
		/// </summary>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool showMessage);
	}

	/// <summary>
	/// Lower multiple of target's stats.
	/// </summary>
	/// <remarks>
	/// Interface for moves that lower multiple stats of the target.
	/// </remarks>
	public interface ITargetMultiStatDownMove : IBattleMove, ICanMagicCoat, IHasStatDown, IHasEffectAgainstTarget, IHasAdditionalEffect
	{
		/// <summary>
		/// Determines if the move fails against the target.
		/// </summary>
		bool FailsAgainstTarget(IBattler user, IBattler target, bool showMessage);
	}

	/// <summary>
	/// Fixed damage-inflicting move.
	/// </summary>
	/// <remarks>
	/// Interface for fixed-damage moves (e.g., Seismic Toss, Night Shade).
	/// </remarks>
	public interface IFixedDamageMove : IBattleMove
	{
		/// <summary>
		/// Gets the fixed damage value for the move.
		/// </summary>
		int FixedDamage(IBattler user, IBattler target);
		/// <summary>
		/// Calculates the damage for the move.
		/// </summary>
		void CalcDamage(IBattler user, IBattler target, int numTargets = 1);
	}

	/// <summary>
	/// Two turn move.
	/// </summary>
	/// <remarks>
	/// Interface for two-turn moves (e.g., Solar Beam, Dig).
	/// </remarks>
	public interface ITwoTurnMove : IBattleMove, IHasChargingTurn
	{
		/// <summary>
		/// Returns true if the move is a charging turn move.
		/// </summary>
		bool ChargingTurnMove();
		/// <summary>
		/// Returns true if the user is in the charging turn.
		/// </summary>
		/// <remarks>
		/// user.effects[PBEffects::TwoTurnAttack] is set to the move's ID if this
		/// method returns true, or nil if false.
		/// Non-nil means the charging turn. nil means the attacking turn.
		/// </remarks>
		bool IsChargingTurn(IBattler user);
		/// <summary>
		/// Returns true if the move is damaging this turn.
		/// </summary>
		/// <remarks>
		/// Stops damage being dealt in the first (charging) turn.
		/// </remarks>
		bool DamagingMove();
		/// <summary>
		/// Performs the quick charging move effect.
		/// </summary>
		/// <remarks>
		/// Does the charging part of this move, for when this move only takes one round
		/// to use.
		/// </remarks>
		void QuickChargingMove(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Checks if the move hits the target.
		/// </summary>
		bool AccuracyCheck(IBattler user, IBattler target);
		/// <summary>
		/// Applies the initial effect of the move.
		/// </summary>
		void InitialEffect(IBattler user, IList<IBattler> targets, int hitNum);
		/// <summary>
		/// Displays the charging turn message.
		/// </summary>
		void ChargingTurnMessage(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Displays the attacking turn message.
		/// </summary>
		void AttackingTurnMessage(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Applies the effect against the target.
		/// </summary>
		void EffectAgainstTarget(IBattler user, IBattler target);
		/// <summary>
		/// Applies the charging turn effect.
		/// </summary>
		void ChargingTurnEffect(IBattler user, IBattler target);
		/// <summary>
		/// Applies the attacking turn effect.
		/// </summary>
		void AttackingTurnEffect(IBattler user, IBattler target);
		/// <summary>
		/// Shows the move animation.
		/// </summary>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}

	/// <summary>
	/// Healing move.
	/// </summary>
	/// <remarks>
	/// Interface for healing moves (e.g., Recover, Soft-Boiled).
	/// </remarks>
	public interface IHealingMove : IBattleMove, IHasHealAmount, ICanSnatch, IHasGeneralEffect, ICanFail
	{
		/// <summary>
		/// Returns true if the move is a healing move.
		/// </summary>
		bool HealingMove();
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Recoil move.
	/// </summary>
	/// <remarks>
	/// Interface for recoil moves (e.g., Take Down, Double-Edge).
	/// </remarks>
	public interface IRecoilMove : IBattleMove, IHasRecoil, IHasEffectAfterAllHits
	{
	}

	/// <summary>
	/// Protect move.
	/// </summary>
	/// <remarks>
	/// Interface for protect moves (e.g., Protect, Detect).
	/// </remarks>
	public interface IProtectMove : IBattleMove, ICanFail
	{
		/// <summary>
		/// Changes the usage counters for the move.
		/// </summary>
		void ChangeUsageCounters(IBattler user, bool specialUsage);
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Applies the general effect of the move.
		/// </summary>
		void EffectGeneral(IBattler user);
		/// <summary>
		/// Displays the protect message.
		/// </summary>
		void ProtectMessage(IBattler user);
	}

	/// <summary>
	/// Weather-inducing move.
	/// </summary>
	/// <remarks>
	/// Interface for weather-inducing moves (e.g., Rain Dance, Sunny Day).
	/// </remarks>
	public interface IWeatherMove : IBattleMove, IHasWeatherType, IHasGeneralEffect, ICanFail
	{
		/// <summary>
		/// Determines if the move fails for the user and targets.
		/// </summary>
		bool MoveFailed(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Pledge move.
	/// </summary>
	/// <remarks>
	/// Interface for pledge moves (e.g., Grass Pledge, Fire Pledge).
	/// </remarks>
	public interface IPledgeMove : IBattleMove, IHasBaseType, IHasBaseDamage, IHasGeneralEffect, IHasEffectAfterAllHits
	{
		/// <summary>
		/// Gets the combo configurations for this Pledge move.
		/// </summary>
		IBattleMove combos { get; }

		/// <summary>
		/// Called at the start of move use.
		/// </summary>
		void OnStartUse(IBattler user, IList<IBattler> targets);
		/// <summary>
		/// Returns true if the move is damaging this turn.
		/// </summary>
		bool DamagingMove();
		/// <summary>
		/// Shows the move animation.
		/// </summary>
		void ShowAnimation(int id, IBattler user, IList<IBattler> targets, int hitNum = 0, bool showAnimation = true);
	}
}