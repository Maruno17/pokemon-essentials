#===============================================================================
#
#===============================================================================
def pbMapInterpreter
  return $game_system&.map_interpreter
end

def pbMapInterpreterRunning?
  interp = pbMapInterpreter
  return interp&.running?
end

# Unused
def pbRefreshSceneMap
  $scene.miniupdate if $scene.is_a?(Scene_Map)
end

def pbUpdateSceneMap
  $scene.miniupdate if $scene.is_a?(Scene_Map) && !pbIsFaded?
end

#===============================================================================
#
#===============================================================================
def pbEventCommentInput(*args)
  parameters = []
  list = args[0].list   # List of commands for event or event page
  elements = args[1]    # Number of elements
  trigger = args[2]     # Trigger
  return nil if list.nil?
  return nil unless list.is_a?(Array)
  list.each do |item|
    next if ![108, 408].include?(item.code)
    next if item.parameters[0] != trigger
    start = list.index(item) + 1
    finish = start + elements
    (start...finish).each do |id|
      parameters.push(list[id].parameters[0]) if list[id]
    end
    return parameters
  end
  return nil
end

def pbCurrentEventCommentInput(elements, trigger)
  return nil if !pbMapInterpreterRunning?
  event = pbMapInterpreter.get_self
  return nil if !event
  return pbEventCommentInput(event, elements, trigger)
end

#===============================================================================
#
#===============================================================================
class ChooseNumberParams
  attr_reader :messageSkin   # Set the full path for the message's window skin
  attr_reader :skin

  def initialize
    @maxDigits = 0
    @minNumber = 0
    @maxNumber = 0
    @skin = nil
    @messageSkin = nil
    @negativesAllowed = false
    @initialNumber = 0
    @cancelNumber = nil
  end

  def setMessageSkin(value)
    @messageSkin = value
  end

  def setSkin(value)
    @skin = value
  end

  def setNegativesAllowed(value)
    @negativeAllowed = value
  end

  def negativesAllowed
    @negativeAllowed ? true : false
  end

  def setRange(minNumber, maxNumber)
    maxNumber = minNumber if minNumber > maxNumber
    @maxDigits = 0
    @minNumber = minNumber
    @maxNumber = maxNumber
  end

  def setDefaultValue(number)
    @initialNumber = number
    @cancelNumber = nil
  end

  def setInitialValue(number)
    @initialNumber = number
  end

  def setCancelValue(number)
    @cancelNumber = number
  end

  def initialNumber
    return @initialNumber.clamp(self.minNumber, self.maxNumber)
  end

  def cancelNumber
    return @cancelNumber || self.initialNumber
  end

  def minNumber
    ret = (@maxDigits > 0) ? -((10**@maxDigits) - 1) : @minNumber
    ret = 0 if !@negativeAllowed && ret < 0
    return ret
  end

  def maxNumber
    ret = (@maxDigits > 0) ? ((10**@maxDigits) - 1) : @maxNumber
    ret = 0 if !@negativeAllowed && ret < 0
    return ret
  end

  def setMaxDigits(value)
    @maxDigits = [1, value].max
  end

  def maxDigits
    return @maxDigits if @maxDigits > 0
    return [numDigits(self.minNumber), numDigits(self.maxNumber)].max
  end

  #-----------------------------------------------------------------------------

  private

  def numDigits(number)
    ans = 1
    number = number.abs
    while number >= 10
      ans += 1
      number /= 10
    end
    return ans
  end
end

#===============================================================================
#
#===============================================================================
def pbChooseNumber(msgwindow, params)
  return 0 if !params
  ret = 0
  maximum = params.maxNumber
  minimum = params.minNumber
  defaultNumber = params.initialNumber
  cancelNumber = params.cancelNumber
  cmdwindow = Window_InputNumberPokemon.new(params.maxDigits)
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.setSkin(params.skin) if params.skin
  cmdwindow.sign = params.negativesAllowed # must be set before number
  cmdwindow.number = defaultNumber
  pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    cmdwindow.update
    msgwindow&.update
    yield if block_given?
    if Input.trigger?(Input::USE)
      ret = cmdwindow.number
      if ret > maximum
        pbPlayBuzzerSE
      elsif ret < minimum
        pbPlayBuzzerSE
      else
        pbPlayDecisionSE
        break
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE
      ret = cancelNumber
      break
    end
  end
  cmdwindow.dispose
  Input.update
  return ret
