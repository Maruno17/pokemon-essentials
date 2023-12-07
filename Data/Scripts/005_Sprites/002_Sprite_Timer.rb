class Sprite_Timer
  def initialize(viewport = nil)
    @viewport = viewport
    @timer = nil
    @total_sec = nil
    @disposed = false
  end

  def dispose
    @timer&.dispose
    @timer = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def update
    return if disposed?
    if $game_system.timer_start
      @timer.visible = true if @timer
      if !@timer
        @timer = Window_AdvancedTextPokemon.newWithSize("", Graphics.width - 120, 0, 120, 64)
        @timer.width = @timer.borderX + 96
        @timer.x = Graphics.width - @timer.width
        @timer.viewport = @viewport
        @timer.z = 99998
      end
      curtime = $game_system.timer
      curtime = 0 if curtime < 0
      if curtime != @total_sec
        # Calculate total number of seconds
        @total_sec = curtime
        # Make a string for displaying the timer
        min = @total_sec / 60
        sec = @total_sec % 60
        @timer.text = _ISPRINTF("<ac>{1:02d}:{2:02d}", min, sec)
      end
      @timer.update
    elsif @timer
      @timer.visible = false
    end
  end
end
