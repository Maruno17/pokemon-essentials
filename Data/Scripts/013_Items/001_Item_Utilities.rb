#===============================================================================
# ItemHandlers
#===============================================================================
module ItemHandlers
  UseText            = ItemHandlerHash.new
  UseFromBag         = ItemHandlerHash.new
  ConfirmUseInField  = ItemHandlerHash.new
  UseInField         = ItemHandlerHash.new
  UseOnPokemon       = ItemHandlerHash.new
  CanUseInBattle     = ItemHandlerHash.new
  UseInBattle        = ItemHandlerHash.new
  BattleUseOnBattler = ItemHandlerHash.new
  BattleUseOnPokemon = ItemHandlerHash.new

  def self.hasUseText(item)
    return UseText[item]!=nil
  end

  def self.hasOutHandler(item)                       # Shows "Use" option in Bag
    return UseFromBag[item]!=nil || UseInField[item]!=nil || UseOnPokemon[item]!=nil
  end

  def self.hasUseInFieldHandler(item)           # Shows "Register" option in Bag
    return UseInField[item]!=nil
  end

  def self.hasUseOnPokemon(item)
    return UseOnPokemon[item]!=nil
  end

  def self.hasUseInBattle(item)
    return UseInBattle[item]!=nil
  end

  def self.hasBattleUseOnBattler(item)
    return BattleUseOnBattler[item]!=nil
  end

  def self.hasBattleUseOnPokemon(item)
    return BattleUseOnPokemon[item]!=nil
  end

  # Returns text to display instead of "Use"
  def self.getUseText(item)
    return UseText.trigger(item)
  end

  # Return value:
  # 0 - Item not used
  # 1 - Item used, don't end screen
  # 2 - Item used, end screen
  # 3 - Item used, don't end screen, consume item
  # 4 - Item used, end screen, consume item
  def self.triggerUseFromBag(item)
    return UseFromBag.trigger(item) if UseFromBag[item]
    # No UseFromBag handler exists; check the UseInField handler if present
    return UseInField.trigger(item) if UseInField[item]
    return 0
  end

  # Returns whether item can be used
  def self.triggerConfirmUseInField(item)
    return true if !ConfirmUseInField[item]
    return ConfirmUseInField.trigger(item)
  end

  # Return value:
  # -1 - Item effect not found
  # 0  - Item not used
  # 1  - Item used
  # 3  - Item used, consume item
  def self.triggerUseInField(item)
    return -1 if !UseInField[item]
    return UseInField.trigger(item)
  end

  # Returns whether item was used
  def self.triggerUseOnPokemon(item,pkmn,scene)
    return false if !UseOnPokemon[item]
    return UseOnPokemon.trigger(item,pkmn,scene)
  end

  def self.triggerCanUseInBattle(item,pkmn,battler,move,firstAction,battle,scene,showMessages=true)
    return true if !CanUseInBattle[item]   # Can use the item by default
    return CanUseInBattle.trigger(item,pkmn,battler,move,firstAction,battle,scene,showMessages)
  end

  def self.triggerUseInBattle(item,battler,battle)
    UseInBattle.trigger(item,battler,battle)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnBattler(item,battler,scene)
    return false if !BattleUseOnBattler[item]
    return BattleUseOnBattler.trigger(item,battler,scene)
  end

  # Returns whether item was used
  def self.triggerBattleUseOnPokemon(item,pkmn,battler,choices,scene)
    return false if !BattleUseOnPokemon[item]
    return BattleUseOnPokemon.trigger(item,pkmn,battler,choices,scene)
  end
end



def pbCanRegisterItem?(item)
  return ItemHandlers.hasUseInFieldHandler(item)
end

def pbCanUseOnPokemon?(item)
  return ItemHandlers.hasUseOnPokemon(item) || GameData::Item.get(item).is_machine?
end



