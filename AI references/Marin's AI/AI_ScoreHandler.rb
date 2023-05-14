# Evasion when Foresighted

# cont 120: self destruct

class MKAI
  class ScoreHandler
    @@GeneralCode = []
    @@MoveCode = {}
    @@StatusCode = []
    @@DamagingCode = []

    def self.add_status(&code)
      @@StatusCode << code
    end

    def self.add_damaging(&code)
      @@DamagingCode << code
    end

    def self.add(*moves, &code)
      if moves.size == 0
        @@GeneralCode << code
      else
        moves.each do |move|
          if move.is_a?(Symbol) # Specific move
            id = getConst(PBMoves, move)
            raise "Invalid move #{move}" if id.nil? || id == 0
            @@MoveCode[id] = code
          elsif move.is_a?(String) # Function code
            @@MoveCode[move] = code
          end
        end
      end
    end

    def self.trigger(list, score, ai, user, target, move)
      return score if list.nil?
      list = [list] if !list.is_a?(Array)
      list.each do |code|
        next if code.nil?
        newscore = code.call(score, ai, user, target, move)
        score = newscore if newscore.is_a?(Numeric)
      end
      return score
    end

    def self.trigger_general(score, ai, user, target, move)
      return self.trigger(@@GeneralCode, score, ai, user, target, move)
    end

    def self.trigger_status_moves(score, ai, user, target, move)
      return self.trigger(@@StatusCode, score, ai, user, target, move)
    end

    def self.trigger_damaging_moves(score, ai, user, target, move)
      return self.trigger(@@DamagingCode, score, ai, user, target, move)
    end

    def self.trigger_move(move, score, ai, user, target)
      id = move.id
      id = move.function if !@@MoveCode[id]
      return self.trigger(@@MoveCode[id], score, ai, user, target, move)
    end
  end
end



#=============================================================================#
#                                                                             #
# Multipliers                                                                 #
#                                                                             #
#=============================================================================#


# Effectiveness modifier
# For this to have a more dramatic effect, this block could be moved lower down
# so that it factors in more score modifications before multiplying.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  # Effectiveness doesn't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove) || move.statusMove?
  # Add half the score times the effectiveness modifiers. Means super effective
  # will be a 50% increase in score.
  target_types = target.types
  mod = move.pbCalcTypeMod(move.type, user, target) / PBTypeEffectiveness::NORMAL_EFFECTIVE.to_f
  # If mod is 0, i.e. the target is immune to the move (based on type, at least),
  # we do not multiply the score to 0, because immunity is handled as a final multiplier elsewhere.
  if mod != 0 && mod != 1
    score *= mod
    MKAI.log("* #{mod} for effectiveness")
  end
  next score
end



#=============================================================================#
#                                                                             #
# All Moves                                                                   #
#                                                                             #
#=============================================================================#


# Accuracy modifier to favor high-accuracy moves
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  next if user.battler == target.battler
  accuracy = user.get_move_accuracy(move, target)
  missing = 100 - accuracy
  # (High) Jump Kick, a move that damages you when you miss
  if move.function == "10B"
    # Decrease the score more drastically if it has lower accuracy
    missing *= 2.0
  end
  if missing > 0
    score -= missing
    MKAI.log("- #{missing} for accuracy")
  end
  next score
end


# Increase/decrease score for each positive/negative stat boost the move gives the user
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_MultiStatUpMove) && !move.is_a?(PokeBattle_StatUpMove) &&
          !move.is_a?(PokeBattle_StatDownMove)
  boosts = 0
  atkBoosts = 0
  spAtkBoosts = 0
  evBoosts = 0
  stats = []
  if move.statUp
    for i in 0...move.statUp.size / 2
      stat = move.statUp[i * 2]
      incr = move.statUp[i * 2 + 1]
      boosts += incr
      atkBoosts += incr if stat == PBStats::ATTACK
      spAtkBoosts += incr if stat == PBStats::SPATK
      evBoosts += incr if stat == PBStats::EVASION
      stats << stat
    end
  end
  if move.statDown
    for i in 0...move.statDown.size / 2
      stat = move.statDown[i * 2]
      decr = move.statDown[i * 2 + 1]
      boosts -= decr if 
      atkBoosts -= decr if stat == PBStats::ATTACK
      spAtkBoosts -= decr if stat == PBStats::SPATK
      stats << stat if !stats.include?(stat)
    end
  end
  # Increase score by 10 * (net stage differences)
  # If attack is boosted and the user is a physical attacker,
  # these stage increases are multiplied by 20 instead of 10.
  if atkBoosts > 0 && user.is_physical_attacker?
    atkIncr = (atkBoosts * 30 * (2 - (user.stages[PBStats::ATTACK] + 6) / 6.0)).round
    if atkIncr > 0
      score += atkIncr
      MKAI.log("+ #{atkIncr} for attack boost and being a physical attacker")
      boosts -= atkBoosts
    end
  end
  # If spatk is boosted and the user is a special attacker,
  # these stage increases are multiplied by 20 instead of 10.
  if spAtkBoosts > 0 && user.is_special_attacker?
    spatkIncr = (spAtkBoosts * 30 * (2 - (user.stages[PBStats::SPATK] + 6) / 6.0)).round
    if spatkIncr > 0
      score += spatkIncr
      MKAI.log("+ #{spatkIncr} for spatk boost and being a special attacker")
      boosts -= spAtkBoosts
    end
  end
  # Boost to evasion
  if evBoosts != 0
    evIncr = (evBoosts * 50 * (2 - (user.stages[PBStats::EVASION] + 6) / 6.0)).round
    if evIncr > 0
      score += evIncr
      MKAI.log("+ #{evIncr} for evasion boost")
      boosts -= evBoosts
    end
  end
  # All remaining stat increases (or decreases) are multiplied by 25 and added to the score.
  if boosts != 0
    total = 6 * stats.size
    eff = total
    user.stages.each_with_index do |value, stage|
      if stats.include?(stage)
        eff -= value
      end
    end
    fact = 1.0
    fact = eff / total.to_f if total != 0
    incr = (boosts * 25 * fact).round
    if incr > 0
      score += incr
      MKAI.log("+ #{incr} for general user buffs (#{eff}/#{total} effectiveness)")
    end
  end
  next score
