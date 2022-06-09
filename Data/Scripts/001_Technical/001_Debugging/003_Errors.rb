#===============================================================================
# Exceptions and critical code
#===============================================================================
class Reset < Exception
end

def pbGetExceptionMessage(e,_script="")
  emessage = e.message.dup
  emessage.force_encoding(Encoding::UTF_8)
  if e.is_a?(Hangup)
    emessage = "The script is taking too long. The game will restart."
  elsif e.is_a?(Errno::ENOENT)
    filename = emessage.sub("No such file or directory - ", "")
    emessage = "File #{filename} not found."
  end
  emessage.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
  return emessage
end

def pbPrintException(e)
  emessage = ""
  if $EVENTHANGUPMSG && $EVENTHANGUPMSG!=""
    emessage = $EVENTHANGUPMSG   # Message with map/event ID generated elsewhere
    $EVENTHANGUPMSG = nil
  else
    emessage = pbGetExceptionMessage(e)
  end
  # begin message formatting
  message = "[Infinite Fusion version #{Settings::GAME_VERSION_NUMBER}]\r\n"
  if $game_switches
    message += "Randomized trainers, " if $game_switches[SWITCH_RANDOM_TRAINERS]
    message += "Randomized gym trainers, " if $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY]
    message += "Randomized wild Pokemon (global), " if $game_switches[SWITCH_WILD_RANDOM_GLOBAL]
    message += "Randomized wild Pokemon (area), " if $game_switches[RandomizerWildPokemonOptionsScene::RANDOM_WILD_AREA]
    message += "All fused, " if $game_switches[SWITCH_RANDOM_TRAINERS]
    message += "Randomized trainers, " if $game_switches[RandomizerWildPokemonOptionsScene::REGULAR_TO_FUSIONS]
  end
    message += "#{Essentials::ERROR_TEXT}\r\n"   # For third party scripts to add to
  message += "Exception: #{e.class}\r\n"
  message += "Message: #{emessage}\r\n"
  # show last 10/25 lines of backtrace
  message += "\r\nBacktrace:\r\n"
  btrace = ""
  if e.backtrace
    maxlength = ($INTERNAL) ? 25 : 10
    e.backtrace[0, maxlength].each { |i| btrace += "#{i}\r\n" }
  end
  btrace.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
  message += btrace
  # output to log
  errorlog = "errorlog.txt"
  errorlog = RTP.getSaveFileName("errorlog.txt") if (Object.const_defined?(:RTP) rescue false)
  File.open(errorlog, "ab") do |f|
    f.write("\r\n=================\r\n\r\n[#{Time.now}]\r\n")
    f.write(message)
  end
  # format/censor the error log directory
  errorlogline = errorlog.gsub("/", "\\")
  errorlogline.sub!(Dir.pwd + "\\", "")
  errorlogline.sub!(pbGetUserName, "USERNAME")
  errorlogline = "\r\n" + errorlogline if errorlogline.length > 20
  # output message
  print("#{message}\r\nThis exception was logged in #{errorlogline}.\r\nHold Ctrl when closing this message to copy it to the clipboard.")
  # Give a ~500ms coyote time to start holding Control
  t = System.delta
  until (System.delta - t) >= 500000
    Input.update
    if Input.press?(Input::CTRL)
      Input.clipboard = message
      break
    end
  end
end

def pbCriticalCode
  ret = 0
  begin
    yield
    ret = 1
  rescue Exception
    e = $!
    if e.is_a?(Reset) || e.is_a?(SystemExit)
      raise
    else
      pbPrintException(e)
      if e.is_a?(Hangup)
        ret = 2
        raise Reset.new
      end
    end
  end
  return ret
end