#===============================================================================
# Change a Pokémon's level
#===============================================================================
def pbChangeLevel(pkmn,newlevel,scene)
  newlevel = newlevel.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level==newlevel
    pbMessage(_INTL("{1}'s level remained unchanged.",pkmn.name))
  elsif pkmn.level>newlevel
    attackdiff  = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.level = newlevel
    pkmn.calc_stats
    scene.pbRefresh
    pbMessage(_INTL("{1} dropped to Lv. {2}!",pkmn.name,pkmn.level))
    attackdiff  = pkmn.attack-attackdiff
    defensediff = pkmn.defense-defensediff
    speeddiff   = pkmn.speed-speeddiff
    spatkdiff   = pkmn.spatk-spatkdiff
    spdefdiff   = pkmn.spdef-spdefdiff
    totalhpdiff = pkmn.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed))
  else
    attackdiff  = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.level = newlevel
    pkmn.changeHappiness("vitamin")
    pkmn.calc_stats
    scene.pbRefresh
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    end
    attackdiff  = pkmn.attack-attackdiff
    defensediff = pkmn.defense-defensediff
    speeddiff   = pkmn.speed-speeddiff
    spatkdiff   = pkmn.spatk-spatkdiff
    spdefdiff   = pkmn.spdef-spdefdiff
    totalhpdiff = pkmn.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff),scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed),scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    for i in movelist
      next if i[0]!=pkmn.level
      pbLearnMove(pkmn,i[1],true) { scene.pbUpdate }
    end
    # Check for evolution
    newspecies = pkmn.check_evolution_on_level_up
    if newspecies
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
  end
end

def pbTopRightWindow(text, scene = nil)
  window = Window_AdvancedTextPokemon.new(text)
  window.width = 198
  window.x     = Graphics.width-window.width
  window.y     = 0
  window.z     = 99999
  pbPlayDecisionSE
  loop do
    Graphics.update
    Input.update
    window.update
    scene.pbUpdate if scene
    break if Input.trigger?(Input::USE)
  end
  window.dispose
end

#===============================================================================
# Restore HP
#===============================================================================
def pbItemRestoreHP(pkmn,restoreHP)
  newHP = pkmn.hp+restoreHP
  newHP = pkmn.totalhp if newHP>pkmn.totalhp
  hpGain = newHP-pkmn.hp
  pkmn.hp = newHP
  return hpGain
end

def pbHPItem(pkmn,restoreHP,scene)
  if !pkmn.able? || pkmn.hp==pkmn.totalhp
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  hpGain = pbItemRestoreHP(pkmn,restoreHP)
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pkmn.name,hpGain))
  return true
end

def pbBattleHPItem(pkmn,battler,restoreHP,scene)
  if battler
    if battler.pbRecoverHP(restoreHP)>0
      scene.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    end
  else
    if pbItemRestoreHP(pkmn,restoreHP)>0
      scene.pbDisplay(_INTL("{1}'s HP was restored.",pkmn.name))
    end
  end
  return true
end

#===============================================================================
# Restore PP
#===============================================================================
def pbRestorePP(pkmn,idxMove,pp)
  return 0 if !pkmn.moves[idxMove] || !pkmn.moves[idxMove].id
  return 0 if pkmn.moves[idxMove].total_pp<=0
  oldpp = pkmn.moves[idxMove].pp
  newpp = pkmn.moves[idxMove].pp+pp
  newpp = pkmn.moves[idxMove].total_pp if newpp>pkmn.moves[idxMove].total_pp
  pkmn.moves[idxMove].pp = newpp
  return newpp-oldpp
end

def pbBattleRestorePP(pkmn, battler, idxMove, pp)
  return if pbRestorePP(pkmn,idxMove,pp) == 0
  if battler && !battler.effects[PBEffects::Transform] &&
     battler.moves[idxMove] && battler.moves[idxMove].id == pkmn.moves[idxMove].id
    battler.pbSetPP(battler.moves[idxMove], pkmn.moves[idxMove].pp)
  end
end

#===============================================================================
# Change EVs
#===============================================================================
def pbJustRaiseEffortValues(pkmn, stat, evGain)
  stat = GameData::Stat.get(stat).id
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbRaiseEffortValues(pkmn, stat, evGain = 10, ev_limit = true)
  stat = GameData::Stat.get(stat).id
  return 0 if ev_limit && pkmn.ev[stat] >= 100
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, 100 - pkmn.ev[stat]) if ev_limit
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbRaiseHappinessAndLowerEV(pkmn,scene,stat,messages)
  h = pkmn.happiness<255
  e = pkmn.ev[stat]>0
  if !h && !e
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if h
    pkmn.changeHappiness("evberry")
  end
  if e
    pkmn.ev[stat] -= 10
    pkmn.ev[stat] = 0 if pkmn.ev[stat]<0
    pkmn.calc_stats
  end
  scene.pbRefresh
  scene.pbDisplay(messages[2-(h ? 0 : 2)-(e ? 0 : 1)])
  return true
