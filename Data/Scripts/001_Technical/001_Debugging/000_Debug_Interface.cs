using System;
using System.Linq;
using System.Linq.Expressions;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.EventArg;

namespace PokemonEssentials
{
	public interface IDebugger
	{
		//event EventHandler<EventArg.IOnDebugEventArgs> OnDebug;
		//event EventHandler<OnDebugEventArgs> OnLog;

		/// <summary>
		/// Create and open data stream to file used for storing log entries.
		/// </summary>
		/// <param name="logfilePath">File Directory</param>
		/// <param name="logBaseName">Name of the File</param>
		void Init(string logfilePath, string logBaseName);
		/// <summary>
		/// Silently writes into log file
		/// </summary>
		/// <param name="message"></param>
		void Log(string message, params object[] param);
		/// <summary>
		/// Silently writes verbose context into log file, along with stack trace.
		/// </summary>
		/// <remarks>
		/// Should use only if debug mode is enabled
		/// </remarks>
		/// <param name="message"></param>
		void LogVerbose(string message, params object[] param);
		/// <summary>
		/// Writes helpful informational text into log file.
		/// </summary>
		/// <param name="message"></param>
		void LogDebug(string message, params object[] param);
		/// <summary>
		/// Displays to user, but doesnt pause or interrupt game.
		/// Typically flashes on screen and goes away.
		/// </summary>
		/// <param name="message"></param>
		void LogWarning(string message, params object[] param);
		/// <summary>
		/// Pauses and interrupts game to be displayed to user.
		/// Typically responses to user commands.
		/// </summary>
		/// <param name="message"></param>
		void LogError(string message, params object[] param);
		/// <summary>
		/// Save and close data stream to file.
		/// </summary>
		void Shutdown();
	}

	namespace EventArg
	{
		/// <summary>
		/// </summary>
		/// <remarks>
		/// LogManager now also implements IDebugger which allows it to act as an IDebugger itself,
		/// facilitating direct logging or acting as a dispatch center, forwarding logs to other IDebugger instances.
		/// </remarks>
		public interface IOnDebugEventArgs : IEventArgs
		{
			//public static readonly int EventId = typeof(OnDebugEventArgs).GetHashCode();

			//int Id { get; }
			/// <summary>
			/// If debug flag is set to true, will add stack trace to output logs.
			/// if debug flag is set to false, will write to output logs but as informational (helpful).
			/// if debug flag is null, will write as debug but no stack trace in output logs.
			/// </summary>
			bool? Debug { get; set; }
			/// <summary>
			/// If true (error), pause/stop game to display error message on screen.
			/// If false (warning), display message on screen without pausing game.
			/// If null (debug), silently log message in background.
			/// </summary>
			bool? Error { get; set; }
			/// <summary>
			/// Message to log to console, file, and/or user
			/// </summary>
			string Message { get; set; }
			/// <summary>
			/// If message contains additional variables that get passed as input parameters for formatting.
			/// </summary>
			object[] MessageParameters { get; set; }
			/// <summary>
			/// Calling method that initiated the log response entry.
			/// </summary>
			System.Reflection.MethodBase Method { get; set; }
			/// <summary>
			/// Calling entity that initiated the log response entry.
			/// </summary>
			object Sender { get; set; }
		}
	}
}