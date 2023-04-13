def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]   # Of the format "XXX: ###: ###"
    file   = $1
    volume = $2.to_i
    pitch  = $3.to_i
    return RPG::AudioFile.new(file, volume, pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]             # Of the format "XXX: ###"
    file   = $1
    volume = $2.to_i
    return RPG::AudioFile.new(file, volume, 100)
  else
    return RPG::AudioFile.new(str, 100, 100)
  end
end

# Converts an object to an audio file.
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str, volume = nil, pitch = nil)
  if str.is_a?(String)
    str = pbStringToAudioFile(str)
    str.volume = volume || 100
    str.pitch  = pitch || 100
  end
  if str.is_a?(RPG::AudioFile)
    if volume || pitch
      return RPG::AudioFile.new(str.name, volume || str.volume || 100,
                                pitch || str.pitch || 100)
    else
      return str
    end
  end
  return str
end

#===============================================================================

# Plays a BGM file.
# param -- Either a string showing the filename
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGMPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.bgm_play(param)
      return
    elsif (RPG.const_defined?(:BGM) rescue false)
      b = RPG::BGM.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.bgm_play(canonicalize("Audio/BGM/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x = 0.0); pbBGMStop(x); end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system
    $game_system.bgm_stop
    return
  elsif (RPG.const_defined?(:BGM) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::BGM.fade((timeInSeconds * 1000).floor) : RPG::BGM.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.bgm_fade((timeInSeconds * 1000).floor) : Audio.bgm_stop
end

#===============================================================================

# Plays an ME file.
# param -- Either a string showing the filename
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.me_play(param)
      return
    elsif (RPG.const_defined?(:ME) rescue false)
      b = RPG::ME.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.me_play(canonicalize("Audio/ME/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x = 0.0); pbMEStop(x); end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  elsif (RPG.const_defined?(:ME) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::ME.fade((timeInSeconds * 1000).floor) : RPG::ME.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.me_fade((timeInSeconds * 1000).floor) : Audio.me_stop
end

#===============================================================================

# Plays a BGS file.
# param -- Either a string showing the filename
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b = RPG::BGS.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.bgs_play(canonicalize("Audio/BGS/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x = 0.0); pbBGSStop(x); end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system
    $game_system.bgs_play(nil)
    return
  elsif (RPG.const_defined?(:BGS) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::BGS.fade((timeInSeconds * 1000).floor) : RPG::BGS.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.bgs_fade((timeInSeconds * 1000).floor) : Audio.bgs_stop
end

#===============================================================================

# Plays an SE file.
# param -- Either a string showing the filename
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                  volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbSEPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.se_play(param)
      return
    end
    if (RPG.const_defined?(:SE) rescue false)
      b = RPG::SE.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.se_play(canonicalize("Audio/SE/" + param.name), param.volume, param.pitch)
  end
end

# Stops SE playback.
def pbSEFade(x = 0.0); pbSEStop(x); end

# Stops SE playback.
def pbSEStop(_timeInSeconds = 0.0)
  if $game_system
    $game_system.se_stop
  elsif (RPG.const_defined?(:SE) rescue false)
    RPG::SE.stop rescue nil
  else
    Audio.se_stop
  end
end

#===============================================================================

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE
  if !nil_or_empty?($data_system&.cursor_se&.name)
    pbSEPlay($data_system.cursor_se)
  elsif FileTest.audio_exist?("Audio/SE/GUI sel cursor")
    pbSEPlay("GUI sel cursor", 80)
  end
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE
  if !nil_or_empty?($data_system&.decision_se&.name)
    pbSEPlay($data_system.decision_se)
  elsif FileTest.audio_exist?("Audio/SE/GUI sel decision")
    pbSEPlay("GUI sel decision", 80)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE
  if !nil_or_empty?($data_system&.cancel_se&.name)
    pbSEPlay($data_system.cancel_se)
  elsif FileTest.audio_exist?("Audio/SE/GUI sel cancel")
    pbSEPlay("GUI sel cancel", 80)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE
  if !nil_or_empty?($data_system&.buzzer_se&.name)
    pbSEPlay($data_system.buzzer_se)
  elsif FileTest.audio_exist?("Audio/SE/GUI sel buzzer")
    pbSEPlay("GUI sel buzzer", 80)
  end
end

# Plays a sound effect that plays when the player closes a menu.
def pbPlayCloseMenuSE
  if FileTest.audio_exist?("Audio/SE/GUI menu close")
    pbSEPlay("GUI menu close", 80)
  end
end
