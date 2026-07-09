using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI utility and helper methods used throughout AI logic.
    /// </summary>
    public interface IBattleAIUtilities : IBattleAI
    {
        /// <summary>
        /// </summary>
        /// <remarks>
        /// These values are taken from the Complete-Fire-Red-Upgrade decomp here:
        /// <seealso href="https://github.com/Skeli789/Complete-Fire-Red-Upgrade/blob/f7f35becbd111c7e936b126f6328fc52d9af68c8/src/ability_battle_effects.c#L41">Github</seealso>
        /// </remarks>
        KeyValuePair<int, int[]> BASE_ABILITY_RATINGS { get; }
        KeyValuePair<int, int[]> BASE_ITEM_RATINGS { get; }

        /// <summary>Returns a random integer from 0 (inclusive) to x (exclusive).</summary>
        int AIRandom(int x);

        /// <summary>Iterates over all battlers, yielding each one and its index.</summary>
        void each_battler();
        //void EachBattler(System.Action<IAIBattler, int> action);

        /// <summary>Iterates over all foe battlers for a given side.</summary>
        void each_foe_battler(int side);
        //void EachFoeBattler(int side, System.Action<IAIBattler, int> action);

        /// <summary>Iterates over all same-side battlers for a given side.</summary>
        void EachSameSideBattler(int side, System.Action<IAIBattler, int> action);

        /// <summary>Iterates over all allies for a given battler index.</summary>
        void EachAlly(int index, System.Action<IAIBattler, int> action);

        /// <summary>
        /// Assumes that pkmn's ability is not negated by a global effect (e.g. Neutralizing Gas).
        /// </summary>
        /// <remarks>
        /// Determines if a Pokémon can absorb a move of a given type.
        /// </remarks>
        /// <param name="pkmn">pkmn is either a <see cref="IAIBattler"/> or a <see cref="IPokemon"/>.</param>
        /// <param name="move">move is a <see cref="IBattleMove"/> or a <see cref="IPokemonMove"/>.</param>
        /// <param name="moveType"></param>
        /// <returns></returns>
        bool pokemon_can_absorb_move(IPokemon pkmn, IMove move, int moveType);
        //bool PokemonCanAbsorbMove(IPokemon pkmn, IMove move, int moveType);

        /// <summary>
        /// Used by Toxic Spikes.
        /// </summary>
        /// <remarks>
        /// Determines if a Pokémon can be poisoned.
        /// </remarks>
        bool pokemon_can_be_poisoned(IPokemon pkmn);
        //bool PokemonCanBePoisoned(IPokemon pkmn);

        /// <summary>Determines if a Pokémon is airborne.</summary>
        bool pokemon_airborne(IPokemon pkmn);
        //bool PokemonAirborne(IPokemon pkmn);
    }
}