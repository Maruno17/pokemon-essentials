using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface defining experience gain and move learning functionality in battles.
	/// Handles experience distribution, EV gains, and move learning mechanics.
	/// </summary>
	public interface IBattleExpAndMoveLearning : IBattle
	{
		/// <summary>
		/// Distributes experience and EVs to participating Pokémon after a battle.
		/// </summary>
		/// <remarks>
		/// Handles experience gain for all participating Pokémon after a battle.
		/// </remarks>
		void pbGainExp();

		/// <summary>
		/// Calculates and applies EV gains for a single Pokémon from a defeated battler.
		/// </summary>
		/// <param name="idxParty">The party index of the Pokémon gaining EVs.</param>
		/// <param name="defeatedBattler">The defeated battler providing the EVs.</param>
		void GainEVsOne(int idxParty, IBattler defeatedBattler);

		/// <summary>
		/// Calculates and applies experience gain for a single Pokémon from a defeated battler.
		/// </summary>
		/// <param name="idxParty">The party index of the Pokémon gaining experience.</param>
		/// <param name="defeatedBattler">The defeated battler providing the experience.</param>
		/// <param name="numPartic">Number of participating Pokémon.</param>
		/// <param name="expShare">List of Pokémon holding Exp. Share.</param>
		/// <param name="expAll">Whether Exp. All is active.</param>
		/// <param name="showMessages">Whether to display experience gain messages.</param>
		void GainExpOne(int idxParty, IBattler defeatedBattler, int numPartic, IList<int> expShare, bool expAll, bool showMessages = true);

		/// <summary>
		/// Attempts to teach a new move to a Pokémon.
		/// </summary>
		void pbLearnMove(int idxParty, int newMove);
		/*
		/// <summary>
		/// Handles move learning for a Pokémon after gaining a level.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn moves.</param>
		/// <param name="level">The new level the Pokémon reached.</param>
		void LearnMovesOnLevelUp(IPokemon pkmn, int level);

		/// <summary>
		/// Handles move learning for a Pokémon after evolution.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn moves.</param>
		void LearnMovesOnEvolution(IPokemon pkmn);

		/// <summary>
		/// Handles move learning for a Pokémon after using a TM/HM.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTM(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutor(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move reminder.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnReminder(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move relearner.
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnRelearner(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 8+).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen8(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 7).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen7(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 6).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen6(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 5).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen5(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 4).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen4(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 3).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen3(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 2).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen2(IPokemon pkmn, IMove move);

		/// <summary>
		/// Handles move learning for a Pokémon after using a move tutor (Gen 1).
		/// </summary>
		/// <param name="pkmn">The Pokémon that may learn the move.</param>
		/// <param name="move">The move to learn.</param>
		void LearnMoveOnTutorGen1(IPokemon pkmn, IMove move);*/
	}
}