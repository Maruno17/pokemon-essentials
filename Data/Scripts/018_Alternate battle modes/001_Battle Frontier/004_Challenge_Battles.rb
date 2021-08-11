#===============================================================================
#
#===============================================================================
class BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return PokeBattle_Battle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattleTower < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return PokeBattle_RecordedBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattlePalace < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return PokeBattle_RecordedBattlePalace.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattleArena < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return PokeBattle_RecordedBattleArena.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
def pbOrganizedBattleEx(opponent, challengedata, endspeech, endspeechwin)
  # Skip battle if holding Ctrl in Debug mode
  if Input.press?(Input::CTRL) && $DEBUG
    pbMessage(_INTL("SKIPPING BATTLE..."))
    pbMessage(_INTL("AFTER WINNING..."))
    pbMessage(endspeech || "...")
    $PokemonTemp.lastbattle = nil
    pbMEStop
    return true
  end
  $Trainer.heal_party
  # Remember original data, to be restored after battle
  challengedata = PokemonChallengeRules.new if !challengedata
  oldlevels = challengedata.adjustLevels($Trainer.party, opponent.party)
  olditems  = $Trainer.party.transform { |p| p.item_id }
  olditems2 = opponent.party.transform { |p| p.item_id }
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = challengedata.createBattle(scene, $Trainer, opponent)
  battle.internalBattle = false
  battle.endSpeeches    = [endspeech]
  battle.endSpeechesWin = [endspeechwin]
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(opponent)) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
  }
  Input.update
  # Restore both parties to their original levels
  challengedata.unadjustLevels($Trainer.party, opponent.party, oldlevels)
  # Heal both parties and restore their original items
  $Trainer.party.each_with_index do |pkmn, i|
    pkmn.heal
    pkmn.makeUnmega
    pkmn.makeUnprimal
    pkmn.item = olditems[i]
  end
  opponent.party.each_with_index do |pkmn, i|
    pkmn.heal
    pkmn.makeUnmega
    pkmn.makeUnprimal
    pkmn.item = olditems2[i]
  end
  # Save the record of the battle
  $PokemonTemp.lastbattle = nil
  if decision == 1 || decision == 2 || decision == 5   # if win, loss or draw
    $PokemonTemp.lastbattle = battle.pbDumpRecord
  end
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

#===============================================================================
# Methods that record and play back a battle.
#===============================================================================
def pbRecordLastBattle
  $PokemonGlobal.lastbattle = $PokemonTemp.lastbattle
  $PokemonTemp.lastbattle   = nil
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattle(battledata)
  return if !battledata
  scene = pbNewBattleScene
  scene.abortable = true
  lastbattle = Marshal.restore(battledata)
  case lastbattle[0]
  when BattleChallenge::BattleTowerID
    battleplayer = PokeBattle_BattlePlayer.new(scene, lastbattle)
  when BattleChallenge::BattlePalaceID
    battleplayer = PokeBattle_BattlePalacePlayer.new(scene, lastbattle)
  when BattleChallenge::BattleArenaID
    battleplayer = PokeBattle_BattleArenaPlayer.new(scene, lastbattle)
  end
  bgm = BattlePlayerHelper.pbGetBattleBGM(lastbattle)
  pbBattleAnimation(bgm) {
    pbSceneStandby {
      battleplayer.pbStartBattle
    }
  }
end

#===============================================================================
# Debug playback methods.
#===============================================================================
def pbDebugPlayBattle
  params = ChooseNumberParams.new
  params.setRange(0, 500)
  params.setInitialValue(0)
  params.setCancelValue(-1)
  num = pbMessageChooseNumber(_INTL("Choose a battle."), params)
  if num >= 0
    pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat", num))
  end
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename, "rb") { |f| pbPlayBattle(f.read) }
end
