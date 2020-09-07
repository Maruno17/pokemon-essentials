#===============================================================================
# Technical Records - By Vendily [v18]
#===============================================================================
# This script adds in Technical Records, the replacement to consumable TMs
#  that also have the ability to allow a mon to relearn the move at a
#  Move Relearner if they forget it.
# Also adds in the system for Technical Records using the icon of the move type
#  much like TMs.
#===============================================================================
# To use it, you must create a new item much like you would a TM or HM, but give
#  it Item Usage 6 (if 6 is already used by some other script, you must edit
#  pbIsTechnicalRecord? and pbIsMachine? to use a different number)
#
# To use the type based icons, name the icon "itemRecordX", where X is either
#  the internal name of the type, or the 3 digit padded type number.
#  AKA. Either NORMAL or 001 will work for X
#
# You really should set INFINITE_TMS to true to get the most out of this script
#  but it's not a requirement at all.
#===============================================================================
begin
PluginManager.register({
  :name    => "Technical Records",
  :version => "1.0",
  :link    => "https://reliccastle.com/resources/443/",
  :credits => "Vendily"
})
rescue
  raise "This script only funtions in v18."
end

def pbIsMachine?(item)
  ret = pbGetItemData(item,ITEM_FIELD_USE)
  return ret && (ret==3 || ret==4 || ret==6)
end

def pbIsTechnicalRecord?(item)
  ret = pbGetItemData(item,ITEM_FIELD_USE)
  return ret && ret==6
end

#===============================================================================
# Use an item from the Bag and/or on a Pokémon
#===============================================================================
def pbUseItem(bag,item,bagscene=nil)
  found = false
  useType = pbGetItemData(item,ITEM_FIELD_USE)
  if pbIsMachine?(item)    # TM or HM or TR
    if $Trainer.pokemonCount==0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    machine = pbGetMachine(item)
    return 0 if machine==nil
    movename = PBMoves.getName(machine)
    pbMessage(_INTL("\\se[PC access]You booted up {1}.\1",PBItems.getName(item)))
    if !pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?",movename))
      return 0
    elsif mon=pbMoveTutorChoose(machine,nil,true)
      bag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITE_TMS
      if pbIsTechnicalRecord?(item)
        bag.pbDeleteItem(item)
        $Trainer.party[mon].trmoves.push(machine)
      end
      return 1
    end
    return 0
  elsif useType && (useType==1 || useType==5) # Item is usable on a Pokémon
    if $Trainer.pokemonCount==0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if pbIsEvolutionStone?(item)
      annot = []
      for pkmn in $Trainer.party
        elig = pbCheckEvolution(pkmn,item)>0
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
              pbMessage(_INTL("You used your last {1}.",PBItems.getName(item)))
              break
            end
          end
        end
      end
      screen.pbEndScene
      bagscene.pbRefresh if bagscene
    }
    return (ret) ? 1 : 0
  elsif useType && useType==2   # Item is usable from bag
    intret = ItemHandlers.triggerUseFromBag(item)
    case intret
    when 0; return 0
    when 1; return 1   # Item used
    when 2; return 2   # Item used, end screen
    when 3; bag.pbDeleteItem(item); return 1   # Item used, consume item
    when 4; bag.pbDeleteItem(item); return 2   # Item used, end screen and consume item
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
  # TM or HM
  if pbIsMachine?(item)
    machine = pbGetMachine(item)
    return false if machine==nil
    movename = PBMoves.getName(machine)
    if pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
    elsif !pkmn.compatibleWithMove?(machine)
      pbMessage(_INTL("{1} can't learn {2}.",pkmn.name,movename))
    else
      pbMessage(_INTL("\\se[PC access]You booted up {1}.\1",PBItems.getName(item)))
      if pbConfirmMessage(_INTL("Do you want to teach {1} to {2}?",movename,pkmn.name))
        if pbLearnMove(pkmn,machine,false,true)
          $PokemonBag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITE_TMS
          if pbIsTechnicalRecord?(item)
            $PokemonBag.pbDeleteItem(item)
            pkmn.trmoves.push(machine)
          end
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
  useType = pbGetItemData(item,ITEM_FIELD_USE)
  if ret && useType && useType==1   # Usable on Pokémon, consumed
    $PokemonBag.pbDeleteItem(item)
    if !$PokemonBag.pbHasItem?(item)
      pbMessage(_INTL("You used your last {1}.",PBItems.getName(item)))
    end
  end
  return ret
end

def pbMoveTutorChoose(move,movelist=nil,bymachine=false)
  ret = false
  move = getID(PBMoves,move)
  if movelist!=nil && movelist.is_a?(Array)
    for i in 0...movelist.length
      movelist[i] = getID(PBSpecies,movelist[i])
    end
  end
  pbFadeOutIn {
    movename = PBMoves.getName(move)
    annot = pbMoveTutorAnnotations(move,movelist)
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
    loop do
      chosen = screen.pbChoosePokemon
      if chosen>=0
        pokemon = $Trainer.party[chosen]
        if pokemon.egg?
          pbMessage(_INTL("Eggs can't be taught any moves."))
        elsif pokemon.shadowPokemon?
          pbMessage(_INTL("Shadow Pokémon can't be taught any moves."))
        elsif movelist && !movelist.any? { |j| j==pokemon.species }
          pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename))
        elsif !pokemon.compatibleWithMove?(move)
          pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename))
        else
          if pbLearnMove(pokemon,move,false,bymachine)
            ret = chosen
            break
          end
        end
      else
        break
      end  
    end
    screen.pbEndScene
  }
  return ret   # Returns whether the move was learned by a Pokemon
end

#===============================================================================
# Load item icons
#===============================================================================
def pbItemIconFile(item)
  return nil if !item
  bitmapFileName = nil
  if item==0
    bitmapFileName = sprintf("Graphics/Icons/itemBack")
  else
    bitmapFileName = sprintf("Graphics/Icons/item%s",getConstantName(PBItems,item)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/item%03d",item)
      if !pbResolveBitmap(bitmapFileName) && pbIsTechnicalRecord?(item)
        move = pbGetMachine(item)
        type = pbGetMoveData(move,MOVE_TYPE)
        bitmapFileName = sprintf("Graphics/Icons/itemRecord%s",getConstantName(PBTypes,type)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/itemRecord%03d",type)
        end
      end
      if !pbResolveBitmap(bitmapFileName) && pbIsMachine?(item)
        move = pbGetMachine(item)
        type = pbGetMoveData(move,MOVE_TYPE)
        bitmapFileName = sprintf("Graphics/Icons/itemMachine%s",getConstantName(PBTypes,type)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/itemMachine%03d",type)
        end
      end
      bitmapFileName = "Graphics/Icons/item000" if !pbResolveBitmap(bitmapFileName)
    end
  end
  return bitmapFileName
end

class PokeBattle_Pokemon
  attr_accessor :trmoves
  
  def trmoves
    @trmoves=[] if !@trmoves
    return @trmoves
  end
end

alias tr_pbGetRelearnableMoves pbGetRelearnableMoves
def pbGetRelearnableMoves(pokemon)
  ret=tr_pbGetRelearnableMoves(pokemon)
  trmoves=[]
  for i in pokemon.trmoves
    trmoves.push(i) if !pokemon.hasMove?(i) && !ret.include?(i)
  end
  ret=ret+trmoves
  return ret|[]
end