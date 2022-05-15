PluginManager.register({
                         :name => "Carmaniac's Speech Bubbles",
                         :version => "1.1",
                         :credits => ["Carmaniac","Avery","Boonzeet"],
                         :link => "https://reliccastle.com/resources/461/"
                       })

#-------------------------------------------------------------------------------
# Carmaniac's Speech Bubbles for v18
# Updated by Avery
#-------------------------------------------------------------------------------
# To use, call pbCallBub(type, eventID)
#
# Where type is either 1 or 2:
# 1 - floating bubble
# 2 - speech bubble with arrow
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Class modifiers
#-------------------------------------------------------------------------------

class PokemonTemp
  attr_accessor :speechbubble_bubble
  attr_accessor :speechbubble_vp
  attr_accessor :speechbubble_arrow
  attr_accessor :speechbubble_outofrange
  attr_accessor :speechbubble_talking
  attr_accessor :speechbubble_alwaysDown
end

module MessageConfig
  BUBBLETEXTBASE = Color.new(22,22,22)
  BUBBLETEXTSHADOW = Color.new(166,160,151)
  WindowOpacity = 255
end

#-------------------------------------------------------------------------------
# Function modifiers
#-------------------------------------------------------------------------------

class Window_AdvancedTextPokemon
  def text=(value)
    if value != nil && value != "" && $PokemonTemp.speechbubble_bubble && $PokemonTemp.speechbubble_bubble > 0
      if $PokemonTemp.speechbubble_bubble == 1
        $PokemonTemp.speechbubble_bubble = 0
        resizeToFit2(value,400,100)
        @x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
        @y = $game_map.events[$PokemonTemp.speechbubble_talking].screen_y - (32 + @height)

        if @y>(Graphics.height-@height-2)
          @y = (Graphics.height-@height)
        elsif @y<2
          @y=2
        end
        if @x>(Graphics.width-@width-2)
          @x = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_x-@width)
        elsif @x<2
          @x=2
        end
      else
        $PokemonTemp.speechbubble_bubble = 0
      end
    end
    setText(value)
  end
end

def pbRepositionMessageWindow(msgwindow, linecount=2)
  msgwindow.height=32*linecount+msgwindow.borderY
  msgwindow.y=(Graphics.height)-(msgwindow.height)
  if $game_temp && $game_temp.in_battle && !$scene.respond_to?("update_basic")
    msgwindow.y=0
  elsif $game_system && $game_system.respond_to?("message_position")
    case $game_system.message_position
    when 0  # up
      msgwindow.y=0
    when 1  # middle
      msgwindow.y=(Graphics.height/2)-(msgwindow.height/2)
    when 2
      if $PokemonTemp.speechbubble_bubble==1
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 100
        msgwindow.width = 400
      elsif $PokemonTemp.speechbubble_bubble==2
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 102
        msgwindow.width = Graphics.width
        if $game_player.direction==8 && !$PokemonTemp.speechbubble_alwaysDown
          $PokemonTemp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280)
          msgwindow.y = 6
        else
          $PokemonTemp.speechbubble_vp = Viewport.new(0, 6 + msgwindow.height, Graphics.width, 280)
          msgwindow.y = (Graphics.height - msgwindow.height) - 6
          if $PokemonTemp.speechbubble_outofrange==true
            msgwindow.y = 6
          end
        end
      else
        msgwindow.height = 102
        msgwindow.y = Graphics.height - msgwindow.height - 6
      end
    end
  end
  if $game_system && $game_system.respond_to?("message_frame")
    if $game_system.message_frame != 0
      msgwindow.opacity = 0
    end
  end
  if $game_message
    case $game_message.background
    when 1  # dim
      msgwindow.opacity=0
    when 2  # transparent
      msgwindow.opacity=0
    end
  end
end

def pbCreateMessageWindow(viewport=nil,skin=nil)
  arrow = nil
  if $PokemonTemp.speechbubble_bubble==2 && $game_map.events[$PokemonTemp.speechbubble_talking] != nil # Message window set to floating bubble.
    if $game_player.direction==8 && !$PokemonTemp.speechbubble_alwaysDown# Player facing up, message window top.
      $PokemonTemp.speechbubble_vp = Viewport.new(0, 104, Graphics.width, 280)
      $PokemonTemp.speechbubble_vp.z = 999999
      arrow = Sprite.new($PokemonTemp.speechbubble_vp)
      arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x - Graphics.width
      arrow.y = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_y - Graphics.height) - 136
      arrow.z = 999999
      arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow4")
      arrow.zoom_x = 2
      arrow.zoom_y = 2
      if arrow.x<-230
        arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
        arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
      end
    else # Player facing left, down, right, message window bottom.
    $PokemonTemp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280)
    $PokemonTemp.speechbubble_vp.z = 999999
    arrow = Sprite.new($PokemonTemp.speechbubble_vp)
    arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
    arrow.y = $game_map.events[$PokemonTemp.speechbubble_talking].screen_y
    arrow.z = 999999
    arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow1")
    if arrow.y>=Graphics.height-120 # Change arrow direction.
      $PokemonTemp.speechbubble_outofrange=true
      $PokemonTemp.speechbubble_vp.rect.y+=104
      arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x - Graphics.width
      arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow4")
      arrow.y = ($game_map.events[$PokemonTemp.speechbubble_talking].screen_y - Graphics.height) - 136
      if arrow.x<-250
        arrow.x = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x
        arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
      end
      if arrow.x>=256
        arrow.x-=15# = $game_map.events[$PokemonTemp.speechbubble_talking].screen_x-Graphics.width
        arrow.bitmap = RPG::Cache.load_bitmap_path("Graphics/Pictures/Arrow3")
      end
    else
      $PokemonTemp.speechbubble_outofrange=false
    end
    arrow.zoom_x = 2
    arrow.zoom_y = 2
    end
  end
  $PokemonTemp.speechbubble_arrow = arrow
  msgwindow=Window_AdvancedTextPokemon.new("")
  if !viewport
    msgwindow.z=99999
  else
    msgwindow.viewport=viewport
  end
  msgwindow.visible=true
  msgwindow.letterbyletter=true
  msgwindow.back_opacity=MessageConfig::WindowOpacity
  pbBottomLeftLines(msgwindow,2)
  $game_temp.message_window_showing=true if $game_temp
  $game_message.visible=true if $game_message
  skin=MessageConfig.pbGetSpeechFrame() if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing=false if $game_temp
  $game_message.visible=false if $game_message
  msgwindow.dispose
  $PokemonTemp.speechbubble_arrow.dispose if $PokemonTemp.speechbubble_arrow
  $PokemonTemp.speechbubble_vp.dispose if $PokemonTemp.speechbubble_vp
end

def pbCallBub(status=0,value=0,always_down=false)
  begin
  $PokemonTemp.speechbubble_talking=get_character(value).id
  $PokemonTemp.speechbubble_bubble=status
  $PokemonTemp.speechbubble_alwaysDown=always_down
  rescue
    return #Let's not crash the game if error
  end
end