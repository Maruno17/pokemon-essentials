#===============================================================================
#
#===============================================================================
class PokemonTrade_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbRunPictures(pictures, sprites)
    loop do
      pictures.each { |pic| pic.update }
      sprites.each_with_index do |sprite, i|
        if sprite.is_a?(IconSprite)
          setPictureIconSprite(sprite, pictures[i])
        else
          setPictureSprite(sprite, pictures[i])
        end
      end
      Graphics.update
      Input.update
      running = false
      pictures.each { |pic| running = true if pic.running? }
      break if !running
    end
  end

  def pbStartScreen(pokemon, pokemon2, trader1, trader2)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon  = pokemon
    @pokemon2 = pokemon2
    @trader1  = trader1
    @trader2  = trader2
    addBackgroundOrColoredPlane(@sprites, "background", "trade_bg",
                                Color.new(248, 248, 248), @viewport)
    @sprites["rsprite1"] = PokemonSprite.new(@viewport)
    @sprites["rsprite1"].setPokemonBitmap(@pokemon, false)
    @sprites["rsprite1"].setOffset(PictureOrigin::BOTTOM)
    @sprites["rsprite1"].x = Graphics.width / 2
    @sprites["rsprite1"].y = 264
    @sprites["rsprite1"].z = 10
    @pokemon.species_data.apply_metrics_to_sprite(@sprites["rsprite1"], 1)
    @sprites["rsprite2"] = PokemonSprite.new(@viewport)
    @sprites["rsprite2"].setPokemonBitmap(@pokemon2, false)
    @sprites["rsprite2"].setOffset(PictureOrigin::BOTTOM)
    @sprites["rsprite2"].x = Graphics.width / 2
    @sprites["rsprite2"].y = 264
    @sprites["rsprite2"].z = 10
    @pokemon2.species_data.apply_metrics_to_sprite(@sprites["rsprite2"], 1)
    @sprites["rsprite2"].visible = false
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  def pbScene1
    spriteBall = IconSprite.new(0, 0, @viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    ballimage = sprintf("Graphics/Battle animations/ball_%s", @pokemon.poke_ball)
    ballopenimage = sprintf("Graphics/Battle animations/ball_%s_open", @pokemon.poke_ball)
    # Starting position of ball
    pictureBall.setXY(0, Graphics.width / 2, 48)
    pictureBall.setName(0, ballimage)
    pictureBall.setSrcSize(0, 32, 64)
    pictureBall.setOrigin(0, PictureOrigin::CENTER)
    pictureBall.setVisible(0, true)
    # Starting position of sprite
    picturePoke.setXY(0, @sprites["rsprite1"].x, @sprites["rsprite1"].y)
    picturePoke.setOrigin(0, PictureOrigin::BOTTOM)
    picturePoke.setVisible(0, true)
    # Change Pokémon color
    picturePoke.moveColor(2, 5, Color.new(248, 176, 140))
    # Recall
    delay = picturePoke.totalDuration
    picturePoke.setSE(delay, "Battle recall")
    pictureBall.setName(delay, ballopenimage)
    pictureBall.setSrcSize(delay, 32, 64)
    # Move sprite to ball
    picturePoke.moveZoom(delay, 8, 0)
    picturePoke.moveXY(delay, 8, Graphics.width / 2, 48)
    picturePoke.setSE(delay + 5, "Battle jump to ball")
    picturePoke.setVisible(delay + 8, false)
    delay = picturePoke.totalDuration + 1
    pictureBall.setName(delay, ballimage)
    pictureBall.setSrcSize(delay, 32, 64)
    # Make Poké Ball go off the top of the screen
    delay = picturePoke.totalDuration + 10
    pictureBall.moveXY(delay, 6, Graphics.width / 2, -32)
    # Play animation
    pbRunPictures(
      [picturePoke, pictureBall],
      [@sprites["rsprite1"], spriteBall]
    )
    spriteBall.dispose
  end

  def pbScene2
    spriteBall = IconSprite.new(0, 0, @viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    ballimage = sprintf("Graphics/Battle animations/ball_%s", @pokemon2.poke_ball)
    ballopenimage = sprintf("Graphics/Battle animations/ball_%s_open", @pokemon2.poke_ball)
    # Starting position of ball
    pictureBall.setXY(0, Graphics.width / 2, -32)
    pictureBall.setName(0, ballimage)
    pictureBall.setSrcSize(0, 32, 64)
    pictureBall.setOrigin(0, PictureOrigin::CENTER)
    pictureBall.setVisible(0, true)
    # Starting position of sprite
    picturePoke.setOrigin(0, PictureOrigin::BOTTOM)
    picturePoke.setZoom(0, 0)
    picturePoke.setColor(0, Color.new(248, 176, 240))
    picturePoke.setVisible(0, false)
    # Dropping ball
    y = Graphics.height - 96 - 16 - 16   # end point of Poké Ball
    delay = picturePoke.totalDuration + 2
    4.times do |i|
      t = [4, 4, 3, 2][i]   # Time taken to rise or fall for each bounce
      d = [1, 2, 4, 8][i]   # Fraction of the starting height each bounce rises to
      delay -= t if i == 0
      if i > 0
        pictureBall.setZoomXY(delay, 100 + (5 * (5 - i)), 100 - (5 * (5 - i)))   # Squish
        pictureBall.moveZoom(delay, 2, 100)                      # Unsquish
        pictureBall.moveXY(delay, t, Graphics.width / 2, y - (100 / d))
      end
      pictureBall.moveXY(delay + t, t, Graphics.width / 2, y)
      pictureBall.setSE(delay + (2 * t), "Battle ball drop")
      delay = pictureBall.totalDuration
    end
    picturePoke.setXY(delay, Graphics.width / 2, y)
    # Open Poké Ball
    delay = pictureBall.totalDuration + 15
    pictureBall.setSE(delay, "Battle recall")
    pictureBall.setName(delay, ballopenimage)
    pictureBall.setSrcSize(delay, 32, 64)
    pictureBall.setVisible(delay + 5, false)
    # Pokémon appears and enlarges
    picturePoke.setVisible(delay, true)
    picturePoke.moveZoom(delay, 8, 100)
    picturePoke.moveXY(delay, 8, Graphics.width / 2, @sprites["rsprite2"].y)
    # Return Pokémon's color to normal and play cry
    delay = picturePoke.totalDuration
    picturePoke.moveColor(delay, 5, Color.new(248, 176, 240, 0))
    cry = GameData::Species.cry_filename_from_pokemon(@pokemon2)
    picturePoke.setSE(delay, cry) if cry
    cry_length = (GameData::Species.cry_length(@pokemon2) * 20).ceil
    picturePoke.setVisible(delay + cry_length + 4, true)   # Time for the cry to play
    # Play animation
    pbRunPictures(
      [picturePoke, pictureBall],
      [@sprites["rsprite2"], spriteBall]
    )
    spriteBall.dispose
  end

  def pbEndScreen(need_fade_out = true)
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    pbFadeOutAndHide(@sprites) if need_fade_out
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    newspecies = @pokemon2.check_evolution_on_trade(@pokemon)
    if newspecies
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(@pokemon2, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
    end
  end

  def pbTrade
    was_owned = $player.owned?(@pokemon2.species)
    $player.pokedex.register(@pokemon2)
    $player.pokedex.set_owned(@pokemon2.species)
    pbBGMStop
    @pokemon.play_cry
    speciesname1 = GameData::Species.get(@pokemon.species).name
    speciesname2 = GameData::Species.get(@pokemon2.species).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}",
                               @pokemon.name, @pokemon.owner.public_id, @pokemon.owner.name) + "\\wtnp[0]") { pbUpdate }
    pbMessageWaitForInput(@sprites["msgwindow"], 50, true) { pbUpdate }
    pbPlayDecisionSE
    pbBGMPlay("Evolution")
    pbScene1
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("For {1}'s {2},\n{3} sends {4}.", @trader1, speciesname1, @trader2, speciesname2) + "\1") { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("{1} bids farewell to {2}.", @trader2, speciesname2)) { pbUpdate }
    pbScene2
    pbBGMStop
    pbMEPlay("Battle capture success")
    pbMessageDisplay(@sprites["msgwindow"],
                     _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}",
                               @pokemon2.name, @pokemon2.owner.public_id, @pokemon2.owner.name) + "\1") { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("Take good care of {1}.", speciesname2)) { pbUpdate }
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(@pokemon2.species)
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", speciesname2)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon2)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon2.species)
        pbEndScreen(false)
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbStartTrade(pokemonIndex, newpoke, nickname, trainerName, trainerGender = 0)
  $stats.trade_count += 1
  myPokemon = $player.party[pokemonIndex]
  yourPokemon = nil
  resetmoves = true
  if newpoke.is_a?(Pokemon)
    newpoke.owner = Pokemon::Owner.new_foreign(trainerName, trainerGender)
    yourPokemon = newpoke
    resetmoves = false
  else
    species_data = GameData::Species.try_get(newpoke)
    raise _INTL("Species {1} does not exist.", newpoke) if !species_data
    yourPokemon = Pokemon.new(species_data.id, myPokemon.level)
    yourPokemon.owner = Pokemon::Owner.new_foreign(trainerName, trainerGender)
  end
  yourPokemon.name          = nickname
  yourPokemon.obtain_method = 2   # traded
  yourPokemon.reset_moves if resetmoves
  yourPokemon.record_first_moves
  pbFadeOutInWithMusic do
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon, yourPokemon, $player.name, trainerName)
    evo.pbTrade
    evo.pbEndScreen
  end
  $player.party[pokemonIndex] = yourPokemon
end
