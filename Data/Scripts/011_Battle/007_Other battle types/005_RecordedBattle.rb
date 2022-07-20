#===============================================================================
#
#===============================================================================
module RecordedBattleModule
  attr_reader :randomnums
  attr_reader :rounds

  module Commands
    FIGHT   = 0
    BAG     = 1
    POKEMON = 2
    RUN     = 3
  end

  def initialize(*arg)
    @randomnumbers = []
    @rounds        = []
    @switches      = []
    @roundindex    = -1
    @properties    = {}
    super(*arg)
  end

  def pbGetBattleType
    return 0   # Battle Tower
  end

  def pbGetTrainerInfo(trainer)
    return nil if !trainer
    if trainer.is_a?(Array)
      ret = []
      trainer.each do |tr|
        if tr.is_a?(Player)
          ret.push([tr.trainer_type, tr.name.clone, tr.id, tr.badges.clone])
        else   # NPCTrainer
          ret.push([tr.trainer_type, tr.name.clone, tr.id, tr.lose_text || "...", tr.win_text || "..."])
        end
      end
      return ret
    elsif trainer[i].is_a?(Player)
      return [[trainer.trainer_type, trainer.name.clone, trainer.id, trainer.badges.clone]]
    else
      return [[trainer.trainer_type, trainer.name.clone, trainer.id, trainer.lose_text || "...", trainer.win_text || "..."]]
    end
  end

  def pbStartBattle
    @properties = {}
    @properties["internalBattle"]  = @internalBattle
    @properties["player"]          = pbGetTrainerInfo(@player)
    @properties["opponent"]        = pbGetTrainerInfo(@opponent)
    @properties["party1"]          = Marshal.dump(@party1)
    @properties["party2"]          = Marshal.dump(@party2)
    @properties["party1starts"]    = Marshal.dump(@party1starts)
    @properties["party2starts"]    = Marshal.dump(@party2starts)
    @properties["weather"]         = @field.weather
    @properties["weatherDuration"] = @field.weatherDuration
    @properties["canRun"]          = @canRun
    @properties["switchStyle"]     = @switchStyle
    @properties["showAnims"]       = @showAnims
    @properties["items"]           = Marshal.dump(@items)
    @properties["backdrop"]        = @backdrop
    @properties["backdropBase"]    = @backdropBase
    @properties["time"]            = @time
    @properties["environment"]     = @environment
    @properties["rules"]           = Marshal.dump(@rules)
    super
  end

  def pbDumpRecord
    return Marshal.dump([pbGetBattleType, @properties, @rounds, @randomnumbers, @switches])
  end

  def pbSwitchInBetween(idxBattler, checkLaxOnly = false, canCancel = false)
    ret = super
    @switches.push(ret)
    return ret
  end

  def pbRegisterMove(idxBattler, idxMove, showMessages = true)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::FIGHT, idxMove]
      return true
    end
    return false
  end

  def pbRegisterTarget(idxBattler, idxTarget)
    super
    @rounds[@roundindex][idxBattler][2] = idxTarget
  end

  def pbRun(idxBattler, duringBattle = false)
    ret = super
    @rounds[@roundindex][idxBattler] = [Commands::RUN, @decision]
    return ret
  end

  def pbAutoChooseMove(idxBattler, showMessages = true)
    ret = super
    @rounds[@roundindex][idxBattler] = [Commands::FIGHT, -1]
    return ret
  end

  def pbRegisterSwitch(idxBattler, idxParty)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::POKEMON, idxParty]
      return true
    end
    return false
  end

  def pbRegisterItem(idxBattler, item, idxTarget = nil, idxMove = nil)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::BAG, item, idxTarget, idxMove]
      return true
    end
    return false
  end

  def pbCommandPhase
    @roundindex += 1
    @rounds[@roundindex] = [[], [], [], []]
    super
  end

  def pbStorePokemon(pkmn); end

  def pbRandom(num)
    ret = super(num)
    @randomnumbers.push(ret)
    return ret
  end
end

