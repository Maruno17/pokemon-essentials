using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Data caches.
	/// </summary>
	public interface ITempMetadataMiscData : ITempMetadata {
		int? regional_dexes_data			{ get; set; }
		int? battle_animations_data			{ get; set; }
		int? move_to_battle_animation_data	{ get; set; }
		int? map_infos						{ get; set; }
	}

	public interface IMainMetadataMiscData : IMain
	{
		void ClearData();

		/// <summary>
		/// Method to get Regional Dexes data.
		/// </summary>
		void LoadRegionalDexes();

		/// <summary>
		/// Methods relating to battle animations data.
		/// </summary>
		void LoadBattleAnimations();

		void LoadMoveToAnim();

		/// <summary>
		/// Method relating to map infos data.
		/// </summary>
		void LoadMapInfos();
	}
}