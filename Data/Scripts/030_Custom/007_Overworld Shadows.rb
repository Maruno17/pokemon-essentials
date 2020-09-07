#==============================================================================#
#                             Overworld Shadows                                #
#                                  by Marin                                    #
#==============================================================================#
#                                    Info                                      #
#                                                                              #
#   You'll have likely heard of KleinStudios' Overworld Shadows script; many   #
#    fangames use it, after all. It was not compatible with Essentials v17+    #
#    though, so after getting the suggestion I thought it would be cool if I   #
#   could make something of my own that would work with v16, as well as v17.   #
#==============================================================================#
#                                  Features:                                   #
#                - Blacklisting events from receiving shadows                  #
#                - Whitelisting events to always receive shadows               #
#                - A scaling animation when an event jumps                     #
#==============================================================================#
#                                    Usage                                     #
#                                                                              #
#     Shadow_Path is the path to the shadow graphic. You can change this       #
#   sprite, though you may need to fiddle with positioning of the sprite in    #
#  relation to the event after, though. That's done in "def position_shadow".  #
#                                                                              #
#  As the name literally says, if an event's name includes any of the strings  #
#  in "No_Shadow_If_Event_Name_Has", it won't get a shadow, UNLESS the event's #
#                 name also includes any of the strings in                     #
#   "Always_Give_Shadow_If_Event_Name_Has". This is essentially "overriding".  #
#                                                                              #
#    Case_Sensitive is either true or false. It's used when determing if an    #
# event's name includes a string in the "No_Shadow" and "Always_Give" arrays.  #
#      If true, it must match all strings with capitals exactly as well.       #
#                If false, capitals don't need to match up.                    #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
  :name => "Overworld Shadows",
  :version => "1.12",
  :credits => "Marin",
  :link => "https://reliccastle.com/resources/161/"
})

Shadow_Path = "Graphics/Characters/shadow"

# Whether or not the event names below need to match in capitals as well.
Case_Sensitive = false

No_Shadow_If_Event_Name_Has = [
    # I like to use "extensions" like these. Up to you though.
    ".shadowless",
    ".noshadow",
    ".sl",
    "Door",
    "Stairs"
]

# Events that have this in their event name will always receive a shadow.
# Does take "Case_Sensitive" into account.
Always_Give_Shadow_If_Event_Name_Has = [
    "Trainer"
]

# Determines whether or not an event should be given a shadow.
def pbShouldGetShadow?(event)
  return true if event.is_a?(Game_Player) # The player will always have a shadow
  page = pbGetActiveEventPage(event)
  return false unless page
  comments = page.list.select { |e| e.code == 108 || e.code == 408 }.map do |e|
    e.parameters.join
  end
  Always_Give_Shadow_If_Event_Name_Has.each do |e|
    name = event.name.clone
    unless Case_Sensitive
      e.downcase!
      name.downcase!
    end
    return true if name.include?(e) || comments.any? { |c| c.include?(e) }
  end
  No_Shadow_If_Event_Name_Has.each do |e|
    name = event.name.clone
    unless Case_Sensitive
      e.downcase!
      name.downcase!
    end
    return false if name.include?(e) || comments.any? { |c| c.include?(e) }
  end
  return true
end

# Extending so we can access some private instance variables.
class Game_Character
  attr_reader :jump_count
end

unless Spriteset_Map.respond_to?(:viewport)
  class Spriteset_Map
    def viewport
      return @viewport1
    end
    
    def self.viewport
      return $scene.spriteset.viewport rescue nil
    end
  end
end

# Following Pokémon compatibility
def pbToggleFollowingPokemon
  return if $Trainer.party[0].hp <= 0 || $Trainer.party[0].isEgg?
  if $game_switches[Following_Activated_Switch]
    if $game_switches[Toggle_Following_Switch]
      $game_switches[Toggle_Following_Switch] = false
      $PokemonTemp.dependentEvents.remove_sprite(true)
      $scene.spriteset.usersprites.select do |e|
        e.is_a?(DependentEventSprites)
      end.each do |des|
        des.sprites.each do |e|
          if e && e.shadow
            e.shadow.dispose
            e.shadow = nil
          end
        end
      end
      pbWait(1)
    else
      $game_switches[Toggle_Following_Switch] = true
      $PokemonTemp.dependentEvents.refresh_sprite
      $scene.spriteset.usersprites.select do |e|
        e.is_a?(DependentEventSprites)
      end.each do |des|
        des.sprites.each do |e|
          e.make_shadow if e.respond_to?(:make_shadow)
        end
      end
      pbWait(1)
    end
  end
end

class DependentEventSprites
  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent do |event, data|
       if data[2] == @map.map_id # Check current map
         spr = Sprite_Character.new(@viewport,event,true)
         @sprites.push(spr)
       end
    end
  end
end

