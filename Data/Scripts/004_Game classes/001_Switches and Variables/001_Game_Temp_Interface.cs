using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// This class handles temporary data that is not included with save data.
	/// </summary>
	/// <remarks>
	/// Refer to "<see cref="Game.game_temp"/>" for the instance of this class.
	/// This interface manages various temporary game states and flags that persist between map transitions
	/// but are not saved to the save file. It includes battle states, player transfers, menu states,
	/// and other temporary game conditions.
	/// </remarks>
	public interface ITempMetadata {
		#region Flags requesting something to happen
		/// <summary>
		/// Gets or sets the menu calling flag.
		/// </summary>
		/// <remarks>
		/// Indicates that the menu system should be opened.
		/// </remarks>
		bool menu_calling { get; set; }
		/// <summary>ready menu calling flag</summary>
		bool ready_menu_calling { get; set; }
		/// <summary>debug calling flag</summary>
		bool debug_calling { get; set; }
		/// <summary>EventHandlers.TriggerOn_player_interact(this) flag</summary>
		bool interact_calling { get; set; }
		/// <summary>battle flag: interrupt (unused)</summary>
		bool battle_abort { get; set; }
		/// <summary>return to title screen flag</summary>
		bool title_screen_calling { get; set; }
		/// <summary>common event ID to start</summary>
		int common_event_id { get; set; }
		#endregion
		#region Flags indicating something is happening
		/// <summary>
		/// Gets or sets whether the menu is currently open.
		/// </summary>
		/// <remarks>
		/// Indicates that a menu interface is currently being displayed.
		/// </remarks>
		bool in_menu { get; set; }
		/// <summary>in-Pokémon storage flag</summary>
		bool in_storage { get; set; }
		/// <summary>in-battle flag</summary>
		bool in_battle { get; set; }
		/// <summary>message window showing</summary>
		bool message_window_showing { get; set; }
		/// <summary>jumping off surf base flag</summary>
		bool ending_surf { get; set; }
		/// <summary>[x, y] while jumping on/off, or null</summary>
		bool surf_base_coords { get; set; }
		/// <summary>performing mini update flag</summary>
		bool in_mini_update { get; set; }
		#endregion
		#region Battle
		/// <summary>
		/// Gets or sets the battleback file name.
		/// </summary>
		/// <remarks>
		/// The filename of the background image to use during battles.
		/// </remarks>
		string battleback_name { get; set; }
		/// <summary>force next battle to be 1v1 flag</summary>
		bool force_single_battle { get; set; }
		/// <summary>[trainer, event ID] or null</summary>
		int waiting_trainer { get; set; }
		/// <summary>record of actions in last recorded battle</summary>
		int last_battle_record { get; set; }
		#endregion
		#region Player transfers
		/// <summary>
		/// Gets or sets whether the player is being transferred.
		/// </summary>
		/// <remarks>
		/// Indicates that the player is in the process of being moved to a new location.
		/// </remarks>
		bool player_transferring { get; set; }
		/// <summary>player destination: map ID</summary>
		int player_new_map_id { get; set; }
		/// <summary>player destination: x-coordinate</summary>
		int player_new_x { get; set; }
		/// <summary>player destination: y-coordinate</summary>
		int player_new_y { get; set; }
		/// <summary>player destination: direction</summary>
		int player_new_direction { get; set; }
		/// <summary>[map ID, x, y] or null</summary>
		int fly_destination { get; set; }
		#endregion
		#region Transitions
		/// <summary>
		/// Gets or sets whether a transition is being processed.
		/// </summary>
		/// <remarks>
		/// Indicates that a screen transition effect is currently active.
		/// </remarks>
		bool transition_processing { get; set; }
		/// <summary>transition file name</summary>
		string transition_name { get; set; }
		IBitmap background_bitmap { get; set; }
		/// <summary>for sprite hashes</summary>
		int fadestate { get; set; }
		#endregion
		#region Other
		/// <summary>
		/// Gets or sets whether a new game has been started.
		/// </summary>
		/// <remarks>
		/// True from new game until first save, false otherwise.
		/// </remarks>
		bool begun_new_game { get; set; }
		/// <summary>menu: play sound effect flag</summary>
		bool menu_beep { get; set; }
		/// <summary>pause menu: index of last selection</summary>
		int menu_last_choice { get; set; }
		/// <summary>set when trainer intro BGM is played</summary>
		IAudioBGM memorized_bgm { get; set; }
		/// <summary>set when trainer intro BGM is played</summary>
		int memorized_bgm_position { get; set; }
		/// <summary>DarknessSprite or null</summary>
		int darkness_sprite { get; set; }
		/// <summary>
		/// Gets or sets the list of mart prices.
		/// </summary>
		/// <remarks>
		/// Stores the prices of items in the current Pokémon Mart.
		/// </remarks>
		IDictionary<int, int[]> mart_prices { get; set; }
		#endregion

		/// <summary>
		/// Initializes all temporary data to their default values.
		/// </summary>
		/// <remarks>
		/// This method should be called when starting a new game or loading a save file.
		/// </remarks>
		ITempMetadata initialize();

		/// <summary>
		/// Clears the list of mart prices.
		/// </summary>
		/// <remarks>
		/// Should be called when leaving a Pokémon Mart or when prices need to be reset.
		/// </remarks>
		void clear_mart_prices();
	}
}