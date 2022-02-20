#===============================================================================
# Success state
#===============================================================================
class Battle::SuccessState
  attr_accessor :typeMod
  attr_accessor :useState    # 0 - not used, 1 - failed, 2 - succeeded
  attr_accessor :protected
  attr_accessor :skill

  def initialize; clear; end

  def clear(full = true)
    @typeMod   = Effectiveness::NORMAL_EFFECTIVE
    @useState  = 0
    @protected = false
    @skill     = 0 if full
  end

  def updateSkill
    case @useState
    when 1
      @skill = -2 if !@protected
    when 2
      if Effectiveness.super_effective?(@typeMod)
        @skill = 2
      elsif Effectiveness.normal?(@typeMod)
        @skill = 1
      elsif Effectiveness.not_very_effective?(@typeMod)
        @skill = -1
      else   # Ineffective
        @skill = -2
      end
    end
    clear(false)
  end
end



#===============================================================================
#
#===============================================================================
class BattleArenaBattle < Battle
  def initialize(*arg)
    super
    @battlersChanged      = true
    @mind                 = [0, 0]
    @skill                = [0, 0]
    @starthp              = [0, 0]
    @count                = 0
    @partyindexes         = [0, 0]
    @battleAI.battleArena = true
  end

  def pbCanSwitchLax?(idxBattler, _idxParty, partyScene = nil)
    partyScene&.pbDisplay(_INTL("{1} can't be switched out!", @battlers[idxBattler].pbThis))
    return false
  end

  def pbEORSwitch(favorDraws = false)
    return if favorDraws && @decision == 5
    return if !favorDraws && @decision > 0
    pbJudge
    return if @decision > 0
    2.times do |side|
      next if !@battlers[side].fainted?
      next if @partyindexes[side] + 1 >= self.pbParty(side).length
      @partyindexes[side] += 1
      newpoke = @partyindexes[side]
      pbMessagesOnReplace(side, newpoke)
      pbReplace(side, newpoke)
      pbOnBattlerEnteringBattle(side)
    end
  end

  def pbOnAllBattlersEnteringBattle
    @battlersChanged = true
    2.times do |side|
      @mind[side]    = 0
      @skill[side]   = 0
      @starthp[side] = battlers[side].hp
    end
    @count           = 0
    return super
  end

  def pbRecordBattlerAsActive(battler)
    @battlersChanged = true
    2.times do |side|
      @mind[side]    = 0
      @skill[side]   = 0
      @starthp[side] = @battlers[side].hp
    end
    @count           = 0
    return super
  end

  def pbMindScore(move)
    if move.function == "ProtectUser" ||   # Detect/Protect
       move.function == "UserEnduresFaintingThisTurn" ||   # Endure
       move.function == "FlinchTargetFailsIfNotUserFirstTurn"   # Fake Out
      return -1
    end
    if move.function == "CounterPhysicalDamage" ||   # Counter
       move.function == "CounterSpecialDamage" ||   # Mirror Coat
       move.function == "MultiTurnAttackBideThenReturnDoubleDamage"   # Bide
      return 0
    end
    return 0 if move.statusMove?
    return 1
  end

  def pbCommandPhase
    if @battlersChanged
      @scene.pbBattleArenaBattlers(@battlers[0], @battlers[1])
      @battlersChanged = false
      @count = 0
    end
    super
    return if @decision != 0
    # Update mind rating (asserting that a move was chosen)
    # TODO: Actually done at Pokémon's turn
    2.times do |side|
      if @choices[side][2] && @choices[side][0] == :UseMove
        @mind[side] += pbMindScore(@choices[side][2])
      end
    end
  end

  def pbEndOfRoundPhase
    super
    return if @decision != 0
    # Update skill rating
    2.times do |side|
      @skill[side] += self.successStates[side].skill
    end
