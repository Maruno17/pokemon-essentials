
#NOTE:
#     USED FOR REGION MAP SCRIPT, BUT IS LIKELY TO BREAK A TON OF OTHER STUFF
#
#   TODO: CLEANUP, ONLY KEEP THE STUFF USED IN MAP SCRIPT


# Whether or not you want to use these utility methods. Toggling this off will
# likely break your scripts. So don't do it unless you know what you're doing :)
USING_MARIN_UTILITY = true

# Whether or not you want the custom/better errors message.
SPECIAL_ERRORS = true



# These two settings only apply if SPECIAL_ERRORS is TRUE

DOUBLE_BACKTRACE = false # The interpreter already contains a small
                         # backtrace for errors in events and such by default.
                         # Settings this to false will not show the custom
                         # backtrace.

BACKTRACE_MAX_SIZE = 12 # The backtrace can go all the way from the very first
                        # call to the very last call. This is the limit as far
                        # as it can go back, because you could have a massive
                        # backtrace otherwise.


def pbMarinUtility
  return USING_MARIN_UTILITY
end

if USING_MARIN_UTILITY

# Sprite class extensions
class Sprite
  # Shorthand for initializing a bitmap by path, bitmap, or width/height:
  # -> bmp("Graphics/Pictures/bag")
  # -> bmp(32, 32)
  # -> bmp(some_other_bitmap)
  def bmp(arg1 = nil, arg2 = nil)
    if arg1
      if arg2
        arg1 = Graphics.width if arg1 == -1
        arg2 = Graphics.height if arg2 == -1
        self.bitmap = Bitmap.new(arg1, arg2)
      elsif arg1.is_a?(Bitmap)
        self.bitmap = arg1.clone
      else
        self.bitmap = Bitmap.new(arg1)
      end
    else
      return self.bitmap
    end
  end
  
  # Alternative to bmp(path):
  # -> bmp = "Graphics/Pictures/bag"
  def bmp=(arg1)
    bmp(arg1)
  end
  
  # Usage:
  # -> [x]             # Sets sprite.x to x
  # -> [x,y]           # Sets sprite.x to x and sprite.y to y
  # -> [x,y,z]         # Sets sprite.x to x and sprite.y to y and sprite.z to z
  # -> [nil,y]         # Sets sprite.y to y
  # -> [nil,nil,z]     # Sets sprite.z to z
  # -> [x,nil,z]       # Sets sprite.x to x and sprite.z to z
  # Etc.
  def xyz=(args)
    self.x = args[0] || self.x
    self.y = args[1] || self.y
    self.z = args[2] || self.z
  end
  
  # Returns the x, y, and z coordinates in the xyz=(args) format, [x,y,z]
  def xyz
    return [self.x,self.y,self.z]
  end
  
  # Centers the sprite by setting the origin points to half the width and height
  def center_origins
    return if !self.bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
  
  # Returns the sprite's full width, taking zoom_x into account
  def fullwidth
    return self.bitmap.width.to_f * self.zoom_x
  end
  
  # Returns the sprite's full height, taking zoom_y into account
  def fullheight
    return self.bitmap.height.to_f * self.zoom_y
  end
end



