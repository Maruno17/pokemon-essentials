#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatch_Scene
  def pbStartScene(pokemon)
    @sprites = {}
    @pokemon = pokemon
    @nicknamed = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Create background image
    addBackgroundOrColoredPlane(@sprites, "background", "hatch_bg",
                                Color.new(248, 248, 248), @viewport)
    # Create egg sprite/Pokémon sprite
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::BOTTOM)
    @sprites["pokemon"].x = Graphics.width / 2
    @sprites["pokemon"].y = 264 + 56   # 56 to offset the egg sprite
    @sprites["pokemon"].setSpeciesBitmap(@pokemon.species, @pokemon.gender,
                                         @pokemon.form, @pokemon.shiny?,
                                         false, false, true)   # Egg sprite
    # Load egg cracks bitmap
    crackfilename = GameData::Species.egg_cracks_sprite_filename(@pokemon.species, @pokemon.form)
    @hatchSheet = AnimatedBitmap.new(crackfilename)
    # Create egg cracks sprite
    @sprites["hatch"] = Sprite.new(@viewport)
    @sprites["hatch"].x = @sprites["pokemon"].x
    @sprites["hatch"].y = @sprites["pokemon"].y
    @sprites["hatch"].ox = @sprites["pokemon"].ox
    @sprites["hatch"].oy = @sprites["pokemon"].oy
    @sprites["hatch"].bitmap = @hatchSheet.bitmap
    @sprites["hatch"].src_rect = Rect.new(0, 0, @hatchSheet.width / 5, @hatchSheet.height)
    @sprites["hatch"].visible = false
    # Create flash overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 200
    @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.white)
    @sprites["overlay"].opacity = 0
    # Start up scene
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    pbBGMPlay("Evolution")
    # Egg animation
    updateScene(1.5)
    pbPositionHatchMask(0)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(0.2)
    pbPositionHatchMask(1)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(0.4)
    pbPositionHatchMask(2)
    pbSEPlay("Battle ball shake")
    swingEgg(8, 2)
    updateScene(0.4)
    pbPositionHatchMask(3)
    pbSEPlay("Battle ball shake")
    swingEgg(16, 4)
    updateScene(0.2)
    pbPositionHatchMask(4)
    pbSEPlay("Battle recall")
    # Fade and change the sprite
    timer_start = System.uptime
    loop do
      tone_val = lerp(0, 255, 0.4, timer_start, System.uptime)
      @sprites["pokemon"].tone = Tone.new(tone_val, tone_val, tone_val)
      @sprites["overlay"].opacity = tone_val
      updateScene
      break if tone_val >= 255
    end
    updateScene(0.75)
    @sprites["pokemon"].setPokemonBitmap(@pokemon) # Pokémon sprite
    @sprites["pokemon"].x = Graphics.width / 2
    @sprites["pokemon"].y = 264
    @pokemon.species_data.apply_metrics_to_sprite(@sprites["pokemon"], 1)
    @sprites["hatch"].visible = false
    timer_start = System.uptime
    loop do
      tone_val = lerp(255, 0, 0.4, timer_start, System.uptime)
      @sprites["pokemon"].tone = Tone.new(tone_val, tone_val, tone_val)
      @sprites["overlay"].opacity = tone_val
      updateScene
      break if tone_val <= 0
    end
    # Finish scene
    cry_duration = GameData::Species.cry_length(@pokemon)
    @pokemon.play_cry
    updateScene(cry_duration + 0.1)
    pbBGMStop
    pbMEPlay("Evolution success")
    @pokemon.name = nil
    pbMessage("\\se[]" + _INTL("{1} hatched from the Egg!", @pokemon.name) + "\\wt[80]") { update }
    # Record the Pokémon's species as owned in the Pokédex
    was_owned = $player.owned?(@pokemon.species)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@pokemon.species)
    $player.pokedex.set_seen_egg(@pokemon.species)
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(@pokemon.species)
      pbMessage(_INTL("{1}'s data was added to the Pokédex.", @pokemon.name)) { update }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
      end
    end
    # Nickname the Pokémon
    if $PokemonSystem.givenicknames == 0 &&
       pbConfirmMessage(
         _INTL("Would you like to nickname the newly hatched {1}?", @pokemon.name)
       ) { update }
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", @pokemon.name),
                                    0, Pokemon::MAX_NAME_SIZE, "", @pokemon, true)
      @pokemon.name = nickname
      @nicknamed = true
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update } if !@nicknamed
    pbDisposeSpriteHash(@sprites)
    @hatchSheet.dispose
    @viewport.dispose
  end

  def pbPositionHatchMask(index)
    @sprites["hatch"].src_rect.x = index * @sprites["hatch"].src_rect.width
  end

  def swingEgg(speed, swingTimes = 1)
    @sprites["hatch"].visible = true
    amplitude = 8
    duration = 0.05 * amplitude / speed
    targets = []
    swingTimes.times do
      targets.push(@sprites["pokemon"].x + amplitude)
      targets.push(@sprites["pokemon"].x - amplitude)
    end
    targets.push(@sprites["pokemon"].x)
    targets.each_with_index do |target, i|
      timer_start = System.uptime
      start_x = @sprites["pokemon"].x
      loop do
        break if i.even? && @sprites["pokemon"].x >= target
        break if i.odd? && @sprites["pokemon"].x <= target
        @sprites["pokemon"].x = lerp(start_x, target, duration, timer_start, System.uptime)
        @sprites["hatch"].x = @sprites["pokemon"].x
        updateScene
      end
    end
    @sprites["pokemon"].x = targets[targets.length - 1]
    @sprites["hatch"].x   = @sprites["pokemon"].x
  end

  # Can be used for "wait" effect.
  def updateScene(duration = 0.01)
    timer_start = System.uptime
    while System.uptime - timer_start < duration
      Graphics.update
      Input.update
      self.update
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonEggHatchScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbMain
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
def pbHatchAnimation(pokemon)
  pbMessage(_INTL("Huh?") + "\1")
  pbFadeOutInWithMusic do
    scene = PokemonEggHatch_Scene.new
    screen = PokemonEggHatchScreen.new(scene)
    screen.pbStartScreen(pokemon)
  end
  return true
