# Temporary screens. Control Screen should be implemented in Option Screen when
# it is ready
#===============================================================================
#
#===============================================================================
class UI::ControlVisualsList < Window_DrawableCommand
  attr_writer :custom_control_base_color, :custom_control_shadow_color
  attr_writer :extra_control_base_color, :extra_control_shadow_color
  
  def initialize(x, y, width, height, input_icons_bitmap, viewport)
    @sorted_actions = PokemonSystem::ACTION_INPUT.keys
    @sorted_actions.sort_by! { |action| PokemonSystem::ACTION_INPUT[action][:order] || @sorted_actions.index(action) }
    @input_icons_bitmap = input_icons_bitmap
    super(x, y, width, height, viewport)
  end

  #-----------------------------------------------------------------------------

  def itemCount
    return @sorted_actions.size + 1
  end

  def current_action
    return @sorted_actions[@index]
  end

  def on_exit_index?
    return @sorted_actions.size == @index
  end
  
  def item_description
    return on_exit_index? ? _INTL("Exit.") : PokemonSystem::ACTION_INPUT[current_action][:description]
  end

  #-----------------------------------------------------------------------------

  # Return text with custom controls (or extra controls, when show_custom was false).
  # Never show gamepad controls. 
  def key_text(action, show_custom)
    code_array = $PokemonSystem.filtered_control_array_hash(
      include_custom: show_custom, include_extra: !show_custom, include_gamepad: false)[action]
    return "" if code_array.nil?
    return Keys.key_name_array(code_array).join(", ")
  end

  def drawItem(index, count, rect)
    rect = drawCursor(index, rect)
    if index == @sorted_actions.size
      rect = draw_icon(nil, rect)
      rect = draw_action_name(_INTL("Exit"), rect)
      return
    end
    rect = draw_icon(PokemonSystem::ACTION_INPUT[@sorted_actions[index]][:icon_position], rect)
    rect = draw_action_name(PokemonSystem::ACTION_INPUT[@sorted_actions[index]][:name], rect)
    rect = draw_extra_control(key_text(@sorted_actions[index], false), rect)
    rect = draw_custom_control(key_text(@sorted_actions[index], true), rect)
  end

  def draw_icon(icon_index, rect)
    if !icon_index.nil?
      self.contents.blt(rect.x,rect.y+2, @input_icons_bitmap.bitmap, 
                        Rect.new(icon_index * @input_icons_bitmap.bitmap.height, 0, 
                                 @input_icons_bitmap.bitmap.height, @input_icons_bitmap.bitmap.height))
    end
    rect.x += @input_icons_bitmap.bitmap.height + 4
    return rect
  end

  def draw_action_name(string, rect)
    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height,
                     string, self.baseColor, self.shadowColor)
    rect.x += rect.width*7/20
    return rect
  end

  def draw_extra_control(string, rect)
    return rect if string == ""
    string = _INTL("{1}, ", string) if string!=""
    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height,
                     string, @extra_control_base_color, @extra_control_shadow_color)
    rect.x += self.contents.text_size(string).width 
    return rect
  end

  def draw_custom_control(string, rect)
    return rect if string == ""
    pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height,
                     string, @custom_control_base_color, @custom_control_shadow_color)
    return rect
  end

  def update
    old_index = self.index
    super
    refresh if self.index != old_index
  end
end

