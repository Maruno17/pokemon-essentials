#===============================================================================
#
#===============================================================================
class Plane
  def update; end
  def refresh; end
end

#===============================================================================
# A plane class that displays a single color.
#===============================================================================
class ColoredPlane < Plane
  def initialize(color, viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(32, 32)
    set_plane_color(color)
  end

  def dispose
    self.bitmap&.dispose
    super
  end

  def set_plane_color(value)
    self.bitmap.fill_rect(0, 0, self.bitmap.width, self.bitmap.height, value)
    refresh
  end
end

#===============================================================================
# A plane class that supports animated images.
#===============================================================================
class AnimatedPlane < Plane
  def initialize(viewport)
    super(viewport)
    @bitmap = nil
  end

  def dispose
    clear_bitmap
    super
  end

  def setBitmap(file, hue = 0)
    clear_bitmap
    return if file.nil?
    @bitmap = AnimatedBitmap.new(file, hue)
    self.bitmap = @bitmap.bitmap if @bitmap
  end

  def set_panorama(file, hue = 0)
    if file.is_a?(String) && file.length > 0
      setBitmap("Graphics/Panoramas/" + file, hue)
    else
      clear_bitmap
    end
  end

  def set_fog(file, hue = 0)
    if file.is_a?(String) && file.length > 0
      setBitmap("Graphics/Fogs/" + file, hue)
    else
      clear_bitmap
    end
  end

  private

  def clear_bitmap
    @bitmap&.dispose
    @bitmap = nil
    self.bitmap = nil if !self.disposed?
  end
end
