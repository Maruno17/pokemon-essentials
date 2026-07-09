using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI logic related to generic move effect scoring and stat changes.
    /// </summary>
    public interface IBattleAIGenericMoveEffectScoring :  IBattleAI
    {
        /// <summary>
        /// Calculates the score for raising a target's stat(s)
        /// </summary>
        /// <remarks>
        /// Main method for calculating the score for moves that raise a battler's
        /// stat(s).
        /// By default, assumes that a stat raise is a good thing. However, this score
        /// is inverted (by desire_mult) if the target opposes the user. If the move
        /// could target a foe but is targeting an ally, the score is also inverted, but
        /// only because it is inverted again in <see cref="pbGetMoveScoreAgainstTarget"/>.
        /// </remarks>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="statChanges">int stat, int increment</param>
        /// <param name="wholeEffect"></param>
        /// <param name="fixedChange"></param>
        /// <param name="ignoreContrary"></param>
        /// <returns></returns>
        int get_score_for_target_stat_raise(int score, IAIBattler target, IDictionary<int, int> statChanges, bool wholeEffect = true, bool fixedChange = false, bool ignoreContrary = false);
        //int GetScoreForTargetStatRaise(int score, IAIBattler target, IDictionary<int, int> statChanges, bool wholeEffect = true, bool fixedChange = false, bool ignoreContrary = false);

        /// <summary>
        /// Returns whether the target raising the given stat will have any impact.
        /// </summary>
        /// <remarks>
        /// Determines if raising a stat for a target is worthwhile.
        /// </remarks>
        bool stat_raise_worthwhile(IAIBattler target, int stat, bool fixedChange = false);
        //bool StatRaiseWorthwhile(IAIBattler target, int stat, bool fixedChange = false);

        /// <summary>
        /// Make score changes based on the general concept of raising stats at all.
        /// </summary>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="stat_changes"></param>
        /// <param name="desire_mult"></param>
        /// <returns></returns>
        int get_target_stat_raise_score_generic(int score, IAIBattler target, int stat_changes, int desire_mult = 1);

        /// <summary>
        /// Make score changes based on the raising of a specific stat.
        /// </summary>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="stat"></param>
        /// <param name="increment"></param>
        /// <param name="desire_mult"></param>
        /// <returns></returns>
        int get_target_stat_raise_score_one(int score, IAIBattler target, int stat, int increment, int desire_mult = 1);

        /// <summary>Calculates the score for lowering a target's stat(s).</summary>
        /// <remarks>
        /// Main method for calculating the score for moves that lower a battler's
        /// stat(s).
        /// By default, assumes that a stat drop is a good thing. However, this score
        /// is inverted (by desire_mult) if the target is the user or an ally. This
        /// inversion does not happen if the move could target a foe but is targeting an
        /// ally, but only because it is inverted in <see cref="pbGetMoveScoreAgainstTarget"/>
        /// instead.
        /// </remarks>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="statChanges">int stat, int decrement</param>
        /// <param name="wholeEffect"></param>
        /// <param name="fixedChange"></param>
        /// <param name="ignoreContrary"></param>
        int get_score_for_target_stat_drop(int score, IAIBattler target, IDictionary<int, int> statChanges, bool wholeEffect = true, bool fixedChange = false, bool ignoreContrary = false);
        //int GetScoreForTargetStatDrop(int score, IAIBattler target, IDictionary<int, int> statChanges, bool wholeEffect = true, bool fixedChange = false, bool ignoreContrary = false);

        /// <summary>
        /// Returns whether the target lowering the given stat will have any impact.
        /// </summary>
        /// <remarks>
        /// Determines if lowering a stat for a target is worthwhile.
        /// </remarks>
        bool stat_drop_worthwhile(IAIBattler target, int stat, bool fixedChange = false);
        //bool StatDropWorthwhile(IAIBattler target, int stat, bool fixedChange = false);

        /// <summary>
        /// Make score changes based on the general concept of lowering stats at all.
        /// </summary>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="stat_changes"></param>
        /// <param name="desire_mult"></param>
        /// <returns></returns>
        int get_target_stat_drop_score_generic(int score, IAIBattler target, int stat_changes, int desire_mult = 1);

        /// <summary>
        /// Make score changes based on the lowering of a specific stat.
        /// </summary>
        /// <param name="score"></param>
        /// <param name="target"></param>
        /// <param name="stat"></param>
        /// <param name="increment"></param>
        /// <param name="desire_mult"></param>
        /// <returns></returns>
        int get_target_stat_drop_score_one(int score, IAIBattler target, int stat, int increment, int desire_mult = 1);

        /// <summary>Calculates the score for weather effects.</summary>
        int get_score_for_weather(int weather, IAIBattler moveUser, bool starting = false);
        //int GetScoreForWeather(int weather, IAIBattler moveUser, bool starting = false);

        /// <summary>Calculates the score for terrain effects.</summary>
        int get_score_for_terrain(int terrain, IAIBattler moveUser, bool starting = false);
        //int GetScoreForTerrain(int terrain, IAIBattler moveUser, bool starting = false);
    }
}