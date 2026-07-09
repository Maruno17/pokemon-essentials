using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for managing special battle introduction animations.
	/// </summary>
	public interface ISpecialBattleIntroAnimations
	{
		/// <summary>
		/// Registers a special battle intro animation.
		/// </summary>
		/// <remarks>
		///  Registers special battle transition animations which may be used instead of
		///  the default ones. There are examples below of how to register them.
		///
		///  The register call has 4 arguments:
		///     1) The name of the animation. Typically unused, but helps to identify the
		///        registration code for a particular animation if necessary.
		///     2) The animation's priority. If multiple special animations could trigger
		///        for the same battle, the one with the highest priority number is used.
		///     3) A condition proc which decides whether the animation should trigger.
		///     4) The animation itself. Could be a bunch of code, or a call to, say,
		///        pbCommonEvent(20) or something else. By the end of the animation, the
		///        screen should be black.
		///  Note that you can get an image of the current game screen with
		///  Graphics.snap_to_bitmap.
		/// </remarks>
		/// <param name="name">The name of the animation</param>
		/// <param name="priority">The priority number (higher priority animations take precedence)</param>
		/// <param name="condition">A function that determines if the animation should trigger</param>
		/// <param name="hash">The animation procedure to execute</param>
		//void register(string name, int priority, object condition, object hash);
		void register(string name, int priority, Func<IViewport, int, IList<IPokemon>, int> condition, Action<IViewport, int, IList<IPokemon>, int> hash);

		/// <summary>
		/// Removes a registered animation by name.
		/// </summary>
		/// <param name="name">The name of the animation to remove</param>
		void remove(string name);

		/// <summary>
		/// Iterates through all registered animations in priority order.
		/// </summary>
		void each();

		/// <summary>
		/// Checks if an animation with the given name is registered.
		/// </summary>
		/// <param name="name">The name to check</param>
		/// <returns>True if the animation exists</returns>
		bool has(string name);

		/// <summary>
		/// Gets a registered animation by name.
		/// </summary>
		/// <param name="name">The name of the animation</param>
		/// <returns>The animation data or null if not found</returns>
		object[] get(string name);
	}

	/// <summary>
	/// Interface for Game_Temp battle animation data.
	/// </summary>
	//public interface IGameTempBattleAnim
	public interface ITempMetadataBattleIntroAnimation : ITempMetadata
	{
		/// <summary>
		/// Gets or sets the transition animation data.
		/// </summary>
		object[] transition_animation_data { get; set; }
	}

	/// <summary>
	/// Interface for battle animation functions.
	/// </summary>
	public interface IMainBattleIntroAnimation : IMain
	{
		/// <summary>
		/// Puts the scene in standby mode for battle animation.
		/// </summary>
		void SceneStandby();

		/// <summary>
		/// Plays the main battle introduction animation.
		/// </summary>
		/// <param name="bgm">Background music to play</param>
		/// <param name="battletype">Type of battle (0=wild, 1=trainer, 2=double wild, 3=double trainer)</param>
		/// <param name="foe">Array of opposing trainers/Pokémon</param>
		void BattleAnimation(IAudioBGM bgm = null, int battletype = 0, object foe = null);

		/// <summary>
		/// Core battle animation functionality.
		/// </summary>
		/// <param name="anim">Animation name to play</param>
		/// <param name="viewport">Viewport for the animation</param>
		/// <param name="location">Location type (0=outside, 1=inside, 2=cave, 3=water)</param>
		/// <param name="num_flashes">Number of initial screen flashes</param>
		void BattleAnimationCore(string anim, IViewport viewport, int location, int num_flashes = 2);
	}
	/*
	/// <summary>
	/// Interface for VS trainer animation condition checking.
	/// </summary>
	public interface IVsTrainerAnimationCondition
	{
		/// <summary>
		/// Checks if the VS trainer animation should trigger.
		/// </summary>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		/// <returns>True if the animation should trigger</returns>
		bool check_vs_trainer_condition(int battle_type, object[] foe, int location);

		/// <summary>
		/// Checks if the VS Elite Four animation should trigger.
		/// </summary>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		/// <returns>True if the animation should trigger</returns>
		bool check_vs_elite_four_condition(int battle_type, object[] foe, int location);

		/// <summary>
		/// Checks if the VS Rocket Admin animation should trigger.
		/// </summary>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		/// <returns>True if the animation should trigger</returns>
		bool check_vs_admin_condition(int battle_type, object[] foe, int location);

		/// <summary>
		/// Checks if the alternate VS trainer animation should trigger.
		/// </summary>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		/// <returns>True if the animation should trigger</returns>
		bool check_alternate_vs_trainer_condition(int battle_type, object[] foe, int location);

		/// <summary>
		/// Checks if the Rocket Grunt animation should trigger.
		/// </summary>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		/// <returns>True if the animation should trigger</returns>
		bool check_rocket_grunt_condition(int battle_type, object[] foe, int location);
	}

	/// <summary>
	/// Interface for VS trainer animation procedures.
	/// </summary>
	public interface IVsTrainerAnimationProcedures
	{
		/// <summary>
		/// Executes the HGSS VS trainer animation.
		/// </summary>
		/// <param name="viewport">Animation viewport</param>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		void execute_vs_trainer_animation(IViewport viewport, int battle_type, object[] foe, int location);

		/// <summary>
		/// Executes the VS Elite Four animation.
		/// </summary>
		/// <param name="viewport">Animation viewport</param>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		void execute_vs_elite_four_animation(IViewport viewport, int battle_type, object[] foe, int location);

		/// <summary>
		/// Executes the VS Rocket Admin animation.
		/// </summary>
		/// <param name="viewport">Animation viewport</param>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		void execute_vs_admin_animation(IViewport viewport, int battle_type, object[] foe, int location);

		/// <summary>
		/// Executes the alternate VS trainer animation.
		/// </summary>
		/// <param name="viewport">Animation viewport</param>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		void execute_alternate_vs_trainer_animation(IViewport viewport, int battle_type, object[] foe, int location);

		/// <summary>
		/// Executes the Rocket Grunt animation.
		/// </summary>
		/// <param name="viewport">Animation viewport</param>
		/// <param name="battle_type">Type of battle</param>
		/// <param name="foe">Array of opposing trainers</param>
		/// <param name="location">Battle location</param>
		void execute_rocket_grunt_animation(IViewport viewport, int battle_type, object[] foe, int location);
	}*/
}