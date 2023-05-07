#===============================================================================
#
#===============================================================================
class Battle::AI
  # Determine the roles filled by a Pokémon on a given side at a given party
  # index.
  # Roles are:
  #   :ace
  #   :baton_passer
  #   :cleric
  #   :field_setter
  #   :lead
  #   :phazer
  #   :physical_wall
  #   :pivot
  #   :screener
  #   :second
  #   :special_wall
  #   :spinner
  #   :stall_breaker
  #   :status_absorber
  #   :sweeper
  #   :tank
  #   :trapper
  #   :weather_setter
  # NOTE: Reborn has the REVENGEKILLER role which compares mon's speed with
  #       opponent (only when deciding whether to switch mon in) - this
  #       comparison should be calculated when needed instead of being a role.
  def determine_roles(side, index)
    pkmn = @battle.pbParty(side)[index]
    ret = []
    return ret if !pkmn || pkmn.egg?
    # Check for moves indicative of particular roles
    hasHealMove = false
    pkmn.moves.each do |m|
      next if !m
      move = Battle::Move.from_pokemon_move(@battle, m)
      hasHealMove = true if !hasHealMove && move.healingMove?
      case move.function
      when "SleepTargetNextTurn",   # Yawn
           "StartPerishCountsForAllBattlers",   # Perish Song
           "SwitchOutTargetStatusMove",   # Roar
           "SwitchOutTargetDamagingMove"   # Circle Throw
        ret.push(:phazer)
      when "CureUserPartyStatus"   # Aromatherapy/Heal Bell
        ret.push(:cleric)
      when "DisableTargetStatusMoves"   # Taunt
        ret.push(:stall_breaker)
      when "HealUserPositionNextTurn"   # Wish
        ret.push(:cleric) if pkmn.ev[:HP] == Pokemon::EV_STAT_LIMIT
      when "HealUserFullyAndFallAsleep"   # Rest
        ret.push(:status_absorber)
      when "SwitchOutUserPassOnEffects"   # Baton Pass
        ret.push(:baton_passer)
      when "SwitchOutUserStatusMove", "SwitchOutUserDamagingMove"   # Teleport (Gen 8+), U-turn
        ret.push(:pivot) if hasHealMove
      when "RemoveUserBindingAndEntryHazards"   # Rapid Spin
        ret.push(:spinner)
      when "StartElectricTerrain", "StartGrassyTerrain",
           "StartMistyTerrain", "StartPsychicTerrain"   # Terrain moves
        ret.push(:field_setter)
      else
        ret.push(:weather_setter) if move.is_a?(Battle::Move::WeatherMove)
      end
    end
    # Check EVs, nature and moves for combinations indicative of particular roles
    if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
      if [:MODEST, :ADAMANT,   # SpAtk+ Atk-, Atk+ SpAtk-
          :TIMID, :JOLLY].include?(pkmn.nature)   # Spd+ Atk-, Spd+ SpAtk-
        ret.push(:sweeper)
      end
    end
    if hasHealMove
      if pkmn.nature.stat_changes.any? { |change| change[0] == :DEFENSE && change[1] > 0 } &&
         !pkmn.nature.stat_changes.any? { |change| change[0] == :DEFENSE && change[1] < 0 }
        ret.push(:physical_wall) if pkmn.ev[:DEFENSE] == Pokemon::EV_STAT_LIMIT
      elsif pkmn.nature.stat_changes.any? { |change| change[0] == :SPECIAL_DEFENSE && change[1] > 0 } &&
            !pkmn.nature.stat_changes.any? { |change| change[0] == :SPECIAL_DEFENSE && change[1] < 0 }
        ret.push(:special_wall) if pkmn.ev[:SPECIAL_DEFENSE] == Pokemon::EV_STAT_LIMIT
      end
    else
      ret.push(:tank) if pkmn.ev[:HP] == Pokemon::EV_STAT_LIMIT
    end
    # Check for abilities indicative of particular roles
    case pkmn.ability_id
    when :REGENERATOR
      ret.push(:pivot)
    when :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, :NATURALCURE, :MAGICGUARD,
         :MAGICBOUNCE, :HYDRATION
      ret.push(:status_absorber)
    when :SHADOWTAG, :ARENATRAP, :MAGNETPULL
      ret.push(:trapper)
    when :DROUGHT, :DRIZZLE, :SANDSTREAM, :SNOWWARNING, :PRIMORDIALSEA,
         :DESOLATELAND, :DELTASTREAM
      ret.push(:weather_setter)
    when :GRASSYSURGE, :ELECTRICSURGE, :MISTYSURGE, :PSYCHICSURGE
      ret.push(:field_setter)
    end
    # Check for items indicative of particular roles
    case pkmn.item_id
    when :LIGHTCLAY
      ret.push(:screener)
    when :ASSAULTVEST
      ret.push(:tank)
    when :CHOICEBAND, :CHOICESPECS
      ret.push(:stall_breaker)
      ret.push(:sweeper) if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
    when :CHOICESCARF
      ret.push(:sweeper) if pkmn.ev[:SPEED] == Pokemon::EV_STAT_LIMIT
    when :TOXICORB, :FLAMEORB
      ret.push(:status_absorber)
    when :TERRAINEXTENDER
      ret.push(:field_setter)
    end
    # Check for position in team, level relative to other levels in team
    partyStarts = @battle.pbPartyStarts(side)
    if partyStarts.include?(index + 1) || index == @battle.pbParty(side).length - 1
      ret.push(:ace)   # Last in party, assumed to be the best Pokémon
    else
      ret.push(:lead) if partyStarts.include?(index)   # First in party
      idxTrainer = @battle.pbGetOwnerIndexFromPartyIndex(side, index)
      maxLevel = @battle.pbMaxLevelInTeam(side, idxTrainer)
      if pkmn.level >= maxLevel
        ret.push(:second)
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
        ret.push(:second) if secondHighest
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
