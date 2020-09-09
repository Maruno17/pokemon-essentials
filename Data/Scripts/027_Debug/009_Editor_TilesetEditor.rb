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
  def pbUpdateTileset
    @sprites["overlay"].bitmap.clear
    textpos = []
    @sprites["tileset"].src_rect = Rect.new(0,@topy,256,Graphics.height-64)
    tilesize = @tileset.terrain_tags.xsize
    for yy in 0...(Graphics.height-64)/32
      ypos = (yy+(@topy/32))*8+384
      next if ypos>=tilesize
      for xx in 0...8
        terr = ypos<384 ? @tileset.terrain_tags[xx*48] : @tileset.terrain_tags[ypos+xx]
        if ypos<384
          @tilehelper.bltTile(@sprites["overlay"].bitmap,xx*32,yy*32,xx*48)
        end
        textpos.push(["#{terr}",xx*32+16,yy*32,2,Color.new(80,80,80),Color.new(192,192,192)])
      end
    end
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,32,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,4,32,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy+28,32,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x+28,@y-@topy,4,32,Color.new(255,0,0))
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end

  def pbGetSelected(x,y)
    return (y<0) ? 48*(x/32) : (y/32)*8+384+(x/32)
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
      @y = -32
      @topy = -32
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
    @sprites["title"] = Window_UnformattedTextPokemon.new(_INTL("Tileset Editor (PgUp/PgDn: SCROLL; Z: MENU)"))
    @sprites["title"].viewport = @viewport
    @sprites["title"].x        = 0
    @sprites["title"].y        = 0
    @sprites["title"].width    = Graphics.width
    @sprites["title"].height   = 64
    @sprites["tileset"] = IconSprite.new(0,64,@viewport)
    @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
    @sprites["tileset"].src_rect = Rect.new(0,0,256,Graphics.height-64)
    @sprites["overlay"] = BitmapSprite.new(256,Graphics.height-64,@viewport)
    @sprites["overlay"].x = 0
    @sprites["overlay"].y = 64
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["title"].visible = true
    @sprites["tileset"].visible = true
    @sprites["overlay"].visible = true
    @x = 0
    @y = -32
    @topy = -32
    pbUpdateTileset
    pbFadeInAndShow(@sprites)
    height = @sprites["tileset"].bitmap.height
    ########
    loop do
      Graphics.update
      Input.update
      if Input.repeat?(Input::UP)
        @y -= 32
        @y = -32 if @y<-32
        @topy = @y if @y<@topy
        pbUpdateTileset
      elsif Input.repeat?(Input::DOWN)
        @y += 32
        @y = height-32 if @y>=height-32
        @topy = @y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
        pbUpdateTileset
      elsif Input.repeat?(Input::LEFT)
        @x -= 32
        @x = 0 if @x<0
        pbUpdateTileset
      elsif Input.repeat?(Input::RIGHT)
        @x += 32
        @x = 256-32 if @x>=256-32
        pbUpdateTileset
      elsif Input.repeat?(Input::L)
        @y -= ((Graphics.height-64)/32)*32
        @topy -= ((Graphics.height-64)/32)*32
        @y = -32 if @y<-32
        @topy = @y if @y<@topy
        @topy = -32 if @topy<-32
        pbUpdateTileset
      elsif Input.repeat?(Input::R)
        @y += ((Graphics.height-64)/32)*32
        @topy += ((Graphics.height-64)/32)*32
        @y = height-32 if @y>=height-32
        @topy = @y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
        if @topy>=height-(Graphics.height-64)
          @topy = height-(Graphics.height-64)
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
          @y = height-32
          @topy = @y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
          pbUpdateTileset
        when 1
          @y = -32
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
