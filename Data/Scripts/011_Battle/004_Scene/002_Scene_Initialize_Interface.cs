using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for initialization and setup methods of the battle scene.
	/// </summary>
	public interface IBattleSceneInitialize : IBattleScene
	{
		/// <summary>
		/// Initializes the battle scene and its elements.
		/// </summary>
		IBattleScene Initialize();

		/// <summary>
		/// Called whenever the battle begins.
		/// </summary>
		/// <param name="battle">The battle instance to initialize.</param>
		void StartBattle(IBattle battle);

		/// <summary>
		/// Initializes all sprites and visual elements for the battle scene.
		/// </summary>
		void InitSprites();

		/// <summary>
		/// Creates and sets up the backdrop, bases, and message bar graphics.
		/// </summary>
		void CreateBackdropSprites();

		/// <summary>
		/// Creates the back sprite for a trainer (player or partner).
		/// </summary>
		/// <param name="idxTrainer">Trainer index (0 for player, 1+ for partners).</param>
		/// <param name="trainerType">Trainer type identifier.</param>
		/// <param name="numTrainers">Total number of trainers on the side.</param>
		void CreateTrainerBackSprite(int idxTrainer, int trainerType, int numTrainers = 1);

		/// <summary>
		/// Creates the front sprite for an opposing trainer.
		/// </summary>
		/// <param name="idxTrainer">Trainer index.</param>
		/// <param name="trainerType">Trainer type identifier.</param>
		/// <param name="numTrainers">Total number of trainers on the side.</param>
		void CreateTrainerFrontSprite(int idxTrainer, int trainerType, int numTrainers = 1);

		/// <summary>
		/// Creates the Pokémon sprite and shadow for a battler.
		/// </summary>
		/// <param name="idxBattler">Battler index.</param>
		void CreatePokemonSprite(int idxBattler);
	}
}