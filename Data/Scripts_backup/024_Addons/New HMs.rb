#===============================================================================
# Teleport
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:TELEPORT,proc{|move,pkmn|
 if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLY : $Trainer.badges[BADGEFORFLY])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:TELEPORT,proc{|move,pokemon|
  if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
   }
   pbEraseEscapePoint
   return true
})

#===============================================================================
# FLY
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLY,proc{|move,pkmn|
 if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLY : $Trainer.badges[BADGEFORFLY])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLY,proc{|move,pokemon|
  if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbFadeOutIn(99999){
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id=$PokemonTemp.flydata[0]
      $game_temp.player_new_x=$PokemonTemp.flydata[1]
      $game_temp.player_new_y=$PokemonTemp.flydata[2]
      $PokemonTemp.flydata=nil
      $game_temp.player_new_direction=2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
   }
   pbEraseEscapePoint
   return true
})
#===============================================================================
# Cut (+Machete)
#===============================================================================
def Kernel.pbCut
  if $DEBUG ||
     (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORCUT : $Trainer.badges[BADGEFORCUT])
    movefinder=Kernel.pbCheckMove(:CUT)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::MACHETE)>0
      Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
      if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Cut!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        return true
      end
    else
    Kernel.pbMessage(_INTL("This tree looks like it could be cut down."))
    end
  else
    Kernel.pbMessage(_INTL("This tree looks like it could be cut down."))
  end
  return false
end

##Machete
def canUseMoveCut?
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORCUT : $Trainer.badges[BADGEFORCUT])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Tree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
end

def useMoveCut
   if !pbHiddenMoveAnimation(nil)
     Kernel.pbMessage(_INTL("{1} used {2}!",$Trainer.name,"Cut"))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true
end

###


HiddenMoveHandlers::CanUseMove.add(:CUT,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORCUT : $Trainer.badges[BADGEFORCUT])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Tree"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:CUT,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true
})




#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  if rand(100)<40
    if pbEncounter(EncounterTypes::RockSmash)
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
  $PokemonTemp.encounterType=EncounterTypes::RockSmash
  pbWildBattle(PBSpecies::GEODUDE,level)
  $PokemonTemp.encounterType=-1
  return true
  
end

#FOR ROCK TUNNEL AND CERULEAN CAVE (+diamond)
def pbRockSmashRandomEncounterSpecial
  if rand(100)<35
    pbEncounter(EncounterTypes::RockSmash)
  else
    rockSmashItem(true)  
  end
end

def getRockSmashItemList(inclRareItems)
        basicItems = [PBItems::ROCKGEM, PBItems::GROUNDGEM,PBItems::STEELGEM,
        PBItems::HARDSTONE,PBItems::HARDSTONE,PBItems::HARDSTONE,PBItems::ROCKGEM,
        PBItems::SMOOTHROCK,PBItems::STARDUST,PBItems::HEARTSCALE,PBItems::HEARTSCALE,
        PBItems::HEARTSCALE,PBItems::SOFTSAND,PBItems::HEARTSCALE]
  
        rareItems = [PBItems::RAREBONE,PBItems::STARDUST,PBItems::ETHER,
        PBItems::REVIVE,PBItems::NUGGET,PBItems::DIAMOND]
        
        fossilItems =    [PBItems::ROOTFOSSIL,PBItems::CLAWFOSSIL,PBItems::DOMEFOSSIL,PBItems::HELIXFOSSIL,
        PBItems::SKULLFOSSIL,PBItems::ARMORFOSSIL]
        
        #            Kernel.pbMessage(inclRareItems.to_s)

        itemsList = inclRareItems ? basicItems + basicItems + rareItems : basicItems
        
        #beaten league
        if $game_switches[12]
          itemsList += fossilItems
        end
        return itemsList
end

def rockSmashItem(isDark=false)
    chance = isDark ? 25 : 45
    if rand(100)< chance
          itemsList = getRockSmashItemList(isDark)
          i = rand(itemsList.length)
          Kernel.pbItemBall(itemsList[i],1,nil,false)
    end
end