end

#===============================================================================
#
#===============================================================================
class FaceWindowVX < SpriteWindow_Base
  def initialize(face)
    super(0, 0, 128, 128)
    faceinfo = face.split(",")
    facefile = pbResolveBitmap("Graphics/Faces/" + faceinfo[0])
    facefile = pbResolveBitmap("Graphics/Pictures/" + faceinfo[0]) if !facefile
    self.contents&.dispose
    @faceIndex = faceinfo[1].to_i
    @facebitmaptmp = AnimatedBitmap.new(facefile)
    @facebitmap = Bitmap.new(96, 96)
    @facebitmap.blt(0, 0, @facebitmaptmp.bitmap,
                    Rect.new((@faceIndex % 4) * 96, (@faceIndex / 4) * 96, 96, 96))
    self.contents = @facebitmap
  end

  def update
    super
    if @facebitmaptmp.totalFrames > 1
      @facebitmaptmp.update
      @facebitmap.blt(0, 0, @facebitmaptmp.bitmap,
                      Rect.new((@faceIndex % 4) * 96, (@faceIndex / 4) * 96, 96, 96))
    end
  end

  def dispose
    @facebitmaptmp.dispose
    @facebitmap&.dispose
    super
  end
end

#===============================================================================
#
#===============================================================================
def pbGetBasicMapNameFromId(id)
  begin
    map = pbLoadMapInfos
    return "" if !map
    return map[id].name
  rescue
    return ""
  end
end

def pbGetMapNameFromId(id)
  name = GameData::MapMetadata.try_get(id)&.name
  name = pbGetBasicMapNameFromId(id) if nil_or_empty?(name)
  name = name.gsub(/\\PN/, $player.name) if $player
  if $game_variables
    name = name.gsub(/\\v\[(\d+)\]/) { |num| $game_variables[$~[1].to_i].to_s }
  end
  return name
end

def pbCsvField!(str)
  ret = ""
  str.sub!(/\A\s*/, "")
  if str[0, 1] == "\""
    str[0, 1] = ""
    escaped = false
    fieldbytes = 0
    str.scan(/./) do |s|
      fieldbytes += s.length
      break if s == "\"" && !escaped
      if s == "\\" && !escaped
        escaped = true
      else
        ret += s
        escaped = false
      end
    end
    str[0, fieldbytes] = ""
    if !str[/\A\s*,/] && !str[/\A\s*$/]
      raise _INTL("Invalid quoted field (in: {1})", ret)
    end
    str[0, str.length] = $~.post_match
  else
    if str[/,/]
      str[0, str.length] = $~.post_match
      ret = $~.pre_match
    else
      ret = str.clone
      str[0, str.length] = ""
    end
    ret.gsub!(/\s+$/, "")
  end
  return ret
end

def pbCsvPosInt!(str)
  ret = pbCsvField!(str)
  if !ret[/\A\d+$/]
    raise _INTL("Field {1} is not a positive integer", ret)
  end
  return ret.to_i
end

#===============================================================================
# Money and coins windows.
#===============================================================================
def pbGetGoldString
  return _INTL("${1}", $player.money.to_s_formatted)
end

def pbDisplayGoldWindow(msgwindow)
  moneyString = pbGetGoldString
  goldwindow = Window_AdvancedTextPokemon.new(_INTL("Money:\n<ar>{1}</ar>", moneyString))
  goldwindow.setSkin("Graphics/Windowskins/goldskin")
  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.width = 160 if goldwindow.width <= 160
  if msgwindow.y == 0
    goldwindow.y = Graphics.height - goldwindow.height
  else
    goldwindow.y = 0
  end
  goldwindow.viewport = msgwindow.viewport
  goldwindow.z = msgwindow.z
  return goldwindow
end

