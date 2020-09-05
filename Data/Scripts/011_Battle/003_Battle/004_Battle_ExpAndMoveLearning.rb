class PokeBattle_Battle
  #=============================================================================
  # Gaining Experience
  #=============================================================================
  def pbGainExp
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
    # Go through each battler in turn to find the Pokémon that participated in
    # battle against it, and award those Pokémon Exp/EVs
    expAll = (hasConst?(PBItems,:EXPALL) && $PokemonBag.pbHasItem?(:EXPALL))
    p1 = pbParty(0)
    @battlers.each do |b|
      next unless b && b.opposes?   # Can only gain Exp from fainted foes
      next if b.participants.length==0
      next unless b.fainted? || b.captured
      # Count the number of participants
      numPartic = 0
      b.participants.each do |partic|
        next unless p1[partic] && p1[partic].able? && pbIsOwner?(0,partic)
        numPartic += 1
      end
      # Find which Pokémon have an Exp Share
      expShare = []
      if !expAll
        eachInTeam(0,0) do |pkmn,i|
          next if !pkmn.able?
          next if !isConst?(pkmn.item,PBItems,:EXPSHARE) &&
                  !isConst?(@initialItems[0][i],PBItems,:EXPSHARE)
          expShare.push(i)
        end
      end
      # Calculate EV and Exp gains for the participants
      if numPartic>0 || expShare.length>0 || expAll
        # Gain EVs and Exp for participants
        eachInTeam(0,0) do |pkmn,i|
          next if !pkmn.able?
          next unless b.participants.include?(i) || expShare.include?(i)
          pbGainEVsOne(i,b)
          pbGainExpOne(i,b,numPartic,expShare,expAll)
        end
        # Gain EVs and Exp for all other Pokémon because of Exp All
        if expAll
          showMessage = true
          eachInTeam(0,0) do |pkmn,i|
            next if !pkmn.able?
            next if b.participants.include?(i) || expShare.include?(i)
            pbDisplayPaused(_INTL("Your party Pokémon in waiting also got Exp. Points!")) if showMessage
            showMessage = false
            pbGainEVsOne(i,b)
            pbGainExpOne(i,b,numPartic,expShare,expAll,false)
          end
        end
      end
      # Clear the participants array
      b.participants = []
    end
  end

  def pbGainEVsOne(idxParty,defeatedBattler)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    evYield = defeatedBattler.pokemon.evYield
    # Num of effort points pkmn already has
    evTotal = 0
    PBStats.eachStat { |s| evTotal += pkmn.ev[s] }
    # Modify EV yield based on pkmn's held item
    if !BattleHandlers.triggerEVGainModifierItem(pkmn.item,pkmn,evYield)
      BattleHandlers.triggerEVGainModifierItem(@initialItems[0][idxParty],pkmn,evYield)
    end
    # Double EV gain because of Pokérus
    if pkmn.pokerusStage>=1   # Infected or cured
      evYield.collect! { |a| a*2 }
    end
    # Gain EVs for each stat in turn
    PBStats.eachStat do |s|
      evGain = evYield[s]
      # Can't exceed overall limit
      if evTotal+evGain>PokeBattle_Pokemon::EV_LIMIT
        evGain = PokeBattle_Pokemon::EV_LIMIT-evTotal
      end
      # Can't exceed individual stat limit
      if pkmn.ev[s]+evGain>PokeBattle_Pokemon::EV_STAT_LIMIT
        evGain = PokeBattle_Pokemon::EV_STAT_LIMIT-pkmn.ev[s]
      end
      # Add EV gain
      pkmn.ev[s] += evGain
      evTotal += evGain
    end
  end

  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growthRate = pkmn.growthrate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=PBExperience.pbGetMaxExperience(growthRate)
      pkmn.calcStats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.baseExp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a/(SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a/(SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.trainerID!=pbPlayer.id ||
                 (pkmn.language!=0 && pkmn.language!=pbPlayer.language))
    if isOutsider
      if pkmn.language!=0 && pkmn.language!=pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # Make sure Exp doesn't exceed the maximum
    expFinal = PBExperience.pbAddExperience(pkmn.exp,exp,growthRate)
    expGained = expFinal-pkmn.exp
    return if expGained<=0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = PBExperience.pbGetLevelFromExperience(expFinal,growthRate)
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
      return
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = PBExperience.pbGetStartExperience(curLevel,growthRate)
      levelMaxExp = PBExperience.pbGetStartExperience(curLevel+1,growthRate)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calcStats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calcStats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
    end
  end

  #=============================================================================
  # Learning a move
  #=============================================================================
  def pbLearnMove(idxParty,newMove)
    pkmn = pbParty(0)[idxParty]
    return if !pkmn
    pkmnName = pkmn.name
    battler = pbFindBattler(idxParty)
    moveName = PBMoves.getName(newMove)
    # Find a space for the new move in pkmn's moveset and learn it
    pkmn.moves.each_with_index do |m,i|
      return if m.id==newMove   # Already knows the new move
      next if m.id!=0           # Not a blank move slot
      pkmn.moves[i] = PBMove.new(newMove)
      battler.moves[i] = PokeBattle_Move.pbFromPBMove(self,pkmn.moves[i]) if battler
      pbDisplay(_INTL("{1} learned {2}!",pkmnName,moveName)) { pbSEPlay("Pkmn move learnt") }
      battler.pbCheckFormOnMovesetChange if battler
      return
    end
    # pkmn already knows four moves, need to forget one to learn newMove
    loop do
      pbDisplayPaused(_INTL("{1} wants to learn {2}, but it already knows four moves.",pkmnName,moveName))
      if pbDisplayConfirm(_INTL("Forget a move to learn {1}?",moveName))
        pbDisplayPaused(_INTL("Which move should be forgotten?"))
        forgetMove = @scene.pbForgetMove(pkmn,newMove)
        if forgetMove>=0
          oldMoveName = PBMoves.getName(pkmn.moves[forgetMove].id)
          pkmn.moves[forgetMove] = PBMove.new(newMove)   # Replaces current/total PP
          battler.moves[forgetMove] = PokeBattle_Move.pbFromPBMove(self,pkmn.moves[forgetMove]) if battler
          pbDisplayPaused(_INTL("1, 2, and... ... ... Ta-da!"))
          pbDisplayPaused(_INTL("{1} forgot how to use {2}. And...",pkmnName,oldMoveName))
          pbDisplay(_INTL("{1} learned {2}!",pkmnName,moveName)) { pbSEPlay("Pkmn move learnt") }
          battler.pbCheckFormOnMovesetChange if battler
          break
        elsif pbDisplayConfirm(_INTL("Give up on learning {1}?",moveName))
          pbDisplay(_INTL("{1} did not learn {2}.",pkmnName,moveName))
          break
        end
      elsif pbDisplayConfirm(_INTL("Give up on learning {1}?",moveName))
        pbDisplay(_INTL("{1} did not learn {2}.",pkmnName,moveName))
        break
      end
    end
  end
end