# A better alternative to the typical @sprites = {}
class SpriteHash
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :visible
  attr_reader :opacity
  
  def initialize
    @hash = {}
    @x = 0
    @y = 0
    @z = 0
    @visible = true
    @opacity = 255
  end
  
  # Returns the object in the specified key
  def [](key)
    key = key.to_sym if key.respond_to?(:to_sym) && !key.is_a?(Numeric)
    return @hash[key]
  end
  
  # Sets an object in specified key to the specified value
  def []=(key, value)
  key = key.to_sym if key.respond_to?(:to_sym) && !key.is_a?(Numeric)
    add(key, value)
  end
  
  # Returns the raw hash
  def raw
    return @hash
  end
  
  # Returns the keys in the hash
  def keys
    return @hash.keys
  end
  
  def length; return self.size; end
  def count; return self.size; end
  
  # Returns the amount of keys in the hash
  def size
    return @hash.keys.size
  end
  
  # Clones the hash
  def clone
    return @hash.clone
  end
  
  # Adds an object to the specified key
  def add(key, value)
    clear_disposed
    key = key.to_sym if key.respond_to?(:to_sym) && !key.is_a?(Numeric)
    @hash[key] if @hash[key] && @hash[key].respond_to?(:dispose)
    @hash[key] = value
    clear_disposed
  end
  
  # Deletes an object in the specified key
  def delete(key)
    key = key.to_sym if key.respond_to?(:to_sym) && !key.is_a?(Numeric)
    @hash[key] = nil
    clear_disposed
  end
  
  # Iterates over all sprites
  def each
    clear_disposed
    @hash.each { |s| yield s[1] if block_given? }
  end
  
  # Updates all sprites
  def update
    clear_disposed
    for key in @hash.keys
      @hash[key].update if @hash[key].respond_to?(:update)
    end
  end
  
  # Disposes all sprites
  def dispose
    clear_disposed
    for key in @hash.keys
      @hash[key].dispose if @hash[key].respond_to?(:dispose)
    end
    clear_disposed
  end
  
  # Compatibility
  def disposed?
    return false
  end
  
  # Changes x on all sprites
  def x=(value)
    clear_disposed
    for key in @hash.keys
      @hash[key].x += value - @x
    end
    @x = value
  end
  
  # Changes y on all sprites
  def y=(value)
    clear_disposed
    for key in @hash.keys
      @hash[key].y += value - @y
    end
    @y = value
  end
  
  # Changes z on all sprites
  def z=(value)
    clear_disposed
    for key in @hash.keys
      @hash[key].z += value - @z
    end
    @z = value
  end
  
  # Changes visibility on all sprites
  def visible=(value)
    clear_disposed
    for key in @hash.keys
      @hash[key].visible = value
    end
  end
  
  # Changes opacity on all sprites
  def opacity=(value)
    clear_disposed
    for key in @hash.keys
      @hash[key].opacity += value - @opacity
    end
    @opacity = [0,value,255].sort[1]
  end
  
  # Fades out all sprites
  def hide(frames = 16)
    clear_disposed
    frames.times do
      Graphics.update
      Input.update
      for key in @hash.keys
        @hash[key].opacity -= 255 / frames.to_f
      end
    end
    @opacity = 0
  end
  
  # Fades in all sprites
  def show(frames = 16)
    clear_disposed
    frames.times do
      Graphics.update
      Input.update
      for key in @hash.keys
        @hash[key].opacity += 255 / frames.to_f
      end
    end
    @opacity = 255
  end
  
  # Deletes all disposed sprites from the hash
  def clear_disposed
    for key in @hash.keys
      if (@hash[key].disposed? rescue true)
        @hash[key] = nil
        @hash.delete(key)
      end
    end
  end
  
  # Renames the old key to the new key
  def rename(old, new)
    self[new] = self[old]
    delete(old)
  end
end


# Stand-alone methods

# Fades in a black overlay
def showBlk(n = 16)
  return if $blkVp || $blk
  $blkVp = Viewport.new(0,0,DEFAULTSCREENWIDTH,DEFAULTSCREENHEIGHT)
  $blkVp.z = 9999999
  $blk = Sprite.new($blkVp)
  $blk.bmp(-1,-1)
  $blk.bitmap.fill_rect(0,0,DEFAULTSCREENWIDTH,DEFAULTSCREENHEIGHT,Color.new(0,0,0))
  $blk.opacity = 0
  for i in 0...(n + 1)
    Graphics.update
    Input.update
    yield i if block_given?
    $blk.opacity += 256 / n.to_f
  end
end

# Fades out and disposes a black overlay
def hideBlk(n = 16)
  return if !$blk || !$blkVp
  for i in 0...(n + 1)
    Graphics.update
    Input.update
    yield i if block_given?
    $blk.opacity -= 256 / n.to_f
  end
  $blk.dispose
  $blk = nil
  $blkVp.dispose
  $blkVp = nil
