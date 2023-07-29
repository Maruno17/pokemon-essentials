#===============================================================================
# ItemHandlers
#===============================================================================
module ItemHandlers
  UseText             = ItemHandlerHash.new
  UseFromBag          = ItemHandlerHash.new
  ConfirmUseInField   = ItemHandlerHash.new
  UseInField          = ItemHandlerHash.new
  UseOnPokemon        = ItemHandlerHash.new
  UseOnPokemonMaximum = ItemHandlerHash.new
  CanUseInBattle      = ItemHandlerHash.new
  UseInBattle         = ItemHandlerHash.new
  BattleUseOnBattler  = ItemHandlerHash.new
  BattleUseOnPokemon  = ItemHandlerHash.new

  def self.hasUseText(item)
    return !UseText[item].nil?
  end

  # Shows "Use" option in Bag.
  def self.hasOutHandler(item)
    return !UseFromBag[item].nil? || !UseInField[item].nil? || !UseOnPokemon[item].nil?
  end

  # Shows "Register" option in Bag.
  def self.hasUseInFieldHandler(item)
    return !UseInField[item].nil?
  end

  def self.hasUseOnPokemon(item)
    return !UseOnPokemon[item].nil?
  end

  def self.hasUseOnPokemonMaximum(item)
    return !UseOnPokemonMaximum[item].nil?
  end

  def self.hasUseInBattle(item)
    return !UseInBattle[item].nil?
  end

  def self.hasBattleUseOnBattler(item)
    return !BattleUseOnBattler[item].nil?
  end

  def self.hasBattleUseOnPokemon(item)
    return !BattleUseOnPokemon[item].nil?
  end

  # Returns text to display instead of "Use"
  def self.getUseText(item)
    return UseText.trigger(item)
  end

  # Return value:
  # 0 - Item not used
  # 1 - Item used, don't end screen
  # 2 - Item used, end screen
  def self.triggerUseFromBag(item)
    return UseFromBag.trigger(item) if UseFromBag[item]
    # No UseFromBag handler exists; check the UseInField handler if present
    if UseInField[item]
      return (UseInField.trigger(item)) ? 1 : 0
    end
    return 0
  end

  # Returns whether item can be used
  def self.triggerConfirmUseInField(item)
    return true if !ConfirmUseInField[item]
    return ConfirmUseInField.trigger(item)
  end

  # Return value:
  # -1 - Item effect not found
  # 0  - Item not used
  # 1  - Item used
  def self.triggerUseInField(item)
    return -1 if !UseInField[item]
    return (UseInField.trigger(item)) ? 1 : 0
  end

  # Returns whether item was used
  def self.triggerUseOnPokemon(item, qty, pkmn, scene)
    return false if !UseOnPokemon[item]
    return UseOnPokemon.trigger(item, qty, pkmn, scene)
  end

  # Returns the maximum number of the item that can be used on the Pokémon at once.
  def self.triggerUseOnPokemonMaximum(item, pkmn)
    return 1 if !UseOnPokemonMaximum[item]
    return 1 if !Settings::USE_MULTIPLE_STAT_ITEMS_AT_ONCE
    return [UseOnPokemonMaximum.trigger(item, pkmn), 1].max
  end

  def self.triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages = true)
    return true if !CanUseInBattle[item]   # Can use the item by default
    return CanUseInBattle.trigger(item, pkmn, battler, move, firstAction, battle, scene, showMessages)
  end

  def self.triggerUseInBattle(item, battler, battle)
    UseInBattle.trigger(item, battler, battle)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnBattler(item, battler, scene)
    return false if !BattleUseOnBattler[item]
    return BattleUseOnBattler.trigger(item, battler, scene)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnPokemon(item, pkmn, battler, choices, scene)
    return false if !BattleUseOnPokemon[item]
    return BattleUseOnPokemon.trigger(item, pkmn, battler, choices, scene)
  end
end

#===============================================================================
#
#===============================================================================
def pbCanRegisterItem?(item)
  return ItemHandlers.hasUseInFieldHandler(item)
end

