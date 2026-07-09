using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI logic related to choosing moves in battle.
    /// </summary>
    public interface IBattleAIChooseMoveLogic : IBattleAI
    {
        /// <summary>Gets the move score threshold for move selection.</summary>
        /// <returns>A value between 0.0 and 1.0 representing the threshold.</returns>
        double MoveScoreThreshold();

        /// <summary>Gets the scores for the user's available moves.</summary>
        /// <returns>List of tuples (move index, score, target index).</returns>
        //IList<(int moveIndex, int score, int targetIndex)> GetMoveScores();
        IList<IBattleAIMoveScore> GetMoveScores();

        void get_redirected_target(ITarget target_data);
        void add_move_to_choices(IBattleChoice choices, int idxMove, int score, int idxTarget = -1);

        /// <summary>Sets up the move check for a given move.</summary>
        /// <param name="move">The move to check.</param>
        void SetUpMoveCheck(IMove move);

        /// <summary>Sets up the move check for a given target.</summary>
        /// <param name="target">The target battler.</param>
        void SetUpMoveCheckTarget(IAIBattler target);

        /// <summary>Predicts whether the current move will fail.</summary>
        /// <returns>True if the move will fail, otherwise false.</returns>
        bool PredictMoveFailure();

        /// <summary>Predicts whether the current move will fail against the target.</summary>
        /// <returns>True if the move will fail against the target, otherwise false.</returns>
        bool PredictMoveFailureAgainstTarget();

        /// <summary>Gets a score for the current move being used against the given targets.</summary>
        /// <param name="targets">The list of target battlers (optional).</param>
        /// <returns>The move score.</returns>
        int GetMoveScore(IList<IAIBattler> targets = null);

        /// <summary>Gets a score for the current move being used against the current target.</summary>
        /// <returns>The move score against the target.</returns>
        int GetMoveScoreAgainstTarget();

        /// <summary>Chooses a move from the available choices.</summary>
        /// <param name="choices">The list of move choices.</param>
        //void ChooseMove(IList<(int moveIndex, int score, int targetIndex)> choices);
        void ChooseMove(IList<IBattleAIMoveScore> choices);
    }

    public interface IBattleAIMoveScore
    {
        int MoveIndex   { get; }
        int Score       { get; }
        int TargetIndex { get; }
    }
}