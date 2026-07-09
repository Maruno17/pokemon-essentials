using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Graphics module extensions providing advanced scene transition capabilities.
    /// Supports numerous transition effects including breaking glass, rotating pieces, splash effects,
    /// directional scrolling, mosaic patterns, and specialized HGSS-style battle transitions.
    /// Manages transition timing, disposal, and frame rate synchronization.
    /// </summary>
    public interface IGraphicsTransitions : PokemonEssentials.RPGMaker.Kernel.Static.IGraphics, IHaveUpdate
    {
        /// <summary>
        /// Current active transition instance being processed.
        /// Null when no transition is active or after disposal.
        /// </summary>
        ITransitionEffect CurrentTransition { get; set; }

        /// <summary>
        /// Whether to pause graphics updates during transition execution.
        /// Ensures smooth transition playback without frame interference.
        /// </summary>
        bool StopWhileTransition { get; set; }

        /// <summary>
        /// Whether transition execution should be interrupted by external events.
        /// Used for emergency stops or scene changes during transitions.
        /// </summary>
        bool InterruptTransition { get; set; }

        /// <summary>
        /// Executes scene transition with specified duration, filename pattern, and vagueness.
        /// Converts duration from 1/20th second units to frames based on Graphics.frame_rate.
        /// Automatically detects transition type from filename and creates appropriate effect.
        /// </summary>
        /// <param name="duration">Duration in 1/20th second increments (default 8 = 0.4 seconds)</param>
        /// <param name="filename">Transition type identifier (e.g., "fadetoblack", "mosaic")</param>
        /// <param name="vague">Vagueness factor for transition edge softness (default 20)</param>
        void transition(int duration = 8, string filename = "", int vague = 20);

        /// <summary>
        /// Updates graphics system and processes active transition animation.
        /// Calls base graphics update, advances transition frame, and handles disposal.
        /// Must be called each frame for proper transition progression.
        /// </summary>
        void update();

        /// <summary>
        /// Analyzes transition filename to determine type and creates appropriate transition effect.
        /// Handles specialized transitions: breaking glass, rotating pieces, scrolling, HGSS effects.
        /// Converts duration to seconds and instantiates matching transition class.
        /// </summary>
        /// <param name="duration">Transition duration in 1/20th second units</param>
        /// <param name="filename">Transition identifier filename</param>
        /// <returns>True if special transition was created, false for default transition</returns>
        bool judge_special_transition(double duration, string filename);
    }

    /// <summary>
    /// Base interface for all transition effect implementations.
    /// Provides common lifecycle management and animation processing.
    /// </summary>
    public interface ITransitionEffect : IHaveUpdate, IDisposable
    {
        ITransitionEffect intiailize(int duration);
        void new_sprite(int x, int y, IBitmap bitmap, int ox = 0, int oy = 0);

        int timer { get; }
        /// <summary>
        /// Whether this transition effect has been disposed and is no longer active.
        /// </summary>
        //bool disposed { get; }

        /// <summary>
        /// Advances transition animation by one frame.
        /// Handles timing calculations, visual effects, and completion detection.
        /// </summary>
        void update();
        void initialize_bitmaps();
        void initialize_sprites();
        void set_up_timings();
        void dispose_all();
        void update_anim();
    }

    /// <summary>
    /// Breaking glass transition effect with shatter animation.
    /// Creates visual effect of screen shattering like breaking glass.
    /// </summary>
    public interface ISceneTransitionBreakingGlass : ITransitionEffect
    {
        /// <summary>
        /// Duration of glass breaking animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Rotating or shrinking pieces transition with configurable rotation.
    /// Creates effect of screen breaking into pieces that rotate or shrink away.
    /// </summary>
    public interface ISceneTransitionShrinkingPieces : ITransitionEffect
    {
        /// <summary>
        /// Duration of pieces animation in seconds.
        /// </summary>
        double Duration { get; }

        /// <summary>
        /// Whether pieces should rotate during animation.
        /// </summary>
        bool ShouldRotate { get; }
    }

    /// <summary>
    /// Splash transition creating ripple or wave effects.
    /// Simulates liquid splash spreading across screen.
    /// </summary>
    public interface ISceneTransitionSplash : ITransitionEffect
    {
        /// <summary>
        /// Duration of splash animation in seconds.
        /// </summary>
        double Duration { get; }

        /// <summary>
        /// Splash intensity factor affecting spread speed.
        /// </summary>
        double Intensity { get; }
    }

    /// <summary>
    /// Random stripe transition with vertical or horizontal orientation.
    /// Creates effect of random strips revealing or concealing content.
    /// </summary>
    public interface ISceneTransitionRandomStripe : ITransitionEffect
    {
        /// <summary>
        /// Duration of stripe animation in seconds.
        /// </summary>
        double Duration { get; }

        /// <summary>
        /// Stripe orientation: 0 = vertical, 1 = horizontal.
        /// </summary>
        int Orientation { get; }
    }

    /// <summary>
    /// Zoom in transition effect scaling content toward center.
    /// Creates focusing or magnification visual effect.
    /// </summary>
    public interface ISceneTransitionZoomIn : ITransitionEffect
    {
        /// <summary>
        /// Duration of zoom animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Screen scrolling transition in specified direction.
    /// Supports 8-directional scrolling including diagonal movement.
    /// </summary>
    public interface ISceneTransitionScrollScreen : ITransitionEffect
    {
        /// <summary>
        /// Duration of scroll animation in seconds.
        /// </summary>
        double Duration { get; }

        /// <summary>
        /// Scroll direction: 1=down-left, 2=down, 3=down-right, 4=left, 6=right, 7=up-left, 8=up, 9=up-right.
        /// </summary>
        int Direction { get; }
    }

    /// <summary>
    /// Mosaic transition creating pixelated block effect.
    /// Gradually increases or decreases mosaic tile size for transition.
    /// </summary>
    public interface ISceneTransitionMosaic : ITransitionEffect
    {
        /// <summary>
        /// Duration of mosaic animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Snake squares transition creating serpentine reveal pattern.
    /// Specialized HGSS-style transition with snake-like progression.
    /// </summary>
    public interface ISceneTransitionSnakeSquares : ITransitionEffect
    {
        /// <summary>
        /// Duration of snake squares animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Diagonal bubble transition with corner-based expansion.
    /// Creates bubble effect emanating from specified screen corner.
    /// </summary>
    public interface ISceneTransitionDiagonalBubble : ITransitionEffect
    {
        /// <summary>
        /// Duration of bubble animation in seconds.
        /// </summary>
        double Duration { get; }

        /// <summary>
        /// Starting corner: 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right.
        /// </summary>
        int Corner { get; }
    }

    /// <summary>
    /// Rising splash transition with upward movement effect.
    /// Creates effect of liquid or energy rising from bottom of screen.
    /// </summary>
    public interface ISceneTransitionRisingSplash : ITransitionEffect
    {
        /// <summary>
        /// Duration of rising splash animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Two ball pass transition for battle scene changes.
    /// HGSS-style transition with two circular elements passing across screen.
    /// </summary>
    public interface ISceneTransitionTwoBallPass : ITransitionEffect
    {
        /// <summary>
        /// Duration of two ball pass animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Spinning ball split transition creating rotation and division effect.
    /// Ball element spins and splits during transition.
    /// </summary>
    public interface ISceneTransitionSpinBallSplit : ITransitionEffect
    {
        /// <summary>
        /// Duration of spin ball split animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Three ball down transition with multiple descending elements.
    /// Three ball elements move downward during transition.
    /// </summary>
    public interface ISceneTransitionThreeBallDown : ITransitionEffect
    {
        /// <summary>
        /// Duration of three ball down animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Single ball down transition with descending ball element.
    /// Simple ball element moves down during transition.
    /// </summary>
    public interface ISceneTransitionBallDown : ITransitionEffect
    {
        /// <summary>
        /// Duration of ball down animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Wavy three ball up transition with wave motion and upward movement.
    /// Three ball elements move upward with wave-like motion.
    /// </summary>
    public interface ISceneTransitionWavyThreeBallUp : ITransitionEffect
    {
        /// <summary>
        /// Duration of wavy three ball up animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Wavy spin ball transition combining wave motion with rotation.
    /// Single ball element spins with wave-like movement pattern.
    /// </summary>
    public interface ISceneTransitionWavySpinBall : ITransitionEffect
    {
        /// <summary>
        /// Duration of wavy spin ball animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Four ball burst transition with explosive expansion effect.
    /// Four ball elements burst outward from center.
    /// </summary>
    public interface ISceneTransitionFourBallBurst : ITransitionEffect
    {
        /// <summary>
        /// Duration of four ball burst animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// VS Trainer transition for trainer battle introductions.
    /// Specialized transition for trainer versus screen presentation.
    /// </summary>
    public interface ISceneTransitionVSTrainer : ITransitionEffect
    {
        /// <summary>
        /// Duration of VS trainer animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// VS Elite Four transition for Elite Four battle introductions.
    /// Enhanced VS transition for Elite Four encounters.
    /// </summary>
    public interface ISceneTransitionVSEliteFour : ITransitionEffect
    {
        /// <summary>
        /// Duration of VS Elite Four animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Rocket Grunt transition for Team Rocket encounters.
    /// Themed transition for Rocket Grunt battle introductions.
    /// </summary>
    public interface ISceneTransitionRocketGrunt : ITransitionEffect
    {
        /// <summary>
        /// Duration of Rocket Grunt animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// VS Rocket Admin transition for Rocket Admin battle introductions.
    /// Enhanced Rocket-themed transition for admin encounters.
    /// </summary>
    public interface ISceneTransitionVSRocketAdmin : ITransitionEffect
    {
        /// <summary>
        /// Duration of VS Rocket Admin animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Fade to black transition creating smooth blackout effect.
    /// Standard fade transition darkening screen to complete black.
    /// </summary>
    public interface ISceneTransitionFadeToBlack : ITransitionEffect
    {
        /// <summary>
        /// Duration of fade to black animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Fade from black transition revealing content from black screen.
    /// Standard fade transition brightening from black to full visibility.
    /// </summary>
    public interface ISceneTransitionFadeFromBlack : ITransitionEffect
    {
        /// <summary>
        /// Duration of fade from black animation in seconds.
        /// </summary>
        double Duration { get; }
    }

    /// <summary>
    /// Transition direction enumeration for directional effects.
    /// </summary>
    public enum TransitionDirection
    {
        DownLeft = 1,
        Down = 2,
        DownRight = 3,
        Left = 4,
        Right = 6,
        UpLeft = 7,
        Up = 8,
        UpRight = 9
    }

    /// <summary>
    /// Corner positions for corner-based transition effects.
    /// </summary>
    public enum TransitionCorner
    {
        TopLeft = 0,
        TopRight = 1,
        BottomLeft = 2,
        BottomRight = 3
    }

    /// <summary>
    /// Orientation for stripe-based transitions.
    /// </summary>
    public enum StripeOrientation
    {
        Vertical = 0,
        Horizontal = 1
    }
}