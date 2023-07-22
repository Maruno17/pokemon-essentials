#===============================================================================
#
#===============================================================================
class Battle::AI
  # Called by the AI's def pbDefaultChooseEnemyCommand, and by def pbChooseMove
  # if the only moves known are bad ones (the latter forces a switch if
  # possible). Also aliased by the Battle Palace and Battle Arena.
  def pbChooseToSwitchOut(terrible_moves = false)
    return false if !@battle.canSwitch   # Battle rule
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
    if terrible_moves
      PBDebug.log_ai("#{@user.name} is being forced to switch out")
    else
      return false if !@trainer.has_skill_flag?("ConsiderSwitching")
      reserves = get_non_active_party_pokemon(@user.index)
      return false if reserves.empty?
      should_switch = Battle::AI::Handlers.should_switch?(@user, reserves, self, @battle)
      if should_switch && @trainer.medium_skill?
        should_switch = false if Battle::AI::Handlers.should_not_switch?(@user, reserves, self, @battle)
      end
      return false if !should_switch
    end
    # Want to switch; find the best replacement Pokémon
    idxParty = choose_best_replacement_pokemon(@user.index, terrible_moves)
    if idxParty < 0   # No good replacement Pokémon found
      PBDebug.log("   => no good replacement Pokémon, will not switch after all")
      return false
    end
    # Prefer using Baton Pass instead of switching
    baton_pass = -1
    @user.battler.eachMoveWithIndex do |m, i|
      next if m.function_code != "SwitchOutUserPassOnEffects"   # Baton Pass
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

  #-----------------------------------------------------------------------------

  def choose_best_replacement_pokemon(idxBattler, terrible_moves = false)
    # Get all possible replacement Pokémon
    party = @battle.pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    reserves = []
    party.each_with_index do |_pkmn, i|
      next if !@battle.pbCanSwitchIn?(idxBattler, i)
      if !terrible_moves   # Not terrible_moves means choosing an action for the round
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
        next if !terrible_moves || reserves.length > 0
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
    if @trainer.high_skill? && !terrible_moves
      return -1 if reserves[0][1] < 100   # If best replacement rated at <100, don't switch
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
    if !pkmn.hasItem?(:HEAVYDUTYBOOTS) && !pokemon_airborne?(pkmn)
      # Toxic Spikes
      if @user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score -= 20 if pokemon_can_be_poisoned?(pkmn)
      end
      # Sticky Web
      if @user.pbOwnSide.effects[PBEffects::StickyWeb]
        score -= 15
      end
    end
    # Predict effectiveness of foe's last used move against pkmn
    each_foe_battler(@user.side) do |b, i|
      next if !b.battler.lastMoveUsed
      move_data = GameData::Move.try_get(b.battler.lastMoveUsed)
      next if !move_data || move_data.status?
      move_type = move_data.type
      eff = Effectiveness.calculate(move_type, *pkmn_types)
      score -= move_data.power * eff / 5
    end
    # Add power * effectiveness / 10 of all pkmn's moves to score
    pkmn.moves.each do |m|
      next if m.power == 0 || (m.pp == 0 && m.total_pp > 0)
      @battle.battlers[idxBattler].allOpposing.each do |b|
        next if pokemon_can_absorb_move?(b.pokemon, m, m.type)
        bTypes = b.pbTypes(true)
        score += m.power * Effectiveness.calculate(m.type, *bTypes) / 10
      end
    end
    # Prefer if pkmn has lower HP and its position will be healed by Wish
    position = @battle.positions[idxBattler]
    if position.effects[PBEffects::Wish] > 0
      amt = position.effects[PBEffects::WishAmount]
      if pkmn.totalhp - pkmn.hp > amt * 2 / 3
        score += 20 * [pkmn.totalhp - pkmn.hp, amt].min / pkmn.totalhp
      end
    end
    # Prefer if user is about to faint from Perish Song
    score += 20 if @user.effects[PBEffects::PerishSong] == 1
    return score
  end

  def calculate_entry_hazard_damage(pkmn, side)
    return 0 if pkmn.hasAbility?(:MAGICGUARD) || pkmn.hasItem?(:HEAVYDUTYBOOTS)
    ret = 0
    # Stealth Rock
    if @battle.sides[side].effects[PBEffects::StealthRock] && GameData::Type.exists?(:ROCK)
      pkmn_types = pkmn.types
      eff = Effectiveness.calculate(:ROCK, *pkmn_types)
      ret += pkmn.totalhp * eff / 8 if !Effectiveness.ineffective?(eff)
    end
    # Spikes
    if @battle.sides[side].effects[PBEffects::Spikes] > 0 && !pokemon_airborne?(pkmn)
      spikes_div = [8, 6, 4][@battle.sides[side].effects[PBEffects::Spikes] - 1]
      ret += pkmn.totalhp / spikes_div
    end
    return ret
  end
