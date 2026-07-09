using PokemonEssentials.RPGMaker;
using System;
using System.Collections.Generic;
using System.IO;

namespace PokemonEssentials
{
	public interface IGame { }

	public interface IMainGameManager : IMain {
		/// <summary>
		/// Gets the player instance.
		/// </summary>
		//IPlayer player							{ get; }
		IGamePlayer player							{ get; }
		/// <summary>
		/// Gets or sets the current game map.
		/// </summary>
		IGameMap game_map						{ get; set; }
		/// <summary>
		/// Gets the temporary game metadata.
		/// </summary>
		ITempMetadata game_temp					{ get; }
		/// <summary>
		/// Gets the game system instance.
		/// </summary>
		IGameSystem game_system					{ get; }
		/// <summary>
		/// <seealso cref="pokemon_system"/>
		/// </summary>
		/// <remarks>Game [Player Menu] Options</remarks>
		//PokemonSystem pokemon_system			{ get; }
		IGameSystemOption PokemonSystem			{ get; }
		/// <summary>
		/// <seealso cref="game_switches"/>
		/// </summary>
		//IGameSwitches game_switches			{ get; }
		IGameSwitches switches					{ get; }
		/// <summary>
		/// <seealso cref="game_variables"/>
		/// </summary>
		//IGameVariables game_variables			{ get; }
		IGameVariable variables				{ get; }
		/// <summary>
		/// <seealso cref="self_switches"/>
		/// </summary>
		//IGameSelfSwitches self_switches			{ get; }
		IGameSelfSwitches game_self_switches	{ get; }
		IGameScreen game_screen					{ get; }
		/// <summary>
		/// <seealso cref="map_factory"/>
		/// </summary>
		//IPokemonMapFactory map_factory			{ get; }
		IMapFactory MapFactory					{ get; }
		IGamePlayer game_player					{ get; }
		/// <summary>
		/// <seealso cref="global_metadata"/>
		/// </summary>
		//PokemonGlobalMetadata global_metadata	{ get; }
		IGlobalMetadata PokemonGlobal			{ get; }
		/// <summary>
		/// <seealso cref="map_metadata"/>
		/// </summary>
		//PokemonMapMetadata map_metadata		{ get; }
		IMapMetadata PokemonMap					{ get; }
		IGameBag bag							{ get; }
		/// <summary>
		/// <seealso cref="storage_system"/>
		/// </summary>
		//PokemonStorage storage_system			{ get; }
		IGameStorage PokemonStorage			{ get; }
		IGameStats stats						{ get; }
		//IScene_Map scene							{ get; set; }
		ISceneMap scene							{ get; set; }
		IPokemonEncounters PokemonEncounters	{ get; }
		//IMapInterpreter MapInterpreter			{ get; }
		IInterpreter MapInterpreter				{ get; }
		string save_engine_version				{ get; set; }
		string save_game_version				{ get; set; }
		string data_animations					{ get; set; }
		string data_tilesets					{ get; set; }
		IList<ICommonEvent> data_common_events	{ get; set; }
		ISystem data_system						{ get; set; }
	}
}