def pbCanUseOnPokemon?(item)
  return ItemHandlers.hasUseOnPokemon(item) || GameData::Item.get(item).is_machine?
end

#===============================================================================
# Change a Pokémon's level
#===============================================================================
def pbChangeLevel(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s level remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s level remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  pkmn.level = new_level
  pkmn.calc_stats
  pkmn.hp = 1 if new_level > old_level && pkmn.species_data.base_stats[:HP] == 1
  scene.pbRefresh
  if old_level > new_level
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else
    pkmn.changeHappiness("vitamin")
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\nAttack<r>+{2}\nDefense<r>+{3}\nSp. Atk<r>+{4}\nSp. Def<r>+{5}\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic do
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      end
    end
  end
end

def pbTopRightWindow(text, scene = nil)
  window = Window_AdvancedTextPokemon.new(text)
  window.width = 198
  window.x     = Graphics.width - window.width
  window.y     = 0
  window.z     = 99999
  pbPlayDecisionSE
  loop do
    Graphics.update
    Input.update
    window.update
    scene&.pbUpdate
    break if Input.trigger?(Input::USE)
  end
  window.dispose
end

def pbChangeExp(pkmn, new_exp, scene)
  new_exp = new_exp.clamp(0, pkmn.growth_rate.maximum_exp)
  if pkmn.exp == new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    else
      pbMessage(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
    end
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  if pkmn.exp > new_exp   # Loses Exp
    difference = pkmn.exp - new_exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
  else   # Gains Exp
    difference = new_exp - pkmn.exp
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.changeHappiness("vitamin")
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
    end
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\nAttack<r>+{2}\nDefense<r>+{3}\nSp. Atk<r>+{4}\nSp. Def<r>+{5}\nSpeed<r>+{6}",
                           total_hp_diff, attack_diff, defense_diff, special_attack_diff, special_defense_diff, speed_diff), scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\nAttack<r>{2}\nDefense<r>{3}\nSp. Atk<r>{4}\nSp. Def<r>{5}\nSpeed<r>{6}",
                           pkmn.totalhp, pkmn.attack, pkmn.defense, pkmn.spatk, pkmn.spdef, pkmn.speed), scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true) { scene.pbUpdate }
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic do
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      end
    end
  end
end

def pbGainExpFromExpCandy(pkmn, base_amt, qty, scene)
  if pkmn.level >= GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  pbSEPlay("Pkmn level up")
  scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  if qty > 1
    (qty - 1).times { pkmn.changeHappiness("vitamin") }
  end
  pbChangeExp(pkmn, pkmn.exp + (base_amt * qty), scene)
  scene.pbHardRefresh
  return true
end

#===============================================================================
# Restore HP
#===============================================================================
def pbItemRestoreHP(pkmn, restoreHP)
  newHP = pkmn.hp + restoreHP
  newHP = pkmn.totalhp if newHP > pkmn.totalhp
  hpGain = newHP - pkmn.hp
  pkmn.hp = newHP
  return hpGain
end

def pbHPItem(pkmn, restoreHP, scene)
  if !pkmn.able? || pkmn.hp == pkmn.totalhp
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  pbSEPlay("Use item in party")
  hpGain = pbItemRestoreHP(pkmn, restoreHP)
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpGain))
  return true
end

def pbBattleHPItem(pkmn, battler, restoreHP, scene)
  if battler
    if battler.pbRecoverHP(restoreHP) > 0
      scene.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    end
  elsif pbItemRestoreHP(pkmn, restoreHP) > 0
    scene.pbDisplay(_INTL("{1}'s HP was restored.", pkmn.name))
  end
  return true
end

#===============================================================================
# Restore PP
#===============================================================================
def pbRestorePP(pkmn, idxMove, pp)
  return 0 if !pkmn.moves[idxMove] || !pkmn.moves[idxMove].id
  return 0 if pkmn.moves[idxMove].total_pp <= 0
  oldpp = pkmn.moves[idxMove].pp
  newpp = pkmn.moves[idxMove].pp + pp
  newpp = pkmn.moves[idxMove].total_pp if newpp > pkmn.moves[idxMove].total_pp
  pkmn.moves[idxMove].pp = newpp
  return newpp - oldpp
