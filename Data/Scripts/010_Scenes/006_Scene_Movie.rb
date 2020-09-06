#===============================================================================
# ** Scene_Movie class, created by SoundSpawn, fixed by Popper.
#-------------------------------------------------------------------------------
#  Instruction
#    1) Movies must be in a new folder called "Movies" in your directory.
#    2) If you call this script from an event, e.g.
#                 Call Script: $scene = Scene_Movie.new("INTRO")
#    3) Have fun playing movies with this script!
#===============================================================================
class Scene_Movie
  def initialize(movie)
    @movie_name = RTP.getPath("Movies\\"+movie+".avi").gsub(/\//,"\\")
  end

  def main
    @temp = Win32API.pbFindRgssWindow.to_s
    movie = Win32API.new('winmm','mciSendString','%w(p,p,l,l)','V')
    movie.call("open \""+@movie_name+
       "\" alias FILE style 1073741824 parent " + @temp.to_s,0,0,0)
    @message = Win32API.new('user32','SendMessage','%w(l,l,l,l)','V')
    @detector = Win32API.new('user32','GetSystemMetrics','%w(l)','L')
    @width = @detector.call(0)
    if @width == 640
      #fullscreen
      Graphics.update
      sleep(0.1)
      Graphics.update
      sleep(0.1)
      Graphics.update
      sleep(0.1)
      #fullscreen
    end
    status = " " * 255
    movie.call("play FILE",0,0,0)
    loop do
      sleep(0.1)
      @message.call(@temp.to_i,11,0,0)
      Graphics.update
      @message.call(@temp.to_i,11,1,0)
      Input.update
      movie.call("status FILE mode",status,255,0)
      true_status = status.unpack("aaaa")
      break if true_status.to_s != "play"
      if Input.trigger?(Input::B)
        movie.call("close FILE",0,0,0)
        $scene = Scene_Map.new
        break
      end
    end
    $scene = Scene_Map.new
  end
end
