using PokemonEssentials.RPGMaker.Kernel;
using System;
using System.Collections.Generic;
using System.Reflection;

namespace PokemonEssentials
{
	/// <summary>
	/// Data box for regular battles.
	/// </summary>
	/// <remarks>
	/// Interface for the Pokémon data box in the battle scene.
	/// </remarks>
	public interface IPokemonDataBox : ISprite, IHaveUpdate, IHaveRefresh, IDisposable
	{
		/// <summary>
		/// Time in seconds to fully fill the Exp bar (from empty).
		/// </summary>
		float EXP_BAR_FILL_TIME         { get; } //= 1.75
		/// <summary>
		/// Time in seconds for this data box to flash when the Exp fully fills.
		/// </summary>
		float EXP_FULL_FLASH_DURATION   { get; } //= 0.2
		/// <summary>
		/// Maximum time in seconds to make a change to the HP bar.
		/// </summary>
		float HP_BAR_CHANGE_TIME        { get; } //= 1.0
		/// <summary>
		/// Time (in seconds) for one complete sprite bob cycle (up and down) while
		/// choosing a command for this battler or when this battler is being chosen as
		/// a target. Set to nil to prevent bobbing.
		/// </summary>
		float BOBBING_DURATION          { get; } //= 0.6
		/// <summary>
		/// Height in pixels of a status icon
		/// </summary>
		float STATUS_ICON_HEIGHT        { get; } //= 16
		int x { set; }
		int y { set; }
		int z { set; }
		int opacity { set; }
		bool visible { set; }
		IColor color { set; }
		int hp { get; }
		IPokemonDataBox initialize(IBattler battler, int sideSize, IViewport viewport = null);
		void initializeDataBoxGraphic(int sideSize);
		void initializeOtherGraphics(IViewport viewport);
		float exp_fraction { get; set; }
		/// <summary>Gets the battler associated with this data box.</summary>
		IBattler Battler { get; set; }
		/// <summary>Gets or sets whether the data box is selected.</summary>
		int Selected { get; set; }
		/// <summary>Animates the HP bar from old to new value.</summary>
		/// <remarks>
		/// NOTE: A change in HP takes the same amount of time to animate, no matter how
		///       big a change it is.
		/// </remarks>
		void AnimateHP(int oldVal, int newVal);
		/// <summary>Returns whether the HP bar is animating.</summary>
		bool AnimatingHP();
		/// <summary>Animates the Exp bar from old to new value.</summary>
		/// <remarks>
		/// NOTE: Filling the Exp bar from empty to full takes <see cref="EXP_BAR_FILL_TIME"/> seconds
		///       no matter what. Filling half of it takes half as long, etc.
		/// </remarks>
		void AnimateExp(int oldVal, int newVal, int range);
		/// <summary>Returns whether the Exp bar is animating.</summary>
		bool AnimatingExp();
		void DrawNumber(int number, IBitmap btmp, float startX, float startY, int align = 0);//:left
		void draw_background();
		void draw_name();
		void draw_level();
		void draw_gender();
		void draw_status();
		void draw_shiny_icon();
		void draw_special_form_icon();
		void draw_owned_icon();
		/// <summary>Refreshes the data box display.</summary>
		void Refresh();
		void refresh_hp();
		void refresh_exp();
		void update_hp_animation();
		void update_exp_animation();
		void update_positions();
		/// <summary>Updates the data box state.</summary>
		void Update();
	}

	/// <summary>
	/// Splash bar to announce a triggered ability.
	/// </summary>
	/// <remarks>
	/// Interface for the ability splash bar in the battle scene.
	/// </remarks>
	public interface IAbilitySplashBar : ISprite, IHaveUpdate, IHaveRefresh, IDisposable
	{
		int x { set; }
		int y { set; }
		int z { set; }
		int opacity { set; }
		bool visible { set; }
		IColor color { set; }
		/// <summary>Gets the battler associated with the splash bar.</summary>
		IBattler Battler { get; set; }
		IAbilitySplashBar initialize(int sideSize, IViewport viewport = null);
		/// <summary>Refreshes the splash bar display.</summary>
		void Refresh();
		/// <summary>Updates the splash bar state.</summary>
		void Update();
	}

	/// <summary>
	/// Pokémon sprite (used in battle).
	/// </summary>
	/// <remarks>
	/// Interface for the battler sprite in the battle scene.
	/// </remarks>
	public interface IBattlerSprite : RPG.ISprite, IHaveUpdate, IDisposable
	{
		/// <summary>Gets the Pokémon associated with the sprite.</summary>
		IPokemon Pkmn { get; }
		/// <summary>Gets or sets the battler index.</summary>
		int Index { get; set; }
		/// <summary>Gets or sets whether the sprite is selected.</summary>
		int Selected { get; set; }
		int sideSize { get; }
		int x { get; set; }
		int y { get; set; }
		int width { get; }
		int height { get; }
		bool visible { set; }
		/// <summary>
		/// Time (in seconds) for one complete sprite bob cycle (up and down) while
		/// choosing a command for this battler. Set to nil to prevent bobbing.
		/// </summary>
		float BOBBING_DURATION { get; } //= 0.6
		/// <summary>
		/// Time (in seconds) for one complete blinking cycle while this battler is
		/// being chosen as a target. Set to nil to prevent blinking.
		/// </summary>
		float TARGET_BLINKING_DURATION { get; } //= 16
		IBattlerSprite initialize(IViewport viewport, int sideSize, int index, string battleAnimations);
		/// <summary>
		/// Set sprite's origin to bottom middle
		/// </summary>
		void SetOrigin();
		void SetPosition();
		void setPokemonBitmap(IPokemon pkmn, bool back = false);
		void PlayIntroAnimation(IPictureEx pictureEx = null);
		/// <summary>Refreshes the sprite display.</summary>
		//void Refresh();
		/// <summary>Updates the sprite state.</summary>
		void Update();
	}

	/// <summary>
	/// Shadow sprite for Pokémon (used in battle).
	/// </summary>
	/// <remarks>
	/// Interface for the battler shadow sprite in the battle scene.
	/// </remarks>
	public interface IBattlerShadowSprite : RPG.ISprite, IHaveUpdate, IDisposable
	{
		/// <summary>Gets the Pokémon associated with the shadow sprite.</summary>
		IPokemon Pkmn { get; }
		/// <summary>Gets or sets the battler index.</summary>
		int Index { get; set; }
		/// <summary>Gets or sets whether the shadow sprite is selected.</summary>
		int Selected { get; set; }
		int width { get; }
		int height { get; }
		IBattlerShadowSprite initialize(IViewport viewport, int sideSize, int index);
		/// <summary>
		/// Set sprite's origin to centre
		/// </summary>
		void SetOrigin();
		void SetPosition();
		void setPokemonBitmap(IPokemon pkmn);
		/// <summary>Refreshes the shadow sprite display.</summary>
		//void Refresh();
		/// <summary>Updates the shadow sprite state.</summary>
		void Update();
	}
}