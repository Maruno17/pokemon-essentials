using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IMainTrainerLoadNew : IMain
	{
		//===============================================================================
		//
		//===============================================================================
		ITrainer LoadTrainer(int tr_type, string tr_name, int tr_version = 0);

		ITrainer NewTrainer(int tr_type, string tr_name, int tr_version, bool save_changes = true);

		void ConvertTrainerData();

		bool TrainerTypeCheck(int trainer_type);

		/// <summary>
		/// Called from trainer events to ensure the trainer exists
		/// </summary>
		/// <param name="tr_type"></param>
		/// <param name="tr_name"></param>
		/// <param name="max_battles"></param>
		/// <param name="tr_version"></param>
		bool TrainerCheck(int tr_type, string tr_name, int max_battles, int tr_version = 0);

		int GetFreeTrainerParty(int tr_type, string tr_name);

		int MissingTrainer(int tr_type, string tr_name, int tr_version);
	}
}