def pbDisplayCoinsWindow(msgwindow, goldwindow)
  coinString = ($player) ? $player.coins.to_s_formatted : "0"
  coinwindow = Window_AdvancedTextPokemon.new(_INTL("Coins:\n<ar>{1}</ar>", coinString))
  coinwindow.setSkin("Graphics/Windowskins/goldskin")
  coinwindow.resizeToFit(coinwindow.text, Graphics.width)
  coinwindow.width = 160 if coinwindow.width <= 160
  if msgwindow.y == 0
    coinwindow.y = (goldwindow) ? goldwindow.y - coinwindow.height : Graphics.height - coinwindow.height
  else
    coinwindow.y = (goldwindow) ? goldwindow.height : 0
  end
  coinwindow.viewport = msgwindow.viewport
  coinwindow.z = msgwindow.z
  return coinwindow
end

def pbDisplayBattlePointsWindow(msgwindow)
  pointsString = ($player) ? $player.battle_points.to_s_formatted : "0"
  pointswindow = Window_AdvancedTextPokemon.new(_INTL("Battle Points:\n<ar>{1}</ar>", pointsString))
  pointswindow.setSkin("Graphics/Windowskins/goldskin")
  pointswindow.resizeToFit(pointswindow.text, Graphics.width)
  pointswindow.width = 160 if pointswindow.width <= 160
  if msgwindow.y == 0
    pointswindow.y = Graphics.height - pointswindow.height
  else
    pointswindow.y = 0
  end
  pointswindow.viewport = msgwindow.viewport
  pointswindow.z = msgwindow.z
  return pointswindow
end

#===============================================================================
#
#===============================================================================
def pbCreateStatusWindow(viewport = nil)
  msgwindow = Window_AdvancedTextPokemon.new("")
  if viewport
    msgwindow.viewport = viewport
  else
    msgwindow.z = 99999
  end
  msgwindow.visible = false
  msgwindow.letterbyletter = false
  pbBottomLeftLines(msgwindow, 2)
  skinfile = MessageConfig.pbGetSpeechFrame
  msgwindow.setSkin(skinfile)
  return msgwindow
end

def pbCreateMessageWindow(viewport = nil, skin = nil)
  msgwindow = Window_AdvancedTextPokemon.new("")
  if viewport
    msgwindow.viewport = viewport
  else
    msgwindow.z = 99999
  end
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
  pbBottomLeftLines(msgwindow, 2)
  $game_temp.message_window_showing = true if $game_temp
  skin = MessageConfig.pbGetSpeechFrame if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing = false if $game_temp
  msgwindow.dispose
end

