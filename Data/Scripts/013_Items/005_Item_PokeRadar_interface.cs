using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	//===============================================================================
	//
	//===============================================================================
	public interface IGlobalMetadataPokeRadar : IGlobalMetadata {
		int? pokeradarBattery		{ get; set; }
	}

	//===============================================================================
	//
	//===============================================================================
	public interface ITempMetadataPokeRadar : ITempMetadata {
		/// <summary>[species, level, chain count, grasses (x,y,ring,rarity)]</summary>
		IPokeRadarMetaData poke_radar_data		{ get; set; }
	}

	public interface IPokeRadarMetaData
	{
		//Tile Grass; x,y,ring,rarity
		//int[] Grass; //x,y,ring,rarity
		IPokeRadarGrassData[] Grass { get; }
		int ChainCount { get; }
		int Species { get; }
		int Level { get; }
	}

	public interface IPokeRadarGrassData
	{
		int X { get; }
		int Y { get; }
		/// <summary>
		/// (0-3 inner to outer)
		/// </summary>
		int Ring { get; }
		int Rarity { get; }
		//IPokeRadarGrassData(int mapx, int mapy, int ring, int rarity)
	}

	public interface IMainItemPokeRadar : IMain
	{
		//===============================================================================
		// Using the Poke Radar.
		//===============================================================================
		bool CanUsePokeRadar();

		bool UsePokeRadar();

		void PokeRadarCancel();

		void PokeRadarHighlightGrass(bool showmessage = true);

		int PokeRadarGetShakingGrass { get; }

		bool PokeRadarOnShakingGrass { get; }

		IEncounterPokemonData PokeRadarGetEncounter(int rarity = 0);

		//===============================================================================
		// Event handlers.
		//===============================================================================
		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_wild_species_chosen, :poke_radar_chain,
		/// 	block: (encounter) => {
		/// 		if (GameData.EncounterType.get(Game.GameData.game_temp.encounter_type).type != types.land ||
		/// 			Game.GameData.PokemonGlobal.bicycle || Game.GameData.PokemonGlobal.partner) {
		/// 			PokeRadarCancel();
		/// 			continue;
		/// 		}
		/// 		ring = PokeRadarGetShakingGrass;
		/// 		if (ring >= 0) {   // Encounter triggered by stepping into rustling grass
		/// 			// Get rarity of shaking grass
		/// 			rarity = 0;   // 0 = rustle, 1 = vigorous rustle, 2 = shiny rustle
		/// 			Game.GameData.game_temp.poke_radar_data[3].each(g => { if (g[2] == ring) rarity = g[3]; });
		/// 			if (Game.GameData.game_temp.poke_radar_data[2] > 0) {   // Chain count, i.e. is chaining
		/// 				chain_chance = 58 + (ring * 10);
		/// 				chain_chance += (int)Math.Min(Game.GameData.game_temp.poke_radar_data[2], 40) / 4;   // Chain length
		/// 				if (Game.GameData.game_temp.poke_radar_data[4]) chain_chance += 10;   // Previous in chain was caught
		/// 				if (rarity == 2 || rand(100) < chain_chance) {
		/// 					// Continue the chain
		/// 					encounter[0] = Game.GameData.game_temp.poke_radar_data[0];   // Species
		/// 					encounter[1] = Game.GameData.game_temp.poke_radar_data[1];   // Level
		/// 					Game.GameData.game_temp.force_single_battle = true;
		/// 				} else {
		/// 					// Break the chain, force an encounter with a different species
		/// 					100.times do;
		/// 						if (encounter && encounter[0] != Game.GameData.game_temp.poke_radar_data[0]) break;
		/// 						new_encounter = Game.GameData.PokemonEncounters.choose_wild_pokemon(Game.GameData.PokemonEncounters.encounter_type);
		/// 						encounter[0] = new_encounter[0];
		/// 						encounter[1] = new_encounter[1];
		/// 					}
		/// 					if (encounter[0] == Game.GameData.game_temp.poke_radar_data[0] && encounter[1] == Game.GameData.game_temp.poke_radar_data[1]) {
		/// 						// Chain couldn't be broken somehow; continue it after all
		/// 						Game.GameData.game_temp.force_single_battle = true;
		/// 					} else {
		/// 						PokeRadarCancel();
		/// 					}
		/// 				}
		/// 			} else {   // Not chaining; will start one
		/// 				// Force random wild encounter, vigorous shaking means rarer species
		/// 				new_encounter = PokeRadarGetEncounter(rarity);
		/// 				encounter[0] = new_encounter[0];
		/// 				encounter[1] = new_encounter[1];
		/// 				Game.GameData.game_temp.force_single_battle = true;
		/// 			}
		/// 		} else if (encounter) {   // Encounter triggered by stepping in non-rustling grass
		/// 			PokeRadarCancel();
		/// 		}
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnWildSpeciesChosen"/>
		/// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
		/// <param name="encounter"></param>
		void OnWildSpeciesChosenTrigger_poke_radar_chain(IEncounterType encounter);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_wild_pokemon_created, :poke_radar_shiny,
		/// 	block: (pkmn) => {
		/// 		if (!Game.GameData.game_temp.poke_radar_data) continue;
		/// 		grasses = Game.GameData.game_temp.poke_radar_data[3];
		/// 		if (!grasses) continue;
		/// 		foreach (var grass in grasses) { //'grasses.each' do => |grass|
		/// 			if (Game.GameData.game_player.x != grass[0] || Game.GameData.game_player.y != grass[1]) continue;
		/// 			if (grass[3] == 2) pkmn.shiny = true;
		/// 			break;
		/// 		}
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnWildPokemonCreate"/>
		/// <seealso cref="IEvents.OnWildPokemonCreated"/>
		/// <seealso cref="EventArg.IOnWildPokemonCreateEventArgs"/>
		/// <param name="pkmn"></param>
		void OnWildPokemonCreatedTrigger_poke_radar_shiny(IPokemon pkmn);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_wild_battle_end, :poke_radar_continue_chain,
		/// 	block: (species, level, outcome) => {
		/// 		if (Game.GameData.game_temp.poke_radar_data && new []{Battle.Outcome.WIN, Battle.Outcome.CATCH}.Contains(outcome)) {
		/// 			Game.GameData.game_temp.poke_radar_data[0] = species;
		/// 			Game.GameData.game_temp.poke_radar_data[1] = level;
		/// 			Game.GameData.game_temp.poke_radar_data[2] += 1;
		/// 			Game.GameData.stats.poke_radar_longest_chain = (int)Math.Max(Game.GameData.game_temp.poke_radar_data[2], Game.GameData.stats.poke_radar_longest_chain);
		/// 			// Catching makes the next Radar encounter more likely to continue the chain
		/// 			Game.GameData.game_temp.poke_radar_data[4] = (outcome == Battle.Outcome.CATCH);
		/// 			PokeRadarHighlightGrass(false);
		/// 		} else {
		/// 			PokeRadarCancel();
		/// 		}
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnWildBattleEnd"/>
		/// <seealso cref="EventArg.IOnWildBattleEndEventArgs"/>
		/// <param name="species"></param>
		/// <param name="level"></param>
		/// <param name="outcome"></param>
		void on_wild_battle_endTrigger_poke_radar_continue_chain(int species, int level, int outcome);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_step_taken, :poke_radar,
		/// 	block: () => {
		/// 		if (Game.GameData.PokemonGlobal.pokeradarBattery && Game.GameData.PokemonGlobal.pokeradarBattery > 0 &&
		/// 			!Game.GameData.game_temp.poke_radar_data) {
		/// 			Game.GameData.PokemonGlobal.pokeradarBattery -= 1;
		/// 		}
		/// 		terrain = Game.GameData.game_map.terrain_tag(Game.GameData.game_player.x, Game.GameData.game_player.y);
		/// 		if (!terrain.land_wild_encounters || !terrain.shows_grass_rustle) {
		/// 			PokeRadarCancel();
		/// 		}
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnStepTaken"/>
		/// <seealso cref="IEvents.OnPlayerStepTaken"/>
		/// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
		void on_player_step_takenTrigger_poke_radar();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_enter_map, :cancel_poke_radar,
		/// 	block: (_old_map_id) => {
		/// 		PokeRadarCancel();
		/// 	}
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnEnterMap"/>
		/// <seealso cref="EventArg.IOnMapCreateEventArgs"/>
		/// <param name="_old_map_id"></param>
		void on_enter_mapTrigger_cancel_poke_radar(int _old_map_id);


		//===============================================================================
		// Item handlers.
		//===============================================================================
		/*
		ItemHandlers.UseInField.add(:POKERADAR, block: (item) => {
			next UsePokeRadar;
		});

		ItemHandlers.UseFromBag.add(:POKERADAR, block: (item) => {
			next (CanUsePokeRadar()) ? 2 : 0;
		});
		*/
	}
}