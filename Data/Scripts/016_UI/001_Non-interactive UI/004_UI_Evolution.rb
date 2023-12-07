#===============================================================================
# Evolution screen
#===============================================================================
class PokemonEvolutionScene
  def self.pbDuplicatePokemon(pkmn, new_species)
    new_pkmn = pkmn.clone
    new_pkmn.species   = new_species
    new_pkmn.name      = nil
    new_pkmn.markings  = []
    new_pkmn.poke_ball = :POKEBALL
    new_pkmn.item      = nil
    new_pkmn.clearAllRibbons
    new_pkmn.calc_stats
    new_pkmn.heal
    # Add duplicate Pokémon to party
    $player.party.push(new_pkmn)
    # See and own duplicate Pokémon
    $player.pokedex.register(new_pkmn)
    $player.pokedex.set_owned(new_species)
  end

  def pbStartScreen(pokemon, newspecies)
    @pokemon = pokemon
    @newspecies = newspecies
    @sprites = {}
    @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @bgviewport.z = 99999
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @msgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @msgviewport.z = 99999
    addBackgroundOrColoredPlane(@sprites, "background", "evolution_bg",
                                Color.new(248, 248, 248), @bgviewport)
    rsprite1 = PokemonSprite.new(@viewport)
    rsprite1.setOffset(PictureOrigin::CENTER)
    rsprite1.setPokemonBitmap(@pokemon, false)
    rsprite1.x = Graphics.width / 2
    rsprite1.y = (Graphics.height - 64) / 2
    rsprite2 = PokemonSprite.new(@viewport)
    rsprite2.setOffset(PictureOrigin::CENTER)
    rsprite2.setPokemonBitmapSpecies(@pokemon, @newspecies, false)
    rsprite2.x       = rsprite1.x
    rsprite2.y       = rsprite1.y
    rsprite2.visible = false
    @sprites["rsprite1"] = rsprite1
    @sprites["rsprite2"] = rsprite2
    @sprites["msgwindow"] = pbCreateMessageWindow(@msgviewport)
    set_up_animation
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def set_up_animation
    sprite = PictureEx.new(0)
    sprite.setVisible(0, true)
    sprite.setColor(0, Color.new(255, 255, 255, 0))
    sprite2 = PictureEx.new(0)
    sprite2.setVisible(0, true)
    sprite2.setZoom(0, 0.0)
    sprite2.setColor(0, Color.new(255, 255, 255, 255))
    # Make sprite turn white
    sprite.moveColor(0, 25, Color.new(255, 255, 255, 255))
    total_duration = 9 * 20   # 9 seconds
    duration = 25 + 15
    zoom_duration = 12
    loop do
      # Shrink prevo sprite, enlarge evo sprite
      sprite.moveZoom(duration, zoom_duration, 0)
      sprite2.moveZoom(duration, zoom_duration, 110)
      duration += zoom_duration
      # If animation has played for long enough, end it now while the evo sprite is large
      break if duration >= total_duration
      # Enlarge prevo sprite, shrink evo sprite
      sprite.moveZoom(duration, zoom_duration, 110)
      sprite2.moveZoom(duration, zoom_duration, 0)
      duration += zoom_duration
      # Shorten the duration of zoom changes for the next cycle
      zoom_duration = [(zoom_duration / 1.2).round, 2].max
    end
    @picture1 = sprite
    @picture2 = sprite2
  end

  # Opens the evolution screen
  def pbEvolution(cancancel = true)
    pbBGMStop
    pbMessageDisplay(@sprites["msgwindow"], "\\se[]" + _INTL("What?") + "\1") { pbUpdate }
    pbPlayDecisionSE
    @pokemon.play_cry
    @sprites["msgwindow"].text = _INTL("{1} is evolving!", @pokemon.name)
    timer_start = System.uptime
    loop do
      Graphics.update
      Input.update
      pbUpdate
      break if System.uptime - timer_start >= 1
    end
    pbMEPlay("Evolution start")
    pbBGMPlay("Evolution")
    canceled = false
    timer_start = System.uptime
    loop do
      pbUpdateNarrowScreen(timer_start)
      @picture1.update
      setPictureSprite(@sprites["rsprite1"], @picture1)
      if @sprites["rsprite1"].zoom_x > 1.0
        @sprites["rsprite1"].zoom_x = 1.0
        @sprites["rsprite1"].zoom_y = 1.0
      end
      @picture2.update
      setPictureSprite(@sprites["rsprite2"], @picture2)
      if @sprites["rsprite2"].zoom_x > 1.0
        @sprites["rsprite2"].zoom_x = 1.0
        @sprites["rsprite2"].zoom_y = 1.0
      end
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::BACK) && cancancel
        pbBGMStop
        pbPlayCancelSE
        canceled = true
        break
      end
      break if !@picture1.running? && !@picture2.running?
    end
    pbFlashInOut(canceled)
    if canceled
      $stats.evolutions_cancelled += 1
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
    else
      pbEvolutionSuccess
    end
  end

  def pbUpdateNarrowScreen(timer_start)
    return if @bgviewport.rect.y >= 80
    buffer = 80
    @bgviewport.rect.height = Graphics.height - lerp(0, 64 + (buffer * 2), 0.7, timer_start, System.uptime).to_i
    @bgviewport.rect.y = lerp(0, buffer, 0.5, timer_start + 0.2, System.uptime).to_i
    @sprites["background"].oy = @bgviewport.rect.y
  end

  def pbUpdateExpandScreen(timer_start)
    return if @bgviewport.rect.height >= Graphics.height
    buffer = 80
    @bgviewport.rect.height = Graphics.height - lerp(64 + (buffer * 2), 0, 0.7, timer_start, System.uptime).to_i
    @bgviewport.rect.y = lerp(buffer, 0, 0.5, timer_start, System.uptime).to_i
    @sprites["background"].oy = @bgviewport.rect.y
  end

  def pbFlashInOut(canceled)
    timer_start = System.uptime
    loop do
      Graphics.update
      pbUpdate(true)
      pbUpdateExpandScreen(timer_start)
      tone = lerp(0, 255, 0.7, timer_start, System.uptime)
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone >= 255
    end
    @bgviewport.rect.y      = 0
    @bgviewport.rect.height = Graphics.height
    @sprites["background"].oy = 0
    if canceled
      @sprites["rsprite1"].visible     = true
      @sprites["rsprite1"].zoom_x      = 1.0
      @sprites["rsprite1"].zoom_y      = 1.0
      @sprites["rsprite1"].color.alpha = 0
      @sprites["rsprite2"].visible     = false
    else
      @sprites["rsprite1"].visible     = false
      @sprites["rsprite2"].visible     = true
      @sprites["rsprite2"].zoom_x      = 1.0
      @sprites["rsprite2"].zoom_y      = 1.0
      @sprites["rsprite2"].color.alpha = 0
    end
    timer_start = System.uptime
    loop do
      Graphics.update
      pbUpdate(true)
      break if System.uptime - timer_start >= 0.25
    end
    timer_start = System.uptime
    loop do
      Graphics.update
      pbUpdate
      pbUpdateExpandScreen(timer_start)
      tone = lerp(255, 0, 0.4, timer_start, System.uptime)
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone <= 0
    end
  end

  def pbEvolutionSuccess
    $stats.evolution_count += 1
    # Play cry of evolved species
    cry_time = GameData::Species.cry_length(@newspecies, @pokemon.form)
    Pokemon.play_cry(@newspecies, @pokemon.form)
    timer_start = System.uptime
    loop do
      Graphics.update
      pbUpdate
      break if System.uptime - timer_start >= cry_time
    end
    pbBGMStop
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = GameData::Species.get(@newspecies).name
    pbMessageDisplay(@sprites["msgwindow"],
                     "\\se[]" + _INTL("Congratulations! Your {1} evolved into {2}!",
                                      @pokemon.name, newspeciesname) + "\\wt[80]") { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    was_fainted = @pokemon.fainted?
    @pokemon.species = @newspecies
    @pokemon.hp = 0 if was_fainted
    @pokemon.calc_stats
    @pokemon.ready_to_evolve = false
    # See and own evolved species
    was_owned = $player.owned?(@newspecies)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@newspecies)
    moves_to_learn = []
    movelist = @pokemon.getMoveList
    movelist.each do |i|
      next if i[0] != 0 && i[0] != @pokemon.level   # 0 is "learn upon evolution"
      moves_to_learn.push(i[1])
    end
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(@pokemon.species)
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", newspeciesname)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
        @sprites["msgwindow"].text = "" if moves_to_learn.length > 0
        pbEndScreen(false) if moves_to_learn.length == 0
      end
    end
    # Learn moves upon evolution for evolved species
    moves_to_learn.each do |move|
      pbLearnMove(@pokemon, move, true) { pbUpdate }
    end
  end

  def pbEvolutionMethodAfterEvolution
    @pokemon.action_after_evolution(@newspecies)
  end

  def pbUpdate(animating = false)
    if animating      # Pokémon shouldn't animate during the evolution animation
      @sprites["background"].update
      @sprites["msgwindow"].update
    else
      pbUpdateSpriteHash(@sprites)
    end
  end

  # Closes the evolution screen.
  def pbEndScreen(need_fade_out = true)
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    if need_fade_out
      pbFadeOutAndHide(@sprites) { pbUpdate }
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @bgviewport.dispose
    @msgviewport.dispose
  end
end