#===============================================================================
#
#===============================================================================
class UI::ControlsVisuals < UI::BaseVisuals
  TEXT_COLOR_THEMES = {   # Themes not in DEFAULT_TEXT_COLOR_THEMES
    :custom_control => [Color.new(248,48,24),  Color.new(248,136,128)],
    :extra_control  => [Color.new(24,112,216), Color.new(136,168,208)] # Extra controls are the non-changeable ones
  }

  def initialize
    @last_index = -1
    super
  end

  def initialize_sprites
    @sprites[:title]  = Window_UnformattedTextPokemon.newWithSize(_INTL("Controls"), 0, 0, Graphics.width, 64, @viewport)
    @sprites[:speech_box].visible = true
    @sprites[:speech_box].letterbyletter = false
    initialize_control_list
  end

  def initialize_control_list
    @sprites[:control_list] = UI::ControlVisualsList.new(
      0, @sprites[:title].height, Graphics.width, Graphics.height - @sprites[:title].height - @sprites[:speech_box].height, 
      @bitmaps[:input_icons], @viewport) 
    @sprites[:control_list].baseColor                   = get_text_color_theme(:black)[0]
    @sprites[:control_list].shadowColor                 = get_text_color_theme(:black)[1]
    @sprites[:control_list].custom_control_base_color   = get_text_color_theme(:custom_control)[0]
    @sprites[:control_list].custom_control_shadow_color = get_text_color_theme(:custom_control)[1]
    @sprites[:control_list].extra_control_base_color    = get_text_color_theme(:extra_control)[0]
    @sprites[:control_list].extra_control_shadow_color  = get_text_color_theme(:extra_control)[1]
    @sprites[:control_list].refresh
    @sprites[:control_list].visible = true
    @sprites[:control_list].active = false
  end
  
  def initialize_background; end
  def initialize_overlay; end
  
  #-----------------------------------------------------------------------------

  def index
    return @sprites[:control_list].index
  end

  def current_action
    return @sprites[:control_list].current_action
  end

  def update_input
    refresh_on_index_changed(@last_index) if index != @last_index
    # Check for interaction
    if Input.trigger?(Input::USE)
      return update_interaction(Input::USE)
    elsif Input.trigger?(Input::BACK)
      return update_interaction(Input::BACK)
    end
    return nil
  end

  def update_interaction(input)
    case input
    when Input::USE
      return :quit if @sprites[:control_list].on_exit_index?
      pbPlayDecisionSE
      refresh_speech_box(:insert_input)
      @sprites[:control_list].active = false
      return :assign_input
    when Input::BACK
      return :quit
    end
    return nil
  end

  def on_valid_new_input
    activate_control_list
    pbPlayDecisionSE
  end
  
  def on_invalid_new_input
    pbPlayBuzzerSE
    @sprites[:control_list].refresh
    refresh_speech_box(:invalid_input)
  end

  def on_cancel_new_input
    activate_control_list
    pbPlayCancelSE
  end

  def activate_control_list
    @sprites[:control_list].active = true
    @sprites[:control_list].refresh
    refresh_speech_box
  end

  def refresh_on_index_changed(old_index)
    refresh_speech_box
    @last_index = index
  end

  def refresh_speech_box(mode=nil)
    @sprites[:speech_box].text = case mode
      when :insert_input    then  _INTL("Press a new key.")
      when :invalid_input   then  _INTL("This key was already used. Press a new key.")
      else                        @sprites[:control_list].item_description
    end
  end
  
  def navigate
    @sprites[:control_list].active = true
    ret = super
    @sprites[:control_list].active = false
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class UI::Controls < UI::BaseScreen
  ACTIONS = HandlerHash.new

  def initialize_visuals
    @visuals = UI::ControlsVisuals.new
  end

  ACTIONS.add(:assign_input, {
    :effect => proc { |screen|
      screen.assign_input
    }
  })

  def assign_input
    input = nil
    loop do
      input = Keys.detect_key(false){ @visuals.update }
      if $PokemonSystem.customizable_control_hash[@visuals.current_action] == input || !already_has_input?(input)
        break 
      end
      if is_cancel_input?(input)
        @visuals.on_cancel_new_input
        return
      end
      @visuals.on_invalid_new_input
    end
    $PokemonSystem.customizable_control_hash[@visuals.current_action] = input
    $PokemonSystem.refresh_control_array_hash
    @visuals.on_valid_new_input
  end

  def already_has_input?(code)
    return $PokemonSystem.control_array_hash.values.flatten.include?(code)
  end

  def is_cancel_input?(code)
    return $PokemonSystem.control_array_hash[:cancel].include?(code)
  end
  
  def end_screen
    pbPlayCloseMenuSE
    super
  end
end

