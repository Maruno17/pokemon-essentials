using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Pokemon shadow Pokemon functionality.
    /// Provides methods for managing shadow Pokemon states, heart gauge, hyper mode, and purification.
    /// </summary>
    public interface IPokemonShadowPokemon : IPokemon, ICloneable
    {
        /// <summary>
        /// Gets or sets whether this Pokemon is a shadow Pokemon.
        /// </summary>
        bool shadow { get; set; }

        /// <summary>
        /// Gets the current heart gauge value.
        /// Sets the heart gauge value for this shadow Pokemon.
        /// </summary>
        /// <returns>The heart gauge value, or 0 if not set.</returns>
        int heart_gauge { get; set; }

        /// <summary>
        /// Gets whether this Pokemon is currently in hyper mode.
        /// Sets the hyper mode state for this shadow Pokemon.
        /// </summary>
        /// <returns>True if in hyper mode, false otherwise.</returns>
        bool hyper_mode { get; set; }

        /// <summary>
        /// Gets or sets the saved experience points for when this Pokemon is purified.
        /// </summary>
        int saved_exp { get; set; }

        /// <summary>
        /// Gets or sets the saved effort values for when this Pokemon is purified.
        /// </summary>
        //IDictionary<int, int> saved_ev { get; set; }
        int[] saved_ev { get; set; }

        /// <summary>
        /// Gets or sets the shadow moves this Pokemon knows.
        /// </summary>
        IList<int> shadow_moves { get; set; }

        /// <summary>
        /// Gets or sets the step counter for heart gauge changes during walking.
        /// </summary>
        int heart_gauge_step_counter { get; set; }

        /// <summary>
        /// Sets Pokemon's Exp. Points.
        /// </summary>
        /// <param name="value">New experience points</param>
        void setExp(int value);

        /// <summary>
        /// Sets Pokemon's Health Points.
        /// </summary>
        /// <param name="value">New health points</param>
        void setHp(int value);

        /// <summary>
        /// Gets the current heart gauge value.
        /// </summary>
        /// <returns>The heart gauge value, or 0 if not set.</returns>
        //int heart_gauge { set; }

        /// <summary>
        /// Gets the shadow Pokemon data for this species and form.
        /// </summary>
        /// <returns>The shadow Pokemon data, or null if none exists.</returns>
        IShadowPokemon shadow_data();

        /// <summary>
        /// Gets the maximum heart gauge size for this shadow Pokemon.
        /// </summary>
        /// <value>The maximum gauge size.</value>
        // <seealso cref="IShadowPokemon.HEART_GAUGE_SIZE"/>
        // <seealso cref="IShadowPokemon.gauge_size"/>
        int max_gauge_size { get; }

        /// <summary>
        /// Adjusts the heart gauge by the specified value.
        /// </summary>
        /// <param name="value">The amount to change the heart gauge by (negative to decrease).</param>
        void adjustHeart(int value);

        /// <summary>
        /// Changes the heart gauge based on the specified method and Pokemon's nature.
        /// </summary>
        /// <param name="method">The method used (battle, call, walking, scent).</param>
        /// <param name="multiplier">Optional multiplier for the change amount (default 1).</param>
        void change_heart_gauge(int method, int multiplier = 1);

        /// <summary>
        /// Gets the current heart stage (0-5) based on the heart gauge.
        /// </summary>
        /// <returns>The heart stage number.</returns>
        int heartStage();

        /// <summary>
        /// Determines if this Pokemon is currently a shadow Pokemon.
        /// </summary>
        /// <returns>True if this is a shadow Pokemon, false otherwise.</returns>
        bool shadowPokemon();

        /// <summary>
        /// Changes the happiness of this Pokémon depending on what happened to change it.
        /// </summary>
        /// <param name="method">the happiness changing method (e.g. 'walking')</param>
        void changeHappiness(int method);

        /// <summary>
        /// Gets whether this Pokemon is currently in hyper mode.
        /// </summary>
        /// <returns>True if in hyper mode, false otherwise.</returns>
        //bool hyper_mode { get; }

        /// <summary>
        /// Converts this Pokemon into a shadow Pokemon with appropriate moves and stats.
        /// </summary>
        void makeShadow();

        /// <summary>
        /// Updates the shadow moves based on the current heart stage.
        /// </summary>
        void update_shadow_moves();

        /// <summary>
        /// Replaces the current moveset with the specified moves.
        /// </summary>
        /// <param name="new_moves">The list of move IDs to replace with.</param>
        void replace_moves(IList<int> new_moves);

        /// <summary>
        /// Determines if this shadow Pokemon can be purified.
        /// </summary>
        /// <returns>True if the Pokemon can be purified, false otherwise.</returns>
        bool purifiable();

        /// <summary>
        /// Checks if this shadow Pokemon is ready to be purified and displays a message if so.
        /// </summary>
        void check_ready_to_purify();

        /// <summary>
        /// Adds effort values to this Pokemon's stats.
        /// </summary>
        /// <param name="added_evs">Dictionary of stat IDs to EV amounts to add.</param>
        //void add_evs(IDictionary<int, int> added_evs);
        void add_evs(int[] added_evs);

        /// <summary>
        /// Creates a clone of this Pokemon including shadow-related data.
        /// </summary>
        /// <returns>A cloned Pokemon object.</returns>
        object clone();
    }
}