#Used in underwater maps
def pbRockSmashRandomEncounterDive
  if rand(100)<25
    pbEncounter(EncounterTypes::RockSmash)
  else
      if rand(100)<20
        itemsList = [PBItems::WATERGEM,PBItems::STEELGEM,
        PBItems::HEARTSCALE,PBItems::HEARTSCALE,PBItems::HARDSTONE,PBItems::ROCKGEM,
        PBItems::SMOOTHROCK,PBItems::WATERSTONE,PBItems::PEARL,PBItems::HEARTSCALE,
        PBItems::HEARTSCALE,PBItems::HEARTSCALE,PBItems::SHOALSHELL,PBItems::BIGPEARL]
        
        i = rand(itemsList.length)
        Kernel.pbItemBall(itemsList[i],1,nil,false)      
      end
  end
end


def Kernel.pbRockSmash
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKSMASH : $Trainer.badges[BADGEFORROCKSMASH])
    movefinder=Kernel.pbCheckMove(:ROCKSMASH)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::PICKAXE)>0
      if Kernel.pbConfirmMessage(_INTL("This rock appears to be breakable.  Would you like to use Rock Smash?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Rock Smash!",speciesname))
        pbHiddenMoveAnimation(movefinder)
        return true
      end
    else
      Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    end
  else
    Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH,proc{|move,pkmn|
   terrain=Kernel.pbFacingTerrainTag
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKSMASH : $Trainer.badges[BADGEFORROCKSMASH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || facingEvent.name!="Rock"
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true  
})

#===============================================================================
# Strength
#===============================================================================
def Kernel.pbStrength(isSlowpoke=false)
  #isBoulder = !$game_switches[377]
  #        Kernel.pbMessage(_INTL("{1}",$game_switches[377]))

  if isSlowpoke
    msg = "It's a big Pokémon, but a Pokémon may be able to push it aside."
  else
    msg = "It's a big boulder, but a Pokémon may be able to push it aside."
  end
    
  if $PokemonMap.strengthUsed
    #Kernel.pbMessage(_INTL("Strength made it possible to move boulders around."))
  elsif $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSTRENGTH : $Trainer.badges[BADGEFORSTRENGTH])
    movefinder=Kernel.pbCheckMove(:STRENGTH)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::LEVER)>0
        Kernel.pbMessage(_INTL(msg))
      if Kernel.pbConfirmMessage(_INTL("Would you like to use Strength?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Strength!\1",speciesname))
        pbHiddenMoveAnimation(movefinder)
        Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",speciesname))
        $PokemonMap.strengthUsed=true
        return true
      end
    else
      Kernel.pbMessage(_INTL(msg))
    end
  else
    Kernel.pbMessage(_INTL(msg))
  end
  return false
end

Events.onAction+=proc{|sender,e|
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     if facingEvent.name=="Boulder"
       Kernel.pbStrength
       return
     end
   end
}


Events.onAction+=proc{|sender,e|
   facingEvent=$game_player.pbFacingEvent
   if facingEvent
     if facingEvent.name=="BoulderSlowpoke"
       Kernel.pbStrength(true)
       return
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:STRENGTH,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORSTRENGTH : $Trainer.badges[BADGEFORSTRENGTH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonMap.strengthUsed
     Kernel.pbMessage(_INTL("Strength is already being used."))
     return false
   end
   return true  
})

HiddenMoveHandlers::UseMove.add(:STRENGTH,proc{|move,pokemon|
   pbHiddenMoveAnimation(pokemon)
   Kernel.pbMessage(_INTL("{1} used {2}!\1",pokemon.name,PBMoves.getName(move)))
   Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
   $PokemonMap.strengthUsed=true
   return true  
})

#===============================================================================
# Surf
#===============================================================================
def pbSurf
  return false if $game_player.pbFacingEvent
  return false if $game_player.pbHasDependentEvents?
  move = getID(PBMoves,:SURF)
  movefinder = pbCheckMove(move) || $PokemonBag.pbQuantity(PBItems::SURFBOARD)>0
  if !pbCheckHiddenMoveBadge(BADGE_FOR_SURF,false) || (!$DEBUG && !movefinder)
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,PBMoves.getName(move)))
    pbCancelVehicles
    pbHiddenMoveAnimation(movefinder)
    surfbgm = pbGetMetadata(0,MetadataSurfBGM)
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing
    return true
  end
  return false
end


def playSurfMusic?()
  mapsWithoutMusic = [322]
  return false if mapsWithoutMusic.include?($game_map.map_id)
  return true
end


def Kernel.pbTransferSurfingNoFade(mapid,xcoord,ycoord,direction=$game_player.direction)
 $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.surfing=true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
end




