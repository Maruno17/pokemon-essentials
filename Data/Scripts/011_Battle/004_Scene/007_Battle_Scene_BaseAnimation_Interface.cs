using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the base class of all hardcoded battle animations.
    /// </summary>
    public interface IAnimation : IHaveUpdate, IDisposable
    {
        /// <summary>Initializes the animation with sprites and viewport.</summary>
        void Initialize(IList<ISprite> sprites, IViewport viewport);
        /// <summary>Disposes the animation and its resources.</summary>
        void Dispose();
        /// <summary>Creates the animation processes.</summary>
        void CreateProcesses();
        /// <summary>Returns whether the animation is empty.</summary>
        bool Empty();
        /// <summary>Returns whether the animation is done.</summary>
        bool AnimDone();
        /// <summary>Adds a sprite to the animation.</summary>
        //IPictureEx AddSprite(ISprite s, PictureOrigin origin = PictureOrigin.TopLeft);
        IPictureEx AddSprite(ISprite s, int origin = 0);
        /// <summary>Adds a new sprite to the animation.</summary>
        //IPictureEx AddNewSprite(int x, int y, string name, PictureOrigin origin = PictureOrigin.TopLeft);
        IPictureEx AddNewSprite(int x, int y, string name, int origin = 0);
        /// <summary>Updates the animation state.</summary>
        void Update();
    }

    /// <summary>
    /// Mixin interface for ball animation effects in battle animations.
    /// </summary>
    public interface IBallAnimationMixin
    {
        /// <summary>
        /// </summary>
        /// <remarks>
        /// NOTE: This array makes the Ball Burst animation differ between types of Poké
        ///       Ball in certain simple ways. The HGSS animations occasionally have
        ///       additional differences, which haven't been coded yet in Essentials as
        ///       they're more complex and I couldn't be bothered.
        /// </remarks>
        /// <example>
        /// key: PokeBallType, and value:
        /// [top glare filename, top particle start tone, top particle end tone,
        ///  middle glare filename, middle glare start tone, middle glare end tone,
        ///  bottom glare filename, bottom glare start tone, bottom glare end tone,
        ///  top particle filename, top particle start tone, top particle end tone,
        ///  bottom particle filename, bottom particle start tone, bottom particle end tone,
        ///  ring tone start, ring tone end]
        /// </example>
        IDictionary<int,object> BALL_BURST_VARIANCES { get; }
        /// <summary>
        /// </summary>
        /// <remarks>
        /// NOTE: This array makes the Ball Burst capture animation differ between types
        ///       of Poké Ball in certain simple ways. The HGSS animations occasionally
        ///       have additional differences, which haven't been coded yet in
        ///       Essentials as they're more complex and I couldn't be bothered.
        /// </remarks>
        /// <example>
        /// key: PokeBallType, and value:
        /// [top glare filename, top particle start tone, top particle end tone,
        ///  middle glare filename, middle glare start tone, middle glare end tone,
        ///  bottom glare filename, bottom glare start tone, bottom glare end tone,
        ///  top particle filename, top particle start tone, top particle end tone,
        ///  bottom particle filename, bottom particle start tone, bottom particle end tone,
        ///  ring tone start, ring tone end]
        /// </example>
        IDictionary<int,object> BALL_BURST_CAPTURE_VARIANCES { get; }
        /// <summary>Returns the color for a Pokémon entering or exiting a Poké Ball.</summary>
        //IColor GetBattlerColorFromPokeBall(PokeBallType pokeBall);
        IColor GetBattlerColorFromPokeBall(int pokeBall);
        /// <summary>Adds a ball sprite to the animation.</summary>
        //IPictureEx AddBallSprite(int ballX, int ballY, PokeBallType pokeBall);
        IPictureEx AddBallSprite(int ballX, int ballY, int pokeBall);
        /// <summary>Makes the Poké Ball track the trainer's hand.</summary>
        KeyValuePair<int, int> BallTracksHand(IPictureEx ball, ISprite traSprite, bool safariThrow = false);
        void trainerThrowingFrames(IPictureEx ball, ITrainer trainer, ISprite traSprite);
        void createBallTrajectory(IPictureEx ball, float delay, float duration, int startX, int startY, int midX, int midY, int endX, int endY);
        void createBallTumbling(IPictureEx ball, float delay, float duration);
        void ballSetOpen(IPictureEx ball, float delay, int poke_ball);
        void ballSetClosed(IPictureEx ball, float delay, int poke_ball);
        void ballOpenUp(IPictureEx ball, float delay, int poke_ball, bool showSquish = true, bool playSE = true);
        void battlerAppear(IBattler battler, float delay, int battlerX, int battlerY, ISprite batSprite, int color);
        void battlerAbsorb(IBattler battler, float delay, int battlerX, int battlerY, int color);
        /// <summary>
        /// The regular Poké Ball burst animation, for when a Pokémon appears from a
        /// Poké Ball.
        /// </summary>
        /// <param name="delay"></param>
        /// <param name="ball"></param>
        /// <param name="ballX"></param>
        /// <param name="ballY"></param>
        /// <param name="poke_ball"></param>
        void ballBurst(float delay, IPictureEx ball, int ballX, int ballY, int poke_ball);
        /// <summary>
        /// The Poké Ball burst animation used when absorbing a wild Pokémon during a
        /// capture attempt.
        /// </summary>
        /// <param name="delay"></param>
        /// <param name="ball"></param>
        /// <param name="ballX"></param>
        /// <param name="ballY"></param>
        /// <param name="poke_ball"></param>
        void ballBurstCapture(float delay, IPictureEx ball, int ballX, int ballY, int poke_ball);
        /// <summary>
        /// The animation shown over a thrown Poké Ball when it has successfully caught
        /// a Pokémon.
        /// </summary>
        /// <param name="ball"></param>
        /// <param name="delay"></param>
        /// <param name="ballX"></param>
        /// <param name="ballY"></param>
        void ballCaptureSuccess(IPictureEx ball, float delay, int ballX, int ballY);
        /// <summary>
        /// The Poké Ball burst animation used when recalling a Pokémon.
        /// </summary>
        /// <remarks>
        /// In HGSS, this is the same for all types of Poké Ball except
        /// for the color that the battler turns.
        /// <seealso cref="GetBattlerColorFromPokeBall"/>
        /// </remarks>
        /// <param name="delay"></param>
        /// <param name="ball"></param>
        /// <param name="ballX"></param>
        /// <param name="ballY"></param>
        /// <param name="poke_ball"></param>
        void ballBurstRecall(float delay, IPictureEx ball, int ballX, int ballY, int poke_ball);
    }
}