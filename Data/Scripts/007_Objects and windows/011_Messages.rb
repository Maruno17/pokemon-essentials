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
    ret = 0
    if @maxDigits > 0
      ret = -((10**@maxDigits) - 1)
    else
      ret = @minNumber
    end
    ret = 0 if !@negativeAllowed && ret < 0
    return ret
  end

  def maxNumber
    ret = 0
    if @maxDigits > 0
      ret = ((10**@maxDigits) - 1)
    else
      ret = @maxNumber
    end
    ret = 0 if !@negativeAllowed && ret < 0
    return ret
  end

  def setMaxDigits(value)
    @maxDigits = [1, value].max
  end

  def maxDigits
    if @maxDigits > 0
      return @maxDigits
    else
      return [numDigits(self.minNumber), numDigits(self.maxNumber)].max
    end
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
  if nil_or_empty?(name)
    name = pbGetBasicMapNameFromId(id)
    name.gsub!(/\\PN/, $player.name) if $player
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
# Money and coins windows
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
# Main message-displaying function
#===============================================================================
def pbMessageDisplay(msgwindow, message, letterbyletter = true, commandProc = nil)
  return if !msgwindow
  oldletterbyletter = msgwindow.letterbyletter
  msgwindow.letterbyletter = (letterbyletter) ? true : false
  ret = nil
  commands = nil
  facewindow = nil
  goldwindow = nil
  coinwindow = nil
  battlepointswindow = nil
  cmdvariable = 0
  cmdIfCancel = 0
  msgwindow.waitcount = 0
  autoresume = false
  text = message.clone
  linecount = (Graphics.height > 400) ? 3 : 2
  ### Text replacement
  text.gsub!(/\\sign\[([^\]]*)\]/i) do      # \sign[something] gets turned into
    next "\\op\\cl\\ts[]\\w[" + $1 + "]"    # \op\cl\ts[]\w[something]
  end
  text.gsub!(/\\\\/, "\5")
  text.gsub!(/\\1/, "\1")
  if $game_actors
    text.gsub!(/\\n\[([1-8])\]/i) { next $game_actors[$1.to_i].name }
  end
  text.gsub!(/\\pn/i,  $player.name) if $player
  text.gsub!(/\\pm/i,  _INTL("${1}", $player.money.to_s_formatted)) if $player
  text.gsub!(/\\n/i,   "\n")
  text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + $1 + ">" }
  text.gsub!(/\\pg/i,  "\\b") if $player&.male?
  text.gsub!(/\\pg/i,  "\\r") if $player&.female?
  text.gsub!(/\\pog/i, "\\r") if $player&.male?
  text.gsub!(/\\pog/i, "\\b") if $player&.female?
  text.gsub!(/\\pg/i,  "")
  text.gsub!(/\\pog/i, "")
  male_text_tag = shadowc3tag(MessageConfig::MALE_TEXT_MAIN_COLOR, MessageConfig::MALE_TEXT_SHADOW_COLOR)
  female_text_tag = shadowc3tag(MessageConfig::FEMALE_TEXT_MAIN_COLOR, MessageConfig::FEMALE_TEXT_SHADOW_COLOR)
  text.gsub!(/\\b/i,   male_text_tag)
  text.gsub!(/\\r/i,   female_text_tag)
  text.gsub!(/\\[Ww]\[([^\]]*)\]/) do
    w = $1.to_s
    if w == ""
      msgwindow.windowskin = nil
    else
      msgwindow.setSkin("Graphics/Windowskins/#{w}", false)
    end
    next ""
  end
  isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
  text.gsub!(/\\c\[([0-9]+)\]/i) do
    next getSkinColor(msgwindow.windowskin, $1.to_i, isDarkSkin)
  end
  loop do
    last_text = text.clone
    text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    break if text == last_text
  end
  loop do
    last_text = text.clone
    text.gsub!(/\\l\[([0-9]+)\]/i) do
      linecount = [1, $1.to_i].max
      next ""
    end
    break if text == last_text
  end
  colortag = ""
  if $game_system && $game_system.message_frame != 0
    colortag = getSkinColor(msgwindow.windowskin, 0, true)
  else
    colortag = getSkinColor(msgwindow.windowskin, 0, isDarkSkin)
  end
  text = colortag + text
  ### Controls
  textchunks = []
  controls = []
  while text[/(?:\\(f|ff|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase, $~[2], -1])
    else
      controls.push([$~[3].downcase, "", -1])
    end
    text = $~.post_match
  end
  textchunks.push(text)
  textchunks.each do |chunk|
    chunk.gsub!(/\005/, "\\")
  end
  textlen = 0
  controls.length.times do |i|
    control = controls[i][0]
    case control
    when "wt", "wtnp", ".", "|"
      textchunks[i] += "\2"
    when "!"
      textchunks[i] += "\1"
    end
    textlen += toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2] = textlen
  end
  text = textchunks.join
  appear_timer_start = nil
  appear_duration = 0.5   # In seconds
  haveSpecialClose = false
  specialCloseSE = ""
  startSE = nil
  controls.length.times do |i|
    control = controls[i][0]
    param = controls[i][1]
    case control
    when "op"
      appear_timer_start = System.uptime
    when "cl"
      text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
      haveSpecialClose = true
      specialCloseSE = param
    when "f"
      facewindow&.dispose
      facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
    when "ff"
      facewindow&.dispose
      facewindow = FaceWindowVX.new(param)
    when "ch"
      cmds = param.clone
      cmdvariable = pbCsvPosInt!(cmds)
      cmdIfCancel = pbCsvField!(cmds).to_i
      commands = []
      while cmds.length > 0
        commands.push(pbCsvField!(cmds))
      end
    when "wtnp", "^"
      text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
    when "se"
      if controls[i][2] == 0
        startSE = param
        controls[i] = nil
      end
    end
  end
  if startSE
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif !appear_timer_start && letterbyletter
    pbPlayDecisionSE
  end
  # Position message window
  pbRepositionMessageWindow(msgwindow, linecount)
  if facewindow
    pbPositionNearMsgWindow(facewindow, msgwindow, :left)
    facewindow.viewport = msgwindow.viewport
    facewindow.z        = msgwindow.z
  end
  atTop = (msgwindow.y == 0)
  # Show text
  msgwindow.text = text
  loop do
    if appear_timer_start
      y_start = (atTop) ? -msgwindow.height : Graphics.height
      y_end = (atTop) ? 0 : Graphics.height - msgwindow.height
      msgwindow.y = lerp(y_start, y_end, appear_duration, appear_timer_start, System.uptime)
      appear_timer_start = nil if msgwindow.y == y_end
    end
    controls.length.times do |i|
      next if !controls[i]
      next if controls[i][2] > msgwindow.position || msgwindow.waitcount != 0
      control = controls[i][0]
      param = controls[i][1]
      case control
      when "f"
        facewindow&.dispose
        facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        pbPositionNearMsgWindow(facewindow, msgwindow, :left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
      when "ff"
        facewindow&.dispose
        facewindow = FaceWindowVX.new(param)
        pbPositionNearMsgWindow(facewindow, msgwindow, :left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
      when "g"      # Display gold window
        goldwindow&.dispose
        goldwindow = pbDisplayGoldWindow(msgwindow)
      when "cn"     # Display coins window
        coinwindow&.dispose
        coinwindow = pbDisplayCoinsWindow(msgwindow, goldwindow)
      when "pt"     # Display battle points window
        battlepointswindow&.dispose
        battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
      when "wu"
        atTop = true
        msgwindow.y = 0
        pbPositionNearMsgWindow(facewindow, msgwindow, :left)
        if appear_timer_start
          msgwindow.y = lerp(y_start, y_end, appear_duration, appear_timer_start, System.uptime)
        end
      when "wm"
        atTop = false
        msgwindow.y = (Graphics.height - msgwindow.height) / 2
        pbPositionNearMsgWindow(facewindow, msgwindow, :left)
      when "wd"
        atTop = false
        msgwindow.y = Graphics.height - msgwindow.height
        pbPositionNearMsgWindow(facewindow, msgwindow, :left)
        if appear_timer_start
          msgwindow.y = lerp(y_start, y_end, appear_duration, appear_timer_start, System.uptime)
        end
      when "ts"     # Change text speed
        msgwindow.textspeed = (param == "") ? 0 : param.to_i / 80.0
      when "."      # Wait 0.25 seconds
        msgwindow.waitcount += 0.25
      when "|"      # Wait 1 second
        msgwindow.waitcount += 1.0
      when "wt"     # Wait X/20 seconds
        param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
        msgwindow.waitcount += param.to_i / 20.0
      when "wtnp"   # Wait X/20 seconds, no pause
        param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
        msgwindow.waitcount = param.to_i / 20.0
        autoresume = true
      when "^"      # Wait, no pause
        autoresume = true
      when "se"     # Play SE
        pbSEPlay(pbStringToAudioFile(param))
      when "me"     # Play ME
        pbMEPlay(pbStringToAudioFile(param))
      end
      controls[i] = nil
    end
    break if !letterbyletter
    Graphics.update
    Input.update
    facewindow&.update
    if autoresume && msgwindow.waitcount == 0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      if msgwindow.busy?
        pbPlayDecisionSE if msgwindow.pausing?
        msgwindow.resume
      elsif !appear_timer_start
        break
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
    break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  end
  Input.update   # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter = oldletterbyletter
  if commands
    $game_variables[cmdvariable] = pbShowCommands(msgwindow, commands, cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  ret = commandProc.call(msgwindow) if commandProc
  goldwindow&.dispose
  coinwindow&.dispose
  battlepointswindow&.dispose
  facewindow&.dispose
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop = (msgwindow.y == 0)
    y_start = (atTop) ? 0 : Graphics.height - msgwindow.height
    y_end = (atTop) ? -msgwindow.height : Graphics.height
    disappear_duration = 0.5   # In seconds
    disappear_timer_start = System.uptime
    loop do
      msgwindow.y = lerp(y_start, y_end, disappear_duration, disappear_timer_start, System.uptime)
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
      break if msgwindow.y == y_end
    end
  end
  return ret
end

#===============================================================================
# Message-displaying functions
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
  cmdwindow = Window_CommandPokemonEx.new(commands)
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.resizeToFit(cmdwindow.commands)
  pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
  cmdwindow.index = defaultCmd
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    msgwindow&.update
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
    cmdwindow = Window_CommandPokemonEx.new(commands)
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
