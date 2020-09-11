module Console
  attr_reader :bufferHandle
  GENERIC_READ                  = 0x80000000
  GENERIC_WRITE                 = 0x40000000
  FILE_SHARE_READ               = 0x00000001
  FILE_SHARE_WRITE              = 0x00000002
  CONSOLE_TEXTMODE_BUFFER       = 0x00000001

  def Console::AllocConsole
    return @apiAllocConsole.call
  end

  def Console::CreateConsoleScreenBuffer(dwDesiredAccess,dwShareMode,dwFlags)
    return @apiCreateConsoleScreenBuffer.call(dwDesiredAccess,dwShareMode,nil,dwFlags,nil)
  end

  def Console::WriteConsole(lpBuffer)
    hFile = @bufferHandle
    return if !hFile
    return @apiWriteConsole.call(hFile,lpBuffer,lpBuffer.size,0,0)
  end

  def Console::ReadConsole(lpBuffer)
    hFile = @bufferHandle
    return @apiReadConsole.call(hFile,lpBuffer,lpBuffer.size,0,0)
  end

  def Console::SetConsoleActiveScreenBuffer(hScreenBuffer)
    return @apiSetConsoleActiveScreenBuffer.call(hScreenBuffer)
  end

  def Console::SetConsoleScreenBufferSize(hScreenBuffer,x,y)
    return @apiSetConsoleScreenBufferSize.call(hScreenBuffer,[x,y].pack("vv"))
  end

  def Console::SetConsoleTitle(title)
    return @apiSetConsoleTitle.call(title)
  end

  def self.setup_console
    return unless $DEBUG
    @apiAllocConsole                 = Win32API.new("kernel32","AllocConsole","","l")
    @apiCreateConsoleScreenBuffer    = Win32API.new("kernel32","CreateConsoleScreenBuffer","nnpnp","l")
    @apiSetConsoleActiveScreenBuffer = Win32API.new("kernel32","SetConsoleActiveScreenBuffer","l","s")
    @apiWriteConsole                 = Win32API.new("kernel32","WriteConsole","lpnnn","S")
    @apiReadConsole                  = Win32API.new("kernel32","ReadConsole","lpnnn","S")
    @apiSetConsoleScreenBufferSize   = Win32API.new("kernel32","SetConsoleScreenBufferSize","lp","S")
    @apiSetConsoleTitle              = Win32API.new("kernel32","SetConsoleTitle","p","s")
    access = (GENERIC_READ | GENERIC_WRITE)
    sharemode = (FILE_SHARE_READ | FILE_SHARE_WRITE)
    @bufferHandle = CreateConsoleScreenBuffer(access,sharemode,CONSOLE_TEXTMODE_BUFFER)
    f = File.open("Game.ini")
    lines = f.readlines()
    s = lines[3]
    len = s.size
    title = (s[6,len - 7])
    SetConsoleScreenBufferSize(@bufferHandle,100,2000)
    SetConsoleTitle("Debug Console -- #{title}")
    echo "#{title} Output Window\n"
    echo "-------------------------------\n"
    echo "If you are seeing this window, you are running\n"
    echo "#{title} in Debug Mode. This means\n"
    echo "that you're either playing a Debug Version, or\n"
    echo "you are playing from within RPG Maker XP.\n"
    echo "\n"
    echo "Closing this window will close the game. If \n"
    echo "you want to get rid of this window, run the\n"
    echo "program from the Shell, or download a Release\n"
    echo "version.\n"
    echo "\n"
    echo "Gameplay will be paused while the console has\n"
    echo "focus. To resume playing, switch to the Game\n"
    echo "Window.\n"
    echo "-------------------------------\n"
    echo "Debug Output:\n"
    echo "-------------------------------\n\n"
    SetConsoleActiveScreenBuffer(@bufferHandle)
  end

  def self.readInput
    length=20
    buffer=0.chr*length
    eventsread=0.chr*4
    done=false
    input=""
    while !done
      echo("waiting for input")
      begin
        @apiReadConsole.call(@bufferHandle,buffer,1,eventsread)
        rescue Hangup
        return
      end
      offset=0
      events=eventsread.unpack("V")
      echo("got input [eventsread #{events}")
      events[0].length.times do
        keyevent=buffer[offset,20]
        keyevent=keyevent.unpack("vCvvvvV")
        if keyevent[0]==1 && keyevent[1]>0
          input+=keyevent[4].chr
          if keyevent[4].chr=="\n"
            done=true
            break
          end
        end
        offset+=20
      end
    end
    return input
  end

  def self.readInput2
    buffer=0.chr
    done=false
    input=""
    eventsread=0.chr*4
    while !done
      if ReadConsole(buffer)==0
        getlast = Win32API.new("kernel32","GetLastError","","n")
        echo(sprintf("failed (%d)\r\n",getlast.call()))
        break
      end
      events=eventsread.unpack("V")
      if events[0]>0
        echo("got input [eventsread #{events}][buffer #{buffer}]\r\n")
        key=buffer[0,events[0]]
        input+=key
        if key=="\n"
          break
        end
        Graphics.update
      end
    end
    return input
  end

  def self.get_input
    echo self.readInput2
  end
end



module Kernel
  def echo(string)
    unless $DEBUG
      return
    end
    Console::WriteConsole(string.is_a?(String) ? string : string.inspect)
  end

  def echoln(string)
    echo(string)
    echo("\r\n")
  end
end