end


# Increase/decrease score for each positive/negative stat boost the move gives the target
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_TargetStatDownMove) && !move.is_a?(PokeBattle_TargetMultiStatDownMove)
  debuffs = 0
  accDecreases = 0
  stats = []
  if move.statDown
    for i in 0...move.statDown.size / 2
      stat = move.statDown[i * 2]
      decr = move.statDown[i * 2 + 1]
      debuffs += decr
      accDecreases += decr if stat == PBStats::ACCURACY
      stats << stat if stat != PBStats::EVASION && stat != PBStats::ACCURACY
    end
  end
  if accDecreases != 0 && target.stages[PBStats::ACCURACY] != -6
    accIncr = (accDecreases * 50 * (target.stages[PBStats::ACCURACY] + 6) / 6.0).round
    score += accIncr
    debuffs -= accIncr
    MKAI.log("+ #{accIncr} for target accuracy debuff")
  end
  # All remaining stat decrases are multiplied by 10 and added to the score.
  if debuffs > 0
    total = 6 * stats.size
    eff = total
    target.stages.each_with_index do |value, stage|
      if stats.include?(stage)
        eff += value
      end
    end
    fact = 1.0
    fact = eff / total.to_f if total != 0
    incr = (debuffs * 25 * fact).round
    score += incr
    MKAI.log("+ #{incr} for general target debuffs (#{eff}/#{total} effectiveness)")
  end
  next score
end


# Prefer priority moves that deal enough damage to knock the target out.
# Use previous damage dealt to determine if it deals enough damage now,
# or make a rough estimate.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  # Apply this logic only for priority moves
  next if move.priority <= 0 || move.function == "0D4" # Bide
  prevDmg = target.get_damage_by_user_and_move(user, move)
  if prevDmg.size > 0
    # We have the previous damage this user has done with this move.
    # Use the average of the previous damage dealt, and if it's more than the target's hp,
    # we can likely use this move to knock out the target.
    avg = (prevDmg.map { |e| e[2] }.sum / prevDmg.size.to_f).floor
    if avg >= target.battler.hp
      MKAI.log("+ 250 for priority move with average damage (#{avg}) >= target hp (#{target.battler.hp})")
      score += 250
    end
  else
    # Calculate the damage this priority move will do.
    # The AI kind of cheats here, because this takes all items, berries, abilities, etc. into account.
    # It is worth for the effect though; the AI using a priority move to prevent
    # you from using one last move before you faint.
    dmg = user.get_move_damage(target, move)
    if dmg >= target.battler.hp
      MKAI.log("+ 250 for priority move with predicted damage (#{dmg}) >= target hp (#{target.battler.hp})")
      score += 250
    end
  end
  next score
end


# Encourage using fixed-damage moves if the fixed damage is more than the target has HP
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_FixedDamageMove) || move.function == "070" || move.function == "0D4"
  dmg = move.pbFixedDamage(user, target)
  if dmg >= target.hp
    score += 175
    MKAI.log("+ 175 for this move's fixed damage being enough to knock out the target")
  end
  next score
end


# See if any moves used in the past did enough damage to now kill the target,
# and if so, give that move slightly more preference.
# There can be more powerful moves that might also take out the user,
# but if this move will also take the user out, this is a safer option.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  next if move.function == "0D4" # Bide
  # Get all times this move was used on the target
  ary = target.get_damage_by_user_and_move(user, move)
  # If this move has been used before, and the move is not a two-turn move
  if ary.size > 0 && !move.chargingTurnMove? && move.function != "0C2" # Hyper Beam
    # Calculate the average damage of every time this move was used on the target
    avg = ary.map { |e| e[2] }.sum / ary.size.to_f
    # If the average damage this move dealt is enough to kill the target, increase likelihood of choosing this move
    if avg >= target.hp
      score += 100
      MKAI.log("+ 100 for this move being likely to take out the target")
    end
  end
  next score
end


# Prefer moves that are usable while the user is asleep
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the move is usable while asleep, and if the user won't wake up this turn
  # Kind of cheating, but insignificant. This way the user can choose a more powerful move instead
  if move.usableWhenAsleep?
    if user.asleep? && user.statusCount > 1
      score += 200
      MKAI.log("+ 200 for being able to use this move while asleep")
    else
      score -= 50
      MKAI.log("- 50 for this move will have no effect")
    end
  end
  next score
end


# Prefer moves that can thaw the user if the user is frozen
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the user is frozen and the move thaws the user
  if user.frozen? && move.thawsUser?
    score += 80
    MKAI.log("+ 80 for being able to thaw the user")
  end
  next score