#===============================================================================
# Main message-displaying function.
#===============================================================================
def pbMessageDisplay(msg_window, message, letter_by_letter = true, command_proc = nil)
  return if !msg_window
  old_letter_by_letter = msg_window.letterbyletter
  msg_window.letterbyletter = letter_by_letter
  controls = []   # Contains [control name, parameter || "", text length to trigger at]
  control_params = {
    :line_count         => (Graphics.height > 400) ? 3 : 2,
    :appear_duration    => 0.5,   # In seconds
    :disappear_duration => 0.5,   # In seconds
    :auto_resume        => false
  }
  extra_sprites = {}   # For other windows and sprites
  text = message.clone
  # Text replacement
  pbMessageDisplay_ReplaceMessageText(msg_window, text)
  # Get default windowskin/text color/number of lines (also replaces some text)
  pbMessageDisplay_SetDefaultProperties(msg_window, text, control_params)
  text = control_params[:color_tag] + text   # Prepend the default text color to text
  # Extract controls from text
  text = pbMessageDisplay_ExtractControls(text, controls)
  # For various controls, create windows/sprites or set values
  pbMessageDisplay_SetUpControls(text, controls, control_params, extra_sprites)
  # Position message window and other windows/sprites
  pbRepositionMessageWindow(msg_window, control_params[:line_count])
  pbMessageDisplay_PositionExtraSprites(msg_window, extra_sprites)
  # Play SE at start
  if control_params[:start_se]
    pbSEPlay(pbStringToAudioFile(control_params[:start_se]))
  elsif !control_params[:appear_timer_start] && msg_window.letterbyletter   # Isn't sliding on, is showing letter by letter
    pbPlayDecisionSE
  end
  ### Show text appearing
  msg_window.text = text
  msg_window.waitcount = 0
  control_params[:msg_window_at_top] = (msg_window.y == 0)
  loop do
    # Message box slides into the screen at the start
    pbMessageDisplay_UpdateMessageWindowSlideOn(msg_window, control_params, extra_sprites)
    # Update and execute controls as they are reached during message display
    controls.length.times do |i|
      next if !controls[i]
      next if controls[i][2] > msg_window.position   # Control triggers in the future
      next if msg_window.waitcount != 0   # Message display is paused
      pbMessageDisplay_UpdateControl(controls[i], msg_window, control_params, extra_sprites)
      controls[i] = nil   # Delete the control after it triggers
    end
    break if !msg_window.letterbyletter   # Whole message has shown already, so break the loop
    # Updating
    Graphics.update
    Input.update
    extra_sprites.each_value { |sprite| sprite&.update }
    # Continue message display if it was paused and should auto-resume
    if control_params[:auto_resume] && msg_window.waitcount == 0
      msg_window.resume if msg_window.busy?
      break if !msg_window.busy?
    end
    # Player inputs to continue message display or close the message at the end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      if msg_window.busy?
        pbPlayDecisionSE if msg_window.pausing?
        msg_window.resume
      elsif !control_params[:appear_timer_start]   # Not sliding in
        break
      end
    end
    # Updating
    pbUpdateSceneMap
    msg_window.update
    yield if block_given?
    # If message is fully shown, auto-break the loop if it's not showing letter
    # by letter OR there is a choice to make OR if there's code to execute
    # afterwards (if none of these apply, await player's input to close the
    # message)
    if !msg_window.busy?
      break if !msg_window.letterbyletter || control_params[:choices] || command_proc
    end
  end
  ### Message has finished displaying
  Input.update   # Must call Input.update again to avoid extra triggers
  msg_window.letterbyletter = old_letter_by_letter
  # If message included choices using \ch, choose one now
  pbMessageDisplay_AfterMessageAppeared(msg_window, control_params, extra_sprites)
  # If message came with code to run afterwards, run it now (it can return a
  # value)
  ret = nil
  ret = command_proc.call(msg_window) if command_proc
  # Dispose extra windows/sprites
  extra_sprites.each_value { |sprite| sprite&.dispose }
  # Message box slides out of the screen at the end
  pbMessageDisplay_MessageWindowSlideOff(msg_window, control_params)
  return ret
end

def pbMessageDisplay_ReplaceMessageText(msg_window, text)
  isDarkSkin = msg_window && isDarkWindowskin(msg_window&.windowskin)
  pbMessageDisplay_ReplaceMessageTextShorthands(msg_window, text)
  # Escaped characters
  text.gsub!(/\\\\/, "\5")
  text.gsub!(/\\1/, "\1")
  text.gsub!(/\\n/i, "\n")
  pbMessageDisplay_ReplaceMessageTextPlaceholders(msg_window, text)
  # Male/female text colors
  pbMessageDisplay_ReplaceMessageTextGenderColorPlaceholders(msg_window, text)
  if isDarkSkin
    male_text_tag = shadowc3tag(MessageConfig::LIGHT_MALE_TEXT_MAIN_COLOR, MessageConfig::LIGHT_MALE_TEXT_SHADOW_COLOR)
    female_text_tag = shadowc3tag(MessageConfig::LIGHT_FEMALE_TEXT_MAIN_COLOR, MessageConfig::LIGHT_FEMALE_TEXT_SHADOW_COLOR)
  else
    male_text_tag = shadowc3tag(MessageConfig::MALE_TEXT_MAIN_COLOR, MessageConfig::MALE_TEXT_SHADOW_COLOR)
    female_text_tag = shadowc3tag(MessageConfig::FEMALE_TEXT_MAIN_COLOR, MessageConfig::FEMALE_TEXT_SHADOW_COLOR)
  end
  text.gsub!(/\\b/i, male_text_tag)
  text.gsub!(/\\r/i, female_text_tag)
  # Other text colors
  text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + $1 + ">" }
  text.gsub!(/\\c\[([0-9]+)\]/i) do
    main_color, shadow_color = get_text_colors_for_windowskin(msg_window&.windowskin, $1.to_i, isDarkSkin)
    next shadowc3tag(main_color, shadow_color)
  end
  # Dark version of icon
  if isDarkSkin
    text.gsub!(/<icon=([^>\n\r]+)>/i) do
      filename = $1
      next "<icon=" + filename + "_dark>" if pbResolveBitmap("Graphics/Icons/" + filename + "_dark")
      next "<icon=" + filename + ">"
    end
  end
