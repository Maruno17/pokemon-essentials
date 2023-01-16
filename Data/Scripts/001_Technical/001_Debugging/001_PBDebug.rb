module PBDebug
  @@log = []

  def self.logonerr
    begin
      yield
    rescue
      PBDebug.log("")
      PBDebug.log("**Exception: #{$!.message}")
      backtrace = ""
      $!.backtrace.each { |line| backtrace += line + "\r\n" }
      PBDebug.log(backtrace)
      PBDebug.log("")
      pbPrintException($!)   # if $INTERNAL
      PBDebug.flush
    end
  end

  def self.flush
    if $DEBUG && $INTERNAL && @@log.length > 0
      File.open("Data/debuglog.txt", "a+b") { |f| f.write(@@log.join) }
    end
    @@log.clear
  end

  def self.log(msg)
    if $DEBUG && $INTERNAL
      echoln msg.gsub("%", "%%")
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.log_header(msg)
    if $DEBUG && $INTERNAL
      echoln Console.markup_style(msg.gsub("%", "%%"), text: :light_purple)
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.log_message(msg)
    if $DEBUG && $INTERNAL
      msg = "\"" + msg + "\""
      echoln Console.markup_style(msg.gsub("%", "%%"), text: :dark_gray)
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.log_ai(msg)
    if $DEBUG && $INTERNAL
      msg = "[AI] " + msg
      echoln msg.gsub("%", "%%")
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.log_score_change(amt, msg)
    return if amt == 0
    if $DEBUG && $INTERNAL
      sign = (amt > 0) ? "+" : "-"
      amt_text = sprintf("%3d", amt.abs)
      msg = "     #{sign}#{amt_text}: #{msg}"
      echoln msg.gsub("%", "%%")
      @@log.push(msg + "\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.dump(msg)
    if $DEBUG && $INTERNAL
      File.open("Data/dumplog.txt", "a+b") { |f| f.write("#{msg}\r\n") }
    end
  end
end
