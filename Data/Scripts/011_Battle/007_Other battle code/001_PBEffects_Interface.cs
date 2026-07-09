using System;

namespace PokemonEssentials
{
	/// <summary>
	/// Interface for Pokemon battle effects constants module.
	/// Defines all battle effect IDs used throughout the battle system for tracking
	/// temporary conditions, status effects, and special states on battlers, sides, and fields.
	/// Effects are organized by scope: battler effects, position effects, side effects, and field effects.
	/// </summary>
	public interface IPBEffects { //}
		/// <summary>
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		/// ToDo: Convert property effects to a dictionary for better management and access.
		object this[int index]	{ get; set; }
	/// <summary>
	/// These effects apply to a battler
	/// </summary>
	// Battler Effects (0-199)
	//public interface IEffectsBattler : IPBEffects
	//{
		/// <summary>Aqua Ring continuous healing effect.</summary>
		int AquaRing			{ get; }
		/// <summary>Attract infatuation effect.</summary>
		int Attract				{ get; }
		/// <summary>Baneful Bunker protection with poison on contact.</summary>
		int BanefulBunker		{ get; }
		/// <summary>Beak Blast charging state.</summary>
		int BeakBlast			{ get; }
		/// <summary>Bide charging state and turn counter.</summary>
		int Bide				{ get; }
		/// <summary>Bide accumulated damage amount.</summary>
		int BideDamage			{ get; }
		/// <summary>Bide original attacker target.</summary>
		int BideTarget			{ get; }
		/// <summary>Burning Bulwark protection with burn on contact.</summary>
		int BurningBulwark		{ get; }
		/// <summary>Burn Up temporary type loss.</summary>
		int BurnUp				{ get; }
		/// <summary>Charge doubled Electric move power.</summary>
		int Charge				{ get; }
		/// <summary>Choice Band/Specs/Scarf locked move.</summary>
		int ChoiceBand			{ get; }
		/// <summary>Confusion status turn counter.</summary>
		int Confusion			{ get; }
		/// <summary>Counter damage amount to return.</summary>
		int Counter				{ get; }
		/// <summary>Counter original attacker target.</summary>
		int CounterTarget		{ get; }
		/// <summary>Curse effect for Ghost types (HP loss) or others (stat changes).</summary>
		int Curse				{ get; }
		/// <summary>Dancer ability queued move copying.</summary>
		int Dancer				{ get; }
		/// <summary>Defense Curl doubled Rollout power.</summary>
		int DefenseCurl		{ get; }
		/// <summary>Destiny Bond activation state.</summary>
		int DestinyBond		{ get; }
		/// <summary>Destiny Bond previous use tracker.</summary>
		int DestinyBondPrevious	{ get; }
		/// <summary>Destiny Bond target battler.</summary>
		int DestinyBondTarget	{ get; }
		/// <summary>Disable effect turn counter.</summary>
		int Disable				{ get; }
		/// <summary>Disable affected move ID.</summary>
		int DisableMove			{ get; }
		/// <summary>Double Shock temporary type loss.</summary>
		int DoubleShock		{ get; }
		/// <summary>Electrify next move becomes Electric type.</summary>
		int Electrify			{ get; }
		/// <summary>Embargo item usage prevention.</summary>
		int Embargo				{ get; }
		/// <summary>Encore effect turn counter.</summary>
		int Encore				{ get; }
		//int EncoreIndex			{ get; set; }
		/// <summary>Encore forced move ID.</summary>
		int EncoreMove			{ get; }
		/// <summary>Endure survival at 1 HP.</summary>
		int Endure				{ get; }
		/// <summary>Forest's Curse/Trick-or-Treat added type.</summary>
		int ExtraType			{ get; }
		/// <summary>First pledge move for combination attacks.</summary>
		int FirstPledge			{ get; }
		/// <summary>Flash Fire Fire move power boost.</summary>
		int FlashFire			{ get; }
		/// <summary>Flinch effect preventing action this turn.</summary>
		int Flinch				{ get; }
		/// <summary>Focus Energy increased critical hit ratio.</summary>
		int FocusEnergy			{ get; }
		/// <summary>Focus Punch charging state.</summary>
		int FocusPunch			{ get; }
		/// <summary>Follow Me/Rage Powder redirection effect.</summary>
		int FollowMe			{ get; }
		/// <summary>Foresight Normal/Fighting vs Ghost effectiveness.</summary>
		int Foresight			{ get; }
		/// <summary>Fury Cutter consecutive use power multiplier.</summary>
		int FuryCutter			{ get; }
		//int FutureSight			{ get; set; }
		//int FutureSightMove		{ get; set; }
		//int FutureSightUser		{ get; set; }
		//int FutureSightUserPos	{ get; set; }
		/// <summary>Gastro Acid ability suppression.</summary>
		int GastroAcid			{ get; }
		/// <summary>Gem item consumed this turn.</summary>
		int GemConsumed			{ get; }
		/// <summary>Grudge PP depletion on KO.</summary>
		int Grudge				{ get; }
		/// <summary>Heal Block healing prevention.</summary>
		int HealBlock			{ get; }
		//int HealingWish		{ get; set; }
		/// <summary>Helping Hand damage boost for ally.</summary>
		int HelpingHand		{ get; }
		/// <summary>Hyper Beam recharge turn requirement.</summary>
		int HyperBeam			{ get; }
		/// <summary>Illusion disguise as party member.</summary>
		/// <remarks>Takes image of last person on team</remarks>
		int Illusion		{ get; }
		/// <summary>Imprison move usage prevention.</summary>
		int Imprison			{ get; }
		/// <summary>Ingrain HP recovery and trapping.</summary>
		int Ingrain			{ get; }
		/// <summary>Instruct forced move repetition.</summary>
		int Instruct			{ get; }
		/// <summary>Instructed battler marker.</summary>
		int Instructed			{ get; }
		/// <summary>Jaw Lock mutual trapping effect.</summary>
		int JawLock				{ get; }
		/// <summary>King's Shield protection with Attack reduction.</summary>
		int KingsShield		{ get; }
		/// <summary>Laser Focus guaranteed critical hit next turn.</summary>
		int LaserFocus			{ get; }
		/// <summary>Leech Seed HP drain to user.</summary>
		int LeechSeed			{ get; }
		//int LifeOrb			{ get; set; }
		/// <summary>Lock-On guaranteed hit next turn.</summary>
		int LockOn				{ get; }
		/// <summary>Lock-On target position.</summary>
		int LockOnPos			{ get; }
		//int LunarDance			{ get; set; }
		/// <summary>Magic Bounce ability reflection state.</summary>
		int MagicBounce			{ get; }
		/// <summary>Magic Coat move reflection.</summary>
		int MagicCoat			{ get; }
		/// <summary>Magnet Rise levitation immunity.</summary>
		int MagnetRise			{ get; }
		/// <summary>Mean Look escape prevention.</summary>
		int MeanLook			{ get; }
		/// <summary>Me First priority move copying.</summary>
		int MeFirst			{ get; }
		/// <summary>Metronome power boost from repeated moves.</summary>
		int Metronome			{ get; }
		/// <summary>Micle Berry accuracy boost when activated.</summary>
		int MicleBerry			{ get; }
		/// <summary>Minimize evasion boost and vulnerability to specific moves.</summary>
		int Minimize			{ get; }
		/// <summary>Miracle Eye Psychic vs Dark effectiveness.</summary>
		int MiracleEye			{ get; }
		/// <summary>Mirror Coat special damage return amount.</summary>
		int MirrorCoat			{ get; }
		/// <summary>Mirror Coat original attacker target.</summary>
		int MirrorCoatTarget	{ get; }
		/// <summary>Move next turn priority adjustment.</summary>
		int MoveNext			{ get; }
		/// <summary>Mud Sport Electric move damage reduction.</summary>
		int MudSport			{ get; }
		// <summary>Trapping move</summary>
		//int MultiTurn			{ get; set; }
		//int MultiTurnAttack	{ get; set; }
		//int MultiTurnUser		{ get; set; }
		/// <summary>Nightmare HP loss for sleeping Pokemon.</summary>
		int Nightmare			{ get; }
		/// <summary>No Retreat stat boost with switching prevention.</summary>
		int NoRetreat			{ get; }
		/// <summary>Obstruct protection with Defense reduction.</summary>
		int Obstruct			{ get; }
		/// <summary>Octolock Attack and Defense reduction over time.</summary>
		int Octolock			{ get; }
		/// <summary>Outrage/Petal Dance/Thrash confusion lock.</summary>
		int Outrage				{ get; }
		/// <summary>Parental Bond second hit damage reduction.</summary>
		int ParentalBond		{ get; }
		//int ParentalBondApplied{ get; set; }
		/// <summary>Perish Song turn counter to fainting.</summary>
		int PerishSong			{ get; }
		/// <summary>Perish Song original user.</summary>
		int PerishSongUser		{ get; }
		/// <summary>Pickup item obtained after battle.</summary>
		int PickupItem			{ get; }
		/// <summary>Pickup item usage counter.</summary>
		int PickupUse			{ get; }
		/// <summary>Pinch status for Battle Palace AI.</summary>
		/// <remarks>Battle Palace only</remarks>
		int Pinch				{ get; }
		/// <summary>Powder Fire move explosion protection.</summary>
		int Powder				{ get; }
		/// <summary>Power Trick Attack and Defense stat swap.</summary>
		int PowerTrick			{ get; }
		/// <summary>Prankster status move priority boost.</summary>
		int Prankster			{ get; }
		/// <summary>Priority ability activation marker.</summary>
		int PriorityAbility		{ get; }
		/// <summary>Priority item activation marker.</summary>
		int PriorityItem		{ get; }
		/// <summary>Protect/Detect protection success.</summary>
		int Protect			{ get; }
		//int ProtectNegation	{ get; set; }
		/// <summary>Protect consecutive use failure rate.</summary>
		int ProtectRate		{ get; }
		//int Pursuit			{ get; set; }
		/// <summary>Quash forced last action in turn.</summary>
		int Quash				{ get; }
		/// <summary>Rage Attack boost on taking damage.</summary>
		int Rage				{ get; }
		/// <summary>Rage Powder redirection effect.</summary>
		int RagePowder			{ get; }
		//int Revenge				{ get; set; }
		//int Roar				{ get; set; }
		/// <summary>Rollout/Ice Ball consecutive hit power multiplier.</summary>
		int Rollout				{ get; }
		/// <summary>Roost temporary Flying type loss.</summary>
		int Roost				{ get; }
		/// <summary>Shell Trap fire damage on physical contact.</summary>
		int ShellTrap			{ get; }
		/// <summary>Silk Trap protection with Speed reduction.</summary>
		int SilkTrap			{ get; }
		// <summary>For when using Poké Balls/Poké Dolls</summary>
		//int SkipTurn			{ get; set; }
		/// <summary>Sky Drop lifting target into air.</summary>
		int SkyDrop			{ get; }
		/// <summary>Slow Start halved Attack and Speed.</summary>
		int SlowStart			{ get; }
		/// <summary>Smack Down grounding and type effectiveness change.</summary>
		int SmackDown			{ get; }
		/// <summary>Snatch status move stealing.</summary>
		int Snatch				{ get; }
		/// <summary>Spiky Shield protection with damage on contact.</summary>
		int SpikyShield		{ get; }
		/// <summary>Spotlight redirection to specific target.</summary>
		int Spotlight			{ get; }
		/// <summary>Stockpile energy storage counter.</summary>
		int Stockpile			{ get; }
		/// <summary>Stockpile Defense boost amount.</summary>
		int StockpileDef		{ get; }
		/// <summary>Stockpile Special Defense boost amount.</summary>
		int StockpileSpDef		{ get; }
		/// <summary>Substitute HP and damage absorption.</summary>
		int Substitute			{ get; }
		/// <summary>Tar Shot Fire weakness and Speed reduction.</summary>
		int TarShot				{ get; }
		/// <summary>Taunt status move prevention.</summary>
		int Taunt				{ get; }
		/// <summary>Telekinesis levitation and accuracy boost.</summary>
		int Telekinesis			{ get; }
		/// <summary>Throat Chop sound move prevention.</summary>
		int ThroatChop			{ get; }
		/// <summary>Torment consecutive move prevention.</summary>
		int Torment			{ get; }
		/// <summary>Toxic increasing poison damage.</summary>
		int Toxic				{ get; }
		/// <summary>Transform species and move copying.</summary>
		int Transform			{ get; }
		/// <summary>Transform copied species ID.</summary>
		int TransformSpecies	{ get; }
		/// <summary>Trapping move continuous damage effect.</summary>
		int Trapping			{ get; }
		/// <summary>Trapping move ID causing damage.</summary>
		int TrappingMove		{ get; }
		/// <summary>Trapping move original user.</summary>
		int TrappingUser		{ get; }
		/// <summary>Truant ability alternate turn skipping.</summary>
		int Truant				{ get; }
		/// <summary>Two-turn attack preparation state.</summary>
		int TwoTurnAttack		{ get; }
		//int Type3				{ get; set; }
		/// <summary>Unburden Speed boost after item consumption.</summary>
		int Unburden			{ get; }
		/// <summary>Uproar continuous sound damage effect.</summary>
		int Uproar				{ get; }
		//int Uturn				{ get; set; }
		/// <summary>Water Sport Fire move damage reduction.</summary>
		int WaterSport			{ get; }
		/// <summary>Weight change from moves like Autotomize.</summary>
		int WeightChange		{ get; }
		//int Wish				{ get; set; }
		//int WishAmount			{ get; set; }
		//int WishMaker			{ get; set; }
		/// <summary>Yawn delayed sleep turn counter.</summary>
		int Yawn				{ get; }
	//}
	/// <summary>
	/// These effects apply to a battler position.
	/// </summary>
	// Position Effects (700-799)
	//public interface IEffectsPosition : IPBEffects
	//{
		/// <summary>Future Sight turn counter until attack hits.</summary>
		int FutureSightCounter			{ get; }
		/// <summary>Future Sight stored move data.</summary>
		int FutureSightMove				{ get; }
		/// <summary>Future Sight original user battler index.</summary>
		int FutureSightUserIndex		{ get; }
		/// <summary>Future Sight original user party position.</summary>
		int FutureSightUserPartyIndex	{ get; }
		/// <summary>Healing Wish revival and healing effect.</summary>
		int HealingWish				{ get; }
		/// <summary>Lunar Dance revival, healing, and PP restoration.</summary>
		int LunarDance					{ get; }
		/// <summary>Wish delayed healing turn counter.</summary>
		int Wish						{ get; }
		/// <summary>Wish healing amount to be restored.</summary>
		int WishAmount					{ get; }
		/// <summary>Wish original user party position.</summary>
		int WishMaker					{ get; }
	//}
	/// <summary>
	/// These effects apply to a side
	/// </summary>
	// Side Effects (800-899)
	//public interface IEffectsSide : IPBEffects
	//{
		/// <summary>Aurora Veil physical and special damage reduction.</summary>
		int AuroraVeil			{ get; }
		/// <summary>Crafty Shield status move protection for team.</summary>
		int CraftyShield		{ get; }
		/// <summary>Echoed Voice consecutive use counter for power boost.</summary>
		int EchoedVoiceCounter	{ get; }
		/// <summary>Echoed Voice used this turn marker.</summary>
		int EchoedVoiceUsed		{ get; }
		/// <summary>Last round fainted battler tracking.</summary>
		int LastRoundFainted	{ get; }
		/// <summary>Light Screen special attack damage reduction.</summary>
		int LightScreen			{ get; }
		/// <summary>Lucky Chant critical hit prevention.</summary>
		int LuckyChant			{ get; }
		/// <summary>Mat Block physical move protection for team.</summary>
		int MatBlock			{ get; }
		/// <summary>Mist stat reduction prevention.</summary>
		int Mist				{ get; }
		/// <summary>Quick Guard priority move protection for team.</summary>
		int QuickGuard			{ get; }
		/// <summary>Rainbow secondary effect chance doubling.</summary>
		int Rainbow				{ get; }
		/// <summary>Reflect physical attack damage reduction.</summary>
		int Reflect				{ get; }
		/// <summary>Round power boost from team coordination.</summary>
		int Round				{ get; }
		/// <summary>Safeguard status condition prevention.</summary>
		int Safeguard			{ get; }
		/// <summary>Sea of Fire continuous damage to non-Fire types.</summary>
		int SeaOfFire			{ get; }
		/// <summary>Spikes entry hazard damage layers (0-3).</summary>
		int Spikes				{ get; }
		/// <summary>Stealth Rock entry hazard type-based damage.</summary>
		int StealthRock			{ get; }
		/// <summary>Sticky Web entry hazard Speed reduction.</summary>
		int StickyWeb			{ get; }
		/// <summary>Swamp Speed reduction for non-Grass types.</summary>
		int Swamp				{ get; }
		/// <summary>Tailwind Speed doubling for team.</summary>
		int Tailwind			{ get; }
		/// <summary>Toxic Spikes entry hazard poison layers (0-2).</summary>
		int ToxicSpikes			{ get; }
		/// <summary>Wide Guard spread move protection for team.</summary>
		int WideGuard			{ get; }
	//}
	/// <summary>
	/// These effects apply to the battle (i.e. both sides)
	/// </summary>
	// Field Effects (900-999)
	//public interface IEffectsField : IPBEffects
	//{
		/// <summary>Amulet Coin prize money doubling.</summary>
		int AmuletCoin		{ get; }
		/// <summary>Fairy Lock switching prevention for all battlers.</summary>
		int FairyLock		{ get; }
		/// <summary>Fusion Bolt boost for next Fusion Flare.</summary>
		int FusionBolt		{ get; }
		/// <summary>Fusion Flare boost for next Fusion Bolt.</summary>
		int FusionFlare		{ get; }
		/// <summary>Gravity increased accuracy and grounding.</summary>
		int Gravity			{ get; }
		/// <summary>Happy Hour prize money doubling.</summary>
		int HappyHour		{ get; }
		/// <summary>Ion Deluge Normal moves become Electric type.</summary>
		int IonDeluge		{ get; }
		/// <summary>Magic Room held item effect negation.</summary>
		int MagicRoom		{ get; }
		/// <summary>Mud Sport field-wide Electric move weakness.</summary>
		int MudSportField	{ get; }
		/// <summary>Pay Day accumulated money from attacks.</summary>
		int PayDay			{ get; }
		/// <summary>Trick Room reversed Speed priority.</summary>
		int TrickRoom		{ get; }
		/// <summary>Water Sport field-wide Fire move weakness.</summary>
		int WaterSportField	{ get; }
		/// <summary>Wonder Room Defense and Special Defense stat swap.</summary>
		int WonderRoom		{ get; }
	}
}