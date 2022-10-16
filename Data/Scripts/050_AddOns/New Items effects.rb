ItemHandlers::BattleUseOnBattler.add(:POKEDEX, proc { |item, battler, scene|
  #if battler.battle.battlers.length  > -1
  #  scene.pbDisplay(_INTL(" The length is {1}",battler.battle.battlers.length))
  #     scene.pbDisplay(_INTL("The PokéDex cannot be used on multiple enemies at once!"))
  #     return false
  #end

  doublebattle = false
  #DOUBLE BATTLES A FAIRE
  #variable temporaire doublebattle
  if doublebattle
    e = battler.pbOpposing2
  else
    is_trainer = battler.battle.opponent

    e1 = battler.pbOpposing1.pokemon
    enemyname = e1.name
    e1type1 = e1.type1
    e1type2 = e1.type2
  end
  if e1type1 == e1type2
    scene.pbDisplay(_INTL("{2} has been identified as a {1} type Pokémon.", PBTypes.getName(e1type1), enemyname))
  else
    scene.pbDisplay(_INTL("{3} has been identified as a {1}/{2} type Pokémon.", PBTypes.getName(e1type1), PBTypes.getName(e1type2), enemyname))

    if $game_switches[10] #BADGE 7
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE, false)
        battler.pbIncreaseStat(PBStats::DEFENSE, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF, false)
        battler.pbIncreaseStat(PBStats::SPDEF, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[8] #BADGE 5
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[6] #BADGE 3
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 2, true)
      end
    elsif $game_switches[8] #BADGE 1
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 1, true)
      end
    end

    return true
  end
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  if useLantern()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:LANTERN, proc { |item|
  Kernel.pbMessage(_INTL("#{$Trainer.name} used the lantern."))
  if useLantern()
    next 1
  else
    next 0
  end
})

def useLantern()
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed? || $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("It's already illuminated..."))
    return false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the cave!"))
  darkness.radius += 176
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMapd
    darkness.radius += 4
  end
  return true
end

ItemHandlers::UseFromBag.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

