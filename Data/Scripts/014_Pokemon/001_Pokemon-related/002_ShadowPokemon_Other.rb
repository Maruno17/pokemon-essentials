=begin
All types except Shadow have Shadow as a weakness.
Shadow has Shadow as a resistance.
On a side note, the Shadow moves in Colosseum will not be affected by Weaknesses
or Resistances, while in XD the Shadow-type is Super-Effective against all other
types.
2/5 - display nature

XD - Shadow Rush -- 55, 100 - Deals damage.
Colosseum - Shadow Rush -- 90, 100
If this attack is successful, user loses half of HP lost by opponent due to this
attack (recoil). If user is in Hyper Mode, this attack has a good chance for a
critical hit.
=end

#===============================================================================
# Purify a Shadow Pokémon.
#===============================================================================
def pbPurify(pkmn, scene)
  return if !pkmn.shadowPokemon? || pkmn.heart_gauge != 0
  $stats.shadow_pokemon_purified += 1
  pkmn.shadow = false
  pkmn.giveRibbon(:NATIONAL)
  scene.pbDisplay(_INTL("{1} opened the door to its heart!", pkmn.name))
  old_moves = []
  pkmn.moves.each { |m| old_moves.push(m.id) }
  pkmn.update_shadow_moves
  pkmn.moves.each_with_index do |m, i|
    next if m.id == old_moves[i]
    scene.pbDisplay(_INTL("{1} regained the move {2}!", pkmn.name, m.name))
  end
  pkmn.record_first_moves
  if pkmn.saved_ev
    pkmn.add_evs(pkmn.saved_ev)
    pkmn.saved_ev = nil
  end
  if pkmn.saved_exp
    newexp = pkmn.growth_rate.add_exp(pkmn.exp, pkmn.saved_exp || 0)
    pkmn.saved_exp = nil
    newlevel = pkmn.growth_rate.level_from_exp(newexp)
    curlevel = pkmn.level
    if newexp != pkmn.exp
      scene.pbDisplay(_INTL("{1} regained {2} Exp. Points!", pkmn.name, newexp - pkmn.exp))
    end
    if newlevel == curlevel
      pkmn.exp = newexp
      pkmn.calc_stats
    else
      pbChangeLevel(pkmn, newlevel, scene)   # for convenience
      pkmn.exp = newexp
    end
  end
  if scene.pbConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.speciesName))
    newname = pbEnterPokemonName(_INTL("{1}'s nickname?", pkmn.speciesName),
                                 0, Pokemon::MAX_NAME_SIZE, "", pkmn)
    pkmn.name = newname
  end
end



