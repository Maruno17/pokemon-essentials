using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials//.Debug.Editor.Listers
{
	/// <summary>
	/// Main editor lister functionality for creating list-based selection interfaces.
	/// Provides core windowing and screen management for editor list displays.
	/// </summary>
	public interface IMainEditorListers : IMain
	{
		/// <summary>
		/// Creates a list window with specified commands and width.
		/// </summary>
		/// <param name="cmds">The list of commands to display</param>
		/// <param name="width">The width of the window (default Graphics.width / 2)</param>
		/// <returns>The configured list window</returns>
		object ListWindow(IList<string> cmds, int width = -1);

		/// <summary>
		/// Displays a list screen with title and lister, returns selected value.
		/// </summary>
		/// <param name="title">The title to display</param>
		/// <param name="lister">The lister object providing content</param>
		/// <returns>The value selected by the user</returns>
		object ListScreen(string title, ILister lister);

		/// <summary>
		/// Displays an interactive list screen with action callbacks.
		/// </summary>
		/// <param name="title">The title to display</param>
		/// <param name="lister">The lister object providing content</param>
		void ListScreenBlock(string title, ILister lister);
	}

	/// <summary>
	/// Base interface for all lister objects that provide list-based selection functionality.
	/// Listers manage content display, viewport handling, and value retrieval.
	/// </summary>
	public interface ILister : IDisposable
	{
		//ILister initialize(string folder, string selection);

		/// <summary>
		/// Sets the viewport for rendering this lister's content.
		/// </summary>
		/// <param name="viewport">The viewport to use for rendering</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the initial index to select when the lister is displayed.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of commands/items to display in the selection list.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the value associated with the specified index.
		/// </summary>
		/// <param name="index">The index to get the value for</param>
		/// <returns>The value at the specified index</returns>
		object value(int index);

		//void Dispose();

		/// <summary>
		/// Refreshes the display for the specified index (e.g., preview images).
		/// </summary>
		/// <param name="index">The index to refresh display for</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for graphics files with image preview functionality.
	/// Displays .png and .gif files from a specified folder with visual preview.
	/// </summary>
	public interface IGraphicsLister : ILister
	{
		/// <summary>
		/// Initializes the graphics lister with folder and selection.
		/// </summary>
		/// <param name="folder">The folder path containing graphics files</param>
		/// <param name="selection">The initially selected file</param>
		IGraphicsLister initialize(string folder, string selection);

		/// <summary>
		/// Sets the viewport for the preview sprite.
		/// </summary>
		/// <param name="viewport">The viewport to use</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of graphics filenames.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the filename at the specified index.
		/// </summary>
		/// <param name="index">The file index</param>
		/// <returns>The filename or empty string for invalid index</returns>
		string value(int index);

		/// <summary>
		/// Refreshes the preview image for the specified file.
		/// </summary>
		/// <param name="index">The file index to preview</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for music files (BGM/ME) with audio preview functionality.
	/// Displays music files from Audio/BGM or Audio/ME folders with playback.
	/// </summary>
	public interface IMusicFileLister : ILister
	{
		/// <summary>
		/// Initializes the music lister with BGM/ME type and selection.
		/// </summary>
		/// <param name="bgm">True for BGM files, false for ME files</param>
		/// <param name="setting">The initially selected file</param>
		IMusicFileLister initialize(bool bgm, string setting);

		/// <summary>
		/// Sets the viewport (no-op for music lister).
		/// </summary>
		/// <param name="viewport">The viewport (unused)</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the currently playing BGM for restoration.
		/// </summary>
		/// <returns>The current BGM or null</returns>
		object getPlayingBGM();

		/// <summary>
		/// Plays the specified BGM or stops music if null.
		/// </summary>
		/// <param name="bgm">The BGM to play or null to stop</param>
		void PlayBGM(IAudioBGM bgm);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of music filenames.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the filename at the specified index.
		/// </summary>
		/// <param name="index">The file index</param>
		/// <returns>The filename or empty string for invalid index</returns>
		string value(int index);

		/// <summary>
		/// Refreshes by playing the music file at the specified index.
		/// </summary>
		/// <param name="index">The file index to play</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for metadata selection (global and player-specific).
	/// Provides selection of global metadata or specific player metadata.
	/// </summary>
	public interface IMetadataLister : ILister
	{
		/// <summary>
		/// Initializes the metadata lister with player selection options.
		/// </summary>
		/// <param name="sel_player_id">The initially selected player ID (-1 for none)</param>
		/// <param name="new_player">Whether to include "add new player" option</param>
		IMetadataLister initialize(int sel_player_id = -1, bool new_player = false);

		/// <summary>
		/// Sets the viewport (no-op for metadata lister).
		/// </summary>
		/// <param name="viewport">The viewport (unused)</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of metadata options.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the metadata value at the specified index.
		/// Returns: -1=cancel, -2=new player, 0=global, 1+=player ID
		/// </summary>
		/// <param name="index">The selection index</param>
		/// <returns>The metadata identifier</returns>
		int value(int index);

		/// <summary>
		/// Refreshes the display (no-op for metadata lister).
		/// </summary>
		/// <param name="index">The index (unused)</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for map selection with minimap preview functionality.
	/// Displays available maps with hierarchical structure and visual preview.
	/// </summary>
	public interface IMapLister : ILister
	{
		/// <summary>
		/// Initializes the map lister with selection and global option.
		/// </summary>
		/// <param name="selmap">The initially selected map ID</param>
		/// <param name="addGlobal">Whether to include global option</param>
		IMapLister initialize(int selmap, bool addGlobal = false);

		/// <summary>
		/// Sets the viewport for the minimap sprite.
		/// </summary>
		/// <param name="viewport">The viewport to use</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of map names with hierarchy formatting.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the map ID at the specified index.
		/// </summary>
		/// <param name="index">The map index</param>
		/// <returns>The map ID (0 for global, -1 for cancel)</returns>
		int value(int index);

		/// <summary>
		/// Refreshes the minimap preview for the specified map.
		/// </summary>
		/// <param name="index">The map index to preview</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for Pokemon species selection with alphabetical sorting.
	/// Displays all species sorted by name with optional "new species" entry.
	/// </summary>
	public interface ISpeciesLister : ILister
	{
		/// <summary>
		/// Initializes the species lister with selection and new option.
		/// </summary>
		/// <param name="selection">The initial selection index (default 0)</param>
		/// <param name="includeNew">Whether to include "new species" option</param>
		ISpeciesLister initialize(int selection = 0, bool includeNew = false);

		/// <summary>
		/// Sets the viewport (no-op for species lister).
		/// </summary>
		/// <param name="viewport">The viewport (unused)</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of species names sorted alphabetically.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the species ID at the specified index.
		/// </summary>
		/// <param name="index">The species index</param>
		/// <returns>The species ID or true for new species option</returns>
		object value(int index);

		/// <summary>
		/// Refreshes the display (no-op for species lister).
		/// </summary>
		/// <param name="index">The index (unused)</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for item selection with icon preview functionality.
	/// Displays all items sorted alphabetically with visual item icons.
	/// </summary>
	public interface IItemLister : ILister
	{
		/// <summary>
		/// Initializes the item lister with selection and new option.
		/// </summary>
		/// <param name="selection">The initial selection index (default 0)</param>
		/// <param name="includeNew">Whether to include "new item" option</param>
		IItemLister initialize(int selection = 0, bool includeNew = false);

		/// <summary>
		/// Sets the viewport for the item icon sprite.
		/// </summary>
		/// <param name="viewport">The viewport to use</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of item names sorted alphabetically.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the item ID at the specified index.
		/// </summary>
		/// <param name="index">The item index</param>
		/// <returns>The item ID or true for new item option</returns>
		object value(int index);

		/// <summary>
		/// Refreshes the item icon for the specified item.
		/// </summary>
		/// <param name="index">The item index to display icon for</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for trainer type selection with sprite preview functionality.
	/// Displays all trainer types with front sprite previews.
	/// </summary>
	public interface ITrainerTypeLister : ILister
	{
		/// <summary>
		/// Initializes the trainer type lister with selection and new option.
		/// </summary>
		/// <param name="selection">The initial selection index (default 0)</param>
		/// <param name="includeNew">Whether to include "new trainer type" option</param>
		ITrainerTypeLister initialize(int selection = 0, bool includeNew = false);

		/// <summary>
		/// Sets the viewport for the trainer sprite.
		/// </summary>
		/// <param name="viewport">The viewport to use</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of trainer type names.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the trainer type ID at the specified index.
		/// </summary>
		/// <param name="index">The trainer type index</param>
		/// <returns>The trainer type ID or true for new trainer type option</returns>
		object value(int index);

		/// <summary>
		/// Refreshes the trainer sprite for the specified trainer type.
		/// </summary>
		/// <param name="index">The trainer type index to display sprite for</param>
		void refresh(int index);
	}

	/// <summary>
	/// Lister for trainer battle selection with detailed battle information.
	/// Displays trainer battles with trainer sprites and Pokemon team details.
	/// </summary>
	public interface ITrainerBattleLister : ILister
	{
		/// <summary>
		/// Initializes the trainer battle lister with selection and new option.
		/// </summary>
		/// <param name="selection">The initial selection index</param>
		/// <param name="includeNew">Whether to include "new trainer battle" option</param>
		ITrainerBattleLister initialize(int selection, bool includeNew);

		/// <summary>
		/// Sets the viewport for trainer sprite and Pokemon list.
		/// </summary>
		/// <param name="viewport">The viewport to use</param>
		void setViewport(IViewport viewport);

		/// <summary>
		/// Gets the starting selection index.
		/// </summary>
		int startIndex { get; }

		/// <summary>
		/// Gets the list of trainer battle descriptions with team counts.
		/// </summary>
		IList<string> commands { get; }

		/// <summary>
		/// Gets the trainer battle identifier at the specified index.
		/// </summary>
		/// <param name="index">The battle index</param>
		/// <returns>Array of [trainer_type, name, version] or true for new battle</returns>
		object value(int index);

		/// <summary>
		/// Refreshes the trainer sprite and Pokemon team list.
		/// </summary>
		/// <param name="index">The battle index to display details for</param>
		void refresh(int index);
	}
}