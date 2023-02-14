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
    # Don't switch if there is a single foe and it is resting after Hyper Beam
    # or will Truant (i.e. free turn)
    if @trainer.high_skill?
      foe_can_act = false
      each_foe_battler(@user.side) do |b|
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
      should_switch = Battle::AI::Handlers.should_switch?(@user, self, @battle)
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

  #=============================================================================

  def choose_best_replacement_pokemon(idxBattler, mandatory = false)
    # Get all possible replacement Pokémon
    party = @battle.pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    reserves = []
    party.each_with_index do |_pkmn, i|
      next if !@battle.pbCanSwitchIn?(idxBattler, i)
      if !mandatory
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
    if !mandatory
      # TODO: Should the current battler be rated as well, to provide a
      #       threshold instead of using a threshold of 100?
      return -1 if reserves[0][1] < 100   # Best replacement rated at <100, don't switch
    end
    # Return the best rated replacement Pokémon
    return reserves[0][0]
  end

  def rate_replacement_pokemon(idxBattler, pkmn, score)
    battler_side = @battle.sides[idxBattler & 1]
    pkmn_types = pkmn.types
    entry_hazard_damage = 0
    # Stealth Rock
    if battler_side.effects[PBEffects::StealthRock] && !pkmn.hasAbility?(:MAGICGUARD) &&
       GameData::Type.exists?(:ROCK) && !pkmn.hasItem?(:HEAVYDUTYBOOTS)
      eff = Effectiveness.calculate(:ROCK, *pkmn_types)
      if !Effectiveness.ineffective?(eff)
        entry_hazard_damage += pkmn.totalhp * eff / 8
      end
    end
    # Spikes
    if battler_side.effects[PBEffects::Spikes] > 0 && !pkmn.hasAbility?(:MAGICGUARD) &&
       !battler.airborne? && !pkmn.hasItem?(:HEAVYDUTYBOOTS)
      if @battle.field.effects[PBEffects::Gravity] > 0 || pkmn.hasItem?(:IRONBALL) ||
         !(pkmn.hasType?(:FLYING) || pkmn.hasItem?(:LEVITATE) || pkmn.hasItem?(:AIRBALLOON))
        spikes_div = [8, 6, 4][battler_side.effects[PBEffects::Spikes] - 1]
        entry_hazard_damage += pkmn.totalhp / spikes_div
      end
    end
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
    # Add power * effectiveness / 10 of all moves to score
    pkmn.moves.each do |m|
      next if m.power == 0 || (m.pp == 0 && m.total_pp > 0)
      @battle.battlers[idxBattler].allOpposing.each do |b|
        bTypes = b.pbTypes(true)
        score += m.power * Effectiveness.calculate(m.type, *bTypes) / 10
      end
    end
    # Prefer if user is about to faint from Perish Song
    score += 10 if @user.effects[PBEffects::PerishSong] == 1
    return score
  end
end

#===============================================================================
# If Pokémon is within 5 levels of the foe, and foe's last move was
# super-effective and powerful.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:high_damage_from_foe,
  proc { |battler, ai, battle|
    if battler.turnCount > 0 && battler.hp < battler.totalhp / 2 && ai.trainer.high_skill?
      target_battler = battler.battler.pbDirectOpposing(true)
      foe = ai.battlers[target_battler.index]
      if !foe.fainted? && foe.battler.lastMoveUsed && (foe.level - battler.level).abs <= 5
        move_data = GameData::Move.get(foe.battler.lastMoveUsed)
        eff = battler.effectiveness_of_type_against_battler(move_data.type, foe)
        if Effectiveness.super_effective?(eff) && move_data.power > 70
          switch_chance = (move_data.power > 95) ? 40 : 20
          if ai.pbAIRandom(100) < switch_chance
            PBDebug.log_ai("#{battler.name} wants to switch because a foe can do a lot of damage to it")
            next true
          end
        end
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon can't do anything (must have been in battle for at least 5 rounds).
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:battler_is_useless,
  proc { |battler, ai, battle|
    if !battle.pbCanChooseAnyMove?(battler.index) && battler.turnCount >= 5
      PBDebug.log_ai("#{battler.name} wants to switch because it can't do anything")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon is Perish Songed and has Baton Pass.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:perish_song,
  proc { |battler, ai, battle|
    if battler.effects[PBEffects::PerishSong] == 1
      PBDebug.log_ai("#{battler.name} wants to switch because it is about to faint from Perish Song")
      next true
    end
    next false
  }
)

#===============================================================================
# Pokémon will faint because of bad poisoning at the end of this round, but
# would survive at least one more round if it were regular poisoning instead.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:reduce_toxic_to_regular_poisoning,
  proc { |battler, ai, battle|
    if battler.status == :POISON && battler.statusCount > 0 && ai.trainer.high_skill?
      next false if battler.has_active_ability?(:POISONHEAL)
      next false if !battler.battler.takesIndirectDamage?
      poison_damage = battler.totalhp / 8
      next_toxic_damage = battler.totalhp * (battler.effects[PBEffects::Toxic] + 1) / 16
      if battler.hp <= next_toxic_damage && battler.hp > poison_damage
        if ai.pbAIRandom(100) < 80
          PBDebug.log_ai("#{battler.name} wants to switch to reduce toxic to regular poisoning")
          next true
        end
      end
    end
    next false
  }
)

#===============================================================================
# Pokémon is Encored into an unfavourable move.
# TODO: Review switch deciding.
#===============================================================================
Battle::AI::Handlers::ShouldSwitch.add(:bad_encored_move,
  proc { |battler, ai, battle|
    if battler.effects[PBEffects::Encore] > 0 && ai.trainer.medium_skill?
      idxEncoredMove = battler.battler.pbEncoredMoveIndex
      if idxEncoredMove >= 0
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
  proc { |battler, ai, battle|
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
