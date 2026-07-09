using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    public interface IMainPlayer : IMain
    {
        string GetPlayerCharset(object charset, ITrainer trainer = null, bool force = false);

        void UpdateVehicle();

        void CancelVehicles(ITilePosition destination = null, bool cancel_swimming = true);

        bool CanUseBike(int map_id);

        void MountBike();

        void DismountBike();
    }

    /// <summary>
    /// Represents the player character in the game, handling movement, interactions, and state management.
    /// </summary>
    public interface IGamePlayer : IGameCharacter, IHaveUpdate, IHaveRefresh
    {
        #region Constants
        /// <summary>
        /// The screen center X coordinate in subpixels.
        /// </summary>
        //const int SCREEN_CENTER_X = ((Settings.SCREEN_WIDTH / 2) - (Game_Map.TILE_WIDTH / 2)) * Game_Map.X_SUBPIXELS;
        int SCREEN_CENTER_X { get; }

        /// <summary>
        /// The screen center Y coordinate in subpixels.
        /// </summary>
        //const int SCREEN_CENTER_Y = ((Settings.SCREEN_HEIGHT / 2) - (Game_Map.TILE_HEIGHT / 2)) * Game_Map.Y_SUBPIXELS;
        int SCREEN_CENTER_Y { get; }

        /// <summary>
        /// Time in seconds for one cycle of bobbing (playing 4 charset frames) while surfing or diving.
        /// </summary>
        //const float SURF_BOB_DURATION = 1.5f;
        float SURF_BOB_DURATION { get; }
        #endregion

        #region Properties
        /// <summary>
        /// Gets or sets the character set data for the player.
        /// </summary>
        object charsetData { get; set; }
        //ICharacterSetData CharsetData { get; set; }

        /// <summary>
        /// Gets or sets the encounter count for the player.
        /// </summary>
        //int EncounterCount { get; set; }
        int encounter_count { get; set; }
        #endregion

        IGamePlayer initialize(ITempMetadata map = null);

        #region Methods
        /// <summary>
        /// Gets the map the player is on.
        /// </summary>
        /// <returns>The map the player is on.</returns>
        //IGameMap GetMap();
        IGameMap map { get; }

        /// <summary>
        /// Gets the ID of the map the player is on.
        /// </summary>
        /// <returns>The map ID.</returns>
        //int GetMapId();
        int map_id { get; }

        /// <summary>
        /// Gets the screen Z coordinate of the player.
        /// </summary>
        /// <param name="height">The height offset.</param>
        /// <returns>The screen Z coordinate.</returns>
        //int GetScreenZ(int height = 0);
        int screen_z(int height = 0);

        /// <summary>
        /// Checks if the player has any followers.
        /// </summary>
        /// <returns>True if the player has followers; otherwise, false.</returns>
        //bool HasFollower();
        bool has_follower { get; }

        /// <summary>
        /// Checks if the player can transfer maps with followers.
        /// </summary>
        /// <returns>True if the player can transfer maps with followers; otherwise, false.</returns>
        bool can_map_transfer_with_follower { get; }
        //bool CanMapTransferWithFollower();

        /// <summary>
        /// Checks if the player can ride a vehicle with followers.
        /// </summary>
        /// <returns>True if the player can ride a vehicle with followers; otherwise, false.</returns>
        bool can_ride_vehicle_with_follower { get; }
        //bool CanRideVehicleWithFollower();

        /// <summary>
        /// Checks if the player can run.
        /// </summary>
        /// <returns>True if the player can run; otherwise, false.</returns>
        bool can_run { get; }
        //bool CanRun();

        /// <summary>
        /// Sets the movement type of the player.
        /// </summary>
        /// <param name="type">The movement type to set.</param>
        void set_movement_type(int type);
        //void SetMovementType(int type);

        /// <summary>
        /// Refreshes the player's character set.
        /// </summary>
        /// <remarks>
        /// Called when the player's character or outfit changes. Assumes the player
        /// isn't moving.
        /// </remarks>
        void refresh_charset();
        //void RefreshCharset();

        /// <summary>
        /// Handles the player bumping into an object.
        /// </summary>
        void bump_into_object();
        //void BumpIntoObject();

        /// <summary>
        /// Adds move distance to the player's statistics.
        /// </summary>
        /// <param name="distance">The distance to add.</param>
        void add_move_distance_to_stats(int distance = 1);
        //void AddMoveDistanceToStats(int distance = 1);

        /// <summary>
        /// Moves the player in a generic direction.
        /// </summary>
        /// <param name="direction">The direction to move.</param>
        /// <param name="turnEnabled">Whether to enable turning.</param>
        void move_generic(int direction, bool turnEnabled = true);
        //void MoveGeneric(int direction, bool turnEnabled = true);

        /// <summary>
        /// Turns the player in a generic direction.
        /// </summary>
        /// <param name="direction">The direction to turn.</param>
        /// <param name="keepEncounterIndicator">Whether to keep the encounter indicator.</param>
        void turn_generic(int direction, bool keepEncounterIndicator = false);
        //void TurnGeneric(int direction, bool keepEncounterIndicator = false);

        /// <summary>
        /// Makes the player jump.
        /// </summary>
        /// <param name="xPlus">The X offset for the jump.</param>
        /// <param name="yPlus">The Y offset for the jump.</param>
        void jump(int xPlus, int yPlus);
        //void Jump(int xPlus, int yPlus);

        /// <summary>
        /// Gets the terrain tag at the player's position.
        /// </summary>
        /// <param name="countBridge">Whether to count bridge tiles.</param>
        /// <returns>The terrain tag.</returns>
        int GetTerrainTag(bool countBridge = false);

        /// <summary>
        /// Gets the event the player is facing.
        /// </summary>
        /// <param name="ignoreInterpreter">Whether to ignore the interpreter.</param>
        /// <returns>The event the player is facing.</returns>
        IGameEvent GetFacingEvent(bool ignoreInterpreter = false);

        /// <summary>
        /// Gets the terrain tag the player is facing.
        /// </summary>
        /// <param name="direction">The direction to check.</param>
        /// <returns>The terrain tag.</returns>
        int GetFacingTerrainTag(int? direction = null);

        /// <summary>
        /// Checks if the character can pass through the specified coordinates in the given direction.
        /// </summary>
        /// <param name="x">The x-coordinate to check.</param>
        /// <param name="y">The y-coordinate to check.</param>
        /// <param name="dir">The direction to check (0, 2, 4, 6, 8); 0 = Determines if all directions are impassable (for jumping).</param>
        /// <param name="strict">Whether to perform a strict check.</param>
        /// <returns>True if the character can pass through; otherwise, false.</returns>
        bool passable(int x, int y, int dir, bool strict = false);

        /// <summary>
        /// Centers the player on the screen.
        /// </summary>
        /// <remarks>
        /// Set Map Display Position to Center of Screen
        /// </remarks>
        /// <param name="x">The X coordinate to center on.</param>
        /// <param name="y">The Y coordinate to center on.</param>
        void center(int x, int y);
        //void Center(int x, int y);

        /// <summary>
        /// Moves the player to the specified coordinates.
        /// </summary>
        /// <param name="x">The X coordinate to move to.</param>
        /// <param name="y">The Y coordinate to move to.</param>
        void moveto(int x, int y);
        //void MoveTo(int x, int y);

        /// <summary>
        /// Makes the encounter count for the player.
        /// </summary>
        void make_encounter_count();
        //void MakeEncounterCount();

        /// <summary>
        /// Refreshes the player's state.
        /// </summary>
        void refresh();
        //void Refresh();

        /// <summary>
        /// Gets triggered trainer events.
        /// </summary>
        /// <param name="triggers">The triggers to check.</param>
        /// <param name="checkIfRunning">Whether to check if running.</param>
        /// <param name="trainerOnly">Whether to only check trainer events.</param>
        /// <returns>A list of triggered trainer events.</returns>
        IList<IGameEvent> GetTriggeredTrainerEvents(int[] triggers, bool checkIfRunning = true, bool trainerOnly = false);

        /// <summary>
        /// Gets triggered counter events.
        /// </summary>
        /// <param name="triggers">The triggers to check.</param>
        /// <param name="checkIfRunning">Whether to check if running.</param>
        /// <returns>A list of triggered counter events.</returns>
        IList<IGameEvent> GetTriggeredCounterEvents(int[] triggers, bool checkIfRunning = true);

        /// <summary>
        /// Checks for event triggers from a distance.
        /// </summary>
        /// <param name="triggers">The triggers to check.</param>
        void CheckEventTriggerFromDistance(int[] triggers);

        /// <summary>
        /// Checks for event triggers at the player's position.
        /// </summary>
        /// <remarks>
        /// Trigger event(s) at the same coordinates as self with the appropriate
        /// trigger(s) that can be triggered
        /// </remarks>
        /// <param name="triggers">The triggers to check.</param>
        /// <returns>True if an event was triggered; otherwise, false.</returns>
        bool check_event_trigger_here(int[] triggers);
        //bool CheckEventTriggerHere(int[] triggers);

        /// <summary>
        /// Checks for event triggers in front of the player.
        /// </summary>
        /// <param name="triggers">The triggers to check.</param>
        /// <returns>True if an event was triggered; otherwise, false.</returns>
        bool check_event_trigger_there(int[] triggers);
        //bool CheckEventTriggerThere(int[] triggers);

        /// <summary>
        /// Checks for event triggers on touch.
        /// </summary>
        /// <param name="direction">The direction of the touch.</param>
        /// <returns>True if an event was triggered; otherwise, false.</returns>
        bool check_event_trigger_touch(int direction);
        //bool CheckEventTriggerTouch(int direction);

        /// <summary>
        /// Updates the player's state.
        /// </summary>
        void update();
        //void Update();

        /// <summary>
        /// Updates the player's new command.
        /// </summary>
        void update_command_new();
        //void UpdateCommandNew();

        /// <summary>
        /// Updates the player's movement.
        /// </summary>
        void update_move();
        //void UpdateMove();

        /// <summary>
        /// Updates the player's stop state.
        /// </summary>
        void update_stop();
        //void UpdateStop();

        /// <summary>
        /// Updates the player's pattern.
        /// </summary>
        void update_pattern();
        //void UpdatePattern();

        /// <summary>
        /// Updates the player's screen position.
        /// </summary>
        /// <remarks>
        /// Track the player on-screen as they move.
        /// </remarks>
        /// <param name="lastRealX">The last real X coordinate.</param>
        /// <param name="lastRealY">The last real Y coordinate.</param>
        void update_screen_position(float lastRealX, float lastRealY);
        //void UpdateScreenPosition(float lastRealX, float lastRealY);

        /// <summary>
        /// Updates event triggering for the player.
        /// </summary>
        void update_event_triggering();
        //void UpdateEventTriggering();
        #endregion
    }
}