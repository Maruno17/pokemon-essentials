using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Data saved in <see cref="IGlobalMetadataFollower.followers"/>.
	/// </summary>
	/// <seealso cref="Application.Game.PokemonGlobal"/>
	/// <seealso cref="Application.Game.GameData"/>
	// Data saved in Game.GameData.PokemonGlobal.followers.
	public interface IFollowerData {
		/// <summary>
		/// Gets or sets the original map ID where the follower was created.
		/// </summary>
		int original_map_id { get; set; }

		/// <summary>
		/// Gets or sets the event ID of the follower.
		/// </summary>
		int event_id { get; set; }

		/// <summary>
		/// Gets or sets the name of the follower's event.
		/// </summary>
		string event_name { get; set; }

		/// <summary>
		/// Gets or sets the current map ID where the follower is located.
		/// </summary>
		int current_map_id { get; set; }

		/// <summary>
		/// Gets or sets the X coordinate of the follower.
		/// </summary>
		float x { get; set; }

		/// <summary>
		/// Gets or sets the Y coordinate of the follower.
		/// </summary>
		float y { get; set; }

		/// <summary>
		/// Gets or sets the direction the follower is facing.
		/// </summary>
		int direction { get; set; }

		/// <summary>
		/// Gets or sets the character name of the follower.
		/// </summary>
		string character_name { get; set; }

		/// <summary>
		/// Gets or sets the character hue of the follower.
		/// </summary>
		int character_hue { get; set; }

		/// <summary>
		/// Gets or sets the name of the follower.
		/// </summary>
		string name { get; set; }

		/// <summary>
		/// Gets or sets the common event ID associated with the follower.
		/// </summary>
		int? common_event_id { get; set; }

		/// <summary>
		/// Gets or sets whether the follower is visible.
		/// </summary>
		bool visible { get; set; }

		/// <summary>
		/// Gets or sets whether the follower should be invisible after transfer.
		/// </summary>
		bool invisible_after_transfer { get; set; }


		//void initialize(int original_map_id, int event_id, string event_name, int current_map_id, float x, float y,
		IFollowerData initialize(int original_map_id, int event_id, string event_name, int current_map_id, float x, float y,
				int direction, string character_name, int character_hue);

		/// <summary>
		/// Checks if the follower is currently visible.
		/// </summary>
		/// <returns>True if the follower is visible; otherwise, false.</returns>
		bool IsVisible();

		/// <summary>
		/// Interacts with an event.
		/// </summary>
		/// <param name="event">The event to interact with.</param>
		void interact(IGameEvent @event);
	}

	/// <summary>
	/// Permanently stores data of follower events (i.e. in save files).
	/// </summary>
	public interface IGlobalMetadataFollower : IGlobalMetadata {
		IList<IFollowerData> followers		{ get; }

		//public void followers() {
		//	if (!@followers) @followers = new List<string>();
		//	return @followers;
		//}
	}

	/// <summary>
	/// Stores Game_Follower instances just for the current play session.
	/// </summary>
	public interface ITempMetadataFollower : ITempMetadata {
		IGameFollowerFactory followers		{ get; }

		//public void followers() {
		//	if (_followers == null) _followers = new Game_FollowerFactory();
		//	return @followers;
		//}
	}

	/// <summary>
	/// Factory class for creating and managing follower characters.
	/// </summary>
	public interface IGameFollowerFactory : IHaveUpdate {
		#region Properties
		/// <summary>
		/// Gets the last update timestamp.
		/// </summary>
		int last_update { get; }
		#endregion

		#region Methods
		IGameFollowerFactory initialize();

		/// <summary>
		/// Adds a new follower.
		/// </summary>
		/// <param name="event">The event to create a follower from.</param>
		/// <param name="name">The name of the follower.</param>
		/// <param name="commonEventId">The common event ID associated with the follower.</param>
		void add_follower(IGameEvent @event, string name = null, int? commonEventId = null);

		/// <summary>
		/// Removes a follower by its associated event.
		/// </summary>
		/// <param name="event">The event associated with the follower to remove.</param>
		void remove_follower_by_event(IGameEvent @event);

		/// <summary>
		/// Removes a follower by its name.
		/// </summary>
		/// <param name="name">The name of the follower to remove.</param>
		void remove_follower_by_name(string name);

		/// <summary>
		/// Removes all followers.
		/// </summary>
		void remove_all_followers();

		/// <summary>
		/// Gets a follower by its index.
		/// </summary>
		/// <param name="index">The index of the follower to get.</param>
		/// <returns>The follower at the specified index, or null if not found.</returns>
		IGameFollower get_follower_by_index(int index = 0);

		/// <summary>
		/// Gets a follower by its name.
		/// </summary>
		/// <param name="name">The name of the follower to get.</param>
		/// <returns>The follower with the specified name, or null if not found.</returns>
		IGameFollower get_follower_by_name(string name);

		/// <summary>
		/// Iterates through all followers.
		/// </summary>
		/// <param name="action">The action to perform on each follower and its data.</param>
		//void each_follower(Action<IDictionary<IGameFollower, IFollowerData>> action);
		void each_follower(Action<IGameFollower, IFollowerData> action);

		/// <summary>
		/// Makes all followers turn towards their leaders.
		/// </summary>
		void turn_followers();

		/// <summary>
		/// Makes all followers move to follow their leaders.
		/// </summary>
		void move_followers();

		/// <summary>
		/// Transfers all followers to the current map.
		/// </summary>
		void map_transfer_followers();

		/// <summary>
		/// Makes followers follow the player into a door.
		/// </summary>
		void follow_into_door();

		/// <summary>
		/// Hides all followers.
		/// </summary>
		/// <remarks>
		/// Used when coming out of a door.
		/// </remarks>
		void hide_followers();

		/// <summary>
		/// Places all followers on the player's position.
		/// </summary>
		/// <remarks>
		/// Used when coming out of a door. Makes all followers invisible until the
		/// player starts moving.
		/// </remarks>
		void put_followers_on_player();

		/// <summary>
		/// Updates the state of all followers.
		/// </summary>
		void update();
		#endregion
	}

	//===============================================================================
	//
	//===============================================================================
	public interface IFollowerSprites : IHaveUpdate, IHaveRefresh, IDisposable {
		//FollowerSprites(IViewport viewport) { initialize(viewport);  }
		void initialize(IViewport viewport);

		//void dispose();

		//bool disposed();

		//void refresh();

		//void update();
	}

	/// <summary>
	/// Helper module for adding/removing/getting followers.
	/// </summary>
	public interface IFollowers {
		#region Class Functions
		/// <summary>
		/// </summary>
		/// <param name="event_id">ID of the event on the current map to be added as a follower</param>
		/// <param name="name">identifier name of the follower to be added</param>
		/// <param name="common_event_id">ID of the Common Event triggered when interacting with this follower</param>
		void add(int event_id, string name, int common_event_id);

		/// <summary>
		/// </summary>
		/// <param name="event">map event to be added as a follower</param>
		void add_event(IGameEvent _event);

		/// <summary>
		/// </summary>
		/// <param name="name">identifier name of the follower to be removed</param>
		void remove(string name);

		/// <summary>
		/// </summary>
		/// <param name="event">map event to be removed as a follower</param>
		void remove_event(IGameEvent _event);

		/// <summary>
		/// Removes all followers.
		/// </summary>
		void Clear();

		/// <summary>
		/// </summary>
		/// <param name="name">name of the follower to get, or null for the first follower | String, null</param>
		/// <returns>follower object</returns>
		//IGameFollower get(string name = null);

		/// <summary>
		/// </summary>
		void follow_into_door();

		void hide_followers();

		void put_followers_on_player();
		#endregion
	}
}