end


# Discourage using OHKO moves if the target is higher level or it has sturdy
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.function == "070" # OHKO Move
    if target.has_ability?(:STURDY)
      score -= 100
      MKAI.log("- 100 for the target has Sturdy")
    end
    if target.level > user.level
      score -= 80
      MKAI.log("- 80 for the move will fail due to level difference")
    end
    score -= 50
    MKAI.log("- 50 for OHKO moves are generally considered bad")
  end
  next score
end


# Encourage using trapping moves, since they're generally weak
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.function == "0CF" # Trapping Move
    if target.effects[PBEffects::Trapping] == 0 # The target is not yet trapped
      score += 60
      MKAI.log("+ 60 for initiating a multi-turn trap")
    end
  end
  next score
end


# Encourage using flinching moves if the user is faster
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.flinchingMove? && (user.faster_than?(target) || move.priority > 0)
    score += 50
    MKAI.log("+ 50 for being able to flinch the target")
  end
  next score
end


# Discourage using a multi-hit physical move if the target has an item or ability
# that will damage the user on each contact.
# Also slightly discourages physical moves if the target has a bad ability in general.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.pbContactMove?(user)
    if user.discourage_making_contact_with?(target)
      if move.multiHitMove?
        score -= 60
        MKAI.log("- 60 for the target has an item or ability that activates on each contact")
      else
        score -= 30
        MKAI.log("- 30 for the target has an item or ability that activates on contact")
      end
    end
  end
  next score
end


# Encourage using moves that can cause a burn.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_BurnMove) && !target.burned? && target.can_burn?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      if target.is_physical_attacker?
        add = 30 + chance * 2
        score += add
        MKAI.log("+ #{add} for being able to burn the physical-attacking target")
      else
        score += chance
        MKAI.log("+ #{chance} for being able to burn the target")
      end
    end
  end
  next score
end


# Encourage using moves that can cause freezing.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_FreezeMove) && !target.frozen? && target.can_freeze?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      score += chance * 2
      MKAI.log("+ #{chance} for being able to freeze the target")
    end
  end
  next score
end


# Encourage using moves that can cause paralysis.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_ParalysisMove) && !target.paralyzed? && target.can_paralyze?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      score += chance
      MKAI.log("+ #{chance} for being able to paralyze the target")
    end
  end
  next score
end


# Encourage using moves that can cause sleep.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_SleepMove) && !target.asleep? && target.can_sleep?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      score += chance
      MKAI.log("+ #{chance} for being able to put the target to sleep")
    end
  end
  next score
end


# Encourage using moves that can cause poison.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_PoisonMove) && !target.poisoned? && target.can_poison?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      if move.toxic
        add = chance * 1.4 * move.pbNumHits(user, [target])
        score += add
        MKAI.log("+ #{add} for being able to badly poison the target")
      else
        add = chance * move.pbNumHits(user, [target])
        score += add
        MKAI.log("+ #{add} for being able to poison the target")
      end
    end
  end
  next score
end


# Encourage using moves that can cause confusion.
MKAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_ConfuseMove) && !target.confused?
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      add = chance * move.pbNumHits(user, [target])
      # The higher the target's attack stats, the more beneficial it is to confuse the target.
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = target.stages[PBStats::ATTACK] + 6
      factor = stageMul[stage] / stageDiv[stage].to_f
      add *= factor
      score += add
      MKAI.log("+ #{add} for being able to confuse the target")
    end
  end
  next score
end


#=============================================================================#
#                                                                             #
# Damaging Moves                                                              #
#                                                                             #
#=============================================================================#


# STAB modifier
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # STAB doesn't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove)
  calcType = move.pbCalcType(user.battler)
  if calcType >= 0 && user.has_type?(calcType)
    if user.has_ability?(:ADAPTABILITY)
      MKAI.log("+ 90 for STAB with Adaptability")
      score += 90
    else
      MKAI.log("+ 50 for STAB")
      score += 50
    end
  end
  next score
end


# Stat stages and physical/special attacker label
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Stat boosts don't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove)
  # If the move is physical
  if move.physicalMove?
    # Increase the score by 25 per stage increase/decrease
    if user.stages[PBStats::ATTACK] != 0
      add = user.stages[PBStats::ATTACK] * 25
      score += add
      MKAI.log("#{add < 0 ? "-" : "+"} #{add.abs} for attack stages")
    end
    # Make the move more likely to be chosen if this user is also considered a physical attacker.
    if user.is_physical_attacker?
      score += 30
      MKAI.log("+ 30 for being a physical attacker")
    end
  end

  # If the move is special
  if move.specialMove?
    # Increase the score by 25 per stage increase/decrease
    if user.stages[PBStats::SPATK] != 0
      add = user.stages[PBStats::SPATK] * 25
      score += add
      MKAI.log("#{add < 0 ? "-" : "+"} #{add.abs} for attack stages")
    end
    # Make the move more likely to be chosen if this user is also considered a special attacker.
    if user.is_special_attacker?
      score += 30
      MKAI.log("+ 30 for being a special attacker")
    end
  end
  next score
end


