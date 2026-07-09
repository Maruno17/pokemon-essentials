#===============================================================================
# Used when generating new trainers for battle challenges.
#===============================================================================
class Battle::DebugSceneNoVisuals
  def initialize(log_messages = false)
    @battle       = nil
    @lastCmd      = [0, 0, 0, 0]
    @lastMove     = [0, 0, 0, 0]
    @log_messages = log_messages
  end

  # Called whenever the battle begins.
  def pbStartBattle(battle)
    @battle   = battle
    @lastCmd  = [0, 0, 0, 0]
    @lastMove = [0, 0, 0, 0]
  end

  def pbBlitz(keys)
    return rand(30)
  end

  # Called whenever a new round begins.
  def pbBeginCommandPhase; end
  def pbBeginAttackPhase; end
  def pbBeginEndOfRoundPhase; end
  def pbShowOpponent(idxTrainer); end
  def pbDamageAnimation(battler, effectiveness = 0); end
  def pbCommonAnimation(animName, user = nil, target = nil); end
  def pbAnimation(moveID, user, targets, hitNum = 0); end
  def pbHitAndHPLossAnimation(targets); end
  def pbShowPartyLineup(side, fullAnim = false); end
  def pbShowAbilitySplash(battler, delay = false, logTrigger = true); end
  def pbReplaceAbilitySplash(battler); end
  def pbHideAbilitySplash(battler); end
  def pbEndBattle(result); end
  def pbWildBattleSuccess; end
  def pbTrainerBattleSuccess; end
  def pbBattleArenaJudgment(b1, b2, r1, r2); end
  def pbBattleArenaBattlers(b1, b2); end

  def pbUpdate(cw = nil); end
  def pbRefresh; end
  def pbRefreshOne(idxBattler); end

  def pbDisplayMessage(msg, brief = false)
    PBDebug.log_message(msg) if @log_messages
  end
  alias pbDisplay pbDisplayMessage

  def pbDisplayPausedMessage(msg)
    PBDebug.log_message(msg) if @log_messages
  end

  def pbDisplayConfirmMessage(msg)
    PBDebug.log_message(msg) if @log_messages
    return true
  end

  def pbShowCommands(msg, commands, defaultValue)
    PBDebug.log_message(msg) if @log_messages
    return 0
  end

  def pbSendOutBattlers(sendOuts, startBattle = false); end
  def pbRecall(idxBattler); end
  def pbItemMenu(idxBattler, firstAction); return -1; end
  def pbResetCommandsIndex(idxBattler); end

  def pbHPChanged(battler, oldHP, showAnim = false); end
  def pbChangePokemon(idxBattler, pkmn); end
  def pbFaintBattler(battler); end
  def pbEXPBar(battler, startExp, endExp, tempExp1, tempExp2); end
  def pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense, oldSpAtk, oldSpDef, oldSpeed); end
  def pbForgetMove(pkmn, moveToLearn); return 0; end   # Always forget first move

  def pbCommandMenu(idxBattler, firstAction)
    return 1 if rand(15) == 0   # Bag
    return 4 if rand(10) == 0   # Call
    return 0                    # Fight
  end

  def pbFightMenu(idxBattler, megaEvoPossible = false)
    battler = @battle.battlers[idxBattler]
    50.times do
      break if yield rand(battler.move.length)
    end
  end

  def pbChooseTarget(idxBattler, target_data, visibleSprites = nil)
    targets = @battle.allOtherSideBattlers(idxBattler).map { |b| b.index }
    return -1 if targets.length == 0
    return targets.sample
  end

  def pbPartyScreen(idxBattler, canCancel = false)
    replacements = []
    @battle.eachInTeamFromBattlerIndex(idxBattler) do |_b, idxParty|
      replacements.push(idxParty) if !@battle.pbFindBattler(idxParty, idxBattler)
    end
    return if replacements.length == 0
    50.times do
      break if yield replacements[rand(replacements.length)], self
    end
  end
end
