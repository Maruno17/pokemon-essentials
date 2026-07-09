using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface ICharacterEntryHelper
	{
		string text { get; set; }
		int maxlength { get; set; }
		char? passwordChar  { get; set; }
		int cursor { get; }

		char[] textChars();

		ICharacterEntryHelper initialize(string text);

		int length();

		bool canInsert();

		bool insert(string ch);

		bool canDelete();

		bool delete();

		//private
		//void ensure;
	}

	public interface IWindow_TextEntry : ISpriteWindow_Base, IHaveUpdate, IHaveRefresh
	{
		string text { get; set; }
		int maxlength { get; set; }
		char? passwordChar  { get; set; }

		IWindow_TextEntry initialize(string text,int x,int y,int width,int height,string heading=null,bool usedarkercolor=false);

		bool insert(char? ch);
		bool insert(string ch);

		void delete();

		//void update();

		void refresh();
	}

	public interface IWindow_TextEntry_Keyboard : IWindow_TextEntry, IHaveUpdate
	{
		void update();
	}

	public interface IWindow_MultilineTextEntry : ISpriteWindow_Base, IHaveUpdate, IHaveRefresh
	{
		string text { get; set; }
		int maxlength { get; set; }
		char? passwordChar  { get; set; }
		IColor baseColor { get; set; }
		IColor shadowColor { get; set; }

		IWindow_MultilineTextEntry initialize(string text,float x,float y,int width,int height);

		bool insert(string ch);

		bool delete();

		string getTextChars();

		int getTotalLines();

		int getLineY(int line);

		int getColumnsInLine(int line);

		int getPosFromLineAndColumn(int line,int column);

		int getLastVisibleLine();

		void updateCursorPos(bool doRefresh);

		void moveCursor(int lineOffset,int columnOffset);

		//void update();

		void refresh();
	}

	/// <summary>
	/// Represents a text entry system for the game.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing text entry in the game,
	/// including text input, validation, and display.
	/// </remarks>
	//public interface ITextEntry
	//{
	//	/// <summary>
	//	/// Gets or sets the text entry window.
	//	/// </summary>
	//	IWindow TextEntryWindow { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry text.
	//	/// </summary>
	//	string TextEntryText { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry font.
	//	/// </summary>
	//	IFont TextEntryFont { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry text color.
	//	/// </summary>
	//	IColor TextEntryTextColor { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry text alignment.
	//	/// </summary>
	//	TextAlignment TextEntryTextAlignment { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry text speed.
	//	/// </summary>
	//	float TextEntryTextSpeed { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the text entry is paused.
	//	/// </summary>
	//	bool TextEntryPause { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry pause opacity.
	//	/// </summary>
	//	int TextEntryPauseOpacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry pause frame.
	//	/// </summary>
	//	int TextEntryPauseFrame { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry cursor opacity.
	//	/// </summary>
	//	int TextEntryCursorOpacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the text entry cursor rectangle.
	//	/// </summary>
	//	IWindowCursorRect TextEntryCursorRect { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the maximum length of the text entry.
	//	/// </summary>
	//	int MaxLength { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the text entry is password mode.
	//	/// </summary>
	//	bool PasswordMode { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the password character.
	//	/// </summary>
	//	char PasswordChar { get; set; }
	//
	//	/// <summary>
	//	/// Initializes the text entry system.
	//	/// </summary>
	//	void Initialize();
	//
	//	/// <summary>
	//	/// Disposes of the text entry system and its resources.
	//	/// </summary>
	//	void Dispose();
	//
	//	/// <summary>
	//	/// Checks if the text entry system has been disposed.
	//	/// </summary>
	//	/// <returns>True if the text entry system has been disposed, false otherwise.</returns>
	//	bool IsDisposed();
	//
	//	/// <summary>
	//	/// Updates the text entry system's state.
	//	/// </summary>
	//	void Update();
	//
	//	/// <summary>
	//	/// Refreshes the text entry system's appearance.
	//	/// </summary>
	//	/// <param name="force_refresh">Whether to force a complete refresh.</param>
	//	void Refresh(bool force_refresh = false);
	//
	//	/// <summary>
	//	/// Sets the text entry window.
	//	/// </summary>
	//	/// <param name="window">The window to set.</param>
	//	void SetTextEntryWindow(IWindow window);
	//
	//	/// <summary>
	//	/// Sets the text entry text.
	//	/// </summary>
	//	/// <param name="text">The text to set.</param>
	//	void SetTextEntryText(string text);
	//
	//	/// <summary>
	//	/// Sets the text entry font.
	//	/// </summary>
	//	/// <param name="font">The font to set.</param>
	//	void SetTextEntryFont(IFont font);
	//
	//	/// <summary>
	//	/// Sets the text entry text color.
	//	/// </summary>
	//	/// <param name="color">The color to set.</param>
	//	void SetTextEntryTextColor(IColor color);
	//
	//	/// <summary>
	//	/// Sets the text entry text alignment.
	//	/// </summary>
	//	/// <param name="alignment">The alignment to set.</param>
	//	void SetTextEntryTextAlignment(TextAlignment alignment);
	//
	//	/// <summary>
	//	/// Sets the text entry text speed.
	//	/// </summary>
	//	/// <param name="speed">The speed to set.</param>
	//	void SetTextEntryTextSpeed(float speed);
	//
	//	/// <summary>
	//	/// Sets whether the text entry is paused.
	//	/// </summary>
	//	/// <param name="pause">Whether to pause the text entry.</param>
	//	void SetTextEntryPause(bool pause);
	//
	//	/// <summary>
	//	/// Sets the text entry pause opacity.
	//	/// </summary>
	//	/// <param name="opacity">The opacity to set.</param>
	//	void SetTextEntryPauseOpacity(int opacity);
	//
	//	/// <summary>
	//	/// Sets the text entry pause frame.
	//	/// </summary>
	//	/// <param name="frame">The frame to set.</param>
	//	void SetTextEntryPauseFrame(int frame);
	//
	//	/// <summary>
	//	/// Sets the text entry cursor opacity.
	//	/// </summary>
	//	/// <param name="opacity">The opacity to set.</param>
	//	void SetTextEntryCursorOpacity(int opacity);
	//
	//	/// <summary>
	//	/// Sets the text entry cursor rectangle.
	//	/// </summary>
	//	/// <param name="rect">The rectangle to set.</param>
	//	void SetTextEntryCursorRect(IWindowCursorRect rect);
	//
	//	/// <summary>
	//	/// Sets the maximum length of the text entry.
	//	/// </summary>
	//	/// <param name="length">The maximum length to set.</param>
	//	void SetMaxLength(int length);
	//
	//	/// <summary>
	//	/// Sets whether the text entry is password mode.
	//	/// </summary>
	//	/// <param name="password">Whether to enable password mode.</param>
	//	void SetPasswordMode(bool password);
	//
	//	/// <summary>
	//	/// Sets the password character.
	//	/// </summary>
	//	/// <param name="c">The character to set.</param>
	//	void SetPasswordChar(char c);
	//
	//	/// <summary>
	//	/// Shows the text entry window.
	//	/// </summary>
	//	void ShowTextEntry();
	//
	//	/// <summary>
	//	/// Hides the text entry window.
	//	/// </summary>
	//	void HideTextEntry();
	//
	//	/// <summary>
	//	/// Waits for text entry to complete.
	//	/// </summary>
	//	/// <returns>The entered text.</returns>
	//	string WaitForTextEntry();
	//}
}