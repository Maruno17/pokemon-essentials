using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for move effects that modify battler statistics including stat stages, base stats, and critical hit rates.
	/// </summary>
	public interface IBattleMoveEffectsBattlerStats : IBattleMove
	{
	}

	#region User Stat Raising - Attack

	/// <summary>
	/// Interface for moves that raise the user's Attack by 1 stage.
	/// </summary>
	public interface IRaiseUserAttack1 : IStatUpMove, IHasStatUp
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack by 2 stages.
	/// Examples: Swords Dance
	/// </summary>
	public interface IRaiseUserAttack2 : IStatUpMove, IHasStatUp
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack by 2 stages if the target faints.
	/// Examples: Fell Stinger (Gen 6-)
	/// </summary>
	public interface IRaiseUserAttack2IfTargetFaints : IBattleMove, IHasStatUp
	{
		/// <summary>
		/// Gets the stat information for the raising effect.
		/// </summary>
	 	//KeyValuePair<string stat, int stages> statUp { get; }
	 	KeyValuePair<string, int> statUp { get; }

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack by 3 stages.
	/// </summary>
	public interface IRaiseUserAttack3 : IStatUpMove, IHasStatUp
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack by 3 stages if the target faints.
	/// Examples: Fell Stinger (Gen 7+)
	/// </summary>
	public interface IRaiseUserAttack3IfTargetFaints : IBattleMove, IHasStatUp
	{
		/// <summary>
		/// Gets the stat information for the raising effect.
		/// </summary>
		//KeyValuePair<string stat, int stages> statUp { get; }
		KeyValuePair<string, int> statUp { get; }

		/// <summary>
		/// Performs effects after all hits of the move are completed.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target that was hit</param>
		void EffectAfterAllHits(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that maximize the user's Attack but cost half of max HP.
	/// Examples: Belly Drum
	/// </summary>
	public interface IMaxUserAttackLoseHalfOfTotalHP : IBattleMove
	{
		/// <summary>
		/// Gets the stat information for the raising effect.
		/// </summary>
		//KeyValuePair<string stat, int stages> statUp { get; }
		KeyValuePair<string, int> statUp { get; }

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
	/// Interface for moves that raise Attack, Special Attack, and Speed by 2 stages each, but cost half of max HP.
	/// Examples: Fillet Away
	/// </summary>
	public interface IRaiseUserAtkSpAtkSpeed2LoseHalfOfTotalHP : IMultiStatUpMove
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

	#region User Stat Raising - Defense

	/// <summary>
	/// Interface for moves that raise the user's Defense by 1 stage.
	/// Examples: Harden, Steel Wing, Withdraw
	/// </summary>
	public interface IRaiseUserDefense1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Defense by 1 stage and curl up.
	/// Examples: Defense Curl
	/// </summary>
	public interface IRaiseUserDefense1CurlUpUser : IStatUpMove
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise the user's Defense by 2 stages.
	/// Examples: Acid Armor, Barrier, Iron Defense
	/// </summary>
	public interface IRaiseUserDefense2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Defense by 3 stages.
	/// Examples: Cotton Guard
	/// </summary>
	public interface IRaiseUserDefense3 : IStatUpMove
	{
	}

	#endregion

	#region User Stat Raising - Special Attack

	/// <summary>
	/// Interface for moves that raise the user's Special Attack by 1 stage.
	/// Examples: Charge Beam, Fiery Dance
	/// </summary>
	public interface IRaiseUserSpAtk1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Special Attack by 2 stages.
	/// Examples: Nasty Plot
	/// </summary>
	public interface IRaiseUserSpAtk2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Special Attack by 3 stages.
	/// Examples: Tail Glow
	/// </summary>
	public interface IRaiseUserSpAtk3 : IStatUpMove
	{
	}

	#endregion

	#region User Stat Raising - Special Defense

	/// <summary>
	/// Interface for moves that raise the user's Special Defense by 1 stage.
	/// </summary>
	public interface IRaiseUserSpDef1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Special Defense by 1 stage and power up Electric moves.
	/// Examples: Charge
	/// </summary>
	public interface IRaiseUserSpDef1PowerUpElectricMove : IStatUpMove
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise the user's Special Defense by 2 stages.
	/// Examples: Amnesia
	/// </summary>
	public interface IRaiseUserSpDef2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Special Defense by 3 stages.
	/// </summary>
	public interface IRaiseUserSpDef3 : IStatUpMove
	{
	}

	#endregion

	#region User Stat Raising - Speed

	/// <summary>
	/// Interface for moves that raise the user's Speed by 1 stage.
	/// Examples: Flame Charge
	/// </summary>
	public interface IRaiseUserSpeed1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Speed by 2 stages.
	/// Examples: Agility, Rock Polish
	/// </summary>
	public interface IRaiseUserSpeed2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Speed by 2 stages and lower weight.
	/// Examples: Autotomize
	/// </summary>
	public interface IRaiseUserSpeed2LowerUserWeight : IStatUpMove
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise the user's Speed by 3 stages.
	/// </summary>
	public interface IRaiseUserSpeed3 : IStatUpMove
	{
	}

	#endregion

	#region User Stat Raising - Accuracy and Evasion

	/// <summary>
	/// Interface for moves that raise the user's accuracy by 1 stage.
	/// </summary>
	public interface IRaiseUserAccuracy1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's accuracy by 2 stages.
	/// </summary>
	public interface IRaiseUserAccuracy2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's accuracy by 3 stages.
	/// </summary>
	public interface IRaiseUserAccuracy3 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's evasion by 1 stage.
	/// Examples: Double Team
	/// </summary>
	public interface IRaiseUserEvasion1 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's evasion by 2 stages.
	/// </summary>
	public interface IRaiseUserEvasion2 : IStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's evasion by 2 stages and minimize.
	/// Examples: Minimize
	/// </summary>
	public interface IRaiseUserEvasion2MinimizeUser : IStatUpMove
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise the user's evasion by 3 stages.
	/// </summary>
	public interface IRaiseUserEvasion3 : IStatUpMove
	{
	}

	#endregion

	#region User Critical Hit Rate

	/// <summary>
	/// Interface for moves that increase the user's critical hit rate.
	/// Examples: Focus Energy
	/// </summary>
	public interface IRaiseUserCriticalHitRate2 : IBattleMove
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

	#region User Multi-Stat Raising

	/// <summary>
	/// Interface for moves that raise the user's Attack and Defense by 1 stage each.
	/// Examples: Bulk Up
	/// </summary>
	public interface IRaiseUserAtkDef1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack, Defense, and Speed by 1 stage each.
	/// Examples: Victory Dance
	/// </summary>
	public interface IRaiseUserAtkDefSpd1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack, Defense, and accuracy by 1 stage each.
	/// Examples: Coil
	/// </summary>
	public interface IRaiseUserAtkDefAcc1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack and Special Attack by 1 stage each.
	/// Examples: Work Up
	/// </summary>
	public interface IRaiseUserAtkSpAtk1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise Attack and Sp. Attack by 1 or 2 stages based on sun.
	/// Examples: Growth
	/// </summary>
	public interface IRaiseUserAtkSpAtk1Or2InSun : IMultiStatUpMove
	{
		/// <summary>
		/// Called when the move starts being used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="targets">Array of target Pokémon</param>
		void OnStartUse(IBattler user, IList<IBattler> targets);
	}

	/// <summary>
	/// Interface for moves that lower Defense and Sp. Def by 1, raise Atk, Sp. Atk, and Speed by 2.
	/// Examples: Shell Smash
	/// </summary>
	public interface ILowerUserDefSpDef1RaiseUserAtkSpAtkSpd2 : IBattleMove
	{
		/// <summary>
		/// Gets the stats that will be raised.
		/// </summary>
		string[] statUp { get; }

		/// <summary>
		/// Gets the stats that will be lowered.
		/// </summary>
		string[] statDown { get; }

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
	/// Interface for moves that raise the user's Attack and Speed by 1 stage each.
	/// Examples: Dragon Dance
	/// </summary>
	public interface IRaiseUserAtkSpd1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise Attack and Speed, and remove hazards and substitutes.
	/// Examples: Mortal Spin
	/// </summary>
	public interface IRaiseUserAtkSpd1RemoveEntryHazardsAndSubstitutes : IRaiseUserAtkSpd1
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
	/// Interface for moves that raise Speed by 2 stages and Attack by 1.
	/// Examples: Shift Gear
	/// </summary>
	public interface IRaiseUserAtk1Spd2 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Attack and accuracy by 1 stage each.
	/// Examples: Hone Claws
	/// </summary>
	public interface IRaiseUserAtkAcc1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Defense and Special Defense by 1 stage each.
	/// Examples: Cosmic Power, Defend Order
	/// </summary>
	public interface IRaiseUserDefSpDef1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise the user's Sp. Attack and Sp. Defense by 1 stage each.
	/// Examples: Calm Mind
	/// </summary>
	public interface IRaiseUserSpAtkSpDef1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise Sp. Attack and Sp. Defense by 1 and cure status.
	/// Examples: Take Heart
	/// </summary>
	public interface IRaiseUserSpAtkSpDef1CureStatus : IMultiStatUpMove
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
	/// Interface for moves that raise Sp. Attack, Sp. Defense, and Speed by 1 stage each.
	/// Examples: Quiver Dance
	/// </summary>
	public interface IRaiseUserSpAtkSpDefSpd1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise all main stats by 1 stage.
	/// Examples: Ancient Power, Ominous Wind, Silver Wind
	/// </summary>
	public interface IRaiseUserMainStats1 : IMultiStatUpMove
	{
	}

	/// <summary>
	/// Interface for moves that raise all main stats by 1 but cost a third of max HP.
	/// Examples: Clangorous Soul
	/// </summary>
	public interface IRaiseUserMainStats1LoseThirdOfTotalHP : IMultiStatUpMove
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
	/// Interface for moves that raise all main stats by 1 and trap the user.
	/// Examples: No Retreat
	/// </summary>
	public interface IRaiseUserMainStats1TrapUserInBattle : IRaiseUserMainStats1
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

	#region Special Stat Effects

	/// <summary>
	/// Interface for moves that start raising user's Attack when damaged.
	/// Examples: Rage
	/// </summary>
	public interface IStartRaiseUserAtk1WhenDamaged : IBattleMove
	{
		/// <summary>
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	#endregion

	#region User Stat Lowering

	/// <summary>
	/// Interface for moves that lower the user's Attack by 1 stage.
	/// </summary>
	public interface ILowerUserAttack1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Attack by 2 stages.
	/// </summary>
	public interface ILowerUserAttack2 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Defense by 1 stage.
	/// Examples: Clanging Scales
	/// </summary>
	public interface ILowerUserDefense1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Defense by 2 stages.
	/// </summary>
	public interface ILowerUserDefense2 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Special Attack by 1 stage.
	/// Examples: Make It Rain
	/// </summary>
	public interface ILowerUserSpAtk1 : IStatDownMove
	{
		/// <summary>
		/// Performs effects when dealing damage to target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectWhenDealingDamage(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that lower the user's Special Attack by 2 stages.
	/// </summary>
	public interface ILowerUserSpAtk2 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Special Defense by 1 stage.
	/// </summary>
	public interface ILowerUserSpDef1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Special Defense by 2 stages.
	/// </summary>
	public interface ILowerUserSpDef2 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Speed by 1 stage.
	/// Examples: Hammer Arm, Ice Hammer
	/// </summary>
	public interface ILowerUserSpeed1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Speed by 2 stages.
	/// </summary>
	public interface ILowerUserSpeed2 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Attack and Defense by 1 stage each.
	/// Examples: Superpower
	/// </summary>
	public interface ILowerUserAtkDef1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Defense and Special Defense by 1 stage each.
	/// Examples: Armor Cannon, Close Combat, Dragon Ascent, Headlong Rush
	/// </summary>
	public interface ILowerUserDefSpDef1 : IStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the user's Defense, Special Defense, and Speed by 1 stage each.
	/// Examples: V-create
	/// </summary>
	public interface ILowerUserDefSpDefSpd1 : IStatDownMove
	{
	}

	#endregion

	#region Target Stat Raising

	/// <summary>
	/// Interface for moves that raise the target's Attack by 1 stage.
	/// Examples: Howl (Gen 8+)
	/// </summary>
	public interface IRaiseTargetAttack1 : IBattleMove
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
	/// Interface for moves that raise target's Attack by 2 and lower Defense by 2.
	/// Examples: Spicy Extract
	/// </summary>
	public interface IRaiseTargetAtk2LowerTargetDef2 : IBattleMove
	{
		/// <summary>
		/// Gets the stats that will be raised.
		/// </summary>
		string[] statUp { get; }

		/// <summary>
		/// Gets the stats that will be lowered.
		/// </summary>
		string[] statDown { get; }

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
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that raise target's Attack by 2 and confuse them.
	/// Examples: Swagger
	/// </summary>
	public interface IRaiseTargetAttack2ConfuseTarget : IBattleMove
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
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that raise target's Special Attack by 1 and confuse them.
	/// Examples: Flatter
	/// </summary>
	public interface IRaiseTargetSpAtk1ConfuseTarget : IBattleMove
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
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that raise target's Special Defense by 1.
	/// Examples: Aromatic Mist
	/// </summary>
	public interface IRaiseTargetSpDef1 : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

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
	/// Interface for moves that raise one random stat of the target by 2 stages.
	/// Examples: Acupressure
	/// </summary>
	public interface IRaiseTargetRandomStat2 : IBattleMove
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
	/// Interface for moves that raise target's Attack and Special Attack by 2 stages each.
	/// Examples: Decorate
	/// </summary>
	public interface IRaiseTargetAtkSpAtk2 : IBattleMove
	{
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

	#region Target Stat Lowering

	/// <summary>
	/// Interface for moves that lower the target's Attack by 1 stage.
	/// </summary>
	public interface ILowerTargetAttack1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower target's Attack by 1 and bypass Substitute.
	/// Examples: Play Nice
	/// </summary>
	public interface ILowerTargetAttack1BypassSubstitute : ITargetStatDownMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);
	}

	/// <summary>
	/// Interface for moves that lower the target's Attack by 2 stages.
	/// Examples: Charm, Feather Dance
	/// </summary>
	public interface ILowerTargetAttack2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Attack by 3 stages.
	/// </summary>
	public interface ILowerTargetAttack3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Defense by 1 stage.
	/// </summary>
	public interface ILowerTargetDefense1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower Defense by 1 and power up in Gravity.
	/// Examples: Grav Apple
	/// </summary>
	public interface ILowerTargetDefense1PowersUpInGravity : ILowerTargetDefense1
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
	/// Interface for moves that lower Defense by 1 and can flinch.
	/// Examples: Triple Arrows
	/// </summary>
	public interface ILowerTargetDefense1FlinchTarget : ITargetStatDownMove
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

	/// <summary>
	/// Interface for moves that lower the target's Defense by 2 stages.
	/// Examples: Screech
	/// </summary>
	public interface ILowerTargetDefense2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Defense by 3 stages.
	/// </summary>
	public interface ILowerTargetDefense3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Attack by 1 stage.
	/// </summary>
	public interface ILowerTargetSpAtk1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Attack by 2 stages.
	/// Examples: Eerie Impulse
	/// </summary>
	public interface ILowerTargetSpAtk2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower Sp. Attack by 2 if can attract.
	/// Examples: Captivate
	/// </summary>
	public interface ILowerTargetSpAtk2IfCanAttract : ITargetStatDownMove
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
		/// Performs additional effects on a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void AdditionalEffect(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Attack by 3 stages.
	/// </summary>
	public interface ILowerTargetSpAtk3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Defense by 1 stage.
	/// </summary>
	public interface ILowerTargetSpDef1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Defense by 2 stages.
	/// </summary>
	public interface ILowerTargetSpDef2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Special Defense by 3 stages.
	/// </summary>
	public interface ILowerTargetSpDef3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Speed by 1 stage.
	/// </summary>
	public interface ILowerTargetSpeed1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower Speed by 1 and always hit in rain.
	/// Examples: Bleakwind Storm
	/// </summary>
	public interface ILowerTargetSpeed1AlwaysHitsInRain : ILowerTargetSpeed1
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
	/// Interface for moves that lower Speed by 1 and are weaker in Grassy Terrain.
	/// Examples: Bulldoze
	/// </summary>
	public interface ILowerTargetSpeed1WeakerInGrassyTerrain : ITargetStatDownMove
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
	/// Interface for moves that lower Speed by 1 and make target weaker to Fire.
	/// Examples: Tar Shot
	/// </summary>
	public interface ILowerTargetSpeed1MakeTargetWeakerToFire : ITargetStatDownMove
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
	/// Interface for moves that lower the target's Speed by 2 stages.
	/// Examples: Cotton Spore, Scary Face, String Shot
	/// </summary>
	public interface ILowerTargetSpeed2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's Speed by 3 stages.
	/// </summary>
	public interface ILowerTargetSpeed3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's accuracy by 1 stage.
	/// </summary>
	public interface ILowerTargetAccuracy1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's accuracy by 2 stages.
	/// </summary>
	public interface ILowerTargetAccuracy2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's accuracy by 3 stages.
	/// </summary>
	public interface ILowerTargetAccuracy3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's evasion by 1 stage.
	/// Examples: Sweet Scent (Gen 5-)
	/// </summary>
	public interface ILowerTargetEvasion1 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower evasion by 1 and remove side effects.
	/// Examples: Defog
	/// </summary>
	public interface ILowerTargetEvasion1RemoveSideEffects : ITargetStatDownMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

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
	/// Interface for moves that lower the target's evasion by 2 stages.
	/// Examples: Sweet Scent (Gen 6+)
	/// </summary>
	public interface ILowerTargetEvasion2 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower the target's evasion by 3 stages.
	/// </summary>
	public interface ILowerTargetEvasion3 : ITargetStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower target's Attack and Defense by 1 stage each.
	/// Examples: Tickle
	/// </summary>
	public interface ILowerTargetAtkDef1 : ITargetMultiStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower target's Attack and Special Attack by 1 stage each.
	/// Examples: Noble Roar
	/// </summary>
	public interface ILowerTargetAtkSpAtk1 : ITargetMultiStatDownMove
	{
	}

	/// <summary>
	/// Interface for moves that lower poisoned target's Attack, Sp. Attack, and Speed by 1.
	/// Examples: Venom Drench
	/// </summary>
	public interface ILowerPoisonedTargetAtkSpAtkSpd1 : IBattleMove
	{
		/// <summary>
		/// Gets the stats that will be lowered.
		/// </summary>
		string[] statDown { get; }

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
		/// Checks for Mirror Armor ability on the target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <returns>True if the effect can proceed</returns>
		bool CheckForMirrorArmor(IBattler user, IBattler target);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	#endregion

	#region Ally Stat Effects

	/// <summary>
	/// Interface for moves that raise allies' Attack and Defense by 1 stage each.
	/// Examples: Coaching
	/// </summary>
	public interface IRaiseAlliesAtkDef1 : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

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
	/// Interface for moves that raise Plus/Minus user and allies' Attack and Sp. Attack by 1.
	/// Examples: Gear Up
	/// </summary>
	public interface IRaisePlusMinusUserAndAlliesAtkSpAtk1 : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise Plus/Minus user and allies' Defense and Sp. Defense by 1.
	/// Examples: Magnetic Flux
	/// </summary>
	public interface IRaisePlusMinusUserAndAlliesDefSpDef1 : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

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
		/// Performs the general effect when the move is used.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		void EffectGeneral(IBattler user);
	}

	/// <summary>
	/// Interface for moves that raise grounded Grass-type battlers' Attack and Sp. Attack by 1.
	/// Examples: Rototiller
	/// </summary>
	public interface IRaiseGroundedGrassBattlersAtkSpAtk1 : IBattleMove
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
	/// Interface for moves that raise all Grass-type battlers' Defense by 1.
	/// Examples: Flower Shield
	/// </summary>
	public interface IRaiseGrassBattlersDef1 : IBattleMove
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

	#endregion

	#region Stat Stage Swapping and Copying

	/// <summary>
	/// Interface for moves that swap user and target's Attack and Sp. Attack stat stages.
	/// Examples: Power Swap
	/// </summary>
	public interface IUserTargetSwapAtkSpAtkStages : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that swap user and target's Defense and Sp. Defense stat stages.
	/// Examples: Guard Swap
	/// </summary>
	public interface IUserTargetSwapDefSpDefStages : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that swap user and target's all stat stages.
	/// Examples: Heart Swap
	/// </summary>
	public interface IUserTargetSwapStatStages : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that copy the target's stat stages.
	/// Examples: Psych Up
	/// </summary>
	public interface IUserCopyTargetStatStages : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that steal target's positive stat stages before damage.
	/// Examples: Spectral Thief
	/// </summary>
	public interface IUserStealTargetPositiveStatStages : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Calculates damage for the move.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		/// <param name="numTargets">Number of targets</param>
		void CalcDamage(IBattler user, IBattler target, int numTargets = 1);
	}

	/// <summary>
	/// Interface for moves that reverse all target's stat changes.
	/// Examples: Topsy-Turvy
	/// </summary>
	public interface IInvertTargetStatStages : IBattleMove
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
	/// Interface for moves that reset target's stat stages to 0.
	/// Examples: Clear Smog
	/// </summary>
	public interface IResetTargetStatStages : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that reset all battlers' stat stages to 0.
	/// Examples: Haze
	/// </summary>
	public interface IResetAllBattlersStatStages : IBattleMove
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

	#region Stat Stage Protection

	/// <summary>
	/// Interface for moves that protect user's side from stat lowering.
	/// Examples: Mist
	/// </summary>
	public interface IStartUserSideImmunityToStatStageLowering : IBattleMove
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

	#region Base Stat Manipulation

	/// <summary>
	/// Interface for moves that swap the user's Attack and Defense stats.
	/// Examples: Power Trick
	/// </summary>
	public interface IUserSwapBaseAtkDef : IBattleMove
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
	/// Interface for moves that swap user and target's Speed stats.
	/// Examples: Speed Swap
	/// </summary>
	public interface IUserTargetSwapBaseSpeed : IBattleMove
	{
		/// <summary>
		/// Determines if the move ignores Substitute protection.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <returns>True if the move ignores Substitute</returns>
		bool ignoresSubstitute(IBattler user);

		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that average user and target's Attack and Sp. Attack.
	/// Examples: Power Split
	/// </summary>
	public interface IUserTargetAverageBaseAtkSpAtk : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that average user and target's Defense and Sp. Defense.
	/// Examples: Guard Split
	/// </summary>
	public interface IUserTargetAverageBaseDefSpDef : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	/// <summary>
	/// Interface for moves that average user and target's current HP.
	/// Examples: Pain Split
	/// </summary>
	public interface IUserTargetAverageHP : IBattleMove
	{
		/// <summary>
		/// Performs effects against a specific target.
		/// </summary>
		/// <param name="user">The Pokémon using the move</param>
		/// <param name="target">The target Pokémon</param>
		void EffectAgainstTarget(IBattler user, IBattler target);
	}

	#endregion

	#region Speed and Defensive Effects

	/// <summary>
	/// Interface for moves that double the Speed of user's side for 4 rounds.
	/// Examples: Tailwind
	/// </summary>
	public interface IStartUserSideDoubleSpeed : IBattleMove
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
	/// Interface for moves that swap all battlers' base defensive stats.
	/// Examples: Wonder Room
	/// </summary>
	public interface IStartSwapAllBattlersBaseDefensiveStats : IBattleMove
	{
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

	#endregion
}