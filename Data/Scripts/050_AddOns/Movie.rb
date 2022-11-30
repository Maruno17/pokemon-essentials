class Movie
  attr_reader :finished

  def initialize(framesPath, bgm, maxFrame = 1000, canStopEarly=false)
    @currentFrame = 1
    @initialTime = nil
    @timeElapsed = nil
    @maxFrame = maxFrame
    @framesPath = framesPath
    @bgm = bgm
    @canStopEarly = canStopEarly
    @finished=false
  end

  def play(imageNumber = 12)
    @finished=false
    @currentFrame = 1
    @initialTime = Time.now
    @timeElapsed = Time.now

    pbBGMPlay(@bgm)
    while (@currentFrame <= @maxFrame)# && !(@canStopEarly && Input::ACTION))
      if Input.trigger?(Input::C)

      end
      frame = sprintf(@framesPath, @currentFrame)
      picture = Game_Picture.new(imageNumber)
      picture.show(frame, 0, 0, 0, 100, 100, 255, 0)
      pbWait(Graphics.frame_rate / 20)
      picture.erase
      @currentFrame += 1
    end
    @finished=true
    pbBGMStop
  end

  def playInViewPort(viewport)
    @finished=false
    @currentFrame = 1
    @initialTime = Time.now
    @timeElapsed = Time.now

    pbBGMPlay(@bgm)
    while (@currentFrame <= @maxFrame)# && !(@canStopEarly && Input::ACTION))
      break if Input.trigger?(Input::C) && @canStopEarly
      frame = sprintf(@framesPath, @currentFrame)
      picture = Sprite.new(viewport)
      picture.bitmap = pbBitmap(frame)
      picture.visible=true
      pbWait(Graphics.frame_rate / 20)
      picture.dispose
      @currentFrame += 1
    end
    @finished=true
    pbBGMStop
  end

  # not really necessary I think
  # def pbAutoregulador()
  #   hora_inicio = $game_variables[VARIABLE_TIME_INITIAL]
  #   hora_actual = Time.now
  #   diferencia = (hora_actual - hora_inicio) * 20 #20 frames corresponde a 1 seg
  #   #Redondeo
  #   diferencia_entera = diferencia.to_i
  #
  #   diferencia_entera = diferencia_entera.to_f
  #
  #   if diferencia - diferencia_entera >= 0.5
  #     diferencia_entera = diferencia_entera + 1
  #   end
  #
  #   $game_variables[VARIABLE_CURRENT_FRAME] = diferencia_entera.to_int
  #
  #   $game_variables[VARIABLE_TIME_ELAPSED] = Time.now
  #
  #   return $game_variables[VARIABLE_CURRENT_FRAME]
  # end

end
