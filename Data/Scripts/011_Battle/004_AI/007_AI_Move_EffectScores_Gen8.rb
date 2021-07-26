class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias gen8_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill = 100)
    score = gen8_pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    when "176"
      score += 20 if user.stages[:SPEED] <= 0
    #---------------------------------------------------------------------------
    when "178"
      score += 60 if !target.movedThisRound
    #---------------------------------------------------------------------------
    when "179"
      stats_maxed = true
      GameData::Stat.each_main_battle do |s|
         next if user.statStageAtMax?(s.id)
         stats_maxed = false
         break
      end
      if stats_maxed || user.hp <= user.totalhp/2 || user.hasActiveAbility?(:CONTRARY)
        score -= 100
      elsif user.hp >= (3 * user.totalhp/4) && skill >= PBTrainerAI.highSkill
        score += 30
      end
      GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
      if skill >= PBTrainerAI.mediumSkill
        hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
        score += 20 if hasDamagingAttack
      end
    #---------------------------------------------------------------------------
    when "17A"
      good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                      :Swamp, :Rainbow, :Mist, :Safeguard,
                      :Tailwind].map!{|e| PBEffects.const_get(e) }
      bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map!{|e| PBEffects.const_get(e) }
      if skill >= PBTrainerAI.mediumSkill
        bad_effects.each do |e|
          score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          score -= 10 if ![0, 1, false, nil].include?(target.pbOwnSide.effects[e])
        end
      end
      if skill >= PBTrainerAI.highSkill
        good_effects.each do |e|
          score += 10 if ![0, 1, false, nil].include?(target.pbOwnSide.effects[e])
          score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        end
      end
    #---------------------------------------------------------------------------
    when "17B"
      if @battle.pbSideSize(user.index) < 2 || target.opposes?(user)
        score -= 100
      elsif ((target.effects[PBEffects::CraftyShield] || target.hasActiveAbility?(:CONTRARY)) &&
                      skill >= PBTrainerAI.mediumSkill)
        score -= 90
      else
        score += 80
        score -= target.stages[:ATTACK] * 20
        score -= target.stages[:SPECIAL_ATTACK] * 20
      end
    #---------------------------------------------------------------------------
    when "17C"
    #---------------------------------------------------------------------------
    when "17D"
      score += 40 if !target.trappedInBattle?
      score -= 100 if target.effects[PBEffects::JawLock] >= 0
    #---------------------------------------------------------------------------
    when "17E"
      ally_amt = 30
      @battle.eachSameSideBattler(user.index) do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt/2
        elsif b.hp < (b.totalhp * 3 / 4)
          score += ally_amt
        end
      end
    #---------------------------------------------------------------------------
    when "17F"
      stats_maxed = true
      GameData::Stat.each_main_battle do |s|
         next if user.statStageAtMax?(s.id)
         stats_maxed = false
         break
      end
      if stats_maxed || user.effects[PBEffects::NoRetreat] || user.hasActiveAbility?(:CONTRARY)
        score -= 100
      elsif skill >= PBTrainerAI.highSkill
        score -= 50 if user.hp <= user.totalhp/2
        score += 30 if user.trappedInBattle?
      end
      GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
      if skill >= PBTrainerAI.mediumSkill
        hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
        score += 20 if hasDamagingAttack
      end
    #---------------------------------------------------------------------------
    when "180"
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
    when "181"
      score += 30 if !target.trappedInBattle?
      score -= 100 if !target.pbCanLowerStatStage?(:DEFENSE, user, move) &&
                       target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, move)
      score -= 100 if target.effects[PBEffects::Octolock] >= 0
    #---------------------------------------------------------------------------
    when "182"
      redirection = true
      user.eachOpposing do
        next if b.effects[PBEffects::RagePowder]
        next if b.effects[PBEffects::Spotlight] > 0
        next if b.effects[PBEffects::FollowMe] > 0
        next if b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType == :ELECTRIC
        next if b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType == :WATER
        redirection = false
        break
      end
      score += 50 if redirection && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "183"
      if !user.item || !user.itemActive? || !user.item.is_berry?
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
          score += 30 if useful_berries.include?(user.item)
        end
        if skill >= PBTrainerAI.mediumSkill
          score += 20 if user.canHeal? && user.hp < user.totalhp/3 && user.hasActiveAbility?(:CHEEKPOUCH)
          score += 20 if user.hasActiveAbility?([:HARVEST, :RECYLE, :RIPEN])
          score += 20 if !user.canConsumeBerry?
        end
        score -= user.stages[:DEFENSE] * 20
      end
    #---------------------------------------------------------------------------
    when "184"
      useful_berries = [
        :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
        :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
        :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
        :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
        :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
      ]
      @battle.eachSameSideBattler(user.index) do |b|
        if !b.item || !b.itemActive? || !b.item.is_berry?
          score -= 100/@battle.pbSideSize(user.index)
        else
          if skill >= PBTrainerAI.highSkill
            amt = 30/@battle.pbSideSize(user.index)
            score += amt if useful_berries.include?(b.item)
          end
          if skill >= PBTrainerAI.mediumSkill
            amt = 20/@battle.pbSideSize(user.index)
            score += amt if b.canHeal? && b.hp < b.totalhp/3 && b.hasActiveAbility?(:CHEEKPOUCH)
            score += amt if b.hasActiveAbility?([:HARVEST, :RECYLE, :RIPEN])
            score += amt if !b.canConsumeBerry?
          end
        end
      end
      if skill >= PBTrainerAI.highSkill
        @battle.eachOtherSideBattler(user.index) do |b|
          amt = 10/@battle.pbSideSize(target.index)
          score -= amt if useful_berries.any? { |item| b.hasActiveItem?(item) }
          score -= amt if b.canHeal? && b.hp < b.totalhp/3 && b.hasActiveAbility?(:CHEEKPOUCH)
          score -= amt if b.hasActiveAbility?([:HARVEST, :RECYLE, :RIPEN])
          score -= amt if !b.canConsumeBerry?
        end
      end
    #---------------------------------------------------------------------------
    when "185"
      if !target.pbCanLowerStatStage?(:SPEED,user) ||
         (target.hasActiveAbility?(:CONTRARY) && skill >= PBTrainerAI.highSkill) ||
         target.effects[PBEffects::TarShot]
        score -= 100
      else
        score += target.stages[:SPEED] * 10
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 50 if aspeed < ospeed && aspeed*2 > ospeed
        end
      end
      score += 20 if user.moves.any? { |m| m.pbCalcType == :FIRE }
    #---------------------------------------------------------------------------
    when "186"
      if !target.pbCanLowerStatStage?(:DEFENSE,user)
        score -= 90
      else
        score += 20
        score += target.stages[:DEFENSE] * 20
      end
      score += 30 if @battle.field.effects[PBEffects::Gravity] > 0
    #---------------------------------------------------------------------------
    when "187"
      score += 5 if target.pbCanPoison?(user,false)
    #---------------------------------------------------------------------------
    when "188"
      if skill >= PBTrainerAI.highSkill
        stat = (move.physicalMove?)? :DEFENSE : :SPECIAL_DEFENSE
        score += 50 if targets.stages[stat] > 1
      end
    #---------------------------------------------------------------------------
    when "189"
      ally_amt = 80/@battle.pbSideSize(user.index)
      @battle.eachSameSideBattler(user.index) do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt
        elsif b.hp < (b.totalhp * 3 / 4)
          score += ally_amt
        end
        score += ally_amt/2 if b.pbHasAnyStatus?
      end
    #---------------------------------------------------------------------------
    when "18A"
      score += 20 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "18B"
      if target.statsRaised
        score -= 30
        if target.pbCanBurn?(user,false)
          score += 30
          if skill >= PBTrainerAI.highSkill
            score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
          end
        end
      end
    #---------------------------------------------------------------------------
    when "18C"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      score += 30 if @battle.field.terrain == :Grassy && user.affectedByTerrain?
      score += 20 if aspeed < ospeed && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "18D"
      score += 40 if @battle.field.terrain == :Electric && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "18E"
      if @battle.pbSideSize(user.index) < 2
        score -= 100
      else
        user.eachAlly do |b|
          if ((b.effects[PBEffects::CraftyShield] || b.hasActiveAbility?(:CONTRARY)) &&
                          skill >= PBTrainerAI.mediumSkill)
            score -= 90
          else
            score += 40
            score -= b.stages[:ATTACK] * 20
            score -= b.stages[:SPECIAL_ATTACK] * 20
          end
        end
      end
    #---------------------------------------------------------------------------
    when "18F"
      if !target.item || !target.itemActive? || !target.unlosableItem?(target.item)
         score -= 90
      else
        score += 50
      end
    #---------------------------------------------------------------------------
    when "190"
      score += 40 if @battle.field.terrain == :Psychic && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "191"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if (aspeed > ospeed && user.hp > user.totalhp/3) || user.hp > user.totalhp/2
        score += 60
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "192"
      if skill >= PBTrainerAI.mediumSkill
        if !target.item || !target.itemActive?
           score -= 90
        else
          score += 50
        end
      end
    #---------------------------------------------------------------------------
    when "193"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed && (aspeed * 2 / 3) < ospeed
        score -= 90
      elsif aspeed < ospeed && (aspeed * 3 / 2) > ospeed
        score += 90
      end
      score += user.stages[:DEFENSE] * 30
    #---------------------------------------------------------------------------
    when "194"
      score += 50 if user.statsRaised
    #---------------------------------------------------------------------------
    when "195"
      score -= 100 if @battle.field.terrain == :None
    #---------------------------------------------------------------------------
    when "196"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 40   # want to draw
        score += 40 if @battle.field.terrain == :Misty && user.affectedByTerrain?
      else
        score -= user.hp*100/user.totalhp
        score += 20 if @battle.field.terrain == :Misty && user.affectedByTerrain?
      end
    #---------------------------------------------------------------------------
    when "197"
      if target.pbHasOtherType?(:PSYCHIC)
        score -= 90
      elsif !target.canChangeType?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "198"
    #---------------------------------------------------------------------------
    when "199"
      score -= 100 if user.hp<=user.totalhp/2
    #---------------------------------------------------------------------------
    end
    return score
  end
end
