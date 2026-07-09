using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// This script is for Pokémon Essentials. It makes a recordable Hall of Fame
	/// like the Gen 3 games.
	/// </summary>
	/// <remarks>
	/// To this scripts works, put it above main, put a 512x384 picture in
	/// hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
	/// use <see cref="IMainHallOfFame.HallOfFameEntry"/>. After you recorder the first entry, you can access
	/// the hall teams using a PC. You can also check the player Hall of Fame last
	/// number using <see cref="IGlobalMetadataHallOfFame.hallOfFameLastNumber"/>.
	/// </remarks>
	/// <seealso cref="IGameManager.pokemonGlobal"/>
	/// Hall of Fame - by FL (Credits will be apreciated)
	public interface ISceneHallOfFame : IScene, IHaveUpdate {
		/// <summary>
		/// Placement for pokemon icons
		/// </summary>
		void StartScene();

		void StartSceneEntry();

		void StartScenePC();

		void EndScene();

		void slowFadeOut(float duration);

		/// <summary>
		/// Dispose the sprite if the sprite exists and make it null
		/// </summary>
		/// <param name="sprites"></param>
		/// <param name="spritename"></param>
		void restartSpritePosition(ISprite sprites, string spritename);

		/// <summary>
		/// Change the pokémon sprites opacity except the index one
		/// </summary>
		/// <param name="index"></param>
		/// <param name="opacity"></param>
		void setPokemonSpritesOpacity(int index, int opacity = 255);

		void saveHallEntry();

		/// <summary>
		/// Return the x/y point position in screen for battler index number
		/// Don't use odd numbers!
		/// </summary>
		/// <param name="battlernumber"></param>
		/// <returns></returns>
		int xpointformula(int battlernumber);

		int ypointformula(int battlernumber);

		/// <summary>
		/// Returns 0, 1 or 2 as the x position value (left, middle, right column)
		/// </summary>
		/// <param name="battlernumber"></param>
		/// <returns></returns>
		int xpositionformula(int battlernumber);

		/// <summary>
		/// Returns 0, 1 or 2 as the y position value (top, middle, bottom row)
		/// </summary>
		/// <param name="battlernumber"></param>
		/// <returns></returns>
		int ypositionformula(int battlernumber);

		void moveSprite(int i);

		void createBattlers(bool hide = true);

		void createTrainerBattler();

		void writeTrainerData();

		void writePokemonData(IPokemon pokemon, int hallNumber = -1);

		void writeWelcome();

		void AnimationLoop();

		void PCSelection();

		void Update();

		void UpdateAnimation();

		bool UpdatePC();
	}

	//===============================================================================
	//
	//===============================================================================
	public interface IScreenHallOfFame : IScreen {
		IScreenHallOfFame initialize(ISceneHallOfFame scene);

		void StartScreenEntry();

		void StartScreenPC();
	}

	//===============================================================================
	//
	//===============================================================================
	public interface IGlobalMetadataHallOfFame : IGlobalMetadata {
		IList<IPokemon> hallOfFame { get; }

		/// <summary>
		/// Number necessary if hallOfFame array reach in its size limit
		/// </summary>
		int hallOfFameLastNumber { get; }
	}

	public interface IMainHallOfFame : IMain
	{
		//===============================================================================
		//
		//===============================================================================
		void HallOfFameEntry();

		void HallOfFamePC();
	}

	//MenuHandlers.add(:pc_menu, :hall_of_fame, {
	//	"name"      => _INTL("Hall of Fame"),
	//	"order"     => 40,
	//	"condition" => () => next Game.GameData.PokemonGlobal.hallOfFameLastNumber > 0,
	//	"effect"    => menu => {
	//		Message("\\se[PC access]" + _INTL("Accessed the Hall of Fame."));
	//		HallOfFamePC();
	//		next false;
	//	}
	//});
}