end

def pbHatch(pokemon)
  $stats.eggs_hatched += 1
  speciesname = pokemon.speciesName
  pokemon.name           = nil
  pokemon.owner          = Pokemon::Owner.new_from_trainer($player)
  pokemon.happiness      = 120
  pokemon.timeEggHatched = Time.now.to_i
  pokemon.obtain_method  = 1   # hatched from egg
  pokemon.hatched_map    = $game_map.map_id
  pokemon.record_first_moves
  if !pbHatchAnimation(pokemon)
    pbMessage(_INTL("Huh?") + "\1")
    pbMessage(_INTL("...") + "\1")
    pbMessage(_INTL("... .... .....") + "\1")
    pbMessage(_INTL("{1} hatched from the Egg!", speciesname))
    was_owned = $player.owned?(pokemon.species)
    $player.pokedex.register(pokemon)
    $player.pokedex.set_owned(pokemon.species)
    $player.pokedex.set_seen_egg(pokemon.species)
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(pokemon.species)
      pbMessage(_INTL("{1}'s data was added to the Pokédex.", speciesname))
      $player.pokedex.register_last_seen(pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(pokemon.species)
      end
    end
    # Nickname the Pokémon
    if $PokemonSystem.givenicknames == 0 &&
       pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?", speciesname))
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname),
                                    0, Pokemon::MAX_NAME_SIZE, "", pokemon)
      pokemon.name = nickname
    end
  end
end

EventHandlers.add(:on_player_step_taken, :hatch_eggs,
  proc {
    $player.party.each do |egg|
      next if egg.steps_to_hatch <= 0
      egg.steps_to_hatch -= 1
      $player.pokemon_party.each do |pkmn|
        next if !pkmn.ability&.has_flag?("FasterEggHatching")
        egg.steps_to_hatch -= 1
        break
      end
      if egg.steps_to_hatch <= 0
        egg.steps_to_hatch = 0
        pbHatch(egg)
      end
    end
  }
)