#    PBDebug.log("[Mind: #{@mind.inspect}, Skill: #{@skill.inspect}]")
    # Increment turn counter
    @count += 1
    return if @count < 3
    # Half all multi-turn moves
    @battlers[0].pbCancelMoves(true)
    @battlers[1].pbCancelMoves(true)
    # Calculate scores in each category
    ratings1 = [0, 0, 0]
    ratings2 = [0, 0, 0]
    if @mind[0] == @mind[1]
      ratings1[0] = 1
      ratings2[0] = 1
    elsif @mind[0] > @mind[1]
      ratings1[0] = 2
    else
      ratings2[0] = 2
    end
    if @skill[0] == @skill[1]
      ratings1[1] = 1
      ratings2[1] = 1
    elsif @skill[0] > @skill[1]
      ratings1[1] = 2
    else
      ratings2[1] = 2
    end
    body = [0, 0]
    body[0] = ((@battlers[0].hp * 100) / [@starthp[0], 1].max).floor
    body[1] = ((@battlers[1].hp * 100) / [@starthp[1], 1].max).floor
    if body[0] == body[1]
      ratings1[2] = 1
      ratings2[2] = 1
    elsif body[0] > body[1]
      ratings1[2] = 2
    else
      ratings2[2] = 2
    end
    # Show scores
    @scene.pbBattleArenaJudgment(@battlers[0], @battlers[1], ratings1.clone, ratings2.clone)
    # Calculate total scores
    points = [0, 0]
    ratings1.each { |val| points[0] += val }
    ratings2.each { |val| points[1] += val }
    # Make judgment
    if points[0] == points[1]
      pbDisplay(_INTL("{1} tied the opponent\n{2} in a referee's decision!",
                      @battlers[0].name, @battlers[1].name))
      # NOTE: Pokémon doesn't really lose HP, but the effect is mostly the
      #       same.
      @battlers[0].hp = 0
      @battlers[0].pbFaint(false)
      @battlers[1].hp = 0
      @battlers[1].pbFaint(false)
    elsif points[0] > points[1]
      pbDisplay(_INTL("{1} defeated the opponent\n{2} in a referee's decision!",
                      @battlers[0].name, @battlers[1].name))
      @battlers[1].hp = 0
      @battlers[1].pbFaint(false)
    else
      pbDisplay(_INTL("{1} lost to the opponent\n{2} in a referee's decision!",
                      @battlers[0].name, @battlers[1].name))
      @battlers[0].hp = 0
      @battlers[0].pbFaint(false)
    end
    pbGainExp
    pbEORSwitch
  end
end



#===============================================================================
#
#===============================================================================
class Battle::AI
  attr_accessor :battleArena

  unless method_defined?(:_battleArena_pbEnemyShouldWithdraw?)
    alias _battleArena_pbEnemyShouldWithdraw? pbEnemyShouldWithdraw?
  end

  def pbEnemyShouldWithdraw?(idxBattler)
    return _battleArena_pbEnemyShouldWithdraw?(idxBattler) if !@battleArena
    return false
  end
end



