using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface defining the end-of-round phase of battle, including weather, healing, delayed moves, status, field, and all end-of-round effects.
    /// </summary>
    public interface IBattleEndOfRoundPhase : IBattle
    {
        /// <summary>
        /// Handles end-of-round weather checks and weather effects.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEOREndWeather(IList<IBattler> priority);

        /// <summary>
        /// Handles weather damage for a battler at the end of the round.
        /// </summary>
        /// <param name="battler">The battler to apply weather damage to.</param>
        void pbEORWeatherDamage(IBattler battler);

        /// <summary>
        /// Handles the use of delayed moves like Future Sight and Doom Desire at the end of the round.
        /// </summary>
        /// <param name="position">The battler position affected.</param>
        /// <param name="positionIndex">The index of the battler position.</param>
        void pbEORUseFutureSight(IActivePosition position, int positionIndex);

        /// <summary>
        /// Handles healing from Wish at the end of the round.
        /// </summary>
        void pbEORWishHealing();

        /// <summary>
        /// Handles Sea of Fire damage at the end of the round.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEORSeaOfFireDamage(IList<IBattler> priority);

        /// <summary>
        /// Handles healing from Grassy Terrain at the end of the round.
        /// </summary>
        /// <param name="battler">The battler to heal.</param>
        void pbEORTerrainHealing(IBattler battler);

        /// <summary>
        /// Handles various healing effects at the end of the round (Aqua Ring, Ingrain, Leech Seed, etc.).
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEORHealingEffects(IList<IBattler> priority);

        /// <summary>
        /// Handles damage from status problems (poison, burn) at the end of the round.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEORStatusProblemDamage(IList<IBattler> priority);

        /// <summary>
        /// Handles damage from effects (Nightmare, Curse) at the end of the round.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEOREffectDamage(IList<IBattler> priority);

        /// <summary>
        /// Handles damage to trapped battlers at the end of the round.
        /// </summary>
        /// <param name="battler">The battler affected by trapping.</param>
        void pbEORTrappingDamage(IBattler battler);

        /// <summary>
        /// Handles countdown and end of effects that apply to a battler at the end of the round.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEOREndBattlerEffects(IList<IBattler> priority);

        /// <summary>
        /// Handles countdown and end of effects that apply to one side of the field at the end of the round.
        /// </summary>
        /// <param name="side">The side index (0 or 1).</param>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEOREndSideEffects(int side, IList<IBattler> priority);

        /// <summary>
        /// Handles countdown and end of effects that apply to the whole field at the end of the round.
        /// </summary>
        /// <param name="priority">The priority list of battlers.</param>
        void pbEOREndFieldEffects(IList<IBattler> priority);

        /// <summary>
        /// Handles end-of-round terrain checks and effects.
        /// </summary>
        void pbEOREndTerrain();

        /// <summary>
        /// Handles end-of-round self-inflicted effects on a battler (Hyper Mode, Uproar, Slow Start, etc.).
        /// </summary>
        /// <param name="battler">The battler affected.</param>
        void pbEOREndBattlerSelfEffects(IBattler battler);

        /// <summary>
        /// Handles shifting distant battlers to middle positions at the end of the round (triple battles).
        /// </summary>
        void pbEORShiftDistantBattlers();

        /// <summary>
        /// Main End Of Round phase method. Orchestrates all end-of-round effects.
        /// </summary>
        void pbEndOfRoundPhase();
    }
}