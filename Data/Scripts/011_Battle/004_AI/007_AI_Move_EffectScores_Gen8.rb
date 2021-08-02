class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias gen8_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill = 100)
    score = gen8_pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    when "176"
      score += 5 if target.pbCanPoison?(user, false)
    #---------------------------------------------------------------------------
    when "177"
      if target.pbCanBurn?(user, false)
        score += 40
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "178"
      score += 20 if user.stages[:SPEED] <= 0
    #---------------------------------------------------------------------------
    when "179"
      if user.effects[PBEffects::NoRetreat]
        score -= 100
      elsif user.hasActiveAbility?(:CONTRARY)
        score -= 100
      else
        stats_maxed = true
        GameData::Stat.each_main_battle do |s|
          next if user.statStageAtMax?(s.id)
          stats_maxed = false
          break
        end
        if stats_maxed
          score -= 100
        else
          if skill >= PBTrainerAI.highSkill
            score -= 50 if user.hp <= user.totalhp / 2
            score += 30 if user.trappedInBattle?
          end
          GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
          if skill >= PBTrainerAI.mediumSkill
            hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
    #---------------------------------------------------------------------------
    when "17A"
      if user.hp <= user.totalhp / 2
        score -= 100
      elsif user.hasActiveAbility?(:CONTRARY)
        score -= 100
      else
        stats_maxed = true
        GameData::Stat.each_main_battle do |s|
          next if user.statStageAtMax?(s.id)
          stats_maxed = false
          break
        end
        if stats_maxed
          score -= 100
        else
          if skill >= PBTrainerAI.highSkill && user.hp >= user.totalhp * 0.75
            score += 30
          end
          GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
          if skill >= PBTrainerAI.mediumSkill
            hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
    #---------------------------------------------------------------------------
    when "17B"
      has_ally = false
      user.eachAlly do |b|
        next if !b.pbCanLowerStatStage?(:ATTACK, user) &&
                !b.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
        has_ally = true
        if skill >= PBTrainerAI.mediumSkill && b.hasActiveAbility?(:CONTRARY)
          score -= 90
        else
          score += 40
          score -= b.stages[:ATTACK] * 20
          score -= b.stages[:SPECIAL_ATTACK] * 20
        end
      end
      score = 0 if !has_ally
    #---------------------------------------------------------------------------
    when "17C"
      if target.opposes?(user)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && target.hasActiveAbility?(:CONTRARY)
        score -= 90
      else
        score -= target.stages[:ATTACK] * 20
        score -= target.stages[:SPECIAL_ATTACK] * 20
      end
    #---------------------------------------------------------------------------
    when "17D"
      if !target.pbCanLowerStatStage?(:DEFENSE, user)
        score -= 90
      else
        score += 20
        score += target.stages[:DEFENSE] * 20
      end
      score += 30 if @battle.field.effects[PBEffects::Gravity] > 0
    #---------------------------------------------------------------------------
    when "17E"
      if !target.pbCanLowerStatStage?(:SPEED, user) && target.effects[PBEffects::TarShot]
        score -= 100
      else
        score += target.stages[:SPEED] * 10
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 50 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
      score += 20 if user.moves.any? { |m| m.damagingMove? && m.pbCalcType(user) == :FIRE }
    #---------------------------------------------------------------------------
    when "17F"
      if target.pbHasOtherType?(:PSYCHIC)
        score -= 90
      elsif !target.canChangeType?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "180"
      score += 40 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "181"
      score += 40 if @battle.field.terrain == :Psychic && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "182"
      score += 40 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "183"
    #---------------------------------------------------------------------------
    when "184"
    #---------------------------------------------------------------------------
    when "185"
      if skill >= PBTrainerAI.mediumSkill && @battle.field.terrain == :Grassy
        aspeed = pbRoughStat(user, :SPEED, skill)
        ospeed = pbRoughStat(target, :SPEED, skill)
        score += 40 if aspeed < ospeed
      end
    #---------------------------------------------------------------------------
    when "186"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "187"
      redirection = false
      user.eachOpposing do |b|
        next if b.index == target.index
        if b.effects[PBEffects::RagePowder] ||
           b.effects[PBEffects::Spotlight] > 0 ||
           b.effects[PBEffects::FollowMe] > 0 ||
           (b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType == :ELECTRIC) ||
           (b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType == :WATER)
          redirection = true
          break
        end
      end
      score += 50 if redirection && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "188"
    #---------------------------------------------------------------------------
    when "189"
      if skill >= PBTrainerAI.highSkill
        stat = (move.physicalMove?)? :DEFENSE : :SPECIAL_DEFENSE
        score += 50 if targets.stages[stat] > 1
      end
    #---------------------------------------------------------------------------
    when "18A"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed && aspeed * 2 / 3 < ospeed
        score -= 50
      elsif aspeed < ospeed && aspeed * 1.5 > ospeed
        score += 50
      end
      score += user.stages[:DEFENSE] * 30
    #---------------------------------------------------------------------------
    when "18B"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if (aspeed > ospeed && user.hp > user.totalhp / 3) || user.hp > user.totalhp / 2
        score += 60
      else
        score -= 90
      end
      score += user.stages[:SPECIAL_ATTACK] * 20
    #---------------------------------------------------------------------------
    when "18C"
      ally_amt = 30
      @battle.eachSameSideBattler(user.index) do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt / 2
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
      end
    #---------------------------------------------------------------------------
    when "18D"
      ally_amt = 80 / @battle.pbSideSize(user.index)
      @battle.eachSameSideBattler(user.index) do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
        score += ally_amt / 2 if b.pbHasAnyStatus?
      end
    #---------------------------------------------------------------------------
    when "18E"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 40   # want to draw
        score += 40 if @battle.field.terrain == :Misty
      else
        score -= user.hp * 100 / user.totalhp
        score += 20 if @battle.field.terrain == :Misty
      end
    #---------------------------------------------------------------------------
    when "18F"
      if target.effects[PBEffects::Octolock] >= 0
        score -= 100
      else
        score += 30 if !target.trappedInBattle?
        score -= 100 if !target.pbCanLowerStatStage?(:DEFENSE, user, move) &&
                        !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, move)
      end
    #---------------------------------------------------------------------------
    when "190"
      if target.effects[PBEffects::JawLock] < 0
        score += 40 if !user.trappedInBattle? && !target.trappedInBattle?
      end
    #---------------------------------------------------------------------------
    when "191"
      if !user.item || !user.item.is_berry? || !user.itemActive?
        score -= 100
      else
        if skill >= PBTrainerAI.highSkill
          useful_berries = [
            :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
            :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
            :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
            :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
            :SALACBERRY, :STARFBERRY, :WIKIBERRY
          ]
          score += 30 if useful_berries.include?(user.item_id)
        end
        if skill >= PBTrainerAI.mediumSkill
          score += 20 if user.canHeal? && user.hp < user.totalhp / 3 && user.hasActiveAbility?(:CHEEKPOUCH)
          score += 20 if user.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                         user.pbHasMoveFunction?("0F6")   # Recycle
          score += 20 if !user.canConsumeBerry?
        end
        score -= user.stages[:DEFENSE] * 20
      end
    #---------------------------------------------------------------------------
    when "192"
      useful_berries = [
        :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
        :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
        :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
        :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
        :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
      ]
      @battle.eachSameSideBattler(user.index) do |b|
        if !b.item || !b.item.is_berry? || !b.itemActive?
          score -= 100 / @battle.pbSideSize(user.index)
        else
          if skill >= PBTrainerAI.highSkill
            amt = 30 / @battle.pbSideSize(user.index)
            score += amt if useful_berries.include?(b.item_id)
          end
          if skill >= PBTrainerAI.mediumSkill
            amt = 20 / @battle.pbSideSize(user.index)
            score += amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
            score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                            b.pbHasMoveFunction?("0F6")   # Recycle
            score += amt if !b.canConsumeBerry?
          end
        end
      end
      if skill >= PBTrainerAI.highSkill
        @battle.eachOtherSideBattler(user.index) do |b|
          amt = 10 / @battle.pbSideSize(target.index)
          score -= amt if b.hasActiveItem?(useful_berries)
          score -= amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
          score -= amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                          b.pbHasMoveFunction?("0F6")   # Recycle
          score -= amt if !b.canConsumeBerry?
        end
      end
    #---------------------------------------------------------------------------
    when "193"
      if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
        score -= 100
      elsif !target.item || !target.itemActive? || target.unlosableItem?(target.item) ||
         target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif target.effects[PBEffects::Substitute] > 0
        score -= 90
      else
        score += 50
      end
    #---------------------------------------------------------------------------
    when "194"
      score -= 100 if user.hp <= user.totalhp / 2
    #---------------------------------------------------------------------------
    when "195"
      last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
      if last_move && last_move.total_pp > 0 && last_move.pp <= 3
        score += 50
      end
    #---------------------------------------------------------------------------
    when "196"
      if skill >= PBTrainerAI.mediumSkill
        if !target.item || !target.itemActive?
          score -= 90
        else
          score += 50
        end
      end
    #---------------------------------------------------------------------------
    when "197"
    #---------------------------------------------------------------------------
    when "198"
      if skill >= PBTrainerAI.mediumSkill
        good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                        :Swamp, :Rainbow, :Mist, :Safeguard,
                        :Tailwind].map! { |e| PBEffects.const_get(e) }
        bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map! { |e| PBEffects.const_get(e) }
        bad_effects.each do |e|
          score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          score -= 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
        end
        if skill >= PBTrainerAI.highSkill
          good_effects.each do |e|
            score += 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
            score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          end
        end
      end
    #---------------------------------------------------------------------------
    when "199"
      score -= 100 if @battle.field.terrain == :None
    #---------------------------------------------------------------------------
    end
    return score
  end
end
