#===============================================================================
# * Hall of Fame - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a recordable Hall of Fame
# like the Gen 3 games.
#
#===============================================================================
#
# To this scripts works, put it above main, put a 512x384 picture in
# hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
# use 'pbHallOfFameEntry'. After you recorder the first entry, you can access
# the hall teams using a PC. You can also check the player Hall of Fame last
# number using '$PokemonGlobal.hallOfFameLastNumber'.
#
#===============================================================================
class HallOfFame_Scene
  # When true, all pokémon will be in one line
  # When false, all pokémon will be in two lines
  SINGLE_ROW_OF_POKEMON = false
  # Make the pokémon movement ON in hall entry
  ANIMATION = true
  # Speed in pokémon movement in hall entry. Don't use less than 2!
  ANIMATIONSPEED = 32
  # Entry wait time (in seconds) between showing each Pokémon (and trainer).
  # Waits for twice this tme when showing "Welcome to the Hall of Fame!".
  ENTRY_WAIT_TIME = 3.0
  # Maximum number limit of simultaneous hall entries saved.
  # 0 = Doesn't save any hall. -1 = no limit
  # Prefer to use larger numbers (like 500 and 1000) than don't put a limit
  # If a player exceed this limit, the first one will be removed
  HALL_ENTRIES_LIMIT = 50
  # The entry music name. Put "" to doesn't play anything
  HALL_OF_FAME_BGM = "Hall of Fame"
  # Allow eggs to be show and saved in hall
  ALLOW_EGGS = true
  # Remove the hallbars when the trainer sprite appears
  REMOVE_BARS_WHEN_SHOWING_TRAINER = true
  # The final fade speed on entry
  FINAL_FADE_DURATION = 1.0
  # Sprite's opacity value when it isn't selected
  OPACITY = 64
  TEXT_BASE_COLOR   = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(0, 0, 0)

  # Placement for pokemon icons
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Comment the below line to doesn't use a background
    addBackgroundPlane(@sprites, "bg", "Hall of Fame/bg", @viewport)
    @sprites["hallbars"] = IconSprite.new(@viewport)
    @sprites["hallbars"].setBitmap("Graphics/UI/Hall of Fame/bars")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 10
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @alreadyFadedInEnd = false
    @useMusic = false
    @battlerIndex = 0
    @hallEntry = []
    @nationalDexList = [:NONE]
    GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
  end

  def pbStartSceneEntry
    pbStartScene
    @useMusic = (HALL_OF_FAME_BGM && HALL_OF_FAME_BGM != "")
    pbBGMPlay(HALL_OF_FAME_BGM) if @useMusic
    saveHallEntry
    @xmovement = []
    @ymovement = []
    createBattlers
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartScenePC
    pbStartScene
    @hallIndex = $PokemonGlobal.hallOfFame.size - 1
    @hallEntry = $PokemonGlobal.hallOfFame[-1]
    createBattlers(false)
    pbFadeInAndShow(@sprites) { pbUpdate }
    pbUpdatePC
  end

  def pbEndScene
    $game_map.autoplay if @useMusic
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites.include?("msgwindow")
    pbFadeOutAndHide(@sprites) { pbUpdate } if !@alreadyFadedInEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def slowFadeOut(duration)
    timer_start = System.uptime
    loop do
      alpha = lerp(255, 0, duration, timer_start, System.uptime)
      pbSetSpritesToColor(@sprites, Color.new(0, 0, 0, alpha))
      Graphics.update
      Input.update
      pbUpdate
      break if alpha == 0
    end
  end

  # Dispose the sprite if the sprite exists and make it null
  def restartSpritePosition(sprites, spritename)
    sprites[spritename].dispose if sprites.include?(spritename) && sprites[spritename]
    sprites[spritename] = nil
  end

  # Change the pokémon sprites opacity except the index one
  def setPokemonSpritesOpacity(index, opacity = 255)
    @hallEntry.size.times do |n|
      @sprites["pokemon#{n}"].opacity = (n == index) ? 255 : opacity if @sprites["pokemon#{n}"]
    end
  end

  def saveHallEntry
    $player.party.each do |pkmn|
      # Clones every pokémon object
      @hallEntry.push(pkmn.clone) if !pkmn.egg? || ALLOW_EGGS
    end
    # Update the global variables
    $PokemonGlobal.hallOfFame.push(@hallEntry)
    $PokemonGlobal.hallOfFameLastNumber += 1
    if HALL_ENTRIES_LIMIT >= 0 && $PokemonGlobal.hallOfFame.size > HALL_ENTRIES_LIMIT
      $PokemonGlobal.hallOfFame.delete_at(0)
    end
  end

  # Return the x/y point position in screen for battler index number
  # Don't use odd numbers!
  def xpointformula(battlernumber)
    ret = 0
    if SINGLE_ROW_OF_POKEMON
      ret = ((60 * (battlernumber / 2)) + 48) * (xpositionformula(battlernumber) - 1)
      ret += (Graphics.width / 2) - 56
    else
      ret = 32 + (160 * xpositionformula(battlernumber))
    end
    return ret
  end

  def ypointformula(battlernumber)
    ret = 0
    if SINGLE_ROW_OF_POKEMON
      ret = 96 - (8 * (battlernumber / 2))
    else
      ret = 32 + (128 * ypositionformula(battlernumber) / 2)
    end
    return ret
  end

  # Returns 0, 1 or 2 as the x/y column value
  def xpositionformula(battlernumber)
    ret = 0
    if SINGLE_ROW_OF_POKEMON
      ret = (battlernumber % 2) * 2
    else
      ret = (battlernumber / 3).even? ? (19 - battlernumber) % 3 : (19 + battlernumber) % 3
    end
    return ret
  end

  def ypositionformula(battlernumber)
    ret = 0
    if SINGLE_ROW_OF_POKEMON
      ret = 1
    else
      ret = ((battlernumber / 3) % 2) * 2
    end
    return ret
  end

  def moveSprite(i)
    spritename = (i > -1) ? "pokemon#{i}" : "trainer"
    speed = (i > -1) ? ANIMATIONSPEED : 2
    if !ANIMATION   # Skips animation
      @sprites[spritename].x -= speed * @xmovement[i]
      @xmovement[i] = 0
      @sprites[spritename].y -= speed * @ymovement[i]
      @ymovement[i] = 0
    end
    if @xmovement[i] != 0
      direction = (@xmovement[i] > 0) ? -1 : 1
      @sprites[spritename].x += speed * direction
      @xmovement[i] += direction
    end
    if @ymovement[i] != 0
      direction = (@ymovement[i] > 0) ? -1 : 1
      @sprites[spritename].y += speed * direction
      @ymovement[i] += direction
    end
  end

  def createBattlers(hide = true)
    # Movement in animation
    6.times do |i|
      # Clear all 6 pokémon sprites and dispose the ones that exists every time
      # that this method is call
      restartSpritePosition(@sprites, "pokemon#{i}")
      next if i >= @hallEntry.size
      xpoint = xpointformula(i)
      ypoint = ypointformula(i)
      pok = @hallEntry[i]
      @sprites["pokemon#{i}"] = PokemonSprite.new(@viewport)
      @sprites["pokemon#{i}"].setOffset(PictureOrigin::TOP_LEFT)
      @sprites["pokemon#{i}"].setPokemonBitmap(pok)
      # This method doesn't put the exact coordinates
      @sprites["pokemon#{i}"].x = xpoint
      @sprites["pokemon#{i}"].y = ypoint
      if @sprites["pokemon#{i}"].bitmap && !@sprites["pokemon#{i}"].disposed?
        @sprites["pokemon#{i}"].x += (128 - @sprites["pokemon#{i}"].bitmap.width) / 2
        @sprites["pokemon#{i}"].y += (128 - @sprites["pokemon#{i}"].bitmap.height) / 2
      end
      @sprites["pokemon#{i}"].z = 7 - i if SINGLE_ROW_OF_POKEMON
      next if !hide
      # Animation distance calculation
      horizontal = 1 - xpositionformula(i)
      vertical = 1 - ypositionformula(i)
      xdistance = (horizontal == -1) ? -@sprites["pokemon#{i}"].bitmap.width : Graphics.width
      ydistance = (vertical == -1) ? -@sprites["pokemon#{i}"].bitmap.height : Graphics.height
      xdistance = ((xdistance - @sprites["pokemon#{i}"].x) / ANIMATIONSPEED).abs + 1
      ydistance = ((ydistance - @sprites["pokemon#{i}"].y) / ANIMATIONSPEED).abs + 1
      biggerdistance = (xdistance > ydistance) ? xdistance : ydistance
      @xmovement[i] = biggerdistance
      @xmovement[i] *= -1 if horizontal == -1
      @xmovement[i] = 0   if horizontal == 0
      @ymovement[i] = biggerdistance
      @ymovement[i] *= -1 if vertical == -1
      @ymovement[i] = 0   if vertical == 0
      # Hide the battlers
      @sprites["pokemon#{i}"].x += @xmovement[i] * ANIMATIONSPEED
      @sprites["pokemon#{i}"].y += @ymovement[i] * ANIMATIONSPEED
    end
  end

  def createTrainerBattler
    @sprites["trainer"] = IconSprite.new(@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.front_sprite_filename($player.trainer_type))
    if SINGLE_ROW_OF_POKEMON
      @sprites["trainer"].x = Graphics.width / 2
      @sprites["trainer"].y = 178
    else
      @sprites["trainer"].x = Graphics.width - 96
      @sprites["trainer"].y = 160
    end
    @sprites["trainer"].z = 9
    @sprites["trainer"].ox = @sprites["trainer"].bitmap.width / 2
    @sprites["trainer"].oy = @sprites["trainer"].bitmap.height / 2
    if REMOVE_BARS_WHEN_SHOWING_TRAINER
      @sprites["overlay"].bitmap.clear
      @sprites["hallbars"].visible = false
    end
    @xmovement[@battlerIndex] = 0
    @ymovement[@battlerIndex] = 0
    if ANIMATION && !SINGLE_ROW_OF_POKEMON   # Trainer Animation
      startpoint = Graphics.width / 2
      # 2 is the trainer speed
      @xmovement[@battlerIndex] = (startpoint - @sprites["trainer"].x) / 2
      @sprites["trainer"].x = startpoint
    else
      timer_start = System.uptime
      loop do
        Graphics.update
        Input.update
        pbUpdate
        break if System.uptime - timer_start >= ENTRY_WAIT_TIME
      end
    end
  end

  def writeTrainerData
    if $PokemonGlobal.hallOfFameLastNumber == 1
      totalsec = $stats.time_to_enter_hall_of_fame.to_i
    else
      totalsec = $stats.play_time.to_i
    end
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    pubid = sprintf("%05d", $player.public_ID)
    lefttext = _INTL("Name<r>{1}", $player.name) + "<br>"
    lefttext += _INTL("ID No.<r>{1}", pubid) + "<br>"
    if hour > 0
      lefttext += _INTL("Time<r>{1}h {2}m", hour, min) + "<br>"
    else
      lefttext += _INTL("Time<r>{1}m", min) + "<br>"
    end
    lefttext += _INTL("Pokédex<r>{1}/{2}",
                      $player.pokedex.owned_count, $player.pokedex.seen_count) + "<br>"
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport = @viewport
    @sprites["messagebox"].width = 192 if @sprites["messagebox"].width < 192
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("League champion!\nCongratulations!") + "\\^")
  end

  def writePokemonData(pokemon, hallNumber = -1)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pokename = pokemon.name
    speciesname = pokemon.speciesName
    if pokemon.male?
      speciesname += "♂"
    elsif pokemon.female?
      speciesname += "♀"
    end
    pokename += "/" + speciesname
    pokename = _INTL("Egg") + "/" + _INTL("Egg") if pokemon.egg?
    idno = (pokemon.owner.name.empty? || pokemon.egg?) ? "?????" : sprintf("%05d", pokemon.owner.public_id)
    dexnumber = _INTL("No. ???")
    if !pokemon.egg?
      number = @nationalDexList.index(pokemon.species) || 0
      dexnumber = _ISPRINTF("No. {1:03d}", number)
    end
    textPositions = [
      [dexnumber, 32, Graphics.height - 74, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [pokename, Graphics.width - 192, Graphics.height - 74, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [_INTL("Lv. {1}", pokemon.egg? ? "?" : pokemon.level),
       64, Graphics.height - 42, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [_INTL("ID No. {1}", pokemon.egg? ? "?????" : idno),
       Graphics.width - 192, Graphics.height - 42, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    if hallNumber > -1
      textPositions.push([_INTL("Hall of Fame No."), (Graphics.width / 2) - 104, 6, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
      textPositions.push([hallNumber.to_s, (Graphics.width / 2) + 104, 6, :right, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(overlay, textPositions)
  end

  def writeWelcome
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pbDrawTextPositions(overlay, [[_INTL("Welcome to the Hall of Fame!"),
                                   Graphics.width / 2, Graphics.height - 68, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
  end

  def pbAnimationLoop
    loop do
      Graphics.update
      Input.update
      pbUpdate
      pbUpdateAnimation
      break if @battlerIndex == @hallEntry.size + 2
    end
  end

  def pbPCSelection
    loop do
      Graphics.update
      Input.update
      pbUpdate
      continueScene = true
      break if Input.trigger?(Input::BACK)   # Exits
      if Input.trigger?(Input::USE)   # Moves the selection one entry backward
        @battlerIndex += 10
        continueScene = pbUpdatePC
      end
      if Input.trigger?(Input::LEFT)   # Moves the selection one pokémon forward
        @battlerIndex -= 1
        continueScene = pbUpdatePC
      end
      if Input.trigger?(Input::RIGHT)   # Moves the selection one pokémon backward
        @battlerIndex += 1
        continueScene = pbUpdatePC
      end
      break if !continueScene
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateAnimation
    if @battlerIndex <= @hallEntry.size
      if @xmovement[@battlerIndex] != 0 || @ymovement[@battlerIndex] != 0
        spriteIndex = (@battlerIndex < @hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex += 1
        if @battlerIndex <= @hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the
          # ENTRY_WAIT_TIME and goes to the next battler
          @hallEntry[@battlerIndex - 1].play_cry
          writePokemonData(@hallEntry[@battlerIndex - 1])
          timer_start = System.uptime
          loop do
            Graphics.update
            Input.update
            pbUpdate
            break if System.uptime - timer_start >= ENTRY_WAIT_TIME
          end
          if @battlerIndex < @hallEntry.size   # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex, OPACITY)
            @sprites["overlay"].bitmap.clear
          else   # Show the welcome message and prepares the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            timer_start = System.uptime
            loop do
              Graphics.update
              Input.update
              pbUpdate
              break if System.uptime - timer_start >= ENTRY_WAIT_TIME * 2
            end
            setPokemonSpritesOpacity(-1, OPACITY) if !SINGLE_ROW_OF_POKEMON
            createTrainerBattler
          end
        end
      end
    elsif @battlerIndex > @hallEntry.size
      # Write the trainer data and fade
      writeTrainerData
      timer_start = System.uptime
      loop do
        Graphics.update
        Input.update
        pbUpdate
        break if System.uptime - timer_start >= ENTRY_WAIT_TIME
      end
      pbBGMFade(FINAL_FADE_DURATION) if @useMusic
      slowFadeOut(FINAL_FADE_DURATION)
      @alreadyFadedInEnd = true
      @battlerIndex += 1
    end
  end

  def pbUpdatePC
    # Change the team
    if @battlerIndex >= @hallEntry.size
      @hallIndex -= 1
      return false if @hallIndex == -1
      @hallEntry = $PokemonGlobal.hallOfFame[@hallIndex]
      @battlerIndex = 0
      createBattlers(false)
    elsif @battlerIndex < 0
      @hallIndex += 1
      return false if @hallIndex >= $PokemonGlobal.hallOfFame.size
      @hallEntry = $PokemonGlobal.hallOfFame[@hallIndex]
      @battlerIndex = @hallEntry.size - 1
      createBattlers(false)
    end
    # Change the pokemon
    @hallEntry[@battlerIndex].play_cry
    setPokemonSpritesOpacity(@battlerIndex, OPACITY)
    hallNumber = $PokemonGlobal.hallOfFameLastNumber + @hallIndex -
                 $PokemonGlobal.hallOfFame.size + 1
    writePokemonData(@hallEntry[@battlerIndex], hallNumber)
    return true
  end
end

#===============================================================================
#
#===============================================================================
class HallOfFameScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreenEntry
    @scene.pbStartSceneEntry
    @scene.pbAnimationLoop
    @scene.pbEndScene
  end

  def pbStartScreenPC
    @scene.pbStartScenePC
    @scene.pbPCSelection
    @scene.pbEndScene
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_menu, :hall_of_fame, {
  "name"      => _INTL("Hall of Fame"),
  "order"     => 40,
  "condition" => proc { next $PokemonGlobal.hallOfFameLastNumber > 0 },
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]Accessed the Hall of Fame."))
    pbHallOfFamePC
    next false
  }
})

#===============================================================================
#
#===============================================================================
class PokemonGlobalMetadata
  attr_writer :hallOfFame
  # Number necessary if hallOfFame array reach in its size limit
  attr_writer :hallOfFameLastNumber

  def hallOfFame
    @hallOfFame = [] if !@hallOfFame
    return @hallOfFame
  end

  def hallOfFameLastNumber
    return @hallOfFameLastNumber || 0
  end
end

#===============================================================================
#
#===============================================================================
def pbHallOfFameEntry
  scene = HallOfFame_Scene.new
  screen = HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end

def pbHallOfFamePC
  scene = HallOfFame_Scene.new
  screen = HallOfFameScreen.new(scene)
  screen.pbStartScreenPC
end
