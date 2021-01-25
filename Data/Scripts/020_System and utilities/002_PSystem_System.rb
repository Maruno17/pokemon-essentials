# Loads data from a file "safely", similar to load_data. If an encrypted archive
# exists, the real file is deleted to ensure that the file is loaded from the
# encrypted archive.
def pbSafeLoad(file)
  if (safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a")) && safeExists?(file)
    File.delete(file) rescue nil
  end
  return load_data(file)
end

def pbChooseLanguage
  commands=[]
  for lang in LANGUAGES
    commands.push(lang[0])
  end
  return pbShowCommands(nil,commands)
end

def pbScreenCapture
  t = pbGetTimeNow
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S")
  filestart = sprintf("%s.%03d", filestart, (t.to_f - t.to_i) * 1000)   # milliseconds
  capturefile = RTP.getSaveFileName(sprintf("%s.png", filestart))
  Graphics.snap_to_bitmap.save_to_png(capturefile)
  pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
end

def pbDebugF7
  if $DEBUG
    Console::setup_console
    begin
      debugBitmaps
    rescue
    end
    pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
  end
end



module Input
  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if trigger?(Input::F7)
      pbDebugF7
    end
  end
end
