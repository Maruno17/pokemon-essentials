module PBDebug
  @@log = []

  def self.logonerr
    begin
      yield
    rescue
      PBDebug.log("")
      PBDebug.log("**Exception: #{$!.message}")
      PBDebug.log($!.backtrace.inspect.to_s)
      PBDebug.log("")
      pbPrintException($!)   # if $INTERNAL
      PBDebug.flush
    end
  end

  def self.flush
    if $DEBUG && $INTERNAL && @@log.length > 0
      File.open("Data/debuglog.txt", "a+b") { |f| f.write(@@log.to_s) }
    end
    @@log.clear
  end

  def self.log(msg)
    if $DEBUG && $INTERNAL
      @@log.push("#{msg}\r\n")
      PBDebug.flush   # if @@log.length > 1024
    end
  end

  def self.dump(msg)
    if $DEBUG && $INTERNAL
      File.open("Data/dumplog.txt", "a+b") { |f| f.write("#{msg}\r\n") }
    end
  end
end
