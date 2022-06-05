#===============================================================================
# Klein Footprints / WolfPP for Pokémon Essentials
# Give credits if you're using this!
# http://kleinstudio.deviantart.com
#
# bo4p5687 update (v.19)
#===============================================================================

# Fix event comment
def pbEventCommentInput(*args)
  parameters = []
  list = *args[0].list   # Event or event page
  elements = *args[1]    # Number of elements
  trigger = *args[2]     # Trigger
  return nil if list == nil
  return nil unless list.is_a?(Array)
  for item in list
    next unless item.code == 108 || item.code == 408
    if item.parameters[0] == trigger[0]
      start = list.index(item) + 1
      finish = start + elements[0]
      for id in start...finish
        next if !list[id]
        parameters.push(list[id].parameters[0])
      end
      return parameters
    end
  end
  return nil
end

module FootprintVariables
  # If you set pokemon here, they doesn't have footprints
  FOLLOWING_DONT_WALK = [
    # Example:
    # 12,15,17
  ]

  # Set here the terrain tag for footprints, 3 is sand
  TERRAIN_FOOT = 3

  # Initial opacity for footprints
  FOOT_OPACITY = 62

  # Delay velocity
  FOOT_DELAY = 1.1

  def self.get_new_id
    newId = 1
    while !$game_map.events[newId].nil? do
      break if $game_map.events[newId].erased
      newId += 1
    end
    return newId
  end

  def self.show(event, position)
    if event != $game_player
      return if event.character_name == "" || event.character_name == "nil" || event.name.include?("/nofoot/")
      return if pbEventCommentInput(event, 0, "NoFoot")
      if $Trainer.party.length > 0
        return if (!($game_map.events[event] && $game_map.events[event].name == "Dependent") &&
          (FOLLOWING_DONT_WALK.include?($Trainer.party[0].species) || $PokemonGlobal.bicycle))
      end
    end
    character_sprites = $scene.spriteset.character_sprites
    viewport = $scene.spriteset.viewport1
    footsprites = $scene.spriteset.footsprites
    nid = self.get_new_id
    rpgEvent    = RPG::Event.new(position[0], position[1])
    rpgEvent.id = nid
    fev = Game_Event.new($game_map.map_id, rpgEvent, $game_map)
    eventsprite = Sprite_Character.new(viewport, fev)
    character_sprites.push(eventsprite)
    footsprites.push(Footsprite.new(eventsprite, fev, viewport, $game_map, position[2], nid, character_sprites, (event==$game_player)))
  end

end

class Game_Event < Game_Character
  attr_reader :erased
end

class Sprite_Character
  alias old_initialize_foot initialize
  def initialize(viewport, character=nil)
    old_initialize_foot(viewport, character)
    @disposed = false
  end

  alias old_update_foot update
  def update
    return if @disposed
    old_update_foot
  end

  alias old_dispose_foot dispose
  def dispose
    old_dispose_foot
    @disposed = true
  end
end

class Spriteset_Map
  attr_accessor :character_sprites
  attr_accessor :footsprites

  alias old_initialize initialize
  def initialize(map=nil)
    old_initialize(map)
    @footsprites = []
  end

  def viewport1
    return @@viewport1
  end

  def putFootprint(event, pos)
    return FootprintVariables.show(event, pos)
  end

  alias old_dispose dispose
  def dispose
    old_dispose
    @footsprites.each { |sprite| sprite.dispose } if !@footsprites.nil?
    @footsprites.clear
  end

  alias old_update update
  def update
    old_update
    return if @footsprites.nil?
    @footsprites.each { |sprite| sprite.update  }
  end
end

class Scene_Map
  def spriteset?
    return !@spritesets.nil?
  end
end

class Game_Character

  def get_last_pos
    case direction
    when 2 then return [@x,   @y-1, direction] # Move down
    when 4 then return [@x+1, @y,   direction] # Move left
    when 6 then return [@x-1, @y,   direction] # Move right
    when 8 then return [@x,   @y+1, direction] # Move up
    end
    return false
  end

  def foot_prints?
    return $game_map.terrain_tag(get_last_pos[0], get_last_pos[1]) == FootprintVariables::TERRAIN_FOOT && $scene.is_a?(Scene_Map) && $scene.spriteset?
  end

  alias leave_tile_footprints triggerLeaveTile
  def triggerLeaveTile
    leave_tile_footprints
    $scene.spriteset.putFootprint(self, get_last_pos) if foot_prints?
  end

end

class Footsprite
  def initialize(sprite,event,viewport,map,direction,nid,chardata,player)
    @rsprite = sprite
    # Sprite
    @sprite  = Sprite.new(viewport)
    file = player && $PokemonGlobal.bicycle ? "footsetbike.png" : "footset.png"
    @sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", file)
    # Set position
    @realwidth = @sprite.bitmap.width/4
    @sprite.src_rect.width = @realwidth
    @opacity = FootprintVariables::FOOT_OPACITY
    setFootset(direction)
    # Values
    @map = map
    @event = event
    @disposed = false
    @eventid  = nid
    @viewport = viewport
    @chardata = chardata
    update
  end

  def setFootset(direction)
    @sprite.src_rect.x =
      case direction
      when 2 then 0              # Move down
      when 4 then @realwidth * 3 # Move left
      when 6 then @realwidth * 2 # Move right
      when 8 then @realwidth     # Move up
      end
    @sprite.opacity = @opacity
  end

  def dispose
    return if @disposed
    @disposed = true
    @event.erase
    (0...@chardata.length).each { |i| @chardata.delete_at(i) if @chardata[i] == @rsprite }
    @rsprite.dispose
    @sprite.dispose
    @sprite = nil
  end

  def update
    return if @disposed
    x = @rsprite.x - @rsprite.ox
    y = @rsprite.y - @rsprite.oy
    width  = @rsprite.src_rect.width
    height = @rsprite.src_rect.height
    @sprite.x  = x + width / 2
    @sprite.y  = y + height
    @sprite.ox = @realwidth / 2
    @sprite.oy = @sprite.bitmap.height
    @sprite.z  = @rsprite.z - 2
    @opacity  -= FootprintVariables::FOOT_DELAY
    @sprite.opacity = @opacity
    dispose if @sprite.opacity <= 0
  end
end