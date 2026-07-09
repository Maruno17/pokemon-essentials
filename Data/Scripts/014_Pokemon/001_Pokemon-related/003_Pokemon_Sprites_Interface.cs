using System;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for Pokemon sprite functionality used out of battle.
	/// Provides methods for displaying Pokemon sprites with proper scaling and positioning.
	/// </summary>
	public interface IPokemonSprite : ISprite, IHaveUpdate, IDisposable
	{
		IPokemonSprite initialize(IViewport viewport);

		/// <summary>
		/// Disposes of the sprite and cleans up resources.
		/// </summary>
		void dispose();

		/// <summary>
		/// Clears the current bitmap and disposes of icon bitmap resources.
		/// </summary>
		void clearBitmap();

		/// <summary>
		/// Sets the origin offset for sprite positioning.
		/// </summary>
		/// <param name="offset">The picture origin offset to use (default: CENTER).</param>
		void setOffset(int offset);

		/// <summary>
		/// Changes the sprite's origin point based on the current offset setting.
		/// </summary>
		void changeOrigin();

		/// <summary>
		/// Sets the Pokemon's bitmap sprite from a Pokemon object.
		/// </summary>
		/// <param name="pokemon">The Pokemon to display.</param>
		/// <param name="back">Whether to show the back sprite (default: false).</param>
		void setPokemonBitmap(object pokemon, bool back = false);

		/// <summary>
		/// Sets the Pokemon's bitmap sprite with a specific species override.
		/// </summary>
		/// <param name="pokemon">The Pokemon to display.</param>
		/// <param name="species">The species to display instead of the Pokemon's actual species.</param>
		/// <param name="back">Whether to show the back sprite (default: false).</param>
		void setPokemonBitmapSpecies(object pokemon, object species, bool back = false);

		/// <summary>
		/// Sets the sprite bitmap using species data parameters.
		/// </summary>
		/// <param name="species">The species to display.</param>
		/// <param name="gender">The gender form (default: 0).</param>
		/// <param name="form">The form number (default: 0).</param>
		/// <param name="shiny">Whether the Pokemon is shiny (default: false).</param>
		/// <param name="shadow">Whether the Pokemon is a shadow Pokemon (default: false).</param>
		/// <param name="back">Whether to show the back sprite (default: false).</param>
		/// <param name="egg">Whether this is an egg sprite (default: false).</param>
		void setSpeciesBitmap(object species, int gender = 0, int form = 0, bool shiny = false, bool shadow = false, bool back = false, bool egg = false);

		/// <summary>
		/// Updates the sprite animation and bitmap.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Interface for Pokemon icon sprites used in menus and party screens.
	/// Provides animated icons that respond to Pokemon status and selection state.
	/// </summary>
	public interface IPokemonIconSprite : ISprite, IHaveUpdate, IDisposable
	{
		/// <summary>
		/// Gets or sets whether this icon is currently selected.
		/// </summary>
		bool selected { get; set; }

		/// <summary>
		/// Gets or sets whether this icon is currently active.
		/// </summary>
		bool active { get; set; }

		/// <summary>
		/// Gets the Pokemon this icon represents.
		/// </summary>
		IPokemon pokemon { get; set; }

		/// <summary>
		/// Gets the logical X coordinate of the icon.
		/// </summary>
		int x { get; }

		/// <summary>
		/// Gets the logical Y coordinate of the icon.
		/// </summary>
		int y { get; }

		/// <summary>
		/// Time in seconds for one animation cycle of a Pokemon icon.
		/// This duration is modified based on Pokemon HP status.
		/// </summary>
		/// <remarks>
		/// Time in seconds for one animation cycle of this Pokémon icon. It is doubled
		/// if the Pokémon is at 50% HP or lower, and doubled again if it is at 25% HP
		/// or lower. The icon doesn't animate at all if the Pokémon is fainted.
		/// </remarks>
		float ANIMATION_DURATION { get; }

		IPokemonIconSprite initialize(IPokemon pokemon, IViewport viewport = null);

		/// <summary>
		/// Disposes of the icon sprite and cleans up resources.
		/// </summary>
		void dispose();

		/// <summary>
		/// Sets or gets the Pokemon this icon represents.
		/// </summary>
		//object pokemon { set; }

		/// <summary>
		/// Sets the origin offset for icon positioning.
		/// </summary>
		/// <param name="offset">The picture origin offset to use (default: CENTER).</param>
		void setOffset(int offset);

		/// <summary>
		/// Changes the icon's origin point based on the current offset setting.
		/// </summary>
		void changeOrigin();

		/// <summary>
		/// Updates the current animation frame based on Pokemon HP status.
		/// Animation speed varies based on HP percentage and stops when fainted.
		/// </summary>
		void update_frame();

		/// <summary>
		/// Updates the icon's animation, bitmap, and jumping animation effects.
		/// </summary>
		void update();
	}

	/// <summary>
	/// Interface for Pokemon species icon sprites used for displaying species without specific Pokemon data.
	/// Provides animated icons based on species, gender, form, and shiny status.
	/// </summary>
	public interface IPokemonSpeciesIconSprite : ISprite, IHaveUpdate, IHaveRefresh, IDisposable
	{
		/// <summary>
		/// Gets the species this icon represents.
		/// </summary>
		int species { get; }

		/// <summary>
		/// Gets the gender form this icon displays.
		/// </summary>
		int gender { get; set; }

		/// <summary>
		/// Gets the form number this icon displays.
		/// </summary>
		int form { get; set; }

		/// <summary>
		/// Gets whether this icon displays a shiny Pokemon.
		/// </summary>
		bool shiny { get; set; }

		IPokemonSpeciesIconSprite initialize(int species, IViewport viewport = null);

		/// <summary>
		/// Disposes of the species icon sprite and cleans up resources.
		/// </summary>
		void dispose();

		/// <summary>
		/// Sets the species this icon represents.
		/// </summary>
		//object species { set; }

		/// <summary>
		/// Sets the gender form this icon displays.
		/// </summary>
		//int gender { set; }

		/// <summary>
		/// Sets the form number this icon displays.
		/// </summary>
		//int form { set; }

		/// <summary>
		/// Sets whether this icon displays a shiny Pokemon.
		/// </summary>
		//bool shiny { set; }

		/// <summary>
		/// Sets all parameters for the species icon at once.
		/// </summary>
		/// <param name="species">The species to display.</param>
		/// <param name="gender">The gender form to display.</param>
		/// <param name="form">The form number to display.</param>
		/// <param name="shiny">Whether to display as shiny (default: false).</param>
		void SetParams(object species, int gender, int form, bool shiny = false);

		/// <summary>
		/// Sets the origin offset for icon positioning.
		/// </summary>
		/// <param name="offset">The picture origin offset to use (default: CENTER).</param>
		void setOffset(int offset);

		/// <summary>
		/// Changes the icon's origin point based on the current offset setting.
		/// </summary>
		void changeOrigin();

		/// <summary>
		/// Refreshes the icon bitmap and animation data based on current parameters.
		/// </summary>
		void refresh();

		/// <summary>
		/// Updates the current animation frame at a constant rate.
		/// </summary>
		void update_frame();

		/// <summary>
		/// Updates the icon's animation and bitmap.
		/// </summary>
		void update();
	}
	/*
	/// <summary>
	/// Interface for Pokemon sprite animation constants and utilities.
	/// Defines timing and animation behavior for Pokemon sprites and icons.
	/// </summary>
	public interface IPokemonSpriteConstants
	{
		/// <summary>
		/// Time in seconds for one animation cycle of a Pokemon icon.
		/// This duration is modified based on Pokemon HP status.
		/// </summary>
		float ANIMATION_DURATION { get; }
	}

	/// <summary>
	/// Interface for Pokemon sprite bitmap management.
	/// Handles the loading and caching of Pokemon sprite bitmaps.
	/// </summary>
	public interface IPokemonSpriteBitmapManager
	{
		/// <summary>
		/// Gets a sprite bitmap for a specific Pokemon.
		/// </summary>
		/// <param name="pokemon">The Pokemon to get the sprite for.</param>
		/// <param name="back">Whether to get the back sprite.</param>
		/// <returns>The animated bitmap for the Pokemon sprite.</returns>
		object sprite_bitmap_from_pokemon(object pokemon, bool back);

		/// <summary>
		/// Gets a sprite bitmap for a Pokemon with species override.
		/// </summary>
		/// <param name="pokemon">The Pokemon to get the sprite for.</param>
		/// <param name="back">Whether to get the back sprite.</param>
		/// <param name="species">The species to display instead of the Pokemon's species.</param>
		/// <returns>The animated bitmap for the Pokemon sprite.</returns>
		object sprite_bitmap_from_pokemon(object pokemon, bool back, object species);

		/// <summary>
		/// Gets a sprite bitmap using species parameters.
		/// </summary>
		/// <param name="species">The species to get the sprite for.</param>
		/// <param name="form">The form number.</param>
		/// <param name="gender">The gender form.</param>
		/// <param name="shiny">Whether the Pokemon is shiny.</param>
		/// <param name="shadow">Whether the Pokemon is a shadow Pokemon.</param>
		/// <param name="back">Whether to get the back sprite.</param>
		/// <param name="egg">Whether this is an egg sprite.</param>
		/// <returns>The animated bitmap for the Pokemon sprite.</returns>
		object sprite_bitmap(object species, int form, int gender, bool shiny, bool shadow, bool back, bool egg);

		/// <summary>
		/// Gets the filename for a Pokemon icon.
		/// </summary>
		/// <param name="pokemon">The Pokemon to get the icon filename for.</param>
		/// <returns>The filename of the Pokemon's icon.</returns>
		string icon_filename_from_pokemon(object pokemon);

		/// <summary>
		/// Gets the filename for a species icon.
		/// </summary>
		/// <param name="species">The species to get the icon filename for.</param>
		/// <param name="form">The form number.</param>
		/// <param name="gender">The gender form.</param>
		/// <param name="shiny">Whether the Pokemon is shiny.</param>
		/// <returns>The filename of the species' icon.</returns>
		string icon_filename(object species, int form, int gender, bool shiny);
	}
	*/
}