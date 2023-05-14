class PokeBattle_AI
  #=============================================================================
  #
  #=============================================================================
  # TODO: Reborn has the REVENGEKILLER role which compares mon's speed with
  #       opponent (only when deciding whether to switch mon in) - this
  #       comparison should be calculated when needed instead of being a role.
  module BattleRole
    PHAZER         = 0
    CLERIC         = 1
    STALLBREAKER   = 2
    STATUSABSORBER = 3
    BATONPASSER    = 4
    SPINNER        = 5
    FIELDSETTER    = 6
    WEATHERSETTER  = 7
    SWEEPER        = 8
    PIVOT          = 9
    PHYSICALWALL   = 10
    SPECIALWALL    = 11
    TANK           = 12
    TRAPPER        = 13
    SCREENER       = 14
    ACE            = 15
    LEAD           = 16
    SECOND         = 17
  end

  #=============================================================================
  # Determine the roles filled by a Pokémon on a given side at a given party
  # index.
  #=============================================================================
  def determine_roles(side, index)
    pkmn = @battle.pbParty(side)[index]
    ret = []
    return ret if !pkmn || pkmn.egg?

    # Check for moves indicative of particular roles
    hasHealMove  = false
    hasPivotMove = false
    pkmn.moves.each do |m|
      next if !m
      move = PokeBattle_Move.pbFromPBMove(@battle, m)
      hasHealMove = true if !hasHealMove && move.healingMove?
      case move.function
      when "004", "0E5", "0EB", "0EC"   # Yawn, Perish Song, Roar, Circle Throw
        ret.push(BattleRole::PHAZER)
      when "019"   # Aromatherapy/Heal Bell
        ret.push(BattleRole::CLERIC)
      when "0BA"   # Taunt
        ret.push(BattleRole::STALLBREAKER)
      when "0D7"   # Wish
        ret.push(BattleRole::CLERIC) if pkmn.ev[PBStats::HP] == PokeBattle_Pokemon::EV_STAT_LIMIT
      when "0D9"   # Rest
        ret.push(BattleRole::STATUSABSORBER)
      when "0ED"   # Baton Pass
        ret.push(BattleRole::BATONPASSER)
      when "0EE"   # U-turn
        hasPivotMove = true
      when "110"   # Rapid Spin
        ret.push(BattleRole::SPINNER)
      when "154", "155", "156", "173"   # Terrain moves
        ret.push(BattleRole::FIELDSETTER)
      else
        ret.push(BattleRole::WEATHERSETTER) if move.is_a?(PokeBattle_WeatherMove)
      end
    end

    # Check EVs, nature and moves for combinations indicative of particular roles
    if pkmn.ev[PBStats::SPEED] == PokeBattle_Pokemon::EV_STAT_LIMIT
      if [PBNatures::MODEST, PBNatures::ADAMANT,   # SpAtk+ Atk-, Atk+ SpAtk-
          PBNatures::TIMID, PBNatures::JOLLY].include?(pkmn.nature)   # Spd+ Atk-, Spd+ SpAtk-
        ret.push(BattleRole::SWEEPER)
      end
    end
    if hasHealMove
      ret.push(BattleRole::PIVOT) if hasPivotMove
      if PBNatures.getStatRaised(pkmn.nature) == PBStats::DEFENSE &&
         PBNatures.getStatLowered(pkmn.nature) != PBStats::DEFENSE
        ret.push(BattleRole::PHYSICALWALL) if pkmn.ev[PBStats::DEFENSE] == PokeBattle_Pokemon::EV_STAT_LIMIT
      elsif PBNatures.getStatRaised(pkmn.nature) == PBStats::SPDEF &&
            PBNatures.getStatLowered(pkmn.nature) != PBStats::SPDEF
        ret.push(BattleRole::SPECIALWALL) if pkmn.ev[PBStats::SPDEF] == PokeBattle_Pokemon::EV_STAT_LIMIT
      end
    else
      ret.push(BattleRole::TANK) if pkmn.ev[PBStats::HP] == PokeBattle_Pokemon::EV_STAT_LIMIT
    end

    # Check for abilities indicative of particular roles
    case pkmn.ability_id
    when :REGENERATOR
      ret.push(BattleRole::PIVOT)
    when :GUTS, :QUICKFEET, :FLAREBOOST, :TOXICBOOST, :NATURALCURE, :MAGICGUARD,
         :MAGICBOUNCE, :HYDRATION
      ret.push(BattleRole::STATUSABSORBER)
    when :SHADOWTAG, :ARENATRAP, :MAGNETPULL
      ret.push(BattleRole::TRAPPER)
    when :DROUGHT, :DRIZZLE, :SANDSTREAM, :SNOWWARNING, :PRIMORDIALSEA,
         :DESOLATELAND, :DELTASTREAM
      ret.push(BattleRole::WEATHERSETTER)
    when :GRASSYSURGE, :ELECTRICSURGE, :MISTYSURGE, :PSYCHICSURGE
      ret.push(BattleRole::FIELDSETTER)
    end

    # Check for items indicative of particular roles
    case pkmn.item_id
    when :LIGHTCLAY
      ret.push(BattleRole::SCREENER)
    when :ASSAULTVEST
      ret.push(BattleRole::TANK)
    when :CHOICEBAND, :CHOICESPECS
      ret.push(BattleRole::STALLBREAKER)
      ret.push(BattleRole::SWEEPER) if pkmn.ev[PBStats::SPEED] == PokeBattle_Pokemon::EV_STAT_LIMIT
    when :CHOICESCARF
      ret.push(BattleRole::SWEEPER) if pkmn.ev[PBStats::SPEED] == PokeBattle_Pokemon::EV_STAT_LIMIT
    when :TOXICORB, :FLAMEORB
      ret.push(BattleRole::STATUSABSORBER)
    when :TERRAINEXTENDER
      ret.push(BattleRole::FIELDSETTER)
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
        @battle.eachInTeam(side, @battle.pbGetOwnerIndexFromPartyIndex(side, index)).each do |p|
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
