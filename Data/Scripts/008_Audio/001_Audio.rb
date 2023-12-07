#===============================================================================
# Methods that determine the duration of an audio file.
#===============================================================================
def getOggPage(file)
  fgetdw = proc { |f|
    (f.eof? ? 0 : (f.read(4).unpack("V")[0] || 0))
  }
  dw = fgetdw.call(file)
  return nil if dw != 0x5367674F
  header = file.read(22)
  bodysize = 0
  hdrbodysize = (file.read(1)[0].ord rescue 0)
  hdrbodysize.times do
    bodysize += (file.read(1)[0].ord rescue 0)
  end
  ret = [header, file.pos, bodysize, file.pos + bodysize]
  return ret
end

# internal function
def oggfiletime(file)
  fgetdw = proc { |f|
    (f.eof? ? 0 : (f.read(4).unpack("V")[0] || 0))
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
  pages.each do |pg|
    header = pg[0]
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
      file.pos = pg[1]
      packtype = (file.read(1)[0].ord rescue 0)
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
  pcmlengths.each_with_index { |length, j| ret += length.to_f / rates[j] }
  return ret * 256.0
end

# Gets the length of an audio file in seconds. Supports WAV, MP3, and OGG files.
def getPlayTime(filename)
  if FileTest.exist?(filename)
    return [getPlayTime2(filename), 0].max
  elsif FileTest.exist?(filename + ".wav")
    return [getPlayTime2(filename + ".wav"), 0].max
  elsif FileTest.exist?(filename + ".mp3")
    return [getPlayTime2(filename + ".mp3"), 0].max
  elsif FileTest.exist?(filename + ".ogg")
    return [getPlayTime2(filename + ".ogg"), 0].max
  end
  return 0
end

def getPlayTime2(filename)
  return -1 if !FileTest.exist?(filename)
  time = -1
  fgetdw = proc { |file|
    (file.eof? ? 0 : (file.read(4).unpack("V")[0] || 0))
  }
  fgetw = proc { |file|
    (file.eof? ? 0 : (file.read(2).unpack("v")[0] || 0))
  }
  File.open(filename, "rb") do |file|
    file.pos = 0
    fdw = fgetdw.call(file)
    case fdw
    when 0x46464952   # "RIFF"
      filesize = fgetdw.call(file)
      wave = fgetdw.call(file)
      return -1 if wave != 0x45564157   # "WAVE"
      fmt = fgetdw.call(file)
      return -1 if fmt != 0x20746d66   # "fmt "
      fgetdw.call(file)   # fmtsize
      fgetw.call(file)   # format
      fgetw.call(file)   # channels
      fgetdw.call(file)   # rate
      bytessec = fgetdw.call(file)
      return -1 if bytessec == 0
      fgetw.call(file)   # bytessample
      fgetw.call(file)   # bitssample
      data = fgetdw.call(file)
      return -1 if data != 0x61746164   # "data"
      datasize = fgetdw.call(file)
      time = datasize.to_f / bytessec
      return time
    when 0x5367674F   # "OggS"
      file.pos = 0
      time = oggfiletime(file)
      return time
    end
    file.pos = 0
    # Find the length of an MP3 file
    loop do
      rstr = ""
      ateof = false
      until file.eof?
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
        next if [0, 15].include?(t)
        freqs = [44_100, 22_050, 11_025, 48_000]
        bitrates = [32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
        bitrate = bitrates[t]
        t = (rstr[1] >> 2) & 3
        freq = freqs[t]
        t = (rstr[1] >> 1) & 1
        filesize = FileTest.size(filename)
        frameLength = ((144_000 * bitrate) / freq) + t
        numFrames = filesize / (frameLength + 4)
        time = (numFrames * 1152.0 / freq)
        break
      end
    end
  end
  return time
end