end

def pbMessageDisplay_ReplaceMessageTextShorthands(msg_window, text)
  # \sign[something] gets turned into \op\cl\ts[]\w[something]
  text.gsub!(/\\sign\[([^\]]*)\]/i) { next "\\op\\cl\\ts[]\\w[" + $1 + "]" }
end

def pbMessageDisplay_ReplaceMessageTextPlaceholders(msg_window, text)
  text.gsub!(/\\pn/i, $player.name) if $player
  text.gsub!(/\\pm/i, _INTL("${1}", $player.money.to_s_formatted)) if $player
  loop do
    last_text = text.clone
    text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    break if text == last_text
  end
  if $game_actors
    text.gsub!(/\\n\[([1-8])\]/i) { next $game_actors[$1.to_i].name }
  end
end

def pbMessageDisplay_ReplaceMessageTextGenderColorPlaceholders(msg_window, text)
  text.gsub!(/\\pg/i, "\\b") if $player&.male?
  text.gsub!(/\\pg/i, "\\r") if $player&.female?
  text.gsub!(/\\pog/i, "\\r") if $player&.male?
  text.gsub!(/\\pog/i, "\\b") if $player&.female?
  text.gsub!(/\\pg/i, "")
  text.gsub!(/\\pog/i, "")
end

# NOTE: Controls mentioned in here shouldn't be in the constants below as they
#       are removed here before the constants are used.
def pbMessageDisplay_SetDefaultProperties(msg_window, text, control_params)
  # Get windowskin to use for the message
  text.gsub!(/\\w\[([^\]]*)\]/i) do
    w = $1.to_s
    if w == ""
      msg_window.windowskin = nil
    else
      msg_window.setSkin("Graphics/Windowskins/#{w}", false)
    end
    next ""
  end
  # Get default text color based on the windowskin
  colortag = ""
  if $game_system && $game_system.message_frame != 0
    main_color, shadow_color = get_text_colors_for_windowskin(msg_window.windowskin, 0, true)
    colortag = shadowc3tag(main_color, shadow_color)
  else
    isDarkSkin = isDarkWindowskin(msg_window.windowskin)
    main_color, shadow_color = get_text_colors_for_windowskin(msg_window.windowskin, 0, isDarkSkin)
    colortag = shadowc3tag(main_color, shadow_color)
  end
  control_params[:color_tag] = colortag
  # Get number of lines of text
  loop do
    last_text = text.clone
    text.gsub!(/\\l\[([0-9]+)\]/i) do
      control_params[:line_count] = [1, $1.to_i].max
      next ""
    end
    break if text == last_text
  end
end

# NOTE: All these appear as \XYZ[ABC].
MESSAGE_DISPLAY_CONTROLS_WITH_PARAMETER = [
  "f", "ff", "ts", "cl", "me", "se", "wt", "wtnp", "ch"
]
# NOTE: All these appear as \XYZ.
MESSAGE_DISPLAY_CONTROLS_WITHOUT_PARAMETER = [
  "g", "cn", "pt", "wd", "wm", "wu", "op", "cl", "\\.", "\\|", "\\!", "\\^"
]