end

def pbBattleRestorePP(pkmn, battler, idxMove, pp)
  return if pbRestorePP(pkmn, idxMove, pp) == 0
  if battler && !battler.effects[PBEffects::Transform] &&
     battler.moves[idxMove] && battler.moves[idxMove].id == pkmn.moves[idxMove].id
    battler.pbSetPP(battler.moves[idxMove], pkmn.moves[idxMove].pp)
  end
end

#===============================================================================
# Change EVs
#===============================================================================
def pbJustRaiseEffortValues(pkmn, stat, evGain)
  stat = GameData::Stat.get(stat).id
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbRaiseEffortValues(pkmn, stat, evGain = 10, no_ev_cap = false)
  stat = GameData::Stat.get(stat).id
  return 0 if !no_ev_cap && pkmn.ev[stat] >= 100
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, 100 - pkmn.ev[stat]) if !no_ev_cap
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbMaxUsesOfEVRaisingItem(stat, amt_per_use, pkmn, no_ev_cap = false)
  max_per_stat = (no_ev_cap) ? Pokemon::EV_STAT_LIMIT : 100
  amt_can_gain = max_per_stat - pkmn.ev[stat]
  ev_total = 0
  GameData::Stat.each_main { |s| ev_total += pkmn.ev[s.id] }
  amt_can_gain = [amt_can_gain, Pokemon::EV_LIMIT - ev_total].min
  return [(amt_can_gain.to_f / amt_per_use).ceil, 1].max
end

def pbUseEVRaisingItem(stat, amt_per_use, qty, pkmn, happiness_type, scene, no_ev_cap = false)
  ret = true
  qty.times do |i|
    if pbRaiseEffortValues(pkmn, stat, amt_per_use, no_ev_cap) > 0
      pkmn.changeHappiness(happiness_type)
    else
      ret = false if i == 0
      break
    end
  end
  if !ret
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  pbSEPlay("Use item in party")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s {2} increased.", pkmn.name, GameData::Stat.get(stat).name))
  return true
end

def pbMaxUsesOfEVLoweringBerry(stat, pkmn)
  ret = (pkmn.ev[stat].to_f / 10).ceil
  happiness = pkmn.happiness
  uses = 0
  if happiness < 255
    bonus_per_use = 0
    bonus_per_use += 1 if pkmn.obtain_map == $game_map.map_id
    bonus_per_use += 1 if pkmn.poke_ball == :LUXURYBALL
    has_soothe_bell = pkmn.hasItem?(:SOOTHEBELL)
    loop do
      uses += 1
      gain = [10, 5, 2][happiness / 100]
      gain += bonus_per_use
      gain = (gain * 1.5).floor if has_soothe_bell
      happiness += gain
      break if happiness >= 255
    end
  end
  return [ret, uses].max
end

def pbRaiseHappinessAndLowerEV(pkmn, scene, stat, qty, messages)
  h = pkmn.happiness < 255
  e = pkmn.ev[stat] > 0
  if !h && !e
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if h
    qty.times { |i| pkmn.changeHappiness("evberry") }
  end
  if e
    pkmn.ev[stat] -= 10 * qty
    pkmn.ev[stat] = 0 if pkmn.ev[stat] < 0
    pkmn.calc_stats
  end
  scene.pbRefresh
  scene.pbDisplay(messages[2 - (h ? 0 : 2) - (e ? 0 : 1)])
  return true
end

#===============================================================================
# Change nature
#===============================================================================
def pbNatureChangingMint(new_nature, item, pkmn, scene)
  if pkmn.nature_for_stats == new_nature
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if !scene.pbConfirm(_INTL("It might affect {1}'s stats. Are you sure you want to use it?", pkmn.name))
    return false
  end
  pkmn.nature_for_stats = new_nature
  pkmn.calc_stats
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s stats may have changed due to the effects of the {2}!",
                        pkmn.name, GameData::Item.get(item).name))
  return true
end

