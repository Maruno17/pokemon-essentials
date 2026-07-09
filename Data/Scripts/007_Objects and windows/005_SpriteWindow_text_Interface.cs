using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents a window that can display text with sprites.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing windows that can display text with sprites,
	/// including text rendering, formatting, and sprite management.
	/// </remarks>
	//public interface ISpriteWindowText : ISpriteWindow
	public interface IWindow_UnformattedTextPokemon : ISpriteWindow_Base, IHaveRefresh
	{
		/// <summary>
		/// Gets or sets the window's text.
		/// </summary>
		string text { get; set; }

		/// <summary>
		/// Gets or sets the window's font.
		/// </summary>
		//IFont Font { get; set; }

		/// <summary>
		/// Gets or sets the window's text color.
		/// </summary>
		IColor baseColor { get; set; }
		IColor shadowColor { get; set; }
		//IColor TextColor { get; set; }

		/// <summary>
		/// Letter-by-letter mode.
		/// </summary>
		/// <remarks>
		/// This mode is not supported in this class.
		/// </remarks>
		bool letterbyletter		{ get; set; }

		/// <summary>
		/// Initializes the text sprite window with an optional viewport.
		/// </summary>
		/// <param name="viewport">The viewport to use, or null for the default.</param>
		IWindow_UnformattedTextPokemon initialize(string text = "");

		IWindow_UnformattedTextPokemon WithSize(string text, int x, int y, int width, int height, IViewport viewport = null);

		/// <summary>
		/// </summary>
		/// <param name="text"></param>
		/// <param name="maxwidth">maxwidth is maximum acceptable window width.</param>
		/// <returns></returns>
		IPoint resizeToFitInternal(string text, int maxwidth);

		void setTextToFit(string text, int maxwidth = -1);

		/// <summary>
		/// </summary>
		/// <param name="text"></param>
		/// <param name="maxwidth">maxwidth is maximum acceptable window width.</param>
		void resizeToFit(string text, int maxwidth = -1);

		/// <summary>
		/// </summary>
		/// <param name="text"></param>
		/// <param name="width">width is current window width.</param>
		void resizeHeightToFit(string text, int width = -1);

		void setSkin(int skin);

		void Refresh();
	}

	public interface IWindow_AdvancedTextPokemon : ISpriteWindow_Base, IHaveUpdate, IHaveRefresh, IDisposable {
		string text				{ get; set; }
		IColor baseColor		{ get; set; }
		IColor shadowColor		{ get; set; }
		bool letterbyletter		{ get; set; }
		int lineHeight			{ get; set; }

		//void lineHeight(value) {
		//	@lineHeight=value;
		//	this.text=this.text;
		//}
		//
		//void text=(value) {
		//	setText(value);
		//}

		int textspeed { get; set; }

		int waitcount { get; set; }

		//void baseColor=(value) {
		//	@baseColor=value;
		//	refresh();
		//}
		//
		//void shadowColor=(value) {
		//	@shadowColor=value;
		//	refresh();
		//}

		//void dispose();

		/// <summary>
		/// 0 = Pause cursor is displayed at end of text<para>
		/// 1 = Pause cursor is displayed at bottom right</para>
		/// 2 = Pause cursor is displayed at lower middle side
		/// </summary>
		int cursorMode				{ get; set; }

		//void cursorMode=(value) {
		//	@cursorMode=value;
		//	moveCursor;
		//}

		IWindow_AdvancedTextPokemon initialize(string text = "");

		IWindow_AdvancedTextPokemon WithSize(string text, float x, float y, int width, int height, IViewport viewport= null);

		int width { set; }

		int height { set; }

		void resizeToFit(string text, int maxwidth = -1);

		void resizeToFit2(string text, int maxwidth, int maxheight);

		int[] resizeToFitInternal(string text, int maxwidth);

		void resizeHeightToFit(string text, int width = -1);

		void setSkin(int skin, bool redrawText = true);

		void setTextToFit(string text, int maxwidth = -1);

		void setText(string value);

		bool busy { get; }

		bool pausing { get; }

		bool resume();

		int position();

		int maxPosition();

		void skipAhead();

		void allocPause();

		void startPause();

		void stopPause();

		void moveCursor();

		void refresh();

		void redrawText();

		void updateInternal();

		void update();
	}

	public interface IWindow_InputNumberPokemon : ISpriteWindow_Base, IHaveUpdate, IHaveRefresh {
		int number			{ get; set; }
		bool sign				{ get; set; }
		bool active			{ set; }

		IWindow_InputNumberPokemon initialize(int digits_max);

		void refresh();

		void update();
	}

	public interface ISpriteWindow_Selectable : ISpriteWindow_Base, IHaveUpdate, IHaveRefresh {
		int index				{ get; set; }
		int itemCount			{ get; }
		int count				{ get; }
		int rowHeight			{ get; set; }
		int columns				{ get; }
		int columnSpacing		{ get; set; }
		int row_max				{ get; }
		int top_row				{ get; set; }
		int top_item			{ get; }
		int page_row_max			{ get; }
		int page_item_max			{ get; }

		ISpriteWindow_Selectable initialize(float x, float y, float width, float height);

		bool ignore_input { set; }
		//
		//void count() {
		//return @item_max;
		//}
		//
		//void row_max() {
		//return ((@item_max + @column_max - 1) / @column_max).to_i;
		//}
		//
		//void top_row() {
		//return (@virtualOy / (@row_height || 32)).to_i;
		//}
		//
		//void top_item() {
		//return top_row * @column_max;
		//}

		//void top_row=(row) {
		//	if (row>row_max-1) {
		//		row=row_max-1;
		//	}
		//	if (row<0) {		// NOTE: The two comparison checks must be reversed since row_max can be 0
		//		row=0;
		//	}
		//	@virtualOy=row*@row_height;
		//}
		//
		//void page_row_max() {
		//return priv_page_row_max.to_i;
		//}
		//
		//void page_item_max() {
		//return priv_page_item_max.to_i;
		//}

		IRect itemRect(int item);

		void refresh();

		void update_cursor_rect();

		void update();
	}

	public interface IUpDownArrowMixin : IHaveUpdate, IDisposable {
		IUpDownArrowMixin initUpDownArrow();

		//void dispose();

		IViewport viewport { set; }

		IColor color { set; }

		void adjustForZoom(ISprite sprite);

		void update();
	}

	public interface ISpriteWindow_SelectableEx : ISpriteWindow_Selectable, IUpDownArrowMixin
	{
		//include UpDownArrowMixin;

		//new IViewport viewport { set; }

		ISpriteWindow_SelectableEx initialize(float x, float y, float width, float height);
	}

	public interface IWindow_DrawableCommand : ISpriteWindow_SelectableEx, IHaveUpdate, IHaveRefresh, IDisposable {
		//bool doubleclick			{ get; }
		int baseColor				{ get; set; }
		int shadowColor			{ get; set; }

		IWindow_DrawableCommand initialize(float x, float y, float width, float height, IViewport viewport = null);

		float textWidth(IBitmap bitmap, string text);

		void getAutoDims(string[] commands, int[] dims, float? width = null);

		void setSkin(int skin);

		IRect drawCursor(int index, IRect rect);

		//void dispose();

		/// <summary>
		/// </summary>
		/// <remarks>
		/// To be implemented by derived classes.
		/// </remarks>
		int itemCount();

		/// <summary>
		/// </summary>
		/// <remarks>
		/// To be implemented by derived classes.
		/// </remarks>
		/// <param name="index"></param>
		/// <param name="count"></param>
		/// <param name="rect"></param>
		void drawItem(int index, int count, IRect rect);

		void refresh();

		void update();
	}

	public interface IWindow_CommandPokemon : IWindow_DrawableCommand {
		//new IColor color				{ get; set; }
		IList<string> commands				{ get; set; }

		IWindow_CommandPokemon initialize(string[] commands,float? width=null);

		IWindow_CommandPokemon WithSize(string[] commands, float x, float y, float width, float height, IViewport viewport= null);

		IWindow_CommandPokemon Empty(float x, float y, float width, float height, IViewport viewport= null);

		int index { set; }

		float width { set; }

		float height { set; }

		void resizeToFit(string[] commands, float? width = null);

		int itemCount();

		void drawItem(int index, int count, IRect rect);
	}

	public interface IWindow_AdvancedCommandPokemon : IWindow_DrawableCommand {
		IList<string> commands				{ get; set; }

		int textWidth(IBitmap bitmap, string text);

		IWindow_AdvancedCommandPokemon initialize(string[] commands, int? width= null);

		IWindow_AdvancedCommandPokemon WithSize(string[] commands,float x,float y,int width,int height,IViewport viewport= null);

		IWindow_AdvancedCommandPokemon Empty(float x, float y, int width, int height, IViewport viewport = null);

		int index { set; }

		//string[] commands { set; }

		int width { set; }

		int height { set; }

		void resizeToFit(string[] commands, int? width = null);

		int itemCount();

		void drawItem(int index, int count, IRect rect);
	}

	public interface IWindow_CommandPokemonEx : IWindow_CommandPokemon { }

	public interface IWindow_AdvancedCommandPokemonEx : IWindow_AdvancedCommandPokemon { }

	/// <summary>
	/// Represents the alignment of text in a window.
	/// </summary>
	public enum TextAlignment
	{
		/// <summary>
		/// Text is aligned to the left.
		/// </summary>
		Left,

		/// <summary>
		/// Text is centered.
		/// </summary>
		Center,

		/// <summary>
		/// Text is aligned to the right.
		/// </summary>
		Right
	}
}