def pbMessageDisplay_ExtractControls(text, controls)
  # Chop up text into chunks each time a control comes up, and puts the controls
  # into one array and the non-control text into another
  reg_string = "(?:" +
               "\\\\(" + MESSAGE_DISPLAY_CONTROLS_WITH_PARAMETER.join("|") + ")" + "\\[([^\\\]]*)\\]" +
               "|" +
               "\\\\(" + MESSAGE_DISPLAY_CONTROLS_WITHOUT_PARAMETER.join("|") + ")" +
               ")"
  reg = Regexp.new(reg_string, Regexp::IGNORECASE)
  textchunks = []
  while text[reg]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase, $~[2], -1])   # Has a parameter
    else
      controls.push([$~[3].downcase, "", -1])   # No parameter
    end
    text = $~.post_match
  end
  textchunks.push(text)
  textchunks.each { |chunk| chunk.gsub!(/\005/, "\\") }
  # For certain controls (ones that pause and auto-resume), append display-
  # halting text to the text chunk just before them
  pbMessageDisplay_AddHaltingText(textchunks, controls)
  # For all controls, determine when they trigger in terms of characters
  # displayed and store that number in controls[i][2]
  textlen = 0
  controls.length.times do |i|
    control = controls[i][0]
    textlen += toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2] = textlen
  end
  # Glue text chunks back together and return it
  return textchunks.join
end

def pbMessageDisplay_AddHaltingText(textchunks, controls)
  controls.length.times do |i|
    control = controls[i][0]
    case control
    when "wt", "wtnp", ".", "|"
      textchunks[i] += "\2"   # Pause and auto-resume
    when "!"
      textchunks[i] += "\1"   # Pause and wait for input
    end
  end
end

def pbMessageDisplay_SetUpControls(text, controls, control_params, extra_sprites)
  controls.length.times do |i|
    control = controls[i][0]
    param = controls[i][1]
    case control
    when "f"
      extra_sprites[:face_window]&.dispose
      extra_sprites[:face_window] = PictureWindow.new("Graphics/Pictures/#{param}")
    when "ff"
      extra_sprites[:face_window]&.dispose
      extra_sprites[:face_window] = FaceWindowVX.new(param)
    when "se"
      if controls[i][2] == 0   # At start of message
        control_params[:start_se] = param
        controls[i] = nil
      end
    when "ch"
      cmds = param.clone
      control_params[:choice_variable] = pbCsvPosInt!(cmds)
      control_params[:choice_if_cancel] = pbCsvField!(cmds).to_i
      control_params[:choices] = []
      while cmds.length > 0
        control_params[:choices].push(pbCsvField!(cmds))
      end
    when "wtnp", "^"
      text.sub!(/\001\z/, "")   # fix: '$' can match end of line as well
    when "op"
      control_params[:appear_timer_start] = System.uptime
    when "cl"
      text.sub!(/\001\z/, "")   # fix: '$' can match end of line as well
      control_params[:slide_off_at_close] = true
      control_params[:end_se] = param
    end
  end
end

def pbMessageDisplay_PositionExtraSprites(msg_window, extra_sprites)
  if extra_sprites[:face_window]
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
    extra_sprites[:face_window].viewport = msg_window.viewport
    extra_sprites[:face_window].z        = msg_window.z
  end
end

def pbMessageDisplay_UpdateMessageWindowSlideOn(msg_window, control_params, extra_sprites)
  if control_params[:appear_timer_start]
    y_start = (control_params[:msg_window_at_top]) ? -msg_window.height : Graphics.height
    y_end = (control_params[:msg_window_at_top]) ? 0 : Graphics.height - msg_window.height
    msg_window.y = lerp(y_start, y_end, control_params[:appear_duration],
                        control_params[:appear_timer_start], System.uptime)
    control_params[:appear_timer_start] = nil if msg_window.y == y_end
  end
end

