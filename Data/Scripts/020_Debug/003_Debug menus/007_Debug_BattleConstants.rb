 
#===============================================================================
# # Field Effects
#===============================================================================

# These effects apply to a battler
BATTLER_EFFECTS = {
    PBEffects::AquaRing            => {:name => "Aqua Ring"},
    PBEffects::BanefulBunker       => {:name => "Baneful Bunker"},
    PBEffects::BeakBlast           => {:name => "Beak Blast"},
    PBEffects::BideDamage          => {:name => "Bide Damage"},
    PBEffects::BurnUp              => {:name => "Burn Up"},
    PBEffects::Charge              => {:name => "Charge"}, 
    PBEffects::ChoiceBand          => {:name => "Choice Band",:type => :MOVEID}, # Move ID (default -1)
    PBEffects::Confusion           => {:name => "Confusion"},
    PBEffects::Curse               => {:name => "Curse"},
    PBEffects::DefenseCurl         => {:name => "Defense Curl"},
    PBEffects::Disable             => {:name => "Disable"},
    PBEffects::DisableMove         => {:name => "Disable Move",:type => :MOVEID}, # Move ID (default -1})
    PBEffects::Electrify           => {:name => "Electrify"},
    PBEffects::Embargo             => {:name => "Embargo"},
    PBEffects::Encore              => {:name => "Encore"},
    PBEffects::EncoreMove          => {:name => "Encore Move",:type => :MOVEID}, # Move ID (default -1)
    PBEffects::Endure              => {:name => "Endure"},
    PBEffects::FlashFire           => {:name => "Flash Fire"},
    PBEffects::Flinch              => {:name => "Flinch"},
    PBEffects::FocusEnergy         => {:name => "Focus Energy"}, # is set to 2 by Essentials when active
    PBEffects::FocusPunch          => {:name => "Focus Punch"},
    PBEffects::FollowMe            => {:name => "Follow Me"}, #  ist set to 1 by Essentials when active
    PBEffects::Foresight           => {:name => "Foresight"},
    PBEffects::FuryCutter          => {:name => "Fury Cutter"},
    PBEffects::GastroAcid          => {:name => "Gastro Acid"},
    PBEffects::Grudge              => {:name => "Grudge"},
    PBEffects::HealBlock           => {:name => "Heal Block"},
    PBEffects::HelpingHand         => {:name => "Helping Hand"},
    PBEffects::HyperBeam           => {:name => "Hyper Beam"},
    PBEffects::Imprison            => {:name => "Imprison"},
    PBEffects::Ingrain             => {:name => "Ingrain"},
    PBEffects::Instruct            => {:name => "Instruct"},
    PBEffects::Instructed          => {:name => "Instructed"},
    PBEffects::KingsShield         => {:name => "Kings Shield"},
    PBEffects::LaserFocus          => {:name => "Laser Focus"}, # is set to 2 by Essentials when active
    PBEffects::LeechSeed           => {:name => "Leech Seed",:type => :USERINDEX}, # User index (so game knows where to put the HP)
    PBEffects::LockOn              => {:name => "Lock On"}, # is set to 2 by Essentials when active
    PBEffects::LockOnPos           => {:name => "Lock On Position"}, # Target Index
    PBEffects::MagicBounce         => {:name => "Magic Bounce"},
    PBEffects::MagicCoat           => {:name => "Magic Coat"},
    PBEffects::MagnetRise          => {:name => "Magnet Rise"},
    PBEffects::MeanLook            => {:name => "Mean Look",:type => :USERINDEX}, # User Index (so the game knows when the user left the field and target can switch out again) (default -1)
    PBEffects::MeFirst             => {:name => "Me First"},
    PBEffects::Metronome           => {:name => "Metronome (Item)"},
    PBEffects::Minimize            => {:name => "Minimize"},
    PBEffects::MiracleEye          => {:name => "Miracle Eye"},
    PBEffects::MudSport            => {:name => "Mud Sport"},
    PBEffects::Nightmare           => {:name => "Nightmare"},
    PBEffects::Outrage             => {:name => "Outrage"},
    PBEffects::PerishSong          => {:name => "Perish Song"},
    PBEffects::PerishSongUser      => {:name => "Perish Song User",:type => :USERINDEX}, # User Index (so the game knows how to judge for win/loss) (default -1)
    PBEffects::Powder              => {:name => "Powder"},
    PBEffects::PowerTrick          => {:name => "Power Trick"},
    PBEffects::Protect             => {:name => "Protect"},
    PBEffects::ProtectRate         => {:name => "Protect Rate"},
    PBEffects::Pursuit             => {:name => "Pursuit"},
    PBEffects::Quash               => {:name => "Quash"},
    PBEffects::Rage                => {:name => "Rage"},
    PBEffects::RagePowder          => {:name => "Rage Powder"}, # Used along with FollowMe
    PBEffects::Rollout             => {:name => "Rollout"},
    PBEffects::Roost               => {:name => "Roost"},
    PBEffects::ShellTrap           => {:name => "Shell Trap"},
    PBEffects::SlowStart           => {:name => "Slow Start"},
    PBEffects::SmackDown           => {:name => "Smack Down"},
    PBEffects::Snatch              => {:name => "Snatch"}, # is set to 1 by Essentials when active
    PBEffects::SpikyShield         => {:name => "Spiky Shield"},
    PBEffects::Spotlight           => {:name => "Spotlight"},
    PBEffects::Stockpile           => {:name => "Stockpile"},
    PBEffects::StockpileDef        => {:name => "Stockpile Def"},
    PBEffects::StockpileSpDef      => {:name => "Stockpile Sp. Def"},
    PBEffects::Substitute          => {:name => "Substitute"}, # Substitutes HP
    PBEffects::Taunt               => {:name => "Taunt"},
    PBEffects::Telekinesis         => {:name => "Telekinesis"},
    PBEffects::ThroatChop          => {:name => "Throat Chop"}, # is set to 3 by Essentials when active
    PBEffects::Torment             => {:name => "Torment"},
    PBEffects::Toxic               => {:name => "Toxic"},
    PBEffects::Truant              => {:name => "Truant"},
    PBEffects::Unburden            => {:name => "Unburden"},
    PBEffects::Uproar              => {:name => "Uproar"},
    PBEffects::WaterSport          => {:name => "Water Sport"},
    PBEffects::WeightChange        => {:name => "Weight Change"},
    PBEffects::Yawn                => {:name => "Yawn"}
}