end

# Returns the percentage of exp the Pokémon has compared to the next level
def pbGetExpPercentage(pokemon)
  pokemon = pokemon.pokemon if pokemon.respond_to?("pokemon")
  startexp = PBExperience.pbGetStartExperience(pokemon.level, pokemon.growthrate)
  endexp = PBExperience.pbGetStartExperience(pokemon.level + 1, pokemon.growthrate)
  return (pokemon.exp - startexp).to_f / (endexp - startexp).to_f
end

unless defined?(oldrand)
  alias oldrand rand
  def rand(a = nil, b = nil)
    if a.is_a?(Range)
      l = a.min
      u = a.max
      return l + oldrand(u - l + 1)
    elsif a.is_a?(Numeric)
      if b.is_a?(Numeric)
        return a + oldrand(b - a)
      else
        return oldrand(a)
      end
    elsif a.nil?
      if b
        return rand(b)
      else
        return oldrand(2)
      end
    end
  end
end

# Input module extensions
module Input
  # Returns true if any of the buttons below are pressed
  def self.any?
    return true if defined?(Game_Mouse) && $mouse && $mouse.click?
    keys = [Input::C,Input::B,Input::LEFT,Input::RIGHT,Input::UP,Input::DOWN,
            # 0-9, a-z
            0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,
            0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x50,0x51,0x52,0x53,
            0x54,0x55,0x56,0x57,0x58,0x59,0x5A]
    for key in keys
      return true if Input.triggerex?(key)
    end
    return false
  end
end





if SPECIAL_ERRORS

MessageBox = Win32API.new('user32', 'MessageBox', ['I','P','P','I'], 'I')

def p_msg(msg, title = nil, icon = nil)
  case icon
  when :error, :err
    uType = 0x10
    title ||= "Error" + "[" + GAME_VERSION_NUMBER + "]"
  when :q, :question, :ask
    uType = 0x20
    title ||= "Question"
  when :warning, :warn
    uType = 0x30
    title ||= "Warning"
  when :inform, :info, :information
    uType = 0x40
    title ||= "Info"
  else
    uType = 0
    title ||= "Pokémon"
  end
  hwnd = Win32API.pbFindRgssWindow
  Graphics.update
  t = Thread.new { MessageBox.call(hwnd, msg, title, uType); Thread.exit }
  while t.status
    Graphics.update
  end
end


def buildErrorTitle()
  title = "Error " + "[" + GAME_VERSION_NUMBER + "]"
  if $game_switches
    title += " rt " if $game_switches[987] #random trainers
    title += " rwg " if $game_switches[956] #random wild - global
    title += " rwa" if $game_switches[777] #random wild - area
    title += "_f" if $game_switches[953] #rand to fusion
  end
  return title
end

def p_err(ex = $!, message = nil)
  if $Rescue
    raise
    return
  end
  if ex.is_a?(String)
    ex = RuntimeError.new ex
  elsif ex.is_a?(Class)
    ex = ex.new
  end
  trace = ex.backtrace || caller
  script_id = trace[0][7..-1].split(':')[0].to_i
  script = $RGSS_SCRIPTS[script_id][1]
  line = trace[0].split(':')[1].to_i
  msg = "Script '[#{script}]' line #{line}: #{ex.class} occurred."
  if message || ex.message != ex.class.to_s
    if message
      msg << "\n\n#{message}"
    else
      msg << "\n\n#{ex.message}"
      message = ex.message
    end
  end
  showtrace = (trace.size > 2)
  showtrace = false if !DOUBLE_BACKTRACE && message.include?(':in `')
  if showtrace
    msg << "\n\n"
    msg << trace[0...BACKTRACE_MAX_SIZE].map do |e|
      sID = e.split(':')[0][7..-1]
      if sID.numeric?
        sID = sID.to_i
        s = "'" + $RGSS_SCRIPTS[sID][1] + "'"
      else
        s = "eval"
      end
      line = e.split(':')[1].to_i
      code = e.split(':')[2..-1].join(':')
      str = "from #{s} line #{line}"
      str << " #{code}" unless code.empty?
      next str
    end.join("\n")
  end
  p_msg(msg, buildErrorTitle(), :err)
  Kernel.exit! true