end

#===============================================================================
# Battle items
#===============================================================================
def pbBattleItemCanCureStatus?(status,pkmn,scene,showMessages)
  if !pkmn.able? || pkmn.status!=status
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    return false
  end
  return true
end

def pbBattleItemCanRaiseStat?(stat,battler,scene,showMessages)
  if !battler || !battler.pbCanRaiseStatStage?(stat,battler)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    return false
  end
  return true
end

#===============================================================================
# Decide whether the player is able to ride/dismount their Bicycle
#===============================================================================
def pbBikeCheck
  if $PokemonGlobal.surfing || $PokemonGlobal.diving ||
     (!$PokemonGlobal.bicycle && $game_player.pbTerrainTag.must_walk)
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if $PokemonGlobal.bicycle
    if map_metadata && map_metadata.always_bicycle
      pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  end
  if !map_metadata || (!map_metadata.can_bicycle && !map_metadata.outdoor_map)
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  return true
end

#===============================================================================
# Find the closest hidden item (for Itemfinder)
#===============================================================================
def pbClosestHiddenItem
  result = []
  playerX = $game_player.x
  playerY = $game_player.y
  for event in $game_map.events.values
    next if !event.name[/hiddenitem/i]
    next if (playerX-event.x).abs>=8
    next if (playerY-event.y).abs>=6
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    result.push(event)
  end
  return nil if result.length==0
  ret = nil
  retmin = 0
  for event in result
    dist = (playerX-event.x).abs+(playerY-event.y).abs
    next if ret && retmin<=dist
    ret = event
    retmin = dist
  end
  return ret
end

#===============================================================================
# Teach and forget a move
#===============================================================================
def pbLearnMove(pkmn,move,ignoreifknown=false,bymachine=false,&block)
  return false if !pkmn
  move = GameData::Move.get(move).id
  if pkmn.egg? && !$DEBUG
    pbMessage(_INTL("Eggs can't be taught any moves."),&block)
    return false
  end
  if pkmn.shadowPokemon?
    pbMessage(_INTL("Shadow Pokémon can't be taught any moves."),&block)
    return false
  end
  pkmnname = pkmn.name
  movename = GameData::Move.get(move).name
  if pkmn.hasMove?(move)
    pbMessage(_INTL("{1} already knows {2}.",pkmnname,movename),&block) if !ignoreifknown
    return false
  end
  if pkmn.numMoves<Pokemon::MAX_MOVES
    pkmn.learn_move(move)
    pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pkmnname,movename),&block)
    return true
  end
  loop do
    pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.\1",
      pkmnname, movename, pkmn.numMoves.to_word), &block) if !bymachine
    pbMessage(_INTL("Please choose a move that will be replaced with {1}.",movename),&block)
    forgetmove = pbForgetMove(pkmn,move)
    if forgetmove>=0
      oldmovename = pkmn.moves[forgetmove].name
      oldmovepp   = pkmn.moves[forgetmove].pp
      pkmn.moves[forgetmove] = Pokemon::Move.new(move)   # Replaces current/total PP
      if bymachine && Settings::TAUGHT_MACHINES_KEEP_OLD_PP
        pkmn.moves[forgetmove].pp = [oldmovepp,pkmn.moves[forgetmove].total_pp].min
      end
      pbMessage(_INTL("1, 2, and...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"),&block)
      pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",pkmnname,oldmovename),&block)
      pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",pkmnname,movename),&block)
      pkmn.changeHappiness("machine") if bymachine
      return true
    elsif pbConfirmMessage(_INTL("Give up on learning {1}?",movename),&block)
      pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename),&block)
      return false
    end
  end
end

def pbForgetMove(pkmn,moveToLearn)
  ret = -1
  pbFadeOutIn {
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pkmn],0,moveToLearn)
  }
  return ret
end