# Temporary method for testing. Remove before release
def open_controls_ui
  pbFadeOutIn do
    UI::Controls.new.main
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSystem
  ENABLE_CUSTOM_CONTROLS = true # When false, use controls defined in F1. Remember to edit mkxp.json
  ACTION_INPUT = HandlerHash.new 

  @@control_array_hash = {} # So temporary data wouldn't be stored in the save.
  
  attr_accessor :customizable_control_hash # Hash with action per control code. Manually set it to nil to reset the controls

  # Used hash for the controls, including gamepad and fixed controls.
  def control_array_hash
    refresh_control_array_hash if @@control_array_hash.empty?
    return @@control_array_hash
  end

  def refresh_control_array_hash
    # Customizable controls
    if @customizable_control_hash.nil?
      @customizable_control_hash = {}
      for action in ACTION_INPUT.keys
        @customizable_control_hash[action] = Keys.key_code(ACTION_INPUT[action][:customizable_key])
      end
    end

    # Non-customizable/extra controls
    @@control_array_hash = {}
    for action in ACTION_INPUT.keys
      @@control_array_hash[action] = ACTION_INPUT[action][:keys].map{|name| Keys.key_code(name)}
    end

    for key in @customizable_control_hash.keys
      next if !@@control_array_hash.has_key?(key)
      next if @@control_array_hash[key].include?(@customizable_control_hash[key])
      @@control_array_hash[key].push(@customizable_control_hash[key])
    end
  end

  # Used to return a hash with different controls info.
  # Extra keys means non-custom keys.
  # Calling 
  #  Keys.key_name_array($PokemonSystem.filtered_control_array_hash(include_keyboard: false)[:up])
  # returns an array with only "up" gamepad keys. This can be used to display controls in-game. 
  def filtered_control_array_hash(include_extra: true, include_custom: true, include_keyboard: true, include_gamepad: true)
    ret = {}
    for key in control_array_hash.keys
      array = []
      for code in control_array_hash[key]
        if code >= Input::GAMEPAD_OFFSET
          next if !include_gamepad
        else
          next if !include_keyboard
        end
        if @customizable_control_hash.values.include?(code)
          next if !include_custom
        else
          next if !include_extra
        end
        array.push(code)
      end
      ret[key] = array if !array.empty?
    end
    return ret
  end

  def convert_hash_name_to_code(hash)
    return hash.map{|key, name| [key, Keys.key_code(name)]}.to_h
  end

  def convert_hash_name_array_to_code(hash)
    return hash.map{|key, array| [key, array.map{|name| Keys.key_code(name)}]}.to_h
  end
end

