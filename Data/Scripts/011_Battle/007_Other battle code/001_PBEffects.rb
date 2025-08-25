#===============================================================================
#
#===============================================================================
module PBEffects
  #-----------------------------------------------------------------------------
  # These effects apply to a battler.
  #-----------------------------------------------------------------------------

  AllySwitchRate      = 0
  AquaRing            = 1
  Attract             = 2
  BanefulBunker       = 3
  BeakBlast           = 4
  Bide                = 5
  BideDamage          = 6
  BideTarget          = 7
  BurningBulwark      = 8
  BurnUp              = 9
  Charge              = 10
  ChoiceBand          = 11
  Confusion           = 12
  Counter             = 13
  CounterTarget       = 14
  CudChewBerry        = 15
  CudChewCounter      = 16
  Curse               = 17
  Dancer              = 18
  DefenseCurl         = 19
  DestinyBond         = 20
  DestinyBondPrevious = 21
  DestinyBondTarget   = 22
  Disable             = 23
  DisableMove         = 24
  DoubleShock         = 25
  Electrify           = 26
  Embargo             = 27
  Encore              = 28
  EncoreMove          = 29
  Endure              = 30
  ExtraType           = 31
  FirstPledge         = 32
  FlashFire           = 33
  Flinch              = 34
  FocusEnergy         = 35
  FocusPunch          = 36
  FollowMe            = 37
  Foresight           = 38
  FuryCutter          = 39
  GastroAcid          = 40
  GemConsumed         = 41
  GigatonHammer       = 42
  Grudge              = 43
  HealBlock           = 44
  HelpingHand         = 45
  HyperBeam           = 46
  Illusion            = 47
  Imprison            = 48
  Ingrain             = 49
  Instruct            = 50
  Instructed          = 51
  JawLock             = 52
  KingsShield         = 53
  LaserFocus          = 54
  LeechSeed           = 55
  LockOn              = 56
  LockOnPos           = 57
  MagicBounce         = 58
  MagicCoat           = 59
  MagnetRise          = 60
  MeanLook            = 61
  MeFirst             = 62
  Metronome           = 63
  MicleBerry          = 64
  Minimize            = 65
  MiracleEye          = 66
  MirrorCoat          = 67
  MirrorCoatTarget    = 68
  MoveNext            = 69
  MudSport            = 70
  Nightmare           = 71
  NoRetreat           = 72
  Obstruct            = 73
  Octolock            = 74
  Outrage             = 75
  ParentalBond        = 76
  PerishSong          = 77
  PerishSongUser      = 78
  PickupItem          = 79
  PickupUse           = 80
  Pinch               = 81   # Battle Palace only
  Powder              = 82
  PowerTrick          = 83
  Prankster           = 84
  PriorityAbility     = 85
  PriorityItem        = 86
  Protect             = 87
  ProtectRate         = 88
  Quash               = 89
  Rage                = 90
  RagePowder          = 91   # Used along with FollowMe
  Rollout             = 92
  Roost               = 93
  SaltCure            = 94
  ShedTail            = 95   # Just prevents Substitute resetting upon switch
  ShellTrap           = 96
  SilkTrap            = 97
  SkyDrop             = 98
  SlowStart           = 99
  SmackDown           = 100
  Snatch              = 101
  SpikyShield         = 102
  Spotlight           = 103
  Stockpile           = 104
  StockpileDef        = 105
  StockpileSpDef      = 106
  Substitute          = 107
  SyrupBomb           = 108
  SyrupBombUser       = 109
  TarShot             = 110
  Taunt               = 111
  Telekinesis         = 112
  ThroatChop          = 113
  Torment             = 114
  Toxic               = 115
  Transform           = 116
  TransformSpecies    = 117
  Trapping            = 118   # Trapping move that deals EOR damage
  TrappingMove        = 119
  TrappingUser        = 120
  Truant              = 121
  TwoTurnAttack       = 122
  Unburden            = 123
  Uproar              = 124
  Vulnerable          = 125
  WaterSport          = 126
  WeightChange        = 127
  Yawn                = 128

  #-----------------------------------------------------------------------------
  # These effects apply to a battler position.
  #-----------------------------------------------------------------------------

  FutureSightCounter        = 700
  FutureSightMove           = 701
  FutureSightUserIndex      = 702
  FutureSightUserPartyIndex = 703
  HealingWish               = 704
  LunarDance                = 705
  Wish                      = 706
  WishAmount                = 707
  WishMaker                 = 708

  #-----------------------------------------------------------------------------
  # These effects apply to a side.
  #-----------------------------------------------------------------------------

  AuroraVeil         = 800
  CraftyShield       = 801
  EchoedVoiceCounter = 802
  EchoedVoiceUsed    = 803
  LastRoundFainted   = 804
  LightScreen        = 805
  LuckyChant         = 806
  MatBlock           = 807
  Mist               = 808
  QuickGuard         = 809
  Rainbow            = 810
  Reflect            = 811
  Round              = 812
  Safeguard          = 813
  SeaOfFire          = 814
  Spikes             = 815
  StealthRock        = 816
  StickyWeb          = 817
  Swamp              = 818
  Tailwind           = 819
  ToxicSpikes        = 820
  WideGuard          = 821

  #-----------------------------------------------------------------------------
  # These effects apply to the battle (i.e. both sides).
  #-----------------------------------------------------------------------------

  AmuletCoin      = 900
  FairyLock       = 901
  FusionBolt      = 902
  FusionFlare     = 903
  Gravity         = 904
  HappyHour       = 905
  IonDeluge       = 906
  MagicRoom       = 907
  MudSportField   = 908
  PayDay          = 909
  TrickRoom       = 910
  WaterSportField = 911
  WonderRoom      = 912
end
