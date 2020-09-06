class Thread
  def Thread.exclusive
    old_critical = Thread.critical
    begin
      Thread.critical = true
      return yield
    ensure
      Thread.critical = old_critical
    end
  end
end



def getPlayMusic
  return MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
     "SOFTWARE\\Enterbrain\\RGSS","PlayMusic",true)
end

def getPlaySound
  return MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
     "SOFTWARE\\Enterbrain\\RGSS","PlaySound",true)
end



class AudioContext
  attr_reader :context

  def initialize
    init = Win32API.new("audio.dll", "AudioContextInitialize", '', 'l')
    @context=init.call()
  end

  def dispose
    if @context!=0
      init = Win32API.new("audio.dll", "AudioContextFree", 'l', '')
      init.call(context)
      @context=0
    end
  end
end



#####################################
# Needed because RGSS doesn't call at_exit procs on exit
# Exit is not called when game is reset (using F12)
$AtExitProcs=[] if !$AtExitProcs

def exit(code=0)
  for p in $AtExitProcs
    p.call
  end
  raise SystemExit.new(code)
end

def at_exit(&block)
  $AtExitProcs.push(Proc.new(&block))
end

#####################################
# Works around a problem with FileTest.exist
# if directory contains accent marks
if !defined?(safeExists?)
  def safeExists?(f)
    ret=false
    File.open(f,"rb") { ret=true } rescue nil
    return ret
  end
end



module AudioState
  w32_LL = Win32API.new("kernel32.dll", "LoadLibrary", 'p', 'l') # :nodoc:
  w32_FL = Win32API.new("kernel32.dll", "FreeLibrary", 'p', 'l')# :nodoc:

  if safeExists?("audio.dll")
    @handle = w32_LL.call("audio.dll")
    at_exit { w32_FL.call(@handle) }
    AudioContextIsActive    = Win32API.new("audio.dll","AudioContextIsActive","l","l")# :nodoc:
    AudioContextPlay        = Win32API.new("audio.dll","AudioContextPlay","lpllll","")# :nodoc:
    AudioContextStop        = Win32API.new("audio.dll","AudioContextStop","l","")# :nodoc:
    AudioContextFadeOut     = Win32API.new("audio.dll","AudioContextFadeOut","ll","")# :nodoc:
    AudioContextGetPosition = Win32API.new("audio.dll","AudioContextGetPosition","l","l")# :nodoc:
    AudioContextFadeIn      = Win32API.new("audio.dll","AudioContextFadeIn","ll","")# :nodoc:
    AudioContextSetVolume   = Win32API.new("audio.dll","AudioContextSetVolume","ll","")# :nodoc:
    AudioContextSEPlay      = Win32API.new("audio.dll","AudioContextSEPlay","lplll","")# :nodoc:
    if !@MEContext
      @MEContext=AudioContext.new
      at_exit { @MEContext.dispose }
    end
    if !@BGMContext
      @BGMContext=AudioContext.new
      at_exit { @BGMContext.dispose }
    end
    if !@BGSContext
      @BGSContext=AudioContext.new
      at_exit { @BGSContext.dispose }
    end
    if !@SEContext
      @SEContext=AudioContext.new
      at_exit { @SEContext.dispose }
    end
  else
    AudioContextIsActive    = nil # :nodoc:
    AudioContextPlay        = nil # :nodoc:
    AudioContextStop        = nil # :nodoc:
    AudioContextFadeOut     = nil # :nodoc:
    AudioContextGetPosition = nil # :nodoc:
    AudioContextFadeIn      = nil # :nodoc:
    AudioContextSetVolume   = nil # :nodoc:
    AudioContextSEPlay      = nil # :nodoc:
  end

  @channel   = nil
  @bgm       = nil
  @name      = ""
  @pitch     = 100
  @bgmVolume = 100.0
  @meVolume  = 100.0
  @bgsVolume = 100.0
  @seVolume  = 100.0

  def self.setWaitingBGM(bgm,volume,pitch,position)
    @waitingBGM=[bgm,volume,pitch,position]
  end

  def self.bgmActive?
    return !@BGMContext ? false : (AudioContextIsActive.call(@BGMContext.context)!=0)
  end

  def self.meActive?
    return !@MEContext ? false : (AudioContextIsActive.call(@MEContext.context)!=0)
  end

  def self.waitingBGM; @waitingBGM; end
  def self.context; @BGMContext ? @BGMContext.context : nil; end
  def self.meContext; @MEContext ? @MEContext.context : nil; end
  def self.bgsContext; @BGSContext ? @BGSContext.context : nil; end
  def self.seContext; @SEContext ? @SEContext.context : nil; end
  def self.system; @system; end
  def self.bgm; @bgm; end
  def self.name; @name; end
  def self.pitch; @pitch; end
  def self.volume; @volume; end

  def self.waitingBGM=(value);
    Thread.exclusive { @waitingBGM=value; }
  end

  def self.volume=(value); @volume=value; end
  def self.bgm=(value); @bgm=value; end
  def self.name=(value); @name=value; end
  def self.pitch=(value); @pitch=value; end