def useTeleporter()
  if HiddenMoveHandlers.triggerCanUseMove(:TELEPORT, 0, true)
    Kernel.pbMessage(_INTL("Teleport to where?", $Trainer.name))
    ret = pbBetterRegionMap(-1, true, true)
    return false unless ret
    ###############################################
    if ret
      $PokemonTemp.flydata = ret
    end
    # scene = PokemonRegionMapScene.new(-1, false)
    # screen = PokemonRegionMap.new(scene)
    # ret = screen.pbStartFlyScreen
    # if ret
    #   $PokemonTemp.flydata = ret
    # end
  end

  if !$PokemonTemp.flydata
    return false
  else
    Kernel.pbMessage(_INTL("{1} used the teleporter!", $Trainer.name))
    pbFadeOutIn(99999) {
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id = $PokemonTemp.flydata[0]
      $game_temp.player_new_x = $PokemonTemp.flydata[1]
      $game_temp.player_new_y = $PokemonTemp.flydata[2]
      $PokemonTemp.flydata = nil
      $game_temp.player_new_direction = 2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
    return true
  end
end

ItemHandlers::BattleUseOnBattler.add(:POKEDEX, proc { |item, battler, scene|
  #if battler.battle.battlers.length  > -1
  #  scene.pbDisplay(_INTL(" The length is {1}",battler.battle.battlers.length))
  #     scene.pbDisplay(_INTL("The PokéDex cannot be used on multiple enemies at once!"))
  #     return false
  #end

  doublebattle = false
  #DOUBLE BATTLES A FAIRE
  #variable temporaire doublebattle
  if doublebattle
    e = battler.pbOpposing2
  else
    is_trainer = battler.battle.opponent

    e1 = battler.pbOpposing1.pokemon
    enemyname = e1.name
    e1type1 = e1.type1
    e1type2 = e1.type2
  end
  if e1type1 == e1type2
    scene.pbDisplay(_INTL("{2} has been identified as a {1} type Pokémon.", PBTypes.getName(e1type1), enemyname))
  else
    scene.pbDisplay(_INTL("{3} has been identified as a {1}/{2} type Pokémon.", PBTypes.getName(e1type1), PBTypes.getName(e1type2), enemyname))

    if $game_switches[10] #BADGE 7
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE, false)
        battler.pbIncreaseStat(PBStats::DEFENSE, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF, false)
        battler.pbIncreaseStat(PBStats::SPDEF, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[8] #BADGE 5
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[6] #BADGE 3
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 2, true)
      end
    elsif $game_switches[8] #BADGE 1
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 1, true)
      end
    end

    return true
  end
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed?
    Kernel.pbMessage(_INTL("The cave is already illuminated."))
    next false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the cave!"))
  $PokemonGlobal.flashUsed = true
  darkness.radius += 176
  while darkness.radius < 176
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += 4
  end
  next true
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

#NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.egg?
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.eggsteps = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseFromBag.add(:DEBUGGER, proc { |item|
  Kernel.pbMessage(_INTL("[{1}]The debugger should ONLY be used if you are stuck somewhere because of a glitch.", Settings::GAME_VERSION_NUMBER))
  if Kernel.pbConfirmMessageSerious(_INTL("Innapropriate use of this item can lead to unwanted effects and make the game unplayable. Do you want to continue?"))
    $game_player.cancelMoveRoute()
    Kernel.pbStartOver(false)
    Kernel.pbMessage(_INTL("Please report the glitch on the Pokecommunity thread, on the game's subreddit or in the game's Discord channel."))
  end
})

ItemHandlers::UseFromBag.add(:ODDKEYSTONE, proc { |item|
  TOTAL_SPIRITS_NEEDED = 108
  nbSpirits = pbGet(VAR_ODDKEYSTONE_NB)
  if nbSpirits == 107
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("Voices can be heard whispering from it..."))
    Kernel.pbMessage(_INTL("Just... one... more..."))
  elsif nbSpirits < TOTAL_SPIRITS_NEEDED
    nbNeeded = TOTAL_SPIRITS_NEEDED - nbSpirits
    Kernel.pbMessage(_INTL("Voices can be heard whispering from the Odd Keystone..."))
    Kernel.pbMessage(_INTL("Bring... us... {1}... spirits", nbNeeded.to_s))
  else
    Kernel.pbMessage(_INTL("The Odd Keystone appears to be moving on its own."))
    Kernel.pbMessage(_INTL("It seems as if some poweful energy is trying to escape from it."))
    if (Kernel.pbMessage("Let it out?", ["No", "Yes"], 0)) == 1
      pbWildBattle(:SPIRITOMB, 27)
      pbSet(VAR_ODDKEYSTONE_NB, 0)
    end
    next 1
  end
})

ItemHandlers::UseFromBag.add(:MAGICBOOTS, proc { |item|
  if $DEBUG
    if Kernel.pbConfirmMessageSerious(_INTL("Take off the Magic Boots?"))
      $DEBUG = false
    end
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Put on the Magic Boots?"))
      Kernel.pbMessage(_INTL("Debug mode is now active."))
      $game_switches[842] = true #got debug mode (for compatibility)
      $DEBUG = true
    end
  end
  next 1
})

def pbForceEvo(pokemon)
  newspecies = getEvolvedSpecies(pokemon)
  return false if newspecies == -1
  if newspecies > 0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
  return true
end

def getEvolvedSpecies(pokemon)
  return pbCheckEvolutionEx(pokemon) { |pokemon, evonib, level, poke|
    next pbMiniCheckEvolution(pokemon, evonib, level, poke, true)
  }
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNAREVERSER, proc { |item, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    reverseFusion(pokemon)
    scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
    scene.pbRefresh
    next true
  end

  next false
})

def reverseFusion(pokemon)
  body = getBasePokemonID(pokemon.species, true)
  head = getBasePokemonID(pokemon.species, false)
  newspecies = (head) * Settings::NB_POKEMON + body

  body_exp = pokemon.exp_when_fused_body
  head_exp = pokemon.exp_when_fused_head

  pokemon.exp_when_fused_body = head_exp
  pokemon.exp_when_fused_head = body_exp

  pokemon.head_shiny,pokemon.body_shiny = pokemon.body_shiny,pokemon.head_shiny
  #play animation
  pbFadeOutInWithMusic(99999) {
    fus = PokemonEvolutionScene.new
    fus.pbStartScreen(pokemon, newspecies, true)
    fus.pbEvolution(false, true)
    fus.pbEndScreen
  }
end

