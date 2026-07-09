using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization.Formatters.Binary;
//using Newtonsoft.Json.Linq;
//using Newtonsoft.Json;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for save data values.
	/// </summary>
	/// <remarks>
	/// Contains the save values defined in Essentials by default.
	/// </remarks>
	//[System.Serializable]
	public interface ISaveDataObject
	{
		IPlayer player							{ get; set; }
		IGameSystem game_system					{ get; set; }
		IGameSystemOption pokemon_system		{ get; set; }
		IGameSwitches switches					{ get; set; }
		IGameVariable variables					{ get; set; }
		IGameSelfSwitches self_switches			{ get; set; }
		IGameScreen game_screen					{ get; set; }
		IMapFactory map_factory					{ get; set; }	//IPokemonMapFactory
		IGamePlayer game_player					{ get; set; }
		IGlobalMetadata global_metadata			{ get; set; }	//IPokemonGlobalMetadata
		IMapMetadata map_metadata				{ get; set; }	//IPokemonMapMetadata
		IGameBag bag							{ get; set; }	//IPokemonBag
		IGameStorage storage_system				{ get; set; }	//IPokemonStorage
		IGameStats stats						{ get; set; }
		string essentials_version				{ get; set; }
		string game_version						{ get; set; }
	}
	/*
	/// <summary>
	/// Interface for save data JSON conversion.
	/// </summary>
	public interface ISaveDataConverter
	{
		void WriteJson(JsonWriter writer, ISaveDataObject value, JsonSerializer serializer);
		ISaveDataObject ReadJson(JsonReader reader, Type objectType, ISaveDataObject existingValue, bool hasExistingValue, JsonSerializer serializer);
	}

	/// <summary>
	/// JSON converter for save data serialization.
	/// </summary>
	public class SaveDataConverter : JsonConverter<ISaveDataObject>, ISaveDataConverter
	{
		public override bool CanWrite
		{
			get { return false; }
		}

		public override void WriteJson(JsonWriter writer, ISaveDataObject value, JsonSerializer serializer)
		{
			JToken t = JToken.FromObject(value);
			if (t.Type != JTokenType.Object)
			{
				t.WriteTo(writer);
			}
			else
			{
				JObject o = (JObject)t;
				IList<string> propertyNames = o.Properties().Select(p => p.Name).ToList();

				o.AddFirst(new JProperty("Keys", new JArray(propertyNames)));
				o.WriteTo(writer);
			}

			if (value != null)
			{
#if DEBUG
				//File.open(file_path, "wb", file => { Marshal.dump(saveDataHash, file); });
				//System.IO.File.WriteAllText(filePath,
				//	JsonConvert.SerializeObject(value
				//		,formatting: Formatting.Indented
				//		//,settings: new JsonSerializerSettings() { Formatting = Formatting.Indented }
				//	));
#else
				BinaryFormatter bf = new BinaryFormatter();
				using(FileStream fs = System.IO.File.Open(filePath, System.IO.FileMode.OpenOrCreate, System.IO.FileAccess.Write))
				{
					bf.Serialize(fs, value);
				}
#endif
			}
		}

		public override ISaveDataObject ReadJson(JsonReader reader, Type objectType, ISaveDataObject existingValue, bool hasExistingValue, JsonSerializer serializer)
		{
			//throw new NotImplementedException("Unnecessary because CanRead is false. The type will skip the converter.");
			if (reader.TokenType == JsonToken.Null)
				return null;

			ISaveDataObject data = null;
			// Load JObject from stream
			JObject jo = JObject.Load(reader);
			// Create target object based on JObject
			//ISaveDataObject target = Create(objectType, jo);

			IDictionary<string, object> jo_player					= (IDictionary<string, object>)ToObject(jo["player"]);
			IDictionary<string, object> jo_game_system				= (IDictionary<string, object>)ToObject(jo["game_system"]);
			IDictionary<string, object> jo_pokemon_system			= (IDictionary<string, object>)ToObject(jo["pokemon_system"]);
			IDictionary<string, object> jo_switches					= (IDictionary<string, object>)ToObject(jo["switches"]);
			IDictionary<string, object> jo_variables				= (IDictionary<string, object>)ToObject(jo["variables"]);
			IDictionary<string, object> jo_self_switches			= (IDictionary<string, object>)ToObject(jo["self_switches"]);
			IDictionary<string, object> jo_game_screen				= (IDictionary<string, object>)ToObject(jo["game_screen"]);
			IDictionary<string, object> jo_map_factory				= (IDictionary<string, object>)ToObject(jo["map_factory"]);
			IDictionary<string, object> jo_game_player				= (IDictionary<string, object>)ToObject(jo["game_player"]);
			IDictionary<string, object> jo_global_metadata			= (IDictionary<string, object>)ToObject(jo["global_metadata"]);
			IDictionary<string, object> jo_map_metadata				= (IDictionary<string, object>)ToObject(jo["map_metadata"]);
			IDictionary<string, object> jo_bag						= (IDictionary<string, object>)ToObject(jo["bag"]);
			IDictionary<string, object> jo_storage_system			= (IDictionary<string, object>)ToObject(jo["storage_system"]);
			IDictionary<string, object> jo_stats					= (IDictionary<string, object>)ToObject(jo["stats"]);

			//IPlayer player							= new Player() { };
			//Game_System game_system					= jo["game_system"].ToObject<IGameSystem>();
			//PokemonSystem pokemon_system			= jo["pokemon_system"].ToObject<IPokemonSystem>();
			//Game_Switches switches					= jo["switches"].ToObject<IGameSwitches>();
			//Game_Variables variables				= jo["variables"].ToObject<IGameVariable>();
			//Game_SelfSwitches self_switches			= jo["self_switches"].ToObject<IGameSelfSwitches>();
			//Game_Screen game_screen					= jo["game_screen"].ToObject<IGameScreen>();
			//PokemonMapFactory map_factory			= jo["map_factory"].ToObject<IMapFactory>();
			//Game_Player game_player					= jo["game_player"].ToObject<IGamePlayer>();
			//PokemonGlobalMetadata global_metadata	= jo["global_metadata"].ToObject<IGlobalMetadata>();
			//PokemonMapMetadata map_metadata			= jo["map_metadata"].ToObject<IMapMetadata>();
			//PokemonBag bag							= jo["bag"].ToObject<IGameBag>();
			//PokemonStorage storage_system			= jo["storage_system"].ToObject<IGameStorage>();
			//GameStats stats							= jo["stats"].ToObject<IGameStats>();
			//string essentials_version				= jo["essentials_version"].ToObject<string>();
			//string game_version						= jo["game_version"].ToObject<string>();

			data.player					= jo["player"].ToObject<IPlayer>();
			data.game_system			= jo["game_system"].ToObject<IGameSystem>();
			data.pokemon_system			= jo["pokemon_system"].ToObject<IGameSystemOption>();
			data.switches				= jo["switches"].ToObject<IGameSwitches>();
			data.variables				= jo["variables"].ToObject<IGameVariable>();
			data.self_switches			= jo["self_switches"].ToObject<IGameSelfSwitches>();
			data.game_screen			= jo["game_screen"].ToObject<IGameScreen>();
			data.map_factory			= jo["map_factory"].ToObject<IMapFactory>();
			data.game_player			= jo["game_player"].ToObject<IGamePlayer>();
			data.global_metadata		= jo["global_metadata"].ToObject<IGlobalMetadata>();
			data.map_metadata			= jo["map_metadata"].ToObject<IMapMetadata>();
			data.bag					= jo["bag"].ToObject<IGameBag>();
			data.storage_system			= jo["storage_system"].ToObject<IGameStorage>();
			data.stats					= jo["stats"].ToObject<IGameStats>();
			data.essentials_version		= jo["essentials_version"].ToObject<string>();
			data.game_version			= jo["game_version"].ToObject<string>();

			//data = new GameState()
			//{
			//};

			return data;
		}

		protected bool FieldExists(string fieldName, JObject jObject)
		{
			return jObject[fieldName] != null;
		}

		protected static object ToObject(string json)
		{
			if (string.IsNullOrEmpty(json))
				return null;
			return ToObject(JToken.Parse(json));
		}

		protected static object ToObject(JToken token)
		{
			//switch (token.Type)
			//{
				//case JTokenType.Object:
				if (token.Type == JTokenType.Object)
					return token.Children<JProperty>()
								.ToDictionary(prop => prop.Name,
												prop => ToObject(prop.Value),
												StringComparer.OrdinalIgnoreCase);
				//case JTokenType.Array:
				//if (token.Type == JTokenType.Array)
				//	return token.Select(ToObject).ToList();
				//default:
					return ((JValue)token).Value;
			//}
		}

		//public override bool CanConvert(System.Type objectType)
		//{
		//	return typeof(ISaveDataObject) == objectType;
		//}

		/// <summary>Creates a new reader for the specified jObject by copying the settings
		/// from an existing reader.</summary>
		/// <param name="reader">The reader whose settings should be copied.</param>
		/// <param name="jToken">The jToken to create a new reader for.</param>
		/// <returns>The new disposable reader.</returns>
		public static JsonReader CopyReaderForObject(JsonReader reader, JToken jToken)
		{
			JsonReader jTokenReader = jToken.CreateReader();
			jTokenReader.Culture = reader.Culture;
			jTokenReader.DateFormatString = reader.DateFormatString;
			jTokenReader.DateParseHandling = reader.DateParseHandling;
			jTokenReader.DateTimeZoneHandling = reader.DateTimeZoneHandling;
			jTokenReader.FloatParseHandling = reader.FloatParseHandling;
			jTokenReader.MaxDepth = reader.MaxDepth;
			jTokenReader.SupportMultipleContent = reader.SupportMultipleContent;
			return jTokenReader;
		}
	}
	*/

		//public class SaveDataValue
		//{
		//	public string Id { get; private set; }
		//
		//	public SaveDataValue(string id)
		//	{
		//		Id = id;
		//	}
		//
		//	public object GetFromOldFormat(List<object> oldFormat)
		//	{
		//		// Placeholder logic for extracting data from old format.
		//		// This would depend on the structure of the old_format array.
		//		Debug.Log($"Getting data for '{Id}' from old format.");
		//		return null; // Return null or a default value
		//	}
		//}

		/// <summary>
		/// Implementation of save data result that can be either Dictionary or Array.
		/// </summary>
		//public class SaveDataResult : ISaveDataResult
		//{
		//	public bool IsDictionary { get; }
		//	public IDictionary<string, ISaveValue> DictionaryData { get; }
		//	public ISaveValue[] ArrayData { get; }
		//
		//	public SaveDataResult(IDictionary<string, ISaveValue> data)
		//	{
		//		IsDictionary = true;
		//		DictionaryData = data;
		//		ArrayData = null;
		//	}
		//
		//	public SaveDataResult(ISaveValue[] data)
		//	{
		//		IsDictionary = false;
		//		DictionaryData = null;
		//		ArrayData = data;
		//	}
		//}

		/// <summary>
		/// JSON converter for save data serialization.
		/// </summary>
		//public class SaveDataConverter : JsonConverter<ISaveData>, ISaveDataConverter
		//{
		//	public override void WriteJson(JsonWriter writer, ISaveData value, JsonSerializer serializer)
		//	{
		//		JToken t = JToken.FromObject(value);
		//
		//		if (t.Type != JTokenType.Object)
		//		{
		//			t.WriteTo(writer);
		//		}
		//		else
		//		{
		//			JObject o = (JObject)t;
		//			IList<string> propertyNames = o.Properties().Select(p => p.Name).ToList();
		//
		//			o.AddFirst(new JProperty("Keys", new JArray(propertyNames)));
		//			o.WriteTo(writer);
		//		}
		//	}
		//
		//	public override ISaveData ReadJson(JsonReader reader, Type objectType, ISaveData existingValue, bool hasExistingValue, JsonSerializer serializer)
		//	{
		//		JObject jo = JObject.Load(reader);
		//		// Implementation will be provided in the concrete SaveData class
		//		throw new NotImplementedException("ReadJson implementation required in concrete SaveData class");
		//	}
		//}

	/*[System.Serializable]
	public class GameState : ISaveDataObject
	{
		public Player player							{ get; protected set; }
		public Game_System game_system					{ get; protected set; }
		public PokemonSystem pokemon_system				{ get; protected set; }
		public Game_Switches switches					{ get; protected set; }
		public Game_Variables variables					{ get; protected set; }
		public Game_SelfSwitches self_switches			{ get; protected set; }
		public Game_Screen game_screen					{ get; protected set; }
		public PokemonMapFactory map_factory			{ get; protected set; }
		public Game_Player game_player					{ get; protected set; }
		public PokemonGlobalMetadata global_metadata	{ get; protected set; }
		public PokemonMapMetadata map_metadata			{ get; protected set; }
		public PokemonBag bag							{ get; protected set; }
		public PokemonStorage storage_system			{ get; protected set; }
		public GameStats stats							{ get; protected set; }
		public string essentials_version				{ get; set; }
		public string game_version						{ get; set; }

		public void save_value()
		{
			player				= Game.GameData.player;
			game_system			= Game.GameData.game_system;
			pokemon_system		= Game.GameData.PokemonSystem;
			switches			= Game.GameData.game_switches;
			variables			= Game.GameData.game_variables;
			self_switches		= Game.GameData.game_self_switches;
			game_screen			= Game.GameData.game_screen;
			map_factory			= Game.GameData.map_factory;
			game_player			= Game.GameData.game_player;
			global_metadata		= Game.GameData.PokemonGlobal;
			map_metadata		= Game.GameData.PokemonMap;
			bag					= Game.GameData.bag;
			storage_system		= Game.GameData.PokemonStorage;
			stats				= Game.GameData.Stats;
			essentials_version	= Essentials.VERSION;
			game_version		= Settings.GAME_VERSION;
		}

		public void load_value()
		{
			Game.GameData.player				= player;
			Game.GameData.game_system			= game_system;
			Game.GameData.PokemonSystem			= pokemon_system;
			Game.GameData.game_switches			= switches;
			Game.GameData.game_variables		= variables;
			Game.GameData.game_self_switches	= self_switches;
			Game.GameData.game_screen			= game_screen;
			Game.GameData.map_factory			= map_factory;
			Game.GameData.game_player			= game_player;
			Game.GameData.PokemonGlobal			= global_metadata;
			Game.GameData.PokemonMap			= map_metadata;
			Game.GameData.bag					= bag;
			Game.GameData.PokemonStorage		= storage_system;
			Game.GameData.Stats					= stats;
			Game.GameData.save_engine_version	= essentials_version;
			Game.GameData.save_game_version		= game_version;
		}

		public void new_game_value()
		{
			Game.GameData.player				= new Player("Unnamed", GameData.TrainerType.keys.first);
			Game.GameData.game_system			= new Game_System();
			Game.GameData.PokemonSystem			= new PokemonSystem();
			Game.GameData.game_switches			= new Game_Switches();
			Game.GameData.game_variables		= new Game_Variables();
			Game.GameData.game_self_switches	= new Game_SelfSwitches();
			Game.GameData.game_screen			= new Game_Screen();
			//Game.GameData.map_factory			= new map_factory;
			Game.GameData.game_player			= new Game_Player();
			Game.GameData.PokemonGlobal			= new PokemonGlobalMetadata();
			Game.GameData.PokemonMap			= new PokemonMapMetadata();
			Game.GameData.bag					= new PokemonBag();
			Game.GameData.PokemonStorage		= new PokemonStorage();
			Game.GameData.Stats					= new GameStats();
			Game.GameData.save_engine_version	= Essentials.VERSION;
			Game.GameData.save_game_version		= Settings.GAME_VERSION;
		}

		public void reset_on_new_game()
		{
			//Game.GameData.player				= new Player("Unnamed", GameData.TrainerType.keys.first);
			Game.GameData.game_system			= new Game_System();
			//Game.GameData.PokemonSystem			= new PokemonSystem();
			//Game.GameData.game_switches			= new Game_Switches();
			//Game.GameData.game_variables		= new Game_Variables();
			//Game.GameData.game_self_switches	= new Game_SelfSwitches();
			//Game.GameData.game_screen			= new Game_Screen();
			//Game.GameData.map_factory			= new map_factory;
			//Game.GameData.game_player			= new Game_Player();
			//Game.GameData.PokemonGlobal			= new PokemonGlobalMetadata();
			//Game.GameData.PokemonMap			= new PokemonMapMetadata();
			//Game.GameData.bag					= new PokemonBag();
			//Game.GameData.PokemonStorage		= new PokemonStorage();
			Game.GameData.Stats					= new GameStats();
			//Game.GameData.save_engine_version	= Essentials.VERSION;
			//Game.GameData.save_game_version		= Settings.GAME_VERSION;
		}

		public void load_in_bootup()
		{
			//Game.GameData.player				= player;
			Game.GameData.game_system			= game_system;
			Game.GameData.PokemonSystem			= pokemon_system;
			//Game.GameData.game_switches			= switches;
			//Game.GameData.game_variables		= variables;
			//Game.GameData.game_self_switches	= self_switches;
			//Game.GameData.game_screen			= game_screen;
			//Game.GameData.map_factory			= map_factory;
			//Game.GameData.game_player			= game_player;
			//Game.GameData.PokemonGlobal			= global_metadata;
			//Game.GameData.PokemonMap			= map_metadata;
			//Game.GameData.bag					= bag;
			//Game.GameData.PokemonStorage		= storage_system;
			Game.GameData.Stats					= stats;
			Game.GameData.save_engine_version	= essentials_version;
			Game.GameData.save_game_version		= game_version;
		}
	}*/
}