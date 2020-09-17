class PokeBattle_Battle
  #=============================================================================
  # Choosing Pokémon to switch
  #=============================================================================
  # Checks whether the replacement Pokémon (at party index idxParty) can enter
  # battle.
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitchLax?(idxBattler,idxParty,partyScene=nil)
    return true if idxParty<0
    party = pbParty(idxBattler)
    return false if idxParty>=party.length
    return false if !party[idxParty]
    if party[idxParty].egg?
      partyScene.pbDisplay(_INTL("An Egg can't battle!")) if partyScene
      return false
    end
    if !pbIsOwner?(idxBattler,idxParty)
      owner = pbGetOwnerFromPartyIndex(idxBattler,idxParty)
      partyScene.pbDisplay(_INTL("You can't switch {1}'s Pokémon with one of yours!",
        owner.name)) if partyScene
      return false
    end
    if party[idxParty].fainted?
      partyScene.pbDisplay(_INTL("{1} has no energy left to battle!",
         party[idxParty].name)) if partyScene
      return false
    end
    if pbFindBattler(idxParty,idxBattler)
      partyScene.pbDisplay(_INTL("{1} is already in battle!",
         party[idxParty].name)) if partyScene
      return false
    end
    return true
  end

  # Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out (and that its replacement at party index idxParty can switch in).
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitch?(idxBattler,idxParty=-1,partyScene=nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    eachSameSideBattler(idxBattler) do |b|
      next if choices[b.index][0]!=:SwitchOut || choices[b.index][1]!=idxParty
      partyScene.pbDisplay(_INTL("{1} has already been selected.",
         pbParty(idxBattler)[idxParty].name)) if partyScene
      return false
    end
    # Check whether battler can switch out
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive?
      if BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability,battler,self)
        return true
      end
    end
    if battler.itemActive?
      if BattleHandlers.triggerCertainSwitchingUserItem(battler.item,battler,self)
        return true
      end
    end
    # Other certain switching effects
    return true if NEWEST_BATTLE_MECHANICS && battler.pbHasType?(:GHOST)
    # Other certain trapping effects
    if battler.effects[PBEffects::OctolockUser]>=0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    if battler.effects[PBEffects::JawLock]
      @battlers.each do |b|
        if (battler.effects[PBEffects::JawLockUser] == b.index) && !b.fainted?
          partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
          return false
        end
      end
    end   
    if battler.effects[PBEffects::Trapping]>0 ||
       battler.effects[PBEffects::MeanLook]>=0 ||
       battler.effects[PBEffects::Ingrain] ||
       battler.effects[PBEffects::NoRetreat] ||
       @field.effects[PBEffects::FairyLock]>0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    # Trapping abilities/items
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.abilityName)) if partyScene
        return false
      end
    end
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.itemName)) if partyScene
        return false
      end
    end
    return true
  end

  def pbCanChooseNonActive?(idxBattler)
    pbParty(idxBattler).each_with_index do |_pkmn,i|
      return true if pbCanSwitchLax?(idxBattler,i)
    end
    return false
  end

  def pbRegisterSwitch(idxBattler,idxParty)
    return false if !pbCanSwitch?(idxBattler,idxParty)
    @choices[idxBattler][0] = :SwitchOut
    @choices[idxBattler][1] = idxParty   # Party index of Pokémon to switch in
    @choices[idxBattler][2] = nil
    return true
  end

  #=============================================================================
  # Open the party screen and potentially pick a replacement Pokémon (or AI
  # chooses replacement)
  #=============================================================================
  # Open party screen and potentially choose a Pokémon to switch with. Used in
  # all instances where the party screen is opened.
  def pbPartyScreen(idxBattler,checkLaxOnly=false,canCancel=false,shouldRegister=false)
    ret = -1
    @scene.pbPartyScreen(idxBattler,canCancel) { |idxParty,partyScene|
      if checkLaxOnly
        next false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
      else
        next false if !pbCanSwitch?(idxBattler,idxParty,partyScene)
      end
      if shouldRegister
        next false if idxParty<0 || !pbRegisterSwitch(idxBattler,idxParty)
      end
      ret = idxParty
      next true
    }
    return ret
  end

  # For choosing a replacement Pokémon when prompted in the middle of other
  # things happening (U-turn, Baton Pass, in def pbSwitch).
  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    return pbPartyScreen(idxBattler,checkLaxOnly,canCancel) if pbOwnedByPlayer?(idxBattler)
    return @battleAI.pbDefaultChooseNewEnemy(idxBattler,pbParty(idxBattler))
  end

  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws=false)
    return if @decision>0 && !favorDraws
    return if @decision==5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if wildBattle? && opposes?(idxBattler)   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && @switchStyle && trainerBattle? && pbSideSize(0)==1 &&
             opposes?(idxBattler) && !@battlers[0].fainted? && pbCanChooseNonActive?(0) &&
             @battlers[0].effects[PBEffects::Outrage]==0
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if isConst?(enemyParty[idxPartyNew].ability,PBAbilities,:ILLUSION)
              idxPartyForName = pbGetLastPokeInTeam(idxBattler)
            end
            if pbDisplayConfirm(_INTL("{1} is about to send in {2}. Will you switch your Pokémon?",
               opponent.fullname,enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0,false,true)
              if idxPlayerPartyNew>=0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0,idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle?   # Player switches in in a trainer battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          switch = false
          if !pbDisplayConfirm(_INTL("Use next Pokémon?"))
            switch = (pbRun(idxBattler,true)<=0)
          else
            switch = true
          end
          if switch
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length==0
      pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switched.include?(b.index)
      end
    end
  end

  def pbGetReplacementPokemonIndex(idxBattler,random=false)
    if random
      return -1 if !pbCanSwitch?(idxBattler)   # Can battler switch out?
      choices = []   # Find all Pokémon that can switch in
      eachInTeamFromBattlerIndex(idxBattler) do |_pkmn,i|
        choices.push(i) if pbCanSwitchLax?(idxBattler,i)
      end
      return -1 if choices.length==0
      return choices[pbRandom(choices.length)]
    else
      return pbSwitchInBetween(idxBattler,true)
    end
  end

  # Actually performs the recalling and sending out in all situations.
  def pbRecallAndReplace(idxBattler,idxParty,batonPass=false)
    @scene.pbRecall(idxBattler) if !@battlers[idxBattler].fainted?
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    @scene.pbShowPartyLineup(idxBattler&1) if pbSideSize(idxBattler)==1
    pbMessagesOnReplace(idxBattler,idxParty)
    pbReplace(idxBattler,idxParty,batonPass)
  end

  def pbMessageOnRecall(battler)
    if battler.pbOwnedByPlayer?
      if battler.hp<=battler.totalhp/4
        pbDisplayBrief(_INTL("Good job, {1}! Come back!",battler.name))
      elsif battler.hp<=battler.totalhp/2
        pbDisplayBrief(_INTL("OK, {1}! Come back!",battler.name))
      elsif battler.turnCount>=5
        pbDisplayBrief(_INTL("{1}, that’s enough! Come back!",battler.name))
      elsif battler.turnCount>=2
        pbDisplayBrief(_INTL("{1}, come back!",battler.name))
      else
        pbDisplayBrief(_INTL("{1}, switch out! Come back!",battler.name))
      end
    else
      owner = pbGetOwnerName(b.index)
      pbDisplayBrief(_INTL("{1} withdrew {2}!",owner,battler.name))
    end
  end

  # Only called from def pbRecallAndReplace and Battle Arena's def pbSwitch.
  def pbMessagesOnReplace(idxBattler,idxParty)
    party = pbParty(idxBattler)
    newPkmnName = party[idxParty].name
    if isConst?(party[idxParty].ability,PBAbilities,:ILLUSION)
      newPkmnName = party[pbLastInTeam(idxBattler)].name
    end
    if pbOwnedByPlayer?(idxBattler)
      opposing = @battlers[idxBattler].pbDirectOpposing
      if opposing.fainted? || opposing.hp==opposing.totalhp
        pbDisplayBrief(_INTL("You're in charge, {1}!",newPkmnName))
      elsif opposing.hp>=opposing.totalhp/2
        pbDisplayBrief(_INTL("Go for it, {1}!",newPkmnName))
      elsif opposing.hp>=opposing.totalhp/4
        pbDisplayBrief(_INTL("Just a little more! Hang in there, {1}!",newPkmnName))
      else
        pbDisplayBrief(_INTL("Your opponent's weak! Get 'em, {1}!",newPkmnName))
      end
    else
      owner = pbGetOwnerFromBattlerIndex(idxBattler)
      pbDisplayBrief(_INTL("{1} sent out {2}!",owner.fullname,newPkmnName))
    end
  end

  # Only called from def pbRecallAndReplace above and Battle Arena's def
  # pbSwitch.
  def pbReplace(idxBattler,idxParty,batonPass=false)
    party = pbParty(idxBattler)
    idxPartyOld = @battlers[idxBattler].pokemonIndex
    # Initialise the new Pokémon
    @battlers[idxBattler].pbInitialize(party[idxParty],idxParty,batonPass)
    # Reorder the party for this battle
    partyOrder = pbPartyOrder(idxBattler)
    partyOrder[idxParty],partyOrder[idxPartyOld] = partyOrder[idxPartyOld],partyOrder[idxParty]
    # Send out the new Pokémon
    pbSendOut([[idxBattler,party[idxParty]]])
#    pbCalculatePriority(false,[idxBattler]) if NEWEST_BATTLE_MECHANICS
  end

  # Called from def pbReplace above and at the start of battle.
  # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
  def pbSendOut(sendOuts,startBattle=false)
    sendOuts.each { |b| @peer.pbOnEnteringBattle(self,b[1]) }
    @scene.pbSendOutBattlers(sendOuts,startBattle)
    sendOuts.each do |b|
      @scene.pbResetMoveIndex(b[0])
      pbSetSeen(@battlers[b[0]])
      @usedInBattle[b[0]&1][b[0]/2] = true
    end
  end

  #=============================================================================
  # Effects upon a Pokémon entering battle
  #=============================================================================
  # Called at the start of battle only.
  def pbOnActiveAll
    # Weather-inducing abilities, Trace, Imposter, etc.
    pbCalculatePriority(true)
    pbPriority(true).each { |b| b.pbEffectsOnSwitchIn(true) }
    pbCalculatePriority
    # Check forms are correct
    eachBattler { |b| b.pbCheckForm }
  end

  # Called when a Pokémon switches in (entry effects, entry hazards).
  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && (isConst?(battler.item,PBItems,:AMULETCOIN) ||
                             isConst?(battler.item,PBItems,:LUCKINCENSE))
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.totalpp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      aType = getConst(PBTypes,:ROCK) || 0
      bTypes = battler.pbTypes(true)
      eff = PBTypes.getCombinedEffectiveness(aType,bTypes[0],bTypes[1],bTypes[2])
      if !PBTypes.ineffective?(eff)
        eff = eff.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was badly poisoned by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(PBStats::SPEED)
        battler.pbLowerStatStage(PBStats::SPEED,1,nil)
        battler.pbItemStatRestoreCheck
      end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    return true
  end
end
