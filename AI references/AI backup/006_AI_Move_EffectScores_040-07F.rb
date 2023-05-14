class PokeBattle_AI
  alias __b__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    score = __b__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    #---------------------------------------------------------------------------
    when "040"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[PBStats::SPATK]<0
      end
    #---------------------------------------------------------------------------
    when "041"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[PBStats::ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "042"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::ATTACK,user)
          score -= 90
        else
          score += target.stages[PBStats::ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if target.stages[PBStats::ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "043"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::DEFENSE,user)
          score -= 90
        else
          score += target.stages[PBStats::DEFENSE]*20
        end
      else
        score += 20 if target.stages[PBStats::DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "044"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPEED,user)
          score -= 90
        else
          score += target.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,PBStats::SPEED,skill)
            ospeed = pbRoughStat(target,PBStats::SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[PBStats::SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "045"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPATK,user)
          score -= 90
        else
          score += user.stages[PBStats::SPATK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[PBStats::SPATK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "046"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPDEF,user)
          score -= 90
        else
          score += target.stages[PBStats::SPDEF]*20
        end
      else
        score += 20 if target.stages[PBStats::SPDEF]>0
      end
    #---------------------------------------------------------------------------
    when "047"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::ACCURACY,user)
          score -= 90
        else
          score += target.stages[PBStats::ACCURACY]*10
        end
      else
        score += 20 if target.stages[PBStats::ACCURACY]>0
      end
    #---------------------------------------------------------------------------
    when "048"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::EVASION,user)
          score -= 90
        else
          score += target.stages[PBStats::EVASION]*10
        end
      else
        score += 20 if target.stages[PBStats::EVASION]>0
      end
    #---------------------------------------------------------------------------
    when "049"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::EVASION,user)
          score -= 90
        else
          score += target.stages[PBStats::EVASION]*10
        end
      else
        score += 20 if target.stages[PBStats::EVASION]>0
      end
      score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                     target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                     target.pbOwnSide.effects[PBEffects::Mist]>0 ||
                     target.pbOwnSide.effects[PBEffects::Safeguard]>0
      score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
                     target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
                     target.pbOwnSide.effects[PBEffects::StealthRock]
    #---------------------------------------------------------------------------
    when "04A"
      avg =  target.stages[PBStats::ATTACK]*10
      avg += target.stages[PBStats::DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "04B"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::ATTACK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[PBStats::ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[PBStats::ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "04C"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::DEFENSE,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[PBStats::DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[PBStats::DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "04D"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPEED,user)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score += target.stages[PBStats::SPEED]*20
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,PBStats::SPEED,skill)
            ospeed = pbRoughStat(target,PBStats::SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if target.stages[PBStats::SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "04E"
      if user.gender==2 || target.gender==2 || user.gender==target.gender ||
         target.hasActiveAbility?(:OBLIVIOUS)
        score -= 90
      elsif move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPATK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[PBStats::SPATK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[PBStats::SPATK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "04F"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(PBStats::SPDEF,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[PBStats::SPDEF]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[PBStats::SPDEF]>0
      end
    #---------------------------------------------------------------------------
    when "050"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        avg = 0; anyChange = false
        PBStats.eachBattleStat do |s|
          next if target.stages[s]==0
          avg += target.stages[s]
          anyChange = true
        end
        if anyChange
          score += avg*10
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "051"
      if skill>=PBTrainerAI.mediumSkill
        stages = 0
        @battle.eachBattler do |b|
          totalStages = 0
          PBStats.eachBattleStat { |s| totalStages += b.stages[s] }
          if b.opposes?(user)
            stages += totalStages
          else
            stages -= totalStages
          end
        end
        score += stages*10
      end
    #---------------------------------------------------------------------------
    when "052"
      if skill>=PBTrainerAI.mediumSkill
        aatk = user.stages[PBStats::ATTACK]
        aspa = user.stages[PBStats::SPATK]
        oatk = target.stages[PBStats::ATTACK]
        ospa = target.stages[PBStats::SPATK]
        if aatk>=oatk && aspa>=ospa
          score -= 80
        else
          score += (oatk-aatk)*10
          score += (ospa-aspa)*10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "053"
      if skill>=PBTrainerAI.mediumSkill
        adef = user.stages[PBStats::DEFENSE]
        aspd = user.stages[PBStats::SPDEF]
        odef = target.stages[PBStats::DEFENSE]
        ospd = target.stages[PBStats::SPDEF]
        if adef>=odef && aspd>=ospd
          score -= 80
        else
          score += (odef-adef)*10
          score += (ospd-aspd)*10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "054"
      if skill>=PBTrainerAI.mediumSkill
        userStages = 0; targetStages = 0
        PBStats.eachBattleStat do |s|
          userStages   += user.stages[s]
          targetStages += target.stages[s]
        end
        score += (targetStages-userStages)*10
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "055"
      if skill>=PBTrainerAI.mediumSkill
        equal = true
        PBStats.eachBattleStat do |s|
          stagediff = target.stages[s]-user.stages[s]
          score += stagediff*10
          equal = false if stagediff!=0
        end
        score -= 80 if equal
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "056"
      score -= 80 if user.pbOwnSide.effects[PBEffects::Mist]>0
    #---------------------------------------------------------------------------
    when "057"
      if skill>=PBTrainerAI.mediumSkill
        aatk = pbRoughStat(user,PBStats::ATTACK,skill)
        adef = pbRoughStat(user,PBStats::DEFENSE,skill)
        if aatk==adef ||
           user.effects[PBEffects::PowerTrick]   # No flip-flopping
          score -= 90
        elsif adef>aatk   # Prefer a higher Attack
          score += 30
        else
          score -= 30
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "058"
      if skill>=PBTrainerAI.mediumSkill
        aatk   = pbRoughStat(user,PBStats::ATTACK,skill)
        aspatk = pbRoughStat(user,PBStats::SPATK,skill)
        oatk   = pbRoughStat(target,PBStats::ATTACK,skill)
        ospatk = pbRoughStat(target,PBStats::SPATK,skill)
        if aatk<oatk && aspatk<ospatk
          score += 50
        elsif aatk+aspatk<oatk+ospatk
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "059"
      if skill>=PBTrainerAI.mediumSkill
        adef   = pbRoughStat(user,PBStats::DEFENSE,skill)
        aspdef = pbRoughStat(user,PBStats::SPDEF,skill)
        odef   = pbRoughStat(target,PBStats::DEFENSE,skill)
        ospdef = pbRoughStat(target,PBStats::SPDEF,skill)
        if adef<odef && aspdef<ospdef
          score += 50
        elsif adef+aspdef<odef+ospdef
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "05A"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp>=(user.hp+target.hp)/2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "05B"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Tailwind]>0
    #---------------------------------------------------------------------------
    when "05C"
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05C",   # Mimic
         "05D",   # Sketch
         "0B6"    # Metronome
      ]
      lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
      if user.effects[PBEffects::Transform] ||
         target.lastRegularMoveUsed<=0 ||
         moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
         isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
        score -= 90
      end
      user.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed
        score -= 90
        break
      end
    #---------------------------------------------------------------------------
    when "05D"
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05D"    # Sketch
      ]
      lastMoveData = pbGetMoveData(target.lastRegularMoveUsed)
      if user.effects[PBEffects::Transform] ||
         target.lastRegularMoveUsed<=0 ||
         moveBlacklist.include?(lastMoveData[MOVE_FUNCTION_CODE]) ||
         isConst?(lastMoveData[MOVE_TYPE],PBTypes,:SHADOW)
        score -= 90
      end
      user.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed
        score -= 90   # User already knows the move that will be Sketched
        break
      end
    #---------------------------------------------------------------------------
    when "05E"
      if isConst?(user.ability,PBAbilities,:MULTITYPE) ||
         isConst?(user.ability,PBAbilities,:RKSSYSTEM)
        score -= 90
      else
        types = []
        user.eachMove do |m|
          next if m.id==@id
          next if PBTypes.isPseudoType?(m.type)
          next if user.pbHasType?(m.type)
          types.push(m.type) if !types.include?(m.type)
        end
        score -= 90 if types.length==0
      end
    #---------------------------------------------------------------------------
    when "05F"
      if isConst?(user.ability,PBAbilities,:MULTITYPE) ||
         isConst?(user.ability,PBAbilities,:RKSSYSTEM)
        score -= 90
      elsif target.lastMoveUsed<=0 ||
         PBTypes.isPseudoType?(pbGetMoveData(target.lastMoveUsed,MOVE_TYPE))
        score -= 90
      else
        aType = -1
        target.eachMove do |m|
          next if m.id!=target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if aType<0
          score -= 90
        else
          types = []
          for i in 0..PBTypes.maxValue
            next if user.pbHasType?(i)
            types.push(i) if PBTypes.resistant?(aType,i)
          end
          score -= 90 if types.length==0
        end
      end
    #---------------------------------------------------------------------------
    when "060"
      if isConst?(user.ability,PBAbilities,:MULTITYPE) ||
         isConst?(user.ability,PBAbilities,:RKSSYSTEM)
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        envtypes = [
           :NORMAL, # None
           :GRASS,  # Grass
           :GRASS,  # Tall grass
           :WATER,  # Moving water
           :WATER,  # Still water
           :WATER,  # Underwater
           :ROCK,   # Rock
           :ROCK,   # Cave
           :GROUND  # Sand
        ]
        type = envtypes[@environment]
        score -= 90 if user.pbHasType?(type)
      end
    #---------------------------------------------------------------------------
    when "061"
      if target.effects[PBEffects::Substitute]>0 ||
         isConst?(target.ability,PBAbilities,:MULTITYPE) ||
         isConst?(target.ability,PBAbilities,:RKSSYSTEM)
        score -= 90
      elsif target.pbHasType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "062"
      if isConst?(user.ability,PBAbilities,:MULTITYPE) ||
         isConst?(user.ability,PBAbilities,:RKSSYSTEM)
        score -= 90
      elsif user.pbHasType?(target.type1) &&
         user.pbHasType?(target.type2) &&
         target.pbHasType?(user.type1) &&
         target.pbHasType?(user.type2)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "063"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if isConst?(target.ability,PBAbilities,:MULTITYPE) ||
           isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:SIMPLE) ||
           isConst?(target.ability,PBAbilities,:TRUANT)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "064"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if isConst?(target.ability,PBAbilities,:INSOMNIA) ||
           isConst?(target.ability,PBAbilities,:MULTITYPE) ||
           isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:TRUANT)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "065"
      score -= 40   # don't prefer this move
      if skill>=PBTrainerAI.mediumSkill
        if target.ability==0 || user.ability==target.ability ||
           isConst?(user.ability,PBAbilities,:MULTITYPE) ||
           isConst?(user.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:FLOWERGIFT) ||
           isConst?(target.ability,PBAbilities,:FORECAST) ||
           isConst?(target.ability,PBAbilities,:ILLUSION) ||
           isConst?(target.ability,PBAbilities,:IMPOSTER) ||
           isConst?(target.ability,PBAbilities,:MULTITYPE) ||
           isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:TRACE) ||
           isConst?(target.ability,PBAbilities,:WONDERGUARD) ||
           isConst?(target.ability,PBAbilities,:ZENMODE)
          score -= 90
        end
      end
      if skill>=PBTrainerAI.highSkill
        if isConst?(target.ability,PBAbilities,:TRUANT) &&
           user.opposes?(target)
          score -= 90
        elsif isConst?(target.ability,PBAbilities,:SLOWSTART) &&
           user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "066"
      score -= 40   # don't prefer this move
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if user.ability==0 || user.ability==target.ability ||
           isConst?(target.ability,PBAbilities,:MULTITYPE) ||
           isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:TRUANT) ||
           isConst?(user.ability,PBAbilities,:FLOWERGIFT) ||
           isConst?(user.ability,PBAbilities,:FORECAST) ||
           isConst?(user.ability,PBAbilities,:ILLUSION) ||
           isConst?(user.ability,PBAbilities,:IMPOSTER) ||
           isConst?(user.ability,PBAbilities,:MULTITYPE) ||
           isConst?(user.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(user.ability,PBAbilities,:TRACE) ||
           isConst?(user.ability,PBAbilities,:ZENMODE)
          score -= 90
        end
        if skill>=PBTrainerAI.highSkill
          if isConst?(user.ability,PBAbilities,:TRUANT) &&
             user.opposes?(target)
            score += 90
          elsif isConst?(user.ability,PBAbilities,:SLOWSTART) &&
             user.opposes?(target)
            score += 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "067"
      score -= 40   # don't prefer this move
      if skill>=PBTrainerAI.mediumSkill
        if (user.ability==0 && target.ability==0) ||
           user.ability==target.ability ||
           isConst?(user.ability,PBAbilities,:ILLUSION) ||
           isConst?(user.ability,PBAbilities,:MULTITYPE) ||
           isConst?(user.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(user.ability,PBAbilities,:WONDERGUARD) ||
           isConst?(target.ability,PBAbilities,:ILLUSION) ||
           isConst?(target.ability,PBAbilities,:MULTITYPE) ||
           isConst?(target.ability,PBAbilities,:RKSSYSTEM) ||
           isConst?(target.ability,PBAbilities,:WONDERGUARD)
          score -= 90
        end
      end
      if skill>=PBTrainerAI.highSkill
        if isConst?(target.ability,PBAbilities,:TRUANT) &&
           user.opposes?(target)
          score -= 90
        elsif isConst?(target.ability,PBAbilities,:SLOWSTART) &&
          user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "068"
      if target.effects[PBEffects::Substitute]>0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill>=PBTrainerAI.highSkill
        score -= 90 if isConst?(target.ability,PBAbilities,:MULTITYPE)
        score -= 90 if isConst?(target.ability,PBAbilities,:RKSSYSTEM)
        score -= 90 if isConst?(target.ability,PBAbilities,:SLOWSTART)
        score -= 90 if isConst?(target.ability,PBAbilities,:TRUANT)
      end
    #---------------------------------------------------------------------------
    when "069"
      score -= 70
    #---------------------------------------------------------------------------
    when "06A"
      if target.hp<=20
        score += 80
      elsif target.level>=25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "06B"
      score += 80 if target.hp<=40
    #---------------------------------------------------------------------------
    when "06C"
      score -= 50
      score += target.hp*100/target.totalhp
    #---------------------------------------------------------------------------
    when "06D"
      score += 80 if target.hp<=user.level
    #---------------------------------------------------------------------------
    when "06E"
      if user.hp>=target.hp
        score -= 90
      elsif user.hp<target.hp/2
        score += 50
      end
    #---------------------------------------------------------------------------
    when "06F"
      score += 30 if target.hp<=user.level
    #---------------------------------------------------------------------------
    when "070"
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level>user.level
    #---------------------------------------------------------------------------
    when "071"
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,PBStats::ATTACK,skill)
        spatk  = pbRoughStat(user,PBStats::SPATK,skill)
        if attack*1.5<spatk
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed>0
          moveData = pbGetMoveData(target.lastMoveUsed)
          if moveData[MOVE_BASE_DAMAGE]>0 &&
             (MOVE_CATEGORY_PER_MOVE && moveData[MOVE_CATEGORY]==0) ||
             (!MOVE_CATEGORY_PER_MOVE && PBTypes.isPhysicalType?(moveData[MOVE_TYPE]))
            score -= 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "072"
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,PBStats::ATTACK,skill)
        spatk  = pbRoughStat(user,PBStats::SPATK,skill)
        if attack>spatk*1.5
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed>0
          moveData = pbGetMoveData(target.lastMoveUsed)
          if moveData[MOVE_BASE_DAMAGE]>0 &&
             (MOVE_CATEGORY_PER_MOVE && moveData[MOVE_CATEGORY]==1) ||
             (!MOVE_CATEGORY_PER_MOVE && !PBTypes.isSpecialType?(moveData[MOVE_TYPE]))
            score -= 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "073"
      score -= 90 if target.effects[PBEffects::HyperBeam]>0
    #---------------------------------------------------------------------------
    when "074"
      target.eachAlly do |b|
        next if !b.near?(target)
        score += 10
      end
    #---------------------------------------------------------------------------
    when "075"
    #---------------------------------------------------------------------------
    when "076"
    #---------------------------------------------------------------------------
    when "077"
    #---------------------------------------------------------------------------
    when "078"
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "079"
    #---------------------------------------------------------------------------
    when "07A"
    #---------------------------------------------------------------------------
    when "07B"
    #---------------------------------------------------------------------------
    when "07C"
      score -= 20 if target.status==PBStatuses::PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "07D"
      score -= 20 if target.status==PBStatuses::SLEEP &&   # Will cure status
                     target.statusCount>1
    #---------------------------------------------------------------------------
    when "07E"
    #---------------------------------------------------------------------------
    when "07F"
    #---------------------------------------------------------------------------
    end
    return score
  end
end
