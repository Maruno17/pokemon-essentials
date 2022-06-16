################################################################################
# "Slot Machine" mini-game
# By Maruno
#-------------------------------------------------------------------------------
# Run with:      pbSlotMachine(1)
# - The number is either 0 (easy), 1 (default) or 2 (hard).
################################################################################
class SlotMachineReel < BitmapSprite
  attr_accessor :reel
  attr_accessor :toppos
  attr_accessor :spinning
  attr_accessor :stopping
  attr_accessor :slipping

  SCROLLSPEED = 16   # Must be a divisor of 48
  ICONSPOOL = [[0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7], # 0 - Easy
               [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 6, 7],       # 1 - Medium (default)
               [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 6, 7]]             # 2 - Hard
  SLIPPING = [0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3]

  def initialize(x, y, difficulty = 1)
    @viewport = Viewport.new(x, y, 64, 144)
    @viewport.z = 99999
    super(64, 144, @viewport)
    @reel = []
    ICONSPOOL[difficulty].length.times do |i|
      @reel.push(ICONSPOOL[difficulty][i])
    end
    @reel.shuffle!
    @toppos = 0
    @spinning = false
    @stopping = false
    @slipping = 0
    @index = rand(@reel.length)
    @images = AnimatedBitmap.new(_INTL("Graphics/Pictures/Slot Machine/images"))
    @shading = AnimatedBitmap.new("Graphics/Pictures/Slot Machine/ReelOverlay")
    update
  end

  def startSpinning
    @spinning = true
  end

  def stopSpinning(noslipping = false)
    @stopping = true
    @slipping = SLIPPING[rand(SLIPPING.length)]
    @slipping = 0 if noslipping
  end

  def showing
    array = []
    3.times do |i|
      num = @index - i
      num += @reel.length if num < 0
      array.push(@reel[num])
    end
    return array   # [0] = top, [1] = middle, [2] = bottom
  end

  def update
    self.bitmap.clear
    if @toppos == 0 && @stopping && @slipping == 0
      @spinning = @stopping = false
    end
    if @spinning
      @toppos += SCROLLSPEED
      if @toppos > 0
        @toppos -= 48
        @index = (@index + 1) % @reel.length
        @slipping -= 1 if @slipping > 0
      end
    end
    4.times do |i|
      num = @index - i
      num += @reel.length if num < 0
      self.bitmap.blt(0, @toppos + (i * 48), @images.bitmap, Rect.new(@reel[num] * 64, 0, 64, 48))
    end
    self.bitmap.blt(0, 0, @shading.bitmap, Rect.new(0, 0, 64, 144))
  end
end



class SlotMachineScore < BitmapSprite
  attr_reader :score

  def initialize(x, y, score = 0)
    @viewport = Viewport.new(x, y, 70, 22)
    @viewport.z = 99999
    super(70, 22, @viewport)
    @numbers = AnimatedBitmap.new("Graphics/Pictures/Slot Machine/numbers")
    self.score = score
  end

  def score=(value)
    @score = value
    @score = Settings::MAX_COINS if @score > Settings::MAX_COINS
    refresh
  end

  def refresh
    self.bitmap.clear
    5.times do |i|
      digit = (@score / (10**i)) % 10 # Least significant digit first
      self.bitmap.blt(14 * (4 - i), 0, @numbers.bitmap, Rect.new(digit * 14, 0, 14, 22))
    end
  end
end



