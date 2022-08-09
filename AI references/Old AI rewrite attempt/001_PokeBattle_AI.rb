class PokeBattle_AI
  #=============================================================================
  #
  #=============================================================================
  # AI skill levels:
  #     0:     Wild Pokémon
  #     1-31:  Basic trainer (young/inexperienced)
  #     32-47: Some skill
  #     48-99: High skill
  #     100+:  Best trainers (Gym Leaders, Elite Four, Champion)
  # NOTE: A trainer's skill value can range from 0-255, but by default only four
  #       distinct skill levels exist. The skill value is typically the same as
  #       the trainer's base money value.
  module AILevel
    # Minimum skill level to be in each AI skill bracket.
    def self.minimum; return 1;   end
    def self.medium;  return 32;  end
    def self.high;    return 48;  end
    def self.best;    return 100; end
  end

  #=============================================================================
  #
  #=============================================================================
  def initialize(battle)
    @battle      = battle
    @skill       = 0
    @user        = nil
    @wildBattler = @battle.wildBattle?   # Whether AI is choosing for a wild Pokémon
    @roles       = [Array.new(@battle.pbParty(0).length) { |i| determine_roles(0, i) },
                    Array.new(@battle.pbParty(1).length) { |i| determine_roles(1, i) }]
  end

  def pbAIRandom(x); return rand(x); end

  def pbStdDev(choices)
    sum = 0
    n   = 0
    choices.each do |c|
      sum += c[1]
      n   += 1
    end
    return 0 if n<2
    mean = sum.to_f/n.to_f
    varianceTimesN = 0
    choices.each do |c|
      next if c[1]<=0
      deviation = c[1].to_f-mean
      varianceTimesN += deviation*deviation
    end
    # Using population standard deviation
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN/n)
  end

  # Decide whether the opponent should Mega Evolve their Pokémon
  def pbEnemyShouldMegaEvolve?
    if @battle.pbCanMegaEvolve?(@user.index)   # Simple "always should if possible"
      PBDebug.log("[AI] #{@user.pbThis} (#{@user.index}) will Mega Evolve")
      return true
    end
    return false
  end

  # Choose an action
  def pbDefaultChooseEnemyCommand(idxBattler)
    set_up(idxBattler)
    choices = pbGetMoveScores
    return if pbEnemyShouldUseItem?
    return if pbEnemyShouldWithdraw?
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
    pbChooseMove(choices)
  end

  # Set some class variables for the Pokémon whose action is being chosen
  def set_up(idxBattler)
    # TODO: Where relevant, pretend the user is Mega Evolved if it isn't but can
    #       be.
    @user        = @battle.battlers[idxBattler]
    @wildBattler = (@battle.wildBattle? && @user.opposes?)
    @skill       = 0
    if !@wildBattler
      @skill     = @battle.pbGetOwnerFromBattlerIndex(@user.index).skill || 0
      @skill     = AILevel.minimum if @skill < AILevel.minimum
    end
  end

  def skill_check(threshold)
    return @skill >= threshold
  end
end