#===============================================================================
#
#===============================================================================
class Battle::Scene
  def pbBattleArenaUpdate
    pbGraphicsUpdate
  end

  def updateJudgment(window, phase, battler1, battler2, ratings1, ratings2)
    total1 = 0
    total2 = 0
    phase.times do |i|
      total1 += ratings1[i]
      total2 += ratings2[i]
    end
    window.contents.clear
    pbSetSystemFont(window.contents)
    textpos = [
      [battler1.name, 64, 6, 2, Color.new(248, 0, 0), Color.new(208, 208, 200)],
      [_INTL("VS"), 144, 6, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [battler2.name, 224, 6, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [_INTL("Mind"), 144, 54, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [_INTL("Skill"), 144, 86, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [_INTL("Body"), 144, 118, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [sprintf("%d", total1), 64, 166, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [_INTL("Judgment"), 144, 166, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)],
      [sprintf("%d", total2), 224, 166, 2, Color.new(72, 72, 72), Color.new(208, 208, 200)]
    ]
    pbDrawTextPositions(window.contents, textpos)
    images = []
    phase.times do |i|
      y = [48, 80, 112][i]
      x = (ratings1[i] == ratings2[i]) ? 64 : ((ratings1[i] > ratings2[i]) ? 0 : 32)
      images.push(["Graphics/Pictures/judgment", 64 - 16, y, x, 0, 32, 32])
      x = (ratings1[i] == ratings2[i]) ? 64 : ((ratings1[i] < ratings2[i]) ? 0 : 32)
      images.push(["Graphics/Pictures/judgment", 224 - 16, y, x, 0, 32, 32])
    end
    pbDrawImagePositions(window.contents, images)
    window.contents.fill_rect(16, 150, 256, 4, Color.new(80, 80, 80))
  end

  def pbBattleArenaBattlers(battler1, battler2)
    pbMessage(_INTL("REFEREE: {1} VS {2}!\nCommence battling!\\wtnp[20]",
                    battler1.name, battler2.name)) { pbBattleArenaUpdate }
  end

  def pbBattleArenaJudgment(battler1, battler2, ratings1, ratings2)
    msgwindow  = nil
    dimmingvp  = nil
    infowindow = nil
    begin
      msgwindow = pbCreateMessageWindow
      dimmingvp = Viewport.new(0, 0, Graphics.width, Graphics.height - msgwindow.height)
      pbMessageDisplay(msgwindow,
                       _INTL("REFEREE: That's it! We will now go to judging to determine the winner!\\wtnp[20]")) {
        pbBattleArenaUpdate
        dimmingvp.update
      }
      dimmingvp.z = 99999
      infowindow = SpriteWindow_Base.new(80, 0, 320, 224)
      infowindow.contents = Bitmap.new(infowindow.width - infowindow.borderX,
                                       infowindow.height - infowindow.borderY)
      infowindow.z        = 99999
      infowindow.visible  = false
      11.times do |i|
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        dimmingvp.color = Color.new(0, 0, 0, i * 128 / 10)
      end
      updateJudgment(infowindow, 0, battler1, battler2, ratings1, ratings2)
      infowindow.visible = true
      11.times do |i|
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        infowindow.update
      end
      updateJudgment(infowindow, 1, battler1, battler2, ratings1, ratings2)
      pbMessageDisplay(msgwindow,
                       _INTL("REFEREE: Judging category 1, Mind!\nThe Pokémon showing the most guts!\\wtnp[40]")) {
        pbBattleArenaUpdate
        dimmingvp.update
        infowindow.update
      }
      updateJudgment(infowindow, 2, battler1, battler2, ratings1, ratings2)
      pbMessageDisplay(msgwindow,
                       _INTL("REFEREE: Judging category 2, Skill!\nThe Pokémon using moves the best!\\wtnp[40]")) {
        pbBattleArenaUpdate
        dimmingvp.update
        infowindow.update
      }
      updateJudgment(infowindow, 3, battler1, battler2, ratings1, ratings2)
      pbMessageDisplay(msgwindow,
                       _INTL("REFEREE: Judging category 3, Body!\nThe Pokémon with the most vitality!\\wtnp[40]")) {
        pbBattleArenaUpdate
        dimmingvp.update
        infowindow.update
      }
      total1 = 0
      total2 = 0
      3.times do |i|
        total1 += ratings1[i]
        total2 += ratings2[i]
      end
      if total1 == total2
        pbMessageDisplay(msgwindow,
                         _INTL("REFEREE: Judgment: {1} to {2}!\nWe have a draw!\\wtnp[40]", total1, total2)) {
          pbBattleArenaUpdate
          dimmingvp.update
          infowindow.update
        }
      elsif total1 > total2
        pbMessageDisplay(msgwindow,
                         _INTL("REFEREE: Judgment: {1} to {2}!\nThe winner is {3}'s {4}!\\wtnp[40]",
                               total1, total2, @battle.pbGetOwnerName(battler1.index), battler1.name)) {
          pbBattleArenaUpdate
          dimmingvp.update
          infowindow.update
        }
      else
        pbMessageDisplay(msgwindow,
                         _INTL("REFEREE: Judgment: {1} to {2}!\nThe winner is {3}!\\wtnp[40]",
                               total1, total2, battler2.name)) {
          pbBattleArenaUpdate
          dimmingvp.update
          infowindow.update
        }
      end
      infowindow.visible = false
      msgwindow.visible  = false
      11.times do |i|
        pbGraphicsUpdate
        pbInputUpdate
        msgwindow.update
        dimmingvp.update
        dimmingvp.color = Color.new(0, 0, 0, (10 - i) * 128 / 10)
      end
    ensure
      pbDisposeMessageWindow(msgwindow)
      dimmingvp.dispose
      infowindow&.contents&.dispose
      infowindow&.dispose
    end
  end
end
