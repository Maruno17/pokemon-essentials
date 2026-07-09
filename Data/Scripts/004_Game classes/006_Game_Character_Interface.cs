using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using PokemonEssentials.RPGMaker.Kernel;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a character in the game, including the player, events, and followers.
	/// Handles movement, animation, and interaction with the game map.
	/// </summary>
	public interface IGameCharacter : IHaveUpdate {
		#region Properties
		/// <summary>
		/// Gets the unique identifier of the character.
		/// </summary>
		int id { get; }

		/// <summary>
		/// Gets the map the character is on.
		/// </summary>
		//IGameMap map { get; }

		/// <summary>
		/// Gets the original x-coordinate of the character.
		/// </summary>
		int original_x { get; }

		/// <summary>
		/// Gets the original y-coordinate of the character.
		/// </summary>
		int original_y { get; }

		/// <summary>
		/// Gets the current x-coordinate of the character.
		/// </summary>
		int x { get; }

		/// <summary>
		/// Gets the current y-coordinate of the character.
		/// </summary>
		int y { get; }

		/// <summary>
		/// Gets the real x-coordinate of the character (including subpixel movement).
		/// </summary>
		float real_x { get; }

		/// <summary>
		/// Gets the real y-coordinate of the character (including subpixel movement).
		/// </summary>
		float real_y { get; }

		/// <summary>
		/// Gets or sets the x-offset of the character's sprite in pixels.
		/// Positive values shift the sprite to the right.
		/// </summary>
		int x_offset { get; set; }

		/// <summary>
		/// Gets or sets the y-offset of the character's sprite in pixels.
		/// Positive values shift the sprite down.
		/// </summary>
		int y_offset { get; set; }

		/// <summary>
		/// Gets or sets the width of the character in tiles.
		/// </summary>
		int width { get; set; }

		/// <summary>
		/// Gets or sets the height of the character in tiles.
		/// </summary>
		int height { get; set; }

		/// <summary>
		/// Gets or sets the size of the character's sprite.
		/// </summary>
		int[] sprite_size { get; set; }

		/// <summary>
		/// Gets the tile ID of the character.
		/// </summary>
		int tile_id { get; }

		/// <summary>
		/// Gets or sets the name of the character's sprite.
		/// </summary>
		string character_name { get; set; }

		/// <summary>
		/// Gets or sets the hue of the character's sprite.
		/// </summary>
		int character_hue { get; set; }

		/// <summary>
		/// Gets or sets the opacity of the character's sprite.
		/// </summary>
		int opacity { get; set; }

		/// <summary>
		/// Gets the blend type of the character's sprite.
		/// </summary>
		int blend_type { get; }

		/// <summary>
		/// Gets or sets the direction the character is facing.
		/// </summary>
		int direction { get; set; }

		/// <summary>
		/// Gets or sets the pattern of the character's sprite.
		/// </summary>
		int pattern { get; set; }

		/// <summary>
		/// Gets or sets the surface pattern of the character's sprite.
		/// </summary>
		int pattern_surf { get; set; }

		/// <summary>
		/// Gets or sets whether the character's pattern is locked.
		/// </summary>
		bool lock_pattern { get; set; }

		/// <summary>
		/// Gets whether the character's move route is being forced.
		/// </summary>
		bool move_route_forcing { get; }

		/// <summary>
		/// Gets or sets whether the character can pass through other characters.
		/// </summary>
		bool through { get; set; }

		/// <summary>
		/// Gets or sets the ID of the animation being played.
		/// </summary>
		int animation_id { get; set; }

		/// <summary>
		/// Gets or sets the height of the animation.
		/// </summary>
		int animation_height { get; set; }

		/// <summary>
		/// Gets or sets whether the animation uses regular tone.
		/// </summary>
		bool animation_regular_tone { get; set; }

		/// <summary>
		/// Gets or sets whether the character is transparent.
		/// </summary>
		bool transparent { get; set; }
		int original_direction { get; }
		int original_pattern { get; }
		int move_type { get; }
		/// <summary>
		/// Gets or sets the move speed of the character.
		/// </summary>
		int move_speed { get; set; }

		/// <summary>
		/// Gets or sets the move frequency of the character.
		/// </summary>
		int move_frequency { get; set; }

		/// <summary>
		/// Gets the jump speed of the character.
		/// </summary>
		/// <value>
		/// Takes the same values as <see cref="move_speed"/>.
		/// </value>
		int jump_speed { get; set; }
		PokemonEssentials.RPGMaker.IMoveRoute move_route { get; }
		int move_route_index { get; }
		PokemonEssentials.RPGMaker.IMoveRoute original_move_route { get; }
		int original_move_route_index { get; }

		/// <summary>
		/// Gets or sets whether the character animates while walking.
		/// </summary>
		bool walk_anime { get; set; }
		bool step_anime { get; set; }
		bool direction_fix { get; set; }
		bool always_on_top { get; set; }
		int anime_count { get; }
		int stop_count { get; }
		bool bumping { get; set; }
		int jump_peak { get; }
		int jump_distance { get; }
		float jump_fraction { get; }
		bool jumping_on_spot { get; }
		/// <summary>
		/// Gets or sets the height of the character's bobbing animation.
		/// </summary>
		int bob_height { get; }
		int wait_count { get; }
		int? wait_start { get; }
		bool moved_this_frame { get; }
		bool moveto_happened { get; }
		bool locked { get; }
		int prelock_direction { get; }
		#endregion

		IGameCharacter initialize(ITempMetadata map = null);

		#region Methods
		/// <summary>
		/// Checks if the character is at the specified coordinates.
		/// </summary>
		/// <param name="checkX">The x-coordinate to check.</param>
		/// <param name="checkY">The y-coordinate to check.</param>
		/// <returns>True if the character is at the specified coordinates; otherwise, false.</returns>
		bool at_coordinate(int checkX, int checkY);

		/// <summary>
		/// Checks if the character is in line with the specified coordinates.
		/// </summary>
		/// <param name="checkX">The x-coordinate to check.</param>
		/// <param name="checkY">The y-coordinate to check.</param>
		/// <returns>True if the character is in line with the specified coordinates; otherwise, false.</returns>
		bool in_line_with_coordinate(int checkX, int checkY);

		/// <summary>
		/// Iterates through each tile occupied by the character.
		/// </summary>
		/// <param name="action">The action to perform for each tile.</param>
		//IEnumerable<KeyValuePair<int, int>> each_occupied_tile();
		void each_occupied_tile(Action<int, int> action);

		/// <summary>
		/// Sets the move speed of the character.
		/// </summary>
		/// <param name="value">The new move speed value.</param>
		//void SetMoveSpeed(int value);

		/// <summary>
		/// Sets the jump speed of the character.
		/// </summary>
		/// <param name="value">The new jump speed value.</param>
		//void SetJumpSpeed(int value);

		/// <summary>
		/// Gets the pattern update speed of the character.
		/// </summary>
		/// <remarks>
		/// Returns time in seconds for one full cycle (4 frames) of an animating
		/// charset to show. Two frames are shown per movement across one tile.
		/// </remarks>
		/// <returns>The pattern update speed in seconds.</returns>
		//float GetPatternUpdateSpeed();
		float pattern_update_speed();

		/// <summary>
		/// Sets the move frequency of the character.
		/// </summary>
		/// <param name="value">The new move frequency value.</param>
		//void SetMoveFrequency(int value);

		/// <summary>
		/// Locks the character's movement.
		/// </summary>
		void Lock();

		/// <summary>
		/// Performs a mini-lock on the character.
		/// </summary>
		void minilock();

		/// <summary>
		/// Checks if the character is locked.
		/// </summary>
		/// <returns>True if the character is locked; otherwise, false.</returns>
		bool IsLocked();
		//bool lock();

		/// <summary>
		/// Unlocks the character's movement.
		/// </summary>
		void unlock();

		#region Information from map data
		/// <summary>
		/// Gets the map the character is on.
		/// </summary>
		/// <returns>The map the character is on.</returns>
		//IGameMap GetMap();
		//IGameMap map();
		IGameMap map { get; }

		/// <summary>
		/// Gets the terrain tag at the character's position.
		/// </summary>
		/// <returns>The terrain tag at the character's position.</returns>
		//int GetTerrainTag();
		int terrain_tag { get; }

		/// <summary>
		/// Gets the bush depth at the character's position.
		/// </summary>
		/// <returns>The bush depth at the character's position.</returns>
		//int GetBushDepth();
		int bush_depth { get; }

		/// <summary>
		/// Calculates the bush depth at the character's position.
		/// </summary>
		void calculate_bush_depth();

		/// <summary>
		/// Gets the full pattern of the character's sprite.
		/// </summary>
		/// <returns>The full pattern of the character's sprite.</returns>
		//int GetFullPattern();
		int fullPattern();
		#endregion

		#region Passability
		/// <summary>
		/// Checks if the character can pass through the specified coordinates in the given direction.
		/// </summary>
		/// <param name="x">The x-coordinate to check.</param>
		/// <param name="y">The y-coordinate to check.</param>
		/// <param name="dir">The direction to check.</param>
		/// <param name="strict">Whether to perform a strict check.</param>
		/// <returns>True if the character can pass through; otherwise, false.</returns>
		//bool IsPassable(int x, int y, int dir, bool strict = false);
		bool passable(int x, int y, int dir, bool strict = false);

		/// <summary>
		/// Checks if the character can move from the specified coordinates in the given direction.
		/// </summary>
		/// <param name="startX">The starting x-coordinate.</param>
		/// <param name="startY">The starting y-coordinate.</param>
		/// <param name="dir">The direction to check.</param>
		/// <param name="strict">Whether to perform a strict check.</param>
		/// <returns>True if the character can move; otherwise, false.</returns>
		bool can_move_from_coordinate(int startX, int startY, int dir, bool strict = false);

		/// <summary>
		/// Checks if the character can move in the given direction.
		/// </summary>
		/// <param name="dir">The direction to check.</param>
		/// <param name="strict">Whether to perform a strict check.</param>
		/// <returns>True if the character can move; otherwise, false.</returns>
		bool can_move_in_direction(int dir, bool strict = false);
		#endregion

		#region  Screen position of the character
		/// <summary>
		/// Gets the screen x-coordinate of the character.
		/// </summary>
		/// <returns>The screen x-coordinate of the character.</returns>
		//int GetScreenX();
		float screen_x();

		/// <summary>
		/// Gets the ground screen y-coordinate of the character.
		/// </summary>
		/// <returns>The ground screen y-coordinate of the character.</returns>
		//int GetScreenYGround();
		float screen_y_ground();

		/// <summary>
		/// Gets the screen y-coordinate of the character.
		/// </summary>
		/// <returns>The screen y-coordinate of the character.</returns>
		//int GetScreenY();
		int screen_y();

		/// <summary>
		/// Gets the screen z-coordinate of the character.
		/// </summary>
		/// <param name="height">The height offset.</param>
		/// <returns>The screen z-coordinate of the character.</returns>
		//int GetScreenZ(int height = 0);
		int screen_z(int height = 0);
		#endregion

		#region  Movement
		/// <summary>
		/// Checks if the character is moving.
		/// </summary>
		/// <returns>True if the character is moving; otherwise, false.</returns>
		//bool IsMoving();
		bool moving();

		/// <summary>
		/// Checks if the character is jumping.
		/// </summary>
		/// <returns>True if the character is jumping; otherwise, false.</returns>
		//bool IsJumping();
		bool jumping();

		/// <summary>
		/// Straightens the character's pattern.
		/// </summary>
		void straighten();

		/// <summary>
		/// Forces the character to follow a move route.
		/// </summary>
		/// <param name="moveRoute">The move route to follow.</param>
		void force_move_route(PokemonEssentials.RPGMaker.IMoveRoute moveRoute);

		/// <summary>
		/// Moves the character to the specified coordinates.
		/// </summary>
		/// <param name="x">The x-coordinate to move to.</param>
		/// <param name="y">The y-coordinate to move to.</param>
		void moveto(int x, int y);

		/// <summary>
		/// Triggers the leave tile event.
		/// </summary>
		void triggerLeaveTile();

		/// <summary>
		/// Increases the character's step count.
		/// </summary>
		void increase_steps();
		#endregion

		#region Movement commands
		void move_type_random();

		void move_type_toward_player();

		void move_type_custom();

		void move_generic(int dir, bool turn_enabled = true);

		void move_down(bool turn_enabled = true);

		void move_left(bool turn_enabled = true);

		void move_right(bool turn_enabled = true);

		void move_up(bool turn_enabled = true);

		void move_upper_left();

		void move_upper_right();

		void move_lower_left();

		void move_lower_right();

		// Anticlockwise.
		void moveLeft90();

		// Clockwise.
		void moveRight90();

		void move_random();

		void move_random_range(int xrange = -1, int yrange = -1);

		void move_random_UD(int range = -1);

		void move_random_LR(int range = -1);

		void move_toward_player();

		void move_away_from_player();

		void move_forward();

		void move_backward();

		void jump(float x_plus, float y_plus);

		bool jumpForward(int distance = 1);

		bool jumpBackward(int distance = 1);

		void turn_generic(int dir);

		void turn_down  ();
		void turn_left  ();
		void turn_right ();
		void turn_up    ();

		void turn_right_90();

		void turn_left_90();

		void turn_180();

		void turn_right_or_left_90();

		void turn_random();

		void turn_toward_player();

		void turn_away_from_player();
		#endregion

		#region Updating
		/// <summary>
		/// Updates the character's state.
		/// </summary>
		void update();

		/// <summary>
		/// Updates the character's command.
		/// </summary>
		void update_command();

		/// <summary>
		/// Updates the character's new command.
		/// </summary>
		void update_command_new();

		/// <summary>
		/// Updates the character's movement.
		/// </summary>
		void update_move();

		/// <summary>
		/// Updates the character's stop state.
		/// </summary>
		void update_stop();

		/// <summary>
		/// Updates the character's pattern.
		/// </summary>
		void update_pattern();
		#endregion
		#endregion
	}
}