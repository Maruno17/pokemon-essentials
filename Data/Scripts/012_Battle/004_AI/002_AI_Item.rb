class PokeBattle_AI
  #=============================================================================
  # Decide whether the opponent should use an item on the Pokémon
  #=============================================================================
  def pbEnemyShouldUseItem?(idxBattler)
    user = @battle.battlers[idxBattler]
    item, idxTarget = pbEnemyItemToUse(idxBattler)
    return false if item==0
    # Determine target of item (always the Pokémon choosing the action)
    useType = pbGetItemData(item,ITEM_BATTLE_USE)
    if useType && (useType==1 || useType==6)   # Use on Pokémon
      idxTarget = @battle.battlers[idxTarget].pokemonIndex   # Party Pokémon
    end
    # Register use of item
    @battle.pbRegisterItem(idxBattler,item,idxTarget)
    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use item #{PBItems.getName(item)}")
    return true
  end

  # NOTE: The AI will only consider using an item on the Pokémon it's currently
  #       choosing an action for.
  def pbEnemyItemToUse(idxBattler)
    return 0 if !@battle.internalBattle
    items = @battle.pbGetOwnerItems(idxBattler)
    return 0 if !items || items.length==0
    # Determine target of item (always the Pokémon choosing the action)
    idxTarget = idxBattler   # Battler using the item
    battler = @battle.battlers[idxTarget]
    pkmn = battler.pokemon
    # Item categories
    hpItems = {
       :POTION       => 20,
       :SUPERPOTION  => 50,
       :HYPERPOTION  => 200,
       :MAXPOTION    => 999,
       :BERRYJUICE   => 20,
       :SWEETHEART   => 20,
       :FRESHWATER   => 50,
       :SODAPOP      => 60,
       :LEMONADE     => 80,
       :MOOMOOMILK   => 100,
       :ORANBERRY    => 10,
       :SITRUSBERRY  => battler.totalhp/4,
       :ENERGYPOWDER => 50,
       :ENERGYROOT   => 200
    }
    hpItems[:RAGECANDYBAR] = 20 if !NEWEST_BATTLE_MECHANICS
    fullRestoreItems = [
       :FULLRESTORE
    ]
    oneStatusItems = [   # Preferred over items that heal all status problems
       :AWAKENING,:CHESTOBERRY,:BLUEFLUTE,
       :ANTIDOTE,:PECHABERRY,
       :BURNHEAL,:RAWSTBERRY,
       :PARALYZEHEAL,:PARLYZHEAL,:CHERIBERRY,
       :ICEHEAL,:ASPEARBERRY
    ]
    allStatusItems = [
       :FULLHEAL,:LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,
       :SHALOURSABLE,:BIGMALASADA,:LUMBERRY,:HEALPOWDER
    ]
    allStatusItems.push(:RAGECANDYBAR) if NEWEST_BATTLE_MECHANICS
    xItems = {
       :XATTACK    => [PBStats::ATTACK,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XATTACK2   => [PBStats::ATTACK,2],
       :XATTACK3   => [PBStats::ATTACK,3],
       :XATTACK6   => [PBStats::ATTACK,6],
       :XDEFENSE   => [PBStats::DEFENSE,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XDEFENSE2  => [PBStats::DEFENSE,2],
       :XDEFENSE3  => [PBStats::DEFENSE,3],
       :XDEFENSE6  => [PBStats::DEFENSE,6],
       :XDEFEND    => [PBStats::DEFENSE,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XDEFEND2   => [PBStats::DEFENSE,2],
       :XDEFEND3   => [PBStats::DEFENSE,3],
       :XDEFEND6   => [PBStats::DEFENSE,6],
       :XSPATK     => [PBStats::SPATK,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XSPATK2    => [PBStats::SPATK,2],
       :XSPATK3    => [PBStats::SPATK,3],
       :XSPATK6    => [PBStats::SPATK,6],
       :XSPECIAL   => [PBStats::SPATK,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XSPECIAL2  => [PBStats::SPATK,2],
       :XSPECIAL3  => [PBStats::SPATK,3],
       :XSPECIAL6  => [PBStats::SPATK,6],
       :XSPDEF     => [PBStats::SPDEF,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XSPDEF2    => [PBStats::SPDEF,2],
       :XSPDEF3    => [PBStats::SPDEF,3],
       :XSPDEF6    => [PBStats::SPDEF,6],
       :XSPEED     => [PBStats::SPEED,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XSPEED2    => [PBStats::SPEED,2],
       :XSPEED3    => [PBStats::SPEED,3],
       :XSPEED6    => [PBStats::SPEED,6],
       :XACCURACY  => [PBStats::ACCURACY,(NEWEST_BATTLE_MECHANICS) ? 2 : 1],
       :XACCURACY2 => [PBStats::ACCURACY,2],
       :XACCURACY3 => [PBStats::ACCURACY,3],
       :XACCURACY6 => [PBStats::ACCURACY,6]
    }
    losthp = battler.totalhp-battler.hp
    preferFullRestore = (battler.hp<=battler.totalhp*2/3 &&
       (battler.status!=PBStatuses::NONE || battler.effects[PBEffects::Confusion]>0))
    # Find all usable items
    usableHPItems     = []
    usableStatusItems = []
    usableXItems      = []
    items.each do |i|
      next if !i || i==0
      next if !@battle.pbCanUseItemOnPokemon?(i,pkmn,battler,@battle.scene,false)
      next if !ItemHandlers.triggerCanUseInBattle(i,pkmn,battler,nil,
         false,self,@battle.scene,false)
      checkedItem = false
      # Log HP healing items
      if losthp>0
        hpItems.each do |item, power|
          next if !isConst?(i,PBItems,item)
          checkedItem = true
          usableHPItems.push([i,5,power])
        end
        next if checkedItem
      end
      # Log Full Restores (HP healer and status curer)
      if losthp>0 || battler.status!=PBStatuses::NONE
        fullRestoreItems.each do |item|
          next if !isConst?(i,PBItems,item)
          checkedItem = true
          usableHPItems.push([i,(preferFullRestore) ? 3 : 7,999])
          usableStatusItems.push([i,(preferFullRestore) ? 3 : 9])
        end
        next if checkedItem
      end
      # Log single status-curing items
      if battler.status!=PBStatuses::NONE
        oneStatusItems.each do |item|
          next if !isConst?(i,PBItems,item)
          checkedItem = true
          usableStatusItems.push([i,5])
        end
        next if checkedItem
        # Log Full Heal-type items
        allStatusItems.each do |item|
          next if !isConst?(i,PBItems,item)
          checkedItem = true
          usableStatusItems.push([i,7])
        end
        next if checkedItem
      end
      # Log stat-raising items
      xItems.each do |item, data|
        next if !isConst?(i,PBItems,item)
        checkedItem = true
        usableXItems.push([i,battler.stages[data[0]],data[1]])
      end
      next if checkedItem
    end
    # Prioritise using a HP restoration item
    if usableHPItems.length>0 && (battler.hp<=battler.totalhp/4 ||
       (battler.hp<=battler.totalhp/2 && pbAIRandom(100)<30))
      usableHPItems.sort! { |a,b| (a[1]==b[1]) ? a[2]<=>b[2] : a[1]<=>b[1] }
      prevItem = nil
      usableHPItems.each do |i|
        return i[0],idxTarget if i[2]>=losthp
        prevItem = i
      end
      return prevItem[0],idxTarget
    end
    # Next prioritise using a status-curing item
    if usableStatusItems.length>0 && pbAIRandom(100)<40
      usableStatusItems.sort! { |a,b| a[1]<=>b[1] }
      return usableStatusItems[0][0],idxTarget
    end
    # Next try using an X item
    if usableXItems.length>0 && pbAIRandom(100)<30
      usableXItems.sort! { |a,b| (a[1]==b[1]) ? a[2]<=>b[2] : a[1]<=>b[1] }
      prevItem = nil
      usableXItems.each do |i|
        break if prevItem && i[1]>prevItem[1]
        return i[0],idxTarget if i[1]+i[2]>=6
        prevItem = i
      end
      return prevItem[0],idxTarget
    end
    return 0
  end
end
