#===============================================================================
# Evolution animation metafiles and related methods
#===============================================================================
class SpriteMetafile
  VIEWPORT      = 0
  TONE          = 1
  SRC_RECT      = 2
  VISIBLE       = 3
  X             = 4
  Y             = 5
  Z             = 6
  OX            = 7
  OY            = 8
  ZOOM_X        = 9
  ZOOM_Y        = 10
  ANGLE         = 11
  MIRROR        = 12
  BUSH_DEPTH    = 13
  OPACITY       = 14
  BLEND_TYPE    = 15
  COLOR         = 16
  FLASHCOLOR    = 17
  FLASHDURATION = 18
  BITMAP        = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport = nil)
    @metafile = []
    @values = [
      viewport,
      Tone.new(0, 0, 0, 0), Rect.new(0, 0, 0, 0),
      true,
      0, 0, 0, 0, 0, 100, 100,
      0, false, 0, 255, 0,
      Color.new(0, 0, 0, 0), Color.new(0, 0, 0, 0),
      0
    ]
  end

  def disposed?
    return false
  end

  def dispose; end

  def flash(color, duration)
    if duration > 0
      @values[FLASHCOLOR] = color.clone
      @values[FLASHDURATION] = duration
      @metafile.push([FLASHCOLOR, color])
      @metafile.push([FLASHDURATION, duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X] = value
    @metafile.push([X, value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y] = value
    @metafile.push([Y, value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    if value && !value.disposed?
      @values[SRC_RECT].set(0, 0, value.width, value.height)
      @metafile.push([SRC_RECT, @values[SRC_RECT].clone])
    end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT] = value
    @metafile.push([SRC_RECT, value])
  end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE] = value
    @metafile.push([VISIBLE, value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z] = value
    @metafile.push([Z, value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX] = value
    @metafile.push([OX, value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY] = value
    @metafile.push([OY, value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def zoom=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def angle
    return @values[ANGLE]
  end

  def angle=(value)
    @values[ANGLE] = value
    @metafile.push([ANGLE, value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR] = value
    @metafile.push([MIRROR, value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH] = value
    @metafile.push([BUSH_DEPTH, value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY] = value
    @metafile.push([OPACITY, value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE] = value
    @metafile.push([BLEND_TYPE, value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR] = value.clone
    @metafile.push([COLOR, @values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE] = value.clone
    @metafile.push([TONE, @values[TONE]])
  end

  def update
    @metafile.push([-1, nil])
  end
end

#===============================================================================
#
#===============================================================================
class SpriteMetafilePlayer
  def initialize(metafile, sprite = nil)
    @metafile = metafile
    @sprites = []
    @playing = false
    @index = 0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing = true
    @index = 0
  end

  def update
    if @playing
      (@index...@metafile.length).each do |j|
        @index = j + 1
        break if @metafile[j][0] < 0
        code = @metafile[j][0]
        value = @metafile[j][1]
        @sprites.each do |sprite|
          case code
          when SpriteMetafile::X          then sprite.x = value
          when SpriteMetafile::Y          then sprite.y = value
          when SpriteMetafile::OX         then sprite.ox = value
          when SpriteMetafile::OY         then sprite.oy = value
          when SpriteMetafile::ZOOM_X     then sprite.zoom_x = value
          when SpriteMetafile::ZOOM_Y     then sprite.zoom_y = value
          when SpriteMetafile::SRC_RECT   then sprite.src_rect = value
          when SpriteMetafile::VISIBLE    then sprite.visible = value
          when SpriteMetafile::Z          then sprite.z = value   # prevent crashes
          when SpriteMetafile::ANGLE      then sprite.angle = (value == 180) ? 179.9 : value
          when SpriteMetafile::MIRROR     then sprite.mirror = value
          when SpriteMetafile::BUSH_DEPTH then sprite.bush_depth = value
          when SpriteMetafile::OPACITY    then sprite.opacity = value
          when SpriteMetafile::BLEND_TYPE then sprite.blend_type = value
          when SpriteMetafile::COLOR      then sprite.color = value
          when SpriteMetafile::TONE       then sprite.tone = value
          end
        end
      end
      @playing = false if @index == @metafile.length
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbSaveSpriteState(sprite)
  state = []
  return state if !sprite || sprite.disposed?
  state[SpriteMetafile::BITMAP]     = sprite.x
  state[SpriteMetafile::X]          = sprite.x
  state[SpriteMetafile::Y]          = sprite.y
  state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
  state[SpriteMetafile::VISIBLE]    = sprite.visible
  state[SpriteMetafile::Z]          = sprite.z
  state[SpriteMetafile::OX]         = sprite.ox
  state[SpriteMetafile::OY]         = sprite.oy
  state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
  state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
  state[SpriteMetafile::ANGLE]      = sprite.angle
  state[SpriteMetafile::MIRROR]     = sprite.mirror
  state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
  state[SpriteMetafile::OPACITY]    = sprite.opacity
  state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
  state[SpriteMetafile::COLOR]      = sprite.color.clone
  state[SpriteMetafile::TONE]       = sprite.tone.clone
  return state
end

def pbRestoreSpriteState(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.x          = state[SpriteMetafile::X]
  sprite.y          = state[SpriteMetafile::Y]
  sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
  sprite.visible    = state[SpriteMetafile::VISIBLE]
  sprite.z          = state[SpriteMetafile::Z]
  sprite.ox         = state[SpriteMetafile::OX]
  sprite.oy         = state[SpriteMetafile::OY]
  sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
  sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
  sprite.angle      = state[SpriteMetafile::ANGLE]
  sprite.mirror     = state[SpriteMetafile::MIRROR]
  sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
  sprite.opacity    = state[SpriteMetafile::OPACITY]
  sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
  sprite.color      = state[SpriteMetafile::COLOR]
  sprite.tone       = state[SpriteMetafile::TONE]
end

def pbSaveSpriteStateAndBitmap(sprite)
  return [] if !sprite || sprite.disposed?
  state = pbSaveSpriteState(sprite)
  state[SpriteMetafile::BITMAP] = sprite.bitmap
  return state
end

def pbRestoreSpriteStateAndBitmap(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.bitmap = state[SpriteMetafile::BITMAP]
  pbRestoreSpriteState(sprite, state)
  return state
end

#===============================================================================
# Evolution screen
#===============================================================================
class PokemonEvolutionScene
  private

  def pbGenerateMetafiles(s1x, s1y, s2x, s2y)
    sprite = SpriteMetafile.new
    sprite.ox      = s1x
    sprite.oy      = s1y
    sprite.opacity = 255
    sprite2 = SpriteMetafile.new
    sprite2.ox      = s2x
    sprite2.oy      = s2y
    sprite2.zoom    = 0.0
    sprite2.opacity = 255
    alpha = 0
    alphaDiff = 10 * 20 / Graphics.frame_rate
    loop do
      sprite.color.red   = 255
      sprite.color.green = 255
      sprite.color.blue  = 255
      sprite.color.alpha = alpha
      sprite.color  = sprite.color
      sprite2.color = sprite.color
      sprite2.color.alpha = 255
      sprite.update
      sprite2.update
      break if alpha >= 255
      alpha += alphaDiff
    end
    totaltempo   = 0
    currenttempo = 25
    maxtempo = 7 * Graphics.frame_rate
    while totaltempo < maxtempo
      currenttempo.times do |j|
        if alpha < 255
          sprite.color.red   = 255
          sprite.color.green = 255
          sprite.color.blue  = 255
          sprite.color.alpha = alpha
          sprite.color = sprite.color
          alpha += 10
        end
        sprite.zoom  = [1.1 * (currenttempo - j - 1) / currenttempo, 1.0].min
        sprite2.zoom = [1.1 * (j + 1) / currenttempo, 1.0].min
        sprite.update
        sprite2.update
      end
      totaltempo += currenttempo
      if totaltempo + currenttempo < maxtempo
        currenttempo.times do |j|
          sprite.zoom  = [1.1 * (j + 1) / currenttempo, 1.0].min
          sprite2.zoom = [1.1 * (currenttempo - j - 1) / currenttempo, 1.0].min
          sprite.update
          sprite2.update
        end
      end
      totaltempo += currenttempo
      currenttempo = [(currenttempo / 1.5).floor, 5].max
    end
    @metafile1 = sprite
    @metafile2 = sprite2
  end

  public

  def pbUpdate(animating = false)
    if animating      # Pokémon shouldn't animate during the evolution animation
      @sprites["background"].update
      @sprites["msgwindow"].update
    else
      pbUpdateSpriteHash(@sprites)
    end
  end

  def pbUpdateNarrowScreen
    halfResizeDiff = 8 * 20 / Graphics.frame_rate
    if @bgviewport.rect.y < 80
      @bgviewport.rect.height -= halfResizeDiff * 2
      if @bgviewport.rect.height < Graphics.height - 64
        @bgviewport.rect.y += halfResizeDiff
        @sprites["background"].oy = @bgviewport.rect.y
      end
    end
  end

  def pbUpdateExpandScreen
    halfResizeDiff = 8 * 20 / Graphics.frame_rate
    if @bgviewport.rect.y > 0
      @bgviewport.rect.y -= halfResizeDiff
      @sprites["background"].oy = @bgviewport.rect.y
    end
    if @bgviewport.rect.height < Graphics.height
      @bgviewport.rect.height += halfResizeDiff * 2
    end
  end

  def pbFlashInOut(canceled, oldstate, oldstate2)
    tone = 0
    toneDiff = 20 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      pbUpdate(true)
      pbUpdateExpandScreen
      tone += toneDiff
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone >= 255
    end
    @bgviewport.rect.y      = 0
    @bgviewport.rect.height = Graphics.height
    @sprites["background"].oy = 0
    if canceled
      pbRestoreSpriteState(@sprites["rsprite1"], oldstate)
      pbRestoreSpriteState(@sprites["rsprite2"], oldstate2)
      @sprites["rsprite1"].zoom_x      = 1.0
      @sprites["rsprite1"].zoom_y      = 1.0
      @sprites["rsprite1"].color.alpha = 0
      @sprites["rsprite1"].visible     = true
      @sprites["rsprite2"].visible     = false
    else
      @sprites["rsprite1"].visible     = false
      @sprites["rsprite2"].visible     = true
      @sprites["rsprite2"].zoom_x      = 1.0
      @sprites["rsprite2"].zoom_y      = 1.0
      @sprites["rsprite2"].color.alpha = 0
    end
    (Graphics.frame_rate / 4).times do
      Graphics.update
      pbUpdate(true)
    end
    tone = 255
    toneDiff = 40 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      pbUpdate
      tone -= toneDiff
      @viewport.tone.set(tone, tone, tone, 0)
      break if tone <= 0
    end
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
    addBackgroundOrColoredPlane(@sprites, "background", "evolutionbg",
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
    rsprite2.opacity = 0
    @sprites["rsprite1"] = rsprite1
    @sprites["rsprite2"] = rsprite2
    pbGenerateMetafiles(rsprite1.ox, rsprite1.oy, rsprite2.ox, rsprite2.oy)
    @sprites["msgwindow"] = pbCreateMessageWindow(@msgviewport)
    pbFadeInAndShow(@sprites) { pbUpdate }
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

  # Opens the evolution screen
  def pbEvolution(cancancel = true)
    metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
    metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
    metaplayer1.play
    metaplayer2.play
    pbBGMStop
    pbMessageDisplay(@sprites["msgwindow"], "\\se[]" + _INTL("What?") + "\\1") { pbUpdate }
    pbPlayDecisionSE
    @pokemon.play_cry
    @sprites["msgwindow"].text = _INTL("{1} is evolving!", @pokemon.name)
    timer = 0.0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      timer += Graphics.delta_s
      break if timer >= 1.0
    end
    oldstate  = pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
    pbMEPlay("Evolution start")
    pbBGMPlay("Evolution")
    canceled = false
    loop do
      pbUpdateNarrowScreen
      metaplayer1.update
      metaplayer2.update
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::BACK) && cancancel
        pbBGMStop
        pbPlayCancelSE
        canceled = true
        break
      end
      break unless metaplayer1.playing? && metaplayer2.playing?
    end
    pbFlashInOut(canceled, oldstate, oldstate2)
    if canceled
      $stats.evolutions_cancelled += 1
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
    else
      pbEvolutionSuccess
    end
  end

  def pbEvolutionSuccess
    $stats.evolution_count += 1
    # Play cry of evolved species
    frames = (GameData::Species.cry_length(@newspecies, @pokemon.form) * Graphics.frame_rate).ceil
    Pokemon.play_cry(@newspecies, @pokemon.form)
    (frames + 4).times do
      Graphics.update
      pbUpdate
    end
    pbBGMStop
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = GameData::Species.get(@newspecies).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
                           @pokemon.name, newspeciesname)) { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    @pokemon.species = @newspecies
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
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned && $player.has_pokedex
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", newspeciesname)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
        @sprites["msgwindow"].text = "" if moves_to_learn.length > 0
        pbEndScreen(false) if moves_to_learn.length == 0
      }
    end
    # Learn moves upon evolution for evolved species
    moves_to_learn.each do |move|
      pbLearnMove(@pokemon, move, true) { pbUpdate }
    end
  end

  def pbEvolutionMethodAfterEvolution
    @pokemon.action_after_evolution(@newspecies)
  end

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
end