unless defined?(pbGetActiveEventPage)
  def pbGetActiveEventPage(event, mapid = nil)
    mapid ||= event.map.map_id if event.respond_to?(:map)
    pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
    for i in 0...pages.size
      c = pages[pages.size - 1 - i].condition
      ss = !(c.self_switch_valid && !$game_self_switches[[mapid,
          event.id,c.self_switch_ch]])
      sw1 = !(c.switch1_valid && !$game_switches[c.switch1_id])
      sw2 = !(c.switch2_valid && !$game_switches[c.switch2_id])
      var = true
      if c.variable_valid
        if !c.variable_value || !$game_variables[c.variable_id].is_a?(Numeric) ||
           $game_variables[c.variable_id] < c.variable_value
          var = false
        end
      end
      if ss && sw1 && sw2 && var # All conditions are met
        return pages[pages.size - 1 - i]
      end
    end
    return nil
  end
end

class Spriteset_Map
  attr_accessor :usersprites
end

class Sprite_Character
  attr_accessor :shadow
  
  alias ow_shadow_init initialize
  def initialize(viewport, character = nil, is_follower = false)
    @viewport = viewport
    @is_follower = is_follower
    ow_shadow_init(@viewport, character)
    return unless pbShouldGetShadow?(character)
    return if @is_follower && defined?(Toggle_Following_Switch) &&
              !$game_switches[Toggle_Following_Switch]
    return if @is_follower && defined?(Following_Activated_Switch) &&
              !$game_switches[Following_Activated_Switch]
    @character = character
    if @character.is_a?(Game_Event)
      page = pbGetActiveEventPage(@character)
      return if !page || !page.graphic || page.graphic.character_name == ""
    end
    make_shadow
  end
  
  def make_shadow
    @shadow.dispose if @shadow
    @shadow = nil
    @shadow = Sprite.new(@viewport)
    @shadow.bitmap = BitmapCache.load_bitmap(Shadow_Path)
    # Center the shadow by halving the origin points
    @shadow.ox = @shadow.bitmap.width / 2.0
    @shadow.oy = @shadow.bitmap.height / 2.0
    # Positioning the shadow
    position_shadow
  end
  
  def position_shadow
    return unless @shadow
    x = @character.screen_x
    y = @character.screen_y
    if @character.jumping?
      @totaljump = @character.jump_count if !@totaljump
      case @character.jump_count
      when 1..(@totaljump / 3)
        @shadow.zoom_x += 0.1
        @shadow.zoom_y += 0.1
      when (@totaljump / 3 + 1)..(@totaljump / 3 + 2)
        @shadow.zoom_x += 0.05
        @shadow.zoom_y += 0.05
      when (@totaljump / 3 * 2 - 1)..(@totaljump / 3 * 2)
        @shadow.zoom_x -= 0.05
        @shadow.zoom_y -= 0.05
      when (@totaljump / 3 * 2 + 1)..(@totaljump)
        @shadow.zoom_x -= 0.1
        @shadow.zoom_y -= 0.1
      end
      if @character.jump_count == 1
        @shadow.zoom_x = 1.0
        @shadow.zoom_y = 1.0
        @totaljump = nil
      end
    end
    @shadow.x = x
    @shadow.y = y - 6
    @shadow.z = self.z - 1
    if @shadow
      if !@charbitmap || @charbitmap.disposed? || @character.instance_eval { @erased }
        @shadow.dispose
        @shadow = nil
      end
    end
  end
  
  alias ow_shadow_visible visible=
  def visible=(value)
    ow_shadow_visible(value)
    @shadow.visible = value if @shadow
  end

  alias ow_shadow_dispose dispose
  def dispose
    ow_shadow_dispose
    @shadow.dispose if @shadow
    @shadow = nil
  end

  alias ow_shadow_update update
  def update
    ow_shadow_update
    position_shadow
    
    if @character.is_a?(Game_Event)
      page = pbGetActiveEventPage(@character)
      if @old_page != page
        @shadow.dispose if @shadow
        @shadow = nil
        if page && page.graphic && page.graphic.character_name != "" &&
           pbShouldGetShadow?(@character)
          unless @is_follower && defined?(Toggle_Following_Switch) &&
                 !$game_switches[Toggle_Following_Switch]
            unless defined?(Following_Activated_Switch) &&
                   !$game_switches[Following_Activated_Switch]
              make_shadow
            end
          end
        end
      end
    end
    
    @old_page = (@character.is_a?(Game_Event) ? pbGetActiveEventPage(@character) : nil)
    
    bushdepth = @character.bush_depth
    if @shadow
      @shadow.opacity = self.opacity
      @shadow.visible = (bushdepth == 0)
      if !self.visible || (@is_follower || @character == $game_player) &&
         ($PokemonGlobal.surfing || $PokemonGlobal.diving)
        @shadow.visible = false
      end
    end
  end
end