#===============================================================================
# Battle items
#===============================================================================
def pbBattleItemCanCureStatus?(status, pkmn, scene, showMessages)
  if !pkmn.able? || pkmn.status != status
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    return false
  end
  return true
end

def pbBattleItemCanRaiseStat?(stat, battler, scene, showMessages)
  if !battler || !battler.pbCanRaiseStatStage?(stat, battler)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    return false
  end
  return true
end

#===============================================================================
# Decide whether the player is able to ride/dismount their Bicycle
#===============================================================================
def pbBikeCheck
  if $PokemonGlobal.surfing || $PokemonGlobal.diving ||
     (!$PokemonGlobal.bicycle &&
     ($game_player.pbTerrainTag.must_walk || $game_player.pbTerrainTag.must_walk_or_run))
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  if !$game_player.can_ride_vehicle_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  map_metadata = $game_map.metadata
  if $PokemonGlobal.bicycle
    if map_metadata&.always_bicycle
      pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  end
  if !map_metadata || (!map_metadata.can_bicycle && !map_metadata.outdoor_map)
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  return true
end

#===============================================================================
# Find the closest hidden item (for Itemfinder)
#===============================================================================
def pbClosestHiddenItem
  result = []
  playerX = $game_player.x
  playerY = $game_player.y
  $game_map.events.each_value do |event|
    next if !event.name[/hiddenitem/i]
    next if (playerX - event.x).abs >= 8
    next if (playerY - event.y).abs >= 6
    next if $game_self_switches[[$game_map.map_id, event.id, "A"]]
    result.push(event)
  end
  return nil if result.length == 0
  ret = nil
  retmin = 0
  result.each do |event|
    dist = (playerX - event.x).abs + (playerY - event.y).abs
    next if ret && retmin <= dist
    ret = event
    retmin = dist
  end
  return ret
end

#===============================================================================
# Teach and forget a move
#===============================================================================
def pbLearnMove(pkmn, move, ignore_if_known = false, by_machine = false, &block)
  return false if !pkmn
  move = GameData::Move.get(move).id
  if pkmn.egg? && !$DEBUG
    pbMessage(_INTL("Eggs can't be taught any moves."), &block)
    return false
  elsif pkmn.shadowPokemon?
    pbMessage(_INTL("Shadow Pokémon can't be taught any moves."), &block)
    return false
  end
  pkmn_name = pkmn.name
  move_name = GameData::Move.get(move).name
  if pkmn.hasMove?(move)
    pbMessage(_INTL("{1} already knows {2}.", pkmn_name, move_name), &block) if !ignore_if_known
    return false
  elsif pkmn.numMoves < Pokemon::MAX_MOVES
    pkmn.learn_move(move)
    pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
    return true
  end
  pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
                  pkmn_name, move_name, pkmn.numMoves.to_word) + "\1", &block)
  if pbConfirmMessage(_INTL("Should {1} forget a move to learn {2}?", pkmn_name, move_name), &block)
    loop do
      move_index = pbForgetMove(pkmn, move)
      if move_index >= 0
        old_move_name = pkmn.moves[move_index].name
        oldmovepp = pkmn.moves[move_index].pp
        pkmn.moves[move_index] = Pokemon::Move.new(move)   # Replaces current/total PP
        if by_machine && Settings::TAUGHT_MACHINES_KEEP_OLD_PP
          pkmn.moves[move_index].pp = [oldmovepp, pkmn.moves[move_index].total_pp].min
        end
        pbMessage(_INTL("1, 2, and...\\wt[16] ...\\wt[16] ...\\wt[16] Ta-da!") + "\\se[Battle ball drop]\1", &block)
        pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd..." + "\1", pkmn_name, old_move_name), &block)
        pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
        pkmn.changeHappiness("machine") if by_machine
        return true
      elsif pbConfirmMessage(_INTL("Give up on learning {1}?", move_name), &block)
        pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
        return false
      end
    end
  else
    pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
  end
  return false
end

def pbForgetMove(pkmn, moveToLearn)
  ret = -1
  pbFadeOutIn do
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pkmn], 0, moveToLearn)
  end
  return ret
end