#===============================================================================
# Relic Stone scene.
#===============================================================================
class RelicStoneScene
  def pbPurify
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbDisplay(msg,brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbStartScene(pokemon)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @pokemon = pokemon
    addBackgroundPlane(@sprites,"bg","relicstonebg",@viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].viewport = @viewport
    @sprites["msgwindow"].x        = 0
    @sprites["msgwindow"].y        = Graphics.height-96
    @sprites["msgwindow"].width    = Graphics.width
    @sprites["msgwindow"].height   = 96
    @sprites["msgwindow"].text     = ""
    @sprites["msgwindow"].visible  = true
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end



class RelicStoneScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(x)
    @scene.pbDisplay(x)
  end

  def pbConfirm(x)
    @scene.pbConfirm(x)
  end

  def pbUpdate; end

  def pbRefresh; end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbPurify
    pbPurify(pokemon,self)
    @scene.pbEndScene
  end
end



def pbRelicStoneScreen(pkmn)
  retval = true
  pbFadeOutIn {
    scene = RelicStoneScene.new
    screen = RelicStoneScreen.new(scene)
    retval = screen.pbStartScreen(pkmn)
  }
  return retval
end



#===============================================================================
#
#===============================================================================
def pbRelicStone
  if !$player.party.any? { |pkmn| pkmn.purifiable? }
    pbMessage(_INTL("You have no Pokémon that can be purified."))
    return
  end
  pbMessage(_INTL("There's a Pokémon that may open the door to its heart!"))
  # Choose a purifiable Pokemon
  pbChoosePokemon(1, 2,proc { |pkmn|
    pkmn.able? && pkmn.shadowPokemon? && pkmn.heart_gauge == 0
  })
  if $game_variables[1] >= 0
    pbRelicStoneScreen($player.party[$game_variables[1]])
  end
end



#===============================================================================
# Shadow Pokémon in battle.
#===============================================================================
class Battle
  alias __shadow__pbCanUseItemOnPokemon? pbCanUseItemOnPokemon?

  def pbCanUseItemOnPokemon?(item,pkmn,battler,scene,showMessages = true)
    ret = __shadow__pbCanUseItemOnPokemon?(item,pkmn,battler,scene,showMessages)
    if ret && pkmn.hyper_mode && ![:JOYSCENT, :EXCITESCENT, :VIVIDSCENT].include?(item)
      scene.pbDisplay(_INTL("This item can't be used on that Pokémon."))
      return false
    end
    return ret
  end
end



class Battle::Battler
  alias __shadow__pbInitPokemon pbInitPokemon

  def pbInitPokemon(*arg)
    if self.pokemonIndex>0 && inHyperMode?
      self.pokemon.hyper_mode = false
    end
    __shadow__pbInitPokemon(*arg)
    # Called into battle
    if shadowPokemon?
      self.types = [:SHADOW] if GameData::Type.exists?(:SHADOW)
      self.pokemon.change_heart_gauge("battle") if pbOwnedByPlayer?
    end
  end

  def shadowPokemon?
    p = self.pokemon
    return p && p.shadowPokemon?
  end

  def inHyperMode?
    return false if fainted?
    p = self.pokemon
    return p && p.hyper_mode
  end

  def pbHyperMode
    return if fainted? || !shadowPokemon? || inHyperMode? || !pbOwnedByPlayer?
    p = self.pokemon
    if @battle.pbRandom(p.heart_gauge) <= p.max_gauge_size / 4
      p.hyper_mode = true
      @battle.pbDisplay(_INTL("{1}'s emotions rose to a fever pitch!\nIt entered Hyper Mode!",self.pbThis))
    end
  end

  def pbHyperModeObedience(move)
    return true if !inHyperMode?
    return true if !move || move.type == :SHADOW
    return rand(100)<20
  end
end



#===============================================================================
# Shadow item effects.
#===============================================================================
def pbRaiseHappinessAndReduceHeart(pkmn, scene, multiplier)
  if !pkmn.shadowPokemon? || (pkmn.happiness == 255 && pkmn.heart_gauge == 0)
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  old_gauge = pkmn.heart_gauge
  old_happiness = pkmn.happiness
  pkmn.changeHappiness("vitamin")
  pkmn.change_heart_gauge("scent", multiplier)
  if pkmn.heart_gauge == old_gauge
    scene.pbDisplay(_INTL("{1} turned friendly.", pkmn.name))
  elsif pkmn.happiness == old_happiness
    scene.pbDisplay(_INTL("{1} adores you!\nThe door to its heart opened a little.", pkmn.name))
    pkmn.check_ready_to_purify
  else
    scene.pbDisplay(_INTL("{1} turned friendly.\nThe door to its heart opened a little.", pkmn.name))
    pkmn.check_ready_to_purify
  end
  return true
end

ItemHandlers::UseOnPokemon.add(:JOYSCENT,proc { |item,pokemon,scene|
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 1)
})

ItemHandlers::UseOnPokemon.add(:EXCITESCENT,proc { |item,pokemon,scene|
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 2)
})

ItemHandlers::UseOnPokemon.add(:VIVIDSCENT,proc { |item,pokemon,scene|
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 3)
})

ItemHandlers::UseOnPokemon.add(:TIMEFLUTE,proc { |item,pokemon,scene|
  if !pokemon.shadowPokemon? || pokemon.heart_gauge == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pokemon.heart_gauge = 0
  pokemon.check_ready_to_purify
  next true
})

ItemHandlers::CanUseInBattle.add(:JOYSCENT,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || !battler.shadowPokemon? || !battler.inHyperMode?
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:JOYSCENT,:EXCITESCENT,:VIVIDSCENT)

ItemHandlers::BattleUseOnBattler.add(:JOYSCENT,proc { |item,battler,scene|
  battler.pokemon.hyper_mode = false
  battler.pokemon.change_heart_gauge("scent", 1)
  scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,GameData::Item.get(item).name))
  next true
})

