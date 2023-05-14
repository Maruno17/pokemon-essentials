class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctions(score)
    case @move.function
    #---------------------------------------------------------------------------
    when "000"   # No extra effect
    #---------------------------------------------------------------------------
    when "001"   # Splash (does nothing)
    #---------------------------------------------------------------------------
    when "002"   # Struggle
    #---------------------------------------------------------------------------
    when "003"   # Make target fall asleep
      # Can't use Dark Void if user isn't Darkrai
      if NEWEST_BATTLE_MECHANICS && @move.id == :DARKVOID
        return 0 if !@user.isSpecies?(:DARKRAI) &&
                    @user.effects[PBEffects::TransformSpecies] != :DARKRAI
      end
      # Check whether the target can be put to sleep
      if @target.pbCanSleep?(@user, false) && @target.effects[PBEffects::Yawn] == 0
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.3

        # Prefer if user has a move that depends on the target being asleep
        mini_score *= 1.5 if @user.pbHasMoveFunction?("0DE", "10F")   # Dream Eater, Nightmare
        # Prefer if user has an ability that depends on the target being asleep
        mini_score *= 1.5 if skill_check(AILevel.medium) && @user.hasActiveAbility?(:BADDREAMS)
        # Prefer if user has certain roles
        mini_score *= 1.2 if check_battler_role(@user, BattleRole::PHYSICALWALL,
           BattleRole::SPECIALWALL, BattleRole::CLERIC, BattleRole::PIVOT)
        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).
        # Prefer if user knows some moves that work with stalling tactics
        mini_score *= 1.5 if @user.pbHasMoveFunction?("0DC", "10C")   # Leech Seed, Substitute
        # Prefer if user can heal at the end of each round
        # TODO: Needs to account for more healing effects. Aqua Ring, Black
        #       Sludge, etc.
        if skill_check(AILevel.medium) &&
           (@user.hasActiveItem?(:LEFTOVERS) ||
           (@user.hasActiveAbility?(:POISONHEAL) && user.poisoned?))
          mini_score *= 1.2
        end

        # Prefer if target is at full HP
        mini_score *= 1.2 if @target.hp == @target.totalhp
        # Prefer if target's stats are raised
        sum_stages = 0
        PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Don't prefer if target is confused or infatuated
        mini_score *= 0.6 if @target.effects[PBEffects::Confusion] > 0
        mini_score *= 0.7 if @target.effects[PBEffects::Attract] >= 0
        # TODO: Don't prefer if target has previously used a move that is usable
        #       while asleep.
        mini_score *= 0.1 if check_for_move(@target) { |move| move.usableWhenAsleep? }
        # Don't prefer if target can cure itself, benefits from being asleep, or
        # can pass sleep back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            return (@move.statusMove?) ? 0 : score
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.7
          when :SYNCHRONIZE
            mini_score *= 0.3 if !@user.pbHasAnyStatus?
          end
        end

        # Prefer if user is faster than the target
        mini_score *= 1.3 if @user_faster
        # TODO: Prefer if user's moves won't do much damage to the target.

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "004"   # Yawn (target falls asleep at end of next round)
      return 0 if @target.effects[PBEffects::Yawn] > 0 || !@target.pbCanSleep?(@user, false)
      mini_score = 1.0
      # Inherently prefer
      mini_score *= 1.2

      # Prefer if user has a move that depends on the target being asleep
      mini_score *= 1.4 if @user.pbHasMoveFunction?("0DE", "10F")   # Dream Eater, Nightmare
      # Prefer if user has an ability that depends on the target being asleep
      mini_score *= 1.4 if skill_check(AILevel.medium) && @user.hasActiveAbility?(:BADDREAMS)
      # Prefer if user has certain roles
      mini_score *= 1.2 if check_battler_role(@user, BattleRole::PHYSICALWALL,
         BattleRole::SPECIALWALL, BattleRole::CLERIC, BattleRole::PIVOT)

      # Prefer if target is at full HP
      mini_score *= 1.2 if @target.hp == @target.totalhp
      # Prefer if target's stats are raised
      sum_stages = 0
      PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
      mini_score *= 1 + sum_stages * 0.1 if sum_stages > 0
      # Don't prefer if target is confused or infatuated
      mini_score *= 0.4 if @target.effects[PBEffects::Confusion] > 0
      mini_score *= 0.5 if @target.effects[PBEffects::Attract] >= 0
      # TODO: Don't prefer if target has previously used a move that is usable
      #       while asleep.
      mini_score *= 0.1 if check_for_move(@target) { |move| move.usableWhenAsleep? }
      # Don't prefer if target can cure itself, benefits from being asleep, or
      # can pass sleep back to the user
      # TODO: Check for other effects to list here.
      if skill_check(AILevel.best) && @target.abilityActive?
        case @target.ability_id
        when :SHEDSKIN
          return 0
        when :HYDRATION
          return 0 if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
        when :NATURALCURE
          mini_score *= 0.1
        when :MARVELSCALE
          mini_score *= 0.8
        end
      end

      # TODO: Prefer if user's moves won't do much damage to the target.

      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "005", "0BE"   # Poison the target
      if @target.pbCanPoison?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.2

        # Prefer if user has a move that benefits from the target being poisoned
        mini_score *= 1.6 if @user.pbHasMoveFunction?("08B", "140")   # Venoshock, Venom Drench
        # Prefer if user has an ability that benefits from the target being poisoned
        mini_score *= 1.6 if skill_check(AILevel.medium) && @user.hasActiveAbility?(:MERCILESS)
        # Prefer if user has certain roles
        mini_score *= 1.5 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)

        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::DEFENSE, PBStats::SPDEF, PBStats::EVASION].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Prefer if target has Sturdy
        if skill_check(AILevel.best) && @target.hasActiveAbility?(:STURDY) && @move.damagingMove?
          mini_score *= 1.1
        end
        # Don't prefer if target is yawning
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # TODO: Don't prefer if target has previously used a move that benefits
        #       from being poisoned or can clear poisoning.
        mini_score *= 0.2 if check_for_move(@target) { |move| move.function == "07E" }   # Facade
        mini_score *= 0.1 if check_for_move(@target) { |move| move.function == "0D9" }   # Rest
        # Don't prefer if target can cure itself, benefits from being poisoned,
        # or can pass poisoning back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :TOXICBOOST, :GUTS, :QUICKFEET
            mini_score *= 0.2
          when :POISONHEAL, :MAGICGUARD
            mini_score *= 0.1
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.7
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # TODO: Prefer if user's moves won't do much damage to the target.

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "006"   # Badly poison the target (Toxic)
      if @target.pbCanPoison?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.3

        # Prefer if user has a move that benefits from the target being poisoned
        mini_score *= 1.6 if @user.pbHasMoveFunction?("08B", "140")   # Venoshock, Venom Drench
        # Prefer if user has an ability that benefits from the target being poisoned
        mini_score *= 1.6 if skill_check(AILevel.medium) && @user.hasActiveAbility?(:MERCILESS)
        # Prefer if user has certain roles
        mini_score *= 1.6 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
        # Prefer if status move and user is Poison-type (can't miss)
        mini_score *= 1.1 if NEWEST_BATTLE_MECHANICS && @move.statusMove? &&
                             @user.pbHasType?(:POISON)

        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::DEFENSE, PBStats::SPDEF, PBStats::EVASION].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Prefer if target has Sturdy
        if skill_check(AILevel.best) && @target.hasActiveAbility?(:STURDY) && @move.damagingMove?
          mini_score *= 1.1
        end
        # TODO: Prefer if target has previously used a HP-restoring move.
        mini_score *= 2 if check_for_move(@target) { |move| move.healingMove? }
        # Don't prefer if target is yawning
        mini_score *= 0.1 if @target.effects[PBEffects::Yawn] > 0
        # TODO: Don't prefer if target has previously used a move that benefits
        #       from being poisoned or can clear poisoning.
        mini_score *= 0.3 if check_for_move(@target) { |move| move.function == "07E" }   # Facade
        mini_score *= 0.1 if check_for_move(@target) { |move| move.function == "0D9" }   # Rest
        # Don't prefer if target can cure itself, benefits from being poisoned,
        # or can pass poisoning back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :TOXICBOOST, :GUTS, :QUICKFEET
            mini_score *= 0.2
          when :POISONHEAL, :MAGICGUARD
            mini_score *= 0.1
          when :NATURALCURE
            mini_score *= 0.2
          when :MARVELSCALE
            mini_score *= 0.8
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # TODO: Prefer if user's moves won't do much damage to the target.

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "007", "0C5"   # Paralyse the target
      return 0 if @move.id == :THUNDERWAVE &&
                  PBTypeEffectiveness.ineffective?(pbCalcTypeMod(@move.type, @user, @target))

      if @target.pbCanParalyze?(@user, false)
        mini_score = 1.0

        # Prefer if user has certain roles
        mini_score *= 1.2 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL, BattleRole::PIVOT)
        mini_score *= 1.3 if check_battler_role(@user, BattleRole::TANK)
        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target is at full HP
        mini_score *= 1.2 if @target.hp == @target.totalhp
        # Prefer if target is confused or infatuated
        mini_score *= 1.1 if @target.effects[PBEffects::Confusion] > 0
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Don't prefer if target is yawning
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :GUTS, :QUICKFEET
            mini_score *= 0.2
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.5
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # Prefer if user is slower than the target but will be faster if target
        # is paralysed
        if !@user_faster && skill_check(AILevel.best) && !@target.hasActiveAbility?(:QUICKFEET)
          user_speed   = pbRoughStat(@user, PBStats::SPEED)
          target_speed = pbRoughStat(@target, PBStats::SPEED)
          paralysis_factor = (NEWEST_BATTLE_MECHANICS) ? 2 : 4
          if (user_speed > target_speed / paralysis_factor) ^ (@battle.field.effects[PBEffects::TrickRoom] > 0)
            mini_score *= 1.5
          end
        end

        # Prefer if any Pokémon in the user's party has the Sweeper role
        @battle.eachInTeamFromBattlerIndex(@user.index) do |_pkmn, idxParty|
          next if !check_role(@user.idxOwnSide, idxParty, BattleRole::SWEEPER)
          mini_score *= 1.1
          break
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "008"   # Paralyse the target, weather-dependent accuracy
      mini_score = 1.0

      # TODO: Prefer if user is slower and target has previously used a move
      #       that makes it semi-invulnerable in the air (Fly, Bounce, Sky Drop).
      if !@user_faster
        if check_for_move(@target) { |move| ["0C9", "0CC", "0CE"].include?(move.function) }
          mini_score *= 1.2
        end
      end

      if @target.pbCanParalyze?(@user, false) && @target.effects[PBEffects::Yawn] == 0
        # Prefer if user has certain roles
        mini_score *= 1.2 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL, BattleRole::PIVOT)
        mini_score *= 1.3 if check_battler_role(@user, BattleRole::TANK)
        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target is at full HP
        mini_score *= 1.2 if @target.hp == @target.totalhp
        # Prefer if target is confused or infatuated
        mini_score *= 1.1 if @target.effects[PBEffects::Confusion] > 0
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :GUTS, :QUICKFEET
            mini_score *= 0.2
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.5
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # Prefer if user is slower than the target but will be faster if target
        # is paralysed
        if !@user_faster && skill_check(AILevel.best) && !@target.hasActiveAbility?(:QUICKFEET)
          user_speed   = pbRoughStat(@user, PBStats::SPEED)
          target_speed = pbRoughStat(@target, PBStats::SPEED)
          paralysis_factor = (NEWEST_BATTLE_MECHANICS) ? 2 : 4
          if (user_speed > target_speed / paralysis_factor) ^ (@battle.field.effects[PBEffects::TrickRoom] > 0)
            mini_score *= 1.5
          end
        end

        # Prefer if any Pokémon in the user's party has the Sweeper role
        @battle.eachInTeamFromBattlerIndex(@user.index) do |_pkmn, idxParty|
          next if !check_role(@user.idxOwnSide, idxParty, BattleRole::SWEEPER)
          mini_score *= 1.1
          break
        end
      else
        return 0 if @move.statusMove?
      end
      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "009"   # Paralyse the target, make the target flinch
      if @target.pbCanParalyze?(@user, false)
        mini_score = 1.0

        # Prefer if user has certain roles
        mini_score *= 1.2 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL, BattleRole::PIVOT)
        mini_score *= 1.1 if check_battler_role(@user, BattleRole::TANK)
        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target is at full HP
        mini_score *= 1.1 if @target.hp == @target.totalhp
        # Prefer if target is confused or infatuated
        mini_score *= 1.1 if @target.effects[PBEffects::Confusion] > 0
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :GUTS, :QUICKFEET
            mini_score *= 0.2
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.5
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # Prefer if user is slower than the target but will be faster if target
        # is paralysed
        if !@user_faster && skill_check(AILevel.best) && !@target.hasActiveAbility?(:QUICKFEET)
          user_speed   = pbRoughStat(@user, PBStats::SPEED)
          target_speed = pbRoughStat(@target, PBStats::SPEED)
          paralysis_factor = (NEWEST_BATTLE_MECHANICS) ? 2 : 4
          if (user_speed > target_speed / paralysis_factor) ^ (@battle.field.effects[PBEffects::TrickRoom] > 0)
            mini_score *= 1.1
          end
        end
        # Prefer if target can flinch and user is faster than it, but don't
        # prefer if target benefits from flinching
        if skill_check(AILevel.best) && !@target.hasActiveAbility?(:INNERFOCUS) &&
           @target.effects[PBEffects::Substitute] == 0
          mini_score *= 1.1 if @user_faster
          mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)
        end

        # Prefer if any Pokémon in the user's party has the Sweeper role
        @battle.eachInTeamFromBattlerIndex(@user.index) do |_pkmn, idxParty|
          next if !check_role(@user.idxOwnSide, idxParty, BattleRole::SWEEPER)
          mini_score *= 1.1
          break
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00A", "0C6"   # Burn the target
      if @target.pbCanBurn?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.2

        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Prefer if target's Attack is higher than its Special Attack
        if pbRoughStat(@target, PBStats::ATTACK) > pbRoughStat(@target, PBStats::SPATK)
          mini_score *= 1.4
        end
        # Prefer if target has Sturdy
        if skill_check(AILevel.best) && @target.hasActiveAbility?(:STURDY) && @move.damagingMove?
          mini_score *= 1.1
        end
        # Don't prefer if target is yawning
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # TODO: Don't prefer if target has previously used a move that benefits
        #       from being burned or can clear a burn.
        mini_score *= 0.3 if check_for_move(@target) { |move| move.function == "07E" }   # Facade
        mini_score *= 0.1 if check_for_move(@target) { |move| move.function == "0D9" }   # Rest
        # Don't prefer if target can cure itself, benefits from being burned, or
        # can pass a burn back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :GUTS, :FLAREBOOST
            mini_score *= 0.1
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.7
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          when :MAGICGUARD
            mini_score *= 0.5
          when :QUICKFEET
            mini_score *= 0.3
          end
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00B"   # Burn the target, make the target flinch
      if @target.pbCanBurn?(@user, false)
        mini_score = 1.0

        # Prefer if some of target's stats are raised
        sum_stages = 0
        [PBStats::ATTACK, PBStats::SPATK, PBStats::SPEED].each do |s|
          sum_stages += @target.stages[s]
        end
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Prefer if target's Attack is higher than its Special Attack
        if pbRoughStat(@target, PBStats::ATTACK) > pbRoughStat(@target, PBStats::SPATK)
          mini_score *= 1.4
        end
        # Prefer if target has Sturdy
        if skill_check(AILevel.best) && @target.hasActiveAbility?(:STURDY) && @move.damagingMove?
          mini_score *= 1.1
        end
        # Don't prefer if target is yawning
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # TODO: Don't prefer if target has previously used a move that benefits
        #       from being burned or can clear a burn.
        mini_score *= 0.3 if check_for_move(@target) { |move| move.function == "07E" }   # Facade
        mini_score *= 0.1 if check_for_move(@target) { |move| move.function == "0D9" }   # Rest
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :GUTS, :FLAREBOOST
            mini_score *= 0.1
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.7
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          when :MAGICGUARD
            mini_score *= 0.5
          when :QUICKFEET
            mini_score *= 0.3
          end
        end

        # Prefer if target can flinch and user is faster than it, but don't
        # prefer if target benefits from flinching
        if skill_check(AILevel.best) && !@target.hasActiveAbility?(:INNERFOCUS) &&
           @target.effects[PBEffects::Substitute] == 0
          mini_score *= 1.1 if @user_faster
          mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00C"   # Freeze the target
      if @target.pbCanFreeze?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.2

        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target's stats are raised
        sum_stages = 0
        PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # TODO: Prefer if target has previously used a HP-restoring move.
        mini_score *= 1.2 if check_for_move(@target) { |move| move.healingMove? }
        # TODO: Don't prefer if target has previously used a move that thaws it.
        if check_for_move(@target) { |move| move.thawsUser? }
          return (@move.statusMove?) ? 0 : score
        end
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.8
          end
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00D"   # Freeze the target, weather-dependent accuracy
      if @target.pbCanFreeze?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.4

        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target's stats are raised
        sum_stages = 0
        PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # TODO: Prefer if target has previously used a HP-restoring move.
        mini_score *= 1.2 if check_for_move(@target) { |move| move.healingMove? }
        # TODO: Don't prefer if target has previously used a move that thaws it.
        if check_for_move(@target) { |move| move.thawsUser? }
          return (@move.statusMove?) ? 0 : score
        end
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.8
          end
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00E"   # Freeze the target, make the target flinch
      if @target.pbCanFreeze?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.1

        # TODO: Prefer if user has any setup moves (i.e. it wants to stall to
        #       get them set up).

        # Prefer if target's stats are raised
        sum_stages = 0
        PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # TODO: Prefer if target has previously used a HP-restoring move.
        mini_score *= 1.2 if check_for_move(@target) { |move| move.healingMove? }
        # TODO: Don't prefer if target has previously used a move that thaws it.
        if check_for_move(@target) { |move| move.thawsUser? }
          return (@move.statusMove?) ? 0 : score
        end
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.8
          end
        end

        # Prefer if target can flinch and user is faster than it, but don't
        # prefer if target benefits from flinching
        if skill_check(AILevel.best) && !@target.hasActiveAbility?(:INNERFOCUS) &&
           @target.effects[PBEffects::Substitute] == 0
          mini_score *= 1.1 if @user_faster
          mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "00F"   # Make the target flinch
      if @user_faster &&
         (@target.effects[PBEffects::Substitute] == 0 || @move.soundMove?) &&
         !(skill_check(AILevel.best) && @target.hasActiveAbility?(:INNERFOCUS))
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.3

        # Prefer if target will be hurt at end of round
        # TODO: There are a lot more effects to consider (e.g. trapping, Aqua
        #       Ring, sea of fire) and more immunitues to consider (e.g.
        #       takesIndirectDamage?, Poison Heal ability).
        if @target.status == PBStatuses::POISON || @target.status == PBStatuses::BURN
          mini_score *= (@target.effects[PBEffects::Toxic] > 0) ? 1.3 : 1.1
        elsif @battle.pbWeather == PBWeather::Sandstorm &&
           !@target.pbHasType?(:GROUND) && !@target.pbHasType?(:ROCK) && !@target.pbHasType?(:STEEL)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::Hail && !@target.pbHasType?(:ICE)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::ShadowSky && !@target.shadowPokemon?
          mini_score *= 1.1
        elsif @target.effects[PBEffects::LeechSeed] >= 0 || @target.effects[PBEffects::Curse]
          mini_score *= 1.1
        end

        # Don't prefer if target benefits from flinching
        mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      end
    #---------------------------------------------------------------------------
    when "010"   # Make the target flinch, more damage/accuracy if target is minimized
      if @user_faster &&
         (@target.effects[PBEffects::Substitute] == 0 || @move.soundMove?) &&
         !(skill_check(AILevel.best) && @target.hasActiveAbility?(:INNERFOCUS))
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.3

        # Prefer if target will be hurt at end of round
        # TODO: There are a lot more effects to consider (e.g. trapping, Aqua
        #       Ring, sea of fire) and more immunitues to consider (e.g.
        #       takesIndirectDamage?, Poison Heal ability).
        if @target.status == PBStatuses::POISON || @target.status == PBStatuses::BURN
          mini_score *= (@target.effects[PBEffects::Toxic] > 0) ? 1.3 : 1.1
        elsif @battle.pbWeather == PBWeather::Sandstorm &&
           !@target.pbHasType?(:GROUND) && !@target.pbHasType?(:ROCK) && !@target.pbHasType?(:STEEL)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::Hail && !@target.pbHasType?(:ICE)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::ShadowSky && !@target.shadowPokemon?
          mini_score *= 1.1
        elsif @target.effects[PBEffects::LeechSeed] >= 0 || @target.effects[PBEffects::Curse]
          mini_score *= 1.1
        end

        # Don't prefer if target benefits from flinching
        mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      end
    #---------------------------------------------------------------------------
    when "011"   # Make the target flinch, fails if user isn't asleep
      return 0 if !@user.asleep?
      mini_score = 1.0
      # Inherently prefer
      # TODO: Is this needed? Moves that can't be used while asleep are already
      #       0.2x, so I don't see why this move needs preferring even more.
      mini_score *= 2

      if @user_faster &&
         (@target.effects[PBEffects::Substitute] == 0 || @move.soundMove?) &&
         !(skill_check(AILevel.best) && @target.hasActiveAbility?(:INNERFOCUS))
        # Prefer if target will be hurt at end of round
        # TODO: There are a lot more effects to consider (e.g. trapping, Aqua
        #       Ring, sea of fire) and more immunitues to consider (e.g.
        #       takesIndirectDamage?, Poison Heal ability).
        if @target.status == PBStatuses::POISON || @target.status == PBStatuses::BURN
          mini_score *= (@target.effects[PBEffects::Toxic] > 0) ? 1.3 : 1.1
        elsif @battle.pbWeather == PBWeather::Sandstorm &&
           !@target.pbHasType?(:GROUND) && !@target.pbHasType?(:ROCK) && !@target.pbHasType?(:STEEL)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::Hail && !@target.pbHasType?(:ICE)
          mini_score *= 1.1
        elsif @battle.pbWeather == PBWeather::ShadowSky && !@target.shadowPokemon?
          mini_score *= 1.1
        elsif @target.effects[PBEffects::LeechSeed] >= 0 || @target.effects[PBEffects::Curse]
          mini_score *= 1.1
        end

        # Don't prefer if target benefits from flinching
        mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)
      end
      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "012"   # Make the target flinch, fails if not the user's first turn
      return 0 if @user.turnCount > 0

      if (@target.effects[PBEffects::Substitute] == 0 || @move.soundMove?) &&
         !(skill_check(AILevel.best) && @target.hasActiveAbility?(:INNERFOCUS))
        mini_score = 1.0
        # Don't prefer if it's not a single battle
        # TODO: What is the purpose of this check?
        mini_score *= 0.7 if !@battle.singleBattle?
        # Don't prefer if target benefits from flinching
        mini_score *= 0.3 if @target.hasActiveAbility?(:STEADFAST)
        # TODO: Don't prefer if target has previously used Encore.

        # Prefer if user is faster than the target
        mini_score *= 2 if @user_faster

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      end
    #---------------------------------------------------------------------------
    when "013", "014"   # Confuse the target
      if @target.pbCanConfuse?(@user, false)
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.2

        # Prefer if user has a substitute
        mini_score *= 1.3 if @user.effects[PBEffects::Substitute] > 0
        # Prefer if user has a move that combos well with the target being confused
        mini_score *= 1.2 if @user.pbHasMoveFunction?("10C")   # Substitute
        # Prefer if user has certain roles
        mini_score *= 1.3 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)

        # Prefer if target's Attack stat is raised
        sum_stages = @target.stages[PBStats::ATTACK]
        mini_score *= 1 + sum_stages * 0.1 if sum_stages > 0
        # Prefer if target's Attack is higher than its Special Attack
        if pbRoughStat(@target, PBStats::ATTACK) > pbRoughStat(@target, PBStats::SPATK)
          mini_score *= 1.2
        end
        # Prefer if target is paralysed or infatuated
        mini_score *= 1.1 if @target.status == PBStatuses::PARALYSIS
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        # Don't prefer if target is asleep or yawning
        mini_score *= 0.4 if @target.status == PBStatuses::SLEEP
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # Don't prefer if target benefits from being confused
        mini_score *= 0.7 if skill_check(AILevel.best) && @target.hasActiveAbility?(:TANGLEDFEET)

        # TODO: Prefer if user's moves won't do much damage to the target.

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "015"   # Confuse the target, weather-dependent accuracy
      mini_score = 1.0

      # TODO: Prefer if user is slower and target has previously used a move
      #       that makes it semi-invulnerable in the air (Fly, Bounce, Sky Drop).
      if !@user_faster
        if check_for_move(@target) { |move| ["0C9", "0CC", "0CE"].include?(move.function) }
          mini_score *= 1.2
        end
      end

      if @target.pbCanConfuse?(@user, false)
        # Inherently prefer
        mini_score *= 1.2

        # Prefer if user has a substitute
        mini_score *= 1.3 if @user.effects[PBEffects::Substitute] > 0
        # Prefer if user has a move that combos well with the target being confused
        mini_score *= 1.2 if @user.pbHasMoveFunction?("10C")   # Substitute
        # Prefer if user has certain roles
        mini_score *= 1.3 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)

        # Prefer if target's Attack stat is raised
        sum_stages = @target.stages[PBStats::ATTACK]
        mini_score *= 1 + sum_stages * 0.1 if sum_stages > 0
        # Prefer if target's Attack is higher than its Special Attack
        if pbRoughStat(@target, PBStats::ATTACK) > pbRoughStat(@target, PBStats::SPATK)
          mini_score *= 1.2
        end
        # Prefer if target is paralysed or infatuated
        mini_score *= 1.1 if @target.status == PBStatuses::PARALYSIS
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        # Don't prefer if target is asleep or yawning
        mini_score *= 0.4 if @target.status == PBStatuses::SLEEP
        mini_score *= 0.4 if @target.effects[PBEffects::Yawn] > 0
        # Don't prefer if target benefits from being confused
        mini_score *= 0.7 if skill_check(AILevel.best) && @target.hasActiveAbility?(:TANGLEDFEET)
      else
        return 0 if @move.statusMove?
      end
      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "016"   # Make the target infatuated with the user
      can_attract = true
      user_gender = @user.gender
      target_gender = @target.gender
      if user_gender == 2 || target_gender == 2 || user_gender == target_gender
        can_attract = false
      elsif @target.effects[PBEffects::Attract] >= 0
        can_attract = false
      elsif skill_check(AILevel.best) && @target.hasActiveAbility?([:OBLIVIOUS, :AROMAVEIL])
        can_attract = false
      elsif skill_check(AILevel.best)
        @target.eachAlly do |b|
          next if !b.hasActiveAbility?(:AROMAVEIL)
          can_attract = false
          break
        end
      end
      if can_attract
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.2

        # Prefer if user has a substitute
        mini_score *= 1.3 if @user.effects[PBEffects::Substitute] > 0
        # Prefer if user has a move that combos well with the target being confused
        mini_score *= 1.2 if @user.pbHasMoveFunction?("10C")   # Substitute
        # Prefer if user has certain roles
        mini_score *= 1.3 if check_battler_role(@user,
           BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
        # Don't prefer if user has an ability that causes infatuation
        mini_score *= 0.7 if @user.hasActiveAbility?(:CUTECHARM)

        # Prefer if target is paralysed or infatuated
        mini_score *= 1.1 if @target.status == PBStatuses::PARALYSIS
        mini_score *= 1.1 if @target.effects[PBEffects::Attract] >= 0
        # Don't prefer if target is asleep or yawning
        mini_score *= 0.5 if @target.status == PBStatuses::SLEEP
        mini_score *= 0.5 if @target.effects[PBEffects::Yawn] > 0
        # Don't prefer if target has an item that benefits from it being infatuated
        # TODO: Include consideration of whether the use can be infatuated.
        mini_score *= 0.1 if skill_check(AILevel.high) && @target.hasActiveItem?(:DESTINYKNOT)

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      else
        return 0 if @move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "017"   # Randomly burn, paralyse or freeze the target
      if !@target.pbHasAnyStatus?
        mini_score = 1.0
        # Inherently prefer
        mini_score *= 1.4

        # Prefer if target's stats are raised
        sum_stages = 0
        PBStats.eachBattleStat { |s| sum_stages += @target.stages[s] }
        mini_score *= 1 + sum_stages * 0.05 if sum_stages > 0
        # Don't prefer if target can cure itself, benefits from being paralysed,
        # or can pass paralysis back to the user
        # TODO: Check for other effects to list here.
        if skill_check(AILevel.best) && @target.abilityActive?
          case @target.ability_id
          when :SHEDSKIN
            mini_score *= 0.7
          when :HYDRATION
            if [PBWeather::Rain, PBWeather::HeavyRain].include?(@battle.pbWeather)
              return (@move.statusMove?) ? 0 : score
            end
          when :GUTS, :QUICKFEET
            mini_score *= 0.3
          when :NATURALCURE
            mini_score *= 0.3
          when :MARVELSCALE
            mini_score *= 0.7
          when :SYNCHRONIZE
            mini_score *= 0.5 if !@user.pbHasAnyStatus?
          end
        end

        # Apply mini_score to score
        mini_score = apply_effect_chance_to_score(mini_score)
        score *= mini_score
      end
    #---------------------------------------------------------------------------
    when "018"   # Cure user's burn/poison/paralysis
      return 0 if @user.status != PBStatuses::BURN &&
                  @user.status != PBStatuses::POISON &&
                  @user.status != PBStatuses::PARALYSIS
      mini_score = 1.0
      # Inherently prefer
      mini_score *= 3

      # Prefer if user is above 50% HP/don't prefer if user is below 50% HP
      if @user.hp >= @user.totalhp / 2
        mini_score *= 1.5
      else
        mini_score *= 0.3
      end
      # Prefer if user is badly poisoned
      mini_score *= 1.3 if @user.effects[PBEffects::Toxic] > 2
      # Don't prefer if user is yawning
      mini_score *= 0.1 if @user.effects[PBEffects::Yawn] > 0

      # TODO: Prefer if a foe has previously used a move that benefits from the
      #       user having a status problem (Hex, probably some other moves).
      # TODO: Don't prefer if a foe's previously used move did enough damage
      #       that it would KO the user if used again.

      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "019"   # Cure all user's party of status problems
      num_statuses = 0
      party = @battle.pbParty(@user.index)
      party.each do |pkmn|
        num_statuses += 1 if pkmn && pkmn.status != PBStatuses::NONE
      end
      return 0 if num_status == 0   # No Pokémon to cure

      mini_score = 1.0
      # Inherently prefer
      mini_score *= 1.2

      # Prefer if user has a status problem
      mini_score *= 1.3 if @user.status != PBStatuses::NONE
      # Prefer if user is badly poisoned
      mini_score *= 1.3 if @user.effects[PBEffects::Toxic] > 2

      # TODO: Prefer if a foe has previously used a HP-restoring move.

      # Check all party Pokémon
      party.each_with_index do |pkmn, idxParty|
        next if !pkmn || pkmn.egg? || pkmn.status == PBStatuses::NONE
        # TODO: Check for other abilities, etc. that make a Pokémon benefit from
        #       having one or any status problem.
        case pkmn.status
        when PBStatuses::SLEEP
          # Inherently prefer
          mini_score *= 1.1
        when PBStatuses::POISON
          # Prefer if Pokémon has certain roles
          mini_score *= 1.2 if check_role(@user.idxOwnSide, idxParty,
             BattleRole::PHYSICALWALL, BattleRole::SPECIALWALL)
          # Don't prefer if Pokémon has an ability that benefits from being poisoned
          mini_score *= 0.5 if pkmn.hasAbility?(:POISONHEAL)
        when PBStatuses::BURN
          # Inherently prefer
          mini_score *= 1.2
        when PBStatuses::PARALYSIS
          # Prefer if Pokémon has the Sweeper role
          mini_score *= 1.2 if check_role(@user.idxOwnSide, idxParty, BattleRole::SWEEPER)
        when PBStatuses::FROZEN
          # Inherently prefer
          mini_score *= 1.1
        end
        # Don't prefer if Pokémon has an ability or knows a move that benefits
        # from having a status problem
        mini_score *= 0.8 if pkmn.hasAbility?(:GUTS) || pkmn.hasAbility?(:QUICKFEET)
        # TODO: Make this a function code check instead.
        mini_score *= 0.8 if pkmn.knowsMove?(:FACADE)
      end

      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "01A"   # Safeguard user's side from inflicted status problems for 5 rounds
      if @user.pbOwnSide.effects[PBEffects::Safeguard] == 0 && @user_faster &&
         !@user.pbHasAnyStatus? && !check_battler_role(@user, BattleRole::STATUSABSORBER)
        # TODO: Prefer if any foe has previously used Spore. Really? Probably
        #       should be if they've used any status-causing move (with the
        #       amount of preferring depending on its additional effect chance).
      end
    #---------------------------------------------------------------------------
    when "01B"   # Pass user's status problem to the target
      return 0 if @user.status == PBStatuses::NONE ||
                  !@target.pbCanInflictStatus?(@user.status, @user, false, @move)
      mini_score = 1.0
      # Inherently prefer
      mini_score *= 1.3

      # Prefer if user has a move that benefits from the target having a status
      # problem
      # TODO: Are there other moves?
      mini_score *= 1.3 if @user.pbHasMoveFunction?("07F")   # Hex

      if @target.effects[PBEffects::Yawn] == 0
        # Inherently prefer again
        mini_score *= 1.3

        # Don't prefer if target benefits from having a status problem
        mini_score *= 0.7 if @target.hasActiveAbility?([:SHEDSKIN, :NATURALCURE,
                                                        :GUTS, :QUICKFEET, :MARVELSCALE])
        # TODO: Don't prefer if target has previously used a move that benefits
        #       from them having a status problem (Hex, probably some other moves).

        # Status-specific checks
        # TODO: Add something for sleep?
        case @user.status
        when PBStatuses::POISON
          # Prefer is user is badly poisoned
          mini_score *= 1.4 if @user.effects[PBEffects::Toxic] > 0
          # TODO: Prefer if target has previously used a HP-restoring move.
          # Don't prefer if target benefits from being poisoned
          mini_score *= 0.3 if @target.hasActiveAbility?(:POISONHEAL)
          mini_score *= 0.7 if @target.hasActiveAbility?(:TOXICBOOST)
        when PBStatuses::BURN
          # Prefer if target has a higher Attack than Special Attack
          if pbRoughStat(@target, PBStats::ATTACK) > pbRoughStat(@target, PBStats::SPATK)
            mini_score *= 1.2
          end
          # Don't prefer if target benefits from being burned
          mini_score *= 0.7 if @target.hasActiveAbility?(:FLAREBOOST)
        when PBStatuses::PARALYSIS
          # Prefer if target is faster than the user
          mini_score *= 1.2 if !@user_faster
        end
      end

      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "01C"   # Increase user's Attack by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "01D", "0C8"   # Increase user's Defense by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "01E"   # Increase user's Defense by 1 stage, user curls up
      score = get_score_for_user_stat_raise(score)
      # Prefer if user knows Rollout and hasn't curled up yet
      score *= 1.3 if !@user.effects[PBEffects::DefenseCurl] && @user.pbHasMoveFunction?("0D3")   # Rollout
    #---------------------------------------------------------------------------
    when "01F"   # Increase user's Speed by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "020"   # Increase user's Special Attack by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "021"   # Increase user's Special Defense by 1 stage, charges next Electric move
      score = get_score_for_user_stat_raise(score)
      # Prefer if user knows any damaging Electric-type moves and isn't charged
      if @user.effects[PBEffects::Charge] == 0
        score *= 1.5 if check_for_move(@user) do |move|
          next move.damagingMove? && move.type == :ELECTRIC
        end
      end
    #---------------------------------------------------------------------------
    when "022"   # Increase user's evasion by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "023"   # Set user's critical hit rate to 2
      # TODO: This is mimicking def get_mini_score_for_user_stat_raise for the
      #       most part.
      # Discard move if it will have no effect
      if @user.effects[PBEffects::FocusEnergy] >= 2
        return (@move.statusMove?) ? 0 : score
      end

      mini_score = 1.0

      # Prefer if user is above 75% HP/don't prefer if user is below 33% HP
      if @user.hp >= @user.totalhp * 3 / 4
        mini_score *= 1.2
      elsif @user.hp < @user.totalhp / 3
        mini_score *= 0.3
      end
      # Prefer if user hasn't been in battle for long
      mini_score *= 1.2 if @user.turnCount < 2
      # Prefer if user has the ability Super Luck or Sniper
      mini_score *= 2 if @user.hasActiveAbility?([:SUPERLUCK, :SNIPER])
      # Prefer if user has an item that raises its critical hit rate
      if @user.hasActiveItem?([:SCOPELENS, :RAZORCLAW])
        mini_score *= 1.2
      elsif @user.hasActiveItem?(:LANSATBERRY)
        mini_score *= 1.3
      elsif @user.isSpecies?(:FARFETCHD) && @user.hasActiveItem?(:STICK)
        mini_score *= 1.2
      elsif @user.isSpecies?(:CHANSEY) && @user.hasActiveItem?(:LUCKYPUNCH)
        mini_score *= 1.2
      end
      # Prefer if user knows any moves with a high critical hit rate
      mini_score *= 2 if check_for_move(@user) { |move| move.highCriticalRate? }
      # Don't prefer if user is confused
      mini_score *= 0.2 if @user.effects[PBEffects::Confusion] > 0
      # Don't prefer if user is infatuated or Leech Seeded
      if @user.effects[PBEffects::Attract] >= 0 || @user.effects[PBEffects::LeechSeed] >= 0
        mini_score *= 0.6
      end
      # Don't prefer if user has an ability or item that will force it to switch
      # out
      if @user.hp < @user.totalhp * 3 / 4
        mini_score *= 0.3 if @user.hasActiveAbility?([:EMERGENCYEXIT, :WIMPOUT])
        mini_score *= 0.3 if @user.hasActiveItem?(:EJECTBUTTON)
      end
      # Don't prefer if user has a move that always deals critical hits or
      # allows a move to always be a critical hit
      mini_score *= 0.5 if @user.pbHasMoveFunction?("0A0", "15E")   # Frost Breath, Laser Focus

      # Prefer if target has a status problem
      if @target.status != PBStatuses::NONE
        mini_score *= 1.2
        mini_score *= 1.3 if [PBStatuses::SLEEP, PBStatuses::FROZEN].include?(@target.status)
      end
      # Prefer if target is yawning
      mini_score *= 1.7 if @target.effects[PBEffects::Yawn] > 0
      # Prefer if target is recovering after Hyper Beam
      mini_score *= 1.3 if @target.effects[PBEffects::HyperBeam] > 0
      # Prefer if target is Encored into a status move
      if @target.effects[PBEffects::Encore] > 0 &&
         GameData::Move.get(@target.effects[PBEffects::EncoreMove]).category == 2   # Status move
        mini_score *= 1.5
      end
      # Don't prefer if target has an ability that prevents or benefits from
      # critical hits
      mini_score *= 0.2 if @target.hasActiveAbility?([:ANGERPOINT, :SHELLARMOR, :BATTLEARMOR])
      # TODO: Don't prefer if target has previously used a move that would force
      #       the user to switch (or Yawn/Perish Song which encourage it). Prefer
      #       instead if the move raises evasion. Note this comes after the
      #       dissociation of Bulk Up from sweeping_stat.

      # TODO: Prefer if the maximum damage the target has dealt wouldn't hurt
      #       the user much.
      # TODO: Don't prefer if target is a higher level than the user
      if @target.level > @user.level + 5
        mini_score *= 0.6
        if @target.level > @user.level + 10
          mini_score *= 0.2
        end
      end
      # Don't prefer if foe's side is able to use a boosted Retaliate
      # TODO: I think this is what Reborn means. Reborn doesn't check for the
      #       existence of the move Retaliate, just whether it can be boosted.
      if @user.pbOpposingSide.effects[PBEffects::LastRoundFainted] == @battle.turnCount - 1
        mini_score *= 0.3
      end

      # Don't prefer if it's not a single battle
      mini_score *= 0.5 if !@battle.singleBattle?

      # Apply mini_score to score
      mini_score = apply_effect_chance_to_score(mini_score)
      score *= mini_score
    #---------------------------------------------------------------------------
    when "024"   # Increase user's Attack and Defense by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "025"   # Increase user's Attack, Defense and accuracy by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "026"   # Increase user's Attack and Speed by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "027"   # Increase user's Attack and Special Attack by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "028"   # Increase user's Attack and Special Attack by 1 stage each (2 in sun)
      # TODO: Needs to account for different stat gain in sun.
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "029"   # Increase user's Attack and accuracy by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02A"   # Increase user's Defense and Special Defense by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02B"   # Increase user's Special Attack, Special Defense and Speed by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02C"   # Increase user's Special Attack and Special Defense by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02D"   # Increase user's Atk/Def/Speed/SpAtk/SpDef by 1 stage each
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02E"   # Increase user's Attack by 2 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "02F"   # Increase user's Defense by 2 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "030"   # Increase user's Speed by 2 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "031"   # Increase user's Speed by 2 stages, user loses 100kg
      score = get_score_for_user_stat_raise(score)
      if @user.pbWeight > 1
        # TODO: Don't prefer if user knows 09B Heavy Slam (being heavier means
        #       that move does more damage).

        # TODO: Prefer if target has previously used a move that deals more
        #       damage to a heavier target - 09A Low Kick.
        # TODO: Don't prefer if target has previously used a move that deals
        #       more damage to a lighter target - 09B Heavy Slam.
      end
    #---------------------------------------------------------------------------
    when "032"   # Increase user's Special Attack by 2 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "033"   # Increase user's Special Defense by 2 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "034"   # Increase user's evasion by 2 stages, user is minimized
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "035"   # Decrease user's Def/SpDef by 1 stage each, increase user's Atk/SpAtk/Speed by 2 stages each
      score = get_score_for_user_stat_raise(score)
      # TODO: The stat-lowerings of this one.
    #---------------------------------------------------------------------------
    when "036"   # Increase user's Speed by 2 stages, increase user's Attack by 1 stage
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "037"   # Increase one random target's stat by 2 stages
      # Discard status move if target has Contrary
      return 0 if @move.statusMove? && @target.hasActiveAbility?(:CONTRARY)

      # Discard move if it can't raise any stats
      can_change_any_stat = false
      PBStats.eachBattleStat do |stat|
        next if @target.statStageAtMax?(stat)
        can_change_any_stat = true
        break
      end
      if !can_change_any_stat
        return (@move.statusMove?) ? 0 : score
      end

      mini_score = 1.0

      # Prefer if target has the ability Simple
      mini_score *= 2 if @target.hasActiveAbility?(:SIMPLE)

      # Don't prefer if target doesn't have much HP left
      mini_score *= 0.3 if @target.hp < @target.totalhp / 3
      # Don't prefer if target is badly poisoned
      mini_score *= 0.2 if @target.effects[PBEffects::Toxic] > 0
      # Don't prefer if target is confused
      mini_score *= 0.4 if @target.effects[PBEffects::Confusion] > 0
      # Don't prefer if target is infatuated or Leech Seeded
      if @target.effects[PBEffects::Attract] >= 0 || @target.effects[PBEffects::LeechSeed] >= 0
        mini_score *= 0.3
      end
      # Don't prefer if target has an ability or item that will force it to
      # switch out
      if @target.hp < @target.totalhp * 3 / 4
        mini_score *= 0.3 if @target.hasActiveAbility?([:EMERGENCYEXIT, :WIMPOUT])
        mini_score *= 0.3 if @target.hasActiveItem?(:EJECTBUTTON)
      end
      # Don't prefer if target has Contrary
      mini_score *= 0.5 if @target.hasActiveAbility?(:CONTRARY)

      # TODO: Don't prefer if any foe has previously used a stat stage-clearing
      #       move (050, 051 Clear Smog/Haze). Shouldn't query @target's moves.
#      mini_score *= 0.3 if check_for_move(@target) { |move| ["050", "051"].include?(move.function) }   # Clear Smog, Haze

      # Apply the mini-score to the actual score
      score = apply_effect_chance_to_score(score * mini_score)
    #---------------------------------------------------------------------------
    when "038"   # Increase user's Defense by 3 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "039"   # Increase user's Special Attack by 3 stages
      score = get_score_for_user_stat_raise(score)
    #---------------------------------------------------------------------------
    when "03A"   # Halves user's HP, sets user's Attack to +6 stages
      if @user.statStageAtMax?(PBStats::ATTACK) ||
         @user.hp<=@user.totalhp/2
        score -= 100
      else
        score += (6-@user.stages[PBStats::ATTACK])*10
        if skill_check(AILevel.medium)
          hasPhysicalAttack = false
          @user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 40
          elsif skill_check(AILevel.high)
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "03B"   # Decreases user's Attack and Defense by 1 stage each
      avg =  @user.stages[PBStats::ATTACK]*10
      avg += @user.stages[PBStats::DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03C"   # Decreases user's Defense and Special Defense by 1 stage each
      avg =  @user.stages[PBStats::DEFENSE]*10
      avg += @user.stages[PBStats::SPDEF]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03D"   # Decreases user's Defense, Special Defense and Speed by 1 stage each
      avg =  @user.stages[PBStats::DEFENSE]*10
      avg += @user.stages[PBStats::SPEED]*10
      avg += @user.stages[PBStats::SPDEF]*10
      score += (avg/3).floor
    #---------------------------------------------------------------------------
    when "03E"   # Decreases user's Speed by 1 stage
      score += @user.stages[PBStats::SPEED]*10
    #---------------------------------------------------------------------------
    when "03F"   # Decreases user's Special Attack by 2 stages
      score += @user.stages[PBStats::SPATK]*10
    #---------------------------------------------------------------------------
    end
    return score
  end
end
