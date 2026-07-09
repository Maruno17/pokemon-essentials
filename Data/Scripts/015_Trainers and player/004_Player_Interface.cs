using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Trainer class for the player
	/// </summary>
	//ToDo: Rename to `IPlayerTrainer` or `IHumanTrainer`?
	public interface IPlayer : ITrainer {
		/// <summary>the character ID of the player</summary>
		int character_ID		{ get; set; }
		/// <summary>the player's outfit</summary>
		int outfit		{ get; set; }
		/// <summary>the player's Gym Badges (true if owned)</summary>
		IList<bool> badges		{ get; set; }
		/// <summary>the player's money</summary>
		/// <remarks>
		/// Sets the player's money. It can not exceed <see cref="ISettings.MAX_MONEY"/>.
		/// </remarks>
		/// <value>new money value</value>
		int money		{ get; set; }
		/// <summary>the player's Game Corner coins</summary>
		/// <remarks>
		/// Sets the player's coins amount. It can not exceed <see cref="ISettings.MAX_COINS"/>.
		/// </remarks>
		/// <value>new coins value</value>
		int coins		{ get; set; }
		/// <summary>the player's battle points</summary>
		/// <remarks>
		/// Sets the player's Battle Points amount. It can not exceed
		/// <see cref="ISettings.MAX_BATTLE_POINTS"/>.
		/// </remarks>
		/// <value>new Battle Points value</value>
		int battle_points		{ get; set; }
		/// <summary>the player's soot</summary>
		/// <remarks>
		/// Sets the player's soot amount. It can not exceed <see cref="ISettings.MAX_SOOT"/>.
		/// </remarks>
		/// <value>new soot value</value>
		int soot		{ get; set; }
		/// <summary>the player's Pokédex</summary>
		IPokedex pokedex		{ get; }
		/// <summary>whether the Pokédex has been obtained</summary>
		bool has_pokedex		{ get; set; }
		/// <summary>whether the Pokégear has been obtained</summary>
		bool has_pokegear		{ get; set; }
		/// <summary>whether the player has running shoes (i.e. can run)</summary>
		bool has_running_shoes		{ get; set; }
		/// <summary>whether the player has an innate ability to access Pokémon storage</summary>
		bool has_box_link		{ get; set; }
		/// <summary>whether the creator of the Pokémon Storage System has been seen</summary>
		bool seen_storage_creator		{ get; set; }
		/// <summary>whether the effect of Exp All applies innately</summary>
		bool has_exp_all		{ get; set; }
		/// <summary>whether Mystery Gift can be used from the load screen</summary>
		bool mystery_gift_unlocked		{ get; set; }
		/// <summary>downloaded Mystery Gift data</summary>
		IList<IList<object>> mystery_gifts		{ get; set; }

		//public Player(string name, int trainer_type)
		//	: base(name, trainer_type) { initialize(name, trainer_type); }

		IPlayer initialize(string name, int trainer_type);

		//-----------------------------------------------------------------------------

		int trainer_type();

		/// <summary>
		/// Returns the number of Gym Badges owned by the player
		/// </summary>
		/// <returns></returns>
		int badge_count();

		//-----------------------------------------------------------------------------

		/// <summary>
		/// </summary>
		/// <remarks>
		/// Shorthand for <see cref="IPokedex.seen(int)"/>.
		/// </remarks>
		/// <seealso cref="IPokedex.seen(int)"/>
		/// <param name="species"></param>
		/// <returns></returns>
		bool seen(int species);

		/// <summary>
		/// </summary>
		/// <remarks>
		/// Shorthand for <see cref="IPokedex.owned(int)"/>.
		/// </remarks>
		/// <seealso cref="IPokedex.owned(int)"/>
		/// <param name="species"></param>
		/// <returns></returns>
		bool owned(int species);
	}
}