# Discourage using damaging moves if the target is semi-invulnerable and slower,
# and encourage using damaging moves if they can break through the semi-invulnerability
# (e.g. prefer earthquake when target is underground)
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Target is semi-invulnerable
  if target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    encourage = false
    discourage = false
    # User will hit first while target is still semi-invulnerable.
    # If this move will do extra damage because the target is semi-invulnerable,
    # encourage using this move. If not, discourage using it.
    if user.faster_than?(target)
      if target.in_two_turn_attack?("0C9", "0CC", "0CE") # Fly, Bounce, Sky Drop
        encourage = move.hitsFlyingTargets?
        discourage = !encourage
      elsif target.in_two_turn_attack?("0CA") # Dig
        # Do not encourage using Fissure, even though it can hit digging targets, because it's an OHKO move
        encourage = move.hitsDiggingTargets? && move.function != "070"
        discourage = !encourage
      elsif target.in_two_turn_attack?("0CB") # Dive
        encourage = move.hitsDivingTargets?
        discourage = !encourage
      else
        discourage = true
      end
    end
    # If the user has No Guard
    if user.has_ability?(:NOGUARD)
      # Then any move would be able to hit the target, meaning this move wouldn't be anything special.
      encourage = false
      discourage = false
    end
    if encourage
      score += 100
      MKAI.log("+ 100 for being able to hit through a semi-invulnerable state")
    elsif discourage
      score -= 150
      MKAI.log("- 150 for not being able to hit target because of semi-invulnerability")
    end
  end
  next score
end


# Lower the score of multi-turn moves, because they likely have quite high power and thus score.
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if !user.has_item?(:POWERHERB) && (move.chargingTurnMove? || move.function == "0C2") # Hyper Beam
    score -= 70
    MKAI.log("- 70 for requiring a charging turn")
  end
  next score
end


# Prefer using damaging moves based on the level difference between the user and target,
# because if the user will get one-shot, then there's no point in using set-up moves.
# Furthermore, if the target is more than 5 levels higher than the user, priority
# get an additional boost to ensure the user can get a hit in before being potentially one-shot.
# TODO: Make "underdog" method, also for use by moves like perish song or explode and such
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Start counting factor this when there's a level difference of greater than 5
  if user.underdog?(target)
    add = 5 * (target.level - user.level - 5)
    if add > 0
      score += add
      MKAI.log("+ #{5 * (target.level - user.level - 5)} for preferring damaging moves due to being a low level")
    end
    if move.priority > 0
      score += 30
      MKAI.log("+ 30 for being a priority move and being and underdog")
    end
  end
  next score
end


# Discourage using physical moves when the user is burned
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if user.burned?
    if move.physicalMove? && move.function != "07E"
      score -= 50
      MKAI.log("- 50 for being a physical move and being burned")
    end
  end
  next score
end


# Encourage high-critical hit rate moves, or damaging moves in general
# if Laser Focus or Focus Energy has been used
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  next if !move.pbCouldBeCritical?(user.battler, target.battler)
  if move.highCriticalRate? || user.effects[PBEffects::LaserFocus] > 0 ||
     user.effects[PBEffects::FocusEnergy] > 0
    score += 30
    MKAI.log("+ 30 for having a high critical-hit rate")
  end
  next score
end


# Discourage recoil moves if they would knock the user out
MKAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_RecoilMove)
    dmg = move.pbRecoilDamage(user.battler, target.battler)
    if dmg >= user.hp
      score -= 50
      MKAI.log("- 50 for the recoil will knock the user out")
    end
  end
  next score
end



#=============================================================================#
#                                                                             #
# Move-specific                                                               #
#                                                                             #
#=============================================================================#


# Facade
MKAI::ScoreHandler.add("07E") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed?
    score += 50
    MKAI.log("+ 50 for doing more damage with a status condition")
  end
  next score
end


# Aromatherapy, Heal Bell
MKAI::ScoreHandler.add("019") do |score, ai, user, target, move|
  count = 0
  user.side.battlers.each do |proj|
    next if proj.nil?
    # + 80 for each active battler with a status condition
    count += 2.0 if proj.has_non_volatile_status?
  end
  user.side.party.each do |proj|
    next if proj.battler # Skip battlers
    # Inactive party members do not have a battler attached,
    # so we can't use has_non_volatile_status?
    count += 1.0 if proj.pokemon.status > 0
    # + 40 for each inactive pokemon with a status condition in the party
  end
  if count != 0
    add = count * 40.0
    score += add
    MKAI.log("+ #{add} for curing status condition(s)")
  else
    score -= 30
    MKAI.log("- 30 for not curing any status conditions")
  end
  next score
end


# Psycho Shift
MKAI::ScoreHandler.add("01B") do |score, ai, user, target, move|
  # If the user has a status condition that is not frozen,
  if user.has_non_volatile_status? && !user.frozen?
    # And the target doesn't have any status conditions
    if !target.has_non_volatile_status?
      # Then we can transfer our status condition
      transferrable = true
      transferrable = false if user.burned? && !target.can_burn?(user, move)
      transferrable = false if user.poisoned? && !target.can_poison?(user, move)
      transferrable = false if user.paralyzed? && !target.can_paralyze?(user, move)
      transferrable = false if user.asleep? && !target.can_sleep?(user, move)
      if transferrable
        score += 120
        MKAI.log("+ 120 for being able to pass on our status condition")
        if user.burned? && target.is_physical_attacker?
          score += 50
          MKAI.log("+ 50 for being able to burn the physical-attacking target")
        end
      end
    end
  else
    score -= 30
    MKAI.log("- 30 for not having a transferrable status condition")
  end
  next score
end


