using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Custom exception thrown when a battle is aborted.
	/// </summary>
	public interface IBattleAbortedException : IThrowException
	{
		//public BattleAbortedException(string message) : base(message) { }
	}

	/// <summary>
	/// Interface defining battle initialization and termination logic.
	/// Handles battle setup, participant management, and battle conclusion.
	/// </summary>
	public interface IBattleStartAndEnd : IBattle
	{
		/// <summary>
		/// Aborts the current battle by throwing a <see cref="IBattleAbortedException"/>.
		/// </summary>
		/// <exception cref="IBattleAbortedException"/>
		void pbAbort();

		/// <summary>
		/// Ensures all required participants exist and adjusts battle size if necessary.
		/// Will never create new battler positions, only delete them (except for wild Pokémon).
		/// </summary>
		/// <remarks>
		/// Reduces the size of each side by 1 and tries again if needed.
		/// If side sizes are uneven, only the larger side's size will be reduced until both sides are equal.
		/// </remarks>
		void EnsureParticipants();

		#region Set up all battlers
		/// <summary>
		/// Creates a new battler at the specified index with the given Pokémon and party index.
		/// </summary>
		/// <param name="idxBattler">The battle index for the new battler.</param>
		/// <param name="pkmn">The Pokémon to create the battler with.</param>
		/// <param name="idxParty">The party index of the Pokémon.</param>
		void CreateBattler(int idxBattler, IPokemon pkmn, int idxParty);

		/// <summary>
		/// Sets up the battler slots for both sides of the battle.
		/// </summary>
		/// <remarks>
		/// Sets up both sides of the battle with their respective Pokémon and trainers.
		/// </remarks>
		/// <returns>A tuple containing arrays of battler indices for each side.</returns>
		int[][] pbSetUpSides();
		#endregion

		/// <summary>
		/// Send out all battlers at the start of battle.
		/// </summary>
		/// <remarks>
		/// Initiates the battle by sending out all battlers.
		/// </remarks>
		/// <param name="sendOuts">Array of battler indices to send out.</param>
		void StartBattleSendOut(IList<int> sendOuts);

		/// <summary>
		/// Starts a new battle.
		/// </summary>
		/// <returns>The outcome of the battle.</returns>
		int StartBattle();

		/// <summary>
		/// Core battle initialization logic.
		/// </summary>
		void StartBattleCore();

		#region Main battle loop.
		/// <summary>
		/// Main battle loop that handles turns and battle progression.
		/// </summary>
		void BattleLoop();
		#endregion

		#region End of battle.
		/// <summary>
		/// Handles money gain after winning a battle.
		/// </summary>
		void GainMoney();

		/// <summary>
		/// Handles money loss after losing a battle.
		/// </summary>
		void LoseMoney();

		/// <summary>
		/// Handles end of battle logic including rewards, messages, and cleanup.
		/// </summary>
		/// <returns>The final battle outcome.</returns>
		int EndOfBattle();
		#endregion

		#region Judging.
		/// <summary>
		/// Checks the battle state at a specific point.
		/// </summary>
		/// <remarks>
		/// Checks for special conditions that might alter the battle decision.
		/// </remarks>
		/// <param name="user">The user triggering the checkpoint.</param>
		/// <param name="move">Optional move being used.</param>
		void JudgeCheckpoint(IBattler user, PokemonEssentials.Data.IMove move = null);

		/// <summary>
		/// Determines the battle outcome based on time limit.
		/// </summary>
		/// <returns>The battle outcome based on remaining Pokémon and HP.</returns>
		int DecisionOnTime();

		/// <summary>
		/// Alternative time-based decision method (unused).
		/// </summary>
		/// <returns>The battle outcome based on average HP percentages.</returns>
		[System.Obsolete("Unused")]
		int DecisionOnTime2();

		/// <summary>
		/// Gets the draw outcome constant.
		/// </summary>
		int DecisionOnDraw { get; }

		/// <summary>
		/// Judges the current state of the battle and sets the decision.
		/// </summary>
		void Judge();
		#endregion
	}
}