# These effects apply to a side
SIDE_EFFECTS = {
    PBEffects::AuroraVeil         => {:name => "Aurora Veil"},
    PBEffects::CraftyShield       => {:name => "Crafty Shield"},
    PBEffects::EchoedVoiceCounter => {:name => "Echoed Voice Counter"},
    PBEffects::EchoedVoiceUsed    => {:name => "Echoed Voice Used"},
    PBEffects::LastRoundFainted   => {:name => "Last Round Fainted (Turn Count)"}, # Turn Count
    PBEffects::LightScreen        => {:name => "Light Screen"},
    PBEffects::LuckyChant         => {:name => "Lucky Chant"},
    PBEffects::MatBlock           => {:name => "Mat Block"},
    PBEffects::Mist               => {:name => "Mist"},
    PBEffects::QuickGuard         => {:name => "Quick Guard"},
    PBEffects::Rainbow            => {:name => "Rainbow"},
    PBEffects::Reflect            => {:name => "Reflect"},
    PBEffects::Round              => {:name => "Round"},
    PBEffects::Safeguard          => {:name => "Safeguard"},
    PBEffects::SeaOfFire          => {:name => "Sea Of Fire"}, 
    PBEffects::Spikes             => {:name => "Spikes"},
    PBEffects::StealthRock        => {:name => "Stealth Rock"},
    PBEffects::StickyWeb          => {:name => "Sticky Web"},
    PBEffects::Swamp              => {:name => "Swamp"}, 
    PBEffects::Tailwind           => {:name => "Tailwind"},
    PBEffects::ToxicSpikes        => {:name => "Toxic Spikes"},
    PBEffects::WideGuard          => {:name => "Wide Guard"},
}

# These effects apply to the battle (i.e. both sides)
FIELD_EFFECTS = {
    PBEffects::AmuletCoin      => { :name => "Amulet Coin"},
    PBEffects::FairyLock       => { :name => "Fairy Lock"},
    PBEffects::FusionBolt      => { :name => "Fusion Bolt"},
    PBEffects::FusionFlare     => { :name => "Fusion Flare"},
    PBEffects::Gravity         => { :name => "Gravity"},
    PBEffects::HappyHour       => { :name => "Happy Hour"},
    PBEffects::IonDeluge       => { :name => "Ion Deluge"},
    PBEffects::MagicRoom       => { :name => "Magic Room"},
    PBEffects::MudSportField   => { :name => "Mud Sport Field"},
    PBEffects::PayDay          => { :name => "Pay Day"},
    PBEffects::TrickRoom       => { :name => "Trick Room"},
    PBEffects::WaterSportField => { :name => "Water Sport Field"},
    PBEffects::WonderRoom      => { :name => "Wonder Room"},
}
  

  
BATTLE_METADATA = {
    :time           => { :name => "Time of day (mechanic only)"},
    :environment    => { :name => "Battle surrounding (mechanic only)"},
    :turnCount      => { :name => "Turn count"},
    :items          => { :name => "Opponent items"},
    :internalBattle => { :name => "Internal Battle"},
    :switchStyle    => { :name => "Switch Style"},
    :expGain        => { :name => "Allow EXP/EV Gain"},
  }

BATTLE_STATS = {
  :ATTACK           => {:name => "Attack"},
  :DEFENSE          => {:name => "Defense"},
  :SPECIAL_ATTACK   => {:name => "Sp. Attack"},
  :SPECIAL_DEFENSE  => {:name => "Sp. Defense"},
  :SPEED            => {:name => "Speed"},
  :ACCURACY         => {:name => "Accuracy"},
  :EVASION          => {:name => "Evasion"},
}