#===============================================================================
# Waterfall
#===============================================================================
def Kernel.pbAscendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
  return if event.direction!=8 # can't ascend if not facing up
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    event.move_up
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  event.move_speed=oldmovespeed
end

def Kernel.pbDescendWaterfall(event=nil)
  event=$game_player if !event
  return if !event
  return if event.direction!=2 # Can't descend if not facing down
  oldthrough=event.through
  oldmovespeed=event.move_speed
  terrain=Kernel.pbFacingTerrainTag  
  return if terrain!=PBTerrain::Waterfall# && terrain!=PBTerrain::WaterfallCrest
  event.through=true
  event.move_speed=2
  loop do
    event.move_down
    terrain=pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through=oldthrough
  event.move_speed=oldmovespeed
end

def Kernel.pbWaterfall
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORWATERFALL : $Trainer.badges[BADGEFORWATERFALL])
    movefinder=Kernel.pbCheckMove(:WATERFALL)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::JETPACK)>0
      if Kernel.pbConfirmMessage(_INTL("It's a large waterfall.  Would you like to use Waterfall?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Waterfall.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbAscendWaterfall
        return true
      end
    else
      Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    end
  else
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
  end
  return false
end

Events.onAction+=proc{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   if terrain==PBTerrain::Waterfall
     Kernel.pbWaterfall
     return
   end
   if terrain==PBTerrain::WaterfallCrest
     Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
     return
   end
}

HiddenMoveHandlers::CanUseMove.add(:WATERFALL,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORWATERFALL : $Trainer.badges[BADGEFORWATERFALL])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   terrain=Kernel.pbFacingTerrainTag
   if terrain!=PBTerrain::Waterfall
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   Kernel.pbAscendWaterfall
   return true
})
#===============================================================================
# Rock Climb
#===============================================================================

Events.onAction+=proc{|sender,e|
   terrain=Kernel.pbFacingTerrainTag
   if terrain==PBTerrain::Ledge
      pbRockClimb()
    return
   end
}

HiddenMoveHandlers::CanUseMove.add(:ROCKCLIMB,proc{|move,pkmn|
  pbRockClimb()
})



def pbRockClimb()
     if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORROCKCLIMB : $Trainer.badges[BADGEFORWATERFALL])
     return false
   end
   terrain=Kernel.pbFacingTerrainTag
   if terrain!=PBTerrain::Ledge
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   Kernel.pbClimbLedge
   return true
end
  
  
HiddenMoveHandlers::UseMove.add(:WATERFALL,proc{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   Kernel.pbClimbLedge
   return true
})

def Kernel.pbClimbLedge(event=nil)
  if Kernel.pbFacingTerrainTag==PBTerrain::Ledge
    if Kernel.pbConfirmMessage(_INTL("It looks like it's possible to climb. Would you like to use Rock Climb?"))
      if Kernel.pbJumpToward(2,true)
            $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,$game_player.x,$game_player.y,true)
            $game_player.increase_steps
            $game_player.check_event_trigger_here([1,2])
          end
          return true
        end
        return false
    end
    
end

