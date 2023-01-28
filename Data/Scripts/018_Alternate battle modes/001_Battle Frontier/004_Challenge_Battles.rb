#===============================================================================
#
#===============================================================================
class BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return Battle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattleTower < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return RecordedBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattlePalace < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return RecordedBattle::BattlePalaceBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
class BattleArena < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    return RecordedBattle::BattleArenaBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

#===============================================================================
#
#===============================================================================
def pbOrganizedBattleEx(opponent, challengedata)
  # Skip battle if holding Ctrl in Debug mode
  if Input.press?(Input::CTRL) && $DEBUG
    pbMessage(_INTL("SKIPPING BATTLE..."))
    pbMessage(_INTL("AFTER WINNING..."))
    pbMessage(opponent.lose_text || "...")
    $game_temp.last_battle_record = nil
    pbMEStop
    return true
  end
  $player.heal_party
  # Remember original data, to be restored after battle
  challengedata = PokemonChallengeRules.new if !challengedata
  oldlevels = challengedata.adjustLevels($player.party, opponent.party)
  olditems  = $player.party.transform { |p| p.item_id }
  olditems2 = opponent.party.transform { |p| p.item_id }
  # Create the battle scene (the visual side of it)
  scene = BattleCreationHelperMethods.create_battle_scene
  # Create the battle class (the mechanics side of it)
  battle = challengedata.createBattle(scene, $player, opponent)
  battle.internalBattle = false
  # Set various other properties in the battle class
  BattleCreationHelperMethods.prepare_battle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(opponent)) do
    pbSceneStandby { decision = battle.pbStartBattle }
  end
  Input.update
  # Restore both parties to their original levels
  challengedata.unadjustLevels($player.party, opponent.party, oldlevels)
  # Heal both parties and restore their original items
  $player.party.each_with_index do |pkmn, i|
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
  $game_temp.last_battle_record = nil
  if [1, 2, 5].include?(decision)   # if win, loss or draw
    $game_temp.last_battle_record = battle.pbDumpRecord
  end
  case decision
  when 1   # Won
    $stats.trainer_battles_won += 1
  when 2, 3, 5   # Lost, fled, draw
    $stats.trainer_battles_lost += 1
  end
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

#===============================================================================
# Methods that record and play back a battle.
#===============================================================================
def pbRecordLastBattle
  $PokemonGlobal.lastbattle = $game_temp.last_battle_record
  $game_temp.last_battle_record = nil
end

def pbPlayLastBattle
  pbPlayBattle($PokemonGlobal.lastbattle)
end

def pbPlayBattle(battledata)
  return if !battledata
  scene = BattleCreationHelperMethods.create_battle_scene
  scene.abortable = true
  lastbattle = Marshal.restore(battledata)
  case lastbattle[0]
  when BattleChallenge::BATTLE_TOWER_ID
    battleplayer = RecordedBattle::PlaybackBattle.new(scene, lastbattle)
  when BattleChallenge::BATTLE_PALACE_ID
    battleplayer = RecordedBattle::BattlePalacePlaybackBattle.new(scene, lastbattle)
  when BattleChallenge::BATTLE_ARENA_ID
    battleplayer = RecordedBattle::BattleArenaPlaybackBattle.new(scene, lastbattle)
  end
  bgm = RecordedBattle::PlaybackHelper.pbGetBattleBGM(lastbattle)
  pbBattleAnimation(bgm) do
    pbSceneStandby { battleplayer.pbStartBattle }
  end
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
  pbPlayBattleFromFile(sprintf("Battles/Battle%03d.dat", num)) if num >= 0
end

def pbPlayBattleFromFile(filename)
  pbRgssOpen(filename, "rb") { |f| pbPlayBattle(f.read) }
end
