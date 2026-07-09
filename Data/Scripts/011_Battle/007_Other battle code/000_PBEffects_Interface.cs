using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// These effects apply to a battler
	/// </summary>
	public interface IEffectsBattler {
		object this[int index]	{ get; set; }
		/// <summary>Aqua Ring continuous healing effect.</summary>
		bool AquaRing			{ get; set; }
		/// <summary>Attract infatuation effect.</summary>
		int Attract				{ get; set; }
		/// <summary>Baneful Bunker protection with poison on contact.</summary>
		int BanefulBunker		{ get; }
		//bool BatonPass			{ get; set; }
		/// <summary>Beak Blast charging state.</summary>
		int BeakBlast			{ get; }
		/// <summary>Bide charging state and turn counter.</summary>
		int Bide				{ get; set; }
		/// <summary>Bide accumulated damage amount.</summary>
		int BideDamage			{ get; set; }
		/// <summary>Bide original attacker target.</summary>
		int BideTarget			{ get; set; }
		/// <summary>Burning Bulwark protection with burn on contact.</summary>
		int BurningBulwark		{ get; }
		/// <summary>Burn Up temporary type loss.</summary>
		bool BurnUp				{ get; }
		/// <summary>Charge doubled Electric move power.</summary>
		int Charge				{ get; set; }
		/// <summary>Choice Band/Specs/Scarf locked move.</summary>
		int ChoiceBand			{ get; set; }
		/// <summary>Confusion status turn counter.</summary>
		int Confusion			{ get; set; }
		/// <summary>Counter damage amount to return.</summary>
		int Counter				{ get; set; }
		/// <summary>Counter original attacker target.</summary>
		int CounterTarget		{ get; set; } //ToDo: maybe `byte?` and do `.HasValue`?
		/// <summary>Curse effect for Ghost types (HP loss) or others (stat changes).</summary>
		bool Curse				{ get; set; }
		/// <summary>Dancer ability queued move copying.</summary>
		int Dancer				{ get; }
		/// <summary>Defense Curl doubled Rollout power.</summary>
		bool DefenseCurl		{ get; set; }
		/// <summary>Destiny Bond activation state.</summary>
		bool DestinyBond		{ get; set; }
		/// <summary>Destiny Bond previous use tracker.</summary>
		int DestinyBondPrevious	{ get; }
		/// <summary>Destiny Bond target battler.</summary>
		int DestinyBondTarget	{ get; }
		/// <summary>Disable effect turn counter.</summary>
		int Disable				{ get; set; }
		/// <summary>Disable affected move ID.</summary>
		int DisableMove			{ get; set; }
		/// <summary>Double Shock temporary type loss.</summary>
		bool DoubleShock		{ get; }
		/// <summary>Electrify next move becomes Electric type.</summary>
		bool Electrify			{ get; set; }
		/// <summary>Embargo item usage prevention.</summary>
		int Embargo				{ get; set; }
		/// <summary>Encore effect turn counter.</summary>
		int Encore				{ get; set; }
		//int EncoreIndex			{ get; set; }
		/// <summary>Encore forced move ID.</summary>
		int EncoreMove			{ get; set; }
		/// <summary>Endure survival at 1 HP.</summary>
		bool Endure				{ get; set; }
		/// <summary>Forest's Curse/Trick-or-Treat added type.</summary>
		int ExtraType			{ get; }
		/// <summary>First pledge move for combination attacks.</summary>
		int FirstPledge			{ get; set; }
		/// <summary>Flash Fire Fire move power boost.</summary>
		bool FlashFire			{ get; set; }
		/// <summary>Flinch effect preventing action this turn.</summary>
		bool Flinch				{ get; set; }
		/// <summary>Focus Energy increased critical hit ratio.</summary>
		int FocusEnergy			{ get; set; }
		/// <summary>Focus Punch charging state.</summary>
		int FocusPunch			{ get; }
		/// <summary>Follow Me/Rage Powder redirection effect.</summary>
		int FollowMe			{ get; set; }
		/// <summary>Foresight Normal/Fighting vs Ghost effectiveness.</summary>
		bool Foresight			{ get; set; }
		/// <summary>Fury Cutter consecutive use power multiplier.</summary>
		int FuryCutter			{ get; set; }
		//int FutureSight			{ get; set; }
		//int FutureSightMove		{ get; set; }
		//int FutureSightUser		{ get; set; }
		//int FutureSightUserPos	{ get; set; }
		/// <summary>Gastro Acid ability suppression.</summary>
		bool GastroAcid			{ get; set; }
		/// <summary>Gem item consumed this turn.</summary>
		int GemConsumed			{ get; }
		/// <summary>Grudge PP depletion on KO.</summary>
		bool Grudge				{ get; set; }
		/// <summary>Heal Block healing prevention.</summary>
		int HealBlock			{ get; set; }
		//bool HealingWish		{ get; set; }
		/// <summary>Helping Hand damage boost for ally.</summary>
		bool HelpingHand		{ get; set; }
		/// <summary>Hyper Beam recharge turn requirement.</summary>
		int HyperBeam			{ get; set; }
		/// <summary>Illusion disguise as party member.</summary>
		/// <remarks>Takes image of last person on team</remarks>
		IPokemon Illusion		{ get; set; }
		/// <summary>Imprison move usage prevention.</summary>
		bool Imprison			{ get; set; }
		/// <summary>Ingrain HP recovery and trapping.</summary>
		bool Ingrain			{ get; set; }
		/// <summary>Instruct forced move repetition.</summary>
		int Instruct			{ get; }
		/// <summary>Instructed battler marker.</summary>
		int Instructed			{ get; }
		/// <summary>Jaw Lock mutual trapping effect.</summary>
		int JawLock				{ get; }
		/// <summary>King's Shield protection with Attack reduction.</summary>
		bool KingsShield		{ get; set; }
		/// <summary>Laser Focus guaranteed critical hit next turn.</summary>
		int LaserFocus			{ get; }
		/// <summary>Leech Seed HP drain to user.</summary>
		int LeechSeed			{ get; set; }
		//bool LifeOrb			{ get; set; }
		/// <summary>Lock-On guaranteed hit next turn.</summary>
		int LockOn				{ get; set; }
		/// <summary>Lock-On target position.</summary>
		int LockOnPos			{ get; set; }
		//bool LunarDance			{ get; set; }
		/// <summary>Magic Bounce ability reflection state.</summary>
		int MagicBounce			{ get; }
		/// <summary>Magic Coat move reflection.</summary>
		bool MagicCoat			{ get; set; }
		/// <summary>Magnet Rise levitation immunity.</summary>
		int MagnetRise			{ get; set; }
		/// <summary>Mean Look escape prevention.</summary>
		int MeanLook			{ get; set; }
		/// <summary>Me First priority move copying.</summary>
		bool MeFirst			{ get; set; }
		/// <summary>Metronome power boost from repeated moves.</summary>
		int Metronome			{ get; set; }
		/// <summary>Micle Berry accuracy boost when activated.</summary>
		bool MicleBerry			{ get; set; }
		/// <summary>Minimize evasion boost and vulnerability to specific moves.</summary>
		bool Minimize			{ get; set; }
		/// <summary>Miracle Eye Psychic vs Dark effectiveness.</summary>
		bool MiracleEye			{ get; set; }
		/// <summary>Mirror Coat special damage return amount.</summary>
		int MirrorCoat			{ get; set; }
		/// <summary>Mirror Coat original attacker target.</summary>
		int MirrorCoatTarget	{ get; set; }
		/// <summary>Move next turn priority adjustment.</summary>
		bool MoveNext			{ get; set; }
		/// <summary>Mud Sport Electric move damage reduction.</summary>
		bool MudSport			{ get; set; }
		// <summary>Trapping move</summary>
		//int MultiTurn			{ get; set; }
		//int MultiTurnAttack	{ get; set; }
		//int MultiTurnUser		{ get; set; }
		/// <summary>Nightmare HP loss for sleeping Pokemon.</summary>
		bool Nightmare			{ get; set; }
		/// <summary>No Retreat stat boost with switching prevention.</summary>
		bool NoRetreat			{ get; }
		/// <summary>Obstruct protection with Defense reduction.</summary>
		int Obstruct			{ get; }
		/// <summary>Octolock Attack and Defense reduction over time.</summary>
		int Octolock			{ get; }
		/// <summary>Outrage/Petal Dance/Thrash confusion lock.</summary>
		int Outrage				{ get; set; }
		/// <summary>Parental Bond second hit damage reduction.</summary>
		int ParentalBond		{ get; set; }
		//bool ParentalBondApplied{ get; set; }
		/// <summary>Perish Song turn counter to fainting.</summary>
		int PerishSong			{ get; set; }
		/// <summary>Perish Song original user.</summary>
		int PerishSongUser		{ get; set; }
		/// <summary>Pickup item obtained after battle.</summary>
		int PickupItem			{ get; set; }
		/// <summary>Pickup item usage counter.</summary>
		int PickupUse			{ get; set; }
		/// <summary>Pinch status for Battle Palace AI.</summary>
		/// <remarks>Battle Palace only</remarks>
		bool Pinch				{ get; set; }
		/// <summary>Powder Fire move explosion protection.</summary>
		bool Powder				{ get; set; }
		/// <summary>Power Trick Attack and Defense stat swap.</summary>
		bool PowerTrick			{ get; set; }
		/// <summary>Prankster status move priority boost.</summary>
		int Prankster			{ get; }
		/// <summary>Priority ability activation marker.</summary>
		int PriorityAbility		{ get; }
		/// <summary>Priority item activation marker.</summary>
		int PriorityItem		{ get; }
		/// <summary>Protect/Detect protection success.</summary>
		bool Protect			{ get; set; }
		//bool ProtectNegation	{ get; set; }
		/// <summary>Protect consecutive use failure rate.</summary>
		short ProtectRate		{ get; set; }
		//bool Pursuit			{ get; set; }
		/// <summary>Quash forced last action in turn.</summary>
		bool Quash				{ get; set; }
		/// <summary>Rage Attack boost on taking damage.</summary>
		bool Rage				{ get; set; }
		/// <summary>Rage Powder redirection effect.</summary>
		int RagePowder			{ get; }
		//int Revenge				{ get; set; }
		//bool Roar				{ get; set; }
		/// <summary>Rollout/Ice Ball consecutive hit power multiplier.</summary>
		byte Rollout			{ get; set; }
		/// <summary>Roost temporary Flying type loss.</summary>
		bool Roost				{ get; set; }
		/// <summary>Shell Trap fire damage on physical contact.</summary>
		int ShellTrap			{ get; }
		/// <summary>Silk Trap protection with Speed reduction.</summary>
		int SilkTrap			{ get; }
		// <summary>For when using Poké Balls/Poké Dolls</summary>
		//bool SkipTurn			{ get; set; }
		/// <summary>Sky Drop lifting target into air.</summary>
		bool SkyDrop			{ get; set; }
		/// <summary>Slow Start halved Attack and Speed.</summary>
		int SlowStart			{ get; }
		/// <summary>Smack Down grounding and type effectiveness change.</summary>
		bool SmackDown			{ get; set; }
		/// <summary>Snatch status move stealing.</summary>
		bool Snatch				{ get; set; }
		/// <summary>Spiky Shield protection with damage on contact.</summary>
		bool SpikyShield		{ get; set; }
		/// <summary>Spotlight redirection to specific target.</summary>
		int Spotlight			{ get; }
		/// <summary>Stockpile energy storage counter.</summary>
		int Stockpile			{ get; set; }
		/// <summary>Stockpile Defense boost amount.</summary>
		int StockpileDef		{ get; set; }
		/// <summary>Stockpile Special Defense boost amount.</summary>
		int StockpileSpDef		{ get; set; }
		/// <summary>Substitute HP and damage absorption.</summary>
		int Substitute			{ get; set; }
		/// <summary>Tar Shot Fire weakness and Speed reduction.</summary>
		int TarShot				{ get; }
		/// <summary>Taunt status move prevention.</summary>
		int Taunt				{ get; set; }
		/// <summary>Telekinesis levitation and accuracy boost.</summary>
		int Telekinesis			{ get; set; }
		/// <summary>Throat Chop sound move prevention.</summary>
		int ThroatChop			{ get; }
		/// <summary>Torment consecutive move prevention.</summary>
		bool Torment			{ get; set; }
		/// <summary>Toxic increasing poison damage.</summary>
		int Toxic				{ get; set; }
		/// <summary>Transform species and move copying.</summary>
		bool Transform			{ get; set; }
		/// <summary>Transform copied species ID.</summary>
		int TransformSpecies	{ get; }
		/// <summary>Trapping move continuous damage effect.</summary>
		int Trapping			{ get; }
		/// <summary>Trapping move ID causing damage.</summary>
		int TrappingMove		{ get; }
		/// <summary>Trapping move original user.</summary>
		int TrappingUser		{ get; }
		/// <summary>Truant ability alternate turn skipping.</summary>
		bool Truant				{ get; set; }
		/// <summary>Two-turn attack preparation state.</summary>
		int TwoTurnAttack		{ get; set; }
		//int Type3				{ get; set; }
		/// <summary>Unburden Speed boost after item consumption.</summary>
		bool Unburden			{ get; set; }
		/// <summary>Uproar continuous sound damage effect.</summary>
		int Uproar				{ get; set; }
		//bool Uturn				{ get; set; }
		/// <summary>Water Sport Fire move damage reduction.</summary>
		bool WaterSport			{ get; set; }
		/// <summary>Weight change from moves like Autotomize.</summary>
		int WeightChange		{ get; set; }
		//int Wish				{ get; set; }
		//int WishAmount			{ get; set; }
		//int WishMaker			{ get; set; }
		/// <summary>Yawn delayed sleep turn counter.</summary>
		int Yawn				{ get; set; }

		IEffectsBattler initialize(bool batonpass);
	}
}