end

def p_info(msg, title = nil)
  p_msg(msg, title, :info)
end

def p_warn(msg, title = nil)
  p_msg(msg, title, :warn)
end

def p_question(msg, title = nil)
  p_msg(msg, title, :question)
end

trace_var(:$scene, proc do |object|
  break unless object
  unless object.instance_variable_get(:@__old_main)
    object.instance_variable_set(:@__old_main, object.method(:main))
    def object.main
      self.instance_variable_get(:@__old_main).call
    rescue
      p_err
    end
  end
end)

else

def p_err(*args)
  raise *args
end

end # if SPECIAL_ERRORS


def pbGetActiveEventPage(event, mapid = nil)
  mapid ||= event.map.map_id if event.respond_to?(:map)
  pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
  for i in 0...pages.size
    c = pages[pages.size - 1 - i].condition
    ss = !(c.self_switch_valid && !$game_self_switches[[mapid,
        event.id,c.self_switch_ch]])
    sw1 = !(c.switch1_valid && !$game_switches[c.switch1_id])
    sw2 = !(c.switch2_valid && !$game_switches[c.switch2_id])
    var = true
    if c.variable_valid
      if !c.variable_value || !$game_variables[c.variable_id].is_a?(Numeric) ||
         $game_variables[c.variable_id] < c.variable_value
        var = false
      end
    end
    if ss && sw1 && sw2 && var # All conditions are met
      return pages[pages.size - 1 - i]
    end
  end
  return nil
end



class TextSprite < Sprite
  # Sets up the sprite and bitmap. You can also pass text to draw
  # either an array of arrays, or an array containing the normal "parameters"
  # for drawing text:
  # [text,x,y,align,basecolor,shadowcolor]
  def initialize(viewport = nil, text = nil, width = -1, height = -1)
    super(viewport)
    @width = width
    @height = height
    self.bmp(@width, @height)
    pbSetSystemFont(self.bmp)
    if text.is_a?(Array)
      if text[0].is_a?(Array)
        pbDrawTextPositions(self.bmp,text)
      else
        pbDrawTextPositions(self.bmp,[text])
      end
    end
  end
  
  # Clears the bitmap (and thus all drawn text)
  def clear
    self.bmp.clear
    pbSetSystemFont(self.bmp)
  end
  
  # You can also pass text to draw either an array of arrays, or an array
  # containing the normal "parameters" for drawing text:
  # [text,x,y,align,basecolor,shadowcolor]
  def draw(text, clear = false)
    self.clear if clear
    if text[0].is_a?(Array)
      pbDrawTextPositions(self.bmp,text)
    else
      pbDrawTextPositions(self.bmp,[text])
    end
  end
  
  # Draws text with outline
  # [text,x,y,align,basecolor,shadowcolor]
  def draw_outline(text, clear = false)
    self.clear if clear
    if text[0].is_a?(Array)
      for e in text
        pbDrawOutlineText(self.bmp,e[1],e[2],640,480,e[0],e[4],e[5],e[3])
      end
    else
      e = text
      pbDrawOutlineText(self.bmp,e[1],e[2],640,480,e[0],e[4],e[5],e[3])
    end
  end
  
  # Draws and breaks a line if the width is exceeded
  # [text,x,y,width,numlines,basecolor,shadowcolor]
  def draw_ex(text, clear = false)
    self.clear if clear
    if text[0].is_a?(Array)
      for e in text
        drawTextEx(self.bmp,e[1],e[2],e[3],e[4],e[0],e[5],e[6])
      end
    else
      e = text
      drawTextEx(self.bmp,e[1],e[2],e[3],e[4],e[0],e[5],e[6])
    end
  end
  
  # Clears and disposes the sprite
  def dispose
    clear
    super
  end
end




end # if USING_MARIN_UTILITY