#==============================================================================#
#                                   Footprints                                 #
#                                    by Marin                                  #
#==============================================================================#
#    If an event walks on a tile with terrain tag 3 (Sand), it will produce    #
#             visual footprints. Works with Following Pokémon.                 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
  :name => "Marin's Footprints",
  :version => "1.2",
  :credits => "Marin",
  :link => "https://reliccastle.com/resources/406/",
})

class Sprite_Character
  # This is the amount the opacity is lowered per frame. It needs to go 256 -> 0,
  # which means setting this to 4 would make each step pair last 64 frames (~1.5s)
  FADE_OUT_SPEED = 6
  
  # A configurable X/Y offset for the step sprites, in case they don't align
  # nicely with the player's graphic.
  WALK_X_OFFSET = 0
  WALK_Y_OFFSET = 0
  
  # A configurable X/Y offset for bike print sprites, in case they don't align
  # nicely with the player's graphic.
  BIKE_X_OFFSET = -8
  BIKE_Y_OFFSET = 0
  
  # If true, both the player AND the follower will create footprints.
  # If false, only the follower will create footprints.
  DUPLICATE_FOOTSTEPS_WITH_FOLLOWER = false
  
  # If the event name includes any of these strings, it will not produce
  # footprints.
  EVENTNAME_MAY_NOT_INCLUDE = [
    "NoFootprint",
    ".noprint",
    ".nostep",
    ".nofootprint",
    ".nofootstep"
  ]
  
  # If the filename (graphic) includes any of these strings, it will not produce
  # footprints. Works on top of the event name list.
  FILENAME_MAY_NOT_INCLUDE = [
    
  ]
  
  attr_accessor :steps
  attr_reader :follower
     
  alias footsteps_initialize initialize
  def initialize(*args)
    footsteps_initialize(*args)
    if $PokemonTemp && $PokemonTemp.respond_to?(:dependentEvents) &&
       $PokemonTemp.dependentEvents && $PokemonTemp.dependentEvents.respond_to?(:realEvents) &&
       $PokemonTemp.dependentEvents.realEvents.is_a?(Array) &&
       $PokemonTemp.dependentEvents.realEvents.include?(@character)
      @follower = true
    end
    @steps = []
  end
  
  alias footsteps_dispose dispose
  def dispose
    @steps.each { |e| e[0].dispose }
    footsteps_dispose
  end
  
  alias footsteps_update update
  def update
    footsteps_update
    @old_x ||= @character.x
    @old_y ||= @character.y
    if (@character.x != @old_x || @character.y != @old_y) && !["", "nil"].include?(@character.character_name)
      if @character == $game_player && $PokemonTemp.dependentEvents &&
         $PokemonTemp.dependentEvents.respond_to?(:realEvents) &&
         $PokemonTemp.dependentEvents.realEvents.select { |e| !["", "nil"].include?(e.character_name) }.size > 0 &&
         !DUPLICATE_FOOTSTEPS_WITH_FOLLOWER
        if !EVENTNAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].name) &&
           !FILENAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].character_name)
          make_steps = false
        else
          make_steps = true
        end
      elsif (!@character.respond_to?(:name) || !EVENTNAME_MAY_NOT_INCLUDE.include?(@character.name)) &&
             !FILENAME_MAY_NOT_INCLUDE.include?(@character.character_name)
        tilesetid = @character.map.instance_eval { @map.tileset_id }
        make_steps = [2,1,0].any? do |e|
          tile_id = @character.map.data[@old_x, @old_y, e]
          next false if tile_id.nil?
          next $data_tilesets[tilesetid].terrain_tags[tile_id] == PBTerrain::Sand
        end
      end
      if make_steps
        fstep = Sprite.new(self.viewport)
        fstep.z = 0
        dirs = [nil,"DownLeft","Down","DownRight","Left","Still","Right","UpLeft",
            "Up", "UpRight"]
        if @character == $game_player && $PokemonGlobal.bicycle
          fstep.bmp("Graphics/Characters/steps#{dirs[@character.direction]}Bike")
        else
          fstep.bmp("Graphics/Characters/steps#{dirs[@character.direction]}")
        end
        @steps ||= []
        if @character == $game_player && $PokemonGlobal.bicycle
          x = BIKE_X_OFFSET
          y = BIKE_Y_OFFSET
        else
          x = WALK_X_OFFSET
          y = WALK_Y_OFFSET
        end
        @steps << [fstep, @character.map, @old_x + x / Game_Map::TILE_WIDTH.to_f, @old_y + y / Game_Map::TILE_HEIGHT.to_f]
      end
    end
    @old_x = @character.x
    @old_y = @character.y
    update_footsteps
  end
  
  def update_footsteps
    if @steps
      for i in 0...@steps.size
        next unless @steps[i]
        sprite, map, x, y, ox = @steps[i]
        sprite.x = -map.display_x / Game_Map::X_SUBPIXELS + x * Game_Map::TILE_WIDTH
        sprite.y = -map.display_y / Game_Map::Y_SUBPIXELS + (y + 1) * Game_Map::TILE_HEIGHT
        sprite.y -= Game_Map::TILE_HEIGHT
        sprite.opacity -= FADE_OUT_SPEED
        if sprite.opacity <= 0
          sprite.dispose
          @steps[i] = nil
        end
      end
      @steps.compact!
    end
  end
end

class DependentEventSprites
  attr_accessor :sprites
  
  def refresh
    steps = []
    for sprite in @sprites
      steps << sprite.steps
      if sprite.follower
        $FollowerSteps = sprite.steps
      end
      sprite.steps = []
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent do |event, data|
      if data[0] == @map.map_id # Check original map
        #@map.events[data[1]].erase
      end
      if data[2] == @map.map_id # Check current map
        spr = Sprite_Character.new(@viewport, event)
        if spr.follower
          spr.steps = $FollowerSteps
          $FollowerSteps = nil
        end
        @sprites.push(spr)
      end
    end
  end
end

class Spriteset_Map
  alias footsteps_update update
  def update
    footsteps_update
    # Only update events that are on-screen
    for sprite in @character_sprites
      if sprite.character.is_a?(Game_Event)
        sprite.update_footsteps
      end
    end
  end
end