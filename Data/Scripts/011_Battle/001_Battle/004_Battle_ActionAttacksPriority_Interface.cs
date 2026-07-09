using System;
using System.Collections;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface defining battle actions, attacks, and priority mechanics.
	/// Handles move selection, targeting, and turn order calculation.
	/// </summary>
	public interface IBattleActionAttacksPriority : IBattle
	{
		/// <summary>
		/// Checks if a battler can choose a specific move.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="idxMove">The move index.</param>
		/// <param name="showMessages">Whether to display messages.</param>
		/// <param name="sleepTalk">Whether the move is being used via Sleep Talk.</param>
		/// <returns>True if the move can be chosen, false otherwise.</returns>
		bool CanChooseMove(int idxBattler, int idxMove, bool showMessages, bool sleepTalk = false);

		/// <summary>
		/// Checks if a battler can choose any move.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="sleepTalk">Whether checking for Sleep Talk.</param>
		/// <returns>True if any move can be chosen, false otherwise.</returns>
		bool CanChooseAnyMove(int idxBattler, bool sleepTalk = false);

		/// <summary>
		/// Automatically chooses a move for a battler (Encore or Struggle).
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="showMessages">Whether to display messages.</param>
		/// <returns>True if a move was chosen, false otherwise.</returns>
		bool AutoChooseMove(int idxBattler, bool showMessages = true);

		/// <summary>
		/// Registers a move choice for a battler.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="idxMove">The move index.</param>
		/// <param name="showMessages">Whether to display messages.</param>
		/// <returns>True if the move was registered, false otherwise.</returns>
		bool RegisterMove(int idxBattler, int idxMove, bool showMessages = true);

		/// <summary>
		/// Checks if a battler chose a specific move.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="moveID">The move ID to check.</param>
		/// <returns>True if the move was chosen, false otherwise.</returns>
		bool ChoseMove(int idxBattler, int moveID);

		/// <summary>
		/// Checks if a battler chose a move with a specific function code.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="code">The function code to check.</param>
		/// <returns>True if the move was chosen, false otherwise.</returns>
		bool ChoseMoveFunctionCode(int idxBattler, int code);

		/// <summary>
		/// Registers a target for a battler's move.
		/// </summary>
		/// <param name="idxBattler">The battler index.</param>
		/// <param name="idxTarget">The target index.</param>
		void RegisterTarget(int idxBattler, int idxTarget);

		/// <summary>
		/// Checks if a move can target a specific battler.
		/// </summary>
		/// <param name="idxUser">The user's battler index.</param>
		/// <param name="idxTarget">The target's battler index.</param>
		/// <param name="targetData">The move's target data.</param>
		/// <returns>True if the target is valid, false otherwise.</returns>
		//bool MoveCanTarget(int idxUser, int idxTarget, MoveTargetData targetData);
		bool MoveCanTarget(int idxUser, int idxTarget, ITarget targetData);

		/// <summary>
		/// Calculates the priority order for all battlers.
		/// </summary>
		/// <param name="fullCalc">Whether to perform a full recalculation.</param>
		/// <param name="indexArray">Optional array of battler indices to recalculate.</param>
		void CalculatePriority(bool fullCalc = false, IList<int> indexArray = null);

		//int[] pbPriority(bool onlySpeedSort = false);
		IList<IBattlePriority> pbPriority(bool onlySpeedSort = false);
	}

	public interface IBattlePriority
	{
		IBattler battler	{ get; }
		int speed			{ get; set; }
		/// <summary>
		/// sub-priority from ability
		/// </summary>
		int ability			{ get; set; }
		/// <summary>
		/// sub-priority from item
		/// </summary>
		int item			{ get; set; }
		/// <summary>
		/// final sub-priority
		/// </summary>
		int subPriority		{ get; set; }
		int priority		{ get; set; }
		/// <summary>
		/// tie-breaker order
		/// </summary>
		int order			{ get; set; }
	}
}