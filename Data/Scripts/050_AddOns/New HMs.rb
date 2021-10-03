
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