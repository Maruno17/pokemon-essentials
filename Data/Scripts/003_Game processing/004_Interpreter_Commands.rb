#===============================================================================
# ** Interpreter
#-------------------------------------------------------------------------------
#  This interpreter runs event commands. This class is used within the
#  Game_System class and the Game_Event class.
#===============================================================================
class Interpreter
  #-----------------------------------------------------------------------------
  # * Event Command Execution
  #-----------------------------------------------------------------------------
  def execute_command
    # Reached end of list of commands
    if @index >= @list.size - 1
      command_end
      return true
    end
    # Make current command's parameters available for reference via @parameters
    @parameters = @list[@index].parameters
    # Branch by command code
    case @list[@index].code
    when 101 then return command_101   # Show Text
    when 102 then return command_102   # Show Choices
    when 402 then return command_402   # When [**]
    when 403 then return command_403   # When Cancel
    when 103 then return command_103   # Input Number
    when 104 then return command_104   # Change Text Options
    when 105 then return command_105   # Button Input Processing
    when 106 then return command_106   # Wait
    when 111 then return command_111   # Conditional Branch
    when 411 then return command_411   # Else
    when 112 then return command_112   # Loop
    when 413 then return command_413   # Repeat Above
    when 113 then return command_113   # Break Loop
    when 115 then return command_115   # Exit Event Processing
    when 116 then return command_116   # Erase Event
    when 117 then return command_117   # Call Common Event
    when 118 then return command_118   # Label
    when 119 then return command_119   # Jump to Label
    when 121 then return command_121   # Control Switches
    when 122 then return command_122   # Control Variables
    when 123 then return command_123   # Control Self Switch
    when 124 then return command_124   # Control Timer
    when 125 then return command_125   # Change Gold
    when 126 then return command_126   # Change Items
    when 127 then return command_127   # Change Weapons
    when 128 then return command_128   # Change Armor
    when 129 then return command_129   # Change Party Member
    when 131 then return command_131   # Change Windowskin
    when 132 then return command_132   # Change Battle BGM
    when 133 then return command_133   # Change Battle End ME
    when 134 then return command_134   # Change Save Access
    when 135 then return command_135   # Change Menu Access
    when 136 then return command_136   # Change Encounter
    when 201 then return command_201   # Transfer Player
    when 202 then return command_202   # Set Event Location
    when 203 then return command_203   # Scroll Map
    when 204 then return command_204   # Change Map Settings
    when 205 then return command_205   # Change Fog Color Tone
    when 206 then return command_206   # Change Fog Opacity
    when 207 then return command_207   # Show Animation
    when 208 then return command_208   # Change Transparent Flag
    when 209 then return command_209   # Set Move Route
    when 210 then return command_210   # Wait for Move's Completion
    when 221 then return command_221   # Prepare for Transition
    when 222 then return command_222   # Execute Transition
    when 223 then return command_223   # Change Screen Color Tone
    when 224 then return command_224   # Screen Flash
    when 225 then return command_225   # Screen Shake
    when 231 then return command_231   # Show Picture
    when 232 then return command_232   # Move Picture
    when 233 then return command_233   # Rotate Picture
    when 234 then return command_234   # Change Picture Color Tone
    when 235 then return command_235   # Erase Picture
    when 236 then return command_236   # Set Weather Effects
    when 241 then return command_241   # Play BGM
    when 242 then return command_242   # Fade Out BGM
    when 245 then return command_245   # Play BGS
    when 246 then return command_246   # Fade Out BGS
    when 247 then return command_247   # Memorize BGM/BGS
    when 248 then return command_248   # Restore BGM/BGS
    when 249 then return command_249   # Play ME
    when 250 then return command_250   # Play SE
    when 251 then return command_251   # Stop SE
    when 301 then return command_301   # Battle Processing
    when 601 then return command_601   # If Win
    when 602 then return command_602   # If Escape
    when 603 then return command_603   # If Lose
    when 302 then return command_302   # Shop Processing
    when 303 then return command_303   # Name Input Processing
    when 311 then return command_311   # Change HP
    when 312 then return command_312   # Change SP
    when 313 then return command_313   # Change State
    when 314 then return command_314   # Recover All
    when 315 then return command_315   # Change EXP
    when 316 then return command_316   # Change Level
    when 317 then return command_317   # Change Parameters
    when 318 then return command_318   # Change Skills
    when 319 then return command_319   # Change Equipment
    when 320 then return command_320   # Change Actor Name
    when 321 then return command_321   # Change Actor Class
    when 322 then return command_322   # Change Actor Graphic
    when 331 then return command_331   # Change Enemy HP
    when 332 then return command_332   # Change Enemy SP
    when 333 then return command_333   # Change Enemy State
    when 334 then return command_334   # Enemy Recover All
    when 335 then return command_335   # Enemy Appearance
    when 336 then return command_336   # Enemy Transform
    when 337 then return command_337   # Show Battle Animation
    when 338 then return command_338   # Deal Damage
    when 339 then return command_339   # Force Action
    when 340 then return command_340   # Abort Battle
    when 351 then return command_351   # Call Menu Screen
    when 352 then return command_352   # Call Save Screen
    when 353 then return command_353   # Game Over
    when 354 then return command_354   # Return to Title Screen
    when 355 then return command_355   # Script
    else          return true          # Other
    end
  end

  def command_dummy
    return true
  end
  #-----------------------------------------------------------------------------
  # * End Event
  #-----------------------------------------------------------------------------
  def command_end
    @list = nil
    end_follower_overrides
    # If main map event and event ID are valid, unlock event
    if @main && @event_id > 0 && $game_map.events[@event_id]
      $game_map.events[@event_id].unlock
    end
  end
  #-----------------------------------------------------------------------------
  # * Command Skip
  #-----------------------------------------------------------------------------
  def command_skip
    indent = @list[@index].indent
    loop do
      return true if @list[@index + 1].indent == indent
      @index += 1
    end
  end
  #-----------------------------------------------------------------------------
  # * Command If
  #-----------------------------------------------------------------------------
  def command_if(value)
    if @branch[@list[@index].indent] == value
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end
  #-----------------------------------------------------------------------------
  # * Show Text
  #-----------------------------------------------------------------------------
  def command_101
    return false if $game_temp.message_window_showing
    message     = @list[@index].parameters[0]
    message_end = ""
    choices                 = nil
    number_input_variable   = nil
    number_input_max_digits = nil
    # Check the next command(s) for things to add on to this text
    loop do
      next_index = pbNextIndex(@index)
      case @list[next_index].code
      when 401   # Continuation of 101 Show Text
        text = @list[next_index].parameters[0]
        message += " " if text != "" && message[message.length - 1, 1] != " "
        message += text
        @index = next_index
        next
      when 101   # Show Text
        message_end = "\1"
      when 102   # Show Choices
        @index = next_index
        choices = setup_choices(@list[@index].parameters)
      when 103   # Input Number
        number_input_variable   = @list[next_index].parameters[0]
        number_input_max_digits = @list[next_index].parameters[1]
        @index = next_index
      end
      break
    end
    # Translate the text
    message = _MAPINTL($game_map.map_id, message)
    # Display the text, with choices/number choosing if appropriate
    @message_waiting = true   # Lets parallel process events work while a message is displayed
    if choices
      command = pbMessage(message + message_end, choices[0], choices[1])
      @branch[@list[@index].indent] = choices[2][command] || command
    elsif number_input_variable
      params = ChooseNumberParams.new
      params.setMaxDigits(number_input_max_digits)
      params.setDefaultValue($game_variables[number_input_variable])
      $game_variables[number_input_variable] = pbMessageChooseNumber(message + message_end, params)
      $game_map.need_refresh = true if $game_map
    else
      pbMessage(message + message_end)
    end
    @message_waiting = false
    return true
  end
  #-----------------------------------------------------------------------------
  # * Show Choices
  #-----------------------------------------------------------------------------
  def command_102
    choices = setup_choices(@list[@index].parameters)
    @message_waiting = true
    command = pbShowCommands(nil, choices[0], choices[1])
    @message_waiting = false
    @branch[@list[@index].indent] = choices[2][command] || command
    Input.update   # Must call Input.update again to avoid extra triggers
    return true
  end

  def setup_choices(params)
    # Get initial options
    choices = params[0].clone
    cancel_index = params[1]
    # Clone @list so the original isn't modified
    @list = Marshal.load(Marshal.dump(@list))
    # Get more choices
    @choice_branch_index = 4
    ret = add_more_choices(choices, cancel_index, @index + 1, @list[@index].indent)
    # Rename choices
    ret[0].each_with_index { |choice, i| ret[0][i] = @renamed_choices[i] if @renamed_choices[i] }
    @renamed_choices.clear
    # Remove hidden choices
    ret[2] = Array.new(ret[0].length) { |i| i }
    @hidden_choices.each_with_index do |condition, i|
      next if !condition
      ret[0][i] = nil
      ret[2][i] = nil
    end
    ret[0].compact!
    ret[2].compact!
    @hidden_choices.clear
    # Translate choices
    ret[0].map! { |ch| _MAPINTL($game_map.map_id, ch) }
    return ret
  end

  def add_more_choices(choices, cancel_index, choice_index, indent)
    # Find index of next command after the current Show Choices command
    loop do
      break if @list[choice_index].indent == indent && ![402, 403, 404].include?(@list[choice_index].code)
      choice_index += 1
    end
    next_cmd = @list[choice_index]
    # If the next command isn't another Show Choices, we're done
    return [choices, cancel_index] if next_cmd.code != 102
    # Add more choices
    old_length = choices.length
    choices += next_cmd.parameters[0]
    # Update cancel option
    if next_cmd.parameters[1] == 5   # Branch
      cancel_index = choices.length + 1
      @choice_branch_index = cancel_index - 1
    elsif next_cmd.parameters[1] > 0   # A choice
      cancel_index = old_length + next_cmd.parameters[1]
      @choice_branch_index = -1
    end
    # Update first Show Choices command to include all options and result of cancelling
    @list[@index].parameters[0] = choices
    @list[@index].parameters[1] = cancel_index
    # Find the "When" lines for this Show Choices command and update their index parameter
    temp_index = choice_index + 1
    loop do
      break if @list[temp_index].indent == indent && ![402, 403, 404].include?(@list[temp_index].code)
      if @list[temp_index].code == 402 && @list[temp_index].indent == indent
        @list[temp_index].parameters[0] += old_length
      end
      temp_index += 1
    end
    # Delete the "Show Choices" line
    @list.delete(next_cmd)
    # Find more choices to add
    return add_more_choices(choices, cancel_index, choice_index + 1, indent)
  end

  def hide_choice(number, condition = true)
    @hidden_choices[number - 1] = condition
  end

  def rename_choice(number, new_name, condition = true)
    return if !condition || nil_or_empty?(new_name)
    @renamed_choices[number - 1] = new_name
  end
  #-----------------------------------------------------------------------------
  # * When [**]
  #-----------------------------------------------------------------------------
  def command_402
    # @parameters[0] is 0/1/2/3 for Choice 1/2/3/4 respectively
    if @branch[@list[@index].indent] == @parameters[0]
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end
  #-----------------------------------------------------------------------------
  # * When Cancel
  #-----------------------------------------------------------------------------
  def command_403
    # @parameters[0] is 4 for "Branch"
    if @branch[@list[@index].indent] == @choice_branch_index
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end
  #-----------------------------------------------------------------------------
  # * Input Number
  #-----------------------------------------------------------------------------
  def command_103
    @message_waiting = true
    variable_number = @list[@index].parameters[0]
    params = ChooseNumberParams.new
    params.setMaxDigits(@list[@index].parameters[1])
    params.setDefaultValue($game_variables[variable_number])
    $game_variables[variable_number] = pbChooseNumber(nil, params)
    $game_map.need_refresh = true if $game_map
    @message_waiting = false
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Text Options
  #-----------------------------------------------------------------------------
  def command_104
    return false if $game_temp.message_window_showing
    $game_system.message_position = @parameters[0]
    $game_system.message_frame    = @parameters[1]
    return true
  end
  #-----------------------------------------------------------------------------
  # * Button Input Processing
  #-----------------------------------------------------------------------------
  def pbButtonInputProcessing(variable_number = 0, timeout_frames = 0)
    ret = 0
    timer = timeout_frames * Graphics.frame_rate / 20
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      # Check for input and break if there is one
      (1..18).each do |i|
        ret = i if Input.trigger?(i)
      end
      break if ret != 0
      # Count down the timer and break if it runs out
      if timeout_frames > 0
        timer -= 1
        break if timer <= 0
      end
    end
    Input.update
    if variable_number && variable_number > 0
      $game_variables[variable_number] = ret
      $game_map.need_refresh = true if $game_map
    end
    return ret
  end

  def command_105
    return false if @buttonInput
    @buttonInput = true
    pbButtonInputProcessing(@list[@index].parameters[0])
    @buttonInput = false
    @index += 1
    return true
  end
  #-----------------------------------------------------------------------------
  # * Wait
  #-----------------------------------------------------------------------------
  def command_106
    @wait_count = @parameters[0] * Graphics.frame_rate / 20
    return true
  end
  #-----------------------------------------------------------------------------
  # * Conditional Branch
  #-----------------------------------------------------------------------------
  def command_111
    result = false
    case @parameters[0]
    when 0   # switch
      switch_name = $data_system.switches[@parameters[1]]
      if switch_name && switch_name[/^s\:/]
        result = (eval($~.post_match) == (@parameters[2] == 0))
      else
        result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
      end
    when 1   # variable
      value1 = $game_variables[@parameters[1]]
      value2 = (@parameters[2] == 0) ? @parameters[3] : $game_variables[@parameters[3]]
      case @parameters[4]
      when 0 then result = (value1 == value2)
      when 1 then result = (value1 >= value2)
      when 2 then result = (value1 <= value2)
      when 3 then result = (value1 > value2)
      when 4 then result = (value1 < value2)
      when 5 then result = (value1 != value2)
      end
    when 2   # self switch
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        result = ($game_self_switches[key] == (@parameters[2] == 0))
      end
    when 3   # timer
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        result = (@parameters[2] == 0) ? (sec >= @parameters[1]) : (sec <= @parameters[1])
      end