def pbMessageDisplay_UpdateControl(control, msg_window, control_params, extra_sprites)
  param = control[1]
  case control[0]
  when "f"
    extra_sprites[:face_window]&.dispose
    extra_sprites[:face_window] = PictureWindow.new("Graphics/Pictures/#{param}")
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
    extra_sprites[:face_window].viewport = msg_window.viewport
    extra_sprites[:face_window].z        = msg_window.z
  when "ff"
    extra_sprites[:face_window]&.dispose
    extra_sprites[:face_window] = FaceWindowVX.new(param)
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
    extra_sprites[:face_window].viewport = msg_window.viewport
    extra_sprites[:face_window].z        = msg_window.z
  when "ts"     # Change text speed
    msg_window.textspeed = (param == "") ? 0 : param.to_i / 80.0
  when "me"     # Play ME
    pbMEPlay(pbStringToAudioFile(param))
  when "se"     # Play SE
    pbSEPlay(pbStringToAudioFile(param))
  when "wtnp"   # Wait X/20 seconds, no pause
    param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
    msg_window.waitcount = param.to_i / 20.0
    control_params[:auto_resume] = true
  when "wt"     # Wait X/20 seconds
    param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
    msg_window.waitcount += param.to_i / 20.0
  when "g"      # Display gold window
    extra_sprites[:gold_window]&.dispose
    extra_sprites[:gold_window] = pbDisplayGoldWindow(msg_window)
  when "cn"     # Display coins window
    extra_sprites[:coins_window]&.dispose
    extra_sprites[:coins_window] = pbDisplayCoinsWindow(msg_window, extra_sprites[:gold_window])
  when "pt"     # Display battle points window
    extra_sprites[:battle_points_window]&.dispose
    extra_sprites[:battle_points_window] = pbDisplayBattlePointsWindow(msg_window)
  when "wd"     # Put message window at the bottom of the screen
    control_params[:msg_window_at_top] = false
    msg_window.y = Graphics.height - msg_window.height
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
    if control_params[:appear_timer_start]   # If sliding in, recalculate position
      msg_window.y = lerp(y_start, y_end, control_params[:appear_duration],
                          control_params[:appear_timer_start], System.uptime)
    end
  when "wm"     # Put message window in the middle of the screen
    control_params[:msg_window_at_top] = false
    msg_window.y = (Graphics.height - msg_window.height) / 2
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
  when "wu"     # Put message window at the top of the screen
    control_params[:msg_window_at_top] = true
    msg_window.y = 0
    pbPositionNearMsgWindow(extra_sprites[:face_window], msg_window, :left)
    if control_params[:appear_timer_start]
      msg_window.y = lerp(y_start, y_end, control_params[:appear_duration],
                          control_params[:appear_timer_start], System.uptime)
    end
  when "."      # Wait 0.25 seconds
    msg_window.waitcount += 0.25
  when "|"      # Wait 1 second
    msg_window.waitcount += 1.0
  when "^"      # Wait, no pause
    control_params[:auto_resume] = true
  end
end

def pbMessageDisplay_AfterMessageAppeared(msg_window, control_params, extra_sprites)
  if control_params[:choices]
    $game_variables[control_params[:choice_variable]] = pbShowCommands(
      msg_window, control_params[:choices], control_params[:choice_if_cancel]
    )
    $game_map.need_refresh = true if $game_map
  end
end

def pbMessageDisplay_MessageWindowSlideOff(msg_window, control_params)
  if control_params[:slide_off_at_close]
    pbSEPlay(pbStringToAudioFile(control_params[:end_se]))
    msg_window_at_top = (msg_window.y == 0)
    y_start = (msg_window_at_top) ? 0 : Graphics.height - msg_window.height
    y_end = (msg_window_at_top) ? -msg_window.height : Graphics.height
    disappear_timer_start = System.uptime
    loop do
      msg_window.y = lerp(y_start, y_end, control_params[:disappear_duration],
                          disappear_timer_start, System.uptime)
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msg_window.update
      break if msg_window.y == y_end
    end
  end
end