#===============================================================================
#
#===============================================================================
module Input
  AXIS_ENABLED = true

  # Used offsets to support the same variable for both gamepad and keyboard.
  GAMEPAD_OFFSET = 500
  AXIS_OFFSET = 100 + GAMEPAD_OFFSET
  AXIS_THRESHOLD = 0.5
  AXIS_REPEAT_INITIAL_DELAY = 0.5
  AXIS_REPEAT_DELAY = 0.1

  # Using this for manual check
  LEFT_STICK_LEFT   = 0x00
  LEFT_STICK_RIGHT  = 0x01
  LEFT_STICK_UP     = 0x02
  LEFT_STICK_DOWN   = 0x03
  RIGHT_STICK_LEFT  = 0x04
  RIGHT_STICK_RIGHT = 0x05
  RIGHT_STICK_UP    = 0x06
  RIGHT_STICK_DOWN  = 0x07
  LEFT_TRIGGER      = 0x09
  RIGHT_TRIGGER     = 0x0B
  AXIS_COUNT        = RIGHT_TRIGGER+1

  class << self
    if !method_defined?(:__controls_press?)
      alias :__controls_press? :press?
      def press?(button)
        key = button_to_key(button)
        return key ? pressex_array?(key) : __controls_press?(button)
      end

      alias :__controls_trigger? :trigger?
      def trigger?(button)
        key = button_to_key(button)
        return key ? triggerex_array?(key) : __controls_trigger?(button)
      end

      alias :__controls_repeat? :repeat?
      def repeat?(button)
        key = button_to_key(button)
        return key ? repeatex_array?(key) : __controls_repeat?(button)
      end

      alias :__controls_release? :release?
      def release?(button)
        key = button_to_key(button)
        return key ? releaseex_array?(key) : __controls_release?(button)
      end
    end

    def pressex_array?(array)
      for item in array
        if item >= AXIS_OFFSET 
          return true if axis_pressex?(item - AXIS_OFFSET)
        elsif item >= GAMEPAD_OFFSET
          return true if Controller.pressex?(item - GAMEPAD_OFFSET)
        else
          return true if pressex?(item)
        end
      end
      return false
    end

    def triggerex_array?(array)
      for item in array
        if item >= AXIS_OFFSET 
          return true if axis_triggerex?(item - AXIS_OFFSET)
        elsif item >= GAMEPAD_OFFSET
          return true if Controller.triggerex?(item - GAMEPAD_OFFSET)
        else
          return true if triggerex?(item)
        end
      end
      return false
    end

    def repeatex_array?(array)
      for item in array
        if item >= AXIS_OFFSET 
          # Trigger is checked in axis_repeatex?
          return true if axis_repeatex?(item - AXIS_OFFSET)
        elsif item >= GAMEPAD_OFFSET
          return true if Controller.repeatex?(item - GAMEPAD_OFFSET)
          return true if Controller.triggerex?(item - GAMEPAD_OFFSET)
        else
          return true if repeatex?(item)
          return true if triggerex?(item)
        end
      end
      return false
    end

    def releaseex_array?(array)
      for item in array
        if item >= AXIS_OFFSET 
          return true if axis_releaseex?(item - AXIS_OFFSET)
        elsif item >= GAMEPAD_OFFSET
          return true if Controller.releaseex?(item - GAMEPAD_OFFSET)
        else
          return true if releaseex?(item)
        end
      end
      return false
    end

    def dir4
      return 0 if press?(DOWN) && press?(UP)
      return 0 if press?(LEFT) && press?(RIGHT)
      for button in [DOWN,LEFT,RIGHT,UP]
        return button if press?(button)
      end
      return 0
    end

    def dir8
      buttons = []
      for b in [DOWN,LEFT,RIGHT,UP]
        buttons.push(b) if press?(b)
      end
      if buttons.length==0
        return 0
      elsif buttons.length==1
        return buttons[0]
      elsif buttons.length==2
        return 0 if (buttons[0]==DOWN && buttons[1]==UP)
        return 0 if (buttons[0]==LEFT && buttons[1]==RIGHT)
      end
      up_down    = 0
      left_right = 0
      for b in buttons
        up_down    = b if up_down==0 && (b==UP || b==DOWN)
        left_right = b if left_right==0 && (b==LEFT || b==RIGHT)
      end
      if up_down==DOWN
        return 1 if left_right==LEFT
        return 3 if left_right==RIGHT
        return 2
      elsif up_down==UP
        return 7 if left_right==LEFT
        return 9 if left_right==RIGHT
        return 8
      else
        return 4 if left_right==LEFT
        return 6 if left_right==RIGHT
        return 0
      end
    end

    def button_to_key(button)
      $PokemonSystem ||= PokemonSystem.new
      return case button
        when Input::DOWN
          $PokemonSystem.control_array_hash[:down]
        when Input::LEFT
          $PokemonSystem.control_array_hash[:left]
        when Input::RIGHT
          $PokemonSystem.control_array_hash[:right]
        when Input::UP
          $PokemonSystem.control_array_hash[:up]
        when Input::USE
          $PokemonSystem.control_array_hash[:use]
        when Input::BACK
          $PokemonSystem.control_array_hash[:cancel]
        when Input::ACTION
          $PokemonSystem.control_array_hash[:action]
        when Input::JUMPUP
          $PokemonSystem.control_array_hash[:jump_up]
        when Input::JUMPDOWN
          $PokemonSystem.control_array_hash[:jump_down]
        else
          nil
      end
    end

    @@axis_states = Array.new(AXIS_COUNT, false)
    @@axis_states_old      = @@axis_states.clone
    @@axis_states_trigger  = @@axis_states.clone
    @@axis_states_repeat   = @@axis_states.clone
    @@axis_states_release  = @@axis_states.clone
    @@axis_states_trigger_time = Array.new(@@axis_states.size, 0.0)
    @@axis_states_repeat_time = Array.new(@@axis_states.size, 0.0)
    
    def refresh_axis_array
      for i in 0...@@axis_states.size
        @@axis_states_old[i] = @@axis_states[i]
        @@axis_states[i] = axis_state(i) > AXIS_THRESHOLD
        @@axis_states_trigger[i] =  @@axis_states[i] && !@@axis_states_old[i]
        @@axis_states_release[i] = !@@axis_states[i] &&  @@axis_states_old[i]
        @@axis_states_trigger_time[i] = System.uptime if @@axis_states_trigger[i]
        @@axis_states_repeat[i] = @@axis_states_trigger[i] || (
          @@axis_states[i] && (
            System.uptime >= @@axis_states_trigger_time[i] + AXIS_REPEAT_INITIAL_DELAY
          ) && System.uptime >= @@axis_states_repeat_time[i] + AXIS_REPEAT_DELAY
        )
        @@axis_states_repeat_time[i] = System.uptime if @@axis_states_repeat[i]
      end
    end
    
    def axis_state(key)
      return case key
        when LEFT_STICK_LEFT;   -Controller.axes_left[0]    
        when LEFT_STICK_RIGHT;   Controller.axes_left[0] 
        when LEFT_STICK_UP;     -Controller.axes_left[1]
        when LEFT_STICK_DOWN;    Controller.axes_left[1]
        when RIGHT_STICK_LEFT;  -Controller.axes_right[0]
        when RIGHT_STICK_RIGHT;  Controller.axes_right[0]
        when RIGHT_STICK_UP;    -Controller.axes_right[1]
        when RIGHT_STICK_DOWN;   Controller.axes_right[1]
        when LEFT_TRIGGER;       Controller.axes_trigger[0]
        when RIGHT_TRIGGER;      Controller.axes_trigger[1]
        else 0
      end
    end

    def axis_pressex?(index)
      return @@axis_states[index] 
    end

    def axis_triggerex?(index)
      return @@axis_states_trigger[index] 
    end

    def axis_repeatex?(index)
      return @@axis_states_repeat[index] 
    end

    def axis_releaseex?(index)
      return @@axis_states_release[index] 
    end

    # For compatibility with other scripts, use update_KGC_ScreenCapture
    # instead of Input.update
    if AXIS_ENABLED && defined?(Controller) && !method_defined?(:__controls_update_kgc)
      alias :__controls_update_kgc :update_KGC_ScreenCapture
      def update_KGC_ScreenCapture
        __controls_update_kgc
        refresh_axis_array
      end
    end
  end