# Purify
MKAI::ScoreHandler.add("15B") do |score, ai, user, target, move|
  if target.has_non_volatile_status?
    factor = 1 - user.hp / user.totalhp.to_f
    # At full hp, factor is 0 (thus not encouraging this move)
    # At half hp, factor is 0.5 (thus slightly encouraging this move)
    # At 1 hp, factor is about 1.0 (thus encouraging this move)
    if user.flags[:will_be_healed]
      score -= 30
      MKAI.log("- 30 for the user will already be healed by something")
    elsif factor != 0
      if user.is_healing_pointless?(0.5)
        score -= 10
        MKAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
      elsif user.is_healing_necessary?(0.5)
        add = (factor * 250).round
        score += add
        MKAI.log("+ #{add} for we will likely die without healing")
      else
        add = (factor * 125).round
        score += add
        MKAI.log("+ #{add} for we have lost some hp")
      end
    end
  else
    score -= 30
    MKAI.log("- 30 for the move will fail since the target has no status condition")
  end
  next score
end


# Refresh
MKAI::ScoreHandler.add("018") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed?
    score += 70
    MKAI.log("+ 70 for being able to cure our status condition")
  end
  next score
end


# Rest
MKAI::ScoreHandler.add("0D9") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  if user.flags[:will_be_healed]
    score -= 30
    MKAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    # Not at full hp
    if user.can_sleep?(user, move, true)
      add = (factor * 100).round
      score += add
      MKAI.log("+ #{add} for we have lost some hp")
    else
      score -= 10
      MKAI.log("- 10 for the move will fail")
    end
  end
  next score
end


# Smelling Salts
MKAI::ScoreHandler.add("07C") do |score, ai, user, target, move|
  if target.paralyzed?
    score += 50
    MKAI.log("+ 50 for doing double damage")
  end
  next score
end


# Wake-Up Slap
MKAI::ScoreHandler.add("07D") do |score, ai, user, target, move|
  if target.asleep?
    score += 50
    MKAI.log("+ 50 for doing double damage")
  end
  next score
end


# Fire Fang, Flare Blitz
MKAI::ScoreHandler.add("00B", "0FE") do |score, ai, user, target, move|
  if !target.burned? && target.can_burn?(user, move)
    if target.is_physical_attacker?
      score += 40
      MKAI.log("+ 40 for being able to burn the physical-attacking target")
    else
      score += 10
      MKAI.log("+ 10 for being able to burn the target")
    end
  end
  next score
end


# Ice Fang
MKAI::ScoreHandler.add("00E") do |score, ai, user, target, move|
  if !target.frozen? && target.can_freeze?(user, move)
    score += 20
    MKAI.log("+ 20 for being able to freeze the target")
  end
  next score
end


# Thunder Fang
MKAI::ScoreHandler.add("009") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 10
    MKAI.log("+ 10 for being able to paralyze the target")
  end
  next score
end


# Ice Burn
MKAI::ScoreHandler.add("0C6") do |score, ai, user, target, move|
  if !target.burned? && target.can_burn?(user, move)
    if target.is_physical_attacker?
      score += 80
      MKAI.log("+ 80 for being able to burn the physical-attacking target")
    else
      score += 30
      MKAI.log("+ 30 for being able to burn the target")
    end
  end
  next score
end


# Secret Power
MKAI::ScoreHandler.add("0A4") do |score, ai, user, target, move|
  score += 40
  MKAI.log("+ 40 for its potential side effects")
  next score
end


# Tri Attack
MKAI::ScoreHandler.add("017") do |score, ai, user, target, move|
  if !target.has_non_volatile_status?
    score += 50
    MKAI.log("+ 50 for being able to cause a status condition")
  end
  next score
end


# Freeze Shock, Bounce
MKAI::ScoreHandler.add("0C5", "0CC") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 30
    MKAI.log("+ 30 for being able to paralyze the target")
  end
  next score
end


# Volt Tackle
MKAI::ScoreHandler.add("0FD") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 10
    MKAI.log("+ 10 for being able to paralyze the target")
  end
  next score
end


# Toxic Thread
MKAI::ScoreHandler.add("159") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 50
    MKAI.log("+ 50 for being able to poison the target")
  end
  if target.battler.pbCanLowerStatStage?(PBStats::SPEED, user, move) &&
     target.faster_than?(user)
    score += 30
    MKAI.log("+ 30 for being able to lower target speed")
  end
  next score
end


# Dark Void
MKAI::ScoreHandler.add(:DARKVOID) do |score, ai, user, target, move|
  if user.is_species?(:DARKRAI)
    if !target.asleep? && target.can_sleep?(user, move)
      score += 120
      MKAI.log("+ 120 for damaging the target with Nightmare if it is asleep")
    end
  else
    score -= 100
    MKAI.log("- 100 for this move will fail")
  end
  next score
end


# Yawn
MKAI::ScoreHandler.add("004") do |score, ai, user, target, move|
  if !target.has_non_volatile_status? && target.effects[PBEffects::Yawn] == 0
    score += 60
    MKAI.log("+ 60 for putting the target to sleep")
  end
  next score
end


# Flatter
MKAI::ScoreHandler.add("040") do |score, ai, user, target, move|
  if target.confused?
    score -= 30
    MKAI.log("- 30 for only raising target stats without being able to confuse it")
  else
    score += 30
    MKAI.log("+ 30 for confusing the target")
  end
  next score
end


