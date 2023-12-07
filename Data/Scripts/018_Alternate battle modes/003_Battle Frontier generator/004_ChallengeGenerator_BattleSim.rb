#===============================================================================
#
#===============================================================================
class RuledTeam
  attr_accessor :team

  def initialize(party, rule)
    count = rule.ruleset.suggestedNumber
    @team = []
    retnum = []
    loop do
      count.times do |i|
        retnum[i] = rand(party.length)
        @team[i] = party[retnum[i]]
        party.delete_at(retnum[i])
      end
      break if rule.ruleset.isValid?(@team)
    end
    @totalGames = 0
    @rating = PlayerRating.new
    @history = MatchHistory.new(@rating)
  end

  def [](i)
    @team[i]
  end

  def length
    return @team.length
  end

  def rating
    @rating.winChancePercent
  end

  def ratingData
    @rating
  end

  def ratingRaw
    [@rating.rating, @rating.deviation, @rating.volatility, @rating.winChancePercent]
  end

  def compare(other)
    @rating.compare(other.ratingData)
  end

  def totalGames
    (@totalGames || 0) + self.games
  end

  def addMatch(other, score)
    @history.addMatch(other.ratingData, score)
  end

  def games
    @history.length
  end

  def updateRating
    @totalGames = 0 if !@totalGames
    oldgames = self.games
    @history.updateAndClear
    newgames = self.games
    @totalGames += (oldgames - newgames)
  end

  def toStr
    return "[" + @rating.to_i.to_s + "," + @games.to_i.to_s + "]"
  end

  def load(party)
    ret = []
    team.length.times do |i|
      ret.push(party[team[i]])
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class SingleMatch
  attr_reader :opponentRating
  attr_reader :opponentDeviation
  attr_reader :score
  attr_reader :kValue

  def initialize(opponentRating, opponentDev, score, kValue = 16)
    @opponentRating    = opponentRating
    @opponentDeviation = opponentDev
    @score             = score   # -1=draw, 0=lose, 1=win
    @kValue            = kValue
  end
end

#===============================================================================
#
#===============================================================================
class MatchHistory
  include Enumerable

  def initialize(thisPlayer)
    @matches    = []
    @thisPlayer = thisPlayer
  end

  def [](i)
    @matches[i]
  end

  def length
    @matches.length
  end

  def each
    @matches.each { |item| yield item }
  end

  def addMatch(otherPlayer, result)
    # 1=I won; 0=Other player won; -1: Draw
    @matches.push(SingleMatch.new(otherPlayer.rating, otherPlayer.deviation, result))
  end

  def updateAndClear
    @thisPlayer.update(@matches)
    @matches.clear
  end
end

#===============================================================================
#
#===============================================================================
class PlayerRatingElo
  attr_reader :rating

  K_VALUE = 16

  def initialize
    @rating          = 1600.0
    @deviation       = 0
    @volatility      = 0
    @estimatedRating = nil
  end

  def winChancePercent
    return @estimatedRating if @estimatedRating
    x = (1 + (10.0**((@rating - 1600.0) / 400.0)))
    @estimatedRating = (x == 0 ? 1.0 : 1.0 / x)
    return @estimatedRating
  end

  def update(matches)
    return if matches.length == 0
    stake = 0
    matches.length.times do
      score = (match.score == -1) ? 0.5 : match.score
      e = (1 + (10.0**((@rating - match.opponentRating) / 400.0)))
      stake += match.kValue * (score - e)
    end
    @rating += stake
  end
end

