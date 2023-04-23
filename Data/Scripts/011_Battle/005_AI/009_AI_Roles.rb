class Battle::AI
  #=============================================================================
  #
  #=============================================================================
  # TODO: Reborn has the REVENGEKILLER role which compares mon's speed with
  #       opponent (only when deciding whether to switch mon in) - this
  #       comparison should be calculated when needed instead of being a role.
  module BattleRole
    PHAZER          = 0
    CLERIC          = 1
    STALL_BREAKER   = 2
    STATUS_ABSORBER = 3
    BATON_PASSER    = 4
    SPINNER         = 5
    FIELD_SETTER    = 6
    WEATHER_SETTER  = 7
    SWEEPER         = 8
    PIVOT           = 9
    PHYSICAL_WALL   = 10
    SPECIAL_WALL    = 11
    TANK            = 12
    TRAPPER         = 13
    SCREENER        = 14
    ACE             = 15
    LEAD            = 16
    SECOND          = 17
  end

  #-----------------------------------------------------------------------------

  # Determine the roles filled by a Pokémon on a given side at a given party
  # index.
  def determine_roles(side, index)
    pkmn = @battle.pbParty(side)[index]
    ret = []
    return ret if !pkmn || pkmn.egg?

    # Check for moves indicative of particular roles
    hasHealMove  = false
    hasPivotMove = false
    pkmn.moves.each do |m|
      next if !m
      move = Battle::Move.from_pokemon_move(@battle, m)
      hasHealMove = true if !hasHealMove && move.healingMove?
      case move.function
      when "SleepTargetNextTurn",   # Yawn
           "StartPerishCountsForAllBattlers",   # Perish Song
           "SwitchOutTargetStatusMove",   # Roar
           "SwitchOutTargetDamagingMove"   # Circle Throw
        ret.push(BattleRole::PHAZER)
      when "CureUserPartyStatus"   # Aromatherapy/Heal Bell
        ret.push(BattleRole::CLERIC)
      when "DisableTargetStatusMoves"   # Taunt
        ret.push(BattleRole::STALL_BREAKER)
      when "HealUserPositionNextTurn"   # Wish
        ret.push(BattleRole::CLERIC) if pkmn.ev[:HP] == Pokemon::EV_STAT_LIMIT
      when "HealUserFullyAndFallAsleep"   # Rest
        ret.push(BattleRole::STATUS_ABSORBER)
      when "SwitchOutUserPassOnEffects"   # Baton Pass
        ret.push(BattleRole::BATON_PASSER)
      when "SwitchOutUserStatusMove", "SwitchOutUserDamagingMove"   # Teleport (Gen 8+), U-turn
        hasPivotMove = true
      when "RemoveUserBindingAndEntryHazards"   # Rapid Spin
        ret.push(BattleRole::SPINNER)
      when "StartElectricTerrain", "StartGrassyTerrain",
           "StartMistyTerrain", "StartPsychicTerrain"   # Terrain moves
        ret.push(BattleRole::FIELD_SETTER)
      else
        ret.push(BattleRole::WEATHER_SETTER) if move.is_a?(Battle::Move::WeatherMove)
      end
    end

    # Check EVs, nature and moves for combinations indicative of particular roles
    if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
      if [:MODEST, :ADAMANT,   # SpAtk+ Atk-, Atk+ SpAtk-
          :TIMID, :JOLLY].include?(pkmn.nature)   # Spd+ Atk-, Spd+ SpAtk-
        ret.push(BattleRole::SWEEPER)
      end
    end
    if hasHealMove
      ret.push(BattleRole::PIVOT) if hasPivotMove
      if pkmn.nature.stat_changes.any? { |change| change[0] == :DEFENSE && change[1] > 0 } &&
         !pkmn.nature.stat_changes.any? { |change| change[0] == :DEFENSE && change[1] < 0 }
        ret.push(BattleRole::PHYSICAL_WALL) if pkmn.ev[:DEFENSE] == Pokemon::EV_STAT_LIMIT
      elsif pkmn.nature.stat_changes.any? { |change| change[0] == :SPECIAL_DEFENSE && change[1] > 0 } &&
            !pkmn.nature.stat_changes.any? { |change| change[0] == :SPECIAL_DEFENSE && change[1] < 0 }
        ret.push(BattleRole::SPECIAL_WALL) if pkmn.ev[:SPECIAL_DEFENSE] == Pokemon::EV_STAT_LIMIT
      end
    else
      ret.push(BattleRole::TANK) if pkmn.ev[:HP] == Pokemon::EV_STAT_LIMIT
    end

    # Check for abilities indicative of particular roles
    case pkmn.ability_id
    when :REGENERATOR
      ret.push(BattleRole::PIVOT)
    when :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, :NATURALCURE, :MAGICGUARD,
         :MAGICBOUNCE, :HYDRATION
      ret.push(BattleRole::STATUS_ABSORBER)
    when :SHADOWTAG, :ARENATRAP, :MAGNETPULL
      ret.push(BattleRole::TRAPPER)
    when :DROUGHT, :DRIZZLE, :SANDSTREAM, :SNOWWARNING, :PRIMORDIALSEA,
         :DESOLATELAND, :DELTASTREAM
      ret.push(BattleRole::WEATHER_SETTER)
    when :GRASSYSURGE, :ELECTRICSURGE, :MISTYSURGE, :PSYCHICSURGE
      ret.push(BattleRole::FIELD_SETTER)
    end

    # Check for items indicative of particular roles
    case pkmn.item_id
    when :LIGHTCLAY
      ret.push(BattleRole::SCREENER)
    when :ASSAULTVEST
      ret.push(BattleRole::TANK)
    when :CHOICEBAND, :CHOICESPECS
      ret.push(BattleRole::STALL_BREAKER)
      ret.push(BattleRole::SWEEPER) if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
    when :CHOICESCARF
      ret.push(BattleRole::SWEEPER) if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
    when :TOXICORB, :FLAMEORB
      ret.push(BattleRole::STATUS_ABSORBER)
    when :TERRAINEXTENDER
      ret.push(BattleRole::FIELD_SETTER)
    end

    # Check for position in team, level relative to other levels in team
    partyStarts = @battle.pbPartyStarts(side)
    if partyStarts.include?(index + 1) || index == @battle.pbParty(side).length - 1
      ret.push(BattleRole::ACE)
    else
      ret.push(BattleRole::LEAD) if partyStarts.include?(index)
      idxTrainer = @battle.pbGetOwnerIndexFromPartyIndex(side, index)
      maxLevel = @battle.pbMaxLevelInTeam(side, idxTrainer)
      if pkmn.level >= maxLevel
        ret.push(BattleRole::SECOND)
      else
        secondHighest = true
        seenHigherLevel = false
        @battle.eachInTeam(side, @battle.pbGetOwnerIndexFromPartyIndex(side, index)) do |p|
          next if p.level < pkmn.level
          if seenHigherLevel
            secondHighest = false
            break
          end
          seenHigherLevel = true
        end
        # NOTE: There can be multiple "second"s if all their levels are equal
        #       and the highest in the team (and none are the ace).
        ret.push(BattleRole::SECOND) if secondHighest
      end
    end

    return ret
  end

  def check_role(side, idxBattler, *roles)
    role_array = @roles[side][idxBattler]
    roles.each do |r|
      return true if role_array.include?(r)
    end
    return false
  end

  def check_battler_role(battler, *roles)
    side = idxParty.idxOwnSide
    idxParty = idxParty.pokemonIndex
    return check_role(side, idxParty, *roles)
  end
end
