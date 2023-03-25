class Battle::AI
  #=============================================================================
  # Decide whether the opponent should switch Pokémon
  #=============================================================================
  # Called by the AI's def pbDefaultChooseEnemyCommand, and by def pbChooseMove
  # if the only moves known are bad ones (the latter forces a switch). Also
  # aliased by the Battle Palace and Battle Arena.
  def pbChooseToSwitchOut(force_switch = false)
    return false if @user.wild?
    return false if !@battle.pbCanSwitchOut?(@user.index)
    # Don't switch if all foes are unable to do anything, e.g. resting after
    # Hyper Beam, will Truant (i.e. free turn)
    if @trainer.high_skill?
      foe_can_act = false
      each_foe_battler(@user.side) do |b, i|
        next if !b.can_attack?
        foe_can_act = true
        break
      end
      return false if !foe_can_act
    end
    # Various calculations to decide whether to switch
    if force_switch
      PBDebug.log_ai("#{@user.name} is being forced to switch out")
    else
      return false if !@trainer.has_skill_flag?("ConsiderSwitching")
      reserves = get_non_active_party_pokemon(@user.index)
      should_switch = Battle::AI::Handlers.should_switch?(@user, reserves, self, @battle)
      if should_switch && @trainer.medium_skill?
        should_switch = false if Battle::AI::Handlers.should_not_switch?(@user, reserves, self, @battle)
      end
      return false if !should_switch
    end
    # Want to switch; find the best replacement Pokémon
    idxParty = choose_best_replacement_pokemon(@user.index, force_switch)
    if idxParty < 0   # No good replacement Pokémon found
      PBDebug.log("   => no good replacement Pokémon, will not switch after all")
      return false
    end
    # Prefer using Baton Pass instead of switching
    baton_pass = -1
    @user.battler.eachMoveWithIndex do |m, i|
      next if m.function != "SwitchOutUserPassOnEffects"   # Baton Pass
      next if !@battle.pbCanChooseMove?(@user.index, i, false)
      baton_pass = i
      break
    end
    if baton_pass >= 0 && @battle.pbRegisterMove(@user.index, baton_pass, false)
      PBDebug.log("   => will use Baton Pass to switch out")
      return true
    elsif @battle.pbRegisterSwitch(@user.index, idxParty)
      PBDebug.log("   => will switch with #{@battle.pbParty(@user.index)[idxParty].name}")
      return true
    end
    return false
  end

  def get_non_active_party_pokemon(idxBattler)
    ret = []
    @battle.pbParty(idxBattler).each_with_index do |pkmn, i|
      ret.push(pkmn) if @battle.pbCanSwitchIn?(idxBattler, i)
    end
    return ret
  end

  #=============================================================================

  def choose_best_replacement_pokemon(idxBattler, mandatory = false)
    # Get all possible replacement Pokémon
    party = @battle.pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    reserves = []
    party.each_with_index do |_pkmn, i|
      next if !@battle.pbCanSwitchIn?(idxBattler, i)
      if !mandatory   # Not mandatory means choosing an action for the round
        ally_will_switch_with_i = false
        @battle.allSameSideBattlers(idxBattler).each do |b|
          next if @battle.choices[b.index][0] != :SwitchOut || @battle.choices[b.index][1] != i
          ally_will_switch_with_i = true
          break
        end
        next if ally_will_switch_with_i
      end
      # Ignore ace if possible
      if @trainer.has_skill_flag?("ReserveLastPokemon") && i == idxPartyEnd - 1
        next if !mandatory || reserves.length > 0
      end
      reserves.push([i, 100])
      break if @trainer.has_skill_flag?("UsePokemonInOrder") && reserves.length > 0
    end
    return -1 if reserves.length == 0
    # Rate each possible replacement Pokémon
    reserves.each_with_index do |reserve, i|
      reserves[i][1] = rate_replacement_pokemon(idxBattler, party[reserve[0]], reserve[1])
    end
    reserves.sort! { |a, b| b[1] <=> a[1] }   # Sort from highest to lowest rated
    # Don't bother choosing to switch if all replacements are poorly rated
    if @trainer.high_skill? && !mandatory
      # TODO: Should the current battler be rated as well, to provide a
      #       threshold instead of using a threshold of 100?
      return -1 if reserves[0][1] < 100   # Best replacement rated at <100, don't switch
    end
    # Return the party index of the best rated replacement Pokémon
    return reserves[0][0]
  end

  def rate_replacement_pokemon(idxBattler, pkmn, score)
    pkmn_types = pkmn.types
    entry_hazard_damage = calculate_entry_hazard_damage(pkmn, idxBattler & 1)
    if entry_hazard_damage >= pkmn.hp
      score -= 50   # pkmn will just faint
    elsif entry_hazard_damage > 0
      score -= 50 * entry_hazard_damage / pkmn.hp
    end
    # TODO: Toxic Spikes.
    # TODO: Sticky Web.
    # Predict effectiveness of foe's last used move against pkmn
    each_foe_battler(@user.side) do |b, i|
      next if !b.battler.lastMoveUsed
      move_data = GameData::Move.get(b.battler.lastMoveUsed)
      next if move_data.status?
      move_type = move_data.type
      eff = Effectiveness.calculate(move_type, *pkmn_types)
      score -= move_data.power * eff / 5
    end
    # Add power * effectiveness / 10 of all pkmn's moves to score
    pkmn.moves.each do |m|
      next if m.power == 0 || (m.pp == 0 && m.total_pp > 0)
      @battle.battlers[idxBattler].allOpposing.each do |b|
        bTypes = b.pbTypes(true)
        # TODO: Consider Wonder Guard, Volt Absorb et al. Consider pkmn's
        #       ability if it changes the user's types or powers up their moves?
        score += m.power * Effectiveness.calculate(m.type, *bTypes) / 10
      end
    end
    # Prefer if user is about to faint from Perish Song
    score += 10 if @user.effects[PBEffects::PerishSong] == 1
    return score
  end

  def calculate_entry_hazard_damage(pkmn, side)
    return 0 if pkmn.hasAbility?(:MAGICGUARD) || pkmn.hasItem?(:HEAVYDUTYBOOTS)
    ret = 0
    # Stealth Rock
    if @battle.sides[side].effects[PBEffects::StealthRock] && GameData::Type.exists?(:ROCK)
      eff = Effectiveness.calculate(:ROCK, *pkmn_types)
      ret += pkmn.totalhp * eff / 8 if !Effectiveness.ineffective?(eff)
    end
    # Spikes
    if @battle.sides[side].effects[PBEffects::Spikes] > 0
      if @battle.field.effects[PBEffects::Gravity] > 0 || pkmn.hasItem?(:IRONBALL) ||
         !(pkmn.hasType?(:FLYING) || pkmn.hasItem?(:LEVITATE) || pkmn.hasItem?(:AIRBALLOON))
        spikes_div = [8, 6, 4][@battle.sides[side].effects[PBEffects::Spikes] - 1]
        ret += pkmn.totalhp / spikes_div
      end
    end
    return ret
  end
