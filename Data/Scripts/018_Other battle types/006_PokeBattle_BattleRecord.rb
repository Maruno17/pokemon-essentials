#===============================================================================
#
#===============================================================================
module PokeBattle_RecordedBattleModule
  attr_reader :randomnums
  attr_reader :rounds

  module Commands
    Fight   = 0
    Bag     = 1
    Pokemon = 2
    Run     = 3
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
      for i in 0...trainer.length
        ret.push([trainer[i].trainertype,trainer[i].name.clone,trainer[i].id,trainer[i].badges.clone])
      end
      return ret
    else
      return [
         [trainer.trainertype,trainer.name.clone,trainer.id,trainer.badges.clone]
      ]
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
    @properties["endSpeeches"]     = (@endSpeeches) ? @endSpeeches.clone : ""
    @properties["endSpeechesWin"]  = (@endSpeechesWin) ? @endSpeechesWin.clone : ""
    @properties["weather"]         = @field.weather
    @properties["weatherDuration"] = @field.weatherDuration
    @properties["canRun"]          = @canRun
    @properties["switchStyle"]     = @switchStyle
    @properties["showAnims"]       = @showAnims
    @properties["items"]           = Marshal.dump(@items)
    @properties["environment"]     = @environment
    @properties["rules"]           = Marshal.dump(@rules)
    super
  end

  def pbDumpRecord
    return Marshal.dump([pbGetBattleType,@properties,@rounds,@randomnumbers,@switches])
  end

  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    ret = super
    @switches.push(ret)
    return ret
  end

  def pbRegisterMove(idxBattler,idxMove,showMessages=true)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::Fight,idxMove]
      return true
    end
    return false
  end

  def pbRegisterTarget(idxBattler,idxTarget)
    super
    @rounds[@roundindex][idxBattler][2] = idxTarget
  end

  def pbRun(idxBattler,duringBattle=false)
    ret = super
    @rounds[@roundindex][idxBattler] = [Commands::Run,@decision]
    return ret
  end

  def pbAutoChooseMove(idxBattler,showMessages=true)
    ret = super
    @rounds[@roundindex][idxBattler] = [Commands::Fight,-1]
    return ret
  end

  def pbRegisterSwitch(idxBattler,idxParty)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::Pokemon,idxParty]
      return true
    end
    return false
  end

  def pbRegisterItem(idxBattler,item,idxTarget=nil,idxMove=nil)
    if super
      @rounds[@roundindex][idxBattler] = [Commands::Bag,item,idxTarget,idxMove]
      return true
    end
    return false
  end

  def pbCommandPhase
    @roundindex += 1
    @rounds[@roundindex] = [[],[],[],[]]
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
module BattlePlayerHelper
  def self.pbGetOpponent(battle)
    return self.pbCreateTrainerInfo(battle[1]["opponent"])
  end

  def self.pbGetBattleBGM(battle)
    return self.pbGetTrainerBattleBGM(self.pbGetOpponent(battle))
  end

  def self.pbCreateTrainerInfo(trainer)
    return nil if !trainer
    if trainer.length>1
      ret = []
      ret[0]=PokeBattle_Trainer.new(trainer[0][1],trainer[0][0])
      ret[0].id     = trainer[0][2]
      ret[0].badges = trainer[0][3]
      ret[1] = PokeBattle_Trainer.new(trainer[1][1],trainer[1][0])
      ret[1].id     = trainer[1][2]
      ret[1].badges = trainer[1][3]
      return ret
    else
      ret = PokeBattle_Trainer.new(trainer[0][1],trainer[0][0])
      ret.id     = trainer[0][2]
      ret.badges = trainer[0][3]
      return ret
    end
  end
end



#===============================================================================
#
#===============================================================================
module PokeBattle_BattlePlayerModule
  module Commands
    Fight   = 0
    Bag     = 1
    Pokemon = 2
    Run     = 3
  end

  def initialize(scene,battle)
    @battletype  = battle[0]
    @properties  = battle[1]
    @rounds      = battle[2]
    @randomnums  = battle[3]
    @switches    = battle[4]
    @roundindex  = -1
    @randomindex = 0
    @switchindex = 0
    super(scene,
       Marshal.restore(StringInput.new(@properties["party1"])),
       Marshal.restore(StringInput.new(@properties["party2"])),
       BattlePlayerHelper.pbCreateTrainerInfo(@properties["player"]),
       BattlePlayerHelper.pbCreateTrainerInfo(@properties["opponent"])
    )
  end

  def pbStartBattle
    @party1starts          = @properties["party1starts"]
    @party2starts          = @properties["party2starts"]
    @internalBattle        = @properties["internalBattle"]
    @endSpeeches           = @properties["endSpeeches"]
    @endSpeechesWin        = @properties["endSpeechesWin"]
    @field.weather         = @properties["weather"]
    @field.weatherDuration = @properties["weatherDuration"]
    @canRun                = @properties["canRun"]
    @switchStyle           = @properties["switchStyle"]
    @showAnims             = @properties["showAnims"]
    @environment           = @properties["environment"]
    @items                 = Marshal.restore(StringInput.new(@properties["items"]))
    @rules                 = Marshal.restore(StringInput.new(@properties["rules"]))
    super
  end

  def pbSwitchInBetween(_idxBattler,_checkLaxOnly=false,_canCancel=false)
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

  def pbCommandPhaseCore
    @roundindex += 1
    for i in 0...4
      next if @rounds[@roundindex][i].length==0
      pbClearChoice(i)
      case @rounds[@roundindex][i][0]
      when Commands::Fight
        if @rounds[@roundindex][i][1]==-1
          pbAutoChooseMove(i,false)
        else
          pbRegisterMove(i,@rounds[@roundindex][i][1])
        end
        if @rounds[@roundindex][i][2]
          pbRegisterTarget(i,@rounds[@roundindex][i][2])
        end
      when Commands::Bag
        pbRegisterItem(i,@rounds[@roundindex][i][1],@rounds[@roundindex][i][2],@rounds[@roundindex][i][3])
      when Commands::Pokemon
        pbRegisterSwitch(i,@rounds[@roundindex][i][1])
      when Commands::Run
        @decision = @rounds[@roundindex][i][1]
      end
    end
  end
end



#===============================================================================
#
#===============================================================================
class PokeBattle_RecordedBattle < PokeBattle_Battle
  include PokeBattle_RecordedBattleModule

  def pbGetBattleType; return 0; end
end



class PokeBattle_RecordedBattlePalace < PokeBattle_BattlePalace
  include PokeBattle_RecordedBattleModule

  def pbGetBattleType; return 1; end
end



class PokeBattle_RecordedBattleArena < PokeBattle_BattleArena
  include PokeBattle_RecordedBattleModule

  def pbGetBattleType; return 2; end
end



class PokeBattle_BattlePlayer < PokeBattle_Battle
  include PokeBattle_BattlePlayerModule
end



class PokeBattle_BattlePalacePlayer < PokeBattle_BattlePalace
  include PokeBattle_BattlePlayerModule
end



class PokeBattle_BattleArenaPlayer < PokeBattle_BattleArena
  include PokeBattle_BattlePlayerModule
end
