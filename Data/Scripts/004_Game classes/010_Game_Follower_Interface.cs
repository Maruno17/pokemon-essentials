using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a follower character that follows the player in the game.
	/// </summary>
	/// <remarks>
	/// Instances of this are stored in <see cref="realEvents"/>.
	/// </remarks>
	public interface IGameFollower : IGameEvent {
		#region Properties
		/// <summary>
		/// Gets or sets the map the follower is on.
		/// </summary>
		IGameMap Map { get; set; }
		#endregion

		#region Methods
		//Game_Follower(FollowerData event_data) { initialize(event_data); }
		IGameFollower initialize(IFollowerData event_data);

		/// <summary>
		/// Gets the map ID the follower is on.
		/// </summary>
		/// <returns>The map ID.</returns>
		int GetMapId();

		/// <summary>
		/// Moves the follower through a tile in the specified direction.
		/// </summary>
		/// <param name="direction">The direction to move.</param>
		void move_through(int direction);

		/// <summary>
		/// Moves the follower in a fancy way, considering passability and player position.
		/// </summary>
		/// <param name="direction">The direction to move.</param>
		void move_fancy(int direction);

		/// <summary>
		/// Makes the follower jump in a fancy way, considering passability and leader position.
		/// </summary>
		/// <param name="direction">The direction to jump.</param>
		/// <param name="leader">The leader character to follow.</param>
		void jump_fancy(int direction, IGameCharacter leader);

		/// <summary>
		/// Moves the follower to a new position in a fancy way.
		/// </summary>
		/// <param name="newX">The new X coordinate.</param>
		/// <param name="newY">The new Y coordinate.</param>
		/// <param name="leader">The leader character to follow.</param>
		void fancy_moveto(float newX, float newY, IGameCharacter leader);

		/// <summary>
		/// Ends all movement immediately.
		/// </summary>
		/// <remarks>
		/// Ceases all movement immediately. Used when the leader wants to move another
		/// tile but this hasn't quite finished its previous movement yet.
		/// </remarks>
		void end_movement();

		/// <summary>
		/// Makes the follower turn towards the leader.
		/// </summary>
		/// <param name="leader">The leader character to turn towards.</param>
		void turn_towards_leader(IGameCharacter leader);

		/// <summary>
		/// Makes the follower follow the leader.
		/// </summary>
		/// <param name="leader">The leader character to follow.</param>
		/// <param name="instant">Whether to move instantly.</param>
		/// <param name="leaderIsTrueLeader">Whether the leader is the true leader.</param>
		void follow_leader(IGameCharacter leader, bool instant = false, bool leaderIsTrueLeader = true);

		/// <summary>
		/// Checks if a location is passable for the follower.
		/// </summary>
		/// <param name="x">The X coordinate to check.</param>
		/// <param name="y">The Y coordinate to check.</param>
		/// <param name="direction">The direction to check.</param>
		/// <returns>True if the location is passable; otherwise, false.</returns>
		bool location_passable(int x, int y, int direction);
		//bool IsLocationPassable(int x, int y, int direction);
		#endregion
	}
}