#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles data surrounding the system. Backround music, etc.
#  is managed here as well. Refer to "$game_system" for the instance of
#  this class.
#==============================================================================
class Game_System
  attr_reader   :map_interpreter          # map event interpreter
  attr_reader   :battle_interpreter       # battle event interpreter
  attr_accessor :timer                    # timer
  attr_accessor :timer_working            # timer working flag
  attr_accessor :save_disabled            # save forbidden
  attr_accessor :menu_disabled            # menu forbidden
  attr_accessor :encounter_disabled       # encounter forbidden
  attr_accessor :message_position         # text option: positioning
  attr_accessor :message_frame            # text option: window frame
  attr_accessor :save_count               # save count
  attr_accessor :magic_number             # magic number
  attr_accessor :autoscroll_x_speed
  attr_accessor :autoscroll_y_speed
  attr_accessor :bgm_position

  def initialize
    @map_interpreter    = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer              = 0
    @timer_working      = false
    @save_disabled      = false
    @menu_disabled      = false
    @encounter_disabled = false
    @message_position   = 2
    @message_frame      = 0
    @save_count         = 0
    @magic_number       = 0
    @autoscroll_x_speed = 0
    @autoscroll_y_speed = 0
    @bgm_position       = 0
    @bgs_position       = 0
  end

################################################################################

  def bgm_play(bgm)
    old_pos = @bgm_position
    @bgm_position = 0
    bgm_play_internal(bgm, 0)
    @bgm_position = old_pos
  end

  def bgm_play_internal2(name, volume, pitch, position) # :nodoc:
    vol = volume
    vol *= $PokemonSystem.bgmvolume / 100.0
    vol = vol.to_i
    begin
      Audio.bgm_play(name, vol, pitch, position)
    rescue ArgumentError
      Audio.bgm_play(name, vol, pitch)
    end
  end

  def bgm_play_internal(bgm, position) # :nodoc:
    @bgm_position = position if !@bgm_paused
    @playing_bgm = bgm&.clone
    if bgm && bgm.name != ""
      if !@defaultBGM && FileTest.audio_exist?("Audio/BGM/" + bgm.name)
        bgm_play_internal2("Audio/BGM/" + bgm.name, bgm.volume, bgm.pitch, @bgm_position)
      end
    else
      @bgm_position = position if !@bgm_paused
      @playing_bgm = nil
      Audio.bgm_stop if !@defaultBGM
    end
    if @defaultBGM
      bgm_play_internal2("Audio/BGM/" + @defaultBGM.name,
                         @defaultBGM.volume, @defaultBGM.pitch, @bgm_position)
    end
    Graphics.frame_reset
  end

  def bgm_pause(fadetime = 0.0) # :nodoc:
    pos = Audio.bgm_pos rescue 0
    self.bgm_fade(fadetime) if fadetime > 0.0
    @bgm_position = pos
    @bgm_paused   = true
  end

  def bgm_unpause  # :nodoc:
    @bgm_position = 0
    @bgm_paused   = false
  end

  def bgm_resume(bgm) # :nodoc:
    if @bgm_paused
      self.bgm_play_internal(bgm, @bgm_position)
      @bgm_position = 0
      @bgm_paused   = false
    end
  end

  def bgm_stop # :nodoc:
    @bgm_position = 0 if !@bgm_paused
    @playing_bgm  = nil
    Audio.bgm_stop if !@defaultBGM
  end

  def bgm_fade(time) # :nodoc:
    @bgm_position = 0 if !@bgm_paused
    @playing_bgm = nil
    Audio.bgm_fade((time * 1000).floor) if !@defaultBGM
  end

  def playing_bgm
    return @playing_bgm
  end

  # Saves the currently playing background music for later playback.
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end

  # Plays the currently memorized background music
  def bgm_restore
    bgm_play(@memorized_bgm)
  end

  # Returns an RPG::AudioFile object for the currently playing background music
  def getPlayingBGM
    return (@playing_bgm) ? @playing_bgm.clone : nil
  end

  def setDefaultBGM(bgm, volume = 80, pitch = 100)
    bgm = RPG::AudioFile.new(bgm, volume, pitch) if bgm.is_a?(String)
    @defaultBGM = nil
    if bgm && bgm.name != ""
      self.bgm_play(bgm)
      @defaultBGM = bgm.clone
    else
      self.bgm_play(@playing_bgm)
    end
  end

################################################################################

  def me_play(me)
    me = RPG::AudioFile.new(me) if me.is_a?(String)
    if me && me.name != ""
      if FileTest.audio_exist?("Audio/ME/" + me.name)
        vol = me.volume
        vol *= $PokemonSystem.bgmvolume / 100.0
        vol = vol.to_i
        Audio.me_play("Audio/ME/" + me.name, vol, me.pitch)
      end
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end

################################################################################

  def bgs_play(bgs)
    @playing_bgs = (bgs.nil?) ? nil : bgs.clone
    if bgs && bgs.name != ""
      if FileTest.audio_exist?("Audio/BGS/" + bgs.name)
        vol = bgs.volume
        vol *= $PokemonSystem.sevolume / 100.0
        vol = vol.to_i
        Audio.bgs_play("Audio/BGS/" + bgs.name, vol, bgs.pitch)
      end
    else
      @bgs_position = 0
      @playing_bgs  = nil
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end

  def bgs_pause(fadetime = 0.0) # :nodoc:
    if fadetime > 0.0
      self.bgs_fade(fadetime)
    else
      self.bgs_stop
    end
    @bgs_paused = true
  end

  def bgs_unpause  # :nodoc:
    @bgs_paused = false
  end

  def bgs_resume(bgs) # :nodoc:
    if @bgs_paused
      self.bgs_play(bgs)
      @bgs_paused = false
    end
  end

  def bgs_stop
    @bgs_position = 0
    @playing_bgs  = nil
    Audio.bgs_stop
  end

  def bgs_fade(time)
    @bgs_position = 0
    @playing_bgs  = nil
    Audio.bgs_fade((time * 1000).floor)
  end

  def playing_bgs
    return @playing_bgs
  end

  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end

  def bgs_restore
    bgs_play(@memorized_bgs)
  end

  def getPlayingBGS
    return (@playing_bgs) ? @playing_bgs.clone : nil
  end

################################################################################

  def se_play(se)
    se = RPG::AudioFile.new(se) if se.is_a?(String)
    if se && se.name != "" && FileTest.audio_exist?("Audio/SE/" + se.name)
      vol = se.volume
      vol *= $PokemonSystem.sevolume / 100.0
      vol = vol.to_i
      Audio.se_play("Audio/SE/" + se.name, vol, se.pitch)
    end
  end

  def se_stop
    Audio.se_stop
  end

################################################################################

  def battle_bgm
    return (@battle_bgm) ? @battle_bgm : $data_system.battle_bgm
  end

  attr_writer :battle_bgm

  def battle_end_me
    return (@battle_end_me) ? @battle_end_me : $data_system.battle_end_me
  end

  attr_writer :battle_end_me

################################################################################

  def windowskin_name
    if @windowskin_name.nil?
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end

  attr_writer :windowskin_name

  def update
    @timer -= 1 if @timer_working && @timer > 0
    if Input.trigger?(Input::SPECIAL) && pbCurrentEventCommentInput(1, "Cut Scene")
      event = @map_interpreter.get_self
      @map_interpreter.pbSetSelfSwitch(event.id, "A", true)
      @map_interpreter.command_end
      event.start
    end
  end
end
