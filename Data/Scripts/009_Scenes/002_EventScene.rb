#===============================================================================
#
#===============================================================================
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
#
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
    @picturesprites.each { |sprite| sprite.dispose }
    @usersprites.each { |sprite| sprite.dispose }
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

  # ticks is in 1/20ths of a second.
  def wait(ticks)
    return if ticks <= 0
    timer_start = System.uptime
    loop do
      update
      break if System.uptime - timer_start >= ticks / 20.0
    end
  end

  # extra_ticks is in 1/20ths of a second.
  def pictureWait(extra_ticks = 0)
    loop do
      hasRunning = false
      @pictures.each { |pic| hasRunning = true if pic.running? }
      break if !hasRunning
      update
    end
    wait(extra_ticks)
  end

  def update
    return if disposed?
    Graphics.update
    Input.update
    @pictures.each { |picture| picture.update }
    @picturesprites.each { |sprite| sprite.update }
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
    loop do
      update
      break if disposed?
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbEventScreen(cls)
  pbFadeOutIn do
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    PBDebug.logonerr { cls.new(viewport).main }
    viewport.dispose
  end
end