#===============================================================================
# Use an item from the Bag and/or on a Pokémon
#===============================================================================
# @return [Integer] 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbUseItem(bag,item,bagscene=nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if itm.is_machine?    # TM or TR or HM
    if $Trainer.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    machine = itm.move
    return 0 if !machine
    movename = GameData::Move.get(machine).name
    pbMessage(_INTL("\\se[PC access]You booted up {1}.\1",itm.name))
    if !pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?",movename))
      return 0
    elsif pbMoveTutorChoose(machine,nil,true,itm.is_TR?)
      bag.pbDeleteItem(item) if itm.is_TR?
      return 1
    end
    return 0
  elsif useType==1 || useType==5   # Item is usable on a Pokémon
    if $Trainer.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      for pkmn in $Trainer.party
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"),false,annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen<0
          ret = false
          break
        end
        pkmn = $Trainer.party[chosen]
        if pbCheckUseOnPokemon(item,pkmn,screen)
          ret = ItemHandlers.triggerUseOnPokemon(item,pkmn,screen)
          if ret && useType==1   # Usable on Pokémon, consumed
            bag.pbDeleteItem(item)
            if !bag.pbHasItem?(item)
              pbMessage(_INTL("You used your last {1}.",itm.name)) { screen.pbUpdate }
              break
            end
          end
        end
      end
      screen.pbEndScene
      bagscene.pbRefresh if bagscene
    }
    return (ret) ? 1 : 0
  elsif useType==2   # Item is usable from Bag
    intret = ItemHandlers.triggerUseFromBag(item)
    case intret
    when 0 then return 0
    when 1 then return 1   # Item used
    when 2 then return 2   # Item used, end screen
    when 3                 # Item used, consume item
      bag.pbDeleteItem(item)
      return 1
    when 4                 # Item used, end screen and consume item
      bag.pbDeleteItem(item)
      return 2
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end

# Only called when in the party screen and having chosen an item to be used on
# the selected Pokémon
def pbUseItemOnPokemon(item,pkmn,scene)
  itm = GameData::Item.get(item)
  # TM or HM
  if itm.is_machine?
    machine = itm.move
    return false if !machine
    movename = GameData::Move.get(machine).name
    if pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { scene.pbUpdate }
    elsif !pkmn.compatible_with_move?(machine)
      pbMessage(_INTL("{1} can't learn {2}.",pkmn.name,movename)) { scene.pbUpdate }
    else
      pbMessage(_INTL("\\se[PC access]You booted up {1}.\1",itm.name)) { scene.pbUpdate }
      if pbConfirmMessage(_INTL("Do you want to teach {1} to {2}?",movename,pkmn.name)) { scene.pbUpdate }
        if pbLearnMove(pkmn,machine,false,true) { scene.pbUpdate }
          $PokemonBag.pbDeleteItem(item) if itm.is_TR?
          return true
        end
      end
    end
    return false
  end
  # Other item
  ret = ItemHandlers.triggerUseOnPokemon(item,pkmn,scene)
  scene.pbClearAnnotations
  scene.pbHardRefresh
  useType = itm.field_use
  if ret && useType==1   # Usable on Pokémon, consumed
    $PokemonBag.pbDeleteItem(item)
    if !$PokemonBag.pbHasItem?(item)
      pbMessage(_INTL("You used your last {1}.",itm.name)) { scene.pbUpdate }
    end
  end
  return ret
end

def pbUseKeyItemInField(item)
  ret = ItemHandlers.triggerUseInField(item)
  if ret==-1   # Item effect not found
    pbMessage(_INTL("Can't use that here."))
  elsif ret==3   # Item was used and consumed
    $PokemonBag.pbDeleteItem(item)
  end
  return ret!=-1 && ret!=0
end

def pbUseItemMessage(item)
  itemname = GameData::Item.get(item).name
  if itemname.starts_with_vowel?
    pbMessage(_INTL("You used an {1}.",itemname))
  else
    pbMessage(_INTL("You used a {1}.",itemname))
  end
end

def pbCheckUseOnPokemon(_item,pkmn,_screen)
  return pkmn && !pkmn.egg?
end

