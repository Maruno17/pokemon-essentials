using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Constant checks.
    /// </summary>
    /// <remarks>
    /// Core overworld functionality interface mapping overworld system.
    /// Contains event handlers, step tracking, battles, and map management functions.
    /// </remarks>
    public interface IMainOverworld : IMain
    {
        /// <summary>
        /// Pokérus check
        /// </summary>
        /// <remarks>
        /// Handles Pokérus progression checks each frame, decrements Pokérus counter when day changes.
        /// Updates infected Pokémon to ensure proper Pokérus stage transitions.
        /// </remarks>
        /// <example>
        /// <code>
        /// EventHandlers.add(:on_frame_update, :pokerus_counter,
        ///   proc {
        ///     next if !$player || $player.party.none? { |pkmn| pkmn.pokerusStage == 1 }
        ///     last = $PokemonGlobal.pokerusTime
        ///     next if !last
        ///     now = pbGetTimeNow
        ///     if last.year != now.year || last.month != now.month || last.day != now.day
        ///       $player.pokemon_party.each { |pkmn| pkmn.lowerPokerusCount }
        ///       $PokemonGlobal.pokerusTime = now
        ///     end
        ///   }
        /// )
        /// </code>
        /// </example>
        /// <seealso cref="IEvents.OnFrameUpdate"/>
        //void on_frame_update_pokerus_counter();
        void OnFrameUpdateTrigger_pokerus_counter();

        /// <summary>
        /// Returns whether the Poké Center should explain Pokérus to the player, if a
        /// healed Pokémon has it.
        /// </summary>
        /// <remarks>
        /// Checks if any party Pokémon have active Pokérus and the player hasn't been informed yet.
        /// Used by Pokémon Centers to determine if Pokérus explanation should be shown.
        /// </remarks>
        /// <returns>True if Pokérus explanation should be displayed to player</returns>
        bool Pokerus();

        /// <summary>
        /// Determines if device battery is critically low based on percentage and time remaining.
        /// Considers both power percentage (≤15%) and time remaining (≤10 minutes).
        /// </summary>
        /// <returns>True if battery is critically low and requires user attention</returns>
        bool BatteryLow();

        /// <summary>
        /// Displays low battery warning message to prevent save data loss when power is critical.
        /// Only shows warning once per session until battery level improves.
        /// </summary>
        /// <seealso cref="IEvents.OnFrameUpdate"/>
        //void on_frame_update_low_battery_warning();
        void on_frame_updateTrigger_low_battery_warning();

        /// <summary>
        /// Processes delayed BGM playback after fade transitions to prevent audio conflicts.
        /// Plays queued background music when delay timer expires.
        /// </summary>
        /// <seealso cref="IEvents.OnFrameUpdate"/>
        //void on_frame_update_cue_bgm_after_delay();
        void on_frame_updateTrigger_cue_bgm_after_delay();

        /// <summary>
        /// Increments happiness for party Pokémon at regular walking intervals.
        /// Uses randomization and step counter to vary happiness gain timing naturally.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnPlayerStepTaken"/>
        //void on_player_step_taken_gain_happiness();
        void on_player_stepTrigger_taken_gain_happiness();

        /// <summary>
        /// Applies poison damage to affected party Pokémon while walking in the field.
        /// Includes visual/audio feedback and handles fainting based on game settings.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnPlayerStepTaken"/>
        /// <param name="handled">Transfer handling flag to prevent conflicting map transitions</param>
        void on_player_stepTrigger_taken_can_transfer_poison_party(bool? handled);

        /// <summary>
        /// Handles party wipeout scenario when all Pokémon faint, initiates blackout sequence.
        /// Shows appropriate messages and starts game over procedures.
        /// </summary>
        void CheckAllFainted();

        /// <summary>
        /// Collects volcanic soot when stepping on soot grass terrain with Soot Sack item.
        /// Removes soot grass tiles after collection and updates soot inventory.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <param name="event">The map event that stepped on soot grass</param>
        void on_step_takenTrigger_pick_up_soot(IGameEvent @event);

        /// <summary>
        /// Shows grass rustling animation when stepping on tall grass terrain.
        /// Respects airborne event naming conventions to skip animation appropriately.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <param name="event">The map event that stepped on grass</param>
        void on_step_takenTrigger_grass_rustling(IGameEvent @event);

        /// <summary>
        /// Displays water ripple effects when stepping on still water surfaces.
        /// Creates visual feedback for water interaction while respecting airborne events.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <param name="event">The map event that stepped on water</param>
        void on_step_takenTrigger_still_water_ripple(IGameEvent @event);

        /// <summary>
        /// Handles automatic player movement including ice sliding and waterfall traversal.
        /// Processes special terrain movement mechanics and directional constraints.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <param name="event">The player event requiring automatic movement</param>
        void on_step_takenTrigger_auto_move_player(IGameEvent @event);

        /// <summary>
        /// Tracks walking distance for Pokémon with distance-based evolution requirements.
        /// Currently handles Pawmo, Bramblin, and Rellor evolution distance tracking.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnStepTakenFieldMovement"/>
        /// <seealso cref="EventArg.IOnStepTakenFieldMovementEventArgs"/>
        /// <param name="event">The map event that stepped to trigger distance tracking</param>
        void on_step_takenTrigger_party_pokemon_distance_tracker(IGameEvent @event);

        /// <summary>
        /// Main step processing coordinator that handles all step-based overworld events.
        /// Manages wild encounters, terrain effects, and step-triggered mechanics.
        /// </summary>
        /// <param name="eventTriggered">Whether the step was triggered by an event rather than player input</param>
        void OnStepTaken(bool eventTriggered);

        /// <summary>
        /// Allows wild encounters to trigger when player changes direction without moving.
        /// Enables encounters when turning in place on encounter-eligible terrain.
        /// </summary>
        /// <seealso cref="IEvents.OnStepTaken"/>
        /// <seealso cref="IEvents.OnPlayerStepTaken"/>
        /// <seealso cref="IEvents.OnPlayerChangeDirection"/>
        void on_player_change_direction_trigger_encounter();

        /// <summary>
        /// Processes potential wild battle encounters based on terrain and game state.
        /// Handles encounter rates, repel effects, and battle initiation logic.
        /// </summary>
        /// <param name="repel_active">Whether repel effect is currently preventing encounters</param>
        void BattleOnStepTaken(bool repel_active);

        /// <summary>
        /// Configures new map state including teleport destinations and encounter setup.
        /// Initializes map-specific settings when entering a different map area.
        /// </summary>
        /// <seealso cref="IEvents.OnEnterMap"/>
        /// <seealso cref="EventArg.IOnMapChangeEventArgs"/>
        /// <param name="old_map_id">The map ID that was previously active</param>
        void on_enter_map_setup_new_map(int old_map_id);

        /// <summary>
        /// Updates overworld weather effects when transitioning between maps.
        /// Changes weather display based on new map's metadata and environmental settings.
        /// </summary>
        /// <seealso cref="IEvents.OnEnterMap"/>
        /// <seealso cref="EventArg.IOnMapChangeEventArgs"/>
        /// <param name="old_map_id">The map ID that was previously active</param>
        void on_enter_map_set_weather(int old_map_id);

        /// <summary>
        /// Maintains navigation trail history of recently visited maps.
        /// Updates map visitation tracking for navigation and backtracking features.
        /// </summary>
        /// <seealso cref="IEvents.OnEnterMap"/>
        /// <seealso cref="EventArg.IOnMapChangeEventArgs"/>
        /// <param name="old_map_id">The map ID that was previously active</param>
        void on_enter_map_add_to_trail(int old_map_id);

        /// <summary>
        /// Manages bicycle state transitions when entering maps with cycling requirements.
        /// Forces cycling on required maps or dismounts bike on forbidden areas.
        /// </summary>
        /// <seealso cref="IEvents.OnEnterMap"/>
        /// <seealso cref="EventArg.IOnMapChangeEventArgs"/>
        /// <param name="old_map_id">The map ID that was previously active</param>
        void on_enter_map_force_cycling(int old_map_id);

        /// <summary>
        /// Controls darkness overlay visibility for cave exploration and Flash effects.
        /// Shows or hides darkness circle based on map lighting conditions.
        /// </summary>
        /// <seealso cref="IEvents.OnMapOrSpritesetChange"/>
        /// <seealso cref="EventArg.IOnMapSceneChangeEventArgs"/>
        /// <param name="scene">The map scene managing visual display</param>
        /// <param name="map_changed">Whether the map actually changed or just spriteset refreshed</param>
        void on_map_or_spriteset_change_show_darkness(ISceneMap scene, bool map_changed);

        /// <summary>
        /// Displays location signpost window when entering new named areas.
        /// Shows area announcements if location signposts are enabled in settings.
        /// </summary>
        /// <seealso cref="IEvents.OnMapOrSpritesetChange"/>
        /// <seealso cref="EventArg.IOnMapSceneChangeEventArgs"/>
        /// <param name="scene">The map scene managing visual display</param>
        /// <param name="map_changed">Whether the map actually changed or just spriteset refreshed</param>
        void on_map_or_spriteset_change_show_location_window(ISceneMap scene, bool map_changed);

        /// <summary>
        /// Calculates the map coordinates of the tile directly in front of an event.
        /// Returns full map context including map ID for cross-map tile references.
        /// </summary>
        /// <param name="direction">Facing direction to check (uses event's direction if null)</param>
        /// <param name="event">Event to check facing tile for (uses player if null)</param>
        /// <returns>Coordinates containing map ID, x position, and y position</returns>
        ITilePosition FacingTile(int? direction = null, IGameEvent @event = null);

        /// <summary>
        /// Gets the local tile coordinates that an event is facing within current map.
        /// Returns only x,y coordinates without map context for same-map operations.
        /// </summary>
        /// <param name="direction">Facing direction to check (uses event's direction if null)</param>
        /// <param name="event">Event to check facing tile for (uses player if null)</param>
        /// <returns>Local coordinates containing x and y position only</returns>
        ITilePosition FacingTileRegular(int? direction = null, IGameEvent @event = null);

        /// <summary>
        /// Determines if an event is facing toward the player within interaction distance.
        /// Checks both facing direction and proximity for NPC interaction mechanics.
        /// </summary>
        /// <param name="event">The event to check facing direction for</param>
        /// <param name="player">The player event to check if being faced</param>
        /// <param name="distance">Maximum distance for interaction eligibility</param>
        /// <returns>True if event faces player within specified distance</returns>
        bool EventFacesPlayer(IGameEvent @event, IGameEvent player, int distance);

        /// <summary>
        /// Checks if an event has clear line of sight and can reach the player.
        /// Verifies pathfinding possibility for AI movement and interaction systems.
        /// </summary>
        /// <param name="event">The event attempting to reach the player</param>
        /// <param name="player">The player event to reach</param>
        /// <param name="distance">Maximum reach distance for pathfinding</param>
        /// <returns>True if event can successfully reach player within distance</returns>
        bool EventCanReachPlayer(IGameEvent @event, IGameEvent player, int distance);

        /// <summary>
        /// Determines if two events are positioned adjacent and facing each other.
        /// Used for dialogue triggers and interactive event positioning.
        /// </summary>
        /// <param name="event1">First event in the facing relationship</param>
        /// <param name="event2">Second event in the facing relationship</param>
        /// <returns>True if both events are adjacent and facing toward each other</returns>
        bool FacingEachOther(IGameEvent event1, IGameEvent event2);

        /// <summary>
        /// Queues background music to play after a fade transition completes.
        /// Prevents audio conflicts by delaying playback until fade is finished.
        /// </summary>
        /// <param name="bgm">Background music to cue for delayed playback</param>
        /// <param name="seconds">Fade duration in seconds before music starts</param>
        /// <param name="volume">BGM volume level (null uses default)</param>
        /// <param name="pitch">BGM pitch adjustment (null uses default)</param>
        void CueBGM(IAudioBGM bgm, double seconds, int? volume = null, int? pitch = null);

        /// <summary>
        /// Automatically plays appropriate background music after map transitions.
        /// Handles surf music when surfing or falls back to default map music.
        /// </summary>
        void AutoplayOnTransition();

        /// <summary>
        /// Automatically plays appropriate background music after game save operations.
        /// Ensures proper music restoration after save dialogs or interruptions.
        /// </summary>
        void AutoplayOnSave();

        /// <summary>
        /// Creates and executes a movement route for the specified event.
        /// Constructs RPG movement commands from simplified command array.
        /// </summary>
        /// <param name="event">Game event to apply movement route to</param>
        /// <param name="commands">Array of PBMoveRoute movement command constants</param>
        /// <param name="waitComplete">Whether to block until movement completes</param>
        /// <returns>The created RPG movement route object</returns>
        RPGMaker.IMoveRoute MoveRoute(IGameEvent @event, int[] commands, bool waitComplete = false);

        /// <summary>
        /// Blocks execution for the specified duration while maintaining game updates.
        /// Continues processing graphics, input, and scene updates during wait.
        /// </summary>
        /// <param name="duration">Duration to wait in seconds</param>
        void Wait(double duration);

        /// <summary>
        /// Initiates or continues player sliding movement on ice terrain.
        /// Automatically moves player forward while on ice until hitting obstacle.
        /// </summary>
        void SlideOnIce();

        /// <summary>
        /// Rotates an event to face toward another event's position.
        /// Calculates relative positioning and chooses appropriate direction.
        /// </summary>
        /// <param name="event">Event that should turn to face the target</param>
        /// <param name="otherEvent">Target event to face toward</param>
        void TurnTowardEvent(IGameEvent @event, IGameEvent otherEvent);

        /// <summary>
        /// Moves an event toward the player's position using pathfinding.
        /// Continues movement until event reaches player or path is blocked.
        /// </summary>
        /// <param name="event">Event that should move toward the player</param>
        void MoveTowardPlayer(IGameEvent @event);

        /// <summary>
        /// Activates bridge mode with specified height for layered movement.
        /// Allows events to move over lower terrain at the bridge elevation.
        /// </summary>
        /// <param name="height">Elevation height of the bridge above ground level</param>
        void BridgeOn(int height = 2);

        /// <summary>
        /// Deactivates bridge mode and returns movement to ground level.
        /// Resets elevation tracking for normal terrain interaction.
        /// </summary>
        void BridgeOff();

        /// <summary>
        /// Records current player position as the cave escape destination.
        /// Used for Escape Rope and cave exit functionality.
        /// </summary>
        void SetEscapePoint();

        /// <summary>
        /// Clears the current cave escape point destination.
        /// Disables escape functionality until a new point is set.
        /// </summary>
        void EraseEscapePoint();

        /// <summary>
        /// Records current location as the active Pokémon Center for respawning.
        /// Sets the destination for blackout recovery and Fly quick travel.
        /// </summary>
        void SetPokemonCenter();

        /// <summary>
        /// Registers a partner trainer for double battles and following.
        /// Loads trainer data and prepares their team for cooperative battles.
        /// </summary>
        /// <param name="tr_type">Type identifier for the trainer class</param>
        /// <param name="tr_name">Name of the specific trainer</param>
        /// <param name="tr_id">Unique ID number for the trainer instance</param>
        void RegisterPartner(int tr_type, string tr_name, int tr_id = 0);

        /// <summary>
        /// Removes the current partner trainer from active status.
        /// Ends cooperative battle mode and clears partner data.
        /// </summary>
        void DeregisterPartner();

        /// <summary>
        /// Handles pickup of items from item balls in the overworld.
        /// Shows appropriate messages and adds items to bag if space available.
        /// </summary>
        /// <param name="item">Item to attempt pickup for</param>
        /// <param name="quantity">Number of items to pick up</param>
        /// <returns>True if item was successfully picked up, false if bag full</returns>
        bool ItemBall(int item, int quantity = 1);

        /// <summary>
        /// Handles receiving items from NPCs or events with appropriate messages.
        /// Shows obtained message before attempting to add to bag.
        /// </summary>
        /// <param name="item">Item to give to the player</param>
        /// <param name="quantity">Number of items to give</param>
        /// <returns>True if item was successfully added to bag</returns>
        bool ReceiveItem(int item, int quantity = 1);

        /// <summary>
        /// Handles Game Corner prize purchases with special messaging.
        /// Adds prize items directly to bag after successful purchase.
        /// </summary>
        /// <param name="item">Prize item to purchase</param>
        /// <param name="quantity">Number of prize items to buy</param>
        /// <returns>True if prize was successfully added to bag</returns>
        bool BuyPrize(int item, int quantity = 1);
    }

    /// <summary>
    /// class Game_Temp
    /// Additional Game_Temp attributes for overworld functionality
    /// </summary>
    public interface ITempMetadataOverworld : ITempMetadata
    {
        /// <summary>Whether low battery warning has been shown.</summary>
        bool warned_low_battery { get; set; }

        /// <summary>Queued BGM to play after delay.</summary>
        IAudioBGM cue_bgm { get; set; }

        /// <summary>Timer start time for BGM delay.</summary>
        double cue_bgm_timer_start { get; set; }

        /// <summary>Delay duration before playing queued BGM.</summary>
        double cue_bgm_delay { get; set; }
    }

    /// <summary>
    /// Move route command constants
    /// </summary>
    public interface IPBMoveRoute
    {
        // Movement command constants mapped from Ruby module
        int DOWN { get; }
        int LEFT { get; }
        int RIGHT { get; }
        int UP { get; }
        int LOWER_LEFT { get; }
        int LOWER_RIGHT { get; }
        int UPPER_LEFT { get; }
        int UPPER_RIGHT { get; }
        int RANDOM { get; }
        int TOWARD_PLAYER { get; }
        int AWAY_FROM_PLAYER { get; }
        int FORWARD { get; }
        int BACKWARD { get; }
        int JUMP { get; }
        int WAIT { get; }
        int TURN_DOWN { get; }
        int TURN_LEFT { get; }
        int TURN_RIGHT { get; }
        int TURN_UP { get; }
        int TURN_RIGHT90 { get; }
        int TURN_LEFT90 { get; }
        int TURN180 { get; }
        int TURN_RIGHT_OR_LEFT90 { get; }
        int TURN_RANDOM { get; }
        int TURN_TOWARD_PLAYER { get; }
        int TURN_AWAY_FROM_PLAYER { get; }
        int SWITCH_ON { get; }
        int SWITCH_OFF { get; }
        int CHANGE_SPEED { get; }
        int CHANGE_FREQUENCY { get; }
        int WALK_ANIME_ON { get; }
        int WALK_ANIME_OFF { get; }
        int STEP_ANIME_ON { get; }
        int STEP_ANIME_OFF { get; }
        int DIRECTION_FIX_ON { get; }
        int DIRECTION_FIX_OFF { get; }
        int THROUGH_ON { get; }
        int THROUGH_OFF { get; }
        int ALWAYS_ON_TOP_ON { get; }
        int ALWAYS_ON_TOP_OFF { get; }
        int GRAPHIC { get; }
        int OPACITY { get; }
        int BLENDING { get; }
        int PLAY_SE { get; }
        int SCRIPT { get; }
        int SCRIPT_ASYNC { get; }
    }
}