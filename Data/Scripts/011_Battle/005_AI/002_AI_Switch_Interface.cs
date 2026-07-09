using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for AI logic related to switching Pokémon in battle.
    /// </summary>
    public interface IBattleAISwitchLogic : IBattleAI
    {
        /// <summary>Determines if the AI should switch out the current battler.</summary>
        /// <remarks>
        /// Called by the AI's <see cref="IBattleAI.DefaultChooseEnemyCommand(int)"/>,
        /// and by <see cref="IBattleAIChooseMoveLogic.ChooseMove(IList{IBattleAIMoveScore})"/>
        /// if the only moves known are bad ones (the latter forces a switch if possible).
        /// Also aliased by the Battle Palace and Battle Arena.
        /// </remarks>
        /// <param name="terribleMoves">Whether only bad moves are available (forces switch if true).</param>
        /// <returns>True if a switch should occur, otherwise false.</returns>
        bool ChooseToSwitchOut(bool terribleMoves = false);

        /// <summary>Gets the list of non-active party Pokémon that can be switched in.</summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <returns>List of Pokémon that can be switched in.</returns>
        IList<IPokemon> GetNonActivePartyPokemon(int idxBattler);

        /// <summary>Chooses the best replacement Pokémon to switch in.</summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="terribleMoves">Whether only bad moves are available (forces switch if true).</param>
        /// <returns>The party index of the best replacement Pokémon, or -1 if none found.</returns>
        int ChooseBestReplacementPokemon(int idxBattler, bool terribleMoves = false);

        /// <summary>Rates a potential replacement Pokémon for switching in.</summary>
        /// <param name="idxBattler">The battler index.</param>
        /// <param name="pkmn">The Pokémon to rate.</param>
        /// <param name="score">The current score for this Pokémon.</param>
        /// <returns>The adjusted score for the replacement Pokémon.</returns>
        int RateReplacementPokemon(int idxBattler, IPokemon pkmn, int score);

        /// <summary>Calculates the entry hazard damage for a Pokémon switching in.</summary>
        /// <param name="pkmn">The Pokémon to check.</param>
        /// <param name="side">The side index (0=player, 1=opponent).</param>
        /// <returns>The amount of damage the Pokémon would take from entry hazards.</returns>
        int CalculateEntryHazardDamage(IPokemon pkmn, int side);
    }

    /// <summary>
    /// Interface for a collection of event handlers that can be used to customize the AI's decision-making process for switching Pokémon.
    /// </summary>
    public interface IBattleAISwitchHandler
    {
        /// <summary>
        /// Pokémon is about to faint because of Perish Song.
        /// </summary>
        bool ShouldSwitch_perish_song(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon will take a significant amount of damage at the end of this round, or
        /// it has an effect that causes it damage at the end of this round which it can
        /// remove by switching.
        /// </summary>
        bool ShouldSwitch_significant_eor_damage(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon can cure its status problem or heal some HP with its ability by
        /// switching out. Covers all abilities with an OnSwitchOut AbilityEffects
        /// handler.
        /// </summary>
        bool ShouldSwitch_cure_status_problem_by_switching_out(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon's position is about to be healed by Wish, and a reserve can benefit
        /// more from that healing than the Pokémon can.
        /// </summary>
        bool ShouldSwitch_wish_healing(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon is yawning and can't do anything while asleep.
        /// </summary>
        bool ShouldSwitch_yawning(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon is asleep, won't wake up soon and can't do anything while asleep.
        /// </summary>
        bool ShouldSwitch_asleep(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon can't use any moves and isn't Destiny Bonding/Grudging/hiding behind a
        /// Substitute.
        /// </summary>
        bool ShouldSwitch_battler_is_useless(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon can't do anything to any foe because its ability absorbs all damage
        /// the Pokémon can deal out.
        /// </summary>
        bool ShouldSwitch_foe_absorbs_all_moves_with_its_ability(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon doesn't have an ability that makes it immune to a foe's move, but a
        /// reserve does (see def pokemon_can_absorb_move?). The foe's move is chosen
        /// randomly, or is their most powerful move if the trainer's skill level is good
        /// enough.
        /// </summary>
        bool ShouldSwitch_absorb_foe_move(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Sudden Death rule (at the end of each round, if one side has more able Pokémon
        /// than the other side, that side wins). Avoid fainting at all costs.
        /// </summary>
        /// <remarks>
        /// NOTE: This rule isn't used anywhere.
        /// </remarks>
        bool ShouldSwitch_sudden_death(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Pokémon is within 5 levels of the foe, and foe's last move was super-effective
        /// and powerful.
        /// </summary>
        bool ShouldSwitch_high_damage_from_foe(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);

        /// <summary>
        /// Don't bother switching if the battler will just faint from entry hazard damage
        /// upon switching back in, and if no reserve can remove the entry hazard(s).
        /// Switching out in this case means the battler becomes unusable, so it might as
        /// well stick around instead and do as much as it can.
        /// </summary>
        bool ShouldNotSwitch_lethal_entry_hazards(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't bother switching (50% chance) if the battler knows a super-effective
        /// move.
        /// </summary>
        bool ShouldNotSwitch_battler_has_super_effective_move(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't bother switching if the battler has 4 or more positive stat stages.
        /// Negative stat stages are ignored.
        /// </summary>
        bool ShouldNotSwitch_battler_has_very_raised_stats(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
        /// <summary>
        /// Don't bother switching if the battler has Wonder Guard and is immune to the
        /// foe's damaging attacks.
        /// </summary>
        bool ShouldNotSwitch_battler_is_immune_via_wonder_guard(IBattler battler, IList<IPokemon> reserves, IBattleAI ai, IBattle battle);
    }
}