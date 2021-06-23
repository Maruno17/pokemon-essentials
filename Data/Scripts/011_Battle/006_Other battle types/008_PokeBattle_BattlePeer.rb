#===============================================================================
#
#===============================================================================
# Unused class.
class PokeBattle_NullBattlePeer
  def pbOnEnteringBattle(battle,pkmn,wild=false); end
  def pbOnLeavingBattle(battle,pkmn,usedInBattle,endBattle=false); end

  def pbStorePokemon(player,pkmn)
    player.party[player.party.length] = pkmn if !player.party_full?
    return -1
  end

  def pbGetStorageCreatorName; return nil; end
  def pbCurrentBox;            return -1;  end
  def pbBoxName(box);          return "";  end
end



#===============================================================================
#
#===============================================================================
class PokeBattle_RealBattlePeer
  def pbStorePokemon(player,pkmn)
    if !player.party_full?
      player.party[player.party.length] = pkmn
      return -1
    end
    pkmn.heal if Settings::HEAL_STORED_POKEMON
    oldCurBox = pbCurrentBox
    storedBox = $PokemonStorage.pbStoreCaught(pkmn)
    if storedBox<0
      # NOTE: Poké Balls can't be used if storage is full, so you shouldn't ever
      #       see this message.
      pbDisplayPaused(_INTL("Can't catch any more..."))
      return oldCurBox
    end
    return storedBox
  end

  def pbGetStorageCreatorName
    return pbGetStorageCreator if $Trainer.seen_storage_creator
    return nil
  end

  def pbCurrentBox
    return $PokemonStorage.currentBox
  end

  def pbBoxName(box)
    return (box<0) ? "" : $PokemonStorage[box].name
  end

  def pbOnEnteringBattle(_battle,pkmn,wild=false)
    f = MultipleForms.call("getFormOnEnteringBattle",pkmn,wild)
    pkmn.form = f if f
  end

  # For switching out, including due to fainting, and for the end of battle
  def pbOnLeavingBattle(battle,pkmn,usedInBattle,endBattle=false)
    return if !pkmn
    f = MultipleForms.call("getFormOnLeavingBattle",pkmn,battle,usedInBattle,endBattle)
    pkmn.form = f if f && pkmn.form!=f
    pkmn.hp = pkmn.totalhp if pkmn.hp>pkmn.totalhp
  end
end



#===============================================================================
#
#===============================================================================
class PokeBattle_BattlePeer
  def self.create
    return PokeBattle_RealBattlePeer.new
  end
end
