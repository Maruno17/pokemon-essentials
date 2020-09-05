#===============================================================================
#
#===============================================================================
# Unused class.
class PokeBattle_NullBattlePeer
  def pbOnEnteringBattle(battle,pkmn,wild=false); end
  def pbOnLeavingBattle(battle,pkmn,usedInBattle,endBattle=false); end

  def pbStorePokemon(player,pkmn)
    player.party[player.party.length] = pkmn if player.party.length<6
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
    if player.party.length<6
      player.party[player.party.length] = pkmn
      return -1
    end
    pkmn.heal
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
    return pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    return nil
  end

  def pbCurrentBox
    return $PokemonStorage.currentBox
  end

  def pbBoxName(box)
    return (box<0) ? "" : $PokemonStorage[box].name
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