end

#===============================================================================
# Pokémon is about to faint because of Perish Song.
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
# Pokémon will take a significant amount of damage at the end of this round, or
# it has an effect that causes it damage at the end of this round which it can
# remove by switching.
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
# switching out. Covers all abilities with an OnSwitchOut AbilityEffects
# handler.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:cure_status_problem_by_switching_out,
  proc { |battler, reserves, ai, battle|
    next false if !battler.ability_active?
    # Don't try to cure a status problem/heal a bit of HP if entry hazards will
    # KO the battler if it switches back in
    entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pokemon, battler.side)
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
    if battler.ability == :NATURALCURE || (single_status_cure && single_status_cure == battler.status)
      # Cures status problem
      next false if battler.wants_status_problem?(battler.status)
      next false if battler.status == :SLEEP && battler.statusCount == 1   # Will wake up this round anyway
      next false if entry_hazard_damage >= battler.totalhp / 4
      # Don't bother curing a poisoning if Toxic Spikes will just re-poison the
      # battler when it switches back in
      if battler.status == :POISON && reserves.none? { |pkmn| pkmn.hasType?(:POISON) }
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 2
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 1 && battler.statusCount == 0
      end
      # Not worth curing status problems that still allow actions if at high HP
      next false if battler.hp >= battler.totalhp / 2 && ![:SLEEP, :FROZEN].include?(battler.status)
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to cure its status problem with #{battler.ability.name}")
        next true
      end
    elsif battler.ability == :REGENERATOR
      # Not worth healing if battler would lose more HP from switching back in later
      next false if entry_hazard_damage >= battler.totalhp / 3
      # Not worth healing HP if already at high HP
      next false if battler.hp >= battler.totalhp / 2
      # Don't bother if a foe is at low HP and could be knocked out instead
      if battler.check_for_move { |m| m.damagingMove? }
        weak_foe = false
        ai.each_foe_battler(battler.side) do |b, i|
          weak_foe = true if b.hp < b.totalhp / 3
          break if weak_foe
        end
        next false if weak_foe
      end
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to heal with #{battler.ability.name}")
        next true
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon's position is about to be healed by Wish, and a reserve can benefit
# more from that healing than the Pokémon can.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:wish_healing,
  proc { |battler, reserves, ai, battle|
    position = battle.positions[battler.index]
    next false if position.effects[PBEffects::Wish] == 0
    amt = position.effects[PBEffects::WishAmount]
    next false if battler.totalhp - battler.hp >= amt * 2 / 3   # Want to heal itself instead
    reserve_wants_healing_more = false
    reserves.each do |pkmn|
      entry_hazard_damage = ai.calculate_entry_hazard_damage(pkmn, battler.index & 1)
      next if entry_hazard_damage >= pkmn.hp
      reserve_wants_healing_more = (pkmn.totalhp - pkmn.hp - entry_hazard_damage >= amt * 2 / 3)
      break if reserve_wants_healing_more
    end
    if reserve_wants_healing_more
      PBDebug.log_ai("#{battler.name} wants to switch because Wish can heal a reserve more")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon is yawning and can't do anything while asleep.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:yawning,
  proc { |battler, reserves, ai, battle|
    # Yawning and can fall asleep because of it
    next false if battler.effects[PBEffects::Yawn] == 0 || !battler.battler.pbCanSleepYawn?
    # Doesn't want to be asleep (includes checking for moves usable while asleep)
    next false if battler.wants_status_problem?(:SLEEP)
    # Can't cure itself of sleep
    if battler.ability_active?
      next false if [:INSOMNIA, :NATURALCURE, :REGENERATOR, :SHEDSKIN].include?(battler.ability_id)
      next false if battler.ability_id == :HYDRATION && [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
    end
    next false if battler.has_active_item?([:CHESTOBERRY, :LUMBERRY]) && battler.battler.canConsumeBerry?
    # Ally can't cure sleep
    ally_can_heal = false
    ai.each_ally(battler.index) do |b, i|
      ally_can_heal = b.has_active_ability?(:HEALER)
      break if ally_can_heal
    end
    next false if ally_can_heal
    # Doesn't benefit from being asleep/isn't less affected by sleep
    next false if battler.has_active_ability?([:EARLYBIRD, :MARVELSCALE])
    # Not trapping another battler in battle
    if ai.trainer.high_skill?
      next false if ai.battlers.any? do |b|
        b.effects[PBEffects::JawLock] == battler.index ||
        b.effects[PBEffects::MeanLook] == battler.index ||
        b.effects[PBEffects::Octolock] == battler.index ||
        b.effects[PBEffects::TrappingUser] == battler.index
      end
      trapping = false
      ai.each_foe_battler(battler.side) do |b, i|
        next if b.ability_active? && Battle::AbilityEffects.triggerCertainSwitching(b.ability, b.battler, battle)
        next if b.item_active? && Battle::ItemEffects.triggerCertainSwitching(b.item, b.battler, battle)
        next if Settings::MORE_TYPE_EFFECTS && b.has_type?(:GHOST)
        next if b.battler.trappedInBattle?   # Relevant trapping effects are checked above
        if battler.ability_active?
          trapping = Battle::AbilityEffects.triggerTrappingByTarget(battler.ability, b.battler, battler.battler, battle)
          break if trapping
        end
        if battler.item_active?
          trapping = Battle::ItemEffects.triggerTrappingByTarget(battler.item, b.battler, battler.battler, battle)
          break if trapping
        end
      end
      next false if trapping
    end
    # Doesn't have sufficiently raised stats that would be lost by switching
    next false if battler.stages.any? { |key, val| val >= 2 }
    PBDebug.log_ai("#{battler.name} wants to switch because it is yawning and can't do anything while asleep")
    next true
  }
)

#===============================================================================
# Pokémon is asleep, won't wake up soon and can't do anything while asleep.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:asleep,
  proc { |battler, reserves, ai, battle|
    # Asleep and won't wake up this round or next round
    next false if battler.status != :SLEEP || battler.statusCount <= 2
    # Doesn't want to be asleep (includes checking for moves usable while asleep)
    next false if battler.wants_status_problem?(:SLEEP)
    # Doesn't benefit from being asleep
    next false if battler.has_active_ability?(:MARVELSCALE)
    # Doesn't know Rest (if it does, sleep is expected, so don't apply this check)
    next false if battler.check_for_move { |m| m.function_code == "HealUserFullyAndFallAsleep" }
    # Not trapping another battler in battle
    if ai.trainer.high_skill?
      next false if ai.battlers.any? do |b|
        b.effects[PBEffects::JawLock] == battler.index ||
        b.effects[PBEffects::MeanLook] == battler.index ||
        b.effects[PBEffects::Octolock] == battler.index ||
        b.effects[PBEffects::TrappingUser] == battler.index
      end
      trapping = false
      ai.each_foe_battler(battler.side) do |b, i|
        next if b.ability_active? && Battle::AbilityEffects.triggerCertainSwitching(b.ability, b.battler, battle)
        next if b.item_active? && Battle::ItemEffects.triggerCertainSwitching(b.item, b.battler, battle)
        next if Settings::MORE_TYPE_EFFECTS && b.has_type?(:GHOST)
        next if b.battler.trappedInBattle?   # Relevant trapping effects are checked above
        if battler.ability_active?
          trapping = Battle::AbilityEffects.triggerTrappingByTarget(battler.ability, b.battler, battler.battler, battle)
          break if trapping
        end
        if battler.item_active?
          trapping = Battle::ItemEffects.triggerTrappingByTarget(battler.item, b.battler, battler.battler, battle)
          break if trapping
        end
      end
      next false if trapping
    end
    # Doesn't have sufficiently raised stats that would be lost by switching
    next false if battler.stages.any? { |key, val| val >= 2 }
    # 50% chance to not bother
    next false if ai.pbAIRandom(100) < 50
    PBDebug.log_ai("#{battler.name} wants to switch because it is asleep and can't do anything")
    next true
  }
)

