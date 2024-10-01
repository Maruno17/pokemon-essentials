#===============================================================================
# ItemHandlers.
#===============================================================================
module ItemHandlers
  UseText             = ItemHandlerHash.new
  UseFromBag          = ItemHandlerHash.new
  ConfirmUseInField   = ItemHandlerHash.new
  UseInField          = ItemHandlerHash.new
  UsableOnPokemon     = ItemHandlerHash.new
  UseOnPokemon        = ItemHandlerHash.new
  UseOnPokemonMaximum = ItemHandlerHash.new
  CanUseInBattle      = ItemHandlerHash.new
  UseInBattle         = ItemHandlerHash.new
  BattleUseOnBattler  = ItemHandlerHash.new
  BattleUseOnPokemon  = ItemHandlerHash.new

  module_function

  def hasUseText(item)
    return !UseText[item].nil?
  end

  # Shows "Use" option in Bag.
  def hasOutHandler(item)
    return !UseFromBag[item].nil? || !UseInField[item].nil? || !UseOnPokemon[item].nil?
  end

  # Shows "Register" option in Bag.
  def hasUseInFieldHandler(item)
    return !UseInField[item].nil?
  end

  def hasUsableOnPokemon(item)
    return !UsableOnPokemon[item].nil?
  end

  def hasUseOnPokemon(item)
    return !UseOnPokemon[item].nil?
  end

  def hasUseOnPokemonMaximum(item)
    return !UseOnPokemonMaximum[item].nil?
  end

  def hasUseInBattle(item)
    return !UseInBattle[item].nil?
  end

  def hasBattleUseOnBattler(item)
    return !BattleUseOnBattler[item].nil?
  end

  def hasBattleUseOnPokemon(item)
    return !BattleUseOnPokemon[item].nil?
  end

  # Returns text to display instead of "Use".
  def getUseText(item)
    return UseText.trigger(item)
  end

  # Return value:
  # 0 - Item not used
  # 1 - Item used, don't end screen
  # 2 - Item used, end screen
  def triggerUseFromBag(item, bag_screen = nil)
    return UseFromBag.trigger(item, bag_screen) if UseFromBag[item]
    # No UseFromBag handler exists; check the UseInField handler if present
    if UseInField[item]
      return (UseInField.trigger(item)) ? 1 : 0
    end
    return 0
  end

  # Returns whether item can be used.
  def triggerConfirmUseInField(item)
    return true if !ConfirmUseInField[item]
    return ConfirmUseInField.trigger(item)
  end

  # Return value:
  # -1 - Item effect not found
  # 0  - Item not used
  # 1  - Item used
  def triggerUseInField(item)
    return -1 if !UseInField[item]
    return (UseInField.trigger(item)) ? 1 : 0
  end

  # Returns whether item will have an effect if used on pkmn.
  def triggerUsableOnPokemon(item, pkmn)
    return false if !UsableOnPokemon[item]
    return UsableOnPokemon.trigger(item, pkmn)
  end

  # Returns whether item was used.
  def triggerUseOnPokemon(item, qty, pkmn, scene)
    return false if !UseOnPokemon[item]
    return UseOnPokemon.trigger(item, qty, pkmn, scene)
  end

  # Returns the maximum number of the item that can be used on the Pokémon at once.
  def triggerUseOnPokemonMaximum(item, pkmn)
    return 1 if !UseOnPokemonMaximum[item]
    return 1 if !Settings::USE_MULTIPLE_STAT_ITEMS_AT_ONCE
    return [UseOnPokemonMaximum.trigger(item, pkmn), 1].max
  end

  def triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages = true)
    return true if !CanUseInBattle[item]   # Can use the item by default
    return CanUseInBattle.trigger(item, pkmn, battler, move, firstAction, battle, scene, showMessages)
  end

  def triggerUseInBattle(item, battler, battle)
    UseInBattle.trigger(item, battler, battle)
  end

  # Returns whether item was used.
  def triggerBattleUseOnBattler(item, battler, scene)
    return false if !BattleUseOnBattler[item]
    return BattleUseOnBattler.trigger(item, battler, scene)
  end

  # Returns whether item was used.
  def triggerBattleUseOnPokemon(item, pkmn, battler, choices, scene)
    return false if !BattleUseOnPokemon[item]
    return BattleUseOnPokemon.trigger(item, pkmn, battler, choices, scene)
  end
end

#===============================================================================
#
#===============================================================================
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

