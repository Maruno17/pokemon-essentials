class Win32API
  @@RGSSWINDOW = nil
  @@GetCurrentThreadId       = Win32API.new('kernel32', 'GetCurrentThreadId', '%w()', 'l')
  @@GetWindowThreadProcessId = Win32API.new('user32', 'GetWindowThreadProcessId', '%w(l p)', 'l')
  @@FindWindowEx             = Win32API.new('user32', 'FindWindowEx', '%w(l l p p)', 'l')

  # Added by Peter O. as a more reliable way to get the RGSS window
  def Win32API.pbFindRgssWindow
    return @@RGSSWINDOW if @@RGSSWINDOW
    processid = [0].pack('l')
    threadid = @@GetCurrentThreadId.call
    nextwindow = 0
    loop do
      nextwindow = @@FindWindowEx.call(0,nextwindow,"RGSS Player",0)
      if nextwindow!=0
        wndthreadid = @@GetWindowThreadProcessId.call(nextwindow,processid)
        if wndthreadid==threadid
          @@RGSSWINDOW = nextwindow
          return @@RGSSWINDOW
        end
      end
      break if nextwindow==0
    end
    raise "Can't find RGSS player window"
  end

  # Returns the size of the window. Used in detecting the mouse position.
  def Win32API.client_size
    hWnd = pbFindRgssWindow
    rect = [0,0,0,0].pack('l4')
    Win32API.new('user32','GetClientRect',%w(l p),'i').call(hWnd,rect)
    width,height = rect.unpack('l4')[2..3]
    return width,height
  end
end



# Well done for finding this place.
# DO NOT EDIT THESE
ESSENTIALS_VERSION = "18.1.dev"
ERROR_TEXT = ""
