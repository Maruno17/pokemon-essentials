#===============================================================================
# Edits the terrain tags of tiles in tilesets.
#===============================================================================
begin

def pbTilesetWrapper
  return PokemonDataWrapper.new(
     "Data/Tilesets.rxdata",
     "Data/TilesetsTemp.rxdata",
     Proc.new{
        pbMessage(_INTL("The editor has detected that the tileset data was recently edited in RPG Maker XP."))
        next !pbConfirmMessage(_INTL("Do you want to load those recent edits?"))
     }
  )
end



class PokemonTilesetScene
  TILESET_WIDTH = 256
  TILE_SIZE     = 32

  def pbUpdateTileset
    @sprites["overlay"].bitmap.clear
    textpos = []
    @sprites["tileset"].src_rect = Rect.new(0,@topy,TILESET_WIDTH,Graphics.height)
    tilesize = @tileset.terrain_tags.xsize
    for yy in 0...Graphics.height/TILE_SIZE
      ypos = (yy+(@topy/TILE_SIZE))*8+384
      next if ypos>=tilesize
      for xx in 0...8
        terr = ypos<384 ? @tileset.terrain_tags[xx*48] : @tileset.terrain_tags[ypos+xx]
        if ypos<384
          @tilehelper.bltTile(@sprites["overlay"].bitmap,xx*TILE_SIZE,yy*TILE_SIZE,xx*48)
        end
        textpos.push(["#{terr}",xx*TILE_SIZE+TILE_SIZE/2,yy*TILE_SIZE,2,Color.new(80,80,80),Color.new(192,192,192)])
      end
    end
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,TILE_SIZE,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,4,TILE_SIZE,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy+28,TILE_SIZE,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x+28,@y-@topy,4,TILE_SIZE,Color.new(255,0,0))
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end

  def pbGetSelected(x,y)
    return (y<0) ? 48*(x/TILE_SIZE) : (y/TILE_SIZE)*8+384+(x/TILE_SIZE)
  end

  def pbSetSelected(i,value)
    if i<384
      for j in 0...48
        @tileset.terrain_tags[i+j] = value
      end
    else
      @tileset.terrain_tags[i] = value
    end
  end

  def pbChooseTileset
    commands = []
    for i in 1...@tilesetwrapper.data.length
      commands.push(sprintf("%03d %s",i,@tilesetwrapper.data[i].name))
    end
    ret = pbShowCommands(nil,commands,-1)
    if ret>=0
      @tileset = @tilesetwrapper.data[ret+1]
      @tilehelper.dispose
      @tilehelper = TileDrawingHelper.fromTileset(@tileset)
      @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
      @x = 0
      @y = -TILE_SIZE
      @topy = -TILE_SIZE
      pbUpdateTileset
    end
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @tilesetwrapper = pbTilesetWrapper
    @tileset = @tilesetwrapper.data[1]
    @tilehelper = TileDrawingHelper.fromTileset(@tileset)
    @sprites = {}
    @sprites["title"] = Window_UnformattedTextPokemon.new(_INTL("Tileset Editor\r\nPgUp/PgDn: SCROLL\r\nZ: MENU"))
    @sprites["title"].viewport = @viewport
    @sprites["title"].x        = TILESET_WIDTH
    @sprites["title"].y        = 0
    @sprites["title"].width    = Graphics.width - TILESET_WIDTH
    @sprites["title"].height   = 128
    @sprites["tileset"] = IconSprite.new(0,0,@viewport)
    @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
    @sprites["tileset"].src_rect = Rect.new(0,0,TILESET_WIDTH,Graphics.height)
    @sprites["overlay"] = BitmapSprite.new(TILESET_WIDTH,Graphics.height,@viewport)
    @sprites["overlay"].x = 0
    @sprites["overlay"].y = 0
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["title"].visible = true
    @sprites["tileset"].visible = true
    @sprites["overlay"].visible = true
    @x = 0
    @y = -TILE_SIZE
    @topy = -TILE_SIZE
    pbUpdateTileset
    pbFadeInAndShow(@sprites)
    height = @sprites["tileset"].bitmap.height
    ########
    loop do
      Graphics.update
      Input.update
      if Input.repeat?(Input::UP)
        @y -= TILE_SIZE
        @y = -TILE_SIZE if @y<-TILE_SIZE
        @topy = @y if @y<@topy
        pbUpdateTileset
      elsif Input.repeat?(Input::DOWN)
        @y += TILE_SIZE
        @y = height-TILE_SIZE if @y>=height-TILE_SIZE
        @topy = @y-Graphics.height+TILE_SIZE if @y-@topy>=Graphics.height
        pbUpdateTileset
      elsif Input.repeat?(Input::LEFT)
        @x -= TILE_SIZE
        @x = 0 if @x<0
        pbUpdateTileset
      elsif Input.repeat?(Input::RIGHT)
        @x += TILE_SIZE
        @x = TILESET_WIDTH-TILE_SIZE if @x>=TILESET_WIDTH-TILE_SIZE
        pbUpdateTileset
      elsif Input.repeat?(Input::L)
        @y -= (Graphics.height/TILE_SIZE)*TILE_SIZE
        @topy -= (Graphics.height/TILE_SIZE)*TILE_SIZE
        @y = -TILE_SIZE if @y<-TILE_SIZE
        @topy = @y if @y<@topy
        @topy = -TILE_SIZE if @topy<-TILE_SIZE
        pbUpdateTileset
      elsif Input.repeat?(Input::R)
        @y += (Graphics.height/TILE_SIZE)*TILE_SIZE
        @topy += (Graphics.height/TILE_SIZE)*TILE_SIZE
        @y = height-TILE_SIZE if @y>=height-TILE_SIZE
        @topy = @y-Graphics.height+TILE_SIZE if @y-@topy>=Graphics.height
        if @topy>=height-Graphics.height
          @topy = height-Graphics.height
        end
        pbUpdateTileset
      elsif Input.trigger?(Input::A)
        commands = [
           _INTL("Go to bottom"),
           _INTL("Go to top"),
           _INTL("Change tileset"),
           _INTL("Cancel")
        ]
        ret = pbShowCommands(nil,commands,-1)
        case ret
        when 0
          @y = height-TILE_SIZE
          @topy = @y-Graphics.height+TILE_SIZE if @y-@topy>=Graphics.height
          pbUpdateTileset
        when 1
          @y = -TILE_SIZE
          @topy = @y if @y<@topy
          pbUpdateTileset
        when 2
          pbChooseTileset
        end
      elsif Input.trigger?(Input::B)
        if pbConfirmMessage(_INTL("Save changes?"))
          @tilesetwrapper.save
          $data_tilesets = @tilesetwrapper.data
          if $game_map && $MapFactory
            $MapFactory.setup($game_map.map_id)
            $game_player.center($game_player.x,$game_player.y)
            if $scene.is_a?(Scene_Map)
              $scene.disposeSpritesets
              $scene.createSpritesets
            end
          end
          pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
        end
        break if pbConfirmMessage(_INTL("Exit from the editor?"))
      elsif Input.trigger?(Input::C)
        selected = pbGetSelected(@x,@y)
        params = ChooseNumberParams.new
        params.setRange(0,99)
        params.setDefaultValue(@tileset.terrain_tags[selected])
        pbSetSelected(selected,pbMessageChooseNumber(_INTL("Set the terrain tag."),params))
        pbUpdateTileset
      end
    end
    ########
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @tilehelper.dispose
  end
end



def pbTilesetScreen
  pbFadeOutIn {
    scene = PokemonTilesetScene.new
    scene.pbStartScene
  }
end



rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