#    when 4, 5   # actor, enemy
    when 6   # character
      character = get_character(@parameters[1])
      result = (character.direction == @parameters[2]) if character
    when 7   # gold
      gold = $player.money
      result = (@parameters[2] == 0) ? (gold >= @parameters[1]) : (gold <= @parameters[1])
#    when 8, 9, 10   # item, weapon, armor
    when 11   # button
      result = Input.press?(@parameters[1])
    when 12   # script
      result = execute_script(@parameters[1])
    end
    # Store result in hash
    @branch[@list[@index].indent] = result
    if @branch[@list[@index].indent]
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end
  #-----------------------------------------------------------------------------
  # * Else
  #-----------------------------------------------------------------------------
  def command_411
    if @branch[@list[@index].indent] == false   # Could be nil, so intentionally checks for false
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end
  #-----------------------------------------------------------------------------
  # * Loop
  #-----------------------------------------------------------------------------
  def command_112
    return true
  end
  #-----------------------------------------------------------------------------
  # * Repeat Above
  #-----------------------------------------------------------------------------
  def command_413
    indent = @list[@index].indent
    loop do
      @index -= 1
      return true if @list[@index].indent == indent
    end
  end
  #-----------------------------------------------------------------------------
  # * Break Loop
  #-----------------------------------------------------------------------------
  def command_113
    indent = @list[@index].indent
    temp_index = @index
    loop do
      temp_index += 1
      return true if temp_index >= @list.size - 1   # Reached end of commands
      # Skip ahead to after the [Repeat Above] end of the current loop
      if @list[temp_index].code == 413 && @list[temp_index].indent < indent
        @index = temp_index
        return true
      end
    end
  end
  #-----------------------------------------------------------------------------
  # * Exit Event Processing
  #-----------------------------------------------------------------------------
  def command_115
    command_end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Erase Event
  #-----------------------------------------------------------------------------
  def command_116
    if @event_id > 0
      $game_map.events[@event_id]&.erase
      $PokemonMap&.addErasedEvent(@event_id)
    end
    @index += 1
    return false
  end
  #-----------------------------------------------------------------------------
  # * Call Common Event
  #-----------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@parameters[0]]
    if common_event
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Label
  #-----------------------------------------------------------------------------
  def command_118
    return true
  end
  #-----------------------------------------------------------------------------
  # * Jump to Label
  #-----------------------------------------------------------------------------
  def command_119
    label_name = @parameters[0]
    temp_index = 0
    loop do
      return true if temp_index >= @list.size - 1   # Reached end of commands
      # Check whether this command is a label with the desired name
      if @list[temp_index].code == 118 &&
         @list[temp_index].parameters[0] == label_name
        @index = temp_index
        return true
      end
      # Command isn't the desired label, increment temp_index and keep looking
      temp_index += 1
    end
  end
  #-----------------------------------------------------------------------------
  # * Control Switches
  #-----------------------------------------------------------------------------
  def command_121
    should_refresh = false
    (@parameters[0]..@parameters[1]).each do |i|
      next if $game_switches[i] == (@parameters[2] == 0)
      $game_switches[i] = (@parameters[2] == 0)
      should_refresh = true
    end
    # Refresh map
    $game_map.need_refresh = true if should_refresh
    return true
  end
  #-----------------------------------------------------------------------------
  # * Control Variables
  #-----------------------------------------------------------------------------
  def command_122
    value = 0
    case @parameters[3]
    when 0   # invariable (fixed value)
      value = @parameters[4]
    when 1   # variable
      value = $game_variables[@parameters[4]]
    when 2   # random number
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
#    when 3, 4, 5   # item, actor, enemy
    when 6   # character
      character = get_character(@parameters[4])
      if character
        case @parameters[5]
        when 0 then value = character.x             # x-coordinate
        when 1 then value = character.y             # y-coordinate
        when 2 then value = character.direction     # direction
        when 3 then value = character.screen_x      # screen x-coordinate
        when 4 then value = character.screen_y      # screen y-coordinate
        when 5 then value = character.terrain_tag.id_number   # terrain tag
        end
      end
    when 7   # other
      case @parameters[4]
      when 0 then value = $game_map.map_id                             # map ID
      when 1 then value = $player.pokemon_party.length                 # party members
      when 2 then value = $player.money                                # gold