#===============================================================================
# Dive
#===============================================================================
def Kernel.pbDive
  divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
  return false if !divemap
  if $DEBUG ||
    (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
    movefinder=Kernel.pbCheckMove(:DIVE)
    if $DEBUG || movefinder || $PokemonBag.pbQuantity(PBItems::SCUBAGEAR)
      if Kernel.pbConfirmMessage(_INTL("The sea is deep here.  Would you like to use Dive?"))
        speciesname=!movefinder ? $Trainer.name : movefinder.name
        Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
        pbHiddenMoveAnimation(movefinder)
        pbFadeOutIn(99999){
           $game_temp.player_new_map_id=divemap
           $game_temp.player_new_x=$game_player.x
           $game_temp.player_new_y=$game_player.y
           $game_temp.player_new_direction=$game_player.direction
           Kernel.pbCancelVehicles
           $PokemonGlobal.diving=true
           $game_screen.weather(0,0,0)
           Kernel.pbUpdateVehicle
           $scene.transfer_player(false)
           $game_map.autoplay
           $game_map.refresh
        }
        return true
      end
    else
      Kernel.pbMessage(_INTL("The sea is deep here.  A Pokémon may be able to go underwater."))
    end
  else
    Kernel.pbMessage(_INTL("The sea is deep here.  A Pokémon may be able to go underwater."))
  end
  return false
end

def Kernel.pbSurfacing
  return if !$PokemonGlobal.diving
  divemap=nil
  meta=pbLoadMetadata
  for i in 0...meta.length
    if meta[i] && meta[i][MetadataDiveMap]
      if meta[i][MetadataDiveMap]==$game_map.map_id
        divemap=i
        break
      end
    end
  end
  return if !divemap
  movefinder=Kernel.pbCheckMove(:DIVE)
  
  #if $DEBUG || (movefinder &&
  #  (HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE]) &&
  if   (canSurfaceHere?(divemap,$game_player.x,$game_player.y))
    if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above.  Would you like to use Dive?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used Dive.",speciesname))
      pbHiddenMoveAnimation(movefinder)
      pbFadeOutIn(99999){
         $game_temp.player_new_map_id=divemap
         $game_temp.player_new_x=$game_player.x
         $game_temp.player_new_y=$game_player.y
         $game_temp.player_new_direction=$game_player.direction
         Kernel.pbCancelVehicles
         $PokemonGlobal.surfing=true
         Kernel.pbUpdateVehicle
         $scene.transfer_player(false)
         surfbgm=pbGetMetadata(0,MetadataSurfBGM)
         if surfbgm
           pbBGMPlay(surfbgm)
         else
           $game_map.autoplayAsCue
         end
         $game_map.refresh
      }
      return true
    end
  else
    Kernel.pbMessage(_INTL("It's impossible to surface here!"))
    $PokemonGlobal.surfing = false

  end
  return false
end

def canSurfaceHere?(mapID,x,y)
  terrainTag = $MapFactory.getTerrainTag(mapID,x,y)
  map = $MapFactory.getMapNoAdd(mapID)
  $PokemonGlobal.surfing = true
  
  #Kernel.pbMessage(_INTL("{1}",mapID))
  return  pbIsPassableWaterTag?(terrainTag) &&
          map.playerPassable?(x,y,0)
end


def Kernel.pbTransferUnderwater(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.diving=true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

def Kernel.pbTransfer(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id=mapid
     $game_temp.player_new_x=xcoord
     $game_temp.player_new_y=ycoord
     $game_temp.player_new_direction=direction
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=proc{|sender,e|
   terrain=$game_player.terrain_tag
   if terrain==PBTerrain::DeepWater
     Kernel.pbDive
     return
   end
   if $PokemonGlobal.diving
     if DIVINGSURFACEANYWHERE
       Kernel.pbSurfacing
       return
     else
       divemap=nil
       meta=pbLoadMetadata
       for i in 0...meta.length
         if meta[i] && meta[i][MetadataDiveMap]
           if meta[i][MetadataDiveMap]==$game_map.map_id
             divemap=i
             break
           end
         end
       end
       if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
         Kernel.pbSurfacing
         return
       end
     end
   end
}

HiddenMoveHandlers::CanUseMove.add(:DIVE,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORDIVE : $Trainer.badges[BADGEFORDIVE])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if $PokemonGlobal.diving
     return true if DIVINGSURFACEANYWHERE
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
     if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
       return true
     else
       Kernel.pbMessage(_INTL("Can't use that here."))
       return false
     end
   end
   if $game_player.terrain_tag!=PBTerrain::DeepWater
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:DIVE,proc{|move,pokemon|
   wasdiving=$PokemonGlobal.diving
   if $PokemonGlobal.diving
     divemap=nil
     meta=pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap]
         if meta[i][MetadataDiveMap]==$game_map.map_id
           divemap=i
           break
         end
       end
     end
   else
     divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
   end
   return false if !divemap
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}.",pokemon.name,PBMoves.getName(move)))
   end
   pbFadeOutIn(99999){
      $game_temp.player_new_map_id=divemap
      $game_temp.player_new_x=$game_player.x
      $game_temp.player_new_y=$game_player.y
      $game_temp.player_new_direction=$game_player.direction
      Kernel.pbCancelVehicles
      if wasdiving
        $PokemonGlobal.surfing=true
      else
        $PokemonGlobal.diving=true
      end
      Kernel.pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
   }
   return true
})



