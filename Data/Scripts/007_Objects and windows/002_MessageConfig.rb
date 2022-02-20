module MessageConfig
  LIGHT_TEXT_MAIN_COLOR   = Color.new(248, 248, 248)
  LIGHT_TEXT_SHADOW_COLOR = Color.new(72, 80, 88)
  DARK_TEXT_MAIN_COLOR    = Color.new(80, 80, 88)
  DARK_TEXT_SHADOW_COLOR  = Color.new(160, 160, 168)
  FONT_NAME               = "Power Green"
  FONT_SIZE               = 27
  FONT_Y_OFFSET           = 8
  SMALL_FONT_NAME         = "Power Green Small"
  SMALL_FONT_SIZE         = 21
  SMALL_FONT_Y_OFFSET     = 8
  NARROW_FONT_NAME        = "Power Green Narrow"
  NARROW_FONT_SIZE        = 27
  NARROW_FONT_Y_OFFSET    = 8
  # 0 = Pause cursor is displayed at end of text
  # 1 = Pause cursor is displayed at bottom right
  # 2 = Pause cursor is displayed at lower middle side
  CURSOR_POSITION         = 1
  WINDOW_OPACITY          = 255
  TEXT_SPEED              = nil   # can be positive to wait frames or negative to
                                  # show multiple characters in a single frame
  @@systemFrame     = nil
  @@defaultTextSkin = nil
  @@textSpeed       = nil
  @@systemFont      = nil
  @@smallFont       = nil
  @@narrowFont      = nil

  def self.pbDefaultSystemFrame
    if $PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[$PokemonSystem.frame]) || ""
    else
      return pbResolveBitmap("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[0]) || ""
    end
  end

  def self.pbDefaultSpeechFrame
    if $PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[$PokemonSystem.textskin]) || ""
    else
      return pbResolveBitmap("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[0]) || ""
    end
  end

  def self.pbDefaultWindowskin
    skin = ($data_system) ? $data_system.windowskin_name : nil
    if skin && skin != ""
      skin = pbResolveBitmap("Graphics/Windowskins/" + skin) || ""
    end
    skin = pbResolveBitmap("Graphics/System/Window") if nil_or_empty?(skin)
    skin = pbResolveBitmap("Graphics/Windowskins/001-Blue01") if nil_or_empty?(skin)
    return skin || ""
  end

  def self.pbGetSystemFrame
    if !@@systemFrame
      skin = MessageConfig.pbDefaultSystemFrame
      skin = MessageConfig.pbDefaultWindowskin if nil_or_empty?(skin)
      @@systemFrame = skin || ""
    end
    return @@systemFrame
  end

  def self.pbGetSpeechFrame
    if !@@defaultTextSkin
      skin = MessageConfig.pbDefaultSpeechFrame
      skin = MessageConfig.pbDefaultWindowskin if nil_or_empty?(skin)
      @@defaultTextSkin = skin || ""
    end
    return @@defaultTextSkin
  end

  def self.pbSetSystemFrame(value)
    @@systemFrame = pbResolveBitmap(value) || ""
  end

  def self.pbSetSpeechFrame(value)
    @@defaultTextSkin = pbResolveBitmap(value) || ""
  end

  #-----------------------------------------------------------------------------

  def self.pbDefaultTextSpeed
    return ($PokemonSystem) ? pbSettingToTextSpeed($PokemonSystem.textspeed) : pbSettingToTextSpeed(nil)
  end

  def self.pbGetTextSpeed
    @@textSpeed = pbDefaultTextSpeed if !@@textSpeed
    return @@textSpeed
  end

  def self.pbSetTextSpeed(value)
    @@textSpeed = value
  end

  def self.pbSettingToTextSpeed(speed)
    case speed
    when 0 then return 2
    when 1 then return 1
    when 2 then return -2
    end
    return TEXT_SPEED || 1
  end

  #-----------------------------------------------------------------------------

  def self.pbDefaultSystemFontName
    return MessageConfig.pbTryFonts(FONT_NAME)
  end

  def self.pbDefaultSmallFontName
    return MessageConfig.pbTryFonts(SMALL_FONT_NAME)
  end

  def self.pbDefaultNarrowFontName
    return MessageConfig.pbTryFonts(NARROW_FONT_NAME)
  end

  def self.pbGetSystemFontName
    @@systemFont = pbDefaultSystemFontName if !@@systemFont
    return @@systemFont
  end

  def self.pbGetSmallFontName
    @@smallFont = pbDefaultSmallFontName if !@@smallFont
    return @@smallFont
  end

  def self.pbGetNarrowFontName
    @@narrowFont = pbDefaultNarrowFontName if !@@narrowFont
    return @@narrowFont
  end

  def self.pbSetSystemFontName(value)
    @@systemFont = MessageConfig.pbTryFonts(value)
    @@systemFont = MessageConfig.pbDefaultSystemFontName if @@systemFont == ""
  end

  def self.pbSetSmallFontName(value)
    @@smallFont = MessageConfig.pbTryFonts(value)
    @@smallFont = MessageConfig.pbDefaultSmallFontName if @@smallFont == ""
  end

  def self.pbSetNarrowFontName(value)
    @@narrowFont = MessageConfig.pbTryFonts(value)
    @@narrowFont = MessageConfig.pbDefaultNarrowFontName if @@narrowFont == ""
  end

  def self.pbTryFonts(*args)
    args.each do |a|
      next if !a
      case a
      when String
        return a if Font.exist?(a)
      when Array
        a.each do |aa|
          ret = MessageConfig.pbTryFonts(aa)
          return ret if ret != ""
        end
      end
    end
    return ""
  end
end



#===============================================================================
# Position a window
#===============================================================================
def pbBottomRight(window)
  window.x = Graphics.width - window.width
  window.y = Graphics.height - window.height
end

def pbBottomLeft(window)
  window.x = 0
  window.y = Graphics.height - window.height
end

def pbBottomLeftLines(window, lines, width = nil)
  window.x = 0
  window.width = width || Graphics.width
  window.height = (window.borderY rescue 32) + (lines * 32)
  window.y = Graphics.height - window.height
end

def pbPositionFaceWindow(facewindow, msgwindow)
  return if !facewindow
  if msgwindow
    if facewindow.height <= msgwindow.height
      facewindow.y = msgwindow.y
    else
      facewindow.y = msgwindow.y + msgwindow.height - facewindow.height
    end
    facewindow.x = Graphics.width - facewindow.width
    msgwindow.x = 0
    msgwindow.width = Graphics.width - facewindow.width
  else
    facewindow.height = Graphics.height if facewindow.height > Graphics.height
    facewindow.x = 0
    facewindow.y = 0
  end
end

def pbPositionNearMsgWindow(cmdwindow, msgwindow, side)
  return if !cmdwindow
  if msgwindow
    height = [cmdwindow.height, Graphics.height - msgwindow.height].min
    if cmdwindow.height != height
      cmdwindow.height = height
    end
    cmdwindow.y = msgwindow.y - cmdwindow.height
    if cmdwindow.y < 0
      cmdwindow.y = msgwindow.y + msgwindow.height
      if cmdwindow.y + cmdwindow.height > Graphics.height
        cmdwindow.y = msgwindow.y - cmdwindow.height
      end
    end
    case side
    when :left
      cmdwindow.x = msgwindow.x
    when :right
      cmdwindow.x = msgwindow.x + msgwindow.width - cmdwindow.width
    else
      cmdwindow.x = msgwindow.x + msgwindow.width - cmdwindow.width
    end
  else
    cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
    cmdwindow.x = 0
    cmdwindow.y = 0
  end
end

# internal function
def pbRepositionMessageWindow(msgwindow, linecount = 2)
  msgwindow.height = (32 * linecount) + msgwindow.borderY
  msgwindow.y = (Graphics.height) - (msgwindow.height)
  if $game_system
    case $game_system.message_position
    when 0  # up
      msgwindow.y = 0
    when 1  # middle
      msgwindow.y = (Graphics.height / 2) - (msgwindow.height / 2)
    when 2
      msgwindow.y = (Graphics.height) - (msgwindow.height)
    end
    msgwindow.opacity = 0 if $game_system.message_frame != 0
  end
end

# internal function
def pbUpdateMsgWindowPos(msgwindow, event, eventChanged = false)
  if event
    if eventChanged
      msgwindow.resizeToFit2(msgwindow.text, Graphics.width * 2 / 3, msgwindow.height)
    end
    msgwindow.y = event.screen_y - 48 - msgwindow.height
    if msgwindow.y < 0
      msgwindow.y = event.screen_y + 24
    end
    msgwindow.x = event.screen_x - (msgwindow.width / 2)
    msgwindow.x = 0 if msgwindow.x < 0
    if msgwindow.x > Graphics.width - msgwindow.width
      msgwindow.x = Graphics.width - msgwindow.width
    end
  else
    curwidth = msgwindow.width
    if curwidth != Graphics.width
      msgwindow.width = Graphics.width
      msgwindow.width = Graphics.width
    end
  end
end

#===============================================================================
# Determine the colour of a background
#===============================================================================
def isDarkBackground(background, rect = nil)
  return true if !background || background.disposed?
  rect = background.rect if !rect
  return true if rect.width <= 0 || rect.height <= 0
  xSeg = (rect.width / 16)
  xLoop = (xSeg == 0) ? 1 : 16
  xStart = (xSeg == 0) ? rect.x + (rect.width / 2) : rect.x + (xSeg / 2)
  ySeg = (rect.height / 16)
  yLoop = (ySeg == 0) ? 1 : 16
  yStart = (ySeg == 0) ? rect.y + (rect.height / 2) : rect.y + (ySeg / 2)
  count = 0
  y = yStart
  r = g = b = 0
  yLoop.times do
    x = xStart
    xLoop.times do
      clr = background.get_pixel(x, y)
      if clr.alpha != 0
        r += clr.red
        g += clr.green
        b += clr.blue
        count += 1
      end
      x += xSeg
    end
    y += ySeg
  end
  return true if count == 0
  r /= count
  g /= count
  b /= count
  return ((r * 0.299) + (g * 0.587) + (b * 0.114)) < 160
end

def isDarkWindowskin(windowskin)
  return true if !windowskin || windowskin.disposed?
  if windowskin.width == 192 && windowskin.height == 128
    return isDarkBackground(windowskin, Rect.new(0, 0, 128, 128))
  elsif windowskin.width == 128 && windowskin.height == 128
    return isDarkBackground(windowskin, Rect.new(0, 0, 64, 64))
  elsif windowskin.width == 96 && windowskin.height == 48
    return isDarkBackground(windowskin, Rect.new(32, 16, 16, 16))
  else
    clr = windowskin.get_pixel(windowskin.width / 2, windowskin.height / 2)
    return ((clr.red * 0.299) + (clr.green * 0.587) + (clr.blue * 0.114)) < 160
  end
end

#===============================================================================
# Determine which text colours to use based on the darkness of the background
#===============================================================================
def getSkinColor(windowskin, color, isDarkSkin)
  if !windowskin || windowskin.disposed? ||
     windowskin.width != 128 || windowskin.height != 128
    # Base color, shadow color (these are reversed on dark windowskins)
    textcolors = [
      "0070F8", "78B8E8",   # 1  Blue
      "E82010", "F8A8B8",   # 2  Red
      "60B048", "B0D090",   # 3  Green
      "48D8D8", "A8E0E0",   # 4  Cyan
      "D038B8", "E8A0E0",   # 5  Magenta
      "E8D020", "F8E888",   # 6  Yellow
      "A0A0A8", "D0D0D8",   # 7  Grey
      "F0F0F8", "C8C8D0",   # 8  White
      "9040E8", "B8A8E0",   # 9  Purple
      "F89818", "F8C898",   # 10 Orange
      colorToRgb32(MessageConfig::DARK_TEXT_MAIN_COLOR),
      colorToRgb32(MessageConfig::DARK_TEXT_SHADOW_COLOR),   # 11 Dark default
      colorToRgb32(MessageConfig::LIGHT_TEXT_MAIN_COLOR),
      colorToRgb32(MessageConfig::LIGHT_TEXT_SHADOW_COLOR)   # 12 Light default
    ]
    if color == 0 || color > textcolors.length / 2   # No special colour, use default
      if isDarkSkin   # Dark background, light text
        return shadowc3tag(MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR)
      end
      # Light background, dark text
      return shadowc3tag(MessageConfig::DARK_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_SHADOW_COLOR)
    end
    # Special colour as listed above
    if isDarkSkin && color != 12   # Dark background, light text
      return sprintf("<c3=%s,%s>", textcolors[(2 * (color - 1)) + 1], textcolors[2 * (color - 1)])
    end
    # Light background, dark text
    return sprintf("<c3=%s,%s>", textcolors[2 * (color - 1)], textcolors[(2 * (color - 1)) + 1])
  else   # VX windowskin
    color = 0 if color >= 32
    x = 64 + ((color % 8) * 8)
    y = 96 + ((color / 8) * 8)
    pixel = windowskin.get_pixel(x, y)
    return shadowctagFromColor(pixel)
  end
end

def getDefaultTextColors(windowskin)
  if !windowskin || windowskin.disposed? ||
     windowskin.width != 128 || windowskin.height != 128
    if isDarkWindowskin(windowskin)
      return [MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR]   # White
    else
      return [MessageConfig::DARK_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_SHADOW_COLOR]   # Dark gray
    end
  else   # VX windowskin
    color = windowskin.get_pixel(64, 96)
    shadow = nil
    isDark = (color.red + color.green + color.blue) / 3 < 128
    if isDark
      shadow = Color.new(color.red + 64, color.green + 64, color.blue + 64)
    else
      shadow = Color.new(color.red - 64, color.green - 64, color.blue - 64)
    end
    return [color, shadow]
  end
end

#===============================================================================
# Makes sure a bitmap exists
#===============================================================================
def pbDoEnsureBitmap(bitmap, dwidth, dheight)
  if !bitmap || bitmap.disposed? || bitmap.width < dwidth || bitmap.height < dheight
    oldfont = (bitmap && !bitmap.disposed?) ? bitmap.font : nil
    bitmap&.dispose
    bitmap = Bitmap.new([1, dwidth].max, [1, dheight].max)
    (oldfont) ? bitmap.font = oldfont : pbSetSystemFont(bitmap)
    bitmap.font.shadow = false if bitmap.font.respond_to?("shadow")
  end
  return bitmap
end

#===============================================================================
# Set a bitmap's font
#===============================================================================
# Sets a bitmap's font to the system font.
def pbSetSystemFont(bitmap)
  bitmap.font.name = MessageConfig.pbGetSystemFontName
  bitmap.font.size = MessageConfig::FONT_SIZE
  bitmap.text_offset_y = MessageConfig::FONT_Y_OFFSET
end

# Sets a bitmap's font to the system small font.
def pbSetSmallFont(bitmap)
  bitmap.font.name = MessageConfig.pbGetSmallFontName
  bitmap.font.size = MessageConfig::SMALL_FONT_SIZE
  bitmap.text_offset_y = MessageConfig::SMALL_FONT_Y_OFFSET
end

# Sets a bitmap's font to the system narrow font.
def pbSetNarrowFont(bitmap)
  bitmap.font.name = MessageConfig.pbGetNarrowFontName
  bitmap.font.size = MessageConfig::NARROW_FONT_SIZE
  bitmap.text_offset_y = MessageConfig::NARROW_FONT_Y_OFFSET
end

#===============================================================================
# Blend colours, set the colour of all bitmaps in a sprite hash
#===============================================================================
def pbAlphaBlend(dstColor, srcColor)
  r = (255 * (srcColor.red - dstColor.red) / 255) + dstColor.red
  g = (255 * (srcColor.green - dstColor.green) / 255) + dstColor.green
  b = (255 * (srcColor.blue - dstColor.blue) / 255) + dstColor.blue
  a = (255 * (srcColor.alpha - dstColor.alpha) / 255) + dstColor.alpha
  return Color.new(r, g, b, a)
end

def pbSrcOver(dstColor, srcColor)
  er = srcColor.red * srcColor.alpha / 255
  eg = srcColor.green * srcColor.alpha / 255
  eb = srcColor.blue * srcColor.alpha / 255
  iea = 255 - srcColor.alpha
  cr = dstColor.red * dstColor.alpha / 255
  cg = dstColor.green * dstColor.alpha / 255
  cb = dstColor.blue * dstColor.alpha / 255
  ica = 255 - dstColor.alpha
  a = 255 - ((iea * ica) / 255)
  r = ((iea * cr) / 255) + er
  g = ((iea * cg) / 255) + eg
  b = ((iea * cb) / 255) + eb
  r = (a == 0) ? 0 : r * 255 / a
  g = (a == 0) ? 0 : g * 255 / a
  b = (a == 0) ? 0 : b * 255 / a
  return Color.new(r, g, b, a)
end

def pbSetSpritesToColor(sprites, color)
  return if !sprites || !color
  colors = {}
  sprites.each do |i|
    next if !i[1] || pbDisposed?(i[1])
    colors[i[0]] = i[1].color.clone
    i[1].color = pbSrcOver(i[1].color, color)
  end
  Graphics.update
  Input.update
  colors.each do |i|
    next if !sprites[i[0]]
    sprites[i[0]].color = i[1]
  end
end

#===============================================================================
# Update and dispose sprite hashes
#===============================================================================
def using(window)
  begin
    yield if block_given?
  ensure
    window.dispose
  end
end

def pbUpdateSpriteHash(windows)
  windows.each do |i|
    window = i[1]
    if window
      if window.is_a?(Sprite) || window.is_a?(Window)
        window.update if !pbDisposed?(window)
      elsif window.is_a?(Plane)
        begin
          window.update if !window.disposed?
        rescue NoMethodError
        end
      elsif window.respond_to?("update")
        begin
          window.update
        rescue RGSSError
        end
      end
    end
  end
end

# Disposes all objects in the specified hash.
def pbDisposeSpriteHash(sprites)
  return if !sprites
  sprites.each_key do |i|
    pbDisposeSprite(sprites, i)
  end
  sprites.clear
end

# Disposes the specified graphics object within the specified hash. Basically
# like:   sprites[id].dispose
def pbDisposeSprite(sprites, id)
  sprite = sprites[id]
  sprite.dispose if sprite && !pbDisposed?(sprite)
  sprites[id] = nil
end

def pbDisposed?(x)
  return true if !x
  return x.disposed? if !x.is_a?(Viewport)
  begin
    x.rect = x.rect
  rescue
    return true
  end
  return false
end

#===============================================================================
# Fades and window activations for sprite hashes
#===============================================================================
def pbPushFade
  $game_temp.fadestate = [$game_temp.fadestate + 1, 0].max if $game_temp
end

def pbPopFade
  $game_temp.fadestate = [$game_temp.fadestate - 1, 0].max if $game_temp
end

def pbIsFaded?
  return ($game_temp) ? $game_temp.fadestate > 0 : false
end

# pbFadeOutIn(z) { block }
# Fades out the screen before a block is run and fades it back in after the
# block exits.  z indicates the z-coordinate of the viewport used for this effect
def pbFadeOutIn(z = 99999, nofadeout = false)
  col = Color.new(0, 0, 0, 0)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = z
  numFrames = (Graphics.frame_rate * 0.4).floor
  alphaDiff = (255.0 / numFrames).ceil
  (0..numFrames).each do |j|
    col.set(0, 0, 0, j * alphaDiff)
    viewport.color = col
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    val = 0
    val = yield if block_given?
    nofadeout = true if val == 99999   # Ugly hack used by Town Map in the Bag/Pokégear
  ensure
    pbPopFade
    if !nofadeout
      (0..numFrames).each do |j|
        col.set(0, 0, 0, (numFrames - j) * alphaDiff)
        viewport.color = col
        Graphics.update
        Input.update
      end
    end
    viewport.dispose
  end
end

def pbFadeOutInWithUpdate(z, sprites, nofadeout = false)
  col = Color.new(0, 0, 0, 0)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = z
  numFrames = (Graphics.frame_rate * 0.4).floor
  alphaDiff = (255.0 / numFrames).ceil
  (0..numFrames).each do |j|
    col.set(0, 0, 0, j * alphaDiff)
    viewport.color = col
    pbUpdateSpriteHash(sprites)
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    yield if block_given?
  ensure
    pbPopFade
    if !nofadeout
      (0..numFrames).each do |j|
        col.set(0, 0, 0, (numFrames - j) * alphaDiff)
        viewport.color = col
        pbUpdateSpriteHash(sprites)
        Graphics.update
        Input.update
      end
    end
    viewport.dispose
  end
end

# Similar to pbFadeOutIn, but pauses the music as it fades out.
# Requires scripts "Audio" (for bgm_pause) and "SpriteWindow" (for pbFadeOutIn).
def pbFadeOutInWithMusic(zViewport = 99999)
  playingBGS = $game_system.getPlayingBGS
  playingBGM = $game_system.getPlayingBGM
  $game_system.bgm_pause(1.0)
  $game_system.bgs_pause(1.0)
  pos = $game_system.bgm_position
  pbFadeOutIn(zViewport) {
    yield
    $game_system.bgm_position = pos
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  }
end

def pbFadeOutAndHide(sprites)
  visiblesprites = {}
  numFrames = (Graphics.frame_rate * 0.4).floor
  alphaDiff = (255.0 / numFrames).ceil
  pbDeactivateWindows(sprites) {
    (0..numFrames).each do |j|
      pbSetSpritesToColor(sprites, Color.new(0, 0, 0, j * alphaDiff))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
  sprites.each do |i|
    next if !i[1]
    next if pbDisposed?(i[1])
    visiblesprites[i[0]] = true if i[1].visible
    i[1].visible = false
  end
  return visiblesprites
end

def pbFadeInAndShow(sprites, visiblesprites = nil)
  if visiblesprites
    visiblesprites.each do |i|
      if i[1] && sprites[i[0]] && !pbDisposed?(sprites[i[0]])
        sprites[i[0]].visible = true
      end
    end
  end
  numFrames = (Graphics.frame_rate * 0.4).floor
  alphaDiff = (255.0 / numFrames).ceil
  pbDeactivateWindows(sprites) {
    (0..numFrames).each do |j|
      pbSetSpritesToColor(sprites, Color.new(0, 0, 0, ((numFrames - j) * alphaDiff)))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
end

# Restores which windows are active for the given sprite hash.
# _activeStatuses_ is the result of a previous call to pbActivateWindows
def pbRestoreActivations(sprites, activeStatuses)
  return if !sprites || !activeStatuses
  activeStatuses.each_key do |k|
    if sprites[k].is_a?(Window) && !pbDisposed?(sprites[k])
      sprites[k].active = activeStatuses[k] ? true : false
    end
  end
end

# Deactivates all windows. If a code block is given, deactivates all windows,
# runs the code in the block, and reactivates them.
def pbDeactivateWindows(sprites)
  if block_given?
    pbActivateWindow(sprites, nil) { yield }
  else
    pbActivateWindow(sprites, nil)
  end
end

# Activates a specific window of a sprite hash. _key_ is the key of the window
# in the sprite hash. If a code block is given, deactivates all windows except
# the specified window, runs the code in the block, and reactivates them.
def pbActivateWindow(sprites, key)
  return if !sprites
  activeStatuses = {}
  sprites.each do |i|
    if i[1].is_a?(Window) && !pbDisposed?(i[1])
      activeStatuses[i[0]] = i[1].active
      i[1].active = (i[0] == key)
    end
  end
  if block_given?
    begin
      yield
    ensure
      pbRestoreActivations(sprites, activeStatuses)
    end
    return {}
  else
    return activeStatuses
  end
end

#===============================================================================
# Create background planes for a sprite hash
#===============================================================================
# Adds a background to the sprite hash.
# _planename_ is the hash key of the background.
# _background_ is a filename within the Graphics/Pictures/ folder and can be
#     an animated image.
# _viewport_ is a viewport to place the background in.
def addBackgroundPlane(sprites, planename, background, viewport = nil)
  sprites[planename] = AnimatedPlane.new(viewport)
  bitmapName = pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName.nil?
    # Plane should exist in any case
    sprites[planename].bitmap = nil
    sprites[planename].visible = false
  else
    sprites[planename].setBitmap(bitmapName)
    sprites.each_value do |spr|
      if spr.is_a?(Window)
        spr.windowskin = nil
      end
    end
  end
end

# Adds a background to the sprite hash.
# _planename_ is the hash key of the background.
# _background_ is a filename within the Graphics/Pictures/ folder and can be
#       an animated image.
# _color_ is the color to use if the background can't be found.
# _viewport_ is a viewport to place the background in.
def addBackgroundOrColoredPlane(sprites, planename, background, color, viewport = nil)
  bitmapName = pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName.nil?
    # Plane should exist in any case
    sprites[planename] = ColoredPlane.new(color, viewport)
  else
    sprites[planename] = AnimatedPlane.new(viewport)
    sprites[planename].setBitmap(bitmapName)
    sprites.each_value do |spr|
      if spr.is_a?(Window)
        spr.windowskin = nil
      end
    end
  end
end



#===============================================================================
# Ensure required method definitions
#===============================================================================
module Graphics
  if !self.respond_to?("width")
    def self.width; return 640; end
  end
  if !self.respond_to?("height")
    def self.height; return 480; end
  end
end



if !defined?(_INTL)
  def _INTL(*args)
    string = args[0].clone
    (1...args.length).each do |i|
      string.gsub!(/\{#{i}\}/, args[i].to_s)
    end
    return string
  end
end

if !defined?(_ISPRINTF)
  def _ISPRINTF(*args)
    string = args[0].clone
    (1...args.length).each do |i|
      string.gsub!(/\{#{i}\:([^\}]+?)\}/) { |m|
        next sprintf("%" + $1, args[i])
      }
    end
    return string
  end
end

if !defined?(_MAPINTL)
  def _MAPINTL(*args)
    string = args[1].clone
    (2...args.length).each do |i|
      string.gsub!(/\{#{i}\}/, args[i + 1].to_s)
    end
    return string
  end
end
