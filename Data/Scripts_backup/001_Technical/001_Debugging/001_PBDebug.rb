module PBDebug
  @@log = []

  def self.logonerr
    begin
      yield
    rescue
      PBDebug.log("")
      PBDebug.log("**Exception: #{$!.message}")
      PBDebug.log("#{$!.backtrace.inspect}")
      PBDebug.log("")
#      if $INTERNAL
        pbPrintException($!)
#      end
      PBDebug.flush
    end
  end

  def self.flush
    if $DEBUG && $INTERNAL && @@log.length>0
      File.open("Data/debuglog.txt", "a+b") { |f| f.write("#{@@log}") }
    end
    @@log.clear
  end

  def self.log(msg)
    if $DEBUG && $INTERNAL
      @@log.push("#{msg}\r\n")
#      if @@log.length>1024
        PBDebug.flush
#      end
    end
  end

  def self.dump(msg)
    if $DEBUG && $INTERNAL
      File.open("Data/dumplog.txt", "a+b") { |f| f.write("#{msg}\r\n") }
    end
  end
end