end if PokemonSystem::ENABLE_CUSTOM_CONTROLS

#===============================================================================
# Keys and buttons here.
# Comment a line in a hash to disable a key/button, but remember to remove it
# from the default controls as well.
#===============================================================================
module Keys
  # Available keys in keyboard.
  KEYBOARD_LIST = {
    # Mouse buttons
    "Backspace"    => 0x08,
    "Tab"          => 0x09,
    "Clear"        => 0x0C,
    "Enter"        => 0x0D,
    "Shift"        => 0x10,
    "Ctrl"         => 0x11,
    "Alt"          => 0x12,
    "Pause"        => 0x13,
    # IME keys
    "Caps Lock"    => 0x14,
    "Esc"          => 0x1B,
    "Space"        => 0x20,
    "Page Up"      => 0x21,
    "Page Down"    => 0x22,
    "End"          => 0x23,
    "Home"         => 0x24,
    "Left"         => 0x25,
    "Up"           => 0x26,
    "Right"        => 0x27,
    "Down"         => 0x28,
    "Select"       => 0x29,
    "Print"        => 0x2A,
    "Execute"      => 0x2B,
    "Print Screen" => 0x2C,
    "Insert"       => 0x2D,
    "Delete"       => 0x2E,
    "Help"         => 0x2F,
    "0"            => 0x30,
    "1"            => 0x31,
    "2"            => 0x32,
    "3"            => 0x33,
    "4"            => 0x34,
    "5"            => 0x35,
    "6"            => 0x36,
    "7"            => 0x37,
    "8"            => 0x38,
    "9"            => 0x39,
    "A"            => 0x41,
    "B"            => 0x42,
    "C"            => 0x43,
    "D"            => 0x44,
    "E"            => 0x45,
    "F"            => 0x46,
    "G"            => 0x47,
    "H"            => 0x48,
    "I"            => 0x49,
    "J"            => 0x4A,
    "K"            => 0x4B,
    "L"            => 0x4C,
    "M"            => 0x4D,
    "N"            => 0x4E,
    "O"            => 0x4F,
    "P"            => 0x50,
    "Q"            => 0x51,
    "R"            => 0x52,
    "S"            => 0x53,
    "T"            => 0x54,
    "U"            => 0x55,
    "V"            => 0x56,
    "W"            => 0x57,
    "X"            => 0x58,
    "Y"            => 0x59,
    "Z"            => 0x5A,
    # Windows keys
    "Numpad 0"     => 0x60,
    "Numpad 1"     => 0x61,
    "Numpad 2"     => 0x62,
    "Numpad 3"     => 0x63,
    "Numpad 4"     => 0x64,
    "Numpad 5"     => 0x65,
    "Numpad 6"     => 0x66,
    "Numpad 7"     => 0x67,
    "Numpad 8"     => 0x68,
    "Numpad 9"     => 0x69,
    "Multiply"     => 0x6A,
    "Add"          => 0x6B,
    "Separator"    => 0x6C,
    "Subtract"     => 0x6D,
    "Decimal"      => 0x6E,
    "Divide"       => 0x6F,
    "F1"           => 0x70,
    "F2"           => 0x71,
    "F3"           => 0x72,
    "F4"           => 0x73,
    "F5"           => 0x74,
    "F6"           => 0x75,
    "F7"           => 0x76,
    "F8"           => 0x77,
    "F9"           => 0x78,
    "F10"          => 0x79,
    "F11"          => 0x7A,
    "F12"          => 0x7B,
    "F13"          => 0x7C,
    "F14"          => 0x7D,
    "F15"          => 0x7E,
    "F16"          => 0x7F,
    "F17"          => 0x80,
    "F18"          => 0x81,
    "F19"          => 0x82,
    "F20"          => 0x83,
    "F21"          => 0x84,
    "F22"          => 0x85,
    "F23"          => 0x86,
    "F24"          => 0x87,
    "Num Lock"     => 0x90,
    "Scroll Lock"  => 0x91,
    # Multiple position Shift, Ctrl and Menu keys
    ";:"           => 0xBA,
    "+"            => 0xBB,
    ","            => 0xBC,
    "-"            => 0xBD,
    "."            => 0xBE,
    "/?"           => 0xBF,
    "`~"           => 0xC0,
    "{"            => 0xDB,
    "\|"           => 0xDC,
    "}"            => 0xDD,
    "'\""          => 0xDE,
    "AX"           => 0xE1 # Japan only
  }

  # Available buttons at gamepad.
  GAMEPAD_LIST = {
    "Button A"       => 0x00,
    "Button B"       => 0x01,
    "Button X"       => 0x02,
    "Button Y"       => 0x03,
    "Button Back"    => 0x04,
    "Button Guide"   => 0x05,
    "Button Start"   => 0x06,
    "Left Stick"     => 0x07,
    "Right Stick"    => 0x08,
    "Left Shoulder"  => 0x09,
    "Right Shoulder" => 0x0A,
    "D-Pad Up"       => 0x0B,
    "D-Pad Down"     => 0x0C,
    "D-Pad Left"     => 0x0D,
    "D-Pad Right"    => 0x0E,
    # The below ones are commented since they aren't working properly in the 2025 mkxp-z version.
#   "Button Misc"    => 0x0F, # Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button
#   "Paddle 1"       => 0x10, # Xbox Elite paddle P1 (upper left, facing the back)
#   "Paddle 2"       => 0x11, # Xbox Elite paddle P3 (upper right, facing the back)
#   "Paddle 3"       => 0x12, # Xbox Elite paddle P2 (lower left, facing the back)
#   "Paddle 4"       => 0x13, # Xbox Elite paddle P4 (lower right, facing the back)
#   "Touchpad"       => 0x14, # PS4/PS5 touchpad button
  }

  # Available axis at gamepad.
  # This one is manually checked
  GAMEPAD_AXIS_LIST = {
    "L-Stick Left"   => Input::LEFT_STICK_LEFT,
    "L-Stick Right"  => Input::LEFT_STICK_RIGHT,
    "L-Stick Up"     => Input::LEFT_STICK_UP,
    "L-Stick Down"   => Input::LEFT_STICK_DOWN,
    "RStick Left"    => Input::RIGHT_STICK_LEFT,
    "RStick Right"   => Input::RIGHT_STICK_RIGHT,
    "RStick Up"      => Input::RIGHT_STICK_UP,
    "RStick Down"    => Input::RIGHT_STICK_DOWN,
    "Left Trigger"   => Input::LEFT_TRIGGER,
    "Right Trigger"  => Input::RIGHT_TRIGGER,
  }

  def self.key_name(key_code)
    ret = KEYBOARD_LIST.key(key_code)
    return ret if ret
    ret = GAMEPAD_LIST.key(key_code - Input::GAMEPAD_OFFSET)
    return ret if ret
    ret = GAMEPAD_AXIS_LIST.key(key_code - Input::AXIS_OFFSET)
    return ret if ret
    return key_code==0 ? "None" : "?"
  end 

  def self.key_code(key_name)
    ret  = KEYBOARD_LIST[key_name]
    if !ret && GAMEPAD_LIST.has_key?(key_name)
      ret  = GAMEPAD_LIST[key_name] + Input::GAMEPAD_OFFSET
    end
    if !ret && GAMEPAD_AXIS_LIST.has_key?(key_name)
      ret  = GAMEPAD_AXIS_LIST[key_name] + Input::AXIS_OFFSET
    end
    raise "The key #{key_name} no longer exists! " if !ret
    return ret
  end 

  def self.key_name_array(key_code_array)
    return key_code_array.map{|code| _INTL(key_name(code))}
  end 

  def self.detect_key(include_gamepad)
    loop do
      Graphics.update
      Input.update
      yield if block_given?
      for key_code in KEYBOARD_LIST.values
        next if !Input.triggerex?(key_code)
        return key_code
      end
      if include_gamepad && Input.const_defined?(:Controller)
        for original_code in GAMEPAD_LIST.values
          next if !Input::Controller.triggerex?(original_code)
          return original_code + Input::GAMEPAD_OFFSET 
        end
        for original_code in GAMEPAD_AXIS_LIST.values
          next if !Input.axis_triggerex?(original_code)
          return original_code + Input::AXIS_OFFSET 
        end
      end
    end
  end
