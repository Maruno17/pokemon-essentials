class PokeBattle_AI
  alias __b__pbGetMoveScoreFunctions pbGetMoveScoreFunctions

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctions(score)
    score = __b__pbGetMoveScoreFunctions(score)
    case @move.function
    #---------------------------------------------------------------------------
    when "040"
      if !@target.pbCanConfuse?(@user,false)
        score -= 90
      else
        score += 30 if @target.stages[PBStats::SPATK]<0
      end
    #---------------------------------------------------------------------------
    when "041"
      if !@target.pbCanConfuse?(@user,false)
        score -= 90
      else
        score += 30 if @target.stages[PBStats::ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "042"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::ATTACK,@user)
          score -= 90
        else
          score += @target.stages[PBStats::ATTACK]*20
          if skill_check(AILevel.medium)
            hasPhysicalAttack = false
            @target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill_check(AILevel.high)
              score -= 90
            end
          end
        end
      else
        score += 20 if @target.stages[PBStats::ATTACK]>0
        if skill_check(AILevel.medium)
          hasPhysicalAttack = false
          @target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "043"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::DEFENSE,@user)
          score -= 90
        else
          score += @target.stages[PBStats::DEFENSE]*20
        end
      else
        score += 20 if @target.stages[PBStats::DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "044"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPEED,@user)
          score -= 90
        else
          score += @target.stages[PBStats::SPEED]*10
          if skill_check(AILevel.high)
            aspeed = pbRoughStat(@user,PBStats::SPEED)
            ospeed = pbRoughStat(@target,PBStats::SPEED)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if @user.stages[PBStats::SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "045"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPATK,@user)
          score -= 90
        else
          score += @user.stages[PBStats::SPATK]*20
          if skill_check(AILevel.medium)
            hasSpecicalAttack = false
            @target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill_check(AILevel.high)
              score -= 90
            end
          end
        end
      else
        score += 20 if @user.stages[PBStats::SPATK]>0
        if skill_check(AILevel.medium)
          hasSpecicalAttack = false
          @target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "046"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPDEF,@user)
          score -= 90
        else
          score += @target.stages[PBStats::SPDEF]*20
        end
      else
        score += 20 if @target.stages[PBStats::SPDEF]>0
      end
    #---------------------------------------------------------------------------
    when "047"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::ACCURACY,@user)
          score -= 90
        else
          score += @target.stages[PBStats::ACCURACY]*10
        end
      else
        score += 20 if @target.stages[PBStats::ACCURACY]>0
      end
    #---------------------------------------------------------------------------
    when "048"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::EVASION,@user)
          score -= 90
        else
          score += @target.stages[PBStats::EVASION]*10
        end
      else
        score += 20 if @target.stages[PBStats::EVASION]>0
      end
    #---------------------------------------------------------------------------
    when "049"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::EVASION,@user)
          score -= 90
        else
          score += @target.stages[PBStats::EVASION]*10
        end
      else
        score += 20 if @target.stages[PBStats::EVASION]>0
      end
      score += 30 if @target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                     @target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     @target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                     @target.pbOwnSide.effects[PBEffects::Mist]>0 ||
                     @target.pbOwnSide.effects[PBEffects::Safeguard]>0
      score -= 30 if @target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
                     @target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
                     @target.pbOwnSide.effects[PBEffects::StealthRock]
    #---------------------------------------------------------------------------
    when "04A"
      avg =  @target.stages[PBStats::ATTACK]*10
      avg += @target.stages[PBStats::DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "04B"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::ATTACK,@user)
          score -= 90
        else
          score += 40 if @user.turnCount==0
          score += @target.stages[PBStats::ATTACK]*20
          if skill_check(AILevel.medium)
            hasPhysicalAttack = false
            @target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill_check(AILevel.high)
              score -= 90
            end
          end
        end
      else
        score += 10 if @user.turnCount==0
        score += 20 if @target.stages[PBStats::ATTACK]>0
        if skill_check(AILevel.medium)
          hasPhysicalAttack = false
          @target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "04C"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::DEFENSE,@user)
          score -= 90
        else
          score += 40 if @user.turnCount==0
          score += @target.stages[PBStats::DEFENSE]*20
        end
      else
        score += 10 if @user.turnCount==0
        score += 20 if @target.stages[PBStats::DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "04D"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPEED,@user)
          score -= 90
        else
          score += 20 if @user.turnCount==0
          score += @target.stages[PBStats::SPEED]*20
          if skill_check(AILevel.high)
            aspeed = pbRoughStat(@user,PBStats::SPEED)
            ospeed = pbRoughStat(@target,PBStats::SPEED)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if @user.turnCount==0
        score += 30 if @target.stages[PBStats::SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "04E"
      if @user.gender==2 || @target.gender==2 || @user.gender==@target.gender ||
         @target.hasActiveAbility?(:OBLIVIOUS)
        score -= 90
      elsif @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPATK,@user)
          score -= 90
        else
          score += 40 if @user.turnCount==0
          score += @target.stages[PBStats::SPATK]*20
          if skill_check(AILevel.medium)
            hasSpecicalAttack = false
            @target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill_check(AILevel.high)
              score -= 90
            end
          end
        end
      else
        score += 10 if @user.turnCount==0
        score += 20 if @target.stages[PBStats::SPATK]>0
        if skill_check(AILevel.medium)
          hasSpecicalAttack = false
          @target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "04F"
      if @move.statusMove?
        if !@target.pbCanLowerStatStage?(PBStats::SPDEF,@user)
          score -= 90
        else
          score += 40 if @user.turnCount==0
          score += @target.stages[PBStats::SPDEF]*20
        end
      else
        score += 10 if @user.turnCount==0
        score += 20 if @target.stages[PBStats::SPDEF]>0
      end
    #---------------------------------------------------------------------------
    when "050"
      if @target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        avg = 0; anyChange = false
        PBStats.eachBattleStat do |s|
          next if @target.stages[s]==0
          avg += @target.stages[s]
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
      if skill_check(AILevel.medium)
        stages = 0
        @battle.eachBattler do |b|
          totalStages = 0
          PBStats.eachBattleStat { |s| totalStages += b.stages[s] }
          if b.opposes?(@user)
            stages += totalStages
          else
            stages -= totalStages
          end
        end
        score += stages*10
      end
    #---------------------------------------------------------------------------
    when "052"
      if skill_check(AILevel.medium)
        aatk = @user.stages[PBStats::ATTACK]
        aspa = @user.stages[PBStats::SPATK]
        oatk = @target.stages[PBStats::ATTACK]
        ospa = @target.stages[PBStats::SPATK]
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
      if skill_check(AILevel.medium)
        adef = @user.stages[PBStats::DEFENSE]
        aspd = @user.stages[PBStats::SPDEF]
        odef = @target.stages[PBStats::DEFENSE]
        ospd = @target.stages[PBStats::SPDEF]
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
      if skill_check(AILevel.medium)
        userStages = 0; targetStages = 0
        PBStats.eachBattleStat do |s|
          userStages   += @user.stages[s]
          targetStages += @target.stages[s]
        end
        score += (targetStages-userStages)*10
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "055"
      if skill_check(AILevel.medium)
        equal = true
        PBStats.eachBattleStat do |s|
          stagediff = @target.stages[s]-@user.stages[s]
          score += stagediff*10
          equal = false if stagediff!=0
        end
        score -= 80 if equal
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "056"
      score -= 80 if @user.pbOwnSide.effects[PBEffects::Mist]>0
    #---------------------------------------------------------------------------
    when "057"
      if skill_check(AILevel.medium)
        aatk = pbRoughStat(@user,PBStats::ATTACK)
        adef = pbRoughStat(@user,PBStats::DEFENSE)
        if aatk==adef ||
           @user.effects[PBEffects::PowerTrick]   # No flip-flopping
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
      if skill_check(AILevel.medium)
        aatk   = pbRoughStat(@user,PBStats::ATTACK)
        aspatk = pbRoughStat(@user,PBStats::SPATK)
        oatk   = pbRoughStat(@target,PBStats::ATTACK)
        ospatk = pbRoughStat(@target,PBStats::SPATK)
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
      if skill_check(AILevel.medium)
        adef   = pbRoughStat(@user,PBStats::DEFENSE)
        aspdef = pbRoughStat(@user,PBStats::SPDEF)
        odef   = pbRoughStat(@target,PBStats::DEFENSE)
        ospdef = pbRoughStat(@target,PBStats::SPDEF)
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
      if @target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif @user.hp>=(@user.hp+@target.hp)/2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "05B"
      score -= 90 if @user.pbOwnSide.effects[PBEffects::Tailwind]>0
    #---------------------------------------------------------------------------
    when "05C"
      moveBlacklist = [
        "002",   # Struggle
        "014",   # Chatter
        "05C",   # Mimic
        "05D",   # Sketch
        "0B6"    # Metronome
      ]
      if @user.effects[PBEffects::Transform] || !@target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(@target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        @user.eachMove do |m|
          next if m != @target.lastRegularMoveUsed
          score -= 90
          break
        end
      end
    #---------------------------------------------------------------------------
    when "05D"
      moveBlacklist = [
        "002",   # Struggle
        "014",   # Chatter
        "05D"    # Sketch
      ]
      if @user.effects[PBEffects::Transform] || !@target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(@target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        @user.eachMove do |m|
          next if m != @target.lastRegularMoveUsed
          score -= 90   # User already knows the move that will be Sketched
          break
        end
      end
    #---------------------------------------------------------------------------
    when "05E"
      if [:MULTITYPE, :RKSSYSTEM].include?(@user.ability_id)
        score -= 90
      else
        types = []
        @user.eachMove do |m|
          next if m.id==@id
          next if PBTypes.isPseudoType?(m.type)
          next if @user.pbHasType?(m.type)
          types.push(m.type) if !types.include?(m.type)
        end
        score -= 90 if types.length==0
      end
    #---------------------------------------------------------------------------
    when "05F"
      if [:MULTITYPE, :RKSSYSTEM].include?(@user.ability_id)
        score -= 90
      elsif !@target.lastMoveUsed ||
         PBTypes.isPseudoType?(GameData::Move.get(@target.lastMoveUsed).type)
        score -= 90
      else
        aType = nil
        @target.eachMove do |m|
          next if m.id!=@target.lastMoveUsed
          aType = m.pbCalcType(@user)
          break
        end
        if aType
          types = []
          GameData::Type.each do |t|
            types.push(t.id) if !@user.pbHasType?(t.id) && PBTypes.resistant?(aType, t.id)
          end
          score -= 90 if types.length==0
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "060"
      if [:MULTITYPE, :RKSSYSTEM].include?(@user.ability_id)
        score -= 90
      elsif skill_check(AILevel.medium)
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
        type = envtypes[@battle.environment]
        score -= 90 if @user.pbHasType?(type)
      end
    #---------------------------------------------------------------------------
    when "061"
      if @target.effects[PBEffects::Substitute]>0 ||
         [:MULTITYPE, :RKSSYSTEM].include?(@target.ability_id)
        score -= 90
      elsif @target.pbHasType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "062"
      if [:MULTITYPE, :RKSSYSTEM].include?(@user.ability_id)
        score -= 90
      elsif @user.pbHasType?(@target.type1) &&
         @user.pbHasType?(@target.type2) &&
         @target.pbHasType?(@user.type1) &&
         @target.pbHasType?(@user.type2)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "063"
      if @target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill_check(AILevel.medium)
        if [:MULTITYPE, :RKSSYSTEM, :SIMPLE, :TRUANT].include?(@target.ability_id)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "064"
      if @target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill_check(AILevel.medium)
        if [:INSOMNIA, :MULTITYPE, :RKSSYSTEM, :TRUANT].include?(@target.ability_id)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "065"
      score -= 40   # don't prefer this move
      if skill_check(AILevel.medium)
        if !@target.ability || @user.ability_id == @target.ability_id ||
           [:MULTITYPE, :RKSSYSTEM].include?(@user.ability_id) ||
           [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
            :TRACE, :WONDERGUARD, :ZENMODE].include?(@target.ability_id)
          score -= 90
        end
      end
      if skill_check(AILevel.high) && @user.opposes?(@target)
        score -= 90 if [:SLOWSTART, :TRUANT].include?(@target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "066"
      score -= 40   # don't prefer this move
      if @target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill_check(AILevel.medium)
        if !@user.ability || @user.ability_id == @target.ability_id ||
          [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(@target.ability_id) ||
          [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
           :TRACE, :ZENMODE].include?(@user.ability_id)
          score -= 90
        end
        if skill_check(AILevel.high) && @user.opposes?(@target)
          score += 90 if [:SLOWSTART, :TRUANT].include?(@user.ability_id)
        end
      end
    #---------------------------------------------------------------------------
    when "067"
      score -= 40   # don't prefer this move
      if skill_check(AILevel.medium)
        if (!@user.ability && !@target.ability) ||
           @user.ability_id == @target.ability_id ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(@user.ability_id) ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(@target.ability_id)
          score -= 90
        end
      end
      if skill_check(AILevel.high) && @user.opposes?(@target)
        score -= 90 if [:SLOWSTART, :TRUANT].include?(@target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "068"
      if @target.effects[PBEffects::Substitute]>0 ||
         @target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill_check(AILevel.high)
        score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(@target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "069"
      score -= 70
    #---------------------------------------------------------------------------
    when "06A"
      if @target.hp<=20
        score += 80
      elsif @target.level>=25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "06B"
      score += 80 if @target.hp<=40
    #---------------------------------------------------------------------------
    when "06C"
      score -= 50
      score += @target.hp*100/@target.totalhp
    #---------------------------------------------------------------------------
    when "06D"
      score += 80 if @target.hp<=@user.level
    #---------------------------------------------------------------------------
    when "06E"
      if @user.hp>=@target.hp
        score -= 90
      elsif @user.hp<@target.hp/2
        score += 50
      end
    #---------------------------------------------------------------------------
    when "06F"
      score += 30 if @target.hp<=@user.level
    #---------------------------------------------------------------------------
    when "070"
      score -= 90 if @target.hasActiveAbility?(:STURDY)
      score -= 90 if @target.level>@user.level
    #---------------------------------------------------------------------------
    when "071"
      if @target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(@user,PBStats::ATTACK)
        spatk  = pbRoughStat(@user,PBStats::SPATK)
        if attack*1.5<spatk
          score -= 60
        elsif skill_check(AILevel.medium) && @target.lastMoveUsed
          moveData = GameData::Move.get(@target.lastMoveUsed)
          if moveData.base_damage > 0 &&
             (MOVE_CATEGORY_PER_MOVE && moveData.category == 0) ||
             (!MOVE_CATEGORY_PER_MOVE && PBTypes.isPhysicalType?(moveData.type))
            score -= 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "072"
      if @target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(@user,PBStats::ATTACK)
        spatk  = pbRoughStat(@user,PBStats::SPATK)
        if attack>spatk*1.5
          score -= 60
        elsif skill_check(AILevel.medium) && @target.lastMoveUsed
          moveData = GameData::Move.get(@target.lastMoveUsed)
          if moveData.base_damage > 0 &&
             (MOVE_CATEGORY_PER_MOVE && moveData.category == 1) ||
             (!MOVE_CATEGORY_PER_MOVE && !PBTypes.isSpecialType?(moveData.type))
            score -= 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "073"
      score -= 90 if @target.effects[PBEffects::HyperBeam]>0
    #---------------------------------------------------------------------------
    when "074"
      @target.eachAlly do |b|
        next if !b.near?(@target)
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
      if skill_check(AILevel.high)
        score += 30 if !@target.hasActiveAbility?(:INNERFOCUS) &&
                       @target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "079"
    #---------------------------------------------------------------------------
    when "07A"
    #---------------------------------------------------------------------------
    when "07B"
    #---------------------------------------------------------------------------
    when "07C"
      score -= 20 if @target.status==PBStatuses::PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "07D"
      score -= 20 if @target.status==PBStatuses::SLEEP &&   # Will cure status
                     @target.statusCount>1
    #---------------------------------------------------------------------------
    when "07E"
    #---------------------------------------------------------------------------
    when "07F"
    #---------------------------------------------------------------------------
    end
    return score
  end
end