# Swagger
MKAI::ScoreHandler.add("041") do |score, ai, user, target, move|
  if target.confused?
    score -= 50
    MKAI.log("- 50 for only raising target stats without being able to confuse it")
  else
    score += 50
    MKAI.log("+ 50 for confusing the target")
    if !target.is_physical_attacker?
      score += 50
      MKAI.log("+ 50 for the target also is not a physical attacker")
    end
  end
  next score
end


# Attract
MKAI::ScoreHandler.add("016") do |score, ai, user, target, move|
  # If the target can be attracted by the user
  if target.can_attract?(user)
    score += 150
    MKAI.log("+ 150 for being able to attract the target")
  end
  next score
end


# Rage
MKAI::ScoreHandler.add("093") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  perc = dmg / target.totalhp.to_f
  perc /= 1.5 if user.discourage_making_contact_with?(target)
  score += perc * 150
  next score
end


# Uproar, Thrash, Petal Dance, Outrage, Ice Ball, Rollout
MKAI::ScoreHandler.add("0D1", "0D2", "0D3") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  perc = dmg / target.totalhp.to_f
  perc /= 1.5 if user.discourage_making_contact_with?(target) && move.pbContactMove?(user)
  if perc != 0
    add = perc * 80
    score += add
    MKAI.log("+ #{add} for dealing about #{(perc * 100).round}% dmg")
  end
  next score
end


# Stealth Rock, Spikes, Toxic Spikes
MKAI::ScoreHandler.add("103", "104", "105") do |score, ai, user, target, move|
  if move.function == "103" && user.opposing_side.effects[PBEffects::Spikes] >= 3 ||
     move.function == "104" && user.opposing_side.effects[PBEffects::ToxicSpikes] >= 2 ||
     move.function == "105" && user.opposing_side.effects[PBEffects::StealthRock]
    score -= 30
    MKAI.log("- 30 for the opposing side already has max spikes")
  else
    inactive = user.opposing_side.party.size - user.opposing_side.battlers.compact.size
    add = inactive * 30
    add *= (3 - user.opposing_side.effects[PBEffects::Spikes]) / 3.0 if move.function == "103"
    add *= 3 / 4.0 if user.opposing_side.effects[PBEffects::ToxicSpikes] == 1 && move.function == "104"
    score += add
    MKAI.log("+ #{add} for there are #{inactive} pokemon to be sent out at some point")
  end
  next score
end


# Disable
MKAI::ScoreHandler.add("0B9") do |score, ai, user, target, move|
  # Already disabled one of the target's moves
  if target.effects[PBEffects::Disable] > 1
    score -= 30
    MKAI.log("- 30 for the target is already disabled")
  else
    # Get previous damage done by the target
    prevDmg = target.get_damage_by_user(user)
    if prevDmg.size > 0
      lastDmg = prevDmg[-1]
      # If the last move did more than 50% damage and the target was faster,
      # we can't disable the move in time thus using Disable is pointless.
      if user.is_healing_pointless?(0.5) && target.faster_than?(user)
        score -= 30
        MKAI.log("- 30 for the target move is too strong and the target is faster")
      else
        add = (lastDmg[3] * 150).round
        score += add
        MKAI.log("+ #{add} for we disable a strong move")
      end
    else
      # Target hasn't used a damaging move yet
      score -= 30
      MKAI.log("- 30 for the target hasn't used a damaging move yet.")
    end
  end
  next score
end


# Counter
MKAI::ScoreHandler.add("071") do |score, ai, user, target, move|
  expect = false
  expect = true if target.is_physical_attacker? && !target.is_healing_necessary?(0.5)
  prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0
    lastDmg = prevDmg[-1]
    lastMove = lastDmg[1]
    expect = true if lastMove.physicalMove?
  end
  # If we can reasonably expect the target to use a physical move
  if expect
    score += 60
    MKAI.log("+ 60 for we can reasonably expect the target to use a physical move")
  end
  next score
end


# Aqua Ring
MKAI::ScoreHandler.add("0DA") do |score, ai, user, target, move|
  if !user.effects[PBEffects::AquaRing]
    if !user.underdog?(target)
      score += 80
      MKAI.log("+ 80 for gaining hp each round")
    else
      # Underdogs are likely to die fast, so setting up healing for each round
      # is likely useless and only a waste of a turn.
      score += 40
      MKAI.log("+ 40 for gaining hp each round despite being an underdog")
    end
  else
    score -= 30
    MKAI.log("- 30 for the user already has an aqua ring")
  end
  next score
end


# Ingrain
MKAI::ScoreHandler.add("0DB") do |score, ai, user, target, move|
  if !user.effects[PBEffects::Ingrain]
    if !user.underdog?(target)
      score += 80
      MKAI.log("+ 80 for gaining hp each round")
    else
      # Underdogs are likely to die fast, so setting up healing for each round
      # is likely useless and only a waste of a turn.
      score += 40
      MKAI.log("+ 40 for gaining hp each round despite being an underdog")
    end
  else
    score -= 30
    MKAI.log("- 30 for the user is already ingrained")
  end
  next score
end


# Leech Seed
MKAI::ScoreHandler.add("0DC") do |score, ai, user, target, move|
  if !user.underdog?(target) && !target.has_type?(:GRASS) && target.effects[PBEffects::LeechSeed] == 0
    score += 60
    MKAI.log("+ 60 for sapping hp from the target")
  end
  next score
end