#===============================================================================
#
#===============================================================================
module RecordedBattlePlaybackModule
  module Commands
    FIGHT   = 0
    BAG     = 1
    POKEMON = 2
    RUN     = 3
  end

  def initialize(scene, battle)
    @battletype  = battle[0]
    @properties  = battle[1]
    @rounds      = battle[2]
    @randomnums  = battle[3]
    @switches    = battle[4]
    @roundindex  = -1
    @randomindex = 0
    @switchindex = 0
    super(scene,
       Marshal.restore(@properties["party1"]),
       Marshal.restore(@properties["party2"]),
       RecordedBattle::PlaybackHelper.pbCreateTrainerInfo(@properties["player"]),
       RecordedBattle::PlaybackHelper.pbCreateTrainerInfo(@properties["opponent"])
    )
  end

  def pbStartBattle
    @party1starts          = Marshal.restore(@properties["party1starts"])
    @party2starts          = Marshal.restore(@properties["party2starts"])
    @internalBattle        = @properties["internalBattle"]
    @field.weather         = @properties["weather"]
    @field.weatherDuration = @properties["weatherDuration"]
    @canRun                = @properties["canRun"]
    @switchStyle           = @properties["switchStyle"]
    @showAnims             = @properties["showAnims"]
    @backdrop              = @properties["backdrop"]
    @backdropBase          = @properties["backdropBase"]
    @time                  = @properties["time"]
    @environment           = @properties["environment"]
    @items                 = Marshal.restore(@properties["items"])
    @rules                 = Marshal.restore(@properties["rules"])
    super
  end

  def pbSwitchInBetween(_idxBattler, _checkLaxOnly = false, _canCancel = false)
    ret = @switches[@switchindex]
    @switchindex += 1
    return ret
  end

  def pbRandom(_num)
    ret = @randomnums[@randomindex]
    @randomindex += 1
    return ret
  end

  def pbDisplayPaused(str)
    pbDisplay(str)
  end

  def pbCommandPhaseLoop(isPlayer)
    return if !isPlayer
    @roundindex += 1
    4.times do |i|
      next if @rounds[@roundindex][i].length == 0
      pbClearChoice(i)
      case @rounds[@roundindex][i][0]
      when Commands::FIGHT
        if @rounds[@roundindex][i][1] == -1
          pbAutoChooseMove(i, false)
        else
          pbRegisterMove(i, @rounds[@roundindex][i][1])
        end
        if @rounds[@roundindex][i][2]
          pbRegisterTarget(i, @rounds[@roundindex][i][2])
        end
      when Commands::BAG
        pbRegisterItem(i, @rounds[@roundindex][i][1], @rounds[@roundindex][i][2], @rounds[@roundindex][i][3])
      when Commands::POKEMON
        pbRegisterSwitch(i, @rounds[@roundindex][i][1])
      when Commands::RUN
        @decision = @rounds[@roundindex][i][1]
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class RecordedBattle < Battle
  include RecordedBattleModule

  def pbGetBattleType; return 0; end
end

class RecordedBattle::BattlePalaceBattle < BattlePalaceBattle
  include RecordedBattleModule

  def pbGetBattleType; return 1; end
end

class RecordedBattle::BattleArenaBattle < BattleArenaBattle
  include RecordedBattleModule

  def pbGetBattleType; return 2; end
end

class RecordedBattle::PlaybackBattle < Battle
  include RecordedBattlePlaybackModule
end

class RecordedBattle::BattlePalacePlaybackBattle < BattlePalaceBattle
  include RecordedBattlePlaybackModule
end

class RecordedBattle::BattleArenaPlaybackBattle < BattleArenaBattle
  include RecordedBattlePlaybackModule
end

#===============================================================================
#
#===============================================================================
module RecordedBattle::PlaybackHelper
  def self.pbGetOpponent(battle)
    return self.pbCreateTrainerInfo(battle[1]["opponent"])
  end

  def self.pbGetBattleBGM(battle)
    return self.pbGetTrainerBattleBGM(self.pbGetOpponent(battle))
  end

  def self.pbCreateTrainerInfo(trainer)
    return nil if !trainer
    ret = []
    trainer.each do |tr|
      if tr.length == 4   # Player
        t = Player.new(tr[1], tr[0])
        t.badges = tr[3]
      else   # NPCTrainer
        t = NPCTrainer.new(tr[1], tr[0])
        t.lose_text = tr[3] || "..."
        t.win_text = tr[4] || "..."
      end
      t.id = tr[2]
      ret.push(t)
    end
    return ret
  end
end