end if PokemonSystem::ENABLE_CUSTOM_CONTROLS

# When including inputs, don't forget to add an input constant (like Input::USE)
# and link it in button_to_key

PokemonSystem::ACTION_INPUT.add(:down, {
  :name             => _INTL("Down"),
  :order            => 0,
  :icon_position    => 0,
  :description      => _INTL("Moves the character. Select entries and navigate menus."),
  :keys             => ["Down","D-Pad Down","L-Stick Down"],
  :customizable_key => "Numpad 2",
})

PokemonSystem::ACTION_INPUT.add(:left, {
  :name             => _INTL("Left"),
  :order            => 1,
  :icon_position    => 0,
  :description      => _INTL("Moves the character. Select entries and navigate menus."),
  :keys             => ["Left","D-Pad Left","L-Stick Left"],
  :customizable_key => "Numpad 4",
})

PokemonSystem::ACTION_INPUT.add(:right, {
  :name             => _INTL("Right"),
  :order            => 2,
  :icon_position    => 0,
  :description      => _INTL("Moves the character. Select entries and navigate menus."),
  :keys             => ["Right", "D-Pad Right", "L-Stick Right"],
  :customizable_key => "Numpad 6",
})

PokemonSystem::ACTION_INPUT.add(:up, {
  :name             => _INTL("Up"),
  :order            => 3,
  :icon_position    => 0,
  :description      => _INTL("Moves the character. Select entries and navigate menus."),
  :keys             => ["Up", "D-Pad Up","L-Stick Up"],
  :customizable_key => "Numpad 8",
})