#===============================================================================
#
#===============================================================================
def pbCanRegisterItem?(item)
  return ItemHandlers.hasUseInFieldHandler(item)
end

# Returns whether pkmn is able to have an item used on it.
def pbCanPokemonHaveItemUsedOnIt?(pkmn, item)
  return pkmn && !pkmn.egg? && (!pkmn.hyper_mode || GameData::Item.get(item)&.is_scent?)
end

# Used to filter the Bag when choosing an item to use on a party Pokémon.
# Also used in the Bag to indicate which party Pokémon the selected item is
# usable on.
def pbCanUseItemOnPokemon?(item)
  return ItemHandlers.hasUseOnPokemon(item) ||
         ItemHandlers.hasUsableOnPokemon(item) ||
         GameData::Item.get(item).is_machine?
end

# This method assumes the item is usable on a Pokémon. It returns whether the
# item will have an effect when used on pkmn, i.e. it won't have no effect.
# Used in the Bag to indicate which party Pokémon the selected item is usable
# on.
def pbItemHasEffectOnPokemon?(item, pkmn)
  return false if !pbCanPokemonHaveItemUsedOnIt?(pkmn, item)
  ret = ItemHandlers.triggerUsableOnPokemon(item, pkmn)
  return ret
end

#===============================================================================
# Use an item from the Bag and/or on a Pokémon.
#===============================================================================
# Called from the Bag screen and also when prompted to use a Repel when one runs
# out (bag_screen will be nil for the latter).
# @return [Integer] 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbUseItem(bag, item, bag_screen = nil)
  item_data = GameData::Item.get(item)
  useType = item_data.field_use
  if useType == 1   # Item is usable on a Pokémon
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if item_data.is_evolution_stone?
      annot = []
      $player.party.each do |pkmn|
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn do
      screen = UI::Party.new($player.party, mode: :use_item)
      if item_data.is_evolution_stone?
        screen.set_able_annotation_proc(proc { |pkmn| next pkmn.check_evolution_on_use_item(item) })
      end
      screen.choose_pokemon do |pkmn, party_index|
        next true if party_index < 0
        next false if !pbCanPokemonHaveItemUsedOnIt?(pkmn, item)
        qty = 1
        max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
        max_at_once = [max_at_once, bag.quantity(item)].min
        if max_at_once > 1
          pbPlayDecisionSE
          qty = screen.choose_number(
            _INTL("How many {1} do you want to use?", GameData::Item.get(item).portion_name_plural), max_at_once
          )
          screen.set_help_text("")
        end
        next false if qty <= 0
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
        if ret && item_data.consumed_after_use?
          bag.remove(item, qty)
          if !bag.has?(item)
            screen.show_message(_INTL("You used your last {1}.", item_data.portion_name))
            next true
          end
        end
        next false
      end
      bag_screen&.pbRefresh
    end
    return (ret) ? 1 : 0
  elsif useType == 2 || item_data.is_machine?   # Item is usable from Bag or teaches a move
    intret = ItemHandlers.triggerUseFromBag(item, bag_screen)
    if intret >= 0
      bag.remove(item) if intret == 1 && item_data.consumed_after_use?
      return intret
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end

# Only called when in the party screen and having chosen an item to be used on
# the selected Pokémon. screen is the party screen.
def pbUseItemOnPokemon(item, pkmn, screen)
  item_data = GameData::Item.get(item)
  # TM or HM
  if item_data.is_machine?
    move = item_data.move
    return false if !move
    move_name = GameData::Move.get(move).name
    if pkmn.shadowPokemon?
      screen.show_message(_INTL("Shadow Pokémon can't be taught any moves."))
    elsif !pkmn.compatible_with_move?(move)
      screen.show_message(_INTL("{1} can't learn {2}.", pkmn.name, move_name))
    else
      pbSEPlay("PC access")
      screen.show_message(_INTL("You booted up the {1}.", item_data.portion_name) + "\1")
      if screen.show_confirm_message(_INTL("Do you want to teach {1} to {2}?", move_name, pkmn.name))
        if pbLearnMove(pkmn, move, false, true) { screen.update }
          $bag.remove(item) if item_data.consumed_after_use?
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
    qty = screen.choose_number(
      _INTL("How many {1} do you want to use?", item_data.portion_name_plural), max_at_once
    )
    screen.set_help_text("")
  end
  return false if qty <= 0
  ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
  screen.clear_annotations
  screen.refresh
  if ret && item_data.consumed_after_use?
    $bag.remove(item, qty)
    if !$bag.has?(item)
      screen.show_message(_INTL("You used your last {1}.", item_data.portion_name))
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

