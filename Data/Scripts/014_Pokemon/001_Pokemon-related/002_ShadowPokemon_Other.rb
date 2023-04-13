# All types except Shadow have Shadow as a weakness.
# Shadow has Shadow as a resistance.
# On a side note, the Shadow moves in Colosseum will not be affected by
# Weaknesses or Resistances, while in XD the Shadow-type is Super-Effective
# against all other types.
# 2/5 - display nature
#
# XD - Shadow Rush -- 55, 100 - Deals damage.
# Colosseum - Shadow Rush -- 90, 100
# If this attack is successful, user loses half of HP lost by opponent due to
# this attack (recoil). If user is in Hyper Mode, this attack has a good chance
# for a critical hit.

#===============================================================================
# Purify a Shadow Pokémon.
#===============================================================================
def pbPurify(pkmn, scene)
  return if !pkmn.shadowPokemon? || pkmn.heart_gauge != 0
  $stats.shadow_pokemon_purified += 1
  pkmn.shadow = false
  pkmn.hyper_mode = false
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
    newexp = pkmn.growth_rate.add_exp(pkmn.exp, (pkmn.saved_exp * 4 / 5) || 0)
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
  if $PokemonSystem.givenicknames == 0 &&
     scene.pbConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.speciesName))
    newname = pbEnterPokemonName(_INTL("{1}'s nickname?", pkmn.speciesName),
                                 0, Pokemon::MAX_NAME_SIZE, "", pkmn)
    pkmn.name = newname
  end
end

#===============================================================================
# Relic Stone scene.
#===============================================================================
class RelicStoneScene
  def pbPurify; end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbStartScene(pokemon)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon = pokemon
    addBackgroundPlane(@sprites, "bg", "relicstonebg", @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].viewport = @viewport
    @sprites["msgwindow"].x        = 0
    @sprites["msgwindow"].y        = Graphics.height - 96
    @sprites["msgwindow"].width    = Graphics.width
    @sprites["msgwindow"].height   = 96
    @sprites["msgwindow"].text     = ""
    @sprites["msgwindow"].visible  = true
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

#===============================================================================
#
#===============================================================================
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
    pbPurify(pokemon, self)
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
def pbRelicStoneScreen(pkmn)
  retval = true
  pbFadeOutIn do
    scene = RelicStoneScene.new
    screen = RelicStoneScreen.new(scene)
    retval = screen.pbStartScreen(pkmn)
  end
  return retval
end

#===============================================================================
#
#===============================================================================
def pbRelicStone
  if $player.party.none? { |pkmn| pkmn.purifiable? }
    pbMessage(_INTL("You have no Pokémon that can be purified."))
    return
  end
  pbMessage(_INTL("There's a Pokémon that may open the door to its heart!"))
  # Choose a purifiable Pokemon
  pbChoosePokemon(1, 2, proc { |pkmn|
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
  unless method_defined?(:__shadow__pbCanUseItemOnPokemon?)
    alias __shadow__pbCanUseItemOnPokemon? pbCanUseItemOnPokemon?
  end

  def pbCanUseItemOnPokemon?(item, pkmn, battler, scene, showMessages = true)
    ret = __shadow__pbCanUseItemOnPokemon?(item, pkmn, battler, scene, showMessages)
    if ret && pkmn.hyper_mode && ![:JOYSCENT, :EXCITESCENT, :VIVIDSCENT].include?(item)
      scene.pbDisplay(_INTL("This item can't be used on that Pokémon."))
      return false
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class Battle::Battler
  alias __shadow__pbInitPokemon pbInitPokemon unless method_defined?(:__shadow__pbInitPokemon)

  def pbInitPokemon(*arg)
    self.pokemon.hyper_mode = false if self.pokemonIndex > 0 && inHyperMode?
    __shadow__pbInitPokemon(*arg)
    # Called into battle
    if shadowPokemon?
      self.types = [:SHADOW] if GameData::Type.exists?(:SHADOW)
      self.pokemon.change_heart_gauge("battle") if pbOwnedByPlayer?
    end
  end

  def shadowPokemon?
    p = self.pokemon
    return p&.shadowPokemon?
  end

  def inHyperMode?
    return false if fainted?
    p = self.pokemon
    return p&.hyper_mode
  end

  def pbHyperMode
    return if fainted? || !shadowPokemon? || inHyperMode? || !pbOwnedByPlayer?
    p = self.pokemon
    if @battle.pbRandom(p.heart_gauge) <= p.max_gauge_size / 4
      p.hyper_mode = true
      @battle.pbDisplay(_INTL("{1}'s emotions rose to a fever pitch!\nIt entered Hyper Mode!", self.pbThis))
    end
  end

  def pbHyperModeObedience(move)
    return true if !inHyperMode?
    return true if !move || move.type == :SHADOW
    return rand(100) < 20
  end
end

#===============================================================================
# Shadow item effects.
#===============================================================================
def pbRaiseHappinessAndReduceHeart(pkmn, scene, multiplier, show_fail_message = true)
  if !pkmn.shadowPokemon? || (pkmn.happiness == 255 && pkmn.heart_gauge == 0)
    scene.pbDisplay(_INTL("It won't have any effect.")) if show_fail_message
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

ItemHandlers::UseOnPokemon.add(:JOYSCENT, proc { |item, qty, pkmn, scene|
  ret = false
  if pkmn.hyper_mode
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}.", pkmn.name, GameData::Item.get(item).name))
    pkmn.hyper_mode = false
    ret = true
  end
  next pbRaiseHappinessAndReduceHeart(pkmn, scene, 1, !ret) || ret
})

ItemHandlers::UseOnPokemon.add(:EXCITESCENT, proc { |item, qty, pkmn, scene|
  ret = false
  if pkmn.hyper_mode
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}.", pkmn.name, GameData::Item.get(item).name))
    pkmn.hyper_mode = false
    ret = true
  end
  next pbRaiseHappinessAndReduceHeart(pkmn, scene, 2, !ret) || ret
})