ItemHandlers::BattleUseOnBattler.add(:EXCITESCENT,proc { |item,battler,scene|
  battler.pokemon.hyper_mode = false
  battler.pokemon.change_heart_gauge("scent", 2)
  scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,GameData::Item.get(item).name))
  next true
})

ItemHandlers::BattleUseOnBattler.add(:VIVIDSCENT,proc { |item,battler,scene|
  battler.pokemon.hyper_mode = false
  battler.pokemon.change_heart_gauge("scent", 3)
  scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",battler.pbThis,GameData::Item.get(item).name))
  next true
})



#===============================================================================
# Two turn attack. On first turn, halves the HP of all active Pokémon.
# Skips second turn (if successful). (Shadow Half)
#===============================================================================
class Battle::Move::AllBattlersLoseHalfHPUserSkipsNextTurn < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.allBattlers.none? { |b| b.hp > 1 }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.allBattlers.each do |b|
      b.pbReduceHP(b.hp / 2, false) if b.hp > 1
    end
    @battle.pbDisplay(_INTL("Each Pokémon's HP was halved!"))
    @battle.allBattlers.each { |b| b.pbItemHPHealCheck }
    user.effects[PBEffects::HyperBeam] = 2
    user.currentMove = @id
  end
end



#===============================================================================
# User takes recoil damage equal to 1/2 of its current HP. (Shadow End)
#===============================================================================
class Battle::Move::UserLosesHalfHP < Battle::Move::RecoilMove
  def pbRecoilDamage(user,target)
    return (target.damageState.totalHPLost/2.0).round
  end

  def pbEffectAfterAllHits(user,target)
    return if user.fainted? || target.damageState.unaffected
    # NOTE: This move's recoil is not prevented by Rock Head/Magic Guard.
    amt = pbRecoilDamage(user,target)
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
end



#===============================================================================
# Starts shadow weather. (Shadow Sky)
#===============================================================================
class Battle::Move::StartShadowSkyWeather < Battle::Move::WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :ShadowSky
  end
end



#===============================================================================
# Ends the effects of Light Screen, Reflect and Safeguard on both sides.
# (Shadow Shed)
#===============================================================================
class Battle::Move::RemoveAllScreens < Battle::Move
  def pbEffectGeneral(user)
    for i in @battle.sides
      i.effects[PBEffects::AuroraVeil]  = 0
      i.effects[PBEffects::Reflect]     = 0
      i.effects[PBEffects::LightScreen] = 0
      i.effects[PBEffects::Safeguard]   = 0
    end
    @battle.pbDisplay(_INTL("It broke all barriers!"))
  end
end



#===============================================================================
#
#===============================================================================
class Game_Temp
  attr_accessor :party_heart_gauges_before_battle
end



# Record current heart gauges of Pokémon in party, to see if they drop to zero
# during battle and need to say they're ready to be purified afterwards
Events.onStartBattle += proc { |_sender|
  $game_temp.party_heart_gauges_before_battle = []
  $player.party.each_with_index do |pkmn, i|
    $game_temp.party_heart_gauges_before_battle[i] = pkmn.heart_gauge
  end
}

Events.onEndBattle += proc { |_sender,_e|
  $game_temp.party_heart_gauges_before_battle.each_with_index do |value, i|
    pkmn = $player.party[i]
    next if !pkmn || !value || value == 0
    pkmn.check_ready_to_purify if pkmn.heart_gauge == 0
  end
}

Events.onStepTaken += proc {
  $player.able_party.each do |pkmn|
    next if pkmn.heart_gauge == 0
    pkmn.heart_gauge_step_counter = 0 if !pkmn.heart_gauge_step_counter
    pkmn.heart_gauge_step_counter += 1
    if pkmn.heart_gauge_step_counter >= 256
      old_stage = pkmn.heartStage
      pkmn.change_heart_gauge("walking")
      new_stage = pkmn.heartStage
      if new_stage == 0
        pkmn.check_ready_to_purify
      elsif new_stage != old_stage
        pkmn.update_shadow_moves
      end
      pkmn.heart_gauge_step_counter = 0
    end
  end
  if ($PokemonGlobal.purifyChamber rescue nil)
    $PokemonGlobal.purifyChamber.update
  end
}
