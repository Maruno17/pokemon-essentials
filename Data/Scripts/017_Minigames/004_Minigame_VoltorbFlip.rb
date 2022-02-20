#===============================================================================
# "Voltorb Flip" mini-game
# By KitsuneKouta
#-------------------------------------------------------------------------------
# Run with:      pbVoltorbFlip
#===============================================================================
class VoltorbFlip
  # Ranges of total coins available in each level.
  LEVEL_RANGES = [[20, 50],
                  [50, 100],
                  [100, 200],
                  [200, 350],
                  [350, 600],
                  [600, 1000],
                  [1000, 2000],
                  [2000, 3500]]

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStart
    @level = 1
    @firstRound = true
    pbNewGame
  end

  def pbNewGame
    # Initialize variables
    @sprites = {}
    @cursor = []
    @marks = []
    @coins = []
    @numbers = []
    @voltorbNumbers = []
    @points = 0
    @index = [0, 0]
    # [x,y,points,selected]
    @squares = [0, 0, 0, false]
    @directory = "Graphics/Pictures/Voltorb Flip/"
    squareValues = []
    total = 1
    voltorbs = 0
    25.times do |i|
      # Sets the value to 1 by default
      squareValues[i] = 1
      # Sets the value to 0 (a voltorb) if # for that level hasn't been reached
      if voltorbs < 5 + @level
        squareValues[i] = 0
        voltorbs += 1
      # Sets the value randomly to a 2 or 3 if the total is less than the max
      elsif total < LEVEL_RANGES[@level - 1][1]
        squareValues[i] = rand(2..3)
        total *= squareValues[i]
      end
      next if total <= LEVEL_RANGES[@level - 1][1]
      # Lowers value of square to 1 if over max
      total /= squareValues[i]
      squareValues[i] = 1
    end
    # Randomize the values a little
    25.times do |i|
      temp = squareValues[i]
      if squareValues[i] > 1 && rand(10) == 0
        total /= squareValues[i]
        squareValues[i] -= 1
        total *= squareValues[i]
      end
      next if total >= LEVEL_RANGES[@level - 1][0] || squareValues[i] <= 0
      total /= squareValues[i]
      squareValues[i] = temp
      total *= squareValues[i]
    end
    # Populate @squares array
    25.times do |i|
      r = rand(squareValues.length)
      @squares[i] = [((i % 5) * 64) + 128, (i / 5).abs * 64, squareValues[r], false]
      squareValues.delete_at(r)
    end
    pbCreateSprites
    # Display numbers (all zeroes, as no values have been calculated yet)
    5.times do |i|
      pbUpdateRowNumbers(0, 0, i)
      pbUpdateColumnNumbers(0, 0, i)
    end
    pbDrawShadowText(@sprites["text"].bitmap, 8, 22, 118, 26,
                     _INTL("Your coins"), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    pbDrawShadowText(@sprites["text"].bitmap, 8, 88, 118, 26,
                     _INTL("Prize coins"), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    # Draw current level
    pbDrawShadowText(@sprites["level"].bitmap, 8, 154, 118, 28,
                     _INTL("Level {1}", @level.to_s), Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
    # Displays total and current coins
    pbUpdateCoins
    # Draw curtain effect
    if @firstRound
      angleDiff = 10 * 20 / Graphics.frame_rate
      loop do
        @sprites["curtainL"].angle -= angleDiff
        @sprites["curtainR"].angle += angleDiff
        Graphics.update
        Input.update
        update
        break if @sprites["curtainL"].angle <= -180
      end
    end
    @sprites["curtainL"].visible = false
    @sprites["curtainR"].visible = false
    @sprites["curtain"].opacity = 100
    if $player.coins >= Settings::MAX_COINS
      pbMessage(_INTL("You've gathered {1} Coins. You cannot gather any more.", Settings::MAX_COINS.to_s_formatted))
      $player.coins = Settings::MAX_COINS   # As a precaution
      @quit = true
#    elsif !pbConfirmMessage(_INTL("Play Voltorb Flip Lv. {1}?",@level)) && $player.coins<Settings::MAX_COINS
#      @quit=true
    else
      @sprites["curtain"].opacity = 0
      # Erase 0s to prepare to replace with values
      @sprites["numbers"].bitmap.clear
      # Reset arrays to empty
      @voltorbNumbers = []
      @numbers = []
      # Draw numbers for each row (precautionary)
      @squares.length.times do |i|
        next if (i % 5) != 0
        num = 0
        voltorbs = 0
        j = i + 5
        (i...j).each do |k|
          num += @squares[k][2]
          voltorbs += 1 if @squares[k][2] == 0
        end
        pbUpdateRowNumbers(num, voltorbs, i / 5)
      end
      # Reset arrays to empty
      @voltorbNumbers = []
      @numbers = []
      # Draw numbers for each column
      5.times do |i|
        num = 0
        voltorbs = 0
        5.times do |j|
          num += @squares[i + (j * 5)][2]
          voltorbs += 1 if @squares[i + (j * 5)][2] == 0
        end
        pbUpdateColumnNumbers(num, voltorbs, i)
      end
    end
  end

  def pbCreateSprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = RPG::Cache.load_bitmap(@directory, "boardbg")
    @sprites["text"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["level"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["level"].bitmap)
    @sprites["curtain"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["curtain"].z = 99999
    @sprites["curtain"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites["curtain"].opacity = 0
    @sprites["curtainL"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["curtainL"].z = 99999
    @sprites["curtainL"].x = Graphics.width / 2
    @sprites["curtainL"].angle = -90
    @sprites["curtainL"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites["curtainR"] = BitmapSprite.new(Graphics.width, Graphics.height * 2, @viewport)
    @sprites["curtainR"].z = 99999
    @sprites["curtainR"].x = Graphics.width / 2
    @sprites["curtainR"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height * 2, Color.new(0, 0, 0))
    @sprites["cursor"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["cursor"].z = 99998
    @sprites["icon"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["icon"].z = 99997
    @sprites["mark"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["memo"] = Sprite.new(@viewport)
    @sprites["memo"].bitmap = RPG::Cache.load_bitmap(@directory, "memo")
    @sprites["memo"].x = 10
    @sprites["memo"].y = 244
    @sprites["memo"].visible = false
    @sprites["numbers"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["totalCoins"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["currentCoins"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["animation"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["animation"].z = 99999
    6.times do |i|
      @sprites[i] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[i].z = 99996
      @sprites[i].visible = false
    end
    # Creates images ahead of time for the display-all animation (reduces lag)
    icons = []
    points = 0
    3.times do |i|
      25.times do |j|
        points = @squares[j][2] if i == 2
        icons[j] = [@directory + "tiles", @squares[j][0], @squares[j][1], 320 + (i * 64) + (points * 64), 0, 64, 64]
      end
      icons.compact!
      pbDrawImagePositions(@sprites[i].bitmap, icons)
    end
    icons = []
    25.times do |i|
      icons[i] = [@directory + "tiles", @squares[i][0], @squares[i][1], @squares[i][2] * 64, 0, 64, 64]
    end
    pbDrawImagePositions(@sprites[5].bitmap, icons)
    # Default cursor image
    @cursor[0] = [@directory + "cursor", 0 + 128, 0, 0, 0, 64, 64]
  end

  def getInput
    if Input.trigger?(Input::UP)
      pbPlayCursorSE
      if @index[1] > 0
        @index[1] -= 1
        @sprites["cursor"].y -= 64
      else
        @index[1] = 4
        @sprites["cursor"].y = 256
      end
    elsif Input.trigger?(Input::DOWN)
      pbPlayCursorSE
      if @index[1] < 4
        @index[1] += 1
        @sprites["cursor"].y += 64
      else
        @index[1] = 0
        @sprites["cursor"].y = 0
      end
    elsif Input.trigger?(Input::LEFT)
      pbPlayCursorSE
      if @index[0] > 0
        @index[0] -= 1
        @sprites["cursor"].x -= 64
      else
        @index[0] = 4
        @sprites["cursor"].x = 256
      end
    elsif Input.trigger?(Input::RIGHT)
      pbPlayCursorSE
      if @index[0] < 4
        @index[0] += 1
        @sprites["cursor"].x += 64
      else
        @index[0] = 0
        @sprites["cursor"].x = 0
      end
    elsif Input.trigger?(Input::USE)
      if @cursor[0][3] == 64   # If in mark mode
        @squares.length.times do |i|
          if (@index[0] * 64) + 128 == @squares[i][0] && @index[1] * 64 == @squares[i][1] && @squares[i][3] == false
            pbSEPlay("Voltorb Flip mark")
          end
        end
        (@marks.length + 1).times do |i|
          if @marks[i].nil?
            @marks[i] = [@directory + "tiles", (@index[0] * 64) + 128, @index[1] * 64, 256, 0, 64, 64]
          elsif @marks[i][1] == (@index[0] * 64) + 128 && @marks[i][2] == @index[1] * 64
            @marks.delete_at(i)
            @marks.compact!
            @sprites["mark"].bitmap.clear
            break
          end
        end
        pbDrawImagePositions(@sprites["mark"].bitmap, @marks)
        pbWait(Graphics.frame_rate / 20)
      else
        # Display the tile for the selected spot
        icons = []
        @squares.length.times do |i|
          if (@index[0] * 64) + 128 == @squares[i][0] && @index[1] * 64 == @squares[i][1] && @squares[i][3] == false
            pbAnimateTile((@index[0] * 64) + 128, @index[1] * 64, @squares[i][2])
            @squares[i][3] = true
            # If Voltorb (0), display all tiles on the board
            if @squares[i][2] == 0
              pbSEPlay("Voltorb Flip explosion")
              # Play explosion animation
              # Part1
              animation = []
              3.times do |j|
                animation[0] = icons[0] = [@directory + "tiles", (@index[0] * 64) + 128, @index[1] * 64,
                                           704 + (64 * j), 0, 64, 64]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(Graphics.frame_rate / 20)
                @sprites["animation"].bitmap.clear
              end
              # Part2
              animation = []
              6.times do |j|
                animation[0] = [@directory + "explosion", (@index[0] * 64) - 32 + 128, (@index[1] * 64) - 32,
                                j * 128, 0, 128, 128]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(Graphics.frame_rate / 10)
                @sprites["animation"].bitmap.clear
              end
              # Unskippable text block, parameter 2 = wait time (corresponds to ME length)
              pbMessage(_INTL("\\me[Voltorb Flip game over]Oh no! You get 0 Coins!\\wtnp[50]"))
              pbShowAndDispose
              @sprites["mark"].bitmap.clear
              if @level > 1
                # Determine how many levels to reduce by
                newLevel = 0
                @squares.length.times do |j|
                  newLevel += 1 if @squares[j][3] == true && @squares[j][2] > 1
                end
                newLevel = @level if newLevel > @level
                if @level > newLevel
                  @level = newLevel
                  @level = 1 if @level < 1
                  pbMessage(_INTL("\\se[Voltorb Flip level down]Dropped to Game Lv. {1}!", @level.to_s))
                end
              end
              # Update level text
              @sprites["level"].bitmap.clear
              pbDrawShadowText(@sprites["level"].bitmap, 8, 154, 118, 28, "Level " + @level.to_s,
                               Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
              @points = 0
              pbUpdateCoins
              # Revert numbers to 0s
              @sprites["numbers"].bitmap.clear
              5.times do |j|
                pbUpdateRowNumbers(0, 0, j)
                pbUpdateColumnNumbers(0, 0, j)
              end
              pbDisposeSpriteHash(@sprites)
              @firstRound = false
              pbNewGame
            else
              # Play tile animation
              animation = []
              4.times do |j|
                animation[0] = [@directory + "flipAnimation", (@index[0] * 64) - 14 + 128, (@index[1] * 64) - 16,
                                j * 92, 0, 92, 96]
                pbDrawImagePositions(@sprites["animation"].bitmap, animation)
                pbWait(Graphics.frame_rate / 20)
                @sprites["animation"].bitmap.clear
              end
              if @points == 0
                @points += @squares[i][2]
                pbSEPlay("Voltorb Flip point")
              elsif @squares[i][2] > 1
                @points *= @squares[i][2]
                pbSEPlay("Voltorb Flip point")
              end
              break
            end
          end
        end
      end
      count = 0
      @squares.length.times do |i|
        if @squares[i][3] == false && @squares[i][2] > 1
          count += 1
        end
      end
      pbUpdateCoins
      # Game cleared
      if count == 0
        @sprites["curtain"].opacity = 100
        pbMessage(_INTL("\\me[Voltorb Flip win]Game clear!\\wtnp[40]"))
#        pbMessage(_INTL("You've found all of the hidden x2 and x3 cards."))
#        pbMessage(_INTL("This means you've found all the Coins in this game, so the game is now over."))
        pbMessage(_INTL("\\se[Voltorb Flip gain coins]{1} received {2} Coins!", $player.name, @points.to_s_formatted))
        # Update level text
        @sprites["level"].bitmap.clear
        pbDrawShadowText(@sprites["level"].bitmap, 8, 154, 118, 28, _INTL("Level {1}", @level.to_s),
                         Color.new(60, 60, 60), Color.new(150, 190, 170), 1)
        old_coins = $player.coins
        $player.coins += @points
        $stats.coins_won += $player.coins - old_coins if $player.coins > old_coins
        @points = 0
        pbUpdateCoins
        @sprites["curtain"].opacity = 0
        pbShowAndDispose
        # Revert numbers to 0s
        @sprites["numbers"].bitmap.clear
        5.times do |i|
          pbUpdateRowNumbers(0, 0, i)
          pbUpdateColumnNumbers(0, 0, i)
        end
        @sprites["curtain"].opacity = 100
        if @level < 8
          @level += 1
          pbMessage(_INTL("\\se[Voltorb Flip level up]Advanced to Game Lv. {1}!", @level.to_s))
          if @firstRound
#            pbMessage(_INTL("Congratulations!"))
#            pbMessage(_INTL("You can receive even more Coins in the next game!"))
            @firstRound = false
          end
        end
        pbDisposeSpriteHash(@sprites)
        pbNewGame
      end
    elsif Input.trigger?(Input::ACTION)
      pbPlayDecisionSE
      @sprites["cursor"].bitmap.clear
      if @cursor[0][3] == 0 # If in normal mode
        @cursor[0] = [@directory + "cursor", 128, 0, 64, 0, 64, 64]
        @sprites["memo"].visible = true
      else # Mark mode
        @cursor[0] = [@directory + "cursor", 128, 0, 0, 0, 64, 64]
        @sprites["memo"].visible = false
      end
    elsif Input.trigger?(Input::BACK)
      @sprites["curtain"].opacity = 100
      if @points == 0
        if pbConfirmMessage("You haven't found any Coins! Are you sure you want to quit?")
          @sprites["curtain"].opacity = 0
          pbShowAndDispose
          @quit = true
        end
      elsif pbConfirmMessage(_INTL("If you quit now, you will recieve {1} Coin(s). Will you quit?",
                                   @points.to_s_formatted))
        pbMessage(_INTL("{1} received {2} Coin(s)!", $player.name, @points.to_s_formatted))
        old_coins = $player.coins
        $player.coins += @points
        $stats.coins_won += $player.coins - old_coins if $player.coins > old_coins
        @points = 0
        pbUpdateCoins
        @sprites["curtain"].opacity = 0
        pbShowAndDispose
        @quit = true
      end
      @sprites["curtain"].opacity = 0
    end
    # Draw cursor
    pbDrawImagePositions(@sprites["cursor"].bitmap, @cursor)
  end

  def pbUpdateRowNumbers(num, voltorbs, i)
    numText = sprintf("%02d", num)
    numText.chars.each_with_index do |digit, j|
      @numbers[j] = [@directory + "numbersSmall", 472 + (j * 16), 8 + (i * 64), digit.to_i * 16, 0, 16, 16]
    end
    @voltorbNumbers[i] = [@directory + "numbersSmall", 488, 34 + (i * 64), voltorbs * 16, 0, 16, 16]
    # Display the numbers
    pbDrawImagePositions(@sprites["numbers"].bitmap, @numbers)
    pbDrawImagePositions(@sprites["numbers"].bitmap, @voltorbNumbers)
  end

  def pbUpdateColumnNumbers(num, voltorbs, i)
    numText = sprintf("%02d", num)
    numText.chars.each_with_index do |digit, j|
      @numbers[j] = [@directory + "numbersSmall", 152 + (i * 64) + (j * 16), 328, digit.to_i * 16, 0, 16, 16]
    end
    @voltorbNumbers[i] = [@directory + "numbersSmall", 168 + (i * 64), 354, voltorbs * 16, 0, 16, 16]
    # Display the numbers
    pbDrawImagePositions(@sprites["numbers"].bitmap, @numbers)
    pbDrawImagePositions(@sprites["numbers"].bitmap, @voltorbNumbers)
  end

  def pbCreateCoins(source, y)
    coinText = sprintf("%05d", source)
    coinText.chars.each_with_index do |digit, i|
      @coins[i] = [@directory + "numbersScore", 6 + (i * 24), y, digit.to_i * 24, 0, 24, 38]
    end
  end

  def pbUpdateCoins
    # Update coins display
    @sprites["totalCoins"].bitmap.clear
    pbCreateCoins($player.coins, 46)
    pbDrawImagePositions(@sprites["totalCoins"].bitmap, @coins)
    # Update points display
    @sprites["currentCoins"].bitmap.clear
    pbCreateCoins(@points, 112)
    pbDrawImagePositions(@sprites["currentCoins"].bitmap, @coins)
  end

  def pbAnimateTile(x, y, tile)
    icons = []
    points = 0
    3.times do |i|
      points = tile if i == 2
      icons[i] = [@directory + "tiles", x, y, 320 + (i * 64) + (points * 64), 0, 64, 64]
      pbDrawImagePositions(@sprites["icon"].bitmap, icons)
      pbWait(Graphics.frame_rate / 20)
    end
    icons[3] = [@directory + "tiles", x, y, tile * 64, 0, 64, 64]
    pbDrawImagePositions(@sprites["icon"].bitmap, icons)
    pbSEPlay("Voltorb Flip tile")
  end

  def pbShowAndDispose
    # Make pre-rendered sprites visible (this approach reduces lag)
    5.times do |i|
      @sprites[i].visible = true
      pbWait(Graphics.frame_rate / 20) if i < 3
      @sprites[i].bitmap.clear
      @sprites[i].z = 99997
    end
    pbSEPlay("Voltorb Flip tile")
    @sprites[5].visible = true
    @sprites["mark"].bitmap.clear
    pbWait(Graphics.frame_rate / 10)
    # Wait for user input to continue
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        break
      end
    end
    # "Dispose" of tiles by column
    5.times do |i|
      icons = []
      pbSEPlay("Voltorb Flip tile")
      5.times do |j|
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1],
                    448 + (@squares[i + (j * 5)][2] * 64), 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(Graphics.frame_rate / 20)
      5.times do |j|
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 384, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(Graphics.frame_rate / 20)
      5.times do |j|
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 320, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(Graphics.frame_rate / 20)
      5.times do |j|
        icons[j] = [@directory + "tiles", @squares[i + (j * 5)][0], @squares[i + (j * 5)][1], 896, 0, 64, 64]
      end
      pbDrawImagePositions(@sprites[i].bitmap, icons)
      pbWait(Graphics.frame_rate / 20)
    end
    @sprites["icon"].bitmap.clear
    6.times do |i|
      @sprites[i].bitmap.clear
    end
    @sprites["cursor"].bitmap.clear
  end

#  def pbWaitText(msg,frames)
#    msgwindow=pbCreateMessageWindow
#    pbMessageDisplay(msgwindow,msg)
#    frames.times do
#      pbWait(1)
#    end
#    pbDisposeMessageWindow(msgwindow)
#  end

  def pbEndScene
    @sprites["curtainL"].angle = -180
    @sprites["curtainR"].angle = 90
    # Draw curtain effect
    @sprites["curtainL"].visible = true
    @sprites["curtainR"].visible = true
    angleDiff = 18 * 20 / Graphics.frame_rate
    loop do
      @sprites["curtainL"].angle += angleDiff
      @sprites["curtainR"].angle -= angleDiff
      # Fixes a minor graphical bug
      @sprites["curtainL"].y -= 2 if @sprites["curtainL"].angle >= -90
      Graphics.update
      Input.update
      update
      if @sprites["curtainL"].angle >= -90
        break
      end
    end
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      getInput
      break if @quit
    end
  end
end



class VoltorbFlipScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStart
    @scene.pbScene
    @scene.pbEndScene
  end
end



def pbVoltorbFlip
  if !$bag.has?(:COINCASE)
    pbMessage(_INTL("You can't play unless you have a Coin Case."))
  elsif $player.coins == Settings::MAX_COINS
    pbMessage(_INTL("Your Coin Case is full!"))
  else
    scene = VoltorbFlip.new
    screen = VoltorbFlipScreen.new(scene)
    screen.pbStartScreen
  end
end
