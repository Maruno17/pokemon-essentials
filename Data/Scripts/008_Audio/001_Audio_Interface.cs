using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Audio file duration analysis system supporting WAV, MP3, and OGG formats.
	/// Provides precise audio file timing information for playlist management and playback control.
	/// </summary>
	public interface IMainAudio : IMain
	{
		/// <summary>
		/// Reads OGG page header and structure information from audio file stream.
		/// Parses OGG container format to extract page metadata and payload size.
		/// </summary>
		/// <param name="file">Open file stream positioned at potential OGG page</param>
		/// <returns>OGG page data structure with header info and body size</returns>
		IOggPage getOggPage(System.IO.Stream file); //IFileStream

		/// <summary>
		/// Calculates total playback duration of OGG Vorbis audio file in seconds.
		/// Analyzes all OGG pages to determine PCM sample length and sample rate.
		/// </summary>
		/// <param name="file">Open OGG file stream to analyze</param>
		/// <returns>Duration in seconds, -1 if file is invalid or corrupted</returns>
		double oggfiletime(System.IO.Stream file); //IFileStream

		/// <summary>
		/// Determines audio file duration with automatic format detection.
		/// Attempts to find file with common audio extensions if exact path doesn't exist.
		/// Supports .wav, .mp3, and .ogg file formats.
		/// </summary>
		/// <param name="filename">Base filename to check (without extension)</param>
		/// <returns>Audio duration in seconds, 0 if file not found</returns>
		double getPlayTime(string filename);

		/// <summary>
		/// Analyzes specific audio file to determine precise playback duration.
		/// Handles WAV (RIFF), OGG Vorbis, and MP3 (MPEG Layer 3) format detection and parsing.
		/// Calculates duration based on file format specifications and bitrate analysis.
		/// </summary>
		/// <param name="filename">Full path to audio file to analyze</param>
		/// <returns>Duration in seconds, -1 if file invalid or format unsupported</returns>
		double getPlayTime2(string filename);
	}

	/// <summary>
	/// Represents OGG page structure with header and body information.
	/// Contains metadata needed for OGG stream parsing and duration calculation.
	/// </summary>
	public interface IOggPageData
	{
		/// <summary>
		/// OGG page header containing stream metadata and flags.
		/// </summary>
		byte[] Header { get; }

		/// <summary>
		/// File position where page body starts.
		/// </summary>
		long BodyStart { get; }

		/// <summary>
		/// Size of page body in bytes.
		/// </summary>
		int BodySize { get; }

		/// <summary>
		/// File position where next page begins.
		/// </summary>
		long NextPageStart { get; }
	}

	/// <summary>
	/// Represents an OGG page with header information and position data.
	/// </summary>
	public interface IOggPage
	{
		/// <summary>
		/// The page header data.
		/// </summary>
		byte[] header { get; set; }

		/// <summary>
		/// The position in the file where the page data starts.
		/// </summary>
		long position { get; set; }

		/// <summary>
		/// The size of the page body in bytes.
		/// </summary>
		int bodysize { get; set; }

		/// <summary>
		/// The position where the page ends.
		/// </summary>
		long endPosition { get; set; }
	}

	/// <summary>
	/// Represents a file stream for audio file reading operations.
	/// Provides low-level file access needed for format-specific parsing.
	/// </summary>
	public interface IFileStream : IDisposable
	{
		/// <summary>
		/// Current position in the file stream.
		/// </summary>
		long Position { get; set; }

		/// <summary>
		/// Whether end of file has been reached.
		/// </summary>
		bool IsEndOfFile { get; }

		/// <summary>
		/// Reads specified number of bytes from current position.
		/// </summary>
		/// <param name="count">Number of bytes to read</param>
		/// <returns>Byte array of read data</returns>
		byte[] Read(int count);
	}
}