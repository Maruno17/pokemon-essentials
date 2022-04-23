
#===============================================================================
# Rock Smash
#===============================================================================


def pbRockSmashRandomEncounter
  if rand(100)<30
    if pbEncounter(:RockSmash)
      return
    else
      pbDefaultRockSmashEncounter(5,15)
    end
  else
    rockSmashItem(false)
  end
end

def pbDefaultRockSmashEncounter(minLevel,maxLevel)
  level =rand((maxLevel-minLevel).abs)+minLevel
  pbWildBattle(:GEODUDE,level)
  return true
end

#FOR ROCK TUNNEL AND CERULEAN CAVE (+diamond)
def pbRockSmashRandomEncounterSpecial
  if rand(100)<35
    pbEncounter(:RockSmash)
  else
    rockSmashItem(true)
  end
end

def getRockSmashItemList(inclRareItems)
  basicItems = [:ROCKGEM, :GROUNDGEM,:STEELGEM,
                :HARDSTONE,:HARDSTONE,:HARDSTONE,:ROCKGEM,
                :SMOOTHROCK,:STARDUST,:HEARTSCALE,:HEARTSCALE,
                :HEARTSCALE,:SOFTSAND,:HEARTSCALE,:RAREBONE]

  rareItems = [:RAREBONE,:STARDUST,:ETHER,
               :REVIVE,:NUGGET,:DIAMOND]

  fossilItems =    [:ROOTFOSSIL,:CLAWFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,
                    :SKULLFOSSIL,:ARMORFOSSIL]

  #            Kernel.pbMessage(inclRareItems.to_s)

  itemsList = inclRareItems ? basicItems + basicItems + rareItems : basicItems

  #beaten league
  if $game_switches[12]
    itemsList += fossilItems
  end
  return itemsList
end

def rockSmashItem(isDark=false)
  chance = 50
  if rand(100)< chance
    itemsList = getRockSmashItemList(isDark)
    i = rand(itemsList.length)
    Kernel.pbItemBall(itemsList[i],1,nil,false)
  end
end


#Used in underwater maps
def pbRockSmashRandomEncounterDive
  if rand(100)<25
    pbEncounter(:RockSmash)
  else
    if rand(100)<20
      itemsList = [:WATERGEM,:STEELGEM,
                   :HEARTSCALE,:HEARTSCALE,:HARDSTONE,:ROCKGEM,
                   :SMOOTHROCK,:WATERSTONE,:PEARL,:HEARTSCALE,
                   :HEARTSCALE,:HEARTSCALE,:SHOALSHELL,:BIGPEARL]

      i = rand(itemsList.length)
      Kernel.pbItemBall(itemsList[i],1,nil,false)
    end
  end
end



############### MORNING SUN / MOONLIGHT
HiddenMoveHandlers::CanUseMove.add(:MORNINGSUN,proc{|move,pkmn|
  if !GameData::MapMetadata.get($game_map.map_id).outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here."))
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:MORNINGSUN,proc{|move,pokemon|
  Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,GameData::Move.get(move).name))
  pbHiddenMoveAnimation(pokemon)
  pbFadeOutIn(99999){
    pbSkipTime(9)
    newTime = pbGetTimeNow.strftime("%I:%M %p")
    Kernel.pbMessage(_INTL("{1} waited until morning...",$Trainer.name))
    Kernel.pbMessage(_INTL("The time is now {1}",newTime))
    $game_screen.weather(:None,0,0)
    $game_map.refresh
  }
  next true
})

HiddenMoveHandlers::CanUseMove.add(:MOONLIGHT,proc{|move,pkmn|
  if !GameData::MapMetadata.get($game_map.map_id).outdoor_map
    Kernel.pbMessage(_INTL("Can't use that here."))
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:MOONLIGHT,proc{|move,pokemon|
  Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,GameData::Move.get(move).name))
  pbHiddenMoveAnimation(pokemon)
  pbFadeOutIn(99999){
    pbSkipTime(21)
    newTime = pbGetTimeNow.strftime("%I:%M %p")
    Kernel.pbMessage(_INTL("{1} waited until night...",$Trainer.name))
    Kernel.pbMessage(_INTL("The time is now {1}",newTime))
    $game_screen.weather(:None,0,0)
    $game_map.refresh
  }
  next true
})

def pbSkipTime(newTime)
  currentTime = pbGetTimeNow.hour
  #hoursToAdd = (24-currentTime + newTime)-24
  hoursToAdd = newTime - currentTime
  $game_variables[UnrealTime::EXTRA_SECONDS] += hoursToAdd*3600
end