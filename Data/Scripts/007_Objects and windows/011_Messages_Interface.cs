using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	public interface IMainMessage : IMain
	{
		bool MapInterpreterRunning();

		IInterpreter MapInterpreter();
		//	if (Game.GameData.GameMap && Game.GameData.GameMap.respond_to("interpreter")) {
		//		return Game.GameData.GameMap.interpreter;
		//	} else if (Game.GameData.GameSystem) {
		//		return Game.GameData.GameSystem.map_interpreter;
		//	}
		//	return null;
		//}

		void RefreshSceneMap();

		void UpdateSceneMap();
		// ########

		int? EventCommentInput(IGameCharacter @event, int elements, string trigger);

		int? CurrentEventCommentInput(int elements, string trigger);

		string GetBasicMapNameFromId(int id);

		string GetMapNameFromId(int id);

		string CsvField(ref string str);

		int CsvPosInt(ref string str);

		// internal function
		string GetGoldString();

		IWindow_AdvancedTextPokemon DisplayGoldWindow(IWindow msgwindow);

		IWindow_AdvancedTextPokemon DisplayCoinsWindow(IWindow msgwindow,IWindow goldwindow);

		IWindow_AdvancedTextPokemon CreateStatusWindow(IViewport viewport=null);

		IWindow_AdvancedTextPokemon CreateMessageWindow(IViewport viewport=null,int? skin=null);

		//ToDo: Return IDisposable?...
		void DisposeMessageWindow(IWindow msgwindow);

		void MessageDisplay(IWindow msgwindow,string message,bool letterbyletter=true,Action commandProc=null);

		int Message(string message,string[] commands=null,int cmdIfCancel=0,int? skin=null,int defaultCmd=0,Action block = null);

		bool ConfirmMessage(string message,Action block = null);

		bool ConfirmMessageSerious(string message,Action block = null);

		//int MessageChooseNumber(string message,string[] param,Action block = null);
		int MessageChooseNumber(string message,IChooseNumberParams param,Action block = null);

		int ShowCommands(IWindow msgwindow,string[] commands=null,int cmdIfCancel=0,int defaultCmd=0, Action block = null);

		int ShowCommandsWithHelp(IWindow msgwindow,string[] commands,string[] help,int cmdIfCancel=0,int defaultCmd=0, Action block = null);

		void MessageWaitForInput(IWindow msgwindow,int frames,bool showPause=false);

		string FreeText(IWindow msgwindow, string currenttext, IWindow passwordbox, int maxlength, int width = 240,Action block = null);

		void MessageFreeText(string message, string currenttext, IWindow passwordbox, int maxlength, int width = 240,Action block = null);



		//string  itemIconTag(Items item);
		string  itemIconTag(int item);

		IColor getSkinColor(IWindow windowskin,IColor color,bool isDarkSkin);

		// internal function
		void RepositionMessageWindow(IWindow msgwindow, int linecount=2);

		// internal function
		void UpdateMsgWindowPos(IWindow msgwindow,IGameEvent @event,bool eventChanged=false);


		int ButtonInputProcessing(int variableNumber = 0, int timeoutFrames = 0);

		int ChooseNumber(IWindow msgwindow, IChooseNumberParams param, Action block = null);

		void PositionFaceWindow(IWindow facewindow,IWindow msgwindow);

		void PositionNearMsgWindow(IWindow cmdwindow,IWindow msgwindow,bool side);
	}

	public interface IChooseNumberParams {
		IChooseNumberParams initialize();

		void setMessageSkin(int value);

		/// <summary>
		/// Set the full path for the message's window skin
		/// </summary>
		string messageSkin { get; }

		void setSkin(int value);

		string skin { get; }

		void setNegativesAllowed(bool value);

		void negativesAllowed();

		void setRange(int minNumber,int maxNumber);

		void setDefaultValue(int number);

		void setInitialValue(int number);

		void setCancelValue(int number);

		int initialNumber();

		int cancelNumber();

		int minNumber();

		int maxNumber();

		void setMaxDigits(int value);

		int maxDigits();

		//private;

		//void clamp(int v,int mn,int mx);

		//int numDigits(int number);
	}

	public interface IFaceWindowVX : ISpriteWindow_Base, IHaveUpdate, IDisposable
	{
		IFaceWindowVX initialize(string face);

		//void update();
		//void dispose();
	}

	/// <summary>
	/// Represents a message system for displaying text in the game.
	/// </summary>
	/// <remarks>
	/// This interface defines the functionality for managing messages in the game,
	/// including text display, formatting, and interaction.
	/// </remarks>
	//public interface IMessages
	//{
	//	/// <summary>
	//	/// Gets or sets the message window.
	//	/// </summary>
	//	IWindow MessageWindow { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the command window.
	//	/// </summary>
	//	IWindow CommandWindow { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the face window.
	//	/// </summary>
	//	IWindow FaceWindow { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message text.
	//	/// </summary>
	//	string MessageText { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message font.
	//	/// </summary>
	//	IFont MessageFont { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message text color.
	//	/// </summary>
	//	IColor MessageTextColor { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message text alignment.
	//	/// </summary>
	//	TextAlignment MessageTextAlignment { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message text speed.
	//	/// </summary>
	//	float MessageTextSpeed { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets whether the message is paused.
	//	/// </summary>
	//	bool MessagePause { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message pause opacity.
	//	/// </summary>
	//	int MessagePauseOpacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message pause frame.
	//	/// </summary>
	//	int MessagePauseFrame { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message cursor opacity.
	//	/// </summary>
	//	int MessageCursorOpacity { get; set; }
	//
	//	/// <summary>
	//	/// Gets or sets the message cursor rectangle.
	//	/// </summary>
	//	IWindowCursorRect MessageCursorRect { get; set; }
	//
	//	/// <summary>
	//	/// Initializes the message system.
	//	/// </summary>
	//	void Initialize();
	//
	//	/// <summary>
	//	/// Disposes of the message system and its resources.
	//	/// </summary>
	//	void Dispose();
	//
	//	/// <summary>
	//	/// Checks if the message system has been disposed.
	//	/// </summary>
	//	/// <returns>True if the message system has been disposed, false otherwise.</returns>
	//	bool IsDisposed();
	//
	//	/// <summary>
	//	/// Updates the message system's state.
	//	/// </summary>
	//	void Update();
	//
	//	/// <summary>
	//	/// Refreshes the message system's appearance.
	//	/// </summary>
	//	/// <param name="force_refresh">Whether to force a complete refresh.</param>
	//	void Refresh(bool force_refresh = false);
	//
	//	/// <summary>
	//	/// Sets the message window.
	//	/// </summary>
	//	/// <param name="window">The window to set.</param>
	//	void SetMessageWindow(IWindow window);
	//
	//	/// <summary>
	//	/// Sets the command window.
	//	/// </summary>
	//	/// <param name="window">The window to set.</param>
	//	void SetCommandWindow(IWindow window);
	//
	//	/// <summary>
	//	/// Sets the face window.
	//	/// </summary>
	//	/// <param name="window">The window to set.</param>
	//	void SetFaceWindow(IWindow window);
	//
	//	/// <summary>
	//	/// Sets the message text.
	//	/// </summary>
	//	/// <param name="text">The text to set.</param>
	//	void SetMessageText(string text);
	//
	//	/// <summary>
	//	/// Sets the message font.
	//	/// </summary>
	//	/// <param name="font">The font to set.</param>
	//	void SetMessageFont(IFont font);
	//
	//	/// <summary>
	//	/// Sets the message text color.
	//	/// </summary>
	//	/// <param name="color">The color to set.</param>
	//	void SetMessageTextColor(IColor color);
	//
	//	/// <summary>
	//	/// Sets the message text alignment.
	//	/// </summary>
	//	/// <param name="alignment">The alignment to set.</param>
	//	void SetMessageTextAlignment(TextAlignment alignment);
	//
	//	/// <summary>
	//	/// Sets the message text speed.
	//	/// </summary>
	//	/// <param name="speed">The speed to set.</param>
	//	void SetMessageTextSpeed(float speed);
	//
	//	/// <summary>
	//	/// Sets whether the message is paused.
	//	/// </summary>
	//	/// <param name="pause">Whether to pause the message.</param>
	//	void SetMessagePause(bool pause);
	//
	//	/// <summary>
	//	/// Sets the message pause opacity.
	//	/// </summary>
	//	/// <param name="opacity">The opacity to set.</param>
	//	void SetMessagePauseOpacity(int opacity);
	//
	//	/// <summary>
	//	/// Sets the message pause frame.
	//	/// </summary>
	//	/// <param name="frame">The frame to set.</param>
	//	void SetMessagePauseFrame(int frame);
	//
	//	/// <summary>
	//	/// Sets the message cursor opacity.
	//	/// </summary>
	//	/// <param name="opacity">The opacity to set.</param>
	//	void SetMessageCursorOpacity(int opacity);
	//
	//	/// <summary>
	//	/// Sets the message cursor rectangle.
	//	/// </summary>
	//	/// <param name="rect">The rectangle to set.</param>
	//	void SetMessageCursorRect(IWindowCursorRect rect);
	//
	//	/// <summary>
	//	/// Shows a message.
	//	/// </summary>
	//	/// <param name="text">The text to show.</param>
	//	/// <param name="face">The face to show, or null for none.</param>
	//	/// <param name="commands">The commands to show, or null for none.</param>
	//	void ShowMessage(string text, string face = null, string[] commands = null);
	//
	//	/// <summary>
	//	/// Hides the message.
	//	/// </summary>
	//	void HideMessage();
	//
	//	/// <summary>
	//	/// Waits for the message to be dismissed.
	//	/// </summary>
	//	void WaitForMessage();
	//
	//	/// <summary>
	//	/// Waits for a command to be selected.
	//	/// </summary>
	//	/// <returns>The index of the selected command.</returns>
	//	int WaitForCommand();
	//}
}