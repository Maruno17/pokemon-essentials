using System;
using PokemonEssentials.Framework;

namespace PokemonEssentials.Framework
{
    /*
    /// <summary>
    /// AI Move Effects Misc handlers interface for various miscellaneous battle move effects.
    /// Contains handler methods for move effect scoring, failure checks, and special behaviors.
    /// </summary>
    public interface IAiMoveEffectsMisc
    {
        /// <summary>
        /// Handler for moves that do nothing and congratulate the player.
        /// Returns useless score for AI evaluation.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int DoesNothingCongratulations(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Handler for moves that fail if it's not the user's first turn.
        /// Checks failure condition and adjusts score accordingly.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FailsIfNotUserFirstTurn(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Handler for moves that fail if the user has unused moves.
        /// Evaluates whether the user has other available moves.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FailsIfUserHasUnusedMove(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Handler for moves that fail if the user hasn't consumed a berry.
        /// Checks if the user has belched (consumed a berry).
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FailsIfUserNotConsumedBerry(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Handler for moves that fail if the target has no item.
        /// Checks target's item status and activity.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FailsIfTargetHasNoItem(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Handler for moves that fail unless target shares a type with the user.
        /// Compares user and target types for compatibility.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool FailsUnlessTargetSharesTypeWithUser(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that fail if user was damaged this turn.
        /// Evaluates speed relationships and status conditions.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FailsIfUserDamagedThisTurn(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves that fail if target has acted.
        /// Checks speed and damaging move availability.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int FailsIfTargetActed(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for crash damage moves unusable in gravity.
        /// Adjusts score based on accuracy and indirect damage susceptibility.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int CrashDamageIfFailsUnusableInGravity(int score, IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for sun weather moves.
        /// Prevents use when conflicting weather is active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartSunWeather(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting sun weather.
        /// Evaluates weather benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartSunWeatherScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting rain weather.
        /// Evaluates weather benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartRainWeather(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting sandstorm weather.
        /// Evaluates weather benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartSandstormWeather(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting hail weather.
        /// Evaluates weather benefits and conflicts, considers snowstorm setting.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartHailWeather(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for electric terrain moves.
        /// Prevents use when electric terrain is already active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartElectricTerrain(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting electric terrain.
        /// Evaluates terrain benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartElectricTerrainScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for grassy terrain moves.
        /// Prevents use when grassy terrain is already active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartGrassyTerrain(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting grassy terrain.
        /// Evaluates terrain benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartGrassyTerrainScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for misty terrain moves.
        /// Prevents use when misty terrain is already active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartMistyTerrain(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting misty terrain.
        /// Evaluates terrain benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartMistyTerrainScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for psychic terrain moves.
        /// Prevents use when psychic terrain is already active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool StartPsychicTerrain(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting psychic terrain.
        /// Evaluates terrain benefits and conflicts.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartPsychicTerrainScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for removing terrain effects.
        /// Negatively scores based on current terrain benefits.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveTerrain(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for terrain removal moves.
        /// Fails if no terrain is currently active.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RemoveTerrainFailsIfNoTerrain(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for adding spikes to foe's side.
        /// Fails if maximum spikes are already present.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddSpikesToFoeSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for adding spikes to foe's side.
        /// Evaluates based on number of vulnerable reserve Pokemon.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddSpikesToFoeSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for adding toxic spikes to foe's side.
        /// Fails if maximum toxic spikes are already present.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddToxicSpikesToFoeSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for adding toxic spikes to foe's side.
        /// Evaluates based on number of vulnerable reserve Pokemon.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddToxicSpikesToFoeSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for adding stealth rocks to foe's side.
        /// Fails if stealth rocks are already present.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddStealthRocksToFoeSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for adding stealth rocks to foe's side.
        /// Evaluates based on number of vulnerable reserve Pokemon.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddStealthRocksToFoeSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for adding sticky web to foe's side.
        /// Fails if sticky web is already present.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AddStickyWebToFoeSide(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for adding sticky web to foe's side.
        /// Evaluates based on number of vulnerable reserve Pokemon.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AddStickyWebToFoeSideScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for swapping side effects.
        /// Fails if no relevant side effects are present to swap.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool SwapSideEffects(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for swapping side effects.
        /// Evaluates based on beneficial vs detrimental effects on each side.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int SwapSideEffectsScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for making a substitute.
        /// Fails if substitute already exists or user HP is too low.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool UserMakeSubstitute(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for making a substitute.
        /// Evaluates based on user HP, foe's bypassing moves, and recent damage.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserMakeSubstituteScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for removing user binding and entry hazards.
        /// Evaluates removal of trapping, leech seed, and entry hazards.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveUserBindingAndEntryHazards(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for attacks that hit two turns later.
        /// Fails if Future Sight is already targeting the position.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="target">The target battler</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool AttackTwoTurnsLater(IBattleMove move, IBattler user, IBattler target, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for attacks that hit two turns later.
        /// Penalizes when user is down to last Pokemon.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AttackTwoTurnsLaterScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for swapping positions with ally.
        /// Fails if no valid ally target is available.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool UserSwapsPositionsWithAlly(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for swapping positions with ally.
        /// Generally penalized as usually not beneficial.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserSwapsPositionsWithAllyScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for burning attacker before user acts.
        /// Evaluates potential for burning contact move users.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int BurnAttackerBeforeUserActs(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for moves where all battlers lose half HP and user skips next turn.
        /// Balances HP loss ratios against recharge penalty.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int AllBattlersLoseHalfHPUserSkipsNextTurn(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for user losing half HP.
        /// Applies similar evaluation as losing half total HP.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int UserLosesHalfHP(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for starting shadow sky weather.
        /// Evaluates weather benefits and conflicts with higher HP penalty.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int StartShadowSkyWeather(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Failure check for removing all screens and safeguard.
        /// Fails if no screens or safeguard effects are present.
        /// </summary>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>True if move will fail, false otherwise</returns>
        bool RemoveAllScreensAndSafeguard(IBattleMove move, IBattler user, IAI ai, IBattle battle);

        /// <summary>
        /// Score handler for removing all screens and safeguard.
        /// Evaluates based on opponent vs own side screen presence.
        /// </summary>
        /// <param name="score">Base score for the move</param>
        /// <param name="move">The move being evaluated</param>
        /// <param name="user">The battler using the move</param>
        /// <param name="ai">AI evaluation context</param>
        /// <param name="battle">Current battle instance</param>
        /// <returns>Modified score for move evaluation</returns>
        int RemoveAllScreensAndSafeguardScore(int score, IBattleMove move, IBattler user, IAI ai, IBattle battle);*/
    }
}