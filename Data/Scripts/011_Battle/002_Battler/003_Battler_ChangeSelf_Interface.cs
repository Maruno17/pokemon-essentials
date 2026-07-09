using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for the Battler self-change logic (HP, type, form, etc.).
    /// </summary>
    public interface IBattlerChangeSelf : IBattler
    {
        /// <summary>
        /// Reduces the battler's HP by the given amount.
        /// </summary>
        /// <param name="amt">The amount of HP to reduce.</param>
        /// <param name="anim">Whether to show the HP animation.</param>
        /// <param name="registerDamage">Whether to register the damage for this round.</param>
        /// <param name="anyAnim">Whether to show any animation.</param>
        /// <returns>The actual amount of HP reduced.</returns>
        int ReduceHP(int amt, bool anim = true, bool registerDamage = true, bool anyAnim = true);

        /// <summary>
        /// Recovers the battler's HP by the given amount.
        /// </summary>
        /// <param name="amt">The amount of HP to recover.</param>
        /// <param name="anim">Whether to show the HP animation.</param>
        /// <param name="anyAnim">Whether to show any animation.</param>
        /// <returns>The actual amount of HP recovered.</returns>
        int RecoverHP(int amt, bool anim = true, bool anyAnim = true);

        /// <summary>
        /// Recovers HP from a draining move, or takes damage if the target has Liquid Ooze.
        /// </summary>
        /// <param name="amt">The amount of HP to drain.</param>
        /// <param name="target">The target battler.</param>
        /// <param name="msg">Optional message to display.</param>
        void RecoverHPFromDrain(int amt, IBattler target, string msg = null);

        /// <summary>
        /// Takes effect damage (e.g., from weather or status) and triggers related effects.
        /// </summary>
        /// <param name="amt">The amount of HP to lose.</param>
        /// <param name="show_anim">Whether to show the HP animation.</param>
        void TakeEffectDamage(int amt, bool show_anim = true);

        /// <summary>
        /// Causes the battler to faint, triggering all related effects and events.
        /// </summary>
        /// <param name="showMessage">Whether to show the faint message.</param>
        void Faint(bool showMessage = true);

        /// <summary>
        /// Sets the PP of a move.
        /// </summary>
        /// <param name="move">The move to set PP for.</param>
        /// <param name="pp">The new PP value.</param>
        void SetPP(IMove move, int pp);

        /// <summary>
        /// Reduces the PP of a move, with special handling for multi-turn attacks and infinite PP.
        /// </summary>
        /// <param name="move">The move to reduce PP for.</param>
        /// <returns>True if PP was reduced or not needed, false if out of PP.</returns>
        bool ReducePP(IMove move);

        /// <summary>
        /// Reduces the PP of a move for another battler.
        /// </summary>
        /// <param name="move">The move to reduce PP for.</param>
        void ReducePPOther(IMove move);

        /// <summary>
        /// Changes the battler's type(s) to the given type(s) or another battler's types.
        /// </summary>
        /// <param name="newType">The new type(s) or battler to copy types from.</param>
        void ChangeTypes(int newType);

        /// <summary>
        /// Resets the battler's types to their original values.
        /// </summary>
        void ResetTypes();

        /// <summary>
        /// Changes the battler's form to the given form, updating stats and visuals.
        /// </summary>
        /// <param name="newForm">The new form index.</param>
        /// <param name="msg">The message to display.</param>
        void ChangeForm(int newForm, string msg);

        /// <summary>
        /// Checks and updates the battler's form based on status changes (e.g., Shaymin frozen).
        /// </summary>
        void CheckFormOnStatusChange();

        /// <summary>
        /// Checks and updates the battler's form based on moveset changes (e.g., Keldeo Secret Sword).
        /// </summary>
        void CheckFormOnMovesetChange();

        /// <summary>
        /// Checks and updates the battler's form based on weather changes (e.g., Castform Forecast).
        /// </summary>
        /// <param name="ability_changed">Whether the ability has changed.</param>
        void CheckFormOnWeatherChange(bool ability_changed = false);

        /// <summary>
        /// Checks and updates the battler's form for all relevant triggers (entering battle, end of round, etc.).
        /// </summary>
        /// <param name="endOfRound">Whether this is at the end of the round.</param>
        void CheckForm(bool endOfRound = false);

        /// <summary>
        /// Transforms this battler into the target, copying stats, types, and moves.
        /// </summary>
        /// <param name="target">The target battler to transform into.</param>
        void Transform(IBattler target);

        /// <summary>
        /// Placeholder for Hyper Mode logic (Shadow Pokémon).
        /// </summary>
        void HyperMode();
    }
}