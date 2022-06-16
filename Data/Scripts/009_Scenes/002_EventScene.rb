class PictureSprite < Sprite
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    @pictureBitmap = nil
    @customBitmap = nil
    @customBitmapIsBitmap = true
    @hue = 0
    update
  end

  def dispose
    @pictureBitmap&.dispose
    super
  end

  # Doesn't free the bitmap
  def setCustomBitmap(bitmap)
    @customBitmap = bitmap
    @customBitmapIsBitmap = @customBitmap.is_a?(Bitmap)
  end

  def update
    super
    @pictureBitmap&.update
    # If picture file name is different from current one
    if @customBitmap && @picture.name == ""
      self.bitmap = (@customBitmapIsBitmap) ? @customBitmap : @customBitmap.bitmap
    elsif @picture_name != @picture.name || @picture.hue.to_i != @hue.to_i
      # Remember file name to instance variables
      @picture_name = @picture.name
      @hue = @picture.hue.to_i
      # If file name is not empty
      if @picture_name == ""
        @pictureBitmap&.dispose
        @pictureBitmap = nil
        self.visible = false
        return
      end
      # Get picture graphic
      @pictureBitmap&.dispose
      @pictureBitmap = AnimatedBitmap.new(@picture_name, @hue)
      self.bitmap = (@pictureBitmap) ? @pictureBitmap.bitmap : nil
    elsif @picture_name == ""
      # Set sprite to invisible
      self.visible = false
      return
    end
    setPictureSprite(self, @picture)
  end
end



def pbTextBitmap(text, maxwidth = Graphics.width)
  tmp = Bitmap.new(maxwidth, Graphics.height)
  pbSetSystemFont(tmp)
  drawFormattedTextEx(tmp, 0, 4, maxwidth, text, Color.new(248, 248, 248), Color.new(168, 184, 184))
  return tmp
end



#===============================================================================
# EventScene
#===============================================================================
class EventScene
  attr_accessor :onCTrigger, :onBTrigger, :onUpdate

  def initialize(viewport = nil)
    @viewport       = viewport
    @onCTrigger     = Event.new
    @onBTrigger     = Event.new
    @onUpdate       = Event.new
    @pictures       = []
    @picturesprites = []
    @usersprites    = []
    @disposed       = false
  end

  def dispose
    return if disposed?
    @picturesprites.each do |sprite|
      sprite.dispose
    end
    @usersprites.each do |sprite|
      sprite.dispose
    end
    @onCTrigger.clear
    @onBTrigger.clear
    @onUpdate.clear
    @pictures.clear
    @picturesprites.clear
    @usersprites.clear
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def addBitmap(x, y, bitmap)
    # _bitmap_ can be a Bitmap or an AnimatedBitmap
    # (update method isn't called if it's animated)
    # EventScene doesn't take ownership of the passed-in bitmap
    num = @pictures.length
    picture = PictureEx.new(num)
    picture.setXY(0, x, y)
    picture.setVisible(0, true)
    @pictures[num] = picture
    @picturesprites[num] = PictureSprite.new(@viewport, picture)
    @picturesprites[num].setCustomBitmap(bitmap)
    return picture
  end

  def addLabel(x, y, width, text)
    addBitmap(x, y, pbTextBitmap(text, width))
  end

  def addImage(x, y, name)
    num = @pictures.length
    picture = PictureEx.new(num)
    picture.name = name
    picture.setXY(0, x, y)
    picture.setVisible(0, true)
    @pictures[num] = picture
    @picturesprites[num] = PictureSprite.new(@viewport, picture)
    return picture
  end

  def addUserSprite(sprite)
    @usersprites.push(sprite)
  end

  def getPicture(num)
    return @pictures[num]
  end

  def wait(frames)
    frames.times { update }
  end

  def pictureWait(extraframes = 0)
    loop do
      hasRunning = false
      @pictures.each do |pic|
        hasRunning = true if pic.running?
      end
      break if !hasRunning
      update
    end
    extraframes.times { update }
  end

  def update
    return if disposed?
    Graphics.update
    Input.update
    @pictures.each do |picture|
      picture.update
    end
    @picturesprites.each do |sprite|
      sprite.update
    end
    @usersprites.each do |sprite|
      next if !sprite || sprite.disposed? || !sprite.is_a?(Sprite)
      sprite.update
    end
    @onUpdate.trigger(self)
    if Input.trigger?(Input::BACK)
      @onBTrigger.trigger(self)
    elsif Input.trigger?(Input::USE)
      @onCTrigger.trigger(self)
    end
  end

  def main
    until disposed?
      update
    end
  end
end



#===============================================================================
#
#===============================================================================
def pbEventScreen(cls)
  pbFadeOutIn {
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    PBDebug.logonerr {
      cls.new(viewport).main
    }
    viewport.dispose
  }
end
