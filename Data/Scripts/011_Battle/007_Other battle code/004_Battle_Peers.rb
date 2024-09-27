#===============================================================================
#
#===============================================================================
class Battle::Peer
  def pbStorePokemon(player, pkmn)
    if !player.party_full?
      player.party[player.party.length] = pkmn
      return -1
    end
    if Settings::HEAL_STORED_POKEMON
      old_ready_evo = pkmn.ready_to_evolve
      pkmn.heal
      pkmn.ready_to_evolve = old_ready_evo
    end
    oldCurBox = pbCurrentBox
    storedBox = $PokemonStorage.pbStoreCaught(pkmn)
    if storedBox < 0
      # NOTE: Poké Balls can't be used if storage is full, so you shouldn't ever
      #       see this message.
      pbDisplayPaused(_INTL("Can't catch any more..."))
      return oldCurBox
    end
    return storedBox
  end

  def pbGetStorageCreatorName
    return UI::PC.pbGetStorageCreator if $player.seen_storage_creator
    return nil
  end

  def pbCurrentBox
    return $PokemonStorage.currentBox
  end

  def pbBoxName(box)
    return (box < 0) ? "" : $PokemonStorage[box].name
  end

  def pbOnStartingBattle(battle, pkmn, wild = false)
    f = MultipleForms.call("getFormOnStartingBattle", pkmn, wild)
    pkmn.form = f if f
    MultipleForms.call("changePokemonOnStartingBattle", pkmn, battle)
  end

  def pbOnEnteringBattle(battle, battler, pkmn, wild = false)
    f = MultipleForms.call("getFormOnEnteringBattle", pkmn, wild)
    pkmn.form = f if f
    battler.form = pkmn.form if battler.form != pkmn.form
    MultipleForms.call("changePokemonOnEnteringBattle", battler, pkmn, battle)
  end

  # For switching out, including due to fainting, and for the end of battle
  def pbOnLeavingBattle(battle, pkmn, usedInBattle, endBattle = false)
    return if !pkmn
    f = MultipleForms.call("getFormOnLeavingBattle", pkmn, battle, usedInBattle, endBattle)
    pkmn.form = f if f && pkmn.form != f
    pkmn.hp = pkmn.totalhp if pkmn.hp > pkmn.totalhp
    MultipleForms.call("changePokemonOnLeavingBattle", pkmn, battle, usedInBattle, endBattle)
  end
end

#===============================================================================
# Unused class.
#===============================================================================
class Battle::NullPeer
  def pbOnEnteringBattle(battle, battler, pkmn, wild = false); end
  def pbOnLeavingBattle(battle, pkmn, usedInBattle, endBattle = false); end

  def pbStorePokemon(player, pkmn)
    player.party[player.party.length] = pkmn if !player.party_full?
    return -1
  end

  def pbGetStorageCreatorName; return nil; end
  def pbCurrentBox;            return -1;  end
  def pbBoxName(box);          return "";  end
end
