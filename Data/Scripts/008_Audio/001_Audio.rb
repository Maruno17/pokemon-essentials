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
    @context=init.call
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
    @waitingBGM = value
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
  volume=0 if !getPlayMusic
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

def Audio_bgm_stop
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
  volume=0 if !getPlayMusic
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

def Audio_me_stop
  AudioState::AudioContextStop.call(AudioState.meContext)
end

def Audio_bgs_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound
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

def Audio_bgs_stop
  AudioState::AudioContextStop.call(AudioState.bgsContext)
end

def Audio_se_play(name, volume, pitch, position = 0)
  volume=0 if !getPlaySound
  begin
    filename = canonicalize(RTP.getAudioPath(name))
    AudioState::AudioContextSEPlay.call(AudioState.seContext,filename,
       volume,pitch,position)
  rescue
    p $!.message,$!.backtrace
  end
end

def Audio_se_stop
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
      Audio_bgm_stop
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
      Audio_me_stop
    end

    def self.bgs_play(name,volume=80,pitch=100)
      Audio_bgs_play(name,volume,pitch,0)
    end

    def self.bgs_fade(ms)
      Audio_bgs_fade(ms)
    end

    def self.bgs_stop
      Audio_bgs_stop
    end

=begin
    def self.se_play(name,volume=80,pitch=100)
      Audio_se_play(name,volume,pitch,0)
    end

    def self.se_stop
      Audio_se_stop
    end
=end
  end
end   # safeExists?("audio.dll")



#===============================================================================
# Methods that determine the duration of an audio file.
#===============================================================================
def getOggPage(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  dw = fgetdw.call(file)
  return nil if dw != 0x5367674F
  header = file.read(22)
  bodysize = 0
  hdrbodysize = (file.read(1)[0] rescue 0)
  hdrbodysize.times do
    bodysize += (file.read(1)[0] rescue 0)
  end
  ret = [header, file.pos, bodysize, file.pos + bodysize]
  return ret
end

# internal function
def oggfiletime(file)
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  fgetw = proc { |file|
    (file.eof? ? 0 : (file.read(2).unpack("v")[0] || 0))
  }
  pages = []
  page = nil
  loop do
    page = getOggPage(file)
    break if !page
    pages.push(page)
    file.pos = page[3]
  end
  return -1 if pages.length == 0
  curserial = nil
  i = -1
  pcmlengths = []
  rates = []
  for page in pages
    header = page[0]
    serial = header[10, 4].unpack("V")
    frame = header[2, 8].unpack("C*")
    frameno = frame[7]
    frameno = (frameno << 8) | frame[6]
    frameno = (frameno << 8) | frame[5]
    frameno = (frameno << 8) | frame[4]
    frameno = (frameno << 8) | frame[3]
    frameno = (frameno << 8) | frame[2]
    frameno = (frameno << 8) | frame[1]
    frameno = (frameno << 8) | frame[0]
    if serial != curserial
      curserial = serial
      file.pos = page[1]
      packtype = (file.read(1)[0] rescue 0)
      string = file.read(6)
      return -1 if string != "vorbis"
      return -1 if packtype != 1
      i += 1
      version = fgetdw.call(file)
      return -1 if version != 0
      rates[i] = fgetdw.call(file)
    end
    pcmlengths[i] = frameno
  end
  ret = 0.0
  for i in 0...pcmlengths.length
    ret += pcmlengths[i].to_f / rates[i]
  end
  return ret
end

# Gets the length of an audio file in seconds. Supports WAV, MP3, and OGG files.
def getPlayTime(filename)
  if safeExists?(filename)
    return [getPlayTime2(filename), 0].max
  elsif safeExists?(filename + ".wav")
    return [getPlayTime2(filename + ".wav"), 0].max
  elsif safeExists?(filename + ".mp3")
    return [getPlayTime2(filename + ".mp3"), 0].max
  elsif safeExists?(filename + ".ogg")
    return [getPlayTime2(filename + ".ogg"), 0].max
  end
  return 0
end

def getPlayTime2(filename)
  return -1 if !safeExists?(filename)
  time = -1
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  fgetw = proc { |file|
    (file.eof? ? 0 : (file.read(2).unpack("v")[0] || 0))
  }
  File.open(filename, "rb") { |file|
    file.pos = 0
    fdw = fgetdw.call(file)
    if fdw == 0x46464952   # "RIFF"
      filesize = fgetdw.call(file)
      wave = fgetdw.call(file)
      return -1 if wave != 0x45564157   # "WAVE"
      fmt = fgetdw.call(file)
      return -1 if fmt != 0x20746d66   # "fmt "
      fmtsize = fgetdw.call(file)
      format = fgetw.call(file)
      channels = fgetw.call(file)
      rate = fgetdw.call(file)
      bytessec = fgetdw.call(file)
      return -1 if bytessec == 0
      bytessample = fgetw.call(file)
      bitssample = fgetw.call(file)
      data = fgetdw.call(file)
      return -1 if data != 0x61746164   # "data"
      datasize = fgetdw.call(file)
      time = (datasize*1.0)/bytessec
      return time
    elsif fdw == 0x5367674F   # "OggS"
      file.pos = 0
      time = oggfiletime(file)
      return time
    end
    file.pos = 0
    # Find the length of an MP3 file
    while true
      rstr = ""
      ateof = false
      while !file.eof?
        if (file.read(1)[0] rescue 0) == 0xFF
          begin
            rstr = file.read(3)
          rescue
            ateof = true
          end
          break
        end
      end
      break if ateof || !rstr || rstr.length != 3
      if rstr[0] == 0xFB
        t = rstr[1] >> 4
        next if t == 0 || t == 15
        freqs = [44100, 22050, 11025, 48000]
        bitrates = [32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
        bitrate = bitrates[t]
        t = (rstr[1] >> 2) & 3
        freq = freqs[t]
        t = (rstr[1] >> 1) & 1
        filesize = FileTest.size(filename)
        frameLength = ((144000 * bitrate) / freq) + t
        numFrames = filesize / (frameLength + 4)
        time = (numFrames * 1152.0 / freq)
        break
      end
    end
  }
  return time
end