#===============================================================================
# Message-displaying functions.
#===============================================================================
def pbMessage(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwndw|
                             next Kernel.pbShowCommands(msgwndw, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow)
  Input.update
  return ret
end

def pbConfirmMessage(message, &block)
  return (pbMessage(message, [_INTL("Yes"), _INTL("No")], 2, &block) == 0)
end

def pbConfirmMessageSerious(message, &block)
  return (pbMessage(message, [_INTL("No"), _INTL("Yes")], 1, &block) == 1)
end

def pbMessageChooseNumber(message, params, &block)
  msgwindow = pbCreateMessageWindow(nil, params.messageSkin)
  ret = pbMessageDisplay(msgwindow, message, true,
                         proc { |msgwndw|
                           next pbChooseNumber(msgwndw, params, &block)
                         }, &block)
  pbDisposeMessageWindow(msgwindow)
  return ret
end

def pbShowCommands(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0)
  return 0 if !commands
  cmdwindow = Window_AdvancedCommandPokemon.new(commands)
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.resizeToFit(cmdwindow.commands)
  pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
  cmdwindow.index = defaultCmd
  command = 0
  loop do
    Graphics.update
    Input.update
    msgwindow&.update
    cmdwindow.update
    yield if block_given?
    if Input.trigger?(Input::BACK)
      if cmdIfCancel > 0
        command = cmdIfCancel - 1
        break
      elsif cmdIfCancel < 0
        command = cmdIfCancel
        break
      end
    end
    if Input.trigger?(Input::USE)
      command = cmdwindow.index
      break
    end
    pbUpdateSceneMap
  end
  ret = command
  cmdwindow.dispose
  Input.update
  return ret
end

def pbShowCommandsWithHelp(msgwindow, commands, help, cmdIfCancel = 0, defaultCmd = 0)
  msgwin = msgwindow
  msgwin = pbCreateMessageWindow(nil) if !msgwindow
  oldlbl = msgwin.letterbyletter
  msgwin.letterbyletter = false
  if commands
    cmdwindow = Window_AdvancedCommandPokemon.new(commands)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = msgwin.y if cmdwindow.height > msgwin.y
    cmdwindow.index = defaultCmd
    command = 0
    msgwin.text = help[cmdwindow.index]
    msgwin.width = msgwin.width   # Necessary evil to make it use the proper margins
    loop do
      Graphics.update
      Input.update
      oldindex = cmdwindow.index
      cmdwindow.update
      msgwin.text = help[cmdwindow.index] if oldindex != cmdwindow.index
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel > 0
          command = cmdIfCancel - 1
          break
        elsif cmdIfCancel < 0
          command = cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE)
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
  end
  msgwin.letterbyletter = oldlbl
  pbDisposeMessageWindow(msgwin) if !msgwindow
  return ret
end

# frames is the number of 1/20 seconds to wait for
def pbMessageWaitForInput(msgwindow, frames, showPause = false)
  return if !frames || frames <= 0
  msgwindow.startPause if msgwindow && showPause
  timer_start = System.uptime
  loop do
    Graphics.update
    Input.update
    msgwindow&.update
    pbUpdateSceneMap
    yield if block_given?
    break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
    break if System.uptime - timer_start >= frames / 20.0
  end
  msgwindow.stopPause if msgwindow && showPause
end

def pbFreeText(msgwindow, currenttext, passwordbox, maxlength, width = 240)
  window = Window_TextEntry_Keyboard.new(currenttext, 0, 0, width, 64)
  ret = ""
  window.maxlength = maxlength
  window.visible = true
  window.z = 99999
  pbPositionNearMsgWindow(window, msgwindow, :right)
  window.text = currenttext
  window.passwordChar = "*" if passwordbox
  Input.text_input = true
  loop do
    Graphics.update
    Input.update
    if Input.triggerex?(:ESCAPE)
      ret = currenttext
      break
    elsif Input.triggerex?(:RETURN)
      ret = window.text
      break
    end
    window.update
    msgwindow&.update
    yield if block_given?
  end
  Input.text_input = false
  window.dispose
  Input.update
  return ret
end

def pbMessageFreeText(message, currenttext, passwordbox, maxlength, width = 240, &block)
  msgwindow = pbCreateMessageWindow
  retval = pbMessageDisplay(msgwindow, message, true,
                            proc { |msgwndw|
                              next pbFreeText(msgwndw, currenttext, passwordbox, maxlength, width, &block)
                            }, &block)
  pbDisposeMessageWindow(msgwindow)
  return retval
end
