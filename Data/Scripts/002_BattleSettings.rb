#===============================================================================
#
#===============================================================================
module Settings
  #-----------------------------------------------------------------------------
  # UI.
  #-----------------------------------------------------------------------------

  # The background graphic moves sideways at the start of battle, along with the
  # side bases and the trainer(s)/Pokémon. If this is true, the background will
  # not move (the bases/trainers/Pokémon still will).
  DISABLE_SLIDING_BACKGROUND          = false
  # Whether the main color of a move's name in the Fight menu in battle matches
  # the pixel at coordinate (10,34) in cursor_fight.png for that move's type
  # (true), or whether the move name's color is the default black (false).
  BATTLE_MOVE_NAME_COLOR_FROM_GRAPHIC = true
  # Whether the data box for a selected Pokémon in battle (either because you're
  # choosing a command for it or targeting it) moves up and down a little.
  BOB_BATTLE_DATA_BOX_IF_SELECTED     = true
  # Whether the sprite of a selected Pokémon in battle (when choosing a command
  # for it) moves up and down a little.
  BOB_BATTLER_SPRITE_IF_SELECTED      = true
  # Whether the sprite of a selected Pokémon in battle (when targeting it)
  # flashes visible/invisible.
  FLASH_BATTLER_SPRITE_IF_TARGETED    = true
  # Whether the command UI will hide the buttons for useless commands (e.g.
  # "Run" if you're not allowed to run from battle, or "Bag" if the "disableBag"
  # battle rule is applied).
  HIDE_USELESS_BATTLE_COMMANDS        = true

  #-----------------------------------------------------------------------------
  # Turn order and disobedience.
  #-----------------------------------------------------------------------------

  # Whether turn order is recalculated after a Pokémon Mega Evolves.
  RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION = (MECHANICS_GENERATION >= 7)
  # Whether turn order is recalculated after a Pokémon's Speed stat changes.
  RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES  = (MECHANICS_GENERATION >= 8)
  # Whether any Pokémon (originally owned by the player or foreign) can disobey
  # the player's commands if the Pokémon is too high a level compared to the
  # number of Gym Badges the player has.
  ANY_HIGH_LEVEL_POKEMON_CAN_DISOBEY          = false
  # Whether foreign Pokémon can disobey the player's commands if the Pokémon is
  # too high a level compared to the number of Gym Badges the player has.
  FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY      = true

  #-----------------------------------------------------------------------------
  # Mega Evolution.
  #-----------------------------------------------------------------------------

  # The Game Switch which, while ON, prevents all Pokémon in battle from Mega
  # Evolving even if they otherwise could.
  NO_MEGA_EVOLUTION = 34

  #-----------------------------------------------------------------------------
  # Move usage calculations.
  #-----------------------------------------------------------------------------

  # Whether a move's physical/special category depends on the move itself as in
  # newer Gens (true), or on its type as in older Gens (false).
  MOVE_CATEGORY_PER_MOVE           = (MECHANICS_GENERATION >= 4)
  # Whether critical hits do 1.5x damage and have 4 stages (true), or they do 2x
  # damage and have 5 stages as in Gen 5 (false). Also determines whether
  # critical hit rate can be copied by Transform/Psych Up.
  NEW_CRITICAL_HIT_RATE_MECHANICS  = (MECHANICS_GENERATION >= 6)
  # Whether several effects apply relating to a Pokémon's type:
  #   * Electric-type immunity to paralysis.
  #   * Ghost-type immunity to being trapped.
  #   * Grass-type immunity to powder moves and Effect Spore.
  #   * Poison-type Pokémon can't miss when using Toxic.
  MORE_TYPE_EFFECTS                = (MECHANICS_GENERATION >= 6)
  # The minimum number of Gym Badges required to boost each stat of a player's
  # Pokémon by 1.1x, in battle only.
  NUM_BADGES_BOOST_ATTACK          = (MECHANICS_GENERATION >= 4) ? 999 : 1
  NUM_BADGES_BOOST_DEFENSE         = (MECHANICS_GENERATION >= 4) ? 999 : 5
  NUM_BADGES_BOOST_SPECIAL_ATTACK  = (MECHANICS_GENERATION >= 4) ? 999 : 7
  NUM_BADGES_BOOST_SPECIAL_DEFENSE = (MECHANICS_GENERATION >= 4) ? 999 : 7
  NUM_BADGES_BOOST_SPEED           = (MECHANICS_GENERATION >= 4) ? 999 : 3

  #-----------------------------------------------------------------------------
  # Move, ability and item effects.
  #-----------------------------------------------------------------------------

  # Whether a battle's default weather or default terrain can (false) or cannot
  # (true) be overridden by an ability or move inducing another weather type.
  # This doesn't apply to the primal weathers (harsh sun, heavy rain, strong
  # winds), which can replace the default weather.
  DEFAULT_WEATHER_AND_TERRAIN_CANNOT_BE_REPLACED = (MECHANICS_GENERATION >= 9)
  # Whether the in-battle hail weather is replaced by Snowstorm (from Gen 9+)
  # instead. Affects the weather started by the Ability Snow Warning and the
  # default battle weather if it is hailing in the overworld.
  USE_SNOWSTORM_WEATHER_INSTEAD_OF_HAIL          = (MECHANICS_GENERATION >= 9)
  # Whether weather caused by an ability lasts 5 rounds (true) or forever (false).
  FIXED_DURATION_WEATHER_FROM_ABILITY            = (MECHANICS_GENERATION >= 6)
  # Whether held items stolen from a wild target by a player's Pokémon using
  # Covet/Thief go straight into the player's Bag (true) or end up being held by
  # the Pokémon that used Covet/Thief (false).
  STOLEN_HELD_ITEMS_GO_INTO_BAG                  = (MECHANICS_GENERATION >= 9)
  # Whether X items (X Attack, etc.) raise their stat by 2 stages (true) or 1
  # (false).
  X_STAT_ITEMS_RAISE_BY_TWO_STAGES               = (MECHANICS_GENERATION >= 7)
  # Whether some Poké Balls have catch rate multipliers from Gen 7+ (true) or
  # from earlier generations (false).
  NEW_POKE_BALL_CATCH_RATES                      = (MECHANICS_GENERATION >= 7)
  # Whether Soul Dew powers up Psychic and Dragon-type moves by 20% (true) or
  # raises the holder's Special Attack and Special Defense by 50% (false).
  SOUL_DEW_POWERS_UP_TYPES                       = (MECHANICS_GENERATION >= 7)
  # Whether Greninja's Battle Bond ability makes it change into Ash-Greninja
  # (false) or raises its Attack/Sp. Atk/Speed (true) when it knocks out a
  # target. Either way, it only happens once per battle.
  GRENINJA_BATTLE_BOND_RAISES_STATS              = (MECHANICS_GENERATION >= 9)

  #-----------------------------------------------------------------------------
  # Affection.
  #-----------------------------------------------------------------------------

  # Whether Pokémon with high happiness will gain more Exp from battles, have a
  # chance of avoiding/curing negative effects by themselves, resisting
  # fainting, etc.
  AFFECTION_EFFECTS        = false
  # Whether a Pokémon's happiness is limited to 179, and can only be increased
  # further with friendship-raising berries. Related to AFFECTION_EFFECTS by
  # default because affection effects only start applying above a happiness of
  # 179. Also lowers the happiness evolution threshold to 160.
  APPLY_HAPPINESS_SOFT_CAP = AFFECTION_EFFECTS

  #-----------------------------------------------------------------------------
  # Capturing Pokémon.
  #-----------------------------------------------------------------------------

  # Whether it is easier for wild Pokémon below level 13 to be caught.
  CATCH_RATE_BONUS_FOR_LOW_LEVEL                      = (MECHANICS_GENERATION >= 8)
  # If the player has fewer Gym Badges than this, the chance of catching any
  # wild Pokémon whose level is higher than the player's Pokémon will be divided
  # by 10. 0 means this penalty never applies. Note that this shouldn't be used
  # with the CATCH_RATE_PENALTY_IF_POKEMON_WILL_NOT_OBEY Setting.
  NUM_BADGES_TO_NOT_MAKE_HIGHER_LEVEL_CAPTURES_HARDER = (MECHANICS_GENERATION == 8) ? 8 : 0
  # If true, wild Pokémon that would disobey the player because of their level
  # (except if it's within 5 levels of the maximum obedience level) will be
  # harder to catch. Note that this shouldn't be used with the
  # NUM_BADGES_TO_NOT_MAKE_HIGHER_LEVEL_CAPTURES_HARDER Setting.
  CATCH_RATE_PENALTY_IF_POKEMON_WILL_NOT_OBEY         = (MECHANICS_GENERATION >= 9)
  # Whether the critical capture mechanic applies. Note that its calculation is
  # based on a total of 600+ species (i.e. that many species need to be caught
  # to provide the greatest critical capture chance of 2.5x), and there may be
  # fewer species in your game.
  ENABLE_CRITICAL_CAPTURES                            = (MECHANICS_GENERATION >= 5)
  # Whether the player is asked what to do with a newly caught Pokémon if their
  # party is full. If true, the player can toggle whether they are asked this in
  # the Options screen.
  NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER                = (MECHANICS_GENERATION >= 7)

  #-----------------------------------------------------------------------------
  # Exp and EV gain.
  #-----------------------------------------------------------------------------

  # Whether the Exp gained from beating a Pokémon should be scaled depending on
  # the gainer's level.
  SCALED_EXP_FORMULA                    = (MECHANICS_GENERATION == 5 || MECHANICS_GENERATION >= 7)
  # Whether the Exp gained from beating a Pokémon should be divided equally
  # between each participant (true), or whether each participant should gain
  # that much Exp (false). This also applies to Exp gained via the Exp Share
  # (held item version) being distributed to all Exp Share holders.
  SPLIT_EXP_BETWEEN_GAINERS             = (MECHANICS_GENERATION <= 5)
  # Whether the Exp gained from beating a Pokémon is multiplied by 1.5 if that
  # Pokémon is owned by another trainer.
  MORE_EXP_FROM_TRAINER_POKEMON         = (MECHANICS_GENERATION <= 6)
  # Whether the Exp gained from beating a Pokémon is multiplied by 1.2 if that
  # Pokémon evolves by levelling up at/above a specific level and is at/above
  # that level.
  MORE_EXP_AT_EVOLUTION_LEVEL_OR_HIGHER = (MECHANICS_GENERATION >= 6)
  # Whether a Pokémon holding a Power item gains 8 (true) or 4 (false) EVs in
  # the relevant stat.
  MORE_EVS_FROM_POWER_ITEMS             = (MECHANICS_GENERATION >= 7)
  # Whether Pokémon gain Exp for capturing a Pokémon.
  GAIN_EXP_FOR_CAPTURE                  = (MECHANICS_GENERATION >= 6)

  #-----------------------------------------------------------------------------
  # End of battle.
  #-----------------------------------------------------------------------------

  # Whether the Run command in trainer battles allows the player to end the
  # battle as their loss (true) or does nothing (false).
  CAN_FORFEIT_TRAINER_BATTLES         = (MECHANICS_GENERATION >= 9)
  # The Game Switch which, while ON, prevents the player from losing money if
  # they lose a battle (they can still gain money from trainers for winning).
  NO_MONEY_LOSS                       = 33
  # Whether held items that have been consumed (except for berries) will be
  # recovered at the end of a battle.
  RESTORE_HELD_ITEMS_AFTER_BATTLE     = (MECHANICS_GENERATION >= 9)
  # Whether party Pokémon check if they can evolve after all battles regardless
  # of the outcome (true), or only after battles the player won (false).
  CHECK_EVOLUTION_AFTER_ALL_BATTLES   = (MECHANICS_GENERATION >= 6)
  # Whether fainted Pokémon can try to evolve after a battle.
  CHECK_EVOLUTION_FOR_FAINTED_POKEMON = true

  #-----------------------------------------------------------------------------
  # AI.
  #-----------------------------------------------------------------------------

  # Whether wild Pokémon with the "Legendary", "Mythical" or "UltraBeast" flag
  # (as defined in pokemon.txt) have a smarter AI. Their skill level is set to
  # 32, which is a medium skill level.
  SMARTER_WILD_LEGENDARY_POKEMON = true
end