#===============================================================================
# Pokémon can't use any moves and isn't Destiny Bonding/Grudging/hiding behind a
# Substitute.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:battler_is_useless,
  proc { |battler, reserves, ai, battle|
    next false if !ai.trainer.medium_skill?
    next false if battler.turnCount < 2   # Just switched in, give it a chance
    next false if battle.pbCanChooseAnyMove?(battler.index)
    next false if battler.effects[PBEffects::DestinyBond] || battler.effects[PBEffects::Grudge]
    if battler.effects[PBEffects::Substitute]
      hidden_behind_substitute = true
      ai.each_foe_battler(battler.side) do |b, i|
        next if !b.check_for_move { |m| m.ignoresSubstitute?(b.battler) }
        hidden_behind_substitute = false
        break
      end
      next false if hidden_behind_substitute
    end
    PBDebug.log_ai("#{battler.name} wants to switch because it can't do anything")
    next true
  }
)

#===============================================================================
# Pokémon can't do anything to any foe because its ability absorbs all damage
# the Pokémon can deal out.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:foe_absorbs_all_moves_with_its_ability,
  proc { |battler, reserves, ai, battle|
    next false if battler.battler.turnCount < 2   # Don't switch out too quickly
    next false if battler.battler.hasMoldBreaker?
    # Check if battler can damage any of its foes
    can_damage_foe = false
    ai.each_foe_battler(battler.side) do |b, i|
      if ai.trainer.high_skill? && b.rough_end_of_round_damage > 0
        can_damage_foe = true   # Foe is being damaged already
        break
      end
      # Check for battler's moves that can damage the foe (b)
      battler.battler.eachMove do |move|
        next if move.statusMove?
        if ["IgnoreTargetAbility",
            "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function_code)
          can_damage_foe = true
          break
        end
        if !ai.pokemon_can_absorb_move?(b, move, move.pbCalcType(battler.battler))
          can_damage_foe = true
          break
        end
      end
      break if can_damage_foe
    end
    next false if can_damage_foe
    # Check if a reserve could damage any foe; only switch if one could
    reserve_can_damage_foe = false
    reserves.each do |pkmn|
      ai.each_foe_battler(battler.side) do |b, i|
        # Check for reserve's moves that can damage the foe (b)
        pkmn.moves.each do |move|
          next if move.status_move?
          if ["IgnoreTargetAbility",
              "CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function_code)
            reserve_can_damage_foe = true
            break
          end
          if !ai.pokemon_can_absorb_move?(b, move, move.type)
            reserve_can_damage_foe = true
            break
          end
        end
        break if reserve_can_damage_foe
      end
      break if reserve_can_damage_foe
    end
    next false if !reserve_can_damage_foe
    PBDebug.log_ai("#{battler.name} wants to switch because it can't damage the foe(s)")
    next true
  }
)

#===============================================================================
# Pokémon doesn't have an ability that makes it immune to a foe's move, but a
# reserve does (see def pokemon_can_absorb_move?). The foe's move is chosen
# randomly, or is their most powerful move if the trainer's skill level is good
# enough.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:absorb_foe_move,
  proc { |battler, reserves, ai, battle|
    next false if !ai.trainer.medium_skill?
    # Not worth it if the battler is evasive enough
    next false if battler.stages[:EVASION] >= 3
    # Not worth it if abilities are being negated
    next false if battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
    # Get the foe move with the highest power (or a random damaging move)
    foe_moves = []
    ai.each_foe_battler(battler.side) do |b, i|
      b.moves.each do |move|
        next if move.statusMove?
        m_power = move.power
        m_power = 100 if move.is_a?(Battle::Move::OHKO)
        m_type = move.pbCalcType(b.battler)
        foe_moves.push([m_power, m_type, move])
      end
    end
    next false if foe_moves.empty?
    if ai.trainer.high_skill?
      foe_moves.sort! { |a, b| a[0] <=> b[0] }   # Highest power move
      chosen_move = foe_moves.last
    else
      chosen_move = foe_moves[ai.pbAIRandom(foe_moves.length)]   # Random move
    end
    # Get the chosen move's information
    move_power = chosen_move[0]
    move_type = chosen_move[1]
    move = chosen_move[2]
    # Don't bother if the foe's best move isn't too strong
    next false if move_power < 70
    # Check battler for absorbing ability
    next false if ai.pokemon_can_absorb_move?(battler, move, move_type)
    # battler can't absorb move; find a party Pokémon that can
    if reserves.any? { |pkmn| ai.pokemon_can_absorb_move?(pkmn, move, move_type) }
      next false if ai.pbAIRandom(100) < 70
      PBDebug.log_ai("#{battler.name} wants to switch because it can't absorb a foe's move but a reserve can")
      next true
    end
    next false
  }
)

