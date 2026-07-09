using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IMainUtilitiesBattleAudio : IMain
	{
		//===============================================================================
		// Load various wild battle music.
		//===============================================================================
		/// <summary>
		/// wildParty is an array of Pokémon objects.
		/// </summary>
		/// <param name="_wildParty"></param>
		/// <returns></returns>
		IAudioBGM GetWildBattleBGM(string _wildParty);

		IAudioBGM GetWildVictoryBGM();

		IAudioME GetWildCaptureME();

		//===============================================================================
		// Load/play various trainer battle music.
		//===============================================================================
		void PlayTrainerIntroBGM(int trainer_type);

		/// <summary>
		/// Can be a <see cref="IPlayer"/>, <see cref="INPCTrainer"/> or an array of them.
		/// </summary>
		/// <param name="trainer"></param>
		/// <returns></returns>
		IAudioBGM GetTrainerBattleBGM(params ITrainer[] trainer);

		IAudioBGM GetTrainerBattleBGMFromType(int trainertype);

		/// <summary>
		/// Can be a <see cref="IPlayer"/>, <see cref="INPCTrainer"/> or an array of them.
		/// </summary>
		/// <param name="trainer"></param>
		/// <returns></returns>
		IAudioBGM GetTrainerVictoryBGM(params ITrainer[] trainer);
	}
}