#===============================================================================
# Give an item to a Pokémon to hold, and take a held item from a Pokémon.
#===============================================================================
# screen is either the party screen or the summary screen.
def pbGiveItemToPokemon(item, pkmn, screen, pkmnid = 0)
  return false if item.nil?
  # Check if the Pokémon can hold the item, or have its item removed if it's
  # already holding one
  if pkmn.egg?
    screen.show_message(_INTL("Eggs can't hold items."))
    return false
  elsif pkmn.mail
    screen.show_message(_INTL("{1}'s mail must be removed before giving it an item.", pkmn.name))
    return false if !pbTakeItemFromPokemon(pkmn, screen)
  end
  new_item_name = GameData::Item.get(item).portion_name
  if pkmn.hasItem?
    # Swap existing held item with the new item
    old_item_name = pkmn.item.portion_name
    if old_item_name.starts_with_vowel?
      screen.show_message(_INTL("{1} is already holding an {2}.", pkmn.name, old_item_name) + "\1")
    else
      screen.show_message(_INTL("{1} is already holding a {2}.", pkmn.name, old_item_name) + "\1")
    end
    if screen.show_confirm_message(_INTL("Would you like to switch the two items?"))
      $bag.remove(item)
      if !$bag.add(pkmn.item)
        raise _INTL("Couldn't re-store deleted item in Bag somehow") if !$bag.add(item)
        screen.show_message(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      elsif GameData::Item.get(item).is_mail?
        if pbWriteMail(item, pkmn, pkmnid, screen)
          pkmn.item = item
          screen.show_message(_INTL("Took the {1} from {2} and gave it the {3}.", old_item_name, pkmn.name, new_item_name))
          return true
        elsif !$bag.add(item)
          raise _INTL("Couldn't re-store deleted item in Bag somehow")
        end
      else
        pkmn.item = item
        screen.show_message(_INTL("Took the {1} from {2} and gave it the {3}.", old_item_name, pkmn.name, new_item_name))
        return true
      end
    end
  elsif !GameData::Item.get(item).is_mail? || pbWriteMail(item, pkmn, pkmnid, screen)
    # Give the new item
    $bag.remove(item)
    pkmn.item = item
    screen.show_message(_INTL("{1} is now holding the {2}.", pkmn.name, new_item_name))
    return true
  end
  return false
end

# screen is either the party screen or the summary screen.
def pbTakeItemFromPokemon(pkmn, screen)
  ret = false
  # Check if the Pokémon has an item to remove, and whether the item can be put
  # in the Bag
  if !pkmn.hasItem?
    screen.show_message(_INTL("{1} isn't holding anything.", pkmn.name))
    return false
  elsif !$bag.can_add?(pkmn.item)
    screen.show_message(_INTL("The Bag is full. The Pokémon's item could not be removed."))
    return false
  end
  if pkmn.mail
    # Remove a mail item
    if screen.show_confirm_message(_INTL("Save the removed mail in your PC?"))
      if pbMoveToMailbox(pkmn)
        pkmn.item = nil
        screen.show_message(_INTL("The mail was saved in your PC."))
        ret = true
      else
        screen.show_message(_INTL("Your PC's Mailbox is full."))
      end
    elsif screen.show_confirm_message(_INTL("If the mail is removed, its message will be lost. OK?"))
      item_name = pkmn.item.portion_name
      $bag.add(pkmn.item)
      pkmn.item = nil
      screen.show_message(_INTL("Received the {1} from {2}.", item_name, pkmn.name))
      ret = true
    end
  else
    # Remove a regular item
    item_name = pkmn.item.portion_name
    $bag.add(pkmn.item)
    pkmn.item = nil
    screen.show_message(_INTL("Received the {1} from {2}.", item_name, pkmn.name))
    ret = true
  end
  return ret
end

#===============================================================================
# Choose an item from a given list. Only lets you choose an item you have at
# least 1 of in the Bag. The chosen item's ID is stored in the given Game
# Variable.
#===============================================================================
def pbChooseItemFromList(message, variable, *args)
  commands = {}
  args.each do |item|
    item_data = GameData::Item.try_get(item)
    next if !item_data || !$bag.has?(item_data.id)
    commands[item_data.id] = item_data.name
  end
  if commands.length == 0
    $game_variables[variable] = :NONE
    return nil
  end
  commands[:NONE] = _INTL("Cancel")
  ret = pbMessage(message, commands.values, -1)
  if ret < 0 || ret >= commands.length - 1
    $game_variables[variable] = :NONE
    return nil
  end
  $game_variables[variable] = commands.keys[ret] || :NONE
  return commands.keys[ret]
end

#===============================================================================
# Change a Pokémon's level.
#===============================================================================
def pbChangeLevel(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1}'s level remained unchanged.", pkmn.name))
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
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
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
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
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
        scene.refresh if scene.is_a?(UI::Party)
      end
    end
  end
end

#===============================================================================
# Change a Pokémon's Experience amount.
#===============================================================================
def pbChangeExp(pkmn, new_exp, scene)
  new_exp = new_exp.clamp(0, pkmn.growth_rate.maximum_exp)
  if pkmn.exp == new_exp
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1}'s Exp. Points remained unchanged.", pkmn.name))
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
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} lost {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} dropped to Lv. {2}!", pkmn.name, pkmn.level))
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
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    else
      pbMessage(_INTL("{1} gained {2} Exp. Points!", pkmn.name, difference))
    end
    pkmn.exp = new_exp
    pkmn.changeHappiness("vitamin")
    pkmn.calc_stats
    scene.pbRefresh
    return if pkmn.level == old_level
    # Level changed
    if scene.is_a?(UI::Party)
      scene.show_message(_INTL("{1} grew to Lv. {2}!", pkmn.name, pkmn.level))
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
        scene.refresh if scene.is_a?(UI::Party)
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
  scene.set_help_text("") if scene.is_a?(UI::Party)
  if qty > 1
    (qty - 1).times { pkmn.changeHappiness("vitamin") }
  end
  pbChangeExp(pkmn, pkmn.exp + (base_amt * qty), scene)
  scene.pbHardRefresh
  return true