#===============================================================================
# Sudden Death rule (at the end of each round, if one side has more able Pokémon
# than the other side, that side wins). Avoid fainting at all costs.
# NOTE: This rule isn't used anywhere.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:sudden_death,
  proc { |battler, reserves, ai, battle|
    next false if !battle.rules["suddendeath"] || battler.turnCount == 0
    if battler.hp <= battler.totalhp / 2
      threshold = 100 * (battler.totalhp - battler.hp) / battler.totalhp
      if ai.pbAIRandom(100) < threshold
        PBDebug.log_ai("#{battler.name} wants to switch to avoid being KO'd and losing because of the sudden death rule")
        next true
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon is within 5 levels of the foe, and foe's last move was super-effective
# and powerful.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:high_damage_from_foe,
  proc { |battler, reserves, ai, battle|
    next false if !ai.trainer.high_skill?
    next false if battler.hp >= battler.totalhp / 2
    big_threat = false
    ai.each_foe_battler(battler.side) do |b, i|
      next if (b.level - battler.level).abs > 5
      next if !b.battler.lastMoveUsed || !GameData::Move.exists?(b.battler.lastMoveUsed)
      move_data = GameData::Move.get(b.battler.lastMoveUsed)
      next if move_data.status?
      eff = battler.effectiveness_of_type_against_battler(move_data.type, b)
      next if !Effectiveness.super_effective?(eff) || move_data.power < 70
      switch_chance = (move_data.power > 90) ? 50 : 25
      big_threat = (ai.pbAIRandom(100) < switch_chance)
      break if big_threat
    end
    if big_threat
      PBDebug.log_ai("#{battler.name} wants to switch because a foe has a powerful super-effective move")
      next true
    end
    next false
  }
)