#===============================================================================
#
#===============================================================================
class PlayerRating
  attr_reader :volatility
  attr_reader :deviation
  attr_reader :rating

  def initialize
    @rating          = 1500.0
    @deviation       = 350.0
    @volatility      = 0.9
    @estimatedRating = nil
  end

  def winChancePercent
    return @estimatedRating if @estimatedRating
    if @deviation > 100
      # https://www.smogon.com/forums/threads/make-sense-of-your-shoddy-battle-rating.55764/
      otherRating = 1500.0
      otherDeviation = 350.0
      s = Math.sqrt(100_000.0 + (@deviation * @deviation) + (otherDeviation * otherDeviation))
      g = 10.0**((otherRating - @rating) * 0.79 / s)
      @estimatedRating = (1.0 / (1.0 + g)) * 100.0   # Percent chance that I win against opponent
    else
      # GLIXARE method
      rds = @deviation * @deviation
      sqr = Math.sqrt(15.905694331435 * (rds + 221_781.21786254))
      inner = (1500.0 - @rating) * Math::PI / sqr
      @estimatedRating = ((10_000.0 / (1.0 + (10.0**inner))) + 0.5) / 100.0
    end
    return @estimatedRating
  end

  def update(matches, system = 1.2)
    volatility = volatility2
    deviation = deviation2
    rating = rating2
    if matches.length == 0
      setDeviation2(Math.sqrt((deviation * deviation) + (volatility * volatility)))
      return
    end
    g = []
    e = []
    score = []
    matches.length.times do |i|
      match = matches[i]
      g[i] = getGFactor(match.opponentDeviation)
      e[i] = getEFactor(rating, match.opponentRating, g[i])
      score[i] = match.score
    end
    # Estimated variance
    variance = 0.0
    matches.length.times do |i|
      variance += g[i] * g[i] * e[i] * (1 - e[i])
    end
    variance = 1.0 / variance
    # Improvement sum
    sum = 0.0
    matches.length.times do |i|
      v = score[i]
      sum += g[i] * (v.to_f - e[i]) if v != -1
    end
    volatility = getUpdatedVolatility(volatility, deviation, variance, sum, system)
    # Update deviation
    t = (deviation * deviation) + (volatility * volatility)
    deviation = 1.0 / Math.sqrt((1.0 / t) + (1.0 / variance))
    # Update rating
    rating += deviation * deviation * sum
    setRating2(rating)
    setDeviation2(deviation)
    setVolatility2(volatility)
  end

  #-----------------------------------------------------------------------------

  private

  attr_writer :volatility

  alias volatility2 volatility

  def rating2
    return (@rating - 1500.0) / 173.7178
  end

  def deviation2
    return @deviation / 173.7178
  end

  def getGFactor(deviation)
    # deviation is not yet in glicko2
    deviation /= 173.7178
    return 1.0 / Math.sqrt(1.0 + ((3.0 * deviation * deviation) / (Math::PI * Math::PI)))
  end

  def getEFactor(rating, opponentRating, g)
    # rating is already in glicko2
    # opponentRating is not yet in glicko2
    opponentRating = (opponentRating - 1500.0) / 173.7178
    return 1.0 / (1.0 + Math.exp(-g * (rating - opponentRating)))
  end

  def setVolatility2(value)
    @volatility = value
  end

  def setRating2(value)
    @estimatedRating = nil
    @rating = (value * 173.7178) + 1500.0
  end

  def setDeviation2(value)
    @estimatedRating = nil
    @deviation = value * 173.7178
  end

  def getUpdatedVolatility(volatility, deviation, variance, improvementSum, system)
    improvement = improvementSum * variance
    a = Math.log(volatility * volatility)
    squSystem = system * system
    squDeviation = deviation * deviation
    squVariance = variance + variance
    squDevplusVar = squDeviation + variance
    x0 = a
    100.times do   # Up to 100 iterations to avoid potentially infinite loops
      e = Math.exp(x0)
      d = squDevplusVar + e
      squD = d * d
      i = improvement / d
      h1 = (-(x0 - a) / squSystem) - (0.5 * e * i * i)
      h2 = (-1.0 / squSystem) - (0.5 * e * squDevplusVar / squD)
      h2 += 0.5 * squVariance * e * (squDevplusVar - e) / (squD * d)
      x1 = x0
      x0 -= h1 / h2
      break if (x1 - x0).abs < 0.000001
    end
    return Math.exp(x0 / 2.0)
  end
end