#      when 3   # steps
      when 4 then value = Graphics.frame_count / Graphics.frame_rate   # play time
      when 5 then value = $game_system.timer / Graphics.frame_rate     # timer
      when 6 then value = $game_system.save_count                      # save count
      end
    end
    # Apply value and operation to all specified game variables
    (@parameters[0]..@parameters[1]).each do |i|
      case @parameters[2]
      when 0   # set
        next if $game_variables[i] == value
        $game_variables[i] = value
      when 1   # add
        next if $game_variables[i] >= 99_999_999
        $game_variables[i] += value
      when 2   # subtract
        next if $game_variables[i] <= -99_999_999
        $game_variables[i] -= value
      when 3   # multiply
        next if value == 1
        $game_variables[i] *= value
      when 4   # divide
        next if [0, 1].include?(value)
        $game_variables[i] /= value
      when 5   # remainder
        next if [0, 1].include?(value)
        $game_variables[i] %= value
      end
      $game_variables[i] = 99_999_999 if $game_variables[i] > 99_999_999
      $game_variables[i] = -99_999_999 if $game_variables[i] < -99_999_999
      $game_map.need_refresh = true
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Control Self Switch
  #-----------------------------------------------------------------------------
  def command_123
    if @event_id > 0
      new_value = (@parameters[1] == 0)
      key = [$game_map.map_id, @event_id, @parameters[0]]
      if $game_self_switches[key] != new_value
        $game_self_switches[key] = new_value
        $game_map.need_refresh = true
      end
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Control Timer
  #-----------------------------------------------------------------------------
  def command_124
    $game_system.timer_working = (@parameters[0] == 0)
    $game_system.timer = @parameters[1] * Graphics.frame_rate if @parameters[0] == 0
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Gold
  #-----------------------------------------------------------------------------
  def command_125
    value = (@parameters[1] == 0) ? @parameters[2] : $game_variables[@parameters[2]]
    value = -value if @parameters[0] == 1   # Decrease
    $player.money += value
    return true
  end

  def command_126; command_dummy; end   # Change Items
  def command_127; command_dummy; end   # Change Weapons
  def command_128; command_dummy; end   # Change Armor
  def command_129; command_dummy; end   # Change Party Member
  #-----------------------------------------------------------------------------
  # * Change Windowskin
  #-----------------------------------------------------------------------------
  def command_131
    Settings::SPEECH_WINDOWSKINS.length.times do |i|
      next if Settings::SPEECH_WINDOWSKINS[i] != @parameters[0]
      $PokemonSystem.textskin = i
      MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[i])
      return true
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Battle BGM
  #-----------------------------------------------------------------------------
  def command_132
    ($PokemonGlobal.nextBattleBGM = @parameters[0]) ? @parameters[0].clone : nil
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Battle End ME
  #-----------------------------------------------------------------------------
  def command_133; command_dummy; end
  #-----------------------------------------------------------------------------
  # * Change Save Access
  #-----------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@parameters[0] == 0)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Menu Access
  #-----------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@parameters[0] == 0)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Encounter
  #-----------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@parameters[0] == 0)
    $game_player.make_encounter_count
    return true
  end
  #-----------------------------------------------------------------------------
  # * Transfer Player
  #-----------------------------------------------------------------------------
  def command_201
    return true if $game_temp.in_battle
    return false if $game_temp.player_transferring ||
                    $game_temp.message_window_showing ||
                    $game_temp.transition_processing
    # Set up the transfer and the player's new coordinates
    $game_temp.player_transferring = true
    if @parameters[0] == 0   # Direct appointment
      $game_temp.player_new_map_id    = @parameters[1]
      $game_temp.player_new_x         = @parameters[2]
      $game_temp.player_new_y         = @parameters[3]
    else   # Appoint with variables
      $game_temp.player_new_map_id    = $game_variables[@parameters[1]]
      $game_temp.player_new_x         = $game_variables[@parameters[2]]
      $game_temp.player_new_y         = $game_variables[@parameters[3]]
    end
    $game_temp.player_new_direction = @parameters[4]
    @index += 1
    # If transition happens with a fade, do the fade
    if @parameters[5] == 0
      Graphics.freeze
      $game_temp.transition_processing = true
      $game_temp.transition_name       = ""
    end
    return false
  end
  #-----------------------------------------------------------------------------
  # * Set Event Location
  #-----------------------------------------------------------------------------
  def command_202
    return true if $game_temp.in_battle
    character = get_character(@parameters[0])
    return true if character.nil?
    # Move the character
    case @parameters[1]
    when 0   # Direct appointment
      character.moveto(@parameters[2], @parameters[3])
    when 1   # Appoint with variables
      character.moveto($game_variables[@parameters[2]], $game_variables[@parameters[3]])
    else   # Exchange with another event
      character2 = get_character(@parameters[2])
      if character2
        old_x = character.x
        old_y = character.y
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # Set character's direction
    case @parameters[4]
    when 2 then character.turn_down
    when 4 then character.turn_left
    when 6 then character.turn_right
    when 8 then character.turn_up
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Scroll Map
  #-----------------------------------------------------------------------------
  def command_203
    return true if $game_temp.in_battle
    return false if $game_map.scrolling?
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Map Settings
  #-----------------------------------------------------------------------------
  def command_204
    case @parameters[0]
    when 0   # panorama
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue  = @parameters[2]
    when 1   # fog
      $game_map.fog_name       = @parameters[1]
      $game_map.fog_hue        = @parameters[2]
      $game_map.fog_opacity    = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom       = @parameters[5]
      $game_map.fog_sx         = @parameters[6]
      $game_map.fog_sy         = @parameters[7]
    when 2   # battleback
      $game_map.battleback_name  = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Fog Color Tone
  #-----------------------------------------------------------------------------
  def command_205
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Fog Opacity
  #-----------------------------------------------------------------------------
  def command_206
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Show Animation
  #-----------------------------------------------------------------------------
  def command_207
    character = get_character(@parameters[0])
    if @follower_animation
      character = Followers.get(@follower_animation_id)
      @follower_animation = false
      @follower_animation_id = nil
    end
    return true if character.nil?
    character.animation_id = @parameters[1]
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Transparent Flag
  #-----------------------------------------------------------------------------
  def command_208
    $game_player.transparent = (@parameters[0] == 0)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Set Move Route
  #-----------------------------------------------------------------------------
  def command_209
    character = get_character(@parameters[0])
    if @follower_move_route
      character = Followers.get(@follower_move_route_id)
      @follower_move_route = false
      @follower_move_route_id = nil
    end
    return true if character.nil?
    character.force_move_route(@parameters[1])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Wait for Move's Completion
  #-----------------------------------------------------------------------------
  def command_210
    @move_route_waiting = true if !$game_temp.in_battle
    return true
  end
  #-----------------------------------------------------------------------------
  # * Prepare for Transition
  #-----------------------------------------------------------------------------
  def command_221
    return false if $game_temp.message_window_showing
    Graphics.freeze
    return true
  end
  #-----------------------------------------------------------------------------
  # * Execute Transition
  #-----------------------------------------------------------------------------
  def command_222
    return false if $game_temp.transition_processing
    $game_temp.transition_processing = true
    $game_temp.transition_name       = @parameters[0]
    @index += 1
    return false
  end
  #-----------------------------------------------------------------------------
  # * Change Screen Color Tone
  #-----------------------------------------------------------------------------
  def command_223
    $game_screen.start_tone_change(@parameters[0], @parameters[1] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Screen Flash
  #-----------------------------------------------------------------------------
  def command_224
    $game_screen.start_flash(@parameters[0], @parameters[1] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Screen Shake
  #-----------------------------------------------------------------------------
  def command_225
    $game_screen.start_shake(@parameters[0], @parameters[1], @parameters[2] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Show Picture
  #-----------------------------------------------------------------------------
  def command_231
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    if @parameters[3] == 0   # Direct appointment
      x = @parameters[4]
      y = @parameters[5]
    else   # Appoint with variables
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
                                       x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Move Picture
  #-----------------------------------------------------------------------------
  def command_232
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    if @parameters[3] == 0   # Direct appointment
      x = @parameters[4]
      y = @parameters[5]
    else   # Appoint with variables
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    $game_screen.pictures[number].move(@parameters[1] * Graphics.frame_rate / 20,
                                       @parameters[2], x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Rotate Picture
  #-----------------------------------------------------------------------------
  def command_233
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    $game_screen.pictures[number].rotate(@parameters[1])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Change Picture Color Tone
  #-----------------------------------------------------------------------------
  def command_234
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    $game_screen.pictures[number].start_tone_change(@parameters[1],
                                                    @parameters[2] * Graphics.frame_rate / 20)
    return true
  end
  #-----------------------------------------------------------------------------
  # * Erase Picture
  #-----------------------------------------------------------------------------
  def command_235
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    $game_screen.pictures[number].erase
    return true
  end
  #-----------------------------------------------------------------------------
  # * Set Weather Effects
  #-----------------------------------------------------------------------------
  def command_236
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Play BGM
  #-----------------------------------------------------------------------------
  def command_241
    pbBGMPlay(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Fade Out BGM
  #-----------------------------------------------------------------------------
  def command_242
    pbBGMFade(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Play BGS
  #-----------------------------------------------------------------------------
  def command_245
    pbBGSPlay(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Fade Out BGS
  #-----------------------------------------------------------------------------
  def command_246
    pbBGSFade(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Memorize BGM/BGS
  #-----------------------------------------------------------------------------
  def command_247
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    return true
  end
  #-----------------------------------------------------------------------------
  # * Restore BGM/BGS
  #-----------------------------------------------------------------------------
  def command_248
    $game_system.bgm_restore
    $game_system.bgs_restore
    return true
  end
  #-----------------------------------------------------------------------------
  # * Play ME
  #-----------------------------------------------------------------------------
  def command_249
    pbMEPlay(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Play SE
  #-----------------------------------------------------------------------------
  def command_250
    pbSEPlay(@parameters[0])
    return true
  end
  #-----------------------------------------------------------------------------
  # * Stop SE
  #-----------------------------------------------------------------------------
  def command_251
    pbSEStop
    return true
  end

  def command_301; command_dummy; end   # Battle Processing
  def command_601; command_if(0); end   # If Win
  def command_602; command_if(1); end   # If Escape
  def command_603; command_if(2); end   # If Lose
  def command_302; command_dummy; end   # Shop Processing
  #-----------------------------------------------------------------------------
  # * Name Input Processing
  #-----------------------------------------------------------------------------
  def command_303
    if $player
      $player.name = pbEnterPlayerName(_INTL("Your name?"), 1, @parameters[1], $player.name)
      return true
    end
    if $game_actors && $data_actors && $data_actors[@parameters[0]]
      $game_temp.battle_abort = true
      pbFadeOutIn {
        sscene = PokemonEntryScene.new
        sscreen = PokemonEntry.new(sscene)
        $game_actors[@parameters[0]].name = sscreen.pbStartScreen(
          _INTL("Enter {1}'s name.", $game_actors[@parameters[0]].name),
          1, @parameters[1], $game_actors[@parameters[0]].name
        )
      }
    end
    return true
  end

  def command_311; command_dummy; end   # Change HP
  def command_312; command_dummy; end   # Change SP
  def command_313; command_dummy; end   # Change State
  #-----------------------------------------------------------------------------
  # * Recover All
  #-----------------------------------------------------------------------------
  def command_314
    if @parameters[0] == 0
      if Settings::HEAL_STORED_POKEMON   # No need to heal stored Pokémon
        $player.heal_party
      else
        pbEachPokemon { |pkmn, box| pkmn.heal }   # Includes party Pokémon
      end
    end
    return true
  end

  def command_315; command_dummy; end   # Change EXP
  def command_316; command_dummy; end   # Change Level
  def command_317; command_dummy; end   # Change Parameters
  def command_318; command_dummy; end   # Change Skills
  def command_319; command_dummy; end   # Change Equipment
  def command_320; command_dummy; end   # Change Actor Name
  def command_321; command_dummy; end   # Change Actor Class
  def command_322; command_dummy; end   # Change Actor Graphic
  def command_331; command_dummy; end   # Change Enemy HP
  def command_332; command_dummy; end   # Change Enemy SP
  def command_333; command_dummy; end   # Change Enemy State
  def command_334; command_dummy; end   # Enemy Recover All
  def command_335; command_dummy; end   # Enemy Appearance
  def command_336; command_dummy; end   # Enemy Transform
  def command_337; command_dummy; end   # Show Battle Animation
  def command_338; command_dummy; end   # Deal Damage
  def command_339; command_dummy; end   # Force Action
  def command_340; command_dummy; end   # Abort Battle
  #-----------------------------------------------------------------------------
  # * Call Menu Screen
  #-----------------------------------------------------------------------------
  def command_351
    $game_temp.menu_calling = true
    @index += 1
    return false
  end
  #-----------------------------------------------------------------------------
  # * Call Save Screen
  #-----------------------------------------------------------------------------
  def command_352
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    screen.pbSaveScreen
    return true
  end
  #-----------------------------------------------------------------------------
  # * Game Over
  #-----------------------------------------------------------------------------
  def command_353
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn { pbStartOver(true) }
  end
  #-----------------------------------------------------------------------------
  # * Return to Title Screen
  #-----------------------------------------------------------------------------
  def command_354
    $game_temp.title_screen_calling = true
    return false
  end
  #-----------------------------------------------------------------------------
  # * Script
  #-----------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    # Look for more script commands or a continuation of one, and add them to script
    loop do
      break if ![355, 655].include?(@list[@index + 1].code)
      script += @list[@index + 1].parameters[0] + "\n"
      @index += 1
    end
    # Run the script
    execute_script(script)
    return true
  end
end