PokemonSystem::ACTION_INPUT.add(:use, {
  :name             => _INTL("Use"),
  :order            => 4,
  :icon_position    => 0,
  :description      => _INTL("Confirm choices, check things, talk to people, and move through text."),
  :keys             => ["Enter", "Button A"],
  :customizable_key => "C",
})

PokemonSystem::ACTION_INPUT.add(:cancel, {
  :name             => _INTL("Cancel"),
  :order            => 5,
  :icon_position    => 1,
  :description      => _INTL("Exit, cancel a choice or mode, and move at field in a different speed."),
  :keys             => ["Esc", "Button B"],
  :customizable_key => "X",
})

PokemonSystem::ACTION_INPUT.add(:action, {
  :name             => _INTL("Action"),
  :order            => 6,
  :icon_position    => 2,
  :description      => _INTL("Open the menu. Also has various functions depending on context."),
  :keys             => ["Button X"],
  :customizable_key => "Z",
})

PokemonSystem::ACTION_INPUT.add(:jump_up, {
  :name             => _INTL("Jump Up"),
  :order            => 7,
  :icon_position    => 0,
  :description      => _INTL("Advance quickly in menus."),
  :keys             => ["Left Shoulder"],
  :customizable_key => "A",
})

PokemonSystem::ACTION_INPUT.add(:jump_down, {
  :name             => _INTL("Jump Down"),
  :order            => 8,
  :icon_position    => 0,
  :description      => _INTL("Advance quickly in menus."),
  :keys             => ["Right Shoulder"],
  :customizable_key => "S",
})