ItemHandlers::UseOnPokemon.add(:INFINITEREVERSERS, proc { |item, pokemon, scene|
  if !pokemon.isFusion?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * Settings::NB_POKEMON + body

    body_exp = pokemon.exp_when_fused_body
    head_exp = pokemon.exp_when_fused_head

    pokemon.exp_when_fused_body = head_exp
    pokemon.exp_when_fused_head = body_exp

    #play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

#
# def pbDNASplicing(pokemon, scene, supersplicers = false, superSplicer = false)
#   if (pokemon.species <= NB_POKEMON)
#     if pokemon.fused != nil
#       if $Trainer.party.length >= 6
#         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
#         return false
#       else
#         $Trainer.party[$Trainer.party.length] = pokemon.fused
#         pokemon.fused = nil
#         pokemon.form = 0
#         scene.pbHardRefresh
#         scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
#         return true
#       end
#     else
#       chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
#       if chosen >= 0
#         poke2 = $Trainer.party[chosen]
#         if (poke2.species <= NB_POKEMON) && poke2 != pokemon
#           #check if fainted
#           if pokemon.hp == 0 || poke2.hp == 0
#             scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
#             return false
#           end
#           if pbFuse(pokemon, poke2, supersplicers)
#             pbRemovePokemonAt(chosen)
#           end
#         elsif pokemon == poke2
#           scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
#           return false
#         else
#           scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
#           return false
#
#         end
#
#       else
#         return false
#       end
#     end
#   else
#     return true if pbUnfuse(pokemon, scene, supersplicers)
#
#     #unfuse
#   end
# end
#
# def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
#   #pcPosition nil   : unfusing from party
#   #pcPosition [x,x] : unfusing from pc
#   #
#
#   if (pokemon.obtain_method == 2 || pokemon.ot != $Trainer.name) # && !canunfuse
#     scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
#     return false
#   else
#     if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
#       if pokemon.species > (NB_POKEMON * NB_POKEMON) + NB_POKEMON #triple fusion
#         scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
#         return false
#       elsif $Trainer.party.length >= 6 && !pcPosition
#         scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
#         return false
#       else
#         scene.pbDisplay(_INTL("Unfusing ... "))
#         scene.pbDisplay(_INTL(" ... "))
#         scene.pbDisplay(_INTL(" ... "))
#
#         bodyPoke = getBasePokemonID(pokemon.species, true)
#         headPoke = getBasePokemonID(pokemon.species, false)
#
#
#         if pokemon.exp_when_fused_head == nil || pokemon.exp_when_fused_body == nil
#           new_level = calculateUnfuseLevelOldMethod(pokemon, supersplicers)
#           body_level = new_level
#           head_level = new_level
#           poke1 = Pokemon.new(bodyPoke, body_level)
#           poke2 = Pokemon.new(headPoke, head_level)
#         else
#           exp_body = pokemon.exp_when_fused_body + pokemon.exp_gained_since_fused
#           exp_head = pokemon.exp_when_fused_head + pokemon.exp_gained_since_fused
#
#           poke1 = Pokemon.new(bodyPoke, pokemon.level)
#           poke2 = Pokemon.new(headPoke, pokemon.level)
#           poke1.exp = exp_body
#           poke2.exp = exp_head
#         end
#
#         #poke1 = PokeBattle_Pokemon.new(bodyPoke, lev, $Trainer)
#         #poke2 = PokeBattle_Pokemon.new(headPoke, lev, $Trainer)
#
#         if pcPosition == nil
#           box = pcPosition[0]
#           index = pcPosition[1]
#           $PokemonStorage.pbStoreToBox(poke2, box, index)
#         else
#           Kernel.pbAddPokemonSilent(poke2, poke2.level)
#         end
#         #On ajoute l'autre dans le pokedex aussi
#         $Trainer.seen[poke1.species] = true
#         $Trainer.owned[poke1.species] = true
#         $Trainer.seen[poke2.species] = true
#         $Trainer.owned[poke2.species] = true
#
#         pokemon.species = poke1.species
#         pokemon.level = poke1.level
#         pokemon.name = poke1.name
#         pokemon.moves = poke1.moves
#         pokemon.obtain_method = 0
#         poke1.obtain_method = 0
#
#         #scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
#         scene.pbHardRefresh
#         scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
#         return true
#       end
#     end
#   end
# end

def calculateUnfuseLevelOldMethod(pokemon, supersplicers)
  if pokemon.level > 1
    if supersplicers
      lev = pokemon.level * 0.9
    else
      lev = pokemon.obtain_method == 2 ? pokemon.level * 0.65 : pokemon.level * 0.75
    end
  else
    lev = 1
  end
  return lev.floor
end

def drawFusionPreviewText(viewport, text, x, y)
  label_base_color = Color.new(248, 248, 248)
  label_shadow_color = Color.new(104, 104, 104)
  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap
  textpos = [[text, x, y, 0, label_base_color, label_shadow_color]]
  pbDrawTextPositions(overlay, textpos)
end

def drawPokemonType(pokemon_id, x_pos = 192, y_pos = 264)
  width = 66

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 1000001

  overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport).bitmap

  pokemon = GameData::Species.get(pokemon_id)
  typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
  type1_number = GameData::Type.get(pokemon.type1).id_number
  type2_number = GameData::Type.get(pokemon.type2).id_number
  type1rect = Rect.new(0, type1_number * 28, 64, 28)
  type2rect = Rect.new(0, type2_number * 28, 64, 28)
  if pokemon.type1 == pokemon.type2
    overlay.blt(x_pos + (width / 2), y_pos, typebitmap.bitmap, type1rect)
  else
    overlay.blt(x_pos, y_pos, typebitmap.bitmap, type1rect)
    overlay.blt(x_pos + width, y_pos, typebitmap.bitmap, type2rect)
  end
  return viewport
end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item
  if it1 != nil
    $PokemonBag.pbStoreItem(it1, 1)
  end
  if it2 != nil
    $PokemonBag.pbStoreItem(it2, 1)
  end
  pokemon.item = nil
  poke2.item = nil
end

#A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
# 
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    #if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3  
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    #else
    #pokemon.moves[move].dmgup+=1
    #pokemon.moves[move].damage +=5
    #pokemon.moves[move].accuracy -=5

    #movename=PBMoves.getName(pokemon.moves[move].id)
    #scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    #next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    #end
  end
})