#===============================================================================
#
#===============================================================================
def pbDecideWinnerEffectiveness(move, otype1, otype2, ability, scores)
  data = GameData::Move.get(move)
  return 0 if data.power == 0
  atype = data.type
  typemod = 1.0
  if ability != :LEVITATE || data.type != :GROUND
    mod1 = Effectiveness.calculate(atype, otype1)
    mod2 = (otype1 == otype2) ? 1.0 : Effectiveness.calculate(atype, otype2)
    if ability == :WONDERGUARD
      mod1 = 1.0 if !Effectiveness.super_effective?(mod1)
      mod2 = 1.0 if !Effectiveness.super_effective?(mod2)
    end
    typemod = mod1 * mod2
  end
  typemod *= 4   # Because dealing with 2 types
  return scores[0] if typemod == 0    # Ineffective
  return scores[1] if typemod == 1    # Doubly not very effective
  return scores[2] if typemod == 2    # Not very effective
  return scores[3] if typemod == 4    # Normal effective
  return scores[4] if typemod == 8    # Super effective
  return scores[5] if typemod == 16   # Doubly super effective
  return 0
end

def pbDecideWinnerScore(party0, party1, rating)
  score = 0
  types1 = []
  types2 = []
  abilities = []
  party1.length.times do |j|
    types1.push(party1[j].types[0])
    types2.push(party1[j].types[1] || party1[j].types[0])
    abilities.push(party1[j].ability_id)
  end
  party0.length.times do |i|
    party0[i].moves.each do |move|
      next if !move
      party1.length.times do |j|
        score += pbDecideWinnerEffectiveness(
          move.id, types1[j], types2[j], abilities[j], [-16, -8, 0, 4, 12, 20]
        )
      end
    end
    basestatsum = baseStatTotal(party0[i].species)
    score += basestatsum / 10
    score += 10 if party0[i].item   # Not in Battle Dome ranking
  end
  score += rating + rand(32)
  return score
end

def pbDecideWinner(party0, party1, rating0, rating1)
  rating0 = (rating0 * 15.0 / 100).round
  rating1 = (rating1 * 15.0 / 100).round
  score0 = pbDecideWinnerScore(party0, party1, rating0)
  score1 = pbDecideWinnerScore(party1, party0, rating1)
  if score0 == score1
    return 5 if rating0 == rating1
    return (rating0 > rating1) ? 1 : 2
  else
    return (score0 > score1) ? 1 : 2
  end
end

#===============================================================================
#
#===============================================================================
def pbRuledBattle(team1, team2, rule)
  decision = 0
  if rand(100) == 0
    level = rule.ruleset.suggestedLevel
    t_type = GameData::TrainerType.keys.first
    trainer1 = NPCTrainer.new("PLAYER1", t_type)
    trainer2 = NPCTrainer.new("PLAYER2", t_type)
    items1 = []
    items2 = []
    team1.team.each_with_index do |p, i|
      next if !p
      if p.level != level
        p.level = level
        p.calc_stats
      end
      items1[i] = p.item_id
      trainer1.party.push(p)
    end
    team2.team.each_with_index do |p, i|
      next if !p
      if p.level != level
        p.level = level
        p.calc_stats
      end
      items2[i] = p.item_id
      trainer2.party.push(p)
    end
    scene = Battle::DebugSceneNoVisuals.new
    battle = rule.createBattle(scene, trainer1, trainer2)
    battle.debug = true
    battle.controlPlayer = true
    battle.internalBattle = false
    decision = battle.pbStartBattle
    team1.team.each_with_index do |p, i|
      next if !p
      p.heal
      p.item = items1[i]
    end
    team2.team.each_with_index do |p, i|
      next if !p
      p.heal
      p.item = items2[i]
    end
  else
    party1 = []
    party2 = []
    team1.length.times { |i| party1.push(team1[i]) }
    team2.length.times { |i| party2.push(team2[i]) }
    decision = pbDecideWinner(party1, party2, team1.rating, team2.rating)
  end
  case decision
  when 1   # Team 1 wins
    team1.addMatch(team2, 1)
    team2.addMatch(team1, 0)
  when 2   # Team 2 wins
    team1.addMatch(team2, 0)
    team2.addMatch(team1, 1)
  else
    team1.addMatch(team2, -1)
    team2.addMatch(team1, -1)
  end
end
