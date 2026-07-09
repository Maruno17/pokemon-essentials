using PokemonEssentials.RPGMaker.Kernel;
using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Provides core scene elements and UI controls for the battle animation editor.
	/// Contains fundamental components like menus, clipboards, and base control classes used throughout the animation editor.
	/// </summary>
	public interface IBattleAnimationEditor
	{
		/// <summary>
		/// Displays a popup menu at the current mouse position.
		/// Used for context-sensitive menu operations in the animation editor.
		/// </summary>
		/// <param name="commands">Array of command strings to display in the menu.</param>
		/// <returns>Index of the selected command, or -1 if cancelled.</returns>
		int TrackPopupMenu(IList<string> commands);
	}

	/// <summary>
	/// Provides a custom menu window with mouse interaction support.
	/// Used for context menus and popup selections in the animation editor.
	/// </summary>
	public interface IWindowMenu : IWindow_CommandPokemon
	{
		/// <summary>
		/// Initializes the menu window with commands at the specified position.
		/// </summary>
		/// <param name="commands">Array of command strings to display.</param>
		/// <param name="x">X coordinate for the menu.</param>
		/// <param name="y">Y coordinate for the menu.</param>
		IWindowMenu initialize(IList<string> commands, int x, int y);

		/// <summary>
		/// Performs hit testing to determine which menu item is under the mouse cursor.
		/// </summary>
		/// <returns>Index of the menu item under the cursor, or -1 if none.</returns>
		int hittest();
	}

	/// <summary>
	/// Provides clipboard functionality for copy/paste operations in the animation editor.
	/// Allows copying animation elements and pasting them in other locations.
	/// </summary>
	public interface IClipboard
	{
		/// <summary>
		/// Gets the current clipboard data.
		/// </summary>
		/// <returns>The data stored in the clipboard, or null if empty.</returns>
		object data { get; }

		/// <summary>
		/// Gets the type key of the current clipboard data.
		/// </summary>
		/// <returns>String identifying the type of data stored.</returns>
		string typekey { get; }

		/// <summary>
		/// Sets data in the clipboard with a type identifier.
		/// </summary>
		/// <param name="data">The data to store in the clipboard.</param>
		/// <param name="key">String identifying the type of data.</param>
		void setData(object data, string key);
	}

	/// <summary>
	/// Provides shadow text rendering functionality for UI elements.
	/// Used to create readable text overlays with shadow effects.
	/// </summary>
	public interface IShadowText
	{
		/// <summary>
		/// Draws text with a shadow effect on the specified bitmap.
		/// </summary>
		/// <param name="bitmap">The bitmap to draw on.</param>
		/// <param name="x">X coordinate for the text.</param>
		/// <param name="y">Y coordinate for the text.</param>
		/// <param name="w">Width of the text area.</param>
		/// <param name="h">Height of the text area.</param>
		/// <param name="t">The text to draw.</param>
		/// <param name="disabled">Whether the text should appear disabled.</param>
		/// <param name="align">Text alignment (0=left, 1=center, 2=right).</param>
		void shadowtext(IBitmap bitmap, int x, int y, int w, int h, string t, bool disabled = false, int align = 0);
	}

	/// <summary>
	/// Sprite sheet scrolling bar.
	/// </summary>
	public interface IAnimationWindow : ISprite, IHaveUpdate, IHaveRefresh
	{
		/// <summary>
		/// The bitmap used for rendering the control.
		/// </summary>
		IAnimatedBitmap animbitmap { get; set; }

		int start { get; set; }

		int selected { get; set; }

		/// <summary>
		/// Whether the control's value has been changed.
		/// </summary>
		bool changed { get; set; }

		IAnimationWindow initialize(float x, float y, float width, float height, IViewport viewport = null);

		void drawrect(IBitmap bm, float x, float y, float width, float height, IColor color);

		void drawborder(IBitmap bm, float x, float y, float width, float height, IColor color);

		/// <summary>
		/// Redraws the control's visual representation.
		/// </summary>
		void refresh();

		/// <summary>
		/// Updates the control's logic, potentially invalidating it.
		/// </summary>
		void update();
	}

	public interface ICanvasAnimationWindow : IAnimationWindow
	{
		/// <summary>
		/// The bitmap used for rendering the control.
		/// </summary>
		IAnimatedBitmap animbitmap { get; set; }

		ICanvasAnimationWindow initialize(string canvas, float x, float y, float width, float height, IViewport viewport = null);
	}

	/// <summary>
	/// Cel sprite.
	/// </summary>
	interface IInvalidatableSprite : ISprite
	{
		IInvalidatableSprite initialize(IViewport viewport = null);

		/// <summary>
		/// Marks the control as needing to be redrawn.
		/// </summary>
		void invalidate();

		/// <summary>
		/// Gets whether the control needs to be redrawn.
		/// </summary>
		/// <returns>True if the control is invalid and needs refreshing.</returns>
		bool invalid { get; }

		/// <summary>
		/// Marks the control as no longer needing to be redrawn.
		/// </summary>
		void validate();

		/// <summary>
		/// Redraws the control only if it is currently invalid.
		/// </summary>
		void repaint();
	}
}