# Leech Life, Parabolic Charge, Drain Punch, Giga Drain, Horn Leech, Mega Drain, Absorb
MKAI::ScoreHandler.add("0DD") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  add = dmg / 2
  score += add
  MKAI.log("+ #{add} for hp gained")
  next score
end


# Dream Eater
MKAI::ScoreHandler.add("0DE") do |score, ai, user, target, move|
  if target.asleep?
    dmg = user.get_move_damage(target, move)
    add = dmg / 2
    score += add
    MKAI.log("+ #{add} for hp gained")
  else
    score -= 30
    MKAI.log("- 30 for the move will fail")
  end
  next score
end


# Heal Pulse
MKAI::ScoreHandler.add("0DF") do |score, ai, user, target, move|
  # If the target is an ally
  ally = false
  target.battler.eachAlly do |battler|
    ally = true if battler == user.battler
  end
  if ally
    factor = 1 - target.hp / target.totalhp.to_f
    # At full hp, factor is 0 (thus not encouraging this move)
    # At half hp, factor is 0.5 (thus slightly encouraging this move)
    # At 1 hp, factor is about 1.0 (thus encouraging this move)
    if target.flags[:will_be_healed]
      score -= 30
      MKAI.log("- 30 for the target will already be healed by something")
    elsif factor != 0
      if target.is_healing_pointless?(0.5)
        score -= 10
        MKAI.log("- 10 for the target will take more damage than we can heal if the opponent repeats their move")
      elsif target.is_healing_necessary?(0.5)
        add = (factor * 250).round
        score += add
        MKAI.log("+ #{add} for the target will likely die without healing")
      else
        add = (factor * 125).round
        score += add
        MKAI.log("+ #{add} for the target has lost some hp")
      end
    else
      score -= 30
      MKAI.log("- 30 for the target is at full hp")
    end
  else
    score -= 30
    MKAI.log("- 30 for the target is not an ally")
  end
  next score
end


# Whirlwind, Roar, Circle Throw, Dragon Tail, U-Turn, Volt Switch
MKAI::ScoreHandler.add("0EB", "0EC", "0EE") do |score, ai, user, target, move|
  if user.bad_against?(target) && user.level >= target.level &&
     !target.has_ability?(:SUCTIONCUPS) && !target.effects[PBEffects::Ingrain]
    score += 100
    MKAI.log("+ 100 for forcing our target to switch and we're bad against our target")
  end
  next score
end


# Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves
MKAI::ScoreHandler.add("0EF") do |score, ai, user, target, move|
  if target.bad_against?(user) && !target.has_type?(:GHOST)
    score += 100
    MKAI.log("+ 100 for locking our target in battle with us and they're bad against us")
  end
  next score
end


# Mimic
MKAI::ScoreHandler.add("05C") do |score, ai, user, target, move|
  blacklisted = ["002", "014", "05C", "05D", "0B6"] # Struggle, Chatter, Mimic, Sketch, Metronome
  last_move = pbGetMoveData(target.battler.lastRegularMoveUsed)
  # Don't mimic if no move has been used or we can't mimic the move
  if target.battler.lastRegularMoveUsed <= 0 || blacklisted.include?(last_move[MOVE_FUNCTION_CODE])
    score -= 30
    MKAI.log("- 30 for we can't mimic any move used prior")
  else
    move_id = last_move[MOVE_ID]
    matchup = target.calculate_move_matchup(move_id)
    # If our target used a move that would also be super effective against them,
    # it would be a good idea to mimic that move now so we can use it against them.
    if matchup > 1
      add = (matchup * 75.0).round
      score += add
      MKAI.log("+ #{add} for we can mimic a move that would be super effective against the target too.")
    end
  end
  next score
end


# Recover, Slack Off, Soft-Boiled, Heal Order, Milk Drink, Roost, Wish
MKAI::ScoreHandler.add("0D5", "0D6", "0D7") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed]
    score -= 30
    MKAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(0.5)
      score -= 10
      MKAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(0.5)
      add = (factor * 250).round
      score += add
      MKAI.log("+ #{add} for we will likely die without healing")
    else
      add = (factor * 125).round
      score += add
      MKAI.log("+ #{add} for we have lost some hp")
    end
  else
    score -= 30
    MKAI.log("- 30 for we are at full hp")
  end
  next score
end


# Moonlight, Morning Sun, Synthesis
MKAI::ScoreHandler.add("0D8") do |score, ai, user, target, move|
  heal_factor = 0.5
  case ai.battle.pbWeather
  when PBWeather::Sun, PBWeather::HarshSun
    heal_factor = 2.0 / 3.0
  when PBWeather::None, PBWeather::StrongWinds
    heal_factor = 0.5
  else
    heal_factor = 0.25
  end
  effi_factor = 1.0
  effi_factor = 0.5 if heal_factor == 0.25
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed]
    score -= 30
    MKAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(heal_factor)
      score -= 10
      MKAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(heal_factor)
      add = (factor * 250 * effi_factor).round
      score += add
      MKAI.log("+ #{add} for we will likely die without healing")
    else
      add = (factor * 125 * effi_factor).round
      score += add
      MKAI.log("+ #{add} for we have lost some hp")
    end
  else
    score -= 30
    MKAI.log("- 30 for we are at full hp")
  end
  next score
end


