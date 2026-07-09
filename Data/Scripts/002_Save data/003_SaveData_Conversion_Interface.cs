using System;
using System.Collections.Generic;
using System.IO;

namespace PokemonEssentials
{
	// Interface for Conversion
	public interface IConversion
	{
		string Id { get; }
		string Title { get; }
		string TriggerType { get; }
		string Version { get; }

		bool ShouldRun(string version);
		void Run(IDictionary<string, object> saveData);
		void RunSingle(object obj, string key);

		// Configuration methods (for use within the registration block)
		//void DisplayTitle(string newTitle);
		//void EssentialsVersion(object version);
		//void GameVersion(object version);
		//void ToValue(string valueId, Action<object> block);
		//void ToAll(Action<IDictionary<string, object>> block);
	}

	// Interface for SaveData
	public interface ISaveDataConversion : ISaveData
	{
		void RegisterConversion(string id, Action<IConversion> block);
		IList<IConversion> GetConversions(IDictionary<string, object> saveData);
		bool RunConversions(IDictionary<string, object> saveData);
		void RunSingleConversions(object obj, string key, IDictionary<string, object> saveData);
	}
}