##New "stones"
# ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
# #
# ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

#easter egg for evolving shellder into slowbro's tail
ItemHandlers::UseOnPokemon.add(:SLOWPOKETAIL, proc { |item, pokemon, scene|
  shellbroNum = NB_POKEMON * PBSpecies::SHELLDER + PBSpecies::SLOWBRO #SHELLBRO
  newspecies = pokemon.species == PBSpecies::SHELLDER ? shellbroNum : -1
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 }) if scene.pbHasAnnotations?
      scene.pbRefresh
    }
    next true
  end
})
#
# ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
ItemHandlers::UseOnPokemon.add(:POISONMUSHROOM, proc { |item, pkmn, scene|
  if pkmn.status != :POISON
    pkmn.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pkmn.name))
  end
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:POISONMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  if battler.status != :POISON
    battler.status = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned from eating the mushroom.", pokemon.name))
  end
  pbBattleHPItem(pokemon, battler, 10, scene)
})

ItemHandlers::UseOnPokemon.add(:TINYMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:TINYMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BIGMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 10, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BIGMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:BALMMUSHROOM, proc { |item, pkmn, scene|
  next pbHPItem(pkmn, 999, scene)
})
ItemHandlers::BattleUseOnPokemon.add(:BALMMUSHROOM, proc { |item, pokemon, battler, choices, scene|
  next pbBattleHPItem(pokemon, battler, 999, scene)
})

#TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  if Settings::ROAMING_SPECIES.length == 0
    Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
  else
    text = "\\l[8]"
    min = $game_switches[350] ? 0 : 1
    for i in min...Settings::ROAMING_SPECIES.length
      poke = Settings::ROAMING_SPECIES[i]
      next if poke == PBSPecies::FEEBAS
      if $game_switches[poke[2]]
        status = $PokemonGlobal.roamPokemon[i]
        if status == true
          if $PokemonGlobal.roamPokemonCaught[i]
            text += _INTL("{1} has been caught.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          else
            text += _INTL("{1} has been defeated.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          end
        else
          curmap = $PokemonGlobal.roamPosition[i]
          if curmap
            mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

            if curmap == $game_map.map_id
              text += _INTL("Beep beep! {1} appears to be nearby!",
                            PBSpecies.getName(getID(PBSpecies, poke[0])))
            else
              text += _INTL("{1} is roaming around {3}",
                            PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
                            mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
            end
          else
            text += _INTL("{1} is roaming in an unknown area.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
          end
        end
      else
        #text+=_INTL("{1} does not appear to be roaming.",
        #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
      end
      text += "\n" if i < Settings::ROAMING_SPECIES.length - 1
    end
    Kernel.pbMessage(text)
  end
})

####EXP. ALL
#Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc 
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

# ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, poke, scene|
#   abilityList = poke.getAbilityList
#   abil1 = 0; abil2 = 0
#   for i in abilityList
#     abil1 = i[0] if i[1] == 0
#     abil2 = i[1] if i[1] == 1
#   end
#   if poke.abilityIndex() >= 2 || abil1 == abil2
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   if Kernel.pbConfirmMessage(_INTL("Do you want to change {1}'s ability?",
#                                    poke.name))
#
#     if poke.abilityIndex() == 0
#       poke.setAbility(1)
#     else
#       poke.setAbility(0)
#     end
#     scene.pbDisplay(_INTL("{1}'s ability was changed!", poke.name))
#     next true
#   end
#   next false
#
# })

#NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.egg?
    if pokemon.steps_to_hatch <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.steps_to_hatch = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR_NORMAL, proc { |item, pokemon, scene|
  if pokemon.egg?
    steps = pokemon.steps_to_hatch
    steps = (steps / 1.5).ceil
    # steps -= 2000 / (pokemon.nbIncubatorsUsed + 1).ceil
    if steps <= 1
      pokemon.steps_to_hatch = 1
    else
      pokemon.steps_to_hatch = steps
    end
    scene.pbDisplay(_INTL("Incubating..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("..."))
    scene.pbDisplay(_INTL("The egg is closer to hatching!"))

    # if pokemon.steps_to_hatch <= 1
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("The egg is ready to hatch!"))
    #   next false
    # else
    #   scene.pbDisplay(_INTL("Incubating..."))
    #   scene.pbDisplay(_INTL("..."))
    #   scene.pbDisplay(_INTL("..."))
    #   if pokemon.nbIncubatorsUsed >= 10
    #     scene.pbDisplay(_INTL("The egg is a bit closer to hatching"))
    #   else
    #     scene.pbDisplay(_INTL("The egg is closer to hatching"))
    #   end
    #   pokemon.incrIncubator()
    #   next true
    # end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  next false if pokemon.egg?
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

def pbForceEvo(pokemon)
  evolutions = getEvolvedSpecies(pokemon)
  return false if evolutions.empty?
  #if multiple evolutions, pick a random one
  #(format of returned value is [[speciesNum, level]])
  newspecies = evolutions[rand(evolutions.length - 1)][0]
  return false if newspecies == nil
  evo = PokemonEvolutionScene.new
  evo.pbStartScreen(pokemon, newspecies)
  evo.pbEvolution
  evo.pbEndScreen
  return true
end

# format of returned value is [[speciesNum, evolutionMethod],[speciesNum, evolutionMethod],etc.]
def getEvolvedSpecies(pokemon)
  return GameData::Species.get(pokemon.species).get_evolutions(true)
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS2, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

def pbDNASplicing(pokemon, scene, supersplicers = false, superSplicer = false)
  playingBGM = $game_system.getPlayingBGM
  dexNumber = pokemon.species_data.id_number
  if (pokemon.species_data.id_number <= NB_POKEMON)
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        return false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.form = 0
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        return true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if (poke2.species_data.id_number <= NB_POKEMON) && poke2 != pokemon
          #check if fainted

          if pokemon.egg? || poke2.egg?
            scene.pbDisplay(_INTL("It's impossible to fuse an egg!"))
            return false
          end
          if pokemon.hp == 0 || poke2.hp == 0
            scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
            return false
          end
          if (pbFuse(pokemon, poke2, superSplicer))
            pbRemovePokemonAt(chosen)
            scene.pbHardRefresh
            pbBGMPlay(playingBGM)
            return true
          end
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
          return false
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
          return false
        end
      else
        return false
      end
    end
  else
    #UNFUSE
    return true if pbUnfuse(pokemon, scene, supersplicers)
  end
end

def pbFuse(pokemon, poke2, supersplicers = false)
  newid = (pokemon.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number

  pathCustom = _INTL("Graphics/CustomBattlers/{1}.{2}.png", poke2.species_data.id_number, pokemon.species_data.id_number)
  hasCustom = false
  if (pbResolveBitmap(pathCustom))
    picturePath = pathCustom
    hasCustom = true
  else
    picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png", poke2.species_data.id_number, pokemon.species_data.id_number)
  end

  previewwindow = PictureWindow.new(picturePath)

  new_level = calculateFusedPokemonLevel(pokemon.level, poke2.level, supersplicers)
  typeWindow = drawPokemonType(newid)
  drawFusionPreviewText(typeWindow, "Lv. " + new_level.to_s, 232, 0,)

  if !$Trainer.seen?(newid)
    if hasCustom
      previewwindow.picture.pbSetColor(150, 255, 150, 200)
    else
      previewwindow.picture.pbSetColor(255, 255, 255, 200)
    end
  end
  previewwindow.x = (Graphics.width / 2) - (previewwindow.width / 2)
  previewwindow.y = ((Graphics.height - 96) / 2) - (previewwindow.height / 2)
  previewwindow.z = 1000000

  if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?", newid)))
    previewwindow.dispose
    typeWindow.dispose
    fus = PokemonFusionScene.new
    if (fus.pbStartScreen(pokemon, poke2, newid))
      returnItemsToBag(pokemon, poke2)
      fus.pbFusionScreen(false, supersplicers)
      $game_variables[126] += 1 #fuse counter
      fus.pbEndScreen
      return true

    end
  else
    previewwindow.dispose
    typeWindow.dispose
    return false
  end

end

def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)

  bodyPoke = getBasePokemonID(pokemon.species_data.id_number, true)
  headPoke = getBasePokemonID(pokemon.species_data.id_number, false)

  if (pokemon.obtain_method == 2 || pokemon.ot != $Trainer.name) # && !canunfuse
    scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
    return false
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
      if pokemon.species_data.id_number > (NB_POKEMON * NB_POKEMON) + NB_POKEMON #triple fusion
        scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
        return false
      end

      keepInParty = 0
      if $Trainer.party.length >= 6 && !pcPosition
        scene.pbDisplay(_INTL("Your party is full! Keep which Pokémon in party?"))
        choice = Kernel.pbMessage("Select a Pokémon to keep in your party.", [_INTL("{1}", PBSpecies.getName(bodyPoke)), _INTL("{1}", PBSpecies.getName(headPoke)), "Cancel"], 2)
        if choice == 2
          return false
        else
          keepInParty = choice
        end
      end

      scene.pbDisplay(_INTL("Unfusing ... "))
      scene.pbDisplay(_INTL(" ... "))
      scene.pbDisplay(_INTL(" ... "))

      if pokemon.exp_when_fused_head == nil || pokemon.exp_when_fused_body == nil
        new_level = calculateUnfuseLevelOldMethod(pokemon, supersplicers)
        body_level = new_level
        head_level = new_level
        poke1 = Pokemon.new(bodyPoke, body_level)
        poke2 = Pokemon.new(headPoke, head_level)
      else
        exp_body = pokemon.exp_when_fused_body + pokemon.exp_gained_since_fused
        exp_head = pokemon.exp_when_fused_head + pokemon.exp_gained_since_fused

        poke1 = Pokemon.new(bodyPoke, pokemon.level)
        poke2 = Pokemon.new(headPoke, pokemon.level)
        poke1.exp = exp_body
        poke2.exp = exp_head
      end
      body_level = poke1.level
      head_level = poke2.level

      pokemon.exp_gained_since_fused = 0
      pokemon.exp_when_fused_head = nil
      pokemon.exp_when_fused_body = nil


      if pokemon.shiny?
        pokemon.shiny = false
        if pokemon.bodyShiny? && pokemon.headShiny?
          pokemon.shiny = true
          poke2.shiny = true
        elsif pokemon.bodyShiny?
          pokemon.shiny = true
        elsif pokemon.headShiny?
          poke2.shiny = true
        else         #shiny was obtained already fused
        if rand(2) == 0
            pokemon.shiny = true
          else
            poke2.shiny = true
          end
        end
      end
      pokemon.debug_shiny=true if pokemon.debug_shiny && pokemon.body_shiny
      poke2.debug_shiny=true if pokemon.debug_shiny || poke2.head_shiny

      pokemon.body_shiny=false
      pokemon.head_shiny=false


      if !pokemon.shiny?
        pokemon.debug_shiny=false
      end
      if !poke2.shiny?
        poke2.debug_shiny=false
      end

      if $Trainer.party.length >= 6
        if (keepInParty == 0)
          $PokemonStorage.pbStoreCaught(poke2)
          scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
        else
          poke2 = Pokemon.new(bodyPoke, body_level)
          poke1 = Pokemon.new(headPoke, head_level)

          if pcPosition != nil
            box = pcPosition[0]
            index = pcPosition[1]
            #todo: store at next available position from current position
            $PokemonStorage.pbStoreCaught(poke2)
          else
            $PokemonStorage.pbStoreCaught(poke2)
            scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
          end

        end
      else
        if pcPosition != nil
          box = pcPosition[0]
          index = pcPosition[1]

          #todo: store at next available position from current position
          $PokemonStorage.pbStoreCaught(poke2)
        else
          Kernel.pbAddPokemonSilent(poke2, poke2.level)
        end
      end

      #On ajoute l'autre dans le pokedex aussi
      $Trainer.pokedex.set_seen(poke1.species)
      $Trainer.pokedex.set_owned(poke1.species)

      pokemon.species = poke1.species
      pokemon.level = poke1.level
      pokemon.name = poke1.name
      pokemon.moves = poke1.moves
      pokemon.obtain_method = 0
      poke1.obtain_method = 0

      #scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
      return true
    end
  end
end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item

  $PokemonBag.pbStoreItem(it1, 1) if it1 != nil
  $PokemonBag.pbStoreItem(it2, 1) if it2 != nil

  pokemon.item = nil
  poke2.item = nil
end

#A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
# 
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    #if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3  
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    #else
    #pokemon.moves[move].dmgup+=1
    #pokemon.moves[move].damage +=5
    #pokemon.moves[move].accuracy -=5

    #movename=PBMoves.getName(pokemon.moves[move].id)
    #scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    #next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    #end
  end
})

##New "stones"
# ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

# ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })
#
# ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
#   if (pokemon.isShadow? rescue false)
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   end
#   newspecies = pbCheckEvolution(pokemon, item)
#   if newspecies <= 0
#     scene.pbDisplay(_INTL("It won't have any effect."))
#     next false
#   else
#     pbFadeOutInWithMusic(99999) {
#       evo = PokemonEvolutionScene.new
#       evo.pbStartScreen(pokemon, newspecies)
#       evo.pbEvolution(false)
#       evo.pbEndScreen
#       scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
#       scene.pbRefresh
#     }
#     next true
#   end
# })

#
# ItemHandlers::UseOnPokemon.copy(:FIRESTONE,
#    :THUNDERSTONE,:WATERSTONE,:LEAFSTONE,:MOONSTONE,
#    :SUNSTONE,:DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:OVALSTONE,
#    :UPGRADE,:DUBIOUSDISC,:ICESTONE,:MAGNETSTONE)

#Quest log

ItemHandlers::UseFromBag.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
  next 1
})

ItemHandlers::UseInField.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
})

#TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  track_pokemon()
})
ItemHandlers::UseFromBag.add(:REVEALGLASS, proc { |item|
  track_pokemon()
})

def track_pokemon()
  nbRoaming = 0
  if Settings::ROAMING_SPECIES.length == 0
    Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
  else
    text = "\\l[8]"
    min = $game_switches[350] ? 0 : 1
    for i in min...Settings::ROAMING_SPECIES.length
      poke = Settings::ROAMING_SPECIES[i]
      next if poke[0] == :FEEBAS
      if $game_switches[poke[2]]
        status = $PokemonGlobal.roamPokemon[i]
        if status == true
          if $PokemonGlobal.roamPokemonCaught[i]
            text += _INTL("{1} has been caught.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          else
            text += _INTL("{1} has been defeated.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          end
        else
          nbRoaming += 1
          curmap = $PokemonGlobal.roamPosition[i]
          if curmap
            mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

            if curmap == $game_map.map_id
              text += _INTL("Beep beep! {1} appears to be nearby!",
                            PBSpecies.getName(getID(PBSpecies, poke[0])))
            else
              text += _INTL("{1} is roaming around {3}",
                            PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
                            mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
            end
          else
            text += _INTL("{1} is roaming in an unknown area.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
          end
        end
      else
        #text+=_INTL("{1} does not appear to be roaming.",
        #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
      end
      #text += "\n" if i < Settings::ROAMING_SPECIES.length - 1
    end
    if nbRoaming == 0
      text = "No Pokémon appears to be roaming at this moment."
    end
    Kernel.pbMessage(text)
  end
end

####EXP. ALL
#Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc 
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})