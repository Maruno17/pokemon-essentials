using System;
using System.Collections.Generic;
using PokemonEssentials.Data;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for individual Pokemon instances.
	/// Represents a single Pokemon with all its data including stats, moves,
	/// status conditions, ownership information, and battle capabilities.
	/// </summary>
	/// <remarks>
	/// The player's party Pokemon are stored in the array <see cref="ITrainer.party"/>.
	/// </remarks>
	/// <seealso cref="IGameManager.player"/>
	public interface IPokemon : ICloneable
	{
		/// <summary>This Pokemon's species.</summary>
		int species { get; }

		/// <summary>
		/// If defined, this Pokemon's form will be this value even if a MultipleForms
		/// handler tries to say otherwise.
		/// </summary>
		int? forced_form { get; set; }

		/// <summary>
		/// If defined, is the time (in Integer form) when this Pokemon's form was set.
		/// </summary>
		int? time_form_set { get; set; }

		/// <summary>The current experience points.</summary>
		int exp { get; }

		/// <summary>The number of steps until this Pokemon hatches, 0 if this Pokemon is not an egg.</summary>
		int steps_to_hatch { get; set; }

		/// <summary>The current HP.</summary>
		int hp { get; }

		/// <summary>This Pokemon's current status (see GameData::Status).</summary>
		int status { get; }

		/// <summary>
		/// Sleep count / toxic flag / 0:
		/// sleep (number of rounds before waking up), toxic (0 = regular poison, 1 = toxic)
		/// </summary>
		int statusCount { get; set; }

		/// <summary>This Pokemon's shininess (true, false, nil). Is recalculated if made nil.</summary>
		bool? shiny { get; set; }

		/// <summary>The moves known by this Pokemon.</summary>
		IPokemonMove[] moves { get; set; }

		/// <summary>The IDs of moves known by this Pokemon when it was obtained.</summary>
		int[] first_moves { get; set; }

		/// <summary>An array of ribbons owned by this Pokemon.</summary>
		int[] ribbons { get; set; }

		/// <summary>Contest stats - Cool.</summary>
		int cool { get; set; }

		/// <summary>Contest stats - Beauty.</summary>
		int beauty { get; set; }

		/// <summary>Contest stats - Cute.</summary>
		int cute { get; set; }

		/// <summary>Contest stats - Smart.</summary>
		int smart { get; set; }

		/// <summary>Contest stats - Tough.</summary>
		int tough { get; set; }

		/// <summary>Contest stats - Sheen.</summary>
		int sheen { get; set; }

		/// <summary>The Pokerus strain and infection time.</summary>
		int pokerus { get; set; }

		/// <summary>This Pokemon's current happiness (an integer between 0 and 255).</summary>
		int happiness { get; set; }

		/// <summary>The item ID of the Poke Ball this Pokemon is in.</summary>
		int poke_ball { get; set; }

		/// <summary>This Pokemon's markings, one value per mark.</summary>
		bool[] markings { get; set; }

		/// <summary>A hash of IV values for HP, Atk, Def, Speed, Sp. Atk and Sp. Def.</summary>
		//IDictionary<int, int> iv { get; set; }
		int[] iv { get; set; }

		/// <summary>
		/// An array of booleans indicating whether a stat is made to have maximum IVs
		/// (for Hyper Training). Set like @ivMaxed[:ATTACK] = true
		/// </summary>
		//IDictionary<int, bool> ivMaxed { get; set; }
		bool[] ivMaxed { get; set; }

		/// <summary>This Pokemon's effort values.</summary>
		//IDictionary<int, int> ev { get; set; }
		int[] ev { get; set; }

		/// <summary>Calculated total HP stat.</summary>
		int totalhp { get; }

		/// <summary>Calculated Attack stat.</summary>
		int attack { get; }

		/// <summary>Calculated Defense stat.</summary>
		int defense { get; }

		/// <summary>Calculated Special Attack stat.</summary>
		int spatk { get; }

		/// <summary>Calculated Special Defense stat.</summary>
		int spdef { get; }

		/// <summary>Calculated Speed stat.</summary>
		int speed { get; }

		/// <summary>This Pokemon's owner.</summary>
		IOwner owner { get; }

		/// <summary>
		/// The manner this Pokemon was obtained:
		/// 0 (met), 1 (as egg), 2 (traded), 4 (fateful encounter)
		/// </summary>
		int obtain_method { get; set; }

		/// <summary>The ID of the map this Pokemon was obtained in.</summary>
		int obtain_map { get; set; }

		/// <summary>
		/// Describes the manner this Pokemon was obtained. If left undefined,
		/// the obtain map's name is used.
		/// </summary>
		string obtain_text { get; set; }

		/// <summary>The level of this Pokemon when it was obtained.</summary>
		int obtain_level { get; set; }

		/// <summary>
		/// If this Pokemon hatched from an egg, returns the map ID where the hatching happened.
		/// Otherwise returns 0.
		/// </summary>
		int hatched_map { get; set; }

		/// <summary>
		/// Another Pokemon which has been fused with this Pokemon (or nil if there is none).
		/// Currently only used by Kyurem, to record a fused Reshiram or Zekrom.
		/// </summary>
		IPokemon fused { get; set; }

		/// <summary>This Pokemon's personal ID.</summary>
		int personalID { get; set; }

		/// <summary>A number used by certain species to evolve.</summary>
		int evolution_counter { get; set; }

		/// <summary>
		/// Used by Galarian Yamask to remember that it took sufficient damage from a
		/// battle and can evolve.
		/// </summary>
		bool ready_to_evolve { get; set; }

		/// <summary>Whether this Pokemon can be deposited in storage/Day Care.</summary>
		bool cannot_store { get; set; }

		/// <summary>Whether this Pokemon can be released.</summary>
		bool cannot_release { get; set; }

		/// <summary>Whether this Pokemon can be traded.</summary>
		bool cannot_trade { get; set; }

		/// <summary>Max total IVs.</summary>
		int IV_STAT_LIMIT { get; }

		/// <summary>Max total EVs.</summary>
		int EV_LIMIT { get; }

		/// <summary>Max EVs that a single stat can have.</summary>
		int EV_STAT_LIMIT { get; }

		/// <summary>Maximum length a Pokemon's nickname can be.</summary>
		int MAX_NAME_SIZE { get; }

		/// <summary>Maximum number of moves a Pokemon can know at once.</summary>
		int MAX_MOVES { get; }

		/// <summary>
		/// Initializes a new Pokemon with specified parameters.
		/// Creates Pokemon with given species, level, and optional parameters.
		/// </summary>
		/// <param name="species">Pokemon species</param>
		/// <param name="level">Pokemon level</param>
		/// <param name="owner">Pokemon owner (optional)</param>
		/// <param name="withMoves">Whether to generate moves (optional)</param>
		IPokemon initialize(int species, int level, IOwner owner = null, bool withMoves = true);

		void play_cry(int volume = 90, float? pitch = null);

		/// <summary>
		/// Gets Pokemon's display name.
		/// Returns nickname if set, otherwise species name.
		/// </summary>
		/// <returns>Pokemon's display name</returns>
		string name { get; }

		/// <summary>
		/// Gets or sets Pokemon's nickname.
		/// Custom name given by trainer, distinct from species name.
		/// </summary>
		string nickname { get; set; }

		/// <summary>
		/// Gets Pokemon's current level.
		/// Calculated from experience points and growth rate.
		/// </summary>
		int level { get; }

		/// <summary>
		/// Sets Pokemon's level.
		/// Adjusts experience points to match specified level.
		/// </summary>
		/// <remarks>
		/// Sets this Pokémon's level. The given level must be between 1 and the
		/// maximum level (defined in <see cref="IGrowthRate.max_level"/>).
		/// </remarks>
		/// <param name="value">New level to set (between 1 and the maximum level)</param>
		void setLevel(int value);

		/// <summary>
		/// Sets Pokemon's Exp. Points.
		/// </summary>
		/// <param name="value">New experience points</param>
		void setExp(int value);

		/// <summary>
		/// Returns this Pokemon's growth rate.
		/// </summary>
		/// <seealso cref="IGrowthRate.id"/>
		int growth_rate{ get; }

		/// <summary>
		/// Returns this Pokémon's base Experience value
		/// </summary>
		int base_exp { get; }

		/// <summary>
		/// Gets Pokemon's current form.
		/// May be overridden by forced_form if set.
		/// </summary>
		int form { get; set; }

		int form_simple { get; set; }

		/// <summary>
		/// Sets Pokemon's form.
		/// Changes appearance and potentially stats/abilities.
		/// </summary>
		/// <remarks>
		/// The same as <see cref="form"/>, but yields to a given <paramref name="block"/> in the middle so that a
		/// message about the form changing can be shown before calling "onSetForm"
		/// which may have its own messages, e.g. learning a move.
		/// </remarks>
		/// <seealso cref="IMultipleForms"/>
		/// <param name="value">New form to set</param>
		void setForm(int value, Action block = null);

		// ###############################################################################
		// Ability
		// ###############################################################################
		/// <summary>
		/// Returns the index of this Pokémon's ability.
		/// </summary>
		/// <remarks>
		/// The index of this Pokémon's ability (0, 1 are natural abilities, 2+ are
		/// hidden abilities) as defined for its species/form. An ability may not be
		/// defined at this index. Is recalculated (as 0 or 1) if made null.
		/// </remarks>
		int abilityIndex { get; }

		/// <summary>
		/// Sets Pokemon's ability index (<see cref="abilityIndex"/>).
		/// Changes active ability to specified ability.
		/// </summary>
		/// <param name="value">Forced ability index (null if none is set)</param>
		void setAbilityIndex(int? value);

		/// <summary>
		/// Gets Pokemon's current ability.
		/// Based on species, form, and ability index.
		/// </summary>
		int ability_id { get; }

		/// <summary>
		/// Sets Pokemon's ability.
		/// Changes active ability to specified ability (if possible).
		/// </summary>
		/// <param name="value">New ability to set</param>
		void setAbility(int value);

		/// <summary>
		/// Returns whether this Pokémon has a particular ability.
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		bool hasAbility(int value = 0);

		/// <summary>
		/// Returns whether this Pokémon has a hidden ability
		/// </summary>
		/// <returns></returns>
		bool hasHiddenAbility();

		/// <summary>
		/// Returns the list of abilities this Pokémon can have.
		/// </summary>
		// <returns><see cref="KeyValuePair{Ability_Id, Ability_Index}"/></returns>
		//KeyValuePair<int,int> getAbilityList();
		int[] getAbilityList();

		// ###############################################################################
		// Nature
		// ###############################################################################
		/// <summary>
		/// Gets Pokemon's nature.
		/// Affects stat growth and flavor preferences.
		/// </summary>
		int nature { get; }

		/// <summary>
		/// Sets Pokemon's nature.
		/// Affects stat modifiers and personality.
		/// </summary>
		/// <param name="value">New nature to set</param>
		void setNature(int value);

		/// <summary>
		/// Returns the calculated nature, taking into account things that change its
		/// stat-altering effect (i.e. Gen 8 mints). Only used for calculating stats.
		/// </summary>
		/// <remarks>
		/// If defined, this Pokémon's nature is considered to be this when calculating stats.
		/// </remarks>
		/// <value>
		/// ID of the nature to use for calculating stats
		/// </value>
		int nature_for_stats { get; set; }

		int nature_for_stats_id { get; }

		/// <summary>
		/// Returns whether this Pokémon has a particular nature. If no value is given,
		/// returns whether this Pokémon has a nature set.
		/// </summary>
		/// <param name="value">nature ID to check</param>
		/// <returns>whether this Pokémon has a particular nature or a nature at all</returns>
		//bool hasNature(Natures? value = null); //-1
		bool hasNature(int value); //-1

		// ###############################################################################
		// Gender
		// ###############################################################################
		/// <summary>
		/// Gets Pokemon's gender.
		/// Based on species gender ratio and personal ID.
		/// </summary>
		/// <seealso cref="IGenderRatio"/>
		/// <value>
		/// Return this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
		/// </value>
		int gender { get; }

		/// <summary>
		/// Sets Pokemon's gender to a particular gender (if possible).
		/// </summary>
		/// <param name="value">New gender to set (0/false = male, 1/true = female)</param>
		void setGender(bool value);

		/// <summary>
		/// Makes this Pokémon male.
		/// </summary>
		void makeMale();

		/// <summary>
		/// Makes this Pokémon female.
		/// </summary>
		void makeFemale();

		/// <summary>
		/// Checks if Pokemon is male.
		/// </summary>
		/// <returns>True if Pokemon is male</returns>
		bool male { get; }

		/// <summary>
		/// Checks if Pokemon is female.
		/// </summary>
		/// <returns>True if Pokemon is female</returns>
		bool female { get; }

		/// <summary>
		/// Checks if Pokemon is genderless.
		/// </summary>
		/// <returns>True if Pokemon is genderless</returns>
		bool genderless { get; }

		// ###############################################################################
		// Shininess
		// ###############################################################################
		/// <summary>
		/// Returns whether this Pokémon species is restricted to only ever being one
		/// gender (or genderless).
		/// </summary>
		bool isSingleGendered { get; }

		/// <summary>
		/// Checks if Pokemon is shiny (differently colored).
		/// Based on personal ID and trainer ID calculations.
		/// </summary>
		/// <seealso cref="ISettings.SHINY_POKEMON_CHANCE"/>
		/// <value>True if Pokemon is shiny</value>
		bool isShiny { get; }

		/// <summary>
		/// Checks if Pokemon is shiny (differently colored, square sparkles).
		/// Based on personal ID and trainer ID calculations.
		/// </summary>
		/// <value>True if Pokemon is shiny</value>
		bool isSuperShiny { get; set; }

		/// <summary>
		/// Checks if Pokemon is an egg.
		/// </summary>
		/// <returns>True if Pokemon is an egg</returns>
		bool egg { get; }

		// ###############################################################################
		// Items
		// ###############################################################################
		/// <summary>
		/// Gets Pokemon's held item.
		/// Item currently held by this Pokemon.
		/// </summary>
		int item { get; }

		/// <summary>
		/// Sets Pokemon's held item.
		/// Changes item held by this Pokemon.
		/// </summary>
		/// <param name="value">New item to hold</param>
		void setItem(int value);

		/// <summary>
		/// Returns whether this Pokémon is holding an item. If an item id is passed,
		/// returns whether the Pokémon is holding that item.
		/// </summary>
		/// <param name="value">item ID to check</param>
		/// <returns>whether this Pokémon is holding the specified item or an item at all</returns>
		bool hasItem(int value);

		/// <summary>
		/// Return the items this species can be found holding in the wild
		/// </summary>
		/// <returns>[itemcommon,itemuncommon,itemrare]</returns>
		int[] wildHoldItems { get; }

		/// <summary>
		/// Returns this Pokémon's mail.
		/// </summary>
		/// <remarks>
		/// Return mail held by this Pokémon (null if there is none)
		/// </remarks>
		IMail mail { get; }

		/// <summary>
		/// If mail is a Mail object, gives that mail to this Pokémon. If nil is given,
		/// removes the held mail.
		/// </summary>
		/// <param name="value">mail to be held by this Pokémon</param>
		void setMail(IMail value);

		/// <summary>
		/// </summary>
		/// <value>
		/// Whether the Pokémon is not fainted and not an egg
		/// </value>
		bool able { get; }

		/// <summary>
		/// Heals all HP of this Pokémon.
		/// </summary>
		/// <remarks>
		/// Returns <see cref="hp"/> to amount equal to <see cref="totalhp"/>
		/// </remarks>
		void heal_HP();

		/// <summary>
		/// Heals the status problem of this Pokémon.
		/// </summary>
		/// <remarks>
		/// Heals the <see cref="status"/> problem of this Pokémon.
		/// </remarks>
		void heal_status();

		/// <summary>
		/// Restores all PP of this Pokémon. If a move index is given, restores the PP
		/// of the move in that index.
		/// </summary>
		/// <remarks>
		/// Returns <see cref="IPokemonMove.pp"/> to amount equal to <see cref="IPokemonMove.total_pp"/>
		/// within <see cref="moves"/> matching given <paramref name="move_index"/> in collection.
		/// </remarks>
		/// <param name="move_index">index of the move to heal (-1 if all moves should be healed)</param>
		void heal_PP(int move_index = -1);

		/// <summary>
		/// Heals Pokemon completely.
		/// Restores HP, cures status, and restores PP.
		/// </summary>
		void heal();

		/// <summary>
		/// Return an array of this Pokémon's types
		/// </summary>
		int[] types { get; }

		/// <summary>
		/// Returns whether this Pokémon has the specified type.
		/// </summary>
		/// <param name="type">type to check</param>
		/// <returns></returns>
		bool hasType(int type);

		/// <summary>
		/// Returns this Pokémon's first type.
		/// </summary>
		//Types Type1 { get; }

		/// <summary>
		/// Returns this Pokémon's second type.
		/// </summary>
		//Types Type2 { get; }

		/// <summary>
		/// Changes Pokemon's happiness.
		/// Applies happiness change based on specified method.
		/// </summary>
		/// <param name="method">Method of happiness change</param>
		void changeHappiness(int method);

		/// <summary>
		/// Checks if Pokemon can evolve.
		/// Determines if evolution conditions are met.
		/// </summary>
		/// <returns>True if Pokemon can evolve</returns>
		bool hasEvolution();

		/// <summary>
		/// Gets Pokemon's evolution.
		/// Returns species Pokemon would evolve into.
		/// </summary>
		/// <returns>Evolution species or null</returns>
		int getEvolution();

		/// <summary>
		/// Evolves Pokemon.
		/// Changes species to evolved form and adjusts stats.
		/// </summary>
		/// <param name="new_species">Species to evolve into</param>
		void evolve(int new_species);

		// ###############################################################################
		// Moves
		// ###############################################################################
		/// <summary>
		/// Returns the number of moves known by the Pokémon.
		/// </summary>
		int numMoves { get; }

		/// <summary>
		/// Returns true if the Pokémon knows the given move.
		/// </summary>
		/// <param name="move_id">ID of the move to check</param>
		/// <returns>True if Pokemon knows the move</returns>
		bool hasMove(int move_id);

		/// <summary>
		/// Checks if Pokemon knows a specific move.
		/// </summary>
		/// <param name="move_id">ID of the move to check</param>
		/// <returns>True if Pokemon knows the move</returns>
		bool knowsMove(int move_id);

		/// <summary>
		/// Learns a new move.
		/// Adds move to Pokemon's moveset.
		/// </summary>
		/// <remarks>
		/// Silently learns the given move. Will erase the first known move if it has to.
		/// </remarks>
		/// <param name="move_id">ID of the move to learn</param>
		/// <returns>True if move was learned</returns>
		bool learnMove(int move_id);

		/// <summary>
		/// Forgets a move.
		/// Removes move from Pokemon's moveset.
		/// </summary>
		/// <param name="move_id">ID of the move to delete</param>
		// <param name="moveIndex">Index of move to forget</param>
		void forgetMove(int move_id);

		/// <summary>
		/// Forgets a move.
		/// Removes move from Pokemon's moveset.
		/// </summary>
		/// <remarks>
		/// Deletes the move at the given index from the Pokémon.
		/// </remarks>
		/// <param name="moveIndex">Index of move to forget</param>
		void forget_move_at_index(int moveIndex);

		/// <summary>
		/// Deletes all moves from the Pokémon.
		/// </summary>
		void forget_all_moves();

		/// <summary>
		/// Copies currently known moves into a separate array, for Move Relearner.
		/// </summary>
		void record_first_moves();
		//void RecordFirstMoves();

		/// <summary>
		/// Adds a move to this Pokémon's first moves.
		/// </summary>
		/// <param name="move_id">ID of the move to add</param>
		void add_first_move(int move_id);

		/// <summary>
		/// Removes a move to this Pokémon's first moves.
		/// </summary>
		/// <param name="move_id">ID of the move to remove</param>
		void remove_first_move(int move_id);

		/// <summary>
		/// Returns the list of moves this Pokémon can learn by levelling up.
		/// </summary>
		/// <returns></returns>
		//KeyValuePair<Moves, int>[] getMoveList();
		int[] getMoveList(int? method = null);

		/// <summary>
		/// Sets this Pokémon's movelist to the default movelist it originally had.
		/// </summary>
		void resetMoves();

		/// <summary>
		/// Clears this Pokémon's first moves.
		/// </summary>
		void clear_first_moves();

		/// <summary>
		/// Gets compatible moves for this Pokemon.
		/// Returns moves this Pokemon can learn.
		/// </summary>
		/// <returns>Array of compatible moves</returns>
		int[] getCompatibleMoves();

		/// <summary>
		/// Return whether the Pokémon is compatible with the given move
		/// </summary>
		/// <param name="move_id">ID of the move to check</param>
		/// <returns></returns>
		bool compatible_with_move(int move_id);
		//bool isCompatibleWithMove(int move_id);

		bool can_relearn_move { get; }

		/// <summary>
		/// Checks if Pokemon has fainted.
		/// </summary>
		/// <returns>True if HP is 0</returns>
		bool fainted { get; }

		/// <summary>
		/// Causes Pokemon to faint.
		/// Sets HP to 0 and applies faint effects.
		/// </summary>
		void faint();

		/// <summary>
		/// Gets Pokemon's status condition.
		/// Current non-volatile status affecting Pokemon.
		/// </summary>
		/// <returns>Status condition or null</returns>
		int getStatus();

		/// <summary>
		/// Sets Pokemon's status condition.
		/// Applies new status condition to Pokemon.
		/// </summary>
		/// <param name="status">Status condition to apply</param>
		void setStatus(int status);

		/// <summary>
		/// Cures Pokemon's status condition.
		/// Removes current status condition.
		/// </summary>
		void cureStatus();

		// ###############################################################################
		// Moves
		// ###############################################################################
		/// <summary>
		/// Returns the number of ribbons this Pokemon has.
		/// </summary>
		/// <returns></returns>
		//int ribbonCount { get; }
		int numRibbons { get; }

		/// <summary>
		/// Returns whether this Pokémon has the specified ribbon.
		/// </summary>
		/// <param name="ribbon">ribbon ID to check for</param>
		/// <returns></returns>
		bool hasRibbon(int ribbon);

		/// <summary>
		/// Gives this Pokémon the specified ribbon.
		/// </summary>
		/// <param name="ribbon">ID of the ribbon to give</param>
		void giveRibbon(int ribbon);

		/// <summary>
		/// Replaces one ribbon with the next one along, if possible.
		/// </summary>
		/// <remarks>
		/// Replaces one ribbon with the next one along, if possible. If none of the
		/// given ribbons are owned, give the first one.
		/// </remarks>
		/// <param name="arg">ID of the ribbon that was gained</param>
		/// <returns></returns>
		int upgradeRibbon(params int[] arg);

		/// <summary>
		/// Removes the specified ribbon from this Pokémon.
		/// </summary>
		/// <param name="ribbon">ID of the ribbon to remove</param>
		void takeRibbon(int ribbon);

		/// <summary>
		/// Removes all ribbons from this Pokémon.
		/// </summary>
		void clearAllRibbons();

		// ###############################################################################
		// Pokérus
		// ###############################################################################
		/// <summary>
		/// Gives this Pokemon Pokérus (either the specified strain or a random one).
		/// </summary>
		/// <param name="strain">Pokérus strain to give (1-15 inclusive, or 0 for random)</param>
		void GivePokerus(int strain = 0);

		/// <summary>
		/// Resets the infection time for this Pokemon's Pokérus (even if cured).
		/// </summary>
		void resetPokerusTime();

		/// <summary>
		/// Reduces the time remaining for this Pokemon's Pokérus (if infected).
		/// </summary>
		void lowerPokerusCount();

		/// <summary>
		/// Cures this Pokémon's Pokérus (if infected).
		/// </summary>
		void curePokerus();

		/// <summary>
		/// Returns the Pokérus infection stage for this Pokemon. The possible stages are
		/// 0/null (not infected), 1/true (infected) and 2/false (cured).
		/// </summary>
		/// <value>
		/// Return [0, 1, 2] current Pokérus infection stage
		/// </value>
		//int PokerusStage { get; }
		bool? PokerusStage { get; }

		/// <summary>
		/// Return the Pokérus infection stage for this Pokémon
		/// </summary>
		int? pokerusStrain { get; }

		// ###############################################################################
		// Ownership, obtained information
		// ###############################################################################
		/// <summary>
		/// Changes this Pokémon's owner.
		/// </summary>
		/// <param name="new_owner">the owner to change to</param>
		void setOwner(IOwner new_owner);

		/// <summary>
		/// Returns whether the specified Trainer is NOT this Pokemon's original trainer.
		/// </summary>
		/// <param name="trainer">the trainer to compare to the original trainer</param>
		/// <returns></returns>
		bool isForeign(ITrainer trainer);

		/// <summary>
		/// Returns the time when this Pokémon was obtained.
		/// </summary>
		DateTime? timeReceived { get; set; }

		/// <summary>
		/// Sets the time when this Pokémon was obtained.
		/// </summary>
		/// <param name="value">time in seconds since Unix epoch</param>
		void setTimeReceived(int value);

		/// <summary>
		/// Returns the time when this Pokémon hatched.
		/// </summary>
		DateTime? timeEggHatched { get; set; }

		/// <summary>
		/// Sets the time when this Pokémon hatched.
		/// </summary>
		/// <param name="value">time in seconds since Unix epoch</param>
		void setTimeEggHatched(int value);

		// ###############################################################################
		// Other
		// ###############################################################################
		/// <summary>
		/// Assigns the name of this Pokemon
		/// </summary>
		/// <param name="value">the nickname of this Pokémon</param>
		void setName(string value);

		/// <summary>
		/// Returns whether this Pokémon has been nicknamed
		/// </summary>
		bool nicknamed { get; }

		/// <summary>
		/// Returns the species name of this Pokémon
		/// </summary>
		string speciesName { get; }

		/// <summary>
		/// Returns the height of this Pokémon in decimetres (0.1 metres).
		/// </summary>
		float height { get; }

		/// <summary>
		/// Returns the weight of this Pokémon in hectograms (0.1 kilograms).
		/// </summary>
		float weight { get; }

		/// <summary>
		/// Returns the EV yield of this Pokémon.
		/// </summary>
		/// <value>
		/// the EV yield of this Pokémon (a hash with six key/value pairs)
		/// </value>
		int[] evYield{ get; }

		int affection_level { get; }

		/// <summary>
		/// Changes the happiness of this Pokémon depending on what happened to change it.
		/// </summary>
		/// <param name="method">the happiness changing method (e.g. 'walking')</param>
		void ChangeHappiness(int method);

		// ###############################################################################
		// Evolution checks.
		// ###############################################################################
		/// <summary>
		/// Checks whether this Pokemon can evolve because of levelling up.
		/// </summary>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_on_level_up();

		/// <summary>
		/// Checks whether this Pokemon can evolve because of levelling up in battle.
		/// This also checks call_level_up as above.
		/// </summary>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_on_battle_level_up();

		/// <summary>
		///  Checks whether this Pokemon can evolve because of using an item on it.
		/// </summary>
		/// <param name="item_used">the item being used</param>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_on_use_item(int item_used);

		/// <summary>
		/// Checks whether this Pokemon can evolve because of being traded.
		/// </summary>
		/// <param name="other_pkmn">the other Pokémon involved in the trade</param>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_on_trade(IPokemon other_pkmn);

		/// <summary>
		/// Checks whether this Pokemon can evolve after a battle.
		/// </summary>
		/// <param name="party_index"></param>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_after_battle(int party_index);

		/// <summary>
		/// Checks whether this Pokemon can evolve by a triggered event.
		/// </summary>
		/// <param name="value">a value that may be used by the evolution method</param>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_by_event(int value = 0);

		/// <summary>
		/// Called after this Pokémon evolves, to remove its held item (if the evolution
		/// required it to have a held item) or duplicate this Pokémon (Shedinja only).
		/// </summary>
		/// <param name="new_species">the species that this Pokémon evolved into</param>
		void action_after_evolution(int new_species);

		/// <summary>
		/// The core method that performs evolution checks. Needs a block given to it,
		/// which will provide either a GameData::Species ID (the species to evolve
		/// into) or nil (keep checking).
		/// </summary>
		/// <returns>the ID of the species to evolve into</returns>
		int check_evolution_internal();

		void trigger_event_evolution();

		// ###############################################################################
		// Stat calculations, Pokémon creation
		// ###############################################################################
		/// <summary>
		/// Returns this Pokémon's base, a hash with six key/value pairs.
		/// </summary>
		/// <returns></returns>
		// <seealso cref="IGameStats"/>
		int[] baseStats { get; }

		/// <summary>
		/// Returns this Pokémon's effective IVs, taking into account Hyper Training.
		/// Only used for calculating stats.
		/// </summary>
		/// <returns>hash containing this Pokémon's effective IVs</returns>
		int[] calcIV();

		/// <summary>
		/// Returns the maximum HP of this Pokémon.
		/// </summary>
		/// <remarks>
		/// Used to calculate <see cref="totalhp"/>
		/// </remarks>
		/// <param name="_base"></param>
		/// <param name="level"></param>
		/// <param name="iv"></param>
		/// <param name="ev"></param>
		/// <returns></returns>
		int calcHP(int _base, int level, int iv, int ev);

		/// <summary>
		/// Returns the specified stat of this Pokémon (not used for total HP).
		/// </summary>
		/// <remarks>
		/// </remarks>
		/// <param name="_base"></param>
		/// <param name="level"></param>
		/// <param name="iv"></param>
		/// <param name="ev"></param>
		/// <param name="pv"></param>
		// Used to calculate <see cref="Stats"/>
		int calcStat(int _base, int level, int iv, int ev, int pv);

		/// <summary>
		/// Calculates this Pokémon's stats.
		/// </summary>
		/// <remarks>
		/// Recalculates all stats based on base stats, IVs, EVs, level, and nature.
		/// </remarks>
		//int calcStats();
		int calc_stats();

		/// <summary>
		/// Creates a new Pokémon object.
		/// </summary>
		/// <param name="species">Pokémon species.</param>
		/// <param name="level">Pokémon level.</param>
		/// <param name="player">Trainer object for the original trainer (the player by default).</param>
		/// <param name="withMoves">If false, this Pokémon has no moves.</param>
		/// <param name="recheck_form">whether to auto-check the form</param>
		/// <returns></returns>
		IPokemon initialize(int species, int level, ITrainer player = null, bool withMoves = true, bool recheck_form = true);
	}

	/*
	/// <summary>
	/// Interface for Pokemon factory and utility methods.
	/// Provides static methods for creating and managing Pokemon instances.
	/// </summary>
	public interface IPokemonFactory
	{
		/// <summary>
		/// Creates a new wild Pokemon.
		/// Generates Pokemon with random IVs and appropriate level.
		/// </summary>
		/// <param name="species">Pokemon species</param>
		/// <param name="level">Pokemon level</param>
		/// <returns>New wild Pokemon</returns>
		IPokemon createWildPokemon(ISpecies species, int level);

		/// <summary>
		/// Creates a new trainer Pokemon.
		/// Generates Pokemon for trainer use with appropriate moves and stats.
		/// </summary>
		/// <param name="species">Pokemon species</param>
		/// <param name="level">Pokemon level</param>
		/// <param name="trainer">Pokemon's trainer</param>
		/// <returns>New trainer Pokemon</returns>
		IPokemon createTrainerPokemon(ISpecies species, int level, ITrainer trainer);

		/// <summary>
		/// Creates a Pokemon egg.
		/// Generates egg with appropriate hatching requirements.
		/// </summary>
		/// <param name="species">Pokemon species</param>
		/// <param name="steps">Steps required to hatch</param>
		/// <returns>New Pokemon egg</returns>
		IPokemon createEgg(ISpecies species, int steps);

		/// <summary>
		/// Validates Pokemon data.
		/// Checks if Pokemon data is valid and consistent.
		/// </summary>
		/// <param name="pokemon">Pokemon to validate</param>
		/// <returns>True if Pokemon data is valid</returns>
		bool validatePokemon(IPokemon pokemon);
	}

	/// <summary>
	/// Interface for Pokemon experience and leveling system.
	/// Manages experience point calculations, level progression, and growth rates.
	/// </summary>
	public interface IPokemonExperience
	{
		/// <summary>
		/// Calculates experience required for level.
		/// Returns total experience needed to reach specified level.
		/// </summary>
		/// <param name="level">Target level</param>
		/// <param name="growthRate">Pokemon's growth rate</param>
		/// <returns>Experience required</returns>
		int getExpForLevel(int level, IGrowthRate growthRate);

		/// <summary>
		/// Calculates level from experience.
		/// Returns current level based on experience points.
		/// </summary>
		/// <param name="exp">Current experience points</param>
		/// <param name="growthRate">Pokemon's growth rate</param>
		/// <returns>Current level</returns>
		int getLevelFromExp(int exp, IGrowthRate growthRate);

		/// <summary>
		/// Adds experience to Pokemon.
		/// Increases experience and handles level ups.
		/// </summary>
		/// <param name="pokemon">Pokemon gaining experience</param>
		/// <param name="amount">Experience to add</param>
		void addExperience(IPokemon pokemon, int amount);

		/// <summary>
		/// Handles level up process.
		/// Manages stat increases and move learning during level up.
		/// </summary>
		/// <param name="pokemon">Pokemon leveling up</param>
		/// <param name="oldLevel">Previous level</param>
		/// <param name="newLevel">New level</param>
		void processLevelUp(IPokemon pokemon, int oldLevel, int newLevel);
	}

	/// <summary>
	/// Interface for Pokemon stat calculation system.
	/// Handles stat calculations including base stats, IVs, EVs, nature modifiers, and level scaling.
	/// </summary>
	public interface IPokemonStats
	{
		/// <summary>
		/// Calculates HP stat.
		/// Uses HP-specific formula with base stat, IV, EV, and level.
		/// </summary>
		/// <param name="pokemon">Pokemon to calculate for</param>
		/// <returns>Calculated HP stat</returns>
		int calculateHP(IPokemon pokemon);

		/// <summary>
		/// Calculates non-HP stat.
		/// Uses standard formula with base stat, IV, EV, level, and nature modifier.
		/// </summary>
		/// <param name="pokemon">Pokemon to calculate for</param>
		/// <param name="stat">Stat to calculate</param>
		/// <returns>Calculated stat value</returns>
		int calculateStat(IPokemon pokemon, IStat stat);

		/// <summary>
		/// Gets nature modifier for stat.
		/// Returns multiplier based on nature's stat preferences.
		/// </summary>
		/// <param name="nature">Pokemon's nature</param>
		/// <param name="stat">Stat to check</param>
		/// <returns>Nature modifier (0.9, 1.0, or 1.1)</returns>
		double getNatureModifier(INature nature, IStat stat);

		/// <summary>
		/// Validates IV values.
		/// Checks if IV values are within valid range.
		/// </summary>
		/// <param name="ivs">IV dictionary to validate</param>
		/// <returns>True if IVs are valid</returns>
		bool validateIVs(Dictionary<IStat, int> ivs);

		/// <summary>
		/// Validates EV values.
		/// Checks if EV values are within valid range and total.
		/// </summary>
		/// <param name="evs">EV dictionary to validate</param>
		/// <returns>True if EVs are valid</returns>
		bool validateEVs(Dictionary<IStat, int> evs);
	}
	*/
}