using System;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Poke Ball effects module that manages ball-specific capture mechanics.
    /// Provides specialized handling for different Poke Ball types including capture rate modifications,
    /// unconditional capture effects, and success/failure callbacks for capture attempts.
    /// Contains handler collections for various Poke Ball trigger types and conditions.
    /// </summary>
    public interface IPokeBallEffects
    {
        /// <summary>Handler collection for unconditional capture effects (e.g., Master Ball).</summary>
        IItemHandlerHash IsUnconditional { get; }

        /// <summary>Handler collection for catch rate modification effects.</summary>
        IItemHandlerHash ModifyCatchRate { get; }

        /// <summary>Handler collection for successful capture effects.</summary>
        IItemHandlerHash OnCatch { get; }

        /// <summary>Handler collection for failed capture effects.</summary>
        IItemHandlerHash OnFailCatch { get; }

        /// <summary>
        /// Checks if a Poke Ball provides unconditional capture like Master Ball.
        /// Determines if the ball guarantees capture regardless of normal calculations.
        /// </summary>
        /// <param name="ball">Poke Ball being used</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="battler">Target battler being captured</param>
        /// <returns>True if capture is guaranteed, false otherwise</returns>
        bool isUnconditional(IItem ball, IBattle battle, IBattler battler);

        /// <summary>
        /// Modifies the catch rate based on the specific Poke Ball being used.
        /// Applies ball-specific multipliers and conditional bonuses to capture calculations.
        /// Examples: Great Ball (1.5x), Ultra Ball (2x), Net Ball (3.5x for Bug/Water types).
        /// </summary>
        /// <param name="ball">Poke Ball being used</param>
        /// <param name="catchRate">Base catch rate to modify</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="battler">Target battler being captured</param>
        /// <returns>Modified catch rate value</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);

        /// <summary>
        /// Triggers effects that occur when a Pokemon is successfully caught.
        /// Handles post-capture modifications and special ball effects applied to the captured Pokemon.
        /// </summary>
        /// <param name="ball">Poke Ball that was used</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="pkmn">Pokemon that was captured</param>
        void onCatch(IItem ball, IBattle battle, IPokemon pkmn);

        /// <summary>
        /// Triggers effects that occur when a capture attempt fails.
        /// Handles failure statistics tracking and any special ball effects on failed captures.
        /// Automatically increments the global failed Poke Ball counter.
        /// </summary>
        /// <param name="ball">Poke Ball that was used</param>
        /// <param name="battle">Current battle context</param>
        /// <param name="battler">Target battler that escaped</param>
        void onFailCatch(IItem ball, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Great Ball catch rate effects.
    /// Provides 1.5x catch rate multiplier for all capture attempts.
    /// </summary>
    public interface IGreatBallEffect
    {
        /// <summary>
        /// Applies Great Ball catch rate multiplier.
        /// </summary>
        /// <param name="ball">Great Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Catch rate multiplied by 1.5</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Ultra Ball catch rate effects.
    /// Provides 2x catch rate multiplier for all capture attempts.
    /// </summary>
    public interface IUltraBallEffect
    {
        /// <summary>
        /// Applies Ultra Ball catch rate multiplier.
        /// </summary>
        /// <param name="ball">Ultra Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Catch rate multiplied by 2</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Net Ball catch rate effects.
    /// Provides enhanced catch rate for Bug and Water type Pokemon.
    /// </summary>
    public interface INetBallEffect
    {
        /// <summary>
        /// Applies Net Ball type-specific catch rate bonus.
        /// Provides 3.5x (or 3x in legacy mode) multiplier for Bug and Water types.
        /// </summary>
        /// <param name="ball">Net Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on target's type</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Dive Ball catch rate effects.
    /// Provides enhanced catch rate in underwater environments.
    /// </summary>
    public interface IDiveBallEffect
    {
        /// <summary>
        /// Applies Dive Ball environment-specific catch rate bonus.
        /// Provides 3.5x multiplier when battling underwater.
        /// </summary>
        /// <param name="ball">Dive Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on battle environment</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Nest Ball catch rate effects.
    /// Provides enhanced catch rate for lower level Pokemon.
    /// </summary>
    public interface INestBallEffect
    {
        /// <summary>
        /// Applies Nest Ball level-based catch rate bonus.
        /// Provides increasing multiplier for Pokemon level 30 and below,
        /// with maximum bonus at level 1 and decreasing as level increases.
        /// </summary>
        /// <param name="ball">Nest Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on target's level</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Repeat Ball catch rate effects.
    /// Provides enhanced catch rate for Pokemon species already owned.
    /// </summary>
    public interface IRepeatBallEffect
    {
        /// <summary>
        /// Applies Repeat Ball ownership-based catch rate bonus.
        /// Provides 3.5x (or 3x in legacy mode) multiplier for Pokemon species
        /// already registered as owned in the player's Pokedex.
        /// </summary>
        /// <param name="ball">Repeat Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on species ownership</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Timer Ball catch rate effects.
    /// Provides increasing catch rate based on battle duration.
    /// </summary>
    public interface ITimerBallEffect
    {
        /// <summary>
        /// Applies Timer Ball turn-based catch rate bonus.
        /// Provides increasing multiplier starting at 1x and growing by 0.3x per turn,
        /// capped at 4x maximum effectiveness.
        /// </summary>
        /// <param name="ball">Timer Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on turn count</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Dusk Ball catch rate effects.
    /// Provides enhanced catch rate during night time or in caves.
    /// </summary>
    public interface IDuskBallEffect
    {
        /// <summary>
        /// Applies Dusk Ball time-based catch rate bonus.
        /// Provides 3x (or 3.5x in legacy mode) multiplier during night time or cave battles.
        /// </summary>
        /// <param name="ball">Dusk Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on time of day</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Quick Ball catch rate effects.
    /// Provides enhanced catch rate only on the first turn of battle.
    /// </summary>
    public interface IQuickBallEffect
    {
        /// <summary>
        /// Applies Quick Ball first-turn catch rate bonus.
        /// Provides 5x multiplier only on turn 0 (the very first turn of battle).
        /// </summary>
        /// <param name="ball">Quick Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on turn timing</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }

    /// <summary>
    /// Interface for Fast Ball catch rate effects.
    /// Provides enhanced catch rate for Pokemon with high base Speed stats.
    /// </summary>
    public interface IFastBallEffect
    {
        /// <summary>
        /// Applies Fast Ball speed-based catch rate bonus.
        /// Provides enhanced catch rate for Pokemon with base Speed of 100 or higher.
        /// </summary>
        /// <param name="ball">Fast Ball item</param>
        /// <param name="catchRate">Base catch rate</param>
        /// <param name="battle">Current battle</param>
        /// <param name="battler">Target battler</param>
        /// <returns>Modified catch rate based on base Speed stat</returns>
        int modifyCatchRate(IItem ball, int catchRate, IBattle battle, IBattler battler);
    }
}