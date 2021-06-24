def Kernel.pbDisplayText(message,xposition,yposition,z=nil)
  @hud = []
  # Draw the text
    baseColor=Color.new(72,72,72)
    shadowColor=Color.new(160,160,160)
    sprite = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
    if z != nil
      sprite.z=z
    end
    @hud.push(sprite)
    text1=_INTL(message)
    textPosition=[
      [text1,xposition,yposition,2,baseColor,shadowColor],
    ]
    pbSetSystemFont(@hud[-1].bitmap)
    pbDrawTextPositions(@hud[0].bitmap,textPosition)
end

def Kernel.pbDisplayNumber(number,xposition,yposition)
  @numT = []
  # Draw the text
    baseColor=Color.new(72,72,72)
    shadowColor=Color.new(160,160,160)
    @numT.push(BitmapSprite.new(Graphics.width,Graphics.height,@viewport1))
    text1=_INTL(number.to_s)
    textPosition=[
      [text1,xposition,yposition,2,baseColor,shadowColor],
    ]
    pbSetSystemFont(@numT[-1].bitmap)
    pbDrawTextPositions(@numT[0].bitmap,textPosition)
end

def Kernel.pbClearNumber()
  if @numT != nil then
    for sprite in @numT
      sprite.dispose
    end
    @numT.clear
end
end
def Kernel.pbClearText()
  if @hud != nil then
    for sprite in @hud
      sprite.dispose
    end
    @hud.clear
end
end
