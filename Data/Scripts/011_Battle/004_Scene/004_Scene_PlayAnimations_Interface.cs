using System;
using System.Collections.Generic;
using PokemonEssentials.RPGMaker;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for global methods related to battle scene animations and effects.
	/// </summary>
	public interface IBattleScenePlayAnimations : IScene, IHaveUpdate, IDisposable
	{
		/// <summary>
		/// Animates the battle intro.
		/// </summary>
		void BattleIntroAnimation();

		/// <summary>
		/// Animates a party lineup appearing for the given side.
		/// </summary>
		/// <param name="side">The side index (0=player, 1=opponent).</param>
		/// <param name="fullAnim">Whether to play the full animation.</param>
		void ShowPartyLineup(int side, bool fullAnim = false);

		/// <summary>
		/// Animates an opposing trainer sliding in from off-screen.
		/// </summary>
		/// <remarks>
		/// Will animate a previous trainer that is already on-screen slide off first.
		/// Used at the end of battle.
		/// </remarks>
		/// <param name="idxTrainer">The trainer index.</param>
		void ShowOpponent(int idxTrainer);

		/// <summary>
		/// Animates a trainer's sprite and party lineup hiding, and Pokémon being sent out.
		/// </summary>
		/// <remarks>
		/// Animates a trainer's sprite and party lineup hiding (if they are visible).
		/// Animates a Pokémon being sent out into battle, then plays the shiny
		/// animation for it if relevant.
		/// </remarks>
		/// <param name="sendOuts">Array of <see cref="KeyValuePair{idxBattler, pkmn}"/> pairs.</param>
		/// <param name="startBattle">Whether this is the start of battle.</param>
		//void SendOutBattlers(IList<(int, IPokemon)> sendOuts, bool startBattle = false);
		void SendOutBattlers(IDictionary<int, IPokemon> sendOuts, bool startBattle = false);

		/// <summary>
		/// Animates a Pokémon being recalled into its Poké Ball and its data box hiding.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		void Recall(int idxBattler);

		/// <summary>
		/// Shows the ability splash bar animation for a battler.
		/// </summary>
		/// <param name="battler">The battler.</param>
		void ShowAbilitySplash(IBattler battler);

		/// <summary>
		/// Hides the ability splash bar animation for a battler.
		/// </summary>
		/// <param name="battler">The battler.</param>
		void HideAbilitySplash(IBattler battler);

		/// <summary>
		/// Replaces the ability splash bar animation for a battler.
		/// </summary>
		/// <param name="battler">The battler.</param>
		void ReplaceAbilitySplash(IBattler battler);

		/// <summary>
		/// Shows a HP-changing animation and animates a data box's HP bar.
		/// </summary>
		/// <remarks>
		/// Called by <see cref="IBattlerChangeSelf.ReduceHP(int, bool, bool, bool)"/>, <see cref="IBattlerChangeSelf.RecoverHP(int, bool, bool)"/>
		/// </remarks>
		/// <param name="battler">The battler.</param>
		/// <param name="oldHP">The old HP value.</param>
		/// <param name="showAnim">Whether to show the animation.</param>
		void HPChanged(IBattler battler, int oldHP, bool showAnim = false);

		/// <summary>
		/// Animates a damage animation for a battler.
		/// </summary>
		/// <param name="battler">The battler.</param>
		/// <param name="effectiveness">Effectiveness value.</param>
		void DamageAnimation(IBattler battler, int effectiveness = 0);

		/// <summary>
		/// Animates HP loss for multiple battlers.
		/// </summary>
		/// <remarks>
		/// Animates battlers flashing and data boxes' HP bars because of damage taken
		/// by an attack. targets is an array, which are all animated simultaneously.
		/// </remarks>
		/// <param name="targets">List of (battler, oldHP, effectiveness) tuples.</param>
		//void HitAndHPLossAnimation(IList<(IBattler, int, int)> targets);
		void HitAndHPLossAnimation(IList<IBattlerHitAndHPLossAnimation> targets);

		/// <summary>
		/// Animates a data box's Exp bar.
		/// </summary>
		/// <param name="battler">The battler.</param>
		/// <param name="startExp">Starting Exp value.</param>
		/// <param name="endExp">Ending Exp value.</param>
		/// <param name="tempExp1">Temporary Exp value 1.</param>
		/// <param name="tempExp2">Temporary Exp value 2.</param>
		void EXPBar(IBattler battler, int startExp, int endExp, int tempExp1, int tempExp2);

		/// <summary>
		/// Shows stats windows upon a Pokémon leveling up.
		/// </summary>
		/// <param name="pkmn">The Pokémon.</param>
		/// <param name="battler">The battler.</param>
		/// <param name="oldTotalHP">Old HP value.</param>
		/// <param name="oldAttack">Old Attack value.</param>
		/// <param name="oldDefense">Old Defense value.</param>
		/// <param name="oldSpAtk">Old Sp. Atk value.</param>
		/// <param name="oldSpDef">Old Sp. Def value.</param>
		/// <param name="oldSpeed">Old Speed value.</param>
		void LevelUp(IPokemon pkmn, IBattler battler, int oldTotalHP, int oldAttack, int oldDefense, int oldSpAtk, int oldSpDef, int oldSpeed);

		/// <summary>
		/// Animates a Pokémon fainting.
		/// </summary>
		/// <param name="battler">The battler.</param>
		void FaintBattler(IBattler battler);

		/// <summary>
		/// Animates throwing a Poké Ball at a Pokémon in an attempt to catch it.
		/// </summary>
		/// <param name="ball">The ball type.</param>
		/// <param name="shakes">Number of shakes.</param>
		/// <param name="critical">Whether it's a critical capture.</param>
		/// <param name="targetBattler">Target battler index.</param>
		/// <param name="showPlayer">Whether to show the player.</param>
		void Throw(int ball, int shakes, bool critical, int targetBattler, bool showPlayer = false);

		/// <summary>
		/// Plays the wild capture success animation.
		/// </summary>
		void ThrowSuccess();

		/// <summary>
		/// Hides the capture ball for a battler.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		void HideCaptureBall(int idxBattler);

		/// <summary>
		/// Animates a Poké Ball being thrown and deflected.
		/// </summary>
		/// <param name="ball">The ball type.</param>
		/// <param name="idxBattler">The battler index.</param>
		void ThrowAndDeflect(int ball, int idxBattler);

		/// <summary>
		/// Hides all battler shadows before yielding to a move animation, then restores them.
		/// </summary>
		/// <remarks>
		/// Hides all battler shadows before yielding to a move animation, and then
		/// restores the shadows afterwards.
		/// </remarks>
		/// <param name="action">The action to perform while shadows are hidden.</param>
		void SaveShadows(Action action);

		/// <summary>
		/// Finds the animation details for a move.
		/// </summary>
		/// <remarks>
		/// Returns the animation ID to use for a given move/user. Returns null if that
		/// move has no animations defined for it.
		/// </remarks>
		/// <param name="move2anim">Move-to-animation mapping.</param>
		/// <param name="moveID">Move ID.</param>
		/// <param name="idxUser">User index.</param>
		/// <param name="hitNum">Hit number.</param>
		/// <returns>Tuple of animation index and noFlip flag, or null.</returns>
		KeyValuePair<int, bool>? FindMoveAnimDetails(IDictionary<int, int> move2anim, int moveID, int idxUser, int hitNum = 0);

		/// <summary>
		/// Finds the animation for a move, using defaults if necessary.
		/// </summary>
		/// <remarks>
		/// Returns the animation ID to use for a given move. If the move has no
		/// animations, tries to use a default move animation depending on the move's
		/// type. If that default move animation doesn't exist, trues to use Tackle's
		/// move animation. Returns nil if it can't find any of these animations to use.
		/// </remarks>
		/// <param name="moveID">Move ID.</param>
		/// <param name="idxUser">User index.</param>
		/// <param name="hitNum">Hit number.</param>
		/// <returns>Tuple of animation index and noFlip flag, or null.</returns>
		KeyValuePair<int, bool>? FindMoveAnimation(int moveID, int idxUser, int hitNum);

		/// <summary>
		/// Plays a move animation.
		/// </summary>
		/// <param name="moveID">Move ID.</param>
		/// <param name="user">User battler.</param>
		/// <param name="targets">Target battlers.</param>
		/// <param name="hitNum">Hit number.</param>
		void Animation(int moveID, IBattler user, IList<IBattler> targets, int hitNum = 0);

		/// <summary>
		/// Plays a common animation.
		/// </summary>
		/// <param name="animName">Animation name.</param>
		/// <param name="user">User battler (optional).</param>
		/// <param name="target">Target battler (optional).</param>
		void CommonAnimation(string animName, IBattler user = null, IBattler target = null);
		void AnimationCore(string animation, IBattler user, IBattler target, bool oppMove = false);
		/// <summary>
		/// Ball burst common animations should have a focus of "Target" and a priority
		/// of "Front".
		/// </summary>
		/// <param name="_picture_ex"></param>
		/// <param name="anim_name"></param>
		/// <param name="battler"></param>
		/// <param name="target_x"></param>
		/// <param name="target_y"></param>
		void BallBurstCommonAnimation(IPictureEx _picture_ex, string anim_name, IBattler battler, IBattler target_x, IBattler target_y);
	}

	public interface IBattlerHitAndHPLossAnimation //: IBattleScenePlayAnimations, IHaveUpdate, IDisposable
	{
		IBattler battler { get; set; }
		int oldHP { get; set; }
		int effectiveness { get; set; }
	}
}