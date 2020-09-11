class PokemonTrade_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbRunPictures(pictures,sprites)
    loop do
      for i in 0...pictures.length
        pictures[i].update
      end
      for i in 0...sprites.length
        if sprites[i].is_a?(IconSprite)
          setPictureIconSprite(sprites[i],pictures[i])
        else
          setPictureSprite(sprites[i],pictures[i])
        end
      end
      Graphics.update
      Input.update
      running = false
      for i in 0...pictures.length
        running = true if pictures[i].running?
      end
      break if !running
    end
  end

  def pbStartScreen(pokemon,pokemon2,trader1,trader2)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @pokemon  = pokemon
    @pokemon2 = pokemon2
    @trader1  = trader1
    @trader2  = trader2
    addBackgroundOrColoredPlane(@sprites,"background","tradebg",
       Color.new(248,248,248),@viewport)
    @sprites["rsprite1"] = PokemonSprite.new(@viewport)
    @sprites["rsprite1"].setPokemonBitmap(@pokemon,false)
    @sprites["rsprite1"].setOffset(PictureOrigin::Bottom)
    @sprites["rsprite1"].x = Graphics.width/2
    @sprites["rsprite1"].y = 264
    @sprites["rsprite1"].z = 10
    pbApplyBattlerMetricsToSprite(@sprites["rsprite1"],1,@pokemon.fSpecies)
    @sprites["rsprite2"] = PokemonSprite.new(@viewport)
    @sprites["rsprite2"].setPokemonBitmap(@pokemon2,false)
    @sprites["rsprite2"].setOffset(PictureOrigin::Bottom)
    @sprites["rsprite2"].x = Graphics.width/2
    @sprites["rsprite2"].y = 264
    @sprites["rsprite2"].z = 10
    pbApplyBattlerMetricsToSprite(@sprites["rsprite2"],1,@pokemon2.fSpecies)
    @sprites["rsprite2"].visible = false
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)
  end

  def pbScene1
    spriteBall = IconSprite.new(0,0,@viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    # Starting position of ball
    pictureBall.setXY(0,Graphics.width/2,48)
    pictureBall.setName(0,sprintf("Graphics/Battle animations/ball_%02d",@pokemon.ballused))
    pictureBall.setSrcSize(0,32,64)
    pictureBall.setOrigin(0,PictureOrigin::Center)
    pictureBall.setVisible(0,true)
    # Starting position of sprite
    picturePoke.setXY(0,@sprites["rsprite1"].x,@sprites["rsprite1"].y)
    picturePoke.setOrigin(0,PictureOrigin::Bottom)
    picturePoke.setVisible(0,true)
    # Change Pokémon color
    picturePoke.moveColor(2,5,Color.new(31*8,22*8,30*8,255))
    # Recall
    delay = picturePoke.totalDuration
    picturePoke.setSE(delay,"Battle recall")
    pictureBall.setName(delay,sprintf("Graphics/Battle animations/ball_%02d_open",@pokemon.ballused))
    pictureBall.setSrcSize(delay,32,64)
    # Move sprite to ball
    picturePoke.moveZoom(delay,8,0)
    picturePoke.moveXY(delay,8,Graphics.width/2,48)
    picturePoke.setSE(delay+5,"Battle jump to ball")
    picturePoke.setVisible(delay+8,false)
    delay = picturePoke.totalDuration+1
    pictureBall.setName(delay,sprintf("Graphics/Battle animations/ball_%02d",@pokemon.ballused))
    pictureBall.setSrcSize(delay,32,64)
    # Make Poké Ball go off the top of the screen
    delay = picturePoke.totalDuration+10
    pictureBall.moveXY(delay,6,Graphics.width/2,-32)
    # Play animation
    pbRunPictures(
       [picturePoke,pictureBall],
       [@sprites["rsprite1"],spriteBall]
    )
    spriteBall.dispose
  end

  def pbScene2
    spriteBall = IconSprite.new(0,0,@viewport)
    pictureBall = PictureEx.new(0)
    picturePoke = PictureEx.new(0)
    # Starting position of ball
    pictureBall.setXY(0,Graphics.width/2,-32)
    pictureBall.setName(0,sprintf("Graphics/Battle animations/ball_%02d",@pokemon2.ballused))
    pictureBall.setSrcSize(0,32,64)
    pictureBall.setOrigin(0,PictureOrigin::Center)
    pictureBall.setVisible(0,true)
    # Starting position of sprite
    picturePoke.setOrigin(0,PictureOrigin::Bottom)
    picturePoke.setZoom(0,0)
    picturePoke.setColor(0,Color.new(31*8,22*8,30*8,255))
    picturePoke.setVisible(0,false)
    # Dropping ball
    y = Graphics.height-96-16-16   # end point of Poké Ball
    delay = picturePoke.totalDuration+2
    for i in 0...4
      t = [4,4,3,2][i]   # Time taken to rise or fall for each bounce
      d = [1,2,4,8][i]   # Fraction of the starting height each bounce rises to
      delay -= t if i==0
      if i>0
        pictureBall.setZoomXY(delay,100+5*(5-i),100-5*(5-i))   # Squish
        pictureBall.moveZoom(delay,2,100)                      # Unsquish
        pictureBall.moveXY(delay,t,Graphics.width/2,y-100/d)
      end
      pictureBall.moveXY(delay+t,t,Graphics.width/2,y)
      pictureBall.setSE(delay+2*t,"Battle ball drop")
      delay = pictureBall.totalDuration
    end
    picturePoke.setXY(delay,Graphics.width/2,y)
    # Open Poké Ball
    delay = pictureBall.totalDuration+15
    pictureBall.setSE(delay,"Battle recall")
    pictureBall.setName(delay,sprintf("Graphics/Battle animations/ball_%02d_open",@pokemon2.ballused))
    pictureBall.setSrcSize(delay,32,64)
    pictureBall.setVisible(delay+5,false)
    # Pokémon appears and enlarges
    picturePoke.setVisible(delay,true)
    picturePoke.moveZoom(delay,8,100)
    picturePoke.moveXY(delay,8,Graphics.width/2,@sprites["rsprite2"].y)
    # Return Pokémon's color to normal and play cry
    delay = picturePoke.totalDuration
    picturePoke.moveColor(delay,5,Color.new(31*8,22*8,30*8,0))
    cry = pbCryFile(@pokemon2)
    picturePoke.setSE(delay,cry) if pbResolveAudioSE(cry)
    # Play animation
    pbRunPictures(
       [picturePoke,pictureBall],
       [@sprites["rsprite2"],spriteBall]
    )
    spriteBall.dispose
  end

  def pbEndScreen
    pbDisposeMessageWindow(@sprites["msgwindow"])
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    newspecies = pbTradeCheckEvolution(@pokemon2,@pokemon)
    if newspecies>0
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(@pokemon2,newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
    end
  end

  def pbTrade
    pbBGMStop
    pbPlayCry(@pokemon)
    speciesname1=PBSpecies.getName(@pokemon.species)
    speciesname2=PBSpecies.getName(@pokemon2.species)
    pbMessageDisplay(@sprites["msgwindow"],
       _ISPRINTF("{1:s}\r\nID: {2:05d}   OT: {3:s}\\wtnp[0]",
       @pokemon.name,@pokemon.publicID,@pokemon.ot)) { pbUpdate }
    pbMessageWaitForInput(@sprites["msgwindow"],50,true) { pbUpdate }
    pbPlayDecisionSE
    pbScene1
    pbMessageDisplay(@sprites["msgwindow"],
       _INTL("For {1}'s {2},\r\n{3} sends {4}.\1",@trader1,speciesname1,@trader2,speciesname2)) { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
       _INTL("{1} bids farewell to {2}.",@trader2,speciesname2)) { pbUpdate }
    pbScene2
    pbMessageDisplay(@sprites["msgwindow"],
       _ISPRINTF("{1:s}\r\nID: {2:05d}   OT: {3:s}\1",
       @pokemon2.name,@pokemon2.publicID,@pokemon2.ot)) { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
       _INTL("Take good care of {1}.",speciesname2)) { pbUpdate }
  end
end



def pbStartTrade(pokemonIndex,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon = $Trainer.party[pokemonIndex]
  opponent = PokeBattle_Trainer.new(trainerName,trainerGender)
  opponent.setForeignID($Trainer)
  yourPokemon = nil; resetmoves = true
  if newpoke.is_a?(PokeBattle_Pokemon)
    newpoke.trainerID = opponent.id
    newpoke.ot        = opponent.name
    newpoke.otgender  = opponent.gender
    newpoke.language  = opponent.language
    yourPokemon = newpoke
    resetmoves = false
  else
    if newpoke.is_a?(String) || newpoke.is_a?(Symbol)
      raise _INTL("Species does not exist ({1}).",newpoke) if !hasConst?(PBSpecies,newpoke)
      newpoke = getID(PBSpecies,newpoke)
    end
    yourPokemon = pbNewPkmn(newpoke,myPokemon.level,opponent)
  end
  yourPokemon.name       = nickname
  yourPokemon.obtainMode = 2   # traded
  yourPokemon.resetMoves if resetmoves
  yourPokemon.pbRecordFirstMoves
  $Trainer.seen[yourPokemon.species]  = true
  $Trainer.owned[yourPokemon.species] = true
  pbSeenForm(yourPokemon)
  pbFadeOutInWithMusic {
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $Trainer.party[pokemonIndex] = yourPokemon
end

#===============================================================================
# Evolution methods
#===============================================================================
def pbTradeCheckEvolution(pkmn, other_pkmn)
  ret = pbCheckEvolutionEx(pkmn) { |pkmn, method, parameter, new_species|
    success = PBEvolution.call("tradeCheck", method, pkmn, parameter, other_pkmn)
    next (success) ? new_species : -1
  }
  return ret
end