#===============================================================================
# Use an item from the Bag and/or on a Pokémon
#===============================================================================
# @return [Integer] 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbUseItem(bag, item, bagscene = nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if useType == 1   # Item is usable on a Pokémon
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      $player.party.each do |pkmn|
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn do
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"), false, annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen < 0
          ret = false
          break
        end
        pkmn = $player.party[chosen]
        next if !pbCheckUseOnPokemon(item, pkmn, screen)
        qty = 1
        max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
        max_at_once = [max_at_once, $bag.quantity(item)].min
        if max_at_once > 1
          qty = screen.scene.pbChooseNumber(
            _INTL("How many {1} do you want to use?", GameData::Item.get(item).portion_name_plural), max_at_once
          )
          screen.scene.pbSetHelpText("") if screen.is_a?(PokemonPartyScreen)
        end
        next if qty <= 0
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
        next unless ret && itm.consumed_after_use?
        bag.remove(item, qty)
        next if bag.has?(item)
        pbMessage(_INTL("You used your last {1}.", itm.portion_name)) { screen.pbUpdate }
        break
      end
      screen.pbEndScene
      bagscene&.pbRefresh
    end
    return (ret) ? 1 : 0
  elsif useType == 2 || itm.is_machine?   # Item is usable from Bag or teaches a move
    intret = ItemHandlers.triggerUseFromBag(item)
    if intret >= 0
      bag.remove(item) if intret == 1 && itm.consumed_after_use?
      return intret
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end

# Only called when in the party screen and having chosen an item to be used on
# the selected Pokémon
def pbUseItemOnPokemon(item, pkmn, scene)
  itm = GameData::Item.get(item)
  # TM or HM
  if itm.is_machine?
    machine = itm.move
    return false if !machine
    movename = GameData::Move.get(machine).name
    if pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { scene.pbUpdate }
    elsif !pkmn.compatible_with_move?(machine)
      pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { scene.pbUpdate }
    else
      pbMessage("\\se[PC access]" + _INTL("You booted up the {1}.", itm.portion_name) + "\1") { scene.pbUpdate }
      if pbConfirmMessage(_INTL("Do you want to teach {1} to {2}?", movename, pkmn.name)) { scene.pbUpdate }
        if pbLearnMove(pkmn, machine, false, true) { scene.pbUpdate }
          $bag.remove(item) if itm.consumed_after_use?
          return true
        end
      end
    end
    return false
  end
  # Other item
  qty = 1
  max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
  max_at_once = [max_at_once, $bag.quantity(item)].min
  if max_at_once > 1
    qty = scene.scene.pbChooseNumber(
      _INTL("How many {1} do you want to use?", itm.portion_name_plural), max_at_once
    )
    scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  end
  return false if qty <= 0
  ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, scene)
  scene.pbClearAnnotations
  scene.pbHardRefresh
  if ret && itm.consumed_after_use?
    $bag.remove(item, qty)
    if !$bag.has?(item)
      pbMessage(_INTL("You used your last {1}.", itm.portion_name)) { scene.pbUpdate }
    end
  end
  return ret
end

def pbUseKeyItemInField(item)
  ret = ItemHandlers.triggerUseInField(item)
  if ret == -1   # Item effect not found
    pbMessage(_INTL("Can't use that here."))
  elsif ret > 0 && GameData::Item.get(item).consumed_after_use?
    $bag.remove(item)
  end
  return ret > 0
end

def pbUseItemMessage(item)
  itemname = GameData::Item.get(item).portion_name
  if itemname.starts_with_vowel?
    pbMessage(_INTL("You used an {1}.", itemname))
  else
    pbMessage(_INTL("You used a {1}.", itemname))
  end
end

def pbCheckUseOnPokemon(item, pkmn, _screen)
  return pkmn && !pkmn.egg? && (!pkmn.hyper_mode || GameData::Item.get(item)&.is_scent?)
end