# Minimize
MKAI::ScoreHandler.add("034") do |score, ai, user, target, move|
  accuracy = false
  double = false
  target.side.battlers.any? do |proj|
    accuracy = true if proj.moves.any? { |move| move.tramplesMinimize?(1) && !proj.target_is_immune?(move, user) }
    double = true if proj.moves.any? { |move| move.tramplesMinimize?(2) && !proj.target_is_immune?(move, user) }
  end
  if accuracy
    score -= 40
    MKAI.log("- 40 for the target has moves that will hit with perfect accuracy against minimized targets")
  end
  if double
    score -= 90
    MKAI.log("- 90 for the target has moves that will deal double damage against minimized targets")
  end
  next score
end


# Lucky Chant
MKAI::ScoreHandler.add("0A1") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::LuckyChant] > 0
    score -= 30
    MKAI.log("- 30 for lucky chant is already active")
  elsif user.side.flags[:will_luckychant]
    score -= 30
    MKAI.log("- 30 for another battler will already use lucky chant")
  else
    enemies = target.side.battlers.select { |proj| !proj.fainted? }.size
    critenemies = target.side.battlers.select { |proj| proj.moves.any? { |m| m.highCriticalRate? } }.size
    add = enemies * 20 + critenemies * 30
    score += add
    MKAI.log("+ #{add} based on enemy and high-crit-dealing enemy moves count")
  end
  next score
end


# Reflect
MKAI::ScoreHandler.add("0A2") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::Reflect] > 0
    score -= 30
    MKAI.log("- 30 for reflect is already active")
  elsif user.side.flags[:will_reflect]
    score -= 30
    MKAI.log("- 30 for another battler will already use reflect")
  else
    enemies = target.side.battlers.select { |proj| !proj.fainted? }.size
    physenemies = target.side.battlers.select { |proj| proj.is_physical_attacker? }.size
    add = enemies * 20 + physenemies * 30
    score += add
    MKAI.log("+ #{add} based on enemy and physical enemy count")
  end
  next score
end


# Light Screen
MKAI::ScoreHandler.add("0A3") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::LightScreen] > 0
    score -= 30
    MKAI.log("- 30 for light screen is already active")
  elsif user.side.flags[:will_lightscreen]
    score -= 30
    MKAI.log("- 30 for another battler will already use light screen")
  else
    enemies = target.side.battlers.select { |proj| !proj.fainted? }.size
    specenemies = target.side.battlers.select { |proj| proj.is_special_attacker? }.size
    add = enemies * 20 + specenemies * 30
    score += add
    MKAI.log("+ #{add} based on enemy and special enemy count")
  end
  next score
end


# Haze
MKAI::ScoreHandler.add("051") do |score, ai, user, target, move|
  if user.side.flags[:will_haze]
    score -= 30
    MKAI.log("- 30 for another battler will already use haze")
  else
    net = 0
    # User buffs: net goes up
    # User debuffs: net goes down
    # Target buffs: net goes down
    # Target debuffs: net goes up
    # The lower net is, the better Haze is to choose.
    user.side.battlers.each do |proj|
      PBStats.eachBattleStat { |s| net += proj.stages[s] }
    end
    target.side.battlers.each do |proj|
      PBStats.eachBattleStat { |s| net -= proj.stages[s] }
    end
    # As long as the target's stat stages are more advantageous than ours (i.e. net < 0), Haze is a good choice
    if net < 0
      add = -net * 20
      score += add
      MKAI.log("+ #{add} to reset disadvantageous stat stages")
    else
      score -= 30
      MKAI.log("- 30 for our stat stages are advantageous")
    end
  end
  next score
end


# Bide
MKAI::ScoreHandler.add("0D4") do |score, ai, user, target, move|
  # If we've been hit at least once, use Bide if we could take two hits of the last attack and survive
  prevDmg = target.get_damage_by_user(user)
  if prevDmg.size > 0
    lastDmg = prevDmg[-1]
    predDmg = lastDmg[2] * 2
    # We would live if we took two hits of the last move
    if user.hp - predDmg > 0
      score += 120
      MKAI.log("+ 120 for we can survive two subsequent attacks")
    else
      score -= 10
      MKAI.log("- 10 for we would not survive two subsequent attacks")
    end
  else
    score -= 10
    MKAI.log("- 10 for we don't know whether we'd survive two subsequent attacks")
  end
  next score
end


# Metronome
MKAI::ScoreHandler.add("0B6") do |score, ai, user, target, move|
  score += 20
  MKAI.log("+ 20 to make this move an option if all other choices also have a low score")
  next score
end


# Mirror Move
MKAI::ScoreHandler.add("0AE") do |score, ai, user, target, move|
  if target.battler.lastRegularMoveUsed <= 0 || target.faster_than?(user)
    score -= 10
    MKAI.log("- 10 for we don't know what move our target will use")
  elsif target.battler.lastRegularMoveUsed <= 0 && user.faster_than?(target)
    score -= 30
    MKAI.log("- 30 for our target has not made a move yet")
  else
    # Can Mirror Move
    if pbGetMoveData(target.battler.lastRegularMoveUsed, MOVE_FLAGS)[/e/]
      matchup = target.calculate_move_matchup(pbGetMoveData(target.battler.lastRegularMoveUsed, MOVE_ID))
      # Super Effective
      if matchup > 1
        add = (matchup * 75.0).round
        score += add
        MKAI.log("+ #{add} for being able to mirror a super effective move")
      else
        score -= 30
        MKAI.log("- 30 for we would likely mirror a not very effective move")
      end
    else
      score -= 30
      MKAI.log("- 30 for we would not be able to mirror the move the target will likely use")
    end
  end
  next score
end