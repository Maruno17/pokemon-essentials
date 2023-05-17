#===============================================================================
# Exceptions and critical code
#===============================================================================
class Reset < Exception
end

class EventScriptError < Exception
  attr_accessor :event_message

  def initialize(message)
    super(nil)
    @event_message = message
  end
end

def pbGetExceptionMessage(e, _script = "")
  return e.event_message.dup if e.is_a?(EventScriptError)   # Message with map/event ID generated elsewhere
  emessage = e.message.dup
  emessage.force_encoding(Encoding::UTF_8)
  case e
  when Hangup
    emessage = "The script is taking too long. The game will restart."
  when Errno::ENOENT
    filename = emessage.sub("No such file or directory - ", "")
    emessage = "File #{filename} not found."
  end
  emessage.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
  return emessage
end

def pbPrintException(e)
  emessage = pbGetExceptionMessage(e)
  # begin message formatting
  message = "[Pokémon Essentials version #{Essentials::VERSION}]\r\n"
  message += "#{Essentials::ERROR_TEXT}\r\n"   # For third party scripts to add to
  if !e.is_a?(EventScriptError)
    message += "Exception: #{e.class}\r\n"
    message += "Message: "
  end
  message += emessage
  # show last 10/25 lines of backtrace
  if !e.is_a?(EventScriptError)
    message += "\r\n\r\nBacktrace:\r\n"
    backtrace_text = ""
    if e.backtrace
      maxlength = ($INTERNAL) ? 25 : 10
      e.backtrace[0, maxlength].each { |i| backtrace_text += "#{i}\r\n" }
    end
    backtrace_text.gsub!(/Section(\d+)/) { $RGSS_SCRIPTS[$1.to_i][1] } rescue nil
    message += backtrace_text
  end
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
  t = System.uptime
  until System.uptime - t >= 0.5
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