ItemHandlers::UseOnPokemon.add(:VIVIDSCENT, proc { |item, qty, pkmn, scene|
  ret = false
  if pkmn.hyper_mode
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}.", pkmn.name, GameData::Item.get(item).name))
    pkmn.hyper_mode = false
    ret = true
  end
  next pbRaiseHappinessAndReduceHeart(pkmn, scene, 3, !ret) || ret
})

ItemHandlers::UseOnPokemon.add(:TIMEFLUTE, proc { |item, qty, pkmn, scene|
  if !pkmn.shadowPokemon? || pkmn.heart_gauge == 0 || pkmn.isSpecies?(:LUGIA)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pbPurify(pkmn, scene)
  next true
})

ItemHandlers::CanUseInBattle.add(:JOYSCENT, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.shadowPokemon? || (pokemon.happiness == 255 && pokemon.heart_gauge == 0)
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:JOYSCENT, :EXCITESCENT, :VIVIDSCENT)

ItemHandlers::BattleUseOnPokemon.add(:JOYSCENT, proc { |item, pokemon, battler, choices, scene|
  if pokemon.hyper_mode
    pokemon.hyper_mode = false
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",
                          battler&.pbThis || pokemon.name, GameData::Item.get(item).name))
  end
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 1, false)
  next true
})

ItemHandlers::BattleUseOnPokemon.add(:EXCITESCENT, proc { |item, pokemon, battler, choices, scene|
  if pokemon.hyper_mode
    pokemon.hyper_mode = false
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",
                          battler&.pbThis || pokemon.name, GameData::Item.get(item).name))
  end
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 2, false)
  next true
})

ItemHandlers::BattleUseOnPokemon.add(:VIVIDSCENT, proc { |item, pokemon, battler, choices, scene|
  if pokemon.hyper_mode
    pokemon.hyper_mode = false
    scene.pbDisplay(_INTL("{1} came to its senses from the {2}!",
                          battler&.pbThis || pokemon.name, GameData::Item.get(item).name))
  end
  pbRaiseHappinessAndReduceHeart(pokemon, scene, 3, false)
  next true
})

#===============================================================================
# Two turn attack. On first turn, halves the HP of all active Pokémon.
# Skips second turn (if successful). (Shadow Half)
#===============================================================================
class Battle::Move::AllBattlersLoseHalfHPUserSkipsNextTurn < Battle::Move
  def pbMoveFailed?(user, targets)
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
  def pbRecoilDamage(user, target)
    return (user.hp / 2.0).round
  end

  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    # NOTE: This move's recoil is not prevented by Rock Head/Magic Guard.
    amt = pbRecoilDamage(user, target)
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Starts shadow weather. (Shadow Sky)
#===============================================================================
class Battle::Move::StartShadowSkyWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :ShadowSky
  end
end

#===============================================================================
# Ends the effects of Light Screen, Reflect and Safeguard on both sides.
# (Shadow Shed)
#===============================================================================
class Battle::Move::RemoveAllScreensAndSafeguard < Battle::Move
  def pbMoveFailed?(user, targets)
    will_fail = true
    @battle.sides.each do |side|
      will_fail = false if side.effects[PBEffects::AuroraVeil] > 0 ||
                           side.effects[PBEffects::LightScreen] > 0 ||
                           side.effects[PBEffects::Reflect] > 0 ||
                           side.effects[PBEffects::Safeguard] > 0
    end
    if will_fail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.sides.each do |i|
      i.effects[PBEffects::AuroraVeil]  = 0
      i.effects[PBEffects::LightScreen] = 0
      i.effects[PBEffects::Reflect]     = 0
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

#===============================================================================
#
#===============================================================================
# Record current heart gauges of Pokémon in party, to see if they drop to zero
# during battle and need to say they're ready to be purified afterwards
EventHandlers.add(:on_start_battle, :record_party_heart_gauges,
  proc {
    $game_temp.party_heart_gauges_before_battle = []
    $player.party.each_with_index do |pkmn, i|
      $game_temp.party_heart_gauges_before_battle[i] = pkmn.heart_gauge
    end
  }
)

EventHandlers.add(:on_end_battle, :check_ready_to_purify,
  proc { |_decision, _canLose|
    $game_temp.party_heart_gauges_before_battle.each_with_index do |value, i|
      pkmn = $player.party[i]
      next if !pkmn || !value || value == 0
      pkmn.check_ready_to_purify if pkmn.heart_gauge == 0
    end
  }
)

EventHandlers.add(:on_player_step_taken, :lower_heart_gauges,
  proc {
    $player.able_party.each do |pkmn|
      next if pkmn.heart_gauge == 0
      pkmn.heart_gauge_step_counter = 0 if !pkmn.heart_gauge_step_counter
      pkmn.heart_gauge_step_counter += 1
      next if pkmn.heart_gauge_step_counter < 256
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
    $PokemonGlobal.purifyChamber&.update
  }
)
