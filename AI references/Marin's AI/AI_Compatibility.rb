class PokeBattle_Battle
  attr_reader :battleAI

  alias mkai_initialize initialize
  def initialize(*args)
    mkai_initialize(*args)
    @battleAI = MKAI.new(self, self.wildBattle?)
    @battleAI.sides[0].set_party(@party1)
    @battleAI.sides[0].set_trainers(@player)
    @battleAI.sides[1].set_party(@party2)
    @battleAI.sides[1].set_trainers(@opponent)
  end

  def pbRecallAndReplace(idxBattler, idxParty, batonPass = false)
    if !@battlers[idxBattler].fainted?
      @scene.pbRecall(idxBattler)
      @battleAI.sides[idxBattler % 2].recall(idxBattler)
    end
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    @scene.pbShowPartyLineup(idxBattler & 1) if pbSideSize(idxBattler) == 1
    pbMessagesOnReplace(idxBattler, idxParty)
    pbReplace(idxBattler, idxParty, batonPass)
  end

  # Bug fix (used b instead of battler)
  def pbMessageOnRecall(battler)
    if battler.pbOwnedByPlayer?
      if battler.hp<=battler.totalhp/4
        pbDisplayBrief(_INTL("Good job, {1}! Come back!",battler.name))
      elsif battler.hp<=battler.totalhp/2
        pbDisplayBrief(_INTL("OK, {1}! Come back!",battler.name))
      elsif battler.turnCount>=5
        pbDisplayBrief(_INTL("{1}, that’s enough! Come back!",battler.name))
      elsif battler.turnCount>=2
        pbDisplayBrief(_INTL("{1}, come back!",battler.name))
      else
        pbDisplayBrief(_INTL("{1}, switch out! Come back!",battler.name))
      end
    else
      owner = pbGetOwnerName(battler.index)
      pbDisplayBrief(_INTL("{1} withdrew {2}!",owner,battler.name))
    end
  end

  alias mkai_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    mkai_pbEndOfRoundPhase
    @battleAI.end_of_round
  end

  alias mkai_pbShowAbilitySplash pbShowAbilitySplash
  def pbShowAbilitySplash(battler, delay = false, logTrigger = true)
    mkai_pbShowAbilitySplash(battler, delay, logTrigger)
    @battleAI.reveal_ability(battler)
  end
end

class PokeBattle_Move
  attr_reader :statUp
  attr_reader :statDown

  alias mkai_pbReduceDamage pbReduceDamage
  def pbReduceDamage(user, target)
    mkai_pbReduceDamage(user, target)
    @battle.battleAI.register_damage(self, user, target, target.damageState.hpLost)
  end

  def pbCouldBeCritical?(user, target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    # Set up the critical hit ratios
    ratios = (NEWEST_BATTLE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
    c = 0
    # Ability effects that alter critical hit rate
    if c >= 0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability, user, target, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability, user, target, c)
    end
    # Item effects that alter critical hit rate
    if c >= 0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item, user, target, c)
    end
    return false if c < 0
    # Move-specific "always/never a critical hit" effects
    return false if pbCritialOverride(user,target) == -1
    return true
  end
end

class MKAI
  def pbAIRandom(x)
    return rand(x)
  end

  def pbDefaultChooseEnemyCommand(idxBattler)
    sideIndex = idxBattler % 2
    index = MKAI.battler_to_proj_index(idxBattler)
    side = @sides[sideIndex]
    projection = side.battlers[index]
    # Choose move
    data = projection.choose_move
    if data.nil?
      # Struggle
      @battle.pbAutoChooseMove(idxBattler)
    elsif data[0] == :ITEM
      # [:ITEM, item_id, target&]
      item = data[1]
      # Determine target of item (always the Pokémon choosing the action)
      useType = pbGetItemData(item, ITEM_BATTLE_USE)
      if data[2]
        target_index = data[2]
      else
        target_index = idxBattler
        if useType && (useType == 1 || useType == 6)   # Use on Pokémon
          target_index = @battle.battlers[target_index].pokemonIndex   # Party Pokémon
        end
      end
      # Register our item
      @battle.pbRegisterItem(idxBattler, item, target_index)
    elsif data[0] == :SWITCH
      # [:SWITCH, pokemon_index]
      @battle.pbRegisterSwitch(idxBattler, data[1])
    else
      # [move_index, move_target]
      move_index, move_target = data
      # Mega evolve if we determine that we should
      @battle.pbRegisterMegaEvolution(idxBattler) if projection.should_mega_evolve?(idxBattler)
      # Register our move
      @battle.pbRegisterMove(idxBattler, move_index, false)
      # Register the move's target
      @battle.pbRegisterTarget(idxBattler, move_target)
    end
  end


  #=============================================================================
  # Choose a replacement Pokémon
  #=============================================================================
  def pbDefaultChooseNewEnemy(idxBattler, party)
    proj = self.battler_to_projection(@battle.battlers[idxBattler])
    scores = proj.get_optimal_switch_choice
    scores.each do |_, _, proj|
      pkmn = proj.pokemon
      index = @battle.pbParty(idxBattler).index(pkmn)
      if @battle.pbCanSwitchLax?(idxBattler, index)
        return index
      end
    end
    return -1
  end
end

class PokeBattle_Battler
  alias mkai_pbInitialize pbInitialize
  def pbInitialize(pkmn, idxParty, batonPass = false)
    mkai_pbInitialize(pkmn, idxParty, batonPass)
    ai = @battle.battleAI
    sideIndex = @index % 2
    ai.sides[sideIndex].send_out(@index, self)
  end

  alias mkai_pbFaint pbFaint
  def pbFaint(*args)
    mkai_pbFaint(*args)
    @battle.battleAI.faint_battler(self)
  end
end

class PokeBattle_PoisonMove
  attr_reader :toxic
end

class Array
  def sum
    n = 0
    self.each { |e| n += e }
    n
  end
end

# Overwrite Frisk to show the enemy held item
BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item > 0
    end
    if foes.length > 0
      battle.pbShowAbilitySplash(battler)
      if NEWEST_BATTLE_MECHANICS
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis, b.pbThis(true), PBItems.getName(b.item)))
          battle.battleAI.reveal_item(b)
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis, PBItems.getName(foe.item)))
        battle.battleAI.reveal_item(foe)
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)