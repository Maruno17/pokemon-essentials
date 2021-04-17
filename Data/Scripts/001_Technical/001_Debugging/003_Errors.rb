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
  premessage = "\r\n=================\r\n\r\n[#{Time.now}]\r\n"
  emessage = ""
  if $EVENTHANGUPMSG && $EVENTHANGUPMSG!=""
    emessage = $EVENTHANGUPMSG   # Message with map/event ID generated elsewhere
    $EVENTHANGUPMSG = nil
  else
    emessage = pbGetExceptionMessage(e)
  end
  btrace = ""
  if e.backtrace
    maxlength = ($INTERNAL) ? 25 : 10
    e.backtrace[0,maxlength].each { |i| btrace += "#{i}\r\n" }
  end
  btrace.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
  message = "[Pokémon Essentials version #{Essentials::VERSION}]\r\n"
  message += "#{Essentials::ERROR_TEXT}"   # For third party scripts to add to
  message += "Exception: #{e.class}\r\n"
  message += "Message: #{emessage}\r\n"
  message += "\r\nBacktrace:\r\n#{btrace}"
  errorlog = "errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog = RTP.getSaveFileName("errorlog.txt")
  end
  File.open(errorlog,"ab") { |f| f.write(premessage); f.write(message) }
  errorlogline = errorlog
  errorlogline.sub!(Dir.pwd + "/", "")
  errorlogline.sub!(pbGetUserName, "USERNAME")
  errorlogline = "\r\n" + errorlogline if errorlogline.length > 20
  errorlogline.gsub!("/", "\\") if System.platform[/Windows/]
  print("#{message}\r\nThis exception was logged in #{errorlogline}.\r\nHold Ctrl after closing this message to copy it to the clipboard.")
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