class SlotMachineScene
  attr_accessor :gameRunning
  attr_accessor :gameEnd
  attr_accessor :wager
  attr_accessor :replay

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbPayout
    @replay = false
    payout = 0
    bonus = 0
    wonRow = []
    # Get reel pictures
    reel1 = @sprites["reel1"].showing
    reel2 = @sprites["reel2"].showing
    reel3 = @sprites["reel3"].showing
    combinations = [[reel1[1], reel2[1], reel3[1]], # Centre row
                    [reel1[0], reel2[0], reel3[0]], # Top row
                    [reel1[2], reel2[2], reel3[2]], # Bottom row
                    [reel1[0], reel2[1], reel3[2]], # Diagonal top left -> bottom right
                    [reel1[2], reel2[1], reel3[0]]] # Diagonal bottom left -> top right
    combinations.length.times do |i|
      break if i >= 1 && @wager <= 1 # One coin = centre row only
      break if i >= 3 && @wager <= 2 # Two coins = three rows only
      wonRow[i] = true
      case combinations[i]
      when [1, 1, 1]   # Three Magnemites
        payout += 8
      when [2, 2, 2]   # Three Shellders
        payout += 8
      when [3, 3, 3]   # Three Pikachus
        payout += 15
      when [4, 4, 4]   # Three Psyducks
        payout += 15
      when [5, 5, 6], [5, 6, 5], [6, 5, 5], [6, 6, 5], [6, 5, 6], [5, 6, 6]   # 777 multi-colored
        payout += 90
        bonus = 1 if bonus < 1
      when [5, 5, 5], [6, 6, 6]   # Red 777, blue 777
        payout += 300
        bonus = 2 if bonus < 2
      when [7, 7, 7]   # Three replays
        @replay = true
      else
        if combinations[i][0] == 0   # Left cherry
          if combinations[i][1] == 0   # Centre cherry as well
            payout += 4
          else
            payout += 2
          end
        else
          wonRow[i] = false
        end
      end
    end
    @sprites["payout"].score = payout
    frame = 0
    if payout > 0 || @replay
      if bonus > 0
        pbMEPlay("Slots big win")
      else
        pbMEPlay("Slots win")
      end
      # Show winning animation
      timePerFrame = Graphics.frame_rate / 8
      until frame == Graphics.frame_rate * 3
        Graphics.update
        Input.update
        update
        @sprites["window2"].bitmap&.clear
        @sprites["window1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/win"))
        @sprites["window1"].src_rect.set(152 * ((frame / timePerFrame) % 4), 0, 152, 208)
        if bonus > 0
          @sprites["window2"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/bonus"))
          @sprites["window2"].src_rect.set(152 * (bonus - 1), 0, 152, 208)
        end
        @sprites["light1"].visible = true
        @sprites["light1"].src_rect.set(0, 26 * ((frame / timePerFrame) % 4), 96, 26)
        @sprites["light2"].visible = true
        @sprites["light2"].src_rect.set(0, 26 * ((frame / timePerFrame) % 4), 96, 26)
        (1..5).each do |i|
          if wonRow[i - 1]
            @sprites["row#{i}"].visible = (frame / timePerFrame).even?
          else
            @sprites["row#{i}"].visible = false
          end
        end
        frame += 1
      end
      @sprites["light1"].visible = false
      @sprites["light2"].visible = false
      @sprites["window1"].src_rect.set(0, 0, 152, 208)
      # Pay out
      loop do
        break if @sprites["payout"].score <= 0
        Graphics.update
        Input.update
        update
        @sprites["payout"].score -= 1
        @sprites["credit"].score += 1
        if Input.trigger?(Input::USE) || @sprites["credit"].score == Settings::MAX_COINS
          @sprites["credit"].score += @sprites["payout"].score
          @sprites["payout"].score = 0
        end
      end
      (Graphics.frame_rate / 2).times do
        Graphics.update
        Input.update
        update
      end
    else
      # Show losing animation
      timePerFrame = Graphics.frame_rate / 4
      until frame == Graphics.frame_rate * 2
        Graphics.update
        Input.update
        update
        @sprites["window2"].bitmap&.clear
        @sprites["window1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/lose"))
        @sprites["window1"].src_rect.set(152 * ((frame / timePerFrame) % 2), 0, 152, 208)
        frame += 1
      end
    end
    @wager = 0
  end

  def pbStartScene(difficulty)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "bg", "Slot Machine/bg", @viewport)
    @sprites["reel1"] = SlotMachineReel.new(64, 112, difficulty)
    @sprites["reel2"] = SlotMachineReel.new(144, 112, difficulty)
    @sprites["reel3"] = SlotMachineReel.new(224, 112, difficulty)
    (1..3).each do |i|
      @sprites["button#{i}"] = IconSprite.new(68 + (80 * (i - 1)), 260, @viewport)
      @sprites["button#{i}"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/button"))
      @sprites["button#{i}"].visible = false
    end
    (1..5).each do |i|
      y = [170, 122, 218, 82, 82][i - 1]
      @sprites["row#{i}"] = IconSprite.new(2, y, @viewport)
      @sprites["row#{i}"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/line%1d%s",
                                            1 + (i / 2), (i >= 4) ? ((i == 4) ? "a" : "b") : ""))
      @sprites["row#{i}"].visible = false
    end
    @sprites["light1"] = IconSprite.new(16, 32, @viewport)
    @sprites["light1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/lights"))
    @sprites["light1"].visible = false
    @sprites["light2"] = IconSprite.new(240, 32, @viewport)
    @sprites["light2"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/lights"))
    @sprites["light2"].mirror = true
    @sprites["light2"].visible = false
    @sprites["window1"] = IconSprite.new(358, 96, @viewport)
    @sprites["window1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/insert"))
    @sprites["window1"].src_rect.set(0, 0, 152, 208)
    @sprites["window2"] = IconSprite.new(358, 96, @viewport)
    @sprites["credit"] = SlotMachineScore.new(360, 66, $player.coins)
    @sprites["payout"] = SlotMachineScore.new(438, 66, 0)
    @wager = 0
    update
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    frame = 0
    spinFrameTime   = Graphics.frame_rate / 4
    insertFrameTime = Graphics.frame_rate * 4 / 10
    loop do
      Graphics.update
      Input.update
      update
      @sprites["window1"].bitmap&.clear
      @sprites["window2"].bitmap&.clear
      if @sprites["credit"].score == Settings::MAX_COINS
        pbMessage(_INTL("You've got {1} Coins.", Settings::MAX_COINS.to_s_formatted))
        break
      elsif $player.coins == 0
        pbMessage(_INTL("You've run out of Coins.\nGame over!"))
        break
      elsif @gameRunning   # Reels are spinning
        @sprites["window1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/stop"))
        @sprites["window1"].src_rect.set(152 * ((frame / spinFrameTime) % 4), 0, 152, 208)
        if Input.trigger?(Input::USE)
          pbSEPlay("Slots stop")
          if @sprites["reel1"].spinning
            @sprites["reel1"].stopSpinning(@replay)
            @sprites["button1"].visible = true
          elsif @sprites["reel2"].spinning
            @sprites["reel2"].stopSpinning(@replay)
            @sprites["button2"].visible = true
          elsif @sprites["reel3"].spinning
            @sprites["reel3"].stopSpinning(@replay)
            @sprites["button3"].visible = true
          end
        end
        if !@sprites["reel3"].spinning
          @gameEnd = true
          @gameRunning = false
        end
      elsif @gameEnd   # Reels have been stopped
        pbPayout
        # Reset graphics
        @sprites["button1"].visible = false
        @sprites["button2"].visible = false
        @sprites["button3"].visible = false
        (1..5).each do |i|
          @sprites["row#{i}"].visible = false
        end
        @gameEnd = false
      else   # Awaiting coins for the next spin
        @sprites["window1"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/insert"))
        @sprites["window1"].src_rect.set(152 * ((frame / insertFrameTime) % 2), 0, 152, 208)
        if @wager > 0
          @sprites["window2"].setBitmap(sprintf("Graphics/Pictures/Slot Machine/press"))
          @sprites["window2"].src_rect.set(152 * ((frame / insertFrameTime) % 2), 0, 152, 208)
        end
        if Input.trigger?(Input::DOWN) && @wager < 3 && @sprites["credit"].score > 0
          pbSEPlay("Slots coin")
          @wager += 1
          @sprites["credit"].score -= 1
          if @wager >= 3
            @sprites["row5"].visible = true
            @sprites["row4"].visible = true
          elsif @wager >= 2
            @sprites["row3"].visible = true
            @sprites["row2"].visible = true
          elsif @wager >= 1
            @sprites["row1"].visible = true
          end
        elsif @wager >= 3 || (@wager > 0 && @sprites["credit"].score == 0) ||
              (Input.trigger?(Input::USE) && @wager > 0) || @replay
          if @replay
            @wager = 3
            (1..5).each do |i|
              @sprites["row#{i}"].visible = true
            end
          end
          @sprites["reel1"].startSpinning
          @sprites["reel2"].startSpinning
          @sprites["reel3"].startSpinning
          frame = 0
          @gameRunning = true
        elsif Input.trigger?(Input::BACK) && @wager == 0
          break
        end
      end
      frame = (frame + 1) % (Graphics.frame_rate * 4)
    end
    old_coins = $player.coins
    $player.coins = @sprites["credit"].score
    if $player.coins > old_coins
      $stats.coins_won += $player.coins - old_coins
    elsif $player.coins < old_coins
      $stats.coins_lost += old_coins - $player.coins
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class SlotMachine
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(difficulty)
    @scene.pbStartScene(difficulty)
    @scene.pbMain
    @scene.pbEndScene
  end
end



def pbSlotMachine(difficulty = 1)
  if !$bag.has?(:COINCASE)
    pbMessage(_INTL("It's a Slot Machine."))
  elsif $player.coins == 0
    pbMessage(_INTL("You don't have any Coins to play!"))
  elsif $player.coins == Settings::MAX_COINS
    pbMessage(_INTL("Your Coin Case is full!"))
  else
    pbFadeOutIn {
      scene = SlotMachineScene.new
      screen = SlotMachine.new(scene)
      screen.pbStartScreen(difficulty)
    }
  end
end
