#===============================================================================
#
#===============================================================================
class Battle::AI
  HP_HEAL_ITEMS = {
    :POTION       => 20,
    :SUPERPOTION  => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50,
    :HYPERPOTION  => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200,
    :MAXPOTION    => 999,
    :BERRYJUICE   => 20,
    :SWEETHEART   => 20,
    :FRESHWATER   => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 30 : 50,
    :SODAPOP      => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 50 : 60,
    :LEMONADE     => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 70 : 80,
    :MOOMOOMILK   => 100,
    :ORANBERRY    => 10,
    :SITRUSBERRY  => 1,   # Actual amount is determined below (pkmn.totalhp / 4)
    :ENERGYPOWDER => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 60 : 50,
    :ENERGYROOT   => (Settings::REBALANCED_HEALING_ITEM_AMOUNTS) ? 120 : 200
  }
  HP_HEAL_ITEMS[:RAGECANDYBAR] = 20 if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
  FULL_RESTORE_ITEMS = [
    :FULLRESTORE
  ]
  ONE_STATUS_CURE_ITEMS = [   # Preferred over items that heal all status problems
    :AWAKENING, :CHESTOBERRY, :BLUEFLUTE,
    :ANTIDOTE, :PECHABERRY,
    :BURNHEAL, :RAWSTBERRY,
    :PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY,
    :ICEHEAL, :ASPEARBERRY
  ]
  ALL_STATUS_CURE_ITEMS = [
    :FULLHEAL, :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE,
    :SHALOURSABLE, :BIGMALASADA, :PEWTERCRUNCHIES, :LUMBERRY, :HEALPOWDER
  ]
  ALL_STATUS_CURE_ITEMS.push(:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS
  ONE_STAT_RAISE_ITEMS = {
    :XATTACK    => [:ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XATTACK2   => [:ATTACK, 2],
    :XATTACK3   => [:ATTACK, 3],
    :XATTACK6   => [:ATTACK, 6],
    :XDEFENSE   => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XDEFENSE2  => [:DEFENSE, 2],
    :XDEFENSE3  => [:DEFENSE, 3],
    :XDEFENSE6  => [:DEFENSE, 6],
    :XDEFEND    => [:DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XDEFEND2   => [:DEFENSE, 2],
    :XDEFEND3   => [:DEFENSE, 3],
    :XDEFEND6   => [:DEFENSE, 6],
    :XSPATK     => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XSPATK2    => [:SPECIAL_ATTACK, 2],
    :XSPATK3    => [:SPECIAL_ATTACK, 3],
    :XSPATK6    => [:SPECIAL_ATTACK, 6],
    :XSPECIAL   => [:SPECIAL_ATTACK, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XSPECIAL2  => [:SPECIAL_ATTACK, 2],
    :XSPECIAL3  => [:SPECIAL_ATTACK, 3],
    :XSPECIAL6  => [:SPECIAL_ATTACK, 6],
    :XSPDEF     => [:SPECIAL_DEFENSE, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XSPDEF2    => [:SPECIAL_DEFENSE, 2],
    :XSPDEF3    => [:SPECIAL_DEFENSE, 3],
    :XSPDEF6    => [:SPECIAL_DEFENSE, 6],
    :XSPEED     => [:SPEED, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XSPEED2    => [:SPEED, 2],
    :XSPEED3    => [:SPEED, 3],
    :XSPEED6    => [:SPEED, 6],
    :XACCURACY  => [:ACCURACY, (Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1],
    :XACCURACY2 => [:ACCURACY, 2],
    :XACCURACY3 => [:ACCURACY, 3],
    :XACCURACY6 => [:ACCURACY, 6]
  }
  ALL_STATS_RAISE_ITEMS = [
    :MAXMUSHROOMS
  ]
  REVIVE_ITEMS = {
    :REVIVE      => 5,
    :MAXREVIVE   => 7,
    :REVIVALHERB => 7,
    :MAXHONEY    => 7
  }

  #-----------------------------------------------------------------------------

  # Decide whether the opponent should use an item on the Pokémon.
  def pbChooseToUseItem
    item = nil
    idxTarget = nil   # Party index (battle_use type 1/2/3) or battler index
    idxMove = nil
    item, idxTarget, idxMove = choose_item_to_use
    return false if !item
    # Register use of item
    @battle.pbRegisterItem(@user.index, item, idxTarget, idxMove)
    PBDebug.log_ai("#{@user.name} will use item #{GameData::Item.get(item).name}")
    return true
  end

  # Return values are:
  #   item ID
  #   target index (party index for items with a battle use of 1/2/3, battler
  #     index otherwise)
  #   move index (for items usable on moves only)
  def choose_item_to_use
    return nil if !@battle.internalBattle
    items = @battle.pbGetOwnerItems(@user.index)
    return nil if !items || items.length == 0
    # Find all items usable on the Pokémon choosing this action
    pkmn = @user.battler.pokemon
    usable_items = {}
    items.each do |item|
      usage = get_usability_of_item_on_pkmn(item, @user.party_index, @user.side)
      usage.each_pair do |key, vals|
        usable_items[key] ||= []
        usable_items[key] += vals
      end
    end
    # Prioritise using a HP restoration item
    if usable_items[:hp_heal] && (pkmn.hp <= pkmn.totalhp / 4 ||
       (pkmn.hp <= pkmn.totalhp / 2 && pbAIRandom(100) < 30))
      usable_items[:hp_heal].sort! { |a, b| (a[2] == b[2]) ? a[3] <=> b[3] : a[2] <=> b[2] }
      usable_items[:hp_heal].each do |item|
        return item[0], item[1] if item[3] >= (pkmn.totalhp - pkmn.hp) * 0.75
      end
      return usable_items[:hp_heal].last[0], usable_items[:hp_heal].last[1]
    end
    # Next prioritise using a status-curing item
    if usable_items[:status_cure] &&
       ([:SLEEP, :FROZEN].include?(pkmn.status) || pbAIRandom(100) < 40)
      usable_items[:status_cure].sort! { |a, b| a[2] <=> b[2] }
      return usable_items[:status_cure].first[0], usable_items[:status_cure].first[1]
    end
    # Next try using an item that raises all stats (Max Mushrooms)
    if usable_items[:all_stats_raise] && pbAIRandom(100) < 30
      return usable_items[:stat_raise].first[0], usable_items[:stat_raise].first[1]
    end
    # Next try using an X item
    if usable_items[:stat_raise] && pbAIRandom(100) < 30
      usable_items[:stat_raise].sort! { |a, b| (a[2] == b[2]) ? a[3] <=> b[3] : a[2] <=> b[2] }
      return usable_items[:stat_raise].last[0], usable_items[:stat_raise].last[1]
    end
    # Find items usable on other Pokémon in the user's team
    # NOTE: Currently only checks Revives.
    usable_items = {}
    @battle.eachInTeamFromBattlerIndex(@user.index) do |team_pkmn, i|
      next if !team_pkmn.fainted?   # Remove this line to check unfainted Pokémon too
      items.each do |item|
        usage = get_usability_of_item_on_pkmn(item, i, @user.side)
        usage.each_pair do |key, vals|
          usable_items[key] ||= []
          usable_items[key] += vals
        end
      end
    end
    # Try using a Revive (prefer Max Revive-type items over Revive)
    if usable_items[:revive] &&
       (@battle.pbAbleNonActiveCount(@user.index) == 0 || pbAIRandom(100) < 40)
      usable_items[:revive].sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
      return usable_items[:revive].last[0], usable_items[:revive].last[1]
    end
    return nil
  end

  def get_usability_of_item_on_pkmn(item, party_index, side)
    pkmn = @battle.pbParty(side)[party_index]
    battler = @battle.pbFindBattler(party_index, side)
    ret = {}
    return ret if !@battle.pbCanUseItemOnPokemon?(item, pkmn, battler, @battle.scene, false)
    return ret if !ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, nil,
                                                      false, self, @battle.scene, false)
    want_to_cure_status = (pkmn.status != :NONE)
    if battler
      if want_to_cure_status
        want_to_cure_status = @battlers[battler.index].wants_status_problem?(pkmn.status)
        want_to_cure_status = false if pkmn.status == :SLEEP && pkmn.statusCount <= 2
      end
      want_to_cure_status ||= (battler.effects[PBEffects::Confusion] > 1)
    end
    if HP_HEAL_ITEMS.include?(item)
      if pkmn.hp < pkmn.totalhp
        heal_amount = HP_HEAL_ITEMS[item]
        heal_amount = pkmn.totalhp / 4 if item == :SITURUSBERRY
        ret[:hp_heal] ||= []
        ret[:hp_heal].push([item, party_index, 5, heal_amount])
      end
    elsif FULL_RESTORE_ITEMS.include?(item)
      prefer_full_restore = (pkmn.hp <= pkmn.totalhp * 2 / 3 && want_to_cure_status)
      if pkmn.hp < pkmn.totalhp
        ret[:hp_heal] ||= []
        ret[:hp_heal].push([item, party_index, (prefer_full_restore) ? 3 : 7, 999])
      end
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, (prefer_full_restore) ? 3 : 9])
      end
    elsif ONE_STATUS_CURE_ITEMS.include?(item)
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, 5])
      end
    elsif ALL_STATUS_CURE_ITEMS.include?(item)
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, 7])
      end
    elsif ONE_STAT_RAISE_ITEMS.include?(item)
      stat_data = ONE_STAT_RAISE_ITEMS[item]
      if battler && stat_raise_worthwhile?(@battlers[battler.index], stat_data[0])
        ret[:stat_raise] ||= []
        ret[:stat_raise].push([item, party_index, battler.stages[stat_data[0]], stat_data[1]])
      end
    elsif ALL_STATS_RAISE_ITEMS.include?(item)
      if battler
        ret[:all_stats_raise] ||= []
        ret[:all_stats_raise].push([item, party_index])
      end
    elsif REVIVE_ITEMS.include?(item)
      ret[:revive] ||= []
      ret[:revive].push([item, party_index, REVIVE_ITEMS[item]])
    end
    return ret
  end
end
