using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Comprehensive audio playback system supporting BGM, BGS, ME, and SE audio types.
	/// Handles audio file parsing, volume/pitch control, and playback management with format detection.
	/// Supports string-based audio parameters with embedded volume and pitch notation.
	/// </summary>
	public interface IMainAudioPlay : IMain
	{
		/// <summary>
		/// Converts string representation to audio file object with volume and pitch parsing.
		/// Supports formats: "filename", "filename:volume", "filename:volume:pitch".
		/// Automatically sets default values for missing parameters.
		/// </summary>
		/// <param name="audioString">String in format "file[:volume[:pitch]]"</param>
		/// <returns>Audio file object with parsed parameters</returns>
		IAudioObject StringToAudioFile(string audioString);

		/// <summary>
		/// Resolves various audio parameter formats into standardized audio file object.
		/// Handles string parsing, existing AudioFile objects, and parameter overrides.
		/// Provides unified interface for all audio parameter input methods.
		/// </summary>
		/// <param name="audioParam">String path or existing AudioFile object</param>
		/// <param name="volume">Volume override (0-100), null to use existing</param>
		/// <param name="pitch">Pitch override (typically 100 = normal), null to use existing</param>
		/// <returns>Resolved audio file object with final parameters</returns>
		IAudioObject ResolveAudioFile(IAudioObject audioParam, int? volume = null, int? pitch = null);

		/// <summary>
		/// Starts background music playback with automatic game system integration.
		/// Attempts game system playback first, falls back to direct audio if unavailable.
		/// Handles file path resolution relative to Audio/BGM/ directory.
		/// </summary>
		/// <param name="audioParam">Audio file specification (string or AudioFile)</param>
		/// <param name="volume">Playback volume (0-100), overrides embedded volume</param>
		/// <param name="pitch">Playback pitch (100 = normal), overrides embedded pitch</param>
		void BGMPlay(IAudioBGM audioParam, int? volume = null, int? pitch = null);

		/// <summary>
		/// Gradually fades out background music over specified duration.
		/// Provides smooth audio transition for scene changes and dramatic effect.
		/// </summary>
		/// <param name="timeInSeconds">Fade duration in seconds (0 for immediate stop)</param>
		void BGMFade(double timeInSeconds = 0.0);

		/// <summary>
		/// Stops or fades out background music playback.
		/// Integrates with game system for proper state management and crossfading.
		/// </summary>
		/// <param name="timeInSeconds">Fade out duration in seconds (0 for immediate stop)</param>
		void BGMStop(double timeInSeconds = 0.0);

		/// <summary>
		/// Plays music effect (ME) audio that temporarily interrupts background music.
		/// ME files typically play once and restore previous BGM upon completion.
		/// Handles file path resolution relative to Audio/ME/ directory.
		/// </summary>
		/// <param name="audioParam">Audio file specification (string or AudioFile)</param>
		/// <param name="volume">Playback volume (0-100), overrides embedded volume</param>
		/// <param name="pitch">Playback pitch (100 = normal), overrides embedded pitch</param>
		void MEPlay(IAudioME audioParam, int? volume = null, int? pitch = null);

		/// <summary>
		/// Gradually fades out music effect over specified duration.
		/// Allows smooth transition when interrupting ME playback.
		/// </summary>
		/// <param name="timeInSeconds">Fade duration in seconds (0 for immediate stop)</param>
		void MEFade(double timeInSeconds = 0.0);

		/// <summary>
		/// Stops or fades out music effect playback.
		/// Properly manages ME state and BGM restoration timing.
		/// </summary>
		/// <param name="timeInSeconds">Fade out duration in seconds (0 for immediate stop)</param>
		void MEStop(double timeInSeconds = 0.0);

		/// <summary>
		/// Starts background sound (BGS) playback for ambient audio loops.
		/// BGS typically provides environmental sounds that loop continuously.
		/// Handles file path resolution relative to Audio/BGS/ directory.
		/// </summary>
		/// <param name="audioParam">Audio file specification (string or AudioFile)</param>
		/// <param name="volume">Playback volume (0-100), overrides embedded volume</param>
		/// <param name="pitch">Playback pitch (100 = normal), overrides embedded pitch</param>
		void BGSPlay(IAudioBGS audioParam, int? volume = null, int? pitch = null);

		/// <summary>
		/// Gradually fades out background sound over specified duration.
		/// Provides smooth ambient audio transitions.
		/// </summary>
		/// <param name="timeInSeconds">Fade duration in seconds (0 for immediate stop)</param>
		void BGSFade(double timeInSeconds = 0.0);

		/// <summary>
		/// Stops or fades out background sound playback.
		/// Manages BGS state with proper cleanup and fade handling.
		/// </summary>
		/// <param name="timeInSeconds">Fade out duration in seconds (0 for immediate stop)</param>
		void BGSStop(double timeInSeconds = 0.0);

		/// <summary>
		/// Plays sound effect (SE) for immediate audio feedback.
		/// SE files are typically short, non-looping sounds for UI and game events.
		/// Handles file path resolution relative to Audio/SE/ directory.
		/// </summary>
		/// <param name="audioParam">Audio file specification (string or AudioFile)</param>
		/// <param name="volume">Playback volume (0-100), overrides embedded volume</param>
		/// <param name="pitch">Playback pitch (100 = normal), overrides embedded pitch</param>
		void SEPlay(IAudioSE audioParam, int? volume = null, int? pitch = null);

		/// <summary>
		/// Attempts to fade out sound effect over specified duration.
		/// Note: Most SE implementations only support immediate stop due to short duration.
		/// </summary>
		/// <param name="timeInSeconds">Fade duration in seconds (usually ignored for SE)</param>
		void SEFade(double timeInSeconds = 0.0);

		/// <summary>
		/// Immediately stops all sound effect playback.
		/// Clears SE channel to prevent audio overlap and ensure clean state.
		/// </summary>
		/// <param name="timeInSeconds">Fade duration (ignored for SE, always immediate)</param>
		void SEStop(double timeInSeconds = 0.0);

		/// <summary>
		/// Plays standard cursor movement sound effect for UI navigation.
		/// Uses system-defined cursor SE or fallback "GUI sel cursor" sound.
		/// Provides consistent audio feedback for menu navigation.
		/// </summary>
		void PlayCursorSE();

		/// <summary>
		/// Plays confirmation sound effect for menu selection and decision making.
		/// Uses system-defined decision SE or fallback "GUI sel decision" sound.
		/// Indicates successful choice confirmation to player.
		/// </summary>
		void PlayDecisionSE();

		/// <summary>
		/// Plays cancellation sound effect for backing out of menus and canceling actions.
		/// Uses system-defined cancel SE or fallback "GUI sel cancel" sound.
		/// Provides audio feedback for cancel/back operations.
		/// </summary>
		void PlayCancelSE();

		/// <summary>
		/// Plays buzzer sound effect for invalid actions and error conditions.
		/// Uses system-defined buzzer SE or fallback "GUI sel buzzer" sound.
		/// Indicates to player that attempted action is not allowed.
		/// </summary>
		void PlayBuzzerSE();

		/// <summary>
		/// Plays menu close sound effect when exiting menus and dialog boxes.
		/// Uses "GUI menu close" sound to provide closure feedback.
		/// Helps establish clear menu state transitions for user experience.
		/// </summary>
		void PlayCloseMenuSE();
	}

	/// <summary>
	/// Game system interface for integrated audio management.
	/// Provides higher-level audio control with state management.
	/// </summary>
	//public interface IGameSystem
	//{
	//	/// <summary>
	//	/// Plays BGM through game system with state tracking.
	//	/// </summary>
	//	/// <param name="audioFile">Audio file to play</param>
	//	void bgm_play(IAudioObject audioFile);
	//
	//	/// <summary>
	//	/// Stops BGM through game system.
	//	/// </summary>
	//	void bgm_stop();
	//
	//	/// <summary>
	//	/// Fades BGM over specified time.
	//	/// </summary>
	//	/// <param name="timeInSeconds">Fade duration</param>
	//	void bgm_fade(double timeInSeconds);
	//
	//	/// <summary>
	//	/// Plays ME through game system.
	//	/// </summary>
	//	/// <param name="audioFile">Audio file to play</param>
	//	void me_play(IAudioObject audioFile);
	//
	//	/// <summary>
	//	/// Stops ME through game system.
	//	/// </summary>
	//	/// <param name="audioFile">Audio file parameter (can be null)</param>
	//	void me_stop(IAudioObject audioFile);
	//
	//	/// <summary>
	//	/// Fades ME over specified time.
	//	/// </summary>
	//	/// <param name="timeInSeconds">Fade duration</param>
	//	void me_fade(double timeInSeconds);
	//
	//	/// <summary>
	//	/// Plays BGS through game system.
	//	/// </summary>
	//	/// <param name="audioFile">Audio file to play (null to stop)</param>
	//	void bgs_play(IAudioBGS audioFile);
	//
	//	/// <summary>
	//	/// Fades BGS over specified time.
	//	/// </summary>
	//	/// <param name="timeInSeconds">Fade duration</param>
	//	void bgs_fade(double timeInSeconds);
	//
	//	/// <summary>
	//	/// Plays SE through game system.
	//	/// </summary>
	//	/// <param name="audioFile">Audio file to play</param>
	//	void se_play(IAudioSE audioFile);
	//
	//	/// <summary>
	//	/// Stops SE through game system.
	//	/// </summary>
	//	void se_stop();
	//}

	/// <summary>
	/// System data containing default UI sound effects.
	/// Provides standardized audio for common UI interactions.
	/// </summary>
	//public interface ISystemData
	//{
	//	/// <summary>
	//	/// Default cursor movement sound effect.
	//	/// </summary>
	//	IAudioSE cursor_se { get; }
	//
	//	/// <summary>
	//	/// Default decision/confirmation sound effect.
	//	/// </summary>
	//	IAudioSE decision_se { get; }
	//
	//	/// <summary>
	//	/// Default cancel/back sound effect.
	//	/// </summary>
	//	IAudioSE cancel_se { get; }
	//
	//	/// <summary>
	//	/// Default buzzer/error sound effect.
	//	/// </summary>
	//	IAudioSE buzzer_se { get; }
	//}

	/// <summary>
	/// Represents an RPG audio file with name, volume, and pitch parameters.
	/// Standard audio object used throughout the RPG framework.
	/// </summary>
	//public interface IAudioFile
	//{
	//    /// <summary>
	//    /// Audio file name/path relative to appropriate audio directory.
	//    /// </summary>
	//    string name { get; set; }
	//
	//    /// <summary>
	//    /// Playback volume level (0-100).
	//    /// </summary>
	//    int volume { get; set; }
	//
	//    /// <summary>
	//    /// Playback pitch adjustment (100 = normal speed/pitch).
	//    /// </summary>
	//    int pitch { get; set; }
	//}

	/// <summary>
	/// Flexible audio parameter that can be string path or AudioFile object.
	/// Allows unified handling of different audio input formats.
	/// </summary>
	public interface IAudioParameter
	{
		/// <summary>
		/// Whether this parameter is a string path.
		/// </summary>
		bool IsString { get; }

		/// <summary>
		/// Whether this parameter is an AudioFile object.
		/// </summary>
		bool IsAudioFile { get; }

		/// <summary>
		/// Gets parameter as string (if IsString is true).
		/// </summary>
		string AsString { get; }

		/// <summary>
		/// Gets parameter as AudioFile (if IsAudioFile is true).
		/// </summary>
		IAudioObject AsAudioFile { get; }
	}
}