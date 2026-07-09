using System;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for battle active field which manages field-wide effects, weather, and terrain.
	/// Tracks various battle field conditions and their durations including weather effects,
	/// terrain effects, and special field conditions like Gravity, Magic Room, etc.
	/// </summary>
	public interface IActiveField
	{
		/// <summary>
		/// Array of field effects and their states/durations.
		/// Contains various field-wide battle effects that affect all battlers.
		/// </summary>
		IEffectsField effects { get; set; }

		/// <summary>
		/// The default weather condition for this battle field.
		/// Used as the base weather when no weather moves are active.
		/// </summary>
		int defaultWeather { get; set; }

		/// <summary>
		/// The current weather condition affecting the battle field.
		/// Affects move power, accuracy, and various battle mechanics.
		/// </summary>
		int weather { get; set; }

		/// <summary>
		/// The remaining duration for the current weather effect.
		/// Weather effects typically last 5 turns unless extended by items or abilities.
		/// </summary>
		int weatherDuration { get; set; }

		/// <summary>
		/// The default terrain condition for this battle field.
		/// Used as the base terrain when no terrain moves are active.
		/// </summary>
		int defaultTerrain { get; set; }

		/// <summary>
		/// The current terrain condition affecting the battle field.
		/// Affects move power, priority, and status conditions for grounded battlers.
		/// </summary>
		int terrain { get; set; }

		/// <summary>
		/// The remaining duration for the current terrain effect.
		/// Terrain effects typically last 5 turns unless extended by items or abilities.
		/// </summary>
		int terrainDuration { get; set; }
		IActiveField initialize();
	}

	/// <summary>
	/// Interface for battle active side which manages side-specific effects and entry hazards.
	/// Tracks effects that apply to one side of the battle including screens, entry hazards,
	/// and various protective or enhancing effects.
	/// </summary>
	public interface IActiveSide
	{
		/// <summary>
		/// Array of side effects and their states/durations.
		/// Contains various effects that apply to all battlers on one side including
		/// screens (Reflect/Light Screen), entry hazards (Spikes/Stealth Rock), and
		/// protective effects (Safeguard/Mist).
		/// </summary>
		IEffectsSide effects { get; set; }
		IActiveSide initialize();
	}

	/// <summary>
	/// Interface for battle active position which manages position-specific effects.
	/// Tracks effects that apply to specific battle positions including delayed attacks,
	/// healing effects, and wish-based moves that target specific positions rather than battlers.
	/// </summary>
	public interface IActivePosition
	{
		/// <summary>
		/// Array of position effects and their states/durations.
		/// Contains effects tied to battle positions including Future Sight attacks,
		/// Wish healing, and other delayed effects that persist even when battlers switch.
		/// </summary>
		IEffectsPosition effects { get; set; }
		IActivePosition initialize();
	}

	/// <summary>
	/// Interface for field effects collection managing various field-wide battle conditions.
	/// </summary>
	public interface IEffectsField
	{
		/// <summary>
		/// Amulet Coin effect - doubles prize money if active.
		/// </summary>
		bool AmuletCoin { get; set; }

		/// <summary>
		/// Fairy Lock effect duration - prevents switching for all battlers.
		/// </summary>
		int FairyLock { get; set; }

		/// <summary>
		/// Fusion Bolt effect - increases power of next Fusion Flare.
		/// </summary>
		bool FusionBolt { get; set; }

		/// <summary>
		/// Fusion Flare effect - increases power of next Fusion Bolt.
		/// </summary>
		bool FusionFlare { get; set; }

		/// <summary>
		/// Gravity effect duration - grounds all airborne battlers and increases move accuracy.
		/// </summary>
		int Gravity { get; set; }

		/// <summary>
		/// Happy Hour effect - doubles prize money if active.
		/// </summary>
		bool HappyHour { get; set; }

		/// <summary>
		/// Ion Deluge effect - makes Normal moves become Electric type.
		/// </summary>
		bool IonDeluge { get; set; }

		/// <summary>
		/// Magic Room effect duration - negates held item effects.
		/// </summary>
		int MagicRoom { get; set; }

		/// <summary>
		/// Mud Sport field effect duration - weakens Electric moves.
		/// </summary>
		int MudSportField { get; set; }

		/// <summary>
		/// Pay Day accumulated money from Pay Day moves.
		/// </summary>
		int PayDay { get; set; }

		/// <summary>
		/// Trick Room effect duration - reverses Speed priority.
		/// </summary>
		int TrickRoom { get; set; }

		/// <summary>
		/// Water Sport field effect duration - weakens Fire moves.
		/// </summary>
		int WaterSportField { get; set; }

		/// <summary>
		/// Wonder Room effect duration - swaps Defense and Special Defense stats.
		/// </summary>
		int WonderRoom { get; set; }
	}

	/// <summary>
	/// Interface for side effects collection managing side-specific battle conditions.
	/// </summary>
	public interface IEffectsSide
	{
		/// <summary>
		/// Aurora Veil effect duration - reduces damage from both physical and special attacks.
		/// </summary>
		int AuroraVeil { get; set; }

		/// <summary>
		/// Crafty Shield effect - protects team from status moves for the turn.
		/// </summary>
		bool CraftyShield { get; set; }

		/// <summary>
		/// Echoed Voice counter - tracks consecutive uses of Echoed Voice for power increase.
		/// </summary>
		int EchoedVoiceCounter { get; set; }

		/// <summary>
		/// Echoed Voice used flag - tracks if Echoed Voice was used this turn.
		/// </summary>
		bool EchoedVoiceUsed { get; set; }

		/// <summary>
		/// Last round fainted battler index - tracks which battler fainted last round.
		/// </summary>
		int LastRoundFainted { get; set; }

		/// <summary>
		/// Light Screen effect duration - reduces damage from special attacks.
		/// </summary>
		int LightScreen { get; set; }

		/// <summary>
		/// Lucky Chant effect duration - prevents critical hits against this side.
		/// </summary>
		int LuckyChant { get; set; }

		/// <summary>
		/// Mat Block effect - protects team from damaging moves for the turn.
		/// </summary>
		bool MatBlock { get; set; }

		/// <summary>
		/// Mist effect duration - prevents stat reductions from opposing moves.
		/// </summary>
		int Mist { get; set; }

		/// <summary>
		/// Quick Guard effect - protects team from priority moves for the turn.
		/// </summary>
		bool QuickGuard { get; set; }

		/// <summary>
		/// Rainbow effect duration - doubles secondary effect chances.
		/// </summary>
		int Rainbow { get; set; }

		/// <summary>
		/// Reflect effect duration - reduces damage from physical attacks.
		/// </summary>
		int Reflect { get; set; }

		/// <summary>
		/// Round effect flag - tracks if Round was used for power boost.
		/// </summary>
		bool Round { get; set; }

		/// <summary>
		/// Safeguard effect duration - prevents status conditions.
		/// </summary>
		int Safeguard { get; set; }

		/// <summary>
		/// Sea of Fire effect duration - damages non-Fire types each turn.
		/// </summary>
		int SeaOfFire { get; set; }

		/// <summary>
		/// Spikes layers - entry hazard that damages switching Pokemon (0-3 layers).
		/// </summary>
		int Spikes { get; set; }

		/// <summary>
		/// Stealth Rock effect - entry hazard with type-based damage.
		/// </summary>
		bool StealthRock { get; set; }

		/// <summary>
		/// Sticky Web effect - entry hazard that lowers Speed of switching Pokemon.
		/// </summary>
		bool StickyWeb { get; set; }

		/// <summary>
		/// Swamp effect duration - quarters Speed of non-Grass types.
		/// </summary>
		int Swamp { get; set; }

		/// <summary>
		/// Tailwind effect duration - doubles Speed of team members.
		/// </summary>
		int Tailwind { get; set; }

		/// <summary>
		/// Toxic Spikes layers - entry hazard that poisons switching Pokemon (0-2 layers).
		/// </summary>
		int ToxicSpikes { get; set; }

		/// <summary>
		/// Wide Guard effect - protects team from multi-target moves for the turn.
		/// </summary>
		bool WideGuard { get; set; }
	}

	/// <summary>
	/// Interface for position effects collection managing position-specific battle conditions.
	/// </summary>
	public interface IEffectsPosition //ToDo: rename to `IEffectsBattler`?
	{
		/// <summary>
		/// Future Sight counter - turns remaining until Future Sight attack hits.
		/// </summary>
		int FutureSightCounter { get; set; }

		/// <summary>
		/// Future Sight move - the move that will hit when counter reaches 0.
		/// </summary>
		int FutureSightMove { get; set; }

		/// <summary>
		/// Future Sight user index - battler index of the original user.
		/// </summary>
		int FutureSightUserIndex { get; set; }

		/// <summary>
		/// Future Sight user party index - party position of the original user.
		/// </summary>
		int FutureSightUserPartyIndex { get; set; }

		/// <summary>
		/// Healing Wish effect - provides healing when next battler switches in.
		/// </summary>
		bool HealingWish { get; set; }

		/// <summary>
		/// Lunar Dance effect - provides healing and PP restoration when next battler switches in.
		/// </summary>
		bool LunarDance { get; set; }

		/// <summary>
		/// Wish counter - turns remaining until Wish healing activates.
		/// </summary>
		int Wish { get; set; }

		/// <summary>
		/// Wish amount - HP amount that will be healed when Wish activates.
		/// </summary>
		int WishAmount { get; set; }

		/// <summary>
		/// Wish maker - battler index of the Pokemon that used Wish.
		/// </summary>
		int WishMaker { get; set; }
	}
}