#===============================================================================
# Give an item to a Pokémon to hold, and take a held item from a Pokémon
#===============================================================================
def pbGiveItemToPokemon(item, pkmn, scene, pkmnid = 0)
  newitemname = GameData::Item.get(item).portion_name
  if pkmn.egg?
    scene.pbDisplay(_INTL("Eggs can't hold items."))
    return false
  elsif pkmn.mail
    scene.pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", pkmn.name))
    return false if !pbTakeItemFromPokemon(pkmn, scene)
  end
  if pkmn.hasItem?
    olditemname = pkmn.item.portion_name
    if newitemname.starts_with_vowel?
      scene.pbDisplay(_INTL("{1} is already holding an {2}.", pkmn.name, olditemname) + "\1")
    else
      scene.pbDisplay(_INTL("{1} is already holding a {2}.", pkmn.name, olditemname) + "\1")
    end
    if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
      $bag.remove(item)
      if !$bag.add(pkmn.item)
        raise _INTL("Couldn't re-store deleted item in Bag somehow") if !$bag.add(item)
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      elsif GameData::Item.get(item).is_mail?
        if pbWriteMail(item, pkmn, pkmnid, scene)
          pkmn.item = item
          scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.", olditemname, pkmn.name, newitemname))
          return true
        elsif !$bag.add(item)
          raise _INTL("Couldn't re-store deleted item in Bag somehow")
        end
      else
        pkmn.item = item
        scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.", olditemname, pkmn.name, newitemname))
        return true
      end
    end
  elsif !GameData::Item.get(item).is_mail? || pbWriteMail(item, pkmn, pkmnid, scene)
    $bag.remove(item)
    pkmn.item = item
    scene.pbDisplay(_INTL("{1} is now holding the {2}.", pkmn.name, newitemname))
    return true
  end
  return false
end

def pbTakeItemFromPokemon(pkmn, scene)
  ret = false
  if !pkmn.hasItem?
    scene.pbDisplay(_INTL("{1} isn't holding anything.", pkmn.name))
  elsif !$bag.can_add?(pkmn.item)
    scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
  elsif pkmn.mail
    if scene.pbConfirm(_INTL("Save the removed mail in your PC?"))
      if pbMoveToMailbox(pkmn)
        scene.pbDisplay(_INTL("The mail was saved in your PC."))
        pkmn.item = nil
        ret = true
      else
        scene.pbDisplay(_INTL("Your PC's Mailbox is full."))
      end
    elsif scene.pbConfirm(_INTL("If the mail is removed, its message will be lost. OK?"))
      $bag.add(pkmn.item)
      scene.pbDisplay(_INTL("Received the {1} from {2}.", pkmn.item.portion_name, pkmn.name))
      pkmn.item = nil
      pkmn.mail = nil
      ret = true
    end
  else
    $bag.add(pkmn.item)
    scene.pbDisplay(_INTL("Received the {1} from {2}.", pkmn.item.portion_name, pkmn.name))
    pkmn.item = nil
    ret = true
  end
  return ret
end

#===============================================================================
# Choose an item from the Bag
#===============================================================================
def pbChooseItem(var = 0, *args)
  ret = nil
  pbFadeOutIn do
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, $bag)
    ret = screen.pbChooseItemScreen
  end
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseApricorn(var = 0)
  ret = nil
  pbFadeOutIn do
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, $bag)
    ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_apricorn? })
  end
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseFossil(var = 0)
  ret = nil
  pbFadeOutIn do
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, $bag)
    ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_fossil? })
  end
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Game Variable. Only items which the player has are listed.
def pbChooseItemFromList(message, variable, *args)
  commands = []
  itemid   = []
  args.each do |item|
    next if !GameData::Item.exists?(item)
    itm = GameData::Item.get(item)
    next if !$bag.has?(itm)
    commands.push(itm.name)
    itemid.push(itm.id)
  end
  if commands.length == 0
    $game_variables[variable] = :NONE
    return nil
  end
  commands.push(_INTL("Cancel"))
  itemid.push(nil)
  ret = pbMessage(message, commands, -1)
  if ret < 0 || ret >= commands.length - 1
    $game_variables[variable] = :NONE
    return nil
  end
  $game_variables[variable] = itemid[ret] || :NONE
  return itemid[ret]
end