end

#===============================================================================
# Restore HP.
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
# Restore PP.
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
# Change EVs.
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
# Change nature.
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
# Battle items.
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
# Decide whether the player is able to ride/dismount their Bicycle.
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
# Find the closest hidden item (for Itemfinder).
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
# Teach and forget a move.
#===============================================================================
def pbLearnMove(pkmn, move, ignore_if_known = false, by_machine = false, screen = nil, &block)
  return false if !pkmn
  pkmn_name = pkmn.name
  move = GameData::Move.get(move).id
  move_name = GameData::Move.get(move).name
  # Check if Pokémon is unable to learn any moves
  if pkmn.egg? && !$DEBUG
    pbMessage(_INTL("Eggs can't be taught any moves."), &block)
    return false
  elsif pkmn.shadowPokemon?
    pbMessage(_INTL("Shadow Pokémon can't be taught any moves."), &block)
    return false
  end
  # Check if Pokémon can learn this move
  if pkmn.hasMove?(move)
    if !ignore_if_known
      pbMessage(_INTL("{1} already knows {2}.", pkmn_name, move_name), &block)
    end
    return false
  elsif pkmn.numMoves < Pokemon::MAX_MOVES
    pkmn.learn_move(move)
    pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
    return true
  end
  # Pokémon needs to forget a move to learn this one
  pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
                  pkmn_name, move_name, pkmn.numMoves.to_word) + "\1", &block)
  if pbConfirmMessage(_INTL("Should {1} forget a move to learn {2}?", pkmn_name, move_name), &block)
    loop do
      move_index = pbForgetMove(pkmn, move, screen)
      if move_index >= 0
        old_move_name = pkmn.moves[move_index].name
        old_move_pp = pkmn.moves[move_index].pp
        pkmn.moves[move_index] = Pokemon::Move.new(move)   # Replaces current/total PP
        if by_machine && Settings::TAUGHT_MACHINES_KEEP_OLD_PP
          pkmn.moves[move_index].pp = [old_move_pp, pkmn.moves[move_index].total_pp].min
        end
        pbMessage(_INTL("1, 2, and...\\wt[16] ...\\wt[16] ...\\wt[16] Ta-da!") + "\\se[Battle ball drop]\1", &block)
        pbMessage(_INTL("{1} forgot how to use {2}.\nAnd...", pkmn_name, old_move_name) + "\1", &block)
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

def pbForgetMove(pkmn, move_to_learn, screen = nil)
  ret = -1
  pbFadeOutInWithUpdate(screen&.sprites) do
    summary_screen = UI::PokemonSummary.new([pkmn], 0, mode: :choose_move, new_move: move_to_learn)
    ret = summary_screen.choose_move
  end
  return ret
end
