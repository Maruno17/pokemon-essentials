#===============================================================================
#
#===============================================================================
module Input
  # NOTE: If you add a brand new input (and not just an alternate name of an
  #       existing input like the ones below), you will need to make it equal to
  #       a number (e.g. NEWINPUT = 42). The numbers used are all listed below,
  #       so use a different one.
#  DOWN  = 2
#  LEFT  = 4
#  RIGHT = 6
#  UP    = 8
  ACTION                = A   # 11
  BACK                  = B   # 12
  USE                   = C   # 13
  QUICK_UP   = JUMPUP   = X   # 14
  QUICK_DOWN = JUMPDOWN = Y   # 15
#  Z = 16
#  L = 17
#  R = 18
# 19 and 20 are unused.
#  SHIFT = 21
#  CTRL  = 22
#  ALT   = 23
# 24 is unused.
#  F5 = 25
#  F6 = 26
#  F7 = 27
#  F8 = 28
#  F9 = 29
# 30-37 are unused.
#  MOUSELEFT   = 38
#  MOUSEMIDDLE = 39
#  MOUSERIGHT  = 40
#  MOUSEX1     = 41
#  MOUSEX2     = 42
# 43 and higher are unused.

  # This lists all remappable inputs (written as Input::SOMETHING throughout the
  # code) with their keys. These keys cannot be remapped. The second array is
  # for gamepad buttons/axis.
  # Keys are SDL scancodes (https://wiki.libsdl.org/SDL3/SDL_Scancode) minus the
  # "SDL_SCANCODE_" beginning part.
  DEFAULT_INPUT_MAPPINGS = {
    self::UP         => [[:UP], [:LSTICK_UP, :RSTICK_UP]],
    self::DOWN       => [[:DOWN], [:LSTICK_DOWN, :RSTICK_DOWN]],
    self::LEFT       => [[:LEFT], [:LSTICK_LEFT, :RSTICK_LEFT]],
    self::RIGHT      => [[:RIGHT], [:LSTICK_RIGHT, :RSTICK_RIGHT]],
    self::USE        => [[:SPACE, :RETURN], []],
    self::BACK       => [[:ESCAPE], []],
    self::ACTION     => [[:BACKSPACE], []],
    self::QUICK_UP   => [[:PAGEUP], []],
    self::QUICK_DOWN => [[:PAGEDOWN], []]
  }
  # This lists all remappable inputs (written as Input::SOMETHING throughout the
  # code) with their remappable keys and gamepad buttons.
  # Each input's array is of length 2, where the first value is a keyboard key
  # and the second value is a gamepad button. One of each is all the Options
  # screen supports.
  # Keys are SDL scancodes (https://wiki.libsdl.org/SDL3/SDL_Scancode) minus the
  # "SDL_SCANCODE_" beginning part.
  DEFAULT_INPUT_MAPPINGS_REMAPPABLE = {
    self::UP         => [nil, :DPAD_UP],
    self::DOWN       => [nil, :DPAD_DOWN],
    self::LEFT       => [nil, :DPAD_LEFT],
    self::RIGHT      => [nil, :DPAD_RIGHT],
    self::USE        => [:C, :A],
    self::BACK       => [:X, :B],
    self::ACTION     => [:Z, :X],
    self::QUICK_UP   => [:A, :LEFTSHOULDER],
    self::QUICK_DOWN => [:S, :RIGHTSHOULDER],
  }

  # All keyboard keys that can be mapped to an input by the player.
  # Keys are SDL scancodes (https://wiki.libsdl.org/SDL3/SDL_Scancode) minus the
  # "SDL_SCANCODE_" beginning part.
  # The exception are the number keys which are the Windows Virtual-Key codes
  # (https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes)
  # for them because symbols that are just a number aren't allowed.
  REMAP_KEYBOARD_KEYS = {
    :A => "A", :B => "B", :C => "C", :D => "D", :E => "E", :F => "F", :G => "G",
    :H => "H", :I => "I", :J => "J", :K => "K", :L => "L", :M => "M", :N => "N",
    :O => "O", :P => "P", :Q => "Q", :R => "R", :S => "S", :T => "T", :U => "U",
    :V => "V", :W => "W", :X => "X", :Y => "Y", :Z => "Z",
    0x30 => "0", 0x31 => "1", 0x32 => "2", 0x33 => "3", 0x34 => "4",
    0x35 => "5", 0x36 => "6", 0x37 => "7", 0x38 => "8", 0x39 => "9",
    :GRAVE        => "`",
    :TAB          => _INTL("Tab"),
    :CAPSLOCK     => _INTL("Caps Lock"),
    :BACKSLASH    => "\\",   # Actually #~ in UK
    :LSHIFT       => _INTL("L. Shift"),
    :LCTRL        => _INTL("L. Ctrl"),
    :LALT         => _INTL("L. Alt"),
    :MINUS        => "-",
    :EQUALS       => "=",
    :LEFTBRACKET  => "[",
    :RIGHTBRACKET => "]",
    :SEMICOLON    => ";",
    :APOSTROPHE   => "'",
    :NONUSHASH    => "#",
    :COMMA        => ",",
    :PERIOD       => ".",
    :SLASH        => "/",
    :RSHIFT       => _INTL("R. Shift"),
    :RCTRL        => _INTL("R. Ctrl"),
    :RALT         => _INTL("R. Alt"),
    :HOME         => _INTL("Home"),
    :END          => _INTL("End"),
    :INSERT       => _INTL("Insert"),
    :DELETE       => _INTL("Delete"),
    :KP_1 => _INTL("Num 1"), :KP_2 => _INTL("Num 2"),
    :KP_3 => _INTL("Num 3"), :KP_4 => _INTL("Num 4"),
    :KP_5 => _INTL("Num 5"), :KP_6 => _INTL("Num 6"),
    :KP_7 => _INTL("Num 7"), :KP_8 => _INTL("Num 8"),
    :KP_9 => _INTL("Num 9"), :KP_0 => _INTL("Num 0"),
    :KP_DIVIDE    => _INTL("Num /"),
    :KP_MULTIPLY  => _INTL("Num *"),
    :KP_MINUS     => _INTL("Num -"),
    :KP_PLUS      => _INTL("Num +"),
    :KP_ENTER     => _INTL("Num Enter"),
    :KP_PERIOD    => _INTL("Num .")
  }
  # All gamepad buttons that can be mapped to an input by the player.
  # Buttons are SDL Controller Button codes
  # (https://wiki.libsdl.org/SDL2/SDL_GameControllerButton) minus the
  # "SDL_CONTROLLER_BUTTON_" beginning part.
  REMAP_GAMEPAD_BUTTONS = {
    :DPAD_UP       => _INTL("D Up"),
    :DPAD_DOWN     => _INTL("D Down"),
    :DPAD_LEFT     => _INTL("D Left"),
    :DPAD_RIGHT    => _INTL("D Right"),
    :A => "A", :B => "B", :X => "X", :Y => "Y",
    :LEFTSTICK     => _INTL("L Stick"),
    :RIGHTSTICK    => _INTL("R Stick"),
    :LEFTSHOULDER  => _INTL("L Shoulder"),
    :RIGHTSHOULDER => _INTL("R Shoulder"),
    :BACK          => _INTL("Back"),
    :GUIDE         => _INTL("Guide"),
    :START         => _INTL("Start"),
#    :MISC1         => _INTL("Share/Mic"),
#    :PADDLE1       => _INTL("Paddle 1"),
#    :PADDLE2       => _INTL("Paddle 2"),
#    :PADDLE3       => _INTL("Paddle 3"),
#    :PADDLE4       => _INTL("Paddle 4"),
#    :TOUCHPAD      => _INTL("Touchpad"),
#    :MAX           => _INTL("Max")
  }

  REMAP_GAMEPAD_AXIS = {
#    :LSTICK_LEFT   => _INTL("L Stick Left"),
#    :LSTICK_RIGHT  => _INTL("L Stick Right"),
#    :LSTICK_UP     => _INTL("L Stick Up"),
#    :LSTICK_DOWN   => _INTL("L Stick Down"),
#    :RSTICK_LEFT   => _INTL("R Stick Left"),
#    :RSTICK_RIGHT  => _INTL("R Stick Right"),
#    :RSTICK_UP     => _INTL("R Stick Up"),
#    :RSTICK_DOWN   => _INTL("R Stick Down"),
    :LEFTTRIGGER   => _INTL("L Trigger"),
    :RIGHTTRIGGER  => _INTL("R Trigger"),
  }

  #-----------------------------------------------------------------------------

  # TODO: Maybe cache the return values of this method?
  def self.input_to_keys(input)
    ret = [DEFAULT_INPUT_MAPPINGS.dig(input, 0)&.clone || [], DEFAULT_INPUT_MAPPINGS.dig(input, 1)&.clone || []]
    if $PokemonSystem && $PokemonSystem.controls[input]
      ret[0].push($PokemonSystem.controls[input][0]) if $PokemonSystem.controls[input][0]
      ret[1].push($PokemonSystem.controls[input][1]) if $PokemonSystem.controls[input][1]
    end
    return (ret[0].empty? && ret[1].empty?) ? nil : ret
  end

  def self.input_name(input, type = :keyboard)
    case type
    when :keyboard
      return _INTL(REMAP_KEYBOARD_KEYS[input]) if REMAP_KEYBOARD_KEYS[input]
    when :gamepad
      if AXIS_HASH.key?(input)
        return _INTL(REMAP_GAMEPAD_AXIS[input]) if REMAP_GAMEPAD_AXIS[input]
      else
        return _INTL(REMAP_GAMEPAD_BUTTONS[input]) if REMAP_GAMEPAD_BUTTONS[input]
      end
    end
    return input.to_s
  end

  if !defined? __orig_press?
    class << self
      alias :__orig_press? :press?
      alias :__orig_trigger? :trigger?
      alias :__orig_repeat? :repeat?
      alias :__orig_release? :release?
    end
  end

  def self.press?(input)
    keys = input_to_keys(input)
    return (keys) ? multi_pressex?(*keys) : __orig_press?(input)
  end

  def self.trigger?(input)
    keys = input_to_keys(input)
    return (keys) ? multi_triggerex?(*keys) : __orig_trigger?(input)
  end

  def self.repeat?(input)
    keys = input_to_keys(input)
    return (keys) ? multi_repeatex?(*keys) : __orig_repeat?(input)
  end

  def self.release?(input)
    keys = input_to_keys(input)
    return (keys) ? multi_releaseex?(*keys) : __orig_release?(input)
  end



  def self.multi_pressex?(*key)
    return true if key[0].any? { |k| pressex?(k) }
    return true if key[1].any? { |k| AXIS_HASH.key?(k) ? axis_pressex?(k) : Controller.pressex?(k) }
    return false
  end

  def self.multi_triggerex?(*key)
    return true if key[0].any? { |k| triggerex?(k) }
    return true if key[1].any? { |k| AXIS_HASH.key?(k) ? axis_triggerex?(k) : Controller.triggerex?(k) }
    return false
  end

  def self.multi_repeatex?(*key)
    return true if key[0].any? { |k| triggerex?(k) || repeatex?(k) }
    return true if key[1].any? { |k| AXIS_HASH.key?(k) ? axis_triggerex?(k) || axis_repeatex?(k) : Controller.triggerex?(k) || Controller.repeatex?(k) }
    return false
  end

  def self.multi_releaseex?(*key)
    return true if key[0].any? { |k| releaseex?(k) }
    return true if key[1].any? { |k| AXIS_HASH.key?(k) ? axis_releaseex?(k) : Controller.releaseex?(k) }
    return false
  end

  #-----------------------------------------------------------------------------

  @@previous_dir4 = 0

  def self.dir4(moved_last_frame = false)
    # Get all direction inputs
    up = self.press?(UP)
    down = self.press?(DOWN)
    left = self.press?(LEFT)
    right = self.press?(RIGHT)
    # Cancel out opposing directions
    up = down = false if up && down
    left = right = false if left && right
    # Determine the return value
    ret = (down) ? DOWN : (up) ? UP : 0
    ret = (left) ? LEFT : (right) ? RIGHT : ret
    # Zigzag while moving
    if moved_last_frame
      case @@previous_dir4
      when UP, DOWN
        ret = (left) ? LEFT : (right) ? RIGHT : ret
      when LEFT, RIGHT
        ret = (down) ? DOWN : (up) ? UP : ret
      end
    end
    @@previous_dir4 = ret
    return ret
  end

  # In the order for DOWN, LEFT, RIGHT, UP.
  OTHER_DIRS = [
    [LEFT, RIGHT, UP],    # DOWN
    [DOWN, UP, RIGHT],    # LEFT
    [DOWN, UP, LEFT],     # RIGHT
    [LEFT, RIGHT, DOWN]   # UP
  ]
  # Which direction to return if there are two different direction keys being
  # pressed at once. In the order for DOWN, LEFT, RIGHT, UP, and then the
  # sub-arrays are in order OTHER_DIRS[i].
  DIR8_COMBOS = [
    [1, 3, 0],   # DOWN + [LEFT, RIGHT, UP]
    [1, 7, 0],   # LEFT + [DOWN, UP, RIGHT]
    [3, 9, 0],   # RIGHT + [DOWN, UP, LEFT]
    [7, 9, 0]    # UP + [LEFT, RIGHT, DOWN]
  ]

  def self.dir8
    [DOWN, LEFT, RIGHT, UP].each_with_index do |dir, i|
      next if !press?(dir)
      OTHER_DIRS[i].each_with_index do |other_dir, j|
        next if !press?(other_dir)
        return DIR8_COMBOS[i][j]
      end
      return dir
    end
    return 0
  end

  #-----------------------------------------------------------------------------

  # Custom approach for axis since there is no direct way to get this info,
  # unlike gamepad and keyboard.

  # When false, disable axis support. Remember to remove axis keys from
  # DEFAULT_INPUT_MAPPINGS.
  ENABLE_GAMEPAD_AXIS = true

  # Used hash for higher performance when checking keys.
  AXIS_HASH = ENABLE_GAMEPAD_AXIS ? [
    :LSTICK_LEFT, :LSTICK_RIGHT, :LSTICK_UP, :LSTICK_DOWN,
    :RSTICK_LEFT, :RSTICK_RIGHT, :RSTICK_UP, :RSTICK_DOWN,
    :LEFTTRIGGER, :RIGHTTRIGGER
  ].to_h { |value| [value, value] } : {}

  AXIS_THRESHOLD = 0.5
  AXIS_REPEAT_INITIAL_DELAY = 0.5
  AXIS_REPEAT_DELAY = 0.1

  @@axis_states          = {}
  @@axis_states_old      = {}
  @@axis_states_trigger  = {}
  @@axis_states_repeat   = {}
  @@axis_states_release  = {}
  @@axis_states_trigger_time = {}
  @@axis_states_repeat_time = {}
  
  def self.refresh_axis_array
    return if !ENABLE_GAMEPAD_AXIS
    for k in AXIS_HASH.keys
      @@axis_states_trigger_time[k] ||= 0
      @@axis_states_repeat_time[k] ||= 0
      @@axis_states_old[k] = @@axis_states[k]
      @@axis_states[k] = axis_state(k) > AXIS_THRESHOLD
      @@axis_states_trigger[k] =  @@axis_states[k] && !@@axis_states_old[k]
      @@axis_states_release[k] = !@@axis_states[k] &&  @@axis_states_old[k]
      @@axis_states_trigger_time[k] = System.uptime if @@axis_states_trigger[k]
      @@axis_states_repeat[k] = @@axis_states_trigger[k] || (
        @@axis_states[k] && (
          System.uptime >= @@axis_states_trigger_time[k] + AXIS_REPEAT_INITIAL_DELAY
        ) && System.uptime >= @@axis_states_repeat_time[k] + AXIS_REPEAT_DELAY
      )
      @@axis_states_repeat_time[k] = System.uptime if @@axis_states_repeat[k]
    end
  end
  
  def self.axis_state(key)
    return case key
      when :LSTICK_LEFT  then -Controller.axes_left[0]    
      when :LSTICK_RIGHT then  Controller.axes_left[0] 
      when :LSTICK_UP    then -Controller.axes_left[1]
      when :LSTICK_DOWN  then  Controller.axes_left[1]
      when :RSTICK_LEFT  then -Controller.axes_right[0]
      when :RSTICK_RIGHT then  Controller.axes_right[0]
      when :RSTICK_UP    then -Controller.axes_right[1]
      when :RSTICK_DOWN  then  Controller.axes_right[1]
      when :LEFTTRIGGER  then  Controller.axes_trigger[0]
      when :RIGHTTRIGGER then  Controller.axes_trigger[1]
      else 0
    end
  end

  def self.axis_pressex?(index)
    return @@axis_states[index] 
  end
  def self.axis_triggerex?(index)
    return @@axis_states_trigger[index] 
  end
  def self.axis_repeatex?(index)
    return @@axis_states_repeat[index] 
  end
  def self.axis_releaseex?(index)
    return @@axis_states_release[index] 
  end

  #-----------------------------------------------------------------------------

  if !defined? __screenshot_update
    class << Input
      alias __screenshot_update update
    end
  end

  def self.update
    __screenshot_update
    pbScreenCapture if trigger?(Input::F8)
    refresh_axis_array
  end
end

#===============================================================================
#
#===============================================================================
module Mouse
  # Returns the position of the mouse relative to the game window.
  def self.getMousePos(catch_anywhere = false)
    return nil unless Input.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end