end



def Audio_bgm_playing?
  AudioState.channel!=nil
end

def Audio_bgm_name
  AudioState.name
end

def Audio_bgm_pitch
  AudioState.pitch
end

def Audio_bgm_play(name, volume, pitch, position = 0)
  volume=0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.meActive?
      AudioState.setWaitingBGM(filename,volume,pitch,position)
      return
    end
    AudioState::AudioContextPlay.call(AudioState.context,filename,volume,pitch,position,1)
    AudioState.name=filename
    AudioState.volume=volume
    AudioState.pitch=pitch
  rescue Hangup
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_bgm_fadein(ms)
  AudioState::AudioContextFadeIn.call(AudioState.context,ms.to_i)
end

def Audio_bgm_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.context,ms.to_i)
end

def Audio_bgm_stop()
  begin
    AudioState::AudioContextStop.call(AudioState.context)
    AudioState.waitingBGM=nil
    AudioState.name = ""
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_bgm_get_position
  return AudioState::AudioContextGetPosition.call(AudioState.context)
end

def Audio_bgm_get_volume
  return 0 if !AudioState.bgmActive?
  return AudioState.volume
end

def Audio_bgm_set_volume(volume)
  return if !AudioState.bgmActive?
  AudioState.volume = volume * 1.0
  AudioState::AudioContextSetVolume.call(AudioState.context,volume.to_i)
end

def Audio_me_play(name, volume, pitch, position = 0)
  volume=0 if !getPlayMusic()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    if AudioState.bgmActive?
      bgmPosition=Audio_bgm_get_position
      AudioState.setWaitingBGM(
        AudioState.name,
        AudioState.volume,
        AudioState.pitch,
        bgmPosition
      )
      AudioState::AudioContextStop.call(AudioState.context)
    end
    AudioState::AudioContextPlay.call(AudioState.meContext,filename,
       volume,pitch,position,0)
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_me_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.meContext,ms)
end

def Audio_me_stop()
  AudioState::AudioContextStop.call(AudioState.meContext)
end

def Audio_bgs_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextPlay.call(AudioState.bgsContext,filename,
       volume,pitch,position,0)
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_bgs_fade(ms)
  AudioState::AudioContextFadeOut.call(AudioState.bgsContext,ms)
end

def Audio_bgs_stop()
  AudioState::AudioContextStop.call(AudioState.bgsContext)
end

def Audio_se_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound()
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextSEPlay.call(AudioState.seContext,filename,
       volume,pitch,position)
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_se_stop()
  AudioState::AudioContextStop.call(AudioState.seContext)
end



####################################################
if safeExists?("audio.dll")
  module Graphics
    if !defined?(audiomodule_update)
      class << self
        alias audiomodule_update update
      end
    end

    def self.update
      Audio.update
      audiomodule_update
    end
  end



  module Audio
    @@musicstate = nil
    @@soundstate = nil

    def self.update
      return if Graphics.frame_count%10!=0
      if AudioState.waitingBGM && !AudioState.meActive?
        waitbgm=AudioState.waitingBGM
        AudioState.waitingBGM=nil
        bgm_play(waitbgm[0],waitbgm[1],waitbgm[2],waitbgm[3])
      end
    end

    def self.bgm_play(name,volume=80,pitch=100,position=nil)
      begin
        if position==nil || position==0
          Audio_bgm_play(name,volume,pitch,0)
        else
          Audio_bgm_play(name,volume,pitch,position)
          Audio_bgm_fadein(500)
        end
      rescue Hangup
        bgm_play(name,volume,pitch,position)
      end
    end

    def self.bgm_fade(ms)
      Audio_bgm_fade(ms)
    end

    def self.bgm_stop
      Audio_bgm_stop()
    end

    def self.bgm_position
      return Audio_bgm_get_position
    end

    def self.me_play(name,volume=80,pitch=100)
      Audio_me_play(name,volume,pitch,0)
    end

    def self.me_fade(ms)
      Audio_me_fade(ms)
    end

    def self.me_stop
      Audio_me_stop()
    end

    def self.bgs_play(name,volume=80,pitch=100)
      Audio_bgs_play(name,volume,pitch,0)
    end

    def self.bgs_fade(ms)
      Audio_bgs_fade(ms)
    end

    def self.bgs_stop
      Audio_bgs_stop()
    end

=begin
    def self.se_play(name,volume=80,pitch=100)
      Audio_se_play(name,volume,pitch,0)
    end

    def self.se_stop
      Audio_se_stop()
    end
=end
  end
end   # safeExists?("audio.dll")