#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH,proc{|move,pkmn|
   if !$DEBUG &&
      !(HIDDENMOVESCOUNTBADGES ? $Trainer.numbadges>=BADGEFORFLASH : $Trainer.badges[BADGEFORFLASH])
     Kernel.pbMessage(_INTL("Sorry, a new Badge is required."))
     return false
   end
   if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $PokemonGlobal.flashUsed
     Kernel.pbMessage(_INTL("This is in use already."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:FLASH,proc{|move,pokemon|
   darkness=$PokemonTemp.darknessSprite
   return false if !darkness || darkness.disposed?
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
     $PokemonGlobal.flashUsed=true
     darkness.radius+=200

   #while darkness.radius<176
   #  Graphics.update
   #  Input.update
   #  pbUpdateSceneMap
   #  darkness.radius+=4
   #end
   return true
})




############### MORNING SUN / MOONLIGHT
HiddenMoveHandlers::CanUseMove.add(:MORNINGSUN,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:MORNINGSUN,proc{|move,pokemon|
  Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
   pbFadeOutIn(99999){
     pbSkipTime(9)
     newTime = pbGetTimeNow.strftime("%I:%M %p")
     Kernel.pbMessage(_INTL("{1} waited until morning...",$Trainer.name))
     Kernel.pbMessage(_INTL("The time is now {1}",newTime))
     $game_screen.weather(0,0,0)
     $game_map.refresh
    }
   return true
})

HiddenMoveHandlers::CanUseMove.add(:MOONLIGHT,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:MOONLIGHT,proc{|move,pokemon|
   Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
   pbFadeOutIn(99999){
     pbSkipTime(21)
     newTime = pbGetTimeNow.strftime("%I:%M %p")
     Kernel.pbMessage(_INTL("{1} waited until night...",$Trainer.name))
     Kernel.pbMessage(_INTL("The time is now {1}",newTime))
     $game_screen.weather(0,0,0)
     $game_map.refresh
    }
   return true
})

def pbSkipTime(newTime)
  currentTime = pbGetTimeNow.hour
  #hoursToAdd = (24-currentTime + newTime)-24
  hoursToAdd = newTime - currentTime
  $game_variables[79] += hoursToAdd*3600
end

############### WEATHER MOVES
#Rain Dance
HiddenMoveHandlers::UseMove.add(:RAINDANCE,proc{|move,pokemon|
   Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
  if $game_screen.weather_type==1
      Kernel.pbMessage(_INTL("It stopped raining!"))
      $game_map.refresh
      $game_screen.weather(0,0,20)
  else
      Kernel.pbMessage(_INTL("It started to rain!"))
      $game_map.refresh
      $game_screen.weather(1,2,20)
  end
  return true
})

HiddenMoveHandlers::CanUseMove.add(:RAINDANCE,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

#Sunny Day
HiddenMoveHandlers::UseMove.add(:SUNNYDAY,proc{|move,pokemon|
   Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
  if $game_screen.weather_type==5
      Kernel.pbMessage(_INTL("The sunlight faded."))
      $game_map.refresh
      $game_screen.weather(0,0,20)
  else
      Kernel.pbMessage(_INTL("The sunlight turned harsh!"))
      $game_map.refresh
      $game_screen.weather(5,2,20)
  end
  return true
})

HiddenMoveHandlers::CanUseMove.add(:SUNNYDAY,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || !PBDayNight.isDay?(pbGetTimeNow)
      Kernel.pbMessage(_INTL("Can't use that now.")) 
      return false
   end
   return true
})

#Hail
HiddenMoveHandlers::UseMove.add(:HAIL,proc{|move,pokemon|
   Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
  if $game_screen.weather_type==3
      Kernel.pbMessage(_INTL("It stopped hailing"))
      $game_map.refresh
      $game_screen.weather(0,0,20)
  else
      Kernel.pbMessage(_INTL("It started to hail!"))
      $game_map.refresh
      $game_screen.weather(3,2,20)
  end
  return true
})

HiddenMoveHandlers::CanUseMove.add(:HAIL,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})

#sandstorm
HiddenMoveHandlers::UseMove.add(:SANDSTORM,proc{|move,pokemon|
   Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   pbHiddenMoveAnimation(pokemon)
  if $game_screen.weather_type==7
      Kernel.pbMessage(_INTL("The sandstorm faded."))
      $game_map.refresh
      $game_screen.weather(0,0,20)
    else
      Kernel.pbMessage(_INTL("A sandstorm brewed up!"))
      $game_map.refresh
      $game_screen.weather(7,2,20)
  end
  return true
})

HiddenMoveHandlers::CanUseMove.add(:SANDSTORM,proc{|move,pkmn|
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   return true
})