end

#===============================================================================
# Pokémon is about to faint because of Perish Song.
# TODO: Also switch to remove other negative effects like Disable, Yawn.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:perish_song,
  proc { |battler, reserves, ai, battle|
    if battler.effects[PBEffects::PerishSong] == 1
      PBDebug.log_ai("#{battler.name} wants to switch because it is about to faint from Perish Song")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon will take a significant amount of damage at the end of this round.
# Also, Pokémon has an effect that causes it damage at the end of this round,
# which it can remove by switching.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:significant_eor_damage,
  proc { |battler, reserves, ai, battle|
    eor_damage = battler.rough_end_of_round_damage
    # Switch if battler will take significant EOR damage
    if eor_damage >= battler.hp / 2 || eor_damage >= battler.totalhp / 4
      PBDebug.log_ai("#{battler.name} wants to switch because it will take a lot of EOR damage")
      next true
    end
    # Switch to remove certain effects that cause the battler EOR damage
    if ai.trainer.high_skill? && eor_damage > 0
      if battler.effects[PBEffects::LeechSeed] >= 0 && ai.pbAIRandom(100) < 50
        PBDebug.log_ai("#{battler.name} wants to switch to get rid of its Leech Seed")
        next true
      end
      if battler.effects[PBEffects::Nightmare]
        PBDebug.log_ai("#{battler.name} wants to switch to get rid of its Nightmare")
        next true
      end
      if battler.effects[PBEffects::Curse]
        PBDebug.log_ai("#{battler.name} wants to switch to get rid of its Curse")
        next true
      end
      if battler.status == :POISON && battler.statusCount > 0 && !battler.has_active_ability?(:POISONHEAL)
        poison_damage = battler.totalhp / 8
        next_toxic_damage = battler.totalhp * (battler.effects[PBEffects::Toxic] + 1) / 16
        if (battler.hp <= next_toxic_damage && battler.hp > poison_damage) ||
           next_toxic_damage > poison_damage * 2
          PBDebug.log_ai("#{battler.name} wants to switch to reduce toxic to regular poisoning")
          next true
        end
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon can cure its status problem or heal some HP with its ability by
# switching out. Covers all abilities with an OnSwitchOut AbilityEffects handler.
# TODO: Review switch deciding. Add randomness?
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:cure_status_problem_by_switching_out,
  proc { |battler, reserves, ai, battle|
    next false if !battler.ability_active?
    # Don't try to cure a status problem/heal a bit of HP if entry hazards will
    # KO the battler if it switches back in
    entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pkmn, battler.side)
    next false if entry_hazard_damage >= battler.hp
    # Check specific abilities
    single_status_cure = {
      :IMMUNITY    => :POISON,
      :INSOMNIA    => :SLEEP,
      :LIMBER      => :PARALYSIS,
      :MAGMAARMOR  => :FROZEN,
      :VITALSPIRIT => :SLEEP,
      :WATERBUBBLE => :BURN,
      :WATERVEIL   => :BURN
    }[battler.ability_id]
    if battler.ability_id == :NATURALCURE || (single_status_cure && single_status_cure == battler.status)
      # Cures status problem
      next false if battler.wants_status_problem?(battler.status)
      next false if battler.status == :SLEEP && battler.statusCount == 1   # Will wake up this round anyway
      next false if entry_hazard_damage >= battler.totalhp / 4
      # Don't bother curing a poisoning if Toxic Spikes will just re-poison the
      # battler when it switches back in
      if battler.status == :POISON && reserves.none? { |pkmn| pkmn.hasType?(:POISON) }
        next false if battle.field.effects[PBEffectS::ToxicSpikes] == 2
        next false if battle.field.effects[PBEffectS::ToxicSpikes] == 1 && battler.statusCount == 0
      end
      # Not worth curing status problems that still allow actions if at high HP
      next false if battler.hp >= battler.totalhp / 2 && ![:SLEEP, :FROZEN].include?(battler.status)
      PBDebug.log_ai("#{battler.name} wants to switch to cure its status problem with #{battler.ability.name}")
      next true
    elsif battler.ability_id == :REGENERATOR
      # Heals 33% HP
      next false if entry_hazard_damage >= battler.totalhp / 3
      # Not worth healing HP if already at high HP
      next false if battler.hp >= battler.totalhp / 2
      # TODO: Don't bother if user can do decent damage.
      if ai.pbAIRandom(100) < 50
        PBDebug.log_ai("#{battler.name} wants to switch to heal with #{battler.ability.name}")
        next true
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon can't do anything to a Wonder Guard foe.
# TODO: Check other abilities that provide immunities?
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:foe_has_wonder_guard,
  proc { |battler, reserves, ai, battle|
    next false if battler.battler.hasMoldBreaker?
    non_wonder_guard_foe_exists = false
    has_super_effective_move = false
    foe_types = b.pbTypes(true)
    next false if foe_types.length == 0
    ai.each_foe_battler(battler.side) do |b, i|
      if !b.has_active_ability?(:WONDERGUARD)
        non_wonder_guard_foe_exists = true
        break
      end
      if ai.trainer.high_skill? && b.rough_end_of_round_damage > 0
        non_wonder_guard_foe_exists = true   # Wonder Guard is being overcome already
        break
      end
      # Check for super-effective damaging moves
      battler.battler.eachMove do |move|
        next if move.statusMove?
        if ["IgnoreTargetAbility",
            "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function)
          has_super_effective_move = true
          break
        end
        eff = Effectiveness.calculate(move.pbCalcType(battler.battler), *foe_types)
        if Effectiveness.super_effective?(eff)
          has_super_effective_move = true
          break
        end
      end
      # TODO: Check if battler has other useful status moves. CFRU considers
      #       these (and makes sure they're usable; also ensure they're not
      #       stopped by a substitute):
      #       - Inflict sleep/poison/burn/paralysis (not freeze)
      #       - Inflict confusion (inc. Swagger/Flatter)
      #       - Start damaging weather (sandstorm/hail)
      #       - Trick (to give foe an item with EOR damage/status infliction)
      #       - Other EOR damage moves (Leech Seed, Nightmare, Curse)
      #       - Perish Song
      #       - Add third type to target (Trick-or-Treat, Forest's Curse)
      #       - Worry Seed, Gastro Acid, Entrainment, Simple Beam, Core Enforcer
      #       - Roar
      #       - Baton Pass, Teleport
      #       - Memento (why?)
      #       - Entry hazards (not sure why; just to stack them up?)
      #       - Wish (just to set it up?)
      #       - Tailwind (just to set it up?)
      #       - Lucky Chant (just to set it up?)
      break if has_super_effective_move
    end
    if !non_wonder_guard_foe_exists && !has_super_effective_move
      # Check reserves for super-effective moves; only switch if there are any
      reserve_has_super_effective_move = false
      reserves.each do |pkmn|
        pkmn.moves.each do |m|
          next if m.status_move?
          if ["IgnoreTargetAbility",
              "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function_code)
            reserve_has_super_effective_move = true
            break
          end
          eff = Effectiveness.calculate(m.type, *foe_types)
          if Effectiveness.super_effective?(eff)
            reserve_has_super_effective_move = true
            break
          end
        end
        break if reserve_has_super_effective_move
      end
      next false if !reserve_has_super_effective_move
      PBDebug.log_ai("#{battler.name} wants to switch because it can't do anything against Wonder Guard")
      next true
    end
    next false
  }
)

#===============================================================================
# If Pokémon is within 5 levels of the foe, and foe's last move was
# super-effective and powerful.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:high_damage_from_foe,
  proc { |battler, reserves, ai, battle|
    next false if battler.hp >= battler.totalhp / 2
    next false if !ai.trainer.high_skill?
    big_threat = false
    ai.each_foe_battler(battler.side) do |b, i|
      next if (foe.level - battler.level).abs > 5
      next if !b.battler.lastMoveUsed
      move_data = GameData::Move.get(b.battler.lastMoveUsed)
      next if move_data.status?
      eff = battler.effectiveness_of_type_against_battler(move_data.type, b)
      next if !Effectiveness.super_effective?(eff) || move_data.power < 60
      switch_chance = (move_data.power > 90) ? 50 : 25
      if ai.pbAIRandom(100) < switch_chance
        big_threat = true
        break
      end
    end
    if big_threat
      PBDebug.log_ai("#{battler.name} wants to switch because a foe can do a lot of damage to it")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon can't do anything (must have been in battle for at least 3 rounds).
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:battler_is_useless,
  proc { |battler, reserves, ai, battle|
    if !battle.pbCanChooseAnyMove?(battler.index) && battler.turnCount >= 3
      PBDebug.log_ai("#{battler.name} wants to switch because it can't do anything")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon is Encored into an unfavourable move.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:bad_encored_move,
  proc { |battler, reserves, ai, battle|
    next false if battler.effects[PBEffects::Encore] == 0
    idxEncoredMove = battler.battler.pbEncoredMoveIndex
    next false if idxEncoredMove < 0
    ai.set_up_move_check(battler.moves[idxEncoredMove])
    scoreSum   = 0
    scoreCount = 0
    battler.battler.allOpposing.each do |b|
      scoreSum += ai.pbGetMoveScore([b])
      scoreCount += 1
    end
    if scoreCount > 0 && scoreSum / scoreCount <= 20
      if ai.pbAIRandom(100) < 80
        PBDebug.log_ai("#{battler.name} wants to switch because of encoring a bad move")
        next true
      else
        next false
      end
    end
    next false
  }
)

#===============================================================================
# Sudden Death rule - I'm not sure what this means.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:sudden_death,
  proc { |battler, reserves, ai, battle|
    if battle.rules["suddendeath"] && battler.turnCount > 0
      if battler.hp <= battler.totalhp / 4 && ai.pbAIRandom(100) < 30
        PBDebug.log_ai("#{battler.name} wants to switch because of the sudden death rule")
        next true
      elsif battler.hp <= battler.totalhp / 2 && ai.pbAIRandom(100) < 80
        PBDebug.log_ai("#{battler.name} wants to switch because of the sudden death rule")
        next true
      end
    end
    next false
  }
)

#===============================================================================
# Don't bother switching if the battler will just faint from entry hazard damage
# upon switching back in.
# TODO: Allow it if the replacement will be able to get rid of entry hazards?
#===============================================================================
# Battle::AI::Handlers::ShouldNotSwitch.add(:lethal_entry_hazards,
#   proc { |battler, reserves, ai, battle|
#     entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pkmn, battler.side)
#     next entry_hazard_damage >= battler.hp
#   }
# )
