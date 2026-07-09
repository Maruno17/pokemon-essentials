using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// This class handles data surrounding the system. Background music, etc.
    /// is managed here as well. Refer to "Game.GameData.game_system" for the instance of
    /// this class.
    /// </summary>
    public interface IGameSystem : IHaveUpdate {
        /// <summary>Map event interpreter.</summary>
        IInterpreter map_interpreter { get; }

        /// <summary>Battle event interpreter.</summary>
        IInterpreter battle_interpreter { get; }

        /// <summary>
        /// The game's internal playtime (<see cref="IGameStats.play_time"/>) when the timer was started, or <c>null</c> if not started.
        /// </summary>
        double? timer_start { get; set; } // Ruby uses integers for time, but C# System.TimeSpan uses double for TotalSeconds. User specified 'double for time'.

        /// <summary>Time (in seconds) the timer is initially set to.</summary>
        double timer_duration { get; set; } // Using double for consistency with timer_start

        /// <summary>Save forbidden.</summary>
        bool save_disabled { get; set; }

        /// <summary>Menu forbidden.</summary>
        bool menu_disabled { get; set; }

        /// <summary>Encounter forbidden.</summary>
        bool encounter_disabled { get; set; }

        /// <summary>Text option: positioning (0: top, 1: middle, 2: bottom).</summary>
        int message_position { get; set; }

        /// <summary>Text option: window frame (0: normal, 1: alternative).</summary>
        int message_frame { get; set; }

        /// <summary>Save count.</summary>
        int save_count { get; set; } // Your C# interface used int?, Ruby used int. Sticking to int from Ruby.

        /// <summary>Magic number.</summary>
        int magic_number { get; set; }

        /// <summary>Speed for autoscrolling map background X-axis.</summary>
        int autoscroll_x_speed { get; set; }

        /// <summary>Speed for autoscrolling map background Y-axis.</summary>
        int autoscroll_y_speed { get; set; }

        /// <summary>Current playback position of the BGM, in seconds or samples, depending on audio engine.</summary>
        double bgm_position { get; set; } // Changed to double to align with audio positioning that's often float/double

        /// <summary>Current playback position of the BGS.</summary>
        double bgs_position { get; set; } // Added based on your C# versions

        /// <summary>The background music to play during battles.</summary>
        IAudioBGM battle_bgm { get; set; } // attr_writer implies get; set; Ruby has a custom getter.

        /// <summary>The music effect to play when a battle ends.</summary>
        IAudioME battle_end_me { get; set; } // attr_writer implies get; set; Ruby has a custom getter.

        /// <summary>The name of the windowskin file to use.</summary>
        string windowskin_name { get; set; } // attr_writer implies get; set; Ruby has a custom getter.

        /// <summary>The currently playing background music.</summary>
        IAudioBGM playing_bgm { get; }

        /// <summary>The currently playing background sound.</summary>
        IAudioBGS playing_bgs { get; }

        /// <summary>The memorized background sound.</summary>
        IAudioBGS memorized_bgs { get; } // Added from your C# interface, Ruby has @memorized_bgs in bgs_memorize

        /// <summary>
        /// Initializes the game system.
        /// </summary>
        void initialize();

        /// <summary>
        /// Gets the remaining time on the timer in seconds.
        /// </summary>
        /// <returns>Remaining time in seconds.</returns>
        double timer(); // Ruby method is [timer], your C# version used `GetTimer`. Sticking to [timer] from Ruby. Returns double.

        /// <summary>
        /// Starts playing a BGM.
        /// </summary>
        /// <param name="bgm">The BGM to play. Can be an <see cref="IAudioBGM"/> object or a string filename.</param>
        /// <param name="track">Optional track number for multi-track audio systems.</param>
        void bgm_play(IAudioBGM bgm, int? track = null);
        //void bgm_play(string bgm_name, int volume = 80, int pitch = 100, int? track = null); // Consider adding if direct filename play is needed and differs from setDefaultBGM logic

        /// <summary>
        /// Internal method for playing BGM. Marked as internal or to be used with caution.
        /// </summary>
        void bgm_play_internal2(string name, float volume, float pitch, double position, int? track = null); // position changed to double

        /// <summary>
        /// Internal method for playing BGM. Marked as internal or to be used with caution.
        /// </summary>
        void bgm_play_internal(IAudioBGM bgm, double position, int? track = null); // position changed to double

        /// <summary>
        /// Pauses the BGM with an optional fade-out time.
        /// </summary>
        /// <param name="fadetime">Time in seconds for the BGM to fade out.</param>
        void bgm_pause(double fadetime = 0.0);

        /// <summary>
        /// Unpauses the BGM.
        /// </summary>
        void bgm_unpause();

        /// <summary>
        /// Resumes a paused BGM.
        /// </summary>
        /// <param name="bgm">The BGM to resume.</param>
        void bgm_resume(IAudioBGM bgm);

        /// <summary>
        /// Stops the BGM.
        /// </summary>
        /// <param name="track">Optional track number.</param>
        void bgm_stop(int? track = null);

        /// <summary>
        /// Fades out the BGM over a specified time.
        /// </summary>
        /// <param name="time">Time in seconds for the fade-out.</param>
        /// <param name="track">Optional track number.</param>
        void bgm_fade(double time, int? track = null);

        /// <summary>
        /// Saves the currently playing background music for later playback.
        /// </summary>
        void bgm_memorize();

        /// <summary>
        /// Plays the currently memorized background music.
        /// </summary>
        void bgm_restore();

        /// <summary>
        /// Returns an <see cref="IAudioBGM"/> object for the currently playing background music.
        /// </summary>
        /// <returns>The currently playing BGM, or <c>null</c> if none.</returns>
        IAudioBGM getPlayingBGM(); // Name kept as is from Ruby

        /// <summary>
        /// Sets a BGM as the default to play, or reverts to system default if <paramref name="bgm"/> is <c>null</c> or empty.
        /// </summary>
        /// <param name="bgm">The <see cref="IAudioBGM"/> object to set as default.</param>
        void setDefaultBGM(IAudioBGM bgm); // Ruby has volume/pitch here, but they are unused if 'bgm' is an object.

        /// <summary>
        /// Sets a BGM by filename as the default to play.
        /// </summary>
        /// <param name="bgm_name">Filename of the BGM.</param>
        /// <param name="volume">Volume (default 80).</param>
        /// <param name="pitch">Pitch (default 100).</param>
        void setDefaultBGM(string bgm_name, int volume = 80, int pitch = 100); // Parameters from Ruby string overload

        /// <summary>
        /// Plays a music effect (ME).
        /// </summary>
        /// <param name="me">The <see cref="IAudioME"/> object or filename to play.</param>
        void me_play(IAudioME me);

        /// <summary>
        /// Plays a music effect (ME) by filename.
        /// </summary>
        /// <param name="me_name">Filename of the ME.</param>
        /// <param name="volume">Volume (default 80).</param>
        /// <param name="pitch">Pitch (default 100).</param>
        void me_play(string me_name, int volume = 80, int pitch = 100);

        /// <summary>
        /// Plays a background sound (BGS).
        /// </summary>
        /// <param name="bgs">The <see cref="IAudioBGS"/> object or filename to play.</param>
        void bgs_play(IAudioBGS bgs);
        // void bgs_play(string bgs_name, int volume = 80, int pitch = 100); // Consider if needed

        /// <summary>
        /// Pauses the BGS with an optional fade-out time.
        /// </summary>
        /// <param name="fadetime">Time in seconds for the BGS to fade out.</param>
        void bgs_pause(double fadetime = 0.0);

        /// <summary>
        /// Unpauses the BGS.
        /// </summary>
        void bgs_unpause();

        /// <summary>
        /// Resumes a paused BGS.
        /// </summary>
        /// <param name="bgs">The BGS to resume.</param>
        void bgs_resume(IAudioBGS bgs);

        /// <summary>
        /// Stops the BGS.
        /// </summary>
        void bgs_stop();

        /// <summary>
        /// Fades out the BGS over a specified time.
        /// </summary>
        /// <param name="time">Time in seconds for the fade-out.</param>
        void bgs_fade(double time);

        /// <summary>
        /// Saves the currently playing background sound for later playback.
        /// </summary>
        void bgs_memorize();

        /// <summary>
        /// Plays the currently memorized background sound.
        /// </summary>
        void bgs_restore();

        /// <summary>
        /// Returns an <see cref="IAudioBGS"/> object for the currently playing background sound.
        /// </summary>
        /// <returns>The currently playing BGS, or <c>null</c> if none.</returns>
        IAudioBGS getPlayingBGS(); // Name kept as is from Ruby

        /// <summary>
        /// Plays a sound effect (SE).
        /// </summary>
        /// <param name="se">The <see cref="IAudioSE"/> object or filename to play.</param>
        void se_play(IAudioSE se);

        /// <summary>
        /// Plays a sound effect (SE) by filename.
        /// </summary>
        /// <param name="se_name">Filename of the SE.</param>
        /// <param name="volume">Volume (default 80).</param>
        /// <param name="pitch">Pitch (default 100).</param>
        void se_play(string se_name, int volume = 80, int pitch = 100);

        /// <summary>
        /// Stops all sound effects.
        /// </summary>
        void se_stop();

        /// <summary>
        /// This method is called once per frame. It is not used by <c>Game_System</c>.
        /// </summary>
        void update();
    }
}