#===============================================================================
# Give an item to a Pokémon to hold, and take a held item from a Pokémon
#===============================================================================
def pbGiveItemToPokemon(item,pkmn,scene,pkmnid=0)
  newitemname = GameData::Item.get(item).name
  if pkmn.egg?
    scene.pbDisplay(_INTL("Eggs can't hold items."))
    return false
  elsif pkmn.mail
    scene.pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",pkmn.name))
    return false if !pbTakeItemFromPokemon(pkmn,scene)
  end
  if pkmn.hasItem?
    olditemname = pkmn.item.name
    if pkmn.hasItem?(:LEFTOVERS)
      scene.pbDisplay(_INTL("{1} is already holding some {2}.\1",pkmn.name,olditemname))
    elsif newitemname.starts_with_vowel?
      scene.pbDisplay(_INTL("{1} is already holding an {2}.\1",pkmn.name,olditemname))
    else
      scene.pbDisplay(_INTL("{1} is already holding a {2}.\1",pkmn.name,olditemname))
    end
    if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
      $PokemonBag.pbDeleteItem(item)
      if !$PokemonBag.pbStoreItem(pkmn.item)
        if !$PokemonBag.pbStoreItem(item)
          raise _INTL("Could't re-store deleted item in Bag somehow")
        end
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      else
        if GameData::Item.get(item).is_mail?
          if pbWriteMail(item,pkmn,pkmnid,scene)
            pkmn.item = item
            scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.",olditemname,pkmn.name,newitemname))
            return true
          else
            if !$PokemonBag.pbStoreItem(item)
              raise _INTL("Couldn't re-store deleted item in Bag somehow")
            end
          end
        else
          pkmn.item = item
          scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.",olditemname,pkmn.name,newitemname))
          return true
        end
      end
    end
  else
    if !GameData::Item.get(item).is_mail? || pbWriteMail(item,pkmn,pkmnid,scene)
      $PokemonBag.pbDeleteItem(item)
      pkmn.item = item
      scene.pbDisplay(_INTL("{1} is now holding the {2}.",pkmn.name,newitemname))
      return true
    end
  end
  return false
end

def pbTakeItemFromPokemon(pkmn,scene)
  ret = false
  if !pkmn.hasItem?
    scene.pbDisplay(_INTL("{1} isn't holding anything.",pkmn.name))
  elsif !$PokemonBag.pbCanStore?(pkmn.item)
    scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
  elsif pkmn.mail
    if scene.pbConfirm(_INTL("Save the removed mail in your PC?"))
      if !pbMoveToMailbox(pkmn)
        scene.pbDisplay(_INTL("Your PC's Mailbox is full."))
      else
        scene.pbDisplay(_INTL("The mail was saved in your PC."))
        pkmn.item = nil
        ret = true
      end
    elsif scene.pbConfirm(_INTL("If the mail is removed, its message will be lost. OK?"))
      $PokemonBag.pbStoreItem(pkmn.item)
      scene.pbDisplay(_INTL("Received the {1} from {2}.",pkmn.item.name,pkmn.name))
      pkmn.item = nil
      pkmn.mail = nil
      ret = true
    end
  else
    $PokemonBag.pbStoreItem(pkmn.item)
    scene.pbDisplay(_INTL("Received the {1} from {2}.",pkmn.item.name,pkmn.name))
    pkmn.item = nil
    ret = true
  end
  return ret
end

#===============================================================================
# Choose an item from the Bag
#===============================================================================
def pbChooseItem(var = 0, *args)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseApricorn(var = 0)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_apricorn? })
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

def pbChooseFossil(var = 0)
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_fossil? })
  }
  $game_variables[var] = ret || :NONE if var > 0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message, variable, *args)
  commands = []
  itemid   = []
  for item in args
    next if !GameData::Item.exists?(item)
    itm = GameData::Item.get(item)
    next if !$PokemonBag.pbHasItem?(itm)
    commands.push(itm.name)
    itemid.push(itm.id)
  end
  if commands.length == 0
    $game_variables[variable] = 0
    return nil
  end
  commands.push(_INTL("Cancel"))
  itemid.push(nil)
  ret = pbMessage(message, commands, -1)
  if ret < 0 || ret >= commands.length-1
    $game_variables[variable] = nil
    return nil
  end
  $game_variables[variable] = itemid[ret]
  return itemid[ret]
end