#===============================================================================
#===============================================================================
#===============================================================================

#===============================================================================
# Don't bother switching if the battler will just faint from entry hazard damage
# upon switching back in, and if no reserve can remove the entry hazard(s).
# Switching out in this case means the battler becomes unusable, so it might as
# well stick around instead and do as much as it can.
#===============================================================================
Battle::AI::Handlers::ShouldNotSwitch.add(:lethal_entry_hazards,
  proc { |battler, reserves, ai, battle|
    next false if battle.rules["suddendeath"]
    # Check whether battler will faint from entry hazard(s)
    entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pokemon, battler.side)
    next false if entry_hazard_damage < battler.hp
    # Check for Rapid Spin
    reserve_can_remove_hazards = false
    reserves.each do |pkmn|
      pkmn.moves.each do |move|
        reserve_can_remove_hazards = (move.function_code == "RemoveUserBindingAndEntryHazards")
        break if reserve_can_remove_hazards
      end
      break if reserve_can_remove_hazards
    end
    next false if reserve_can_remove_hazards
    PBDebug.log_ai("#{battler.name} won't switch after all because it will faint from entry hazards if it switches back in")
    next true
  }
)

#===============================================================================
# Don't bother switching (50% chance) if the battler knows a super-effective
# move.
#===============================================================================
Battle::AI::Handlers::ShouldNotSwitch.add(:battler_has_super_effective_move,
  proc { |battler, reserves, ai, battle|
    next false if battler.effects[PBEffects::PerishSong] == 1
    next false if battle.rules["suddendeath"]
    has_super_effective_move = false
    battler.battler.eachMove do |move|
      next if move.pp == 0 && move.total_pp > 0
      next if move.statusMove?
      # NOTE: Ideally this would ignore moves that are unusable, but that would
      #       be too complicated to implement.
      move_type = move.type
      move_type = move.pbCalcType(battler.battler) if ai.trainer.medium_skill?
      ai.each_foe_battler(battler.side) do |b|
        # NOTE: Ideally this would ignore foes that move cannot target, but that
        #       is complicated enough to implement that I'm not bothering. It's
        #       also rare that it would matter.
        eff = b.effectiveness_of_type_against_battler(move_type, battler, move)
        has_super_effective_move = Effectiveness.super_effective?(eff)
        break if has_super_effective_move
      end
      break if has_super_effective_move
    end
    if has_super_effective_move && ai.pbAIRandom(100) < 50
      PBDebug.log_ai("#{battler.name} won't switch after all because it has a super-effective move")
      next true
    end
    next false
  }
)

#===============================================================================
# Don't bother switching if the battler has 4 or more positive stat stages.
# Negative stat stages are ignored.
#===============================================================================
Battle::AI::Handlers::ShouldNotSwitch.add(:battler_has_very_raised_stats,
  proc { |battler, reserves, ai, battle|
    next false if battle.rules["suddendeath"]
    stat_raises = 0
    battler.stages.each_value { |val| stat_raises += val if val > 0 }
    if stat_raises >= 4
      PBDebug.log_ai("#{battler.name} won't switch after all because it has a lot of raised stats")
      next true
    end
    next false
  }
)
