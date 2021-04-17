class Game_Player < Game_Character
  @@bobFrameSpeed = 1.0/15

  def fullPattern
    case self.direction
    when 2 then return self.pattern
    when 4 then return self.pattern + 4
    when 6 then return self.pattern + 8
    when 8 then return self.pattern + 12
    end
    return 0
  end

  def setDefaultCharName(chname,pattern,lockpattern=false)
    return if pattern<0 || pattern>=16
    @defaultCharacterName = chname
    @direction = [2,4,6,8][pattern/4]
    @pattern = pattern%4
    @lock_pattern = lockpattern
  end

  def pbCanRun?
    return false if $game_temp.in_menu || $game_temp.in_battle ||
                    @move_route_forcing || $game_temp.message_window_showing ||
                    pbMapInterpreterRunning?
    input = ($PokemonSystem.runstyle == 1) ^ Input.press?(Input::ACTION)
    return input && $Trainer.has_running_shoes && !jumping? &&
       !$PokemonGlobal.diving && !$PokemonGlobal.surfing &&
       !$PokemonGlobal.bicycle && !$game_player.pbTerrainTag.must_walk
  end

  def pbIsRunning?
    return moving? && !@move_route_forcing && pbCanRun?
  end

  def character_name
    @defaultCharacterName = "" if !@defaultCharacterName
    return @defaultCharacterName if @defaultCharacterName!=""
    if !@move_route_forcing && $Trainer.character_ID>=0
      meta = GameData::Metadata.get_player($Trainer.character_ID)
      if meta && !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing
        charset = 1   # Display normal character sprite
        if pbCanRun? && (moving? || @wasmoving) && Input.dir4!=0 && meta[4] && meta[4]!=""
          charset = 4   # Display running character sprite
        end
        newCharName = pbGetPlayerCharset(meta,charset)
        @character_name = newCharName if newCharName
        @wasmoving = moving?
      end
    end
    return @character_name
  end

  def update_command
    if $game_player.pbTerrainTag.ice
      self.move_speed = 4     # Sliding on ice
    elsif !moving? && !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        self.move_speed = 5   # Cycling
      elsif pbCanRun? || $PokemonGlobal.surfing
        self.move_speed = 4   # Running, surfing
      else
        self.move_speed = 3   # Walking, diving
      end
    end
    super
  end

  def update_pattern
    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      p = ((Graphics.frame_count%60)*@@bobFrameSpeed).floor
      @pattern = p if !@lock_pattern
      @pattern_surf = p
      @bob_height = (p>=2) ? 2 : 0
    else
      @bob_height = 0
      super
    end
  end
end


=begin
class Game_Character
  alias update_old2 update

  def update
    if self.is_a?(Game_Event)
      if @dependentEvents
        for i in 0...@dependentEvents.length
          if @dependentEvents[i][0]==$game_map.map_id &&
             @dependentEvents[i][1]==self.id
            self.move_speed_real = $game_player.move_speed_real
            break
          end
        end
      end
    end
    update_old2
  end
end
=end
